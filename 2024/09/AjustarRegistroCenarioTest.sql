DECLARE
  vr_cdcooper CONSTANT NUMBER := 7;
  vr_nrdconta CONSTANT NUMBER := 99884089;
  
BEGIN
  
  INSERT INTO crapsda(nrdconta,
                      dtmvtolt,
                      vlsddisp,
                      vlsdchsl,
                      vlsdbloq,
                      vlsdblpr,
                      vlsdblfp,
                      vlsdindi,
                      vllimcre,
                      cdcooper,
                      vlsdeved,
                      vldeschq,
                      vllimutl,
                      vladdutl,
                      vlsdrdca,
                      vlsdrdpp,
                      vllimdsc,
                      vlprepla,
                      vlprerpp,
                      vlcrdsal,
                      qtchqliq,
                      qtchqass,
                      dtdsdclq,
                      vltotpar,
                      vlopcdia,
                      vlavaliz,
                      vlavlatr,
                      qtdevolu,
                      vltotren,
                      vldestit,
                      vllimtit,
                      vlsdempr,
                      vlsdfina,
                      vlsrdc30,
                      vlsrdc60,
                      vlsrdcpr,
                      vlsrdcpo,
                      vlsdcota,
                      vlblqjud,
                      vlblqaco,
                      vllimcpa,
                      vlblqprj,
                      vllimcrdpa,
                      vlblqapli)
            ( SELECT t1.nrdconta,
                     t2.dtmvtolt,
                     t1.vlsddisp,
                     t1.vlsdchsl,
                     t1.vlsdbloq,
                     t1.vlsdblpr,
                     t1.vlsdblfp,
                     t1.vlsdindi,
                     t1.vllimcre,
                     t1.cdcooper,
                     t1.vlsdeved,
                     t1.vldeschq,
                     t1.vllimutl,
                     t1.vladdutl,
                     t1.vlsdrdca,
                     t1.vlsdrdpp,
                     t1.vllimdsc,
                     t1.vlprepla,
                     t1.vlprerpp,
                     t1.vlcrdsal,
                     t1.qtchqliq,
                     t1.qtchqass,
                     t1.dtdsdclq,
                     t1.vltotpar,
                     t1.vlopcdia,
                     t1.vlavaliz,
                     t1.vlavlatr,
                     t1.qtdevolu,
                     t1.vltotren,
                     t1.vldestit,
                     t1.vllimtit,
                     t1.vlsdempr,
                     t1.vlsdfina,
                     t1.vlsrdc30,
                     t1.vlsrdc60,
                     t1.vlsrdcpr,
                     t1.vlsrdcpo,
                     t1.vlsdcota,
                     t1.vlblqjud,
                     t1.vlblqaco,
                     t1.vllimcpa,
                     t1.vlblqprj,
                     t1.vllimcrdpa,
                     t1.vlblqapli 
                FROM crapsda t1 
                   , crapsda t2
               WHERE t1.cdcooper = vr_cdcooper
                 AND t1.nrdconta = vr_nrdconta 
                 AND t1.dtmvtolt = to_date('20/09/2024','dd/mm/yyyy')
                 AND t2.cdcooper = vr_cdcooper
                 AND t2.nrdconta = 99999552 
                 AND t2.dtmvtolt >= to_date('21/09/2024','dd/mm/yyyy'));
       
  UPDATE craplcm t
     SET t.dtmvtolt = to_date('27/09/2024','dd/mm/yyyy')
   WHERE t.cdcooper = vr_cdcooper 
     AND t.nrdconta = vr_nrdconta 
     AND t.dtmvtolt = to_date('23/09/2024','dd/mm/yyyy');
  
  COMMIT;
  
END;
