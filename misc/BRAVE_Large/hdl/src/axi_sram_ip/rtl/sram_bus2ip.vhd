-------------------------------------------------------
--! @file       SRAM_BUS2IP.vhd
--! @brief      external SRAM drivers
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

entity SRAM_BUS2IP is
	generic (
		I2P_ADDR_WIDTH : integer := 17;
		I2P_BURST_WIDTH : integer := 4
		);
    Port (
	-- Signaux SRAM
		SRAM_Addr : out std_logic_vector(15 downto 0);
		SRAM_Data : inout std_logic_vector(15 downto 0);
		SRAM_CEn : out std_logic;
		SRAM_OEn : out std_logic;
		SRAM_WEn : out std_logic;
		SRAM_LBn : out std_logic;
		SRAM_UBn : out std_logic;

	-- Signaux BUS2IP
		BUS2IP_Clk : in std_logic;
		BUS2IP_Resetn : in std_logic;
		IP2Bus_Data : out std_logic_vector(63 downto 0);
		IP2Bus_WrAck : out std_logic;
		IP2Bus_RdAck : out std_logic;
		IP2Bus_AddrAck : out std_logic;
		IP2Bus_Error : out std_logic;
		Bus2IP_Addr : in std_logic_vector(I2P_ADDR_WIDTH-1 downto 0);
		Bus2IP_Data : in std_logic_vector(63 downto 0);
		Bus2IP_RNW : in std_logic;
		Bus2IP_BE : in std_logic_vector(7 downto 0);
		Bus2IP_Burst : in std_logic;
		Bus2IP_BurstLength : in std_logic_vector(I2P_BURST_WIDTH-1 downto 0);
		Bus2IP_WrReq : in std_logic;
		Bus2IP_RdReq : in std_logic;
		Bus2IP_CS : in std_logic;
		Type_of_xfer : in std_logic
		);
end SRAM_BUS2IP;

architecture Behavioral of SRAM_BUS2IP is

-- Machines d'état

type fsm_sram_type is
(
	SRAM_IDLE_R,
	SRAM_IDLE_W,
	SRAM_WRITE0_1,
	SRAM_WRITE0_2,
	SRAM_WRITE1_1,
	SRAM_WRITE1_2,
	SRAM_WRITE2_1,
	SRAM_WRITE2_2,
	SRAM_WRITE3_1,
	SRAM_READ0,
	SRAM_READ1,
	SRAM_READ2,
	SRAM_READ3
);

type fsm_sramip_type is
(
	WAIT_IDLE,
	WAIT_END_REQ,
	WAIT_FIFO_SRAM,
	WAIT_START_FIFO
 );

type fsm_fifo_type is
(
	FIFO_IDLE_R,
	FIFO_IDLE_W,
	FIFO_AD_WRITE,
	FIFO_AD_WAIT_WRITE,
	FIFO_AD_WAIT_WRITE_START,
	FIFO_AD_READ,
	FIFO_AD_WAIT_READ
 );


constant FIN_BURST : std_logic_vector(I2P_BURST_WIDTH-1 downto 0):=conv_std_logic_vector(0,I2P_BURST_WIDTH);

signal s_SRAM_Data_Out : std_logic_vector(15 downto 0);
signal s_SRAM_CEn,s_SRAM_OEn,s_SRAM_LBn,s_SRAM_UBn : std_logic;
signal s_SRAM_Addr,s_SRAM_AddrW,s_SRAM_AddrR : std_logic_vector(15 downto 0);

signal StartW,StartR : std_logic;
signal NbreBurst_LatchW,NbreBurst : std_logic_vector(I2P_BURST_WIDTH-1 downto 0);
signal WStartFIFO,RStartFIFO : std_logic;

signal FIFO_BE_Out : std_logic_vector(7 downto 0);
signal FIFO_BE_Wr,FIFO_BE_Re : std_logic;
signal FIFO_BE_Full,FIFO_BE_Empty : std_logic;

signal FIFO_AddrW_Wr,FIFO_AddrW_Re : std_logic;
signal FIFO_AddrW_Full,FIFO_AddrW_Empty : std_logic;

signal FIFO_W_Wr,FIFO_W_Re : std_logic;
signal FIFO_W_Full,FIFO_W_Empty : std_logic;
signal FIFO_W_Disable,FIFO_Busy,FIFO_BusyW,FIFO_BusyR : std_logic;
signal FIFO_W_DataOut : std_logic_vector(63 downto 0);

