# `rp_localize`

Use this mod if you want to print a number respecting the current locale.

## `loc.num(numbr)`

Takes a number `numbr` and return a formatted string representing the number appropriately for the current locale.
For positive integers, the output is the same as for `tostring`.

For convenience, if `numbr` is a string, it will first be attempted to internally convert it to a number.
If it succeeds, it is localized. If it fails, the string is returned unchanged.

This function currently supports the decimal point, the minus sign and the infinity sign. NaNs will be shown as `tostring` would show them.
