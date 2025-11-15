# Configurações
TB := tb_Sequence_design
STOP := 20000ns
SYN := -fsynopsys
WAVE := wave.vcd

# Arquivos na ordem de compilação
FILES := Types.vhdl \
         Seed_generator.vhdl \
         LFSR_3bits.vhdl \
         Reorder_Vector.vhdl \
         Controller.vhdl \
         Sequence_design.vhdl \
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

# Executar sem abrir GTKWave
run-only: elaborate
	@echo "🚀 Executando simulação..."
	ghdl -r $(SYN) $(TB) --vcd=$(WAVE) --stop-time=$(STOP)

# Abrir GTKWave (se wavefile existir)
view:
	@if [ -f "$(WAVE)" ]; then \
		gtkwave $(WAVE) & \
	else \
		echo "❌ $(WAVE) não encontrado. Execute 'make run' primeiro."; \
	fi

# Limpar arquivos gerados
clean:
	@echo "🧹 Limpando arquivos..."
	rm -f *.o *.cf e~*.o $(WAVE) $(TB)
	ghdl --remove 2>/dev/null || true
	ghdl --clean 2>/dev/null || true
	@echo "✅ Limpeza concluída!"

# Ajuda
help:
	@echo "🎯 Comandos disponíveis:"
	@echo "  make all     - Compilar e executar simulação (abre GTKWave)"
	@echo "  make run     - Compilar e executar simulação"
	@echo "  make run-only - Executar simulação sem abrir GTKWave"
	@echo "  make view    - Abrir GTKWave com wavefile existente"
	@echo "  make clean   - Limpar todos os arquivos gerados"
	@echo "  make help    - Mostrar esta ajuda"
	@echo ""
	@echo "⚙️  Configurações:"
	@echo "  Testbench: $(TB)"
	@echo "  Tempo: $(STOP)"
	@echo "  Wavefile: $(WAVE)"

.PHONY: all analyze elaborate run run-only view clean help