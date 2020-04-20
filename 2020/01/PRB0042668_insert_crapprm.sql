
INSERT 
  INTO crapprm(nmsistem
              ,cdcooper
              ,cdacesso
              ,dstexprm
              ,dsvlrprm)
VALUES('CRED'
      ,0
      ,'VERIFICA_CONTA_DEVOLU'
      ,'Verifica se devemos bloquear a devolucao de cheques sem conta informada (1 = Verifica / 0 = Nao verifica)'
      ,'1');

COMMIT;
