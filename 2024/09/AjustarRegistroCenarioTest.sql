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
  
  UPDATE crapass t
     SET t.vllimcre = 5000
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta;

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
                     ,vr_nrdconta
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
                     ,vr_cdcooper
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
