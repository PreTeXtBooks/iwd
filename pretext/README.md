# PreTeXt Book Version

This directory contains the PreTeXt version of ...

The repository contains a repository of STACK questions as a submodule.

If you are cloning this repository, use `git clone --recurse-submodules` (or `git clone --recursive`).

## Building the Book

To build the book locally:

```bash
cd pretext
pretext build web
```

To view the built book:

```bash
pretext view web
```

### PDF version

To build the PDF version, we need to generate static versions of the STACK questions (once).
Thus, the first time and whenever STACK questions have been updated or added, run:

```bash
pretext generate stack
pretext build print
```


## GitHub Actions Deployment

The book is automatically built and validated when commits are made to pull requests, and deployed to GitHub Pages when changes are pushed to the main branch. See `.github/workflows/deploy-pretext.yml` for the deployment configuration.

## R Code Support

The book includes support for R code examples with syntax highlighting. R code blocks are defined using:

```xml
<program language="r">
  <input>
# Your R code here
x &lt;- 10  # Use &lt; for < in XML
  </input>
</program>
```

For interactive code blocks, add the `interactive="yes"` attribute.

## Images

Images should be placed in the `source/images/` directory or the `assets/` directory and can be included using the `<image>` element in PreTeXt.

## Project Structure

- `source/` - PreTeXt source files (.ptx)
- `source/main.ptx` - Main book file
- `source/ch_*.ptx` - Chapter files
- `source/images/` - Image source files
- `assets/` - Static assets (images, data files, STACK questions, etc.)
- `publication/` - Publication configuration
- `project.ptx` - Project configuration
- `output/` - Generated output (not tracked in git)

## More Information

For more information about PreTeXt, visit:
- PreTeXt documentation: https://pretextbook.org/
- PreTeXt Guide: https://pretextbook.org/doc/guide/html/

## STACK questions

STACK questions are included as submodules in the folder `assets/stack/`.

When cloning this repository, to also check out the submodule content, run `git clone --recurse-submodules` (or `git clone --recursive`) rather than merely `git clone`.

### Updating the STACK questions

Each commit in this PreTeXt repo has a specific commit of the submodule associated with it (i.e. a specific state of the STACK questions). To update to a newer commit, there are two options:

Two options:
1. Go into submodule subfolder, e.g. `assets/stack/Statistics-and-Probability-Open-Question-Bank`, run `git pull` to update to the latest commit of the submodule.
2. Alternatively, in the project root run `git submodule update --remote` or `git submodule update --remote pretext/assets/stack/Statistics-and-Probability-Open-Question-Bank/` to update a specific submodule (the path is relative to current working directory)
Then make a new commit in the PreTeXt repo to associate the new commit with the PreTeXt repository.

## Pulling latest changes

If changes have happened upstream to the STACK question repo, a simple `git pull` in the PreTeXt repo will update the associated commit ID, but not update the submodule content. To update the content as well, you have three options:

1. `git pull && git submodule update --init --recursive`
	1. Update: Updates the **content** of the submodule (not just the reference commit)
	2. init: Add new submodules, in case any were added in the latest commits
	3. recursive: in case the submodules themselves contain submodules
2. As of [Git 2.14](https://github.com/git/git/blob/master/Documentation/RelNotes/2.14.0.txt#L117), you can use `git pull --recurse-submodules` (and alias it to whatever you like if you want).
3. As of [Git 2.15](https://github.com/git/git/blob/master/Documentation/RelNotes/2.15.0.txt#L358), you could set [`submodule.recurse`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-submodulerecurse) to true so that `git pull` does this automatically. You can do this globally by running: `git config --global submodule.recurse true`