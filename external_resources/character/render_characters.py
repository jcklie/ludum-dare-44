import os

import delegator

output_folder = "target"
characters = {"€": "eur",
              "$": "usd",
              "£": "gbp",
              "¥": "yen"}

scad_filename = os.path.abspath("character.scad")
camera_rot_x_steps = 16
camera_rot_x = 55
camera_trans_z = 5
camera_dist = 36
image_size = 256

os.makedirs(output_folder, exist_ok=True)

for char, name in characters.items():
    for camera_rot_z in range(0, 360, 45):
        output_filename = os.path.join(output_folder, f"{name}_{camera_rot_z}.png")

        parameters = {"char": '\"' + char + '\"',
                      "$fn": 100}

        parameter_string = "\'" + " ".join([k + "=" + str(v) for k,v in parameters.items()]) + "\'"

        command_parts = ["openscad",
                         f"-o {output_filename}",
                         f"-D {parameter_string}",
                         f"--camera=0,0,{camera_trans_z},{camera_rot_x},0,{camera_rot_z},{camera_dist}",
                         f"--imgsize={image_size},{image_size}",
                         "--projection=p",
                         "--autocenter",
                         scad_filename]
        command = " ".join(command_parts)
        c = delegator.run(command)