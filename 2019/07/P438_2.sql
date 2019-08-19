
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'QTD_DIAS_EXIBE_PROP_IB', 'Quantidade de dias para determinar quando as propostas/simulações não devem mais ser apresentadas na conta online.', '60');

UPDATE tbcadast_dominio_campo x
  set x.nmdominio = trim(x.nmdominio)
where x.nmdominio = 'TPRENDA '
and x.cddominio = 7;

COMMIT;
