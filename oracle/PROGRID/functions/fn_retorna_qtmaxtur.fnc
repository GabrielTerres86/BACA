create or replace function progrid.fn_retorna_qtmaxtur(pr_idevento crapadp.idevento%TYPE
                                              ,pr_cdcooper crapadp.cdcooper%TYPE
                                              ,pr_cdagenci crapeap.cdagenci%TYPE
                                              ,pr_dtanoage crapadp.dtanoage%TYPE
                                              ,pr_cdevento crapadp.cdevento%TYPE) return integer is
  
  CURSOR cr_crapeap(pr_cdcooper crapeap.cdcooper%TYPE
                   ,pr_idevento crapeap.idevento%TYPE
                   ,pr_cdevento crapeap.cdevento%TYPE
                   ,pr_dtanoage crapeap.dtanoage%TYPE
                   ,pr_cdagenci crapeap.cdagenci%TYPE) IS

    SELECT eap.qtmaxtur 
      FROM crapeap eap
     WHERE eap.cdcooper = pr_cdcooper
       AND eap.idevento = pr_idevento                                     
       AND eap.cdevento = pr_cdevento
       AND eap.dtanoage = pr_dtanoage
       AND eap.cdagenci = pr_cdagenci;

  rw_crapeap cr_crapeap%ROWTYPE;

  CURSOR cr_crapedp(pr_idevento crapedp.idevento%TYPE
                   ,pr_cdcooper crapedp.cdcooper%TYPE
                   ,pr_dtanoage crapedp.dtanoage%TYPE
                   ,pr_cdevento crapedp.cdevento%TYPE) IS

    SELECT edp.qtmaxtur
      FROM crapedp edp
     WHERE edp.idevento = pr_idevento
       AND edp.cdcooper = pr_cdcooper
       AND edp.dtanoage = pr_dtanoage
       AND edp.cdevento = pr_cdevento;
  
  rw_crapedp cr_crapedp%ROWTYPE;

  vr_qtmaxtur crapeap.qtmaxtur%TYPE := 0;

BEGIN

  OPEN cr_crapeap(pr_cdcooper => pr_cdcooper
                 ,pr_idevento => pr_idevento
                 ,pr_cdevento => pr_cdevento
                 ,pr_dtanoage => pr_dtanoage
                 ,pr_cdagenci => pr_cdagenci);

  FETCH cr_crapeap INTO rw_crapeap;
          
  IF cr_crapeap%FOUND THEN

    CLOSE cr_crapeap;

    IF NVL(rw_crapeap.qtmaxtur,0) > 0 THEN
      vr_qtmaxtur := NVL(rw_crapeap.qtmaxtur,0);
    ELSE
      OPEN cr_crapedp(pr_idevento => pr_idevento
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_dtanoage => pr_dtanoage
                     ,pr_cdevento => pr_cdevento);

      FETCH cr_crapedp INTO rw_crapedp;

      IF cr_crapedp%FOUND THEN

        CLOSE cr_crapedp;

        IF rw_crapedp.qtmaxtur > 0 THEN
          vr_qtmaxtur := NVL(rw_crapedp.qtmaxtur,0);
        ELSE
                 
          OPEN cr_crapedp(pr_idevento => pr_idevento
                         ,pr_cdcooper => 0
                         ,pr_dtanoage => 0
                         ,pr_cdevento => pr_cdevento);

          FETCH cr_crapedp INTO rw_crapedp;

          IF cr_crapedp%FOUND THEN
            CLOSE cr_crapedp;
            vr_qtmaxtur := NVL(rw_crapedp.qtmaxtur,0);
          ELSE
            CLOSE cr_crapedp;
          END IF;       

        END IF;
      ELSE
        CLOSE cr_crapedp;
      END IF;

    END IF; -- rw_crapeap.qtmaxtur > 0         
  ELSE -- 
    CLOSE cr_crapeap;

    OPEN cr_crapedp(pr_idevento => pr_idevento
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_dtanoage => pr_dtanoage
                   ,pr_cdevento => pr_cdevento);

    FETCH cr_crapedp INTO rw_crapedp;

    IF cr_crapedp%FOUND THEN

      CLOSE cr_crapedp;

      IF NVL(rw_crapedp.qtmaxtur,0) > 0 THEN
        vr_qtmaxtur := rw_crapedp.qtmaxtur;          
      ELSE
                           
        OPEN cr_crapedp(pr_idevento => pr_idevento
                       ,pr_cdcooper => 0
                       ,pr_dtanoage => 0
                       ,pr_cdevento => pr_cdevento);

        FETCH cr_crapedp INTO rw_crapedp;

        IF cr_crapedp%FOUND THEN
          CLOSE cr_crapedp;
          vr_qtmaxtur := NVL(rw_crapedp.qtmaxtur,0);
        ELSE
          CLOSE cr_crapedp;
        END IF;       

      END IF;
    ELSE

      CLOSE cr_crapedp;

      OPEN cr_crapedp(pr_idevento => pr_idevento
                     ,pr_cdcooper => 0
                     ,pr_dtanoage => 0
                     ,pr_cdevento => pr_cdevento);

      FETCH cr_crapedp INTO rw_crapedp;

      IF cr_crapedp%FOUND THEN
        CLOSE cr_crapedp;
        vr_qtmaxtur := NVL(rw_crapedp.qtmaxtur,0);
      ELSE
        CLOSE cr_crapedp;
      END IF;       
    END IF;

  END IF;

  RETURN vr_qtmaxtur;

end fn_retorna_qtmaxtur;
/
