BEGIN
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'https://www.cenprotsc.com.br/ieptb/services/ProtestoInterface'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 3
     AND prm.cdacesso IN ('WS_IEPTB_CANCELAMENTO', 'WS_IEPTB_ENDERECO');
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'processarquivos_ws;ws_dhqb0023'
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