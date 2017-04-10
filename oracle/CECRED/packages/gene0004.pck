CREATE OR REPLACE PACKAGE CECRED.GENE0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0004
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 15/08/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar interface e validações necessárias para intercambio de dados
  --
  --  Alteracoes: 15/08/2014 - Adicionado TRIM na pc_extrai_dados (Jean Michel).
  --              31/07/2015 - Criada funcao generica fn_executa_job 
  --              10/06/2016 - Criada procedure pc_reagenda_job SD402010 (Tiago/Thiago).
  ---------------------------------------------------------------------------------------------------------------

  /* Definições das procedures de uso público */

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
                          ,pr_dscritic OUT VARCHAR2); 
  
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
                            ,pr_dscritic IN VARCHAR2);                       --> Descrição da crítica
                    
END GENE0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0004
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 06/04/2017
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
    --  Data     : Maio/2014.                   Ultima atualizacao: 21/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Valida permissão para os objetos envolvidos na execução.
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
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida  EXCEPTION;          --> Controle de saída
      vr_arquivo    VARCHAR2(400);      --> Variável para retorno da busca de arquivo de bloqueio
      vr_arquivo_so VARCHAR2(400);      --> Variável para retorno da busca de arquivo de bloqueio
      vr_dsdircop   VARCHAR2(100);
      
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

      -- Renato Darosci (05/07/2016)
      /* Pega o caminho absoluto */
      /*vr_dsdircop:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper);*/
                             
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
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'so_consulta'
                                ,pr_listarq => vr_arquivo_so
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
          pr_cdcritic := 999;
          pr_dscritic := 'Acesso nao autorizado.';
          RAISE vr_exc_saida;
        END IF;

        -- Verifica status do bloqueio da tela
        IF rw_craptel.flgtelbl = 0 THEN
          pr_cdcritic := 999;
          pr_dscritic := 'Tela bloqueada';
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
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := pr_dscritic || ' Erro em PC_VALIDA_ACESSO_SISTEMA. --> ' || SQLERRM;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em PC_VALIDA_ACESSO_SISTEMA: ' || SQLERRM;
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
    --  Data     : Maio/2014.                   Ultima atualizacao: 06/04/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Verifica permissão para os objetos envolvidos na execução.
    --
    --   Alteracoes: 11/05/2016 - Ajustado o cursor que busca dados do cadastro 
    --                            com permissoes de acesso as telas do sistema
    --                            para utilizar o indice da tabela
    --                            (Douglas - Chamado 450570)
    --
    --               06/04/2017 - Criei novo cursor sobre a CRAPACE para ser executado
    --                            sem o parametro nmrotina desta forma melhorando a performance
    --                            (Carlos Rafael Tanholi - SD 538898)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida   EXCEPTION;             --> Controle de erros
      vr_cddepart    crapope.cddepart%TYPE; --> Descrição do departamento
      vr_nmdatela crapace.nmdatela%TYPE;      

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
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := pr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 999;
        pr_dscritic := 'Erro em PC_VERIFICA_PERMISSAO_OPERACAO: ' || SQLERRM;
    END;
  END pc_verifica_permissao_operacao;

  PROCEDURE pc_reagenda_job(pr_job_name IN  Dba_Scheduler_Jobs.job_name%TYPE
                           ,pr_dtagenda IN  DATE    /*data*/
                           ,pr_hragenda IN  INTEGER /*horas*/
                           ,pr_mmagenda IN  INTEGER /*minutos*/
                           ,pr_dscritic OUT VARCHAR2) IS
  BEGIN    
    DECLARE
    
      CURSOR cr_job(pr_job_name dba_scheduler_jobs.job_name%TYPE) IS
        SELECT j.job_name, j.JOB_ACTION, j.start_date
          FROM Dba_Scheduler_Jobs j       
         WHERE j.owner = 'CECRED'
           AND upper(j.job_name) LIKE '%'||upper(pr_job_name)||'%' ESCAPE '\';
           
      rw_job cr_job%ROWTYPE;   
        
      vr_jobname  VARCHAR2(100);  
      vr_dscritic VARCHAR2(1000);
      
      vr_dscomando VARCHAR2(4000);
      vr_dtagenda  TIMESTAMP;
      
    BEGIN
      
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

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;  
  END pc_reagenda_job;

  PROCEDURE pc_executa_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo    
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta sendo executado no job
                          ,pr_dscritic OUT VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_executa_job
    --  Sistema  : Rotinas de tratamento que verifica dia util e se o processo
    --             esta rodando para nao executar uma job
    --  Sigla    : GENE
    --  Autor    : Tiago
    --  Data     : Julho/2014.                   Ultima atualizacao: 03/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execução.
    --
    --   Alteracoes: 10/08/2015 - Incluindo paramentros e gerado funcionalidade para
    --                            para caso o job não pode ser executado conseguir reagendar
    --                            automaticamente o job para a proxima hora (Odirlei-AMcom)
    --
    --               03/05/2016 - Alterado paramtro fixo do tempo para reagendar a job para
    --                            buscar da crapprm (Lucas Ranghetti #412789)
    -- .............................................................................
  BEGIN           
    DECLARE 
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de saída
      vr_exc_null   EXCEPTION;                       --> Controle de saída    
      
      vr_dtauxili   DATE;
      vr_tempo   NUMBER;   -- Tempo em milisegundos
      vr_minutos NUMBER;   -- Tempo em minutos
      
      -- Procedimento para reprogramar job que não pode ser rodados
      -- pois processi da cooperativa ainda esta rodando
      PROCEDURE pc_reprograma_job(pr_dscritic OUT VARCHAR2) IS
        
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
        vr_dscritic VARCHAR2(1000);
        
        
      BEGIN
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
                                ,pr_des_erro  => pr_dscritic);
        ELSE
          CLOSE cr_job;
          pr_dscritic := 'Não foi possivel reagendar job para procedimento '||pr_nmprogra||
                         ', job não encontrado.';           
        END IF;
        
      END pc_reprograma_job;
      
    BEGIN  
      
      pr_dscritic := '';
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
         
      -- Se não encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
         CLOSE btch0001.cr_crapdat;
         pr_dscritic := 'Sistema sem data de movimento.';
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
            
              pc_reprograma_job(pr_dscritic => pr_dscritic);
              -- se retornou critica
              IF pr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;                    
              
              pr_dscritic := 'Processo noturno nao finalizado para cooperativa '||to_char(pr_cdcooper)||
                             ', job reagendado para '||to_char((SYSDATE + vr_tempo),'DD/MM/RRRR HH24:MI');
              RAISE vr_exc_saida;
            ELSE  
              pr_dscritic := 'Processo noturno nao finalizado para cooperativa '||to_char(pr_cdcooper);           
              RAISE vr_exc_saida;
            END IF;
         END IF;            
      END IF;
    
      IF pr_fldiautl = 1 THEN
         vr_dtauxili := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => SYSDATE
                                                   ,pr_tipo => 'A');
                                                   
         IF vr_dtauxili <> TRUNC(SYSDATE) THEN
            pr_dscritic := 'Processo deve rodar apenas em dia util';
            RAISE vr_exc_saida;
         END IF;   
      END IF;   
    
    EXCEPTION 
      WHEN vr_exc_saida THEN
        -- verificar se deve gerar log
        IF pr_flgerlog = 1 THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                     pr_ind_tipo_log => 2, --> erro tratado 
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || pr_nmprogra ||
                                                        ' --> ' || pr_dscritic, 
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
        
      WHEN OTHERS THEN        
        pr_dscritic := 'Erro em PC_EXECUTA_JOB: ' || SQLERRM;
        
        -- verificar se deve gerar log
        IF pr_flgerlog = 1 THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                     pr_ind_tipo_log => 2, --> erro tratado 
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - ' || pr_nmprogra ||
                                                        ' --> ' || pr_dscritic, 
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
        
    END;
  END pc_executa_job;

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
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execução.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de saída
      vr_exc_null  EXCEPTION;                      --> Controle de saída

    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper'));
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;

        pr_cdcritic := 999;
        pr_dscritic := 'Sistema sem data de movimento.';

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
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreram erros na validação
      IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_null;
      END IF;

      -- Libera acesso a tela indicando que não existe crítica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro em PC_EXECUTA_METODO. ' || pr_dscritic || ' --> ' || SQLERRM;
      WHEN OTHERS THEN
        pr_cdcritic := 999;
        pr_dscritic := 'Erro em PC_EXECUTA_METODO: ' || SQLERRM;
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
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com dados para criação de LOG interno nas rotinas executadas.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    BEGIN
      RETURN '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><params>' ||
             '<nmprogra>' || pr_nmdatela || '</nmprogra>' ||
             '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
             '<cdagenci>' || pr_cdagenci || '</cdagenci>' ||
             '<nrdcaixa>' || pr_nrdcaixa || '</nrdcaixa>' ||
             '<idorigem>' || pr_idorigem || '</idorigem>' ||
             '<cdoperad>' || pr_cdoperad || '</cdoperad>' ||
             '<nmeacao>' || pr_nmeacao || '</nmeacao></params></Root>';
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
                            ,pr_dscritic IN VARCHAR2) IS                     --> Descrição da crítica
    -- ..........................................................................
    --
    --  Programa : pc_gera_xml_erro
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com descrição do erro.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_bxml   VARCHAR2(32700);    --> String com o XML do erro

    BEGIN
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
    --  Data     : Maio/2013.                   Ultima atualizacao: 30/04/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informações acerca da requisição via XML.
    --
    --   Alteracoes: 30/04/2014 - Incluir campo de ação no LOG (Petter - Supero).
    -- .............................................................................

    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN
      -- Inserir primeiro registro para o histórico (request)
      INSERT INTO crapsrw(dtsolici, nmtelaex, nmuserex, xmldadrq, cdcooper, nmacaoex)
        VALUES(SYSDATE, pr_nmdatela, pr_cdoperad, pr_xml, pr_cdcooper, pr_nmdeacao)
          RETURNING nrseqsol INTO pr_sequence;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em PC_INSERE_TRANS: ' || SQLERRM;
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
    --  Data     : Maio/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informações acerca da requisição via XML.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................

    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN
      -- Atualizar histórico com XML de retorno (response)
      UPDATE crapsrw cw
      SET cw.xmldadrp = pr_xml
      WHERE cw.nrseqsol = pr_seq;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_atualiza_trans: ' || SQLERRM;
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
    --  Data     : Maio/2013.                   Ultima atualizacao: 06/06/2016
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
    --               06/06/2016 - Ajustes realizados:
    --                            -> Incluido upper nos campos que são indice da tabela craprdr
    --                            (Adriano - SD 464741).
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
        RAISE vr_exc_erro;
      END IF;

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
        RAISE vr_exc_erro;
      END IF;

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
        
        vr_dscritic:= 'Registro craprdr nao encontrado.';
        
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
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_problema THEN
        pr_des_erro := 'NOK';
      WHEN vr_exc_erro THEN
        pr_cdcritic:= 0;
        pr_dscritic:= vr_dscritic;
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro em PC_REDIR_ACAO: ' || SQLERRM;
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
    --  Data     : Maio/2013.                   Ultima atualizacao: 30/04/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerenciar interface de comunicação (requisição/resposta) do sistema Web.
    --               Irá receber um arquivo XML com dados de manipulação e parâmetros de execução
    --               para acessar a package/procedure necessário e irá retornar um novo XML com
    --               mensagem de erro ou dados de retorno do processamento.
    --
    --   Alteracoes: 30/04/2014 - Implementação do cadastro de ações para execução (Petter - Supero).
    --
    --               17/05/2014 - Implementação do controle de acesso (Petter - Supero).
    -- .................................................................................................
  BEGIN
    DECLARE
      vr_xml        XMLType;               --> Variável do XML de entrada
      vr_erro_xml   XMLType;               --> Variável do XML de erro
      vr_des_erro   VARCHAR2(4000);        --> Variável para armazenar descrição do erro de execução
      vr_cdcooper   PLS_INTEGER;           --> Código da cooperativa
      vr_nmdcampo   VARCHAR2(150);         --> Nome do campo da execução
      vr_seq        NUMBER;                --> Sequencia do histórico de execuções
      vr_cdcritic   PLS_INTEGER;           --> Código da crítica
      vr_dscritic   VARCHAR2(4000);        --> Descrição da crítica
      vr_exc_erro   EXCEPTION;             --> Controle de tratamento de erros personalizados
      vr_exc_libe   EXCEPTION;             --> Controle de erros para o processo de liberação
      vr_conttag    PLS_INTEGER;           --> Contador do número de ocorrências da TAG

    BEGIN
      -- Criar instancia do XML em memória
      vr_xml := XMLType.createxml(pr_xml_req);

      -- Verifica se existe a TAG de permissão
      gene0007.pc_lista_nodo(pr_xml => vr_xml, pr_nodo => 'Permissao', pr_cont => vr_conttag, pr_des_erro => vr_des_erro);

      -- Verifica se ocorreram erros na busca da TAG
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se existe permissão de execução da tela pelo usuário e hora
      IF vr_conttag > 0 THEN
        pc_executa_metodo(pr_xml      => vr_xml
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
      END IF;

      -- Verifica se o controle de permissão gerou erro ou crítica
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar XML de erro
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper')
                        ,pr_cdagenci => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'cdagenci')
                        ,pr_nrdcaixa => gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'nrdcaixa')
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);

        RAISE vr_exc_libe;
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
        -- Gera XML com mensagem de erro
        IF NVL(vr_cdcritic, 0) = 0 THEN
          pc_gera_xml_erro(pr_xml      => vr_erro_xml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdcampo => vr_nmdcampo
                          ,pr_cdcritic => 0
                          ,pr_dscritic => vr_dscritic);

          -- Gravar mensagem de erro
          pc_atualiza_trans(pr_xml      => vr_erro_xml
                           ,pr_seq      => vr_seq
                           ,pr_des_erro => vr_dscritic);

          -- Verifica se ocorreram erros ao gravar XML de resposta
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          pc_gera_xml_erro(pr_xml      => vr_erro_xml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdcampo => vr_nmdcampo
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

          -- Gravar mensagem de erro
          pc_atualiza_trans(pr_xml      => vr_erro_xml
                           ,pr_seq      => vr_seq
                           ,pr_des_erro => vr_dscritic);

          -- Verifica se ocorreram erros ao gravar XML de resposta
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
      ELSE
        -- Propagar XML de sucesso
        pr_xml_res := vr_xml.getClobVal();
      END IF;
    EXCEPTION
      WHEN vr_exc_libe THEN
        ROLLBACK;

        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
      WHEN vr_exc_erro THEN
        ROLLBACK;

        -- Gerar XML com descrição do erro para exibição no sistema Web
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => vr_cdcooper
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Erro: ' || vr_dscritic);

        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
      WHEN OTHERS THEN
        ROLLBACK;

        -- Gerar XML com descrição do erro para exibição no sistema Web
        pc_gera_xml_erro(pr_xml      => vr_erro_xml
                        ,pr_cdcooper => vr_cdcooper
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Erro: ' || SQLERRM);

        -- Propagar XML de erro
        pr_xml_res := vr_erro_xml.getClobVal();
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
    --  Data     : Abril/2014.                   Ultima atualizacao: 15/08/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Extrair dados do XML de requisição.
    --
    --   Alteracoes: 15/08/2014 - Inserido TRIM (Jean Michel)
    -- .............................................................................
  BEGIN
    BEGIN
      pr_cdcooper := TO_NUMBER(TRIM(pr_xml.extract('/Root/params/cdcooper/text()').getstringval()));
      pr_nmdatela := TRIM(pr_xml.extract('/Root/params/nmprogra/text()').getstringval());
      pr_nmeacao  := TRIM(pr_xml.extract('/Root/params/nmeacao/text()').getstringval());
      pr_cdagenci := TRIM(pr_xml.extract('/Root/params/cdagenci/text()').getstringval());
      pr_nrdcaixa := TRIM(pr_xml.extract('/Root/params/nrdcaixa/text()').getstringval());
      pr_idorigem := TRIM(pr_xml.extract('/Root/params/idorigem/text()').getstringval());
      pr_cdoperad := TRIM(pr_xml.extract('/Root/params/cdoperad/text()').getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em PC_EXTRAI_DADOS: ' || SQLERRM;
    END;
  END pc_extrai_dados;

END GENE0004;
/
