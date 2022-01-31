-------------------------------------------------------
--! @file       Compteur_Addr.vhd
--! @brief      Simple counter
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity Compteur_Addr is
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

end entity Compteur_Addr;


architecture Behavioral of Compteur_Addr is

signal Offset,Cpt,Offset_Mask,Offset_Inc : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

Offset_Mask(DATA_WIDTH-1 downto MASK_WIDTH) <= (others => '1');
Offset_Mask(MASK_WIDTH-1 downto 0) <= not Mask;
Offset_Inc(DATA_WIDTH-1 downto MASK_WIDTH+1) <= (others => '0');
Offset_Inc(MASK_WIDTH downto 0) <= Inc_Step;

Data_Out <= (Cpt + (Offset and WrapMask)) and Offset_Mask when Wrap='1'
			else (Cpt + Offset) and Offset_Mask;

process(Clk)
begin
	if rising_edge(Clk) then
		if Data_Load='1' then
			if Wrap='0' then
				Cpt <= Data_In;
				Offset <= (others => '0');
			else
				Cpt <= Data_In and not WrapMask;
				Offset <= Data_In and WrapMask;
			end if;
		elsif Data_Inc='1' then Offset <= Offset + Offset_Inc;
		end if;
	end if;
end process;
			
end Behavioral;
