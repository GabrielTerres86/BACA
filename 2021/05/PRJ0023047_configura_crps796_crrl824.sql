begin
  --
  --configura o programa pc_crps796 e também o relatório crrl824 para as cooperativas ativas
  --
  for r_coop in (
                 --select que busca as cooperativas ativas
                 SELECT cop.cdcooper
                 FROM crapcop cop
                 WHERE cop.flgativo = 1
                 ORDER BY cop.cdcooper
                )
  loop
    --
    insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, PROGRESS_RECID, QTMINMED)
    values ('CRED', 'CRPS796', 'Gera relatorio diario produto Poupanca', '.', '.', '.', 999, 1217, 1, 824, 0, 0, 0, 0, 1, r_coop.cdcooper, null, null);
    --
    insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, PROGRESS_RECID, CDFILREL, NRSEQPRI)
    values (824, 1, 1, 'PRODUTOS DE CAPTACAO PCAPTA POUPANCA', 1, 'Financeiro', '132col', 1, r_coop.cdcooper, 'D', 1, 2, 1, ' ', null, null, null);
    --
  end loop;
  --
  commit;
  --
end;
