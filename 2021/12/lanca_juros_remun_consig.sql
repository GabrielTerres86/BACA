DECLARE

 vr_texto_padrao    VARCHAR2(200); 
 aux_qtd_reg        NUMBER := 0;
 vldivida_ris       NUMBER := 0;
 vlr_diff_real      NUMBER := 0;
 qt_dia_atr         NUMBER := 0;
 vlr_diff_tot_real  NUMBER := 0;
 vr_cdmodali        NUMBER := 0;
 vr_cdhistor        NUMBER := 0;
 rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
 vr_dtrefere        DATE   := TO_DATE('30/11/2021','DD/MM/YYYY');

  -- Arquivo de rollback
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0118765';
  vr_nmarqimp        VARCHAR2(100)  := 'diff_contabil.csv';     
  vr_ind_arquiv      utl_file.file_type;

  -- Variaveis tratamento de erro
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_dscritic       VARCHAR2(4000);
  vr_exc_saida      EXCEPTION;


  CURSOR cr_lanctos IS 
      SELECT tab.cdcooper, tab.nrdconta, tab.nrctremp, tab.cdagenci, tab.vlpreemp, tab.txjuremp, SUM(tab.tot) AS lanc
      FROM
        (SELECT (case when h.indebcre = 'D' then x.vllanmto else x.vllanmto * -1 end) as tot
                ,x.cdcooper
                ,x.nrdconta
                ,x.nrctremp
                ,a.cdagenci
                ,e.vlpreemp
                ,e.txjuremp
               FROM craplem x,
                    craphis h,
                    crapepr e,
                    crawepr w,
                    crapass a
               where e.tpemprst = 1
                 AND e.tpdescto = 2
                 AND e.inliquid = 0
                 AND e.inprejuz = 0   
                 AND e.dtmvtolt <= vr_dtrefere
                 and x.dtmvtolt <= vr_dtrefere
                 AND (h.nrctacrd IN (1664,1667) OR h.nrctadeb IN (1664,1667))
                 and x.cdcooper = h.cdcooper
                 and x.cdhistor = h.cdhistor
                 AND e.cdcooper = x.cdcooper
                 AND e.nrdconta = x.nrdconta
                 AND e.nrctremp = x.nrctremp
                 AND w.cdcooper = e.cdcooper
                 AND w.nrdconta = e.nrdconta
                 AND w.nrctremp = e.nrctremp
                 AND e.cdcooper = a.cdcooper
                 AND e.nrdconta = a.nrdconta                 
                 AND e.cdlcremp <> 100
                 AND NOT EXISTS(SELECT 1
                            FROM tbepr_renegociacao_contrato trc
                                ,tbepr_renegociacao tr
                           WHERE trc.nrctrotr = 0
                             AND trc.cdcooper = e.cdcooper
                             AND trc.nrdconta = e.nrdconta
                             AND trc.nrctrepr = e.nrctremp
                             AND tr.cdcooper = trc.cdcooper
                             AND tr.nrdconta = trc.nrdconta
                             AND tr.nrctremp = trc.nrctremp 
                             AND (tr.dtlibera = x.dtmvtolt)
                             AND x.cdhistor IN (1036, 1059, 2326, 2327)
                              )                      
        UNION ALL
          SELECT (case when h.indebcre = 'D' then x.vllanmto else x.vllanmto * -1 end) as tot
                  ,x.cdcooper
                  ,x.nrdconta
                  ,x.nrctremp                 
                  ,a.cdagenci      
                  ,e.vlpreemp   
                  ,e.txjuremp                           
                from tbepr_renegociacao_craplem x
                    ,craphis h
                    ,crapepr e
                    ,crawepr w
                    ,crapass a
                 where e.tpemprst = 1
                   AND e.tpdescto = 2
                   AND e.inliquid = 0
                   AND e.inprejuz = 0   
                   AND e.dtmvtolt <= vr_dtrefere
                   and x.dtmvtolt <= vr_dtrefere
                   AND (h.nrctacrd IN (1664,1667) OR h.nrctadeb IN (1664,1667)) 
                   and x.cdcooper = h.cdcooper
                   and x.cdhistor = h.cdhistor
                   AND e.cdcooper = x.cdcooper
                   AND e.nrdconta = x.nrdconta
                   AND e.nrctremp = x.nrctremp
                   AND w.cdcooper = e.cdcooper
                   AND w.nrdconta = e.nrdconta
                   AND w.nrctremp = e.nrctremp
                   AND e.cdcooper = a.cdcooper
                   AND e.nrdconta = a.nrdconta
                   AND e.cdlcremp <> 100     
                 AND NOT EXISTS(SELECT 1
                            FROM tbepr_renegociacao_contrato trc
                                ,tbepr_renegociacao tr
                           WHERE trc.nrctrotr = 0
                             AND trc.cdcooper = e.cdcooper
                             AND trc.nrdconta = e.nrdconta
                             AND trc.nrctrepr = e.nrctremp
                             AND tr.cdcooper = trc.cdcooper
                             AND tr.nrdconta = trc.nrdconta
                             AND tr.nrctremp = trc.nrctremp 
                             AND (tr.dtlibera = x.dtmvtolt )
                             AND x.cdhistor IN (1036, 1059, 2326, 2327) )  
                           
        ) tab  GROUP BY tab.cdcooper, tab.nrdconta, tab.nrctremp, tab.cdagenci, tab.vlpreemp, tab.txjuremp;
  rw_lanctos cr_lanctos%ROWTYPE; 

  CURSOR cr_crps_mes_atual(pr_cdcooper crapvri.cdcooper%TYPE
                          ,pr_nrdconta crapvri.nrdconta%TYPE
                          ,pr_nrctremp crapvri.nrctremp%TYPE ) IS 
     select sum(crapvri.vldivida) vri_div, crapris.qtdiaatr, crapris.cdmodali
      from crapris
          ,crapvri
      WHERE crapvri.cdcooper = crapris.cdcooper
       and crapvri.nrdconta = crapris.nrdconta
       and crapvri.dtrefere = crapris.dtrefere
       and crapvri.innivris = crapris.innivris
       and crapvri.cdmodali = crapris.cdmodali
       and crapvri.nrctremp = crapris.nrctremp
       and crapvri.nrseqctr = crapris.nrseqctr
       and crapris.cdcooper = pr_cdcooper
       and crapris.dtrefere = vr_dtrefere
       and crapris.cdorigem = 3
       AND crapris.inddocto = 1
       and crapvri.cdvencto BETWEEN 110 AND 290
       AND crapvri.nrdconta = pr_nrdconta
       AND crapvri.nrctremp = pr_nrctremp
     GROUP BY crapris.qtdiaatr, crapris.cdmodali;
       

