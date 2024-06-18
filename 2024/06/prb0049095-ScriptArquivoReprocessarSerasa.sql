DECLARE

  ct_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PRB0049095';
  vr_module_name VARCHAR2(100) := NULL;
  vr_action_name VARCHAR2(100) := NULL;
  vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;

  PROCEDURE gerarLogEvento(pr_idprocessamento IN tbgen_prglog_ocorrencia.dsmensagem%TYPE
                          ,pr_dsmensagem      IN tbgen_prglog_ocorrencia.dsmensagem%TYPE) IS
  BEGIN
    cobr0014.gerarLogBatch(pr_cdcooper => 3
                          ,pr_cdagenci => 0
                          ,pr_cdprogra => ct_cdprogra
                          ,pr_idprglog => vr_idprglog
                          ,pr_dstiplog => 'O'
                          ,pr_tpocorre => 4
                          ,pr_dscritic => pr_idprocessamento || '#(' || pr_dsmensagem || ')#'
                          ,pr_cdcritic => 0
                          ,pr_cdcricid => 0);
  END gerarLogEvento;

  PROCEDURE logRegistroTarifa(pr_idprocessamento     VARCHAR2
                             ,pr_tab_lcm             paga0001.typ_tab_lcm_consolidada
                             ,pr_tab_lat_consolidada paga0001.typ_tab_lat_consolidada) IS
  
    vr_index   VARCHAR2(60);
    vr_dstexto VARCHAR2(4000);
  
  BEGIN
  
    vr_index   := NULL;
    vr_dstexto := NULL;
    vr_index   := pr_tab_lcm.first;
    IF pr_tab_lcm.EXISTS(vr_index) THEN
      WHILE vr_index IS NOT NULL
      LOOP
      
        vr_dstexto := '"pr_tab_lcm";"' || pr_tab_lcm(vr_index).cdcooper || '";"' || pr_tab_lcm(vr_index).nrdconta || '";"' || pr_tab_lcm(vr_index).nrconven ||
                      '";"' || pr_tab_lcm(vr_index).cdocorre || '";"' || pr_tab_lcm(vr_index).cdhistor || '";"' || pr_tab_lcm(vr_index).tplancto ||
                      '";"' ||
                      TRIM(to_char(pr_tab_lcm(vr_index).vllancto, '999999990d00', 'NLS_NUMERIC_CHARACTERS = '',.''')) ||
                      '";"' || pr_tab_lcm(vr_index).qtdregis || '";"' || pr_tab_lcm(vr_index).cdfvlcop || '";"' || pr_tab_lcm(vr_index).nrctremp ||
                      '";"' || pr_tab_lcm(vr_index).nrdocmto || '";"' || pr_tab_lcm(vr_index).cdpesqbb || '";"' || pr_tab_lcm(vr_index).cdmotivo ||
                      '";"' || pr_tab_lcm(vr_index).idtabcob || '"';
      
        gerarLogEvento(pr_idprocessamento => pr_idprocessamento, pr_dsmensagem => vr_dstexto);
      
        vr_index := pr_tab_lcm.next(vr_index);
      END LOOP;
    END IF;
  
    vr_index   := NULL;
    vr_dstexto := NULL;
    vr_index   := pr_tab_lat_consolidada.first;
    IF pr_tab_lat_consolidada.EXISTS(vr_index) THEN
      WHILE vr_index IS NOT NULL
      LOOP
      
        vr_dstexto := '"pr_tab_lat_consolidada";"' || pr_tab_lat_consolidada(vr_index).cdcooper || '";"' || pr_tab_lat_consolidada(vr_index).nrdconta ||
                      '";"' || pr_tab_lat_consolidada(vr_index).nrdocmto || '";"' || pr_tab_lat_consolidada(vr_index).nrcnvcob ||
                      '";"' || pr_tab_lat_consolidada(vr_index).dsincide || '";"' || pr_tab_lat_consolidada(vr_index).cdocorre ||
                      '";"' || pr_tab_lat_consolidada(vr_index).cdmotivo || '";"' ||
                      TRIM(to_char(pr_tab_lat_consolidada(vr_index).vllanmto
                                  ,'999999990d00'
                                  ,'NLS_NUMERIC_CHARACTERS = '',.''')) || '";"' ||
                      TRIM(pr_tab_lat_consolidada(vr_index).dscritic) || '"';
      
        gerarLogEvento(pr_idprocessamento => pr_idprocessamento, pr_dsmensagem => vr_dstexto);
      
        vr_index := pr_tab_lat_consolidada.next(vr_index);
      END LOOP;
    END IF;
  
  END logregistrotarifa;

  PROCEDURE pc_atualiza_situacao(pr_idprocessamento VARCHAR2
                                ,pr_rowid           IN ROWID
                                ,pr_intipret        IN PLS_INTEGER
                                ,pr_dsretser        IN VARCHAR2
                                ,pr_ufexceca        IN VARCHAR2
                                ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE
                                ,pr_dscritic        OUT VARCHAR2) IS
  
    CURSOR cr_crapcob IS
      SELECT a.inserasa
            ,a.cdcooper
            ,a.cdbandoc
            ,a.nrdctabb
            ,a.nrcnvcob
            ,a.nrdconta
            ,a.nrdocmto
            ,b.cdagenci
            ,b.cdbccxlt
            ,b.nrdolote
            ,b.nrconven
            ,a.dtretser
            ,a.dtvencto
        FROM cecred.crapcco b
            ,cecred.crapcob a
       WHERE a.ROWID = pr_rowid
         AND b.cdcooper = a.cdcooper
         AND b.nrconven = a.nrcnvcob;
    rw_crapcob cr_crapcob%ROWTYPE;
  
    CURSOR cr_erro(pr_cderro_serasa tbcobran_erros_serasa.cderro_serasa%TYPE) IS
      SELECT dserro_serasa
            ,cdocorre
            ,cdmotivo
        FROM cecred.tbcobran_erros_serasa
       WHERE cderro_serasa = pr_cderro_serasa;
    rw_erro cr_erro%ROWTYPE;
  
    CURSOR cr_dtlipgto(pr_rowid    ROWID
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT cob.dtvencto
            ,cob.vldescto
            ,cob.vlabatim
            ,cob.flgdprot
        FROM cecred.crapcob cob
       WHERE cob.dtlipgto < pr_dtmvtolt
         AND cob.incobran = 0
         AND cob.rowid = pr_rowid;
    rw_dtlipgto cr_dtlipgto%ROWTYPE;
  
    CURSOR cr_ultimaSituacaoSerasa(pr_cdcooper crapcob.cdcooper%TYPE
                                  ,pr_nrdconta crapcob.nrdconta%TYPE
                                  ,pr_cdbandoc crapcob.cdbandoc%TYPE
                                  ,pr_nrdctabb crapcob.nrdctabb%TYPE
                                  ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                                  ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      WITH UltimoSequencial AS
       (SELECT NVL(MAX(nrsequencia), 0) nrsequencia
          FROM CECRED.tbcobran_his_neg_serasa
         WHERE cdcooper = pr_cdcooper
           AND cdbandoc = pr_cdbandoc
           AND nrdctabb = pr_nrdctabb
           AND nrcnvcob = pr_nrcnvcob
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto),
      UltimaSituacao AS
       (SELECT inserasa
          FROM CECRED.tbcobran_his_neg_serasa
         INNER JOIN UltimoSequencial
            ON cecred.tbcobran_his_neg_serasa.nrsequencia = UltimoSequencial.nrsequencia
         WHERE tbcobran_his_neg_serasa.cdcooper = pr_cdcooper
           AND tbcobran_his_neg_serasa.cdbandoc = pr_cdbandoc
           AND tbcobran_his_neg_serasa.nrdctabb = pr_nrdctabb
           AND tbcobran_his_neg_serasa.nrcnvcob = pr_nrcnvcob
           AND tbcobran_his_neg_serasa.nrdconta = pr_nrdconta
           AND tbcobran_his_neg_serasa.nrdocmto = pr_nrdocmto)
      SELECT inserasa
        FROM UltimaSituacao;
    rw_ultimaSituacaoSerasa cr_ultimaSituacaoSerasa%ROWTYPE;
  
    CURSOR cr_dtvencto(pr_rowid ROWID) IS
      SELECT cob.dtvencto
            ,cob.vldescto
            ,cob.vlabatim
            ,cob.flgdprot
        FROM cecred.crapcob cob
       WHERE cob.rowid = pr_rowid
         AND cob.incobran = 0;
    rw_dtvencto cr_dtvencto%ROWTYPE;
  
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
  
    TYPE typ_tab_erros IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  
    vr_inserasa            crapcob.inserasa%TYPE;
    vr_dtretser            DATE;
    vr_dslog               VARCHAR2(500);
    vr_inreterr            PLS_INTEGER;
    vr_erros               typ_tab_erros;
    vr_erros_temp          PLS_INTEGER := 0;
    vr_ind                 PLS_INTEGER := 0;
    vr_tab_lcm             PAGA0001.typ_tab_lcm_consolidada;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
    vr_inreterr_tratado    PLS_INTEGER;
  
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);
  
    vr_exc_saida EXCEPTION;
  
  BEGIN
  
    OPEN cr_crapcob;
    FETCH cr_crapcob
      INTO rw_crapcob;
    CLOSE cr_crapcob;
  
    IF pr_dsretser IS NULL THEN
      vr_inreterr := 0;
    ELSE
      vr_inreterr := 1;
    
      LOOP
        EXIT WHEN TRIM(substr(pr_dsretser, (vr_ind * 3) + 1)) IS NULL;
      
        vr_erros(vr_ind + 1) := TRIM(substr(pr_dsretser, (vr_ind * 3) + 1, 3));
        vr_erros_temp := vr_erros(vr_ind + 1);
      
        IF pr_intipret = 3 THEN
          EXIT;
        END IF;
      
        vr_ind := vr_ind + 1;
        EXIT;
      END LOOP;
    END IF;
  
    vr_inreterr_tratado := vr_inreterr;
    IF vr_inreterr = 1 THEN
      IF vr_erros_temp = 391 THEN
        vr_inreterr_tratado := 0;
      END IF;
    END IF;
    IF pr_intipret = 3 AND pr_ufexceca <> 'S' AND rw_crapcob.inserasa IN (2, 5) THEN
      vr_inserasa := rw_crapcob.inserasa;
      vr_dtretser := rw_crapcob.dtretser;
      vr_dslog    := 'Serasa - Recebido informacoes apenas informacionais';
    ELSIF pr_intipret = 3 AND rw_crapcob.inserasa = 2 AND vr_erros_temp = 0 THEN
      vr_inserasa := rw_crapcob.inserasa;
      vr_dtretser := pr_dtmvtolt;
      vr_dslog    := 'Serasa - Recebido informacoes do AR';
    ELSIF pr_intipret = 3 AND rw_crapcob.inserasa = 2 AND vr_erros_temp <> 0 THEN
      vr_inserasa := 6;
      vr_dtretser := NULL;
      vr_dslog    := 'Serasa - Erro no recebimento da solicitacao da negativacao do AR';
    ELSIF pr_intipret = 3 AND rw_crapcob.inserasa <> 2 THEN
      vr_inserasa := rw_crapcob.inserasa;
      vr_dtretser := NULL;
      vr_dslog    := 'Serasa - Recebido informacoes do AR, porem boleto nao esta com situacao de enviada';
    ELSIF pr_intipret = 1 AND vr_inreterr_tratado = 0 AND rw_crapcob.inserasa IN (1, 2) THEN
      vr_inserasa := 2;
      vr_dtretser := pr_dtmvtolt;
      vr_dslog    := 'Negativacao em andamento';
    ELSIF pr_intipret = 1 AND vr_inreterr_tratado = 1 AND rw_crapcob.inserasa IN (1, 2) THEN
      IF vr_erros_temp <> 59 THEN
        vr_inserasa := 6;
        vr_dtretser := NULL;
      ELSE
        vr_inserasa := rw_crapcob.inserasa;
        vr_dtretser := rw_crapcob.dtretser;
      END IF;
    
      OPEN cr_erro(vr_erros_temp);
      FETCH cr_erro
        INTO rw_erro;
      vr_dslog := 'Falha no processo de negativacao - Motivo: Retorno Serasa: ' || rw_erro.dserro_serasa;
      CLOSE cr_erro;
    
    ELSIF pr_intipret = 1 AND vr_inreterr_tratado = 0 AND rw_crapcob.inserasa NOT IN (1, 2) THEN
      vr_inserasa := rw_crapcob.inserasa;
      vr_dtretser := NULL;
      vr_dslog    := 'Serasa - Recebido confirmacao de recebimento da solicitacao de inclusao, mas boleto esta com situacao ';
      IF rw_crapcob.inserasa = 0 THEN
        vr_dslog := vr_dslog || ' de nao negativada';
      ELSIF rw_crapcob.inserasa = 3 THEN
        vr_dslog := vr_dslog || ' de pendente de envio de cancelamento';
      ELSIF rw_crapcob.inserasa = 4 THEN
        vr_dslog := vr_dslog || ' de pendente de cancelamento';
      ELSIF rw_crapcob.inserasa = 5 THEN
        vr_dslog := vr_dslog || ' de negativado';
      ELSIF rw_crapcob.inserasa = 6 THEN
        vr_dslog := vr_dslog || ' de recusado na Serasa';
      ELSIF rw_crapcob.inserasa = 7 THEN
        vr_dslog := vr_dslog || ' de acao judicial';
      ELSE
        vr_dslog := vr_dslog || ' desconhecida (' || rw_crapcob.inserasa || ')';
      END IF;
    
    ELSIF pr_intipret = 1 AND vr_inreterr_tratado = 1 AND rw_crapcob.inserasa NOT IN (1, 2) THEN
      vr_inserasa := 0;
      vr_dtretser := NULL;
      vr_dslog    := 'Serasa - Erro no recebimento, mas situacao estava como solicitado cancelamento. Alterado situacao para nao negativado.';
    
    ELSIF pr_intipret = 2 THEN
      vr_inserasa := 0;
      vr_dtretser := NULL;
      vr_dslog    := 'Exclusão do cancelamento de negativacao do boleto - Serasa';
    END IF;
  
    IF pr_intipret = 2 AND vr_inserasa = 0 THEN
      UPDATE cecred.crapcob
         SET flserasa = 0
            ,qtdianeg = 0
       WHERE ROWID = pr_rowid;
    END IF;
  
    IF (NOT (pr_ufexceca = 'S' AND pr_intipret = 1)) OR vr_inserasa = 6 THEN
      BEGIN
        UPDATE cecred.crapcob
           SET inserasa = vr_inserasa
              ,dtretser = vr_dtretser
         WHERE ROWID = pr_rowid;
      
        OPEN cr_ultimaSituacaoSerasa(pr_cdcooper => rw_crapcob.cdcooper
                                    ,pr_nrdconta => rw_crapcob.nrdconta
                                    ,pr_cdbandoc => rw_crapcob.cdbandoc
                                    ,pr_nrdctabb => rw_crapcob.nrdctabb
                                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                    ,pr_nrdocmto => rw_crapcob.nrdocmto);
        FETCH cr_ultimaSituacaoSerasa
          INTO rw_ultimaSituacaoSerasa;
        CLOSE cr_ultimaSituacaoSerasa;
      
        IF vr_inserasa IN (0, 6) AND NVL(rw_ultimaSituacaoSerasa.inserasa, -1) NOT IN (0, 6) THEN
          BEGIN
            UPDATE cecred.crapcob
               SET dtlipgto = ADD_MONTHS(dtlipgto, -60)
             WHERE ROWID = pr_rowid;
          
            OPEN cr_dtlipgto(pr_dtmvtolt => pr_dtmvtolt, pr_rowid => pr_rowid);
            FETCH cr_dtlipgto
              INTO rw_dtlipgto;
          
            IF cr_dtlipgto%FOUND THEN
              COBR0007.pc_inst_pedido_baixa_decurso(pr_cdcooper            => rw_crapcob.cdcooper
                                                   ,pr_nrdconta            => rw_crapcob.nrdconta
                                                   ,pr_nrcnvcob            => rw_crapcob.nrcnvcob
                                                   ,pr_nrdocmto            => rw_crapcob.nrdocmto
                                                   ,pr_cdocorre            => 2
                                                   ,pr_dtmvtolt            => pr_dtmvtolt
                                                   ,pr_cdoperad            => '1'
                                                   ,pr_nrremass            => 0
                                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                   ,pr_cdcritic            => vr_cdcritic
                                                   ,pr_dscritic            => vr_dscritic);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
              PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => rw_crapcob.cdcooper
                                                   ,pr_dtmvtolt            => pr_dtmvtolt
                                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                   ,pr_cdcritic            => vr_cdcritic
                                                   ,pr_dscritic            => vr_dscritic);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            ELSE
              OPEN cr_dtvencto(pr_rowid => pr_rowid);
              FETCH cr_dtvencto
                INTO rw_dtvencto;
              IF cr_dtvencto%FOUND THEN
                DDDA0001.pc_procedimentos_dda_jd(pr_rowid_cob       => pr_rowid
                                                ,pr_tpoperad        => 'A'
                                                ,pr_tpdbaixa        => ' '
                                                ,pr_dtvencto        => rw_dtvencto.dtvencto
                                                ,pr_vldescto        => rw_dtvencto.vldescto
                                                ,pr_vlabatim        => rw_dtvencto.vlabatim
                                                ,pr_flgdprot        => rw_dtvencto.flgdprot
                                                ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                                ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                                ,pr_cdcritic        => vr_cdcritic
                                                ,pr_dscritic        => vr_dscritic);
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
              END IF;
              CLOSE cr_dtvencto;
            END IF;
            CLOSE cr_dtlipgto;
          
          EXCEPTION
            WHEN OTHERS THEN
              cecred.pc_internal_exception(PR_COMPLEME => '2 - instrucao dtlipgto serasa - crapcob.rowid = ' || pr_rowid);
          END;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(PR_COMPLEME => 'Erro linha 405:' || pr_rowid);
          vr_dscritic := 'Erro ao alterar CRAPCOB: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      BEGIN
        INSERT INTO cecred.tbcobran_his_neg_serasa
          (cdcooper
          ,cdbandoc
          ,nrdctabb
          ,nrcnvcob
          ,nrdconta
          ,nrdocmto
          ,nrsequencia
          ,dhhistorico
          ,inserasa
          ,dtretser
          ,cdoperad)
        VALUES
          (rw_crapcob.cdcooper
          ,rw_crapcob.cdbandoc
          ,rw_crapcob.nrdctabb
          ,rw_crapcob.nrcnvcob
          ,rw_crapcob.nrdconta
          ,rw_crapcob.nrdocmto
          ,(SELECT nvl(MAX(thns.nrsequencia), 0) + 1
             FROM cecred.tbcobran_his_neg_serasa thns
            WHERE thns.cdcooper = rw_crapcob.cdcooper
              AND thns.cdbandoc = rw_crapcob.cdbandoc
              AND thns.nrdctabb = rw_crapcob.nrdctabb
              AND thns.nrcnvcob = rw_crapcob.nrcnvcob
              AND thns.nrdconta = rw_crapcob.nrdconta
              AND thns.nrdocmto = rw_crapcob.nrdocmto)
          ,SYSDATE
          ,vr_inserasa
          ,vr_dtretser
          ,'1');
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(PR_COMPLEME => 'Erro linha 444:' || pr_rowid);
          vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
  
    paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => substr(vr_dslog, 1, 109)
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    vr_tab_lcm.delete;
  
    IF vr_inreterr = 1 THEN
      vr_ind := vr_erros.first;
      LOOP
        EXIT WHEN vr_ind IS NULL;
        OPEN cr_erro(vr_erros(vr_ind));
        FETCH cr_erro
          INTO rw_erro;
        IF cr_erro%NOTFOUND THEN
          CLOSE cr_erro;
          vr_dscritic := 'Erro ' || vr_erros(vr_ind) || ' nao previsto na tabela de erros da Serasa.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_erro;
      
        IF rw_erro.cdmotivo IS NOT NULL AND vr_inreterr_tratado = 1 THEN
          COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => pr_rowid
                                            ,pr_cdocorre => rw_erro.cdocorre
                                            ,pr_cdmotivo => rw_erro.cdmotivo
                                            ,pr_vltarifa => 0
                                            ,pr_cdbcoctl => 0
                                            ,pr_cdagectl => 0
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => '1'
                                            ,pr_nrremass => 0
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
          PAGA0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => pr_rowid
                                             ,pr_cdocorre            => rw_erro.cdocorre
                                             ,pr_tplancto            => 'T'
                                             ,pr_vltarifa            => 0
                                             ,pr_cdhistor            => 0
                                             ,pr_cdmotivo            => rw_erro.cdmotivo
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm
                                             ,pr_cdcritic            => vr_cdcritic
                                             ,pr_dscritic            => vr_dscritic);
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
        END IF;
      
        IF nvl(vr_erros(vr_ind), 0) = 302 THEN
          vr_dslog := 'Endereço incorreto: Mensagem dos correios - Não foi possível entregar a notificação ao pagador.';
        ELSIF nvl(vr_erros(vr_ind), 0) = 296 THEN
          vr_dslog := 'Falha no processo de negativação: O nome do pagador não corresponde ao CPF informado.';
        ELSIF nvl(vr_erros(vr_ind), 0) = 306 THEN
          vr_dslog := 'Pagador não localizado.';
        ELSIF nvl(vr_erros(vr_ind), 0) = 745 THEN
          vr_dslog := 'Falha no processo de negativação: O Boleto não será negativado.';
        ELSIF nvl(vr_erros(vr_ind), 0) = 22 THEN
          vr_dslog := 'A exclusão não pode ser realizada pois este boleto não está mais negativado.';
        ELSE
          vr_dslog := 'Retorno Serasa: ' || vr_erros(vr_ind) || '-' || rw_erro.dserro_serasa;
        END IF;
      
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => trunc(SYSDATE)
                                     ,pr_dsmensag => vr_dslog
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        vr_ind := vr_erros.next(vr_ind);
      
      END LOOP;
    ELSE
      IF pr_intipret = 1 THEN
        IF pr_ufexceca = 'S' THEN
          COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => pr_rowid
                                            ,pr_cdocorre => 93
                                            ,pr_cdmotivo => 'S4'
                                            ,pr_vltarifa => 0
                                            ,pr_cdbcoctl => 0
                                            ,pr_cdagectl => 0
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => '1'
                                            ,pr_nrremass => 0
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
          PAGA0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => pr_rowid
                                             ,pr_cdocorre            => 93
                                             ,pr_tplancto            => 'T'
                                             ,pr_vltarifa            => 0
                                             ,pr_cdhistor            => 0
                                             ,pr_cdmotivo            => 'S4'
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm
                                             ,pr_cdcritic            => vr_cdcritic
                                             ,pr_dscritic            => vr_dscritic);
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
        ELSE
          COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => pr_rowid
                                            ,pr_cdocorre => 93
                                            ,pr_cdmotivo => 'S2'
                                            ,pr_vltarifa => 0
                                            ,pr_cdbcoctl => 0
                                            ,pr_cdagectl => 0
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => '1'
                                            ,pr_nrremass => 0
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
          PAGA0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => pr_rowid
                                             ,pr_cdocorre            => 93
                                             ,pr_tplancto            => 'T'
                                             ,pr_vltarifa            => 0
                                             ,pr_cdhistor            => 0
                                             ,pr_cdmotivo            => 'S2'
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm
                                             ,pr_cdcritic            => vr_cdcritic
                                             ,pr_dscritic            => vr_dscritic);
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
        END IF;
      ELSIF pr_intipret = 2 THEN
        COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => pr_rowid
                                          ,pr_cdocorre => 94
                                          ,pr_cdmotivo => 'S2'
                                          ,pr_vltarifa => 0
                                          ,pr_cdbcoctl => 0
                                          ,pr_cdagectl => 0
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdoperad => '1'
                                          ,pr_nrremass => 0
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        PAGA0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => pr_rowid
                                           ,pr_cdocorre            => 94
                                           ,pr_tplancto            => 'T'
                                           ,pr_vltarifa            => 0
                                           ,pr_cdhistor            => 0
                                           ,pr_cdmotivo            => 'S2'
                                           ,pr_tab_lcm_consolidada => vr_tab_lcm
                                           ,pr_cdcritic            => vr_cdcritic
                                           ,pr_dscritic            => vr_dscritic);
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;
    END IF;
  
    IF vr_tab_lcm.exists(vr_tab_lcm.first) THEN
      PAGA0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper
                                          ,pr_dtmvtolt            => pr_dtmvtolt
                                          ,pr_cdagenci            => rw_crapcob.cdagenci
                                          ,pr_cdbccxlt            => rw_crapcob.cdbccxlt
                                          ,pr_nrdolote            => rw_crapcob.nrdolote
                                          ,pr_cdpesqbb            => rw_crapcob.nrconven
                                          ,pr_cdcritic            => vr_cdcritic
                                          ,pr_dscritic            => vr_dscritic
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm);
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
  
    logRegistroTarifa(pr_idprocessamento     => pr_idprocessamento
                     ,pr_tab_lcm             => vr_tab_lcm
                     ,pr_tab_lat_consolidada => vr_tab_lat_consolidada);
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      cobr0014.gerarLogBatch(pr_cdcooper => 3
                            ,pr_cdagenci => 0
                            ,pr_cdprogra => ct_cdprogra
                            ,pr_idprglog => vr_idprglog
                            ,pr_dstiplog => 'O'
                            ,pr_tpocorre => 4
                            ,pr_dscritic => 'pc_atualiza_situacao vr_exc_saida - ' || vr_dscritic
                            ,pr_cdcricid => vr_cdcritic);
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      raise_application_error(-20001, 'pc_atualiza_situacao vr_exc_saida: ' || pr_dscritic);
    WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      RAISE;
  END pc_atualiza_situacao;

  FUNCTION boletoJaProcessado(pr_dsboleto VARCHAR2) RETURN NUMBER IS
    vr_flboleto_processado NUMBER(1) := 0;
  BEGIN
    IF pr_dsboleto IN ('(1,101002,10558314,5494)'
                      ,'(1,101002,11856700,55)'
                      ,'(1,101002,11856700,56)'
                      ,'(1,101002,11856700,57)'
                      ,'(1,101002,8004102,8578)'
                      ,'(1,101002,8004102,8579)'
                      ,'(1,101002,15285189,825)'
                      ,'(1,101002,7250258,2456)'
                      ,'(1,101002,7250258,2468)'
                      ,'(1,101002,11564377,197)'
                      ,'(1,101002,11564377,211)'
                      ,'(1,101002,11564377,213)'
                      ,'(6,105001,249114,8),'
                      ,'(2,102002,633470,3280)') THEN
      vr_flboleto_processado := 1;
    END IF;
    RETURN vr_flboleto_processado;
  END boletoJaProcessado;

  PROCEDURE processarLinhaArquivo(pr_idprocessamento      VARCHAR2
                                 ,pr_dslinha              IN VARCHAR2
                                 ,pr_uf_excecao           VARCHAR2
                                 ,pr_cdcooper             IN OUT crapcob.cdcooper%TYPE
                                 ,pr_nrlinha_primeiro_900 IN OUT NUMBER
                                 ,pr_tpregistro_serasa    OUT NUMBER) IS
  
    CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
                     ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                     ,pr_nrdconta crapcob.nrdconta%TYPE
                     ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT cob.rowid idrowid_crapcob
            ,dat.dtmvtolt
        FROM cecred.crapcob cob
       INNER JOIN cecred.crapdat dat
          ON dat.cdcooper = cob.cdcooper
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;
  
    TYPE typ_tab_erros IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  
    vr_intipreg            PLS_INTEGER;
    vr_nrcnvcob            crapcob.nrcnvcob%TYPE;
    vr_nrdconta            crapcob.nrdconta%TYPE;
    vr_nrdocmto            crapcob.nrdocmto%TYPE;
    vr_intipret            PLS_INTEGER;
    vr_dsretser            VARCHAR2(60);
    vr_inreterr            PLS_INTEGER;
    vr_ind                 PLS_INTEGER;
    vr_erros               typ_tab_erros;
    vr_dsboleto_validar    VARCHAR2(100);
    vr_flboleto_processado NUMBER(1);
    vr_cderro_serasa       NUMBER;
    vr_ufsacado            crapsab.cdufsaca%TYPE;
    vr_ufexceca            VARCHAR2(1);
    vr_dscritic            VARCHAR2(32000) := NULL;
  
  BEGIN
  
    pr_tpregistro_serasa   := NULL;
    vr_dsboleto_validar    := NULL;
    vr_flboleto_processado := NULL;
    vr_intipreg            := substr(pr_dslinha, 1, 1);
  
    IF vr_intipreg = 0 THEN
    
      FOR rw_coop IN (SELECT cop.cdcooper
                        FROM cecred.crapcop cop
                       WHERE substr(lpad(cop.nrdocnpj, 15, '0'), 1, 9) = substr(pr_dslinha, 2, 9))
      LOOP
        pr_cdcooper := rw_coop.cdcooper;
      END LOOP;
    
    ELSIF vr_intipreg = 1 THEN
    
      vr_nrcnvcob := TRIM(substr(pr_dslinha, 773, 10));
      vr_nrdocmto := TRIM(substr(pr_dslinha, 704, 10));
      vr_nrdconta := nvl(TO_NUMBER(TRIM(substr(pr_dslinha, 783, 10))), 0);
    
      IF vr_nrdconta <> 0 THEN
      
        IF substr(pr_dslinha, 2, 1) = 'I' THEN
          vr_intipret := 1;
        ELSIF substr(pr_dslinha, 2, 1) = 'E' THEN
          vr_intipret := 2;
        ELSE
          vr_intipret := 3;
        END IF;
      
        pr_tpregistro_serasa := vr_intipret;
      
        vr_dsretser := rtrim(substr(pr_dslinha, 834, 60));
        vr_erros.delete;
        vr_ind := 0;
      
        IF vr_dsretser IS NULL THEN
          vr_inreterr := 0;
        ELSE
          vr_inreterr := 1;
          LOOP
            EXIT WHEN TRIM(substr(vr_dsretser, (vr_ind * 3) + 1)) IS NULL;
            vr_erros(vr_ind + 1) := TRIM(substr(vr_dsretser, (vr_ind * 3) + 1, 3));
            vr_cderro_serasa := vr_erros(vr_ind + 1);
            IF vr_intipret = 3 THEN
              EXIT;
            END IF;
            vr_ind := vr_ind + 1;
            EXIT;
          END LOOP;
        END IF;
      
        IF nvl(vr_cderro_serasa, 0) = 900 AND pr_nrlinha_primeiro_900 IS NULL THEN
          pr_nrlinha_primeiro_900 := to_number(substr(pr_dslinha, 894, 7));
        END IF;
      
        vr_dsboleto_validar    := '(' || pr_cdcooper || ',' || vr_nrcnvcob || ',' || vr_nrdconta || ',' || vr_nrdocmto || ')';
        vr_flboleto_processado := boletoJaProcessado(pr_dsboleto => vr_dsboleto_validar);
      
        IF vr_flboleto_processado = 0 AND pr_nrlinha_primeiro_900 IS NOT NULL THEN
        
          vr_ufsacado := TRIM(substr(pr_dslinha, 473, 2));
        
          IF instr(pr_uf_excecao, vr_ufsacado) <> 0 THEN
            vr_ufexceca := 'S';
          ELSE
            vr_ufexceca := 'N';
          END IF;
        
          OPEN cr_crapcob(pr_cdcooper, vr_nrcnvcob, vr_nrdconta, vr_nrdocmto);
          FETCH cr_crapcob
            INTO rw_crapcob;
          IF cr_crapcob%NOTFOUND THEN
            raise_application_error(-20001
                                   ,'open cr_crapcob - Boleto não encontrado: ' || vr_dsboleto_validar || ' - ' ||
                                    substr(pr_dslinha, 894, 7));
          END IF;
          CLOSE cr_crapcob;
        
          pc_atualiza_situacao(pr_idprocessamento => pr_idprocessamento
                              ,pr_rowid           => rw_crapcob.idrowid_crapcob
                              ,pr_intipret        => vr_intipret
                              ,pr_dsretser        => vr_dsretser
                              ,pr_ufexceca        => vr_ufexceca
                              ,pr_dtmvtolt        => rw_crapcob.dtmvtolt
                              ,pr_dscritic        => vr_dscritic);
        
        END IF;
      
      ELSE
        gerarLogEvento(pr_idprocessamento => pr_idprocessamento
                      ,pr_dsmensagem      => substr(pr_dslinha, 894, 7) ||
                                             '---------------------------------------------------------------------------------------------');
      END IF;
    
    END IF;
  
  END processarLinhaArquivo;

  PROCEDURE processarArquivo(pr_idprocessamento VARCHAR2
                            ,pr_dsdireto        VARCHAR2
                            ,pr_nmarquivo       VARCHAR2
                            ,pr_uf_excecao      VARCHAR2) IS
  
    vr_utlfileh                  utl_file.file_type;
    vr_dslinha                   VARCHAR2(4000);
    vr_qtlinha_arquivo           NUMBER := 0;
    vr_qtlinha_pendente_inclusao NUMBER := 0;
    vr_qtlinha_pendente_exclusao NUMBER := 0;
    vr_qtlinha_pendente_outros   NUMBER := 0;
    vr_nrlinha_primeiro_900      NUMBER := NULL;
    vr_tpregistro_serasa         NUMBER;
    vr_cdcooper                  crapcob.cdcooper%TYPE := NULL;
  
    vr_dscritic VARCHAR2(4000);
  
  BEGIN
  
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdireto
                            ,pr_nmarquiv => pr_nmarquivo
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, 'gene0001.pc_abre_arquivo:' || vr_dscritic);
    END IF;
  
    IF utl_file.is_open(vr_utlfileh) THEN
    
      LOOP
      
        vr_qtlinha_arquivo := vr_qtlinha_arquivo + 1;
        vr_dslinha         := NULL;
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh, pr_des_text => vr_dslinha);
        EXCEPTION
          WHEN no_data_found THEN
            EXIT;
        END;
      
        vr_tpregistro_serasa := NULL;
      
        processarLinhaArquivo(pr_idprocessamento      => pr_idprocessamento
                             ,pr_dslinha              => vr_dslinha
                             ,pr_uf_excecao           => pr_uf_excecao
                             ,pr_cdcooper             => vr_cdcooper
                             ,pr_nrlinha_primeiro_900 => vr_nrlinha_primeiro_900
                             ,pr_tpregistro_serasa    => vr_tpregistro_serasa);
      
        IF vr_nrlinha_primeiro_900 IS NOT NULL THEN
          IF nvl(vr_tpregistro_serasa, 0) = 1 THEN
            vr_qtlinha_pendente_inclusao := vr_qtlinha_pendente_inclusao + 1;
          ELSIF nvl(vr_tpregistro_serasa, 0) = 2 THEN
            vr_qtlinha_pendente_exclusao := vr_qtlinha_pendente_exclusao + 1;
          ELSIF nvl(vr_tpregistro_serasa, 0) = 3 THEN
            vr_qtlinha_pendente_outros := vr_qtlinha_pendente_outros + 1;
          END IF;
        END IF;
      
      END LOOP;
    
      gerarLogEvento(pr_idprocessamento => pr_idprocessamento
                    ,pr_dsmensagem      => '"arquivo";"' || pr_nmarquivo || '";"' || vr_qtlinha_arquivo || '";"' ||
                                           vr_nrlinha_primeiro_900 || '";"' || vr_qtlinha_pendente_inclusao || '";"' ||
                                           vr_qtlinha_pendente_exclusao || '";"' || vr_qtlinha_pendente_outros || '";"' ||
                                           vr_cdcooper || '"');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'processarArquivo others: ' || pr_nmarquivo, TRUE);
  END processarArquivo;

