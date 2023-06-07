BEGIN
  BEGIN
    UPDATE TBDOMIC_LIQTRANS_ARQUIVO TLA
       SET TLA.NMARQUIVO_GERADO  = NULL
          ,TLA.DHARQUIVO_GERADO  = NULL
          ,TLA.NMARQUIVO_RETORNO = NULL
          ,TLA.DHARQUIVO_RETORNO = NULL
     WHERE TLA.IDARQUIVO IN (745846);
  END;

  BEGIN
    UPDATE TBDOMIC_LIQTRANS_LANCTO TLL
       SET TLL.INSITUACAO      = 0
          ,TLL.DHPROCESSAMENTO = NULL
     WHERE TLL.IDARQUIVO IN (745846);
  END;

  BEGIN
    UPDATE TBDOMIC_LIQTRANS_PDV TLP
       SET TLP.CDOCORRENCIA         = NULL
          ,TLP.DHRETORNO            = NULL
          ,TLP.CDOCORRENCIA_RETORNO = NULL
          ,TLP.DSERRO               = NULL
          ,TLP.DSOCORRENCIA_RETORNO = NULL
     WHERE IDCENTRALIZA IN (SELECT idcentraliza
                              FROM tbdomic_liqtrans_centraliza
                             WHERE idlancto IN (SELECT idlancto
                                                  FROM tbdomic_liqtrans_lancto
                                                 WHERE idarquivo IN (745846)));
  END;

  COMMIT;

END;
