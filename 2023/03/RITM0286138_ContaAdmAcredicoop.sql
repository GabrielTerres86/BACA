DECLARE
  vr_code           NUMBER;
  vr_errm           VARCHAR2(64);
  vr_globalname     VARCHAR2(100);
  vr_nrdcontaAdm    cecred.crapass.nrdconta%type;
  
  vc_bdprod         CONSTANT VARCHAR2(100) := 'AYLLOSP';
BEGIN
  
  SELECT GLOBAL_NAME
    INTO vr_globalname
    FROM GLOBAL_NAME;
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '850012';
  ELSE
    vr_nrdcontaAdm := '99149923';  
  END IF;
  
  UPDATE CRAPPRM P
     SET P.DSVLRPRM = vr_nrdcontaAdm
   WHERE P.CDCOOPER = 2
     AND P.CDACESSO = 'CONTAADM_DEVOLUCAO_PIX'
     AND P.NMSISTEM = 'CRED'; 

  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao modificar a Conta Administrativa ACREDICOOP - ' || vr_code || ' / ' || vr_errm);
END;    
