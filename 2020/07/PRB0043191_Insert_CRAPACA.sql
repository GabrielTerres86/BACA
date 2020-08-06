BEGIN
  
  INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES (NULL, 'EXCLUI_CARTAO', 'TELA_ATENDA_CARTAOCREDITO', 'pc_excluir_proposta', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd', 1228);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no insert = '||SQLERRM);
END;
