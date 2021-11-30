declare
begin 
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'DATATRUST_ATIVO_ADM_D', 'Parâmetro de definição de envio ou não de análise ao Datatrust na admissão digital', 'true');
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'DATATRUST_ATIVO_ADM_P', 'Parâmetro de definição de envio ou não de análise ao Datatrust na admissão presencial', 'true');
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'SCORE_ENV_INAT_ADM_D', 'Score padrão quando o envio ao Datatrust está inativo na admissão digital', '0.00');
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'SCORE_ENV_INAT_ADM_P', 'Score padrão quando o envio ao Datatrust está inativo na admissão presencial', '0.00');
commit;
end;
/