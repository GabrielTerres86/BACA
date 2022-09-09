BEGIN;

INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'MONIT_EMAIL_SEGCORP_PIX1', 'Email de destino dos monitoramentos erros processamento.', 'notifique@ailos.coop.br');

INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'MONIT_EMAIL_SEGCORP_PIX2', 'Email de destino dos monitoramentos erros processamento.', 'maria.pamplona@ailos.coop.br');

INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'MONIT_EMAIL_SEGCORP_PIX3', 'Email de destino dos monitoramentos erros processamento.', 'felipe.maciel@ailos.com.br');

COMMIT;

END;