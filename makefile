# Makefile para GHDL + GTKWave — Projeto LFSR

TB := tb_LFSR
STOP := 3us
SYN := -fsynopsys

all: run

analyze:
	ghdl -a $(SYN) LFSR_3bit.vhdl
	ghdl -a $(SYN) Reorder_Vector.vhdl
	ghdl -a $(SYN) $(TB).vhdl

elaborate: analyze
	ghdl -e $(SYN) $(TB)

run: elaborate
	ghdl -r $(SYN) $(TB) --vcd=wave.vcd --stop-time=$(STOP)
	@if command -v gtkwave >/dev/null 2>&1; then gtkwave wave.vcd & else echo "wave.vcd gerado (instale gtkwave para visualizar)"; fi

clean:
	rm -f *.o work-*.cf wave.vcd
