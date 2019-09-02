CREATE OR REPLACE PACKAGE CECRED.ESTE0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0001
      Sistema  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Março/2016.                   Ultima atualizacao: 08/03/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
	  --> Funcao para formatar o numero em decimal conforme padrao da IBRATAN
  FUNCTION fn_decimal_ibra (pr_numero IN number) RETURN NUMBER;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra (pr_data IN DATE) RETURN VARCHAR2;
	
  --> Funcao que retorna o ultimo Protocolo de Análise Automática do Motor
  FUNCTION fn_protocolo_analise_auto (pr_cdcooper IN NUMBER
                                     ,pr_nrdconta IN NUMBER
                                     ,pr_nrctremp IN NUMBER) RETURN tbgen_webservice_aciona.dsprotocolo%TYPE;
  
  --> Funcao que retorna o ultimo Protocolo de Análise Automática do Motor via Web
  PROCEDURE pr_protocolo_analise_auto_web (pr_nrdconta IN NUMBER
                                          ,pr_nrctremp IN NUMBER
                                          ,pr_xmllog   IN VARCHAR2 -- XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);        -- Erros do processo
                                
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                  pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                            
                                  pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operado
                                  pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                  pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                  pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                  ---- OUT ----
                                  pr_proposta OUT JSON,                   --> Retorno do clob em modelo json da proposta de emprestimo
                                  pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                  pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                  
  --> Procedimento para verificar se deve permitir o envio de email para o comite
  PROCEDURE pc_verifica_email_comite (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                      ---- OUT ----                                        
                                      pr_flgenvio OUT NUMBER,                 --> Retorno de deve permitir email de email (0-nao 1-sim)
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica

  --> Procedimento para verificar se deve permitir o envio de email para o comite versao web mensageria
  PROCEDURE pc_verifica_email_comite_web ( pr_nrdconta IN  VARCHAR2              -- Numero da conta do cooperado
                                          ,pr_nrctremp IN  craphis.cdhistor%TYPE -- Numero da proposta de emprestimo                                        
                                          ,pr_xmllog   IN  VARCHAR2              -- XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);            -- Erros do processo
                                          
  PROCEDURE pc_busca_param_ibra(pr_cdcooper       in crapcop.cdcooper%type  -- Codigo da cooperativa
                               ,pr_tpenvest       in varchar2 default null  --> Tipo de envio C - Consultar(Get)
                               ,pr_host_esteira  out varchar2               -- Host da esteira
                               ,pr_recurso_este  out varchar2               -- URI da esteira
                               ,pr_dsdirlog      out varchar2               -- Diretorio de log dos arquivos
                               ,pr_autori_este   out varchar2               -- Chave de acesso
                               ,pr_chave_aplica  out varchar2               -- App Key
                               ,pr_dscritic      out varchar2 ); 
                                          
  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                        pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                        pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                        ---- OUT ----                                        
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                        
  --> Rotina para alterar o numero da proposta no acionamento
  PROCEDURE pc_alter_nrctrprp_aciona( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica

  --> Rotina para converter arquivo(pdf) para CLOB em base64 para ser enviado via JSON                                    
  PROCEDURE pc_arq_para_clob_base64(pr_nmarquiv     IN VARCHAR2,
                                    pr_json_value_arq OUT json_value,
                                    pr_dscritic    OUT VARCHAR2);
                                      
  --> Extrair a descricao de critica do jsson de retorno
  FUNCTION fn_retorna_critica (pr_jsonreto IN VARCHAR2) RETURN VARCHAR2;
   
  --> Rotina responsavel por gravar registro de log de acionamento
  PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbgen_webservice_aciona.cdcooper%TYPE, 
                                 pr_cdagenci                 IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
                                 pr_cdoperad                 IN tbgen_webservice_aciona.cdoperad%TYPE, 
                                 pr_cdorigem                 IN tbgen_webservice_aciona.cdorigem%TYPE, 
                                 pr_nrctrprp                 IN tbgen_webservice_aciona.nrctrprp%TYPE, 
                                 pr_nrdconta                 IN tbgen_webservice_aciona.nrdconta%TYPE, 
                                 pr_cdcliente                IN tbgen_webservice_aciona.cdcliente%TYPE DEFAULT 1, 
                                 pr_tpacionamento            IN tbgen_webservice_aciona.tpacionamento%TYPE, 
                                 pr_dsoperacao               IN tbgen_webservice_aciona.dsoperacao%TYPE, 
                                 pr_dsuriservico             IN tbgen_webservice_aciona.dsuriservico%TYPE, 
                                 pr_dsmetodo                 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT 'POST',
                                 pr_dtmvtolt                 IN tbgen_webservice_aciona.dtmvtolt%TYPE, 
                                 pr_dhacionamento            IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP,
                                 pr_cdstatus_http            IN tbgen_webservice_aciona.cdstatus_http%TYPE, 
                                 pr_dsconteudo_requisicao    IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
                                 pr_dsresposta_requisicao    IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
                                 pr_dsprotocolo              IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL,
                                 pr_flgreenvia               IN tbgen_webservice_aciona.flgreenvia%TYPE DEFAULT 0,
                                 pr_nrreenvio                IN tbgen_webservice_aciona.nrreenvio%TYPE DEFAULT 0,
                                 pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT 1,
                                 pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT 0,
                                 pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
                                 pr_dscritic                OUT VARCHAR2);
                                                                 
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est (pr_cdcooper  IN crawepr.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                    ,pr_nrctremp  IN crawepr.nrctremp%TYPE
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                    ,pr_nmarquiv  IN VARCHAR2
                                     ---- OUT ----
                                    ,pr_dsmensag OUT VARCHAR2
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2);

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                    pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                    pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                    ---- OUT ----                           
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2);              --> Descricao da critica                                      
  
   --> Rotina responsavel por gerar a alteracao do numero da proposta para a esteira
  PROCEDURE pc_alter_numproposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
  --> Rotina para efetuar a derivação de uma proposta para a Esteira
  PROCEDURE pc_derivar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia           
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> codigo do operador
                                   ,pr_cdorigem  IN INTEGER                   --> Origem da operacao
                                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE     --> Numero da conta do cooperado
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero da proposta de emprestimo 
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE);   --> Data do movimento

 
  --> Rotina responsavel por gerar o cancelamento da proposta para a esteira
  PROCEDURE pc_cancelar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica 
                                      
  --> Rotina responsavel por gerar a interrupção da proposta para a esteira
  PROCEDURE pc_interrompe_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica 
                                      
  --> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica                                      
  
  --> Rotina responsavel por consultar informações da proposta na esteira
  PROCEDURE pc_consultar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                  --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo                          
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,    --> Data do movimento                                      
                                      ---- OUT ----                             
                                      pr_cdsitest OUT NUMBER,                   --> Retorna situacao da proposta
                                      pr_cdstatan OUT NUMBER,                   --> Retornoa status da proposta
                                      pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);                --> Descricao da critica.                                    
																			
  -- Rotina para retornar a obrigação de envio ou não da análise automática
  PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cód. cooperativa
		                                      ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo da Pessoa
                                          ,pr_cdfinemp IN crawepr.cdfinemp%TYPE --> Cód. finalidade do credito
                                          ,pr_cdlcremp IN crawepr.cdlcremp%TYPE --> Cód. linha de crédito
                                           ---- OUT ----
																					,pr_inobriga OUT VARCHAR2             --> Indicador de obrigação de análisa automática ('S' - Sim / 'N' - Não)
																					,pr_cdcritic OUT PLS_INTEGER          --> Cód. da crítica
																					,pr_dscritic OUT VARCHAR2);           --> Desc. da crítica
						
  -- Interface para acionamento web da pc_obrigacao_analise_automatic
  PROCEDURE pc_obrigacao_analise_autom_web(pr_cdfinemp IN crawepr.cdfinemp%TYPE  --> Finalidade de crédito
                                          ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo da Pessoa
                                          ,pr_cdlcremp IN crawepr.cdlcremp%TYPE  --> Cód. linha de crédito
                                           ---- OUT ----                                          
                                          ,pr_xmllog   IN  VARCHAR2                    -- XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                 -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                    -- Descrição da crítica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);  
                                          
  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                       ,pr_dsprotoc IN crawepr.dsprotoc%TYPE);
									
  PROCEDURE pc_notificacoes_prop(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Numero da conta
                                ,pr_nrctremp    IN crawepr.nrctremp%TYPE --> Numero do contrato
                                ,pr_cdcritic    OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2             --> Descricao da critica
                                 );
  
  FUNCTION fn_agenda_reenvio_analise(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Numero da conta
                                    ,pr_nrctremp    IN crawepr.nrctremp%TYPE --> Numero do contrato
                                    ,pr_cdagenci    IN crawepr.cdagenci%TYPE DEFAULT NULL --> PA que irá acionar o motor
                                    ,pr_cdoperad    IN crawepr.cdoperad%TYPE DEFAULT NULL --> Operador que irá acionar o motor
                                     ) RETURN BOOLEAN;
  
  PROCEDURE pc_job_reenvio_analise;
  
  PROCEDURE pc_email_reenvio_analise(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR);             --> Descricao da critica    

  PROCEDURE pc_set_job_reenvioanalise;  

  FUNCTION fn_get_job_reenvioanalise RETURN BOOLEAN;

