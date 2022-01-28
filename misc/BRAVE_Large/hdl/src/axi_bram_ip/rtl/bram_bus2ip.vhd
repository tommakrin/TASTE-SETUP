-------------------------------------------------------
--! @file       BRAM_BUS2IP.vhd
--! @brief      AXI to BRAM interface
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity BRAM_BUS2IP is
	generic
	(
		BRAM_ADDR_WIDTH : integer:=12;
		BRAM_DATA_WIDTH : integer:=8;
		I2P_ADDR_WIDTH : integer := 12;
		I2P_BURST_WIDTH : integer := 4
	);
    Port (
	-- Signaux BUS2IP BUS A
		BUSA2IP_Clk : in std_logic;
		BUSA2IP_Resetn : in std_logic;
		IP2BusA_Data : out std_logic_vector(63 downto 0);
		IP2BusA_WrAck : out std_logic;
		IP2BusA_RdAck : out std_logic;
		IP2BusA_AddrAck : out std_logic;
		IP2BusA_Error : out std_logic;
		BusA2IP_Addr : in std_logic_vector(I2P_ADDR_WIDTH-1 downto 0);
		BusA2IP_Data : in std_logic_vector(63 downto 0);
		BusA2IP_RNW : in std_logic;
		BusA2IP_BE : in std_logic_vector(7 downto 0);
		BusA2IP_Burst : in std_logic;
		BusA2IP_BurstLength : in std_logic_vector(I2P_BURST_WIDTH-1 downto 0);
		BusA2IP_WrReq : in std_logic;
		BusA2IP_RdReq : in std_logic;
		BusA2IP_CS : in std_logic;
		Type_of_xfer_A : in std_logic;

	-- Signaux BUS2IP BUS B
		BUSB2IP_Clk : in std_logic;
		BUSB2IP_Resetn : in std_logic;
		IP2BusB_Data : out std_logic_vector(63 downto 0);
		IP2BusB_WrAck : out std_logic;
		IP2BusB_RdAck : out std_logic;
		IP2BusB_AddrAck : out std_logic;
		IP2BusB_Error : out std_logic;
		BusB2IP_Addr : in std_logic_vector(I2P_ADDR_WIDTH-1 downto 0);
		BusB2IP_Data : in std_logic_vector(63 downto 0);
		BusB2IP_RNW : in std_logic;
		BusB2IP_BE : in std_logic_vector(7 downto 0);
		BusB2IP_Burst : in std_logic;
		BusB2IP_BurstLength : in std_logic_vector(I2P_BURST_WIDTH-1 downto 0);
		BusB2IP_WrReq : in std_logic;
		BusB2IP_RdReq : in std_logic;
		BusB2IP_CS : in std_logic;
		Type_of_xfer_B : in std_logic
		);
end BRAM_BUS2IP;

architecture Behavioral of BRAM_BUS2IP is

component BRAM is
generic (
	ADDR_WITDH : integer:=12;
	DATA_WITDH : integer:=8
);
Port (
	CKA : in std_logic;
	WEA : in std_logic;
	ADRA : in std_logic_vector(ADDR_WITDH-1 downto 0);
	DINA : in std_logic_vector(DATA_WITDH-1 downto 0);
	DOUTA : out std_logic_vector(DATA_WITDH-1 downto 0);
	CKB : in std_logic;
	WEB : in std_logic;
	ADRB : in std_logic_vector(ADDR_WITDH-1 downto 0);
	DINB : in std_logic_vector(DATA_WITDH-1 downto 0);
	DOUTB : out std_logic_vector(DATA_WITDH-1 downto 0)
);
end component;

-- Machines d'état

type fsm_bram_type is
(
	BRAM_IDLE_R,
	BRAM_IDLE_W,
	BRAM_WRITE0,
	BRAM_WRITE1,
	BRAM_READ0,
	BRAM_READ1
);

type fsm_bramip_type is
(
	WAIT_IDLE,
	WAIT_END_REQ,
	WAIT_FIFO_BRAM,
	WAIT_START_FIFO
 );

type fsm_fifo_type is
(
	FIFO_IDLE_R,
	FIFO_IDLE_W,
	FIFO_AD_WRITE,
	FIFO_AD_WRITE_END_1,
	FIFO_AD_WRITE_END_2,
	FIFO_AD_WRITE_END_3,
	FIFO_AD_WAIT_WRITE,
	FIFO_AD_WAIT_WRITE_START,
	FIFO_AD_READ,
	FIFO_AD_WAIT_READ
 );


constant FIN_BURST : std_logic_vector(I2P_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(0,I2P_BURST_WIDTH);
constant BURST_01 : std_logic_vector(I2P_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(1,I2P_BURST_WIDTH);

-- Signaux BUS A

signal s_BRAM_A_Data_Out : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0) := (others => '0');
signal s_BRAM_A_WE : std_logic;
signal s_BRAM_A_Addr,s_BRAM_A_AddrW,s_BRAM_A_AddrR : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0) := (others => '0');

signal StartW_A,StartR_A : std_logic;
signal NbreBurstA_LatchW,NbreBurstA : std_logic_vector(I2P_BURST_WIDTH-1 downto 0) := (others => '0');
signal WStartFIFO_A,RStartFIFO_A : std_logic;

signal FIFO_A_BE_Out : std_logic_vector(7 downto 0) := (others => '0');
signal FIFO_A_BE_Wr,FIFO_A_BE_Re : std_logic;
signal FIFO_A_BE_Full,FIFO_A_BE_Empty : std_logic;

signal FIFO_A_AddrW_Wr,FIFO_A_AddrW_Re : std_logic;
signal FIFO_A_AddrW_Full,FIFO_A_AddrW_Empty : std_logic;

