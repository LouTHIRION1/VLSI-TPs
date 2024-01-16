library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
  port
  (
    -- Exec  operands
    dec_op1      : out std_logic_vector(31 downto 0); -- first alu input
    dec_op2      : out std_logic_vector(31 downto 0); -- shifter input
    dec_exe_dest : out std_logic_vector(3 downto 0);  -- Rd destination
    dec_exe_wb   : out std_logic;                     -- Rd destination write back
    dec_flag_wb  : out std_logic;                     -- CSPR modifiy

    -- Decod to mem via exec
    dec_mem_data  : out std_logic_vector(31 downto 0); -- data to MEM
    dec_mem_dest  : out std_logic_vector(3 downto 0);
    dec_pre_index : out std_logic;

    dec_mem_lw : out std_logic;
    dec_mem_lb : out std_logic;
    dec_mem_sw : out std_logic;
    dec_mem_sb : out std_logic;

    -- Shifter command
    dec_shift_lsl : out std_logic;
    dec_shift_lsr : out std_logic;
    dec_shift_asr : out std_logic;
    dec_shift_ror : out std_logic;
    dec_shift_rrx : out std_logic;
    dec_shift_val : out std_logic_vector(4 downto 0);
    dec_cy        : out std_logic;

    -- Alu operand selection
    dec_comp_op1 : out std_logic;
    dec_comp_op2 : out std_logic;
    dec_alu_cy   : out std_logic;

    -- Exec Synchro
    dec2exe_empty : out std_logic;
    exe_pop       : in std_logic;

    -- Alu command
    dec_alu_cmd : out std_logic_vector(1 downto 0);

    -- Exe Write Back to reg
    exe_res : in std_logic_vector(31 downto 0);

    exe_c : in std_logic;
    exe_v : in std_logic;
    exe_n : in std_logic;
    exe_z : in std_logic;

    exe_dest    : in std_logic_vector(3 downto 0); -- Rd destination
    exe_wb      : in std_logic;                    -- Rd destination write back
    exe_flag_wb : in std_logic;                    -- CSPR modifiy

    -- Ifetch interface
    dec_pc : out std_logic_vector(31 downto 0);
    if_ir  : in std_logic_vector(31 downto 0);

    -- Ifetch synchro
    dec2if_empty : out std_logic;
    if_pop       : in std_logic;

    if2dec_empty : in std_logic;
    dec_pop      : out std_logic;

    -- Mem Write back to reg
    mem_res  : in std_logic_vector(31 downto 0);
    mem_dest : in std_logic_vector(3 downto 0);
    mem_wb   : in std_logic;

    -- global interface
    ck      : in std_logic;
    reset_n : in std_logic;
    vdd     : in bit;
    vss     : in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior of Decod is

  component reg
    port
    (
      -- Write Port 1 prioritaire
      wdata1 : in std_logic_vector(31 downto 0);
      wadr1  : in std_logic_vector(3 downto 0);
      wen1   : in std_logic;

      -- Write Port 2 non prioritaire
      wdata2 : in std_logic_vector(31 downto 0);
      wadr2  : in std_logic_vector(3 downto 0);
      wen2   : in std_logic;

      -- Write CSPR Port
      wcry    : in std_logic;
      wzero   : in std_logic;
      wneg    : in std_logic;
      wovr    : in std_logic;
      cspr_wb : in std_logic;

      -- Read Port 1 32 bits
      reg_rd1 : out std_logic_vector(31 downto 0);
      radr1   : in std_logic_vector(3 downto 0);
      reg_v1  : out std_logic;

      -- Read Port 2 32 bits
      reg_rd2 : out std_logic_vector(31 downto 0);
      radr2   : in std_logic_vector(3 downto 0);
      reg_v2  : out std_logic;

      -- Read Port 3 32 bits
      reg_rd3 : out std_logic_vector(31 downto 0);
      radr3   : in std_logic_vector(3 downto 0);
      reg_v3  : out std_logic;

      -- read CSPR Port
      reg_cry  : out std_logic;
      reg_zero : out std_logic;
      reg_neg  : out std_logic;
      reg_cznv : out std_logic;
      reg_ovr  : out std_logic;
      reg_vv   : out std_logic;

      -- Invalidate Port 
      inval_adr1 : in std_logic_vector(3 downto 0);
      inval1     : in std_logic;

      inval_adr2 : in std_logic_vector(3 downto 0);
      inval2     : in std_logic;

      inval_czn : in std_logic;
      inval_ovr : in std_logic;

      -- PC
      reg_pc  : out std_logic_vector(31 downto 0);
      reg_pcv : out std_logic;
      inc_pc  : in std_logic;

      -- global interface
      ck      : in std_logic;
      reset_n : in std_logic;
      vdd     : in bit;
      vss     : in bit);
  end component;

  component fifo_127b
    port
    (
      din  : in std_logic_vector(126 downto 0);
      dout : out std_logic_vector(126 downto 0);

      -- commands
      push : in std_logic;
      pop  : in std_logic;

      -- flags
      full  : out std_logic;
      empty : out std_logic;

      reset_n : in std_logic;
      ck      : in std_logic;
      vdd     : in bit;
      vss     : in bit
    );
  end component;

  component fifo_32b
    port
    (
      din  : in std_logic_vector(31 downto 0);
      dout : out std_logic_vector(31 downto 0);

      -- commands
      push : in std_logic;
      pop  : in std_logic;

      -- flags
      full  : out std_logic;
      empty : out std_logic;

      reset_n : in std_logic;
      ck      : in std_logic;
      vdd     : in bit;
      vss     : in bit
    );
  end component;

  signal cond  : std_logic; -- Condition (Predicat) based on valid flags
  signal condv : std_logic; -- Wait until valid
  signal operv : std_logic; -- Wait until source operands are valid (controls stall cycles)

  -- Instruction Type
  signal regop_t  : std_logic; -- Operand registre
  signal mult_t   : std_logic; -- Multiplication
  signal swap_t   : std_logic; -- 
  signal trans_t  : std_logic; -- Transfert mémoire
  signal mtrans_t : std_logic; -- Transfert mémoire multiple
  signal branch_t : std_logic; -- Branch

  ---- Instruction type (only 1 signal is enabled at a time!)
  -- Regop instructions
  signal and_i : std_logic; -- AND
  signal eor_i : std_logic; -- XOR
  signal sub_i : std_logic; -- SUBstraction
  signal rsb_i : std_logic; -- 
  signal add_i : std_logic; -- ADDition
  signal adc_i : std_logic; -- ADdition with Carry
  signal sbc_i : std_logic;
  signal rsc_i : std_logic;
  signal tst_i : std_logic;
  signal teq_i : std_logic;
  signal cmp_i : std_logic;
  signal cmn_i : std_logic;
  signal orr_i : std_logic;
  signal mov_i : std_logic;
  signal bic_i : std_logic;
  signal mvn_i : std_logic;

  -- mult instruction
  signal mul_i : std_logic;
  signal mla_i : std_logic;

  -- trans instruction
  signal ldr_i  : std_logic;
  signal str_i  : std_logic;
  signal ldrb_i : std_logic;
  signal strb_i : std_logic;

  -- mtrans instruction
  signal ldm_i : std_logic; -- Load Multiple
  signal stm_i : std_logic; -- Store Multiple

  -- branch instruction
  signal b_i  : std_logic;
  signal bl_i : std_logic;

  -- link
  signal blink : std_logic; -- Branch and Link

  -- Multiple transferts
  signal mtrans_shift : std_logic; -- 16 bits qui indiquent le registre a transferer, on fait un decalage pour identifier les registres qui sont a transferer

  signal mtrans_ia : std_logic;
  signal mtrans_ib : std_logic;
  signal mtrans_da : std_logic;
  signal mtrans_da : std_logic;

  signal mtrans_mask_shift : std_logic_vector(15 downto 0);
  signal mtrans_mask       : std_logic_vector(15 downto 0);
  signal mtrans_list       : std_logic_vector(15 downto 0);
  signal mtrans_1un        : std_logic;
  signal mtrans_loop_adr   : std_logic;
  signal mtrans_nbr        : std_logic_vector(4 downto 0);
  signal mtrans_rd         : std_logic_vector(3 downto 0); -- Numero de registre de destination (Read port)

  -- Register File (RF) read ports
  signal radr1   : std_logic_vector(3 downto 0);
  signal rdata1  : std_logic_vector(31 downto 0);
  signal rvalid1 : std_logic;

  signal radr2   : std_logic_vector(3 downto 0);
  signal rdata2  : std_logic_vector(31 downto 0);
  signal rvalid2 : std_logic;

  signal radr3   : std_logic_vector(3 downto 0);
  signal rdata3  : std_logic_vector(31 downto 0);
  signal rvalid3 : std_logic;

  -- Register File (RF) inval ports
  signal inval_exe_adr : std_logic_vector(3 downto 0);
  signal inval_exe     : std_logic;

  signal inval_mem_adr : std_logic_vector(3 downto 0);
  signal inval_mem     : std_logic;

  -- Flags
  signal cry  : std_logic;
  signal zero : std_logic;
  signal neg  : std_logic;
  signal ovr  : std_logic;

  signal reg_cznv : std_logic;
  signal reg_vv   : std_logic;

  signal inval_czn : std_logic; -- Signal d'invalidation
  signal inval_ovr : std_logic; -- Signal d'invalidation

  -- Program Coounter (PC)
  signal reg_pc  : std_logic_vector(31 downto 0);
  signal reg_pcv : std_logic; -- Valid bit
  signal inc_pc  : std_logic;

  -- FIFOs
  signal dec2if_full : std_logic; -- Operands vers EXEC
  signal dec2if_push : std_logic;

  signal dec2exe_full : std_logic;
  signal dec2exe_push : std_logic;

  signal if2dec_pop : std_logic;

  -- Exec  operands
  signal op1      : std_logic_vector(31 downto 0);
  signal op2      : std_logic_vector(31 downto 0);
  signal alu_dest : std_logic_vector(3 downto 0);
  signal alu_wb   : std_logic;
  signal flag_wb  : std_logic;

  signal offset32 : std_logic_vector(31 downto 0);

  -- Decod to mem via exec
  signal mem_data  : std_logic_vector(31 downto 0);
  signal ld_dest   : std_logic_vector(3 downto 0);
  signal pre_index : std_logic;

  signal mem_lw : std_logic;
  signal mem_lb : std_logic;
  signal mem_sw : std_logic;
  signal mem_sb : std_logic;

  -- Shifter command
  signal shift_lsl : std_logic;
  signal shift_lsr : std_logic;
  signal shift_asr : std_logic;
  signal shift_ror : std_logic;
  signal shift_rrx : std_logic;
  signal shift_val : std_logic_vector(4 downto 0);
  signal cy        : std_logic;

  -- Alu operand selection
  signal comp_op1 : std_logic;
  signal comp_op2 : std_logic;
  signal alu_cy   : std_logic;

  -- Alu command
  signal alu_cmd : std_logic_vector(1 downto 0);

  -- DECOD FSM

  type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
  signal cur_state, next_state : state_type;

  signal debug_state : std_logic_vector(3 downto 0) := X"0";

begin

  dec2exec : fifo_127b
  port map
  (
    din(126)           => pre_index,
    din(125 downto 94) => op1,
    din(93 downto 62)  => op2,
    din(61 downto 58)  => alu_dest,
    din(57)            => alu_wb,
    din(56)            => flag_wb,

    din(55 downto 24) => rdata3,
    din(23 downto 20) => ld_dest,
    din(19)           => mem_lw,
    din(18)           => mem_lb,
    din(17)           => mem_sw,
    din(16)           => mem_sb,

    din(15)          => shift_lsl,
    din(14)          => shift_lsr,
    din(13)          => shift_asr,
    din(12)          => shift_ror,
    din(11)          => shift_rrx,
    din(10 downto 6) => shift_val,
    din(5)           => cry,

    din(4) => comp_op1,
    din(3) => comp_op2,
    din(2) => alu_cy,

    din(1 downto 0) => alu_cmd,

    dout(126)           => dec_pre_index,
    dout(125 downto 94) => dec_op1,
    dout(93 downto 62)  => dec_op2,
    dout(61 downto 58)  => dec_exe_dest,
    dout(57)            => dec_exe_wb,
    dout(56)            => dec_flag_wb,

    dout(55 downto 24) => dec_mem_data,
    dout(23 downto 20) => dec_mem_dest,
    dout(19)           => dec_mem_lw,
    dout(18)           => dec_mem_lb,
    dout(17)           => dec_mem_sw,
    dout(16)           => dec_mem_sb,

    dout(15)          => dec_shift_lsl,
    dout(14)          => dec_shift_lsr,
    dout(13)          => dec_shift_asr,
    dout(12)          => dec_shift_ror,
    dout(11)          => dec_shift_rrx,
    dout(10 downto 6) => dec_shift_val,
    dout(5)           => dec_cy,

    dout(4) => dec_comp_op1,
    dout(3) => dec_comp_op2,
    dout(2) => dec_alu_cy,

    dout(1 downto 0) => dec_alu_cmd,

    push => dec2exe_push,
    pop  => exe_pop,

    empty => dec2exe_empty,
    full  => dec2exe_full,

    reset_n => reset_n,
    ck      => ck,
    vdd     => vdd,
    vss     => vss);

  dec2if : fifo_32b
  port
  map (din => reg_pc,
  dout     => dec_pc,

  push => dec2if_push,
  pop  => if_pop,

  empty => dec2if_empty,
  full  => dec2if_full,

  reset_n => reset_n,
  ck      => ck,
  vdd     => vdd,
  vss     => vss);

  reg_inst : reg
  port
  map(wdata1 => exe_res,
  wadr1      => exe_dest,
  wen1       => exe_wb,

  wdata2 => mem_res,
  wadr2  => mem_dest,
  wen2   => mem_wb,

  wcry    => exe_c,
  wzero   => exe_z,
  wneg    => exe_n,
  wovr    => exe_v,
  cspr_wb => exe_flag_wb,

  reg_rd1 => rdata1,
  radr1   => radr1,
  reg_v1  => rvalid1,

  reg_rd2 => rdata2,
  radr2   => radr2,
  reg_v2  => rvalid2,

  reg_rd3 => rdata3,
  radr3   => radr3,
  reg_v3  => rvalid3,

  reg_cry  => cry,
  reg_zero => zero,
  reg_neg  => neg,
  reg_ovr  => ovr,

  reg_cznv => reg_cznv,
  reg_vv   => reg_vv,

  inval_adr1 => inval_exe_adr,
  inval1     => inval_exe,

  inval_adr2 => inval_mem_adr,
  inval2     => inval_mem,

  inval_czn => inval_czn,
  inval_ovr => inval_ovr,

  reg_pc  => reg_pc,
  reg_pcv => reg_pcv,
  inc_pc  => inc_pc,

  ck      => ck,
  reset_n => reset_n,
  vdd     => vdd,
  vss     => vss);

  ---- Execution condition (Bits 31 downto 28)
  -- 0000 - x"0" : EQ - (Z = 1)
  -- 0001 - x"1" : NE - (Z = 0)
  -- 0010 - x"2" : HS/CS - (C = 1)
  -- 0011 - x"3" : LO/CC - (C = 0)
  -- 0100 - x"4" : MI - (N = 1)
  -- 0101 - x"5" : PL - (N = 0)
  -- 0110 - x"6" : VS - (V = 1)
  -- 0111 - x"7" : VC - (V = 0)
  -- 1000 - x"8" : HI - (C = 1) AND (Z = 0)
  -- 1001 - x"9" : LS - (C = 0) OR (Z = 1)
  -- 1010 - x"A" : GE - superieur ou egal
  -- 1011 - x"B" : LT - strictement inferieur
  -- 1100 - x"C" : GT - strictement superieur
  -- 1101 - x"D" : LE - inferieur ou egal
  -- 1110 - x"E" : AL - toujours
  -- 1111 - x"F" : NV - reserve

  cond <= '1' when
    (if_ir(31 downto 28) = X"0" and zero = '1') or
    (if_ir(31 downto 28) = X"1" and zero = '0') or
    (if_ir(31 downto 28) = X"2" and cry = '1') or
    (if_ir(31 downto 28) = X"3" and cry = '0') or
    (if_ir(31 downto 28) = X"4" and neg = '1') or
    (if_ir(31 downto 28) = X"5" and neg = '0') or
    (if_ir(31 downto 28) = X"6" and ovr = '1') or
    (if_ir(31 downto 28) = X"7" and ovr = '0') or
    (if_ir(31 downto 28) = X"8" and (cry = '1' and zero = '0')) or
    (if_ir(31 downto 28) = X"9" and (cry = '0' or zero = '1')) or
    (if_ir(31 downto 28) = X"A" and neg = ovr) or
    (if_ir(31 downto 28) = X"B" and neg /= ovr) or
    (if_ir(31 downto 28) = X"C" and (zero = '0' and neg = ovr)) or
    (if_ir(31 downto 28) = X"D" and (zero = '1' or neg /= ovr)) or
    (if_ir(31 downto 28) = X"E") else
    '0';

  -- Verify CPSR validity bits
  condv <= '1' when
    (if_ir(31 downto 28) = x"0" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"1" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"2" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"3" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"4" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"5" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"6" and reg_vv = '1') or
    (if_ir(31 downto 28) = x"7" and reg_vv = '1') or
    (if_ir(31 downto 28) = x"8" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"9" and reg_cznv = '1') or
    (if_ir(31 downto 28) = x"A" and reg_cznv = '1' and reg_vv = '1') or
    (if_ir(31 downto 28) = x"B" and reg_cznv = '1' and reg_vv = '1') or
    (if_ir(31 downto 28) = x"C" and reg_cznv = '1' and reg_vv = '1') or
    (if_ir(31 downto 28) = x"D" and reg_cznv = '1' and reg_vv = '1') or
    (if_ir(31 downto 28) = x"E") else
    '0';

  ---- Instruction Types
  -- Data Processing (Bits 27 downto 26) = "00"
  regop_t <= '1' when
    (if_ir(27 downto 26) = b"00" and
    mult_t = '0' and
    swap_t = '0') else
    '0';
  -- Multiplication (Bits 27 downto 22) = "000000" and (Bits 7 downto 4) = "1001"
  mult_t <= '1' when
    (if_ir(27 downto 22) = b"000000" and
    if_ir(7 downto 4) = b"1001") else
    '0';
  -- Swap (Bits 27 downto 23) = "00010" and (Bits 11 downto 4) = "00001001"
  swap_t <= '1' when
    (if_ir(27 downto 23) = b"00010" and
    if_ir(11 downto 4) = b"00001001") else
    '0';
  -- Branch (Bits 27 downto 25) = "101"
  branch_t <= '1' when
    (if_ir(27 downto 25) = b"101") else
    '0';
  -- Simple memory access (Bits 27 downto 26) = "01"
  trans_t <= '1' when
    (if_ir(27 downto 26) = b"01") else
    '0';
  -- Multiple memory access (Bits 27 downto 25) = "100"
  mtrans_t <= '1' when
    (if_ir(27 downto 25) = b"100") else
    '0';

  ---- OPCODES
  ---- Decod regop Opcodes (Bits 24 downto 21)
  -- 0000 - x"0" : AND : Rd <= Rn and Op2
  -- 0001 - x"1" : EOR : Rd <= Rn xor Op2
  -- 0010 - x"2" : SUB : Rd <= Rn − Op2
  -- 0011 - x"3" : RSB : Rd <= Op2 − Rn
  -- 0100 - x"4" : ADD : Rd <= Rn + Op2
  -- 0101 - x"5" : ADC : Rd <= Rn + Op2 + C
  -- 0110 - x"6" : SBC : Rd <= Rn − Op2 + C − 1
  -- 0111 - x"7" : RSC : Rd <= Op2 − Rn + C − 1
  -- 1000 - x"8" : TST : Positionne les flags pour Rn and Op2
  -- 1001 - x"9" : TEQ : Positionne les flags pour Rn xor Op2
  -- 1010 - x"A" : CMP : Positionne les flags pour Rn − Op2
  -- 1011 - x"B" : CMN : Positionne les flags pour Rn + Op2
  -- 1100 - x"C" : ORR : Rd <= Rn or Op2
  -- 1101 - x"D" : MOV : Rd <= Op2
  -- 1110 - x"E" : BIC : Rd <= Rn and not Op2
  -- 1111 - x"F" : MVN : Rd <= not Op2

  and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"0" else
    '0';
  eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"1" else
    '0';
  sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"2" else
    '0';
  rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"3" else
    '0';
  add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"4" else
    '0';
  adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"5" else
    '0';
  sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"6" else
    '0';
  rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"7" else
    '0';
  tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"8" else
    '0';
  teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"9" else
    '0';
  cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"A" else
    '0';
  cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"B" else
    '0';
  orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"C" else
    '0';
  mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"D" else
    '0';
  bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"E" else
    '0';
  mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = x"F" else
    '0';

  -- Mult instruction
  mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else
    '0';
  mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else
    '0';

  -- Simple Transfer instruction
  ldr_i <= '1' when trans_t = '1' and if_ir(20) = '1' and if_ir(22) = '0' else
    '0';
  str_i <= '1' when trans_t = '1' and if_ir(20) = '0' and if_ir(22) = '0' else
    '0';
  ldrb_i <= '1' when trans_t = '1' and if_ir(20) = '1' and if_ir(22) = '1' else
    '0';
  strb_i <= '1' when trans_t = '1' and if_ir(20) = '0' and if_ir(22) = '1' else
    '0';

  -- Multiple Transfer instruction
  ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else
    '0';
  stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else
    '0';

  -- Branch instruction
  b_i <= '1' when branch_t = '1' and if_ir(24) = '0' else
    '0';
  bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else
    '0';

  ---- Decode interface operands TODO:
  op1 <=
    reg_pc when (branch_t = '1') else
    exe_res when (mtrans_shift = '1') else
    rdata1 when (regop_t = '1' and mov_i = '0' and mvn_i = '0') or (trans_t = '1') or (mtrans_t = '1') else
    x"00000000";

  offset32 <= x"0000_0000"; -- TODO: Branch

  op2 <= -- TODO:
    offset32 when (branch_t = '1') else
    rdata2;

  -- ALU destination Rd
  alu_dest <=
    if_ir(15 downto 12) when regop_t = '1' else -- Data Processing 
    if_ir(15 downto 12) when trans_t = '1' else -- Simple memory access 
    if_ir(19 downto 16) when mult_t = '1';      -- Multiplication

  -- ALU Writeback enabled
  alu_wb <=
    '1' when mult_t = '1' else                                                                  -- Multiplication
    '1' when regop_t = '1' and tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0' else -- Data Processing (Writes to Rd)
    '1' when branch_t = '1' else                                                                -- Branch (writes to PC)
    '1' when trans_t = '1' and if_ir(21) = '1' else                                             -- Simple memory access with writeback
    '1' when mtrans_t = '1' and if_ir(21) = '1' else                                            -- Simple memory access with writeback
    '0';

  -- Update flags 
  flag_wb <=
    if_ir(20) when regop_t = '1' else -- Data Processing, bit S = '1'
    '0';

  ---- Read addresses for registers
  -- Read address 1
  radr1 <=
    if_ir(19 downto 16) when regop_t = '1' else -- Data Processing 
    if_ir(19 downto 16) when mult_t = '1' else  -- Multiplication
    if_ir(19 downto 16) when trans_t = '1' else -- Simple memory access
    if_ir(19 downto 16) when mtrans_t = '1';    -- Multiple memory access

  -- Read address 2 = Rm
  radr2 <=
    if_ir(3 downto 0) when regop_t = '1' and if_ir(25) = '0' else -- Op2 Registre
    if_ir(3 downto 0) when trans_t = '1' and if_ir(25) = '1' else -- Simple memory access
    mtrans_rd when mtrans_t = '1' else
    "0000";

  -- Read address 3 = 
  radr3 <=
    mtrans_rd when mtrans_t = '1' else          -- Multiple memory access
    if_ir(15 downto 12) when trans_t = '1' else -- Simple memory access
    if_ir(11 downto 8);                         -- Shift

  -- Reg Invalid TODO:
  inval_exe_adr <= ... else
    if_ir(15 downto 12);

  inval_exe <= '1' when ...
    '0';

  inval_mem_adr <= ...
    mtrans_rd;

  inval_mem <= '1' when ... else
    '0';

  inval_czn <=
    inval_ovr <=

    -- operand validite TODO:

    operv <= '1' when
    '0';

  -- Decode to mem interface TODO:
  ld_dest   <=
    pre_index <=

    mem_lw <=
    mem_lb <= ldrb_i;
  mem_sw <=
    mem_sb <= strb_i;

  -- Shifter command

  shift_lsl <= '1' when (regop_t = '1' and if_ir(6 downto 5) = "00" and if_ir(25) = '0') else -- Register operation (I = 0)
    '1' when (trans_t = '1' and if_ir(6 downto 5) = "00" and if_ir(25) = '1') else              -- Simple transfer b25 = 1 with shift
    '1' when (branch_t = '1') else                                                              -- Branch Instruction
    '0';

  shift_lsr <= '1' when (regop_t = '1' and if_ir(6 downto 5) = "01" and if_ir(25) = '0') else -- Register operation (I = 0)
    '1' when (trans_t = '1' and if_ir(6 downto 5) = "01" and if_ir(25) = '1') else              -- Simple transfer b25 = 1 with shift
    '0';

  shift_asr <= '1' when (regop_t = '1' and if_ir(6 downto 5) = "10" and if_ir(25) = '0') else -- Register operation (I = 0)
    '1' when (trans_t = '1' and if_ir(6 downto 5) = "10" and if_ir(25) = '1') else              -- Simple transfer b25 = 1 with shift
    '0';

  shift_ror <= '1' when (regop_t = '1' and if_ir(6 downto 5) = "11" and if_ir(25) = '0' and shift_rrx = '0') else -- Register operation (I = 0)
    '1' when (trans_t = '1' and if_ir(6 downto 5) = "11" and if_ir(25) = '1' and shift_rrx = '0') else              -- Simple transfer b25 = 1 with shift
    '1' when regop_t = '1' and if_ir(25) = '1' else                                                                 -- Extension sur 32 bits de l’imm ́ediat 8 bits par rotation
    '0';

  -- RRX shifts are only executed when the rotation/shift value is 0 for a ROR
  shift_rrx <= '1' when (if_ir(6 downto 5) = "11" and regop_t = '1' and if_ir(25) = '0' and shift_val = "00000") else -- Register operation (I = 0)
    '1' when (if_ir(6 downto 5) = "11" and trans_t = '1' and if_ir(25) = '1' and shift_val = "00000") else              -- Simple transfer b25 = 1 with shift
    '0';

  -- Shift/Rotation values are found on the bits 11 - 7 TODO: Complete
  shift_val <= "00010" when (branch_t = '1') else                                     -- Branch instructions multiply offset x4 (<< 2)
    if_ir(11 downto 7) when (trans_t = '1' and if_ir(25) = '1') else                    -- Simple transfer (bit 25 I = 1)
    if_ir(11 downto 8) & '0' when (regop_t = '1' and if_ir(25) = '0') else              -- Data processing with immediate (ignore bit 4)
    if_ir(11 downto 7) when (regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '0') else -- Register operation (bit 25 I = 0)
    rdata3(4 downto 0) when (regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '1') else -- Register operation (bit 25 I = 0)
    "00000";

  -- Alu operand selection
  comp_op1 <= '1' when rsb_i = '1' or
    comp_op2 <= '1' when sub_i = '1' or

    alu_cy <= '1' when sub_i = '1' or

    -- Alu command

    alu_cmd <= "11" when --TODO: else
    "00";
  -- Mtrans reg list

  process (ck)
  begin
    if (rising_edge(ck)) then
      -- TODO: 
    end if;
  end process;

  mtrans_mask_shift <= X"FFFE" when if_ir(0) = '1' and mtrans_mask(0) = '1' else
    X"FFFC" when if_ir(1) = '1' and mtrans_mask(1) = '1' else
    X"FFF8" when if_ir(2) = '1' and mtrans_mask(2) = '1' else
    X"FFF0" when if_ir(3) = '1' and mtrans_mask(3) = '1' else
    X"FFE0" when if_ir(4) = '1' and mtrans_mask(4) = '1' else
    X"FFC0" when if_ir(5) = '1' and mtrans_mask(5) = '1' else
    X"FF80" when if_ir(6) = '1' and mtrans_mask(6) = '1' else
    X"FF00" when if_ir(7) = '1' and mtrans_mask(7) = '1' else
    X"FE00" when if_ir(8) = '1' and mtrans_mask(8) = '1' else
    X"FC00" when if_ir(9) = '1' and mtrans_mask(9) = '1' else
    X"F800" when if_ir(10) = '1' and mtrans_mask(10) = '1' else
    X"F000" when if_ir(11) = '1' and mtrans_mask(11) = '1' else
    X"E000" when if_ir(12) = '1' and mtrans_mask(12) = '1' else
    X"C000" when if_ir(13) = '1' and mtrans_mask(13) = '1' else
    X"8000" when if_ir(14) = '1' and mtrans_mask(14) = '1' else
    X"0000";

  mtrans_list <= if_ir(15 downto 0) and mtrans_mask;

  process (mtrans_list)
  begin
  end process;

  mtrans_1un <= '1' when mtrans_nbr = "00001" else
    '0';

  mtrans_rd <= X"0" when mtrans_list(0) = '1' else
    X"1" when mtrans_list(1) = '1' else
    X"2" when mtrans_list(2) = '1' else
    X"3" when mtrans_list(3) = '1' else
    X"4" when mtrans_list(4) = '1' else
    X"5" when mtrans_list(5) = '1' else
    X"6" when mtrans_list(6) = '1' else
    X"7" when mtrans_list(7) = '1' else
    X"8" when mtrans_list(8) = '1' else
    X"9" when mtrans_list(9) = '1' else
    X"A" when mtrans_list(10) = '1' else
    X"B" when mtrans_list(11) = '1' else
    X"C" when mtrans_list(12) = '1' else
    X"D" when mtrans_list(13) = '1' else
    X"E" when mtrans_list(14) = '1' else
    X"F";

  -- FSM

  process (ck)
  begin

    if (rising_edge(ck)) then
      if (reset_n = '0') then
        cur_state <= FETCH;
      else
        cur_state <= next_state;
      end if;
    end if;

  end process;

  inc_pc <= dec2if_push;

  -- Mealy type Finite State Machine
  -- states: (FETCH, RUN, BRANCH, LINK, MTRANS)
  process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty, reg_pcv, bl_i,
    branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
    mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd, mtrans_mask_shift)
  begin
    case cur_state is

      when FETCH =>
        -- TODO:
        debug_state <= X"1";

        if2dec_pop      <= '0';
        dec2exe_push    <= '0';
        blink           <= '0';
        mtrans_shift    <= '0';
        mtrans_loop_adr <= '0';

        if dec2if_full = '0' and reg_pcv = '1' and if2dec_empty = '0' then
          next_state <= RUN;
        end if;

      when RUN =>
        debug_state <= X"2";
        -- TODO: 

      when BRANCH =>
        debug_state <= X"3";
        -- TODO: 

      when LINK =>
        debug_state <= X"4";
        -- TODO: 

      when MTRANS =>
        debug_state <= X"5";
        -- TODO: 

    end case;
  end process;

  dec_pop <= if2dec_pop;
end Behavior;