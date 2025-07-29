vlib work
vlog reg_mux.v dsp48a1.v dsp48a1_tb.v
vsim -voptargs=+acc work.dsp_unit_tb
add wave *
run -all
#quit -sim