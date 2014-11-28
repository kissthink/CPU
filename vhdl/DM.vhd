library ieee;
use ieee.std_logic_1164.all;

-- Driven by rising edge of clk50
-- Function : Read / Write Data from Sram1

entity DM is
  
  port (
    clk50     : in    std_logic;
    rdn, wrn  : in    std_logic;
    wMemAddr  : in    std_logic_vector(15 downto 0);
    wMemData  : in    std_logic_vector(15 downto 0);
    MemRead   : in    std_logic;
    MemWrite  : in    std_logic;
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    MemOutput : out   std_logic_vector(15 downto 0)
    );

end DM;

architecture DM_Arch of DM is

  signal state : std_logic := "00";
  
begin  -- IM_Arch

  Ram1EN <= '0';
  Ram1OE <= '0';
  Ram1RW <= '1';
  rdn <= '1';
  wrn <= '1';

  process (clk50)
  begin  -- process
    if clk50'event then
      if MemRead = '1' then
        case state is
          when "00" =>
            Ram1Data <= (others => 'Z');
            Ram1RW <= '1';
            state <= "01";
          when "01" =>
            Ram1Addr <= "00" & wMemAddr;
            Ram1RW <= '1';
            state <= "10";
          when "10" =>
            MemOutput <= Ram1Data;
            Ram1RW <= '1';
            state <= "11";
          when "11" =>
            Ram1Data <= (others => 'Z');
            Ram1RW <= '1';
            state <= "00";
        end case;
      elsif MemWrite = '1' then
        case state is
          when "00" =>
            Ram1Data <= wMemData;
            Ram1RW <= '1';
            state <= "01";
          when "01" =>
            Ram1Addr <= wMemAddr;
            Ram1RW <= '1';
            state <= "10";
          when "10" =>
            Ram1RW <= '0';
            state <= "11";
          when "11" =>
            Ram1RW <= '1';
            state <= "00";
        end case;
      end if;
    end if;
  end process;
  
end IM_Arch;
