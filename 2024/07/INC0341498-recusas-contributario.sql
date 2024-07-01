DECLARE

vr_cdcritic PLS_INTEGER;
vr_dscritic VARCHAR(500);

CURSOR cr_propostas IS
  SELECT *
    FROM cecred.tbseg_prestamista t
   WHERE nrproposta IN ('202408236377','202212185775','202406802401','202406641912','202406603032','202405878283','202301314560','202317150264','202408250055','202319308037','202406775956','202408437798',
						'202406665506','202406613061','202406644435','202408276988','202408278536','202406670299','202408260837','202406762296','202401807979','202401708765','202406781992','202407937150',
						'202408375589','202308183001','202400494319','202407907958','202406617980','202406615877','202408380658','202407915781','202404043754','202408275410','202408237925','202406763588',
						'202406763007','202406770282','202300797749','202406666525','202309807171','202408280359','202408279540','202403388401','202406783073','202406612552','202406805633','202408276093',
						'202401924695','202400455492','202408276944','202406071654','202408245312','202406652897','202408375710','202408278641','202407901951','202408261389','202406632238','202406759026',
						'202320414878','202407903716','202406781944','202407943030','202402032780','202408246504','202406775204','202406635719','202407907959','202406811470','202406630116','202406644889',
						'202406776235','202406667076','202407894106','202407893943','202407941491','202408249608','202406604185','202408431294','202408382840','202408235693','202306992917');

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

END LOOP;


UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408236377';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202212185775';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406802401';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406641912';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406603032';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202405878283';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202301314560';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202317150264';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408250055';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202319308037';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406775956';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408437798';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406665506';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406613061';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 1 ,p.cdmotrec = 75  ,p.tpregist = 0 WHERE p.nrproposta = '202406644435';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408276988';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408278536';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406670299';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408260837';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406762296';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202401807979';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202401708765';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406781992';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407937150';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408375589';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202308183001';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400494319';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407907958';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406617980';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406615877';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408380658';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407915781';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202404043754';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408275410';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408237925';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406763588';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406763007';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406770282';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202300797749';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406666525';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202309807171';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408280359';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408279540';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202403388401';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406783073';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406612552';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406805633';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408276093';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 316 ,p.tpregist = 0 WHERE p.nrproposta = '202401924695';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202400455492';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408276944';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406071654';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408245312';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406652897';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408375710';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408278641';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407901951';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408261389';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406632238';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406759026';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202320414878';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407903716';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406781944';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407943030';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202402032780';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408246504';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406775204';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406635719';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407907959';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406811470';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406630116';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406644889';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406776235';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406667076';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407894106';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407893943';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202407941491';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408249608';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202406604185';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408431294';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408382840';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202408235693';
UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 8 ,p.cdmotrec = 193 ,p.tpregist = 0 WHERE p.nrproposta = '202306992917';

COMMIT;

UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 342122 AND s.nrctrseg = 420288 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 384526 AND s.nrctrseg = 420135 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 530867 AND s.nrctrseg = 426787 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 561428 AND s.nrctrseg = 421300 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 568163 AND s.nrctrseg = 422731 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 624802 AND s.nrctrseg = 425387 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 686956 AND s.nrctrseg = 425617 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 784648 AND s.nrctrseg = 426033 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 791997 AND s.nrctrseg = 426105 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 796727 AND s.nrctrseg = 424816 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 987158 AND s.nrctrseg = 427049 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 1032623 AND s.nrctrseg = 423269 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 14640236 AND s.nrctrseg = 426864 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 14692937 AND s.nrctrseg = 419890 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 14694646 AND s.nrctrseg = 425351 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 2 AND s.NRDCONTA = 16272870 AND s.nrctrseg = 419428 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 5 AND s.NRDCONTA = 55255 AND s.nrctrseg = 141021 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 5 AND s.NRDCONTA = 144860 AND s.nrctrseg = 149292 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 5 AND s.NRDCONTA = 256650 AND s.nrctrseg = 150012 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 6 AND s.NRDCONTA = 59960 AND s.nrctrseg = 127945 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 6 AND s.NRDCONTA = 105880 AND s.nrctrseg = 126675 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 6 AND s.NRDCONTA = 136590 AND s.nrctrseg = 126555 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 15334 AND s.nrctrseg = 208084 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 59021 AND s.nrctrseg = 206249 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 64378 AND s.nrctrseg = 204714 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 101079 AND s.nrctrseg = 207329 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 199990 AND s.nrctrseg = 206804 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 341789 AND s.nrctrseg = 206298 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 15044696 AND s.nrctrseg = 203978 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 18295797 AND s.nrctrseg = 204347 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 7 AND s.NRDCONTA = 18721893 AND s.nrctrseg = 203131 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 8 AND s.NRDCONTA = 2569 AND s.nrctrseg = 28150 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 8 AND s.NRDCONTA = 7820 AND s.nrctrseg = 28237 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 8 AND s.NRDCONTA = 7870 AND s.nrctrseg = 28086 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 8 AND s.NRDCONTA = 42234 AND s.nrctrseg = 28260 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 17167 AND s.nrctrseg = 116819 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 36668 AND s.nrctrseg = 118449 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 36668 AND s.nrctrseg = 118452 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 262757 AND s.nrctrseg = 117022 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 285030 AND s.nrctrseg = 117208 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 337188 AND s.nrctrseg = 121029 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 343870 AND s.nrctrseg = 116070 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 391085 AND s.nrctrseg = 121903 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 398527 AND s.nrctrseg = 122140 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 500534 AND s.nrctrseg = 121851 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 501115 AND s.nrctrseg = 118964 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 501921 AND s.nrctrseg = 122915 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 17165415 AND s.nrctrseg = 121316 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 17831334 AND s.nrctrseg = 119988 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18121004 AND s.nrctrseg = 121961 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18364055 AND s.nrctrseg = 116602 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18726755 AND s.nrctrseg = 118180 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18738036 AND s.nrctrseg = 119454 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18774857 AND s.nrctrseg = 123165 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 9 AND s.NRDCONTA = 18799221 AND s.nrctrseg = 119778 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 10 AND s.NRDCONTA = 19 AND s.nrctrseg = 74644 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 10 AND s.NRDCONTA = 172448 AND s.nrctrseg = 73549 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 10 AND s.NRDCONTA = 247898 AND s.nrctrseg = 74277 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 10 AND s.NRDCONTA = 17704588 AND s.nrctrseg = 75030 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 53120 AND s.nrctrseg = 430882 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 147532 AND s.nrctrseg = 425873 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 266671 AND s.nrctrseg = 412693 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 314455 AND s.nrctrseg = 424764 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 326666 AND s.nrctrseg = 422932 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 349607 AND s.nrctrseg = 425012 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 377724 AND s.nrctrseg = 422594 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 401870 AND s.nrctrseg = 431136 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 560618 AND s.nrctrseg = 425179 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 583685 AND s.nrctrseg = 430004 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 829854 AND s.nrctrseg = 423631 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 905003 AND s.nrctrseg = 429261 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 17590639 AND s.nrctrseg = 430878 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 12 AND s.NRDCONTA = 76473 AND s.nrctrseg = 89848 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 12 AND s.NRDCONTA = 156787 AND s.nrctrseg = 89856 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 12 AND s.NRDCONTA = 16628268 AND s.nrctrseg = 90373 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 324035 AND s.nrctrseg = 610917 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 402850 AND s.nrctrseg = 602429 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 579513 AND s.nrctrseg = 611022 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 704156 AND s.nrctrseg = 604262 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 15150453 AND s.nrctrseg = 595650 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 13 AND s.NRDCONTA = 18807445 AND s.nrctrseg = 609462 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 14 AND s.NRDCONTA = 15658490 AND s.nrctrseg = 125204 AND s.tpseguro = 4;
UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 14 AND s.NRDCONTA = 15944611 AND s.nrctrseg = 127687 AND s.tpseguro = 4;

COMMIT;


END;