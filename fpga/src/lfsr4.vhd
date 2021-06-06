-- from https://www.engineersgarage.com/feed-back-register-in-vhdl/
-- modified for 4 bits
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY LFSR4 IS
  PORT (Clk, Rst: IN std_logic;
        output: OUT std_logic_vector (3 DOWNTO 0));
END LFSR4;

ARCHITECTURE LFSR4_beh OF LFSR4 IS
  SIGNAL Currstate, Nextstate: std_logic_vector (3 DOWNTO 0);
  SIGNAL feedback: std_logic;
BEGIN

  StateReg: PROCESS (Clk,Rst)
  BEGIN
    IF (Rst = '1') THEN
      Currstate <= (0 => '1', OTHERS =>'0');
    ELSIF (Clk = '1' AND Clk'EVENT) THEN
      Currstate <= Nextstate;
    END IF;
  END PROCESS;
  
  feedback <= Currstate(3) XOR Currstate(1) XOR Currstate(0);
  Nextstate <= feedback & Currstate(3 DOWNTO 1);
  output <= Currstate;

END LFSR4_beh;