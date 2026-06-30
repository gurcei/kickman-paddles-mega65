Trying to get the paddles-version of the game (patched by crispyfpga) working more nicely on the mega65:

- https://www.lemon64.com/forum/viewtopic.php?t=73267&sid=857e6b07d415892624c935e2bdee7c5e

## Building the patch loader

The ACME source version of the patch lives at `src/kickman-patch.asm`.

```sh
make
```

This emits `build/kickman-patch.prg`. Override the assembler path with `ACME=/path/to/acme make` if needed.

Or run ACME directly:

```sh
mkdir -p build
acme -f cbm -o build/kickman-patch.prg src/kickman-patch.asm
```
