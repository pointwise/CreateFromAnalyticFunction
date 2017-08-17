#
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

################################################################################
# Analytic function to create a spiral. See analyticFunctions.glf.
################################################################################

proc computeSurfacePoint { u v } {

  set pi 3.1415926535897931

  # 1st axis
  set R1 1.0
  # 2nd axis
  set R2 1.0
  # number of rotations per unit length
  set N [expr {1.0/(2.0 * $pi)}]

  set phi [expr { $u * $pi * 2.0 } ]
  set theta [expr { $N * $v * $pi * -2.0 } ]

  set x [expr { $R1 * cos($phi) * cos($theta) - $R2 * sin($phi) * sin($theta) }]
  set y [expr { $R1 * cos($phi) * sin($theta) + $R2 * sin($phi) * cos($theta) }]
  set z [expr { $v }]

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
