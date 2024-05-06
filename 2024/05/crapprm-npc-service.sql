BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = 'wspcrh.cecred.coop.br'
   WHERE UPPER(prm.cdacesso) LIKE UPPER('%NPC_SERVICE_DOMAIN%');
   COMMIT;
END;