BEGIN    
  UPDATE CRAPACA
     SET LSTPARAM = LSTPARAM || ', pr_cdoperad'
   WHERE NMPROCED = 'pc_salva_blq_ope_cred_csv'
     AND NMDEACAO = 'BLQJUD_SALVAR_CSV_OPE_CRED';
   
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	RAISE_application_error(-20500, SQLERRM);
END;
/
