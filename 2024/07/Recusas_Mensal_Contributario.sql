DECLARE

vr_cdcritic PLS_INTEGER;
vr_dscritic VARCHAR(500);

CURSOR cr_propostas IS
  SELECT *
    FROM cecred.tbseg_prestamista t
   WHERE nrproposta IN ('202408692692','202408707257','202408580895','202314944167','202408583217','202403506139','202312952044','202408857589','202408874620','202308765289','202408538935','202408606486','202319741058','202408617533','202406497553','202406457660','202403874848','202407941461','202409015899','202408685291','202408853661','202408539271','202408246786','202408685364','202408434029','202408682970','202406803951','202408846874','202408748417','202408751119','202408461050','202408563434','202213671638','202408280362','202408558805','202406783120','202406652238','202408368870','202409023656','202305432498','202319744089','202401204033','202401505675','202408709355','202408438854','202408530546','202409016854','202408282028','202407894586','202408999656','202408618843','202406801100','202408845751','202408599849','202406225762','202307986359','202317679318','202408857143','202408616169','202408556812','202408729522','202406211970','202315532365','202408748307','202408840457','202408750683','202408697138','202405587857','202407389336','202408605016','202408531168','202306705733','202408602966','202409121918','202409121719','202409025255');

BEGIN

FOR rw_propostas IN cr_propostas LOOP

  cecred.segu0003.pc_efetuar_estorno(pr_cdcooper   => rw_propostas.cdcooper   
                                    ,pr_nrdconta   => rw_propostas.nrdconta   
                                    ,pr_nrctrseg   => rw_propostas.nrctrseg
                                    ,pr_nrctremp   => rw_propostas.nrctremp
                                    ,pr_nrproposta => rw_propostas.nrproposta 
                                    ,pr_dtmvtolt   => TRUNC(SYSDATE)
                                    ,pr_cdhistor   => 4060
                                    ,pr_cdcritic   => vr_cdcritic
                                    ,pr_dscritic   => vr_dscritic);
									
	UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = rw_propostas.cdcooper AND s.nrdconta = rw_propostas.nrdconta AND s.nrctrseg = rw_propostas.nrctrseg AND s.tpseguro = 4;								

END LOOP;

UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408692692';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408707257';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408580895';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202314944167';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 75  ,p.tpregist = 0 WHERE p.nrproposta = '202408583217';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202403506139';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202312952044';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408857589';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408874620';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202308765289';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408538935';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408606486';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202319741058';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408617533';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406497553';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406457660';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202403874848';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407941461';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409015899';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408685291';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 75  ,p.tpregist = 0 WHERE p.nrproposta = '202408853661';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408539271';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408246786';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408685364';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408434029';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408682970';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406803951';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408846874';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408748417';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408751119';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408461050';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408563434';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202213671638';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408280362';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408558805';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406783120';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406652238';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408368870';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409023656';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202305432498';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202319744089';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202401204033';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202401505675';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408709355';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408438854';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408530546';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409016854';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408282028';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407894586';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408999656';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408618843';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406801100';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408845751';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408599849';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406225762';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202307986359';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202317679318';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408857143';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408616169';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408556812';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408729522';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 75  ,p.tpregist = 0 WHERE p.nrproposta = '202406211970';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202315532365';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408748307';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408840457';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 75  ,p.tpregist = 0 WHERE p.nrproposta = '202408750683';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408697138';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202405587857';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407389336';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408605016';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408531168';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202306705733';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408602966';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409121918';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409121719';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202409025255';


COMMIT;
END;