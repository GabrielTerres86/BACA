--inc0043184 corrigir os saldos de março das contas investimento (Carlos)
UPDATE crapsli SET vlsddisp = 604.06 WHERE cdcooper = 1 AND nrdconta = 2090988 AND dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 85.98  WHERE cdcooper = 1 AND nrdconta = 2213117 AND dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 734.17 WHERE cdcooper = 1 AND nrdconta = 2525801 AND dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 280.30 WHERE cdcooper = 1 AND nrdconta = 2529483 AND dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 296.73 WHERE cdcooper = 1 AND nrdconta = 2597462 AND dtrefere = '31/03/2020';
UPDATE crapsli SET vlsddisp = 582.60 WHERE cdcooper = 1 AND nrdconta = 2712440 AND dtrefere = '31/03/2020';

COMMIT;
