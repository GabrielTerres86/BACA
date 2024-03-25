declare
vr_vllanmto craplac.vllanmto%TYPE;
vr_idprglog     NUMBER;
vr_dscritic     VARCHAR(4000);
BEGIN
  FOR rw_aplicacoes IN (select rda.cdcooper, 
                               rda.nrdconta ,
                               rda.nraplica,
                               rda.vlsdrdca,
                               rda.vlsltxmx,
                               rda.vlsltxmm,
                               rda.progress_recid 
                         FROM cecred.craprda rda
                        WHERE rda.progress_recid IN (SELECT rda.progress_recid
                                                       FROM cecred.craprda rda,
                                                            cecred.crapcop cop
                                                      WHERE rda.cdcooper = cop.cdcooper
                                                        AND trunc(rda.vlsltxmx, 2) <= 0
                                                        AND rda.insaqtot = 0
                                                        AND rda.tpaplica IN (7, 8)
                                                        AND cop.FLGATIVO = 1)) LOOP
   
      SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) vllanmto into vr_vllanmto
        FROM cecred.craplap lac,cecred.craphis his
       WHERE his.cdhistor = lac.cdhistor
         AND his.cdcooper = lac.cdcooper
         AND lac.cdcooper = rw_aplicacoes.cdcooper 
         AND lac.nrdconta = rw_aplicacoes.nrdconta
         AND lac.nraplica = rw_aplicacoes.nraplica;
      
      IF  vr_vllanmto <= 0 THEN
        vr_dscritic := ' UPDATE cecred.craprda rda SET rda.insaqtot = 1
                         ,rda.vlsdrdca = ' || rw_aplicacoes.vlsdrdca ||
                       ' ,rda.vlsltxmx = ' || rw_aplicacoes.vlsltxmx ||
                       ' ,rda.vlsltxmm = ' || rw_aplicacoes.vlsltxmm ||
                       ' WHERE progress_recid = ' || rw_aplicacoes.progress_recid ;
        CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => 'INC0302555',
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
        UPDATE cecred.craprda rda
           SET rda.insaqtot = 1
               ,rda.vlsdrdca = 0
               ,rda.vlsltxmx = 0
               ,rda.vlsltxmm = 0
        WHERE progress_recid = rw_aplicacoes.progress_recid ;
      END IF;
  
      end loop;
      
      COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Altera saldo indevido II inc0302555 ');
  
END;
