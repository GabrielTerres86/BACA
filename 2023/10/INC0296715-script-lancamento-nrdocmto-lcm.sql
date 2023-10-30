DECLARE

  TYPE typ_reg_lcm IS RECORD(
       cdcooper cecred.craplcm.cdcooper%TYPE,
       nrdconta cecred.craplcm.nrdconta%TYPE,
       cdhistor cecred.craplcm.cdhistor%TYPE,
       novo_nrdocmto cecred.craplcm.nrdocmto%TYPE,
       progress_recid cecred.craplcm.progress_recid%TYPE);
  TYPE typ_tab_lcm IS TABLE OF typ_reg_lcm INDEX BY PLS_INTEGER;
  
  vr_tab_lcm typ_tab_lcm;
  vr_qtregistro number(10) := 0;
             
BEGIN
  vr_tab_lcm.delete;

             SELECT cdcooper,
                    nrdconta,
                    cdhistor,
                    novo_nrdocmto,
                    progress_recid
  BULK COLLECT INTO vr_tab_lcm 
               FROM(SELECT a.cdcooper,
                           a.nrdconta,
                           a.cdhistor,      
                           SUBSTR(a.cdpesqbb, TRIM(LENGTH('Desconto do Borderô')+1)) AS novo_nrdocmto,
                           a.progress_recid 
                      FROM cecred.craplcm a 
                     WHERE a.cdhistor = 2664 
                       AND a.nrdocmto IS NULL);

   IF NVL(vr_tab_lcm.count,0) > 0 THEN 
      FOR i IN vr_tab_lcm.first .. vr_tab_lcm.last
      LOOP
        vr_qtregistro := vr_qtregistro + 1;
        
        UPDATE cecred.craplcm a
           SET a.nrdocmto = vr_tab_lcm(i).novo_nrdocmto
         WHERE a.progress_recid = vr_tab_lcm(i).progress_recid;

        IF MOD(vr_qtregistro,100) = 0 THEN
          COMMIT;
        END IF; 
      END LOOP;  
   END IF;
  
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar cecred.craplcm.nrdocmto',true);
END;
