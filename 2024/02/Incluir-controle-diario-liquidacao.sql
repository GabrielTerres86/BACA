BEGIN
  INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao(DTREFERENCIA,TPMARCO,DSOBSERVACAO)
            VALUES (to_Date('08/02/2024','dd/mm/yyyy'),1,'Implantacao MLC');
      
  COMMIT;
END;
