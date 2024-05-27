begin

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
               values ('CRED', 0, 'QTDIAEXPURGOCARGA_RISCO', 'Quantidade de dias que sera mantido os dados de carga antes de realizar o expurgo das cargas geradas para central de risco', '360');

  commit;
end;