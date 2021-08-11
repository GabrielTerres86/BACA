/*
 * Tempo script: média de 10 segundos.
*/
DECLARE

  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
  vr_qtd_dias_atraso INTEGER;
  vr_cdcritic        INTEGER;
  vr_dscritic        VARCHAR2(4000);

BEGIN
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  vr_qtd_dias_atraso := 0;

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 9);
  FETCH cecred.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;

  FOR i IN (SELECT ris.cdcooper
                  ,ris.nrdconta
                  ,ris.nrctremp
              FROM crapris ris
             WHERE ris.cdcooper = 9
               AND ris.cdagenci = 28
               AND ris.nrctremp IN (SELECT prop.nrctremp
                                        FROM gestaoderisco.credcorreios_proposta prop WHERE TRUNC(prop.dth_registro) = '10/08/2021')
               AND ris.dtrefere = rw_crapdat.dtmvtoan
               AND ris.cdmodali IN (299,499)) LOOP

    cecred.EMPR0021.pc_atualiza_valor_59d(pr_cdcooper => i.cdcooper,
                                          pr_nrdconta => i.nrdconta,
                                          pr_nrctremp => i.nrctremp,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      DBMS_OUTPUT.put_line('ERRO: ' || i.cdcooper
                                    || ' - '
                                    || i.nrdconta
                                    || ' - '
                                    || i.nrctremp
                                    || ' - '
                                    || vr_cdcritic || ' - ' || vr_dscritic);
    END IF;
  END LOOP;
  COMMIT;

  FOR i IN (SELECT MAX(tbris.qtdiaatr) qtdiaatr
                  ,tbris.nrdconta nrdconta
                  ,tbris.nrctremp nrctremp
                  ,tbris.cdcooper cdcooper
              FROM tbrisco_central_ocr tbris
             WHERE 1 = 1
               AND tbris.cdcooper = 9
               AND tbris.cdmodali IN (299,499)
               AND tbris.nrctremp IN (SELECT prop.nrctremp
                                        FROM gestaoderisco.credcorreios_proposta prop WHERE TRUNC(prop.dth_registro) = '10/08/2021')
               AND EXISTS (SELECT 1
                             FROM crapris ris
                            WHERE ris.cdcooper = 9
                              AND ris.cdagenci = 28
                              AND ris.dtrefere = rw_crapdat.dtmvtoan
                              AND ris.cdmodali IN (299,499)
                              AND ris.nrctremp = tbris.nrctremp)
                         GROUP BY (nrdconta, nrctremp, cdcooper)) LOOP
  
    IF i.qtdiaatr >= 180 THEN
      vr_qtd_dias_atraso := 181;
    ELSIF i.qtdiaatr >= 150 THEN
      vr_qtd_dias_atraso := 151;
    ELSIF i.qtdiaatr >= 120 THEN
      vr_qtd_dias_atraso := 121;
    ELSIF i.qtdiaatr >= 90 THEN
      vr_qtd_dias_atraso := 91;
    ELSIF i.qtdiaatr >= 60 THEN
      vr_qtd_dias_atraso := 61;
    ELSIF i.qtdiaatr >= 30 THEN
      vr_qtd_dias_atraso := 31;
    ELSE
      vr_qtd_dias_atraso := 16;
    END IF;
  
    UPDATE crapris ris
       SET ris.dtdrisco =
           (rw_crapdat.dtmvtolt - i.qtdiaatr) + vr_qtd_dias_atraso
     WHERE ris.nrdconta = i.nrdconta
       AND ris.nrctremp = i.nrctremp
       AND ris.cdcooper = i.cdcooper
       AND ris.cdcooper = 9
       AND ris.cdagenci = 28
       AND ris.cdmodali IN (299,499);

  END LOOP;
  COMMIT;
END;
