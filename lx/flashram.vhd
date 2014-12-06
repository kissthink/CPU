----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:37:55 12/05/2014 
-- Design Name: 
-- Module Name:    flashram - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flashram is
	port (
		rst : in std_logic;
		clk50     : in    std_logic;
		PC        : in    std_logic_vector(15 downto 0);
		instruc   : out   std_logic_vector(15 downto 0);
		output    : out   std_logic_vector(15 downto 0);
		isok		 : inout std_logic := '0';
		
      Ram2Data  : inout std_logic_vector(15 downto 0);
		Ram2Addr : inout std_logic_vector(17 downto 0);			  
		Ram2OE, Ram2WE, Ram2EN : out std_logic;
	
		flash_byte : out std_logic;--BYTE#
		flash_vpen : out std_logic;
		flash_ce : out std_logic;
		flash_oe : out std_logic;
		flash_we : out std_logic;
		flash_rp : out std_logic;
		flash_addr : out std_logic_vector(22 downto 1);
		flash_data : inout std_logic_vector(15 downto 0)
		
		);
		
end flashram;

architecture Behavioral of flashram is

	signal state : std_logic := '0';
	--signal output : std_logic_vector(15 downto 0) := "0000000000000001";
	signal condition : std_logic_vector(3 downto 0):="0000";
	signal flashdata : std_logic_vector(15 downto 0):="0000000000000000";
	signal flashnum : std_logic_vector(15 downto 0):="0000000000000000";
	signal addr2pc : std_logic_vector(17 downto 0):= "000000000000000000";
	signal flashpc : std_logic_vector(22 downto 1):= "0000000000000000000000";
	signal addr : std_logic_vector(22 downto 1):="0000000000000000000000";
	signal data_out : std_logic_vector(15 downto 0);
	signal currInstr : std_logic_vector(15 downto 0) := X"0800";
	signal LowPC : std_logic_vector(3 downto 0) := "0000";
	signal none : std_logic_vector(15 downto 0);
	signal ctl_read : std_logic;
	signal nothing : std_logic;
  
	component flash_io
    port ( 
		addr : in  STD_LOGIC_VECTOR (22 downto 1);
      data_in : in  STD_LOGIC_VECTOR (15 downto 0);
      data_out : out  STD_LOGIC_VECTOR (15 downto 0);
		clk : in std_logic;--ÀÊ±„ ≤√¥ ±÷”
		reset : in std_logic;
		  
		flash_byte : out std_logic;--BYTE#
		flash_vpen : out std_logic;
		flash_ce : out std_logic;
		flash_oe : out std_logic;
		flash_we : out std_logic;
		flash_rp : out std_logic;
		flash_addr : out std_logic_vector(22 downto 1);
		flash_data : inout std_logic_vector(15 downto 0);
			  
      ctl_read : in  STD_LOGIC;
      ctl_write : in  STD_LOGIC;
		ctl_erase : in STD_LOGIC
		);
	end component;
	
begin

	LowPC <= PC(3 downto 0);
  
	currInstr <= "01101" & "001" & "00000100" when LowPC = "0000" else
               -- LI R1 0x4.  R1 = 0x4

               "01101" & "010" & "00011001" when LowPC = "0001" else
               -- LI R2 0x19  R2 = 0x19
               
               "11011" & "001" & "010" & "00011" when LowPC = "0010" else
               -- SW R1 R2 0x3    MEM(4 + 3) = 0x19

               "10011" & "001" & "011" & "00011" when LowPC = "0011" else
               -- LW R1 R3 0x3    R3 = MEM(4 + 3) = 0x19
               
               X"0800";
	
	flash : flash_io PORT MAP (
		addr => addr,
		data_in => none,
		data_out => data_out,
		clk => clk50,
		reset => rst,
		flash_byte => flash_byte,
		flash_vpen => flash_vpen,
		flash_ce => flash_ce,
		flash_oe => flash_oe,
		flash_we => flash_we,
		flash_rp => flash_rp,
		flash_addr => flash_addr,
		flash_data => flash_data,
		ctl_read => ctl_read,
		ctl_write => nothing,
		ctl_erase => nothing
	);
	
	process(clk50, rst)
	begin
		if rst = '0' then
			Ram2OE <= '1';
			Ram2WE <= '1';
			Ram2EN <= '0';
			state <= '0';
			isok <= '0';
			output <= "1000000000000000";
		elsif clk50'event and clk50 = '1' then

		  if isok = '1' then
			 case state is
				when '0' =>
					Ram2Data <= (others => 'Z');
					Ram2Addr <= "00" & PC;
					output <= "0100000000000000";
					state <= '1';
				when '1' =>
					--          instruc <= Ram2Data;
					instruc <= currInstr;
					output <= "0010000000000000";
					state <= '0';
				when others => null;
			 end case;
		  elsif isok = '0' then
		    state <= not state;
			 --output(10) <= '1';
			 --output <= "0001000000000000";
			 if condition = "0000" then
				--output(3 downto 0) <= condition;
				addr <= flashpc;
				--output <= flashpc(16 downto 1);
				condition <= "0001";
			 elsif condition = "0001" then
			 	--output(3 downto 0) <= condition;
				ctl_read <= not ctl_read;
				condition <= "0010";
			 elsif condition = "0010" then
				--output(3 downto 0) <= condition;
				flashdata <= data_out;
				flashpc <= flashpc+1;
				--output <= flashdata;
				condition <= "0011";
			 elsif condition = "0011" then
			 	--output(3 downto 0) <= condition;
				Ram2Addr <= addr2pc;	
				condition <= "0100";
			 elsif condition = "0100" then
			 	--output(3 downto 0) <= condition;
			   Ram2Data <= flashdata;
				--output <= Ram2Data;
			 	condition <= "0101";
			 elsif condition = "0101" then
			 	--output(3 downto 0) <= condition;
				Ram2WE <= '0';
				condition <= "0110";
			 elsif condition = "0110" then
			 	--output(3 downto 0) <= condition;
				Ram2WE <= '1';
				condition <="0111";
			 elsif condition = "0111" then
			 	--output(3 downto 0) <= condition;
				addr2pc <= addr2pc+1;
				flashnum <= flashnum+1;
				--output <= flashnum;
				condition <= "0000";
			 end if;
			 output <= Ram2Data;
			 if flashnum > x"01F4" then
				isok <= '1';
			 end if;
		  end if;
		end if;
	end process;
			

end Behavioral;

