use <character.scad>

pedestal_color = [0.8, 0.8, 0.8];

module splash_scene() {
    translate([-6,0,1])
        rotate([0,5,150])
            character("¥", [0.63, 0.14, 0.94]);
    translate([-4,10,0])
        rotate([4,0,160])
            character("£", [1.0, 0.65, 0], angry=true);
    translate([-2,20,0])
        rotate([-2,-4,160])
            character("$", [0, 1.0, 0]);
    translate([0,30,0])
        rotate([0,10,180])
            character("€", [0.269, 0.347, 0.953]);
            
}

$fn=100;

// camera translate: [1.28, 4.64, 4.39]
// camera rotate: [92.10, 0, 209.30]
// distance: 60.27
splash_scene();