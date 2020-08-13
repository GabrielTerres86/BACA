/*
(Luiz Cherpers(Mouts) - INC0057772)
ajuste no campo INSERASA = 0
*/
declare
  -- Local variables here
  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);

  cursor cr_crapcob is
    SELECT cob.rowid
      FROM crapcob cob
     WHERE cob.nrdconta = 10389733
       AND cob.cdcooper = 1
       AND cob.nrcnvcob = 101004
       AND cob.nrdocmto in (1413, 1414, 1415, 1416)
       AND cob.inserasa = 6; -- recusado serasa

begin
  for rw_dados in cr_crapcob loop
    begin
      update crapcob set INSERASA = 0 
         where rowid = rw_dados.rowid;
    
      paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_dados.rowid,
                                    pr_cdoperad => '1',
                                    pr_dtmvtolt => trunc(SYSDATE),
                                    pr_dsmensag => 'Indicador de integracao com Serasa ajustado manualmente',
                                    pr_des_erro => vr_dserro,
                                    pr_dscritic => vr_dscritic);
    end;
  
    commit;
  end loop;
end;
