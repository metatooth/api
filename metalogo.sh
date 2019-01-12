#!/bin/bash

pi=`echo "4*a(1)" | bc -l`
rad=`echo "60*($pi/180)" | bc -l`

if [ $# -ne 2 ]
then
    echo "usage: metalogo.sh <radius> <height>"
    exit
fi

R=$1
H=$2

function tan()
{
    echo "scale=5;s($1)/c($1)" | bc -l
}

tan_sixty=`echo "s($rad)/c($rad)" | bc -l`
twice_tan_sixty=`echo "2*$tan_sixty" | bc -l`

b=`echo "$H/$twice_tan_sixty" | bc -l`
x=`echo "$b*s($rad/2)" | bc -l`
delta=`echo "($H/2)-$x" | bc -l`

ax=`echo "$R" | bc -l`
ay=`echo "$R-($H/2)-$delta" | bc -l`

bx=`echo "$R-($b/2)" | bc -l`
by=`echo "$R-($H/4)-$delta" | bc -l`

cx=`echo "$R+($b/2)" | bc -l`
cy=`echo "$R-($H/4)-$delta" | bc -l`

dx=`echo "$R-$b" | bc -l`
dy=`echo "$R-$delta" | bc -l`

ex=`echo "$R" | bc -l`
ey=`echo "$R-$delta" | bc -l`

fx=`echo "$R+$b" | bc -l`
fy=`echo "$R-$delta" | bc -l`

gx=`echo "$R-(3*($b/2))" | bc -l`
gy=`echo "$R+($H/4)-$delta" | bc -l`

hx=`echo "$R-($b/2)" | bc -l`
hy=`echo "$R+($H/4)-$delta" | bc -l`

ix=`echo "$R+($b/2)" | bc -l`
iy=`echo "$R+($H/4)-$delta" | bc -l`

jx=`echo "$R+(3*($b/2))" | bc -l`
jy=`echo "$R+($H/4)-$delta" | bc -l`

kx=`echo "$R-(2*$b)" | bc -l`
ky=`echo "$R+($H/2)-$delta" | bc -l`

lx=`echo "$R-$b" | bc -l`
ly=`echo "$R+($H/2)-$delta" | bc -l`

mx=`echo "$R" | bc -l`
my=`echo "$R+($H/2)-$delta" | bc -l`

nx=`echo "$R+$b" | bc -l`
ny=`echo "$R+($H/2)-$delta" | bc -l`

ox=`echo "$R+(2*$b)" | bc -l`
oy=`echo "$R+($H/2)-$delta" | bc -l`

height=`echo "2*$R" | bc -l`
width=`echo "2*$R" | bc -l`

cat << EOF
<svg height="$height" width="$width">
  <circle r="$R" cx="$R" cy="$R" fill="black"/>
  <polygon points="$ax,$ay $ox,$oy $kx,$ky" fill="white"/>
  <polygon points="$dx,$dy $fx,$fy $mx,$my" fill="black"/>
  <polygon points="$bx,$by $cx,$cy $ex,$ey" fill="black"/>
  <polygon points="$gx,$gy $hx,$hy $lx,$ly" fill="black"/>
  <polygon points="$ix,$iy $jx,$jy $nx,$ny" fill="black"/>
  <polygon points="$hx,$hy $ix,$iy $ex,$ey" fill="white"/>
</svg>
EOF
