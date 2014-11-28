library ieee;
use ieee.std_logic_1164.all;

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

  signal state : std_logic := "00";
  
begin  -- IM_Arch

  Ram2EN <= '0';
  Ram2OE <= '0';
  Ram2RW <= '1';

  process (clk50)
  begin  -- process
    if clk50'event then
      case state is
        when "00" =>
          Ram2Data <= (others => 'Z');
          state <= "01";
        when "01" =>
          Ram2Addr <= "00" & PC;
          state <= "10";
        when "10" =>
          state <= "11"'
        when "11" =>
          instruc <= Ram2Data;
          Ram2Data <= (others => 'Z');
          state <= "00";
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
