update crapepr   e
set e.inliquid = 1
where e.tpemprst = 1
AND e.tpdescto = 2
AND e.inliquid = 0
AND e.dtliquid is not null
AND (e.cdcooper ,e.nrdconta ,e.nrctremp) in
(
    SELECT  l.cdcooper
           ,l.nrdconta
           ,l.nrctremp
              FROM craplem   l
              JOIN craphis   h
                ON h.cdcooper = l.cdcooper
               AND h.cdhistor = l.cdhistor
             WHERE l.cdcooper = e.cdcooper
               AND l.nrdconta = e.nrdconta
               AND l.nrctremp = e.nrctremp
               AND l.cdhistor NOT IN (
                       1047, 1076     -- Multa
                      ,1540, 1618     -- Multa Aval
                      ,1077, 1078     -- Juros de Mora
                      ,1619, 1620     -- Juros de Mora Aval
                      ,1048           -- Desconto
                      ,2311, 2312 )   -- IOF
    HAVING SUM(CASE WHEN h.indebcre = 'C' THEN -l.vllanmto
                            WHEN h.indebcre = 'D' THEN l.vllanmto
                       END) = 0
    GROUP BY  l.cdcooper
             ,l.nrdconta
             ,l.nrctremp
)
/

commit
/
