function pyth(a=0,b=0,c=0) = sqrt(c == 0 ? (a*a + b*b) : (c*c - a*a - b*b));

D_MAX = 100;

D_CORE = 84;

D_CORE_INNER = 81.5;
W_CORE_INNER = 36;

D_PUPIL = 50;

DO_SIDE_RING = 42;
DI_SIDE_RING = 38;
D_SIDE_RING_SPHERE = 85;
DEPTH_SIDE_RING = 3;
X_SIDE_RING = pyth(c=D_CORE/2, a=DO_SIDE_RING/2) - DEPTH_SIDE_RING;

DO_FRONT_RING = 53;
DI_FRONT_RING = D_PUPIL;
H_FRONT_RING = 12;
H_FRONT_RING_GAP = 8;
Z_FRONT_RING_TOP = pyth(c=D_CORE/2, a=DI_FRONT_RING/2);

D_LEDGE = 48;
Z_LEDGE = Z_FRONT_RING_TOP - 5;

W_RING_GAP = 2.5;

D_BROWS_SMALL = 2.5;
D_BROWS_BIG = 3.5;
W_BROWS = 66;
Y_BROWS = 42;
Y_BROW_ANCHOR = 26;
Z_BROW_ANCHOR = 17;
A_BROW = 30;
L_BROW_ANCHOR = 18;
D_BROW_ANCHOR = 7.5;

W_CENTER_RING = 2.6;
D_CENTER_RING = 77;

W_TOP_BOTTOM_STRIP = 10;
Z_TOP_BOTTOM_STRIP_TOP = 26;
Z_TOP_BOTTOM_STRIP_BOTTOM = -17;
DEPTH_TOP_BOTTOM_STRIP = 15;
DO_TOP_BOTTOM_STRIP = D_CORE_INNER-2;
DI_TOP_BOTTOM_STRIP = D_CENTER_RING + 1;

C_MAIN = "#cccccc";
C_RINGS = "#888888";
C_BROWS = "#222222";

module intersection() {
  difference(){
    children(0);
    difference(){
      cube(D_MAX, center=true);
      children(1);
    }
  }
}

module lamp_cavity() {
  cylinder(d=D_PUPIL, h=D_CORE);
}

module front_ring_cavity() {
  translate([0,0,Z_FRONT_RING_TOP-H_FRONT_RING])cylinder(d=DO_FRONT_RING, h=H_FRONT_RING);
}

module side_rings_cavity() {
  rotate([0,90,0])
    difference()
  {
    cylinder(d=DO_SIDE_RING, h=D_SIDE_RING_SPHERE, center=true);
    cylinder(d=DI_SIDE_RING, h=D_MAX, center=true);
    cylinder(d=D_MAX, h=2* X_SIDE_RING,center=true);
  }
}

module center_ring_cavity() {
  rotate([0,90,0])
  cylinder(h=W_CENTER_RING,d=D_CORE+1, center=true);
}

module top_bottom_strip_cavity() {
  h_strip = Z_TOP_BOTTOM_STRIP_TOP - Z_TOP_BOTTOM_STRIP_BOTTOM;
  for(sy = [-1,1]){
    scale([1,sy,1])
      translate([-W_TOP_BOTTOM_STRIP/2 ,D_CORE/2-DEPTH_TOP_BOTTOM_STRIP,Z_TOP_BOTTOM_STRIP_BOTTOM])
      cube([W_TOP_BOTTOM_STRIP, DEPTH_TOP_BOTTOM_STRIP, h_strip]);
  }
}

module body_outer(){
  r_chamfer_inner = pyth(c=D_CORE_INNER/2, a=W_CORE_INNER/2);
  color(C_MAIN)
  difference(){
    sphere(d=D_CORE);
    rotate([0,90,0]) difference(){
      cylinder(d=D_CORE+1, h=W_CORE_INNER+8, center=true);
      translate([0,0,W_CORE_INNER/2])cylinder(r1=r_chamfer_inner, r2=r_chamfer_inner+5, h=8);
      translate([0,0,-W_CORE_INNER/2-8])cylinder(r1=r_chamfer_inner+5, r2=r_chamfer_inner, h=8);
    }
    lamp_cavity();
    front_ring_cavity();
    side_rings_cavity();
  }
}