signal FIFO_A_W_Wr,FIFO_A_W_Re : std_logic;
signal FIFO_A_W_Full,FIFO_A_W_Empty : std_logic;
signal FIFO_A_W_Disable,FIFO_A_Busy,FIFO_A_BusyW,FIFO_A_BusyR : std_logic;
signal FIFO_A_W_DataOut : std_logic_vector(63 downto 0) := (others => '0');

signal AddrAReadEn,Set_AddrARead,Clr_AddrARead : std_logic;

signal BRAM_A_Busy : std_logic;
signal fsm_A_bram : fsm_bram_type;
signal fsm_A_fifo : fsm_fifo_type;
signal fsm_A_bramipW,fsm_A_bramipR : fsm_bramip_type;

signal IP2BusA_ErrorW,IP2BusA_ErrorR : std_logic;

signal CptA : std_logic_vector(3 downto 0);
signal ShRegDataAW,ShRegDataAR : std_logic_vector(63 downto 0);
signal ShRegBEA : std_logic_vector(7 downto 0);

signal s_BusA_AdAckOn,s_BusA_AdAckEn : std_logic;
signal s_BusA_WrAckOn,s_BusA_WrAckEn : std_logic;
signal s_FIFO_A_Wr,s_FIFO_A_WrEn : std_logic;

-- Signaux BUS B

signal s_BRAM_B_Data_Out : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0) := (others => '0');
signal s_BRAM_B_WE : std_logic;
signal s_BRAM_B_Addr,s_BRAM_B_AddrW,s_BRAM_B_AddrR : std_logic_vector(BRAM_ADDR_WIDTH-1 downto 0) := (others => '0');

signal StartW_B,StartR_B : std_logic;
signal NbreBurstB_LatchW,NbreBurstB : std_logic_vector(I2P_BURST_WIDTH-1 downto 0) := (others => '0');
signal WStartFIFO_B,RStartFIFO_B : std_logic;

signal FIFO_B_BE_Out : std_logic_vector(7 downto 0) := (others => '0');
signal FIFO_B_BE_Wr,FIFO_B_BE_Re : std_logic;
signal FIFO_B_BE_Full,FIFO_B_BE_Empty : std_logic;

signal FIFO_B_AddrW_Wr,FIFO_B_AddrW_Re : std_logic;
signal FIFO_B_AddrW_Full,FIFO_B_AddrW_Empty : std_logic;

signal FIFO_B_W_Wr,FIFO_B_W_Re : std_logic;
signal FIFO_B_W_Full,FIFO_B_W_Empty : std_logic;
signal FIFO_B_W_Disable,FIFO_B_Busy,FIFO_B_BusyW,FIFO_B_BusyR : std_logic;
signal FIFO_B_W_DataOut : std_logic_vector(63 downto 0) := (others => '0');

signal AddrBReadEn,Set_AddrBRead,Clr_AddrBRead : std_logic;

signal BRAM_B_Busy : std_logic;
signal fsm_B_bram : fsm_bram_type;
signal fsm_B_fifo : fsm_fifo_type;
signal fsm_B_bramipW,fsm_B_bramipR : fsm_bramip_type;

signal IP2BusB_ErrorW,IP2BusB_ErrorR : std_logic;

signal CptB : std_logic_vector(3 downto 0);
signal ShRegDataBW,ShRegDataBR : std_logic_vector(63 downto 0);
signal ShRegBEB : std_logic_vector(7 downto 0);

signal s_BusB_AdAckOn,s_BusB_AdAckEn : std_logic;
signal s_BusB_WrAckOn,s_BusB_WrAckEn : std_logic;
signal s_FIFO_B_Wr,s_FIFO_B_WrEn : std_logic;

-----

signal BRAM_DOUTA,BRAM_DOUTB : std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);

begin

-- Instanciation BRAM

BRAM_0 : BRAM
generic map (
	ADDR_WITDH => BRAM_ADDR_WIDTH,
	DATA_WITDH => BRAM_DATA_WIDTH
)
port map (
	CKA => BUSA2IP_Clk,
	WEA => s_BRAM_A_WE,
	ADRA => s_BRAM_A_Addr,
	DINA => s_BRAM_A_Data_Out,
	DOUTA => BRAM_DOUTA,
	CKB => BUSB2IP_Clk,
	WEB => s_BRAM_B_WE,
	ADRB => s_BRAM_B_Addr,
	DINB => s_BRAM_B_Data_Out,
	DOUTB => BRAM_DOUTB
);


---------------------------------------
-- Gestion BUS A
---------------------------------------


FIFO_A_BE : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 8
)
port map (
    clk_i   => BUSA2IP_Clk,
    rst_ni  => BUSA2IP_Resetn,
    --
    wen_i   => FIFO_A_BE_Wr,
    data_i  => BusA2IP_BE,
    full_o  => FIFO_A_BE_Full,
    --
    data_o  => FIFO_A_BE_Out,
    ren_i   => FIFO_A_BE_Re,
    empty_o => FIFO_A_BE_Empty
    );

FIFO_A_ADDR_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => BRAM_ADDR_WIDTH
)
port map (
    clk_i   => BUSA2IP_Clk,
    rst_ni  => BUSA2IP_Resetn,
    --
    wen_i   => FIFO_A_AddrW_Wr,
    data_i  => BusA2IP_Addr(BRAM_ADDR_WIDTH-1 downto 0),
    full_o  => FIFO_A_AddrW_Full,
    --
    ren_i   => FIFO_A_AddrW_Re,
    data_o  => s_BRAM_A_AddrW,
    empty_o => FIFO_A_AddrW_Empty
    );