signal AddrReadEn,Set_AddrRead,Clr_AddrRead : std_logic;

signal SRAM_Busy : std_logic;
signal fsm_sram : fsm_sram_type;
signal fsm_fifo : fsm_fifo_type;
signal fsm_sramipW,fsm_sramipR : fsm_sramip_type;

signal IP2Bus_ErrorW,IP2Bus_ErrorR : std_logic;

signal s_AdAckOn,s_AdAckEn : std_logic;
signal s_WrAckEn : std_logic;
signal s_FIFO_Wr,s_FIFO_WrEn : std_logic;

begin

FIFO_BE : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 8
)
port map (
    clk_i   => BUS2IP_Clk,
    rst_ni  => BUS2IP_Resetn,
    --
    wen_i   => FIFO_BE_Wr,
    data_i  => Bus2IP_BE,
    full_o  => FIFO_BE_Full,
    --
    ren_i   => FIFO_BE_Re,
    data_o  => FIFO_BE_Out,
    empty_o => FIFO_BE_Empty
    );

FIFO_ADDR_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 16
)
port map (
    clk_i   => BUS2IP_Clk,
    rst_ni  => BUS2IP_Resetn,
    --
    wen_i   => FIFO_AddrW_Wr,
    data_i  => Bus2IP_Addr(16 downto 1),
    full_o  => FIFO_AddrW_Full,
    --
    ren_i   => FIFO_AddrW_Re,
    data_o  => s_SRAM_AddrW,
    empty_o => FIFO_AddrW_Empty
    );

FIFO_DATA_W : entity work.sync_fifo
generic map (
	AW => 4,
	DW => 64
)
port map (
    clk_i   => BUS2IP_Clk,
    rst_ni  => BUS2IP_Resetn,
    --
    wen_i   => FIFO_W_Wr,
    data_i  => Bus2IP_Data,
    full_o  => FIFO_W_Full,
    --
    data_o  => FIFO_W_DataOut,
    ren_i   => FIFO_W_Re,
    empty_o => FIFO_W_Empty
    );

SRAM_Addr <= s_SRAM_Addr;
SRAM_Data <= (others => 'Z') when (s_SRAM_CEn or not s_SRAM_OEn)='1' else s_SRAM_Data_Out;
SRAM_CEn <= s_SRAM_CEn;
SRAM_OEn <= s_SRAM_OEn;
SRAM_LBn <= s_SRAM_LBn;
SRAM_UBn <= s_SRAM_UBn;

FIFO_W_Disable <= FIFO_W_Full or FIFO_AddrW_Full or FIFO_BE_Full;
FIFO_Busy <= FIFO_BusyW or FIFO_BusyR;

IP2Bus_Error <= IP2Bus_ErrorR or IP2Bus_ErrorW;

s_FIFO_Wr <= s_FIFO_WrEn and not FIFO_W_Disable;
FIFO_BE_Wr <= s_FIFO_Wr;
FIFO_AddrW_Wr <= s_FIFO_Wr;
FIFO_W_Wr <= s_FIFO_Wr;

IP2Bus_WrAck <= s_WrAckEn and not FIFO_W_Disable;
IP2Bus_AddrAck <= s_AdAckOn or (s_AdAckEn and not FIFO_W_Disable);


-- Gestion de l'adresse lecture disponible
process(BUS2IP_Clk,BUS2IP_Resetn)
begin
	if BUS2IP_Resetn='0' then AddrReadEn <= '0';
	elsif rising_edge(BUS2IP_Clk) then
		if Set_AddrRead='1' then AddrReadEn <= '1';
		elsif Clr_AddrRead='1' then AddrReadEn <= '0';
		end if;
	end if;
end process;

