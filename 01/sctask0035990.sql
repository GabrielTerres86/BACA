/*
   Script para cria��o de par�metros a serem usados nas rotinas de recebimento de cheques e t�tlus/faturas.
   
   sctask0025990


*/

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BANCOS_BLQ_CHQ', 'Bancos que n�o podemos mais aceitar o recebimento de cheques.', '12,231,353,356,409,479,399');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BANCOS_BLQ_TIT', 'Bancos que n�o podemos mais aceitar inclus�o de titulos.', '12,231,353,356,409,479');


COMMIT;
