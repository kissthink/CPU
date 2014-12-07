library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity IM is
  port (
    rst       : in std_logic;
    clk50     : in    std_logic;
    PC        : in    std_logic_vector(15 downto 0);
    instruc   : out   std_logic_vector(15 downto 0);
    isok_out  : out std_logic := '0';
    
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2Addr  : out std_logic_vector(17 downto 0);			  
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
  
end IM;

architecture Behavioral of IM is

	signal state : std_logic := '0';
	signal condition : std_logic_vector(3 downto 0):="0000";
	signal flashdata : std_logic_vector(15 downto 0):=(others => '0');
	signal flashnum : std_logic_vector(15 downto 0):=(others => '0');
	signal addr2pc : std_logic_vector(17 downto 0):= (others => '0');
	signal flashpc : std_logic_vector(22 downto 1):= (others => '0');
	signal addr : std_logic_vector(22 downto 1):=(others => '0');
	signal data_out : std_logic_vector(15 downto 0);
	signal none : std_logic_vector(15 downto 0);
	signal ctl_read : std_logic;
	signal nothing : std_logic;
    signal isok : std_logic := '0';
  
	component FlashIO
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

  isok_out <= isok;
  
  flash : FlashIO PORT MAP (
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
      flashnum <= (others => '0');
    elsif clk50'event and clk50 = '1' then
      if isok = '1' then
        case state is
          when '0' =>
            Ram2OE <= '0';
            Ram2Data <= (others => 'Z');
            Ram2Addr <= "00" & PC;
            state <= '1';
          when '1' =>
            Ram2OE <= '0';
            instruc <= Ram2Data;
            state <= '0';
          when others => null;
        end case;
      elsif isok = '0' then
        state <= not state;
        if condition = "0000" then
          addr <= flashpc;
          condition <= "0001";
        elsif condition = "0001" then
          ctl_read <= not ctl_read;
          condition <= "0010";
        elsif condition = "0010" then
          flashdata <= data_out;
          flashpc <= flashpc+1;
          condition <= "0011";
        elsif condition = "0011" then
          Ram2Addr <= addr2pc;	
          condition <= "0100";
        elsif condition = "0100" then
          Ram2Data <= flashdata;
          condition <= "0101";
        elsif condition = "0101" then
          Ram2WE <= '0';
          condition <= "0110";
        elsif condition = "0110" then
          Ram2WE <= '1';
          condition <="0111";
        elsif condition = "0111" then
          addr2pc <= addr2pc+1;
          flashnum <= flashnum+1;
          condition <= "0000";
        end if;
        if flashnum > x"6000" then
          isok <= '1';
        end if;
      end if;
    end if;
  end process;

end Behavioral;
