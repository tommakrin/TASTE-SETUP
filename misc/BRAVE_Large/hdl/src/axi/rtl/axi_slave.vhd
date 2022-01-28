-------------------------------------------------------
--! @file       AXI_Slave.vhd
--! @brief      AXI slave interface to custom IP interface
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

entity AXI_Slave is
generic (
	AXI_ADDR_WIDTH : integer:=32;
	AXI_DATA_WIDTH : integer:=64;
	AXI_ID_WIDTH : integer range 1 to 16 := 4;
	AXI_BURST_WIDTH : integer:=4;
	IPIF_ADDR_MAP : AddrMappingTable:=(0 => (start_addr => x"7000_0000", end_addr => x"7000_00FF"));
	IPIF_ADDR_TEST_MSB : natural:=31;
	IPIF_ADDR_TEST_LSB : natural:=0;
	IPIF_ADDR_WIDTH : integer:=32;
	BURST_ADDR_WIDTH : integer:=12
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
	S_AXI_WID     : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
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
-- Controls to the IP/IPIF modules
	--Bus2IP_Clk    : out std_logic;
	Bus2IP_Resetn : out std_logic;
	IP2Bus_Data   : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0 );
	IP2Bus_WrAck  : in  std_logic;
	IP2Bus_RdAck  : in  std_logic;
	IP2Bus_AddrAck: in  std_logic;
	IP2Bus_Error  : in  std_logic;

	Bus2IP_Addr   : out std_logic_vector(IPIF_ADDR_WIDTH-1 downto 0);
	Bus2IP_Data   : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	Bus2IP_RNW    : out std_logic;
	Bus2IP_BE     : out std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
	Bus2IP_Burst  : out std_logic;
	Bus2IP_BurstLength : out std_logic_vector(AXI_BURST_WIDTH-1 downto 0);
	Bus2IP_WrReq  : out std_logic;
	Bus2IP_RdReq  : out std_logic;
	Bus2IP_CS     : out std_logic;
	Bus2IP_RdCE   : out std_logic;
	Bus2IP_WrCE   : out std_logic;
	Type_of_xfer  : out std_logic
);

end entity AXI_Slave;


architecture Behavioral of AXI_Slave is

component Compteur_Addr is
generic
(
	DATA_WIDTH : integer:=12;
	MASK_WIDTH : integer:=4
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

constant AXI_DATA_WIDTH_BITS : integer:=clog2(AXI_DATA_WIDTH);
constant CPT_ADDR_WIDTH : integer:=min2(BURST_ADDR_WIDTH,IPIF_ADDR_WIDTH);
constant CPT_MASK_WIDTH : integer:=clog2(AXI_DATA_WIDTH/8);

constant FIN_BURST : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(0,AXI_BURST_WIDTH);
constant BURST_01 : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(1,AXI_BURST_WIDTH);

constant s_Mask : std_logic_vector(CPT_MASK_WIDTH-1 downto 0):=conv_std_logic_vector(2**(AXI_DATA_WIDTH_BITS-3)-1,CPT_MASK_WIDTH);

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
	ADDR_AXI_WAIT_START,
	ADDR_AXI_WAIT_END
);

type fsm_w_ipif_type is
(
	WRITE_IDLE,
	WRITE_WAIT_LAST_ACK,
	WRITE_WAIT_ACK,
	WRITE_WAIT_WVALID,
	WRITE_ERROR,
	WRITE_WAIT_BREADY
);

type fsm_ad_ipif_type is
(
	ADDR_IPIF_IDLE,
	ADDR_IPIF_WAIT_ACK,
	ADDR_IPIF_WAIT_RREADY
);

type fsm_r_ipif_type is
(
	READ_IDLE,
	READ_WAIT_ACK,
	READ_WAIT_RREADY,
	READ_ERROR
);

