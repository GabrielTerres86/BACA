BEGIN
  
  INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES (NULL, 'ALTERA_TITULAR', 'TELA_ATENDA_CARTAOCREDITO', 'pc_cartao_titular', 'pr_cdcooper,pr_cdadmcrd,pr_nrdconta', 1228);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no insert = '||SQLERRM);
END;
