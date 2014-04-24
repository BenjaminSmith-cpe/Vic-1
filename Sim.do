onerror {resume}
quietly set dataset_list [list sim vsim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/VIC1_TB/DUT/clock
add wave -noupdate -divider Busses
add wave -noupdate sim:/VIC1_TB/DUT/B_BUS
add wave -noupdate sim:/VIC1_TB/DUT/C_BUS
add wave -noupdate -radix decimal sim:/VIC1_TB/DUT/B_CONTROL
add wave -noupdate -radix binary sim:/VIC1_TB/DUT/C_CONTROL
add wave -noupdate sim:/VIC1_TB/DUT/ALU_HBUS
add wave -noupdate -divider Registers
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/H/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/OPC/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/TOS/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/CPP/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/LV/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/SP/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/PC/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/MAR/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/MBR/DataContents
add wave -noupdate -expand -group DataContents sim:/VIC1_TB/DUT/MDR/DataContents
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/H_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/OPC_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/OPC_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/TOS_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/TOS_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/CPP_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/CPP_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/LV_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/LV_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/SP_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/SP_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/PC_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/PC_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MDR_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MDR_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MAR_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MAR_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MBR_ena
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MBR_OutEn
add wave -noupdate -expand -group {Control Signals} sim:/VIC1_TB/DUT/MBRU_OutEn
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/OPC_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/TOS_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/CPP_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/LV_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/SP_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/PC_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/PC_SpecialOut
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/MDR_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/MAR_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/MAR_SpecialOut
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/MBR_out
add wave -noupdate -expand -group {Output Values} sim:/VIC1_TB/DUT/MBRU_out
add wave -noupdate -divider Memory
add wave -noupdate sim:/VIC1_TB/DUT/FETCH
add wave -noupdate sim:/VIC1_TB/DUT/READ
add wave -noupdate sim:/VIC1_TB/DUT/WRITE
add wave -noupdate sim:/VIC1_TB/DUT/MemoryBus
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {9 ns} {31 ns}
