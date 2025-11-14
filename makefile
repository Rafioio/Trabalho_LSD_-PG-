# Makefile para testar Input e Controller
GHDL = ghdl
GTKWAVE = gtkwave

test_input:
	@echo "=== TESTANDO INPUT ==="
	$(GHDL) -a Input.vhdl
	$(GHDL) -a tb_Input.vhdl
	$(GHDL) -e tb_Input
	$(GHDL) -r tb_Input --vcd=wave_input.vcd --stop-time=1000ns

test_controller:
	@echo "=== TESTANDO CONTROLLER ==="
	$(GHDL) -a Input.vhdl
	$(GHDL) -a Controller.vhdl
	$(GHDL) -a tb_Controller.vhdl
	$(GHDL) -e tb_Controller
	$(GHDL) -r tb_Controller --vcd=wave_controller.vcd --stop-time=2000ns

view_input:
	$(GTKWAVE) wave_input.vcd

view_controller:
	$(GTKWAVE) wave_controller.vcd

clean:
	rm -f *.cf *.vcd e~*.o tb_Input tb_Controller

.PHONY: test_input test_controller view_input view_controller clean