signal s_ADDRW_Ok,s_ADDRR_Ok : std_logic;
signal s_LenR,s_BurstLengthR,s_BurstLengthRAd : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=(others => '0');
signal s_LenW,s_BurstLengthW : std_logic_vector(AXI_BURST_WIDTH-1 downto 0):=(others => '0');
signal s_IncW,s_IncR : std_logic;
signal s_FixedW,s_FixedR : std_logic;
signal s_AWREADY,s_WREADY_On,s_WREADY_En : std_logic;
signal s_ARREADY,s_RVALID,s_RVALID_On,s_RVALID_En : std_logic;
signal s_AWADDR,s_ARADDR : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0):=(others => '0');

signal s_WrapW,s_WrapR : std_logic;
signal s_IncStepW,s_IncStepR : std_logic_vector(CPT_MASK_WIDTH downto 0):=(others => '0');
signal s_WrapMaskW,s_WrapMaskR : std_logic_vector(CPT_ADDR_WIDTH-1 downto 0):=(others => '0');
signal s_AddrRCpt,s_AddrWCpt : std_logic_vector(CPT_ADDR_WIDTH-1 downto 0):=(others => '0');
signal s_AddrR,s_AddrW : std_logic_vector(IPIF_ADDR_WIDTH-1 downto 0):=(others => '0');

signal fsm_arbit : fsm_arbit_type;
signal fsm_w_add_axi,fsm_r_add_axi : fsm_add_axi_type;
signal fsm_w_ipif : fsm_w_ipif_type;
signal fsm_r_ipif : fsm_r_ipif_type;
signal fsm_r_ad_ipif : fsm_ad_ipif_type;
signal s_WrErr,s_RdErr,s_WrAddr,s_RdAddr : std_logic;
signal s_WrStart,s_RdStart,s_WrEnd,s_RdEnd : std_logic;

signal s_BE : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0):=(others => '0');
signal s_RNW : std_logic;
signal s_WrCS,s_RdCS : std_logic;
signal s_WrReq,s_WrReqEn,s_WrReqOn : std_logic;
signal s_RdReq,s_RdReqEn,s_RdReqOn,s_RLastAd : std_logic;
signal s_BurstR,s_BurstW : std_logic;

signal s_AWVALID,s_ARVALID,s_RLAST : std_logic;
signal s_RDATA : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
signal s_RdErrorLatch : std_logic:='0';

begin

S_AXI_AWREADY <= s_AWREADY;
S_AXI_ARREADY <= s_ARREADY;

S_AXI_RDATA <= IP2Bus_Data when s_RVALID_En='1' else s_RDATA;

S_AXI_WREADY <= s_WREADY_On or (IP2Bus_WrAck and s_WREADY_En);
s_RVALID <= s_RVALID_On or (IP2Bus_RdAck and s_RVALID_En);
S_AXI_RVALID <= s_RVALID;
S_AXI_RLAST <= s_RLAST;

S_AXI_RRESP <= "10" when (s_RdErrorLatch or (IP2Bus_Error and IP2Bus_RdAck))='1' else "00";

--Bus2IP_Clk <= S_AXI_ACLK;
Bus2IP_Resetn <= S_AXI_ARESETN;

Bus2IP_Addr <= s_AddrR when s_RNW='1' else s_AddrW;
Bus2IP_RNW <= s_RNW;

Bus2IP_BE <= s_BE when s_RNW='0' else (others => '1');

Bus2IP_BurstLength <= s_LenW when s_RNW='0' else s_LenR;
Bus2IP_Burst <= s_BurstW when s_RNW='0' else s_BurstR;

Type_of_xfer <= not s_FixedR when s_RNW='1' else not s_FixedW;
Bus2IP_CS <= s_RdCS or s_WrCS;

s_WrReq <= (s_WrReqOn and not IP2Bus_WrAck) or (s_WrReqEn and (S_AXI_WVALID or not IP2Bus_WrAck));
Bus2IP_WrReq <= s_WrReq;
Bus2IP_WrCE <= s_WrReq;
s_RdReq <= s_RdReqOn or (s_RdReqEn and ((not IP2Bus_AddrAck) or ((s_RVALID and S_AXI_RREADY) and not s_RLastAd)));
Bus2IP_RdReq <= s_RdReq;
Bus2IP_RdCE <= s_RdReq;

