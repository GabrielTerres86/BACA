BEGIN
  UPDATE tbdomic_liqtrans_lancto
     SET insituacao = 1
   WHERE idarquivo IN (513753, 513754, 513755, 513756, 513757, 513758, 513759);

  COMMIT;
END;
