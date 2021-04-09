declare
  --
  vr_nrregistro number := 0;
  vr_nrctrl_atualizados number := 0;
  vr_existe_ass number;
  vr_existe_lim number;
  vr_nrdrowid   rowid;
  vr_dsmensagem varchar2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_des_erro VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_handle utl_file.file_type;
  vr_handle_log utl_file.file_type;
  vr_exc_erro EXCEPTION;

  vr_dsdireto  varchar2(150);
  vr_insitlim NUMBER(5);
  vr_cddlinha_contrato NUMBER(10);
  vr_tpctrllim NUMBER(2);
  vr_descTpLim VARCHAR2(50);
  ----
  --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
  vr_cdcritic crapcri.cdcritic%TYPE;    

  
  -- Local variables here
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem =5--aimaro
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

    -- -- -- -- -- -- -- -- -- -- 
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- -- -- -- -- -- -- -- -- --
  BEGIN

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    vr_retorno     BOOLEAN DEFAULT(FALSE);
    vr_xml      xmltype;
  
    vr_nrdrowid   rowid;
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
    vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;

    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato

      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,
          ---        
             craplim.tprenova,
             craplim.dsnrenov,
             craplim.dtfimvig dtfimvig_rollback,
             craplim.cdoperad ,
             craplim.cdopelib 
                          
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1
         AND craplim.insitlim = 2;-- ativa.
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor Linhas de Credito Rotativo
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.flgstlcr
        FROM craplrt
       WHERE craplrt.cdcooper = pr_cdcooper AND
             craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper AND
             craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
             AND craprli.tplimite = 1; -- Limite Credito
    rw_craprli cr_craprli%ROWTYPE;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapalt.dsaltera,
             crapalt.rowid,
             crapalt.cdoperad,
             crapalt.flgctitg
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.dtaltera = pr_dtmvtolt;
    rw_crapalt cr_crapalt%ROWTYPE;

   -- limite credito
    CURSOR cr_tbrisco_operacoes(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato
    SELECT 1 FROM tbrisco_operacoes o
                 WHERE o.cdcooper = pr_cdcooper
                   AND o.nrdconta = pr_nrdconta
                   AND o.nrctremp = pr_nrctrlim
                   AND o.tpctrato = 1
                   AND o.flintegrar_sas = 1;--- já marcado para atualizar
    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

    vr_in_risco_rat INTEGER;
    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    -- P450 Valida Endividamento
    vr_strating     NUMBER;
    vr_flgrating    NUMBER;
    vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056

    vr_innivris     NUMBER;


  BEGIN

    --> Buscar Parametro
    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;
    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado nao possui proposta de limite de credito Ativa. ';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;
    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de credito deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Contrato nao esta vencido.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o limite de credito
    OPEN cr_craplrt(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    -- Verifica se o limite de credito existe
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim.cddlinha;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplrt;
    END IF;


  --- Não validar
 /*   -- Verifica a situacao do limite do credito
    IF nvl(rw_craplrt.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Linha de credito bloqueada. Nao e possivel efetuar a renovacao. E necessario incluir um novo limite. ' || rw_craplim.cddlinha;
      RAISE vr_exc_saida;
    END IF;*/


    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras do Linha de Credito nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;

/* Não validar
    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;
*/

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN

      -- Verifica processamento do Rating Renovacao
      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        -- Validar Status rating
        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 1 -- Limite Credito
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          
           IF substr(vr_dscritic,1,47) = 'Contrato nao pode ser efetivado, Rating vencido' THEN

              -- verificar se já está marcado para atualizar o rating a noite via lote, se já está não precisa fazer novamente.
              OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctrlim => pr_nrctrlim);
              FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
              IF cr_tbrisco_operacoes%NOTFOUND THEN

                BEGIN 
                  UPDATE tbrisco_operacoes o
                     SET o.flintegrar_sas = 1
                   WHERE o.cdcooper = pr_cdcooper
                     AND o.nrdconta = pr_nrdconta
                     AND o.nrctremp = pr_nrctrlim
                     AND o.tpctrato = 1;
                EXCEPTION
                  WHEN OTHERS THEN
                  vr_dscritic := 'Erro atualizar tabela tbrisco_operacoes, para rating vencido '||SQLERRM;
                  RAISE vr_exc_saida;
                END;         
  --tbrating_historicos
                vr_retorno := rati0003.fn_registra_historico(pr_cdcooper             => pr_cdcooper
                                                            ,pr_cdoperad             => pr_cdoperad
                                                            ,pr_nrdconta             => pr_nrdconta
                                                            ,pr_nrctro               => pr_nrctrlim
                                                            ,pr_dtmvtolt             => NULL
                                                            ,pr_valor                => 0
                                                            ,pr_tpctrato             => 1
                                                            ,pr_rating_sugerido      => NULL
                                                            ,pr_justificativa        => 'Renovacao Limite de credito em massa'
                                                            ,pr_inrisco_rating       => NULL
                                                            ,pr_dtrisco_rating       => NULL
                                                            ,pr_inrisco_rating_autom => NULL
                                                            ,pr_dtrisco_rating_autom => NULL
                                                            ,pr_insituacao_rating    => NULL
                                                            ,pr_inorigem_rating      => NULL
                                                            ,pr_cdoperad_rating      => pr_cdoperad
                                                            ,pr_tpoperacao_rating    => NULL
                                                         --   ,pr_retxml               => vr_xml
                                                            ,pr_cdcritic             => vr_cdcritic
                                                            ,pr_dscritic             => vr_dscritic);
                IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
                
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                              ,pr_des_text => 'UPDATE tbrisco_operacoes SET '
                                                                  ||' flintegrar_sas = 0 '
                                                            ||' WHERE cdcooper = '||pr_cdcooper
                                                            ||'   AND nrdconta = '||pr_nrdconta
                                                             ||'  AND nrctremp = '||pr_nrctrlim
                                                             ||'  AND tpctrato = 1;' -- Limite Credito        
                                                          );        
   
  
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                         ,pr_des_text => 'delete tbrating_historicos '
                       ||' WHERE cdcooper = '||pr_cdcooper           
                       ||' and nrdconta = '||pr_nrdconta                                 
                       ||'  AND nrctremp = '||pr_nrctrlim                                 
                       ||' AND tpctrato = 1 '                                 
                       ||' and ds_justificativa = '||''''||'Renovacao Limite de credito em massa1'||''''                                 
                       ||';'                                 
                      );                                  
              END IF;                                                  
                                   
           ELSE
             RAISE vr_exc_saida;
           END IF;  
        ELSE

          -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
          RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_vlendivi => vr_vlendivid
                                         ,pr_vlrating => vr_vllimrating
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Status do rating inválido
          IF vr_flgrating = 0 THEN
            vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
            RAISE vr_exc_saida;

          ELSE -- Status do rating válido

            -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
            IF ((vr_vlendivid) > vr_vllimrating) THEN

              -- Gravar o Rating da operação, efetivando-o
              rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                               ,pr_nrdconta          => pr_nrdconta
                                               ,pr_tpctrato          => 1 -- Limite Credito
                                               ,pr_nrctrato          => pr_nrctrlim
                                               ,pr_dtrating          => pr_dtmvtolt
                                               ,pr_strating          => 4
                                               ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                               --Variáveis para gravar o histórico
                                               ,pr_cdoperad          => pr_cdoperad
                                               ,pr_dtmvtolt          => pr_dtmvtolt
                                               ,pr_valor             => rw_craplim.vllimite
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => 'Renovação de Contrato - Efetivação do Rating [LIMI0001.pc_renovar_limite_cred_manual]'
                                               ,pr_tpoperacao_rating => 2
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                               --Variáveis de crítica
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              rati0005.pc_altera_flag_alterar(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrato => pr_nrctrlim
                                             ,pr_tpctrato => 1 -- Limite Credito
                                             ,pr_flgalter => 0
                                             ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

            END IF;
          END IF;

        END IF; --- rating vencido

      END IF;
      -- Verifica processamento do Rating Renovacao
    END IF;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE craplim SET '
                                                      ||' dtrenova = '||''''||to_char(rw_craplim.dtrenova,'dd/mm/rrrr')||''''
                                                      ||' ,tprenova = '||''''||rw_craplim.tprenova||''''
                                                      ||' ,dsnrenov = '||''''||rw_craplim.dsnrenov||''''                
                                                     ||' ,dtfimvig = '||''''||to_char(rw_craplim.dtfimvig_rollback,'dd/mm/rrrr')||''''
                                                      ||' ,qtrenova = '||rw_craplim.qtrenova
                                                      ||' ,cdoperad = '||''''||rw_craplim.cdoperad||''''
                                                      ||' ,cdopelib = '||''''||rw_craplim.cdoperad||''''
                                                ||' WHERE cdcooper = '||pr_cdcooper
                                                ||'   AND nrdconta = '||pr_nrdconta
                                                 ||'  AND nrctrlim = '||pr_nrctrlim
                                                 ||'  AND tpctrlim = 1;' -- Limite Credito        
                                              );
 
    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim SET
             dtrenova = pr_dtmvtolt,
             tprenova = 'M',
             dsnrenov = '',
             dtfimvig = pr_dtmvtolt + nvl(qtdiavig,0),
             qtrenova = nvl(qtrenova,0) + 1,
             cdoperad = pr_cdoperad,
             cdopelib = pr_cdoperad
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 1; -- Limite Credito
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    /* Por default fica como 3 */
    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Cred. Ctr: ' || pr_nrctrlim || ',';

    /* Se for conta integracao ativa, seta a flag para enviar ao BB */
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  /* Ativa */
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;

    /* Verifica se jah possui alteracao */
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;
    --Verificar se encontrou
    IF cr_crapalt%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapalt;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE crapalt SET '
                                                          ||' dsaltera = '||''''||to_char(rw_craplim.dtrenova,'dd/mm/rrrr')||''''
                                                          ||' ,cdoperad = '||''''||rw_craplim.cdoperad||''''
                                                          ||' ,flgctitg = '||''''||rw_craplim.cdoperad||''''
                                                    ||' WHERE rowid = '||''''||rw_crapalt.rowid||''''
                                                    ||';'
                                                   );          

      -- Altera o registro
      BEGIN
        UPDATE crapalt SET
               crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               crapalt.cdoperad = pr_cdoperad,
               crapalt.flgctitg = vr_flgctitg
         WHERE crapalt.rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          --Sair
          RAISE vr_exc_saida;
      END;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapalt;

      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (crapalt.nrdconta
          ,crapalt.dtaltera
          ,crapalt.tpaltera
          ,crapalt.dsaltera
          ,crapalt.cdcooper
          ,crapalt.flgctitg
          ,crapalt.cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'delete crapalt '
                                      ||' WHERE cdcooper = '||pr_cdcooper
                                      ||' and nrdconta = '||pr_nrdconta
                                      ||' and tpaltera = 2'
                                      ||' and dtaltera = '||''''||to_char(pr_dtmvtolt,'dd/mm/rrrr')||''''
                                      ||';'
                                     );          
    
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;
    
   GENE0001.pc_gera_log(pr_cdcooper =>  pr_cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                        ,pr_dstransa => 'Renovacao manual Limite (RITM00121279)'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'Script'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'Contrato',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => pr_nrctrlim);    

    COMMIT;  -- Necessário devido ao uso do PRAGMA

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK; -- Necessário devido ao uso do PRAGMA
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_renovar_limite_cred_manual: '|| SQLERRM;
      ROLLBACK; -- Necessário devido ao uso do PRAGMA
    END;

  END pc_renovar_limite_cred_manual;


 -- Rotina referente a renovacao manual do limite de desconto de cheque
  PROCEDURE pc_renovar_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica


    -- -- -- -- -- -- -- -- -- -- 
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- -- -- -- -- -- -- -- -- --

  BEGIN

  DECLARE

    -- Variável para consulta de limite
    vr_tab_lim_desconto dscc0001.typ_tab_lim_desconto;
    
    vr_retorno     BOOLEAN DEFAULT(FALSE);
    vr_xml      xmltype;
    
    --Variaveis auxiliares
    vr_vllimite craplim.vllimite%TYPE;
    vr_nrdrowid ROWID;
    vr_in_risco_rat INTEGER;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de Log de Alteracao
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
    vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;

    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato

      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,
             
             craplim.tprenova,
             craplim.dtfimvig dtfimvig_rollback,        
             dtinivig  
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 2; -- Limite de crédito de desconto de cheque
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor Linhas de Credito de Desconto de Cheque
    CURSOR cr_crapldc (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT crapldc.flgstlcr
        FROM crapldc
       WHERE crapldc.cdcooper = pr_cdcooper
         AND crapldc.cddlinha = pr_cddlinha
         AND crapldc.tpdescto = 2; -- Cheque

    rw_crapldc cr_crapldc%ROWTYPE;

    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper
         AND craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
         AND craprli.tplimite = 2; -- Limite Credito Desconto Cheque

    rw_craprli cr_craprli%ROWTYPE;

    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid,
           cdoperad,
           flgctitg
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;

     rw_crapalt cr_crapalt%ROWTYPE;
   --limite desconto cheque  
   CURSOR cr_tbrisco_operacoes(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato
    SELECT 1 FROM tbrisco_operacoes o
                 WHERE o.cdcooper = pr_cdcooper
                   AND o.nrdconta = pr_nrdconta
                   AND o.nrctremp = pr_nrctrlim
                   AND o.tpctrato = 2
                   AND o.flintegrar_sas = 1;--- já marcado para atualizar
    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;     

     vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

     -- P450 Valida Endividamento
     vr_strating     NUMBER;
     vr_flgrating    NUMBER;
     vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
     vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
     -- P450 Valida Endividamento

  BEGIN

    --> Buscar Parametro
    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');


    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado não possui proposta de limite de desconto cheque.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de desconto de cheque deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite de desconto de cheque. Limite nao esta vencido.';
      RAISE vr_exc_saida;
    END IF;

    --Guarda valor anterior do limite
    vr_vllimite := rw_craplim.vllimite;

    -- Consulta o limite de credito de desconto de cheque
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;

    -- Verifica se o limite de credito existe
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_dscritic := 'Linha de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapldc;
    END IF;

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras da linha de credito de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;


    -- Consulta o limite de desconto por tipo de pessoa
    DSCC0001.pc_busca_tab_limdescont(pr_cdcooper => pr_cdcooper                  --> Codigo da cooperativa
                                    ,pr_inpessoa => rw_crapass.inpessoa          --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                    ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto
                                    ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                    ,pr_dscritic => vr_dscritic);                --> Descrição da crítica

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN

      -- Verifica processamento do Rating Renovacao
      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        
        /* Validar Status rating */
        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 2 -- Limite Desconto Cheque
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          
           IF substr(vr_dscritic,1,47) = 'Contrato nao pode ser efetivado, Rating vencido' THEN

              -- verificar se já está marcado para atualizar o rating a noite via lote, se já está não precisa fazer novamente.
              OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctrlim => pr_nrctrlim);
              FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
              IF cr_tbrisco_operacoes%NOTFOUND THEN

                BEGIN 
                  UPDATE tbrisco_operacoes o
                     SET o.flintegrar_sas = 1
                   WHERE o.cdcooper = pr_cdcooper
                     AND o.nrdconta = pr_nrdconta
                     AND o.nrctremp = pr_nrctrlim
                     AND o.tpctrato = 2;
                EXCEPTION
                  WHEN OTHERS THEN
                  vr_dscritic := 'Erro atualizar tabela tbrisco_operacoes, para rating vencido '||SQLERRM;
                  RAISE vr_exc_saida;
                END;         

                vr_retorno := rati0003.fn_registra_historico(pr_cdcooper             => pr_cdcooper
                                                            ,pr_cdoperad             => pr_cdoperad
                                                            ,pr_nrdconta             => pr_nrdconta
                                                            ,pr_nrctro               => pr_nrctrlim
                                                            ,pr_dtmvtolt             => NULL
                                                            ,pr_valor                => 0
                                                            ,pr_tpctrato             => 2
                                                            ,pr_rating_sugerido      => NULL
                                                            ,pr_justificativa        => 'Renovacao Limite de desconto cheque em massa1'
                                                            ,pr_inrisco_rating       => NULL
                                                            ,pr_dtrisco_rating       => NULL
                                                            ,pr_inrisco_rating_autom => NULL
                                                            ,pr_dtrisco_rating_autom => NULL
                                                            ,pr_insituacao_rating    => NULL
                                                            ,pr_inorigem_rating      => NULL
                                                            ,pr_cdoperad_rating      => pr_cdoperad
                                                            ,pr_tpoperacao_rating    => NULL
                                                         --   ,pr_retxml               => vr_xml
                                                            ,pr_cdcritic             => vr_cdcritic
                                                            ,pr_dscritic             => vr_dscritic);
                IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
                
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                              ,pr_des_text => 'UPDATE tbrisco_operacoes SET '
                                                                  ||' flintegrar_sas = 0 '
                                                            ||' WHERE cdcooper = '||pr_cdcooper
                                                            ||'   AND nrdconta = '||pr_nrdconta
                                                             ||'  AND nrctremp = '||pr_nrctrlim
                                                             ||'  AND tpctrato = 2;' -- Limite desc cheque
                                                          );        
   
  
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                         ,pr_des_text => 'delete tbrating_historicos '
                       ||' WHERE cdcooper = '||pr_cdcooper           
                       ||' and nrdconta = '||pr_nrdconta                                 
                       ||'  AND nrctremp = '||pr_nrctrlim                                 
                       ||' AND tpctrato = 2 '                                 
                       ||' and ds_justificativa = '||''''||'Renovacao Limite de credito em massa1'||''''                                 
                       ||';'                                 
                      );                                  
              END IF;                                                  
                                   
           ELSE
             RAISE vr_exc_saida;
           END IF;  
        ELSE

