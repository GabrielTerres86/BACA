DECLARE
  vr_cdhistor         craplem.cdhistor%type;
  vr_dif_saldo        craplem.vllanmto%type;
  vr_nrdolote         craplem.nrdolote%type;
  vr_flgincre         boolean;
  vr_flgcredi         boolean;
  vr_cdcritic         number;
  vr_dscritic         varchar2(2000);
  vr_nmdireto         VARCHAR2(3000);
  vr_arqhandl_liqd    utl_file.file_type;
  vr_arqhandl_multa   utl_file.file_type;
  vr_linha            VARCHAR2(5000);

  CURSOR cr_saldo_extrato IS
    SELECT  l.cdcooper
           ,l.nrdconta
           ,l.nrctremp
           ,e.dtliquid
           ,max(l.dtmvtolt)   dtextrato
           ,SUM(CASE WHEN h.indebcre = 'C' THEN -l.vllanmto
                            WHEN h.indebcre = 'D' THEN l.vllanmto
                       END) saldo
              FROM crapepr   e
              JOIN craplem   l
                ON l.cdcooper = e.cdcooper
               AND l.nrdconta = e.nrdconta
               AND l.nrctremp = e.nrctremp
              JOIN craphis   h
                ON h.cdcooper = l.cdcooper
               AND h.cdhistor = l.cdhistor
             WHERE e.tpemprst = 1
               AND e.tpdescto = 2
               AND e.dtliquid is not null
               AND l.cdhistor NOT IN (
                       1047, 1076     -- Multa
                      ,1540, 1618     -- Multa Aval
                      ,1077, 1078     -- Juros de Mora
                      ,1619, 1620     -- Juros de Mora Aval
                      ,1048           -- Desconto
                      ,2311, 2312 )   -- IOF
    HAVING SUM(CASE WHEN h.indebcre = 'C' THEN -l.vllanmto
                            WHEN h.indebcre = 'D' THEN l.vllanmto
                       END) <> 0
    GROUP BY  l.cdcooper
             ,l.nrdconta
             ,l.nrctremp
             ,e.dtliquid
    ORDER BY  SUM(CASE WHEN h.indebcre = 'C' THEN -l.vllanmto
                        WHEN h.indebcre = 'D' THEN l.vllanmto
                  END) desc;

  CURSOR cr_saldo_fis ( pr_cdcooper    in tbepr_consig_contrato_tmp.cdcooper%type
                       ,pr_nrdconta    in tbepr_consig_contrato_tmp.nrdconta%type
                       ,pr_nrctremp    in tbepr_consig_contrato_tmp.nrctremp%type
                       ,pr_dtmovimento in tbepr_consig_contrato_tmp.dtmovimento%type
                       ,pr_liquid      in tbepr_consig_contrato_tmp.dtmovimento%type ) IS
    SELECT vlsdev_empratu_d0
    FROM   tbepr_consig_contrato_tmp
    WHERE cdcooper    = pr_cdcooper
    AND   nrdconta    = pr_nrdconta 
    AND   nrctremp    = pr_nrctremp
    and   dtmovimento in (pr_dtmovimento, pr_liquid)
    order by  dtmovimento desc;
  rw_saldo_fis      cr_saldo_fis%rowtype;

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

  CURSOR cr_data_erro ( pr_cdcooper    in tbepr_consig_contrato_tmp.cdcooper%type
                       ,pr_nrdconta    in tbepr_consig_contrato_tmp.nrdconta%type
                       ,pr_nrctremp    in tbepr_consig_contrato_tmp.nrctremp%type ) IS
    select l.dtmvtolt
    from   craplem l
    where l.cdcooper = pr_cdcooper
    and   l.nrdconta = pr_nrdconta
    and   l.nrctremp = pr_nrctremp
    and   l.cdhistor = 1044
    and exists ( select l2.dtmvtolt
                 from   craplem l2
                 where l2.cdcooper  = l.cdcooper
                 and   l2.nrdconta  = l.nrdconta
                 and   l2.nrctremp  = l.nrctremp
                 and   l2.dtmvtolt  = l.dtmvtolt
                 and   l2.cdhistor IN ( 2311, 2312, 1076, 1047, 1618
                                       ,1540, 1078, 1077, 1620, 1619
                                       ,1051, 1050,  322, 2308, 2309
                                       ,2310, 2313, 2314)
               )
    having count(1) > 1
    group by l.dtmvtolt;

