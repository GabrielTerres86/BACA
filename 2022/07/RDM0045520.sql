DECLARE
  vr_cdcooper CECRED.CRAPEPR.CDCOOPER%TYPE := 8;
  vr_nrdconta CECRED.CRAPEPR.NRDCONTA%TYPE := 31275;
  vr_nrctremp CECRED.CRAPEPR.NRCTREMP%TYPE := 6777;

BEGIN  
  UPDATE CECRED.CRAPEPR t
     SET t.vlprejuz = 138.90
       , t.vljrmprj = 0
       , t.vljraprj = 141.19
       , t.vlsprjat = 280.09
       , t.vlsdprej = 280.09
   WHERE t.cdcooper = vr_cdcooper
     AND t.nrdconta = vr_nrdconta
     AND t.nrctremp = vr_nrctremp;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
