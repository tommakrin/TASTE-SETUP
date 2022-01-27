-------------------------------------------------------
--! @file       uart_rxtx.vhd
--! @brief      Full duplex UART
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

entity uart_rxtx is
generic (
   DIV_WIDTH : integer
);
Port (

   clk    : in std_logic;
   reset  : in std_logic;
   enable : in std_logic;

   -- configuration
   -- common to TX & RX
   baud        : in std_logic_vector(DIV_WIDTH - 1 downto 0);
   data_7_bits : in std_logic;
   parity_en   : in std_logic;
   parity_odd  : in std_logic;
   stop_2      : in std_logic;
   msb_first   : in std_logic;

   -- TX
   txreset    : in  std_logic;
   txenable   : in  std_logic;
   txdata     : in  std_logic_vector(7 downto 0);
   txdata_w   : in  std_logic;
   txready    : out std_logic;
   txempty    : out std_logic;
   txdone     : out std_logic;
   txoverflow : out std_logic;

   -- RX
   rxreset    : in  std_logic;
   rxenable   : in  std_logic;
   rxdata     : out std_logic_vector(7 downto 0);
   rxready    : out std_logic := '0';
   rxack      : in  std_logic;
   rxoverflow : out std_logic;
   rxPERR     : out std_logic;          -- parity
   rxFERR     : out std_logic;          -- frame error

   -- Interfaces physiques
   TX : out std_logic;
   RX : in  std_logic
);
end uart_rxtx;

architecture Structure of uart_rxtx is

   component UART_Rx is
   Generic (
      DIV_WIDTH : integer
   );
   Port (
      Clk          : in std_logic;
      Reset        : in std_logic;
      Enable       : in std_logic;

      Set_Divider_val : in std_logic_vector(DIV_WIDTH - 1 downto 0);

      Set_Data_7        : in std_logic;
      Set_Parity_Bit    : in std_logic;
      Set_Parity_Odd    : in std_logic;
      Set_Stop_Bit      : in std_logic;
      Set_Get_MSB_First : in std_logic;

      Idle : out std_logic;
      Data_Out     : out std_logic_vector(7 downto 0);
      Data_Out_En  : out std_logic := '0';
      Data_Out_Ack : in  std_logic;

      RxStart : out std_logic;

      Overflow_Error : out std_logic;
      Parity_Error   : out std_logic;
      Frame_Error    : out std_logic;

      RX    : in  std_logic
   );
   end component;

   component UART_Tx is
   Generic (
      DIV_WIDTH :    integer
   );
   Port (
      Clk          : in std_logic;
      Reset        : in std_logic;
      Enable       : in std_logic;

      Set_Divider_val : in std_logic_vector(DIV_WIDTH - 1 downto 0);

      Set_Data_7         : in std_logic;
      Set_Parity_Bit     : in std_logic;
      Set_Parity_Odd     : in std_logic;
      Set_Stop_Bit       : in std_logic;
      Set_Send_MSB_First : in std_logic;

      Idle : out std_logic;

      -- The input data: 8 bit - this is the UART sender
      -- Provide data on Data_In and set In_W to high
      Data_In    : in  std_logic_vector(7 downto 0);
      Data_In_W  : in  std_logic;
      Data_W_En  : out std_logic;
      Data_empty : out std_logic;

      TxEnd : out std_logic;

      TX : out std_logic
   );
   end component;

   signal txready_i : std_logic;

   signal txreset_i : std_logic;
   signal rxreset_i : std_logic;
   signal txenable_i : std_logic;
   signal rxenable_i : std_logic;

begin

   txreset_i <= reset or txreset;
   rxreset_i <= reset or rxreset;
   txenable_i <= enable and txenable;
   rxenable_i <= enable and rxenable;

   rxinst : UART_Rx
   generic map (
      DIV_WIDTH => DIV_WIDTH
   )
   port map (
      clk    => clk,
      reset  => rxreset_i,
      enable => rxenable_i,

      Set_Divider_val => baud,

      Set_Data_7        => data_7_bits,
      Set_Parity_Bit    => parity_en,
      Set_Parity_Odd    => parity_odd,
      Set_Stop_Bit      => stop_2,
      Set_Get_MSB_First => msb_first,

      Data_Out       => rxdata,
      Data_Out_En    => rxready,
      Data_Out_Ack   => rxack,
      Overflow_Error => rxoverflow,
      Parity_Error   => rxPERR,
      Frame_Error    => rxFERR,

      rx => rx
   );

   txready    <= txready_i;
   txoverflow <= txdata_w and not txready_i;

   txinst : UART_Tx
   generic map (
      DIV_WIDTH => DIV_WIDTH
   )
   port map (
      clk    => clk,
      reset  => txreset_i,
      enable => txenable_i,

      Set_Divider_val => baud,

      Set_Data_7         => data_7_bits,
      Set_Parity_Bit     => parity_en,
      Set_Parity_Odd     => parity_odd,
      Set_Stop_Bit       => stop_2,
      Set_Send_MSB_First => msb_first,

      Data_In    => txdata,
      Data_In_W  => txdata_w,
      Data_W_En  => txready_i,
      Data_empty => txempty,
      TxEnd      => txdone,

      TX => tx
   );

end Structure;
