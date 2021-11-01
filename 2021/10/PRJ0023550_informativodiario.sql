BEGIN

  BEGIN
    INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES ('CONSULTA_INFDIARIO', 'TELA_PRONAM', 'pc_consultar_infdiario_web', 'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_dataini,pr_datafim', (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_PRONAM' AND ROWNUM = 1));
  EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir acao para consulta do informativo diário: '||SQLERRM);
  END;

  COMMIT;

  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Informativo diário adicionado com sucesso.');

END;
