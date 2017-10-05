CREATE OR REPLACE PACKAGE CECRED.CAIX0001 IS

  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : CAIX0001
  --  Sistema  : Rotinas referentes a Tela BCAIXA
  --  Sigla    : CAIX
  --  Autor    : Lucas Ranghetti
  --  Data     : Fevereiro/2015.                   Ultima atualizacao: 20/06/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar procedures referentes a tela bcaixa

  -- Alteracoes: 06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP (Guilherme/SUPERO)
  --
  -- 20/06/2017 - Criada procedure para gerar LOG pc_gera_log no retorno da Gene0002 
  --              Setado modulo
  --              Padrão de mensagens 
  --              Incluido parametro de entrada com o nome do programa na procedure pc_saldo_cofre 
  --              Incluido parametro de entrada com o nome do programa na procedure pc_gera_relato 
  --              Incluido parametro de entrada com a indica a etapa de execução da tela de chamada
  --                nas seguintes procedures pc_saldo_caixas - pc_saldo_cofre - pc_saldo_total - pc_gera_relato
  --              ( Belli - Envolti - 20/06/2017 - Chamado 660322)

  -----------------------------------------------------------------------------------------------------------

  TYPE typ_reg_crapbcx IS
    RECORD (cdagenci INTEGER
           ,nrdcaixa INTEGER
           ,nmoperad VARCHAR2(30)
           ,vldsdtot NUMBER
           ,csituaca VARCHAR2(16)
           ,tpcaicof VARCHAR2(5)
           ,vltotcai NUMBER
           ,vltotcof NUMBER
           ,totcacof NUMBER);
  TYPE typ_tab_crapbcx IS TABLE OF typ_reg_crapbcx INDEX BY PLS_INTEGER;


  TYPE typ_w_craphis IS
    RECORD (cdhistor craphis.cdhistor%TYPE
           ,dshistor VARCHAR2(18)
           ,dsdcompl VARCHAR2(50)
           ,qtlanmto INTEGER
           ,vllanmto NUMBER);
  TYPE typ_tab_craphis IS TABLE OF typ_w_craphis INDEX BY PLS_INTEGER;

  TYPE typ_w_empresa IS
    RECORD (cdempres crapccs.cdempres%TYPE
           ,qtlanmto INTEGER
           ,vllanmto NUMBER);
  TYPE typ_tab_empresa IS TABLE OF typ_w_empresa INDEX BY PLS_INTEGER;

  PROCEDURE pc_saldo_caixas(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                           ,pr_nrdcaixa IN INTEGER                 -- Caixa
                           ,pr_dtrefere IN DATE                    -- Data Referencia
                           ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
                           ,pr_cdprogra IN VARCHAR2                -- Programa
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                           ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                           ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                           ,pr_saldotot OUT NUMBER                 -- Saldo Total
                           ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                           ,pr_clobxmlc OUT CLOB);                 -- xml com Registros da crapbcx

  PROCEDURE pc_saldo_cofre(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                 -- Caixa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                          ,pr_cdprogra IN VARCHAR2                -- Programa
                          ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                          ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                          ,pr_saldotot OUT NUMBER                 -- Saldo Total
                          ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                          ,pr_clobxmlc OUT CLOB);                 -- xml com Registros da crapbcx

  PROCEDURE pc_saldo_total(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                 -- Caixa
                          ,pr_dtrefere IN DATE                    -- Data Referencia
                          ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
                          ,pr_cdprogra IN VARCHAR2                -- Programa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                          ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                          ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                          ,pr_saldotot OUT NUMBER                 -- Saldo Total
                          ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                          ,pr_clobxmlc OUT CLOB);                 -- xml com Registros da crapbcx

 PROCEDURE pc_disp_dados_bole_caixa(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Agencia/PA
                                    ,pr_nrdcaixa IN INTEGER               --> Caixa
                                    ,pr_rowid    IN ROWID
                                    ,pr_nmarquiv IN VARCHAR2              --> Arquivo Impressao
                                    ,pr_flgimpre IN INTEGER               --> Impressao Sim=1/Nao=0
                                    ,pr_cdprogra IN VARCHAR2              --> Programa
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Com erros
                                    ,pr_vlcredit OUT NUMBER                --> Valor Credito
                                    ,pr_vldebito OUT NUMBER);

 PROCEDURE pc_gera_relato(pr_cdcooper IN crapcop.cdcooper%TYPE     -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE    -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                  -- Caixa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    -- Data movimento
                          ,pr_tpcaicof IN VARCHAR2                 -- Caixa/Cofre/Total
                          ,pr_saldotot IN NUMBER                   -- Saldo Total
                          ,pr_cdprogra IN VARCHAR2                 -- Programa
                          ,pr_inetapa  IN VARCHAR2                 -- etapa de execução da tela de chamada
                          ,pr_tab_crapbcx IN typ_tab_crapbcx       -- Registros da crapbcx
                          ,pr_nmarqimp OUT VARCHAR2                -- Caminho do arquivo
                          ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica

 PROCEDURE pc_gera_log(pr_cdcooper     IN  crapcop.cdcooper%TYPE     -- Cooperativa
                      ,pr_modulo       IN  VARCHAR2                  -- Modulo que disparou
                      ,pr_acao         IN  VARCHAR2                  -- Ação do modulo
                      ,pr_cdagenci     IN  crapage.cdagenci%TYPE     -- Agencia/PA
                      ,pr_nrdcaixa     IN  INTEGER                   -- Caixa
                      ,pr_dtmvtolt     IN  crapdat.dtmvtolt%TYPE     -- Data movimento
                      ,pr_tpcaicof     IN  VARCHAR2                  -- Tipo de pequisa
                      ,pr_dscritic_in  IN  crapcri.dscritic%TYPE     -- Descricao da critica Entrada
                      ,pr_dscritic_out OUT crapcri.dscritic%TYPE     -- Descricao da critica Saida
   ) ; 

END CAIX0001;
/
create or replace package body cecred.CAIX0001 is

  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : CAIX0001
  --  Sistema  : Rotinas referentes a Tela BCAIXA
  --  Sigla    : CAIX
  --  Autor    : Lucas Ranghetti
  --  Data     : Fevereiro/2015.                   Ultima atualizacao: 20/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar procedures referentes a tela bcaixa Opcao T
  -- Alteracoes: 11/03/2015 - Conversao de Progress -->> Oracle (Lucas R. #245838)
  --
  --             24/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
  --                          sobre o campo cdopecxa.(Carlos Rafael Tanholi).
  --
  --             20/06/2017 - Criada procedure para gerar LOG pc_gera_log no retorno da Gene0002 
  --                          Setado modulo
  --                          Padrão de mensangnes 
  --                          Incluido parametro de entrada com o nome do programa na procedure pc_saldo_cofre 
  --                          Incluido parametro de entrada com o nome do programa na procedure pc_gera_relato 
  --                          Incluido parametro de entrada que indica a etapa de execução da tela de chamada
  --                            nas seguintes procedures pc_saldo_caixas - pc_saldo_cofre - pc_saldo_total 
  --                            - pc_gera_relato: Executa o relatório apenas no 2o momento
  --                          ( Belli - Envolti - 20/06/2017 - Chamado 660322)
  --
  --             20/09/2017 - Alterada pc_gera_log para não gravar nome de arquivo de log e gravar cdprograma
  --                          (Ana - Envolti - 20/09/2017 - Chamado 746134)
  --  
  -----------------------------------------------------------------------------------------------------------

  -- Cursores genericos
  CURSOR cr_crapope (pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_cdoperad IN crapope.cdoperad%TYPE) IS
  SELECT ope.nmoperad
        ,ope.dsimpres
    FROM crapope ope
   WHERE ope.cdcooper = pr_cdcooper
     AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  -- Variaveis Globais dentro da package

  -- mensgaem que vai para o usuario - 23/06/2017 - Chamado 660322
  vr_dscritic_padrao    VARCHAR2(2000) := 'Nao foi possivel gerar impressao, tente mais tarde';
            
  -- Variaveis de impressão
  vr_nmarqimp VARCHAR2(200);

  PROCEDURE pc_saldo_caixas(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                           ,pr_nrdcaixa IN INTEGER                 -- Caixa
                           ,pr_dtrefere IN DATE                    -- Data Referencia
                           ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
                           ,pr_cdprogra IN VARCHAR2                -- Programa
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                           ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                           ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                           ,pr_saldotot OUT NUMBER                 -- Saldo Total
                           ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                           ,pr_clobxmlc OUT CLOB) IS               -- Registros da crapbcx
/* .............................................................................

   Programa: pc_saldo_caixas                 Antigo: b1wgen0096.p --> SaldoCaixas
   Sistema : CRED
   Sigla   : CAIX0001
   Autor   : Lucas Eduardo Ranghetti
   Data    : Fevereiro/2015.                        Ultima atualizacao: 20/06/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Consultar saldo atual dos caixas em tela.

   Alteracoes: 22/01/2013 - Alterada procedure SaldoCaixas para aceitar
                            pac 0 (Daniele).

               28/08/2013 - Alterada procedure SaldoCaixas para filtrar
                            por dtrefere (Carlos)

               23/02/2015 - Alterado PAC para PA (Lucas R. #245838 )

               11/03/2015 - Conversao de Progress -->> Oracle (Lucas R. #245838)

               20/06/2017 - Dispara procedure para gerar LOG pc_gera_log 
                            Setado modulo
                            Padrão de mensagens 
                            Incluido parametro de entrada com a indica a etapa de execução da tela de chamada:
                            Executa o relatório apenas no 2o momento
                            ( Belli - Envolti - 20/06/2017 - Chamado 660322)

  ............................................................................. */
  BEGIN
    DECLARE

      -- DECLARAÇÃO DE VARIAVEIS

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variável de crítica log - 20/06/2017 - Chamado 660322 
      vr_dscritic_out     VARCHAR2  (10000);
     
      -- Variaveis de posicionamento de modulo - 20/06/2017 - Chamado 660322
      vr_acao             VARCHAR2   (100); 

      --Variaveis de indices
      vr_index PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis do programa
      vr_vlcredit NUMBER;
      vr_vldebito NUMBER;
      vr_vlrsaldo NUMBER;

      -- CLOB xml
      vr_des_xml      CLOB;

      -- Tabela de erros
      vr_tab_erro   GENE0001.typ_tab_erro;
      vr_tab_crapbcx typ_tab_crapbcx;

      -- CURSORES
      -- Contem os dados referente o boletim dos caixas
      CURSOR cr_crapbcx(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_dtrefere IN crapdat.dtmvtolt%TYPE,
                        pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT bcx.nrdcaixa,
             bcx.cdagenci,
             bcx.vldsdini,
             bcx.vldsdfin,
             bcx.cdsitbcx,
             bcx.cdopecxa,
             bcx.progress_recid,
             ROWID
        FROM crapbcx bcx
       WHERE bcx.cdcooper = pr_cdcooper
         AND bcx.dtmvtolt = pr_dtrefere
         AND ((bcx.cdagenci = pr_cdagenci AND pr_cdagenci > 0)
          OR (bcx.cdagenci > 0 AND pr_cdagenci = 0))
          ORDER BY bcx.cdagenci
                  ,bcx.nrdcaixa;
      rw_crapbcx cr_crapbcx%ROWTYPE;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS

      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
      vr_acao := 'CAIX0001.pc_saldo_caixas';      
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => vr_acao);

      -- Limpar temp-table
      vr_tab_crapbcx.DELETE;

      vr_vlrsaldo := 0;
      -- Leitura da tabela de boletim de caixa
      FOR rw_crapbcx IN cr_crapbcx (pr_cdcooper => pr_cdcooper
                                   ,pr_dtrefere => pr_dtrefere
                                   ,pr_cdagenci => nvl(pr_cdagenci,0)) LOOP

        --Buscar Proximo indice para o boletim de caixa
        vr_index:= vr_tab_crapbcx.COUNT + 1;

        vr_tab_crapbcx(vr_index).cdagenci := rw_crapbcx.cdagenci;
        vr_tab_crapbcx(vr_index).nrdcaixa := rw_crapbcx.nrdcaixa;
         vr_tab_crapbcx(vr_index).tpcaicof := 'CAIXA';

        -- Aberto
        IF rw_crapbcx.cdsitbcx = 1 THEN

          -- Aberto Hoje
          vr_tab_crapbcx(vr_index).csituaca := 'ABERTO';

          -- Buscar boletim de caixa
          caix0001.pc_disp_dados_bole_caixa(pr_cdcooper => pr_cdcooper
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_cdagenci => pr_cdagenci
                                            ,pr_nrdcaixa => pr_nrdcaixa
                                            ,pr_rowid    => rw_crapbcx.rowid
                                            ,pr_nmarquiv => ' '
                                            ,pr_flgimpre => 0 -- NO/false
                                            ,pr_cdprogra => pr_cdprogra
                                            ,pr_tab_erro => vr_tab_erro
                                            ,pr_vlcredit => vr_vlcredit
                                            ,pr_vldebito => vr_vldebito);

          --Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
      
            vr_cdcritic:= vr_tab_erro(1).cdcritic;
            vr_dscritic:= vr_tab_erro(1).dscritic;
            RAISE vr_exc_saida;
          END IF;

          vr_tab_crapbcx(vr_index).vldsdtot := nvl(rw_crapbcx.vldsdini,0) + nvl(vr_vlcredit,0) -
                                               nvl(vr_vldebito,0);
          vr_vlrsaldo := vr_vlrsaldo + vr_tab_crapbcx(vr_index).vldsdtot;
        ELSIF rw_crapbcx.cdsitbcx = 2  THEN -- Fechados

          vr_tab_crapbcx(vr_index).csituaca := 'FECHADO';
          vr_tab_crapbcx(vr_index).vldsdtot := nvl(rw_crapbcx.vldsdfin,0);
          vr_vlrsaldo := vr_vlrsaldo + vr_tab_crapbcx(vr_index).vldsdtot;
        END IF;

        -- Se saldo for zerado limpa registro da temp-table
        IF vr_tab_crapbcx(vr_index).vldsdtot = 0 THEN
          vr_tab_crapbcx.DELETE(vr_index);
          CONTINUE;
        END IF;

        -- Busca do operador do caixa
        OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => rw_crapbcx.cdopecxa);
        FETCH cr_crapope INTO rw_crapope;

        IF cr_crapope%NOTFOUND THEN
          -- Fechar cursor
          CLOSE cr_crapope;
        ELSE
          -- Fechar cursor
          CLOSE cr_crapope;
          -- Armazenar nome do operador
          vr_tab_crapbcx(vr_index).nmoperad := SubStr(rw_crapope.nmoperad,1,30);
        END IF;
      END LOOP;
      -- Saldo total do caixa
      pr_saldotot := nvl(vr_vlrsaldo,0);
      -- Se não criou registros na temp-table gera critica e levanta exceção

      IF vr_tab_crapbcx.COUNT = 0 THEN
        vr_dscritic := 'Nao ha caixas com saldo para o PA informado.';
        vr_dscritic_padrao := null;
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root>');

      -- Buscar registros da temp-table
      FOR idx IN 1..vr_tab_crapbcx.Count LOOP
        pc_escreve_xml(
                     '<agencia cdagenci="' || to_char(nvl(vr_tab_crapbcx(idx).cdagenci,0)) || '">'||
                       '<cdcooper>' || to_char(pr_cdcooper) ||
                       '</cdcooper>' ||
                       '<cdagenci>' || to_char(nvl(vr_tab_crapbcx(idx).cdagenci,0)) ||
                       '</cdagenci>' ||
                       '<nrdcaixa>' || to_char(nvl(vr_tab_crapbcx(idx).nrdcaixa,0)) ||
                       '</nrdcaixa>' ||
                       '<nmoperad>' || to_char(vr_tab_crapbcx(idx).nmoperad) ||
                       '</nmoperad>' ||
                       '<vldsdtot>' || to_char(nvl(vr_tab_crapbcx(idx).vldsdtot,0),'fm999G999G990D00') ||
                       '</vldsdtot>' ||
                       '<csituaca>' || to_char(vr_tab_crapbcx(idx).csituaca) ||
                       '</csituaca>' ||
                       '<totcacof>' || to_char(nvl(vr_tab_crapbcx(idx).totcacof,0),'fm999G999G990D00') ||
                       '</totcacof>' ||
                       '<vltotcai>' || to_char(nvl(vr_tab_crapbcx(idx).vltotcai,0),'fm999G999G990D00') ||
                       '</vltotcai>' ||
                       '<vltotcof>' || to_char(nvl(vr_tab_crapbcx(idx).vltotcof,0),'fm999G999G990D00') ||
                       '</vltotcof>' ||
                       '<saldotot>' || to_char(nvl(pr_saldotot,0),'fm999G999G990D00') ||
                       '</saldotot>' ||
                     '</agencia>'  );
      END LOOP;
      -- Fim da tag conteudo
      pc_escreve_xml('</root>');

      -- Gravar xml para retorno
      pr_clobxmlc := vr_des_xml;

      -- Finaliza o XML
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Incluido novo parametro na chamada - Chamado 660322 - 23/06/2017
      -- Incluido parametro de entrada com a indica a etapa de execução da tela de chamada - Chamado 660322 - 26/06/2017
      -- Executa o relatório apenas no 2o momento
      -- Gerar relatorio de cofre
      pc_gera_relato(pr_cdcooper => pr_cdcooper,
                     pr_cdagenci => pr_cdagenci,
                     pr_nrdcaixa => pr_nrdcaixa,
                     pr_dtmvtolt => pr_dtmvtolt,
                     pr_tpcaicof => 'CAIXA',
                     pr_saldotot => pr_saldotot,
                     pr_cdprogra => pr_cdprogra,
                     pr_inetapa  => pr_inetapa,
                     pr_tab_crapbcx => vr_tab_crapbcx,
                     pr_nmarqimp => vr_nmarqimp,
                     pr_dscritic => vr_dscritic);

        -- Se possuir critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      -- Gravar nome do arquivo de impressão
      pr_nmarqimp := vr_nmarqimp;

    EXCEPTION
      -- Rotina de geracao de erro
      WHEN vr_exc_saida THEN
        CAIX0001.pc_gera_log(pr_cdcooper
                            ,pr_cdprogra
                            ,vr_acao
                            ,pr_cdagenci
                            ,pr_nrdcaixa
                            ,pr_dtmvtolt
                            ,'CAIXA'
                            ,vr_dscritic
                            ,vr_dscritic_out
                            );
                                             
        if vr_dscritic_padrao is null then
        -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        else
          -- mensagem que vai para o usuario - 20/06/2017 - Chamado 660322 
          pr_dscritic := vr_dscritic_padrao;          
        end if;                
            
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        pr_dscritic := 'Erro na consulta dos boletins de caixa CAIX0001.pc_saldo_caixas: ' || SQLERRM;
        CAIX0001.pc_gera_log ( 
              pr_cdcooper
             ,pr_cdprogra
             ,vr_acao
             ,pr_cdagenci
             ,pr_nrdcaixa
             ,pr_dtmvtolt
             ,'CAIXA'
             ,pr_dscritic
             ,vr_dscritic_out
            );
         pr_dscritic := vr_dscritic_padrao;
    END;

  END pc_saldo_caixas;

  PROCEDURE pc_saldo_cofre(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                 -- Caixa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                          ,pr_cdprogra IN VARCHAR2                -- Programa
                          ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                          ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                          ,pr_saldotot OUT NUMBER                 -- Saldo Total
                          ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                          ,pr_clobxmlc OUT CLOB) IS               -- Registros da crapbcx
                                                  
  /* .............................................................................

   Programa: pc_saldo_cofre                 Antigo: b1wgen0120.p --> BuscaDados - Opção "T"
   Sistema : CRED
   Sigla   : CAIX0001
   Autor   : Lucas Eduardo Ranghetti
   Data    : Março/2015.                        Ultima atualizacao: 20/06/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Consultar saldo atual em Cofre.

   Alteracoes:
              20/06/2017 - Dispara procedure para gerar LOG pc_gera_log 
                           Setado modulo
                           Padrão de mensagens 
                           Incluido parametro de entrada com o nome do programa na procedure pc_saldo_cofre 
                           Incluido parametro de entrada com a indica a etapa de execução da tela de chamada:
                           Executa o relatório apenas no 2o momento
                           ( Belli - Envolti - 20/06/2017 - Chamado 660322)

  ............................................................................. */
  BEGIN
    DECLARE

    -- Variável de críticas
      vr_dscritic VARCHAR2(10000);

      -- Variável de crítica log - 20/06/2017 - Chamado 660322 
      vr_dscritic_out     VARCHAR2  (10000);
     
      -- Variaveis de posicionamento de modulo - 20/06/2017 - Chamado 660322
      vr_acao             VARCHAR2   (100); 

      --Variaveis de indices
      vr_index PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- CLOB xml
      vr_des_xml      CLOB;

      vr_tab_crapbcx typ_tab_crapbcx;

      -- CURSORES
      -- Tabela dos saldos em cofre dos PAs
      CURSOR cr_crapslc(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
       SELECT slc.cdagenci
             ,slc.vlrsaldo
             ,slc.cdcooper
        FROM crapslc slc
       WHERE slc.cdcooper = pr_cdcooper
         AND ((slc.cdagenci = pr_cdagenci
         AND pr_cdagenci > 0)
         OR (slc.cdagenci > 0
         AND pr_cdagenci = 0))
         AND slc.nrdcofre = 1
        ORDER BY slc.cdcooper,
                 slc.cdagenci;
      rw_crapslc cr_crapslc%ROWTYPE;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS

      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
      vr_acao := 'CAIX0001.pc_saldo_cofre';      
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => vr_acao);
      
      -- Limpar temp-table
      vr_tab_crapbcx.DELETE;

      pr_saldotot := 0;

      -- Buscar saldo de cofres
      OPEN cr_crapslc(pr_cdcooper => pr_cdcooper
                     ,pr_cdagenci => nvl(pr_cdagenci,0));
      LOOP
        FETCH cr_crapslc INTO rw_crapslc;
        EXIT WHEN cr_crapslc%NOTFOUND;

        -- acumular valores em cofre
        pr_saldotot := pr_saldotot + rw_crapslc.vlrsaldo;

        --Buscar Proximo indice
        vr_index:= vr_tab_crapbcx.COUNT + 1;

        vr_tab_crapbcx(vr_index).cdagenci := rw_crapslc.cdagenci;
         vr_tab_crapbcx(vr_index).vldsdtot := nvl(rw_crapslc.vlrsaldo,0);
        vr_tab_crapbcx(vr_index).tpcaicof := 'COFRE';

      END LOOP; -- Fim do loop rw_crapslc
      -- Se não criou registros na temp-table gera critica e levanta exceção
      IF vr_tab_crapbcx.COUNT = 0 THEN
        vr_dscritic := 'Nao ha saldo em cofre para o PA informado.';
        vr_dscritic_padrao := null;
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root>');

      -- Buscar registros da temp-table
      FOR idx IN 1..vr_tab_crapbcx.Count LOOP
        pc_escreve_xml(
                     '<agencia>'||
                       '<cdagenci>' || to_char(nvl(vr_tab_crapbcx(idx).cdagenci,0)) ||
                       '</cdagenci>' ||
                       '<vldsdtot>' || to_char(nvl(vr_tab_crapbcx(idx).vldsdtot,0),'fm999G999G990D00') ||
                       '</vldsdtot>' ||
                     '</agencia>'  );
      END LOOP;
      -- Fim da tag conteudo
      pc_escreve_xml('</root>');

      -- Gravar xml para retorno
      pr_clobxmlc := vr_des_xml;

      -- Finaliza o XML
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);


      -- Incluido novo parametro na chamada - Chamado 660322 - 23/06/2017
      -- Incluido parametro de entrada com a indica a etapa de execução da tela de chamada - Chamado 660322 - 26/06/2017
      -- Executa o relatório apenas no 2o momento
      -- Gerar relatorio de caixa
      pc_gera_relato(pr_cdcooper => pr_cdcooper,
                     pr_cdagenci => pr_cdagenci,
                     pr_nrdcaixa => pr_nrdcaixa,
                     pr_dtmvtolt => pr_dtmvtolt,
                     pr_tpcaicof => 'COFRE',
                     pr_saldotot => pr_saldotot,
                     pr_cdprogra => pr_cdprogra,
                     pr_inetapa  => pr_inetapa,
                     pr_tab_crapbcx => vr_tab_crapbcx,
                     pr_nmarqimp => vr_nmarqimp,
                     pr_dscritic => vr_dscritic);

      -- Se possuir critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Gravar nome do arquivo de impressão
      pr_nmarqimp := vr_nmarqimp;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Dispara geração de log - 20/06/2017 - Chamado 660322 
        CAIX0001.pc_gera_log (pr_cdcooper
                             ,pr_cdprogra
                             ,vr_acao
                             ,pr_cdagenci
                             ,pr_nrdcaixa
                             ,pr_dtmvtolt
                             ,'COFRE'
                             ,vr_dscritic
                             ,vr_dscritic_out
                             );
                                             
        if vr_dscritic_padrao is null then
          -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        else
          -- mensagem que vai para o usuario - 20/06/2017 - Chamado 660322 
          pr_dscritic := vr_dscritic_padrao;          
        end if;      
        
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Rotina de geracao de erro
        pr_dscritic := 'Erro na consulta dos saldos em cofre CAIX0001.pc_saldo_cofre: ' || SQLERRM;
                     
        -- Dispara geração de log - 20/06/2017 - Chamado 660322 
        CAIX0001.pc_gera_log (pr_cdcooper
                             ,pr_cdprogra
                             ,vr_acao
                             ,pr_cdagenci
                             ,pr_nrdcaixa
                             ,pr_dtmvtolt
                             ,'COFRE'
                             ,pr_dscritic
                             ,vr_dscritic_out
                             );
                             
          pr_dscritic := vr_dscritic_padrao;
    END;

  END pc_saldo_cofre;

  PROCEDURE pc_saldo_total(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                 -- Caixa
                          ,pr_dtrefere IN DATE                    -- Data Referencia
                          ,pr_cdoperad IN crapope.cdoperad%TYPE   -- Operador
                          ,pr_cdprogra IN VARCHAR2                -- Programa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                          ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                          ,pr_nmarqimp OUT VARCHAR2               -- Arquivo Impressao
                          ,pr_saldotot OUT NUMBER                 -- Saldo Total
                          ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao da critica
                          ,pr_clobxmlc OUT CLOB) IS               -- Registros da crapbcx
