#!/usr/bin/env python3
"""
Monkey-patch PreTeXt to fix XSL entity resolution and Runestone services issues.

This module patches PreTeXt's core modules to work around:
1. External entity resolution issues in XSL processing (lxml incompatibility)
2. Graceful fallback for Runestone services

Apply this patch before building by importing: `import fix_pretext`
"""

import os
import re
import sys
import tempfile
from functools import wraps
from pathlib import Path


def patch_pretext():
    """Apply all necessary patches to PreTeXt."""
    
    # Patch 1: Fix XSL entity resolution in common.py
    try:
        from pretext.core import common
        from lxml import etree as ET
        
        original_xsltproc = common.xsltproc
        
        @wraps(original_xsltproc)
        def patched_xsltproc(xsl, xml, result, output_dir=None, stringparams={}):
            """Patched xsltproc that handles entity resolution issues.
            
            Args match original: (xsl, xml, result, output_dir=None, stringparams={})
            """
            
            # Read the XSL file
            xsl_dir = os.path.dirname(xsl)
            with open(xsl, 'r', encoding='utf-8') as f:
                xsl_content = f.read()
            
            # Remove DOCTYPE declarations that cause entity resolution issues
            xsl_content_fixed = re.sub(
                r'<!DOCTYPE[^[]*\[[^]]*\]>',
                '',
                xsl_content,
                flags=re.DOTALL
            )
            
            # Fix import/include paths to use absolute paths
            def fix_import_include_path(match):
                tag_type = match.group(1)  # 'import' or 'include'
                rel_path = match.group(2)
                abs_path = os.path.normpath(os.path.join(xsl_dir, rel_path))
                return f'<xsl:{tag_type} href="{abs_path}"'
            
            xsl_content_fixed = re.sub(
                r'<xsl:(import|include)\s+href="([^"]+)"',
                fix_import_include_path,
                xsl_content_fixed
            )
            
            # If we removed a DOCTYPE, load and process entities
            if xsl_content_fixed != xsl_content:
                entity_match = re.search(r'<!ENTITY %\s+(\w+)\s+SYSTEM\s+"([^"]+)">', xsl_content)
                if entity_match:
                    rel_path = entity_match.group(2)
                    abs_entity_path = os.path.normpath(os.path.join(xsl_dir, rel_path))
                    
                    if os.path.exists(abs_entity_path):
                        with open(abs_entity_path, 'r', encoding='utf-8') as f:
                            entity_content = f.read()
                        
                        # Parse entity definitions
                        entity_dict = {}
                        for match in re.finditer(r'<!ENTITY\s+([\w-]+)\s+"([^"]*)">', entity_content):
                            entity_key = match.group(1)
                            entity_value = match.group(2)
                            entity_dict[entity_key] = entity_value
                        
                        # Recursively expand entities
                        for _ in range(10):  # Limit iterations
                            changed = False
                            for key, value in list(entity_dict.items()):
                                new_value = value
                                for ref_key, ref_value in entity_dict.items():
                                    if ref_key != key and f'&{ref_key};' in new_value:
                                        new_value = new_value.replace(f'&{ref_key};', ref_value)
                                        changed = True
                                entity_dict[key] = new_value
                            if not changed:
                                break
                        
                        # Replace entities in XSL
                        for entity_key, entity_value in entity_dict.items():
                            xsl_content_fixed = xsl_content_fixed.replace(
                                f'%{entity_key};', 
                                entity_value
                            )
                            xsl_content_fixed = xsl_content_fixed.replace(
                                f'&{entity_key};',
                                entity_value
                            )
            
            # Write fixed XSL to a temporary file for parsing
            with tempfile.NamedTemporaryFile(
                mode='w',
                suffix='.xsl',
                delete=False,
                encoding='utf-8'
            ) as tmp:
                tmp.write(xsl_content_fixed)
                tmp_path = tmp.name
            
            try:
                # Use the temporary file for processing
                control = None
                if output_dir:
                    control = ET.XSLTAccessControl(write_file=True)
                xsl_tree = ET.parse(tmp_path)
                xslt = ET.XSLT(xsl_tree, access_control=control)
                
                # Continue with original logic
                xml_tree = ET.parse(xml)
                result_tree = xslt(xml_tree, **stringparams) if stringparams else xslt(xml_tree)
                
                if result:
                    result_tree.write(
                        result,
                        pretty_print=True,
                        xml_declaration=True,
                        encoding='utf-8'
                    )
                else:
                    # Return string if no result file specified
                    return ET.tostring(
                        result_tree,
                        pretty_print=True,
                        xml_declaration=True,
                        encoding='utf-8'
                    )
            finally:
                os.unlink(tmp_path)
        
        common.xsltproc = patched_xsltproc
        print("✓ Patched pretext.core.common.xsltproc")
    except Exception as e:
        print(f"✗ Failed to patch common.xsltproc: {e}")
        sys.exit(1)
    
    # Patch 2: Fix Runestone services handling
    try:
        from pretext.core import pretext
        
        original_query_rs = pretext.query_runestone_services
        
        @wraps(original_query_rs)
        def patched_query_runestone_services(services_url):
            """Patched query_runestone_services with graceful fallback."""
            try:
                # Try the original function first
                return original_query_rs(services_url)
            except Exception:
                # Return minimal default XML structure on failure
                return '''<?xml version="1.0"?>
<all>
    <js>
        <item>default.js</item>
    </js>
    <css>
        <item>default.css</item>
    </css>
    <cdn-url>https://runestone.academy</cdn-url>
    <version>latest</version>
</all>'''
        
        pretext.query_runestone_services = patched_query_runestone_services
        print("✓ Patched pretext.core.pretext.query_runestone_services")
    except Exception as e:
        print(f"✗ Failed to patch utils.get_services: {e}")
        sys.exit(1)


# Apply patches when module is imported
patch_pretext()
