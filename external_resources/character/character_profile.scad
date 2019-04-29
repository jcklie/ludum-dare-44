use <character.scad>

$fn=100;

pedestal_color = [0.8, 0.8, 0.8];

module eur_scene() {
    color(pedestal_color)
        cube([8,8,8], center=true);
    translate([0,0,5])
        rotate([10,5,0])
            character("€", [0.269, 0.347, 0.953], true);
}

module usd_scene() {
    color(pedestal_color)
        cube([8,8,8], center=true);
    translate([0,0,15])
        rotate([170,-5,-10])
            character("$", [0, 1.0, 0]);
}

module gbp_scene() {
    color(pedestal_color)
        cube([8,8,8], center=true);
    translate([0,0,4])
        rotate([0,10,0])
            character("£", [1.0, 0.65, 0], true);
}

module yen_scene() {
    color(pedestal_color)
        cube([8,8,8], center=true);
    translate([0,2,4])
        rotate([25,-10,0])
            character("¥", [0.7, 0.3, 0.95]);
}

scene = "yen";

// euro:
// camera translate: [3.32, 0.74, 4.9]
// camera rotate: [113.80, 0, 58.6]
// distance: 54.24
if (scene == "eur") {
    eur_scene();
}

// usd:
// camera translate: [2.39, -0.46, 5.62]
// camera rotate: [102.60, 0, 49.50]
// distance: 60.27
if (scene == "usd") {
    usd_scene();
}

// gbp:
// camera translate: [2.64, 3.31, 7.28]
// camera rotate: [112.4, 0, 52.3]
// distance: 43.93
if (scene == "gbp") {
    gbp_scene();
}

// yen:
// camera translate: [0.63,1.26,4.97]
// camera rotate: [84.4,0,50.2]
// distance: 54.24
if (scene == "yen") {
    yen_scene();
}