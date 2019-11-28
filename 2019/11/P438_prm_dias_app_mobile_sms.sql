select * from CECRED.DISPOSITIVOMOBILE t where t.cooperativaid = 1 and t.numeroconta = 6101046

/*Parâmetro de dias para verificar atividade no aplicativo mobile para envio de SMS */
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIAS_ACE_APP_MOBILE_SMS', 'Quantidade máxima de dias para verificar atividade no aplicativo mobile para envio de SMS.', '30');

COMMIT;
