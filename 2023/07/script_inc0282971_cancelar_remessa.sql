BEGIN

    UPDATE cecred.tbtransf_arquivo_ted arq 
       SET arq.IDSITUACAO = 1
     WHERE arq.NRSEQ_ARQ_TED = 35913;

    UPDATE cecred.tbtransf_arquivo_ted_linhas lin
       SET lin.dsret_cnab = 'YK'
     WHERE lin.NRSEQ_ARQ_TED = 35913
       AND lin.dsret_cnab = 'NP';

    commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
/