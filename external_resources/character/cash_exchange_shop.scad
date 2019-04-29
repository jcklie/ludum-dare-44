font="Book Antiqua:style=Bold";
font_size = 9;
t = 2;

shop_color = "BurlyWood";
exchanging_steps = 16;

a = 10.5;

module cash_exchange_shop(char, char_color, animation, step) {
    module character() {
        color(char_color)
            linear_extrude(height=t)
                text(char, font=font, halign="center");
    }
    module shop() {
        color(shop_color)
            translate([-a/2,0,0])
                cube(a);
    }
    
    shop();
    
    translate([0,0,a])
        if (animation == "Closed") {
            color("white")
                character();
        } else if (animation == "Open") {
            character();
        } else if (animation == "Exchanging") {
            translate([0,0.57*font_size,0])
                rotate([0,0,-step/exchanging_steps * 360])
                    translate([0,-0.57*font_size,0])
                        character();
        }
}


char = "€";
char_color = "purple";
animation = "Exchanging";   // Closed, Exchanging, Open
step = 0;
cash_exchange_shop(char, char_color, animation, step);