----------------------
-------------------------
          -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
          RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_vlendivi => vr_vlendivid
                                         ,pr_vlrating => vr_vllimrating
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Status do rating inválido
          IF vr_flgrating = 0 THEN
            vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
            RAISE vr_exc_saida;

          ELSE -- Status do rating válido

            -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
            IF ((vr_vlendivid) > vr_vllimrating) THEN

              -- Gravar o Rating da operação, efetivando-o
              rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                               ,pr_nrdconta          => pr_nrdconta
                                               ,pr_tpctrato          => 2 -- Limite Desconto Cheque
                                               ,pr_nrctrato          => pr_nrctrlim
                                               ,pr_dtrating          => pr_dtmvtolt
                                               ,pr_strating          => 4
                                               ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                               --Variáveis para gravar o histórico
                                               ,pr_cdoperad          => pr_cdoperad
                                               ,pr_dtmvtolt          => pr_dtmvtolt
                                               ,pr_valor             => vr_vllimite
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => 'Renovação de Contrato - RITM0123960]'
                                               ,pr_tpoperacao_rating => 2
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                               --Variáveis de crítica
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              rati0005.pc_altera_flag_alterar(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrato => pr_nrctrlim
                                             ,pr_tpctrato => 2 -- Limite Desconto Cheque
                                             ,pr_flgalter => 0
                                             ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

            END IF;
          END IF;

        END IF; --rating vencido      

      END IF;
      -- Verifica processamento do Rating Renovacao
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim
         SET dtinivig = pr_dtmvtolt,
             dtfimvig = pr_dtmvtolt + NVL(qtdiavig,0),
             qtrenova = NVL(qtrenova,0) + 1,
             dtrenova = pr_dtmvtolt,
             tprenova = 'M' -- Manual
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 2; -- Limite Desconto Cheque

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito de desconto de cheque: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE craplim SET '
                                                      ||' dtinivig = '||''''||to_char(rw_craplim.dtinivig,'dd/mm/rrrr')||''''
                                                      ||' ,dtfimvig = '||''''||to_char(rw_craplim.dtfimvig_rollback,'dd/mm/rrrr')||''''
                                                      ||' ,qtrenova = '||rw_craplim.qtrenova
                                                      ||' ,dtrenova = '||''''||to_char(rw_craplim.dtrenova,'dd/mm/rrrr')||''''
                                                      ||' ,tprenova = '||''''||rw_craplim.tprenova||''''
                                                ||' WHERE cdcooper = '||pr_cdcooper
                                                ||'   AND nrdconta = '||pr_nrdconta
                                                 ||'  AND nrctrlim = '||pr_nrctrlim
                                                 ||'  AND tpctrlim = 2;' -- Limite Credito        
                                              );

    -- Por default fica como 3
    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Desc Cheque. Ctr: ' || pr_nrctrlim || ',';

    -- Se for conta integracao ativa, seta a flag para enviar ao BB
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  -- Ativa
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;

    -- Verifica se jah possui alteracao
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'UPDATE crapalt SET '
                                                            ||' dsaltera  = '||''''||rw_crapalt.dsaltera||''''
                                                            ||' ,cdoperad = '||''''||rw_crapalt.cdoperad||''''
                                                            ||' ,flgctitg = '||rw_crapalt.flgctitg
                                                      ||' WHERE rowid = '||''''||rw_crapalt.rowid||''''
                                                      ||';'
                                                     );       
    ELSE
      CLOSE cr_crapalt;
      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2 -- alterações diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                              ,pr_des_text => 'delete crapalt '
                            ||' WHERE cdcooper = '||pr_cdcooper
                            ||' and nrdconta = '||pr_nrdconta
                            ||' and tpaltera = 2'
                            ||' and dtaltera = '||''''||to_char(pr_dtmvtolt,'dd/mm/rrrr')||''''
                            ||';'
                           );     
          
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;

    --Gerar histórico de renovação de Proposta.
    TELA_ATENDA_DSCTO_TIT.pc_gravar_hist_alt_limite(pr_cdcooper => pr_cdcooper,
                                                    pr_nrdconta => pr_nrdconta,
                                                    pr_nrctrlim => pr_nrctrlim,
                                                    pr_tpctrlim => 2,
                                                    pr_dsmotivo => 'RENOVACAO MANUAL MASSIVA RITM0123960',
                                                    pr_cdcritic => vr_cdcritic,
                                                    pr_dscritic => vr_dscritic);
        
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                        ,pr_des_text => 'delete cecred.tbdsct_hist_alteracao_limite '
                      ||' WHERE cdcooper = '||pr_cdcooper
                      ||' and nrdconta = '||pr_nrdconta
                      ||' and nrctrlim = '||pr_nrctrlim
                      ||' and tpctrlim = 2 '                      
                      ||' and dsmotivo = '||''''||'RENOVACAO MANUAL MASSIVA RITM0123960'||''''
                      ||';'
                     );        

    COMMIT;  -- Necessário devido ao uso do PRAGMA
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      ROLLBACK; -- Necessário devido ao uso do PRAGMA
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      ROLLBACK; -- Necessário devido ao uso do PRAGMA
    END;

  END pc_renovar_lim_desc_cheque;

  
