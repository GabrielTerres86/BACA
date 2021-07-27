PL/SQL Developer Test script 3.0
440
-- Created on 26/07/2021 by T0032717 
DECLARE 
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_principal(pr_cdcooper IN crapepr.cdcooper%TYPE) IS
    SELECT s.cdcooper, s.nrdconta, s.nrctremp, w.cdlcremp, w.tpemprst, w.qtpreemp, w.dtdpagto, w.cdfinemp, w.idfiniof, w.dtcarenc, w.vlemprst
          ,to_char(decode(w.nrctrliq##1, 0, null, w.nrctrliq##1)) || ',' ||
           to_char(decode(w.nrctrliq##2, 0, null, w.nrctrliq##2)) || ',' ||
           to_char(decode(w.nrctrliq##3, 0, null, w.nrctrliq##3)) || ',' ||
           to_char(decode(w.nrctrliq##4, 0, null, w.nrctrliq##4)) || ',' ||
           to_char(decode(w.nrctrliq##5, 0, null, w.nrctrliq##5)) || ',' ||
           to_char(decode(w.nrctrliq##6, 0, null, w.nrctrliq##6)) || ',' ||
           to_char(decode(w.nrctrliq##7, 0, null, w.nrctrliq##7)) || ',' ||
           to_char(decode(w.nrctrliq##8, 0, null, w.nrctrliq##8)) || ',' ||
           to_char(decode(w.nrctrliq##9, 0, null, w.nrctrliq##9)) || ',' ||
           to_char(decode(w.nrctrliq##10, 0, null, w.nrctrliq##10)) dsliquid
      FROM credito.tbepr_renegociacao_simula s
          ,tbepr_renegociacao r
          ,crawepr w
          ,crapdat d
     WHERE w.cdcooper = pr_cdcooper
       AND s.idprphib = 0          -- nao hibrida
       AND s.cdcooper = w.cdcooper
       AND s.nrdconta = w.nrdconta
       AND s.nrctremp = w.nrctremp
       AND r.cdcooper = s.cdcooper
       AND r.nrdconta = s.nrdconta
       AND r.nrctremp = s.nrctremp
       AND d.cdcooper = w.cdcooper -- crapdat
       AND w.dtlibera < d.dtmvtolt -- precisa atualizar data
       AND r.dtlibera IS NULL      -- nao efetivado
       AND (w.dtaprova + 30) >= d.dtmvtolt -- validade da proposta
       AND w.insitapr = 1; -- aprovadas
  rw_principal cr_principal%ROWTYPE;
  
  -- Dados dos bens da proposta
  CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                   ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                   ,pr_nrctremp IN crapbpr.nrctrpro%TYPE
                   ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE) IS
    SELECT b.dscatbem
      FROM crapbpr b
     WHERE b.cdcooper = pr_cdcooper
       AND b.nrdconta = pr_nrdconta
       AND b.nrctrpro = pr_nrctremp
       AND b.tpctrpro = pr_tpctrpro;
  rw_crapbpr cr_crapbpr%ROWTYPE;
  
  -- Dados da conta
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT a.inpessoa, 
           a.nrcpfcgc
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_tbepr_renegociacao(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                              ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                              ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE) IS
    SELECT * 
      FROM tbepr_renegociacao
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_tbepr_renegociacao cr_tbepr_renegociacao%ROWTYPE;
  
  CURSOR cr_tbepr_renegociacao_contrato(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                                       ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                                       ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE) IS
    SELECT * 
      FROM tbepr_renegociacao_contrato
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_tbepr_renegociacao_contrato cr_tbepr_renegociacao_contrato%ROWTYPE;
  
  CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
    SELECT * 
      FROM crawepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_crawepr cr_crawepr%ROWTYPE;
  
  vr_dscritic        VARCHAR2(4000);
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_des_erro        VARCHAR2(4000);
  vr_nrdrowid        ROWID;
  
  vr_exc_erro        EXCEPTION;
  
  rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);

  vr_dsorigem        VARCHAR2(50);
  vr_dstransa        VARCHAR2(50);
  vr_vlemprst        crawepr.vlemprst%TYPE;
  vr_vlpreemp_or     crawepr.vlemprst%TYPE;
  vr_vlpreemp        crawepr.vlpreemp%TYPE;
  vr_cdperapr        NUMBER;
  vr_dscatbem        VARCHAR2(500);
  vr_txcetano        NUMBER;
  vr_txcetmes        NUMBER;
  vr_nivrisco        VARCHAR2(20);
  vr_incontgencia    VARCHAR2(1);
BEGIN
  
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0098265'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0098265_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  vr_dsorigem := GENE0001.vr_vet_des_origens(5);
  vr_dstransa := 'Recalcular Emprestimo';
  -- Test statements here
  FOR rw_crapcop IN cr_crapcop LOOP
    -- Verificação do calendário
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1; --Sistema sem data de movimento.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    FOR rw_principal IN cr_principal(rw_crapcop.cdcooper) LOOP
      
      OPEN cr_crawepr(pr_cdcooper => rw_principal.cdcooper
                     ,pr_nrdconta => rw_principal.nrdconta
                     ,pr_nrctremp => rw_principal.nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;
    
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE crawepr 
                                  SET vlpreemp = ' || REPLACE(rw_crawepr.vlpreemp, ',', '.') || '
                                     ,vlemprst = ' || REPLACE(rw_crawepr.vlemprst, ',', '.') || ' 
                                     ,dtlibera = to_date(''' || rw_crawepr.dtlibera || ''', ''dd-mm-yyyy'')
                                     ,percetop = ' || rw_crawepr.percetop || '
                                     ,dsnivris = ' || rw_crawepr.dsnivris || '
                                     ,dsnivori = ' || rw_crawepr.dsnivori || '
                                     ,insitapr = ' || rw_crawepr.insitapr || '
                                     ,cdopeapr = ' || rw_crawepr.cdopeapr || '
                                     ,dtaprova = ' || rw_crawepr.dtaprova || '
                                     ,hraprova = ' || rw_crawepr.hraprova || '
                                     ,insitest = ' || rw_crawepr.insitest || '
                                     ,txmensal = ' || rw_crawepr.txmensal || '
                                     ,txdiaria = ' || rw_crawepr.txdiaria || '
                                WHERE cdcooper = ' || rw_principal.CDCOOPER || ', 
                                  AND nrdconta = ' || rw_principal.NRDCONTA || ', 
                                  AND nrctremp = ' || rw_principal.NRCTREMP || ';' ||chr(13)||chr(13), FALSE); 
        
      
      OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrdconta => rw_principal.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        CLOSE cr_crapass;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      
      vr_vlemprst := rw_principal.vlemprst;
      vr_vlpreemp_or := vr_vlpreemp;
  
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_nrdconta => rw_principal.nrdconta,
                                   pr_nrctremp => rw_principal.nrctremp,
                                   pr_tpctrpro => 90) LOOP
          vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
      END LOOP;
      /* Efetuar a chamada a rotina Oracle  */
      EMPR0021.pc_recalcular_renegociacao(pr_cdcooper => rw_crapcop.cdcooper,
                                          pr_nrdconta => rw_principal.nrdconta,
                                          pr_nrctremp => rw_principal.nrctremp,
                                          pr_vldevtot => vr_vlemprst,
                                          pr_vlparemp => vr_vlpreemp,
                                          pr_cdperapr => vr_cdperapr, /* Auxiliar para perda de aprovacao */
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        CONTINUE;
      END IF;
      /* Atualizar na tabela crawepr */
      BEGIN
        UPDATE cecred.crawepr 
           SET vlpreemp = vr_vlpreemp
              ,vlemprst = vr_vlemprst
              ,dtlibera = rw_crapdat.dtmvtolt 
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_principal.nrdconta 
           AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar a crawepr: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      CCET0001.pc_calculo_cet_emprestimos(pr_cdcooper => rw_crapcop.cdcooper,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_nrdconta => rw_principal.nrdconta,
                                          pr_cdprogra => 'ATENDA',
                                          pr_inpessoa => rw_crapass.inpessoa,
                                          pr_cdusolcr => 2,
                                          pr_cdlcremp => rw_principal.cdlcremp,
                                          pr_tpemprst => rw_principal.tpemprst,
                                          pr_nrctremp => rw_principal.nrctremp,
                                          pr_dtlibera => rw_crapdat.dtmvtolt, -- o progress considera que ja esta com a data nova
                                          pr_vlemprst => vr_vlemprst,
                                          pr_txmensal => 0,
                                          pr_vlpreemp => vr_vlpreemp,
                                          pr_qtpreemp => rw_principal.qtpreemp,
                                          pr_dtdpagto => rw_principal.dtdpagto,
                                          pr_cdfinemp => rw_principal.cdfinemp,
                                          pr_dscatbem => vr_dscatbem,
                                          pr_idfiniof => rw_principal.idfiniof,
                                          pr_dsctrliq => rw_principal.dsliquid, -- buscar_liquidacoes_contrato
                                          pr_idgravar => 'N',
                                          pr_dtcarenc => rw_principal.dtcarenc,
                                          pr_vlrdoiof => -1,
                                          pr_txcetano => vr_txcetano,
                                          pr_txcetmes => vr_txcetmes,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      -- Sair em caso de erro 
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      RATI0002.pc_obtem_emprestimo_risco(pr_cdcooper => rw_crapcop.cdcooper,
                                         pr_cdagenci => 1,
                                         pr_nrdcaixa => 1,
                                         pr_cdoperad => 1,
                                         pr_nrdconta => rw_principal.nrdconta,
                                         pr_idseqttl => 1,
                                         pr_idorigem => 5,
                                         pr_nmdatela => 'ATENDA',
                                         pr_flgerlog => 'S',
                                         pr_cdfinemp => rw_principal.cdfinemp,
                                         pr_cdlcremp => rw_principal.cdlcremp,
                                         pr_dsctrliq => rw_principal.dsliquid,
                                         pr_nrctremp => rw_principal.nrctremp,
                                         pr_nivrisco => vr_nivrisco,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
      -- Sair em caso de erro 
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
           
     /* Atualiza os campos da proposta de emprestimo */
     BEGIN
        UPDATE cecred.crawepr 
           SET percetop = vr_txcetano
              ,dsnivris = UPPER(vr_nivrisco)
              ,dsnivori = UPPER(vr_nivrisco)
         WHERE cdcooper = rw_crapcop.cdcooper 
           AND nrdconta = rw_principal.nrdconta 
           AND nrctremp = rw_principal.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar a crawepr: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      -- Validar a perda de aprovacao
      IF vr_cdperapr <> 0 THEN
        BEGIN
          UPDATE cecred.crawepr 
             SET insitapr = 0
                ,cdopeapr = ''
                ,dtaprova = NULL
                ,hraprova = 0
                ,insitest = 0
           WHERE cdcooper = rw_crapcop.cdcooper 
             AND nrdconta = rw_principal.nrdconta 
             AND nrctremp = rw_principal.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar a crawepr: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        LCRE0001.pc_contingencia_taxa(pr_cdcooper     => rw_crapcop.cdcooper,
                                      pr_tpoperac     => 1,
                                      pr_incontgencia => vr_incontgencia,
                                      pr_cdcritic     => vr_cdcritic,
                                      pr_dscritic     => vr_dscritic);
        -- Sair em caso de erro 
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;   
                     
        IF vr_incontgencia = 'S' THEN
          BEGIN
            UPDATE cecred.crawepr 
               SET txmensal = 0
                  ,txdiaria = 0
             WHERE cdcooper = rw_crapcop.cdcooper 
               AND nrdconta = rw_principal.nrdconta 
               AND nrctremp = rw_principal.nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a crawepr: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;              
        END IF;
      END IF;
      --
      OPEN cr_tbepr_renegociacao(pr_cdcooper => rw_principal.cdcooper
                                ,pr_nrdconta => rw_principal.nrdconta
                                ,pr_nrctremp => rw_principal.nrctremp);
      FETCH cr_tbepr_renegociacao INTO rw_tbepr_renegociacao;
      CLOSE cr_tbepr_renegociacao;
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE tbepr_renegociacao SET
                               DTDPAGTO = to_date(''' || rw_tbepr_renegociacao.DTDPAGTO || ''', ''dd-mm-yyyy''), 
                               QTPREEMP = ' || rw_tbepr_renegociacao.QTPREEMP || ', 
                               VLEMPRST = ' || REPLACE(rw_tbepr_renegociacao.VLEMPRST, ',', '.') || ', 
                               VLPREEMP = ' || REPLACE(rw_tbepr_renegociacao.VLPREEMP, ',', '.') || ', 
                               WHERE CDCOOPER = ' || rw_tbepr_renegociacao.CDCOOPER || ' 
                                 AND NRDCONTA = ' || rw_tbepr_renegociacao.NRDCONTA || ' 
                                 AND NRCTREMP = ' || rw_tbepr_renegociacao.NRCTREMP || ';' ||chr(13)||chr(13), FALSE); 
      FOR rw_tbepr_renegociacao_contrato IN cr_tbepr_renegociacao_contrato(pr_cdcooper => rw_principal.cdcooper
                                                                          ,pr_nrdconta => rw_principal.nrdconta
                                                                          ,pr_nrctremp => rw_principal.nrctremp) LOOP
        -- grava rollback proposta
        gene0002.pc_escreve_xml(vr_dados_rollback
                              , vr_texto_rollback
                              ,'UPDATE tbepr_renegociacao_contrato SET
                                VLSDEVED = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLSDEVED, ',', '.') || ',
                                VLNVSDDE = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLNVSDDE, ',', '.') || ', 
                                VLNVPRES = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLNVPRES, ',', '.') || ', 
                                VLPRECAR = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLPRECAR, ',', '.') || ', 
                                VLIOFEPR = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFEPR, ',', '.') || ', 
                                VLTAREPR = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLTAREPR, ',', '.') || ', 
                                VLEMPRST = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLEMPRST, ',', '.') || ',
                                VLFINANC = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLFINANC, ',', '.') || ',
                                VLIOFADC = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFADC, ',', '.') || ', 
                                VLIOFPRI = ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFPRI, ',', '.') || ', 
                                PERCETOP = ' || REPLACE(rw_tbepr_renegociacao_contrato.PERCETOP, ',', '.') || '
                                WHERE CDCOOPER = ' || rw_tbepr_renegociacao_contrato.CDCOOPER || ' 
                                  AND NRDCONTA = ' || rw_tbepr_renegociacao_contrato.NRDCONTA || ' 
                                  AND NRCTREMP = ' || rw_tbepr_renegociacao_contrato.NRCTREMP || ';' ||chr(13)||chr(13), FALSE); 
      END LOOP;
      
      
      
      GENE0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => ''
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => rw_principal.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrctremp'
                                 ,pr_dsdadant => rw_principal.nrctremp
                                 ,pr_dsdadatu => rw_principal.nrctremp);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'vlpreemp'
                               ,pr_dsdadant => to_char(vr_vlpreemp_or,'fm99999g999g990','NLS_NUMERIC_CHARACTERS=,.')
                               ,pr_dsdadatu => to_char(vr_vlpreemp,'fm99999g999g990','NLS_NUMERIC_CHARACTERS=,.'));
      -- salvar por contrato
      COMMIT;
    END LOOP;
  END LOOP;
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT; 
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      ROLLBACK;
      dbms_output.put_line(vr_dscritic);
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line(SQLERRM);
END;
0
0