FIFO_A_DATA_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 64
)
port map (
    clk_i   => BUSA2IP_Clk,
    rst_ni  => BUSA2IP_Resetn,
    --
    wen_i   => FIFO_A_W_Wr,
    data_i  => BusA2IP_Data,
    full_o  => FIFO_A_W_Full,
    --
    ren_i   => FIFO_A_W_Re,
    data_o  => FIFO_A_W_DataOut,
    empty_o => FIFO_A_W_Empty
    );

FIFO_A_W_Disable <= FIFO_A_W_Full or FIFO_A_AddrW_Full or FIFO_A_BE_Full;
FIFO_A_Busy <= FIFO_A_BusyW or FIFO_A_BusyR;

IP2BusA_Error <= IP2BusA_ErrorR or IP2BusA_ErrorW;

s_FIFO_A_Wr <= s_FIFO_A_WrEn and not FIFO_A_W_Disable;
FIFO_A_BE_Wr <= s_FIFO_A_Wr;
FIFO_A_AddrW_Wr <= s_FIFO_A_Wr;
FIFO_A_W_Wr <= s_FIFO_A_Wr;

IP2BusA_WrAck <= s_BusA_WrAckOn or (s_BusA_WrAckEn and not FIFO_A_W_Disable);
IP2BusA_AddrAck <= s_BusA_AdAckOn or (s_BusA_AdAckEn and not FIFO_A_W_Disable);

-- Gestion de l'adresse lecture disponible
process(BUSA2IP_Clk,BUSA2IP_Resetn)
begin
	if BUSA2IP_Resetn='0' then AddrAReadEn <= '0';
	elsif rising_edge(BUSA2IP_Clk) then
		if Set_AddrARead='1' then AddrAReadEn <= '1';
		elsif Clr_AddrARead='1' then AddrAReadEn <= '0';
		end if;
	end if;
end process;

-- Gestion des FIFOs Addr (R/W) et FIFO (W) IPIF.
process(BUSA2IP_Clk,BUSA2IP_Resetn)
begin
	if BUSA2IP_Resetn='0' then
		s_FIFO_A_WrEn <= '0';
		FIFO_A_BusyW <= '0';
		FIFO_A_BusyR <= '0';
		s_BusA_WrAckOn <= '0';
		s_BusA_WrAckEn <= '0';
		s_BusA_AdAckOn <= '0';
		s_BusA_AdAckEn <= '0';
		Set_AddrARead <= '0';
		fsm_A_fifo <= FIFO_IDLE_R;
	elsif rising_edge(BUSA2IP_Clk) then
		case fsm_A_fifo is
			when FIFO_IDLE_R =>
				-- Valeurs par défaut
				s_FIFO_A_WrEn <= '0';
				FIFO_A_BusyW <= '0';
				FIFO_A_BusyR <= '0';
				s_BusA_WrAckOn <= '0';
				s_BusA_WrAckEn <= '0';
				s_BusA_AdAckOn <= '0';
				s_BusA_AdAckEn <= '0';
				Set_AddrARead <= '0';

				if RStartFIFO_A='1' then
					FIFO_A_BusyR <= '1';
					if AddrAReadEn='1' then fsm_A_fifo <= FIFO_AD_WAIT_READ;
					else fsm_A_fifo <= FIFO_AD_READ;
					end if;
				elsif WStartFIFO_A='1' then
					NbreBurstA <= NbreBurstA_LatchW;
					FIFO_A_BusyW <= '1';
					if FIFO_A_W_Disable='1' then fsm_A_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_A_WrEn <= '1';
						if NbreBurstA_LatchW=FIN_BURST then fsm_A_fifo <= FIFO_AD_WRITE_END_1;
						else
							s_BusA_WrAckEn <= '1';
							s_BusA_AdAckEn <= '1';
							fsm_A_fifo <= FIFO_AD_WRITE;
						end if;
					end if;
				end if;

			when FIFO_IDLE_W =>
				-- Valeurs par défaut
				s_FIFO_A_WrEn <= '0';
				FIFO_A_BusyW <= '0';
				FIFO_A_BusyR <= '0';
				s_BusA_WrAckOn <= '0';
				s_BusA_WrAckEn <= '0';
				s_BusA_AdAckOn <= '0';
				s_BusA_AdAckEn <= '0';
				Set_AddrARead <= '0';

				if WStartFIFO_A='1' then
					NbreBurstA <= NbreBurstA_LatchW;
					FIFO_A_BusyW <= '1';
					if FIFO_A_W_Disable='1' then fsm_A_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_A_WrEn <= '1';
						if NbreBurstA_LatchW=FIN_BURST then fsm_A_fifo <= FIFO_AD_WRITE_END_1;
						else
							s_BusA_WrAckEn <= '1';
							s_BusA_AdAckEn <= '1';
							fsm_A_fifo <= FIFO_AD_WRITE;
						end if;
					end if;
				elsif RStartFIFO_A='1' then
					FIFO_A_BusyR <= '1';
					if AddrAReadEn='1' then fsm_A_fifo <= FIFO_AD_WAIT_READ;
					else fsm_A_fifo <= FIFO_AD_READ;
					end if;
				end if;

			when FIFO_AD_WRITE =>
				if FIFO_A_W_Disable='0' then
					NbreBurstA <= NbreBurstA-1;
					if BusA2IP_WrReq='0' then
						s_FIFO_A_WrEn <= '0';
						s_BusA_WrAckEn <= '0';
						s_BusA_AdAckEn <= '0';
						fsm_A_fifo <= FIFO_AD_WAIT_WRITE;
					elsif NbreBurstA=BURST_01 then
						s_BusA_WrAckEn <= '0';
						s_BusA_AdAckEn <= '0';
						fsm_A_fifo <= FIFO_AD_WRITE_END_1;
					end if;
				end if;

			when FIFO_AD_WRITE_END_1 =>
				if FIFO_A_W_Disable='0' then
					s_FIFO_A_WrEn <= '0';
					fsm_A_fifo <= FIFO_AD_WRITE_END_2;
				end if;

			when FIFO_AD_WRITE_END_2 =>
				if BRAM_A_Busy='1' then fsm_A_fifo <= FIFO_AD_WRITE_END_3;
				end if;

			when FIFO_AD_WRITE_END_3 =>
				if BRAM_A_Busy='0' then
					s_BusA_WrAckOn <= '1';
					s_BusA_AdAckOn <= '1';
					FIFO_A_BusyW <= '0';
					fsm_A_fifo <= FIFO_IDLE_R;
				end if;

			when FIFO_AD_WAIT_WRITE =>
				if BusA2IP_WrReq='1' then
					s_FIFO_A_WrEn <= '1';
					if NbreBurstA=FIN_BURST then fsm_A_fifo <= FIFO_AD_WRITE_END_1;
					else
						s_BusA_WrAckEn <= '1';
						s_BusA_AdAckEn <= '1';
						fsm_A_fifo <= FIFO_AD_WRITE;
					end if;
				end if;

			when FIFO_AD_WAIT_WRITE_START =>
				if FIFO_A_W_Disable='0' then
					s_FIFO_A_WrEn <= '1';
					if NbreBurstA=FIN_BURST then fsm_A_fifo <= FIFO_AD_WRITE_END_1;
					else
						s_BusA_WrAckEn <= '1';
						s_BusA_AdAckEn <= '1';
						fsm_A_fifo <= FIFO_AD_WRITE;
					end if;
				end if;

			when FIFO_AD_READ =>
				Set_AddrARead <= '1';
				s_BRAM_A_AddrR <= BusA2IP_Addr(BRAM_ADDR_WIDTH-1 downto 0);
				s_BusA_AdAckOn <= '1';
				FIFO_A_BusyR <= '0';
				fsm_A_fifo <= FIFO_IDLE_W;

			when FIFO_AD_WAIT_READ =>
				if AddrAReadEn='0' then fsm_A_fifo <= FIFO_AD_READ;
				end if;

			when others => fsm_A_fifo <= FIFO_IDLE_R;
		end case;
	end if;
