-- incluir parametro para identificar o coordenador a assinar
UPDATE CRAPACA 
SET LSTPARAM = LSTPARAM || ',pr_tipo_acao'
WHERE NMDEACAO = 'INSERE_APROVADOR_CRD'
  AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';

COMMIT;