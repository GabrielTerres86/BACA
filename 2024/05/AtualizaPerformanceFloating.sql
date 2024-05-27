DECLARE
  already_exists  EXCEPTION;
  columns_indexed EXCEPTION;
  PRAGMA EXCEPTION_INIT(already_exists, -955);
  PRAGMA EXCEPTION_INIT(columns_indexed, -1408);
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE (idarquivo_acmp615_lote) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_FK01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE (nrispb_favorecido, cdmotivo_devolucao) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX02:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE (nrispb_recebedor, cdmotivo_devolucao) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX03:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE (cdidentificador_titulo) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX04:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE (cdidentificador_baixa) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_DETALHE_IDX05:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01 ON COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE (idarquivo_acmp615_header) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_ARQUIVO_ACMP615_LOTE_FK01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01 ON COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL (idciclo_liquidacao_pcr) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_FK01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01 ON COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL (nrparcial) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_PARCIAL_IDX01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01 ON COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR (dhinicio_vigencia, dhfim_vigencia, nrordem) PARALLEL 20 TABLESPACE TBS_COBRANCA_I';
    dbms_output.put_line('create COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01 NOPARALLEL';
    dbms_output.put_line('alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel COBRANCA.TBCOBRAN_CICLO_LIQUIDACAO_PCR_IDX01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5 ON PAGAMENTO.TB_BAIXA_PCR_RETORNO (nrindenticacao_bo) PARALLEL 20 TABLESPACE TBS_PAGAMENTO_I';
    dbms_output.put_line('create PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5 NOPARALLEL';
    dbms_output.put_line('alter parallel PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel PAGAMENTO.TB_BAIXA_PCR_RETORNO_IDX5:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX pagamento.tb_baixa_pcr_remessa_idx10 ON pagamento.tb_baixa_pcr_remessa (nrtitulo_npc) PARALLEL 20 TABLESPACE tbs_pagamento_i';
    dbms_output.put_line('create PAGAMENTO.tb_baixa_pcr_remessa_idx10');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate PAGAMENTO.tb_baixa_pcr_remessa_idx10:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX pagamento.tb_baixa_pcr_remessa_idx10 NOPARALLEL';
    dbms_output.put_line('alter parallel PAGAMENTO.tb_baixa_pcr_remessa_idx10');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel PAGAMENTO.tb_baixa_pcr_remessa_idx10:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX pagamento.tb_baixa_pcr_remessa_idx11 ON pagamento.tb_baixa_pcr_remessa (nrindenticacao_bo) PARALLEL 20 TABLESPACE tbs_pagamento_i';
    dbms_output.put_line('create PAGAMENTO.tb_baixa_pcr_remessa_idx11');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate PAGAMENTO.tb_baixa_pcr_remessa_idx11:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX pagamento.tb_baixa_pcr_remessa_idx11 NOPARALLEL';
    dbms_output.put_line('alter parallel PAGAMENTO.tb_baixa_pcr_remessa_idx11');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel PAGAMENTO.tb_baixa_pcr_remessa_idx11:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx01 ON cobranca.tbcobran_ocorrencia_liquidacao (cdcooperativa ASC, nrconta_corrente ASC, nrboleto ASC ) PARALLEL 20 TABLESPACE tbs_cobranca_i';
    dbms_output.put_line('create cobranca.tbcobran_ocorrencia_liquidacao_idx01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate cobranca.tbcobran_ocorrencia_liquidacao_idx01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx01 NOPARALLEL';
    dbms_output.put_line('alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx01:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx02 ON cobranca.tbcobran_ocorrencia_liquidacao (dtmovimento_sistema ASC ) PARALLEL 20 TABLESPACE tbs_cobranca_i';
    dbms_output.put_line('create cobranca.tbcobran_ocorrencia_liquidacao_idx02');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate cobranca.tbcobran_ocorrencia_liquidacao_idx02:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx02 NOPARALLEL';
    dbms_output.put_line('alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx02');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx02:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx03 ON cobranca.tbcobran_ocorrencia_liquidacao ( dhregistro ASC ) PARALLEL 20 TABLESPACE tbs_cobranca_i';
    dbms_output.put_line('create cobranca.tbcobran_ocorrencia_liquidacao_idx03');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate cobranca.tbcobran_ocorrencia_liquidacao_idx03:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx03 NOPARALLEL';
    dbms_output.put_line('alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx03');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx03:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx04 ON cobranca.tbcobran_ocorrencia_liquidacao ( cdidentificador_titulo_pcr ASC ) PARALLEL 20 TABLESPACE tbs_cobranca_i';
    dbms_output.put_line('create cobranca.tbcobran_ocorrencia_liquidacao_idx04');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate cobranca.tbcobran_ocorrencia_liquidacao_idx04:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX cobranca.tbcobran_ocorrencia_liquidacao_idx04 NOPARALLEL';
    dbms_output.put_line('alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx04');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel cobranca.tbcobran_ocorrencia_liquidacao_idx04:'||sqlerrm);
  END;

  BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01 ON cobranca.tbcobran_arquivo_acmp615_header ( idciclo_liquidacao_pcr ASC ) PARALLEL 20 TABLESPACE tbs_cobranca_i';
    dbms_output.put_line('create cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped crate cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01:'||sqlerrm);
  END;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER INDEX cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01 NOPARALLEL';
    dbms_output.put_line('alter parallel cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01');
  EXCEPTION
    WHEN already_exists OR columns_indexed THEN
      dbms_output.put_line('skipped alter parallel cobranca.TBCOBRAN_ARQUIVO_ACMP615_HEADER_FK01:'||sqlerrm);
  END;

  COMMIT;

END;