end process;

-- Gestion de l'accès BRAM
process(BUSA2IP_Clk,BUSA2IP_Resetn)
begin
	if BUSA2IP_Resetn='0' then
		s_BRAM_A_WE <= '0';
		FIFO_A_AddrW_Re <= '0';
		FIFO_A_W_Re <= '0';
		FIFO_A_BE_Re <= '0';
		Clr_AddrARead <= '0';
		IP2BusA_RdAck <= '0';
		BRAM_A_Busy <= '0';
		fsm_A_bram <= BRAM_IDLE_R;
	elsif rising_edge(BUSA2IP_Clk) then
		case fsm_A_bram is
			when BRAM_IDLE_R =>
				-- Valeurs par défaut
				s_BRAM_A_WE <= '0';
				FIFO_A_AddrW_Re <= '0';
				FIFO_A_W_Re <= '0';
				FIFO_A_BE_Re <= '0';
				Clr_AddrARead <= '0';
				IP2BusA_RdAck <= '0';
				BRAM_A_Busy <= '0';

				if AddrAReadEn='1' then
					s_BRAM_A_Addr <= s_BRAM_A_AddrR;
					Clr_AddrARead <= '1';
					BRAM_A_Busy <= '1';
					fsm_A_bram <= BRAM_READ0;
				elsif FIFO_A_AddrW_Empty='0' then
					s_BRAM_A_Addr <= s_BRAM_A_AddrW;
					CptA <= "0001";
					ShRegDataAW <= FIFO_A_W_DataOut;
					ShRegBEA <= FIFO_A_BE_Out;
					BRAM_A_Busy <= '1';
					FIFO_A_AddrW_Re <= '1';
					FIFO_A_W_Re <= '1';
					FIFO_A_BE_Re <= '1';
					fsm_A_bram <= BRAM_WRITE0;
				end if;

			when BRAM_IDLE_W =>
				-- Valeurs par défaut
				s_BRAM_A_WE <= '0';
				FIFO_A_AddrW_Re <= '0';
				FIFO_A_W_Re <= '0';
				FIFO_A_BE_Re <= '0';
				Clr_AddrARead <= '0';
				IP2BusA_RdAck <= '0';
				BRAM_A_Busy <= '0';

				if FIFO_A_AddrW_Empty='0' then
					s_BRAM_A_Addr <= s_BRAM_A_AddrW;
					ShRegDataAW <= FIFO_A_W_DataOut;
					ShRegBEA <= FIFO_A_BE_Out;
					BRAM_A_Busy <= '1';
					FIFO_A_AddrW_Re <= '1';
					FIFO_A_W_Re <= '1';
					FIFO_A_BE_Re <= '1';
					fsm_A_bram <= BRAM_WRITE0;
				elsif AddrAReadEn='1' then
					s_BRAM_A_Addr <= s_BRAM_A_AddrR;
					Clr_AddrARead <= '1';
					BRAM_A_Busy <= '1';
					fsm_A_bram <= BRAM_READ0;
				end if;

			when BRAM_WRITE0 =>
				FIFO_A_AddrW_Re <= '0';
				FIFO_A_W_Re <= '0';
				FIFO_A_BE_Re <= '0';
				CptA <= "0001";
				s_BRAM_A_WE <= ShRegBEA(0);
				s_BRAM_A_Data_Out <= ShRegDataAW(7 downto 0);
				ShRegBEA <= '0'&ShRegBEA(7 downto 1);
				ShRegDataAW <= x"00"&ShRegDataAW(63 downto 8);
				fsm_A_bram <= BRAM_WRITE1;

			when BRAM_WRITE1 =>
				s_BRAM_A_Data_Out <= ShRegDataAW(7 downto 0);
				s_BRAM_A_Addr <= s_BRAM_A_Addr+1;
				ShRegBEA <= '0'&ShRegBEA(7 downto 1);
				ShRegDataAW <= x"00"&ShRegDataAW(63 downto 8);
				if CptA(3)='0' then
					s_BRAM_A_WE <= ShRegBEA(0);
					CptA <= CptA + 1;
				else
					s_BRAM_A_WE <= '0';
					fsm_A_bram <= BRAM_IDLE_R;
				end if;

			when BRAM_READ0 =>
				Clr_AddrARead <= '0';
				CptA <= "0000";
				s_BRAM_A_Addr <= s_BRAM_A_Addr+1;
				fsm_A_bram <= BRAM_READ1;

			when BRAM_READ1 =>
				if CptA(3)='0' then
					ShRegDataAR <= BRAM_DOUTA&ShRegDataAR(63 downto 8);
					s_BRAM_A_Addr <= s_BRAM_A_Addr+1;
					CptA <= CptA + 1;
				else
					IP2BusA_Data <= ShRegDataAR;
					IP2BusA_RdAck <= '1';
					fsm_A_bram <= BRAM_IDLE_W;
				end if;

			when others => fsm_A_bram <= BRAM_IDLE_R;
		end case;
	end if;
