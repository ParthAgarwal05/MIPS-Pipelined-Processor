library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_tb is
end main_tb;

architecture tb of main_tb is
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  constant CLK_PERIOD : time := 20 ns;

  component main is
    Port(clk : in std_logic; reset : in std_logic);
  end component;

  signal dut_clk   : std_logic;
  signal dut_reset : std_logic;

begin
  DUT: main port map(clk => clk, reset => reset);

  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;

  reset_process: process
  begin
    reset <= '1';
    wait for CLK_PERIOD * 2;
    reset <= '0';
    wait;
  end process;

  stim_process: process
  begin
    wait for CLK_PERIOD * 50;
    report "Simulation complete";
    wait;
  end process;
end tb;
