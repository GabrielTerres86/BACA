BEGIN

    UPDATE cecred.tbtransf_arquivo_ted_linhas tatl
       SET tatl.dsret_cnab = 'NP'
     WHERE tatl.cdsegmento = 'A'
       AND tatl.nrseq_arq_ted = 37116
       AND tatl.nrseq_arq_ted_linha IN (369884, 369885);

    UPDATE cecred.tbtransf_arquivo_ted tat
       SET tat.idsituacao = 3
     WHERE tat.cdcooper = 8
       AND tat.nrdconta = 99971488
       AND tat.nrseq_arquivo = 4
       AND tat.nrseq_arq_ted = 37116;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;