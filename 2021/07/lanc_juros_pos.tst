PL/SQL Developer Test script 3.0
247
DECLARE
  CURSOR cr_lem_mensal(pr_cdcooper IN craplem.cdcooper%TYPE
                      ,pr_nrdconta IN craplem.nrdconta%TYPE
                      ,pr_nrctremp IN craplem.nrctremp%TYPE
                      ,pr_cdhistor IN craplem.cdhistor%TYPE) IS
    SELECT 1
      FROM craplem l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta 
       AND l.nrctremp = pr_nrctremp
       AND l.cdhistor = pr_cdhistor
       AND l.dtmvtolt = to_date('30/06/2021','dd/mm/rrrr');
  rw_lem_mensal cr_lem_mensal%ROWTYPE;
  
  CURSOR cr_apos_mensal(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_cdhistor IN craplem.cdhistor%TYPE) IS
    SELECT l.dtmvtolt
         , l.vllanmto
         , l.rowid
      FROM craplem l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta 
       AND l.nrctremp = pr_nrctremp
       AND l.cdhistor = pr_cdhistor
       AND l.dtmvtolt >= to_date('01/07/2021','dd/mm/rrrr')
  ORDER BY l.dtmvtolt;
  rw_apos_mensal cr_apos_mensal%ROWTYPE;
  
  vr_idx             NUMBER := 0;
  vr_dsdireto        VARCHAR2(1000);
  vr_des_erro        VARCHAR2(2000);
  vr_input_file      utl_file.file_type;
  vr_linha_arq       VARCHAR2(2000);
  vr_campo           GENE0002.typ_split;
  vr_achou           BOOLEAN;
  vr_arq_cdcooper    crapepr.cdcooper%TYPE;
  vr_arq_nrdconta    crapepr.nrdconta%TYPE;
  vr_arq_nrctremp    crapepr.nrctremp%TYPE;
  vr_arq_cdhistor    craplem.cdhistor%TYPE;
  vr_arq_dtmvtolt    craplem.dtmvtolt%TYPE;
  vr_arq_cdagenci    craplem.cdagenci%TYPE;
  vr_arq_cdbccxlt    craplem.cdbccxlt%TYPE;
  vr_arq_nrdolote    craplem.nrdolote%TYPE;
  vr_arq_nrdocmto    craplem.nrdocmto%TYPE;
  vr_arq_nrseqdig    craplem.nrseqdig%TYPE;
  vr_arq_vllanmto    craplem.vllanmto%TYPE;
  vr_arq_dtpagemp    craplem.dtpagemp%TYPE;
  vr_arq_txjurepr    craplem.txjurepr%TYPE;
  vr_arq_vlpreemp    craplem.vlpreemp%TYPE;
  vr_arq_nrautdoc    craplem.nrautdoc%TYPE;
  vr_arq_nrsequni    craplem.nrsequni%TYPE;
  vr_arq_nrparepr    craplem.nrparepr%TYPE;
  vr_arq_nrseqava    craplem.nrseqava%TYPE;
  vr_arq_dtestorn    craplem.dtestorn%TYPE;
  vr_arq_cdorigem    craplem.cdorigem%TYPE;
  vr_arq_dthrtran    craplem.dthrtran%TYPE;
  vr_arq_qtdiacal    craplem.qtdiacal%TYPE;
  vr_arq_vltaxper    craplem.vltaxper%TYPE;
  vr_arq_vltaxprd    craplem.vltaxprd%TYPE;
  vr_arq_nrdoclcm    craplem.nrdoclcm%TYPE;

