BEGIN

  UPDATE cecred.crapsld
     SET dtrefere = to_date('09/02/2024', 'dd/mm/yyyy')
   WHERE cdcooper = 6;

  FOR i IN (SELECT *
              FROM cecred.crapsda
             WHERE cdcooper = 6
               AND dtmvtolt = to_date('30/11/2023', 'dd/mm/yyyy')) LOOP
  
    INSERT INTO cecred.crapsda
      (nrdconta, dtmvtolt, vlsddisp, vlsdchsl, vlsdbloq, vlsdblpr, vlsdblfp,
       vlsdindi, vllimcre, cdcooper, vlsdeved, vldeschq, vllimutl, vladdutl,
       vlsdrdca, vlsdrdpp, vllimdsc, vlprepla, vlprerpp, vlcrdsal, qtchqliq,
       qtchqass, dtdsdclq, vltotpar, vlopcdia, vlavaliz, vlavlatr, qtdevolu,
       vltotren, vldestit, vllimtit, vlsdempr, vlsdfina, vlsrdc30, vlsrdc60,
       vlsrdcpr, vlsrdcpo, vlsdcota, vlblqjud, vlblqaco, vllimcpa, vlblqprj,
       vllimcrdpa, vlblqapli)
    VALUES
      (i.nrdconta, to_date('09/02/2024', 'dd/mm/yyyy'), i.vlsddisp,
       i.vlsdchsl, i.vlsdbloq, i.vlsdblpr, i.vlsdblfp, i.vlsdindi,
       i.vllimcre, i.cdcooper, i.vlsdeved, i.vldeschq, i.vllimutl,
       i.vladdutl, i.vlsdrdca, i.vlsdrdpp, i.vllimdsc, i.vlprepla,
       i.vlprerpp, i.vlcrdsal, i.qtchqliq, i.qtchqass, i.dtdsdclq,
       i.vltotpar, i.vlopcdia, i.vlavaliz, i.vlavlatr, i.qtdevolu,
       i.vltotren, i.vldestit, i.vllimtit, i.vlsdempr, i.vlsdfina,
       i.vlsrdc30, i.vlsrdc60, i.vlsrdcpr, i.vlsrdcpo, i.vlsdcota,
       i.vlblqjud,i.vlblqaco, i.vllimcpa, i.vlblqprj, i.vllimcrdpa,
       i.vlblqapli);
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
