BEGIN
  
  UPDATE crapprm prm
       SET PRM.DSVLRPRM = '950;16#951;12#952;13#953;15#954;17#955;14#756;11#986;18'
  WHERE prm.nmsistem = 'CRED'
  AND prm.cdcooper = 0 
  AND prm.cdacesso = 'CRED_DEPARA_TIPOCARTAO';       

COMMIT;
END;



         
