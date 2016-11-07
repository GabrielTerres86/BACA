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
  -- Objetivo  : Criar interface e validações necessárias para intercambio de dados para o sistema PROGRID
  --
  --        Alteracoes: 29/10/2015 - Incluido nova condicao na busca de Regionais,
  --                                 "AND reg.cddregio NOT IN (9,999)" (Jean Michel). 
  --                                 
  --                    19/10/2016 - Incluido chamada da pc_informa_acesso_progrid na
  --                                 procedure pc_redir_acao_prgd para registro de LOG 
  --                                 em qualquer acesso as rotinas (Jean Michel)
  ---------------------------------------------------------------------------------------------------------------

  -- Procedure que será a interface entre o Oracle e sistema Web
  PROCEDURE pc_xml_web_prgd(pr_xml_req IN CLOB --> Arquivo XML de retorno
                           ,
                            pr_xml_res OUT NOCOPY CLOB); --> Arquivo XML de resposta

  -- Procedure para gerenciar a extração de dados do XML de envio
  PROCEDURE pc_extrai_dados_prgd(pr_xml      IN xmltype --> XML com dados para LOG
                                ,
                                 pr_cdcooper OUT NUMBER --> Código da cooperativa
                                ,
                                 pr_cdoperad OUT VARCHAR2 --> Operador
                                ,
                                 pr_nmdatela OUT VARCHAR2 --> Nome da tela
                                ,
                                 pr_nmdeacao OUT VARCHAR2 --> Nome da ação
                                ,
                                 pr_idcokses OUT VARCHAR2 --> ID do Cookie da sessao
                                ,
                                 pr_idsistem OUT INTEGER --> ID do Sistema
                                ,
                                 pr_cddopcao OUT VARCHAR2 --> Codigo da opcao
                                ,
                                 pr_dscritic OUT VARCHAR2); --> Descrição da crítica

  -- Procedure para listar as cooperativas do sistema
  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,
                                  pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo         
                                 ,
                                  pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,
                                  pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,
                                  pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                               pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,
                               pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,
                               pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2); --> Descricao do Erro

  /* Procedure para listar os eixos do sistema */
  PROCEDURE pc_lista_eixo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro                        
                         
                         
  /* Procedure para listar os temas do sistema */
  PROCEDURE pc_lista_tema(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                         ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                         
  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_evento(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                           ,pr_cdagenci IN VARCHAR2              --> Codigo da Agencia (PA)    
                           ,pr_cdeixtem IN gnapetp.cdeixtem%TYPE --> Codigo do Eixo
                           ,pr_nrseqtem IN craptem.nrseqtem%TYPE --> Codigo do Tema
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                           
  /* Procedure para retornar data base da agenda da cooperativa */
  PROCEDURE pc_retanoage(pr_cdcooper IN VARCHAR2     --> Codigo da Cooperativa
                        ,pr_idevento IN VARCHAR2     --> Ide do evento
                        ,pr_dtanoage IN VARCHAR2     --> Ano agenda
                        ,pr_xmllog   IN VARCHAR2     --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2    --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2    --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);  --> Descricao do Erro
                        
  /* Informação do modulo em execução na sessão do Progrid */
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
  --  Objetivo  : Criar interface e validações necessárias para intercambio de dados
  --
  --  Notas: Obrigatoriamente a estrutura de parâmetros deverá ser a seguinte:
  --
  --        (..., pr_xmllog, pr_cdcritic, pr_dscritic, pr_retxml, pr_nmdcampo, pr_des_erro)
  --
  --        Estes parâmetros devem estar sempre presentes e na ordem apresentada para padronizar
  --        O retorno das execuções dinâmicas para o sistema Web.
  --
  --        - pr_xmllog: Arquivo XML com inforamções para LOG interno
  --        - pr_cdcritic: código da crítica, se houver
  --        - pr_dscritic: descrição da crítica, se houver
  --        - pr_retxml: XML de retorno, retorno obrigatório
  --        - pr_nmdcampo: nome do campo executor, se houver
  --        - pr_des_erro: erros de execução da rotina, se houver
  --
  --        Alteracoes: 29/10/2015 - Incluido nova condicao na busca de Regionais,
  --                                 "AND reg.cddregio NOT IN (9,999)" (Jean Michel).
  --
  --                    19/10/2016 - Incluido chamada da pc_informa_acesso_progrid na
  --                                 procedure pc_redir_acao_prgd para registro de LOG 
  --                                 em qualquer acesso as rotinas (Jean Michel)
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
    
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
    
      -- Se não encontrar registro para a cooperativa
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
  PROCEDURE pc_valida_acesso_sistema_prgd(pr_cdcooper IN crapace.cdcooper%TYPE  --> Código da cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do operador
                                         ,pr_idsistem IN craptel.idsistem%TYPE  --> Identificador do sistema
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                         ,pr_dsdepart OUT crapope.dsdepart%TYPE --> Descrição do departamento
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código de retorno
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descrição do retorno
    -- ..........................................................................
    --
    --  Programa : pc_valida_acesso_sistema_prgd
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Valida permissão para os objetos envolvidos na execução.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida EXCEPTION; --> Controle de saída
      vr_arquivo    VARCHAR2(400); --> Variável para retorno da busca de arquivo de bloqueio
      vr_arquivo_so VARCHAR2(400); --> Variável para retorno da busca de arquivo de bloqueio
      vr_dsdircop   VARCHAR2(100);
      
      -- Busca dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS --> Código da cooperativa
        SELECT cop.cdcooper
               ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Busca dados do cadastro dos operadores
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE --> Código da cooperativa
                       ,
                        pr_cdoperad IN crapope.cdoperad%TYPE) IS --> Código do operador
        SELECT pe.dsdepart
          FROM crapope pe
         WHERE pe.cdcooper = pr_cdcooper
           AND upper(pe.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;
    
      -- Busca dados do cadastro de telas
      CURSOR cr_craptel(pr_cdcooper IN craptel.cdcooper%TYPE --> Código da cooperativa
                       ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                       ,pr_idsistem IN craptel.idsistem%TYPE) IS --> identificador no sistema
        SELECT el.inacesso, el.idambtel, el.flgtelbl
          FROM craptel el
         WHERE el.cdcooper = pr_cdcooper
           AND el.nmdatela = pr_nmdatela
           AND el.idsistem = pr_idsistem;
      rw_craptel cr_craptel%ROWTYPE;
    
      -- Busca dados do cadastro dos programas
      CURSOR cr_crapprg(pr_cdcooper IN crapprg.cdcooper%TYPE --> Código da cooperativa
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
    
      -- Se não encontrar registro
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
    
      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        pr_cdcritic := 67;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        pr_dsdepart := rw_crapope.dsdepart;
        CLOSE cr_crapope;
      END IF;
    
      -- Verifica se a tela está cadastrada no sistema
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
    
      -- Verifica se o programa está cadastrado
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
    
       /* Pega o caminho absoluto */
      vr_dsdircop:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper);
                             
      -- Verifica se encontrou o caminho
      IF vr_dsdircop IS NULL THEN
        pr_dscritic := 'Caminho invalido.';
        RAISE vr_exc_saida;
      END IF;
                     
      -- Monta caminho para localizar restrição de uso
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'cred_bloq'
                                ,pr_listarq => vr_arquivo
                                ,pr_des_erro => pr_dscritic);
    
      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        pr_cdcritic := 999;
        RAISE vr_exc_saida;
      END IF;
    
      -- Pesquisar pasta por arquivo de liberação
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdircop || '/arquivos'
                                ,pr_pesq     => 'so_consulta'
                                ,pr_listarq  => vr_arquivo_so
                                ,pr_des_erro => pr_dscritic);
    
      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        pr_cdcritic := 999;
        RAISE vr_exc_saida;
      END IF;
    
      -- Verifica se existe arquivo para controle de bloqueio
      IF vr_arquivo IS NOT NULL THEN
        pr_cdcritic := 999;
        pr_dscritic := 'Sistema Bloqueado. Tente mais tarde!!!';
        RAISE vr_exc_saida;
      END IF;
    
      -- Se não gerar consistência limpa críticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro em PRGD0001.PC_VALIDA_ACESSO_SISTEMA_PRGD. Erro: ' || pr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em PRGD0001.PC_VALIDA_ACESSO_SISTEMA_PRGD: ' || SQLERRM;
    END;
  END pc_valida_acesso_sistema_prgd;

  /* Procedure para verificar a permissão no momento da requisição */
  PROCEDURE pc_verifica_permis_oper_prgd(pr_cdcooper IN crapace.cdcooper%TYPE      --> Código da cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Código do operador
                                        ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                        ,pr_cddopcao IN crapace.cddopcao%TYPE      --> Código da opção                                          
                                        ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE) IS --> Código da crítica
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
    --   Objetivo  : Verifica permissão para os objetos envolvidos na execução.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida EXCEPTION; --> Controle de erros
      vr_dsdepart crapope.dsdepart%TYPE; --> Descrição do departamento
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
           AND upper(ce.cdoperad) = upper(pr_cdoperad)
           AND upper(ce.nmdatela) = upper(pr_nmdatela)
           AND ce.cddopcao = pr_cddopcao
           AND ce.idambace = 3;
    
      vr_nmdatela crapace.nmdatela%TYPE;
    
    BEGIN
    
      -- Valida o acesso ao sistema
      pc_valida_acesso_sistema_prgd(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_idsistem => pr_idsistem
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_dsdepart => vr_dsdepart
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
    
      -- Verifica se ocorreram erros de execução
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Verifica qual é o departamento de operação
      IF vr_dsdepart <> 'TI' THEN
        -- Verifica as permissões de execução no cadastro
        OPEN cr_crapace(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_cddopcao);
        FETCH cr_crapace
          INTO vr_nmdatela;
        -- Verifica se foi encontrada permissão
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

  /* Procedure para controlar o processo de validação de execução */
  PROCEDURE pc_executa_metodo_prgd(pr_xml      IN OUT xmltype   --> Documento XML
                                  ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
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
    --   Objetivo  : Validar acesso em tempo de execução.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE
      rw_crapdat btch0001.cr_crapdat%ROWTYPE; --> Cursor com dados da data
      vr_exc_saida EXCEPTION; --> Controle de saída
      vr_exc_null  EXCEPTION; --> Controle de saída
    
    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper'));
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
    
      -- Se não encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
      
        pr_cdcritic := 999;
        pr_dscritic := 'Sistema sem data de movimento.';
      
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
    
      IF gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'nmdeacao') NOT IN('LISTA_COOPER','LISTA_REGIONAIS','LISTA_PA') THEN
        -- Valida permissão de execução
        pc_verifica_permis_oper_prgd(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper')
                                    ,pr_cdoperad => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdoperad')
                                    ,pr_idsistem => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'idsistem')
                                    ,pr_nmdatela => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'nmdatela')
                                    ,pr_cddopcao => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag  => 'cddopcao')
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);
    
        -- Verifica se ocorreram erros na validação
        IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_null;
        END IF;
      END IF;
    
      -- Libera acesso a tela indicando que não existe crítica
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

  -- Procedure para gerenciar a extração de dados do XML de envio
  PROCEDURE pc_extrai_dados_prgd(pr_xml      IN xmltype       --> XML com dados para LOG
                                ,pr_cdcooper OUT NUMBER       --> Código da cooperativa
                                ,pr_cdoperad OUT VARCHAR2     --> Operador
                                ,pr_nmdatela OUT VARCHAR2     --> Nome da tela
                                ,pr_nmdeacao OUT VARCHAR2     --> Nome da ação
                                ,pr_idcokses OUT VARCHAR2     --> ID do Cookie da sessao
                                ,pr_idsistem OUT INTEGER      --> ID do Sistema
                                ,pr_cddopcao OUT VARCHAR2     --> Codigo da opcao
                                ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
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
    --   Objetivo  : Extrair dados do XML de requisição.
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
  FUNCTION fn_cria_xml_log_prd(pr_cdcooper IN NUMBER                       --> Código da cooperativa
                              ,pr_nmdatela IN VARCHAR2                     --> Nome da tela
                              ,pr_nmdeacao IN VARCHAR2                     --> Nome da ação
                              ,pr_idorigem IN VARCHAR2                     --> Identificação de origem
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
    --   Objetivo  : Gerar XML com dados para criação de LOG interno nas rotinas executadas.
    --
    --   Alteracoes:
    -- .............................................................................
  BEGIN
    BEGIN
      RETURN '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><params>' || '<nmdatela>' || pr_nmdatela || '</nmdatela>' || '<cdcooper>' || pr_cdcooper || '</cdcooper>' || '<idorigem>' || pr_idorigem || '</idorigem>' || '<cdoperad>' || pr_cdoperad || '</cdoperad>' || '<nmdeacao>' || pr_nmdeacao || '</nmdeacao></params></Root>';
    END;
  END;

  -- Procedure para controlar o redirecionamento das operações
  PROCEDURE pc_redir_acao_prgd(pr_xml      IN OUT NOCOPY xmltype 	      --> Sequencia de cadastro da solicitação de execução
                              ,pr_nrseqsol IN OUT crapsrw.nrseqsol%TYPE --> Sequencia do histórico de execução
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                 --> Descrição da crítica
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
    --   Objetivo  : Gerar chamada para a package/procedure de execução do processo de backend.
    --
    --   Alteracoes: 30/04/2014 - Implementação do cadastro de ações para execução (Petter - Supero).
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
      vr_sql   VARCHAR2(32000); --> SQL dinâmico para montagem de execuções personalizadas
      vr_param gene0002.typ_split; --> Lista de strings quebradas por delimitador
      vr_exc_erro     EXCEPTION; --> Controle de exceção
      vr_exc_null     EXCEPTION; --> Controle de exceção
      vr_exc_problema EXCEPTION; --> Controle de exceção
      vr_xpath    VARCHAR2(400); --> XPath da tag do arquivo XML
      vr_cdcooper NUMBER; --> Código da cooperativa
      vr_nmdatela VARCHAR2(100); --> Nome da tela/programa que será executado
      pr_sequence NUMBER; --> Sequencia de gravação do LOG
      vr_nmdeacao VARCHAR2(100); --> Ação que será executada para a tela
      vr_cdoperad VARCHAR2(100); --> Operador
      vr_xmllog   VARCHAR2(32767); --> XML para propagar informações de LOG
      vr_dscritic VARCHAR2(4000); --> Descricao do Erro
      vr_idcokses VARCHAR2(100); -- ID do cookie da sessao
      vr_cddopcao VARCHAR2(100); -- Tipo da opcao
      vr_idsistem INTEGER(2) := 0; -- ID do sistema que esta sendo utilizado
    
      -- Busca qual package/procedure deverá ser executada
      CURSOR cr_craprdr(pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela de execucao
                       ,pr_nmdeacao IN crapaca.nmdeacao%TYPE) IS --> Nome da ação de execucao
      
        SELECT ca.nmpackag, ca.nmproced, ca.lstparam
          FROM craprdr cr, crapaca ca
         WHERE ca.nrseqrdr = cr.nrseqrdr
           AND (upper(cr.nmprogra) LIKE upper(pr_nmdatela) OR
               pr_nmdatela IS NULL)
           AND upper(ca.nmdeacao) LIKE upper(pr_nmdeacao);
    
      rw_craprdr cr_craprdr%ROWTYPE;
    
    BEGIN
      -- Extrair dados do XML de requisição
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
    
      -- Gravar solicitação
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
    
      -- Busca os dados da execução solicitada
      OPEN cr_craprdr(vr_nmdatela, vr_nmdeacao);
      FETCH cr_craprdr
        INTO rw_craprdr;
    
      -- Verificar se existe package cadastrada para execução
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

      -- Verifica se existem parâmetros adicionais criados
      IF rw_craprdr.lstparam IS NOT NULL THEN
        -- Quebra a string de parametros
        vr_param := gene0002.fn_quebra_string(rw_craprdr.lstparam, ',');
      
        -- Itera sobre a string quebrada
        IF vr_param.count > 0 THEN
          FOR idx IN 1 .. vr_param.count LOOP
            -- Capturar valor do XPath do arquivo XML
            vr_xpath := '/Root/Dados/' || substr(vr_param(idx), 4, length(vr_param(idx))) || '/text()';
          
            -- Concatena o comando SQL, caso não exista valor na TAG gera parâmetro de valor NULL
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
    
      -- Ordem para executar de forma imediata o SQL dinâmico
      EXECUTE IMMEDIATE vr_sql USING OUT pr_cdcritic, OUT pr_dscritic, IN OUT pr_xml, OUT pr_nmdcampo, OUT vr_dscritic;
    
      -- Verifica se ocorreram erros
      IF vr_dscritic <> 'OK' THEN
        RAISE vr_exc_problema;
      END IF;
    
      -- Atualiza histórico com o XML de resposta
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

  -- Procedure que será a interface entre o Oracle e sistema Web
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
    --   Objetivo  : Gerenciar interface de comunicação (requisição/resposta) do sistema Web.
    --               Irá receber um arquivo XML com dados de manipulação e parâmetros de execução
    --               para acessar a package/procedure necessário e irá retornar um novo XML com
    --               mensagem de erro ou dados de retorno do processamento.
    --
    --   Alteracoes: 
    --
    -- .................................................................................................
  BEGIN
    DECLARE
    
      -- Variaveis de excessao e erro
      vr_exc_erro EXCEPTION; --> Controle de tratamento de erros personalizados
      vr_exc_libe EXCEPTION; --> Controle de erros para o processo de liberação
      vr_cdcritic crapcri.cdcritic%TYPE; --> Variavel para armazenar codigo do erro de execucao
      vr_dscritic VARCHAR2(4000); --> Variavel para armazenar descricao do erro de execucao
    
      -- Variaveis locais
      vr_cdcooper crapcop.cdcooper%TYPE; --> Código da cooperativa
      vr_nmdcampo VARCHAR2(150); --> Nome do campo da execução
      vr_nrseqsol NUMBER; --> Sequencia do histórico de execuções
      vr_conttag  PLS_INTEGER; --> Contador do número de ocorrências da TAG
      vr_xml      xmltype; --> Variável do XML de entrada
      vr_erro_xml xmltype; --> Variável do XML de erro
    
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
    
      -- Verifica se existe permissão de execucao da tela pelo usuario e hora
      IF vr_conttag > 0 THEN
        pc_executa_metodo_prgd(pr_xml      => vr_xml
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      END IF;
    
      -- Verifica se o controle de permissão gerou erro ou crítica
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar XML de erro
        gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                 ,pr_cdcooper => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag  => 'cdcooper')
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      
        RAISE vr_exc_libe;
      END IF;
    
      -- Gerar requisição para web
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
      
        -- Gerar XML com descrição do erro para exibição no sistema Web
        gene0004.pc_gera_xml_erro(pr_xml      => vr_erro_xml
                                 ,pr_cdcooper => vr_cdcooper
                                 ,pr_cdcritic => 0
                                 ,pr_dscritic => 'Erro: ' || vr_dscritic);
      
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getclobval();
      WHEN OTHERS THEN
        ROLLBACK;
      
        -- Gerar XML com descrição do erro para exibição no sistema Web
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
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
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
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
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
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
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
                        ,pr_xmllog   IN VARCHAR2     --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2    --> Descrição da crítica
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
    --
    --              
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
             )
             ;
    
    rw_gnpapgd cr_gnpapgd%ROWTYPE;    
    
    -- Variaveis de critica
    vr_dscritic crapcri.dscritic%TYPE;    
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
  
  /* Informação do modulo em execução na sessão */
  PROCEDURE pc_informa_acesso_progrid(pr_module IN VARCHAR2
                                     ,pr_action IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    CECRED.GENE0001.pc_informa_acesso(pr_module => pr_module
                                     ,pr_action => pr_action);
  END pc_informa_acesso_progrid;

END PRGD0001;
/
