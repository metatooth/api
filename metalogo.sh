#!/bin/bash

pi=`echo "4*a(1)" | bc -l`
rad=`echo "60*($pi/180)" | bc -l`

if [ $# -ne 3 ]
then
    echo "usage: metalogo.sh <radius> <ratio> <theta>"
    echo
    echo "  Outputs a SVG of width & height twice <radius>. Draw a circle "
    echo "  of <radius>. Inset a triangle inscribed within a"
    echo "  circle of <radius>*<ratio>. Then rotate the triangle by <theta>."
    echo
    echo "  for example, metalogo.sh 256 0.8 15"
    exit
fi

radius=$1
ratio=$2
theta=$3

center_x=$radius
center_y=$radius

R=`echo "$radius * $ratio" | bc -l`

delta_y=`echo "$radius - $R" | bc -l`

tan_sixty=`echo "s($rad)/c($rad)" | bc -l`
tan_thirty=`echo "s($rad/2)/c($rad/2)" | bc -l`
sine_thirty=`echo "s($rad/2)" | bc -l`

sine_theta=`echo "s($theta*($pi/180))" | bc -l`
cosine_theta=`echo "c($theta*($pi/180))" | bc -l`

# Calculate big triangle from R

X=`echo "$R * $sine_thirty" | bc -l`
B=`echo "$X / $tan_thirty" | bc -l`
H=`echo "$B * $tan_sixty" | bc -l`

# Small triangle is 1/4 height of big triangle

h=`echo "$H / 4" | bc -l`

b=`echo "$h / $tan_sixty" | bc -l`
x=`echo "$b * $tan_thirty" | bc -l`
r=`echo "$x / $sine_thirty" | bc -l`

ax=`echo "$center_x" | bc -l`
ay=`echo "$delta_y" | bc -l`

bx=`echo "$center_x - $b" | bc -l`
by=`echo "$h + $delta_y" | bc -l`

cx=`echo "$center_x + $b" | bc -l`
cy=`echo "$h + $delta_y" | bc -l`

dx=`echo "$center_x - (2 * $b)" | bc -l`
dy=`echo "2 * $h + $delta_y" | bc -l`

ex=`echo "$center_x" | bc -l`
ey=`echo "2 * $h + $delta_y" | bc -l`

fx=`echo "$center_x + (2 * $b)" | bc -l`
fy=`echo "2 * $h + $delta_y" | bc -l`

gx=`echo "$center_x - (3 * $b)" | bc -l`
gy=`echo "3 * $h + $delta_y" | bc -l`

hx=`echo "$center_x - $b" | bc -l`
hy=`echo "3 * $h + $delta_y" | bc -l`

ix=`echo "$center_x + $b" | bc -l`
iy=`echo "3 * $h + $delta_y" | bc -l`

jx=`echo "$center_x + (3 * $b)" | bc -l`
jy=`echo "3 * $h + $delta_y" | bc -l`

kx=`echo "$center_x - (4 * $b)" | bc -l`
ky=`echo "4 * $h + $delta_y" | bc -l`

lx=`echo "$center_x - (2 * $b)" | bc -l`
ly=`echo "4 * $h + $delta_y" | bc -l`

mx=`echo "$center_x" | bc -l`
my=`echo "4 * $h + $delta_y" | bc -l`

nx=`echo "$center_x + (2 * $b)" | bc -l`
ny=`echo "4 * $h + $delta_y" | bc -l`

ox=`echo "$center_x + (4 * $b)" | bc -l`
oy=`echo "4 * $h + $delta_y" | bc -l`

height=`echo "2*$radius" | bc -l`
width=`echo "2*$radius" | bc -l`

cat << EOF
<svg height="$height" width="$width">
  <!--
  pi is $pi
  60 deg. is $rad radians
  tan 60 is $tan_sixty
  tan 30 is $tan_thirty
  sine 30 is $sine_thirty
  
  Radius is $radius

  R is $R
  X is $X
  B is $B
  H is $H

  h is $h
  x is $x
  b is $b
  r is $r

  -->
  <circle r="$radius" cx="$center_x" cy="$center_y" fill="black"/>
  <polygon points="$ax,$ay $ox,$oy $kx,$ky" fill="white"/>
  <polygon points="$dx,$dy $fx,$fy $mx,$my" fill="black"/>
  <polygon points="$bx,$by $cx,$cy $ex,$ey" fill="black"/>
  <polygon points="$gx,$gy $hx,$hy $lx,$ly" fill="black"/>
  <polygon points="$ix,$iy $jx,$jy $nx,$ny" fill="black"/>
  <polygon points="$hx,$hy $ix,$iy $ex,$ey" fill="white"/>
</svg>
EOF
