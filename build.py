import os
import shutil
import subprocess as subp
from pathlib import Path
import tempfile

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
    # Create missing folders if they dont exist.
    Path("src").mkdir(parents=True, exist_ok=True)
    Path("src/include").mkdir(parents=True, exist_ok=True)
    Path("assets").mkdir(parents=True, exist_ok=True)

    # Get the .asm files
    asm_files = list(filter(
        lambda x: x.suffix == ".asm" and x.is_file(),
        Path("src").rglob('*')
    ))
    if len(asm_files) != len(set(asm_files)):
        print("Error: There are multiple .asm files with the same name")
        return

    # Create a temp obj directory 
    with tempfile.TemporaryDirectory() as obj_dir:
        obj_file_paths = []

        # Compile
        for asm in asm_files:
            obj_file_path = Path(obj_dir) / (asm.stem + ".o")
            obj_file_paths.append(obj_file_path)
            exec_result = subp.run(["rgbasm", asm, "--include", "src/include", "--output", obj_file_path])
            if exec_result.returncode != 0:
                print(f"\n^ BUILD ERROR ^\n")
                print(exec_result.stdout, exec_result.stderr)
                return

        # Link
        exec_result = subp.run(["rgblink", *obj_file_paths, "--map", "bin/memory.map", "--sym", "bin/symbols.sym", "--tiny", "--wramx", "--nopad", "--output", "bin/snake.gbc"])
        if exec_result.returncode != 0:
            print(f"\n^ BUILD ERROR ^\n")
            print(exec_result.stdout, exec_result.stderr)
            return

        # Fix
        exec_result = subp.run(["rgbfix", "bin/snake.gbc", "--color-only", "--validate", "--title", "SNAKE"])
        if exec_result.returncode != 0:
            print(f"\n^ BUILD ERROR ^\n")
            print(exec_result.stdout, exec_result.stderr)
            return

run()
