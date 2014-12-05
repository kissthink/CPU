library ieee;
use ieee.std_logic_1164.all;

-- Driven by rising edge of clk
-- Function : Read / Write Data from Sram1

entity DM is
  
  port (
    clk       : in    std_logic;
    wMemAddr  : in    std_logic_vector(15 downto 0);
    wMemData  : in    std_logic_vector(15 downto 0);
    MemRead   : in    std_logic;
    MemWrite  : in    std_logic;
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    rdn, wrn  : out   std_logic;
    tbre      : in    std_logic;
    tsre      : in    std_logic;
    dready    : in    std_logic;
    ComSig    : out   std_logic_vector(1 downto 0);
    MemOutput : out   std_logic_vector(15 downto 0)
    );

end DM;

architecture DM_Arch of DM is

  signal state : std_logic := '0';
  signal wMemAddr_Cache : std_logic_vector(15 downto 0) := X"0000";
  signal wMemData_Cache : std_logic_vector(15 downto 0) := X"0000";
  
begin  -- DM_Arch

  ComSig <= "00" when wMemAddr = X"BF00" and (MemRead = '1' or MemWrite = '1') else
            "01" when wMemAddr = X"BF01" and (MemRead = '1' or MemWrite = '1') else
            "11";

  wMemAddr_Cache <= wMemAddr when rising_edge(clk) and state = '0';

  wMemData_Cache <= wMemData when rising_edge(clk) and state = '0';
  
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      if MemRead = '1' then
        if (state = '0' and wMemAddr = X"BF00") or (state = '1' and wMemAddr_Cache = X"BF00") then
          case state is
            when '0'  =>
              Ram1EN <= '1';
              Ram1OE <= '1';
              rdn <= '0';
              wrn <= '1';
              state <= '1';
            when '1'  =>
              MemOutput <= Ram1Data;
              Ram1Data <= (others => 'Z');
              Ram1EN <= '1';
              Ram1OE <= '1';
              rdn <= '1';
              wrn <= '1';
              state <= '0';
            when others => null;
          end case;
        elsif (state = '0' and wMemAddr = X"BF01") or (state = '1' and wMemAddr_Cache = X"BF01") then
          MemOutput <= X"000" & "00" & dready & (tbre and tsre);
          Ram1Data <= (others => 'Z');
          rdn <= '1';
          wrn <= '1';
          Ram1EN <= '1';
          Ram1OE <= '1';
        else
          case state is
            when '0' =>
              Ram1RW <= '1';
              Ram1Data <= (others => 'Z');
              Ram1Addr <= "00" & wMemAddr;
              rdn <= '1';
              wrn <= '1';
              Ram1EN <= '0';
              Ram1OE <= '0';
              state <= '1';
            when '1' =>
              Ram1RW <= '1';
              MemOutput <= Ram1Data;
              Ram1Data <= (others => 'Z');
              rdn <= '1';
              wrn <= '1';
              Ram1EN <= '0';
              Ram1OE <= '0';
              state <= '0';
            when others => null;
          end case;
        end if;
      elsif MemWrite = '1' then
        if (state = '0' and wMemAddr = X"BF00") or (state = '1' and wMemAddr_Cache = X"BF00") then
          case state is
            when '0' =>
              Ram1Data <= wMemData;
              rdn <= '1';
              wrn <= '1';
              Ram1EN <= '1';
              Ram1OE <= '1';
              state <= '1';
            when '1' =>
              rdn <= '1';
              wrn <= '0';
              Ram1EN <= '1';
              Ram1OE <= '1';
              state <= '0';
            when others => null;
          end case;
        else
          case state is
            when '0' =>
              Ram1RW <= '1';
              Ram1Addr <= "00" & wMemAddr;
              Ram1Data <= wMemData;
              rdn <= '1';
              wrn <= '1';
              Ram1EN <= '0';
              Ram1OE <= '0';
              state <= '1';
            when '1' =>
              Ram1RW <= '0';
              rdn <= '1';
              wrn <= '1';
              Ram1EN <= '0';
              Ram1OE <= '0';
              state <= '0';
            when others => null;
          end case;
        end if;
      else                              -- not read nor write
        Ram1EN <= '1';
        Ram1OE <= '1';
        Ram1RW <= '1';
        rdn <= '1';
        wrn <= '1';
      end if;
    end if;                             -- end rising_edge
  end process;
  
end DM_Arch;
