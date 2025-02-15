BEGIN
  UPDATE CONTACORRENTE.TBPIX_ALTERACAO_COOPERADO A SET
    A.FLJOB_EXECUTADO = 0,
    A.DHEXECUCAO_JOB = NULL
  WHERE A.DTREGISTRO >= TO_DATE('17/03/2022 15:00', 'DD/MM/YYYY HH24:MI');

  UPDATE CECRED.TBCC_LANCAMENTOS_PENDENTES L SET 
    L.IDSITUACAO = 'M'
  WHERE L.IDSEQ_LANCAMENTO IN (79517177,79263963,74335372);
  
  COMMIT;
END;