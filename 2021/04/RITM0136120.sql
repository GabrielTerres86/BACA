-- RITM0136120
BEGIN

  DELETE FROM cecred.tbcecred_envio_assinatura WHERE CDDOC IN (1,2,4,41);
  DELETE FROM ged.tbged_assina_signatario WHERE CDDOC IN (1,2,3,4,21,41);
  DELETE FROM ged.tbged_assina_documento WHERE CDDOC IN (1,2,3,4,21,41);
  COMMIT;

END;