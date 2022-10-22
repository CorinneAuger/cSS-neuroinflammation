# Darkens color for borders around points on a plot

import colorsys

def scale_lightness(rgb, scale_l):
    # convert rgb to hls
    h, l, s = colorsys.rgb_to_hls(*rgb)
    # manipulate h, l, s values and return as rgb
    return colorsys.hls_to_rgb(h, min(1, l * scale_l), s = s)

color_in = input("Color: ")
color_in = map(float, color_in.split(", "))
r,g,b = scale_lightness(color_in, 0.5)
print(f"{r:.2f}, {g:.2f}, {b:.2f}")
