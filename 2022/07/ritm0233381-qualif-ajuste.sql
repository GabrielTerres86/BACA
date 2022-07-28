DECLARE
  TYPE typ_reg_crawepr IS RECORD(cdcooper  cecred.crawepr.cdcooper%TYPE,
                                 nrdconta  cecred.crawepr.nrdconta%TYPE,
                                 nrctremp  cecred.crawepr.nrctremp%TYPE);
  TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY PLS_INTEGER;
  vr_tab_crawepr typ_tab_crawepr;
  TYPE typ_reg_crapepr IS RECORD(cdcooper  cecred.crapepr.cdcooper%TYPE,
                                 nrdconta  cecred.crapepr.nrdconta%TYPE,
                                 nrctremp  cecred.crapepr.nrctremp%TYPE);
  TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
  vr_tab_crapepr typ_tab_crapepr;
  vr_cont            NUMBER(6) := 0;
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;
  
  CURSOR c_crawepr is
    SELECT a.cdcooper,
           a.nrdconta,
           a.nrctremp
      FROM cecred.crawepr a 
     WHERE a.cdlcremp = 1500
       AND a.idquapro not in (4);
       rw_crawepr c_crawepr%ROWTYPE;
     
  CURSOR c_crapepr is
    SELECT a.cdcooper,
           a.nrdconta,
           a.nrctremp
      FROM cecred.crapepr a 
     WHERE a.cdlcremp = 1500
       AND a.idquaprc not in (4);
       rw_crapepr c_crapepr%ROWTYPE;       
BEGIN
     FOR rw_crawepr IN c_crawepr LOOP
       vr_cont := vr_cont + 1; 
       vr_tab_crawepr(vr_cont).cdcooper := rw_crawepr.cdcooper;
       vr_tab_crawepr(vr_cont).nrdconta := rw_crawepr.nrdconta;
       vr_tab_crawepr(vr_cont).nrctremp := rw_crawepr.nrctremp;
     END LOOP;         
       FORALL vr_idx IN INDICES OF vr_tab_crawepr SAVE EXCEPTIONS
         UPDATE cecred.crawepr w
            SET w.idquapro = 4
          WHERE w.cdcooper = vr_tab_crawepr(vr_idx).cdcooper
           AND  w.nrdconta = vr_tab_crawepr(vr_idx).nrdconta
           AND  w.nrctremp = vr_tab_crawepr(vr_idx).nrctremp;
COMMIT;
       vr_cont := 0;
     FOR rw_crapepr IN c_crapepr LOOP
       vr_cont := vr_cont + 1; 
       vr_tab_crapepr(vr_cont).cdcooper := rw_crapepr.cdcooper;
       vr_tab_crapepr(vr_cont).nrdconta := rw_crapepr.nrdconta;
       vr_tab_crapepr(vr_cont).nrctremp := rw_crapepr.nrctremp;
     END LOOP;  
       FORALL vr_idx1 IN INDICES OF vr_tab_crapepr SAVE EXCEPTIONS
         UPDATE cecred.crapepr P
            SET p.idquaprc = 4
          WHERE P.cdcooper = vr_tab_crapepr(vr_idx1).cdcooper
           AND  P.nrdconta = vr_tab_crapepr(vr_idx1).nrdconta
           AND  P.nrctremp = vr_tab_crapepr(vr_idx1).nrctremp; 
COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
