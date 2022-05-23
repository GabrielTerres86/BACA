declare
begin 
  
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
values ('CRED', 0, 'ANALISE_DICT_BLQ_CAUT', 'Valor que permite a desativação da análise de PIX no recebimento.', '0');

UPDATE cecred.crapaca c SET lstparam = 'pr_vlcortedict,pr_hrdesabilitado, pr_analise' 
WHERE c.nmdeacao = 'CADFRA_GRAVA_PARAM_BLQ_CAUTELAR' 
AND c.nmpackag = 'TELA_CADFRA' 
AND c.nmproced = 'pc_grava_parametros_bloqueio_cautelar';


commit;end;

/
