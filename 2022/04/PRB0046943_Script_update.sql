BEGIN
  UPDATE tbdomic_liqtrans_arquivo t
     SET t.nmarquivo_origem         = REPLACE(t.nmarquivo_origem, '20220401', '20220331')
        ,t.nrcontrole_emissor       = REPLACE(t.nrcontrole_emissor, '20220401', '20220331')
        ,t.nrcontrole_dest_original = REPLACE(t.nrcontrole_dest_original, '20220401', '20220331')
        ,t.dharquivo_origem         = REPLACE(t.dharquivo_origem, '2022-04-01', '2022-03-31')
        ,t.dtreferencia             = REPLACE(t.dtreferencia, '2022-04-01', '2022-03-31')
        ,t.dhrecebimento            = REPLACE(t.dhrecebimento, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513794, 513795, 513796, 513797, 513798, 513799);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = REPLACE(t.dhinclusao, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513794, 513795, 513796, 513797, 513798, 513799);

  UPDATE tbdomic_liqtrans_pdv t
     SET t.dtpagamento  = REPLACE(t.dtpagamento, '2022-04-04', '2022-04-01')
        ,t.dhmanutencao = REPLACE(t.dhmanutencao, '01/04/2022', '31/03/2022')
   WHERE idcentraliza IN
         (SELECT idcentraliza
            FROM tbdomic_liqtrans_centraliza
           WHERE idlancto IN
                 (SELECT idlancto
                    FROM tbdomic_liqtrans_lancto
                   WHERE idarquivo IN (513794, 513795, 513796, 513797, 513798, 513799)));

  UPDATE tbdomic_liqtrans_arquivo t
     SET t.nmarquivo_origem         = REPLACE(t.nmarquivo_origem, '20220401', '20220331')
        ,t.nrcontrole_emissor       = REPLACE(t.nrcontrole_emissor, '20220401', '20220331')
        ,t.nrcontrole_dest_original = REPLACE(t.nrcontrole_dest_original, '20220401', '20220331')
        ,t.dharquivo_origem         = REPLACE(t.dharquivo_origem, '2022-04-01', '2022-03-31')
        ,t.dtreferencia             = REPLACE(t.dtreferencia, '2022-04-01', '2022-03-31')
        ,t.dhrecebimento            = REPLACE(t.dhrecebimento, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513800, 513801, 513802, 513803, 513804, 513805);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = REPLACE(t.dhinclusao, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513800, 513801, 513802, 513803, 513804, 513805);

  UPDATE tbdomic_liqtrans_pdv t
     SET t.dtpagamento  = REPLACE(t.dtpagamento, '2022-04-01', '2022-03-31')
        ,t.dhmanutencao = REPLACE(t.dhmanutencao, '01/04/2022', '31/03/2022')
   WHERE idcentraliza IN
         (SELECT idcentraliza
            FROM tbdomic_liqtrans_centraliza
           WHERE idlancto IN
                 (SELECT idlancto
                    FROM tbdomic_liqtrans_lancto
                   WHERE idarquivo IN (513800, 513801, 513802, 513803, 513804, 513805)));

  UPDATE tbdomic_liqtrans_arquivo t
     SET t.nmarquivo_origem         = REPLACE(t.nmarquivo_origem, '20220401', '20220331')
        ,t.nrcontrole_emissor       = REPLACE(t.nrcontrole_emissor, '20220401', '20220331')
        ,t.nrcontrole_dest_original = REPLACE(t.nrcontrole_dest_original, '20220401', '20220331')
        ,t.dharquivo_origem         = REPLACE(t.dharquivo_origem, '2022-04-01', '2022-03-31')
        ,t.dtreferencia             = REPLACE(t.dtreferencia, '2022-04-01', '2022-03-31')
        ,t.dhrecebimento            = REPLACE(t.dhrecebimento, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513806, 513807, 513808, 513809, 513810, 513811);

  UPDATE tbdomic_liqtrans_lancto t
     SET t.dhinclusao = REPLACE(t.dhinclusao, '01/04/2022', '31/03/2022')
   WHERE idarquivo IN (513806, 513807, 513808, 513809, 513810, 513811);

  UPDATE tbdomic_liqtrans_pdv t
     SET t.dtpagamento  = REPLACE(t.dtpagamento, '2022-04-01', '2022-03-31')
        ,t.dhmanutencao = REPLACE(t.dhmanutencao, '01/04/2022', '31/03/2022')
   WHERE idcentraliza IN
         (SELECT idcentraliza
            FROM tbdomic_liqtrans_centraliza
           WHERE idlancto IN
                 (SELECT idlancto
                    FROM tbdomic_liqtrans_lancto
                   WHERE idarquivo IN (513806, 513807, 513808, 513809, 513810, 513811)));

  COMMIT;

END;
