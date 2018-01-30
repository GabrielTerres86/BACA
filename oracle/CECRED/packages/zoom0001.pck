CREATE OR REPLACE PACKAGE CECRED.ZOOM0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : ZOOM0001                         antigo: /sistema/generico/procedures/b1wgen0059.p
    Sistema  : Rotinas genericas referente a zoom de pesquisa
    Sigla    : ZOOM
    Autor    : Adriano Marchi
    Data     : 30/11/2015.                   Ultima atualizacao: 04/08/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Buscar os dados p/ telas de pesquisas ou zoom's

   Alteracoes: 24/02/2016 - Criação das rotinas respectivas a conversão da tela CADCCO/ATURAT
   				            (Jonathan RJKAM).
  
               12/06/2016 - Criação da rotina pc_busca_craplrt em vritude da conversão da tela LROTAT
                            (Andrei - RKAM).
                            
               22/02/2017 - Conversão da rotina busca-gncdnto (Adriano - SD 614408).
               04/08/2017 - Ajuste para inclusao do parametros flserasa (Adriano).
                                           
               08/05/2017 - Ajustes para incluir rotinas de pesquisa de dominios e descrição de associado
                            (Jonata - RKAM).
                                           
  ---------------------------------------------------------------------------------------------------------------*?
  
  /* Tabela para guardar os operadores */
  TYPE typ_operadores IS RECORD 
    (cdcooper crapope.cdcooper%TYPE
    ,cdoperad crapope.cdoperad%TYPE
    ,nmoperad crapope.nmoperad%TYPE
    ,cdagenci crapope.cdagenci%TYPE
    ,vlpagchq crapope.vlpagchq%TYPE);
    
  --Tabela para guardar os operadores  
  TYPE typ_tab_operadores IS TABLE OF typ_operadores INDEX BY PLS_INTEGER;
  
  /* Tabela para guardar os historicos */
  TYPE typ_historicos IS RECORD 
    (cdhistor craphis.cdhistor%TYPE
    ,dshistor craphis.dshistor%TYPE);
    
  --Tabela para guardar os historicos  
  TYPE typ_tab_historicos IS TABLE OF typ_historicos INDEX BY PLS_INTEGER;
  
  /* Tabela para guardar os bancos caixa */
  TYPE typ_banco_caixa IS RECORD 
    (cdbccxlt crapbcl.cdbccxlt%TYPE
    ,nmextbcc crapbcl.nmextbcc%TYPE);
    
  --Tabela para guardar os bancos caixa  
  TYPE typ_tab_banco_caixa IS TABLE OF typ_banco_caixa INDEX BY PLS_INTEGER;

  /* Tabela para guardar os parametro de cobranca */
  TYPE typ_cobranca IS RECORD 
    (nrconven crapcco.nrconven%TYPE
    ,nrdctabb crapcco.nrdctabb%TYPE
    ,cddbanco crapcco.cddbanco%TYPE
    ,situacao VARCHAR(10)
    ,dsorgarq crapcco.dsorgarq%TYPE);
    
  --Tabela para guardar os parametro de cobranca 
  TYPE typ_tab_cobranca IS TABLE OF typ_cobranca INDEX BY PLS_INTEGER;
  
  --Tabela para guardar os bancos
  TYPE typ_tab_bancos IS TABLE OF crapban%ROWTYPE INDEX BY PLS_INTEGER;

  /* Tabela para guardar as linhas de crédito */
  TYPE typ_linhas IS RECORD 
    (cdlcremp craplcr.cdlcremp%TYPE
    ,dsclremp craplcr.dslcremp%TYPE
    ,flgstlcr VARCHAR2(40)
    ,tpctrato craplcr.tpctrato%TYPE
    ,txbaspre craplcr.txbaspre%TYPE
    ,nrfimpre craplcr.nrfimpre%TYPE
    ,tpgarant craplcr.tpctrato%TYPE
    ,dsgarant VARCHAR2(100));
       
   /* Tabela para guardar as linhas de crédito */
  TYPE typ_tab_linhas IS TABLE OF typ_linhas INDEX BY PLS_INTEGER;
  
  /* Tabela para guardar as finalidades de empréstimos */
  TYPE typ_finalidades_empr IS RECORD 
    (cdfinemp crapfin.cdfinemp%TYPE
    ,dsfinemp crapfin.dsfinemp%TYPE
    ,flgstfin crapfin.flgstfin%TYPE
    ,tpfinali crapfin.tpfinali%TYPE);
       
   /* Tabela para guardar as finalidades de empréstimos */
  TYPE typ_tab_finalidades_empr IS TABLE OF typ_finalidades_empr INDEX BY PLS_INTEGER;
              
  /* Tabela para guardar as naturezas de ocupação */
  TYPE typ_natureza_ocupacao IS RECORD 
    (cdnatocp gncdnto.cdnatocp%TYPE
    ,dsnatocp gncdnto.dsnatocp%TYPE
    ,rsnatocp gncdnto.rsnatocp%TYPE);
       
  /* Tabela para guardar as naturezas de ocupação */
  TYPE typ_tab_natureza_ocupacao IS TABLE OF typ_natureza_ocupacao INDEX BY PLS_INTEGER;

  /* Tabela para guardar as ocupações */
  TYPE typ_ocupacoes IS RECORD 
    (cdocupa  gncdocp.cdocupa%TYPE
    ,dsdocupa gncdocp.dsdocupa%TYPE
    ,cdnatocp gncdocp.cdnatocp%TYPE
    ,rsdocupa gncdocp.rsdocupa%TYPE);
    
  /* Tabela para guardar as ocupações */
  TYPE typ_tab_ocupacoes IS TABLE OF typ_ocupacoes INDEX BY PLS_INTEGER;  
              
  /* Procedure para encontrar operadores */
  PROCEDURE pc_busca_operadores_web(pr_cdoperad IN crapope.cdoperad%TYPE   --Operador                                   
                                   ,pr_nmoperad IN crapope.nmoperad%TYPE   --Nome do operador
                                   ,pr_nrregist IN NUMBER                  --Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                  --Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                   
  /* Rotina para encontrar os operadores */
  PROCEDURE pc_busca_operadores_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                   ,pr_nriniseq IN INTEGER  -->Quantidade inicial
                                   ,pr_nrregist IN INTEGER  -->Quantidade registros
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro    
								   
  PROCEDURE pc_busca_bancos_web (pr_cdbccxlt  IN crapban.cdbccxlt%TYPE
                                ,pr_cddbanco  IN crapban.cdbccxlt%TYPE
                                ,pr_nmextbcc  IN crapban.nmextbcc%TYPE
                                ,pr_nrregist  IN INTEGER          --> Quantidade de registros                    
                                ,pr_nriniseq  IN INTEGER          --> Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) ;           --Saida OK/NOK
     
  --Rotina para buscar os bancos                            
  PROCEDURE pc_busca_bancos_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                               ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                               ,pr_nrregist IN INTEGER                              
                               ,pr_nriniseq IN INTEGER  
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                               ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro  
    
  --Rotina para buscar os convenios                           
  PROCEDURE pc_busca_param_cnv_cob(pr_nrconven IN crapcco.nrconven%TYPE        --Convenio
                                  ,pr_nriniseq IN NUMBER                  --Quantidade inicial
                                  ,pr_nrregist IN NUMBER                  --Qunatidade de registros
                                  ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) ;           --Saida OK/NOK 


  --Rotina para buscar os históricos 
  PROCEDURE pc_busca_historico_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                   ,pr_nrdcaixa IN INTEGER               --Código caixa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                   ,pr_cdhistor IN craphis.cdhistor%TYPE --> cd historico
                                   ,pr_dshistor IN craphis.dshistor%TYPE --> ds historico
                                   ,pr_flglanca IN INTEGER --> flag se lancamento
                                   ,pr_inautori IN INTEGER -->                                    
                                   ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro  
  
  --Rotina para buscar os históricos 
  PROCEDURE pc_busca_historico_web(pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdtarhis  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhiscxa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisnet  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhistaa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisblq  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                                  ,pr_flglanca  IN INTEGER --> flag se lancamento
                                  ,pr_inautori  IN INTEGER 
                                  ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                  ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                  ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) ;           --Saida OK/NOK 	
                                  
  --Rotina para buscar os banco/caixa
  PROCEDURE pc_busca_banco_caixa_web(pr_cdbccxlt  IN crapbcl.cdbccxlt%TYPE -- Código do banco
                                    ,pr_nmextbcc  IN crapbcl.nmextbcc%TYPE -- Nome do Banco
                                    ,pr_nmbcolot  IN crapban.nmextbcc%TYPE
                                    ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                    ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                    ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK 
                                    
  --Rotina para buscar os banco/caixa 
  PROCEDURE pc_busca_banco_caixa_car( pr_cdcooper IN crapcop.cdcooper%type --> Codigo Cooperativa  
                                     ,pr_nrdcaixa IN INTEGER               --> Código caixa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE --> Código do banco
                                     ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE --> Nome do banco
                                     ,pr_nrregist IN INTEGER               --> Quantidade de registros                            
                                     ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro                                                                       							                                  
                                   
  PROCEDURE pc_busca_craplrt(pr_cddlinha  IN craplrt.cddlinha%TYPE -- Codigo da linha
                            ,pr_dsdlinha  IN craplrt.dsdlinha%TYPE -- Descricao da linha
                            ,pr_tpdlinha  IN craplrt.tpdlinha%TYPE -- Tipo da linha
                            ,pr_flgstlcr  IN craplrt.flgstlcr%TYPE -- Ativo/Inativo
                            ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                            ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                            ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                            ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK                                                                                                           							                                  
  
  PROCEDURE pc_busca_linhas_credito_web(pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- cd historico
                                       ,pr_dslcremp  IN craplcr.dslcremp%TYPE -- cd historico
                                       ,pr_cdfinemp  IN craplch.cdfinemp%TYPE -- cd historico
                                       ,pr_flgstlcr  IN craplcr.flgstlcr%TYPE -- cd historico
                                       ,pr_cdmodali  IN craplcr.cdmodali%TYPE -- cd historico
                                       ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                       ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                       ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK
                                       
  PROCEDURE pc_busca_linhas_credito_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                        ,pr_nrdcaixa IN INTEGER               --Código caixa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                        ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- cd historico
                                        ,pr_dslcremp  IN craplcr.dslcremp%TYPE -- cd historico
                                        ,pr_cdfinemp  IN craplch.cdfinemp%TYPE -- cd historico
                                        ,pr_flgstlcr  IN craplcr.flgstlcr%TYPE -- cd historico
                                        ,pr_cdmodali  IN craplcr.cdmodali%TYPE -- cd historico
                                        ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                        ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro                                         
   
  PROCEDURE pc_busca_finalidades_empr_web(pr_cdfinemp  IN crapfin.cdfinemp%TYPE -- Código da finalidade
                                         ,pr_dsfinemp  IN crapfin.dsfinemp%TYPE -- Descrição da finalidade
                                         ,pr_flgstfin  IN crapfin.flgstfin%TYPE -- Situação da finalidade: 0 - Não ativas / 1 - Aitvas / 3 - Todas
                                         ,pr_lstipfin  IN VARCHAR2 DEFAULT NULL -- lista com os tipo de finalidade ou nulo para todas
                                         ,pr_cdlcrhab  IN craplch.cdlcrhab%TYPE -- Codigo da linha de credito habilitada
                                         ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                         ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                         ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                         ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK
                                         
  PROCEDURE pc_busca_finalidades_empr_car( pr_cdcooper IN crapreg.cdcooper%type -- Codigo Cooperativa  
                                          ,pr_nrdcaixa IN INTEGER               -- Código caixa
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE -- Código da agência
                                          ,pr_cdfinemp IN crapfin.cdfinemp%TYPE -- Código da finalidade
                                          ,pr_dsfinemp IN crapfin.dsfinemp%TYPE -- Descrição da finalidade
                                          ,pr_flgstfin IN crapfin.flgstfin%TYPE -- Situação da finalidade: 0 - Não ativas / 1 - Aitvas / 3 - Todas
                                          ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                          ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                          ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                          ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2);          -- Descricao Erro                                           
                                                                                                        
  PROCEDURE pc_busca_gncdnto_car( pr_cdnatocp IN gncdnto.cdnatocp%TYPE -- Código da finalidade
                                 ,pr_rsnatocp IN gncdnto.rsnatocp%TYPE -- Descrição da finalidade
                                 ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                 ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                 ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2);          -- Descricao Erro  
                                 
  PROCEDURE pc_busca_gncdnto_web(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                                ,pr_cdnatopc  IN gncdnto.cdnatocp%TYPE --Código da natureza
                                ,pr_rsnatocp  IN gncdnto.dsnatocp%TYPE -- Descrição da natureza
                                ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);          --Saida OK/NOK  
                                
  PROCEDURE pc_busca_gncdocp_web(pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                                ,pr_cdocpttl  IN gncdnto.cdnatocp%TYPE --Código da natureza
                                ,pr_cdocpcje  IN gncdnto.cdnatocp%TYPE --Código da natureza
                                ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                ,pr_dsocpttl  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);          --Saida OK/NOK      
                                
  PROCEDURE pc_busca_gncdocp_car( pr_cdocupa  IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                                 ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                 ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                 ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                 ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2);          -- Descricao Erro                                                                                          
                                                                                                                                         
  PROCEDURE pc_busca_operacao_conta(pr_cdoperacao IN tbcc_operacao.cdoperacao%TYPE --> Codigo da operacao
                                   ,pr_dsoperacao IN tbcc_operacao.dsoperacao%TYPE --> Descricao da operacao
                                   ,pr_nrregist   IN INTEGER                       --> Quantidade de registros                            
                                   ,pr_nriniseq   IN INTEGER                       --> Qunatidade inicial
                                   ,pr_xmllog     IN VARCHAR2                      --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER                   --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2                      --> Descricao da critica
                                   ,pr_retxml    IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2                      --> Nome do Campo
                            	     ,pr_des_erro  OUT VARCHAR2);                   --> Saida OK/NOK
                                                                                                        
  PROCEDURE pc_busca_dominios(pr_idtipo_dominio     IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- código do dominio
                             ,pr_dstipo_dominio     IN tbrisco_dominio_tipo.dstipo_dominio%TYPE -- descrição do dominio
                             ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                             ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                             ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                             ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                             ,pr_des_erro  OUT VARCHAR2);
  
  PROCEDURE pc_busca_descricao_dominios(pr_idtipo_dominio   IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- Tipo do dominio
                                       ,pr_idgarantia       IN VARCHAR2 --Código da garantia
                                       ,pr_idmodalidade     IN VARCHAR2 --Código da modalidade
                                       ,pr_idconta_cosif    IN VARCHAR2 --Código da conta cosif
                                       ,pr_idorigem_recurso IN VARCHAR2 --Código da origem recurso
                                       ,pr_idindexador      IN VARCHAR2 --Código da indexador
                                       ,pr_idvariacao_cambial IN VARCHAR2 --Código da variacao cambial
                                       ,pr_idnat_operacao     IN VARCHAR2 --Código da natureza operacao
                                       ,pr_idcaract_especial  IN VARCHAR2 --Código da caracteritica especial
                                       ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2);
   
  PROCEDURE pc_busca_descricao_associados(pr_cdcooper   IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                         ,pr_nrdconta   IN crapass.nrdconta%TYPE -- Número da contaca especial
                                         ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                         ,pr_des_erro  OUT VARCHAR2);
                                         
  PROCEDURE pc_busca_conta_cosif(pr_idgarantia     IN VARCHAR2       -->Código da garantia
                                ,pr_idtipo_dominio IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- código do dominio
                                ,pr_dstipo_dominio IN tbrisco_dominio_tipo.dstipo_dominio%TYPE -- descrição do dominio
                                ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2);                                         
                                                                                                                   
  PROCEDURE pc_busca_nacionalidades(pr_cdnacion  IN crapnac.cdnacion%TYPE -- código da nacionalidade
                                   ,pr_dsnacion  IN crapnac.dsnacion%TYPE -- descrição da nacionalidade
                                   ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                                   ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                                   ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                   ,pr_des_erro  OUT VARCHAR2);     
                                   
  PROCEDURE pc_consulta_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                       ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                       ,pr_cdoedptl          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedptl          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoedttl          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedttl          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoeddoc          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoeddoc          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoedcje          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedcje          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                       ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                       ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2);  
                                     
  PROCEDURE pc_busca_cnae(pr_cdcnae    IN tbgen_cnae.cdcnae%TYPE -- código CNAE
                         ,pr_dscnae    IN tbgen_cnae.dscnae%TYPE -- descrição CNAE
                         ,pr_flserasa  IN tbgen_cnae.flserasa%TYPE --Negativar SERASA
                         ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                         ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                         ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                         ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                         ,pr_des_erro  OUT VARCHAR2);                                                                                    
                                                                                                                   
END ZOOM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ZOOM0001 AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: ZOOM0001                          antigo: /sistema/generico/procedures/b1wgen0059.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano Marchi
   Data    : 30/11/2015                       Ultima atualizacao: 04/08/2017

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Buscar os dados p/ telas de pesquisas ou zoom's

   Alteracoes: 24/02/2016 - Criação das rotinas respectivas a conversão da tela CADCCO/ATURAT
   				                 (Jonathan RJKAM).                                         
                           
               12/06/2016 - Criação da rotina pc_busca_craplrt em vritude da conversão da tela LROTAT
                            (Andrei - RKAM).
                                                    
               12/06/2016 - Criação das rotinas para consulta de linhas de crédito e finalidades de empréstimo
                            (Andrei - RKAM).
                                                 
               07/02/2017 - Criacao da pc_busca_operacao_conta. (Jaison/Oscar - PRJ335)
               22/02/2017 - Conversão da rotina busca-gncdnto (Adriano - SD 614408).
                                                   
			   08/03/2017 - Ajuste para enviar corretamente o campo cdocupa no xml de retorno
			                (Adriano - SD 614408).                               
               
               08/05/2017 - Ajustes para incluir rotinas de pesquisa de dominios e descrição de associado
                            (Jonata - RKAM).        
                                                    
			   04/08/2017 - Ajuste para inclusao do parametros flserasa (Adriano).       
                                                    
  ---------------------------------------------------------------------------------------------------------------*/
  
  /*PROCEDURE RESPONSAVEL POR ENCONTRAR OPERADORES*/
  PROCEDURE pc_busca_operadores(pr_cdcooper IN crapcop.cdcooper%TYPE --Cooperativa do operador                               
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdoperad IN crapope.cdoperad%TYPE --Código do Operador
                               ,pr_nmoperad IN crapope.nmoperad%TYPE --Nome do operador
                               ,pr_nrregist IN INTEGER               --Número de registros
                               ,pr_nriniseq IN INTEGER               --Número sequencial
                               ,pr_qtregist OUT INTEGER              --Quantidade de registros
                               ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                               ,pr_tab_operadores OUT ZOOM0001.typ_tab_operadores --Tabela w-inform
                               ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                               ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
                                                
     
    /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_operador                            antiga: b1wgen0059.p busca-crapope
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Novembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para Buscar Informacoes operadores
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/
    CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE
                     ,pr_nmoperad IN crapope.nmoperad%TYPE) IS                     
    SELECT ope.cdcooper
          ,ope.cdoperad
          ,ope.cdagenci
          ,ope.nmoperad
          ,ope.vlpagchq
     FROM crapope ope
    WHERE (TRIM(pr_cdoperad) IS NULL 
           OR UPPER(ope.cdoperad) = UPPER(pr_cdoperad))
       AND ope.cdcooper = pr_cdcooper       
       AND (TRIM(pr_nmoperad) IS NULL
            OR UPPER(ope.nmoperad) LIKE '%' || UPPER(pr_nmoperad) || '%');
    rw_crapope cr_crapope%ROWTYPE;
    
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_index    PLS_INTEGER;
      
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
      
    BEGIN
      --Limpar tabelas auxiliares
      pr_tab_operadores.DELETE;
        
      --Inicializar Variavel
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      --Selecionar Titular
      FOR rw_crapope IN cr_crapope(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmoperad => pr_nmoperad) LOOP
                                   
        --Indice para a temp-table
        vr_index:= pr_tab_operadores.COUNT + 1;
                                    
        --Incrementar Quantidade Registros do Parametro
        pr_qtregist:= nvl(pr_qtregist,0) + 1;
          
        /* controles da paginacao */
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
          
        --Numero Registros
        IF vr_nrregist > 0 THEN 
                               
          --Verificar se já existe na temp-table                             
          IF NOT pr_tab_operadores.EXISTS(vr_index) THEN
              
            --Popular dados na tabela memoria
            pr_tab_operadores(vr_index).cdcooper:= rw_crapope.cdcooper;
            pr_tab_operadores(vr_index).cdoperad:= rw_crapope.cdoperad;
            pr_tab_operadores(vr_index).cdagenci:= rw_crapope.cdagenci;
            pr_tab_operadores(vr_index).nmoperad:= rw_crapope.nmoperad;
            pr_tab_operadores(vr_index).vlpagchq:= rw_crapope.vlpagchq;
              
          END IF;  
        END IF;
          
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
      END LOOP;  

      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                           
       
      IF pr_tab_operadores.COUNT() = 0 THEN
      
        vr_dscritic := 'Nenhum operador foi encontrado.';
        RAISE vr_exc_erro;
        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
          
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
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
  END pc_busca_operadores;

  /* Procedure para encontrar operadores */
  PROCEDURE pc_busca_operadores_web(pr_cdoperad IN crapope.cdoperad%TYPE   --Operador                                   
                                   ,pr_nmoperad IN crapope.nmoperad%TYPE   --Nome do operador
                                   ,pr_nrregist IN NUMBER                  --Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                  --Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
 
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_busca_opreradores_web              Antigo: busca-crapope
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Novembro/2015                           Ultima atualizacao: 26/02/2016 
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para buscar os operadores. Apenas chama a rotina pc_busca_operadores.
  
    Alterações : 26/02/2016 - Ajuste para contabilizar os registros encontrados corretamente
                             (Jonathan - RKAM)
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_operadores ZOOM0001.typ_tab_operadores;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_operadores.DELETE;
      
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
      
      pc_busca_operadores(pr_cdcooper => vr_cdcooper
                         ,pr_nrdcaixa => vr_nrdcaixa
                         ,pr_cdagenci => vr_cdagenci                        
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nmoperad => pr_nmoperad
                         ,pr_nrregist => pr_nrregist
                         ,pr_nriniseq => pr_nriniseq
                         ,pr_qtregist => vr_qtregist
                         ,pr_nmdcampo => pr_nmdcampo
                         ,pr_tab_operadores => vr_tab_operadores 
                         ,pr_tab_erro => vr_tab_erro
                         ,pr_des_erro => vr_des_reto);
                               
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_web.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Operadores>');
      
      --Buscar Primeiro beneficiario
      vr_index:= vr_tab_operadores.FIRST;
        
      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<inf>'||
                                                        '<cdcooper>' || vr_tab_operadores(vr_index).cdcooper ||'</cdcooper>'||
                                                        '<cdoperad>' || vr_tab_operadores(vr_index).cdoperad ||'</cdoperad>'||
                                                        '<cdagenci>' || vr_tab_operadores(vr_index).cdagenci ||'</cdagenci>'||
                                                        '<nmoperad>' || vr_tab_operadores(vr_index).nmoperad ||'</nmoperad>'||
                                                        '<vlpagchq>' || vr_tab_operadores(vr_index).vlpagchq ||'</vlpagchq>'||                                                          
                                                     '</inf>');         
                   
        --Proximo Registro
        vr_index:= vr_tab_operadores.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Operadores></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);

      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Operadores'        --> Nome da TAG XML
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
        pr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_operadores_web;  

  /* Rotina para encontrar os operadores */
  PROCEDURE pc_busca_operadores_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                   ,pr_nriniseq IN INTEGER  -->Quantidade inicial
                                   ,pr_nrregist IN INTEGER  -->Quantidade registros
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_operadores_car            Antiga: busca-crapope
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Adrinao Marchi (CECRED)
    Data    : 30/11/2015                          Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Realizar a busca de operadores

    Alteracoes:                               
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_operadores ZOOM0001.typ_tab_operadores;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_operadores.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
       
      --Busca operadores                                                         
      pc_busca_operadores(pr_cdcooper => pr_cdcooper
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_cdagenci => pr_cdagenci                        
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nmoperad => ''
                         ,pr_nrregist => pr_nrregist
                         ,pr_nriniseq => pr_nriniseq
                         ,pr_qtregist => vr_qtregist
                         ,pr_nmdcampo => pr_nmdcampo
                         ,pr_tab_operadores => vr_tab_operadores 
                         ,pr_tab_erro => vr_tab_erro
                         ,pr_des_erro => vr_des_reto);
                               
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_car.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clob_ret, TRUE);
      dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

      --Buscar Primeira regional
      vr_index:= vr_tab_operadores.FIRST;
        
      --Percorrer todos as regionais
      WHILE vr_index IS NOT NULL LOOP
        vr_string:= '<regi>'||
                      '<cdcooper>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdcooper),'0')|| '</cdcooper>'||
                      '<cdoperad>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdoperad),'0')|| '</cdoperad>'||
                      '<cdagenci>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdoperad),' ')|| '</cdagenci>'||
                      '<nmoperad>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).nmoperad),' ')|| '</nmoperad>'||                        
                    '</regi>';

         -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);

        --Proximo Registro
        vr_index:= vr_tab_operadores.NEXT(vr_index);

      END LOOP;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '</root>'
                             ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
        pr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_car --> '|| SQLERRM;

  END pc_busca_operadores_car;

  
  PROCEDURE pc_busca_param_cnv_cob(pr_nrconven IN crapcco.nrconven%TYPE   --Convenio
                                  ,pr_nriniseq IN NUMBER                  --Quantidade inicial
                                  ,pr_nrregist IN NUMBER                  --Qunatidade de registros
                                  ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
    
                              
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_param_convenios                            
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para trazer parametros do cadastro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/  
                              
  --Cursor para encontrar os convenios  
  CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrconven IN crapcco.nrconven%TYPE) IS
  SELECT crapcco.nrconven
        ,crapcco.nrdctabb
        ,crapcco.cddbanco
        ,DECODE(crapcco.flgativo,1,'ATIVO','INATIVO') situacao
        ,crapcco.dsorgarq    
    FROM crapcco 
   WHERE crapcco.cdcooper = pr_cdcooper  
     AND(pr_nrconven IS NULL  OR
         crapcco.nrconven = pr_nrconven)
         ORDER BY crapcco.nmdbanco;
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de parametros cobranca
    vr_tab_cobranca typ_tab_cobranca;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nrregist INTEGER;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_cobranca.DELETE;
      
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
      
      FOR rw_crapcco IN cr_crapcco(pr_cdcooper => vr_cdcooper
                                  ,pr_nrconven => pr_nrconven) LOOP
      
        --Incrementar Quantidade Registros do Parametro
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
          
        --Numero Registros
        IF vr_nrregist > 0 THEN 
          
          --Indice para a temp-table
          vr_index:= vr_tab_cobranca.COUNT + 1;        
          vr_tab_cobranca(vr_index).nrconven:= rw_crapcco.nrconven;
          vr_tab_cobranca(vr_index).nrdctabb:= rw_crapcco.nrdctabb;
          vr_tab_cobranca(vr_index).cddbanco:= rw_crapcco.cddbanco;
          vr_tab_cobranca(vr_index).situacao:= rw_crapcco.situacao;
          vr_tab_cobranca(vr_index).dsorgarq:= rw_crapcco.dsorgarq;
          
        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
      END LOOP;          
             
      IF vr_tab_cobranca.COUNT() = 0 THEN      
        vr_dscritic := 'Nenhum parametro de convenio encontrado.';
        RAISE vr_exc_erro;        
      END IF;
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros>');
      
      --Buscar Primeiro beneficiario
      vr_index:= vr_tab_cobranca.FIRST;
        
      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados            
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<cobranca>'||  
                                                        '<nrconven>' || TO_CHAR(gene0002.fn_mask(vr_tab_cobranca(vr_index).nrconven,'zzzzzz.zz9')) ||'</nrconven>'||
                                                        '<nrdctabb>' || LTrim(RTRIM(gene0002.fn_mask(vr_tab_cobranca(vr_index).nrdctabb, 'zzzz.zzz.9'))) ||'</nrdctabb>'||                                                         
                                                        '<cddbanco>' || vr_tab_cobranca(vr_index).cddbanco ||'</cddbanco>'||
                                                        '<flgativo>' || vr_tab_cobranca(vr_index).situacao ||'</flgativo>'||
                                                        '<dsorgarq>' || vr_tab_cobranca(vr_index).dsorgarq ||'</dsorgarq>'||                                                          
                                                     '</cobranca>'); 
          
        --Proximo Registro
        vr_index:= vr_tab_cobranca.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</parametros></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'parametros'            --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'             --> Nome do atributo
                               ,pr_atval => vr_qtregist    --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);      
                                   
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN        
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
        pr_dscritic:= 'Erro na pc_busca_param_cnv_cob --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_param_cnv_cob;
  
  
  PROCEDURE pc_busca_bancos (pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa 
                            ,pr_nrdcaixa IN INTEGER               --Código caixa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                            ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                            ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                            ,pr_nrregist IN INTEGER
                            ,pr_nriniseq IN INTEGER
                            ,pr_qtregist OUT INTEGER
                            ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                            ,pr_tab_bancos OUT typ_tab_bancos --Tabela w-inform
                            ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                            ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    CURSOR cr_crapban IS
    SELECT crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nmresbcc
          ,crapban.dtmvtolt
          ,crapban.cdoperad
          ,crapban.flgoppag
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
     FROM  crapban 
    WHERE crapban.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,crapban.cdbccxlt,pr_cdbccxlt)
      AND (TRIM(pr_nmextbcc) IS NULL 
       OR upper(crapban.nmextbcc) LIKE '%'|| upper(pr_nmextbcc) || '%' )
         ORDER BY crapban.cdbccxlt;
    
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000):= NULL;
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
  
  --Tabela de bancos
  vr_tab_bancos typ_tab_bancos;
  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;
  
  BEGIN
   --limpar tabela BANCOS
    vr_tab_bancos.DELETE;
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    vr_nrregist := nvl(pr_nrregist,0);
    
    FOR rw_crapban IN cr_crapban LOOP
      
      --Indice para a temp-table
      vr_index:= pr_tab_bancos.COUNT + 1;
                                    
      --Incrementar Quantidade Registros do Parametro
      pr_qtregist:= nvl(pr_qtregist,0) + 1;
          
      /* controles da paginacao */
      IF (pr_qtregist < nvl(pr_nriniseq,0)) OR
         (pr_qtregist > (nvl(pr_nriniseq,0) + nvl(pr_nrregist,0))) THEN
         --Proximo registro
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_bancos.EXISTS(vr_index) THEN   
                     
            --Popular dados na tabela memoria
            pr_tab_bancos(vr_index).cdbccxlt:= rw_crapban.cdbccxlt;
            pr_tab_bancos(vr_index).nmextbcc:= rw_crapban.nmextbcc;
            pr_tab_bancos(vr_index).nmresbcc:= rw_crapban.nmresbcc;
            pr_tab_bancos(vr_index).dtmvtolt:= rw_crapban.dtmvtolt;
            pr_tab_bancos(vr_index).cdoperad:= rw_crapban.cdoperad;
            pr_tab_bancos(vr_index).flgoppag:= rw_crapban.flgoppag;   
            pr_tab_bancos(vr_index).nrispbif:= rw_crapban.nrispbif;             
            pr_tab_bancos(vr_index).flgdispb:= rw_crapban.flgdispb;   
            pr_tab_bancos(vr_index).dtinispb:= rw_crapban.dtinispb;
                       
          END IF;  
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    --Retorno OK
    pr_des_erro:= 'OK';  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';          
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
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
  END  pc_busca_bancos;     
  
  PROCEDURE pc_busca_bancos_web (pr_cdbccxlt  IN crapban.cdbccxlt%TYPE
                                ,pr_cddbanco  IN crapban.cdbccxlt%TYPE
                                ,pr_nmextbcc  IN crapban.nmextbcc%TYPE
                                ,pr_nrregist  IN INTEGER                              
                                ,pr_nriniseq  IN INTEGER  
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS           --Saida OK/NOK
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos_web                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos, apenas chama pc_busca_bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_bancos typ_tab_bancos;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_cdbccxlt crapban.cdbccxlt%TYPE := 0;
   
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                 
  
  BEGIN
    --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_bancos.DELETE;
      
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
      
      --Pega o código do banco a ser pesquisado
      IF pr_cdbccxlt > 0 THEN
        
        vr_cdbccxlt := pr_cdbccxlt;
        
      ELSIF pr_cddbanco > 0 THEN
        
        vr_cdbccxlt := pr_cddbanco;
        
      END IF;
      
      pc_busca_bancos(pr_cdcooper   => vr_cdcooper 
                     ,pr_nrdcaixa   => vr_nrdcaixa
                     ,pr_cdagenci   => vr_cdagenci
                     ,pr_cdbccxlt   => vr_cdbccxlt
                     ,pr_nmextbcc   => pr_nmextbcc
                     ,pr_nrregist   => pr_nrregist
                     ,pr_nriniseq   => pr_nriniseq
                     ,pr_qtregist   => vr_qtregist
                     ,pr_nmdcampo   => pr_nmdcampo
                     ,pr_tab_bancos => vr_tab_bancos
                     ,pr_tab_erro   => vr_tab_erro
                     ,pr_des_erro   => vr_des_reto);
                     
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN    
            
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na pc_busca_bancos_web.';
        END IF;  
                
        --Levantar Excecao
        RAISE vr_exc_erro; 
              
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><bancos>');
      
      --Buscar Primeiro registro
      vr_index:= vr_tab_bancos.FIRST;
        
      --Percorrer todos os registros
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<banco>'||
                                                     '  <cdbccxlt>' || vr_tab_bancos(vr_index).cdbccxlt ||'</cdbccxlt>'||
                                                     '  <nmextbcc>' || vr_tab_bancos(vr_index).nmextbcc ||'</nmextbcc>'||
                                                     '  <nmresbcc>' || vr_tab_bancos(vr_index).nmresbcc ||'</nmresbcc>'||
                                                     '  <dtmvtolt>' || vr_tab_bancos(vr_index).dtmvtolt ||'</dtmvtolt>'||
                                                     '  <cdoperad>' || vr_tab_bancos(vr_index).cdoperad ||'</cdoperad>'||
                                                     '  <flgoppag>' || vr_tab_bancos(vr_index).flgoppag ||'</flgoppag>'||
                                                     '  <nrispbif>' || vr_tab_bancos(vr_index).nrispbif ||'</nrispbif>'||
                                                     '  <flgdispb>' || vr_tab_bancos(vr_index).flgdispb ||'</flgdispb>'||
                                                     '  <dtinispb>' || vr_tab_bancos(vr_index).dtinispb ||'</dtinispb>'||                                                        
                                                     '</banco>'); 
                   
        --Proximo Registro
        vr_index:= vr_tab_bancos.NEXT(vr_index);      
            
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</bancos></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
      -- Insere atributo na tag banco com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'bancos'            --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);    
                                   
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
        pr_dscritic:= 'Erro na pc_busca_bancos_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_bancos_web;
                                
  PROCEDURE pc_busca_bancos_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                               ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                               ,pr_nrregist IN INTEGER                              
                               ,pr_nriniseq IN INTEGER  
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                               ,pr_dscritic OUT VARCHAR2)IS         --> Descricao Erro  
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos_car                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos, apenas chama pc_busca_bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_bancos typ_tab_bancos;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;         
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_bancos.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;   
    
    pc_busca_bancos(pr_cdcooper   => pr_cdcooper 
                   ,pr_nrdcaixa   => pr_nrdcaixa
                   ,pr_cdagenci   => pr_cdagenci
                   ,pr_cdbccxlt   => pr_cdbccxlt
                   ,pr_nmextbcc   => pr_nmextbcc
                   ,pr_nrregist   => pr_nrregist
                   ,pr_nriniseq   => pr_nriniseq
                   ,pr_qtregist   => vr_qtregist
                   ,pr_nmdcampo   => pr_nmdcampo
                   ,pr_tab_bancos => vr_tab_bancos
                   ,pr_tab_erro   => vr_tab_erro
                   ,pr_des_erro   => vr_des_reto);
                     
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN    
          
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF; 
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_bancos.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      
      vr_string:= '<banco>'||
                  '  <cdbccxlt>' || vr_tab_bancos(vr_index).cdbccxlt ||'</cdbccxlt>'||
                  '  <nmextbcc>' || vr_tab_bancos(vr_index).nmextbcc ||'</nmextbcc>'||
                  '  <nmresbcc>' || vr_tab_bancos(vr_index).nmresbcc ||'</nmresbcc>'||
                  '  <dtmvtolt>' || vr_tab_bancos(vr_index).dtmvtolt ||'</dtmvtolt>'||
                  '  <cdoperad>' || vr_tab_bancos(vr_index).cdoperad ||'</cdoperad>'||
                  '  <flgoppag>' || vr_tab_bancos(vr_index).flgoppag ||'</flgoppag>'||
                  '  <nrispbif>' || vr_tab_bancos(vr_index).nrispbif ||'</nrispbif>'||
                  '  <flgdispb>' || vr_tab_bancos(vr_index).flgdispb ||'</flgdispb>'||
                  '  <dtinispb>' || vr_tab_bancos(vr_index).dtinispb ||'</dtinispb>'||                          
                  '</banco>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_bancos.NEXT(vr_index);
      
    END LOOP; 
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_bancos_car --> '|| SQLERRM;
  
  END pc_busca_bancos_car; 
  
  PROCEDURE pc_busca_historico(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa 
                              ,pr_nrdcaixa IN INTEGER               --Código caixa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                              ,pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                              ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                              ,pr_flglanca  IN INTEGER --> flag se lancamento
                              ,pr_inautori  IN INTEGER 
                              ,pr_nrregist IN INTEGER
                              ,pr_nriniseq IN INTEGER
                              ,pr_qtregist OUT INTEGER
                              ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                              ,pr_tab_historicos OUT typ_tab_historicos --Tabela historicos
                              ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                              ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao: 02/08/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos.
    
    Alterações : 02/08/2016 - Ajuste para retornar o nome extenso do histórico (Andrei - RKAM)
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_craphis IS
  SELECT craphis.indebfol
        ,craphis.tplotmov
        ,craphis.indebcre
        ,craphis.inhistor
        ,craphis.indebcta
        ,craphis.inautori
        ,craphis.cdhistor
        ,craphis.dshistor
        ,craphis.dsexthst
   FROM craphis 
  WHERE craphis.cdcooper = pr_cdcooper                
    AND craphis.cdhistor = decode(nvl(pr_cdhistor,0),0,craphis.cdhistor,pr_cdhistor)
    AND (TRIM(pr_dshistor) IS NULL
     OR upper(craphis.dsexthst) LIKE '%'|| upper(pr_dshistor) ||'%');
    
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_historicos.DELETE;  
    
    FOR rw_craphis IN cr_craphis LOOP
      
      IF pr_flglanca = 1   THEN /* Utilizado pela LOTE e LANAUT */
        
        IF rw_craphis.indebfol <> 1   THEN 
          
          IF rw_craphis.tplotmov <> 1   OR
             rw_craphis.indebcre <> 'D' OR
             rw_craphis.inhistor <> 1   OR
             rw_craphis.indebcta <> 1   THEN
             CONTINUE;
          END IF;
          
        END IF;
        
      END IF;
      
      IF pr_inautori = 9 THEN  /* Utilizado pelo programa DCTROR */
        
        IF rw_craphis.tplotmov <> 8 AND
           rw_craphis.tplotmov <> 9 THEN 
           CONTINUE;
        END IF;      
         
      ELSE 
        IF pr_inautori <> 0 THEN
          IF rw_craphis.inautori <> 1 THEN
            CONTINUE;
          END IF;
        END IF;
      END IF;
      
      --Indice para a temp-table
      vr_index:= pr_tab_historicos.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo historico
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_historicos.EXISTS(vr_index) THEN  
                      
            --Popular dados na tabela memoria
            pr_tab_historicos(vr_index).cdhistor:= rw_craphis.cdhistor;
            pr_tab_historicos(vr_index).dshistor:= rw_craphis.dsexthst;
                       
          END IF;  
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_historico;                             
  
  PROCEDURE pc_busca_historico_web(pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdtarhis  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhiscxa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisnet  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhistaa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisblq  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                                  ,pr_flglanca  IN INTEGER --> flag se lancamento
                                  ,pr_inautori  IN INTEGER 
                                  ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                  ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                  ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2)IS            --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico_web                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos para WEB, apenas chama a pc_busca_historico.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de historicos
    vr_tab_historicos typ_tab_historicos;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_cdhistor craphis.cdhistor%TYPE := 0;
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_historicos.DELETE;
      
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
                                
    --Pega o códito do histórico a ser utilizado
    IF pr_cdhistor > 0 THEN
      
      vr_cdhistor := pr_cdhistor;
      
    ELSIF pr_cdtarhis > 0 THEN
      
      vr_cdhistor := pr_cdtarhis;
      
    ELSIF pr_cdhiscxa > 0 THEN
      
      vr_cdhistor := pr_cdhiscxa;
      
    ELSIF pr_cdhisnet > 0 THEN
      
      vr_cdhistor := pr_cdhisnet;
      
    ELSIF pr_cdhistaa > 0 THEN
      
      vr_cdhistor := pr_cdhistaa;
      
    ELSIF pr_cdhisblq > 0 THEN
      
      vr_cdhistor := pr_cdhisblq;
      
    END IF;  
    
    pc_busca_historico(pr_cdcooper      => vr_cdcooper
                      ,pr_nrdcaixa      => vr_nrdcaixa
                      ,pr_cdagenci      => vr_cdagenci
                      ,pr_cdhistor      => vr_cdhistor
                      ,pr_dshistor      => pr_dshistor
                      ,pr_flglanca      => pr_flglanca
                      ,pr_inautori      => pr_inautori
                      ,pr_nrregist      => pr_nrregist
                      ,pr_nriniseq      => pr_nriniseq
                      ,pr_qtregist      => vr_qtregist
                      ,pr_nmdcampo      => pr_nmdcampo
                      ,pr_tab_historicos => vr_tab_historicos
                      ,pr_tab_erro       => vr_tab_erro
                      ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><historicos>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_historicos.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<historico>'||
                                                   '  <cdhistor>' || vr_tab_historicos(vr_index).cdhistor||'</cdhistor>'||
                                                   '  <dshistor>' || vr_tab_historicos(vr_index).dshistor||'</dshistor>'||                                                   
                                                   '</historico>'); 
            
      --Proximo Registro
      vr_index:= vr_tab_historicos.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</historicos></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'historicos'        --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_historico_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_historico_web;                             
  
  PROCEDURE pc_busca_historico_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                   ,pr_nrdcaixa IN INTEGER               --Código caixa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                   ,pr_cdhistor IN craphis.cdhistor%TYPE --> cd historico
                                   ,pr_dshistor IN craphis.dshistor%TYPE --> ds historico
                                   ,pr_flglanca IN INTEGER --> flag se lancamento
                                   ,pr_inautori IN INTEGER -->                                    
                                   ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2)IS         --> Descricao Erro  
                                   
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico_car                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos caracter, apenas chama a pc_busca_historico.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_historicos typ_tab_historicos;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_historicos.DELETE;
    
    pc_busca_historico(pr_cdcooper      => pr_cdcooper
                      ,pr_nrdcaixa      => pr_nrdcaixa
                      ,pr_cdagenci      => pr_cdagenci
                      ,pr_cdhistor      => pr_cdhistor
                      ,pr_dshistor      => pr_dshistor
                      ,pr_flglanca      => pr_flglanca
                      ,pr_inautori      => pr_inautori
                      ,pr_nrregist      => pr_nrregist
                      ,pr_nriniseq      => pr_nriniseq
                      ,pr_qtregist      => vr_qtregist
                      ,pr_nmdcampo      => pr_nmdcampo
                      ,pr_tab_historicos => vr_tab_historicos
                      ,pr_tab_erro       => vr_tab_erro
                      ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_web.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeira regional
    vr_index:= vr_tab_historicos.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<historico>'||
                  '  <cdhistor>' || vr_tab_historicos(vr_index).cdhistor||'</cdhistor>'||
                  '  <dshistor>' || vr_tab_historicos(vr_index).dshistor||'</dshistor>'||                    
                  '</historico>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_historicos.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_historico_car --> '|| SQLERRM;
      
  END pc_busca_historico_car; 
    
  PROCEDURE pc_busca_banco_caixa(pr_cdcooper IN crapcop.cdcooper%TYPE     -- Cooperativa 
                                ,pr_nrdcaixa IN INTEGER                   -- Código caixa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE     -- Código da agência
                                ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE     -- Código do banco
                                ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE     -- Nome do banco
                                ,pr_nrregist IN INTEGER                   -- Número de registros
                                ,pr_nriniseq IN INTEGER                   -- Quantidade inicial
                                ,pr_qtregist OUT INTEGER                  -- Quantidade total de registros
                                ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                ,pr_tab_banco_caixa OUT typ_tab_banco_caixa -- Tabela banco caixa
                                ,pr_tab_erro OUT gene0001.typ_tab_erro    -- Tabela Erros
                                ,pr_des_erro OUT VARCHAR2)IS              -- Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa                            
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_crapbcl(pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE
                   ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE) IS
  SELECT crapbcl.cdbccxlt
        ,crapbcl.nmextbcc
    FROM crapbcl 
   WHERE crapbcl.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,crapbcl.cdbccxlt,pr_cdbccxlt)
    AND (TRIM(pr_nmextbcc) IS NULL
     OR upper(crapbcl.nmextbcc) LIKE '%'|| upper(pr_nmextbcc) ||'%')
   ORDER BY crapbcl.cdbccxlt;
      
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;

  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_banco_caixa.DELETE;  
    
    FOR rw_crapbcl IN cr_crapbcl(pr_cdbccxlt => pr_cdbccxlt
                                ,pr_nmextbcc => pr_nmextbcc) LOOP      
      
      --Indice para a temp-table
      vr_index:= pr_tab_banco_caixa.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo registro
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_banco_caixa.EXISTS(vr_index) THEN   
                     
            --Popular dados na tabela memoria
            pr_tab_banco_caixa(vr_index).cdbccxlt:= rw_crapbcl.cdbccxlt;
            pr_tab_banco_caixa(vr_index).nmextbcc:= rw_crapbcl.nmextbcc;
                       
          END IF;  
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_banco_caixa;                             
  
  PROCEDURE pc_busca_banco_caixa_web(pr_cdbccxlt  IN crapbcl.cdbccxlt%TYPE -- Código do banco
                                    ,pr_nmextbcc  IN crapbcl.nmextbcc%TYPE -- Nome do Banco
                                    ,pr_nmbcolot  IN crapban.nmextbcc%TYPE
                                    ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                    ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                    ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa_web                          
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa para WEB, apenas chama a pc_busca_banco_caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de historicos
    vr_tab_banco_caixa typ_tab_banco_caixa;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nmextbcc crapbcl.nmextbcc%TYPE;
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_banco_caixa.DELETE;
      
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
    
    --Pega o nome do banco a ser pesquisado
    IF trim(pr_nmextbcc) IS NOT NULL THEN
        
      vr_nmextbcc := pr_nmextbcc;
        
    ELSIF trim(pr_nmbcolot) IS NOT NULL THEN
        
      vr_nmextbcc := pr_nmbcolot;
        
    END IF;
      
    pc_busca_banco_caixa(pr_cdcooper      => vr_cdcooper
                        ,pr_nrdcaixa      => vr_nrdcaixa
                        ,pr_cdagenci      => vr_cdagenci
                        ,pr_cdbccxlt      => pr_cdbccxlt
                        ,pr_nmextbcc      => vr_nmextbcc
                        ,pr_nrregist      => pr_nrregist
                        ,pr_nriniseq      => pr_nriniseq
                        ,pr_qtregist      => vr_qtregist
                        ,pr_nmdcampo      => pr_nmdcampo
                        ,pr_tab_banco_caixa => vr_tab_banco_caixa
                        ,pr_tab_erro       => vr_tab_erro
                        ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_banco_caixa.';
      END IF;      
          
      --Levantar Excecao
      RAISE vr_exc_erro;   
           
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><bancoCaixa>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_banco_caixa.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<banco>'||
                                                   '  <cdbccxlt>' || vr_tab_banco_caixa(vr_index).cdbccxlt||'</cdbccxlt>'||
                                                   '  <nmextbcc>' || vr_tab_banco_caixa(vr_index).nmextbcc||'</nmextbcc>'||                                                   
                                                   '</banco>'); 
            
      --Proximo Registro
      vr_index:= vr_tab_banco_caixa.NEXT(vr_index); 
    
    END LOOP;
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</bancoCaixa></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'bancoCaixa'        --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_banco_caixa_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_banco_caixa_web;                             
  
  PROCEDURE pc_busca_banco_caixa_car( pr_cdcooper IN crapcop.cdcooper%type --> Codigo Cooperativa  
                                     ,pr_nrdcaixa IN INTEGER               --> Código caixa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE --> Código do banco
                                     ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE --> Nome do banco
                                     ,pr_nrregist IN INTEGER               --> Quantidade de registros                            
                                     ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2)IS          --> Descricao Erro  
                                   
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa_car                          
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa caracter, apenas chama a pc_busca_banco_caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de bancos
    vr_tab_banco_caixa typ_tab_banco_caixa;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_banco_caixa.DELETE;
    
    pc_busca_banco_caixa(pr_cdcooper      => pr_cdcooper
                        ,pr_nrdcaixa      => pr_nrdcaixa
                        ,pr_cdagenci      => pr_cdagenci
                        ,pr_cdbccxlt      => pr_cdbccxlt
                        ,pr_nmextbcc      => pr_nmextbcc
                        ,pr_nrregist      => pr_nrregist
                        ,pr_nriniseq      => pr_nriniseq
                        ,pr_qtregist      => vr_qtregist
                        ,pr_nmdcampo      => pr_nmdcampo
                        ,pr_tab_banco_caixa => vr_tab_banco_caixa
                        ,pr_tab_erro       => vr_tab_erro
                        ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN   
           
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_banco_caixa.';
      END IF;      
          
      --Levantar Excecao
      RAISE vr_exc_erro;
              
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_banco_caixa.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<bancoCaixa>'||
                  '  <cdbccxlt>' || vr_tab_banco_caixa(vr_index).cdbccxlt||'</cdbccxlt>'||
                  '  <nmextbcc>' || vr_tab_banco_caixa(vr_index).nmextbcc||'</nmextbcc>'||                    
                  '</bancoCaixa>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_banco_caixa.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_banco_caixa_car --> '|| SQLERRM;
      
  END pc_busca_banco_caixa_car; 

  PROCEDURE pc_busca_craplrt(pr_cddlinha  IN craplrt.cddlinha%TYPE -- Codigo da linha
                            ,pr_dsdlinha  IN craplrt.dsdlinha%TYPE -- Descricao da linha
                            ,pr_tpdlinha  IN craplrt.tpdlinha%TYPE -- Tipo da linha
                            ,pr_flgstlcr  IN craplrt.flgstlcr%TYPE -- Ativo/Inativo
                            ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                            ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                            ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                            ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2)IS            --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_craplrt                            antiga: b1wgen0059\busca-craplrt
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei
    Data     : Julho/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa para linhas de crédito
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                     ,pr_cddlinha IN craplrt.cddlinha%TYPE
                     ,pr_tpdlinha IN craplrt.tpdlinha%TYPE
                     ,pr_flgstlrc IN craplrt.flgstlcr%TYPE
                     ,pr_dsdlinha IN craplrt.dsdlinha%TYPE)IS
    SELECT craplrt.cddlinha
          ,craplrt.dsdlinha
          ,craplrt.tpdlinha
          ,craplrt.txjurfix
      FROM craplrt
     WHERE craplrt.cdcooper = pr_cdcooper
       AND(pr_cddlinha = 0 
        OR craplrt.cddlinha = pr_cddlinha)  
       AND(pr_tpdlinha = 0 
        OR craplrt.tpdlinha = pr_tpdlinha)
       AND(pr_flgstlrc <> 1 
        OR craplrt.flgstlcr = pr_flgstlcr)          
       AND(trim(pr_dsdlinha) IS NULL
        OR upper(craplrt.dsdlinha) LIKE '%' || upper(pr_dsdlinha) || '%');
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de historicos
    vr_tab_historicos typ_tab_historicos;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_cdhistor craphis.cdhistor%TYPE := 0;
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;  
    
    vr_nrregist INTEGER := pr_nrregist;
  
  BEGIN
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
                                
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><linhas>');
      
    FOR rw_craplrt IN cr_craplrt(pr_cdcooper => vr_cdcooper
                                ,pr_cddlinha => nvl(pr_cddlinha,0)
                                ,pr_tpdlinha => nvl(pr_tpdlinha,0)
                                ,pr_flgstlrc => nvl(pr_flgstlcr,0)
                                ,pr_dsdlinha => pr_dsdlinha) LOOP
      
      vr_qtregist := nvl(vr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo historico
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<linha>'||
                                                     '  <cddlinha>' || rw_craplrt.cddlinha ||'</cddlinha>'||
                                                     '  <dsdlinha>' || rw_craplrt.dsdlinha ||'</dsdlinha>'||                                                   
                                                     '  <dsdtxfix>' || to_char(rw_craplrt.txjurfix,'990D00','NLS_NUMERIC_CHARACTERS='',.''') || '% + TR' ||'</dsdtxfix>'||                                                   
                                                     '  <dsdtplin>' || (CASE rw_craplrt.tpdlinha WHEN 1 THEN 'Limite PF' ELSE 'Limite PJ' END) ||'</dsdtplin>'||
                                                     '</linha>'); 
       END IF;  
       
       --Diminuir registros
       vr_nrregist:= nvl(vr_nrregist,0) - 1;    
      
    END LOOP;
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</linhas></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'linhas'        --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_historico_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_craplrt; 
  
  PROCEDURE pc_busca_linhas_credito(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa 
                                   ,pr_nrdcaixa IN INTEGER               --Código caixa
                                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --Código da agência
                                   ,pr_dslcremp IN craplcr.dslcremp%TYPE -- cd historico
                                   ,pr_cdfinemp IN craplch.cdfinemp%TYPE -- descricao historico
                                   ,pr_flgstlcr IN craplcr.flgstlcr%TYPE --> flag se lancamento
                                   ,pr_cdmodali IN craplcr.cdmodali%TYPE 
                                   ,pr_nrregist IN INTEGER
                                   ,pr_nriniseq IN INTEGER
                                   ,pr_qtregist OUT INTEGER
                                   ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                                   ,pr_tab_linhas OUT typ_tab_linhas --Tabela linhas
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                   ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_linhas_credito                            antiga: b1wgen0059\busca-craplcr
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei
    Data     : Julho/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa linhas de crédito
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
                   ,pr_cdfinemp IN craplch.cdfinemp%TYPE
                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE
                   ,pr_cdmodali IN craplcr.cdmodali%TYPE
                   ,pr_flgstlcr IN craplcr.flgstlcr%TYPE) IS
  SELECT craplcr.cdlcremp
        ,craplcr.dslcremp
        ,decode(craplcr.flgstlcr,1,'Liberada','Bloqueada') flgstlcr
        ,craplcr.tpctrato
        ,craplcr.txbaspre
        ,craplcr.nrfimpre
        ,decode(craplcr.tpctrato,1,'AVAL',2,'VEICULOS',3,'IMOVEIS','NAO CADASTRADO') dsgarant
        ,craplcr.cdcooper
   FROM craplch
       ,craplcr 
  WHERE craplch.cdcooper = pr_cdcooper
    AND craplch.cdfinemp = pr_cdfinemp     
    AND craplch.cdlcrhab >= pr_cdlcremp    
    AND craplcr.cdcooper = craplch.cdcooper
    AND craplcr.cdlcremp = craplch.cdlcrhab
    AND (pr_cdmodali = 0
     OR craplcr.cdmodali = pr_cdmodali )   
    AND (((pr_cdmodali = 0 
    AND    pr_cdlcremp = 0)
    AND craplch.cdlcrhab >= pr_cdlcremp )
     OR ((pr_cdmodali <> 0 
    AND   pr_cdlcremp <> 0)
    AND craplch.cdlcrhab = pr_cdlcremp ))  
    AND (pr_flgstlcr = 0 
     OR craplcr.flgstlcr = pr_flgstlcr)
    AND (pr_dslcremp IS NULL OR upper(craplcr.dslcremp) LIKE ('%' || upper(pr_dslcremp) ||'%'));
  rw_craplch cr_craplch%ROWTYPE;
  
  CURSOR cr_craplcr(pr_cdcooper IN craplch.cdcooper%TYPE
                   ,pr_cdlcremp IN craplcr.cdlcremp%TYPE
                   ,pr_cdmodali IN craplcr.cdmodali%TYPE
                   ,pr_flgstlcr IN craplcr.flgstlcr%TYPE) IS
  SELECT craplcr.cdlcremp
        ,craplcr.dslcremp
        ,decode(craplcr.flgstlcr,1,'Liberada','Bloqueada') flgstlcr
        ,craplcr.tpctrato
        ,craplcr.txbaspre
        ,craplcr.nrfimpre
        ,decode(craplcr.tpctrato,1,'AVAL',2,'VEICULOS',3,'IMOVEIS','NAO CADASTRADO') dsgarant
        ,craplcr.cdcooper
   FROM craplcr 
  WHERE craplcr.cdcooper = pr_cdcooper
    AND (pr_cdmodali = 0
     OR craplcr.cdmodali = pr_cdmodali )
    AND (pr_cdlcremp = 0 
     OR  craplcr.cdlcremp = pr_cdlcremp)
    AND (pr_flgstlcr = 0 
     OR craplcr.flgstlcr = pr_flgstlcr)
     AND (pr_dslcremp IS NULL OR upper(craplcr.dslcremp) LIKE ('%' || upper(pr_dslcremp) ||'%'));
  rw_craplch cr_craplch%ROWTYPE;
  
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_linhas.DELETE;  
     
    IF pr_cdfinemp > 0 THEN
                         
      FOR rw_craplch IN cr_craplch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdfinemp => pr_cdfinemp
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_cdmodali => pr_cdmodali
                                  ,pr_flgstlcr => pr_flgstlcr) LOOP
        
        --Indice para a temp-table
        vr_index:= pr_tab_linhas.COUNT + 1;
        pr_qtregist := nvl(pr_qtregist,0) + 1;
        
        /* controles da paginacao */
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proxima linha
            CONTINUE;
        END IF; 
        
        --Numero Registros
        IF vr_nrregist > 0 THEN 
          
          --Verificar se já existe na temp-table                             
          IF NOT pr_tab_linhas.EXISTS(vr_index) THEN  
                        
              --Popular dados na tabela memoria
              pr_tab_linhas(vr_index).cdlcremp:= rw_craplch.cdlcremp;
              pr_tab_linhas(vr_index).dsclremp:= rw_craplch.dslcremp;
              pr_tab_linhas(vr_index).flgstlcr:= rw_craplch.flgstlcr;
              pr_tab_linhas(vr_index).tpctrato:= rw_craplch.tpctrato;
              pr_tab_linhas(vr_index).txbaspre:= rw_craplch.txbaspre;
              pr_tab_linhas(vr_index).nrfimpre:= rw_craplch.nrfimpre;
              pr_tab_linhas(vr_index).tpgarant:= rw_craplch.tpctrato;
              pr_tab_linhas(vr_index).dsgarant:= rw_craplch.dsgarant;
                         
            END IF;  
            
        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
      END LOOP;

    ELSE
      
      FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_cdmodali => pr_cdmodali
                                  ,pr_flgstlcr => pr_flgstlcr) LOOP
        
        --Indice para a temp-table
        vr_index:= pr_tab_linhas.COUNT + 1;
        pr_qtregist := nvl(pr_qtregist,0) + 1;
        
        /* controles da paginacao */
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proxima linha
            CONTINUE;
        END IF; 
        
        --Numero Registros
        IF vr_nrregist > 0 THEN 
          
          --Verificar se já existe na temp-table                             
          IF NOT pr_tab_linhas.EXISTS(vr_index) THEN  
                        
              --Popular dados na tabela memoria
              pr_tab_linhas(vr_index).cdlcremp:= rw_craplcr.cdlcremp;
              pr_tab_linhas(vr_index).dsclremp:= rw_craplcr.dslcremp;
              pr_tab_linhas(vr_index).flgstlcr:= rw_craplcr.flgstlcr;
              pr_tab_linhas(vr_index).tpctrato:= rw_craplcr.tpctrato;
              pr_tab_linhas(vr_index).txbaspre:= rw_craplcr.txbaspre;
              pr_tab_linhas(vr_index).nrfimpre:= rw_craplcr.nrfimpre;
              pr_tab_linhas(vr_index).tpgarant:= rw_craplcr.tpctrato;
              pr_tab_linhas(vr_index).dsgarant:= rw_craplcr.dsgarant;
                         
            END IF;  
            
        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
      END LOOP;
    
    END IF;
    
        
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_linhas_credito;                             
  
  PROCEDURE pc_busca_linhas_credito_web(pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- cd historico
                                       ,pr_dslcremp  IN craplcr.dslcremp%TYPE -- cd historico
                                       ,pr_cdfinemp  IN craplch.cdfinemp%TYPE -- cd historico
                                       ,pr_flgstlcr  IN craplcr.flgstlcr%TYPE -- cd historico
                                       ,pr_cdmodali  IN craplcr.cdmodali%TYPE -- cd historico
                                       ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                       ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                       ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2)IS            --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_linhas_credito_web                            antiga: b1wgen0059\busca-craplcr
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei  
    Data     : Julho/2016                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de linhas de crédito para WEB, apenas chama a pc_busca_linhas_credito.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de linhas de crédito
    vr_tab_linhas typ_tab_linhas;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_linhas.DELETE;
      
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
    
    pc_busca_linhas_credito(pr_cdcooper   => vr_cdcooper
                           ,pr_nrdcaixa   => vr_nrdcaixa
                           ,pr_cdlcremp   => nvl(pr_cdlcremp,0)
                           ,pr_dslcremp   => pr_dslcremp
                           ,pr_cdfinemp   => nvl(pr_cdfinemp,0)
                           ,pr_flgstlcr   => pr_flgstlcr
                           ,pr_cdmodali   => nvl(pr_cdmodali,0)
                           ,pr_nrregist   => pr_nrregist
                           ,pr_nriniseq   => pr_nriniseq
                           ,pr_qtregist   => vr_qtregist
                           ,pr_nmdcampo   => pr_nmdcampo
                           ,pr_tab_linhas => vr_tab_linhas
                           ,pr_tab_erro   => vr_tab_erro
                           ,pr_des_erro   => vr_des_reto);
                           
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_linhas_credito_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><linhas>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_linhas.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<linha>'||
                                                   '  <cdlcremp>' || vr_tab_linhas(vr_index).cdlcremp||'</cdlcremp>'||
                                                   '  <dslcremp>' || vr_tab_linhas(vr_index).dsclremp||'</dslcremp>'|| 
                                                   '  <flgstlcr>' || vr_tab_linhas(vr_index).flgstlcr||'</flgstlcr>'|| 
                                                   '  <tpctrato>' || vr_tab_linhas(vr_index).tpctrato||'</tpctrato>'|| 
                                                   '  <txbaspre>' || vr_tab_linhas(vr_index).txbaspre||'</txbaspre>'|| 
                                                   '  <nrfimpre>' || vr_tab_linhas(vr_index).nrfimpre||'</nrfimpre>'|| 
                                                   '  <tpgarant>' || vr_tab_linhas(vr_index).tpgarant||'</tpgarant>'|| 
                                                   '  <dsgarant>' || vr_tab_linhas(vr_index).dsgarant||'</dsgarant>'||                                             
                                                   '</linha>'); 
                                                              
      --Proximo Registro
      vr_index:= vr_tab_linhas.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</linhas></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'linhas'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_linhas_credito_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_linhas_credito_web;                             
    
  PROCEDURE pc_busca_linhas_credito_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                        ,pr_nrdcaixa IN INTEGER               --Código caixa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                        ,pr_cdlcremp  IN craplcr.cdlcremp%TYPE -- cd historico
                                        ,pr_dslcremp  IN craplcr.dslcremp%TYPE -- cd historico
                                        ,pr_cdfinemp  IN craplch.cdfinemp%TYPE -- cd historico
                                        ,pr_flgstlcr  IN craplcr.flgstlcr%TYPE -- cd historico
                                        ,pr_cdmodali  IN craplcr.cdmodali%TYPE -- cd historico
                                        ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                        ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2)IS         --> Descricao Erro  
                                   
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_linhas_credito_car                            antiga: b1wgen0059\busca-craplcr
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei
    Data     : Julho/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de linhas de crédito caracter, apenas chama a pc_busca_linhas_credito.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de linhas de crédito
    vr_tab_linhas typ_tab_linhas;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_linhas.DELETE;
          
    pc_busca_linhas_credito(pr_cdcooper   => pr_cdcooper
                           ,pr_nrdcaixa   => pr_nrdcaixa
                           ,pr_cdlcremp   => nvl(pr_cdlcremp,0)
                           ,pr_dslcremp   => pr_dslcremp
                           ,pr_cdfinemp   => nvl(pr_cdfinemp,0)
                           ,pr_flgstlcr   => pr_flgstlcr
                           ,pr_cdmodali   => nvl(pr_cdmodali,0)
                           ,pr_nrregist   => pr_nrregist
                           ,pr_nriniseq   => pr_nriniseq
                           ,pr_qtregist   => vr_qtregist
                           ,pr_nmdcampo   => pr_nmdcampo
                           ,pr_tab_linhas => vr_tab_linhas
                           ,pr_tab_erro   => vr_tab_erro
                           ,pr_des_erro   => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_linhas_credito_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_linhas.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<linhas>'||
                  '  <cdlcremp>' || vr_tab_linhas(vr_index).cdlcremp||'</cdlcremp>'||
                  '  <dslcremp>' || vr_tab_linhas(vr_index).dsclremp||'</dslcremp>'||
                  '  <flgstlcr>' || vr_tab_linhas(vr_index).flgstlcr||'</flgstlcr>'||       
                  '  <tpctrato>' || vr_tab_linhas(vr_index).tpctrato||'</tpctrato>'||       
                  '  <txbaspre>' || vr_tab_linhas(vr_index).txbaspre||'</txbaspre>'||       
                  '  <nrfimpre>' || vr_tab_linhas(vr_index).nrfimpre||'</nrfimpre>'||       
                  '  <tpgarant>' || vr_tab_linhas(vr_index).tpgarant||'</tpgarant>'||       
                  '  <dsgarant>' || vr_tab_linhas(vr_index).dsgarant||'</dsgarant>'||                                       
                  '</linhas>';
                  
       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_linhas.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_linhas_credito_car --> '|| SQLERRM;
      
  END pc_busca_linhas_credito_car; 
   
  PROCEDURE pc_busca_finalidades_empr(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa 
                                     ,pr_nrdcaixa IN INTEGER               --Código caixa
                                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE -- Código da finalidade
                                     ,pr_dsfinemp IN crapfin.dsfinemp%TYPE -- Descrição da finalidade
                                     ,pr_flgstfin IN crapfin.flgstfin%TYPE -- Situação da finalidade: 0 - Não ativas / 1 - Aitvas / 3 - Todas
                                     ,pr_lstipfin IN VARCHAR2 DEFAULT NULL -- lista com os tipo de finalidade ou nulo para todas
                                     ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE DEFAULT 0 -- Codigo da linha de credito habilitada
                                     ,pr_nrregist IN INTEGER               -- Número de registro
                                     ,pr_nriniseq IN INTEGER               -- Número sequencial do registro
                                     ,pr_qtregist OUT INTEGER              -- Quantidade de registro
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                                     ,pr_tab_finalidades_empr OUT typ_tab_finalidades_empr --Tabela linhas
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                     ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_finalidades_empr                            antiga: b1wgen0059\busca-crapfin
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei
    Data     : Julho/2016                           Ultima atualizacao: 29/03/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa finalidades de empréstimo
    
    Alterações : 01/02/2017 - Adicao de filtro por Linha de Credito. (Jaison/James - PRJ298)

                 29/03/2017 - Inclusao do filtro de lista por tipo de finalidade.
                              PRJ343 - Cessao de credito. (Odirlei-Amcom)
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                   ,pr_cdfinemp IN crapfin.cdfinemp%TYPE
                   ,pr_flgstfin IN crapfin.flgstfin%TYPE
                   ,pr_dsfinemp IN crapfin.dsfinemp%TYPE
                   ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE) IS
    SELECT fin.cdfinemp
          ,fin.dsfinemp
          ,fin.flgstfin
          ,fin.tpfinali
      FROM crapfin fin
          ,craplch lch
     WHERE fin.cdcooper = lch.cdcooper(+)
       AND fin.cdfinemp = lch.cdfinemp(+)
       AND fin.cdcooper = pr_cdcooper
    AND(pr_cdfinemp = 0 
        OR fin.cdfinemp = pr_cdfinemp)
       AND(pr_flgstfin = 3 -- Todas as situacoes
        OR fin.flgstfin = pr_flgstfin)
       AND(pr_lstipfin IS NULL OR 
         'S' = gene0002.fn_existe_valor(pr_base  => pr_lstipfin, 
                                          pr_busca => fin.tpfinali, 
                                        pr_delimite => ',')
         ) 
       AND UPPER(fin.dsfinemp) LIKE '%' || pr_dsfinemp || '%'
       AND(pr_cdlcrhab = 0 
        OR lch.cdlcrhab = pr_cdlcrhab)
  GROUP BY fin.cdfinemp
          ,fin.dsfinemp
          ,fin.flgstfin
          ,fin.tpfinali;
  rw_crapfin cr_crapfin%ROWTYPE;
  
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_finalidades_empr.DELETE;  
                       
    FOR rw_crapfin IN cr_crapfin(pr_cdcooper => pr_cdcooper
                                ,pr_cdfinemp => pr_cdfinemp
                                ,pr_flgstfin => pr_flgstfin
                                ,pr_dsfinemp => pr_dsfinemp
                                ,pr_cdlcrhab => pr_cdlcrhab) LOOP
      
      --Indice para a temp-table
      vr_index:= pr_tab_finalidades_empr.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima linha
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_finalidades_empr.EXISTS(vr_index) THEN  
                      
            --Popular dados na tabela memoria
            pr_tab_finalidades_empr(vr_index).cdfinemp:= rw_crapfin.cdfinemp;
            pr_tab_finalidades_empr(vr_index).dsfinemp:= rw_crapfin.dsfinemp;
            pr_tab_finalidades_empr(vr_index).flgstfin:= rw_crapfin.flgstfin;
            pr_tab_finalidades_empr(vr_index).tpfinali:= rw_crapfin.tpfinali;
                       
          END IF;  
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_finalidades_empr;                             
  
  PROCEDURE pc_busca_finalidades_empr_web(pr_cdfinemp  IN crapfin.cdfinemp%TYPE -- Código da finalidade
                                         ,pr_dsfinemp  IN crapfin.dsfinemp%TYPE -- Descrição da finalidade
                                         ,pr_flgstfin  IN crapfin.flgstfin%TYPE -- Situação da finalidade: 0 - Não ativas / 1 - Aitvas / 3 - Todas
                                         ,pr_lstipfin  IN VARCHAR2              -- lista com os tipo de finalidade ou nulo para todas
                                         ,pr_cdlcrhab  IN craplch.cdlcrhab%TYPE -- Codigo da linha de credito habilitada
                                         ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                         ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                         ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                         ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_finalidades_empr_web                            antiga: b1wgen0059\busca-crapfin-craplcr
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei  
    Data     : Julho/2016                          Ultima atualizacao: 29/03/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa finalidades de empréstimo para WEB, apenas chama a pc_busca_finalidades_empr.
    
    Alterações : 01/02/2017 - Adicao de filtro por Linha de Credito. (Jaison/James - PRJ298)

                 29/03/2017 - Inclusao do filtro de lista por tipo de finalidade.
                              PRJ343 - Cessao de credito. (Odirlei-Amcom)
                               
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de finalidades de empréstimos
    vr_tab_finalidades_empr typ_tab_finalidades_empr;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_finalidades_empr.DELETE;
      
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
    
    pc_busca_finalidades_empr(pr_cdcooper => vr_cdcooper        -- Cooperativa 
                             ,pr_nrdcaixa => vr_nrdcaixa        -- Código caixa
                             ,pr_cdfinemp => nvl(pr_cdfinemp,0) -- Código da finalidade
                             ,pr_dsfinemp => UPPER(pr_dsfinemp) -- Descrição da finalidade
                             ,pr_flgstfin => pr_flgstfin        -- Situação da finalidade
                             ,pr_lstipfin => pr_lstipfin        -- lista com os tipo de finalidade ou nulo para todas
                             ,pr_cdlcrhab => nvl(pr_cdlcrhab,0) -- Codigo da linha de credito habilitada
                             ,pr_nrregist => pr_nrregist        -- Número de registro
                             ,pr_nriniseq => pr_nriniseq        -- Número sequencial do registro
                             ,pr_qtregist => vr_qtregist        -- Quantidade de registro
                             ,pr_nmdcampo => pr_nmdcampo        -- Nome do campo com erro
                             ,pr_tab_finalidades_empr => vr_tab_finalidades_empr -- Tabela finalidades
                             ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                             ,pr_des_erro => vr_des_reto); --Tabela de erros 
                           
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_linhas_credito_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><finalidades>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_finalidades_empr.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<finalidade>'||
                                                   '  <cdfinemp>' || vr_tab_finalidades_empr(vr_index).cdfinemp||'</cdfinemp>'||
                                                   '  <dsfinemp>' || vr_tab_finalidades_empr(vr_index).dsfinemp||'</dsfinemp>'|| 
                                                   '  <flgstfin>' || vr_tab_finalidades_empr(vr_index).flgstfin||'</flgstfin>'|| 
                                                   '  <tpfinali>' || vr_tab_finalidades_empr(vr_index).tpfinali||'</tpfinali>'|| 
                                                   '</finalidade>'); 
                                                              
      --Proximo Registro
      vr_index:= vr_tab_finalidades_empr.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</finalidades></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'linhas'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_finalidades_empr_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_finalidades_empr_web;                             
    
  PROCEDURE pc_busca_finalidades_empr_car( pr_cdcooper IN crapreg.cdcooper%type -- Codigo Cooperativa  
                                          ,pr_nrdcaixa IN INTEGER               -- Código caixa
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE -- Código da agência
                                          ,pr_cdfinemp IN crapfin.cdfinemp%TYPE -- Código da finalidade
                                          ,pr_dsfinemp IN crapfin.dsfinemp%TYPE -- Descrição da finalidade
                                          ,pr_flgstfin IN crapfin.flgstfin%TYPE -- Situação da finalidade: 0 - Não ativas / 1 - Aitvas / 3 - Todas
                                          ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                          ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                          ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                          ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2)IS          -- Descricao Erro  
                                     
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_finalidades_empr_car                            antiga: b1wgen0059\busca-crapfin
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei
    Data     : Julho/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa finalidades de empréstimo caracter, apenas chama a pc_busca_finalidades_empr.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de finalidades de empréstimos
    vr_tab_finalidades_empr typ_tab_finalidades_empr;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_finalidades_empr.DELETE;
          
    pc_busca_finalidades_empr(pr_cdcooper   => pr_cdcooper
                             ,pr_nrdcaixa   => pr_nrdcaixa
                             ,pr_cdfinemp   => nvl(pr_cdfinemp,0)
                             ,pr_dsfinemp   => UPPER(pr_dsfinemp)
                             ,pr_flgstfin   => pr_flgstfin
                             ,pr_nrregist   => pr_nrregist
                             ,pr_nriniseq   => pr_nriniseq
                             ,pr_qtregist   => vr_qtregist
                             ,pr_nmdcampo   => pr_nmdcampo
                             ,pr_tab_finalidades_empr => vr_tab_finalidades_empr
                             ,pr_tab_erro   => vr_tab_erro
                             ,pr_des_erro   => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_finalidades_empr_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_finalidades_empr.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<finalidades>'||
                  '  <cdfinemp>' || vr_tab_finalidades_empr(vr_index).cdfinemp||'</cdfinemp>'||
                  '  <dsfinemp>' || vr_tab_finalidades_empr(vr_index).dsfinemp||'</dsfinemp>'||
                  '  <flgstfin>' || vr_tab_finalidades_empr(vr_index).flgstfin||'</flgstfin>'||       
                  '  <tpfinali>' || vr_tab_finalidades_empr(vr_index).tpfinali||'</tpfinali>'||                                       
                  '</finalidades>';
                  
       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_finalidades_empr.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_finalidades_empr_car --> '|| SQLERRM;
      
  END pc_busca_finalidades_empr_car; 

  PROCEDURE pc_busca_operacao_conta(pr_cdoperacao IN tbcc_operacao.cdoperacao%TYPE --> Codigo da operacao
                                   ,pr_dsoperacao IN tbcc_operacao.dsoperacao%TYPE --> Descricao da operacao
                                   ,pr_nrregist   IN INTEGER                       --> Quantidade de registros                            
                                   ,pr_nriniseq   IN INTEGER                       --> Qunatidade inicial
                                   ,pr_xmllog     IN VARCHAR2                      --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER                   --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2                      --> Descricao da critica
                                   ,pr_retxml    IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2                      --> Nome do Campo
                            	     ,pr_des_erro  OUT VARCHAR2) IS                  --> Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_operacao_conta              Antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jaison Fernando
    Data     : Fevereiro/2017                       Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia : -----
    Objetivo   : Pesquisa Operacoes de Conta Corrente.
    
    Alteracoes : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    CURSOR cr_operacao(pr_cdoperacao IN tbcc_operacao.cdoperacao%TYPE
                      ,pr_dsoperacao IN tbcc_operacao.dsoperacao%TYPE) IS
      SELECT ope.cdoperacao
            ,upper(ope.dsoperacao) dsoperacao
        FROM tbcc_operacao ope
       WHERE ope.cdoperacao = DECODE(pr_cdoperacao, 0, ope.cdoperacao, pr_cdoperacao)
         AND(TRIM(pr_dsoperacao) IS NULL
          OR upper(ope.dsoperacao) LIKE '%' || upper(pr_dsoperacao) || '%');

    -- Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';

    -- Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

    vr_nrregist INTEGER := pr_nrregist;

  BEGIN
    -- Inicializar Variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;

    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><operacoes>');

    FOR rw_operacao IN cr_operacao(pr_cdoperacao => nvl(pr_cdoperacao,0)
                                  ,pr_dsoperacao => pr_dsoperacao) LOOP

      vr_qtregist := nvl(vr_qtregist,0) + 1;

      -- controles da paginacao
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         -- Proximo
          CONTINUE;
      END IF;

      -- Numero Registros
      IF vr_nrregist > 0 THEN

        -- Carrega os dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<operacao>'||
                                                     '  <cdoperacao>' || rw_operacao.cdoperacao ||'</cdoperacao>'||
                                                     '  <dsoperacao>' || rw_operacao.dsoperacao ||'</dsoperacao>'||
                                                     '</operacao>');
       END IF;

       -- Diminuir registros
       vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</operacoes></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que ira receber o novo atributo
                             ,pr_tag   => 'operacoes'         --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Numero da localizacao da TAG na arvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descricao de erros

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Retorno
    pr_des_erro:= 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro:= 'NOK';

      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_des_erro:= 'NOK';

      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_operacao_conta --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_operacao_conta;
  
  PROCEDURE pc_busca_gncdnto(pr_cdnatocp IN gncdnto.cdnatocp%TYPE -- Código da natureza
                            ,pr_rsnatocp IN gncdnto.rsnatocp%TYPE -- Descrição da natureza
                            ,pr_nrregist IN INTEGER               -- Número de registro
                            ,pr_nriniseq IN INTEGER               -- Número sequencial do registro
                            ,pr_qtregist OUT INTEGER              -- Quantidade de registro
                            ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                            ,pr_tab_natureza_ocupacao OUT typ_tab_natureza_ocupacao --Tabela natureza de ocupação
                            ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                            ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdnto                            antiga: b1wgen0059\busca-gncdnto
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano
    Data     : Fevereiro/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa naturezas de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_gncdnto(pr_cdnatocp IN gncdnto.cdnatocp%TYPE
                   ,pr_dsnatocp IN gncdnto.dsnatocp%TYPE) IS
  SELECT gncdnto.cdnatocp
        ,gncdnto.dsnatocp
        ,gncdnto.rsnatocp
   FROM gncdnto
  WHERE (pr_cdnatocp = 0 
     OR gncdnto.cdnatocp = pr_cdnatocp)
    AND UPPER(gncdnto.rsnatocp) LIKE '%' || pr_dsnatocp || '%';
  rw_gncdnto cr_gncdnto%ROWTYPE;
  
  vr_nrregist INTEGER := nvl(pr_nrregist,9999);
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_natureza_ocupacao.DELETE;  
                       
    FOR rw_gncdnto IN cr_gncdnto(pr_cdnatocp => pr_cdnatocp
                                ,pr_dsnatocp => pr_rsnatocp) LOOP
      
      IF trim(rw_gncdnto.rsnatocp) IS NULL THEN
        
        CONTINUE;
        
      END IF;
      
      IF rw_gncdnto.cdnatocp = 99 THEN
        
        CONTINUE;
      
      END IF;
      
      --Indice para a temp-table
      vr_index:= pr_tab_natureza_ocupacao.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima linha
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_natureza_ocupacao.EXISTS(vr_index) THEN  
                      
            --Popular dados na tabela memoria
            pr_tab_natureza_ocupacao(vr_index).cdnatocp:= rw_gncdnto.cdnatocp;
            pr_tab_natureza_ocupacao(vr_index).dsnatocp:= rw_gncdnto.dsnatocp;
            pr_tab_natureza_ocupacao(vr_index).rsnatocp:= rw_gncdnto.rsnatocp;
                       
          END IF;  
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK'; 
    
  END pc_busca_gncdnto;                             
  
  PROCEDURE pc_busca_gncdnto_web(pr_cdnatocp  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                                ,pr_cdnatopc  IN gncdnto.cdnatocp%TYPE -- Código da natureza
                                ,pr_rsnatocp  IN gncdnto.dsnatocp%TYPE -- Descrição da natureza
                                ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdnto_web                            antiga: b1wgen0059\busca-gncdnto
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa Naturezas de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de natureza de ocupação
    vr_tab_natureza_ocupacao typ_tab_natureza_ocupacao;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdnatocp gncdnto.cdnatocp%TYPE;
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_natureza_ocupacao.DELETE;
      
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
    
    IF pr_cdnatopc > 0 THEN
    
      vr_cdnatocp := pr_cdnatopc;
      
    ELSE
      
      vr_cdnatocp := pr_cdnatocp;
          
    END IF;
    
    pc_busca_gncdnto(pr_cdnatocp => nvl(vr_cdnatocp,0) -- Código da natureza
                    ,pr_rsnatocp => UPPER(pr_rsnatocp) -- Descrição da natureza
                    ,pr_nrregist => pr_nrregist        -- Número de registro
                    ,pr_nriniseq => pr_nriniseq        -- Número sequencial do registro
                    ,pr_qtregist => vr_qtregist        -- Quantidade de registro
                    ,pr_nmdcampo => pr_nmdcampo        -- Nome do campo com erro
                    ,pr_tab_natureza_ocupacao => vr_tab_natureza_ocupacao -- Tabela naturezas
                    ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                    ,pr_des_erro => vr_des_reto); --Tabela de erros 
                           
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_gncdnto_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><gncdnto>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_natureza_ocupacao.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<naturezas>'||
                                                   '  <cdnatocp>' || vr_tab_natureza_ocupacao(vr_index).cdnatocp||'</cdnatocp>'||
                                                   '  <dsnatocp>' || vr_tab_natureza_ocupacao(vr_index).dsnatocp||'</dsnatocp>'|| 
                                                   '  <rsnatocp>' || vr_tab_natureza_ocupacao(vr_index).rsnatocp||'</rsnatocp>'||                                                    
                                                   '</naturezas>'); 
                                                              
      --Proximo Registro
      vr_index:= vr_tab_natureza_ocupacao.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</gncdnto></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'gncdnto'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_gncdnto_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_gncdnto_web;                             
    
  PROCEDURE pc_busca_gncdnto_car( pr_cdnatocp IN gncdnto.cdnatocp%TYPE -- Código da finalidade
                                 ,pr_rsnatocp IN gncdnto.rsnatocp%TYPE -- Descrição da finalidade
                                 ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                 ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                 ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2)IS          -- Descricao Erro  
                                     
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdnto_car                            antiga: b1wgen0059\busca-gncdnto
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano 
    Data     : Fevereiro/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa naturezas de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de naturezas de ocupação
    vr_tab_natureza_ocupacao typ_tab_natureza_ocupacao;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_natureza_ocupacao.DELETE;
          
    pc_busca_gncdnto(pr_cdnatocp   => nvl(pr_cdnatocp,0)
                    ,pr_rsnatocp   => UPPER(pr_rsnatocp)
                    ,pr_nrregist   => pr_nrregist
                    ,pr_nriniseq   => pr_nriniseq
                    ,pr_qtregist   => vr_qtregist
                    ,pr_nmdcampo   => pr_nmdcampo
                    ,pr_tab_natureza_ocupacao => vr_tab_natureza_ocupacao
                    ,pr_tab_erro   => vr_tab_erro
                    ,pr_des_erro   => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_gncdnto_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_natureza_ocupacao.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<naturezas>'||
                  '  <cdnatocp>' || vr_tab_natureza_ocupacao(vr_index).cdnatocp||'</cdnatocp>'||
                  '  <rsnatocp>' || vr_tab_natureza_ocupacao(vr_index).rsnatocp||'</rsnatocp>'||
                  '  <dsnatocp>' || vr_tab_natureza_ocupacao(vr_index).dsnatocp||'</dsnatocp>'||                                       
                  '</naturezas>';
                  
       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_natureza_ocupacao.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_gncdnto_car --> '|| SQLERRM;
      
  END pc_busca_gncdnto_car; 
  
  PROCEDURE pc_busca_gncdocp(pr_cdocupa  IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                            ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                            ,pr_nrregist IN INTEGER               -- Número de registro
                            ,pr_nriniseq IN INTEGER               -- Número sequencial do registro
                            ,pr_qtregist OUT INTEGER              -- Quantidade de registro
                            ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                            ,pr_tab_ocupacoes OUT typ_tab_ocupacoes --Tabela de ocupação
                            ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                            ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdocp                            antiga: b1wgen0059\busca-gncdocp
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano
    Data     : Fevereiro/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_gncdocp(pr_cdocupa  IN gncdocp.cdnatocp%TYPE
                   ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE) IS
  SELECT ocp.cdocupa
        ,ocp.dsdocupa
        ,ocp.rsdocupa
   FROM gncdocp ocp
  WHERE(pr_cdocupa = 0
     OR ocp.cdocupa = pr_cdocupa)
    AND UPPER(ocp.rsdocupa) LIKE '%' || pr_rsdocupa || '%';
  rw_gncdocp cr_gncdocp%ROWTYPE;
  
  vr_nrregist INTEGER := nvl(pr_nrregist,9999);
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_ocupacoes.DELETE;  
                       
    FOR rw_gncdocp IN cr_gncdocp(pr_cdocupa  => pr_cdocupa
                                ,pr_rsdocupa => pr_rsdocupa) LOOP
      
      IF trim(rw_gncdocp.rsdocupa) IS NULL THEN
        
        CONTINUE;
        
      END IF;
      
      --Indice para a temp-table
      vr_index:= pr_tab_ocupacoes.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proxima linha
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_ocupacoes.EXISTS(vr_index) THEN  
                      
            --Popular dados na tabela memoria
            pr_tab_ocupacoes(vr_index).cdocupa:= rw_gncdocp.cdocupa;
            pr_tab_ocupacoes(vr_index).dsdocupa:= rw_gncdocp.dsdocupa;
            pr_tab_ocupacoes(vr_index).rsdocupa:= rw_gncdocp.rsdocupa;
                       
          END IF;  
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_gncdocp;                             
  
  PROCEDURE pc_busca_gncdocp_web(pr_cdocupa   IN gncdocp.cdocupa%TYPE  -- Código da ocupação
                                ,pr_cdocpttl  IN gncdnto.cdnatocp%TYPE --Código da natureza
                                ,pr_cdocpcje  IN gncdnto.cdnatocp%TYPE --Código da natureza
                                ,pr_rsdocupa  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                ,pr_dsocpttl  IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                    
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdocp_web                            antiga: b1wgen0059\busca-gncdocp
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano  
    Data     : Fevereiro/2017                          Ultima atualizacao: 08/03/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de ocupação
    
    Alterações : 08/03/2017 - Ajuste para enviar corretamente o campo cdocupa no xml de retorno
			                  (Adriano - SD 614408).

    -------------------------------------------------------------------------------------------------------------*/                                    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de ocupação
    vr_tab_ocupacoes typ_tab_ocupacoes;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    
    vr_cdocupa gncdocp.cdocupa%TYPE;
    vr_rsdocupa gncdocp.rsdocupa%TYPE;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;    
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_ocupacoes.DELETE;
      
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
    
    IF pr_cdocpttl > 0 THEN
    
      vr_cdocupa := pr_cdocpttl;
      
    ELSIF pr_cdocpcje > 0 THEN

      vr_cdocupa := pr_cdocpcje;
    
    ELSE
          
      vr_cdocupa := pr_cdocupa;
          
    END IF;
    
    IF trim(pr_dsocpttl) IS NOT NULL THEN
      
      vr_rsdocupa := pr_dsocpttl;
      
    ELSE
      
      vr_rsdocupa := pr_rsdocupa;
    
    END IF; 
    
    pc_busca_gncdocp(pr_cdocupa  => nvl(vr_cdocupa,0)  -- Código da ocupação
                    ,pr_rsdocupa => UPPER(vr_rsdocupa) -- Descrição da ocupação
                    ,pr_nrregist => pr_nrregist        -- Número de registro
                    ,pr_nriniseq => pr_nriniseq        -- Número sequencial do registro
                    ,pr_qtregist => vr_qtregist        -- Quantidade de registro
                    ,pr_nmdcampo => pr_nmdcampo        -- Nome do campo com erro
                    ,pr_tab_ocupacoes => vr_tab_ocupacoes -- Tabela naturezas
                    ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                    ,pr_des_erro => vr_des_reto); --Tabela de erros 
                           
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_gncdocp_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><gncdocp>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_ocupacoes.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<ocupacoes>'||
                                                   '  <cdocupa>' || vr_tab_ocupacoes(vr_index).cdocupa||'</cdocupa>'||
                                                   '  <dsdocupa>' || vr_tab_ocupacoes(vr_index).dsdocupa||'</dsdocupa>'|| 
                                                   '  <rsdocupa>' || vr_tab_ocupacoes(vr_index).rsdocupa||'</rsdocupa>'||                                                    
                                                   '</ocupacoes>'); 
                                                              
      --Proximo Registro
      vr_index:= vr_tab_ocupacoes.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</gncdocp></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'gncdocp'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
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
      pr_dscritic:= 'Erro na pc_busca_gncdocp_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_gncdocp_web;                             
    
  PROCEDURE pc_busca_gncdocp_car( pr_cdocupa  IN gncdocp.cdocupa%TYPE -- Código da ocupação
                                 ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE -- Descrição da ocupação
                                 ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                 ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                 ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             -- Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 -- Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          -- Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2)IS          -- Descricao Erro  
                                     
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gncdocp_car                            antiga: b1wgen0059\busca-gncdocp
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano 
    Data     : Fevereiro2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de ocupação
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de ocupação
    vr_tab_ocupacoes typ_tab_ocupacoes;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_ocupacoes.DELETE;
          
    pc_busca_gncdocp(pr_cdocupa    => nvl(pr_cdocupa,0)
                    ,pr_rsdocupa   => UPPER(pr_rsdocupa)
                    ,pr_nrregist   => pr_nrregist
                    ,pr_nriniseq   => pr_nriniseq
                    ,pr_qtregist   => vr_qtregist
                    ,pr_nmdcampo   => pr_nmdcampo
                    ,pr_tab_ocupacoes => vr_tab_ocupacoes
                    ,pr_tab_erro   => vr_tab_erro
                    ,pr_des_erro   => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_gncdocp_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_ocupacoes.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<ocupacoes>'||
                  '  <cdocupa>' || vr_tab_ocupacoes(vr_index).cdocupa||'</cdocupa>'||
                  '  <dsdocupa>' || vr_tab_ocupacoes(vr_index).dsdocupa||'</dsdocupa>'||
                  '  <rsdocupa>' || vr_tab_ocupacoes(vr_index).rsdocupa||'</rsdocupa>'||                                       
                  '</ocupacoes>';
                  
       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_ocupacoes.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
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
      pr_dscritic:= 'Erro na pc_busca_gncdocp_car --> '|| SQLERRM;
      
  END pc_busca_gncdocp_car; 
  PROCEDURE pc_busca_nacionalidades(pr_cdnacion  IN crapnac.cdnacion%TYPE -- código da nacionalidade
                                   ,pr_dsnacion  IN crapnac.dsnacion%TYPE -- descrição da nacionalidade
                                   ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                                   ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                                   ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                   ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
  Programa : pc_busca_nacionalidades                            antiga: 
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Adriano - CECRED
  Data     : Junho/2017                           Ultima atualizacao:
    
  Dados referentes ao programa:
    
  Frequencia: -----
  Objetivo   : Pesquisa de dominios
    
  Alterações : 
  -------------------------------------------------------------------------------------------------------------*/    
                        
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
    
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
    
    --Inicializa as variaveis  
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
	  
    TELA_CADNAC.pc_busca_nacionalidades(pr_cdnacion => pr_cdnacion 
                                       ,pr_dsnacion => pr_dsnacion
                                       ,pr_nrregist => pr_nrregist
                                       ,pr_nriniseq => pr_nriniseq
                                       ,pr_xmllog   => pr_xmllog
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic 
                                       ,pr_retxml   => pr_retxml
                                       ,pr_nmdcampo => pr_nmdcampo
                                       ,pr_des_erro => pr_des_erro);
                                       
    IF pr_des_erro <> 'OK' THEN
     
      IF nvl(vr_cdcritic,0) = 0    AND
         TRIM(vr_dscritic) IS NULL THEN
      
        vr_dscritic := 'Erro na chamada da rotina TELA_CADNAC.pc_busca_nacionalidades.';
          
      END IF;
    
      RAISE vr_exc_erro;
      
    END IF;                                           
    
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na ZOOM0001.pc_busca_nacionalidades --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_nacionalidades;
  
  PROCEDURE pc_consulta_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                       ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                       ,pr_cdoedptl          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedptl          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoedttl          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedttl          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoeddoc          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoeddoc          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_cdoedcje          IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE                                       
                                       ,pr_nmoedcje          IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE
                                       ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                       ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                       ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
  Programa : pc_consulta_orgao_expedidor                            antiga: 
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Adriano - CECRED
  Data     : Junho/2017                           Ultima atualizacao:
    
  Dados referentes ao programa:
    
  Frequencia: -----
  Objetivo   : Rotina para buscar orgão expedidor
    
  Alterações : 26/09/2017 - Adicionado uma lista de valores para carregar orgao emissor (PRJ339 - Kelvin).
  -------------------------------------------------------------------------------------------------------------*/    
  --Variaveis auxiliares
  vr_cdorgao_expedidor tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
  vr_nmorgao_expedidor tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
                        
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
    
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
    
    --Inicializa as variaveis  
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
    
    IF TRIM(pr_cdorgao_expedidor) IS NOT NULL THEN
      vr_cdorgao_expedidor := pr_cdorgao_expedidor;    
    END IF;
    
    IF TRIM(pr_nmorgao_expedidor) IS NOT NULL THEN
      vr_nmorgao_expedidor := pr_nmorgao_expedidor;
    END IF;      
    
    IF TRIM(pr_cdoedptl) IS NOT NULL THEN
      vr_cdorgao_expedidor := pr_cdoedptl;    
    END IF;
    
    IF TRIM(pr_nmoedptl) IS NOT NULL THEN
      vr_nmorgao_expedidor := pr_nmoedptl;
    END IF;
    
    IF TRIM(pr_cdoedttl) IS NOT NULL THEN
      vr_cdorgao_expedidor := pr_cdoedttl;    
    END IF;
    
    IF TRIM(pr_nmoedttl) IS NOT NULL THEN
      vr_nmorgao_expedidor := pr_nmoedttl;
    END IF;
    
    IF TRIM(pr_cdoeddoc) IS NOT NULL THEN
      vr_cdorgao_expedidor := pr_cdoeddoc;    
    END IF;
    
    IF TRIM(pr_nmoeddoc) IS NOT NULL THEN
      vr_nmorgao_expedidor := pr_nmoeddoc;
    END IF;
    
    IF TRIM(pr_cdoedcje) IS NOT NULL THEN
      vr_cdorgao_expedidor := pr_cdoedcje;    
    END IF;
    
    IF TRIM(pr_nmoedcje) IS NOT NULL THEN
      vr_nmorgao_expedidor := pr_nmoedcje;
    END IF;
    
    TELA_CADORG.pc_consulta_orgao_expedidor(pr_cdorgao_expedidor => vr_cdorgao_expedidor 
                                           ,pr_nmorgao_expedidor => vr_nmorgao_expedidor
                                           ,pr_nrregist => pr_nrregist
                                           ,pr_nriniseq => pr_nriniseq
                                           ,pr_xmllog   => pr_xmllog
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic 
                                           ,pr_retxml   => pr_retxml
                                           ,pr_nmdcampo => pr_nmdcampo
                                           ,pr_des_erro => pr_des_erro);
                                       
    IF pr_des_erro <> 'OK' THEN
     
      IF nvl(vr_cdcritic,0) = 0    AND
         TRIM(vr_dscritic) IS NULL THEN
      
        vr_dscritic := 'Erro na chamada da rotina TELA_CADORG.pc_consulta_orgao_expedidor.';
          
      END IF;
    
      RAISE vr_exc_erro;
      
    END IF;                                           
    
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na ZOOM0001.pc_consulta_orgao_expedidor --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_consulta_orgao_expedidor;
  
  PROCEDURE pc_busca_cnae(pr_cdcnae    IN tbgen_cnae.cdcnae%TYPE -- código CNAE
                         ,pr_dscnae    IN tbgen_cnae.dscnae%TYPE -- descrição CNAE
                         ,pr_flserasa  IN tbgen_cnae.flserasa%TYPE --Negativar SERASA
                         ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                         ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                         ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                         ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                         ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                         ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                         ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                         ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
  Programa : pc_busca_cnae                                       antiga: 
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Adriano - CECRED
  Data     : Junho/2017                           Ultima atualizacao: 04/08/2017
    
  Dados referentes ao programa:
    
  Frequencia: -----
  Objetivo   : Pesquisa de códigod CNAE
    
  Alterações : 04/08/2017 - Ajuste para inclusao do parametros flserasa (Adriano).
  -------------------------------------------------------------------------------------------------------------*/    
                        
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
    
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
    
    --Inicializa as variaveis  
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
	  
    TELA_CADCNA.pc_busca_cnae(pr_cdcnae => pr_cdcnae
                             ,pr_dscnae => pr_dscnae
                             ,pr_flserasa => pr_flserasa
                             ,pr_nriniseq => pr_nriniseq
                             ,pr_nrregist => pr_nrregist
                             ,pr_xmllog   => pr_xmllog
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_retxml   => pr_retxml
                             ,pr_nmdcampo => pr_nmdcampo
                             ,pr_des_erro => pr_des_erro);
                                       
    IF pr_des_erro <> 'OK' THEN
     
      IF nvl(vr_cdcritic,0) = 0    AND
         TRIM(vr_dscritic) IS NULL THEN
      
        vr_dscritic := 'Erro na chamada da rotina TELA_CADCNA.pc_busca_cnae.';
          
      END IF;
    
      RAISE vr_exc_erro;
      
    END IF;                                           
    
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na ZOOM0001.pc_busca_cnae --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_cnae;

  PROCEDURE pc_busca_dominios(pr_idtipo_dominio     IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- código do dominio
                             ,pr_dstipo_dominio     IN tbrisco_dominio_tipo.dstipo_dominio%TYPE -- descrição do dominio
                             ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                             ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                             ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                             ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                             ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_dominios                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de dominios
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/    
                        
    CURSOR cr_tbrisco_dominio_tipo(pr_idtipo_dominio IN tbrisco_dominio_tipo.idtipo_dominio%TYPE
                                  ,pr_dstipo_dominio IN tbrisco_dominio_tipo.dstipo_dominio%TYPE) IS
    SELECT dominio.idtipo_dominio
          ,dominio.dstipo_dominio
          ,dominio.flpossui_subdominio
          ,dominio.cdtamanho_dominio
      FROM tbrisco_dominio_tipo dominio
     WHERE(pr_idtipo_dominio = 0
        OR dominio.idtipo_dominio = pr_idtipo_dominio)
       AND (TRIM(pr_dstipo_dominio) IS NULL
        OR UPPER(dominio.dstipo_dominio) LIKE '%' || UPPER(pr_dstipo_dominio) || '%');			
    rw_tbrisco_dominio_tipo cr_tbrisco_dominio_tipo%ROWTYPE;
  	
    CURSOR cr_tbrisco_dominio(pr_idtipo_dominio IN tbrisco_dominio.idtipo_dominio%TYPE)IS
    SELECT opcoes.iddominio
          ,opcoes.cddominio
          ,opcoes.dsdominio
          ,opcoes.cdsubdominio
          ,opcoes.dssubdominio
          ,opcoes.flregistro_padrao
          ,RISC0003.fn_valor_opcao_dominio(iddominio) dsdvalor
          ,RISC0003.fn_descri_opcao_dominio(iddominio) descricao
          ,row_number() over (partition by opcoes.cddominio order by opcoes.cddominio) nrseq
          ,COUNT(*) OVER (PARTITION BY opcoes.cddominio) qtdregis
      FROM tbrisco_dominio opcoes
     WHERE opcoes.idtipo_dominio = pr_idtipo_dominio
     ORDER BY opcoes.cddominio, opcoes.cdsubdominio; 
    rw_tbrisco_dominio cr_tbrisco_dominio%ROWTYPE;
	
    CURSOR cr_dominio(pr_dsdominio IN tbrisco_dominio.dsdominio%TYPE)IS                    
    SELECT tbrisco_dominio.cddominio
          ,tbrisco_dominio.dsdominio
          ,tbrisco_dominio.iddominio
      FROM tbrisco_dominio
     WHERE tbrisco_dominio.idtipo_dominio = 2
       AND tbrisco_dominio.dsdominio = pr_dsdominio;
    rw_dominio cr_dominio%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
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
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
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
	  
    OPEN cr_tbrisco_dominio_tipo(pr_idtipo_dominio => pr_idtipo_dominio
                                ,pr_dstipo_dominio => pr_dstipo_dominio);
									
	  FETCH cr_tbrisco_dominio_tipo INTO rw_tbrisco_dominio_tipo;
	  
	  IF cr_tbrisco_dominio_tipo%NOTFOUND THEN
	  
	    vr_dscritic := 'Dominio [' || pr_idtipo_dominio || '] solicitado nao existe.';
      RAISE vr_exc_erro; 
	  
    END IF;
	  
	  -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><dados/>');
  
    FOR rw_tbrisco_dominio IN cr_tbrisco_dominio(pr_idtipo_dominio => pr_idtipo_dominio) LOOP
      
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF; 
          
      --Numero Registros
      IF vr_nrregist > 0 THEN 
                    
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'dominio', pr_tag_cont => NULL, pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'idtipo_dominio', pr_tag_cont => rw_tbrisco_dominio_tipo.idtipo_dominio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dstipo_dominio', pr_tag_cont => rw_tbrisco_dominio.descricao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'iddominio', pr_tag_cont => rw_tbrisco_dominio.iddominio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cdsubdominio', pr_tag_cont => lpad(rw_tbrisco_dominio.cdsubdominio,rw_tbrisco_dominio_tipo.cdtamanho_dominio ,'0'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dssubdominio', pr_tag_cont => rw_tbrisco_dominio.dssubdominio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'flregistro_padrao', pr_tag_cont => rw_tbrisco_dominio.flregistro_padrao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdvalor', pr_tag_cont => rw_tbrisco_dominio.dsdvalor, pr_des_erro => vr_dscritic);
  		  
        IF rw_tbrisco_dominio.nrseq = 1 OR 
           vr_flgfirst                  THEN
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cddominio', pr_tag_cont => lpad(rw_tbrisco_dominio.cddominio,rw_tbrisco_dominio_tipo.cdtamanho_dominio,'0'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdominio', pr_tag_cont => rw_tbrisco_dominio.dsdominio, pr_des_erro => vr_dscritic);
        
        ELSE
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cddominio', pr_tag_cont => ' ', pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdominio', pr_tag_cont => ' ', pr_des_erro => vr_dscritic);
        
        END IF;
        
        IF pr_idtipo_dominio = 8 THEN
         
          OPEN cr_dominio(pr_dsdominio => risc0003.fn_descri_opcao_dominio(rw_tbrisco_dominio.iddominio));
          
          FETCH cr_dominio INTO rw_dominio;
          
          CLOSE cr_dominio;  
        
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'nrctacosif', pr_tag_cont => rw_dominio.cddominio, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsctacosif', pr_tag_cont => rw_dominio.dsdominio, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'iddominioctacosif', pr_tag_cont => rw_dominio.iddominio, pr_des_erro => vr_dscritic);

        END IF;
        
        vr_contador := vr_contador + 1;
        vr_flgfirst := FALSE;
        
      END IF;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
    END LOOP;       
                   
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'dados'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'             --> Nome do atributo
                             ,pr_atval => vr_qtregist    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'dados'            --> Nome da TAG XML
                             ,pr_atrib => 'flpossui_subdominio'             --> Nome do atributo
                             ,pr_atval => rw_tbrisco_dominio_tipo.flpossui_subdominio --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'dados'            --> Nome da TAG XML
                             ,pr_atrib => 'dstipo_dominio'             --> Nome do atributo
                             ,pr_atval => rw_tbrisco_dominio_tipo.dstipo_dominio --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na pc_busca_dominios --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_dominios;

  PROCEDURE pc_busca_descricao_dominios(pr_idtipo_dominio   IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- Tipo do dominio
                                       ,pr_idgarantia       IN VARCHAR2 --Código da garantia
                                       ,pr_idmodalidade     IN VARCHAR2 --Código da modalidade
                                       ,pr_idconta_cosif    IN VARCHAR2 --Código da conta cosif
                                       ,pr_idorigem_recurso IN VARCHAR2 --Código da origem recurso
                                       ,pr_idindexador      IN VARCHAR2 --Código da indexador
                                       ,pr_idvariacao_cambial IN VARCHAR2 --Código da variacao cambial
                                       ,pr_idnat_operacao     IN VARCHAR2 --Código da natureza operacao
                                       ,pr_idcaract_especial  IN VARCHAR2 --Código da caracteritica especial
                                       ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_dominios                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de dominios
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/    
    
    CURSOR cr_dominio(pr_dsdominio IN tbrisco_dominio.dsdominio%TYPE)IS                    
    SELECT tbrisco_dominio.cddominio
          ,tbrisco_dominio.dsdominio
		  ,tbrisco_dominio.iddominio
      FROM tbrisco_dominio
     WHERE tbrisco_dominio.idtipo_dominio = 2
       AND tbrisco_dominio.dsdominio = pr_dsdominio;
    rw_dominio cr_dominio%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
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
    
    --Variaveis Locais    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_contador INTEGER :=0;
    vr_descricao VARCHAR2(2000);
    vr_iddominio tbrisco_dominio.iddominio%TYPE:=0;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
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
      
    IF trim(pr_idgarantia) IS NOT NULL THEN
      
      vr_descricao:= pr_idgarantia;
    
    ELSIF TRIM(pr_idmodalidade) IS NOT NULL THEN
      
      vr_descricao:= pr_idmodalidade;
      
    ELSIF TRIM(pr_idconta_cosif) IS NOT NULL THEN
      
      vr_descricao:= pr_idconta_cosif;
      
    ELSIF TRIM(pr_idorigem_recurso) IS NOT NULL THEN
      
      vr_descricao:= pr_idorigem_recurso;
      
    ELSIF TRIM(pr_idindexador) IS NOT NULL THEN
      
      vr_descricao:= pr_idindexador;
      
    ELSIF TRIM(pr_idvariacao_cambial) IS NOT NULL THEN
      
      vr_descricao:= pr_idvariacao_cambial;
      
    ELSIF TRIM(pr_idnat_operacao) IS NOT NULL THEN
      
      vr_descricao:= pr_idnat_operacao;
      
    ELSIF TRIM(pr_idcaract_especial) IS NOT NULL THEN
      
      vr_descricao:= pr_idcaract_especial;
      
    END IF;
    
    vr_iddominio:= RISC0003.fn_busca_iddominio(pr_idtipo_dominio => pr_idtipo_dominio
                                              ,pr_dsvlrdom       => vr_descricao);
                                 
    IF trim(vr_descricao) IS NOT NULL AND
       vr_iddominio <> 0              THEN
       
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
                      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dominios', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominios', pr_posicao => 0, pr_tag_nova => 'dominio', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => 0, pr_tag_nova => 'iddominio', pr_tag_cont => vr_iddominio, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => 0, pr_tag_nova => 'descricao', pr_tag_cont => Risc0003.fn_descri_opcao_dominio(pr_iddominio => vr_iddominio), pr_des_erro => vr_dscritic);

      IF trim(pr_idgarantia)    IS NOT NULL OR 
         TRIM(pr_idconta_cosif) IS NOT NULL THEN
       
        OPEN cr_dominio(pr_dsdominio => risc0003.fn_descri_opcao_dominio(vr_iddominio));
        
        FETCH cr_dominio INTO rw_dominio;
        
        CLOSE cr_dominio;  
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => 0, pr_tag_nova => 'nrctacosif', pr_tag_cont => rw_dominio.cddominio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => 0, pr_tag_nova => 'dsctacosif', pr_tag_cont => rw_dominio.dsdominio, pr_des_erro => vr_dscritic);
		gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => 0, pr_tag_nova => 'iddominioctacosif', pr_tag_cont => rw_dominio.iddominio, pr_des_erro => vr_dscritic);

      END IF;
       
    END IF;
            
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na pc_busca_descricao_dominios --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_descricao_dominios;

  PROCEDURE pc_busca_descricao_associados(pr_cdcooper   IN crapcop.cdcooper%TYPE -- Código da cooperativa
                                         ,pr_nrdconta   IN crapass.nrdconta%TYPE -- Número da contaca especial
                                         ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                         ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_descricao_associados                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata
    Data     : Maio/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de descrição de associados
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/    
            
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.dsnivris
          ,crapass.nrcpfcgc
          ,crapass.inpessoa
      FROM crapass      
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;     
                               
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
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
    
    --Variaveis Locais    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_contador INTEGER :=0;
    vr_descricao VARCHAR2(2000);
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
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
            
    IF nvl(pr_cdcooper,0) = 0 THEN
    
      vr_dscritic:= 'Código da cooperativa inválido.';
      RAISE vr_exc_erro;
      
    END IF;
    
    IF nvl(pr_nrdconta,0) = 0 THEN
    
      vr_dscritic:= 'Conta inválida.';
      RAISE vr_exc_erro;
      
    END IF;
    
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
                   
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      
      --Fechar o cursor 
      CLOSE cr_crapass;
      
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9);
      RAISE vr_exc_erro;
          
    END IF;
    
    --Fechar o cursor 
    CLOSE cr_crapass;   
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
                      
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => 0, pr_tag_nova => 'info', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'info', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_crapass.nmprimtl, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'info', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, rw_crapass.inpessoa), pr_des_erro => vr_dscritic);
    
    --Se o dsnivris do cooperado for vazio deve retornar 'A' pois este valor será utilizado para setar o campo de classificação da tela MOVRGP como default 'A'.
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'info', pr_posicao => 0, pr_tag_nova => 'dsnivris', pr_tag_cont => nvl(trim(rw_crapass.dsnivris),'A'), pr_des_erro => vr_dscritic);

            
  EXCEPTION
    WHEN vr_exc_erro THEN        
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
      pr_dscritic:= 'Erro na pc_busca_descricao_associados --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_descricao_associados;
  
  PROCEDURE pc_busca_conta_cosif(pr_idgarantia     IN VARCHAR2       -->Código da garantia
                                ,pr_idtipo_dominio IN tbrisco_dominio_tipo.idtipo_dominio%TYPE -- código do dominio
                                ,pr_dstipo_dominio IN tbrisco_dominio_tipo.dstipo_dominio%TYPE -- descrição do dominio
                                ,pr_nrregist  IN INTEGER                 -- Quantidade de registros                            
                                ,pr_nriniseq  IN INTEGER                 -- Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2                -- XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            -- Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               -- Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               -- Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2)IS
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_conta_cosif                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata
    Data     : Junho/2017                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de conta cosif 
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/    
                        
    CURSOR cr_tbrisco_dominio_tipo(pr_idtipo_dominio IN tbrisco_dominio_tipo.idtipo_dominio%TYPE
                                  ,pr_dstipo_dominio IN tbrisco_dominio_tipo.dstipo_dominio%TYPE) IS
    SELECT dominio.idtipo_dominio
          ,dominio.dstipo_dominio
          ,dominio.flpossui_subdominio
          ,dominio.cdtamanho_dominio
      FROM tbrisco_dominio_tipo dominio
     WHERE(pr_idtipo_dominio = 0
        OR dominio.idtipo_dominio = pr_idtipo_dominio)
       AND (TRIM(pr_dstipo_dominio) IS NULL
        OR UPPER(dominio.dstipo_dominio) LIKE '%' || UPPER(pr_dstipo_dominio) || '%');			
    rw_tbrisco_dominio_tipo cr_tbrisco_dominio_tipo%ROWTYPE;
  	
    CURSOR cr_tbrisco_dominio(pr_idtipo_dominio IN tbrisco_dominio.idtipo_dominio%TYPE
                             ,pr_dsdominio      IN tbrisco_dominio.dsdominio%TYPE)IS
    SELECT opcoes.iddominio
          ,opcoes.cddominio
          ,opcoes.dsdominio
          ,opcoes.cdsubdominio
          ,opcoes.dssubdominio
          ,opcoes.flregistro_padrao
          ,RISC0003.fn_valor_opcao_dominio(iddominio) dsdvalor
          ,RISC0003.fn_descri_opcao_dominio(iddominio) descricao
          ,row_number() over (partition by opcoes.cddominio order by opcoes.cddominio) nrseq
          ,COUNT(*) OVER (PARTITION BY opcoes.cddominio) qtdregis
      FROM tbrisco_dominio opcoes
     WHERE opcoes.idtipo_dominio = pr_idtipo_dominio
       AND opcoes.dsdominio      = pr_dsdominio
     ORDER BY opcoes.cddominio, opcoes.cdsubdominio; 
    rw_tbrisco_dominio cr_tbrisco_dominio%ROWTYPE;
	
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
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
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nrregist INTEGER;
    vr_contador INTEGER :=0;
    vr_flgfirst BOOLEAN := TRUE;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
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
	  
      OPEN cr_tbrisco_dominio_tipo(pr_idtipo_dominio => pr_idtipo_dominio
                                  ,pr_dstipo_dominio => pr_dstipo_dominio);
  									
      FETCH cr_tbrisco_dominio_tipo INTO rw_tbrisco_dominio_tipo;
  	  
      IF cr_tbrisco_dominio_tipo%NOTFOUND THEN
  	  
        vr_dscritic := 'Dominio [' || pr_idtipo_dominio || '] solicitado nao existe.';
        RAISE vr_exc_erro; 
  	  
      END IF;
  	  
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><dados/>');
    
      FOR rw_tbrisco_dominio IN cr_tbrisco_dominio(pr_idtipo_dominio => pr_idtipo_dominio
                                                  ,pr_dsdominio      => risc0003.fn_descri_opcao_dominio(pr_idgarantia)) LOOP
        
        --Incrementar Quantidade Registros do Parametro
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
            
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
            
        --Numero Registros
        IF vr_nrregist > 0 THEN 
                      
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'dominio', pr_tag_cont => NULL, pr_des_erro => vr_dscritic); 
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'idtipo_dominio', pr_tag_cont => rw_tbrisco_dominio_tipo.idtipo_dominio, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dstipo_dominio', pr_tag_cont => rw_tbrisco_dominio.descricao, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'iddominio', pr_tag_cont => rw_tbrisco_dominio.iddominio, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cdsubdominio', pr_tag_cont => lpad(rw_tbrisco_dominio.cdsubdominio,rw_tbrisco_dominio_tipo.cdtamanho_dominio ,'0'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dssubdominio', pr_tag_cont => rw_tbrisco_dominio.dssubdominio, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'flregistro_padrao', pr_tag_cont => rw_tbrisco_dominio.flregistro_padrao, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdvalor', pr_tag_cont => rw_tbrisco_dominio.dsdvalor, pr_des_erro => vr_dscritic);
    		  
          IF rw_tbrisco_dominio.nrseq = 1 OR 
             vr_flgfirst                  THEN
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cddominio', pr_tag_cont => lpad(rw_tbrisco_dominio.cddominio,rw_tbrisco_dominio_tipo.cdtamanho_dominio,'0'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdominio', pr_tag_cont => rw_tbrisco_dominio.dsdominio, pr_des_erro => vr_dscritic);
          
          ELSE
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'cddominio', pr_tag_cont => ' ', pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dominio', pr_posicao => vr_contador, pr_tag_nova => 'dsdominio', pr_tag_cont => ' ', pr_des_erro => vr_dscritic);
          
          END IF;
          
          vr_contador := vr_contador + 1;
          vr_flgfirst := FALSE;
          
        END IF;
          
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
          
      END LOOP;       
                     
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'dados'            --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'             --> Nome do atributo
                               ,pr_atval => vr_qtregist    --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'dados'            --> Nome da TAG XML
                               ,pr_atrib => 'flpossui_subdominio'             --> Nome do atributo
                               ,pr_atval => rw_tbrisco_dominio_tipo.flpossui_subdominio --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'dados'            --> Nome da TAG XML
                               ,pr_atrib => 'dstipo_dominio'             --> Nome do atributo
                               ,pr_atval => rw_tbrisco_dominio_tipo.dstipo_dominio --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN        
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
        pr_dscritic:= 'Erro na ZOOM0001.pc_busca_conta_cosif --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
      
  END pc_busca_conta_cosif;

  
END ZOOM0001;
/
