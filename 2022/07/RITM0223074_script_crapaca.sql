BEGIN

  UPDATE cecred.crapaca aca
     SET aca.lstparam = aca.lstparam || ',pr_nroperaca,pr_dtoperaca'
   WHERE aca.nmdeacao = 'SALVA_IMOVEL'
     AND aca.nmpackag = 'TELA_IMOVEL';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
