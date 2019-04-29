font="Book Antiqua:style=Bold";
font_size = 9;
t = 2;

eye_r = 1;
eye_pupil_r = 0.5;
eyebrow_xz = 0.5;
eyebrow_y = 2;
eyebrow_angle = 20;


module character(char, char_color, angry) {
    color(char_color)
        rotate([90,0,0])
            translate([0,0,-t]/2)
                linear_extrude(height=t)
                    text(char, font=font, halign="center");
    pair_of_eyes(angry);
}

module pair_of_eyes(angry = false) {
    module angry_eyebrow() {
        color("black")
            translate([0,0.25*eye_r,1.5*eye_r])
                rotate([eyebrow_angle,0,0])
                    cube([eyebrow_xz, eyebrow_y, eyebrow_xz], center=true);
    }
    
    module eye() {
        color("white")
            sphere(r=eye_r);
        translate([eye_r-eye_pupil_r/2,0,0])
            color("black")
                sphere(r=eye_pupil_r);
        if (angry) {
            angry_eyebrow();
        }
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
character(char, char_color, angry=true);