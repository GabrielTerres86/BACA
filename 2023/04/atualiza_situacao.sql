BEGIN
  update SEGURO.TBSEG_RESUMO_CONTRATACAO_VIDA a set a.tpsituacao = 1 where a.flcontratado = 1;
  commit;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao atualizar TBSEG_RESUMO_CONTRATACAO_VIDA: '|| SQLERRM);
END;
