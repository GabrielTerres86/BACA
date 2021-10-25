-- Atualizar 2 RATINGS
-- Menos de 1 Segundo
BEGIN
  UPDATE tbrisco_operacoes o SET o.flintegrar_sas = 1, o.dtvencto_rating = TO_DATE('25/10/2021', 'dd/mm/yyyy') WHERE o.cdcooper = 10 AND o.nrdconta = 82384  AND o.nrctremp = 143685 AND o.tpctrato = 1;
  UPDATE tbrisco_operacoes o SET o.flintegrar_sas = 1, o.dtvencto_rating = TO_DATE('25/10/2021', 'dd/mm/yyyy') WHERE o.cdcooper = 10 AND o.nrdconta = 101083 AND o.nrctremp = 101181 AND o.tpctrato = 1;
  COMMIT;
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20502, 'Erro: ' || SQLERRM);
END;