s_ADDRW_Ok <= '1' when (S_AXI_AWADDR(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)>=IPIF_ADDR_MAP(0).start_addr(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB))
	and (S_AXI_AWADDR(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)<=IPIF_ADDR_MAP(0).end_addr(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)) else '0';
s_ADDRR_Ok <= '1' when (S_AXI_ARADDR(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)>=IPIF_ADDR_MAP(0).start_addr(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB))
	and (S_AXI_ARADDR(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)<=IPIF_ADDR_MAP(0).end_addr(IPIF_ADDR_TEST_MSB downto IPIF_ADDR_TEST_LSB)) else '0';

s_IncW <= IP2Bus_AddrAck and (not s_FixedW) and not s_RNW;
s_IncR <= IP2Bus_AddrAck and s_RNW and not s_FixedR;

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

ADDRESS_GEN_1 : if (BURST_ADDR_WIDTH>=IPIF_ADDR_WIDTH) generate

s_AddrW <= s_AddrWCpt;
s_AddrR <= s_AddrRCpt;

end generate ADDRESS_GEN_1;

----------------------

ADDRESS_GEN_2 : if (BURST_ADDR_WIDTH<IPIF_ADDR_WIDTH) generate

s_AddrW <= s_AWADDR(IPIF_ADDR_WIDTH-1 downto BURST_ADDR_WIDTH)&s_AddrWCpt;
s_AddrR <= s_ARADDR(IPIF_ADDR_WIDTH-1 downto BURST_ADDR_WIDTH)&s_AddrRCpt;

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
begin
	if S_AXI_ARESETN='0' then
		s_AWREADY <= '0';
		s_WrErr <= '0';
		s_WrAddr <= '0';
		s_RNW <= '1';
		fsm_w_add_axi <= ADDR_AXI_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_w_add_axi is
			when ADDR_AXI_IDLE =>
				if (s_ADDRW_Ok and s_AWVALID)='1' then
					s_AWREADY <= '1';
					s_AWADDR <= S_AXI_AWADDR;
					s_FixedW <= not (S_AXI_AWBURST(0) or S_AXI_AWBURST(1));
					s_WrapW <= S_AXI_AWBURST(1) and not S_AXI_AWBURST(0);
					s_LenW <= S_AXI_AWLEN;
					S_AXI_BID <= S_AXI_AWID;
					s_WrAddr <= '1';
					s_RNW <= '0';
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
					fsm_w_add_axi <= ADDR_AXI_WAIT_START;
				elsif s_AWVALID='1' then
					s_LenW <= S_AXI_AWLEN;
					S_AXI_BID <= S_AXI_AWID;
					s_AWREADY <= '1';
					s_WrErr <= '1';
					s_RNW <= '0';
					fsm_w_add_axi <= ADDR_AXI_WAIT_START;
				else
					s_AWREADY <= '0';
					s_LenW <= (others => '0');
					s_RNW <= '1';
				end if;
			
			when ADDR_AXI_WAIT_START =>
				s_AWREADY <= '0';
				if s_WrStart='1' then
					s_WrAddr <= '0';
					s_WrErr <= '0';
					fsm_w_add_axi <= ADDR_AXI_WAIT_END;
				end if;
			
			when ADDR_AXI_WAIT_END =>
				if s_WrEnd='1' then fsm_w_add_axi <= ADDR_AXI_IDLE;
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
begin
	if S_AXI_ARESETN='0' then
		s_ARREADY <= '0';
		s_RdErr <= '0';
		s_RdAddr <= '0';
		fsm_r_add_axi <= ADDR_AXI_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_add_axi is
			when ADDR_AXI_IDLE =>
				if (s_ADDRR_Ok and s_ARVALID)='1' then
					s_ARREADY <= '1';
					s_ARADDR <= S_AXI_ARADDR;
					s_FixedR <= not (S_AXI_ARBURST(0) or S_AXI_ARBURST(1));
					s_WrapR <= S_AXI_ARBURST(1) and not S_AXI_ARBURST(0);
					s_LenR <= S_AXI_ARLEN;
					S_AXI_RID <= S_AXI_ARID;
					s_RdAddr <= '1';
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
					fsm_r_add_axi <= ADDR_AXI_WAIT_START;
				elsif s_ARVALID='1' then
					s_LenR <= S_AXI_ARLEN;
					S_AXI_RID <= S_AXI_ARID;
					s_ARREADY <= '1';
					s_RdErr <= '1';
					fsm_r_add_axi <= ADDR_AXI_WAIT_START;
				else s_ARREADY <= '0';
				end if;
			
			when ADDR_AXI_WAIT_START =>
				s_ARREADY <= '0';
				if s_RdStart='1' then
					s_RdAddr <= '0';
					s_RdErr <= '0';
					fsm_r_add_axi <= ADDR_AXI_WAIT_END;
				end if;
				
			when ADDR_AXI_WAIT_END =>
				if s_RdEnd='1' then fsm_r_add_axi <= ADDR_AXI_IDLE;
				end if;

			when others => fsm_r_add_axi <= ADDR_AXI_IDLE;
		end case;
	end if;
