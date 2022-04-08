begin

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'HOST_API_INVESTIMENTO', 'URL de acesso à API de Investimento Ailos', 'http://investimentoapi.test.app.ailos.coop.br');

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ( (SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),'LCI_CONTA_HABILITADA', 'apli0013', 'pc_lci_habilitado_web', 'pr_cdcooper, pr_nrdconta', 71);

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ((SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),'LCI_HABILITAR', 'apli0013', 'pc_habilita_lci_web', 'pr_cdcooper, pr_nrdconta', 71);

commit;
end;
