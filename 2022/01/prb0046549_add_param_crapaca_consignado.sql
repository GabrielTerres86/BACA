BEGIN
  UPDATE crapaca aca
     SET aca.lstparam = 'pr_nrdconta,pr_nrctremp,pr_cdlcremp'
   WHERE aca.nmdeacao = 'SIMULA_VALIDA_CONSIGNADO';
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
