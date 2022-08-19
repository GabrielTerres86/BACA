DECLARE
  vr_code NUMBER;
  vr_errm VARCHAR2(64);
BEGIN
  
  -- Conta Adm Viacredi
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,1
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'7239530');
  
  -- Conta Adm Acredicoop
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,2
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'820024');
    
  -- Conta Adm Acentra
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,5
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'50008');
    
  -- Conta Adm Unilos
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,6
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'850004');
    
  -- Conta Adm Credcrea
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,7
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'40002');
    
  -- Conta Adm Credelesc
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,8
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'7239530');
    
  -- Conta Adm Transpocred
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,9
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'4006');
    
  -- Conta Adm Credicomin
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,10
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'9008');
    
  -- Conta Adm Credifoz
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,11
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'9148');

  -- Conta Adm Crevisc
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,12
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'850012');

  -- Conta Adm Civia
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,13
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'7239530');

  -- Conta Adm Evolua
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,14
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'59650');

  -- Conta Adm Alto Vale
  INSERT INTO CECRED.CRAPPRM P
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
  VALUES
  ('CRED'
  ,16
  ,'CONTAADM_DEVOLUCAO_PIX'
  ,'Conta administrativa da Cooperativa, para receber os valores a devolver e enviar via Pix ao ex-cooperado pela solicitação ASVR9810'
  ,'830003');

  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir as Contas Administrativas - ' || vr_code || ' / ' || vr_errm);
END;    