/* .............................................................................

   Programa: pc_saldo_total
   Sistema : CRED
   Sigla   : CAIX0001
   Autor   : Lucas Eduardo Ranghetti
   Data    : Março/2015.                        Ultima atualizacao: 20/06/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Consultar saldo atual em Cofre e em Caixa.

   Alteracoes:
               20/06/2017 - Dispara procedure para gerar LOG pc_gera_log 
                            Setado modulo
                            Padrão de mensagens 
                            Incluido parametro de entrada com a indica a etapa de execução da tela de chamada
                            Executa o relatório apenas no 2o momento
                           ( Belli - Envolti - 20/06/2017 - Chamado 660322)

  ............................................................................. */
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_dscritic VARCHAR2(10000);

      -- Variável de crítica log - 20/06/2017 - Chamado 660322 
      vr_dscritic_out     VARCHAR2  (10000);
     
      -- Variaveis de posicionamento de modulo - 20/06/2017 - Chamado 660322
      vr_acao             VARCHAR2   (100); 

      --Variaveis de indices
      vr_index VARCHAR2(5);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis do programa
      vr_vlcredit NUMBER;
      vr_vldebito NUMBER;
      vr_vltotcai NUMBER;
      vr_vltotcof NUMBER;
      vr_totcaipa NUMBER;
      vr_vltaaint NUMBER;
      vr_nmarqimp VARCHAR2(100);

      -- Tabela de erros
      vr_tab_erro   GENE0001.typ_tab_erro;
      -- CLOB xml
      vr_des_xml      CLOB;
      -- Tabela temporaria
      vr_tab_crapbcx typ_tab_crapbcx;

      -- Contem os dados referente o boletim dos caixas
      CURSOR cr_crapbcx(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_dtrefere IN crapdat.dtmvtolt%TYPE,
                        pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT bcx.nrdcaixa
            ,bcx.cdagenci
            ,bcx.vldsdini
            ,bcx.vldsdfin
            ,bcx.cdsitbcx
            ,bcx.cdopecxa
            ,bcx.progress_recid
            ,bcx.rowid
            ,row_number() OVER(PARTITION BY bcx.cdagenci ORDER BY bcx.cdagenci, slc.cdagenci) current_of
            ,COUNT(1) OVER(PARTITION BY bcx.cdagenci) last_of
            ,slc.cdcooper
            ,slc.vlrsaldo
        FROM crapbcx bcx
            ,crapslc slc
       WHERE bcx.cdcooper = pr_cdcooper
         AND bcx.dtmvtolt = pr_dtrefere
         AND ((bcx.cdagenci = pr_cdagenci
         AND pr_cdagenci > 0)
          OR (bcx.cdagenci > 0
         AND pr_cdagenci = 0))
         AND slc.cdcooper = bcx.cdcooper
         AND slc.cdagenci = bcx.cdagenci
         AND slc.nrdcofre = 1
          ORDER BY bcx.cdagenci
                  ,slc.cdagenci
                  ,bcx.nrdcaixa;
      rw_crapbcx cr_crapbcx%ROWTYPE;

      -- Contem os dados referente o boletim dos caixas Internet e TAA
      CURSOR cr_crapbcx_II(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_dtrefere IN crapdat.dtmvtolt%TYPE) IS
      SELECT bcx.nrdcaixa,
             bcx.cdagenci,
             bcx.vldsdini,
             bcx.vldsdfin,
             bcx.cdsitbcx,
             bcx.cdopecxa,
             bcx.progress_recid,
             ROWID
        FROM crapbcx bcx
       WHERE bcx.cdcooper = pr_cdcooper
         AND bcx.dtmvtolt = pr_dtrefere
         AND ((bcx.cdagenci IN(90,91) AND pr_cdagenci = 0)
          OR (bcx.cdagenci = pr_cdagenci AND pr_cdagenci IN(90,91)) )
          ORDER BY bcx.cdagenci
                  ,bcx.nrdcaixa;
      rw_crapbcx_II cr_crapbcx_II%ROWTYPE;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS

      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
      vr_acao := 'CAIX0001.pc_saldo_total';      
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => vr_acao);
      
      -- Limpar temp-table
      vr_tab_crapbcx.DELETE;

      -- Iniciar variavel zerada
      vr_vltotcai := 0;
      vr_vltotcof := 0;
      vr_totcaipa := 0;
      vr_vltaaint := 0;

      -- Buscar valores de caixa
      -- Leitura da tabela de boletim de caixa
      FOR rw_crapbcx IN cr_crapbcx(pr_cdcooper => pr_cdcooper
                                   ,pr_dtrefere => pr_dtrefere
                                   ,pr_cdagenci => nvl(pr_cdagenci,0)) LOOP

        -- Aberto
        IF rw_crapbcx.cdsitbcx = 1 THEN

          -- Buscar boletim de caixa
          pc_disp_dados_bole_caixa(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_rowid    => rw_crapbcx.rowid
                                  ,pr_nmarquiv => ' '
                                  ,pr_flgimpre => 0 -- NO/false
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_vlcredit => vr_vlcredit
                                  ,pr_vldebito => vr_vldebito);

          -- Se possuir erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_dscritic:= vr_tab_erro(1).dscritic;
            RAISE vr_exc_saida;
          END IF;

          vr_vltotcai := vr_vltotcai + nvl(rw_crapbcx.vldsdini,0) +
                         nvl(vr_vlcredit,0) - nvl(vr_vldebito,0);
          -- Total por pa
          vr_totcaipa := vr_totcaipa + nvl(rw_crapbcx.vldsdini,0) +
                         nvl(vr_vlcredit,0) - nvl(vr_vldebito,0);

        ELSIF rw_crapbcx.cdsitbcx = 2  THEN -- Fechados

          vr_vltotcai := vr_vltotcai + nvl(rw_crapbcx.vldsdfin,0);
          -- Total por pa
          vr_totcaipa := vr_totcaipa + nvl(rw_crapbcx.vldsdfin,0);

        END IF;

        -- Se for o ultimo PA do loop
        IF rw_crapbcx.current_of = rw_crapbcx.last_of THEN
          --Buscar Proximo indice para o boletim de caixa
          vr_index:= to_char(LPAD(rw_crapbcx.cdagenci,5,0));
          vr_tab_crapbcx(vr_index).cdagenci := rw_crapbcx.cdagenci;
          vr_tab_crapbcx(vr_index).tpcaicof := 'TOTAL';
          vr_tab_crapbcx(vr_index).vltotcai := vr_totcaipa;

          vr_vltotcof := vr_vltotcof + rw_crapbcx.vlrsaldo;

          vr_tab_crapbcx(vr_index).vltotcof := rw_crapbcx.vlrsaldo;

            vr_tab_crapbcx(vr_index).totcacof := vr_totcaipa + rw_crapbcx.vlrsaldo;
          vr_totcaipa := 0;
        END IF;

      END LOOP;  -- Fim do loop rw_crapbcx

     vr_totcaipa := 0;
      -- Buscar valores de TAA e Internet
      FOR rw_crapbcx_II IN cr_crapbcx_II(pr_cdcooper => pr_cdcooper
                                        ,pr_dtrefere => pr_dtrefere) LOOP

        -- Aberto
        IF rw_crapbcx_II.cdsitbcx = 1 THEN

          -- Buscar boletim de caixa
          pc_disp_dados_bole_caixa(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_rowid    => rw_crapbcx_II.rowid
                                  ,pr_nmarquiv => ' '
                                  ,pr_flgimpre => 0 -- NO/false
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_vlcredit => vr_vlcredit
                                  ,pr_vldebito => vr_vldebito);

          -- Se possuir erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_dscritic:= vr_tab_erro(1).dscritic;
            RAISE vr_exc_saida;
          END IF;

          vr_vltaaint := vr_vltaaint + nvl(rw_crapbcx_II.vldsdini,0) +
                         nvl(vr_vlcredit,0) - nvl(vr_vldebito,0);
          -- Total por pa
          vr_totcaipa := vr_totcaipa + nvl(rw_crapbcx_II.vldsdini,0) +
                         nvl(vr_vlcredit,0) - nvl(vr_vldebito,0);

        ELSIF rw_crapbcx_II.cdsitbcx = 2  THEN -- Fechados

          vr_vltaaint := vr_vltaaint + nvl(rw_crapbcx_II.vldsdfin,0);
          -- Total por pa
          vr_totcaipa := vr_totcaipa + nvl(rw_crapbcx_II.vldsdfin,0);

        END IF;

        --Buscar Proximo indice para o boletim de caixa
        vr_index:= to_char(LPAD(rw_crapbcx_II.cdagenci,5,0));
        vr_tab_crapbcx(vr_index).cdagenci := rw_crapbcx_II.cdagenci;
        vr_tab_crapbcx(vr_index).tpcaicof := 'TOTAL';
        vr_tab_crapbcx(vr_index).vltotcai := vr_totcaipa;
        vr_tab_crapbcx(vr_index).totcacof := vr_totcaipa;

        vr_totcaipa := 0;

      END LOOP;  -- Fim do loop rw_crapbcx_II

      -- saldo total caixa + cofre + Internet e TAA
      pr_saldotot := nvl(vr_vltotcai,0) + nvl(vr_vltotcof,0) + nvl(vr_vltaaint,0);

      -- Se não criou registros na temp-table gera critica e levanta exceção
      IF vr_tab_crapbcx.COUNT = 0 THEN
        vr_dscritic := 'Nao ha caixas/cofres com saldo para o PA informado.';
        vr_dscritic_padrao := null;
        RAISE vr_exc_saida;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root>');

      -- Buscar primeiro registro da tabela
      vr_index:= vr_tab_crapbcx.FIRST;
      WHILE vr_index IS NOT NULL LOOP

        pc_escreve_xml(
                     '<agencia cdagenci="' || to_char(nvl(vr_tab_crapbcx(vr_index).cdagenci,0)) || '">'||
                       '<cdagenci>' || to_char(nvl(vr_tab_crapbcx(vr_index).cdagenci,0)) ||
                       '</cdagenci>' ||
                       '<totcacof>' || to_char(nvl(vr_tab_crapbcx(vr_index).totcacof,0),'fm999G999G990D00') ||
                       '</totcacof>' ||
                       '<vltotcai>' || to_char(nvl(vr_tab_crapbcx(vr_index).vltotcai,0),'fm999G999G990D00') ||
                       '</vltotcai>' ||
                       '<vltotcof>' || to_char(nvl(vr_tab_crapbcx(vr_index).vltotcof,0),'fm999G999G990D00') ||
                       '</vltotcof>' ||
                     '</agencia>'  );
        -- Proximo registro
        vr_index:= vr_tab_crapbcx.NEXT(vr_index);
      END LOOP;
      -- Fim da tag conteudo
      pc_escreve_xml('</root>');

      -- Gravar xml para retorno
      pr_clobxmlc := vr_des_xml;

      -- Finaliza o XML
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Incluido novo parametro na chamada - Chamado 660322 - 23/06/2017
      -- Incluido parametro de entrada com a indica a etapa de execução da tela de chamada - Chamado 660322 - 26/06/2017
      -- Executa o relatório apenas no 2o momento
      -- Gerar relatorio de caixa
      pc_gera_relato(pr_cdcooper => pr_cdcooper,
                     pr_cdagenci => pr_cdagenci,
                     pr_nrdcaixa => pr_nrdcaixa,
                     pr_dtmvtolt => pr_dtmvtolt,
                     pr_tpcaicof => 'TOTAL',
                     pr_saldotot => pr_saldotot,
                     pr_cdprogra => pr_cdprogra,
                     pr_inetapa  => pr_inetapa,
                     pr_tab_crapbcx => vr_tab_crapbcx,
                     pr_nmarqimp => vr_nmarqimp,
                     pr_dscritic => vr_dscritic);

      -- Se possuir critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Gravar nome do arquivo de impressão
      pr_nmarqimp := vr_nmarqimp;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Dispara geração de log - 20/06/2017 - Chamado 660322 
        CAIX0001.pc_gera_log ( 
              pr_cdcooper
             ,pr_cdprogra
             ,vr_acao
             ,pr_cdagenci
             ,pr_nrdcaixa
             ,pr_dtmvtolt
             ,'TOTAL'
             ,vr_dscritic
             ,vr_dscritic_out
            );
                                             
        if vr_dscritic_padrao is null then
          -- Monta mensagem de erro
        pr_dscritic := vr_dscritic;
        else
          -- mensagem que vai para o usuario - 20/06/2017 - Chamado 660322 
          pr_dscritic := vr_dscritic_padrao;          
        end if;      
            
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Rotina de geracao de erro
        pr_dscritic := 'Erro na consulta dos saldos em cofre/caixa CAIX0001.pc_saldo_total: ' || SQLERRM;
                     
        -- Dispara geração de log - 20/06/2017 - Chamado 660322 
        CAIX0001.pc_gera_log ( 
              pr_cdcooper
             ,pr_cdprogra
             ,vr_acao
             ,pr_cdagenci
             ,pr_nrdcaixa
             ,pr_dtmvtolt
             ,'TOTAL'
             ,pr_dscritic
             ,vr_dscritic_out
            );
            
        -- mensgaem que vai para o usuario - 20/06/2017 - Chamado 660322
        pr_dscritic := vr_dscritic_padrao;
    END;

  END pc_saldo_total;

  PROCEDURE pc_disp_dados_bole_caixa(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Agencia/PA
                                    ,pr_nrdcaixa IN INTEGER               --> Caixa
                                    ,pr_rowid    IN ROWID
                                    ,pr_nmarquiv IN VARCHAR2               --> Arquivo Impressao
                                    ,pr_flgimpre IN INTEGER                --> Impressao Sim=1/Nao=0
                                    ,pr_cdprogra IN VARCHAR2               --> Programa
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Com erros
                                    ,pr_vlcredit OUT NUMBER                --> Valor Credito
                                    ,pr_vldebito OUT NUMBER) IS            --> Valor Debito
