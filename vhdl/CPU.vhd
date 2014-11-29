library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CPU is
  
  port (
    clk50     : in std_logic;           -- 50M
    rst       : in std_logic;
    
    input     : in   std_logic_vector(15 downto 0);
    
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    
    Ram2Addr  : out   std_logic_vector(17 downto 0);
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2OE    : out   std_logic;
    Ram2RW    : out   std_logic;
    Ram2EN    : out   std_logic;

    rdn       : out   std_logic;
    wrn       : out   std_logic;

    lDigits   : out   std_logic_vector(6 downto 0);
    output    : out   std_logic_vector(15 downto 0)
    );

end CPU;

architecture CPU_Arch of CPU is

  component PCMux
    port (
      CPU_CLK : in  std_logic;
      PC_Src  : in  std_logic;
      PC_New  : in  std_logic_vector(15 downto 0);
      PC_1    : in  std_logic_vector(15 downto 0);
      PC_Next : out std_logic_vector(15 downto 0)
      );
  end component;
  
  component IM
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
  end component;

  component HazardUnit
    port (
      ID_EX_Rx      : in  std_logic_vector(2 downto 0);
      ID_EX_Ry      : in  std_logic_vector(2 downto 0);
      ID_EX_RegDst  : in  std_logic_vector(2 downto 0);
      ID_EX_MemRead : in  std_logic;
      IF_ID_Rx      : in  std_logic_vector(2 downto 0);
      IF_ID_Ry      : in  std_logic_vector(2 downto 0);
      Force_Nop     : out std_logic;
      IF_ID_Keep    : out std_logic
      );
  end component;
  
  component RegisterFile
    port (
      CPU_CLK  : in  std_logic;
      RegWrite : in  std_logic;
      Rx, Ry   : in  std_logic_vector(2 downto 0);
      Rd       : in  std_logic_vector(3 downto 0);
      wData    : in  std_logic_vector(15 downto 0);
    
      R0_out   : out std_logic_vector(15 downto 0);
      R1_out   : out std_logic_vector(15 downto 0);
      R2_out   : out std_logic_vector(15 downto 0);
      R3_out   : out std_logic_vector(15 downto 0);
      R4_out   : out std_logic_vector(15 downto 0);
      R5_out   : out std_logic_vector(15 downto 0);
      R6_out   : out std_logic_vector(15 downto 0);
      R7_out   : out std_logic_vector(15 downto 0);
      Rsp_out  : out std_logic_vector(15 downto 0);
      Rt_out   : out std_logic_vector(15 downto 0);
      Rih_out  : out std_logic_vector(15 downto 0);

      RxVal    : out std_logic_vector(15 downto 0);
      RyVal    : out std_logic_vector(15 downto 0);
      RspVal   : out std_logic_vector(15 downto 0);
      RtVal    : out std_logic_vector(15 downto 0);
      RihVal   : out std_logic_vector(15 downto 0)
      );
  end component;

  component SignExt
    port (
      CPU_CLK : in  std_logic;
      input   : in  std_logic_vector(15 downto 0);
      output  : out std_logic_vector(15 downto 0)
      );
  end component;

  component ZeroExt
    port (
      CPU_CLK : in  std_logic;
      input   : in  std_logic_vector(7 downto 0);
      output  : out std_logic_vector(15 downto 0)
      );
  end component;

  component ControlUnit
    port (
      CPU_CLK    : in  std_logic;
      instruc    : in  std_logic_vector(15 downto 0);
      ForceZero  : in  std_logic;
      RegWrite   : out std_logic;
      RegDataSrc : out std_logic_vector(2 downto 0);
      CmpCode    : out std_logic;
      MemDataSrc : out std_logic;
      MemWrite   : out std_logic;
      MemRead    : out std_logic;
      BranchCtrl : out std_logic_vector(2 downto 0);
      ALU_Op     : out std_logic_vector(2 downto 0);
      ALU_Src1   : out std_logic_vector(1 downto 0);
      ALU_Src2   : out std_logic_vector(1 downto 0);
      RegDst     : out std_logic_vector(2 downto 0)
      );
  end component;

  component PCUnit
    port (
      CPU_CLK     : in  std_logic;
      BranchCtrl  : in  std_logic_vector(2 downto 0);
      PC_1        : in  std_logic_vector(15 downto 0);
      SignImm     : in  std_logic_vector(15 downto 0);
      RxVal       : in  std_logic_vector(15 downto 0);
      RtVal       : in  std_logic_vector(15 downto 0);
      PC_New      : out std_logic_vector(15 downto 0);
      PC_Src      : out std_logic;
      Force_Nop   : out std_logic;
      ID_EX_Clear : out std_logic
      );
  end component;

  component ALU
    port (
      CPU_CLK  : in  std_logic;
      op_in    : in  std_logic_vector(2 downto 0);
      operand1 : in  std_logic_vector(15 downto 0);
      operand2 : in  std_logic_vector(15 downto 0);
      result   : out std_logic_vector(15 downto 0);
      zero     : out std_logic;
      neg      : out std_logic
      );
  end component;

  component ForwardingUnit
    port (
      ID_EX_Rx          : in std_logic_vector(2 downto 0);
      ID_Ex_Ry          : in std_logic_vector(2 downto 0);
      ALU_Src1          : in std_logic_vector(1 downto 0);
      ALU_Src2          : in std_logic_vector(1 downto 0);
      EX_MEM_ALU_Result : in std_logic_vector(15 downto 0);
      EX_MEM_Rd         : in std_logic_vector(3 downto 0);
      EX_MEM_RegWrite   : in std_logic;
      MEM_WB_ALU_Result : in std_logic_vector(15 downto 0);
      MEM_WB_Rd         : in std_logic_vector(3 downto 0);
      MEM_WB_RegWrite   : in std_logic;
      Forward1          : out std_logic_vector(18 downto 0);
      Forward2          : out std_logic_vector(18 downto 0)
      );
  end component;

  component RegDataUnit
    port (
      CPU_CLK     : in  std_logic;
      RegDataSrc  : in  std_logic_vector(2 downto 0);
      CmpCode     : in  std_logic;
      zero        : in  std_logic;
      neg         : in  std_logic;
      RegDataCtrl : out std_logic_vector(3 downto 0)
      );
  end component;

  component DM
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
      rdn, wrn  : out   std_logic;
      MemOutput : out   std_logic_vector(15 downto 0)
      );
  end component;

  
  signal CPU_CLK : std_logic := '0';
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
  
  signal PC : std_logic_vector(15 downto 0) := X"0000";
  signal PC_tmp : std_logic_vector(15 downto 0) := X"0000";
  signal PC_1 : std_logic_vector(15 downto 0) := X"0000";
  signal PC_Src : std_logic := '0';
  signal PC_New : std_logic_vector(15 downto 0) := X"0000";
  signal IF_ID_PC_1 : std_logic_vector(15 downto 0) := X"0000";
  signal IF_ID_Instruc : std_logic_vector(15 downto 0) := X"0800";
  signal IF_ID_Instruc_tmp : std_logic_vector(15 downto 0) := X"0800";
  signal IF_ID_Keep : std_logic := '0';

  signal RegWrite : std_logic := '0';
  signal Rd : std_logic_vector(3 downto 0) := "1111";
  signal wData : std_logic_vector(15 downto 0) := X"0000";
  signal Force_Nop_B : std_logic := '0';
  signal Force_Nop_L : std_logic := '0';
  signal ForceZero : std_logic := '0';
  signal ID_EX_PC_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_Rx : std_logic_vector(10 downto 8) := (others => '0');
  signal ID_EX_Ry : std_logic_vector(7 downto 5) := (others => '0');
  signal ID_EX_Rz : std_logic_vector(4 downto 2) := (others => '0');
  signal ID_EX_RxVal : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_RyVal : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_RspVal : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_RtVal : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_RihVal : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_SignImm : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_ZeroImm : std_logic_vector(15 downto 0) := (others => '0');
  signal ID_EX_RegWrite : std_logic := '0';
  signal ID_EX_RegDataSrc : std_logic_vector(2 downto 0) := (others => '0');
  signal ID_EX_CmpCode : std_logic := '0';
  signal ID_EX_MemDataSrc : std_logic := '0';
  signal ID_EX_MemWrite : std_logic := '0';
  signal ID_EX_MemRead : std_logic := '0';
  signal ID_EX_BranchCtrl : std_logic_vector(2 downto 0) := (others => '0');
  signal ID_EX_ALU_Op : std_logic_vector(2 downto 0) := (others => '0');
  signal ID_EX_ALU_Src1 : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_EX_ALU_Src2 : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_EX_RegDst : std_logic_vector(2 downto 0) := (others => '0');
  signal ID_EX_Clear : std_logic := '0';

  signal operand1 : std_logic_vector(15 downto 0) := (others => '0');
  signal operand2 : std_logic_vector(15 downto 0) := (others => '0');
  signal Forward1 : std_logic_vector(18 downto 0) := (others => '0');
  signal Forward2 : std_logic_vector(18 downto 0) := (others => '0');
  signal EX_MEM_ALU_Result : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_Zero : std_logic := '0';
  signal EX_MEM_Neg : std_logic := '0';
  signal EX_MEM_RegWrite : std_logic := '0';
  signal EX_MEM_RegDataSrc : std_logic_vector(2 downto 0) := (others => '0');
  signal EX_MEM_CmpCode : std_logic := '0';
  signal EX_MEM_MemDataSrc : std_logic := '0';
  signal EX_MEM_MemRead : std_logic := '0';
  signal EX_MEM_MemWrite : std_logic := '0';
  signal EX_MEM_PC_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_RihVal : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_RxVal : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_RyVal : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_ZeroImm : std_logic_vector(15 downto 0) := (others => '0');
  signal EX_MEM_Rd : std_logic_vector(3 downto 0) := (others => '0');

  signal wMemData : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_ALU_Result : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_RegWrite : std_logic := '0';
  signal MEM_WB_PC_1 : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_RihVal : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_RxVal : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_RyVal : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_ZeroImm : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_Rd : std_logic_vector(3 downto 0) := (others => '0');
  signal MEM_WB_MemOutput : std_logic_vector(15 downto 0) := (others => '0');
  signal MEM_WB_RegDataCtrl : std_logic_vector(3 downto 0) := (others => '0');
  
