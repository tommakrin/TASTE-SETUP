-------------------------------------------------------
--! @file       axi_ahb_ip.vhd
--! @brief      AXI to 8 ahb peripheral bridge
--! @author     Régis Spadotti (Scalian) 
--! @author     Michel Francis (Scalian)
--! @author     F.Manni (Cnes)
--!
--!-----------------------------------------------------------------------------------------------
--! @copyright  CNES   
--! @verbatim
--! This File is licensed as MIT license
--! Permission is hereby granted, free of charge, to any person obtaining a copy
--! of this software and associated documentation files (the "Software"), to deal
--! in the Software without restriction, including without limitation the rights
--! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--! copies of the Software, and to permit persons to whom the Software is
--! furnished to do so, subject to the following conditions:
--! 
--! The above copyright notice and this permission notice shall be included in all
--! copies or substantial portions of the Software.
--! 
--! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--! SOFTWARE.
--! @endverbatim
--!
--!-----------------------------------------------------------------------------------------------
--! * Version         : V1.1
--! * Version history : 
--!    * V1 :  2021-03-08 : Scalian : Creation
--!    * V2 :  2021-05-19 : F.Manni (CNES) : 
--!                         * Improve documentation
--! 
--!-----------------------------------------------------------------------------------------------
--! File Creation date : 2021-03-08
--! Project name       : R5 reference Design
--! 
--!-----------------------------------------------------------------------------------------------
--! Softwares             :  
--!     * PC          : Linux Ubuntu 20.04LTS 
--!     * Editor      : Visual studio code 2021-05 + Eclipse 2019-12
--!     * Synthetizer : Nxmap 3.5.0.4 (29th march 2021)
--!     * P&R         : Nxmap 3.5.0.4 (29th march 2021)
--! Automatic VHDL coding :  NO 
--! 
--!-----------------------------------------------------------------------------------------------
--! @details  
--!  
--! @todo provide a detailed description and comments tag for this entity for doxygen
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.ALL;
use ieee.std_logic_unsigned.all;

library work;
use work.common_functions_pkg.all;
use work.AddrDecoderPkg.all;

entity axi_ahb_ip is
generic (
	AXI_ADDR_WIDTH  : integer:=32;
	AXI_DATA_WIDTH  : integer:=64;
	AXI_ID_WIDTH    : integer range 1 to 16 := 4;
	AXI_BURST_WIDTH : integer:=4;
	AHB_ADDR_MAP    : AddrMappingTable := (
      0 => (start_addr => X"3000_1000", end_addr => X"3000_1FFF"),
      1 => (start_addr => X"3000_2000", end_addr => X"3000_2FFF"),
      2 => (start_addr => X"3000_3000", end_addr => X"3000_3FFF"),
      3 => (start_addr => X"3000_4000", end_addr => X"3000_4FFF"),
      4 => (start_addr => X"3000_5000", end_addr => X"3000_5FFF"),
      5 => (start_addr => X"3000_6000", end_addr => X"3000_7FFF"),
      6 => (start_addr => X"3000_8000", end_addr => X"3000_8FFF"),
      7 => (start_addr => X"3000_9000", end_addr => X"3000_9FFF"));
	MSB_DECODER : natural:=29;
	AHB_ADDR_TEST_LSB : natural:=0;
	AHB_ADDR_WIDTH    : integer:=32;
	BURST_ADDR_WIDTH  : integer:=12
);
port (
-- AXI Global System Signals
	S_AXI_ACLK    : in  std_logic;
	S_AXI_ARESETN : in  std_logic;
-- AXI Write Address Channel Signals
	S_AXI_AWID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	S_AXI_AWADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_AWLEN   : in  std_logic_vector(AXI_BURST_WIDTH-1 downto 0);
	S_AXI_AWSIZE  : in  std_logic_vector(2 downto 0);
	S_AXI_AWBURST : in  std_logic_vector(1 downto 0);
	S_AXI_AWLOCK  : in  std_logic_vector(1 downto 0);
	S_AXI_AWCACHE : in  std_logic_vector(3 downto 0);
	S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
	S_AXI_AWVALID : in  std_logic;
	S_AXI_AWREADY : out std_logic;
-- AXI Write Channel Signals
	S_AXI_WID     : in std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	S_AXI_WDATA   : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	S_AXI_WSTRB   : in  std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
	S_AXI_WLAST   : in  std_logic;
	S_AXI_WVALID  : in  std_logic;
	S_AXI_WREADY  : out std_logic;
-- AXI Write Response Channel Signals
	S_AXI_BID     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	S_AXI_BRESP   : out std_logic_vector(1 downto 0);
	S_AXI_BVALID  : out std_logic;
	S_AXI_BREADY  : in  std_logic;
-- AXI Read Address Channel Signals
	S_AXI_ARID    : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	S_AXI_ARADDR  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_ARLEN   : in  std_logic_vector(AXI_BURST_WIDTH-1 downto 0);
	S_AXI_ARSIZE  : in  std_logic_vector(2 downto 0);
	S_AXI_ARBURST : in  std_logic_vector(1 downto 0);
	S_AXI_ARLOCK  : in  std_logic_vector(1 downto 0);
	S_AXI_ARCACHE : in  std_logic_vector(3 downto 0);
	S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
	S_AXI_ARVALID : in  std_logic;
	S_AXI_ARREADY : out std_logic;
-- AXI Read Data Channel Signals
	S_AXI_RID     : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	S_AXI_RDATA   : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	S_AXI_RRESP   : out std_logic_vector(1 downto 0);
	S_AXI_RLAST   : out std_logic;
	S_AXI_RVALID  : out std_logic;
	S_AXI_RREADY  : in  std_logic;

-- AHB signals

	M0_AHB_HRESETN	: out  std_logic;
	M0_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M0_AHB_HWRITE	: out std_logic;
	M0_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M0_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M0_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M0_AHB_HNONSEC	: out std_logic; 
	M0_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M0_AHB_HMASTLOCK: out std_logic;
	M0_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M0_AHB_HREADY	: in  std_logic;
	M0_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M0_AHB_HRESP	: in  std_logic;
	M0_AHB_HSEL      : out std_logic;

	M1_AHB_HRESETN	: out  std_logic;
	M1_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M1_AHB_HWRITE	: out std_logic;
	M1_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M1_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M1_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M1_AHB_HNONSEC	: out std_logic; 
	M1_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M1_AHB_HMASTLOCK: out std_logic;
	M1_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M1_AHB_HREADY	: in  std_logic;
	M1_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M1_AHB_HRESP	: in  std_logic;
	M1_AHB_HSEL     : out std_logic;

	M2_AHB_HRESETN	: out  std_logic;
	M2_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M2_AHB_HWRITE	: out std_logic;
	M2_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M2_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M2_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M2_AHB_HNONSEC	: out std_logic; 
	M2_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M2_AHB_HMASTLOCK: out std_logic;
	M2_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M2_AHB_HREADY	: in  std_logic;
	M2_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M2_AHB_HRESP	: in  std_logic;
	M2_AHB_HSEL     : out std_logic;

	M3_AHB_HRESETN	: out  std_logic;
	M3_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M3_AHB_HWRITE	: out std_logic;
	M3_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M3_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M3_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M3_AHB_HNONSEC	: out std_logic; 
	M3_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M3_AHB_HMASTLOCK: out std_logic;
	M3_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M3_AHB_HREADY	: in  std_logic;
	M3_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M3_AHB_HRESP	: in  std_logic;
	M3_AHB_HSEL     : out std_logic;

	M4_AHB_HRESETN	: out  std_logic;
	M4_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M4_AHB_HWRITE	: out std_logic;
	M4_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M4_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M4_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M4_AHB_HNONSEC	: out std_logic; 
	M4_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M4_AHB_HMASTLOCK: out std_logic;
	M4_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M4_AHB_HREADY	: in  std_logic;
	M4_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M4_AHB_HRESP	: in  std_logic;
	M4_AHB_HSEL     : out std_logic;

	M5_AHB_HRESETN	: out  std_logic;
	M5_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M5_AHB_HWRITE	: out std_logic;
	M5_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M5_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M5_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M5_AHB_HNONSEC	: out std_logic; 
	M5_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M5_AHB_HMASTLOCK: out std_logic;
	M5_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M5_AHB_HREADY	: in  std_logic;
	M5_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M5_AHB_HRESP	: in  std_logic;
	M5_AHB_HSEL     : out std_logic;

	M6_AHB_HRESETN	: out  std_logic;
	M6_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M6_AHB_HWRITE	: out std_logic;
	M6_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M6_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M6_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M6_AHB_HNONSEC	: out std_logic; 
	M6_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M6_AHB_HMASTLOCK: out std_logic;
	M6_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M6_AHB_HREADY	: in  std_logic;
	M6_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M6_AHB_HRESP	: in  std_logic;
	M6_AHB_HSEL     : out std_logic;

	M7_AHB_HRESETN	: out  std_logic;
	M7_AHB_HADDR	: out std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
	M7_AHB_HWRITE	: out std_logic;
	M7_AHB_HSIZE	: out std_logic_vector(2 downto 0);
	M7_AHB_HBURST	: out std_logic_vector(2 downto 0);
	M7_AHB_HPROT	: out std_logic_vector(6 downto 0);
	M7_AHB_HNONSEC	: out std_logic; 
	M7_AHB_HTRANS	: out std_logic_vector(1 downto 0);
	M7_AHB_HMASTLOCK: out std_logic;
	M7_AHB_HWDATA	: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M7_AHB_HREADY	: in  std_logic;
	M7_AHB_HRDATA	: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	M7_AHB_HRESP	: in  std_logic;
	M7_AHB_HSEL     : out std_logic
);
end entity axi_ahb_ip;


architecture Behavioral of axi_ahb_ip is

