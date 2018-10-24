--> Listar debitos ocorridos apos a transferencia de prejuizo
SELECT a.cdcooper,
       a.nrdconta,
       a.nmprimtl,
       p.dtinclusao,
       l.dtmvtolt,
       l.cdhistor,
       h.dshistor,
       l.vllanmto
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
   AND h.indebcre = 'D'   
   AND p.cdcooper = &pr_cdcooper
   AND p.dtliquidacao IS NULL
   AND a.cdcooper = &pr_cdcooper
   AND a.inprejuz = 1
   AND (l.cdhistor NOT IN (2719, --> EST. CREDITO
                           2718, --> JUROS REM. CC  
                             37, --> TAXA C/C NEG.
                             38, --> JUROS LIM.CRD
                           2182, --> DESP. ACORDO                            
                           2323) --> IOF S/ C-C
                          
        --> ou ocorridos depois do dia da transferencia
        OR (l.cdhistor IN (37, --> TAXA C/C NEG.
                          38) --> JUROS LIM.CRD
            AND l.dtmvtolt <> p.dtinclusao )
       );                  
