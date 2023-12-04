onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main_test/clk
add wave -noupdate /main_test/rw
add wave -noupdate /main_test/reset
add wave -noupdate /main_test/valid_req
add wave -noupdate -radix hexadecimal /main_test/data_in
add wave -noupdate -radix hexadecimal /main_test/addr
add wave -noupdate -radix hexadecimal /main_test/data_out
add wave -noupdate /main_test/cache_ready
add wave -noupdate /main_test/hit
add wave -noupdate /main_test/miss
add wave -noupdate /main_test/read
add wave -noupdate /main_test/write
add wave -noupdate -radix hexadecimal /main_test/ram_out
add wave -noupdate -radix hexadecimal /main_test/cache_out
add wave -noupdate -radix hexadecimal /main_test/tag
add wave -noupdate /main_test/current_state
add wave -noupdate /main_test/next_state
add wave -noupdate /main_test/cw_en
add wave -noupdate /main_test/cr_en
add wave -noupdate /main_test/mw_en
add wave -noupdate /main_test/mr_en
add wave -noupdate /main_test/ram_ack
add wave -noupdate /main_test/set_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {175548 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 196
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
configure wave -timelineunits ps
update
WaveRestoreZoom {133901 ps} {254005 ps}
