declare
  vr_cdhistor         craplem.cdhistor%type;
  vr_nrdolote         craplem.nrdolote%type;
  vr_flgincre         boolean;
  vr_flgcredi         boolean;
  vr_cdcritic         number;
  vr_dscritic         varchar2(2000);
  vr_nmdireto         VARCHAR2(3000);
  vr_arqhandl         utl_file.file_type;
  vr_linha            VARCHAR2(5000);

  CURSOR cr_craplem is
    SELECT  distinct lem_deb.*, epr.dtliquid
    FROM    crapepr   epr
    INNER JOIN craplem   lem_deb
            ON (    lem_deb.cdcooper = epr.cdcooper
                AND lem_deb.nrdconta = epr.nrdconta
                AND lem_deb.nrctremp = epr.nrctremp
               )
    WHERE epr.tpemprst = 1 -- PP
    AND   epr.tpdescto = 2 -- Desconto em folha
    AND   (   epr.dtliquid IS NULL
           OR epr.dtliquid >=  to_date('19/01/2021', 'dd/mm/yyyy')
          )
    AND   lem_deb.cdcooper = 5
    AND   lem_deb.cdhistor = 1037
    AND   lem_deb.nrdolote = 600010
    AND   lem_deb.dtmvtolt > to_date('19/01/2021', 'dd/mm/yyyy')
    ORDER BY  lem_deb.cdcooper
             ,lem_deb.nrdconta
             ,lem_deb.nrctremp
             ,lem_deb.dtmvtolt;

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

  CURSOR cr_saldo_contrato ( pr_cdcooper in crapepr.cdcooper%type
                            ,pr_nrdconta in crapepr.nrdconta%type
                            ,pr_nrctremp in crapepr.nrctremp%type ) is
    SELECT SUM(CASE WHEN h.indebcre = 'C' THEN -l.vllanmto
                                WHEN h.indebcre = 'D' THEN l.vllanmto
                           END) vlsaldo
    FROM craplem   l
    JOIN craphis   h
      ON h.cdcooper = l.cdcooper
     AND h.cdhistor = l.cdhistor
    WHERE l.cdcooper = pr_cdcooper
      AND l.nrdconta = pr_nrdconta
      AND l.nrctremp = pr_nrctremp
     AND l.cdhistor NOT IN (
             1047, 1076     -- Multa
            ,1540, 1618     -- Multa Aval
            ,1077, 1078     -- Juros de Mora
            ,1619, 1620     -- Juros de Mora Aval
            ,1048           -- Desconto
            ,2311, 2312 );  -- IOF
  rw_saldo_contrato      cr_saldo_contrato%rowtype;
  
BEGIN
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 5, pr_nmsubdir => '/log');
        
  -- Abrir arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => 'estorna_lem_juros_indevidos_consig.txt'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqhandl
                          ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20501, 'Erro ao abrir arquivo log/estorna_lem_juros_indevidos_consig.txt');
  END IF; 

  OPEN cr_crapdat ( pr_cdcooper => 5 );
  FETCH  cr_crapdat
  INTO  rw_crapdat;
  CLOSE cr_crapdat;

  FOR rw_craplem IN cr_craplem LOOP
    IF rw_craplem.dtliquid is not null THEN
      OPEN cr_saldo_contrato ( pr_cdcooper => rw_craplem.cdcooper
                              ,pr_nrdconta => rw_craplem.nrdconta
                              ,pr_nrctremp => rw_craplem.nrctremp );
      FETCH  cr_saldo_contrato
      INTO  rw_saldo_contrato;
      CLOSE cr_saldo_contrato;

      IF rw_saldo_contrato.vlsaldo = 0 THEN
        CONTINUE;
      END IF;
    END IF;

    vr_linha := rw_craplem.cdcooper      || ';' ||
                rw_craplem.nrdconta      || ';' ||
                rw_craplem.nrctremp      || ';' ||
                rw_craplem.dtmvtolt      || ';' ||
                rw_craplem.vllanmto      || ';';

    GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);

    OPEN cr_crapass ( pr_cdcooper => rw_craplem.cdcooper
                     ,pr_nrdconta => rw_craplem.nrdconta );
    FETCH  cr_crapass
    INTO  rw_crapass;
    CLOSE cr_crapass;

    vr_cdhistor := 1041; -- Para contratos com saldo positivo
    vr_nrdolote := 600007;
    vr_flgincre := true;
    vr_flgcredi := true;

    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_craplem.cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => rw_crapass.cdagenci,
                                           pr_tplotmov => 5,
                                           pr_nrdolote => vr_nrdolote,
                                           pr_nrdconta => rw_craplem.nrdconta,
                                           pr_cdhistor => vr_cdhistor,
                                           pr_nrctremp => rw_craplem.nrctremp,
                                           pr_vllanmto => rw_craplem.vllanmto,
                                           pr_dtpagemp => rw_crapdat.dtmvtolt,
                                           pr_txjurepr => 0,
                                           pr_vlpreemp => 0,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 0,
                                           pr_flgincre => vr_flgincre,
                                           pr_flgcredi => vr_flgcredi,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 5,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  END LOOP;

  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);

  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    raise_application_error(-20501, SQLERRM);
END;
/
