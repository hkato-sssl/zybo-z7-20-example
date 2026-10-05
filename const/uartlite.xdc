# Copyright (c) 2026 Hidekazu Kato <hkato.sssl@gmail.com>
# SPDX-License-Identifier: MIT

set_property IOSTANDARD LVCMOS33 [get_ports UART_0_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports UART_0_txd]
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_txd]

set_property PACKAGE_PIN J15 [get_ports UART_0_rxd]
set_property PACKAGE_PIN P14 [get_ports UART_1_rxd]
set_property PACKAGE_PIN W16 [get_ports UART_0_txd]
set_property PACKAGE_PIN T15 [get_ports UART_1_txd]
