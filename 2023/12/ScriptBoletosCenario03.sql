BEGIN
  DELETE PAGAMENTO.tbpagto_resultado_antifraude af
   WHERE af.idanalise_fraude IN (346119503, 346119504, 346119497, 346119500);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'IDAFS');
END;