component Compteur_Addr is
generic
(
	DATA_WIDTH : integer := 12;
	MASK_WIDTH : integer := 4
);
port
(
	Clk : in std_logic;
	Inc_Step : in std_logic_vector(MASK_WIDTH downto 0);
	Mask : in std_logic_vector(MASK_WIDTH-1 downto 0);
	Wrap : in std_logic;
	WrapMask : in std_logic_vector(DATA_WIDTH-1 downto 0);
	Data_In : in std_logic_vector(DATA_WIDTH-1 downto 0);
	Data_Load : in std_logic;
	Data_Inc : in std_logic;
	Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end component;

component sync_fifo is
  generic (
    DW : positive := 16;
    AW : positive := 3
  );
  port (
    clk_i   : in  std_logic;
    rst_ni  : in  std_logic;
    --
    wen_i   : in  std_logic;
    data_i  : in  std_logic_vector(DW-1 downto 0);
    full_o  : out std_logic;
    --
    ren_i   : in  std_logic;
    data_o  : out std_logic_vector(DW-1 downto 0);
    empty_o : out std_logic
  );
end component;

constant AXI_DATA_WIDTH_BITS : integer:=clog2(AXI_DATA_WIDTH);
constant CPT_ADDR_WIDTH : integer:=min2(BURST_ADDR_WIDTH,AHB_ADDR_WIDTH);
constant CPT_MASK_WIDTH : integer:=clog2(AXI_DATA_WIDTH/8);

constant FIN_BURST : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(0,AXI_BURST_WIDTH);
constant BURST_01 : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(1,AXI_BURST_WIDTH);

constant s_Mask : std_logic_vector(CPT_MASK_WIDTH-1 downto 0):=(others => '0');

constant NBRE_SEL : natural:=AHB_ADDR_MAP'LENGTH;

constant ADDR_TEST_MASK : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0):=conv_std_logic_vector((2**(MSB_DECODER+1))-1,AXI_ADDR_WIDTH);

type fsm_arbit_type is
(
	ARBIT_IDLE_R,
	ARBIT_IDLE_W,
	ARBIT_WAIT_R_ACK,
	ARBIT_WAIT_R_END,
	ARBIT_WAIT_W_ACK,
	ARBIT_WAIT_W_END
);

type fsm_add_axi_type is
(
	ADDR_AXI_IDLE,
	ADDR_AXI_TEST_1,
	ADDR_AXI_TEST_2,
	ADDR_AXI_TEST_3,
	ADDR_AXI_WAIT_START,
	ADDR_AXI_WAIT_END
);

type fsm_w_ahb_type is
(
	WRITE_IDLE,
	WRITE_STEP,
	WRITE_WAIT_ADDR_ACK,
	WRITE_WAIT_LAST_ACK,
	WRITE_WAIT_ACK,
	WRITE_WAIT_WVALID,
	WRITE_ERROR,
	WRITE_WAIT_BREADY
);

type fsm_r_ahb_type is
(
	READ_IDLE,
	READ_WAIT_ADDR_ACK,
	READ_WAIT_ACK,
	READ_WAIT_FIFO,
	READ_ERROR
);

type fsm_r_last_type is
(
	READ_WAIT_START,
	READ_WAIT_FIFO_RREADY
);

signal s_ADDRW_Ok,s_ADDRR_Ok : std_logic:='0';
signal s_LenW,s_LenR,s_BurstLengthR,s_BurstLengthW : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=(others => '0');
signal s_IncW,s_IncR,s_IncWEn,s_IncREn : std_logic;
signal s_AWREADY,s_WREADY_On,s_WREADY_En : std_logic;
signal s_ARREADY : std_logic;
signal s_AWADDR,s_ARADDR : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0):=(others => '0');
signal s_AddrIncR,s_AddrIncW,s_WrapTestR,s_WrapTestW : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0):=(others => '0');

signal s_WrapW,s_WrapR : std_logic;
signal s_IncStepW,s_IncStepR : std_logic_vector(CPT_MASK_WIDTH downto 0):=(others => '0');
signal s_WrapMaskW,s_WrapMaskR : std_logic_vector(CPT_ADDR_WIDTH-1 downto 0):=(others => '0');
signal s_AddrRCpt,s_AddrWCpt : std_logic_vector(CPT_ADDR_WIDTH-1 downto 0):=(others => '0');
signal s_AddrR,s_AddrW : std_logic_vector(AHB_ADDR_WIDTH-1 downto 0):=(others => '0');

signal fsm_arbit : fsm_arbit_type;
signal fsm_w_add_axi,fsm_r_add_axi : fsm_add_axi_type;
signal fsm_w_ahb : fsm_w_ahb_type;
signal fsm_r_ahb : fsm_r_ahb_type;
signal s_WrErr,s_RdErr,s_WrAddr,s_RdAddr : std_logic;
signal s_WrStart,s_RdStart,s_WrEnd,s_RdEnd : std_logic;

signal s_AWVALID,s_ARVALID : std_logic;
signal s_RDATA : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
signal s_RdErrorLatch : std_logic:='0';

signal s_HWRITE : std_logic;
signal s_HTRANS_R,s_HTRANS_W : std_logic_vector(1 downto 0);
signal s_HSIZE_R,s_HSIZE_W : std_logic_vector(2 downto 0);
signal s_HPROT_R,s_HPROT_W : std_logic_vector(6 downto 0);
signal s_HNONSEC_R,s_HNONSEC_W : std_logic;
signal s_HBURST_R,s_HBURST_W : std_logic_vector(2 downto 0);
signal s_HWDATA,s_HRDATA : std_logic_vector(AXI_DATA_WIDTH-1 downto 0):=(others => '0');
signal s_HREADY,s_HRESP : std_logic;
signal s_SEL_R,s_SEL_W : std_logic_vector(NBRE_SEL-1 downto 0):=(others => '0');
signal s_AddrR_Inc,s_AddrW_Inc : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0):=(others => '0');

signal s_AddrR_Test,s_AddrW_Test : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);

signal Strb16_test,Strb16_0,Strb16_1 : std_logic;
signal Strb32_test,Strb32_0,Strb32_1 : std_logic;

signal AlignR16,AlignR32,AlignR64,AlignR128 : std_logic;
signal AlignW16,AlignW32,AlignW64,AlignW128 : std_logic;

signal Current_Index,Current_Index_R,Current_Index_W : natural range 0 to NBRE_SEL-1:=0;

--signal M_AHB_HCLK : std_logic;
signal M_AHB_HRESETN,M_AHB_HWRITE,M_AHB_HNONSEC,M_AHB_HMASTLOCK : std_logic;
signal M_AHB_HADDR : std_logic_vector(AHB_ADDR_WIDTH-1 downto 0);
signal M_AHB_HSIZE,M_AHB_HBURST : std_logic_vector(2 downto 0);
signal M_AHB_HPROT : std_logic_vector(6 downto 0);
signal M_AHB_HTRANS : std_logic_vector(1 downto 0);
signal M_AHB_HWDATA : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
--signal M_AHB_HWDATA : std_logic_vector(AHB_DATA_WIDTH-1 downto 0);
signal M_AHB_HREADY,M_AHB_HRESP,M_AHB_HSEL : std_logic_vector(NBRE_SEL-1 downto 0);
signal M_AHB_HRDATA : STDL64_ARRAY_TYPE(NBRE_SEL-1 downto 0);

signal FIFO_WEn,FIFO_Full,FIFO_Empty : std_logic;
signal FIFO_DataIn : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
signal s_FIFO_En,s_FIFO_On : std_logic;
signal s_RRESP : std_logic_vector(1 downto 0);
signal s_LengthR : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=(others => '0');
signal fsm_r_last : fsm_r_last_type;

signal Resetp : std_logic;

begin

NBRE_BUS_8 : if (NBRE_SEL>=8) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= M_AHB_HCLK;
--M4_AHB_HCLK <= M_AHB_HCLK;
--M5_AHB_HCLK <= M_AHB_HCLK;
--M6_AHB_HCLK <= M_AHB_HCLK;
--M7_AHB_HCLK <= M_AHB_HCLK;

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= M_AHB_HRESETN;
M4_AHB_HRESETN <= M_AHB_HRESETN;
M5_AHB_HRESETN <= M_AHB_HRESETN;
M6_AHB_HRESETN <= M_AHB_HRESETN;
M7_AHB_HRESETN <= M_AHB_HRESETN;

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= M_AHB_HWRITE;
M4_AHB_HWRITE <= M_AHB_HWRITE;
M5_AHB_HWRITE <= M_AHB_HWRITE;
M6_AHB_HWRITE <= M_AHB_HWRITE;
M7_AHB_HWRITE <= M_AHB_HWRITE;

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= M_AHB_HNONSEC;
M4_AHB_HNONSEC <= M_AHB_HNONSEC;
M5_AHB_HNONSEC <= M_AHB_HNONSEC;
M6_AHB_HNONSEC <= M_AHB_HNONSEC;
M7_AHB_HNONSEC <= M_AHB_HNONSEC;

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M4_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M5_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M6_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M7_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= M_AHB_HADDR;
M4_AHB_HADDR <= M_AHB_HADDR;
M5_AHB_HADDR <= M_AHB_HADDR;
M6_AHB_HADDR <= M_AHB_HADDR;
M7_AHB_HADDR <= M_AHB_HADDR;

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= M_AHB_HSIZE;
M4_AHB_HSIZE <= M_AHB_HSIZE;
M5_AHB_HSIZE <= M_AHB_HSIZE;
M6_AHB_HSIZE <= M_AHB_HSIZE;
M7_AHB_HSIZE <= M_AHB_HSIZE;

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= M_AHB_HBURST;
M4_AHB_HBURST <= M_AHB_HBURST;
M5_AHB_HBURST <= M_AHB_HBURST;
M6_AHB_HBURST <= M_AHB_HBURST;
M7_AHB_HBURST <= M_AHB_HBURST;

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= M_AHB_HPROT;
M4_AHB_HPROT <= M_AHB_HPROT;
M5_AHB_HPROT <= M_AHB_HPROT;
M6_AHB_HPROT <= M_AHB_HPROT;
M7_AHB_HPROT <= M_AHB_HPROT;

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= M_AHB_HTRANS;
M4_AHB_HTRANS <= M_AHB_HTRANS;
M5_AHB_HTRANS <= M_AHB_HTRANS;
M6_AHB_HTRANS <= M_AHB_HTRANS;
M7_AHB_HTRANS <= M_AHB_HTRANS;

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= M_AHB_HWDATA;
M4_AHB_HWDATA <= M_AHB_HWDATA;
M5_AHB_HWDATA <= M_AHB_HWDATA;
M6_AHB_HWDATA <= M_AHB_HWDATA;
M7_AHB_HWDATA <= M_AHB_HWDATA;

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= M_AHB_HSEL(3);
M4_AHB_HSEL <= M_AHB_HSEL(4);
M5_AHB_HSEL <= M_AHB_HSEL(5);
M6_AHB_HSEL <= M_AHB_HSEL(6);
M7_AHB_HSEL <= M_AHB_HSEL(7);

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;
M_AHB_HRESP(3) <= M3_AHB_HRESP;
M_AHB_HRESP(4) <= M4_AHB_HRESP;
M_AHB_HRESP(5) <= M5_AHB_HRESP;
M_AHB_HRESP(6) <= M6_AHB_HRESP;
M_AHB_HRESP(7) <= M7_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;
M_AHB_HREADY(3) <= M3_AHB_HREADY;
M_AHB_HREADY(4) <= M4_AHB_HREADY;
M_AHB_HREADY(5) <= M5_AHB_HREADY;
M_AHB_HREADY(6) <= M6_AHB_HREADY;
M_AHB_HREADY(7) <= M7_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;
M_AHB_HRDATA(3) <= M3_AHB_HRDATA;
M_AHB_HRDATA(4) <= M4_AHB_HRDATA;
M_AHB_HRDATA(5) <= M5_AHB_HRDATA;
M_AHB_HRDATA(6) <= M6_AHB_HRDATA;
M_AHB_HRDATA(7) <= M7_AHB_HRDATA;

