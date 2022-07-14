BEGIN
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'CONSELHO REGIONAL DE CONTABILIDADE'
  WHERE E.IDORGAO_EXPEDIDOR = 12;
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'Secretaria de Defesa Social (Pernambuco)'
  WHERE E.IDORGAO_EXPEDIDOR = 55;
  
  UPDATE CECRED.TBGEN_ORGAO_EXPEDIDOR E
    SET E.Nmorgao_Expedidor = 'Registro Civil das Pessoas Naturais'
      , E.Cdorgao_Expedidor = 'CRC'
  WHERE E.IDORGAO_EXPEDIDOR = 69;
  
  DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR 
  WHERE cdorgao_expedidor = 'CRED'
    AND nmorgao_expedidor = 'Conselho Regional de Economistas Domésticos';
    
  DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR 
  WHERE cdorgao_expedidor = 'CREFONO'
    AND nmorgao_expedidor = 'Conselho Regional de Fonoaudiologia';
  
  DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR 
  WHERE cdorgao_expedidor = 'COREM'
    AND nmorgao_expedidor = 'Conselho Regional de Museologia';
  
  DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR 
  WHERE cdorgao_expedidor = 'CRT'
    AND nmorgao_expedidor = 'Conselho Regional dos Técnicos Industriais';
  
  DELETE CECRED.TBGEN_ORGAO_EXPEDIDOR 
  WHERE cdorgao_expedidor = 'CRTA'
    AND nmorgao_expedidor = 'Conselho Regional dos Técnicos Agrícolas';
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
