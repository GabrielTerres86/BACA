BEGIN
  UPDATE crapaca a 
     SET a.lstparam = 'pr_nrcpfcgc,pr_nrdconta,pr_nrctro,pr_status,pr_datafim,pr_dataini,pr_crapbdc,pr_crapbdt,pr_craplim,pr_crawepr,pr_crapcpa,pr_contrliq,pr_tbrisco_oper_cc,pr_imobiliario'
   WHERE UPPER(a.nmdeacao) = 'CONSULTARRAT'
     AND UPPER(a.nmpackag) = 'TELA_RATMOV';
   
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500,SQLERRM);
END;
