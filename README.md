## Project Overview

![alt-text](https://media.cheggcdn.com/media/c71/c71bed0f-53dc-486c-8ab0-d8a53a3702b1/php432Vsz)

This project is a **single-cycle RISC-V processor (RV32I)** implementation created in **SystemVerilog**. It is designed based on the architecture presented in the book *Computer Organization and Design: The Hardware/Software Interface* by **David A. Patterson and John L. Hennessy**. This processor design follows the structure outlined for the **RV32I** instruction set architecture (ISA), and the design is simulated using **Icarus Verilog**.

## Design Structure

The core of the processor is a **single-cycle design**, which means that each instruction completes in one clock cycle. The design includes the following submodules, as shown in the provided diagram:

1. **Program Counter (PC)** - The PC keeps track of the address of the current instruction
2. **Instruction Memory** - This submodule holds the instructions
3. **Control Unit** - Decodes the instruction and generates control signals for other modules
4. **ALU (Arithmetic Logic Unit)** - Performs arithmetic and logical operations
5. **Registers** - A set of 32 general-purpose registers for storing temporary data
6. **Data Memory** - Handles data read/write operations
7. **Immediate Generator** - Generates immediate values required by instructions
8. **Multiplexers** - Used to select inputs for different stages based on determined control signals
9. **ALU Control** - Determines the operation to be performed by the ALU

Each submodule is carefully designed to handle its specific part of the CPU, including a TB to test individual capability.

## Current Status and Future Plans

This project is currently a **Work in Progress (WIP)**. Some improvements and additions are planned for future iterations:

1. **Pipelining**: 
   - A major future enhancement is pipelining**, allowing the processor to execute multiple instructions concurrently, allowing for a significant performance boost.
   
2. **Branch Prediction**:
   - I plan to implement branch prediction mechanisms to improve instruction flow and reduce pipeline stalls caused by branching instructions.

3. **Top-Level Simulation**:
   - A more complete top-level simulation will be implemented, where the entire processor, including all modules, will be simulated with more complex test cases.

4. **Additional Testbenches**:
   - More testbenches will be developed to validate edge cases, seek out potential corner cases, and ensure robust design handling under various scenarios.

5. **Optimization**:
   - Further optimization may be done on areas where there is room for improvement, such as in the ALU design or memory operations.
