CREATE OR REPLACE PROCEDURE CECRED.pc_crps731 IS
/* .............................................................................

   Programa: pc_crps731
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Supero
   Data    : Maio/2018                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo: Busca todas as propostas de cartão que estão sem aprovação a 8 dias.

   Alteracoes:

  ............................................................................. */

  -- Declarações
  -- Tabela que contém o arquivo
  vr_exc_erro              EXCEPTION;
  vr_dscritic              VARCHAR2(4000);
  --
  vr_dias_expiracao        NUMBER:=8; --default
  --
  CURSOR cur_cooper IS
    SELECT cdcooper
    FROM crapcop
    WHERE flgativo = 1;
  --
  --Propostas com Prazo em Expiração
  CURSOR cur_prop_agenci(pr_cdcooper         IN crapcop.cdcooper%TYPE
                        ,pr_dias_expiracao   IN NUMBER) IS
    SELECT DISTINCT crass.cdagenci --agencia
      FROM crawcrd crcrd
          ,crapass crass
    WHERE 1=1
       AND crass.nrdconta = crcrd.nrdconta
       AND crass.cdcooper = crcrd.cdcooper 
       AND crcrd.insitcrd = 0
       AND crcrd.cdcooper = pr_cdcooper
       AND crcrd.cdadmcrd BETWEEN 10 AND 80
       AND crcrd.dtpropos = TRUNC(SYSDATE)-pr_dias_expiracao;

  --Propostas com Prazo em Expiração
  CURSOR cur_prop_exp(pr_cdcooper         IN crapcop.cdcooper%TYPE
                     ,pr_cdagenci         IN crawcrd.cdagenci%TYPE
                     ,pr_dias_expiracao   IN NUMBER) IS
    SELECT crcrd.nrdconta --Número da conta
          ,crcrd.nrctrcrd --Número da proposta
          ,crcrd.dtpropos --Data Proposta
      FROM crawcrd crcrd
          ,crapass crass
    WHERE 1=1
       AND crass.nrdconta = crcrd.nrdconta
       AND crass.cdcooper = crcrd.cdcooper
       AND crcrd.insitcrd = 0
       AND crass.cdagenci = pr_cdagenci
       AND crcrd.cdcooper = pr_cdcooper
       AND crcrd.cdadmcrd BETWEEN 10 AND 80
       AND crcrd.dtpropos = TRUNC(SYSDATE)-pr_dias_expiracao;

  vr_propostas_concat    VARCHAR2(4000);
  vr_email_agencia       VARCHAR2(500);
  --
  vr_current_cooper      crapcop.cdcooper%TYPE;
  vr_razao_social        crapass.nmprimtl%TYPE;
  vr_associados          VARCHAR2(4000);

  -- Subrotinas
  -- Busca associados
  PROCEDURE pc_busca_associados(pr_cdcooper crapass.cdcooper%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE,
                                pr_nrctrcrd crawcrd.nrctrcrd%TYPE,
                                pr_associados OUT VARCHAR2) IS
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.cdsitdtl,
             crapass.nrcpfcgc,
             crapass.inlbacen,
             crapass.cdsitcpf,
             crapass.cdtipcta,
             crapass.dtdemiss,
             crapass.nrdctitg,
             crapass.flgctitg,
             crapass.idimprtr,
             crapass.idastcjt,
             crapass.cdsitdct
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE,
                      pr_nrcpf    tbcrd_aprovacao_cartao.nrcpf%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd
         AND nrcpf    = pr_nrcpf;
    rw_tbaprc cr_tbaprc%ROWTYPE;

    CURSOR cr_craptfc(pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT tfc.nrdddtfc||'-'||tfc.nrtelefo AS telefone
      FROM   craptfc tfc
      WHERE  tfc.nrdconta = pr_nrdconta
      AND    rownum <= 1
      ORDER BY tfc.tptelefo;

    rw_craptfc  cr_craptfc%ROWTYPE;

    vr_assinou  VARCHAR2(1);
    vr_idxctr   PLS_INTEGER;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_tab_crapavt cada0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens    cada0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro    gene0001.typ_tab_erro;

    vr_associados  VARCHAR2(4000);
  BEGIN
      --Busca dados do associado
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP

      IF rw_crapass.inpessoa = 2 THEN --PJ
        cada0001.pc_busca_dados_58(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 0
                                  ,pr_flgerlog => FALSE
                                  ,pr_cddopcao => 'C'
                                  ,pr_nrdctato => 0
                                  ,pr_nrcpfcto => ''
                                  ,pr_nrdrowid => NULL
                                  ,pr_tab_crapavt => vr_tab_crapavt
                                  ,pr_tab_bens => vr_tab_bens
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR
          vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        vr_idxctr := vr_tab_crapavt.first;
        --> Verificar se retornou informacao
        IF vr_idxctr IS NULL THEN
          RAISE vr_exc_saida;
        END IF;

        FOR vr_cont_reg IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP

          -- Buscar dados assinatura
          OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctrcrd => pr_nrctrcrd,
                         pr_nrcpf    => vr_tab_crapavt(vr_cont_reg).nrcpfcgc);
          FETCH cr_tbaprc INTO rw_tbaprc;

          IF cr_tbaprc%NOTFOUND THEN
            vr_assinou := 'N';
            CLOSE cr_tbaprc;
          ELSE
            vr_assinou := 'S';
            CLOSE cr_tbaprc;
          END IF;

          IF vr_assinou = 'N' THEN

            OPEN cr_craptfc(pr_nrdconta => pr_nrdconta);
            FETCH cr_craptfc INTO rw_craptfc;
            CLOSE cr_craptfc;

            vr_associados := vr_associados||'Nome do Sócio: '||vr_tab_crapavt(vr_cont_reg).nmdavali||'<br>'||
                                            'Telefone: '||rw_craptfc.telefone||'<br>';
          END IF;


        END LOOP;
      ELSE
        -- Buscar dados assinatura
        OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctrcrd => pr_nrctrcrd,
                       pr_nrcpf    => rw_crapass.nrcpfcgc);
        FETCH cr_tbaprc INTO rw_tbaprc;

        IF cr_tbaprc%NOTFOUND THEN
          vr_assinou := 'N';
          CLOSE cr_tbaprc;
        ELSE
          vr_assinou := 'S';
          CLOSE cr_tbaprc;
        END IF;

        IF vr_assinou = 'N' THEN

          OPEN cr_craptfc(pr_nrdconta => pr_nrdconta);
          FETCH cr_craptfc INTO rw_craptfc;
          CLOSE cr_craptfc;

          vr_associados := vr_associados||'Nome do Sócio: '||rw_crapass.nmprimtl||'<br>'||
                                          'Telefone: '||rw_craptfc.telefone||'<br>';
        END IF;

      END IF;

    END LOOP;

    pr_associados := vr_associados;

  EXCEPTION
    WHEN vr_exc_saida THEN
      RETURN;
    WHEN OTHERS THEN
      RETURN;
  END;
  -- Gera log em tabelas
  PROCEDURE pc_gera_log(pr_cdcooper     IN crapcop.cdcooper%type DEFAULT 3 -- Cooperativa
                       ,pr_dstiplog     IN VARCHAR2                        -- Tipo de Log
                       ,pr_dscritic     IN VARCHAR2 DEFAULT NULL           -- Descrição do Log
                       ,pr_tpocorrencia IN VARCHAR2 dEFAULT 4              -- Tipo de Ocorrência
                       ) IS
  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_log
  --  Sistema  : Rotina para gravar logs em tabelas
  --  Sigla    : CRED
  --  Autor    : Supero
  --  Data     : Março/2018           Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Rotina executada em qualquer frequencia.
  -- Objetivo  : Controla gravação de log em tabelas.
  --
  -- Alteracoes:
  --
  ------------------------------------------------------------------------------------------------------------
  vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
  --
  BEGIN
    -- Controlar geração de log de execução dos jobs
    pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E')
                          ,pr_cdprograma    => 'CRPS731'
                          ,pr_cdcooper      => pr_cdcooper
                          ,pr_tpexecucao    => 2 -- job
                          ,pr_tpocorrencia  => pr_tpocorrencia
                          ,pr_cdcriticidade => 0 -- baixa
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_idprglog      => vr_idprglog
                          ,pr_nmarqlog      => NULL
                          );
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Inclusão na tabela de erros Oracle
      pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_gera_log;

  -- Controla Controla log
  PROCEDURE pc_controla_log_batch(pr_idtiplog IN NUMBER   -- Tipo de Log
                                 ,pr_dscritic IN VARCHAR2 -- Descrição do Log
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ) IS
    --
    vr_dstiplog VARCHAR2(10);
    --
  BEGIN
    -- Descrição do tipo de log
    IF pr_idtiplog = 2 THEN
      --
      vr_dstiplog := 'ERRO: ';
      --
    ELSE
      --
      vr_dstiplog := 'ALERTA: ';
      --
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => pr_idtiplog
                              ,pr_cdprograma   => 'CRPS731'
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - '
                                                          || 'CRPS731' || ' --> ' || vr_dstiplog
                                                          || pr_dscritic );
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_controla_log_batch;

