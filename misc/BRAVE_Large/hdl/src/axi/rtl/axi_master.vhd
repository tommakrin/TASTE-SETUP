-------------------------------------------------------
--! @file       axi_master.vhd
--! @brief      AXI master bootrom loader
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
--!                         * add memory intialization through python
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
--! This module automatically writes data to the TCM.   
--! It uses R5 AXI peripheral port to do so
--! Just after reset, the master take the number of instructions NBR_INSTR and write them  to the TCM
--! The instructions are take from a memory mem_axi_master of which the content is initialized with 
--! a mem file (right now `Loop-zero.mem` ) through Nxmap python command `addMemoryInitialization` from `./subscripts/project_parameters.py`.
--! The content of the memory is described in `Loop-zero.mem.txt`:
--!  @include{lineo} Loop-zero.mem.txt .
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity AXI_MASTER is
generic( 
    ADDR_LENGTH  : integer ;--:= 32;
    DATA_LENGTH  : integer ;--:= 64;
    NBR_INSTR    : integer --:= 30-- THE NBR of INSTRUCTIONS in the file boot.txt (MUST be EVEN)
);
port(
    CLK   : in std_logic;
    RST_N   : in std_logic;
    CPUHALT : out std_logic;
    -- Write Address Channel
    M_AWADDRS0    : out std_logic_vector(ADDR_LENGTH - 1 downto 0);  
    M_AWBURSTS0   : out std_logic_vector(1 downto 0);   
    M_AWCACHES0   : out std_logic_vector(3 downto 0);   
    M_AWIDS0      : out std_logic_vector(7 downto 0);   
    M_AWLENS0     : out std_logic_vector(3 downto 0);   
    M_AWLOCKS0    : out std_logic_vector(1 downto 0);   
    M_AWPROTS0    : out std_logic_vector(2 downto 0);   
    M_AWREADYS0   : in std_logic;          
    M_AWSIZES0    : out std_logic_vector(2 downto 0);   
    M_AWVALIDS0   : out std_logic;                        
    -- Write Data Channel
    M_WDATAS0     : out std_logic_vector(DATA_LENGTH - 1 downto 0);  
    M_WIDS0       : out std_logic_vector(7 downto 0);    
    M_WLASTS0     : out std_logic;                         
    M_WREADYS0    : in std_logic;           
    M_WSTRBS0     : out std_logic_vector(7 downto 0);   
    M_WVALIDS0    : out std_logic;                     
    -- Write response channel
    M_BIDS0       : in std_logic_vector(7 downto 0);  
    M_BREADYS0    : out std_logic;                     
    M_BRESPS0     : in std_logic_vector(1 downto 0);  
    M_BVALIDS0    : in std_logic;           
    -- Read Address Channel
    M_ARADDRS0    : out std_logic_vector(ADDR_LENGTH - 1 downto 0);  
    M_ARBURSTS0   : out std_logic_vector(1 downto 0);    
    M_ARCACHES0   : out std_logic_vector(3 downto 0);    
    M_ARIDS0      : out std_logic_vector(7 downto 0);    
    M_ARLENS0     : out std_logic_vector(3 downto 0);    
    M_ARLOCKS0    : out std_logic_vector(1 downto 0);    
    M_ARPROTS0    : out std_logic_vector(2 downto 0);    
    M_ARREADYS0   : in std_logic;           
    M_ARSIZES0    : out std_logic_vector(2 downto 0);   
    M_ARVALIDS0   : out std_logic;                        
    -- Read Data Channel
    M_RDATAS0     : in std_logic_vector(DATA_LENGTH - 1 downto 0); 
    M_RIDS0       : in std_logic_vector(7 downto 0);  
    M_RLASTS0     : in std_logic;           
    M_RREADYS0    : out std_logic;           
    M_RRESPS0     : in std_logic_vector(1 downto 0);  
    M_RVALIDS0    : in std_logic
);

end AXI_MASTER;

architecture arch of AXI_MASTER is
    ---------- FSM to control the AXI_MASTER -----------------
    type etat is (INIT,WRITE_SLAVE,WAIT_RESP,GET_RESP);
    signal ep,ef : etat; 
    signal end_write : std_logic:='0';
    signal s_CPUHALT : std_logic:='0';
    signal cpt       : integer:=0;
    signal EN_cpt    : std_logic;
    signal dis_adr   : std_logic;
    signal dis_data   : std_logic;
    signal en_data   : std_logic;
    ---------- RAM -----------------
    --- this structure is not working neither by python intialization nor by vhdl init
    type MEM_TYPE is array (0 to 1023) of std_logic_vector(DATA_LENGTH - 1 downto 0); -- 64K
    signal mem_axi_master : MEM_TYPE;

   -- example of vhdl instanciation (otherwise done by python)
   -- signal mem_axi_master : MEM_TYPE:=(0=>x"eafffffeeafffffe",
   --                                    1=>x"deadbeefdeafbeef",
   --                                    2=>x"cafedecacafedeca",
   --                                   3=>x"012345678abcdef0",
   --                                   others=>x"0000000000000000");
    attribute NX_USE : string;
    attribute NX_USE of mem_axi_master : signal is "RAM";


    ---------- AXI MASTER Signals ------------------
    signal s_M_AWADDRS0  : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    signal s_M_AWVALIDS0 : std_logic; 
    signal s_M_WDATAS0   : std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal s_M_WLASTS0   : std_logic;
    signal s_M_WVALIDS0  : std_logic; 
    signal s_M_BREADYS0  : std_logic;
    signal s_M_ARADDRS0  : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    signal s_M_ARVALIDS0 : std_logic; 
    signal s_M_RREADYS0  : std_logic; 
    signal wnext         : std_logic;

    signal datamem2send   : std_logic_vector(DATA_LENGTH - 1 downto 0); 
