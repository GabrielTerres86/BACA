DECLARE 

  CURSOR cr_crapsda IS
    SELECT *  
      FROM crapsda t
     WHERE t.cdcooper = 1
       AND t.nrdconta IN (9730443,9732225,9733132)
       AND T.DTMVTOLT = TO_DATE('16/06/2024','dd/mm/yyyy');

BEGIN
  
  FOR sda IN cr_crapsda LOOP
    
    BEGIN
      INSERT INTO crapsda(nrdconta
                         ,dtmvtolt
                         ,vlsddisp
                         ,vlsdchsl
                         ,vlsdbloq
                         ,vlsdblpr
                         ,vlsdblfp
                         ,vlsdindi
                         ,vllimcre
                         ,cdcooper
                         ,vlsdeved
                         ,vldeschq
                         ,vllimutl
                         ,vladdutl
                         ,vlsdrdca
                         ,vlsdrdpp
                         ,vllimdsc
                         ,vlprepla
                         ,vlprerpp
                         ,vlcrdsal
                         ,qtchqliq
                         ,qtchqass
                         ,dtdsdclq
                         ,vltotpar
                         ,vlopcdia
                         ,vlavaliz
                         ,vlavlatr
                         ,qtdevolu
                         ,vltotren
                         ,vldestit
                         ,vllimtit
                         ,vlsdempr
                         ,vlsdfina
                         ,vlsrdc30
                         ,vlsrdc60
                         ,vlsrdcpr
                         ,vlsrdcpo
                         ,vlsdcota
                         ,vlblqjud
                         ,vlblqaco
                         ,vllimcpa
                         ,vlblqprj
                         ,vllimcrdpa
                         ,vlblqapli)
                   VALUES(sda.nrdconta
                         ,to_date('17/06/2024','dd/mm/yyyy')
                         ,sda.vlsddisp
                         ,sda.vlsdchsl
                         ,sda.vlsdbloq
                         ,sda.vlsdblpr
                         ,sda.vlsdblfp
                         ,sda.vlsdindi
                         ,sda.vllimcre
                         ,sda.cdcooper
                         ,sda.vlsdeved
                         ,sda.vldeschq
                         ,sda.vllimutl
                         ,sda.vladdutl
                         ,sda.vlsdrdca
                         ,sda.vlsdrdpp
                         ,sda.vllimdsc
                         ,sda.vlprepla
                         ,sda.vlprerpp
                         ,sda.vlcrdsal
                         ,sda.qtchqliq
                         ,sda.qtchqass
                         ,sda.dtdsdclq
                         ,sda.vltotpar
                         ,sda.vlopcdia
                         ,sda.vlavaliz
                         ,sda.vlavlatr
                         ,sda.qtdevolu
                         ,sda.vltotren
                         ,sda.vldestit
                         ,sda.vllimtit
                         ,sda.vlsdempr
                         ,sda.vlsdfina
                         ,sda.vlsrdc30
                         ,sda.vlsrdc60
                         ,sda.vlsrdcpr
                         ,sda.vlsrdcpo
                         ,sda.vlsdcota
                         ,sda.vlblqjud
                         ,sda.vlblqaco
                         ,sda.vllimcpa
                         ,sda.vlblqprj
                         ,sda.vllimcrdpa
                         ,sda.vlblqapli);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
  END LOOP;
  
  COMMIT;
  
  BEGIN
    UPDATE crapsda t
       SET t.vlsdbloq = ROUND(t.nrdconta / 10000,2)
     WHERE t.cdcooper = 1
       AND t.nrdconta IN (9730443,9732225,9733132)
       AND T.DTMVTOLT = TO_DATE('17/06/2024','dd/mm/yyyy');
  EXCEPTION 
    WHEN OTHERS THEN
      NULL;
  END;
  
  COMMIT;
  
END;
