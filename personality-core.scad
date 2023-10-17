function pyth(a=0,b=0,c=0) = sqrt(c == 0 ? (a*a + b*b) : (c*c - a*a - b*b));

D_CORE = 84;

D_CORE_INNER = 81.5;
W_CORE_INNER = 36;

D_PUPIL = 50;

DO_SIDE_RING = 42;
DI_SIDE_RING = 38;
D_SIDE_RING_SPHERE = 85;

DO_FRONT_RING = 53;
DI_FRONT_RING = D_PUPIL;
H_FRONT_RING = 12;
H_FRONT_RING_GAP = 8;
Z_FRONT_RING_TOP = pyth(c=D_CORE/2, a=DI_FRONT_RING/2);

D_LEDGE = 48;
Z_LEDGE = Z_FRONT_RING_TOP - 2;

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

W_CENTER_STRIP = 2.6;
D_CENTER_STRIP = 77;

C_MAIN = "#cccccc";
C_RINGS = "#888888";
C_BROWS = "#222222";


module lamp_cavity() {
  cylinder(d=D_PUPIL, h=D_CORE);
}

module front_ring_cavity() {
  translate([0,0,Z_FRONT_RING_TOP-H_FRONT_RING])cylinder(d=DO_FRONT_RING, h=H_FRONT_RING);
}

module center_strip_cavity() {
  rotate([0,90,0])
  cylinder(h=W_CENTER_STRIP,d=D_CORE+1, center=true);
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
    center_strip_cavity();
  }
}

module center_strip() {
  color(C_BROWS)
    difference()
  {
    rotate([0,90,0]) cylinder(d=D_CENTER_STRIP, h=W_CENTER_STRIP, center=true);
    lamp_cavity();
    front_ring_cavity();
  }
}

module side_rings() {
  w_rings = pyth(c=D_CORE, a=DO_SIDE_RING);
  color(C_RINGS)
  rotate([0,90,0])
  difference(){
    cylinder(d=DO_SIDE_RING, h=D_SIDE_RING_SPHERE, center=true);
    cylinder(d=DI_SIDE_RING, h=D_SIDE_RING_SPHERE, center=true);
    difference(){
      cube(D_SIDE_RING_SPHERE+1,center=true);
      sphere(d=D_SIDE_RING_SPHERE);
    }
    cube([D_SIDE_RING_SPHERE,D_SIDE_RING_SPHERE,w_rings-4],center=true);
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

center_strip();
body_outer();
body_inner();

side_rings();
front_ring();

