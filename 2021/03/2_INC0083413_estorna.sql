DECLARE
  vr_cdhistor         craplem.cdhistor%type;
  vr_nrdolote         craplem.nrdolote%type;
  vr_cdcritic         number;
  vr_dscritic         varchar2(2000);

  CURSOR cr_crapdat ( pr_cdcooper in craplcm.cdcooper%type ) is
     SELECT  dat.*
     FROM    crapdat   dat
     WHERE dat.cdcooper = pr_cdcooper;

  rw_crapdat   cr_crapdat%rowtype;

  CURSOR cr_crapass ( pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type ) is
     SELECT  cdagenci
     FROM    crapass
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta;
  rw_crapass         cr_crapass%rowtype;

  CURSOR cr_tcmt is
     SELECT  max(idseqmov) idseqmov, CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLDEBITO, VLCREDITO, VLSALDO, INTPLANCAMENTO, INSTATUSPROCES, DSERROPROCES, IDINTEGRACAO, DSMOTIVO
     FROM    tbepr_consig_movimento_tmp
     WHERE dtmovimento    = to_date('19/03/2021', 'dd/mm;yyyy')
     and   instatusproces = 'P'
and (cdcooper, nrdconta, nrctremp) in ( ( 1,8496439,2497560)
                                       ,(13, 202657, 80770)
                                       ,(13, 242470, 53912)
                                      )
     HAVING count(1) > 1
     GROUP BY  CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLDEBITO, VLCREDITO, VLSALDO, INTPLANCAMENTO, INSTATUSPROCES, DSERROPROCES, IDINTEGRACAO, DSMOTIVO
     ORDER BY  CDCOOPER, NRDCONTA, NRCTREMP;

  CURSOR cr_craplem ( pr_cdcooper       IN tbepr_consig_movimento_tmp.cdcooper%type
                     ,pr_nrdconta       IN tbepr_consig_movimento_tmp.nrdconta%type
                     ,pr_nrctremp       IN tbepr_consig_movimento_tmp.nrctremp%type
                     ,pr_nrparepr       IN tbepr_consig_movimento_tmp.nrparcela%type
                     ,pr_intplancamento IN tbepr_consig_movimento_tmp.intplancamento%type ) is
     SELECT  *
     FROM    craplem
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta
     AND   nrctremp = pr_nrctremp
     AND   nvl(nrparepr, pr_nrparepr) = pr_nrparepr
     AND   dtmvtolt = to_date('23/03/2021', 'dd/mm;yyyy')
     AND   (   (    pr_intplancamento = 2
                AND cdhistor in (1057, 1045, 1039, 1044) -- PAGAM.PARCELA
               )
            OR (    pr_intplancamento = 3
                AND cdhistor in (1057, 1045, 1039, 1044) -- PAGAM.PARCELA
               )
            OR (    pr_intplancamento = 4 -- JUROS DE MORA
                AND cdhistor in (1620, 1619, 1078, 1077)
               )
            OR (    pr_intplancamento = 5
                AND cdhistor in (1618, 1540, 1076, 1047) -- MULTA
               )
            OR (    pr_intplancamento = 6 -- IOF
                AND cdhistor in (2312, 2311)
               )
            OR (    pr_intplancamento = 10 -- Juros remuneratórios
                AND cdhistor in (1038, 1037)
               )
           );         

  CURSOR cr_craphis (pr_cdhistor IN craphis.cdhistor%type ) is
    SELECT  dshistor
    FROM craphis
    WHERE cdhistor= pr_cdhistor;

  rw_craphis   cr_craphis%rowtype;
                                                  
