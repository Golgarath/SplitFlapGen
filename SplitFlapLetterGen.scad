// SplitFlap Generator by Golgarath 2021-06-11 & 2021-06-12
// contributions by ThePseud0o & Smartbert
// Thanks to ProjektionTV & Community

// Model to generate:  
model = "loop"; //[card, letter, all, loop]

//letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ .!?0123456789";
//Letter front side (flap is on top)
letter1 = "A";
//Letter front side (flap is at bottom)
letter2 = "B";

// Font for Letters
font = "Roboto Mono:Bold"; //["Roboto Mono:Bold","Arial Black","Comic Sans MS","Ubuntu Mono"]
//resize factor for letters
//resize factor for letter in X direction
scale_x = 0.7; 
//resize factor for letter in Y direction
scale_y = 0.75;
// Letter Movement on X
move_X = -0.6;
// Letter thickness
letter_thickness = 0.2;
//baseline for Letter
baseline = 10;

// Size of card
//Height of the card in mm
height  = 42.8; 
//Width of the card in mm
width   = 54;
//Thickness of the card in mm
thickness = .6;
 // Corner radius in mm
r = 3;

//coutout width
hinge_width = 2;
// cutout from top
hinge_top = 3; 
// hinge size
hinge = 2; 
//cutout below hinge
hinge_bottom = 5; 

//Distance between flaps
distance = 1; // Smartberts ergänzung


/* [Hidden] */
eps = 0.01;      // epsilon to intersect faces
eps2 = eps * 2;  // epsilon * 2 to intersect faces

//letters for "loop" model
letters = ["9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " ", ".", "!", "?", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A"];
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

module char (char){
    scale([scale_x, scale_y, 1]) 
        linear_extrude(letter_thickness + eps)        
            text(char, size=(height * 2), halign="center", valign="baseline", font=font);
}

module letter(letter1, letter2) {
     intersection(){ //Letter top
        basecard();        
        rotate([180, 0, 0]) 
            translate ([width/2 + move_X, -(height*2) + baseline - distance / 2, -letter_thickness ]) 
                resize([0, 0, letter_thickness+eps] , auto=[false,false,true]) 
                    char (letter1);
    }
    
    intersection(){ //Letter bottom
        basecard();
        translate ([width/2 + move_X, 0 + baseline + distance / 2, thickness-letter_thickness]) 
            resize([0, 0, letter_thickness + eps], auto=[false,false,true]) 
                char (letter2);
    }
}

if (model=="letter") {
    $fn = $preview ? 12 : 72;
    color ("white") letter(letter1, letter2);
}

if (model=="card") {
    $fn = $preview ? 12 : 72;
    color ("gray") card(letter1, letter2);
}

if (model=="all") {
    $fn = $preview ? 12 : 72;
    color ("white") translate ([0, 0, -eps]) scale([1, 1, 1+eps2]) letter(letter1, letter2);
    color ("gray") card(letter1, letter2);
}

if (model == "loop"){
    $fn = $preview ? 24 : 72;
    for (a=[0:lettercount-1]) {
        
        translate([(width+10)*(a%10), (height*2 + 10+distance) * floor(a / 10), -eps]) 
            color ("white") scale([1, 1, 1+eps2]) letter(letters[a], letters[a+1]);
        translate([(width+10)*(a%10), (height*2 + 10+distance) * floor(a / 10), 0]) 
            color ("gray") basecard();//card(letters[a], letters[a+1]);
        
        rotate([180, 0, 0]) translate([(width+10)*(a%10), -height*2-distance - (height*2 + 10+distance) * floor(a / 10), -thickness -eps]) 
            color ("white") scale([1, 1, 1+eps2]) letter(letters[a+1], letters[a+2]);
        rotate([180, 0, 0]) translate([(width+10)*(a%10),-height*2-distance - (height*2 + 10+distance) * floor(a / 10), -thickness]) 
            color ("gray") basecard();//card(letters[a+1], letters[a+2]);
        
    }
}