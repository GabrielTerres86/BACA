BEGIN
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'URL_MULE_DWLD_TELAUNICA'
    ,'Url Mulesoft download tela unica'
    ,'/dev-eapi-ailosmais-frontoffice/motorcredito/v1/converter/dadostelaunica');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;

