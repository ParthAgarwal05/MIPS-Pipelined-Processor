-- File: ID_Stage.vhd
library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
entity ID_Stage is
  Port(clk, reset: in std_logic;
       instruction: in std_logic_vector(31 downto 0);
       PC_in: in std_logic_vector(31 downto 0);
       write_enable: in std_logic;
       write_reg: in std_logic_vector(4 downto 0);
       write_data: in std_logic_vector(31 downto 0);
       opcode: out std_logic_vector(3 downto 0);
       rs_data: out std_logic_vector(31 downto 0);
       rt_data: out std_logic_vector(31 downto 0);
       imm: out std_logic_vector(31 downto 0);
       jaddr: out std_logic_vector(25 downto 0);
       PC_out: out std_logic_vector(31 downto 0));
end ID_Stage;
architecture rtl of ID_Stage is
  type regfile_t is array(0 to 31) of std_logic_vector(31 downto 0);
  signal regs: regfile_t := (
        0  => x"00000006",  
        1  => x"0000000a",
        2  => x"00000002",  
        3  => x"00000003",
        4  => x"00000004",
        others => (others => '0')
    );

  signal rs_idx, rt_idx: integer range 0 to 31 := 0;
begin

  process(clk, reset)
  begin
    if reset='1' then
    elsif rising_edge(clk) then
      if write_enable = '1' and to_integer(unsigned(write_reg)) /= 0 then
        regs(to_integer(unsigned(write_reg))) <= write_data;
      end if;
    end if;
  end process;

  process(instruction, regs, PC_in)
    variable rs_raw : std_logic_vector(4 downto 0);
    variable rt_raw : std_logic_vector(4 downto 0);
    variable rs_i   : integer;
    variable rt_i   : integer;
  begin
    opcode <= instruction(31 downto 28);
    rs_raw := instruction(27 downto 23);
    rt_raw := instruction(22 downto 18);
    
    rs_i := to_integer(unsigned(rs_raw));
    rt_i := to_integer(unsigned(rt_raw));
    
    if rs_i >= 0 and rs_i <= 31 then
      rs_data <= regs(rs_i);
    else
      rs_data <= (others => '0');
    end if;

    if rt_i >= 0 and rt_i <= 31 then
      rt_data <= regs(rt_i);
    else
      rt_data <= (others => '0');
    end if;

    imm   <= std_logic_vector(resize(signed(instruction(17 downto 2)), 32));
    jaddr <= instruction(27 downto 2);
    PC_out <= PC_in;
  end process;

end rtl;
