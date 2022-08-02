# `drop_items_on_die` API

Use this API if your mod modifies the player inventory
and you want to make sure the items drop to the ground
on death.

There is one function.

## `drop_items_on_die.register_listname(listname)`

Tells this mod that the player inventory list with the name
`listname` should drop its item when the player dies.

