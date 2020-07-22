PL/SQL Developer Test script 3.0
883
-- Created on 30/03/2020 by F0030794 
/* Rentabiliza aplicacoes programada */
  
declare 
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_tem_critica boolean := false;
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0042800-rentabiliza';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_nmarqimp5       VARCHAR2(100)  := 'rollback.txt';
  vr_cdhistor_irrf   craphis.cdhistor%TYPE := 2744; -- DB IRRF
  vr_cdhistor_rgt    craphis.cdhistor%TYPE := 2742; -- RESG.APL.PROG
  vr_vllanmto_irrf   craplac.vllanmto%TYPE;
  vr_vllanmto_rgt    craplac.vllanmto%TYPE;
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  vr_ind_arquiv5     utl_file.file_type;

  
  vr_vlaplica         craprac.vlaplica%TYPE;
  vr_vlaplica_parcial craprac.vlaplica%TYPE;
  vr_dtmvtolt         craprac.dtmvtolt%TYPE;

  TYPE typ_tab_craptxi IS
    TABLE OF number(18,8)
    INDEX BY VARCHAR2(8); -- dtiniper(8)

  vr_tab_craptxi typ_tab_craptxi;
  vr_idx_craptxi VARCHAR(008);
  vr_txperiod    NUMBER(20,8);
  vr_vlsldtot    NUMBER(20,8) := 0;
  vr_vlrendim    NUMBER(20,8) := 0; -- Valor do rendimento
  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
  
  -- variaveis para inclusao da aplicacao
  vr_nraplica         craprac.nraplica%TYPE;
  vr_tab_care         APLI0005.typ_tab_care;
  vr_vl_para_creditar craprac.vlaplica%TYPE;
  
  TYPE typ_tab_valores IS
  RECORD(valor number(18,8)
        ,qtde  pls_integer
        ,craplot_rowid rowid);
  
  TYPE typ_tab_craplotes IS
  TABLE OF typ_tab_valores
  INDEX BY VARCHAR2(2); -- cdcooper(2)
  
  vr_soma_creditos    typ_tab_craplotes;
  
  vr_craprac_rowid ROWID;
  vr_craplac_rowid ROWID;
  vr_craplot_rowid ROWID;

  cursor cr_aplica IS