module body_inner() {
  color(C_MAIN)
  difference(){
    sphere(d=D_CORE_INNER);
    translate([D_CORE/2+W_CORE_INNER/2,0,0])cube(D_CORE,center=true);
    translate([-D_CORE/2-W_CORE_INNER/2,0,0])cube(D_CORE,center=true);
    lamp_cavity();
    front_ring_cavity();
    center_ring_cavity();
    top_bottom_strip_cavity();
  }
}

module center_ring() {
  color(C_BROWS)
    difference()
  {
    rotate([0,90,0]) cylinder(d=D_CENTER_RING, h=W_CENTER_RING, center=true);
    lamp_cavity();
    front_ring_cavity();
  }
}

module top_bottom_strip() {
  color(C_RINGS)
    intersection()
  {
    for(ry = [90,-90]){
      rotate([0,ry,0])
        translate([0,0,W_CENTER_RING/2])
        cylinder(r1=DI_TOP_BOTTOM_STRIP/2, r2=DO_TOP_BOTTOM_STRIP/2, h=(W_TOP_BOTTOM_STRIP-W_CENTER_RING)/2);
    }
    top_bottom_strip_cavity();
  }
}


module side_rings() {
  color(C_RINGS)
  rotate([0,90,0])
  difference(){
    cylinder(d=DO_SIDE_RING, h=D_SIDE_RING_SPHERE, center=true);
    cylinder(d=DI_SIDE_RING, h=D_SIDE_RING_SPHERE, center=true);
    difference(){
      cube(D_SIDE_RING_SPHERE+1,center=true);
      sphere(d=D_SIDE_RING_SPHERE);
    }
    cube([D_SIDE_RING_SPHERE,D_SIDE_RING_SPHERE,X_SIDE_RING*2],center=true);
  }
}

module front_ring() {
  d_center = (DO_FRONT_RING + DI_FRONT_RING) / 2;
  w_ring = (DO_FRONT_RING - DI_FRONT_RING) / 2;

  w_socket = (d_center - D_LEDGE)/2;
  h_socket = Z_LEDGE - Z_FRONT_RING_TOP + H_FRONT_RING;

  color(C_RINGS) 
    translate([0,0,Z_FRONT_RING_TOP])
    difference()
  {
    rotate_extrude() {
      translate([d_center/2,0]){
        circle(d=w_ring); 
        translate([0,-H_FRONT_RING/2])square([w_ring, H_FRONT_RING], center=true);
      }
      translate([D_LEDGE/2,-H_FRONT_RING]) square([w_socket, h_socket]);
    }
    cube([D_CORE, W_RING_GAP, 2 * H_FRONT_RING_GAP], center=true);
    cube([W_RING_GAP, D_CORE, 2 * H_FRONT_RING_GAP], center=true);
  }
}

module eyebrow() {
  r=70;
  a=42;
  a_big=30;
  x_overlap = sin(a/2) * D_BROWS_SMALL/2;
  x_end = sin(a/2) * r;
  y_end = cos(a/2) * r;
  module anchor() {
    rotate([0,-90,0])linear_extrude(2,center=true) hull(){
      circle(d=D_BROW_ANCHOR);
      translate([(D_BROW_ANCHOR-D_BROWS_BIG)/2,L_BROW_ANCHOR]) circle(d=D_BROWS_BIG);
    }
  }

  translate([0,Y_BROW_ANCHOR,Z_BROW_ANCHOR])
    color(C_BROWS)
    rotate([A_BROW,0,0])
  {
    translate([W_BROWS/2,0])anchor();
    translate([-W_BROWS/2,0])anchor();
    translate([0,L_BROW_ANCHOR-y_end,(D_BROW_ANCHOR-D_BROWS_BIG)/2]){
      translate([x_end-x_overlap,y_end])rotate([0,90,0])cylinder(d=D_BROWS_SMALL,h=W_BROWS/2-x_end+x_overlap);
      translate([-x_end+x_overlap,y_end])rotate([0,-90,0])cylinder(d=D_BROWS_SMALL,h=W_BROWS/2-x_end+x_overlap);
      rotate([0,0,90-a/2])rotate_extrude(angle=a) {
        translate([r,0]) circle(d=D_BROWS_SMALL);
      }
      rotate([0,0,90-a_big/2])rotate_extrude(angle=a_big) {
        translate([r,0]) circle(d=D_BROWS_BIG);
      }
    }
  }
}

eyebrow();
scale([1,-1,1])eyebrow();

$fn=120;

center_ring();
body_outer();
body_inner();

side_rings();
front_ring();
top_bottom_strip();

