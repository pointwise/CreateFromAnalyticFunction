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
# Analytic function to create a NACA airfoil. See analyticFunctions.glf
################################################################################

proc computeSegmentPoint { u } {

    set x $u
    set z 0.0
    set t 0.12

    if {$x >= 0.0} {
        set y [expr { ($t/0.2) * (0.2969*sqrt($x) - 0.1260*($x) - 0.3516*pow($x,2) + 0.2843*pow($x,3) - 0.1015*pow($x,4)) }]
    } elseif {$x < 0.0} {
        set x [expr {-1.0*$x}]
        set y [expr { -1.0 * ($t/0.2) * (0.2969*sqrt($x) - 0.1260*($x) - 0.3516*pow($x,2) + 0.2843*pow($x,3) - 0.1015*pow($x,4)) }]
    }

    return "$x $y $z"

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
