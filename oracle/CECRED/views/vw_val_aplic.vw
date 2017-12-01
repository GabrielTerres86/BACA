CREATE OR REPLACE FORCE VIEW CECRED.VW_VAL_APLIC AS
SELECT
  adi.cdcooper AS cdcooper,
  adi.nrdconta AS nrdconta,
  adt.nrctagar AS nrctagar,
  adi.nrctremp AS nrctremp,
  adt.cdaditiv AS cdaditiv,
  adi.nraplica AS nraplica,
  adi.tpproapl AS tpproapl,
  adi.nraditiv AS nraditiv,
  fn_retorna_valores_aplicacao(adi.cdcooper,adi.nrdconta,adt.nrctagar,adt.cdaditiv,adi.nraplica,adi.tpproapl) AS dscaplic
FROM
  crapepr epr,
  crapadt adt,
  crapadi adi
WHERE epr.cdcooper(+) = adt.cdcooper
      AND epr.nrdconta(+) = adt.nrdconta
      AND epr.nrctremp(+) = adt.nrctremp
      AND adt.cdcooper = adi.cdcooper
      AND adt.nrdconta = adi.nrdconta
      AND adt.nraditiv = adi.nraditiv
      AND adt.nrctremp = adi.nrctremp
      AND adt.tpctrato = adi.tpctrato
      AND adt.cdaditiv in (2,3) -- Aditivo de Apli??o
      AND epr.inliquid = 0
      AND epr.inprejuz = 0
      AND adt.tpctrato = 90 -- Emprestimo/Financiamento
      ORDER BY adi.cdcooper, adi.nrdconta, adi.nraplica
