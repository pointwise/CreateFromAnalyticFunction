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
# Analytic function to create a sphere. See analyticFunctions.glf.
################################################################################

proc computeSurfacePoint { u v } {

  set pi 3.1415926535897931

  set r 1

  set phi [expr { $u * $pi } ]
  set theta [expr { $v * $pi * 2 } ]
  
  set x [expr { $r * sin($phi) * cos($theta) } ]
  set y [expr { $r * sin($phi) * sin($theta) } ]
  set z [expr { $r * cos($phi) } ]

  return "$x $y $z"
}

proc computeSegmentPoint { u } {

  set pi 3.1415926535897931

  set r 1

  set theta [expr { $u * $pi * 2 } ]

  set x [expr { $r * cos($theta) } ]
  set y [expr { $r * sin($theta) } ]

  return "$x $y 0"
}

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
