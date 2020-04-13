-- Inserir registro contendo o caminho do logo da Sicredi
INSERT INTO crapprm
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm)
VALUES
  ('CRED'
  ,0
  ,'IMG_LOGO_SICREDI'
  ,'Caminho da imagem do logo da Sicredi'
  ,'img/sicredi-logo.png');

-- Efetuar commit
COMMIT;