end process;


StartW_A <= BusA2IP_CS and BusA2IP_WrReq;
StartR_A <= BusA2IP_CS and BusA2IP_RdReq;

-- Gestion des requêtes d'écriture
process(BUSA2IP_Clk,BUSA2IP_Resetn)
begin
	if BUSA2IP_Resetn='0' then
		IP2BusA_ErrorW <= '0';
		WStartFIFO_A <= '0';
		fsm_A_bramipW <= WAIT_IDLE;
	elsif rising_edge(BUSA2IP_Clk) then
		case fsm_A_bramipW is
			when WAIT_IDLE =>
				if StartW_A='1' then
					NbreBurstA_LatchW <= BusA2IP_BurstLength;
					IP2BusA_ErrorW <= not Type_of_xfer_A;
					if (BRAM_A_Busy or FIFO_A_Busy)='1' then fsm_A_bramipW <= WAIT_FIFO_BRAM;
					else
						WStartFIFO_A <= '1';
						fsm_A_bramipW <= WAIT_START_FIFO;
					end if;
				else
					IP2BusA_ErrorW <= '0';
					WStartFIFO_A <= '0';
					NbreBurstA_LatchW <= (others => '0');
				end if;

			when WAIT_END_REQ =>
				if FIFO_A_BusyW='0' then fsm_A_bramipW <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_BRAM =>
				if (BRAM_A_Busy or FIFO_A_Busy)='0' then
					WStartFIFO_A <= '1';
					fsm_A_bramipW <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_A_BusyW='1' then
					WStartFIFO_A <= '0';
					fsm_A_bramipW <= WAIT_END_REQ;
				end if;

			when others => fsm_A_bramipW <= WAIT_IDLE;
		end case;
	end if;
end process;

-- Gestion des requêtes de lecture
process(BUSA2IP_Clk,BUSA2IP_Resetn)
begin
	if BUSA2IP_Resetn='0' then
		IP2BusA_ErrorR <= '0';
		RStartFIFO_A <= '0';
		fsm_A_bramipR <= WAIT_IDLE;
	elsif rising_edge(BUSA2IP_Clk) then
		case fsm_A_bramipR is
			when WAIT_IDLE =>
				if StartR_A='1' then
					IP2BusA_ErrorR <= not Type_of_xfer_A;
					if (BRAM_A_Busy or FIFO_A_Busy)='1' then fsm_A_bramipR <= WAIT_FIFO_BRAM;
					else
						RStartFIFO_A <= '1';
						fsm_A_bramipR <= WAIT_START_FIFO;
					end if;
				else
					IP2BusA_ErrorR <= '0';
					RStartFIFO_A <= '0';
				end if;

			when WAIT_END_REQ =>
				if FIFO_A_BusyR='0' then fsm_A_bramipR <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_BRAM =>
				if (BRAM_A_Busy or FIFO_A_Busy)='0' then
					RStartFIFO_A <= '1';
					fsm_A_bramipR <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_A_BusyR='1' then
					RStartFIFO_A <= '0';
					fsm_A_bramipR <= WAIT_END_REQ;
				end if;

			when others => fsm_A_bramipR <= WAIT_IDLE;
		end case;
	end if;
end process;


---------------------------------------
-- Gestion BUS B
---------------------------------------


FIFO_B_BE : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 8
)
port map (
    clk_i   => BUSB2IP_Clk,
    rst_ni  => BUSB2IP_Resetn,
    --
    wen_i   => FIFO_B_BE_Wr,
    data_i  => BusB2IP_BE,
    full_o  => FIFO_B_BE_Full,
    --
    ren_i   => FIFO_B_BE_Re,
    data_o  => FIFO_B_BE_Out,
    empty_o => FIFO_B_BE_Empty
    );

