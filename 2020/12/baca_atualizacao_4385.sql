BEGIN
   -- Insere os novos registros 
     -- credcrea veiculo novo
      insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
        values (7, 3, 31, 'Novo', 215, 1, 0, 30.00, 5.00, 0.00, 77);

     -- credcrea veiculo usado
      insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
        values (7, 3, 32, 'Usado', 216, 1, 1, 90.00, 10.00, 0.00, 77);

     -- Acredicoop Imovel
      insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
        values (2, 4, 41, 'Imovel', 959, 1, 0, 90.00, 10.00, 0.00, 77);

   -- Atualiza os registros necessarios
     -- Evolua
       -- Veiculo Novo
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 1108 WHERE t.cdcooper = 14 AND t.idsegmento = 3 AND t.idsubsegmento = 31;
       -- Veiculo Usado
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 1109 WHERE t.cdcooper = 14 AND t.idsegmento = 3 AND t.idsubsegmento = 32;
       -- Imovel
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 1107 WHERE t.cdcooper = 14 AND t.idsegmento = 4 AND t.idsubsegmento = 41;

     -- Acentra
       -- Veiculo Novo
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 719 WHERE t.cdcooper = 5 AND t.idsegmento = 3 AND t.idsubsegmento = 31;
       -- Veiculo Usado
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 721 WHERE t.cdcooper = 5 AND t.idsegmento = 3 AND t.idsubsegmento = 32;
       -- Imovel
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 325 WHERE t.cdcooper = 5 AND t.idsegmento = 4 AND t.idsubsegmento = 41;

     -- Unilos
       -- Veiculo Novo
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 133 WHERE t.cdcooper = 6 AND t.idsegmento = 3 AND t.idsubsegmento = 31;
       -- Veiculo Usado
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 134 WHERE t.cdcooper = 6 AND t.idsegmento = 3 AND t.idsubsegmento = 32;
       -- Imovel
       UPDATE tbepr_subsegmento t SET t.cdlinha_credito = 132 WHERE t.cdcooper = 6 AND t.idsegmento = 4 AND t.idsubsegmento = 41;

  -- Deleta os registros que não serão mais necessários na Civia
    DELETE FROM tbepr_subsegmento t WHERE t.cdcooper = 13 AND t.idsegmento = 3 AND t.idsubsegmento IN (31, 32);
    DELETE FROM tbepr_subsegmento t WHERE t.cdcooper = 13 AND t.idsegmento = 4 AND t.idsubsegmento = 41;
    
  COMMIT;   
END;
