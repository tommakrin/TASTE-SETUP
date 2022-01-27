--------------------------------------------------------------------------------
-- Company: GMV Aerospace & Defence S.A.U.
-- Copyright European Space Agency, 2019-2020
--------------------------------------------------------------------------------
--   __ _ _ __ _____   __
--  / _` | '_ ` _ \ \ / /   Company:	GMV Aerospace & Defence S.A.U.
-- | (_| | | | | | \ V /    Author: 	Ruben Domingo Torrijos (rdto@gmv.com)
--  \__, |_| |_| |_|\_/     Module: 	TASTE
--   __/ |               
--  |___/              
-- 
-- Create Date: 18/09/2019
-- Design Name: TASTE
-- Module Name: TASTE
-- Project Name: Cora-mbad-4zynq
-- Target Devices: XC7Z045
-- Tool versions: Vivado 2019
-- Description: Interface between Zynq proccesor and Bambu IP through AXI_LITE
--
-- Dependencies:
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TASTE is
  port (
    ---------------------------------------------------
    --			  AXI4 LITE CORE CONTROLLER 		 --
    ---------------------------------------------------
    -- Clock and Reset
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    -- Write Address Channel
    S_AXI_AWADDR : in std_logic_vector(31 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;
    -- Write Data Channel
    S_AXI_WDATA : in std_logic_vector(31 downto 0);
    S_AXI_WSTRB : in std_logic_vector(3 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_WREADY : out std_logic;
    -- Read Address Channel
    S_AXI_ARADDR : in std_logic_vector(31 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;
    -- Read Data Channel
    S_AXI_RDATA : out std_logic_vector(31 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in std_logic;
    -- Write Response Channel
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in std_logic
  );
end TASTE;

architecture rtl of TASTE is

  ---------------------------------------------------
  --			  COMPONENT DECLARATION			 	 --
  ---------------------------------------------------	
  -- Circuits for the existing PIs
  component adder_bambu is
    port (
      inp : in std_logic_vector(63 downto 0); -- ASSERT uses 64 bit INTEGERs (optimal would be 62 bits)
      outp : out std_logic_vector(63 downto 0); -- ASSERT uses 64 bit INTEGERs (optimal would be 62 bits)
      start_adder : in std_logic;
      finish_adder : out std_logic;
      clock_adder : in std_logic;
      reset_adder : in std_logic
    );
  end component;

  ---------------------------------------------------
  --			  CONSTANTS			 	 	 		 --
  ---------------------------------------------------

  constant OKAY : std_logic_vector(1 downto 0) := "00";
  constant EXOKAY : std_logic_vector(1 downto 0) := "01";
  constant SLVERR : std_logic_vector(1 downto 0) := "10";
  constant DECERR : std_logic_vector(1 downto 0) := "11";
  ----------------------------------------------------
  --			  	TYPE DEFINITION			 	 	  --
  ----------------------------------------------------

  ------------------------------
  --	AXI LITE SLAVE CTRL		--
  ------------------------------
  -- AXI4 LITE SLAVE CONTROLLER FSM --
  type AXI_SLAVE_CTRL_states is(idle, reading, r_complete, writing, wait_resp);

  -- AXI4 combinational outputs record --
  type AXI_SLAVE_CTRL_comb_out is record

    awready : std_logic;
    wready : std_logic;
    arready : std_logic;
    rdata : std_logic_vector(31 downto 0);
    rresp : std_logic_vector(1 downto 0);
    rvalid : std_logic;
    bvalid : std_logic;

  end record;

  -- AXI4 internal signals record --
  type AXI_SLAVE_CTRL_inter is record

    current_state : AXI_SLAVE_CTRL_states;
    r_local_address : integer;
    bresp : std_logic_vector(1 downto 0);
    --Registers for I/O
    adder_inp : std_logic_vector(63 downto 0); -- ASSERT uses 64 bit INTEGERs (optimal would be 62 bits)

    adder_StartCalculationsInternal : std_logic;
    adder_StartCalculationsInternalOld : std_logic;

    done : std_logic;
  end record;

  constant INIT_AXI_SLAVE_CTRL_comb_out : AXI_SLAVE_CTRL_comb_out := (awready => '0',
                                                                      wready => '0',
                                                                      arready => '0',
                                                                      rdata => (others => '0'),
                                                                      rresp => OKAY,
                                                                      rvalid => '0',
                                                                      bvalid => '0'
                                                                      );

  constant INIT_AXI_SLAVE_CTRL_inter : AXI_SLAVE_CTRL_inter := (current_state => idle,
                                                                r_local_address => 0,
                                                                bresp => OKAY,
                                                                --Registers for I/O
                                                                adder_inp => (others => '0'),

                                                                adder_StartCalculationsInternal => '0',
                                                                adder_StartCalculationsInternalOld => '0',

                                                                done => '0'
                                                                );
  ------------------------------
  --	SIGNAL DECLARATION		--
  ------------------------------	
  -- Registers for I/O
  signal adder_inp : std_logic_vector(63 downto 0); -- ASSERT uses 64 bit INTEGERs (optimal would be 62 bits)
  signal adder_outp : std_logic_vector(63 downto 0); -- ASSERT uses 64 bit INTEGERs (optimal would be 62 bits)

  signal adder_start : std_logic;
  signal adder_done : std_logic;
  -- AXI LITE SLAVE CTRL Signals --	
  signal AXI_SLAVE_CTRL_r : AXI_SLAVE_CTRL_inter;
  signal AXI_SLAVE_CTRL_rin : AXI_SLAVE_CTRL_inter;
  signal AXI_SLAVE_CTRL_r_comb_out : AXI_SLAVE_CTRL_comb_out;
  signal AXI_SLAVE_CTRL_rin_comb_out : AXI_SLAVE_CTRL_comb_out;

begin

  ---------------------------------------------------
  --				COMPONENT INSTANTITATION		 --
  ---------------------------------------------------
  -- Connections to the VHDL circuits

  Interface_adder : adder_bambu
  port map(
    inp => adder_inp,
    outp => adder_outp,
    start_adder => adder_start,
    finish_adder => adder_done,
    clock_adder => S_AXI_ACLK,
    reset_adder => S_AXI_ARESETN
  );
  ---------------------------------------------------
  --				PROCESS INSTANTIATION		     --
  ---------------------------------------------------		

  ---------------------------------------------------
  --				AXI LITE SLAVE CTRL			 	 --
  ---------------------------------------------------	
  -- Sequential process --
  seq_axi_slave : process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      AXI_SLAVE_CTRL_r <= AXI_SLAVE_CTRL_rin;
      AXI_SLAVE_CTRL_r_comb_out <= AXI_SLAVE_CTRL_rin_comb_out;
    end if;
  end process;

  -- Combinational process --	
  comb_axi_slave : process (-- internal signals --
                            AXI_SLAVE_CTRL_r, AXI_SLAVE_CTRL_r_comb_out,
                            -- AXI inputs --
                            S_AXI_ARESETN, S_AXI_AWADDR, S_AXI_AWVALID, S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WVALID, S_AXI_ARADDR, S_AXI_ARVALID, S_AXI_RREADY, S_AXI_BREADY,
                            -- Bambu signals --
                            adder_outp,
                            adder_done,
                            adder_start
                            )

    variable v : AXI_SLAVE_CTRL_inter;
    variable v_comb_out : AXI_SLAVE_CTRL_comb_out;
    variable comb_S_AXI_AWVALID_S_AXI_ARVALID : std_logic_vector(1 downto 0);
    variable w_local_address : integer;

  begin

    -----------------------------------------------------------------
    --				   DEFAULT VARIABLES ASIGNATION		           --
    -----------------------------------------------------------------
    v := AXI_SLAVE_CTRL_r;
    -----------------------------------------------------------------
    --	 	DEFAULT COMBINATIONAL OUTPUT VARIABLES ASIGNATION      --
    -----------------------------------------------------------------
    v_comb_out := INIT_AXI_SLAVE_CTRL_comb_out;
    if adder_start = '1' then
      v.done := '0';
    end if;
    if adder_done = '1' then
      v.done := '1';
    end if;

    -----------------------------------------------------------------
    --	 			DEFAULT INTERNAL VARIABLE ASIGNATION      	   --
    -----------------------------------------------------------------		
    w_local_address := to_integer(unsigned(S_AXI_AWADDR(15 downto 0)));
    comb_S_AXI_AWVALID_S_AXI_ARVALID := S_AXI_AWVALID & S_AXI_ARVALID;
    -- Update start-stop pulses
    v.adder_StartCalculationsInternalOld := AXI_SLAVE_CTRL_r.adder_StartCalculationsInternal;

    -----------------------------------------------------------------
    --	 					 AXI LITE CTRL FSM      	   		   --
    -----------------------------------------------------------------		
    case AXI_SLAVE_CTRL_r.current_state is
      when idle =>
        v.bresp := OKAY;
        case comb_S_AXI_AWVALID_S_AXI_ARVALID is
          when "01" =>
            v.current_state := reading;
          when "11" =>
            v.current_state := reading;
          when "10" =>
            v.current_state := writing;
          when others =>
            v.current_state := idle;
        end case;

      when writing =>
        v_comb_out.awready := S_AXI_AWVALID;
        v_comb_out.wready := S_AXI_WVALID;
        v.bresp := AXI_SLAVE_CTRL_r.bresp;
        if S_AXI_WVALID = '1' then
          v.current_state := wait_resp;
          case w_local_address is
            when (768) => v.adder_StartCalculationsInternal := AXI_SLAVE_CTRL_r.adder_StartCalculationsInternal xor '1';
            when (772) => v.adder_inp(31 downto 0) := S_AXI_WDATA;
            when (776) => v.adder_inp(63 downto 32) := S_AXI_WDATA;

            when others => null;
          end case;
        end if;

      when wait_resp =>
        v_comb_out.awready := S_AXI_AWVALID;
        v_comb_out.wready := S_AXI_WVALID;
        v.bresp := AXI_SLAVE_CTRL_r.bresp;
        v_comb_out.bvalid := S_AXI_BREADY;
        if S_AXI_AWVALID = '0' then
          v.current_state := idle;
        else
          if S_AXI_WVALID = '1' then
            case w_local_address is
              when (768) => v.adder_StartCalculationsInternal := AXI_SLAVE_CTRL_r.adder_StartCalculationsInternal xor '1';
              when (772) => v.adder_inp(31 downto 0) := S_AXI_WDATA;
              when (776) => v.adder_inp(63 downto 32) := S_AXI_WDATA;

              when others => null;
            end case;
          else
            v.current_state := writing;
          end if;
        end if;
      -- Reading state  
      when reading =>
        v_comb_out.arready := S_AXI_ARVALID;
        v.bresp := OKAY;
        v.r_local_address := to_integer(unsigned(S_AXI_ARADDR(15 downto 0)));
        v.current_state := r_complete;
      -- Reading complete  
      when r_complete =>
        v_comb_out.arready := S_AXI_ARVALID;
        v_comb_out.rvalid := '1';
        v.bresp := OKAY;
        if S_AXI_RREADY = '1' then
          if S_AXI_ARVALID = '0' then
            v.current_state := idle;
          else
            v.r_local_address := to_integer(unsigned(S_AXI_ARADDR(15 downto 0)));
          end if;
        end if;
        case AXI_SLAVE_CTRL_r.r_local_address is
            -- result calculated flag
          when (768) => v_comb_out.rdata(31 downto 0) := X"000000" & "0000000" & AXI_SLAVE_CTRL_r.done;
          when (780) => v_comb_out.rdata(31 downto 0) := adder_outp(31 downto 0);
          when (784) => v_comb_out.rdata(31 downto 0) := adder_outp(63 downto 32);

          when others => v_comb_out.rdata(31 downto 0) := (others => '0');
        end case;
    end case;
    ---------------------------------------------------
    --				  RESET ASIGNATION		 	     --
    ---------------------------------------------------		
    if S_AXI_ARESETN = '0' then
      v := INIT_AXI_SLAVE_CTRL_inter;
      v_comb_out := INIT_AXI_SLAVE_CTRL_comb_out;
    end if;
    ---------------------------------------------------
    --				SIGNAL ASIGNATION			     --
    ---------------------------------------------------
    AXI_SLAVE_CTRL_rin <= v;
    AXI_SLAVE_CTRL_rin_comb_out <= v_comb_out;

  end process;

  ----------------------------------------------------------
  --			          OUTPUTS	 	 	    		 	--
  ----------------------------------------------------------
  adder_inp <= AXI_SLAVE_CTRL_r.adder_inp;
  adder_start <= AXI_SLAVE_CTRL_r.adder_StartCalculationsInternal xor AXI_SLAVE_CTRL_r.adder_StartCalculationsInternalOld;
  ---------------------------------------------------
  --				AXI LITE SLAVE CTRL			 	 --
  ---------------------------------------------------		
  S_AXI_AWREADY <= AXI_SLAVE_CTRL_rin_comb_out.awready;
  S_AXI_WREADY <= AXI_SLAVE_CTRL_rin_comb_out.wready;
  S_AXI_ARREADY <= AXI_SLAVE_CTRL_rin_comb_out.arready;
  S_AXI_RDATA <= AXI_SLAVE_CTRL_rin_comb_out.rdata;
  S_AXI_RRESP <= AXI_SLAVE_CTRL_rin_comb_out.rresp;
  S_AXI_RVALID <= AXI_SLAVE_CTRL_rin_comb_out.rvalid;
  S_AXI_BRESP <= AXI_SLAVE_CTRL_rin.bresp;
  S_AXI_BVALID <= AXI_SLAVE_CTRL_rin_comb_out.bvalid;
end rtl;