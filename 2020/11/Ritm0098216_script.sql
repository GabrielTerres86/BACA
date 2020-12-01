/* RITM0098216 - Eliminar dados em duplicidade gerados pelo IEPTB */

BEGIN
    
  /* Inforamações Viacredi*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND 
  (ret.tpocorre = '1' OR ret.tpocorre = '7') 
   --
   AND ret.cdcooper in (1)
   AND ret.nrdconta in (7333099
  ,9605339
  ,8314004
  ,8314004
  ,11328800
  ,9952420
  ,10765530
  ,7272634
  ,3649520
  ,7034121
  ,9989994
  ,3797791
  ,11360054
  ,6621317
  ,6064655
  ,9209360
  ,10920617
  ,6815111
  ,9139443
  ,10593152
  ,9204750
  ,9204750
  ,7151470
  ,9225200
  ,10114980
  ,8360480
  ,906
  ,8607443
  ,7315910
  ,11122170
  ,7308701
  ,7308701
  ,9781773
  ,9967257
  ,10784357
  ,10784357
  ,6336000
  ,10807373
  ,9256636
  ,7960921
  ,8012628
  ,10593152
  ,8516022
  ,8516022
  ,8422478
  ,8960828
  ,8127662
  ,2666243)
  AND ret.nrdocmto in (1328
  ,77
  ,480
  ,477
  ,8
  ,1230
  ,449
  ,388
  ,463
  ,1346
  ,376
  ,3811
  ,2
  ,1985
  ,5192
  ,394
  ,1
  ,44159
  ,6221
  ,31
  ,182
  ,181
  ,1319
  ,3804
  ,43
  ,2509
  ,401
  ,6033
  ,4536
  ,1204
  ,2715
  ,2747
  ,9292
  ,223
  ,310
  ,305
  ,3356
  ,29
  ,67
  ,145
  ,3053
  ,34
  ,131
  ,128
  ,827
  ,1661
  ,16
  ,126);

  /* Inforamações Acentra*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (5)
  AND ret.nrdconta in (91871,185787,169587,159956)
  AND ret.nrdocmto in (1608,159,80,616);


  /* Inforamações Acredi*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (2)
  AND ret.nrdconta in (566705)
  AND ret.nrdocmto in (361);

  /* Inforamações AutoVale*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (16)   
  AND ret.nrdconta in (653284,559750,135739,518921,374288,511153,325635)
  AND ret.nrdocmto in (296,585,171,13930,1760,92,546);


  /* Inforamações Civia*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (13)   
  AND ret.nrdconta in (540,292869,292869,453307,453307,453307,453307,453307,453307,453307,453307,124907)
  AND ret.nrdocmto in (8843,1110,1143,9,8,7,6,4,3,2,1,443);


  /* Inforamações Credcrea*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (7)   
  AND ret.nrdconta in (76201,313661,114847,189235,72141,151874)
  AND ret.nrdocmto in (2291,111,200,76,3405,341);

  /* Inforamações Credcomin*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (10)   
  AND ret.nrdconta in (74926)
  AND ret.nrdocmto in (37);

  /* Inforamações Credfoz*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (11)   
  AND ret.nrdconta in (291579)
  AND ret.nrdocmto in (2404);

  /* Inforamações Evolua*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (14)   
  AND ret.nrdconta in (143812)
  AND ret.nrdocmto in (11465);

  /* Inforamações Transpocred*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (9 )   
  AND ret.nrdconta in (136522,208140,6378,121568,172979,224413,285315,208140)
  AND ret.nrdocmto in (2192,1369,222060,166,619,1374,59,1334);

  /* Inforamações Unilos*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (6 )   
  AND ret.nrdconta in (185469,500658)
  AND ret.nrdocmto in (69,1085);

  COMMIT;
END;

  