end process;


-- Gestion Ecriture Data
process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		s_WREADY_On <= '0';
		s_WREADY_En <= '0';
		S_AXI_BVALID <= '0';
		s_WrCS <= '0';
		s_WrReqEn <= '0';
		s_WrReqOn <= '0';
		s_BurstW <= '0';
		s_WrEnd <= '0';
		s_WrStart <= '0';
		fsm_w_ipif <= WRITE_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_w_ipif is
			when WRITE_IDLE =>
				S_AXI_BRESP <= "00";
				S_AXI_BVALID <= '0';
				s_WrEnd <= '0';
				-- Valeurs par défaut
				s_WrStart <= '0';
				s_WREADY_On <= '0';
				s_WREADY_En <= '0';
				s_WrCS <= '0';
				s_WrReqEn <= '0';
				s_WrReqOn <= '0';
				s_BurstW <= '0';
				if s_WrErr='1' then
					s_WrStart <= '1';
					s_BurstLengthW <= s_LenW;
					s_WREADY_On <= '1';
					fsm_w_ipif <= WRITE_ERROR;
				elsif (S_AXI_WVALID and s_WrAddr)='1' then
					Bus2IP_Data <= S_AXI_WDATA;
					s_BE <= S_AXI_WSTRB;
					s_WrCS <= '1';
					s_WREADY_On <= '1';
					s_WrStart <= '1';
					if s_LenW=FIN_BURST then
						s_WrReqOn <= '1';
						fsm_w_ipif <= WRITE_WAIT_LAST_ACK;
					else
						s_BurstLengthW <= s_LenW-1;
						s_WrReqEn <= '1';
						s_BurstW <= '1';
						s_WREADY_En <= '1';
						fsm_w_ipif <= WRITE_WAIT_ACK;
					end if;
				end if;
			
			when WRITE_WAIT_LAST_ACK =>
				s_WREADY_On <= '0';
				s_WrStart <= '0';
				if IP2Bus_WrAck='1' then
					s_WrReqOn <= '0';
					S_AXI_BVALID <= '1';
					if IP2Bus_Error='1' then S_AXI_BRESP <= "10";
					end if;
					fsm_w_ipif <= WRITE_WAIT_BREADY;
				end if;
					
			when WRITE_WAIT_ACK =>
				s_WrStart <= '0';
				s_WREADY_On <= '0';
				if IP2Bus_WrAck='1' then
					if IP2Bus_Error='1' then S_AXI_BRESP <= "10";
					end if;
					if S_AXI_WVALID='1' then
						Bus2IP_Data <= S_AXI_WDATA;
						s_BE <= S_AXI_WSTRB;
						if s_BurstLengthW=FIN_BURST then
							s_BurstW <= '0';
							s_WREADY_En <= '0';
							s_WrReqOn <= '1';
							s_WrReqEn <= '0';
							fsm_w_ipif <= WRITE_WAIT_LAST_ACK;
						else s_BurstLengthW <= s_BurstLengthW-1;
						end if;						
					else
						s_WREADY_On <= '1';
						s_WrReqEn <= '0';
						fsm_w_ipif <= WRITE_WAIT_WVALID;
					end if;
				end if;
				
			when WRITE_WAIT_WVALID =>
				if S_AXI_WVALID='1' then
					s_WREADY_On <= '0';
					Bus2IP_Data <= S_AXI_WDATA;
					s_BE <= S_AXI_WSTRB;
					if s_BurstLengthW=FIN_BURST then
						s_WREADY_En <= '0';
						s_WrReqOn <= '1';
						s_BurstW <= '0';
						fsm_w_ipif <= WRITE_WAIT_LAST_ACK;
					else
						s_BurstLengthW <= s_BurstLengthW-1;
						s_WrReqEn <= '1';
						fsm_w_ipif <= WRITE_WAIT_ACK;
					end if;
				end if;
			
			when WRITE_ERROR =>
				s_WrStart <= '0';
				if S_AXI_WVALID='1' then
					if s_BurstLengthW=FIN_BURST then
						s_WREADY_On <= '0';
						S_AXI_BRESP <= "10";
						S_AXI_BVALID <= '1';
						fsm_w_ipif <= WRITE_WAIT_BREADY;
					else s_BurstLengthW <= s_BurstLengthW-1;
					end if;
				end if;
				
			when WRITE_WAIT_BREADY =>
				if S_AXI_BREADY='1' then
					s_WrEnd <= '1';
					S_AXI_BVALID <= '0';
					fsm_w_ipif <= WRITE_IDLE;
				end if;
			
			when others => fsm_w_ipif <= WRITE_IDLE;
		end case;
	end if;