END ESTE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0001 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0001
      Sistema  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Março/2016.                   Ultima atualizacao: 25/07/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes: 03/05/2017 - Alterações referentes ao Projeto 337. (Reinert)
                  01/03/2018 - Substituir utilização da tabela tbepr_acionamento pela tbgen_webservice_aciona
				  02/04/2018 - Incluir novo campo liquidOpCredAtraso no retorno do
                               motor de credito e enviar para esteira - Diego Simas (AMcom)
				  25/07/2018 - Correção para a contagem de dias em atraso
							   Fluxo Atraso (quantidadeDiasAtraso)
							   PJ 450 - Diego Simas (AMcom)		

          16/07/2019 - PRJ 438 - Add. pc_notificacoes_prop,fn_agenda_reenvio_analise,pc_job_reenvio_analise,pc_email_reenvio_analise
                     - Rafael R. Santos(AmCom)

  ---------------------------------------------------------------------------------------------------------------*/
  --/ variavel global para controle do JOB de reenvio para analise
  vg_job_reenvio_analise BOOLEAN := FALSE;
  --> Funcao para formatar o numero em decimal conforme padrao da IBRATAN
  FUNCTION fn_decimal_ibra (pr_numero IN number) RETURN NUMBER IS --RETURN VARCHAR2 is
  BEGIN
    RETURN  pr_numero; 
    -- Desabilitado mascara para incrementar no Json o campo no padrao numeroco sem aspas
    -- pois o json incrementa conforme a tipagem da variavel
    -- to_char(pr_numero,'99999990D00','NLS_NUMERIC_CHARACTERS=''.,''');  
  END fn_decimal_ibra;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
  END fn_DataTempo_ibra;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD');
  END fn_Data_ibra;
  
    --> Funcao que retorna o ultimo Protocolo de Análise Automática do Motor
    FUNCTION fn_protocolo_analise_auto (pr_cdcooper IN NUMBER
                                       ,pr_nrdconta IN NUMBER
                                       ,pr_nrctremp IN NUMBER) RETURN tbgen_webservice_aciona.dsprotocolo%TYPE IS
                                       
      CURSOR cr_tbgen_webservice_aciona IS
        SELECT aci.dsprotocolo dsprotocolo
          FROM tbgen_webservice_aciona aci
         WHERE aci.cdcooper = pr_cdcooper
           AND aci.nrdconta = pr_nrdconta
           AND aci.nrctrprp = pr_nrctremp
           AND aci.tpacionamento = 2 /* Retorno */
           AND aci.dsprotocolo IS NOT NULL
         ORDER BY aci.dhacionamento DESC;
       rw_tbgen_webservice_aciona cr_tbgen_webservice_aciona%ROWTYPE;
    BEGIN
      OPEN cr_tbgen_webservice_aciona;
      FETCH cr_tbgen_webservice_aciona INTO rw_tbgen_webservice_aciona;
      RETURN rw_tbgen_webservice_aciona.dsprotocolo;
    END fn_protocolo_analise_auto;
    
    --> Funcao que retorna o ultimo Protocolo de Análise Automática do Motor via Web
    PROCEDURE pr_protocolo_analise_auto_web (pr_nrdconta IN NUMBER
                                            ,pr_nrctremp IN NUMBER
                                            ,pr_xmllog   IN VARCHAR2 -- XML com informações de LOG
                                            ,pr_cdcritic OUT PLS_INTEGER -- Código da crítica
                                            ,pr_dscritic OUT VARCHAR2 -- Descrição da crítica
                                            ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                            ,pr_nmdcampo OUT VARCHAR2          -- Nome do campo com erro
                                            ,pr_des_erro OUT VARCHAR2) IS      -- Erros do processo
      /* ..........................................................................
            
        Programa : busca_protocolo_web        
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Lombardi
        Data     : Outubro/2016.                   Ultima atualizacao: 
            
        Dados referentes ao programa:
            
        Frequencia: Sempre que for chamado
        Objetivo  : Buscar o ultimo Protocolo de Análise Automática do Motor via Web
            
        Alteração : 
                
      ..........................................................................*/ 
           
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000) := NULL;
		
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_dsprotocolo tbgen_webservice_aciona.dsprotocolo%TYPE;
      
		BEGIN
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
      
      -- Buscar o ultimo Protocolo de Análise Automática do Motor
      vr_dsprotocolo := fn_protocolo_analise_auto(pr_cdcooper => vr_cdcooper
                                                 ,pr_nrdconta => pr_nrdconta
                                                 ,pr_nrctremp => pr_nrctremp);
      
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  RAISE vr_exc_erro;
		  END IF;
		  
      -- Retorna OK para cadastro efetuado com sucesso
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><protocolo>'|| vr_dsprotocolo || '</protocolo></Root>');
      
		EXCEPTION
      WHEN vr_exc_erro THEN
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina pr_protocolo_analise_auto_web: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END pr_protocolo_analise_auto_web;
    
  --> Procedimento para verificar se deve permitir o envio de email para o comite
  PROCEDURE pc_verifica_email_comite (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                      ---- OUT ----                                        
                                      pr_flgenvio OUT NUMBER,                 --> Retorno de deve permitir email de email (0-nao 1-sim)
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_verifica_email_comite        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 14/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar se deve permitir o envio de email para o comite
    
    Alteração : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------        
    vr_flgenvio     VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
  
    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_flgenvio := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                              pr_cdcooper => pr_cdcooper, 
                                              pr_cdacesso => 'ENVIA_EMAIL_COMITE');
    pr_flgenvio  := nvl(vr_flgenvio,0);     
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar parametro ENVIA_EMAIL_COMITE: '||SQLERRM;
  END pc_verifica_email_comite;
  
  --> Procedimento para verificar se deve permitir o envio de email para o comite versao web mensageria
  PROCEDURE pc_verifica_email_comite_web ( pr_nrdconta IN  VARCHAR2                    -- Numero da conta do cooperado
                                          ,pr_nrctremp IN  craphis.cdhistor%TYPE       -- Numero da proposta de emprestimo                                        
                                          ,pr_xmllog   IN  VARCHAR2                    -- XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                 -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                    -- Descrição da crítica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS                -- Erros do processo
  /* ..........................................................................
    
    Programa : pc_verifica_email_comite        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 14/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar se deve permitir o envio de email para o comite
                versao para ser utilizada no ayllos-web via mensageria
    
    Alteração : 
        
  ..........................................................................*/
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000)       := NULL;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_flgenvio NUMBER;
    
  BEGIN
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
    
    pc_verifica_email_comite (pr_cdcooper  => vr_cdcooper,  --> Codigo da cooperativa                                        
                              pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                              pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo                                        
                              ---- OUT ----                                        
                              pr_flgenvio  => vr_flgenvio,  --> Retorno de deve permitir email de email (0-nao 1-sim)
                              pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                              pr_dscritic  => vr_dscritic); --> Descricao da critica
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;   
    
    -- Retorna OK para cadastro efetuado com sucesso
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><flmail_comite>'|| vr_flgenvio || '</flmail_comite></Root>');   

    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar parametro ENVIA_EMAIL_COMITE: '||SQLERRM;
  END pc_verifica_email_comite_web;
  
  
  
  PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                        pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                        pr_tpenvest  IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                        ---- OUT ----                                        
                                        pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                        pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_verifica_regras_esteira        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 09/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira 
    
    Alteração : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.insitest
			      ,epr.cdopeapr
						,epr.insitapr
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    vr_contige_este VARCHAR2(500);
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
  
    --> Verificar se a Esteira esta em contigencia para a cooperativa
    vr_contige_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                  pr_cdcooper => pr_cdcooper, 
                                                  pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA');
    IF vr_contige_este IS NULL THEN
      vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_IBRA não encontrado.';
      RAISE vr_exc_erro;      
    END IF;
    
    IF vr_contige_este = '1' THEN
      vr_dscritic := 'Atenção! A aprovação da proposta deve ser feita pela tela CMAPRV.';
      RAISE vr_exc_erro;      
    END IF; 
    
    -- Para inclusão, alteração ou derivação
    IF nvl(pr_tpenvest,' ') IN ('I','A','D') THEN    
      
      --> Buscar dados da proposta
      OPEN cr_crawepr (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
        RAISE vr_exc_erro;
      END IF;
      
      -- Somente permitirá se ainda não enviada 
      -- OU se foi Reprovada pelo Motor
      -- ou se houve Erro Conexão
      -- OU se foi enviada e recebemos a Derivação 
      IF rw_crawepr.insitest = 0 
      OR (rw_crawepr.insitest = 3 AND rw_crawepr.insitapr = 2 AND rw_crawepr.cdopeapr = 'MOTOR') 
      OR (rw_crawepr.insitest = 3 AND rw_crawepr.insitapr = 6 AND pr_tpenvest = 'I')       
      OR (rw_crawepr.insitest = 3 AND rw_crawepr.insitapr = 5) THEN
        -- Sair pois pode ser enviada
        RETURN;
      END IF;
      -- Não será possível enviar/reenviar para a Esteira
      vr_dscritic := 'A proposta não pode ser enviada para Análise de crédito, verifique a situação da proposta!';
      RAISE vr_exc_erro;      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar regras da Análise de Crédito: '||SQLERRM;
  END pc_verifica_regras_esteira;
  
  PROCEDURE pc_busca_param_ibra(pr_cdcooper       in crapcop.cdcooper%type  -- Codigo da cooperativa
                               ,pr_tpenvest       in varchar2 default null  --> Tipo de envio C - Consultar(Get)
                               ,pr_host_esteira  out varchar2               -- Host da esteira
                               ,pr_recurso_este  out varchar2               -- URI da esteira
                               ,pr_dsdirlog      out varchar2               -- Diretorio de log dos arquivos
                               ,pr_autori_este   out varchar2               -- Chave de acesso
                               ,pr_chave_aplica  out varchar2               -- App Key
                               ,pr_dscritic      out varchar2 ) is
  /* ..........................................................................
  

    Programa : pc_busca_param_ibra
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Abril/2018.

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Buscar parametros para uso na comunicacao com a esteira, removido
                da procedure pc_carrega_param_ibrapara pode utilizar sem a validação
                da pc_verifica_regras_esteira

    Alteração : 12/04/2018 Criação

  ..........................................................................*/
    vr_exc_erro exception;
    vr_dscritic varchar2(4000);
    vr_cdcritic number;

  BEGIN

     if  pr_tpenvest = 'M' then
         --> Buscar hots so webservice do motor
         pr_host_esteira := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA');
         if  pr_host_esteira is null then
             vr_dscritic := 'Parametro HOST_WEBSRV_MOTOR_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;

         --> Buscar recurso uri do motor
         pr_recurso_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA');

         if  pr_recurso_este is null then
             vr_dscritic := 'Parametro URI_WEBSRV_MOTOR_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;

         --> Buscar chave de acesso do motor (Autorization é igual ao Consultas Automatizadas)
         pr_autori_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdcooper =>  pr_cdcooper
                                                    ,pr_cdacesso => 'AUTORIZACAO_IBRATAN');
         if  pr_autori_este is null then
             vr_dscritic := 'Parametro AUTORIZACAO_IBRATAN não encontrado.';
             raise vr_exc_erro;
         end if;

         -- Concatenar o Prefixo
         pr_autori_este := 'CECRED'||lpad(pr_cdcooper,2,'0')||':'||pr_autori_este;

         -- Gerar Base 64
         pr_autori_este := 'Ibratan '||sspc0001.pc_encode_base64(pr_autori_este);

         --> Buscar chave de aplicação do motor
         pr_chave_aplica := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'KEY_WEBSRV_MOTOR_IBRA');

         if  pr_chave_aplica is null then
             vr_dscritic := 'Parametro KEY_WEBSRV_MOTOR_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;

     else
         --> Buscar hots so webservice da esteira
         pr_host_esteira := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'HOSWEBSRVCE_ESTEIRA_IBRA');
         if  pr_host_esteira is null then
             vr_dscritic := 'Parametro HOSWEBSRVCE_ESTEIRA_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;

         --> Buscar recurso uri da esteira
         pr_recurso_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                     ,pr_cdcooper => pr_cdcooper
                                                     ,pr_cdacesso => 'URIWEBSRVCE_RECURSO_IBRA');

         if  pr_recurso_este is null then
             vr_dscritic := 'Parametro URIWEBSRVCE_RECURSO_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;

         --> Buscar chave de acesso da esteira
         pr_autori_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_cdacesso => 'KEYWEBSRVCE_ESTEIRA_IBRA');

         if  pr_autori_este is null then
             vr_dscritic := 'Parametro KEYWEBSRVCE_ESTEIRA_IBRA não encontrado.';
             raise vr_exc_erro;
         end if;
     end if;

     --> Buscar diretorio do log
     pr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => 3
                                         ,pr_nmsubdir => '/log/webservices' );

  EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          end if;

          pr_dscritic := vr_dscritic;

    when others then
         pr_dscritic := 'Não foi possivel buscar parametros da estira: '||sqlerrm;
  END;


  PROCEDURE pc_carrega_param_ibra(pr_cdcooper       IN crapcop.cdcooper%TYPE,  -- Codigo da cooperativa
                                  pr_nrdconta       IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp       IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo                                        
                                  pr_tpenvest       IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio C - Consultar(Get)
                                  pr_host_esteira  OUT VARCHAR2,               -- Host da esteira
                                  pr_recurso_este  OUT VARCHAR2,               -- URI da esteira
                                  pr_dsdirlog      OUT VARCHAR2,               -- Diretorio de log dos arquivos 
                                  pr_autori_este   OUT VARCHAR2,               -- Chave de acesso
                                  pr_chave_aplica  OUT VARCHAR2,               -- App Key
                                  pr_dscritic      OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_carrega_param_ibra        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 08/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com a esteira
    
    Alteração : 12/04/2018 Adicionado a procdure pc_busca_param_ibra (Paulo Penteado GFT)
        
  ..........................................................................*/  
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
  BEGIN  
    
    pc_verifica_regras_esteira (pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa                                        
                                pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                                pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo                                        
                                pr_tpenvest  => pr_tpenvest,  --> Tipo de envio C - Consultar(Get)
                                ---- OUT ----                                        
                                pr_cdcritic => vr_cdcritic,                 --> Codigo da critica
                                pr_dscritic => vr_dscritic);            --> Descricao da critica
  
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF; 
  
    pc_busca_param_ibra(pr_cdcooper      => pr_cdcooper
                       ,pr_tpenvest      => pr_tpenvest
                       ,pr_host_esteira  => pr_host_esteira
                       ,pr_recurso_este  => pr_recurso_este
                       ,pr_dsdirlog      => pr_dsdirlog
                       ,pr_autori_este   => pr_autori_este
                       ,pr_chave_aplica  => pr_chave_aplica
                       ,pr_dscritic      => pr_dscritic );

    IF vr_dscritic  IS NOT NULL THEN
				RAISE vr_exc_erro;      
			END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel buscar parametros da estira: '||SQLERRM;
  END; 
  
  --> Extrair a descricao de critica do json de retorno
  FUNCTION fn_retorna_critica (pr_jsonreto IN VARCHAR2) RETURN VARCHAR2 IS
  /* ..........................................................................
    
    Programa : fn_retorna_critica        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Maio/2016.                   Ultima atualizacao: 22/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Extrair a descricao de critica do json de retorno
    
    Alteração : 
        
  ..........................................................................*/ 
  
    vr_obj_retorno   json := json();
    vr_obj_content   json := json();
    vr_dsretorn      VARCHAR2(32000);
    vr_auxctrl       BOOLEAN := FALSE;
    vr_exc_erro      EXCEPTION;
    vr_json          BOOLEAN;
    vr_xml           xmltype;
  BEGIN
    
    vr_dsretorn := pr_jsonreto;
    
    --> Transformar texto em objeto json
    LOOP
      BEGIN
        vr_obj_retorno := json(vr_dsretorn);
        vr_json := TRUE; --> Marcar como um json valido
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN   
          --> Tentar ajustar json para tentar criar o objeto novamente
          IF vr_auxctrl = FALSE THEN  
            vr_auxctrl := TRUE;   
            vr_dsretorn := REPLACE(vr_dsretorn,'"StatusMessage"',',"StatusMessage"') ;
            vr_dsretorn := REPLACE(vr_dsretorn,'Bad Request','"Bad Request"') ;            
            vr_dsretorn := '{'||vr_dsretorn||'}';
          ELSE
            vr_json := FALSE;
            EXIT;
          END IF;
      END;
    END LOOP;  
    
    IF vr_json THEN
      --> buscar content
      IF vr_obj_retorno.exist('Content') THEN
        -- converter content em objeto
        vr_obj_content := json(vr_obj_retorno.get('Content').to_char());
        --> Extrair a critica encontrada
        RETURN replace(vr_obj_content.get('descricao').to_char(),'"');
      END IF;
    ELSE
      -- Verificar se é um xml(retorno da analise)
      BEGIN
        vr_xml := XMLType.createxml(pr_jsonreto);
        RETURN TRIM(vr_xml.extract('/Dados/inf/msg_detalhe/text()').getstringval());
      EXCEPTION
        WHEN OTHERS THEN 
          RAISE vr_exc_erro;    
      END;  
    END IF;
    
    -- Senao conseguir extrair critica retorna null
    RETURN NULL;
  
  EXCEPTION
    -- Senao conseguir extrair critica retorna null
    WHEN vr_exc_erro THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;  
  END;
  
  --> Rotina responsavel por gravar registro de log de acionamento
PROCEDURE pc_grava_acionamento(pr_cdcooper                 IN tbgen_webservice_aciona.cdcooper%TYPE, 
                               pr_cdagenci                 IN tbgen_webservice_aciona.cdagenci_acionamento%TYPE,
                               pr_cdoperad                 IN tbgen_webservice_aciona.cdoperad%TYPE, 
                               pr_cdorigem                 IN tbgen_webservice_aciona.cdorigem%TYPE, 
                               pr_nrctrprp                 IN tbgen_webservice_aciona.nrctrprp%TYPE, 
                               pr_nrdconta                 IN tbgen_webservice_aciona.nrdconta%TYPE, 
                               pr_cdcliente                IN tbgen_webservice_aciona.cdcliente%TYPE DEFAULT 1, 
                               pr_tpacionamento            IN tbgen_webservice_aciona.tpacionamento%TYPE, 
                               pr_dsoperacao               IN tbgen_webservice_aciona.dsoperacao%TYPE, 
                               pr_dsuriservico             IN tbgen_webservice_aciona.dsuriservico%TYPE, 
                               pr_dsmetodo                 IN tbgen_webservice_aciona.dsmetodo%TYPE DEFAULT 'POST',
                               pr_dtmvtolt                 IN tbgen_webservice_aciona.dtmvtolt%TYPE, 
                               pr_dhacionamento            IN tbgen_webservice_aciona.dhacionamento%TYPE DEFAULT SYSTIMESTAMP,
                               pr_cdstatus_http            IN tbgen_webservice_aciona.cdstatus_http%TYPE, 
                               pr_dsconteudo_requisicao    IN tbgen_webservice_aciona.dsconteudo_requisicao%TYPE,
                               pr_dsresposta_requisicao    IN tbgen_webservice_aciona.dsresposta_requisicao%TYPE,
                               pr_dsprotocolo              IN tbgen_webservice_aciona.dsprotocolo%TYPE DEFAULT NULL,
                               pr_flgreenvia               IN tbgen_webservice_aciona.flgreenvia%TYPE DEFAULT 0,
                               pr_nrreenvio                IN tbgen_webservice_aciona.nrreenvio%TYPE DEFAULT 0,
                               pr_tpconteudo               IN tbgen_webservice_aciona.tpconteudo%TYPE DEFAULT 1,
                               pr_tpproduto                IN tbgen_webservice_aciona.tpproduto%TYPE DEFAULT 0,
                               pr_idacionamento           OUT tbgen_webservice_aciona.idacionamento%TYPE,
                                 pr_dscritic                OUT VARCHAR2) IS
                                 
  /* ..........................................................................
    
    Programa : pc_grava_acionamento        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Março/2016.                   Ultima atualizacao: 08/03/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Grava registro de log de acionamento
    
    Alteração : 11/11/2018 - Alterações referentes ao Projeto 402. (Rafael Faria)
        
  ..........................................................................*/
  BEGIN
     -- Criada rotina generica para manter os acionamentos webservice
     WEBS0003.pc_grava_acionamento(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci    => pr_cdagenci
                                  ,pr_cdoperad    => pr_cdoperad
                                  ,pr_cdorigem    => pr_cdorigem
                                  ,pr_nrctrprp    => pr_nrctrprp
                                  ,pr_nrdconta    => pr_nrdconta
                                  ,pr_cdcliente   => pr_cdcliente
                                  ,pr_tpacionamento => pr_tpacionamento
                                  ,pr_dhacionamento => pr_dhacionamento
                                  ,pr_dsoperacao    => pr_dsoperacao
                                  ,pr_dsuriservico  => pr_dsuriservico
                                  ,pr_dsmetodo      => pr_dsmetodo
                                  ,pr_dtmvtolt      => pr_dtmvtolt
                                  ,pr_cdstatus_http => pr_cdstatus_http
                                  ,pr_dsconteudo_requisicao  => pr_dsconteudo_requisicao
                                  ,pr_dsresposta_requisicao  => pr_dsresposta_requisicao
                                  ,pr_flgreenvia    => pr_flgreenvia
                                  ,pr_nrreenvio     => pr_nrreenvio
                                  ,pr_tpconteudo    => pr_tpconteudo
                                  ,pr_tpproduto     => pr_tpproduto
                                  ,pr_dsprotocolo   => pr_dsprotocolo
                                  ,pr_idacionamento => pr_idacionamento
                                  ,pr_dscritic      => pr_dscritic);
   
  EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao inserir tbgen_webservice_aciona: '||SQLERRM;
      ROLLBACK;
  END pc_grava_acionamento;
  
  --> Rotina para alterar o numero da proposta no acionamento
  PROCEDURE pc_alter_nrctrprp_aciona( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alter_nrctrprp_aciona        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Abril/2016.                   Ultima atualizacao: 14/04/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para alterar o numero da proposta no acionamento
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
  BEGIN
  
    UPDATE tbgen_webservice_aciona aci
       SET aci.nrctrprp = pr_nrctremp_novo
     WHERE aci.cdcooper = pr_cdcooper
       AND aci.nrdconta = pr_nrdconta
       AND aci.nrctrprp = pr_nrctremp;        
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar acionamento: '||SQLERRM;  
  END;  
  
  
  --> Rotina para converter arquivo(pdf) para CLOB em base64 para ser enviado
   -- via JSON  
  PROCEDURE pc_arq_para_clob_base64(pr_nmarquiv     IN VARCHAR2,
                                    pr_json_value_arq OUT json_value, 
                                    pr_dscritic    OUT VARCHAR2  )IS
  
    vr_arquivo        BLOB;
    vr_json_valor     json_value;
    vr_nmdireto       VARCHAR2(4000);
    vr_nmarquiv       VARCHAR2(4000);
    vr_nomarqui       VARCHAR2(4000);
    vr_dsdircop       VARCHAR2(4000);
    
    vr_exec_erro EXCEPTION;
    vr_dscritic  VARCHAR2(4000);
    
  BEGIN
  
    -- Chamar rotina de separação do caminho do nome
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv
                                   ,pr_direto  => vr_nmdireto
                                   ,pr_arquivo => vr_nomarqui);  
  
    -- Verificar qual a base de execução
    IF gene0001.fn_database_name =
       gene0001.fn_param_sistema('CRED', 0, 'DB_NAME_PRODUC') THEN
      --> Produção
      vr_nmarquiv := pr_nmarquiv;
    ELSE
      --> Caso nao for produção, é necessario corrigir endereço do arquivo,
      --> devido a diferença entre endereco progress e oracle
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => 0);
      IF vr_nmdireto NOT LIKE '%' || vr_dsdircop || '%' THEN
      
        vr_nmdireto := replace(vr_nmdireto, '/usr/coop/', vr_dsdircop);
        vr_nmarquiv := vr_nmdireto || '/' || vr_nomarqui;
      ELSE
        vr_nmarquiv := pr_nmarquiv;
      END IF;
    END IF;
  
    --> Verificar se existe arquivo
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto || '/' ||
                                              vr_nomarqui /*vr_nmarquiv*/) =
       FALSE THEN
      vr_dscritic := 'Arquivo ' || vr_nmdireto || '/' || vr_nomarqui /*vr_nmarquiv*/
                     || ' não encontrado.';
      RAISE vr_exec_erro;
    END IF;
    
    /* Carrega o arquivo binário a para memória em uma variavel BLOB */
    vr_arquivo := gene0002.fn_arq_para_blob(vr_nmdireto, vr_nomarqui);
    /* Codifica o arquivo binário da memória em Base64 */
    vr_json_valor := json_ext.encode(vr_arquivo);
    pr_json_value_arq := vr_json_valor;
    
  EXCEPTION
    WHEN vr_exec_erro THEN
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi posssivel converter arquivo para CLOB: '|| SQLERRM;
  END pc_arq_para_clob_base64;
  
  -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira ( pr_cdcooper    IN crapcop.cdcooper%TYPE,  --> Codigo da cooperativa
                                pr_cdagenci    IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                pr_cdoperad    IN crapope.cdoperad%TYPE,  --> codigo do operador
                                pr_cdorigem    IN INTEGER,                --> Origem da operacao
                                pr_nrdconta    IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                pr_nrctremp    IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                pr_comprecu    IN VARCHAR2,               --> Complemento do recuros da URI
                                pr_dsmetodo    IN VARCHAR2,               --> Descricao do metodo
                                pr_conteudo    IN CLOB,                   --> Conteudo no Json para comunicacao
                                pr_dsoperacao  IN VARCHAR2,               --> Operacao realizada
                                pr_tpenvest    IN VARCHAR2 DEFAULT NULL,  --> Tipo de envio, I-Inclusao C - Consultar(Get)
																pr_dsprotocolo OUT VARCHAR2,              --> Protocolo retornado na requisição
                                pr_dscritic    OUT VARCHAR2 ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    
    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;
		
    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);
    
  BEGIN
    
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_nrdconta      => pr_nrdconta,                   -- Numero da conta do cooperado
                          pr_nrctremp      => pr_nrctremp,                   -- Numero da proposta de emprestimo
                          pr_tpenvest      => pr_tpenvest,                   -- Tipo do Envio 
                          pr_host_esteira  => vr_host_esteira,               -- Host da esteira
                          pr_recurso_este  => vr_recurso_este,               -- URI da esteira
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos 
                          pr_autori_este   => vr_autori_este  ,              -- Authorization 
                          pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    -- Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      -- Incluiremos o Reply-To para devolução da Análise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
    END IF;
    
        
    vr_request.content := pr_conteudo;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato é o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
		
    --> Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctremp,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_cdcliente             => 1,          
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */      
                         pr_dsoperacao            => pr_dsoperacao,       
                         pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,       
                         pr_dsmetodo              => pr_dsmetodo,
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => vr_response.status_code,
                         pr_dsconteudo_requisicao => pr_conteudo,
                         pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                     ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                     ',"Content":'||vr_response.content||'}',
                         pr_flgreenvia            => 0,
                         pr_nrreenvio             => 0,
                         pr_tpconteudo            => 1,
                         pr_tpproduto             => 0,
                         pr_idacionamento         => vr_idacionamento,
                         pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Análise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da Análise de Crédito.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'GET' THEN   
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da Análise Automática de Crédito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para Análise de Crédito.';  
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          -- Tratar mensagem específica de Fluxo Atacado:
          -- "Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN 
            -- Mensagens diferentes dela terão o prefixo, somente ela não terá
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;            
          END IF;  
        ELSE
          pr_dscritic := vr_dscritic_aux;            
        END IF;
        
      ELSE  
        pr_dscritic := vr_dscritic_aux;    
      END IF;                         
      
    END IF;
		
    -- Pj 438 - Marcelo Telles Coelho - Mouts - 07/04/2019
    -- Startar job de atualização das informações da Tela Única
    IF pr_dscritic IS NULL AND pr_tpenvest <> 'M' -- Não foi chamada para Motor
    OR 
       (pr_dscritic IS NULL AND pr_tpenvest IS NULL AND pr_dsoperacao = 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO')
    THEN
      tela_analise_credito.pc_job_dados_analise_credito(pr_cdcooper  => pr_cdcooper
                                                       ,pr_nrdconta  => pr_nrdconta
                                                       ,pr_tpproduto => 2 -- Empréstimos/Financiamentos
                                                       ,pr_nrctremp  => pr_nrctremp
                                                       ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Fim Pj 438

		IF pr_tpenvest = 'M' AND pr_dsmetodo = 'POST' THEN
	    --> Transformar texto em objeto json
			BEGIN
        
        -- Transformar os Headers em uma lista (\n é o separador)
        vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
        vr_idx_split  := vr_tab_split.FIRST;
        -- Iterar sobre todos os headers até encontrar o protocolo
        WHILE vr_idx_split IS NOT NULL AND pr_dsprotocolo IS NULL LOOP
          -- Testar se é o Location
          IF lower(vr_tab_split(vr_idx_split)) LIKE 'location%' THEN
            -- Extrair o final do atributo, ou seja, o conteúdo após a ultima barra
            pr_dsprotocolo := SUBSTR(vr_tab_split(vr_idx_split),INSTR(vr_tab_split(vr_idx_split),'/',-1)+1);
          END IF;        
          -- Buscar proximo header        
          vr_idx_split := vr_tab_split.NEXT(vr_idx_split);    
        END LOOP;
        
        -- Se conseguiu encontrar Protocolo
        IF pr_dsprotocolo IS NOT NULL THEN 
  				-- Atualizar acionamento																										 
          UPDATE tbgen_webservice_aciona
		  			 SET dsprotocolo = pr_dsprotocolo
			  	 WHERE idacionamento = vr_idacionamento;
        ELSE    
				  -- Gerar erro 
          vr_dscritic := 'Nao foi possivel retornar Protocolo da Análise Automática de Crédito!';
					RAISE vr_exc_erro;																						 
				END IF;
			EXCEPTION
				WHEN OTHERS THEN   
					vr_dscritic := 'Nao foi possivel retornar Protocolo de Análise Automática de Crédito!';
					RAISE vr_exc_erro;
			END;  
		END IF;
		
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar proposta para Análise de Crédito: '||SQLERRM;  
  END pc_enviar_esteira;
  
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                  pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                            
                                  pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operado
                                  pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                  pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                  pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                  pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                  ---- OUT ----
                                  pr_proposta OUT json,                   --> Retorno do clob em modelo json da proposta de emprestimo
                                  pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                  pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
      Programa : pc_gera_json_proposta        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 10/07/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por realizar as leituras no sistema cecred a fim
                  de montar o objeto json contendo a proposta de emprestimo
    
      Alteração : 08/08/2016 Enviar sempre o PA de envio nas propostas de inclusão/alteração. (Oscar)
                  19/08/2016 Enviar 0 no parecer quando não existir parecer. (Oscar)

                  12/09/2016 Enviar o saldo do pre-aprovado se estiver liberado na conta
                  para ter pre-aprovado. (Oscar)
                  
                  30/01/2017 - Exibir o tipo de emprestimo Pos-Fixado. (Jaison/James - PRJ298)

                  27/02/2017 SD610862 - Enviar novas informações para a esteira:
                               - cooperadoColaborador: Flag se eh proposta de colaborador
                               - codigoCargo: Codigo do Cargo do Colaborador
                               - classificacaoRisco: Nivel de risco no momento da criacao
                               - renegociacao: Flag de renogociação ou não 
                               - faturamentoAnual: Faturamento dos ultimos 12 meses
                               
                  20/07/2017 - P337 - Customizacoes Motor de Credit0 (Marcos-Supero)                               
        
                  02/04/2018 - Incluir novo campo liquidOpCredAtraso na esteira
                               Diego Simas (AMcom)

				  25/07/2018 - Correção para a contagem de dias em atraso
							   Fluxo Atraso (quantidadeDiasAtraso)
							   PJ 450 - Diego Simas (AMcom)

                  26/07/2018 - Correção para quando a quantidade de meses do histórico de empréstimo for nula receber zero 
							   PJ 450 - Diego Simas (AMcom) (Fluxo Atraso)							   

                  12/02/2019 - P442 - Nova estrutura do PreAprovado (Marcos-Envolti)
                 10/07/2019 - P438 - Inclusão dos atributos canalCodigo e canalDescricao no Json para identificar 
                                a origem da operação de crédito na Esteira. (Douglas Pagel / AMcom).
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci,
             epr.dtmvtolt,
             epr.vlemprst,
             epr.qtpreemp,
             epr.dtvencto,
             epr.vlpreemp,
             epr.inliquid_operac_atraso,
             epr.hrinclus,
             epr.cdlcremp,
             lcr.dslcremp,
             epr.cdfinemp,
             fin.dsfinemp,
             lcr.tpctrato,
             epr.cdoperad,
             ope.nmoperad,
             pac.instatus,
             epr.dsnivris,
             epr.insitapr,
             UPPER(epr.cdopeapr) cdopeapr,
             TO_CHAR(NRCTRLIQ##1) || ',' || TO_CHAR(NRCTRLIQ##2) || ',' ||
             TO_CHAR(NRCTRLIQ##3) || ',' || TO_CHAR(NRCTRLIQ##4) || ',' ||
             TO_CHAR(NRCTRLIQ##5) || ',' || TO_CHAR(NRCTRLIQ##6) || ',' ||
             TO_CHAR(NRCTRLIQ##7) || ',' || TO_CHAR(NRCTRLIQ##8) || ',' ||
             TO_CHAR(NRCTRLIQ##9) || ',' || TO_CHAR(NRCTRLIQ##10) dsliquid,
             CASE epr.tpemprst
               WHEN 0 THEN 'TR'
               WHEN 1 THEN 'PP'
               WHEN 2 THEN 'POS'
             END tpproduto,
             -- Indica que am linha de credito eh CDC ou C DC
             DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper
                                               ,pr_cdfinemp => epr.cdfinemp),3,1,0) AS inlcrcdc,
             epr.idfluata,	 
             epr.cdorigem
        FROM crawepr epr,
             craplcr lcr,
             crapfin fin,
             crapope ope,
             crappac pac
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = fin.cdcooper
         AND epr.cdfinemp = fin.cdfinemp
         AND epr.cdcooper = ope.cdcooper
         AND upper(epr.cdoperad) = upper(ope.cdoperad)
         AND epr.nrseqpac = pac.nrseqpac(+)
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    --> Selecionar os associados da cooperativa por CPF/CGC
    CURSOR cr_crapass_cpfcgc(pr_cdcooper crapass.cdcooper%TYPE,
                             pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT cdcooper,
             nrdconta,
             flgcrdpa               
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
         AND dtelimin IS NULL;
    
    --> Buscar valor de propostas pendentes
    CURSOR cr_crawepr_pend (pr_cdcooper crawepr.cdcooper%TYPE,
                            pr_nrdconta crawepr.nrdconta%TYPE,
                            pr_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT nvl(SUM(w.vlemprst),0) vlemprst
        FROM crawepr w
        JOIN craplcr l
          ON l.cdlcremp = w.cdlcremp
         AND l.cdcooper = w.cdcooper               
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.insitapr IN(1,3)        -- já estao aprovadas
         AND w.insitest NOT IN(4,5,6)  -- 4 - Expiradas - 5 - Expirada por decurso de prazo -- PJ 438 - Márcio (Mouts) - 6 - Anulação -- PJ438 - Paulo Martins - Mouts
         AND w.nrctremp <> pr_nrctremp -- desconsiderar a proposta que esta sendo enviada no momento
         AND NOT EXISTS ( SELECT 1
                            FROM crapepr p
                           WHERE w.cdcooper = p.cdcooper
                             AND w.nrdconta = p.nrdconta
                             AND w.nrctremp = p.nrctremp);
    
    rw_crawepr_pend cr_crawepr_pend%ROWTYPE;

    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.cdoperad  
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    --> Buscar se a conta é de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS 
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';                                          
    vr_flgcolab BOOLEAN;
    vr_cddcargo tbcadast_colaborador.cdcooper%TYPE;
    
    --> Calculo do faturamento PJ
    CURSOR cr_crapjfn(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
            +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
       FROM crapjfn
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
    
    -- Buscar quantos dias de atraso houve no contrato
    CURSOR cr_crapris(pr_nrctremp IN crapepr.nrctremp%TYPE
                     ,pr_dtultdma IN crapdat.dtultdma%TYPE) IS
      SELECT MAX(ris.qtdiaatr) qtdiaatr
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = NVL(pr_nrctremp,ris.nrctremp)
         AND ris.dtrefere >= pr_dtultdma
         AND ris.cdmodali in(299,499)
         AND ris.inddocto = 1;
    vr_qtddiatr NUMBER;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Objeto json da proposta
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();
    vr_obj_imagem   json := json();
    vr_lst_doctos   json_list := json_list();
    vr_json_valor   json_value;
    
    -- Variaveis auxiliares
    vr_data_aux     DATE := NULL;
    vr_dstpgara     craptab.dstextab%TYPE;
    vr_dstextab     craptab.dstextab%TYPE;
    vr_nrctremp     crawepr.nrctremp%TYPE;
    vr_inusatab     BOOLEAN;
    vr_vlutiliz     NUMBER;
    vr_vlprapne     NUMBER;
    vr_vllimdis     NUMBER;
    vr_vlparcel     NUMBER;
    vr_vldispon     NUMBER;
    vr_nmarquiv     varchar2(1000);
    vr_dsiduser     varchar2(100);
        vr_dsprotoc  tbgen_webservice_aciona.dsprotocolo%TYPE;
        vr_dsdirarq  VARCHAR2(1000);
        vr_dscomando VARCHAR2(1000);
    vr_ind_opeatr   BOOLEAN;
    vr_qthisemp     crapprm.dsvlrprm%TYPE;
      
    --- variavel cartoes
    vr_vltotccr NUMBER;

  BEGIN
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;
    
    --> Criar objeto json para agencia da proposta
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', pr_cdagenci);    
    vr_obj_proposta.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_proposta.put('cooperadoContaPA' ,vr_obj_agencia);
    
    -- Nr. conta sem o digito
    vr_obj_proposta.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_proposta.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));
    
    -- apenas se nao for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      vr_obj_proposta.put('cooperadoNome'    , rw_crapass.nmprimtl);
    END IF;
    
    vr_obj_proposta.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    vr_obj_proposta.put('numero'             , rw_crawepr.nrctremp);
    vr_obj_proposta.put('valor'              , fn_decimal_ibra(rw_crawepr.vlemprst));
    vr_obj_proposta.put('parcelaQuantidade'  , rw_crawepr.qtpreemp);
    vr_obj_proposta.put('parcelaPrimeiroVencimento', fn_Data_ibra(rw_crawepr.dtvencto));
    vr_obj_proposta.put('parcelaValor'       , fn_decimal_ibra(rw_crawepr.vlpreemp));
    
    --> Data e hora da inclusao da proposta
    vr_data_aux := to_date(to_char(rw_crawepr.dtmvtolt,'DD/MM/RRRR') ||' '||
                           to_char(to_date(rw_crawepr.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');    
    vr_obj_proposta.put('dataHora'           , fn_DataTempo_ibra(vr_data_aux));    
    
    
    /* 0 – CDC Diversos
       1 – CDC Veículos 
       2 – Empréstimos /Financiamentos 
       3 – Desconto Cheques 
       4 – Desconto Títulos 
       5 – Cartão de Crédito 
       6 – Limite de Crédito) */
       
    -- Se for CDC e diversos
    IF rw_crawepr.cdfinemp = 58 AND rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_proposta.put('produtoCreditoSegmentoCodigo'    ,0); -- CDC Diversos
      vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'CDC Diversos');
    -- Se for CDC e veiculos
    ELSIF rw_crawepr.cdfinemp = 59 AND rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_proposta.put('produtoCreditoSegmentoCodigo'    ,1); -- CDC Veiculos
      vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'CDC Veiculos');
    ELSE
      vr_obj_proposta.put('produtoCreditoSegmentoCodigo' ,2); -- Emprestimos/Financiamento
      vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'Emprestimos/Financiamento');      
    END IF;
    
      vr_obj_proposta.put('linhaCreditoCodigo'    ,rw_crawepr.cdlcremp);
      vr_obj_proposta.put('linhaCreditoDescricao' ,rw_crawepr.dslcremp);
      vr_obj_proposta.put('finalidadeCodigo'      ,rw_crawepr.cdfinemp);       
      vr_obj_proposta.put('finalidadeDescricao'   ,rw_crawepr.dsfinemp);      
    
    vr_obj_proposta.put('tipoProduto'           ,rw_crawepr.tpproduto);
    vr_obj_proposta.put('tipoGarantiaCodigo'    ,rw_crawepr.tpctrato );
    
    --> Buscar descição do tipo de garantia
    vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED', 
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawepr.tpctrato);    
    vr_obj_proposta.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );
    
    vr_obj_proposta.put('segueFluxoAtacado'    ,(CASE WHEN rw_crawepr.idfluata=1 THEN TRUE ELSE FALSE END)); 

    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;  
    
    vr_obj_proposta.put('loginOperador'         ,lower(rw_crapope.cdoperad));
    vr_obj_proposta.put('nomeOperador'          ,rw_crapope.nmoperad );
    
    -- Vazio se for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      /* Se estiver zerado é pq não houve Parecer de Credito - ou seja - oriundo do Motor de Crédito */  
      IF NVL(rw_crawepr.instatus, 0) = 0 THEN
        /* Se reprovado no Motor */
        IF rw_crawepr.cdopeapr = 'MOTOR' AND rw_crawepr.insitapr = 2 THEN 
          /*Fixo 3-Nao Conceder*/
          rw_crawepr.instatus := 3;
        ELSE
          /*Fixo 2-Analise Manual*/
          rw_crawepr.instatus := 2;
        END IF;
      END IF;
      /*1-pre-aprovado, 2-analise manual, 3-nao conceder */
      vr_obj_proposta.put('parecerPreAnalise', rw_crawepr.instatus);
    ELSE
      /* Zerado para CDC */
      vr_obj_proposta.put('parecerPreAnalise', 0);
    END IF; 
    
    
    IF rw_crawepr.inlcrcdc = 0 THEN
      
      -- retorna o limite dos cartoes do cooperado para todas as contas (usando a cada0004.lista_cartoes)
      ccrd0001.pc_retorna_limite_cooperado(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_vllimtot => vr_vltotccr);

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';
      
      -- Busca endividamento do cooperado
      RATI0001.pc_calcula_endividamento( pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                        ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                                        ,pr_nrdcaixa   => 0               --> Número do caixa
                                        ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                                        ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                        ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                        ,pr_dsliquid   => rw_crawepr.dsliquid --> Lista de contratos a liquidar
                                        ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                        ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                        ,pr_inusatab   => vr_inusatab     --> Indicador de utilização da tabela de juros
                                        ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                        ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                                        ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                        ,pr_dscritic   => vr_dscritic);   --> Saída de erro
      -- Se houve erro
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      
      vr_vllimdis := 0.0;
      vr_vlprapne := 0.0;
      FOR rw_crapass_cpfcgc IN cr_crapass_cpfcgc(pr_cdcooper => pr_cdcooper,
                                                 pr_nrcpfcgc => rw_crapass.nrcpfcgc) LOOP

          IF rw_crapass_cpfcgc.nrdconta = pr_nrdconta THEN
             vr_nrctremp := pr_nrctremp;
          ELSE
             vr_nrctremp := 0;
          END IF;

          rw_crawepr_pend := NULL;
          OPEN cr_crawepr_pend(pr_cdcooper => rw_crapass_cpfcgc.cdcooper,
                               pr_nrdconta => rw_crapass_cpfcgc.nrdconta,
                               pr_nrctremp => vr_nrctremp);
          FETCH cr_crawepr_pend INTO rw_crawepr_pend;        
          CLOSE cr_crawepr_pend; 
          
          vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne; 
          
          --> Selecionar o saldo disponivel do pre-aprovado da conta em questão  da carga ativa
          IF rw_crapass_cpfcgc.flgcrdpa = 1 THEN
            -- Calcular o pre-aprovado disponível
            empr0002.pc_calc_pre_aprovad_sint_cta(pr_cdcooper => rw_crapass_cpfcgc.cdcooper
                                                 ,pr_nrdconta => rw_crapass_cpfcgc.nrdconta
                                                 ,pr_vlparcel => vr_vlparcel
                                                 ,pr_vldispon => vr_vldispon
                                                 ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Incrementar o disponível
            vr_vllimdis := nvl(vr_vldispon, 0) + vr_vllimdis;
	      END IF;
      END LOOP;
      
      vr_obj_proposta.put('endividamentoContaValor'     ,(vr_vlutiliz + vr_vltotccr));
      vr_obj_proposta.put('propostasPendentesValor'     ,fn_decimal_ibra(vr_vlprapne) );
      vr_obj_proposta.put('limiteCooperadoValor'        ,fn_decimal_ibra(nvl(vr_vllimdis,0)) );
      
      -- Busca PDF gerado pela análise automática do Motor        
      vr_dsprotoc := este0001.fn_protocolo_analise_auto(pr_cdcooper => pr_cdcooper
                                                       ,pr_nrdconta => pr_nrdconta
                                                       ,pr_nrctremp => pr_nrctremp);
                                                       
      vr_obj_proposta.put('protocoloPolitica'          ,vr_dsprotoc);
      
	  -- Tratativa exclusiva para ambiente de homologacao, não deve existir o parametro "URI_WEBSRV_ESTEIRA_HOMOL"
	  -- em ambiente produtivo
      IF (trim(gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL')) IS NOT NULL) THEN
        vr_obj_proposta.put('ambienteTemp','true');
        vr_obj_proposta.put('urlRetornoTemp', gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') );
      END IF;
      
      -- Copiar parâmetro
      vr_nmarquiv := pr_nmarquiv;
      
      -- Caso não tenhamos recebido o PDF
      IF vr_nmarquiv IS NULL THEN 
        
        -- Gerar ID aleatório
        vr_dsiduser := dbms_random.string('A', 27);
        
        -- Nome do PDF para gerar
        vr_nmarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_nmsubdir => '/rl')
                    ||'/'||vr_dsiduser||'.pdf';
        
        -- Acionaremos a geração do PDF da Proposta
        -- via Schell Script pois esta funcionalidade
        -- esta no Progress e não há previsão de conversão
        empr0003.pc_gera_proposta_pdf(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => 1
                                     ,pr_nmdatela => 'ATENDA'
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_idorigem => pr_cdorigem
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_dsiduser => vr_dsiduser
                                     ,pr_nmarqpdf => vr_nmarquiv);
        -- Se o arquivo não existir
        IF NOT gene0001.fn_exis_arquivo(vr_nmarquiv) THEN 
          -- Remover o conteudo do nome do arquivo para não enviar
          vr_nmarquiv := null;
        END IF;
        
      END IF;
      
      IF vr_nmarquiv IS NOT NULL THEN
        -- Converter arquivo PDF para clob em base64 para enviar via json
        pc_arq_para_clob_base64(pr_nmarquiv       => vr_nmarquiv
                               ,pr_json_value_arq => vr_json_valor
                               ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN                        
          RAISE vr_exc_erro;
        END IF;
        -- Gerar objeto json para a imagem 
        vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
        vr_obj_imagem.put('conteudo'    ,vr_json_valor);
        vr_obj_imagem.put('emissaoData' , fn_Data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData', '');
        -- incluir objeto imagem na proposta
        vr_lst_doctos.append(vr_obj_imagem.to_json_value());
        
        -- Caso o PDF tenha sido gerado nesta rotina
        IF vr_nmarquiv <> NVL(pr_nmarquiv,' ') THEN 
          -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
          GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmarquiv);
        END IF;
      END IF;
                 
      -- Se encontrou PDF de análise Motor
      IF vr_dsprotoc IS NOT NULL THEN
                
        -- Diretorio para salvar
        vr_dsdirarq := GENE0001.fn_diretorio (pr_tpdireto => 'C' --> usr/coop
                                             ,pr_cdcooper => 3
                                             ,pr_nmsubdir => '/log/webservices'); 

        -- Utilizar o protocolo para nome do arquivo
        vr_nmarquiv := vr_dsprotoc || '.pdf';

        -- Comando para download
        vr_dscomando := GENE0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

        -- Substituir o caminho do arquivo a ser baixado
        vr_dscomando := replace(vr_dscomando
                               ,'[local-name]'
                               ,vr_dsdirarq || '/' || vr_nmarquiv);

        -- Substiruir a URL para Download
        vr_dscomando := REPLACE(vr_dscomando
                               ,'[remote-name]'
                               ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')
                               ||GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')
                               || '_result/' || vr_dsprotoc || '/pdf');

        -- Executar comando para Download
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomando);

        
        -- Se NAO encontrou o arquivo
        IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) THEN
          vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
          RAISE vr_exc_erro;
          END IF;
          
        -- Converter arquivo PDF para clob em base64 para enviar via json
        pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                               ,pr_json_value_arq => vr_json_valor
                               ,pr_dscritic       => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN                        
          RAISE vr_exc_erro;
      END IF;
                 
        -- Gerar objeto json para a imagem 
        vr_obj_imagem.put('codigo'      ,'RESULTADO_POLITICA');
        vr_obj_imagem.put('conteudo'    ,vr_json_valor);
        vr_obj_imagem.put('emissaoData' ,fn_Data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData','');
        -- incluir objeto imagem na proposta
        vr_lst_doctos.append(vr_obj_imagem.to_json_value());
          
        -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
        GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv);
                
      END IF;
        
      -- Incluiremos os documentos ao json principal
      vr_obj_proposta.put('documentos',vr_lst_doctos);
                 
    ELSE -- caso for CDC, enviar vazio
      vr_obj_proposta.put('endividamentoContaValor'     ,'');
      vr_obj_proposta.put('propostasPendentesValor'     ,'');
      vr_obj_proposta.put('endividamentoContaValor'     ,'');
    END IF;            
    
    vr_obj_proposta.put('contratoNumero'     ,rw_crawepr.nrctremp);

    -- Verificar se a conta é de colaborador do sistema Cecred
    vr_cddcargo := NULL;
    OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                   ,pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_tbcolab
     INTO vr_cddcargo;
    IF cr_tbcolab%FOUND THEN 
      vr_flgcolab := TRUE;
    ELSE
      vr_flgcolab := FALSE;
    END IF;
    CLOSE cr_tbcolab; 
    
    -- Enviar tag indicando se é colaborador
    vr_obj_proposta.put('cooperadoColaborador',vr_flgcolab);
    
    -- Enviar o cargo somente se colaborador
    IF vr_flgcolab THEN 
      vr_obj_proposta.put('codigoCargo',vr_cddcargo);
    END IF;
    
    -- Enviar nivel de risco no momento da criacao 
    vr_obj_proposta.put('classificacaoRisco',rw_crawepr.dsnivris);
    
    -- Enviar flag se a proposta é de renogociação
    vr_obj_proposta.put('renegociacao',(rw_crawepr.dsliquid != '0,0,0,0,0,0,0,0,0,0'));
    
    -- Buscar parâmetro da quantidade de meses para encontro do histórico de empréstimos
    vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPREST');
   
    -- Busca maior atraso dentre os emprestimos do cooperado        
    OPEN cr_crapris(null, add_months(rw_crapdat.dtmvtolt,-vr_qthisemp));
    FETCH cr_crapris
     INTO vr_qtddiatr;
    CLOSE cr_crapris; 

	vr_qtddiatr := nvl(vr_qtddiatr,0);

    -- Enviar flag política de crédito
    IF rw_crawepr.inliquid_operac_atraso = 0 THEN
      vr_ind_opeatr := false;
    ELSE
      vr_ind_opeatr := true;
    END IF;
    
    vr_obj_proposta.put('operacaoCreditoNaoLiquidada',vr_ind_opeatr);
    vr_obj_proposta.put('quantidadeDiasAtraso',vr_qtddiatr);

    -- BUscar faturamento se pessoa Juridica
    IF rw_crapass.inpessoa = 2 THEN 
      -- Buscar faturamento 
      OPEN cr_crapjfn(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjfn
       INTO rw_crapjfn;
      CLOSE cr_crapjfn;
      vr_obj_proposta.put('faturamentoAnual',fn_decimal_ibra(rw_crapjfn.vltotfat));
    END IF;

    vr_obj_proposta.put('canalCodigo',rw_crawepr.cdorigem);
    vr_obj_proposta.put('canalDescricao',gene0001.vr_vet_des_origens(rw_crawepr.cdorigem));
    
    -- Devolver o objeto criado
    pr_proposta := vr_obj_proposta;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel montar objeto proposta: '||SQLERRM;
  END pc_gera_json_proposta;
  
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                   ,pr_cdorigem  IN INTEGER
                                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                   ,pr_nmarquiv  IN VARCHAR2
                                    ---- OUT ----
                                   ,pr_dsmensag OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    
      Programa : pc_incluir_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 13/07/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
      Alteração : 
                  13/07/2017 - P337 - Ajustes para envio ao Motor - Marcos(Supero)
        
                  15/12/2017 - P337 - SM - Ajustes no envio para retormar reinício 
                               de fluxo (Marcos-Supero)        

                  17/07/2019 - Inclusao da chamada da fn_agenda_reenvio_analise
                               Rafael Rocha (AmCom)
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    vr_obj_proposta      json := json();
    vr_obj_proposta_clob clob;
    
    vr_dsprotoc VARCHAR2(1000);
		vr_comprecu VARCHAR2(1000);
		
    -- Buscar informações da Proposta
		CURSOR cr_crawepr IS
			SELECT wpr.insitest
            ,wpr.insitapr
            ,wpr.cdopeapr
            ,wpr.cdagenci
            ,wpr.nrctaav1
            ,wpr.nrctaav2
            ,ass.inpessoa
            ,wpr.dsprotoc
            ,wpr.cdlcremp
            ,wpr.cdfinemp
            ,wpr.rowid
				FROM crawepr wpr
            ,crapass ass
			 WHERE wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
				 AND wpr.nrdconta = pr_nrdconta
				 AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Tipo Envio Esteira
    vr_tpenvest varchar2(1);
    
    -- Acionamentos de retorno
    CURSOR cr_aciona_retorno(pr_dsprotocolo VARCHAR2) IS
      SELECT ac.dsconteudo_requisicao
        FROM tbgen_webservice_aciona ac
       WHERE ac.cdcooper = pr_cdcooper
         AND ac.nrdconta = pr_nrdconta
         AND ac.nrctrprp = pr_nrctremp
         AND ac.dsprotocolo = pr_dsprotocolo
         AND ac.tpacionamento = 2; -- Somente Retorno
    vr_dsconteudo_requisicao tbgen_webservice_aciona.dsconteudo_requisicao%TYPE;
    
    -- Hora de Envio
    vr_hrenvest crawepr.hrenvest%TYPE;
    -- Quantidade de segundos de Espera
		vr_qtsegund NUMBER;
    -- Analise finalizada
    vr_flganlok boolean := FALSE;
    
    -- Objetos para retorno das mensagens
    vr_obj     cecred.json := json();
    vr_obj_anl cecred.json := json();
    vr_obj_lst cecred.json_list := json_list();
    vr_obj_msg cecred.json := json();
    vr_destipo varchar2(1000);
    vr_desmens varchar2(4000);
    vr_dsmensag VARCHAR2(32767);
    vr_inobriga VARCHAR2(1);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
    --
    --/ verifica se existe reenvio automatico agendado para a proposta de credito em execucao
    FUNCTION fn_reenvio_ativo_job(pr_cdcooper  IN crawepr.cdcooper%TYPE
                                 ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                 ,pr_nrctremp  IN crawepr.nrctremp%TYPE) RETURN  BOOLEAN IS
    --/  
    vr_existe_agend NUMBER(5);
    --
  BEGIN    
      --/
      SELECT COUNT(*)
        INTO vr_existe_agend
        FROM tbepr_reenvio_analise tra
       WHERE tra.cdcooper = pr_cdcooper
         AND tra.nrdconta = pr_nrdconta
         AND tra.nrctremp = pr_nrctremp
         AND trunc(tra.dtagernv) = trunc(sysdate) 
         AND tra.insitrnv = 3; -- em execucao
      --/      
      RETURN ( vr_existe_agend > 0 );
      --/
    EXCEPTION WHEN OTHERS THEN
      RETURN FALSE; 
    END fn_reenvio_ativo_job;
    --
    PROCEDURE pc_cancela_reenvio(pr_cdcooper  IN crawepr.cdcooper%TYPE
                                ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                ,pr_nrctremp  IN crawepr.nrctremp%TYPE) IS
    --/  
    vr_existe_agend NUMBER(5);
    --
    BEGIN
      --/
      FOR rw IN ( SELECT ROWID
                    FROM tbepr_reenvio_analise tra
                   WHERE tra.cdcooper = pr_cdcooper
                     AND tra.nrdconta = pr_nrdconta
                     AND tra.nrctremp = pr_nrctremp
                 )
      LOOP                    
  
       UPDATE tbepr_reenvio_analise
          SET insitrnv = 5  -- Cancelado
        WHERE ROWID = rw.rowid;
        -- Efetuar gravação
        COMMIT;
      END LOOP;
      --/
    EXCEPTION WHEN OTHERS THEN
     NULL;
    END pc_cancela_reenvio;
   --/
  BEGIN    
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,    
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF; 
  
	  -- Buscar informações da proposta
	  OPEN cr_crawepr;
		FETCH cr_crawepr INTO rw_crawepr;
		CLOSE cr_crawepr;
    --
    --/caso exista um reenvio pelo JOB ativo e a sessao nao for a do JOB, 
    -- aborta o processo com critica
    IF fn_reenvio_ativo_job(pr_cdcooper,pr_nrdconta,pr_nrctremp) AND NOT fn_get_job_reenvioanalise
      THEN
         vr_dscritic := gene0001.fn_param_sistema('CRED',pr_cdcooper,'METODO_REENVIO_MSG');
         RAISE vr_exc_erro;
          
    ELSIF NOT fn_get_job_reenvioanalise THEN
       -- se nao for sessao do JOB cancela reenvio agendado pelo JOB caso exista.
       pc_cancela_reenvio(pr_cdcooper,pr_nrdconta,pr_nrctremp);
    END IF;
    
    -- Verificar se a Cooperativa/Linha/Finalidade Obriga a passagem pelo Motor
    pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                  ,pr_inpessoa => rw_crawepr.inpessoa
                                  ,pr_cdfinemp => rw_crawepr.cdfinemp
                                  ,pr_cdlcremp => rw_crawepr.cdlcremp                                      
                                  ,pr_inobriga => vr_inobriga
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    
    -- Se Obrigatorio e ainda não Enviada ou Enviada mas com Erro Conexao
    IF vr_inobriga = 'S' AND (rw_crawepr.insitest = 0 OR rw_crawepr.insitapr = 6) THEN 
      
      --> Gerar informações no padrao JSON da proposta de emprestimo
			ESTE0002.pc_gera_json_analise(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
													          pr_cdagenci  => rw_crawepr.cdagenci, --> Agência da Proposta
													          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
													          pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
													          pr_nrctaav1  => rw_crawepr.nrctaav1, --> Avalista 01
													          pr_nrctaav2  => rw_crawepr.nrctaav2, --> Avalista 02
													          ---- OUT ----
													          pr_dsjsonan  => vr_obj_proposta,  --> Retorno do clob em modelo json das informações
													          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
													          pr_dscritic  => vr_dscritic); --> Descricao da critica
	    
			IF nvl(vr_cdcritic,0) > 0 OR
				 TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_erro;        
			END IF;           
			
	    --> Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa da Proposta
      IF rw_crawepr.inpessoa = 1 THEN 
  			vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
	  																															,pr_cdcooper
		  																														,'REGRA_ANL_MOTOR_IBRA_PF')||'/start';    
      ELSE
      	vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
	  																															,pr_cdcooper
		  																														,'REGRA_ANL_MOTOR_IBRA_PJ')||'/start';            
      END IF;    
          
                                                          
      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
			json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);
      
      -- Se o DEBUG estiver habilitado
      IF vr_flgdebug = 'S' THEN
        --> Gravar dados log acionamento
        pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                             pr_cdagenci              => pr_cdagenci,          
                             pr_cdoperad              => pr_cdoperad,          
                             pr_cdorigem              => pr_cdorigem,          
                             pr_nrctrprp              => pr_nrctremp,          
                             pr_nrdconta              => pr_nrdconta,          
                             pr_cdcliente             => 1,
                             pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                             pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                             pr_dsuriservico          => NULL,       
                             pr_dsmetodo              => NULL,     
                             pr_dtmvtolt              => pr_dtmvtolt,       
                             pr_cdstatus_http         => 0,
                             pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                             pr_dsresposta_requisicao => null,
                             pr_flgreenvia            => 0,
                             pr_nrreenvio             => 0,
                             pr_tpconteudo            => 1,
                             pr_tpproduto             => 0,
                             pr_idacionamento         => vr_idaciona,
                             pr_dscritic              => vr_dscritic);
        -- Sem tratamento de exceção para DEBUG                    
        --IF TRIM(vr_dscritic) IS NOT NULL THEN
        --  RAISE vr_exc_erro;
        --END IF;
      END IF;       
      
			--> Enviar dados para Análise Automática Esteira (Motor)
      pc_enviar_esteira(pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
											  pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia                                          
											  pr_cdoperad    => pr_cdoperad,          --> codigo do operador
											  pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
											  pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
											  pr_nrctremp    => pr_nrctremp,          --> Numero da proposta de emprestimo          
											  pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento                                      
											  pr_comprecu    => vr_comprecu,          --> Complemento do recuros da URI
											  pr_dsmetodo    => 'POST',               --> Descricao do metodo
											  pr_conteudo    => vr_obj_proposta_clob,  --> Conteudo no Json para comunicacao
											  pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE AUTOMATICA DE CREDITO',  --> Operação efetuada
											  pr_tpenvest    => 'M',                  --> Tipo de envio (Motor)
											  pr_dsprotocolo => vr_dsprotoc,           --> Protocolo gerado
											  pr_dscritic    => vr_dscritic);            

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_proposta_clob);
      dbms_lob.freetemporary(vr_obj_proposta_clob);                        
                        
			-- verificar se retornou critica
			IF vr_dscritic IS NOT NULL THEN
				RAISE vr_exc_erro;
			END IF;
      
      -- Atualizar a proposta
      vr_hrenvest := to_char(SYSDATE,'sssss');
	    BEGIN
				UPDATE crawepr wpr 
					 SET wpr.insitest = 1, -->  1 – Enviada para Analise 
							 wpr.dtenvmot = trunc(SYSDATE), 
							 wpr.hrenvmot = vr_hrenvest,
							 wpr.cdopeste = pr_cdoperad,
							 wpr.dsprotoc = nvl(vr_dsprotoc,' '),
               wpr.insitapr = 0,
               wpr.cdopeapr = NULL,
               wpr.dtaprova = NULL,
               wpr.hraprova = 0
				 WHERE wpr.rowid = rw_crawepr.rowid;      
			EXCEPTION    
				WHEN OTHERS THEN
					vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Análise Automática de Crédito: '||SQLERRM;
					RAISE vr_exc_erro;
			END;

      -- Efetuar gravação
      COMMIT;
      
      -- Buscar a quantidade de segundos de espera pela Análise Automática
      vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_IBRA'),30);

      -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
      WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

        -- Aguardar 0.5 segundo para evitar sobrecarga de processador
        sys.dbms_lock.sleep(0.5);
        
        -- Verificar se a analise jah finalizou 
      	OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;
        CLOSE cr_crawepr;
        
        -- Se a proposta mudou de situação Esteira
        IF rw_crawepr.insitest <> 1 THEN 
          -- Indica que terminou a analise 
          vr_flganlok := true;
        END IF;

      END LOOP;
      
      -- Se chegarmos neste ponto e a analise não voltou OK signifca que houve timeout
      IF NOT vr_flganlok THEN 
        -- Então acionaremos a rotina que solicita via GET o termino da análise
        -- e caso a mesma ainda não tenha terminado, a proposta será salva como Expirada
        ESTE0001.pc_solicita_retorno_analise(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_dsprotoc => vr_dsprotoc);
      END IF;
      
      -- Reconsultar a situação esteira e parecer para retorno
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;
      
      -- Se houve expiração
      IF rw_crawepr.insitest = 1 THEN 
        pr_dsmensag := 'Proposta permanece em <b>Processamento</b>...';
      ELSIF rw_crawepr.insitest = 2 THEN 
        pr_dsmensag := '<b>Avaliação Manual</b>';
      ELSIF rw_crawepr.insitest = 3 THEN 
        -- Conforme tipo de aprovacao
        IF rw_crawepr.insitapr = 1 THEN
          pr_dsmensag := '<b>Aprovada</b>';
        ELSIF rw_crawepr.insitapr = 2 THEN 
          pr_dsmensag := '<b>Rejeitada</b>';          
        ELSIF rw_crawepr.insitapr IN(0,6) THEN 
          pr_dsmensag := '<b>Erro</b> motor de crédito';
        ELSIF rw_crawepr.insitapr = 3 THEN 
          pr_dsmensag := '<b>Com Restricoes</b>';        
        ELSIF rw_crawepr.insitapr = 4 THEN
          pr_dsmensag := '<b>Refazer Proposta</b>';
        ELSIF rw_crawepr.insitapr = 5 THEN
          pr_dsmensag := '<b>Avaliação Manual</b>';
        END IF;
      ELSIF rw_crawepr.insitest = 4 THEN
        pr_dsmensag := '<b>Expirada</b> apos '||vr_qtsegund||' segundos de espera.';        
      ELSIF rw_crawepr.insitest = 5 THEN -- PJ 438 - Márcio (Mouts)
        pr_dsmensag := '<b>Expirada por decurso de prazo</b>';   -- PJ 438 - Márcio (Mouts)
      ELSE 
        pr_dsmensag := '<b>Finalizada</b> com situação indefinida!';
      END IF;
      
      -- Gerar mensagem padrao:
      pr_dsmensag := 'Resultado da Avaliação: '||pr_dsmensag;
      
      -- Se houver protocolo e a analise foi encerrada ou derivada
      IF vr_dsprotoc IS NOT NULL AND rw_crawepr.insitest in(2,3) THEN 
        -- Buscar os detalhes do acionamento de retorno
        OPEN cr_aciona_retorno(vr_dsprotoc);
        FETCH cr_aciona_retorno
         INTO vr_dsconteudo_requisicao;
        -- Somente se encontrou
        IF cr_aciona_retorno%FOUND THEN 
          CLOSE cr_aciona_retorno; 
          -- Processar as mensagens para adicionar ao retorno
          BEGIN 
            -- Efetuar cast para JSON
            vr_obj := json(vr_dsconteudo_requisicao);            
            -- Se existe o objeto de analise
            IF vr_obj.exist('analises') THEN
              vr_obj_anl := json(vr_obj.get('analises').to_char());        
              -- Se existe a lista de mensagens
              IF vr_obj_anl.exist('mensagensDeAnalise') THEN
                vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
                -- Para cada mensagem 
                for vr_idx in 1..vr_obj_lst.count() loop
                  BEGIN
                    vr_obj_msg := json( vr_obj_lst.get(vr_idx));
                    -- Se encontrar o atributo texto e tipo
                    if vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                      vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                      vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                    end if;
                    IF vr_destipo <> 'DETALHAMENTO' THEN
                    vr_dsmensag := vr_dsmensag || '<BR>['||vr_destipo||'] '||vr_desmens;                              
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL; -- Ignorar essa linha
                  END;
                END LOOP;
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN 
              -- Ignorar se o conteudo nao for JSON não conseguiremos ler as mensagens
              null; 
          END; 
        ELSE
          CLOSE cr_aciona_retorno;           
        END IF;
        
        -- Se nao encontrou mensagem
        IF vr_dsmensag IS NULL THEN 
          -- Usar mensagem padrao
          vr_dsmensag := '<br>Obs: para acessar detalhes da decisão, acionar <b>[Detalhes Proposta]</b>';            
        ELSE
          -- Gerar texto padrão 
          vr_dsmensag := '<br>Detalhes da decisão:<br>###'|| vr_dsmensag;
        END IF;
        -- Concatenar ao retorno a mensagem montada
        pr_dsmensag := pr_dsmensag ||vr_dsmensag;
      END IF;
      
      -- Commitar o encerramento da rotina 
      COMMIT;
      
		ELSE
            
      --> Gerar informações no padrao JSON da proposta de emprestimo
      pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                            pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia                                            
                            pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                            pr_cdorigem  => pr_cdorigem,  --> Origem da operacao
                            pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                            pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
                            pr_nmarquiv  => pr_nmarquiv,  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                            ---- OUT ----
                            pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta de emprestimo
                            pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                            pr_dscritic  => vr_dscritic); --> Descricao da critica
      
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;  
  
      --> Se origem veio do Motor/Esteira
      IF pr_cdorigem = 9 THEN 
        -- É uma derivação
        vr_tpenvest := 'D';
      ELSE 
        vr_tpenvest := 'I';
      END IF;
  
      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);  
      
      -- Se o DEBUG estiver habilitado
      IF vr_flgdebug = 'S' THEN
        --> Gravar dados log acionamento
        pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                             pr_cdagenci              => pr_cdagenci,          
                             pr_cdoperad              => pr_cdoperad,          
                             pr_cdorigem              => pr_cdorigem,          
                             pr_nrctrprp              => pr_nrctremp,          
                             pr_nrdconta              => pr_nrdconta,          
                             pr_cdcliente             => 1,       
                             pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                             pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                             pr_dsuriservico          => NULL,       
                             pr_dsmetodo              => NULL,
                             pr_dtmvtolt              => pr_dtmvtolt,       
                             pr_cdstatus_http         => 0,
                             pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                             pr_dsresposta_requisicao => null,
                             pr_flgreenvia            => 0,
                             pr_nrreenvio             => 0,
                             pr_tpconteudo            => 1,
                             pr_tpproduto             => 0,
                             pr_idacionamento         => vr_idaciona,
                             pr_dscritic              => vr_dscritic);
        -- Sem tratamento de exceção para DEBUG                    
        --IF TRIM(vr_dscritic) IS NOT NULL THEN
        --  RAISE vr_exc_erro;
        --END IF;
      END IF;  
      
      --> Enviar dados para Esteira
      pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                          pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia                                          
                          pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                          pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                          pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                          pr_nrctremp    => pr_nrctremp,          --> Numero da proposta de emprestimo atual/antigo
                          pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento                                      
                          pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                          pr_dsmetodo    => 'POST',               --> Descricao do metodo
                          pr_conteudo    => vr_obj_proposta_clob, --> Conteudo no Json para comunicacao
                          pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO',   --> Operacao realizada
                          pr_tpenvest    => vr_tpenvest,          --> Tipo de envio
                          pr_dsprotocolo => vr_dsprotoc,
                          pr_dscritic    => vr_dscritic);            
      
      -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
      IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

        -- Tentaremos enviar alteração com reinício de fluxo para a Esteira 
        este0001.pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper          --> Codigo da cooperativa
                                         ,pr_cdagenci => pr_cdagenci          --> Codigo da agencia 
                                         ,pr_cdoperad => pr_cdoperad          --> codigo do operador
                                         ,pr_cdorigem => pr_cdorigem          --> Origem da operacao
                                         ,pr_nrdconta => pr_nrdconta          --> Numero da conta do cooperado
                                         ,pr_nrctremp => pr_nrctremp          --> Numero da proposta de emprestimo atual/antigo
                                         ,pr_dtmvtolt => pr_dtmvtolt          --> Data do movimento   
                                        ,pr_flreiflx => 1                    --> Reiniciar o fluxo
                                        ,pr_nmarquiv => pr_nmarquiv
                                         ,pr_cdcritic => vr_cdcritic          
                                         ,pr_dscritic => vr_dscritic);

        END IF;
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_obj_proposta_clob);
      dbms_lob.freetemporary(vr_obj_proposta_clob);    
      
      -- verificar se retornou critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
      vr_hrenvest := to_char(SYSDATE,'sssss');
      
      --> Atualizar proposta
      BEGIN
        UPDATE crawepr wpr 
           SET wpr.insitest = 2, -->  2 – Enviada para Analise Manual
               wpr.dtenvest = trunc(SYSDATE), 
               wpr.hrenvest = vr_hrenvest,
               wpr.cdopeste = pr_cdoperad,
               wpr.dsprotoc = nvl(vr_dsprotoc,' '),
               wpr.insitapr = 0,
               wpr.cdopeapr = NULL,
               wpr.dtaprova = NULL,
               wpr.hraprova = 0
         WHERE wpr.rowid = rw_crawepr.rowid;      
      EXCEPTION    
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';
      
      -- Efetuar gravação
      COMMIT;
    
    END IF;
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1, 
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO INCLUIR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    --/

    --/
    IF fn_get_job_reenvioanalise THEN
      UPDATE tbepr_reenvio_analise tra
         SET tra.insitrnv = 4 -- concluido 
       WHERE tra.cdcooper = pr_cdcooper
         AND tra.nrdconta = pr_nrdconta
         AND tra.nrctremp = pr_nrctremp
         AND tra.insitrnv <> 5
         AND trunc(tra.dtagernv) = trunc(sysdate) ;
     END IF;
    --/
    
    -- Verificação para retentativa de envio
    IF rw_crawepr.insitest = 3 AND rw_crawepr.insitapr IN (0,6) THEN
      IF NOT ( este0001.fn_agenda_reenvio_analise(pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdagenci,pr_cdoperad) ) THEN
        --/
        este0001.pc_notificacoes_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp,vr_cdcritic,vr_dscritic);          
      END IF;  
    END IF;
    
    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      --/ P438 
      IF NOT ( este0001.fn_agenda_reenvio_analise(pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdagenci,pr_cdoperad) ) THEN
        --/
        este0001.pc_notificacoes_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp,vr_cdcritic,vr_dscritic);          
      END IF;

    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;

      IF NOT ( este0001.fn_agenda_reenvio_analise(pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdagenci,pr_cdoperad) ) THEN
        --/
        este0001.pc_notificacoes_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp,vr_cdcritic,vr_dscritic);          
      END IF;

  END pc_incluir_proposta_est;
    
  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  PROCEDURE pc_alterar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                    pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                    pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                    pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                    pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                    pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo
                                    pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento
                                    pr_flreiflx  IN INTEGER,                --> Indica se deve reiniciar o fluxo de aprovacao na esteira (1-true, 0-false)
                                    pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                    ---- OUT ----                           
                                    pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                    pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alterar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao da proposta para a esteira    
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
      
    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();  
		vr_dsprotocolo  VARCHAR2(1000);
    vr_obj_proposta_clob clob;
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
  BEGIN                  
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,        
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO ALTERAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,  
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;   
  
    --> Gerar informações no padrao JSON da proposta de emprestimo
    pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                          pr_cdagenci  => pr_cdagenci,  --> Codigo da agencia                                            
                          pr_cdoperad  => pr_cdoperad,  --> codigo do operado
                          pr_cdorigem  => pr_cdorigem,  --> Origem da operacao
                          pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                          pr_nrctremp  => pr_nrctremp,  --> Numero da proposta de emprestimo
                          pr_nmarquiv  => pr_nmarquiv,  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                          ---- OUT ----
                          pr_proposta  => vr_obj_proposta,  --> Retorno do clob em modelo json da proposta de emprestimo
                          pr_cdcritic  => vr_cdcritic,  --> Codigo da critica
                          pr_dscritic  => vr_dscritic); --> Descricao da critica
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;  
    
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    -- Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);
    
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_proposta_clob);
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,        
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES ALTERAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,     
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,          --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,          --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,          --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,          --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,          --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,          --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,          --> Data do movimento                                      
                        pr_comprecu    => NULL,                 --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                --> Descricao do metodo
                        pr_conteudo    => vr_obj_proposta_clob, --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO', --> Operacao realizada
												pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);            
    
    -- Se não houve erro
    IF vr_dscritic IS NULL THEN 
    
    --> Atualizar proposta
    BEGIN
      UPDATE crawepr epr 
         SET epr.insitest = 2, -->  2 – Reenviado para Analise
               epr.dtenvest = trunc(SYSDATE), 
               epr.hrenvest = to_char(SYSDATE,'sssss'),
               epr.cdopeste = pr_cdoperad,
               epr.dsprotoc = nvl(vr_dsprotocolo,' '),
               epr.insitapr = 0,
               epr.cdopeapr = NULL,
               epr.dtaprova = NULL,
               epr.hraprova = 0
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise de Credito: '||SQLERRM;
      END;         

    
    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%proposta nao encontrada%' THEN

      -- Tentaremos enviar inclusão novamente na Esteira
      pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                             ,pr_cdagenci => pr_cdagenci --> Codigo da agencia                                          
                             ,pr_cdoperad => pr_cdoperad --> codigo do operador
                             ,pr_cdorigem => pr_cdorigem --> Origem da operacao
                             ,pr_nrdconta => pr_nrdconta --> Numero da conta do cooperado
                             ,pr_nrctremp => pr_nrctremp --> Numero da proposta de emprestimo atual/antigo
                             ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento                                      
                             ,pr_nmarquiv => NULL
                             ,pr_dsmensag => vr_dsmensag
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

    END IF;  

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF; 
    
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,   
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO ALTERAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,    
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar alteracao da proposta de Analise de Credito: '||SQLERRM;
  END pc_alterar_proposta_est;
  
  --> Rotina responsavel por gerar a alteracao do numero da proposta para a esteira
  PROCEDURE pc_alter_numproposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo antigo
                                      pr_nrctremp_novo IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo novo
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_alter_numproposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao do numero da proposta para a esteira    
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;        
    
    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_agencia  json := json();
		vr_dsprotocolo VARCHAR2(1000);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
    
  BEGIN      
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,         
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO ALTERAR NUMERO PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;                 
       
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;        
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr; 
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_alter.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_alter.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_alter.put('cooperadoContaNum'     , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_alter.put('cooperadoContaDv'      , to_number(substr(rw_crapass.nrdconta,-1)));
    vr_obj_alter.put('numero'                , pr_nrctremp);
    vr_obj_alter.put('propostaNovoNumero'    , pr_nrctremp_novo);
    vr_obj_alter.put('contratoNumero'        , pr_nrctremp_novo); 
    vr_obj_alter.put('cooperadoTipoPessoa'   , rw_crapass.inpessoa_ibra);
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_alter.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_alter.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF; 
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'   , vr_obj_agencia);
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;        
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,        
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES ALTERAR NUMERO PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,         
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_alter.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;      
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,                  --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,                  --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,                  --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,                  --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,                  --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,                  --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,                  --> Data do movimento                                      
                        pr_comprecu    => '/numeroProposta',            --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                        --> Descricao do metodo
                        pr_conteudo    => vr_obj_alter.to_char,         --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA ALTERACAO DO NUMERO DA PROPOSTA PARA ANALISE DE CREDITO',  --> Operacao realizada
												pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;      
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,                                    
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO ALTERAR NUMERO PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;   
    
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar alteracao do numero da proposta para Analise de Credito: '||SQLERRM;
  END pc_alter_numproposta_est;
  
  --> Rotina para efetuar a derivação de uma proposta para a Esteira
  PROCEDURE pc_derivar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                   ,pr_cdorigem  IN INTEGER
                                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) IS
    /* ..........................................................................
    
      Programa : pc_derivar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Marcos Martini (Supero)
      Data     : Dezembro/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por verificar a proposta e enviar 
                  inclusao ou alteração da proposta na esteira
      
      Alteração : 06/08/2019 - P438 - Inclusão da chamada para retentativa de envio 
                               em caso de retorno de erro. (Douglas Pagel / AMcom).
        
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------

    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
		
    -- Buscar informações da Proposta
		CURSOR cr_crawepr IS
			SELECT wpr.insitest
            ,wpr.insitapr
            ,wpr.dtenvest
            ,wpr.dtenvmot
            ,wpr.dsprotoc
            ,wpr.cdorigem
				FROM crawepr wpr
			 WHERE wpr.cdcooper = pr_cdcooper
				 AND wpr.nrdconta = pr_nrdconta
				 AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Obrigação de envio ao Motor 
    vr_inobriga VARCHAR2(1);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
  BEGIN    
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO DERIVAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF; 
  
	  -- Buscar informações da proposta
	  OPEN cr_crawepr;
		FETCH cr_crawepr INTO rw_crawepr;
		CLOSE cr_crawepr;
    
    -- Para Propostas ainda não enviada para a Esteira
    IF rw_crawepr.dtenvest IS NULL THEN
      -- Inclusão na esteira
      pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_cdorigem => pr_cdorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_nmarquiv => NULL
                             ,pr_dsmensag => vr_dsmensag
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
    ELSE
      -- Atualização com reinício de fluxo 
      pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_cdorigem => pr_cdorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_flreiflx => 1
                             ,pr_nmarquiv => NULL
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      
    END IF;
    
    -- Testar erro
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,        
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO DERIVAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      --> Gerar em LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                pr_ind_tipo_log => 2,
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                || ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '
                                                || ' do Protocolo: '||rw_crawepr.dsprotoc
                                                || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                pr_flnovlog     => 'N',
                                pr_flfinmsg     => 'S',
                                pr_dsdirlog     => NULL,
                                pr_dstiplog     => 'O',
                                PR_CDPROGRAMA   => NULL);
    
      IF NOT ( este0001.fn_agenda_reenvio_analise(pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdagenci,pr_cdoperad) ) THEN
        --/
        este0001.pc_notificacoes_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp,vr_cdcritic,vr_dscritic);          
      END IF;

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Não foi possivel realizar derivacao da proposta de Análise de Crédito: '||SQLERRM;
      
      --> Gerar em LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                pr_ind_tipo_log => 2,
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                || ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '
                                                || ' do Protocolo: '||rw_crawepr.dsprotoc
                                                || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                pr_flnovlog     => 'N',
                                pr_flfinmsg     => 'S',
                                pr_dsdirlog     => NULL,
                                pr_dstiplog     => 'O',
                                PR_CDPROGRAMA   => NULL);      

      IF NOT ( este0001.fn_agenda_reenvio_analise(pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdagenci,pr_cdoperad) ) THEN
        --/
        este0001.pc_notificacoes_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp,vr_cdcritic,vr_dscritic);          
      END IF;

  END pc_derivar_proposta_est;
  
  --> Rotina responsavel por gerar o cancelamento da proposta para a esteira
  PROCEDURE pc_cancelar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_cancelar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 09/03/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar o cancelamento da proposta para a esteira
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
    -- Objeto json da proposta
    vr_obj_cancelar json := json();
    vr_obj_agencia  json := json();
    -- Auxiliares
    vr_dsprotocolo VARCHAR2(1000);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
    
  BEGIN
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO CANCELAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;     
     
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr; 
          
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_cancelar.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_cancelar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_cancelar.put('cooperadoContaNum'     , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_cancelar.put('cooperadoContaDv'      , to_number(substr(rw_crapass.nrdconta,-1)));    
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    
    vr_obj_cancelar.put('numero'                , pr_nrctremp);
    vr_obj_cancelar.put('operadorCancelamentoLogin',lower(pr_cdoperad));
    vr_obj_cancelar.put('operadorCancelamentoNome' ,rw_crapope.nmoperad) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_cancelar.put('operadorCancelamentoPA'   , vr_obj_agencia);    
    vr_obj_cancelar.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;        
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES CANCELAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_cancelar.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento                                      
                        pr_comprecu    => '/cancelar',               --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_cancelar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DO CANCELAMENTO DA PROPOSTA DE ANALISE DE CREDITO',       --> Operacao realizada
												pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica (Ignorar a critica de Proposta Nao Encontrada
    IF vr_dscritic IS NOT NULL AND lower(vr_dscritic) NOT LIKE '%proposta nao encontrada%' THEN
      RAISE vr_exc_erro;
    END IF;      
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO CANCELAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;   
    
    --> Atualizar proposta
    BEGIN
      UPDATE crawepr wpr 
         SET wpr.dtenvest = NULL
            ,wpr.hrenvest = 0
            ,wpr.cdopeste = ' '
       WHERE wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos cancelamento: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
    
    COMMIT;  
        
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar o cancelamento da Analise de Credito: '||SQLERRM;
  END pc_cancelar_proposta_est;
  
  --> Rotina responsavel por gerar o cancelamento da proposta para a esteira
  PROCEDURE pc_interrompe_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                       pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                       pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                       pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                       pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                       pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                       ---- OUT ----                           
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_interrompe_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Marcos Martini (Supero)
      Data     : Dezembro/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por interromper o fluxo da proposta na esteira
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    
    -- Objeto json da proposta
    vr_obj_cancelar json := json();
    vr_obj_agencia  json := json();
    -- Auxiliares
    vr_dsprotocolo VARCHAR2(1000);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
    
  BEGIN
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO INTERROMPE PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;     
     
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr; 
          
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_cancelar.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_cancelar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_cancelar.put('cooperadoContaNum'     , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_cancelar.put('cooperadoContaDv'      , to_number(substr(rw_crapass.nrdconta,-1)));    
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_cancelar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    
    vr_obj_cancelar.put('numero'                , pr_nrctremp);
    vr_obj_cancelar.put('operadorCancelamentoLogin',lower(pr_cdoperad));
    vr_obj_cancelar.put('operadorCancelamentoNome' ,rw_crapope.nmoperad) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_cancelar.put('operadorCancelamentoPA'   , vr_obj_agencia);    
    vr_obj_cancelar.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;        
   
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,      
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES INTERROMPER PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_cancelar.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento                                      
                        pr_comprecu    => '/interromperFluxo',       --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_cancelar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA INTERRUPÇÃO DA PROPOSTA DE ANALISE DE CREDITO',       --> Operacao realizada
												pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);            
    
    -- Verificar se retornou critica (Ignorar a critica de Proposta Nao Encontrada ou proposta nao permite interromper o fluxo
    IF vr_dscritic IS NOT NULL 
      AND lower(vr_dscritic) NOT LIKE '%proposta nao encontrada%' 
      AND lower(vr_dscritic) NOT LIKE '%proposta nao permite interromper o fluxo%'
      AND lower(vr_dscritic) NOT LIKE '%produto cdc nao integrado%' THEN
      RAISE vr_exc_erro;
    END IF;    
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO INTERROMPER PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;   
    
    COMMIT;          
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar a interrupcao da Analise de Credito: '||SQLERRM;
  END pc_interrompe_proposta_est;  
  
  --> Rotina responsavel por gerar efetivacao da proposta para a esteira
  PROCEDURE pc_efetivar_proposta_est( pr_cdcooper  IN crawepr.cdcooper%TYPE,  --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,  --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,  --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,  --> Numero da proposta de emprestimo atual/antigo                                      
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,  --> Data do movimento                                      
                                      pr_nmarquiv  IN VARCHAR2,               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                      ---- OUT ----                           
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
    /* ..........................................................................
    
      Programa : pc_efetivar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 30/01/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a efetivacao da proposta para a esteira
      Alteração : 20/09/2016 - Atualizar a data de envio da efetivação da proposta 
                  no Oracle, no Progress estava gerando erro (Oscar).
                  
                  22/09/2016 - Enviar a data em que a proposta foi efetivada ao invés
                  da data do dia.
        
                  30/01/2017 - Remocao do campo tipo de emprestimo. (Jaison/James - PRJ298)

       				   20/12/2017 - Incluídos históricos 2013 e 2014 no cursor cr_craplem Prj. 402 (Jean Michel).

                  30/10/2018 - Adicionado novos campos projeto 439 (Rafael Faria - Supero)
    ..........................................................................*/ 
    
    -----------> CURSORES <-----------
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta,
             ass.nmprimtl,
             ass.cdagenci,
             age.nmextage,
             ass.inpessoa,
             decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
             ass.nrcpfcgc
               
        FROM crapass ass,
             crapage age
       WHERE ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta; 
    rw_crapass cr_crapass%ROWTYPE;
    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT wepr.nrctremp,
             wepr.vlemprst,
             wepr.qtpreemp,
             wepr.dtvencto,
             wepr.vlpreemp,
             wepr.hrinclus,
             wepr.cdagenci,
             wepr.cdlcremp,
             lcr.dslcremp,
             wepr.cdfinemp,
             lcr.tpctrato,
             epr.cdopeefe,
             ope.nmoperad nmoperad_efet,
             epr.cdagenci cdagenci_efet,             
             -- Indica que am linha de credito eh CDC ou C DC
             DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper
                                               ,pr_cdfinemp => epr.cdfinemp),3,1,0) AS inlcrcdc,
             epr.dtmvtolt,
             epr.vltarifa,
             epr.vliofepr,
             epr.vlemprst vlempfin,
             epr.txmensal,
             epr.vliofadc,
             empr0012.fn_retorna_comissao_emp(pr_cdcooper=> epr.cdcooper
                                             ,pr_nrdconta=> epr.nrdconta
                                             ,pr_nrctremp=> epr.nrctremp) vlcomissao,
             add_months(wepr.dtvencto,wepr.qtpreemp -1) dtultpag
        FROM crawepr wepr,
             craplcr lcr,
             crapope ope,
             crapepr epr
       WHERE wepr.cdcooper = lcr.cdcooper
         AND wepr.cdlcremp = lcr.cdlcremp
         AND wepr.cdcooper = epr.cdcooper
         AND wepr.nrdconta = epr.nrdconta
         AND wepr.nrctremp = epr.nrctremp
         AND  epr.cdcooper = ope.cdcooper(+)
         AND  upper(epr.cdopeefe) = upper(ope.cdoperad(+))
         AND wepr.cdcooper = pr_cdcooper
         AND wepr.nrdconta = pr_nrdconta
         AND wepr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;   
    
    
   CURSOR cr_craplem (pr_cdcooper craplem.cdcooper%TYPE,
                      pr_nrdconta craplem.nrdconta%TYPE,
                      pr_nrctremp craplem.nrctremp%TYPE,
                      pr_dtmvtolt craplem.dtmvtolt%TYPE)IS  
                        
    SELECT dthrtran
      FROM craplem
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtmvtolt = pr_dtmvtolt
       AND cdhistor IN (99, 1032, 1036, 1059, 2013, 2014) /* Efetivação */
       AND rownum = 1;
    rw_craplem cr_craplem%ROWTYPE;  
    
    -- Buscar os bens em garanita na Proposta
    CURSOR cr_crapbpr (pr_cdcooper crapbpr.cdcooper%type,
                       pr_nrdconta crapbpr.nrdconta%TYPE,
                       pr_nrctremp crapbpr.nrctrpro%TYPE ) IS       
      SELECT crapbpr.vlmerbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp   
         AND crapbpr.tpctrpro = 90
         AND rownum=1
         AND trim(crapbpr.dscatbem) is not NULL;
    rw_crapbpr cr_crapbpr%ROWTYPE;
       
    --> verificar se dados do CET já foram gravados
    CURSOR cr_tbepr_calculo_cet (pr_cdcooper tbepr_calculo_cet.cdcooper%type
                                ,pr_nrdconta tbepr_calculo_cet.nrdconta%TYPE
                                ,pr_nrctremp tbepr_calculo_cet.nrctremp%TYPE) IS
      SELECT t.txmensal
            ,t.vlrdoiof
            ,t.vlrdsegu
            ,t.vlrtarif
            ,t.txanocet
        FROM tbepr_calculo_cet t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctremp = pr_nrctremp;
    rw_tbepr_calculo_cet cr_tbepr_calculo_cet%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    -- Objeto json da proposta
    vr_obj_efetivar json := json();
    vr_obj_agencia  json := json();
    vr_obj_imagem   json := json(); 
    
    -- Auxiliares
    vr_json_valor   json_value;
    vr_dsprotocolo  VARCHAR2(1000);
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
    -- variaveis programa
    vr_txdjuros      NUMBER;
    vr_vlentbem      NUMBER;
    vr_vlmerbem      NUMBER;
    vr_vliofadi      NUMBER;
    vr_vlpertar      NUMBER;
    
  BEGIN
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO EFETIVAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;     
  
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_craplem(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp,
                    pr_dtmvtolt => rw_crawepr.dtmvtolt);
    FETCH cr_craplem INTO rw_craplem;
    
    -- Caso nao encontrar abortar proceso
    IF cr_craplem%NOTFOUND THEN
      CLOSE cr_craplem;
      vr_cdcritic := 0; 
      vr_dscritic := 'Proposta nao foi efetivada.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craplem;
    
        
    
    --> Criar objeto json para agencia da proposta
    /***************** VERIFICAR *********************/
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crawepr.cdagenci);    
    vr_obj_efetivar.put('PA' ,vr_obj_agencia);    
    vr_obj_agencia := json();
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
    vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);    
    vr_obj_efetivar.put('cooperadoContaPA' ,vr_obj_agencia);
    vr_obj_agencia := json();
    
    -- Nr. conta sem o digito
    vr_obj_efetivar.put('cooperadoContaNum'      , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
    -- Somente o digito
    vr_obj_efetivar.put('cooperadoContaDv'       , to_number(substr(rw_crapass.nrdconta,-1)));
    
    IF rw_crapass.inpessoa = 1 THEN
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
    ELSE
      vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
    END IF;
    
    --> Verificar se possui o operador que realizou a efetivacao
    IF TRIM(rw_crawepr.cdopeefe) IS NULL THEN
      vr_dscritic := 'Operador da efetivacao da proposta nao encontrado.'; 
      RAISE vr_exc_erro; 
    END IF;
    
    vr_obj_efetivar.put('numero'                 , pr_nrctremp);

    /*
      produtoCreditoSegmentoCodigo
      (0 – CDC Diversos
     , 1 – CDC Veículos
     , 2 – Empréstimos /Financiamentos
     , 3 – Desconto Cheques – Limite
     , 4 – Desconto Cheques - Borderô
     , 5 – Desconto Título – Limite
     , 6 – Desconto de Títulos – Borderô
     , 7 – Cartão de Crédito
     , 8 – Limite de Crédito (Conta)
     , 9 – Consignado)
     */

    IF rw_crawepr.cdfinemp = 58 and rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 0);
    ELSIF rw_crawepr.cdfinemp = 59 and rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 1);
    ELSE
      vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 2);  
    END IF;

    vr_obj_efetivar.put('operadorEfetivacaoLogin', rw_crawepr.cdopeefe);
    vr_obj_efetivar.put('operadorEfetivacaoNome' , rw_crawepr.nmoperad_efet) ;
     --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'       , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'                , rw_crawepr.cdagenci_efet);    
    vr_obj_efetivar.put('operadorEfetivacaoPA'   , vr_obj_agencia);    
    vr_obj_efetivar.put('dataHora'               ,fn_DataTempo_ibra(COALESCE(rw_craplem.dthrtran, SYSDATE))) ; 
    vr_obj_efetivar.put('contratoNumero'         , pr_nrctremp);
    vr_obj_efetivar.put('valor'                  , rw_crawepr.vlemprst);
    vr_obj_efetivar.put('parcelaQuantidade'      , rw_crawepr.qtpreemp);
    vr_obj_efetivar.put('parcelaPrimeiroVencimento' , fn_Data_ibra( rw_crawepr.dtvencto));
    -- se for CDC envia o ultimo vencimento
    IF rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_efetivar.put('parcelaUltimoVencimento' , fn_Data_ibra( rw_crawepr.dtultpag));
    END IF;
    vr_obj_efetivar.put('parcelaValor'           , fn_decimal_ibra(rw_crawepr.vlpreemp));
    
    -- Gerar imagem apensa se nao for CDC
    IF rw_crawepr.inlcrcdc = 0 THEN
      IF pr_nmarquiv IS NOT NULL THEN
        --> converter arquivo PDF para clob em base64 para enviar via json
        pc_arq_para_clob_base64(pr_nmarquiv       => pr_nmarquiv,
                                pr_json_value_arq => vr_json_valor, 
                                pr_dscritic       => vr_dscritic);
                                
        IF TRIM(vr_dscritic) IS NOT NULL THEN                        
          RAISE vr_exc_erro;
        END IF;
        
        -- Gerar objeto json para a imagem 
        vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
        vr_obj_imagem.put('imagem'      , vr_json_valor);
        vr_obj_imagem.put('emissaoData' , fn_Data_ibra(SYSDATE));
        vr_obj_imagem.put('validadeData', '');
        -- incluir objeto imagem na proposta
        vr_obj_efetivar.put('imagem'    ,vr_obj_imagem);
      END IF;
                 
    END IF;
    
    
    -----------------------------------------------------------------------------------------------
    IF rw_crawepr.inlcrcdc = 1 THEN

      OPEN cr_tbepr_calculo_cet (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp);
      FETCH cr_tbepr_calculo_cet INTO rw_tbepr_calculo_cet;
      CLOSE cr_tbepr_calculo_cet;
      
      vr_obj_efetivar.put('valorCET', ESTE0001.fn_decimal_ibra(rw_tbepr_calculo_cet.txanocet)); 
      vr_obj_efetivar.put('valorIOF', ESTE0001.fn_decimal_ibra(rw_crawepr.vliofepr));
      vr_obj_efetivar.put('valorTarifa', ESTE0001.fn_decimal_ibra(rw_crawepr.vltarifa)); 
      vr_obj_efetivar.put('valorTotalFinanciado', ESTE0001.fn_decimal_ibra(rw_crawepr.vlempfin)); 
      vr_obj_efetivar.put('valorRepasse', ESTE0001.fn_decimal_ibra(rw_crawepr.vlemprst)); 
      vr_obj_efetivar.put('multa', ESTE0001.fn_decimal_ibra(2)); --> fixo 2% 
      vr_obj_efetivar.put('valorSeguro', ESTE0001.fn_decimal_ibra(0)); -- fixo 0 [validar]
      
      -- chamar procedure da EMPR0012 com o valor da comissao
      vr_obj_efetivar.put('valorComissionamento', ESTE0001.fn_decimal_ibra(rw_crawepr.vlcomissao)); -- buscar em procedure CDC

      OPEN cr_crapbpr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr INTO rw_crapbpr;

      IF cr_crapbpr%FOUND THEN
        vr_vlmerbem := rw_crapbpr.vlmerbem;
      ELSE
        vr_vlmerbem := rw_crawepr.vlemprst;
      END IF;
      CLOSE cr_crapbpr;
      
      vr_obj_efetivar.put('valorBem', ESTE0001.fn_decimal_ibra(vr_vlmerbem)); --> valor do bem

      vr_vlentbem := vr_vlmerbem - rw_crawepr.vlemprst;
      vr_obj_efetivar.put('valorEntrada', ESTE0001.fn_decimal_ibra(vr_vlentbem));  -- nao temos [ver com ibratan]    

      vr_txdjuros := ROUND((POWER(1 + (nvl(rw_crawepr.txmensal,0) / 100),12) - 1) * 100,2);
      vr_obj_efetivar.put('taxaAoAno', ESTE0001.fn_decimal_ibra(vr_txdjuros)); 

      vr_vliofadi := ROUND(((rw_crawepr.vliofadc / rw_crawepr.vlempfin) * 100),2);
      vr_obj_efetivar.put('percentualIofAdicional', ESTE0001.fn_decimal_ibra(vr_vliofadi)); 
                 
      vr_vlpertar := ROUND(((rw_crawepr.vltarifa / rw_crawepr.vlempfin) * 100),2);
      vr_obj_efetivar.put('percentualTarifa', ESTE0001.fn_decimal_ibra(vr_vlpertar)); 
    END IF;
    -----------------------------------------------------------------------------------------------
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES EFETIVAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_efetivar.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
    
    --> Enviar dados para Esteira
    pc_enviar_esteira ( pr_cdcooper    => pr_cdcooper,               --> Codigo da cooperativa
                        pr_cdagenci    => pr_cdagenci,               --> Codigo da agencia                                          
                        pr_cdoperad    => pr_cdoperad,               --> codigo do operador
                        pr_cdorigem    => pr_cdorigem,               --> Origem da operacao
                        pr_nrdconta    => pr_nrdconta,               --> Numero da conta do cooperado
                        pr_nrctremp    => pr_nrctremp,               --> Numero da proposta de emprestimo atual/antigo
                        pr_dtmvtolt    => pr_dtmvtolt,               --> Data do movimento                                      
                        pr_comprecu    => '/efetivar',               --> Complemento do recuros da URI
                        pr_dsmetodo    => 'PUT',                     --> Descricao do metodo
                        pr_conteudo    => vr_obj_efetivar.to_char,   --> Conteudo no Json para comunicacao
                        pr_dsoperacao  => 'ENVIO DA EFETIVACAO DA PROPOSTA DE ANALISE DE CREDITO',       --> Operacao realizada
												pr_dsprotocolo => vr_dsprotocolo,
                        pr_dscritic    => vr_dscritic);            
    
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
     --> Atualizar proposta
    BEGIN
      UPDATE crawepr epr 
         SET epr.dtenefes = trunc(SYSDATE)
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;      
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da efetivacao de Analise de Credito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,        
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO EFETIVAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;      
    
    COMMIT;         
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar efetivacao da proposta de Analise de Credito: '||SQLERRM;
  END pc_efetivar_proposta_est;
  
  --> Rotina responsavel por consultar informações da proposta na esteira
  PROCEDURE pc_consultar_proposta_est(pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia                                          
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                      pr_cdorigem  IN INTEGER,                  --> Origem da operacao
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo                          
                                      pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,    --> Data do movimento                                      
                                      ---- OUT ----                             
                                      pr_cdsitest OUT NUMBER,                   --> Retorna situacao da proposta    
                                      pr_cdstatan OUT NUMBER,                   --> Retornoa status da proposta                                                                            
                                      pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS              --> Descricao da critica.
    /* .........................................................................
    
      Programa : pc_consultar_proposta_est        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Março/2016.                   Ultima atualizacao: 30/01/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por buscar informações da proposta na esteira
      Alteração : 30/01/2017 - Remocao do campo tipo de emprestimo. (Jaison/James - PRJ298)
        
    ..........................................................................*/
    -----------> CURSORES <-----------        
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.vlemprst,
             epr.qtpreemp,
             epr.dtvencto,
             epr.vlpreemp,
             epr.hrinclus,
             epr.cdlcremp,
             epr.cdfinemp,
             epr.cdagenci
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp; 
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    
    vr_obj_proposta  json := json();
    vr_obj_retorno   json := json();
    
    vr_cdsitest      NUMBER;    
    vr_cdstatan      NUMBER;
    vr_cdsegpro_ret  NUMBER;
    vr_cdlcremp_ret  NUMBER;
    vr_cdfinemp_ret  NUMBER;
    vr_cdtpprod_ret  VARCHAR2(100);
    vr_nrctremp_ret  crawepr.nrctremp%TYPE;
    vr_nrctremp_ret2 crawepr.nrctremp%TYPE;
    vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
  BEGIN
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'INICIO CONSULTAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;    
  
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper      => pr_cdcooper,                   -- Codigo da cooperativa
                          pr_nrdconta      => pr_nrdconta,                   -- Numero da conta do cooperado
                          pr_nrctremp      => pr_nrctremp,                   -- Numero da proposta de emprestimo
                          pr_tpenvest      => 'C',                           -- Tipo de envio C - Consultar(Get)
                          pr_host_esteira  => vr_host_esteira,               -- Host da esteira
                          pr_recurso_este  => vr_recurso_este,               -- URI da esteira
                          pr_dsdirlog      => vr_dsdirlog    ,               -- Diretorio de log dos arquivos 
                          pr_autori_este   => vr_autori_este  ,              -- Authorization 
                          pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                          pr_dscritic      => vr_dscritic    );
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;           
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;        
        
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este;
    vr_request.method    := 'GET';
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    vr_request.parameters('numero') := pr_nrctremp; 
    -- Nr. conta sem o digito
    vr_request.parameters('cooperadoContaNum') := to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1));
    -- Somente o digito
    vr_request.parameters('cooperadoContaDv')  := to_number(substr(pr_nrdconta,-1));
    vr_request.parameters('cooperativaCodigo') := pr_cdcooper;
    vr_request.parameters('valor')             := fn_decimal_ibra(rw_crawepr.vlemprst);      
    vr_request.parameters('parcelaQuantidade') := rw_crawepr.qtpreemp;
    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'ANTES CONSULTAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => vr_obj_proposta.to_char,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato é o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Gravar dados log acionamento
    pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                         pr_cdagenci              => pr_cdagenci,          
                         pr_cdoperad              => pr_cdoperad,          
                         pr_cdorigem              => pr_cdorigem,          
                         pr_nrctrprp              => pr_nrctremp,          
                         pr_nrdconta              => pr_nrdconta,          
                         pr_cdcliente             => 1,
                         pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */      
                         pr_dsoperacao            => 'CONSULTA DA PROPOSTA DE ANALISE DE CREDITO',
                         pr_dsuriservico          => vr_recurso_este,       
                         pr_dsmetodo              => 'GET',      
                         pr_dtmvtolt              => pr_dtmvtolt,       
                         pr_cdstatus_http         => vr_response.status_code,
                         pr_dsconteudo_requisicao => vr_obj_proposta.to_char,
                         pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                     ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                     ',"Content":'||vr_response.content||'}',
                         pr_flgreenvia            => 0,
                         pr_nrreenvio             => 0,
                         pr_tpconteudo            => 1,
                         pr_tpproduto             => 0,
                         pr_idacionamento         => vr_idacionamento,
                         pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      vr_dscritic := 'Não foi possivel consultar informações de Analise de Credito, '||
                     'favor entrar em contato com a equipe responsavel.(Cod:'||vr_response.status_code||')';    
      RAISE vr_exc_erro;
    END IF;
      
    ---- Estrair dados retorno    
    vr_obj_retorno := json(vr_response.content);
    IF vr_obj_retorno.exist('numero') THEN
      vr_nrctremp_ret := vr_obj_retorno.get('numero').to_char();
    END IF;
    -- Situação da proposta 
    -- (0-Aguardando Analise, 1 -Agendado, 2 - Em Análise, 3 - Aprovada, 4 - Não Aprovada, 5-Efetivada, 6 - Refazer,
    --  7 - Aguardando Alienação/Gravame, 8 - Cancelada, 9 - Entregue PA, 10 - Aguardando Informação, 11 - Encerrada por Reanálise, 
    -- 12 - Agendado Alienação/Gravame, 13 - Registrando Alienação/Gravame, 14 - Aguardando Informação Alienação/Gravame, 
    -- 15 - Aguardando Análise Superior, 16 - Agendado Análise Superior, 17 - Em Análise Superior, 18 - Aprovada condicionalmente)
    IF vr_obj_retorno.exist('situacao') THEN
      vr_cdsitest   := vr_obj_retorno.get('situacao').to_char();
    END IF;
    
    --> Código do segmento de produto de crédito 
    -- (0 – CDC Diversos, 1 – CDC Veículos, 2 – Empréstimos/Financiamentos, 
    -- 3 – Desconto Cheques, 4 – Desconto Títulos, 5 – Cartão de Crédito, 6 – Limite de Crédito) 
    IF vr_obj_retorno.exist('produtoCreditoSegmentoCodigo') THEN
      vr_cdsegpro_ret := vr_obj_retorno.get('produtoCreditoSegmentoCodigo').to_char();    
    END IF;
    IF vr_obj_retorno.exist('linhaCreditoCodigo') THEN
      vr_cdlcremp_ret := vr_obj_retorno.get('linhaCreditoCodigo').to_char();    
    END IF;
    IF vr_obj_retorno.exist('finalidadeCodigo') THEN
      vr_cdfinemp_ret := vr_obj_retorno.get('finalidadeCodigo').to_char();    
    END IF;
    -- Tipo de Produto (PP ou TR)    
    IF vr_obj_retorno.exist('tipoProduto') THEN
      vr_cdtpprod_ret := vr_obj_retorno.get('tipoProduto').to_char();    
    END IF;
    IF vr_obj_retorno.exist('contratoNumero') AND 
       upper(vr_obj_retorno.get('contratoNumero').to_char()) <> 'NULL' THEN
      vr_nrctremp_ret2:= vr_obj_retorno.get('contratoNumero').to_char();        
    END IF;

    --> Status da Análise (0 - Aguardando Analise, 1 - Em Analise, 2 - Aprovada, 
    --                     3 - Não Aprovada, 4 - Refazer, 5 – Expirado, 6 – Aprovado Condicional) 
    IF vr_obj_retorno.exist('statusAnalise') THEN
      vr_cdstatan   := vr_obj_retorno.get('statusAnalise').to_char();
    END IF;
    
    --> Retornar valores
    pr_cdstatan := vr_cdstatan;
    pr_cdsitest := vr_cdsitest;
    

    
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                           pr_cdagenci              => pr_cdagenci,          
                           pr_cdoperad              => pr_cdoperad,          
                           pr_cdorigem              => pr_cdorigem,          
                           pr_nrctrprp              => pr_nrctremp,          
                           pr_nrdconta              => pr_nrdconta,          
                           pr_cdcliente             => 1,
                           pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                           pr_dsoperacao            => 'TERMINO CONSULTAR PROPOSTA',       
                           pr_dsuriservico          => NULL,       
                           pr_dsmetodo              => NULL,
                           pr_dtmvtolt              => pr_dtmvtolt,       
                           pr_cdstatus_http         => 0,
                           pr_dsconteudo_requisicao => null,
                           pr_dsresposta_requisicao => null,
                           pr_flgreenvia            => 0,
                           pr_nrreenvio             => 0,
                           pr_tpconteudo            => 1,
                           pr_tpproduto             => 0,
                           pr_idacionamento         => vr_idaciona,
                           pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar consulta da proposta de Analise de Credito: '||SQLERRM;
  END pc_consultar_proposta_est;

  PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cód. cooperativa
                                          ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo da Pessoa
                                          ,pr_cdfinemp IN crawepr.cdfinemp%TYPE  --> Cód. finalidade do credito
                                          ,pr_cdlcremp IN crawepr.cdlcremp%TYPE  --> Cód. linha de crédito
                                           ---- OUT ----                                          
                                          ,pr_inobriga OUT VARCHAR2              --> Indicador de obrigação de análisa automática ('S' - Sim / 'N' - Não)
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Cód. da crítica
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Desc. da crítica
  BEGIN                                          
  /* .........................................................................
    
    Programa : pc_obrigacao_analise_automatica
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Reinert
    Data     : Abril/2017                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar positivo caso a proposta deverá passar 
                por análise automática ou posteriormente manual na Esteira de Crédito
    Alteração : 
        
  ..........................................................................*/
    DECLARE
    
      -- Verificação de finalidade pré-aprovada
      CURSOR cr_crapfin IS
        SELECT 1
          FROM crapfin fin
              ,crappre pre
         WHERE pre.cdcooper = fin.cdcooper
           AND pre.cdfinemp = fin.cdfinemp
           AND fin.cdcooper = pr_cdcooper
           AND pre.inpessoa = pr_inpessoa
           AND fin.cdfinemp = pr_cdfinemp;
      vr_inpreapv NUMBER := 0;
    
      -- Cursor para verificar se a linha de crédito não é de Aprovação Automática
      CURSOR cr_craplcr IS
        SELECT lcr.flgdisap
              ,DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => pr_cdcooper
                                                 ,pr_cdfinemp => pr_cdfinemp),3,1,0) AS inlcrcdc
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
           AND lcr.cdlcremp = pr_cdlcremp;
      vr_flgdisap craplcr.flgdisap%TYPE;
      vr_inlcrcdc PLS_INTEGER;
           
    BEGIN 
      
      -- Verificação de finalidade pré-aprovada
      OPEN cr_crapfin;
      FETCH cr_crapfin
       INTO vr_inpreapv;
      CLOSE cr_crapfin; 
    
      -- Verificar se a linha de crédito não é de aprovação automática
      OPEN cr_craplcr;
      FETCH cr_craplcr 
       INTO vr_flgdisap,vr_inlcrcdc;
      CLOSE cr_craplcr;
      
      -- Se finalidade PRE-APROVADO
      -- OU linha dispensa aprovação 
      -- OU é linha CDC
      -- OU Esteira está em contingência 
      -- OU a Cooperativa não Obriga Análise Automática
      IF vr_inpreapv = 1
      OR vr_inlcrcdc = 1
      OR vr_flgdisap = 1 
      OR GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'CONTIGENCIA_ESTEIRA_IBRA') = 1 
      OR GENE0001.FN_PARAM_SISTEMA('CRED',pr_cdcooper,'ANALISE_OBRIG_MOTOR_CRED') = 0 THEN
        pr_inobriga := 'N';
      ELSE 
        pr_inobriga := 'S';
      END IF;
      
    EXCEPTION     
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de análise da proposta: '||SQLERRM;

    END;
  END pc_obrigacao_analise_automatic;	

  PROCEDURE pc_obrigacao_analise_autom_web(pr_cdfinemp IN crawepr.cdfinemp%TYPE  --> Finalidade de crédito
                                          ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo da Pessoa
                                          ,pr_cdlcremp IN crawepr.cdlcremp%TYPE  --> Cód. linha de crédito
                                           ---- OUT ----                                          
                                          ,pr_xmllog   IN  VARCHAR2                    -- XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                 -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                    -- Descrição da crítica
                                          ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS                -- Erros do processo
  BEGIN                                          
  /* .........................................................................
    
    Programa : pc_obrigacao_analise_autom_web
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Reinert
    Data     : Abril/2017                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar positivo caso a proposta deverá passar 
                por análise automática ou posteriormente manual na Esteira de Crédito
                para web
    Alteração : 
        
  ..........................................................................*/
    DECLARE
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic VARCHAR2(10000)       := NULL;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_inobriga VARCHAR2(1);
    
    BEGIN 
      
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
    
    pc_obrigacao_analise_automatic(pr_cdcooper => vr_cdcooper
                                  ,pr_inpessoa => pr_inpessoa
                                  ,pr_cdfinemp => pr_cdfinemp
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_inobriga => vr_inobriga
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;   
    
    -- Retorna OK para cadastro efetuado com sucesso
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><inobriga>'|| vr_inobriga || '</inobriga></Root>');   

    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar parametro ENVIA_EMAIL_COMITE: '||SQLERRM;
    END;
  END pc_obrigacao_analise_autom_web;   
  
  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
	PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                       ,pr_dsprotoc IN crawepr.dsprotoc%TYPE) IS
	  /* .........................................................................
    
    Programa : pc_solicita_retorno_analise
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Marcos Martini
    Data     : Agosto/2017                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo solicitar o retorno da analise no Motor
    Alteração : 
        
  ..........................................................................*/

  
		-- Tratamento de exceções
	  vr_exc_erro EXCEPTION;	
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);
	  vr_des_erro VARCHAR2(10);
	
	  -- Variáveis auxiliares
		vr_qtsegund crapprm.dsvlrprm%TYPE;
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
	  vr_nrdrowid ROWID;
		vr_dsresana VARCHAR2(100);
    vr_dssitret VARCHAR2(100);
		vr_indrisco VARCHAR2(100);
		vr_nrnotrat VARCHAR2(100);
		vr_nrinfcad VARCHAR2(100);
		vr_nrliquid VARCHAR2(100);
		vr_nrgarope VARCHAR2(100);
    vr_inopeatr VARCHAR2(100);
		vr_nrparlvr VARCHAR2(100);
		vr_nrperger VARCHAR2(100);
    vr_datscore VARCHAR2(100);
    vr_desscore VARCHAR2(100);
    vr_idfluata BOOLEAN;
    vr_xmllog   VARCHAR2(4000);
		vr_retxml   xmltype;
    vr_nmdcampo VARCHAR2(100);
	
	  vr_dsprotoc crawepr.dsprotoc%TYPE;
	
    -- Objeto json da proposta
    vr_obj_proposta json := json();
		vr_obj_retorno json := json();
    vr_obj_indicadores json := json();
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
	
	  -- Cursores
	  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Cooperativas com análise automática obrigatória
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
         AND flgativo = 1
         AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_CRED') = 1;
    
		-- Proposta sem retorno
		CURSOR cr_crawepr IS
			SELECT wpr.cdcooper
            ,wpr.nrdconta
            ,wpr.nrctremp 
            ,wpr.dsprotoc
            ,wpr.dtenvest
            ,wpr.hrenvest
            ,wpr.insitest
            ,wpr.cdagenci
            ,wpr.insitapr
            ,wpr.dtenvmot
            ,wpr.hrenvmot
            ,wpr.rowid
        FROM crawepr wpr
       WHERE wpr.cdcooper = pr_cdcooper 
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp
         AND wpr.dsprotoc = pr_dsprotoc
         AND wpr.insitest = 1-- Enviadas para Analise Automática
         /*FOR UPDATE*/;

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100);
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
              
	BEGIN
    
		-- Buscar todas as Coops com obrigatoriedade de Análise Automática    
    FOR rw_crapcop IN cr_crapcop LOOP
      
      -- Buscar o tempo máximo de espera em segundos pela analise do motor		
		  vr_qtsegund := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'TIME_RESP_MOTOR_IBRA');
    
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_dscritic:= gene0001.fn_busca_critica(1);
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      -- Desde que não estejamos com processo em execução ou o dia util
      IF rw_crapdat.inproces = 1 /*AND trunc(SYSDATE) = rw_crapdat.dtmvtolt */ THEN
        
        -- Buscar DEBUG ativo ou não
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                               pr_cdagenci              => 1,          
                               pr_cdoperad              => '1',          
                               pr_cdorigem              => 5,          
                               pr_nrctrprp              => 0,          
                               pr_nrdconta              => 0,          
                               pr_cdcliente             => 1,          
                               pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                               pr_dsoperacao            => 'INICIO SOLICITA RETORNOS',       
                               pr_dsuriservico          => NULL,       
                               pr_dsmetodo              => NULL,  
                               pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                               pr_cdstatus_http         => 0,
                               pr_dsconteudo_requisicao => null,
                               pr_dsresposta_requisicao => null,
                               pr_flgreenvia            => 0,
                               pr_nrreenvio             => 0,
                               pr_tpconteudo            => 1,
                               pr_tpproduto             => 0,
                               pr_idacionamento         => vr_idaciona,
                               pr_dscritic              => vr_dscritic);
          -- Sem tratamento de exceção para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;   
      
        -- Buscar todas as propostas enviadas para o motor e que ainda não tenham retorno
        FOR rw_crawepr IN cr_crawepr LOOP
          
          -- Capturar o protocolo do contrato para apresentar na crítica caso ocorra algum erro
          vr_dsprotoc := rw_crawepr.dsprotoc;
          -- Carregar parametros para a comunicacao com a esteira
          pc_carrega_param_ibra(pr_cdcooper      => rw_crawepr.cdcooper, -- Codigo da cooperativa
                                pr_nrdconta      => rw_crawepr.nrdconta, -- Numero da conta do cooperado
                                pr_nrctremp      => rw_crawepr.nrctremp, -- Numero da proposta de emprestimo
                                pr_tpenvest      => 'M',             -- Tipo de envio M - Motor
                                pr_host_esteira  => vr_host_esteira, -- Host da esteira
                                pr_recurso_este  => vr_recurso_este, -- URI da esteira
                                pr_dsdirlog      => vr_dsdirlog    , -- Diretorio de log dos arquivos 
                                pr_autori_este   => vr_autori_este  ,              -- Authorization 
                                pr_chave_aplica  => vr_chave_aplica ,              -- Chave de acesso
                                pr_dscritic      => vr_dscritic    );	    
          -- Se retornou crítica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF; 
    			
          vr_recurso_este := vr_recurso_este||'/instance/'||rw_crawepr.dsprotoc;

          vr_request.service_uri := vr_host_esteira;
          vr_request.api_route   := vr_recurso_este;
          vr_request.method      := 'GET';
          vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    	    
          vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
          vr_request.headers('Authorization') := vr_autori_este;
    			
          -- Se houver ApplicationKey
          IF vr_chave_aplica IS NOT NULL THEN 
            vr_request.headers('ApplicationKey') := vr_chave_aplica;
          END IF;
          
          -- Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                 pr_cdagenci              => rw_crawepr.cdagenci,          
                                 pr_cdoperad              => 'MOTOR',          
                                 pr_cdorigem              => 5,          
                                 pr_nrctrprp              => rw_crawepr.nrctremp,          
                                 pr_nrdconta              => rw_crawepr.nrdconta,         
                                 pr_cdcliente             => 1,       
                                 pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                 pr_dsoperacao            => 'ANTES SOLICITA RETORNOS',       
                                 pr_dsuriservico          => NULL,       
                                 pr_dsmetodo              => NULL,
                                 pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                 pr_cdstatus_http         => 0,
                                 pr_dsconteudo_requisicao => null,
                                 pr_dsresposta_requisicao => null,
                                 pr_flgreenvia            => 0,
                                 pr_nrreenvio             => 0,
                                 pr_tpconteudo            => 1,
                                 pr_tpproduto             => 0,
                                 pr_idacionamento         => vr_idaciona,
                                 pr_dscritic              => vr_dscritic);
            -- Sem tratamento de exceção para DEBUG                    
            --IF TRIM(vr_dscritic) IS NOT NULL THEN
            --  RAISE vr_exc_erro;
            --END IF;
          END IF;   
         
          -- Disparo do REQUEST
          json0001.pc_executa_ws_json(pr_request           => vr_request
                                     ,pr_response          => vr_response
                                     ,pr_diretorio_log     => vr_dsdirlog
                                     ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                     ,pr_dscritic          => vr_dscritic); 
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;	
          
          -- Iniciar status
          vr_dssitret := 'TEMPO ESGOTADO';
          
          -- HTTP 204 não tem conteúdo
          IF vr_response.status_code != 204 THEN
            -- Extrair dados de retorno
            vr_obj_retorno := json(vr_response.content);
            -- Resultado Analise Regra
            IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
              vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
              -- Montar a mensagem que será gravada no acionamento
              CASE lower(vr_dsresana)
                WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
                WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
                WHEN 'derivar'  THEN vr_dssitret := 'ANALISAR MANUAL';
                WHEN 'erro'     THEN vr_dssitret := 'ERRO';
                ELSE vr_dssitret := 'DESCONHECIDA';
              END CASE;         
            END IF;  
          END IF; 

          --> Gravar dados log acionamento
          pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                               pr_cdagenci              => rw_crawepr.cdagenci,          
                               pr_cdoperad              => 'MOTOR',
                               pr_cdorigem              => 5, /*Ayllos*/
                               pr_nrctrprp              => rw_crawepr.nrctremp,          
                               pr_nrdconta              => rw_crawepr.nrdconta,          
                               pr_cdcliente             => 1,         
                               pr_tpacionamento         => 2,  /* 1 - Envio, 2 – Retorno */      
                               pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DE CREDITO - '||vr_dssitret,
                               pr_dsuriservico          => vr_host_esteira||vr_recurso_este,       
                               pr_dsmetodo              => 'GET',
                               pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                               pr_cdstatus_http         => vr_response.status_code,
                               pr_dsconteudo_requisicao => vr_response.content,
                               pr_dsresposta_requisicao => null,
                               pr_dsprotocolo           => rw_crawepr.dsprotoc,
                               pr_flgreenvia            => 0,
                               pr_nrreenvio             => 0,
                               pr_tpconteudo            => 1,
                               pr_tpproduto             => 0,
                               pr_idacionamento         => vr_idacionamento,
                               pr_dscritic              => vr_dscritic);
    			                     
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_response.status_code NOT IN(200,204,429) THEN
            vr_dscritic := 'Não foi possivel consultar informações da Analise de Credito, '||
                           'favor entrar em contato com a equipe responsavel.  '|| 
                           '(Cod:'||vr_response.status_code||')';    
            RAISE vr_exc_erro;
          END IF;
    			
          -- Se recebemos o código diferente de 200 
          IF vr_response.status_code != 200 THEN
            -- Checar expiração
            IF trunc(SYSDATE) > rw_crawepr.dtenvmot 
            OR to_number(to_char(SYSDATE, 'sssss')) - rw_crawepr.hrenvmot > vr_qtsegund THEN
              BEGIN
                UPDATE crawepr epr
                   SET epr.insitest = 3 --> Analise Finalizada
                      ,epr.insitapr = 6 --> Erro na análise
                 WHERE epr.rowid = rw_crawepr.rowid;
              EXCEPTION
                WHEN OTHERS THEN 
                  vr_dscritic := 'Erro na expiracao da analise automatica: '||sqlerrm;
                  RAISE vr_exc_erro;	
              END;
    					
              -- Gerar informações do log
              GENE0001.pc_gera_log(pr_cdcooper => rw_crawepr.cdcooper
                                  ,pr_cdoperad => 'MOTOR'
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => 'AIMARO'
                                  ,pr_dstransa => 'Expiracao da Analise Automatica'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'ESTEIRA'
                                  ,pr_nrdconta => rw_crawepr.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);                         
    		      
              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitest'
                                       ,pr_dsdadant => rw_crawepr.insitest
                                       ,pr_dsdadatu => 3);
              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitapr'
                                       ,pr_dsdadant => rw_crawepr.insitapr
                                       ,pr_dsdadatu => 5);                                       
            END IF;
            
          ELSE
            
            -- Buscar IndicadoresCliente
            IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN
              
              vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));
            
              -- Nivel Risco Calculado -- 
              IF vr_obj_indicadores.exist('nivelRisco') THEN
                vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
              END IF;

              -- Rating Calculado -- 
              IF vr_obj_indicadores.exist('notaRating') THEN
                vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
              END IF;
      				
              -- Informação Cadastral -- 
              IF vr_obj_indicadores.exist('informacaoCadastral') THEN
                vr_nrinfcad := ltrim(rtrim(vr_obj_indicadores.get('informacaoCadastral').to_char(),'"'),'"');
              END IF;

              -- Liquidez -- 
              IF vr_obj_indicadores.exist('liquidez') THEN
                vr_nrliquid := ltrim(rtrim(vr_obj_indicadores.get('liquidez').to_char(),'"'),'"');
              END IF;

              -- Garantia -- 
              IF vr_obj_indicadores.exist('garantia') THEN
                vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
              END IF;
      		    
              -- Indicador de operação de crédito em atraso
              IF vr_obj_indicadores.exist('liquidOpCredAtraso') THEN
                vr_inopeatr := ltrim(rtrim(vr_obj_indicadores.get('liquidOpCredAtraso').to_char(),'"'),'"');
              END IF;

              -- Patrimônio Pessoal Livre -- 
              IF vr_obj_indicadores.exist('patrimonioPessoalLivre') THEN
                vr_nrparlvr := ltrim(rtrim(vr_obj_indicadores.get('patrimonioPessoalLivre').to_char(),'"'),'"');
              END IF;

              -- Percepção Geral Empresa -- 
              IF vr_obj_indicadores.exist('percepcaoGeralEmpresa') THEN
                vr_nrperger := ltrim(rtrim(vr_obj_indicadores.get('percepcaoGeralEmpresa').to_char(),'"'),'"');
              END IF;
              
              -- Score Boa Vista -- 
              IF vr_obj_indicadores.exist('descricaoScoreBVS') THEN
                vr_desscore := ltrim(rtrim(vr_obj_indicadores.get('descricaoScoreBVS').to_char(),'"'),'"');
              END IF;
              
              -- Data Score Boa Vista -- 
              IF vr_obj_indicadores.exist('dataScoreBVS') THEN
                vr_datscore := ltrim(rtrim(vr_obj_indicadores.get('dataScoreBVS').to_char(),'"'),'"');
              END IF;
              
              -- PJ637
              IF vr_obj_indicadores.exist('segueFluxoAtacado') THEN
                vr_idfluata := (CASE WHEN upper(ltrim(rtrim(vr_obj_indicadores.get('segueFluxoAtacado').to_char(),'"'),'"')) = 'TRUE' THEN TRUE ELSE FALSE END);
            END IF;  
              

            END IF;
            
            -- Se o DEBUG estiver habilitado
            IF vr_flgdebug = 'S' THEN
              --> Gravar dados log acionamento
              pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                   pr_cdagenci              => rw_crawepr.cdagenci,          
                                   pr_cdoperad              => 'MOTOR',          
                                   pr_cdorigem              => 5,          
                                   pr_nrctrprp              => rw_crawepr.nrctremp,          
                                   pr_nrdconta              => rw_crawepr.nrdconta,         
                                   pr_cdcliente             => 1,
                                   pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                   pr_dsoperacao            => 'ANTES PROCESSAMENTO RETORNO',       
                                   pr_dsuriservico          => NULL,       
                                   pr_dsmetodo              => NULL,
                                   pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                   pr_cdstatus_http         => 0,
                                   pr_dsconteudo_requisicao => null,
                                   pr_dsresposta_requisicao => null,
                                   pr_flgreenvia            => 0,
                                   pr_nrreenvio             => 0,
                                   pr_tpconteudo            => 1,
                                   pr_tpproduto             => 0,
                                   pr_idacionamento         => vr_idaciona,
                                   pr_dscritic              => vr_dscritic);
              -- Sem tratamento de exceção para DEBUG                    
              --IF TRIM(vr_dscritic) IS NOT NULL THEN
              --  RAISE vr_exc_erro;
              --END IF;
            END IF; 
    				
            -- Gravar o retorno e proceder com o restante do processo pós análise automática
            WEBS0001.pc_retorno_analise_proposta(pr_cdorigem => 5 /*Ayllos*/
                                                ,pr_dsprotoc => rw_crawepr.dsprotoc
                                                ,pr_nrtransa => vr_idacionamento
                                                ,pr_dsresana => vr_dsresana
                                                ,pr_indrisco => vr_indrisco
                                                ,pr_nrnotrat => vr_nrnotrat
                                                ,pr_nrinfcad => vr_nrinfcad
                                                ,pr_nrliquid => vr_nrliquid
                                                ,pr_nrgarope => vr_nrgarope
                                                ,pr_inopeatr => vr_inopeatr
                                                ,pr_nrparlvr => vr_nrparlvr
                                                ,pr_nrperger => vr_nrperger
                                                ,pr_desscore => vr_desscore
                                                ,pr_datscore => vr_datscore
                                                ,pr_dsrequis => vr_obj_proposta.to_char
                                                ,pr_namehost => vr_host_esteira||'/'||vr_recurso_este
                                                ,pr_idfluata => vr_idfluata -- PJ637
                                                -- OUT (Não trataremos retorno de erro pois é tudo efetuado na rotina chamada)
                                                ,pr_xmllog   => vr_xmllog 
                                                ,pr_cdcritic => vr_cdcritic 
                                                ,pr_dscritic => vr_dscritic 
                                                ,pr_retxml   => vr_retxml   
                                                ,pr_nmdcampo => vr_nmdcampo 
                                                ,pr_des_erro => vr_des_erro );
          END IF;
          -- Efetuar commit
          COMMIT;
        END LOOP;
        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                               pr_cdagenci              => 1,          
                               pr_cdoperad              => '1',          
                               pr_cdorigem              => 5,          
                               pr_nrctrprp              => 0,          
                               pr_nrdconta              => 0,          
                               pr_cdcliente             => 1,
                               pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                               pr_dsoperacao            => 'TERMINO SOLICITA RETORNOS',       
                               pr_dsuriservico          => NULL,       
                               pr_dsmetodo              => NULL,
                               pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                               pr_cdstatus_http         => 0,
                               pr_dsconteudo_requisicao => null,
                               pr_dsresposta_requisicao => null,
                               pr_flgreenvia            => 0,
                               pr_nrreenvio             => 0,
                               pr_tpconteudo            => 1,
                               pr_tpproduto             => 0,
                               pr_idacionamento         => vr_idaciona,
                               pr_dscritic              => vr_dscritic);
          -- Sem tratamento de exceção para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;
      END IF;  
      -- Gravação para liberação do registro
      COMMIT;
    END LOOP;  
	EXCEPTION
		WHEN vr_exc_erro THEN
			-- Desfazer alterações
      ROLLBACK;
      -- Gerar log
			btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

		WHEN OTHERS THEN
			-- Desfazer alterações
      ROLLBACK;
      -- Gerar log
			btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
	END pc_solicita_retorno_analise;
  --/ Rotina para gerar as notificações relacionadas as propostas de emprestimo
  PROCEDURE pc_notificacoes_prop(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Numero da conta
                                ,pr_nrctremp    IN crawepr.nrctremp%TYPE --> Numero do contrato
                                ,pr_cdcritic    OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2             --> Descricao da critica
                                 ) IS
  /* .............................................................................
   Programa: pc_notificacoes_prop
   Sistema : Rotinas referentes ao WebService de propostas
   Sigla   : CRED
   Autor   : Rafael Rocha (AmCom)
   Data    : Maio/19.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Criar notificações relacionadas as propostas de crédito
   --
   Observacao: --
   ..............................................................................*/
   --/
   CURSOR cr_wpr IS
     SELECT wpr.cdcooper,
            wpr.nrdconta,
            wpr.nrctremp,
            wpr.insitapr,
            wpr.cdorigem
       FROM crawepr wpr, crapsim sim
      WHERE wpr.cdcooper = pr_cdcooper
        AND wpr.nrdconta = pr_nrdconta
        AND wpr.nrctremp = pr_nrctremp
        AND wpr.cdcooper = sim.cdcooper
        AND wpr.nrdconta = sim.nrdconta
        AND wpr.nrsimula = sim.nrsimula
        -- AND wpr.cdorigem = 3
        AND wpr.nrsimula IS NOT NULL;
   --/
   rw_wpr cr_wpr%ROWTYPE;
   vr_des_reto_not VARCHAR2(10);
   --/            
	 BEGIN
     --/        
     OPEN cr_wpr;
     FETCH cr_wpr INTO rw_wpr;
     IF cr_wpr%FOUND THEN
     CLOSE cr_wpr;
      --/
      IF NVL(rw_wpr.insitapr,0) IN (1,2,3,4,5,6) THEN
       IF rw_wpr.cdorigem = 3 THEN
           empr0017.pc_cria_notificacao(pr_cdcooper => rw_wpr.cdcooper,
                                        pr_nrdconta => rw_wpr.nrdconta,
                                        pr_nrctremp => rw_wpr.nrctremp,
                                        pr_tporigem => 0, -- motor
                                        pr_des_reto => vr_des_reto_not);
       END IF;
       --/ envia email tambem quando erro e derivar
       -- A situação insitapr = 5(Derivar) aqui, é somente quando obtemos erro na este0001.pc_derivar_proposta_est
       -- ou seja, quando na tentativa de derivar ocorrer um erro ( exception da rotina ).
       -- Com este cenário, temos uma situação de ERRO onde o crawepr.insitapr fica = 5(Derivar).
       IF rw_wpr.insitapr IN (5,6) THEN
           empr0017.pc_email_esteira(pr_cdcooper => rw_wpr.cdcooper, 
                                     pr_nrdconta => rw_wpr.nrdconta, 
                                     pr_nrctremp => rw_wpr.nrctremp);
       END IF;
      END IF;                            
     ELSE
       CLOSE cr_wpr;
     END IF;
     
  END pc_notificacoes_prop;
  --
  --/ Rotina para agendar reenvio de propostas para analise de credito
  FUNCTION fn_agenda_reenvio_analise(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Numero da conta
                                    ,pr_nrctremp    IN crawepr.nrctremp%TYPE --> Numero do contrato
                                    ,pr_cdagenci    IN crawepr.cdagenci%TYPE DEFAULT NULL --> PA que irá acionar o motor
                                    ,pr_cdoperad    IN crawepr.cdoperad%TYPE DEFAULT NULL --> Operador que irá acionar o motor
                                     ) RETURN BOOLEAN IS 
  /* ............................................................................
   Programa: fn_agenda_reenvio_analise
   Sistema : Rotinas referentes ao WebService de propostas
   Sigla   : CRED
   Autor   : Rafael Rocha (AmCom)
   Data    : Julho/19.            Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Agendar reenvio de propostas para analise de credito. 

   Observacao: Há um Job que roda de tempo em tempo, fazendo leitura na tabela tbepr_reenvio_analise
               e programando reenvio da proposta para anaise de credito.
               Desta forma, a inserção/atualizacao do registro(conforme regra) na tabela tbepr_reenvio_analise 
               representa um agendamento de reenvio para analise de credito.
   Alteracoes:
   ..............................................................................*/
  --
  --/ Variavel recebe valor em minutos para a proxima tentativa de envio para analise
  vr_qt_minutos VARCHAR2(10) := nvl(gene0001.fn_param_sistema('CRED',0,'QT_MINUTOS_RETENTATIVAS'),5);
  --/
  vr_aplicou_dml NUMBER := 0;
  --/
  CURSOR cr_wepr(pr_cdcooper IN crawepr.cdcooper%TYPE,
                 pr_nrdconta IN crawepr.nrdconta%TYPE,
                 pr_nrctremp IN crawepr.nrctremp%TYPE) IS
   SELECT *
     FROM crawepr
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND nrctremp = pr_nrctremp;
   rw_wepr cr_wepr%ROWTYPE; 
  --/
  FUNCTION fn_valida_proposta(pr_cdcooper IN crawepr.cdcooper%TYPE,
                              pr_nrdconta IN crawepr.nrdconta%TYPE,
                              pr_nrctremp IN crawepr.nrctremp%TYPE) RETURN BOOLEAN IS
  vr_existe NUMBER(2);
  --/
  BEGIN
   --/
   SELECT COUNT(*)
     INTO vr_existe
     FROM crawepr w
    WHERE w.cdcooper = pr_cdcooper
      AND w.nrdconta = pr_nrdconta
      AND w.nrctremp = pr_nrctremp
      AND w.insitapr > 1 -- nao aprovada
      AND w.insitest > 0 -- algum retorno
      AND NOT EXISTS ( SELECT 1
                         FROM crapepr epr
                        WHERE epr.cdcooper = w.cdcooper
                          AND epr.nrdconta = w.nrdconta
                          AND epr.nrctremp = w.nrctremp)
      --/ somente se a proposta não tiver seu agendamento cancelado
      AND NOT EXISTS ( SELECT 1
                         FROM tbepr_reenvio_analise tra
                        WHERE tra.cdcooper = w.cdcooper
                          AND tra.nrdconta = w.nrdconta
                          AND tra.nrctremp = w.nrctremp
                          AND tra.insitrnv = 5 --cancelado
                      );
   --/
   RETURN vr_existe > 0;
  END fn_valida_proposta;
  --/
  FUNCTION fn_valida_reenvios_prop(pr_cdcooper IN crawepr.cdcooper%TYPE,
                                   pr_nrdconta IN crawepr.nrdconta%TYPE,
                                   pr_nrctremp IN crawepr.nrctremp%TYPE) RETURN BOOLEAN IS

   --/
   vr_qttentreenv crawepr.qttentreenv%TYPE;
   --/
  BEGIN
   --/
   SELECT nvl(wpr.qttentreenv,0)
     INTO vr_qttentreenv
     FROM crawepr wpr
    WHERE wpr.cdcooper = pr_cdcooper
      AND wpr.nrdconta = pr_nrdconta
      AND wpr.nrctremp = pr_nrctremp;

   --/ retorna possitivo somente quando a quantidade de tentativas nao atingiu
   --/ a quantidade parametrizada.    
   RETURN ( vr_qttentreenv < nvl(gene0001.fn_param_sistema('CRED',0,'QT_RETENTATIVAS_ANALISE'),3) );
    
  END fn_valida_reenvios_prop;
  --/  
  BEGIN
   --/
   IF fn_valida_proposta(pr_cdcooper,pr_nrdconta,pr_nrctremp)
   AND fn_valida_reenvios_prop(pr_cdcooper,pr_nrdconta,pr_nrctremp) THEN
    --/
    OPEN cr_wepr(pr_cdcooper,pr_nrdconta,pr_nrctremp);
    FETCH cr_wepr INTO rw_wepr;
    CLOSE cr_wepr;
   
    --/ As situações abaixo condicionadas tem que ser as mesmas
    -- na pc_notificacoes_prop na parte onde chama a empr0017.pc_email_esteira
    -- A situação 5(Derivar) aqui, é somente quando obtemos erro na este0001.pc_derivar_proposta_est
    -- ou seja, quando na tentativa de derivar ocorrer um erro ( exception da rotina ).
    -- Com este cenário, temos uma situação de erro onde o crawepr.insitapr fica = 5
    IF rw_wepr.insitapr IN (5,6) THEN
     --/
     UPDATE tbepr_reenvio_analise
        SET insitrnv = 0,
            dtagernv = trunc(sysdate),
            nrhragen = to_char((SYSDATE + vr_qt_minutos/1440),'sssss'),
            cdagenci = nvl(pr_cdagenci, cdagenci),
            cdoperad = nvl(pr_cdoperad, cdoperad)
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrctremp;
     --/
     vr_aplicou_dml := SQL%ROWCOUNT; 
     --/
     IF vr_aplicou_dml = 0 THEN
       --/
       BEGIN
        INSERT INTO tbepr_reenvio_analise
              (dtinclus,
               cdcooper,
               nrdconta,
               nrctremp,
               insitrnv,
               dtagernv,
               nrhragen,
               cdagenci,
               cdoperad)
            VALUES
              (trunc(sysdate),
               rw_wepr.cdcooper,
               rw_wepr.nrdconta,
               rw_wepr.nrctremp,
               0,
               trunc(sysdate),
               to_char((SYSDATE + vr_qt_minutos/1440),'sssss'), -- o cadastro no parametro é por minutos
               nvl(pr_cdagenci,0),
               nvl(pr_cdoperad, ''));
           --/
           vr_aplicou_dml := SQL%ROWCOUNT; 
       EXCEPTION WHEN OTHERS THEN
          NULL;
       END;
     END IF; -- vr_aplicou_dml = 0
    END IF; -- IF rw_wepr.insitapr IN (5,6)
   END IF; -- fn_valida_proposta, fn_valida_reenvios_prop
   --/
   IF vr_aplicou_dml > 0 THEN
     --/ libera registro para o job
     COMMIT;
   END IF;  
   --
   --/
   RETURN ( vr_aplicou_dml > 0 );
   
  END fn_agenda_reenvio_analise;
  --
  --/ Procedure exposta para o job reenviar propostas de credito, previamente agendadas, para de analise.
  PROCEDURE pc_job_reenvio_analise IS

  /* ..........................................................................

   Programa : pc_job_reenvio_analise
   Sistema  : Credito
   Sigla    : CRED
   Autor    : Rafael Rocha (Amcom)
   Data     : 07/2019.                   Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Procedimento para reenviar propostas de credito, previamente agendadas, para analise.

   Alteração : 17/07/2019 - Inclusão da chamada para o envio da SMS. (Douglas Pagel / AMcom).
  ...........................................................................*/
    
  vr_next_min  TIMESTAMP WITH TIME ZONE;
  ct_next_day  CONSTANT TIMESTAMP WITH TIME ZONE := TRUNC(SYSDATE + 1) + 8/24; 
  vr_timestamp TIMESTAMP WITH TIME ZONE;
  vr_dscritic  VARCHAR2(32000);
  vr_job_reenvio BOOLEAN := TRUE;
  --/
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  --/
  FUNCTION fn_get_cr_crapdat(pr_cdcooper IN crapcop.cdcooper%TYPE)
      RETURN BTCH0001.cr_crapdat%ROWTYPE IS
    --/
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    --/
    BEGIN
     --/
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     CLOSE BTCH0001.cr_crapdat;
     --/
     RETURN rw_crapdat;
    EXCEPTION WHEN OTHERS
      THEN
        RETURN rw_crapdat;
  END fn_get_cr_crapdat;
  --
  --/
  BEGIN
   --/
   FOR rw_coop IN (SELECT cop.cdcooper
                     FROM crapcop cop
                    WHERE cop.flgativo = 1
                    ORDER BY cop.cdcooper)
   LOOP
     -- verifica se metodo esta ativo para a cooperativa, caso nao ele vai para proxima coop.
     continue WHEN nvl(gene0001.fn_param_sistema('CRED',rw_coop.cdcooper,'METODO_REENVIO_ATIVO'),'0') = '0';
     --/
     rw_crapdat := fn_get_cr_crapdat(rw_coop.cdcooper);
     --/ tra.nrhragen,'sssss'
     FOR rw_crawepr IN (SELECT wpr.*, tra.rowid AS rowid_reenvio
                          FROM tbepr_reenvio_analise tra,
                               crawepr wpr
                         WHERE tra.cdcooper = rw_coop.cdcooper
                           AND TRUNC(tra.dtagernv) = TRUNC(SYSDATE)
                           AND gene0002.fn_converte_time_data(gene0002.fn_busca_entrada(1,to_char(tra.nrhragen),' ')) <= gene0002.fn_converte_time_data(gene0002.fn_busca_entrada(1,to_char(SYSDATE,'sssss'),' '))
                           AND nvl(wpr.qttentreenv,0) < nvl(GENE0001.fn_param_sistema('CRED', 0, 'QT_RETENTATIVAS_ANALISE'),0)
                           AND tra.insitrnv IN (0,4) -- (0) nao enviado ou (4) concluido
                           AND tra.cdcooper = wpr.cdcooper
                           AND tra.nrdconta = wpr.nrdconta
                           AND tra.nrctremp = wpr.nrctremp
                           AND wpr.insitapr <> 1
                           AND NOT EXISTS (SELECT 1
                                             FROM crapepr epr
                                            WHERE epr.cdcooper = wpr.cdcooper
                                              AND epr.nrdconta = wpr.nrdconta
                                              AND epr.nrctremp = wpr.nrctremp))
     LOOP
      --/
      vr_next_min := (SYSDATE + 2/1440);
      --/caso o sistema da cooperativa não esteja online (rw_crapdat.inproces <> 1), 
      -- programa o reenvio para o proximo dia as 08hs     
      vr_timestamp := (CASE WHEN rw_crapdat.inproces <> 1 THEN ct_next_day ELSE vr_next_min END);
      --
      --/ caso a cooperativa nao esteja online, agenda para dia seguinte
      IF vr_timestamp = ct_next_day THEN
        --/
        UPDATE tbepr_reenvio_analise tra
           SET tra.insitrnv = 1, -- agendado
               tra.dtagernv = trunc(ct_next_day)
         WHERE tra.rowid = rw_crawepr.rowid_reenvio;
         
      ELSE
        --/
        UPDATE tbepr_reenvio_analise tra
           SET tra.insitrnv = 1 -- agendado
         WHERE tra.rowid = rw_crawepr.rowid_reenvio;
      END IF;
      --/
      empr0017.pc_aciona_motor(pr_cdcooper => rw_crawepr.cdcooper,
                               pr_nrdconta => rw_crawepr.nrdconta,
                               pr_nrctremp => rw_crawepr.nrctremp,
                               pr_timestamp => vr_timestamp,
                               pr_job_reenvio => vr_job_reenvio);

      --/ libera o registro para proxima leitura do job
      COMMIT;
     END LOOP;
     --/
   END LOOP;
    
  END pc_job_reenvio_analise;  
  --
  --/  
  PROCEDURE pc_email_reenvio_analise(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR) IS           --> Descricao da critica

    CURSOR cr_coop IS
      SELECT cop.cdcooper, dat.dtmvtolt
        FROM crapcop cop, crapdat dat
       WHERE cop.cdcooper = pr_cdcooper
         AND cop.cdcooper = dat.cdcooper;
    rw_coop cr_coop%ROWTYPE;
 
    CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE) IS
      SELECT a.cdagenci
            ,w.cdcooper
            ,w.nrdconta
            ,w.nrctremp
            ,w.dtmvtolt
            ,w.vlemprst
        FROM crawepr w
            ,crapass a
            ,crapdat d
       WHERE w.cdcooper = pr_cdcooper
         AND nvl(w.qttentreenv, 0) >=
             GENE0001.fn_param_sistema('CRED', pr_cdcooper, 'QT_RETENTATIVAS_ANALISE')
         AND w.dtmvtolt BETWEEN (d.dtmvtolt - GENE0001.fn_param_sistema('CRED', pr_cdcooper, 'DIAS_REL_RETENTA_ANALISE')) AND d.dtmvtolt
         AND w.insitapr || w.insitest <> 13 -- aprovada com analise finalizada
         AND NOT EXISTS (SELECT 1
                           FROM crapepr epr
                          WHERE epr.cdcooper = w.cdcooper
                            AND epr.nrdconta = w.nrdconta
                            AND epr.nrctremp = w.nrctremp)
         AND a.cdcooper = w.cdcooper 
         AND a.nrdconta = w.nrdconta
         AND d.cdcooper = w.cdcooper
      ORDER BY w.dtmvtolt;

    vr_cdcritic      crapcri.cdcritic%TYPE; -- Codigo de critica
    vr_dscritic      VARCHAR2(2000); -- Descricao de critica
    vr_exc_saida     EXCEPTION; -- Tratamento de excecao parando a cadeia
                               
    PROCEDURE pc_gera_csv(pr_cdcooper in crawepr.cdcoopeR%TYPE) IS

      vr_cdprogra      crapprg.cdprogra%TYPE := 'JOB'; -- Codigo do presente programa
      vr_arquivo_txt   UTL_FILE.FILE_TYPE; -- Arquivo csv
      vr_nmdiretorio   VARCHAR2(50); -- Diretorio do csv
      vr_email_dest    VARCHAR2(1000); -- Email do destinatario csv
      vr_assunto_email VARCHAR(1000);
      vr_corpo_email   VARCHAR(4000);
      vr_qt_registros  INTEGER;
      vr_nmarquivo     VARCHAR2(100);

    BEGIN
    
      -- Buscar o diretorio /rl
      vr_nmdiretorio := GENE0001.fn_diretorio(pr_tpdireto => 'c',
                                              pr_cdcooper => pr_cdcooper);

      vr_nmarquivo := 'crps783.csv';
      vr_email_dest :=    GENE0001.fn_param_sistema('CRED', pr_cdcooper, 'EMAIL_RETENTA_ANALISE');   
      vr_assunto_email := GENE0001.fn_param_sistema('CRED', pr_cdcooper, 'ASS_REL_RETENTA_ANALISE'); 
      vr_corpo_email :=   GENE0001.fn_param_sistema('CRED', pr_cdcooper, 'MSG_REL_RETENTA_ANALISE');                     

      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdiretorio || '/rl', --> Diretório do arquivo
                               pr_nmarquiv => vr_nmarquivo, --> Nome do arquivo
                               pr_tipabert => 'W', --> Modo de abertura (R,W,A)
                               pr_utlfileh => vr_arquivo_txt, --> Handle do arquivo aberto
                               pr_des_erro => vr_dscritic); --> Retorno da critica

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      --
      -- Cabecalho do crrl579.csv
      GENE0001.pc_escr_linha_arquivo(vr_arquivo_txt,
                                     'Cooperativa;Conta;PA do Cooperado;Número da Proposta;Data da Proposta;Valor da Proposta');
      vr_qt_registros := 0;
      FOR rw_reenv IN cr_crawepr(pr_cdcooper) LOOP
        -- Escrever detalhe do .csv
        GENE0001.pc_escr_linha_arquivo(vr_arquivo_txt,
                                       rw_reenv.cdcooper || ';' ||
                                       gene0002.fn_mask_conta(rw_reenv.nrdconta) || ';' ||
                                       rw_reenv.cdagenci || ';' ||
                                       gene0002.fn_mask_contrato(rw_reenv.nrctremp) || ';' ||
                                       to_char(rw_reenv.dtmvtolt) || ';' ||
                                       to_char(rw_reenv.vlemprst,'fm99999g999g990d00') );
        vr_qt_registros := vr_qt_registros + 1;
      END LOOP;
      
      -- Fechar o arquivo crrl579.csv
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_txt);

      IF vr_email_dest IS NOT NULL AND vr_qt_registros > 0 THEN
        -- Converter o arquiovo para envio
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper,
                                     pr_nmarquiv => vr_nmdiretorio || '/rl/'||vr_nmarquivo,
                                     pr_nmarqenv => vr_nmarquivo,
                                     pr_des_erro => vr_dscritic);
                                     
        IF NOT vr_dscritic IS NULL THEN 
          RAISE vr_exc_saida;
        END IF;
                                     
        -- Enviar arquivo .csv por email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper,
                                   pr_cdprogra        => vr_cdprogra,
                                   pr_des_destino     => vr_email_dest,
                                   pr_des_assunto     => vr_assunto_email,
                                   pr_des_corpo       => vr_corpo_email,
                                   pr_des_anexo       => vr_nmdiretorio ||'/converte/'||vr_nmarquivo,
                                   pr_flg_remove_anex => 'N', --> Remover os anexos passados
                                   pr_flg_remete_coop => 'N', --> Se o envio será do e-mail da Cooperativa
                                   pr_flg_enviar      => 'S', --> Enviar o e-mail na hora
                                   pr_des_erro        => vr_dscritic);
                                     
        IF NOT vr_dscritic IS NULL THEN 
          RAISE vr_exc_saida;
        END IF;   
      END IF;
    END pc_gera_csv;

  BEGIN
    FOR rw_coop IN cr_coop LOOP
      pc_gera_csv(rw_coop.cdcooper);
    END LOOP;
    
  EXCEPTION 
    WHEN vr_exc_saida THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, 
                                                 pr_dscritic => vr_dscritic);
      
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na rotina pc_email_reenvio_analise: ' || sqlerrm;
      
  END pc_email_reenvio_analise;
  --/
  PROCEDURE pc_set_job_reenvioanalise IS    
  BEGIN
    vg_job_reenvio_analise := TRUE;
  END pc_set_job_reenvioanalise;
  --/
  FUNCTION fn_get_job_reenvioanalise RETURN BOOLEAN IS
  BEGIN
     RETURN vg_job_reenvio_analise;
  END fn_get_job_reenvioanalise;

	
END ESTE0001;
/
