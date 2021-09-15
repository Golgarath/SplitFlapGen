// Version 1.1.0 2021-09-15
// SplitFlap Generator by Golgarath 2021-06-11 & 2021-06-12
// contributions by ThePseud0o & Smartbert
// Thanks to ProjektionTV & Community

// History: 
// V 1.0.x - Initial Release & Minor Bugfixes
// V 1.1.0 - Letter on front & back can be configuered independent from ech other
//           Twitch Emote "Kappa" added 

/* [Output] */
// Model to generate: "card", "letter", "all" - both, "loop" - overview complete set, "animation"
model = "loop"; //[card, letter, all, loop, animation]
// For the "loop" variant it is important to set the yyyy1 and yyyy2 parameters to equal values.

// letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ .!?0123456789";
// Letter front side (flap is at top)
letter1 = "B";
// Letter back side (flap is at top)
letter2 = "/Grafik/Kappa.svg";

/* [Modifiers Front] */

// Font for Letter
font1 = "Roboto Mono:Bold"; //["Roboto Mono:Bold","Arial Black","Comic Sans MS","Ubuntu Mono"]

// resize factor for letters
// resize factor for letter in X direction
scale_x1 = 0.7; 
// resize factor for letter in Y direction
scale_y1 = 0.75;
// letter shift on x
move_x1 = -0.6;
// letter thickness
letter_thickness1 = 0.3;
// baseline for letter
baseline1 = 10;

/* [Modifiers Back] */

// Font for Letter
font2 = "Roboto Mono:Bold"; //["Roboto Mono:Bold","Arial Black","Comic Sans MS","Ubuntu Mono"]
//resize factor for letters
//resize factor for letter in X direction
scale_x2 = 0.7; 
//resize factor for letter in Y direction
scale_y2 = 0.75;
// letter shift on x
move_x2 = -0.6;
// letter thickness
letter_thickness2 = 0.3;
// baseline for letter
baseline2 = 10;


/* [Base SplitFlap Card] */
// Size of card
// Height of the card in mm
height  = 42.8; 
// Width of the card in mm
width   = 54;
// Thickness of the card in mm
thickness = .9;
// Corner radius in mm
r = 3;

// cutout width
hinge_width = 2;
// cutout from top
hinge_top = 1.59; 
// hinge size
hinge = 1.6; 
// cutout below hinge
hinge_bottom = 14; 

// Distance between flaps
distance = 1; // Smartberts ergänzung

/* [Export Parameter] */
// Flip Card
flip_card = false; //[false, true]

/* [Hidden] */
eps = 0.001;      // epsilon to intersect faces
eps2 = eps * 2;   // epsilon * 2 to intersect faces

