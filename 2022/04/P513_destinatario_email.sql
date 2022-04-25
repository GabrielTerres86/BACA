BEGIN
   UPDATE CRAPPRM SET DSVLRPRM = 'alexandre.henrique@ailos.coop.br;andrielly.souza@ailos.coop.br;eduardo.kistner@ailos.coop.br' WHERE CDACESSO = 'SAQUE_PAGUE_E-MAIL';
   COMMIT;
END;