BEGIN
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 1, pr_nmsubdir => '/log');
        
  -- Abrir arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => 'contratos_liquidados_com_saldo.txt'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqhandl_liqd
                          ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20501, 'Erro ao abrir arquivo contratos_liquidados_com_saldo.txt');
  END IF; 
        
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => 'contratos_liquidados_extrato_errado.txt'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqhandl_multa
                          ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20502, 'Erro ao abrir arquivo contratos_liquidados_estrato_errado.txt');
  END IF; 
        
  vr_linha := 'Cooperativa;Conta;Contrato;Diferença;Saldo extrato;Saldo FIS;Data de liquidação;Data de último lançamento no extrato;';
  GENE0001.pc_escr_linha_arquivo(vr_arqhandl_liqd,vr_linha);

  vr_linha := 'Cooperativa;Conta;Contrato;Data do erro;Diferença;Saldo extrato;Saldo FIS;Data de liquidação;Data de último lançamento no extrato;';
  GENE0001.pc_escr_linha_arquivo(vr_arqhandl_multa,vr_linha);

  FOR rw_saldo_extrato IN cr_saldo_extrato LOOP
     OPEN cr_saldo_fis ( pr_cdcooper    => rw_saldo_extrato.cdcooper
                        ,pr_nrdconta    => rw_saldo_extrato.nrdconta
                        ,pr_nrctremp    => rw_saldo_extrato.nrctremp
                        ,pr_dtmovimento => rw_saldo_extrato.dtextrato
                        ,pr_liquid      => rw_saldo_extrato.dtliquid);
     FETCH cr_saldo_fis
     INTO  rw_saldo_fis;
     CLOSE cr_saldo_fis;

     vr_dif_saldo := rw_saldo_extrato.saldo - rw_saldo_fis.vlsdev_empratu_d0;
   

     IF rw_saldo_fis.vlsdev_empratu_d0 <> 0 THEN
        dbms_output.put_line('Coop: '             || rw_saldo_extrato.cdcooper      ||
                             ' Conta: '           || rw_saldo_extrato.nrdconta      ||
                             ' Contrato: '        || rw_saldo_extrato.nrctremp      ||
                             ' Diferença: '       || vr_dif_saldo                   ||
                             ' Saldo extrato: '   || rw_saldo_extrato.saldo         ||
                             ' Saldo FIS: '       || rw_saldo_fis.vlsdev_empratu_d0 ||
                             ' Data liquidação: ' || rw_saldo_extrato.dtextrato     ||
                             ' Data extrato: '    || rw_saldo_extrato.dtliquid );
     END IF;


     IF  vr_dif_saldo <> 0
     AND rw_saldo_fis.vlsdev_empratu_d0 = 0 THEN

        OPEN cr_crapdat ( pr_cdcooper => rw_saldo_extrato.cdcooper );
        FETCH  cr_crapdat
        INTO  rw_crapdat;
        CLOSE cr_crapdat;

        OPEN cr_crapass ( pr_cdcooper => rw_saldo_extrato.cdcooper
                         ,pr_nrdconta => rw_saldo_extrato.nrdconta );
        FETCH  cr_crapass
        INTO  rw_crapass;
        CLOSE cr_crapass;

        vr_linha := rw_saldo_extrato.cdcooper      || ';' ||
                    rw_saldo_extrato.nrdconta      || ';' ||
                    rw_saldo_extrato.nrctremp      || ';' ||
                    vr_dif_saldo                   || ';' ||
                    rw_saldo_extrato.saldo         || ';' ||
                    rw_saldo_fis.vlsdev_empratu_d0 || ';' ||
                    rw_saldo_extrato.dtliquid      || ';' ||
                    rw_saldo_extrato.dtextrato     || ';';
        GENE0001.pc_escr_linha_arquivo(vr_arqhandl_liqd,vr_linha);

        IF vr_dif_saldo < 0 THEN
          vr_cdhistor := 1040; -- Para contratos com saldo negativo
          vr_nrdolote := 600006;
          vr_flgincre := false;
          vr_flgcredi := false;
        ELSE
          vr_cdhistor := 1041; -- Para contratos com saldo positivo
          vr_nrdolote := 600007;
          vr_flgincre := true;
          vr_flgcredi := true;
        END IF;

        cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_saldo_extrato.cdcooper,
                                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                               pr_cdagenci => rw_crapass.cdagenci,
                                               pr_cdbccxlt => 100,
                                               pr_cdoperad => 1,
                                               pr_cdpactra => rw_crapass.cdagenci,
                                               pr_tplotmov => 5,
                                               pr_nrdolote => vr_nrdolote,
                                               pr_nrdconta => rw_saldo_extrato.nrdconta,
                                               pr_cdhistor => vr_cdhistor,
                                               pr_nrctremp => rw_saldo_extrato.nrctremp,
                                               pr_vllanmto => abs(vr_dif_saldo),
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

        FOR   rw_data_erro_saldo_fis IN cr_data_erro ( pr_cdcooper    => rw_saldo_extrato.cdcooper
                                                      ,pr_nrdconta    => rw_saldo_extrato.nrdconta
                                                      ,pr_nrctremp    => rw_saldo_extrato.nrctremp) loop
          vr_linha := rw_saldo_extrato.cdcooper       || ';' ||
                      rw_saldo_extrato.nrdconta       || ';' ||
                      rw_saldo_extrato.nrctremp       || ';' ||
                      rw_data_erro_saldo_fis.dtmvtolt || ';' ||
                      vr_dif_saldo                    || ';' ||
                      rw_saldo_extrato.saldo          || ';' ||
                      rw_saldo_fis.vlsdev_empratu_d0  || ';' ||
                      rw_saldo_extrato.dtliquid       || ';' ||
                      rw_saldo_extrato.dtextrato      || ';';
          GENE0001.pc_escr_linha_arquivo(vr_arqhandl_multa,vr_linha);
        END LOOP;
     END IF;
  END LOOP;

  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl_liqd);
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl_multa);

  COMMIT;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    raise_application_error(-20501, SQLERRM);
END;
/
