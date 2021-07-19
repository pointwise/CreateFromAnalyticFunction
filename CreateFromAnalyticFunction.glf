#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

################################################################################
# Create database curves or surfaces (or grid connectors) using a simple
# analytic function script. Example functions are provided in the examples
# folder.
#
# An analytic surface is created by supplying a Tcl proc named
# "computeSurfacePoint" in a separate script file, which must accept two
# numeric arguments (U, V), and return a point in 3-D space (represented
# as a list in the form "$x $y $z").
#
# An analytic curve is created by supplying a Tcl proc named
# "computeSegmentPoint" in a separate script file, which must accept one
# numeric argument (U), and return a point in 3-D space (represented as a
# list in the form "$x $y $z").
#
# The supplied script may include either or both of "computeSurfacePoint" and
# "computeSegmentPoint".
#
# LIMITATIONS: The ability of this script to construct surfaces containing
# discontinuities or sharp edges is limited. It is suggested to use two
# functions to define such a surface. If a function that produces
# discontinuities or sharp edges must be used, it is suggested that either
# the U or V axis be aligned with the discontinuity or edge. As an example,
# compare the results of absSphere.glf and absSphereV2.glf, or the results of
# of discontinuitySphere.glf and discontinuitySphereV2.glf in the examples
# folder.
################################################################################

package require PWI_Glyph 2

## analytic functions

pw::Script loadTk

# initialize globals

set infoMessage ""

set color(Valid) "white"
set color(Invalid) "misty rose"

set userInfoFile [file join [file dirname [info script]] "defaults.ini"]

set control(SegmentType) "database"
set control(EntityType) "Segment"

set segment(Start) 0.0
set segment(End) 1.0
set segment(NumPoints) 10
set segment(Type) "CatmullRom"

set surface(Start) "0.0 0.0"
set surface(End) "1.0 1.0"
set surface(NumPoints) "10 10"
set surface(Spline) "1"

proc readDefaults { } {
  global userInfoFile control segment surface

  if { [catch { set fp [open $userInfoFile r] } msg] } {
    set control(File) ""
  } else {
    set file_data [read $fp]
    close $fp
    foreach iniValue [split $file_data "\n"] {
      set nvpair [split $iniValue "="]
      if { [llength $nvpair] == 2 } {
        set [lindex $nvpair 0] [lindex $nvpair 1]
      }
    }
  }
}

proc writeDefaults { } {
  global userInfoFile control segment surface
  if { [file exists $control(File)] } {
    file delete -force $userInfoFile
  }

  if { ! [catch { set fp [open $userInfoFile w] }] } {
    foreach n [array names control] {
      puts $fp "control($n)=$control($n)"
    }
    foreach n [array names segment] {
      puts $fp "segment($n)=$segment($n)"
    }
    foreach n [array names surface] {
      puts $fp "surface($n)=$surface($n)"
    }
    close $fp
  }
}

# widget hierarchy
set w(LabelTitle)             .title
set w(FrameMain)              .main
  set w(LabelFile)              $w(FrameMain).lfile
  set w(EntryFile)              $w(FrameMain).efile
  set w(ButtonFile)             $w(FrameMain).bfile
  set w(LabelEntityType)        $w(FrameMain).lenttype
  set w(ComboEntityType)        $w(FrameMain).comenttype
  set w(FrameSegment)           $w(FrameMain).fsegment
    set w(FrameSegmentType)        $w(FrameSegment).fsegtype
      set w(RadioDatabase)          $w(FrameSegmentType).rdatabase
      set w(RadioGrid)              $w(FrameSegmentType).rgrid
      set w(RadioSource)            $w(FrameSegmentType).rsource
    set w(LabelStart)             $w(FrameSegment).lstart
    set w(EntryStart)             $w(FrameSegment).estart
    set w(LabelEnd)               $w(FrameSegment).lend
    set w(EntryEnd)               $w(FrameSegment).eend
    set w(LabelNumPoints)         $w(FrameSegment).lnumpoints
    set w(EntryNumPoints)         $w(FrameSegment).enumpoints
    set w(FrameType)              $w(FrameSegment).ftype
      set w(RadioCatmullRom)        $w(FrameType).rcatmullrom
      set w(RadioAkima)             $w(FrameType).rakima
      set w(RadioLinear)            $w(FrameType).rlinear
  set w(FrameSurface)           $w(FrameMain).fsurface
    set w(LabelStartUV)           $w(FrameSurface).lstartuv
    set w(EntryStartUV)           $w(FrameSurface).estartuv
    set w(LabelEndUV)             $w(FrameSurface).lenduv
    set w(EntryEndUV)             $w(FrameSurface).eenduv
    set w(LabelNumPointsUV)       $w(FrameSurface).lnumpointsuv
    set w(EntryNumPointsUV)       $w(FrameSurface).enumpointsuv
    set w(CheckSplineUV)          $w(FrameSurface).csplineuv
