CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Ocorrencias
  --
  -- Alterado: 23/01/2018 - Daniel AMcom
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Busca dados de risco das contas (contratos de empréstimo e limite de crédito) */
  PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                                ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK
                                
  /* Verifica Conta Corrente em Prejuízo e lista detalhes */
  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

END TELA_ATENDA_OCORRENCIAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_OCORRENCIAS IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_OCORRENCIAS
  --  Sistema  : Procedimentos para tela Atenda / Ocorrencias
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Setembro/2016.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  -- Alterado: 23/01/2018 - Reginaldo (AMcom)
  -- Ajuste: Criada procedure pc_busca_dados_risco
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_monta_reg_conta_xml(pr_retxml     IN OUT NOCOPY XMLType
                               ,pr_pos_conta     IN INTEGER
                               ,pr_dscritic      IN OUT VARCHAR2
                               ,pr_num_conta     IN crapass.nrdconta%TYPE
                               ,pr_cpf_cnpj      IN VARCHAR2
                               ,pr_num_contrato  IN crawepr.nrctremp%TYPE
                               ,pr_ris_inclusao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_grupo     IN crawepr.dsnivris%TYPE
                               ,pr_rating        IN crawepr.dsnivris%TYPE
                               ,pr_ris_atraso    IN crawepr.dsnivris%TYPE
                               ,pr_ris_refin     IN crawepr.dsnivris%TYPE
                               ,pr_ris_agravado  IN crawepr.dsnivris%TYPE
                               ,pr_ris_operacao  IN crawepr.dsnivris%TYPE
                               ,pr_ris_cpf       IN crawepr.dsnivris%TYPE
                               ,pr_numero_grupo  IN crapgrp.nrdgrupo%TYPE
                               ,pr_ris_melhora   IN crawepr.dsnivris%TYPE
                               ,pr_ris_final     IN crawepr.dsnivris%TYPE
                               ,pr_tipo_registro IN VARCHAR2) IS
  BEGIN
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Contas',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Conta',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_conta',
                             pr_tag_cont => pr_num_conta,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'cpf_cnpj',
                             pr_tag_cont => pr_cpf_cnpj,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'contrato',
                             pr_tag_cont => pr_num_contrato,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_inclusao',
                             pr_tag_cont => pr_ris_inclusao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_grupo',
                             pr_tag_cont => pr_ris_grupo,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'rating',
                             pr_tag_cont => pr_rating,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_atraso',
                             pr_tag_cont => pr_ris_atraso,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_refin',
                             pr_tag_cont => pr_ris_refin,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_agravado',
                             pr_tag_cont => pr_ris_agravado,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_melhora',
                             pr_tag_cont => CASE WHEN pr_ris_melhora <> pr_ris_inclusao AND pr_ris_melhora = 'A' THEN pr_ris_melhora ELSE '' END,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_operacao',
                             pr_tag_cont => pr_ris_operacao,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_cpf',
                             pr_tag_cont => pr_ris_cpf,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'risco_final',
                             pr_tag_cont => pr_ris_final,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'numero_gr_economico',
                             pr_tag_cont => pr_numero_grupo,
                             pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Conta',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'tipo_registro',
                             pr_tag_cont => pr_tipo_registro,
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_conta_xml;

  PROCEDURE pc_monta_reg_central_risco(pr_retxml           IN OUT NOCOPY XMLType
                                      ,pr_dscritic         IN OUT VARCHAR2
                                      ,pr_ris_ult_central  IN crawepr.dsnivris%TYPE
                                      ,pr_data_risco       IN VARCHAR2
                                      ,pr_qtd_dias_risco   IN VARCHAR2
                                      ,pr_ris_cooperado    IN crapass.inrisctl%TYPE
                                      ,pr_dat_ris_cooperad IN crapass.dtrisctl%TYPE) IS
  BEGIN
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Central',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_ult_central',
                             pr_tag_cont => pr_ris_ult_central,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'data_risco',
                             pr_tag_cont => pr_data_risco,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtd_dias_risco',
                             pr_tag_cont => pr_qtd_dias_risco,
                             pr_des_erro => pr_dscritic);

     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Central',
                             pr_posicao  => 0,
                             pr_tag_nova => 'risco_cooperado',
                             pr_tag_cont => pr_ris_cooperado || ' - ' || TO_CHAR(pr_dat_ris_cooperad, 'DD/MM/YYYY'),
                             pr_des_erro => pr_dscritic);
  END pc_monta_reg_central_risco;


 PROCEDURE pc_busca_dados_risco(pr_nrdconta IN crawepr.nrdconta%TYPE --> Número da conta
                               ,pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* ............................................................................

        Programa: pc_busca_dados_risco
        Sistema : Ayllos
        Sigla   : CECRED
        Autor   : Daniel/AMcom & Reginaldo/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao: 29/03/2018

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar dados de risco a partir de uma conta base
        Observacao: -----
        Alteracoes:  Ajuste para ler dados da nova tabela de "dados brutos" (tbrisco_central_ocr)
                     Março/2018 - Reginaldo (AMcom)
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variáveis gerais da procedure
      vr_auxconta          INTEGER := 0;           -- Contador auxiliar para posicão no XML
      vr_risco_ult_central crawepr.dsnivris%TYPE;  -- Risco da última central
      vr_data_risco_final  crapris.dtdrisco%TYPE;  -- Data do risco final
      vr_valor_arrasto     NUMBER;

      ---------->> CURSORES <<--------

      -- Dados da conta base
      CURSOR cr_base(pr_cdcooper INTEGER
           , pr_nrdconta INTEGER) IS
      SELECT cb.cdcooper
           , cb.nrdconta
           , cb.inpessoa
           , cb.nrcpfcgc
           , cb.inrisctl
           , cb.dtrisctl
           , DECODE(cb.inpessoa, 1,
                     to_char(cb.nrcpfcgc, '00000000000'),
                     substr(to_char(cb.nrcpfcgc, '00000000000000'), 1, 8)) nrcpfcgc_compara
        FROM crapass cb
       WHERE cb.cdcooper = pr_cdcooper
         AND cb.nrdconta = pr_nrdconta;
      rw_cbase cr_base%ROWTYPE;

      -- Contas de mesmo titular da conta base
      CURSOR cr_contas_do_titular(rw_cbase IN cr_base%ROWTYPE) IS
       WITH contas AS (
          SELECT ass.cdcooper
               , ass.nrdconta
               , ass.inpessoa
               , to_char(ass.nrcpfcgc,
                                    DECODE(ass.inpessoa, 1, '00000000000','00000000000000')) nrcpfcgc
               , DECODE(ass.inpessoa, 1,
                     to_char(ass.nrcpfcgc, '00000000000'),
                     substr(to_char(ass.nrcpfcgc, '00000000000000'), 1, 8)) nrcpfcgc_compara
               , ass.dsnivris
            FROM crapass ass
           WHERE cdcooper = rw_cbase.cdcooper
             AND inpessoa = rw_cbase.inpessoa
        )
        SELECT c.cdcooper
                   , c.nrdconta
                   , c.nrcpfcgc
                   , c.inpessoa
                   , c.dsnivris
                   , DECODE(c.nrdconta, rw_cbase.nrdconta, 0, 1) ordem
        FROM contas c
        WHERE c.nrcpfcgc_compara = rw_cbase.nrcpfcgc_compara
        ORDER BY ordem;
      rw_contas_do_titular cr_contas_do_titular%ROWTYPE;

    -- Contas dos grupos econômicos aos quais o titular da conta base está ligado
    CURSOR cr_contas_grupo_economico(rw_cbase IN cr_base%ROWTYPE) IS
    WITH grupos AS (
        SELECT gr.cdcooper
             , gr.nrdconta
             , gr.nrctasoc
             , gr.inpessoa
             , (SELECT to_char(nrcpfcgc,
                                  DECODE(inpessoa, 1, '00000000000','00000000000000')) FROM crapass WHERE cdcooper = gr.cdcooper AND nrdconta = gr.nrdconta) nrcpfcgc
             , DECODE(gr.inpessoa, 1,
                           to_char(gr.nrcpfcgc, '00000000000'),
                           substr(to_char(gr.nrcpfcgc, '00000000000000'), 1, 8)) nrcpfcgc_compara
             , gr.nrdgrupo
             , gr.dsdrisgp
             , (SELECT DECODE(inpessoa, 1,
                           to_char(nrcpfcgc, '00000000000'),
                           substr(to_char(nrcpfcgc, '00000000000000'), 1, 8)) FROM crapass WHERE cdcooper = gr.cdcooper AND nrdconta = gr.nrdconta) nrcpfcgc_nrdconta
             , (SELECT DECODE(inpessoa, 1,
                           to_char(nrcpfcgc, '00000000000'),
                           substr(to_char(nrcpfcgc, '00000000000000'), 1, 8)) FROM crapass WHERE cdcooper = gr.cdcooper AND nrdconta = gr.nrctasoc) nrcpfcgc_nrctasoc
          FROM crapgrp gr
         WHERE gr.cdcooper = rw_cbase.cdcooper
           AND gr.nrdgrupo IN (
              SELECT aux.nrdgrupo
                       FROM crapgrp aux
                      WHERE aux.cdcooper = rw_cbase.cdcooper
                        AND DECODE(aux.inpessoa, 1,
                               to_char(aux.nrcpfcgc, '00000000000'),
                               substr(to_char(aux.nrcpfcgc, '00000000000000'), 1, 8)) =
                               rw_cbase.nrcpfcgc_compara
          )
      )
      SELECT DISTINCT grp.nrdconta
           , grp.nrcpfcgc
           , (SELECT dsnivris FROM crapass WHERE cdcooper = grp.cdcooper AND nrdconta = grp.nrdconta) dsnivris
           , grp.nrdgrupo
           , grp.dsdrisgp
        FROM grupos grp
       WHERE grp.nrcpfcgc_nrdconta <> rw_cbase.nrcpfcgc_compara
         AND grp.nrcpfcgc_nrctasoc <> rw_cbase.nrcpfcgc_compara
         ;
    rw_contas_grupo_economico cr_contas_grupo_economico%ROWTYPE;

    -- Dados dos riscos
    CURSOR cr_tbrisco_central(pr_cdcooper NUMBER
                            , pr_nrdconta NUMBER
                            , pr_dtmvtoan DATE) IS
    SELECT ris.nrctremp
         , ris.cdmodali
         , ris.nrdgrupo
         , ris.dtdrisco
         , RISC0004.fn_traduz_risco(ris.inrisco_inclusao) risco_inclusao
         , RISC0004.fn_traduz_risco(ris.inrisco_rating) risco_rating
         , RISC0004.fn_traduz_risco(ris.inrisco_atraso) risco_atraso
         , RISC0004.fn_traduz_risco(ris.inrisco_agravado) risco_agravado
         , RISC0004.fn_traduz_risco(ris.inrisco_melhora) risco_melhora
         , RISC0004.fn_traduz_risco(ris.inrisco_refin) risco_refin
         , RISC0004.fn_traduz_risco(ris.inrisco_operacao) risco_operacao
         , RISC0004.fn_traduz_risco(ris.inrisco_cpf) risco_cpf
         , RISC0004.fn_traduz_risco(ris.inrisco_grupo) risco_grupo
         , RISC0004.fn_traduz_risco(ris.inrisco_final) risco_final
             , ris.cdmodali as ris_cdmodali
         , decode (ris.cdmodali
                 , 0, 'CTA'
                 , 101, 'CTA'
                 , 201, 'LIM'
                 , 1901, 'LIM'
                 , 299, 'EMP'
                 , 499, 'EMP'
                 , 301, 'DCH'
                 , 302, 'DTI'
                 , 999, 'CTA') tipo_registro
             , epr.idquaprc as epr_idquaprc
             , epr.cdlcremp as epr_cdlcremp
             , epr.cdfinemp as epr_cdfinemp
             , lcr.flgrefin as lcr_flgrefin
             , lcr.flgstlcr as lcr_flgstlcr
             , epr.dtinicio_atraso_refin
      FROM tbrisco_central_ocr ris
     LEFT JOIN crapepr epr ON epr.cdcooper = ris.cdcooper AND epr.nrdconta = ris.nrdconta AND ris.nrctremp = epr.nrctremp
     LEFT JOIN craplcr lcr ON lcr.cdlcremp = epr.cdlcremp AND lcr.cdcooper = ris.cdcooper
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
       AND ris.dtrefere = pr_dtmvtoan
     ORDER BY decode(ris.cdmodali, 0, 0, 1);
    rw_tbrisco_central cr_tbrisco_central%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    -- Parâmetro do arrasto --
    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT t.dstextab
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'USUARI'
       AND t.cdempres = 11
       AND t.cdacesso = 'RISCOBACEN'
       AND t.tpregist = 000;
    rw_tab cr_tab%ROWTYPE;

    vr_tiporegistro VARCHAR(3);

    BEGIN
      pr_des_erro := 'OK';

      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Contas',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      CLOSE cr_dat;

      -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
      CLOSE cr_tab;

      vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), ',', '.'));

      -- Busca dados da conta base
      OPEN cr_base(pr_cdcooper, pr_nrdconta);
      FETCH cr_base INTO rw_cbase;
      CLOSE cr_base;

      -- Percorre contas de mesmo CPF/CNPJ da conta base
      FOR rw_contas_do_titular
       IN cr_contas_do_titular(rw_cbase) LOOP
          FOR rw_tabrisco_central
            IN cr_tbrisco_central(pr_cdcooper
                                        , rw_contas_do_titular.nrdconta
                                 , rw_dat.dtmvtoan) LOOP

                -- trata tipo de registro Refinanciamento (REF)
                IF rw_tabrisco_central.ris_cdmodali IN (4, 3) 
                  OR rw_tabrisco_central.dtinicio_atraso_refin IS NOT NULL 
                  OR (rw_tabrisco_central.lcr_flgrefin = 1 
                      AND rw_tabrisco_central.lcr_flgstlcr = 1) 
                  OR rw_tabrisco_central.epr_cdfinemp IN (13,23,62,63,66,69) THEN
                     vr_tiporegistro := 'REF';
                ELSE
                   vr_tiporegistro := rw_tabrisco_central.tipo_registro;
                END IF;
                -- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_do_titular.nrdconta
                                     , rw_contas_do_titular.nrcpfcgc
                                   , rw_tabrisco_central.nrctremp
                                   , rw_tabrisco_central.risco_inclusao
                                   , rw_tabrisco_central.risco_grupo
                                   , rw_tabrisco_central.risco_rating
                                   , rw_tabrisco_central.risco_atraso
                                   , rw_tabrisco_central.risco_refin
                                   , rw_tabrisco_central.risco_agravado
                                   , rw_tabrisco_central.risco_operacao
                                   , rw_tabrisco_central.risco_cpf
                                   , rw_tabrisco_central.nrdgrupo
                                   , rw_tabrisco_central.risco_melhora
                                   , rw_tabrisco_central.risco_final
                                   , vr_tiporegistro --rw_tabrisco_central.tipo_registro
                                   );

             vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
         END LOOP; -- contratos
      END LOOP; -- contas de mesmo titular

      -- Percorre contas dos grupos econômicos em que o titular da conta base faz parte
      FOR rw_contas_grupo_economico
        IN cr_contas_grupo_economico(rw_cbase) LOOP

        FOR rw_tabrisco_central
            IN cr_tbrisco_central(pr_cdcooper
                                              , rw_contas_grupo_economico.nrdconta
                                 , rw_dat.dtmvtoan) LOOP

                   -- trata tipo de registro Refinanciamento (REF)
                IF rw_tabrisco_central.ris_cdmodali IN (4, 3) 
                  OR rw_tabrisco_central.dtinicio_atraso_refin IS NOT NULL 
                  OR (rw_tabrisco_central.lcr_flgrefin = 1 
                      AND rw_tabrisco_central.lcr_flgstlcr = 1) 
                  OR rw_tabrisco_central.epr_cdfinemp IN (13,23,62,63,66,69) THEN
                     vr_tiporegistro := 'REF';
                ELSE
                   vr_tiporegistro := rw_tabrisco_central.tipo_registro;
                END IF;
                                
                -- Adiciona registro para a conta/contrato no XML de retorno
                pc_monta_reg_conta_xml(pr_retxml
                                     , vr_auxconta
                                     , vr_dscritic
                                     , rw_contas_grupo_economico.nrdconta
                                     , rw_contas_grupo_economico.nrcpfcgc
                                   , rw_tabrisco_central.nrctremp
                                   , rw_tabrisco_central.risco_inclusao
                                   , rw_tabrisco_central.risco_grupo
                                   , rw_tabrisco_central.risco_rating
                                   , rw_tabrisco_central.risco_atraso
                                   , rw_tabrisco_central.risco_refin
                                   , rw_tabrisco_central.risco_agravado
                                   , rw_tabrisco_central.risco_operacao
                                   , rw_tabrisco_central.risco_cpf
                                   , rw_tabrisco_central.nrdgrupo
                                   , rw_tabrisco_central.risco_melhora
                                   , rw_tabrisco_central.risco_final
                                   , vr_tiporegistro --rw_tabrisco_central.tipo_registro
                                   );

               vr_auxconta := vr_auxconta + 1; -- Para controle da estrutura do XML
         END LOOP; -- contratos
      END LOOP; -- contas do grupo econômico

      -- Busca o risco da última central de riscos (último fechamento)
      vr_risco_ult_central := RISC0004.fn_busca_risco_ult_central(pr_cdcooper
                                                       , pr_nrdconta
                                                       , rw_dat.dtultdma
                                                       , vr_valor_arrasto);
      vr_data_risco_final := RISC0004.fn_busca_data_risco(pr_cdcooper
                                               , pr_nrdconta
                                               , rw_dat.dtmvtoan
                                               , vr_valor_arrasto);

      -- Adiciona registro com dados da central de riscos no XML de retorno
      pc_monta_reg_central_risco(pr_retxml
                            , vr_dscritic
                            , RISC0004.fn_traduz_risco(vr_risco_ult_central)
                            , TO_CHAR(vr_data_risco_final, 'DD/MM/YYYY')
                            , CASE WHEN vr_data_risco_final IS NOT NULL THEN TO_CHAR(rw_dat.dtmvtolt-vr_data_risco_final) ELSE '' END
                            , rw_cbase.inrisctl
                            , rw_cbase.dtrisctl);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;

      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_dscritic := vr_dscritic;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_dados_risco;

  /* Busca contratos de acordos do Cooperado */
  PROCEDURE pc_busca_ctr_acordos(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                                ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK

  BEGIN

    /* .............................................................................

    Programa: pc_busca_ctr_acordos
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem de contratos de acordos e riscos(Daniel AMcom).

    Alteracoes:
    ..............................................................................*/

    DECLARE
      -- >>> CURSORES <<< --

      -- Consulta de contratos de acordos ativos
      CURSOR cr_acordo(pr_cdcooper tbrecup_acordo.cdcooper%TYPE
                      ,pr_nrdconta tbrecup_acordo.nrdconta%TYPE
                      ,pr_cdsituacao tbrecup_acordo.cdsituacao%TYPE) IS
        SELECT tbrecup_acordo.cdcooper AS cdcooper
              ,tbrecup_acordo_contrato.nracordo AS nracordo
              ,tbrecup_acordo.nrdconta AS nrdconta
              ,tbrecup_acordo_contrato.nrctremp AS nrctremp
              ,DECODE(tbrecup_acordo_contrato.cdorigem,1,'Estouro de Conta',2,'Empréstimo',3,'Empréstimo','Inexistente') AS dsorigem
          FROM tbrecup_acordo_contrato
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_contrato.nracordo
         WHERE tbrecup_acordo.cdcooper = pr_cdcooper
           AND tbrecup_acordo.nrdconta = pr_nrdconta
           AND tbrecup_acordo.cdsituacao = pr_cdsituacao;

      rw_acordo cr_acordo%ROWTYPE;

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador INTEGER := 0;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'acordos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_acordo IN cr_acordo(pr_cdcooper   => vr_cdcooper
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_cdsituacao => 1) LOOP
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordos', pr_posicao => 0, pr_tag_nova => 'acordo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nracordo', pr_tag_cont => TO_CHAR(rw_acordo.nracordo), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'dsorigem', pr_tag_cont => TO_CHAR(rw_acordo.dsorigem), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'acordo',   pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => GENE0002.fn_mask_contrato(rw_acordo.nrctremp), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contador), pr_des_erro => vr_dscritic);


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_OCORRENCIAS - pc_busca_ctr_acordos: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_ctr_acordos;
  
  PROCEDURE pc_consulta_preju_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_preju_cc
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas (AMcom)
    Data     : Junho/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Consulta para verificar se a conta corrente está em prejuízo
                 e listar os detalhes na tela ATENDA/OCORRÊNCIAS/PREJUÍZOS.

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/
    
    -- CURSORES --    
    
    --> Consultar se já houve prejuizo nessa conta
    CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS 
      SELECT t.dtinclusao,
             t.qtdiaatr,
             t.vlpgprej,
             t.vlrabono,
             t.vljuprej,
             t.vlsdprej,
             t.vldivida_original
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;    
    
    --> Consultar crapass
    CURSOR cr_crapass(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                      pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS 
      SELECT c.inprejuz
        FROM crapass c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.inprejuz = 1;
    rw_crapass cr_crapass%ROWTYPE;  
    
    --> Consultar crapsld
    CURSOR cr_crapsld(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                      pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS 
      SELECT c.vliofmes
        FROM crapsld c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;  
    
    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper crapdat.cdcooper%TYPE) IS
      SELECT dat.dtmvtolt
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_qtdiaatr NUMBER(10);
    vr_qtdiapre NUMBER(10);
    vr_inprejuz VARCHAR2(1);
    vr_qttotatr NUMBER(10);
    vr_saldodev NUMBER(25,2);
    vr_iof      NUMBER(25,2);

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    
    -----> PROCESSAMENTO PRINCIPAL <-----
    
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    vr_qtdiaatr := 0;
    vr_qtdiapre := 0;
    vr_inprejuz := 'N';
    vr_qttotatr := 0;
    vr_saldodev := 0; 
    
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);

    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%FOUND THEN 
      CLOSE cr_crapass;
      
      vr_inprejuz := 'S';
       
      OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
                       
      FETCH cr_prejuizo INTO rw_prejuizo;
       
      IF cr_prejuizo%FOUND THEN 
          
        CLOSE cr_prejuizo;
          
        -- Faz todo o processamento dos detalhes do prejuízo --
        -- Diego Simas (AMcom)         
        -- Dias em atraso   --
        -- Dias em prejuízo --  
          
        OPEN cr_dat(pr_cdcooper => pr_cdcooper);
                        
        FETCH cr_dat INTO rw_dat;
       
        IF cr_dat%FOUND THEN 
          CLOSE cr_dat;
          -- Dias em Atraso   --
          vr_qtdiaatr := ((rw_dat.dtmvtolt - rw_prejuizo.dtinclusao) + rw_prejuizo.qtdiaatr); 
          -- Dias em Prejuízo --
          vr_qtdiapre := (rw_dat.dtmvtolt - rw_prejuizo.dtinclusao);              
        ELSE
          CLOSE cr_dat;             
        END IF;
        
        -- Dias Total Atraso
        vr_qttotatr := vr_qtdiaatr + vr_qtdiapre; 

        OPEN cr_crapsld(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta); 
        FETCH cr_crapsld INTO rw_crapsld;
        
        vr_iof := 0;
        
        IF cr_crapsld%FOUND THEN 
          CLOSE cr_crapsld;
          vr_iof := rw_crapsld.vliofmes;
          vr_saldodev := ((rw_prejuizo.vlpgprej + rw_prejuizo.vlrabono) - (rw_prejuizo.vljuprej + rw_prejuizo.vlsdprej + rw_crapsld.vliofmes));          
        ELSE          
          CLOSE cr_crapsld;     
          vr_saldodev := ((rw_prejuizo.vlpgprej + rw_prejuizo.vlrabono) - (rw_prejuizo.vljuprej + rw_prejuizo.vlsdprej));        
        END IF;
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'dttransf', -- Transferência
                               pr_tag_cont => to_char(rw_prejuizo.dtinclusao, 'DD/MM/YYYY'),
                               pr_des_erro => vr_dscritic);
          
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vltrapre', -- Valor Transferido para Prejuízo
                               pr_tag_cont => rw_prejuizo.vldivida_original,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vlsdprej', -- Saldo Atual
                               pr_tag_cont => rw_prejuizo.vlsdprej,
                               pr_des_erro => vr_dscritic);                                                       
          
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'qtdiaatr', -- Dias em atraso
                               pr_tag_cont => vr_qtdiaatr,
                               pr_des_erro => vr_dscritic);
                                 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'qtdiapre', -- Dias em prejuízo
                               pr_tag_cont => vr_qtdiapre,
                               pr_des_erro => vr_dscritic);  
         
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'qtdittat', -- Dias total atraso
                               pr_tag_cont => vr_qttotatr,
                               pr_des_erro => vr_dscritic);   
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vljuprej', -- Juros Remuneratório
                               pr_tag_cont => rw_prejuizo.vljuprej,
                               pr_des_erro => vr_dscritic);
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'valoriof', -- IOF
                               pr_tag_cont => vr_iof,
                               pr_des_erro => vr_dscritic);                                                               
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vlpagpre', -- Valor pago prejuízo
                               pr_tag_cont => rw_prejuizo.vlpgprej,
                               pr_des_erro => vr_dscritic);                    
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vlabopre', -- Valor abono prejuízo
                               pr_tag_cont => rw_prejuizo.vlrabono,
                               pr_des_erro => vr_dscritic);  
                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_qtregist,
                               pr_tag_nova => 'vlslddev', -- Saldo Devedor
                               pr_tag_cont => abs(least(vr_saldodev,0)),
                               pr_des_erro => vr_dscritic);  
         
      ELSE
        CLOSE cr_prejuizo;          
      END IF;       
    ELSE
      CLOSE cr_crapass;       
    END IF;
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_qtregist,
                           pr_tag_nova => 'inprejuz', -- Indicador de Prejuízo
                           pr_tag_cont => vr_inprejuz,
                           pr_des_erro => vr_dscritic);  

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_preju_cc --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_preju_cc; 

END TELA_ATENDA_OCORRENCIAS;
/
