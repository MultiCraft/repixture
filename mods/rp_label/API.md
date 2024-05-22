## Functions

### `rp_label.write_name(pos, text)`

Sets the name/label text of the node at `pos` to `text`.
Only has an effect if the node supports labels.

### `rp_label.container_label_formspec_element(meta)`

Returns a formspec string for a given node metadata
that adds a white 'label' formspec element on top of the
formspec showing the current label of the node (added
with the "label and graphite") item. The node label
is defined in the metadata string `"name"`.

Useful for all container nodes that can be labelled
that way.

If the label is empty, an empty formspec string will
be returned.

