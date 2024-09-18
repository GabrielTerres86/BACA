DECLARE
  vr_nrseqrdr cecred.craprdr.nrseqrdr%TYPE;
BEGIN

  SELECT nrseqrdr	
   INTO vr_nrseqrdr
   FROM    cecred.craprdr a
  WHERE a.nmprogra= 'INTBRD';

  INSERT INTO cecred.crapaca
      (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES
      ('INSERE_BRD_PAYLOAD'
      ,NULL
      ,'CREDITO.incluirPayloadBorderoIntegr'
      ,'pr_rowidpayload,pr_payload '
      ,vr_nrseqrdr);
        
  INSERT INTO cecred.crapaca
      (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES
      ('ATUALIZA_BRD_PAYLOAD'
      ,NULL
      ,'CREDITO.atualizarSituacaoPayloadBordero'
      ,'pr_idintegracao,pr_cdacao,pr_dsopcao'
      ,vr_nrseqrdr);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