BEGIN
  dbms_output.enable(1000000);
  FOR rw_tcmt IN cr_tcmt LOOP
    OPEN cr_crapdat ( pr_cdcooper => rw_tcmt.cdcooper );
    FETCH  cr_crapdat
    INTO  rw_crapdat;
    CLOSE cr_crapdat;

    OPEN cr_crapass ( pr_cdcooper => rw_tcmt.cdcooper
                     ,pr_nrdconta => rw_tcmt.nrdconta );
    FETCH  cr_crapass
    INTO  rw_crapass;
    CLOSE cr_crapass;

    FOR rw_craplem IN cr_craplem ( pr_cdcooper       => rw_tcmt.cdcooper
                                  ,pr_nrdconta       => rw_tcmt.nrdconta
                                  ,pr_nrctremp       => rw_tcmt.nrctremp
                                  ,pr_nrparepr       => rw_tcmt.nrparcela
                                  ,pr_intplancamento => rw_tcmt.intplancamento ) LOOP
      OPEN cr_craphis (pr_cdhistor => rw_craplem.cdhistor);
      FETCH  cr_craphis
      INTO   rw_craphis;
      CLOSE cr_craphis;
      
      dbms_output.put_line( 'Cooperativa:'      || rw_tcmt.cdcooper       || ' ' ||
                           ' Conta:'            || rw_tcmt.nrdconta       || ' ' ||
                           ' Contrato:'         || rw_tcmt.nrctremp       || ' ' ||
                           ' Parcela:'          || rw_tcmt.nrparcela      || ' ' ||
                           ' Valor duplicado:'  || rw_tcmt.vlsaldo        || ' ' ||
                           ' Valor lançado:'    || rw_craplem.vllanmto    || ' ' ||
                           ' Historico:'        || rw_craplem.cdhistor    || ' ' ||
                           rw_craphis.dshistor                            || ' ' ||
                           ' intplancamento:'   || rw_tcmt.intplancamento || ' ' ||
                           ' instatusproces:'    || rw_tcmt.instatusproces);

        IF rw_craplem.cdhistor IN (1038, 1037) THEN -- Juros remuneratórios
          vr_cdhistor := 3272;
          vr_nrdolote := 600031;
        ELSIF rw_craplem.cdhistor IN (2312, 2311) THEN -- IOF
          vr_cdhistor := 1705;
          vr_nrdolote := 600031;
        ELSIF rw_craplem.cdhistor IN (1620, 1619, 1078, 1077) THEN -- JUROS DE MORA
          vr_cdhistor := 1711;
          vr_nrdolote := 600031;
        ELSIF rw_craplem.cdhistor IN (1618, 1540, 1076, 1047) THEN -- MULTA
          vr_cdhistor := 1708;
          vr_nrdolote := 600031;
        ELSIF rw_craplem.cdhistor IN (1057, 1045, 1039, 1044, 1057, 1045, 1039, 1044) THEN -- PAGAM.PARCELA
          vr_cdhistor := 1705;
          vr_nrdolote := 600031;
        END IF;

        cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_tcmt.cdcooper,
                                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                               pr_cdagenci => rw_crapass.cdagenci,
                                               pr_cdbccxlt => 100,
                                               pr_cdoperad => 1,
                                               pr_cdpactra => rw_crapass.cdagenci,
                                               pr_tplotmov => 5,
                                               pr_nrdolote => vr_nrdolote,
                                               pr_nrdconta => rw_tcmt.nrdconta,
                                               pr_cdhistor => vr_cdhistor,
                                               pr_nrctremp => rw_tcmt.nrctremp,
                                               pr_vllanmto => rw_tcmt.vlsaldo,
                                               pr_dtpagemp => rw_crapdat.dtmvtolt,
                                               pr_txjurepr => 0,
                                               pr_vlpreemp => 0,
                                               pr_nrsequni => 0,
                                               pr_nrparepr => 0,
                                               pr_flgincre => true,
                                               pr_flgcredi => true,
                                               pr_nrseqava => 0,
                                               pr_cdorigem => 5,
                                               pr_cdcritic => vr_cdcritic,
                                               pr_dscritic => vr_dscritic);
                        
    END LOOP;
  END LOOP;
  
  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20501, SQLERRM);
END;
/
