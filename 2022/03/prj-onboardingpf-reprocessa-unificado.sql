BEGIN
  
  update cadastro.tbcadast_pessoa_atualiza a
    set a.insit_atualiza = 1
  where a.insit_atualiza = 3
    and trunc(a.dhatualiza) >= trunc(sysdate-4);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END
