BEGIN
  INSERT INTO crapprm c
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED'
    ,0
    ,'NMARQ_IMPRES_ATENDA_API'
    ,'Manual de API a ser impresso na tela Atenda -> Plataforma API -> Imprimir'
    ,'TermoPlataformaAPI.pdf');
  COMMIT;
END;