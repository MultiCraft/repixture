# Manual Generator for Repixture

This directory contains the source files that will generate the Repixture Player Manual for Repixture.

The manual utilizes Hugo, a static site generator (<https://www.gohugo.io>).

## How to generate/update the manual

You need Hugo for this to work. These are the steps:

1. Change directory to `manual_generator` (you are here)
2. Delete the `public` directory (if was generated before)
3. Run `hugo`

The result is a webpage in `manual_generator/public`. You can open it in a webbrowser.
Note the output is meant for Codeberg Pages, however.

## How to publish the manual

The manual is supposed to be used by Codeberg Pages.
There is a special `pages` branch in the Repixture repository.

1. Generate the manual (see above)
2. Switch to the `pages` branch
3. Copy the contents of `manual_generator/pages` to the root directory of this repository
4. Check if everything looks OK. Delete files that are no longer used
5. Commit the changes
