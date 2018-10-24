--> Listar creditos ocorridos apos a transferencia de prejuizo que não foram transf para o bloqueado prej
--> ** Necessario verificar se o Cred. ocorreu no mesmo dia da transf para prejuizo, porém horas antes
SELECT a.cdcooper,
       a.nrdconta,
       a.nmprimtl,
       p.dtinclusao,
       l.dtmvtolt,
       l.cdhistor,
       h.dshistor,
       l.vllanmto,
       h.dsexthst
  FROM crapass a,
       craplcm l,
       craphis h,
       tbcc_prejuizo p
 WHERE a.cdcooper = p.cdcooper
   AND a.nrdconta = p.nrdconta
   AND a.cdcooper = l.cdcooper
   AND a.nrdconta = l.nrdconta
   AND l.dtmvtolt >= p.dtinclusao
   AND l.cdcooper = h.cdcooper
   AND l.cdhistor = h.cdhistor
   AND h.indebcre = 'C'   
   AND p.cdcooper = 11
   AND p.dtliquidacao IS NULL
   AND a.cdcooper = 11
   AND a.inprejuz = 1
   AND h.intransf_cred_prejuizo = 1
   --> Buscar cred. de transf
   AND NOT EXISTS (SELECT 1 
                     FROM craplcm l2
                    WHERE l2.cdcooper = l.cdcooper
                      AND l2.nrdconta = l.nrdconta
                      AND l2.dtmvtolt = l.dtmvtolt
                      AND l2.vllanmto = l.vllanmto
                      --> que tenham no maximo 3s de dif 
                      AND l2.hrtransa - l.hrtransa < 3
                      AND l2.cdhistor = 2719
                      );
   
