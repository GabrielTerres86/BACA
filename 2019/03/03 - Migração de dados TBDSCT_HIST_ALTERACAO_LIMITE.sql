-- 1� Libera��o proposta confirmada
BEGIN
  INSERT INTO cecred.tbdsct_hist_alteracao_limite
        (cdcooper
        ,nrdconta
        ,tpctrlim
        ,nrctrlim
        ,dtinivig
        ,dtfimvig
        ,vllimite
        ,insitlim
        ,dhalteracao
        ,dsmotivo)
  SELECT lim.cdcooper
        ,lim.nrdconta
        ,lim.tpctrlim
        ,lim.nrctrlim
        ,lim.dtinivig
        ,lim.dtfimvig
        ,lim.vllimite
        ,lim.insitlim
        ,lim.dtpropos
        ,'LIBERA��O DE LIMITE'
    FROM crawlim lim
        ,crapcop cop
   WHERE lim.nrctrmnt = 0
     AND lim.insitlim = 2
     AND lim.tpctrlim = 3
     AND lim.cdcooper = cop.cdcooper
     AND cop.flgativo = 1
     AND NOT EXISTS( SELECT 1
                       FROM tbdsct_hist_alteracao_limite hal
                      WHERE hal.cdcooper = lim.cdcooper
                        AND hal.nrdconta = lim.nrdconta
                        AND hal.tpctrlim = lim.tpctrlim
                        AND hal.nrctrlim = lim.nrctrlim
                        AND hal.dsmotivo = 'LIBERA��O DE LIMITE' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 2� Libera��o contrato cancelado
BEGIN
  INSERT INTO cecred.tbdsct_hist_alteracao_limite
        (cdcooper
        ,nrdconta
        ,tpctrlim
        ,nrctrlim
        ,dtinivig
        ,dtfimvig
        ,vllimite
        ,insitlim
        ,dhalteracao
        ,dsmotivo)
  SELECT lim.cdcooper
        ,lim.nrdconta
        ,lim.tpctrlim
        ,lim.nrctrlim
        ,lim.dtinivig
        ,lim.dtfimvig
        ,lim.vllimite
        ,2
        ,lim.dtpropos
        ,'LIBERA��O DE LIMITE'
    FROM craplim lim
        ,crapcop cop
   WHERE lim.insitlim = 3
     AND lim.tpctrlim = 3
     AND lim.cdcooper = cop.cdcooper
     AND cop.flgativo = 1
     AND NOT EXISTS( SELECT 1
                       FROM tbdsct_hist_alteracao_limite hal
                      WHERE hal.cdcooper = lim.cdcooper
                        AND hal.nrdconta = lim.nrdconta
                        AND hal.tpctrlim = lim.tpctrlim
                        AND hal.nrctrlim = lim.nrctrlim
                        AND hal.dsmotivo = 'LIBERA��O DE LIMITE' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 3� Manuten��o / Majora��o
BEGIN
  INSERT INTO cecred.tbdsct_hist_alteracao_limite
        (cdcooper
        ,nrdconta
        ,tpctrlim
        ,nrctrlim
        ,dtinivig
        ,dtfimvig
        ,vllimite
        ,insitlim
        ,dhalteracao
        ,dsmotivo)
  SELECT lim.cdcooper
        ,lim.nrdconta
        ,lim.tpctrlim
        ,lim.nrctrlim
        ,lim.dtinivig
        ,lim.dtfimvig
        ,lim.vllimite
        ,lim.insitlim
        ,lim.dtpropos
        ,CASE WHEN (SELECT mnt.vllimite
                      FROM crawlim mnt
                     WHERE mnt.cdcooper = lim.cdcooper
                       AND mnt.nrdconta = lim.nrdconta
                       AND mnt.tpctrlim = lim.tpctrlim
                       AND mnt.nrctrlim = lim.nrctrmnt) > lim.vllimite 
              THEN 'MAJORA��O' ELSE 'MANUTEN��O' END || ' DE LIMITE'
    FROM crawlim lim
        ,crapcop cop
   WHERE lim.nrctrmnt > 0
     AND lim.insitlim = 2
     AND lim.tpctrlim = 3
     AND lim.cdcooper = cop.cdcooper
     AND cop.flgativo = 1
     AND NOT EXISTS( SELECT 1
                       FROM tbdsct_hist_alteracao_limite hal
                      WHERE hal.cdcooper = lim.cdcooper
                        AND hal.nrdconta = lim.nrdconta
                        AND hal.tpctrlim = lim.tpctrlim
                        AND hal.nrctrlim = lim.nrctrlim
                        AND (hal.dsmotivo = 'MAJORA��O DE LIMITE' OR hal.dsmotivo = 'MANUTEN��O DE LIMITE') )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 4� Renova��o
BEGIN
  INSERT INTO cecred.tbdsct_hist_alteracao_limite
        (cdcooper
        ,nrdconta
        ,tpctrlim
        ,nrctrlim
        ,dtinivig
        ,dtfimvig
        ,vllimite
        ,insitlim
        ,dhalteracao
        ,dsmotivo)
  SELECT lim.cdcooper
        ,lim.nrdconta
        ,lim.tpctrlim
        ,lim.nrctrlim
        ,lim.dtinivig
        ,lim.dtfimvig
        ,lim.vllimite
        ,2
        ,lim.dtrenova
        ,'RENOVA��O '||
         CASE WHEN lim.tprenova = 'M' THEN 'MANUAL' ELSE 'AUTOM�TICA' END
    FROM craplim lim
        ,crapcop cop
   WHERE lim.qtrenova > 0
     AND lim.dtrenova IS NOT NULL
     AND lim.tpctrlim = 3
     AND lim.cdcooper = cop.cdcooper
     AND cop.flgativo = 1
     AND NOT EXISTS( SELECT 1
                       FROM tbdsct_hist_alteracao_limite hal
                      WHERE hal.cdcooper = lim.cdcooper
                        AND hal.nrdconta = lim.nrdconta
                        AND hal.tpctrlim = lim.tpctrlim
                        AND hal.nrctrlim = lim.nrctrlim
                        AND hal.dsmotivo LIKE 'RENOVA��O%' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 5� Canelcamento
BEGIN
  INSERT INTO cecred.tbdsct_hist_alteracao_limite
        (cdcooper
        ,nrdconta
        ,tpctrlim
        ,nrctrlim
        ,dtinivig
        ,dtfimvig
        ,vllimite
        ,insitlim
        ,dhalteracao
        ,dsmotivo)
  SELECT lim.cdcooper
        ,lim.nrdconta
        ,lim.tpctrlim
        ,lim.nrctrlim
        ,lim.dtinivig
        ,nvl(lim.dtcancel, lim.dtfimvig)
        ,lim.vllimite
        ,lim.insitlim
        ,lim.dtcancel
        ,'CANCELAMENTO'
    FROM craplim lim
        ,crapcop cop
   WHERE lim.insitlim = 3
     AND lim.tpctrlim = 3
     AND lim.dtcancel IS NOT NULL
     AND lim.cdcooper = cop.cdcooper
     AND cop.flgativo = 1
     AND NOT EXISTS( SELECT 1
                       FROM tbdsct_hist_alteracao_limite hal
                      WHERE hal.cdcooper = lim.cdcooper
                        AND hal.nrdconta = lim.nrdconta
                        AND hal.tpctrlim = lim.tpctrlim
                        AND hal.nrctrlim = lim.nrctrlim
                        AND hal.dsmotivo = 'CANCELAMENTO' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
