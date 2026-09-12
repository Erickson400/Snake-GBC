import subprocess
from pathlib import Path

"""
This script builds the project into a working rom.

Project structure:
    assets/        --- Holds game and graphics data. In binary, png or some other format.
    bin/           --- Holds the final ROM, symbol and map files, and object files.
    src/           --- Where all the assembly code lives.
    src/include    --- Holds global constants and libraries.
    tools/         --- Python scripts for generating assets.
Folders can have sub-folders.

Building pipeline:
rgbasm -> rgblink -> rgbfix -> valid_rom.
rgbgfx can be used to generate assets from png,
but I think tool scripts should handle that and not the build script.

Steps:
- Get every file path from src/ except files from src/include/
- For each file run `rgbasm $in --include src/include --output $out`,
where $in is the .asm file, and $out is the .obj file. obj files should be put
in a temporary bin/obj/ folder.
- Run `rgblink bin/obj/*.o --map bin/memory.map --sym bin/symbols.sym --tiny --wramx --nopad --output snake.gbc`
- Run `rgbfix snake.gbc --color-only --validate --title SNAKE`
- Clear the bin/obj/ folder.

For what all the commands params do, check https://rgbds.gbdev.io/docs/v1.0.3/rgbasm.1.
"""

def run():
    exit = subprocess.run(["rgbasm", "-h"])
    if exit.returncode == 1:
        print("SUS")

run()
