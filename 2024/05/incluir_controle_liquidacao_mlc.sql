BEGIN
  INSERT INTO tbcobran_controle_diario_liquidacao(dtreferencia,
                                                  tpmarco,
                                                  dsobservacao)
                                          VALUES (to_date('04/07/2024','dd/mm/yyyy')
                                                 ,1
                                                 ,'TESTES MLC');
                                                 
  COMMIT;
END;