DECLARE
  vr_cdcooper CONSTANT NUMBER := 7;
  vr_nrdconta CONSTANT NUMBER := 81602545;
  vr_vldsdisp NUMBER;
  
  CURSOR cr_saldo(pr_dtmvtolt DATE) IS
    SELECT * 
      FROM crapsda t 
     WHERE t.cdcooper = 1 
       AND t.nrdconta = 84794941 
       AND t.dtmvtolt = pr_dtmvtolt;
  rw_saldo  cr_saldo%ROWTYPE;
  
BEGIN
  
  UPDATE crapdat t
     SET t.dtmvtolt    = to_date('23/09/2024','dd/mm/yyyy')
       , t.dtmvtoan    = to_date('20/09/2024','dd/mm/yyyy')
       , t.dtmvtopr    = to_date('24/09/2024','dd/mm/yyyy')
       , t.dtmvtocd    = to_date('23/09/2024','dd/mm/yyyy')
       , t.dtmvcentral = to_date('23/09/2024','dd/mm/yyyy')
   WHERE t.cdcooper = vr_cdcooper;
  
  OPEN  cr_saldo(to_date('16/02/2024','dd/mm/yyyy'));
  FETCH cr_saldo INTO rw_saldo;
  CLOSE cr_saldo;
  
  vr_vldsdisp := rw_saldo.vlsddisp;
   
  UPDATE crapsda t 
     SET t.vlsddisp = rw_saldo.vlsddisp
       , t.vlsdchsl = rw_saldo.vlsdchsl
       , t.vlsdbloq = rw_saldo.vlsdbloq
       , t.vlsdblpr = rw_saldo.vlsdblpr
       , t.vlsdblfp = rw_saldo.vlsdblfp
       , t.vlsdindi = rw_saldo.vlsdindi
       , t.vllimcre = rw_saldo.vllimcre
       , t.vlsdeved = rw_saldo.vlsdeved
       , t.vldeschq = rw_saldo.vldeschq
       , t.vllimutl = rw_saldo.vllimutl
       , t.vladdutl = rw_saldo.vladdutl
       , t.vlsdrdca = rw_saldo.vlsdrdca
       , t.vlsdrdpp = rw_saldo.vlsdrdpp
       , t.vllimdsc = rw_saldo.vllimdsc
       , t.vldestit = rw_saldo.vldestit
       , t.vllimtit = rw_saldo.vllimtit
       , t.vlsdcota = rw_saldo.vlsdcota
       , t.vlblqjud = rw_saldo.vlblqjud
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta
     AND t.dtmvtolt = to_date('20/09/2024','dd/mm/yyyy');
  
  OPEN  cr_saldo(to_date('19/02/2024','dd/mm/yyyy'));
  FETCH cr_saldo INTO rw_saldo;
  CLOSE cr_saldo;
  
  DELETE crapsda t 
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta
     AND t.dtmvtolt >= to_date('23/09/2024','dd/mm/yyyy');
  
  UPDATE crapsld t
     SET t.vlsddisp = vr_vldsdisp
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta;
     
  DELETE craplcm t
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta
     AND t.dtmvtolt >= to_date('23/09/2024','dd/mm/yyyy');
     
  INSERT INTO craplcm(dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,nrseqdig
                     ,vllanmto
                     ,nrdctabb
                     ,cdpesqbb
                     ,vldoipmf
                     ,nrautdoc
                     ,nrsequni
                     ,cdbanchq
                     ,cdcmpchq
                     ,cdagechq
                     ,nrctachq
                     ,nrlotchq
                     ,sqlotchq
                     ,dtrefere
                     ,hrtransa
                     ,cdoperad
                     ,dsidenti
                     ,cdcooper
                     ,nrdctitg
                     ,dscedent
                     ,cdcoptfn
                     ,cdagetfn
                     ,nrterfin
                     ,nrparepr
                     ,nrseqava
                     ,nraplica
                     ,cdorigem
                     ,idlautom)
              (SELECT to_date('23/09/2024','dd/mm/yyyy')
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,nrseqdig
                     ,vllanmto
                     ,nrdctabb
                     ,cdpesqbb
                     ,vldoipmf
                     ,nrautdoc
                     ,nrsequni
                     ,cdbanchq
                     ,cdcmpchq
                     ,cdagechq
                     ,nrctachq
                     ,nrlotchq
                     ,sqlotchq
                     ,dtrefere
                     ,hrtransa
                     ,cdoperad
                     ,dsidenti
                     ,cdcooper
                     ,nrdctitg
                     ,dscedent
                     ,cdcoptfn
                     ,cdagetfn
                     ,nrterfin
                     ,nrparepr
                     ,nrseqava
                     ,nraplica
                     ,cdorigem
                     ,idlautom
                  FROM craplcm t 
                 WHERE ROWID IN ('AAAkspAAAAAKQaqAAN','AAAkspAAAAABQYiAAg'));
  
  COMMIT;
  
END;