end process;


-- Gestion Lecture Data

-- Gestion RdReq & AddrAck
process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		s_RdReqOn <= '0';
		s_RdReqEn <= '0';
		s_RLastAd <= '0';
		fsm_r_ad_ipif <= ADDR_IPIF_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_ad_ipif is		
			when ADDR_IPIF_IDLE =>		
				s_RLastAd <= '0';
				-- Valeurs par défaut
				s_RdReqOn <= '0';
				s_RdReqEn <= '0';
				if (s_RdAddr and not s_RdErr)='1' then
					if s_LenR=FIN_BURST then s_RdReqOn <= '1';
					else s_RdReqEn <= '1';
					end if;
					s_BurstLengthRAd <= s_LenR;
					fsm_r_ad_ipif <= ADDR_IPIF_WAIT_ACK;
				end if;
				
			when ADDR_IPIF_WAIT_ACK =>
				s_RdReqOn <= '0';
				if IP2Bus_AddrAck='1' then
					if s_BurstLengthRAd=FIN_BURST then
						s_RdReqEn <= '0';
						fsm_r_ad_ipif <= ADDR_IPIF_IDLE;
					else
						s_BurstLengthRAd <= s_BurstLengthRAd-1;
						if (S_AXI_RREADY and s_RVALID)='0' then
							s_RdReqEn <= '0';
							fsm_r_ad_ipif <= ADDR_IPIF_WAIT_RREADY;
						end if;
						if s_BurstLengthRAd=BURST_01 then s_RLastAd <= '1';
						end if;
					end if;
				end if;

			when ADDR_IPIF_WAIT_RREADY =>
				if (S_AXI_RREADY and s_RVALID)='1' then
					s_RdReqEn <= '1';
					fsm_r_ad_ipif <= ADDR_IPIF_WAIT_ACK;
				end if;
				
			when others => fsm_r_ad_ipif <= ADDR_IPIF_IDLE;
		end case;
	end if;
end process;

