# Hey Emacs, use -*- Tcl -*- mode

if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded tclgnuplot 1.0 [list source [file join $dir tclgnuplot.tcl]]
