DECLARE



--variaveis arquivos
  vr_dsmensagem varchar2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_des_erro VARCHAR2(1000);

  vr_handle utl_file.file_type;
  vr_handle_log utl_file.file_type;
  vr_registros NUMBER(10):= 0;


  vr_dsdireto VARCHAR2(150);

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro  EXCEPTION;

  --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
--    vr_texto VARCHAR2(600);

CURSOR c1 IS 
SELECT a.cdcooper, a.nrdconta, a.nrctrlim, a.tpctrlim, a.dtpropos, a.dtfimvig, a.insitlim
FROM craplim a
WHERE a.cdcooper =11--credifoz
AND a.tpctrlim =1
AND a.nrdconta||a.nrctrlim IN (--conta||Contrato
 222577||16258
,488887||38233
,590541||104884
,289221||26036
,434582||35214
,354082||24221
--,626260||2547  --de desconto cheque
,352764||50133
,168491||5246
,489646||101203
,64629||1093
,201383||17393
,226327||12901
,281719||12665
,477796||34588
,560979||47615
,359483||22598
,47406||293999
,314064||28554
,447803||38834
,485470||37179
,230073||17171
,501425||104465
,528048||40887
,401617||35862
,335282||22905
,487970||33997
,195456||6066
,153230||23908
,641782||47927
,157112||15004
,158011||11758
,294845||26266
,477524||37885
,353060||31966
,402788||30526
,437522||38279
,276057||14062
,506478||40020
,262420||15599
,78522||4897
,175889||38664
,403938||30009
,192163||17005
,451436||35656
,249696||17279
,627119||108429
,342513||16692
,186244||12692
,317870||17484
);

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
    -- P450 Valida Endividamento

    -- Informações de data do sistema
    rw_crapdat      btch0001.rw_crapdat%TYPE;
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

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
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

                vr_retorno := rati0003.fn_registra_historico(pr_cdcooper             => pr_cdcooper
                                                            ,pr_cdoperad             => pr_cdoperad
                                                            ,pr_nrdconta             => pr_nrdconta
                                                            ,pr_nrctro               => pr_nrctrlim
                                                            ,pr_dtmvtolt             => NULL
                                                            ,pr_valor                => 0
                                                            ,pr_tpctrato             => 1
                                                            ,pr_rating_sugerido      => NULL
                                                            ,pr_justificativa        => 'Renovacao Limite de credito em massa1'
                                                            ,pr_inrisco_rating       => NULL
                                                            ,pr_dtrisco_rating       => NULL
                                                            ,pr_inrisco_rating_autom => NULL
                                                            ,pr_dtrisco_rating_autom => NULL
                                                            ,pr_insituacao_rating    => NULL
                                                            ,pr_inorigem_rating      => NULL
                                                            ,pr_cdoperad_rating      => pr_cdoperad
                                                            ,pr_tpoperacao_rating    => NULL
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

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
--      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_renovar_limite_cred_manual: '|| SQLERRM;
    --  ROLLBACK;
    END;

  END pc_renovar_limite_cred_manual;





begin
  -- Test statements here

      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 11); --credifoz
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;  

-- Banco individual
         -- vr_nmarq_rollback := '/progress/t0031664/micros/cpd/bacas/RITM0127089_ROLLBACK_RENOVA.sql';
         -- vr_nmarq_log      := '/progress/t0031664/micros/cpd/bacas/LOG_RITM0127089_RENOVA.txt';

-- Banco Test      
-- \\pkgtest\micros---  /microstst/cecred/Elton/
      --    vr_nmarq_rollback := '/microstst/cecred/Elton/RITM0127089_ROLLBACK_RENOVA.sql';
      --    vr_nmarq_log      := '/microstst/cecred/Elton/LOG_RITM0127089_RENOVA.txt';

-- caminho para produção:
          vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
          vr_nmarq_rollback := vr_dsdireto||'RITM0127089_ROLLBACK_RENOVA.sql';
          vr_nmarq_log      := vr_dsdireto||'LOG_RITM0127089_RENOVA.txt';


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
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Coop;Conta;Contrato;Mensagem');


 FOR r1 IN c1 LOOP

    pc_renovar_limite_cred_manual(pr_cdcooper => r1.cdcooper
                                 ,pr_cdoperad =>'1'
                                 ,pr_nmdatela =>'ATENDA'
                                 ,pr_idorigem =>5  --aimaro
                                 ,pr_nrdconta =>r1.nrdconta
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_nrctrlim =>  r1.nrctrlim
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
     IF vr_dscritic IS NOT NULL THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => r1.cdcooper || ';' || r1.nrdconta ||
                                                          ';' || r1.nrctrlim || ';' || vr_dscritic);
          vr_dscritic := NULL;                                                
     END IF; 
     
     vr_registros := vr_registros +1;                

  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                              ,pr_des_text => 'Contratos tratados no processo:'||vr_registros );

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                ,pr_des_text => 'COMMIT;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
  
   COMMIT;

  EXCEPTION
    
    WHEN vr_exc_erro THEN
      dbms_output.put_line('Erro arquivos: ' || vr_dsmensagem);
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Erro arquivos: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);      

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'COMMIT;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
      ROLLBACK;  
    WHEN OTHERS THEN
      dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'COMMIT;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
      ROLLBACK;
END;
