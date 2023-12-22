BEGIN
  UPDATE PAGAMENTO.tbpagto_analise_antifraude_boleto
     SET dssessao_usuario = ' '
   WHERE idanalise_fraude = 346122523;

  UPDATE PAGAMENTO.tbpagto_analise_antifraude_boleto
     SET dssincronizacao_transacao      = ' '
   WHERE idanalise_fraude = 346122524;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'antifraude-boleto');
    ROLLBACK;
END;