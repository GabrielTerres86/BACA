-- Parametros deposito mobile ------------------------------------
DECLARE
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);

  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST LOOP
    pr_cdcooper := coop(i);
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'DIAS_ELIM_CHEQ_MOBI', 'Dias elimina��o folha de cheque mobile', '60');
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'TP_ENVIO_EMAIL_CHQ_MOB', 'Tipo de envio de email elimina��o folha de cheque mobile. 1=PA, 2=Outros', '1');
    
    INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', pr_cdcooper, 'EMAIL_NOTI_DEPO_CHEQ_MOB', 'E-mails notifica��o cheque mobile', '');
 
  END LOOP;
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_INI_LIM_DEP_MOB', 'Hor�rio Inicio Limite Dep�sito', '09:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_FIM_LIM_DEP_MOB', 'Hor�rio Fim Limite Dep�sito', '20:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_INI_LIM_EST_MOB', 'Hor�rio Inicio Limite Estorno', '09:00');
  
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 3, 'HORA_FIM_LIM_EST_MOB', 'Hor�rio Inicio Limite Estorno', '20:00');

END;