begin
   s_M_WLASTS0<='1'; ---no burst only 1 write

   process(CLK,RST_N)  -- Asserting AWVALID
   begin  
      if (RST_N = '0') then                                   
         s_M_AWVALIDS0 <= '0';                                                              
      elsif (rising_edge (CLK)) then
         if (s_M_AWVALIDS0 = '0' and EN_cpt = '1') then 
            s_M_AWVALIDS0 <= '1';                                                         
         elsif (M_AWREADYS0 = '1' and s_M_AWVALIDS0 = '1') then         
            s_M_AWVALIDS0 <= '0';                                                                          
         end if;                                                        
      end if;                                                                                                                      
   end process;

   wnext <= M_WREADYS0 and s_M_WVALIDS0; -- condition of write  
    
   process(CLK,RST_N)  -- Asserting WVALID                                           
   begin  
      if (RST_N = '0') then                                   
         s_M_WVALIDS0 <= '0';                                                              
      elsif (rising_edge (CLK)) then
         if (s_M_WVALIDS0 = '0' and EN_cpt = '1') then                                      
            s_M_WVALIDS0 <= '1';                                                                           
         elsif (wnext = '1' ) then                                
            s_M_WVALIDS0 <= '0';
         end if;                                                                       
      end if;                                                                         
   end process;  

   process(CLK,RST_N)  -- Asserting BREADY                                           
   begin  
      if (RST_N = '0') then                                   
         s_M_BREADYS0 <= '0';                                                              
      elsif (rising_edge (CLK)) then
         if (M_BVALIDS0 = '1' and s_M_BREADYS0 = '0') then               
            s_M_BREADYS0 <= '1';                                            
         -- deassert after one clock cycle                             
         elsif (s_M_BREADYS0 = '1') then                                   
            s_M_BREADYS0 <= '0';                                            
         end if;                                                                                                                   
      end if;                                                             
   end process;
   
   datamem2send   <= mem_axi_master(cpt); --read rom

   process(CLK,RST_N) -- write ADDR and DATA
   begin
      if(RST_N = '0') then
         cpt <= 0;
         end_write <= '0';
         s_CPUHALT <= '0';
         s_M_AWADDRS0  <= (others => '1');
         s_M_WDATAS0   <= (others => '0');
      elsif rising_edge(CLK) then
         
         if(cpt = (NBR_INSTR/2)) then  -- cpt_MAX = (last boot.txt nbr line)/2  =  
            end_write <= '1'; 
            cpt <= 0;
         elsif (EN_cpt = '1') then
            s_M_AWADDRS0  <= s_M_AWADDRS0 + 1;
            s_M_WDATAS0   <= datamem2send;
            --if cpt=0 then
               --test sequence for branch 0  
            --   s_M_WDATAS0   <= x"eafffffeeafffffe";
            --else
               --test sequence for addressing
            --   s_M_WDATAS0   <= s_M_AWADDRS0&s_M_AWADDRS0; 
            --end if;      
            cpt <= cpt + 1;   
         end if;

         if (end_write = '1' and s_M_BREADYS0 = '1') then               
            s_CPUHALT <= '1';               
         end if;     
      end if;
   end process;

   process(CLK,RST_N)
   begin
      if(RST_N = '0') then
         ep <= INIT;
      elsif rising_edge(CLK) then
         ep <= ef;
      end if;
   end process;

   
   process(ep, end_write, M_BVALIDS0)
   begin
      EN_cpt<='0';
      case ep is
         when INIT =>
            if(end_write = '1') then 
               ef <= INIT;
            else
               ef <= WRITE_SLAVE;
            end if;

         when WRITE_SLAVE =>
            ef <= WAIT_RESP;
            EN_cpt <= '1';

         when WAIT_RESP =>
            if(M_BVALIDS0 = '1') then
               ef <= GET_RESP;
            else
               ef <= WAIT_RESP;
            end if;

         when GET_RESP =>
            if(end_write = '1') then
               ef <= INIT;
            else
               ef <= WRITE_SLAVE;
            end if;
         when others =>
            ef <= INIT;                                            
      end case;
   end process;

   CPUHALT <= s_CPUHALT;

   -- d'ou sort ce bit 24 a 1 ?
   -- ou sont les chip-select AWCSELS/ARCSELS ?
   M_AWADDRS0  <= (s_M_AWADDRS0(28 downto 0) & "000") or "00000001000000000000000000000000";    -- "000" : for multiplication by 8 
   M_AWVALIDS0 <= s_M_AWVALIDS0;

   M_AWBURSTS0 <= "01"; --INCR burst
   M_AWCACHES0 <= (others => '0');
   M_AWIDS0    <= (others => '0');
   M_AWLENS0   <= (others => '0');
   M_AWLOCKS0  <= (others => '0');
   M_AWPROTS0  <= (others => '0');
	
   M_AWSIZES0	<= "011"; -- 2^SIZE bytes
    
   M_WIDS0     <= (others => '0'); 
   M_WSTRBS0   <= (others => '1');
   M_WDATAS0   <= s_M_WDATAS0 ;
   M_WLASTS0   <= s_M_WLASTS0 ;
   M_WVALIDS0  <= s_M_WVALIDS0;

   M_BREADYS0  <= s_M_BREADYS0;

   M_ARADDRS0  <= (others => '0');
   M_ARVALIDS0 <= '0';
   M_ARBURSTS0 <= "00";
   M_ARCACHES0 <= (others => '0');
   M_ARIDS0    <= (others => '0');
   M_ARLENS0   <= (others => '0');
   M_ARLOCKS0  <= (others => '0');
   M_ARPROTS0  <= (others => '0');
   M_ARSIZES0  <= "000";
   M_RREADYS0  <= '0';


end arch;    
