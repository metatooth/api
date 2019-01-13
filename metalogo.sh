#!/bin/bash

pi=`echo "4*a(1)" | bc -l`
rad=`echo "60*($pi/180)" | bc -l`

if [ $# -ne 1 ]
then
    echo "usage: metalogo.sh <radius>"
    exit
fi

R=$1

tan_sixty=`echo "s($rad)/c($rad)" | bc -l`
tan_thirty=`echo "s($rad/2)/c($rad/2)" | bc -l`
sine_thirty=`echo "s($rad/2)" | bc -l`

# Calculate big triangle from R

X=`echo "$R * $sine_thirty" | bc -l`
B=`echo "$X / $tan_thirty" | bc -l`
H=`echo "$B * $tan_sixty" | bc -l`


# Small triangle is 1/4 height of big triangle

h=`echo "$H / 4" | bc -l`

b=`echo "$h / $tan_sixty" | bc -l`
x=`echo "$b * $tan_thirty" | bc -l`
r=`echo "$x / $sine_thirty" | bc -l`

ax=`echo "$R" | bc -l`
ay=0

bx=`echo "$R - $b" | bc -l`
by=`echo "$h" | bc -l`

cx=`echo "$R + $b" | bc -l`
cy=`echo "$h" | bc -l`

dx=`echo "$R - (2 * $b)" | bc -l`
dy=`echo "2 * $h" | bc -l`

ex=`echo "$R" | bc -l`
ey=`echo "2 * $h" | bc -l`

fx=`echo "$R + (2 * $b)" | bc -l`
fy=`echo "2 * $h" | bc -l`

gx=`echo "$R - (3 * $b)" | bc -l`
gy=`echo "3 * $h" | bc -l`

hx=`echo "$R - $b" | bc -l`
hy=`echo "3 * $h" | bc -l`

ix=`echo "$R + $b" | bc -l`
iy=`echo "3 * $h" | bc -l`

jx=`echo "$R + (3 * $b)" | bc -l`
jy=`echo "3 * $h" | bc -l`

kx=`echo "$R - (4 * $b)" | bc -l`
ky=`echo "4 * $h" | bc -l`

lx=`echo "$R - (2 * $b)" | bc -l`
ly=`echo "4 * $h" | bc -l`

mx=`echo "$R" | bc -l`
my=`echo "4 * $h" | bc -l`

nx=`echo "$R + (2 * $b)" | bc -l`
ny=`echo "4 * $h" | bc -l`

ox=`echo "$R + (4 * $b)" | bc -l`
oy=`echo "4 * $h" | bc -l`

height=`echo "2*$R" | bc -l`
width=`echo "2*$R" | bc -l`

cat << EOF
<svg height="$height" width="$width">
  <!--
  pi is $pi
  60 deg. is $rad radians
  tan 60 is $tan_sixty
  tan 30 is $tan_thirty
  sine 30 is $sine_thirty
  
  Radius is $R

  X is $X
  B is $B
  H is $H

  h is $h
  x is $x
  b is $b
  r is $r

  -->
  <circle r="$R" cx="$R" cy="$R" fill="black"/>
  <polygon points="$ax,$ay $ox,$oy $kx,$ky" fill="white"/>
  <polygon points="$dx,$dy $fx,$fy $mx,$my" fill="black"/>
  <polygon points="$bx,$by $cx,$cy $ex,$ey" fill="black"/>
  <polygon points="$gx,$gy $hx,$hy $lx,$ly" fill="black"/>
  <polygon points="$ix,$iy $jx,$jy $nx,$ny" fill="black"/>
  <polygon points="$hx,$hy $ix,$iy $ex,$ey" fill="white"/>
</svg>
EOF
