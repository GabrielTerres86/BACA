
UPDATE tbepr_folha_pagto_saldo f
   SET f.vldesbloqueado = f.vlbloqueado
 WHERE ( f.cdcooper = 11
        AND f.nrdconta  IN( 496448)
        AND f.nrctremp IN (78368)
       )
   OR ( f.cdcooper = 11
        AND f.nrdconta  IN( 86029)
        AND f.nrctremp IN (79054)
       )
   OR ( f.cdcooper = 10
        AND f.nrdconta  IN( 56316)
        AND f.nrctremp IN (12681)
       )
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 1031)
        AND f.nrctremp IN (12665)
       )*/
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 56316)
        AND f.nrctremp IN (12648)
       )
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 122947)
        AND f.nrctremp IN (12615)
       )*/       
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 22195)
        AND f.nrctremp IN (28998)
       )       
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 10251)
        AND f.nrctremp IN (29116)
       )       
       */
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 199702)
        AND f.nrctremp IN (29063)
       )    
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 901717)
        AND f.nrctremp IN (29193)--28918)
       )    
   OR  ( f.cdcooper = 13
        AND f.nrdconta  IN( 249203)
        AND f.nrctremp IN (67972)--67709)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN( 3774520)
        AND f.nrctremp IN (2608273)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN( 22097732)
        AND f.nrctremp IN (2608547)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN(  9055290)
        AND f.nrctremp IN (2618600)
       );
       
    --COMMIT;
SELECT * FROM tbepr_folha_pagto_saldo f
WHERE ( f.cdcooper = 11
        AND f.nrdconta  IN( 496448)
        AND f.nrctremp IN (78368)
       )
   OR ( f.cdcooper = 11
        AND f.nrdconta  IN( 86029)
        AND f.nrctremp IN (79054)
       )
   OR ( f.cdcooper = 10
        AND f.nrdconta  IN( 56316)
        AND f.nrctremp IN (12681)
       )
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 1031)
        AND f.nrctremp IN (12665)
       )*/
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 56316)
        AND f.nrctremp IN (12648)
       )
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 10
        AND f.nrdconta  IN( 122947)
        AND f.nrctremp IN (12615)
       )*/       
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 22195)
        AND f.nrctremp IN (28998)
       )       
   /* Ja desbloqueou, não existe saldo
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 10251)
        AND f.nrctremp IN (29116)
       )       
       */
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 199702)
        AND f.nrctremp IN (29063)
       )    
   OR  ( f.cdcooper = 9
        AND f.nrdconta  IN( 901717)
        AND f.nrctremp IN (29193)--28918)
       )    
   OR  ( f.cdcooper = 13
        AND f.nrdconta  IN( 249203)
        AND f.nrctremp IN (67972)--67709)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN( 3774520)
        AND f.nrctremp IN (2608273)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN( 22097732)
        AND f.nrctremp IN (2608547)
       )    
   OR  ( f.cdcooper = 1
        AND f.nrdconta  IN(  9055290)
        AND f.nrctremp IN (2618600)
       )
       
       ;    
    
    
    
    
    
    
11 --CREDIFOZ  496448  78368 -- Ja desbloqueou, possui saldo diferente diferente
11 --CREDIFOZ  86029  79054
10 --CREDICOMIN  56316  12681
10 --CREDICOMIN  1031  12665 -- Ja desbloqueou, não existe saldo
10 --CREDICOMIN  56316  12648
10 --CREDICOMIN  122947  12615 -- Ja desbloqueou, não existe saldo
9 --TRANSPOCRED  22195   28998 -- Ja desbloqueou, possui saldo diferente diferente
9 --TRANSPOCRED  10251   29116 -- Ja desbloqueou, não existe saldo
9 --TRANSPOCRED  199702   29063
9 --TRANSPOCRED  901717   28918
13 --CIVIA  245920-3  67709
1 --VIACREDI  377452-0  2608273
1 --VIACREDI  2209773-2  2608547
1 --VIACREDI  905529-0  2618600