begin
  vr_dsdireto := GENE0001.fn_diretorio('M',3,'jaison');

  GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_dsdireto || '/craplem_3006.csv'
                          ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                          ,pr_des_erro => vr_des_erro);

  IF utl_file.IS_OPEN(vr_input_file) THEN

    BEGIN

      LOOP
        GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                    ,pr_des_text => vr_linha_arq);
        vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,'"',''),',','.');
        vr_campo := GENE0002.fn_quebra_string(pr_string  => vr_linha_arq
                                             ,pr_delimit => ';');

        
        vr_idx := vr_idx + 1;
        IF vr_idx = 5000 THEN
          COMMIT;
          vr_idx := 0;
        END IF;
        
        -- Ignora cabecalho
        IF vr_campo(2) <> 'DTMVTOLT' THEN

          vr_arq_cdcooper := GENE0002.fn_char_para_number(vr_campo(17));
          vr_arq_nrdconta := GENE0002.fn_char_para_number(vr_campo(6));
          vr_arq_nrctremp := GENE0002.fn_char_para_number(vr_campo(10));
          vr_arq_cdhistor := GENE0002.fn_char_para_number(vr_campo(8));

          OPEN cr_lem_mensal(pr_cdcooper => vr_arq_cdcooper
                            ,pr_nrdconta => vr_arq_nrdconta
                            ,pr_nrctremp => vr_arq_nrctremp
                            ,pr_cdhistor => vr_arq_cdhistor);
          FETCH cr_lem_mensal INTO rw_lem_mensal;
          vr_achou := cr_lem_mensal%FOUND;
          CLOSE cr_lem_mensal;

          IF NOT vr_achou THEN

            vr_arq_dtmvtolt := to_date(vr_campo(2),'dd/mm/yyyy');
            vr_arq_cdagenci := GENE0002.fn_char_para_number(vr_campo(3));
            vr_arq_cdbccxlt := GENE0002.fn_char_para_number(vr_campo(4));
            vr_arq_nrdolote := GENE0002.fn_char_para_number(vr_campo(5));
            vr_arq_nrdocmto := vr_campo(7);
            vr_arq_nrseqdig := GENE0002.fn_char_para_number(vr_campo(9));
            vr_arq_vllanmto := GENE0002.fn_char_para_number(vr_campo(11));
            vr_arq_dtpagemp := to_date(vr_campo(12),'dd/mm/yyyy');
            vr_arq_txjurepr := GENE0002.fn_char_para_number(vr_campo(13));
            vr_arq_vlpreemp := GENE0002.fn_char_para_number(vr_campo(14));
            vr_arq_nrautdoc := vr_campo(15);
            vr_arq_nrsequni := vr_campo(16);
            vr_arq_nrparepr := GENE0002.fn_char_para_number(vr_campo(18));
            vr_arq_nrseqava := GENE0002.fn_char_para_number(vr_campo(20));
            vr_arq_dtestorn := to_date(vr_campo(21),'dd/mm/yyyy');
            vr_arq_cdorigem := GENE0002.fn_char_para_number(vr_campo(22));
            vr_arq_dthrtran := to_date(vr_campo(23), 'dd/mm/yyyy hh24:mi:ss');
            vr_arq_qtdiacal := GENE0002.fn_char_para_number(vr_campo(24));
            vr_arq_vltaxper := GENE0002.fn_char_para_number(vr_campo(25));
            vr_arq_vltaxprd := GENE0002.fn_char_para_number(vr_campo(26));
            vr_arq_nrdoclcm := GENE0002.fn_char_para_number(vr_campo(27));

            insert into craplem (DTMVTOLT
                               , CDAGENCI
                               , CDBCCXLT
                               , NRDOLOTE
                               , NRDCONTA
                               , NRDOCMTO
                               , CDHISTOR
                               , NRSEQDIG
                               , NRCTREMP
                               , VLLANMTO
                               , DTPAGEMP
                               , TXJUREPR
                               , VLPREEMP
                               , NRAUTDOC
                               , NRSEQUNI
                               , CDCOOPER
                               , NRPAREPR
                               , NRSEQAVA
                               , DTESTORN
                               , CDORIGEM
                               , DTHRTRAN
                               , QTDIACAL
                               , VLTAXPER
                               , VLTAXPRD
                               , NRDOCLCM)
                         values (vr_arq_dtmvtolt
                               , vr_arq_cdagenci
                               , vr_arq_cdbccxlt
                               , vr_arq_nrdolote
                               , vr_arq_nrdconta
                               , vr_arq_nrdocmto
                               , vr_arq_cdhistor
                               , vr_arq_nrseqdig
                               , vr_arq_nrctremp
                               , vr_arq_vllanmto
                               , vr_arq_dtpagemp
                               , vr_arq_txjurepr
                               , vr_arq_vlpreemp
                               , vr_arq_nrautdoc
                               , vr_arq_nrsequni
                               , vr_arq_cdcooper
                               , vr_arq_nrparepr
                               , vr_arq_nrseqava
                               , vr_arq_dtestorn
                               , vr_arq_cdorigem
                               , SYSDATE
                               , vr_arq_qtdiacal
                               , vr_arq_vltaxper
                               , vr_arq_vltaxprd
                               , vr_arq_nrdoclcm);

            OPEN cr_apos_mensal(pr_cdcooper => vr_arq_cdcooper
                               ,pr_nrdconta => vr_arq_nrdconta
                               ,pr_nrctremp => vr_arq_nrctremp
                               ,pr_cdhistor => vr_arq_cdhistor);
            FETCH cr_apos_mensal INTO rw_apos_mensal;
            vr_achou := cr_apos_mensal%FOUND;
            CLOSE cr_apos_mensal;

            IF vr_achou THEN
              IF vr_arq_cdhistor NOT IN (2346,2347) THEN
                UPDATE craplem l
                   SET l.vllanmto = l.vllanmto - vr_arq_vllanmto
                      ,l.dthrtran = SYSDATE
                 WHERE l.rowid = rw_apos_mensal.rowid;
              END IF;
            ELSE
              
              UPDATE crapcot 
               SET crapcot.qtjurmfx = NVL(crapcot.qtjurmfx,0) + ROUND(vr_arq_vllanmto / 0.82870000, 4)
             WHERE crapcot.cdcooper = vr_arq_cdcooper
               AND crapcot.nrdconta = vr_arq_nrdconta;  

              UPDATE crapepr
                 SET crapepr.dtrefjur = to_date('30/06/2021', 'DD/MM/YYYY')
                    ,crapepr.diarefju = 30
                    ,crapepr.mesrefju = 6
                    ,crapepr.anorefju = 2021
                    ,crapepr.dtrefcor = to_date('30/06/2021', 'DD/MM/YYYY')
                    ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + vr_arq_vllanmto
                    ,crapepr.vljuracu = NVL(crapepr.vljuracu,0) + (CASE WHEN vr_arq_cdhistor IN (2346,2347) THEN 0 ELSE vr_arq_vllanmto END)
                    ,crapepr.vljurmes = NVL(crapepr.vljurmes,0) + (CASE WHEN vr_arq_cdhistor IN (2346,2347) THEN 0 ELSE vr_arq_vllanmto END)
                    ,crapepr.vljuratu = 0
                    ,crapepr.indpagto = 0
               WHERE crapepr.cdcooper = vr_arq_cdcooper
                 AND crapepr.nrdconta = vr_arq_nrdconta
                 AND crapepr.nrctremp = vr_arq_nrctremp;
            
            END IF;

          END IF;

        END IF;

      END LOOP;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Fim das linhas do arquivo
        NULL;
    END;

  END IF;

  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

  COMMIT;
  dbms_output.put_line('FIM!');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    IF utl_file.IS_OPEN(vr_input_file) THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    END IF;
  
end;
0
1
vr_campo(21)
