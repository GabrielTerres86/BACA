BEGIN
  
insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'NM_ARQ_PAC_FECHAM_PROVIS', 'Nome do arquivo de Fechamento provis�rio do dia em que o relat�rio � executado', 'FAC64003');

insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'NM_ARQ_PAC_FECHAM_DEFIN', 'Nome do arquivo de Fechamento definitivo do dia anterior', 'FAC64009');

COMMIT;

END;
