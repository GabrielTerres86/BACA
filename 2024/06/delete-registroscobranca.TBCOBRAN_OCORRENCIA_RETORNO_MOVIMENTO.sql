BEGIN
  delete from cobranca.TBCOBRAN_OCORRENCIA_RETORNO_MOVIMENTO where trunc(dhregistro) >= '05/06/2024';
  COMMIT;
END;