BEGIN
  --
  FOR rcooper IN cur_cooper LOOP
    --
    vr_dias_expiracao := gene0001.fn_param_sistema (pr_nmsistem => 'CRED',
                                                    pr_cdcooper => rcooper.cdcooper,
                                                    pr_cdacesso => 'DIAS_EMAIL_PROP_EXPIRAR');
    --
    vr_current_cooper := rcooper.cdcooper;
    --
    -- Inicia processo
    pc_controla_log_batch(1, 'Início crps731',rcooper.cdcooper);
    --
    --
    FOR ragenci IN cur_prop_agenci(rcooper.cdcooper
                                  ,vr_dias_expiracao) LOOP
      --
      vr_propostas_concat := NULL;
      --
      --Busca E-mail da Agência
      BEGIN
        SELECT dsdemail
        INTO vr_email_agencia
          FROM crapage
        WHERE cdcooper = rcooper.cdcooper
           AND cdagenci = ragenci.cdagenci;
      EXCEPTION
        WHEN no_data_found THEN
          vr_dscritic := 'Email da agência (PA) não encontrado.';
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;

          pc_gera_log(pr_cdcooper     => rcooper.cdcooper
                  ,pr_dstiplog     => 'E'
                  ,pr_dscritic     =>  vr_dscritic
                  ,pr_tpocorrencia => 2
                  );

          RAISE vr_exc_erro;
      END;
      --
      --
      FOR rcurexp IN cur_prop_exp(rcooper.cdcooper
                                 ,ragenci.cdagenci
                                 ,vr_dias_expiracao) LOOP

        BEGIN
          SELECT cr.nmprimtl
          INTO   vr_razao_social
          FROM   crapass cr
          WHERE  cr.nrdconta = rcurexp.nrdconta
          AND    cr.cdcooper = rcooper.cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := SQLERRM;

            pc_gera_log(pr_cdcooper     => rcooper.cdcooper
                    ,pr_dstiplog     => 'E'
                    ,pr_dscritic     =>  vr_dscritic
                    ,pr_tpocorrencia => 2
                    );

            RAISE vr_exc_erro;
        END;

        pc_busca_associados(rcooper.cdcooper
                           ,rcurexp.nrdconta
                           ,rcurexp.nrctrcrd
                           ,vr_associados);

        vr_propostas_concat := vr_propostas_concat || 'Proposta: '||rcurexp.nrctrcrd||'<br>'||
                                                      'Conta: '||rcurexp.nrdconta||'<br>'||
                                                      'Nome/Razão Social: '||vr_razao_social||'<br>'||
                                                      vr_associados||'<br>';

      END LOOP;
      --
      dbms_output.put_line(vr_propostas_concat);
      --
      IF vr_propostas_concat IS NOT NULL THEN
        gene0003.pc_solicita_email(pr_cdcooper => rcooper.cdcooper
                                  ,pr_cdprogra => 'pc_crps731'
                                  ,pr_des_destino => vr_email_agencia
                                  ,pr_des_assunto => 'Prazo da proposta do Cartão CECRED Empresas está expirando'
                                  ,pr_des_corpo => 'Faltam 3 dias para expirar o prazo da assinatura do(s) sócio(s) na proposta de solicitação do Cartão CECRED.<br>
Entre em contato com o cooperado para comunicá-lo.<br><br>
Propostas pendentes: <br><br>
'||vr_propostas_concat
                                  ,pr_des_anexo => NULL
                                  ,pr_flg_remete_coop => 'S'
                                  ,pr_flg_enviar => 'S'
                                  ,pr_des_erro => vr_dscritic);
      END IF;
      --
      IF vr_dscritic IS NOT NULL THEN

       pc_gera_log(pr_cdcooper     => rcooper.cdcooper
                  ,pr_dstiplog     => 'E'
                  ,pr_dscritic     =>  vr_dscritic
                  ,pr_tpocorrencia => 2
                  );

        RAISE vr_exc_erro;
      END IF;
      --
    END LOOP;
    --
    --
    pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps731 --> Finalizado o processamento.',rcooper.cdcooper);
    --
  END LOOP;
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps731 --> ' || vr_dscritic,vr_current_cooper);
  WHEN OTHERS THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps731 --> ' || SQLERRM,vr_current_cooper);
  --
END;
/
