# CreateFromAnalyticFunction
Create database curves or surfaces, even connectors, using a simple analytic function script.

![ScriptImage](https://raw.github.com/pointwise/CreateFromAnalyticFunction/master/TkGUI.png)

## Usage
An analytic surface is created by supplying a Tcl proc named
"computeSurfacePoint" in a separate script file, which must accept either two
or four arguments and return a point in 3-D space (represented
as a list in the form "$x $y $z").

The two argument Tcl proc must accept the numeric arguments U and V. This version of the
Tcl proc is used when your analytic function only requires the surface's uv values.

For example:
```Tcl
proc computeSurfacePoint { u v } {
  # your code here
  return [list $x $y $z]
}
```

The four argument Tcl proc must accept the numeric arguments U and V and the
minUV and maxUV surface limits. This version of the Tcl proc is used when your
analytic function requires the surface's uv values and the full parametric
surface extents.

For example:
```Tcl
proc computeSurfacePoint { u v minUV maxUV } {
  set uMin [expr { 1.0 * [lindex $uvMin 0]}]
  set vMin [expr { 1.0 * [lindex $uvMin 1]}]
  set uMax [expr { 1.0 * [lindex $uvMax 0]}]
  set vMax [expr { 1.0 * [lindex $uvMax 1]}]
  # your code here
  return [list $x $y $z]
}
```

An analytic curve is created by supplying a Tcl proc named
"computeSegmentPoint" in a separate script file, which must accept one
numeric argument (U), and return a point in 3-D space (represented as a
list in the form "$x $y $z").

The two argument Tcl proc must accept the numeric arguments U and V.

For example:
```Tcl
proc computeSegmentPoint { u } {
  # your code here
  return [list $x $y $z]
}
```

The supplied script may include either or both of "computeSurfacePoint" and
"computeSegmentPoint".

![ScriptImage](https://raw.github.com/pointwise/CreateFromAnalyticFunction/master/TorusImage.png)

## Limitations
The ability of this script to construct surfaces containing
discontinuities or sharp edges is limited. It is suggested to use two
functions to define such a surface. If a function that produces
discontinuities or sharp edges must be used, it is suggested that either
the U or V axis be aligned with the discontinuity or edge. As an example,
compare the results of absSphere.glf and absSphereV2.glf, or the results of
of discontinuitySphere.glf and discontinuitySphereV2.glf in the examples
folder.

## Disclaimer
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.
	 

