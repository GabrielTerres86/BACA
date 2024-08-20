BEGIN
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'https://www.cenprotsc.com.br/ieptb/services/ProtestoNacionalInterfaceV1'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 3
     AND prm.cdacesso IN ('WS_IEPTB_CANCELAMENTO', 'WS_IEPTB_ENDERECO');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'RITM0416232');
    RAISE;
END;