BEGIN

  DECLARE
  
    vr_dsdireto        VARCHAR2(300);
    vr_listaarq        VARCHAR2(32000);
    vr_tab_arqtmp      gene0002.typ_split;
    vr_indice          INTEGER;
    vr_uf_excecao      VARCHAR2(100) := ';';
    vr_idprocessamento VARCHAR2(50);
  
    vr_qttotal_arquivo     NUMBER := 0;
    vr_qtarquivo_processar NUMBER := 0;
  
    vr_dscritic VARCHAR2(4000);
  
  BEGIN
  
    vr_idprocessamento := 'PRB0049095:' || to_char(SYSDATE, 'yyyymmddhh24miss');
    vr_dsdireto        := gene0001.fn_diretorio(pr_tpdireto => 'M', pr_cdcooper => 3, pr_nmsubdir => 'cobranca/prb0049095');
  
    gerarLogEvento(pr_idprocessamento => vr_idprocessamento
                  ,pr_dsmensagem      => '"arquivo";"nmarquivo";"qtlinha_arquivo";"linha primeiro 900";"inclusao";"exclusao";"outro";"cooperativa"');
    gerarLogEvento(pr_idprocessamento => vr_idprocessamento
                  ,pr_dsmensagem      => '"pr_tab_lcm";"cdcooper";"nrdconta";"nrconven";"cdocorre";"cdhistor";"tplancto";"vllancto";"qtdregis";"cdfvlcop";"nrctremp";"nrdocmto";"cdpesqbb";"cdmotivo";"idtabcob"');
    gerarLogEvento(pr_idprocessamento => vr_idprocessamento
                  ,pr_dsmensagem      => '"pr_tab_lat_consolidada";"cdcooper";"nrdconta";"nrdocmto";"nrcnvcob";"dsincide";"cdocorre";"cdmotivo";"vllanmto";"dscritic"');
  
    FOR rw_excecao IN (SELECT dsuf
                         FROM cecred.tbcobran_param_exc_neg_serasa
                        WHERE indexcecao = 1)
    LOOP
      vr_uf_excecao := vr_uf_excecao || rw_excecao.dsuf || ';';
    END LOOP;
  
    FOR rw_dtref IN (SELECT to_date('15052024', 'ddmmyyyy') + LEVEL - 1 dtreferencia
                       FROM dual
                     CONNECT BY LEVEL <= 22
                      ORDER BY 1)
    LOOP
    
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto
                                ,pr_pesq     => '%CVDEV%' || TRIM(to_char(rw_dtref.dtreferencia, 'ddmmyy')) || '%'
                                ,pr_listarq  => vr_listaarq
                                ,pr_des_erro => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, 'gene0001.pc_lista_arquivos:' || vr_dscritic);
      END IF;
    
      IF vr_listaarq IS NOT NULL THEN
        vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarq);
        vr_indice     := vr_tab_arqtmp.first;
        WHILE vr_indice IS NOT NULL
        LOOP
        
          processarArquivo(pr_idprocessamento => vr_idprocessamento
                          ,pr_dsdireto        => vr_dsdireto
                          ,pr_nmarquivo       => vr_tab_arqtmp(vr_indice)
                          ,pr_uf_excecao      => vr_uf_excecao);
        
          COMMIT;
        
          vr_indice          := vr_tab_arqtmp.next(vr_indice);
          vr_qttotal_arquivo := vr_qttotal_arquivo + 1;
        
        END LOOP;
      
      END IF;
    
    END LOOP;
  
    gerarLogEvento(pr_idprocessamento => vr_idprocessamento, pr_dsmensagem => 'vr_qttotal_arquivo:' || vr_qttotal_arquivo);
  
    IF vr_qttotal_arquivo = 0 THEN
      raise_application_error(-20001, 'Nenhum arquivo localizado');
    END IF;
  
  END;

EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaointerna(pr_compleme => 'PRB0049095 Geral');
    ROLLBACK;
    RAISE;
END;
