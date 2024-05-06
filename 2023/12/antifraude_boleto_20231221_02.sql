BEGIN
  UPDATE PAGAMENTO.tbpagto_analise_antifraude_boleto
     SET dssessao_usuario               = ' '
        ,dsversao_software_usuario      = ' '
        ,dsurl_origem                   = ' '
        ,vllatitude_localizacao         = 0.000000000
        ,vllongitude_localizacao        = 0.000000000
        ,qtmetros_precisao_localizacao  = 0
        ,nrcarimbo_datahora_localizacao = 0
        ,dssincronizacao_transacao      = ' '
   WHERE idanalise_fraude IN (346122500, 346122496, 346122499, 346122494, 346122495, 346122497, 346122498, 346122490, 346122491, 346122492);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'antifraude-boleto');
    ROLLBACK;
END;