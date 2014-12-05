library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Driven by rising edge of clk
-- One Read costs two cycles.
-- Function : Read Instruction from Sram

entity IM is
  
  port (
    clk       : in    std_logic;
    PC        : in    std_logic_vector(15 downto 0);
    Ram2Addr  : out   std_logic_vector(17 downto 0);
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2OE    : out   std_logic;
    Ram2RW    : out   std_logic;
    Ram2EN    : out   std_logic;
    instruc   : out   std_logic_vector(15 downto 0)
    );

end IM;

architecture IM_Arch of IM is

  signal state : std_logic := '0';
  signal currInstr : std_logic_vector(15 downto 0) := X"0800";
  signal LowPC : std_logic_vector(3 downto 0) := "0000";
  
begin  -- IM_Arch

  Ram2EN <= '0';
  Ram2OE <= '0';
  Ram2RW <= '1';

  --currInstr <= "01101" & "001" & "00000100" when LowPC = "0000" else
  --              LI R1 0x4.  R1 = 0x4

  --             "01101" & "010" & "00011001" when LowPC = "0001" else
  --              LI R2 0x19  R2 = 0x19
               
  --             "01101" & "011" & "01000101" when LowPC = "0010" else
  --              LI R3 0x19  R3 = 0x45
               
  --             "11011" & "001" & "011" & "00100" when LowPC = "0011" else
  --              SW R1 R3 0x4    MEM(R1 + 4) = R3 = 0x45

  --             "10011" & "001" & "101" & "00100" when LowPC = "0100" else
  --              LW R1 R5 0x4    R5 = MEM(R1 + 4) = 0x45
               
  --             X"0800";

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      case state is
        when '0' =>
          Ram2Data <= (others => 'Z');
          Ram2Addr <= "00" & PC;
          LowPC <= PC(3 downto 0);
          state <= '1';
        when '1' =>
          instruc <= Ram2Data;
--          instruc <= currInstr;
          state <= '0';
        when others => null;
      end case;
    end if;
  end process;
  
end IM_Arch;