//letters for "loop" model
letters = ["9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " ", "_", "#", "/Grafik/Kappa.svg", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A"];
lettercount = 40;

module rcube(size, radius) {
    if(len(radius) == undef) {
        // The same radius on all corners
        rcube(size, [radius, radius, radius, radius]);
    } else if(len(radius) == 2) {
        // Different radii on top and bottom
        rcube(size, [radius[0], radius[0], radius[1], radius[1]]);
    } else if(len(radius) == 4) {
        // Different radius on different corners
        hull() {
            // BL
            if(radius[0] == 0) cube([1, 1, size[2]]);
            else translate([radius[0], radius[0]]) cylinder(r = radius[0], h = size[2]);
            // BR
            if(radius[1] == 0) translate([size[0] - 1, 0]) cube([1, 1, size[2]]);
            else translate([size[0] - radius[1], radius[1]]) cylinder(r = radius[1], h = size[2]);
            // TR
            if(radius[2] == 0) translate([size[0] - 1, size[1] - 1])cube([1, 1, size[2]]);
            else translate([size[0] - radius[2], size[1] - radius[2]]) cylinder(r = radius[2], h = size[2]);
            // TL
            if(radius[3] == 0) translate([0, size[1] - 1]) cube([1, 1, size[2]]);
            else translate([radius[3], size[1] - radius[3]]) cylinder(r = radius[3], h = size[2]);
        }
    } else {
        echo("ERROR: Incorrect length of 'radius' parameter. Expecting integer or vector with length 2 or 4.");
    }
}

module basecard (){
    difference(){
        rcube([width, height, thickness],[r,r,0,0]);
        //TL
        translate([0-eps, height - hinge_top + eps, -eps]) 
            cube([hinge_width + eps2, hinge_top + eps2, thickness + eps2]);
        //BL
        translate([0-eps, height - hinge_top - hinge - hinge_bottom + eps, -eps]) 
            cube([hinge_width + eps2, hinge_bottom + eps2, thickness + eps2]);
        //TR
        translate([width - hinge_width + eps, height - hinge_top + eps, -eps]) 
            cube([hinge_width + eps2, hinge_top + eps2, thickness + eps2]);
        //BR
        translate([width - hinge_width + eps, height - hinge_top - hinge - hinge_bottom + eps, -eps]) 
            cube([hinge_width +eps2, hinge_bottom + eps2, thickness + eps2]);
    }
}

module card(letter1, letter2) {
    difference() {  
        basecard();
        letter(letter1, letter2);        
    }
}

module char (char, scale_x, scale_y, letter_thickness, fontStyle){

    if (len(char) > 3)
    {   
        scale([scale_x, scale_y, 1]) 
            linear_extrude(letter_thickness + eps)        
            translate ([-32 , 0, 0]) 
            resize([65, 0, 0] , auto=[true, true, false]) 
                import (char);
    } 
    else
    {
    scale([scale_x, scale_y, 1]) 
        linear_extrude(letter_thickness + eps)        
        text(char, size=(height * 2), halign="center", valign="baseline", font=fontStyle);
    }
}

module letter(letter1, letter2) {
     intersection(){ //Letter front
        basecard();        
        rotate([180, 0, 0]) 
            translate ([width/2 + move_x1, -(height*2) + baseline1 - distance / 2, -letter_thickness1 ]) 
                resize([0, 0, letter_thickness1+eps] , auto=[false,false,true]) 
                    char (letter1, scale_x1, scale_y1, letter_thickness1, font1);
    }
    
    intersection(){ //Letter back
        basecard();
        translate ([width/2 + move_x2, 0 + baseline2 + distance / 2, thickness-letter_thickness2]) 
            resize([0, 0, letter_thickness2 + eps], auto=[false,false,true]) 
                char (letter2, scale_x2, scale_y2, letter_thickness2, font2);
    }
}

if (model=="letter") {
    $fn = $preview ? 12 : 72;
     
    rotate ([flip_card ? 180 : 0, 0, 0]) color ("white") letter(letter1, letter2);
}

if (model=="card") {
    $fn = $preview ? 12 : 72;
    rotate ([flip_card ? 180 : 0, 0, 0]) color ("gray") card(letter1, letter2);
}

if (model=="all") {
    $fn = $preview ? 12 : 72;
    rotate ([flip_card ? 180 : 0, 0, 0]) color ("white") translate ([0, 0, -eps]) scale([1, 1, 1+eps2]) letter(letter1, letter2);
    rotate ([flip_card ? 180 : 0, 0, 0]) color ("gray") card(letter1, letter2);
}

if (model == "loop"){
    $fn = $preview ? 24 : 72;
    eps = 0.1;
    eps2 = eps * 2;
     
    for (a=[0:lettercount-1]) {
        
        translate([(width+10)*(a%10), (height*2 + 10+distance) * floor(a / 10), -eps]) 
            color ("white") scale([1, 1, 1+eps2]) letter(letters[a], letters[a+1]);
        translate([(width+10)*(a%10), (height*2 + 10+distance) * floor(a / 10), 0]) 
            color ("gray") basecard();
        
        rotate([180, 0, 0]) translate([(width+10)*(a%10), -height*2-distance - (height*2 + 10+distance) * floor(a / 10), -thickness -eps]) 
            color ("white") scale([1, 1, 1+eps2]) letter(letters[a+1], letters[a+2]);
        rotate([180, 0, 0]) translate([(width+10)*(a%10),-height*2-distance - (height*2 + 10+distance) * floor(a / 10), -thickness]) 
            color ("gray") basecard();
        
    }
}

if (model == "animation"){
    animate = "ABCDEFGHIJKLMNOP";
    for(i=[0 : 1 : len(animate) - 1]) {
        angle = $t * 360 - i * (360 / (len(animate)));
        angle2 = min((angle + 360) % 360, 250) - i;
        translate([0, height, 0]) rotate([angle2, 0, 0]) translate([0, -height, 0]) {
            color ("white") translate ([0, 0, -eps]) scale([1, 1, 1+eps2]) letter(animate[i], animate[(i + 1) % len(animate)]);
            color ("gray") card(animate[i], animate[(i + 1) % len(animate)]);
        }
    }
}