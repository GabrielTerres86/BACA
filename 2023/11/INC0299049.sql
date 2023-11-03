Declare 
  
  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0299049';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0299049';
  vc_dtinicioCRAPSDA                  CONSTANT DATE           := to_date('01/11/2023','dd/mm/yyyy');

  vr_erro_geralog EXCEPTION;
  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.cdcooper     
          ,contas.valor
      from CECRED.crapsld a
          ,(

SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9240 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9239 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9239 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16446 as NRDCONTA,1600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 923591 as NRDCONTA,2128.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 923591 as NRDCONTA,2339.78 as valor from dual
            union all
SELECT 1 as CDCOOPER, 941336 as NRDCONTA,1485.83 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2020599 as NRDCONTA,5950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2070731 as NRDCONTA,3700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2155060 as NRDCONTA,8000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2196700 as NRDCONTA,2287 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2212560 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2261375 as NRDCONTA,156 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2631504 as NRDCONTA,1967.05 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2837811 as NRDCONTA,12700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2943468 as NRDCONTA,1158.45 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2998386 as NRDCONTA,1300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3527662 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3567702 as NRDCONTA,3757 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3616177 as NRDCONTA,591.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3653854 as NRDCONTA,797.27 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3662667 as NRDCONTA,106.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3770001 as NRDCONTA,30161 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3812634 as NRDCONTA,1380 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3818276 as NRDCONTA,1505.58 as valor from dual
            union all
SELECT 1 as CDCOOPER, 4068718 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6058558 as NRDCONTA,2600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6058558 as NRDCONTA,3725.75 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,1883 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,2815 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,3085 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6130380 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6147895 as NRDCONTA,1472.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6168540 as NRDCONTA,297.85 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6168540 as NRDCONTA,200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6172148 as NRDCONTA,11877.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6207189 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6354971 as NRDCONTA,675 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6406955 as NRDCONTA,1236.98 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6409270 as NRDCONTA,350 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6458157 as NRDCONTA,843 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6462774 as NRDCONTA,524.81 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6486649 as NRDCONTA,2370 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6599680 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6662463 as NRDCONTA,325 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6715907 as NRDCONTA,1466 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6808352 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6824447 as NRDCONTA,700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6861989 as NRDCONTA,1230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6871488 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6900968 as NRDCONTA,6663.6 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7075006 as NRDCONTA,948.54 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7145250 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7165242 as NRDCONTA,313 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7168004 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7210612 as NRDCONTA,1750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7218575 as NRDCONTA,2688 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7244436 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7285671 as NRDCONTA,614.29 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7355580 as NRDCONTA,11891.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7355947 as NRDCONTA,811.56 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7366531 as NRDCONTA,1747 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7399332 as NRDCONTA,8500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7456727 as NRDCONTA,6750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7466854 as NRDCONTA,3900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7476850 as NRDCONTA,364.3 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,6600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7531052 as NRDCONTA,3290 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7549636 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7570252 as NRDCONTA,12000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7570252 as NRDCONTA,15120 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7581688 as NRDCONTA,5693.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7590520 as NRDCONTA,550 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7624310 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7627564 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7638990 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7641370 as NRDCONTA,1003.65 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7974256 as NRDCONTA,1605 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8012520 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8047189 as NRDCONTA,5097.9 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8064652 as NRDCONTA,2940 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8097038 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8097038 as NRDCONTA,667 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8240310 as NRDCONTA,880 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8261474 as NRDCONTA,5630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8309655 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8362327 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8362327 as NRDCONTA,14051 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8400822 as NRDCONTA,500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8446490 as NRDCONTA,4397.21 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8451842 as NRDCONTA,700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8533539 as NRDCONTA,3094 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8553521 as NRDCONTA,13000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8595542 as NRDCONTA,2200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8753440 as NRDCONTA,726.96 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8776652 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8790167 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8927472 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9006354 as NRDCONTA,400.7 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3676.68 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,4999.99 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9101810 as NRDCONTA,1230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111387 as NRDCONTA,2807 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111581 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111581 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111654 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9134662 as NRDCONTA,6500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9134794 as NRDCONTA,7675 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9138609 as NRDCONTA,483 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9155031 as NRDCONTA,1320 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9169741 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9223851 as NRDCONTA,792.26 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9235442 as NRDCONTA,3572.85 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9287949 as NRDCONTA,665.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9288341 as NRDCONTA,846.39 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9338527 as NRDCONTA,357.33 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9345116 as NRDCONTA,1816 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9347011 as NRDCONTA,1065 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9366555 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9465308 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9480013 as NRDCONTA,1642.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9511733 as NRDCONTA,1363 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9520708 as NRDCONTA,18000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9550364 as NRDCONTA,341 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9591893 as NRDCONTA,3544.8 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9595473 as NRDCONTA,1100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9617035 as NRDCONTA,3300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9672125 as NRDCONTA,990.05 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9686738 as NRDCONTA,2630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9739521 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9739521 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9742611 as NRDCONTA,16000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9742611 as NRDCONTA,16000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9889809 as NRDCONTA,6130 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9889809 as NRDCONTA,7250 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9989820 as NRDCONTA,1240 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10027033 as NRDCONTA,650.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10042903 as NRDCONTA,1010.59 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10061053 as NRDCONTA,900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,5950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3930 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3395 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,560.52 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,2027.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,1576.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10073884 as NRDCONTA,2160 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10237755 as NRDCONTA,8165 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10261770 as NRDCONTA,790 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10297367 as NRDCONTA,3200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10313109 as NRDCONTA,4410 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10356223 as NRDCONTA,9500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10369783 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10477438 as NRDCONTA,2198 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10480285 as NRDCONTA,2434 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10501746 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10590218 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10687467 as NRDCONTA,995 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10729933 as NRDCONTA,1292.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10737049 as NRDCONTA,9900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10737979 as NRDCONTA,1750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10771280 as NRDCONTA,2473.74 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10787437 as NRDCONTA,1223.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10800131 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10805559 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10847197 as NRDCONTA,4969.9 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11098252 as NRDCONTA,750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11107553 as NRDCONTA,12400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11107553 as NRDCONTA,11100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11114347 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,5900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,5900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,12500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11187247 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11393750 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11414537 as NRDCONTA,2049 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11415509 as NRDCONTA,3962.1 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11425385 as NRDCONTA,2203.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11425385 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11508191 as NRDCONTA,3069 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,8351.49 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,13708.22 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11542543 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11564792 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11576324 as NRDCONTA,887.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11606037 as NRDCONTA,2100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11617144 as NRDCONTA,1902 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11649771 as NRDCONTA,2085.7 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11674210 as NRDCONTA,678.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11677627 as NRDCONTA,4900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11697610 as NRDCONTA,1170 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11729112 as NRDCONTA,861.6 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11729392 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,1274 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,2361 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,1695 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11840196 as NRDCONTA,20000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11840196 as NRDCONTA,20000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11880198 as NRDCONTA,260 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11912383 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11957905 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11977248 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12095737 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12130907 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12139793 as NRDCONTA,2586.82 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12139793 as NRDCONTA,1637.51 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12401099 as NRDCONTA,2144.06 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12425001 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12509620 as NRDCONTA,1355 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12525413 as NRDCONTA,1100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12614661 as NRDCONTA,3306 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12848697 as NRDCONTA,550 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12931659 as NRDCONTA,2270 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13067265 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13067265 as NRDCONTA,3923.33 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13136267 as NRDCONTA,1045 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13231103 as NRDCONTA,500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13287397 as NRDCONTA,1964 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13373161 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13664514 as NRDCONTA,620 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13737139 as NRDCONTA,5788 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13994336 as NRDCONTA,788.95 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14167387 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14251957 as NRDCONTA,1799.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14252554 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14252554 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14350378 as NRDCONTA,4774.77 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14371995 as NRDCONTA,2870 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14402076 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14420562 as NRDCONTA,25501.84 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14551390 as NRDCONTA,260 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14628945 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14669919 as NRDCONTA,3700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14717328 as NRDCONTA,2800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14762501 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14763940 as NRDCONTA,4600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14930773 as NRDCONTA,4900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14930773 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15082610 as NRDCONTA,340 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15143104 as NRDCONTA,440 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15156214 as NRDCONTA,3200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15266265 as NRDCONTA,2275 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15340171 as NRDCONTA,8856 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15414809 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15503283 as NRDCONTA,3800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15601773 as NRDCONTA,2233.68 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15603075 as NRDCONTA,6890 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15619494 as NRDCONTA,4582.8 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,1694 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15710807 as NRDCONTA,1300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15718824 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15813703 as NRDCONTA,2920 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15836495 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15844714 as NRDCONTA,340 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15971112 as NRDCONTA,2486 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15994481 as NRDCONTA,150 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15994481 as NRDCONTA,289 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16044746 as NRDCONTA,4600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16050304 as NRDCONTA,2540.24 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16124766 as NRDCONTA,2600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16198263 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16247728 as NRDCONTA,1410 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16275110 as NRDCONTA,1666.48 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16275110 as NRDCONTA,2135 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16353641 as NRDCONTA,3950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16489543 as NRDCONTA,2258 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16501357 as NRDCONTA,3211 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16608712 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16645022 as NRDCONTA,1885 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16680081 as NRDCONTA,1102.4 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16680081 as NRDCONTA,948.03 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,4704.23 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,3889.24 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,3409.67 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16877969 as NRDCONTA,620.83 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16920732 as NRDCONTA,6900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16961609 as NRDCONTA,962.25 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16982720 as NRDCONTA,275 as valor from dual
            union all
SELECT 1 as CDCOOPER, 17213037 as NRDCONTA,7778 as valor from dual
            union all
SELECT 1 as CDCOOPER, 17213037 as NRDCONTA,4354 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,2061.69 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,4395.93 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,2647.07 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,3536 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,4461.75 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1924079 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2441110 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3576728 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3576728 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6668925 as NRDCONTA,1570 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7598394 as NRDCONTA,22397 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8037582 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8290296 as NRDCONTA,3278 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8927472 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8987785 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9441549 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9441549 as NRDCONTA,7700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9708766 as NRDCONTA,2750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9708766 as NRDCONTA,2750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9877673 as NRDCONTA,2779.37 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11928700 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12052760 as NRDCONTA,13580 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12052760 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13192043 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13548336 as NRDCONTA,9230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11166231 as NRDCONTA,4800 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,6000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,3350 as valor from dual
            union all
SELECT 2 as CDCOOPER, 557170 as NRDCONTA,1064 as valor from dual
            union all
SELECT 2 as CDCOOPER, 558915 as NRDCONTA,500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 591220 as NRDCONTA,4798.79 as valor from dual
            union all
SELECT 2 as CDCOOPER, 594644 as NRDCONTA,10200 as valor from dual
            union all
SELECT 2 as CDCOOPER, 594644 as NRDCONTA,9670 as valor from dual
            union all
SELECT 2 as CDCOOPER, 607312 as NRDCONTA,3470 as valor from dual
            union all
SELECT 2 as CDCOOPER, 630098 as NRDCONTA,3439.5 as valor from dual
            union all
SELECT 2 as CDCOOPER, 662372 as NRDCONTA,500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 677973 as NRDCONTA,4677 as valor from dual
            union all
SELECT 2 as CDCOOPER, 680354 as NRDCONTA,1658.47 as valor from dual
            union all
SELECT 2 as CDCOOPER, 680354 as NRDCONTA,1591.13 as valor from dual
            union all
SELECT 2 as CDCOOPER, 689130 as NRDCONTA,25650 as valor from dual
            union all
SELECT 2 as CDCOOPER, 737860 as NRDCONTA,300 as valor from dual
            union all
SELECT 2 as CDCOOPER, 756571 as NRDCONTA,10000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 764442 as NRDCONTA,1729 as valor from dual
            union all
SELECT 2 as CDCOOPER, 769037 as NRDCONTA,957 as valor from dual
            union all
SELECT 2 as CDCOOPER, 769320 as NRDCONTA,1500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 779920 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 805009 as NRDCONTA,1500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 821152 as NRDCONTA,2268 as valor from dual
            union all
SELECT 2 as CDCOOPER, 839493 as NRDCONTA,7120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 839493 as NRDCONTA,4000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 840432 as NRDCONTA,1358.97 as valor from dual
            union all
SELECT 2 as CDCOOPER, 847763 as NRDCONTA,8500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 862240 as NRDCONTA,2000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 871168 as NRDCONTA,1114.5 as valor from dual
            union all
SELECT 2 as CDCOOPER, 872563 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 897680 as NRDCONTA,4710 as valor from dual
            union all
SELECT 2 as CDCOOPER, 910210 as NRDCONTA,10000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 910210 as NRDCONTA,20000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 938661 as NRDCONTA,1125.26 as valor from dual
            union all
SELECT 2 as CDCOOPER, 989118 as NRDCONTA,15000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 990434 as NRDCONTA,1182 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1011383 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1057871 as NRDCONTA,14383.33 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1057871 as NRDCONTA,19573.25 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1067699 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1076140 as NRDCONTA,825 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1090461 as NRDCONTA,635 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1101641 as NRDCONTA,8100 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1106376 as NRDCONTA,3225 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1185713 as NRDCONTA,575 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15091805 as NRDCONTA,5830 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333000 as NRDCONTA,2725 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333639 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,2500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,1000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,1200 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,4990 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,4990 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,2500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15803600 as NRDCONTA,2698.2 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333000 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 50067 as NRDCONTA,696.56 as valor from dual
            union all
SELECT 5 as CDCOOPER, 105678 as NRDCONTA,575 as valor from dual
            union all
SELECT 5 as CDCOOPER, 112577 as NRDCONTA,960 as valor from dual
            union all
SELECT 5 as CDCOOPER, 112577 as NRDCONTA,575 as valor from dual
            union all
SELECT 5 as CDCOOPER, 127612 as NRDCONTA,732 as valor from dual
            union all
SELECT 5 as CDCOOPER, 127612 as NRDCONTA,640 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144738 as NRDCONTA,4990 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144738 as NRDCONTA,4990 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144762 as NRDCONTA,6700 as valor from dual
            union all
SELECT 5 as CDCOOPER, 147265 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 148270 as NRDCONTA,800 as valor from dual
            union all
SELECT 5 as CDCOOPER, 156019 as NRDCONTA,1498.07 as valor from dual
            union all
SELECT 5 as CDCOOPER, 185558 as NRDCONTA,4842 as valor from dual
            union all
SELECT 5 as CDCOOPER, 211338 as NRDCONTA,1000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,7474 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,5978.66 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,3650 as valor from dual
            union all
SELECT 5 as CDCOOPER, 231525 as NRDCONTA,7000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 243124 as NRDCONTA,2050 as valor from dual
            union all
SELECT 5 as CDCOOPER, 255068 as NRDCONTA,2500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 261939 as NRDCONTA,890 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4800 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4897 as valor from dual
            union all
SELECT 5 as CDCOOPER, 289078 as NRDCONTA,1500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 295329 as NRDCONTA,1087 as valor from dual
            union all
SELECT 5 as CDCOOPER, 295434 as NRDCONTA,4200 as valor from dual
            union all
SELECT 5 as CDCOOPER, 311863 as NRDCONTA,5712.23 as valor from dual
            union all
SELECT 5 as CDCOOPER, 315958 as NRDCONTA,27450 as valor from dual
            union all
SELECT 5 as CDCOOPER, 328626 as NRDCONTA,3000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,3398 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354651 as NRDCONTA,2000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 357987 as NRDCONTA,4995 as valor from dual
            union all
SELECT 5 as CDCOOPER, 361186 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 364185 as NRDCONTA,6139.77 as valor from dual
            union all
SELECT 5 as CDCOOPER, 14752522 as NRDCONTA,13350 as valor from dual
            union all
SELECT 5 as CDCOOPER, 14907666 as NRDCONTA,2000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15513033 as NRDCONTA,1400 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15513033 as NRDCONTA,1751.6 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15601218 as NRDCONTA,3413 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15997510 as NRDCONTA,572 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,21295.05 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16074998 as NRDCONTA,2300 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16467787 as NRDCONTA,4832.75 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16467787 as NRDCONTA,4832.75 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16522230 as NRDCONTA,4000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16789229 as NRDCONTA,190 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16877780 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16877780 as NRDCONTA,4240 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16957083 as NRDCONTA,3260 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16957083 as NRDCONTA,4000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17049946 as NRDCONTA,500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17220270 as NRDCONTA,5100 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17346088 as NRDCONTA,5550 as valor from dual
            union all
SELECT 5 as CDCOOPER, 114600 as NRDCONTA,3000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 135542 as NRDCONTA,2434.52 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,4050 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 358266 as NRDCONTA,1000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 368377 as NRDCONTA,1250 as valor from dual
            union all
SELECT 6 as CDCOOPER, 10448 as NRDCONTA,4510.58 as valor from dual
            union all
SELECT 6 as CDCOOPER, 39713 as NRDCONTA,2750 as valor from dual
            union all
SELECT 6 as CDCOOPER, 59960 as NRDCONTA,11000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 148067 as NRDCONTA,2000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 172863 as NRDCONTA,20000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 172863 as NRDCONTA,5000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 195944 as NRDCONTA,2887 as valor from dual
            union all
SELECT 6 as CDCOOPER, 201553 as NRDCONTA,5430 as valor from dual
            union all
SELECT 6 as CDCOOPER, 201650 as NRDCONTA,7059 as valor from dual
            union all
SELECT 6 as CDCOOPER, 217743 as NRDCONTA,4684 as valor from dual
            union all
SELECT 6 as CDCOOPER, 224359 as NRDCONTA,5861.6 as valor from dual
            union all
SELECT 6 as CDCOOPER, 224359 as NRDCONTA,2255.82 as valor from dual
            union all
SELECT 6 as CDCOOPER, 249246 as NRDCONTA,3000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 505978 as NRDCONTA,2314.32 as valor from dual
            union all
SELECT 6 as CDCOOPER, 14920441 as NRDCONTA,4100 as valor from dual
            union all
SELECT 7 as CDCOOPER, 46493 as NRDCONTA,2264 as valor from dual
            union all
SELECT 7 as CDCOOPER, 46493 as NRDCONTA,3750 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194565 as NRDCONTA,1861.06 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194565 as NRDCONTA,1608 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194603 as NRDCONTA,1696 as valor from dual
            union all
SELECT 7 as CDCOOPER, 229555 as NRDCONTA,2000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 252751 as NRDCONTA,6000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 317969 as NRDCONTA,3286 as valor from dual
            union all
SELECT 7 as CDCOOPER, 317969 as NRDCONTA,4600 as valor from dual
            union all
SELECT 7 as CDCOOPER, 324892 as NRDCONTA,1100 as valor from dual
            union all
SELECT 7 as CDCOOPER, 325368 as NRDCONTA,6600 as valor from dual
            union all
SELECT 7 as CDCOOPER, 391166 as NRDCONTA,654 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,2874 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,3179.46 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,3361 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,2930 as valor from dual
            union all
SELECT 7 as CDCOOPER, 414476 as NRDCONTA,8000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 414786 as NRDCONTA,1900 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15696880 as NRDCONTA,1145 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15711080 as NRDCONTA,6000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15711080 as NRDCONTA,1000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16137949 as NRDCONTA,2500 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16145232 as NRDCONTA,2000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16899610 as NRDCONTA,4000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 17529174 as NRDCONTA,3000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 417882 as NRDCONTA,31250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,4871.25 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,4964.44 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 14877 as NRDCONTA,2940.91 as valor from dual
            union all
SELECT 9 as CDCOOPER, 51837 as NRDCONTA,7000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 62332 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 148792 as NRDCONTA,4469.79 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,10962.01 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,10795.88 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,11795.3 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,13765 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,11550.16 as valor from dual
            union all
SELECT 9 as CDCOOPER, 177334 as NRDCONTA,707.52 as valor from dual
            union all
SELECT 9 as CDCOOPER, 177342 as NRDCONTA,1556.17 as valor from dual
            union all
SELECT 9 as CDCOOPER, 179639 as NRDCONTA,3200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 187046 as NRDCONTA,280 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,850 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,650 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1300 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1050 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 193275 as NRDCONTA,900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 195782 as NRDCONTA,5395 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224405 as NRDCONTA,1500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224413 as NRDCONTA,309.72 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224413 as NRDCONTA,884.31 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224693 as NRDCONTA,3524 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224693 as NRDCONTA,3910 as valor from dual
            union all
SELECT 9 as CDCOOPER, 234826 as NRDCONTA,6000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 242268 as NRDCONTA,6000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 245070 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 247332 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 247332 as NRDCONTA,750 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258695 as NRDCONTA,1016 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258725 as NRDCONTA,1281.15 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258725 as NRDCONTA,1539 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,9990 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,8800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 286486 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 288241 as NRDCONTA,950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 289604 as NRDCONTA,10854.4 as valor from dual
            union all
SELECT 9 as CDCOOPER, 293970 as NRDCONTA,4500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309605 as NRDCONTA,4400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309605 as NRDCONTA,4998 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4700 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4999 as valor from dual
            union all
SELECT 9 as CDCOOPER, 314404 as NRDCONTA,3980 as valor from dual
            union all
SELECT 9 as CDCOOPER, 314404 as NRDCONTA,3500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 322857 as NRDCONTA,4000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 326909 as NRDCONTA,2160 as valor from dual
            union all
SELECT 9 as CDCOOPER, 329908 as NRDCONTA,825 as valor from dual
            union all
SELECT 9 as CDCOOPER, 329932 as NRDCONTA,250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,30000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,637 as valor from dual
            union all
SELECT 9 as CDCOOPER, 341231 as NRDCONTA,820 as valor from dual
            union all
SELECT 9 as CDCOOPER, 363880 as NRDCONTA,720 as valor from dual
            union all
SELECT 9 as CDCOOPER, 363880 as NRDCONTA,2920 as valor from dual
            union all
SELECT 9 as CDCOOPER, 370932 as NRDCONTA,543.6 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2550 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2550 as valor from dual
            union all
SELECT 9 as CDCOOPER, 385557 as NRDCONTA,3900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 402559 as NRDCONTA,3660 as valor from dual
            union all
SELECT 9 as CDCOOPER, 407178 as NRDCONTA,1250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 407178 as NRDCONTA,1950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,15542 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,18275 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,6174.25 as valor from dual
            union all
SELECT 9 as CDCOOPER, 424951 as NRDCONTA,1897 as valor from dual
            union all
SELECT 9 as CDCOOPER, 435201 as NRDCONTA,6825.65 as valor from dual
            union all
SELECT 9 as CDCOOPER, 439231 as NRDCONTA,4582.04 as valor from dual
            union all
SELECT 9 as CDCOOPER, 439231 as NRDCONTA,4990 as valor from dual
            union all
SELECT 9 as CDCOOPER, 442801 as NRDCONTA,6500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 445037 as NRDCONTA,5129 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446106 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446106 as NRDCONTA,2800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446157 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 462128 as NRDCONTA,3287.81 as valor from dual
            union all
SELECT 9 as CDCOOPER, 462128 as NRDCONTA,1725 as valor from dual
            union all
SELECT 9 as CDCOOPER, 470996 as NRDCONTA,4625 as valor from dual
            union all
SELECT 9 as CDCOOPER, 542903 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 547069 as NRDCONTA,3300 as valor from dual
            union all
SELECT 9 as CDCOOPER, 553719 as NRDCONTA,1380 as valor from dual
            union all
SELECT 9 as CDCOOPER, 557129 as NRDCONTA,37123.86 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048624 as NRDCONTA,2654 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048853 as NRDCONTA,1470 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048853 as NRDCONTA,4332 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15288323 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15288323 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,4290 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,3262 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,683.35 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15557316 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15590860 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 16264959 as NRDCONTA,1210 as valor from dual
            union all
SELECT 9 as CDCOOPER, 211893 as NRDCONTA,1415 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,10000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,23333.33 as valor from dual
            union all
SELECT 9 as CDCOOPER, 361216 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 443956 as NRDCONTA,3670 as valor from dual
            union all
SELECT 10 as CDCOOPER, 752 as NRDCONTA,8810.29 as valor from dual
            union all
SELECT 10 as CDCOOPER, 1600 as NRDCONTA,1712.72 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,8137.8 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,8294.4 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,6000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 20265 as NRDCONTA,1439 as valor from dual
            union all
SELECT 10 as CDCOOPER, 29076 as NRDCONTA,631 as valor from dual
            union all
SELECT 10 as CDCOOPER, 41084 as NRDCONTA,2800 as valor from dual
            union all
SELECT 10 as CDCOOPER, 42765 as NRDCONTA,1119.49 as valor from dual
            union all
SELECT 10 as CDCOOPER, 43486 as NRDCONTA,3600 as valor from dual
            union all
SELECT 10 as CDCOOPER, 57223 as NRDCONTA,1270 as valor from dual
            union all
SELECT 10 as CDCOOPER, 66524 as NRDCONTA,602 as valor from dual
            union all
SELECT 10 as CDCOOPER, 88463 as NRDCONTA,710 as valor from dual
            union all
SELECT 10 as CDCOOPER, 91901 as NRDCONTA,765 as valor from dual
            union all
SELECT 10 as CDCOOPER, 91901 as NRDCONTA,847 as valor from dual
            union all
SELECT 10 as CDCOOPER, 118001 as NRDCONTA,8000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 127159 as NRDCONTA,696.69 as valor from dual
            union all
SELECT 10 as CDCOOPER, 170844 as NRDCONTA,10500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 171816 as NRDCONTA,14500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 177946 as NRDCONTA,35000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 186856 as NRDCONTA,16500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 187054 as NRDCONTA,6175 as valor from dual
            union all
SELECT 10 as CDCOOPER, 187054 as NRDCONTA,2480 as valor from dual
            union all
SELECT 10 as CDCOOPER, 193712 as NRDCONTA,3000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 200506 as NRDCONTA,5465 as valor from dual
            union all
SELECT 10 as CDCOOPER, 213128 as NRDCONTA,1227.01 as valor from dual
            union all
SELECT 10 as CDCOOPER, 213128 as NRDCONTA,587 as valor from dual
            union all
SELECT 10 as CDCOOPER, 215082 as NRDCONTA,3500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,17000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,2500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,15000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 15990460 as NRDCONTA,710 as valor from dual
            union all
SELECT 10 as CDCOOPER, 15990460 as NRDCONTA,745 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16590937 as NRDCONTA,900 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16670566 as NRDCONTA,900 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16859430 as NRDCONTA,2742 as valor from dual
            union all
SELECT 10 as CDCOOPER, 25542 as NRDCONTA,20000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 5215 as NRDCONTA,594 as valor from dual
            union all
SELECT 11 as CDCOOPER, 52825 as NRDCONTA,1528 as valor from dual
            union all
SELECT 11 as CDCOOPER, 52825 as NRDCONTA,1328 as valor from dual
            union all
SELECT 11 as CDCOOPER, 93785 as NRDCONTA,1363.58 as valor from dual
            union all
SELECT 11 as CDCOOPER, 94137 as NRDCONTA,615 as valor from dual
            union all
SELECT 11 as CDCOOPER, 138894 as NRDCONTA,1241.86 as valor from dual
            union all
SELECT 11 as CDCOOPER, 142182 as NRDCONTA,4990 as valor from dual
            union all
SELECT 11 as CDCOOPER, 180017 as NRDCONTA,660 as valor from dual
            union all
SELECT 11 as CDCOOPER, 185680 as NRDCONTA,3329 as valor from dual
            union all
SELECT 11 as CDCOOPER, 185680 as NRDCONTA,5082.76 as valor from dual
            union all
SELECT 11 as CDCOOPER, 203955 as NRDCONTA,1735 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4420 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4420 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4730 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4730 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,3220 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4800 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4900 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4065.52 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4700 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4639.2 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4680 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4680 as valor from dual
            union all
SELECT 11 as CDCOOPER, 375810 as NRDCONTA,5300 as valor from dual
            union all
SELECT 11 as CDCOOPER, 380474 as NRDCONTA,14000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 409880 as NRDCONTA,330 as valor from dual
            union all
SELECT 11 as CDCOOPER, 495220 as NRDCONTA,1400 as valor from dual
            union all
SELECT 11 as CDCOOPER, 499625 as NRDCONTA,3196.54 as valor from dual
            union all
SELECT 11 as CDCOOPER, 530670 as NRDCONTA,1750 as valor from dual
            union all
SELECT 11 as CDCOOPER, 547166 as NRDCONTA,1700 as valor from dual
            union all
SELECT 11 as CDCOOPER, 547166 as NRDCONTA,4500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 576654 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 583081 as NRDCONTA,443 as valor from dual
            union all
SELECT 11 as CDCOOPER, 621595 as NRDCONTA,3000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 637688 as NRDCONTA,1588 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,1350 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,681.1 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4024 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 671363 as NRDCONTA,1008 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,1631.25 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,2263.31 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,2040 as valor from dual
            union all
SELECT 11 as CDCOOPER, 703338 as NRDCONTA,15270 as valor from dual
            union all
SELECT 11 as CDCOOPER, 708135 as NRDCONTA,1834 as valor from dual
            union all
SELECT 11 as CDCOOPER, 717800 as NRDCONTA,6061.16 as valor from dual
            union all
SELECT 11 as CDCOOPER, 717800 as NRDCONTA,4245.3 as valor from dual
            union all
SELECT 11 as CDCOOPER, 729400 as NRDCONTA,1500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 734136 as NRDCONTA,1446 as valor from dual
            union all
SELECT 11 as CDCOOPER, 745928 as NRDCONTA,7000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 750581 as NRDCONTA,7500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 753874 as NRDCONTA,8675 as valor from dual
            union all
SELECT 11 as CDCOOPER, 753874 as NRDCONTA,27438 as valor from dual
            union all
SELECT 11 as CDCOOPER, 758698 as NRDCONTA,10000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 789836 as NRDCONTA,11000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 812633 as NRDCONTA,9872 as valor from dual
            union all
SELECT 11 as CDCOOPER, 834319 as NRDCONTA,6400 as valor from dual
            union all
SELECT 11 as CDCOOPER, 893188 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 925713 as NRDCONTA,5000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 954535 as NRDCONTA,43850 as valor from dual
            union all
SELECT 11 as CDCOOPER, 957933 as NRDCONTA,20000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 978850 as NRDCONTA,5000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 988260 as NRDCONTA,7000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 1005863 as NRDCONTA,4600 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14497727 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14497727 as NRDCONTA,4789.25 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14687534 as NRDCONTA,1200 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14687534 as NRDCONTA,693.58 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14695898 as NRDCONTA,2879.97 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15630951 as NRDCONTA,1671 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16114086 as NRDCONTA,6250 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16223110 as NRDCONTA,1474.5 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16344502 as NRDCONTA,683 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16372441 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16805755 as NRDCONTA,1450 as valor from dual
            union all
SELECT 11 as CDCOOPER, 233390 as NRDCONTA,630.3 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16932617 as NRDCONTA,7500 as valor from dual
            union all
SELECT 12 as CDCOOPER, 6106 as NRDCONTA,9000 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,985 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,1831.88 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,1831.88 as valor from dual
            union all
SELECT 12 as CDCOOPER, 30147 as NRDCONTA,4465 as valor from dual
            union all
SELECT 12 as CDCOOPER, 77968 as NRDCONTA,1650 as valor from dual
            union all
SELECT 12 as CDCOOPER, 137952 as NRDCONTA,3826.8 as valor from dual
            union all
SELECT 12 as CDCOOPER, 204838 as NRDCONTA,200 as valor from dual
            union all
SELECT 12 as CDCOOPER, 16226208 as NRDCONTA,1750 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17011043 as NRDCONTA,2325 as valor from dual
            union all
SELECT 12 as CDCOOPER, 86940 as NRDCONTA,9793 as valor from dual
            union all
SELECT 13 as CDCOOPER, 117625 as NRDCONTA,400 as valor from dual
            union all
SELECT 13 as CDCOOPER, 118753 as NRDCONTA,328 as valor from dual
            union all
SELECT 13 as CDCOOPER, 131393 as NRDCONTA,1034 as valor from dual
            union all
SELECT 13 as CDCOOPER, 134287 as NRDCONTA,3800 as valor from dual
            union all
SELECT 13 as CDCOOPER, 161845 as NRDCONTA,1000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 165980 as NRDCONTA,698 as valor from dual
            union all
SELECT 13 as CDCOOPER, 166057 as NRDCONTA,100000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 273139 as NRDCONTA,3624 as valor from dual
            union all
SELECT 13 as CDCOOPER, 293938 as NRDCONTA,589.46 as valor from dual
            union all
SELECT 13 as CDCOOPER, 302732 as NRDCONTA,1550 as valor from dual
            union all
SELECT 13 as CDCOOPER, 326135 as NRDCONTA,1250 as valor from dual
            union all
SELECT 13 as CDCOOPER, 337226 as NRDCONTA,1038 as valor from dual
            union all
SELECT 13 as CDCOOPER, 338737 as NRDCONTA,7252 as valor from dual
            union all
SELECT 13 as CDCOOPER, 396168 as NRDCONTA,15000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 404845 as NRDCONTA,384 as valor from dual
            union all
SELECT 13 as CDCOOPER, 430145 as NRDCONTA,9096 as valor from dual
            union all
SELECT 13 as CDCOOPER, 440914 as NRDCONTA,6000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 480304 as NRDCONTA,4000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 488836 as NRDCONTA,3180 as valor from dual
            union all
SELECT 13 as CDCOOPER, 541427 as NRDCONTA,2482.46 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,5500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,5500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,9424 as valor from dual
            union all
SELECT 13 as CDCOOPER, 583464 as NRDCONTA,4000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 583715 as NRDCONTA,12200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 603430 as NRDCONTA,2180 as valor from dual
            union all
SELECT 13 as CDCOOPER, 623130 as NRDCONTA,1000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 644870 as NRDCONTA,7200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 644870 as NRDCONTA,7200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 669440 as NRDCONTA,950 as valor from dual
            union all
SELECT 13 as CDCOOPER, 669440 as NRDCONTA,1170 as valor from dual
            union all
SELECT 13 as CDCOOPER, 670570 as NRDCONTA,12000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 675687 as NRDCONTA,3286 as valor from dual
            union all
SELECT 13 as CDCOOPER, 722308 as NRDCONTA,680 as valor from dual
            union all
SELECT 13 as CDCOOPER, 722308 as NRDCONTA,535 as valor from dual
            union all
SELECT 13 as CDCOOPER, 735167 as NRDCONTA,407 as valor from dual
            union all
SELECT 13 as CDCOOPER, 15150933 as NRDCONTA,816 as valor from dual
            union all
SELECT 13 as CDCOOPER, 15547671 as NRDCONTA,3666 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16039920 as NRDCONTA,1534 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16697987 as NRDCONTA,1800 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16813391 as NRDCONTA,1500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 17354862 as NRDCONTA,15000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 242888 as NRDCONTA,2673 as valor from dual
            union all
SELECT 13 as CDCOOPER, 596698 as NRDCONTA,1000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17833 as NRDCONTA,7000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20060 as NRDCONTA,1000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20915 as NRDCONTA,8950 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20915 as NRDCONTA,8697 as valor from dual
            union all
SELECT 14 as CDCOOPER, 34070 as NRDCONTA,4800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 38156 as NRDCONTA,500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 42889 as NRDCONTA,1300 as valor from dual
            union all
SELECT 14 as CDCOOPER, 42919 as NRDCONTA,2000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 47155 as NRDCONTA,5500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 53597 as NRDCONTA,9000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 62642 as NRDCONTA,7000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 69876 as NRDCONTA,16800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 87068 as NRDCONTA,2500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 111120 as NRDCONTA,170 as valor from dual
            union all
SELECT 14 as CDCOOPER, 114545 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 116807 as NRDCONTA,2500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 128597 as NRDCONTA,4081 as valor from dual
            union all
SELECT 14 as CDCOOPER, 132020 as NRDCONTA,516 as valor from dual
            union all
SELECT 14 as CDCOOPER, 137669 as NRDCONTA,10322 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146293 as NRDCONTA,1414 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146439 as NRDCONTA,1878 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146897 as NRDCONTA,9598 as valor from dual
            union all
SELECT 14 as CDCOOPER, 157325 as NRDCONTA,1500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 175269 as NRDCONTA,3000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 190497 as NRDCONTA,4000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 194611 as NRDCONTA,3355 as valor from dual
            union all
SELECT 14 as CDCOOPER, 255947 as NRDCONTA,1225 as valor from dual
            union all
SELECT 14 as CDCOOPER, 259934 as NRDCONTA,766 as valor from dual
            union all
SELECT 14 as CDCOOPER, 268020 as NRDCONTA,1213 as valor from dual
            union all
SELECT 14 as CDCOOPER, 268160 as NRDCONTA,3840 as valor from dual
            union all
SELECT 14 as CDCOOPER, 269336 as NRDCONTA,120 as valor from dual
            union all
SELECT 14 as CDCOOPER, 272892 as NRDCONTA,2100 as valor from dual
            union all
SELECT 14 as CDCOOPER, 315877 as NRDCONTA,438 as valor from dual
            union all
SELECT 14 as CDCOOPER, 322032 as NRDCONTA,494.93 as valor from dual
            union all
SELECT 14 as CDCOOPER, 336513 as NRDCONTA,4338 as valor from dual
            union all
SELECT 14 as CDCOOPER, 343994 as NRDCONTA,25000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 346128 as NRDCONTA,470 as valor from dual
            union all
SELECT 14 as CDCOOPER, 365777 as NRDCONTA,3505 as valor from dual
            union all
SELECT 14 as CDCOOPER, 386693 as NRDCONTA,2406.77 as valor from dual
            union all
SELECT 14 as CDCOOPER, 396036 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 396117 as NRDCONTA,970.18 as valor from dual
            union all
SELECT 14 as CDCOOPER, 398586 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 398586 as NRDCONTA,3000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 403920 as NRDCONTA,2000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 403920 as NRDCONTA,2200 as valor from dual
            union all
SELECT 14 as CDCOOPER, 404381 as NRDCONTA,15707.85 as valor from dual
            union all
SELECT 14 as CDCOOPER, 14990520 as NRDCONTA,713.2 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15317757 as NRDCONTA,866 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15423913 as NRDCONTA,12400 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15523152 as NRDCONTA,1500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15596419 as NRDCONTA,10000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15597237 as NRDCONTA,1250 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15660532 as NRDCONTA,1416 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15777294 as NRDCONTA,192.25 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15795322 as NRDCONTA,2250 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16199065 as NRDCONTA,1260 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16215770 as NRDCONTA,3800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16802357 as NRDCONTA,8000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16813820 as NRDCONTA,331.98 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16982118 as NRDCONTA,1050 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17124867 as NRDCONTA,3300 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17316430 as NRDCONTA,17916.25 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17316430 as NRDCONTA,10500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17342880 as NRDCONTA,500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 35521 as NRDCONTA,30000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 46361 as NRDCONTA,749.31 as valor from dual
            union all
SELECT 16 as CDCOOPER, 47422 as NRDCONTA,3690 as valor from dual
            union all
SELECT 16 as CDCOOPER, 53023 as NRDCONTA,1000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 58157 as NRDCONTA,4165 as valor from dual
            union all
SELECT 16 as CDCOOPER, 145912 as NRDCONTA,505 as valor from dual
            union all
SELECT 16 as CDCOOPER, 185434 as NRDCONTA,3849.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 221376 as NRDCONTA,425.25 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,4987 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,9000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,6632 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,4788 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,1320 as valor from dual
            union all
SELECT 16 as CDCOOPER, 269964 as NRDCONTA,402.48 as valor from dual
            union all
SELECT 16 as CDCOOPER, 292818 as NRDCONTA,645.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 311170 as NRDCONTA,5000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 350664 as NRDCONTA,300 as valor from dual
            union all
SELECT 16 as CDCOOPER, 390569 as NRDCONTA,6955 as valor from dual
            union all
SELECT 16 as CDCOOPER, 403520 as NRDCONTA,38500 as valor from dual
            union all
SELECT 16 as CDCOOPER, 450294 as NRDCONTA,480 as valor from dual
            union all
SELECT 16 as CDCOOPER, 482269 as NRDCONTA,3000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 551724 as NRDCONTA,5000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 567566 as NRDCONTA,570 as valor from dual
            union all
SELECT 16 as CDCOOPER, 580104 as NRDCONTA,2865.09 as valor from dual
            union all
SELECT 16 as CDCOOPER, 605174 as NRDCONTA,362.2 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,978.2 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,1660 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,1600 as valor from dual
            union all
SELECT 16 as CDCOOPER, 705144 as NRDCONTA,350 as valor from dual
            union all
SELECT 16 as CDCOOPER, 762466 as NRDCONTA,2100 as valor from dual
            union all
SELECT 16 as CDCOOPER, 784478 as NRDCONTA,1732 as valor from dual
            union all
SELECT 16 as CDCOOPER, 866644 as NRDCONTA,4800 as valor from dual
            union all
SELECT 16 as CDCOOPER, 867969 as NRDCONTA,287.13 as valor from dual
            union all
SELECT 16 as CDCOOPER, 871591 as NRDCONTA,280 as valor from dual
            union all
SELECT 16 as CDCOOPER, 894540 as NRDCONTA,1361 as valor from dual
            union all
SELECT 16 as CDCOOPER, 922501 as NRDCONTA,200 as valor from dual
            union all
SELECT 16 as CDCOOPER, 931756 as NRDCONTA,85 as valor from dual
            union all
SELECT 16 as CDCOOPER, 941980 as NRDCONTA,1561 as valor from dual
            union all
SELECT 16 as CDCOOPER, 950521 as NRDCONTA,849 as valor from dual
            union all
SELECT 16 as CDCOOPER, 1013980 as NRDCONTA,6990 as valor from dual
            union all
SELECT 16 as CDCOOPER, 1072579 as NRDCONTA,239.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 3899420 as NRDCONTA,1079 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6033458 as NRDCONTA,2000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6096484 as NRDCONTA,1000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15414477 as NRDCONTA,834 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,1950 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,5952 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,12900 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16085744 as NRDCONTA,3212.5 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16255607 as NRDCONTA,3658.79 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16255607 as NRDCONTA,1626 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16695054 as NRDCONTA,976 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6641890 as NRDCONTA,3250 as valor from dual
			) contas
			
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor, contas.cdcooper
      from CECRED.crapsda a
          ,(
            
SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9240 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9239 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1515187 as NRDCONTA,9239 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16446 as NRDCONTA,1600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 923591 as NRDCONTA,2128.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 923591 as NRDCONTA,2339.78 as valor from dual
            union all
SELECT 1 as CDCOOPER, 941336 as NRDCONTA,1485.83 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2020599 as NRDCONTA,5950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2070731 as NRDCONTA,3700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2155060 as NRDCONTA,8000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2196700 as NRDCONTA,2287 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2212560 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2261375 as NRDCONTA,156 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2631504 as NRDCONTA,1967.05 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2837811 as NRDCONTA,12700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2943468 as NRDCONTA,1158.45 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2998386 as NRDCONTA,1300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3527662 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3567702 as NRDCONTA,3757 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3616177 as NRDCONTA,591.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3653854 as NRDCONTA,797.27 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3662667 as NRDCONTA,106.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3770001 as NRDCONTA,30161 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3812634 as NRDCONTA,1380 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3818276 as NRDCONTA,1505.58 as valor from dual
            union all
SELECT 1 as CDCOOPER, 4068718 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6058558 as NRDCONTA,2600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6058558 as NRDCONTA,3725.75 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,1883 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,2815 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6092411 as NRDCONTA,3085 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6130380 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6147895 as NRDCONTA,1472.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6168540 as NRDCONTA,297.85 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6168540 as NRDCONTA,200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6172148 as NRDCONTA,11877.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6207189 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6354971 as NRDCONTA,675 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6406955 as NRDCONTA,1236.98 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6409270 as NRDCONTA,350 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6458157 as NRDCONTA,843 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6462774 as NRDCONTA,524.81 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6486649 as NRDCONTA,2370 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6599680 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6662463 as NRDCONTA,325 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6715907 as NRDCONTA,1466 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6808352 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6824447 as NRDCONTA,700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6861989 as NRDCONTA,1230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6871488 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6900968 as NRDCONTA,6663.6 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7075006 as NRDCONTA,948.54 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7145250 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7165242 as NRDCONTA,313 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7168004 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7210612 as NRDCONTA,1750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7218575 as NRDCONTA,2688 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7244436 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7285671 as NRDCONTA,614.29 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7355580 as NRDCONTA,11891.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7355947 as NRDCONTA,811.56 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7366531 as NRDCONTA,1747 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7399332 as NRDCONTA,8500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7456727 as NRDCONTA,6750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7466854 as NRDCONTA,3900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7476850 as NRDCONTA,364.3 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,6600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7505973 as NRDCONTA,400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7531052 as NRDCONTA,3290 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7549636 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7570252 as NRDCONTA,12000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7570252 as NRDCONTA,15120 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7581688 as NRDCONTA,5693.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7590520 as NRDCONTA,550 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7624310 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7627564 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7638990 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7641370 as NRDCONTA,1003.65 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7974256 as NRDCONTA,1605 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8012520 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8047189 as NRDCONTA,5097.9 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8064652 as NRDCONTA,2940 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8097038 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8097038 as NRDCONTA,667 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8240310 as NRDCONTA,880 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8261474 as NRDCONTA,5630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8309655 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8362327 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8362327 as NRDCONTA,14051 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8400822 as NRDCONTA,500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8446490 as NRDCONTA,4397.21 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8451842 as NRDCONTA,700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8533539 as NRDCONTA,3094 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8553521 as NRDCONTA,13000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8595542 as NRDCONTA,2200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8753440 as NRDCONTA,726.96 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8776652 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8790167 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8927472 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9006354 as NRDCONTA,400.7 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3676.68 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,4999.99 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9040471 as NRDCONTA,3630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9101810 as NRDCONTA,1230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111387 as NRDCONTA,2807 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111581 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111581 as NRDCONTA,11000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9111654 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9134662 as NRDCONTA,6500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9134794 as NRDCONTA,7675 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9138609 as NRDCONTA,483 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9155031 as NRDCONTA,1320 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9169741 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9223851 as NRDCONTA,792.26 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9235442 as NRDCONTA,3572.85 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9287949 as NRDCONTA,665.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9288341 as NRDCONTA,846.39 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9338527 as NRDCONTA,357.33 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9345116 as NRDCONTA,1816 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9347011 as NRDCONTA,1065 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9366555 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9465308 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9480013 as NRDCONTA,1642.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9511733 as NRDCONTA,1363 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9520708 as NRDCONTA,18000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9550364 as NRDCONTA,341 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9591893 as NRDCONTA,3544.8 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9595473 as NRDCONTA,1100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9617035 as NRDCONTA,3300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9672125 as NRDCONTA,990.05 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9686738 as NRDCONTA,2630 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9739521 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9739521 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9742611 as NRDCONTA,16000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9742611 as NRDCONTA,16000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9889809 as NRDCONTA,6130 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9889809 as NRDCONTA,7250 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9989820 as NRDCONTA,1240 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10027033 as NRDCONTA,650.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10042903 as NRDCONTA,1010.59 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10061053 as NRDCONTA,900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,5950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3930 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10063374 as NRDCONTA,3395 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,560.52 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,2027.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10067175 as NRDCONTA,1576.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10073884 as NRDCONTA,2160 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10237755 as NRDCONTA,8165 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10261770 as NRDCONTA,790 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10297367 as NRDCONTA,3200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10313109 as NRDCONTA,4410 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10356223 as NRDCONTA,9500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10369783 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10477438 as NRDCONTA,2198 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10480285 as NRDCONTA,2434 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10501746 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10590218 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10687467 as NRDCONTA,995 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10729933 as NRDCONTA,1292.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10737049 as NRDCONTA,9900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10737979 as NRDCONTA,1750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10771280 as NRDCONTA,2473.74 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10787437 as NRDCONTA,1223.31 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10800131 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10805559 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 10847197 as NRDCONTA,4969.9 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11098252 as NRDCONTA,750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11107553 as NRDCONTA,12400 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11107553 as NRDCONTA,11100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11114347 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,5900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,5900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11163810 as NRDCONTA,12500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11187247 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11393750 as NRDCONTA,4000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11414537 as NRDCONTA,2049 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11415509 as NRDCONTA,3962.1 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11425385 as NRDCONTA,2203.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11425385 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11508191 as NRDCONTA,3069 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,8351.49 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,6000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11534974 as NRDCONTA,13708.22 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11542543 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11564792 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11576324 as NRDCONTA,887.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11606037 as NRDCONTA,2100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11617144 as NRDCONTA,1902 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11649771 as NRDCONTA,2085.7 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11674210 as NRDCONTA,678.5 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11677627 as NRDCONTA,4900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11697610 as NRDCONTA,1170 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11729112 as NRDCONTA,861.6 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11729392 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,1274 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,2361 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11744235 as NRDCONTA,1695 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11840196 as NRDCONTA,20000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11840196 as NRDCONTA,20000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11880198 as NRDCONTA,260 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11912383 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11957905 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11977248 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12095737 as NRDCONTA,3500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12130907 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12139793 as NRDCONTA,2586.82 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12139793 as NRDCONTA,1637.51 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12401099 as NRDCONTA,2144.06 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12425001 as NRDCONTA,1000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12509620 as NRDCONTA,1355 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12525413 as NRDCONTA,1100 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12614661 as NRDCONTA,3306 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12848697 as NRDCONTA,550 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12931659 as NRDCONTA,2270 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13067265 as NRDCONTA,4999 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13067265 as NRDCONTA,3923.33 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13136267 as NRDCONTA,1045 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13231103 as NRDCONTA,500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13287397 as NRDCONTA,1964 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13373161 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13664514 as NRDCONTA,620 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13737139 as NRDCONTA,5788 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13994336 as NRDCONTA,788.95 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14167387 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14251957 as NRDCONTA,1799.2 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14252554 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14252554 as NRDCONTA,4990 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14350378 as NRDCONTA,4774.77 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14371995 as NRDCONTA,2870 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14402076 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14420562 as NRDCONTA,25501.84 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14551390 as NRDCONTA,260 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14628945 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14669919 as NRDCONTA,3700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14717328 as NRDCONTA,2800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14762501 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14763940 as NRDCONTA,4600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14930773 as NRDCONTA,4900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 14930773 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15082610 as NRDCONTA,340 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15143104 as NRDCONTA,440 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15156214 as NRDCONTA,3200 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15266265 as NRDCONTA,2275 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15340171 as NRDCONTA,8856 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15414809 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15503283 as NRDCONTA,3800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15601773 as NRDCONTA,2233.68 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15603075 as NRDCONTA,6890 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15619494 as NRDCONTA,4582.8 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15665755 as NRDCONTA,1694 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15710807 as NRDCONTA,1300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15718824 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15813703 as NRDCONTA,2920 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15836495 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15844714 as NRDCONTA,340 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15971112 as NRDCONTA,2486 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15994481 as NRDCONTA,150 as valor from dual
            union all
SELECT 1 as CDCOOPER, 15994481 as NRDCONTA,289 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16044746 as NRDCONTA,4600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16050304 as NRDCONTA,2540.24 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16124766 as NRDCONTA,2600 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16198263 as NRDCONTA,2000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16247728 as NRDCONTA,1410 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16275110 as NRDCONTA,1666.48 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16275110 as NRDCONTA,2135 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16353641 as NRDCONTA,3950 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16489543 as NRDCONTA,2258 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16501357 as NRDCONTA,3211 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16608712 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16645022 as NRDCONTA,1885 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16680081 as NRDCONTA,1102.4 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16680081 as NRDCONTA,948.03 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,4704.23 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,3889.24 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16793781 as NRDCONTA,3409.67 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16877969 as NRDCONTA,620.83 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16920732 as NRDCONTA,6900 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16961609 as NRDCONTA,962.25 as valor from dual
            union all
SELECT 1 as CDCOOPER, 16982720 as NRDCONTA,275 as valor from dual
            union all
SELECT 1 as CDCOOPER, 17213037 as NRDCONTA,7778 as valor from dual
            union all
SELECT 1 as CDCOOPER, 17213037 as NRDCONTA,4354 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,2061.69 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,4395.93 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,2647.07 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,3536 as valor from dual
            union all
SELECT 1 as CDCOOPER, 80361773 as NRDCONTA,4461.75 as valor from dual
            union all
SELECT 1 as CDCOOPER, 1924079 as NRDCONTA,4500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 2441110 as NRDCONTA,300 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3576728 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 3576728 as NRDCONTA,800 as valor from dual
            union all
SELECT 1 as CDCOOPER, 6668925 as NRDCONTA,1570 as valor from dual
            union all
SELECT 1 as CDCOOPER, 7598394 as NRDCONTA,22397 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8037582 as NRDCONTA,1500 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8290296 as NRDCONTA,3278 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8927472 as NRDCONTA,3000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 8987785 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9441549 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9441549 as NRDCONTA,7700 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9708766 as NRDCONTA,2750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9708766 as NRDCONTA,2750 as valor from dual
            union all
SELECT 1 as CDCOOPER, 9877673 as NRDCONTA,2779.37 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11928700 as NRDCONTA,5000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12052760 as NRDCONTA,13580 as valor from dual
            union all
SELECT 1 as CDCOOPER, 12052760 as NRDCONTA,15000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13192043 as NRDCONTA,10000 as valor from dual
            union all
SELECT 1 as CDCOOPER, 13548336 as NRDCONTA,9230 as valor from dual
            union all
SELECT 1 as CDCOOPER, 11166231 as NRDCONTA,4800 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,6000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 331554 as NRDCONTA,3350 as valor from dual
            union all
SELECT 2 as CDCOOPER, 557170 as NRDCONTA,1064 as valor from dual
            union all
SELECT 2 as CDCOOPER, 558915 as NRDCONTA,500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 591220 as NRDCONTA,4798.79 as valor from dual
            union all
SELECT 2 as CDCOOPER, 594644 as NRDCONTA,10200 as valor from dual
            union all
SELECT 2 as CDCOOPER, 594644 as NRDCONTA,9670 as valor from dual
            union all
SELECT 2 as CDCOOPER, 607312 as NRDCONTA,3470 as valor from dual
            union all
SELECT 2 as CDCOOPER, 630098 as NRDCONTA,3439.5 as valor from dual
            union all
SELECT 2 as CDCOOPER, 662372 as NRDCONTA,500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 677973 as NRDCONTA,4677 as valor from dual
            union all
SELECT 2 as CDCOOPER, 680354 as NRDCONTA,1658.47 as valor from dual
            union all
SELECT 2 as CDCOOPER, 680354 as NRDCONTA,1591.13 as valor from dual
            union all
SELECT 2 as CDCOOPER, 689130 as NRDCONTA,25650 as valor from dual
            union all
SELECT 2 as CDCOOPER, 737860 as NRDCONTA,300 as valor from dual
            union all
SELECT 2 as CDCOOPER, 756571 as NRDCONTA,10000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 764442 as NRDCONTA,1729 as valor from dual
            union all
SELECT 2 as CDCOOPER, 769037 as NRDCONTA,957 as valor from dual
            union all
SELECT 2 as CDCOOPER, 769320 as NRDCONTA,1500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 779920 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 805009 as NRDCONTA,1500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 821152 as NRDCONTA,2268 as valor from dual
            union all
SELECT 2 as CDCOOPER, 839493 as NRDCONTA,7120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 839493 as NRDCONTA,4000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 840432 as NRDCONTA,1358.97 as valor from dual
            union all
SELECT 2 as CDCOOPER, 847763 as NRDCONTA,8500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 862240 as NRDCONTA,2000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 871168 as NRDCONTA,1114.5 as valor from dual
            union all
SELECT 2 as CDCOOPER, 872563 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 897680 as NRDCONTA,4710 as valor from dual
            union all
SELECT 2 as CDCOOPER, 910210 as NRDCONTA,10000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 910210 as NRDCONTA,20000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 938661 as NRDCONTA,1125.26 as valor from dual
            union all
SELECT 2 as CDCOOPER, 989118 as NRDCONTA,15000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 990434 as NRDCONTA,1182 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1011383 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1057871 as NRDCONTA,14383.33 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1057871 as NRDCONTA,19573.25 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1067699 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1076140 as NRDCONTA,825 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1090461 as NRDCONTA,635 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1101641 as NRDCONTA,8100 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1106376 as NRDCONTA,3225 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1185713 as NRDCONTA,575 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15091805 as NRDCONTA,5830 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333000 as NRDCONTA,2725 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333639 as NRDCONTA,3000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,2500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,1000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,1200 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,4990 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,4990 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15766209 as NRDCONTA,2500 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15803600 as NRDCONTA,2698.2 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 1082620 as NRDCONTA,10120 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15333000 as NRDCONTA,5000 as valor from dual
            union all
SELECT 2 as CDCOOPER, 15335259 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 50067 as NRDCONTA,696.56 as valor from dual
            union all
SELECT 5 as CDCOOPER, 105678 as NRDCONTA,575 as valor from dual
            union all
SELECT 5 as CDCOOPER, 112577 as NRDCONTA,960 as valor from dual
            union all
SELECT 5 as CDCOOPER, 112577 as NRDCONTA,575 as valor from dual
            union all
SELECT 5 as CDCOOPER, 127612 as NRDCONTA,732 as valor from dual
            union all
SELECT 5 as CDCOOPER, 127612 as NRDCONTA,640 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144738 as NRDCONTA,4990 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144738 as NRDCONTA,4990 as valor from dual
            union all
SELECT 5 as CDCOOPER, 144762 as NRDCONTA,6700 as valor from dual
            union all
SELECT 5 as CDCOOPER, 147265 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 148270 as NRDCONTA,800 as valor from dual
            union all
SELECT 5 as CDCOOPER, 156019 as NRDCONTA,1498.07 as valor from dual
            union all
SELECT 5 as CDCOOPER, 185558 as NRDCONTA,4842 as valor from dual
            union all
SELECT 5 as CDCOOPER, 211338 as NRDCONTA,1000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,7474 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,5978.66 as valor from dual
            union all
SELECT 5 as CDCOOPER, 214680 as NRDCONTA,3650 as valor from dual
            union all
SELECT 5 as CDCOOPER, 231525 as NRDCONTA,7000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 243124 as NRDCONTA,2050 as valor from dual
            union all
SELECT 5 as CDCOOPER, 255068 as NRDCONTA,2500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 261939 as NRDCONTA,890 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4800 as valor from dual
            union all
SELECT 5 as CDCOOPER, 279625 as NRDCONTA,4897 as valor from dual
            union all
SELECT 5 as CDCOOPER, 289078 as NRDCONTA,1500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 295329 as NRDCONTA,1087 as valor from dual
            union all
SELECT 5 as CDCOOPER, 295434 as NRDCONTA,4200 as valor from dual
            union all
SELECT 5 as CDCOOPER, 311863 as NRDCONTA,5712.23 as valor from dual
            union all
SELECT 5 as CDCOOPER, 315958 as NRDCONTA,27450 as valor from dual
            union all
SELECT 5 as CDCOOPER, 328626 as NRDCONTA,3000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,3398 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354651 as NRDCONTA,2000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 357987 as NRDCONTA,4995 as valor from dual
            union all
SELECT 5 as CDCOOPER, 361186 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 364185 as NRDCONTA,6139.77 as valor from dual
            union all
SELECT 5 as CDCOOPER, 14752522 as NRDCONTA,13350 as valor from dual
            union all
SELECT 5 as CDCOOPER, 14907666 as NRDCONTA,2000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15513033 as NRDCONTA,1400 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15513033 as NRDCONTA,1751.6 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15601218 as NRDCONTA,3413 as valor from dual
            union all
SELECT 5 as CDCOOPER, 15997510 as NRDCONTA,572 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,21295.05 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16009401 as NRDCONTA,10000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16074998 as NRDCONTA,2300 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16467787 as NRDCONTA,4832.75 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16467787 as NRDCONTA,4832.75 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16522230 as NRDCONTA,4000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16789229 as NRDCONTA,190 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16877780 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16877780 as NRDCONTA,4240 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16957083 as NRDCONTA,3260 as valor from dual
            union all
SELECT 5 as CDCOOPER, 16957083 as NRDCONTA,4000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17049946 as NRDCONTA,500 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17220270 as NRDCONTA,5100 as valor from dual
            union all
SELECT 5 as CDCOOPER, 17346088 as NRDCONTA,5550 as valor from dual
            union all
SELECT 5 as CDCOOPER, 114600 as NRDCONTA,3000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 135542 as NRDCONTA,2434.52 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,4050 as valor from dual
            union all
SELECT 5 as CDCOOPER, 354473 as NRDCONTA,5000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 358266 as NRDCONTA,1000 as valor from dual
            union all
SELECT 5 as CDCOOPER, 368377 as NRDCONTA,1250 as valor from dual
            union all
SELECT 6 as CDCOOPER, 10448 as NRDCONTA,4510.58 as valor from dual
            union all
SELECT 6 as CDCOOPER, 39713 as NRDCONTA,2750 as valor from dual
            union all
SELECT 6 as CDCOOPER, 59960 as NRDCONTA,11000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 148067 as NRDCONTA,2000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 172863 as NRDCONTA,20000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 172863 as NRDCONTA,5000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 195944 as NRDCONTA,2887 as valor from dual
            union all
SELECT 6 as CDCOOPER, 201553 as NRDCONTA,5430 as valor from dual
            union all
SELECT 6 as CDCOOPER, 201650 as NRDCONTA,7059 as valor from dual
            union all
SELECT 6 as CDCOOPER, 217743 as NRDCONTA,4684 as valor from dual
            union all
SELECT 6 as CDCOOPER, 224359 as NRDCONTA,5861.6 as valor from dual
            union all
SELECT 6 as CDCOOPER, 224359 as NRDCONTA,2255.82 as valor from dual
            union all
SELECT 6 as CDCOOPER, 249246 as NRDCONTA,3000 as valor from dual
            union all
SELECT 6 as CDCOOPER, 505978 as NRDCONTA,2314.32 as valor from dual
            union all
SELECT 6 as CDCOOPER, 14920441 as NRDCONTA,4100 as valor from dual
            union all
SELECT 7 as CDCOOPER, 46493 as NRDCONTA,2264 as valor from dual
            union all
SELECT 7 as CDCOOPER, 46493 as NRDCONTA,3750 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194565 as NRDCONTA,1861.06 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194565 as NRDCONTA,1608 as valor from dual
            union all
SELECT 7 as CDCOOPER, 194603 as NRDCONTA,1696 as valor from dual
            union all
SELECT 7 as CDCOOPER, 229555 as NRDCONTA,2000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 252751 as NRDCONTA,6000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 317969 as NRDCONTA,3286 as valor from dual
            union all
SELECT 7 as CDCOOPER, 317969 as NRDCONTA,4600 as valor from dual
            union all
SELECT 7 as CDCOOPER, 324892 as NRDCONTA,1100 as valor from dual
            union all
SELECT 7 as CDCOOPER, 325368 as NRDCONTA,6600 as valor from dual
            union all
SELECT 7 as CDCOOPER, 391166 as NRDCONTA,654 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,2874 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,3179.46 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,3361 as valor from dual
            union all
SELECT 7 as CDCOOPER, 407780 as NRDCONTA,2930 as valor from dual
            union all
SELECT 7 as CDCOOPER, 414476 as NRDCONTA,8000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 414786 as NRDCONTA,1900 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15696880 as NRDCONTA,1145 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15711080 as NRDCONTA,6000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 15711080 as NRDCONTA,1000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16137949 as NRDCONTA,2500 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16145232 as NRDCONTA,2000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 16899610 as NRDCONTA,4000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 17529174 as NRDCONTA,3000 as valor from dual
            union all
SELECT 7 as CDCOOPER, 417882 as NRDCONTA,31250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,4871.25 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,4964.44 as valor from dual
            union all
SELECT 9 as CDCOOPER, 11320 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 14877 as NRDCONTA,2940.91 as valor from dual
            union all
SELECT 9 as CDCOOPER, 51837 as NRDCONTA,7000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 62332 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 148792 as NRDCONTA,4469.79 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,10962.01 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,10795.88 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,11795.3 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,13765 as valor from dual
            union all
SELECT 9 as CDCOOPER, 157830 as NRDCONTA,11550.16 as valor from dual
            union all
SELECT 9 as CDCOOPER, 177334 as NRDCONTA,707.52 as valor from dual
            union all
SELECT 9 as CDCOOPER, 177342 as NRDCONTA,1556.17 as valor from dual
            union all
SELECT 9 as CDCOOPER, 179639 as NRDCONTA,3200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 187046 as NRDCONTA,280 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,850 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,650 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1300 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1050 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1200 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 188328 as NRDCONTA,600 as valor from dual
            union all
SELECT 9 as CDCOOPER, 193275 as NRDCONTA,900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 195782 as NRDCONTA,5395 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 216941 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224405 as NRDCONTA,1500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224413 as NRDCONTA,309.72 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224413 as NRDCONTA,884.31 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224693 as NRDCONTA,3524 as valor from dual
            union all
SELECT 9 as CDCOOPER, 224693 as NRDCONTA,3910 as valor from dual
            union all
SELECT 9 as CDCOOPER, 234826 as NRDCONTA,6000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 242268 as NRDCONTA,6000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 245070 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 247332 as NRDCONTA,3000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 247332 as NRDCONTA,750 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258695 as NRDCONTA,1016 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258725 as NRDCONTA,1281.15 as valor from dual
            union all
SELECT 9 as CDCOOPER, 258725 as NRDCONTA,1539 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,9990 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 265861 as NRDCONTA,8800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 286486 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 288241 as NRDCONTA,950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 289604 as NRDCONTA,10854.4 as valor from dual
            union all
SELECT 9 as CDCOOPER, 293970 as NRDCONTA,4500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309605 as NRDCONTA,4400 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309605 as NRDCONTA,4998 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4700 as valor from dual
            union all
SELECT 9 as CDCOOPER, 309621 as NRDCONTA,4999 as valor from dual
            union all
SELECT 9 as CDCOOPER, 314404 as NRDCONTA,3980 as valor from dual
            union all
SELECT 9 as CDCOOPER, 314404 as NRDCONTA,3500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 322857 as NRDCONTA,4000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 326909 as NRDCONTA,2160 as valor from dual
            union all
SELECT 9 as CDCOOPER, 329908 as NRDCONTA,825 as valor from dual
            union all
SELECT 9 as CDCOOPER, 329932 as NRDCONTA,250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,30000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,637 as valor from dual
            union all
SELECT 9 as CDCOOPER, 341231 as NRDCONTA,820 as valor from dual
            union all
SELECT 9 as CDCOOPER, 363880 as NRDCONTA,720 as valor from dual
            union all
SELECT 9 as CDCOOPER, 363880 as NRDCONTA,2920 as valor from dual
            union all
SELECT 9 as CDCOOPER, 370932 as NRDCONTA,543.6 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2550 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 384909 as NRDCONTA,2550 as valor from dual
            union all
SELECT 9 as CDCOOPER, 385557 as NRDCONTA,3900 as valor from dual
            union all
SELECT 9 as CDCOOPER, 402559 as NRDCONTA,3660 as valor from dual
            union all
SELECT 9 as CDCOOPER, 407178 as NRDCONTA,1250 as valor from dual
            union all
SELECT 9 as CDCOOPER, 407178 as NRDCONTA,1950 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,15542 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,18275 as valor from dual
            union all
SELECT 9 as CDCOOPER, 413216 as NRDCONTA,6174.25 as valor from dual
            union all
SELECT 9 as CDCOOPER, 424951 as NRDCONTA,1897 as valor from dual
            union all
SELECT 9 as CDCOOPER, 435201 as NRDCONTA,6825.65 as valor from dual
            union all
SELECT 9 as CDCOOPER, 439231 as NRDCONTA,4582.04 as valor from dual
            union all
SELECT 9 as CDCOOPER, 439231 as NRDCONTA,4990 as valor from dual
            union all
SELECT 9 as CDCOOPER, 442801 as NRDCONTA,6500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 445037 as NRDCONTA,5129 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446106 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446106 as NRDCONTA,2800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 446157 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 462128 as NRDCONTA,3287.81 as valor from dual
            union all
SELECT 9 as CDCOOPER, 462128 as NRDCONTA,1725 as valor from dual
            union all
SELECT 9 as CDCOOPER, 470996 as NRDCONTA,4625 as valor from dual
            union all
SELECT 9 as CDCOOPER, 542903 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 547069 as NRDCONTA,3300 as valor from dual
            union all
SELECT 9 as CDCOOPER, 553719 as NRDCONTA,1380 as valor from dual
            union all
SELECT 9 as CDCOOPER, 557129 as NRDCONTA,37123.86 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048624 as NRDCONTA,2654 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048853 as NRDCONTA,1470 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15048853 as NRDCONTA,4332 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15288323 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15288323 as NRDCONTA,5000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,4290 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,3262 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15362213 as NRDCONTA,683.35 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15557316 as NRDCONTA,2000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 15590860 as NRDCONTA,1800 as valor from dual
            union all
SELECT 9 as CDCOOPER, 16264959 as NRDCONTA,1210 as valor from dual
            union all
SELECT 9 as CDCOOPER, 211893 as NRDCONTA,1415 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,10000 as valor from dual
            union all
SELECT 9 as CDCOOPER, 330574 as NRDCONTA,23333.33 as valor from dual
            union all
SELECT 9 as CDCOOPER, 361216 as NRDCONTA,2500 as valor from dual
            union all
SELECT 9 as CDCOOPER, 443956 as NRDCONTA,3670 as valor from dual
            union all
SELECT 10 as CDCOOPER, 752 as NRDCONTA,8810.29 as valor from dual
            union all
SELECT 10 as CDCOOPER, 1600 as NRDCONTA,1712.72 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,8137.8 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,8294.4 as valor from dual
            union all
SELECT 10 as CDCOOPER, 8613 as NRDCONTA,6000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 20265 as NRDCONTA,1439 as valor from dual
            union all
SELECT 10 as CDCOOPER, 29076 as NRDCONTA,631 as valor from dual
            union all
SELECT 10 as CDCOOPER, 41084 as NRDCONTA,2800 as valor from dual
            union all
SELECT 10 as CDCOOPER, 42765 as NRDCONTA,1119.49 as valor from dual
            union all
SELECT 10 as CDCOOPER, 43486 as NRDCONTA,3600 as valor from dual
            union all
SELECT 10 as CDCOOPER, 57223 as NRDCONTA,1270 as valor from dual
            union all
SELECT 10 as CDCOOPER, 66524 as NRDCONTA,602 as valor from dual
            union all
SELECT 10 as CDCOOPER, 88463 as NRDCONTA,710 as valor from dual
            union all
SELECT 10 as CDCOOPER, 91901 as NRDCONTA,765 as valor from dual
            union all
SELECT 10 as CDCOOPER, 91901 as NRDCONTA,847 as valor from dual
            union all
SELECT 10 as CDCOOPER, 118001 as NRDCONTA,8000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 127159 as NRDCONTA,696.69 as valor from dual
            union all
SELECT 10 as CDCOOPER, 170844 as NRDCONTA,10500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 171816 as NRDCONTA,14500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 177946 as NRDCONTA,35000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 186856 as NRDCONTA,16500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 187054 as NRDCONTA,6175 as valor from dual
            union all
SELECT 10 as CDCOOPER, 187054 as NRDCONTA,2480 as valor from dual
            union all
SELECT 10 as CDCOOPER, 193712 as NRDCONTA,3000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 200506 as NRDCONTA,5465 as valor from dual
            union all
SELECT 10 as CDCOOPER, 213128 as NRDCONTA,1227.01 as valor from dual
            union all
SELECT 10 as CDCOOPER, 213128 as NRDCONTA,587 as valor from dual
            union all
SELECT 10 as CDCOOPER, 215082 as NRDCONTA,3500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,17000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,2500 as valor from dual
            union all
SELECT 10 as CDCOOPER, 239739 as NRDCONTA,15000 as valor from dual
            union all
SELECT 10 as CDCOOPER, 15990460 as NRDCONTA,710 as valor from dual
            union all
SELECT 10 as CDCOOPER, 15990460 as NRDCONTA,745 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16590937 as NRDCONTA,900 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16670566 as NRDCONTA,900 as valor from dual
            union all
SELECT 10 as CDCOOPER, 16859430 as NRDCONTA,2742 as valor from dual
            union all
SELECT 10 as CDCOOPER, 25542 as NRDCONTA,20000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 5215 as NRDCONTA,594 as valor from dual
            union all
SELECT 11 as CDCOOPER, 52825 as NRDCONTA,1528 as valor from dual
            union all
SELECT 11 as CDCOOPER, 52825 as NRDCONTA,1328 as valor from dual
            union all
SELECT 11 as CDCOOPER, 93785 as NRDCONTA,1363.58 as valor from dual
            union all
SELECT 11 as CDCOOPER, 94137 as NRDCONTA,615 as valor from dual
            union all
SELECT 11 as CDCOOPER, 138894 as NRDCONTA,1241.86 as valor from dual
            union all
SELECT 11 as CDCOOPER, 142182 as NRDCONTA,4990 as valor from dual
            union all
SELECT 11 as CDCOOPER, 180017 as NRDCONTA,660 as valor from dual
            union all
SELECT 11 as CDCOOPER, 185680 as NRDCONTA,3329 as valor from dual
            union all
SELECT 11 as CDCOOPER, 185680 as NRDCONTA,5082.76 as valor from dual
            union all
SELECT 11 as CDCOOPER, 203955 as NRDCONTA,1735 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4420 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4420 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4730 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4730 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,3220 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4800 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4900 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4065.52 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4700 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4639.2 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4680 as valor from dual
            union all
SELECT 11 as CDCOOPER, 360686 as NRDCONTA,4680 as valor from dual
            union all
SELECT 11 as CDCOOPER, 375810 as NRDCONTA,5300 as valor from dual
            union all
SELECT 11 as CDCOOPER, 380474 as NRDCONTA,14000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 409880 as NRDCONTA,330 as valor from dual
            union all
SELECT 11 as CDCOOPER, 495220 as NRDCONTA,1400 as valor from dual
            union all
SELECT 11 as CDCOOPER, 499625 as NRDCONTA,3196.54 as valor from dual
            union all
SELECT 11 as CDCOOPER, 530670 as NRDCONTA,1750 as valor from dual
            union all
SELECT 11 as CDCOOPER, 547166 as NRDCONTA,1700 as valor from dual
            union all
SELECT 11 as CDCOOPER, 547166 as NRDCONTA,4500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 576654 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 583081 as NRDCONTA,443 as valor from dual
            union all
SELECT 11 as CDCOOPER, 621595 as NRDCONTA,3000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 637688 as NRDCONTA,1588 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,1350 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,681.1 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4024 as valor from dual
            union all
SELECT 11 as CDCOOPER, 663204 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 671363 as NRDCONTA,1008 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,1631.25 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,2263.31 as valor from dual
            union all
SELECT 11 as CDCOOPER, 699152 as NRDCONTA,2040 as valor from dual
            union all
SELECT 11 as CDCOOPER, 703338 as NRDCONTA,15270 as valor from dual
            union all
SELECT 11 as CDCOOPER, 708135 as NRDCONTA,1834 as valor from dual
            union all
SELECT 11 as CDCOOPER, 717800 as NRDCONTA,6061.16 as valor from dual
            union all
SELECT 11 as CDCOOPER, 717800 as NRDCONTA,4245.3 as valor from dual
            union all
SELECT 11 as CDCOOPER, 729400 as NRDCONTA,1500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 734136 as NRDCONTA,1446 as valor from dual
            union all
SELECT 11 as CDCOOPER, 745928 as NRDCONTA,7000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 750581 as NRDCONTA,7500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 753874 as NRDCONTA,8675 as valor from dual
            union all
SELECT 11 as CDCOOPER, 753874 as NRDCONTA,27438 as valor from dual
            union all
SELECT 11 as CDCOOPER, 758698 as NRDCONTA,10000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 789836 as NRDCONTA,11000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 812633 as NRDCONTA,9872 as valor from dual
            union all
SELECT 11 as CDCOOPER, 834319 as NRDCONTA,6400 as valor from dual
            union all
SELECT 11 as CDCOOPER, 893188 as NRDCONTA,1000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 925713 as NRDCONTA,5000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 954535 as NRDCONTA,43850 as valor from dual
            union all
SELECT 11 as CDCOOPER, 957933 as NRDCONTA,20000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 978850 as NRDCONTA,5000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 988260 as NRDCONTA,7000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 1005863 as NRDCONTA,4600 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14497727 as NRDCONTA,4000 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14497727 as NRDCONTA,4789.25 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14687534 as NRDCONTA,1200 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14687534 as NRDCONTA,693.58 as valor from dual
            union all
SELECT 11 as CDCOOPER, 14695898 as NRDCONTA,2879.97 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15630951 as NRDCONTA,1671 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16114086 as NRDCONTA,6250 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16223110 as NRDCONTA,1474.5 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16344502 as NRDCONTA,683 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16372441 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16805755 as NRDCONTA,1450 as valor from dual
            union all
SELECT 11 as CDCOOPER, 233390 as NRDCONTA,630.3 as valor from dual
            union all
SELECT 11 as CDCOOPER, 15684539 as NRDCONTA,2500 as valor from dual
            union all
SELECT 11 as CDCOOPER, 16932617 as NRDCONTA,7500 as valor from dual
            union all
SELECT 12 as CDCOOPER, 6106 as NRDCONTA,9000 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,985 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,1831.88 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17337 as NRDCONTA,1831.88 as valor from dual
            union all
SELECT 12 as CDCOOPER, 30147 as NRDCONTA,4465 as valor from dual
            union all
SELECT 12 as CDCOOPER, 77968 as NRDCONTA,1650 as valor from dual
            union all
SELECT 12 as CDCOOPER, 137952 as NRDCONTA,3826.8 as valor from dual
            union all
SELECT 12 as CDCOOPER, 204838 as NRDCONTA,200 as valor from dual
            union all
SELECT 12 as CDCOOPER, 16226208 as NRDCONTA,1750 as valor from dual
            union all
SELECT 12 as CDCOOPER, 17011043 as NRDCONTA,2325 as valor from dual
            union all
SELECT 12 as CDCOOPER, 86940 as NRDCONTA,9793 as valor from dual
            union all
SELECT 13 as CDCOOPER, 117625 as NRDCONTA,400 as valor from dual
            union all
SELECT 13 as CDCOOPER, 118753 as NRDCONTA,328 as valor from dual
            union all
SELECT 13 as CDCOOPER, 131393 as NRDCONTA,1034 as valor from dual
            union all
SELECT 13 as CDCOOPER, 134287 as NRDCONTA,3800 as valor from dual
            union all
SELECT 13 as CDCOOPER, 161845 as NRDCONTA,1000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 165980 as NRDCONTA,698 as valor from dual
            union all
SELECT 13 as CDCOOPER, 166057 as NRDCONTA,100000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 273139 as NRDCONTA,3624 as valor from dual
            union all
SELECT 13 as CDCOOPER, 293938 as NRDCONTA,589.46 as valor from dual
            union all
SELECT 13 as CDCOOPER, 302732 as NRDCONTA,1550 as valor from dual
            union all
SELECT 13 as CDCOOPER, 326135 as NRDCONTA,1250 as valor from dual
            union all
SELECT 13 as CDCOOPER, 337226 as NRDCONTA,1038 as valor from dual
            union all
SELECT 13 as CDCOOPER, 338737 as NRDCONTA,7252 as valor from dual
            union all
SELECT 13 as CDCOOPER, 396168 as NRDCONTA,15000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 404845 as NRDCONTA,384 as valor from dual
            union all
SELECT 13 as CDCOOPER, 430145 as NRDCONTA,9096 as valor from dual
            union all
SELECT 13 as CDCOOPER, 440914 as NRDCONTA,6000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 480304 as NRDCONTA,4000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 488836 as NRDCONTA,3180 as valor from dual
            union all
SELECT 13 as CDCOOPER, 541427 as NRDCONTA,2482.46 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,5500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,5500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 549517 as NRDCONTA,9424 as valor from dual
            union all
SELECT 13 as CDCOOPER, 583464 as NRDCONTA,4000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 583715 as NRDCONTA,12200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 603430 as NRDCONTA,2180 as valor from dual
            union all
SELECT 13 as CDCOOPER, 623130 as NRDCONTA,1000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 644870 as NRDCONTA,7200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 644870 as NRDCONTA,7200 as valor from dual
            union all
SELECT 13 as CDCOOPER, 669440 as NRDCONTA,950 as valor from dual
            union all
SELECT 13 as CDCOOPER, 669440 as NRDCONTA,1170 as valor from dual
            union all
SELECT 13 as CDCOOPER, 670570 as NRDCONTA,12000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 675687 as NRDCONTA,3286 as valor from dual
            union all
SELECT 13 as CDCOOPER, 722308 as NRDCONTA,680 as valor from dual
            union all
SELECT 13 as CDCOOPER, 722308 as NRDCONTA,535 as valor from dual
            union all
SELECT 13 as CDCOOPER, 735167 as NRDCONTA,407 as valor from dual
            union all
SELECT 13 as CDCOOPER, 15150933 as NRDCONTA,816 as valor from dual
            union all
SELECT 13 as CDCOOPER, 15547671 as NRDCONTA,3666 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16039920 as NRDCONTA,1534 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16697987 as NRDCONTA,1800 as valor from dual
            union all
SELECT 13 as CDCOOPER, 16813391 as NRDCONTA,1500 as valor from dual
            union all
SELECT 13 as CDCOOPER, 17354862 as NRDCONTA,15000 as valor from dual
            union all
SELECT 13 as CDCOOPER, 242888 as NRDCONTA,2673 as valor from dual
            union all
SELECT 13 as CDCOOPER, 596698 as NRDCONTA,1000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17833 as NRDCONTA,7000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20060 as NRDCONTA,1000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20915 as NRDCONTA,8950 as valor from dual
            union all
SELECT 14 as CDCOOPER, 20915 as NRDCONTA,8697 as valor from dual
            union all
SELECT 14 as CDCOOPER, 34070 as NRDCONTA,4800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 38156 as NRDCONTA,500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 42889 as NRDCONTA,1300 as valor from dual
            union all
SELECT 14 as CDCOOPER, 42919 as NRDCONTA,2000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 47155 as NRDCONTA,5500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 53597 as NRDCONTA,9000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 62642 as NRDCONTA,7000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 69876 as NRDCONTA,16800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 87068 as NRDCONTA,2500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 111120 as NRDCONTA,170 as valor from dual
            union all
SELECT 14 as CDCOOPER, 114545 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 116807 as NRDCONTA,2500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 128597 as NRDCONTA,4081 as valor from dual
            union all
SELECT 14 as CDCOOPER, 132020 as NRDCONTA,516 as valor from dual
            union all
SELECT 14 as CDCOOPER, 137669 as NRDCONTA,10322 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146293 as NRDCONTA,1414 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146439 as NRDCONTA,1878 as valor from dual
            union all
SELECT 14 as CDCOOPER, 146897 as NRDCONTA,9598 as valor from dual
            union all
SELECT 14 as CDCOOPER, 157325 as NRDCONTA,1500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 175269 as NRDCONTA,3000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 190497 as NRDCONTA,4000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 194611 as NRDCONTA,3355 as valor from dual
            union all
SELECT 14 as CDCOOPER, 255947 as NRDCONTA,1225 as valor from dual
            union all
SELECT 14 as CDCOOPER, 259934 as NRDCONTA,766 as valor from dual
            union all
SELECT 14 as CDCOOPER, 268020 as NRDCONTA,1213 as valor from dual
            union all
SELECT 14 as CDCOOPER, 268160 as NRDCONTA,3840 as valor from dual
            union all
SELECT 14 as CDCOOPER, 269336 as NRDCONTA,120 as valor from dual
            union all
SELECT 14 as CDCOOPER, 272892 as NRDCONTA,2100 as valor from dual
            union all
SELECT 14 as CDCOOPER, 315877 as NRDCONTA,438 as valor from dual
            union all
SELECT 14 as CDCOOPER, 322032 as NRDCONTA,494.93 as valor from dual
            union all
SELECT 14 as CDCOOPER, 336513 as NRDCONTA,4338 as valor from dual
            union all
SELECT 14 as CDCOOPER, 343994 as NRDCONTA,25000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 346128 as NRDCONTA,470 as valor from dual
            union all
SELECT 14 as CDCOOPER, 365777 as NRDCONTA,3505 as valor from dual
            union all
SELECT 14 as CDCOOPER, 386693 as NRDCONTA,2406.77 as valor from dual
            union all
SELECT 14 as CDCOOPER, 396036 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 396117 as NRDCONTA,970.18 as valor from dual
            union all
SELECT 14 as CDCOOPER, 398586 as NRDCONTA,5000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 398586 as NRDCONTA,3000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 403920 as NRDCONTA,2000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 403920 as NRDCONTA,2200 as valor from dual
            union all
SELECT 14 as CDCOOPER, 404381 as NRDCONTA,15707.85 as valor from dual
            union all
SELECT 14 as CDCOOPER, 14990520 as NRDCONTA,713.2 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15317757 as NRDCONTA,866 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15423913 as NRDCONTA,12400 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15523152 as NRDCONTA,1500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15596419 as NRDCONTA,10000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15597237 as NRDCONTA,1250 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15660532 as NRDCONTA,1416 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15777294 as NRDCONTA,192.25 as valor from dual
            union all
SELECT 14 as CDCOOPER, 15795322 as NRDCONTA,2250 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16199065 as NRDCONTA,1260 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16215770 as NRDCONTA,3800 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16802357 as NRDCONTA,8000 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16813820 as NRDCONTA,331.98 as valor from dual
            union all
SELECT 14 as CDCOOPER, 16982118 as NRDCONTA,1050 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17124867 as NRDCONTA,3300 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17316430 as NRDCONTA,17916.25 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17316430 as NRDCONTA,10500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 17342880 as NRDCONTA,500 as valor from dual
            union all
SELECT 14 as CDCOOPER, 35521 as NRDCONTA,30000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 46361 as NRDCONTA,749.31 as valor from dual
            union all
SELECT 16 as CDCOOPER, 47422 as NRDCONTA,3690 as valor from dual
            union all
SELECT 16 as CDCOOPER, 53023 as NRDCONTA,1000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 58157 as NRDCONTA,4165 as valor from dual
            union all
SELECT 16 as CDCOOPER, 145912 as NRDCONTA,505 as valor from dual
            union all
SELECT 16 as CDCOOPER, 185434 as NRDCONTA,3849.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 221376 as NRDCONTA,425.25 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,4987 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,9000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,6632 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,4788 as valor from dual
            union all
SELECT 16 as CDCOOPER, 229113 as NRDCONTA,1320 as valor from dual
            union all
SELECT 16 as CDCOOPER, 269964 as NRDCONTA,402.48 as valor from dual
            union all
SELECT 16 as CDCOOPER, 292818 as NRDCONTA,645.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 311170 as NRDCONTA,5000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 350664 as NRDCONTA,300 as valor from dual
            union all
SELECT 16 as CDCOOPER, 390569 as NRDCONTA,6955 as valor from dual
            union all
SELECT 16 as CDCOOPER, 403520 as NRDCONTA,38500 as valor from dual
            union all
SELECT 16 as CDCOOPER, 450294 as NRDCONTA,480 as valor from dual
            union all
SELECT 16 as CDCOOPER, 482269 as NRDCONTA,3000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 551724 as NRDCONTA,5000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 567566 as NRDCONTA,570 as valor from dual
            union all
SELECT 16 as CDCOOPER, 580104 as NRDCONTA,2865.09 as valor from dual
            union all
SELECT 16 as CDCOOPER, 605174 as NRDCONTA,362.2 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,978.2 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,1660 as valor from dual
            union all
SELECT 16 as CDCOOPER, 633283 as NRDCONTA,1600 as valor from dual
            union all
SELECT 16 as CDCOOPER, 705144 as NRDCONTA,350 as valor from dual
            union all
SELECT 16 as CDCOOPER, 762466 as NRDCONTA,2100 as valor from dual
            union all
SELECT 16 as CDCOOPER, 784478 as NRDCONTA,1732 as valor from dual
            union all
SELECT 16 as CDCOOPER, 866644 as NRDCONTA,4800 as valor from dual
            union all
SELECT 16 as CDCOOPER, 867969 as NRDCONTA,287.13 as valor from dual
            union all
SELECT 16 as CDCOOPER, 871591 as NRDCONTA,280 as valor from dual
            union all
SELECT 16 as CDCOOPER, 894540 as NRDCONTA,1361 as valor from dual
            union all
SELECT 16 as CDCOOPER, 922501 as NRDCONTA,200 as valor from dual
            union all
SELECT 16 as CDCOOPER, 931756 as NRDCONTA,85 as valor from dual
            union all
SELECT 16 as CDCOOPER, 941980 as NRDCONTA,1561 as valor from dual
            union all
SELECT 16 as CDCOOPER, 950521 as NRDCONTA,849 as valor from dual
            union all
SELECT 16 as CDCOOPER, 1013980 as NRDCONTA,6990 as valor from dual
            union all
SELECT 16 as CDCOOPER, 1072579 as NRDCONTA,239.8 as valor from dual
            union all
SELECT 16 as CDCOOPER, 3899420 as NRDCONTA,1079 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6033458 as NRDCONTA,2000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6096484 as NRDCONTA,1000 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15414477 as NRDCONTA,834 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,1950 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,5952 as valor from dual
            union all
SELECT 16 as CDCOOPER, 15862364 as NRDCONTA,12900 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16085744 as NRDCONTA,3212.5 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16255607 as NRDCONTA,3658.79 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16255607 as NRDCONTA,1626 as valor from dual
            union all
SELECT 16 as CDCOOPER, 16695054 as NRDCONTA,976 as valor from dual
            union all
SELECT 16 as CDCOOPER, 6641890 as NRDCONTA,3250 as valor from dual            
			) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = contas.cdcooper
       AND a.dtmvtolt BETWEEN vc_dtinicioCRAPSDA AND TRUNC(SYSDATE)
     ORDER BY a.nrdconta, a.dtmvtolt asc;

    



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
         SET a.VLSDDISP = a.VLSDDISP + pr_valor
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
           SET a.VLSDDISP = a.VLSDDISP + pr_valor
         WHERE a.nrdconta = pr_nrdconta
           AND a.cdcooper = pr_cdcooper
           AND a.dtmvtolt = pr_dtmvtolt;
    END IF;
  END;



BEGIN
  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;
    

  FOR rg_crapsld IN cr_crapsld LOOP
    gr_nrdconta := rg_crapsld.nrdconta;
    gr_cdcooper := rg_crapsld.cdcooper;

    pr_atualiza_sld(gr_cdcooper,
                    gr_nrdconta,
                    rg_crapsld.vlsddisp,
                    rg_crapsld.valor,
                    vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro_geralog;
    END IF;

  END LOOP;

  FOR rg_crapsda IN cr_crapsda LOOP

    gr_nrdconta := rg_crapsda.nrdconta;
    gr_cdcooper := rg_crapsda.cdcooper;

    pr_atualiza_sda(gr_cdcooper,
                    gr_nrdconta,
                    rg_crapsda.dtmvtolt,
                    rg_crapsda.vlsddisp,
                    rg_crapsda.valor,
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
                            gr_cdcooper || '/' || gr_nrdconta || ')- ' ||  vr_dscritic);

  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            gr_cdcooper || '/' || gr_nrdconta || ') - ' ||  ' - ' || v_code || ' - ' || v_errm);
END;
/
