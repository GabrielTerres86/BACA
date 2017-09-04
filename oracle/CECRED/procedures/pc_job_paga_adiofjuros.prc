CREATE OR REPLACE PROCEDURE CECRED.pc_job_paga_adiofjuros IS
 /* ..........................................................................

   JOB: PC_JOB_PAGA_ADIOFJUROS
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Tiago Machado Flor - CECRED
   Data    : Março/2017.                     Ultima atualizacao: 02/03/2017

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Efetuar os debitos de agendamentos de AD, IOF e Juros.

   Alteracoes: 03/04/2017 - Alterações implementadas:
                             *retirado conta fixa;
                             *mudado parametro da obtem_saldo_dia de I para A;
                             *adicionado commit na ultima linha do programa;
                             *retirado +1 do nrseqdig antes de inserir a craplcm;
                             (Tiago/Thiago).
                             
               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
          			        crapass, crapttl, crapjur 
					       (Adriano - P339). 
                             
               01/06/2017 - Alterado numero do documento de 999999 para 777777
                            pq o crps008 lançava com o mesmo numero de documento
                            (Tiago/Thiago).
  ..........................................................................*/

BEGIN
  
  DECLARE
    CURSOR cr_crapcop IS
      SELECT * 
        FROM crapcop
       WHERE crapcop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.vllimcre
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.cdcooper
            ,crapass.cdagenci
            ,crapass.nrctacns
            ,crapass.dtdemiss
            ,crapass.idastcjt
      FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
      AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_lautom_ctrl(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT ctrl.*       ,lau.vllanaut
            ,lau.cdagenci ,lau.cdbccxlt
            ,lau.nrdolote ,lau.nrdocmto
            ,lau.dtmvtopg
        FROM tbcc_lautom_controle ctrl, craplau lau
       WHERE ctrl.idlautom = lau.idlancto
         AND ctrl.cdcooper = pr_cdcooper
         AND ctrl.cdhistor IN (323, 38, 37)
         AND ctrl.insit_lancto = 1
         AND lau.insitlau = 1
         AND ctrl.nrdconta = lau.nrdconta
         AND ctrl.cdcooper = lau.cdcooper
       ORDER BY ctrl.dtmvtolt;        
    rw_lautom_ctrl cr_lautom_ctrl%ROWTYPE;                      

    --Buscar informacoes de lote
    CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT  craplot.cdcooper
             ,craplot.dtmvtolt
             ,craplot.nrdolote
             ,craplot.cdagenci
             ,craplot.nrseqdig
             ,craplot.cdbccxlt
             ,craplot.qtcompln
             ,craplot.tplotmov
             ,craplot.cdhistor
             ,craplot.cdoperad
             ,craplot.qtinfoln
             ,craplot.vlcompcr
             ,craplot.vlinfocr
             ,craplot.rowid
      FROM craplot craplot
      WHERE craplot.cdcooper = pr_cdcooper
      AND   craplot.dtmvtolt = pr_dtmvtolt
      AND   craplot.cdagenci = pr_cdagenci
      AND   craplot.cdbccxlt = pr_cdbccxlt
      AND   craplot.nrdolote = pr_nrdolote
      FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;

    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    vr_cdprogra  VARCHAR2(40) := 'PC_JOB_PAGA_ADIOFJUROS';
    vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;

    vr_qtdiacor  INTEGER;   
    vr_vlminchq  NUMBER(25,2);                                            
    vr_vlminiof  NUMBER(25,2);                                 
    vr_vlminadp  NUMBER(25,2);
    
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    
    vr_tab_erro  GENE0001.typ_tab_erro;   --> Tabela com erros
    vr_tab_saldo EXTR0001.typ_tab_saldos; --> Tabela de retorno da rotina
    
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  crapcri.dscritic%TYPE;
    vr_exc_erro  EXCEPTION;
    vr_exc_email EXCEPTION;
       
    -- Procedimento para inserir o lote e não deixar tabela lockada
    PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                              pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                              pr_cdagenci IN craplot.cdagenci%TYPE,
                              pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                              pr_nrdolote IN craplot.nrdolote%TYPE,
                              pr_cdoperad IN craplot.cdoperad%TYPE,
                              pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                              pr_tplotmov IN craplot.tplotmov%TYPE,
                              pr_cdhistor IN craplot.cdhistor%TYPE,
                              pr_craplot  OUT cr_craplot%ROWTYPE,
                              pr_dscritic OUT VARCHAR2)IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- criar rowtype controle
      rw_craplot_ctl cr_craplot%ROWTYPE;

    BEGIN

      /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1..100 LOOP
        BEGIN
          -- Leitura do lote
          OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                           pr_dtmvtolt  => pr_dtmvtolt,
                           pr_cdagenci  => pr_cdagenci,
                           pr_cdbccxlt  => pr_cdbccxlt,
                           pr_nrdolote  => pr_nrdolote);
          FETCH cr_craplot INTO rw_craplot_ctl;
          pr_dscritic := NULL;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
             IF cr_craplot%ISOPEN THEN
               CLOSE cr_craplot;
             END IF;

             -- setar critica caso for o ultimo
             IF i = 100 THEN
               pr_dscritic:= pr_dscritic||'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
             END IF;
             -- aguardar 0,5 seg. antes de tentar novamente
             sys.dbms_lock.sleep(0.1);
        END;
      END LOOP;

      -- se encontrou erro ao buscar lote, abortar programa
      IF pr_dscritic IS NOT NULL THEN
        ROLLBACK;
        RETURN;
      END IF;

      IF cr_craplot%NOTFOUND THEN
        -- criar registros de lote na tabela
        INSERT INTO craplot
                (craplot.cdcooper
                ,craplot.dtmvtolt
                ,craplot.cdagenci
                ,craplot.cdbccxlt
                ,craplot.nrdolote
                ,craplot.nrseqdig
                ,craplot.tplotmov
                ,craplot.cdoperad
                ,craplot.cdhistor
                ,craplot.nrdcaixa
                ,craplot.cdopecxa)
        VALUES  (pr_cdcooper
                ,pr_dtmvtolt
                ,pr_cdagenci
                ,pr_cdbccxlt
                ,pr_nrdolote
                ,1  -- craplot.nrseqdig
                ,pr_tplotmov
                ,pr_cdoperad
                ,pr_cdhistor
                ,pr_nrdcaixa
                ,pr_cdoperad)
           RETURNING  craplot.ROWID
                     ,craplot.nrdolote
                     ,craplot.nrseqdig
                     ,craplot.cdbccxlt
                     ,craplot.tplotmov
                     ,craplot.dtmvtolt
                     ,craplot.cdagenci
                     ,craplot.cdhistor
                     ,craplot.cdoperad
                     ,craplot.qtcompln
                     ,craplot.qtinfoln
                     ,craplot.vlcompcr
                     ,craplot.vlinfocr
                 INTO rw_craplot_ctl.ROWID
                    , rw_craplot_ctl.nrdolote
                    , rw_craplot_ctl.nrseqdig
                    , rw_craplot_ctl.cdbccxlt
                    , rw_craplot_ctl.tplotmov
                    , rw_craplot_ctl.dtmvtolt
                    , rw_craplot_ctl.cdagenci
                    , rw_craplot_ctl.cdhistor
                    , rw_craplot_ctl.cdoperad
                    , rw_craplot_ctl.qtcompln
                    , rw_craplot_ctl.qtinfoln
                    , rw_craplot_ctl.vlcompcr
                    , rw_craplot_ctl.vlinfocr;
      ELSE
        -- ou atualizar o nrseqdig para reservar posição
        UPDATE craplot
           SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
         WHERE craplot.ROWID = rw_craplot_ctl.ROWID
         RETURNING craplot.nrseqdig INTO rw_craplot_ctl.nrseqdig;
      END IF;

      CLOSE cr_craplot;

      -- retornar informações para o programa chamador
      pr_craplot := rw_craplot_ctl;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        ROLLBACK;
        -- se ocorreu algum erro durante a criacao
        pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
    END pc_insere_lote;       

    PROCEDURE pc_paga_adiofjuros(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                ,pr_cdagenci IN craplcm.cdagenci%TYPE
                                ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                                ,pr_nrdolote IN craplcm.nrdolote%TYPE
                                ,pr_nrdconta IN craplcm.nrdconta%TYPE
                                ,pr_cdoperad IN craplcm.cdoperad%TYPE
                                ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                                ,pr_tplotmov IN craplot.tplotmov%TYPE
                                ,pr_cdhistor IN craplot.cdhistor%TYPE
                                ,pr_vllanmto IN craplcm.vllanmto%TYPE
                                ,pr_idlautom IN craplcm.idlautom%TYPE
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    
      vr_qtdlan NUMBER(25);
                                
      CURSOR cr_craplcm(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                       ,pr_cdhistor craphis.cdhistor%TYPE) IS
        SELECT COUNT(*) qtdlan
          FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.cdhistor = pr_cdhistor;
      rw_craplcm cr_craplcm%ROWTYPE;
    BEGIN
      --Qdo é um cursor com COUNT(*) sempre da FOUND
      OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_cdhistor => pr_cdhistor);
      FETCH cr_craplcm INTO rw_craplcm;
      CLOSE cr_craplcm;
      
      vr_qtdlan := 777777 - rw_craplcm.qtdlan;    
      vr_qtdlan := TO_NUMBER(vr_qtdlan||pr_cdhistor);
      
      pc_insere_lote (pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_cdbccxlt => pr_cdbccxlt
                     ,pr_nrdolote => pr_nrdolote
                     ,pr_cdoperad => pr_cdoperad
                     ,pr_nrdcaixa => pr_nrdcaixa
                     ,pr_tplotmov => pr_tplotmov
                     ,pr_cdhistor => pr_cdhistor
                     ,pr_craplot  => rw_craplot    --OUT
                     ,pr_dscritic => vr_dscritic); --OUT
                     
      IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic:= 0;
          --Levantar Excecao
         RAISE vr_exc_erro;
      END IF;

      /* Cria o lancamento do DEBITO */
      BEGIN
        INSERT INTO craplcm (cdcooper
                            ,dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,nrdconta
                            ,nrdctabb
                            ,nrdctitg
                            ,nrdocmto
                            ,cdhistor
                            ,nrseqdig
                            ,vllanmto                          
                            ,cdcoptfn
                            ,idlautom)
               VALUES  (pr_cdcooper  
                       ,rw_craplot.dtmvtolt
                       ,rw_craplot.cdagenci
                       ,rw_craplot.cdbccxlt
                       ,rw_craplot.nrdolote
                       ,pr_nrdconta
                       ,pr_nrdconta
                       ,GENE0002.FN_MASK(pr_nrdconta, '99999999')
                       ,vr_qtdlan
                       ,pr_cdhistor
                       ,rw_craplot.nrseqdig
                       ,pr_vllanmto                     
                       ,0
                       ,pr_idlautom);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- se ocorreu algum erro durante a criacao
        pr_dscritic := 'Erro na pc_paga_adiofjuros '||SQLERRM; 
    END pc_paga_adiofjuros;       
    
    PROCEDURE pc_atu_sit_controle(pr_idlautom     IN craplau.idlancto%TYPE
                                 ,pr_insit_lancto IN tbcc_lautom_controle.insit_lancto%TYPE
                                 ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS
    BEGIN
      UPDATE  tbcc_lautom_controle 
         SET  tbcc_lautom_controle.insit_lancto = pr_insit_lancto
        WHERE tbcc_lautom_controle.idlautom = pr_idlautom;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Nao foi possivel atualizar a tabela tbcc_lautom_controle(idlautom: '||pr_idlautom||')';        
    END pc_atu_sit_controle;
    
    PROCEDURE pc_atualiza_lautom(pr_idlautom IN craplau.idlancto%TYPE
                                ,pr_insitlau IN craplau.insitlau%TYPE
                                ,pr_dtdebito IN craplau.dtdebito%TYPE DEFAULT SYSDATE
                                ,pr_vllanaut IN craplau.vllanaut%TYPE DEFAULT 0
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                               
    BEGIN
      IF pr_insitlau = 2 THEN
         BEGIN
           UPDATE craplau 
              SET craplau.insitlau = pr_insitlau
                 ,craplau.dtdebito = pr_dtdebito
            WHERE craplau.idlancto = pr_idlautom;
         EXCEPTION
           WHEN OTHERS THEN
             pr_dscritic := 'Nao foi possivel atualizar craplau.';
         END;      
      ELSE
         IF pr_insitlau = 1 THEN
            BEGIN
              UPDATE craplau
                 SET craplau.vllanaut = pr_vllanaut
               WHERE craplau.idlancto = pr_idlautom;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Nao foi possivel atualizar craplau.';
            END;
         END IF;
      END IF;        
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Nao foi possivel atualizar craplau.';
    END pc_atualiza_lautom;
  
  --#################INICIO PROGRAMA###################### 
  BEGIN

    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)

    gene0004.pc_executa_job(pr_cdcooper => 3
                           ,pr_fldiautl => 1
                           ,pr_flproces => 1
                           ,pr_flrepjob => 1
                           ,pr_flgerlog => 0
                           ,pr_nmprogra => vr_cdprogra
                           ,pr_dscritic => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_email;
    END IF;        

    OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
       CLOSE BTCH0001.cr_crapdat;
       vr_cdcritic := 0;
       vr_dscritic := 'CRAPDAT nao encontrada.';
       RAISE vr_exc_erro;
    END IF;            

    CLOSE BTCH0001.cr_crapdat;

    FOR rw_crapcop IN cr_crapcop LOOP
      
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
         CLOSE BTCH0001.cr_crapdat;
         vr_cdcritic := 0;
         vr_dscritic := 'CRAPDAT nao encontrada.';
         RAISE vr_exc_erro;
      END IF;            
        
      CLOSE BTCH0001.cr_crapdat;
      
      -- Buscar dias corridos para a cobrança de juros
      vr_qtdiacor:= TO_NUMBER(gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                        pr_cdcooper => rw_crapcop.cdcooper,
                                                        pr_cdacesso => 'PARLIM_QTDIACOR'));
      vr_qtdiacor:= NVL(vr_qtdiacor,0);

      -- Valor minimo para cobrança de cheque especial                                      
      vr_vlminchq:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_cdacesso => 'PARLIM_VLMINCHQ');
      vr_vlminchq:= NVL(vr_vlminchq,0);
                                                  
      -- Valor minimo para cobrança de IOF
      vr_vlminiof:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_cdacesso => 'PARLIM_VLMINIOF');
      vr_vlminiof:= NVL(vr_vlminiof,0);
                                                  
      -- Valor minimo para cobrança de juros de adiantamento a depositante
      vr_vlminadp:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_cdacesso => 'PARLIM_VLMINADP');
      vr_vlminadp:= NVL(vr_vlminadp,0);
      
      FOR rw_lautom_ctrl IN cr_lautom_ctrl(pr_cdcooper => rw_crapcop.cdcooper) LOOP
                                  
        /*Busca associado*/  
        OPEN cr_crapass(pr_cdcooper => rw_lautom_ctrl.cdcooper
                       ,pr_nrdconta => rw_lautom_ctrl.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        
        IF cr_crapass%NOTFOUND THEN
           CLOSE cr_crapass;                    

           vr_dscritic := 'Numero de conta nao encontrado, Coop:'||rw_lautom_ctrl.cdcooper||' Conta:'||rw_lautom_ctrl.nrdconta;
           pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                          ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                          ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           -- Parametros para Ocorrencia
                          ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                          ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                          ,pr_dsmensagem    => vr_dscritic   --> dscritic       
                          ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                          ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
           
           CONTINUE;        
        END IF;            
        
        CLOSE cr_crapass;   
                                
        /** Verifica se possui saldo para fazer a operacao **/
        EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => rw_crapcop.cdcooper
                                    ,pr_rw_crapdat => rw_crapdat
                                    ,pr_cdagenci   => rw_crapass.cdagenci
                                    ,pr_nrdcaixa   => 100
                                    ,pr_cdoperad   => 1
                                    ,pr_nrdconta   => rw_lautom_ctrl.nrdconta
                                    ,pr_vllimcre   => rw_crapass.vllimcre
                                    ,pr_tipo_busca => 'A' --> tipo de busca(I-dtmvtolt)
                                    ,pr_flgcrass   => FALSE
                                    ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                    ,pr_des_reto   => vr_dscritic
                                    ,pr_tab_sald   => vr_tab_saldo
                                    ,pr_tab_erro   => vr_tab_erro);
        --Se ocorreu erro
        IF vr_dscritic = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_lautom_ctrl.nrdconta;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_lautom_ctrl.nrdconta;
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;       
        END IF;
        
        --Verificar o saldo retornado
        IF vr_tab_saldo.Count = 0 THEN
           --Montar mensagem erro
           vr_cdcritic:= 0;
           vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
           --Levantar Excecao
           RAISE vr_exc_erro;
        ELSE
          --Se tiver saldo suficiente, pago a divida
          IF (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
              nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) >= rw_lautom_ctrl.vllanaut THEN

             pc_paga_adiofjuros(pr_cdcooper => rw_lautom_ctrl.cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => rw_lautom_ctrl.cdagenci
                               ,pr_cdbccxlt => rw_lautom_ctrl.cdbccxlt
                               ,pr_nrdolote => rw_lautom_ctrl.nrdolote
                               ,pr_nrdconta => rw_lautom_ctrl.nrdconta
                               ,pr_cdoperad => 1
                               ,pr_nrdcaixa => 100
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => rw_lautom_ctrl.cdhistor
                               ,pr_vllanmto => rw_lautom_ctrl.vllanaut
                               ,pr_idlautom => rw_lautom_ctrl.idlautom
                               ,pr_dscritic => vr_dscritic);
             
             IF TRIM(vr_dscritic) IS NOT NULL THEN                
                vr_cdcritic:= 0;
                RAISE vr_exc_erro;
             END IF;
             
             pc_atualiza_lautom(pr_idlautom => rw_lautom_ctrl.idlautom
                               ,pr_insitlau => 2 --PAGO
                               ,pr_dtdebito => rw_crapdat.dtmvtolt
                               ,pr_dscritic => vr_dscritic);
                               
             IF TRIM(vr_dscritic) IS NOT NULL THEN                
                vr_cdcritic:= 0;
                RAISE vr_exc_erro;
             END IF;
                              
             pc_atu_sit_controle(pr_idlautom     => rw_lautom_ctrl.idlautom
                                ,pr_insit_lancto => 2 --PAGO
                                ,pr_dscritic     => vr_dscritic);
                                
             IF TRIM(vr_dscritic) IS NOT NULL THEN   
                vr_cdcritic:= 0;             
                RAISE vr_exc_erro;
             END IF;
                                
          ELSE

             --Se o saldo nao for suficiente e nao deve estourar a conta
             --verifico se consigo pagar parcial
             
             --Primeiro verifico se tenho ao menos o valor minimo de pagamento
             
             --IOF S/EMPR.CC
             IF rw_lautom_ctrl.cdhistor = 323 THEN
               -- Valor minimo para cobrança de IOF
               IF vr_vlminiof > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                 nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
                  CONTINUE;                            
               END IF;             
             END IF;
        
             --JUROS LIM.CRD
             IF rw_lautom_ctrl.cdhistor = 38 THEN             
               -- Valor minimo para cobrança de cheque especial                                      
               IF vr_vlminchq > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                 nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
                  CONTINUE;               
               END IF;                          
             END IF;
             
             --TAXA C/C NEG.
             IF rw_lautom_ctrl.cdhistor = 37 THEN
               -- Valor minimo para cobrança de juros de adiantamento a depositante
               IF vr_vlminadp > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                 nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
                  CONTINUE;               
               END IF;                          
             END IF;
             
             pc_paga_adiofjuros(pr_cdcooper => rw_lautom_ctrl.cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => rw_lautom_ctrl.cdagenci
                               ,pr_cdbccxlt => rw_lautom_ctrl.cdbccxlt
                               ,pr_nrdolote => rw_lautom_ctrl.nrdolote
                               ,pr_nrdconta => rw_lautom_ctrl.nrdconta
                               ,pr_cdoperad => 1
                               ,pr_nrdcaixa => 100
                               ,pr_tplotmov => 1
                               ,pr_cdhistor => rw_lautom_ctrl.cdhistor
                               ,pr_vllanmto => (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                                nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0))
                               ,pr_idlautom => rw_lautom_ctrl.idlautom
                               ,pr_dscritic => vr_dscritic);
                               
             IF TRIM(vr_dscritic) IS NOT NULL THEN 
                vr_cdcritic:= 0;               
                RAISE vr_exc_erro;
             END IF;
             
             pc_atualiza_lautom(pr_idlautom => rw_lautom_ctrl.idlautom
                               ,pr_insitlau => 1 --PENDENTE
                               ,pr_vllanaut => rw_lautom_ctrl.vllanaut - (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                                                          nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0))
                               ,pr_dscritic => vr_dscritic);

             IF TRIM(vr_dscritic) IS NOT NULL THEN                
                vr_cdcritic:= 0;
                RAISE vr_exc_erro;
             END IF;
               
          END IF;                          
        END IF;                                 
                                  
      END LOOP;  
    
    END LOOP;
    
    pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                    
    
    COMMIT;                 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      
      pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                     ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                     ,pr_dsmensagem    => vr_dscritic   --> dscritic       
                     ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                     ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

      pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                    
      
    WHEN vr_exc_email THEN
      -- Efetuar rollback
      ROLLBACK;

      pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                     ,pr_cdcriticidade => 1             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                     ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                     ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                     ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

      pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                     ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      -- Parametros para Ocorrencia
                     ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                    
      
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',3 ,'ERRO_EMAIL_JOB');
      
      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO JOB: '|| 'JBCC_PAGA_ADIOFJUROS' ||
                     '<br>Cooperativa: '     || to_char(3, '990')||                      
                     '<br>Critica: '         || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => 3
                                ,pr_cdprogra        => 'PC_JOB_AGENDEB'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| 'JBCC_PAGA_ADIOFJUROS'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                              
      
    WHEN OTHERS THEN
        ROLLBACK;
        
        pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                       ,pr_cdcriticidade => 3             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                       ,pr_dsmensagem    => vr_dscritic||' '||Sqlerrm   --> dscritic       
                       ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                       ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                       ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                       ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        -- Parametros para Ocorrencia
                       ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                    
      
        -- buscar destinatarios do email                           
        vr_email_dest := gene0001.fn_param_sistema('CRED',3 ,'ERRO_EMAIL_JOB');
        
        -- Gravar conteudo do email, controle com substr para não estourar campo texto
        vr_conteudo := substr('ERRO NA EXECUCAO JOB: '|| 'JBCC_PAGA_ADIOFJUROS' ||
                       '<br>Cooperativa: '     || to_char(3, '990')||                      
                       '<br>Critica: '         || vr_dscritic,1,4000);
                        
        vr_dscritic := NULL;
        --/* Envia e-mail para o Operador */
        gene0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => 'PC_JOB_AGENDEB'
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| 'JBCC_PAGA_ADIOFJUROS'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
        COMMIT;                              
  END;
  
END pc_job_paga_adiofjuros;
/
