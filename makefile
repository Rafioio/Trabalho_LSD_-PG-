# Makefile para testar sistema completo
GHDL = ghdl
GTKWAVE = gtkwave

test_controller:
	@echo "=== TESTANDO CONTROLLER COMPLETO (INPUT + LED) ==="
	$(GHDL) -a Input.vhdl
	$(GHDL) -a Controller.vhdl
	$(GHDL) -a tb_Controller.vhdl
	$(GHDL) -e tb_Controller
	$(GHDL) -r tb_Controller --vcd=wave_controller.vcd --stop-time=2000ns

view_controller:
	$(GTKWAVE) wave_controller.vcd

clean:
	rm -f *.cf *.vcd e~*.o tb_Controller

.PHONY: test_controller view_controller clean