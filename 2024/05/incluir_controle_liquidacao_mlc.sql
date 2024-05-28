BEGIN
  INSERT INTO tbcobran_controle_diario_liquidacao(dtreferencia,
                                                  tpmarco,
                                                  dsobservacao)
                                          VALUES ('22/05/2024'
                                                 ,1
                                                 ,'TESTES MLC');
                                                 
  COMMIT;
END;
