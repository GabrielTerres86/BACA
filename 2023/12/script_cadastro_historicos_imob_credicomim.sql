BEGIN

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED/GARANTIDO/PF/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED_HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_BOLETO_IQ_CRED_SFI_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_GARANTIDO\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_HOME\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDIQ_SFI_SFH\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CABINE_TEDVD_SFI_SFH\%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CANCELA_ADM_DEB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10C,10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CANCELA_ADM_DEB_SFI/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CONTRATO_CRED/GARANTIDO/PF/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CONTRATO_CRED/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/002%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10D')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_CRED_SFI/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/002%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10F')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/GARANTIDO/01F,%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/GARANTIDO/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10D')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_DEB_SFI/PJ/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_REEMB_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10C,10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_REEMB_SFI/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10F,10G')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_GARANTIDO/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10C')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_HOME/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDIQ_SFI_SFH/%');

  UPDATE cecred.crappat a
     SET a.nmpartar = CONCAT(a.nmpartar, ',10B,10D,10A')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE 'HISTORICOS_TEDVD_SFI_SFH/%');

  COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 
