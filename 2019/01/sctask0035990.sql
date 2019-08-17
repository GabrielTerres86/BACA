/*
   Script para criação de parêmetros a serem usados nas rotinas de recebimento de cheques e títlus/faturas.
   
   sctask0025990


*/

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BANCOS_BLQ_CHQ', 'Bancos que não podemos mais aceitar o recebimento de cheques.', '12,231,353,356,409,479,399');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BANCOS_BLQ_TIT', 'Bancos que não podemos mais aceitar inclusão de titulos.', '12,231,353,356,409,479');


COMMIT;
