library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
entity WB_Stage is
  Port(opcode: in std_logic_vector(3 downto 0);
       alu_in: in std_logic_vector(31 downto 0);
       mem_in: in std_logic_vector(31 downto 0);
       result: out std_logic_vector(31 downto 0));
end WB_Stage;
architecture rtl of WB_Stage is
begin
  process(opcode, alu_in, mem_in)
  begin
    if opcode="1011" then
      result<=mem_in;
    else
      result<=alu_in;
    end if;
  end process;
end rtl;
