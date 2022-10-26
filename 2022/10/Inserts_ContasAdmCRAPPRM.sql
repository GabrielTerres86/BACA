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
    vr_nrdcontaAdm := '15642844';
  ELSE
    vr_nrdcontaAdm := '7239530';  
  END IF;
  
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '860000';
  ELSE
    vr_nrdcontaAdm := '820024';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '366668';
  ELSE
    vr_nrdcontaAdm := '50008';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '269948';
  ELSE
    vr_nrdcontaAdm := '850004';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '457450';
  ELSE
    vr_nrdcontaAdm := '40002';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '64548';
  ELSE
    vr_nrdcontaAdm := '7239530';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '4006';
  ELSE
    vr_nrdcontaAdm := '4006';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '243086';
  ELSE
    vr_nrdcontaAdm := '9008';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '535745';
  ELSE
    vr_nrdcontaAdm := '9148';  
  END IF;
    
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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '212040';
  ELSE
    vr_nrdcontaAdm := '850012';  
  END IF;

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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '750298';
  ELSE
    vr_nrdcontaAdm := '7239530';  
  END IF;

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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '408905';
  ELSE
    vr_nrdcontaAdm := '59650';  
  END IF;

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
  ,vr_nrdcontaAdm);
  
  IF vr_globalname = vc_bdprod THEN
    vr_nrdcontaAdm := '1057804';
  ELSE
    vr_nrdcontaAdm := '830003';  
  END IF;

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
  ,vr_nrdcontaAdm);

  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir as Contas Administrativas - ' || vr_code || ' / ' || vr_errm);
END;    