-- Gestion data & RdAcq
process(S_AXI_ARESETN,S_AXI_ACLK)
begin
	if S_AXI_ARESETN='0' then
		s_RLAST <= '0';
		s_BurstR <= '0';
		s_RdCS <= '0';
		s_RVALID_On <= '0';
		s_RVALID_En <= '0';
		s_RdEnd <= '0';
		s_RdStart <= '0';
		fsm_r_ipif <= READ_IDLE;
	elsif rising_edge(S_AXI_ACLK) then
		case fsm_r_ipif is
			when READ_IDLE =>
				s_RdEnd <= '0';
				-- Valeurs par défaut
				s_RLAST <= '0';
				s_BurstR <= '0';
				s_RdErrorLatch <= '0';
				s_RVALID_On <= '0';
				s_RVALID_En <= '0';
				s_RdStart <= '0';
				s_RdCS <= '0';
				if s_RdErr='1' then
					s_RdErrorLatch <= '1';
					s_RVALID_On <= '1';
					s_RdStart <= '1';
					s_BurstLengthR <= s_LenR;
					if s_LenR=FIN_BURST then s_RLAST <= '1';
					end if;
					fsm_r_ipif <= READ_ERROR;
				elsif s_RdAddr='1' then
					if s_LenR=FIN_BURST then s_RLAST <= '1';
					end if;
					s_RdCS <= '1';
					s_RVALID_En <= '1';
					s_RdStart <= '1';
					s_BurstLengthR <= s_LenR;
					s_BurstR <= '1';
					fsm_r_ipif <= READ_WAIT_ACK;
				end if;

			when READ_WAIT_ACK =>
				s_RdStart <= '0';
				if IP2Bus_RdAck='1' then
					if S_AXI_RREADY='1' then
						if s_BurstLengthR=FIN_BURST then
							s_RdEnd <= '1';
							s_RLAST <= '0';
							s_RVALID_On <= '0';
							s_RVALID_En <= '0';
							fsm_r_ipif <= READ_IDLE;
						else
							s_BurstLengthR <= s_BurstLengthR-1;
							if IP2Bus_Error='1' then s_RdErrorLatch <= '1';
							end if;
							if s_BurstLengthR=BURST_01 then
								s_BurstR <= '0';
								s_RLAST <= '1';
							end if;
						end if;
					else
						if IP2Bus_Error='1' then s_RdErrorLatch <= '1';
						end if;
						if s_BurstLengthR=BURST_01 then s_BurstR <= '0';
						end if;
						s_RDATA <= IP2Bus_Data;
						s_RVALID_On <= '1';
						s_RVALID_En <= '0';
						fsm_r_ipif <= READ_WAIT_RREADY;
					end if;
				end if;

			when READ_WAIT_RREADY =>
				if S_AXI_RREADY='1' then
					s_RVALID_On <= '0';
					s_RVALID_En <= '1';
					if s_BurstLengthR=FIN_BURST then
						s_RdEnd <= '1';
						s_RLAST <= '0';
						s_RVALID_En <= '0';
						fsm_r_ipif <= READ_IDLE;
					else
						s_BurstLengthR <= s_BurstLengthR-1;
						if s_BurstLengthR=BURST_01 then s_RLAST <= '1';
						end if;
					end if;
					fsm_r_ipif <= READ_WAIT_ACK;
				end if;
				
			when READ_ERROR =>
				s_RdStart <= '0';
				if S_AXI_RREADY='1' then
					if s_BurstLengthR=FIN_BURST then
						s_RdEnd <= '1';
						s_RLAST <= '0';
						s_RVALID_On <= '0';
						s_RVALID_En <= '0';
						fsm_r_ipif <= READ_IDLE;
					else
						s_BurstLengthR <= s_BurstLengthR-1;
						if s_BurstLengthR=BURST_01 then s_RLAST <= '1';
						end if;
					end if;
				end if;				
				
			when others => fsm_r_ipif <= READ_IDLE;
		end case;
	end if;
end process;


end Behavioral;
