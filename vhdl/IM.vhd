library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Driven by rising edge of clk50
-- One Read costs two cycles.
-- Function : Read Instruction from Sram

entity IM is
  
  port (
    clk50     : in    std_logic;
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

  currInstr <= "01101" & "001" & "00000100" when LowPC = "0000" else
               -- LI R1 0x4.  R1 = 0x4

               "01101" & "010" & "00011001" when LowPC = "0001" else
               -- LI R2 0x19  R2 = 0x19
               
               "11011" & "001" & "010" & "00011" when LowPC = "0010" else
               -- SW R1 R2 0x3    MEM(4 + 3) = 0x19

               "10011" & "001" & "011" & "00011" when LowPC = "0011" else
               -- LW R1 R3 0x3    R3 = MEM(4 + 3) = 0x19

               "11101" & "100" & "011" & "01111" when LowPC = "0100" else
               -- NOT R4 R3      R4 = ~R3 = 0xFFE6

               "00110" & "101" & "100" & "00100" when LowPC = "0101" else
               -- SLLV R5 R4     R5 = R4 << 4 = 0xFE60
               
               X"0800";

  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      case state is
        when '0' =>
          Ram2Data <= (others => 'Z');
          Ram2Addr <= "00" & PC;
          LowPC <= PC(3 downto 0);
          state <= '1';
        when '1' =>
--          instruc <= Ram2Data;
          instruc <= currInstr;
          state <= '0';
        when others => null;
      end case;
    end if;
  end process;
  
  --clk_addr <= CPU_CLK after 20 ns;
  --clk_out <= CPU_CLK after 20 ns;

  --process (CPU_CLK)
  --begin  -- process
  --  if rising_edge(CPU_CLK) then
  --    Ram2Data <= (others => 'Z');
  --  end if;
  --end process;

  --process (clk_addr)
  --begin  -- process
  --  if rising_edge(clk_addr) then
  --    Ram2Addr <= "00" & PC;
  --  end if;
  --end process;

  --process (clk_out)
  --begin  -- process
  --  if rising_edge(clk_out) then
  --    instruc <= Ram2Data;
  --  end if;
  --end process;
  
end IM_Arch;
