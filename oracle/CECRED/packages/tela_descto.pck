CREATE OR REPLACE PACKAGE CECRED.TELA_DESCTO AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TELA_DESCTO                     Antiga: 
  --  Autor   : Jaison
  --  Data    : Setembro/2016                   Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo DESCTO - Controle de Desconto de Cheques.
  --
  --  Alteracoes: 
  --  
  --------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_rel_bordero_nao_liberados(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_rel_limites_nao_renovados(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

END TELA_DESCTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_DESCTO AS

 /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: TELA_DESCTO                     Antiga: 
  --  Autor   : Jaison
  --  Data    : Setembro/2016                   Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo DESCTO - Controle de Desconto de Cheques.
  --
  --  Alteracoes: 
  --  
  --------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_rel_bordero_nao_liberados(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_rel_bordero_nao_liberados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Buscar os dados
      CURSOR cr_dados(pr_cdcooper crapbdc.cdcooper%TYPE
                     ,pr_dtiniper DATE
                     ,pr_dtfimper DATE) IS
        SELECT bdc.dtmvtolt,
               ass.cdagenci,
               ass.nrdconta,
               bdc.nrborder,
               bdc.dtinsori,
               bdc.hrtransa,
               bdc.cdopeori,
               bdc.insitbdc,
               ope.nmoperad,
               DECODE(bdc.insitbdc, 1, 'EM ESTUDO', 'ANALISADO') dssitbdc

          FROM crapbdc bdc,
               crapass ass,
               crapope ope

         WHERE bdc.cdcooper = ass.cdcooper
           AND bdc.nrdconta = ass.nrdconta
           AND bdc.cdcooper = ope.cdcooper(+)
           AND bdc.cdopeori = ope.cdoperad(+)
           AND bdc.cdcooper = pr_cdcooper
           AND bdc.insitbdc IN (1,2) -- 1–Estudo / 2–Analise
           AND bdc.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper

      ORDER BY ass.cdagenci,
               bdc.dtmvtolt,
               ass.nrdconta;

      -- Buscar os cheques
      CURSOR cr_crapcdb(pr_cdcooper crapcdb.cdcooper%TYPE
                       ,pr_nrdconta crapcdb.nrdconta%TYPE
                       ,pr_nrborder crapcdb.nrborder%TYPE) IS
        SELECT crapcdb.cdbanchq,
               crapcdb.vlcheque
          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrdconta = pr_nrdconta
           AND crapcdb.nrborder = pr_nrborder;

      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_reto VARCHAR2(100);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cddagenc VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_dtiniper crapbdc.dtmvtolt%TYPE;
      vr_dtfimper crapbdc.dtmvtolt%TYPE;
      vr_dstextab craptab.dstextab%TYPE;
      vr_cdagenci crapass.cdagenci%TYPE;
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nrborder crapbdc.nrborder%TYPE;
      vr_vlchqmai NUMBER;
      vr_qt_ban85 NUMBER;
      vr_vl_ban85 NUMBER;
      vr_qt_menor NUMBER;
      vr_vl_menor NUMBER;
      vr_qt_maior NUMBER;
      vr_vl_maior NUMBER;
      vr_nmarqpdf VARCHAR2(1000);

      vr_nmarquiv VARCHAR2(200);
      vr_dsdireto VARCHAR2(200);
      vr_dscomand VARCHAR2(4000);
      vr_typsaida VARCHAR2(100);

      -- Variáveis para armazenar as informações em XML
      vr_des_xml   CLOB;
      vr_txtcompl  VARCHAR2(32600);

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
      END;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_rel_bordero_nao_liberados'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cddagenc
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Se NAO informou data inicial
      IF TRIM(pr_dtiniper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO informou data final
      IF TRIM(pr_dtfimper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Seta as datas
      vr_dtiniper := TO_DATE(pr_dtiniper, 'DD/MM/RRRR');
      vr_dtfimper := TO_DATE(pr_dtfimper, 'DD/MM/RRRR');

      -- Se foi informado intervalo superior a 60 dias
      IF (vr_dtiniper - vr_dtfimper) > 60 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe um intervalo de até 60 dias.';
        RAISE vr_exc_erro;
      END IF;

      -- Buscar parametro maiores cheques
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper 
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MAIORESCHQ'
                                               ,pr_tpregist => 1); 
      -- Se NAO encontrou
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => 55)
                    || ' => CRED-USUARI-11-MAIORESCHQ-001';
        RAISE vr_exc_erro;
      ELSE
        -- Valor maior cheque
        vr_vlchqmai := TO_NUMBER(SUBSTR(vr_dstextab, 1, 15));
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Seta os valores
      vr_cdagenci := NVL(pr_cdagenci,0);
      vr_nrdconta := NVL(pr_nrdconta,0);
      vr_nrborder := NVL(pr_nrborder,0);

      -- Inicio
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>'||
                       '<Relat vlchqmai="'|| TO_CHAR(vr_vlchqmai,'fm999G999G999G990D00') ||'" 
                               dtiniper="'|| TO_CHAR(vr_dtiniper, 'DD/MM/RRRR') ||'" 
                               dtfimper="'|| TO_CHAR(vr_dtfimper, 'DD/MM/RRRR') ||'" 
                               cdagenci="'|| (CASE WHEN vr_cdagenci = 0 THEN '0 - TODOS' ELSE TO_CHAR(vr_cdagenci) END) ||'" 
                               nrdconta="'|| (CASE WHEN vr_nrdconta = 0 THEN '0 - TODAS' ELSE TRIM(GENE0002.fn_mask_conta(TO_CHAR(vr_nrdconta))) END) ||'" 
                               nrborder="'|| (CASE WHEN vr_nrborder = 0 THEN '0 - TODOS' ELSE TRIM(GENE0002.fn_mask_contrato(TO_CHAR(vr_nrborder))) END) ||'">');

      -- Buscar os dados
      FOR rw_dados IN cr_dados(pr_cdcooper => vr_cdcooper
                              ,pr_dtiniper => vr_dtiniper 
                              ,pr_dtfimper => vr_dtfimper) LOOP

        -- Se foi informado agencia e for diferente vai para o proximo
        IF vr_cdagenci > 0 AND vr_cdagenci <> rw_dados.cdagenci THEN
          CONTINUE;
        END IF;

        -- Se foi informado conta e for diferente vai para o proximo
        IF vr_nrdconta > 0 AND vr_nrdconta <> rw_dados.nrdconta THEN
          CONTINUE;
        END IF;

        -- Se foi informado bordero e for diferente vai para o proximo
        IF vr_nrborder > 0 AND vr_nrborder <> rw_dados.nrborder THEN
          CONTINUE;
        END IF;

        -- Reseta os valores
        vr_qt_ban85 := 0;
        vr_vl_ban85 := 0;
        vr_qt_menor := 0;
        vr_vl_menor := 0;
        vr_qt_maior := 0;
        vr_vl_maior := 0;

        -- Buscar os cheques
        FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => rw_dados.nrdconta 
                                    ,pr_nrborder => rw_dados.nrborder) LOOP
          -- Cheques da cooperativa
          IF rw_crapcdb.cdbanchq = 85 THEN
            vr_qt_ban85 := vr_qt_ban85 + 1;
            vr_vl_ban85 := vr_vl_ban85 + rw_crapcdb.vlcheque;
          ELSE
            -- Se valor cheques maiores for maior que valor do cheque
            IF vr_vlchqmai > rw_crapcdb.vlcheque THEN
              vr_qt_menor := vr_qt_menor + 1;
              vr_vl_menor := vr_vl_menor + rw_crapcdb.vlcheque;
            ELSE
              vr_qt_maior := vr_qt_maior + 1;
              vr_vl_maior := vr_vl_maior + rw_crapcdb.vlcheque;
            END IF;
          END IF;
        END LOOP;

        pc_escreve_xml('<Bordero>'||
                         '<dtmvtolt>'|| TO_CHAR(rw_dados.dtmvtolt, 'DD/MM/RRRR') ||'</dtmvtolt>'||
                         '<cdagenci>'|| rw_dados.cdagenci ||'</cdagenci>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(rw_dados.nrdconta)) ||'</nrdconta>'||
                         '<nrborder>'|| TRIM(GENE0002.fn_mask_contrato(rw_dados.nrborder)) ||'</nrborder>'||
                         '<dat_real>'|| TO_CHAR(rw_dados.dtinsori, 'DD/MM/RRRR') ||'</dat_real>'||
                         '<hor_real>'|| GENE0002.fn_converte_time_data(rw_dados.hrtransa) ||'</hor_real>'||
                         '<qt_ban85>'|| vr_qt_ban85 ||'</qt_ban85>'||
                         '<vl_ban85>'|| TO_CHAR(vr_vl_ban85,'fm999G999G999G990D00') ||'</vl_ban85>'||
                         '<qt_menor>'|| vr_qt_menor ||'</qt_menor>'||
                         '<vl_menor>'|| TO_CHAR(vr_vl_menor,'fm999G999G999G990D00') ||'</vl_menor>'||
                         '<qt_maior>'|| vr_qt_maior ||'</qt_maior>'||
                         '<vl_maior>'|| TO_CHAR(vr_vl_maior,'fm999G999G999G990D00') ||'</vl_maior>'||
                         '<nmoperad>'|| SUBSTR(rw_dados.nmoperad, 1, 25) ||'</nmoperad>'||
                         '<dssitbdc>'|| rw_dados.dssitbdc ||'</dssitbdc>'||
                       '</Bordero>');
      END LOOP;

      -- Final
      pc_escreve_xml( '</Relat></raiz>',TRUE);

      -- Buscar diretorio da cooperativa
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/rl');

      vr_nmarquiv := 'crrl725';

      -- Remover arquivo existente
      vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomand
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro
      IF vr_typsaida = 'ERR' THEN
        vr_dscritic := 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Montar nome do arquivo
      vr_nmarqpdf := vr_nmarquiv || GENE0002.fn_busca_time || '.pdf';

      --> Solicita geracao do PDF
      GENE0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                                 ,pr_cdprogra  => 'DESCTO'
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/raiz/Relat/Bordero'
                                 ,pr_dsjasper  => 'crrl725.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqpdf
                                 ,pr_cdrelato => 725
                                 ,pr_flg_gerar => 'S'
                                 ,pr_qtcoluna  => 234
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => ' '
                                 ,pr_nrcopias  => 1
                                 ,pr_nrvergrl  => 1
                                 ,pr_des_erro  => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      IF vr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_erro; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;

      END IF; -- pr_idorigem = 5

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela DESCTO: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_rel_bordero_nao_liberados;

  PROCEDURE pc_rel_limites_nao_renovados(pr_dtiniper   IN VARCHAR2              --> Data inicial
                                        ,pr_dtfimper   IN VARCHAR2              --> Data final
                                        ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Numero do PA
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Numero do bordero
                                        ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_rel_limites_nao_renovados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Buscar os dados
      CURSOR cr_dados(pr_cdcooper craplim.cdcooper%TYPE
                     ,pr_dtiniper DATE
                     ,pr_dtfimper DATE) IS
        SELECT ass.cdagenci,
               ass.nrdconta,
               ass.nmprimtl,
               lim.nrctrlim,
               lim.vllimite,
               lim.dtfimvig,
               lim.dsnrenov

          FROM crapass ass,
               craplim lim

         WHERE ass.cdcooper = lim.cdcooper
           AND ass.nrdconta = lim.nrdconta
           AND lim.tpctrlim = 2 -- Cheque
           AND lim.insitlim = 2 -- Ativo
           AND lim.cdcooper = pr_cdcooper
           AND lim.dsnrenov <> ' '
           AND lim.dtfimvig BETWEEN pr_dtiniper AND pr_dtfimper

      ORDER BY ass.cdagenci,
               ass.nrdconta;

      -- Busca o nome das agencias
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT crapage.cdagenci,
                crapage.nmresage
           FROM crapage
          WHERE crapage.cdcooper = pr_cdcooper;

      -- Telefone do cooperado
      CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%TYPE
                       ,pr_nrdconta IN craptfc.nrdconta%TYPE) IS
         SELECT craptfc.nrdddtfc,
                craptfc.nrtelefo
           FROM craptfc
          WHERE craptfc.cdcooper = pr_cdcooper
            AND craptfc.nrdconta = pr_nrdconta
            AND craptfc.idseqttl = 1
       ORDER BY craptfc.tptelefo, 
                craptfc.nrtelefo;
      rw_craptfc cr_craptfc%ROWTYPE;

      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_reto VARCHAR2(100);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cddagenc VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_dtiniper crapbdc.dtmvtolt%TYPE;
      vr_dtfimper crapbdc.dtmvtolt%TYPE;
      vr_cdagenci crapass.cdagenci%TYPE;
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nrctrlim craplim.nrctrlim%TYPE;
      vr_nmarqpdf VARCHAR2(1000);
      vr_nrtelefo VARCHAR2(50);
      vr_blnfound BOOLEAN;

      vr_nmarquiv VARCHAR2(200);
      vr_dsdireto VARCHAR2(200);
      vr_dscomand VARCHAR2(4000);
      vr_typsaida VARCHAR2(100);

      -- Tipo de registros
      TYPE typ_reg_crapage IS RECORD
        (nmresage crapage.nmresage%TYPE);

      -- Tipo de dados
      TYPE typ_tab_crapage  IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

      -- Vetor de memoria
      vr_tab_crapage  typ_tab_crapage;
      vr_vet_nrenova  GENE0002.typ_split;

      -- Variáveis para armazenar as informações em XML
      vr_des_xml   CLOB;
      vr_txtcompl  VARCHAR2(32600);

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
      END;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_rel_limites_nao_renovados'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cddagenc
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Se NAO informou data inicial
      IF TRIM(pr_dtiniper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.';
        RAISE vr_exc_erro;
      END IF;

      -- Se NAO informou data final
      IF TRIM(pr_dtfimper) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Seta as datas
      vr_dtiniper := TO_DATE(pr_dtiniper, 'DD/MM/RRRR');
      vr_dtfimper := TO_DATE(pr_dtfimper, 'DD/MM/RRRR');

      -- Se foi informado intervalo superior a 30 dias
      IF (vr_dtiniper - vr_dtfimper) > 30 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe um intervalo de até 30 dias.';
        RAISE vr_exc_erro;
      END IF;

      -- Se data final for igual ou superior a data atual
      IF vr_dtfimper >= rw_crapdat.dtmvtolt THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe uma data inferior ao dia atual.';
        RAISE vr_exc_erro;
      END IF;

      -- Busca o nome das agencias
      FOR rw_crapage IN cr_crapage(pr_cdcooper => vr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Seta os valores
      vr_cdagenci := NVL(pr_cdagenci,0);
      vr_nrdconta := NVL(pr_nrdconta,0);
      vr_nrctrlim := NVL(pr_nrctrlim,0);

      -- Inicio
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>'||
                       '<Relat dtiniper="'|| TO_CHAR(vr_dtiniper, 'DD/MM/RRRR') ||'" 
                               dtfimper="'|| TO_CHAR(vr_dtfimper, 'DD/MM/RRRR') ||'" 
                               cdagenci="'|| (CASE WHEN vr_cdagenci = 0 THEN '0 - TODOS' ELSE TO_CHAR(vr_cdagenci) END) ||'" 
                               nrdconta="'|| (CASE WHEN vr_nrdconta = 0 THEN '0 - TODAS' ELSE TRIM(GENE0002.fn_mask_conta(TO_CHAR(vr_nrdconta))) END) ||'" 
                               nrctrlim="'|| (CASE WHEN vr_nrctrlim = 0 THEN '0 - TODOS' ELSE TRIM(GENE0002.fn_mask_contrato(TO_CHAR(vr_nrctrlim))) END) ||'">');

      -- Buscar os dados
      FOR rw_dados IN cr_dados(pr_cdcooper => vr_cdcooper
                              ,pr_dtiniper => vr_dtiniper 
                              ,pr_dtfimper => vr_dtfimper) LOOP

        -- Se foi informado agencia e for diferente vai para o proximo
        IF vr_cdagenci > 0 AND vr_cdagenci <> rw_dados.cdagenci THEN
          CONTINUE;
        END IF;

        -- Se foi informado conta e for diferente vai para o proximo
        IF vr_nrdconta > 0 AND vr_nrdconta <> rw_dados.nrdconta THEN
          CONTINUE;
        END IF;

        -- Se foi informado contrato e for diferente vai para o proximo
        IF vr_nrctrlim > 0 AND vr_nrctrlim <> rw_dados.nrctrlim THEN
          CONTINUE;
        END IF;

        vr_nrtelefo := '';
        -- Busca o telefone
        OPEN cr_craptfc(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => rw_dados.nrdconta);
        FETCH cr_craptfc INTO rw_craptfc;
        vr_blnfound := cr_craptfc%FOUND;
        CLOSE cr_craptfc;
        -- Se encontrar
        IF vr_blnfound THEN
          vr_nrtelefo := rw_craptfc.nrdddtfc|| ' ' ||rw_craptfc.nrtelefo;
        END IF;

        -- Efetua o split das informacoes separados por ;
        vr_vet_nrenova := GENE0002.fn_quebra_string(pr_string  => rw_dados.dsnrenov
                                                   ,pr_delimit => '|');

        pc_escreve_xml('<Limite>'||
                         '<cdagenci>'|| rw_dados.cdagenci ||'</cdagenci>'||
                         '<nmresage>'|| vr_tab_crapage(rw_dados.cdagenci).nmresage ||'</nmresage>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(rw_dados.nrdconta)) ||'</nrdconta>'||
                         '<nmprimtl>'|| SUBSTR(rw_dados.nmprimtl, 1, 30) ||'</nmprimtl>'||
                         '<nrtelefo>'|| vr_nrtelefo ||'</nrtelefo>'||
                         '<nrctrlim>'|| TRIM(GENE0002.fn_mask_contrato(rw_dados.nrctrlim)) ||'</nrctrlim>'||
                         '<vllimite>'|| TO_CHAR(rw_dados.vllimite,'fm999G999G999G990D00') ||'</vllimite>'||
                         '<dtfimvig>'|| TO_CHAR(rw_dados.dtfimvig,'DD/MM/RRRR') ||'</dtfimvig>'||
                         '<dsnrenov>'|| (CASE WHEN vr_vet_nrenova.EXISTS(1) THEN SUBSTR(vr_vet_nrenova(1), 1, 32) ELSE '' END) ||'</dsnrenov>'||
                         '<dsvlrmot>'|| (CASE WHEN vr_vet_nrenova.EXISTS(2) THEN vr_vet_nrenova(2) ELSE '' END) ||'</dsvlrmot>'||
                       '</Limite>');
      END LOOP;

      -- Final
      pc_escreve_xml( '</Relat></raiz>',TRUE);

      -- Buscar diretorio da cooperativa
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/rl');

      vr_nmarquiv := 'crrl726';

      -- Remover arquivo existente
      vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomand
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro
      IF vr_typsaida = 'ERR' THEN
        vr_dscritic := 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Montar nome do arquivo
      vr_nmarqpdf := vr_nmarquiv || GENE0002.fn_busca_time || '.pdf';

      --> Solicita geracao do PDF
      GENE0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                                 ,pr_cdprogra  => 'DESCTO'
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/raiz/Relat/Limite'
                                 ,pr_dsjasper  => 'crrl726.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqpdf
                                 ,pr_cdrelato => 726
                                 ,pr_flg_gerar => 'S'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => ' '
                                 ,pr_nrcopias  => 1
                                 ,pr_nrvergrl  => 1
                                 ,pr_des_erro  => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      IF vr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_erro; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;

      END IF; -- pr_idorigem = 5

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela DESCTO: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_rel_limites_nao_renovados;

END TELA_DESCTO;
/
