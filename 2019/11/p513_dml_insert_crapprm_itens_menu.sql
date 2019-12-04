----  inclusao itens do menu SAQUE E PAGUE na tab CRAPPRM

--ITEM IDENTIFICACAO             
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU0','068000 – Identificação','00010;1');
COMMIT;      
--ITENS SAQUE             
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU1','068010 – Saque Conta Corrente','00110;1');
COMMIT;      
--ITENS DEPOSITO             
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU2','068900 – Depósito','00210;1');
COMMIT;      
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU3','068910 – Deposito Conta Corrente Sem Cartão','00220;1');
COMMIT;              
--ITENS EXTRATO
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU4','070004 – Extrato Mensal','00310;0');
COMMIT;      
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU5','070001 – Extrato dos Últimos Movimentos','00320;0');
COMMIT;      
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU6','070002 – Extrato semanal','00330;0');
COMMIT;
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU7','070003 – Extrato quinzenal','00340;0');
COMMIT;      
--ITENS SALDO EM TELA
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU8','068001 – Saldo Conta Corrente','00410;0');
COMMIT;      
--ITENS PAGAMENTO
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_ITENS_MENU9','068020 - Pagamento com código de barras','00510;0');
COMMIT;      
--ITENS CONSULTA CONTA
insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
             values('CRED',0,'SAQUE_PAGUE_ITENS_MENU10','068004 – Consulta Conta','00120;1');
COMMIT; 