BEGIN
  
  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;

  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'COOP;CONTA;CONTRATO;HISTORICO;VALOR;RESULTADO;OBSERVACAO');

  OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;  
  CLOSE BTCH0001.cr_crapdat;
  
  
  FOR rw_lanctos IN cr_lanctos LOOP
    -- Zera as variaveis, pae
    qt_dia_atr      := 0;
    vr_cdmodali     := 0;
    vldivida_ris    := 0;
    vlr_diff_real   := 0;
    vr_texto_padrao := '';


    OPEN cr_crps_mes_atual(rw_lanctos.cdcooper, rw_lanctos.nrdconta, rw_lanctos.nrctremp);
    FETCH cr_crps_mes_atual INTO vldivida_ris, qt_dia_atr, vr_cdmodali;
    CLOSE cr_crps_mes_atual;

    aux_qtd_reg     := aux_qtd_reg + 1;
    vr_cdhistor     := (CASE WHEN vr_cdmodali = 299 THEN 1037 ELSE 1038 END);

    -- Calcula a diff sobra     
    vlr_diff_real := nvl(vldivida_ris, 0) - nvl(rw_lanctos.lanc, 0);

    -- Calcula a diff falta
    --vlr_diff_real := nvl(rw_lanctos.lanc, 0) - nvl(vldivida_ris, 0);

    -- Se for uma diferença de Sobra (saldo devedor > que soma lancto), iremos considerar como juros remun
    IF nvl(vlr_diff_real, 0) > 0.1 THEN 
      
      vr_texto_padrao := rw_lanctos.cdcooper || ';' ||
                         rw_lanctos.nrdconta || ';' ||
                         rw_lanctos.nrctremp || ';' ||
                         vr_cdhistor         || ';' ||
                         vlr_diff_real       || ';';
    

      empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_lanctos.cdcooper --Codigo Cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Emprestimo
                                      ,pr_cdagenci => rw_lanctos.cdagenci --Codigo Agencia
                                      ,pr_cdbccxlt => 100 --Codigo Caixa
                                      ,pr_cdoperad => 1 --Operador
                                      ,pr_cdpactra => rw_lanctos.cdagenci --Posto Atendimento - - agencia do coperado crapass
                                      ,pr_tplotmov => 5 --Tipo movimento
                                      ,pr_nrdolote => 600013 --Numero Lote
                                      ,pr_nrdconta => rw_lanctos.nrdconta --Numero da Conta
                                      ,pr_cdhistor => vr_cdhistor --Codigo Historico do juros remuneratorio
                                      ,pr_nrctremp => rw_lanctos.nrctremp --Numero Contrato
                                      ,pr_vllanmto => vlr_diff_real  -- Valor do lançamento
                                      ,pr_dtpagemp => rw_crapdat.dtmvtolt --Data Pagamento Emprestimo
                                      ,pr_txjurepr => rw_lanctos.txjuremp --Taxa Juros Emprestimo
                                      ,pr_vlpreemp => rw_lanctos.vlpreemp --Valor Emprestimo
                                      ,pr_nrsequni => 0 --Numero Sequencia
                                      ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                      ,pr_flgincre => TRUE --Indicador Credito
                                      ,pr_flgcredi => TRUE --Credito
                                      ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                      ,pr_cdorigem => 7 -- Batch
                                      ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                      ,pr_dscritic => vr_dscritic); --Descricao Erro
     
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_texto_padrao || 'NOK;' || vr_dscritic);
        CONTINUE;
      END IF;

      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_texto_padrao || 'OK;');
    END IF ;

    -- commit a cada 1k 
    IF aux_qtd_reg = 1000 THEN
      aux_qtd_reg := 0;
      COMMIT;
    END IF;    
      
  END LOOP;  

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 
  COMMIT;  

EXCEPTION
  WHEN vr_exc_saida THEN 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    ROLLBACK;
END; 
