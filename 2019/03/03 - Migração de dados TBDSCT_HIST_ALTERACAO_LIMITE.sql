-- 1º Liberação proposta confirmada
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
        ,'LIBERAÇÃO DE LIMITE'
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
                        AND hal.dsmotivo = 'LIBERAÇÃO DE LIMITE' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 2º Liberação contrato cancelado
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
        ,'LIBERAÇÃO DE LIMITE'
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
                        AND hal.dsmotivo = 'LIBERAÇÃO DE LIMITE' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 3º Manutenção / Majoração
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
              THEN 'MAJORAÇÃO' ELSE 'MANUTENÇÃO' END || ' DE LIMITE'
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
                        AND (hal.dsmotivo = 'MAJORAÇÃO DE LIMITE' OR hal.dsmotivo = 'MANUTENÇÃO DE LIMITE') )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 4º Renovação
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
        ,'RENOVAÇÃO '||
         CASE WHEN lim.tprenova = 'M' THEN 'MANUAL' ELSE 'AUTOMÁTICA' END
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
                        AND hal.dsmotivo LIKE 'RENOVAÇÃO%' )
   ORDER BY lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim;

  COMMIT;
END;
/
-- 5º Canelcamento
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
