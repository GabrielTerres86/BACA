BEGIN
  UPDATE investimento.tbinvest_saldo_base_fria
     SET VLPRINCIPAL = 0
 WHERE idcustodia = 7257
   AND nrconta = 1430
   AND idinstituicaoemissao = 14;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'INC0322907');
    ROLLBACK;
    RAISE;
END;
