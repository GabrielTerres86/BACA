BEGIN
INSERT INTO CECRED.CRAPSDA(NRDCONTA,DTMVTOLT,VLSDDISP,VLSDCHSL,VLSDBLOQ,VLSDBLPR,VLSDBLFP,VLSDINDI,VLLIMCRE,CDCOOPER,VLSDEVED,VLDESCHQ,VLLIMUTL,VLADDUTL,VLSDRDCA,VLSDRDPP,VLLIMDSC,VLPREPLA,VLPRERPP,VLCRDSAL,QTCHQLIQ,QTCHQASS,DTDSDCLQ,VLTOTPAR,VLOPCDIA,VLAVALIZ,VLAVLATR,QTDEVOLU,VLTOTREN,VLDESTIT,VLLIMTIT,VLSDEMPR,VLSDFINA,VLSRDC30,VLSRDC60,VLSRDCPR,VLSRDCPO,VLSDCOTA,VLBLQJUD,VLBLQACO,VLLIMCPA,VLBLQPRJ,VLLIMCRDPA,VLBLQAPLI) 
VALUES (84172509,to_date('27/08/2024','dd/mm/yyyy'),0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,40,0,0,0,0,NULL,0,0,1982.9,230.82,0,3000,0,0,0,0,0,0,0,0,93.92,0,0,0,0,NULL,0);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;