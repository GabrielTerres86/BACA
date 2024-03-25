BEGIN
DELETE FROM cecred.crapsda sda
 WHERE sda.cdcooper = 10
   AND trunc(sda.dtmvtolt) = trunc(to_date('13/03/2024', 'dd/mm/yyyy'));

INSERT INTO cecred.crapsda
  (nrdconta
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
  ,progress_recid
  ,vlblqaco
  ,vllimcpa
  ,vlblqprj
  ,vllimcrdpa
  ,vlblqapli)
  SELECT sda.nrdconta
        ,trunc(to_date('13/03/2024', 'dd/mm/yyyy'))
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
        ,NULL
        ,sda.vlblqaco
        ,sda.vllimcpa
        ,sda.vlblqprj
        ,sda.vllimcrdpa
        ,sda.vlblqapli
    FROM cecred.crapsda sda
   WHERE sda.cdcooper = 10
     AND trunc(sda.dtmvtolt) = trunc(to_date('04/01/2024', 'dd/mm/yyyy'));
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;