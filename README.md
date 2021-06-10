# CreateFromAnalyticFunction
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

Create database curves or surfaces, connectors, or even source curves using a simple analytic function script.

![ScriptImage](https://raw.github.com/pointwise/CreateFromAnalyticFunction/master/TkGUI.png)

## Usage

The analytic surfaces and curves are defined by a custom script containing one or more
*well known* callback funtions. These callback funtions are responsible for returning
the xyz point corresponding to the UV values passed to the callback.

* `proc computeSurfacePoint { u v }`
* `proc computeSurfacePoint { u v minUV maxUV }`
* `proc computeSegmentPoint { u }`
* `proc computeSegmentPoint { u minU maxU }`

The supplied script may include either one or both of `computeSurfacePoint` and
`computeSegmentPoint` procs.

### Basic Surface Usage

An analytic surface is created by supplying a Tcl proc named
`computeSurfacePoint` in a separate script file, which must accept either two
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
  set uMin [expr {1.0 * [lindex $uvMin 0]}]
  set vMin [expr {1.0 * [lindex $uvMin 1]}]
  set uMax [expr {1.0 * [lindex $uvMax 0]}]
  set vMax [expr {1.0 * [lindex $uvMax 1]}]
  # your code here
  return [list $x $y $z]
}
```

### Basic Curve Usage

An analytic curve is created by supplying a Tcl proc named
`computeSegmentPoint` in a separate script file, which must accept
one or three arguments and return a point in 3-D space (represented
as a list in the form "$x $y $z").

The one argument Tcl proc must accept the numeric argument U.

For example:
```Tcl
proc computeSegmentPoint { u } {
  # your code here
  return [list $x $y $z]
}
```

The three argument Tcl proc must accept the numeric argument U, and the minU and
maxU surface limits. This version of the Tcl proc is used when your analytic
function requires the curves's u values and the full parametric extents.

For example:
```Tcl
proc computeSegmentPoint { u minU maxU } {
  set uMin [expr {1.0 * $minU}]
  set uMax [expr {1.0 * $maxU}]
  # your code here
  return [list $x $y $z]
}
```

### Advanced Usage

Four additional callbacks are supported that help with implementing more complex surface algorithms.
Any combination (or none) of these callbacks may be used. They are optional.

* `proc beginSurface { uStart vStart uEnd vEnd uNumPoints vNumPoints }`
  * Called once at the beginning of the process.
  * The parameters contain the values set by the user in the dialog box.
* `proc beginSurfaceV { v }`
  * Called each time a new parametric V value is started.
* `proc endSurfaceV { v }`
  * Called after all U values for a parametric V value have been processed.
* `proc endSurface { }`
  * Called once at the end of the process after all UV values have been processed.

In general, the callbacks will be called in the sequence defined by the following
pseudo logic:

```Tcl
beginSurface $uStart $vStart $uEnd $vEnd $uNumPoints $vNumPoints
foreach v $vParams {
  beginSurfaceV $v
  foreach u $uParams {
    if { 2 == $paramCnt } {
      computeSurfacePoint $u $v
    } else {
      computeSurfacePoint $u $v $minUV $maxUV
    }
  }
  endSurfaceV $v
}
endSurface
```


## Example Surface

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
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