end generate NBRE_BUS_8;

NBRE_BUS_7 : if (NBRE_SEL=7) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= M_AHB_HCLK;
--M4_AHB_HCLK <= M_AHB_HCLK;
--M5_AHB_HCLK <= M_AHB_HCLK;
--M6_AHB_HCLK <= M_AHB_HCLK;
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= M_AHB_HRESETN;
M4_AHB_HRESETN <= M_AHB_HRESETN;
M5_AHB_HRESETN <= M_AHB_HRESETN;
M6_AHB_HRESETN <= M_AHB_HRESETN;
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= M_AHB_HWRITE;
M4_AHB_HWRITE <= M_AHB_HWRITE;
M5_AHB_HWRITE <= M_AHB_HWRITE;
M6_AHB_HWRITE <= M_AHB_HWRITE;
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= M_AHB_HNONSEC;
M4_AHB_HNONSEC <= M_AHB_HNONSEC;
M5_AHB_HNONSEC <= M_AHB_HNONSEC;
M6_AHB_HNONSEC <= M_AHB_HNONSEC;
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M4_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M5_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M6_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= M_AHB_HADDR;
M4_AHB_HADDR <= M_AHB_HADDR;
M5_AHB_HADDR <= M_AHB_HADDR;
M6_AHB_HADDR <= M_AHB_HADDR;
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= M_AHB_HSIZE;
M4_AHB_HSIZE <= M_AHB_HSIZE;
M5_AHB_HSIZE <= M_AHB_HSIZE;
M6_AHB_HSIZE <= M_AHB_HSIZE;
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= M_AHB_HBURST;
M4_AHB_HBURST <= M_AHB_HBURST;
M5_AHB_HBURST <= M_AHB_HBURST;
M6_AHB_HBURST <= M_AHB_HBURST;
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= M_AHB_HPROT;
M4_AHB_HPROT <= M_AHB_HPROT;
M5_AHB_HPROT <= M_AHB_HPROT;
M6_AHB_HPROT <= M_AHB_HPROT;
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= M_AHB_HTRANS;
M4_AHB_HTRANS <= M_AHB_HTRANS;
M5_AHB_HTRANS <= M_AHB_HTRANS;
M6_AHB_HTRANS <= M_AHB_HTRANS;
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= M_AHB_HWDATA;
M4_AHB_HWDATA <= M_AHB_HWDATA;
M5_AHB_HWDATA <= M_AHB_HWDATA;
M6_AHB_HWDATA <= M_AHB_HWDATA;
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= M_AHB_HSEL(3);
M4_AHB_HSEL <= M_AHB_HSEL(4);
M5_AHB_HSEL <= M_AHB_HSEL(5);
M6_AHB_HSEL <= M_AHB_HSEL(6);
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;
M_AHB_HRESP(3) <= M3_AHB_HRESP;
M_AHB_HRESP(4) <= M4_AHB_HRESP;
M_AHB_HRESP(5) <= M5_AHB_HRESP;
M_AHB_HRESP(6) <= M6_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;
M_AHB_HREADY(3) <= M3_AHB_HREADY;
M_AHB_HREADY(4) <= M4_AHB_HREADY;
M_AHB_HREADY(5) <= M5_AHB_HREADY;
M_AHB_HREADY(6) <= M6_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;
M_AHB_HRDATA(3) <= M3_AHB_HRDATA;
M_AHB_HRDATA(4) <= M4_AHB_HRDATA;
M_AHB_HRDATA(5) <= M5_AHB_HRDATA;
M_AHB_HRDATA(6) <= M6_AHB_HRDATA;

end generate NBRE_BUS_7;

NBRE_BUS_6 : if (NBRE_SEL=6) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= M_AHB_HCLK;
--M4_AHB_HCLK <= M_AHB_HCLK;
--M5_AHB_HCLK <= M_AHB_HCLK;
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= M_AHB_HRESETN;
M4_AHB_HRESETN <= M_AHB_HRESETN;
M5_AHB_HRESETN <= M_AHB_HRESETN;
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= M_AHB_HWRITE;
M4_AHB_HWRITE <= M_AHB_HWRITE;
M5_AHB_HWRITE <= M_AHB_HWRITE;
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= M_AHB_HNONSEC;
M4_AHB_HNONSEC <= M_AHB_HNONSEC;
M5_AHB_HNONSEC <= M_AHB_HNONSEC;
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M4_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M5_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= M_AHB_HADDR;
M4_AHB_HADDR <= M_AHB_HADDR;
M5_AHB_HADDR <= M_AHB_HADDR;
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= M_AHB_HSIZE;
M4_AHB_HSIZE <= M_AHB_HSIZE;
M5_AHB_HSIZE <= M_AHB_HSIZE;
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= M_AHB_HBURST;
M4_AHB_HBURST <= M_AHB_HBURST;
M5_AHB_HBURST <= M_AHB_HBURST;
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= M_AHB_HPROT;
M4_AHB_HPROT <= M_AHB_HPROT;
M5_AHB_HPROT <= M_AHB_HPROT;
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= M_AHB_HTRANS;
M4_AHB_HTRANS <= M_AHB_HTRANS;
M5_AHB_HTRANS <= M_AHB_HTRANS;
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= M_AHB_HWDATA;
M4_AHB_HWDATA <= M_AHB_HWDATA;
M5_AHB_HWDATA <= M_AHB_HWDATA;
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= M_AHB_HSEL(3);
M4_AHB_HSEL <= M_AHB_HSEL(4);
M5_AHB_HSEL <= M_AHB_HSEL(5);
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;
M_AHB_HRESP(3) <= M3_AHB_HRESP;
M_AHB_HRESP(4) <= M4_AHB_HRESP;
M_AHB_HRESP(5) <= M5_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;
M_AHB_HREADY(3) <= M3_AHB_HREADY;
M_AHB_HREADY(4) <= M4_AHB_HREADY;
M_AHB_HREADY(5) <= M5_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;
M_AHB_HRDATA(3) <= M3_AHB_HRDATA;
M_AHB_HRDATA(4) <= M4_AHB_HRDATA;
M_AHB_HRDATA(5) <= M5_AHB_HRDATA;

end generate NBRE_BUS_6;

NBRE_BUS_5 : if (NBRE_SEL=5) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= M_AHB_HCLK;
--M4_AHB_HCLK <= M_AHB_HCLK;
--M5_AHB_HCLK <= '0';
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= M_AHB_HRESETN;
M4_AHB_HRESETN <= M_AHB_HRESETN;
M5_AHB_HRESETN <= '0';
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= M_AHB_HWRITE;
M4_AHB_HWRITE <= M_AHB_HWRITE;
M5_AHB_HWRITE <= '0';
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= M_AHB_HNONSEC;
M4_AHB_HNONSEC <= M_AHB_HNONSEC;
M5_AHB_HNONSEC <= '0';
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M4_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M5_AHB_HMASTLOCK <= '0';
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= M_AHB_HADDR;
M4_AHB_HADDR <= M_AHB_HADDR;
M5_AHB_HADDR <= (others => '0');
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= M_AHB_HSIZE;
M4_AHB_HSIZE <= M_AHB_HSIZE;
M5_AHB_HSIZE <= (others => '0');
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= M_AHB_HBURST;
M4_AHB_HBURST <= M_AHB_HBURST;
M5_AHB_HBURST <= (others => '0');
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= M_AHB_HPROT;
M4_AHB_HPROT <= M_AHB_HPROT;
M5_AHB_HPROT <= (others => '0');
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= M_AHB_HTRANS;
M4_AHB_HTRANS <= M_AHB_HTRANS;
M5_AHB_HTRANS <= (others => '0');
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= M_AHB_HWDATA;
M4_AHB_HWDATA <= M_AHB_HWDATA;
M5_AHB_HWDATA <= (others => '0');
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= M_AHB_HSEL(3);
M4_AHB_HSEL <= M_AHB_HSEL(4);
M5_AHB_HSEL <= '0';
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;
M_AHB_HRESP(3) <= M3_AHB_HRESP;
M_AHB_HRESP(4) <= M4_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;
M_AHB_HREADY(3) <= M3_AHB_HREADY;
M_AHB_HREADY(4) <= M4_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;
M_AHB_HRDATA(3) <= M3_AHB_HRDATA;
M_AHB_HRDATA(4) <= M4_AHB_HRDATA;

end generate NBRE_BUS_5;

NBRE_BUS_4 : if (NBRE_SEL=4) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= M_AHB_HCLK;
--M4_AHB_HCLK <= '0';
--M5_AHB_HCLK <= '0';
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= M_AHB_HRESETN;
M4_AHB_HRESETN <= '0';
M5_AHB_HRESETN <= '0';
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= M_AHB_HWRITE;
M4_AHB_HWRITE <= '0';
M5_AHB_HWRITE <= '0';
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= M_AHB_HNONSEC;
M4_AHB_HNONSEC <= '0';
M5_AHB_HNONSEC <= '0';
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M4_AHB_HMASTLOCK <= '0';
M5_AHB_HMASTLOCK <= '0';
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= M_AHB_HADDR;
M4_AHB_HADDR <= (others => '0');
M5_AHB_HADDR <= (others => '0');
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= M_AHB_HSIZE;
M4_AHB_HSIZE <= (others => '0');
M5_AHB_HSIZE <= (others => '0');
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= M_AHB_HBURST;
M4_AHB_HBURST <= (others => '0');
M5_AHB_HBURST <= (others => '0');
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= M_AHB_HPROT;
M4_AHB_HPROT <= (others => '0');
M5_AHB_HPROT <= (others => '0');
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= M_AHB_HTRANS;
M4_AHB_HTRANS <= (others => '0');
M5_AHB_HTRANS <= (others => '0');
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= M_AHB_HWDATA;
M4_AHB_HWDATA <= (others => '0');
M5_AHB_HWDATA <= (others => '0');
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= M_AHB_HSEL(3);
M4_AHB_HSEL <= '0';
M5_AHB_HSEL <= '0';
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;
M_AHB_HRESP(3) <= M3_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;
M_AHB_HREADY(3) <= M3_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;
M_AHB_HRDATA(3) <= M3_AHB_HRDATA;

