-- Aplica contorno nos horarios dos lancamentos para o INC0089797
-- Coop:1-Viacredi Conta:7311311
UPDATE craplmt SET hrtransa = 54157 WHERE progress_recid = 38859510;
UPDATE craplmt SET hrtransa = 54437 WHERE progress_recid = 38859742;
UPDATE craplmt SET hrtransa = 54161 WHERE progress_recid = 38859512;
UPDATE craplmt SET hrtransa = 54440 WHERE progress_recid = 38859734;
UPDATE craplmt SET hrtransa = 54166 WHERE progress_recid = 38859514;
UPDATE craplmt SET hrtransa = 54444 WHERE progress_recid = 38859735;

UPDATE craplcm SET hrtransa = 54157 WHERE progress_recid = 1108508157;
UPDATE craplcm SET hrtransa = 54437 WHERE progress_recid = 1108513466;
UPDATE craplcm SET hrtransa = 54161 WHERE progress_recid = 1108508161;
UPDATE craplcm SET hrtransa = 54440 WHERE progress_recid = 1108513460;
UPDATE craplcm SET hrtransa = 54166 WHERE progress_recid = 1108508166;
UPDATE craplcm SET hrtransa = 54444 WHERE progress_recid = 1108513461;

-- Coop:1-Viacredi Conta:6399100
UPDATE craplcm SET hrtransa = 35275 WHERE progress_recid = 1070803830;
UPDATE craplcm SET hrtransa = 35280 WHERE progress_recid = 1070804882;
UPDATE craplcm SET hrtransa = 35285 WHERE progress_recid = 1070803833;
UPDATE craplcm SET hrtransa = 38319 WHERE progress_recid = 1070838597;
UPDATE craplcm SET hrtransa = 35290 WHERE progress_recid = 1070803837;

UPDATE craplmt SET hrtransa = 35275 WHERE progress_recid = 37792525;            
UPDATE craplmt SET hrtransa = 35280 WHERE progress_recid = 37792544;            
UPDATE craplmt SET hrtransa = 35285 WHERE progress_recid = 37792526;            
UPDATE craplmt SET hrtransa = 38319 WHERE progress_recid = 37794873;            
UPDATE craplmt SET hrtransa = 35290 WHERE progress_recid = 37792522;            

COMMIT;