FIFO_B_ADDR_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => BRAM_ADDR_WIDTH
)
port map (
    clk_i   => BUSB2IP_Clk,
    rst_ni  => BUSB2IP_Resetn,
    --
    wen_i   => FIFO_B_AddrW_Wr,
    data_i  => BusB2IP_Addr(BRAM_ADDR_WIDTH-1 downto 0),
    full_o  => FIFO_B_AddrW_Full,
    --
    ren_i   => FIFO_B_AddrW_Re,
    data_o  => s_BRAM_B_AddrW,
    empty_o => FIFO_B_AddrW_Empty
    );

FIFO_B_DATA_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 64
)
port map (
    clk_i   => BUSB2IP_Clk,
    rst_ni  => BUSB2IP_Resetn,
    --
    wen_i   => FIFO_B_W_Wr,
    data_i  => BusB2IP_Data,
    full_o  => FIFO_B_W_Full,
    --
    ren_i   => FIFO_B_W_Re,
    data_o  => FIFO_B_W_DataOut,
    empty_o => FIFO_B_W_Empty
    );

FIFO_B_W_Disable <= FIFO_B_W_Full or FIFO_B_AddrW_Full or FIFO_B_BE_Full;
FIFO_B_Busy <= FIFO_B_BusyW or FIFO_B_BusyR;

IP2BusB_Error <= IP2BusB_ErrorR or IP2BusB_ErrorW;

s_FIFO_B_Wr <= s_FIFO_B_WrEn and not FIFO_B_W_Disable;
FIFO_B_BE_Wr <= s_FIFO_B_Wr;
FIFO_B_AddrW_Wr <= s_FIFO_B_Wr;
FIFO_B_W_Wr <= s_FIFO_B_Wr;

IP2BusB_WrAck <= s_BusB_WrAckOn or (s_BusB_WrAckEn and not FIFO_B_W_Disable);
IP2BusB_AddrAck <= s_BusB_AdAckOn or (s_BusB_AdAckEn and not FIFO_B_W_Disable);

-- Gestion de l'adresse lecture disponible
process(BUSB2IP_Clk,BUSB2IP_Resetn)
begin
	if BUSB2IP_Resetn='0' then AddrBReadEn <= '0';
	elsif rising_edge(BUSB2IP_Clk) then
		if Set_AddrBRead='1' then AddrBReadEn <= '1';
		elsif Clr_AddrBRead='1' then AddrBReadEn <= '0';
		end if;
	end if;
end process;

-- Gestion des FIFOs Addr (R/W) et FIFO (W) IPIF.
process(BUSB2IP_Clk,BUSB2IP_Resetn)
begin
	if BUSB2IP_Resetn='0' then
		s_FIFO_B_WrEn <= '0';
		FIFO_B_BusyW <= '0';
		FIFO_B_BusyR <= '0';
		s_BusB_WrAckOn <= '0';
		s_BusB_WrAckEn <= '0';
		s_BusB_AdAckOn <= '0';
		s_BusB_AdAckEn <= '0';
		Set_AddrBRead <= '0';
		fsm_B_fifo <= FIFO_IDLE_R;
	elsif rising_edge(BUSB2IP_Clk) then
		case fsm_B_fifo is
			when FIFO_IDLE_R =>
				-- Valeurs par défaut
				s_FIFO_B_WrEn <= '0';
				FIFO_B_BusyW <= '0';
				FIFO_B_BusyR <= '0';
				s_BusB_WrAckOn <= '0';
				s_BusB_WrAckEn <= '0';
				s_BusB_AdAckOn <= '0';
				s_BusB_AdAckEn <= '0';
				Set_AddrBRead <= '0';

				if RStartFIFO_B='1' then
					FIFO_B_BusyR <= '1';
					if AddrBReadEn='1' then fsm_B_fifo <= FIFO_AD_WAIT_READ;
					else fsm_B_fifo <= FIFO_AD_READ;
					end if;
				elsif WStartFIFO_B='1' then
					NbreBurstB <= NbreBurstB_LatchW;
					FIFO_B_BusyW <= '1';
					if FIFO_B_W_Disable='1' then fsm_B_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_B_WrEn <= '1';
						if NbreBurstB_LatchW=FIN_BURST then fsm_B_fifo <= FIFO_AD_WRITE_END_1;
						else
							s_BusB_WrAckEn <= '1';
							s_BusB_AdAckEn <= '1';
							fsm_B_fifo <= FIFO_AD_WRITE;
						end if;
					end if;
				end if;

			when FIFO_IDLE_W =>
				-- Valeurs par défaut
				s_FIFO_B_WrEn <= '0';
				FIFO_B_BusyW <= '0';
				FIFO_B_BusyR <= '0';
				s_BusB_WrAckOn <= '0';
				s_BusB_WrAckEn <= '0';
				s_BusB_AdAckOn <= '0';
				s_BusB_AdAckEn <= '0';
				Set_AddrBRead <= '0';

				if WStartFIFO_B='1' then
					NbreBurstB <= NbreBurstB_LatchW;
					FIFO_B_BusyW <= '1';
					if FIFO_B_W_Disable='1' then fsm_B_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_B_WrEn <= '1';
						if NbreBurstB_LatchW=FIN_BURST then fsm_B_fifo <= FIFO_AD_WRITE_END_1;
						else
							s_BusB_WrAckEn <= '1';
							s_BusB_AdAckEn <= '1';
							fsm_B_fifo <= FIFO_AD_WRITE;
						end if;
					end if;
				elsif RStartFIFO_B='1' then
					FIFO_B_BusyR <= '1';
					if AddrBReadEn='1' then fsm_B_fifo <= FIFO_AD_WAIT_READ;
					else fsm_B_fifo <= FIFO_AD_READ;
					end if;
				end if;

			when FIFO_AD_WRITE =>
				if FIFO_B_W_Disable='0' then
					NbreBurstB <= NbreBurstB-1;
					if BusB2IP_WrReq='0' then
						s_FIFO_B_WrEn <= '0';
						s_BusB_WrAckEn <= '0';
						s_BusB_AdAckEn <= '0';
						fsm_B_fifo <= FIFO_AD_WAIT_WRITE;
					elsif NbreBurstB=BURST_01 then
						s_BusB_WrAckEn <= '0';
						s_BusB_AdAckEn <= '0';
						fsm_B_fifo <= FIFO_AD_WRITE_END_1;
					end if;
				end if;

			when FIFO_AD_WRITE_END_1 =>
				if FIFO_B_W_Disable='0' then
					s_FIFO_B_WrEn <= '0';
					fsm_B_fifo <= FIFO_AD_WRITE_END_2;
				end if;

			when FIFO_AD_WRITE_END_2 =>
				if BRAM_B_Busy='1' then fsm_B_fifo <= FIFO_AD_WRITE_END_3;
				end if;

			when FIFO_AD_WRITE_END_3 =>
				if BRAM_B_Busy='0' then
					s_BusB_WrAckOn <= '1';
					s_BusB_AdAckOn <= '1';
					FIFO_B_BusyW <= '0';
					fsm_B_fifo <= FIFO_IDLE_R;
				end if;

			when FIFO_AD_WAIT_WRITE =>
				if BusB2IP_WrReq='1' then
					s_FIFO_B_WrEn <= '1';
					if NbreBurstB=FIN_BURST then fsm_B_fifo <= FIFO_AD_WRITE_END_1;
					else
						s_BusB_WrAckEn <= '1';
						s_BusB_AdAckEn <= '1';
						fsm_B_fifo <= FIFO_AD_WRITE;
					end if;
				end if;

			when FIFO_AD_WAIT_WRITE_START =>
				if FIFO_B_W_Disable='0' then
					s_FIFO_B_WrEn <= '1';
					if NbreBurstB=FIN_BURST then fsm_B_fifo <= FIFO_AD_WRITE_END_1;
					else
						s_BusB_WrAckEn <= '1';
						s_BusB_AdAckEn <= '1';
						fsm_B_fifo <= FIFO_AD_WRITE;
					end if;
				end if;

			when FIFO_AD_READ =>
				Set_AddrBRead <= '1';
				s_BRAM_B_AddrR <= BusB2IP_Addr(BRAM_ADDR_WIDTH-1 downto 0);
				s_BusB_AdAckOn <= '1';
				FIFO_B_BusyR <= '0';
				fsm_B_fifo <= FIFO_IDLE_W;

			when FIFO_AD_WAIT_READ =>
				if AddrBReadEn='0' then fsm_B_fifo <= FIFO_AD_READ;
				end if;

			when others => fsm_B_fifo <= FIFO_IDLE_R;
		end case;
	end if;
