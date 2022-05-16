BEGIN
   INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
               VALUES ('CRED', 0, 'REMESSA_NPC_BULK', 'Quantidade registros para processar no BULK', '500');

  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
               VALUES ('CRED', 0, 'REMESSA_NPC_COMMIT', 'Quantidade registros para commitar no BULK', '100');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;