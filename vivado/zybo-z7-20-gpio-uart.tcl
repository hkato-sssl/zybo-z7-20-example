# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

# parameters
set FPGA_PART xc7z020clg400-1
set BOARD_PART digilentinc.com:zybo-z7-20:part0:1.2
set JOBS 8
set PROJ_NAME [file rootname [file tail [info script]]]
set PROJ_DIR $env(HOME)/ws/vivado/$PROJ_NAME
set SCRIPT_DIR [file dirname [info script]]
set BD_FILE $SCRIPT_DIR/${PROJ_NAME}-bd.tcl
set BD_DESIGN design_1
set SRC_DIR $SCRIPT_DIR/../src
set SRC_FILES {
}
set XDC_DIR $SCRIPT_DIR/../const
set XDC_FILES {
    $XDC_DIR/uartlite.xdc
}

# import the local functions
source $SCRIPT_DIR/local-funcs.tcl

# set the board repository path
set_param board.repoPaths $env(HOME)/.Xilinx/Vivado/2025.1/xhub/board_store

# create the project
if {! [local::is_installed $BOARD_PART]} {
    xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
    xhub::install [xhub::get_xitems $BOARD_PART]
}
create_project $PROJ_NAME $PROJ_DIR -part $FPGA_PART
set_property board_part $BOARD_PART [current_project]

# import source files
if {[info exists SRC_FILES] && [llength $SRC_FILES] > 0} {
    import_files -norecurs [subst $SRC_FILES]
}
if {[info exists XDC_FILES] && [llength $XDC_FILES] > 0} {
    import_files -norecurs -fileset constrs_1 [subst $XDC_FILES]
}

# create the block design
create_bd_design $BD_DESIGN
source $BD_FILE

# create the wrapper file
make_wrapper -files [get_files $PROJ_DIR/$PROJ_NAME.srcs/sources_1/bd/$BD_DESIGN/$BD_DESIGN.bd] -top
add_files -norecurse $PROJ_DIR/$PROJ_NAME.gen/sources_1/bd/$BD_DESIGN/hdl/${BD_DESIGN}_wrapper.v

# Generate a bitstream file
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
wait_on_run impl_1

# Write a XSA file
write_hw_platform -fixed -include_bit -force -file $PROJ_DIR/$PROJ_NAME.xsa

