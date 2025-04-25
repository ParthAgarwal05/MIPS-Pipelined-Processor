library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
  Port (
    clk    : in  std_logic;
    reset  : in  std_logic
  );
end main;

architecture rtl of main is
  signal PC         : std_logic_vector(31 downto 0);
  signal instr_IF   : std_logic_vector(31 downto 0);

  signal IFID_PC    : std_logic_vector(31 downto 0);
  signal IFID_instr : std_logic_vector(31 downto 0);

  signal opcode_ID  : std_logic_vector(3 downto 0);
  signal rs_data_ID : std_logic_vector(31 downto 0);
  signal rt_data_ID : std_logic_vector(31 downto 0);
  signal imm_ID     : std_logic_vector(31 downto 0);
  signal jaddr_ID   : std_logic_vector(25 downto 0);
  signal PC_ID      : std_logic_vector(31 downto 0);

  signal IDEX_opcode  : std_logic_vector(3 downto 0);
  signal IDEX_rs_data : std_logic_vector(31 downto 0);
  signal IDEX_rt_data : std_logic_vector(31 downto 0);
  signal IDEX_imm     : std_logic_vector(31 downto 0);
  signal IDEX_jaddr   : std_logic_vector(25 downto 0);
  signal IDEX_PC      : std_logic_vector(31 downto 0);

  signal alu_EX       : std_logic_vector(31 downto 0);
  signal brTaken_EX   : std_logic;
  signal brTarget_EX  : std_logic_vector(31 downto 0);
  signal jTaken_EX    : std_logic;
  signal jTarget_EX   : std_logic_vector(31 downto 0);

  signal EXMEM_alu      : std_logic_vector(31 downto 0);
  signal EXMEM_rt_data  : std_logic_vector(31 downto 0);
  signal EXMEM_brTaken  : std_logic;
  signal EXMEM_brTgt    : std_logic_vector(31 downto 0);
  signal EXMEM_jTaken   : std_logic;
  signal EXMEM_jTgt     : std_logic_vector(31 downto 0);
  signal EXMEM_opcode   : std_logic_vector(3 downto 0);

  signal memData_MEM    : std_logic_vector(31 downto 0);

  signal MEMWB_alu    : std_logic_vector(31 downto 0);
  signal MEMWB_mem    : std_logic_vector(31 downto 0);
  signal MEMWB_opcode : std_logic_vector(3 downto 0);
  signal MEMWB_rtdata : std_logic_vector(31 downto 0);

  signal wb_result    : std_logic_vector(31 downto 0);

begin
  IF_inst: entity work.IF_Stage
    port map(clk => clk, reset => reset,
             branch_taken => EXMEM_brTaken,
             branch_target => EXMEM_brTgt(31 downto 0),
             jump_taken => EXMEM_jTaken,
             jump_target => EXMEM_jTgt(31 downto 0),
             PC => PC,
             instruction => instr_IF);

  process(clk)
  begin
    if rising_edge(clk) then
      IFID_PC    <= PC;
      IFID_instr <= instr_IF;
    end if;
  end process;

  ID_inst: entity work.ID_Stage
    port map(clk => clk, reset => reset,
             instruction => IFID_instr,
             PC_in => IFID_PC,
             write_enable => '1',      
             write_reg => MEMWB_alu(4 downto 0),
             write_data => wb_result,
             opcode => opcode_ID,
             rs_data => rs_data_ID,
             rt_data => rt_data_ID,
             imm => imm_ID,
             jaddr => jaddr_ID,
             PC_out => PC_ID);

  process(clk)
  begin
    if rising_edge(clk) then
      IDEX_opcode  <= opcode_ID;
      IDEX_rs_data <= rs_data_ID;
      IDEX_rt_data <= rt_data_ID;
      IDEX_imm     <= imm_ID;
      IDEX_jaddr   <= jaddr_ID;
      IDEX_PC      <= PC_ID;
    end if;
  end process;

  EX_inst: entity work.EXE_Stage
    port map(opcode => IDEX_opcode,
             rs_data => IDEX_rs_data,
             rt_data => IDEX_rt_data,
             imm => IDEX_imm,
             jaddr => IDEX_jaddr,
             PC_in => IDEX_PC,
             alu_result => alu_EX,
             branch_taken => brTaken_EX,
             branch_target => brTarget_EX,
             jump_taken => jTaken_EX,
             jump_target => jTarget_EX);

  process(clk)
  begin
    if rising_edge(clk) then
      EXMEM_opcode  <= IDEX_opcode;
      EXMEM_alu     <= alu_EX;
      EXMEM_rt_data <= IDEX_rt_data;
      EXMEM_brTaken <= brTaken_EX;
      EXMEM_brTgt   <= brTarget_EX;
      EXMEM_jTaken  <= jTaken_EX;
      EXMEM_jTgt    <= jTarget_EX;
    end if;
  end process;

  MEM_inst: entity work.MEM_Stage
    port map(clk => clk,
             opcode => EXMEM_opcode,
             alu_in => EXMEM_alu,
             rt_data => EXMEM_rt_data,
             mem_data => memData_MEM,
             alu_out => MEMWB_alu);

  process(clk)
  begin
    if rising_edge(clk) then
      MEMWB_opcode <= EXMEM_opcode;
      MEMWB_alu    <= EXMEM_alu;
      MEMWB_mem    <= memData_MEM;
    end if;
  end process;

  WB_inst: entity work.WB_Stage
    port map(opcode => MEMWB_opcode,
             alu_in => MEMWB_alu,
             mem_in => MEMWB_mem,
             result => wb_result);
end rtl;