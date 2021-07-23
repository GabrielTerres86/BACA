BEGIN
  INSERT INTO TBCC_PRODUTO(CDPRODUTO,
                           DSPRODUTO,
                           FLGITEM_SOA,
                           FLGUTILIZA_INTERFACE_PADRAO,
                           FLGENVIA_SMS,
                           FLGCOBRA_TARIFA,
                           IDFAIXA_VALOR,
                           FLGPRODUTO_API)
  VALUES((SELECT MAX(CDPRODUTO) +1 FROM TBCC_PRODUTO),
         'FUNDOS DE INVESTIMENTOS',
         1,
         0,
         0,
         0,
         0,
         0);
  COMMIT;
END;