end process;

-- Gestion de l'accès BRAM
process(BUSB2IP_Clk,BUSB2IP_Resetn)
begin
	if BUSB2IP_Resetn='0' then
		s_BRAM_B_WE <= '0';
		FIFO_B_AddrW_Re <= '0';
		FIFO_B_W_Re <= '0';
		FIFO_B_BE_Re <= '0';
		Clr_AddrBRead <= '0';
		IP2BusB_RdAck <= '0';
		BRAM_B_Busy <= '0';
		fsm_B_bram <= BRAM_IDLE_R;
	elsif rising_edge(BUSB2IP_Clk) then
		case fsm_B_bram is
			when BRAM_IDLE_R =>
				-- Valeurs par défaut
				s_BRAM_B_WE <= '0';
				FIFO_B_AddrW_Re <= '0';
				FIFO_B_W_Re <= '0';
				FIFO_B_BE_Re <= '0';
				Clr_AddrBRead <= '0';
				IP2BusB_RdAck <= '0';
				BRAM_B_Busy <= '0';

				if AddrBReadEn='1' then
					s_BRAM_B_Addr <= s_BRAM_B_AddrR;
					Clr_AddrBRead <= '1';
					BRAM_B_Busy <= '1';
					fsm_B_bram <= BRAM_READ0;
				elsif FIFO_B_AddrW_Empty='0' then
					s_BRAM_B_Addr <= s_BRAM_B_AddrW;
					ShRegDataBW <= FIFO_B_W_DataOut;
					ShRegBEB <= FIFO_B_BE_Out;
					BRAM_B_Busy <= '1';
					FIFO_B_AddrW_Re <= '1';
					FIFO_B_W_Re <= '1';
					FIFO_B_BE_Re <= '1';
					fsm_B_bram <= BRAM_WRITE0;
				end if;

			when BRAM_IDLE_W =>
				-- Valeurs par défaut
				s_BRAM_B_WE <= '0';
				FIFO_B_AddrW_Re <= '0';
				FIFO_B_W_Re <= '0';
				FIFO_B_BE_Re <= '0';
				Clr_AddrBRead <= '0';
				IP2BusB_RdAck <= '0';
				BRAM_B_Busy <= '0';

				if FIFO_B_AddrW_Empty='0' then
					s_BRAM_B_Addr <= s_BRAM_B_AddrW;
					ShRegDataBW <= FIFO_B_W_DataOut;
					ShRegBEB <= FIFO_B_BE_Out;
					BRAM_B_Busy <= '1';
					FIFO_B_AddrW_Re <= '1';
					FIFO_B_W_Re <= '1';
					FIFO_B_BE_Re <= '1';
					fsm_B_bram <= BRAM_WRITE0;
				elsif AddrBReadEn='1' then
					s_BRAM_B_Addr <= s_BRAM_B_AddrR;
					Clr_AddrBRead <= '1';
					BRAM_B_Busy <= '1';
					fsm_B_bram <= BRAM_READ0;
				end if;

			when BRAM_WRITE0 =>
				FIFO_B_AddrW_Re <= '0';
				FIFO_B_W_Re <= '0';
				FIFO_B_BE_Re <= '0';
				CptB <= "0001";
				s_BRAM_B_WE <= ShRegBEB(0);
				s_BRAM_B_Data_Out <= ShRegDataBW(7 downto 0);
				ShRegBEB <= '0'&ShRegBEB(7 downto 1);
				ShRegDataBW <= x"00"&ShRegDataBW(63 downto 8);
				fsm_B_bram <= BRAM_WRITE1;

			when BRAM_WRITE1 =>
				s_BRAM_B_Data_Out <= ShRegDataBW(7 downto 0);
				s_BRAM_B_Addr <= s_BRAM_B_Addr+1;
				ShRegBEB <= '0'&ShRegBEB(7 downto 1);
				ShRegDataBW <= x"00"&ShRegDataBW(63 downto 8);
				if CptB(3)='0' then
					s_BRAM_B_WE <= ShRegBEB(0);
					CptB <= CptB + 1;
				else
					s_BRAM_B_WE <= '0';
					fsm_B_bram <= BRAM_IDLE_R;
				end if;

			when BRAM_READ0 =>
				Clr_AddrBRead <= '0';
				CptB <= "0000";
				s_BRAM_B_Addr <= s_BRAM_B_Addr+1;
				fsm_B_bram <= BRAM_READ1;

			when BRAM_READ1 =>
				if CptB(3)='0' then
					ShRegDataBR <= BRAM_DOUTB&ShRegDataBR(63 downto 8);
					s_BRAM_B_Addr <= s_BRAM_B_Addr+1;
					CptB <= CptB + 1;
				else
					IP2BusB_Data <= ShRegDataBR;
					IP2BusB_RdAck <= '1';
					fsm_B_bram <= BRAM_IDLE_W;
				end if;

			when others => fsm_B_bram <= BRAM_IDLE_R;
		end case;
	end if;
