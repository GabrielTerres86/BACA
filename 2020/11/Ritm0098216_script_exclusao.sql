/* RITM0098216 - Eliminar dados em duplicidade gerados pelo IEPTB */
    
  /* Inforamações Viacredi*/
  DELETE tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND 
  (ret.tpocorre = '1' OR ret.tpocorre = '7') 
   --
   AND ret.cdcooper in (1) 
   AND (ret.nrdconta,ret.nrdocmto) in ((7333099,1328)
                                      ,(9605339,77)
                                      ,(8314004,480)
                                      ,(8314004,477)
                                      ,(11328800,8)
                                      ,(9952420,1230)
                                      ,(10765530,449)
                                      ,(7272634,388)
                                      ,(3649520,463)
                                      ,(7034121,1346)
                                      ,(9989994,376)
                                      ,(3797791,3811)
                                      ,(11360054,2)
                                      ,(6621317,1985)
                                      ,(6064655,5192)
                                      ,(9209360,394)
                                      ,(10920617,1)
                                      ,(6815111,44159)
                                      ,(9139443,6221)
                                      ,(10593152,31)
                                      ,(9204750,182)
                                      ,(9204750,181)
                                      ,(7151470,1319)
                                      ,(9225200,3804)
                                      ,(10114980,43)
                                      ,(8360480,2509)
                                      ,(906,401)
                                      ,(8607443,6033)
                                      ,(7315910,4536)
                                      ,(11122170,1204)
                                      ,(7308701,2715)
                                      ,(7308701,2747)
                                      ,(9781773,9292)
                                      ,(9967257,223)
                                      ,(10784357,310)
                                      ,(10784357,305)
                                      ,(6336000,3356)
                                      ,(10807373,29)
                                      ,(9256636,67)
                                      ,(7960921,145)
                                      ,(8012628,3053)
                                      ,(10593152,34)
                                      ,(8516022,131)
                                      ,(8516022,128)
                                      ,(8422478,827)
                                      ,(8960828,1661)
                                      ,(8127662,16)
                                      ,(2666243,126));

  /* Inforamações Acentra*/
  DELETE  tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (5)
  AND (ret.nrdconta, ret.nrdocmto) in (( 91871,1608)
                                        ,(185787,159)
                                        ,(169587,80)
                                        ,(159956,616))
  AND ret.nrdocmto in (1608,159,80,616);


  /* Inforamações Acredi*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (2)
  AND ret.nrdconta in (566705)
  AND ret.nrdocmto in (361);

  /* Inforamações AutoVale*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (16)   
  AND (ret.nrdconta,ret.nrdocmto) in ((653284,296)
                                      ,(559750,585)
                                      ,(135739,171)
                                      ,(518921,13930)
                                      ,(374288,1760)
                                      ,(511153,92)
                                      ,(325635,546));


  /* Inforamações Civia*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (13)   
  AND (ret.nrdconta, ret.nrdocmto) IN ((540,8843)
                                       ,(292869,1110)
                                       ,(292869,1143)
                                       ,(453307,9)
                                       ,(453307,8)
                                       ,(453307,7)
                                       ,(453307,6)
                                       ,(453307,4)
                                       ,(453307,3)
                                       ,(453307,2)
                                       ,(453307,1)
                                       ,(124907,443));



  /* Inforamações Credcrea*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (7)   
  AND (ret.nrdconta,ret.nrdocmto) in ((76201,2291)
                                      ,(313661,111)
                                      ,(114847,200)
                                      ,(189235,76)
                                      ,(72141,3405)
                                      ,(151874,341))
  AND ret.nrdocmto in (2291,111,200,76,3405,341);

  /* Inforamações Credcomin*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (10)   
  AND ret.nrdconta in (74926)
  AND ret.nrdocmto in (37);

  /* Inforamações Credfoz*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (11)   
  AND ret.nrdconta in (291579)
  AND ret.nrdocmto in (2404);

  /* Inforamações Evolua*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (14)   
  AND ret.nrdconta in (143812)
  AND ret.nrdocmto in (11465);

  /* Inforamações Transpocred*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (9 )   
  AND (ret.nrdconta,ret.nrdocmto) IN ((136522,2192)
                                      ,(208140,1369)
                                      ,(6378,222060)
                                      ,(121568,166)
                                      ,(172979,619)
                                      ,(224413,1374)
                                      ,(285315,59)
                                      ,(208140,1334))
  AND ret.nrdocmto in (2192,1369,222060,166,619,1374,59,1334);

  /* Inforamações Unilos*/
  DELETE   tbcobran_retorno_ieptb ret
  WHERE ret.dtconciliacao IS NULL  AND (ret.tpocorre = '1' OR ret.tpocorre = '7') 
  --
  AND ret.cdcooper in (6 )   
  AND (ret.nrdconta,ret.nrdocmto) in ((185469,69)
                                      ,(500658,1085));

  COMMIT;
