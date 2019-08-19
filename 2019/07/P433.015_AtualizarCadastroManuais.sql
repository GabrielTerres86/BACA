BEGIN
  DELETE CRAPPRM t WHERE t.nmsistem = 'CRED' AND t.cdacesso = 'MANUAL_UTILIZACAO_API';

  INSERT INTO CRAPTAB(nmsistem, tptabela, cdempres, cdacesso, tpregist, dstextab, cdcooper)
       VALUES ('CRED', 'GENERI', 0, 'MANUAL_UTILIZA_API', 1, 'Implementacao de aplicativos clients com acesso as APIs Ailos.pdf', 0);

  INSERT INTO CRAPTAB(nmsistem, tptabela, cdempres, cdacesso, tpregist, dstextab, cdcooper)
       VALUES ('CRED', 'GENERI', 0, 'MANUAL_UTILIZA_API', 2, 'Manual - API de Cobranca v1.0.pdf', 0);
       
  INSERT INTO CRAPTAB(nmsistem, tptabela, cdempres, cdacesso, tpregist, dstextab, cdcooper)
       VALUES ('CRED', 'GENERI', 0, 'MANUAL_UTILIZA_API', 3, 'Manual de Orientacao ao Consumidor de APIs da Ailos.pdf', 0);
  
  COMMIT;
END;
