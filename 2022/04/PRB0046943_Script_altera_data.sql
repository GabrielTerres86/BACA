BEGIN
  UPDATE tbdomic_liqtrans_arquivo t
     SET t.dhrecebimento = sysdate-1
   WHERE idarquivo IN (513794, 513795, 513796, 513797, 513798, 513799);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = sysdate-1
   WHERE idarquivo IN (513794, 513795, 513796, 513797, 513798, 513799);

  UPDATE tbdomic_liqtrans_arquivo t
     SET t.dhrecebimento = sysdate-1
   WHERE idarquivo IN (513800, 513801, 513802, 513803, 513804, 513805);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = sysdate-1
   WHERE idarquivo IN (513800, 513801, 513802, 513803, 513804, 513805);

  UPDATE tbdomic_liqtrans_arquivo t
     SET t.dhrecebimento = sysdate-1
   WHERE idarquivo IN (513806, 513807, 513808, 513809, 513810, 513811);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = sysdate-1
   WHERE idarquivo IN (513806, 513807, 513808, 513809, 513810, 513811);

  COMMIT;

END;
