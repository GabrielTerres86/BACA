/*************************************** 
 * SCRIPT PARA AJUSTE DAS PARCELAS 
 *   ... LIQUIDADAS EM PREJUÍZO
 * (INCORPORAÇÃO CREDCORREIOS)
 * TEMPO PREVISTO: 0,10 segundos
 *************************************** */
declare

  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
  vr_qtd_dias_atraso INTEGER;
  vr_cdcritic        INTEGER;
  vr_dscritic        VARCHAR2(4000);
  vr_dtdrisco        crapris.dtdrisco%TYPE;

begin
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  for i in (
        select pro_credc."nr_proposta" as nr_proposta
              ,pro_credc."cd_coop"     as cd_coop
              ,pro_credc."cd_posto"    as cd_posto
              ,conta_aimaro.nrdconta   as nrdconta
              ,pro_aimaro.nrctremp     as nrctremp
          from "proposta_credito"@credcorreiosinc pro_credc
              ,GESTAODERISCO.CREDCORREIOS_PROPOSTA pro_aimaro
              ,GESTAODERISCO.CREDCORREIOS_CONTA conta_aimaro
         where 1=1
           and pro_credc."nr_proposta" = pro_aimaro.nr_proposta
           and conta_aimaro.id_conta = pro_aimaro.id_conta
           /* prejuízo */
           and (select trunc(min(parc."dt_vcto_parc") )
                       from "parcela"@CREDCORREIOSINC parc
                      where 1=1
                        and parc."situacao_parc" <> 'L'
                        and parc."nr_proposta" = pro_credc."nr_proposta"
                        )+360 < (select trunc(dat.dtmvtolt) from crapdat dat where dat.cdcooper = 9)
         group by pro_credc."nr_proposta" 
                 ,pro_credc."cd_coop"     
                 ,pro_credc."cd_posto"    
                 ,conta_aimaro.nrdconta   
                 ,pro_aimaro.nrctremp     
         order by pro_credc."nr_proposta"
  ) loop
        /* parcelas */
        for parc_credcorreios in (
            select parc_credc."situacao_parc" as situacao_parc
                  ,parc_credc."nr_parcela" as nr_parcela
              from "parcela"@CREDCORREIOSINC parc_credc
             where 1=1
               and parc_credc."nr_proposta" = i.nr_proposta
              order by parc_credc."nr_parcela"
        ) loop
            -- dbms_output.put_line('UPDATE crappep SET inliquid = 0 WHERE cdcooper = 9 AND nrdconta = ' || i.NRDCONTA || ' AND nrctremp = ' || i.NRCTREMP || ' AND nrparepr = ' || parc_credcorreios.nr_parcela || ';');
            update crappep a
               set a.inliquid = decode(TRIM(parc_credcorreios.situacao_parc),'L',1,0)
             where 1=1
               and a.NRDCONTA = i.NRDCONTA
               and a.nrctremp = i.NRCTREMP
               and a.nrparepr = parc_credcorreios.nr_parcela
               and a.cdcooper = 9
            ;
        end loop;
  end loop;
  commit;

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
               AND ris.dtrefere = to_date('02/08/2021', 'dd/mm/YYYY')
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
                                        FROM gestaoderisco.credcorreios_proposta prop)
               AND EXISTS (SELECT 1
                             FROM crapris ris
                            WHERE ris.cdcooper = 9
                              AND ris.cdagenci = 28
                              AND ris.dtrefere = to_date('02/08/2021', 'dd/mm/YYYY')
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

    vr_dtdrisco := NULL;
    BEGIN
      SELECT dtdrisco INTO vr_dtdrisco
        FROM crapris ris
       WHERE ris.nrdconta = i.nrdconta
         AND ris.nrctremp = i.nrctremp
         AND ris.cdcooper = i.cdcooper
         AND ris.cdcooper = 9
         AND ris.cdagenci = 28
         AND ris.cdmodali IN (299,499);
    END;

    -- dbms_output.put_line('UPDATE crapris SET dtdrisco = to_date('''|| vr_dtdrisco ||''', ''dd/mm/YYYY'') WHERE cdagenci = 28 AND cdmodali IN (299,499) AND cdcooper = 9 AND nrdconta = ' || i.nrdconta || ' AND nrctremp = ' || i.nrctremp || ';');
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
exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
end;
