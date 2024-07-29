DECLARE

CURSOR cr_propostas IS
  SELECT *
    FROM cecred.tbseg_prestamista t
   WHERE nrproposta IN ('202406274411','202406280121','202406280319','202406280321','202406280340','202406281621','202406284556','202406321167','202406324449','202406325146','202406331251','202406333502','202406335528','202406337241','202406338876','202406349320','202406354182','202406358268','202400050425','202400054350','202400061339','202400086912','202400091466','202400094580','202400094581','202400094582','202400102059','202400138964','202400151343','202400156964','202400165934','202406227360','202406233791','202406252613','202406255194','202406265447','202406267545','202406267576','202406270067','202406274379');

BEGIN

UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406274411';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406280121';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 207 ,p.tpregist = 0 WHERE p.nrproposta = '202406280319';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 207 ,p.tpregist = 0 WHERE p.nrproposta = '202406280321';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 207 ,p.tpregist = 0 WHERE p.nrproposta = '202406280340';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406281621';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406284556';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406321167';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406324449';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406325146';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406331251';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406333502';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406335528';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406337241';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406338876';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406349320';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406354182';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406358268';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 316 ,p.tpregist = 0 WHERE p.nrproposta = '202400050425';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400054350';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400061339';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400086912';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400091466';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400094580';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400094581';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400094582';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400102059';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400138964';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400151343';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 207 ,p.tpregist = 0 WHERE p.nrproposta = '202400156964';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400165934';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406227360';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406233791';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406252613';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406255194';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406265447';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406267545';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406267576';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406270067';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406274379';

COMMIT;

FOR rw_propostas IN cr_propostas LOOP
	UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = rw_propostas.cdcooper AND s.nrdconta = rw_propostas.nrdconta AND s.nrctrseg = rw_propostas.nrctrseg AND s.tpseguro = 4;
	
END LOOP;

COMMIT;
END;