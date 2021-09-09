declare
begin 
  
INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'NR_REINCID_TEL_FRAUDE', 'Número de reincidências de telefone na admissão digital', '3');

INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'NR_REINCID_EMAIL_FRAUDE', 'Número de reincidências de e-mail na admissão digital', '3');

INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'NR_MESES_HIST_ADM', 'Porcentagem que define risco alto de fraude na admissão', '18');

commit;
end;
/