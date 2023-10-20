library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
  port
  (
    -- Write Port 1 prioritaire
    wdata1 : in std_logic_vector(31 downto 0);
    wadr1  : in std_logic_vector(3 downto 0);
    wen1   : in std_logic;

    -- Write Port 2 non prioritaire
    wdata2 : in std_logic_vector(31 downto 0);
    wadr2  : in std_logic_vector(3 downto 0);
    wen2   : in std_logic;

    -- Write CSPR Port
    wcry    : in std_logic;
    wzero   : in std_logic;
    wneg    : in std_logic;
    wovr    : in std_logic;
    cspr_wb : in std_logic;

    -- Read Port 1 32 bits
    reg_rd1 : out std_logic_vector(31 downto 0);
    radr1   : in std_logic_vector(3 downto 0);
    reg_v1  : out std_logic;

    -- Read Port 2 32 bits
    reg_rd2 : out std_logic_vector(31 downto 0);
    radr2   : in std_logic_vector(3 downto 0);
    reg_v2  : out std_logic;

    -- Read Port 3 32 bits
    reg_rd3 : out std_logic_vector(31 downto 0);
    radr3   : in std_logic_vector(3 downto 0);
    reg_v3  : out std_logic;

    -- read CSPR Port
    reg_cry  : out std_logic;
    reg_zero : out std_logic;
    reg_neg  : out std_logic;
    reg_cznv : out std_logic;
    reg_ovr  : out std_logic;
    reg_vv   : out std_logic;

    -- Invalidate Port 
    inval_adr1 : in std_logic_vector(3 downto 0);
    inval1     : in std_logic;

    inval_adr2 : in std_logic_vector(3 downto 0);
    inval2     : in std_logic;

    inval_czn : in std_logic;
    inval_ovr : in std_logic;

    -- PC
    reg_pc  : out std_logic_vector(31 downto 0);
    reg_pcv : out std_logic;
    inc_pc  : in std_logic;

    -- global interface
    ck      : in std_logic;
    reset_n : in std_logic;
    vdd     : in bit;
    vss     : in bit);
end Reg;

architecture behavioral_reg of Reg is
end behavioral_reg;