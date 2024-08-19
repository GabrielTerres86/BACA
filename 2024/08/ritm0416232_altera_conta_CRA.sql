BEGIN
  UPDATE crapprm
     SET crapprm.dsvlrprm = '136;4372;647535;IEPTB-SC;12.079.319/0001-33;CC;2'
   WHERE crapprm.nmsistem = 'CRED'
     AND crapprm.cdcooper = 3
     AND crapprm.cdacesso = 'CONTA_IEPTB_CUSTAS';

  UPDATE crapprm
     SET crapprm.dsvlrprm = '136;4372;647535;IEPTB-SC;12.079.319/0001-33;CC;2'
   WHERE crapprm.nmsistem = 'CRED'
     AND crapprm.cdcooper = 3
     AND crapprm.cdacesso = 'CONTA_IEPTB_TARIFAS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'RITM0416232');
    ROLLBACK;
END;
