# Variables
SRC = $(wildcard *.sv)
OUT = build.vvp  # Generic output file name

# Default target
all: $(OUT)

$(OUT): $(SRC)
	iverilog -g2012 -o $(OUT) $(SRC)

# Run all .vvp files in the directory
run: $(wildcard *.vvp)
	@for file in $^; do vvp $$file; done

clean:
	rm -f *.vvp