set w(FrameButtons)           .buttons
  set w(Logo)                   $w(FrameButtons).logo
  set w(ButtonOk)               $w(FrameButtons).bok
  set w(ButtonCancel)           $w(FrameButtons).bcancel
set w(Message)                .msg

# creates a segment using $control(File)'s 'computePoint' function
proc createSegment { start end step {fmt simple} {const 0} } {
  global control

  set segment [pw::SegmentSpline create]
  set numArgs [llength [info args computeSegmentPoint]]
  for { set u $start } { $u <= $end+($step/2.0) } { set u [expr $u + $step] } {
    if { $u > $end } {
      set u $end
    }
    switch $numArgs {
    1 {
      $segment addPoint [computeSegmentPoint $u] }
    3 {
      $segment addPoint [computeSegmentPoint $u $start $end] }
    default {
      error {Illegal number of args to computeSegmentPoint} }
    }
  }

  $segment setSlope $::segment(Type)
  return $segment
}

# creates a connector (createSegment is a helper)
proc createConnector { start end stepSize } {
  set segment [createSegment $start $end $stepSize ]
  set con [pw::Connector create]
  $con addSegment $segment
  $con calculateDimension
}

# creates a curve (createSegment is a helper)
proc createCurve { start end stepSize {fmt simple} {const 0} } {
  set segment [createSegment $start $end $stepSize $fmt $const]
  set curve [pw::Curve create]
  $curve addSegment $segment
  return $curve
}

# creates a source (createSegment is a helper)
proc createSourceCurve { start end stepSize {fmt simple} {const 0} } {
  set segment [createSegment $start $end $stepSize $fmt $const]
  set srcCurve [pw::SourceCurve create]
  $srcCurve addSegment $segment
  return $srcCurve
}

proc procExists { procName } {
  return [expr {"$procName" eq [info procs $procName]}]
}

proc callOptionalProc { procName args } {
  if { [procExists $procName] } {
    $procName {*}$args
  }
}

proc callBeginSurface { uStart vStart uEnd vEnd uNumPoints vNumPoints } {
  callOptionalProc beginSurface $uStart $vStart $uEnd $vEnd $uNumPoints $vNumPoints
}

proc callBeginSurfaceV { v } {
  callOptionalProc beginSurfaceV $v
}

proc callEndSurfaceV { v } {
  callOptionalProc endSurfaceV $v
}

proc callEndSurface { } {
  callOptionalProc endSurface
}

