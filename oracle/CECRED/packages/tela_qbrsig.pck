CREATE OR REPLACE PACKAGE CECRED.tela_qbrsig IS
  PROCEDURE pc_con_regra_qbrsig(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

  PROCEDURE pc_con_historico_qbrsig(pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico Ailos
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_salvar_historico_qbrsig(pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico Ailos
                                      ,pr_cdhisrec IN craphis.cdhisrec%TYPE --> Codigo do historico receita
                                      ,pr_cdestsig IN craphis.cdestsig%TYPE --> Codigo da regra de quebra de sigilo
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_con_conta_qbrsig(pr_cdcooper IN crapass.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_con_quebra_qbrsig(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero seq de quebra do sigilo
                                ,pr_idsitqbr IN tbjur_qbr_sig_extrato.idsitqbr%TYPE --> Situacao a ser pesquisada
                                ,pr_iniregis IN NUMBER                --> Controle de paginacao
                                ,pr_qtregpag IN NUMBER                --> Controle de paginacao
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_quebra_sigilo(pr_cdcoptel IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_nrdconta IN VARCHAR2               --> Numero da conta
                            ,pr_dtiniper IN VARCHAR2               --> Data de inicio do periodo
                            ,pr_dtfimper IN VARCHAR2               --> Data de fim do periodo
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_gera_arquivo(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_atualiza_info_qbrsig(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                                   ,pr_nrseqlcm IN tbjur_qbr_sig_extrato.nrseqlcm%TYPE --> Numero sequencial da tabela LCM
                                   ,pr_cdbandep IN tbjur_qbr_sig_extrato.cdbandep%TYPE --> Banco depositante
                                   ,pr_cdagedep IN tbjur_qbr_sig_extrato.cdagedep%TYPE --> Agencia depositante
                                   ,pr_nrctadep IN tbjur_qbr_sig_extrato.nrctadep%TYPE --> Conta depositante
                                   ,pr_nrcpfcgc IN tbjur_qbr_sig_extrato.nrcpfcgc%TYPE --> CPF
                                   ,pr_nmprimtl IN tbjur_qbr_sig_extrato.nmprimtl%TYPE --> Nome
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_reprocessar_quebra(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_quebra_sigilo_job(pr_cdcoptel IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                ,pr_nrdconta IN VARCHAR2               --> Numero da conta
                                ,pr_dtiniper IN VARCHAR2               --> Data de inicio do periodo
                                ,pr_dtfimper IN VARCHAR2               --> Data de fim do periodo
                                ,pr_cdoperad IN VARCHAR2);             --> Codigo do operador
END tela_qbrsig;
/
/*
Alterações:

02/07/2019 RITM0024195 Na rotina pc_carrega_arq_origem_destino, estrutura 29, incluídas as informações de
           banco, agência e conta do cooperado (Carlos)
           
03/07/2019 RITM0024196 Na rotina pc_carrega_arq_origem_destino, estrutura 18, verificado o tipo de pessoa
           através do tamanho do documento (Carlos)
           
23/08/2019 RITM0032523 Correçao da busca de teds e correção do filtro de docs para que os lançamentos constem
           no mesmo para que sejam atualizados manualmente (Carlos)

06/09/2019 RITM0034490 Inclusão de nova regra, para identificar lançamentos de salário (Carlos)
*/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_qbrsig IS
  vr_idreprocessar NUMBER(1) := 0;

  -- Exception
  vr_erros EXCEPTION;
  vr_dacaojud  crapicf.dacaojud%TYPE := 'DESC_ACAO_TESTE';
  vr_idicfjud  NUMBER(1);

  /* Declaracao de tipos */
  -- Dados de historico (de-para Ailos x Receita)
  TYPE typ_rec_historico IS RECORD(cdhisrec craphis.cdhisrec%TYPE
                                  ,cdestsig craphis.cdestsig%TYPE);  

  TYPE typ_tbhistorico IS TABLE OF typ_rec_historico INDEX BY PLS_INTEGER;
  vr_tbhistorico typ_tbhistorico;

  -- Dados de contas que serao investigadas
  TYPE typ_rec_conta_investigar IS RECORD (cdcooper crapass.cdcooper%TYPE
                                          ,nrdconta crapass.nrdconta%TYPE
                                          ,nrcpfcgc crapass.nrcpfcgc%TYPE
                                          ,dtiniper DATE
                                          ,dtfimper DATE);

  TYPE typ_tbconta_investigar IS TABLE OF typ_rec_conta_investigar INDEX BY VARCHAR2(30);
  vr_tbconta_investigar typ_tbconta_investigar;

  -- Dados da Agencia
  TYPE typ_rec_arq_agencia IS RECORD (cddbanco VARCHAR2(3)    /*  1 - Numero do Banco      */
                                     ,cdagenci INTEGER        /*  2 - Numero da Agencia    */
                                     ,nmextage VARCHAR2(35)   /*  3 - Nome da Agencia      */
                                     ,dsendcop VARCHAR2(500)  /*  4 - Endereco da Agencia  */
                                     ,nmcidade VARCHAR2(15)   /*  5 - Cidade               */  
                                     ,cdufdcop VARCHAR2(2)    /*  6 - UF                   */
                                     ,nmdopais VARCHAR2(6)    /*  7 - Pais                 */
                                     ,nrcepend NUMBER(15)     /*  8 - Cep                  */
                                     ,nrtelefo VARCHAR2(30)   /*  9 - Telefone PA          */
                                     ,dtabertu VARCHAR2(10)   /* 10 - Data Abertura PA     */ 
                                     ,dtfecham VARCHAR2(10)); /* 11 - Data Fechamento PA   */

  TYPE typ_tbarq_agencias IS TABLE OF typ_rec_arq_agencia INDEX BY VARCHAR2(10);
  vr_tbarq_agencias typ_tbarq_agencias;
  
  -- Dados da conta
  TYPE typ_rec_arq_conta IS RECORD (cddbanco VARCHAR2(3)    /* 1 - Numero do Banco */
                                   ,cdagenci INTEGER        /* 2 - Numero da Agencia */
                                   ,nrdconta INTEGER        /* 3 - Numero da Conta */
                                   ,tpdconta VARCHAR2(1)    /* 4 - Tipo da Conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros */
                                   ,dtabertu VARCHAR2(10)   /* 5 - Data de Abertura da Conta */  
                                   ,dtfecham VARCHAR2(10)   /* 6 - Data de Encerramento da Conta */
                                   ,tpmovcta VARCHAR2(1));  /* 7 - Tipo de Movimentação da Conta   
                                                                   1 = É uma conta investigada e houve movimentaçao bancária no período de afastamento.
                                                                   2 = É uma conta investigada, porém nao houve movimentaçao no período.
                                                                   3 = Quando nao for uma conta investigada, 
                                                                      porém trata-se de conta do mesmo banco que efetuou transaçao bancária com uma conta investigada. */
  TYPE typ_tbarq_contas IS TABLE OF typ_rec_arq_conta INDEX BY VARCHAR2(15);
  vr_tbarq_contas typ_tbarq_contas;
  
  -- Dados dos Titulares para escrever no arquivo
  TYPE typ_rec_arq_titular IS RECORD (cddbanco VARCHAR2(3)    /* 1 - Codigo do Banco */
                                     ,cdagenci INTEGER        /* 2 - Numero da Agencia */
                                     ,nrdconta INTEGER        /* 3 - Numero da Conta */
                                     ,tpdconta VARCHAR2(1)    /* 4 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros */
                                     ,dsvincul VARCHAR2(1)    /* 5 - Vinculo: T = Titular, 
                                                                              1 = 1o. Co-titular, 
                                                                              2 = 2o. Co-titular e assim consecutivamente; ou 
                                                                              R = Representante, 
                                                                              L = Representante Legal, 
                                                                              P = Procurador, 
                                                                              O = Outros */
                                     ,flafasta INTEGER        /* 6 - Indica se a pessoa, física ou jurídica, teve ou não o sigilo bancário afastado (conforme determinação judicial). 
                                                                     0 = Não teve o sigilo afastado. 1 = Teve o sigilo afastado. */
                                     ,inpessoa INTEGER        /* 7 - Tipo de pessoa: 1=Pessoa Fisica; 2=Pessoa Juridica */
                                     ,nrcpfcgc NUMBER(25)     /* 8 - CPF */
                                     ,nmprimtl VARCHAR2(80)   /* 9 - Nome Completo */
                                     ,tpdocttl VARCHAR2(50)   /* 10 - Tipo de Documento */
                                     ,nrdocttl VARCHAR2(20)   /* 11 - Numero do Documento */
                                     ,dsendere VARCHAR2(80)   /* 12 - Endereço */
                                     ,nmcidade VARCHAR2(40)   /* 13 - Cidade */
                                     ,ufendere VARCHAR2(2)    /* 14 - UF */
                                     ,nmdopais VARCHAR2(40)   /* 15 - País */
                                     ,nrcepend NUMBER(15)     /* 16 - CEP */
                                     ,nrtelefo VARCHAR2(20)   /* 17 - Telefone */
                                     ,vlrrendi VARCHAR2(14)   /* 18 - Renda Informada */
                                     ,dtultalt VARCHAR2(10)   /* 19 - Data Atualizacao Renda */
                                     ,dtadmiss VARCHAR2(10)   /* 20 - Data Abertura da conta */ 
                                     ,dtdemiss VARCHAR2(10)); /* 21 - Data Encerramento da Conta */

  TYPE typ_tbarq_titulares IS TABLE OF typ_rec_arq_titular INDEX BY VARCHAR2(30);
  vr_tbarq_titulares typ_tbarq_titulares;
  
  -- Dados do Extrato para escrever no arquivo
  TYPE typ_rec_arq_extrato IS RECORD (idseqlcm NUMBER         /*  1 - Sequencial */
                                     ,cddbanco VARCHAR2(3)    /*  2 - Codigo do Banco */
                                     ,cdagenci INTEGER        /*  3 - Agencia */ 
                                     ,nrdconta INTEGER        /*  4 - Conta */
                                     ,tpdconta VARCHAR2(1)    /*  5 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros. */
                                     ,dtmvtolt VARCHAR2(10)   /*  6 - Data Lancamento */
                                     ,nrdocmto VARCHAR2(20)   /*  7 - Documento */
                                     ,dshistor VARCHAR2(50)   /*  8 - Descricao Historico */ 
                                     ,tplancto VARCHAR2(3)    /*  9 - Tipo de Lancamento  */
                                     ,vllanmto VARCHAR2(16)   /* 10 - Valor Lancamento */
                                     ,indebcre VARCHAR2(1)    /* 11 - Natureza do Lancamento */
                                     ,vlrsaldo VARCHAR2(16)   /* 12 - Valor Saldo CC */
                                     ,sddebcre VARCHAR2(1)    /* 13 - Natureza do Saldo */
                                     ,localtra VARCHAR2(80)); /* 14 - Local da Transacao */ 

  TYPE typ_tbarq_extrato IS TABLE OF typ_rec_arq_extrato INDEX BY PLS_INTEGER;
  vr_tbarq_extrato typ_tbarq_extrato;
  
  -- Dados de Origem e Destino para escrever no arquivo
  TYPE typ_rec_arq_origem_destino IS RECORD (idseqarq NUMBER          /*  1 - Sequencial  Arquivo */
                                            ,idseqlcm NUMBER          /*  2 - Sequencial */ 
                                            ,vllanmto VARCHAR2(16)    /*  3 - Valor Lancamento */
                                            ,nrdocmto VARCHAR2(20)    /*  4 - Nro. Documento */
                                            ,cdbandep VARCHAR2(3)     /*  5 - Banco OD */  
                                            ,cdagedep INTEGER         /*  6 - Agencia OD */ 
                                            ,nrctadep VARCHAR2(20)    /*  7 - Conta   OD */
                                            ,tpdconta VARCHAR2(1)     /*  8 - Tipo de conta: 1=conta corrente, 2=poupança, 3=investimento, 4=outros.*/
                                            ,inpessoa VARCHAR2(1)     /*  9 - Tipo de Pessoa OD */
                                            ,nrcpfcgc NUMBER(25)      /* 10 - CPF/CNPJ OD */
                                            ,nmprimtl VARCHAR2(80)    /* 11 - Nome OD */  
                                            ,tpdocttl VARCHAR2(50)    /* 12 - Nome Doc Identificacao OD */
                                            ,nrdocttl VARCHAR2(20)    /* 13 - Nro. Doc Identificacao OD */
                                            ,dscodbar VARCHAR2(100)   /* 14 - Codigo Barra  */
                                            ,nmendoss VARCHAR2(80)    /* 15 - Nome Endossante Cheque */ 
                                            ,docendos VARCHAR2(50)    /* 16 - Doc Endossante Cheque   */
                                            ,idsitide VARCHAR2(1)     /* 17 - Situacao Identificacao  */
                                            ,dsobserv VARCHAR2(250)); /* 18 - Observacao  */ 

  TYPE typ_tbarq_origem_destino IS TABLE OF typ_rec_arq_origem_destino INDEX BY PLS_INTEGER;
  vr_tbarq_origem_destino typ_tbarq_origem_destino;

  -- Dados do Erro
  TYPE typ_rec_erro IS RECORD (dsorigem VARCHAR(100)
                              ,dserro   VARCHAR2(32000));

  TYPE typ_tberro IS TABLE OF typ_rec_erro INDEX BY PLS_INTEGER;
  vr_tberro typ_tberro;
  
  -- Dados de Cheques ICFJUD para escrever no arquivo
  TYPE typ_rec_arq_cheques_icfjud IS RECORD (dtinireq DATE              /*  1 - Data da Solicitação */
                                            ,cdbanreq NUMBER            /*  2 - Banco Requisitado */ 
                                            ,cdagereq NUMBER            /*  3 - Agencia Requisitada */
                                            ,nrctareq NUMBER            /*  4 - Nr. da conta requisitada */
                                            ,intipreq NUMBER            /*  5 - Tipo de Requisição */
                                            ,dsdocmc7 VARCHAR2(50) );   /*  6 - dsdocmc7 do cheque requisitado */  

  -- Dados de Cheques ICFJUD
  TYPE typ_tbarq_cheques_icfjud IS TABLE OF typ_rec_arq_cheques_icfjud INDEX BY PLS_INTEGER;
  vr_tbarq_cheques_icfjud typ_tbarq_cheques_icfjud;
  /* Fim declaracao de tipos */
  
  /* Rotinas tela QBRSIG */
  PROCEDURE pc_con_regra_qbrsig(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_regra
        Sistema : CECRED
        Sigla   : TELA_QBRSIG
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar regras de quebra de sigilo

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);


      --> variaveis auxiliares
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);

      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_prm_qbrsig IS
        SELECT qbr.cdestsig
             , qbr.nmestsig
          FROM tbjur_prm_quebra_sigilo qbr
         ORDER 
            BY qbr.cdestsig;

      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;

      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');

      FOR rw_prm_qbrsig IN cr_prm_qbrsig LOOP
        BEGIN
          pc_escreve_xml( '<estsig>
                           <cdestsig>'|| rw_prm_qbrsig.cdestsig ||'</cdestsig>'||
                          '<nmestsig>'|| rw_prm_qbrsig.nmestsig ||'</nmestsig>'||
                          '</estsig>');
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de regras'||': '||SQLERRM;
          RAISE vr_exc_erro;
        END;
      END LOOP;

      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

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
  END pc_con_regra_qbrsig;
  
  PROCEDURE pc_con_historico_qbrsig(pr_cdhistor IN craphis.cdhistor%TYPE
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_regra
        Sistema : CECRED
        Sigla   : TELA_QBRSIG
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar regras de quebra de sigilo

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);


      --> variaveis auxiliares
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);

      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_prm_craphis IS
        SELECT his.cdhistor
             , his.dsexthst
             , his.cdhisrec
             , his.cdestsig
             , decode(his.cdestsig,NULL,' ',his.cdestsig||'-'||qbr.nmestsig) nmestsig
          FROM tbjur_prm_quebra_sigilo qbr
             , craphis his
         WHERE qbr.cdestsig (+) = his.cdestsig
           AND his.cdcooper     = 3
           AND (his.cdhisrec     IS NOT NULL OR pr_cdhistor IS NOT NULL)
           AND his.cdhistor     = nvl(pr_cdhistor,his.cdhistor)
         ORDER
            BY his.cdhistor;

      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;

      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');

      FOR rw_prm_craphis IN cr_prm_craphis LOOP
        BEGIN
          pc_escreve_xml( '<histor>
                           <cdhistor>'|| rw_prm_craphis.cdhistor ||'</cdhistor>'||
                          '<dsexthst>'|| rw_prm_craphis.dsexthst ||'</dsexthst>'||
                          '<cdhisrec>'|| rw_prm_craphis.cdhisrec ||'</cdhisrec>'||
                          '<cdestsig>'|| rw_prm_craphis.cdestsig ||'</cdestsig>'||
                          '<nmestsig>'|| rw_prm_craphis.nmestsig ||'</nmestsig>'||
                          '</histor>');
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de regras'||': '||SQLERRM;
          RAISE vr_exc_erro;
        END;
      END LOOP;

      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

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
  END pc_con_historico_qbrsig;
  
  PROCEDURE pc_salvar_historico_qbrsig(pr_cdhistor IN craphis.cdhistor%TYPE
                                      ,pr_cdhisrec IN craphis.cdhisrec%TYPE
                                      ,pr_cdestsig IN craphis.cdestsig%TYPE
                                      ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_regra
        Sistema : CECRED
        Sigla   : TELA_QBRSIG
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar regras de quebra de sigilo

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);


      --> variaveis auxiliares
      
      ---------->> CURSORES <<--------
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        UPDATE craphis c
           SET c.cdhisrec = pr_cdhisrec
             , c.cdestsig = pr_cdestsig
         WHERE c.cdhistor = pr_cdhistor;
        
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPHIS - '||SQLERRM;
          
          RAISE vr_exc_erro;
      END;
  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

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
  END pc_salvar_historico_qbrsig;
  
  PROCEDURE pc_con_conta_qbrsig(pr_cdcooper IN crapass.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_regra
        Sistema : CECRED
        Sigla   : TELA_QBRSIG
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar regras de quebra de sigilo

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);


      --> variaveis auxiliares
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);

      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_crapass IS
        SELECT ass.nmprimtl
             , gene0002.fn_mask_cpf_cnpj(ass.nrcpfcgc, ass.inpessoa) nrcpfcgc
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;

      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;

      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');

      FOR rw_crapass IN cr_crapass LOOP
        BEGIN
          pc_escreve_xml('<conta>
                          <nmprimtl>'|| rw_crapass.nmprimtl ||'</nmprimtl>'||
                         '<nrcpfcgc>'|| rw_crapass.nrcpfcgc ||'</nrcpfcgc>'||
                         '</conta>');
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de regras'||': '||SQLERRM;
          RAISE vr_exc_erro;
        END;
      END LOOP;

      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

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
  END pc_con_conta_qbrsig;

  PROCEDURE pc_con_quebra_qbrsig(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero seq de quebra do sigilo
                                ,pr_idsitqbr IN tbjur_qbr_sig_extrato.idsitqbr%TYPE --> Situacao a ser pesquisada
                                ,pr_iniregis IN NUMBER                --> Controle de paginacao
                                ,pr_qtregpag IN NUMBER                --> Controle de paginacao
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_con_quebra_qbrsig
        Sistema : CECRED
        Sigla   : TELA_QBRSIG
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar regras de quebra de sigilo

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      --> variaveis auxiliares
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);
      vr_idquebra        NUMBER := 0;
      
      vr_qtregist        NUMBER := 0;

      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_quebra IS
        SELECT t.cdcooper
             , trim(gene0002.fn_mask(t.nrdconta,'zzzz.zzz-z')) nrdconta
             , gene0002.fn_mask_cpf_cnpj(ass.nrcpfcgc,ass.inpessoa) nrcpfcgc
             , t.dtiniper
             , t.dtfimper
             , t.cdoperad
             , t.idsitqbr
             , ass.nmprimtl
          FROM crapass ass
             , tbjur_quebra_sigilo t
         WHERE ass.cdcooper = t.cdcooper
           AND ass.nrdconta = t.nrdconta
           AND t.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
      
      CURSOR cr_lancamentos IS
        SELECT lcm.dtmvtolt
             , his.indebcre||'-'||lcm.cdhistor cdhistor
             , lcm.vllanmto
             , ext.idsitqbr||'-'||CASE ext.idsitqbr WHEN 0 THEN 'Pendente'
                                                    WHEN 1 THEN 'Informacoes encontradas'
                                                    WHEN 2 THEN 'Informacoes encontradas em regra nao parametrizada'
                                                    WHEN 3 THEN 'DOC, informacoes devem ser atualizadas manualmente'
                                                    WHEN 4 THEN 'Informacoes nao encontradas nas regras existentes'
                                                    WHEN 5 THEN 'Registro incluido para busca das informacos no ICFJUD'
                                                    WHEN 6 THEN 'Informacoes atualizadas manualmente'
                                                    WHEN 7 THEN 'Erro na busca das informacoes'
                                                    WHEN 8 THEN 'Parametrizacao Ailos x Receita inexistente'
                                                    ELSE 'Situacao nao identificada'
                                                    END idsitqbr
             , ext.nrseqlcm
             , ext.nrdocmto
             , ext.cdbandep
             , trim(ban.nmextbcc) nmextbcc
             , ext.cdagedep
             , ext.nrctadep
             , ext.nrcpfcgc
             , ext.nmprimtl
             , ext.dsobsqbr
          FROM crapban               ban
             , craphis               his
             , craplcm               lcm
             , tbjur_qbr_sig_extrato ext
         WHERE ban.cdbccxlt (+) = ext.cdbandep
           AND his.cdcooper = lcm.cdcooper
           AND his.cdhistor = lcm.cdhistor
           AND lcm.progress_recid = ext.nrseqlcm
           AND ext.idsitqbr = decode(pr_idsitqbr,0,ext.idsitqbr,pr_idsitqbr)
           AND ext.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
         ORDER
            BY lcm.dtmvtolt
             , lcm.progress_recid;

      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;

      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');

      FOR rw_quebra IN cr_quebra LOOP
        vr_idquebra := 1;

        BEGIN
          pc_escreve_xml('<quebra>
                          <cdcooper>'||rw_quebra.cdcooper||'</cdcooper>'||
                         '<nrdconta>'||rw_quebra.nrdconta||'</nrdconta>'||
                         '<nrcpfcgc>'||rw_quebra.nrcpfcgc||'</nrcpfcgc>'||
                         '<dtiniper>'||to_char(rw_quebra.dtiniper,'DD/MM/RRRR')||'</dtiniper>'||
                         '<dtfimper>'||to_char(rw_quebra.dtfimper,'DD/MM/RRRR')||'</dtfimper>'||
                         '<cdoperad>'||rw_quebra.cdoperad||'</cdoperad>'||
                         '<idsitqbr>'||rw_quebra.idsitqbr||'</idsitqbr>'||
                         '<nmprimtl>'||rw_quebra.nmprimtl||'</nmprimtl>'||
                         '</quebra>');
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de quebras'||': '||SQLERRM;
          RAISE vr_exc_erro;
        END;
      END LOOP;
      
      IF vr_idquebra = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Quebra nao existente!';

        RAISE vr_exc_erro;
      END IF;
      
      FOR rw_lancamentos IN cr_lancamentos LOOP
        vr_qtregist:= nvl(vr_qtregist,0) + 1;

        --Sem Pagina
        IF (vr_qtregist >= pr_iniregis AND
            vr_qtregist < (pr_iniregis + pr_qtregpag)) THEN
          BEGIN
            pc_escreve_xml('<lancamentos>
                            <dtmvtolt>'||to_char(rw_lancamentos.dtmvtolt,'DD/MM/RRRR')||'</dtmvtolt>'||
                           '<cdhistor>'||rw_lancamentos.cdhistor||'</cdhistor>'||
                           '<vllanmto>'||rw_lancamentos.vllanmto||'</vllanmto>'||
                           '<idsitqbr>'||rw_lancamentos.idsitqbr||'</idsitqbr>'||
                           '<nrseqlcm>'||rw_lancamentos.nrseqlcm||'</nrseqlcm>'||
                           '<nrdocmto>'||rw_lancamentos.nrdocmto||'</nrdocmto>'||
                           '<cdbandep>'||rw_lancamentos.cdbandep||'</cdbandep>'||
                           '<nmextbcc>'||rw_lancamentos.nmextbcc||'</nmextbcc>'||
                           '<cdagedep>'||rw_lancamentos.cdagedep||'</cdagedep>'||
                           '<nrctadep>'||rw_lancamentos.nrctadep||'</nrctadep>'||
                           '<nrcpfcgc>'||rw_lancamentos.nrcpfcgc||'</nrcpfcgc>'||
                           '<nmprimtl>'||rw_lancamentos.nmprimtl||'</nmprimtl>'||
                           '<dsobsqbr>'||rw_lancamentos.dsobsqbr||'</dsobsqbr>'||
                           '</lancamentos>');
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao montar tabela de lancamentos'||': '||SQLERRM;
            RAISE vr_exc_erro;
          END;
        END IF;
      END LOOP;

      pc_escreve_xml('<registros>
                      <qtregist>'||vr_qtregist||'</qtregist>'||
                     '</registros>');

      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

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
  END pc_con_quebra_qbrsig;
  /* Fim tela QBRSIG */
  
  --Abertura dos arquivos
  PROCEDURE pc_abre_arquivo(pr_dirarquivo  IN VARCHAR2
                           ,pr_nmarquivo   IN VARCHAR2
                           ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Tenta abrir o arquivo de log em modo append
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dirarquivo --> Diretório do arquivo
                            ,pr_nmarquiv => pr_nmarquivo  --> Nome do arquivo
                            ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => pr_ind_arqlog --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro); --> Descricao do erro
    IF vr_des_erro IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_abre_arquivo;
  
  -- Escrever no arquivo
  PROCEDURE pc_escreve_linha_arq(pr_dirarquivo  IN VARCHAR2
                                ,pr_nmarquivo   IN VARCHAR2
                                ,pr_texto_linha IN VARCHAR2
                                ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Adiciona a linha de log
    BEGIN
      gene0001.pc_escr_linha_arquivo(pr_ind_arqlog,pr_texto_linha);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao escrever no arquivo <' || pr_dirarquivo || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_escreve_linha_arq;
  
  -- Fechar arquivo
  PROCEDURE pc_fechar_arquivo(pr_dirarquivo  IN VARCHAR2
                             ,pr_nmarquivo   IN VARCHAR2
                             ,pr_ind_arqlog  IN OUT UTL_FILE.file_type) IS
    vr_exc_saida EXCEPTION;
    vr_des_erro   VARCHAR2(4000);
  BEGIN
    -- Libera o arquivo
    BEGIN
      gene0001.pc_fecha_arquivo(pr_ind_arqlog);
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro
        vr_des_erro := 'Problema ao fechar o arquivo <' || pr_dirarquivo || '/' || pr_nmarquivo || '>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
      gene0001.pc_print(to_char(sysdate, 'hh24:mi:ss') || ' - ' ||
                        'BTCH0001.pc_gera_log_batch --> ' || vr_des_erro);
  END pc_fechar_arquivo;

  --Carregar historico parametrizados com historico receita
  PROCEDURE pc_carregar_historico_de_para IS
    CURSOR cr_historico IS
      SELECT c.cdhistor
           , c.cdhisrec
           , c.cdestsig
        FROM craphis c
       WHERE c.cdcooper = 3
         AND c.cdhisrec IS NOT NULL;
  BEGIN
    FOR rw_historico IN cr_historico LOOP
      vr_tbhistorico(rw_historico.cdhistor).cdhisrec := rw_historico.cdhisrec;
      vr_tbhistorico(rw_historico.cdhistor).cdestsig := rw_historico.cdestsig;
    END LOOP;
  END pc_carregar_historico_de_para;
  
  --Carregar agencias das contas envolvidas na quebra
  PROCEDURE pc_carrega_arq_agencias(pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE) IS
    
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_cta_investigar VARCHAR2(30);
    
    -- Buscar os dados das agencias que estão sendo investigadas
    CURSOR cr_agencias (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT age.cdcooper
           , age.cdagenci
           , age.dtabertu
           , age.nrtelvoz
           , ass.inpessoa
        FROM crapass ass
           , crapage age
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    -- Buscar os dados das agencias dos avalistas dessa conta
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
           , age.cdagenci
           , age.dtabertu
           , age.nrtelvoz
        FROM crapass ass
           , crapavt avt
           , crapage age
       WHERE age.cdcooper = ass.cdcooper
         AND age.cdagenci = ass.cdagenci
         AND ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;

  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := vr_tbconta_investigar.FIRST;

    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da agencia de cada conta investigada
      FOR rw_agencia IN cr_agencias (pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                    ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                                    
        -- Se não possuir dados do PA, devemos criticar para que o Juridico providencie
        IF rw_agencia.nrtelvoz IS NULL OR
           rw_agencia.dtabertu IS NULL THEN
          
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
          vr_tberro(vr_idx_err).dserro   := 'Dados do PA nao carregados. ' ||
                                            'Cooperativa: ' || to_char(rw_agencia.cdcooper,'fm000') ||
                                            ' PA: ' || to_char(rw_agencia.cdagenci,'fm0000') ||
                                            ' Informar o telefone e a data de abertura!';
        ELSE
          -- Verificamos se os dados do PA já foram carregados, para evitar de enviarmos linhas duplicadas do PA
          BEGIN
            INSERT INTO cecred.tbjur_qbr_sig_agencia(nrseq_quebra_sigilo,
                                                     cdcooper,
                                                     cdagenci) VALUES (pr_nrseq_quebra_sigilo,
                                                                       rw_agencia.cdcooper,
                                                                       rw_agencia.cdagenci);
          EXCEPTION
            WHEN dup_val_on_index THEN
              NULL;
          END;
        END IF;
        
        -- verificar se a conta eh de pessoa juridica
        IF rw_agencia.inpessoa = 2 THEN
          -- Temos que carregar as informacoes dos avalistas
          FOR rw_agencia_avalista IN cr_avalistas(pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                                 ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
                         
            --  Se não possuir dados do PA, devemos criticar para que o Juridico providencie
            IF rw_agencia.nrtelvoz IS NULL OR
               rw_agencia.dtabertu IS NULL THEN

              vr_idx_err := vr_tberro.COUNT + 1;
              vr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
              vr_tberro(vr_idx_err).dserro   := 'Dados do PA nao carregados. ' ||
                                                'Cooperativa: ' || to_char(rw_agencia_avalista.cdcooper,'fm000') ||
                                                ' PA: ' || to_char(rw_agencia_avalista.cdagenci,'fm0000');
            ELSE
              -- Verificamos se os dados do PA já foram carregados, para evitar de enviarmos linhas duplicadas do PA
              BEGIN
                INSERT INTO cecred.tbjur_qbr_sig_agencia(nrseq_quebra_sigilo,
                                                         cdcooper,
                                                         cdagenci) VALUES (pr_nrseq_quebra_sigilo,
                                                                           rw_agencia_avalista.cdcooper,
                                                                           rw_agencia_avalista.cdagenci);
              EXCEPTION
                WHEN dup_val_on_index THEN
                  NULL;
              END;
            END IF;
          END LOOP; -- Loop Agencia do Avalista
        END IF; -- Pessoa Juridica
      END LOOP; --  Loop Agencia

      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := vr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      -- Caso acontece algum erro nao tratado, nao geramos o arquivo e o programa deve ser corrigido
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'AGENCIAS';
      vr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_agencias;
  
  -- Carregar os dados das contas envolvidas
  PROCEDURE pc_carrega_arq_contas(pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE) IS
    
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_idx_conta VARCHAR2(15);
    vr_tpmovcta  VARCHAR2(1);
    vr_idx_cta_investigar VARCHAR2(30);
    vr_idx_cta_investigar_exists VARCHAR2(30);

    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Buscar os dados das contas dos avalistas que estão sendo investigados
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass, crapavt avt
       WHERE ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;
         
    -- verificar se a conta possui movimentacao durante o periodo da quebra
    CURSOR cr_existe_mov (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtmvtolt_ini IN DATE
                         ,pr_dtmvtolt_fim IN DATE) IS
      SELECT 1 existe
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim;
    rw_existe_mov cr_existe_mov%ROWTYPE;
         
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := vr_tbconta_investigar.FIRST;

    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP

        -- Chave do Conta para buscar os dados
        vr_idx_conta := to_char(rw_conta.cdcooper,'fm000') || '_' || 
                        to_char(rw_conta.nrdconta,'fm0000000000');

        -- Tipo Movimentação = 1 - É uma conta investigada e houve movimentação bancária no período de afastamento
        vr_tpmovcta := '1';
        
        -- Verificar se a conta teve movimentação no periodo da quebra
        OPEN cr_existe_mov (pr_cdcooper     => rw_conta.cdcooper 
                           ,pr_nrdconta     => rw_conta.nrdconta 
                           ,pr_dtmvtolt_ini => vr_tbconta_investigar(vr_idx_cta_investigar).dtiniper
                           ,pr_dtmvtolt_fim => vr_tbconta_investigar(vr_idx_cta_investigar).dtfimper);
        FETCH cr_existe_mov INTO rw_existe_mov;
        -- Verificar se encontrou registro
        IF cr_existe_mov%NOTFOUND THEN
          -- Possui movimentação ?
          -- Tipo Movimentação = 2 - É uma conta investigada, porém não houve movimentação no período
          vr_tpmovcta := '2';
        END IF;
        -- Fecha o Cursor
        CLOSE cr_existe_mov;
        
        -- Indice da Conta que estamos criando                  
        BEGIN
          INSERT INTO cecred.tbjur_qbr_sig_conta(nrseq_quebra_sigilo,
                                                 cdcooper,
                                                 nrdconta,
                                                 tpmovcta) VALUES (pr_nrseq_quebra_sigilo,
                                                                   rw_conta.cdcooper,
                                                                   rw_conta.nrdconta,
                                                                   vr_tpmovcta);
        EXCEPTION
          WHEN dup_val_on_index THEN
            NULL;
        END;
        
        -- verificar se a conta eh de pessoa juridica
        IF rw_conta.inpessoa = 2 THEN
          -- Temos que carregar as informacoes dos avalistas
          FOR rw_conta_avalista IN cr_avalistas(pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                               ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
            
            -- Tipo Movimentação = 1 - É uma conta investigada e houve movimentação bancária no período de afastamento
            vr_tpmovcta := '1';
            
            -- Verificar se a conta esta sendo investigada ?
            IF NOT vr_tbconta_investigar.EXISTS(vr_idx_cta_investigar_exists) THEN
              -- Tipo Movimentação = 3 - Quando não for uma conta investigada, porém trata-se de conta do mesmo banco que efetuou transação bancária com uma conta investigada.
              vr_tpmovcta := '3';
            ELSE 
              -- Verificar se a conta teve movimentação no periodo da quebra
              OPEN cr_existe_mov (pr_cdcooper     => rw_conta_avalista.cdcooper 
                                 ,pr_nrdconta     => rw_conta_avalista.nrdconta 
                                 ,pr_dtmvtolt_ini => vr_tbconta_investigar(vr_idx_cta_investigar).dtiniper
                                 ,pr_dtmvtolt_fim => vr_tbconta_investigar(vr_idx_cta_investigar).dtfimper);
              FETCH cr_existe_mov INTO rw_existe_mov;
              -- Verificar se encontrou registro
              IF cr_existe_mov%NOTFOUND THEN
                -- Possui movimentação ?
                -- Tipo Movimentação = 2 - É uma conta investigada, porém não houve movimentação no período
                vr_tpmovcta := '2';
              END IF;
              -- Fecha o Cursor
              CLOSE cr_existe_mov;
            END IF;
            
            -- Indice da Conta que estamos criando                  
            BEGIN
              INSERT INTO cecred.tbjur_qbr_sig_conta(nrseq_quebra_sigilo,
                                                     cdcooper,
                                                     nrdconta,
                                                     tpmovcta) VALUES (pr_nrseq_quebra_sigilo,
                                                                       rw_conta_avalista.cdcooper,
                                                                       rw_conta_avalista.nrdconta,
                                                                       vr_tpmovcta);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP; -- Loop Conta do Avalista
        END IF; -- Pessoa Juridica

      END LOOP; --  Loop Conta Cooperado
      
      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := vr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'CONTAS';
      vr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_contas;
  
  PROCEDURE pc_carrega_arq_titulares(pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE) IS
    -- Variaveis Locais
    vr_idx_err     INTEGER;
    vr_idx_titular VARCHAR2(30);
    vr_idx_cta_investigar VARCHAR2(30);
    vr_pessoa_investigada VARCHAR2(1);
    vr_tpendass NUMBER;
    vr_nmprimtl VARCHAR2(80);
    vr_tpdocttl VARCHAR2(50);
    vr_nrdocttl VARCHAR2(20);
    vr_dsendere VARCHAR2(80);
    vr_nmcidade VARCHAR2(40);
    vr_ufendere VARCHAR2(2);
    vr_nrcepend NUMBER(15);
    vr_nrtelefo VARCHAR2(20);
    vr_vlrrendi NUMBER(25,2);
    vr_dtultalt VARCHAR2(10);
    vr_dtabtcct VARCHAR2(10);
    vr_dtdemiss VARCHAR2(10);
    vr_inpessoa VARCHAR2(1);
    vr_nrcpfcgc NUMBER(25);
    vr_dsvincul VARCHAR2(1);

    -- Buscar os dados dos titulares que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.cdagenci,
             ass.inpessoa,
             ass.dtmvtolt,
             ass.dtelimin,
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.tpdocptl,
             ass.nrdocptl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Buscar os dados do titular "Pessoa Fisica" com base no CPF investigado
    CURSOR cr_titulares(pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ttl.*,
             decode(ttl.idseqttl, 
              1, 'T', -- O primeiro titular eh "T"
              2, '1', -- O segundo titular eh "1"  Primeiro co-titular
              3, '2', -- O terceiro titular eh "2"  Segundo co-titular
              4, '3', -- O quarto titular eh "3"  Terceiro co-titular
              'O') dsvincul -- Os demais titulares serão "O" Outros
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper 
         AND ttl.nrdconta = pr_nrdconta;

    -- Buscar a ultima data de alteracao na conta do cooperado
    CURSOR cr_ultima_alteracao (pr_cdcooper IN INTEGER
                               ,pr_nrdconta IN INTEGER) IS
      SELECT MAX(alt.dtaltera) dtaltera
        FROM crapalt alt
       WHERE alt.cdcooper = pr_cdcooper
         AND alt.nrdconta = pr_nrdconta
         AND alt.tpaltera = 1;
    rw_ultima_alteracao cr_ultima_alteracao%ROWTYPE;

    -- Buscar o contrato social da empresa
    CURSOR cr_contrato_social (pr_cdcooper IN INTEGER
                              ,pr_nrdconta IN INTEGER) IS
      SELECT jur.nrregemp
        ,UPPER(jur.orregemp) orregemp
      FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_contrato_social cr_contrato_social%ROWTYPE;
   
    -- Buscar o endereco do cooperado
    CURSOR cr_endereco (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER
                       ,pr_tpendass IN INTEGER) IS
      SELECT enc.dsendere
            ,enc.nrendere
            ,enc.nmcidade
            ,enc.cdufende
            ,enc.nrcepend
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.tpendass = pr_tpendass;
    rw_endereco cr_endereco%ROWTYPE;

    -- Buscar o telefone de contato do cooperado
    CURSOR cr_contato (pr_cdcooper IN INTEGER
                      ,pr_nrdconta IN INTEGER) IS
      SELECT tfc.nrdddtfc
            ,tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.tptelefo in (1,2,3) -- 1: Residencial / 2: Celular / 3: Comercial
       ORDER BY tfc.tptelefo;
    rw_contato cr_contato%ROWTYPE;
    
    -- Buscar o rendimento do cooperado
    CURSOR cr_rendimento (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_nrcpfcgc IN NUMBER) IS
      SELECT ttl.vlsalari,
             (ttl.vldrendi##1
            + ttl.vldrendi##2
            + ttl.vldrendi##3
            + ttl.vldrendi##4
            + ttl.vldrendi##5
            + ttl.vldrendi##6) vldrendi
      FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_rendimento cr_rendimento%ROWTYPE;
    
    -- Buscar o valor do ultimo faturamento informado pela empresa
    CURSOR cr_faturamento (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER) IS
      SELECT resultado.cdcooper
            ,resultado.nrdconta
            ,TO_NUMBER(SUBSTR(resultado.chave,1,4)) max_anoftbru
            ,TO_NUMBER(SUBSTR(resultado.chave,5,2)) max_mesftbru
            ,TO_NUMBER(SUBSTR(resultado.chave,7,27)) / 100 max_vlrftbru
      FROM (
            SELECT jfn.cdcooper
                  ,jfn.nrdconta
                  ,MAX(TO_CHAR(a.anoftbru,'fm0000')
                     ||TO_CHAR(a.mesftbru,'fm00')
                     ||TO_CHAR(a.vlrftbru*100,'fm000000000000000000000000000')) chave
            FROM (
                  -- Tabela de memoria para carregar todos os valores de faturamento
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##1 mesftbru
                        ,jfni.anoftbru##1 anoftbru
                        ,jfni.vlrftbru##1 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##2 mesftbru
                        ,jfni.anoftbru##2 anoftbru
                        ,jfni.vlrftbru##2 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##3 mesftbru
                        ,jfni.anoftbru##3 anoftbru
                        ,jfni.vlrftbru##3 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##4 mesftbru
                        ,jfni.anoftbru##4 anoftbru
                        ,jfni.vlrftbru##4 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##5 mesftbru
                        ,jfni.anoftbru##5 anoftbru
                        ,jfni.vlrftbru##5 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##6 mesftbru
                        ,jfni.anoftbru##6 anoftbru
                        ,jfni.vlrftbru##6 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##7 mesftbru
                        ,jfni.anoftbru##7 anoftbru
                        ,jfni.vlrftbru##7 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##8 mesftbru
                        ,jfni.anoftbru##8 anoftbru
                        ,jfni.vlrftbru##8 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##9 mesftbru
                        ,jfni.anoftbru##9 anoftbru
                        ,jfni.vlrftbru##9 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##10 mesftbru
                        ,jfni.anoftbru##10 anoftbru
                        ,jfni.vlrftbru##10 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##11 mesftbru
                        ,jfni.anoftbru##11 anoftbru
                        ,jfni.vlrftbru##11 vlrftbru
                  FROM crapjfn jfni
                  UNION ALL
                  SELECT jfni.cdcooper
                        ,jfni.nrdconta
                        ,jfni.mesftbru##12 mesftbru
                        ,jfni.anoftbru##12 anoftbru
                        ,jfni.vlrftbru##12 vlrftbru
                  FROM crapjfn jfni
                 ) a
                ,crapjfn jfn
            WHERE a.cdcooper = jfn.cdcooper
              AND a.nrdconta = jfn.nrdconta
              AND jfn.cdcooper = pr_cdcooper
              AND jfn.nrdconta = pr_nrdconta
            GROUP BY
                   jfn.cdcooper
                  ,jfn.nrdconta
           ) resultado;
    rw_faturamento cr_faturamento%ROWTYPE;

    -- Buscar os dados das contas dos avalistas que estão sendo investigados
    CURSOR cr_avalistas (pr_cdcooper IN INTEGER 
                        ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.cdagenci,
             ass.inpessoa,
             ass.dtmvtolt,
             ass.dtelimin,
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.tpdocptl,
             ass.nrdocptl
        FROM crapass ass, crapavt avt
       WHERE ass.cdcooper = avt.cdcooper
         AND ass.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc > 0
         AND avt.nrdctato > 0;
         
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := vr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP

        -- Abertura e encerramento da conta
        vr_dtabtcct := to_char(rw_conta.dtmvtolt,'DDMMYYYY');
        vr_dtdemiss := to_char(rw_conta.dtelimin,'DDMMYYYY');
        -- Tipo de pessoa 
        vr_inpessoa := rw_conta.inpessoa;
        
        -- Limpar os campos
        vr_tpdocttl := '';
        vr_nrdocttl := '';
        vr_nmprimtl := '';
        vr_nrcpfcgc := 0;
        
        -- Carregar a data da ultima atualizacao do cadastro
        vr_dtultalt := '';
        OPEN cr_ultima_alteracao (pr_cdcooper => rw_conta.cdcooper
                                 ,pr_nrdconta => rw_conta.nrdconta);
        FETCH cr_ultima_alteracao INTO rw_ultima_alteracao;
        -- Verificar se encontrou atualizacao
        IF cr_ultima_alteracao%FOUND THEN
          -- Carrega a data
          vr_dtultalt := to_char(rw_ultima_alteracao.dtaltera,'DDMMYYYY');
        END IF;
        -- Fechar o Cursor
        CLOSE cr_ultima_alteracao;
        
        -- Carregar os dados do endereço da conta
        vr_dsendere := '';
        vr_nmcidade := '';
        vr_nrcepend := '';
        -- Verificar o tipo de pessoa para carregar o endereço correto
        IF rw_conta.inpessoa = 1 THEN
          vr_tpendass := 10; -- Residencial
        ELSE
          vr_tpendass := 9;  -- Comercial
        END IF;
        -- Abrir o cursor do endereco da conta do cooperado
        OPEN cr_endereco (pr_cdcooper => rw_conta.cdcooper
                         ,pr_nrdconta => rw_conta.nrdconta
                         ,pr_tpendass => vr_tpendass);
        FETCH cr_endereco INTO rw_endereco;
        -- Verificamos se o endereço existe
        IF cr_endereco%FOUND THEN
          -- Atualizamos o endereço
          vr_dsendere := rw_endereco.dsendere || ' ' || rw_endereco.nrendere;
          vr_nmcidade := rw_endereco.nmcidade;
          vr_ufendere := rw_endereco.cdufende;
          IF rw_endereco.nrcepend > 0 THEN
            vr_nrcepend := rw_endereco.nrcepend;
          END IF;
        END IF;
        -- Fechar o Cursor
        CLOSE cr_endereco;

        -- Carregamos a informação do telefone do cooperado
        vr_nrtelefo := ''; 
        OPEN cr_contato(pr_cdcooper => rw_conta.cdcooper
                       ,pr_nrdconta => rw_conta.nrdconta);
        FETCH cr_contato INTO rw_contato;
        -- Verificar se encontrou o telefone de contato
        IF cr_contato%FOUND THEN
          -- Atulizar o telefone de contato
          vr_nrtelefo := to_char(rw_contato.nrdddtfc) || to_char(rw_contato.nrtelefo);
        END IF;
        -- Fechar o Cursor 
        CLOSE cr_contato;        
        
        -- Pessoa Fisica
        IF rw_conta.inpessoa  = 1 THEN
          
          -- Para pessoa fisica, temos que buscar os dados do Titular crapttl
          FOR rw_titular IN cr_titulares(pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                        ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP

            -- Chave do Conta para buscar os dados
            vr_idx_titular := to_char(rw_titular.cdcooper,'fm000') || '_' || 
                              to_char(rw_titular.nrdconta,'fm0000000000') || '_' ||
                              to_char(rw_titular.nrcpfcgc,'fm000000000000000');

            -- Pessoa esta sendo investigada ?
            vr_pessoa_investigada := '0';
            IF vr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
              vr_pessoa_investigada := '1';
            END IF;
              
            -- Nome do titular 
            vr_nmprimtl := rw_titular.nmextttl;
            -- Documentos do cooperado
            vr_tpdocttl := rw_titular.tpdocttl;
            vr_nrdocttl := rw_titular.nrdocttl;
            vr_nrcpfcgc := rw_titular.nrcpfcgc;
            
            -- Carregar o valor de rendimento informado pelo cooperado
            vr_vlrrendi := 0;
            -- Quando for pessoa fisica enviamos o salario mais a renda informada
            OPEN cr_rendimento (pr_cdcooper => rw_titular.cdcooper
                               ,pr_nrdconta => rw_titular.nrdconta
                               ,pr_nrcpfcgc => rw_titular.nrcpfcgc);
            FETCH cr_rendimento INTO rw_rendimento;
            IF cr_rendimento%FOUND THEN
              -- Rendimento do Cooperado (SALARIO + RENDIMENTOS INFORMADOS)
              vr_vlrrendi := (rw_rendimento.vlsalari + rw_rendimento.vldrendi);
            END IF;
            -- Fechar Cursor
            CLOSE cr_rendimento;
            
            BEGIN
              INSERT INTO cecred.tbjur_qbr_sig_titular(nrseq_quebra_sigilo,
                                                       cdcooper,
                                                       nrdconta,
                                                       nrcpfcgc,
                                                       cddbanco,
                                                       cdagenci,
                                                       tpdconta,
                                                       dsvincul,
                                                       flafasta,
                                                       inpessoa,
                                                       nmprimtl,
                                                       tpdocttl,
                                                       nrdocttl,
                                                       dsendere,
                                                       nmcidade,
                                                       ufendere,
                                                       nmdopais,
                                                       nrcepend,
                                                       nrtelefo,
                                                       vlrrendi,
                                                       dtultalt,
                                                       dtadmiss,
                                                       dtdemiss)
                                                VALUES(pr_nrseq_quebra_sigilo
                                                      ,rw_conta.cdcooper
                                                      ,rw_titular.nrdconta
                                                      ,vr_nrcpfcgc
                                                      ,'085'
                                                      ,rw_conta.cdagenci
                                                      ,1
                                                      ,rw_titular.dsvincul
                                                      ,vr_pessoa_investigada
                                                      ,vr_inpessoa
                                                      ,vr_nmprimtl
                                                      ,vr_tpdocttl
                                                      ,vr_nrdocttl
                                                      ,vr_dsendere
                                                      ,vr_nmcidade
                                                      ,vr_ufendere
                                                      ,'BRASIL'
                                                      ,vr_nrcepend
                                                      ,vr_nrtelefo
                                                      ,vr_vlrrendi
                                                      ,vr_dtultalt
                                                      ,vr_dtabtcct
                                                      ,vr_dtdemiss);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP; -- Titulares da conta de pessoa fisica
        ELSE
          -- Pessoa Jurídica
          
          -- Chave do Conta para buscar os dados
          vr_idx_titular := to_char(rw_conta.cdcooper,'fm000') || '_' || 
                            to_char(rw_conta.nrdconta,'fm0000000000') || '_' ||
                            to_char(rw_conta.nrcpfcgc,'fm000000000000000');

          -- Pessoa esta sendo investigada ?
          vr_pessoa_investigada := '0';
          IF vr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
            vr_pessoa_investigada := '1';
          END IF;

          -- Pessoa Juridica utiliza o contrato social
          vr_tpdocttl := '';
          vr_nrdocttl := '';
          -- Nome do titular da conta PJ
          vr_nmprimtl := rw_conta.nmprimtl;
          -- CNPJ que está sendo investigado
          vr_nrcpfcgc := rw_conta.nrcpfcgc;
          
          -- Abrir o cursor do contrato social da conta do cooperado
          OPEN cr_contrato_social (pr_cdcooper => rw_conta.cdcooper
                                  ,pr_nrdconta => rw_conta.nrdconta);
          FETCH cr_contrato_social INTO rw_contrato_social;
          -- Verificamos se o endereço existe
          IF cr_contrato_social%FOUND THEN
            vr_tpdocttl := 'CONTRATO SOCIAL';
            vr_nrdocttl := SUBSTR( to_char(rw_contrato_social.nrregemp) || ' ' || rw_contrato_social.orregemp , 1,20);
          END IF;
          -- Fechar Cursor
          CLOSE cr_contrato_social;
          
          -- Carregar o valor de rendimento informado pelo cooperado
          vr_vlrrendi := 0;
          -- Quando for pessoa juridica enviamos o valor do faturamento
          OPEN cr_faturamento (pr_cdcooper => rw_conta.cdcooper
                              ,pr_nrdconta => rw_conta.nrdconta);
          FETCH cr_faturamento INTO rw_faturamento;
          IF cr_faturamento%FOUND THEN
            -- Ultimo faturamento da empresa
            vr_vlrrendi := rw_faturamento.max_vlrftbru;
          END IF;
          -- Fechar Cursor
          CLOSE cr_faturamento;

          BEGIN
            INSERT INTO cecred.tbjur_qbr_sig_titular(nrseq_quebra_sigilo,
                                                     cdcooper,
                                                     nrdconta,
                                                     nrcpfcgc,
                                                     cddbanco,
                                                     cdagenci,
                                                     tpdconta,
                                                     dsvincul,
                                                     flafasta,
                                                     inpessoa,
                                                     nmprimtl,
                                                     tpdocttl,
                                                     nrdocttl,
                                                     dsendere,
                                                     nmcidade,
                                                     ufendere,
                                                     nmdopais,
                                                     nrcepend,
                                                     nrtelefo,
                                                     vlrrendi,
                                                     dtultalt,
                                                     dtadmiss,
                                                     dtdemiss)
                                              VALUES(pr_nrseq_quebra_sigilo
                                                    ,rw_conta.cdcooper
                                                    ,rw_conta.nrdconta
                                                    ,vr_nrcpfcgc
                                                    ,'085'
                                                    ,rw_conta.cdagenci
                                                    ,1
                                                    ,'T'
                                                    ,vr_pessoa_investigada
                                                    ,vr_inpessoa
                                                    ,vr_nmprimtl
                                                    ,vr_tpdocttl
                                                    ,vr_nrdocttl
                                                    ,vr_dsendere
                                                    ,vr_nmcidade
                                                    ,vr_ufendere
                                                    ,'BRASIL'
                                                    ,vr_nrcepend
                                                    ,vr_nrtelefo
                                                    ,vr_vlrrendi
                                                    ,vr_dtultalt
                                                    ,vr_dtabtcct
                                                    ,vr_dtdemiss);
          EXCEPTION
            WHEN dup_val_on_index THEN
              NULL;
          END;

          -- Temos que carregar as informacoes dos avalistas
          FOR rw_titular_avt IN cr_avalistas(pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                            ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
            
            -- Chave do Conta para buscar os dados
            vr_idx_titular := to_char(rw_titular_avt.cdcooper,'fm000') || '_' || 
                              to_char(rw_titular_avt.nrdconta,'fm0000000000') || '_' ||
                              to_char(rw_titular_avt.nrcpfcgc,'fm000000000000000');

            -- Abertura e encerramento da conta
            vr_dtabtcct := to_char(rw_titular_avt.dtmvtolt,'DDMMYYYY');
            vr_dtdemiss := to_char(rw_titular_avt.dtelimin,'DDMMYYYY');

            -- Verificar se a 
            IF rw_titular_avt.inpessoa = 2 THEN
              -- Pessoa Juridica utiliza o contrato social
              vr_tpdocttl := '';
              vr_nrdocttl := '';
              -- Abrir o cursor do contrato social da conta do cooperado
              OPEN cr_contrato_social (pr_cdcooper => rw_titular_avt.cdcooper
                                      ,pr_nrdconta => rw_titular_avt.nrdconta);
              FETCH cr_contrato_social INTO rw_contrato_social;
              -- Verificamos se o endereço existe
              IF cr_contrato_social%FOUND THEN
                vr_tpdocttl := 'CONTRATO SOCIAL';
                vr_nrdocttl := to_char(rw_contrato_social.nrregemp) || ' ' || rw_contrato_social.orregemp;
              END IF;
              -- Fechar Cursor
              CLOSE cr_contrato_social;
            ELSE
              vr_tpdocttl := rw_titular_avt.tpdocptl;
              vr_nrdocttl := rw_titular_avt.nrdocptl;
            END IF;
              
            -- Pessoa esta sendo investigada ?
            vr_pessoa_investigada := '0';
            IF vr_tbconta_investigar.EXISTS(vr_idx_titular) THEN
              vr_pessoa_investigada := '1';
              vr_dsvincul := 'T'; -- TITULAR
            ELSE 
              vr_dsvincul := 'R'; -- REPRESENTANTE
            END IF;
              
            -- Carregar a data da ultima atualizacao do cadastro
            vr_dtultalt := '';
            OPEN cr_ultima_alteracao (pr_cdcooper => rw_titular_avt.cdcooper
                                     ,pr_nrdconta => rw_titular_avt.nrdconta);
            FETCH cr_ultima_alteracao INTO rw_ultima_alteracao;
            -- Verificar se encontrou atualizacao
            IF cr_ultima_alteracao%FOUND THEN
              -- Carrega a data
              vr_dtultalt := to_char(rw_ultima_alteracao.dtaltera,'DDMMYYYY');
            END IF;
            -- Fechar o Cursor
            CLOSE cr_ultima_alteracao;
              
            -- Carregar os dados do endereço da conta
            vr_dsendere := '';
            vr_nmcidade := '';
            vr_nrcepend := '';
            -- Verificar o tipo de pessoa para carregar o endereço correto
            IF rw_titular_avt.inpessoa = 1 THEN
              vr_tpendass := 10; -- Residencial
            ELSE
              vr_tpendass := 9;  -- Comercial
            END IF;
            -- Abrir o cursor do endereco da conta do cooperado
            OPEN cr_endereco (pr_cdcooper => rw_titular_avt.cdcooper
                             ,pr_nrdconta => rw_titular_avt.nrdconta
                             ,pr_tpendass => vr_tpendass);
            FETCH cr_endereco INTO rw_endereco;
            -- Verificamos se o endereço existe
            IF cr_endereco%FOUND THEN
              -- Atualizamos o endereço
              vr_dsendere := rw_endereco.dsendere || ' ' || rw_endereco.nrendere;
              vr_nmcidade := rw_endereco.nmcidade;
              vr_ufendere := rw_endereco.cdufende;
              IF rw_endereco.nrcepend > 0 THEN
                vr_nrcepend := rw_endereco.nrcepend;
              END IF;
            END IF;
            -- Fechar o Cursor
            CLOSE cr_endereco;

            -- Carregamos a informação do telefone do cooperado
            vr_nrtelefo := ''; 
            OPEN cr_contato(pr_cdcooper => rw_titular_avt.cdcooper
                           ,pr_nrdconta => rw_titular_avt.nrdconta);
            FETCH cr_contato INTO rw_contato;
            -- Verificar se encontrou o telefone de contato
            IF cr_contato%FOUND THEN
              -- Atulizar o telefone de contato
              vr_nrtelefo := to_char(rw_contato.nrdddtfc) || to_char(rw_contato.nrtelefo);
            END IF;
            -- Fechar o Cursor 
            CLOSE cr_contato;
            
            -- Carregar o valor de rendimento informado pelo cooperado
            vr_vlrrendi := 0;
            -- Tratamento para pessoa física
            IF rw_titular_avt.inpessoa = 1 THEN
              -- Quando for pessoa fisica enviamos o salario mais a renda informada
              OPEN cr_rendimento (pr_cdcooper => rw_titular_avt.cdcooper
                                 ,pr_nrdconta => rw_titular_avt.nrdconta
                                 ,pr_nrcpfcgc => rw_titular_avt.nrcpfcgc);
              FETCH cr_rendimento INTO rw_rendimento;
              IF cr_rendimento%FOUND THEN
                -- Rendimento do Cooperado (SALARIO + RENDIMENTOS INFORMADOS)
                vr_vlrrendi := (rw_rendimento.vlsalari + rw_rendimento.vldrendi);
              END IF;
              -- Fechar Cursor
              CLOSE cr_rendimento;
            ELSE
              -- Quando for pessoa juridica enviamos o valor do faturamento
              OPEN cr_faturamento (pr_cdcooper => rw_titular_avt.cdcooper
                                  ,pr_nrdconta => rw_titular_avt.nrdconta);
              FETCH cr_faturamento INTO rw_faturamento;
              IF cr_faturamento%FOUND THEN
                -- Ultimo faturamento da empresa
                vr_vlrrendi := rw_faturamento.max_vlrftbru;
              END IF;
              -- Fechar Cursor
              CLOSE cr_faturamento;
            END IF;

            BEGIN
              INSERT INTO cecred.tbjur_qbr_sig_titular(nrseq_quebra_sigilo,
                                                       cdcooper,
                                                       nrdconta,
                                                       nrcpfcgc,
                                                       cddbanco,
                                                       cdagenci,
                                                       tpdconta,
                                                       dsvincul,
                                                       flafasta,
                                                       inpessoa,
                                                       nmprimtl,
                                                       tpdocttl,
                                                       nrdocttl,
                                                       dsendere,
                                                       nmcidade,
                                                       ufendere,
                                                       nmdopais,
                                                       nrcepend,
                                                       nrtelefo,
                                                       vlrrendi,
                                                       dtultalt,
                                                       dtadmiss,
                                                       dtdemiss)
                                                VALUES(pr_nrseq_quebra_sigilo
                                                      ,rw_titular_avt.cdcooper
                                                      ,rw_titular_avt.nrdconta
                                                      ,rw_titular_avt.nrcpfcgc
                                                      ,'085'
                                                      ,rw_titular_avt.cdagenci
                                                      ,1
                                                      ,vr_dsvincul
                                                      ,vr_pessoa_investigada
                                                      ,rw_titular_avt.inpessoa
                                                      ,rw_titular_avt.nmprimtl
                                                      ,vr_tpdocttl
                                                      ,vr_nrdocttl
                                                      ,vr_dsendere
                                                      ,vr_nmcidade
                                                      ,vr_ufendere
                                                      ,'BRASIL'
                                                      ,vr_nrcepend
                                                      ,vr_nrtelefo
                                                      ,vr_vlrrendi
                                                      ,vr_dtultalt
                                                      ,vr_dtabtcct
                                                      ,vr_dtdemiss);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP; -- Loop Conta do Avalista
        END IF; -- Pessoa Juridica
      END LOOP; --  Loop Conta Cooperado

      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := vr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'TITULARES';
      vr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_titulares;

  PROCEDURE pc_carrega_arq_extrato(pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                                  ,pr_nrseqlcm            IN NUMBER DEFAULT 0) IS

    -- Variaveis Locais
    vr_idx_err     INTEGER;
    vr_idx_extrato INTEGER;
    vr_idx_cta_investigar VARCHAR2(30);

    vr_tplancto INTEGER;
    vr_vldsaldo NUMBER(25,2);
    vr_vlrsaldo NUMBER(25,2);
    vr_sddebcre VARCHAR2(1);
    vr_localtra VARCHAR2(50);
    vr_idsitqbr tbjur_qbr_sig_extrato.idsitqbr%TYPE;
    vr_dsobsqbr tbjur_qbr_sig_extrato.dsobsqbr%TYPE;
    
    
    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_contas (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    -- Buscar o saldo inicial da conta
    CURSOR cr_saldo (pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_dtmvtolt IN DATE) IS
      SELECT sda.vlsddisp
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dtmvtolt;
    rw_saldo cr_saldo%ROWTYPE;

    -- Buscar as movimentações que a conte efetuou
    CURSOR cr_lancamentos (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_dtmvtolt_ini IN DATE
                          ,pr_dtmvtolt_fim IN DATE) IS
      SELECT lcm.progress_recid
            ,lcm.dtmvtolt
            ,lcm.vllanmto
            ,lcm.nrdocmto
            ,lcm.nrterfin
            ,his.cdhistor
            ,his.dshistor
            ,his.indebcre
        FROM craplcm lcm, craphis his
       WHERE his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND lcm.progress_recid = decode(pr_nrseqlcm,0,lcm.progress_recid,pr_nrseqlcm)
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim;
  BEGIN
    -- Percorrer todas as contas que estao sendo investigadas
    vr_idx_cta_investigar := vr_tbconta_investigar.FIRST;
    WHILE TRIM(vr_idx_cta_investigar) IS NOT NULL LOOP
      -- Carregar os dados da conta de cada conta investigada
      FOR rw_conta IN cr_contas (pr_cdcooper => vr_tbconta_investigar(vr_idx_cta_investigar).cdcooper
                                ,pr_nrdconta => vr_tbconta_investigar(vr_idx_cta_investigar).nrdconta) LOOP
        
        -- Carregar o saldo inicial do cooperado 
        vr_vldsaldo := 0;
        OPEN cr_saldo (pr_cdcooper => rw_conta.cdcooper
                      ,pr_nrdconta => rw_conta.nrdconta
                      ,pr_dtmvtolt => (gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                                                  ,pr_dtmvtolt => vr_tbconta_investigar(vr_idx_cta_investigar).dtiniper - 1
                                                                  ,pr_tipo => 'A')));

        FETCH cr_saldo INTO rw_saldo;
        IF cr_saldo%FOUND THEN
          vr_vldsaldo := rw_saldo.vlsddisp;
        END IF;
        -- Fecha Cursor
        CLOSE cr_saldo;

        -- Percorrer todas as movimentaçoes da conta
        FOR rw_lancamento IN cr_lancamentos (pr_cdcooper     => rw_conta.cdcooper
                                            ,pr_nrdconta     => rw_conta.nrdconta
                                            ,pr_dtmvtolt_ini => vr_tbconta_investigar(vr_idx_cta_investigar).dtiniper
                                            ,pr_dtmvtolt_fim => vr_tbconta_investigar(vr_idx_cta_investigar).dtfimper) LOOP

          -- Calcular o valor do saldo do cooperado
          IF rw_lancamento.indebcre = 'C' THEN
            vr_vldsaldo := vr_vldsaldo + rw_lancamento.vllanmto;
          ELSE
            vr_vldsaldo := vr_vldsaldo - rw_lancamento.vllanmto;
          END IF;
          
          -- Verificar situacao da conta com base no lancamento que foi computado ao saldo
          IF vr_vldsaldo >= 0  THEN
			      vr_sddebcre := 'C'; -- Credor
          ELSE
            vr_sddebcre := 'D'; --Devedor
          END IF;
          
          -- Verificar se o saldo esta negativo
          IF vr_vldsaldo < 0 THEN
            -- Deixar valor positivo para escrever no arquivo
            vr_vlrsaldo := vr_vldsaldo * -1;
          ELSE
            vr_vlrsaldo := vr_vldsaldo;
          END IF;

          -- Tipo do Lancamento, mapeado para o historico
          IF vr_tbhistorico.exists(rw_lancamento.cdhistor) THEN
            vr_tplancto := vr_tbhistorico(rw_lancamento.cdhistor).cdhisrec;
            vr_idsitqbr := 0;
            vr_dsobsqbr := '';
          ELSE
            vr_tplancto := 0;
            vr_idsitqbr := 8;
            vr_dsobsqbr := 'Parametrizacao Ailos x Receita inexistente';
          END IF;

          -- Definir o local de onde a transacao foi efetuada
          vr_localtra := '';
          IF rw_lancamento.nrterfin > 0 THEN 
            vr_localtra := 'TAA - ' || rw_lancamento.nrterfin;
          ELSIF rw_lancamento.indebcre = 'C' THEN
            vr_localtra := 'AGENCIA';
          ELSIF vr_tplancto IN (105, 102, 110, 104, 203, 207, 213, 107, 204, 106) THEN
            vr_localtra := 'AGENCIA';
          END IF;
          
          IF rw_lancamento.cdhistor = 135 THEN
            vr_localtra := 'AGENCIA';
          END IF;

          IF rw_lancamento.cdhistor IN (508, 537, 538, 539) THEN
            vr_localtra := 'INTERNET';
          END IF;

          -- Chave do Extrato
          vr_idx_extrato := vr_tbarq_extrato.COUNT + 1;
          
          BEGIN
            INSERT INTO cecred.tbjur_qbr_sig_extrato(nrseq_quebra_sigilo,
                                                     nrseqlcm,
                                                     vlrsaldo,
                                                     indebcre_saldo,
                                                     dslocal_transacao,
                                                     idsitqbr,
                                                     dsobsqbr)
                                              VALUES(pr_nrseq_quebra_sigilo
                                                    ,rw_lancamento.progress_recid
                                                    ,vr_vlrsaldo
                                                    ,vr_sddebcre
                                                    ,vr_localtra
                                                    ,vr_idsitqbr
                                                    ,vr_dsobsqbr);
          EXCEPTION
            WHEN dup_val_on_index THEN
              UPDATE cecred.tbjur_qbr_sig_extrato c
                 SET c.idsitqbr = vr_idsitqbr
                   , c.dsobsqbr = vr_dsobsqbr
               WHERE c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
                 AND c.nrseqlcm = rw_lancamento.progress_recid;
          END;
          
          COMMIT;
        END LOOP; -- Extrato da conta do cooperado
      END LOOP; --  Loop Conta Cooperado

      -- Ir para a proxima CONTA
      vr_idx_cta_investigar := vr_tbconta_investigar.NEXT(vr_idx_cta_investigar);
    END LOOP; --  Loop Contas investigadas
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'EXTRATO';
      vr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_extrato;
  
  -- Carregar os dados para escrever no arquivo de _ORIGEM_DESTINO
  PROCEDURE pc_carrega_arq_origem_destino(pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                                         ,pr_nrseqlcm            IN NUMBER DEFAULT 0) IS
    -- Variaveis Locais
    vr_idx_err            INTEGER;
    vr_idx_ted            INTEGER;
    vr_idx_cheques_icfjud INTEGER;

    vr_nrdocmto NUMBER(25);
    vr_inpessoa VARCHAR2(1);
    vr_nrcpfcgc NUMBER(25);
    vr_nmprimtl VARCHAR2(50);
    vr_cdagenci INTEGER;
    vr_nrdconta INTEGER;
    vr_cdbandep INTEGER;
    vr_nrctadep INTEGER;

    vr_registro BOOLEAN;
    vr_anteutil DATE;
    vr_vldpagto NUMBER(25,2);

    vr_found_boleto BOOLEAN;
    vr_dt_pesquisa_ret DATE;

    vr_lote_empres VARCHAR2(5000);
    vr_encontrou_folha_velha BOOLEAN;

    vr_cdestsig NUMBER;

    vr_sqlerrm VARCHAR2(4000);

    vrins_cdbandep cecred.tbjur_qbr_sig_extrato.cdbandep%TYPE;
    vrins_cdagedep cecred.tbjur_qbr_sig_extrato.cdagedep%TYPE;
    vrins_nrctadep cecred.tbjur_qbr_sig_extrato.nrctadep%TYPE;
    vrins_tpdconta cecred.tbjur_qbr_sig_extrato.tpdconta%TYPE;
    vrins_inpessoa cecred.tbjur_qbr_sig_extrato.inpessoa%TYPE;
    vrins_nrcpfcgc cecred.tbjur_qbr_sig_extrato.nrcpfcgc%TYPE;
    vrins_nmprimtl cecred.tbjur_qbr_sig_extrato.nmprimtl%TYPE;
    vrins_tpdocttl cecred.tbjur_qbr_sig_extrato.tpdocttl%TYPE;
    vrins_nrdocttl cecred.tbjur_qbr_sig_extrato.nrdocttl%TYPE;
    vrins_dscodbar cecred.tbjur_qbr_sig_extrato.dscodbar%TYPE;
    vrins_nmendoss cecred.tbjur_qbr_sig_extrato.nmendoss%TYPE;
    vrins_docendos cecred.tbjur_qbr_sig_extrato.docendos%TYPE;
    vrins_idsitide cecred.tbjur_qbr_sig_extrato.idsitide%TYPE;
    vrins_dsobserv cecred.tbjur_qbr_sig_extrato.dsobserv%TYPE;
    vrins_idsitqbr cecred.tbjur_qbr_sig_extrato.idsitqbr%TYPE;
    vrins_dsobsqbr cecred.tbjur_qbr_sig_extrato.dsobsqbr%TYPE;
    vrins_nrdocmto cecred.tbjur_qbr_sig_extrato.nrdocmto%TYPE;

    -- Buscar os dados das contas que estão sendo investigadas
    CURSOR cr_conta IS
      SELECT ass.cdcooper
           , ass.nrdconta
           , ass.cdagenci
           , ass.inpessoa
           , ass.nrcpfcgc
           , ass.nmprimtl
           , cop.nmextcop
           , cop.nrdocnpj
           , c.dtiniper
           , c.dtfimper
        FROM crapass ass
           , crapcop cop
           , cecred.tbjur_quebra_sigilo c
       WHERE cop.cdcooper = ass.cdcooper
         AND ass.cdcooper = c.cdcooper
         AND ass.nrdconta = c.nrdconta
         AND c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;

    -- Buscar as movimentações que a conta efetuou
    CURSOR cr_lancamento IS
      SELECT lcm.cdcooper
           , lcm.nrdconta
           , lcm.progress_recid
           , lcm.dtmvtolt
           , lcm.vllanmto
           , lcm.nrdocmto
           , lcm.cdcoptfn
           , lcm.nrterfin
           , lcm.cdpesqbb
           , lcm.nrdctabb
           , lcm.nrdolote
           , lcm.cdbanchq
           , lcm.cdagechq
           , lcm.nrctachq
           , his.cdhistor
           , his.dshistor
           , his.indebcre
           , his.cdhisrec
           , c.rowid
           , c.idsitqbr
           , ass.nmprimtl
           , ass.inpessoa
           , ass.nrcpfcgc
        FROM crapass ass
           , craplcm lcm
           , craphis his
           , cecred.tbjur_qbr_sig_extrato c
       WHERE ass.cdcooper = lcm.cdcooper
         AND ass.nrdconta = lcm.nrdconta
         AND his.cdcooper = lcm.cdcooper
         AND his.cdhistor = lcm.cdhistor
         AND lcm.progress_recid = c.nrseqlcm
         AND c.nrseqlcm = decode(pr_nrseqlcm,0,c.nrseqlcm,pr_nrseqlcm)
         AND c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
       
    -- Buscar o codigo da empresa 
    CURSOR cr_empresa(pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER) IS
      SELECT emp.cdempres
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;
    rw_empresa cr_empresa%ROWTYPE;
    
    -- Buscar os dados da conta que fez o crédito
    CURSOR cr_crapass_origem(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_nrdolote IN craplcm.nrdolote%TYPE) IS
      SELECT a.*
        FROM crapass a
            ,craplcm l
       WHERE a.cdcooper = l.cdcooper
         AND a.nrdconta = l.nrdconta
         AND l.nrdolote = pr_nrdolote
         AND l.dtmvtolt = pr_dtmvtolt
         AND l.cdhistor = 889
         AND l.cdcooper = pr_cdcooper;
    rw_crapass_origem cr_crapass_origem%ROWTYPE;
    
    -- Buscar os dados da conta salario
    CURSOR cr_conta_salario(pr_cdcooper IN INTEGER
                           ,pr_nrdconta IN INTEGER) IS
      SELECT ccs.* 
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper
         AND ccs.nrdconta = pr_nrdconta;
    rw_conta_salario cr_conta_salario%ROWTYPE;
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_total_folha_velha(pr_cdcooper IN INTEGER
                               ,pr_nrdolote IN INTEGER
                               ,pr_cdempres IN INTEGER
                               ,pr_dtmvtolt IN DATE)  IS
      SELECT SUM(valor) total FROM (
        -- Somar o valor de Salario - Creditado na cooperativa
        SELECT SUM(lcm.vllanmto) valor 
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 8 -- Credito de salario liquido
        UNION ALL
        -- Somar o valor de Salario - Creditado na conta salario
        SELECT SUM(lcs.vllanmto) valor 
          FROM craplcs lcs, crapccs ccs 
         WHERE ccs.cdcooper = lcs.cdcooper 
           AND ccs.nrdconta = lcs.nrdconta 
           AND lcs.dtmvtolt >= ccs.dtadmiss
           AND ccs.cdempres = pr_cdempres 
           AND lcs.cdcooper = pr_cdcooper 
           AND lcs.dtmvtolt = pr_dtmvtolt
      ) tabela;
    rw_total_folha_velha cr_total_folha_velha%ROWTYPE;
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_lancto_folha_velha(pr_cdcooper IN INTEGER
                                ,pr_nrdolote IN INTEGER
                                ,pr_cdempres IN INTEGER
                                ,pr_dtmvtolt IN DATE)  IS
    
      SELECT * FROM (
        -- Salario - Creditado na cooperativa
        SELECT lcm.cdcooper
              ,lcm.nrdconta
              ,lcm.vllanmto
              ,'C' idtpcont
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdhistor = 8 -- Credito de salario liquido
        UNION ALL
        -- Salario - Creditado na conta salario
        SELECT ccs.cdcooper
              ,ccs.nrdconta
              ,lcs.vllanmto
              ,'T' idtpcont 
          FROM craplcs lcs, crapccs ccs 
         WHERE ccs.cdcooper = lcs.cdcooper 
           AND ccs.nrdconta = lcs.nrdconta 
           AND lcs.dtmvtolt >= ccs.dtadmiss
           AND ccs.cdempres = pr_cdempres 
           AND lcs.cdcooper = pr_cdcooper 
           AND lcs.dtmvtolt = pr_dtmvtolt
      ) tabela;    
    
    -- Buscar o valor total da folha paga em determinada data
    CURSOR cr_total_folha_nova(pr_cdcooper IN INTEGER
                              ,pr_nrdconta IN INTEGER
                              ,pr_dtmvtolt IN DATE)  IS
      SELECT SUM(pfp.vllctpag) vllctpag 
        FROM crappfp pfp, crapemp emp
       WHERE pfp.cdcooper = emp.cdcooper 
         AND pfp.cdempres = emp.cdempres 
         AND pfp.dtcredit = pr_dtmvtolt
         AND emp.cdcooper = pr_cdcooper 
         AND emp.nrdconta = pr_nrdconta;
    rw_total_folha_nova cr_total_folha_nova%ROWTYPE;

    -- Buscar os dados dos lancamento auxiliares para uma date e um lote
    CURSOR cr_lancto_folha_nova (pr_cdcooper IN INTEGER
                                ,pr_nrdconta IN INTEGER
                                ,pr_dtmvtolt IN DATE)  IS
      SELECT lfp.*
        FROM craplfp lfp, crappfp pfp, crapemp emp
       WHERE lfp.cdcooper = pfp.cdcooper 
         AND lfp.cdempres = pfp.cdempres 
         AND lfp.nrseqpag = pfp.nrseqpag
         AND pfp.cdcooper = emp.cdcooper 
         AND pfp.cdempres = emp.cdempres 
         AND pfp.dtcredit = pr_dtmvtolt
         AND emp.cdcooper = pr_cdcooper 
         AND emp.nrdconta = pr_nrdconta;
    
    -- Buscar banco, agência e conta depositada do cheque
    CURSOR cr_crapfdc_524(pr_cdcooper IN crapfdc.cdcooper%TYPE
                         ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                         ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                         ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                         ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT fdc.cdbandep
           , fdc.cdagedep
           , fdc.nrctadep
           , fdc.dsdocmc7
        FROM crapfdc fdc
       WHERE fdc.cdcooper = pr_cdcooper
         AND fdc.cdbandep = pr_cdbanchq
         AND fdc.cdagedep = pr_cdagechq
         AND fdc.nrctadep = pr_nrctachq
         AND fdc.nrcheque = pr_nrcheque;
    rw_crapfdc_524 cr_crapfdc_524%ROWTYPE;

    -- Buscar os dados do cheque
    CURSOR cr_cheque(pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_nrcheque IN INTEGER) IS
      SELECT fdc.cdbandep
            ,fdc.cdagedep
            ,fdc.nrctadep
            ,fdc.nrctachq
        FROM crapfdc fdc 
       WHERE fdc.cdcooper = pr_cdcooper
         AND fdc.nrdconta = pr_nrdconta
         AND fdc.nrcheque = pr_nrcheque;
     rw_cheque cr_cheque%ROWTYPE;
      
    -- Buscar os dados da conta do cooperado a partir da agencia da cooperativa
    CURSOR cr_conta_aux(pr_cdagectl IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ass.nmprimtl
            ,ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.cdagenci
        FROM crapass ass, crapcop cop
       WHERE cop.cdcooper = ass.cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND cop.cdagectl = pr_cdagectl;
    rw_conta_aux cr_conta_aux%ROWTYPE;
     
    -- Buscar os dados da conta do cooperado com o codigo da cooperativa
    CURSOR cr_conta_aux2(pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT ass.nmprimtl
            ,DECODE(ass.inpessoa,1,1,2) inpessoa
            ,ass.nrcpfcgc
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = pr_cdcooper;
    rw_conta_aux2 cr_conta_aux2%ROWTYPE;
      
    -- Buscar os dados do boleto
    CURSOR cr_boleto (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER
                     ,pr_dtdpagto IN DATE
                     ,pr_nrdocmto IN INTEGER) IS
      SELECT cob.vldpagto
            ,cob.nrinssac
            ,cob.nrdocmto
            ,cob.cdbanpag
            ,cob.cdagepag
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrdconta = pr_nrdconta
         AND cob.dtdpagto = pr_dtdpagto
         AND cob.nrdocmto = pr_nrdocmto;
    rw_boleto cr_boleto%ROWTYPE;
    
    -- Buscar os dados do boleto
    CURSOR cr_boleto_2 (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER
                       ,pr_nrcnvcob IN INTEGER
                       ,pr_nrdocmto IN INTEGER) IS
      SELECT cob.vldpagto
            ,cob.nrinssac
            ,cob.nrdocmto
            ,cob.cdbanpag
            ,cob.cdagepag
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdocmto = pr_nrdocmto;
    
    --rw_boleto_2 cr_boleto_2%ROWTYPE;

    -- Credito de Cobranca - Histórico 971
    CURSOR cr_crapret_971(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcco cco
       WHERE cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 1 -- Apenas convenio BB
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdocorre IN (6,17)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdocorre IN (6,17)
               )
             );

    -- Credito de Cobranca - Histórico 977
    CURSOR cr_crapret_977(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcop cop, crapcco cco
       WHERE cop.cdcooper = ret.cdcooper
         AND cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ((ret.cdbcorec = 85 and ret.cdagerec <> cop.cdagectl and ret.cdocorre IN (6,76)) or
                      (ret.cdbcorec <> 85 and ret.cdocorre IN (6,76)))
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ((ret.cdbcorec = 85 and ret.cdagerec <> cop.cdagectl and ret.cdocorre IN (6,76)) or
                      (ret.cdbcorec <> 85 and ret.cdocorre IN (6,76)))
               )
             );    
    
    -- Credito de Cobranca - Histórico 987
    CURSOR cr_crapret_987(pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcop cop, crapcco cco
       WHERE cop.cdcooper = ret.cdcooper
         AND cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdbcorec = 85
                 AND ret.cdagerec = cop.cdagectl
                 AND ret.cdocorre IN (6,76)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdbcorec = 85
                 AND ret.cdagerec = cop.cdagectl
                 AND ret.cdocorre IN (6,76)
               )
             );


    -- Credito de Cobranca - Histórico 1089
    CURSOR cr_crapret_1089(pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_dtcredit IN crapret.dtcredit%TYPE) IS
      SELECT ret.*
        FROM crapret ret, crapcco cco
       WHERE cco.cdcooper = ret.cdcooper 
         AND cco.nrconven = ret.nrcnvcob
         AND cco.cddbanco = 85 -- Apenas convenio CECRED
         AND ret.cdcooper = pr_cdcooper
         AND ret.nrdconta = pr_nrdconta
         AND ( ( --- Liberação do FLOAT
                     pr_dtcredit >= to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit = pr_dtcredit
                 AND ret.flcredit = 1
                 AND ret.cdocorre IN (17,77)
               ) OR (
                     pr_dtcredit < to_date('21/10/2014','dd/mm/yyyy') 
                 AND ret.dtcredit IS NULL
                 AND ret.flcredit = 0
                 AND ret.dtocorre = pr_dtcredit
                 AND ret.cdocorre IN (17,77)
               )
             );
    
    -- Buscar os dados do pagador
    CURSOR cr_pagador(pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER
                     ,pr_nrinssac IN NUMBER) IS
      SELECT sab.cdtpinsc 
            ,sab.nrinssac
            ,sab.nmdsacad
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_pagador cr_pagador%ROWTYPE;
    
    -- Buscar os dados da Custodia de Cheque
    CURSOR cr_custodia_cheque(pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrdocmto IN INTEGER) IS
      SELECT cst.vlcheque
            ,cst.nrdocmto
            ,cst.cdbanchq
            ,cst.cdagechq
            ,cst.nrctachq
            ,cst.cdcooper
						,cst.dsdocmc7
        FROM crapcst cst
       WHERE cst.cdcooper = pr_cdcooper
         AND cst.nrdconta = pr_nrdconta
         AND cst.nrdocmto = pr_nrdocmto;
    rw_custodia_cheque cr_custodia_cheque%ROWTYPE;
    
    -- Buscar os dados do cheque 
    CURSOR cr_cheque_085 (pr_cdcooper IN INTEGER
                         ,pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto
         AND chd.cdbanchq = 085;
    rw_cheque_085 cr_cheque_085%ROWTYPE;

    -- Buscar os dados do cheque 
    CURSOR cr_all_cheques (pr_cdcooper IN INTEGER
                          ,pr_nrdconta IN INTEGER
                          ,pr_nrdocmto IN INTEGER) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
            ,chd.cdbanchq
            ,chd.vlcheque
            ,chd.dsdocmc7
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto;

    -- Buscar os dados do cheque na DATA
    CURSOR cr_all_cheques_data (pr_cdcooper IN INTEGER
                               ,pr_nrdconta IN INTEGER
                               ,pr_nrdocmto IN INTEGER
                               ,pr_dtmvtolt IN DATE) IS
      SELECT chd.nrctachq
            ,chd.cdagechq
            ,chd.cdbanchq
            ,chd.vlcheque
            ,chd.nrdocmto
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrdocmto = pr_nrdocmto
         AND chd.dtmvtolt = pr_dtmvtolt;
         
    -- Buscar os dados de Transferencia de Valores
    CURSOR cr_transf_valor (pr_cdcooper IN INTEGER
                           ,pr_nrdconta IN INTEGER
                           ,pr_vldocrcb IN NUMBER
                           ,pr_dtmvtolt IN DATE
                           ,pr_nrdocmto IN INTEGER) IS
      SELECT tvl.cpfcgrcb,
             tvl.cdbccrcb,
             tvl.cdagercb,
             tvl.nrcctrcb,
             tvl.nmpesrcb,
             tvl.flgpescr -- Tipo de Pessoa que receberá a TED
        FROM craptvl tvl
       WHERE tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta
         AND tvl.vldocrcb = pr_vldocrcb
         AND tvl.dtmvtolt = pr_dtmvtolt
         AND tvl.nrdocmto = pr_nrdocmto;
    rw_transf_valor cr_transf_valor%ROWTYPE;
    
    -- Bordero de Cheque
    CURSOR cr_bordero_cheque (pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrborder IN INTEGER) IS
      SELECT cdb.vlliquid
            ,cdb.nrdocmto
            ,cdb.cdbanchq
            ,cdb.cdagechq
            ,cdb.nrctachq
      FROM crapcdb cdb
      WHERE cdb.cdcooper = pr_cdcooper 
        AND cdb.nrdconta = pr_nrdconta 
        AND cdb.nrborder = pr_nrborder;                             

    -- Bordero de Titulos
    CURSOR cr_bordero_titulo (pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrborder IN INTEGER) IS
      SELECT tdb.vlliquid
            ,tdb.nrdocmto
            ,tdb.nrinssac
      FROM craptdb tdb
      WHERE tdb.cdcooper = pr_cdcooper 
        AND tdb.nrdconta = pr_nrdconta 
        AND tdb.nrborder = pr_nrborder;

    -- Buscar as informações de TED
    CURSOR cr_ted578 (pr_cdcooper IN INTEGER
                     ,pr_nrdconta IN INTEGER
                     ,pr_dtmvtolt IN DATE
                     ,pr_vllanmto IN NUMBER) IS
      SELECT lmt.vldocmto,
             lmt.cdbandif banco,
             lmt.cdagedif,
             lmt.nrctadif,
             TRIM(lmt.nmtitdif) nmtitdif,
             lmt.nrcpfdif,
             lmt.cdbanctl,
             lmt.cdagectl,
             lmt.nrdconta,
             lmt.nmcopcta,
             lmt.nrcpfcop,
             lmt.cdagenci,
             lmt.dttransa
        FROM craplmt lmt
       WHERE lmt.cdcooper = pr_cdcooper
         AND lmt.nrdconta = pr_nrdconta 
         AND lmt.dttransa = pr_dtmvtolt
         AND lmt.idsitmsg = 3 -- (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
         AND lmt.vldocmto = pr_vllanmto
    ORDER BY lmt.dttransa, lmt.hrtransa, lmt.nrsequen;

    CURSOR cr_crapicf (pr_cdcooper     IN INTEGER
                      ,pr_dacaojud     IN VARCHAR2
                      ,pr_nrctareq     IN INTEGER 
                      ,pr_cdbanreq     IN INTEGER
                      ,pr_cdagereq     IN INTEGER) IS
      SELECT dtinireq
           , cdbanreq
           , cdagereq
           , nrctareq
           , intipreq
           , dsdocmc7
           , nrcpfcgc
           , nmprimtl
        FROM crapicf
       WHERE cdcooper = pr_cdcooper
         AND dacaojud = Upper(pr_dacaojud)
         AND nrctareq = pr_nrctareq
         AND cdbanreq = pr_cdbanreq
         AND cdagereq = pr_cdagereq;
    --
    rw_crapicf cr_crapicf%ROWTYPE;
    
    CURSOR cr_cooperativa(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT crapcop.cdcooper
        FROM crapcop
       WHERE crapcop.cdagectl = pr_cdagectl;
    rw_cooperativa cr_cooperativa%ROWTYPE;
    --
    CURSOR cr_cooperado(pr_cdcooper IN INTEGER
               ,pr_nrdconta IN INTEGER) IS
      SELECT crapass.nmprimtl
           , crapass.nrcpfcgc 
        FROM crapass 
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    --
    rw_cooperado cr_cooperado%ROWTYPE;

    CURSOR cr_hist_508_boleto(pr_progress_recid IN NUMBER) IS
      SELECT cob.vldpagto
           , cob.nrinssac
           , cob.nrdocmto
           , cob.cdbanpag
           , cob.cdagepag
        FROM craptit tit
           , crapcob cob
           , craplcm lcm
       WHERE cob.nrcnvcob (+)   = TO_number(SUBSTR(tit.dscodbar,20,6))
         AND cob.nrdconta (+)   = TO_number(SUBSTR(tit.dscodbar,26,8))
         AND cob.nrdocmto (+)   = TO_number(SUBSTR(tit.dscodbar,34,9))
         AND tit.cdcooper       = lcm.cdcooper
         AND tit.nrdconta       = lcm.nrdconta
         AND tit.dtmvtolt       = lcm.dtmvtolt
         AND tit.vldpagto       = lcm.vllanmto
         AND (tit.nrautdoc + 1) = lcm.nrautdoc
         AND lcm.progress_recid = pr_progress_recid;

    rw_hist_508_boleto cr_hist_508_boleto%ROWTYPE;

    CURSOR cr_hist_508_convenio(pr_progress_recid IN NUMBER) IS
      SELECT SUBSTR(lcm.cdpesqbb,INSTR(lcm.cdpesqbb,'LINE - ')+7,50) nmconvenio
        FROM craplft lft
           , craplcm lcm
       WHERE lft.cdcooper       = lcm.cdcooper
         AND lft.nrdconta       = lcm.nrdconta
         AND lft.dtmvtolt       = lcm.dtmvtolt
         AND lft.vllanmto       = lcm.vllanmto
         AND lft.nrautdoc       = lcm.nrautdoc - 1
         AND lcm.progress_recid = pr_progress_recid;

    rw_hist_508_convenio cr_hist_508_convenio%ROWTYPE;
    
    CURSOR cr_hist_508_protocolo(pr_progress_recid IN NUMBER) IS
      SELECT to_number(substr(pro.dsinform##3,instr(pro.dsinform##3,'Codigo de Barras: ')+18,3)) cdbandep
        FROM crappro pro
           , craplcm lcm
       WHERE pro.dtmvtolt = lcm.dtmvtolt
         AND pro.cdcooper = lcm.cdcooper
         AND pro.nrdconta = lcm.nrdconta
         AND pro.nrdocmto = lcm.nrdocmto
         AND lcm.progress_recid = pr_progress_recid;

    rw_hist_508_protocolo cr_hist_508_protocolo%ROWTYPE;

    PROCEDURE pc_atualiza_tbjur (pr_rowid IN ROWID) IS
      --
    BEGIN
      UPDATE cecred.tbjur_qbr_sig_extrato c
         SET c.cdbandep = vrins_cdbandep
           , c.cdagedep = vrins_cdagedep
           , c.nrctadep = vrins_nrctadep
           , c.inpessoa = vrins_inpessoa
           , c.nrcpfcgc = vrins_nrcpfcgc
           , c.nmprimtl = vrins_nmprimtl
           , c.tpdconta = vrins_tpdconta
           , c.tpdocttl = vrins_tpdocttl
           , c.nrdocttl = vrins_nrdocttl
           , c.dscodbar = vrins_dscodbar
           , c.nmendoss = vrins_nmendoss
           , c.docendos = vrins_docendos
           , c.idsitide = vrins_idsitide
           , c.dsobserv = vrins_dsobserv
           , c.idsitqbr = vrins_idsitqbr
           , c.dsobsqbr = vrins_dsobsqbr
           , c.nrdocmto = vrins_nrdocmto
       WHERE c.rowid = pr_rowid
         AND c.idsitqbr NOT IN (6,8); --Nao atualizar se foi preenchido manualmente ou falta his. receita
       
       COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_sqlerrm := SQLERRM;

        UPDATE cecred.tbjur_qbr_sig_extrato c
           SET c.idsitqbr = 7
             , c.dsobsqbr = substr('Erro: '||vr_sqlerrm,1,200)
         WHERE c.rowid = pr_rowid;
        
        COMMIT;
    END;

  BEGIN
      -- Carregar os dados da conta de cada conta investigada
    FOR rw_conta IN cr_conta LOOP

      -- Percorrer todas as movimentaçoes da conta
      FOR rw_lancamento IN cr_lancamento LOOP
        BEGIN
          vrins_cdbandep := NULL;
          vrins_cdagedep := NULL;
          vrins_nrctadep := NULL;
          vrins_tpdconta := NULL;
          vrins_inpessoa := NULL;
          vrins_nrcpfcgc := NULL;
          vrins_nmprimtl := NULL;
          vrins_tpdocttl := NULL;
          vrins_nrdocttl := NULL;
          vrins_dscodbar := NULL;
          vrins_nmendoss := NULL;
          vrins_docendos := NULL;
          vrins_idsitide := NULL;
          vrins_dsobserv := NULL;
          vrins_nrdocmto := NULL;
          vr_registro    := FALSE;
          vrins_idsitqbr := NULL;
          vrins_dsobsqbr := NULL;
        
          -- Identificamos se o historico do lancamento esta mapeado
          IF NOT vr_tbhistorico.EXISTS(rw_lancamento.cdhistor) THEN
            vr_cdestsig := 0;
          ELSE
            vr_cdestsig := vr_tbhistorico(rw_lancamento.cdhistor).cdestsig;
          END IF;

          -- Debito de CHEQUE 
          IF vr_cdestsig = 1 OR vr_cdestsig = 0 THEN -- Deb. CHEQUE
              vr_registro := FALSE;
              -- Montar o numero do documento
              vr_nrdocmto := SUBSTR(to_char(rw_lancamento.nrdocmto),1,( LENGTH(to_char(rw_lancamento.nrdocmto)) - 1 ));
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';

              -- Buscar os dados do cheque
              OPEN cr_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_nrcheque => vr_nrdocmto);
              FETCH cr_cheque INTO rw_cheque;
              IF cr_cheque%FOUND THEN
                -- Se for cheque da Cooperativa
                IF rw_cheque.cdbandep = 85 THEN 
                  -- Buscar a conta de quem depositou o cheque
                  OPEN cr_conta_aux (pr_cdagectl => rw_cheque.cdagedep
                                    ,pr_nrdconta => rw_cheque.nrctadep);
                  FETCH cr_conta_aux INTO rw_conta_aux;
                  IF cr_conta_aux%FOUND THEN
                    vr_inpessoa := rw_conta_aux.inpessoa;
                    vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                    vr_nmprimtl := rw_conta_aux.nmprimtl;
                  END IF;
                  -- Fechar Cursor
                  CLOSE cr_conta_aux;
                END IF;

                vrins_cdbandep := rw_cheque.cdbandep;
                vrins_cdagedep := rw_cheque.cdagedep;
                vrins_nrctadep := rw_cheque.nrctadep;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 1';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;

                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF; -- Encontrou cheque
              -- Fechar Cursor
              CLOSE cr_cheque;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF;-- Historico 21

            IF vr_cdestsig = 2 OR vr_cdestsig = 0 THEN -- Credito Cobranca 
              vr_registro := FALSE;
              vr_anteutil := rw_lancamento.dtmvtolt - 1;
              vr_anteutil := gene0005.fn_valida_dia_util(pr_cdcooper => rw_lancamento.cdcooper
                                                        ,pr_dtmvtolt => vr_anteutil
                                                        ,pr_tipo     => 'A');

              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_dtdpagto => vr_anteutil
                             ,pr_nrdocmto => rw_lancamento.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              -- Encontrou boleto ?
              IF cr_boleto%FOUND THEN
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
                  
                vrins_nrdocmto := rw_boleto.nrdocmto;
                vrins_cdbandep := rw_boleto.cdbanpag;
                vrins_cdagedep := rw_boleto.cdagepag;
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 2';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;
              -- Fechar Cursor
              CLOSE cr_boleto;
              
              -- Se encontrou o boleto vai para o proximo lancamento
              IF vr_registro THEN
                CONTINUE;
              END IF;
              
              vr_vldpagto := 0;
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_dtdpagto => rw_lancamento.dtmvtolt
                             ,pr_nrdocmto => rw_lancamento.nrdocmto);
              FETCH cr_boleto INTO rw_boleto;
              -- Encontrou boleto ?
              IF cr_boleto%FOUND THEN
                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
          
                vrins_nrdocmto := rw_boleto.nrdocmto;
                vrins_cdbandep := rw_boleto.cdbanpag;
                vrins_cdagedep := rw_boleto.cdagepag;
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';     
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 2';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;

              -- Fechar cursor
              CLOSE cr_boleto;

              IF vr_vldpagto <> rw_lancamento.vllanmto  THEN
                vr_idx_err := vr_tberro.COUNT + 1;
                vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO - LOOP';
                vr_tberro(vr_idx_err).dserro   := '1 - ' ||
                                                  'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                  'Valor Calculado: ' || vr_vldpagto || '  ' || 
                                                  'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
                                                  'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                  'ID: ' || rw_lancamento.progress_recid;
              END IF;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 266 

            IF vr_cdestsig = 3 OR vr_cdestsig = 0 THEN -- Credito Cobranca
              vr_registro := FALSE;

              -- Abrir cursor da crapret 
              FOR rw_crapret IN cr_crapret_971(pr_cdcooper => rw_lancamento.cdcooper 
                                              ,pr_nrdconta => rw_lancamento.nrdconta
                                              ,pr_dtcredit => rw_lancamento.dtmvtolt) LOOP
                
                vr_vldpagto := 0;
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_dtdpagto => rw_crapret.dtocorre
                               ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto INTO rw_boleto;
                vr_found_boleto := cr_boleto%FOUND;
                CLOSE cr_boleto;

                -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
                IF NOT vr_found_boleto THEN
                  -- Buscar os dados do boleto que esta sendo pago
                  OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                   ,pr_nrdconta => rw_crapret.nrdconta
                                   ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                   ,pr_nrdocmto => rw_crapret.nrdocmto);
                  FETCH cr_boleto_2 INTO rw_boleto;
                  vr_found_boleto := cr_boleto_2%FOUND;
                  CLOSE cr_boleto_2;
                END IF;
                  
                -- Encontrou boleto ?
                IF vr_found_boleto THEN
                  vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                  vr_inpessoa := '';
                  vr_nrcpfcgc := '';
                  vr_nmprimtl := '';

                  -- Busca dados do pagador
                  IF rw_boleto.nrinssac > 0 THEN
                    -- Buscar Pagador
                    OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                    ,pr_nrdconta => rw_lancamento.nrdconta
                                    ,pr_nrinssac => rw_boleto.nrinssac);
                    FETCH cr_pagador INTO rw_pagador;
                    IF cr_pagador%FOUND THEN
                      vr_inpessoa := rw_pagador.cdtpinsc;
                      vr_nrcpfcgc := rw_pagador.nrinssac;
                      vr_nmprimtl := rw_pagador.nmdsacad;
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_pagador;
                  END IF;-- Dados do pagador
            
                  vrins_nrdocmto := rw_boleto.nrdocmto;
                  vrins_cdbandep := rw_boleto.cdbanpag;
                  vrins_cdagedep := rw_boleto.cdagepag;
                  vrins_nrctadep := '';
                  vrins_tpdconta := '';
                  vrins_inpessoa := vr_inpessoa;
                  vrins_nrcpfcgc := vr_nrcpfcgc;
                  vrins_nmprimtl := vr_nmprimtl;
                  vrins_tpdocttl := '';
                  vrins_nrdocttl := '';
                  vrins_dscodbar := '';
                  vrins_nmendoss := '';
                  vrins_docendos := '';
                  vrins_idsitide := '0'; -- Fixo ZERO
                  vrins_dsobserv := '';

                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 3';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                  
                  pc_atualiza_tbjur(rw_lancamento.rowid);

                  vr_registro := TRUE;
                END IF;
              END LOOP;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 971

            IF vr_cdestsig = 4 OR vr_cdestsig = 0 THEN -- Credito Cobranca
              vr_registro := FALSE;
              
              -- data padrão para pesquisa
              vr_dt_pesquisa_ret := rw_lancamento.dtmvtolt;

              -- Abrir cursor da crapret 
              FOR rw_crapret IN cr_crapret_977(pr_cdcooper => rw_lancamento.cdcooper 
                                              ,pr_nrdconta => rw_lancamento.nrdconta
                                              ,pr_dtcredit => vr_dt_pesquisa_ret) LOOP
                
                vr_vldpagto := 0;
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_dtdpagto => rw_crapret.dtocorre
                               ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto INTO rw_boleto;
                vr_found_boleto := cr_boleto%FOUND;
                CLOSE cr_boleto;

                -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
                IF NOT vr_found_boleto THEN
                  -- Buscar os dados do boleto que esta sendo pago
                  OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                   ,pr_nrdconta => rw_crapret.nrdconta
                                   ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                   ,pr_nrdocmto => rw_crapret.nrdocmto);
                  FETCH cr_boleto_2 INTO rw_boleto;
                  vr_found_boleto := cr_boleto_2%FOUND;
                  CLOSE cr_boleto_2;
                END IF;
                  
                -- Encontrou boleto ?
                IF vr_found_boleto THEN
                  vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                  vr_inpessoa := '';
                  vr_nrcpfcgc := '';
                  vr_nmprimtl := '';
                  
                  -- Busca dados do pagador
                  IF rw_boleto.nrinssac > 0 THEN
                    -- Buscar Pagador
                    OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                    ,pr_nrdconta => rw_lancamento.nrdconta
                                    ,pr_nrinssac => rw_boleto.nrinssac);
                    FETCH cr_pagador INTO rw_pagador;
                    IF cr_pagador%FOUND THEN
                      vr_inpessoa := rw_pagador.cdtpinsc;
                      vr_nrcpfcgc := rw_pagador.nrinssac;
                      vr_nmprimtl := rw_pagador.nmdsacad;
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_pagador;
                  END IF;-- Dados do pagador
            
                  vrins_nrdocmto := rw_boleto.nrdocmto;
                  vrins_cdbandep := rw_boleto.cdbanpag;
                  vrins_cdagedep := rw_boleto.cdagepag;
                  vrins_nrctadep := '';
                  vrins_tpdconta := '';
                  vrins_inpessoa := vr_inpessoa;
                  vrins_nrcpfcgc := vr_nrcpfcgc;
                  vrins_nmprimtl := vr_nmprimtl;
                  vrins_tpdocttl := '';
                  vrins_nrdocttl := '';
                  vrins_dscodbar := '';
                  vrins_nmendoss := '';
                  vrins_docendos := '';
                  vrins_idsitide := '0'; -- Fixo ZERO
                  vrins_dsobserv := '';
                  
                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 4';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                  
                  pc_atualiza_tbjur(rw_lancamento.rowid);

                  vr_registro := TRUE;
                END IF;
              END LOOP;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 977

            IF vr_cdestsig = 5 OR vr_cdestsig = 0 THEN -- Credito Cobranca 
              vr_registro := FALSE;

              -- Abrir cursor da crapret 
              FOR rw_crapret IN cr_crapret_987(pr_cdcooper => rw_lancamento.cdcooper 
                                              ,pr_nrdconta => rw_lancamento.nrdconta
                                              ,pr_dtcredit => rw_lancamento.dtmvtolt) LOOP
                
                vr_vldpagto := 0;
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_dtdpagto => rw_crapret.dtocorre
                               ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto INTO rw_boleto;
                vr_found_boleto := cr_boleto%FOUND;
                CLOSE cr_boleto;

                -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
                IF NOT vr_found_boleto THEN
                  -- Buscar os dados do boleto que esta sendo pago
                  OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                   ,pr_nrdconta => rw_crapret.nrdconta
                                   ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                   ,pr_nrdocmto => rw_crapret.nrdocmto);
                  FETCH cr_boleto_2 INTO rw_boleto;
                  vr_found_boleto := cr_boleto_2%FOUND;
                  CLOSE cr_boleto_2;
                END IF;

                -- Encontrou boleto ?
                IF vr_found_boleto THEN
                  vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                  vr_inpessoa := '';
                  vr_nrcpfcgc := '';
                  vr_nmprimtl := '';

                  -- Busca dados do pagador
                  IF rw_boleto.nrinssac > 0 THEN
                    -- Buscar Pagador
                    OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                    ,pr_nrdconta => rw_lancamento.nrdconta
                                    ,pr_nrinssac => rw_boleto.nrinssac);
                    FETCH cr_pagador INTO rw_pagador;
                    IF cr_pagador%FOUND THEN
                      vr_inpessoa := rw_pagador.cdtpinsc;
                      vr_nrcpfcgc := rw_pagador.nrinssac;
                      vr_nmprimtl := rw_pagador.nmdsacad;
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_pagador;
                  END IF;-- Dados do pagador
            
                  vrins_nrdocmto := rw_boleto.nrdocmto;
                  vrins_cdbandep := rw_boleto.cdbanpag;
                  vrins_cdagedep := rw_boleto.cdagepag;
                  vrins_nrctadep := '';
                  vrins_tpdconta := '';
                  vrins_inpessoa := vr_inpessoa;
                  vrins_nrcpfcgc := vr_nrcpfcgc;
                  vrins_nmprimtl := vr_nmprimtl;
                  vrins_tpdocttl := '';
                  vrins_nrdocttl := '';
                  vrins_dscodbar := '';
                  vrins_nmendoss := '';
                  vrins_docendos := '';
                  vrins_idsitide := '0'; -- Fixo ZERO
                  vrins_dsobserv := '';
                  
                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 5';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                  
                  pc_atualiza_tbjur(rw_lancamento.rowid);
                  
                  vr_registro := TRUE;
                END IF;
              END LOOP;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 987

            IF vr_cdestsig = 6 OR vr_cdestsig = 0 THEN -- Credito Cobranca 
              vr_registro := FALSE;

              -- Abrir cursor da crapret 
              FOR rw_crapret IN cr_crapret_1089(pr_cdcooper => rw_lancamento.cdcooper 
                                               ,pr_nrdconta => rw_lancamento.nrdconta
                                               ,pr_dtcredit => rw_lancamento.dtmvtolt) LOOP
                                               
                vr_vldpagto := 0;
                -- Buscar os dados do boleto que esta sendo pago
                OPEN cr_boleto (pr_cdcooper => rw_crapret.cdcooper 
                               ,pr_nrdconta => rw_crapret.nrdconta
                               ,pr_dtdpagto => rw_crapret.dtocorre
                               ,pr_nrdocmto => rw_crapret.nrdocmto);
                FETCH cr_boleto INTO rw_boleto;
                vr_found_boleto := cr_boleto%FOUND;
                CLOSE cr_boleto;

                -- Se não encontrou o boleto com a data de pagamento, vamos buscar pelo número
                IF NOT vr_found_boleto THEN
                  -- Buscar os dados do boleto que esta sendo pago
                  OPEN cr_boleto_2 (pr_cdcooper => rw_crapret.cdcooper 
                                   ,pr_nrdconta => rw_crapret.nrdconta
                                   ,pr_nrcnvcob => rw_crapret.nrcnvcob
                                   ,pr_nrdocmto => rw_crapret.nrdocmto);
                  FETCH cr_boleto_2 INTO rw_boleto;
                  vr_found_boleto := cr_boleto_2%FOUND;
                  CLOSE cr_boleto_2;
                END IF;

                -- Encontrou boleto ?
                IF vr_found_boleto THEN

                  vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                  vr_inpessoa := '';
                  vr_nrcpfcgc := '';
                  vr_nmprimtl := '';
                  
                  -- Busca dados do pagador
                  IF rw_boleto.nrinssac > 0 THEN
                    -- Buscar Pagador
                    OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                    ,pr_nrdconta => rw_lancamento.nrdconta
                                    ,pr_nrinssac => rw_boleto.nrinssac);
                    FETCH cr_pagador INTO rw_pagador;
                    IF cr_pagador%FOUND THEN
                      vr_inpessoa := rw_pagador.cdtpinsc;
                      vr_nrcpfcgc := rw_pagador.nrinssac;
                      vr_nmprimtl := rw_pagador.nmdsacad;
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_pagador;
                  END IF;-- Dados do pagador
            
                  vrins_nrdocmto := rw_boleto.nrdocmto;
                  vrins_cdbandep := rw_boleto.cdbanpag;
                  vrins_cdagedep := rw_boleto.cdagepag;
                  vrins_nrctadep := '';
                  vrins_tpdconta := '';
                  vrins_inpessoa := vr_inpessoa;
                  vrins_nrcpfcgc := vr_nrcpfcgc;
                  vrins_nmprimtl := vr_nmprimtl;
                  vrins_tpdocttl := '';
                  vrins_nrdocttl := '';
                  vrins_dscodbar := '';
                  vrins_nmendoss := '';
                  vrins_docendos := '';
                  vrins_idsitide := '0'; -- Fixo ZERO
                  vrins_dsobserv := '';

                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 6';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                  
                  pc_atualiza_tbjur(rw_lancamento.rowid);

                  vr_registro := TRUE;
                END IF;
              END LOOP;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 1089

            IF vr_cdestsig = 7 OR vr_cdestsig = 0 THEN -- Credito de Cobrança
              vr_registro := FALSE;
              vr_vldpagto := 0;
              
              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_boleto (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_dtdpagto => rw_lancamento.dtmvtolt
                             ,pr_nrdocmto => to_number(SUBSTR(to_char(rw_lancamento.nrdocmto),5,6)));
              FETCH cr_boleto INTO rw_boleto;
              -- Encontrou boleto ?
              IF cr_boleto%FOUND THEN
                vr_vldpagto := vr_vldpagto + rw_boleto.vldpagto;
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                -- Busca dados do pagador
                IF rw_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador
              
                vrins_nrdocmto := rw_boleto.nrdocmto;
                vrins_cdbandep := rw_boleto.cdbanpag;
                vrins_cdagedep := rw_boleto.cdagepag;
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';  

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 7';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;
              -- Fechar cursor
              CLOSE cr_boleto;

              IF vr_vldpagto <> rw_lancamento.vllanmto  THEN
                vr_idx_err := vr_tberro.COUNT + 1;
                vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO - LOOP';
                vr_tberro(vr_idx_err).dserro   := '2 - ' ||
                                                  'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                  'Valor Calculado: ' || vr_vldpagto || '  ' || 
                                                  'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
                                                  'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                  'ID: ' || rw_lancamento.progress_recid;
              END IF;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 654

            IF vr_cdestsig = 8 OR vr_cdestsig = 0 THEN -- Deb. Bloq. de Cheque em Custodia
              vr_registro := FALSE;
              
              FOR rw_custodia_cheque IN cr_custodia_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                                                           ,pr_nrdconta => rw_lancamento.nrdconta
                                                           ,pr_nrdocmto => rw_lancamento.nrdocmto) LOOP

                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';

                IF rw_custodia_cheque.cdbanchq = 85 THEN
                  OPEN  cr_cooperativa(pr_cdagectl => rw_custodia_cheque.cdagechq);
                  FETCH cr_cooperativa INTO rw_cooperativa;
                  --
                  IF cr_cooperativa%FOUND THEN
                    OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
                                      ,pr_nrdconta => rw_custodia_cheque.nrctachq);
                    FETCH cr_cooperado INTO rw_cooperado;
                    IF cr_cooperado%FOUND THEN
                      vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
                      vr_nmprimtl := rw_cooperado.nmprimtl;
                    END IF;
                    CLOSE cr_cooperado;
                  END IF;
                  --
                  CLOSE cr_cooperativa;               
                ELSE              
                  IF vr_idicfjud = 1 THEN
                    OPEN  cr_crapicf (pr_cdcooper => rw_conta.cdcooper
                                     ,pr_dacaojud => Upper(vr_dacaojud)
                                     ,pr_nrctareq => rw_custodia_cheque.nrctachq
                                     ,pr_cdbanreq => rw_custodia_cheque.cdbanchq
                                     ,pr_cdagereq => rw_custodia_cheque.cdagechq );
                    FETCH cr_crapicf INTO rw_crapicf;
                    -- Verificar se não encontra a informação na tabela CRAPICF.
                    IF cr_crapicf%NOTFOUND THEN
                      BEGIN
                        INSERT INTO crapicf
                          (cdcooper
                          ,nrctaori
                          ,cdbanori
                          ,cdbanreq
                          ,cdagereq
                          ,nrctareq
                          ,intipreq
                          ,dacaojud
                          ,dtmvtolt
                          ,dtinireq
                          ,cdoperad
                          ,dsdocmc7
                          ,dtdopera
                          ,vldopera
                          ,tpctapes)
                        VALUES
                          (rw_conta.cdcooper
                          ,rw_conta.nrdconta
                          ,85
                          ,rw_custodia_cheque.cdbanchq
                          ,rw_custodia_cheque.cdagechq
                          ,rw_custodia_cheque.nrctachq
                          ,1
                          ,UPPER(vr_dacaojud)
                          ,TRUNC(SYSDATE)
                          ,TRUNC(SYSDATE)
                          ,'1'
                          ,rw_custodia_cheque.dsdocmc7
                          ,rw_lancamento.dtmvtolt
                          ,rw_custodia_cheque.vlcheque
                          ,'01');
                        --
                        vr_idx_cheques_icfjud := vr_tbarq_cheques_icfjud.COUNT + 1;
                        --
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);              
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_custodia_cheque.cdbanchq; 
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_custodia_cheque.cdagechq; 
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_custodia_cheque.nrctachq; 
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                           
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_custodia_cheque.dsdocmc7;
                        
                        vrins_idsitqbr := 5;
                        vrins_dsobsqbr := 'Registro incluido para busca ICFJUD em '||to_char(SYSDATE,'DD/MM/RRRR');
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_idx_err := vr_tberro.COUNT + 1;
                          vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico - 881 - LOOP';
                          vr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
                                                            'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                            'Valor Cheque: ' || rw_custodia_cheque.vlcheque || '  ' || 
                                                            'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                            'ID: ' || rw_lancamento.progress_recid ||  '  ' || 
                                                            'Erro: '|| SQLERRM;
                                                            
                      END;
                    ELSE
                      vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
                      vr_nmprimtl := rw_crapicf.nmprimtl;
                    END IF;
                    --
                    CLOSE cr_crapicf;
                  END IF;
                END IF;

                vrins_nrdocmto := rw_custodia_cheque.nrdocmto;
                vrins_cdbandep := rw_custodia_cheque.cdbanchq;
                vrins_cdagedep := rw_custodia_cheque.cdagechq;
                vrins_nrctadep := rw_custodia_cheque.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF  rw_lancamento.idsitqbr = 5
                AND nvl(vr_nrcpfcgc,0) = 0 THEN
                  --Se registro ja foi incluido no ICF e ainda nao possui as informacoes, mantem situacao 5
                  vrins_idsitqbr := 5;
                ELSE
                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 8';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                END IF;

                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END LOOP;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 881

            IF vr_cdestsig = 9 OR vr_cdestsig = 0 THEN -- Deb. CHEQUE Propria Cooperativa
              vr_registro := FALSE;
              -- Gerar o numero do documento
              vr_nrdocmto := to_number( SUBSTR(to_char(rw_lancamento.nrdocmto),1,( LENGTH(to_char(rw_lancamento.nrdocmto)) - 3 )) || '022' );
              -- Buscar os dados do cheque
              OPEN cr_cheque_085 (pr_cdcooper => rw_lancamento.cdcooper 
                                 ,pr_nrdconta => rw_lancamento.nrdconta
                                 ,pr_nrdocmto => vr_nrdocmto);
              FETCH cr_cheque_085 INTO rw_cheque_085;
              -- Encontrou o cheque ?
              IF cr_cheque_085%FOUND THEN
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                vr_cdagenci := '';

                -- Buscar a conta de quem depositou o cheque
                OPEN cr_conta_aux (pr_cdagectl => rw_cheque_085.cdagechq
                                  ,pr_nrdconta => rw_cheque_085.nrctachq);
                FETCH cr_conta_aux INTO rw_conta_aux;
                IF cr_conta_aux%FOUND THEN
                  vr_inpessoa := rw_conta_aux.inpessoa;
                  vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                  vr_nmprimtl := rw_conta_aux.nmprimtl;
                  vr_cdagenci := rw_conta_aux.cdagenci;
                END IF;
                -- Fechar Cursor
                CLOSE cr_conta_aux;

                vrins_cdbandep := '085';
                vrins_cdagedep := vr_cdagenci;
                vrins_nrctadep := rw_cheque_085.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 9';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;

                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;
              -- Fechar cursor
              CLOSE cr_cheque_085;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 386

            IF vr_cdestsig = 10 OR vr_cdestsig = 0 THEN -- Credito de Transferencia Via Internet
              vr_registro := FALSE;

              vr_nrdconta := to_number( SUBSTR(rw_lancamento.cdpesqbb,45,8));
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';

              -- Buscar os dados da conta que fez a transferencia
              OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcooper
                                 ,pr_nrdconta => vr_nrdconta);
              FETCH cr_conta_aux2 INTO rw_conta_aux2;
              -- Encontrou a conta?
              IF cr_conta_aux2%FOUND THEN
                vr_inpessoa := rw_conta_aux2.inpessoa;
                vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux2.nmprimtl;
                vr_cdagenci := rw_conta_aux2.cdagenci;
                
                vrins_cdbandep := '085';
                vrins_cdagedep := vr_cdagenci;
                vrins_nrctadep := rw_lancamento.nrdconta;
                vrins_tpdconta := '4'; -- Outros
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 10';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);
                
                vr_registro := TRUE;
              END IF;

              -- Fechar Cursor
              CLOSE cr_conta_aux2;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historicos 537, 538, 539
            
            IF vr_cdestsig = 11 OR vr_cdestsig = 0 THEN -- Transferencia Intercooperativa
              vr_registro := FALSE;

              vr_nrdconta := rw_lancamento.nrdctabb;
              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';
              
              -- Buscar os dados da conta que fez a transferencia
              OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcoptfn
                                 ,pr_nrdconta => vr_nrdconta);
              FETCH cr_conta_aux2 INTO rw_conta_aux2;
              -- Encontrou a conta?
              IF cr_conta_aux2%FOUND THEN
                vr_inpessoa := rw_conta_aux2.inpessoa;
                vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux2.nmprimtl;
                vr_cdagenci := rw_conta_aux2.cdagenci;
                
                vrins_cdbandep := '085';
                vrins_cdagedep := vr_cdagenci;
                vrins_nrctadep := rw_lancamento.nrdconta;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 11';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);
                
                vr_registro := TRUE;
              END IF;

              -- Fechar Cursor
              CLOSE cr_conta_aux2;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historicos 1009, 1014, 1011, 1015

            IF vr_cdestsig = 12 OR vr_cdestsig = 0 THEN -- Transferencia Cooperativa
              vr_registro := FALSE;
            
              IF rw_lancamento.cdhistor = 771 THEN
                vr_nrdconta := to_number(SUBSTR(rw_lancamento.cdpesqbb,45,8));
              ELSE
                vr_nrdconta := rw_lancamento.cdpesqbb;
              END IF;

              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';
              
              -- Buscar os dados da conta que fez a transferencia
              OPEN cr_conta_aux2 (pr_cdcooper => rw_lancamento.cdcooper
                                 ,pr_nrdconta => vr_nrdconta);
              FETCH cr_conta_aux2 INTO rw_conta_aux2;
              -- Encontrou a conta?
              IF cr_conta_aux2%FOUND THEN
                vr_inpessoa := rw_conta_aux2.inpessoa;
                vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                vr_nmprimtl := rw_conta_aux2.nmprimtl;
                vr_cdagenci := rw_conta_aux2.cdagenci;
                
                vrins_cdbandep := '085';
                vrins_cdagedep := vr_cdagenci;
                vrins_nrctadep := rw_lancamento.nrdconta;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 12';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);
                
                vr_registro := TRUE;
              END IF;

              -- Fechar Cursor
              CLOSE cr_conta_aux2;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historicos 302, 771, 303

            IF vr_cdestsig = 13 OR vr_cdestsig = 0 THEN -- Deb. CHEQUE Praca e Fora Praca 
              vr_registro := FALSE;

              FOR rw_all_cheques IN cr_all_cheques(pr_cdcooper => rw_lancamento.cdcooper
                                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                                  ,pr_nrdocmto => rw_lancamento.nrdocmto) LOOP
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- cdbanchq=85 o Banco do Cheque é da AILOS
                IF rw_all_cheques.cdbanchq = 85 THEN
                  OPEN  cr_cooperativa(pr_cdagectl => rw_all_cheques.cdagechq);
                  FETCH cr_cooperativa INTO rw_cooperativa;
                  --
                  IF cr_cooperativa%FOUND THEN
                    OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
                                      ,pr_nrdconta => rw_all_cheques.nrctachq);
                    FETCH cr_cooperado INTO rw_cooperado;
                    IF cr_cooperado%FOUND THEN
                      vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
                      vr_nmprimtl := rw_cooperado.nmprimtl;
                    END IF;
                    CLOSE cr_cooperado;
                  END IF;
                  --
                  CLOSE cr_cooperativa;
                ELSE
                  IF vr_idicfjud = 1 THEN
                    OPEN  cr_crapicf (pr_cdcooper => rw_conta.cdcooper
                                     ,pr_dacaojud => Upper(vr_dacaojud)
                                     ,pr_nrctareq => rw_all_cheques.nrctachq
                                     ,pr_cdbanreq => rw_all_cheques.cdbanchq
                                     ,pr_cdagereq => rw_all_cheques.cdagechq );
                    FETCH cr_crapicf INTO rw_crapicf;
                    -- Verificar se não encontra a informação na tabela CRAPICF.
                    IF cr_crapicf%NOTFOUND THEN                               
                      BEGIN
                        INSERT INTO crapicf
                          (cdcooper
                          ,nrctaori
                          ,cdbanori
                          ,cdbanreq
                          ,cdagereq
                          ,nrctareq
                          ,intipreq
                          ,dacaojud
                          ,dtmvtolt
                          ,dtinireq
                          ,cdoperad
                          ,dsdocmc7
                          ,dtdopera
                          ,vldopera
                          ,tpctapes)
                        VALUES
                          (rw_conta.cdcooper
                          ,rw_conta.nrdconta
                          ,85
                          ,rw_all_cheques.cdbanchq
                          ,rw_all_cheques.cdagechq
                          ,rw_all_cheques.nrctachq
                          ,1
                          ,UPPER(vr_dacaojud)
                          ,TRUNC(SYSDATE)
                          ,TRUNC(SYSDATE)
                          ,'1'
                          ,rw_all_cheques.dsdocmc7
                          ,rw_lancamento.dtmvtolt
                          ,rw_all_cheques.vlcheque
                          ,'01');
                        --
                        vr_idx_cheques_icfjud := vr_tbarq_cheques_icfjud.COUNT + 1;
                        --                
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);          
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_all_cheques.cdbanchq;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_all_cheques.cdagechq;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_all_cheques.nrctachq;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                      
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_all_cheques.dsdocmc7;
                        
                        vrins_idsitqbr := 5;
                        vrins_dsobsqbr := 'Registro incluido para busca ICFJUD em '||to_char(SYSDATE,'DD/MM/RRRR');
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_idx_err := vr_tberro.COUNT + 1;
                          vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico 372 - LOOP';
                          vr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
                                              'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                              'Valor Cheque: ' || rw_all_cheques.vlcheque || '  ' || 
                                              'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                              'ID: ' || rw_lancamento.progress_recid || '  ' || 
                                              'Erro: '|| SQLERRM;
                      END;
                    ELSE
                      vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
                      vr_nmprimtl := rw_crapicf.nmprimtl;                 
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_crapicf;
                  END IF;
                END IF;
                    
                vrins_cdbandep := rw_all_cheques.cdbanchq;
                vrins_cdagedep := rw_all_cheques.cdagechq;
                vrins_nrctadep := rw_all_cheques.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF  rw_lancamento.idsitqbr = 5
                AND nvl(vr_nrcpfcgc,0) = 0 THEN
                  --Se registro ja foi incluido no ICF e ainda nao possui as informacoes, mantem situacao 5
                  vrins_idsitqbr := 5;
                ELSE
                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 13';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                END IF;

                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END LOOP;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historicos 3, 4, 372                                

            IF vr_cdestsig = 14 OR vr_cdestsig = 0 THEN -- Folha de Pagamento
              vr_registro := FALSE;
              -- Valor inicial = FOLHA VELHA não encontrada
              vr_encontrou_folha_velha := FALSE;
              
              -- Buscar o código da empresa, para identificar os dados da folha de pagamentos
              OPEN cr_empresa(pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta);
              FETCH cr_empresa INTO rw_empresa;
              -- Verifica se encontrou a empresa
              IF cr_empresa%FOUND THEN
                -- Fecha cursor
                CLOSE cr_empresa;
                
                -- Buscar o lote da empresa
                vr_lote_empres := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_lancamento.cdcooper 
                                                            ,pr_nmsistem => 'CRED'
                                                            ,pr_tptabela => 'GENERI'
                                                            ,pr_cdempres => 0
                                                            ,pr_cdacesso => 'NUMLOTEFOL'
                                                            ,pr_tpregist => rw_empresa.cdempres) ;

                -- Antes dessa data o lote era incrementado em 1                                            
                IF rw_lancamento.dtmvtolt < to_date('10/12/2015','dd/mm/yyyy') THEN
                  vr_lote_empres := vr_lote_empres + 1;
                END IF;
                
                -- Verificar o valor total da folha velha
                OPEN cr_total_folha_velha(pr_cdcooper => rw_lancamento.cdcooper 
                                         ,pr_nrdolote => vr_lote_empres
                                         ,pr_cdempres => rw_empresa.cdempres
                                         ,pr_dtmvtolt => rw_lancamento.dtmvtolt);
                FETCH cr_total_folha_velha INTO rw_total_folha_velha;
                -- Encontrou a folha ?
                IF cr_total_folha_velha%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_total_folha_velha;
                    
                  -- Verificar se o valor da Folha que foi paga é igual ao lançamento
                  IF rw_total_folha_velha.total = rw_lancamento.vllanmto THEN
                    -- Encontrou o valor correspondente na FOLHA VELHA
                    vr_encontrou_folha_velha := TRUE;

                    -- Se for igual, vamos enviar os lançamentos individuais
                    -- Caso conta não seja o mesmo valor, será enviado de forma consolidada
                      
                    -- Percorrer todos os lançamentos da folha de pagamento CRAPLCM e CRAPLCS
                    FOR rw_lancto_folha_velha IN cr_lancto_folha_velha(pr_cdcooper => rw_lancamento.cdcooper 
                                                                      ,pr_nrdolote => vr_lote_empres
                                                                      ,pr_cdempres => rw_empresa.cdempres
                                                                      ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP
                      -- Inicializar variaveis
                      vr_inpessoa := '';
                      vr_nrcpfcgc := '';
                      vr_nmprimtl := '';
                      vr_cdagenci := '';
                      vr_cdbandep := '';
                      vr_nrctadep := 0;
        	                  
                      -- Verificar se o tipo de lançamento eh "C" - Conta Corrente
                      IF rw_lancto_folha_velha.idtpcont = 'C' THEN
                        -- Buscar os dados da conta que fez a transferencia
                        OPEN cr_conta_aux2 (pr_cdcooper => rw_lancto_folha_velha.cdcooper
                                           ,pr_nrdconta => rw_lancto_folha_velha.nrdconta);
                        FETCH cr_conta_aux2 INTO rw_conta_aux2;
                        -- Encontrou a conta?
                        IF cr_conta_aux2%FOUND THEN
                          vr_inpessoa := rw_conta_aux2.inpessoa;
                          vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                          vr_nmprimtl := rw_conta_aux2.nmprimtl;
                          vr_cdagenci := rw_conta_aux2.cdagenci;
                          vr_cdbandep := '085';
                          vr_nrctadep := rw_lancto_folha_velha.nrdconta;
                        END IF;
                        -- Fechar Cursor
                        CLOSE cr_conta_aux2;

                      -- Verificar se o tipo de lançamento eh "T" - Transferencia Conta Salário
                      ELSIF rw_lancto_folha_velha.idtpcont = 'T' THEN
                        -- Buscar os dados da conta salario
                        OPEN cr_conta_salario (pr_cdcooper => rw_lancto_folha_velha.cdcooper
                                              ,pr_nrdconta => rw_lancto_folha_velha.nrdconta);
                        FETCH cr_conta_salario INTO rw_conta_salario;
                        -- Encontrou a conta?
                        IF cr_conta_salario%FOUND THEN
                          vr_inpessoa := '1'; -- Pessoa Fisica
                          vr_nrcpfcgc := rw_conta_salario.nrcpfcgc;
                          vr_nmprimtl := rw_conta_salario.nmfuncio;
                          vr_cdagenci := rw_conta_salario.cdagetrf;
                          vr_cdbandep := rw_conta_salario.cdbantrf;
                          vr_nrctadep := rw_conta_salario.nrctatrf;
                        END IF;
                        -- Fechar Cursor
                        CLOSE cr_conta_salario;
                          
                      END IF;
                        
                      vrins_cdbandep := vr_cdbandep;
                      vrins_cdagedep := vr_cdagenci;
                      vrins_nrctadep := vr_nrctadep;
                      vrins_tpdconta := '';
                      vrins_inpessoa := vr_inpessoa;
                      vrins_nrcpfcgc := vr_nrcpfcgc;
                      vrins_nmprimtl := vr_nmprimtl;
                      vrins_tpdocttl := '';
                      vrins_nrdocttl := '';
                      vrins_dscodbar := '';
                      vrins_nmendoss := '';
                      vrins_docendos := '';
                      vrins_idsitide := '0'; -- Fixo ZERO
                      vrins_dsobserv := '';
                      
                      IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                        vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                      ELSE 
                        vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                      END IF;
                      
                      IF vr_cdestsig = 0 THEN
                        vrins_idsitqbr := 2;
                        vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 14';
                      ELSE
                        vrins_idsitqbr := 1;
                        vrins_dsobsqbr := '';
                      END IF;
                      
                      pc_atualiza_tbjur(rw_lancamento.rowid);

                      vr_registro := TRUE;
                    END LOOP; -- LOOP Folha nova
                  END IF; -- Total da folha velha
                  
                ELSE
                  -- Fecha cursor
                  CLOSE cr_total_folha_velha;
                END IF; -- Encontrou total folha velha ?
              
                -- Se encontrou a folha de pagamento velha, não pesquisa a folha de pagamento nova
                IF NOT vr_encontrou_folha_velha THEN
                  -- Verificar o valor total da folha nova
                  OPEN cr_total_folha_nova(pr_cdcooper => rw_lancamento.cdcooper
                                          ,pr_nrdconta => rw_lancamento.nrdconta
                                          ,pr_dtmvtolt => rw_lancamento.dtmvtolt);
                  FETCH cr_total_folha_nova INTO rw_total_folha_nova;
                  IF cr_total_folha_nova%FOUND THEN
                    -- Fecha cursor
                    CLOSE cr_total_folha_nova;
                    
                    -- Verificar se o valor da Folha que foi paga é igual ao lançamento
                    IF rw_total_folha_nova.vllctpag = rw_lancamento.vllanmto THEN
                      -- Se for igual, vamos enviar os lançamentos individuais
                      -- Caso conta não seja o mesmo valor, será enviado de forma consolidada
                      
                      -- Percorrer todos os lançamentos da folha de pagamento CRAPLPF - Lançamento de FOLHA
                      FOR rw_lancto_folha_nova IN cr_lancto_folha_nova(pr_cdcooper => rw_lancamento.cdcooper
                                                                      ,pr_nrdconta => rw_lancamento.nrdconta
                                                                      ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP
                        -- Inicializar variaveis
                        vr_inpessoa := '';
                        vr_nrcpfcgc := '';
                        vr_nmprimtl := '';
                        vr_cdagenci := '';
                        vr_cdbandep := '';
                        vr_nrctadep := 0;
        	                  
                        -- Verificar se o tipo de lançamento eh "C" - Conta Corrente
                        IF rw_lancto_folha_nova.idtpcont = 'C' THEN
                          -- Buscar os dados da conta que fez a transferencia
                          OPEN cr_conta_aux2 (pr_cdcooper => rw_lancto_folha_nova.cdcooper
                                             ,pr_nrdconta => rw_lancto_folha_nova.nrdconta);
                          FETCH cr_conta_aux2 INTO rw_conta_aux2;
                          -- Encontrou a conta?
                          IF cr_conta_aux2%FOUND THEN
                            vr_inpessoa := rw_conta_aux2.inpessoa;
                            vr_nrcpfcgc := rw_conta_aux2.nrcpfcgc;
                            vr_nmprimtl := rw_conta_aux2.nmprimtl;
                            vr_cdagenci := rw_conta_aux2.cdagenci;
                            vr_cdbandep := '085';
                            vr_nrctadep := rw_lancto_folha_nova.nrdconta;
                          END IF;
                          -- Fechar Cursor
                          CLOSE cr_conta_aux2;

                        -- Verificar se o tipo de lançamento eh "T" - Transferencia Conta Salário
                        ELSIF rw_lancto_folha_nova.idtpcont = 'T' THEN
                          -- Buscar os dados da conta salario
                          OPEN cr_conta_salario (pr_cdcooper => rw_lancto_folha_nova.cdcooper
                                                ,pr_nrdconta => rw_lancto_folha_nova.nrdconta);
                          FETCH cr_conta_salario INTO rw_conta_salario;
                          -- Encontrou a conta?
                          IF cr_conta_salario%FOUND THEN
                            vr_inpessoa := '1'; -- Pessoa Fisica
                            vr_nrcpfcgc := rw_conta_salario.nrcpfcgc;
                            vr_nmprimtl := rw_conta_salario.nmfuncio;
                            vr_cdagenci := rw_conta_salario.cdagetrf;
                            vr_cdbandep := rw_conta_salario.cdbantrf;
                            vr_nrctadep := rw_conta_salario.nrctatrf;
                          END IF;
                          -- Fechar Cursor
                          CLOSE cr_conta_salario;
                          
                        END IF;
                        
                        vrins_cdbandep := vr_cdbandep;
                        vrins_cdagedep := vr_cdagenci;
                        vrins_nrctadep := vr_nrctadep;
                        vrins_tpdconta := '';
                        vrins_inpessoa := vr_inpessoa;
                        vrins_nrcpfcgc := vr_nrcpfcgc;
                        vrins_nmprimtl := vr_nmprimtl;
                        vrins_tpdocttl := '';
                        vrins_nrdocttl := '';
                        vrins_dscodbar := '';
                        vrins_nmendoss := '';
                        vrins_docendos := '';
                        vrins_idsitide := '0'; -- Fixo ZERO
                        vrins_dsobserv := '';
                        
                        IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                          vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                        ELSE 
                          vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                        END IF;
                        
                        IF vr_cdestsig = 0 THEN
                          vrins_idsitqbr := 2;
                          vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 14';
                        ELSE
                          vrins_idsitqbr := 1;
                          vrins_dsobsqbr := '';
                        END IF;
                        
                        pc_atualiza_tbjur(rw_lancamento.rowid);

                        vr_registro := TRUE;
                      END LOOP; -- LOOP Folha nova
                      
                    END IF; -- Valor total da folha de pagamento nova
                  
                  ELSE 
                    -- Fecha cursor
                    CLOSE cr_total_folha_nova;
                    
                  END IF; -- Encontrou total folha nova ? 
                  
                END IF; -- Encontrou folha velha ? 
              
              END IF; -- Encontrou cadastro da EMPRESA
                  
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 889

            IF vr_cdestsig = 15 OR vr_cdestsig = 0 THEN -- Credito TED
              vr_registro := FALSE;

              --pesquisar teds
              FOR rw_ted IN cr_ted578(pr_cdcooper => rw_lancamento.cdcooper
                                     ,pr_nrdconta => rw_lancamento.nrdconta
                                     ,pr_dtmvtolt => rw_lancamento.dtmvtolt
                                     ,pr_vllanmto => rw_lancamento.vllanmto) LOOP

                vrins_cdbandep := rw_ted.banco;
                vrins_tpdconta := '';
                vrins_inpessoa := '';
                vrins_nrcpfcgc := rw_ted.nrcpfdif;
                vrins_nmprimtl := rw_ted.nmtitdif;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;

                -- Verificar se a Conta do Depositante existe
                IF rw_ted.nrctadif > 0 THEN
                  -- Se a conta existir mandamos os dados do Depositante
                  vrins_cdagedep := rw_ted.cdagedif;
                  vrins_nrctadep := rw_ted.nrctadif;
                ELSE
                  -- Caso o depositante/favorecido não possua conta no banco, 
                  -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
                  --              9999, 99999999999999999999 e NAO­CORRENTISTA 
                  vrins_cdagedep := 9999;
                  vrins_nrctadep := 99999999999999999999;
                  vrins_dsobserv := 'NAO­CORRENTISTA';
                END IF;

                -- Se a TED nao possui CPF de origem e o banco eh o 756 (Bancoob)
                -- Iremos adicionar o CNPJ do banco como origem
                IF rw_ted.nrcpfdif = 0   AND 
                   rw_ted.banco    = 756 THEN
                  vrins_nrcpfcgc := 02038232000164;
                ELSE
                  vrins_nrcpfcgc := rw_ted.nrcpfdif;
                END IF;

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 15';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;

                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;

              END LOOP;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF;-- Historico 578 estrutura 15

            IF vr_cdestsig = 16 THEN -- Credito DOC
              vrins_cdbandep := rw_lancamento.cdbanchq;
              vrins_cdagedep := rw_lancamento.cdagechq;
              vrins_nrctadep := rw_lancamento.nrctachq;
              vrins_tpdconta := '';
              vrins_inpessoa := '';
              vrins_nrcpfcgc := '';
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';

              IF rw_lancamento.cdhistor = 575 THEN
                vrins_nmprimtl := substr(rw_lancamento.cdpesqbb,1,50);
              END IF;

              --A tela QBRSIG deve filtrar a situação "3-DOC - Informações devem ser informadas manualmente"
              --para incluir os CPF/CNPJ da pessoa debitada
              vrins_idsitqbr := 3;
              vrins_dsobsqbr := 'As informacoes de DOC devem ser informadas manualmente.';

              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF; -- Historico 548,575

            IF vr_cdestsig = 17 OR vr_cdestsig = 0 THEN -- Acerto Cheque Extra Caixa
              vr_registro := FALSE;
              -- Montar o numero do documento
              vr_nrdocmto := SUBSTR(to_char(rw_lancamento.nrdocmto), 1, (LENGTH(to_char(rw_lancamento.nrdocmto)) - 1 ));
              -- Buscar os dados do cheque
              OPEN cr_cheque (pr_cdcooper => rw_lancamento.cdcooper 
                             ,pr_nrdconta => rw_lancamento.nrdconta
                             ,pr_nrcheque => vr_nrdocmto);
              FETCH cr_cheque INTO rw_cheque;
              IF cr_cheque%FOUND THEN
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                vr_cdagenci := '';
                -- Buscar a conta de quem depositou o cheque
                OPEN cr_conta_aux (pr_cdagectl => rw_cheque.cdagedep
                                  ,pr_nrdconta => rw_cheque.nrctachq);
                FETCH cr_conta_aux INTO rw_conta_aux;
                IF cr_conta_aux%FOUND THEN
                  vr_inpessoa := rw_conta_aux.inpessoa;
                  vr_nrcpfcgc := rw_conta_aux.nrcpfcgc;
                  vr_nmprimtl := rw_conta_aux.nmprimtl;
                  vr_cdagenci := rw_conta_aux.cdagenci;
                END IF;
                -- Fechar Cursor
                CLOSE cr_conta_aux;
                
                vrins_cdbandep := '085';
                vrins_cdagedep := vr_cdagenci;
                vrins_nrctadep := rw_cheque.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 17';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF; -- Encontrou cheque
              -- Fechar Cursor
              CLOSE cr_cheque;
              
              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 521

            IF vr_cdestsig = 18 OR vr_cdestsig = 0 THEN --  Deb. TED 
              vr_registro := FALSE;

              -- Buscar o registro de transferencia de Valor
              OPEN cr_transf_valor (pr_cdcooper => rw_lancamento.cdcooper 
                                   ,pr_nrdconta => rw_lancamento.nrdconta
                                   ,pr_vldocrcb => rw_lancamento.vllanmto
                                   ,pr_dtmvtolt => rw_lancamento.dtmvtolt
                                   ,pr_nrdocmto => rw_lancamento.nrdocmto);
              FETCH cr_transf_valor INTO rw_transf_valor;
              -- Verificar se encontrou o registro
              IF cr_transf_valor%FOUND THEN
                
                -- Se o tamanho do documento for maior que 11 é pessoa jurídica
                IF length(rw_transf_valor.cpfcgrcb) > 11 THEN
                  vr_inpessoa := '2';
                ELSE
                  vr_inpessoa := '1';
                END IF;
                  
                -- Atualizar os sequenciais 
                vrins_cdbandep := rw_transf_valor.cdbccrcb;
                vrins_cdagedep := rw_transf_valor.cdagercb;
                vrins_nrctadep := rw_transf_valor.nrcctrcb;
                vrins_tpdconta := '1';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := rw_transf_valor.cpfcgrcb;
                vrins_nmprimtl := rw_transf_valor.nmpesrcb;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';
                
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 18';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              ELSIF vr_cdestsig <> 0 THEN
                vrins_cdbandep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := '';
                vrins_nrcpfcgc := '';
                vrins_nmprimtl := '';
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                -- Caso o depositante/favorecido não possua conta no banco, 
                -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
                --              9999, 99999999999999999999 e NAO­CORRENTISTA 
                vrins_cdagedep := 9999;
                vrins_nrctadep := 99999999999999999999;
                vrins_dsobserv := 'NAO­CORRENTISTA';
                  
                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 18';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;
                
              -- Fechar Cursor
              CLOSE cr_transf_valor;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historicos 503, 555
            
            IF vr_cdestsig = 19 THEN
              vrins_cdbandep := '085';
              vrins_cdagedep := '';
              vrins_nrctadep := '';
              vrins_tpdconta := '1';
              vrins_inpessoa := '2'; -- Juridica
              vrins_nrcpfcgc := '82639451000138';
              vrins_nmprimtl := rw_conta.nmextcop;
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';

              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              IF vr_cdestsig = 0 THEN
                vrins_idsitqbr := 2;
                vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 19';
              ELSE
                vrins_idsitqbr := 1;
                vrins_dsobsqbr := '';
              END IF;

              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF; -- Tipo Lancamento 102, 104, 105, 106, 107, 110  e Historicos 351, 399, 47, 15, 79, 501, 503, 597, 377, 613, 630, 320, 354, 658, 535, 504

            IF vr_cdestsig = 20 THEN -- Cheque Compensado
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              -- Buscar banco, agência e conta de depósito
              OPEN cr_crapfdc_524(pr_cdcooper => rw_conta.cdcooper
                                 ,pr_cdbanchq => rw_lancamento.cdbanchq
                                 ,pr_cdagechq => rw_lancamento.cdagechq
                                 ,pr_nrctachq => rw_lancamento.nrctachq
                                 ,pr_nrcheque => to_number(substr(to_char(rw_lancamento.nrdocmto), 0, length(to_char(rw_lancamento.nrdocmto)) -1))); -- Devemos pesquisar nr. do cheque sem o DV

              FETCH cr_crapfdc_524 INTO rw_crapfdc_524;

              IF cr_crapfdc_524%FOUND THEN            
                -- cdbanchq=85 o Banco do Cheque é da AILOS
                IF rw_crapfdc_524.cdbandep = 85 THEN
                  OPEN  cr_cooperativa(pr_cdagectl => rw_crapfdc_524.cdagedep);
                  FETCH cr_cooperativa INTO rw_cooperativa;
                  --
                  IF cr_cooperativa%FOUND THEN
                    OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper
                                      ,pr_nrdconta => rw_crapfdc_524.nrctadep);
                    FETCH cr_cooperado INTO rw_cooperado;
                    IF cr_cooperado%FOUND THEN
                      vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
                      vr_nmprimtl := rw_cooperado.nmprimtl;
                    END IF;
                    CLOSE cr_cooperado;
                  END IF;
                  --
                  CLOSE cr_cooperativa;
                ELSE
                  IF vr_idicfjud = 1 THEN
                    OPEN cr_crapicf (pr_cdcooper => rw_conta.cdcooper
                                    ,pr_dacaojud => Upper(vr_dacaojud)
                                    ,pr_nrctareq => rw_crapfdc_524.nrctadep
                                    ,pr_cdbanreq => rw_crapfdc_524.cdbandep
                                    ,pr_cdagereq => rw_crapfdc_524.cdagedep);
                    FETCH cr_crapicf INTO rw_crapicf;
                    -- Verificar se não encontra a informação na tabela CRAPICF.
                    IF cr_crapicf%NOTFOUND THEN 
                      --
                      BEGIN
                        INSERT INTO crapicf
                          (cdcooper
                          ,nrctaori
                          ,cdbanori
                          ,cdbanreq
                          ,cdagereq
                          ,nrctareq
                          ,intipreq
                          ,dacaojud
                          ,dtmvtolt
                          ,dtinireq
                          ,cdoperad
                          ,dsdocmc7
                          ,dtdopera
                          ,vldopera                     
                          ,tpctapes)
                        VALUES
                          (rw_conta.cdcooper
                          ,rw_conta.nrdconta
                          ,85
                          ,rw_crapfdc_524.cdbandep
                          ,rw_crapfdc_524.cdagedep
                          ,rw_crapfdc_524.nrctadep
                          ,1
                          ,UPPER(vr_dacaojud)
                          ,TRUNC(SYSDATE)
                          ,TRUNC(SYSDATE)
                          ,'1'
                          ,rw_crapfdc_524.dsdocmc7
                          ,rw_lancamento.dtmvtolt
                          ,rw_lancamento.vllanmto                     
                          ,'02');
                        --
                        vr_idx_cheques_icfjud := vr_tbarq_cheques_icfjud.COUNT + 1;
                        --                
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dtinireq := TRUNC(SYSDATE);          
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdbanreq := rw_crapfdc_524.cdbandep;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).cdagereq := rw_crapfdc_524.cdagedep;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).nrctareq := rw_crapfdc_524.nrctadep;
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).intipreq := 1;                      
                        vr_tbarq_cheques_icfjud(vr_idx_cheques_icfjud).dsdocmc7 := rw_crapfdc_524.dsdocmc7;                 
                        
                        vrins_idsitqbr := 5;
                        vrins_dsobsqbr := 'Registro incluido para busca ICFJUD em '||to_char(SYSDATE,'DD/MM/RRRR');
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_idx_err := vr_tberro.COUNT + 1;
                          vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO Historico 524 - LOOP';
                          vr_tberro(vr_idx_err).dserro   := '3 - Erro ao tentar inserir na tabela CRAPICF. ' ||
                                                            'Data: ' || rw_lancamento.dtmvtolt || '  ' || 
                                                            'Valor Lancamento: ' || rw_lancamento.vllanmto || '  ' || 
                                                            'Documento: ' || rw_lancamento.nrdocmto || '  ' || 
                                                            'ID: ' || rw_lancamento.progress_recid || '  ' || 
                                                            'Erro: '|| SQLERRM;
                      END;
                    ELSE
                      vr_nrcpfcgc := rw_crapicf.nrcpfcgc;
                      vr_nmprimtl := rw_crapicf.nmprimtl;                 
                    END IF; -- cr_crapicf
                    CLOSE cr_crapicf;
                  END IF;
                END IF;
              END IF; -- cr_crapfdc_524
              -- Fechar cursor
              CLOSE cr_crapfdc_524;

              vrins_cdbandep := rw_lancamento.cdbanchq;
              vrins_cdagedep := rw_lancamento.cdagechq;
              vrins_nrctadep := rw_lancamento.nrctachq;
              vrins_tpdconta := '';
              vrins_inpessoa := '';
              vrins_nrcpfcgc := vr_nrcpfcgc;
              vrins_nmprimtl := vr_nmprimtl;
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';

              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              IF  rw_lancamento.idsitqbr = 5
              AND nvl(vr_nrcpfcgc,0) = 0 THEN
                --Se registro ja foi incluido no ICF e ainda nao possui as informacoes, mantem situacao 5
                vrins_idsitqbr := 5;
              ELSE
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 20';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
              END IF;

              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF; -- Historicos 524, 27

            IF vr_cdestsig = 21 THEN 
              vrins_cdbandep := '085';
              vrins_cdagedep := rw_conta.cdagenci;
              vrins_nrctadep := rw_conta.nrdconta;
              vrins_tpdconta := '1';
              vrins_inpessoa := rw_conta.inpessoa;
              vrins_nrcpfcgc := rw_conta.nrcpfcgc;
              vrins_nmprimtl := rw_conta.nmprimtl;
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';
              
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;
              
              IF vr_cdestsig = 0 THEN
                vrins_idsitqbr := 2;
                vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 21';
              ELSE
                vrins_idsitqbr := 1;
                vrins_dsobsqbr := '';
              END IF;
              
              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF; -- Historicos 570, 22, 614, 1030, 271, 1

            IF vr_cdestsig = 22 OR vr_cdestsig = 0 THEN
              vr_registro := FALSE;

              -- Percorrer todos os cheques na data
              FOR rw_cheque IN cr_all_cheques_data(pr_cdcooper => rw_lancamento.cdcooper
                                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                                  ,pr_nrdocmto => rw_lancamento.nrdocmto
                                                  ,pr_dtmvtolt => rw_lancamento.dtmvtolt) LOOP

                vrins_nrdocmto := rw_cheque.nrdocmto;
                vrins_cdbandep := rw_cheque.cdbanchq;
                vrins_cdagedep := rw_cheque.cdagechq;
                vrins_nrctadep := rw_cheque.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := '';
                vrins_nrcpfcgc := '';
                vrins_nmprimtl := '';
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 22';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END LOOP; -- Loop dos cheque na data

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF;-- Historico 3, 4

            IF vr_cdestsig = 23 OR vr_cdestsig = 0 THEN -- Cr. Descto. Chq.
              vr_registro := FALSE;

              -- Percorrer borderô de cheque
              FOR rw_bordero_cheque IN cr_bordero_cheque (pr_cdcooper => rw_lancamento.cdcooper
                                                         ,pr_nrdconta => rw_lancamento.nrdconta
                                                         ,pr_nrborder => rw_lancamento.nrdocmto) LOOP
                vrins_nrdocmto := rw_bordero_cheque.nrdocmto;
                vrins_cdbandep := rw_bordero_cheque.cdbanchq;
                vrins_cdagedep := rw_bordero_cheque.cdagechq;
                vrins_nrctadep := rw_bordero_cheque.nrctachq;
                vrins_tpdconta := '';
                vrins_inpessoa := '';
                vrins_nrcpfcgc := '';
                vrins_nmprimtl := '';
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 23';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END LOOP; -- Loop dos borderos de cheque

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 270

            IF vr_cdestsig = 24 OR vr_cdestsig = 0 THEN -- Bordero de Titulo
              vr_registro := FALSE;
              vr_nrdocmto := to_number(TRIM(REPLACE(REPLACE(UPPER(rw_lancamento.cdpesqbb),'DESCONTO DO BORDERO',' '),'.', '')));

              -- Percorrer borderô de titulo
              FOR rw_bordero_titulo IN cr_bordero_titulo (pr_cdcooper => rw_lancamento.cdcooper
                                                         ,pr_nrdconta => rw_lancamento.nrdconta
                                                         ,pr_nrborder => vr_nrdocmto) LOOP
                -- Limpar as informações do pagador                                         
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                -- Buscar Pagador
                OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                ,pr_nrdconta => rw_lancamento.nrdconta
                                ,pr_nrinssac => rw_bordero_titulo.nrinssac);
                FETCH cr_pagador INTO rw_pagador;
                IF cr_pagador%FOUND THEN
                  vr_inpessoa := rw_pagador.cdtpinsc;
                  vr_nrcpfcgc := rw_pagador.nrinssac;
                  vr_nmprimtl := rw_pagador.nmdsacad;
                END IF;
                -- Fechar cursor
                CLOSE cr_pagador;
                                                         
                vrins_nrdocmto := '';
                vrins_cdbandep := '';
                vrins_cdagedep := '';
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 24';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END LOOP; -- Loop dos borderos de cheque

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 686

            IF vr_cdestsig = 25 THEN -- CRED TED BB / CR. VIA BB
              vrins_cdbandep := '';
              vrins_tpdconta := '';
              vrins_inpessoa := '';
              vrins_nrcpfcgc := '';
              vrins_nmprimtl := '';
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              -- Caso o depositante/favorecido não possua conta no banco, 
              -- os campos AGENCIA, CONTA e OBSERVACAO devem possuir, respectivamente, os seguintes valores: 
              --              9999, 99999999999999999999 e NAO­CORRENTISTA 
              vrins_cdagedep := 9999;
              vrins_nrctadep := 99999999999999999999;
              vrins_dsobserv := 'NAO­CORRENTISTA';
              
              IF vr_cdestsig = 0 THEN
                vrins_idsitqbr := 2;
                vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 25';
              ELSE
                vrins_idsitqbr := 1;
                vrins_dsobsqbr := '';
              END IF;
                  
              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;
              
              pc_atualiza_tbjur(rw_lancamento.rowid);

              vr_registro := TRUE;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 651

            IF vr_cdestsig = 26 THEN -- SAQUE CARTAO
              vrins_cdbandep := '';
              vrins_tpdconta := '';
              vrins_inpessoa := '';
              vrins_nrcpfcgc := '';
              vrins_nmprimtl := '';
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO

              vrins_cdagedep := 9999;
              vrins_nrctadep := 99999999999999999999;
              vrins_dsobserv := 'SAQUE-CARTAO';

              IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
              ELSE 
                vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
              END IF;

              IF vr_cdestsig = 0 THEN
                vrins_idsitqbr := 2;
                vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 26';
              ELSE
                vrins_idsitqbr := 1;
                vrins_dsobsqbr := '';
              END IF;
              
              pc_atualiza_tbjur(rw_lancamento.rowid);

              vr_registro := TRUE;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 316
            
            IF vr_cdestsig = 27 THEN -- Pagamento Online
              vr_registro := FALSE;

              -- Buscar os dados do boleto que esta sendo pago
              OPEN cr_hist_508_boleto (rw_lancamento.progress_recid);
              FETCH cr_hist_508_boleto INTO rw_hist_508_boleto;

              -- Encontrou boleto ?
              IF cr_hist_508_boleto%FOUND THEN
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := '';
                
                -- Busca dados do pagador
                IF rw_hist_508_boleto.nrinssac > 0 THEN
                  -- Buscar Pagador
                  OPEN cr_pagador (pr_cdcooper => rw_lancamento.cdcooper 
                                  ,pr_nrdconta => rw_lancamento.nrdconta
                                  ,pr_nrinssac => rw_boleto.nrinssac);
                  FETCH cr_pagador INTO rw_pagador;
                  IF cr_pagador%FOUND THEN
                    vr_inpessoa := rw_pagador.cdtpinsc;
                    vr_nrcpfcgc := rw_pagador.nrinssac;
                    vr_nmprimtl := rw_pagador.nmdsacad;
                  END IF;
                  -- Fechar cursor
                  CLOSE cr_pagador;
                END IF;-- Dados do pagador

                vrins_nrdocmto := rw_boleto.nrdocmto;
                vrins_cdbandep := rw_boleto.cdbanpag;
                vrins_cdagedep := rw_boleto.cdagepag;
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 27';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;

                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;
              -- Fechar Cursor
              CLOSE cr_hist_508_boleto;
              
              -- Se encontrou o boleto vai para o proximo lancamento
              IF vr_registro THEN
                CONTINUE;
              END IF;

              OPEN cr_hist_508_convenio (rw_lancamento.progress_recid);
              FETCH cr_hist_508_convenio INTO rw_hist_508_convenio;

              -- Encontrou boleto ?
              IF cr_hist_508_convenio%FOUND THEN
                vr_inpessoa := '';
                vr_nrcpfcgc := '';
                vr_nmprimtl := rw_hist_508_convenio.nmconvenio;
                
                vrins_nrdocmto := '';
                vrins_cdbandep := '';
                vrins_cdagedep := '';
                vrins_nrctadep := '';
                vrins_tpdconta := '';
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';     
                
                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 27';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);

                vr_registro := TRUE;
              END IF;

              -- Fechar cursor
              CLOSE cr_hist_508_convenio;
              
              begin
                OPEN cr_hist_508_protocolo(rw_lancamento.progress_recid);
                FETCH cr_hist_508_protocolo INTO rw_hist_508_protocolo;

                -- Encontrou boleto ?
                IF cr_hist_508_protocolo%FOUND THEN
                  vr_inpessoa := '';
                  vr_nrcpfcgc := '';
                  vr_nmprimtl := '';
                  
                  vrins_nrdocmto := '';
                  vrins_cdbandep := rw_hist_508_protocolo.cdbandep;
                  vrins_cdagedep := '';
                  vrins_nrctadep := '';
                  vrins_tpdconta := '';
                  vrins_inpessoa := vr_inpessoa;
                  vrins_nrcpfcgc := vr_nrcpfcgc;
                  vrins_nmprimtl := vr_nmprimtl;
                  vrins_tpdocttl := '';
                  vrins_nrdocttl := '';
                  vrins_dscodbar := '';
                  vrins_nmendoss := '';
                  vrins_docendos := '';
                  vrins_idsitide := '0'; -- Fixo ZERO
                  vrins_dsobserv := '';     
                  
                  IF vr_cdestsig = 0 THEN
                    vrins_idsitqbr := 2;
                    vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 27';
                  ELSE
                    vrins_idsitqbr := 1;
                    vrins_dsobsqbr := '';
                  END IF;
                  
                  pc_atualiza_tbjur(rw_lancamento.rowid);

                  vr_registro := TRUE;
                END IF;

                -- Fechar cursor
                if cr_hist_508_protocolo%isopen then
                  CLOSE cr_hist_508_protocolo;
                end if;
              exception
                when others then
                  if cr_hist_508_protocolo%isopen then
                    CLOSE cr_hist_508_protocolo;
                  end if;
              end;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF;

            IF vr_cdestsig = 28 THEN -- Devolucao
              vr_inpessoa := rw_lancamento.inpessoa;
              vr_nrcpfcgc := rw_lancamento.nrcpfcgc;
              vr_nmprimtl := rw_lancamento.nmprimtl;

              vrins_nrdocmto := rw_lancamento.nrdocmto;
              vrins_cdbandep := '';
              vrins_cdagedep := '';
              vrins_nrctadep := '';
              vrins_tpdconta := '';
              vrins_inpessoa := vr_inpessoa;
              vrins_nrcpfcgc := vr_nrcpfcgc;
              vrins_nmprimtl := vr_nmprimtl;
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';

              vrins_idsitqbr := 1;
              vrins_dsobsqbr := '';

              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF;
            
            IF vr_cdestsig = 29 THEN -- Informacoes da propria cooperativa, lancamentos de ajuste
              vr_inpessoa := 2;
              vr_nrcpfcgc := rw_conta.nrdocnpj;
              vr_nmprimtl := rw_conta.nmextcop;

              vrins_nrdocmto := rw_lancamento.nrdocmto;
              vrins_cdbandep := '085';
              vrins_cdagedep := rw_conta.cdagenci;
              vrins_nrctadep := rw_conta.nrdconta;
              vrins_tpdconta := '';
              vrins_inpessoa := vr_inpessoa;
              vrins_nrcpfcgc := vr_nrcpfcgc;
              vrins_nmprimtl := vr_nmprimtl;
              vrins_tpdocttl := '';
              vrins_nrdocttl := '';
              vrins_dscodbar := '';
              vrins_nmendoss := '';
              vrins_docendos := '';
              vrins_idsitide := '0'; -- Fixo ZERO
              vrins_dsobserv := '';

              vrins_idsitqbr := 1;
              vrins_dsobsqbr := '';

              pc_atualiza_tbjur(rw_lancamento.rowid);

              CONTINUE;
            END IF;

            IF vr_cdestsig = 30 OR vr_cdestsig = 0 THEN -- Credito de Salario
              vr_registro := FALSE;

              vr_inpessoa := '';
              vr_nrcpfcgc := '';
              vr_nmprimtl := '';
              vr_cdagenci := '';

              -- Buscar os dados da conta que fez o crédito
              OPEN cr_crapass_origem (pr_cdcooper => rw_lancamento.cdcooper
                                     ,pr_dtmvtolt => rw_lancamento.dtmvtolt
                                     ,pr_nrdolote => rw_lancamento.nrdolote
                                     );
              FETCH cr_crapass_origem INTO rw_crapass_origem;
              -- Encontrou a conta?
              IF cr_crapass_origem%FOUND THEN
                vr_inpessoa := rw_crapass_origem.inpessoa;
                vr_nrcpfcgc := rw_crapass_origem.nrcpfcgc;
                vr_nmprimtl := rw_crapass_origem.nmprimtl;
                vr_cdagenci := rw_crapass_origem.cdagenci;
                
                vrins_cdbandep := '085';
                vrins_cdagedep := rw_conta.cdagenci;
                vrins_nrctadep := rw_lancamento.nrdconta;
                vrins_tpdconta := '4'; -- Outros
                vrins_inpessoa := vr_inpessoa;
                vrins_nrcpfcgc := vr_nrcpfcgc;
                vrins_nmprimtl := vr_nmprimtl;
                vrins_tpdocttl := '';
                vrins_nrdocttl := '';
                vrins_dscodbar := '';
                vrins_nmendoss := '';
                vrins_docendos := '';
                vrins_idsitide := '0'; -- Fixo ZERO
                vrins_dsobserv := '';

                IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
                  vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
                ELSE 
                  vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
                END IF;

                IF vr_cdestsig = 0 THEN
                  vrins_idsitqbr := 2;
                  vrins_dsobsqbr := 'Historico nao parametrizado. Informacoes encontradas na regra: 30';
                ELSE
                  vrins_idsitqbr := 1;
                  vrins_dsobsqbr := '';
                END IF;
                
                pc_atualiza_tbjur(rw_lancamento.rowid);
                
                vr_registro := TRUE;
              END IF;

              -- Fechar Cursor
              CLOSE cr_crapass_origem;

              IF vr_registro THEN
                CONTINUE;
              END IF;
            END IF; -- Historico 8

            vrins_cdbandep := '';
            vrins_cdagedep := '';
            vrins_nrctadep := '';
            vrins_tpdconta := '';
            vrins_inpessoa := '';
            vrins_nrcpfcgc := '';
            vrins_nmprimtl := '';
            vrins_tpdocttl := '';
            vrins_nrdocttl := '';
            vrins_dscodbar := '';
            vrins_nmendoss := '';
            vrins_docendos := '';
            vrins_idsitide := '0'; -- Fixo ZERO
            vrins_dsobserv := 'HISTORICO: ' || rw_lancamento.cdhistor;
            
            IF length(to_char(rw_lancamento.nrdocmto)) > 20 THEN
              vrins_nrdocmto := SUBSTR(TRIM(to_char(rw_lancamento.nrdocmto)), -20);
            ELSE 
              vrins_nrdocmto := to_char(rw_lancamento.nrdocmto);
            END IF;

            vrins_idsitqbr := 4;
            vrins_dsobsqbr := 'Informacoes nao encontradas em nenhuma das regras existentes';
            
            pc_atualiza_tbjur(rw_lancamento.rowid);
          EXCEPTION
            WHEN OTHERS THEN
              vrins_idsitqbr := 7;
              vrins_dsobsqbr := substr('Erro - '||SQLERRM,1,200);

              pc_atualiza_tbjur(rw_lancamento.rowid);
          END;
        END LOOP; -- Extrato da conta do cooperado
      END LOOP; --  Loop Conta Cooperado
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := vr_tberro.COUNT + 1;
      vr_tberro(vr_idx_err).dsorigem := 'ORIGEM DESTINO';
      vr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_carrega_arq_origem_destino;
  -- FIM -> Carregar dados para geração
  
  PROCEDURE pc_gera_arq_agencias(pr_nmdir_arquivo       IN     VARCHAR2
                                ,pr_nrseq_quebra_sigilo IN     NUMBER
                                ,pr_tberro              IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_nmarquiv  VARCHAR2(100) := pr_nrseq_quebra_sigilo || '_AGENCIAS.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    
    CURSOR cr_agencia IS
      SELECT age.cdcooper
            ,age.cdagenci
            ,UPPER(age.nmextage) nmextage
            ,UPPER(age.nmcidade) nmcidade
            ,UPPER(age.cdufdcop) cdufdcop
            ,age.nrcepend
            ,UPPER(age.dsendcop) dsendcop
            ,UPPER(age.nmbairro) nmbairro
            ,to_number(regexp_replace(age.nrtelvoz, '[^[:digit:]]', '')) nrtelvoz
            ,age.dtabertu
            ,age.dtfechto
        FROM crapage age
           , cecred.tbjur_qbr_sig_agencia c
       WHERE age.cdcooper = c.cdcooper
         AND age.cdagenci = c.cdagenci
         AND c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
  
    FOR rw_agencia IN cr_agencia LOOP
      vr_dstext_linha := '085' || chr(09) || 
                         rw_agencia.cdagenci || chr(09) || 
                         rw_agencia.nmextage || chr(09) || 
                         TRIM(rw_agencia.dsendcop) || ' ' || TRIM(rw_agencia.nmbairro) || chr(09) || 
                         SUBSTR(rw_agencia.nmcidade, 1, 15) || chr(09) || 
                         rw_agencia.cdufdcop || chr(09) || 
                         'BRASIL' || chr(09) || 
                         rw_agencia.nrcepend || chr(09) || 
                         rw_agencia.nrtelvoz || chr(09) || 
                         to_char(rw_agencia.dtabertu, 'DDMMYYYY') || chr(09) || 
                         to_char(rw_agencia.dtfechto, 'DDMMYYYY') || chr(13);

      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
    END LOOP;

    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO AGENCIAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_agencias;
  
  -- Escrever todas as informações carregadas no arquivo _CONTAS
  PROCEDURE pc_gera_arq_contas(pr_nmdir_arquivo       IN     VARCHAR2
                              ,pr_nrseq_quebra_sigilo IN     cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                              ,pr_tberro              IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err   INTEGER;
    vr_nmarquiv  VARCHAR2(100) := pr_nrseq_quebra_sigilo || '_CONTAS.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    
    CURSOR cr_conta IS
      SELECT c.cdcooper
           , c.nrdconta
           , c.tpmovcta
           , ass.cdagenci
           , ass.dtmvtolt
           , ass.dtelimin
        FROM crapass ass
           , cecred.tbjur_qbr_sig_conta c
       WHERE ass.cdcooper = c.cdcooper
         AND ass.nrdconta = c.nrdconta
         AND c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;

  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);

    -- Chave para percorrer todas as agencias
    FOR rw_conta IN cr_conta LOOP
      vr_dstext_linha := '085' || chr(09) || 
                         rw_conta.cdagenci || chr(09) || 
                         rw_conta.nrdconta || chr(09) || 
                         '1' || chr(09) || 
                         to_char(rw_conta.dtmvtolt, 'DDMMYYYY') || chr(09) || 
                         to_char(rw_conta.dtelimin, 'DDMMYYYY') || chr(09) || 
                         rw_conta.tpmovcta || chr(13);
                          
      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
    END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO CONTAS';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
    
  END pc_gera_arq_contas;
  
  -- Escrever todas as informações carregadas no arquivo _TITULARES
  PROCEDURE pc_gera_arq_titulares(pr_nmdir_arquivo       IN VARCHAR2
                                 ,pr_nrseq_quebra_sigilo IN cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                                 ,pr_tberro              IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_nrseq_quebra_sigilo || '_TITULARES.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    
    CURSOR cr_titular IS
      SELECT nrseq_quebra_sigilo
           , cdcooper 
           , nrdconta 
           , nrcpfcgc 
           , cddbanco 
           , cdagenci 
           , tpdconta 
           , dsvincul 
           , flafasta 
           , inpessoa 
           , nmprimtl 
           , tpdocttl 
           , nrdocttl 
           , dsendere 
           , nmcidade 
           , ufendere 
           , nmdopais 
           , nrcepend 
           , nrtelefo 
           , vlrrendi 
           , dtultalt 
           , dtadmiss 
           , dtdemiss
        FROM cecred.tbjur_qbr_sig_titular c
       WHERE c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);

    FOR rw_titular IN cr_titular LOOP
      vr_dstext_linha := rw_titular.cddbanco || chr(09) || 
                         rw_titular.cdagenci || chr(09) || 
                         rw_titular.nrdconta || chr(09) || 
                         rw_titular.tpdconta || chr(09) || 
                         rw_titular.dsvincul || chr(09) || 
                         rw_titular.flafasta || chr(09) || 
                         rw_titular.inpessoa || chr(09) || 
                         rw_titular.nrcpfcgc || chr(09) || 
                         rw_titular.nmprimtl || chr(09) || 
                         rw_titular.tpdocttl || chr(09) || 
                         rw_titular.nrdocttl || chr(09) || 
                         rw_titular.dsendere || chr(09) || 
                         rw_titular.nmcidade || chr(09) || 
                         rw_titular.ufendere || chr(09) || 
                         rw_titular.nmdopais || chr(09) || 
                         rw_titular.nrcepend || chr(09) || 
                         NVL(TRIM(rw_titular.nrtelefo), 0) || chr(09) || 
                         to_char(rw_titular.vlrrendi * 100) || chr(09) || 
                         rw_titular.dtultalt || chr(09) || 
                         rw_titular.dtadmiss || chr(09) || 
                         rw_titular.dtdemiss || chr(13);

      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
    END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO TITULARES';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_titulares;

  -- Escrever todas as informações carregadas no arquivo _EXTRATO
  PROCEDURE pc_gera_arq_extrato(pr_nmdir_arquivo IN VARCHAR2
                               ,pr_nrseq_quebra_sigilo cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                               ,pr_tberro        IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_nrseq_quebra_sigilo || '_EXTRATO.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log

    CURSOR cr_extrato IS
      SELECT lcm.progress_recid idseqlcm
           , lcm.dtmvtolt
           , lcm.vllanmto
           , lcm.nrdocmto
           , lcm.nrterfin
           , his.cdhistor
           , his.dshistor
           , his.indebcre
           , ass.cdagenci
           , lcm.nrdconta
           , his.cdhisrec
           , c.vlrsaldo
           , c.indebcre_saldo
           , c.dslocal_transacao
        FROM craplcm lcm
           , craphis his
           , crapass ass
           , cecred.tbjur_qbr_sig_extrato c
       WHERE his.cdcooper          = lcm.cdcooper
         AND his.cdhistor          = lcm.cdhistor
         AND ass.cdcooper          = lcm.cdcooper
         AND ass.nrdconta          = lcm.nrdconta
         AND lcm.progress_recid    = c.nrseqlcm
         AND c.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
    
    vr_nrdocmto VARCHAR2(20);
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);
                   
    -- Percorrer todas as linhas de extrato que identificamos 
    FOR rw_extrato IN cr_extrato LOOP
      IF length(to_char(rw_extrato.nrdocmto)) > 20 THEN
        vr_nrdocmto := SUBSTR(TRIM(to_char(rw_extrato.nrdocmto)), -20);
      ELSE 
        vr_nrdocmto := to_char(rw_extrato.nrdocmto);
      END IF;

      vr_dstext_linha := rw_extrato.idseqlcm || chr(09) || 
                         '085' || chr(09) || 
                         rw_extrato.cdagenci || chr(09) || 
                         rw_extrato.nrdconta || chr(09) || 
                         '1' || chr(09) || 
                         to_char(rw_extrato.dtmvtolt, 'DDMMYYYY') || chr(09) || 
                         vr_nrdocmto || chr(09) || 
                         rw_extrato.dshistor || chr(09) || 
                         rw_extrato.cdhisrec || chr(09) || 
                         to_char(rw_extrato.vllanmto * 100) || chr(09) || 
                         rw_extrato.indebcre || chr(09) || 
                         to_char(rw_extrato.vlrsaldo * 100) || chr(09) || 
                         rw_extrato.indebcre_saldo || chr(09) || 
                         rw_extrato.dslocal_transacao || chr(13);

      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
    END LOOP;

    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);

  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO EXTRATO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_extrato;
  
  -- Escrever todas as informações carregadas no arquivo _ORIGEM_DESTINO
  PROCEDURE pc_gera_arq_origem_destino(pr_nmdir_arquivo       IN     VARCHAR2
                                      ,pr_nrseq_quebra_sigilo IN     tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                                      ,pr_tberro              IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_nrseq_quebra_sigilo||'_ORIGEM_DESTINO.txt';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    
    CURSOR cr_origem_destino IS
      SELECT t.nrseqlcm
           , row_number() OVER (PARTITION BY t.nrseq_quebra_sigilo ORDER BY t.nrseqlcm) nrseqreg
           , (lcm.vllanmto * 100) vllanmto
           , t.nrdocmto
           , t.cdbandep
           , t.cdagedep
           , t.nrctadep
           , t.tpdconta
           , t.inpessoa
           , t.nrcpfcgc
           , t.nmprimtl
           , t.tpdocttl
           , t.nrdocttl
           , t.dscodbar
           , t.nmendoss
           , t.docendos
           , t.idsitide
           , t.dsobserv
        FROM craplcm               lcm
           , tbjur_qbr_sig_extrato t
       WHERE lcm.progress_recid    = t.nrseqlcm
         AND t.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
       ORDER
          BY t.nrseqlcm;
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);

    -- Percorrer todas as linhas de extrato que identificamos
    FOR rw_origem_destino IN cr_origem_destino LOOP
      vr_dstext_linha := to_char(rw_origem_destino.nrseqlcm)||to_char(rw_origem_destino.nrseqreg)|| chr(09) || 
                         rw_origem_destino.nrseqlcm || chr(09) ||
                         rw_origem_destino.vllanmto || chr(09) ||
                         rw_origem_destino.nrdocmto || chr(09) ||
                         rw_origem_destino.cdbandep || chr(09) ||
                         rw_origem_destino.cdagedep || chr(09) ||
                         rw_origem_destino.nrctadep || chr(09) ||
                         rw_origem_destino.tpdconta || chr(09) ||
                         rw_origem_destino.inpessoa || chr(09) ||
                         rw_origem_destino.nrcpfcgc || chr(09) ||
                         rw_origem_destino.nmprimtl || chr(09) ||
                         rw_origem_destino.tpdocttl || chr(09) ||
                         rw_origem_destino.nrdocttl || chr(09) ||
                         rw_origem_destino.dscodbar || chr(09) ||
                         rw_origem_destino.nmendoss || chr(09) ||
                         rw_origem_destino.docendos || chr(09) ||
                         rw_origem_destino.idsitide || chr(09) ||
                         rw_origem_destino.dsobserv || chr(13);

      pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                          ,pr_nmarquivo   => vr_nmarquiv
                          ,pr_texto_linha => vr_dstext_linha
                          ,pr_ind_arqlog  => vr_ind_arqlog);
	  END LOOP;
    
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
                     
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO ORIGEM DESTINO';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_origem_destino;

  -- Escrever todas as informações carregadas no arquivo _CHEQUES_ICFJUD_CPF
  PROCEDURE pc_gera_arq_cheques_icfjud(pr_nmdir_arquivo       IN     VARCHAR2
                                      ,pr_nrseq_quebra_sigilo IN     tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE
                                      ,pr_tberro              IN OUT typ_tberro) IS
    -- Variaveis Locais
    vr_idx_err      INTEGER;
    vr_nmarquiv     VARCHAR2(100) := pr_nrseq_quebra_sigilo||'_CHEQUES_ICFJUD_CPF.csv';
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
  BEGIN
    -- Abrir o arquivo
    pc_abre_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                   ,pr_nmarquivo  => vr_nmarquiv
                   ,pr_ind_arqlog => vr_ind_arqlog);

    vr_dstext_linha := 'Data Solicitação;Banco Requisitado;Agência Requisitada;Conta Requisitada;Tipo Requisição;CMC7';

    pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                        ,pr_nmarquivo   => vr_nmarquiv
                        ,pr_texto_linha => vr_dstext_linha
                        ,pr_ind_arqlog  => vr_ind_arqlog);

    -- Percorrer todas as linhas de extrato que identificamos
    IF vr_tbarq_cheques_icfjud.COUNT > 0 THEN
      FOR vr_idx IN vr_tbarq_cheques_icfjud.FIRST..vr_tbarq_cheques_icfjud.LAST LOOP
        vr_dstext_linha := vr_tbarq_cheques_icfjud(vr_idx).dtinireq || ';' || 
                           vr_tbarq_cheques_icfjud(vr_idx).cdbanreq || ';' || 
                           vr_tbarq_cheques_icfjud(vr_idx).cdagereq || ';' || 
                           vr_tbarq_cheques_icfjud(vr_idx).nrctareq || ';' || 
                           vr_tbarq_cheques_icfjud(vr_idx).intipreq || ';' || 
                           vr_tbarq_cheques_icfjud(vr_idx).dsdocmc7;

        pc_escreve_linha_arq(pr_dirarquivo  => pr_nmdir_arquivo
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
      END LOOP;
    END IF;
    --
    -- Fechar o arquivo
    pc_fechar_arquivo(pr_dirarquivo => pr_nmdir_arquivo
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);
                     
  EXCEPTION
    WHEN OTHERS THEN
      vr_idx_err := pr_tberro.COUNT + 1;
      pr_tberro(vr_idx_err).dsorigem := 'ARQUIVO CHEQUES ICF JUD';
      pr_tberro(vr_idx_err).dserro   := 'Erro não tratado. Verifique: ' ||
                                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                                 dbms_utility.format_error_stack,'"', NULL);
  END pc_gera_arq_cheques_icfjud;

  PROCEDURE pc_quebra_sigilo(pr_cdcoptel IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_nrdconta IN VARCHAR2               --> Numero da conta
                            ,pr_dtiniper IN VARCHAR2               --> Data de inicio do periodo
                            ,pr_dtfimper IN VARCHAR2               --> Data de fim do periodo
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    --JOB
    vr_jobname    VARCHAR2(30);
    vr_dsplsql    VARCHAR2(4000);
    vr_cdprogra   VARCHAR2(6) := 'QBRSIG';
    vr_exc_saida  EXCEPTION;

    --> variaveis auxiliares
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    --Parametros gene0004
    vr_cdcoplog INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    /*
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcoplog,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    */

    vr_cdcoplog := '3';
    vr_cdoperad := '1';

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'QBRSIG_'||pr_cdcoptel|| '$';  
           
    -- Montar o bloco PLSQL que será executado
    -- Ou seja, executaremos a geração dos dados
    -- para a agência atual atraves de Job no banco
    vr_dsplsql := 'BEGIN' || chr(13) 
               || '  tela_qbrsig.pc_quebra_sigilo_job('||pr_cdcoptel||chr(13)
               || '                                  ,'''||pr_nrdconta||''''||CHR(13)
               || '                                  ,'''||pr_dtiniper||''''||CHR(13)
               || '                                  ,'''||pr_dtfimper||''''||CHR(13)
               || '                                  ,'''||vr_cdoperad||''''||CHR(13)
               || '                                  );'||chr(13)
               || 'END;';

     -- Faz a chamada ao programa paralelo atraves de JOB
     gene0001.pc_submit_job(pr_cdcooper => vr_cdcoplog  --> Código da cooperativa
                           ,pr_cdprogra => vr_cdprogra  --> Código do programa
                           ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                           ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                           ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                           ,pr_jobname  => vr_jobname   --> Nome randomico criado
                           ,pr_des_erro => vr_dscritic);    
                                    
     -- Testar saida com erro
     if vr_dscritic is not null then 
       -- Levantar exceçao
       raise vr_exc_saida;
     end if;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela QBRSIG: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_quebra_sigilo;
  
  PROCEDURE pc_gera_arquivo(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    vr_dir_arq    VARCHAR2(300);
    vr_dircop     CONSTANT VARCHAR2(200) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                     ,pr_cdcooper => 0
                                                                     ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/qbrsig';

    -- Criacao do diretorio de arquivos
    vr_typ_saida VARCHAR2(100);
    vr_des_saida VARCHAR2(1000);
    
    -- Indices das PL TABLES
    vr_idx_err    INTEGER;
  BEGIN
    -- Se não possuir erros gera os arquivos
    -- Criar diretorio com base na REFERENCIA do processo de quebra de sigilo bancário
    vr_dir_arq := vr_dircop||'/Quebra_'||pr_nrseq_quebra_sigilo;
    -- Primeiro garantimos que o diretorio exista
    
    IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
      -- Efetuar a criação do mesmo
      gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_idx_err := vr_tberro.COUNT + 1;
        vr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
        vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;  
        RAISE vr_erros;
      END IF;
      
      -- Adicionar permissão total na pasta
      gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_idx_err := vr_tberro.COUNT + 1;
        vr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
        vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
        RAISE vr_erros;
      END IF;           
    END IF;

    -- Gerar o arquivo com os dados das agencias para quebra do sigilo bancário
    pc_gera_arq_agencias(pr_nmdir_arquivo       => vr_dir_arq
                        ,pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                        ,pr_tberro              => vr_tberro);

    -- Gerar o arquivo com os dados das contas para quebra do sigilo bancário
    pc_gera_arq_contas(pr_nmdir_arquivo       => vr_dir_arq
                      ,pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                      ,pr_tberro              => vr_tberro);

    -- Gerar o arquivo com os dados dos titulares para quebra do sigilo bancário
    pc_gera_arq_titulares(pr_nmdir_arquivo       => vr_dir_arq
                         ,pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                         ,pr_tberro              => vr_tberro);

    -- Gerar o arquivo com os dados do extrato para quebra do sigilo bancário
    pc_gera_arq_extrato(pr_nmdir_arquivo       => vr_dir_arq
                       ,pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                       ,pr_tberro              => vr_tberro);

    -- Gerar o arquivo com os dados de origem e destino para quebra do sigilo bancário
    pc_gera_arq_origem_destino(pr_nmdir_arquivo        => vr_dir_arq
                              ,pr_nrseq_quebra_sigilo  => pr_nrseq_quebra_sigilo
                              ,pr_tberro               => vr_tberro);

    -- Caso tenha acontecido algum erro durante a geracao dos arquivos precisamos corrigir
    IF vr_tberro.COUNT > 0 THEN
      RAISE vr_erros;
    END IF;

    -- Abertura de arquivos gera registros na CRAPCSO, necessario commit
    COMMIT;
  END;

  PROCEDURE pc_atualiza_info_qbrsig(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                                   ,pr_nrseqlcm IN tbjur_qbr_sig_extrato.nrseqlcm%TYPE --> Numero sequencial da tabela LCM
                                   ,pr_cdbandep IN tbjur_qbr_sig_extrato.cdbandep%TYPE --> Banco depositante
                                   ,pr_cdagedep IN tbjur_qbr_sig_extrato.cdagedep%TYPE --> Agencia depositante
                                   ,pr_nrctadep IN tbjur_qbr_sig_extrato.nrctadep%TYPE --> Conta depositante
                                   ,pr_nrcpfcgc IN tbjur_qbr_sig_extrato.nrcpfcgc%TYPE --> CPF
                                   ,pr_nmprimtl IN tbjur_qbr_sig_extrato.nmprimtl%TYPE --> Nome
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcoplog INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcoplog,
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
      RAISE vr_exc_erro;
    END IF;

    UPDATE tbjur_qbr_sig_extrato t
       SET t.cdbandep = pr_cdbandep
         , t.cdagedep = pr_cdagedep
         , t.nrctadep = pr_nrctadep
         , t.nrcpfcgc = pr_nrcpfcgc
         , t.nmprimtl = pr_nmprimtl
         , t.idsitqbr = 6
         , t.dsobsqbr = 'Informacoes atualizadas manualmente pelo operador '||vr_cdoperad
     WHERE t.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
       AND t.nrseqlcm = pr_nrseqlcm;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela QBRSIG: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;
  
  PROCEDURE pc_reprocessar_quebra(pr_nrseq_quebra_sigilo IN tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE --> Numero sequencial de quebra de sigilo
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcoplog  INTEGER;
    vr_cdoperad  VARCHAR2(100);
    vr_nmdatela  VARCHAR2(100);
    vr_nmeacao   VARCHAR2(100);
    vr_cdagenci  VARCHAR2(100);
    vr_nrdcaixa  VARCHAR2(100);
    vr_idorigem  VARCHAR2(100);
    
    vr_indctainv VARCHAR2(30);
    
    vr_dir_arq    VARCHAR2(300);
    vr_dircop     CONSTANT VARCHAR2(200) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                     ,pr_cdcooper => 0
                                                                     ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/qbrsig';

    -- Criacao do diretorio de arquivos
    vr_typ_saida VARCHAR2(100);
    vr_des_saida VARCHAR2(1000);

    -- Indices das PL TABLES
    vr_idx_err    INTEGER;
    
    --Arquivo de erros
    vr_nmarquiv     VARCHAR2(100);
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog   UTL_FILE.file_type; -- Handle para o arquivo de log
    
    CURSOR cr_quebra IS
      SELECT qbr.cdcooper
           , qbr.nrdconta
           , ass.nrcpfcgc
           , qbr.dtiniper
           , qbr.dtfimper
        FROM crapass ass
           , tbjur_quebra_sigilo qbr
       WHERE ass.cdcooper = qbr.cdcooper
         AND ass.nrdconta = qbr.nrdconta
         AND qbr.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo;
    
    CURSOR cr_lancamentos_1 IS
      SELECT ext.nrseqlcm
        FROM tbjur_qbr_sig_extrato ext
       WHERE ext.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
         AND ext.idsitqbr IN (7,8);

    CURSOR cr_lancamentos_2 IS
      SELECT ext.nrseqlcm
        FROM tbjur_qbr_sig_extrato ext
       WHERE ext.nrseq_quebra_sigilo = pr_nrseq_quebra_sigilo
         AND ext.idsitqbr NOT IN (1,5,6);
  BEGIN
    vr_idreprocessar := 1;

    vr_tbconta_investigar.DELETE;
    vr_tberro.DELETE;
    vr_tbhistorico.DELETE;
    vr_tbarq_agencias.DELETE;
    vr_tbarq_contas.DELETE;
    vr_tbarq_titulares.DELETE;
    vr_tbarq_extrato.DELETE;
    vr_tbarq_origem_destino.DELETE;
    vr_tbarq_cheques_icfjud.DELETE;

    pr_des_erro      := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcoplog,
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
      RAISE vr_exc_erro;
    END IF;

    FOR rw_quebra IN cr_quebra LOOP
      vr_indctainv := lpad(rw_quebra.cdcooper,3,'0')||'_'||lpad(rw_quebra.nrdconta,10,'0')||'_'||lpad(rw_quebra.nrcpfcgc,15,'0');

      vr_tbconta_investigar(vr_indctainv).cdcooper := rw_quebra.cdcooper;
      vr_tbconta_investigar(vr_indctainv).nrdconta := rw_quebra.nrdconta;
      vr_tbconta_investigar(vr_indctainv).nrcpfcgc := rw_quebra.nrcpfcgc;
      vr_tbconta_investigar(vr_indctainv).dtiniper := rw_quebra.dtiniper;
      vr_tbconta_investigar(vr_indctainv).dtfimper := rw_quebra.dtfimper;
    END LOOP;
    
    vr_idicfjud := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => vr_tbconta_investigar(vr_indctainv).cdcooper
                                                        ,pr_cdacesso => 'QBRSIG_ICF_ATIVO'));
    
    pc_carregar_historico_de_para;

    -- Dados para o arquivo _EXTRATO
    FOR rw_lancamentos_1 IN cr_lancamentos_1 LOOP
      pc_carrega_arq_extrato(pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                            ,pr_nrseqlcm            => rw_lancamentos_1.nrseqlcm);
    END LOOP;

    -- Dados para o arquivo _ORIGEM_DESTINO
    FOR rw_lancamentos_2 IN cr_lancamentos_2 LOOP
      pc_carrega_arq_origem_destino(pr_nrseq_quebra_sigilo => pr_nrseq_quebra_sigilo
                                   ,pr_nrseqlcm            => rw_lancamentos_2.nrseqlcm);
    END LOOP;
    
    COMMIT;

    -- Verificar se ocorreu algum erro que deve ser tratado antes de gerar o arquivo
    IF vr_tberro.COUNT > 0 THEN
      RAISE vr_erros;
    END IF;

  EXCEPTION
    WHEN vr_erros THEN
      -- Se não possuir erros gera os arquivos
      -- Criar diretorio com base na REFERENCIA do processo de quebra de sigilo bancário
      vr_dir_arq := vr_dircop||'/Quebra_'||pr_nrseq_quebra_sigilo;
      -- Primeiro garantimos que o diretorio exista
      
      IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
          RAISE vr_erros;
        END IF;

        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
          RAISE vr_erros;
        END IF;
      END IF;

      vr_nmarquiv := pr_nrseq_quebra_sigilo || '_ERROS.txt';

      pc_abre_arquivo(pr_dirarquivo => vr_dir_arq
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);

      -- Chave para percorrer todas as agencias
      FOR x IN vr_tberro.FIRST..vr_tberro.LAST LOOP
        vr_dstext_linha := 'Erro '||vr_tberro(x).dsorigem || ' => ' || vr_tberro(x).dserro;

        pc_escreve_linha_arq(pr_dirarquivo  => vr_dir_arq
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
      END LOOP;

      -- Fechar o arquivo
      pc_fechar_arquivo(pr_dirarquivo => vr_dir_arq
                       ,pr_nmarquivo  => vr_nmarquiv
                       ,pr_ind_arqlog => vr_ind_arqlog);

      -- Não altera nenhum dado    
      ROLLBACK;
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela QBRSIG: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;
  
  PROCEDURE pc_quebra_sigilo_job(pr_cdcoptel IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                ,pr_nrdconta IN VARCHAR2               --> Numero da conta
                                ,pr_dtiniper IN VARCHAR2               --> Data de inicio do periodo
                                ,pr_dtfimper IN VARCHAR2               --> Data de fim do periodo
                                ,pr_cdoperad IN VARCHAR2) IS           --> Codigo do operador

    vr_dtiniper DATE;
    vr_dtfimper DATE;

    --Indice conta investigar
    vr_indctainv           VARCHAR2(30);
    vr_nrseq_quebra_sigilo cecred.tbjur_quebra_sigilo.nrseq_quebra_sigilo%TYPE;
    vr_nrcpfcgc            crapass.nrcpfcgc%TYPE;

    vr_dir_arq    VARCHAR2(300);
    vr_dircop     CONSTANT VARCHAR2(200) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                     ,pr_cdcooper => 0
                                                                     ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/qbrsig';

    -- Criacao do diretorio de arquivos
    vr_typ_saida VARCHAR2(100);
    vr_des_saida VARCHAR2(1000);

    -- Indices das PL TABLES
    vr_idx_err    INTEGER;
    
    --> variaveis auxiliares
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    -- Tabelas split
    vr_tab_nrdconta gene0002.typ_split;
    vr_tab_dtiniper gene0002.typ_split;
    vr_tab_dtfimper gene0002.typ_split;
        
    --Arquivo de erros
    vr_nmarquiv     VARCHAR2(100);
    vr_dstext_linha VARCHAR2(32000);
    vr_ind_arqlog   UTL_FILE.file_type; -- Handle para o arquivo de log

    CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcoptel
         AND ass.nrdconta = pr_nrdconta;
    
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    end;
  BEGIN
    -- Limpar todas as tabelas que serão utilizadas no processo
    vr_tbconta_investigar.DELETE;
    vr_tberro.DELETE;
    vr_tbhistorico.DELETE;
    vr_tbarq_agencias.DELETE;
    vr_tbarq_contas.DELETE;
    vr_tbarq_titulares.DELETE;
    vr_tbarq_extrato.DELETE;
    vr_tbarq_origem_destino.DELETE;
    vr_tbarq_cheques_icfjud.DELETE;

    vr_idicfjud := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => pr_cdcoptel
                                                      ,pr_cdacesso => 'QBRSIG_ICF_ATIVO'));
                                                      
    vr_tab_nrdconta := gene0002.fn_quebra_string(pr_nrdconta,';');
    vr_tab_dtiniper := gene0002.fn_quebra_string(pr_dtiniper,';');
    vr_tab_dtfimper := gene0002.fn_quebra_string(pr_dtfimper,';');

    vr_nrseq_quebra_sigilo := fn_sequence(pr_nmtabela => 'TBJUR_QUEBRA_SIGILO'
                                         ,pr_nmdcampo => 'NRSEQ_QUEBRA_SIGILO'
                                         ,pr_dsdchave => ' ');

    IF vr_tab_nrdconta.count() > 0 THEN
      FOR idx IN vr_tab_nrdconta.first..vr_tab_nrdconta.last LOOP
        --Tratamento das variaveis recebidas
        vr_tab_nrdconta(idx) := REPLACE(vr_tab_nrdconta(idx),'.','');
        vr_tab_nrdconta(idx) := REPLACE(vr_tab_nrdconta(idx),'-','');
        vr_dtiniper          := to_date(vr_tab_dtiniper(idx),'DD/MM/RRRR');
        vr_dtfimper          := to_date(vr_tab_dtfimper(idx),'DD/MM/RRRR');
        
        OPEN cr_crapass(vr_tab_nrdconta(idx));
        FETCH cr_crapass INTO vr_nrcpfcgc;
        CLOSE cr_crapass;

        vr_indctainv := lpad(pr_cdcoptel,3,'0')||'_'||lpad(vr_tab_nrdconta(idx),10,'0')||'_'||lpad(vr_nrcpfcgc,15,'0');

        vr_tbconta_investigar(vr_indctainv).cdcooper := pr_cdcoptel;
        vr_tbconta_investigar(vr_indctainv).nrdconta := vr_tab_nrdconta(idx);
        vr_tbconta_investigar(vr_indctainv).nrcpfcgc := vr_nrcpfcgc;
        vr_tbconta_investigar(vr_indctainv).dtiniper := vr_dtiniper;
        vr_tbconta_investigar(vr_indctainv).dtfimper := vr_dtfimper;
        
        BEGIN
          INSERT INTO cecred.tbjur_quebra_sigilo(nrseq_quebra_sigilo,
                                                 cdcooper,
                                                 nrdconta,
                                                 nrcpfcgc,
                                                 dtiniper,
                                                 dtfimper,
                                                 cdoperad,
                                                 idsitqbr)
                                          VALUES(vr_nrseq_quebra_sigilo
                                                ,pr_cdcoptel
                                                ,vr_tab_nrdconta(idx)
                                                ,vr_nrcpfcgc
                                                ,vr_dtiniper
                                                ,vr_dtfimper
                                                ,pr_cdoperad
                                                ,1);
        END;
      END LOOP;
    END IF;

    --Carregar historicos
    pc_carregar_historico_de_para;

    -- Carregar agencias
    pc_carrega_arq_agencias(pr_nrseq_quebra_sigilo => vr_nrseq_quebra_sigilo);

    -- Dados para o arquivo _CONTAS
    pc_carrega_arq_contas(pr_nrseq_quebra_sigilo => vr_nrseq_quebra_sigilo);

    -- Dados para o arquivo _TITULARES
    pc_carrega_arq_titulares(pr_nrseq_quebra_sigilo => vr_nrseq_quebra_sigilo);

    -- Dados para o arquivo _EXTRATO
    pc_carrega_arq_extrato(pr_nrseq_quebra_sigilo => vr_nrseq_quebra_sigilo);

    -- Dados para o arquivo _ORIGEM_DESTINO
    pc_carrega_arq_origem_destino(pr_nrseq_quebra_sigilo => vr_nrseq_quebra_sigilo);

    -- Criar diretorio com base na REFERENCIA do processo de quebra de sigilo bancário
    IF vr_tbarq_cheques_icfjud.count > 0 THEN
      vr_dir_arq := vr_dircop||'/Quebra_'||vr_nrseq_quebra_sigilo;
      -- Primeiro garantimos que o diretorio exista
      
      IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;  
          RAISE vr_erros;
        END IF;
        
        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
          RAISE vr_erros;
        END IF;
      END IF;

      -- Gerar o arquivo com os dados de origem e destino para quebra do sigilo bancário
      pc_gera_arq_cheques_icfjud(pr_nmdir_arquivo        => vr_dir_arq
                                ,pr_nrseq_quebra_sigilo  => vr_nrseq_quebra_sigilo
                                ,pr_tberro               => vr_tberro);
    END IF;
    
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcoptel,
                               pr_cdprogra        => 'QBRSIG',
                               pr_des_destino     => 'bacenjud@ailos.coop.br',
                               pr_des_assunto     => 'Quebra de sigilo bancario',
                               pr_des_corpo       => 'Quebra de sigilo numero '||vr_nrseq_quebra_sigilo||' executada com sucesso!',
                               pr_des_anexo       => '',
                               pr_des_erro        => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      IF vr_typ_saida = 'ERR' THEN
        vr_idx_err := vr_tberro.COUNT + 1;
        vr_tberro(vr_idx_err).dsorigem := 'ENVIO DE EMAIL';
        vr_tberro(vr_idx_err).dserro   := 'Erro ao enviar email - '||vr_dscritic;
        RAISE vr_erros;
      END IF;
    END IF;

    COMMIT;

    -- Verificar se ocorreu algum erro que deve ser tratado antes de gerar o arquivo
    IF vr_tberro.COUNT > 0 THEN
      RAISE vr_erros;
    END IF;
  EXCEPTION
    WHEN vr_erros THEN
      -- Se não possuir erros gera os arquivos
      -- Criar diretorio com base na REFERENCIA do processo de quebra de sigilo bancário
      vr_dir_arq := vr_dircop||'/Quebra_'||vr_nrseq_quebra_sigilo;
      -- Primeiro garantimos que o diretorio exista
      
      IF NOT gene0001.fn_exis_diretorio(vr_dir_arq) THEN
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'CRIAR DIRETORIO ARQUIVO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
          RAISE vr_erros;
        END IF;

        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 '||vr_dir_arq||' 1> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_idx_err := vr_tberro.COUNT + 1;
          vr_tberro(vr_idx_err).dsorigem := 'PERMISSAO NO DIRETORIO';
          vr_tberro(vr_idx_err).dserro   := 'Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
          RAISE vr_erros;
        END IF;
      END IF;
      
      vr_nmarquiv := vr_nrseq_quebra_sigilo || '_ERROS.txt';

      pc_abre_arquivo(pr_dirarquivo => vr_dir_arq
                     ,pr_nmarquivo  => vr_nmarquiv
                     ,pr_ind_arqlog => vr_ind_arqlog);

      -- Chave para percorrer todas as agencias
      FOR x IN vr_tberro.FIRST..vr_tberro.LAST LOOP
        vr_dstext_linha := 'Erro '||vr_tberro(x).dsorigem || ' => ' || vr_tberro(x).dserro;

        pc_escreve_linha_arq(pr_dirarquivo  => vr_dir_arq
                            ,pr_nmarquivo   => vr_nmarquiv
                            ,pr_texto_linha => vr_dstext_linha
                            ,pr_ind_arqlog  => vr_ind_arqlog);
      END LOOP;

      -- Fechar o arquivo
      pc_fechar_arquivo(pr_dirarquivo => vr_dir_arq
                       ,pr_nmarquivo  => vr_nmarquiv
                       ,pr_ind_arqlog => vr_ind_arqlog);

      -- Não altera nenhum dado    
      ROLLBACK;
    WHEN vr_exc_erro THEN
      pc_internal_exception;
      ROLLBACK;
    WHEN OTHERS THEN
      pc_internal_exception;
      ROLLBACK;
  END pc_quebra_sigilo_job;
END tela_qbrsig;
/
