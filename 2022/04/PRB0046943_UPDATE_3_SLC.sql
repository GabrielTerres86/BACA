BEGIN
  UPDATE TBDOMIC_LIQTRANS_PDV
     SET CDOCORRENCIA = '01'
   WHERE IDCENTRALIZA IN
         (SELECT IDCENTRALIZA
            FROM TBDOMIC_LIQTRANS_CENTRALIZA
           WHERE IDLANCTO IN
                 (SELECT IDLANCTO
                    FROM TBDOMIC_LIQTRANS_LANCTO
                   WHERE IDARQUIVO IN (SELECT IDARQUIVO
                                         FROM TBDOMIC_LIQTRANS_ARQUIVO
                                        WHERE TRUNC(DHRECEBIMENTO) = TRUNC(SYSDATE - 1)
                                          AND NMARQUIVO_ORIGEM LIKE 'ASLC022%')));

  UPDATE TBDOMIC_LIQTRANS_PDV
     SET CDOCORRENCIA = '00'
   WHERE IDCENTRALIZA IN
         (SELECT IDCENTRALIZA
            FROM TBDOMIC_LIQTRANS_CENTRALIZA
           WHERE IDLANCTO IN
                 (SELECT IDLANCTO
                    FROM TBDOMIC_LIQTRANS_LANCTO
                   WHERE IDARQUIVO IN (SELECT IDARQUIVO
                                         FROM TBDOMIC_LIQTRANS_ARQUIVO
                                        WHERE TRUNC(DHRECEBIMENTO) = TRUNC(SYSDATE - 1)
                                          AND NMARQUIVO_ORIGEM LIKE 'ASLC024%'
                                       UNION
                                       SELECT IDARQUIVO
                                         FROM TBDOMIC_LIQTRANS_ARQUIVO
                                        WHERE TRUNC(DHRECEBIMENTO) = TRUNC(SYSDATE - 1)
                                          AND NMARQUIVO_ORIGEM LIKE 'ASLC032%')));
  COMMIT;
END;
