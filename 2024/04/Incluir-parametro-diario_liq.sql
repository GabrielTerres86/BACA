BEGIN
  INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao(DTREFERENCIA
                                                          ,TPMARCO
                                                          ,DSOBSERVACAO)
                                                   VALUES (to_date('17/04/2024','dd/mm/yyyy')
                                                          ,1
                                                          ,'TESTES MLC');
  COMMIT;

END;