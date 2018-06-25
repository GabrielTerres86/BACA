CREATE OR REPLACE PACKAGE CECRED.GENE0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0004
  --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar interface e valida��es necess�rias para intercambio de dados
  --
  --  Alteracoes: 15/08/2014 - Adicionado TRIM na pc_extrai_dados (Jean Michel).
  --              31/07/2015 - Criada funcao generica fn_executa_job 
  --              10/06/2016 - Criada procedure pc_reagenda_job SD402010 (Tiago/Thiago).
  --
  --              13/04/2018 - 1 - Tratado Others na gera��o da tabela tbgen erro de sistema
  --                           2 - Seta Modulo
  --                           3 - Eliminada mensagem fixas
  --                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
  --                           5 - Criada PROCEDURE pc_trata_exec_job para tratar a descri��o de criticas 
  --                               no sentido de n�o mais utilizar descri��o como condi��o de decis�o
  --                           6 - Modificada pc_executa_job para ser utilizada somente por rotinas 
  --                               ainda n�o alteradas nesse momento e ficaram pendentes
  --                           (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
  --  
  ---------------------------------------------------------------------------------------------------------------

  /* Defini��es das procedures de uso p�blico */

  /* Procedure para reagender job passando nome, nova data e novo horario*/
  PROCEDURE pc_reagenda_job(pr_job_name IN  Dba_Scheduler_Jobs.job_name%TYPE
                           ,pr_dtagenda IN  DATE
                           ,pr_hragenda IN  INTEGER
                           ,pr_mmagenda IN  INTEGER
                           ,pr_dscritic OUT VARCHAR2);

  /* Procedure que ser� a interface entre o Oracle e sistema Web */
  PROCEDURE pc_xml_web(pr_xml_req IN CLOB                --> Arquivo XML de retorno
                      ,pr_xml_res OUT NOCOPY CLOB);      --> Arquivo XML de resposta


  /* Procedure para gerenciar a extra��o de dados do XML de envio */
  PROCEDURE pc_extrai_dados(pr_xml      IN XMLType                      --> XML com descri��o do erro
                           ,pr_cdcooper OUT NUMBER                      --> C�digo da cooperativa
                           ,pr_nmdatela OUT VARCHAR2                    --> Nome da tela
                           ,pr_nmeacao  OUT VARCHAR2                    --> Nome da a��o
                           ,pr_cdagenci OUT VARCHAR2                    --> Agencia de opera��o
                           ,pr_nrdcaixa OUT VARCHAR2                    --> N�mero do caixa
                           ,pr_idorigem OUT VARCHAR2                    --> Identifica��o de origem
                           ,pr_cdoperad OUT VARCHAR2                    --> Operador
                           ,pr_dscritic OUT VARCHAR2);                  --> Descri��o da cr�tica
                           
  /*Procedures de validacoes genericas para JOBs*/                         
  PROCEDURE pc_executa_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo 
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta s
                          ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                          ) ; 
  
  /* Procedure para inserir hist�rico de transa��es */
  PROCEDURE pc_insere_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                           ,pr_cdcooper IN NUMBER                    --> c�digo da cooperativa
                           ,pr_nmdatela IN crapsrw.nmtelaex%TYPE     --> Tela de execu��o
                           ,pr_cdoperad  IN crapsrw.nmuserex%TYPE     --> Usu�rio solicitante
                           ,pr_sequence IN OUT NUMBER                --> Sequencia gerada do hist�rico
                           ,pr_nmdeacao IN crapsrw.nmacaoex%TYPE     --> Nome da a��o executada
                           ,pr_dscritic OUT VARCHAR2) ;             --> Erros de execu��o    

  /* Procedure para atualizar hist�rico de transa��es */
  PROCEDURE pc_atualiza_trans(pr_xml      IN OUT NOCOPY XMLType    --> XML
                             ,pr_seq      IN OUT NUMBER            --> Sequencia gerada do hist�rico
                             ,pr_des_erro OUT VARCHAR2);           --> Erros de execu��o
 
  /* Gera XML com dados sobre o erro */
  PROCEDURE pc_gera_xml_erro(pr_xml      IN OUT NOCOPY XMLType               --> XML com descri��o do erro
                            ,pr_cdcooper IN crapcop.cdcooper%TYPE            --> C�digo da cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 1  --> C�digo da ag�ncia
                            ,pr_nrsequen IN NUMBER DEFAULT 1                 --> N�mero da sequencia
                            ,pr_nrdcaixa IN NUMBER DEFAULT 0                 --> N�mero do caixa
                            ,pr_nmdcampo IN VARCHAR2 DEFAULT NULL            --> Nome do campo
                            ,pr_cdcritic IN crapcri.cdcritic%TYPE            --> C�digo da cr�tica
                            ,pr_dscritic IN VARCHAR2                         --> Descri��o da cr�tica
                            ,pr_dscriret OUT VARCHAR2                        --> Retorna se deu erro
                            ); 
   
  /*Procedures de validacoes genericas para JOBs*/                         
  PROCEDURE pc_trata_exec_job(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                          ,pr_fldiautl IN INTEGER                 --> Flag se deve validar dia util
                          ,pr_flproces IN INTEGER                 --> Flag se deve validar se esta no processo 
                          ,pr_flrepjob IN INTEGER  DEFAULT 0      --> Flag para reprogramar o job
                          ,pr_flgerlog IN INTEGER  DEFAULT NULL   --> indicador se deve gerar log
                          ,pr_nmprogra IN VARCHAR2 DEFAULT NULL   --> Nome do programa que esta s
                          ,pr_intipmsg OUT INTEGER                --> 1 Padr�o, 2 Grupo de mensagens tratadas
                          ,pr_cdcritic OUT INTEGER                --> Codigo Critica
                          ,pr_dscritic OUT VARCHAR2               --> Descricao Critica
                          );

  /*Procedures Rotina de Log - tabela: tbgen prglog ocorrencia*/   
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-in�cio/ F-fim/ O-ocorr�ncia/ E-erro 
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
  --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
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
  --  Alteracoes: 16/05/2014 - Adicionado procedures para permiss�o de execu��o.
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
  --                        -> Incluido upper nos campos que s�o indice da tabela craprdr
  --                        -> Incluido upper nos campos que s�o indice da tabela crapprg
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
  --              29/11/2016 - P341 - Automatiza��o BACENJUD - Alterado para validar o departamento � partir
  --                           do c�digo e n�o mais pela descri��o (Renato Darosci - Supero)
  --
  --              06/04/2017 - Criei novo cursor sobre a CRAPACE para ser executado sem o parametro nmrotina 
  --                           desta forma melhorando a performance. (Carlos Rafael Tanholi - SD 538898) 
  --
  --              13/04/2018 - 1 - Tratado Others na gera��o da tabela tbgen erro de sistema
  --                           2 - Seta Modulo
  --                           3 - Eliminada mensagem fixas
  --                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
  --                           5 - Criada PROCEDURE pc_trata_exec_job para tratar a descri��o de criticas 
  --                               no sentido de n�o mais utilizar descri��o como condi��o de decis�o
  --                           6 - Modificada pc_executa_job para ser utilizada somente por rotinas 
  --                               ainda n�o alteradas nesse momento e ficaram pendentes
  --                           (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
  --  
  ---------------------------------------------------------------------------------------------------------------

  /* Procedures/functions de uso privado */

  /* Procedure para valiar o acesso ao sistema */
  PROCEDURE pc_valida_acesso_sistema(pr_cdcooper IN crapace.cdcooper%TYPE      --> C�digo da cooperativa
                                    ,pr_cdoperad IN VARCHAR2                   --> C�digo do operador
                                    ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                    ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                                    ,pr_inproces IN crapdat.inproces%TYPE      --> Indicador do processo
                                    ,pr_cddepart OUT crapope.cddepart%TYPE     --> Descri��o do departamento
                                    ,pr_cdcritic OUT PLS_INTEGER               --> C�digo de retorno
                                    ,pr_dscritic OUT VARCHAR2) IS              --> Descri��o do retorno
    -- ..........................................................................
    --
    --  Programa : pc_valida_acesso_sistema
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Objetivo  : Valida permiss�o para os objetos envolvidos na execu��o.
    --
    --   O Log � tratado pela chamadora GENE0004.pc_verifica_permissao_operacao (Unica chamadora)
    --
    --   Alteracoes: 04/09/2015 - Ajuste para retirar o uso do caminho absoluto fixado na rotina
    --                            (Adriano - SD 323620).
    --
    --               06/06/2016 - Ajustes realizados:
    --                            -> Incluido upper nos campos que s�o indice da tabela CRAPPRG
    --                            (Adriano - SD 464741).
    --
    --               26/06/2016 - Correcao para o uso do indice no cursor sobre a craptel na 
    --                            procedure pc_valida_acesso_sistema.(Carlos Rafael Tanholi).   
    --
    --               05/07/2016 - Realizado a retirada da chamada da FN_DIRETORIO com o intu�to de conseguir 
    --                            alguma melhora na performance das chamadas, visto que estavam sendo 
    --                            feitas muitas chamadas da fun��o. D�vidas sobre a altera��o podem ser 
    --                            tratadas tamb�m com o Rodrigo Siewerdt. (Renato Darosci - Supero)
	--
	  --				       21/10/2016 - Ajustado cursor da craptel para n�o executar fun��o desnecessariamente (Rodrigo) 
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida  EXCEPTION;          --> Controle de sa�da
      vr_arquivo    VARCHAR2(400);      --> Vari�vel para retorno da busca de arquivo de bloqueio
      vr_arquivo_so VARCHAR2(400);      --> Vari�vel para retorno da busca de arquivo de bloqueio
      vr_dsdircop   VARCHAR2(100);
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_valida_acesso_sistema';
      
      -- Busca dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> C�digo da cooperativa
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
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE      --> C�digo da cooperativa
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS  --> C�digo do operador
      SELECT pe.cddepart
        FROM crapope pe
       WHERE UPPER(pe.cdoperad) = UPPER(pr_cdoperad)
         AND pe.cdcooper        = pr_cdcooper;
      rw_crapope cr_crapope%ROWTYPE;

      -- Busca dados do cadastro de telas
      CURSOR cr_craptel(pr_cdcooper IN craptel.cdcooper%TYPE      --> C�digo da cooperativa
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
      CURSOR cr_crapprg(pr_cdcooper IN crapprg.cdcooper%TYPE      --> C�digo da cooperativa
                       ,pr_nmdatela IN crapprg.cdprogra%TYPE) IS  --> Nome da tela
      SELECT rg.nmsistem
        FROM crapprg rg
       WHERE rg.cdcooper = pr_cdcooper
         AND UPPER(rg.cdprogra) = UPPER(pr_nmdatela)
         AND UPPER(rg.nmsistem) = 'CRED';

    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se n�o encontrar registro
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
                     
      -- Monta caminho para localizar restri��o de uso
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'cred_bloq'
                                ,pr_listarq => vr_arquivo
                                ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1197;  
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||
                         ' pr_dscritic:' || pr_dscritic;            
        RAISE vr_exc_saida;
      END IF;
      
      -- Pesquisar pasta por arquivo de libera��o
      gene0001.pc_lista_arquivos(pr_path => vr_dsdircop || '/arquivos'
                                ,pr_pesq => 'so_consulta'
                                ,pr_listarq => vr_arquivo_so
                                ,pr_des_erro => pr_dscritic);
                                  
      -- Verifica se ocorreram erros ao pesquisar por arquivo
      IF pr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1197;  
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||
                         ' pr_dscritic:' || pr_dscritic; 
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se existe arquivo para controle de bloqueio
      IF vr_arquivo IS NOT NULL THEN
        -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1209; -- Sistema Bloqueado. Tente mais tarde
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Valida��es condicionais por status de opera��o
      IF rw_craptel.inacesso = 1 THEN
        IF pr_inproces > 2 THEN
          pr_cdcritic := 138;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
      ELSIF pr_inproces = 1 OR (pr_inproces = 2 AND vr_arquivo_so IS NOT NULL) THEN
        -- Verifica status da tela
        IF rw_craptel.idambtel NOT IN (0, 2) THEN
          -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
          pr_cdcritic := 1210; -- Acesso nao autorizado
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;

        -- Verifica status do bloqueio da tela
        IF rw_craptel.flgtelbl = 0 THEN
          -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
          pr_cdcritic := 1211; -- Tela bloqueada
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
      ELSE
        pr_cdcritic := 138;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Se n�o gerar consist�ncia limpa cr�ticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
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

  /* Procedure para verificar a permiss�o no momento da requisi��o */
  PROCEDURE pc_verifica_permissao_operacao(pr_cdcooper IN crapace.cdcooper%TYPE      --> C�digo da cooperativa
                                          ,pr_cdoperad IN VARCHAR2                   --> C�digo do operador
                                          ,pr_idsistem IN craptel.idsistem%TYPE      --> Identificador do sistema
                                          ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da tela
                                          ,pr_nmrotina IN craptel.nmrotina%TYPE      --> Nome da rotina
                                          ,pr_cddopcao IN crapace.cddopcao%TYPE      --> C�digo da op��o
                                          ,pr_inproces IN crapdat.inproces%TYPE      --> Identificador do processo
                                          ,pr_dscritic OUT VARCHAR2                  --> Descri��o da cr�tica
                                          ,pr_cdcritic OUT PLS_INTEGER) IS           --> C�digo da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_verifica_permissao_operacao
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Objetivo  : Verifica permiss�o para os objetos envolvidos na execu��o.
    --
    --   O Log � tratado pela chamadora GENE0004.pc_executa_metodo (Unica chamadora)
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
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_saida   EXCEPTION;             --> Controle de erros
      vr_cddepart    crapope.cddepart%TYPE; --> Descri��o do departamento
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
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      --Ajuste mensagem de erro - Chmd REQ0011757 - 13/04/2018
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper || 
                     ', pr_cdoperad:' || pr_cdoperad || 
                     ', pr_idsistem:' || pr_idsistem || 
                     ', pr_nmdatela:' || pr_nmdatela ||
                     ', pr_nmrotina:' || pr_nmrotina || 
                     ', pr_cddopcao:' || pr_cddopcao || 
                     ', pr_inproces:' || pr_inproces ;
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
                        
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

      -- Verifica se ocorreram erros de execu��o
      IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica qual � o departamento de opera��o
      IF vr_cddepart <> 20 THEN
        
        -- valida o nome da rotina para definir qual o cursor utilizar
        IF (pr_nmrotina IS NULL) THEN
          -- Verifica as permiss�es de execu��o no cadastro
          OPEN cr_crapace_2(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_cddopcao);
          FETCH cr_crapace_2
           INTO vr_nmdatela;
          -- Verifica se foi encontrada permiss�o
          IF cr_crapace_2%NOTFOUND THEN
            CLOSE cr_crapace_2;
            pr_cdcritic := 36;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_crapace_2; 
          END IF;  

        ELSE
        -- Verifica as permiss�es de execu��o no cadastro
        OPEN cr_crapace(pr_cdcooper, pr_cdoperad, pr_nmdatela, pr_nmrotina, pr_cddopcao);
        FETCH cr_crapace
         INTO vr_nmdatela;
        -- Verifica se foi encontrada permiss�o
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

      -- Se n�o gerar consist�ncia limpa cr�ticas
      pr_dscritic := NULL;
      pr_cdcritic := 0;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION      
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      WHEN vr_exc_saida THEN
        pr_dscritic := pr_dscritic ||
                       '. ' || vr_dsparame;
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
    --   Objetivo  : Chamar a rotina de Log para grava��o de criticas.
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

      -- Variaveis n�o utilizadas vr_jobname e vr_dscritic - Chmd REQ0011757 - 13/04/2018  
      
      vr_dscomando VARCHAR2(4000);
      vr_dtagenda  TIMESTAMP;    
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_dsparame   VARCHAR2 (4000)             := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro   VARCHAR2  (100)             := 'GENE0004.pc_reagenda_job'; 
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2 (4000)             := NULL;
      
    BEGIN
      -- Incluido nome do m�dulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      pr_dscritic := NULL;      
      --Ajuste mensagem de erro - Chmd REQ0011757 - 13/04/2018
      vr_dsparame := 'pr_job_name:'   || pr_job_name || 
                     ', pr_dtagenda:' || pr_dtagenda || 
                     ', pr_hragenda:' || pr_hragenda || 
                     ', pr_mmagenda:' || pr_mmagenda;
                     
      -- For�ado teste - Chmd REQ0011757 - 13/04/2018
      --vr_cdcritic := 0 / 0;
      
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
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION      
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => 0);
        -- Monta mensagens --- N�o retorna o erro para o progress
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' '  || vr_nmrotpro ||
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
                             ,pr_intipmsg OUT INTEGER                --> 1 Padr�o:Os programas tratam com a regra atual. 2 Grupo de mensagens para n�o parar o programa.
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
    --   Objetivo  : Validar acesso em tempo de execu��o.
    --
    --   Dispara por: pc_gera_dados_cyber est� gera Log
    --                pc_job_contab_cessao
    --                pc_crps710
    --                pc_executa_job
    --
    --   Alteracoes: 10/08/2015 - Incluindo paramentros e gerado funcionalidade para
    --                            para caso o job n�o pode ser executado conseguir reagendar
    --                            automaticamente o job para a proxima hora (Odirlei-AMcom)
    --
    --               03/05/2016 - Alterado paramtro fixo do tempo para reagendar a job para
    --                            buscar da crapprm (Lucas Ranghetti #412789)
    --
    --               13/04/2018 - Acerto do retorno
    --                            No caso de erro de programa gravar tabela especifica de log
    --                            pr_intipmsg tipo de mensagem a ser tratada especificamente
    --                             1 - Padr�o: Os programas tratam com a regra atual.
    --                             2 - Grupo de mensagens para n�o parar o programa: 
    --                                 Procedures PC_CRPS710 e pc_gera_dados_cyber n�o gera critica.
    --                             3 - Grupo de mensagens para n�o parar o programa: 
    --                                 Procedures pc_job_contab_cessao, PC_CRPS710 e pc_gera_dados_cyber n�o gera critica.                                 
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --
    -- .............................................................................
  BEGIN           
    DECLARE 
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de sa�da
      -- Excluido vr_exc_null - agora � tratado via variavel  - Chmd REQ0011757 - 13/04/2018
      
      vr_dtauxili   DATE;
      vr_tempo   NUMBER;   -- Tempo em milisegundos
      vr_minutos NUMBER;   -- Tempo em minutos
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_dsparame   VARCHAR2(4000)             := NULL; -- Agrupa parametros para gravar em logs
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_trata_exec_job';
      vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
      vr_dscritic   VARCHAR2(4000)             := NULL;
      
      -- Procedimento para reprogramar job que n�o pode ser rodados
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
        -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);      
   
        -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018    
        --DECLARE
        --  vr_teste NUMBER;
        --BEGIN
        --  vr_teste := 0 / 0;
        --END;                  
        
        -- Buscar dados do Job
        OPEN cr_job;
        FETCH cr_job INTO rw_job;        
        
        -- se encontrou o job
        IF cr_job%FOUND THEN
          CLOSE cr_job;
          
          vr_jobname := substr(rw_job.job_name,1,13)||'_rep$';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper              --> C�digo da cooperativa
                                ,pr_cdprogra  => upper(pr_nmprogra)       --> C�digo do programa
                                ,pr_dsplsql   => rw_job.job_action        --> Bloco PLSQL a executar
                                ,pr_dthrexe   => TO_TIMESTAMP_tz(to_char((SYSDATE + vr_tempo),'DD/MM/RRRR HH24:MI'),
                                                                                              'DD/MM/RRRR HH24:MI') --> Incrementar mais tempo
                                ,pr_interva   => NULL                     --> apenas uma vez
                                ,pr_jobname   => vr_jobname               --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN  
            -- Trata mensagen por c�digo - Chmd REQ0011757 - 13/04/2018                                                                
            vr_cdcritic := 1197;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' vr_dscritic:' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        ELSE
          CLOSE cr_job;
          -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
          vr_cdcritic := 1208; -- N�o foi possivel reagendar job para procedimento, job n�o encontrado
          RAISE vr_exc_erro;      
        END IF;
        
        -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      EXCEPTION
        WHEN vr_exc_erro THEN
          vr_cdcritic := NVL(vr_cdcritic,0);          
          -- Buscar a descri��o - Se foi retornado apenas c�digo
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);        
          -- Devolvemos c�digo e critica encontradas das variaveis locais
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
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      pr_intipmsg := 1;
      vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                     ', pr_fldiautl:' || pr_fldiautl ||
                     ', pr_flproces:' || pr_flproces ||
                     ', pr_flrepjob:' || pr_flrepjob ||
                     ', pr_flgerlog:' || pr_flgerlog ||
                     ', pr_nmprogra:' || pr_nmprogra;       
   
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018    
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;                  
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
         
      -- Se n�o encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
        -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
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
              -- Retorna nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);              
              -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
              pr_intipmsg := 3;
              vr_cdcritic := 1207; -- Processo noturno nao finalizado para cooperativa job reagendado 
              RAISE vr_exc_saida;
            ELSE  
              -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
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
         -- Retorna nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);                                                    
         IF vr_dtauxili <> TRUNC(SYSDATE) THEN
            -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
            vr_cdcritic := 1198; -- Processo deve rodar apenas em dia util
            RAISE vr_exc_saida;
         END IF;   
      END IF;   

      -- Limpa nome do m�dulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);      
    EXCEPTION 
      WHEN vr_exc_saida THEN
        -- Buscar a descri��o - Se foi retornado apenas c�digo
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
            gene0004.pc_log(pr_dscritic => pr_dscritic
                           ,pr_cdcritic => pr_cdcritic
                           );
          END IF;
        END IF;
        
      WHEN OTHERS THEN    
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro     || 
                       '. ' || SQLERRM ||
                       '. ' || vr_dsparame  ||
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

  /* Procedure para controlar o processo de valida��o de execu��o */
  PROCEDURE pc_executa_metodo(pr_xml      IN OUT XMLTYPE              --> Documento XML
                             ,pr_cdcritic OUT PLS_INTEGER             --> C�digo da cr�tica
                             ,pr_dscritic OUT VARCHAR2) IS            --> Descri��o da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_executa_metodo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Validar acesso em tempo de execu��o.
    --
    --   O Log � tratado pela chamadora GENE0004.pc_xml_web (Unica chamadora)    
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;    --> Cursor com dados da data
      vr_exc_saida  EXCEPTION;                      --> Controle de sa�da
      -- Excluido vr_exc_null - agora � tratado via variavel  - Chmd REQ0011757 - 13/04/2018
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_executa_metodo';
      vr_cdcritic   crapcri.cdcritic%TYPE      := 0;
      vr_dscritic   VARCHAR2(4000)             := NULL; 

    BEGIN
      -- Incluido nome do m�dulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper'));
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se n�o encontrar registro para a cooperativa
      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
        -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1; -- Sistema sem data de movimento
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida permiss�o de execu��o
      pc_verifica_permissao_operacao(pr_cdcooper => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper')
                                    ,pr_cdoperad => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cdopecxa')
                                    ,pr_idsistem => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'idsistem')
                                    ,pr_nmdatela => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'nmdatela')
                                    ,pr_nmrotina => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'nmrotina')
                                    ,pr_cddopcao => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'cddopcao')
                                    ,pr_inproces => gene0007.fn_valor_tag(pr_xml => pr_xml, pr_pos_exc => 0, pr_nomtag => 'inproces')
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreram erros na valida��o
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Retorna nome do m�dulo logado - Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

      -- Libera acesso a tela indicando que n�o existe cr�tica
      pr_cdcritic := 0;
      pr_dscritic := NULL;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      -- Trata mensagens - Chmd REQ0011757 - 13/04/2018
      -- Excluido vr_exc_null - agora � tratado via variavel 
      WHEN vr_exc_saida THEN
        -- Buscar a descri��o - Se foi retornado apenas c�digo
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic); 
        pr_cdcritic := NVL(vr_cdcritic,0);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0); 
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM; 
    END;
  END pc_executa_metodo;

  /* Cria XML para dados de LOG para os objetos executados */
  FUNCTION fn_cria_xml_log(pr_cdcooper IN NUMBER                       --> C�digo da cooperativa
                          ,pr_nmdatela IN VARCHAR2                     --> Nome da tela
                          ,pr_nmeacao  IN VARCHAR2                     --> Nome da a��o
                          ,pr_cdagenci IN VARCHAR2                     --> Agencia de opera��o
                          ,pr_nrdcaixa IN VARCHAR2                     --> N�mero do caixa
                          ,pr_idorigem IN VARCHAR2                     --> Identifica��o de origem
                          ,pr_cdoperad IN VARCHAR2) RETURN VARCHAR2 IS --> Operador
    -- ..........................................................................
    --
    --  Programa : fn_cria_xml_log
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com dados para cria��o de LOG interno nas rotinas executadas.
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
  BEGIN
    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'gene0004.fn_cria_xml_log');
      RETURN '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><params>' ||
             '<nmprogra>' || pr_nmdatela || '</nmprogra>' ||
             '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
             '<cdagenci>' || pr_cdagenci || '</cdagenci>' ||
             '<nrdcaixa>' || pr_nrdcaixa || '</nrdcaixa>' ||
             '<idorigem>' || pr_idorigem || '</idorigem>' ||
             '<cdoperad>' || pr_cdoperad || '</cdoperad>' ||
             '<nmeacao>' || pr_nmeacao || '</nmeacao></params></Root>';
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    END;
  END;

  /* Gera XML com dados sobre o erro */
  PROCEDURE pc_gera_xml_erro(pr_xml      IN OUT NOCOPY XMLType               --> XML com descri��o do erro
                            ,pr_cdcooper IN crapcop.cdcooper%TYPE            --> C�digo da cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 1  --> C�digo da ag�ncia
                            ,pr_nrsequen IN NUMBER DEFAULT 1                 --> N�mero da sequencia
                            ,pr_nrdcaixa IN NUMBER DEFAULT 0                 --> N�mero do caixa
                            ,pr_nmdcampo IN VARCHAR2 DEFAULT NULL            --> Nome do campo
                            ,pr_cdcritic IN crapcri.cdcritic%TYPE            --> C�digo da cr�tica
                            ,pr_dscritic IN VARCHAR2                         --> Descri��o da cr�tica
                            ,pr_dscriret OUT VARCHAR2                        --> Retorna se deu erro
                            ) IS                     
    -- ..........................................................................
    --
    --  Programa : pc_gera_xml_erro
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar XML com descri��o do erro.
    --
    --   Ap�s erros na procedure pc_xml_web � disparada est� Procedure 
    --   Neste caso n�o gerar Log pois � o erro do erro.
    --   Gravando apenas a linha e descri��o do erro via pc internal exception.  
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_bxml   VARCHAR2(32700);    --> String com o XML do erro   
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_gera_xml_erro'; 

    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      pr_dscriret := 'OK';
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;      
                     
      -- Cabe�alho do arquivo XML
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

      -- Gera o XML de sa�da para o tipo do erro
      pr_xml := XMLType.createXML(vr_bxml);
    END;
    -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);   
  EXCEPTION        
    -- Trata mensagens - Chmd REQ0011757 - 13/04/2018   
    WHEN OTHERS THEN    
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
      pr_dscriret := 'NOK';          
  END pc_gera_xml_erro;

  /* Procedure para inserir hist�rico de transa��es */
  PROCEDURE pc_insere_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                           ,pr_cdcooper IN NUMBER                    --> c�digo da cooperativa
                           ,pr_nmdatela IN crapsrw.nmtelaex%TYPE     --> Tela de execu��o
                           ,pr_cdoperad  IN crapsrw.nmuserex%TYPE     --> Usu�rio solicitante
                           ,pr_sequence IN OUT NUMBER                --> Sequencia gerada do hist�rico
                           ,pr_nmdeacao IN crapsrw.nmacaoex%TYPE     --> Nome da a��o executada
                           ,pr_dscritic OUT VARCHAR2) IS             --> Erros de execu��o
    -- ..........................................................................
    --
    --  Programa : pc_insere_trans
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informa��es acerca da requisi��o via XML.
    --
    --   Chamadoras   PRGD0001.pc_redir_acao_prgd
    --                GENE0004.pc_redir_acao
    --
    --   Alteracoes: 30/04/2014 - Incluir campo de a��o no LOG (Petter - Supero). 
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................

    -- Cria uma nova se��o para commitar
    -- somente esta escopo de altera��es
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_insere_trans';
    -- Trata critica - Chmd REQ0011757 - 13/04/2018
    vr_exc_erro EXCEPTION;      
      
  BEGIN
    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      BEGIN      
        -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
        --IF pr_nmdatela = 'CADA0006' THEN
        --  dbms_output.put_line('pr_nmdatela:' ||  pr_nmdatela);
        --  DECLARE
        --    vr_teste NUMBER;
        --  BEGIN
        --    vr_teste := 0 / 0;
        --  END;
        --END IF;
        -- Inserir primeiro registro para o hist�rico (request)
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
                         'CRAPSRW(1):' ||
                         ' dtsolici:'  || 'SYSDATE' ||
                         ', nmtelaex:' || pr_nmdatela ||
                         ', nmuserex:' || pr_cdoperad ||
                         ', cdcooper:' || pr_cdcooper ||
                         ', nmacaoex:' || pr_nmdeacao ||
                         '. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      COMMIT;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
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

  /* Procedure para atualizar hist�rico de transa��es */
  PROCEDURE pc_atualiza_trans(pr_xml      IN OUT NOCOPY XMLType        --> XML
                             ,pr_seq      IN OUT NUMBER                --> Sequencia gerada do hist�rico
                             ,pr_des_erro OUT VARCHAR2) IS             --> Erros de execu��o
    -- ..........................................................................
    --
    --  Programa : pc_insere_trans
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir informa��es acerca da requisi��o via XML.
    --
    --   Chamadoras: pc_redir_acao e pc_xml_web  
    --
    --   Alteracoes: 
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................

    -- Cria uma nova se��o para commitar
    -- somente esta escopo de altera��es
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_atualiza_trans';
    -- Trata critica - Chmd REQ0011757 - 13/04/2018
    vr_exc_erro EXCEPTION;      
  BEGIN
    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro); 
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --pr_seq := 0 / 0;
      
      BEGIN      
        -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
        --pr_seq := 0 / 0;
        -- Atualizar hist�rico com XML de retorno (response)
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
                       'CRAPSRW(1):' ||
                       ' nrseqsol:'  || pr_seq ||
                       '. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      COMMIT;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
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

  /* Procedure para controlar o redirecionamento das opera��es */
  PROCEDURE pc_redir_acao(pr_xml      IN OUT NOCOPY XMLType         --> Sequencia de cadastro da solicita��o de execu��o
                         ,pr_cdcritic OUT PLS_INTEGER               --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2                  --> Descri��o da cr�tica
                         ,pr_nrseqsol IN OUT crapsrw.nrseqsol%TYPE  --> Sequencia do hist�rico de execu��o
                         ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS              --> Erros de execu��o
    -- ..........................................................................
    --
    --  Programa : pc_redir_acao
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Gerar chamada para a package/procedure de execu��o do processo de backend.    
    -- 
    --   Disparada pela procedure GENE0004.pc_xml_web    
    --
    --   Alteracoes: 30/04/2014 - Implementa��o do cadastro de a��es para execu��o (Petter - Supero).
    --   
    --               03/03/2015 - Alteracao do tamanho da variavel vr_sql para o max
    --                            do tipo varchar2 (Tiago).                                       
    --
    --               06/06/2016 - Ajustes realizados:
    --                            -> Incluido upper nos campos que s�o indice da tabela craprdr
    --                            (Adriano - SD 464741). 
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
  BEGIN
    DECLARE
      vr_sql        VARCHAR2(32000);    --> SQL din�mico para montagem de execu��es personalizadas
      vr_param      gene0002.typ_split; --> Lista de strings quebradas por delimitador
      vr_exc_erro   EXCEPTION;          --> Controle de exce��o
      vr_exc_problema EXCEPTION;        --> Controle de exce��o
      vr_xpath      VARCHAR2(400);      --> XPath da tag do arquivo XML
      vr_cdcooper   NUMBER;             --> C�digo da cooperativa
      vr_nmtela     VARCHAR2(100);      --> Nome da tela/programa que ser� executado
      vr_seqlog     NUMBER;             --> Sequencia de grava��o do LOG
      vr_nmeacao    VARCHAR2(100);      --> A��o que ser� executada para a tela
      vr_cdagenci   VARCHAR2(100);      --> Agencia de opera��o
      vr_nrdcaixa   VARCHAR2(100);      --> N�mero do caixa
      vr_idorigem   VARCHAR2(100);      --> Identifica��o de origem
      vr_cdoperad   VARCHAR2(100);      --> Operador
      vr_xmllog     VARCHAR2(32767);    --> XML para propagar informa��es de LOG
      vr_dscritic   VARCHAR2(4000);     --> Descricao do Erro
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_redir_acao';

      -- Busca qual package/procedure dever� ser executada
      CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE      --> Nome da tela de execu��o
                       ,pr_nmeacao  IN crapaca.nmdeacao%TYPE) IS   --> Nome da a��o de execu��o
        SELECT ca.nmpackag
              ,ca.nmproced
              ,ca.lstparam
        FROM craprdr cr, crapaca ca
        WHERE ca.nrseqrdr = cr.nrseqrdr
          AND cr.nmprogra = UPPER(pr_nmprogra)
          AND ca.nmdeacao = UPPER(pr_nmeacao);
      rw_craprdr cr_craprdr%ROWTYPE;

    BEGIN
      -- Incluido nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
      
      -- Extrair dados do XML de requisi��o
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
        -- Trata mensagen por c�digo - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) ||
                           ' vr_dscritic:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

      -- Gravar solicita��o
      pc_insere_trans(pr_xml      => pr_xml
                     ,pr_cdcooper => vr_cdcooper
                     ,pr_nmdatela => vr_nmtela
                     ,pr_cdoperad => vr_cdoperad
                     ,pr_sequence => vr_seqlog
                     ,pr_nmdeacao => vr_nmeacao
                     ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        -- Trata mensagen por c�digo - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) ||
                           ' vr_dscritic:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

      -- Criar XML com dados de LOG para propagar para os objetos executados
      vr_xmllog := fn_cria_xml_log(pr_cdcooper => vr_cdcooper
                                  ,pr_nmdatela => vr_nmtela
                                  ,pr_nmeacao  => vr_nmeacao
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_cdoperad => vr_cdoperad);

      -- Busca os dados da execu��o solicitada
      OPEN cr_craprdr(vr_nmtela, vr_nmeacao);
      FETCH cr_craprdr INTO rw_craprdr;

      IF cr_craprdr%NOTFOUND THEN
        
      -- Tabela para armazenar as telas para interface web
        -- Inclus�o de mensagen por c�digo - Chmd REQ0011757 - 13/04/2018
        pr_cdcritic := 1212; -- Registro craprdr nao encontrado.        
        -- Verifica se ocorreram erros
        RAISE vr_exc_erro;

      END IF;
      
      
      -- Verificar se existe package cadastrada para execu��o
      IF rw_craprdr.nmpackag IS NOT NULL THEN
        vr_sql := 'begin ' || rw_craprdr.nmpackag || '.';
      ELSE
        vr_sql := 'begin ';
      END IF;

      vr_sql := vr_sql || rw_craprdr.nmproced || '(';

      -- Verifica se existem par�metros adicionais criados
      IF rw_craprdr.lstparam IS NOT NULL THEN
        -- Quebra a string de parametros
        vr_param := gene0002.fn_quebra_string(rw_craprdr.lstparam, ',');
        -- Retorna nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

        -- Itera sobre a string quebrada
        IF vr_param.count > 0 THEN
          FOR idx IN 1..vr_param.count LOOP
            -- Capturar valor do XPath do arquivo XML
            vr_xpath := '/Root/Dados/' || SUBSTR(vr_param(idx), 4, length(vr_param(idx))) || '/text()';

            -- Concatena o comando SQL, caso n�o exista valor na TAG gera par�metro de valor NULL
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

      -- Ordem para executar de forma imediata o SQL din�mico
      EXECUTE IMMEDIATE vr_sql USING OUT pr_cdcritic, OUT pr_dscritic, IN OUT pr_xml, OUT pr_nmdcampo, OUT pr_des_erro;

      -- Verifica se ocorreram erros
      IF pr_des_erro <> 'OK' THEN
        RAISE vr_exc_problema;
      END IF;

      -- Atualiza hist�rico com o XML de resposta
      pc_atualiza_trans(pr_xml      => pr_xml
                       ,pr_seq      => pr_nrseqsol
                       ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        -- Trata mensagen por c�digo - Chmd REQ0011757 - 13/04/2018                                                                
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) ||
                           ' vr_dscritic:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);      
    EXCEPTION
      WHEN vr_exc_problema THEN
        pr_des_erro := 'NOK';
      WHEN vr_exc_erro THEN
        -- Buscar a descri��o - Se foi retornado apenas c�digo
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic, pr_dscritic => pr_dscritic); 
        pr_dscritic := pr_dscritic ||
                       '. pr_nrseqsol:' || pr_nrseqsol;
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0); 
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_nmrotpro      ||
                       '. ' || SQLERRM  ||
                       '. pr_nrseqsol:' || pr_nrseqsol; 
        pr_des_erro := 'NOK';
    END;
  END pc_redir_acao;

  /* Procedures de uso p�blico */

  /* Procedure que ser� a interface entre o Oracle e sistema Web */
  PROCEDURE pc_xml_web(pr_xml_req IN CLOB                --> Arquivo XML de retorno
                      ,pr_xml_res OUT NOCOPY CLOB) IS    --> Arquivo XML de resposta
    -- .................................................................................................
    --
    --  Programa : pc_xml_web
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --
    --   Procedure chamadora: funcoes.php
    --
    --   Objetivo  : Gerenciar interface de comunica��o (requisi��o/resposta) do sistema Web.
    --               Ir� receber um arquivo XML com dados de manipula��o e par�metros de execu��o
    --               para acessar a package/procedure necess�rio e ir� retornar um novo XML com
    --               mensagem de erro ou dados de retorno do processamento.
    --
    --   Alteracoes: 30/04/2014 - Implementa��o do cadastro de a��es para execu��o (Petter - Supero).
    --
    --               17/05/2014 - Implementa��o do controle de acesso (Petter - Supero).
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .................................................................................................
  BEGIN
    DECLARE
      vr_xml        XMLType;               --> Vari�vel do XML de entrada
      vr_erro_xml   XMLType;               --> Vari�vel do XML de erro
      vr_des_erro   VARCHAR2(4000);        --> Vari�vel para armazenar descri��o do erro de execu��o
      vr_cdcooper   PLS_INTEGER := 0;      --> C�digo da cooperativa
      vr_nmdcampo   VARCHAR2(150);         --> Nome do campo da execu��o
      vr_seq        NUMBER;                --> Sequencia do hist�rico de execu��es
      vr_cdcritic   PLS_INTEGER;           --> C�digo da cr�tica
      vr_dscritic   VARCHAR2(4000);        --> Descri��o da cr�tica
      vr_exc_erro   EXCEPTION;             --> Controle de tratamento de erros personalizados
      vr_exc_libe   EXCEPTION;             --> Controle de erros para o processo de libera��o
      vr_conttag    PLS_INTEGER;           --> Contador do n�mero de ocorr�ncias da TAG
      
      -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
      vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_xml_web'; 
      vr_dscriret   VARCHAR2    (3)            := 'OK';

    BEGIN
      -- Incluido nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
      
      -- Criar instancia do XML em mem�ria
      vr_xml := XMLType.createxml(pr_xml_req);
      
      vr_cdcooper := NVL(gene0007.fn_valor_tag(pr_xml => vr_xml, pr_pos_exc => 0, pr_nomtag => 'cdcooper'),0);
      -- Retorna nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

      -- Verifica se existe a TAG de permiss�o
      gene0007.pc_lista_nodo(pr_xml => vr_xml
                            ,pr_nodo => 'Permissao'
                            ,pr_cont => vr_conttag
                            ,pr_des_erro => vr_dscritic);
      --
      -- For�ado erro - Teste Belli - 
      --vr_dscritic := 'Erro pc_lista_nodo: ' || 'ORA-001476 Not Found';
      --
      -- Verifica se ocorreram erros na busca da TAG
      IF vr_dscritic IS NOT NULL THEN
        -- Ajuste codigo e descri��o de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1197;  
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' vr_dscritic:' || vr_dscritic;           
        RAISE vr_exc_erro;
      END IF;
      -- Retorna nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);

      -- Verifica se existe permiss�o de execu��o da tela pelo usu�rio e hora
      IF vr_conttag > 0 THEN
        pc_executa_metodo(pr_xml      => vr_xml
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);      
        -- Verifica se o controle de permiss�o gerou erro ou cr�tica
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_libe;
        END IF;
        -- Retorna nome do m�dulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      END IF;

      -- Gerar requisi��o para web
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
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                         ' vr_dscritic:' || vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        IF vr_dscriret = 'OK' THEN
          -- Propagar XML de erro
          pr_xml_res := vr_erro_xml.getClobVal();
        END IF;

      ELSE
        -- Retorna nome do m�dulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
        -- Propagar XML de sucesso
        pr_xml_res := vr_xml.getClobVal();
      END IF;
      
      -- Limpa nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION      
      WHEN vr_exc_libe THEN                
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        gene0004.pc_log(pr_dscritic => vr_dscritic
                       ,pr_cdcritic => vr_cdcritic                     
                       ,pr_cdcooper => vr_cdcooper
                       );
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
        -- Gerar XML com descri��o do erro para exibi��o no sistema Web
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
        -- Gerar XML com descri��o do erro para exibi��o no sistema Web
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

  /* Procedure para gerenciar a extra��o de dados do XML de envio */
  PROCEDURE pc_extrai_dados(pr_xml      IN XMLType                      --> XML com dados para LOG
                           ,pr_cdcooper OUT NUMBER                      --> C�digo da cooperativa
                           ,pr_nmdatela OUT VARCHAR2                    --> Nome da tela
                           ,pr_nmeacao  OUT VARCHAR2                    --> Nome da a��o
                           ,pr_cdagenci OUT VARCHAR2                    --> Agencia de opera��o
                           ,pr_nrdcaixa OUT VARCHAR2                    --> N�mero do caixa
                           ,pr_idorigem OUT VARCHAR2                    --> Identifica��o de origem
                           ,pr_cdoperad OUT VARCHAR2                    --> Operador
                           ,pr_dscritic OUT VARCHAR2) IS                --> Descri��o da cr�tica
    -- ..........................................................................
    --
    --  Programa : pc_extrai_dados
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Abril/2014.                   Ultima atualizacao: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Extrair dados do XML de requisi��o.
    --
    --   Disparado por 177 programas.
    -- 
    --   Alteracoes: 15/08/2014 - Inserido TRIM (Jean Michel)
    --
    --               13/04/2018 - Trata Others / Seta Modulo / Mensagem fixa
    --                            (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)
    --  
    -- .............................................................................
    --
    -- Variaveis para tratar as criticas - Chmd REQ0011757 - 13/04/2018
    vr_nmrotpro   VARCHAR2  (100)            := 'GENE0004.pc_extrai_dados'; 
    vr_cdcritic   crapcri.cdcritic%TYPE;
  BEGIN
    BEGIN
      -- Incluido nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmrotpro);
      -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
      --DECLARE
      --  vr_teste NUMBER;
      --BEGIN
      --  vr_teste := 0 / 0;
      --END;
      --
      pr_cdcooper := TO_NUMBER(TRIM(pr_xml.extract('/Root/params/cdcooper/text()').getstringval()));
      pr_nmdatela := TRIM(pr_xml.extract('/Root/params/nmprogra/text()').getstringval());
      pr_nmeacao  := TRIM(pr_xml.extract('/Root/params/nmeacao/text()').getstringval());
      pr_cdagenci := TRIM(pr_xml.extract('/Root/params/cdagenci/text()').getstringval());
      pr_nrdcaixa := TRIM(pr_xml.extract('/Root/params/nrdcaixa/text()').getstringval());
      pr_idorigem := TRIM(pr_xml.extract('/Root/params/idorigem/text()').getstringval());
      pr_cdoperad := TRIM(pr_xml.extract('/Root/params/cdoperad/text()').getstringval());
      -- Limpa nome do m�dulo logado Chmd REQ0011757 - 13/04/2018
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
        CECRED.pc_internal_exception(pr_cdcooper => 0);         
        -- Efetuar retorno do erro n�o tratado
        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_nmrotpro ||
                       '. ' || SQLERRM; 
    END;
  END pc_extrai_dados;

  -- ATEN��O N�O UTILIZAR MAIS ESTA PROCEDURE E SIM A pc_trata_exec_job por estar completa  
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
    --   Objetivo  : Validar acesso em tempo de execu��o.
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
    -- Incluido nome do m�dulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0004.' || vr_nmrotpro );
    
    vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_fldiautl:' || pr_fldiautl ||
                   ', pr_flproces:' || pr_flproces ||
                   ', pr_flrepjob:' || pr_flrepjob ||
                   ', pr_flgerlog:' || pr_flgerlog ||
                   ', pr_nmprogra:' || pr_nmprogra;
                   
    -- For�ado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018
    --vr_cdcritic := 0 / 0;
    --
    -- ATEN��O N�O UTILIZAR MAIS ESTA PROCEDURE E SIM A pc_trata_exec_job por estar completa
    --
    -- ESTA PROCEDURE SERA DESATIVADA ASSIM QUE TODOS PROGRAMAS SE CONVERTEREM PARA A pc_trata_exec_job
    --
    -- Chamada para tratar a execu��o de job
    GENE0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                              ,pr_fldiautl => pr_fldiautl --> Flag se deve validar dia util
                              ,pr_flproces => pr_flproces --> Flag se deve validar se esta no processo    
                              ,pr_flrepjob => pr_flrepjob --> Flag para reprogramar o job
                              ,pr_flgerlog => pr_flgerlog --> indicador se deve gerar log
                              ,pr_nmprogra => pr_nmprogra --> Nome do programa que esta sendo executado no job
                              ,pr_intipmsg => vr_intipmsg --> 1 Padr�o:Os programas tratam com a regra atual. 2 Grupo de mensagens para n�o parar o programa.
                              ,pr_cdcritic => vr_cdcritic --> Codigo Critica - Chmd REQ0011757 - 13/04/2018
                              ,pr_dscritic => vr_dscritic --> Descricao Critica
                              );
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN                                                       
      pr_dscritic := vr_dscritic;
    ELSE       
      -- Limpa nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    END IF;      
  EXCEPTION         
    WHEN OTHERS THEN    
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
      -- Efetuar retorno do erro n�o tratado
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
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-in�cio/ F-fim/ O-ocorr�ncia/ E-erro 
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
    --   Objetivo  : Chamar a rotina de Log para grava��o de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN   
    -- Controlar gera��o de log de execu��o dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-in�cio/ F-fim/ O-ocorr�ncia/ E-erro 
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
