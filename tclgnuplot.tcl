# Hey Emacs, use -*- Tcl -*- mode

package require cmdline 1.5

namespace eval ::gnuplot {
    
}

proc ::gnuplot::intlist {args} {
    # Return a list of increasing integers starting with start with
    # length points
    #
    # Arguments:
    #   first -- First integer in the list
    #   length -- Number of integers in the list
    set myoptions {
	{first.arg 0 "First integer"}
	{length.arg 10 "Length of the list"}
    }
    array set arg [::cmdline::getoptions args $myoptions]

    set count 0
    set intlist [list]
    while { [llength $intlist] < $arg(length) } {
	    lappend intlist [expr $arg(first) + $count]
	    incr count
	}
    return $intlist
}

proc ::gnuplot::engineering_notation {args} {
    # Return a number with an SI prefix as a suffix
    #
    # See https://wiki.tcl-lang.org/page/Engineering+Notation
    # and https://www.tcl.tk/man/tcl8.6/TclCmd/format.htm#M20
    #
    # Arguments:
    #   number -- The full number you want to convert
    #   digits -- Maximum number of significant digits to keep
    set myoptions {
	{number.arg 0.0123 "Number to format"}
	{digits.arg 3 "Digits to keep in the formatted output"}
    }
    array set arg [::cmdline::getoptions args $myoptions]

    # Metric prefix symbols (power of 10 divided by 3)
    #
    # See https://www.nist.gov/pml/owm/metric-si-prefixes
    array set orders {
	-8 y -7 z -6 a -5 f -4 p -3 n -2 u -1 m 0 {} 1 k 2 M 3 G 4 T 5 P 6 E 7 Z 8 Y
    }
 
    set number_list  [split [format %e $arg(number)] e]
    set order [expr {[scan [lindex $number_list 1] %d] / 3}]
    if {[catch {set orders($order)} prefix]} {
	return [list $arg(number)]
    }
    set number [format %0.${arg(digits)}g [expr {$arg(number)/pow(10,3*$order)}]]
    if {$prefix eq ""} {
	return $number
    } else {
	return [list $number $prefix]
    }
}

proc ::gnuplot::print_dictionary { dictionary {pattern *} } {
    # Print a formatted version of a dictionary
    # https://wiki.tcl-lang.org/page/pdict%3A+Pretty+print+a+dict
    set longest 0
    dict for {key -} $dictionary {
	if {[string match $pattern $key]} {
	    set longest [expr {max($longest, [string length $key])}]
	}
    }
    dict for {key value} [dict filter $dictionary key $pattern] {
       puts [format "%-${longest}s = %s" $key $value]
    }
}


proc ::gnuplot::y_reference_line { args } {
    # Return gnuplot command strings to create a reference line with a label
    set myoptions {
	{first "Reference the first y axis"}
	{second "Reference the second y axis"}
	{value.arg "1" "Reference line position using the first or second y-axis coordinates"}
	{label-text.arg  "none" "Text label for the reference line to appear somewhere on the line"}
	{label-position.arg "0.5" "Where the label should go on the reference line using 0 --> 1 coordinates"}
	{label-offset.arg "0.02" "Additional spacing between the reference line and the label text"}
	{dashtype "2" "What kind of line to use"}
    }
    array set arg [::cmdline::getoptions args $myoptions]

    set axis_name "first"
    if $arg(second) {
	set axis_name "second"
    } 
    set line_string "set arrow from graph 0, $axis_name $arg(value) "
    append line_string "to graph 1, $axis_name $arg(value) "
    append line_string "nohead dashtype $arg(dashtype)"

    set label_string "set label '$arg(label-text)' at graph $arg(label-position), $axis_name $arg(value) "
    append label_string "offset graph 0, graph $arg(label-offset) "
    append label_string "enhanced"

    return $line_string\n$label_string
}


# Finally, provide the package
package provide tclgnuplot 1.0
