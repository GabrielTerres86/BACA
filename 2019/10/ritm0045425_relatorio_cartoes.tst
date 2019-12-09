PL/SQL Developer Test script 3.0
24
/* 25/10/2019 - ritm0045425 relatório dos cartões e respectivos endereços dos cooperados da Viacredi (Carlos) */
DECLARE
  i INTEGER;
BEGIN

i := cecred.exporta_tabela_para_csv(p_query => 'SELECT r.nrconta_cartao, c.nrdconta, c.nrcrcard, w.insitcrd, e.dsendere, e.nrendere, e.nmbairro, e.complend, e.nrcepend, e.nmcidade, e.cdufende 
  FROM crapcrd c, crawcrd w, tbcrd_conta_cartao r, crapenc e, crapass a
 WHERE c.cdcooper = 1
   AND c.cdcooper = a.cdcooper
   AND c.nrdconta = a.nrdconta
   AND c.cdcooper = w.cdcooper
   AND c.nrdconta = w.nrdconta   
   AND c.nrctrcrd = w.nrctrcrd
   AND w.cdcooper = r.cdcooper
   AND w.nrdconta = r.nrdconta
   AND r.cdcooper = e.cdcooper
   AND r.nrdconta = e.nrdconta
   AND e.tpendass = CASE a.inpessoa WHEN 1 THEN 10 WHEN 2 THEN 9 WHEN 3 THEN 9 END   
   AND e.idseqttl = 1',
   p_dir => '/micros/cecred/carlos/ritm0045425/', --\\pkgprod\micros\cecred\carlos\ritm0045425
   p_arquivo => 'cartoes_viacredi.csv',
   p_formato_data => 'DD/MM/YYYY');

END;
0
0
