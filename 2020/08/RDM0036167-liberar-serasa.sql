/*
(Luiz Cherpers(Mouts) - RDM0036167)
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
       AND cob.inserasa = 0; 

begin
  for rw_dados in cr_crapcob loop
    begin
    
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
    

    end;
  
    commit;
  end loop;
end;