# creates a database surface by saving a plot3D file and loading it
proc createNetworkSurface { start end numPoints } {
  global control surface

  # setting useful local variales
  set uStart [expr { 1.0 * [lindex $start 0]}]
  set vStart [expr { 1.0 * [lindex $start 1]}]
  set uEnd [expr { 1.0 * [lindex $end 0]}]
  set vEnd [expr { 1.0 * [lindex $end 1]}]
  set uNumPoints [lindex $numPoints 0]
  set vNumPoints [lindex $numPoints 1]
  set uStep [expr { ($uEnd - $uStart) / $uNumPoints }]
  set vStep [expr { ($vEnd - $vStart) / $vNumPoints }]
  set numArgs [llength [info args computeSurfacePoint]]

  callBeginSurface $uStart $vStart $uEnd $vEnd $uNumPoints $vNumPoints
  # storing the surface's control points
  for { set j 0 } { $j <= $vNumPoints } { incr j } {
    set v [expr { $vStart + $j * $vStep }]
    callBeginSurfaceV $v
    for { set i 0 } { $i <= $uNumPoints } { incr i } {
      set u [expr { $uStart + $i * $uStep }]
      switch $numArgs {
      2 {
        set point($i,$j) [computeSurfacePoint $u $v] }
      4 {
        set point($i,$j) [computeSurfacePoint $u $v $start $end] }
      default {
        error {Illegal number of args to computeSurfacePoint} }
      }
    }
    callEndSurfaceV $v
  }
  callEndSurface

  # create and start the file
  set netPath [file join [file dirname [info script]] \
              "analyticFunctionsNetwork.x"]
  if { [file exists $netPath] } {
    file delete -force netPath
  }
  set fp [open $netPath w]
  puts $fp 1
  puts $fp "[expr {$uNumPoints+1}] [expr {$vNumPoints+1}] 1"

  # saving the control points
  for { set dim 0 } { $dim < 3 } { incr dim } {
    for { set j 0 } { $j <= $vNumPoints } { incr j } {
      for { set i 0 } { $i <= $uNumPoints } { incr i } {
        puts $fp " [lindex $point($i,$j) $dim] "
      }
    }
    puts $fp ""
  }
  close $fp

  # import the file
  set entities [pw::Database import -type PLOT3D $netPath]

  # spline the result (if requested)
  if { $surface(Spline) } {
    foreach entity $entities {
      $entity spline
    }
  }

  file delete $netPath
}

