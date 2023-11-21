BEGIN

  INSERT INTO GESTAODERISCO.TARISCO_PROGRAMA_RISCO (IDPROGRAMA_RISCO, NMPROGRAMA, DSOBJETIVO, TPPROGRAMA)
  VALUES (1, 'ETL-MULESOFT-RETORNO', 'Rotina responsavel entre copiar dados de risco da base do Ailos+ para Aimaro', 2);

  INSERT INTO GESTAODERISCO.TARISCO_PROGRAMA_RISCO (IDPROGRAMA_RISCO, NMPROGRAMA, DSOBJETIVO, TPPROGRAMA)
  VALUES (2, 'CRIACAO-RISCO-AIMARO', 'Rotina responsavel em buscar dados na tabela htrisco_central_retorno e gravar na crapris e crapvri', 2);

  INSERT INTO GESTAODERISCO.TARISCO_PROGRAMA_RISCO (IDPROGRAMA_RISCO, NMPROGRAMA, DSOBJETIVO, TPPROGRAMA)
  VALUES (3, 'RELATORIOS-CONTABEIS', 'Rotinas responsaveis em gerar relatorios contabeis apos geração da central de risco', 3);

  COMMIT;
END;
