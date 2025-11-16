# Configurações
TB := tb_Sequence_design
STOP := 500000ns
SYN := -fsynopsys
WAVE := wave.vcd

# Arquivos na ordem de compilação
FILES := Controller.vhdl \
         Gerador_Aleatorio.vhdl \
         $(TB).vhdl

all: run

# Compilar todos os arquivos na ordem correta
analyze:
	@echo "🔨 Compilando arquivos..."
	@for file in $(FILES); do \
		echo "📝 Compilando $$file..."; \
		ghdl -a $(SYN) $$file || exit 1; \
	done
	@echo "✅ Compilação concluída!"

# Elaborar o design
elaborate: analyze
	@echo "🔗 Elaborando design..."
	ghdl -e $(SYN) $(TB)
	@echo "✅ Elaboração concluída!"

# Executar simulação
run: elaborate
	@echo "🚀 Executando simulação..."
	ghdl -r $(SYN) $(TB) --vcd=$(WAVE) --stop-time=$(STOP)
	@echo "✅ Simulação concluída!"
	@if command -v gtkwave >/dev/null 2>&1; then \
		echo "📊 Abrindo GTKWave..."; \
		gtkwave $(WAVE) & \
	else \
		echo "📁 $(WAVE) gerado (instale gtkwave para visualizar: sudo apt install gtkwave)"; \
	fi

clean:
	@echo "🧹 Limpando arquivos..."
	rm -f *.o *.cf e~*.o $(WAVE) $(TB)
	ghdl --remove 2>/dev/null || true
	@echo "✅ Limpeza concluída!"

.PHONY: all analyze elaborate run clean