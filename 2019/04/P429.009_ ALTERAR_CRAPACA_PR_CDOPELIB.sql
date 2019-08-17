-- incluir parametro para identificar o coordenador a assinar
UPDATE CRAPACA 
SET LSTPARAM = LSTPARAM || ',pr_cdoperad'
WHERE NMDEACAO = 'INSERE_APROVADOR_CRD'
  AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';

COMMIT;