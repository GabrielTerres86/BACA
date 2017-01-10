CREATE OR REPLACE PACKAGE PROGRID.PRGD0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : PRGD0001
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web PROGRID
  --  Sigla    : PRGD0001
  --  Autor    : Jean Michel
  --  Data     : Agosto/2015.                   Ultima atualizacao: 29/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar interface e valida��es necess�rias para intercambio de dados para o sistema PROGRID
  --
  --        Alteracoes: 29/10/2015 - Incluido nova condicao na busca de Regionais,
  --                                 "AND reg.cddregio NOT IN (9,999)" (Jean Michel). 
  --                                 
  --                    19/10/2016 - Incluido chamada da pc_informa_acesso_progrid na
  --                                 procedure pc_redir_acao_prgd para registro de LOG 
  --                                 em qualquer acesso as rotinas (Jean Michel)
  --
  --                    29/11/2016 - P341 - Automatiza��o BACENJUD - Alterado para validar 
  --                                 o departamento � partir do c�digo e n�o mais pela 
  --                                 descri��o (Renato Darosci - Supero)
  ---------------------------------------------------------------------------------------------------------------

  -- Procedure que ser� a interface entre o Oracle e sistema Web
  PROCEDURE pc_xml_web_prgd(pr_xml_req IN CLOB --> Arquivo XML de retorno
                           ,
                            pr_xml_res OUT NOCOPY CLOB); --> Arquivo XML de resposta

  -- Procedure para gerenciar a extra��o de dados do XML de envio
  PROCEDURE pc_extrai_dados_prgd(pr_xml      IN xmltype --> XML com dados para LOG
                                ,
                                 pr_cdcooper OUT NUMBER --> C�digo da cooperativa
                                ,
                                 pr_cdoperad OUT VARCHAR2 --> Operador
                                ,
                                 pr_nmdatela OUT VARCHAR2 --> Nome da tela
                                ,
                                 pr_nmdeacao OUT VARCHAR2 --> Nome da a��o
                                ,
                                 pr_idcokses OUT VARCHAR2 --> ID do Cookie da sessao
                                ,
                                 pr_idsistem OUT INTEGER --> ID do Sistema
                                ,
                                 pr_cddopcao OUT VARCHAR2 --> Codigo da opcao
                                ,
                                 pr_dscritic OUT VARCHAR2); --> Descri��o da cr�tica

  -- Procedure para listar as cooperativas do sistema
  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,
                                  pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                 ,
                                  pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,
                                  pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,
                                  pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,
                                  pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,
                                  pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,
                                  pr_des_erro OUT VARCHAR2); --> Descricao do Erro

  -- Procedure para listar as cooperativas do sistema
  PROCEDURE pc_lista_regionais(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,
                               pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da Regional
                              ,
                               pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,
                               pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,
                               pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,
                               pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,
                               pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,
                               pr_des_erro OUT VARCHAR2); --> Descricao do Erro

  -- Procedure para listar as cooperativas do sistema
  PROCEDURE pc_lista_pa(pr_cdcooper IN VARCHAR2 --> Codigo da Cooperativa
                       ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da Regional      
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                       ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2); --> Descricao do Erro

  /* Procedure para listar os eixos do sistema */
  PROCEDURE pc_lista_eixo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                        
                         
                         
  /* Procedure para listar os temas do sistema */
  PROCEDURE pc_lista_tema(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                         ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                         
  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_evento(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                           ,pr_cdagenci IN VARCHAR2              --> Codigo da Agencia (PA)    
                           ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                           ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Codigo do Tema
                           ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                           
  /* Procedure para retornar data base da agenda da cooperativa */
  PROCEDURE pc_retanoage(pr_cdcooper IN VARCHAR2     --> Codigo da Cooperativa
                        ,pr_idevento IN VARCHAR2     --> Ide do evento
                        ,pr_dtanoage IN VARCHAR2     --> Ano agenda
                        ,pr_xmllog   IN VARCHAR2     --> XML com informa��es de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                        ,pr_dscritic OUT VARCHAR2    --> Descri��o da cr�tica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2    --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);  --> Descricao do Erro
   
  --> Rotina de envio de email de eventos sem local de realiza��o
  PROCEDURE pc_envia_email_evento_local(pr_dscritic OUT VARCHAR2);
                     
  /* Informa��o do modulo em execu��o na sess�o do Progrid */
  PROCEDURE pc_informa_acesso_progrid(pr_module IN VARCHAR2
                                     ,pr_action IN VARCHAR2 DEFAULT NULL);                             
                         
END PRGD0001;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.PRGD0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : PRGD0001
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web PROGRID
  --  Sigla    : PRGD0001
  --  Autor    : Jean Michel
  --  Data     : Agosto/2015.                   Ultima atualizacao: 19/10/2016
  --
  --  Dados referentes ao programa:
  --
  --  Frequencia: Sempre que for solicitado
  --  Objetivo  : Criar interface e valida��es necess�rias para intercambio de dados
  --
  --  Notas: Obrigatoriamente a estrutura de par�metros dever� ser a seguinte:
  --
  --        (..., pr_xmllog, pr_cdcritic, pr_dscritic, pr_retxml, pr_nmdcampo, pr_des_erro)
  --
  --        Estes par�metros devem estar sempre presentes e na ordem apresentada para padronizar
  --        O retorno das execu��es din�micas para o sistema Web.
  --
  --        - pr_xmllog: Arquivo XML com inforam��es para LOG interno
  --        - pr_cdcritic: c�digo da cr�tica, se houver
  --        - pr_dscritic: descri��o da cr�tica, se houver
  --        - pr_retxml: XML de retorno, retorno obrigat�rio
  --        - pr_nmdcampo: nome do campo executor, se houver
  --        - pr_des_erro: erros de execu��o da rotina, se houver
  --
  --        Alteracoes: 29/10/2015 - Incluido nova condicao na busca de Regionais,
  --                                 "AND reg.cddregio NOT IN (9,999)" (Jean Michel).
  --
  --                    19/10/2016 - Incluido chamada da pc_informa_acesso_progrid na
  --                                 procedure pc_redir_acao_prgd para registro de LOG 
  --                                 em qualquer acesso as rotinas (Jean Michel)
  --
  --                    29/11/2016 - P341 - Automatiza��o BACENJUD - Alterado para validar 
  --                                 o departamento � partir do c�digo e n�o mais pela 
  --                                 descri��o (Renato Darosci - Supero)
  ---------------------------------------------------------------------------------------------------------------

  -- Procedure para validar ID do cookie da sessao
  PROCEDURE pc_valida_cookie(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_cdoperad IN crapope.cdoperad%TYPE --> Codigo do operador
                            ,pr_idcokses IN VARCHAR2              --> ID cookie da sessao
                            ,pr_dscritic OUT VARCHAR2) IS         --> Descricao de erros
    -- ..........................................................................
    --
    --  Programa : pc_valida_cookie
    --  Sistema  : Rotinas de validacao de ID do cookie
    --  Sigla    : PRGD
    --  Autor    : Jean Michel
    --  Data     : Junho/2015.                   Ultima atualizacao: 12/06/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Sem retorno, caso informar retorno com critica, efetuar
    --               logoff no sistema (PROGRID)
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      CURSOR cr_gnapses(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_cdoperad IN crapope.cdoperad%TYPE,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                        pr_idcokses IN VARCHAR2) IS
        SELECT ses.cdcooper, ses.cdoperad
          FROM gnapses ses
         WHERE ses.cdcooper = pr_cdcooper
           AND ses.cdoperad = pr_cdoperad
           AND ses.idsessao = pr_idcokses
           AND ses.dtsessao = pr_dtmvtolt;
    
      rw_gnapses cr_gnapses%ROWTYPE;
    
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      -- Variaveis de erro e excessao
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);
    
    BEGIN
    
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
    
      -- Se n�o encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
      
        vr_cdcritic := 999;
      
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
    
      -- Consulta registro de sessao aberta
      OPEN cr_gnapses(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => pr_cdoperad,
                      pr_dtmvtolt => TRUNC(SYSDATE),
                      pr_idcokses => pr_idcokses);
    
      FETCH cr_gnapses
        INTO rw_gnapses;
    
      -- Verifica se existe registro
      IF cr_gnapses%NOTFOUND THEN
        pr_dscritic := 'Usuario nao logado no sistema';
      END IF;
    
      CLOSE cr_gnapses;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral PRGD0001.PC_VALIDA_COOKIE: ' || SQLERRM;
    END;
  END pc_valida_cookie;

  /* Procedure para valiar o acesso ao sistema */
  PROCEDURE pc_valida_acesso_sistema_prgd(pr_cdcooper IN crapace.cdcooper%TYPE  --> C�digo da cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do operador
                                         ,pr_idsistem IN craptel.idsistem%TYPE  --> Identificador do sistema
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                         ,pr_cddepart OUT crapope.cddepart%TYPE --> Descri��o do departamento
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> C�digo de retorno
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o do retorno
    -- ..........................................................................
    --
    --  Programa : pc_valida_acesso_sistema_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 06/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Valida permiss�o para os objetos envolvidos na execu��o.
    --
    --   Alteracoes: 06/12/2016 - Retirado controle de arquivo do processo batch, Prj. 229 (Jean Michel)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida EXCEPTION; --> Controle de sa�da
      vr_arquivo    VARCHAR2(400); --> Vari�vel para retorno da busca de arquivo de bloqueio
      vr_arquivo_so VARCHAR2(400); --> Vari�vel para retorno da busca de arquivo de bloqueio
      vr_dsdircop   VARCHAR2(100);
      
      -- Busca dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS --> C�digo da cooperativa
        SELECT cop.cdcooper
               ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Busca dados do cadastro dos operadores
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE --> C�digo da cooperativa
                       ,
                        pr_cdoperad IN crapope.cdoperad%TYPE) IS --> C�digo do operador
        SELECT pe.cddepart
          FROM crapope pe
         WHERE pe.cdcooper = pr_cdcooper
           AND upper(pe.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;
    
      -- Busca dados do cadastro de telas
      CURSOR cr_craptel(pr_cdcooper IN craptel.cdcooper%TYPE --> C�digo da cooperativa
                       ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                       ,pr_idsistem IN craptel.idsistem%TYPE) IS --> identificador no sistema
        SELECT el.inacesso, el.idambtel, el.flgtelbl
          FROM craptel el
         WHERE el.cdcooper = pr_cdcooper
           AND el.nmdatela = pr_nmdatela
           AND el.idsistem = pr_idsistem;
      rw_craptel cr_craptel%ROWTYPE;
    
      -- Busca dados do cadastro dos programas
      CURSOR cr_crapprg(pr_cdcooper IN crapprg.cdcooper%TYPE --> C�digo da cooperativa
                       ,pr_nmdatela IN crapprg.cdprogra%TYPE) IS --> Nome da tela
        SELECT rg.nmsistem
          FROM crapprg rg
         WHERE rg.cdcooper = pr_cdcooper
           AND rg.cdprogra = pr_nmdatela
           AND rg.nmsistem = 'CRED';
    
    BEGIN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
    
      -- Se n�o encontrar registro
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;
    
      -- Verifica se existe operador cadastrado
      OPEN cr_crapope(pr_cdcooper, pr_cdoperad);
      FETCH cr_crapope
        INTO rw_crapope;
    
      -- Se n�o encontrar registro
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        pr_cdcritic := 67;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        pr_cddepart := rw_crapope.cddepart;
        CLOSE cr_crapope;
      END IF;
    
      -- Verifica se a tela est� cadastrada no sistema
      OPEN cr_craptel(pr_cdcooper, pr_nmdatela, pr_idsistem);
      FETCH cr_craptel
        INTO rw_craptel;
    
      -- Verifica se a tela foi encontrada
      IF cr_craptel%NOTFOUND THEN
        CLOSE cr_craptel;
        pr_cdcritic := 999;
        pr_dscritic := 'Tela nao cadastrada no sistema.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craptel;
      END IF;
    
      -- Verifica se o programa est� cadastrado
      OPEN cr_crapprg(pr_cdcooper, pr_nmdatela);
    
      -- Verificase a o programa foi encontrado
      IF cr_crapprg%NOTFOUND THEN
        CLOSE cr_crapprg;
        pr_cdcritic := 2;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapprg;
      END IF;
    
      -- Se n�o gerar consist�ncia limpa cr�ticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro em PRGD0001.PC_VALIDA_ACESSO_SISTEMA_PRGD. Erro: ' || pr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em PRGD0001.PC_VALIDA_ACESSO_SISTEMA_PRGD: ' || SQLERRM;
    END;
  END pc_valida_acesso_sistema_prgd;

  /* Procedure para verificar a permiss�o no momento da requisi��o */
  PROCEDURE pc_verifica_permis_oper_prgd(pr_cdcooper IN crapace.cdcooper%TYPE      --> C�digo da cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE      --> C�digo do operador
                                        ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                        ,pr_cddopcao IN crapace.cddopcao%TYPE      --> C�digo da op��o                                          
                                        ,pr_dscritic OUT VARCHAR2                  --> Descri��o da cr�tica
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE) IS --> C�digo da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_verifica_permis_oper_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Verifica permiss�o para os objetos envolvidos na execu��o.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida EXCEPTION; --> Controle de erros
      vr_cddepart crapope.cddepart%TYPE; --> Descri��o do departamento
      vr_dscritic VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
    
      -- Busca dados do cadastro com permissoes de acesso as telas do sistema
      CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE,
                        pr_cdoperad IN crapace.cdoperad%TYPE,
                        pr_nmdatela IN crapace.nmdatela%TYPE,
                        pr_cddopcao IN crapace.cddopcao%TYPE) IS
        SELECT ce.nmdatela
          FROM crapace ce
         WHERE ce.cdcooper = pr_cdcooper
           AND UPPER(ce.cdoperad) = UPPER(pr_cdoperad)
           AND UPPER(ce.nmdatela) = UPPER(pr_nmdatela)
           AND UPPER(ce.cddopcao) = UPPER(pr_cddopcao)
           AND UPPER(ce.nmrotina) IN('PROGRID','ASSEMBLEIA')
           AND ce.idambace = 3;
    
      vr_nmdatela crapace.nmdatela%TYPE;
    
    BEGIN
    
      -- Valida o acesso ao sistema
      pc_valida_acesso_sistema_prgd(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_idsistem => pr_idsistem
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_cddepart => vr_cddepart
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
    
      -- Verifica se ocorreram erros de execu��o
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Verifica qual � o departamento de opera��o
      IF vr_cddepart <> 20 THEN
        -- Verifica as permiss�es de execu��o no cadastro
        OPEN cr_crapace(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_cddopcao);
        FETCH cr_crapace
          INTO vr_nmdatela;
        -- Verifica se foi encontrada permiss�o
        IF cr_crapace%NOTFOUND THEN
          CLOSE cr_crapace;
          vr_cdcritic := 36;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapace;
        END IF;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 999;
        pr_dscritic := 'Erro geral em PRGD0001.PC_VERIFICA_PERMISSAO_OPERACAO_PRGD: ' || SQLERRM;
    END;
  END pc_verifica_permis_oper_prgd;

  /* Procedure para controlar o processo de valida��o de execu��o */
  PROCEDURE pc_executa_metodo_prgd(pr_xml      IN OUT xmltype   --> Documento XML
                                  ,pr_cdcritic OUT PLS_INTEGER  --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2) IS --> Descri��o da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_executa_metodo_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execu��o.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE
      rw_crapdat btch0001.cr_crapdat%ROWTYPE; --> Cursor com dados da data
      vr_exc_saida EXCEPTION; --> Controle de sa�da
      vr_exc_null  EXCEPTION; --> Controle de sa�da
    
    BEGIN
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper'));
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
    
      -- Se n�o encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
      
        pr_cdcritic := 999;
        pr_dscritic := 'Sistema sem data de movimento.';
      
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
    
      IF gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'nmdeacao') NOT IN('LISTA_COOPER','LISTA_REGIONAIS','LISTA_PA') THEN
        -- Valida permiss�o de execu��o
        pc_verifica_permis_oper_prgd(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper')
                                    ,pr_cdoperad => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdoperad')
                                    ,pr_idsistem => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'idsistem')
                                    ,pr_nmdatela => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'nmdatela')
                                    ,pr_cddopcao => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cddopcao')
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);
    
        -- Verifica se ocorreram erros na valida��o
        IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_null;
        END IF;
      END IF;
    
      -- Libera acesso a tela indicando que n�o existe cr�tica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral em PRGD0001.PC_EXECUTA_METODO_PRGD. ' || pr_dscritic || ' --> ' || SQLERRM;
      WHEN OTHERS THEN
        pr_cdcritic := 999;
        pr_dscritic := 'Erro geral em PRGD0001.PC_EXECUTA_METODO_PRGD: ' || SQLERRM;
    END;
  END pc_executa_metodo_prgd;

  -- Procedure para gerenciar a extra��o de dados do XML de envio
  PROCEDURE pc_extrai_dados_prgd(pr_xml      IN xmltype       --> XML com dados para LOG
                                ,pr_cdcooper OUT NUMBER       --> C�digo da cooperativa
                                ,pr_cdoperad OUT VARCHAR2     --> Operador
                                ,pr_nmdatela OUT VARCHAR2     --> Nome da tela
                                ,pr_nmdeacao OUT VARCHAR2     --> Nome da a��o
                                ,pr_idcokses OUT VARCHAR2     --> ID do Cookie da sessao
                                ,pr_idsistem OUT INTEGER      --> ID do Sistema
                                ,pr_cddopcao OUT VARCHAR2     --> Codigo da opcao
                                ,pr_dscritic OUT VARCHAR2) IS --> Descri��o da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_extrai_dados_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : Junho/2015.                   Ultima atualizacao: 12/06/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Extrair dados do XML de requisi��o.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    BEGIN
      pr_cdcooper := to_number(TRIM(pr_xml.extract('/Root/Permissao/cdcooper/text()').getstringval()));
      pr_nmdatela := TRIM(pr_xml.extract('/Root/Permissao/nmdatela/text()').getstringval());
      pr_nmdeacao := TRIM(pr_xml.extract('/Root/Permissao/nmdeacao/text()').getstringval());
      pr_idcokses := TRIM(pr_xml.extract('/Root/Permissao/idcokses/text()').getstringval());
      pr_cdoperad := TRIM(pr_xml.extract('/Root/Permissao/cdoperad/text()').getstringval());
      pr_idsistem := TRIM(pr_xml.extract('/Root/Permissao/idsistem/text()').getstringval());
      pr_cddopcao := TRIM(pr_xml.extract('/Root/Permissao/cddopcao/text()').getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em PRGD0001.pc_extrai_dados: ' || SQLERRM;
    END;
  END pc_extrai_dados_prgd;

  /* Cria XML para dados de LOG para os objetos executados */
  FUNCTION fn_cria_xml_log_prd(pr_cdcooper IN NUMBER                       --> C�digo da cooperativa
                              ,pr_nmdatela IN VARCHAR2                     --> Nome da tela
                              ,pr_nmdeacao IN VARCHAR2                     --> Nome da a��o
                              ,pr_idorigem IN VARCHAR2                     --> Identifica��o de origem
                              ,pr_cdoperad IN VARCHAR2) RETURN VARCHAR2 IS --> Operador
    -- ..........................................................................
    --
    --  Programa : fn_cria_xml_log_prd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com dados para cria��o de LOG interno nas rotinas executadas.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    BEGIN
      RETURN '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><params>' || '<nmdatela>' || pr_nmdatela || '</nmdatela>' || '<cdcooper>' || pr_cdcooper || '</cdcooper>' || '<idorigem>' || pr_idorigem || '</idorigem>' || '<cdoperad>' || pr_cdoperad || '</cdoperad>' || '<nmdeacao>' || pr_nmdeacao || '</nmdeacao></params></Root>';
    END;
  END;

  -- Procedure para controlar o redirecionamento das opera��es
  PROCEDURE pc_redir_acao_prgd(pr_xml      IN OUT NOCOPY xmltype 	      --> Sequencia de cadastro da solicita��o de execu��o
                              ,pr_nrseqsol IN OUT crapsrw.nrseqsol%TYPE --> Sequencia do hist�rico de execu��o
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2                 --> Descri��o da cr�tica
                              ,pr_nmdcampo OUT VARCHAR2) IS             --> Nome do campo com erro
  
    -- ..........................................................................
    --
    --  Programa : pc_redir_acao_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 19/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar chamada para a package/procedure de execu��o do processo de backend.
    --
    --   Alteracoes: 30/04/2014 - Implementa��o do cadastro de a��es para execu��o (Petter - Supero).
    --   
    --               03/03/2015 - Alteracao do tamanho da variavel vr_sql para o max
    --                            do tipo varchar2 (Tiago).                                       
    --
    --               09/12/2015 - Inclusao das acoes de listagem de eixo,tema,evento (Carlos Rafael Tanholi).                               
    --
    --               19/10/2016 - Incluido chamada da pc_informa_acesso_progrid para registro de LOG
    --                            (Jean Michel) 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_sql   VARCHAR2(32000); --> SQL din�mico para montagem de execu��es personalizadas
      vr_param gene0002.typ_split; --> Lista de strings quebradas por delimitador
      vr_exc_erro     EXCEPTION; --> Controle de exce��o
      vr_exc_null     EXCEPTION; --> Controle de exce��o
      vr_exc_problema EXCEPTION; --> Controle de exce��o
      vr_xpath    VARCHAR2(400); --> XPath da tag do arquivo XML
      vr_cdcooper NUMBER; --> C�digo da cooperativa
      vr_nmdatela VARCHAR2(100); --> Nome da tela/programa que ser� executado
      pr_sequence NUMBER; --> Sequencia de grava��o do LOG
      vr_nmdeacao VARCHAR2(100); --> A��o que ser� executada para a tela
      vr_cdoperad VARCHAR2(100); --> Operador
      vr_xmllog   VARCHAR2(32767); --> XML para propagar informa��es de LOG
      vr_dscritic VARCHAR2(4000); --> Descricao do Erro
      vr_idcokses VARCHAR2(100); -- ID do cookie da sessao
      vr_cddopcao VARCHAR2(100); -- Tipo da opcao
      vr_idsistem INTEGER(2) := 0; -- ID do sistema que esta sendo utilizado
    
      -- Busca qual package/procedure dever� ser executada
      CURSOR cr_craprdr(pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela de execucao
                       ,pr_nmdeacao IN crapaca.nmdeacao%TYPE) IS --> Nome da a��o de execucao
      
        SELECT ca.nmpackag, ca.nmproced, ca.lstparam
          FROM craprdr cr, crapaca ca
         WHERE ca.nrseqrdr = cr.nrseqrdr
           AND (upper(cr.nmprogra) LIKE upper(pr_nmdatela) OR
               pr_nmdatela IS NULL)
           AND upper(ca.nmdeacao) LIKE upper(pr_nmdeacao);
    
      rw_craprdr cr_craprdr%ROWTYPE;
    
    BEGIN
      -- Extrair dados do XML de requisi��o
      pc_extrai_dados_prgd(pr_xml      => pr_xml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmdeacao => vr_nmdeacao
                          ,pr_idcokses => vr_idcokses
                          ,pr_idsistem => vr_idsistem
                          ,pr_cddopcao => vr_cddopcao
                          ,pr_dscritic => vr_dscritic);
    
      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Valida ID do cookie da sessao
      pc_valida_cookie(pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                      ,pr_cdoperad => vr_cdoperad   --> Codigo do operador
                      ,pr_idcokses => vr_idcokses   --> ID cookie da sessao
                      ,pr_dscritic => vr_dscritic); --> Descricao de erros     
    
      -- Verifica se houve erro na validacao do cookie
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Gravar solicita��o
      gene0004.pc_insere_trans(pr_xml      => pr_xml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_sequence => pr_sequence
                              ,pr_nmdeacao => vr_nmdeacao
                              ,pr_dscritic => vr_dscritic);
    
      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Criar XML com dados de LOG para propagar para os objetos executados
      vr_xmllog := fn_cria_xml_log_prd(pr_cdcooper => vr_cdcooper
                                      ,pr_nmdatela => vr_nmdatela
                                      ,pr_nmdeacao => vr_nmdeacao
                                      ,pr_idorigem => 3
                                      ,pr_cdoperad => vr_cdoperad);
    
      IF vr_nmdeacao = 'VALIDACOOKIE' THEN
        RAISE vr_exc_null;
      END IF;
    
      IF vr_nmdeacao IN ('LISTA_PA', 'LISTA_REGIONAIS', 'LISTA_COOPER', 'LISTA_EIXO',
                         'LISTA_TEMA', 'LISTA_EVENTO','RETANOAGE','LISTA_FORNECEDORES') THEN
        vr_nmdatela := 'GENERICO';
      END IF;
    
      -- Busca os dados da execu��o solicitada
      OPEN cr_craprdr(vr_nmdatela, vr_nmdeacao);
      FETCH cr_craprdr
        INTO rw_craprdr;
    
      -- Verificar se existe package cadastrada para execu��o
      IF rw_craprdr.nmpackag IS NOT NULL THEN
        vr_sql := 'begin ' || rw_craprdr.nmpackag || '.';
      ELSE
        vr_sql := 'begin ';
      END IF;
    
      vr_sql := vr_sql || rw_craprdr.nmproced || '(';
    
      pc_informa_acesso_progrid(pr_module => vr_nmdatela || '|' || vr_cdcooper || '|' ||
                                             vr_cdoperad || '|' || vr_nmdeacao || '|'
                                            ||vr_idsistem || '|' || vr_cddopcao
                               ,pr_action => rw_craprdr.nmpackag || '.' || rw_craprdr.nmproced);

      -- Verifica se existem par�metros adicionais criados
      IF rw_craprdr.lstparam IS NOT NULL THEN
        -- Quebra a string de parametros
        vr_param := gene0002.fn_quebra_string(rw_craprdr.lstparam, ',');
      
        -- Itera sobre a string quebrada
        IF vr_param.count > 0 THEN
          FOR idx IN 1 .. vr_param.count LOOP
            -- Capturar valor do XPath do arquivo XML
            vr_xpath := '/Root/Dados/' || substr(vr_param(idx), 4, length(vr_param(idx))) || '/text()';
          
            -- Concatena o comando SQL, caso n�o exista valor na TAG gera par�metro de valor NULL
            IF idx = 1 AND vr_param.count > 1 THEN
              IF pr_xml.existsnode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null,';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''' || ',';
              END IF;
            ELSIF idx = 1 AND vr_param.count = 1 THEN
              IF pr_xml.existsnode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''';
              END IF;
            ELSIF idx = vr_param.count THEN
              IF pr_xml.existsnode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''';
              END IF;
            ELSE
              IF pr_xml.existsnode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null,';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''' || ',';
              END IF;
            END IF;
          END LOOP;
        END IF;
      
        vr_sql := vr_sql || ', ''' || vr_xmllog || ''', :1, :2, :3, :4, :5); end;';
      ELSE
        vr_sql := vr_sql || '''' || vr_xmllog || ''', :1, :2, :3, :4, :5); end;';
      END IF;
    
      -- Ordem para executar de forma imediata o SQL din�mico
      EXECUTE IMMEDIATE vr_sql USING OUT pr_cdcritic, OUT pr_dscritic, IN OUT pr_xml, OUT pr_nmdcampo, OUT vr_dscritic;
    
      -- Verifica se ocorreram erros
      IF vr_dscritic <> 'OK' THEN
        RAISE vr_exc_problema;
      END IF;
    
      -- Atualiza hist�rico com o XML de resposta
      gene0004.pc_atualiza_trans(pr_xml      => pr_xml
                                ,pr_seq      => pr_nrseqsol
                                ,pr_des_erro => vr_dscritic);
    
      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_problema THEN
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em PRGD0001.PC_REDIR_ACAO_PRGD: ' || SQLERRM;
    END;
  END pc_redir_acao_prgd;

  -- Procedure que ser� a interface entre o Oracle e sistema Web
  PROCEDURE pc_xml_web_prgd(pr_xml_req IN CLOB --> Arquivo XML de retorno
                           ,pr_xml_res OUT NOCOPY CLOB) IS --> Arquivo XML de resposta
    -- .................................................................................................
    --
    --  Programa : pc_xml_web
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : JUNHO/2015.                   Ultima atualizacao: 12/06/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerenciar interface de comunica��o (requisi��o/resposta) do sistema Web.
    --               Ir� receber um arquivo XML com dados de manipula��o e par�metros de execu��o
    --               para acessar a package/procedure necess�rio e ir� retornar um novo XML com
    --               mensagem de erro ou dados de retorno do processamento.
    --
    --   Alteracoes: 
    --
    -- .................................................................................................
  BEGIN
    DECLARE
    
      -- Variaveis de excessao e erro
      vr_exc_erro EXCEPTION; --> Controle de tratamento de erros personalizados
      vr_exc_libe EXCEPTION; --> Controle de erros para o processo de libera��o
      vr_cdcritic crapcri.cdcritic%TYPE; --> Variavel para armazenar codigo do erro de execucao
      vr_dscritic VARCHAR2(4000); --> Variavel para armazenar descricao do erro de execucao
    
      -- Variaveis locais
      vr_cdcooper crapcop.cdcooper%TYPE; --> C�digo da cooperativa
      vr_nmdcampo VARCHAR2(150); --> Nome do campo da execu��o
      vr_nrseqsol NUMBER; --> Sequencia do hist�rico de execu��es
      vr_conttag  PLS_INTEGER; --> Contador do n�mero de ocorr�ncias da TAG
      vr_xml      xmltype; --> Vari�vel do XML de entrada
      vr_erro_xml xmltype; --> Vari�vel do XML de erro
    
    BEGIN
      -- Criar instancia do XML em memoria
      vr_xml := xmltype.createxml(pr_xml_req);
    
      -- Verifica se existe a TAG de permissao
      gene0007.pc_lista_nodo(pr_xml      => vr_xml
                            ,pr_nodo     => 'Permissao'
                            ,pr_cont     => vr_conttag
                            ,pr_des_erro => vr_dscritic);
    
      -- Verifica se ocorreram erros na busca da TAG
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Verifica se existe permiss�o de execucao da tela pelo usuario e hora
      IF vr_conttag > 0 THEN
        pc_executa_metodo_prgd(pr_xml      => vr_xml
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      END IF;
    
      -- Verifica se o controle de permiss�o gerou erro ou cr�tica
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar XML de erro
        gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                 ,pr_cdcooper => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper')
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      
        RAISE vr_exc_libe;
      END IF;
    
      -- Gerar requisi��o para web
      pc_redir_acao_prgd(pr_xml      => vr_xml
                        ,pr_nrseqsol => vr_nrseqsol
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic
                        ,pr_nmdcampo => vr_nmdcampo);
    
      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      
        -- Gera XML com mensagem de erro
        IF nvl(vr_cdcritic, 0) = 0 THEN
          gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdcampo => vr_nmdcampo
                                   ,pr_cdcritic => 0
                                   ,pr_dscritic => vr_dscritic);
        
          -- Gravar mensagem de erro
          gene0004.pc_atualiza_trans(pr_xml      => vr_erro_xml
                                    ,pr_seq      => vr_nrseqsol
                                    ,pr_des_erro => vr_dscritic);
        
          -- Verifica se ocorreram erros ao gravar XML de resposta
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
        ELSE
          gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdcampo => vr_nmdcampo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
        
          -- Gravar mensagem de erro
          gene0004.pc_atualiza_trans(pr_xml      => vr_erro_xml
                                    ,pr_seq      => vr_nrseqsol
                                    ,pr_des_erro => vr_dscritic);
        
          -- Verifica se ocorreram erros ao gravar XML de resposta
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        
        END IF;
      
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getclobval();
      ELSE
        -- Propagar XML de sucesso
        pr_xml_res := vr_xml.getclobval();
      END IF;
    EXCEPTION
      WHEN vr_exc_libe THEN
        ROLLBACK;
      
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getclobval();
      WHEN vr_exc_erro THEN
        ROLLBACK;
      
        -- Gerar XML com descri��o do erro para exibi��o no sistema Web
        gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                 ,pr_cdcooper => vr_cdcooper
                                 ,pr_cdcritic => 0
                                 ,pr_dscritic => 'Erro: ' || vr_dscritic);
      
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getclobval();
      WHEN OTHERS THEN
        ROLLBACK;
      
        -- Gerar XML com descri��o do erro para exibi��o no sistema Web
        gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                 ,pr_cdcooper => vr_cdcooper
                                 ,pr_cdcritic => 0
                                 ,pr_dscritic => 'Erro geral em PRGD0001.PC_XML_WEB: ' || SQLERRM);
      
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getclobval();
    END;
  END pc_xml_web_prgd;

  /* Procedure para listar as cooperativas do sistema */
  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_cooperativas
    --  Sistema  : Rotinas para listar as cooperativas do sistema
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : Julho/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de cooperativas no sistema.
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
    
      -- Cursores
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper, cop.nmrescop, cop.flgativo
          FROM crapcop cop
         WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.nmrescop;
    
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
    
      FOR rw_crapcop IN cr_crapcop LOOP
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapcop.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmrescop',pr_tag_cont => rw_crapcop.nmrescop,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'flgativo', pr_tag_cont => rw_crapcop.flgativo, pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
    END;
  END pc_lista_cooperativas;

  /* Procedure para listar as cooperativas do sistema */
  PROCEDURE pc_lista_regionais(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da Regional
                              ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_regionais
    --  Sistema  : Rotinas para listar as regionais do sistema
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : Julho/2015.                   Ultima atualizacao: 29/10/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de regionais no sistema.
    --
    --  Alteracoes: 29/10/2015 - Incluido nova condicao na busca de Regionais,
    --                           "AND reg.cddregio NOT IN (9,999)" (Jean Michel).
    -- .............................................................................
  BEGIN
    DECLARE
    
      -- Cursores
      CURSOR cr_crapreg IS
        SELECT reg.cdcooper, reg.cddregio, reg.dsdregio
          FROM crapreg reg
         WHERE (reg.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND (reg.cddregio = pr_cddregio OR pr_cddregio = 0)
           AND reg.cddregio NOT IN (9,999)
         ORDER BY reg.dsdregio;
    
      rw_crapreg cr_crapreg%ROWTYPE;
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    
    BEGIN
    
      FOR rw_crapreg IN cr_crapreg LOOP
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapreg.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddregio', pr_tag_cont => rw_crapreg.cddregio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdregio', pr_tag_cont => rw_crapreg.dsdregio, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_REGIONAIS: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_REGIONAIS: ' || SQLERRM;
    END;
  END pc_lista_regionais;

  /* Procedure para listar as cooperativas do sistema */
  PROCEDURE pc_lista_pa(pr_cdcooper IN VARCHAR2 --> Codigo da Cooperativa
                       ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da Regional      
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                       ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_pa
    --  Sistema  : Rotinas para listar os pa's do sistema por cooperativa ou regional
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : Julho/2015.                   Ultima atualizacao: 02/08/2016
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de pa's no sistema.
    --
    --  Alteracoes: Implementacao do campo pr_cdcooper como VARCHAR2 para listagem de PA's
    --              de varias cooperativas assim retornando uma unica lista. (Carlos Rafael Tanholi - 16/12/2015)
    --
    --              Conforme solicitacao do Marcio implementei a consistencia para o carregamento de agencias
    --              com a flag de habilitadas para o PROGRID igual a 1 (Carlos Rafael Tanholi - 17/12/2015)
    --
    --              02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel. (Jaison/Anderson)
    --
    -- .............................................................................
  BEGIN
    DECLARE
    
      -- Cursores
      CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT age.cdcooper, age.cddregio, age.cdagenci, age.nmresage
          FROM crapage age
         WHERE (age.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND (age.cddregio = pr_cddregio OR pr_cddregio = 0)
           AND (age.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
           AND age.cdagenci NOT IN (90, 91)
           AND age.flgdopgd = 1
           AND age.insitage IN (1,3) -- 1-Ativo ou 3-Temporariamente Indisponivel
         ORDER BY age.nmresage;
    
      rw_crapage cr_crapage%ROWTYPE;
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      arr_cooperativas GENE0002.typ_split;      
      vr_cdcooper crapcop.cdcooper%TYPE;
    
    BEGIN
    
      arr_cooperativas := GENE0002.fn_quebra_string(pr_string => pr_cdcooper, pr_delimit => ',');
    
      FOR vr_cdcooper IN arr_cooperativas.FIRST..arr_cooperativas.LAST LOOP      
    
        FOR rw_crapage IN cr_crapage(arr_cooperativas(vr_cdcooper)) LOOP
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapage.cdcooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddregio', pr_tag_cont => rw_crapage.cddregio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapage.cdagenci, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapage.nmresage, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_PA: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_PA: ' || SQLERRM;
    END;
  END pc_lista_pa;


  /* Procedure para listar os eixos do sistema */
  PROCEDURE pc_lista_eixo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_eixo
    --  Sistema  : Rotinas para listar os eixos do sistema por cooperativa
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Desembro/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eixos do sistema.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursores
      CURSOR cr_gnapetp IS
      SELECT cdeixtem, dseixtem
        FROM gnapetp
       WHERE (cdcooper = 0)
       ORDER BY dseixtem;
        
      rw_gnapetp cr_gnapetp%ROWTYPE;
        
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
    BEGIN
      
      FOR rw_gnapetp IN cr_gnapetp LOOP
          
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem', pr_tag_cont => rw_gnapetp.cdeixtem, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem', pr_tag_cont => rw_gnapetp.dseixtem, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
          
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_EIXO: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_EIXO: ' || SQLERRM;
    END;

  END pc_lista_eixo;

  /* Procedure para listar os temas do sistema */
  PROCEDURE pc_lista_tema(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                         ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_tema
    --  Sistema  : Rotinas para listar os temas do sistema por cooperativa e eixo
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Desembro/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de temas do sistema.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursores
      CURSOR cr_craptem IS
      SELECT nrseqtem, dstemeix
        FROM craptem
       WHERE (cdcooper = 0)
         AND (cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
       ORDER BY dstemeix;
        
      rw_craptem cr_craptem%ROWTYPE;
        
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
    BEGIN
      
      FOR rw_craptem IN cr_craptem LOOP
          
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqtem', pr_tag_cont => rw_craptem.nrseqtem, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstemeix', pr_tag_cont => rw_craptem.dstemeix, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
          
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_TEMA: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_TEMA: ' || SQLERRM;
    END;

  END pc_lista_tema;

  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_evento(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                           ,pr_cdagenci IN VARCHAR2            	 --> Codigo da Agencia (PA)    
                           ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                           ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Codigo do Tema
                           ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_evento
    --  Sistema  : Rotinas para listar os eventos do sistema por cooperativa, eixo e tema
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Desembro/2015.                   Ultima atualizacao: 17/12/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de temas do sistema.
    --
    --  Alteracoes: Implementacao do campo pr_cdagenci como VARCHAR2 para listagem de Eventos
    --              de varias cooperativas e agencias assim retornando uma unica lista.
    --              Formato cooperativa|agencia (Carlos Rafael Tanholi - 17/12/2015) 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursor sobre o cadastro de eventos
      CURSOR cr_crapedp IS
      SELECT cdevento, nmevento
        FROM crapedp
       WHERE (cdcooper = 0)
         AND (cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
         AND (nrseqtem = pr_nrseqtem OR pr_nrseqtem = 0)
       ORDER BY nmevento;
        
      rw_crapedp cr_crapedp%ROWTYPE;
      
      -- Cursor sobre os eventos da agenda 
      CURSOR cr_crapedp_age IS
      SELECT DISTINCT edp.cdevento, edp.nmevento
        FROM crapedp edp,
             crapeap eap
       WHERE (edp.cdcooper = eap.cdcooper)
         AND (eap.cdevento = edp.cdevento)
         AND (edp.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
         AND (edp.cdeixtem = pr_cdeixtem OR pr_cdeixtem = 0)
         AND (edp.nrseqtem = pr_nrseqtem OR pr_nrseqtem = 0)
         AND (eap.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
       ORDER BY edp.nmevento;
        
      rw_crapedp_age cr_crapedp_age%ROWTYPE;
            
      -- Cursor sobre os eventos da agenda 
      CURSOR cr_crapedp_coop_age(pr_cdcoop_agenci IN VARCHAR2) IS
      SELECT DISTINCT edp.cdevento, edp.nmevento
        FROM crapedp edp,
             crapeap eap
       WHERE (edp.cdcooper = eap.cdcooper)
         AND (eap.cdevento = edp.cdevento)
         AND (edp.cdcooper|| '|' ||eap.cdagenci = pr_cdcoop_agenci OR pr_cdcoop_agenci = '0')
       ORDER BY edp.nmevento;
        
      rw_crapedp_coop_age cr_crapedp_coop_age%ROWTYPE;   
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
      arr_agencias GENE0002.typ_split;      
      vr_cdcopage crapcop.cdcooper%TYPE;
    
    BEGIN
          
      IF ( pr_cdagenci <> '0' ) THEN

        IF ( instr(pr_cdagenci, '|') > 0 ) THEN
          
          arr_agencias := GENE0002.fn_quebra_string(pr_string => pr_cdagenci, pr_delimit => ',');           
          
          FOR vr_cdcopage IN arr_agencias.FIRST..arr_agencias.LAST LOOP    

            FOR rw_crapedp_coop_age IN cr_crapedp_coop_age(arr_agencias(vr_cdcopage)) LOOP
                            
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_coop_age.cdevento, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_coop_age.nmevento, pr_des_erro => vr_dscritic);
              vr_contador := vr_contador + 1;
                          
            END LOOP;
            
          END LOOP;      
            
        ELSE
        
          FOR rw_crapedp_age IN cr_crapedp_age LOOP
                        
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_age.cdevento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_age.nmevento, pr_des_erro => vr_dscritic);
            vr_contador := vr_contador + 1;
                      
          END LOOP;
          
        END IF;
        
      ELSE -- lista eventos raiz
    
        FOR rw_crapedp IN cr_crapedp LOOP                  
        
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
            
        END LOOP;
      
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em PRGD0001.PC_LISTA_EVENTO: ' || SQLERRM;
        pr_dscritic := 'Erro geral em PRGD0001.PC_LISTA_EVENTO: ' || SQLERRM;
    END;

  END pc_lista_evento;
  
  /* Procedure para retornar data base da agenda da cooperativa */
  PROCEDURE pc_retanoage(pr_cdcooper IN VARCHAR2     --> Codigo da Cooperativa
                        ,pr_idevento IN VARCHAR2     --> Ide do evento
                        ,pr_dtanoage IN VARCHAR2     --> Ano agenda
                        ,pr_xmllog   IN VARCHAR2     --> XML com informa��es de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                        ,pr_dscritic OUT VARCHAR2    --> Descri��o da cr�tica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2    --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS--> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_retanoage
    --  Sistema  : Rotinas gerais
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Procedure para retornar data base da agenda da cooperativa
    --
    --  Alteracoes: 
    --              
    -- .............................................................................
    
    -- Cursores
    --> Buscar agenda da cooperativa
    CURSOR cr_gnpapgd IS
      SELECT /*+index_desc (gnpapgd GNPAPGD##GNPAPGD1 )*/
             dtanonov,
             dtanoage
        FROM gnpapgd 
       WHERE gnpapgd.idevento = pr_idevento
         AND gnpapgd.cdcooper = pr_cdcooper     
         AND ( pr_dtanoage IS NULL OR
              (pr_dtanoage IS NOT NULL AND 
               gnpapgd.dtanonov = pr_dtanoage)
             );
    
    rw_gnpapgd cr_gnpapgd%ROWTYPE;    
      
    vr_dtanoage gnpapgd.dtanoage%TYPE;
    
  BEGIN
  
    --> Buscar agenda da cooperativa
    OPEN cr_gnpapgd;
    FETCH cr_gnpapgd INTO rw_gnpapgd;
    IF cr_gnpapgd%NOTFOUND THEN      
      pr_dscritic := 'Nao existe agenda para o ano ('|| pr_dtanoage ||') informado!';
      RETURN;        
    ELSE
      --> Se nao informou data como parametro
      IF pr_dtanoage IS NULL THEN
        vr_dtanoage := rw_gnpapgd.dtanoage;
      ELSE
        vr_dtanoage := rw_gnpapgd.dtanonov;   
      END IF;
       
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><dtanoage>' || vr_dtanoage || '</dtanoage></Root>');
                                     
    END IF;    
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em PRGD0001.pc_retanoage: ' || SQLERRM;
      pr_dscritic := 'Erro geral em PRGD0001.pc_retanoage: ' || SQLERRM;

  END pc_retanoage;  
  
  --> Rotina de envio de email de eventos sem local de realiza��o
  PROCEDURE pc_envia_email_evento_local(pr_dscritic OUT VARCHAR2)  IS
    -- ..........................................................................
    --
    --  Programa : pc_envia_email_evento_local
    --  Sistema  : Rotinas gerais
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Procedure envio de email de eventos sem local de realiza��o
    --
    --  Alteracoes: 
    --              
    -- .............................................................................

    --------> CURSORES <--------
    -- Cursor para buscar a quantidade de dias e os endere�os de email para envio 
    CURSOR cr_parametro IS
      SELECT cp.cdcooper
            ,cp.dsemlesl
            ,cp.qtdiapee
            ,cp.qtdiasee
            ,cp.qtdiatee
        FROM crapppc cp
       WHERE cp.idevento = 1
         AND cp.dtanoage = (SELECT MAX(g.dtanoage)
                              FROM gnpapgd g
                             WHERE g.idevento = cp.idevento
                               AND g.cdcooper = cp.cdcooper)
     ORDER BY cp.cdcooper;
                       
    -- Cursor para verificar se existem eventos sem local de realiza��o informado
    CURSOR cr_evento(pr_qtdiaeml in number,pr_cdcooper in number) IS
      SELECT ca.nmresage
            ,ce.nmevento
            ,ce.cdevento
            ,c.dtinieve
            ,c.dtanoage
            ,c.cdcooper
            ,co.nmrescop
            ,TRIM(ca.dsdemail) dsdemail
        FROM crapadp c
            ,crapedp ce
            ,crapage ca
            ,crapcop co
       WHERE c.idstaeve IN (1, 3, 6) --1 - AGENDADO, 3 - TRANSFERIDO, 6 - ACRESCIDO 
         AND trunc(c.dtinieve) = trunc(SYSDATE + pr_qtdiaeml)
         AND c.cdcooper = pr_cdcooper
         AND nvl(c.cdlocali, 0) = 0
         AND ce.idevento = 1
         AND ce.tpevento NOT IN (10, 11) -- EAD
         AND ce.idevento = c.idevento
         AND ce.cdcooper = c.cdcooper
         AND ce.dtanoage = c.dtanoage
         AND ce.cdevento = c.cdevento
         AND ca.cdcooper = c.cdcooper
         AND ca.cdagenci = c.cdagenci
         AND co.cdcooper = c.cdcooper
       ORDER BY 1,2,3;

    -- Vari�vel de cr�ticas
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    
    -- Variaveis gerais
    vr_dstexto  VARCHAR2(5000); --> Texto que sera enviado no email
    vr_emaildst VARCHAR2(400);  --> Endereco do e-mail de destino
    vr_assunto  VARCHAR2(200);  --> Assunto do email
    vr_dscorpo  VARCHAR2(5000); --> Corpo que sera enviado no email  
  
    -- Gerar log
    PROCEDURE pc_gera_log (pr_dscritic IN VARCHAR2) IS
    BEGIN
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - PRGD0001.pc_envia_email_evento_local --> ' || pr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
    END pc_gera_log;
  
  BEGIN

    -------------------------------------------------------------
    -- Esta Rotina dever� ser executada a 01:00 horas da manha --
    -------------------------------------------------------------
    --> Buscar parametriza��o por cooperativa
    FOR rw_parametro in cr_parametro LOOP
      -- Primeiro envio de email
      -- Busca os eventos para envio do email
      FOR rw_evento in cr_evento(pr_qtdiaeml => rw_parametro.qtdiapee,
                                 pr_cdcooper => rw_parametro.cdcooper) LOOP
        
        BEGIN  
          vr_assunto := 'Evento sem local cadastrado � ' || rw_evento.nmrescop;
          vr_dscorpo :=  'O evento <b>'||rw_evento.nmevento||'</b> do dia '||to_char(rw_evento.dtinieve,'dd/mm/yyyy')||
                         ' do PA '||rw_evento.nmresage ||' n�o possui local de realiza��o informado.<br><br>';
          vr_dscorpo :=  vr_dscorpo||'Caso haja a necessidade de alguma altera��o, por favor, envie sua solicita��o via Softdesk o quanto antes.<br>';

          -- Se existe endere�o de email
          -- Envia o email para o respons�vel do PA
          IF rw_evento.dsdemail is not null THEN
                    
            -- Destinat�rio do email
            vr_emaildst := rw_evento.dsdemail;      
            vr_dstexto := '<b>ATEN��O!</b><br><br>';
            vr_dscorpo := vr_dstexto || vr_dscorpo; 
            
          ELSE
            -- Se o PA n�o tem email cadastrado, envia o email para o endere�o cadastrado na tela de parametros do progrid
            vr_emaildst:= rw_parametro.dsemlesl;

            vr_dstexto := '<b>ESTE AVISO FOI GERADO POIS O PA EST� SEM ENDERE�O DE E-MAIL CADASTRADO NO SISTEMA.</b><br><br>';
            vr_dstexto :=  vr_dstexto||'Favor encaminhar ao respons�vel para provid�ncias da seguinte pend�ncia:<br><br>';
            
            vr_dscorpo := vr_dstexto || vr_dscorpo;            
            vr_dscorpo := vr_dscorpo||'* Pedimos tamb�m que seja informado o e-mail de contato do PA.<br>';

          END IF;
                                 
          -- Se existe evento sem local, envia o email
          IF vr_dscorpo IS NOT NULL AND 
            vr_emaildst IS NOT NULL THEN
            -- Enviar e-mail dos dados deste sinistro
            gene0003.pc_solicita_email(pr_cdprogra        => 'PRGD0001' --> Programa conectado
                                      ,pr_des_destino     => vr_emaildst --> Um ou mais detinat�rios separados por ';' ou ','
                                      ,pr_des_assunto     => vr_assunto --> Assunto do e-mail
                                      ,pr_des_corpo       => vr_dscorpo --> Corpo (conteudo) do e-mail
                                      ,pr_des_anexo       => NULL --> Um ou mais anexos separados por ';' ou ','
                                      ,pr_flg_remove_anex => NULL --> Remover os anexos passados
                                      ,pr_flg_log_batch   => NULL --> Incluir no log a informa��o do anexo?
                                      ,pr_flg_enviar      => 'N'  --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic) ;                                  
            -- Caso encontre alguma critica no envio do email                          
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
              pc_gera_log (pr_dscritic => vr_dscritic);
              vr_dscritic := NULL;
              continue;
            END IF;
          END IF;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
            pc_gera_log (pr_dscritic => vr_dscritic);
            vr_dscritic := NULL;
            continue; 
        END;
          
      END LOOP;
      
      -- SEGUNDO ENVIO DO EMAIL
      -- Busca os eventos para envio do email
      FOR rw_evento in cr_evento(pr_qtdiaeml => rw_parametro.qtdiasee,
                                 pr_cdcooper => rw_parametro.cdcooper) LOOP
      
        BEGIN  
          vr_assunto := '2� aviso - Evento sem local cadastrado � ' || rw_evento.nmrescop;        
          vr_dscorpo := ' <b>Este � o segundo aviso que o Posto de Atendimento est� recebendo.</b><br><br>';
          vr_dscorpo := vr_dscorpo || 'O evento <b>'||rw_evento.nmevento||'</b> do dia '||to_char(rw_evento.dtinieve,'dd/mm/yyyy')||
                         ' do PA '||rw_evento.nmresage ||' ainda n�o possui local de realiza��o informado.<br><br>';
          vr_dscorpo :=  vr_dscorpo||'Solicitamos que, por gentileza, seja cadastrado para evitarmos problemas futuros.<br>';
          
          -- Se existe endere�o de email
          -- Envia o email para o respons�vel do PA
          IF rw_evento.dsdemail is not null THEN
            
            -- Destinat�rio do email
            vr_emaildst := rw_evento.dsdemail;  
            IF rw_parametro.dsemlesl IS NOT NULL THEN
               vr_emaildst := vr_emaildst||';'||rw_parametro.dsemlesl;      
            END IF;
                
            vr_dstexto := '<b>ATEN��O!</b><br><br>';        
            vr_dscorpo := vr_dstexto || vr_dscorpo; 
            
          ELSE
            
            -- Se o PA n�o tem email cadastrado, envia o email para o endere�o cadastrado na tela de parametros do progrid
            vr_emaildst:=rw_parametro.dsemlesl;

            vr_dstexto := '<b>ESTE AVISO FOI GERADO POIS O PA EST� SEM ENDERE�O DE E-MAIL CADASTRADO NO SISTEMA.</b><br><br>';
            vr_dstexto :=  vr_dstexto||'Favor encaminhar ao respons�vel para provid�ncias da seguinte pend�ncia:<br><br>';
            
            vr_dscorpo := vr_dstexto || vr_dscorpo;        
            vr_dscorpo :=  vr_dscorpo||'* Pedimos tamb�m que seja informado o e-mail de contato do PA.<br>';
            
          END IF;
                                 
          -- Se existe evento sem local, envia o email
          IF vr_dscorpo IS NOT NULL AND 
             vr_emaildst IS NOT NULL THEN
            -- Enviar e-mail dos dados deste sinistro
            gene0003.pc_solicita_email(pr_cdprogra        => 'PRGD0001' --> Programa conectado
                                      ,pr_des_destino     => vr_emaildst --> Um ou mais detinat�rios separados por ';' ou ','
                                      ,pr_des_assunto     => vr_assunto --> Assunto do e-mail
                                      ,pr_des_corpo       => vr_dscorpo --> Corpo (conteudo) do e-mail
                                      ,pr_des_anexo       => NULL --> Um ou mais anexos separados por ';' ou ','
                                      ,pr_flg_remove_anex => NULL --> Remover os anexos passados
                                      ,pr_flg_log_batch   => NULL --> Incluir no log a informa��o do anexo?
                                      ,pr_flg_enviar      => 'N'  --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic) ;                                  
            -- Caso encontre alguma critica no envio do email                          
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
              pc_gera_log (pr_dscritic => vr_dscritic);
              vr_dscritic := NULL;
              continue;
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
            pc_gera_log (pr_dscritic => vr_dscritic);
            vr_dscritic := NULL;
            continue; 
        END;  
      END LOOP;
      
       -- TERCEIRO ENVIO DO EMAIL
      -- Busca os eventos para envio do email
      FOR rw_evento in cr_evento(pr_qtdiaeml => rw_parametro.qtdiatee,
                                 pr_cdcooper => rw_parametro.cdcooper) LOOP
        
        BEGIN  
          vr_assunto := 'Aviso final - Evento sem local cadastrado - ' || rw_evento.nmrescop;        
          vr_dscorpo := ' <b>J� foram enviados dois comunicados ao Posto de Atendimento.</b><br><br>';        
          vr_dscorpo :=  vr_dscorpo||'Ainda n�o foi efetuado o cadastro de local para o evento <b>'||rw_evento.nmevento||'</b> do dia '||to_char(rw_evento.dtinieve,'dd/mm/yyyy')||
                         ' do PA '||rw_evento.nmresage ||'.<br><br>';
          --vr_dscorpo :=  vr_dscorpo||'Caso n�o seja cadastrado o local, n�o haver� a impress�o do material de divulga��o.<br>';
          vr_dscorpo :=  vr_dscorpo||'Caso o local n�o seja cadastrado HOJE, teremos problemas na impress�o dos'
                         || ' materiais de divulga��o e na comunica��o com os convidados e ministrantes.<br>';
          
          -- Se existe endere�o de email
          -- Envia o email para o respons�vel do PA
          IF rw_evento.dsdemail is not null THEN
            
            -- Destinat�rio do email
            vr_emaildst := rw_evento.dsdemail;
            IF rw_parametro.dsemlesl IS NOT NULL THEN
               vr_emaildst := vr_emaildst||';'||rw_parametro.dsemlesl;      
            END IF;   
            vr_dstexto := '<b><font color = "FF0000">ATEN��O!</font></b><br><br>';
            
            vr_dscorpo := vr_dstexto || vr_dscorpo; 
          ELSE
            
            -- Se o PA n�o tem email cadastrado, envia o email para o endere�o cadastrado na tela de parametros do progrid
            vr_emaildst:=rw_parametro.dsemlesl;
            vr_dstexto := '<b>ESTE AVISO FOI GERADO POIS O PA EST� SEM ENDERE�O DE E-MAIL CADASTRADO NO SISTEMA.</b><br><br>';

            vr_dstexto := vr_dstexto||'Favor encaminhar ao respons�vel para provid�ncias da seguinte pend�ncia:<br><br>';        
            vr_dscorpo := vr_dstexto || vr_dscorpo;        
            vr_dscorpo := vr_dscorpo||'* Pedimos tamb�m que seja informado o e-mail de contato do PA.<br>';
            
          END IF;
                                 
          -- Se existe evento sem local, envia o email
          IF vr_dscorpo IS NOT NULL AND 
             vr_emaildst IS NOT NULL THEN
            -- Enviar e-mail dos dados deste sinistro
            gene0003.pc_solicita_email(pr_cdprogra        => 'PRGD0001' --> Programa conectado
                                      ,pr_des_destino     => vr_emaildst --> Um ou mais detinat�rios separados por ';' ou ','
                                      ,pr_des_assunto     => vr_assunto --> Assunto do e-mail
                                      ,pr_des_corpo       => vr_dscorpo --> Corpo (conteudo) do e-mail
                                      ,pr_des_anexo       => NULL --> Um ou mais anexos separados por ';' ou ','
                                      ,pr_flg_remove_anex => NULL --> Remover os anexos passados
                                      ,pr_flg_log_batch   => NULL --> Incluir no log a informa��o do anexo?
                                      ,pr_flg_enviar      => 'N'  --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic) ;                                  
            -- Caso encontre alguma critica no envio do email                          
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
              pc_gera_log (pr_dscritic => vr_dscritic);
              vr_dscritic := NULL;
              continue;
            END IF;
          END IF;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel enviar email sobre o evento '||rw_evento.cdevento||': '||vr_dscritic;
            pc_gera_log (pr_dscritic => vr_dscritic);
            vr_dscritic := NULL;
            continue; 
        END;
      END LOOP;
      
    END LOOP;
    
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Atualiza variavel de retorno
      pr_dscritic := vr_dscritic;
      pc_gera_log (pr_dscritic => vr_dscritic);
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_dscritic := sqlerrm;
      pc_gera_log (pr_dscritic => vr_dscritic);    
  END pc_envia_email_evento_local;

  /* Informa��o do modulo em execu��o na sess�o */
  PROCEDURE pc_informa_acesso_progrid(pr_module IN VARCHAR2
                                     ,pr_action IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    CECRED.GENE0001.pc_informa_acesso(pr_module => pr_module
                                     ,pr_action => pr_action);

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';

  END pc_informa_acesso_progrid;

END PRGD0001;
/