select 1 cdcooper, 560626 nrdconta, 13 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 849936 nrdconta, 31 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 898260 nrdconta, 23 nraplica, to_date('22/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 904821 nrdconta, 8 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 934925 nrdconta, 8 nraplica, to_date('01/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1657216 nrdconta, 56 nraplica, to_date('05/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1832573 nrdconta, 34 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1875167 nrdconta, 60 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1889516 nrdconta, 17 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1911139 nrdconta, 30 nraplica, to_date('20/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1921614 nrdconta, 48 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1977075 nrdconta, 21 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 1993461 nrdconta, 87 nraplica, to_date('05/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2020815 nrdconta, 17 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2021390 nrdconta, 80 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2021528 nrdconta, 14 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2028824 nrdconta, 19 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2043270 nrdconta, 80 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2084856 nrdconta, 94 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2111047 nrdconta, 25 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2122910 nrdconta, 17 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2206404 nrdconta, 17 nraplica, to_date('14/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2213117 nrdconta, 41 nraplica, to_date('03/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2223422 nrdconta, 5 nraplica, to_date('05/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2223848 nrdconta, 16 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2223953 nrdconta, 32 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2226901 nrdconta, 40 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2285541 nrdconta, 20 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2304090 nrdconta, 17 nraplica, to_date('05/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2357003 nrdconta, 20 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2370069 nrdconta, 15 nraplica, to_date('09/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2388766 nrdconta, 25 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2463962 nrdconta, 29 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2482185 nrdconta, 10 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2485079 nrdconta, 20 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2488051 nrdconta, 2 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2504030 nrdconta, 12 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2514354 nrdconta, 21 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2514516 nrdconta, 37 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2518279 nrdconta, 63 nraplica, to_date('02/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2536633 nrdconta, 117 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2536650 nrdconta, 26 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2542315 nrdconta, 62 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2550040 nrdconta, 2 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2558866 nrdconta, 38 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2559170 nrdconta, 24 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2559196 nrdconta, 7 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2559331 nrdconta, 19 nraplica, to_date('17/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2561514 nrdconta, 27 nraplica, to_date('12/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2567733 nrdconta, 27 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2568799 nrdconta, 11 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2568870 nrdconta, 17 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2569043 nrdconta, 25 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2570149 nrdconta, 23 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2576660 nrdconta, 18 nraplica, to_date('07/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2576805 nrdconta, 46 nraplica, to_date('20/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2577160 nrdconta, 67 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2577500 nrdconta, 35 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2578085 nrdconta, 39 nraplica, to_date('07/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2581345 nrdconta, 7 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2581639 nrdconta, 17 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2581671 nrdconta, 52 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2581922 nrdconta, 34 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2581949 nrdconta, 2 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2582350 nrdconta, 19 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2583933 nrdconta, 80 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2584000 nrdconta, 54 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2585812 nrdconta, 33 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586037 nrdconta, 2 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586134 nrdconta, 12 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586266 nrdconta, 2 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586657 nrdconta, 2 nraplica, to_date('12/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586673 nrdconta, 7 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586940 nrdconta, 18 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586967 nrdconta, 23 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2586975 nrdconta, 2 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2589656 nrdconta, 15 nraplica, to_date('20/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2589869 nrdconta, 17 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2590018 nrdconta, 36 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2590670 nrdconta, 83 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2590727 nrdconta, 72 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2590999 nrdconta, 88 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2600153 nrdconta, 58 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2600498 nrdconta, 17 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2600749 nrdconta, 29 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2600854 nrdconta, 24 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2604310 nrdconta, 15 nraplica, to_date('12/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2604361 nrdconta, 22 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2605171 nrdconta, 18 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2608561 nrdconta, 36 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2612860 nrdconta, 19 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2613026 nrdconta, 15 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2613050 nrdconta, 22 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2613093 nrdconta, 15 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2613352 nrdconta, 4 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2614707 nrdconta, 50 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2620227 nrdconta, 14 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2620308 nrdconta, 13 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2620367 nrdconta, 30 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2622394 nrdconta, 19 nraplica, to_date('05/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2623013 nrdconta, 18 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2623455 nrdconta, 30 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2624770 nrdconta, 18 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2625342 nrdconta, 17 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2625881 nrdconta, 30 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2625946 nrdconta, 11 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2626217 nrdconta, 24 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2626519 nrdconta, 11 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2626845 nrdconta, 28 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2627140 nrdconta, 32 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2634430 nrdconta, 54 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2636859 nrdconta, 28 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2638614 nrdconta, 33 nraplica, to_date('17/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2644517 nrdconta, 25 nraplica, to_date('17/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2648059 nrdconta, 98 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2651025 nrdconta, 37 nraplica, to_date('12/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2652650 nrdconta, 45 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2656280 nrdconta, 43 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2660199 nrdconta, 37 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2670747 nrdconta, 20 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2712440 nrdconta, 77 nraplica, to_date('01/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2765519 nrdconta, 11 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2782383 nrdconta, 178 nraplica, to_date('05/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2800390 nrdconta, 15 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2815150 nrdconta, 107 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2835908 nrdconta, 41 nraplica, to_date('03/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2884194 nrdconta, 29 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2908794 nrdconta, 24 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2914255 nrdconta, 14 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2914310 nrdconta, 23 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2915073 nrdconta, 13 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2915146 nrdconta, 9 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2915162 nrdconta, 82 nraplica, to_date('27/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2938545 nrdconta, 6 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2968304 nrdconta, 30 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2971119 nrdconta, 4 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2972565 nrdconta, 45 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2978857 nrdconta, 21 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2982404 nrdconta, 28 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2988992 nrdconta, 4 nraplica, to_date('04/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2998190 nrdconta, 42 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2998580 nrdconta, 17 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2999005 nrdconta, 38 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 2999030 nrdconta, 159 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3020452 nrdconta, 30 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3030326 nrdconta, 13 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3051803 nrdconta, 33 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3052028 nrdconta, 10 nraplica, to_date('05/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3052079 nrdconta, 26 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3799921 nrdconta, 59 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3823652 nrdconta, 3 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3823970 nrdconta, 13 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3824314 nrdconta, 25 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3852512 nrdconta, 5 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3879330 nrdconta, 20 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3879593 nrdconta, 23 nraplica, to_date('12/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3879690 nrdconta, 5 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3880338 nrdconta, 7 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3880630 nrdconta, 26 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3880680 nrdconta, 33 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 3885720 nrdconta, 19 nraplica, to_date('02/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 4393643 nrdconta, 15 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 4970926 nrdconta, 11 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 6253032 nrdconta, 21 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 6348564 nrdconta, 11 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 6409750 nrdconta, 21 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 6410154 nrdconta, 21 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 80188850 nrdconta, 15 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 80246850 nrdconta, 12 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 90050150 nrdconta, 28 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 90051181 nrdconta, 27 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 90165063 nrdconta, 16 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 90169620 nrdconta, 16 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 1 cdcooper, 90260392 nrdconta, 19 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 8 cdcooper, 6190 nrdconta, 23 nraplica, to_date('29/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 8 cdcooper, 27308 nrdconta, 18 nraplica, to_date('29/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 8 cdcooper, 27324 nrdconta, 14 nraplica, to_date('29/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 8 cdcooper, 27332 nrdconta, 15 nraplica, to_date('29/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 11 cdcooper, 361 nrdconta, 5 nraplica, to_date('15/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 11 cdcooper, 11983 nrdconta, 19 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 11 cdcooper, 81485 nrdconta, 14 nraplica, to_date('15/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 14 cdcooper, 13161 nrdconta, 15 nraplica, to_date('16/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 14 cdcooper, 18724 nrdconta, 10 nraplica, to_date('16/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 525197 nrdconta, 25 nraplica, to_date('10/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 529370 nrdconta, 28 nraplica, to_date('20/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 618780 nrdconta, 20 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 1981030 nrdconta, 17 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2167107 nrdconta, 26 nraplica, to_date('20/02/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2321386 nrdconta, 22 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2321564 nrdconta, 15 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2376717 nrdconta, 24 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2407701 nrdconta, 24 nraplica, to_date('10/01/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2460319 nrdconta, 2 nraplica, to_date('15/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2624273 nrdconta, 27 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual union all 
select 16 cdcooper, 2649047 nrdconta, 13 nraplica, to_date('10/03/2020','dd/mm/rrrr') dtvencto from dual 
;
  rw_aplica cr_aplica%ROWTYPE;

  cursor cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                   ,pr_nrdconta IN craprac.nrdconta%TYPE
                   ,pr_nraplica IN craprac.nraplica%TYPE) IS
  SELECT rac.*
    FROM craprac rac
   WHERE rac.cdcooper = pr_cdcooper
     AND rac.nrdconta = pr_nrdconta
     AND rac.nraplica = pr_nraplica;
  rw_craprac cr_craprac%ROWTYPE;     

  cursor cr_craptxi IS
  select txi.*
    from craptxi txi
   where txi.cddindex = 1 /* CDI */
     and txi.dtiniper >= '01/01/2020';
  rw_craptxi cr_craptxi%ROWTYPE;

  cursor cr_craplac(pr_cdcooper IN craplac.cdcooper%TYPE
                   ,pr_nrdconta IN craplac.nrdconta%TYPE
                   ,pr_dtmvtolt IN craplac.dtmvtolt%TYPE
                   ,pr_cdhistor IN craplac.cdhistor%TYPE)IS
  select sum(lac.vllanmto) as vllanmto
    from craplac lac
   where lac.cdcooper = pr_cdcooper
     and lac.nrdconta = pr_nrdconta
     and lac.cdhistor = pr_cdhistor
     and lac.dtmvtolt = pr_dtmvtolt;
  rw_craplac cr_craplac%ROWTYPE;

  -- Consulta referente a dados de aplicacoes de produtos antigos
  CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                   ,pr_nrdconta IN craprda.nrdconta%TYPE
                   ,pr_nraplica IN craprda.nraplica%TYPE)IS

    SELECT rda.cdcooper
          ,rda.nrdconta
          ,rda.nraplica
      FROM craprda rda
     WHERE rda.cdcooper = pr_cdcooper
       AND rda.nrdconta = pr_nrdconta
       AND rda.nraplica = pr_nraplica
  UNION ALL
    SELECT rac.cdcooper
          ,rac.nrdconta
          ,rac.nraplica
      FROM craprac rac
     WHERE rac.cdcooper = pr_cdcooper
       AND rac.nrdconta = pr_nrdconta
       AND rac.nraplica = pr_nraplica;
  rw_craprda cr_craprda%ROWTYPE;
  
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.cdcooper
          ,lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,lot.nrseqdig
          ,lot.qtinfoln
          ,lot.qtcompln
          ,lot.vlinfocr
          ,lot.vlcompcr
          ,lot.vlcompdb
          ,lot.vlinfodb
          ,lot.rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = pr_cdagenci
       AND lot.cdbccxlt = pr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;
  
  procedure rollback_script(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5, pr_msg);
  END;
  
  PROCEDURE fecha_arquivos IS
  BEGIN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto;  
  END;
  
  PROCEDURE carrega_craptxi IS    
  BEGIN
    FOR rw_craptxi IN cr_craptxi LOOP
      vr_idx_craptxi := to_char(rw_craptxi.dtiniper,'rrrrmmdd');
      vr_tab_craptxi(vr_idx_craptxi) := rw_craptxi.vlrdtaxa;
    END LOOP;
  END;
  
  PROCEDURE zera_temptable IS
   i PLS_INTEGER := 0;
  BEGIN
    LOOP
      i := i + 1;     
      EXIT WHEN i > 17;
      EXIT WHEN i = 20;
      vr_soma_creditos(i).qtde  := 0;
      vr_soma_creditos(i).valor := 0;
    END LOOP;  
  END;
  
  FUNCTION fn_formata_valor(pr_valor numeric) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(to_char(pr_valor,'99999999999999D99','NLS_NUMERIC_CHARACTERS=''.,'''));
  END;
  
  PROCEDURE pc_backup_lote IS
    vr_idx PLS_INTEGER;
  BEGIN
    vr_idx := vr_soma_creditos.first;    
    WHILE vr_idx IS NOT NULL LOOP
    
      IF vr_soma_creditos(vr_idx).qtde > 0 THEN
        backup('
UPDATE craplot
   SET craplot.qtinfoln = craplot.qtinfoln - '|| vr_soma_creditos(vr_idx).qtde ||',
       craplot.qtcompln = craplot.qtcompln - '|| vr_soma_creditos(vr_idx).qtde ||',
       craplot.vlinfocr = craplot.vlinfocr - '|| fn_formata_valor(vr_soma_creditos(vr_idx).valor) ||',
       craplot.vlcompcr = craplot.vlcompcr - '|| fn_formata_valor(vr_soma_creditos(vr_idx).valor) ||'
 WHERE craplot.rowid = '''|| vr_soma_creditos(vr_idx).craplot_rowid ||''';');
        loga('Cooper '||vr_idx||' -> Registros criados '|| vr_soma_creditos(vr_idx).qtde || ' valor creditado ' || vr_soma_creditos(vr_idx).valor);
      END IF;

      vr_idx := vr_soma_creditos.next(vr_idx);
    END LOOP;      
  END;
  
begin
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;

  loga('Inicio Processo');
  
  carrega_craptxi;
  zera_temptable;
  
  loga('Inicio loop principal');  
   
  FOR rw_aplica IN cr_aplica LOOP
    loga('Verificando aplicacao: Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_aplica.nraplica );
    
    OPEN cr_craprac(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_nraplica => rw_aplica.nraplica);
    FETCH cr_craprac INTO rw_craprac;
    IF cr_craprac%NOTFOUND THEN
      CLOSE cr_craprac;
      falha('ERRO - Aplicacao nao encontrada! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_aplica.nraplica );
      CONTINUE;
    END IF;
    CLOSE cr_craprac;
    
    --Busca o valor de IR retido no vcto do plano
    OPEN cr_craplac(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_dtmvtolt => GENE0005.fn_valida_dia_util(pr_cdcooper => rw_aplica.cdcooper
                                                              ,pr_dtmvtolt => rw_aplica.dtvencto
                                                              ,pr_tipo => 'P'
                                                              ,pr_feriado => true
                                                              ,pr_excultdia => true)
                   ,pr_cdhistor => vr_cdhistor_irrf);
    FETCH cr_craplac INTO vr_vllanmto_irrf;
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;
      falha('ERRO - IR nao encontrado! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Aplica: '|| rw_aplica.nraplica );
      CONTINUE;
    END IF;
    CLOSE cr_craplac;
    vr_vllanmto_irrf := nvl(vr_vllanmto_irrf,0);
    
    --Busca o valor resgatado no vcto do plano para conferencia
    OPEN cr_craplac(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_dtmvtolt => GENE0005.fn_valida_dia_util(pr_cdcooper => rw_aplica.cdcooper
                                                              ,pr_dtmvtolt => rw_aplica.dtvencto
                                                              ,pr_tipo => 'P'
                                                              ,pr_feriado => true
                                                              ,pr_excultdia => true)
                   ,pr_cdhistor => vr_cdhistor_rgt);
    FETCH cr_craplac INTO vr_vllanmto_rgt;
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;
      falha('ERRO - RGT nao encontrado! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Aplica: '|| rw_aplica.nraplica );
      CONTINUE;
    END IF;
    CLOSE cr_craplac;
    
    -- Valor rgtado no dia do vcto deve ser igual ao aplicado
    IF rw_craprac.vlaplica <> vr_vllanmto_rgt THEN
      falha('Valores divergem! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Aplica: '|| rw_aplica.nraplica || ' Valor aplica: '|| rw_craprac.vlaplica || ' Valor vcto: '|| vr_vllanmto_rgt );
      continue;
    END IF;

    vr_vlaplica := rw_craprac.vlaplica;
    vr_dtmvtolt := rw_aplica.dtvencto;    
    vr_vlsldtot := rw_craprac.vlaplica + vr_vllanmto_irrf;
    
  --WHILE vr_dtmvtolt < rw_craprac.dtatlsld LOOP
    WHILE vr_dtmvtolt < rw_craprac.dtmvtolt LOOP
      
      -- se for dia util
      IF vr_dtmvtolt = GENE0005.fn_valida_dia_util(pr_cdcooper => rw_craprac.cdcooper
                                                  ,pr_dtmvtolt => vr_dtmvtolt
                                                  ,pr_tipo => 'P'
                                                  ,pr_feriado => true
                                                  ,pr_excultdia => true) THEN
        
        -- Consulta a taxa do CDI
        vr_idx_craptxi := to_char(vr_dtmvtolt,'rrrrmmdd');
        IF vr_tab_craptxi.exists(vr_idx_craptxi) THEN
          vr_txperiod := vr_tab_craptxi(vr_idx_craptxi);
        ELSE
          vr_dscritic := 'Taxa nao encontrada! Data: '||to_char(vr_dtmvtolt,'dd/mm/rrrr');
          falha(vr_dscritic);
          RAISE vr_excsaida;
        END IF;
        
        -- Taxa do indexador deverá estar descapitalizada ao dia, pois o rendimento é calculado diariamente
        vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);

        vr_txperiod := ROUND(vr_txperiod * (rw_craprac.txaplica / 100), 8);
                
        vr_vlrendim := ROUND(vr_vlsldtot * vr_txperiod, 6);
        vr_vlsldtot := ROUND(vr_vlsldtot + vr_vlrendim, 6);
        
      END IF;
      -- incrementa a data
      vr_dtmvtolt := vr_dtmvtolt + 1;
      
      IF vr_dtmvtolt = rw_craprac.dtmvtolt THEN
        vr_vlaplica_parcial := round(vr_vlsldtot,2);
      END IF;
      
    END LOOP;
    
    vr_vlaplica := round(vr_vlsldtot,2);

    -- valor para creditar = rendimento(vr_vlaplica - rw_craprac.vlaplica) + IR original retido
    vr_vl_para_creditar := (vr_vlaplica - (rw_craprac.vlaplica + vr_vllanmto_irrf)) + vr_vllanmto_irrf;
    
    -- Valida se eh um valor valido
    IF vr_vl_para_creditar <= 0 THEN
      falha('ERRO - rendimento calculado menor ou igual a zero! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' Valor: ' || vr_vl_para_creditar);
      continue;
    END IF;
        
    --sucesso('Rendimento calculado! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Aplica: '|| rw_aplica.nraplica || 
    --' Valor Aplicado: ' || rw_craprac.vlaplica || ' Data Vcto do Plano: '|| to_char(rw_aplica.dtvencto,'dd/mm/rrrr') ||
    --' Rendimento ate (26/03): ' || (vr_vlaplica - rw_craprac.vlaplica) ||
    --        ' IRRF: '|| rw_craplac.vllanmto);

    -- Busca a data da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_aplica.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      falha('ERRO - Data nao encontrada! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp );
      RAISE vr_excsaida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    -- busca dados das carencias disponiveis
    apli0005.pc_obtem_carencias(pr_cdcooper => rw_aplica.cdcooper   -- Codigo da Cooperativa
                               ,pr_cdprodut => 1007                 -- Codigo do Produto 
                               ,pr_cdcritic => vr_cdcritic          -- Codigo da Critica
                               ,pr_dscritic => vr_dscritic          -- Descricao da Critica
                               ,pr_tab_care => vr_tab_care);        -- Tabela com registros de Carencia do produto    
    IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      falha('ERRO - Dados carencia nao encontrados! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp );
      RAISE vr_excsaida;
    END IF;
     
    -- Busca proximo sequencia de NRAPLICA
    vr_nraplica := 0;
    LOOP
      -- Verifica qual o proximo valor da sequence
      vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                ,pr_nmdcampo => 'NRAPLICA'
                                ,pr_dsdchave => rw_aplica.cdcooper || ';' || rw_aplica.nrdconta
                                ,pr_flgdecre => 'N');

      /* Consulta CRAPRDA para nao existir aplicacoes com o mesmo numero mesmo
      sendo produto antigo e novo */

      OPEN cr_craprda(pr_cdcooper => rw_aplica.cdcooper
                     ,pr_nrdconta => rw_aplica.nrdconta
                     ,pr_nraplica => vr_nraplica);

      FETCH cr_craprda INTO rw_craprda;

      IF cr_craprda%FOUND THEN
        CLOSE cr_craprda;
        CONTINUE;
      ELSE
        CLOSE cr_craprda;
        EXIT;
      END IF;

    END LOOP;

    -- Insercao do registro de aplicacao
    BEGIN
      INSERT INTO craprac(
        cdcooper
       ,nrdconta
       ,nraplica
       ,cdprodut
       ,cdnomenc
       ,dtmvtolt
       ,dtvencto
       ,dtatlsld
       ,vlaplica
       ,vlbasapl
       ,vlsldatl
       ,vlslfmes
       ,vlsldacu
       ,qtdiacar
       ,qtdiaprz
       ,qtdiaapl
       ,txaplica
       ,idsaqtot
       ,idblqrgt
       ,idcalorc
       ,nrctrrpp
       ,iddebcti
       ,cdoperad)
      VALUES(
        rw_aplica.cdcooper
       ,rw_aplica.nrdconta
       ,vr_nraplica
       ,1007 -- fixo aplicacao programada - pr_cdprodut
       ,0    -- produto nao tem nomenclatura vr_cdnomenc
       ,rw_crapdat.dtmvtolt
       ,(rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz) -- dtvencto
       ,rw_crapdat.dtmvtolt
       ,vr_vl_para_creditar
       ,vr_vl_para_creditar
       ,vr_vl_para_creditar
       ,vr_vl_para_creditar
       ,vr_vl_para_creditar -- Saldo acumulado - apenas o valor da aplicacao
       ,vr_tab_care(1).qtdiacar
       ,vr_tab_care(1).qtdiaprz
       ,vr_tab_care(1).qtdiaprz
       ,94                  -- taxa de rendimento  - vr_txaplica
       ,0                   -- Saque Total
       ,0                   -- Bloqueio Resgate
       ,0                   -- Cálculo Orçamento
       ,rw_craprac.nrctrrpp -- Número da aplicação programada
       ,1                   -- pr_iddebcti
       ,'1'                 -- pr_cdoperad
       )
         RETURNING
          craprac.rowid
        INTO
          vr_craprac_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        falha('ERRO - Erro criando aplicacao! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' SQLERRM: '|| SQLERRM);
        RAISE vr_excsaida;  
    END;
    
    backup('delete from craprac where rowid = ''' || vr_craprac_rowid ||''';');
    
    rollback_script('update craprac set idsaqtot = 1, vlsldatl = 0 where rowid = ''' || vr_craprac_rowid ||''';');
    
    -- Atualiza o lote
    OPEN cr_craplot(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_cdagenci => 1
                   ,pr_cdbccxlt => 100
                   ,pr_nrdolote => 8500);
    FETCH cr_craplot INTO rw_craplot;
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      BEGIN
        INSERT INTO
          craplot(
            cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,tplotmov
           ,nrseqdig
           ,qtinfoln
           ,qtcompln
           ,vlinfocr
           ,vlcompcr)
        VALUES(
          rw_aplica.cdcooper
         ,rw_crapdat.dtmvtolt
         ,1
         ,100
         ,8500
         ,9
         ,1
         ,1
         ,1
         ,vr_vl_para_creditar
         ,vr_vl_para_creditar)
        RETURNING
          craplot.dtmvtolt
         ,craplot.cdagenci
         ,craplot.cdbccxlt
         ,craplot.nrdolote
         ,craplot.nrseqdig
         ,craplot.rowid
        INTO
          rw_craplot.dtmvtolt
         ,rw_craplot.cdagenci
         ,rw_craplot.cdbccxlt
         ,rw_craplot.nrdolote
         ,rw_craplot.nrseqdig
         ,rw_craplot.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          falha('ERRO - Erro inserindo lote! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' SQLERRM: '|| SQLERRM);
          RAISE vr_excsaida;  
      END;
    ELSE
      CLOSE cr_craplot;

      BEGIN
        UPDATE
          craplot
        SET
          craplot.nrseqdig = rw_craplot.nrseqdig + 1,
          craplot.qtinfoln = rw_craplot.qtinfoln + 1,
          craplot.qtcompln = rw_craplot.qtcompln + 1,
          craplot.vlinfocr = rw_craplot.vlinfocr + vr_vl_para_creditar,
          craplot.vlcompcr = rw_craplot.vlcompcr + vr_vl_para_creditar
        WHERE
          craplot.rowid = rw_craplot.rowid
        RETURNING
          craplot.dtmvtolt
         ,craplot.cdagenci
         ,craplot.cdbccxlt
         ,craplot.nrdolote
         ,craplot.nrseqdig
        INTO
          rw_craplot.dtmvtolt
         ,rw_craplot.cdagenci
         ,rw_craplot.cdbccxlt
         ,rw_craplot.nrdolote
         ,rw_craplot.nrseqdig;

      EXCEPTION
        WHEN OTHERS THEN
          falha('ERRO - Erro atualizando lote! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' SQLERRM: '|| SQLERRM);
          RAISE vr_excsaida;  
      END;
    END IF;
    
    -- Insere o lancamento na craplac
    BEGIN
      INSERT INTO
        craplac(
          cdcooper
         ,dtmvtolt
         ,cdagenci
         ,cdbccxlt
         ,nrdolote
         ,nrdconta
         ,nraplica
         ,nrdocmto
         ,nrseqdig
         ,vllanmto
         ,cdhistor
      )VALUES(
         rw_aplica.cdcooper
        ,rw_craplot.dtmvtolt
        ,rw_craplot.cdagenci
        ,rw_craplot.cdbccxlt
        ,rw_craplot.nrdolote
        ,rw_aplica.nrdconta
        ,vr_nraplica
        ,rw_craplot.nrseqdig
        ,rw_craplot.nrseqdig
        ,vr_vl_para_creditar
        ,2743 --vr_cdhistor
        )
       RETURNING
         craplac.rowid
       INTO
         vr_craplac_rowid;

    EXCEPTION
      WHEN OTHERS THEN
        falha('ERRO - Erro inserindo lcto! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' SQLERRM: '|| SQLERRM);
        RAISE vr_excsaida;  
    END;
    
    backup('delete from craplac where rowid = ''' || vr_craplac_rowid ||''';');
    
    -- Soma o total de credito para fazer o backup do craplot.
    vr_soma_creditos(rw_aplica.cdcooper).qtde  := vr_soma_creditos(rw_aplica.cdcooper).qtde  + 1;
    vr_soma_creditos(rw_aplica.cdcooper).valor := vr_soma_creditos(rw_aplica.cdcooper).valor + vr_vl_para_creditar;
    vr_soma_creditos(rw_aplica.cdcooper).craplot_rowid := rw_craplot.rowid;
          
    loga('Aplicacao criada! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' Aplica: '|| vr_nraplica ||' Valor: '|| vr_vl_para_creditar);
    sucesso('Aplicacao criada! Cooper: '|| rw_aplica.cdcooper || ' Conta: ' ||rw_aplica.nrdconta || ' Plano: '|| rw_craprac.nrctrrpp || ' Aplica: '|| vr_nraplica ||' Valor: '|| vr_vl_para_creditar);

  END LOOP;

  loga('Fim do Processo principal com sucesso');
  
  pc_backup_lote;  
  
  rollback_script('commit;');
  
  loga('Fim do Processo com sucesso');

  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
    
  --rollback;
  commit;

  fecha_arquivos;
  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;    
    rollback;
    loga('rollbackou');
    fecha_arquivos;
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    loga('rollbackou');
    fecha_arquivos;
end;
1
vr_dscritic
0
5
5
vr_vlaplica
vr_dtmvtolt
vr_vlsldtot
vr_vlrendim
