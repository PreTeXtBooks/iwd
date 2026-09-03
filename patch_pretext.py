#!/usr/bin/env python3
"""
Patch PreTeXt to fix build issues.

This script applies workarounds to PreTeXt's core modules to fix:
1. External entity resolution issues in XSL processing (lxml incompatibility)
2. Graceful fallback for Runestone services

These patches should be applied after installing PreTeXt.
"""

import os
import re
import sys
from pathlib import Path


def find_pretext_installation():
    """Find the PreTeXt installation directory."""
    try:
        import pretext
        return Path(pretext.__file__).parent
    except ImportError:
        print("PreTeXt not found. Please install it with: pip install pretext")
        sys.exit(1)


def patch_common_py(pretext_path):
    """Patch pretext/core/common.py to fix entity resolution in XSL processing."""
    common_py = pretext_path / "core" / "common.py"
    
    if not common_py.exists():
        print(f"✗ {common_py} not found")
        return False
    
    with open(common_py, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already patched
    if "xsl_content_fixed.replace(f'&{entity_key};'" in content:
        print("✓ common.py already patched")
        return True
    
    # Find and replace the xsltproc function's XSL parsing section
    old_code = '''    control = None
    if output_dir:
        control = ET.XSLTAccessControl(write_file=True)
    xsl_tree = ET.parse(xsl)
    xslt = ET.XSLT(xsl_tree, access_control=control)'''
    
    new_code = '''    control = None
    if output_dir:
        control = ET.XSLTAccessControl(write_file=True)
    
    # Fix external entity loading issues and relative import paths
    import os
    import re
    import tempfile
    
    xsl_dir = os.path.dirname(xsl)
    with open(xsl, 'r', encoding='utf-8') as f:
        xsl_content = f.read()
    
    # Remove DOCTYPE declarations that have external entities
    xsl_content_fixed = re.sub(r'<!DOCTYPE[^[]*\\[[^]]*\\]>', '', xsl_content, flags=re.DOTALL)
    
    # Fix import/include paths to use absolute paths
    # Only match xsl:import and xsl:include elements, not document() or other functions
    def fix_import_include_path(match):
        tag_type = match.group(1)  # 'import' or 'include'
        rel_path = match.group(2)
        abs_path = os.path.normpath(os.path.join(xsl_dir, rel_path))
        return f'<xsl:{tag_type} href="{abs_path}"'
    
    xsl_content_fixed = re.sub(r'<xsl:(import|include)\\s+href="([^"]+)"', fix_import_include_path, xsl_content_fixed)
    
    # If we removed a DOCTYPE, we need to load the entities and do string replacement
    if xsl_content_fixed != xsl_content:
        # Find entity file references that were in the DOCTYPE
        entity_match = re.search(r'<!ENTITY %\\s+(\\w+)\\s+SYSTEM\\s+"([^"]+)">', xsl_content)
        if entity_match:
            rel_path = entity_match.group(2)
            
            # Resolve and load the entity file
            abs_path = os.path.normpath(os.path.join(xsl_dir, rel_path))
            if os.path.exists(abs_path):
                with open(abs_path, 'r', encoding='utf-8') as f:
                    entity_content = f.read()
                
                # Parse entity declarations from the file (including hyphens in names)
                entity_dict = {}
                entity_pattern = r'<!ENTITY\\s+([\\w-]+)\\s+"([^"]*)">'
                for match in re.finditer(entity_pattern, entity_content):
                    entity_key = match.group(1)
                    entity_value = match.group(2)
                    entity_dict[entity_key] = entity_value
                
                # Recursively expand entity references
                max_iterations = 10
                for _ in range(max_iterations):
                    changed = False
                    for entity_key, entity_value in entity_dict.items():
                        new_value = entity_value
                        for ref_key, ref_value in entity_dict.items():
                            if f'&{ref_key};' in new_value and ref_key != entity_key:
                                new_value = new_value.replace(f'&{ref_key};', ref_value)
                                changed = True
                        entity_dict[entity_key] = new_value
                    if not changed:
                        break
                
                # Replace entities in the XSL
                for entity_key, entity_value in entity_dict.items():
                    xsl_content_fixed = xsl_content_fixed.replace(f'%{entity_key};', entity_value)
                    xsl_content_fixed = xsl_content_fixed.replace(f'&{entity_key};', entity_value)
        
        # Create a temporary file with the fixed content
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xsl', delete=False, encoding='utf-8') as tmp:
            tmp.write(xsl_content_fixed)
            tmp_path = tmp.name
        
        try:
            xsl_tree = ET.parse(tmp_path)
        finally:
            os.unlink(tmp_path)
    else:
        xsl_tree = ET.parse(xsl)
    xslt = ET.XSLT(xsl_tree, access_control=control)'''
    
    if old_code in content:
        content = content.replace(old_code, new_code)
        with open(common_py, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✓ Patched common.py")
        return True
    else:
        print("✗ Could not find XSL parsing section in common.py")
        return False


def patch_utils_py(pretext_path):
    """Patch pretext/utils.py for Runestone services handling."""
    utils_py = pretext_path / "utils.py"
    
    if not utils_py.exists():
        print(f"✗ {utils_py} not found")
        return False
    
    with open(utils_py, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already patched
    if "default.js" in content and "default.css" in content:
        print("✓ utils.py already patched")
        return True
    
    # Find the XML format section and replace it
    old_pattern = r'if format == "xml":.*?elif format == "tgz":'
    new_section = '''if format == "xml":
        assert url != "", "URL must be provided to download xml file."
        assert out_path == "", "Output path must not be provided to download xml file."
        try:
            log.info(f"Downloading rs services file from {url}.")
            services_xml = requests.get(url).text
        except Exception as e:
            log.debug(e)
            services_xml = """<?xml version="1.0"?>
<all>
    <js>
        <item>default.js</item>
    </js>
    <css>
        <item>default.css</item>
    </css>
    <cdn-url>https://runestone.academy</cdn-url>
    <version>latest</version>
</all>"""
        finally:
            return services_xml

    elif format == "tgz":'''
    
    if re.search(old_pattern, content, re.DOTALL):
        content = re.sub(old_pattern, new_section, content, flags=re.DOTALL)
        with open(utils_py, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✓ Patched utils.py")
        return True
    else:
        print("✗ Could not find XML format section in utils.py")
        return False


def main():
    print("Patching PreTeXt...")
    pretext_path = find_pretext_installation()
    print(f"Found PreTeXt at: {pretext_path}\n")
    
    success = True
    success = patch_common_py(pretext_path) and success
    success = patch_utils_py(pretext_path) and success
    
    if success:
        print("\n✓ All patches applied successfully")
        return 0
    else:
        print("\n✗ Some patches could not be applied")
        return 1


if __name__ == "__main__":
    sys.exit(main())
