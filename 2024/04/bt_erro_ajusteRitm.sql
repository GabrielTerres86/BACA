BEGIN

  UPDATE CECRED.tbepr_portabilidade TP
     SET TP.flgerro_efetivacao = 1
   WHERE TP.CDCOOPER = 13
     and TP.NRDCONTA = 16904974
     and TP.NRCTREMP = 338282;

  UPDATE CECRED.crawepr A
     SET A.dtlibera = to_date('03/04/2024', 'DD/MM/YYYY')
   WHERE A.CDCOOPER = 13
     and A.NRDCONTA = 16904974
     and A.NRCTREMP = 338282;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;