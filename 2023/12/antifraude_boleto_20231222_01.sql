BEGIN
  UPDATE PAGAMENTO.tbpagto_analise_antifraude_boleto
     SET dssessao_usuario               = LOWER(SYS_GUID()) || LOWER(SYS_GUID())
        ,dsversao_software_usuario      = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Sa'
        ,dsurl_origem                   = 'https://contaonlinetest.viacredi.coop.br/ib/pagamentos/contas/boletos-diversos'
        ,vllatitude_localizacao         = -26.905657900
        ,vllongitude_localizacao        = -49.075626700
        ,qtmetros_precisao_localizacao  = 22
        ,nrcarimbo_datahora_localizacao = 20231222
        ,dssincronizacao_transacao      = ' '
   WHERE idanalise_fraude = 346122519;

  UPDATE PAGAMENTO.tbpagto_analise_antifraude_boleto
     SET dssessao_usuario = ' '
   WHERE idanalise_fraude = 346122521;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'antifraude-boleto');
    ROLLBACK;
END;