/* Script para remover motivos 70/71 */
BEGIN
  DELETE TBCC_HIST_PARAM_PESSOA_PROD
  WHERE idmotivo IN (70, 71);

  COMMIT;
END;
