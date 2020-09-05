/*
(Luiz Cherpers(Mouts) - INC0058971)
ajuste no campo INSERASA = 0
*/
declare
  -- Local variables here
  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);

  cursor cr_crapcob is
    SELECT cob.rowid, cob.cdcooper, cob.nrdconta, cob.nrdocmto, cob.nrcnvcob
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
    
      update tbcobran_his_neg_serasa thns
         set thns.inserasa = 0
       where thns.cdcooper = rw_dados.cdcooper
         AND thns.nrdconta = rw_dados.nrdconta
         AND thns.nrdocmto = rw_dados.nrdocmto
         AND thns.nrcnvcob = rw_dados.nrcnvcob
         and thns.nrsequencia = 1;
    
      update tbcobran_his_neg_serasa thns
         set thns.inserasa = 0
       where thns.cdcooper = rw_dados.cdcooper
         AND thns.nrdconta = rw_dados.nrdconta
         AND thns.nrdocmto = rw_dados.nrdocmto
         AND thns.nrcnvcob = rw_dados.nrcnvcob
         and thns.nrsequencia = 2;
    
      update tbcobran_his_neg_serasa thns
         set thns.inserasa = 0
       where thns.cdcooper = rw_dados.cdcooper
         AND thns.nrdconta = rw_dados.nrdconta
         AND thns.nrdocmto = rw_dados.nrdocmto
         AND thns.nrcnvcob = rw_dados.nrcnvcob
         and thns.nrsequencia = 3;
    
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
