BEGIN
  delete from cobranca.tbcobran_ocorrencia_liquidacao_crapret where trunc(dhregistro) >= '05/06/2024';
  COMMIT;
END;
