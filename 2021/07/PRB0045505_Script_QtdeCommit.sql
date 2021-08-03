BEGIN 
  UPDATE crapprm prm
  SET prm.dsvlrprm = 500
  WHERE prm.nmsistem = 'CRED'
  AND   prm.cdacesso = 'QT_COMMITLOTEJD';

  DELETE crapprm prm
  WHERE prm.nmsistem = 'CRED'
  AND   prm.cdacesso = 'QT_ENVIOCNSJD';                         
 
  COMMIT;
EXCEPTION   
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_compleme => 'PRB0045505');  
END;
  
