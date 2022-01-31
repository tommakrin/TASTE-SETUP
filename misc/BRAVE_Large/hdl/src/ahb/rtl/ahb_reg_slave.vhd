-------------------------------------------------------
--! @file       ahb_reg_slave.vhd
--! @brief      Simple AHB register bank
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

library work;
use work.common_functions_pkg.all;

entity ahb_reg_slave is
Port (
	S_AHB_HCLK 		: in  std_logic;
	S_AHB_HRESETN	: in  std_logic;
    
	S_AHB_HSEL		: in std_logic;
	S_AHB_HADDR		: in std_logic_vector(31 downto 0);
	S_AHB_HWRITE	: in std_logic;
	S_AHB_HSIZE		: in std_logic_vector(2 downto 0);
	S_AHB_HBURST	: in std_logic_vector(2 downto 0);
	S_AHB_HPROT		: in std_logic_vector(6 downto 0);
	S_AHB_HTRANS	: in std_logic_vector(1 downto 0);
	S_AHB_HMASTLOCK	: in std_logic;
	S_AHB_HNONSEC   : in std_logic;
	
	S_AHB_HWDATA	: in std_logic_vector(63 downto 0);
    
	S_AHB_HREADY	: out  std_logic;
	S_AHB_HRDATA	: out  std_logic_vector(63 downto 0);
	S_AHB_HRESP		: out  std_logic
);
end ahb_reg_slave;

architecture Behavioral of ahb_reg_slave is

type Reg64Array is array (0 to 31) of std_logic_vector(63 downto 0);

-- Machines d'état

type fsm_ahb_type is 
(
	AHB_IDLE,
	AHB_READ,
	AHB_WRITE,
	AHB_WAIT
 );

signal AddrR,AddrW : std_logic_vector(31 downto 0);
signal DataR,DataW : std_logic_vector(63 downto 0);

signal idx        : integer; 
signal memory     : Reg64Array;
signal addr_1     : std_logic_vector(7 downto 0);
signal data_place : integer;
signal hready     : std_logic; 

signal fsm_ahb : fsm_ahb_type;

begin

S_AHB_HREADY  <= hready;
S_AHB_HRESP   <= '0';
S_AHB_HRDATA  <= DataR;
DataW         <= S_AHB_HWDATA;
idx           <= conv_integer(addr_1(7 downto 3));
data_place    <= conv_integer(addr_1(2 downto 0));

process(S_AHB_HCLK,S_AHB_HRESETN)
begin
	if S_AHB_HRESETN='0' then
		fsm_ahb <= AHB_IDLE;
		DataR   <= (others => '0');
		addr_1  <= (others => '0');
		hready  <= '1';
	elsif rising_edge(S_AHB_HCLK) then
		hready <= '1';
		AddrW  <= S_AHB_HADDR;
		case fsm_ahb is
			when AHB_IDLE =>
				if S_AHB_HSEL='1' then
					if S_AHB_HTRANS="10" then
						addr_1 <= S_AHB_HADDR(7 downto 0);
						if S_AHB_HWRITE='1' then 
							fsm_ahb <= AHB_WRITE;
						else
							hready  <= '0';
							fsm_ahb <= AHB_READ;
						end if;
					end if;
				end if;
				
			when AHB_READ =>
				DataR <= memory(conv_integer(addr_1(7 downto 3)));
				if S_AHB_HSEL='1' then
					case S_AHB_HTRANS is
						when "00" => 
							fsm_ahb <= AHB_IDLE;
						when "10" =>
							addr_1 <= S_AHB_HADDR(7 downto 0);
							if S_AHB_HWRITE='1' then 
								fsm_ahb <= AHB_WRITE;
							else
								hready <= '0'; 
							end if;
						when "11" =>
							if hready = '1' then
								hready <= '0';
							end if;
							addr_1 <= S_AHB_HADDR(7 downto 0);
						when others => NULL;
					end case;
				else 
					fsm_ahb <= AHB_IDLE;
				end if;
				
			when AHB_WRITE =>
				if S_AHB_HSEL='1' then
					memory(idx) <= DataW;
					case S_AHB_HTRANS is
						when "00" =>
						 	fsm_ahb <= AHB_IDLE;
						when "10" =>
							addr_1 <= S_AHB_HADDR(7 downto 0);
							if S_AHB_HWRITE='0' then
								 fsm_ahb <= AHB_READ;
								 hready  <= '0';
							end if;
						when "01" => 
							addr_1  <= S_AHB_HADDR(7 downto 0);
							fsm_ahb <= AHB_WAIT;
						when "11" =>
							addr_1  <= S_AHB_HADDR(7 downto 0);
                        when others => NULL;
					end case;
				else fsm_ahb <= AHB_IDLE;
				end if;
				
			when AHB_WAIT =>
				if S_AHB_HSEL='1' then
					case S_AHB_HTRANS is
						when "00" => 
							fsm_ahb <= AHB_IDLE;
						when "11" =>
							addr_1  <= S_AHB_HADDR(7 downto 0);
							fsm_ahb <= AHB_WRITE;
						when others => NULL;
					end case;
				else 
					fsm_ahb <= AHB_IDLE;
				end if;
		end case;
	end if;
end process;


end Behavioral;
