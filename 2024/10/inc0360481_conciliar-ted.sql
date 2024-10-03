BEGIN

  UPDATE cecred.tbfin_recursos_movimento
     SET dtconciliacao      = SYSDATE
        ,dsdevted_descricao = 'TED conciliada via INC0360481'
   WHERE IDLANCTO = 115171;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0360481');
    RAISE;
END;