/*--------------------------------------------------------------------

    Programa: pc_disp_dados_bole_caixa               Antigo: b2crap13.p - disponibiliza-dados-boletim-caixa
    Sistema : CRED
    Sigla   : CAIX0001
    Autor   : Lucas Eduardo Ranghetti
    Data    : Fevereiro/2015.                        Ultima atualizacao: 20/06/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamada.
    Objetivo  : Consultar dados do boletim dos caixas.

    Ultima Atualizacao: 04/11/2015

    Alteracoes: 02/03/2006 - Unificacao dos bancos - SQLWorks - Eder

                13/12/2006 - Considerar tplotmov = 32 e historico 561 (Evandro)

                10/05/2007 - Impressao do Coban para a Creditextil (Magui).

                29/08/2007 - Histor 561 nao somava no total de creditos(Magui).

                04/03/2008 - Incluidos lancamentos INSS-BANCOOB (Evandro).

                31/03/2008 - Incluidos lancamentos guias GPS-BANCOOB (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).

                16/02/2009 - Alteracao cdempres (Diego).

                05/06/2009 - Incluir cdagenci na leitura do craplcs (Magui).

                15/07/2009 - Alteracao CDOPERAD (Diego).

                23/11/2009 - Alteracao Codigo Historico (Kbase).

                20/10/2010 - Incluido caminho completo nas referencias do
                             diretorio spool (Elton).

                23/05/2011 - Alterada a leitura da tabela craptab para a
                             tabela crapope (Isara - RKAM).

                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).

                02/01/2012 - Ocorria erro com str_1 pois dava display com
                             stream fechado(Tiago).

                05/06/2013 - Incluido os valores de juros e multa na
                             contabilizacao de faturas (Elton).

                25/09/2013 - Aumentado o format de aux_qtrttctb, de "z,zz9"
                             para "zz,zz9" (Carlos).

                08/01/2014 - Critica de busca de crapage alterada de 15
                             para 962 (Carlos)

                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

                04/11/2015 - Alteração da pesquisa de GPS INSS(LGP)  (Guilherme/SUPERO)

                26/11/2015 - Correção do cálculo da fita de caixa  (Guilherme/SUPERO)
  
                20/06/2017 - Setado modulo  ( Belli - Envolti - 20/06/2017 - Chamado 660322)
                
 ------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- Variaveis internas
      vr_vlrtotal NUMBER  := 0;
      vr_vllanchq NUMBER  := 0;
      vr_qtlanchq INTEGER := 0;

      vr_flgsemhi INTEGER := 0;
      vr_vlrttdeb NUMBER := 0;
      vr_flgouthi BOOLEAN := FALSE;
      vr_vlrttctb NUMBER  := 0;
      vr_qtrttctb INTEGER := 0;
      vr_qtlanmto INTEGER := 0;
      vr_vllanmto NUMBER := 0;

      vr_vlrttcrd NUMBER := 0;
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de indices
      vr_index_craphis PLS_INTEGER := 0;
      vr_index_empresa PLS_INTEGER := 0;

      -- Tabelas temporarias
      vr_typ_w_craphis typ_tab_craphis;
      vr_typ_w_empresa typ_tab_empresa;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      -- CURSORES INTERNOS

      -- BUSCA DOS DADOS DA COOPERATIVA
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop,
               cop.nmextcop,
               cop.dsdircop,
               cop.cdcooper,
               cop.cdcrdarr,
               cop.cdcrdins
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
      rw_crapcop cr_crapcop%ROWTYPE;

      -- CURSOR GENÉRICO DE CALENDÁRIO
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- CURSOR DOS BOLETINS DE CAIXA
      CURSOR cr_crapbcx(pr_rowid IN ROWID) IS
      SELECT bcx.nrdcaixa,
             bcx.cdagenci,
             bcx.vldsdini,
             bcx.vldsdfin,
             bcx.cdsitbcx,
             bcx.cdopecxa,
             bcx.dtmvtolt,
             bcx.nrdmaqui,
             bcx.nrdlacre,
             bcx.qtautent,
             ROWID
        FROM crapbcx bcx
       WHERE bcx.rowid = pr_rowid;
      rw_crapbcx cr_crapbcx%ROWTYPE;

      -- Buscar agencia/PA
      CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT age.cdcxaage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Buscar historicos
      CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT his.nmestrut
            ,his.cdhistor
            ,his.dshistor
            ,his.tplotmov
            ,his.indebcre
            ,his.indcompl
            ,his.tpctbcxa
            ,his.nrctacrd
            ,his.nrctadeb
            ,his.cdcooper
            ,row_number() OVER(PARTITION BY his.cdcooper ORDER BY his.dshistor) current_of
            ,row_number() OVER(PARTITION BY his.cdcooper ORDER BY his.indebcre, his.dshistor) current_of_indebcre
            ,COUNT(1) OVER(PARTITION BY his.cdcooper) last_of
        FROM craphis his
       WHERE his.cdcooper = pr_cdcooper
         AND (his.tplotmov IN(22,24,25,28,29,30,31,32,33)
          OR (his.tplotmov = 5
         AND his.cdhistor = 92)
          OR (his.tplotmov = 0
         AND his.cdhistor = 1414))
       ORDER BY his.indebcre,
                his.dshistor;
      rw_craphis cr_craphis%ROWTYPE;

      -- Buscar lote
      CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdcaixa IN INTEGER
                       ,pr_cdopecxa IN VARCHAR2
                       ,pr_cdbccxlt IN INTEGER
                       ,pr_tplotmov IN INTEGER) IS
      SELECT lot.nrseqdig
            ,lot.cdagenci
            ,lot.nrdolote
            ,lot.dtmvtolt
            ,lot.cdbccxlt
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdcaixa = pr_nrdcaixa
         AND lot.cdopecxa = pr_cdopecxa
         AND lot.tplotmov = pr_tplotmov;
      rw_craplot cr_craplot%ROWTYPE;

      -- Buscar lancamentos na craplcm
      CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT lcm.nrdocmto
             ,lcm.dtmvtolt
             ,lcm.nrdolote
             ,lcm.cdhistor
             ,lcm.cdagenci
             ,lcm.cdcooper
             ,lcm.vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = pr_cdagenci
         AND lcm.cdbccxlt = pr_cdbccxlt
         AND lcm.nrdolote = pr_nrdolote;
      rw_craplcm cr_craplcm%ROWTYPE;

      -- Verifica se existe historico
      CURSOR cr_craphis_II (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
      SELECT his.nmestrut
            ,his.cdhistor
            ,his.dshistor
            ,his.tplotmov
            ,his.indebcre
       FROM craphis his
      WHERE his.cdcooper = pr_cdcooper
        AND his.cdhistor = pr_cdhistor;
      rw_craphis_II cr_craphis_II%ROWTYPE;

      -- Buscar registros da craplem
      CURSOR cr_craplem (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lem.cdcooper
            ,lem.dtmvtolt
            ,lem.cdagenci
            ,lem.cdbccxlt
            ,lem.nrdolote
       FROM craplem lem
      WHERE lem.cdcooper = pr_cdcooper
        AND lem.dtmvtolt = pr_dtmvtolt
        AND lem.cdagenci = pr_cdagenci
        AND lem.cdbccxlt = pr_cdbccxlt
        AND lem.nrdolote = pr_nrdolote;
      rw_craplem cr_craplem%ROWTYPE;

      -- Buscar registros da tabela crapcbb
      CURSOR cr_crapcbb(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE
                        ,pr_tpdocmto IN crapcbb.tpdocmto%TYPE) IS
      SELECT cbb.valorpag
        FROM crapcbb cbb
       WHERE cbb.cdcooper = pr_cdcooper
         AND cbb.dtmvtolt = pr_dtmvtolt
         AND cbb.cdagenci = pr_cdagenci
         AND cbb.cdbccxlt = pr_cdbccxlt
         AND cbb.nrdolote = pr_nrdolote
         AND cbb.tpdocmto = pr_tpdocmto;
       rw_crapcbb cr_crapcbb%ROWTYPE;

       CURSOR cr_crapcbb_II( pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                            ,pr_cdagenci IN crapage.cdagenci%TYPE
                            ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                            ,pr_nrdolote IN craplot.nrdolote%TYPE
                            ,pr_tpdocmto IN crapcbb.tpdocmto%TYPE) IS
      SELECT cbb.valorpag
        FROM crapcbb cbb
       WHERE cbb.cdcooper = pr_cdcooper
         AND cbb.dtmvtolt = pr_dtmvtolt
         AND cbb.cdagenci = pr_cdagenci
         AND cbb.cdbccxlt = pr_cdbccxlt
         AND cbb.nrdolote = pr_nrdolote
         AND cbb.tpdocmto < pr_tpdocmto
         AND cbb.flgrgatv = 1;
       rw_crapcbb_II cr_crapcbb_II%ROWTYPE;

       -- Buscar Lancamentos dos pagamentos do INSS
       CURSOR cr_craplpi(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT lpi.vllanmto
         FROM craplpi lpi
        WHERE lpi.cdcooper = pr_cdcooper
          AND lpi.dtmvtolt = pr_dtmvtolt
          AND lpi.cdagenci = pr_cdagenci
          AND lpi.cdbccxlt = pr_cdbccxlt
          AND lpi.nrdolote = pr_nrdolote;
       rw_craplpi cr_craplpi%ROWTYPE;

       -- Contem os lancamentos dos funcionarios das empresas que
       -- optaram por transferir o salario para outra instituicao financeira.
       CURSOR cr_craplcs(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_cdagenci IN crapage.cdagenci%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE
                        ,pr_cdhistor IN craplot.cdhistor%TYPE) IS
       SELECT lcs.vllanmto
             ,lcs.nrdconta
             ,lcs.cdcooper
         FROM craplcs lcs,
              crapccs ccs
        WHERE lcs.cdcooper = pr_cdcooper
          AND lcs.dtmvtolt = pr_dtmvtolt
          AND lcs.cdagenci = pr_cdagenci
          AND lcs.cdhistor = pr_cdhistor -- Cta. Sal
          AND lcs.nrdolote = pr_nrdolote
          AND ccs.cdcooper = lcs.cdcooper
          AND ccs.nrdconta = lcs.nrdconta
       ORDER BY ccs.cdempres;
      rw_craplcs cr_craplcs%ROWTYPE;

      -- Contem os lancamentos dos funcionarios das empresas que
       -- optaram por transferir o salario para outra instituicao financeira.
       CURSOR cr_crapccs(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT MAX(ccs.cdempres)
             ,ccs.cdempres
         FROM crapccs ccs
        WHERE ccs.cdcooper = pr_cdcooper
          AND ccs.nrdconta = pr_nrdconta
       GROUP BY ccs.cdempres;
      rw_crapccs cr_crapccs%ROWTYPE;

      -- Buscar Lancamentos das Guias da Previdencia Social
      CURSOR cr_craplgp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lgp.vlrtotal
        FROM craplgp lgp
       WHERE lgp.cdcooper = pr_cdcooper
         AND lgp.dtmvtolt = pr_dtmvtolt
         AND lgp.cdagenci = pr_cdagenci
         AND lgp.cdbccxlt = pr_cdbccxlt
         AND lgp.nrdolote = pr_nrdolote;
      rw_craplgp cr_craplgp%ROWTYPE;
      -- Buscar Lancamentos das Guias da Previdencia Social - NOVO
      CURSOR cr_lgp_gps(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lgp.vlrtotal
        FROM craplgp lgp
       WHERE lgp.cdcooper = pr_cdcooper
         AND lgp.dtmvtolt = pr_dtmvtolt
         AND lgp.cdagenci = pr_cdagenci
         AND lgp.cdbccxlt = pr_cdbccxlt
         AND lgp.nrdolote = pr_nrdolote
         AND lgp.idsicred <> 0   -- GPS pagas pelo novo sistema
         AND lgp.flgativo = 1
         AND lgp.nrseqagp = 0;   --Nao pegar GPS agendada
      rw_lgp_gps cr_lgp_gps%ROWTYPE;

      -- Lancamentos da conta investimento
      CURSOR cr_craplci(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_cdhistor IN craplot.cdhistor%TYPE) IS
      SELECT lci.vllanmto
        FROM craplci lci
       WHERE lci.cdcooper = pr_cdcooper
         AND lci.dtmvtolt = pr_dtmvtolt
         AND lci.cdagenci = pr_cdagenci
         AND lci.cdbccxlt = pr_cdbccxlt
         AND lci.nrdolote = pr_nrdolote
         AND lci.cdhistor = pr_cdhistor;
      rw_craplci cr_craplci%ROWTYPE;

      -- Buscar lote
      CURSOR cr_craplot_II(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_cdagenci IN crapage.cdagenci%TYPE
                          ,pr_nrdcaixa IN INTEGER
                          ,pr_cdopecxa IN VARCHAR2
                          ,pr_tplotmov IN INTEGER) IS
      SELECT lot.nrseqdig
            ,lot.cdagenci
            ,lot.nrdolote
            ,lot.dtmvtolt
            ,lot.cdbccxlt
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt IN(30,31,11)
         AND lot.nrdcaixa = pr_nrdcaixa
         AND lot.cdopecxa = pr_cdopecxa
         AND lot.tplotmov = pr_tplotmov;
      rw_craplot_II cr_craplot_II%ROWTYPE;

      -- Lancamentos de faturas
      CURSOR cr_craplft(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT lft.vllanmto
             ,lft.vlrmulta
             ,lft.vlrjuros
             ,lft.cdhistor
             ,lft.cdcooper
        FROM craplft lft
       WHERE lft.cdcooper = pr_cdcooper
         AND lft.dtmvtolt = pr_dtmvtolt
         AND lft.cdagenci = pr_cdagenci
         AND lft.cdbccxlt = pr_cdbccxlt
         AND lft.nrdolote = pr_nrdolote;
      rw_craplft cr_craplft%ROWTYPE;

      -- Titulos acolhidos
      CURSOR cr_craptit(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_intitcop IN craptit.intitcop%TYPE
                       ,pr_flgtitco IN INTEGER) IS
       SELECT tit.vldpagto
             ,tit.cdcooper
         FROM craptit tit
        WHERE (tit.cdcooper = pr_cdcooper
          AND tit.dtmvtolt = pr_dtmvtolt
          AND tit.cdagenci = pr_cdagenci
          AND tit.cdbccxlt = pr_cdbccxlt
          AND tit.nrdolote = pr_nrdolote
          AND tit.intitcop = pr_intitcop
          AND pr_flgtitco = 1) -- True
          OR (tit.cdcooper = pr_cdcooper
          AND tit.dtmvtolt = pr_dtmvtolt
          AND tit.cdagenci = pr_cdagenci
          AND tit.cdbccxlt = pr_cdbccxlt
          AND tit.nrdolote = pr_nrdolote
          AND pr_flgtitco = 0); -- False
      rw_craptit cr_craptit%ROWTYPE;

      -- Buscar lote
      CURSOR cr_craplot_III(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                           ,pr_cdagenci IN crapage.cdagenci%TYPE
                           ,pr_nrdcaixa IN INTEGER
                           ,pr_cdopecxa IN VARCHAR2) IS
      SELECT lot.nrseqdig
            ,lot.cdagenci
            ,lot.nrdolote
            ,lot.dtmvtolt
            ,lot.cdbccxlt
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt IN(11,500)
         AND lot.nrdcaixa = pr_nrdcaixa
         AND lot.cdopecxa = pr_cdopecxa
         AND lot.tplotmov IN(1,23,29);
      rw_craplot_III cr_craplot_III%ROWTYPE;

    -- Cheques acolhidos para depositos nas contas dos associados
    CURSOR cr_crapchd(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_cdagenci IN crapage.cdagenci%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
     SELECT chd.vlcheque
           ,chd.cdbccxlt
       FROM crapchd chd
      WHERE chd.cdcooper = pr_cdcooper
        AND chd.dtmvtolt = pr_dtmvtolt
        AND chd.cdagenci = pr_cdagenci
        AND chd.cdbccxlt = pr_cdbccxlt
        AND chd.nrdolote = pr_nrdolote
        AND chd.inchqcop = 0;
      rw_crapchd cr_crapchd%ROWTYPE;

      -- buscar os lancamentos extra-sistema que compoem o boletim de caixa
      CURSOR cr_craplcx(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdcaixa IN INTEGER
                       ,pr_cdopecxa IN VARCHAR2) IS
        SELECT lcx.cdhistor
              ,lcx.vldocmto
              ,lcx.dsdcompl
              ,lcx.cdcooper
         FROM craplcx lcx
        WHERE lcx.cdcooper = pr_cdcooper
          AND lcx.dtmvtolt = pr_dtmvtolt
          AND lcx.cdagenci = pr_cdagenci
          AND lcx.nrdcaixa = pr_nrdcaixa
          AND UPPER(lcx.cdopecxa) = UPPER(pr_cdopecxa);
        rw_craplcx cr_craplcx%ROWTYPE;

      -- buscar tranferencia de valores (DOC C, DOC D E TEDS)
      CURSOR cr_craptvl(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
       SELECT tvl.vldocrcb
         FROM craptvl tvl
        WHERE tvl.cdcooper = pr_cdcooper
          AND tvl.dtmvtolt = pr_dtmvtolt
          AND tvl.cdagenci = pr_cdagenci
          AND tvl.cdbccxlt = pr_cdbccxlt
          AND tvl.nrdolote = pr_nrdolote;
        rw_craptvl cr_craptvl%ROWTYPE;

    BEGIN
      
	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'CAIX0001.pc_disp_dados_bole_caixa');

      -- Iniciar Valores zerados
      pr_vlcredit := 0;
      pr_vldebito := 0;

      -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
      OPEN cr_crapcop;
      FETCH cr_crapcop
        INTO rw_crapcop;
      -- SE NÃO ENCONTRAR
      IF cr_crapcop%NOTFOUND THEN
        -- FECHAR O CURSOR POIS HAVERÁ RAISE
        CLOSE cr_crapcop;
        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE cr_crapcop;
      END IF;

      -- LEITURA DO CALENDÁRIO DA COOPERATIVA
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- SE NÃO ENCONTRAR
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
        CLOSE btch0001.cr_crapdat;
        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Busca dos boletins informados no parametro
      OPEN cr_crapbcx(pr_rowid => pr_rowid);
      FETCH cr_crapbcx INTO rw_crapbcx;

      -- Se não encontrou Boletim
      IF cr_crapbcx%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapbcx;
        vr_cdcritic := 11;
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Fechar Cursor
      CLOSE cr_crapbcx;

      -- Verificar se agencia existe
      OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => rw_crapbcx.cdagenci);
      FETCH cr_crapage INTO rw_crapage;

      -- Se não encontrar gera critica
      IF cr_crapage%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapage;
        vr_cdcritic := 962;
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapage;

      -- Busca do operador do caixa
      OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                       pr_cdoperad => rw_crapbcx.cdopecxa);
      FETCH cr_crapope INTO rw_crapope;

      IF cr_crapope%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapope;
        vr_cdcritic := 67;
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapope;

      vr_nmarqimp := pr_nmarquiv;  -- Gravar nome do arquivo em variavel
      vr_flgsemhi := 0; -- FALSE
      vr_vlrttcrd := 0; -- Crédito
      vr_vlrttdeb := 0; -- Débito

      -- Buscar historicos
      FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP

        -- Iniciar variaveis
        vr_flgouthi := FALSE;

        IF UPPER(rw_craphis.nmestrut) = UPPER('craplcm') THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 1) LOOP

            -- Verificar situacao utilizando indice craplcm3  - Diego
            FOR rw_craplcm IN cr_craplcm( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                         ,pr_cdagenci => rw_craplot.cdagenci
                                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                         ,pr_nrdolote => rw_craplot.nrdolote) LOOP

              -- Verificar se historico é valido
              OPEN cr_craphis_II(pr_cdcooper => rw_craplcm.cdcooper
                                ,pr_cdhistor => rw_craplcm.cdhistor);
              FETCH cr_craphis_II INTO rw_craphis_II;

              -- Se não for continua rotina
              IF cr_craphis_II%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craphis_II;
                CONTINUE;
              END IF;
              -- Fecha cursor
              CLOSE cr_craphis_II;

              -- Arrecadacoes
              IF rw_craphis.cdhistor <> 717 AND
                rw_craphis_II.indebcre <> rw_craphis.indebcre THEN
                CONTINUE;
              END IF;

              -- Armazenar registros na tabela temporaria
              vr_index_craphis:= vr_typ_w_craphis.COUNT + 1;

              vr_typ_w_craphis(vr_index_craphis).cdhistor := rw_craplcm.cdhistor;

              vr_typ_w_craphis(vr_index_craphis).dshistor := SubStr(rw_craphis_II.dshistor,1,18);
              vr_typ_w_craphis(vr_index_craphis).dsdcompl := ' ';
              vr_typ_w_craphis(vr_index_craphis).qtlanmto := vr_typ_w_craphis(vr_index_craphis).qtlanmto + 1;
              vr_typ_w_craphis(vr_index_craphis).vllanmto := vr_typ_w_craphis(vr_index_craphis).vllanmto +
                                                             nvl(rw_craplcm.vllanmto,0);

              vr_flgouthi := TRUE;
              vr_vlrttctb := vr_vlrttctb + rw_craplcm.vllanmto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Final do loop rw_craplcm
          END LOOP; -- Final do loop rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplem')
          AND rw_craphis.tplotmov <> 5 THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 5) LOOP

            -- Verificar situacao utilizando indice craplem3  - Diego
            FOR rw_craplem IN cr_craplcm( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                         ,pr_cdagenci => rw_craplot.cdagenci
                                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                         ,pr_nrdolote => rw_craplot.nrdolote) LOOP

              -- Verificar se historico é valido
              OPEN cr_craphis_II(pr_cdcooper => rw_craplem.cdcooper
                                ,pr_cdhistor => rw_craplem.cdhistor);
              FETCH cr_craphis_II INTO rw_craphis_II;

              -- Se não for continua rotina
              IF cr_craphis_II%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craphis_II;
                CONTINUE;
              END IF;
              -- Fecha cursor
              CLOSE cr_craphis_II;

              -- Arrecadacoes
              IF rw_craphis.cdhistor <> 717 AND
                rw_craphis_II.indebcre <> rw_craphis.indebcre THEN
                CONTINUE;
              END IF;

              -- Armazenar registros na tabela temporaria
              vr_index_craphis:= vr_typ_w_craphis.COUNT + 1;

              vr_typ_w_craphis(vr_index_craphis).cdhistor := rw_craplem.cdhistor;
              vr_typ_w_craphis(vr_index_craphis).dshistor := SubStr(rw_craphis_II.dshistor,1,18);
              vr_typ_w_craphis(vr_index_craphis).dsdcompl := ' ';
              vr_typ_w_craphis(vr_index_craphis).qtlanmto := vr_typ_w_craphis(vr_index_craphis).qtlanmto + 1;
              vr_typ_w_craphis(vr_index_craphis).vllanmto := vr_typ_w_craphis(vr_index_craphis).vllanmto +
                                                             nvl(rw_craplem.vllanmto,0);

              vr_flgouthi := TRUE;
              vr_vlrttctb := vr_vlrttctb + rw_craplcm.vllanmto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do loop rw_craplem
          END LOOP; -- Final do loop rw_craplot

        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('crapcbb')
          AND rw_craphis.tplotmov  = 31 THEN

          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 31) LOOP

            -- Movimentos Correspondente Bancario - Banco do Brasil
            FOR rw_crapcbb IN cr_crapcbb( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                         ,pr_cdagenci => rw_craplot.cdagenci
                                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                         ,pr_nrdolote => rw_craplot.nrdolote
                                         ,pr_tpdocmto => 3) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_crapcbb.valorpag;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- fim do loop rw_crapcbb
          END LOOP; -- Fim do loop da rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('crapcbb') THEN

          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 28) LOOP

            -- Movimentos Correspondente Bancario - Banco do Brasil
            FOR rw_crapcbb_II IN cr_crapcbb_II( pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                               ,pr_cdagenci => rw_craplot.cdagenci
                                               ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                               ,pr_nrdolote => rw_craplot.nrdolote
                                               ,pr_tpdocmto => 3) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_crapcbb_II.valorpag;
              vr_qtrttctb := vr_qtrttctb + 1;
            END LOOP; -- Fim do loop rw_crapcbb_II
          END LOOP; -- Fim do loop rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplpi') THEN

          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 33) LOOP
            -- Lancamentos dos pagamentos do INSS
            FOR rw_craplpi IN cr_craplpi( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                         ,pr_cdagenci => rw_craplot.cdagenci
                                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                         ,pr_nrdolote => rw_craplot.nrdolote) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craplpi.vllanmto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- fim do loop rw_craplpi
          END LOOP;
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplcs') THEN
          -- Limpar tabela temporaria
          vr_typ_w_empresa.DELETE;
          -- Buscar registros de lote
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 32) LOOP
            -- Contem os lancamentos dos funcionarios das empresas que
            -- optaram por transferir o salario para outra instituicao financeira.
            FOR rw_craplcs IN cr_craplcs(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                        ,pr_cdagenci => rw_crapbcx.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_cdhistor => 561) LOOP
              -- Total da empresa
              vr_qtlanmto := vr_qtlanmto + 1;
              vr_vllanmto := vr_vllanmto + rw_craplcs.vllanmto;

              -- Total de creditos
              vr_vlrttcrd := vr_vlrttcrd + rw_craplcs.vllanmto;

              OPEN cr_crapccs(pr_cdcooper => rw_craplcs.cdcooper
                             ,pr_nrdconta => rw_craplcs.nrdconta);
              FETCH cr_crapccs INTO rw_crapccs;

              IF cr_crapccs%FOUND THEN
                -- Fechar cursor
                CLOSE cr_crapccs;
                -- Gravar informações da empresa na temp-table
                vr_index_empresa := vr_typ_w_empresa.count() + 1;

                vr_typ_w_empresa(vr_index_empresa).cdempres := rw_crapccs.cdempres;
                vr_typ_w_empresa(vr_index_empresa).qtlanmto := nvl(vr_qtlanmto,0);
                vr_typ_w_empresa(vr_index_empresa).qtlanmto := nvl(vr_vllanmto,0);

                vr_qtlanmto := 0;
                vr_vllanmto := 0;
              ELSE
                -- Fechar cursor
                CLOSE cr_crapccs;
              END IF;
            END LOOP; -- Fim do loop rw_craplcs
          END LOOP; -- Fim do loop rw_craplot

        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplgp') THEN
          /* Verifica qual historico deve rodar conforme cadastro da COOP
          Se tem Credenciamento, deve ser historico 582 senao 458 */
          IF (   (rw_crapcop.cdcrdarr  = 0 AND rw_craphis.cdhistor = 458)
              OR (rw_crapcop.cdcrdarr <> 0 AND rw_craphis.cdhistor = 582)) THEN
            -- Buscar lancamentos de lote
            FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                         ,pr_cdagenci => rw_crapbcx.cdagenci
                                         ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                         ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                         ,pr_cdbccxlt => 11
                                         ,pr_tplotmov => 30) LOOP
              -- Lancamentos das Guias da Previdencia Social
              FOR rw_craplgp IN cr_craplgp( pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                           ,pr_cdagenci => rw_craplot.cdagenci
                                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                           ,pr_nrdolote => rw_craplot.nrdolote) LOOP
                vr_vlrttctb := vr_vlrttctb + rw_craplgp.vlrtotal;
                vr_qtrttctb := vr_qtrttctb + 1;
              END LOOP; -- fim do loop rw_craplgp
            END LOOP;
          ELSE
            IF  (rw_crapcop.cdcrdins <> 0 AND rw_craphis.cdhistor = 1414) THEN
              -- Buscar lancamentos de lote - GPS NOVO
              FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                           ,pr_cdagenci => rw_crapbcx.cdagenci
                                           ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                           ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                           ,pr_cdbccxlt => 100
                                           ,pr_tplotmov => 30) LOOP
                -- Lancamentos das Guias da Previdencia Social - GPS NOVO
                FOR rw_lgp_gps IN cr_lgp_gps( pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                             ,pr_cdagenci => rw_craplot.cdagenci
                                             ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                             ,pr_nrdolote => rw_craplot.nrdolote) LOOP

                    vr_vlrttctb := vr_vlrttctb + rw_lgp_gps.vlrtotal;
                    vr_qtrttctb := vr_qtrttctb + 1;

                END LOOP; -- fim do loop rw_lgp_gps
              END LOOP;
            END IF;
          END IF;
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplem') THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 5) LOOP

            -- Verificar situacao utilizando indice craplem3  - Diego
            FOR rw_craplem IN cr_craplcm( pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                         ,pr_cdagenci => rw_craplot.cdagenci
                                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                         ,pr_nrdolote => rw_craplot.nrdolote) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craplem.vllanmto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do rw_craplem
          END LOOP; -- Fim do rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplci') THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 29) LOOP
            -- Lancamentos da conta investimento
            FOR rw_craplci IN cr_craplci(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_cdhistor => rw_craphis.cdhistor) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craplci.vllanmto;
              vr_qtrttctb := vr_qtrttctb + 1;
            END LOOP; -- Fim do rw_craplci
          END LOOP; -- Fim do rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplft') THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot_II IN cr_craplot_II( pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                             ,pr_cdagenci => rw_crapbcx.cdagenci
                                             ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                             ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                             ,pr_tplotmov => 13) LOOP
            -- Lancamentos de faturas
            FOR rw_craplft IN cr_craplft(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot_II.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot_II.cdbccxlt
                                        ,pr_cdagenci => rw_craplot_II.cdagenci
                                        ,pr_nrdolote => rw_craplot_II.nrdolote) LOOP
               -- Soma dos valores
               vr_vlrtotal := nvl(rw_craplft.vllanmto,0) +
                              nvl(rw_craplft.vlrmulta,0) +
                              nvl(rw_craplft.vlrjuros,0);

              -- Verificar se historico é valido
              OPEN cr_craphis_II(pr_cdcooper => rw_craplft.cdcooper
                                ,pr_cdhistor => rw_craplft.cdhistor);
              FETCH cr_craphis_II INTO rw_craphis_II;

              -- Se não for continua rotina
              IF cr_craphis_II%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craphis_II;
                CONTINUE;
              END IF;
              -- Fecha cursor
              CLOSE cr_craphis_II;

              -- Arrecadacoes
              IF rw_craphis.cdhistor <> 717 AND
                rw_craphis_II.indebcre <> rw_craphis.indebcre THEN
                CONTINUE;
              END IF;

              -- Armazenar registros na tabela temporaria
              vr_index_craphis:= vr_typ_w_craphis.COUNT + 1;

              vr_typ_w_craphis(vr_index_craphis).cdhistor := rw_craplft.cdhistor;
              vr_typ_w_craphis(vr_index_craphis).dshistor := SubStr(rw_craphis_II.dshistor,1,18);
              vr_typ_w_craphis(vr_index_craphis).dsdcompl := ' ';
              vr_typ_w_craphis(vr_index_craphis).qtlanmto := vr_typ_w_craphis(vr_index_craphis).qtlanmto + 1;
              vr_typ_w_craphis(vr_index_craphis).vllanmto := vr_typ_w_craphis(vr_index_craphis).vllanmto +
                                                             vr_vlrtotal;

              vr_flgouthi := TRUE;
              vr_vlrttctb := vr_vlrttctb + vr_vlrtotal;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do loop da craplft
          END LOOP; -- Fim do loop rw_craplot_II

          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 21) LOOP
            -- Titulos acolhidos
            FOR rw_craptit IN cr_craptit(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_intitcop => 0 -- não ira buscar com este indice
                                        ,pr_flgtitco => 0) LOOP

              -- Verificar se historico é valido
              OPEN cr_craphis_II(pr_cdcooper => rw_craptit.cdcooper
                                ,pr_cdhistor => 373);
              FETCH cr_craphis_II INTO rw_craphis_II;

              -- Se não for continua rotina
              IF cr_craphis_II%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craphis_II;
                CONTINUE;
              END IF;
              -- Fecha cursor
              CLOSE cr_craphis_II;

              -- Arrecadacoes
              IF rw_craphis.cdhistor <> 717 AND
                rw_craphis_II.indebcre <> rw_craphis.indebcre THEN
                CONTINUE;
              END IF;

              -- Armazenar registros na tabela temporaria
              vr_index_craphis:= vr_typ_w_craphis.COUNT + 1;

              vr_typ_w_craphis(vr_index_craphis).cdhistor := 373;
              vr_typ_w_craphis(vr_index_craphis).dshistor := SubStr(rw_craphis_II.dshistor,1,18);
              vr_typ_w_craphis(vr_index_craphis).dsdcompl := ' ';
              vr_typ_w_craphis(vr_index_craphis).qtlanmto := vr_typ_w_craphis(vr_index_craphis).qtlanmto + 1;
              vr_typ_w_craphis(vr_index_craphis).vllanmto := vr_typ_w_craphis(vr_index_craphis).vllanmto +
                                                             nvl(rw_craptit.vldpagto,0);

              vr_flgouthi := TRUE;
              vr_vlrttctb := vr_vlrttctb + rw_craptit.vldpagto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do loop rw_craptit
          END LOOP; -- Fim do loop rw_craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craptit') AND rw_craphis.cdhistor = 713 THEN

          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 20) LOOP
            -- Titulos acolhidos
            FOR rw_craptit IN cr_craptit(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_intitcop => 0 -- Tit.Outros Bancos
                                        ,pr_flgtitco => 1) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craptit.vldpagto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do loop craptit
          END LOOP; -- Fim do loop craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craptit') AND rw_craphis.cdhistor = 751 THEN -- Titulo Cooperativa
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => 20) LOOP
            -- Titulos acolhidos
            FOR rw_craptit IN cr_craptit(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_intitcop => 1 -- Tit.Cooperativa
                                        ,pr_flgtitco => 1) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craptit.vldpagto;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- Fim do loop craptit
          END LOOP; -- Fim do loop craplot
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('crapchd') THEN -- Cheques capturados
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot_III IN cr_craplot_III( pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                               ,pr_cdagenci => rw_crapbcx.cdagenci
                                               ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                               ,pr_cdopecxa => rw_crapbcx.cdopecxa) LOOP
            -- Cheques acolhidos para depositos nas contas dos associados
            FOR rw_crapchd IN cr_crapchd(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot_III.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot_III.cdbccxlt
                                        ,pr_cdagenci => rw_craplot_III.cdagenci
                                        ,pr_nrdolote => rw_craplot_III.nrdolote) LOOP

              IF rw_crapchd.cdbccxlt = 500 THEN
                vr_vllanchq := vr_vllanchq + rw_crapchd.vlcheque;
                vr_qtlanchq := vr_qtlanchq + 1;
              ELSE
                vr_vlrttctb := vr_vlrttctb + rw_crapchd.vlcheque;
                vr_qtrttctb := vr_qtrttctb + 1;
              END IF;

            END LOOP; -- Final do loop rw_crapchd
          END LOOP; -- Final do loop rw_craplot_III
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craplcx') THEN

          -- buscar os lancamentos extra-sistema que compoem o boletim de caixa
          FOR rw_craplcx IN cr_craplcx( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa) LOOP
            -- se historico não bater pula para o proximo registro
            IF rw_craplcx.cdhistor <> rw_craphis.cdhistor THEN
              CONTINUE;
            END IF;

            IF rw_craphis.indcompl <> 0 THEN
              -- Verificar se historico é valido
              OPEN cr_craphis_II(pr_cdcooper => rw_craplcx.cdcooper
                                ,pr_cdhistor => rw_craplcx.cdhistor);
              FETCH cr_craphis_II INTO rw_craphis_II;

              -- Se não for continua rotina
              IF cr_craphis_II%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craphis_II;
                CONTINUE;
              END IF;
              -- Fecha cursor
              CLOSE cr_craphis_II;

              -- Arrecadacoes
              IF rw_craphis.cdhistor <> 717 AND
                rw_craphis_II.indebcre <> rw_craphis.indebcre THEN
                CONTINUE;
              END IF;

              -- Armazenar registros na tabela temporaria
              vr_index_craphis:= vr_typ_w_craphis.COUNT + 1;

              vr_typ_w_craphis(vr_index_craphis).cdhistor := rw_craplcx.cdhistor;
              vr_typ_w_craphis(vr_index_craphis).dshistor := SubStr(rw_craphis_II.dshistor,1,18);
              vr_typ_w_craphis(vr_index_craphis).dsdcompl := SubStr(to_char(rw_craplcx.dsdcompl),1,50);
              vr_typ_w_craphis(vr_index_craphis).qtlanmto := vr_typ_w_craphis(vr_index_craphis).qtlanmto + 1;
              vr_typ_w_craphis(vr_index_craphis).vllanmto := vr_typ_w_craphis(vr_index_craphis).vllanmto +
                                                             rw_craplcx.vldocmto;

              vr_flgouthi := TRUE;
              vr_vlrttctb := vr_vlrttctb + rw_craplcx.vldocmto;
              vr_qtrttctb := vr_qtrttctb + 1;
            ELSE
              vr_vlrttctb := vr_vlrttctb + rw_craplcx.vldocmto;
              vr_qtrttctb := vr_qtrttctb + 1;
            END IF;

          END LOOP; -- Fim do lancamento extra-caixa rw_craplcx
        ELSIF UPPER(rw_craphis.nmestrut) = UPPER('craptvl') THEN
          -- Verificar baixa de banco para testes com varios caixas abertos
          FOR rw_craplot IN cr_craplot( pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtolt => rw_crapbcx.dtmvtolt
                                       ,pr_cdagenci => rw_crapbcx.cdagenci
                                       ,pr_nrdcaixa => rw_crapbcx.nrdcaixa
                                       ,pr_cdopecxa => rw_crapbcx.cdopecxa
                                       ,pr_cdbccxlt => 11
                                       ,pr_tplotmov => rw_craphis.tplotmov) LOOP
            -- tranferencia de valores (DOC C, DOC D E TEDS)
            FOR rw_craptvl IN cr_craptvl(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdolote => rw_craplot.nrdolote) LOOP

              vr_vlrttctb := vr_vlrttctb + rw_craptvl.vldocrcb;
              vr_qtrttctb := vr_qtrttctb + 1;

            END LOOP; -- fim do rw_craptvl
          END LOOP; -- Fim do loop rw_craplot
        ELSE
          vr_flgsemhi := 1; -- true
        END IF;

        /**** Outros  Tipos de Historicos ******/
        IF rw_craphis.cdhistor <> 717
          AND rw_craphis.cdhistor <> 561
          AND (vr_vlrttctb     <> 0
           OR vr_vllanchq    <> 0) THEN

          -- Se tiver valor de lancamento de cheque
          IF vr_vllanchq <> 0 THEN
            -- Se for historico de debito
            IF rw_craphis.indebcre = 'D' THEN
              vr_vlrttdeb := vr_vlrttdeb + vr_vllanchq;
            ELSE -- historico de credito
              vr_vlrttcrd := vr_vlrttcrd + vr_vllanchq;
            END IF;
          END IF;

          -- Historicos de credito
          IF rw_craphis.indebcre = 'C' THEN
            vr_vlrttcrd := vr_vlrttcrd + vr_vlrttctb;
          ELSE -- Debito
            vr_vlrttdeb := vr_vlrttdeb + vr_vlrttctb;
          END IF;

          -- Limpar variaveis ao fim do historico
          vr_vlrttctb := 0;
          vr_qtrttctb := 0;
          vr_vllanchq := 0;
          vr_qtlanchq := 0;

        END IF;

        -- Hist. 717-arrecadacoes
        IF rw_craphis.last_of = rw_craphis.current_of AND
          rw_craphis.cdhistor = 717                   AND
          (vr_vlrttctb <> 0                          OR
          vr_vllanchq <> 0)                          THEN

          -- Buscar registros da temp-table
          FOR idx IN 1..vr_typ_w_craphis.Count LOOP
            -- Se valor não for zero
            IF vr_typ_w_craphis(idx).vllanmto > 0 THEN
              -- Credito
              IF rw_craphis.indebcre = 'C' THEN
                vr_vlrttcrd := vr_vlrttcrd + vr_typ_w_craphis(idx).vllanmto;
              ELSE -- Debito
                vr_vlrttdeb := vr_vlrttdeb + vr_typ_w_craphis(idx).vllanmto;
              END IF;
            END IF;
          END LOOP;
        END IF;

        -- Se for o ultimo debito/credito
        IF rw_craphis.last_of = rw_craphis.current_of_indebcre THEN
          IF vr_vlrttcrd <> 0 OR vr_vlrttdeb <> 0 THEN
            pr_vlcredit := nvl(vr_vlrttcrd,0);
            pr_vldebito := nvl(vr_vlrttdeb,0);
          END IF;
        END IF;

        -- Se não tiver historico = PROBLEMA
        IF vr_flgsemhi = 1 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Atencao! Avise a Informatica urgente. Ha lancamentos novos no CRAPHIS';
          RAISE vr_exc_saida;
        END IF;
      END LOOP; -- final do loop rw_craphis

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Rotina de geracao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => nvl(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Rotina de geracao de erro
        vr_dscritic := 'Erro na consulta dos boletins de caixa CAIX0001.pc_disp_dados_bole_caixa: ' || SQLERRM;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;

  END pc_disp_dados_bole_caixa;

  PROCEDURE pc_gera_relato(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE   -- Agencia/PA
                          ,pr_nrdcaixa IN INTEGER                 -- Caixa
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   -- Data movimento
                          ,pr_tpcaicof IN VARCHAR2                -- Caixa/Cofre/Total
                          ,pr_saldotot IN NUMBER                  -- Saldo Total
                          ,pr_cdprogra IN VARCHAR2                -- Programa
                          ,pr_inetapa  IN VARCHAR2                -- etapa de execução da tela de chamada
                          ,pr_tab_crapbcx IN typ_tab_crapbcx      -- Registros da crapbcx
                          ,pr_nmarqimp OUT VARCHAR2               -- Caminho do arquivo
                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS    -- Descricao da critica

/* .............................................................................

   Programa: pc_gera_relato
   Sistema : CRED
   Sigla   : CAIX0001
   Autor   : Lucas Eduardo Ranghetti
   Data    : Março/2015.                        Ultima atualizacao: 20/06/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Gerar relatorio de boletim de caixa

   Alteracoes: 05/05/2015 - Alterado o campo flg_impri da procedure pc_solicita_relato de 'S' para 'N'
                            para não gerar o arquivo pdf no diretório audit_pdf (Lucas Ranghetti #281494)

               20/06/2017 - Dispara procedure para gerar LOG pc_gera_log 
                            Setado modulo
                            Padrão de mensagens 
                            Incluido parametro de entrada com o nome do programa na procedure pc_gera_relato 
                            ( Belli - Envolti - 20/06/2017 - Chamado 660322 )
                            
  ............................................................................. */
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_dscritic VARCHAR2(10000);

      --Variaveis de indices
      vr_index PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

       -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);

      -- Variaveis pdf
      vr_nmarqimp VARCHAR2(100) := '';

      vr_nmrescop VARCHAR2(10) := ' ';
      vr_nmrelato VARCHAR2(30) := ' ';

      -- Cursores
      CURSOR cr_crapcop IS
      SELECT cop.nmextcop,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS

      BEGIN

        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN

	    -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'CAIX0001.pc_gera_relato');

      -- Buscar cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      IF cr_crapcop%FOUND THEN
        -- Fechar cursor
        CLOSE cr_crapcop;
        -- buscar nome resumido da cooperativa
        vr_nmrescop := SubStr(rw_crapcop.nmrescop,1,10);
      ELSE
        -- Fechar cursor
        CLOSE cr_crapcop;
      END IF;

      vr_nmrelato := 'BOLETIM DE CAIXA';

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><bcaixa>');

       pc_escreve_xml('<titulo>');
         pc_escreve_xml( '<nmrescop>' || to_char(vr_nmrescop) ||
                         '</nmrescop>' ||
                         '<cdagenci>' || to_char(nvl(pr_cdagenci,0)) ||
                         '</cdagenci>' ||
                         '<nmrelato>' || trim(vr_nmrelato) ||
                         '</nmrelato>' ||
                         '<horario>'  || to_char(SYSTIMESTAMP,'hh24:mi:ss') ||
                         '</horario>' ||
                         '<dtmvtolt>' || to_char(pr_dtmvtolt,'dd/mm/yyyy') ||
                         '</dtmvtolt>' ||
                         '<tpcaicof>' || to_char(pr_tpcaicof) ||
                         '</tpcaicof>'  );
      pc_escreve_xml('</titulo>');

      -- Tag conteudo
      pc_escreve_xml('<conteudo>');

      -- Buscar primeiro registro da tabela
      vr_index:= pr_tab_crapbcx.FIRST;
      WHILE vr_index IS NOT NULL LOOP

        pc_escreve_xml(
                     '<agencia cdagenci="' || to_char(nvl(pr_tab_crapbcx(vr_index).cdagenci,0)) || '">'||
                       '<cdcooper>' || to_char(pr_cdcooper) ||
                       '</cdcooper>' ||
                       '<cdagenci>' || to_char(nvl(pr_tab_crapbcx(vr_index).cdagenci,0)) ||
                       '</cdagenci>' ||
                       '<nrdcaixa>' || to_char(nvl(pr_tab_crapbcx(vr_index).nrdcaixa,0)) ||
                       '</nrdcaixa>' ||
                       '<nmoperad>' || to_char(pr_tab_crapbcx(vr_index).nmoperad) ||
                       '</nmoperad>' ||
                       '<vldsdtot>' || to_char(nvl(pr_tab_crapbcx(vr_index).vldsdtot,0),'fm999G999G990D00') ||
                       '</vldsdtot>' ||
                       '<csituaca>' || to_char(pr_tab_crapbcx(vr_index).csituaca) ||
                       '</csituaca>' ||
                       '<totcacof>' || to_char(nvl(pr_tab_crapbcx(vr_index).totcacof,0),'fm999G999G990D00') ||
                       '</totcacof>' ||
                       '<vltotcai>' || to_char(nvl(pr_tab_crapbcx(vr_index).vltotcai,0),'fm999G999G990D00') ||
                       '</vltotcai>' ||
                       '<vltotcof>' || to_char(nvl(pr_tab_crapbcx(vr_index).vltotcof,0),'fm999G999G990D00') ||
                       '</vltotcof>' ||
                       '<saldotot>' || to_char(nvl(pr_saldotot,0),'fm999G999G990D00') ||
                       '</saldotot>' ||
                     '</agencia>'  );
        -- Proximo registro
        vr_index:= pr_tab_crapbcx.NEXT(vr_index);
      END LOOP;
      -- Fim da tag conteudo
      pc_escreve_xml('</conteudo></bcaixa>');

      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl

      -- buscar nome do arquivo
      vr_nmarqimp := 'bcaixa_' || gene0002.fn_busca_time;
      pr_nmarqimp := vr_nmarqimp;

      -- Gerar o xml para teste
      /*gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                    ,pr_caminho  => '/usr/coop/sistema/equipe/ranghetti/'
                                    ,pr_arquivo  => vr_nmarqimp || '.xml'
                                    ,pr_des_erro => vr_dscritic); */

      -- Gerando o relatório nas pastas /rl
      --Incluído parametro de entrada que indica a etapa de execução da tela de chamada: 
      --executa o relatório apenas no 2o momento - Chamado 660322 - 26/06/2017

      if pr_inetapa <> '0' then
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => pr_cdprogra
                                 ,pr_dtmvtolt  => pr_dtmvtolt
                                 ,pr_dsxml     => vr_des_xml
                                 ,pr_dsxmlnode => '/bcaixa'
                                 ,pr_dsjasper  => 'bcaixa.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_path_arquivo || '/' || vr_nmarqimp || '.ex'
                                 ,pr_flg_gerar => 'S'
                                 ,pr_qtcoluna  => 80
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'N'
                                 ,pr_nmformul  => '80col'
                                 ,pr_nrcopias  => 1
                                 ,pr_des_erro  => vr_dscritic);

      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      END IF;

      -- Liberando a memória alocada pro CLOB
      -- Finaliza o XML
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Rotina de geracao de erro
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Rotina de geracao de erro
        pr_dscritic := 'Erro na impressao dos boletins de caixa CAIX0001.pc_gera_relato: ' || SQLERRM;
    END;
  END pc_gera_relato;

 --- ---

  PROCEDURE pc_gera_log(pr_cdcooper     IN  crapcop.cdcooper%TYPE     -- Cooperativa
                       ,pr_modulo       IN  VARCHAR2                  -- Modulo que disparou
                       ,pr_acao         IN  VARCHAR2                  -- Ação do modulo
                       ,pr_cdagenci     IN  crapage.cdagenci%TYPE     -- Agencia/PA
                       ,pr_nrdcaixa     IN  INTEGER                   -- Caixa
                       ,pr_dtmvtolt     IN  crapdat.dtmvtolt%TYPE     -- Data movimento
                       ,pr_tpcaicof     IN  VARCHAR2                  -- Tipo de pequisa
                       ,pr_dscritic_in  IN  crapcri.dscritic%TYPE     -- Descricao da critica Entrada
                       ,pr_dscritic_out OUT crapcri.dscritic%TYPE     -- Descricao da critica Saida
   ) IS

