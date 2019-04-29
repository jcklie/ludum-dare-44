$fn = 20;

font="Book Antiqua:style=Bold";
font_size = 9;
t = 2;

eye_r = 1;
eye_pupil_r = 0.5;


module character(char, char_color) {
    color(char_color)
        rotate([90,0,0])
            translate([0,0,-t]/2)
                linear_extrude(height=t)
                    text(char, font=font, halign="center");
    pair_of_eyes();
}

module pair_of_eyes() {
    module eye() {
        color("white")
            sphere(r=eye_r);
        translate([eye_r-eye_pupil_r/2,0,0])
            color("black")
                sphere(r=eye_pupil_r);
    }
    
    module eye_position() {
        translate([0.2*font_size, 0.8*t, font_size*0.65])
            children();
    }
    
    mirror(v=[0,1,0])
        eye_position()
            eye();
    eye_position()
        eye();
}

char = "€";
char_color = "red";
character(char, char_color);