CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_SEGURO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SEGURO
  --  Sistema  : Procedimentos para tela Atenda / Seguros
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informa��es da Atenda Seguros
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca quantidade de seguros do Cooperado */
  FUNCTION fn_qtd_seguros_novos(pr_cdcooper   IN crapcop.cdcooper%TYPE     --C�digo da cooperativa
                               ,pr_nrdconta   IN crapceb.nrdconta%TYPE)   --N�mero da conta solicitada;
                                  RETURN NUMBER;
  
  /* Busca dos seguros do Cooperado */
  PROCEDURE pc_busca_seguros(pr_nrdconta   IN crapceb.nrdconta%TYPE --N�mero da conta solicitada;
                            ,pr_dtmvtolt   IN VARCHAR2              --Data atual
                            ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                            ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                            ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

  /* Detalhamento das informa��es de seguro vida contratado na conta */
  PROCEDURE pc_detalha_seguro_vida(pr_nrdconta   IN crapceb.nrdconta%TYPE --> N�mero da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                                  ,pr_xmlseguro  IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK  

  /* Detalhamento das informa��es de seguro AUTO contratado na conta */
  PROCEDURE pc_detalha_seguro_auto(pr_nrdconta   IN crapceb.nrdconta%TYPE --> N�mero da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                                  ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo                             

END TELA_ATENDA_SEGURO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_SEGURO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SEGURO
  --  Sistema  : Procedimentos para tela Atenda / Seguros
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informa��es da Atenda Seguros
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca quantidade de seguros do Cooperado */
  FUNCTION fn_qtd_seguros_novos(pr_cdcooper   IN crapcop.cdcooper%TYPE     --C�digo da cooperativa
                               ,pr_nrdconta   IN crapceb.nrdconta%TYPE)   --N�mero da conta solicitada;
                                   RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_qtd_seguros_novos
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a quantidade de seguros novos contratados na conta

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Busca dos contratos
      CURSOR cr_tbseg_qtd IS
         SELECT COUNT(1)
           FROM tbseg_contratos segNov
               ,crapcsg         csg
               ,tbseg_parceiro  par
          WHERE segNov.cdparceiro = par.cdparceiro
            AND segNov.cdcooper   = csg.cdcooper
            AND segNov.cdsegura   = csg.cdsegura
            AND segNov.cdcooper   = pr_cdcooper
            AND segNov.nrdconta   = pr_nrdconta
            AND segNov.nrapolice > 0;
      vr_qtd NUMBER := 0;
    BEGIN
      -- Busca da quantidade
      OPEN cr_tbseg_qtd;
      FETCH cr_tbseg_qtd
       INTO vr_qtd;
      CLOSE cr_tbseg_qtd;
      -- Retornar quantidade encontrada
      RETURN vr_qtd;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_qtd_seguros_novos;
  
  /* Busca dos seguros do Cooperado */
  PROCEDURE pc_busca_seguros(pr_nrdconta   IN crapceb.nrdconta%TYPE --N�mero da conta solicitada;
                            ,pr_dtmvtolt   IN VARCHAR2              --Data atual
                            ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                            ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                            ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK
  BEGIN

    /* .............................................................................

    Programa: pc_busca_seguros
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem dos seguros contratados na conta corrente repassada. 
                Esta rotina � uma vers�o simplifica da busca_seguros na Bo33, e criamos a mesma 
                pois como haver� consulta em tabela nova dispon�vel somente no Oracle, n�o 
                poderemos utiliz�-la na BO33.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta din�mica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      vr_xmldata CLOB;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dtmvtolt DATE:=to_date(pr_dtmvtolt,'DD/MM/RRRR');

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
      
      -- Cria��o do contexto para a consulta 
      vr_ctx := 
         dbms_xmlgen.newcontext(' SELECT dsTipo        as "dsTipo"
                                        ,tpSeguro      as "tpSeguro"
                                        ,nrApolice2    as "nrApolice2"
                                        ,nrApolice     as "nrApolice"
                                        ,dtIniVigen    as "dtIniVigen"
                                        ,dtFimVigen    as "dtFimVigen"
                                        ,dsSeguradora  as "dsSeguradora"
                                        ,dsSituac      as "dsSituac"
                                        ,idOrigem      as "idOrigem"
                                        ,idContrato    as "idContrato"
                                        ,nmParceiro    as "nmParceiro"
                                        ,cdSegura      as "cdSegura"
                                        ,nmdsegur      as "nmdsegur"
                                        ,tpplaseg      as "tpplaseg"
                                        ,dtcancel      as "dtcancel"
                                        ,vlpreseg      as "vlpreseg"
                                        ,qtprepag      as "qtprepag"
                                        ,vlprepag      AS "vlprepag"
                                        ,dtdebito      AS "dtdebito"
                                        ,dtiniseg      AS "dtiniseg"
                                        ,dtmvtolt      AS "dtmvtolt"
                                        ,cdsexosg      AS "cdsexosg"
                                        ,qtparcel      AS "qtparcel"
                                        ,nmbenvid_1    AS "nmbenvid_1"
                                        ,nmbenvid_2    AS "nmbenvid_2"
                                        ,nmbenvid_3    AS "nmbenvid_3"
                                        ,nmbenvid_4    AS "nmbenvid_4"
                                        ,nmbenvid_5    AS "nmbenvid_5"
                                        ,dsgraupr_1    AS "dsgraupr_1"
                                        ,dsgraupr_2    AS "dsgraupr_2"
                                        ,dsgraupr_3    AS "dsgraupr_3"
                                        ,dsgraupr_4    AS "dsgraupr_4"
                                        ,dsgraupr_5    AS "dsgraupr_5"
                                        ,txpartic_1    AS "txpartic_1"
                                        ,txpartic_2    AS "txpartic_2"
                                        ,txpartic_3    AS "txpartic_3"
                                        ,txpartic_4    AS "txpartic_4"
                                        ,txpartic_5    AS "txpartic_5"
                                    FROM (SELECT decode(seg.tpseguro,1,''CASA''
                                                                   ,11,''CASA''
                                                                    ,2,''AUTO''
                                                                    ,3,''VIDA''
                                                                    ,4,''PRST'',''    '')            dsTipo
                                                ,seg.tpseguro                                        tpSeguro
                                                ,ltrim(gene0002.fn_mask(seg.nrctrseg,''zzzzz.zz9'')) nrApolice
                                                ,to_char(seg.dtinivig,''dd/mm/rrrr'')                dtIniVigen
                                                ,to_char(wseg.dtfimvig,''dd/mm/rrrr'')               dtFimVigen
                                                ,csg.nmresseg                                        dsSeguradora
                                                ,decode(seg.cdsitseg,3,''Ativo''
                                                                   ,11,''Ativo''
                                                                    ,1,''Ativo''
                                                                    ,2,''Cancelado''
                                                                    ,3,''S''||gene0002.fn_mask(seg.nrctratu,''zzzzz.zz9'')
                                                                    ,4,''Vencido'',''?????????'')    dsSituac
                                                ,''A''                                               idOrigem
                                                ,seg.progress_recid                                  idContrato
                                                ,'' ''                                               nmParceiro
                                                ,seg.nrctrseg                                        nrApolice2
                                                ,seg.cdsegura                                        cdSegura

                                                ,NVL(TRIM(wseg.nmdsegur),'' '')                      nmdsegur
                                                ,NVL(wseg.tpplaseg,0)                                tpplaseg
                                                ,seg.dtcancel                                        dtcancel
                                                ,seg.vlpreseg                                        vlpreseg
                                                ,DECODE(seg.tpseguro,11,seg.qtprepag,(seg.qtprepag - seg.indebito)) qtprepag
                                                ,seg.vlprepag                                        vlprepag
                                                ,to_char(seg.dtdebito,''dd/mm/rrrr'')                dtdebito
                                                ,to_char(seg.dtiniseg,''dd/mm/rrrr'')                dtiniseg
                                                ,to_char(seg.dtmvtolt,''dd/mm/rrrr'')                dtmvtolt
                                                ,wseg.cdsexosg                                       cdsexosg
                                                ,wseg.qtparcel                                       qtparcel
                                                ,seg.nmbenvid##1                                     nmbenvid_1
                                                ,seg.nmbenvid##2                                     nmbenvid_2
                                                ,seg.nmbenvid##3                                     nmbenvid_3
                                                ,seg.nmbenvid##4                                     nmbenvid_4
                                                ,seg.nmbenvid##5                                     nmbenvid_5
                                                ,seg.dsgraupr##1                                     dsgraupr_1
                                                ,seg.dsgraupr##2                                     dsgraupr_2
                                                ,seg.dsgraupr##3                                     dsgraupr_3
                                                ,seg.dsgraupr##4                                     dsgraupr_4
                                                ,seg.dsgraupr##5                                     dsgraupr_5
                                                ,seg.txpartic##1                                     txpartic_1
                                                ,seg.txpartic##2                                     txpartic_2
                                                ,seg.txpartic##3                                     txpartic_3
                                                ,seg.txpartic##4                                     txpartic_4
                                                ,seg.txpartic##5                                     txpartic_5
                                            FROM crapseg seg
                                                ,crapcsg csg
                                                ,crawseg wseg
                                           WHERE seg.cdcooper = csg.cdcooper
                                             AND seg.cdsegura = csg.cdsegura
                                             AND seg.cdcooper = '||vr_cdcooper||'
                                             AND seg.nrdconta = '||pr_nrdconta||'
                                             AND seg.cdcooper = wseg.cdcooper (+)
                                             AND seg.nrdconta = wseg.nrdconta (+)
                                             AND seg.nrctrseg = wseg.nrctrseg (+)
                                             AND ( ( seg.cdsitseg = 2 AND
                                                     seg.dtcancel > (add_months('''||vr_dtmvtolt||''',-12))) OR
                                                   ( seg.cdsitseg = 4 AND
                                                     seg.dtfimvig > (add_months('''||vr_dtmvtolt||''',-12))) OR
                                                   ( seg.cdsitseg IN (1,3,11))
                                                 )
                                            UNION ALL
                                          SELECT decode(segNov.tpseguro,''C'',''CASA''
                                                                       ,''A'',''AUTO''
                                                                       ,''V'',''VIDA''
                                                                       ,''G'',''VIDA''
                                                                       ,''P'',''PRST'',''    '')          dsTipo
                                                ,decode(segNov.tpseguro,''C'',11
                                                                       ,''A'',2
                                                                       ,''V'',3
                                                                       ,''G'',3
                                                                       ,''P'',4,0)                        tpSeguro
                                                ,ltrim(gene0002.fn_mask(segNov.nrapolice,''zzzzz.zz9''))  nrApolice
                                                ,to_char(segNov.dtinicio_vigencia,''dd/mm/rrrr'')         dtIniVigen
                                                ,to_char(segNov.dttermino_vigencia,''dd/mm/rrrr'')        dtFimVigen
                                                ,csg.nmresseg                                             dsSeguradora
                                                ,decode(segNov.indsituacao,''A'',''Ativo''
                                                                          ,''R'',''Renovado''
                                                                          ,''C'',''Cancelado''
                                                                          ,''V'',''Vencido'',''?????????'') dsSituac
                                                ,''N''                                                      idOrigem
                                                ,segNov.idcontrato                                          idContrato
                                                ,par.nmparceiro                                             nmParceiro
                                                ,segNov.nrapolice                                           nrApolice2
                                                ,segNov.cdsegura                                            cdsegura

                                                ,TRIM(segNov.nmsegurado)                                    nmdsegur
                                                ,0                                                          tpplaseg
                                                ,segNov.dtcancela                                           dtcancel
                                                ,0                                                          vlpreseg
                                                ,0                                                          qtprepag
                                                ,0                                                          vlprepag
                                                ,to_char(SYSDATE,''dd/mm/rrrr'')                            dtdebito
                                                ,to_char(SYSDATE,''dd/mm/rrrr'')                            dtiniseg
                                                ,to_char(segNov.dtmvtolt,''dd/mm/rrrr'')                    dtmvtolt
                                                ,0                                                          cdsexosg
                                                ,segNov.qtparcelas                                          qtparcel
                                                ,'' ''                                                      nmbenvid_1
                                                ,'' ''                                                      nmbenvid_2
                                                ,'' ''                                                      nmbenvid_3
                                                ,'' ''                                                      nmbenvid_4
                                                ,'' ''                                                      nmbenvid_5
                                                ,'' ''                                                      dsgraupr_1
                                                ,'' ''                                                      dsgraupr_2
                                                ,'' ''                                                      dsgraupr_3
                                                ,'' ''                                                      dsgraupr_4
                                                ,'' ''                                                      dsgraupr_5
                                                ,0                                                          txpartic_1
                                                ,0                                                          txpartic_2
                                                ,0                                                          txpartic_3
                                                ,0                                                          txpartic_4
                                                ,0                                                          txpartic_5
                                                
                                            FROM tbseg_contratos segNov
                                                ,crapcsg         csg
                                                ,tbseg_parceiro  par
                                           WHERE segNov.cdparceiro = par.cdparceiro
                                             AND segNov.cdcooper   = csg.cdcooper
                                             AND segNov.cdsegura   = csg.cdsegura
                                             AND segNov.cdcooper   = '||vr_cdcooper||'
                                             AND segNov.nrdconta   = '||pr_nrdconta||'
                                             AND segNov.nrapolice > 0)
                                ORDER BY dsSituac,dsTipo, dtFimVigen DESC, nrApolice2
                                 ');
                                           -- AND segNov.nrapolice > 0 � para nao mostrar propostas
      -- Renomeando as tags padr�o
      dbms_xmlgen.setRowSetTag(vr_ctx, 'Contratos');
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Retornar o XML montado no par�metro de sa�da CLOB */
      vr_xmldata := dbms_xmlgen.getXML(ctx => vr_ctx);
      IF vr_xmldata IS NOT NULL THEN
        vr_xmldata := replace(vr_xmldata,'version="1.0"','version="1.0" encoding="ISO-8859-1"');
        pr_retxml := XMLType.createXML(vr_xmldata);
      ELSE
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Contratos/>');
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_busca_seguros: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro n�o tratado na rotina da tela TELA_ATENDA_SEGURO - pc_busca_seguros: ' || SQLERRM;
        -- Carregar XML padr�o para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_seguros;
  
  /* Detalhamento das informa��es de seguro vida contratado na conta */
  PROCEDURE pc_detalha_seguro_vida(pr_nrdconta   IN crapceb.nrdconta%TYPE --> N�mero da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                                  ,pr_xmlseguro  IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_detalha_seguro_vida
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Novo procedimento que receber� a Cooperativa, Conta e ID do contrato 
                para detalhamento das informa��es de seguro vida contratado na conta.
                Este procedimento s� ser� acionado para contratos armazenados nas 
                novas tabelas de seguros.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta din�mica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      vr_xml_benefici XMLTYPE;
      vr_xmldata CLOB;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_SEGURO');
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_xmlseguro
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
      
      /* Montando a Query pai */
      vr_ctx := 
             dbms_xmlgen.newcontext(' SELECT segNov.nmsegurado AS "nmSegurado"
                                            ,decode(segNov.tpseguro,''C'',''CASA''
                                                                   ,''A'',''AUTO''
                                                                   ,''V'',''VIDA''
                                                                   ,''G'',''VIDA''
                                                                   ,''P'',''PRST'',''    '') AS "dsTpSeguro"
                                            ,csg.nmresseg AS "nmSeguradora"                       
                                            ,to_char(segNov.dtinicio_vigencia,''dd/mm/rrrr'')  AS "dtIniVigen"
                                            ,to_char(segNov.dttermino_vigencia,''dd/mm/rrrr'') AS "dtFimVigen"
                                            ,ltrim(gene0002.fn_mask(segNov.nrproposta,''zzzzz.zz9'')) AS "nrProposta"
                                            ,ltrim(gene0002.fn_mask(segNov.nrapolice,''zzzzz.zz9''))  AS "nrApolice"
                                            ,ltrim(gene0002.fn_mask(segNov.nrendosso,''zzzzz.zz9''))  AS "nrEndosso"
                                            ,segNov.dsplano AS "dsPlano"
                                            ,to_char(segNov.Vlcapital,''fm999g999g990d00'') AS "vlCapital"
                                            ,ltrim(gene0002.fn_mask(segNov.nrapolice_renovacao,''zzzzz.zz9''))  AS "nrApoliceRenova"
                                            ,to_char(segNov.vlpremio_liquido,''fm999g999g990d00'') AS "vlPremioLiquido"
                                            ,to_char(segNov.qtparcelas,''fm999g999g990'') AS "qtParcelas"
                                            ,to_char(segNov.vlpremio_total,''fm999g999g990d00'') AS "vlPremioTotal"
                                            ,to_char(segNov.vlparcela,''fm999g999g990d00'') AS "vlParcela"
                                            ,segNov.nrdiadebito AS "ddMelhorDia"
                                            ,to_char(segNov.percomissao,''fm990d00'')  AS "perComissao"
                                            ,segNov.dsobservacao AS "dsObservacoes"
                                        FROM tbseg_contratos segNov
                                            ,crapcsg         csg
                                       WHERE segNov.cdcooper   = csg.cdcooper
                                         AND segNov.cdsegura   = csg.cdsegura
                                         AND segNov.cdcooper   = '||vr_cdcooper||'
                                         AND segNov.nrdconta   = '||pr_nrdconta||'
                                         AND segNov.idcontrato = '||pr_idcontrato);
      dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Enfim efetua a Query e gera o XML com as informa��es do contrado */
           
      /* Retornar o XML montado no par�metro de sa�da CLOB */
      vr_xmldata := dbms_xmlgen.getXML(ctx => vr_ctx);
      IF vr_xmldata IS NOT NULL THEN
        vr_xmldata := replace(vr_xmldata,'version="1.0"','version="1.0" encoding="ISO-8859-1"');
        pr_xmlseguro := XMLType.createXML(vr_xmldata);
      ELSE
        pr_xmlseguro := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Contratos/>');
      END IF;

      gene0007.pc_insere_tag(pr_xml => pr_xmlseguro, pr_tag_pai => 'Contrato', pr_posicao => 0, pr_tag_nova => 'Beneficiarios', pr_tag_cont => '', pr_des_erro => pr_des_erro);
      
      /* Somente se encontrou registros */
      IF dbms_xmlgen.getNumRowsProcessed(vr_ctx) > 0 THEN
        
        /* Adicionando os benefici�rios */
        vr_ctx := 
               dbms_xmlgen.newcontext(' SELECT segBen.nmbenefici AS "nmBenefici"
                                              ,to_char(segBen.dtnascimento,''dd/mm/rrrr'') AS "dtNascimento"
                                              ,decode(segBen.dsgrau_parente,''F'',''FILHO(A)'',''P'',''PAIS'',''C'',''CONJUGE'',''????????'') AS "dsGrauParente"
                                              ,to_char(segBen.perparticipacao,''fm990d00'')  AS "perParticipa"
                                          FROM tbseg_vida_benefici segBen
                                         WHERE segBen.idcontrato = '||pr_idcontrato);
        dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
        dbms_xmlgen.setrowtag(vr_ctx, 'Benef');
        
        vr_xml_benefici := dbms_xmlgen.getxmlType(vr_ctx);
        
        /* Somente se encontrou registros */
        IF dbms_xmlgen.getNumRowsProcessed(vr_ctx) > 0 THEN
        
          /* Adicionaremos aos beneficiarios ao XML do Contrato */
          pr_xmlseguro := XmlType.appendChildXML(pr_xmlseguro
                                                ,'/Contrato/Beneficiarios'
                                                ,vr_xml_benefici);
        END IF;

      END IF;
       
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_vida: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro n�o tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_vida: ' || SQLERRM;
        -- Carregar XML padr�o para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_detalha_seguro_vida;  


  /* Detalhamento das informa��es de seguro AUTO contratado na conta */
  PROCEDURE pc_detalha_seguro_auto(pr_nrdconta   IN crapceb.nrdconta%TYPE --> N�mero da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informa��es de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2              --Descri��o da cr�tica
                                  ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_detalha_seguro_auto
    Sistema : Ayllos Web
    Autor   : Guilherme/SUPERO
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Novo procedimento que receber� a Cooperativa, Conta e ID do contrato 
                para detalhamento das informa��es de seguro auto contratado na conta.
                Este procedimento s� ser� acionado para contratos armazenados nas 
                novas tabelas de seguros.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta din�mica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_xmlseguro
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
      
      /* Montando a Query pai */
      vr_ctx := 
             dbms_xmlgen.newcontext(' SELECT segNov.nmsegurado                                        AS "nmSegurado"
                                            ,''AUTOMOVEL''                                            AS "dsTpSeguro"
                                            ,UPPER(gene0007.fn_caract_acento(csg.nmsegura))           AS "nmSeguradora"                       
                                            ,to_char(segNov.dtinicio_vigencia,''dd/mm/rrrr'')         AS "dtIniVigen"
                                            ,to_char(segNov.dttermino_vigencia,''dd/mm/rrrr'')        AS "dtFimVigen"
                                            ,ltrim(segNov.nrproposta)                                 AS "nrProposta"
                                            ,ltrim(segNov.nrapolice)                                  AS "nrApolice"
                                            ,ltrim(segNov.nrendosso)                                  AS "nrEndosso"
                                            ,NVL(gene0007.fn_caract_acento(tipsub.dsendosso),'' '')   AS "dsEndosso"
                                            ,NVL(gene0007.fn_caract_acento(tipsub.dssub_endosso),'' '') AS "dsSubEndosso"

                                            ,UPPER(gene0007.fn_caract_acento(auto.nmmarca))           AS "nmMarca"
                                            ,UPPER(gene0007.fn_caract_acento(auto.dsmodelo))          AS "nmModelo"
                                            ,auto.nrano_fabrica                                       AS "nrAnoFab"
                                            ,auto.nrano_modelo                                        AS "nrAnoMod"
                                            ,auto.dsplaca                                             AS "dsPlaca"
                                            ,auto.dschassi                                            AS "dsChassi"
                                            ,to_char(auto.vlfranquia,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'') AS "vlFranquia"

                                            ,to_char(segNov.vlpremio_liquido,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')    AS "vlPremioLiquido"
                                            ,to_char(segNov.vlpremio_total,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')      AS "vlPremioTotal"
                                            ,to_char(segNov.qtparcelas,''fm999g999g990'')             AS "qtParcelas"
                                            ,to_char(segNov.vlparcela,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')           AS "vlParcela"
                                            ,segNov.nrdiadebito                                       AS "ddMelhorDia"
                                            ,to_char(segNov.percomissao,''fm990d00'',''NLS_NUMERIC_CHARACTERS=,.'')                 AS "perComissao"
                                        FROM tbseg_contratos segNov
                                            ,crapcsg         csg
                                            ,tbseg_auto_veiculos auto
                                            ,tbseg_tipos_endosso tipsub
                                       WHERE csg.cdcooper         = 1
                                         AND csg.cdsegura         = segNov.cdsegura
                                         AND segNov.cdcooper      = '||vr_cdcooper||'
                                         AND segNov.nrdconta      = '||pr_nrdconta||'
                                         AND segNov.idcontrato    = '||pr_idcontrato ||'
                                         AND segNov.tpseguro      = ''A''
                                         AND segNov.idcontrato    = auto.idcontrato
                                         AND segNov.tpendosso     = tipsub.tpendosso(+)
                                         AND segNov.tpsub_endosso = tipsub.tpsub_endosso(+)');
      dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Enfim efetua a Query e gera o XML com as informa��es do contrado */
      pr_xmlseguro := dbms_xmlgen.getXMLType(vr_ctx);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_auto: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro n�o tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_auto: ' || SQLERRM;
        -- Carregar XML padr�o para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_detalha_seguro_auto;  


END TELA_ATENDA_SEGURO;
/