# updates the button state (will be disabled when entries are not valid inputs
# with which to make a segment or surface)
proc updateButtons { } {
  global w color control surface infoMessage

  # check that either a surface or segment can be created
  if { $control(EntityType) == "N/A" } {
    $w(ButtonOk) configure -state disabled
    set infoMessage "Select a script that contains a Tcl proc named\
        computeSegmentPoint or computeSurfacePoint."
    return
  }

  # check that the entries the user has input are valid
  set canCreate 1
  if { $control(EntityType) eq "Segment" } {
    set infoMessage "Press OK to create the curve"
    if { ! [string equal -nocase [$w(EntryStart) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter a valid starting U parameter value"
      set canCreate 0
    }
    if { ! [string equal -nocase [$w(EntryEnd) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter a valid ending U parameter value"
      set canCreate 0
    }
    if { ! [string equal -nocase [$w(EntryNumPoints) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter a valid number of control points"
      set canCreate 0
    }
  } else {
    set infoMessage "Press OK to create the surface"
    if { ! [string equal -nocase [$w(EntryStartUV) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter valid starting U V parameter values"
      set canCreate 0
    }
    if { ! [string equal -nocase [$w(EntryEndUV) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter valid ending U V parameter values"
      set canCreate 0
    }
    if { ! [string equal -nocase [$w(EntryNumPointsUV) cget -background] \
                          $color(Valid)] } {
      set infoMessage "Enter a valid number of U V control points"
      set canCreate 0
    }
  }

  if { $canCreate } {
    $w(ButtonOk) configure -state normal
  } else {
    $w(ButtonOk) configure -state disabled
  }
}

# validation functions; check if input matches some condition, sets widget color
# to $color(Invalid) if not, and calls 'updateButtons'

# checks that $u is a positive non-zero int
proc validateInt { u widget } {
  global w color
  if { [llength $u] != 1
        || ! [string is int -strict $u]
        || $u <= 0 } {
    $w($widget) configure -background $color(Invalid)
  } else {
    $w($widget) configure -background $color(Valid)
  }
  updateButtons
  return 1
}

# checks that $uv is a pair of positive non-zero ints
proc validateIntPair { uv widget } {
  global w color
  if { [llength $uv] != 2
        || ! [string is int -strict [lindex $uv 0]]
        || ! [string is int -strict [lindex $uv 1]]
        || [lindex $uv 0] <= 0
        || [lindex $uv 1] <= 0 } {
    $w($widget) configure -background $color(Invalid)
  } else {
    $w($widget) configure -background $color(Valid)
  }
  updateButtons
  return 1
}

# checks $u is a double
proc validateDouble { u widget } {
  global w color
  if { [llength $u] != 1
        || ! [string is double -strict $u] } {
    $w($widget) configure -background $color(Invalid)
  } else {
    $w($widget) configure -background $color(Valid)
  }
  updateButtons
  return 1
}

# checks $uv is a pair of doubles
proc validateDoublePair { uv widget } {
  #remove this if above code works
  global w color
  if { [catch { eval [concat pwu::Vector2 set $uv] } uv]
        || ! [string is double -strict [lindex $uv 0]]
        || ! [string is double -strict [lindex $uv 1]] } {
    $w($widget) configure -background $color(Invalid)
  } else {
    $w($widget) configure -background $color(Valid)
  }
  updateButtons
  return 1
}

# loads the specified file and disables segment and/or surface
# if they are not possible
proc validateUserProcs { fileName } {
  global w control

  # delete all existing user functions
  catch { rename computeSegmentPoint {} }
  catch { rename computeSurfacePoint {} }

  # load the new file
  if { [file exists $fileName] } {
    catch { source $fileName }
  }

  # figure out which type of file the user loaded.
  set canMakeSegment [procExists "computeSegmentPoint"]
  set canMakeSurface [procExists "computeSurfacePoint"]

  # set widget states to match the file-type
  if { $canMakeSegment && $canMakeSurface } {
    $w(ComboEntityType) configure -state readonly
    if { $control(EntityType) eq "N/A" } {
      set control(EntityType) "Segment"
    }
  } elseif { $canMakeSegment } {
    set control(EntityType) "Segment"
    $w(ComboEntityType) configure -state disabled
  } elseif { $canMakeSurface } {
    set control(EntityType) "Surface"
    $w(ComboEntityType) configure -state disabled
  } else {
    set control(EntityType) "N/A"
    $w(ComboEntityType) configure -state disabled
  }
  event generate $w(ComboEntityType) <<ComboboxSelected>>
  updateButtons
  return 1
}

# respond to ok being pressed
proc okAction { } {
  global control segment surface

  if { $control(EntityType) eq "Segment" } {
    set mode [pw::Application begin Create]
      # short cut for segment(Start) and segment(End) cast to double
      set segStart [expr { 1.0 * $segment(Start) }]
      set segEnd [expr { 1.0 * $segment(End) }]

      set stepSize [expr ($segEnd-$segStart) / $segment(NumPoints)]
      if { $control(SegmentType) eq "database" } {
        createCurve $segStart $segEnd $stepSize
      } elseif { $control(SegmentType) eq "grid" } {
        createConnector $segStart $segEnd $stepSize
      } else {
        createSourceCurve $segStart $segEnd $stepSize
      }
    $mode end
  } else {
    createNetworkSurface $surface(Start) $surface(End) $surface(NumPoints)
  }
}

# respond to file button being pressed
proc fileAction { } {
  global control w

  # query for the new file
  if { [file exists $control(File)] } {
    set possibility [tk_getOpenFile -initialfile $control(File) \
                        -filetypes {{Glyph .glf} {All *}}]
    if { ! ($possibility eq "") } {
      set control(File) $possibility
    }
  } else {
    set localDir [file dirname [info script]]
    set control(File) [tk_getOpenFile -initialdir $localDir \
                        -filetypes {{Glyph .glf} {All *}}]
  }

  validateUserProcs $control(File)

  # correct alignment
  $w(EntryFile) xview moveto 1
}

# build the user interface
proc makeWindow { } {
  global w control color

  # create the widgets
  label $w(LabelTitle) -text "Analytic Surface/Curve"
  set fontSize [font actual TkCaptionFont -size]
  set titleFont [font create -family [font actual TkCaptionFont -family] \
    -weight bold -size [expr {int(1.5 * $fontSize)}]]
  $w(LabelTitle) configure -font $titleFont

  frame $w(FrameMain)

  label $w(LabelFile) -text "Analytic Function (Script):" -padx 2 -anchor e
  entry $w(EntryFile) -width 32 -bd 2 -textvariable control(File)
  # correct alignment
  $w(EntryFile) xview moveto 1
  button $w(ButtonFile) -width 9 -bd 2 -text "Browse..." -command fileAction

  label $w(LabelEntityType) -text "Entity Type:" -padx 2 -anchor e
  ttk::combobox $w(ComboEntityType) -textvariable control(EntityType) \
      -values [list "Segment" "Surface"] -state readonly

  labelframe $w(FrameSegment) -bd 3 -text "Parameters"

    labelframe $w(FrameSegmentType) -bd 3 -text "Segment Type"

      radiobutton $w(RadioDatabase) -width 12 -bd 2 -text "Database Curve" \
          -variable control(SegmentType) -value database
      radiobutton $w(RadioGrid) -width 12 -bd 2 -text "Grid Connector" \
          -variable control(SegmentType) -value grid
      radiobutton $w(RadioSource) -width 12 -bd 2 -text "Source Curve" \
          -variable control(SegmentType) -value source

    label $w(LabelStart) -text "Start (U):" -padx 2 -anchor e
    entry $w(EntryStart) -width 6 -bd 2 -textvariable segment(Start)
    $w(EntryStart) configure -background $color(Valid)

    label $w(LabelEnd) -text "End (U):" -padx 2 -anchor e
    entry $w(EntryEnd) -width 6 -bd 2 -textvariable segment(End)
    $w(EntryEnd) configure -background $color(Valid)

    label $w(LabelNumPoints) -text "Number of Control Points (U):" -padx 2 \
        -anchor e
    entry $w(EntryNumPoints) -width 6 -bd 2 -textvariable segment(NumPoints)
    $w(EntryNumPoints) configure -background $color(Valid)

    labelframe $w(FrameType) -bd 3 -text "Curve Algorithm Options"

      radiobutton $w(RadioCatmullRom) -width 12 -bd 2 -text "Catmull-Rom" \
          -variable segment(Type) -value CatmullRom
      radiobutton $w(RadioAkima) -width 12 -bd 2 -text "Akima" \
          -variable segment(Type) -value Akima
      radiobutton $w(RadioLinear) -width 12 -bd 2 -text "Linear" \
          -variable segment(Type) -value Linear

  labelframe $w(FrameSurface) -bd 3 -text "Parameters" -height 36

    label $w(LabelStartUV) -text "Start (UV):" -padx 2 -anchor e
    entry $w(EntryStartUV) -width 6 -bd 2 -textvariable surface(Start)
    $w(EntryStartUV) configure -background $color(Valid)

    label $w(LabelEndUV) -text "End (UV):" -padx 2 -anchor e
    entry $w(EntryEndUV) -width 6 -bd 2 -textvariable surface(End)
    $w(EntryEndUV) configure -background $color(Valid)

    label $w(LabelNumPointsUV) -text "Number of Control Points (UV):" \
        -padx 2 -anchor e
    entry $w(EntryNumPointsUV) -width 6 -bd 2 -textvariable surface(NumPoints)
    $w(EntryNumPointsUV) configure -background $color(Valid)

    checkbutton $w(CheckSplineUV) -text "Spline result (recommended)" \
        -variable surface(Spline)

  frame $w(FrameButtons) -bd 0

    label $w(Logo) -image [cadenceLogo] -bd 0 -relief flat

    button $w(ButtonOk) -width 12 -bd 2 -text "OK" \
                        -command {
                          wm withdraw .
                          okAction
                          writeDefaults
                          exit
                        }

    button $w(ButtonCancel) -width 12 -bd 2 -text "Cancel" \
                            -command {
                              writeDefaults
                              exit
                            }

  message $w(Message) -textvariable infoMessage -background beige \
                      -bd 2 -relief sunken -padx 5 -pady 5 -anchor w \
                      -justify left -width 300

  $w(EntryFile) configure -validate key \
      -vcmd { validateUserProcs %P }

  $w(EntryStart) configure -validate key \
      -vcmd { validateDouble %P EntryStart }
  $w(EntryEnd) configure -validate key \
      -vcmd { validateDouble %P EntryEnd }
  $w(EntryNumPoints) configure -validate key \
      -vcmd { validateInt %P EntryNumPoints }

  $w(EntryStartUV) configure -validate key \
      -vcmd { validateDoublePair %P EntryStartUV }
  $w(EntryEndUV) configure -validate key \
      -vcmd { validateDoublePair %P EntryEndUV }
  $w(EntryNumPointsUV) configure -validate key \
      -vcmd { validateIntPair %P EntryNumPointsUV }

  # lay out the form
  pack $w(LabelTitle) -side top
  pack [frame .sp -bd 1 -height 2 -relief sunken] -pady 4 -side top -fill x
  pack $w(FrameMain) -side top -fill x
  pack $w(FrameButtons) -side top -fill x -expand 1

  # lay out the form in a grid
  grid $w(LabelFile) $w(EntryFile) $w(ButtonFile) -sticky ew -pady 3 -padx 3

  grid $w(LabelEntityType) $w(ComboEntityType) -sticky ew -pady 5 -padx 5

  grid $w(FrameSegment) -sticky ew -pady 5 -padx 5 -column 0 -columnspan 3

    grid $w(FrameSegmentType) -sticky ew -pady 5 -padx 5 -column 0 -columnspan 2
      grid $w(RadioDatabase) $w(RadioGrid) $w(RadioSource) -sticky ew -pady 3 -padx 3

    grid $w(LabelStart) $w(EntryStart) -sticky ew -pady 3 -padx 3
    grid $w(LabelEnd) $w(EntryEnd) -sticky ew -pady 3 -padx 3
    grid $w(LabelNumPoints) $w(EntryNumPoints)  -sticky ew -pady 3 -padx 3

    grid $w(FrameType) -sticky ew -pady 5 -padx 5 -column 0 -columnspan 3
      grid $w(RadioCatmullRom) $w(RadioAkima) $w(RadioLinear) \
          -sticky ew -pady 3 -padx 3

    grid columnconfigure $w(FrameSegment) 1 -weight 1

  grid $w(FrameSurface) -sticky ew -pady 5 -padx 5 -column 0 -columnspan 3

    grid $w(LabelStartUV) $w(EntryStartUV) -sticky ew -pady 3 -padx 3
    grid $w(LabelEndUV) $w(EntryEndUV) -sticky ew -pady 3 -padx 3
    grid $w(LabelNumPointsUV) $w(EntryNumPointsUV) -sticky ew -pady 3 -padx 3
    grid $w(CheckSplineUV) -sticky w  -pady 3 -padx 3

    grid columnconfigure $w(FrameSurface) 1 -weight 1

  # set gridding and de-gridding commands for relevant frames. Set initial
  # gridded or ungridded state as well. Also update the buttons
  # on program state in the command configuration.

  grid remove $w(FrameSurface)

  bind $w(ComboEntityType) <<ComboboxSelected>> \
      {
        switch $control(EntityType) {
          Segment {
            grid $w(FrameSegment)
            grid remove $w(FrameSurface)
          }
          Surface {
            grid $w(FrameSurface)
            grid remove $w(FrameSegment)
          }
          default {
            grid remove $w(FrameSegment)
            grid remove $w(FrameSurface)
          }
        }
        updateButtons
      }

  validateUserProcs $control(File)

  grid columnconfigure $w(FrameMain) 1 -weight 1

  pack $w(ButtonCancel) $w(ButtonOk) -pady 3 -padx 3 -side right
  pack $w(Logo) -side left -padx 5

  pack $w(Message) -side bottom -fill x -anchor s

  bind . <Control-Return> { $w(ButtonOk) invoke }
  bind . <Escape> { $w(ButtonCancel) invoke }

  # move keyboard focus to the first entry
  focus $w(EntryFile)
  raise .

  # don't allow window to resize
  wm resizable . 0 0
}

proc cadenceLogo {} {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}


readDefaults

makeWindow

tkwait window .

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
