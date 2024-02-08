DECLARE

BEGIN

  UPDATE cecred.crapaca
     SET crapaca.nrseqrdr = 2525
   WHERE crapaca.nmpackag = 'TELA_PCRCMP'
     AND crapaca.nmproced = 'PC_LISTAR_DETALHE_MONITOR_ACMP615_640';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
