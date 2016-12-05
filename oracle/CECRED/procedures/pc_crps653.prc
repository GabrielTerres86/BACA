CREATE OR REPLACE PROCEDURE CECRED.pc_crps653(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                             ,pr_flgresta IN PLS_INTEGER --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
  /* ..........................................................................

   Programa: Fontes/crps653.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo      
   Data    : Julho/13.                           Ultima atualizacao: 11/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 082.
               Efetuar os lancamentos pendentes de Bloqueio Judicial.

   Alteracoes: 18/11/2015 - Ajustado para que seja utilizado o obtem-saldo-dia
                            convertido em Oracle. (Douglas - Chamado 285228)

               11/11/2016 - Conversao Progress >> PLSQL. (Jaison/Daniel)

  ............................................................................. */

BEGIN

  DECLARE

    -- Variaveis de criticas
    vr_cdcritic INTEGER;
    vr_cdprogra VARCHAR2(10);
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de excecao
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
  
    -- Cadastro da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Cadastro do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT crapass.cdcooper
            ,crapass.nrdconta
            ,crapass.dtelimin
            ,crapass.cdsitdtl
            ,crapass.nrcpfcgc
            ,crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = DECODE(pr_nrdconta, 0, crapass.nrdconta, pr_nrdconta)
         AND crapass.nrcpfcgc = DECODE(pr_nrcpfcgc, 0, crapass.nrcpfcgc, pr_nrcpfcgc);
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca possiveis transferencias e duplicacoes de matricula
    CURSOR cr_craptrf(pr_cdcooper IN craptrf.cdcooper%TYPE
                     ,pr_nrdconta IN craptrf.nrdconta%TYPE) IS
      SELECT craptrf.nrsconta
        FROM craptrf
       WHERE craptrf.cdcooper = pr_cdcooper
         AND craptrf.nrdconta = pr_nrdconta
         AND craptrf.tptransa = 1  -- Transferencia
         AND craptrf.insittrs = 2; -- Feito
    rw_craptrf cr_craptrf%ROWTYPE;

    -- Listagem de lancamentos automaticos
    CURSOR cr_craplau(pr_cdcooper IN craplau.cdcooper%TYPE
                     ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
      SELECT 
             craplau.cdcooper
            ,craplau.nrdconta
            ,craplau.vllanaut
            ,craplau.nrdocmto
            ,craplau.nrdctabb
            ,craplau.cdhistor
            ,craplau.dtmvtolt
            ,craplau.cdbccxlt
            ,craplau.nrdolote
            ,craplau.nrseqdig
            ,craplau.cdseqtel
            ,craplau.ROWID
        FROM craplau
       WHERE craplau.cdcooper  = pr_cdcooper
         AND craplau.dtmvtopg <= pr_dtmvtopg
         AND craplau.insitlau  = 1
         AND UPPER(craplau.dsorigem) = 'BLOQJUD';

    -- Listagem de lancamentos automaticos
    CURSOR cr_crablau(pr_cdcooper IN craplau.cdcooper%TYPE
                     ,pr_nrdconta IN craplau.nrdconta%TYPE
                     ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
      SELECT craplau.cdseqtel
            ,craplau.ROWID
        FROM craplau
       WHERE craplau.cdcooper  = pr_cdcooper
         AND craplau.nrdconta  = pr_nrdconta
         AND craplau.dtmvtopg <= pr_dtmvtopg
         AND craplau.insitlau  = 1
         AND UPPER(craplau.dsorigem) = 'BLOQJUD';

    -- Selecionar lancamentos
    CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplcm.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplcm.nrdolote%TYPE
                     ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                     ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
      SELECT craplcm.nrseqdig
            ,craplcm.nrdolote
            ,craplcm.vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdagenci = pr_cdagenci
         AND craplcm.cdbccxlt = pr_cdbccxlt
         AND craplcm.nrdolote = pr_nrdolote
         AND craplcm.nrdctabb = pr_nrdctabb
         AND craplcm.nrdocmto = pr_nrdocmto;
    rw_craplcm cr_craplcm%ROWTYPE;
  
    -- Tipo de dado para receber as datas da tabela crapdat
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Tipo de dado para receber os dados da tabela craplot
    rw_craplot LOTE0001.cr_craplot%ROWTYPE;

    -- Variaveis Gerais
    vr_blnfound   BOOLEAN;
    vr_index      PLS_INTEGER;
    vr_nrdconta   craplau.nrdconta%TYPE;
    vr_qtcompln   INTEGER := 0;
    vr_qtinfoln   INTEGER := 0;
    vr_vltotlan   NUMBER := 0;
    vr_vllanaut   NUMBER;
    vr_cddebtot   INTEGER;
    vr_des_reto   VARCHAR2(3);
    vr_tab_erro   GENE0001.typ_tab_erro;
    vr_tab_saldos EXTR0001.typ_tab_saldos;
    vr_nrdocmto   craplau.nrdocmto%TYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    PROCEDURE pc_baixa_craplau_blqjud(pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                     ,pr_dtmvtolt IN craplau.dtmvtopg%TYPE
                                     ,pr_cdseqtel IN craplau.cdseqtel%TYPE
                                     ,pr_vllanaut IN craplau.vllanaut%TYPE
                                     ,pr_cddebtot IN INTEGER) IS
    BEGIN
      -- Listagem dos lancamentos automaticos
      FOR rw_crabass IN cr_crapass(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => 0
                                  ,pr_nrcpfcgc => pr_nrcpfcgc) LOOP
        IF rw_crabass.nrdconta = pr_nrdconta THEN
          CONTINUE;
        END IF;
        
        -- Listagem dos lancamentos automaticos
        FOR rw_crablau IN cr_crablau(pr_cdcooper => rw_crabass.cdcooper
                                    ,pr_nrdconta => rw_crabass.nrdconta
                                    ,pr_dtmvtopg => pr_dtmvtolt) LOOP
          IF rw_crablau.cdseqtel = pr_cdseqtel THEN
            -- Debito Total
            IF pr_cddebtot = 1 THEN
              BEGIN
                UPDATE craplau
                   SET craplau.insitlau = 3 -- Cancelado
                      ,craplau.dtdebito = pr_dtmvtolt
                 WHERE craplau.ROWID    = rw_crablau.ROWID;
              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar CRAPLAU: ' || SQLERRM;
                RAISE vr_exc_saida;
              END;
            END IF;

            -- Debito Parcial
            IF pr_cddebtot = 2 THEN
              BEGIN
                UPDATE craplau
                   SET craplau.vllanaut = craplau.vllanaut - pr_vllanaut
                 WHERE craplau.ROWID    = rw_crablau.ROWID;
              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar CRAPLAU: ' || SQLERRM;
                RAISE vr_exc_saida;
              END;
            END IF;

          END IF; -- rw_crablau.cdseqtel

        END LOOP; -- rw_crablau

      END LOOP; -- rw_crabass

    END pc_baixa_craplau_blqjud;

  BEGIN
  
    ----------------------
    -- Validações iniciais
    ----------------------
  
    vr_cdprogra := 'CRPS653';
  
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);
  
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
  
    -- Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
  
    -------------------
    -- Rotina Principal
    -------------------
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
  
    -- Busca a data Atual
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
  
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Listagem dos lancamentos automaticos
    FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtopg => rw_crapdat.dtmvtolt) LOOP
      vr_cdcritic := 0;
      vr_vllanaut := 0;
      vr_cddebtot := 0;
      vr_nrdconta := rw_craplau.nrdconta;

      -- Efetua a busca do registro
      OPEN cr_crapass(pr_cdcooper => rw_craplau.cdcooper
                     ,pr_nrdconta => rw_craplau.nrdconta
                     ,pr_nrcpfcgc => 0);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapass%FOUND;
      -- Fecha cursor
      CLOSE cr_crapass;

      -- Se NAO achou faz raise
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
      -- Se existir data de eliminacao
      ELSIF rw_crapass.dtelimin IS NOT NULL THEN
        vr_cdcritic := 410;
      -- Se a situacao estiver entre...
      ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
        vr_cdcritic := 695;
      -- Se a situacao estiver entre...
      ELSIF rw_crapass.cdsitdtl IN (2,4) THEN

        -- Efetua a busca do registro
        OPEN cr_craptrf(pr_cdcooper => rw_crapass.cdcooper
                       ,pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_craptrf INTO rw_craptrf;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_craptrf%FOUND;
        -- Fecha cursor
        CLOSE cr_craptrf;
        -- Se NAO achou faz raise
        IF NOT vr_blnfound THEN
          vr_cdcritic := 95;
        ELSE
          vr_nrdconta := rw_craptrf.nrsconta;
        END IF;

      END IF;

      -- Se NAO possui critica
      IF NVL(vr_cdcritic,0) = 0 THEN

        -- Saldo da conta
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => 0,
                                    pr_nrdcaixa   => 0,
                                    pr_cdoperad   => '1',
                                    pr_nrdconta   => vr_nrdconta,
                                    pr_vllimcre   => rw_crapass.vllimcre,
                                    pr_flgcrass   => FALSE, -- Nao deve carregar todas as contas em memoria, apenas a conta em questao
                                    pr_tipo_busca => 'A', -- Carregar do dia anterior: (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1)
                                    pr_dtrefere   => rw_crapdat.dtmvtolt,
                                    pr_des_reto   => vr_des_reto,
                                    pr_tab_sald   => vr_tab_saldos,
                                    pr_tab_erro   => vr_tab_erro);

         -- Verifica se deu erro
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := 'Nao foi possivel carregar os saldos.';
          END IF;
          RAISE vr_exc_saida;
        ELSE
           vr_index := vr_tab_saldos.FIRST;
           -- Se retornou registro
           IF vr_index IS NOT NULL THEN
             -- Se saldo for maior ou igual ao valor
             IF vr_tab_saldos(vr_index).vlsddisp >= rw_craplau.vllanaut THEN
               vr_vllanaut := rw_craplau.vllanaut;
               vr_cddebtot := 1; -- Debito Total
             -- Se possui saldo
             ELSIF vr_tab_saldos(vr_index).vlsddisp > 0 THEN
               vr_vllanaut := vr_tab_saldos(vr_index).vlsddisp;
               vr_cddebtot := 2; -- Debito Parcial
             END IF;
           ELSE
             vr_cdcritic := 10;
           END IF;
        END IF;
      END IF;

      -- Se NAO possui critica
      IF NVL(vr_cdcritic,0) = 0 THEN

        -- Seta os valores
        vr_qtcompln := vr_qtcompln + 1;
        vr_qtinfoln := vr_qtinfoln + 1;
        vr_vltotlan := vr_vltotlan + vr_vllanaut;

        -- Procedimento para inserir o lote e nao deixar tabela lockada
        LOTE0001.pc_insere_lote(pr_cdcooper => rw_craplau.cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdolote => 6875
                               ,pr_cdoperad => '1'
                               ,pr_nrdcaixa => 0
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => rw_craplau.cdhistor
                               ,pr_craplot  => rw_craplot
                               ,pr_dscritic => vr_dscritic);
        -- Se ocorreu erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Numero do documento
        vr_nrdocmto := rw_craplau.nrdocmto;

        LOOP
          -- verificar existencia de lançamento
          OPEN cr_craplcm(pr_cdcooper => rw_craplau.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => rw_craplot.cdagenci
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                         ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdctabb => vr_nrdconta
                         ,pr_nrdocmto => vr_nrdocmto);
          FETCH cr_craplcm INTO rw_craplcm;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craplcm%FOUND;
          -- Fecha cursor
          CLOSE cr_craplcm;
          -- Se NAO achou sai do loop, caso contrario incrementa
          IF NOT vr_blnfound THEN
            EXIT;
          ELSE
            vr_nrdocmto := vr_nrdocmto + 100000000;
            CONTINUE;
          END IF;
        END LOOP;

        -- Cria registro na tabela de lancamentos
        BEGIN
          INSERT INTO craplcm
            (cdcooper
            ,dtmvtolt
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
            ,nrdctabb
            ,nrdocmto
            ,vllanmto
            ,nrdconta
            ,cdhistor
            ,nrseqdig
            ,nrdctitg
            ,cdpesqbb)
          VALUES
            (rw_craplau.cdcooper
            ,rw_craplot.dtmvtolt
            ,rw_craplot.cdagenci
            ,rw_craplot.cdbccxlt
            ,rw_craplot.nrdolote
            ,rw_craplau.nrdctabb
            ,vr_nrdocmto
            ,vr_vllanaut
            ,vr_nrdconta
            ,rw_craplau.cdhistor
            ,rw_craplot.nrseqdig
            ,rw_craplau.nrdctabb
            ,'Lote ' || TO_CHAR(rw_craplau.dtmvtolt, 'dd')              || '/' ||
                        TO_CHAR(rw_craplau.dtmvtolt, 'mm')              || '-' ||
                        GENE0002.fn_mask(rw_craplot.cdagenci, '999')            || '-' ||
                        GENE0002.fn_mask(rw_craplau.cdbccxlt, '999')    || '-' ||
                        GENE0002.fn_mask(rw_craplau.nrdolote, '999999') || '-' ||
                        GENE0002.fn_mask(rw_craplau.nrseqdig, '99999')  || '-' ||
                        rw_craplau.nrdocmto)
          RETURNING craplcm.nrseqdig
                   ,craplcm.nrdolote
                   ,craplcm.vllanmto
               INTO rw_craplcm.nrseqdig
                   ,rw_craplcm.nrdolote
                   ,rw_craplcm.vllanmto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir CRAPLCM: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Debito Total
        IF vr_cddebtot = 1 THEN
          BEGIN
            UPDATE craplau
               SET craplau.insitlau = 2 -- Efetivado
                  ,craplau.nrcrcard = rw_craplcm.nrdolote
                  ,craplau.nrseqlan = rw_craplcm.nrseqdig
                  ,craplau.dtdebito = rw_crapdat.dtmvtolt
             WHERE craplau.ROWID    = rw_craplau.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar CRAPLAU: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
        END IF;

        -- Debito Parcial
        IF vr_cddebtot = 2 THEN
          BEGIN
            UPDATE craplau
               SET craplau.vllanaut = craplau.vllanaut - vr_vllanaut
             WHERE craplau.ROWID    = rw_craplau.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar CRAPLAU: ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
        END IF;

        -- Atualiza o saldo
        BEGIN
          UPDATE crapsld
             SET vlblqjud = vlblqjud + rw_craplcm.vllanmto
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = vr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar CRAPSLD: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

        -- Efetua a baixa das contas relacionadas ao CPF/CNPJ
        pc_baixa_craplau_blqjud(pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdseqtel => rw_craplau.cdseqtel
                               ,pr_vllanaut => vr_vllanaut
                               ,pr_cddebtot => vr_cddebtot);

      -- Caso contrario possui critica
      ELSE

        BEGIN
          UPDATE craplau
             SET craplau.insitlau = 3 -- Cancelado
                ,craplau.dtdebito = rw_crapdat.dtmvtolt
                ,craplau.cdcritic = vr_cdcritic
           WHERE craplau.ROWID    = rw_craplau.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar CRAPLAU: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      END IF; -- vr_cdcritic
      
    END LOOP; -- cr_craplau

    -- Atualiza a capa do lote
    BEGIN
      UPDATE craplot
         SET qtcompln = qtcompln + vr_qtcompln
            ,vlcompdb = vlcompdb + vr_vltotlan
            ,qtinfoln = qtinfoln + vr_qtinfoln
            ,vlinfodb = vlinfodb + vr_vltotlan
            ,cdbccxpg = 11
       WHERE ROWID    = rw_craplot.ROWID;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar CRAPLOT: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure PC_CRPS653. ' || SQLERRM;
      ROLLBACK;

  END;

END;
/
