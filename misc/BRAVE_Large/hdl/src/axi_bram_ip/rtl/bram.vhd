-------------------------------------------------------
--! @file       BRAM.vhd
--! @brief      VHDL BRAM 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity BRAM is
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
end BRAM;

architecture Behavioral of BRAM is

type MEM_TYPE is array ((2**ADDR_WITDH)-1 downto 0) of std_logic_vector(DATA_WITDH-1 downto 0);
shared variable MEM : MEM_TYPE:=(others => (others => '0'));

begin

process (CKA)
begin
	if rising_edge(CKA) then
		if WEA='1' then MEM(conv_integer(ADRA)):=DINA;
		else DOUTA <= MEM(conv_integer(ADRA));
		end if;
	end if;
end process;

process (CKB)
begin
	if rising_edge(CKB) then
		if WEB='1' then MEM(conv_integer(ADRB)):=DINB;
		else DOUTB <= MEM(conv_integer(ADRB));
		end if;
	end if;
end process;


end Behavioral;

