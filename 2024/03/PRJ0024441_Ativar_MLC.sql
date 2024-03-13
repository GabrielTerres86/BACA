BEGIN
  UPDATE crapprm prm
     SET prm.DSVLRPRM = 1
   WHERE prm.NMSISTEM = 'CRED'
     AND prm.CDCOOPER = 0
     AND prm.CDACESSO = 'MLC_ATIVO';
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'MLC_CRPS551'
    ,'Flag que determina se o fluxo de modernização de liquidação da cobrança (MLC) está ativo para o programa CRPS551'
    ,'0');
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'MLC_CRPS536'
    ,'Flag que determina se o fluxo de modernização de liquidação da cobrança (MLC) está ativo para o programa CRPS536'
    ,'0');
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'MLC_CRPS713'
    ,'Flag que determina se o fluxo de modernização de liquidação da cobrança (MLC) está ativo para o programa CRPS713'
    ,'0');
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'MLC_ENVIARSOLBXNCONC'
    ,'Flag que determina se o fluxo de modernização de liquidação da cobrança (MLC) está ativo para o programa PAGAMENTO.enviarSolicitacaoBaixaNaoConciliada'
    ,'0');
  COMMIT;
END;
