/*
Cadastra nova ação na tabela CRAPACA
Daniel Zimmermann
*/

INSERT INTO crapaca
  (NMDEACAO,
   NMPACKAG,
   NMPROCED,
   LSTPARAM,
   NRSEQRDR)
VALUES
  ('VERIFICA_BORDERO_IB',
   'DSCT0003',
   'pc_verifica_bordero_ib',
   'pr_nrdconta, pr_nrborder',
   724);

COMMIT;

/*
DELETE crapaca 
WHERE NMDEACAO = 'VERIFICA_BORDERO_IB';
COMMIT;
*/