/* .............................................................................

   Programa: pc_gera_log
   Sistema : CRED
   Sigla   : CAIX0001
   Autor   : Cesar Belli - Envolti - Chamado 660322
   Data    : Junho/2017.                        Ultima atualizacao: 20/09/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Gerar log de boletim de caixa
   Alteracoes: 20/09/2017 - Alterada pc_gera_log para não gravar nome de arquivo de log e gravar cdprograma
                            (Ana - Envolti - 20/09/2017 - Chamado 746134)
    
  ............................................................................. */
  
    -- Tratamento de erros
    vr_exc_saida           EXCEPTION;
      
    -- Variaveis de inclusão de log 
    vr_idprglog            tbgen_prglog.idprglog%TYPE := 0;  
    vr_dsmensagem          tbgen_prglog_ocorrencia.dsmensagem%TYPE := null;
    vr_modulo              tbgen_prglog.cdprograma%TYPE;  
  BEGIN
    --Ajuste nmarqlog e cdprograma - Chamado 746134
    vr_modulo := NVL(trim(pr_modulo), 'CAIX0001');
    
	  -- Incluir nome do módulo logado - Chamado 660322 20/06/2017
		GENE0001.pc_set_modulo(pr_module => vr_modulo, pr_action => 'CAIX0001.pc_gera_log');

    vr_dsmensagem := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_modulo 
                             || ' --> ' 
                             || 'ALERTA: '       || pr_dscritic_in    
                             || ' pr_cdcooper='  || pr_cdcooper
                             || ' ,pr_cdagenci=' || pr_cdagenci
                             || ' ,pr_nrdcaixa=' || pr_nrdcaixa
                             || ' ,pr_dtmvtolt=' || pr_dtmvtolt
                             || ' ,pr_tpcaicof=' || pr_tpcaicof                              
                             || ' - Module: ' || vr_modulo 
                             || ' - Action: ' || pr_acao;

     cecred.pc_log_programa(pr_dstiplog      => 'O',              -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                            pr_cdprograma    => vr_modulo,        -- tbgen_prglog
                            pr_cdcooper      => pr_cdcooper,      -- tbgen_prglog
                            pr_tpexecucao    => 1,                -- tbgen_prglog  DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia  => 4,                -- tbgen_prglog_ocorrencia -- 4 Mensagem
                            pr_cdcriticidade => 0,                -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                            pr_dsmensagem    => vr_dsmensagem,    -- tbgen_prglog_ocorrencia
                            pr_flgsucesso    => 1,                -- tbgen_prglog  DEFAULT 1 -- Indicador de sucesso da execução
                            pr_nmarqlog      => NULL,
                            pr_idprglog      => vr_idprglog
                            );
      
           
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 20/06/2017 - Chamado 660322        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      -- Rotina de geracao de erro
      pr_dscritic_out := 'Erro no log dos boletins de caixa CAIX0001.pc_gera_log: ' || SQLERRM;
  
  END pc_gera_log;
  ---
end CAIX0001;
/
