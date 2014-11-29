library ieee;
use ieee.std_logic_1164.all;

-- Driven by rising edge of clk50
-- Function : Read / Write Data from Sram1

entity DM is
  
  port (
    clk50     : in    std_logic;
    wMemAddr  : in    std_logic_vector(15 downto 0);
    wMemData  : in    std_logic_vector(15 downto 0);
    MemRead   : in    std_logic;
    MemWrite  : in    std_logic;
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    rdn, wrn  : out    std_logic;
    MemOutput : out   std_logic_vector(15 downto 0)
    );

end DM;

architecture DM_Arch of DM is

  signal state : std_logic := '0';
  
begin  -- DM_Arch

  Ram1EN <= '0';
  Ram1OE <= '0';
  rdn <= '1';
  wrn <= '1';

  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      if MemRead = '1' then
        case state is
          when '0' =>
            Ram1RW <= '1';
            Ram1Data <= (others => 'Z');
            Ram1Addr <= "00" & wMemAddr;
            state <= '1';
          when '1' =>
            Ram1RW <= '1';
            MemOutput <= Ram1Data;
            state <= '0';
          when others => null;
        end case;
      elsif MemWrite = '1' then
        case state is
          when '0' =>
            Ram1RW <= '1';
            Ram1Addr <= "00" & wMemAddr;
            Ram1Data <= wMemData;
            state <= '1';
          when '1' =>
            Ram1RW <= '0';
            state <= '0';
          when others => null;
        end case;
      end if;
    end if;
  end process;
  
end DM_Arch;