BEGIN
  BEGIN
--- inicio  
-- Banco individual
    --      vr_nmarq_rollback := '/progress/t0031664/micros/cpd/bacas/RITM0123960_ROLLBACK.sql';
    --      vr_nmarq_log      := '/progress/t0031664/micros/cpd/bacas/LOG_RITM0123960.txt';

-- Banco Test      
-- \\pkgtest\micros---  /microstst/cecred/Elton/
         -- vr_nmarq_rollback := '/microstst/cecred/Elton/RITM0123960_ROLLBACK.sql';
        --  vr_nmarq_log      := '/microstst/cecred/Elton/LOG_RITM0123960.txt';

-- caminho para produção:
          vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
          vr_nmarq_rollback := vr_dsdireto||'RITM0123960_ROLLBACK.sql';
          vr_nmarq_log      := vr_dsdireto||'LOG_RITM0123960.txt';

          /* Abrir o arquivo de rollback */
          gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                                  ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_handle     --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);
          if vr_des_erro is not null then
            vr_dsmensagem := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
            RAISE vr_exc_erro;
          end if;
          --
          /* Abrir o arquivo de LOG */
          gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                                  ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_handle_log     --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);
          if vr_des_erro is not null then
            vr_dsmensagem := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
            RAISE vr_exc_erro;
          end if;



          -- Verifica se a data esta cadastrada
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => 13);
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

          -- Se não encontrar
          IF BTCH0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE BTCH0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
            RAISE vr_exc_erro;
          ELSE
            -- Apenas fechar o cursor
            CLOSE BTCH0001.cr_crapdat;
          END IF;

          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Linha;Coop;Conta;Contrato;TipoContrato;Mensagem');
                                        