end generate NBRE_BUS_4;

NBRE_BUS_3 : if (NBRE_SEL=3) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= M_AHB_HCLK;
--M3_AHB_HCLK <= '0';
--M4_AHB_HCLK <= '0';
--M5_AHB_HCLK <= '0';
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= M_AHB_HRESETN;
M3_AHB_HRESETN <= '0';
M4_AHB_HRESETN <= '0';
M5_AHB_HRESETN <= '0';
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= M_AHB_HWRITE;
M3_AHB_HWRITE <= '0';
M4_AHB_HWRITE <= '0';
M5_AHB_HWRITE <= '0';
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= M_AHB_HNONSEC;
M3_AHB_HNONSEC <= '0';
M4_AHB_HNONSEC <= '0';
M5_AHB_HNONSEC <= '0';
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M3_AHB_HMASTLOCK <= '0';
M4_AHB_HMASTLOCK <= '0';
M5_AHB_HMASTLOCK <= '0';
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= M_AHB_HADDR;
M3_AHB_HADDR <= (others => '0');
M4_AHB_HADDR <= (others => '0');
M5_AHB_HADDR <= (others => '0');
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= M_AHB_HSIZE;
M3_AHB_HSIZE <= (others => '0');
M4_AHB_HSIZE <= (others => '0');
M5_AHB_HSIZE <= (others => '0');
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= M_AHB_HBURST;
M3_AHB_HBURST <= (others => '0');
M4_AHB_HBURST <= (others => '0');
M5_AHB_HBURST <= (others => '0');
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= M_AHB_HPROT;
M3_AHB_HPROT <= (others => '0');
M4_AHB_HPROT <= (others => '0');
M5_AHB_HPROT <= (others => '0');
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= M_AHB_HTRANS;
M3_AHB_HTRANS <= (others => '0');
M4_AHB_HTRANS <= (others => '0');
M5_AHB_HTRANS <= (others => '0');
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= M_AHB_HWDATA;
M3_AHB_HWDATA <= (others => '0');
M4_AHB_HWDATA <= (others => '0');
M5_AHB_HWDATA <= (others => '0');
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= M_AHB_HSEL(2);
M3_AHB_HSEL <= '0';
M4_AHB_HSEL <= '0';
M5_AHB_HSEL <= '0';
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;
M_AHB_HRESP(2) <= M2_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;
M_AHB_HREADY(2) <= M2_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;
M_AHB_HRDATA(2) <= M2_AHB_HRDATA;

end generate NBRE_BUS_3;

NBRE_BUS_2 : if (NBRE_SEL=2) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= M_AHB_HCLK;
--M2_AHB_HCLK <= '0';
--M3_AHB_HCLK <= '0';
--M4_AHB_HCLK <= '0';
--M5_AHB_HCLK <= '0';
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= M_AHB_HRESETN;
M2_AHB_HRESETN <= '0';
M3_AHB_HRESETN <= '0';
M4_AHB_HRESETN <= '0';
M5_AHB_HRESETN <= '0';
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= M_AHB_HWRITE;
M2_AHB_HWRITE <= '0';
M3_AHB_HWRITE <= '0';
M4_AHB_HWRITE <= '0';
M5_AHB_HWRITE <= '0';
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= M_AHB_HNONSEC;
M2_AHB_HNONSEC <= '0';
M3_AHB_HNONSEC <= '0';
M4_AHB_HNONSEC <= '0';
M5_AHB_HNONSEC <= '0';
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M2_AHB_HMASTLOCK <= '0';
M3_AHB_HMASTLOCK <= '0';
M4_AHB_HMASTLOCK <= '0';
M5_AHB_HMASTLOCK <= '0';
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= M_AHB_HADDR;
M2_AHB_HADDR <= (others => '0');
M3_AHB_HADDR <= (others => '0');
M4_AHB_HADDR <= (others => '0');
M5_AHB_HADDR <= (others => '0');
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= M_AHB_HSIZE;
M2_AHB_HSIZE <= (others => '0');
M3_AHB_HSIZE <= (others => '0');
M4_AHB_HSIZE <= (others => '0');
M5_AHB_HSIZE <= (others => '0');
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= M_AHB_HBURST;
M2_AHB_HBURST <= (others => '0');
M3_AHB_HBURST <= (others => '0');
M4_AHB_HBURST <= (others => '0');
M5_AHB_HBURST <= (others => '0');
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= M_AHB_HPROT;
M2_AHB_HPROT <= (others => '0');
M3_AHB_HPROT <= (others => '0');
M4_AHB_HPROT <= (others => '0');
M5_AHB_HPROT <= (others => '0');
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= M_AHB_HTRANS;
M2_AHB_HTRANS <= (others => '0');
M3_AHB_HTRANS <= (others => '0');
M4_AHB_HTRANS <= (others => '0');
M5_AHB_HTRANS <= (others => '0');
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= M_AHB_HWDATA;
M2_AHB_HWDATA <= (others => '0');
M3_AHB_HWDATA <= (others => '0');
M4_AHB_HWDATA <= (others => '0');
M5_AHB_HWDATA <= (others => '0');
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= M_AHB_HSEL(1);
M2_AHB_HSEL <= '0';
M3_AHB_HSEL <= '0';
M4_AHB_HSEL <= '0';
M5_AHB_HSEL <= '0';
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;
M_AHB_HRESP(1) <= M1_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;
M_AHB_HREADY(1) <= M1_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;
M_AHB_HRDATA(1) <= M1_AHB_HRDATA;

end generate NBRE_BUS_2;

NBRE_BUS_1 : if (NBRE_SEL=1) generate

--M0_AHB_HCLK <= M_AHB_HCLK;
--M1_AHB_HCLK <= '0';
--M2_AHB_HCLK <= '0';
--M3_AHB_HCLK <= '0';
--M4_AHB_HCLK <= '0';
--M5_AHB_HCLK <= '0';
--M6_AHB_HCLK <= '0';
--M7_AHB_HCLK <= '0';

M0_AHB_HRESETN <= M_AHB_HRESETN;
M1_AHB_HRESETN <= '0';
M2_AHB_HRESETN <= '0';
M3_AHB_HRESETN <= '0';
M4_AHB_HRESETN <= '0';
M5_AHB_HRESETN <= '0';
M6_AHB_HRESETN <= '0';
M7_AHB_HRESETN <= '0';

M0_AHB_HWRITE <= M_AHB_HWRITE;
M1_AHB_HWRITE <= '0';
M2_AHB_HWRITE <= '0';
M3_AHB_HWRITE <= '0';
M4_AHB_HWRITE <= '0';
M5_AHB_HWRITE <= '0';
M6_AHB_HWRITE <= '0';
M7_AHB_HWRITE <= '0';

M0_AHB_HNONSEC <= M_AHB_HNONSEC;
M1_AHB_HNONSEC <= '0';
M2_AHB_HNONSEC <= '0';
M3_AHB_HNONSEC <= '0';
M4_AHB_HNONSEC <= '0';
M5_AHB_HNONSEC <= '0';
M6_AHB_HNONSEC <= '0';
M7_AHB_HNONSEC <= '0';

M0_AHB_HMASTLOCK <= M_AHB_HMASTLOCK;
M1_AHB_HMASTLOCK <= '0';
M2_AHB_HMASTLOCK <= '0';
M3_AHB_HMASTLOCK <= '0';
M4_AHB_HMASTLOCK <= '0';
M5_AHB_HMASTLOCK <= '0';
M6_AHB_HMASTLOCK <= '0';
M7_AHB_HMASTLOCK <= '0';

M0_AHB_HADDR <= M_AHB_HADDR;
M1_AHB_HADDR <= (others => '0');
M2_AHB_HADDR <= (others => '0');
M3_AHB_HADDR <= (others => '0');
M4_AHB_HADDR <= (others => '0');
M5_AHB_HADDR <= (others => '0');
M6_AHB_HADDR <= (others => '0');
M7_AHB_HADDR <= (others => '0');

M0_AHB_HSIZE <= M_AHB_HSIZE;
M1_AHB_HSIZE <= (others => '0');
M2_AHB_HSIZE <= (others => '0');
M3_AHB_HSIZE <= (others => '0');
M4_AHB_HSIZE <= (others => '0');
M5_AHB_HSIZE <= (others => '0');
M6_AHB_HSIZE <= (others => '0');
M7_AHB_HSIZE <= (others => '0');

M0_AHB_HBURST <= M_AHB_HBURST;
M1_AHB_HBURST <= (others => '0');
M2_AHB_HBURST <= (others => '0');
M3_AHB_HBURST <= (others => '0');
M4_AHB_HBURST <= (others => '0');
M5_AHB_HBURST <= (others => '0');
M6_AHB_HBURST <= (others => '0');
M7_AHB_HBURST <= (others => '0');

M0_AHB_HPROT <= M_AHB_HPROT;
M1_AHB_HPROT <= (others => '0');
M2_AHB_HPROT <= (others => '0');
M3_AHB_HPROT <= (others => '0');
M4_AHB_HPROT <= (others => '0');
M5_AHB_HPROT <= (others => '0');
M6_AHB_HPROT <= (others => '0');
M7_AHB_HPROT <= (others => '0');

M0_AHB_HTRANS <= M_AHB_HTRANS;
M1_AHB_HTRANS <= (others => '0');
M2_AHB_HTRANS <= (others => '0');
M3_AHB_HTRANS <= (others => '0');
M4_AHB_HTRANS <= (others => '0');
M5_AHB_HTRANS <= (others => '0');
M6_AHB_HTRANS <= (others => '0');
M7_AHB_HTRANS <= (others => '0');

