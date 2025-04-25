library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
entity MEM_Stage is
  Port(clk: in std_logic;
       opcode: in std_logic_vector(3 downto 0);
       alu_in: in std_logic_vector(31 downto 0);
       rt_data: in std_logic_vector(31 downto 0);
       mem_data: out std_logic_vector(31 downto 0);
       alu_out: out std_logic_vector(31 downto 0));
end MEM_Stage;
architecture rtl of MEM_Stage is
  type dmem_t is array(0 to 255) of std_logic_vector(31 downto 0);
  signal dmem: dmem_t := (others=>(others=>'0'));
  signal opcode_r: std_logic_vector(3 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      opcode_r <= opcode;
      if opcode="1100" then -- sw
        dmem(to_integer(unsigned(alu_in(9 downto 0)))) <= rt_data;
      end if;
    alu_out <= alu_in;
    end if;
  end process;
  mem_data <= dmem(to_integer(unsigned(alu_in(9 downto 0)))) when opcode="1011" else (others=>'0');
  
end rtl;