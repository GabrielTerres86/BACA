BEGIN
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'https://homolog.cenprotsc.com.br/ieptb/services/ProtestoNacionalInterfaceV1'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 3
     AND prm.cdacesso IN ('WS_IEPTB_CANCELAMENTO', 'WS_IEPTB_ENDERECO');
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'homoailos_ws129;Homoailos_ws129'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 3
     AND prm.cdacesso IN ('WS_IEPTB_AUTHENTICATION');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'DMND0005923');
    RAISE;
END;