-- Gestion des FIFOs Addr (R/W) et FIFO Data/BE (W) IPIF.
process(BUS2IP_Clk,BUS2IP_Resetn)
begin
	if BUS2IP_Resetn='0' then
		s_FIFO_WrEn <= '0';
		FIFO_BusyW <= '0';
		FIFO_BusyR <= '0';
		s_WrAckEn <= '0';
		s_AdAckOn <= '0';
		s_AdAckEn <= '0';
		Set_AddrRead <= '0';
		fsm_fifo <= FIFO_IDLE_R;
	elsif rising_edge(BUS2IP_Clk) then
		case fsm_fifo is
			when FIFO_IDLE_R =>
				-- Valeurs par défaut
				s_FIFO_WrEn <= '0';
				FIFO_BusyW <= '0';
				FIFO_BusyR <= '0';
				s_WrAckEn <= '0';
				s_AdAckOn <= '0';
				s_AdAckEn <= '0';
				Set_AddrRead <= '0';

				if RStartFIFO='1' then
					FIFO_BusyR <= '1';
					if AddrReadEn='1' then fsm_fifo <= FIFO_AD_WAIT_READ;
					else fsm_fifo <= FIFO_AD_READ;
					end if;
				elsif WStartFIFO='1' then
					NbreBurst <= NbreBurst_LatchW;
					FIFO_BusyW <= '1';
					if FIFO_W_Disable='1' then fsm_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_WrEn <= '1';
						s_WrAckEn <= '1';
						s_AdAckEn <= '1';
						fsm_fifo <= FIFO_AD_WRITE;
					end if;
				end if;

			when FIFO_IDLE_W =>
				-- Valeurs par défaut
				s_FIFO_WrEn <= '0';
				FIFO_BusyW <= '0';
				FIFO_BusyR <= '0';
				s_WrAckEn <= '0';
				s_AdAckOn <= '0';
				s_AdAckEn <= '0';
				Set_AddrRead <= '0';

				if WStartFIFO='1' then
					NbreBurst <= NbreBurst_LatchW;
					FIFO_BusyW <= '1';
					if FIFO_W_Disable='1' then fsm_fifo <= FIFO_AD_WAIT_WRITE_START;
					else
						s_FIFO_WrEn <= '1';
						s_WrAckEn <= '1';
						s_AdAckEn <= '1';
						fsm_fifo <= FIFO_AD_WRITE;
					end if;
				elsif RStartFIFO='1' then
					FIFO_BusyR <= '1';
					if AddrReadEn='1' then fsm_fifo <= FIFO_AD_WAIT_READ;
					else fsm_fifo <= FIFO_AD_READ;
					end if;
				end if;

			when FIFO_AD_WRITE =>
				if FIFO_W_Disable='0' then
					NbreBurst <= NbreBurst-1;
					if NbreBurst=FIN_BURST then
						FIFO_BusyW <= '0';
						s_FIFO_WrEn <= '0';
						s_WrAckEn <= '0';
						s_AdAckEn <= '0';
						fsm_fifo <= FIFO_IDLE_R;
					elsif Bus2IP_WrReq='0' then
						s_FIFO_WrEn <= '0';
						s_WrAckEn <= '0';
						s_AdAckEn <= '0';
						fsm_fifo <= FIFO_AD_WAIT_WRITE;
					end if;
				end if;

			when FIFO_AD_WAIT_WRITE =>
				if Bus2IP_WrReq='1' then
					s_FIFO_WrEn <= '1';
					s_WrAckEn <= '1';
					s_AdAckEn <= '1';
					fsm_fifo <= FIFO_AD_WRITE;
				end if;

			when FIFO_AD_WAIT_WRITE_START =>
				if FIFO_W_Disable='0' then
					s_FIFO_WrEn <= '1';
					s_WrAckEn <= '1';
					s_AdAckEn <= '1';
					fsm_fifo <= FIFO_AD_WRITE;
				end if;

			when FIFO_AD_READ =>
				Set_AddrRead <= '1';
				s_SRAM_AddrR <= Bus2IP_Addr(16 downto 1);
				s_AdAckOn <= '1';
				FIFO_BusyR <= '0';
				fsm_fifo <= FIFO_IDLE_W;

			when FIFO_AD_WAIT_READ =>
				if AddrReadEn='0' then fsm_fifo <= FIFO_AD_READ;
				end if;

			when others => fsm_fifo <= FIFO_IDLE_R;
		end case;
	end if;
end process;

