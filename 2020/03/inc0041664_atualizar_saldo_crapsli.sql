--inc0041664 corrigir os saldos de fevereiro e março das contas investimento (Carlos)

--zerar janeiro, pois os saldos irão para fevereiro
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9123078; --1 | 2090988 | 31/01/2020
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9127836; --1 | 2213117 | 31/01/2020
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9141142; --1 | 2525801 | 31/01/2020
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9141297; --1 | 2529483 | 31/01/2020
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9144397; --1 | 2597462 | 31/01/2020
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9149164; --1 | 2712440 | 31/01/2020
--saldos de janeiro irão para fevereiro
UPDATE crapsli SET vlsddisp = 604.06 WHERE progress_recid = 9420025; --1 | 2090988 | 29/02/2020
UPDATE crapsli SET vlsddisp = 85.98  WHERE progress_recid = 9424790; --1 | 2213117 | 29/02/2020
UPDATE crapsli SET vlsddisp = 734.17 WHERE progress_recid = 9438113; --1 | 2525801 | 29/02/2020
UPDATE crapsli SET vlsddisp = 280.30 WHERE progress_recid = 9438269; --1 | 2529483 | 29/02/2020
UPDATE crapsli SET vlsddisp = 296.73 WHERE progress_recid = 9441391; --1 | 2597462 | 29/02/2020
UPDATE crapsli SET vlsddisp = 582.60 WHERE progress_recid = 9446159; --1 | 2712440 | 29/02/2020

--zerar fevereiro, pois os saldos irão para março
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990138;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9407880;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9426703;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9435780;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990133;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990134;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9435785;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9435787;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9436032;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437658;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437659;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437662;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437664;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990135;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437715;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990136;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9990137;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437731;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9437746;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9438848;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9441367;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9442068;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9556272;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9341155;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9341737;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9341738;
UPDATE crapsli SET vlsddisp = 0 WHERE progress_recid = 9341739;
--saldos para março
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (934925, to_date('31/03/2020','dd/mm/rrrr'), 101.02, 1);
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (2469847, to_date('31/03/2020','dd/mm/rrrr'), 40.49, 1);
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (2469898, to_date('31/03/2020','dd/mm/rrrr'), 150.58, 1);
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (2517035, to_date('31/03/2020','dd/mm/rrrr'), 61.17, 1);
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (2517922, to_date('31/03/2020','dd/mm/rrrr'), 5.00, 1);
INSERT INTO crapsli (nrdconta, dtrefere, vlsddisp, cdcooper) VALUES (2517973, to_date('31/03/2020','dd/mm/rrrr'), 61.18, 1);
UPDATE crapsli SET vlsddisp = 4489.13 WHERE cdcooper = 1 AND nrdconta = 1522817 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 5906.47 WHERE cdcooper = 1 AND nrdconta = 2257459 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 671.50  WHERE cdcooper = 1 AND nrdconta = 2469782 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 11.51   WHERE cdcooper = 1 AND nrdconta = 2469910 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 144.47  WHERE cdcooper = 1 AND nrdconta = 2469952 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 988.57  WHERE cdcooper = 1 AND nrdconta = 2475430 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 43.09   WHERE cdcooper = 1 AND nrdconta = 2516845 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 32.14   WHERE cdcooper = 1 AND nrdconta = 2516861 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 265.90  WHERE cdcooper = 1 AND nrdconta = 2516900 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 78.32   WHERE cdcooper = 1 AND nrdconta = 2516934 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 59.48   WHERE cdcooper = 1 AND nrdconta = 2517914 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 326.16  WHERE cdcooper = 1 AND nrdconta = 2518279 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 42.15   WHERE cdcooper = 1 AND nrdconta = 2518538 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 620.72  WHERE cdcooper = 1 AND nrdconta = 2543893 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 120.55  WHERE cdcooper = 1 AND nrdconta = 2596687 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 630.81  WHERE cdcooper = 1 AND nrdconta = 2616726 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 4034.45 WHERE cdcooper = 1 AND nrdconta = 9112588 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 6762.90 WHERE cdcooper = 8 AND nrdconta = 6190  AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 4882.46 WHERE cdcooper = 8 AND nrdconta = 27308 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 2403.19 WHERE cdcooper = 8 AND nrdconta = 27324 AND crapsli.dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 2560.36 WHERE cdcooper = 8 AND nrdconta = 27332 AND crapsli.dtrefere = '31/03/2020';

COMMIT;
