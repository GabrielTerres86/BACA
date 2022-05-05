DECLARE
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  
  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0137635';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0137635';
  vc_dstransaAtuDtCRAPLCM             CONSTANT VARCHAR2(4000) := 'Atualizacao da Data de Lancamento (CRAPLCM) por script - INC0137635';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('02/05/2022','dd/mm/yyyy');
  vc_dtmvtoltCRAPLCM                  CONSTANT DATE           := to_date('02/05/2022','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.cdcooper
          ,a.vlsddisp
          ,contas.valor
      from CECRED.crapsld a
          ,(select 1 as cdcooper, 644668 as nrdconta, 46.82 as valor from dual union all
            select 1 as cdcooper, 761885 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 805777 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 1522540 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 1839411 as nrdconta, 17.44 as valor from dual union all
            select 1 as cdcooper, 2010925 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 2017458 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 2026716 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 2046776 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 2184818 as nrdconta, 300 as valor from dual union all
            select 1 as cdcooper, 2214369 as nrdconta, 1350 as valor from dual union all
            select 1 as cdcooper, 2237873 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 2357569 as nrdconta, 4950 as valor from dual union all
            select 1 as cdcooper, 2382628 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 2561638 as nrdconta, 202 as valor from dual union all
            select 1 as cdcooper, 2605120 as nrdconta, 41 as valor from dual union all
            select 1 as cdcooper, 2616912 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 2730847 as nrdconta, 90 as valor from dual union all
            select 1 as cdcooper, 2953307 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 3091694 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 3200990 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 3522857 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 3938921 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 4087879 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 6143377 as nrdconta, 2000 as valor from dual union all
            select 1 as cdcooper, 6233260 as nrdconta, 62.5 as valor from dual union all
            select 1 as cdcooper, 6336310 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 6421822 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 6518664 as nrdconta, 300 as valor from dual union all
            select 1 as cdcooper, 6710859 as nrdconta, 950 as valor from dual union all
            select 1 as cdcooper, 6715168 as nrdconta, 1499.91 as valor from dual union all
            select 1 as cdcooper, 6768385 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 6828906 as nrdconta, 73 as valor from dual union all
            select 1 as cdcooper, 7221045 as nrdconta, 127 as valor from dual union all
            select 1 as cdcooper, 7223420 as nrdconta, 27.49 as valor from dual union all
            select 1 as cdcooper, 7231911 as nrdconta, 240 as valor from dual union all
            select 1 as cdcooper, 7384858 as nrdconta, 2000 as valor from dual union all
            select 1 as cdcooper, 7510519 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 7600178 as nrdconta, 18 as valor from dual union all
            select 1 as cdcooper, 7766726 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 7973969 as nrdconta, 109.98 as valor from dual union all
            select 1 as cdcooper, 8083037 as nrdconta, 52 as valor from dual union all
            select 1 as cdcooper, 8286825 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 8339899 as nrdconta, 15.34 as valor from dual union all
            select 1 as cdcooper, 8352399 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 8451931 as nrdconta, 200 as valor from dual union all
            select 1 as cdcooper, 8783098 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 8979316 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 9057625 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9073914 as nrdconta, 230 as valor from dual union all
            select 1 as cdcooper, 9081127 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 9187367 as nrdconta, 520 as valor from dual union all
            select 1 as cdcooper, 9288570 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9331654 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 9583386 as nrdconta, 7.5 as valor from dual union all
            select 1 as cdcooper, 9689923 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 9928448 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 9963227 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9985000 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10001301 as nrdconta, 290 as valor from dual union all
            select 1 as cdcooper, 10032312 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 10064141 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 10089225 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 10157557 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 10199098 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 10202900 as nrdconta, 24.9 as valor from dual union all
            select 1 as cdcooper, 10226397 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 10247556 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 10274804 as nrdconta, 24.91 as valor from dual union all
            select 1 as cdcooper, 10289054 as nrdconta, 35.98 as valor from dual union all
            select 1 as cdcooper, 10310770 as nrdconta, 59.95 as valor from dual union all
            select 1 as cdcooper, 10372334 as nrdconta, 70 as valor from dual union all
            select 1 as cdcooper, 10400133 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 10405976 as nrdconta, 43.49 as valor from dual union all
            select 1 as cdcooper, 10448489 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10470425 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 10524754 as nrdconta, 192.87 as valor from dual union all
            select 1 as cdcooper, 10538291 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10568751 as nrdconta, 150 as valor from dual union all
            select 1 as cdcooper, 10596160 as nrdconta, 110 as valor from dual union all
            select 1 as cdcooper, 10634304 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 10644539 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 10675590 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 10676791 as nrdconta, 29 as valor from dual union all
            select 1 as cdcooper, 10743782 as nrdconta, 85.5 as valor from dual union all
            select 1 as cdcooper, 10826033 as nrdconta, 16 as valor from dual union all
            select 1 as cdcooper, 10911146 as nrdconta, 175.65 as valor from dual union all
            select 1 as cdcooper, 10918531 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 10931910 as nrdconta, 14.1 as valor from dual union all
            select 1 as cdcooper, 11075775 as nrdconta, 18 as valor from dual union all
            select 1 as cdcooper, 11116579 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 11130415 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 11203072 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 11282762 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 11296631 as nrdconta, 15 as valor from dual union all
            select 1 as cdcooper, 11315547 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 11419253 as nrdconta, 1600 as valor from dual union all
            select 1 as cdcooper, 11457180 as nrdconta, 21 as valor from dual union all
            select 1 as cdcooper, 11554401 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 11655844 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 11717548 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 11748451 as nrdconta, 4 as valor from dual union all
            select 1 as cdcooper, 11784326 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 11787287 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 11835290 as nrdconta, 120.01 as valor from dual union all
            select 1 as cdcooper, 11889810 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 11924187 as nrdconta, 165.97 as valor from dual union all
            select 1 as cdcooper, 11983272 as nrdconta, 76 as valor from dual union all
            select 1 as cdcooper, 12044873 as nrdconta, 96 as valor from dual union all
            select 1 as cdcooper, 12047864 as nrdconta, 25 as valor from dual union all
            select 1 as cdcooper, 12062782 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 12128414 as nrdconta, 750 as valor from dual union all
            select 1 as cdcooper, 12134368 as nrdconta, 320.5 as valor from dual union all
            select 1 as cdcooper, 12148474 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 12153397 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 12155489 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 12163260 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 12164240 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 12257281 as nrdconta, 60 as valor from dual union all
            select 1 as cdcooper, 12297593 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 12315753 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 12343790 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 12474428 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 12546364 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 12554375 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 12677426 as nrdconta, 240 as valor from dual union all
            select 1 as cdcooper, 12696757 as nrdconta, 1.5 as valor from dual union all
            select 1 as cdcooper, 12996645 as nrdconta, 24 as valor from dual union all
            select 1 as cdcooper, 13011758 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 13048228 as nrdconta, 160 as valor from dual union all
            select 1 as cdcooper, 13097709 as nrdconta, 112.89 as valor from dual union all
            select 1 as cdcooper, 13253115 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 13347624 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 13520148 as nrdconta, 14.58 as valor from dual union all
            select 1 as cdcooper, 13552821 as nrdconta, 800 as valor from dual union all
            select 1 as cdcooper, 13618580 as nrdconta, 38.99 as valor from dual union all
            select 1 as cdcooper, 13658360 as nrdconta, 170 as valor from dual union all
            select 1 as cdcooper, 13839900 as nrdconta, 150 as valor from dual union all
            select 1 as cdcooper, 13853643 as nrdconta, 103.89 as valor from dual union all
            select 1 as cdcooper, 13855549 as nrdconta, 33.53 as valor from dual union all
            select 1 as cdcooper, 13890034 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 13923820 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 13934511 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 14097664 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 14144913 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 14179130 as nrdconta, 19.9 as valor from dual union all
            select 1 as cdcooper, 14243040 as nrdconta, 346.71 as valor from dual union all
            select 1 as cdcooper, 14303299 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 14330695 as nrdconta, 19.96 as valor from dual union all
            select 1 as cdcooper, 14383098 as nrdconta, 200 as valor from dual union all
            select 1 as cdcooper, 14565307 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 80100260 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 573094 as nrdconta, 300 as valor from dual union all
            select 2 as cdcooper, 639672 as nrdconta, 200 as valor from dual union all
            select 2 as cdcooper, 724785 as nrdconta, 70 as valor from dual union all
            select 2 as cdcooper, 727423 as nrdconta, 280 as valor from dual union all
            select 2 as cdcooper, 734667 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 981290 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 1044117 as nrdconta, 20 as valor from dual union all
            select 2 as cdcooper, 1101854 as nrdconta, 72 as valor from dual union all
            select 2 as cdcooper, 1111817 as nrdconta, 200 as valor from dual union all
            select 2 as cdcooper, 14559447 as nrdconta, 1000 as valor from dual union all
            select 5 as cdcooper, 136280 as nrdconta, 43.51 as valor from dual union all
            select 5 as cdcooper, 161110 as nrdconta, 200 as valor from dual union all
            select 5 as cdcooper, 262153 as nrdconta, 275 as valor from dual union all
            select 7 as cdcooper, 193836 as nrdconta, 60.5 as valor from dual union all
            select 7 as cdcooper, 330256 as nrdconta, 270 as valor from dual union all
            select 7 as cdcooper, 336998 as nrdconta, 114.4 as valor from dual union all
            select 7 as cdcooper, 13863916 as nrdconta, 20 as valor from dual union all
            select 7 as cdcooper, 14146134 as nrdconta, 40 as valor from dual union all
            select 9 as cdcooper, 40398 as nrdconta, 880 as valor from dual union all
            select 9 as cdcooper, 187828 as nrdconta, 100 as valor from dual union all
            select 10 as cdcooper, 74012 as nrdconta, 35 as valor from dual union all
            select 10 as cdcooper, 123382 as nrdconta, 700 as valor from dual union all
            select 10 as cdcooper, 231894 as nrdconta, 150 as valor from dual union all
            select 11 as cdcooper, 141100 as nrdconta, 70 as valor from dual union all
            select 11 as cdcooper, 226777 as nrdconta, 150 as valor from dual union all
            select 11 as cdcooper, 281824 as nrdconta, 30 as valor from dual union all
            select 11 as cdcooper, 453170 as nrdconta, 5 as valor from dual union all
            select 11 as cdcooper, 520942 as nrdconta, 40 as valor from dual union all
            select 11 as cdcooper, 547182 as nrdconta, 47 as valor from dual union all
            select 11 as cdcooper, 694320 as nrdconta, 20 as valor from dual union all
            select 11 as cdcooper, 744417 as nrdconta, 18.62 as valor from dual union all
            select 11 as cdcooper, 753610 as nrdconta, 50 as valor from dual union all
            select 11 as cdcooper, 832723 as nrdconta, 13 as valor from dual union all
            select 11 as cdcooper, 853151 as nrdconta, 92 as valor from dual union all
            select 12 as cdcooper, 107646 as nrdconta, 22 as valor from dual union all
            select 12 as cdcooper, 122912 as nrdconta, 30 as valor from dual union all
            select 12 as cdcooper, 150649 as nrdconta, 200 as valor from dual union all
            select 12 as cdcooper, 206032 as nrdconta, 261.68 as valor from dual union all
            select 13 as cdcooper, 121878 as nrdconta, 1000 as valor from dual union all
            select 13 as cdcooper, 281646 as nrdconta, 420 as valor from dual union all
            select 14 as cdcooper, 225983 as nrdconta, 550 as valor from dual union all
            select 14 as cdcooper, 228303 as nrdconta, 12.1 as valor from dual union all
            select 14 as cdcooper, 266353 as nrdconta, 50 as valor from dual union all
            select 14 as cdcooper, 319929 as nrdconta, 30 as valor from dual union all
            select 16 as cdcooper, 870897 as nrdconta, 300 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.cdcooper, a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor
      from CECRED.crapsda a
          ,(select 1 as cdcooper, 644668 as nrdconta, 46.82 as valor from dual union all
            select 1 as cdcooper, 761885 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 805777 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 1522540 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 1839411 as nrdconta, 17.44 as valor from dual union all
            select 1 as cdcooper, 2010925 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 2017458 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 2026716 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 2046776 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 2184818 as nrdconta, 300 as valor from dual union all
            select 1 as cdcooper, 2214369 as nrdconta, 1350 as valor from dual union all
            select 1 as cdcooper, 2237873 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 2357569 as nrdconta, 4950 as valor from dual union all
            select 1 as cdcooper, 2382628 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 2561638 as nrdconta, 202 as valor from dual union all
            select 1 as cdcooper, 2605120 as nrdconta, 41 as valor from dual union all
            select 1 as cdcooper, 2616912 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 2730847 as nrdconta, 90 as valor from dual union all
            select 1 as cdcooper, 2953307 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 3091694 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 3200990 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 3522857 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 3938921 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 4087879 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 6143377 as nrdconta, 2000 as valor from dual union all
            select 1 as cdcooper, 6233260 as nrdconta, 62.5 as valor from dual union all
            select 1 as cdcooper, 6336310 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 6421822 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 6518664 as nrdconta, 300 as valor from dual union all
            select 1 as cdcooper, 6710859 as nrdconta, 950 as valor from dual union all
            select 1 as cdcooper, 6715168 as nrdconta, 1499.91 as valor from dual union all
            select 1 as cdcooper, 6768385 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 6828906 as nrdconta, 73 as valor from dual union all
            select 1 as cdcooper, 7221045 as nrdconta, 127 as valor from dual union all
            select 1 as cdcooper, 7223420 as nrdconta, 27.49 as valor from dual union all
            select 1 as cdcooper, 7231911 as nrdconta, 240 as valor from dual union all
            select 1 as cdcooper, 7384858 as nrdconta, 2000 as valor from dual union all
            select 1 as cdcooper, 7510519 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 7600178 as nrdconta, 18 as valor from dual union all
            select 1 as cdcooper, 7766726 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 7973969 as nrdconta, 109.98 as valor from dual union all
            select 1 as cdcooper, 8083037 as nrdconta, 52 as valor from dual union all
            select 1 as cdcooper, 8286825 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 8339899 as nrdconta, 15.34 as valor from dual union all
            select 1 as cdcooper, 8352399 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 8451931 as nrdconta, 200 as valor from dual union all
            select 1 as cdcooper, 8783098 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 8979316 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 9057625 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9073914 as nrdconta, 230 as valor from dual union all
            select 1 as cdcooper, 9081127 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 9187367 as nrdconta, 520 as valor from dual union all
            select 1 as cdcooper, 9288570 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9331654 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 9583386 as nrdconta, 7.5 as valor from dual union all
            select 1 as cdcooper, 9689923 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 9928448 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 9963227 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 9985000 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10001301 as nrdconta, 290 as valor from dual union all
            select 1 as cdcooper, 10032312 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 10064141 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 10089225 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 10157557 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 10199098 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 10202900 as nrdconta, 24.9 as valor from dual union all
            select 1 as cdcooper, 10226397 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 10247556 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 10274804 as nrdconta, 24.91 as valor from dual union all
            select 1 as cdcooper, 10289054 as nrdconta, 35.98 as valor from dual union all
            select 1 as cdcooper, 10310770 as nrdconta, 59.95 as valor from dual union all
            select 1 as cdcooper, 10372334 as nrdconta, 70 as valor from dual union all
            select 1 as cdcooper, 10400133 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 10405976 as nrdconta, 43.49 as valor from dual union all
            select 1 as cdcooper, 10448489 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10470425 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 10524754 as nrdconta, 192.87 as valor from dual union all
            select 1 as cdcooper, 10538291 as nrdconta, 30 as valor from dual union all
            select 1 as cdcooper, 10568751 as nrdconta, 150 as valor from dual union all
            select 1 as cdcooper, 10596160 as nrdconta, 110 as valor from dual union all
            select 1 as cdcooper, 10634304 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 10644539 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 10675590 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 10676791 as nrdconta, 29 as valor from dual union all
            select 1 as cdcooper, 10743782 as nrdconta, 85.5 as valor from dual union all
            select 1 as cdcooper, 10826033 as nrdconta, 16 as valor from dual union all
            select 1 as cdcooper, 10911146 as nrdconta, 175.65 as valor from dual union all
            select 1 as cdcooper, 10918531 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 10931910 as nrdconta, 14.1 as valor from dual union all
            select 1 as cdcooper, 11075775 as nrdconta, 18 as valor from dual union all
            select 1 as cdcooper, 11116579 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 11130415 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 11203072 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 11282762 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 11296631 as nrdconta, 15 as valor from dual union all
            select 1 as cdcooper, 11315547 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 11419253 as nrdconta, 1600 as valor from dual union all
            select 1 as cdcooper, 11457180 as nrdconta, 21 as valor from dual union all
            select 1 as cdcooper, 11554401 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 11655844 as nrdconta, 14 as valor from dual union all
            select 1 as cdcooper, 11717548 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 11748451 as nrdconta, 4 as valor from dual union all
            select 1 as cdcooper, 11784326 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 11787287 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 11835290 as nrdconta, 120.01 as valor from dual union all
            select 1 as cdcooper, 11889810 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 11924187 as nrdconta, 165.97 as valor from dual union all
            select 1 as cdcooper, 11983272 as nrdconta, 76 as valor from dual union all
            select 1 as cdcooper, 12044873 as nrdconta, 96 as valor from dual union all
            select 1 as cdcooper, 12047864 as nrdconta, 25 as valor from dual union all
            select 1 as cdcooper, 12062782 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 12128414 as nrdconta, 750 as valor from dual union all
            select 1 as cdcooper, 12134368 as nrdconta, 320.5 as valor from dual union all
            select 1 as cdcooper, 12148474 as nrdconta, 250 as valor from dual union all
            select 1 as cdcooper, 12153397 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 12155489 as nrdconta, 40 as valor from dual union all
            select 1 as cdcooper, 12163260 as nrdconta, 500 as valor from dual union all
            select 1 as cdcooper, 12164240 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 12257281 as nrdconta, 60 as valor from dual union all
            select 1 as cdcooper, 12297593 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 12315753 as nrdconta, 100 as valor from dual union all
            select 1 as cdcooper, 12343790 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 12474428 as nrdconta, 600 as valor from dual union all
            select 1 as cdcooper, 12546364 as nrdconta, 12 as valor from dual union all
            select 1 as cdcooper, 12554375 as nrdconta, 80 as valor from dual union all
            select 1 as cdcooper, 12677426 as nrdconta, 240 as valor from dual union all
            select 1 as cdcooper, 12696757 as nrdconta, 1.5 as valor from dual union all
            select 1 as cdcooper, 12996645 as nrdconta, 24 as valor from dual union all
            select 1 as cdcooper, 13011758 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 13048228 as nrdconta, 160 as valor from dual union all
            select 1 as cdcooper, 13097709 as nrdconta, 112.89 as valor from dual union all
            select 1 as cdcooper, 13253115 as nrdconta, 35 as valor from dual union all
            select 1 as cdcooper, 13347624 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 13520148 as nrdconta, 14.58 as valor from dual union all
            select 1 as cdcooper, 13552821 as nrdconta, 800 as valor from dual union all
            select 1 as cdcooper, 13618580 as nrdconta, 38.99 as valor from dual union all
            select 1 as cdcooper, 13658360 as nrdconta, 170 as valor from dual union all
            select 1 as cdcooper, 13839900 as nrdconta, 150 as valor from dual union all
            select 1 as cdcooper, 13853643 as nrdconta, 103.89 as valor from dual union all
            select 1 as cdcooper, 13855549 as nrdconta, 33.53 as valor from dual union all
            select 1 as cdcooper, 13890034 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 13923820 as nrdconta, 50 as valor from dual union all
            select 1 as cdcooper, 13934511 as nrdconta, 10 as valor from dual union all
            select 1 as cdcooper, 14097664 as nrdconta, 1000 as valor from dual union all
            select 1 as cdcooper, 14144913 as nrdconta, 17 as valor from dual union all
            select 1 as cdcooper, 14179130 as nrdconta, 19.9 as valor from dual union all
            select 1 as cdcooper, 14243040 as nrdconta, 346.71 as valor from dual union all
            select 1 as cdcooper, 14303299 as nrdconta, 5 as valor from dual union all
            select 1 as cdcooper, 14330695 as nrdconta, 19.96 as valor from dual union all
            select 1 as cdcooper, 14383098 as nrdconta, 200 as valor from dual union all
            select 1 as cdcooper, 14565307 as nrdconta, 20 as valor from dual union all
            select 1 as cdcooper, 80100260 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 573094 as nrdconta, 300 as valor from dual union all
            select 2 as cdcooper, 639672 as nrdconta, 200 as valor from dual union all
            select 2 as cdcooper, 724785 as nrdconta, 70 as valor from dual union all
            select 2 as cdcooper, 727423 as nrdconta, 280 as valor from dual union all
            select 2 as cdcooper, 734667 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 981290 as nrdconta, 100 as valor from dual union all
            select 2 as cdcooper, 1044117 as nrdconta, 20 as valor from dual union all
            select 2 as cdcooper, 1101854 as nrdconta, 72 as valor from dual union all
            select 2 as cdcooper, 1111817 as nrdconta, 200 as valor from dual union all
            select 2 as cdcooper, 14559447 as nrdconta, 1000 as valor from dual union all
            select 5 as cdcooper, 136280 as nrdconta, 43.51 as valor from dual union all
            select 5 as cdcooper, 161110 as nrdconta, 200 as valor from dual union all
            select 5 as cdcooper, 262153 as nrdconta, 275 as valor from dual union all
            select 7 as cdcooper, 193836 as nrdconta, 60.5 as valor from dual union all
            select 7 as cdcooper, 330256 as nrdconta, 270 as valor from dual union all
            select 7 as cdcooper, 336998 as nrdconta, 114.4 as valor from dual union all
            select 7 as cdcooper, 13863916 as nrdconta, 20 as valor from dual union all
            select 7 as cdcooper, 14146134 as nrdconta, 40 as valor from dual union all
            select 9 as cdcooper, 40398 as nrdconta, 880 as valor from dual union all
            select 9 as cdcooper, 187828 as nrdconta, 100 as valor from dual union all
            select 10 as cdcooper, 74012 as nrdconta, 35 as valor from dual union all
            select 10 as cdcooper, 123382 as nrdconta, 700 as valor from dual union all
            select 10 as cdcooper, 231894 as nrdconta, 150 as valor from dual union all
            select 11 as cdcooper, 141100 as nrdconta, 70 as valor from dual union all
            select 11 as cdcooper, 226777 as nrdconta, 150 as valor from dual union all
            select 11 as cdcooper, 281824 as nrdconta, 30 as valor from dual union all
            select 11 as cdcooper, 453170 as nrdconta, 5 as valor from dual union all
            select 11 as cdcooper, 520942 as nrdconta, 40 as valor from dual union all
            select 11 as cdcooper, 547182 as nrdconta, 47 as valor from dual union all
            select 11 as cdcooper, 694320 as nrdconta, 20 as valor from dual union all
            select 11 as cdcooper, 744417 as nrdconta, 18.62 as valor from dual union all
            select 11 as cdcooper, 753610 as nrdconta, 50 as valor from dual union all
            select 11 as cdcooper, 832723 as nrdconta, 13 as valor from dual union all
            select 11 as cdcooper, 853151 as nrdconta, 92 as valor from dual union all
            select 12 as cdcooper, 107646 as nrdconta, 22 as valor from dual union all
            select 12 as cdcooper, 122912 as nrdconta, 30 as valor from dual union all
            select 12 as cdcooper, 150649 as nrdconta, 200 as valor from dual union all
            select 12 as cdcooper, 206032 as nrdconta, 261.68 as valor from dual union all
            select 13 as cdcooper, 121878 as nrdconta, 1000 as valor from dual union all
            select 13 as cdcooper, 281646 as nrdconta, 420 as valor from dual union all
            select 14 as cdcooper, 225983 as nrdconta, 550 as valor from dual union all
            select 14 as cdcooper, 228303 as nrdconta, 12.1 as valor from dual union all
            select 14 as cdcooper, 266353 as nrdconta, 50 as valor from dual union all
            select 14 as cdcooper, 319929 as nrdconta, 30 as valor from dual union all
            select 16 as cdcooper, 870897 as nrdconta, 300 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper
       AND a.dtmvtolt BETWEEN vc_dtinicioCRAPSDA AND
           TRUNC(SYSDATE)
     ORDER BY a.nrdconta, a.dtmvtolt asc;

  CURSOR cr_craplcm is
    SELECT l.nrdconta, l.cdcooper, l.dtmvtolt, l.progress_recid, l.cdagenci, l.cdbccxlt, l.nrdolote, l.nrseqdig
      from CECRED.craplcm l
     WHERE 1=1
       AND l.progress_recid IN (1446790866,
                                1446785056,
                                1446789335,
                                1446774654,
                                1446813016,
                                1446790125,
                                1446777221,
                                1446813023,
                                1446777223,
                                1446618116,
                                1446820310,
                                1446614990,
                                1446786923,
                                1446628751,
                                1446617420,
                                1446624427,
                                1446782271,
                                1446660652,
                                1446774656,
                                1446789691,
                                1446795742,
                                1446809271,
                                1446790126,
                                1446756102,
                                1446615098,
                                1446777225,
                                1446787712,
                                1446617748,
                                1446614874,
                                1446796729,
                                1446795741,
                                1446775917,
                                1446781393,
                                1446783074,
                                1446782273,
                                1446617826,
                                1446809276,
                                1446822990,
                                1446783073,
                                1446755437,
                                1446811917,
                                1446816899,
                                1446794819,
                                1446783436,
                                1446816901,
                                1446777228,
                                1446773513,
                                1446617697,
                                1446813584,
                                1446614030,
                                1446758538,
                                1446614173,
                                1446782275,
                                1446789692,
                                1446617421,
                                1446660043,
                                1446787715,
                                1446817515,
                                1446775918,
                                1446614204,
                                1446614991,
                                1446814047,
                                1446785057,
                                1446809297,
                                1446775919,
                                1446814048,
                                1446781395,
                                1446760952,
                                1446755909,
                                1446614144,
                                1446755458,
                                1446659062,
                                1446777234,
                                1446660182,
                                1446775920,
                                1446615851,
                                1446769715,
                                1446813607,
                                1446779723,
                                1446773515,
                                1446779724,
                                1446660570,
                                1446775921,
                                1446628865,
                                1446614924,
                                1446614875,
                                1446811934,
                                1446614031,
                                1446617727,
                                1446822992,
                                1446618117,
                                1446658971,
                                1446773295,
                                1446660183,
                                1446786568,
                                1446617422,
                                1446614234,
                                1446614145,
                                1446783075,
                                1446629144,
                                1446773296,
                                1446777236,
                                1446777239,
                                1446791354,
                                1446774657,
                                1446779728,
                                1446794821,
                                1446815754,
                                1446618252,
                                1446614391,
                                1446660727,
                                1446778035,
                                1446824638,
                                1446660469,
                                1446628752,
                                1446755973,
                                1446756647,
                                1446789339,
                                1446777242,
                                1446660470,
                                1446755827,
                                1446775928,
                                1446773297,
                                1446774659,
                                1446659959,
                                1446617830,
                                1446614841,
                                1446791355,
                                1446777677,
                                1446661319,
                                1446773300,
                                1446769716,
                                1446614925,
                                1446758539,
                                1446618118,
                                1446628866,
                                1446774660,
                                1446614392,
                                1446660571,
                                1446766371,
                                1446614069,
                                1446661213,
                                1446617749,
                                1446624701,
                                1446757481,
                                1446755287,
                                1446617698,
                                1446816905,
                                1446770476,
                                1446628964,
                                1446660728,
                                1446629145,
                                1446614236,
                                1446772570,
                                1446779730,
                                1446781396,
                                1446614174,
                                1446774663,
                                1446777245,
                                1446778036,
                                1446624702,
                                1446817517,
                                1446660831,
                                1446772933,
                                1446625163,
                                1446628965,
                                1446779737,
                                1446614926,
                                1446773516,
                                1446774667,
                                1446614340,
                                1446614842,
                                1446660832,
                                1446777679,
                                1446628966,
                                1446773303,
                                1446661029,
                                1446617750,
                                1446775932,
                                1446778038,
                                1446824641,
                                1446772571,
                                1446774669,
                                1446614205,
                                1446774670,
                                1446614109,
                                1446614237,
                                1446781399,
                                1446614175,
                                1446769719,
                                1446628868,
                                1446779739,
                                1446777250,
                                1446614876,
                                1446822999,
                                1446660068,
                                1446763147,
                                1446618119,
                                1446614653,
                                1446755421);


     
  PROCEDURE pr_atualiza_sld(pr_cdcooper IN NUMBER,
                            pr_nrdconta IN NUMBER,
                            pr_vlsddisp IN NUMBER,
                            pr_valor    IN NUMBER,
                            pr_dscritic OUT VARCHAR2) IS
  vr_nrdrowid ROWID;
  
  BEGIN
  
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => pr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaSensbCRAPSLD,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapsld.VLSDDISP',
                                       pr_dsdadant => pr_vlsddisp,
                                       pr_dsdadatu => pr_vlsddisp + pr_valor);
      UPDATE CECRED.crapsld a
         SET a.VLSDDISP = a.vlsddisp + pr_valor
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper;
    END IF;       
  END;
    
  PROCEDURE pr_atualiza_sda(pr_cdcooper IN NUMBER,
                            pr_nrdconta IN NUMBER,
                            pr_dtmvtolt IN DATE,
                            pr_vlsddisp IN NUMBER,
                            pr_valor    IN NUMBER,
                            pr_dscritic OUT VARCHAR2) IS

  vr_nrdrowid ROWID;
  
  BEGIN
  
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => pr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaSensbCRAPSDA,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapsda.DTMVTOLT',
                                       pr_dsdadant => pr_dtmvtolt,
                                       pr_dsdadatu => pr_dtmvtolt);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapsda.VLSDDISP',
                                       pr_dsdadant => pr_vlsddisp,
                                       pr_dsdadatu => pr_vlsddisp + pr_valor);

        UPDATE CECRED.crapsda a
           SET a.VLSDDISP = a.vlsddisp + pr_valor
         WHERE a.nrdconta = pr_nrdconta
           AND a.cdcooper = pr_cdcooper
           AND a.dtmvtolt = pr_dtmvtolt;
    END IF;       
  END;
  
  PROCEDURE pr_atualiza_lcm(pr_cdcooper        IN NUMBER,
                            pr_nrdconta        IN NUMBER,
                            pr_dtmvtolt_old    IN DATE,
                            pr_dtmvtolt_new    IN DATE,
                            pr_cdagenci        IN NUMBER,
                            pr_cdbccxlt        IN NUMBER,
                            pr_nrdolote        IN NUMBER,
                            pr_nrseqdig        IN NUMBER,
                            pr_progressrecid   IN NUMBER,
                            pr_dscritic        OUT VARCHAR2) IS

  vr_nrdrowid               ROWID;
  vr_nrseqdig_new           cecred.craplcm.nrseqdig%type;
  
  BEGIN
  
    vr_nrdrowid := null;
    vr_nrseqdig_new := 0;

    select nvl(max(l.nrseqdig),0) + 1
      into vr_nrseqdig_new
      from cecred.craplcm l
     where l.cdcooper = pr_cdcooper
       and l.dtmvtolt = pr_dtmvtolt_new
       and l.cdagenci = pr_cdagenci
       and l.cdbccxlt = pr_cdbccxlt
       and l.nrdolote = pr_nrdolote;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => pr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaAtuDtCRAPLCM,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF pr_dscritic is NULL THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.DTMVTOLT',
                                       pr_dsdadant => pr_dtmvtolt_old,
                                       pr_dsdadatu => pr_dtmvtolt_new);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.PROGRESS_RECID',
                                       pr_dsdadant => pr_progressrecid,
                                       pr_dsdadatu => pr_progressrecid);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplcm.NRSEQDIG',
                                       pr_dsdadant => pr_nrseqdig,
                                       pr_dsdadatu => vr_nrseqdig_new);
      
      
        UPDATE CECRED.craplcm l
           SET l.dtmvtolt = pr_dtmvtolt_new
              ,l.nrseqdig = vr_nrseqdig_new
         WHERE l.progress_recid = pr_progressrecid
           ;
    END IF;       
  END;