-- Gestion de l'accès SRAM.
process(BUS2IP_Clk,BUS2IP_Resetn)
begin
	if BUS2IP_Resetn='0' then
		s_SRAM_CEn <= '1';
		FIFO_AddrW_Re <= '0';
		FIFO_W_Re <= '0';
		FIFO_BE_Re <= '0';
		Clr_AddrRead <= '0';
		IP2Bus_RdAck <= '0';
		SRAM_Busy <= '0';
		fsm_sram <= SRAM_IDLE_R;
	elsif rising_edge(BUS2IP_Clk) then
		case fsm_sram is
			when SRAM_IDLE_R =>
				-- Valeurs par défaut
				s_SRAM_CEn <= '1';
				s_SRAM_OEn <= '1';
				SRAM_WEn <= '1';
				FIFO_AddrW_Re <= '0';
				s_SRAM_LBn <= '1';
				s_SRAM_UBn <= '1';
				FIFO_W_Re <= '0';
				FIFO_BE_Re <= '0';
				Clr_AddrRead <= '0';
				IP2Bus_RdAck <= '0';
				SRAM_Busy <= '0';

				if AddrReadEn='1' then
					s_SRAM_CEn <= '0';
					s_SRAM_OEn <= '0';
					s_SRAM_Addr <= s_SRAM_AddrR;
					Clr_AddrRead <= '1';
					s_SRAM_LBn <= '0';
					s_SRAM_UBn <= '0';
					SRAM_Busy <= '1';
					fsm_sram <= SRAM_READ0;
				elsif FIFO_AddrW_Empty='0' then
					s_SRAM_CEn <= '0';
					s_SRAM_Addr <= s_SRAM_AddrW;
					s_SRAM_LBn <= not FIFO_BE_Out(0);
					s_SRAM_UBn <= not FIFO_BE_Out(1);
					s_SRAM_Data_Out <= FIFO_W_DataOut(15 downto 0);
					FIFO_AddrW_Re <= '1';
					SRAM_Busy <= '1';
					fsm_sram <= SRAM_WRITE0_1;
				end if;

			when SRAM_IDLE_W =>
				-- Valeurs par défaut
				s_SRAM_CEn <= '1';
				s_SRAM_OEn <= '1';
				SRAM_WEn <= '1';
				FIFO_AddrW_Re <= '0';
				s_SRAM_LBn <= '1';
				s_SRAM_UBn <= '1';
				FIFO_W_Re <= '0';
				FIFO_BE_Re <= '0';
				Clr_AddrRead <= '0';
				IP2Bus_RdAck <= '0';
				SRAM_Busy <= '0';

				if FIFO_AddrW_Empty='0' then
					s_SRAM_CEn <= '0';
					s_SRAM_Addr <= s_SRAM_AddrW;
					s_SRAM_LBn <= not FIFO_BE_Out(0);
					s_SRAM_UBn <= not FIFO_BE_Out(1);
					s_SRAM_Data_Out <= FIFO_W_DataOut(15 downto 0);
					FIFO_AddrW_Re <= '1';
					SRAM_Busy <= '1';
					fsm_sram <= SRAM_WRITE0_1;
				elsif AddrReadEn='1' then
					s_SRAM_CEn <= '0';
					s_SRAM_OEn <= '0';
					s_SRAM_Addr <= s_SRAM_AddrR;
					Clr_AddrRead <= '1';
					s_SRAM_LBn <= '0';
					s_SRAM_UBn <= '0';
					SRAM_Busy <= '1';
					fsm_sram <= SRAM_READ0;
				end if;

			when SRAM_WRITE0_1 =>
				SRAM_WEn <= '0';
				FIFO_AddrW_Re <= '0';
				fsm_sram <= SRAM_WRITE0_2;

			when SRAM_WRITE0_2 =>
				s_SRAM_Addr <= s_SRAM_Addr+1;
				s_SRAM_LBn <= not FIFO_BE_Out(2);
				s_SRAM_UBn <= not FIFO_BE_Out(3);
				s_SRAM_Data_Out <= FIFO_W_DataOut(31 downto 16);
				SRAM_WEn <= '1';
				fsm_sram <= SRAM_WRITE1_1;

			when SRAM_WRITE1_1 =>
				SRAM_WEn <= '0';
				fsm_sram <= SRAM_WRITE1_2;

			when SRAM_WRITE1_2 =>
				s_SRAM_Addr <= s_SRAM_Addr+1;
				s_SRAM_LBn <= not FIFO_BE_Out(4);
				s_SRAM_UBn <= not FIFO_BE_Out(5);
				s_SRAM_Data_Out <= FIFO_W_DataOut(47 downto 32);
				SRAM_WEn <= '1';
				fsm_sram <= SRAM_WRITE2_1;

			when SRAM_WRITE2_1 =>
				SRAM_WEn <= '0';
				fsm_sram <= SRAM_WRITE2_2;

			when SRAM_WRITE2_2 =>
				s_SRAM_Addr <= s_SRAM_Addr+1;
				s_SRAM_LBn <= not FIFO_BE_Out(6);
				s_SRAM_UBn <= not FIFO_BE_Out(7);
				s_SRAM_Data_Out <= FIFO_W_DataOut(63 downto 48);
				FIFO_W_Re <= '1';
				FIFO_BE_Re <= '1';
				SRAM_WEn <= '1';
				fsm_sram <= SRAM_WRITE3_1;

			when SRAM_WRITE3_1 =>
				SRAM_WEn <= '0';
				FIFO_BE_Re <= '0';
				FIFO_W_Re <= '0';
				fsm_sram <= SRAM_IDLE_R;

			when SRAM_READ0 =>
				Clr_AddrRead <= '0';
				IP2Bus_Data(15 downto 0) <= SRAM_Data;
				s_SRAM_Addr <= s_SRAM_Addr+1;
				fsm_sram <= SRAM_READ1;

			when SRAM_READ1 =>
				IP2Bus_Data(31 downto 16) <= SRAM_Data;
				s_SRAM_Addr <= s_SRAM_Addr+1;
				fsm_sram <= SRAM_READ2;

			when SRAM_READ2 =>
				IP2Bus_Data(47 downto 32) <= SRAM_Data;
				s_SRAM_Addr <= s_SRAM_Addr+1;
				fsm_sram <= SRAM_READ3;

			when SRAM_READ3 =>
				IP2Bus_Data(63 downto 48) <= SRAM_Data;
				IP2Bus_RdAck <= '1';
				fsm_sram <= SRAM_IDLE_W;

			when others => fsm_sram <= SRAM_IDLE_R;
		end case;
	end if;