--          dbms_output.put_line('Linha;Coop;Conta;Contrato;Mensagem');
          --
          for r_cnt in (
        select cnt.cdcooper
              ,cnt.nrdconta
              ,cnt.nrctrlim
              ,cnt.cddlinha_atual
              ,cnt.cddlinha_nova
        from
        (
SELECT 13 cdcooper, 0000159 nrdconta,  09920925 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0001791 nrdconta,  00020901 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0001813 nrdconta,  00425171 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0002410 nrdconta,  00425195 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0009911 nrdconta,  00009927 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0013200 nrdconta,  00281016 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0015245 nrdconta,  00020906 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0019054 nrdconta,  00000872 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0019232 nrdconta,  09927666 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0019380 nrdconta,  00281055 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0021296 nrdconta,  00000990 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0029629 nrdconta,  00020913 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0040967 nrdconta,  00342899 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0042617 nrdconta,  00342862 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0042676 nrdconta,  00342861 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0044830 nrdconta,  00298648 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0046663 nrdconta,  00298620 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0048615 nrdconta,  00342878 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0048887 nrdconta,  00298619 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0051411 nrdconta,  00425133 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0052264 nrdconta,  00009440 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0054194 nrdconta,  00008196 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0054500 nrdconta,  00018177 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0055336 nrdconta,  00022682 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0055352 nrdconta,  00285725 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0066150 nrdconta,  00020451 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0067113 nrdconta,  00005671 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0067768 nrdconta,  00001044 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0074284 nrdconta,  00025359 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0082210 nrdconta,  00018169 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0083780 nrdconta,  00023844 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0085405 nrdconta,  00011694 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0120235 nrdconta,  00011635 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0124605 nrdconta,  00023665 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0125857 nrdconta,  00011697 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0149098 nrdconta,  00012682 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0180491 nrdconta,  00001346 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0195715 nrdconta,  00023833 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0210420 nrdconta,  00001004 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0213837 nrdconta,  00018103 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0214086 nrdconta,  00209140 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0215651 nrdconta,  00001624 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0247715 nrdconta,  00023821 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0252956 nrdconta,  00022615 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0253634 nrdconta,  00001843 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0280402 nrdconta,  00022221 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0281980 nrdconta,  00023835 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0281999 nrdconta,  00023856 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0285510 nrdconta,  00020908 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0286117 nrdconta,  00020910 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0297950 nrdconta,  00001649 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0299820 nrdconta,  00025408 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317390 nrdconta,  00000490 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317390 nrdconta,  00001860 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0320102 nrdconta,  00001646 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0325961 nrdconta,  00001687 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0330078 nrdconta,  00001489 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0346810 nrdconta,  00001492 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0358231 nrdconta,  00001580 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0009695 nrdconta,  00013737 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0102393 nrdconta,  00000968 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0169439 nrdconta,  00001792 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0191078 nrdconta,  00017092 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0242004 nrdconta,  00023227 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0254681 nrdconta,  00018500 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0255530 nrdconta,  00001323 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0261033 nrdconta,  00001394 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0272000 nrdconta,  00001018 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0273090 nrdconta,  00000826 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0274755 nrdconta,  00001291 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0277711 nrdconta,  00001808 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279382 nrdconta,  00018482 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280259 nrdconta,  00018484 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281140 nrdconta,  00001078 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281140 nrdconta,  00018496 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282030 nrdconta,  00018495 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282600 nrdconta,  00023213 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282863 nrdconta,  00023224 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283258 nrdconta,  00023214 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283495 nrdconta,  00023215 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283649 nrdconta,  00021988 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285935 nrdconta,  00023217 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0287911 nrdconta,  00000983 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0289035 nrdconta,  00000483 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0298808 nrdconta,  00001058 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0316423 nrdconta,  00023289 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317209 nrdconta,  00023299 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0323098 nrdconta,  00001324 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0324531 nrdconta,  00001160 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0329576 nrdconta,  00001734 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0332399 nrdconta,  00001790 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0342700 nrdconta,  00001357 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0702072 nrdconta,  00023245 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0703850 nrdconta,  00023246 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0712655 nrdconta,  00018578 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0713341 nrdconta,  00023205 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0713376 nrdconta,  00334297 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0195618 nrdconta,  00019513 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0196681 nrdconta,  00020084 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0197505 nrdconta,  00021247 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0199168 nrdconta,  00020078 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0207730 nrdconta,  00018632 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0218707 nrdconta,  00016350 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0224200 nrdconta,  00021211 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0265322 nrdconta,  00020187 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0278017 nrdconta,  00021227 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281727 nrdconta,  00020190 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282073 nrdconta,  00021240 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317241 nrdconta,  00025242 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280445 nrdconta,  00001379 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281247 nrdconta,  00001583 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285196 nrdconta,  00022901 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0298310 nrdconta,  00001327 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0311073 nrdconta,  00001611 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317314 nrdconta,  00024604 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0326259 nrdconta,  00001505 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0327565 nrdconta,  00001757 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0342823 nrdconta,  00001506 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0348350 nrdconta,  00001873 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0352489 nrdconta,  00001911 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0163180 nrdconta,  00000494 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282693 nrdconta,  00023173 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0356190 nrdconta,  00001520 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0377953 nrdconta,  00001905 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0415952 nrdconta,  00001817 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0420670 nrdconta,  00001822 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0437514 nrdconta,  00001872 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0452890 nrdconta,  00001923 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0000795 nrdconta,  00007404 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0002720 nrdconta,  00009634 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0006181 nrdconta,  09927646 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0006823 nrdconta,  00092983 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0008001 nrdconta,  00285964 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0010235 nrdconta,  00099140 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0012050 nrdconta,  00099164 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0018198 nrdconta,  00094326 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0025402 nrdconta,  00300844 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0025585 nrdconta,  00002020 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0026492 nrdconta,  00372602 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0028410 nrdconta,  00001237 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0063665 nrdconta,  00019786 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0065633 nrdconta,  00001725 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0070181 nrdconta,  00288437 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0100641 nrdconta,  00008310 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0109223 nrdconta,  00001129 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0112984 nrdconta,  00001642 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0121835 nrdconta,  00013548 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0129372 nrdconta,  00288363 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0136646 nrdconta,  00025300 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0142638 nrdconta,  00024034 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0158259 nrdconta,  00024058 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0173312 nrdconta,  00024048 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0175790 nrdconta,  00024040 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0180289 nrdconta,  00024105 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0184470 nrdconta,  00020273 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0185272 nrdconta,  00024108 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0185701 nrdconta,  00023114 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0186244 nrdconta,  00025136 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0187194 nrdconta,  00024039 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0187232 nrdconta,  00024027 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0187372 nrdconta,  00025134 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0188204 nrdconta,  00016734 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0190136 nrdconta,  00024032 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0200301 nrdconta,  00290340 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0200425 nrdconta,  00001920 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0202517 nrdconta,  00300847 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0204439 nrdconta,  00023116 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0220329 nrdconta,  00003183 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0221694 nrdconta,  00372601 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0221821 nrdconta,  00290330 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0223360 nrdconta,  00016681 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0225339 nrdconta,  00290455 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0225592 nrdconta,  00002081 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0227072 nrdconta,  00093168 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0228630 nrdconta,  00300823 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0229121 nrdconta,  00007103 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0234370 nrdconta,  00023169 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0234850 nrdconta,  00012799 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0239089 nrdconta,  00009080 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0241695 nrdconta,  00024090 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0243370 nrdconta,  00154409 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0244244 nrdconta,  00002668 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0244848 nrdconta,  00008324 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0256420 nrdconta,  00020242 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0262145 nrdconta,  00023132 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0268291 nrdconta,  00020256 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0274046 nrdconta,  00000951 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279056 nrdconta,  00024030 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279161 nrdconta,  00022270 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279234 nrdconta,  00022269 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279935 nrdconta,  00024028 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280364 nrdconta,  00023122 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280658 nrdconta,  00024026 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280909 nrdconta,  00023115 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281158 nrdconta,  00023119 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281395 nrdconta,  00022299 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282243 nrdconta,  00024055 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282529 nrdconta,  00024092 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282723 nrdconta,  00024038 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283061 nrdconta,  00024056 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283592 nrdconta,  00024112 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284793 nrdconta,  00024111 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285501 nrdconta,  00024041 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0286257 nrdconta,  00024064 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0316920 nrdconta,  00025135 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0326194 nrdconta,  00001262 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0338389 nrdconta,  00001698 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0380121 nrdconta,  00001660 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0382990 nrdconta,  00000854 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0012130 nrdconta,  00297302 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0061298 nrdconta,  00001148 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0069825 nrdconta,  00373043 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0073075 nrdconta,  00001339 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0085103 nrdconta,  00007371 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0119652 nrdconta,  00012116 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0119695 nrdconta,  00011804 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0138835 nrdconta,  00011857 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0151289 nrdconta,  00000721 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0212326 nrdconta,  00016459 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0214400 nrdconta,  00001939 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0214850 nrdconta,  00001455 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0252727 nrdconta,  00021560 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0265179 nrdconta,  00019624 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0270296 nrdconta,  00019630 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0271780 nrdconta,  00019625 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0276391 nrdconta,  00019608 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279323 nrdconta,  00021561 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280542 nrdconta,  00019619 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280860 nrdconta,  00019631 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283576 nrdconta,  00021565 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283819 nrdconta,  00021029 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0301353 nrdconta,  00285814 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0304670 nrdconta,  00009311 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0305065 nrdconta,  00003305 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0305758 nrdconta,  00285838 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0306258 nrdconta,  00000853 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0307459 nrdconta,  00019615 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0307548 nrdconta,  00297315 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0309494 nrdconta,  00001553 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0311715 nrdconta,  00012179 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0312282 nrdconta,  00000980 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0312967 nrdconta,  00001715 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0313092 nrdconta,  00001270 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0314692 nrdconta,  00001232 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0315192 nrdconta,  00297386 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0328561 nrdconta,  00001776 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0358517 nrdconta,  00001742 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0463809 nrdconta,  00001970 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0005851 nrdconta,  00004120 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0092649 nrdconta,  00020771 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0092983 nrdconta,  00092290 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0124958 nrdconta,  00020784 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0134864 nrdconta,  00001928 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0157422 nrdconta,  00023938 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0178977 nrdconta,  00020464 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0179140 nrdconta,  00020769 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0179795 nrdconta,  00021453 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0211362 nrdconta,  00020752 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0269107 nrdconta,  00020788 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282197 nrdconta,  00020774 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283940 nrdconta,  00020797 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283967 nrdconta,  00020789 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284653 nrdconta,  00023937 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285951 nrdconta,  00020794 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0400424 nrdconta,  00094187 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0402460 nrdconta,  00001779 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0403032 nrdconta,  00008471 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0404730 nrdconta,  00013482 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0406490 nrdconta,  00020779 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0408794 nrdconta,  00006597 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0409936 nrdconta,  00020766 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0410705 nrdconta,  00364680 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0410829 nrdconta,  00020790 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0410926 nrdconta,  00010823 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0411981 nrdconta,  00008210 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0014290 nrdconta,  00003146 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0018040 nrdconta,  00002085 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0020028 nrdconta,  00091717 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0020524 nrdconta,  00091791 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0025399 nrdconta,  09927646 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0066826 nrdconta,  00008376 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0112941 nrdconta,  00019111 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0129259 nrdconta,  00012502 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0145041 nrdconta,  00022742 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0168572 nrdconta,  00023176 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0170496 nrdconta,  00001859 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0193968 nrdconta,  00024359 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0202436 nrdconta,  00018805 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0203424 nrdconta,  00019107 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0204803 nrdconta,  00001592 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0204951 nrdconta,  00092940 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0204994 nrdconta,  00010682 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0220990 nrdconta,  00290401 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0227838 nrdconta,  00002164 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0275450 nrdconta,  00021171 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282936 nrdconta,  00023179 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283452 nrdconta,  00024098 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284637 nrdconta,  00023195 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284955 nrdconta,  00023199 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285820 nrdconta,  00022714 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0287032 nrdconta,  00022718 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0317195 nrdconta,  00024536 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0407119 nrdconta,  00111600 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0501670 nrdconta,  00022708 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0502340 nrdconta,  00372858 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0502600 nrdconta,  00012593 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0000060 nrdconta,  09280996 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0004014 nrdconta,  00001374 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0009660 nrdconta,  00281029 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0015512 nrdconta,  00007538 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0021873 nrdconta,  00009735 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0027600 nrdconta,  00091243 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0029424 nrdconta,  00093462 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0030554 nrdconta,  00298658 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0031046 nrdconta,  00092211 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0032360 nrdconta,  00298787 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0032387 nrdconta,  00004361 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0036595 nrdconta,  00281036 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0038229 nrdconta,  00001502 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0043354 nrdconta,  00001090 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0043362 nrdconta,  00298784 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0043672 nrdconta,  00024178 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0062138 nrdconta,  00012949 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0068926 nrdconta,  00011181 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0071110 nrdconta,  00011037 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0072842 nrdconta,  00021740 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0075779 nrdconta,  00005782 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0080152 nrdconta,  00024158 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0084700 nrdconta,  00009101 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0104191 nrdconta,  00001363 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0125296 nrdconta,  00012953 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0125377 nrdconta,  00011690 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0125563 nrdconta,  00021741 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0127558 nrdconta,  00011055 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0185434 nrdconta,  00017194 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0186031 nrdconta,  00017197 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0222615 nrdconta,  00024176 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279358 nrdconta,  00020379 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279862 nrdconta,  00024144 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280712 nrdconta,  00020385 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280917 nrdconta,  00020386 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0281328 nrdconta,  00024151 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282065 nrdconta,  00024161 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282707 nrdconta,  00024163 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282847 nrdconta,  00024169 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283266 nrdconta,  00024170 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284548 nrdconta,  00024175 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284599 nrdconta,  00020389 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284734 nrdconta,  00024179 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284840 nrdconta,  00024181 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0285897 nrdconta,  00024188 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0286249 nrdconta,  00024191 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0286770 nrdconta,  00023602 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0600733 nrdconta,  00298748 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0601527 nrdconta,  00008845 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0601705 nrdconta,  00365047 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0602280 nrdconta,  00365137 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0060682 nrdconta,  00315123 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0088781 nrdconta,  00023247 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0113905 nrdconta,  00001131 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0150924 nrdconta,  00023248 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0169641 nrdconta,  00017017 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0175315 nrdconta,  00022000 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0188506 nrdconta,  00017303 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0209910 nrdconta,  00021967 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0279943 nrdconta,  00021961 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0282456 nrdconta,  00021990 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283630 nrdconta,  00021993 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284483 nrdconta,  00021995 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284696 nrdconta,  00023301 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284882 nrdconta,  00023252 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0292869 nrdconta,  00000991 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0317454 nrdconta,  00024440 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0317462 nrdconta,  00024441 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0318361 nrdconta,  00001289 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0319252 nrdconta,  00001134 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0379263 nrdconta,  00001699 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0395897 nrdconta,  00001726 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0701831 nrdconta,  00342212 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0704032 nrdconta,  00001114 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0704695 nrdconta,  00009634 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0705780 nrdconta,  00001765 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0707260 nrdconta,  00315107 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0708160 nrdconta,  00415534 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0712175 nrdconta,  00305757 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0714429 nrdconta,  00009674 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0716278 nrdconta,  00001334 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0731560 nrdconta,  00023249 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0732265 nrdconta,  00021974 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0732559 nrdconta,  00018712 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0004901 nrdconta,  00003479 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0031747 nrdconta,  00093883 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0033553 nrdconta,  00001087 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0039519 nrdconta,  00001069 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0044202 nrdconta,  00001393 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0048224 nrdconta,  00022616 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0048798 nrdconta,  00342888 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0055298 nrdconta,  00001508 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0062430 nrdconta,  00001367 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0075329 nrdconta,  00000661 nrctrlim, 09  cddlinha_atual, 15  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0075329 nrdconta,  00001479 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0080926 nrdconta,  00000997 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0087270 nrdconta,  00013859 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0136956 nrdconta,  00020844 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0161985 nrdconta,  00022561 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0184039 nrdconta,  00022587 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0218952 nrdconta,  00001761 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0278920 nrdconta,  00022526 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0279242 nrdconta,  00020900 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0279781 nrdconta,  00022535 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0280062 nrdconta,  00022537 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0280119 nrdconta,  00022538 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0280771 nrdconta,  00022544 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0282375 nrdconta,  00001016 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0283550 nrdconta,  00022575 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0285633 nrdconta,  00022589 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0285730 nrdconta,  00022584 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0286141 nrdconta,  00020852 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0286753 nrdconta,  00023740 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all 
SELECT 13 cdcooper, 0324426 nrdconta,  00001555 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0351130 nrdconta,  00001658 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0373281 nrdconta,  00001869 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0397296 nrdconta,  00001793 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0137880 nrdconta,  00364829 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0143073 nrdconta,  00000950 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0181943 nrdconta,  00415412 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0183407 nrdconta,  00001748 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0189138 nrdconta,  00001430 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0194069 nrdconta,  00415377 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0206423 nrdconta,  00017580 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0214574 nrdconta,  00024010 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0250732 nrdconta,  00001704 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0251097 nrdconta,  00024003 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0262684 nrdconta,  00024022 nrctrlim, 02  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0278246 nrdconta,  00024012 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0280054 nrdconta,  00014169 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0283231 nrdconta,  00024009 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284521 nrdconta,  00001446 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0284858 nrdconta,  00024015 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0288853 nrdconta,  00001146 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0291714 nrdconta,  00001215 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0316490 nrdconta,  00001098 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0325015 nrdconta,  00027221 nrctrlim, 01  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0334227 nrdconta,  00001368 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0389803 nrdconta,  00001762 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual union all
SELECT 13 cdcooper, 0448664 nrdconta,  00001921 nrctrlim, 12  cddlinha_atual, 17  cddlinha_nova from dual 
        ) cnt
                       )
          loop
            --
            vr_dsmensagem := null;
            vr_nrregistro := vr_nrregistro + 1;
            --
            begin
              --
              select 1 into vr_existe_ass
              from crapass ass
              where ass.nrdconta = r_cnt.nrdconta
                and ass.cdcooper = r_cnt.cdcooper;
              --
            exception
              when others then
                vr_existe_ass := 0;
                vr_dsmensagem := 'Cooperado nao existe';
            end;
            --
            vr_existe_lim := 0;
            vr_insitlim := 0;
            vr_cddlinha_contrato := NULL;
            if vr_existe_ass = 1 then
              --
              begin
                --
                select 1, lim.insitlim, lim.cddlinha, lim.tpctrlim , decode(lim.tpctrlim,1,'Limite Credito',2,'Desconto Cheque',3,'Desconto Titulo')
                 into vr_existe_lim, vr_insitlim, vr_cddlinha_contrato, vr_tpctrllim, vr_descTpLim
                from craplim lim
                where lim.nrctrlim = r_cnt.nrctrlim
                  and lim.nrdconta = r_cnt.nrdconta
                  and lim.cdcooper = r_cnt.cdcooper;
                --  and lim.tpctrlim = 1;
                --
              exception
                when others then
                  vr_existe_lim := 0;
                  vr_dsmensagem := 'Contrato nao encontrado';
              end;
              --
              if vr_existe_lim = 1 AND vr_insitlim = 2 THEN  -- 2-contrato ativo
 
                IF  vr_tpctrllim = 1 THEN -- limite credito
                   pc_renovar_limite_cred_manual(pr_cdcooper => r_cnt.cdcooper
                                               ,pr_cdoperad =>'1'
                                               ,pr_nmdatela =>'ATENDA'
                                               ,pr_idorigem => 5  --aimaro
                                               ,pr_nrdconta => r_cnt.nrdconta
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_nrctrlim => r_cnt.nrctrlim
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                   IF vr_dscritic IS NOT NULL THEN
                      vr_dsmensagem := vr_dscritic;                                                                        
                      vr_dscritic := NULL;                                                
                   END IF;           
                ELSIF  vr_tpctrllim = 2 THEN -- limite desconto cheque
                  pc_renovar_lim_desc_cheque(pr_cdcooper => r_cnt.cdcooper
                                            ,pr_nrdconta => r_cnt.nrdconta
                                            ,pr_idseqttl => 1
                                            ,pr_nrctrlim => r_cnt.nrctrlim
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdoperad =>'1'
                                            ,pr_nmdatela =>'ATENDA'
                                            ,pr_idorigem  => 5  --aimaro
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                                      
                   IF vr_dscritic IS NOT NULL THEN
                      vr_dsmensagem := vr_dscritic;                                                                        
                      vr_dscritic := NULL;                                                
                   END IF;           
                                                                                 
                END IF;
               --
                if vr_dsmensagem is null then
                  begin
                    --
                    update craplim lim
                    set lim.cddlinha = r_cnt.cddlinha_nova
                    where lim.nrctrlim = r_cnt.nrctrlim
                      and lim.nrdconta = r_cnt.nrdconta
                      and lim.cdcooper = r_cnt.cdcooper
                      and lim.tpctrlim = vr_tpctrllim;
                      
                    update crawlim lim
                    set lim.cddlinha = r_cnt.cddlinha_nova
                    where lim.nrctrlim = r_cnt.nrctrlim
                      and lim.nrdconta = r_cnt.nrdconta
                      and lim.cdcooper = r_cnt.cdcooper
                      and lim.tpctrlim = vr_tpctrllim;

                    --
                  exception
                    when others then
                      vr_dsmensagem := 'Erro na atualizacao do contrato:'||sqlerrm;
                  end;
                END IF;  
                --
                if vr_dsmensagem is null then
                  --
                  vr_nrctrl_atualizados :=  vr_nrctrl_atualizados + 1;
                  
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE craplim lim '    ||
                                                                '   SET lim.cddlinha = ' || r_cnt.cddlinha_atual ||
                                                                ' WHERE lim.cdcooper = ' || r_cnt.cdcooper       ||
                                                                '   AND lim.nrdconta = ' || r_cnt.nrdconta       ||
                                                                '   AND lim.nrctrlim = ' || r_cnt.nrctrlim       ||
                                                                '   AND lim.tpctrlim = ' || vr_tpctrllim ||
                                                                ';');

                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crawlim lim '    ||
                                                                '   SET lim.cddlinha = ' || r_cnt.cddlinha_atual ||
                                                                ' WHERE lim.cdcooper = ' || r_cnt.cdcooper       ||
                                                                '   AND lim.nrdconta = ' || r_cnt.nrdconta       ||
                                                                '   AND lim.nrctrlim = ' || r_cnt.nrctrlim       ||
                                                                '   AND lim.tpctrlim = ' || vr_tpctrllim ||
                                                                ';');
                                     
                  GENE0001.pc_gera_log(pr_cdcooper => r_cnt.cdcooper
                                      ,pr_cdoperad => '1'
                                      ,pr_dscritic => ' '
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                      ,pr_dstransa => 'Troca de linha de credito (RITM0123960)'
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 1
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => 1
                                      ,pr_nmdatela => 'Script'
                                      ,pr_nrdconta => r_cnt.nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  --
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                            pr_nmdcampo => 'Linha de '||vr_descTpLim,
                                            pr_dsdadant => r_cnt.cddlinha_atual,
                                            pr_dsdadatu => r_cnt.cddlinha_nova);
                  --
                end if;
                --
              ELSIF vr_existe_lim = 1 AND vr_insitlim <> 2 THEN
                vr_dsmensagem := 'Contrato nao e ativo.';
              end if;
              --

            end if;

            IF vr_cddlinha_contrato   <>      r_cnt.cddlinha_atual AND vr_dsmensagem is NULL THEN
               vr_dsmensagem := ' Linha atual diferente! Atual arquivo: '||r_cnt.cddlinha_atual||' Atual contrato: '||vr_cddlinha_contrato||'. O contrato foi atualizado para nova linha.'; 
            END IF;
               
            IF vr_dsmensagem IS NOT NULL THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' || r_cnt.nrdconta ||
                                                            ';' || r_cnt.nrctrlim ||';' || vr_descTpLim
                                                             || ';' || vr_dsmensagem);
            END IF;
            --
          end loop;
          --
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Total de registros tratados no processo: ' || vr_nrregistro);
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Total de contratos atualizados: ' || vr_nrctrl_atualizados);
          --
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'COMMIT;');
                                                
          COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Erro: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Erro: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);
      
      ROLLBACK;
  END;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
end;
