DECLARE
  CURSOR cr_crapris IS
    SELECT r.cdcooper, r.nrdconta, r.nrctremp
      FROM crapris r, crapdat d
     WHERE d.cdcooper = r.cdcooper
       AND r.cdcooper IN (1,16)
       AND r.cdmodali = 901
       AND r.dtdrisco IS NULL
       AND r.dtrefere = d.dtmvcentral;
  rw_crapris cr_crapris%ROWTYPE;
  
  CURSOR cr_tbrisco_ocr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT o.dtdrisco
      FROM tbrisco_central_ocr o
     WHERE o.cdcooper = pr_cdcooper
       AND o.nrdconta = pr_nrdconta
       AND o.nrctremp = pr_nrctremp
       and o.cdmodali = 901
       AND o.dtdrisco IS NOT NULL
       AND rownum = 1
     ORDER BY o.dtrefere DESC;
  rw_tbrisco_ocr cr_tbrisco_ocr%ROWTYPE;
  
  CURSOR cr_crapris_min(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT MIN(dtrefere) dtrefere
      FROM crapris r
     WHERE r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND r.cdmodali = 901;
  rw_crapris_min cr_crapris_min%ROWTYPE;
BEGIN

  FOR rw_crapris IN cr_crapris LOOP
    OPEN cr_tbrisco_ocr(pr_cdcooper => rw_crapris.cdcooper
                       ,pr_nrdconta => rw_crapris.nrdconta
                       ,pr_nrctremp => rw_crapris.nrctremp);
    FETCH cr_tbrisco_ocr INTO rw_tbrisco_ocr;
    IF cr_tbrisco_ocr%FOUND THEN
      UPDATE crapris SET dtdrisco = rw_tbrisco_ocr.dtdrisco WHERE cdcooper = rw_crapris.cdcooper AND nrdconta = rw_crapris.nrdconta AND nrctremp = rw_crapris.nrctremp AND cdmodali = 901 AND dtdrisco IS NULL;
      UPDATE tbrisco_central_ocr SET dtdrisco = rw_tbrisco_ocr.dtdrisco WHERE cdcooper = rw_crapris.cdcooper AND nrdconta = rw_crapris.nrdconta AND nrctremp = rw_crapris.nrctremp AND cdmodali = 901 AND dtdrisco IS NULL;
    ELSE
      OPEN cr_crapris_min(pr_cdcooper => rw_crapris.cdcooper
                         ,pr_nrdconta => rw_crapris.nrdconta
                         ,pr_nrctremp => rw_crapris.nrctremp);
      FETCH cr_crapris_min INTO rw_crapris_min;
      UPDATE crapris SET dtdrisco = rw_crapris_min.dtrefere WHERE cdcooper = rw_crapris.cdcooper AND nrdconta = rw_crapris.nrdconta AND nrctremp = rw_crapris.nrctremp AND cdmodali = 901 AND dtdrisco IS NULL;
      UPDATE tbrisco_central_ocr SET dtdrisco = rw_crapris_min.dtrefere WHERE cdcooper = rw_crapris.cdcooper AND nrdconta = rw_crapris.nrdconta AND nrctremp = rw_crapris.nrctremp AND cdmodali = 901 AND dtdrisco IS NULL;
      CLOSE cr_crapris_min;
    END IF;
    CLOSE cr_tbrisco_ocr;
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao atualizar. '||SQLERRM);                
END;