end process;


StartW <= Bus2IP_CS and Bus2IP_WrReq;
StartR <= Bus2IP_CS and Bus2IP_RdReq;

-- Gestion des requêtes d'écriture
process(BUS2IP_Clk,BUS2IP_Resetn)
begin
	if BUS2IP_Resetn='0' then
		IP2Bus_ErrorW <= '0';
		WStartFIFO <= '0';
		fsm_sramipW <= WAIT_IDLE;
	elsif rising_edge(BUS2IP_Clk) then
		case fsm_sramipW is
			when WAIT_IDLE =>
				if StartW='1' then
					NbreBurst_LatchW <= Bus2IP_BurstLength;
					IP2Bus_ErrorW <= not Type_of_xfer;
					if (SRAM_Busy or FIFO_Busy)='1' then fsm_sramipW <= WAIT_FIFO_SRAM;
					else
						WStartFIFO <= '1';
						fsm_sramipW <= WAIT_START_FIFO;
					end if;
				else
					IP2Bus_ErrorW <= '0';
					WStartFIFO <= '0';
					NbreBurst_LatchW <= (others => '0');
				end if;

			when WAIT_END_REQ =>
				if FIFO_BusyW='0' then fsm_sramipW <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_SRAM =>
				if (SRAM_Busy or FIFO_Busy)='0' then
					WStartFIFO <= '1';
					fsm_sramipW <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_BusyW='1' then
					WStartFIFO <= '0';
					fsm_sramipW <= WAIT_END_REQ;
				end if;

			when others => fsm_sramipW <= WAIT_IDLE;
		end case;
	end if;
end process;

-- Gestion des requêtes de lecture
process(BUS2IP_Clk,BUS2IP_Resetn)
begin
	if BUS2IP_Resetn='0' then
		IP2Bus_ErrorR <= '0';
		RStartFIFO <= '0';
		fsm_sramipR <= WAIT_IDLE;
	elsif rising_edge(BUS2IP_Clk) then
		case fsm_sramipR is
			when WAIT_IDLE =>
				if StartR='1' then
					IP2Bus_ErrorR <= not Type_of_xfer;
					if (SRAM_Busy or FIFO_Busy)='1' then fsm_sramipR <= WAIT_FIFO_SRAM;
					else
						RStartFIFO <= '1';
						fsm_sramipR <= WAIT_START_FIFO;
					end if;
				else
					IP2Bus_ErrorR <= '0';
					RStartFIFO <= '0';
				end if;

			when WAIT_END_REQ =>
				if FIFO_BusyR='0' then fsm_sramipR <= WAIT_IDLE;
				end if;

			when WAIT_FIFO_SRAM =>
				if (SRAM_Busy or FIFO_Busy)='0' then
					RStartFIFO <= '1';
					fsm_sramipR <= WAIT_START_FIFO;
				end if;

			when WAIT_START_FIFO =>
				if FIFO_BusyR='1' then
					RStartFIFO <= '0';
					fsm_sramipR <= WAIT_END_REQ;
				end if;

			when others => fsm_sramipR <= WAIT_IDLE;
		end case;
	end if;
end process;

end Behavioral;
