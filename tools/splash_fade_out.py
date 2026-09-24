from pathlib import Path
import io
import sys

# I want 60 shades of the palette, not including the original palette.
# The fade-out will take 1 second (aka 60 frames)
# This modifies both palettes. So the table will be 960 bytes.

class Color555:
        def __init__(self, r = 0.0, g = 0.0, b = 0.0):
                self.r: float = r
                self.g: float = g
                self.b: float = b 
        def __str__(self):
                return f"({round(self.r)},{round(self.g)},{round(self.b)})"
        def duplicate(self):
                return Color555(self.r, self.g, self.b)
        def lerp_down(self, t: float):
                self.r *= t
                self.g *= t
                self.b *= t
        def write_to(self, file: io.FileIO):
                word = round(self.r) | (round(self.g) << 5) | (round(self.b) << 10)
                file.write(word.to_bytes(2, byteorder = "little"))

class Palettes:
        def __init__(self):
                self.colors = [Color555() for _ in range(8)] 
        def __str__(self):
                out = "["
                for color in self.colors:
                        out += f"{color} "
                return out + "]"
        def duplicate(self):
                palettes = Palettes()
                palettes.colors = [self.colors[i].duplicate() for i in range(8)] 
                return palettes
        def lerp_down(self, t: float):
                for color in self.colors:
                        color.lerp_down(t)
        def write_to(self, file):
                for color in self.colors:
                        color.write_to(file)


def run():
        original_palettes = Palettes()
        with Path("../assets/splash.pal").open("rb") as file:
                for i in range(8):
                        low_byte = file.read(1)[0]
                        high_byte = file.read(1)[0]
                        word = (high_byte << 8) | low_byte
                        color = Color555()
                        color.r = word & 0b11111
                        color.g = (word >> 5) & 0b11111
                        color.b = (word >> 10) & 0b11111
                        original_palettes.colors[i] = color
        print(f"Original Palettes: {original_palettes}")

        palette_shades: list[Palettes] = []
        lerp_t = 0.933          # Trying to keep it decrease steadily, till the last palette is all zeros
        for i in range(60):
                if i == 0:
                        new_palette = original_palettes.duplicate()
                        new_palette.lerp_down(lerp_t)
                        palette_shades.append(new_palette)
                        continue
                new_palette = palette_shades[-1].duplicate()
                new_palette.lerp_down(lerp_t)
                palette_shades.append(new_palette)

        for i in range(len(palette_shades)):
                print(f"New Palettes {i}: {palette_shades[i]}")

        with Path("../assets/splash_fade_out_palettes.bin").open("wb") as file:
                for palette in palette_shades:
                        palette.write_to(file)
        
        print("Finished")
run()
