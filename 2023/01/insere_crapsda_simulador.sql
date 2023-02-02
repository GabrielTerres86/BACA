DECLARE
cursor cr_crapass IS
  SELECT nrdconta, cdcooper
    from CRAPASS where (nrdconta =  365343   and cdcooper = 5)
    or (nrdconta =  1178520  and cdcooper = 2) 
    or (nrdconta =  746940   and cdcooper = 13) 
    or (nrdconta =  452041   and cdcooper = 7) 
    or (nrdconta =  64149    and cdcooper = 8) 
    or (nrdconta =  241830   and cdcooper = 10) 
    or (nrdconta =  970786   and cdcooper = 11) 
    or (nrdconta =  211044   and cdcooper = 12) 
    or (nrdconta =  403237   and cdcooper = 14) 
    or (nrdconta =  564699   and cdcooper = 9) 
    or (nrdconta =  268291   and cdcooper = 6) 
    or (nrdconta =  15352927 and cdcooper = 1) 
    or (nrdconta =  1070274  and cdcooper = 16) ;

cursor cr_crapsda(pr_nrdconta crapass.nrdconta%type, pr_cdcooper crapass.cdcooper%type) IS
  select * from (
    select 
       pr_nrdconta as nrdconta
      ,pr_cdcooper as CDCOOPER
      ,(select dtmvtolt from crapdat where cdcooper = pr_cdcooper) as dtmvtolt
      ,VLSDDISP
      ,VLSDCHSL
      ,VLSDBLOQ
      ,VLSDBLPR
      ,VLSDBLFP
      ,VLSDINDI
      ,VLLIMCRE
      ,VLSDEVED
      ,VLDESCHQ
      ,VLLIMUTL
      ,VLADDUTL
      ,VLSDRDCA
      ,VLSDRDPP
      ,VLLIMDSC
      ,VLPREPLA
      ,VLPRERPP
      ,VLCRDSAL
      ,QTCHQLIQ
      ,QTCHQASS
      ,DTDSDCLQ
      ,VLTOTPAR
      ,VLOPCDIA
      ,VLAVALIZ
      ,VLAVLATR
      ,QTDEVOLU
      ,VLTOTREN
      ,VLDESTIT
      ,VLLIMTIT
      ,VLSDEMPR
      ,VLSDFINA
      ,VLSRDC30
      ,VLSRDC60
      ,VLSRDCPR
      ,VLSRDCPO
      ,VLSDCOTA
      ,VLBLQJUD
      ,VLBLQACO
      ,VLLIMCPA
      ,VLBLQPRJ
      ,VLLIMCRDPA
      ,VLBLQAPLI
    from crapsda sda where nrdconta = 99999617)
  where rownum = 1;

BEGIN
  FOR rw_crapass IN cr_crapass LOOP  
      FOR rw_crapsda IN cr_crapsda(rw_crapass.nrdconta, rw_crapass.cdcooper) LOOP
        INSERT INTO crapsda (
           nrdconta
          ,CDCOOPER
          ,dtmvtolt
          ,VLSDDISP
          ,VLSDCHSL
          ,VLSDBLOQ
          ,VLSDBLPR
          ,VLSDBLFP
          ,VLSDINDI
          ,VLLIMCRE
          ,VLSDEVED
          ,VLDESCHQ
          ,VLLIMUTL
          ,VLADDUTL
          ,VLSDRDCA
          ,VLSDRDPP
          ,VLLIMDSC
          ,VLPREPLA
          ,VLPRERPP
          ,VLCRDSAL
          ,QTCHQLIQ
          ,QTCHQASS
          ,DTDSDCLQ
          ,VLTOTPAR
          ,VLOPCDIA
          ,VLAVALIZ
          ,VLAVLATR
          ,QTDEVOLU
          ,VLTOTREN
          ,VLDESTIT
          ,VLLIMTIT
          ,VLSDEMPR
          ,VLSDFINA
          ,VLSRDC30
          ,VLSRDC60
          ,VLSRDCPR
          ,VLSRDCPO
          ,VLSDCOTA
          ,VLBLQJUD
          ,VLBLQACO
          ,VLLIMCPA
          ,VLBLQPRJ
          ,VLLIMCRDPA
          ,VLBLQAPLI
        ) VALUES (
           rw_crapsda.nrdconta
          ,rw_crapsda.CDCOOPER
          ,rw_crapsda.dtmvtolt
          ,rw_crapsda.VLSDDISP
          ,rw_crapsda.VLSDCHSL
          ,rw_crapsda.VLSDBLOQ
          ,rw_crapsda.VLSDBLPR
          ,rw_crapsda.VLSDBLFP
          ,rw_crapsda.VLSDINDI
          ,rw_crapsda.VLLIMCRE
          ,rw_crapsda.VLSDEVED
          ,rw_crapsda.VLDESCHQ
          ,rw_crapsda.VLLIMUTL
          ,rw_crapsda.VLADDUTL
          ,rw_crapsda.VLSDRDCA
          ,rw_crapsda.VLSDRDPP
          ,rw_crapsda.VLLIMDSC
          ,rw_crapsda.VLPREPLA
          ,rw_crapsda.VLPRERPP
          ,rw_crapsda.VLCRDSAL
          ,rw_crapsda.QTCHQLIQ
          ,rw_crapsda.QTCHQASS
          ,rw_crapsda.DTDSDCLQ
          ,rw_crapsda.VLTOTPAR
          ,rw_crapsda.VLOPCDIA
          ,rw_crapsda.VLAVALIZ
          ,rw_crapsda.VLAVLATR
          ,rw_crapsda.QTDEVOLU
          ,rw_crapsda.VLTOTREN
          ,rw_crapsda.VLDESTIT
          ,rw_crapsda.VLLIMTIT
          ,rw_crapsda.VLSDEMPR
          ,rw_crapsda.VLSDFINA
          ,rw_crapsda.VLSRDC30
          ,rw_crapsda.VLSRDC60
          ,rw_crapsda.VLSRDCPR
          ,rw_crapsda.VLSRDCPO
          ,rw_crapsda.VLSDCOTA
          ,rw_crapsda.VLBLQJUD
          ,rw_crapsda.VLBLQACO
          ,rw_crapsda.VLLIMCPA
          ,rw_crapsda.VLBLQPRJ
          ,rw_crapsda.VLLIMCRDPA
          ,rw_crapsda.VLBLQAPLI
        );
      END LOOP;
  END LOOP;
  commit;

END;
