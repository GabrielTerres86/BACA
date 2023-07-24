BEGIN

  BEGIN
    DELETE CECRED.craplcm lcm
     WHERE lcm.DTMVTOLT = '24/07/2023'
       AND lcm.cdagenci = 1
       AND lcm.nrdolote = 9666
       AND lcm.cdbccxlt = 100
       AND lcm.cdpesqbb IN
           (SELECT nrliquidacao
              FROM CECRED.tbdomic_liqtrans_pdv
             WHERE idcentraliza IN
                   (SELECT idcentraliza
                      FROM CECRED.tbdomic_liqtrans_centraliza
                     WHERE idlancto IN (SELECT idlancto
                                          FROM CECRED.tbdomic_liqtrans_lancto
                                         WHERE idarquivo IN (767842,767843,767844,767870,767880,767881,767885,767886,767915,767921,767927,767928))));
  END;

  COMMIT;

END;
