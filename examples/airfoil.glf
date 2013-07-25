#
# Copyright 2013 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

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

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT. TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