begin  -- CPU_Arch

  lDigits <= PC_Src & IF_ID_Keep & Force_Nop_B & ForceZero & Force_Nop_L & ID_EX_Clear & CPU_CLK;
  
  output <= PC when input = X"0000" else
            PC_tmp when input = X"0001" else
            PC_1 when input = X"0002" else
            PC_New when input = X"0003" else
            IF_ID_PC_1 when input = X"0004" else
            IF_ID_Instruc when input = X"0005" else
            IF_ID_Instruc_tmp when input = X"0006" else

            ID_EX_RegWrite & ID_EX_CmpCode & ID_EX_MemRead & ID_EX_MemWrite & "1111" & ID_EX_MemDataSrc & ID_EX_RegDataSrc & '1' & ID_EX_BranchCtrl when input = X"1000" else
            '0' & ID_EX_ALU_Op & ID_EX_ALU_Src1 & ID_EX_ALU_Src2 & "1111" & '0' & ID_EX_RegDst when input = X"1001" else
            ID_EX_PC_1 when input = X"1002" else
            ID_EX_Rx & ID_EX_Ry & ID_EX_Rz & "0000000" when input = X"1003" else
            ID_EX_RxVal when input = X"1004" else
            ID_EX_RyVal when input = X"1005" else
            ID_EX_RspVal when input = X"1006" else
            ID_EX_RtVal when input = X"1007" else
            ID_EX_RihVal when input = X"1008" else
            ID_EX_SignImm when input = X"1009" else
            ID_EX_ZeroImm when input = X"100A" else
            wData when input = X"100B" else
            RegWrite & "000" & X"00" & Rd when input = X"100C" else

            operand1 when input = X"2000" else
            operand2 when input = X"2001" else
            Forward1(18 downto 3) when input = X"2002" else
            Forward2(18 downto 3) when input = X"2003" else
            EX_MEM_ALU_Result when input = X"2004" else
            EX_MEM_RegWrite & EX_MEM_RegDataSrc & EX_MEM_CmpCode & EX_MEM_MemDataSrc & EX_MEM_MemRead & EX_MEM_MemWrite & EX_MEM_Zero & EX_MEM_Neg & "00" & EX_MEM_Rd when input = X"2005" else
            EX_MEM_PC_1 when input = X"2006" else
            EX_MEM_RihVal when input = X"2007" else
            EX_MEM_RxVal when input = X"2008" else
            EX_MEM_RyVal when input = X"2009" else
            EX_MEM_ZeroImm when input = X"200A" else

            MEM_WB_RegWrite & "000" & MEM_WB_RegDataCtrl & MEM_WB_Rd & "0000" when input = X"3000" else
            wMemData when input = X"3001" else
            MEM_WB_ALU_Result when input = X"3002" else
            MEM_WB_PC_1 when input = X"3003" else
            MEM_WB_RihVal when input = X"3004" else
            MEM_WB_RxVal when input = X"3005" else
            MEM_WB_RyVal when input = X"3006" else
            MEM_WB_ZeroImm when input = X"3007" else
            MEM_WB_MemOutput when input = X"3008" else

            R0 when input = X"4000" else
            R1 when input = X"4001" else
            R2 when input = X"4002" else
            R3 when input = X"4003" else
            R4 when input = X"4004" else
            R5 when input = X"4005" else
            R6 when input = X"4006" else
            R7 when input = X"4007" else
            Rsp when input = X"4008" else
            Rt when input = X"4009" else
            Rih when input = X"400A" else
            
            (others => '1');
  
  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      CPU_CLK <= not CPU_CLK;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Start / IF
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      PC_1 <= PC + 1;
    end if;
  end process;

  IF_ID_PC_1 <= PC_1 when IF_ID_Keep = '0';
  PC <= PC_tmp when IF_ID_Keep = '0';
  IF_ID_Instruc <= IF_ID_Instruc_tmp when IF_ID_Keep = '0';

  PC_Mux : PCMUX
    port map (
      CPU_CLK => CPU_CLK,
      PC_Src  => PC_Src,
      PC_New  => PC_New,
      PC_1    => PC_1,
      PC_Next => PC_tmp
      );
  
  InstrMem : IM
    port map (
      clk50    => clk50,
      PC       => PC,
      Ram2Addr => Ram2Addr,
      Ram2Data => Ram2Data,
      Ram2OE   => Ram2OE,
      Ram2RW   => Ram2RW,
      Ram2EN   => Ram2EN,
      instruc  => IF_ID_Instruc_tmp
      );
  -----------------------------------------------------------------------------
  -- IF / ID
  -----------------------------------------------------------------------------

  ForceZero <= Force_Nop_B or Force_Nop_L;
  
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      ID_EX_PC_1 <= IF_ID_PC_1;
      ID_EX_Rx <= IF_ID_Instruc(10 downto 8);
      ID_EX_Ry <= IF_ID_Instruc(7 downto 5);
      ID_EX_Rz <= IF_ID_Instruc(4 downto 2);
    end if;
  end process;

  Hazard_Unit : HazardUnit
    port map (
      ID_EX_Rx      => ID_EX_Rx,
      ID_EX_Ry      => ID_EX_Ry,
      ID_EX_RegDst  => ID_EX_RegDst,
      ID_EX_MemRead => ID_EX_MemRead,
      IF_ID_Rx      => IF_ID_Instruc(10 downto 8),
      IF_ID_Ry      => IF_ID_Instruc(7 downto 5),
      Force_Nop     => Force_Nop_L,
      IF_ID_Keep    => IF_ID_Keep
      );
  
  RegFile : RegisterFile
    port map (
      CPU_CLK  => CPU_CLK,
      RegWrite => RegWrite,
      Rx       => IF_ID_Instruc(10 downto 8),
      Ry       => IF_ID_Instruc(7 downto 5),
      Rd       => Rd,
      wData    => wData,

      R0_out   => R0,
      R1_out   => R1,
      R2_out   => R2,
      R3_out   => R3,
      R4_out   => R4,
      R5_out   => R5,
      R6_out   => R6,
      R7_out   => R7,
      Rsp_out  => Rsp,
      Rt_out   => Rt,
      Rih_out  => Rih,
      
      RxVal    => ID_EX_RxVal,
      RyVal    => ID_EX_RyVal,
      RspVal   => ID_EX_RspVal,
      RtVal    => ID_EX_RtVal,
      RihVal   => ID_EX_RihVal
      );

  SignExtend : SignExt
    port map (
      CPU_CLK => CPU_CLK,
      input   => IF_ID_Instruc,
      output  => ID_EX_SignImm
      );

  ZeroExtend : ZeroExt
    port map (
      CPU_CLK => CPU_CLK,
      input   => IF_ID_Instruc(7 downto 0),
      output  => ID_EX_ZeroImm
      );

  CtrlUnit : ControlUnit
    port map (
      CPU_CLK    => CPU_CLK,
      instruc    => IF_ID_Instruc,
      ForceZero  => ForceZero,
      RegWrite   => ID_EX_RegWrite,
      RegDataSrc => ID_EX_RegDataSrc,
      CmpCode    => ID_EX_CmpCode,
      MemDataSrc => ID_EX_MemDataSrc,
      MemWrite   => ID_EX_MemWrite,
      MemRead    => ID_EX_MemRead,
      BranchCtrl => ID_EX_BranchCtrl,
      ALU_Op     => ID_EX_ALU_Op,
      ALU_Src1   => ID_EX_ALU_Src1,
      ALU_Src2   => ID_EX_ALU_Src2,
      RegDst     => ID_EX_RegDst
      );
  -----------------------------------------------------------------------------
  -- ID / EX
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      EX_MEM_RegWrite <= ID_EX_RegWrite and not ID_EX_Clear;
      EX_MEM_RegDataSrc <= ID_EX_RegDataSrc;
      EX_MEM_CmpCode <= ID_EX_CmpCode;
      EX_MEM_MemDataSrc <= ID_EX_MemDataSrc;
      EX_MEM_MemRead <= ID_EX_MemRead and not ID_EX_Clear;
      EX_MEM_MemWrite <= ID_EX_MemWrite and not ID_EX_Clear;
      EX_MEM_PC_1 <= ID_EX_PC_1;
      EX_MEM_RihVal <= ID_EX_RihVal;
      EX_MEM_RxVal <= ID_EX_RxVal;
      EX_MEM_RyVal <= ID_EX_RyVal;
      EX_MEM_ZeroImm <= ID_EX_ZeroImm;
    end if;
  end process;

  -- out : operand1
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case Forward1(18) is
        when '1' =>
          operand1 <= Forward1(15 downto 0);
        when '0' =>
          case Forward1(17 downto 16) is
            when "00" =>                -- Rx
              operand1 <= ID_EX_RxVal;
            when "01" =>                -- Ry
              operand1 <= ID_EX_RyVal;
            when "10" =>                -- Rsp
              operand1 <= ID_EX_RspVal;
            when others => null;
          end case;
        when others => null;
      end case;
    end if;
  end process;

  -- out : operand2
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case Forward2(18) is
        when '1' =>
          operand2 <= Forward2(15 downto 0);
        when '0' =>
          case Forward2(17 downto 16) is
            when "00" =>                -- Rx
              operand2 <= ID_EX_RxVal;
            when "01" =>                -- Ry
              operand2 <= ID_EX_RyVal;
            when "10" =>                -- SignImm
              operand2 <= ID_EX_SignImm;
            when others => null;
          end case;
        when others => null;
      end case;
    end if;
  end process;

  -- out : Rd
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case ID_EX_RegDst is
        when "000" =>                   -- Rx
          EX_MEM_Rd <= '0' & ID_EX_Rx;
        when "001" =>                   -- Ry
          EX_MEM_Rd <= '0' & ID_EX_Ry;
        when "010" =>                   -- Rz
          EX_MEM_Rd <= '0' & ID_EX_Rz;
        when "011" =>                   -- Rsp
          EX_MEM_Rd <= "1000";
        when "100" =>                   -- Rt
          EX_MEM_Rd <= "1001";
        when "101" =>                   -- Rih
          EX_MEM_Rd <= "1010";
        when others => null;
      end case;
    end if;
  end process;

  PC_Unit : PCUnit
    port map (
      CPU_CLK     => CPU_CLK,
      BranchCtrl  => ID_EX_BranchCtrl,
      PC_1        => ID_EX_PC_1,
      SignImm     => ID_EX_SignImm,
      RxVal       => ID_EX_RxVal,
      RtVal       => ID_EX_RtVal,
      PC_New      => PC_New,
      PC_Src      => PC_Src,
      Force_Nop   => Force_Nop_B,
      ID_EX_Clear => ID_EX_Clear
      );
  
  ALU_Unit : ALU
    port map (
      CPU_CLK  => CPU_CLK,
      op_in    => ID_EX_ALU_Op,
      operand1 => operand1,
      operand2 => operand2,
      result   => EX_MEM_ALU_Result,
      zero     => EX_MEM_Zero,
      neg      => EX_MEM_Neg
      );

  ForwUnit : ForwardingUnit
    port map (
      ID_EX_Rx          => ID_EX_Rx,
      ID_EX_Ry          => ID_EX_Ry,
      ALU_Src1          => ID_EX_ALU_Src1,
      ALU_Src2          => ID_EX_ALU_Src2,
      EX_MEM_ALU_Result => EX_MEM_ALU_Result,
      EX_MEM_Rd         => EX_MEM_Rd,
      EX_MEM_RegWrite   => EX_MEM_RegWrite,
      MEM_WB_ALU_Result => MEM_WB_ALU_Result,
      MEM_WB_Rd         => MEM_WB_Rd,
      MEM_WB_RegWrite   => MEM_WB_RegWrite,
      Forward1          => Forward1,
      Forward2          => Forward2
      );

  -----------------------------------------------------------------------------
  -- EX / MEM
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      MEM_WB_RegWrite <= EX_MEM_RegWrite;
      MEM_WB_ALU_Result <= EX_MEM_ALU_Result;
      MEM_WB_PC_1 <= EX_MEM_PC_1;
      MEM_WB_RihVal <= EX_MEM_RihVal;
      MEM_WB_RxVal <= EX_MEM_RxVal;
      MEM_WB_RyVal <= EX_MEM_RyVal;
      MEM_WB_ZeroImm <= EX_MEM_ZeroImm;
      MEM_WB_Rd <= EX_MEM_Rd;
    end if;
  end process;

  -- out : wMemData
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      if EX_MEM_MemDataSrc = '0' then
        wMemData <= EX_MEM_RxVal;
      else
        wMemData <= EX_MEM_RyVal;
      end if;
    end if;
  end process;
  
  RegData : RegDataUnit
    port map (
      CPU_CLK     => CPU_CLK,
      RegDataSrc  => EX_MEM_RegDataSrc,
      CmpCode     => EX_MEM_CmpCode,
      zero        => EX_MEM_Zero,
      neg         => EX_MEM_Neg,
      RegDataCtrl => MEM_WB_RegDataCtrl
      );

  DataMem : DM
    port map (
      clk50     => clk50,
      wMemAddr  => EX_MEM_ALU_Result,
      wMemData  => wMemData,
      MemRead   => EX_MEM_MemRead,
      MemWrite  => EX_MEM_MemWrite,
      Ram1Addr  => Ram1Addr,
      Ram1Data  => Ram1Data,
      Ram1OE    => Ram1OE,
      Ram1RW    => Ram1RW,
      Ram1EN    => Ram1EN,
      rdn       => rdn,
      wrn       => wrn,
      MemOutput => MEM_WB_MemOutput
      );
  
  -----------------------------------------------------------------------------
  -- MEM / WB
  -----------------------------------------------------------------------------

  RegWrite <= MEM_WB_RegWrite;
  Rd <= MEM_WB_Rd;
  wData <= MEM_WB_ALU_Result when MEM_WB_RegDataCtrl = "0000" else
           MEM_WB_MemOutput when MEM_WB_RegDataCtrl = "0001" else
           MEM_WB_PC_1 when MEM_WB_RegDataCtrl = "0010" else
           MEM_WB_RihVal when MEM_WB_RegDataCtrl = "0011" else
           MEM_WB_RxVal when MEM_WB_RegDataCtrl = "0100" else
           MEM_WB_RyVal when MEM_WB_RegDataCtrl = "0101" else
           MEM_WB_ZeroImm when MEM_WB_RegDataCtrl = "0110" else
           X"0000" when MEM_WB_RegDataCtrl = "0111" else
           X"0001" when MEM_WB_RegDataCtrl = "1000";
           
end CPU_Arch;
