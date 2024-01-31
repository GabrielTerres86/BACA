begin

  for i in (select a.rowid tbepr_renegociacao_rowid,
                   b.rowid tbepr_renegociacao_contrato_rowid
              from tbepr_renegociacao a
             inner join tbepr_renegociacao_contrato b
                on a.cdcooper = b.cdcooper
               and a.nrdconta = b.nrdconta
               and a.nrctremp = b.nrctremp
             where a.cdcooper = 1
               and a.dtlibera > to_date('10/10/2023','dd/mm/yyyy')
               and b.tpcontrato_liquidado = 2
               and rownum <= 30) loop
  
    delete tbepr_renegociacao where rowid = i.tbepr_renegociacao_rowid;
  
    delete tbepr_renegociacao_contrato
     where rowid = i.tbepr_renegociacao_contrato_rowid;
  
  end loop;

  for i in (select a.rowid tbepr_renegociacao_rowid,
                   b.rowid tbepr_renegociacao_contrato_rowid
              from tbepr_renegociacao a
             inner join tbepr_renegociacao_contrato b
                on a.cdcooper = b.cdcooper
               and a.nrdconta = b.nrdconta
               and a.nrctremp = b.nrctremp
             where a.cdcooper = 1
               and a.dtlibera > to_date('10/10/2023','dd/mm/yyyy')
               and b.tpcontrato_liquidado = 0
               and rownum <= 30) loop
  
    delete tbepr_renegociacao where rowid = i.tbepr_renegociacao_rowid;
  
    delete tbepr_renegociacao_contrato
     where rowid = i.tbepr_renegociacao_contrato_rowid;
  
  end loop;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