M0_AHB_HWDATA <= M_AHB_HWDATA;
M1_AHB_HWDATA <= (others => '0');
M2_AHB_HWDATA <= (others => '0');
M3_AHB_HWDATA <= (others => '0');
M4_AHB_HWDATA <= (others => '0');
M5_AHB_HWDATA <= (others => '0');
M6_AHB_HWDATA <= (others => '0');
M7_AHB_HWDATA <= (others => '0');

M0_AHB_HSEL <= M_AHB_HSEL(0);
M1_AHB_HSEL <= '0';
M2_AHB_HSEL <= '0';
M3_AHB_HSEL <= '0';
M4_AHB_HSEL <= '0';
M5_AHB_HSEL <= '0';
M6_AHB_HSEL <= '0';
M7_AHB_HSEL <= '0';

M_AHB_HRESP(0) <= M0_AHB_HRESP;

M_AHB_HREADY(0) <= M0_AHB_HREADY;

M_AHB_HRDATA(0) <= M0_AHB_HRDATA;

end generate NBRE_BUS_1;

FIFO_DATA : sync_fifo
generic map (
	DW => 64,
	AW => 4
)
port map (
	clk_i => S_AXI_ACLK,
	rst_ni => S_AXI_ARESETN,
	wen_i => FIFO_WEn,
	data_i => FIFO_DataIn,
	full_o => FIFO_Full,
	ren_i => S_AXI_RREADY,
	data_o => S_AXI_RDATA,
	empty_o => FIFO_Empty
);

FIFO_RRESP : sync_fifo
generic map (
	DW => 2,
	AW => 4
)
port map (
	clk_i => S_AXI_ACLK,
	rst_ni => S_AXI_ARESETN,
	wen_i => FIFO_WEn,
	data_i => s_RRESP,
	full_o => open,
	ren_i => S_AXI_RREADY,
	data_o => S_AXI_RRESP,
	empty_o => open
);

Resetp <= not S_AXI_ARESETN;

Current_Index <= Current_Index_W when s_HWRITE='1' else Current_Index_R;
s_HREADY <= M_AHB_HREADY(conv_integer(Current_Index));
s_HRESP <= M_AHB_HRESP(conv_integer(Current_Index));
s_HRDATA <= M_AHB_HRDATA(conv_integer(Current_Index_R));

S_AXI_AWREADY <= s_AWREADY;
S_AXI_ARREADY <= s_ARREADY;

S_AXI_WREADY <= s_WREADY_On or (s_HREADY and s_WREADY_En);
FIFO_WEn <= s_FIFO_On or (s_HREADY and s_FIFO_En);
S_AXI_RVALID <= not FIFO_Empty;

FIFO_DataIn <= s_HRDATA when s_FIFO_En='1' else s_RDATA;

s_RRESP <= "10" when (s_RdErrorLatch or (s_HRESP and not s_HWRITE))='1' else "00";

--M_AHB_HCLK <= S_AXI_ACLK;
M_AHB_HRESETN <= S_AXI_ARESETN;
M_AHB_HWRITE <= s_HWRITE;

M_AHB_HSIZE <= s_HSIZE_W when s_HWRITE='1' else s_HSIZE_R;
M_AHB_HPROT <= s_HPROT_W when s_HWRITE='1' else s_HPROT_R;
M_AHB_HMASTLOCK <= '0'; -- unsupported signal
M_AHB_HBURST <= s_HBURST_W when s_HWRITE='1' else s_HBURST_R;
M_AHB_HADDR <= s_AddrW when s_HWRITE='1' else s_AddrR;
M_AHB_HTRANS <= s_HTRANS_W when s_HWRITE='1' else s_HTRANS_R;
M_AHB_HNONSEC <= s_HNONSEC_W when s_HWRITE = '1' else s_HNONSEC_R;
M_AHB_HSEL <= s_SEL_W when s_HWRITE = '1' else s_SEL_R;

s_IncW <= (s_HREADY and s_HWRITE) and s_IncWEn;
s_IncR <= (s_HREADY and not s_HWRITE) and s_IncREn;

Strb16_0 <= (S_AXI_WSTRB(0) and S_AXI_WSTRB(1)) or (S_AXI_WSTRB(2) and S_AXI_WSTRB(3));
Strb16_1 <= (S_AXI_WSTRB(4) and S_AXI_WSTRB(5)) or (S_AXI_WSTRB(6) and S_AXI_WSTRB(7));
Strb16_test <= Strb16_0 or Strb16_1;
Strb32_0 <= S_AXI_WSTRB(0) and S_AXI_WSTRB(1) and S_AXI_WSTRB(2) and S_AXI_WSTRB(3);
Strb32_1 <= S_AXI_WSTRB(4) and S_AXI_WSTRB(5) and S_AXI_WSTRB(6) and S_AXI_WSTRB(7);
Strb32_test <= Strb32_0 or Strb32_1;

AlignR16 <= not S_AXI_ARADDR(0);
AlignR32 <= not (S_AXI_ARADDR(1) or S_AXI_ARADDR(0));
AlignR64 <= not (S_AXI_ARADDR(2) or S_AXI_ARADDR(1) or S_AXI_ARADDR(0));
AlignR128 <= not (S_AXI_ARADDR(3) or S_AXI_ARADDR(2) or S_AXI_ARADDR(1) or S_AXI_ARADDR(0));
AlignW16 <= not S_AXI_AWADDR(0);
AlignW32 <= not (S_AXI_AWADDR(1) or S_AXI_AWADDR(0));
AlignW64 <= not (S_AXI_AWADDR(2) or S_AXI_AWADDR(1) or S_AXI_AWADDR(0));
AlignW128 <= not (S_AXI_AWADDR(3) or S_AXI_AWADDR(2) or S_AXI_AWADDR(1) or S_AXI_AWADDR(0));

-- Arbitrage R/W

process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		s_AWVALID <= '0';
		s_ARVALID <= '0';
		fsm_arbit <= ARBIT_IDLE_R;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_arbit is
			when ARBIT_IDLE_R =>
				s_ARVALID <= '0';
				s_AWVALID <= '0';
				if S_AXI_ARVALID='1' then
					s_ARVALID <= '1';
					fsm_arbit <= ARBIT_WAIT_R_ACK;
				elsif S_AXI_AWVALID='1' then
					s_AWVALID <= '1';
					fsm_arbit <= ARBIT_WAIT_W_ACK;
				end if;
			
			when ARBIT_IDLE_W =>
				s_AWVALID <= '0';
				s_ARVALID <= '0';
				if S_AXI_AWVALID='1' then
					s_AWVALID <= '1';
					fsm_arbit <= ARBIT_WAIT_W_ACK;
				elsif S_AXI_ARVALID='1' then
					s_ARVALID <= '1';
					fsm_arbit <= ARBIT_WAIT_R_ACK;
				end if;
				
			when ARBIT_WAIT_R_ACK =>
				if s_ARREADY='1' then
					s_ARVALID <= '0';
					fsm_arbit <= ARBIT_WAIT_R_END;
				end if;
					
			when ARBIT_WAIT_R_END =>
				if s_RdEnd='1' then fsm_arbit <= ARBIT_IDLE_W;
				end if;
					
			when ARBIT_WAIT_W_ACK =>
				if s_AWREADY='1' then
					s_AWVALID <= '0';
					fsm_arbit <= ARBIT_WAIT_W_END;
				end if;
					
			when ARBIT_WAIT_W_END =>
				if s_WrEnd='1' then fsm_arbit <= ARBIT_IDLE_R;
				end if;
				
			when others => fsm_arbit <= ARBIT_IDLE_R;
		end case;
	end if;
end process;

----------------------

ADDRESS_GEN_1 : if (BURST_ADDR_WIDTH>=AHB_ADDR_WIDTH) generate

s_AddrW <= s_AddrWCpt;
s_AddrR <= s_AddrRCpt;

end generate ADDRESS_GEN_1;

----------------------

ADDRESS_GEN_2 : if (BURST_ADDR_WIDTH<AHB_ADDR_WIDTH) generate

s_AddrW <= s_AWADDR(AHB_ADDR_WIDTH-1 downto BURST_ADDR_WIDTH)&s_AddrWCpt;
s_AddrR <= s_ARADDR(AHB_ADDR_WIDTH-1 downto BURST_ADDR_WIDTH)&s_AddrRCpt;

end generate ADDRESS_GEN_2;

-- Gestion adresse écriture

Cpt_W : Compteur_Addr
generic map
(
	DATA_WIDTH => CPT_ADDR_WIDTH,
	MASK_WIDTH => CPT_MASK_WIDTH
)
port map
(
	Clk => S_AXI_ACLK,
	Inc_Step => s_IncStepW,
	Mask => s_Mask,
	Wrap => s_WrapW,
	WrapMask => s_WrapMaskW,
	Data_In => S_AXI_AWADDR(CPT_ADDR_WIDTH-1 downto 0),
	Data_Load => s_AWREADY,
	Data_Inc => s_IncW,
	Data_Out => s_AddrWCpt
);

