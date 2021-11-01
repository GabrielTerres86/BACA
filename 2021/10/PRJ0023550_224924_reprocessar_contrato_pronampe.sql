--Baca para adicionar nova acao para tela Pronam 
BEGIN

  BEGIN
    INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    VALUES ('REPROCESS_CONTRATOPRONAMP', 'TELA_PRONAM', 'pc_atualizar_reprocess_web', 'pr_contratos', (SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_PRONAM' AND ROWNUM = 1));
  EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir acao para o reprocessamento de contrato: '||SQLERRM);
    END;

  COMMIT;

  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Reprocessamento adicionado com sucesso.');

END;
