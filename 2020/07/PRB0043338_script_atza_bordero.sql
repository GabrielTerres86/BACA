-- Alterar a.insitbdt de 3-Liberado para 4-liquidado
update crapbdt a
set a.insitbdt = 4--liquidado  
 ,a.dtliqprj   = '30/06/2020'
 ,a.inprejuz   = 0 -- Não prejuizo
where a.cdcooper = 1
and a.nrdconta = 8791740
and a.nrborder = 548675;

--Situacao do titulo: 0-nao proc,1-resgat,2-proc,3-baixado s/pagto,4-liberado
-- alterar insitit de 4-liberado para 2-processado 
update  craptdb a
set a.insittit = 2--processado  
   ,a.vljraprj = 54.31 -- 0 (era zero)   
   ,a.vlmratit = 96.6  --128,64
   ,a.vliofcpl = 3.85  --5,23  
where a.cdcooper = 1
and a.nrdconta = 8791740
and a.nrborder = 548675
and a.nrdocmto = 705;

-- Valor inserido para zerar o saldo do extrato.
insert into TBDSCT_LANCAMENTO_BORDERO (CDCOOPER, NRDCONTA, NRBORDER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDOCMTO, NRSEQDIG, NRTITULO, DTMVTOLT, CDORIGEM, CDHISTOR, VLLANMTO, DTHRTRAN, DTREFATU, PROGRESS_RECID, DTESTORN)
values (1, 8791740, 548675, 0, 0, 0, 0, 98, 0, to_date('30-06-2020', 'dd-mm-yyyy'), 7, 2798, 7.55, to_date('30-06-2020 08:43:50', 'dd-mm-yyyy hh24:mi:ss'), to_date('30-06-2020 08:43:50', 'dd-mm-yyyy hh24:mi:ss'), null, null);


commit;
