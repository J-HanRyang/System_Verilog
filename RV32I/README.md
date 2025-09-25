# RV32I
SystemVerilog로 구현한 RV32I 명령어 세트의 단일 사이클 CPU 코어, R, S, I, B-Type의 기본 정수 명령어 동작 원리를 학습 <br>
R -> S -> I -> B -> U Type으로 확장하며 구체화

## Block Diagram
<div align="conter">
  <img width="1844" height="933" alt="image" src="https://github.com/user-attachments/assets/ea2e5abe-3ebb-46a0-ad61-db57d9a0be8e" />
</div>

<br>

## Operation by Command Type
### [R-Type](https://github.com/J-HanRyang/System_Verilog/tree/main/RV32I/%20R_Type) (Reg - Reg 연산)
- **목표 :** 두 개의 소스 레지스터(Rs1, Rs2) 값을 읽어 ALU 연산을 수행하고, 그 결과를 목적지 레지스터(Rd)에 저장
- **동작 형태 :** Rd = Rs1 OP Rs2
- **구현된 명령어 :** add, sub, sll, srl, sra, slt, sltu, xor, and

### [S-Type](https://github.com/J-HanRyang/System_Verilog/tree/main/RV32I/S_Type) (메모리 저장)
- **목표 :** Rs1과 상수를 더해 계산한 메모리 주소에 Rs2 레지스터 값을 저장
- **동작 형태 :** MEM[Rs1 + imm] = Rs2
- **구현된 명령어 :** sw, sh, sb

### [I-Type](https://github.com/J-HanRyang/System_Verilog/tree/main/RV32I/I_Type) (상수 연산 / 메모리 로드)
- **목표 :** 소스 레지스터(Rs1)와 부호 확장된 상수(imm)를 연산에 이용하거나, 메모리에서 데이터를 읽어와 레지스터(Rd)에 저장함
- **동작 형태 :
  - **산술/논리 :** Rd = Rs1 OP imm
  - **메모리 로드 :** Rd = MEM[Rs1 + imm]
- **구현된 명령어 :**
  - **산술/논리 :** addi, slti, sltiu, xori, ori, andi, slli, srli, srai
  - **메모리 로드 :** lw, lh, lb, lhu, lbu

### [B-Type](https://github.com/J-HanRyang/System_Verilog/tree/main/RV32I/B_Type) (조건부 분기)
- **목표 :** 두 소스 레지스터(Rs1, Rs2)를 비교하여, 조건이 참인경우 PC의 값을 PC+imm으로 변경하여 프로그램의 실행 흐름을 바꿈
- **동작 형태 :** if (Rs1 OP Rs2) ? PC : PC + imm
- **구현된 명령어 :** beq, bne, blt, bge, bltu, bgeu

<br>

## Main modules
- **Control_Unit.sv :** 제어 유닛, 명령어 해독 및 모든 제어 신호 생성
- **DataPath.sv :** 데이터패스, PC, 레지스터 파일, ALU 등 데이터 처리 및 흐름 담당
- **Inst_ROM.sv :** 데이터 메모리, Load/Store 명령어 처리
- **Data_RAM.sv :** 테스트용 명령어가 저장된 프로그램 메모리
