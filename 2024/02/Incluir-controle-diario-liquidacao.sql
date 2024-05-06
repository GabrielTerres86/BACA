BEGIN
    INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao
                     (dtreferencia
                     ,tpmarco
                     ,dsobservacao)
              VALUES (to_date('29/02/2024','dd/mm/yyyy')
                     ,1
                     ,'Implantacao MLC');
  COMMIT;
  END;
