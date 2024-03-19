BEGIN
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = REPLACE(p.dsvlrprm, '50183516915,', '')
   WHERE p.cdacesso = 'PESSOA_LIGADA_CNSLH_FSCL'
     AND p.cdcooper = 16;

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = REPLACE(p.dsvlrprm, '08400673999,', '')
   WHERE cdacesso = 'PESSOA_LIGADA_CNSLH_ADM'
     AND p.cdcooper = 7;

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = REPLACE(p.dsvlrprm, '02498047948,', '') || '8400673999,'
   WHERE cdacesso = 'PESSOA_LIGADA_DIRETORIA'
     AND p.cdcooper = 7;
  
  COMMIT;   
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Altera pessoas RITM0376569 ');
END;
