DECLARE

CURSOR cr_propostas IS
  SELECT *
    FROM cecred.tbseg_prestamista t
   WHERE nrproposta IN ('202315181152','770353227432','770355066975','770355266850','770356627326','770357148235','770357680530','770358101496','770358560849','770573633547','770573831284','770656272295','770656429003','770656617519');

BEGIN

FOR rw_propostas IN cr_propostas LOOP

	UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 207 ,p.tpregist = 0 WHERE p.nrproposta = rw_propostas.nrproposta;

	UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = rw_propostas.cdcooper AND s.nrdconta = rw_propostas.nrdconta AND s.nrctrseg = rw_propostas.nrctrseg AND s.tpseguro = 4;

END LOOP;

COMMIT;

END;