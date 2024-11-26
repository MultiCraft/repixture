# The Repixture Translation Maintenance Workflow

This document is directed to *developers* describing what to do how to make sure the Repixture translation files stay up to date and functional.

**If you just want to translate, go to:** <https://translate.codeberg.org/projects/repixture/> (you can ignore the rest of the document)



## Introduction

Repixture translations utilize Weblate to allow translators to translate the game online.

Rather than translating strings directly in the PO files, translators are encouraged to go to <https://translate.codeberg.org/projects/repixture/> to translate the string. The Repixture maintainer(s) do the rest.


## Preconditions

You need:

* Python 3
* gettext


## Part 1: Pushing the translations from the game to Weblate:

1. Clean up: Make sure the game repository is in a clean state (no non-committed changes)
2. Update POT files: Run `update_locale_templates.py` in the root directory of this repositoryand commit the changes (if any)
3. Update PO files: TODO
4. Push: Push the changes to the online repository of the game
5. Update Weblate repository (optional): Weblate should soon automatically update its repository. But if you want to want the new strings to be available immediately, go to the project page, then “Manage > Repository Maintenance” and click “Update”

Now the new translations should be visible in Weblate and are available to translators. It is best practice to do this either in regular intervals or whenever a major batch of strings was added or changed, and not just right before a release. That way, translators have time to react.

You should also quickly look over some of the Weblate components to make sure the change actually worked.

## Part 2: Translating

Use the Weblate interface to translate the strings. Inform other translations when a major batch of strings has arrived. Weblate also allows to add announcements on the top of the page via the “Management” button.



## Part 3: Downloading the translations back to the game:

This part is usually done when you’re preparing a release. You want to extract the strings that have been translated in Weblate back to the game.

1. Clean up: Make sure the game repository is in a clean state (no non-committed changes)
2. Commit to Weblate repository: Go to “Manage > Repository Maintenance” and click “Commit” (if the number of pending commits is 0, you can skip this step)
3. Pull from Weblate repository: `git pull weblate <name of main branch>`

Now all the translations from Weblate should be in the game. You may want to do a quick in-game test to make sure.
