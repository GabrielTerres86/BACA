BEGIN

  UPDATE pagamento.tb_baixa_pcr_remessa tb
     SET tb.idbaixa_operacional = 4
   WHERE tb.idbaixa_pcr_remessa = 42863249;
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'altera baixa 42863152');
END;
