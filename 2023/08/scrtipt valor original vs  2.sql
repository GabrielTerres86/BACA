DECLARE

  par_vlajuepr           NUMBER;
  par_vlemprst           NUMBER;
  par_txdiaria           NUMBER;
  par_taxa_mensal        NUMBER;
  par_vlparcela_original NUMBER;
  par_valor_principal    NUMBER := 0;
  par_dt_liberacao       DATE;
  par_dt_vencimento1     DATE;
  par_qtdiacar           NUMBER;
  par_qtparepr           NUMBER;
  vr_diapagto            VARCHAR2(4);
  vr_mespagto            VARCHAR2(4);
  vr_anopagto            VARCHAR2(4);

  CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE
                   ,pr_nrdconta crawepr.nrdconta%TYPE
                   ,pr_nrctremp crawepr.nrctremp%TYPE) IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,a.nrctremp
          ,a.qtpreemp
          ,a.vlemprst
          ,a.txmensal
          ,a.dtlibera
          ,a.dtvencto
      FROM cecred.crawepr a
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
  rw_crawepr cr_crawepr%ROWTYPE;

  CURSOR cr_crappep(pr_cdcooper crappep.cdcooper%TYPE
                   ,pr_nrdconta crappep.nrdconta%TYPE
                   ,pr_nrctremp crappep.nrctremp%TYPE) IS
    SELECT *
      FROM cecred.crappep a
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
     ORDER BY nrparepr;

BEGIN

  OPEN cr_crawepr(pr_cdcooper => 2
                 ,pr_nrdconta => 83232150
                 ,pr_nrctremp => 476020);
  FETCH cr_crawepr
    INTO rw_crawepr;
  CLOSE cr_crawepr;

  vr_diapagto := to_number(to_char(rw_crawepr.dtvencto, 'DD'));
  vr_mespagto := to_number(to_char(rw_crawepr.dtvencto, 'MM'));
  vr_anopagto := to_number(to_char(rw_crawepr.dtvencto, 'YYYY'));

  empr0001.pc_calc_dias360(pr_ehmensal => FALSE
                          ,pr_dtdpagto => to_char(rw_crawepr.dtlibera, 'DD')
                          ,pr_diarefju => to_char(rw_crawepr.dtlibera, 'DD')
                          ,pr_mesrefju => to_char(rw_crawepr.dtlibera, 'MM')
                          ,pr_anorefju => to_char(rw_crawepr.dtlibera
                                                 ,'YYYY')
                          ,pr_diafinal => vr_diapagto
                          ,pr_mesfinal => vr_mespagto
                          ,pr_anofinal => vr_anopagto
                          ,pr_qtdedias => par_qtdiacar);

  par_txdiaria := ROUND((100 *
                        (power((rw_crawepr.txmensal / 100) + 1, (1 / 30)) - 1))
                       ,10);

  par_vlajuepr := rw_crawepr.vlemprst *
                  power((1 + (par_txdiaria / 100)), par_qtdiacar - 30);

  par_vlparcela_original := (par_vlajuepr * rw_crawepr.txmensal / 100) /
                            (1 - power((1 + rw_crawepr.txmensal / 100)
                                      ,(-1 * rw_crawepr.qtpreemp)));

  FOR parc IN cr_crappep(pr_cdcooper => rw_crawepr.cdcooper
                        ,pr_nrdconta => rw_crawepr.nrdconta
                        ,pr_nrctremp => rw_crawepr.nrctremp) LOOP
  
    par_vlajuepr := par_vlajuepr - par_valor_principal;
  
    par_valor_principal := par_vlparcela_original -
                           (par_vlajuepr * (rw_crawepr.txmensal / 100));
  
    IF parc.inliquid = 1 THEN
      CONTINUE;
    END IF;
  
    dbms_output.put_line('Data de vencimento: ' || parc.dtvencto ||
                         ' - Parcela: ' || parc.nrparepr ||
                         ' - Valor principal R$ ' ||
                         round(par_valor_principal, 2));
  
  END LOOP;

END;
