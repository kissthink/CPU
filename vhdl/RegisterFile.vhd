library ieee;
use ieee.std_logic_1164.all;

entity RegisterFile is
  
  port (
    CPU_CLK  : in  std_logic;
    RegWrite : in  std_logic;
    Rx, Ry   : in  std_logic_vector(2 downto 0);
    Rd       : in  std_logic_vector(3 downto 0);
    wData    : in  std_logic_vector(15 downto 0);
    RxVal    : out std_logic_vector(15 downto 0);
    RyVal    : out std_logic_vector(15 downto 0);
    RspVal   : out std_logic_vector(15 downto 0);
    RtVal    : out std_logic_vector(15 downto 0);
    RihVal   : out std_logic_vector(15 downto 0)
    );

end RegisterFile;

architecture RegisterFile_Arch of RegisterFile is

  signal clk : std_logic;
  signal R0 : std_logic_vector(15 downto 0) := (others => '0');
  signal R1 : std_logic_vector(15 downto 0) := (others => '0');
  signal R2 : std_logic_vector(15 downto 0) := (others => '0');
  signal R3 : std_logic_vector(15 downto 0) := (others => '0');
  signal R4 : std_logic_vector(15 downto 0) := (others => '0');
  signal R5 : std_logic_vector(15 downto 0) := (others => '0');
  signal R6 : std_logic_vector(15 downto 0) := (others => '0');
  signal R7 : std_logic_vector(15 downto 0) := (others => '0');
  signal Rsp : std_logic_vector(15 downto 0) := (others => '0');
  signal Rt  : std_logic_vector(15 downto 0) := (others => '0');
  signal Rih : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- RegisterFile_Arch

  clk <= CPU_CLK after 6 ns;

  -- Write
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      if RegWrite = '1' then
        case Rd is
          when "0000" => R0 <= wData;
          when "0001" => R1 <= wData;
          when "0010" => R2 <= wData;
          when "0011" => R3 <= wData;
          when "0100" => R4 <= wData;
          when "0101" => R5 <= wData;
          when "0110" => R6 <= wData;
          when "0111" => R7 <= wData;
          when "1000" => Rsp <= wData;
          when "1001" => Rt <= wData;
          when "1010" => Rih <= wData;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  -- Read Rsp / Rt / Rih
  process (clk)
  begin  -- process
    if falling_edge(clk) then
      RspVal <= Rsp;
      RtVal <= Rt;
      RihVal <= Rih;
    end if;
  end process;

  -- Read Rx
  process (clk)
  begin  -- process
    if falling_edge(clk) then
      case Rx is
        when "000" => RxVal <= R0;
        when "001" => RxVal <= R1;
        when "010" => RxVal <= R2;
        when "011" => RxVal <= R3;
        when "100" => RxVal <= R4;
        when "101" => RxVal <= R5;
        when "110" => RxVal <= R6;
        when "111" => RxVal <= R7;
        when others => null;
      end case;
    end if;
  end process;

  -- Read Ry
  process (clk)
  begin  -- process
    if falling_edge(clk) then
      case Ry is
        when "000" => RyVal <= R0;
        when "001" => RyVal <= R1;
        when "010" => RyVal <= R2;
        when "011" => RyVal <= R3;
        when "100" => RyVal <= R4;
        when "101" => RyVal <= R5;
        when "110" => RyVal <= R6;
        when "111" => RyVal <= R7;
        when others => null;
      end case;
    end if;
  end process;

end RegisterFile_Arch;