process(S_AXI_ARESETN,S_AXI_ACLK)
variable index  : natural range 0 to NBRE_SEL;
begin
	if S_AXI_ARESETN='0' then
		s_AWREADY <= '0';
		s_WrErr <= '0';
		s_WrAddr <= '0';
		s_HWRITE <= '0';
		s_ADDRW_Ok <= '0';
		fsm_w_add_axi <= ADDR_AXI_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_w_add_axi is
			when ADDR_AXI_IDLE =>
				s_AWREADY <= '0';
				s_SEL_W <= (others => '0');
				s_HWRITE <= '0';
				s_WrapMaskW <= (others => '0');
				s_WrapTestW <= (others => '0');
				s_AddrIncW <= (others => '0');
				s_AddrW_Test <= (others => '0');
				if s_AWVALID='1' then
					addr_map_decode(AHB_ADDR_MAP,MSB_DECODER,AHB_ADDR_TEST_LSB,S_AXI_AWADDR,index);
					if index=NBRE_SEL then s_ADDRW_Ok <= '0';
					else
						Current_Index_W <= index;
						s_ADDRW_Ok <= '1';
					end if;
					fsm_w_add_axi <= ADDR_AXI_TEST_1;
				else s_ADDRW_Ok <= '0';
				end if;

			when ADDR_AXI_TEST_1 =>
				if s_ADDRW_Ok='1' then
					s_WrapW <= S_AXI_AWBURST(1) and not S_AXI_AWBURST(0);
					s_AddrW_Test(MSB_DECODER downto 0) <= S_AXI_AWADDR(MSB_DECODER downto 0);
					case S_AXI_AWSIZE is
						when "000" =>
							s_AddrIncW(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_AWLEN;
							s_WrapTestW(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_AWLEN;
						when "001" =>
							s_AddrIncW(AXI_BURST_WIDTH downto 1) <= S_AXI_AWLEN;
							s_WrapTestW(AXI_BURST_WIDTH downto 0) <= S_AXI_AWLEN&"1";
							if AlignW16='0' then s_ADDRW_Ok <= '0';
							end if;
						when "010" =>
							s_AddrIncW(AXI_BURST_WIDTH+1 downto 2) <= S_AXI_AWLEN;
							s_WrapTestW(AXI_BURST_WIDTH+1 downto 0) <= S_AXI_AWLEN&"11";
							if AlignW32='0' then s_ADDRW_Ok <= '0';
							end if;
						when "011" =>
							s_AddrIncW(AXI_BURST_WIDTH+2 downto 3) <= S_AXI_AWLEN;
							s_WrapTestW(AXI_BURST_WIDTH+2 downto 0) <= S_AXI_AWLEN&"111";
							if AlignW64='0' then s_ADDRW_Ok <= '0';
							end if;
						when "100" =>
							s_AddrIncW(AXI_BURST_WIDTH+3 downto 4) <= S_AXI_AWLEN;
							s_WrapTestW(AXI_BURST_WIDTH+3 downto 0) <= S_AXI_AWLEN&"1111";
							if AlignW128='0' then s_ADDRW_Ok <= '0';
							end if;
						when others => s_ADDRW_Ok <= '0';
					end case;
				end if;
				fsm_w_add_axi <= ADDR_AXI_TEST_2;

			when ADDR_AXI_TEST_2 =>
				if s_ADDRW_Ok='1' then
					if s_WrapW='1' then
						if ((S_AXI_AWADDR(MSB_DECODER downto 0) or s_WrapTestW(MSB_DECODER downto 0))>AHB_ADDR_MAP(Current_Index_W).end_addr(MSB_DECODER downto 0)) or
							((S_AXI_AWADDR(MSB_DECODER downto 0) and not s_WrapTestW(MSB_DECODER downto 0))<AHB_ADDR_MAP(Current_Index_W).start_addr(MSB_DECODER downto 0))
							then s_ADDRW_Ok <= '0';
						end if;
					else
						if (s_AddrW_Test+s_AddrIncW)>(AHB_ADDR_MAP(Current_Index_W).end_addr and ADDR_TEST_MASK)
							then s_ADDRW_Ok <= '0';
						end if;
					end if;
				end if;
				fsm_w_add_axi <= ADDR_AXI_TEST_3;
			
			when ADDR_AXI_TEST_3 =>
				s_LenW <= S_AXI_AWLEN;
				S_AXI_BID <= S_AXI_AWID;
				s_AWREADY <= '1';
				s_HWRITE <= '1';
				if s_ADDRW_Ok='1' then
					s_SEL_W(Current_Index_W) <= '1';					
					s_WrAddr <= '1';
					s_HSIZE_W <= S_AXI_AWSIZE;
					s_HPROT_W(0) <= not S_AXI_AWPROT(2);
					s_HPROT_W(1) <= S_AXI_AWPROT(0);
					s_HPROT_W(2) <= S_AXI_AWCACHE(0);
					s_HPROT_W(3) <= S_AXI_AWCACHE(1);
					s_HPROT_W(4) <= S_AXI_AWCACHE(2);
					s_HPROT_W(5) <= S_AXI_AWCACHE(3);
					s_HPROT_W(6) <= '0';
					s_HNONSEC_W  <= S_AXI_AWPROT(1);
					s_AWADDR <= S_AXI_AWADDR;

					if S_AXI_AWLEN=FIN_BURST then s_HBURST_W <= "000";
					elsif S_AXI_AWLEN=conv_std_logic_vector(3,AXI_BURST_WIDTH) then
						s_HBURST_W <= "01"&(S_AXI_AWBURST(0) and not S_AXI_AWBURST(1));
					elsif S_AXI_AWLEN=conv_std_logic_vector(7,AXI_BURST_WIDTH) then
						s_HBURST_W <= "10"&(S_AXI_AWBURST(0) and not S_AXI_AWBURST(1));
					elsif S_AXI_AWLEN=conv_std_logic_vector(15,AXI_BURST_WIDTH) then
						s_HBURST_W <= "11"&(S_AXI_AWBURST(0) and not S_AXI_AWBURST(1));
					else s_HBURST_W <= "001";
					end if;
					
					case S_AXI_AWSIZE is
						when "000" =>
							s_IncStepW <= conv_std_logic_vector(1,CPT_MASK_WIDTH+1);
							s_WrapMaskW(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_AWLEN;
						when "001" =>
							s_IncStepW <= conv_std_logic_vector(2,CPT_MASK_WIDTH+1);
							s_WrapMaskW(AXI_BURST_WIDTH downto 0) <= S_AXI_AWLEN&"1";
						when "010" =>
							s_IncStepW <= conv_std_logic_vector(4,CPT_MASK_WIDTH+1);
							s_WrapMaskW(AXI_BURST_WIDTH+1 downto 0) <= S_AXI_AWLEN&"11";
						when "011" =>
							s_IncStepW <= conv_std_logic_vector(8,CPT_MASK_WIDTH+1);
							s_WrapMaskW(AXI_BURST_WIDTH+2 downto 0) <= S_AXI_AWLEN&"111";
						when "100" =>
							s_IncStepW <= conv_std_logic_vector(16,CPT_MASK_WIDTH+1);
							s_WrapMaskW(AXI_BURST_WIDTH+3 downto 0) <= S_AXI_AWLEN&"1111";
						when others => s_WrErr <= '1';
					end case;
				else s_WrErr <= '1';
				end if;
				fsm_w_add_axi <= ADDR_AXI_WAIT_START;
					
			when ADDR_AXI_WAIT_START =>
				s_AWREADY <= '0';
				if s_WrStart='1' then
					s_WrAddr <= '0';
					s_WrErr <= '0';
					fsm_w_add_axi <= ADDR_AXI_WAIT_END;
				end if;
			
			when ADDR_AXI_WAIT_END =>
				if s_WrEnd='1' then
					s_ADDRW_Ok <= '0';
					fsm_w_add_axi <= ADDR_AXI_IDLE;
				end if;
			
			when others => fsm_w_add_axi <= ADDR_AXI_IDLE;
		end case;
	end if;
end process;

-- Gestion adresse lecture

Cpt_R : Compteur_Addr
generic map
(
	DATA_WIDTH => CPT_ADDR_WIDTH,
	MASK_WIDTH => CPT_MASK_WIDTH
)
port map
(
	Clk => S_AXI_ACLK,
	Inc_Step => s_IncStepR,
	Mask => s_Mask,
	Wrap => s_WrapR,
	WrapMask => s_WrapMaskR,
	Data_In => S_AXI_ARADDR(CPT_ADDR_WIDTH-1 downto 0),
	Data_Load => s_ARREADY,
	Data_Inc => s_IncR,
	Data_Out => s_AddrRCpt
);

process(S_AXI_ARESETN,S_AXI_ACLK)
variable index  : natural range 0 to NBRE_SEL;
begin
	if S_AXI_ARESETN='0' then
		s_ARREADY <= '0';
		s_RdErr <= '0';
		s_RdAddr <= '0';
		s_ADDRR_Ok <= '0';
		fsm_r_add_axi <= ADDR_AXI_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_add_axi is
			when ADDR_AXI_IDLE =>
				s_ARREADY <= '0';
				s_SEL_R <= (others => '0');
				s_WrapMaskR <= (others => '0');
				s_WrapTestR <= (others => '0');
				s_AddrIncR <= (others => '0');
				s_AddrR_Test <= (others => '0');
				if s_ARVALID='1' then
					addr_map_decode(AHB_ADDR_MAP,MSB_DECODER,AHB_ADDR_TEST_LSB,S_AXI_ARADDR,index);
					if index=NBRE_SEL then s_ADDRR_Ok <= '0';
					else
						Current_Index_R <= index;
						s_ADDRR_Ok <= '1';
					end if;
					fsm_r_add_axi <= ADDR_AXI_TEST_1;
				else s_ADDRR_Ok <= '0';
				end if;
				
			when ADDR_AXI_TEST_1 =>
				if s_ADDRR_Ok='1' then
					s_WrapR <= S_AXI_ARBURST(1) and not S_AXI_ARBURST(0);
					s_AddrR_Test(MSB_DECODER downto 0) <= S_AXI_ARADDR(MSB_DECODER downto 0);
					case S_AXI_ARSIZE is
						when "000" =>
							s_AddrIncR(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_ARLEN;
							s_WrapTestR(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_ARLEN;
						when "001" =>
							s_AddrIncR(AXI_BURST_WIDTH downto 1) <= S_AXI_ARLEN;
							s_WrapTestR(AXI_BURST_WIDTH downto 0) <= S_AXI_ARLEN&"1";
							if AlignR16='0' then s_ADDRR_Ok <= '0';
							end if;
						when "010" =>
							s_AddrIncR(AXI_BURST_WIDTH+1 downto 2) <= S_AXI_ARLEN;
							s_WrapTestR(AXI_BURST_WIDTH+1 downto 0) <= S_AXI_ARLEN&"11";
							if AlignR32='0' then s_ADDRR_Ok <= '0';
							end if;
						when "011" =>
							s_AddrIncR(AXI_BURST_WIDTH+2 downto 3) <= S_AXI_ARLEN;
							s_WrapTestR(AXI_BURST_WIDTH+2 downto 0) <= S_AXI_ARLEN&"111";
							if AlignR64='0' then s_ADDRR_Ok <= '0';
							end if;
						when "100" =>
							s_AddrIncR(AXI_BURST_WIDTH+3 downto 4) <= S_AXI_ARLEN;
							s_WrapTestR(AXI_BURST_WIDTH+3 downto 0) <= S_AXI_ARLEN&"1111";
							if AlignR128='0' then s_ADDRR_Ok <= '0';
							end if;
						when others => s_ADDRR_Ok <= '0';
					end case;
				end if;
				fsm_r_add_axi <= ADDR_AXI_TEST_2;
				
			when ADDR_AXI_TEST_2 =>
				if s_ADDRR_Ok='1' then
					if s_WrapR='1' then
						if ((S_AXI_ARADDR(MSB_DECODER downto 0) or s_WrapTestR(MSB_DECODER downto 0))>AHB_ADDR_MAP(Current_Index_R).end_addr(MSB_DECODER downto 0)) or
							((S_AXI_ARADDR(MSB_DECODER downto 0) and not s_WrapTestR(MSB_DECODER downto 0))<AHB_ADDR_MAP(Current_Index_R).start_addr(MSB_DECODER downto 0))
							then s_ADDRR_Ok <= '0';
						end if;
					else
						if (s_AddrR_Test+s_AddrIncR)>(AHB_ADDR_MAP(Current_Index_R).end_addr and ADDR_TEST_MASK)
							then s_ADDRR_Ok <= '0';
						end if;
					end if;
				end if;
				fsm_r_add_axi <= ADDR_AXI_TEST_3;

			when ADDR_AXI_TEST_3 =>
				s_LenR <= S_AXI_ARLEN;
				S_AXI_RID <= S_AXI_ARID;
				s_ARREADY <= '1';
				if s_ADDRR_Ok='1' then
					s_SEL_R(Current_Index_R) <= '1';
					s_RdAddr <= '1';
					s_HSIZE_R <= S_AXI_ARSIZE;
					s_HPROT_R(0) <= not S_AXI_ARPROT(2);
					s_HPROT_R(1) <= S_AXI_ARPROT(0);
					s_HPROT_R(2) <= S_AXI_ARCACHE(0);
					s_HPROT_R(3) <= S_AXI_ARCACHE(1);
					s_HPROT_R(4) <= S_AXI_ARCACHE(3);
					s_HPROT_R(5) <= S_AXI_ARCACHE(2);
					s_HPROT_R(6) <= '0';
					s_HNONSEC_R  <= S_AXI_ARPROT(1);
					s_ARADDR <= S_AXI_ARADDR;

					if S_AXI_ARLEN=FIN_BURST then s_HBURST_R <= "000";
					elsif S_AXI_ARLEN=conv_std_logic_vector(3,AXI_BURST_WIDTH) then
						s_HBURST_R <= "01"&(S_AXI_ARBURST(0) and not S_AXI_ARBURST(1));
					elsif S_AXI_ARLEN=conv_std_logic_vector(7,AXI_BURST_WIDTH) then
						s_HBURST_R <= "10"&(S_AXI_ARBURST(0) and not S_AXI_ARBURST(1));
					elsif S_AXI_ARLEN=conv_std_logic_vector(15,AXI_BURST_WIDTH) then
						s_HBURST_R <= "11"&(S_AXI_ARBURST(0) and not S_AXI_ARBURST(1));
					else s_HBURST_R <= "001";
					end if;
					
					case S_AXI_ARSIZE is
						when "000" =>
							s_IncStepR <= conv_std_logic_vector(1,CPT_MASK_WIDTH+1);
							s_WrapMaskR(AXI_BURST_WIDTH-1 downto 0) <= S_AXI_ARLEN;
						when "001" =>
							s_IncStepR <= conv_std_logic_vector(2,CPT_MASK_WIDTH+1);
							s_WrapMaskR(AXI_BURST_WIDTH downto 0) <= S_AXI_ARLEN&"1";
						when "010" =>
							s_IncStepR <= conv_std_logic_vector(4,CPT_MASK_WIDTH+1);
							s_WrapMaskR(AXI_BURST_WIDTH+1 downto 0) <= S_AXI_ARLEN&"11";
						when "011" =>
							s_IncStepR <= conv_std_logic_vector(8,CPT_MASK_WIDTH+1);
							s_WrapMaskR(AXI_BURST_WIDTH+2 downto 0) <= S_AXI_ARLEN&"111";
						when "100" =>
							s_IncStepR <= conv_std_logic_vector(16,CPT_MASK_WIDTH+1);
							s_WrapMaskR(AXI_BURST_WIDTH+3 downto 0) <= S_AXI_ARLEN&"1111";
						when others => s_RdErr <= '1';
					end case;
				else s_RdErr <= '1';
				end if;
				fsm_r_add_axi <= ADDR_AXI_WAIT_START;
			
			when ADDR_AXI_WAIT_START =>
				s_ARREADY <= '0';
				if s_RdStart='1' then
					s_RdAddr <= '0';
					s_RdErr <= '0';
					fsm_r_add_axi <= ADDR_AXI_WAIT_END;
				end if;
				
			when ADDR_AXI_WAIT_END =>
				if s_RdEnd='1' then
					s_ADDRR_Ok <= '0';
					fsm_r_add_axi <= ADDR_AXI_IDLE;
				end if;
				
			when others => fsm_r_add_axi <= ADDR_AXI_IDLE;
		end case;
	end if;
end process;


-- Gestion Ecriture Data
process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		S_AXI_BVALID <= '0';
		s_WrEnd <= '0';
		s_WrStart <= '0';
		s_IncWEn <= '0';
		s_HTRANS_W <= "00";
		s_WREADY_On <= '0';
		s_WREADY_En <= '0';
		fsm_w_ahb <= WRITE_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_w_ahb is
			when WRITE_IDLE =>
				S_AXI_BRESP <= "00";
				S_AXI_BVALID <= '0';
				s_WrEnd <= '0';
				s_WREADY_En <= '0';
				-- Valeurs par défaut
				s_WrStart <= '0';
				s_WREADY_On <= '0';
				s_IncWEn <= '0';
				s_HTRANS_W <= "00";
				if s_WrErr='1' then
					s_WREADY_On <= '1';
					s_WrStart <= '1';
					s_BurstLengthW <= s_LenW;
					fsm_w_ahb <= WRITE_ERROR;
				elsif (s_WrAddr and S_AXI_WVALID and not s_HRESP)='1' then
					s_HWDATA <= S_AXI_WDATA;
					case s_HSIZE_W is
						when "000" =>
							if S_AXI_WSTRB="00000000" then S_AXI_BRESP <= "10";
							end if;
						when "001" =>
							if Strb16_test='0' then S_AXI_BRESP <= "10";
							end if;
						when "010" =>
							if Strb32_test='0' then S_AXI_BRESP <= "10";
							end if;
						when "011" =>
							if S_AXI_WSTRB/="11111111" then S_AXI_BRESP <= "10";
							end if;
						when others => NULL;
					end case;
					s_WrStart <= '1';
					s_BurstLengthW <= s_LenW;
					s_WREADY_On <= '1';
					fsm_w_ahb <= WRITE_STEP;
				end if;
				
			when WRITE_STEP =>
				s_WrStart <= '0';
				s_WREADY_On <= '0';
				if s_HRESP='1' then
					if s_BurstLengthW=FIN_BURST then
						S_AXI_BRESP <= "10";
						S_AXI_BVALID <= '1';
						fsm_w_ahb <= WRITE_WAIT_BREADY;
					else
						s_WREADY_On <= '1';
						s_BurstLengthW <= s_BurstLengthW-1;
						fsm_w_ahb <= WRITE_ERROR;
					end if;
				else
					if s_BurstLengthW/=FIN_BURST then s_WREADY_En <= '1';
					end if;
					s_IncWEn <= '1';
					s_HTRANS_W <= "10";
					fsm_w_ahb <= WRITE_WAIT_ADDR_ACK;
				end if;
			
			when WRITE_WAIT_ADDR_ACK =>
				if s_HRESP='1' then
					s_HTRANS_W <= "00";
					s_WREADY_En <= '0';
					s_IncWEn <= '0';
					if s_BurstLengthW=FIN_BURST then
						S_AXI_BRESP <= "10";
						S_AXI_BVALID <= '1';
						fsm_w_ahb <= WRITE_WAIT_BREADY;
					else
						if (s_HREADY and S_AXI_WVALID)='1' then
							if s_BurstLengthW=BURST_01 then
								S_AXI_BRESP <= "10";
								S_AXI_BVALID <= '1';
								fsm_w_ahb <= WRITE_WAIT_BREADY;
							else
								s_WREADY_On <= '1';
								s_BurstLengthW <= s_BurstLengthW-2;
								fsm_w_ahb <= WRITE_ERROR;
							end if;
						else
							s_WREADY_On <= '1';
							s_BurstLengthW <= s_BurstLengthW-1;
							fsm_w_ahb <= WRITE_ERROR;
						end if;
					end if;
				elsif s_HREADY='1' then
					M_AHB_HWDATA <= s_HWDATA;
					if s_BurstLengthW=FIN_BURST then
						s_HTRANS_W <= "00";
						s_IncWEn <= '0';
						fsm_w_ahb <= WRITE_WAIT_LAST_ACK;
					else
						s_BurstLengthW <= s_BurstLengthW-1;
						if s_BurstLengthW=BURST_01 then s_WREADY_En <= '0';
						end if;
						if S_AXI_WVALID='1' then
							s_HWDATA <= S_AXI_WDATA;
							case s_HSIZE_W is
								when "000" =>
									if S_AXI_WSTRB="00000000" then S_AXI_BRESP <= "10";
									end if;
								when "001" =>
									if Strb16_test='0' then S_AXI_BRESP <= "10";
									end if;
								when "010" =>
									if Strb32_test='0' then S_AXI_BRESP <= "10";
									end if;
								when "011" =>
									if S_AXI_WSTRB/="11111111" then S_AXI_BRESP <= "10";
									end if;
								when others => NULL;
							end case;
							s_HTRANS_W <= "11";
							fsm_w_ahb <= WRITE_WAIT_ACK;
						else
							s_WREADY_On <= '1';
							s_HTRANS_W <= "01";
							s_IncWEn <= '0';
							fsm_w_ahb <= WRITE_WAIT_WVALID;
						end if;
					end if;
				end if;
			
			when WRITE_WAIT_LAST_ACK =>
				if s_HRESP='1' then
					S_AXI_BRESP <= "10";
					S_AXI_BVALID <= '1';
					fsm_w_ahb <= WRITE_WAIT_BREADY;
				elsif s_HREADY='1' then
					S_AXI_BVALID <= '1';
					fsm_w_ahb <= WRITE_WAIT_BREADY;
				end if;

			when WRITE_WAIT_ACK =>
				if s_HRESP='1' then
					s_HTRANS_W <= "00";
					s_WREADY_En <= '0';
					s_IncWEn <= '0';
					if s_BurstLengthW=FIN_BURST then
						S_AXI_BRESP <= "10";
						S_AXI_BVALID <= '1';
						fsm_w_ahb <= WRITE_WAIT_BREADY;
					else
						if (s_HREADY and S_AXI_WVALID)='1' then
							if s_BurstLengthW=BURST_01 then
								S_AXI_BRESP <= "10";
								S_AXI_BVALID <= '1';
								fsm_w_ahb <= WRITE_WAIT_BREADY;
							else
								s_WREADY_On <= '1';
								s_BurstLengthW <= s_BurstLengthW-2;
								fsm_w_ahb <= WRITE_ERROR;
							end if;
						else
							s_WREADY_On <= '1';
							s_BurstLengthW <= s_BurstLengthW-1;
							fsm_w_ahb <= WRITE_ERROR;
						end if;
					end if;
				elsif s_HREADY='1' then
					M_AHB_HWDATA <= s_HWDATA;
					s_BurstLengthW <= s_BurstLengthW-1;
					if s_BurstLengthW=BURST_01 then s_WREADY_En <= '0';
					end if;
					if s_BurstLengthW=FIN_BURST then
						s_HTRANS_W <= "00";
						s_IncWEn <= '0';
						fsm_w_ahb <= WRITE_WAIT_LAST_ACK;
					elsif S_AXI_WVALID='1' then
						s_HWDATA <= S_AXI_WDATA;
						case s_HSIZE_W is
							when "000" =>
								if S_AXI_WSTRB="00000000" then S_AXI_BRESP <= "10";
								end if;
							when "001" =>
								if Strb16_test='0' then S_AXI_BRESP <= "10";
								end if;
							when "010" =>
								if Strb32_test='0' then S_AXI_BRESP <= "10";
								end if;
							when "011" =>
								if S_AXI_WSTRB/="11111111" then S_AXI_BRESP <= "10";
								end if;
							when others => NULL;
						end case;
					else
						s_WREADY_On <= '1';
						s_HTRANS_W <= "01";
						s_IncWEn <= '0';
						fsm_w_ahb <= WRITE_WAIT_WVALID;
					end if;
				end if;

			when WRITE_WAIT_WVALID =>
				if s_HRESP='1' then
					s_HTRANS_W <= "00";
					s_WREADY_En <= '0';
					if S_AXI_WVALID='1' then
						if s_BurstLengthW=FIN_BURST then
							S_AXI_BRESP <= "10";
							S_AXI_BVALID <= '1';
							s_WREADY_On <= '0';
							fsm_w_ahb <= WRITE_WAIT_BREADY;
						else
							s_BurstLengthW <= s_BurstLengthW-1;
							fsm_w_ahb <= WRITE_ERROR;
						end if;
					else fsm_w_ahb <= WRITE_ERROR;
					end if;
				elsif S_AXI_WVALID='1' then
					s_HWDATA <= S_AXI_WDATA;
					case s_HSIZE_W is
						when "000" =>
							if S_AXI_WSTRB="00000000" then S_AXI_BRESP <= "10";
							end if;
						when "001" =>
							if Strb16_test='0' then S_AXI_BRESP <= "10";
							end if;
						when "010" =>
							if Strb32_test='0' then S_AXI_BRESP <= "10";
							end if;
						when "011" =>
							if S_AXI_WSTRB/="11111111" then S_AXI_BRESP <= "10";
							end if;
						when others => NULL;
					end case;
					s_HTRANS_W <= "11";
					s_WREADY_On <= '0';
					s_IncWEn <= '1';
					fsm_w_ahb <= WRITE_WAIT_ACK;
				end if;

			when WRITE_ERROR =>
				s_WrStart <= '0';
				if S_AXI_WVALID='1' then
					if s_BurstLengthW=FIN_BURST then
						s_WREADY_On <= '0';
						S_AXI_BRESP <= "10";
						S_AXI_BVALID <= '1';
						fsm_w_ahb <= WRITE_WAIT_BREADY;
					else s_BurstLengthW <= s_BurstLengthW-1;
					end if;
				end if;
				
			when WRITE_WAIT_BREADY =>
				if S_AXI_BREADY='1' then
					s_WrEnd <= '1';
					S_AXI_BVALID <= '0';
					fsm_w_ahb <= WRITE_IDLE;
				end if;
			
			when others => fsm_w_ahb <= WRITE_IDLE;
		end case;
	end if;
end process;


-- Gestion Lecture Data

process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		S_AXI_RLAST <= '0';
		fsm_r_last <= READ_WAIT_START;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_last is
			when READ_WAIT_START =>
				s_LengthR <= s_LenR;
				S_AXI_RLAST <= '0';
				if (s_RdErr or (s_RdAddr and FIFo_Empty))='1' then
					if s_LenR=FIN_BURST then S_AXI_RLAST <= '1';
					end if;
					fsm_r_last <= READ_WAIT_FIFO_RREADY;
				end if;
				
			when READ_WAIT_FIFO_RREADY =>
				if (S_AXI_RREADY and not FIFo_Empty)='1' then
					if s_LengthR=FIN_BURST then
						S_AXI_RLAST <= '0';
						fsm_r_last <= READ_WAIT_START;
					else
						s_LengthR <= s_LengthR-1;
						if s_LengthR=BURST_01 then S_AXI_RLAST <= '1';
						end if;
					end if;
				end if;
		end case;
	end if;
end process;

process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		s_HTRANS_R <= "00";
		s_IncREn <= '0';
		s_FIFO_On <= '0';
		s_FIFO_En <= '0';
		s_RdEnd <= '0';
		s_RdStart <= '0';
		fsm_r_ahb <= READ_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_ahb is
			when READ_IDLE =>
				s_FIFO_En <= '0';
				s_RdEnd <= '0';
				-- Valeurs par défaut
				s_RdErrorLatch <= '0';
				s_FIFO_On <= '0';
				s_RdStart <= '0';
				s_IncREn <= '0';
				s_HTRANS_R <= "00";
				if s_RdErr='1' then
					s_FIFO_On <= '1';
					s_RdStart <= '1';
					s_BurstLengthR <= s_LenR;
					s_RdErrorLatch <= '1';
					fsm_r_ahb <= READ_ERROR;
				elsif (s_RdAddr and FIFo_Empty)='1' then
					s_HTRANS_R <= "10";
					s_IncREn <= '1';
					s_RdStart <= '1';
					s_BurstLengthR <= s_LenR;
					fsm_r_ahb <= READ_WAIT_ADDR_ACK;
				end if;
				
			when READ_WAIT_ADDR_ACK =>
				s_RdStart <= '0';
				if s_HRESP='1' then
					s_HTRANS_R <= "00";
					s_FIFO_On <= '1';
					s_IncREn <= '0';
					s_RdErrorLatch <= '1';
					fsm_r_ahb <= READ_ERROR;
				elsif s_HREADY='1' then
					s_FIFO_En <= '1';
					if s_BurstLengthR=FIN_BURST then
						s_HTRANS_R <= "00";
						s_IncREn <= '0';
					else s_HTRANS_R <= "11";
					end if;
					fsm_r_ahb <= READ_WAIT_ACK;
				end if;
				
			when READ_WAIT_ACK =>
				if s_HRESP='1' then
					s_HTRANS_R <= "00";
					s_FIFO_En <= '0';
					s_IncREn <= '0';
					s_RdErrorLatch <= '1';
					if (s_HREADY and not FIFO_Full)='1' then
						if s_BurstLengthR=FIN_BURST then
							s_RdEnd <= '1';
							fsm_r_ahb <= READ_IDLE;
						else
							s_BurstLengthR <= s_BurstLengthR-1;
							s_FIFO_On <= '1';
							fsm_r_ahb <= READ_ERROR;
						end if;
					else
						s_FIFO_On <= '1';
						fsm_r_ahb <= READ_ERROR;
					end if;
				elsif s_HREADY='1' then
					if FIFO_Full='0' then
						if s_BurstLengthR=FIN_BURST then
							s_FIFO_En <= '0';
							s_RdEnd <= '1';
							fsm_r_ahb <= READ_IDLE;
						else
							s_BurstLengthR <= s_BurstLengthR-1;
							if s_BurstLengthR=BURST_01 then
								s_HTRANS_R <= "00";
								s_IncREn <= '0';
							end if;
						end if;
					else
						s_RDATA <= s_HRDATA;
						s_FIFO_On <= '1';
						s_FIFO_En <= '0';
						if s_BurstLengthR/=FIN_BURST then s_HTRANS_R <= "01";
						end if;
						s_IncREn <= '0';
						fsm_r_ahb <= READ_WAIT_FIFO;
					end if;
				end if;
			
			when READ_WAIT_FIFO =>
				if s_HRESP='1' then
					s_RdErrorLatch <= '1';
					s_HTRANS_R <= "00";
					if FIFO_Full='0' then
						if s_BurstLengthR=FIN_BURST then
							s_RdEnd <= '1';
							s_FIFO_On <= '0';
							fsm_r_ahb <= READ_IDLE;
						else
							s_BurstLengthR <= s_BurstLengthR-1;
							fsm_r_ahb <= READ_ERROR;
						end if;
					else fsm_r_ahb <= READ_ERROR;
					end if;
				elsif FIFO_Full='0' then
					s_FIFO_On <= '0';
					if s_BurstLengthR=FIN_BURST then
						s_RdEnd <= '1';
						fsm_r_ahb <= READ_IDLE;
					else
						s_FIFO_En <= '1';
						s_BurstLengthR <= s_BurstLengthR-1;
						if s_BurstLengthR=BURST_01 then s_HTRANS_R <= "00";
						else
							s_HTRANS_R <= "11";
							s_IncREn <= '1';
						end if;
						fsm_r_ahb <= READ_WAIT_ACK;
					end if;
				end if;

			when READ_ERROR =>
				s_RdStart <= '0';
				if FIFO_Full='0' then
					if s_BurstLengthR=FIN_BURST then
						s_RdEnd <= '1';
						s_FIFO_On <= '0';
						fsm_r_ahb <= READ_IDLE;
					else s_BurstLengthR <= s_BurstLengthR-1;
					end if;
				end if;				
			
			when others => fsm_r_ahb <= READ_IDLE;
		end case;
	end if;
end process;


end Behavioral;
