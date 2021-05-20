/* INC0090626 - Ajustar VIP de operações que receberam pagamento de entrada */

UPDATE crapcyc y
  SET y.flgehvip = 1,
      y.cdmotant = decode(cdmotcin,2,cdmotant,7,cdmotant,cdmotcin)
     ,y.cdmotcin = decode(cdmotcin,2,cdmotcin,7,cdmotcin,1)
     ,y.cdoperad = 1
     ,y.dtaltera = to_date('20/05/2021 01:01:01','DD/MM/RRRR HH24:MI:SS')
WHERE y.flgehvip = 0
AND EXISTS (  
SELECT a.cdcooper
      ,a.nrdconta
      ,x.nracordo
      ,x.nrparcela
      ,b.cdorigem
      ,b.nrctremp
      ,c.dtdpagto
      ,c.vldpagto
  FROM tbrecup_acordo_parcela  x
      ,tbrecup_acordo          a
      ,tbrecup_acordo_contrato b
      ,crapcob                 c
 WHERE 1 = 1 --x.nracordo = 321509
   AND x.nracordo = a.nracordo
   AND a.nracordo = b.nracordo
   AND c.cdcooper = a.cdcooper
   AND c.nrdconta = x.nrdconta_cob
   AND c.nrcnvcob = x.nrconvenio
   AND c.nrdocmto = x.nrboleto
   AND x.nrparcela = 0
   AND c.dtdpagto >= '30/04/2021'
   AND c.dtdpagto <= '06/05/2021'
   AND y.cdcooper = a.cdcooper
   AND y.nrdconta = a.nrdconta
   AND y.cdorigem = b.cdorigem
   AND y.nrctremp = b.nrctremp);
   
COMMIT;   
