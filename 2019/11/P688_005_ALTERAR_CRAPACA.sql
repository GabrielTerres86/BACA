-- incluir parametro para identificar o coordenador a assinar
UPDATE CRAPACA 
SET LSTPARAM = LSTPARAM || ',pr_txretcrd'
WHERE NMDEACAO = 'ALTERA_CALC_SOBRAS'
  AND NMPACKAG = 'TELA_SOL030';

COMMIT;