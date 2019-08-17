-- Regerar e postar o relatório crrl214 do dia 20/02 devido a erros na postagem deste dia para cooperativa 16 - Viacredi AltoVale
UPDATE CRAPSLR S
   SET S.DTINIGER = NULL,
       S.DTFIMGER = NULL,
     S.FLGERADO = 'N'
WHERE s.dtmvtolt = '20/02/2019'
  and s.dsjasper = 'crrl214.jasper'
  and s.cdcooper = 16;
   
COMMIT;

