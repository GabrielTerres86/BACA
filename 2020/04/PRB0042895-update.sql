--PRB0042895 - alterar registros já com exclusão do Serasa-

declare
  cursor cr_dados_serasa is
    SELECT cob.rowid
      FROM tbcobran_his_neg_serasa t, crapcob cob
     WHERE TRUNC(t.dhhistorico) >= '01/01/2020'
       AND t.inserasa = 0
       AND cob.cdcooper = t.cdcooper
       AND cob.nrdconta = t.nrdconta
       AND cob.nrcnvcob = t.nrcnvcob
       AND cob.nrdocmto = t.nrdocmto
       AND cob.incobran = 0
       AND cob.inserasa = 0
       AND cob.insitcrt = 0;

begin
  for rw_dados in cr_dados_serasa loop
    begin
      update crapcob  set flserasa = 0, qtdianeg = 0 where rowid = rw_dados.rowid;
    end;
  end loop;
  commit;
end;

