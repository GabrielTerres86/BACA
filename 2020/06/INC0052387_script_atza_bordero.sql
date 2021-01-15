-- Alterar a.insitbdt de 3-Liberado para 4-liquidado
update crapbdt a
set a.insitbdt = 4--liquidado  (quando alterado para 4-liquidado, não aparece na tela atenda)
where a.nrdconta =6766404
and a.cdcooper = 1
and a.nrborder = 547576;

--Situacao do titulo: 0-nao proc,1-resgat,2-proc,3-baixado s/pagto,4-liberado
-- alterar insitit de 4-liberado para 2-processado e a.vlsldtit para valor zero.
update  craptdb a
set a.insittit = 2--processado  
   ,a.vlsldtit = 0
   ,a.vliofcpl = 0.06
   ,a.vliofprj = 0
   ,a.vlpagmra = 0.01
where a.nrdconta =6766404
and a.cdcooper = 1
and a.nrborder = 547576
and a.nrdocmto = 30;

commit;
