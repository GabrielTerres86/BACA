BEGIN  
  UPDATE CECRED.CRAPPRM SET DSVLRPRM = 'centralsuporteaonegocio@ailos.coop.br' WHERE CDACESSO LIKE '%SAQUE_PAGUE_E-MAIL%' AND NMSISTEM = 'CRED';   
  COMMIT;
  EXCEPTION
    
    WHEN OTHERS THEN
      RAISE_application_error(-20500, SQLERRM);
      ROLLBACK;
  
END;