CREATE OR REPLACE PACKAGE CECRED.SSCR0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : SSCR0001
  --  Sistema  : Rotinas genericas referente a CADASTRO SCR/GERAÇÃO DE LANCAMENTO/ARQUIVO 3026
  --  Sigla    : CRED
  --  Autor    : Jose Luis Marchezoni - (DB1)
  --  Data     : Setembor - 2015                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a CADASTRO SCR/GERAÇÃO DE LANCAMENTO/ARQUIVO 3026

  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------
  --Tipo de Registros de historico
  TYPE typ_reg_historico IS RECORD --(cadscr.p/tt-historico) 
    (cdhistor craptab.tpregist%TYPE
    ,dshistor craptab.dstextab%TYPE
    ,dstphist VARCHAR(15));
    
  --Tabela para tipo de registro historico  
  TYPE typ_tab_historico IS TABLE OF typ_reg_historico INDEX BY PLS_INTEGER;
  
  --Tipo de registro de lancamento
  TYPE typ_reg_crapscr IS RECORD 
    (cdcooper crapscr.cdcooper%TYPE
    ,nrdconta crapscr.nrdconta%TYPE
    ,dtrefere crapscr.dtrefere%TYPE
    ,cdhistor crapscr.cdhistor%TYPE
    ,vllanmto crapscr.vllanmto%TYPE
    ,dttransm crapscr.dttransm%TYPE
    ,dtmvtolt crapscr.dtmvtolt%TYPE
    ,cdoperad crapscr.cdoperad%TYPE
    ,dtsolici crapscr.dtsolici%TYPE
    ,flgenvio crapscr.flgenvio%TYPE
    ,dshistor craptab.dstextab%TYPE
    ,dstphist VARCHAR(15)); 
  
  --Tabela para tipo de registro de lancamento
  TYPE typ_tab_crapscr IS TABLE OF typ_reg_crapscr INDEX BY PLS_INTEGER;
  
  /* Rotina referente a atualizacao do envio do arquivo SCR */  
  PROCEDURE pc_atualiza_envio_scr_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                      ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                      ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                      ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento   
                                      ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                      ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                      ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                      ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                      ,pr_flgenvio IN VARCHAR2              --Validar arquivo enviado
                                      ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                      ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                      ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                      ,pr_dscritic OUT VARCHAR2);           --Descricao critica
                                      
  -- Procedure responsavel por atualizar os campos que controlam o envio do arquivo para interface Web
  PROCEDURE pc_atualiza_envio_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                      ,pr_flgenvio IN VARCHAR2              --Validar arquivo enviado
                                      ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                      
  /* Rotina referente a consulta historico do Modo Caracter */
  PROCEDURE pc_busca_historico_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                      ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                      ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                      ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                      ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                      ,pr_operacao IN VARCHAR2 DEFAULT NULL --I-Incluir/A-Alterar/E-Excluir
                                      ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                      ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                      ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico,
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                      ,pr_clob_ret OUT CLOB                 --Tabela Historico
                                      ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                      ,pr_dscritic OUT VARCHAR2);           --Descricao Erro
                                      
  -- Rotina referente a busca do historico do para interface Web
  PROCEDURE pc_busca_historico_scr_web (pr_dtmvtolt IN VARCHAR2 DEFAULT NULL --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2 DEFAULT NULL --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico,
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK

  -- Rotina referente a verificacao dos dados iniciais informados 
  PROCEDURE pc_verifica_dados_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                     ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                     ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                     ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                     ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                     ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta                                     
                                     ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do campo de retorno
                                     ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                     ,pr_dscritic OUT VARCHAR2);           --Descricao critica

  -- Rotina referente a verificacao dos dados iniciais informados para interface Web
  PROCEDURE pc_verifica_dados_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                      ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta                                      
                                      ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                      ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
  
  /* Rotina referente a busca do historico do Modo Caracter */
  PROCEDURE pc_busca_lancamento_scr_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                        ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                        ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                        ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                        ,pr_flgvalid IN VARCHAR2              --Validar se existe lancamento
                                        ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);           --Descricao Erro
                                        
  -- Rotina referente a consultas dos dados lancamentos SCR para interface Web                                        
  PROCEDURE pc_busca_lancamento_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                        ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta                                        
                                        ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                        ,pr_flgvalid IN VARCHAR2              --Validar se existe lancamento
                                        ,pr_nrregist IN INTEGER               --Numero Registros
                                        ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                      
  /* Rotina referente a verificacao do arquivo SCR para interface Caracter */
  PROCEDURE pc_verifica_lancamento_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                          ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                          ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                          ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                          ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                          ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                          ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                          ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                          ,pr_flgvalid IN VARCHAR2              --Validar arquivo enviado
                                          ,pr_nmdcampo OUT VARCHAR2             --Nome do campo de retorno
                                          ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                          ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                          ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                          ,pr_dscritic OUT VARCHAR2);           --Descricao critica
                                          
  -- Rotina referente a verificacao do arquivo SCR para interface Web 
  PROCEDURE pc_verifica_lancamento_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                           ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                           ,pr_flgvalid IN VARCHAR2              --Validar arquivo enviado
                                           ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                           ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                           ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                    
  -- Rotina referente a verificacao do arquivo SCR 
  PROCEDURE pc_gera_arquivo_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                   ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                   ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                   ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                   ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                   ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                   ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                   ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                   ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                   ,pr_dsdirscr OUT VARCHAR2             --Diretorio/caminho do arquivo gerado
                                   ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                   ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                   ,pr_dscritic OUT VARCHAR2);           --Descricao critica

  -- Rotina referente a geracao do arquivo SCR para interface Web
  PROCEDURE pc_gera_arquivo_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X)                                     
                                    ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                   
  -- Rotina referente a verificacao do arquivo SCR
  PROCEDURE pc_grava_lancamento_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                       ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                       ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                       ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                       ,pr_vllanmto IN crapscr.vllanmto%TYPE --Valor do lancamento
                                       ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2              --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                       ,pr_clob_ret OUT CLOB                 --Tabela Retorno
                                       ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                       ,pr_dscritic OUT VARCHAR2);           --Descricao Erro
                                       
  -- Rotina referente a gravacao de lancamento SCR para interface Web
  PROCEDURE pc_grava_lancamento_scr_web(pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                       ,pr_vllanmto IN crapscr.vllanmto%TYPE --Valor do lancamento
                                       ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2              --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                   
END SSCR0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSCR0001 AS

  /*---------------------------------------------------------------------------------------------------------------
   Programa: SSCR0001                             
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : José Luís Marchezoni(DB1)
   Data    : 25/09/2015                        Ultima atualizacao: 20/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Agrupar rotinas genericas refente a CADASTRO SCR/GERAÇÃO DE LANCAMENTO/ARQUIVO 3026

   Alteracoes: 07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                           (Adriano).
                           
               20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
                            varias procedures desta package.(Carlos Rafael Tanholi).                            
                           
  ---------------------------------------------------------------------------------------------------------------*/


  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
        ,cop.nrdocnpj
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Procedure responsavel por atualizar os campos que controlam o envio do arquivo  
  PROCEDURE pc_atualiza_envio_scr (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                  ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                  ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                  ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                  ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento    
                                  ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                  ,pr_flgenvio IN VARCHAR2              --Validar arquivo enviado
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                  ,pr_des_erro OUT VARCHAR2) IS             --Erros do processo OK/NOK
                                  
  /*-------------------------------------------------------------------------------------------------------------
    Programa: pc_atualiza_envio_scr      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 25/09/2015                        Ultima atualizacao: 07/12/2015 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para atualizar os flags de envio do arquivo SCR 

    Alteracoes: 25/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                            (Adriano).
                           
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- CURSORES ---------------------------------  
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_dtsolici IN crapscr.dtsolici%TYPE) IS
  SELECT scr.flgenvio
        ,scr.dttransm
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.dtsolici = pr_dtsolici
     ORDER BY scr.nrdconta, scr.dtrefere, scr.cdhistor;
  rw_crapscr cr_crapscr%ROWTYPE;   
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;  

  ------------------------------- VARIÁVEIS --------------------------------
  -- Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  --Controle de sessao
  vr_retornvl VARCHAR2(3):= 'NOK';
  vr_des_reto VARCHAR2(3);   

  -- Variaveis Gerais
  vr_dtsolici DATE:= NULL;
  vr_dttransm DATE:= NULL;
  
  -- Variaveis de Excecoes
  vr_exc_erro EXCEPTION;
  
  -- Variável exceção para locke
  vr_exc_locked EXCEPTION;
  PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

  -- Tabela de retorno do operadores que estao alocando a tabela especifidada
  vr_tab_locktab GENE0001.typ_tab_locktab;
      
  BEGIN          
    --Inicializar Variaveis
    vr_cdcritic := 0;                         
    vr_dscritic := NULL; 
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    BEGIN
      -- Busca o lancamento
      OPEN cr_crapscr(pr_cdcooper => pr_cdcooper,
                      pr_dtsolici => vr_dtsolici);
                      
      FETCH cr_crapscr INTO rw_crapscr;
           
      -- Gerar erro caso não encontre
      IF cr_crapscr%NOTFOUND THEN
         -- Fechar cursor pois teremos raise
         CLOSE cr_crapscr;
         
         -- Sair com erro
         vr_cdcritic := 0;
         vr_dscritic := 'Lancamento SCR nao encontrado!';
         
         RAISE vr_exc_erro;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapscr;
      END IF; 
      
    EXCEPTION
      
      WHEN vr_exc_locked THEN
        -- Verificar se a tabela está em uso      
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPSCR'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => vr_des_reto
                            ,pt_tab_locktab => vr_tab_locktab);
                            
        IF vr_des_reto = 'OK' THEN
          FOR vr_ind IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPSCR)' || 
                           ' - ' || vr_tab_locktab(vr_ind).nmusuari;
          END LOOP;
        END IF;
        
        -- Gera exceção
        RAISE vr_exc_erro;
         
    END;
    
    -- Determinar a data de transmissao conforme o tipo de envio 
    IF pr_flgenvio <> '1' THEN
      vr_dttransm := NULL; -- Se envio for 'Desfazer', opcao 'X, deve limpar a data de transmissao
    ELSE  
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        
        RAISE vr_exc_erro;
      ELSE
        -- Obter a data do sistema
        vr_dttransm := rw_crapdat.dtmvtolt;        

        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
                  
    END IF;      
    
    -- Bloco para atualizacao dos campos de controle
    BEGIN
      
      -- Gravar os campos
      UPDATE crapscr
         SET crapscr.flgenvio = pr_flgenvio
            ,crapscr.dttransm = vr_dttransm
       WHERE crapscr.cdcooper = pr_cdcooper
         AND crapscr.dtsolici = vr_dtsolici;
         
    EXCEPTION
      WHEN OTHERS THEN
        IF vr_dscritic IS NULL THEN
          vr_dscritic := 'Erro ao atualizar o envio do arquivo SCR: '||SQLERRM;
        END IF;
        
        RAISE vr_exc_erro;
    END;
    
    -- Retorno OK
    vr_retornvl := 'OK';
    -- Gravar
    COMMIT;     
    
  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Retorno não OK          
      pr_des_erro := vr_retornvl;
    
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                               
      ROLLBACK;                             

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := vr_retornvl;

      -- Chamar rotina de gravação de erro
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na sscr0001.pc_atualiza_envio_scr --> '|| SQLERRM;
      END IF;
      
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);             
      
      ROLLBACK;
    
  END pc_atualiza_envio_scr;
  
  -- Procedure responsavel por atualizar os campos que controlam o envio do arquivo para interface Caracter
  PROCEDURE pc_atualiza_envio_scr_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                      ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                      ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                      ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                      ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento    
                                      ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                      ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                      ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                      ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X)                                       
                                      ,pr_flgenvio IN VARCHAR2              --Validar arquivo enviado
                                      ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                      ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                      ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                      ,pr_dscritic OUT VARCHAR2) IS         --Descricao critica
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_atualiza_envio_scr_car   Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 29/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para atualizar os flags de envio do arquivo SCR interface Caracter

    Alteracoes: 29/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                            (Adriano).
                           
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para atualizar os dados informados    
    sscr0001.pc_atualiza_envio_scr(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad   --Operador
                                  ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                  ,pr_idorigem => pr_idorigem   --Origem Processamento
                                  ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                  ,pr_flgenvio => pr_flgenvio   --Flag de arquivo enviado
                                  ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                  ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                  
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_atualiza_envio_scr.' || vr_dscritic || vr_des_reto;
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na sscr0001.pc_atualiza_envio_scr_car --> '|| SQLERRM;

  END pc_atualiza_envio_scr_car;

  -- Procedure responsavel por atualizar os campos que controlam o envio do arquivo para interface Web
  PROCEDURE pc_atualiza_envio_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X)
                                      ,pr_flgenvio IN VARCHAR2              --Validar arquivo enviado
                                      ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                                
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_atualiza_envio_scr_web   Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 30/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para atualizar os flags de envio do arquivo SCR interface Web

    Alteracoes: 07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                           
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
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
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Procedura para atualizar os dados informados    
    sscr0001.pc_atualiza_envio_scr(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                  ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                  ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                  ,pr_cdoperad => vr_cdoperad   --Operador
                                  ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                  ,pr_idorigem => vr_idorigem   --Origem Processamento
                                  ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                  ,pr_flgenvio => pr_flgenvio   --Flag de arquivo enviado
                                  ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                  ,pr_des_erro => vr_des_reto);   --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_atualiza_envio_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
                                      
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_atualiza_envio_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_atualiza_envio_scr_web;

  -- Rotina referente a consulta dos historico 
  PROCEDURE pc_busca_historico_scr(pr_cdcooper IN crapcop.cdcooper%type            --Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER DEFAULT NULL             --Codigo Agencia
                                  ,pr_nrdcaixa IN INTEGER DEFAULT NULL             --Numero Caixa
                                  ,pr_cdoperad IN VARCHAR2 DEFAULT NULL            --Operador
                                  ,pr_nmdatela IN VARCHAR2 DEFAULT NULL            --Nome da tela
                                  ,pr_idorigem IN INTEGER DEFAULT NULL             --Origem Processamento
                                  ,pr_cddopcao IN VARCHAR2 DEFAULT NULL            --Codigo da opcao (C,B,L,X) 
                                  ,pr_operacao IN VARCHAR2 DEFAULT NULL            --I-Incluir/A-Alterar/E-Excluir
                                  ,pr_nrdconta IN INTEGER DEFAULT NULL             --Numero da conta
                                  ,pr_dtsolici IN VARCHAR2 DEFAULT NULL            --Data de solicitacao
                                  ,pr_dtrefere IN VARCHAR2 DEFAULT NULL            --Data de referencia
                                  ,pr_cdhistor IN VARCHAR2 DEFAULT NULL            --Codigo do historico  
                                  ,pr_tab_historico OUT sscr0001.typ_tab_historico --Tabela Historico
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro           --Tabela Erros
                                  ,pr_des_erro OUT VARCHAR2) IS                    --Erros do processo
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_historico_scr       Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 18/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a busca de histórico para arquivo SCR

    Alteracoes: 18/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  --Selecionar informacoes da tabela de historicos
  CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT tab.cdcooper
        ,tab.nmsistem
        ,tab.tptabela
        ,tab.cdempres
        ,tab.cdacesso
        ,tab.tpregist
        ,tab.dstextab            
    FROM craptab tab
   WHERE tab.cdcooper = pr_cdcooper
     AND UPPER(tab.nmsistem) = '3026'
     AND UPPER(tab.tptabela) = 'CONFIG'
     AND tab.cdempres = 0
     AND UPPER(tab.cdacesso) = 'CONTAS3026';
  rw_craptab cr_craptab%ROWTYPE;    
  
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_nrdconta IN crapscr.nrdconta%TYPE,  
                     pr_dtsolici IN crapscr.dtsolici%TYPE,
                     pr_dtrefere IN crapscr.dtrefere%TYPE,
                     pr_cdhistor IN crapscr.cdhistor%TYPE) IS
  SELECT scr.cdhistor
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.nrdconta = pr_nrdconta
     AND scr.dtsolici = pr_dtsolici
     AND scr.dtrefere = pr_dtrefere
     AND scr.cdhistor = pr_cdhistor     
     ORDER BY scr.nrdconta, scr.dtrefere, scr.cdhistor;
  rw_crapscr cr_crapscr%ROWTYPE;   
        
  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 
  
  --Variaveis de Indice
  vr_index VARCHAR(200);

  --Controle de sessao  
  vr_retornvl VARCHAR2(3):= 'NOK';
  
  --Variaveis gerais
  vr_dtsolici DATE;
  vr_dtrefere DATE;
  vr_criarhis VARCHAR2(2):= NULL;
      
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       

  BEGIN
    --Inicializando a variável index
    vr_index := 0;
    
    IF pr_cddopcao IN ('C','L') THEN
      -- Converter a data de solicitacao para tipo DATE
      vr_dtsolici := TO_DATE(pr_dtsolici,'DD/MM/RRRR');
      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');    
    END IF;
           
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
     RAISE vr_exc_erro;
     
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
 
    -- Leitura para busca de historicos
    FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
      -- Criar o historico
      vr_criarhis := '1';
      
      -- Verificar se e necessario buscar o lancamento    
      IF pr_cddopcao IN ('C','L')  THEN       
        -- Busca o lancamento
        OPEN cr_crapscr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_dtsolici => vr_dtsolici,
                        pr_dtrefere => vr_dtrefere,
                        pr_cdhistor => TO_NUMBER(rw_craptab.tpregist));
                        
        FETCH cr_crapscr INTO rw_crapscr;
             
        -- Deve existir lancamento se a opcao for consulta
        IF cr_crapscr%NOTFOUND THEN                    
          -- Verificar se o registro existe para as opcoes Consulta e/ou Lancamento com oper. Excluir/Alterar
          IF pr_cddopcao = 'C' OR (pr_cddopcao = 'C' AND pr_operacao IN ('E','A')) THEN
            vr_criarhis := '0';
          END IF;        
        END IF;  
        -- Fechar o cursor
        CLOSE cr_crapscr;
      END IF;

      -- Nao cria o historico
      IF vr_criarhis = '0' THEN
        CONTINUE;
      END IF;
      
      vr_index:= vr_index + 1; 

      -- Atribuir para a tabela temporaria      
      pr_tab_historico(vr_index).cdhistor := rw_craptab.tpregist;
      pr_tab_historico(vr_index).dshistor := rw_craptab.dstextab;
      
      -- Definir o tipo do historico
      IF SUBSTR(rw_craptab.dstextab,1,1) = 'A' THEN  
        pr_tab_historico(vr_index).dstphist := 'ATIVO';    
      ELSIF SUBSTR(rw_craptab.dstextab,1,1) = 'P' THEN  
        pr_tab_historico(vr_index).dstphist := 'PASSIVO';    
      ELSIF SUBSTR(rw_craptab.dstextab,1,1) = 'R' THEN  
        pr_tab_historico(vr_index).dstphist := 'RESULTADO';  
      END IF;
        
    END LOOP;      
     
    -- Retorno OK
    pr_des_erro:= 'OK';
                 
  EXCEPTION 
    WHEN vr_exc_erro THEN      
      -- Retorno não OK          
      pr_des_erro:= vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na sscr0001.pc_busca_historico_scr --> '|| SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

  END pc_busca_historico_scr;

  -- Rotina referente a busca do historico do para interface Caracter 
  PROCEDURE pc_busca_historico_scr_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                       ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                       ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                       ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2 DEFAULT NULL --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico,
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                       ,pr_clob_ret OUT CLOB                 --Tabela Historico
                                       ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                       ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_historico_src_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 21/09/2015                        Ultima atualizacao: 07/12/2015 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de historicos para interface Caracter

    Alteracoes: 21/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                            (Adriano).
                           
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  vr_tab_historico sscr0001.typ_tab_historico;

  --Variaveis Arquivo Dados
  vr_dstexto VARCHAR2(32767);
  vr_string  VARCHAR2(32767);
      
  --Variaveis de Indice
  vr_index PLS_INTEGER;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Limpar tabela dados
    vr_tab_historico.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Buscar os historicos
    sscr0001.pc_busca_historico_scr(pr_cdcooper => pr_cdcooper           --Codigo Cooperativa
                                   ,pr_cdagenci => pr_cdagenci           --Codigo Agencia
                                   ,pr_nrdcaixa => pr_nrdcaixa           --Numero Caixa
                                   ,pr_cdoperad => pr_cdoperad           --Operador
                                   ,pr_nmdatela => pr_nmdatela           --Nome da tela
                                   ,pr_idorigem => pr_idorigem           --Origem Processamento
                                   ,pr_cddopcao => pr_cddopcao
                                   ,pr_operacao => pr_operacao
                                   ,pr_nrdconta => pr_nrdconta --Numero da conta
                                   ,pr_dtsolici => pr_dtsolici --Data de solicitacao
                                   ,pr_dtrefere => pr_dtrefere --Data de referencia
                                   ,pr_cdhistor => pr_cdhistor --Codigo do historico
                                   ,pr_tab_historico => vr_tab_historico --Tabela Historicos
                                   ,pr_tab_erro => vr_tab_erro           --Tabela Erros
                                   ,pr_des_erro => vr_des_reto);         --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic := 'Erro ao executar a sscr0001.pc_busca_historico_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;      
    END IF;
                                        
    --Montar CLOB
    IF vr_tab_historico.COUNT > 0 THEN        
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clob_ret, TRUE); 
      dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
      
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
       
      --Buscar Primeiro historico
      vr_index := vr_tab_historico.FIRST;
      
      --Percorrer todos os historicos
      WHILE vr_index IS NOT NULL LOOP
        vr_string:= '<hist>'||
                    '<cdhistor>'||NVL(TO_CHAR(vr_tab_historico(vr_index).cdhistor),'0')|| '</cdhistor>'|| 
                    '<dshistor>'||NVL(TO_CHAR(vr_tab_historico(vr_index).dshistor),' ')|| '</dshistor>'|| 
                    '<dstphist>'||NVL(TO_CHAR(vr_tab_historico(vr_index).dstphist),' ')|| '</dstphist>'||
                    '</hist>';
                    
        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);   
                                                  
        --Proximo Registro
        vr_index := vr_tab_historico.NEXT(vr_index);          
      END LOOP;  
      
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '</root>' 
                             ,pr_fecha_xml      => TRUE);                                                   
    END IF;
                                       
    --Retorno
    pr_des_erro := 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      --Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';        
      pr_cdcritic := 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic := 'Erro na sscr0001.pc_busca_historico_scr_car --> '|| SQLERRM;

  END pc_busca_historico_scr_car;
  
  -- Rotina referente a busca do historico do para interface Web
  PROCEDURE pc_busca_historico_scr_web (pr_dtmvtolt IN VARCHAR2 DEFAULT NULL --Data Movimento
                                       ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2 DEFAULT NULL --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico,
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_historico_src_web       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de historicos para interface Web

    Alteracoes: 01/10/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;  
  vr_tab_historico sscr0001.typ_tab_historico;
  
  --Variaveis de Indice
  vr_index PLS_INTEGER;
  
  --Variaveis Locais
  vr_nrregist INTEGER;
  vr_auxconta PLS_INTEGER:= 0;
    
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar os historicos
    sscr0001.pc_busca_historico_scr(pr_cdcooper => vr_cdcooper           --Codigo Cooperativa
                                   ,pr_cdagenci => vr_cdagenci           --Codigo Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa           --Numero Caixa
                                   ,pr_cdoperad => vr_cdoperad           --Operador
                                   ,pr_nmdatela => vr_nmdatela           --Nome da tela
                                   ,pr_idorigem => vr_idorigem           --Origem Processamento
                                   ,pr_cddopcao => pr_cddopcao
                                   ,pr_operacao => pr_operacao
                                   ,pr_nrdconta => pr_nrdconta --Numero da conta
                                   ,pr_dtsolici => pr_dtsolici --Data de solicitacao
                                   ,pr_dtrefere => pr_dtrefere --Data de referencia
                                   ,pr_cdhistor => pr_cdhistor --Codigo do historico
                                   ,pr_tab_historico => vr_tab_historico --Tabela Historicos
                                   ,pr_tab_erro => vr_tab_erro           --Tabela Erros
                                   ,pr_des_erro => vr_des_reto);         --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_busca_historico_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Montar CLOB
    IF vr_tab_historico.COUNT > 0 THEN

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
              
      --Buscar Primeiro historico
      vr_index := vr_tab_historico.FIRST;
      
      --Percorrer todos os historicos
      WHILE vr_index IS NOT NULL LOOP

        -- Insere as tags dos campos da PLTABLE de historicos
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdhistor', pr_tag_cont => TO_CHAR(vr_tab_historico(vr_index).cdhistor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dshistor', pr_tag_cont => TO_CHAR(vr_tab_historico(vr_index).dshistor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstphist', pr_tag_cont => TO_CHAR(vr_tab_historico(vr_index).dstphist), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtsolici', pr_tag_cont => TO_CHAR(pr_dtsolici), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(pr_nrdconta), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtrefere', pr_tag_cont => TO_CHAR(pr_dtrefere), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdhistor', pr_tag_cont => TO_CHAR(pr_cdhistor), pr_des_erro => vr_dscritic);


        -- Incrementa contador p/ posicao no XML
        vr_auxconta := vr_auxconta + 1;

        -- Proximo Registro
        vr_index := vr_tab_historico.NEXT(vr_index);
        
      END LOOP;
      
    ELSE            
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
    END IF;
                                       
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_busca_historico_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_busca_historico_scr_web;  
  
  -- Rotina referente a verificacao dos dados iniciais informados
  PROCEDURE pc_verifica_dados_scr (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                  ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                  ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                  ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                  ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                  ,pr_dtsolici IN VARCHAR2 DEFAULT NULL  --Data de solicitacao
                                  ,pr_dtrefere IN VARCHAR2 DEFAULT NULL  --Data de referencia
                                  ,pr_nrdconta IN INTEGER DEFAULT NULL   --Numero da conta
                                  ,pr_cddopcao IN VARCHAR2               --Codigo da opcao (C,B,L,X)              
                                  ,pr_nmdcampo OUT VARCHAR2              --Nome do Campo
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                  ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_dados_scr        Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 18/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  :     Rotina para verificar os dados nessarios para a geração/consulta/alteracao de lancamentos

    Alteracoes: 18/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- CURSORES ---------------------------------
  -- Buscar os feriados
  CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                   ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
  SELECT fer.cdcooper
        ,fer.dtferiad
    FROM crapfer fer
   WHERE fer.cdcooper = pr_cdcooper 
     AND fer.dtferiad = pr_dtferiad;
  rw_crapfer cr_crapfer%ROWTYPE;
  
  -- Selecionar informacoes dos associados
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
  SELECT ass.nrdconta
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  ------------------------------- VARIÁVEIS --------------------------------    
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 
  
  --Controle de sessao
  vr_retornvl VARCHAR2(3):= 'NOK';  
  
  --Variaves gerais
  vr_dtmvtolt DATE;
  vr_nmdcampo VARCHAR(20);
  vr_dtrefere DATE;
  vr_dtsolici DATE;
      
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       

  BEGIN
  
    -- Verificacoes de comportamento e validacoes conforme a opcao escolhida
    IF pr_cddopcao <> 'C' AND (pr_dtsolici IS NULL OR pr_dtsolici = '') THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Informe a data de solicitacao.';
      vr_nmdcampo := 'dtsolici';

      RAISE vr_exc_erro;
    END IF;   
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtrefere := to_date(pr_dtrefere,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de referencia invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      vr_nmdcampo := 'dtsolici';
      
     RAISE vr_exc_erro;
     
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF; 
    
    -- Verificacao para o opcao de Lancamentos
    IF pr_cddopcao = 'L' THEN 
      -- Deve informar a data de referencia      
      IF vr_dtrefere IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe a data de referencia.';
        vr_nmdcampo := 'dtrefere';
        
        RAISE vr_exc_erro;
      END IF;                  
  
      -- Deve informar o nr. da conta    
      IF pr_nrdconta IS NULL OR pr_nrdconta = 0 THEN  
        vr_cdcritic := 0;          
        vr_dscritic := 'Informe a conta/dv do associdado.';  
        vr_nmdcampo := 'nrdconta';          
                        
        -- Gerar excecao
        RAISE vr_exc_erro;
      END IF;                            
    END IF;                        
                                                                                                
    -- Verificacao da data de referencia para o opcao de Lancamentos
    IF vr_dtrefere IS NOT NULL THEN    
         
      IF TO_CHAR(vr_dtrefere,'MM') = '12' THEN 
        --Assume o primeiro dia do ano seguinte
        vr_dtmvtolt := TO_CHAR(TO_DATE('01/01' || TO_NUMBER(TO_CHAR(vr_dtrefere,'RRRR') + 1),'MM/DD/RRRR'));                
      ELSE        
        -- Assume o primeiro dia do mês seguinte
        vr_dtmvtolt := TRUNC(ADD_MONTHS(vr_dtrefere,1),'mm');
      END IF;
      
      vr_dtmvtolt := TO_DATE(TO_CHAR(vr_dtmvtolt - 1,'DD/MM/RRRR'),'DD/MM/RRRR');                                              
      
      -- Verificar se data e em dia util
      WHILE vr_dtmvtolt > vr_dtrefere LOOP
        
        OPEN cr_crapfer(pr_cdcooper, vr_dtmvtolt);

        FETCH cr_crapfer INTO rw_crapfer;

        -- Feriado ou domingo
        IF cr_crapfer%FOUND OR TO_CHAR(vr_dtmvtolt, 'D') IN (1,7) THEN
          -- Retrocede 1(um) dia para posicionar em dia util
          vr_dtmvtolt := vr_dtmvtolt - 1;

          -- Fechar o cursor
          CLOSE cr_crapfer;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapfer;
          
          EXIT;
        END IF;
                
      END LOOP;
      
      IF vr_dtrefere <> vr_dtmvtolt THEN
        vr_cdcritic := 0;          
        vr_dscritic := 'Data invalida. Deve ser o ultimo dia util do mes.';
        vr_nmdcampo := 'dtrefere';                    
           
        RAISE vr_exc_erro;          
      END IF;
    END IF; -- IF pr_dtrefere
    
    -- Verificar se a conta informada existe
    IF pr_nrdconta > 0 THEN
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN                     
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        
        -- Montar mensagem de critica
        vr_cdcritic := 9;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        -- Posicionar no campo 
        vr_nmdcampo:= 'nrdconta';
             
        RAISE vr_exc_erro; 
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
    END IF; -- IF pr_nrdconta
                
  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro:= vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
                           
      pr_nmdcampo := vr_nmdcampo;
  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na sscr0001.pc_verifica_dados_scr --> '|| SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  

      pr_nmdcampo := vr_nmdcampo;
      
  END pc_verifica_dados_scr;  
  
  -- Rotina referente a verificacao dos dados iniciais informados para interface Caracter
  PROCEDURE pc_verifica_dados_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                     ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                     ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                     ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                     ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                     ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta                                     
                                     ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do campo de retorno
                                     ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                     ,pr_dscritic OUT VARCHAR2) IS         --Descricao critica
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_dados_src_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 21/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Verificar dados iniciais informados em interface caracter

    Alteracoes: 21/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;

  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para verificacao dos dados informados
    sscr0001.pc_verifica_dados_scr(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad   --Operador
                                  ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                  ,pr_idorigem => pr_idorigem   --Origem Processamento                              
                                  ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                  ,pr_dtrefere => pr_dtrefere   --Data de referencia
                                  ,pr_nrdconta => pr_nrdconta   --Numero da conta
                                  ,pr_cddopcao => pr_cddopcao   --Codigo da opcao (C,B,L,X)                             
                                  ,pr_nmdcampo => pr_nmdcampo   --Nome do campo de retorno                     
                                  ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                  ,pr_des_erro => vr_des_reto); --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_verifica_dados_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na sscr0001.pc_verifica_dados_scr_car --> '|| SQLERRM;

  END pc_verifica_dados_scr_car;    
  
  -- Rotina referente a verificacao dos dados iniciais informados para interface Web
  PROCEDURE pc_verifica_dados_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                      ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                      ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta                                      
                                      ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                      ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_dados_src_web       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Verificar dados iniciais informados em interface Web

    Alteracoes: 01/10/2015 - Desenvolvimento - José Luís (DB1)
                
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
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
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
                                                             
    -- Procedura para gerar o arquivo
    sscr0001.pc_verifica_dados_scr(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                  ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                  ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                  ,pr_cdoperad => vr_cdoperad   --Operador
                                  ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                  ,pr_idorigem => vr_idorigem   --Origem Processamento 
                                  ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                  ,pr_dtrefere => pr_dtrefere   --Data de referencia
                                  ,pr_nrdconta => pr_nrdconta   --Numero da conta
                                  ,pr_cddopcao => pr_cddopcao   --Codigo da opcao (C,B,L,X)
                                  ,pr_nmdcampo => pr_nmdcampo   --Nome do campo
                                  ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                  ,pr_des_erro => vr_des_reto); --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_verifica_dados_scr_web.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
                                      
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_verifica_dados_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_verifica_dados_scr_web;

  -- Rotina referente a consultas dos dados lancamentos SCR
  PROCEDURE pc_busca_lancamento_scr (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                    ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                    ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                    ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                    ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                    ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                    ,pr_dtsolici IN VARCHAR2 DEFAULT NULL  --Data de solicitacao
                                    ,pr_dtrefere IN VARCHAR2 DEFAULT NULL  --Data de referencia
                                    ,pr_nrdconta IN INTEGER DEFAULT NULL   --Numero da conta
                                    ,pr_cddopcao IN VARCHAR2               --Codigo da opcao (C,B,L,X)  
                                    ,pr_flgvalid IN VARCHAR2               --Validar se existe lancamento
                                    ,pr_tab_crapscr OUT sscr0001.typ_tab_crapscr --Tabela Lancamentos
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                    ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_lancamento_scr       Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 22/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para consulta dos lancamentos SCR 

    Alteracoes: 22/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_nrdconta IN crapscr.nrdconta%TYPE,
                     pr_dtsolici IN crapscr.dtsolici%TYPE,
                     pr_dtrefere IN crapscr.dtrefere%TYPE) IS
  SELECT scr.cdcooper
        ,scr.nrdconta
        ,scr.dtrefere
        ,scr.cdhistor
        ,scr.vllanmto
        ,scr.dttransm
        ,scr.dtmvtolt
        ,scr.cdoperad
        ,scr.dtsolici
        ,scr.flgenvio
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND (pr_nrdconta IS NULL OR pr_nrdconta = 0 OR scr.nrdconta = pr_nrdconta)
     AND (pr_dtsolici IS NULL OR scr.dtsolici = pr_dtsolici)
     AND (pr_dtrefere IS NULL OR scr.dtrefere = pr_dtrefere);
  rw_crapscr cr_crapscr%ROWTYPE;

  ------------------------------- VARIÁVEIS --------------------------------    
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 

  vr_des_reto VARCHAR2(3); 
  
  --Controle de sessao
  vr_retornvl VARCHAR2(3):= 'NOK';  
  
  --Variaveis gerais
  vr_dtsolici DATE;
  vr_dtrefere DATE;
   
  --Variaveis de Indice
  vr_index VARCHAR(200);
  vr_index_hist VARCHAR2(200);

  vr_operacao VARCHAR2(500);

  vr_cdhistor VARCHAR2(50);

  vr_dstphist VARCHAR2(20);

  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;   

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;  

  BEGIN    
    --Inicializando a variável index
    vr_index := 0;
    vr_index_hist := 0;
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtrefere := to_date(pr_dtrefere,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de referencia invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;  
           
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
     RAISE vr_exc_erro;
     
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF; 

    -- Leitura para busca de lancamentos
    FOR rw_crapscr IN cr_crapscr(pr_cdcooper,pr_nrdconta,TO_DATE(vr_dtsolici),TO_DATE(vr_dtrefere)) LOOP    

      vr_index:= vr_index + 1; 
      vr_dstextab := '';
      
      pr_tab_crapscr(vr_index).cdcooper := rw_crapscr.cdcooper;
      pr_tab_crapscr(vr_index).nrdconta := rw_crapscr.nrdconta;
      pr_tab_crapscr(vr_index).dtrefere := rw_crapscr.dtrefere;
      pr_tab_crapscr(vr_index).cdhistor := rw_crapscr.cdhistor;
      pr_tab_crapscr(vr_index).vllanmto := rw_crapscr.vllanmto;
      pr_tab_crapscr(vr_index).dttransm := rw_crapscr.dttransm;
      pr_tab_crapscr(vr_index).dtmvtolt := rw_crapscr.dtmvtolt;
      pr_tab_crapscr(vr_index).cdoperad := rw_crapscr.cdoperad;
      pr_tab_crapscr(vr_index).dtsolici := rw_crapscr.dtsolici;
      pr_tab_crapscr(vr_index).flgenvio := rw_crapscr.flgenvio;
      

      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => '3026'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'CONTAS3026'
                                               ,pr_tpregist => rw_crapscr.cdhistor);               
 
      -- Se encontrar registro
      IF TRIM(vr_dstextab) IS NOT NULL THEN
        
        -- Definir o tipo do historico
        IF SUBSTR(vr_dstextab,1,1) = 'A' THEN  
          pr_tab_crapscr(vr_index).dstphist := 'ATIVO';    
        ELSIF SUBSTR(vr_dstextab,1,1) = 'P' THEN  
          pr_tab_crapscr(vr_index).dstphist := 'PASSIVO';    
        ELSIF SUBSTR(vr_dstextab,1,1) = 'R' THEN  
          pr_tab_crapscr(vr_index).dstphist := 'RESULTADO';  
        END IF;

        pr_tab_crapscr(vr_index).dshistor := vr_dstextab;
        
      END IF;
      
    END LOOP;      

    IF pr_flgvalid = '1' AND vr_index IN (0,NULL) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Nenhum lancamento cadastrado na tabela SCR';
      
      RAISE vr_exc_erro;      
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro:= vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na sscr0001.pc_busca_lancamento_scr --> '|| SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  

  END pc_busca_lancamento_scr;  

  -- Rotina referente a consultas dos dados lancamentos SCR para interface Caracter
  PROCEDURE pc_busca_lancamento_scr_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                        ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                        ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                        ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                        ,pr_flgvalid IN VARCHAR2              --Validar se existe lancamento
                                        ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela Retorno
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_lancamento_scr_Car   Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 22/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para consulta dos lancamentos SCR para interface Caracter

    Alteracoes: 22/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  vr_tab_crapscr sscr0001.typ_tab_crapscr;

  --Variaveis Arquivo Dados
  vr_dstexto VARCHAR2(32767);
  vr_string  VARCHAR2(32767);
      
  --Variaveis de Indice
  vr_index PLS_INTEGER;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;
  
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Limpar tabela dados
    vr_tab_crapscr.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Buscar os historicos
    sscr0001.pc_busca_lancamento_scr(pr_cdcooper => pr_cdcooper       --Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci       --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa       --Numero Caixa
                                    ,pr_cdoperad => pr_cdoperad       --Operador
                                    ,pr_nmdatela => pr_nmdatela       --Nome da tela
                                    ,pr_idorigem => pr_idorigem       --Origem Processamento
                                    ,pr_dtsolici => pr_dtsolici       --Data de solicitacao
                                    ,pr_dtrefere => pr_dtrefere       --Data de referencia
                                    ,pr_nrdconta => pr_nrdconta       --Numero da conta
                                    ,pr_cddopcao => pr_cddopcao       --Codigo da opcao
                                    ,pr_flgvalid => pr_flgvalid       --Validar se existe lancamento
                                    ,pr_tab_crapscr => vr_tab_crapscr --Tabela Lancamentos
                                    ,pr_tab_erro => vr_tab_erro       --Tabela Erros
                                    ,pr_des_erro => vr_des_reto);     --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_busca_lancamento_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;      
    END IF;
                                        
    --Montar CLOB
    IF vr_tab_crapscr.COUNT > 0 THEN        
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clob_ret, TRUE); 
      dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
      
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
       
      --Buscar Primeiro historico
      vr_index:= vr_tab_crapscr.FIRST;
      
      --Percorrer todos os historicos
      WHILE vr_index IS NOT NULL LOOP
        vr_string:= '<lancto>'||
                    '<cdcooper>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).cdcooper),'0')|| '</cdcooper>'|| 
                    '<nrdconta>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).nrdconta),'0')|| '</nrdconta>'|| 
                    '<dtrefere>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).dtrefere,'DD/MM/RRRR'),' ')|| '</dtrefere>'||                    
                    '<cdhistor>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).cdhistor),'0')|| '</cdhistor>'|| 
                    '<dshistor>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).dshistor),' ')|| '</dshistor>'|| 
                    '<dstphist>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).dstphist),' ')|| '</dstphist>'|| 
                    '<vllanmto>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).vllanmto),' ')|| '</vllanmto>'|| 
                    '<dttransm>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).dttransm,'DD/MM/RRRR'),' ')|| '</dttransm>'||                    
                    '<cdoperad>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).cdoperad),' ')|| '</cdoperad>'|| 
                    '<dtsolici>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).dtsolici,'DD/MM/RRRR'),' ')|| '</dtsolici>'||                     
                    '<flgenvio>'||NVL(TO_CHAR(vr_tab_crapscr(vr_index).flgenvio),'0')|| '</flgenvio>'|| 
                    '</lancto>';
                    
        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);   
                                                  
        --Proximo Registro
        vr_index:= vr_tab_crapscr.NEXT(vr_index);          
      END LOOP;  
      
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '</root>' 
                             ,pr_fecha_xml      => TRUE);                                                   
    END IF;
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na sscr0001.pc_busca_lancamento_scr_car --> '|| SQLERRM;

  END pc_busca_lancamento_scr_car;      

  -- Rotina referente a consultas dos dados lancamentos SCR para interface Web
  PROCEDURE pc_busca_lancamento_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                        ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                        ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X)
                                        ,pr_flgvalid IN VARCHAR2              --Validar se existe lancamento
                                        ,pr_nrregist IN INTEGER               --Numero Registros
                                        ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_busca_lancamento_scr_web   Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para consulta dos lancamentos SCR para interface Web

    Alteracoes: 01/10/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;
  vr_tab_crapscr sscr0001.typ_tab_crapscr;
  
  --Variaveis de Indice
  vr_index PLS_INTEGER;
  
  --Variaveis Locais
  vr_nrregist INTEGER;
  vr_qtregist INTEGER := 0;
  vr_auxconta PLS_INTEGER:= 0;
  
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_nrregist:= pr_nrregist;
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar os lancamentos
    sscr0001.pc_busca_lancamento_scr(pr_cdcooper => vr_cdcooper       --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci       --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa       --Numero Caixa
                                    ,pr_cdoperad => vr_cdoperad       --Operador
                                    ,pr_nmdatela => vr_nmdatela       --Nome da tela
                                    ,pr_idorigem => vr_idorigem       --Origem Processamento
                                    ,pr_dtsolici => pr_dtsolici       --Data de solicitacao
                                    ,pr_dtrefere => pr_dtrefere       --Data de referencia
                                    ,pr_nrdconta => pr_nrdconta       --Numero da conta
                                    ,pr_cddopcao => pr_cddopcao       --Codigo da opcao
                                    ,pr_flgvalid => pr_flgvalid       --Validar se existe lancamento
                                    ,pr_tab_crapscr => vr_tab_crapscr --Tabela Lancamentos
                                    ,pr_tab_erro => vr_tab_erro       --Tabela Erros
                                    ,pr_des_erro => vr_des_reto);     --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_busca_lancamento_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   
             
    --Montar CLOB
    IF vr_tab_crapscr.COUNT > 0 THEN

      --Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
              
      --Buscar Primeiro lancamento
      vr_index := vr_tab_crapscr.FIRST;
      
      --Percorrer todos os lancamentos
      WHILE vr_index IS NOT NULL LOOP

        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          --Proximo Registro
          vr_index:= vr_tab_crapscr.NEXT(vr_index); 
          --Proximo
          CONTINUE;  
        END IF; 
        
        IF vr_nrregist > 0 THEN 
          
          -- Insere as tags dos campos da PLTABLE de lancamentos
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).cdcooper), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).nrdconta), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtrefere', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).dtrefere, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdhistor', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).cdhistor), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vllanmto', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).vllanmto), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dttransm', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).dttransm, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdoperad', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).cdoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtsolici', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).dtsolici, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgenvio', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).flgenvio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dstphist', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).dstphist), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dshistor', pr_tag_cont => TO_CHAR(vr_tab_crapscr(vr_index).dshistor), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
        
        -- Proximo Registro
        vr_index := vr_tab_crapscr.NEXT(vr_index);
        
      END LOOP;
      
    ELSE            
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
    END IF;
              
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
                     
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_busca_lancamento_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_busca_lancamento_scr_web;  

  -- Rotina referente a verificacao do arquivo SCR 
  PROCEDURE pc_verifica_lancamento_scr (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                       ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                       ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                       ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL  --Data de solicitacao
                                       ,pr_flgvalid IN VARCHAR2               --Validar arquivo enviado
                                       ,pr_nmdcampo OUT VARCHAR2              --Nome do Campo
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                       ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_lancamento_scr        Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 22/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para verificar se o arquivo SCR pode ser processado

    Alteracoes: 22/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_dtsolici IN crapscr.dtsolici%TYPE) IS
  SELECT scr.flgenvio
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.dtsolici = pr_dtsolici;
  rw_crapscr cr_crapscr%ROWTYPE;   
  
  ------------------------------- VARIÁVEIS --------------------------------    
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 
  
  --Controle de sessao
  vr_retornvl VARCHAR2(3):= 'NOK';

  --Variaveis gerais
  vr_flgenvio VARCHAR(3):= '0';
  vr_dtsolici DATE;  
  vr_nmdcampo VARCHAR(20);
      
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       

  BEGIN
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
     RAISE vr_exc_erro;
     
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF; 
    
    -- Verificar os lancamentos
    OPEN cr_crapscr (pr_cdcooper => pr_cdcooper,
                     pr_dtsolici => vr_dtsolici);
    
    FETCH cr_crapscr INTO rw_crapscr;
    
    -- Se não encontrar registro
    IF cr_crapscr%NOTFOUND THEN                     
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapscr;
      
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Nenhum lancamento cadastrado na tabela SCR.';
      -- Posicionar no campo 
      vr_nmdcampo:= 'dtsolici';
           
      RAISE vr_exc_erro; 
    ELSE
      -- Verificar se o arquivo foi gerado
      vr_flgenvio := rw_crapscr.flgenvio;
    
      -- Apenas fechar o cursor
      CLOSE cr_crapscr;
    END IF;
    
    -- A opcao determina se valida ou nao o envio do arquivo
    IF vr_flgenvio = '1' AND pr_flgvalid = '1' THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Arquivo SCR referente a ' || pr_dtsolici || ' ja foi gerado.';
      -- Posicionar no campo 
      vr_nmdcampo:= 'dtsolici';
      
      RAISE vr_exc_erro;       
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro:= vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
                           
      pr_nmdcampo := vr_nmdcampo;
  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na sscr0001.pc_verifica_lancamento_scr --> '|| SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  

  END pc_verifica_lancamento_scr;    
  
  -- Rotina referente a verificacao do arquivo SCR para interface Caracter
  PROCEDURE pc_verifica_lancamento_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                          ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                          ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                          ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                          ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                          ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                          ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                          ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                          ,pr_flgvalid IN VARCHAR2              --Validar arquivo enviado
                                          ,pr_nmdcampo OUT VARCHAR2             --Nome do campo de retorno
                                          ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                          ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                          ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                          ,pr_dscritic OUT VARCHAR2) IS         --Descricao critica
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_lancamento_src_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para verificar se o arquivo SCR pode ser processado em interface Caracter

    Alteracoes: 01/10/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para verificacao dos dados informados
    sscr0001.pc_verifica_lancamento_scr(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                       ,pr_idorigem => pr_idorigem   --Origem Processamento                              
                                       ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                       ,pr_flgvalid => pr_flgvalid   --Validar arquivo enviado
                                       ,pr_nmdcampo => pr_nmdcampo   --Nome do campo de retorno
                                       ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                       ,pr_des_erro => vr_des_reto); --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_verifica_lancamento_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na sscr0001.pc_verifica_lancamento_scr_car --> '|| SQLERRM;

  END pc_verifica_lancamento_scr_car;  

  -- Rotina referente a verificacao do arquivo SCR para interface Web 
  PROCEDURE pc_verifica_lancamento_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                           ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X) 
                                           ,pr_flgvalid IN VARCHAR2              --Validar arquivo enviado
                                           ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                           ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                           ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_verifica_lancamento_scr_web     Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para verificar se o arquivo SCR pode ser processado em interface Web

    Alteracoes: 01/10/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------  
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
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
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Procedura para gerar o arquivo
    sscr0001.pc_verifica_lancamento_scr(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                       ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                       ,pr_cdoperad => vr_cdoperad   --Operador
                                       ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                       ,pr_idorigem => vr_idorigem   --Origem Processamento 
                                       ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                       ,pr_flgvalid => pr_flgvalid   --Validar arquivo enviado
                                       ,pr_nmdcampo => pr_nmdcampo   --Nome do campo de retorno
                                       ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                       ,pr_des_erro => vr_des_reto); --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_verifica_lancamento_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
                                      
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_verifica_lancamento_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_verifica_lancamento_scr_web;

  -- Rotina referente a geracao do arquivo SCR 
  PROCEDURE pc_gera_arquivo_scr (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                ,pr_dtsolici IN VARCHAR2 DEFAULT NULL  --Data de solicitacao
                                ,pr_dsdirscr OUT VARCHAR2              --Diretório do arquivo gerado
                                ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_gera_arquivo_scr        Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 22/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gerar o arquivo SCR 

    Alteracoes: 22/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
 
  ------------------------------- CURSORES ---------------------------------
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_dtsolici IN crapscr.dtsolici%TYPE) IS
  SELECT scr.flgenvio
        ,scr.nrdconta
        ,scr.dtrefere
        ,scr.cdhistor
        ,scr.vllanmto      
        ,ROW_NUMBER() OVER(PARTITION BY scr.nrdconta 
                           ORDER BY scr.nrdconta, scr.dtrefere) first_of_nrdconta
        ,ROW_NUMBER() OVER(PARTITION BY scr.nrdconta, scr.dtrefere 
                           ORDER BY scr.nrdconta, scr.dtrefere) first_of_dtrefere
        ,COUNT(1)     OVER(PARTITION BY scr.nrdconta) last_of_nrdconta
        ,COUNT(1)     OVER(PARTITION BY scr.nrdconta, scr.dtrefere) last_of_dtrefere          
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.dtsolici = pr_dtsolici
   ORDER BY scr.nrdconta, scr.dtrefere DESC, scr.cdhistor;
  rw_crapscr cr_crapscr%ROWTYPE;   
  
  -- Busca os lancamentos SCR com valor de lancamento
  CURSOR cr_crapscr_aux (pr_cdcooper IN crapscr.cdcooper%TYPE,
                         pr_dtsolici IN crapscr.dtsolici%TYPE,
                         pr_nrdconta IN crapscr.nrdconta%TYPE,
                         pr_dtrefere IN crapscr.dtrefere%TYPE) IS
  SELECT scr.vllanmto      
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.dtsolici = pr_dtsolici
     AND scr.nrdconta = pr_nrdconta
     AND scr.dtrefere = pr_dtrefere
     AND (scr.vllanmto IS NOT NULL AND scr.vllanmto <> 0) ;
  rw_crapscr_aux cr_crapscr_aux%ROWTYPE;   
  
  -- Selecionar Cpf/Cnpj do associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                   pr_nrdconta IN crapass.nrdconta%TYPE) IS
  SELECT ass.nrcpfcgc
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  ------------------------------- VARIÁVEIS --------------------------------    
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 
  
  --Variaveis de Tabela de memória
  vr_tab_erro gene0001.typ_tab_erro;

  --Controle de sessao
  vr_retornvl VARCHAR2(3):= 'NOK';    
 
  --Variaveis gerais
  vr_dtsolici DATE;
  vr_nrdocnpj VARCHAR2(18):= NULL;
  vr_nrcpfcgc VARCHAR2(18):= NULL;
  vr_flgvalor VARCHAR2(1):= '0';
  vr_database VARCHAR2(10):= NULL;
  vr_dtrefere VARCHAR2(10):= NULL;
  vr_qtbalanc INTEGER:= 0;
  vr_lastcont INTEGER:= 0;
  vr_lastdtre INTEGER:= 0;        
  vr_impcabec BOOLEAN:= FALSE; -- Controle para imprimir cabecalho e tag clisol
  vr_impcliso BOOLEAN:= FALSE;      
  vr_contaatu VARCHAR2(20):= NULL;
  
  -- registros do arquivo
  vr_des_xml  CLOB;          
  vr_nmarquiv VARCHAR2(1000);
  vr_descabec VARCHAR2(5000);
  vr_deslinha VARCHAR2(5000);
  
  -- variaveis para manipulação dos arquivos
  vr_typ_saida  VARCHAR2(100);
  vr_comando    VARCHAR2(4000);
  vr_nom_direto VARCHAR2(5000); -- diretorio padrao da coop
      
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
  
  --------------------------- SUBROTINAS INTERNAS --------------------------
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
  BEGIN
    --Escrever no arquivo CLOB
    dbms_lob.writeappend(vr_des_xml,length(pr_des_dados||CHR(13)),pr_des_dados||CHR(13));
  END; -- PROCEDURE pc_escreve_clob
  
  --------------------------------- PRINCIPAL ------------------------------
  BEGIN
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      
     RAISE vr_exc_erro;
     
    ELSE
      -- Atribuir o nr. do CNPJ
      vr_nrdocnpj := sscr0001.rw_crapcop.nrdocnpj;
      
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF; 
    
    vr_impcliso := FALSE;
    vr_impcabec := FALSE;      
    
    -- Verificar se existem lancamentos para gerar o arquivo
    OPEN cr_crapscr (pr_cdcooper => pr_cdcooper,
                     pr_dtsolici => vr_dtsolici);
                                                                    	
    FETCH cr_crapscr INTO rw_crapscr;
    
    -- Se não encontrar
    IF cr_crapscr%NOTFOUND THEN
       -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Nenhum lancamento cadastrado na tabela SCR.';
     
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapscr;
      
      RAISE vr_exc_erro;       
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapscr;
    END IF;
    
    -- Inicializar clob
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);                                           
    
    -- Buscar os lancamentos para gerar o arquivo
    FOR rw_crapscr IN cr_crapscr(pr_cdcooper,vr_dtsolici) LOOP
      -- Converte a data de referencia
      vr_dtrefere := TO_CHAR(rw_crapscr.dtrefere,'DD/MM/RRRR'); 

      -- Se for o primeiro registro da conta (FIRST-OF nrdconta)
      IF vr_contaatu IS NULL OR vr_contaatu <> rw_crapscr.nrdconta THEN
        -- Atualizar a conta atual
        vr_contaatu := rw_crapscr.nrdconta;
        -- Para controlar last-of
        vr_lastcont := 0;
        -- Inicializar variavel de controle de valor
        vr_flgvalor := '0';
        --  Inicializar variavel de qtd.de balancos         
        vr_qtbalanc := 0;
        
        -- Buscar o Cpf/Cnpj do associado
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapscr.nrdconta);
        
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se não encontrar registro
        IF cr_crapass%NOTFOUND THEN                     
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;
          
          -- Montar mensagem de critica
          vr_cdcritic := 9;
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
               
          RAISE vr_exc_erro; 
        ELSE
          -- Nr. do Cpf/Cnpj do associado
          vr_nrcpfcgc := rw_crapass.nrcpfcgc;  
        
          -- Apenas fechar o cursor
          CLOSE cr_crapass;
        END IF;
    
        -- Imprimir tag apos a primeira interacao que escreveu o cabecalho    
        IF vr_impcliso = TRUE THEN 
          -- Abrir tag <Cli>          
          pc_escreve_clob('    <CliSol TpAtlz="I">');
          
          -- Tipo e Cpf/Cnpj do associado
          vr_deslinha := '      <Cli TpCli="2">' || SUBSTR(vr_nrcpfcgc,1,8) || '</Cli>';
          pc_escreve_clob(vr_deslinha);
        END IF;
      END IF;  
      
      -- Para controlar o last-of
      vr_lastcont := vr_lastcont + 1;
      
      -- Se for o primeiro registro da data de referencia (FIRST-OF dtrefere)
      IF rw_crapscr.first_of_dtrefere = 1 THEN
      -- Para controlar o last-of          
        vr_lastdtre := 0;        
      
        -- Verificar se existe lancamento com valor diferente de zero
        OPEN cr_crapscr_aux (pr_cdcooper => pr_cdcooper,
                             pr_dtsolici => vr_dtsolici,
                             pr_nrdconta => rw_crapscr.nrdconta,
                             pr_dtrefere => rw_crapscr.dtrefere);
            
        FETCH cr_crapscr_aux INTO rw_crapscr_aux;
        
        -- Se não encontrar registro
        IF cr_crapscr_aux%FOUND THEN                     
          -- Setar flag de lancamento com valor
          vr_flgvalor := '1';
          
          -- Determinar a data base
          IF vr_database IS NULL OR rw_crapscr.dtrefere > TO_DATE(vr_database,'DD/MM/RRRR') THEN
            vr_database := TO_CHAR(rw_crapscr.dtrefere,'DD/MM/RRRR');
          END IF;
          
          -- Controle de balanços cadastrados
          vr_qtbalanc := vr_qtbalanc + 1;
        
          -- Fechar o cursor
          CLOSE cr_crapscr_aux;
        END IF; -- IF cr_crapscr_aux%FOUND
        
        -- Escrever o cabecalho
        IF vr_impcabec = FALSE THEN 
          -- Montar o cabecalho
          vr_descabec := '<?xml version="1.0" encoding="UTF-8" ?>';
          vr_deslinha := '<Doc3026 DtBase="' 
                         || TO_CHAR(TO_DATE(vr_database,'DD/MM/RRRR'),'RRRR') || '-' 
                         || TO_CHAR(TO_DATE(vr_database,'DD/MM/RRRR'),'MM')   || '" CNPJ="' 
                         || SUBSTR(vr_nrdocnpj,1,8)                           || '" TpArq="N">';                  
          
          -- Escrevendo o cabecalho no CLOB
          pc_escreve_clob(vr_descabec);
          pc_escreve_clob(vr_deslinha);
          
          -- Inicia tag de bloco do XML
          pc_escreve_clob('  <BlocoCliSol>');
        
          -- Abrir tag <Cli>          
          pc_escreve_clob('    <CliSol TpAtlz="I">');
          
          -- Tipo e Cpf/Cnpj do associado
          vr_deslinha := '      <Cli TpCli="2">' || SUBSTR(vr_nrcpfcgc,1,8) || '</Cli>';
          pc_escreve_clob(vr_deslinha);
          
          -- Marcar para que o cabecalho nao seja impresso novamente
          vr_impcabec := TRUE;
          -- Se houve outra interacao first-of da conta, monta a tag
          vr_impcliso := TRUE;
        END IF;
        
        -- Escrever tags para balanco
        pc_escreve_clob('      <Balanco>');
        
        vr_deslinha := '        <DtBalanco>'||TO_CHAR(TO_DATE(vr_dtrefere,'DD/MM/RRRR'),'RRRR')||'-'
                       ||TO_CHAR(TO_DATE(vr_dtrefere,'DD/MM/RRRR'),'MM')||'-'
                       ||TO_CHAR(TO_DATE(vr_dtrefere,'DD/MM/RRRR'),'DD')||'</DtBalanco>';
        -- Data referencia e cpf/cnpj
        pc_escreve_clob(vr_deslinha);
        
        -- <PartBalanco>
        vr_deslinha := '        <PartBalanco TpPart="2">' || SUBSTR(vr_nrcpfcgc,1,8) || '</PartBalanco>';
        
        pc_escreve_clob(vr_deslinha);
      END IF; -- IF current_of_dtrefere = 1
      
      -- Para controlar o last-of          
        vr_lastdtre := vr_lastdtre + 1;
        
      -- Escrever tag VlrRubr
      IF vr_flgvalor = '1' THEN
        vr_deslinha := '        <VlrRubr CodRubr="'||TRIM(TO_CHAR(rw_crapscr.cdhistor,'999'))||'">'||
                       TRIM(TO_CHAR(REPLACE(TO_CHAR(rw_crapscr.vllanmto),',',''),'9999999990.00'))
                       ||'</VlrRubr>';
        pc_escreve_clob(vr_deslinha);          
      END IF;
                          
      -- Verificar a ultima interacao da DATA DE REFERENCIA (LAST-OF)
      IF vr_lastdtre = rw_crapscr.last_of_dtrefere THEN
        -- Fechar tag <Balanco>
        pc_escreve_clob('      </Balanco>');
      END IF; -- IF rw_crapscr.first_of_dtrefere     
      
      -- Verificar a quantidade de balancos na ultima interacao da CONTA (LAST-OF)
      IF vr_lastcont = rw_crapscr.last_of_nrdconta THEN
        -- Testar a quantidade de balancos
        IF vr_qtbalanc <> 3 THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'E necessario cadastrar 3 balancos. Conta/dv: ' || TO_CHAR(rw_crapscr.nrdconta) || '-' || TO_CHAR(vr_dtrefere) || ' .';
   
          -- Interromper o processamento
          RAISE vr_exc_erro;
        END IF; -- IF vr_qtbalanc
        
        -- Fechar a tag CliSol
        pc_escreve_clob('    </CliSol>' );          
        
      END IF; -- IF rw_crapscr.current_of_nrdconta        
      
    END LOOP; -- FOR rw_crapscr
    
    -- Fecha tag de bloco
    pc_escreve_clob('  </BlocoCliSol>');
    -- Fecha tab principal
    pc_escreve_clob('</Doc3026>');
    
    -- Fechar o arquivo (EXPORT) para o diretorio temporario      

    -- Preparar o arquivo
    vr_nmarquiv := '3026' || TO_CHAR(vr_dtsolici,'RRRR') 
                          || TO_CHAR(vr_dtsolici,'MM') || '.xml';                                                            
                          
    
    -- Busca do diretório base da cooperativa para a geração de relatórios
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => pr_cdcooper);
                     
    -- Escreve o clob no arquivo físico
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                 ,pr_caminho  => vr_nom_direto||'/contab'
                                 ,pr_arquivo  => vr_nmarquiv
                                 ,pr_des_erro => vr_dscritic);

    -- Realizar a conversão do arquivo
    gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                ,pr_nmarquiv => vr_nom_direto||'/contab/'||vr_nmarquiv
                                ,pr_nmarqenv => vr_nmarquiv
                                ,pr_des_erro => vr_dscritic);  
    
    /*  Copiar arquivo para a pasta salvar  */
    vr_comando:= 'cp '||vr_nom_direto||'/contab/'||vr_nmarquiv||' '||vr_nom_direto||'/contab/'||' 2> /dev/null';

    --Executar o comando no unix
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    -- Testar erro
    IF vr_typ_saida = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv ||' para a pasta salvar';
      RAISE vr_exc_erro;
    END IF;   
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);      
    
    -- Atualizar os campos de controle do envio
    sscr0001.pc_atualiza_envio_scr(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_dtsolici => pr_dtsolici
                                  ,pr_flgenvio => '1'
                                  ,pr_tab_erro => vr_tab_erro  
                                  ,pr_des_erro => pr_des_erro);
                                    
    IF pr_des_erro <> 'OK' THEN
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_atualiza_envio_scr.' || vr_dscritic;
      END IF;

      RAISE vr_exc_erro;
    END IF;   
    
    -- Retornar o path onde foi gerado o arquivo    
    pr_dsdirscr   := vr_nom_direto||'/contab/'||vr_nmarquiv;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro := vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na sscr0001.pc_gera_arquivo_scr --> '|| SQLERRM;
      END IF;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  

  END pc_gera_arquivo_scr;    

  -- Rotina referente a geracao do arquivo SCR para interface Caracter
  PROCEDURE pc_gera_arquivo_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                   ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                   ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                   ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                   ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                   ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                   ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                   ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                   ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                   ,pr_dsdirscr OUT VARCHAR2             --Diretorio/caminho do arquivo gerado
                                   ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --Tabela de Retorno
                                   ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                   ,pr_dscritic OUT VARCHAR2) IS         --Descricao critica
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_gera_arquivo_src_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 23/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gerar o arquivo SCR em interface Caracter

    Alteracoes: 23/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para verificacao dos dados informados
    sscr0001.pc_gera_arquivo_scr(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                ,pr_cdoperad => pr_cdoperad   --Operador
                                ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                ,pr_idorigem => pr_idorigem   --Origem Processamento 
                                ,pr_dtsolici => pr_dtsolici   --Data de solicictacao
                                ,pr_dsdirscr => pr_dsdirscr   --Diretorio/caminho do arquivo geracao
                                ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_gera_arquivo_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro em sscr0001.pc_gera_arquivo_scr_car --> '|| SQLERRM;

  END pc_gera_arquivo_scr_car;
  
  -- Rotina referente a geracao do arquivo SCR para interface Web
  PROCEDURE pc_gera_arquivo_scr_web (pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                    ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --Codigo da opcao (C,B,L,X)                                     
                                    ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_gera_arquivo_src_web       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 01/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gerar o arquivo SCR em interface web      

    Alteracoes: 01/10/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
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

  vr_dsdirscr VARCHAR2(100);
  
  --Variaveis Arquivo Dados
  vr_dtmvtolt DATE;

  vr_auxconta PLS_INTEGER:= 0;
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Procedura para gerar o arquivo
    sscr0001.pc_gera_arquivo_scr(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                ,pr_cdoperad => vr_cdoperad   --Operador
                                ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                ,pr_idorigem => vr_idorigem   --Origem Processamento 
                                ,pr_dtsolici => pr_dtsolici   --Data de solicictacao
                                ,pr_dsdirscr => vr_dsdirscr   --Diretorio/caminho do arquivo geracao
                                ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_gera_arquivo_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;    

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
        
    -- Insere as tags dos campos da PLTABLE de bancos      
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdirscr', pr_tag_cont => TO_CHAR(vr_dsdirscr), pr_des_erro => vr_dscritic);
                   
                                      
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_gera_arquivo_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_gera_arquivo_scr_web;
  
  -- Procedure responsavel por gravar os dados para opcoes Inclur, Alterardo e Excluir lancamentos
  PROCEDURE pc_grava_lancamento_scr (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                    ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                    ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                    ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                    ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                    ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                    ,pr_nrdconta IN INTEGER DEFAULT NULL   --Numero da conta
                                    ,pr_dtsolici IN VARCHAR2 DEFAULT NULL  --Data de solicitacao
                                    ,pr_dtrefere IN VARCHAR2 DEFAULT NULL  --Data de referencia
                                    ,pr_cdhistor IN VARCHAR2 DEFAULT NULL  --Codigo do historico
                                    ,pr_vllanmto IN crapscr.vllanmto%TYPE  --Valor do lancamento
                                    ,pr_cddopcao IN VARCHAR2               --Codigo da opcao (C,B,L,X) 
                                    ,pr_operacao IN VARCHAR2               --I-Incluir/A-Alterar/E-Excluir
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                    ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_grava_lancamento_scr Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 28/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gravar os lancamentos SCR - Incluir/Alterar/Excluir - [I/A/E]

    Alteracoes: 28/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- CURSORES ---------------------------------  
  -- Busca os lancamentos SCR
  CURSOR cr_crapscr (pr_cdcooper IN crapscr.cdcooper%TYPE,
                     pr_nrdconta IN crapscr.nrdconta%TYPE,  
                     pr_dtsolici IN crapscr.dtsolici%TYPE,
                     pr_dtrefere IN crapscr.dtrefere%TYPE,
                     pr_cdhistor IN crapscr.cdhistor%TYPE) IS
  SELECT scr.vllanmto
    FROM crapscr scr
   WHERE scr.cdcooper = pr_cdcooper
     AND scr.nrdconta = pr_nrdconta
     AND scr.dtsolici = pr_dtsolici
     AND scr.dtrefere = pr_dtrefere
     AND scr.cdhistor = pr_cdhistor     
     ORDER BY scr.nrdconta, scr.dtrefere, scr.cdhistor;
  rw_crapscr cr_crapscr%ROWTYPE;   
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;  

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3);   
  
  --Variaveis Gerais
  vr_retornvl VARCHAR2(3):= 'NOK';
  vr_lancamen VARCHAR2(1):= '0';
  vr_dtmvtolt VARCHAR2(12):= NULL;
  vr_dtsolici DATE;
  vr_dtrefere DATE;
  
  --Variaveis de Excecoes
  vr_exc_ok    EXCEPTION;
  vr_exc_erro  EXCEPTION;
  
  -- Variável exceção para locke
  vr_exc_locked EXCEPTION;
  PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

  -- Tabela de retorno do operadores que estao alocando a tabela especifidada
  vr_tab_locktab gene0001.typ_tab_locktab;
      
  BEGIN          
    --Inicializar Variaveis
    vr_cdcritic := 0;                         
    vr_dscritic := NULL;   
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtsolici := to_date(pr_dtsolici,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de solicitacao invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    BEGIN                                                  
      --Pega a data movimento e converte para "DATE"
      vr_dtrefere := to_date(pr_dtrefere,'DD/MM/RRRR');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        --Monta mensagem de critica
        vr_dscritic := 'Data de referencia invalida.';
        
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    IF TRIM(pr_vllanmto) IS NULL THEN
      
      vr_cdcritic := 0;                         
      vr_dscritic := 'Valor nao informado.';
      
      -- Gerar a excecao 
      RAISE vr_exc_erro;  
    
    END IF;
    
    IF pr_operacao NOT IN('I','A','E') THEN
      vr_cdcritic := 0;                         
      vr_dscritic := 'Operacao informada invalida: "'||pr_cddopcao||'", deve ser I-Incluir/A-Alterar/E-Excluir';
      
      -- Gerar a excecao 
      RAISE vr_exc_erro;          
    END IF;
    
    BEGIN
      -- Busca o lancamento
      OPEN cr_crapscr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtsolici => vr_dtsolici,
                      pr_dtrefere => vr_dtrefere,
                      pr_cdhistor => TO_NUMBER(pr_cdhistor));
                      
      FETCH cr_crapscr INTO rw_crapscr;
           
      -- Determinar se a opcao eh de inclusao
      IF cr_crapscr%NOTFOUND THEN
        -- Verificar se o registro existe se a opcao for Excluir
        IF pr_operacao IN ('E','A') THEN
          -- Antes de excluir, validar se o registro realmente existe
          IF vr_dscritic IS NULL THEN
            vr_cdcritic := 0;                         
            vr_dscritic := 'Registro da tabela SCR nao encontrado.';
          END IF;
         
          -- Gerar a excecao 
          RAISE vr_exc_erro;          
        END IF;        
        -- Nao existe lancamento
        vr_lancamen := '0';

        -- Fechar o cursor
        CLOSE cr_crapscr;
      ELSE
        -- Existe lancamento
        vr_lancamen := '1';        
        -- Fechar o cursor
        CLOSE cr_crapscr;
      END IF; 
                  
    EXCEPTION
      
      WHEN vr_exc_locked THEN
        -- Verificar se a tabela está em uso      
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPSCR'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => vr_des_reto
                            ,pt_tab_locktab => vr_tab_locktab);
                            
        IF vr_des_reto = 'OK' THEN
          FOR vr_ind IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPSCR)' || 
                           ' - ' || vr_tab_locktab(vr_ind).nmusuari;
          END LOOP;
        END IF;
        
        -- Gera exceção
        RAISE vr_exc_erro;         
    END;
    
    -- Opcao de exclusao
    IF pr_operacao = 'E' THEN      
      -- Excluir o lancamento SCR
      BEGIN
        DELETE FROM crapscr
         WHERE crapscr.cdcooper = pr_cdcooper
           AND crapscr.nrdconta = pr_nrdconta
           AND crapscr.dtsolici = vr_dtsolici
           AND crapscr.dtrefere = vr_dtrefere
           AND crapscr.cdhistor = pr_cdhistor;
           
      EXCEPTION
        WHEN OTHERS THEN
              IF vr_dscritic IS NULL THEN
                vr_dscritic := 'Erro ao deletar os dados na tabela Lancamento SCR: '||SQLERRM;
              END IF;
        RAISE vr_exc_erro;
         
      END;            
      
    -- Atualizacao dos campos para inclusao e alteracao      
    ELSIF pr_operacao IN ('I','A') THEN      
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        
        RAISE vr_exc_erro;
      ELSE
        -- Obter a data do sistema
        vr_dtmvtolt := rw_crapdat.dtmvtolt;        
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
                  
      -- Se existir lancamento, deve atualizar/alterar os campos determinados, mesmo para opcao Incluir
      IF vr_lancamen = '1' THEN          
        BEGIN
          -- Gravar os campos para opcao A-Alteracao
          UPDATE crapscr
             SET crapscr.vllanmto = TO_NUMBER(pr_vllanmto)
                ,crapscr.dtmvtolt = TO_DATE(vr_dtmvtolt)
                ,crapscr.cdoperad = pr_cdoperad            
           WHERE crapscr.cdcooper = pr_cdcooper
             AND crapscr.nrdconta = pr_nrdconta
             AND crapscr.dtsolici = vr_dtsolici
             AND crapscr.dtrefere = vr_dtrefere
             AND crapscr.cdhistor = TO_NUMBER(pr_cdhistor);
             
          EXCEPTION             
            WHEN OTHERS THEN
              IF vr_dscritic IS NULL THEN
                vr_dscritic := 'Erro ao gravar os dados na tabela Lancamento SCR: '||SQLERRM;
              END IF;
          
            RAISE vr_exc_erro;
        END; -- IF vr_lancamen = '1'                   
        
      ELSE        
        
        -- Se nao existir o registor, deve incluir se opcao for "I"
        IF pr_operacao = 'I' THEN
          -- Inserir um novo registro
          BEGIN
            INSERT INTO crapscr 
                   (cdcooper
                   ,nrdconta
                   ,dtsolici
                   ,dtrefere
                   ,dtmvtolt
                   ,cdhistor
                   ,vllanmto
                   ,cdoperad)
            VALUES (pr_cdcooper
                   ,pr_nrdconta
                   ,vr_dtsolici
                   ,vr_dtrefere
                   ,vr_dtmvtolt
                   ,TO_NUMBER(pr_cdhistor)
                   ,pr_vllanmto
                   ,pr_cdoperad);
      
            EXCEPTION
              WHEN OTHERS THEN
                IF vr_dscritic IS NULL THEN
                  vr_dscritic := 'Erro ao inserir os dados na tabela Lancamento SCR: '||SQLERRM;
                END IF;
                  
              RAISE vr_exc_erro;
          END; -- BEGIN        
            
        END IF; -- IF pr_operacao = "I" 
      END IF; -- incluir lancamento
    END IF; -- ELSIF pr_operacao IN ('I','A')
      
    -- Retorno OK
    vr_retornvl := 'OK';    
    
    -- Concluir a transacao
    COMMIT;
    
  -- Tratamento de excecoes
  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Retorno não OK          
      pr_des_erro := vr_retornvl;
    
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      ROLLBACK;                             

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := vr_retornvl;

      -- Chamar rotina de gravação de erro
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na sscr0001.pc_atualiza_envio_scr --> '|| SQLERRM;
      END IF;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      ROLLBACK;
    
  END pc_grava_lancamento_scr;
  
  -- Rotina referente a gravacao de lancamento SCR para interface Caracter 
  PROCEDURE pc_grava_lancamento_scr_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                       ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                       ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                       ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                       ,pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                       ,pr_vllanmto IN crapscr.vllanmto%TYPE --Valor do lancamento
                                       ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2              --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                       ,pr_clob_ret OUT CLOB                 --Tabela Retorno
                                       ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                       ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_grava_lancamento_scr_car   Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 29/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gravar os lancamentos SCR, Incluir/Alterar/Excluir[I/A/E], interface carater

    Alteracoes: 29/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;
  
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para verificacao dos dados informados
    sscr0001.pc_grava_lancamento_scr(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                    ,pr_cdoperad => pr_cdoperad   --Operador
                                    ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                    ,pr_idorigem => pr_idorigem   --Origem Processamento
                                    ,pr_nrdconta => pr_nrdconta   --Numero da conta
                                    ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                    ,pr_dtrefere => pr_dtrefere   --Data de referencia
                                    ,pr_cdhistor => pr_cdhistor   --Codigo do historico
                                    ,pr_vllanmto => pr_vllanmto   --Valor do lancamento
                                    ,pr_cddopcao => pr_cddopcao   --Codigo da opcao (C,B,L,X) 
                                    ,pr_operacao => pr_operacao   --I-Incluir/A-Alterar/E-Excluir
                                    ,pr_tab_erro => vr_tab_erro   --Tabela Erros                                    
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_grava_lancamento_scr.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro:= 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';        
      pr_cdcritic:= 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na sscr0001.pc_grava_lancamento_scr_car --> '|| SQLERRM;

  END pc_grava_lancamento_scr_car;
  
  -- Rotina referente a gravacao de lancamento SCR para interface Web
  PROCEDURE pc_grava_lancamento_scr_web(pr_nrdconta IN INTEGER DEFAULT NULL  --Numero da conta
                                       ,pr_dtsolici IN VARCHAR2 DEFAULT NULL --Data de solicitacao
                                       ,pr_dtrefere IN VARCHAR2 DEFAULT NULL --Data de referencia
                                       ,pr_cdhistor IN VARCHAR2 DEFAULT NULL --Codigo do historico
                                       ,pr_vllanmto IN crapscr.vllanmto%TYPE --Valor do lancamento
                                       ,pr_cddopcao IN VARCHAR2              --Codigo da opcao (C,B,L,X) 
                                       ,pr_operacao IN VARCHAR2              --I-Incluir/A-Alterar/E-Excluir
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                                               
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_grava_lancamento_scr_web Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 30/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para gravar os lancamentos SCR, Incluir/Alterar/Excluir[I/A/E], interface web

    Alteracoes: 07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                 
  ---------------------------------------------------------------------------------------------------------------*/

  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
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
  
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Procedura para verificacao dos dados informados
    sscr0001.pc_grava_lancamento_scr(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                    ,pr_cdoperad => vr_cdoperad   --Operador
                                    ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                    ,pr_idorigem => vr_idorigem   --Origem Processamento
                                    ,pr_nrdconta => pr_nrdconta   --Numero da conta
                                    ,pr_dtsolici => pr_dtsolici   --Data de solicitacao
                                    ,pr_dtrefere => pr_dtrefere   --Data de referencia
                                    ,pr_cdhistor => pr_cdhistor   --Codigo do historico
                                    ,pr_vllanmto => pr_vllanmto   --Valor do lancamento
                                    ,pr_cddopcao => pr_cddopcao   --Codigo da opcao (C,B,L,X) 
                                    ,pr_operacao => pr_operacao   --I-Incluir/A-Alterar/E-Excluir
                                    ,pr_tab_erro => vr_tab_erro   --Tabela Erros                                    
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_grava_lancamento_scr.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
                                      
    --Retorno
    pr_des_erro:= 'OK';    

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
      pr_dscritic:= 'Erro na sscr0001.pc_grava_lancamento_scr_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                       
  END pc_grava_lancamento_scr_web;  
  
END SSCR0001;
/
