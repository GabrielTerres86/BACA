BEGIN

  UPDATE cecred.crapaca aca
     SET aca.lstparam = aca.lstparam || ',pr_tpdlinha'
   WHERE aca.nmdeacao = 'CALCTAXA'
     AND aca.nmpackag = 'tela_lrotat';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
