declare
begin 
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'PERC_MEDIO_FRAUDE_ADM_P', 'Porcentagem que define risco médio de fraude na admissão presencial', '41');
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'PERC_ALTO_FRAUDE_ADM_P', 'Porcentagem que define risco alto de fraude na admissão presencial', '90');
commit;
end;
/