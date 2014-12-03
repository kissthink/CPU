library ieee;
use ieee.std_logic_1164.all;

entity ForwardingDMUnit is
  
  port (
    MemDataSrc : in  std_logic;
    Rx         : in  std_logic_vector(2 downto 0);
    Ry         : in  std_logic_vector(2 downto 0);
    RegWrite   : in  std_logic;
    ALU_Result : in  std_logic_vector(15 downto 0);
    Rd         : in  std_logic_vector(3 downto 0);
    Forward    : out std_logic_vector(17 downto 0)
    );

end ForwardingDMUnit;

architecture ForwardingDMUnit_Arch of ForwardingDMUnit is

  signal UseForward : std_logic := '0';
  signal Rs : std_logic_vector(3 downto 0) := (others => '0');
  
begin  -- ForwardingDMUnit_Arch

  Forward <= UseForward & MemDataSrc & ALU_Result;
  
  Rs <= '0' & Rx when MemDataSrc = '0' else
        '0' & Ry when MemDataSrc = '1';

  UseForward <= '1' when RegWrite = '1' and Rs = Rd else
                '0';

end ForwardingDMUnit_Arch;
