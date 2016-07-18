#!/usr/bin/tclsh

proc compare {old new} {
  set compare_value [string compare [lindex $old 0] [lindex $new 0]]
  if {$compare_value != 0} {
    return $compare_value
  }
  return [string compare [lindex $old 1] [lindex $new 1]]
}

proc normalize_list file_list {
  set return_list {}
  foreach file $file_list {
    if {[string equal [string trim $file] ""]} {
      continue
    }
    if {[regexp {\.DS_Store} $file]} {
      continue
    }
    if {[string equal $file "./.iTunes Preferences.plist"]} {
      continue
    }
    if {[string equal $file "./Downloads/list.plist"]} {
      continue
    }
    if {[regexp {Voice Memos} $file]} {
      continue
    }
    set path_elems [file split $file]
    set artist [lindex $path_elems 1]
    if {[string equal $artist "Movies"]} {
      set artist ""
      set album "Movies"
      set title [lindex $path_elems 2]
    } elseif {[string equal $artist "Ringtones"]} {
      set artist ""
      set album "Ringtones"
      set title [lindex $path_elems 2]
    } else {
      set album [lindex $path_elems 2]
      set title [lindex $path_elems 3]
    }
    lappend return_list [list $album [file rootname $title] $artist]
  }
  return [lsort -command compare $return_list]
}

set old_file [lindex $argv 0]

set old_fd [open $old_file]
set old_files [read $old_fd]
close $old_fd
set old_files [split $old_files \n]
set old_file_list [normalize_list $old_files]

set new_file [lindex $argv 1]
set new_fd [open $new_file]
set new_files [read $new_fd]
close $new_fd
set new_files [split $new_files \n]
set new_file_list [normalize_list $new_files]

while {[llength $old_file_list] > 0 && [llength $new_file_list] > 0} {
  set old_file [lindex $old_file_list 0]
  set new_file [lindex $new_file_list 0]
  set old_album [lindex $old_file 0]
  set new_album [lindex $new_file 0]
  set compare_value [string compare $old_album $new_album]
  if {$compare_value < 0} {
    puts "Album - $old_album; Title - [lindex $old_file 1]; Artist - [lindex $old_file 2]"
    set old_file_list [lrange $old_file_list 1 end]
  } elseif {$compare_value > 0} {
    set new_file_list [lrange $new_file_list 1 end]
  } else {
    set old_title [lindex $old_file 1]
    set new_title [lindex $new_file 1]
    set compare_value [string compare $old_title $new_title]
    if {$compare_value < 0} {
      puts "Album - $old_album; Title - $old_title; Artist - [lindex $old_file 2]"
      set old_file_list [lrange $old_file_list 1 end]
    } elseif {$compare_value > 0} {
      set new_file_list [lrange $new_file_list 1 end]
    } else {
      set old_file_list [lrange $old_file_list 1 end]
      set new_file_list [lrange $new_file_list 1 end]
    }
  }
}
