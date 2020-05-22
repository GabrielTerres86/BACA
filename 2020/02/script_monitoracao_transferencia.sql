INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CRED', 0, 'TRAVA_TRANSF_ATIVO', 'Controla se a trava de valor de transferencia esta habilitada', 1);

INSERT INTO crapprm
  (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES
  ('CRED', 0, 'MONITORAMENTO_TRANSF', 'Email de destino dos monitoramentos', 'monitoracaodefraudes@ailos.coop.br');

COMMIT;
