Usually, items are placed properly on the item frame or item showcase and look correctly.
However, sometimes these might appear too big or are offset too far away from the node.

So there are two optional node fields recognize which you can use to tweak the appearance
of the entity when placed:

* `_rp_itemshow_scale`: Number. Set the scale of the entity in the itemshow node directly.
                        Use this when the entity visual would be too big.
* `_rp_itemshow_offset`: Vector. Offset the entity sideways and up/down. X and Z MUST be equal.
                         You usually need this if the entity appears "behind" the item frame.