end process;


StartW_B <= BusB2IP_CS and BusB2IP_WrReq;
StartR_B <= BusB2IP_CS and BusB2IP_RdReq;

-- Gestion des requêtes d'écriture
process(BUSB2IP_Clk,BUSB2IP_Resetn)
begin
	if BUSB2IP_Resetn='0' then
		IP2BusB_ErrorW <= '0';
		WStartFIFO_B <= '0';
		fsm_B_bramipW <= WAIT_IDLE;
	elsif rising_edge(BUSB2IP_Clk) then
		case fsm_B_bramipW is
			when WAIT_IDLE =>
				if StartW_B='1' then
					NbreBurstB_LatchW <= BusB2IP_BurstLength;
					IP2BusB_ErrorW <= not Type_of_xfer_B;
					if (BRAM_B_Busy or FIFO_B_Busy)='1' then fsm_B_bramipW <= WAIT_FIFO_BRAM;
					else
						WStartFIFO_B <= '1';
						fsm_B_bramipW <= WAIT_START_FIFO;
					end if;
				else
					IP2BusB_ErrorW <= '0';
					WStartFIFO_B <= '0';
					NbreBurstB_LatchW <= (others => '0');
				end if;

			when WAIT_END_REQ =>
				if FIFO_B_BusyW='0' then fsm_B_bramipW <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_BRAM =>
				if (BRAM_B_Busy or FIFO_B_Busy)='0' then
					WStartFIFO_B <= '1';
					fsm_B_bramipW <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_B_BusyW='1' then
					WStartFIFO_B <= '0';
					fsm_B_bramipW <= WAIT_END_REQ;
				end if;

			when others => fsm_B_bramipW <= WAIT_IDLE;
		end case;
	end if;
end process;

-- Gestion des requêtes de lecture
process(BUSB2IP_Clk,BUSB2IP_Resetn)
begin
	if BUSB2IP_Resetn='0' then
		IP2BusB_ErrorR <= '0';
		RStartFIFO_B <= '0';
		fsm_B_bramipR <= WAIT_IDLE;
	elsif rising_edge(BUSB2IP_Clk) then
		case fsm_B_bramipR is
			when WAIT_IDLE =>
				if StartR_B='1' then
					IP2BusB_ErrorR <= not Type_of_xfer_B;
					if (BRAM_B_Busy or FIFO_B_Busy)='1' then fsm_B_bramipR <= WAIT_FIFO_BRAM;
					else
						RStartFIFO_B <= '1';
						fsm_B_bramipR <= WAIT_START_FIFO;
					end if;
				else
					IP2BusB_ErrorR <= '0';
					RStartFIFO_B <= '0';
				end if;

			when WAIT_END_REQ =>
				if FIFO_B_BusyR='0' then fsm_B_bramipR <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_BRAM =>
				if (BRAM_B_Busy or FIFO_B_Busy)='0' then
					RStartFIFO_B <= '1';
					fsm_B_bramipR <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_B_BusyR='1' then
					RStartFIFO_B <= '0';
					fsm_B_bramipR <= WAIT_END_REQ;
				end if;

			when others => fsm_B_bramipR <= WAIT_IDLE;
		end case;
	end if;
end process;


end Behavioral;
