DECLARE

  CURSOR cr_parametros IS
    SELECT cdcooper
         , SUBSTR(dstextab,9,5) hrtrfini
         , SUBSTR(dstextab,3,5) hrtrffim 
      FROM craptab
     WHERE UPPER(nmsistem) = 'CRED'
       AND UPPER(tptabela) = 'GENERI'
       AND cdempres        = 00
       AND UPPER(cdacesso) = 'HRTRANSFER'
       AND tpregist        = 90;
       
  vr_hrinicio   NUMBER := 14400;
  
BEGIN

  FOR prm IN cr_parametros LOOP
    
    INSERT INTO crapprm
              (nmsistem
              ,cdcooper
              ,cdacesso
              ,dstexprm
              ,dsvlrprm)
        VALUES('CRED'
              ,prm.cdcooper
              ,'FOLHA_HORA_INICIO_PROC'
              ,'Horário para início do processamento da FOLHA'
              ,vr_hrinicio);
    
    INSERT INTO crapprm
              (nmsistem
              ,cdcooper
              ,cdacesso
              ,dstexprm
              ,dsvlrprm)
        VALUES('CRED'
              ,prm.cdcooper
              ,'FOLHA_HORA_FINAL_PROC'
              ,'Horário para fim do processamento da FOLHA'
              ,prm.hrtrffim);
    
  END LOOP;

  COMMIT;

END;
