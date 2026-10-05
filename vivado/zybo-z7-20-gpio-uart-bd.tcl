# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

# ZYNQ-7000 PS
set zynq [local::create_xip processing_system7:5.5 processing_system7_0 {
    CONFIG.PCW_IRQ_F2P_INTR 1
    CONFIG.PCW_USE_FABRIC_INTERRUPT 1
}]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
    make_external "FIXED_IO, DDR"
    apply_board_preset "1"
    Master "Disable"
    Slave "Disable"
}  $zynq

# Reset controller for AXI peripherals
local::create_xip_cell proc_sys_reset:5.0 reset_fclk_clk0

# AXI SmartConnect
local::create_xip smartconnect:1.0 smartconnect_0 {
    CONFIG.NUM_SI 1
}

# AXI UART Lite
local::create_xip axi_uartlite:2.0 axi_uartlite_0 {
    CONFIG.C_BAUDRATE   115200
}
make_bd_intf_pins_external  [get_bd_intf_pins axi_uartlite_0/UART]

local::create_xip axi_uartlite:2.0 axi_uartlite_1 {
    CONFIG.C_BAUDRATE   115200
}
make_bd_intf_pins_external  [get_bd_intf_pins axi_uartlite_1/UART]

# LEDs via AXI GPIO
local::create_xip axi_gpio:2.0 axi_gpio_leds {
    CONFIG.C_INTERRUPT_PRESENT  0
}
apply_board_connection -board_interface leds_4bits -ip_intf axi_gpio_leds/GPIO -diagram $BD_DESIGN
apply_board_connection -board_interface rgb_led -ip_intf axi_gpio_leds/GPIO2 -diagram $BD_DESIGN

# Buttons and slide switches via AXI GPIO
local::create_xip axi_gpio:2.0 axi_gpio_inputs {
    CONFIG.C_INTERRUPT_PRESENT  1
}
apply_board_connection -board_interface btns_4bits -ip_intf axi_gpio_inputs/GPIO -diagram $BD_DESIGN
apply_board_connection -board_interface sws_4bits -ip_intf axi_gpio_inputs/GPIO2 -diagram $BD_DESIGN

# Connect AXI peripheral interfaces
set_property CONFIG.NUM_MI 4 [get_bd_cells smartconnect_0]
local::connect_ifs smartconnect_0/M00_AXI axi_uartlite_0/S_AXI
local::connect_ifs smartconnect_0/M01_AXI axi_uartlite_1/S_AXI
local::connect_ifs smartconnect_0/M02_AXI axi_gpio_leds/S_AXI
local::connect_ifs smartconnect_0/M03_AXI axi_gpio_inputs/S_AXI
local::connect_ifs smartconnect_0/S00_AXI processing_system7_0/M_AXI_GP0

# Interrupt signals
local::create_inline_hdl ilconcat:1.0 ilconcat_0 {
    CONFIG.NUM_PORTS 3
}
local::connect_pins axi_uartlite_0/interrupt ilconcat_0/In0
local::connect_pins axi_uartlite_1/interrupt ilconcat_0/In1
local::connect_pins axi_gpio_inputs/ip2intc_irpt ilconcat_0/In2
local::connect_pins ilconcat_0/dout processing_system7_0/IRQ_F2P

# Reset signals
local::connect_pins processing_system7_0/FCLK_RESET0_N reset_fclk_clk0/ext_reset_in 
local::connect_pins reset_fclk_clk0/peripheral_aresetn {
    smartconnect_0/aresetn
    axi_uartlite_0/s_axi_aresetn
    axi_uartlite_1/s_axi_aresetn
    axi_gpio_inputs/s_axi_aresetn
    axi_gpio_leds/s_axi_aresetn
}

# Clock signals
local::connect_pins processing_system7_0/FCLK_CLK0 {
    processing_system7_0/M_AXI_GP0_ACLK
    smartconnect_0/aclk
    reset_fclk_clk0/slowest_sync_clk
    axi_uartlite_0/s_axi_aclk
    axi_uartlite_1/s_axi_aclk
    axi_gpio_inputs/s_axi_aclk
    axi_gpio_leds/s_axi_aclk
}

# Assign BD addresses
assign_bd_address

# Epilogue
regenerate_bd_layout
save_bd_design
