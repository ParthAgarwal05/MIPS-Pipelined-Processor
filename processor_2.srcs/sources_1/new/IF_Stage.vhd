library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
entity IF_Stage is
  Port(clk, reset: in std_logic;
       branch_taken: in std_logic;
       branch_target: in std_logic_vector(31 downto 0);
       jump_taken: in std_logic;
       jump_target: in std_logic_vector(31 downto 0);
       PC: out std_logic_vector(31 downto 0);
       instruction: out std_logic_vector(31 downto 0));
end IF_Stage;
architecture rtl of IF_Stage is
  signal PC_reg: std_logic_vector(31 downto 0);
  type imem_t is array(0 to 255) of std_logic_vector(31 downto 0);
  signal imem: imem_t := (
        -- lw r4,4(r2) at address 0: loads from D-mem[ r2 + 4 ] into r4
--for sw, lw, add instruction
--        0 => x"B1100004",
--        1 => x"C10C0000",  -- sw r3, 0(r2) 
--        -- NOP at address 1 for visibility
--        2 => x"00000000",
--for b type uncomment following 3
--        0  => x"D6BC003F",       -- beq r13, r15, branch to PC+60 (index 16)
--        1  => x"ABCDEF01",       -- Should be skipped if branch is taken
--        16 => x"DEADBEEF",       -- Branch target
--for j type uncomment following 3
--        0 => x"F0000100",       -- J-type: jump to address 16
--        1 => x"ABCDEF01",       -- Another dummy instruction (should be skipped if jump works)
--        16 => x"DEADBEEF",  -- Target of the jump
--for xori
        0 => "10100001000001000000000000001100",
        others => (others => '0')
    );
begin
  process(clk, reset)
  begin
    if reset='1' then
      PC_reg <= (others=>'0');
    elsif rising_edge(clk) then
      if jump_taken='1' then
        PC_reg <= jump_target;
      elsif branch_taken='1' then
        PC_reg <= branch_target;
      else
        PC_reg <= std_logic_vector(unsigned(PC_reg) + 4);
      end if;
    end if;
  end process;
  instruction <= imem(to_integer(unsigned(PC_reg(9 downto 2))));
  PC <= PC_reg;
end rtl;