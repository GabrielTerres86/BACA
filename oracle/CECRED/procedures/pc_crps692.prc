CREATE OR REPLACE PROCEDURE CECRED.pc_crps692 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................
       Programa: pc_crps692 (Fontes/crps692.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Dezembro/2014                     Ultima atualizacao: 27/05/2018

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Renovacao automatica do limite de credito.

       Alteracoes: 03/03/2015 - Incluido a procedure pc_gera_log_alteracao. (Carlos Rafael)

                   13/04/2015 - Alterado o tamanho da coluna dsvlrmot. (James)

                   17/08/2015 - Ajuste para buscar o pior Risco, Projeto de Provisao. (James)

                   11/08/2016 - Adicionado novo filtro por tipo de limite de crédito (Linhares)

                   01/12/2016 - Fazer tratamento para incorporação. (Oscar)

                   27/05/2018 - Chama rotina LIMI0002.PC_CANCELA_LIMITE_INADIM de cancelamento de limite - Daniel(AMcom)

                   06/06/2018 - Ajustes para considerar titulos de bordero vencidos (Andrew Albuquerque - GFT)

                   03/2019 Incluido rati0003.pc_grava_rating_operacao proj 450 rating

                   28/05/2019 - Proj 450 - Ajuste para gravar o rating como vencido (Heckmann - AMcom)

                   05/06/2019 - Inclusão de parametro RATING_RENOVACAO_ATIVO (Mario - AMcom)

                   16/08/2019 - P450 - Grava rating como vencimdo pc_grava_rating_operacao sem
                                pesquisar a contingencia (Luiz Otavio Olinger Momm - AMCOM)
    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS692';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Regras
      vr_dtrenini   DATE;           --> Data de tentativas de renovacoes
      vr_dtaltera   DATE;           --> Data de revisao cadastral
      vr_dtmincta   DATE;           --> Data do Tempo Minimo de Conta
      vr_dstextab   VARCHAR2(1000); --> Campo da tabela generica
      vr_vlarrast   NUMBER;         --> Valor Arrasto
      vr_nivrisco   VARCHAR2(2);    --> Nivel de Risco
      vr_in_risco_rat INTEGER;      --> Nivel de Risco Rating
      -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
      vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;
      vr_habrat                        VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

      vr_vlendivid                     craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
      vr_vllimrating                   craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
      vr_strating                      tbrisco_operacoes.insituacao_rating%TYPE; -- Identificador da Situacao Rating
      vr_dtrating                      tbrisco_operacoes.dtrisco_rating%TYPE; -- Data para efetivar o rating;

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Listagem de alterações cadastrais
      CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                       ,pr_nrdconta IN crapalt.nrdconta%TYPE) IS
        SELECT crapalt.dtaltera
          FROM crapalt
         WHERE crapalt.cdcooper = pr_cdcooper
           AND crapalt.nrdconta = pr_nrdconta
           AND crapalt.tpaltera = 1
           AND ROWNUM = 1
        ORDER BY crapalt.dtaltera DESC; --> Recadastramento
      rw_crapalt cr_crapalt%ROWTYPE;

      -- Verifica se possui registro no CYBER
      CURSOR cr_crapcyb(pr_cdcooper IN crapcyb.cdcooper%TYPE,
                        pr_nrdconta IN crapcyb.nrdconta%TYPE,
                        pr_cdorigem VARCHAR2,
                        pr_qtdiaatr IN crapcyb.qtdiaatr%TYPE) IS
        SELECT qtdiaatr
          FROM crapcyb
         WHERE crapcyb.cdcooper = pr_cdcooper
           AND crapcyb.nrdconta = pr_nrdconta
           AND ','||pr_cdorigem||',' LIKE ('%,'||crapcyb.cdorigem||',%')
           AND crapcyb.qtdiaatr > pr_qtdiaatr
           AND crapcyb.dtdbaixa IS NULL
           AND ROWNUM = 1;
      rw_crapcyb cr_crapcyb%ROWTYPE;

      -- Limite de credito
      CURSOR cr_craplim_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                                pr_inpessoa IN crapass.inpessoa%TYPE,
                                pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                                pr_dtmvtoan IN crapdat.dtmvtoan%TYPE,
                                pr_qtdiaren IN craprli.qtdiaren%TYPE) IS
        SELECT craplim.cdcooper,
               craplim.nrdconta,
               craplim.vllimite,
               craplim.qtrenova,
               craplim.cddlinha,
               craplim.qtdiavig,
               craplim.nrctrlim,
               nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,
               craplim.rowid,
               crapass.nmprimtl,
               crapass.cdagenci,
               crapass.dtadmiss,
               crapass.cdsitdct,
               crapass.nrdctitg,
               crapass.flgctitg,
               crapass.flgrenli,
               crapass.nrcpfcnpj_base
          FROM craplim, crapass
         WHERE craplim.cdcooper = crapass.cdcooper
           AND craplim.nrdconta = crapass.nrdconta
           AND craplim.cdcooper = pr_cdcooper
           AND craplim.insitlim = 2
           AND craplim.tpctrlim = 1 -- Limite de Credito
           AND crapass.inpessoa = pr_inpessoa
           -- Vencimento no Final de Semana
           AND ((nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) > pr_dtmvtoan   AND
                 nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) <= pr_dtmvtolt) OR
               -- Tentativas de Renovacao
                (nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) >= (pr_dtmvtolt - pr_qtdiaren) AND
                 nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) <= pr_dtmvtolt));

      -- Linhas de credito rotativa
      CURSOR cr_craplrt(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craplrt.cddlinha,
               craplrt.flgstlcr
          FROM craplrt
         WHERE craplrt.cdcooper = pr_cdcooper;

      -- Regras do limite de credito
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE) IS
        SELECT craprli.cdcooper,
               craprli.inpessoa,
               craprli.vlmaxren,
               craprli.nrrevcad,
               craprli.qtmincta,
               craprli.qtdiaren,
               craprli.qtmaxren,
               craprli.qtdiaatr,
               craprli.qtatracc,
               craprli.dssitdop,
               craprli.dsrisdop
          FROM craprli
         WHERE craprli.cdcooper = pr_cdcooper
           AND craprli.tplimite = 1; --Limite Credito

      -- Risco com divida (Valor Arrasto)
      CURSOR cr_ris_comdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                          ,pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_inddocto IN crapris.inddocto%TYPE
                          ,pr_vldivida IN crapris.vldivida%TYPE) IS
        SELECT MAX(innivris) innivris
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtrefere = pr_dtrefere
           AND inddocto = pr_inddocto
           AND vldivida > pr_vldivida;
      rw_ris_comdiv cr_ris_comdiv%ROWTYPE;

      -- Risco sem divida
      CURSOR cr_ris_semdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                          ,pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_inddocto IN crapris.inddocto%TYPE) IS
        SELECT MAX(innivris) innivris
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtrefere = pr_dtrefere
           AND inddocto = pr_inddocto;
      rw_ris_semdiv cr_ris_semdiv%ROWTYPE;

      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT crapage.cdagenci,
                crapage.nmresage
           FROM crapage
          WHERE crapage.cdcooper = pr_cdcooper;

      /* Conta incorporada */
      CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE,
                        pr_nrdconta IN craptco.nrdconta%TYPE)  IS
         SELECT 1
           FROM craptco
          WHERE craptco.cdcooper = pr_cdcooper
            AND craptco.nrdconta = pr_nrdconta;
      rw_craptco cr_craptco%ROWTYPE;


      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ------------------------------- TIPOS DE REGISTROS -----------------------
      TYPE typ_reg_craplrt IS RECORD
        (flgstlcr craplrt.flgstlcr%TYPE); -- Situacao da linha

      TYPE typ_reg_rel692 IS RECORD
        (cdagenci crapass.cdagenci%TYPE,
         nrdconta crapass.nrdconta%TYPE,
         nmprimtl crapass.nmprimtl%TYPE,
         nrtelefo craptfc.nrtelefo%TYPE,
         nrctrlim craplim.nrctrlim%TYPE,
         vllimite craplim.vllimite%TYPE,
         dtfimvig craplim.dtfimvig%TYPE,
         dsnrenov craplim.dsnrenov%TYPE,
         dsvlrmot VARCHAR2(20));

      -- Tabela temporaria para os tipos de risco
      TYPE typ_reg_craptab IS RECORD
        (dsdrisco craptab.dstextab%TYPE);

      TYPE typ_reg_crapage IS RECORD
        (nmresage crapage.nmresage%TYPE);

      ------------------------------- TIPOS DE DADOS ---------------------------
      TYPE typ_tab_craplrt  IS TABLE OF typ_reg_craplrt INDEX BY PLS_INTEGER;
      TYPE typ_tab_rel692   IS TABLE OF typ_reg_rel692  INDEX BY VARCHAR2(25);
      TYPE typ_tab_craptab  IS TABLE OF typ_reg_craptab INDEX BY PLS_INTEGER;
      TYPE typ_tab_crapage  IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

      ----------------------------- VETORES DE MEMORIA -------------------------
      vr_tab_craplrt  typ_tab_craplrt;
      vr_tab_rel692   typ_tab_rel692;
      vr_tab_craptab  typ_tab_craptab;
      vr_tab_crapage  typ_tab_crapage;

      ----------------------------- PROCEDURES ---------------------------------
      --Procedure para limpar os dados das tabelas de memoria
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        vr_tab_craplrt.DELETE;
        vr_tab_rel692.DELETE;
        vr_tab_craptab.DELETE;
        vr_tab_crapage.DELETE;
      EXCEPTION
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
          vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps692.pc_limpa_tabela. '||sqlerrm;
          --Sair do programa
          RAISE vr_exc_fimprg;
      END;

      -- Registra LOG de alteração para a tela ALTERA
      PROCEDURE pc_gera_log_alteracao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                     ,pr_nrdctitg IN crapass.nrdctitg%TYPE
                                     ,pr_flgctitg IN crapass.flgctitg%TYPE) IS

        -- Variaveis de Log de Alteracao
        vr_flgctitg crapalt.flgctitg%TYPE;
        vr_dsaltera LONG;

        -- Variaveis com erros
        vr_des_erro   VARCHAR2(4000);

        -- Cursor alteracao de cadastro
        CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS

          SELECT crapalt.dsaltera,
                 crapalt.rowid
            FROM crapalt
           WHERE crapalt.cdcooper = pr_cdcooper
             AND crapalt.nrdconta = pr_nrdconta
             AND crapalt.dtaltera = pr_dtmvtolt;
        rw_crapalt cr_crapalt%ROWTYPE;

      BEGIN

        /* Por default fica como 3 */
        vr_flgctitg  := 3;
        vr_dsaltera  := 'Renov. Aut. Limite Cred. Ctr: ' || pr_nrctrlim || ',';

        /* Se for conta integracao ativa, seta a flag para enviar ao BB */
        IF trim(pr_nrdctitg) IS NOT NULL AND pr_flgctitg = 2 THEN  /* Ativa */
          --Conta Integracao
          vr_flgctitg := 0;
        END IF;

        /* Verifica se jah possui alteracao */
        OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtmvtolt => pr_dtmvtolt);

        FETCH cr_crapalt INTO rw_crapalt;
        --Verificar se encontrou
        IF cr_crapalt%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapalt;
          -- Altera o registro
          BEGIN
            UPDATE crapalt SET
                   crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
                   crapalt.flgctitg = vr_flgctitg
             WHERE crapalt.rowid = rw_crapalt.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Conta: '    || pr_nrdconta ||'.'||
                             'Contrato: ' || pr_nrctrlim ||'.'||
                             'Erro ao atualizar crapalt. '||SQLERRM;

              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            ||vr_cdprogra || ' --> '|| vr_des_erro);
          END;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapalt;

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
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro:= 'Conta: '    || pr_nrdconta ||'.'||
                            'Contrato: ' || pr_nrctrlim ||'.'||
                            'Erro ao inserir crapalt. '||SQLERRM;

              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            ||vr_cdprogra || ' --> ' || vr_des_erro);
          END;

        END IF;

      END pc_gera_log_alteracao;

      -- Procedure para atualizar a nao renovacao do limite de credito
      PROCEDURE pc_nao_renovar_limite_credito(pr_craplim_crapass IN cr_craplim_crapass%ROWTYPE,
                                              pr_dsnrenov        IN VARCHAR2,
                                              pr_dsvlrmot        IN VARCHAR2) IS
        -- Telefone
        CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%TYPE,
                          pr_nrdconta IN craptfc.nrdconta%TYPE) IS
           SELECT craptfc.nrdddtfc,
                  craptfc.nrtelefo
             FROM craptfc
            WHERE craptfc.cdcooper = pr_cdcooper
              AND craptfc.nrdconta = pr_nrdconta
              AND craptfc.idseqttl = 1
         ORDER BY craptfc.tptelefo, craptfc.nrtelefo;
        rw_craptfc cr_craptfc%ROWTYPE;

        -- Variaveis com erros
        vr_exc_erro   EXCEPTION;
        vr_des_erro   VARCHAR2(4000);

        vr_nrtelefo   VARCHAR(15); --> Telefone
        vr_index692   VARCHAR(25); --> Indice do Array
      BEGIN

        vr_nrtelefo := '';
        -- Busca o telefone
        OPEN cr_craptfc(pr_cdcooper => pr_craplim_crapass.cdcooper,
                        pr_nrdconta => pr_craplim_crapass.nrdconta);
        FETCH cr_craptfc INTO rw_craptfc;
        IF cr_craptfc%FOUND THEN
          CLOSE cr_craptfc;
          vr_nrtelefo := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
        ELSE
          CLOSE cr_craptfc;
        END IF;

        -- Indice do relatorio
        vr_index692 := lpad(pr_craplim_crapass.cdagenci,5,'0')||
                       lpad(pr_craplim_crapass.nrdconta,10,'0')||
                       lpad(pr_craplim_crapass.nrctrlim,10,'0');

        -- Tabela de memoria para a impressao do relatorio
        vr_tab_rel692(vr_index692).cdagenci := pr_craplim_crapass.cdagenci;
        vr_tab_rel692(vr_index692).nrdconta := pr_craplim_crapass.nrdconta;
        vr_tab_rel692(vr_index692).nmprimtl := pr_craplim_crapass.nmprimtl;
        vr_tab_rel692(vr_index692).nrtelefo := vr_nrtelefo;
        vr_tab_rel692(vr_index692).nrctrlim := pr_craplim_crapass.nrctrlim;
        vr_tab_rel692(vr_index692).vllimite := pr_craplim_crapass.vllimite;
        vr_tab_rel692(vr_index692).dtfimvig := pr_craplim_crapass.dtfimvig;
        vr_tab_rel692(vr_index692).dsnrenov := pr_dsnrenov;
        vr_tab_rel692(vr_index692).dsvlrmot := pr_dsvlrmot;

        BEGIN
          -- Atualizar a tabela de limite de credito
          UPDATE craplim
             SET dsnrenov = pr_dsnrenov || '|' || pr_dsvlrmot
           WHERE rowid    = pr_craplim_crapass.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Montar mensagem de erro
            vr_des_erro := 'Erro ao atualizar tabela craplim. Rotina pc_crps692. ' || SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Envio centralizado de log de erro
          vr_des_erro := 'Conta: '    || pr_craplim_crapass.nrdconta ||'.'||
                         'Contrato: ' || pr_craplim_crapass.nrctrlim ||'.'||
                         vr_des_erro;
          -- Catalogar o erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                        vr_cdprogra || ' --> '|| vr_des_erro);
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
          vr_des_erro := 'Conta: '    || pr_craplim_crapass.nrdconta ||'.'||
                         'Contrato: ' || pr_craplim_crapass.nrctrlim ||'.'||
                         'Erro nao tratado. Rotina pc_crps692. '||SQLERRM;
          -- Catalogar o erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_des_erro);
      END;

      -- Geração do relatório de limite de creditos vencidos que nao foram renovados
      PROCEDURE pc_imprime_crrl692(pr_tab_rel692  IN typ_tab_rel692,
                                   pr_tab_crapage IN typ_tab_crapage,
                                   pr_des_erro   OUT VARCHAR2) IS

        -- Relatorio
        vr_nom_arquivo VARCHAR2(100);
        vr_des_xml     CLOB;
        vr_dstexto     VARCHAR2(32700);
        vr_nom_direto  VARCHAR2(400);
        vr_des_chave   VARCHAR2(400);
        vr_cdagenci    crapage.cdagenci%TYPE;

        --Variavel de Exceção
        vr_des_erro VARCHAR2(4000);
        vr_exc_erro EXCEPTION;

      BEGIN
        --Inicializar variavel de erro
        pr_des_erro:= NULL;
        -- Busca do diretório base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

        -- Processar todos os registros dos maiores depositantes
        vr_des_chave := pr_tab_rel692.FIRST;
        LOOP
          -- Sair quando a chave atual for null (chegou no final)
          EXIT WHEN vr_des_chave IS NULL;
          -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
          IF vr_des_chave = pr_tab_rel692.FIRST OR pr_tab_rel692(vr_des_chave).cdagenci <> pr_tab_rel692(pr_tab_rel692.PRIOR(vr_des_chave)).cdagenci THEN
            vr_cdagenci := pr_tab_rel692(vr_des_chave).cdagenci;
            -- Nome base do arquivo
            vr_nom_arquivo := 'crrl692_'||to_char(vr_cdagenci,'fm000');
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
            vr_dstexto:= NULL;
            -- Inicilizar as informações do XML
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl692><registros>');
          END IF;

          --Escrever no xml as informacoes da conta
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<limite>
                         <cdagenci>'||vr_cdagenci||'</cdagenci>
                         <nmresage>'||pr_tab_crapage(vr_cdagenci).nmresage||'</nmresage>
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(pr_tab_rel692(vr_des_chave).nrdconta))||'</nrdconta>
                         <nmprimtl>'||substr(pr_tab_rel692(vr_des_chave).nmprimtl,1,30)||'</nmprimtl>
                         <nrtelefo>'||pr_tab_rel692(vr_des_chave).nrtelefo||'</nrtelefo>
                         <nrctrlim>'||LTrim(gene0002.fn_mask_contrato(pr_tab_rel692(vr_des_chave).nrctrlim))||'</nrctrlim>
                         <vllimite>'||to_char(pr_tab_rel692(vr_des_chave).vllimite,'fm999g999g990d00')||'</vllimite>
                         <dtfimvig>'||to_char(pr_tab_rel692(vr_des_chave).dtfimvig,'DD/MM/RRRR')||'</dtfimvig>
                         <dsnrenov>'||pr_tab_rel692(vr_des_chave).dsnrenov||'</dsnrenov>
                         <dsvlrmot>'||pr_tab_rel692(vr_des_chave).dsvlrmot||'</dsvlrmot>
                       </limite>');

          IF vr_des_chave = pr_tab_rel692.LAST OR pr_tab_rel692(vr_des_chave).cdagenci <> pr_tab_rel692(pr_tab_rel692.NEXT(vr_des_chave)).cdagenci THEN
            -- Finalizar o agrupador de Agencias e inicia totalizador do PA
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</registros></crrl692>',true);
            -- Efetuar solicitação de geração de relatório --
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                 --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                       ,pr_dsxml     => vr_des_xml                  --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl692/registros/limite' --> Nó base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl692.jasper'            --> Arquivo de layout do iReport
                                       ,pr_dsparams  => NULL                        --> Nao tem parametros
                                       ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                       ,pr_qtcoluna  => 132                         --> 132 colunas
                                       ,pr_sqcabrel  => NULL                        --> Sequencia do Relatorio {includes/cabrel132_3.i}
                                       ,pr_cdrelato  => 692                         --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                       ,pr_flg_impri => 'N'                         --> Chamar a impressão (Imprim.p)
                                       ,pr_nmformul  => '132dm'                     --> Nome do formulário para impressão
                                       ,pr_nrcopias  => 1                           --> Número de cópias
                                       ,pr_flg_gerar => 'N'                         --> gerar na hora
                                       ,pr_des_erro  => vr_des_erro);               --> Saída com erro

            -- Testar se houve erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar exceção
              RAISE vr_exc_erro;
            END IF;
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);
            vr_dstexto:= NULL;
          END IF;
          -- Buscar o próximo registro da tabela
          vr_des_chave := pr_tab_rel692.NEXT(vr_des_chave);
        END LOOP;
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := vr_des_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao imprimir relatorio crrl692. '||sqlerrm;
      END;

      --------------------------- SUBROTINAS INTERNAS --------------------------
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
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

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_fimprg;
      END IF;

      pc_limpa_tabela;
      --> Buscar Parametro
      vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                ,pr_cdcooper => 0
                                                                ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Seleciona valor de arrasto da tabela generica
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 0);
      -- Atribui o valor do arrasto
      vr_vlarrast := nvl(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 3, 9)),0);
      -- Carrega os tipos de riscos
      vr_tab_craptab(1).dsdrisco  := 'AA';
      vr_tab_craptab(2).dsdrisco  := 'A';
      vr_tab_craptab(3).dsdrisco  := 'B';
      vr_tab_craptab(4).dsdrisco  := 'C';
      vr_tab_craptab(5).dsdrisco  := 'D';
      vr_tab_craptab(6).dsdrisco  := 'E';
      vr_tab_craptab(7).dsdrisco  := 'F';
      vr_tab_craptab(8).dsdrisco  := 'G';
      vr_tab_craptab(9).dsdrisco  := 'H';
      vr_tab_craptab(10).dsdrisco := 'H';

      -- Buscar todas as linhas de credito rotativa
      FOR rw_craplrt IN cr_craplrt(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craplrt(rw_craplrt.cddlinha).flgstlcr  := rw_craplrt.flgstlcr;
      END LOOP;

      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;

      FOR rw_craprli IN cr_craprli(pr_cdcooper => pr_cdcooper) LOOP
        -- Buscar todos os limites de creditos que vencem hoje ou que venceram de acordo com a quantidade de tentativas para renovacao
        FOR rw_craplim_crapass IN cr_craplim_crapass (pr_cdcooper => rw_craprli.cdcooper,
                                                      pr_inpessoa => rw_craprli.inpessoa,
                                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                      pr_dtmvtoan => rw_crapdat.dtmvtoan,
                                                      pr_qtdiaren => rw_craprli.qtdiaren) LOOP

          -- Verifica a situacao do limite do credito
          IF nvl(rw_craplim_crapass.flgrenli,0) = 0 THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Desabilitado Renovacao Automatica',
                                          pr_dsvlrmot        => '');
            CONTINUE;
          END IF;

          -- Verifica se a linha rotativa esta cadastrada
          IF NOT vr_tab_craplrt.EXISTS(rw_craplim_crapass.cddlinha) THEN
            vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim_crapass.cddlinha;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '|| vr_dscritic);
            CONTINUE;
          END IF;

          -- Verifica a situacao do limite do credito
          IF nvl(vr_tab_craplrt(rw_craplim_crapass.cddlinha).flgstlcr,0) = 0 THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Linha de credito bloqueada',
                                          pr_dsvlrmot        => rw_craplim_crapass.cddlinha);
            CONTINUE;
          END IF;

          -- Verifica a situacao da conta
          IF (INSTR(';' || rw_craprli.dssitdop || ';',';' || rw_craplim_crapass.cdsitdct || ';') <= 0) THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Situacao da Conta',
                                          pr_dsvlrmot        => rw_craplim_crapass.cdsitdct);
            CONTINUE;
          END IF;

          -- Verifica o valor maximo que pode ser renovado
          IF nvl(rw_craprli.vlmaxren,0) < nvl(rw_craplim_crapass.vllimite,0) THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Valor do Limite',
                                          pr_dsvlrmot        => TO_CHAR(rw_craplim_crapass.vllimite,'fm999g999g999g990d00'));
            CONTINUE;
          END IF;

          -- Verificar a quantidade maxima que pode renovar
          IF ((nvl(rw_craprli.qtmaxren,0) > 0)                                    AND
              (nvl(rw_craplim_crapass.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Qtde. maxima de renovacao excedida',
                                          pr_dsvlrmot        => rw_craplim_crapass.qtrenova);
            CONTINUE;
          END IF;

          /* Procura se é uma conta incorporada */
          OPEN cr_craptco(rw_craplim_crapass.cdcooper,
                          rw_craplim_crapass.nrdconta);
          FETCH cr_craptco
           INTO rw_craptco;

          /* Só considera se não for conta incorporada */
          IF cr_craptco%NOTFOUND THEN

             CLOSE cr_craptco;

          vr_dtmincta := ADD_MONTHS(rw_crapdat.dtmvtolt, - (rw_craprli.qtmincta));

          -- Verificar o tempo de conta
          IF rw_craplim_crapass.dtadmiss > vr_dtmincta THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Tempo de Conta',
                                          pr_dsvlrmot        => to_char(rw_craplim_crapass.dtadmiss,'DD/MM/RRRR'));
            CONTINUE;
          END IF;
          ELSE
             CLOSE cr_craptco;
          END IF;

          -- Risco com divida (Valor Arrasto)
          OPEN cr_ris_comdiv(pr_cdcooper => rw_craplim_crapass.cdcooper
                            ,pr_nrdconta => rw_craplim_crapass.nrdconta
                            ,pr_dtrefere => rw_crapdat.dtultdma
                            ,pr_inddocto => 1
                            ,pr_vldivida => vr_vlarrast);
          FETCH cr_ris_comdiv
           INTO rw_ris_comdiv;
          CLOSE cr_ris_comdiv;
          -- Se encontrar
          IF rw_ris_comdiv.innivris IS NOT NULL THEN
            vr_nivrisco := TRIM(vr_tab_craptab(rw_ris_comdiv.innivris).dsdrisco);
          ELSE
            -- Risco sem divida
            OPEN cr_ris_semdiv(pr_cdcooper => rw_craplim_crapass.cdcooper
                              ,pr_nrdconta => rw_craplim_crapass.nrdconta
                              ,pr_dtrefere => rw_crapdat.dtultdma
                              ,pr_inddocto => 1);
            FETCH cr_ris_semdiv
             INTO rw_ris_semdiv;
            CLOSE cr_ris_semdiv;
            -- Se encontrar
            IF rw_ris_semdiv.innivris IS NOT NULL THEN
              /* Quando possuir operacao em Prejuizo, o risco da central sera H */
              IF rw_ris_semdiv.innivris = 10 THEN
                vr_nivrisco := TRIM(vr_tab_craptab(rw_ris_semdiv.innivris).dsdrisco);
              ELSE
                vr_nivrisco := TRIM(vr_tab_craptab(2).dsdrisco);
              END IF;
            ELSE
              vr_nivrisco := TRIM(vr_tab_craptab(2).dsdrisco);
            END IF;

          END IF;

          -- Caso seja uma classificacao antiga
          IF vr_nivrisco = 'AA' THEN
            vr_nivrisco := 'A';
          END IF;

          -- Verifica o risco da conta
          IF (INSTR(';' || rw_craprli.dsrisdop || ';',';' || vr_nivrisco || ';') <= 0) THEN
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Risco da Conta',
                                          pr_dsvlrmot        => vr_nivrisco);
            CONTINUE;
          END IF;

          vr_dtaltera := NULL;

          -- Revisão Cadastral
          OPEN cr_crapalt(pr_cdcooper => rw_craplim_crapass.cdcooper
                         ,pr_nrdconta => rw_craplim_crapass.nrdconta);
          FETCH cr_crapalt
           INTO rw_crapalt;
          -- Se NAO encontrar alteração passa para o proximo registro
          IF cr_crapalt%FOUND THEN
            CLOSE cr_crapalt;
            vr_dtaltera := rw_crapalt.dtaltera;
          ELSE
            CLOSE cr_crapalt;
          END IF;

          -- Verifica a revisao cadastral se estah dentro do periodo
          IF ((ADD_MONTHS(rw_crapdat.dtmvtolt, - (rw_craprli.nrrevcad)) > vr_dtaltera) OR (vr_dtaltera IS NULL)) THEN
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Revisao Cadastral',
                                          pr_dsvlrmot        => to_char(vr_dtaltera,'DD/MM/RRRR'));
            CONTINUE;
          END IF;

          -- Verifica se o cooperado possui algum emprestimo em atraso no CYBER
          OPEN cr_crapcyb(pr_cdcooper => rw_craplim_crapass.cdcooper,
                          pr_nrdconta => rw_craplim_crapass.nrdconta,
                          --Ajustes para considerar titulos de bordero vencidos (Andrew Albuquerque - GFT)
                          pr_cdorigem => '2,3,4',
                          pr_qtdiaatr => rw_craprli.qtdiaatr);
          FETCH cr_crapcyb INTO rw_crapcyb;
          IF cr_crapcyb%FOUND THEN
            CLOSE cr_crapcyb;
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Qtde de dias Atraso do Emprestimo',
                                          pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));

            CONTINUE;
          ELSE
            CLOSE cr_crapcyb;
          END IF;

          -- Verifica se o cooperado possui estouro de conta no CYBER
          OPEN cr_crapcyb(pr_cdcooper => rw_craplim_crapass.cdcooper,
                          pr_nrdconta => rw_craplim_crapass.nrdconta,
                          pr_cdorigem => '1',
                          pr_qtdiaatr => rw_craprli.qtatracc);
          FETCH cr_crapcyb INTO rw_crapcyb;
          IF cr_crapcyb%FOUND THEN
            CLOSE cr_crapcyb;
            -- Atualiza na tabela de limite de credito a descricao pelo qual nao foi renovado o limite de credito
            pc_nao_renovar_limite_credito(pr_craplim_crapass => rw_craplim_crapass,
                                          pr_dsnrenov        => 'Qtde de dias Atraso Conta Corrente',
                                          pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));

            CONTINUE;
          ELSE
            CLOSE cr_crapcyb;
          END IF;
          
          -- Atualiza os dados do limite de cheque especial
          BEGIN
            UPDATE craplim SET
                   dtrenova = rw_crapdat.dtmvtolt,
                   tprenova = 'A',
                   dsnrenov = ' ',
                   dtfimvig = rw_crapdat.dtmvtolt + nvl(qtdiavig,0),
                   qtrenova = nvl(qtrenova,0) + 1
             WHERE rowid = rw_craplim_crapass.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Conta: '    || rw_craplim_crapass.nrdconta ||'.'||
                             'Contrato: ' || rw_craplim_crapass.nrctrlim ||'.'||
                             'Erro ao atualizar tabela craplim. Rotina pc_crps692. ' || SQLERRM;
              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                            vr_cdprogra || ' --> ' || vr_dscritic);
              CONTINUE;
          END;

          -- P450 SPT13 - alteracao para habilitar rating novo
          IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN
            -- Verifica processamento do Rating Renovacao
            IF vr_flg_Rating_Renovacao_Ativo = 1 THEN
              -- Grava rating

              -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
              RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_craplim_crapass.nrdconta
                                             ,pr_vlendivi => vr_vlendivid
                                             ,pr_vlrating => vr_vllimrating
                                             ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Conta: '    || rw_craplim_crapass.nrdconta ||'.'||
                               'Contrato: ' || rw_craplim_crapass.nrctrlim ||'.'||
                               'Erro ao buscar o endividamento. Rotina pc_crps692. ' || SQLERRM;
                -- Catalogar o Erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                             vr_cdprogra || ' --> ' || vr_dscritic);
                CONTINUE;
              END IF;

              vr_strating := 2; -- Analisado
              vr_dtrating := NULL;
              IF (vr_vlendivid  > vr_vllimrating)  THEN
                -- Gravar o Rating da operação, efetivando-o
                vr_strating := 4; -- Efetivado
                vr_dtrating := rw_crapdat.dtmvtolt;
              END IF;

              rati0003.pc_grava_rating_operacao( pr_cdcooper           => pr_cdcooper
                                                ,pr_nrdconta           => rw_craplim_crapass.nrdconta
                                                ,pr_tpctrato           => 1
                                                ,pr_nrctrato           => rw_craplim_crapass.nrctrlim
                                                ,pr_strating           => vr_strating
                                                ,pr_dtrataut           => rw_crapdat.dtmvtolt  --> Data da nova renovação
                                                ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                                ,pr_dtrating           => vr_dtrating
                                                --Variáveis de crítica
                                                ,pr_cdcritic           => vr_cdcritic     --> Critica encontrada no processo
                                                ,pr_dscritic           => vr_dscritic);   --> Descritivo do erro

              IF ( vr_cdcritic >= 0 AND vr_cdcritic IS NOT NULL) OR TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Conta: '    || rw_craplim_crapass.nrdconta ||'.'||
                               'Contrato: ' || rw_craplim_crapass.nrctrlim ||'.'||
                               'Erro ao atualizar o rating. Rotina pc_crps692. ' || SQLERRM;
                -- Catalogar o Erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                             vr_cdprogra || ' --> ' || vr_dscritic);
                CONTINUE;
              END IF;
            END IF;
          END IF;
          -- P450 SPT13 - alteracao para habilitar rating novo

          /* Gera Log de alteracao */
          pc_gera_log_alteracao(pr_cdcooper => rw_craplim_crapass.cdcooper
                               ,pr_nrdconta => rw_craplim_crapass.nrdconta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdoperad => 1
                               ,pr_nrctrlim => rw_craplim_crapass.nrctrlim
                               ,pr_nrdctitg => rw_craplim_crapass.nrdctitg
                               ,pr_flgctitg => rw_craplim_crapass.flgctitg);

        END LOOP; /* END LOOP FOR rw_craplim */

      END LOOP; /* END LOOP FOR rw_craprli */

      -- Chama rotina de cancelamento de limite - Daniel(AMcom)
      LIMI0002.PC_CANCELA_LIMITE_INADIM(pr_cdcooper => pr_cdcooper   -- Cooperativa
                                        ,pr_cdcritic => vr_cdcritic   -- Código do erro
                                        ,pr_dscritic => vr_dscritic); -- Descrição do erro
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Gerar relatorios dos limites de creditos vencidos que nao foram renovados
      pc_imprime_crrl692(pr_tab_rel692  => vr_tab_rel692,
                         pr_tab_crapage => vr_tab_crapage,
                         pr_des_erro    => vr_dscritic);
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_fimprg;
      END IF;

      pc_limpa_tabela;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps692;
/
