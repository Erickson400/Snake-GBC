import os
import shutil
import subprocess as subp

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


def run_rgbasm_recursive(directory, obj_file_paths):
    # print(f"RGBASM DIRECTORY -> {directory}")

    files_in_dir = next(os.walk(directory))[2]
    folders_in_dir = next(os.walk(directory))[1]

    directory_without_src = directory.replace("./src", "")

    for file in files_in_dir:
        if not file.endswith(".asm"):
            continue

        file_name, file_extension = os.path.splitext(file)

        obj_folder = f"bin/obj/{directory_without_src}"
        os.makedirs(obj_folder, exist_ok=True)
        obj_file_path = os.path.join(obj_folder, f"{file_name}.obj")
        obj_file_paths.append(obj_file_path)

        exec_result = subp.run(["rgbasm", f"{os.path.join(directory, file)}", "--include", "src/include", "--output", obj_file_path])
        if exec_result.returncode == 1:
            print(f"\n^ BUILD ERROR ^\n")

            print(f"ASM -> {os.path.join(directory, file)}")
            print(f"OBJ -> {obj_file_path}")
            return

    for folder in folders_in_dir:
        run_rgbasm_recursive(os.path.join(directory, folder), obj_file_paths)



def run():

    obj_file_paths = []
    print("Running rgbasm")
    run_rgbasm_recursive('./src', obj_file_paths)

    print("Running rgblink")
    for obj_file_path in obj_file_paths:
        exec_result = subp.run(["rgblink", obj_file_path, "--map", "bin/memory.map", "--sym", "bin/symbols.sym", "--tiny", "--wramx", "--nopad", "--output", "bin/snake.gbc"])
        if exec_result.returncode == 1:
            print(f"\n^ BUILD ERROR ^\n")
            return

    print("Running rgbfix")
    exec_result = subp.run(["rgbfix", "bin/snake.gbc", "--color-only", "--validate", "--title", "SNAKE"])
    if exec_result.returncode == 1:
        print(f"\n^ BUILD ERROR ^\n")
        return

    print("Clearing bin/obj folder")
    folders_in_bin_obj = next(os.walk("bin/obj/"))[1]
    for folder in folders_in_bin_obj:
        shutil.rmtree(os.path.join("bin/obj/", folder))

    files_in_bin_obj = next(os.walk("bin/obj/"))[2]
    for file in files_in_bin_obj:
        os.remove(os.path.join("bin/obj/", file))

run()