BEGIN
  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;

  FOR rg_crapsld IN cr_crapsld LOOP
    vr_cdcooper := rg_crapsld.cdcooper;
    vr_nrdconta := rg_crapsld.nrdconta;

    pr_atualiza_sld(vr_cdcooper,
                    vr_nrdconta,
                    rg_crapsld.vlsddisp,
                    rg_crapsld.valor,
                    vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;
       
  END LOOP;

  FOR rg_crapsda IN cr_crapsda LOOP
    vr_cdcooper := rg_crapsda.cdcooper;    
    vr_nrdconta := rg_crapsda.nrdconta;
    
    pr_atualiza_sda(vr_cdcooper,
                    vr_nrdconta,
                    rg_crapsda.dtmvtolt,
                    rg_crapsda.vlsddisp,
                    rg_crapsda.valor,
                    vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;

   END LOOP;

  FOR rg_craplcm IN cr_craplcm LOOP
    vr_cdcooper := rg_craplcm.cdcooper;        
    vr_nrdconta := rg_craplcm.nrdconta;
    
    pr_atualiza_lcm(vr_cdcooper,                      
                    vr_nrdconta,
                    rg_craplcm.dtmvtolt,
                    vc_dtmvtoltCRAPLCM,
                    rg_craplcm.cdagenci,
                    rg_craplcm.cdbccxlt,
                    rg_craplcm.nrdolote,
                    rg_craplcm.nrseqdig,
                    rg_craplcm.progress_recid,
                    vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;

   END LOOP;   
  
  COMMIT;
  
EXCEPTION
  WHEN vr_erro_geralog THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao gerar log para cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ')- ' ||  vr_dscritic);
    
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||  ' - ' || v_code || ' - ' || v_errm);
END;
