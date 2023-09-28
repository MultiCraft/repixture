# `rp_music` API documentation

The following functions are available:

## `rp_music.add_track(name, def)
Add a track to the track list.

* `name`: File name of track (without suffix; must not start with a digit)
* `def`: Track definition. A table with these fields:
    * `length`: Length of track in seconds
    * `note_color`: Color of the note particle emitted by the music player

Also, the track *must* be in mono for positional playback to work properly.

## `rp_music.clear_tracks()`
Remove all tracks from the track list.

Useful if you want to build your own track list from scratch.

## `rp_music.start(pos)`
Start music playback of a music player node at pos.
Does nothing if there's not a music player.

## `rp_music.start(pos)`
Stops music playback of a music player node at pos.
Does nothing if there's not a music player.

## `rp_music.toggle(pos)`
Toggle music player node on/off (at pos).
Does nothing if there's not a music player.
