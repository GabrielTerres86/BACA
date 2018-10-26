CREATE OR REPLACE PACKAGE CECRED.GENE0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0004
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 10/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar interface e validações necessárias para intercambio de dados
  --
  --  Alteracoes: 15/08/2014 - Adicionado TRIM na pc_extrai_dados (Jean Michel).
  --              31/07/2015 - Criada funcao generica fn_executa_job 
  --              10/06/2016 - Criada procedure pc_reagenda_job SD402010 (Tiago/Thiago).
  --
  --              13/04/2018 - 1 - Tratado Others na geração da tabela tbgen erro de sistema
  --                           2 - Seta Modulo
  --                           3 - Eliminada mensagem fixas
  --                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
  --                           5 - Criada PROCEDURE pc_trata_exec_job para tratar a descrição de criticas 
  --                               no sentido de não mais utilizar descrição como condição de decisão
  --                           6 - Modificada pc_executa_job para ser utilizada somente por rotinas 
  --                               ainda não alteradas nesse momento e ficaram pendentes
  --                           (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
  --
  --              27/08/2018 - Gerado o modulo e ação das rotinas disparadas 
  --                           Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
  --                           Também NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
  --                           (Envolti - Belli - Chamado REQ0024645)
  --
  --               10/09/2018 - Listar o XML no Log                           
  --                           (Envolti - Belli - Chamado REQ0025926)
  --  
  ---------------------------------------------------------------------------------------------------------------

  /* Definições das procedures de uso público */

  /* Procedure para verificar a permissão no momento da requisição */
  PROCEDURE pc_verifica_permissao_operacao(pr_cdcooper IN crapace.cdcooper%TYPE      --> Código da cooperativa
                                          ,pr_cdoperad IN VARCHAR2                   --> Código do operador
                                          ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                          ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                          ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                                          ,pr_cddopcao IN crapace.cddopcao%TYPE      --> Código da opção
                                          ,pr_inproces IN crapdat.inproces%TYPE      --> Identificador do processo
                                          ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                          ,pr_cdcritic OUT PLS_INTEGER);             --> Código da crítica

  /* Procedure para reagender job passando nome, nova data e novo horario*/
  PROCEDURE pc_reagenda_job(pr_job_name IN  Dba_Scheduler_Jobs.job_name%TYPE
                           ,pr_dtagenda IN  DATE
                           ,pr_hragenda IN  INTEGER
                           ,pr_mmagenda IN  INTEGER
                           ,pr_dscritic OUT VARCHAR2);

  /* Procedure que será a interface entre o Oracle e sistema Web */
  PROCEDURE pc_xml_web(pr_xml_req IN CLOB                --> Arquivo XML de retorno
                      ,pr_xml_res OUT NOCOPY CLOB);      --> Arquivo XML de resposta


  /* Procedure para gerenciar a extração de dados do XML de envio */
  PROCEDURE pc_extrai_dados(pr_xml      IN XMLType                      --> XML com descrição do erro
                           ,pr_cdcooper OUT NUMBER                      --> Código da cooperativa
                           ,pr_nmdatela OUT VARCHAR2                    --> Nome da tela
                           ,pr_nmeacao  OUT VARCHAR2                    --> Nome da ação
                           ,pr_cdagenci OUT VARCHAR2                    --> Agencia de operação
                           ,pr_nrdcaixa OUT VARCHAR2                    --> Número do caixa
                           ,pr_idorigem OUT VARCHAR2                    --> Identificação de origem
                           ,pr_cdoperad OUT VARCHAR2                    --> Operador
                           ,pr_dscritic OUT VARCHAR2);                  --> Descrição da crítica
                           
  /*Procedures de validacoes genericas para JOBs*/                         
  PROCEDURE pc_executa_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo 
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta s
                          ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                          ) ; 
  
  /* Procedure para inserir histórico de transações */
  PROCEDURE pc_insere_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                           ,pr_cdcooper IN NUMBER                    --> código da cooperativa
                           ,pr_nmdatela IN crapsrw.nmtelaex%TYPE     --> Tela de execução
                           ,pr_cdoperad  IN crapsrw.nmuserex%TYPE     --> Usuário solicitante
                           ,pr_sequence IN OUT NUMBER                --> Sequencia gerada do histórico
                           ,pr_nmdeacao IN crapsrw.nmacaoex%TYPE     --> Nome da ação executada
                           ,pr_dscritic OUT VARCHAR2) ;             --> Erros de execução    

  /* Procedure para atualizar histórico de transações */
  PROCEDURE pc_atualiza_trans(pr_xml      IN OUT NOCOPY XMLType    --> XML
                             ,pr_seq      IN OUT NUMBER            --> Sequencia gerada do histórico
                             ,pr_des_erro OUT VARCHAR2);           --> Erros de execução
 
  /* Gera XML com dados sobre o erro */
  PROCEDURE pc_gera_xml_erro(pr_xml      IN OUT NOCOPY XMLType               --> XML com descrição do erro
                            ,pr_cdcooper IN crapcop.cdcooper%TYPE            --> Código da cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 1  --> Código da agência
                            ,pr_nrsequen IN NUMBER DEFAULT 1                 --> Número da sequencia
                            ,pr_nrdcaixa IN NUMBER DEFAULT 0                 --> Número do caixa
                            ,pr_nmdcampo IN VARCHAR2 DEFAULT NULL            --> Nome do campo
                            ,pr_cdcritic IN crapcri.cdcritic%TYPE            --> Código da crítica
                            ,pr_dscritic IN VARCHAR2                         --> Descrição da crítica
                            ,pr_dscriret OUT VARCHAR2                        --> Retorna se deu erro
                            ); 
                    
  /*Procedures de validacoes genericas para JOBs*/                         
  PROCEDURE pc_trata_exec_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo 
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta s
                          ,pr_intipmsg OUT INTEGER                --> 1 Padrão, 2 Grupo de mensagens tratadas
                          ,pr_cdcritic OUT INTEGER                --> Codigo Critica
                          ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                          );

  /*Procedures Rotina de Log - tabela: tbgen prglog ocorrencia*/   
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'GENE0004'
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  );                          
END GENE0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0004
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 10/09/2018
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
  --  Alteracoes: 16/05/2014 - Adicionado procedures para permissão de execução.
  --
  --              15/08/2014 - Inserido TRIM na pc_extrai_dados (Jean Michel).
  --
  --              03/03/2015 - Alteracao do tamanho da variavel vr_sql para o max
  --                           do tipo varchar2 da pc_redir_acao (Tiago). 
  --
  --              03/05/2016 - Alterado paramtro fixo do tempo para reagendar a job para
  --                           buscar da crapprm (Lucas Ranghetti #412789)
  --
  --              11/05/2016 - Ajustado o cursor da procedure pc_verifica_permissao_operacao que 
  --                           busca dados do cadastro com permissoes de acesso as telas do 
  --                           sistema para utilizar o indice da tabela (Douglas - Chamado 450570)
  --
  --              06/06/2016 - Ajustes realizados:
  --                        -> Incluido upper nos campos que são indice da tabela craprdr
  --                        -> Incluido upper nos campos que são indice da tabela crapprg
  --                           (Adriano - SD 464741).
  --
  --              26/06/2016 - Correcao para o uso do indice no cursor sobre a craptel na 
  --                           procedure pc_valida_acesso_sistema.(Carlos Rafael Tanholi).
  --
  --              10/06/2016 - Criada procedure pc_reagenda_job SD402010 (Tiago/Thiago).
  --
  --              03/11/2016 - Ajuste na procedure pc_reagenda_job para reagendar o job com
  --                           o fusohorario do servidor que esta executando GMT (Tiago/Thiago SD532302)
  --
  --              29/11/2016 - P341 - Automatização BACENJUD - Alterado para validar o departamento à partir
  --                           do código e não mais pela descrição (Renato Darosci - Supero)
  --
  --              06/04/2017 - Criei novo cursor sobre a CRAPACE para ser executado sem o parametro nmrotina 
  --                           desta forma melhorando a performance. (Carlos Rafael Tanholi - SD 538898)  
  --
  --              13/04/2018 - 1 - Tratado Others na geração da tabela tbgen erro de sistema
  --                           2 - Seta Modulo
  --                           3 - Eliminada mensagem fixas
  --                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
  --                           5 - Criada PROCEDURE pc_trata_exec_job para tratar a descrição de criticas 
  --                               no sentido de não mais utilizar descrição como condição de decisão
  --                           6 - Modificada pc_executa_job para ser utilizada somente por rotinas 
  --                               ainda não alteradas nesse momento e ficaram pendentes
  --                           (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
  --
  --              27/08/2018 - Gerado o modulo e ação das rotinas disparadas 
  --                           Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
  --                           Também NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
  --                           (Envolti - Belli - Chamado REQ0024645)
  --
  --              10/09/2018 - Listar o XML no Log - GIT
  --                         - Mensagem para o usuário não levar parâmetros - 17/09/2018  
  --                         - Liberação via GIT                       
  --                          (Envolti - Belli - Chamado REQ0025926)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Procedures/functions de uso privado */

  /* Procedure para valiar o acesso ao sistema */
  PROCEDURE pc_valida_acesso_sistema(pr_cdcooper IN crapace.cdcooper%TYPE      --> Código da cooperativa
                                    ,pr_cdoperad IN VARCHAR2                   --> Código do operador
                                    ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                    ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                                    ,pr_inproces IN crapdat.inproces%TYPE      --> Indicador do processo
                                    ,pr_cddepart OUT crapope.cddepart%TYPE     --> Descrição do departamento
                                    ,pr_cdcritic OUT PLS_INTEGER               --> Código de retorno
                                    ,pr_dscritic OUT VARCHAR2) IS              --> Descrição do retorno
    -- ..........................................................................
    --
    --  Programa : pc_valida_acesso_sistema
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Objetivo  : Valida permissão para os objetos envolvidos na execução.
    --
    --   O Log é tratado pela chamadora GENE0004.pc_verifica_permissao_operacao (Unica chamadora)
    --
    --   Alteracoes: 04/09/2015 - Ajuste para retirar o uso do caminho absoluto fixado na rotina
    --                            (Adriano - SD 323620).
    --
    --               06/06/2016 - Ajustes realizados:
    --                            -> Incluido upper nos campos que são indice da tabela CRAPPRG
    --                            (Adriano - SD 464741).
    --
    --               26/06/2016 - Correcao para o uso do indice no cursor sobre a craptel na 
    --                            procedure pc_valida_acesso_sistema.(Carlos Rafael Tanholi).   
    --
    --               05/07/2016 - Realizado a retirada da chamada da FN_DIRETORIO com o intuíto de conseguir 
    --                            alguma melhora na performance das chamadas, visto que estavam sendo 
    --                            feitas muitas chamadas da função. Dúvidas sobre a alteração podem ser 
    --                            tratadas também com o Rodrigo Siewerdt. (Renato Darosci - Supero)
	--
	  --				       21/10/2016 - Ajustado cursor da craptel para não executar função desnecessariamente (Rodrigo)
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida  EXCEPTION;          --> Controle de saída
      vr_arquivo    VARCHAR2(400);      --> Variável para retorno da busca de arquivo de bloqueio
      vr_arquivo_so VARCHAR2(400);      --> Variável para retorno da busca de arquivo de bloqueio
      vr_dsdircop   VARCHAR2(100);
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_valida_acesso_sistema';
      
      -- Busca dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> Código da cooperativa
      /*SELECT cop.cdcooper  -- Renato Darosci (05/07/2016)
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;*/
      SELECT cop.cdcooper, prm.dsvlrprm||cop.dsdircop dsdircop
        FROM crapprm prm
           , crapcop cop
       WHERE prm.cdacesso = 'ROOT_DIRCOOP'
         AND cop.cdcooper =  DECODE(prm.cdcooper,0, cop.cdcooper, prm.cdcooper)
         AND prm.nmsistem = 'CRED'
         AND cop.cdcooper = pr_cdcooper
       ORDER BY prm.cdcooper DESC;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca dados do cadastro dos operadores
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS  --> Código do operador
      SELECT pe.cddepart
        FROM crapope pe
       WHERE UPPER(pe.cdoperad) = UPPER(pr_cdoperad)
         AND pe.cdcooper        = pr_cdcooper;
      rw_crapope cr_crapope%ROWTYPE;

      -- Busca dados do cadastro de telas
      CURSOR cr_craptel(pr_cdcooper IN craptel.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                       ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                       ,pr_idsistem IN craptel.idsistem%TYPE) IS  --> identificador no sistema
      SELECT el.inacesso
            ,el.idambtel
            ,el.flgtelbl
        FROM craptel el
       WHERE el.cdcooper = pr_cdcooper
         AND UPPER(el.nmdatela) = UPPER(pr_nmdatela)
         AND UPPER(el.nmrotina) = UPPER(pr_nmrotina)
         AND el.idsistem = pr_idsistem;
      rw_craptel cr_craptel%ROWTYPE;

      -- Busca dados do cadastro dos programas
      CURSOR cr_crapprg(pr_cdcooper IN crapprg.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nmdatela IN crapprg.cdprogra%TYPE) IS  --> Nome da tela
      SELECT rg.nmsistem
        FROM crapprg rg
       WHERE rg.cdcooper = pr_cdcooper
         AND UPPER(rg.cdprogra) = UPPER(pr_nmdatela)
         AND UPPER(rg.nmsistem) = 'CRED';

    BEGIN
      -- o Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar registro
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        /* Pega o caminho absoluto -- Renato Darosci (05/07/2016) */
        vr_dsdircop:= rw_crapcop.dsdircop;
        
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se existe operador cadastrado
      OPEN cr_crapope(pr_cdcooper, pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;

      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        pr_cdcritic := 67;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        pr_cddepart := rw_crapope.cddepart;
        CLOSE cr_crapope;
      END IF;

      -- Verifica se a tela está cadastrada no sistema
      OPEN cr_craptel(pr_cdcooper, pr_nmdatela, NVL(pr_nmrotina, ' '), pr_idsistem);
      FETCH cr_craptel INTO rw_craptel;

      -- Verifica se a tela foi encontrada
      IF cr_craptel%NOTFOUND THEN
        CLOSE cr_craptel;
        
        pr_cdcritic := 322; -- Tela nao cadastrada no sistema.
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
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

      -- Renato Darosci (05/07/2016)
      /* Pega o caminho absoluto */
      /*vr_dsdircop:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper);*/
                             
      -- Verifica se encontrou o caminho
      IF vr_dsdircop IS NULL THEN
        pr_cdcritic := 1048; -- Caminho invalido.
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       ' Tabelas crapprm e crapcop.';
        RAISE vr_exc_saida;
      END IF;
                     
      -- Monta caminho para localizar restrição de uso
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'cred_bloq'
                                ,pr_listarq => vr_arquivo
                                ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1197;  
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)|| ' -> ' ||pr_dscritic;            
        RAISE vr_exc_saida;
      END IF;
      
      -- Pesquisar pasta por arquivo de liberação
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'so_consulta'
                                ,pr_listarq => vr_arquivo_so
                                ,pr_des_erro => pr_dscritic);
                                  
      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1197;  
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)|| ' -> ' ||pr_dscritic; 
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se existe arquivo para controle de bloqueio
      IF vr_arquivo IS NOT NULL THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1209; -- Sistema Bloqueado. Tente mais tarde
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Validações condicionais por status de operação
      IF rw_craptel.inacesso = 1 THEN
        IF pr_inproces > 2 THEN
          pr_cdcritic := 138;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
      ELSIF pr_inproces = 1 OR (pr_inproces = 2 AND vr_arquivo_so IS NOT NULL) THEN
        -- Verifica status da tela
        IF rw_craptel.idambtel NOT IN (0, 2) THEN
          -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
          pr_cdcritic := 1210; -- Acesso nao autorizado
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;

        -- Verifica status do bloqueio da tela
        IF rw_craptel.flgtelbl = 0 THEN
          -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
          pr_cdcritic := 1211; -- Tela bloqueada
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
      ELSE
        pr_cdcritic := 138;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Se não gerar consistência limpa críticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      WHEN vr_exc_saida THEN
        pr_dscritic := pr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        -- Mensagem de erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' ||SQLERRM; 
    END;
  END pc_valida_acesso_sistema;

  /* Procedure para verificar a permissão no momento da requisição */
  PROCEDURE pc_verifica_permissao_operacao(pr_cdcooper IN crapace.cdcooper%TYPE      --> Código da cooperativa
                                          ,pr_cdoperad IN VARCHAR2                   --> Código do operador
                                          ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                          ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                          ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                                          ,pr_cddopcao IN crapace.cddopcao%TYPE      --> Código da opção
                                          ,pr_inproces IN crapdat.inproces%TYPE      --> Identificador do processo
                                          ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                          ,pr_cdcritic OUT PLS_INTEGER) IS           --> Código da crítica
    -- ..........................................................................
    --
    --  Programa : pc_verifica_permissao_operacao
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Objetivo  : Verifica permissão para os objetos envolvidos na execução.
    --
    --   O Log é tratado pela chamadora GENE0004.pc_executa_metodo (Unica chamadora)
    --
    --   Alteracoes: 11/05/2016 - Ajustado o cursor que busca dados do cadastro 
    --                            com permissoes de acesso as telas do sistema
    --                            para utilizar o indice da tabela
    --                            (Douglas - Chamado 450570)
    --
    --               06/04/2017 - Criei novo cursor sobre a CRAPACE para ser executado
    --                            sem o parametro nmrotina desta forma melhorando a performance
    --                            (Carlos Rafael Tanholi - SD 538898)
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --      
    --               02/10/2018 - P442 - Inclusão da Procedure para specification (Marcos-Envolti)
	-- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida   EXCEPTION;             --> Controle de erros
      vr_cddepart    crapope.cddepart%TYPE; --> Descrição do departamento
      vr_nmdatela crapace.nmdatela%TYPE;      

      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_dsparame   VARCHAR2(4000)             := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_verifica_permissao_operacao'; 

      -- Busca dados do cadastro com permissoes de acesso as telas do sistema
      CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE
                       ,pr_cdoperad IN crapace.cdoperad%TYPE
                       ,pr_nmdatela IN crapace.nmdatela%TYPE
                       ,pr_nmrotina IN crapace.nmrotina%TYPE
                       ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
        SELECT ce.nmdatela
        FROM crapace ce
        WHERE ce.cdcooper        = pr_cdcooper
          AND UPPER(ce.cdoperad) = UPPER(pr_cdoperad)
          AND UPPER(ce.nmdatela) = UPPER(pr_nmdatela)
          AND UPPER(ce.nmrotina) = UPPER(pr_nmrotina)
          AND UPPER(ce.cddopcao) = UPPER(pr_cddopcao)
          AND ce.idambace        = 2;

      -- Busca dados do cadastro com permissoes de acesso as telas do sistema
      -- sem informar o nmrotina
      CURSOR cr_crapace_2(pr_cdcooper IN crapace.cdcooper%TYPE
                         ,pr_cdoperad IN crapace.cdoperad%TYPE
                         ,pr_nmdatela IN crapace.nmdatela%TYPE
                         ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
        SELECT ce.nmdatela
        FROM crapace ce
        WHERE ce.cdcooper          = pr_cdcooper
          AND UPPER(ce.cdoperad)   = UPPER(pr_cdoperad)
          AND UPPER(ce.nmdatela)   = UPPER(pr_nmdatela)
          AND UPPER(ce.cddopcao)   = UPPER(pr_cddopcao)
          AND ce.idambace          = 2;
          
    BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      
      --Ajuste mensagem de erro - Chmd REQ0011757 - 13/04/2018
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper || 
                     ', pr_cdoperad:' || pr_cdoperad || 
                     ', pr_idsistem:' || pr_idsistem || 
                     ', pr_nmdatela:' || pr_nmdatela ||
                     ', pr_nmrotina:' || pr_nmrotina || 
                     ', pr_cddopcao:' || pr_cddopcao || 
                     ', pr_inproces:' || pr_inproces ;
                  
      -- Valida o acesso ao sistema
      pc_valida_acesso_sistema(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_idsistem => pr_idsistem
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nmrotina => pr_nmrotina
                              ,pr_inproces => pr_inproces
                              ,pr_cddepart => vr_cddepart
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreram erros de execução
      IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica qual é o departamento de operação
      IF vr_cddepart <> 20 THEN
        
        -- valida o nome da rotina para definir qual o cursor utilizar
        IF (pr_nmrotina IS NULL) THEN
          -- Verifica as permissões de execução no cadastro
          OPEN cr_crapace_2(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_cddopcao);
          FETCH cr_crapace_2
           INTO vr_nmdatela;
          -- Verifica se foi encontrada permissão
          IF cr_crapace_2%NOTFOUND THEN
            CLOSE cr_crapace_2;
            pr_cdcritic := 36;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_crapace_2; 
          END IF;  
        ELSE
        -- Verifica as permissões de execução no cadastro
        OPEN cr_crapace(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_nmrotina, pr_cddopcao);
        FETCH cr_crapace
         INTO vr_nmdatela;
        -- Verifica se foi encontrada permissão
        IF cr_crapace%NOTFOUND THEN
          CLOSE cr_crapace;
          pr_cdcritic := 36;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapace; 
        END IF;
        END IF;
      
      END IF;

      -- Se não gerar consistência limpa críticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      WHEN vr_exc_saida THEN
        pr_dscritic := pr_dscritic ||
                       ' ' || vr_dsparame;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM || 
                       '. ' || vr_dsparame; 
    END;
  END pc_verifica_permissao_operacao;

  PROCEDURE pc_reagenda_job(pr_job_name IN  Dba_Scheduler_Jobs.job_name%TYPE
                           ,pr_dtagenda IN  DATE    /*data*/
                           ,pr_hragenda IN  INTEGER /*horas*/
                           ,pr_mmagenda IN  INTEGER /*minutos*/
                           ,pr_dscritic OUT VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_reagenda_job
    --  Sistema  : Tratamento de Jobs
    --  Sigla    : GENE
    --  Autor    : Desconhecido
    --  Data     : ../../....                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --               Chamadora b1wgen0183.p (Unica chamadora)
    --
    --   Alteracoes:  
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)    
    --
    -- .............................................................................
    --
  BEGIN    
    DECLARE
    
      CURSOR cr_job(pr_job_name dba_scheduler_jobs.job_name%TYPE) IS
        SELECT j.job_name, j.JOB_ACTION, j.start_date
          FROM Dba_Scheduler_Jobs j       
         WHERE j.owner = 'CECRED'
           AND upper(j.job_name) LIKE '%'||upper(pr_job_name)||'%' ESCAPE '\';
           
      rw_job cr_job%ROWTYPE;   
        
      -- Variaveis não utilizadas vr_jobname e vr_dscritic - Chmd REQ0011757 - 13/04/2018  
      
      vr_dscomando VARCHAR2(4000);
      vr_dtagenda  TIMESTAMP;
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_dsparame   VARCHAR2 (4000)             := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro   VARCHAR2  (100)             := 'GENE0004.pc_reagenda_job'; 
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2 (4000)             := NULL;
      
    BEGIN
      -- Incluido nome do módulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      pr_dscritic := NULL;      
      --Ajuste mensagem de erro - Chmd REQ0011757 - 13/04/2018
      vr_dsparame := 'pr_job_name:'   || pr_job_name || 
                     ', pr_dtagenda:' || pr_dtagenda || 
                     ', pr_hragenda:' || pr_hragenda || 
                     ', pr_mmagenda:' || pr_mmagenda;
      
      vr_dtagenda := TO_TIMESTAMP_TZ(to_char(pr_dtagenda,'DD/MM/RRRR')||' '||to_char(pr_hragenda,'00')||':'
                     ||to_char(pr_mmagenda,'00')||':'||'00 ' || to_char( SYSTIMESTAMP, 'TZH:TZM' ),'dd/mm/yyyy hh24:mi:ss TZH:TZM');
    
      FOR rw_job IN cr_job(pr_job_name => pr_job_name) LOOP    
      
        vr_dscomando := 'BEGIN 
                            DBMS_SCHEDULER.SET_ATTRIBUTE(NAME => ''' || 'CECRED' || '.' || rw_job.job_name || ''', 
                                                         attribute => ''start_date'', 
                                                         VALUE => TO_TIMESTAMP_TZ(''' || to_char(vr_dtagenda, 'dd/mm/yyyy hh24:mi:ss') || ' ' || to_char( SYSTIMESTAMP, 'TZH:TZM' )  || ''',''DD/MM/RRRR HH24:MI:SS TZH:TZM''));
                         END;';
        EXECUTE IMMEDIATE vr_dscomando;  
        
        gene0001.pc_gera_log_job(pr_cdcooper => 3
                                ,pr_des_log  => '*******************************************************************************************************'||chr(13)||
                                       'Coop: 3 --> Progr: GEBE0004.PC_REAGENDA_JOB Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                       'JobNM: '||rw_job.job_name||' - Alterado start_date de '|| to_char(rw_job.start_date,'dd/mm/yyyy hh24:mi:ss') ||
                                       '  para: '||to_char(vr_dtagenda, 'dd/mm/yyyy hh24:mi:ss') );
        
        COMMIT;
      END LOOP;

      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => 0);
        -- Monta mensagens --- Não retorna o erro para o progress
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM     ||
                       '. ' || vr_dsparame;  
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        gene0004.pc_log(pr_dscritic => vr_dscritic
                       ,pr_cdcritic => vr_cdcritic
                       );
                       
        ROLLBACK;
    END;  
  END pc_reagenda_job;

  PROCEDURE pc_trata_exec_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo    
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta sendo executado no job
                             ,pr_intipmsg OUT INTEGER                --> 1 Padrão:Os programas tratam com a regra atual. 2 Grupo de mensagens para não parar o programa.
                             ,pr_cdcritic OUT INTEGER                --> Codigo Critica - Chmd REQ0011757 - 13/04/2018
                             ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                            ) IS
    -- ..........................................................................
    --
    --  Programa : pc_trata_exec_job
    --  Sistema  : Rotinas de tratamento que verifica dia util e se o processo
    --             esta rodando para nao executar uma job
    --  Sigla    : GENE
    --  Autor    : Tiago
    --  Data     : Julho/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execução.
    --
    --   Dispara por: pc_gera_dados_cyber está gera Log
    --                pc_job_contab_cessao
    --                pc_crps710
    --                pc_executa_job
    --
    --   Alteracoes: 10/08/2015 - Incluindo paramentros e gerado funcionalidade para
    --                            para caso o job não pode ser executado conseguir reagendar
    --                            automaticamente o job para a proxima hora (Odirlei-AMcom)
    --
    --               03/05/2016 - Alterado paramtro fixo do tempo para reagendar a job para
    --                            buscar da crapprm (Lucas Ranghetti #412789)
    --
    --               13/04/2018 - Acerto do retorno
    --                            No caso de erro de programa gravar tabela especifica de log
    --                            pr_intipmsg tipo de mensagem a ser tratada especificamente
    --                             1 - Padrão: Os programas tratam com a regra atual.
    --                             2 - Grupo de mensagens para não parar o programa: 
    --                                 Procedures PC_CRPS710 e pc_gera_dados_cyber não gera critica.
    --                             3 - Grupo de mensagens para não parar o programa: 
    --                                 Procedures pc_job_contab_cessao, PC_CRPS710 e pc_gera_dados_cyber não gera critica.                                 
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    -- .............................................................................
  BEGIN           
    DECLARE 
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de saída
      -- Excluido vr_exc_null - agora é tratado via variavel  - Chmd REQ0011757 - 13/04/2018
      
      vr_dtauxili   DATE;
      vr_tempo   NUMBER;   -- Tempo em milisegundos
      vr_minutos NUMBER;   -- Tempo em minutos
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_dsparame   VARCHAR2(4000)             := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_trata_exec_job';
      vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
      vr_dscritic   VARCHAR2(4000)             := NULL;
      
      -- Procedimento para reprogramar job que não pode ser rodados
      -- pois processi da cooperativa ainda esta rodando
      PROCEDURE pc_reprograma_job(pr_cdcritic OUT INTEGER  --> Codigo Critica - Chmd REQ0011757 - 13/04/2018
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao Critica
                                 ) IS
        -- Identificar o Job e se o mesmo esta rodando
        CURSOR cr_job IS
          SELECT j.job_name,j.JOB_ACTION
            FROM Dba_Scheduler_Jobs         j
                ,Dba_Scheduler_Running_Jobs r
           WHERE j.owner = 'CECRED'
             AND upper(j.job_action) LIKE '%'||upper(pr_nmprogra)||'%'
             AND j.owner = r.OWNER
             AND j.job_name = r.JOB_NAME;
        rw_job cr_job%ROWTYPE;   
        
        vr_jobname  VARCHAR2(100);  
        vr_dscritic VARCHAR2(1000) := NULL;
        -- Trata critica - Chmd REQ0011757 - 13/04/2018
        vr_exc_erro EXCEPTION;      
        -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
        vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_reprograma_job';
        vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
        
      BEGIN
        -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);      
   
        -- Buscar dados do Job
        OPEN cr_job;
        FETCH cr_job INTO rw_job;
        
        -- se encontrou o job
        IF cr_job%FOUND THEN
          CLOSE cr_job;
          
          vr_jobname := substr(rw_job.job_name,1,13)||'_rep$';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper              --> Código da cooperativa
                                ,pr_cdprogra  => upper(pr_nmprogra)       --> Código do programa
                                ,pr_dsplsql   => rw_job.job_action        --> Bloco PLSQL a executar
                                ,pr_dthrexe   => TO_TIMESTAMP_tz(to_char((SYSDATE + vr_tempo),'DD/MM/RRRR HH24:MI'),
                                                                                              'DD/MM/RRRR HH24:MI') --> Incrementar mais tempo
                                ,pr_interva   => NULL                     --> apenas uma vez
                                ,pr_jobname   => vr_jobname               --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN  
            -- Trata mensagen por código - Chmd REQ0011757 - 13/04/2018                                                                
            vr_cdcritic := 1197;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| ' -> ' ||vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        ELSE
          CLOSE cr_job;
          -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
          vr_cdcritic := 1208; -- Não foi possivel reagendar job para procedimento, job não encontrado
          RAISE vr_exc_erro;      
        END IF;
        
        -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      EXCEPTION
        WHEN vr_exc_erro THEN
          vr_cdcritic := NVL(vr_cdcritic,0);          
          -- Buscar a descrição - Se foi retornado apenas código
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);        
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;               
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
          -- Monta Erro
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         vr_nmrotpro ||
                         '. ' || SQLERRM;         
      END pc_reprograma_job;
      
    BEGIN  
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      pr_intipmsg := 1;
      vr_dsparame := ' pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_fldiautl:' || pr_fldiautl ||
                     ', pr_flproces:' || pr_flproces ||
                     ', pr_flrepjob:' || pr_flrepjob ||
                     ', pr_flgerlog:' || pr_flgerlog ||
                     ', pr_nmprogra:' || pr_nmprogra;       
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
         
      -- Se não encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
         CLOSE btch0001.cr_crapdat;
        -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1; -- Sistema sem data de movimento
         RAISE vr_exc_saida;
      ELSE
         CLOSE btch0001.cr_crapdat;
      END IF;         
      
      IF pr_flproces = 1 THEN
         IF rw_crapdat.inproces <> 1 THEN    
            -- verificar se deve reprogramar job
            IF pr_flrepjob = 1 THEN 
              -- Buscar quantidade em minutos para reagendar a JOB
              vr_minutos := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                      pr_cdcooper => 0, 
                                                      pr_cdacesso => 'QTD_MIN_REAGENDAMENTO');                            
              -- Transformar minuto em milisegundo  
              vr_tempo := vr_minutos/60/24;      
            
              pc_reprograma_job(pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic );
              -- se retornou critica
              IF vr_dscritic IS NOT NULL THEN    
                RAISE vr_exc_saida;
              END IF;                    
              -- Retorna nome do módulo logado Chmd REQ0011757 - 13/04/2018
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);              
              -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
              pr_intipmsg := 3;
              vr_cdcritic := 1207; -- Processo noturno nao finalizado para cooperativa job reagendado 
              RAISE vr_exc_saida;
            ELSE  
              -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
              pr_intipmsg := 2;
              vr_cdcritic := 1206; -- Processo noturno nao finalizado para cooperativa  
              RAISE vr_exc_saida;
            END IF;
         END IF;            
      END IF;
    
      IF pr_fldiautl = 1 THEN
         vr_dtauxili := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => SYSDATE
                                                   ,pr_tipo => 'A');
         -- Retorna nome do módulo logado Chmd REQ0011757 - 13/04/2018
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);                                                    
         IF vr_dtauxili <> TRUNC(SYSDATE) THEN
            -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
            vr_cdcritic := 1198; -- Processo deve rodar apenas em dia util
            RAISE vr_exc_saida;
         END IF;   
      END IF;   
    
      -- Limpa nome do módulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);      
    EXCEPTION 
      WHEN vr_exc_saida THEN
        -- Buscar a descrição - Se foi retornado apenas código
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                       vr_dsparame  ||
                       ', pr_intipmsg:' || pr_intipmsg; 
        pr_cdcritic := NVL(vr_cdcritic,0);
        -- verificar se deve gerar log
        IF pr_flgerlog = 1 THEN
          IF UPPER(NVL(pr_nmprogra,' ')) NOT IN ('DSCT0001.PC_EFETUA_BAIXA_TIT_CAR'
                                                ,'PC_GERAR_TARIFA_PACOTE'
                                                ) THEN 
            -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
            gene0004.pc_log(pr_cdcooper => pr_cdcooper
                           ,pr_dscritic => pr_dscritic
                           ,pr_cdcritic => pr_cdcritic
                           );
        END IF;
        END IF;
        
      WHEN OTHERS THEN        
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro     || 
                       '. ' || SQLERRM ||
                       '.' || vr_dsparame  ||
                       ', pr_intipmsg:' || pr_intipmsg; 
        
        -- verificar se deve gerar log
        IF pr_flgerlog = 1 THEN
          IF UPPER(NVL(pr_nmprogra,' ')) NOT IN ('DSCT0001.PC_EFETUA_BAIXA_TIT_CAR'
                                                ,'PC_GERAR_TARIFA_PACOTE'
                                                ) THEN                      
            -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
            gene0004.pc_log(pr_dscritic => pr_dscritic
                           ,pr_cdcritic => pr_cdcritic
                           ); 
        END IF;
        END IF;
        
    END;
  END pc_trata_exec_job;

  /* Procedure para controlar o processo de validação de execução */
  PROCEDURE pc_executa_metodo(pr_xml      IN OUT XMLTYPE              --> Documento XML
                             ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2) IS            --> Descrição da crítica
    -- ..........................................................................
    --
    --  Programa : pc_executa_metodo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execução.
    --
    --   O Log é tratado pela chamadora GENE0004.pc_xml_web (Unica chamadora)    
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de saída
      -- Excluido vr_exc_null - agora é tratado via variavel  - Chmd REQ0011757 - 13/04/2018

      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_executa_metodo';
      vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
      vr_dscritic   VARCHAR2(4000)             := NULL; 

    BEGIN
      -- Incluido nome do módulo logado - Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper'));
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
        -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1; -- Sistema sem data de movimento
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida permissão de execução
      pc_verifica_permissao_operacao(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper')
                                    ,pr_cdoperad => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdopecxa')
                                    ,pr_idsistem => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'idsistem')
                                    ,pr_nmdatela => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'nmdatela')
                                    ,pr_nmrotina => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'nmrotina')
                                    ,pr_cddopcao => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cddopcao')
                                    ,pr_inproces => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'inproces')
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreram erros na validação
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Retorna nome do módulo logado - Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Libera acesso a tela indicando que não existe crítica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      -- Excluido vr_exc_null - agora é tratado via variavel 
      WHEN vr_exc_saida THEN
        -- Buscar a descrição - Se foi retornado apenas código
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic); 
        pr_cdcritic := NVL(vr_cdcritic,0);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0); 
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM; 
    END;
  END pc_executa_metodo;

  /* Cria XML para dados de LOG para os objetos executados */
  FUNCTION fn_cria_xml_log(pr_cdcooper IN NUMBER                       --> Código da cooperativa
                          ,pr_nmdatela IN VARCHAR2                     --> Nome da tela
                          ,pr_nmeacao  IN VARCHAR2                     --> Nome da ação
                          ,pr_cdagenci IN VARCHAR2                     --> Agencia de operação
                          ,pr_nrdcaixa IN VARCHAR2                     --> Número do caixa
                          ,pr_idorigem IN VARCHAR2                     --> Identificação de origem
                          ,pr_cdoperad IN VARCHAR2) RETURN VARCHAR2 IS --> Operador
    -- ..........................................................................
    --
    --  Programa : fn_cria_xml_log
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com dados para criação de LOG interno nas rotinas executadas.
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................
  BEGIN
    BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'gene0004.fn_cria_xml_log');
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      RETURN '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><params>' ||
             '<nmprogra>' || pr_nmdatela || '</nmprogra>' ||
             '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
             '<cdagenci>' || pr_cdagenci || '</cdagenci>' ||
             '<nrdcaixa>' || pr_nrdcaixa || '</nrdcaixa>' ||
             '<idorigem>' || pr_idorigem || '</idorigem>' ||
             '<cdoperad>' || pr_cdoperad || '</cdoperad>' ||
             '<nmeacao>' || pr_nmeacao || '</nmeacao></params></Root>';
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    END;
  END;

  /* Gera XML com dados sobre o erro */
  PROCEDURE pc_gera_xml_erro(pr_xml      IN OUT NOCOPY XMLType               --> XML com descrição do erro
                            ,pr_cdcooper IN crapcop.cdcooper%TYPE            --> Código da cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 1  --> Código da agência
                            ,pr_nrsequen IN NUMBER DEFAULT 1                 --> Número da sequencia
                            ,pr_nrdcaixa IN NUMBER DEFAULT 0                 --> Número do caixa
                            ,pr_nmdcampo IN VARCHAR2 DEFAULT NULL            --> Nome do campo
                            ,pr_cdcritic IN crapcri.cdcritic%TYPE            --> Código da crítica
                            ,pr_dscritic IN VARCHAR2                         --> Descrição da crítica
                            ,pr_dscriret OUT VARCHAR2                        --> Retorna se deu erro
                            ) IS                     
    -- ..........................................................................
    --
    --  Programa : pc_gera_xml_erro
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com descrição do erro.
    --
    --   Após erros na procedure pc_xml_web é disparada está Procedure 
    --   Neste caso não gerar Log pois é o erro do erro.
    --   Gravando apenas a linha e descrição do erro via pc internal exception.  
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_bxml   VARCHAR2(32700);    --> String com o XML do erro

      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      --vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_gera_xml_erro'; - 27/08/2018 REQ0024645

    BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      pr_dscriret := 'OK';

      -- Cabeçalho do arquivo XML
      vr_bxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';

      -- Verifica se o identificador do erro foi informado
      IF pr_nmdcampo IS NOT NULL THEN
        vr_bxml := vr_bxml || '<Root><Erro nmdcampo="' || pr_nmdcampo || '">';
      ELSE
        vr_bxml := vr_bxml || '<Root><Erro>';
      END IF;

      vr_bxml := vr_bxml || '<Registro><cdagenci>' || pr_cdagenci || '</cdagenci>' ||
                            '<nrdcaixa>' || pr_nrdcaixa || '</nrdcaixa>' ||
                            '<nrsequen>' || pr_nrsequen || '</nrsequen>' ||
                            '<cdcritic>' || pr_cdcritic || '</cdcritic>' ||
                            '<dscritic>' || pr_dscritic || '</dscritic>' ||
                            '<erro>yes</erro>' ||
                            '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
                            '</Registro></Erro></Root>';

      -- Gera o XML de saída para o tipo do erro
      pr_xml := XMLType.createXML(vr_bxml);
    END;
    -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
    --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL); 
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645  
  EXCEPTION        
    -- Trata mensagens - Chmd REQ0011757 - 13/04/2018   
    WHEN OTHERS THEN    
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
      pr_dscriret := 'NOK';          
  END pc_gera_xml_erro;

  /* Procedure para inserir histórico de transações */
  PROCEDURE pc_insere_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                           ,pr_cdcooper IN NUMBER                    --> código da cooperativa
                           ,pr_nmdatela IN crapsrw.nmtelaex%TYPE     --> Tela de execução
                           ,pr_cdoperad  IN crapsrw.nmuserex%TYPE     --> Usuário solicitante
                           ,pr_sequence IN OUT NUMBER                --> Sequencia gerada do histórico
                           ,pr_nmdeacao IN crapsrw.nmacaoex%TYPE     --> Nome da ação executada
                           ,pr_dscritic OUT VARCHAR2) IS             --> Erros de execução
    -- ..........................................................................
    --
    --  Programa : pc_insere_trans
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informações acerca da requisição via XML.
    --
    --   Chamadoras   PRGD0001.pc_redir_acao_prgd
    --                GENE0004.pc_redir_acao
    --
    --   Alteracoes: 30/04/2014 - Incluir campo de ação no LOG (Petter - Supero).
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................

    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_insere_trans';
    -- Trata critica - Chmd REQ0011757 - 13/04/2018
    vr_exc_erro EXCEPTION;      
      
  BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
    BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      
      BEGIN
      -- Inserir primeiro registro para o histórico (request)
      INSERT INTO crapsrw(dtsolici, nmtelaex, nmuserex, xmldadrq, cdcooper, nmacaoex)
        VALUES(SYSDATE, pr_nmdatela, pr_cdoperad, pr_xml, pr_cdcooper, pr_nmdeacao)
          RETURNING nrseqsol INTO pr_sequence;
      EXCEPTION
        -- Trata log - Chmd REQ0011757 - 13/04/2018
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Monta Log
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1034) ||
                         'CRAPSRW:' ||
                         ' dtsolici:'  || 'SYSDATE' ||
                         ', nmtelaex:' || pr_nmdatela ||
                         ', nmuserex:' || pr_cdoperad ||
                         ', cdcooper:' || pr_cdcooper ||
                         ', nmacaoex:' || pr_nmdeacao ||
                         '. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      COMMIT;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      -- Trata log - Chmd REQ0011757 - 13/04/2018
      WHEN vr_exc_erro THEN
        NULL;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Monta Log
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                       vr_nmrotpro  ||
                       '. ' || SQLERRM ||
                       '. dtsolici:' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') ||
                       ', nmtelaex:' || pr_nmdatela ||
                       ', nmuserex:' || pr_cdoperad ||
                       ', cdcooper:' || pr_cdcooper ||
                       ', nmacaoex:' || pr_nmdeacao;
    END;
  END pc_insere_trans;

  /* Procedure para atualizar histórico de transações */
  PROCEDURE pc_atualiza_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                             ,pr_seq      IN OUT NUMBER                --> Sequencia gerada do histórico
                             ,pr_des_erro OUT VARCHAR2) IS             --> Erros de execução
    -- ..........................................................................
    --
    --  Programa : pc_insere_trans
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informações acerca da requisição via XML.
    --
    --   Chamadoras: pc_redir_acao e pc_xml_web  
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --  
    -- .............................................................................

    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_atualiza_trans';
    -- Trata critica - Chmd REQ0011757 - 13/04/2018
    vr_exc_erro EXCEPTION;      
  BEGIN
  BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645 
      
    BEGIN
      -- Atualizar histórico com XML de retorno (response)
      UPDATE crapsrw cw
      SET cw.xmldadrp = pr_xml
      WHERE cw.nrseqsol = pr_seq;
      EXCEPTION
        -- Trata log - Chmd REQ0011757 - 13/04/2018
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => 0);
          -- Monta Log
          pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 1035) ||
                       'CRAPSRW:' ||
                       ' nrseqsol:'  || pr_seq ||
                       '. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      COMMIT;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      -- Trata log - Chmd REQ0011757 - 13/04/2018
      WHEN vr_exc_erro THEN
        NULL;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0); 
        --
        pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                       vr_nmrotpro   ||
                       '. ' || SQLERRM ||
                       '. nrseqsol:'   || pr_seq;
    END;
  END pc_atualiza_trans;

  /* Procedure para controlar o redirecionamento das operações */
  PROCEDURE pc_redir_acao(pr_xml      IN OUT NOCOPY XMLType         --> Sequencia de cadastro da solicitação de execução
                         ,pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                         ,pr_nrseqsol IN OUT crapsrw.nrseqsol%TYPE  --> Sequencia do histórico de execução
                         ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS              --> Erros de execução
    -- ..........................................................................
    --
    --  Programa : pc_redir_acao
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 10/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar chamada para a package/procedure de execução do processo de backend.
    --
    --   Disparada pela procedure GENE0004.pc_xml_web    
    --
    --   Alteracoes: 30/04/2014 - Implementação do cadastro de ações para execução (Petter - Supero).
    --   
    --               03/03/2015 - Alteracao do tamanho da variavel vr_sql para o max
    --                            do tipo varchar2 (Tiago).                                       
    --
    --               06/06/2016 - Ajustes realizados:
    --                            -> Incluido upper nos campos que são indice da tabela craprdr
    --                            (Adriano - SD 464741).
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Gerado o modulo e ação das rotinas disparadas                           
    --                            Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --
    --               10/09/2018 - Listar o XML no Log                           
    --                           (Envolti - Belli - Chamado REQ0025926)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_sql        VARCHAR2(32000);    --> SQL dinâmico para montagem de execuções personalizadas
      vr_param      gene0002.typ_split; --> Lista de strings quebradas por delimitador
      vr_exc_erro   EXCEPTION;          --> Controle de exceção
      vr_exc_problema EXCEPTION;        --> Controle de exceção
      vr_xpath      VARCHAR2(400);      --> XPath da tag do arquivo XML
      vr_cdcooper   NUMBER;             --> Código da cooperativa
      vr_nmtela     VARCHAR2(100);      --> Nome da tela/programa que será executado
      vr_seqlog     NUMBER;             --> Sequencia de gravação do LOG
      vr_nmeacao    VARCHAR2(100);      --> Ação que será executada para a tela
      vr_cdagenci   VARCHAR2(100);      --> Agencia de operação
      vr_nrdcaixa   VARCHAR2(100);      --> Número do caixa
      vr_idorigem   VARCHAR2(100);      --> Identificação de origem
      vr_cdoperad   VARCHAR2(100);      --> Operador
      vr_xmllog     VARCHAR2(32767);    --> XML para propagar informações de LOG
      vr_dscritic   VARCHAR2(4000);     --> Descricao do Erro

      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_redir_acao';

      -- Busca qual package/procedure deverá ser executada
      CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE      --> Nome da tela de execução
                       ,pr_nmeacao  IN crapaca.nmdeacao%TYPE) IS   --> Nome da ação de execução
        SELECT ca.nmpackag
              ,ca.nmproced
              ,ca.lstparam
        FROM craprdr cr, crapaca ca
        WHERE ca.nrseqrdr = cr.nrseqrdr
          AND cr.nmprogra = UPPER(pr_nmprogra)
          AND ca.nmdeacao = UPPER(pr_nmeacao);
      rw_craprdr cr_craprdr%ROWTYPE;

    BEGIN
      -- Incluido nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      
      -- Extrair dados do XML de requisição
      gene0004.pc_extrai_dados(pr_xml      => pr_xml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmtela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        -- Trata mensagen por código - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)|| ' -> ' ||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Gravar solicitação
      pc_insere_trans(pr_xml      => pr_xml
                     ,pr_cdcooper => vr_cdcooper
                     ,pr_nmdatela => vr_nmtela
                     ,pr_cdoperad => vr_cdoperad
                     ,pr_sequence => vr_seqlog
                     ,pr_nmdeacao => vr_nmeacao
                     ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        -- Trata mensagen por código - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)|| ' -> ' ||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Criar XML com dados de LOG para propagar para os objetos executados
      vr_xmllog := fn_cria_xml_log(pr_cdcooper => vr_cdcooper
                                  ,pr_nmdatela => vr_nmtela
                                  ,pr_nmeacao  => vr_nmeacao
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_cdoperad => vr_cdoperad);

      -- Busca os dados da execução solicitada
      OPEN cr_craprdr(vr_nmtela, vr_nmeacao);
      FETCH cr_craprdr INTO rw_craprdr;

      IF cr_craprdr%NOTFOUND THEN
        
        -- Tabela para armazenar as telas para interface web
        -- Inclusão de mensagen por código - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1212; -- Registro craprdr nao encontrado.        
        -- Verifica se ocorreram erros
        RAISE vr_exc_erro;

      END IF;
      
      -- Verificar se existe package cadastrada para execução
      IF rw_craprdr.nmpackag IS NOT NULL THEN
        vr_sql := 'begin ' || rw_craprdr.nmpackag || '.';
      ELSE
        vr_sql := 'begin ';
      END IF;

      vr_sql := vr_sql || rw_craprdr.nmproced || '(';

      -- Verifica se existem parâmetros adicionais criados
      IF rw_craprdr.lstparam IS NOT NULL THEN
        -- Quebra a string de parametros
        vr_param := gene0002.fn_quebra_string(rw_craprdr.lstparam, ',');
        -- Retorna nome do módulo logado Chmd REQ0011757 - 13/04/2018
        --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
        -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

        -- Itera sobre a string quebrada
        IF vr_param.count > 0 THEN
          FOR idx IN 1..vr_param.count LOOP
            -- Capturar valor do XPath do arquivo XML
            vr_xpath := '/Root/Dados/' || SUBSTR(vr_param(idx), 4, length(vr_param(idx))) || '/text()';

            -- Concatena o comando SQL, caso não exista valor na TAG gera parâmetro de valor NULL
            IF idx = 1 AND vr_param.count > 1 THEN
              IF pr_xml.existsNode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null,';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''' || ',';
              END IF;
            ELSIF idx = 1 AND vr_param.count = 1 THEN
              IF pr_xml.existsNode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''' ;
              END IF;
            ELSIF idx = vr_param.count THEN
              IF pr_xml.existsNode(vr_xpath) = 0 THEN
                vr_sql := vr_sql || 'null';
              ELSE
                vr_sql := vr_sql || '''' || pr_xml.extract(vr_xpath).getstringval() || '''';
              END IF;
            ELSE
              IF pr_xml.existsNode(vr_xpath) = 0 THEN
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

      -- Setado modulo paleativamente - 27/08/2018 - Chd REQ0024645    
      DECLARE
        vr_nmtelxml VARCHAR2(200);
        vr_nmmodulo VARCHAR2(200);
      BEGIN
        vr_nmtelxml := gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'nmdatela');
        IF vr_nmtelxml IS NULL THEN
           vr_nmmodulo := vr_nmeacao  || '-' || rw_craprdr.nmpackag;
        ELSE
           vr_nmmodulo := vr_nmtelxml || '-' || rw_craprdr.nmpackag;
        END IF;
        -- Incluido nome do módulo que "Vai Disparar"
        GENE0001.pc_set_modulo(pr_module => vr_nmmodulo, pr_action => rw_craprdr.nmproced);        
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => 0);  
          gene0004.pc_log(pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 9999)||vr_nmrotpro||'. '||SQLERRM
                         ,pr_cdcritic => 9999);               
      END;

      -- Ordem para executar de forma imediata o SQL dinâmico
      EXECUTE IMMEDIATE vr_sql USING OUT pr_cdcritic, OUT pr_dscritic, IN OUT pr_xml, OUT pr_nmdcampo, OUT pr_des_erro;

      -- Verifica se ocorreram erros
      IF pr_des_erro <> 'OK' THEN
        RAISE vr_exc_problema;
      END IF;

      -- Atualiza histórico com o XML de resposta
      pc_atualiza_trans(pr_xml      => pr_xml
                       ,pr_seq      => pr_nrseqsol
                       ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        -- Trata mensagen por código - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)|| ' -> ' ||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL); 
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645     
    EXCEPTION
      -- Incluir no Log o parametro que entra no execute imediate - Chmd REQ0025926 - 10/09/2018
      WHEN vr_exc_problema THEN
        pr_des_erro := 'NOK';
      WHEN vr_exc_erro THEN
        -- Buscar a descrição - Se foi retornado apenas código
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic, pr_dscritic => pr_dscritic); 
        pr_dscritic := pr_dscritic ||
                       '. pr_nrseqsol:' || pr_nrseqsol ||
                       
                       ', vr_sql:'      || SUBSTR(vr_sql,1,2000) ||
                       ', pr_cdcritic:' || pr_cdcritic ||
                       ', pr_dscritic:' || SUBSTR(pr_dscritic,1,500) ||
                       ', pr_nmdcampo:' || pr_nmdcampo ||
                       ', pr_des_erro:' || SUBSTR(pr_des_erro,1,500)
                       ;
                       
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0
                                    ,pr_compleme => '. pr_nrseqsol:' || pr_nrseqsol ||                       
                                                    ', execute immediate vr_sql:' || SUBSTR(vr_sql,1,2000) ||
                                                    ', pr_cdcritic:' || pr_cdcritic ||
                                                    ', pr_dscritic:' || SUBSTR(pr_dscritic,1,500) ||
                                                    ', pr_nmdcampo:' || pr_nmdcampo ||
                                                    ', pr_des_erro:' || SUBSTR(pr_des_erro,1,500) );  
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro      ||
                       '. ' || SQLERRM  ||
                       '. pr_nrseqsol:' || pr_nrseqsol ||
                       
                       ', vr_sql:'      || SUBSTR(vr_sql,1,2000) ||
                       ', pr_cdcritic:' || pr_cdcritic ||
                       ', pr_dscritic:' || SUBSTR(pr_dscritic,1,500) ||
                       ', pr_nmdcampo:' || pr_nmdcampo ||
                       ', pr_des_erro:' || SUBSTR(pr_des_erro,1,500)
                       ;
                        
        pr_des_erro := 'NOK';
    END;
  END pc_redir_acao;

  /* Procedures de uso público */
  /* Procedure que será a interface entre o Oracle e sistema Web */
  PROCEDURE pc_xml_web(pr_xml_req IN CLOB                --> Arquivo XML de retorno
                      ,pr_xml_res OUT NOCOPY CLOB) IS    --> Arquivo XML de resposta
    -- .................................................................................................
    --
    --  Programa : pc_xml_web
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 27/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Procedure chamadora: funcoes.php
    --
    --   Objetivo  : Gerenciar interface de comunicação (requisição/resposta) do sistema Web.
    --               Irá receber um arquivo XML com dados de manipulação e parâmetros de execução
    --               para acessar a package/procedure necessário e irá retornar um novo XML com
    --               mensagem de erro ou dados de retorno do processamento.
    --
    --   Alteracoes: 30/04/2014 - Implementação do cadastro de ações para execução (Petter - Supero).
    --
    --               17/05/2014 - Implementação do controle de acesso (Petter - Supero).
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --
    --              10/09/2018 - Mensagem para o usuário não levar parâmetros - 17/09/2018                      
    --                          (Envolti - Belli - Chamado REQ0025926)
    --  
    -- .................................................................................................
  BEGIN
    DECLARE
      vr_xml        XMLType;               --> Variável do XML de entrada
      vr_erro_xml   XMLType;               --> Variável do XML de erro
      vr_des_erro   VARCHAR2(4000);        --> Variável para armazenar descrição do erro de execução
      vr_cdcooper   PLS_INTEGER := 0;      --> Código da cooperativa
      vr_nmdcampo   VARCHAR2(150);         --> Nome do campo da execução
      vr_seq        NUMBER;                --> Sequencia do histórico de execuções
      vr_cdcritic   PLS_INTEGER;           --> Código da crítica
      vr_dscritic   VARCHAR2(4000);        --> Descrição da crítica
      vr_exc_erro   EXCEPTION;             --> Controle de tratamento de erros personalizados
      vr_exc_libe   EXCEPTION;             --> Controle de erros para o processo de liberação
      vr_conttag    PLS_INTEGER;           --> Contador do número de ocorrências da TAG

      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_xml_web'; 
      vr_dscriret   VARCHAR2    (3)            := 'OK';

    BEGIN
      -- Incluido nome do módulo logado
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Criar instancia do XML em memória
      vr_xml := XMLType.createxml(pr_xml_req);

      vr_cdcooper := NVL(gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper'),0);
      -- Retorna nome do módulo logado
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Verifica se existe a TAG de permissão
      gene0007.pc_lista_nodo(pr_xml => vr_xml
                            ,pr_nodo => 'Permissao'
                            ,pr_cont => vr_conttag
                            ,pr_des_erro => vr_dscritic);
      -- Verifica se ocorreram erros na busca da TAG
      IF vr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1197;  
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)|| ' -> ' ||vr_dscritic;           
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do módulo logado
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645

      -- Verifica se existe permissão de execução da tela pelo usuário e hora
      IF vr_conttag > 0 THEN
        pc_executa_metodo(pr_xml      => vr_xml
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
      -- Verifica se o controle de permissão gerou erro ou crítica
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_libe;
      END IF;
        -- Retorna nome do módulo logado
        --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
        -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      END IF;

      -- Gerar requisição para web
      pc_redir_acao(pr_xml      => vr_xml
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic
                   ,pr_nrseqsol => vr_seq
                   ,pr_nmdcampo => vr_nmdcampo
                   ,pr_des_erro => vr_des_erro);

      -- Verifica se ocorreram erros
      IF vr_des_erro <> 'OK' OR vr_dscritic IS NOT NULL THEN

        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        IF vr_des_erro <> 'OK'  THEN    
          gene0004.pc_log(pr_dscritic => vr_dscritic
                         ,pr_cdcritic => vr_cdcritic
                         );
        END IF;

        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        IF vr_cdcritic = 9999 THEN
          vr_cdcritic:= 1224;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
        
          pc_gera_xml_erro(pr_xml      => vr_erro_xml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdcampo => vr_nmdcampo
                          ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic
                        ,pr_dscriret => vr_dscriret);

          -- Gravar mensagem de erro
          pc_atualiza_trans(pr_xml      => vr_erro_xml
                           ,pr_seq      => vr_seq
                           ,pr_des_erro => vr_dscritic);

          -- Verifica se ocorreram erros ao gravar XML de resposta
          IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 1197;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)|| ' -> ' ||vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        IF vr_dscriret = 'OK' THEN
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
        END IF;

      ELSE
        -- Retorna nome do módulo logado
        --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
        -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
        -- Propagar XML de sucesso
        pr_xml_res := vr_xml.getClobVal();
      END IF;
      
      -- Limpa nome do módulo logado
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
    EXCEPTION
      WHEN vr_exc_libe THEN
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        gene0004.pc_log(pr_dscritic => vr_dscritic
                       ,pr_cdcritic => vr_cdcritic                     
                       ,pr_cdcooper => vr_cdcooper
                       );        
        -- Mensagem para o usuário não levar parâmetros - Chd REQ0025926 - 10/09/2018 - 17/09/2018        
        IF NVL(vr_cdcritic,0) > 0 THEN
          IF NVL(vr_cdcritic,0) = 9999 THEN
            vr_cdcritic:= 1224;
            vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
        END IF;        
        -- Gerar XML de erro
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => vr_cdcooper
                        ,pr_cdagenci => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'cdagenci')
                        ,pr_nrdcaixa => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'nrdcaixa')
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic
                        ,pr_dscriret => vr_dscriret);
        ROLLBACK;

        IF vr_dscriret = 'OK' THEN
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
        END IF;
      WHEN vr_exc_erro THEN
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        gene0004.pc_log(pr_dscritic => vr_dscritic
                       ,pr_cdcritic => vr_cdcritic                     
                       ,pr_cdcooper => vr_cdcooper
                       );
                       
        ROLLBACK;

        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic:= 1224;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Gerar XML com descrição do erro para exibição no sistema Web
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => vr_cdcooper
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => 'Erro: ' || vr_dscritic
                        ,pr_dscriret => vr_dscriret);

        IF vr_dscriret = 'OK' THEN
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
        END IF;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0);
        
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic:= 9999;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                      vr_nmrotpro ||
                      '. ' || SQLERRM;
                      
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        gene0004.pc_log(pr_dscritic => vr_dscritic
                       ,pr_cdcritic => vr_cdcritic                       
                       ,pr_cdcooper => vr_cdcooper
                       );
              
        ROLLBACK;

        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic:= 1224;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Gerar XML com descrição do erro para exibição no sistema Web
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => vr_cdcooper
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic
                        ,pr_dscriret => vr_dscriret);

        IF vr_dscriret = 'OK' THEN
        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
        END IF;
    END;
  END pc_xml_web;

  /* Procedure para gerenciar a extração de dados do XML de envio */
  PROCEDURE pc_extrai_dados(pr_xml      IN XMLType                      --> XML com dados para LOG
                           ,pr_cdcooper OUT NUMBER                      --> Código da cooperativa
                           ,pr_nmdatela OUT VARCHAR2                    --> Nome da tela
                           ,pr_nmeacao  OUT VARCHAR2                    --> Nome da ação
                           ,pr_cdagenci OUT VARCHAR2                    --> Agencia de operação
                           ,pr_nrdcaixa OUT VARCHAR2                    --> Número do caixa
                           ,pr_idorigem OUT VARCHAR2                    --> Identificação de origem
                           ,pr_cdoperad OUT VARCHAR2                    --> Operador
                           ,pr_dscritic OUT VARCHAR2) IS                --> Descrição da crítica
    -- ..........................................................................
    --
    --  Programa : pc_extrai_dados
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Abril/2014.                   Ultima atualizacao: 10/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Extrair dados do XML de requisição.
    --
    --   Disparado por 177 programas.
    -- 
    --   Alteracoes: 15/08/2014 - Inserido TRIM (Jean Michel)
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    --               27/08/2018 - Gerado o modulo e ação das rotinas disparadas                           
    --                            Ação paleativa até todas rotinas setarem o modulo "o que são milhares"
    --                            NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas
    --                           (Envolti - Belli - Chamado REQ0024645)
    --
    --               10/09/2018 - Listar o XML no Log                           
    --                           (Envolti - Belli - Chamado REQ0025926)
    --  
    -- .............................................................................
    --
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_extrai_dados'; 
    vr_cdcritic   crapcri.cdcritic%TYPE;
    -- Variaveis para tratar xml nulo - Chmd REQ0025926 - 10/09/2018
    vr_dsxml      VARCHAR2(3000);
    vr_sqlcode    NUMBER(10);
    vr_cdgraerr   NUMBER (1);
  BEGIN
    BEGIN
      -- Incluido nome do módulo logado
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      --
      pr_cdcooper := TO_NUMBER(TRIM(pr_xml.extract('/Root/params/cdcooper/text()').getstringval()));
      pr_nmdatela := TRIM(pr_xml.extract('/Root/params/nmprogra/text()').getstringval());
      pr_nmeacao  := TRIM(pr_xml.extract('/Root/params/nmeacao/text()').getstringval());
      pr_cdagenci := TRIM(pr_xml.extract('/Root/params/cdagenci/text()').getstringval());
      pr_nrdcaixa := TRIM(pr_xml.extract('/Root/params/nrdcaixa/text()').getstringval());
      pr_idorigem := TRIM(pr_xml.extract('/Root/params/idorigem/text()').getstringval());
      pr_cdoperad := TRIM(pr_xml.extract('/Root/params/cdoperad/text()').getstringval());
      -- Limpa nome do módulo logado Chmd REQ0011757 - 13/04/2018
      --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      -- NÃO setar MODULO e ACTION porque essa rotina entra no ciclo de milhares de chamadas - 27/08/2018 REQ0024645
      
      -- Setado modulo paleativamente - 27/08/2018 - Chd REQ0024645
      DECLARE
        vr_nmtelxml   VARCHAR2   (200);
        vr_nmmodulo   VARCHAR2   (200);
      BEGIN
        BEGIN
          vr_nmtelxml := TRIM(pr_xml.extract('/Root/Permissao/nmdatela/text()').getstringval());
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = -30625 THEN
              vr_nmtelxml := NULL; -- O metodo pr_xml.extract não encontra e sai com o codigo 30625
            ELSE
              CECRED.pc_internal_exception(pr_cdcooper => 0); 
              gene0004.pc_log(pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 9999)||vr_nmrotpro||'. '||SQLERRM
                             ,pr_cdcritic => 9999); 
            END IF;
        END;
        --
        IF vr_nmtelxml IS NULL THEN
           vr_nmmodulo := pr_nmdatela;
        ELSE
           vr_nmmodulo := vr_nmtelxml || ' - ' || pr_nmdatela;
        END IF;
        -- Incluido nome do módulo que "Vai Disparar"
        GENE0001.pc_set_modulo(pr_module => vr_nmmodulo, pr_action => pr_nmeacao);
        --
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => 0);
          gene0004.pc_log(pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 9999)||vr_nmrotpro||'. '||SQLERRM
                         ,pr_cdcritic => 9999); 
      END;
      --
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        -- Trata se erro de xml nulo não grava TBGEN 
        -- porque não da para descobrir quem esta passando - Chmd REQ0025926 - 10/09/2018
        BEGIN 
          vr_sqlcode := SQLCODE;       
          vr_dsxml   := SUBSTR(pr_xml.getStringVal(),1,3000); 
          vr_dsxml   := '1 - sqlcode original:' || vr_sqlcode || ' - pr_xml:' || vr_dsxml;
          CECRED.pc_internal_exception(pr_cdcooper => 0
                                      ,pr_compleme => vr_dsxml);         
        EXCEPTION
          WHEN OTHERS THEN
          IF SQLCODE = -30625 THEN
            -- Se chegar XML nulo não vai gravar TBGEN ERRO
            NULL;
          ELSE
            vr_dsxml := SUBSTR(pr_xml.getStringVal(),1,3000);            
            vr_dsxml := '2 - sqlcode original:' || vr_sqlcode || ' - pr_xml:' || vr_dsxml;
            BEGIN
              -- Comando para retornar negativo o valor do SQLCODE e o sistema gravar a TBEGN ERRO
              vr_cdgraerr := 0 / 0; 
    EXCEPTION
      WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => 0
                                            ,pr_compleme => vr_dsxml || ' - ' ||vr_cdgraerr);         
            END;                    
          END IF;                      
        END;      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM ||
                       ', vr_dsxml:'   || vr_dsxml; 
    END;
  END pc_extrai_dados;

  -- ATENÇÃO NÃO UTILIZAR MAIS ESTA PROCEDURE E SIM A pc_trata_exec_job por estar completa  
  PROCEDURE pc_executa_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo    
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta sendo executado no job
                          ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                          ) IS
    /*..........................................................................
    --
    --  Programa : pc_executa_job
    --  Sistema  : Rotinas de tratamento que verifica dia util e se o processo
    --             esta rodando para nao executar uma job
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Chamado REQ0011757
    --  Data     : 13/04/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execução.
         Disparado : ccrd0003.pck
                     cobr0005 pc_verifica_sms_a_enviar
                     cobr0005 pc_gerar_tarifa_pacote
                     cobr0005 pc_verifica_renovacao_pacote
                     cobr0005 pc_gera_tarifa_sms_enviados
                     dsct0001 pc_efetua_baixa_tit_car_job
                     TELA_CONTAS_GRUPO_ECONOMICO   
                     pc_bancoob_cheques_depositos  
                     pc_bancoob_envia_arquivo_saldo
                     pc_bancoob_envia_arquivo_solcc
                     PC_BANCOOB_RECEBE_ARQ_SOLCC   
                     pc_bancoob_recebe_arquivo_cext
                     pc_controla_deb_tarifas 
                     pc_crps517              
                     pc_job_agendeb          
                     PC_JOB_AGENDEBRECARGACEL
                     pc_job_agendebted     
                     pc_job_paga_adiofjuros  

    --   Alteracoes: 
    
    ............................................................................. */

    vr_intipmsg   PLS_INTEGER                := 0;    
    vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
    vr_dscritic   VARCHAR2(4000)             := NULL;
    vr_dsparame   VARCHAR2(4000)             := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_executa_job';
  BEGIN   
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0004.' || vr_nmrotpro );
    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_fldiautl:' || pr_fldiautl ||
                   ', pr_flproces:' || pr_flproces ||
                   ', pr_flrepjob:' || pr_flrepjob ||
                   ', pr_flgerlog:' || pr_flgerlog ||
                   ', pr_nmprogra:' || pr_nmprogra;
    --
    -- ATENÇÃO NÃO UTILIZAR MAIS ESTA PROCEDURE E SIM A pc_trata_exec_job por estar completa
    --
    -- ESTA PROCEDURE SERA DESATIVADA ASSIM QUE TODOS PROGRAMAS SE CONVERTEREM PARA A pc_trata_exec_job
    --
    -- Chamada para tratar a execução de job
    GENE0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                              ,pr_fldiautl => pr_fldiautl --> Flag se deve validar dia util
                              ,pr_flproces => pr_flproces --> Flag se deve validar se esta no processo    
                              ,pr_flrepjob => pr_flrepjob --> Flag para reprogramar o job
                              ,pr_flgerlog => pr_flgerlog --> indicador se deve gerar log
                              ,pr_nmprogra => pr_nmprogra --> Nome do programa que esta sendo executado no job
                              ,pr_intipmsg => vr_intipmsg --> 1 Padrão:Os programas tratam com a regra atual. 2 Grupo de mensagens para não parar o programa.
                              ,pr_cdcritic => vr_cdcritic --> Codigo Critica - Chmd REQ0011757 - 13/04/2018
                              ,pr_dscritic => vr_dscritic --> Descricao Critica
                              );
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN                                                       
      pr_dscritic := vr_dscritic;
    ELSE       
      -- Limpa nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    END IF;      
  EXCEPTION         
    WHEN OTHERS THEN    
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
      -- Efetuar retorno do erro não tratado
      vr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     vr_nmrotpro     || 
                     '. ' || SQLERRM ||
                     '. ' || vr_dsparame; 
        
      -- verificar se deve gerar log
      IF pr_flgerlog = 1 THEN
        IF UPPER(NVL(pr_nmprogra,' ')) NOT IN ('DSCT0001.PC_EFETUA_BAIXA_TIT_CAR'
                                              ,'PC_GERAR_TARIFA_PACOTE'
                                              ) THEN                    
          -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
          gene0004.pc_log(pr_dscritic => pr_dscritic
                         ,pr_cdcritic => vr_cdcritic
                         );  
        END IF;
      END IF;
  END pc_executa_job;

  /*Procedures Rotina de Log - tabela: tbgen prglog ocorrencia*/     
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT 'GENE0004'
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  ) 
  IS
    -- ..........................................................................
    --
    --  Programa : pc_log
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Chamado REQ0011757
    --  Data     : 13/04/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN   
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdprograma    => pr_nmrotina
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_idprglog      => vr_idprglog
                          );   
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_log;
  
END GENE0004;
/
