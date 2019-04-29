import os

import delegator

characters = {"eur": ("€", "[0.269, 0.347, 0.953]"),
              "usd": ("$", "[0, 1.0, 0]"),
              "gbp": ("£", "[1.0, 0.65, 0]"),
              "yen": ("¥", "[0.7, 0.3, 0.95]")}

def run_openscad_render(openscad_options, scad_filename, output_filename):
    command_parts = ["openscad",
                     f"-o {output_filename}",
                     *openscad_options,
                     scad_filename]
    openscad_command = " ".join(command_parts)
    delegator.run(openscad_command, block=True)

    # next up, we remove the light yellow background from OpenSCAD with transparency
    transparency_command = f"convert {output_filename} -transparent '#ffffe5' {output_filename}"
    delegator.run(transparency_command, block=True)

def render_characters():
    scad_filename = os.path.abspath("character.scad")
    camera_rot_x_steps = 16
    camera_rot_x = 55
    camera_trans_z = 5
    camera_dist = 36
    image_size = 256
    output_folder = os.path.abspath(os.path.join("..", "..", "player", "skin"))

    for name, (char, color) in characters.items():
        skin_anim_path = os.path.join(output_folder, name, "idle")
        os.makedirs(skin_anim_path, exist_ok=True)

        for ang_step in range(camera_rot_x_steps):
            output_filename = os.path.join(skin_anim_path, f"{ang_step}.png")

            parameters = {"char": '\"' + char + '\"',
                          "char_color": color,
                          "angry": "false",
                          "$fn": 100}

            parameter_string = "\'" + ";".join([k + "=" + str(v) for k,v in parameters.items()]) + "\'"

            openscad_options = [f"-D {parameter_string}",
                             f"--camera=0,0,{camera_trans_z},{camera_rot_x},0,{(ang_step/camera_rot_x_steps) * 360},{camera_dist}",
                             f"--imgsize={image_size},{image_size}",
                             "--projection=p",
                             "--autocenter"]

            run_openscad_render(openscad_options, scad_filename, output_filename)

def render_splash_screen():
    scad_filename = os.path.abspath("splash_screen.scad")
    image_width = 2560
    image_height = 1440

    openscad_options = ["--camera=1.28,4.64,4.39,92.1,0,209.3,60.27",
                        f"--imgsize={image_width},{image_height}",
                        "--autocenter"]
    output_filename = os.path.abspath("splash.png")

    run_openscad_render(openscad_options, scad_filename, output_filename)


def render_character_profiles():
    image_width = 1024
    image_height = 576

    parameters = {"eur": "--camera=3.32,0.74,4.9,113.8,0,58.6,54.24",
                  "usd": "--camera=2.39,-0.46,5.62,102.60,0,49.50,60.27",
                  "gbp": "--camera=2.64,3.31,7.28,112.4,0,52.3,43.93",
                  "yen": "--camera=0.63,1.26,4.97,84.4,0,50.2,54.24"}

    for k, cam_settings in parameters.items():
        openscad_options = [f"-D \'scene=\"{k}\"\'",
                            cam_settings,
                            f"--imgsize={image_width},{image_height}",
                            "--autocenter"]
        output_filename = os.path.abspath(f"{k}_profile.png")
        run_openscad_render(openscad_options, "character_profile.scad", output_filename)


def render_cash_exchange_shops():
    image_size = 32
    output_folder_parts = ["..", "..", "cash_exchange"]

    # animation name, number of animation frames
    animations = {"Open": 1,
                  "Exchanging": 16,
                  "Closed": 1}

    for name, (char, color) in characters.items():
        for ani, steps in animations.items():
            ani_output_folder_parts = output_folder_parts + [name, ani]
            output_folder = os.path.abspath(os.path.join(*ani_output_folder_parts))

            for step in range(steps):
                parameters = {"char": '\"' + char + '\"',
                              "char_color": color,
                              "animation": '\"' + ani + '\"',
                              "step": step,
                              "$fn": 100}
                parameter_string = "\'" + ";".join([k + "=" + str(v) for k,v in parameters.items()]) + "\'"

                openscad_options = [f"-D {parameter_string}",
                                    f"--camera=0,8,0.75,17.5,0,0,40",
                                    f"--imgsize={image_size},{image_size}",
                                    "--projection=p",
                                    "--autocenter"]
                output_filename = os.path.join(output_folder, f"{step}.png")
                run_openscad_render(openscad_options, "cash_exchange_shop.scad", output_filename)


#render_splash_screen()
#render_characters()
#render_character_profiles()
render_cash_exchange_shops()