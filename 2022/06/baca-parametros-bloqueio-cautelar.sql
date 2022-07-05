declare
begin 
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'VLCORTE_DICT_BLQ_CAUT', 
'Valor de corte das transações para determinar a DICT deve ser consultada ou não no bloqueio cautelar.', '30,00');

INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'HRDESAB_DICT_BLQ_CAUT', 
'Quantidade de horas após a ultima atualização que determinará se o registro com informações da DICT estará desatualizado.', '2');

INSERT INTO cecred.crapaca (nmdeacao, nmpackag, nmproced, nrseqrdr) values ('CADFRA_BUSCA_PARAM_BLQ_CAUTELAR', 'TELA_CADFRA', 'pc_busca_parametros_bloqueio_cautelar', 704);

INSERT INTO cecred.crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values ('CADFRA_GRAVA_PARAM_BLQ_CAUTELAR', 'TELA_CADFRA', 'pc_grava_parametros_bloqueio_cautelar',
'pr_vlcortedict,pr_hrdesabilitado', 704);

UPDATE cecred.craptel
SET CDOPPTEL = 'C,A,E,B,G', LSOPPTEL = 'CONSULTAR,ALTERAR,EXCLUIR,BLOQUEAR,CAUTELAR'
WHERE nmdatela = 'CADFRA';
commit;
end;
/
