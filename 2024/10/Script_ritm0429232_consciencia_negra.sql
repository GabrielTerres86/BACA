DECLARE

BEGIN
  UPDATE cecred.craplau lau
     SET lau.dtmvtopg = TO_DATE('21112024', 'DDMMYYYY)')
        ,lau.dtdebito = TO_DATE('21112024', 'DDMMYYYY)')
   WHERE lau.progress_Recid IN (77606032
                      ,76767960
                      ,87394092
                      ,77801208
                      ,76945460
                      ,87271311
                      ,88676395
                      ,80539984
                      ,76827609
                      ,88834848);
  
  COMMIT;                      
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'RITM0429232');
END;
