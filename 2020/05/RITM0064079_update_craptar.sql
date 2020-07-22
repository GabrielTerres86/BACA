--RITM0064079 - Alteracao do nome das tarifas

update craptar
   set dstarifa = 'CHEQUE SUPERIOR A 5MIL'
 where cdtarifa = 50
   and cdsubgru = 12
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'SEGUNDA VIA DE DOCUMENTOS PF'
 where cdtarifa = 111
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'SEGUNDA VIA DE DOCUMENTOS PJ'
 where cdtarifa = 116
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'ESPECIAL DE EMPRESTIMO PF'
 where cdtarifa = 183
   and cdsubgru = 27
   and cdcatego = 3
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'ESPECIAL DE EMPRESTIMO PJ'
 where cdtarifa = 184
   and cdsubgru = 27
   and cdcatego = 3
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'IMPRESSAO DE DOCUMENTOS PF'
 where cdtarifa = 201
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'IMPRESSAO DE DOCUMENTOS PJ'
 where cdtarifa = 202
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'MANUTENCAO CONTA ITG PF'
 where cdtarifa = 259
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'MANUTENCAO CONTA ITG PJ'
 where cdtarifa = 260
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'MALOTE PF'
 where cdtarifa = 263
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'MALOTE PJ'
 where cdtarifa = 264
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FOLHA DE PAGAMENTO IB D0'
 where cdtarifa = 274
   and cdsubgru = 11
   and cdcatego = 2
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FOLHA DE PAGAMENTO IB D-1'
 where cdtarifa = 275
   and cdsubgru = 11
   and cdcatego = 2
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FOLHA DE PAGAMENTO IB D-2'
 where cdtarifa = 276
   and cdsubgru = 11
   and cdcatego = 2
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'SMS DEBITO AUTOMATICO PF'
 where cdtarifa = 292
   and cdsubgru = 33
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'SMS DEBITO AUTOMATICO PJ'
 where cdtarifa = 293
   and cdsubgru = 33
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'TRANSFERENCIA SALARIO INTERCOOPERATIVAS'
 where cdtarifa = 327
   and cdsubgru = 11
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'MICROFILMAGEM DE CHEQUE ELETRONICA PF'
 where cdtarifa = 368
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'MICROFILMAGEM DE CHEQUE ELETRONICA PJ'
 where cdtarifa = 369
   and cdsubgru = 17
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'EMPRESTIMO CDC VEICULOS PF'
 where cdtarifa = 381
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'EMPRESTIMO CDC VEICULOS PJ'
 where cdtarifa = 382
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'EMPRESTIMO CDC DIVERSOS PF'
 where cdtarifa = 383
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'EMPRESTIMO CDC DIVERSOS PJ'
 where cdtarifa = 384
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FINANCIAMENTO CDC VEICULOS PF'
 where cdtarifa = 386
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 1;
   
update craptar
   set dstarifa = 'FINANCIAMENTO CDC VEICULOS PJ'
 where cdtarifa = 387
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FINANCIAMENTO CDC DIVERSOS PJ'
 where cdtarifa = 389
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 2;
   
update craptar
   set dstarifa = 'FINANCIAMENTO CDC DIVERSOS PF'
 where cdtarifa = 390
   and cdsubgru = 21
   and cdcatego = 1
   and inpessoa = 1;                                          

COMMIT;
