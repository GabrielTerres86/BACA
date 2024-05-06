BEGIN

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('LISTA_BENS_IMOBILIARIO'
    ,'EMPR0025'
    ,'pc_listar_bens'
    ,'pr_nrdconta,pr_nrctremp,pr_idseq_bem'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));
		
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('ALTERAR_BENS_IMOBILIARIO'
    ,'EMPR0025'
    ,'pc_alterar_bens'
    ,'pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));		

 INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM cecred.crappat)
         ,'HISTORICOS_CONTRATO_CRED/GARANTIDO/PF/PJ/01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G'
         ,2
         ,0);
  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_CONTRATO_CRED/GARANTIDO/%')
      ,3
      ,'4263');
          
  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_REEMB_SFI/%'); 

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CANCELA_ADM_DEB_SFI/%'); 

  INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM cecred.crappat)
         ,'HISTORICOS_BOLETO_IQ_CRED/GARANTIDO/PF/PJ/01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G'
         ,2
         ,0);
  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED/GARANTIDO/PF/PJ/%')
      ,3
      ,'1,15476588,4278/2,820024,4278/3,0,4278/5,850004,4278/6,850004,4278/7,850004,4278/8,30066,4278/9,0,4278/10,0,4278/11,498823,4278/12,850004,4278/13,334260,4278/14,850004,4278/16,933392,4278/');  
  INSERT INTO cecred.crappat
      (CDPARTAR
      ,NMPARTAR
      ,TPDEDADO
      ,CDPRODUT)
    VALUES
      ((SELECT MAX(cdpartar) + 1 FROM cecred.crappat)
      ,'HISTORICOS_TEDIQ_GARANTIDO/01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G'
      ,2
      ,0);

    INSERT INTO cecred.crappco
      (CDPARTAR
      ,CDCOOPER
      ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_GARANTIDO/%')
      ,3
      ,'4272,4275,4276,4277');
  
    INSERT INTO cecred.crappat
      (CDPARTAR
      ,NMPARTAR
      ,TPDEDADO
      ,CDPRODUT)
    VALUES
      ((SELECT MAX(cdpartar) + 1 FROM cecred.crappat)
      ,'HISTORICOS_CABINE_TEDIQ_GARANTIDO\01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G'
      ,2
      ,0);

    INSERT INTO cecred.crappco
      (CDPARTAR
      ,CDCOOPER
      ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_GARANTIDO\%')
      ,3
      ,'4274');
  
    INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      (118
      ,13
      ,'13A,10000,100;13B,10000,100;13C,10005,100;13D,20000,100;13E,10007,100;13F,10006,100;012,10000,100;013,10000,100;FPF,10000,100;13G,20006,100;');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED/GARANTIDO/PF/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED_HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED_SFI_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_GARANTIDO\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_HOME\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_SFI_SFH\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDVD_SFI_SFH\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CANCELA_ADM_DEB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13C,13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CANCELA_ADM_DEB_SFI/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CONTRATO_CRED/GARANTIDO/PF/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CONTRATO_CRED/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/002%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13D')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/002%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13F')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/GARANTIDO/01F,%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/GARANTIDO/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13D')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_REEMB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13C,13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_REEMB_SFI/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13F,13G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_GARANTIDO/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_SFI_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',13B,13D,13A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDVD_SFI_SFH/%');
  
  COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 
