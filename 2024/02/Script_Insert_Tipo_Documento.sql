BEGIN
  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (40
    ,'Troca de Cobranca'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (41
    ,' Devolucao Cobranca'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (48
    ,'Troca de Cobranca Contingencia'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (140
    ,'Troca de Cobranca DDA'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (148
    ,'Troca de Cobranca DDA Contingencia'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (715
    ,'RCO de Cobrancao DDA'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (58
    ,'Ressarcimento Devolucao Cobranca'
    ,NULL);

  INSERT INTO cobranca.ta_tipo_documento_compensacao
    (CDTIPO_DOCUMENTO_COMPENSACAO
    ,DSTIPO_DOCUMENTO_COMPENSACAO
    ,IDTIPO_DOCUMENTO_COMPENSACAO_RCO)
  VALUES
    (15
    ,'RCO de Cobranca'
    ,NULL);
    
  UPDATE cobranca.ta_tipo_documento_compensacao TD
  SET TD.IDTIPO_DOCUMENTO_COMPENSACAO_RCO = (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO = 'RCO de Cobranca')
  WHERE TD.IDTIPO_DOCUMENTO_COMPENSACAO IN (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO IN ('Troca de Cobranca','Troca de Cobranca Contingencia'));

  UPDATE cobranca.ta_tipo_documento_compensacao TD
  SET TD.IDTIPO_DOCUMENTO_COMPENSACAO_RCO = (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO = 'RCO de Cobrancao DDA')
  WHERE TD.IDTIPO_DOCUMENTO_COMPENSACAO IN (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO IN ('Troca de Cobranca DDA','Troca de Cobranca DDA Contingencia'));

  UPDATE cobranca.ta_tipo_documento_compensacao TD
  SET TD.IDTIPO_DOCUMENTO_COMPENSACAO_RCO = (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO = 'Ressarcimento Devolucao Cobranca')
  WHERE TD.IDTIPO_DOCUMENTO_COMPENSACAO IN (SELECT T.IDTIPO_DOCUMENTO_COMPENSACAO FROM cobranca.ta_tipo_documento_compensacao T 
                                 WHERE T.DSTIPO_DOCUMENTO_COMPENSACAO IN (' Devolucao Cobranca'));
    
  COMMIT;

END;
