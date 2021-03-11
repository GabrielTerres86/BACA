BEGIN  
  MERGE INTO cecred.crapprm crapprm
    USING (SELECT 'CRED' nmsistem
                 ,0 cdcooper
                 ,'MONITORA_EMAIL_CALRIS' cdacesso
             FROM dual) crapprm2
    ON (crapprm.nmsistem = crapprm2.nmsistem AND crapprm.cdcooper = crapprm2.cdcooper AND crapprm.cdacesso = crapprm2.cdacesso)
    WHEN MATCHED THEN
      UPDATE
         SET dsvlrprm = 'coaf@ailos.coop.br'
    WHEN NOT MATCHED THEN
      INSERT
        (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES
        ('CRED'
        ,0
        ,'MONITORA_EMAIL_CALRIS'
        ,'Email de destino dos monitoramentos.'
        ,'coaf@ailos.coop.br');
    
  COMMIT;
END;
/