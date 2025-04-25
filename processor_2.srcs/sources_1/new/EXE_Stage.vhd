library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
entity EXE_Stage is
  Port(opcode: in std_logic_vector(3 downto 0);
       rs_data, rt_data, imm: in std_logic_vector(31 downto 0);
       jaddr: in std_logic_vector(25 downto 0);
       PC_in: in std_logic_vector(31 downto 0);
       alu_result: out std_logic_vector(31 downto 0);
       branch_taken: out std_logic;
       branch_target: out std_logic_vector(31 downto 0);
       jump_taken: out std_logic;
       jump_target: out std_logic_vector(31 downto 0));
end EXE_Stage;
architecture rtl of EXE_Stage is  
begin
  process(opcode, rs_data, rt_data, imm, jaddr, PC_in)
  variable offset: signed(31 downto 0);
  begin
    branch_taken <= '0'; jump_taken <= '0';
    alu_result <= (others=>'0');
    case opcode is
      when "0000" => alu_result <= std_logic_vector(signed(rs_data)+signed(rt_data));
      when "0001" => alu_result <= std_logic_vector(signed(rs_data)-signed(rt_data));
      when "0010" => alu_result <= rs_data and rt_data;
      when "0011" => alu_result <= rs_data or rt_data;
      when "0100" => alu_result <= rs_data xor rt_data;
      when "0101" =>  -- rs >= rt
      if (signed(rs_data) >= signed(rt_data)) then
        alu_result <= (others => '0');
      else
        alu_result <= x"00000001";
      end if;
      when "0110" => alu_result <= std_logic_vector(signed(rs_data)+signed(imm));
      when "0111" =>  -- rs >= imm
      if (signed(rs_data) >= signed(imm)) then
        alu_result <= (others => '0');
      else
        alu_result <= x"00000001";
      end if;
      when "1000" => alu_result <= rs_data and imm;
      when "1001" => alu_result <= rs_data or imm;
      when "1010" => alu_result <= rs_data xor std_logic_vector(unsigned(imm));
      when "1011" | "1100" => alu_result <= std_logic_vector(signed(rs_data)+signed(imm));
      when "1101" =>  -- beq
        if rs_data=rt_data then
          branch_taken<='1';
          offset := signed(imm) sll 2;
          branch_target <= std_logic_vector(signed(PC_in)+offset+4);
        end if;
      when "1110" => -- bne
        if rs_data/=rt_data then
          branch_taken<='1';
          offset := signed(imm) sll 2;
          branch_target <= std_logic_vector(signed(PC_in)+offset+4);
        end if;
      when "1111" => -- j
        jump_taken<='1';
        jump_target<= PC_in(31 downto 26)&jaddr;
      when others => null;
    end case;
  end process;
end rtl;