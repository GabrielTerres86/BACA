/* Script para criar usuarios com base no seu respectivo usuario 
   criado na cooperativa viacredi, com os mesmos acessos*/

INSERT INTO crapope
      ( cdoperad, 
        cddsenha, 
        dtaltsnh, 
        nrdedias, 
        nmoperad, 
        cdsitope, 
        nvoperad, 
        tpoperad, 
        vlpagchq, 
        cdcooper, 
        cdagenci, 
        flgdopgd, 
        flgacres, 
        dsdlogin, 
        flgdonet, 
        vlapvcre, 
        cdcomite, 
        vlestor1, 
        dsimpres, 
        vlestor2, 
        cdpactra, 
        flgperac, 
        vllimted, 
        vlapvcap, 
        cddepart, 
        insaqesp, 
        flgutcrm)
 
SELECT ope.cdoperad
      ,ope.cddsenha
      ,SYSDATE dtaltsnh
      ,ope.nrdedias
      ,ope.nmoperad
      ,ope.cdsitope
      ,ope.nvoperad
      ,ope.tpoperad
      ,ope.vlpagchq
      ,cop.cdcooper
      ,ope.cdagenci
      ,ope.flgdopgd
      ,ope.flgacres
      ,ope.dsdlogin
      ,ope.flgdonet
      ,ope.vlapvcre
      ,ope.cdcomite
      ,ope.vlestor1
      ,ope.dsimpres
      ,ope.vlestor2
      ,ope.cdpactra
      ,ope.flgperac
      ,ope.vllimted
      ,ope.vlapvcap
      ,ope.cddepart
      ,ope.insaqesp
      ,ope.flgutcrm
  FROM crapope ope
      ,crapcop cop
 WHERE UPPER(ope.cdoperad) IN ('F0030275','F0030216')
   AND ope.cdcooper = 1
   AND cop.flgativo = 1
   AND cop.cdcooper <> 3
   AND NOT EXISTS ( SELECT 1
                      FROM crapope op1
                     WHERE cop.cdcooper = op1.cdcooper
                       AND ope.cdoperad = op1.cdoperad);
                       
INSERT INTO crapace
      (nmdatela,   
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)  
SELECT ace.nmdatela, 
       ace.cddopcao, 
       ace.cdoperad, 
       ace.nmrotina, 
       cop.cdcooper, 
       ace.nrmodulo, 
       ace.idevento, 
       ace.idambace
  FROM crapace ace
      ,crapcop cop
 WHERE UPPER(ace.cdoperad) IN ('F0030275','F0030216')
   AND ace.cdcooper = 1
   AND cop.flgativo = 1
   AND cop.cdcooper <> 3
   AND cop.cdcooper >= 1
   AND NOT EXISTS ( SELECT 1
                      FROM crapace ac1
                     WHERE cop.cdcooper = ac1.cdcooper
                       AND UPPER(ace.NMDATELA) = UPPER(ac1.NMDATELA)
                       AND UPPER(ace.cdoperad) = UPPER(ac1.cdoperad)
                       AND UPPER(ace.CDDOPCAO) = UPPER(ac1.CDDOPCAO)
                       AND ace.IDAMBACE = ac1.IDAMBACE );
                       
                       
commit;