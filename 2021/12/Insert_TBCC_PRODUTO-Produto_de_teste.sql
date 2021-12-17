BEGIN
  DECLARE
    n_cdProdMax TBCC_PRODUTO.CDPRODUTO%TYPE;
  BEGIN
  
    SELECT MAX(P.CDPRODUTO)
      INTO n_cdProdMax
      FROM TBCC_PRODUTO P;
  
    INSERT INTO TBCC_PRODUTO
      (CDPRODUTO
      ,DSPRODUTO
      ,FLGITEM_SOA
      ,IDFAIXA_VALOR)
      SELECT n_cdProdMax + 1
            ,'PRODUTO DE TESTE'
            ,1
            ,1
        FROM DUAL
       WHERE NOT EXISTS (SELECT 1
                FROM TBCC_PRODUTO
               WHERE CDPRODUTO = n_cdProdMax + 1);
    COMMIT;
  END;
END;
