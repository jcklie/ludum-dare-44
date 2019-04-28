import os

import delegator

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
output_folder = os.path.abspath(os.path.join("..", "..", "player", "skin"))

for char, name in characters.items():
    skin_anim_path = os.path.join(output_folder, name, "idle")
    os.makedirs(skin_anim_path, exist_ok=True)

    for ang_step in range(camera_rot_x_steps):
        output_filename = os.path.join(skin_anim_path, f"{ang_step}.png")

        parameters = {"char": '\"' + char + '\"',
                      "$fn": 100}

        parameter_string = "\'" + ";".join([k + "=" + str(v) for k,v in parameters.items()]) + "\'"

        command_parts = ["openscad",
                         f"-o {output_filename}",
                         f"-D {parameter_string}",
                         f"--camera=0,0,{camera_trans_z},{camera_rot_x},0,{(ang_step/camera_rot_x_steps) * 360},{camera_dist}",
                         f"--imgsize={image_size},{image_size}",
                         "--projection=p",
                         "--autocenter",
                         scad_filename]
        render_command = " ".join(command_parts)
        c = delegator.run(render_command)

        # next up, we remove the light yellow background from OpenSCAD with transparency
        transparency_command = f"convert {output_filename} -transparent '#ffffe5' {output_filename}"
        c = delegator.run(transparency_command)