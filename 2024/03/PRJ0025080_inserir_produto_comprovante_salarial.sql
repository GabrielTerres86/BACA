BEGIN
  INSERT INTO PAGAMENTO.tavans_produto
    (nmproduto
    ,dsmascara_arquivo
    ,cdproduto)
  VALUES
    ('Comprovante Salarial'
    ,'CMP_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR'
    ,'CMP');
  COMMIT;
EXCEPTION 
 WHEN OTHERS THEN
   ROLLBACK;
END;
