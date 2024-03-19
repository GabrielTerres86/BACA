BEGIN

  UPDATE tbcotas_faixas_irrf i
     SET i.vlfaixa_final = 2259.20
   WHERE i.inpessoa = 1
     AND i.cdfaixa = 1;

  UPDATE tbcotas_faixas_irrf i
     SET i.vlfaixa_inicial = 2259.21
        ,i.vldeducao       = 169.44
   WHERE i.inpessoa = 1
     AND i.cdfaixa = 2;

  UPDATE tbcotas_faixas_irrf i
     SET i.vldeducao = 381.44
   WHERE i.inpessoa = 1
     AND i.cdfaixa = 3;

  UPDATE tbcotas_faixas_irrf i
     SET i.vldeducao = 662.77
   WHERE i.inpessoa = 1
     AND i.cdfaixa = 4;

  UPDATE tbcotas_faixas_irrf i
     SET i.vldeducao = 896
   WHERE i.inpessoa = 1
     AND i.cdfaixa = 5;

  COMMIT;   
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Altera tabela IRPF RITM0375138');

END;
