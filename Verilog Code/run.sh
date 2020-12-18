#!/usr/bin/env bash

vlog -f ahblite_sys.vc
vopt -work work ahblite_sys_tb -o work_opt +acc
vsim work_opt -gui
