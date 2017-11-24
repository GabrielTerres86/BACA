CREATE OR REPLACE PACKAGE CECRED.COBR0005 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0005
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2015.                   Ultima atualizacao: 13/03/2016 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referente a consulta e geracao de titulos de cobrança
  --
  --  Alteracoes: 13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
	--             					 	   para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
	--            					 	  (Andrei - RKAM).
  ---------------------------------------------------------------------------------------------------------------
  
  -- Definição de PL Table para armazenar os nomes das TAG´s do XML para iteração
  TYPE typ_reg_cob IS
    RECORD(cdcooper crapcob.cdcooper%TYPE
          ,nrdconta crapcob.nrdconta%TYPE
          ,idseqttl crapcob.idseqttl%TYPE
          ,nmprimtl crapass.nmprimtl%TYPE
          ,incobran VARCHAR2(1)
          ,nossonro VARCHAR2(17)
          ,nrctremp crapcob.nrctremp%TYPE
          ,nmdsacad crapcob.nmdsacad%TYPE
          ,nrinssac crapcob.nrinssac%TYPE
          ,cdtpinsc crapcob.cdtpinsc%TYPE
          ,dsendsac crapsab.dsendsac%TYPE
          ,complend crapsab.complend%TYPE
          ,nmbaisac crapsab.nmbaisac%TYPE
          ,nmcidsac crapsab.nmcidsac%TYPE
          ,cdufsaca crapcob.cdufsaca%TYPE
          ,nrcepsac crapcob.nrcepsac%TYPE
          ,cdbandoc crapcob.cdbandoc%TYPE
          ,dsbandig VARCHAR2(10) -- cód banco com DV
          ,nmdavali crapcob.nmdavali%TYPE
          ,nrinsava crapcob.nrinsava%TYPE
          ,cdtpinav crapcob.cdtpinav%TYPE
          ,nrcnvcob crapcob.nrcnvcob%TYPE
          ,nrcnvceb crapceb.nrcnvceb%TYPE
          ,nrdctabb crapcob.nrdctabb%TYPE
          ,nrcpfcgc crapass.nrcpfcgc%TYPE
          ,inpessoa crapass.inpessoa%TYPE
          ,nrdocmto crapcob.nrdocmto%TYPE
          ,dtmvtolt crapcob.dtmvtolt%TYPE
          ,dsdinstr crapcob.dsdinstr%TYPE
          ,dsdinst1 VARCHAR2(100)
          ,dsdinst2 VARCHAR2(100)
          ,dsdinst3 VARCHAR2(100)
          ,dsdinst4 VARCHAR2(100)
          ,dsdinst5 VARCHAR2(100)          
          ,dsinform crapcob.dsinform%TYPE
          ,dsinfor1 VARCHAR2(100)
          ,dsinfor2 VARCHAR2(100)
          ,dsinfor3 VARCHAR2(100)
          ,dsinfor4 VARCHAR2(100)
          ,dsinfor5 VARCHAR2(100)
          ,dslocpag VARCHAR2(100)
          ,dsavis2v VARCHAR2(100) -- aviso de 2a via
          ,dsagebnf VARCHAR2(50) -- Agencia/Codigo do Beneficiario (apenas no boleto)
          ,dspagad1 VARCHAR2(150)
          ,dspagad2 VARCHAR2(150)        
          ,dspagad3 VARCHAR2(150)  
          ,dssacava VARCHAR2(150)
          ,dsdoccop crapcob.dsdoccop%TYPE
          ,dtvencto crapcob.dtvencto%TYPE
          ,dtretcob crapcob.dtretcob%TYPE
          ,dtdpagto crapcob.dtdpagto%TYPE
          ,vltitulo crapcob.vltitulo%TYPE
          ,vldpagto crapcob.vldpagto%TYPE
          ,vldescto crapcob.vldescto%TYPE
          ,vlabatim crapcob.vlabatim%TYPE
          ,vltarifa crapcob.vltarifa%TYPE
          ,vlrmulta NUMBER(25,2)
          ,vlrjuros NUMBER(25,2)
          ,vloutdes NUMBER(25,2)
          ,vloutcre NUMBER(25,2)
          ,cdmensag crapcob.cdmensag%TYPE
          ,dsdpagto VARCHAR2(11)
          ,dsorgarq crapcco.dsorgarq%TYPE
          ,nrregist INTEGER
          ,idbaiexc INTEGER
          ,cdsituac VARCHAR2(1000)   /* Utilizado para a Internet */
          ,dssituac VARCHAR2(1000)   /* Utilizado para o Ayllos   */
          ,cddespec crapcob.cddespec%TYPE
          ,dsdespec VARCHAR2(1000)
          ,dtdocmto crapcob.dtdocmto%TYPE
          ,cdbanpag VARCHAR2(5)
          ,cdagepag VARCHAR2(4)
          ,flgdesco VARCHAR2(1000)
          ,dtelimin crapcob.dtelimin%TYPE
          ,cdcartei crapcob.cdcartei%TYPE
          ,nrvarcar crapcco.nrvarcar%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,flgregis VARCHAR2(1000)
          ,nrnosnum crapcob.nrnosnum%TYPE
          ,dsstaabr VARCHAR2(1000)
          ,dsstacom VARCHAR2(1000)
          ,flgaceit VARCHAR2(1000)
          ,dtsitcrt DATE
          ,agencidv VARCHAR2(1000)
          ,tpjurmor INTEGER
          ,tpdmulta INTEGER
          ,flgdprot crapcob.flgdprot%TYPE
          ,qtdiaprt crapcob.qtdiaprt%TYPE
          ,indiaprt crapcob.indiaprt%TYPE
          ,insitpro crapcob.insitpro%TYPE
          ,flgcbdda VARCHAR2(1)
          ,cdocorre INTEGER
          ,dsocorre VARCHAR2(1000)
          ,cdmotivo VARCHAR2(1000)
          ,dsmotivo VARCHAR2(1000)
          ,dtocorre DATE
          ,dtdbaixa DATE
          ,vldocmto NUMBER
          ,vlmormul NUMBER
          ,dtvctori DATE
          ,dscjuros VARCHAR2(1000)
          ,dscmulta VARCHAR2(1000)
          ,dscdscto VARCHAR2(1000)
          ,dsinssac VARCHAR2(1000)
          ,vldesabt NUMBER
          ,vljurmul NUMBER
          ,dsorigem VARCHAR2(1000)
          ,dtcredit DATE
          ,nrborder craptdb.nrborder%TYPE
          ,vllimtit NUMBER
          ,vltdscti NUMBER
          ,nrctrlim craptdb.nrctrlim%TYPE
          ,nrctrlim_ativo craptdb.nrctrlim%TYPE
          ,dsdemail VARCHAR2(5000)
          ,flgemail NUMBER
          ,inemiten crapcob.inemiten%TYPE
          ,dsemiten VARCHAR2(1000)
          ,dsemitnt VARCHAR2(1000)
          ,flgcarne NUMBER
          ,cdbarras VARCHAR2(44)
          ,lindigit VARCHAR2(60)
          ,rowidcob ROWID);

  -- Declaração do tipo para a PL Table de nomes das TAG´s
  TYPE typ_tab_cob IS TABLE OF typ_reg_cob INDEX BY PLS_INTEGER;  
    
  PROCEDURE pc_calc_codigo_barras ( pr_dtvencto IN DATE
                                   ,pr_cdbandoc IN INTEGER
                                   ,pr_vltitulo IN crapcob.vltitulo%TYPE
                                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                   ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
                                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                   ,pr_cdcartei IN crapcob.cdcartei%TYPE
                                   ,pr_cdbarras OUT VARCHAR2);  
                                   
  PROCEDURE pc_calc_linha_digitavel(pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2);                                   
  
  PROCEDURE pc_gera_pedido_remessa( pr_rowidcob IN ROWID
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_gerar_titulo_cobranca(pr_cdcooper IN crapcob.cdcooper%TYPE /* cooperativa */
                                    ,pr_nrdconta IN crapcob.nrdconta%TYPE /* conta do cooperado */
                                    ,pr_idseqttl IN crapcob.idseqttl%TYPE DEFAULT 1 /* titular que gerou o boleto */
                                    ,pr_nrcnvcob IN crapcco.nrconven%TYPE /* número do convenio */
                                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL /* numero do documento (ou boleto) */
                                    ,pr_flgregis IN crapcob.flgregis%TYPE DEFAULT 1 /* cobranca registrada */
                                    ,pr_flgsacad IN INTEGER               DEFAULT 0 /* se o sacado eh dda ou nao */
                                    ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT 0 /* contrato de empréstimo */
                                    ,pr_nrpartit IN INTEGER DEFAULT 0     /* numero da parcela do titulo quando tiver */
                                    ,pr_inemiten IN crapcob.inemiten%TYPE /* Emitente */
                                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE /* código do banco */
                                    ,pr_cdcartei IN crapcob.cdcartei%TYPE /* código da carteira */
                                    ,pr_cddespec IN crapcob.cddespec%TYPE /* espécie de documento */
                                    ,pr_nrctasac IN crapcob.nrctasac%TYPE DEFAULT 0 /* numero da conta do sacado se houver */
                                    ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE /* tipo de inscrição do sacado 1=CPF, 2=CNPJ*/
                                    ,pr_nrinssac IN crapcob.nrinssac%TYPE /* nr de inscrição do sacado */
                                    ,pr_nmdavali IN crapcob.nmdavali%TYPE DEFAULT ' ' /* nome do avalista */
                                    ,pr_cdtpinav IN crapcob.cdtpinav%TYPE DEFAULT 0 /* codigo tipo sacador/avalista */
                                    ,pr_nrinsava IN crapcob.nrinsava%TYPE DEFAULT 0 /* nr da inscrição do sacador/avalista */
                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE /* data do movimento */
                                    ,pr_dtdocmto IN crapcob.dtdocmto%TYPE /* data do documento */
                                    ,pr_dtvencto IN crapcob.dtvencto%TYPE /* data do vencimento */
                                    ,pr_vldescto IN crapcob.vldescto%TYPE DEFAULT 0 /* vlr do desconto */
                                    ,pr_vlabatim IN crapcob.vlabatim%TYPE DEFAULT 0 /* vlr do abatimento */
                                    ,pr_cdmensag IN crapcob.cdmensag%TYPE /* tipo de desconto */
                                    ,pr_dsdoccop IN crapcob.dsdoccop%TYPE /* descrição do documento */
                                    ,pr_vltitulo IN crapcob.vltitulo%TYPE /* valor do título */
                                    ,pr_dsinform IN crapcob.dsinform%TYPE DEFAULT '____' /* informações */
                                    ,pr_dsdinstr IN crapcob.dsdinstr%TYPE DEFAULT '____' /* instruções */
                                    ,pr_flgdprot IN crapcob.flgdprot%TYPE DEFAULT 0 /* protestar 0 = Não, 1 = Sim */
                                    ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE DEFAULT 0 /* qtd de dias para protesto */
                                    ,pr_indiaprt IN crapcob.indiaprt%TYPE DEFAULT 3 /* 1= Útil, 2=Corridos, 3= isento */
                                    ,pr_vljurdia IN crapcob.vljurdia%TYPE DEFAULT 0 /* vlr juros ao dia */
                                    ,pr_vlrmulta IN crapcob.vlrmulta%TYPE DEFAULT 0 /* vlr de multa */
                                    ,pr_flgaceit IN crapcob.flgaceit%TYPE DEFAULT 0 /* aceite */
                                    ,pr_tpjurmor IN crapcob.tpjurmor%TYPE DEFAULT 3 /* tipo de juros de mora 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
                                    ,pr_tpdmulta IN crapcob.tpdmulta%TYPE DEFAULT 3 /* tipo de multa 1=vlr "R$", 2= "%" , 3=isento */
                                    ,pr_tpemitir IN INTEGER               DEFAULT 1 /* tipo de emissão = 1 = Boleto / 2 = Carnê */
                                    ,pr_nrremass IN crapret.nrremass%TYPE DEFAULT 0 /* Numero da remessa do arquivo */
                                    ,pr_cdoperad IN crapcob.cdoperad%TYPE /* código do operador */
                                    ,pr_cdcritic OUT INTEGER              /* código de critica (se houver);*/
                                    ,pr_dscritic OUT VARCHAR2             /* descrição da crítica (se houver);*/
                                    ,pr_tab_cob  OUT typ_tab_cob);        /* record do boleto*/
             
  PROCEDURE pc_buscar_titulo_cobranca (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                                      ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo                                      
                                      ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                                      ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Numero do titulo                                      
                                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                                      ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                                      ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                                      ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                                      ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                                      ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                                      ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                                      ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                                      ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                                      ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                                      ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                                      ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                                      ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                                      ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                                      ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                                      ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                                      ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                                      ,pr_fldescon IN INTEGER DEFAULT NULL               --> Se titulo é descontado
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Cód. Operador
                                      ,pr_nriniseq IN INTEGER                            --> Registro inicial da listagem
                                      ,pr_nrregist IN INTEGER                            --> Numero de registros p/ paginaca
                                      ,pr_dtmvtolt IN DATE DEFAULT NULL                  --> Data do movimento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Cód. da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE             --> Descrição da crítica
                                      ,pr_tab_cob  OUT typ_tab_cob);                     /* record do boleto*/                                                              

  --> Rotina para atualizar nome do remetente de SMS de cobrança
  PROCEDURE pc_atualizar_remetente_sms ( pr_cdcooper IN  crapcop.cdcooper%TYPE                  --> Codigo da cooperativa
                                        ,pr_nrdconta IN  crapass.nrdconta%TYPE          --> Numero da conta
                                        ,pr_idcontrato IN tbcobran_sms_contrato.idcontrato%TYPE --> Indicador unico do contrato
                                        ,pr_tpnome_emissao IN OUT tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                        ,pr_nmemissao_sms  IN OUT tbcobran_sms_contrato.nmemissao_sms%TYPE --> nome na emissao do boleto
                                        ,pr_dscritic OUT VARCHAR2);                     --> Retorno de critica
                                    
--> Rotina para atualizar nome do remetente de SMS de cobrança  - Chamada ayllos Web
  PROCEDURE pc_atualizar_remetente_sms_web (  pr_nrdconta       IN crapass.nrdconta%TYPE                     --> Numero de conta do cooperado                                     
                                             ,pr_idcontrato     IN tbcobran_sms_contrato.idcontrato%TYPE     --> Indicador unico do contrato
                                             ,pr_tpnome_emissao IN tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                             ,pr_nmemissao_sms  IN tbcobran_sms_contrato.nmemissao_sms%TYPE  --> nome na emissao do boleto
                                             ,pr_xmllog         IN VARCHAR2               --> XML com informacoes de LOG
                                             ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                             ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                             ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                             ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                             ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
                                         
  --> Rotina para verificar se permite enviar linha digitavel na SMS
  PROCEDURE pc_verif_permite_lindigi (pr_cdcooper IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                     ,pr_flglinha_digitavel OUT tbcobran_sms_param_coop.flglinha_digitavel%TYPE --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                     ,pr_dscritic            OUT VARCHAR2);           --> Retorno de critica                                    
                                     
  --> Rotina responsavel por gerar o relatorio analitico de envio de SMS
  PROCEDURE pc_relat_anali_envio_sms (pr_cdcooper  IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                     ,pr_nrdconta  IN  crapass.nrdconta%TYPE          --> Numer de conta do cooperado
                                     ,pr_dtiniper  IN  DATE                           --> Data inicio do periodo para relatorio
                                     ,pr_dtfimper  IN  DATE                           --> Data fim do periodo para relatorio
                                     ,pr_idorigem  IN INTEGER                         --> Codigo de origem do sistema
                                     ,pr_dsiduser   IN VARCHAR2                       --> id do usuario
                                     ,pr_instatus  IN INTEGER DEFAULT 0               --> Status do SMS (0 - para todos)
                                     ,pr_tppacote  IN INTEGER DEFAULT 0               --> Tipo de pacote(1-pacote,2-individual,0-Todos)
                                     --------->> OUT <<-----------
                                     ,pr_nmarqpdf OUT  VARCHAR2                       --> Retorna o nome do relatorio gerado
                                     ,pr_dsxmlrel OUT CLOB                            --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                     ,pr_cdcritic OUT NUMBER                          --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                     ,pr_dscritic OUT VARCHAR2);                      --> Retorno de critica                                     

  --> Rotina responsavel por gerar o relatorio analitico de envio de SMS - Chamada ayllos Web
  PROCEDURE pc_relat_anali_envio_sms_web (pr_nrdconta   IN  crapass.nrdconta%TYPE --> Numer de conta do cooperado                                     
                                         ,pr_dtiniper   IN VARCHAR2               --> Data inicio do periodo para relatorio
                                         ,pr_dtfimper   IN VARCHAR2               --> Data fim do periodo para relatorio
                                         ,pr_dsiduser   IN VARCHAR2               --> id do usuario
                                         ,pr_instatus   IN INTEGER DEFAULT 0      --> Status do SMS (0 - para todos)
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo    
                                                                          
  --> Rotina para verificar se serviço de SMS.
  PROCEDURE pc_verifar_serv_sms(pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                               ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                               ,pr_nmdatela      IN craptel.nmdatela%TYPE  --> Nome da tela
                               ,pr_idorigem      IN INTEGER                --> Indicador de sistema origem
                               -----> OUT <----                                                                 
                               ,pr_idcontrato OUT tbcobran_sms_contrato.idcontrato%TYPE --> Retornar Numero do contratro ativo
                               ,pr_flsitsms OUT  INTEGER                   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                               ,pr_dsalerta OUT  VARCHAR2                  --> Retorna alerta para o cooperado
                               ,pr_cdcritic OUT  INTEGER                   --> Retorna codigo de critica
                               ,pr_dscritic OUT  VARCHAR2);                --> Retorno de critica

--> Rotina para verificar se serviço de SMS.
  PROCEDURE pc_verifar_serv_sms_web ( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                     ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                     ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                     ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

  --> Buscar informações dos contratos de serviço de SMS
PROCEDURE pc_ret_dados_serv_sms (pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                                  ,pr_nmdatela      IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_idorigem      IN INTEGER                --> Indicador de sistema origem
                                  -----> OUT <----                                   
                                  ,pr_nmprintl     OUT crapass.nmprimtl%TYPE  --> Nome principal do cooperado
                                  ,pr_nmfansia     OUT crapjur.nmfansia%TYPE  --> Nome fantasia do cooperado
                                  ,pr_tpnmemis     OUT tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do SMS
                                  ,pr_nmemisms     OUT tbcobran_sms_contrato.nmemissao_sms%TYPE  --> Nome na emissao do SMS - Outro
                                  ,pr_flgativo     OUT INTEGER                                    --> Indicador de ativo
                                  ,pr_idpacote     OUT tbcobran_sms_contrato.idpacote%TYPE   --> identificador do pacote
                                  ,pr_dspacote     OUT tbcobran_sms_pacotes.dspacote%TYPE    --> Descrição do pacote
                                  ,pr_dhadesao     OUT tbcobran_sms_contrato.dhadesao%TYPE   --> Data hora de adesao
                                  ,pr_idcontrato   OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato
                                  ,pr_vltarifa     OUT crapfco.vltarifa%TYPE                 --> Valor da tarifa
                                  ,pr_flsitsms     OUT INTEGER                               --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                                  ,pr_dsalerta     OUT VARCHAR2                              --> Retorna alerta para o cooperado
                                  ,pr_qtsmspct     OUT tbcobran_sms_contrato.qtdsms_pacote%TYPE --> Retorna quantidade de sms contratada do pacote
                                  ,pr_qtsmsusd     OUT tbcobran_sms_contrato.qtdsms_usados%TYPE --> Retorna quantidade de sms ja utilizadas do pacote
                                  ,pr_dsmsgsemlinddig OUT VARCHAR2                                  
                                  ,pr_dsmsgcomlinddig OUT VARCHAR2                                  
                                  ,pr_cdcritic     OUT  INTEGER                 --> Retorna codigo de critica
                                  ,pr_dscritic     OUT  VARCHAR2);     
                                  
  --> Buscar informações dos contratos de serviço de SMS - Web
  PROCEDURE pc_ret_dados_serv_sms_web ( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                             ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                             ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                             ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                             ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                             ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                             ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
 
  --> Rotina para geração do contrato de SMS
  PROCEDURE pc_gera_contrato_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                 ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                 ,pr_inaprpen    IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                 ,pr_idpacote    IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS
                                 ,pr_tpnmemis    IN tbcobran_sms_contrato.tpnome_emissao%TYPE DEFAULT 1   --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                 ,pr_nmemissa    IN tbcobran_sms_contrato.nmemissao_sms%TYPE DEFAULT NULL --> Nome caso selecionado Outro
                                 -----> OUT <----                                   
                                 ,pr_idcontrato OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 ,pr_dsretorn   OUT  VARCHAR2              --> Mensagem de retorno
                                 ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                 ,pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica
                                 
  --> Rotina para geração do contrato de SMS
  PROCEDURE pc_gera_contrato_sms_web (  pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                       ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                       ,pr_inaprpen   IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                       ,pr_idpacote   IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
                                       
  --> Rotina para canlemaneto do contrato de SMS
  PROCEDURE pc_cancel_contrato_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                   ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                   ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                   ,pr_idorigem    IN INTEGER                --> id origem 
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                   ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                   ,pr_inaprpen    IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                   -----> OUT <----                                   
                                   ,pr_dsretorn   OUT  VARCHAR2                --> Mensagem de retorno             
                                   ,pr_cdcritic   OUT  INTEGER                 --> Retorna codigo de critica
                                   ,pr_dscritic   OUT  VARCHAR2);              --> Retorno de critica
  
  --> Rotina para canlemaneto do contrato de SMS
  PROCEDURE pc_cancel_contrato_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular 
                                       ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS                                       
                                       ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);             --> Erros do processo

   --> Rotina para impressao do contrato de servico de SMS
   PROCEDURE pc_imprim_contrato_sms ( pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                     ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                     ,pr_idorigem    IN INTEGER                --> id origem 
                                     ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                     ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                     ,pr_dsiduser    IN VARCHAR2               --> id do usuario
                                     -----> OUT <----                                   
                                     ,pr_nmarqpdf   OUT VARCHAR2               --> Retorna o nome do relatorio gerado
                                     ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                     ,pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica

  --> Rotina para impressao do contrato de servico de SMS - Web
  PROCEDURE pc_imprim_contrato_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                       ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                       ,pr_dsiduser    IN VARCHAR2               --> id do usuario                                       
                                       ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);             --> Erros do processo
                                       
  --> Rotina para impressao do termo de cancelamento de servico de SMS
  PROCEDURE pc_imprim_cancel_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                 ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                 ,pr_dsiduser    IN VARCHAR2               --> id do usuario
                                 -----> OUT <----                                   
                                 ,pr_nmarqpdf   OUT VARCHAR2               --> Retorna o nome do relatorio gerado
                                 ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                 ,pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica                                       
                                 

  --> Rotina para impressao do termo de cancelamento de servico de SMS - Chamada ayllos Web
  PROCEDURE pc_imprim_cancel_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                     ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                     ,pr_dsiduser    IN VARCHAR2               --> id do usuario                                       
                                     ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                     ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                     ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2);             --> Erros do processo                                 
                                     
   --> Rotina para identificar os SMSs de cobrança pendente de envio e realizar o envio
  PROCEDURE pc_verifica_sms_a_enviar (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     -----> OUT <----                                   
                                     ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                     ,pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica                                     

  --> Enviar lote de SMS para o Aymaru
  PROCEDURE pc_enviar_lote_SMS ( pr_idlotsms  IN tbgen_sms_lote.idlote_sms%TYPE
                                ,pr_dscritic OUT VARCHAR2 
                                ,pr_cdcritic OUT INTEGER );                                     

  --> Rotina para atualizar situação do lote de SMS de cobrança
  PROCEDURE pc_atualiza_status_lote ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,  --> Codigo do lote de SMS
                                      pr_idsituacao IN tbgen_sms_lote.idsituacao%TYPE); --> Código da Situação

  --> Rotina para atualizar situação do SMS
  PROCEDURE pc_atualiza_status_msg ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,     --> Numer do lote de SMS
                                     pr_idsms      IN tbgen_sms_controle.idsms%TYPE,      --> Identificador do SMS
                                     pr_cdretorn   IN tbgen_sms_controle.cdretorno%TYPE,  --> Código de retor
                                     pr_dsretorn   IN tbgen_sms_controle.dsdetalhe_retorno%TYPE, --> Detalhe do retorno
                                     pr_dscritic  OUT VARCHAR2);
                                                                           
  --> Rotina para atualizar situação do SMS - chamada SOA
  PROCEDURE pc_atualiza_status_msg_soa ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,  --> Numer do lote de SMS
                                         pr_xmlrequi   IN xmltype);                        --> Requeisicao xml
 
  --> Rotina para validar a criação do contrato de sms de cobrança
  PROCEDURE pc_valida_contrato_sms( pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_cdagenci      IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                   ,pr_nrdcaixa      IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nmdatela      IN craptel.nmdatela%TYPE  --> Nome da tela
                                   ,pr_idorigem      IN INTEGER                --> Identificador sistema origem
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                                   ,pr_idpacote      IN tbcobran_sms_pacotes.idpacote%TYPE --> Id do pacote de sms de cobrança
                                   -----> OUT <----                                                                                                      
                                   ,pr_flpossnh OUT  INTEGER                   --> Retornar se cooperado possui senha de Internet (1-Ok, 0-NOK)
                                   ,pr_cdcritic OUT  INTEGER                   --> Retorna codigo de critica
                                   ,pr_dscritic OUT  VARCHAR2);                --> Retorno de critica

  --> Rotina para validar a criação do contrato de sms de cobrança - Chamada ayllos Web
  PROCEDURE pc_valida_contrato_sms_web (pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numero de conta do cooperado
                                       ,pr_idpacote   IN INTEGER                --> Numero do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
                                       
  --> Rotina para lançar tarifa do pacote de SMS
  PROCEDURE pc_gerar_tarifa_pacote (pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica

  --> Rotina para verificar e renovar os contratos/pacote de SMS
  PROCEDURE pc_verifica_renovacao_pacote (pr_dscritic   OUT  VARCHAR2);      --> Retorno de critica                                   
                                         
                                         
  --> Rotina para realizar a troca do pacote de SMS
  PROCEDURE pc_trocar_pacote_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado                             
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao                             
                                 ,pr_idpacote    IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS                                 ,
                                 ,pr_idctratu    IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 -----> OUT <----                                   
                                 ,pr_idctrnov   OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 ,pr_dsretorn   OUT VARCHAR2               --> Mensagem de retorno             
                                 ,pr_cdcritic   OUT INTEGER                --> Retorna codigo de critica
                                 ,pr_dscritic   OUT VARCHAR2);             --> Retorno de critica
                                                                          
  --> Rotina para realizar a troca do pacote de SMS - Chamada ayllos Web
  PROCEDURE pc_trocar_pacote_sms_web (  pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numero de conta do cooperado
                                       ,pr_idcontrato IN INTEGER                --> indicador do contrato de serviço de SMS de Cobrança
                                       ,pr_idpacote   IN INTEGER                --> Numero do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) ;            --> Erros do processo

  --> Rotina para cobrar tarifas das SMSs enviadas 
  PROCEDURE pc_gera_tarifa_sms_enviados (pr_cdcooper    IN  INTEGER               --> Codigo da cooperativa                                         
                                        ,pr_dscritic   OUT  VARCHAR2);            --> Retorno de critica

  --> Rotina para verificar se é para apresentar popup do serviço de SMS para o cooperado
  PROCEDURE pc_verifar_oferta_sms(pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado                                 
                                 -----> OUT <----                                                                                                  
                                 ,pr_flofesms OUT  INTEGER                   --> Retorna se deve exibir oferta de SMS
                                 ,pr_dsmensag OUT  VARCHAR2                  --> Retorna alerta para o cooperado
                                 ,pr_dscritic OUT  VARCHAR2);                --> Retorno de critica
                                 
                                 
--> Rotina responsavel por gerar o relatorio de resumo de envio de SMS
  PROCEDURE pc_relat_resumo_envio_sms (pr_cdcooper  IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                      ,pr_nrdconta  IN  crapass.nrdconta%TYPE          --> Numer de conta do cooperado                                     
                                      ,pr_dtiniper  IN  DATE                           --> Data inicio do periodo para relatorio
                                      ,pr_dtfimper  IN  DATE                           --> Data fim do periodo para relatorio
                                      ,pr_idorigem  IN INTEGER                         --> Codigo de origem do sistema
                                      ,pr_dsiduser   IN VARCHAR2                       --> id do usuario
                                      ,pr_instatus  IN INTEGER DEFAULT 0               --> Status do SMS (0 - para todos)
                                      --------->> OUT <<-----------
                                      ,pr_nmarqpdf OUT VARCHAR2                        --> Retorna o nome do relatorio gerado
                                      ,pr_dsxmlrel OUT CLOB                            --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                      ,pr_cdcritic OUT NUMBER                          --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                      ,pr_dscritic OUT VARCHAR2);                                    
END cobr0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0005 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0005
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2015.                   Ultima atualizacao: 22/11/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referente a consulta e geracao de titulos de cobrança
  --
  --  Alteracoes: 13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
	--			      		       	   para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
	--       			    		 	    (Andrei - RKAM).
  --
  --              22/11/2016 - #554528 Melhoria do dscritic (inclusão dos parâmetros e seus valores) na 
  --                           exception vr_exc_semresultado (pc_buscar_titulo_cobranca) para o caso de a 
  --                           mesma voltar a ocorrer (Carlos)
  ---------------------------------------------------------------------------------------------------------------
    
  PROCEDURE pc_gera_pedido_remessa( pr_rowidcob IN ROWID
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_gera_pedido_remessa
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Gerar registro de remessa para o BB

     Alteracoes: ----

  ............................................................................ */      
                                   

      vr_nrremret crapret.nrremret%TYPE;
      vr_nrseqreg crapret.nrseqreg%TYPE;
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(100);
      
      CURSOR cr_crapcob IS
        SELECT cob.*, cob.rowid 
          FROM crapcob cob
         WHERE cob.rowid = pr_rowidcob;
         
      rw_cob cr_crapcob%ROWTYPE;
      vr_ret ROWID;
      
      vr_exc_erro EXCEPTION;
           
  BEGIN    

    BEGIN
      
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_cob;
      
      IF cr_crapcob%NOTFOUND THEN
         RAISE vr_exc_erro;
      END IF;
      
      CLOSE cr_crapcob;
          
      paga0001.pc_prep_remessa_banco( pr_cdcooper => rw_cob.cdcooper
                                     ,pr_nrcnvcob => rw_cob.nrcnvcob
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nrremret => vr_nrremret
                                    , pr_rowid_ret => vr_ret
                                     ,pr_nrseqreg => vr_nrseqreg
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                                     

      vr_nrseqreg := vr_nrseqreg + 1;
      
      paga0001.pc_cria_tab_remessa( pr_idregcob => rw_cob.rowid
                                   ,pr_nrremret => vr_nrremret
                                   ,pr_nrseqreg => vr_nrseqreg
                                   ,pr_cdocorre => 1 -- remessa
                                   ,pr_cdmotivo => '' -- sem motivo
                                   ,pr_dtdprorr => NULL -- sem prorrogacao
                                   ,pr_vlabatim => 0 -- sem abatimeto
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                 
    EXCEPTION
       WHEN vr_exc_erro THEN
         NULL;  
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro nao tratado na COBR0005.pc_gera_pedido_remessa: ' || SQLERRM;
    END;


  END;
  
  PROCEDURE pc_calc_codigo_barras ( pr_dtvencto IN DATE
                                   ,pr_cdbandoc IN INTEGER
                                   ,pr_vltitulo IN crapcob.vltitulo%TYPE
                                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                                   ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE DEFAULT 0
                                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                   ,pr_cdcartei IN crapcob.cdcartei%TYPE
                                   ,pr_cdbarras OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_calc_codigo_barras
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Calcular o código de barras a partir dos parâmetros básicos

     Alteracoes: ----

  ............................................................................ */      
                                   

    vr_aux VARCHAR2(100);
    vr_dtini  DATE := to_date('07/10/1997','DD/MM/RRRR');
    vr_dtnovo DATE := to_date('22/02/2025','DD/MM/RRRR');
    vr_ftvencto INTEGER;
    vr_flgcbok BOOLEAN;
    
  BEGIN

      IF pr_dtvencto >= to_date('22/02/2025','DD/MM/RRRR') THEN
         vr_ftvencto := (trunc(pr_dtvencto) - trunc(vr_dtnovo)) + 1000;
      ELSE
         vr_ftvencto := (trunc(pr_dtvencto) - trunc(vr_dtini));
      END IF;

      IF length(pr_nrcnvcob) <= 6 THEN
        vr_aux := to_char(pr_cdbandoc,'fm000')
                               || '9' /* moeda */
                               || '1' /* nao alterar - constante */
                               || to_char(vr_ftvencto, 'fm0000') 
                               || to_char(pr_vltitulo * 100, 'fm0000000000')
                               || to_char(pr_nrcnvcob, 'fm000000')
                               || lpad(pr_nrdconta, 8, '0')
                               || lpad(pr_nrdocmto, 9, '0')                               
                               || to_char(pr_cdcartei, 'fm00');
      ELSIF length(pr_nrcnvcob) = 7 THEN
        vr_aux := to_char(pr_cdbandoc,'fm000')
                               || '9' /* moeda */
                               || '1' /* nao alterar - constante */
                               || to_char(vr_ftvencto, 'fm0000') 
                               || to_char(pr_vltitulo * 100, 'fm0000000000')
                               || '000000'
                               || lpad(pr_nrcnvcob, 7, '0')
                               || lpad(pr_nrcnvceb, 4, '0')
                               || lpad(pr_nrdocmto, 6, '0')
                               || to_char(pr_cdcartei, 'fm00');        
      END IF;        

      -- Calcular Digito Código Barras
      CXON0000.pc_calc_digito_titulo(pr_valor   => vr_aux --> Valor Calculado
                                    ,pr_retorno => vr_flgcbok); --> Retorno digito correto
      -- Retornar Codigo Barras
      pr_cdbarras := gene0002.fn_mask(vr_aux
                                     ,'99999999999999999999999999999999999999999999');    
    
  END;
  
  PROCEDURE pc_calc_linha_digitavel(pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2) IS
                                   
/* ............................................................................

     Programa: pc_calc_linha_digitavel
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Calcular linha digitavel do código de barras

     Alteracoes: ----

  ............................................................................ */      
                                   
                                   
  BEGIN

    DECLARE    
      -- Linha Digitavel
      vr_titulo1 VARCHAR2(100);
      vr_titulo2 VARCHAR2(100);
      vr_titulo3 VARCHAR2(100);
      vr_titulo4 VARCHAR2(100);
      vr_titulo5 VARCHAR2(100);    
      
      vr_nro_digito     INTEGER;
      vr_retorno BOOLEAN;      
    
    BEGIN
      vr_titulo1 := substr(pr_cdbarras,01,04) ||
                    substr(pr_cdbarras,20,01) ||
                    substr(pr_cdbarras,21,04) || '0';
      vr_titulo2 := substr(pr_cdbarras,25,10) || '0';
      vr_titulo3 := substr(pr_cdbarras,35,10) || '0';
      vr_titulo4 := substr(pr_cdbarras,05,01);
      vr_titulo5 := substr(pr_cdbarras,06,14);
       
      -- Calcula digito - Primeiro campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo1    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE          --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto
          
      -- Calcula digito - Segunda campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo2    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE         --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto
                                    
      -- Calcula digito - Terceira campo da linha digitavel
      CXON0000.pc_calc_digito_verif (pr_valor        => vr_titulo3    --> Valor Calculado
                                    ,pr_valida_zeros => FALSE         --> Validar Zeros
                                    ,pr_nro_digito   => vr_nro_digito --> Digito Verificador
                                    ,pr_retorno      => vr_retorno);  --> Retorno digito correto                              
                                    
      pr_lindigit := gene0002.fn_mask(gene0002.fn_mask(vr_titulo1, '9999999999'),'99999.99999')   || ' ' ||
                     gene0002.fn_mask(gene0002.fn_mask(vr_titulo2, '99999999999'),'99999.999999') || ' ' ||
                     gene0002.fn_mask(gene0002.fn_mask(vr_titulo3, '99999999999'),'99999.999999') || ' ' ||
                     gene0002.fn_mask(vr_titulo4,'9')                                             || ' ' ||     
                     gene0002.fn_mask(vr_titulo5, '99999999999999');                                  
    END;  
    
  END pc_calc_linha_digitavel;                                   
  
  
  -- Gera título de cobrança
  PROCEDURE pc_gerar_titulo_cobranca(pr_cdcooper IN crapcob.cdcooper%TYPE /* cooperativa */
                                    ,pr_nrdconta IN crapcob.nrdconta%TYPE /* conta do cooperado */
                                    ,pr_idseqttl IN crapcob.idseqttl%TYPE DEFAULT 1 /* titular que gerou o boleto */
                                    ,pr_nrcnvcob IN crapcco.nrconven%TYPE /* número do convenio */
                                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL /* numero do documento (ou boleto) */
                                    ,pr_flgregis IN crapcob.flgregis%TYPE DEFAULT 1 /* cobranca registrada */
                                    ,pr_flgsacad IN INTEGER               DEFAULT 0 /* se o sacado eh dda ou nao */
                                    ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT 0 /* contrato de empréstimo */
                                    ,pr_nrpartit IN INTEGER DEFAULT 0     /* numero da parcela do titulo quando tiver */
                                    ,pr_inemiten IN crapcob.inemiten%TYPE /* Emitente */
                                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE /* código do banco */
                                    ,pr_cdcartei IN crapcob.cdcartei%TYPE /* código da carteira */
                                    ,pr_cddespec IN crapcob.cddespec%TYPE /* espécie de documento */
                                    ,pr_nrctasac IN crapcob.nrctasac%TYPE DEFAULT 0 /* numero da conta do sacado se houver */
                                    ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE /* tipo de inscrição do sacado 1=CPF, 2=CNPJ*/
                                    ,pr_nrinssac IN crapcob.nrinssac%TYPE /* nr de inscrição do sacado */
                                    ,pr_nmdavali IN crapcob.nmdavali%TYPE DEFAULT ' ' /* nome do avalista */
                                    ,pr_cdtpinav IN crapcob.cdtpinav%TYPE DEFAULT 0 /* codigo tipo sacador/avalista */
                                    ,pr_nrinsava IN crapcob.nrinsava%TYPE DEFAULT 0 /* nr da inscrição do sacador/avalista */
                                    ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE /* data do movimento */
                                    ,pr_dtdocmto IN crapcob.dtdocmto%TYPE /* data do documento */
                                    ,pr_dtvencto IN crapcob.dtvencto%TYPE /* data do vencimento */
                                    ,pr_vldescto IN crapcob.vldescto%TYPE DEFAULT 0 /* vlr do desconto */
                                    ,pr_vlabatim IN crapcob.vlabatim%TYPE DEFAULT 0 /* vlr do abatimento */
                                    ,pr_cdmensag IN crapcob.cdmensag%TYPE /* tipo de desconto */
                                    ,pr_dsdoccop IN crapcob.dsdoccop%TYPE /* descrição do documento */
                                    ,pr_vltitulo IN crapcob.vltitulo%TYPE /* valor do título */
                                    ,pr_dsinform IN crapcob.dsinform%TYPE DEFAULT '____' /* informações */
                                    ,pr_dsdinstr IN crapcob.dsdinstr%TYPE DEFAULT '____' /* instruções */
                                    ,pr_flgdprot IN crapcob.flgdprot%TYPE DEFAULT 0 /* protestar 0 = Não, 1 = Sim */
                                    ,pr_qtdiaprt IN crapcob.qtdiaprt%TYPE DEFAULT 0 /* qtd de dias para protesto */
                                    ,pr_indiaprt IN crapcob.indiaprt%TYPE DEFAULT 3 /* 1= Útil, 2=Corridos, 3= isento */
                                    ,pr_vljurdia IN crapcob.vljurdia%TYPE DEFAULT 0 /* vlr juros ao dia */
                                    ,pr_vlrmulta IN crapcob.vlrmulta%TYPE DEFAULT 0 /* vlr de multa */
                                    ,pr_flgaceit IN crapcob.flgaceit%TYPE DEFAULT 0 /* aceite */
                                    ,pr_tpjurmor IN crapcob.tpjurmor%TYPE DEFAULT 3 /* tipo de juros de mora 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
                                    ,pr_tpdmulta IN crapcob.tpdmulta%TYPE DEFAULT 3 /* tipo de multa 1=vlr "R$", 2= "%" , 3=isento */
                                    ,pr_tpemitir IN INTEGER               DEFAULT 1 /* tipo de emissão = 1 = Boleto / 2 = Carnê */
                                    ,pr_nrremass IN crapret.nrremass%TYPE DEFAULT 0 /* Numero da remessa do arquivo */
                                    ,pr_cdoperad IN crapcob.cdoperad%TYPE /* código do operador */
                                    ,pr_cdcritic OUT INTEGER              /* código de critica (se houver);*/
                                    ,pr_dscritic OUT VARCHAR2             /* descrição da crítica (se houver);*/
                                    ,pr_tab_cob  OUT typ_tab_cob) IS /* record do boleto*/
/* ............................................................................

     Programa: pc_gerar_titulo_cobranca
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lombardi
     Data    : Agosto/2015                     Ultima atualizacao: 28/08/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Gera título de cobrança

     Alteracoes: 13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
						 	  para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
						 	 (Andrei - RKAM).

                 28/08/2017 - Ajuste para possibilitar envio do boleto à CIP (Rafael)

  ............................................................................ */      

      vr_cdbarras VARCHAR2(44);
      vr_nrnosnum crapcob.nrnosnum%TYPE;
      vr_dtdemiss DATE;

      vr_busca VARCHAR2(100);
      vr_nrdocmto crapcob.nrdocmto%TYPE;
      
      CURSOR cr_cop 
          IS SELECT cdbcoctl, cdagectl 
               FROM crapcop
              WHERE crapcop.cdcooper = pr_cdcooper;
              
      rw_cop cr_cop%ROWTYPE;
      
      CURSOR cr_crapcob IS 
        SELECT cob.*, cob.rowid 
          FROM crapcob cob;
      rw_cob cr_crapcob%ROWTYPE;
      
      CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE) IS
             SELECT * FROM crapcco cco
              WHERE cco.cdcooper = pr_cdcooper
                AND cco.nrconven = pr_nrconven;
                
      rw_crapcco cr_crapcco%ROWTYPE;
      
      CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE
                        ,pr_nrdconta IN crapsab.nrdconta%TYPE
                        ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
             SELECT * FROM crapsab sab
              WHERE sab.cdcooper = pr_cdcooper
                AND sab.nrdconta = pr_nrdconta
                AND sab.nrinssac = pr_nrinssac;
      
      rw_crapsab cr_crapsab%ROWTYPE;                        
      
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
             SELECT * FROM crapass
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta;
                
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crappnp ( pr_nmextcid IN crappnp.nmextcid%TYPE
                         ,pr_cduflogr IN crappnp.cduflogr%TYPE) IS 
             SELECT * FROM crappnp
              WHERE nmextcid = pr_nmextcid
                AND cduflogr = pr_cduflogr;
      
      rw_crappnp cr_crappnp%ROWTYPE;
      
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
            SELECT nrcnvceb 
              FROM crapceb 
             WHERE crapceb.cdcooper = pr_cdcooper
               AND crapceb.nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrcnvcob;
               
      rw_crapceb cr_crapceb%ROWTYPE;                  
      
      vr_exc_critica EXCEPTION;
      vr_exc_erro EXCEPTION;
      
      vr_dsdinstr crapcob.dsdinstr%TYPE;
      vr_nrremret crapret.nrremret%TYPE;
      vr_des_erro VARCHAR2(100);
      
      vr_flgdprot INTEGER;
      vr_qtdiaprt INTEGER;
      vr_indiaprt INTEGER;


  BEGIN    
      OPEN cr_crapcco (pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      
      IF cr_crapcco%NOTFOUND THEN
          CLOSE cr_crapcco;
          pr_cdcritic := 0;
          pr_dscritic := 'Convenio nao encontrado.';        
          RAISE vr_exc_critica;        
      END IF;
      
      CLOSE cr_crapcco;                    

      /* Testar parametro em relacao ao convenio */
      IF  rw_crapcco.flgregis <> pr_flgregis THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Tipo de cobranca invalida.';        
          RAISE vr_exc_critica;
      END IF;

      
      vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                  TRIM(to_char(pr_nrdconta)) || ';' ||
                  TRIM(to_char(pr_nrcnvcob)) || ';' ||
                  TRIM(to_char(rw_crapcco.nrdctabb)) || ';' ||
                  TRIM(to_char(pr_cdbandoc));

      /* Busca a proxima sequencia do campo CRAPCOB.NRDOCMTO */
      IF (pr_nrdocmto IS NULL OR pr_nrdocmto = 0)  THEN
         vr_nrdocmto := fn_sequence('CRAPCOB','NRDOCMTO', vr_busca);
      ELSE
         vr_nrdocmto := pr_nrdocmto;
      END IF;

      IF  vr_nrdocmto = 0 THEN 
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao gerar numero do documento.';
          RAISE vr_exc_critica;
      END IF;

      IF rw_crapcco.cddbanco <> 085 THEN
         /* Se for convenio de 6 digito deve gerar
            o nosso numero apenas com a conta e docto SD 308717*/            
            
         IF LENGTH(to_char(pr_nrcnvcob)) <= 6 THEN
            vr_nrnosnum := to_char(pr_nrdconta,'fm00000000') ||
                           to_char(vr_nrdocmto,'fm000000000');
         ELSE
            OPEN cr_crapceb (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrcnvcob);
            FETCH cr_crapceb INTO rw_crapceb;
            CLOSE cr_crapceb;
               
            vr_nrnosnum := to_char(pr_nrcnvcob, 'fm0000000') ||
                           to_char(rw_crapceb.nrcnvceb, 'fm0000') || 
                           to_char(vr_nrdocmto, 'fm000000');    
         END IF;
      ELSE
          vr_nrnosnum := to_char(pr_nrdconta,'fm00000000') ||
                         to_char(vr_nrdocmto,'fm000000000');
      END IF;
      

      OPEN cr_crapsab (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrinssac => pr_nrinssac);
      FETCH cr_crapsab INTO rw_crapsab;                    

      IF cr_crapsab%NOTFOUND THEN
        CLOSE cr_crapsab;        
        pr_cdcritic := 0;
        pr_dscritic := 'Pagador nao encontrado.';
        RAISE vr_exc_critica;
      END IF;        
      
      CLOSE cr_crapsab;
      
      vr_flgdprot := pr_flgdprot;
      vr_qtdiaprt := pr_qtdiaprt;
      vr_indiaprt := pr_indiaprt;
      
      IF pr_flgregis = 1 THEN
         
         /**** validação praça não executante de protesto ****/      
         OPEN cr_crappnp (pr_nmextcid => rw_crapsab.nmcidsac
                         ,pr_cduflogr => rw_crapsab.cdufsaca);
         FETCH cr_crappnp INTO rw_crappnp;

         IF cr_crappnp%FOUND THEN

            vr_flgdprot := 0;
            vr_qtdiaprt := 0;
            vr_indiaprt := 3;
            
            /* Obs.: cursor será fechado apos a inclusao na crapcob */
                                               
          END IF;
          
      END IF;         
     
      /* se inst aut de protesto, cob registrada e banco 085 */
      IF pr_flgregis = 1 AND 
         pr_flgdprot = 1 AND 
         rw_crapcco.cddbanco = 085 THEN 
         vr_dsdinstr := '** Servico de protesto sera efetuado ' ||  
                        'pelo Banco do Brasil **';
      ELSE
         vr_dsdinstr := pr_dsdinstr;
      END IF;

        /* se banco emite e expede, nosso num conv+ceb+doctmo -
           Rafael Cechet 29/03/11 */

      vr_dtdemiss := pr_dtmvtolt;

      INSERT INTO crapcob 
             (cdcooper, nrdconta, nrdocmto, idseqttl, dtmvtolt, cdbandoc, incobran, nrcnvcob, nrdctabb, cdcartei, 
              cddespec, cdtpinsc, nrinssac, nmdavali, cdtpinav, nrinsava, dtretcob, dtdocmto, dtvencto, vldescto, 
              vlabatim, cdmensag, dsdoccop, vltitulo, dsdinstr, dsinform, cdimpcob, flgimpre, nrctasac, nrctremp, 
              nrnosnum, flgdprot, qtdiaprt, indiaprt, vljurdia, vlrmulta, flgaceit, flgregis, inemiten, insitcrt, 
              insitpro, flgcbdda, tpjurmor, tpdmulta, idopeleg, idtitleg, inemiexp, inregcip, inenvcip, dtvctori)
      VALUES ( pr_cdcooper
              ,pr_nrdconta
              ,vr_nrdocmto
              ,pr_idseqttl
              ,vr_dtdemiss
              ,pr_cdbandoc
              ,0 -- incobran
              ,pr_nrcnvcob
              ,rw_crapcco.nrdctabb
              ,pr_cdcartei -- 10
              ,pr_cddespec
              ,pr_cdtpinsc
              ,pr_nrinssac
              ,upper(pr_nmdavali)
              ,pr_cdtpinav
              ,pr_nrinsava
              ,pr_dtmvtolt
              ,pr_dtdocmto
              ,pr_dtvencto
              ,pr_vldescto -- 20
              ,pr_vlabatim
              ,pr_cdmensag
              ,upper(TRIM(pr_dsdoccop)) || (CASE pr_nrpartit WHEN 0 THEN ' ' ELSE '/' || to_char(pr_nrpartit,'0000') END)
              ,pr_vltitulo
              ,upper(vr_dsdinstr)
              ,upper(pr_dsinform)
              ,3 -- cdimpcob
              ,1 -- flgimpre
              ,pr_nrctasac
              ,pr_nrctremp -- 30
              ,vr_nrnosnum
              ,vr_flgdprot -- 
              ,vr_qtdiaprt -- 
              ,vr_indiaprt -- 
              ,pr_vljurdia -- 
              ,pr_vlrmulta -- 
              ,pr_flgaceit -- 
              ,pr_flgregis -- 
              ,pr_inemiten -- 
              ,0 -- 40
              ,(CASE pr_cdbandoc WHEN 85 THEN 1 ELSE 0 END) -- 
              ,pr_flgsacad -- 
             /* 1=vlr 'R$' diario, 2= '%' Mensal, 3=isento */
              ,(CASE WHEN pr_vljurdia = 0 THEN 3 ELSE pr_tpjurmor END) -- 
             /* 1=vlr 'R$', 2= '%' , 3=isento */
              ,(CASE pr_vlrmulta WHEN 0 THEN 3 ELSE pr_tpdmulta END) -- 
              ,(CASE pr_flgsacad WHEN 1 THEN seqcob_idopeleg.nextval ELSE 0 END) -- 
              ,(CASE pr_flgsacad WHEN 1 THEN seqcob_idtitleg.nextval ELSE 0 END) -- 
              ,(CASE WHEN pr_inemiten = 3 THEN 1 /* a enviar à PG */ ELSE 0 END )
              ,2 -- registro batch CIP
              ,1 -- CIP a enviar
              ,pr_dtvencto -- vencimento original
              ) RETURNING 
                  cdcooper, nrdconta, nrdocmto, idseqttl, dtmvtolt, cdbandoc, incobran, nrcnvcob, nrdctabb, cdcartei, 
                  cddespec, cdtpinsc, nrinssac, nmdavali, cdtpinav, nrinsava, dtretcob, dtdocmto, dtvencto, vldescto, 
                  vlabatim, cdmensag, dsdoccop, vltitulo, dsdinstr, dsinform, cdimpcob, flgimpre, nrctasac, nrctremp, 
                  nrnosnum, flgdprot, qtdiaprt, indiaprt, vljurdia, vlrmulta, flgaceit, flgregis, inemiten, insitcrt, 
                  insitpro, flgcbdda, tpjurmor, tpdmulta, idopeleg, idtitleg, inemiexp, crapcob.ROWID
              INTO 
                  rw_cob.cdcooper, rw_cob.nrdconta, rw_cob.nrdocmto, rw_cob.idseqttl, rw_cob.dtmvtolt, rw_cob.cdbandoc, rw_cob.incobran, rw_cob.nrcnvcob, rw_cob.nrdctabb, rw_cob.cdcartei, 
                  rw_cob.cddespec, rw_cob.cdtpinsc, rw_cob.nrinssac, rw_cob.nmdavali, rw_cob.cdtpinav, rw_cob.nrinsava, rw_cob.dtretcob, rw_cob.dtdocmto, rw_cob.dtvencto, rw_cob.vldescto, 
                  rw_cob.vlabatim, rw_cob.cdmensag, rw_cob.dsdoccop, rw_cob.vltitulo, rw_cob.dsdinstr, rw_cob.dsinform, rw_cob.cdimpcob, rw_cob.flgimpre, rw_cob.nrctasac, rw_cob.nrctremp, 
                  rw_cob.nrnosnum, rw_cob.flgdprot, rw_cob.qtdiaprt, rw_cob.indiaprt, rw_cob.vljurdia, rw_cob.vlrmulta, rw_cob.flgaceit, rw_cob.flgregis, rw_cob.inemiten, rw_cob.insitcrt, 
                  rw_cob.insitpro, rw_cob.flgcbdda, rw_cob.tpjurmor, rw_cob.tpdmulta, rw_cob.idopeleg, rw_cob.idtitleg, rw_cob.inemiexp, rw_cob.rowid;              
                    
      IF pr_flgregis = 1 THEN
         
         IF cr_crappnp%FOUND THEN

            CLOSE cr_crappnp;
      
            paga0001.pc_cria_log_cobranca(rw_cob.rowid
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Obs.: Praca nao executante de protesto'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => pr_dscritic);
                                         
          END IF;
          
          IF cr_crappnp%ISOPEN THEN
             CLOSE cr_crappnp;
          END IF;

      END IF;         
  
      /** Validacoes de Cobranca Registrada **/
      IF  pr_cdbandoc = 1 AND pr_flgregis = 1 THEN 

          pc_gera_pedido_remessa( pr_rowidcob => rw_cob.rowid
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);
      
      ELSE 
         IF rw_cob.cdbandoc = 085 AND 
            pr_flgregis = 1       AND 
            pr_inemiten <> 3      THEN /* nao gerar confirmacao de retorno
                                              qdo emissao Cooperativa/EE */
                                              
          OPEN cr_cop;
          FETCH cr_cop INTO rw_cop;
          CLOSE cr_cop;
            
          /* Preparar Lote de Retorno Cooperado */
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_cob.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 02  /* Baixa */   --Codigo Ocorrencia
                                             ,pr_cdmotivo => '' /* Decurso Prazo */  --Codigo Motivo
                                             ,pr_vltarifa => 0
                                             ,pr_cdbcoctl => rw_cop.cdbcoctl
                                             ,pr_cdagectl => rw_cop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => pr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => pr_dscritic); --Descricao Critica          
         END IF;
      END IF;

      /*** Criando log do processo - Cobranca Registrada ***/
      IF pr_flgregis = 1 THEN 
        
         paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_cob.rowid
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_dtmvtolt => SYSDATE
                                     , pr_dsmensag => (CASE WHEN pr_tpemitir = 1 THEN 'Titulo gerado'
                                     ELSE 'Titulo gerado - Carne' END)
                                     , pr_des_erro => vr_des_erro
                                     , pr_dscritic => pr_dscritic);
      END IF;

      IF pr_flgregis = 1 AND pr_inemiten = 3 THEN /* cooperativa emite e expede */ 
        
          /*** Criando log do boleto – Titulo a enviar para PG ***/
         paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_cob.rowid
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_dtmvtolt => SYSDATE
                                     , pr_dsmensag => 'Titulo a enviar para PG'
                                     , pr_des_erro => vr_des_erro
                                     , pr_dscritic => pr_dscritic);

      END IF;
      
      cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
--                                            ,pr_rowidcob => rw_crapcob.rowidcob
                                        ,pr_nrdconta => rw_cob.nrdconta
                                        ,pr_nrcnvcob => rw_cob.nrcnvcob
                                        ,pr_nrdocmto => rw_cob.nrdocmto
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nriniseq => 1
                                        ,pr_nrregist => 1
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_cob  => pr_tab_cob);      
      

  /*    ASSIGN pr_lsdoctos = pr_lsdoctos + 
                           (IF  pr_lsdoctos <> ''  THEN
                                ','
                            ELSE
                                '') + to_char(aux_nrdocmto) 
             pr_nrdocmto = pr_nrdocmto + 1
             pr_nrdoccop = pr_nrdoccop + 1.*/

  --    RETURN 'OK'.  
  

  EXCEPTION
    WHEN vr_exc_critica THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      -- RETURN "NOK".
      -- Efetuar Rollback
    WHEN vr_exc_erro THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      
      pr_dscritic := pr_dscritic || ' - ' || SQLERRM;

    WHEN OTHERS THEN
      IF cr_crappnp%ISOPEN THEN CLOSE cr_crappnp; END IF;
      IF cr_crapass%ISOPEN THEN CLOSE cr_crapass; END IF;
      IF cr_crapceb%ISOPEN THEN CLOSE cr_crapceb; END IF;
      IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
      IF cr_crapsab%ISOPEN THEN CLOSE cr_crapsab; END IF;
      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
  END pc_gerar_titulo_cobranca;
  
  PROCEDURE pc_buscar_titulo_cobranca (pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                                      ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo
                                      ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                                      ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Nr do titulo
                                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                                      ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                                      ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                                      ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                                      ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                                      ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                                      ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                                      ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                                      ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                                      ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                                      ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                                      ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                                      ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                                      ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                                      ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                                      ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                                      ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                                      ,pr_fldescon IN INTEGER DEFAULT NULL               --> Se titulo é descontado
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Cód. Operador
                                      ,pr_nriniseq IN INTEGER                            --> Registro inicial da listagem
                                      ,pr_nrregist IN INTEGER                            --> Numero de registros p/ paginaca
                                      ,pr_dtmvtolt IN DATE DEFAULT NULL                  --> Data do Movimento
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Cód. da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE             --> Descrição da crítica
                                      ,pr_tab_cob  OUT typ_tab_cob                       /* record do boleto*/                                      
                                      ) IS
  BEGIN                                      
  /* ............................................................................

     Programa: pc_buscar_titulo_cobranca
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet
     Data    : Agosto/2015                     Ultima atualizacao: 05/10/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado
     Objetivo  : Buscar de forma generica titulos de cobrança

     Alteracoes: 05/10/2016 -  Ajustes referente a melhoria M271 (Kelvin).

  ............................................................................ */      

	DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(1000);
      -- Email do Pagador 
      vr_dsdemail VARCHAR2(5000);
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_semresultado EXCEPTION;

      vr_ind INTEGER := 0;      
      vr_ind_cob INTEGER := 0;
      
      vr_nro_digito INTEGER;      
      vr_retorno BOOLEAN;      
      vr_cdagediv INTEGER;
      vr_dsinform cecred.gene0002.typ_split;

			---------------------------- CURSORES -----------------------------------
			CURSOR cr_crapcob 
      
/*      (    pr_cdcooper IN crapcop.cdcooper%TYPE              --> Cooperativa
                            ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL --> PA
                            ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT NULL --> Nr da Conta
                            ,pr_nrctremp IN crapcob.nrctremp%TYPE DEFAULT NULL --> Nr do contato de emprestimo
                            ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE DEFAULT NULL --> Convenio    
                            ,pr_nrdocmto IN crapcob.nrdocmto%TYPE DEFAULT NULL --> Nr do titulo
                            ,pr_cdbandoc IN crapcob.cdbandoc%TYPE DEFAULT NULL --> Banco                                                                        
                            ,pr_dtemissi IN DATE DEFAULT NULL                  --> Data de emissão inicial
                            ,pr_dtemissf IN DATE DEFAULT NULL                  --> Data de emissão final                                      
                            ,pr_dtvencti IN DATE DEFAULT NULL                  --> Data de vencimento inicial
                            ,pr_dtvenctf IN DATE DEFAULT NULL                  --> Data de vencimento final                                      
                            ,pr_dtbaixai IN DATE DEFAULT NULL                  --> Data de baixa inicial
                            ,pr_dtbaixaf IN DATE DEFAULT NULL                  --> Data de baixa final
                            ,pr_dtpagtoi IN DATE DEFAULT NULL                  --> Data de pagamento inicial
                            ,pr_dtpagtof IN DATE DEFAULT NULL                  --> Data de pagamento final
                            ,pr_vltituli IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título inicial
                            ,pr_vltitulf IN crapcob.vltitulo%TYPE DEFAULT NULL --> Valor do título final
                            ,pr_dsdoccop IN crapcob.dsdoccop%TYPE DEFAULT NULL --> Seu número
                            ,pr_incobran IN INTEGER DEFAULT NULL               --> Situacao do titulo (0=em aberto, 3=baixado, 5=Pago)
                            ,pr_flgcbdda IN crapcob.flgcbdda%TYPE DEFAULT NULL --> Flag se o título é DDA
                            ,pr_flcooexp IN INTEGER DEFAULT NULL               --> Cooperado emite e expede
                            ,pr_flceeexp IN INTEGER DEFAULT NULL               --> Cooperativa emite e expede
                            ,pr_flprotes IN INTEGER DEFAULT NULL               --> Se titulo foi protestado
                            ,pr_fldescon IN INTEGER DEFAULT NULL)      
*/      
      
      IS SELECT cop.nmrescop
               ,cop.dsendweb
               ,cop.cdagectl
               ,cop.cdagedbb
               ,cob.dtmvtolt
               ,decode(cob.incobran, 0, 'A', 3, 'B', 5, 'P') incobran
               ,cob.nrdconta
               ,cob.nrctremp
               ,cob.nrdctabb               
               ,cob.cdbandoc
               ,cob.nrdocmto
               ,cob.dtretcob
               ,cob.nrcnvcob
               ,cob.cdcooper
               ,cob.indpagto
               ,cob.dtdpagto
               ,cob.vldpagto
               ,cob.vltitulo
               ,cob.dsinform
               ,cob.dsdinstr
               ,cob.dtvencto
               ,cco.cdcartei
               ,cob.cddespec
               ,decode(cob.cddespec,1,'DM'
                                   ,2,'DS'
                                   ,3,'NP'
                                   ,4,'MENS'
                                   ,5,'NF'
                                   ,6,'RECI'
                                   ,7,'OUTR') dsdespec                                                  
               ,cob.cdtpinsc
               ,cob.cdtpinav
               ,cob.nrinsava
               ,cob.nrinssac
               ,cob.nmdavali
               ,cob.vldescto
               ,cob.cdmensag
               ,cob.dsdoccop
               ,cob.idseqttl
               ,cob.dtdbaixa
               ,cob.vlabatim
               ,cob.vltarifa
               ,decode(cob.cdbanpag, 11, 'COOP', to_char(cob.cdbanpag,'fm000')) cdbanpag
               ,decode(cob.cdagepag, 11, ' ', to_char(cob.cdagepag, 'fm0000')) cdagepag               
               ,cob.dtdocmto
               ,cob.nrnosnum
               ,cob.insitcrt
               ,cob.dtsitcrt
               ,cob.flgdprot
               ,cob.qtdiaprt
               ,cob.indiaprt
               ,cob.vljurdia
               ,cob.vlrmulta
               ,decode(cob.flgaceit,1,' S', 0, ' N') flgaceit
               ,cob.dsusoemp
               ,cob.flgregis
               ,cob.inemiten
               ,cob.tpjurmor
               ,cob.tpdmulta
               ,decode(cob.flgcbdda,1,'S',0,'N') flgcbdda
               ,cob.idtitleg
               ,cob.idopeleg
               ,cob.insitpro
               ,cob.nrremass
               ,cob.cdtitprt
               ,cob.dcmc7chq
               ,cob.inemiexp
               ,cob.dtemiexp
               ,cob.dtelimin
               ,cob.flserasa 
               ,cob.qtdianeg
               ,sab.nmdsacad
               ,sab.dsendsac
               ,sab.nmbaisac
               ,sab.nrcepsac
               ,sab.nmcidsac
               ,sab.cdufsaca
               ,sab.nrendsac
               ,sab.complend
               ,sab.cdsitsac
         --    ,sab.dsdemail
               ,sab.flgemail
               ,sab.nrcelsac
               ,ceb.nrcnvceb
               ,ass.cdagenci
               ,ass.nmprimtl
               ,ass.nrcpfcgc
               ,ass.inpessoa
               ,cco.dsorgarq
               ,cco.nrvarcar
               ,cob.rowid
               ,decode(cob.inemiten,1,'1-BCO',2,'2-COO',3,'3-CEE') dsemiten
               ,decode(cob.inemiten,1,'BCO',2,'COO',3,'CEE') dsemitnt
               ,nvl((SELECT 1 FROM crapcol col
                      WHERE col.cdcooper (+) = cob.cdcooper
                        AND col.nrdconta (+) = cob.nrdconta
                        AND col.nrcnvcob (+) = cob.nrcnvcob
                        AND col.nrdocmto (+) = cob.nrdocmto
                        AND upper(col.dslogtit(+)) LIKE '%CARNE%'),0) flgcarne
               ,nvl((SELECT 1 FROM craptdb tdb
                      WHERE tdb.cdcooper (+) = cob.cdcooper
                        AND tdb.nrdconta (+) = cob.nrdconta
                        AND tdb.nrcnvcob (+) = cob.nrcnvcob
                        AND tdb.nrdocmto (+) = cob.nrdocmto
                        AND tdb.nrdctabb (+) = cob.nrdctabb
                        AND tdb.cdbandoc (+) = cob.cdbandoc
                        AND tdb.insittit (+) = 4),0) fldescon
           FROM crapcob cob
              , crapsab sab
              , crapcco cco
              , crapceb ceb
              , crapass ass
              , crapcop cop
          WHERE cco.cdcooper = pr_cdcooper                            --> Cód. cooperativa
            AND ceb.cdcooper = cco.cdcooper
            AND ceb.nrconven = cco.nrconven
            AND cob.cdcooper = ceb.cdcooper
            AND cob.nrdconta = ceb.nrdconta
            AND cob.nrcnvcob = ceb.nrconven
--            AND cob.cdbandoc = cco.cddbanco
--            AND cob.nrdctabb = cco.nrdctabb
            AND ass.cdcooper = cob.cdcooper
            AND ass.nrdconta = cob.nrdconta
            AND sab.cdcooper = cob.cdcooper
            AND sab.nrdconta = cob.nrdconta
            AND sab.nrinssac = cob.nrinssac            
            AND cop.cdcooper = cob.cdcooper
					  AND (pr_cdagenci IS NULL OR ass.cdagenci =  pr_cdagenci)   --> PA
						AND (pr_nrdconta IS NULL OR ceb.nrdconta =  pr_nrdconta)   --> Nr da Conta
            AND (pr_nrctremp IS NULL OR cob.nrctremp =  pr_nrctremp)   --> Nr do contrato de emprestimo
            AND (pr_nrcnvcob IS NULL OR cco.nrconven =  pr_nrcnvcob)   --> Nr do Convenio
            AND (pr_nrdocmto IS NULL OR cob.nrdocmto =  pr_nrdocmto)   --> Numero do titulo
            AND (pr_cdbandoc IS NULL OR cco.cddbanco =  pr_cdbandoc)   --> Nr do Banco
						AND (pr_dtbaixai IS NULL OR cob.dtdbaixa >= pr_dtbaixai)   --> Data da baixa de
						AND (pr_dtbaixaf IS NULL OR cob.dtdbaixa <= pr_dtbaixaf)   --> Data de baixa até
						AND (pr_dtemissi IS NULL OR cob.dtmvtolt >= pr_dtemissi)   --> Data de emnissão de 
						AND (pr_dtemissf IS NULL OR cob.dtmvtolt <= pr_dtemissf)   --> Data de emissão até
						AND (pr_dtvencti IS NULL OR cob.dtvencto >= pr_dtvencti)   --> Data de vencimento de 
						AND (pr_dtvenctf IS NULL OR cob.dtvencto <= pr_dtvenctf)   --> Data de vencimento até
						AND (pr_dtpagtoi IS NULL OR cob.dtdpagto >= pr_dtpagtoi)   --> Data de pagamento de
						AND (pr_dtpagtof IS NULL OR cob.dtdpagto <= pr_dtpagtof)   --> Data de pagamento até
            AND (pr_dsdoccop IS NULL OR cob.dsdoccop LIKE pr_dsdoccop) --> Seu Numero
            AND (pr_incobran IS NULL OR cob.incobran  = pr_incobran)   --> Situacao do titulo
            AND (pr_fldescon IS NULL OR 
                (pr_fldescon = 1 AND EXISTS(SELECT 1 FROM craptdb tdb
                                             WHERE tdb.cdcooper = cob.cdcooper
                                               AND tdb.nrdconta = cob.nrdconta
                                               AND tdb.nrcnvcob = cob.nrcnvcob
                                               AND tdb.nrdocmto = cob.nrdocmto
                                               AND tdb.nrdctabb = cob.nrdctabb
                                               AND tdb.cdbandoc = cob.cdbandoc
                                               AND tdb.insittit = 4)))
				  ORDER BY cob.nrdconta,
					         cob.nrcnvcob,
                   cob.nrdocmto;
                   
      rw_crapcob cr_crapcob%ROWTYPE;                     
  
    BEGIN

        -- Gera exceção se informar data de inicio e não informar data final e vice-versa
		    IF pr_dtbaixai IS NOT NULL AND pr_dtbaixaf IS NULL OR 
					 pr_dtbaixai IS NULL AND pr_dtbaixaf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Baixa.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;
				
			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtemissi IS NOT NULL AND pr_dtemissf IS NULL OR 
					 pr_dtemissi IS NULL AND pr_dtemissf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Emissao.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtvencti IS NOT NULL AND pr_dtvenctf IS NULL OR 
					 pr_dtvencti IS NULL AND pr_dtvenctf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Vencimento.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtpagtoi IS NOT NULL AND pr_dtpagtof IS NULL OR 
					 pr_dtpagtoi IS NULL AND pr_dtpagtof IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Pagto.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;
			  
				-- Gera exceção se a data inicial informada for maior que a final
			  IF pr_dtbaixai > pr_dtbaixaf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final				
		    IF pr_dtemissi > pr_dtemissf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final				
				IF pr_dtvencti > pr_dtvenctf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data inicial informada for maior que a final
 				IF pr_dtpagtoi > pr_dtpagtof THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtbaixaf - pr_dtbaixai) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtemissf - pr_dtemissi) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
				
			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtvenctf - pr_dtvencti) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;
								
			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtpagtof - pr_dtpagtoi) > 30 THEN
					 -- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;  

        -- inicializar elemento do indice        
        vr_ind_cob := 0;
    
				-- Abre cursor para atribuir os registros encontrados na PL/Table
				FOR rw_crapcob IN cr_crapcob 
          
/*                                      (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_nrcnvcob => pr_nrcnvcob
                                      ,pr_nrdocmto => pr_nrdocmto
                                      ,pr_cdbandoc => pr_cdbandoc
                                      ,pr_dtemissi => pr_dtemissi
                                      ,pr_dtemissf => pr_dtemissf
                                      ,pr_dtvencti => pr_dtvencti
                                      ,pr_dtvenctf => pr_dtvenctf
                                      ,pr_dtbaixai => pr_dtbaixai
                                      ,pr_dtbaixaf => pr_dtbaixaf
                                      ,pr_dtpagtoi => pr_dtpagtoi
                                      ,pr_dtpagtof => pr_dtpagtof
                                      ,pr_vltituli => pr_vltituli
                                      ,pr_vltitulf => pr_vltitulf
                                      ,pr_dsdoccop => pr_dsdoccop
                                      ,pr_incobran => pr_incobran
                                      ,pr_flgcbdda => pr_flgcbdda
                                      ,pr_flcooexp => pr_flcooexp
                                      ,pr_flceeexp => pr_flceeexp
                                      ,pr_flprotes => pr_flprotes
                                      ,pr_fldescon => pr_fldescon) */
          
                      LOOP				   
				
          -- incrementar indice
          vr_ind_cob := vr_ind_cob + 1;
          
				  pr_tab_cob(vr_ind_cob).cdcooper := rw_crapcob.cdcooper;
					pr_tab_cob(vr_ind_cob).cdagenci := rw_crapcob.cdagenci;
					pr_tab_cob(vr_ind_cob).nrctremp := rw_crapcob.nrctremp;
					pr_tab_cob(vr_ind_cob).nrdconta := rw_crapcob.nrdconta;
					pr_tab_cob(vr_ind_cob).nrcnvcob := rw_crapcob.nrcnvcob;
					pr_tab_cob(vr_ind_cob).nrdocmto := rw_crapcob.nrdocmto;
					pr_tab_cob(vr_ind_cob).dtmvtolt := rw_crapcob.dtmvtolt;
					pr_tab_cob(vr_ind_cob).dtvencto := rw_crapcob.dtvencto;
					pr_tab_cob(vr_ind_cob).vltitulo := rw_crapcob.vltitulo;
					pr_tab_cob(vr_ind_cob).dtdbaixa := rw_crapcob.dtdbaixa;
          pr_tab_cob(vr_ind_cob).idseqttl := rw_crapcob.idseqttl;
          
          /* nome do beneficiario */
          IF rw_crapcob.cdbandoc = 085 THEN
             pr_tab_cob(vr_ind_cob).nmprimtl := rw_crapcob.nmprimtl;
          ELSE
             pr_tab_cob(vr_ind_cob).nmprimtl := substr(rw_crapcob.nmrescop || ' - ' ||
                                                rw_crapcob.nmprimtl,1,40);
          END IF;
          
          pr_tab_cob(vr_ind_cob).incobran := rw_crapcob.incobran;
          pr_tab_cob(vr_ind_cob).nossonro := rw_crapcob.nrnosnum;
          pr_tab_cob(vr_ind_cob).nmdsacad := substr(rw_crapcob.nmdsacad,1,40);
          pr_tab_cob(vr_ind_cob).nrinssac := rw_crapcob.nrinssac;
          pr_tab_cob(vr_ind_cob).cdtpinsc := rw_crapcob.cdtpinsc;
          pr_tab_cob(vr_ind_cob).dsendsac := rw_crapcob.dsendsac;
          pr_tab_cob(vr_ind_cob).complend := rw_crapcob.complend;
          pr_tab_cob(vr_ind_cob).nmbaisac := rw_crapcob.nmbaisac;
          pr_tab_cob(vr_ind_cob).nmcidsac := rw_crapcob.nmcidsac;
          pr_tab_cob(vr_ind_cob).cdufsaca := rw_crapcob.cdufsaca;
          pr_tab_cob(vr_ind_cob).nrcepsac := rw_crapcob.nrcepsac;
          
          -- Pagador - Linha 1
          pr_tab_cob(vr_ind_cob).dspagad1 := rw_crapcob.nmdsacad;
          IF rw_crapcob.cdtpinsc = 1 THEN
             pr_tab_cob(vr_ind_cob).dspagad1 := pr_tab_cob(vr_ind_cob).dspagad1 || ' - ' ||
                                                'CPF: ' || gene0002.fn_mask(rw_crapcob.nrinssac, '999.999.999-99');
          ELSE
             pr_tab_cob(vr_ind_cob).dspagad1 := pr_tab_cob(vr_ind_cob).dspagad1 || ' - ' ||
                                                'CNPJ: ' || gene0002.fn_mask(rw_crapcob.nrinssac, '999.999.999/9999-99');
          END IF;
          
          -- Pagador - Linha 2
          pr_tab_cob(vr_ind_cob).dspagad2 := rw_crapcob.dsendsac || 
            (CASE WHEN nvl(rw_crapcob.nrendsac,0) > 0 THEN ', ' || to_char(rw_crapcob.nrendsac) END) ||
            (CASE WHEN rw_crapcob.complend IS NOT NULL THEN ' - ' || rw_crapcob.complend END) ||
            ' - ' || rw_crapcob.nmbaisac;
            
          -- Pagador - Linha 3
          pr_tab_cob(vr_ind_cob).dspagad3 := rw_crapcob.nmcidsac || ' - ' || 
                                             rw_crapcob.cdufsaca || ' - CEP: ' || 
                                             gene0002.fn_mask(rw_crapcob.nrcepsac, '99999-999');
                                             
          -- Sacador / Avalista
          IF TRIM(rw_crapcob.nmdavali) IS NOT NULL THEN
             pr_tab_cob(vr_ind_cob).dssacava := rw_crapcob.nmdavali || 
                (CASE WHEN rw_crapcob.cdtpinav = 1 THEN 
                      ' - CPF: ' || gene0002.fn_mask(rw_crapcob.nrinsava, '999.999.999-99')
                 ELSE
                      ' - CNPJ: ' || gene0002.fn_mask(rw_crapcob.nrinsava, '99.999.999/9999-99')
                 END);
          END IF;
          
          pr_tab_cob(vr_ind_cob).cdbandoc := rw_crapcob.cdbandoc;          
          IF rw_crapcob.cdbandoc = 85 THEN
             pr_tab_cob(vr_ind_cob).dsbandig := '085-1';
          ELSIF rw_crapcob.cdbandoc = 001 THEN
             pr_tab_cob(vr_ind_cob).dsbandig := '001-9';
          END IF;
          
          pr_tab_cob(vr_ind_cob).nmdavali := rw_crapcob.nmdavali;
          pr_tab_cob(vr_ind_cob).nrinsava := rw_crapcob.nrinsava;
          pr_tab_cob(vr_ind_cob).cdtpinav := rw_crapcob.cdtpinav;
          pr_tab_cob(vr_ind_cob).nrcnvcob := rw_crapcob.nrcnvcob;
          pr_tab_cob(vr_ind_cob).nrcnvceb := rw_crapcob.nrcnvceb;
          pr_tab_cob(vr_ind_cob).nrdctabb := rw_crapcob.nrdctabb;
          pr_tab_cob(vr_ind_cob).nrcpfcgc := rw_crapcob.nrcpfcgc;
          pr_tab_cob(vr_ind_cob).inpessoa := rw_crapcob.inpessoa;
          pr_tab_cob(vr_ind_cob).nrdocmto := rw_crapcob.nrdocmto;
          pr_tab_cob(vr_ind_cob).dtmvtolt := rw_crapcob.dtmvtolt;
          pr_tab_cob(vr_ind_cob).dsdoccop := rw_crapcob.dsdoccop;
          pr_tab_cob(vr_ind_cob).dtvencto := rw_crapcob.dtvencto;
          pr_tab_cob(vr_ind_cob).dtretcob := rw_crapcob.dtretcob;
          pr_tab_cob(vr_ind_cob).dtdpagto := rw_crapcob.dtdpagto;
          pr_tab_cob(vr_ind_cob).vltitulo := rw_crapcob.vltitulo;
          pr_tab_cob(vr_ind_cob).vldpagto := rw_crapcob.vldpagto;
          pr_tab_cob(vr_ind_cob).vldescto := rw_crapcob.vldescto;
          pr_tab_cob(vr_ind_cob).vlabatim := rw_crapcob.vlabatim;
          pr_tab_cob(vr_ind_cob).vltarifa := rw_crapcob.vltarifa;
--          pr_tab_cob(vr_ind_cob).vlrmulta := NUMBER(25,2)
--          ,vlrjuros NUMBER(25,2)
--          ,vloutdes NUMBER(25,2)
--          ,vloutcre NUMBER(25,2)
          pr_tab_cob(vr_ind_cob).cdmensag := rw_crapcob.cdmensag;
--          ,dsdpagto VARCHAR2(11)
          pr_tab_cob(vr_ind_cob).dsorgarq := rw_crapcob.dsorgarq;
--          ,nrregist INTEGER
--          ,idbaiexc INTEGER

          IF rw_crapcob.dtdpagto IS NULL AND 
             rw_crapcob.incobran = 'A' THEN
                    
             IF rw_crapcob.dtvencto < nvl(pr_dtmvtolt, trunc(SYSDATE)) THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'V';
             ELSE
                pr_tab_cob(vr_ind_cob).cdsituac := 'A';
             END IF;
              
          ELSIF rw_crapcob.dtdpagto IS NOT NULL AND rw_crapcob.dtdbaixa IS NULL  THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'L';
                 
          ELSIF rw_crapcob.dtdbaixa IS NOT NULL OR rw_crapcob.incobran = 'B' THEN 
                pr_tab_cob(vr_ind_cob).cdsituac := 'B';
                 
          ELSIF rw_crapcob.dtelimin IS NOT NULL THEN
                pr_tab_cob(vr_ind_cob).cdsituac := 'E';
          
          ELSE
                pr_tab_cob(vr_ind_cob).cdsituac := rw_crapcob.incobran;
          END IF;

          IF    pr_tab_cob(vr_ind_cob).cdsituac = 'A' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'ABERTO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'V' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'VENCIDO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'B' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'BAIXADO';                
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'E' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'EXCLUIDO';
          ELSIF pr_tab_cob(vr_ind_cob).cdsituac = 'L' THEN
                pr_tab_cob(vr_ind_cob).dssituac := 'LIQUIDADO';                
          END IF;

          pr_tab_cob(vr_ind_cob).cddespec := rw_crapcob.cddespec;
          pr_tab_cob(vr_ind_cob).dsdespec := rw_crapcob.dsdespec;
          pr_tab_cob(vr_ind_cob).dtdocmto := rw_crapcob.dtdocmto;
          pr_tab_cob(vr_ind_cob).cdbanpag := rw_crapcob.cdbanpag;
          pr_tab_cob(vr_ind_cob).cdagepag := rw_crapcob.cdagepag;
          pr_tab_cob(vr_ind_cob).flgdesco := rw_crapcob.fldescon;
          pr_tab_cob(vr_ind_cob).dtelimin := rw_crapcob.dtelimin;
          pr_tab_cob(vr_ind_cob).cdcartei := rw_crapcob.cdcartei;
          
          /* cooperado emite e expede (padrao) */
          pr_tab_cob(vr_ind_cob).nrvarcar := 1;
          
          /* banco emite e expede */
          IF rw_crapcob.inemiten = 2 THEN
             pr_tab_cob(vr_ind_cob).nrvarcar := rw_crapcob.nrvarcar;
          /* cooperativa emite e expede */
          ELSIF rw_crapcob.inemiten = 3 THEN
             pr_tab_cob(vr_ind_cob).nrvarcar := 2;
          END IF;
          
          pr_tab_cob(vr_ind_cob).flgregis := rw_crapcob.flgregis;
          pr_tab_cob(vr_ind_cob).nrnosnum := rw_crapcob.nrnosnum;
--          ,dsstaabr VARCHAR2(1000)
--          ,dsstacom VARCHAR2(1000)
          pr_tab_cob(vr_ind_cob).flgaceit := rw_crapcob.flgaceit;
          pr_tab_cob(vr_ind_cob).dtsitcrt := rw_crapcob.dtsitcrt;
--          ,agencidv VARCHAR2(1000)
          pr_tab_cob(vr_ind_cob).tpjurmor := rw_crapcob.tpjurmor;
          pr_tab_cob(vr_ind_cob).tpdmulta := rw_crapcob.tpdmulta;
          pr_tab_cob(vr_ind_cob).flgdprot := rw_crapcob.flgdprot;
          pr_tab_cob(vr_ind_cob).qtdiaprt := rw_crapcob.qtdiaprt;
          pr_tab_cob(vr_ind_cob).indiaprt := rw_crapcob.indiaprt;
          pr_tab_cob(vr_ind_cob).insitpro := rw_crapcob.insitpro;
          pr_tab_cob(vr_ind_cob).flgcbdda := rw_crapcob.flgcbdda;
--          ,cdocorre INTEGER
--          ,dsocorre VARCHAR2(1000)
--          ,cdmotivo VARCHAR2(1000)
--          ,dsmotivo VARCHAR2(1000)
--          ,dtocorre DATE
          pr_tab_cob(vr_ind_cob).dtdbaixa := rw_crapcob.dtdbaixa;
--          ,vldocmto NUMBER
--          ,vlmormul NUMBER
--          ,dtvctori DATE
--          ,dscjuros VARCHAR2(1000)
--          ,dscmulta VARCHAR2(1000)
--          ,dscdscto VARCHAR2(1000)
--          ,dsinssac VARCHAR2(1000)
--          ,vldesabt NUMBER
--          ,vljurmul NUMBER
--          ,dsorigem VARCHAR2(1000)
--          ,dtcredit DATE
--          ,nrborder craptdb.nrborder;
--          ,vllimtit NUMBER
--          ,vltdscti NUMBER
--          ,nrctrlim craptdb.nrctrlim;
--          ,nrctrlim_ativo craptdb.nrctrlim;
          COBR0009.pc_busca_emails_pagador(pr_cdcooper  => rw_crapcob.cdcooper
                                          ,pr_nrdconta  => rw_crapcob.nrdconta
                                          ,pr_nrinssac  => rw_crapcob.nrinssac
                                          ,pr_dsdemail  => vr_dsdemail
                                          ,pr_des_erro  => vr_des_erro
                                          ,pr_dscritic  => vr_dscritic);

          pr_tab_cob(vr_ind_cob).dsdemail := vr_dsdemail;
          pr_tab_cob(vr_ind_cob).flgemail := rw_crapcob.flgemail;
          pr_tab_cob(vr_ind_cob).inemiten := rw_crapcob.inemiten;
          pr_tab_cob(vr_ind_cob).dsemiten := rw_crapcob.dsemiten;
          pr_tab_cob(vr_ind_cob).dsemitnt := rw_crapcob.dsemitnt;
          pr_tab_cob(vr_ind_cob).flgcarne := rw_crapcob.flgcarne;
          pr_tab_cob(vr_ind_cob).rowidcob := rw_crapcob.rowid;

          -- Calcular Agencia / Codigo Beneficiario          
          IF rw_crapcob.cdbandoc = 085 THEN
            vr_cdagediv := rw_crapcob.cdagectl * 10;
            vr_retorno := gene0005.fn_calc_digito(pr_nrcalcul => vr_cdagediv, pr_reqweb => FALSE);
            pr_tab_cob(vr_ind_cob).dsagebnf := gene0002.fn_mask(vr_cdagediv, '9999-9') || ' / ' ||
                                               gene0002.fn_mask(rw_crapcob.nrdconta, '9999999-9');
          ELSIF rw_crapcob.cdbandoc = 001 THEN
            vr_cdagediv := rw_crapcob.cdagenci;
            pr_tab_cob(vr_ind_cob).dsagebnf := gene0002.fn_mask(rw_crapcob.cdagedbb, '9999-9') || ' / ' ||
                                               gene0002.fn_mask(rw_crapcob.nrdctabb, '9999999-9');            
          END IF;                                               
          
          pr_tab_cob(vr_ind_cob).dsdinstr := rw_crapcob.dsdinstr;        
          pr_tab_cob(vr_ind_cob).dsinform := rw_crapcob.dsinform;

          pr_tab_cob(vr_ind_cob).dsinfor1 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor2 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor3 := ' ';
          pr_tab_cob(vr_ind_cob).dsinfor4 := ' ';                              
          pr_tab_cob(vr_ind_cob).dsinfor5 := ' ';          

          vr_dsinform := cecred.gene0002.fn_quebra_string(pr_string => rw_crapcob.dsinform,
                                                          pr_delimit => '_');

          FOR vr_ind IN 1..vr_dsinform.count() LOOP
            CASE vr_ind 
               WHEN 1 THEN pr_tab_cob(vr_ind_cob).dsinfor1 := vr_dsinform(1);
               WHEN 2 THEN pr_tab_cob(vr_ind_cob).dsinfor2 := vr_dsinform(2);               
               WHEN 3 THEN pr_tab_cob(vr_ind_cob).dsinfor3 := vr_dsinform(3);
               WHEN 4 THEN pr_tab_cob(vr_ind_cob).dsinfor4 := vr_dsinform(4);
               WHEN 5 THEN pr_tab_cob(vr_ind_cob).dsinfor5 := vr_dsinform(5);
            END CASE;           
          END LOOP;          

          pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst2 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst3 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst4 := ' ';
          pr_tab_cob(vr_ind_cob).dsdinst5 := ' ';

          CASE rw_crapcob.cdmensag 
             WHEN 0 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';
             WHEN 1 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := 'MANTER DESCONTO ATE O VENCIMENTO';
             WHEN 2 THEN pr_tab_cob(vr_ind_cob).dsdinst1 := 'MANTER DESCONTO APOS O VENCIMENTO';
          ELSE 
             pr_tab_cob(vr_ind_cob).dsdinst1 := ' ';             
          END CASE;
          
          IF nvl(rw_crapcob.nrctremp,0) > 0 THEN
             pr_tab_cob(vr_ind_cob).dsdinst1 := '*** NAO ACEITAR PAGAMENTO APOS O VENCIMENTO ***';
          END IF;                    
          
          IF (rw_crapcob.tpjurmor <> 3) OR (rw_crapcob.tpdmulta <> 3) THEN
            
            pr_tab_cob(vr_ind_cob).dsdinst2 := 'APOS VENCIMENTO, COBRAR: ';
            
            IF rw_crapcob.tpjurmor = 1 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'R$ ' || to_char(rw_crapcob.vljurdia, 'fm999g999g990d00') || ' JUROS AO DIA';
            ELSIF rw_crapcob.tpjurmor = 2 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || to_char(rw_crapcob.vljurdia, 'fm999g999g990d00') || '% JUROS AO MES';
            END IF;
      			
            IF rw_crapcob.tpjurmor <> 3 AND
               rw_crapcob.tpdmulta <> 3 THEN
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || ' E ';
            END IF;

            IF rw_crapcob.tpdmulta = 1 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'MULTA DE R$ ' || to_char(rw_crapcob.vlrmulta, 'fm999g999g990d00');
            ELSIF rw_crapcob.tpdmulta = 2 THEN 
               pr_tab_cob(vr_ind_cob).dsdinst2 := pr_tab_cob(vr_ind_cob).dsdinst2 || 'MULTA DE ' || to_char(rw_crapcob.vlrmulta, 'fm999g999g990d00') || '%';
            END IF;
      			      			
          END IF;
          
          IF rw_crapcob.flgdprot = 1 THEN
             pr_tab_cob(vr_ind_cob).dsdinst3 := 'PROTESTAR APOS ' || to_char(rw_crapcob.qtdiaprt,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
             pr_tab_cob(vr_ind_cob).dsdinst4 := '*** SERVICO DE PROTESTO SERA EFETUADO PELO BANCO DO BRASIL ***';
          END IF;
                    
          IF rw_crapcob.flserasa = 1 AND rw_crapcob.qtdianeg > 0  THEN
             pr_tab_cob(vr_ind_cob).dsdinst3 := 'NEGATIVAR NA SERASA APOS ' || to_char(rw_crapcob.qtdianeg,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
             pr_tab_cob(vr_ind_cob).dsdinst4 := ' ';
          END IF;
                    
          pr_tab_cob(vr_ind_cob).dsavis2v := ' ';
          
          IF nvl(rw_crapcob.nrctremp,0) = 0 THEN
             pr_tab_cob(vr_ind_cob).dslocpag := 'APOS VENCIMENTO, PAGAR SOMENTE NA COOPERATIVA ' || rw_crapcob.nmrescop;
             pr_tab_cob(vr_ind_cob).dsavis2v := 'Apos o vencimento, acesse http://' || rw_crapcob.dsendweb || '.';
          ELSE
             pr_tab_cob(vr_ind_cob).dslocpag := 'NAO ACEITAR PAGAMENTO APOS O VENCIMENTO';
          END IF;
          
          pc_calc_codigo_barras ( pr_dtvencto => rw_crapcob.dtvencto
                                 ,pr_cdbandoc => rw_crapcob.cdbandoc
                                 ,pr_vltitulo => rw_crapcob.vltitulo
                                 ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                 ,pr_nrcnvceb => rw_crapcob.nrcnvceb
                                 ,pr_nrdconta => rw_crapcob.nrdconta
                                 ,pr_nrdocmto => rw_crapcob.nrdocmto                                 
                                 ,pr_cdcartei => rw_crapcob.cdcartei
                                 ,pr_cdbarras => pr_tab_cob(vr_ind_cob).cdbarras);
          
          pc_calc_linha_digitavel(pr_cdbarras => pr_tab_cob(vr_ind_cob).cdbarras,
                                  pr_lindigit => pr_tab_cob(vr_ind_cob).lindigit);
                                  					
				END LOOP;
        
        IF pr_tab_cob.count() = 0 THEN
           RAISE vr_exc_semresultado;
        END IF;
  
    EXCEPTION
      
      WHEN vr_exc_semresultado THEN
        pr_cdcritic := 0;
        pr_dscritic := 'pr_cdcooper: ' || to_char(pr_cdcooper) || 
        ' pr_nrdconta: ' || to_char(pr_nrdconta) || 
        ' pr_nrctremp: ' || to_char(pr_nrctremp) || 
        ' pr_nrcnvcob: ' || to_char(pr_nrcnvcob) || 
        ' pr_nrdocmto: ' || to_char(pr_nrdocmto) || 
        ' Boletos nao encontrados.';
      
      WHEN vr_exc_saida THEN
        -- Se possui código de crítica e não foi informado a descrição
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
    				
        -- Atribui exceção para os parametros de crítica				
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na COBR0005.pc_buscar_titulo_cobranca: ' || SQLERRM;

    END;
      
  END pc_buscar_titulo_cobranca;                                          
  
  --> Rotina para atualizar nome do remetente de SMS de cobrança
  PROCEDURE pc_atualizar_remetente_sms ( pr_cdcooper IN  crapcop.cdcooper%TYPE                  --> Codigo da cooperativa
                                        ,pr_nrdconta IN  crapass.nrdconta%TYPE          --> Numero da conta
                                        ,pr_idcontrato IN tbcobran_sms_contrato.idcontrato%TYPE --> Indicador unico do contrato
                                        ,pr_tpnome_emissao IN OUT tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                        ,pr_nmemissao_sms  IN OUT tbcobran_sms_contrato.nmemissao_sms%TYPE --> nome na emissao do boleto
                                        ,pr_dscritic OUT VARCHAR2) IS                    --> Retorno de critica

  /* ............................................................................

       Programa: pc_atualizar_remetente_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar nome do remetente de SMS de cobrança

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    
  BEGIN
    
    UPDATE tbcobran_sms_contrato c
           SET c.tpnome_emissao = pr_tpnome_emissao,
               c.nmemissao_sms  = nvl(pr_nmemissao_sms,c.nmemissao_sms)
         WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta   = pr_nrdconta
       AND c.idcontrato = pr_idcontrato;
           
    IF SQL%ROWCOUNT <> 1 THEN
      vr_dscritic := 'Contrato de SMS nao entontrado.';
      RAISE vr_exc_erro;
    END IF;
  

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar remetente do contrato de SMS: '||SQLERRM;  
  END pc_atualizar_remetente_sms;
  
  --> Rotina para atualizar nome do remetente de SMS de cobrança  - Chamada ayllos Web
  PROCEDURE pc_atualizar_remetente_sms_web (  pr_nrdconta       IN crapass.nrdconta%TYPE                     --> Numero de conta do cooperado                                     
                                             ,pr_idcontrato     IN tbcobran_sms_contrato.idcontrato%TYPE     --> Indicador unico do contrato
                                             ,pr_tpnome_emissao IN tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                             ,pr_nmemissao_sms  IN tbcobran_sms_contrato.nmemissao_sms%TYPE  --> nome na emissao do boleto
                                             ,pr_xmllog         IN VARCHAR2               --> XML com informacoes de LOG
                                             ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                             ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                             ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                             ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                             ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_atualizar_remetente_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar nome do remetente de SMS de cobrança - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_tpnome_emissao tbcobran_sms_contrato.tpnome_emissao%TYPE;
    vr_nmemissao_sms  tbcobran_sms_contrato.nmemissao_sms%TYPE; 
    
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
    
    vr_tpnome_emissao := pr_tpnome_emissao;
    vr_nmemissao_sms  := pr_nmemissao_sms; 
    
    --> Atualizar remetente
    pc_atualizar_remetente_sms ( pr_cdcooper   => vr_cdcooper          --> Codigo da cooperativa
                                ,pr_nrdconta => pr_nrdconta          --> Numero da conta
                                ,pr_idcontrato => pr_idcontrato
                                ,pr_tpnome_emissao => vr_tpnome_emissao --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                ,pr_nmemissao_sms  => vr_nmemissao_sms  --> nome na emissao do boleto
                                ,pr_dscritic => vr_dscritic);       --> Retorno de critica
                                        
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_atualizar_remetente_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_atualizar_remetente_sms_web;
  
  --> Rotina para verificar se permite enviar linha digitavel na SMS
  PROCEDURE pc_verif_permite_lindigi (pr_cdcooper IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                     ,pr_flglinha_digitavel OUT tbcobran_sms_param_coop.flglinha_digitavel%TYPE --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                     ,pr_dscritic            OUT VARCHAR2) IS         --> Retorno de critica

  /* ............................................................................

       Programa: pc_verif_permite_lindigi
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para verificar se permite enviar linha digitavel na SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    --> Verificar se permite linha digitavel
    CURSOR cr_sms_param IS
      SELECT prm.flglinha_digitavel
        FROM tbcobran_sms_param_coop prm
       WHERE prm.cdcooper = pr_cdcooper;
    rw_sms_param cr_sms_param%ROWTYPE;
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    
  BEGIN
    --> Verificar se permite linha digitavel
    OPEN cr_sms_param;
    FETCH cr_sms_param INTO rw_sms_param;
    CLOSE cr_sms_param;
    
    pr_flglinha_digitavel := nvl(rw_sms_param.flglinha_digitavel,0);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_verif_permite_lindigi : '||SQLERRM;  
  END pc_verif_permite_lindigi; 
  
  --> Rotina responsavel por gerar o relatorio analitico de envio de SMS
  PROCEDURE pc_relat_anali_envio_sms (pr_cdcooper  IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                     ,pr_nrdconta  IN  crapass.nrdconta%TYPE          --> Numer de conta do cooperado                                     
                                     ,pr_dtiniper  IN  DATE                           --> Data inicio do periodo para relatorio
                                     ,pr_dtfimper  IN  DATE                           --> Data fim do periodo para relatorio
                                     ,pr_idorigem  IN INTEGER                         --> Codigo de origem do sistema
                                     ,pr_dsiduser  IN VARCHAR2                        --> id do usuario
                                     ,pr_instatus  IN INTEGER DEFAULT 0               --> Status do SMS (0 - para todos)
                                     ,pr_tppacote  IN INTEGER DEFAULT 0               --> Tipo de pacote(1-pacote,2-individual,0-Todos)
                                     --------->> OUT <<-----------
                                     ,pr_nmarqpdf OUT VARCHAR2                        --> Retorna o nome do relatorio gerado
                                     ,pr_dsxmlrel OUT CLOB                            --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                     ,pr_cdcritic OUT NUMBER                          --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                     ,pr_dscritic OUT VARCHAR2) IS                    --> Retorno de critica

  /* ............................................................................

       Programa: pc_relat_anali_envio_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio analitico de envio de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    --> Buscar SMSs enviados 
    CURSOR cr_cobran_sms IS
      SELECT cob.nrdconta,
             ass.nmprimtl, 
             ass.cdagenci,
             age.nmresage,
             cob.nrnosnum,
             sab.nmdsacad,
             cob.dtvencto,
             cob.vltitulo,
             ctl.dhenvio_sms AS dhenvsms,
             ctl.nrddd||' '||ctl.nrtelefone  AS nrdofone,
             pct.dspacote
        FROM tbgen_sms_controle ctl,             
             tbcobran_sms sms,
             tbcobran_sms_contrato ctr,
             tbcobran_sms_pacotes pct,
             crapsab sab,
             crapcob cob,
             crapass ass,
             crapage age
       WHERE ctl.cdcooper = pr_cdcooper
         AND ctl.nrdconta = decode(nvl(pr_nrdconta,0),0,ctl.nrdconta,pr_nrdconta)
         AND ctl.dhenvio_sms BETWEEN pr_dtiniper AND to_date(to_char(pr_dtfimper,'DDMMRRRR')||'235959','DDMMRRHH24MISS')
         AND sms.idlote_sms = ctl.idlote_sms
         AND sms.idsms    = ctl.idsms
         AND sms.instatus_sms = DECODE(pr_instatus,0,sms.instatus_sms,pr_instatus)     
         AND sms.cdcooper = ctr.cdcooper
         AND sms.nrdconta = ctr.nrdconta
         AND sms.idcontrato = ctr.idcontrato
         AND ctr.cdcooper = pct.cdcooper
         AND ctr.idpacote = pct.idpacote
         AND cob.cdcooper = sms.cdcooper
         AND cob.nrdconta = sms.nrdconta
         AND cob.nrcnvcob = sms.nrcnvcob
         AND cob.nrdocmto = sms.nrdocmto
         AND cob.cdbandoc = sms.cdbandoc
         AND cob.nrdctabb = sms.nrdctabb
         AND sab.cdcooper = cob.cdcooper
         AND sab.nrdconta = cob.nrdconta
         AND sab.nrinssac = cob.nrinssac
         AND cob.cdcooper = ass.cdcooper
         AND cob.nrdconta = ass.nrdconta
         AND ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci
         AND ( (pr_tppacote = 2 AND ctr.idpacote IN (1,2)) OR
               (pr_tppacote = 1 AND ctr.idpacote > 2) OR
               (pr_tppacote = 0)
              );
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
     
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    vr_des_reto     VARCHAR2(100);
    vr_tab_erro     GENE0001.typ_tab_erro; 
    
    vr_flexsreg     BOOLEAN := FALSE;
    
    vr_dsdireto     VARCHAR2(4000);
    vr_dscomand     VARCHAR2(4000);
    vr_typsaida     VARCHAR2(100); 
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml      CLOB;
    vr_txtcompl     VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
  
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;  
  
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    IF pr_idorigem <> '3' THEN
      --> INICIO
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl728 dtiniper="'||to_char(pr_dtiniper,'DD/MM/RRRR')||'"
                                                                     dtfimper="'||to_char(pr_dtfimper,'DD/MM/RRRR')||'">');
      
    ELSE
      pc_escreve_xml('<crrl728>');
    END IF;
    
    --> Buscar SMSs enviados 
    FOR rw_cobran_sms IN cr_cobran_sms LOOP
      vr_flexsreg := TRUE;
      pc_escreve_xml('<SMS>'||
                       '<nrdconta>'||     TRIM(gene0002.fn_mask_conta(rw_cobran_sms.nrdconta)) ||'</nrdconta>'||
                       '<nmprimtl>'||     rw_cobran_sms.nmprimtl                             ||'</nmprimtl>'||
                       '<cdagenci>'||     rw_cobran_sms.cdagenci                             ||'</cdagenci>'||
                       '<nmresage>'||     rw_cobran_sms.nmresage                             ||'</nmresage>'||
                       '<nrnosnum>'||     rw_cobran_sms.nrnosnum                             ||'</nrnosnum>'||
                       '<nmdsacad>'||     rw_cobran_sms.nmdsacad                             ||'</nmdsacad>'||   
                       '<dtvencto>'||     to_char(rw_cobran_sms.dtvencto,'DD/MM/RRRR')       ||'</dtvencto>'||   
                       '<vltitulo>'||     rw_cobran_sms.vltitulo                             ||'</vltitulo>'||   
                       '<dhenvio_sms>'||  to_char(rw_cobran_sms.dhenvsms,'DD/MM/RRRR HH24:MI:SS')   ||'</dhenvio_sms>'||
                       '<nrdofone>'||     rw_cobran_sms.nrdofone                             ||'</nrdofone> '||
                       '<dspacote>'||     rw_cobran_sms.dspacote                             ||'</dspacote>
                     </SMS>');      
    END LOOP;
    
    pc_escreve_xml('</crrl728>',TRUE);
    
    IF vr_flexsreg = FALSE THEN
      vr_dscritic := 'Nenhum registro encontrado para o periodo informado.';
      RAISE vr_exc_erro;
    END IF;
    
    --Para origem InternetBank, já concluiu busca das informações, 
    --geração do relatorio ocorrerá no PHP    
    IF pr_idorigem = 3 THEN      
      pr_dsxmlrel := vr_des_xml;
      
    ELSE
      
      --Buscar diretorio da cooperativa
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_nmsubdir => '/rl');
      
      vr_dscomand := 'rm '||vr_dsdireto ||'/crrl728_'||pr_dsiduser||'* 2>/dev/null';
      
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomand
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typsaida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF; 
      
      
      pr_nmarqpdf := 'crrl728_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';
      
      
      --> Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => 'ATENDA'--pr_cdprogra
                                 , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/crrl728/SMS'
                                 , pr_dsjasper  => 'crrl728.jasper'
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_dsdireto ||'/'||pr_nmarqpdf
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 132
                                 , pr_cdrelato  => 728
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'N'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_des_erro  => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF; 
      
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      --> AyllosWeb
      IF pr_idorigem = 5 THEN
        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_erro; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;
        
      END IF;          
    END IF;  
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_relat_anali_envio_sms : '||SQLERRM;  
  END pc_relat_anali_envio_sms; 
  
  --> Rotina responsavel por gerar o relatorio analitico de envio de SMS - Chamada ayllos Web
  PROCEDURE pc_relat_anali_envio_sms_web (pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                         ,pr_dtiniper   IN VARCHAR2               --> Data inicio do periodo para relatorio
                                         ,pr_dtfimper   IN VARCHAR2               --> Data fim do periodo para relatorio
                                         ,pr_dsiduser   IN VARCHAR2               --> id do usuario
                                         ,pr_instatus   IN INTEGER DEFAULT 0      --> Status do SMS (0 - para todos)
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_relat_anali_envio_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio analitico de envio de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_dtfimper DATE;
    vr_dtiniper DATE; 

    -- Variaveis gerais
    vr_nmarqpdf VARCHAR2(1000);
    vr_dsxmlrel CLOB;
    
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

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'pc_relat_anali_envio_sms_web'
                               ,pr_action => NULL);
                               
    
    vr_dtiniper := to_date(pr_dtiniper,'DD/MM/RRRR');
    vr_dtfimper := to_date(pr_dtfimper,'DD/MM/RRRR');
    
    
    --> Rotina responsavel por gerar o relatorio analitico de envio de SMS
    pc_relat_anali_envio_sms (pr_cdcooper  => vr_cdcooper   --> Codigo da cooperativa                                    
                             ,pr_nrdconta  => pr_nrdconta   --> Numer de conta do cooperado                                     
                             ,pr_dtiniper  => vr_dtiniper   --> Data inicio do periodo para relatorio
                             ,pr_dtfimper  => vr_dtfimper   --> Data fim do periodo para relatorio
                             ,pr_idorigem  => vr_idorigem   --> Codigo de origem do sistema
                             ,pr_dsiduser  => pr_dsiduser   --> id do usuario
                             ,pr_instatus  => pr_instatus   --> Status do SMS
                             --------->> OUT <<-----------
                             ,pr_nmarqpdf => vr_nmarqpdf    --> Retorna o nome do relatorio gerado
                             ,pr_dsxmlrel => vr_dsxmlrel    --> Retorna xml do relatorio quando origem for 3 -InternetBank
                             ,pr_cdcritic => vr_cdcritic    --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                             ,pr_dscritic => vr_dscritic);  --> Retorno de critica
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmarqpdf
                          ,pr_des_erro => vr_dscritic);
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_relat_anali_envio_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_relat_anali_envio_sms_web;  
  
  --> Rotina para verificar se serviço de SMS.
  PROCEDURE pc_verifar_serv_sms(pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                               ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                               ,pr_nmdatela      IN craptel.nmdatela%TYPE  --> Nome da tela
                               ,pr_idorigem      IN INTEGER                --> Indicador de sistema origem
                               -----> OUT <----                                                                 
                               ,pr_idcontrato OUT tbcobran_sms_contrato.idcontrato%TYPE --> Retornar Numero do contratro ativo
                               ,pr_flsitsms OUT  INTEGER                   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                               ,pr_dsalerta OUT  VARCHAR2                  --> Retorna alerta para o cooperado
                               ,pr_cdcritic OUT  INTEGER                   --> Retorna codigo de critica
                               ,pr_dscritic OUT  VARCHAR2) IS              --> Retorno de critica

  /* ............................................................................

       Programa: pc_verifar_serv_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para verificar se serviço de SMS.

       Alteracoes: 14/06/2017 - Alterado para sempre cancelar pacote ativo, quando
                                a validação encontrar críticas. (Renato Darosci)

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT pct.cdtarifa
            ,pct.dspacote
            ,ctr.dhcancela
            ,ctr.idcontrato
            ,ctr.dhadesao
        FROM cecred.tbcobran_sms_contrato ctr
            ,cecred.tbcobran_sms_pacotes  pct
       WHERE ctr.cdcooper = pct.cdcooper(+)
         AND ctr.idpacote = pct.idpacote(+)
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.dhcancela IS NULL;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --> Buscar tarifas já aderidas pelo cooperado
    CURSOR cr_tarifas IS
      SELECT DISTINCT pct.cdtarifa
        FROM cecred.tbcobran_sms_contrato ctr
            ,cecred.tbcobran_sms_pacotes  pct
       WHERE ctr.cdcooper = pct.cdcooper(+)
         AND ctr.idpacote = pct.idpacote(+)
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta;
    
    --> Buscar historico da tarifa
    CURSOR cr_crapfvl(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
    SELECT fvl.cdhistor
      FROM crapfco fco
          ,crapfvl fvl
     WHERE fco.cdcooper = pr_cdcooper
       AND fco.flgvigen = 1 --> ativa 
       AND fco.cdfaixav = fvl.cdfaixav 
       AND fvl.cdtarifa = pr_cdtarifa;
    rw_crapfvl cr_crapfvl%ROWTYPE;
    
    --> Buscar parametro de cobranca
    CURSOR cr_cobran_prm IS
      SELECT prm.nrdiaslautom
        FROM tbcobran_sms_param_coop prm
       WHERE prm.cdcooper = pr_cdcooper;
    rw_cobran_prm cr_cobran_prm%ROWTYPE;     
    
    --> Verificar se cooperado possui lançamentos pendentes acima 
    --> da quantidade de dias estabelecida pela coop
    CURSOR cr_craplat(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_cdhistor craphis.cdhistor%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_nrdialau INTEGER) IS
      SELECT COUNT(lat.nrdconta)
        FROM craplat lat
       WHERE cdcooper = pr_cdcooper
         AND insitlat = 1
         AND cdhistor = pr_cdhistor
         AND nrdconta = pr_nrdconta
         AND (pr_dtmvtolt - lat.dttransa) > pr_nrdialau;
         
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --> Verificar se coop esta habilitada a enviar SMS de cobrança
    CURSOR cr_sms_param IS
      SELECT prm.flgenvia_sms
        FROM tbgen_sms_param prm
       WHERE prm.cdcooper = pr_cdcooper
         AND prm.cdproduto = 19;
    rw_sms_param cr_sms_param%ROWTYPE;
    
    --> Verificar se existe ceb ativo
    CURSOR cr_crapceb IS    
    SELECT 1
      FROM crapceb ceb
     WHERE ceb.insitceb = 1
       AND ceb.cdcooper = pr_cdcooper
       AND ceb.nrdconta = pr_nrdconta
       AND rownum <= 1;
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_qtlatpen     INTEGER;
    vr_tot_qtlatpen INTEGER := 0;
    vr_existe       INTEGER := 0; 
    vr_dsalerta     VARCHAR2(2000);
    
  BEGIN
    pr_flsitsms := 1;
    pr_dsalerta := NULL;
    vr_dsalerta := NULL;
  
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;   
  
    rw_contrato_sms := NULL;
    --> Buscar contrato ativo do cooperado
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO rw_contrato_sms;
    CLOSE cr_contrato_sms;    
        
  
    --> Verificar se coop esta habilitada a enviar SMS de cobrança
    rw_sms_param := NULL;
    OPEN cr_sms_param;
    FETCH cr_sms_param INTO rw_sms_param;
    CLOSE cr_sms_param;
    
    IF nvl(rw_sms_param.flgenvia_sms,0) = 0 THEN
      -- Se coop nao estiver liberada, retornar zero na situação do serviço
      pr_flsitsms := 0;
      
      --> Verificar se possui contrato ativo
      IF NVL(rw_contrato_sms.idcontrato,0) > 0 THEN
        --> Canlemaneto do contrato de SMS ativo
        COBR0005.pc_cancel_contrato_sms 
                             (pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                             ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                             ,pr_idseqttl    => 1              --> Sequencial do titular
                             ,pr_idcontrato  => rw_contrato_sms.idcontrato  --> Numero do contrato de SMS
                             ,pr_idorigem    => 7   /*Batch-automatico*/    --> id origem 
                             ,pr_cdoperad    => 996            --> Codigo do operador
                             ,pr_nmdatela    => pr_nmdatela    --> Identificador da tela da operacao
                             ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                             ,pr_inaprpen    => 1              --> Indicador de aprovação de transacao pendente
                             -----> OUT <----           
                             ,pr_dsretorn    => vr_dscritic    --> Mensagem de retorno             
                             ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                             ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                                  
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;  
        
        rw_contrato_sms.idcontrato := 0;
      END IF;
      
      RETURN;
    END IF;
    
    --> Buscar parametro de cobranca
    OPEN cr_cobran_prm;
    FETCH cr_cobran_prm INTO rw_cobran_prm;
    IF cr_cobran_prm%NOTFOUND THEN
      CLOSE cr_cobran_prm;
      vr_dscritic := 'Não foi possivel encontrar parametro de sms cobrança para esta cooperativa.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_cobran_prm;
    END IF;  
    
    --> Verificar se existe ceb ativo
    OPEN cr_crapceb;
    FETCH cr_crapceb INTO vr_existe;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      -- Se cooperado nao possuir ceb ativo, retornar zero na situação do serviço
      pr_flsitsms := 0;
      
      --> Verificar se possui contrato ativo
      IF NVL(rw_contrato_sms.idcontrato,0) > 0 THEN
        --> Canlemaneto do contrato de SMS ativo
        COBR0005.pc_cancel_contrato_sms 
                             (pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                             ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                             ,pr_idseqttl    => 1              --> Sequencial do titular
                             ,pr_idcontrato  => rw_contrato_sms.idcontrato  --> Numero do contrato de SMS
                             ,pr_idorigem    => 7   /*Batch-automatico*/    --> id origem 
                             ,pr_cdoperad    => 996            --> Codigo do operador
                             ,pr_nmdatela    => pr_nmdatela    --> Identificador da tela da operacao
                             ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                             ,pr_inaprpen    => 1              --> Indicador de aprovação de transacao pendente
                             -----> OUT <----           
                             ,pr_dsretorn    => vr_dscritic    --> Mensagem de retorno             
                             ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                             ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                                  
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;  
        
        rw_contrato_sms.idcontrato := 0;
      END IF;
      
      RETURN;
      
    END IF;
    CLOSE cr_crapceb;
        
    
    --> Buscar tarifas de sms já aderidas pelo cooperado
    FOR rw_tarifas IN cr_tarifas LOOP
    
      --> Buscar historico da tarifa
      OPEN cr_crapfvl(pr_cdcooper => pr_cdcooper ,
                      pr_cdtarifa => rw_tarifas.cdtarifa);
      FETCH cr_crapfvl INTO rw_crapfvl;
      CLOSE cr_crapfvl;
      
       
      --> Verificar se cooperado possui lançamentos pendentes acima 
      --> da quantidade de dias estabelecida pela coop
      OPEN cr_craplat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdhistor => rw_crapfvl.cdhistor,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                      pr_nrdialau => rw_cobran_prm.nrdiaslautom);
       FETCH cr_craplat INTO vr_qtlatpen;
       CLOSE cr_craplat;
       
       vr_tot_qtlatpen := vr_tot_qtlatpen + vr_qtlatpen; 

    END LOOP;
    
    --> Caso possuir lançamentos pendentes, cancelar serviço
    IF nvl(vr_tot_qtlatpen,0) > 0 THEN
      --> vr_dsalerta := 'Cooperado possui '||vr_tot_qtlatpen|| ' tarifa(s) de SMS de Cobrança pendente(s).';      
      vr_dsalerta := 'Há valores pendentes para regularização.';
      --> Verificar se possui contrato ativo
      IF rw_contrato_sms.idcontrato > 0 THEN
        --> Canlemaneto do contrato de SMS
        COBR0005.pc_cancel_contrato_sms 
                               (pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                               ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                               ,pr_idseqttl    => 1              --> Sequencial do titular
                               ,pr_idcontrato  => rw_contrato_sms.idcontrato  --> Numero do contrato de SMS
                               ,pr_idorigem    => 7 /*Batch-automatico*/    --> id origem 
                               ,pr_cdoperad    => 996            --> Codigo do operador
                               ,pr_nmdatela    => pr_nmdatela    --> Identificador da tela da operacao
                               ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                               ,pr_inaprpen    => 1              --> Indicador de aprovação de transacao pendente
                               -----> OUT <----           
                               ,pr_dsretorn   => vr_dscritic                --> Mensagem de retorno             
                               ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                               ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                                
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;  

        vr_dsalerta := vr_dsalerta||' O Contrato '|| rw_contrato_sms.idcontrato ||' foi cancelado automaticamente.';
        rw_contrato_sms.idcontrato := 0;
      END IF;
      
    END IF;
       
    IF vr_dsalerta IS NOT NULL THEN
      pr_flsitsms := 0;
      pr_dsalerta := vr_dsalerta;
    END IF;         
    
    --> Retornar numero do contrato ativo
    pr_idcontrato := rw_contrato_sms.idcontrato;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_verifar_serv_sms : '||SQLERRM;  
  END pc_verifar_serv_sms; 
  
  --> Rotina para verificar se serviço de SMS.
  PROCEDURE pc_verifar_serv_sms_web ( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                     ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                     ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                     ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_verifar_serv_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para verificar se serviço de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_idctrativ  tbcobran_sms_contrato.idcontrato%TYPE;
    vr_flsitsms   INTEGER;
    vr_dsalerta   VARCHAR2(4000);

    
    
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

    
    --> Rotina para verificar se serviço de SMS.
    pc_verifar_serv_sms(pr_cdcooper   => vr_cdcooper    --> Codigo da cooperativa
                       ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                       ,pr_nmdatela   => vr_nmdatela    --> Nome da tela
                       ,pr_idorigem   => vr_idorigem    --> Indicador de sistema origem
                       -----> OUT <----                                                                 
                       ,pr_idcontrato =>  vr_idctrativ  --> Retornar Numero do contratro ativo
                       ,pr_flsitsms   =>  vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                       ,pr_dsalerta   =>  vr_dsalerta   --> Retorna alerta para o cooperado
                       ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                       ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
  
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
   
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idctrativ'
                          ,pr_tag_cont => vr_idctrativ
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flsitsms'
                          ,pr_tag_cont => vr_flsitsms
                          ,pr_des_erro => vr_dscritic);
                          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dsalerta'
                          ,pr_tag_cont => vr_dsalerta
                          ,pr_des_erro => vr_dscritic);
    
                                               
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_verifar_serv_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_verifar_serv_sms_web; 
    
  --> Buscar informações dos contratos de serviço de SMS
  PROCEDURE pc_ret_dados_serv_sms (pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                                  ,pr_nmdatela      IN craptel.nmdatela%TYPE  --> Nome da tela
                                  ,pr_idorigem      IN INTEGER                --> Indicador de sistema origem
                                  -----> OUT <----                                   
                                  ,pr_nmprintl     OUT crapass.nmprimtl%TYPE  --> Nome principal do cooperado
                                  ,pr_nmfansia     OUT crapjur.nmfansia%TYPE  --> Nome fantasia do cooperado
                                  ,pr_tpnmemis     OUT tbcobran_sms_contrato.tpnome_emissao%TYPE --> Tipo de nome na emissao do SMS
                                  ,pr_nmemisms     OUT tbcobran_sms_contrato.nmemissao_sms%TYPE  --> Nome na emissao do SMS - Outro
                                  ,pr_flgativo     OUT INTEGER                                    --> Indicador de ativo
                                  ,pr_idpacote     OUT tbcobran_sms_contrato.idpacote%TYPE   --> identificador do pacote
                                  ,pr_dspacote     OUT tbcobran_sms_pacotes.dspacote%TYPE    --> Descrição do pacote
                                  ,pr_dhadesao     OUT tbcobran_sms_contrato.dhadesao%TYPE   --> Data hora de adesao
                                  ,pr_idcontrato   OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato
                                  ,pr_vltarifa     OUT crapfco.vltarifa%TYPE                 --> Valor da tarifa
                                  ,pr_flsitsms     OUT INTEGER                               --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                                  ,pr_dsalerta     OUT VARCHAR2                              --> Retorna alerta para o cooperado
                                  ,pr_qtsmspct     OUT tbcobran_sms_contrato.qtdsms_pacote%TYPE --> Retorna quantidade de sms contratada do pacote
                                  ,pr_qtsmsusd     OUT tbcobran_sms_contrato.qtdsms_usados%TYPE --> Retorna quantidade de sms ja utilizadas do pacote
                                  ,pr_dsmsgsemlinddig OUT VARCHAR2                                  
                                  ,pr_dsmsgcomlinddig OUT VARCHAR2                                  
                                  ,pr_cdcritic     OUT  INTEGER                 --> Retorna codigo de critica
                                  ,pr_dscritic     OUT  VARCHAR2) IS            --> Retorno de critica

  /* ............................................................................

       Programa: pc_consultar_dados_serv_SMS
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Buscar informações dos contratos de serviço de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar nome do titular
    CURSOR cr_crapttl IS
      SELECT ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1; 
        
    --> Buscar nome fantasia da pessoa juridica
    CURSOR cr_crapjur IS
      SELECT jur.nmfansia
        FROM crapjur jur 
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT pct.cdtarifa
            ,ctr.cdcooper
            ,pct.dspacote
            ,ctr.idpacote
            ,ctr.dhcancela
            ,ctr.idcontrato
            ,ctr.dhadesao
            ,ctr.tpnome_emissao
            ,ctr.nmemissao_sms
            ,ctr.qtdsms_pacote
            ,ctr.qtdsms_usados
            ,ass.nmprimtl
            ,ass.inpessoa
        FROM crapass ass
            ,tbcobran_sms_contrato ctr
            ,tbcobran_sms_pacotes  pct
       WHERE ctr.cdcooper = pct.cdcooper(+)
         AND ctr.idpacote = pct.idpacote(+)
         AND ctr.cdcooper = ass.cdcooper
         AND ctr.nrdconta = ass.nrdconta
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
      ORDER BY ctr.dhcancela DESC;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --> Buscar Valor tarifa
    CURSOR cr_crapfco(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
    SELECT fco.vltarifa
      FROM crapfco fco
          ,crapfvl fvl
     WHERE fco.cdcooper = pr_cdcooper
       AND fco.flgvigen = 1 --> ativa 
       AND fco.cdfaixav = fvl.cdfaixav 
       AND fvl.cdtarifa = pr_cdtarifa;
       
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE) IS
                      
     SELECT ass.nmprimtl
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_cdtarifa     craptar.cdtarifa%TYPE;
    vr_idctrativ    tbcobran_sms_contrato.idcontrato%TYPE;
    vr_nmremsms     VARCHAR2(1000);
    vr_valores_dinamicos VARCHAR2(1000);
    
  BEGIN
  
    --> Rotina para verificar se serviço de SMS.
    pc_verifar_serv_sms(pr_cdcooper   => pr_cdcooper    --> Codigo da cooperativa
                       ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                       ,pr_nmdatela   => pr_nmdatela    --> Nome da tela
                       ,pr_idorigem   => pr_idorigem    --> Indicador de sistema origem
                       -----> OUT <----                                                                 
                       ,pr_idcontrato =>  vr_idctrativ  --> Retornar Numero do contratro ativo
                       ,pr_flsitsms   =>  pr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                       ,pr_dsalerta   =>  pr_dsalerta   --> Retorna alerta para o cooperado
                       ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                       ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
  
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar dados do contrato de sms     
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO rw_contrato_sms;
    
    --> Senao encontrar registro, retorna com a flag de ativo = 0, para solicitar
    --> ativacao pelo cooperado
    IF cr_contrato_sms%NOTFOUND THEN
      CLOSE cr_contrato_sms;
      pr_flgativo := 0;
      RETURN;      
    ELSE
      CLOSE cr_contrato_sms;
      vr_cdtarifa   := rw_contrato_sms.cdtarifa;
      pr_dspacote   := rw_contrato_sms.dspacote;
      pr_idpacote   := rw_contrato_sms.idpacote;
      pr_idcontrato := rw_contrato_sms.idcontrato;
      pr_dhadesao   := rw_contrato_sms.dhadesao;
      
      pr_nmprintl  := rw_contrato_sms.nmprimtl;
      pr_tpnmemis  := rw_contrato_sms.tpnome_emissao;
      pr_nmemisms  := rw_contrato_sms.nmemissao_sms;
      
      pr_qtsmspct  := rw_contrato_sms.qtdsms_pacote;
      pr_qtsmsusd  := rw_contrato_sms.qtdsms_usados;
      
      IF rw_contrato_sms.inpessoa = 1 THEN
        --> buscar nome da titular
        OPEN cr_crapttl;
        FETCH cr_crapttl INTO pr_nmfansia;
        CLOSE cr_crapttl;
        
      ELSE
        --> Buscar nome fantasia
        OPEN cr_crapjur;
        FETCH cr_crapjur INTO pr_nmfansia;
        CLOSE cr_crapjur;      
      END IF;
      
     
    -- Definir nome de remetente para o SMS
    IF rw_contrato_sms.tpnome_emissao = 3 THEN
      vr_nmremsms := rw_contrato_sms.nmemissao_sms;
    --> se selecionou Razao social/Nome
    ELSIF rw_contrato_sms.tpnome_emissao = 1 THEN
      --> Buscar nome na crapass
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_nmremsms;
      CLOSE cr_crapass;
                    
    -- se selecionou Nome fantasia
    ELSIF rw_contrato_sms.tpnome_emissao = 2 THEN
                  
      -- Buscar nome na crapjur
      OPEN cr_crapjur;
      FETCH cr_crapjur INTO vr_nmremsms;
      CLOSE cr_crapjur;              

    END IF;  

 --> Variavel para SMS
    vr_valores_dinamicos := '#Nome#=' ||vr_nmremsms ||';'|| 
                            '#LinhaDigitavel#='|| '000000000000';
          
    --> buscar mensagem
    pr_dsmsgcomlinddig := GENE0003.fn_buscar_mensagem
                               (pr_cdcooper        => pr_cdcooper
                               ,pr_cdproduto       => 19
                               ,pr_cdtipo_mensagem => 9
                               ,pr_sms             => 1
                               ,pr_valores_dinamicos => vr_valores_dinamicos);
                               
    --> buscar mensagem
    pr_dsmsgsemlinddig := GENE0003.fn_buscar_mensagem
                               (pr_cdcooper        => pr_cdcooper
                               ,pr_cdproduto       => 19
                               ,pr_cdtipo_mensagem => 12
                               ,pr_sms             => 1
                               ,pr_valores_dinamicos => vr_valores_dinamicos);                               
    END IF;
    
    --> Se estiver cancelado, mandar como inativo, para solicitar
    --> ativacao pelo cooperado
    IF rw_contrato_sms.dhcancela IS NOT NULL THEN
      pr_flgativo := 0;
      RETURN;
    ELSE
      pr_flgativo := 1;
    END IF;
    
    --> Buscar Valor tarifa
    IF vr_cdtarifa IS NOT NULL THEN
      OPEN cr_crapfco(pr_cdcooper => pr_cdcooper ,
                      pr_cdtarifa => vr_cdtarifa);
      FETCH cr_crapfco INTO pr_vltarifa;
      CLOSE cr_crapfco;
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_ret_dados_serv_sms : '||SQLERRM;  
  END pc_ret_dados_serv_sms; 
  
  --> Buscar informações dos contratos de serviço de SMS - Web
  PROCEDURE pc_ret_dados_serv_sms_web ( pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numer de conta do cooperado                                     
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_ret_dados_serv_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Buscar informações dos contratos de serviço de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_nmprintl   crapass.nmprimtl%TYPE;  
    vr_nmfansia   crapjur.nmfansia%TYPE; 
    vr_tpnmemis   tbcobran_sms_contrato.tpnome_emissao%TYPE;
    vr_nmemisms   tbcobran_sms_contrato.nmemissao_sms%TYPE;
    vr_flgativo   INTEGER;    
    vr_idpacote   tbcobran_sms_pacotes.idpacote%TYPE;
    vr_dspacote   tbcobran_sms_pacotes.dspacote%TYPE;
    vr_dhadesao   tbcobran_sms_contrato.dhadesao%TYPE;
    vr_idcontrato tbcobran_sms_contrato.idcontrato%TYPE;
    vr_vltarifa   crapfco.vltarifa%TYPE;
    vr_flsitsms   INTEGER;
    vr_dsalerta   VARCHAR2(4000);
    vr_qtsmspct   tbcobran_sms_contrato.qtdsms_pacote%TYPE;
    vr_qtsmsusd   tbcobran_sms_contrato.qtdsms_usados%TYPE;
    vr_dsmsgsemlinddig VARCHAR2(1000);
    vr_dsmsgcomlinddig VARCHAR2(1000);

    
    
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

    pc_ret_dados_serv_sms (pr_cdcooper  => vr_cdcooper   --> Codigo da cooperativa
                          ,pr_nrdconta  => pr_nrdconta   --> Conta do associado
                          ,pr_nmdatela  => vr_nmdatela   --> Nome da tela
                          ,pr_idorigem  => vr_idorigem   --> Indicador de sistema origem
                          -----> OUT <----              
                          ,pr_nmprintl  => vr_nmprintl   --> Nome principal do cooperado
                          ,pr_nmfansia  => vr_nmfansia   --> Nome fantasia do cooperado
                          ,pr_tpnmemis  => vr_tpnmemis   --> Tipo de nome na emissao do SMS 
                          ,pr_nmemisms  => vr_nmemisms   --> Nome na emissao do SMS - Outro                                       
                          ,pr_flgativo  => vr_flgativo   --> Indicador de ativo
                          ,pr_idpacote  => vr_idpacote   --> identificador do pacote
                          ,pr_dspacote  => vr_dspacote   --> Descrição do pacote
                          ,pr_dhadesao  => vr_dhadesao   --> Data hora de adesao
                          ,pr_idcontrato=> vr_idcontrato --> Numero do contrato
                          ,pr_vltarifa  => vr_vltarifa   --> Valor da tarifa                          
                          ,pr_flsitsms  => vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                          ,pr_dsalerta  => vr_dsalerta   --> Retorna alerta para o cooperado
                          ,pr_qtsmspct  => vr_qtsmspct   --> Retorna quantidade de sms contratada do pacote
                          ,pr_qtsmsusd  => vr_qtsmsusd   --> Retorna quantidade de sms ja utilizadas do pacote
                          ,pr_dsmsgsemlinddig => vr_dsmsgsemlinddig
                          ,pr_dsmsgcomlinddig => vr_dsmsgcomlinddig
                          ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                          ,pr_dscritic  => vr_dscritic); --> Retorno de critica
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmprintl'
                          ,pr_tag_cont => vr_nmprintl
                          ,pr_des_erro => vr_dscritic);
  
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmfansia'
                          ,pr_tag_cont => vr_nmfansia
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmemisms'
                          ,pr_tag_cont => vr_nmemisms
                          ,pr_des_erro => vr_dscritic);
    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tpnmemis'
                          ,pr_tag_cont => vr_tpnmemis
                          ,pr_des_erro => vr_dscritic);
                          
                          
      
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flgativo'
                          ,pr_tag_cont => vr_flgativo
                          ,pr_des_erro => vr_dscritic);
    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idpacote'
                          ,pr_tag_cont => vr_idpacote
                          ,pr_des_erro => vr_dscritic);
      
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dspacote'
                          ,pr_tag_cont => vr_dspacote
                          ,pr_des_erro => vr_dscritic);
    
      
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dhadesao'
                          ,pr_tag_cont => to_char(vr_dhadesao,'DD/MM/RRRR')
                          ,pr_des_erro => vr_dscritic);
    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idcontrato'
                          ,pr_tag_cont => vr_idcontrato
                          ,pr_des_erro => vr_dscritic);
    
      
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'vltarifa'
                          ,pr_tag_cont => to_char(vr_vltarifa,'fm999G990D00',
                                                              'NLS_NUMERIC_CHARACTERS='',.''')
                          ,pr_des_erro => vr_dscritic);
                          
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flsitsms'
                          ,pr_tag_cont => vr_flsitsms
                          ,pr_des_erro => vr_dscritic);
                          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dsalerta'
                          ,pr_tag_cont => vr_dsalerta
                          ,pr_des_erro => vr_dscritic);
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qtsmspct'
                          ,pr_tag_cont => vr_qtsmspct
                          ,pr_des_erro => vr_dscritic);
                          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qtsmsusd'
                          ,pr_tag_cont => vr_qtsmsusd
                          ,pr_des_erro => vr_dscritic);                                            
    
                                               
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_consultar_dados_serv_SMS_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_ret_dados_serv_sms_web;  
  
  
  --> Rotina para geração do contrato de SMS
  PROCEDURE pc_gera_contrato_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                 ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                 ,pr_inaprpen    IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                 ,pr_idpacote    IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS
                                 ,pr_tpnmemis    IN tbcobran_sms_contrato.tpnome_emissao%TYPE DEFAULT 1   --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                                 ,pr_nmemissa    IN tbcobran_sms_contrato.nmemissao_sms%TYPE DEFAULT NULL --> Nome caso selecionado Outro
                                 -----> OUT <----                                   
                                 ,pr_idcontrato OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 ,pr_dsretorn   OUT  VARCHAR2                --> Mensagem de retorno             
                                 ,pr_cdcritic   OUT  INTEGER                 --> Retorna codigo de critica
                                 ,pr_dscritic   OUT  VARCHAR2) IS            --> Retorno de critica

  /* ............................................................................

       Programa: pc_gera_contrato_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para geração do contrato de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT ctr.idcontrato,
             ctr.idpacote
        FROM cecred.tbcobran_sms_contrato ctr
       WHERE ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.dhcancela IS NULL;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --> Buscar pacote de sms
    CURSOR cr_pacotes IS
      SELECT pct.idpacote,
             pct.cdtarifa
        FROM tbcobran_sms_pacotes pct,
             crapass ass  
       WHERE pct.cdcooper = ass.cdcooper
         AND pct.inpessoa = ass.inpessoa
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND pct.flgstatus = 1
         AND pct.idpacote IN (1,2);      
    
    --> Buscar Valor tarifa
    CURSOR cr_crapfco(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
    SELECT fco.vltarifa           
      FROM crapfco fco
          ,crapfvl fvl
     WHERE fco.cdcooper = pr_cdcooper
       AND fco.flgvigen = 1 --> ativa 
       AND fco.cdfaixav = fvl.cdfaixav 
       AND fvl.cdtarifa = pr_cdtarifa;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_idcontrato   INTEGER;
    vr_idctrnov     INTEGER;
    vr_idpacote_aux INTEGER;
    
    vr_dsorigem     craplgm.dsorigem%TYPE;
    vr_dstransa     craplgm.dstransa%TYPE;
    vr_nrdrowid     ROWID;
    vr_idpacote     tbcobran_sms_pacotes.idpacote%TYPE;
    vr_cdtarifa     tbcobran_sms_pacotes.cdtarifa%TYPE;
    vr_vltarifa     crapfco.vltarifa%TYPE;
    
    vr_idastcjt   INTEGER(1) := 0;
    vr_nrcpfcgc   INTEGER;
    vr_nmprimtl   VARCHAR2(500);
    vr_flcartma   INTEGER(1);		
    
    vr_tab_pacote TELA_CADSMS.typ_tab_pacote;
    vr_qtdsmspct  INTEGER := 0;
    vr_qtdsmsusd  INTEGER := 0;
    vr_vlunitario NUMBER;
    vr_vlpacote   NUMBER;
    
  BEGIN
    
    vr_dsorigem  := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa  := 'Inclusão de contrato de servico de SMS.'; 
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;
    
    vr_idctrnov := 0;
    
    --> Verificar se ja existe contrato ativo
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO vr_idcontrato,vr_idpacote_aux;
    IF cr_contrato_sms%FOUND THEN
      CLOSE cr_contrato_sms;
      
      IF nvl(pr_idpacote,0) <> nvl(vr_idpacote_aux,0) THEN
        
        vr_dstransa := 'Trocar pacote Contrato SMS de cobrança.';
        --> Rotina para realizar a troca do pacote de SMS
        COBR0005.pc_trocar_pacote_sms ( pr_cdcooper    => pr_cdcooper   --> Codigo da cooperativa
                                       ,pr_nrdconta    => pr_nrdconta   --> Conta do associado                             
                                       ,pr_idorigem    => pr_idorigem   --> id origem 
                                       ,pr_cdoperad    => pr_cdoperad   --> Codigo do operador
                                       ,pr_nmdatela    => pr_nmdatela   --> Identificador da tela da operacao                             
                                       ,pr_idpacote    => pr_idpacote   --> Identificador do pacote de SMS                                 ,
                                       ,pr_idctratu    => vr_idcontrato --> Numero do contrato de sms
                                       -----> OUT <----                                   
                                       ,pr_idctrnov    => pr_idcontrato   --> Numero do contrato de sms
                                       ,pr_dsretorn    => pr_dsretorn   --> Mensagem de retorno             
                                       ,pr_cdcritic    => vr_cdcritic   --> Retorna codigo de critica
                                       ,pr_dscritic    => vr_dscritic); --> Retorno de critica
               
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic)IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;           
      
      ELSE
        vr_dscritic := 'Já existe o contrato de numero '||vr_idcontrato||' ativo.';
        RAISE vr_exc_erro;
      
      END IF;
      
      
    ELSE
      CLOSE cr_contrato_sms;
    END IF;
    
    --> Verificar se nao gerou novo contrato pela troca de pacote
    IF nvl(pr_idcontrato,0) = 0 THEN
      --> buscar pacote caso nao seja informado
      IF nvl(pr_idpacote,0) = 0 THEN
        --> Buscar pacote de sms
        OPEN cr_pacotes;
        FETCH cr_pacotes INTO vr_idpacote, vr_cdtarifa;
        CLOSE cr_pacotes;
        
        IF vr_idpacote IS NULL THEN
          vr_dscritic := 'Nenhum pacote de SMS ativo.';
          RAISE vr_exc_erro;
        END IF;
      ELSE
        vr_idpacote := pr_idpacote;
      END IF;
      
      IF vr_idpacote > 2 THEN
      
        --> buscar dados do pacote
        TELA_CADSMS.pc_consultar_pacote(pr_idpacote   => vr_idpacote     --> Indicador do pacote
                                       ,pr_cdcooper   => pr_cdcooper     --> Codigo da cooperativa
                                       ,pr_tab_pacote => vr_tab_pacote   --> Retornar dados do pacote de SMS  
                                       ,pr_cdcritic   => vr_cdcritic     --> Codigo da critica
                                       ,pr_dscritic   => vr_dscritic );  --> Descricao da critica
      
        
        IF TRIM(vr_dscritic) IS NOT NULL OR 
           nvl(vr_cdcritic,0) > 0 THEN
          RAISE vr_exc_erro;        
        END IF;
        
        IF vr_tab_pacote.count() = 0 THEN
          vr_dscritic := 'Pacote '||vr_idpacote||' não encontrado.';
          RAISE vr_exc_erro;
        END IF; 
        
        
        vr_qtdsmspct  := vr_tab_pacote(vr_tab_pacote.first).qtdsms;
        vr_qtdsmsusd  := 0;
        vr_vlunitario := vr_tab_pacote(vr_tab_pacote.first).vlsmsad;
        vr_vlpacote   := vr_tab_pacote(vr_tab_pacote.first).vlpacote;
      
      ELSE
      
        vr_vlunitario := 0;
        
        --> Buscar Valor tarifa
        OPEN cr_crapfco(pr_cdcooper => pr_cdcooper,
                        pr_cdtarifa => vr_cdtarifa);
        FETCH cr_crapfco INTO vr_vlunitario;
        CLOSE cr_crapfco;
      
      
        vr_qtdsmspct   :=   0;
        vr_qtdsmsusd   :=   0;
        vr_vlpacote    :=   0;
        
      END IF;
      
      
      -- Se for 3 apenas valida criação do contrato
      IF pr_inaprpen = 3 THEN
        RETURN;
      END IF;
      
      --> Apenas validar assinatura para InternetBank
      IF pr_idorigem = 3 THEN
      
        -- Valida transação de representante legal
        INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)                                         
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

        -- Se houve crítica, gerar exceção
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 

        --Verifica se conta for conta PJ e se exige asinatura multipla
        INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdorigem => 3
                                           ,pr_idastcjt => vr_idastcjt
                                           ,pr_nrcpfcgc => vr_nrcpfcgc
                                           ,pr_nmprimtl => vr_nmprimtl
                                           ,pr_flcartma => vr_flcartma
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro; 
        END IF;                              								
      END IF;
      
      --> Inclusao de contrato efetuada por operador ou responsável de assinatura conjunta 
      IF (pr_nrcpfope > 0 OR vr_idastcjt = 1) AND pr_inaprpen = 0 THEN
        
        
        --> Necessario inclusao de transacao pensente
        INET0002.pc_cria_trans_pend_sms_cobran ( pr_cdagenci  => 90                   --> Codigo do PA
                                                ,pr_nrdcaixa  => 900                  --> Numero do Caixa
                                                ,pr_cdoperad  => pr_cdoperad          --> Codigo do Operados
                                                ,pr_nmdatela  => pr_nmdatela          --> Nome da Tela
                                                ,pr_idorigem  => pr_idorigem          --> Origem da solicitacao
                                                ,pr_idseqttl  => pr_idseqttl          --> Sequencial de Titular               
                                                ,pr_cdtiptra  => 16                   --> Tipo de transacao (16 - Adesao, 17 - Cancelamento)
                                                ,pr_nrcpfope  => pr_nrcpfope          --> Numero do cpf do operador juridico
                                                ,pr_nrcpfrep  => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END)          --> Numero do cpf do representante legal) 
                                                ,pr_cdcoptfn  => 0                    --> Cooperativa do Terminal
                                                ,pr_cdagetfn  => 0                    --> Agencia do Terminal
                                                ,pr_nrterfin  => 0                    --> Numero do Terminal Financeiro
                                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento     
                                                ,pr_cdcooper  => pr_cdcooper          --> Codigo da cooperativa
                                                ,pr_nrdconta  => pr_nrdconta          --> Numero da Conta
                                                ,pr_idoperac  => 1                    --> Identifica tipo da operacao (1 – Inclusao contraro SMS)
                                                ,pr_idastcjt  => vr_idastcjt          --> Indicador de Assinatura Conjunta
                                                ,pr_idpacote  => vr_idpacote          --> Codigo do pacote de SMS
                                                ,pr_vlservico => vr_vlpacote          --> valor de tarifa do SMS/Pacote de SMS
                                                ,pr_cdcritic  => vr_cdcritic          --> Codigo de Critica
                                                ,pr_dscritic  => vr_dscritic);        --> Descricao de Critica
      
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF; 
        
        IF vr_idastcjt = 1 THEN
          pr_dsretorn := 'Serviço de SMS registrado com sucesso. Aguardando aprovacao do registro pelos demais responsaveis.';
        ELSE
          pr_dsretorn := 'Serviço de SMS registrado com sucesso. Aguardando efetivacao do registro pelo preposto.';
        END IF;            
      
      ELSE
      
        BEGIN      
        
          INSERT INTO tbcobran_sms_contrato
                     ( cdcooper
                      ,nrdconta
                      ,idseqttl
                      ,idpacote
                      ,dhadesao
                      ,dhcancela
                      ,cdcanal_adesao 
                      ,cdcanal_cancela 
                      ,tpnome_emissao
                      ,nmemissao_sms
                      ,qtdsms_pacote
                      ,qtdsms_usados
                      ,vlunitario   
                      ,vlpacote)
               VALUES( pr_cdcooper              --> cdcooper
                      ,pr_nrdconta              --> nrdconta
                      ,pr_idseqttl              --> idseqttl
                      ,vr_idpacote              --> idpacote
                      ,SYSDATE                  --> dhadesao
                      ,NULL                     --> dhcancela
                      ,pr_idorigem              --> indorigem_adesao
                      ,NULL                     --> indorigem_cancela 
                      ,pr_tpnmemis              --> tpnome_emissao
                      ,pr_nmemissa              --> nmemissao_sms
                      ,vr_qtdsmspct             --> qtdsms_pacote
                      ,vr_qtdsmsusd             --> qtdsms_usados
                      ,vr_vlunitario            --> vlunitario   
                      ,vr_vlpacote )            --> vlpacote     
                      
              RETURNING idcontrato INTO vr_idcontrato;       
              
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel gravar contrato SMS:'|| SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        pr_idcontrato := vr_idcontrato;
        pr_dsretorn   := 'Ativação do serviço efetuada com sucesso.';
        
      END IF;
    END IF;
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NULL
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
      
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'contrato',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => pr_idcontrato);
    
    IF pr_nrcpfope > 0  THEN
			-- Operador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Operador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcpfope,1)); -- formatar CPF
	  END IF;
    
    IF trim(vr_nmprimtl) IS NOT NULL AND pr_nrcpfope <= 0 THEN
			-- Nome do representante/procurador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'Nome do Representante/Procurador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => vr_nmprimtl);
			
		END IF;
		
		IF vr_nrcpfcgc > 0 AND pr_nrcpfope <= 0 THEN
		  -- CPF do representante/procurador
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
															 ,pr_nmdcampo => 'CPF do Representante/Procurador'
															 ,pr_dsdadant => ' '
															 ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc, 1));
		END IF;
    
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'idpacote',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => vr_idpacote);
    
    
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
			   pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			ELSE	
			   pr_dscritic := vr_dscritic;
		  END IF;
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gera_contrato_sms : '||SQLERRM; 
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
          
       
  END pc_gera_contrato_sms; 
  
  --> Rotina para geração do contrato de SMS
  PROCEDURE pc_gera_contrato_sms_web (  pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numero de conta do cooperado
                                       ,pr_idseqttl   IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                       ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                       ,pr_inaprpen   IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                       ,pr_idpacote   IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_gera_contrato_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para geração do contrato de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_idcontrato tbcobran_sms_contrato.idcontrato%TYPE;
    vr_dsretorn   VARCHAR2(2000);
    
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

    --> Rotina para geração do contrato de SMS
    pc_gera_contrato_sms (pr_cdcooper  => vr_cdcooper  --> Codigo da cooperativa
                         ,pr_nrdconta  => pr_nrdconta  --> Conta do associado
                         ,pr_idseqttl  => pr_idseqttl  --> Sequencial do titular
                         ,pr_idorigem  => vr_idorigem  --> id origem 
                         ,pr_cdoperad  => vr_cdoperad  --> Codigo do operador
                         ,pr_nmdatela  => vr_nmdatela  --> Identificador da tela da operacao
                         ,pr_nrcpfope  => pr_nrcpfope  --> CPF do operador de conta juridica
                         ,pr_inaprpen  => pr_inaprpen  --> Indicador de aprovação de transacao pendente                         
                         ,pr_idpacote  => pr_idpacote  --> Identificador do pacote de SMS
                         -----> OUT <----                                   
                         ,pr_idcontrato=> vr_idcontrato --> Numero do contrato
                         ,pr_dsretorn  => vr_dsretorn   --> Mensagem de retorno
                         ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                         ,pr_dscritic  => vr_dscritic); --> Retorno de critica
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idcontrato'
                          ,pr_tag_cont => vr_idcontrato
                          ,pr_des_erro => vr_dscritic);    
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_gera_contrato_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_gera_contrato_sms_web; 
  
  --> Rotina para canlemaneto do contrato de SMS
  PROCEDURE pc_cancel_contrato_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                   ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                   ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                   ,pr_idorigem    IN INTEGER                --> id origem 
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                   ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE  --> CPF do operador de conta juridica
                                   ,pr_inaprpen    IN NUMBER                 --> Indicador de aprovação de transacao pendente
                                   -----> OUT <----                                   
                                   ,pr_dsretorn   OUT  VARCHAR2                --> Mensagem de retorno             
                                   ,pr_cdcritic   OUT  INTEGER                 --> Retorna codigo de critica
                                   ,pr_dscritic   OUT  VARCHAR2) IS            --> Retorno de critica

  /* ............................................................................

       Programa: pc_cancel_contrato_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para canlemaneto do contrato de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT ctr.idcontrato,
             ctr.idpacote
        FROM cecred.tbcobran_sms_contrato ctr
       WHERE ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.idcontrato = decode(pr_idcontrato,0,ctr.idcontrato,pr_idcontrato)
         AND ctr.dhcancela IS NULL;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --Selecionar titulares com senhas ativas 
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.tpdsenha = pr_tpdsenha;
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    -- Busca dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.cdagesic,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --> Buscar Valor tarifa
    CURSOR cr_crapfco(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
    SELECT fco.vltarifa           
      FROM crapfco fco
          ,crapfvl fvl
     WHERE fco.cdcooper = pr_cdcooper
       AND fco.flgvigen = 1 --> ativa 
       AND fco.cdfaixav = fvl.cdfaixav 
       AND fvl.cdtarifa = pr_cdtarifa;
    
    --> Buscar pacote de sms
    CURSOR cr_pacotes (pr_idpacote tbcobran_sms_pacotes.idpacote%TYPE)IS
      SELECT pct.idpacote,
             pct.cdtarifa
        FROM tbcobran_sms_pacotes pct
       WHERE pct.idpacote = pr_idpacote;   
    rw_pacotes cr_pacotes%ROWTYPE;
    
    --> Buscar boletos pendentes de envio de SMS
    CURSOR cr_crapcob (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT cob.nrcnvcob,
             cob.nrdocmto,
             cob.dtmvtolt
        FROM crapcob cob
      WHERE cob.cdcooper = pr_cdcooper
        AND cob.nrdconta = pr_nrdconta
        AND cob.incobran = 0
        AND cob.inavisms > 0
        AND (cob.insmsant = 1 OR 
             cob.insmsvct = 1 OR 
             cob.insmspos = 1);
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --vr_idcontrato   INTEGER;
    vr_dsorigem     craplgm.dsorigem%TYPE;
    vr_dstransa     craplgm.dstransa%TYPE;
    vr_nrdrowid     ROWID;
    vr_dsdmensg     VARCHAR2(4000);
    vr_dsdassun     crapmsg.dsdassun%TYPE;
    vr_dsdplchv     crapmsg.dsdplchv%TYPE;
    vr_vltarifa     crapfco.vltarifa%TYPE;
    
    vr_idastcjt   INTEGER(1) := 0;
    vr_nrcpfcgc   INTEGER;
    vr_nmprimtl   VARCHAR2(500);
    vr_flcartma   INTEGER(1);	
    
    
  BEGIN
  
    vr_dsorigem  := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa  := 'Cancelamento de contrato de servico de SMS.';
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;
  
    --> Verificar se ja existe contrato ativo
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO rw_contrato_sms;
    IF cr_contrato_sms%NOTFOUND THEN
      CLOSE cr_contrato_sms;
      IF nvl(pr_idcontrato,0) > 0 THEN
        vr_dscritic := 'Contrato '||pr_idcontrato||' não encontrado.';
      ELSE
        vr_dscritic := 'Nenhum contrato ativo foi encontrado.';
      END IF;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_contrato_sms;
    END IF;      
    
    -- Se for 3 apenas valida cancelamento do contrato
    IF pr_inaprpen = 3 THEN
      RETURN;
    END IF;       
    
    --> Apenas validar assinatura para InternetBank
    IF pr_idorigem = 3 THEN
    
      -- Valida transação de representante legal
      INET0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_flvldrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE 1 END)                                         
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      -- Se houve crítica, gerar exceção
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 

      --Verifica se conta for conta PJ e se exige asinatura multipla
      INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_cdorigem => 3
                                         ,pr_idastcjt => vr_idastcjt
                                         ,pr_nrcpfcgc => vr_nrcpfcgc
                                         ,pr_nmprimtl => vr_nmprimtl
                                         ,pr_flcartma => vr_flcartma
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) <> 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro; 
      END IF;                              								
		END IF;
    
    --> Inclusao de contrato efetuada por operador ou responsável de assinatura conjunta 
    IF (pr_nrcpfope > 0 OR vr_idastcjt = 1) AND pr_inaprpen = 0 THEN
      
      vr_vltarifa := 0;
      
      --> Buscar pacote de sms
      OPEN cr_pacotes (pr_idpacote => rw_contrato_sms.idpacote);
      FETCH cr_pacotes INTO rw_pacotes;
      CLOSE cr_pacotes;
      
      --> Buscar Valor tarifa
      OPEN cr_crapfco(pr_cdcooper => pr_cdcooper,
                      pr_cdtarifa => rw_pacotes.cdtarifa);
      FETCH cr_crapfco INTO vr_vltarifa;
      CLOSE cr_crapfco;
      
      --> Necessario inclusao de transacao pensente
      INET0002.pc_cria_trans_pend_sms_cobran ( pr_cdagenci  => 90                   --> Codigo do PA
                                              ,pr_nrdcaixa  => 900                  --> Numero do Caixa
                                              ,pr_cdoperad  => pr_cdoperad          --> Codigo do Operados
                                              ,pr_nmdatela  => pr_nmdatela          --> Nome da Tela
                                              ,pr_idorigem  => pr_idorigem          --> Origem da solicitacao
                                              ,pr_idseqttl  => pr_idseqttl          --> Sequencial de Titular               
                                              ,pr_cdtiptra  => 17                   --> Tipo de transacao (16 - Adesao, 17 - Cancelamento)
                                              ,pr_nrcpfope  => pr_nrcpfope          --> Numero do cpf do operador juridico
                                              ,pr_nrcpfrep  => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END)          --> Numero do cpf do representante legal) 
                                              ,pr_cdcoptfn  => 0                    --> Cooperativa do Terminal
                                              ,pr_cdagetfn  => 0                    --> Agencia do Terminal
                                              ,pr_nrterfin  => 0                    --> Numero do Terminal Financeiro
                                              ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento     
                                              ,pr_cdcooper  => pr_cdcooper          --> Codigo da cooperativa
                                              ,pr_nrdconta  => pr_nrdconta          --> Numero da Conta
                                              ,pr_idoperac  => 1                    --> Identifica tipo da operacao (1 – Inclusao contraro SMS)
                                              ,pr_idastcjt  => vr_idastcjt          --> Indicador de Assinatura Conjunta
                                              ,pr_idpacote  => rw_contrato_sms.idpacote          --> Codigo do pacote de SMS
                                              ,pr_vlservico => vr_vltarifa          --> valor de tarifa do SMS/Pacote de SMS
                                              ,pr_cdcritic  => vr_cdcritic          --> Codigo de Critica
                                              ,pr_dscritic  => vr_dscritic);        --> Descricao de Critica
    
      IF nvl(vr_cdcritic,0) <> 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF; 
      
      IF vr_idastcjt = 1 THEN
        pr_dsretorn := 'Solicitação de Cancelamento do serviço de SMS registrado com sucesso. Aguardando aprovacao do registro pelos demais responsaveis.';
      ELSE
        pr_dsretorn := 'Solicitação de Cancelamento do serviço de SMS registrado com sucesso. Aguardando efetivacao do registro pelo preposto.';
      END IF;
    
    ELSE
    
      BEGIN      
        --Alterar contrato incluindo data de cancelamento
        UPDATE tbcobran_sms_contrato
           SET dhcancela        = SYSDATE,
               cdcanal_cancela  = pr_idorigem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idcontrato = rw_contrato_sms.idcontrato;      
            
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel cancelar contrato:'|| SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --> Cancelar envio de SMSs pendentes
      BEGIN
        UPDATE tbcobran_sms
           SET tbcobran_sms.instatus_sms = 3
         WHERE tbcobran_sms.instatus_sms = 1
           AND tbcobran_sms.cdcooper = pr_cdcooper
           AND tbcobran_sms.nrdconta = pr_nrdconta;
      EXCEPTION     
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel cancelar envio de sms:'|| SQLERRM;
          RAISE vr_exc_erro;
      END;    
    
      --> Buscar boletos pendentes de envio de SMS
      FOR rw_crapcob IN cr_crapcob (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta) LOOP
                                   
        -- Procedure para Cancelar o envio de SMS
        COBR0007.pc_inst_canc_sms 
                             (pr_cdcooper  => pr_cdcooper         --> Codigo da cooperativa
                             ,pr_nrdconta  => pr_nrdconta         --> Numero da conta do cooperado
                             ,pr_nrcnvcob  => rw_crapcob.nrcnvcob --> Numero do Convenio
                             ,pr_nrdocmto  => rw_crapcob.nrdocmto --> Numero do documento
                             ,pr_dtmvtolt  => rw_crapcob.dtmvtolt --> Data de Movimentacao
                             ,pr_cdoperad  => 1                   --> Codigo do Operador
                             ,pr_nrremass  => 0                   --> Numero da Remessa
                             ,pr_cdcritic  => vr_cdcritic         --> Codigo da Critica
                             ,pr_dscritic  => vr_dscritic);       --> Descricao da critica
      
      
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
      END LOOP;
      
      
    
      pr_dsretorn   := 'Cancelamento do serviço efetuada com sucesso.';
    END IF;
    
    IF pr_idorigem = 7 THEN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RETURN;
      ELSE
        CLOSE cr_crapcop;
      END IF;
    
      vr_dsdassun := 'Cancelamento do Serviço de SMS de Cobrança'; 
      vr_dsdplchv := 'Cancelar SMS Cobrança'; 
      
      --> Buscar pessoas que possuem acesso a conta
      FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta
                                   ,pr_tpdsenha  => 1) LOOP
        --> buscar mensagem
        vr_dsdmensg := GENE0003.fn_buscar_mensagem
                                   (pr_cdcooper        => pr_cdcooper
                                   ,pr_cdproduto       => 19
                                   ,pr_cdtipo_mensagem => 15
                                   ,pr_sms             => 0
                                   ,pr_valores_dinamicos => NULL);
                                                                                    
        --> Insere na tabela de mensagens (CRAPMSG)
        GENE0003.pc_gerar_mensagem
                   (pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idseqttl => rw_crapsnh.idseqttl /* Titular */
                   ,pr_cdprogra => pr_nmdatela         /* Programa */
                   ,pr_inpriori => 0
                   ,pr_dsdmensg => vr_dsdmensg         /* corpo da mensagem */
                   ,pr_dsdassun => vr_dsdassun         /* Assunto */
                   ,pr_dsdremet => rw_crapcop.nmrescop 
                   ,pr_dsdplchv => vr_dsdplchv
                   ,pr_cdoperad => 1
                   ,pr_cdcadmsg => 0
                   ,pr_dscritic => vr_dscritic);                             
      END LOOP; -- Fim loop CRAPSNH 
    
    END IF;
    
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NULL
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
      
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'contrato',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => rw_contrato_sms.idcontrato);
   

    COMMIT;    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;      
			IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
			   pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			ELSE	
			   pr_dscritic := vr_dscritic;
		  END IF;
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_cancel_contrato_sms : '||SQLERRM;  
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
  END pc_cancel_contrato_sms; 
  
  --> Rotina para canlemaneto do contrato de SMS
  PROCEDURE pc_cancel_contrato_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                       ,pr_idseqttl    IN crapttl.idseqttl%TYPE  --> Sequencial do titular 
                                       ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS                                       
                                       ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_cancel_contrato_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para canlemaneto do contrato de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_dsretorn VARCHAR2(1000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

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

    --> Rotina para canlemaneto do contrato de SMS
    pc_cancel_contrato_sms (pr_cdcooper    => vr_cdcooper    --> Codigo da cooperativa
                           ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                           ,pr_idseqttl    => pr_idseqttl    --> Sequencial do titular 
                           ,pr_idcontrato  => pr_idcontrato  --> Numero do contrato de SMS
                           ,pr_idorigem    => vr_idorigem    --> id origem 
                           ,pr_cdoperad    => vr_cdoperad    --> Codigo do operador
                           ,pr_nmdatela    => vr_nmdatela    --> Identificador da tela da operacao
                           ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                           ,pr_inaprpen    => 0              --> Indicador de aprovação de transacao pendente
                           -----> OUT <----           
                           ,pr_dsretorn    => vr_dsretorn
                           ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                           ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_cancel_contrato_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_cancel_contrato_sms_web; 
  
  --> Rotina para impressao do contrato de servico de SMS
  PROCEDURE pc_imprim_contrato_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                   ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                   ,pr_idorigem    IN INTEGER                --> id origem 
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                   ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                   ,pr_dsiduser    IN VARCHAR2               --> id do usuario
                                   -----> OUT <----                                   
                                   ,pr_nmarqpdf   OUT VARCHAR2               --> Retorna o nome do relatorio gerado
                                   ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                   ,pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_cancel_contrato_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para impressao do contrato de servico de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT --> Dados coop
             cop.nmextcop,
             cop.nrdocnpj,
             cop.cdbcoctl,       
             cop.cdagectl,
             cop.nrctactl,
             cop.dsendweb,
             cop.nmcidade nmcidcop,
             --> dados associado
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa,
             ass.dtnasctl,
             --> Endereco
             enc.dsendere ||' '||enc.nrendere||', '||enc.nmbairro dsendere,
             enc.nmcidade,
             enc.cdufende,
             enc.nrcepend,
             --> Contrato
             ctr.idcontrato,
             pct.dspacote,
             ctr.dhadesao,
             ctr.idseqttl,
             pct.cdtarifa
        FROM tbcobran_sms_contrato ctr,
             tbcobran_sms_pacotes pct,
             crapenc enc,
             crapass ass,
             crapcop cop
       WHERE cop.cdcooper = ctr.cdcooper
         AND ctr.cdcooper = ass.cdcooper
         AND ctr.nrdconta = ass.nrdconta
         AND ass.cdcooper = enc.cdcooper(+)
         AND ass.nrdconta = enc.nrdconta(+)
         AND enc.idseqttl(+) = 1
         AND enc.tpendass(+) = DECODE(ass.inpessoa,1,10,2,9)
         AND ctr.idpacote = pct.idpacote
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.idcontrato = pr_idcontrato
         AND ctr.dhcancela IS NULL;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --> Buscar nome do titular
    CURSOR cr_crapttl ( pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_idseqttl crapsnh.idseqttl%TYPE)IS
      SELECT ttl.nmextttl,
             ttl.dsproftl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl; 
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --> Buscar pessoa que contratou o serviço 
    CURSOR cr_crapavt ( pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_idseqttl crapsnh.idseqttl%TYPE)IS
      SELECT nvl(trim(avt.nmdavali),ass.nmprimtl) nmdavali,
             avt.dsproftl
        FROM crapavt avt,
             crapass ass,
             crapsnh snh
       WHERE snh.cdcooper = avt.cdcooper
         AND snh.nrdconta = avt.nrdconta
         AND snh.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = ass.cdcooper(+)
         AND avt.nrdctato = ass.nrdconta(+)
         AND avt.tpctrato = 6
         AND snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = pr_idseqttl
         AND snh.tpdsenha = 1;
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar responsavel legal menor de idade
    CURSOR cr_crapcrl IS
      SELECT ass.nmprimtl
            ,ass.dsproftl
        FROM crapcrl crl
            ,crapass ass
       WHERE crl.nrctamen = pr_nrdconta
         AND crl.cdcooper = pr_cdcooper
         AND crl.cdcooper = ass.cdcooper
         AND crl.nrdconta = ass.nrdconta;
    rw_crapcrl cr_crapcrl%ROWTYPE;
    
    
    --> Buscar Valor tarifa
    CURSOR cr_crapfco(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
    SELECT fco.vltarifa
      FROM crapfco fco
          ,crapfvl fvl
     WHERE fco.cdcooper = pr_cdcooper
       AND fco.flgvigen = 1 --> ativa 
       AND fco.cdfaixav = fvl.cdfaixav 
       AND fvl.cdtarifa = pr_cdtarifa;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_des_reto     VARCHAR2(100);
    vr_tab_erro     GENE0001.typ_tab_erro; 
    
    vr_dsorigem     craplgm.dsorigem%TYPE;
    vr_dstransa     craplgm.dstransa%TYPE;
    vr_nrdrowid     ROWID;
    vr_dtmvtolt_ext VARCHAR2(500);
    vr_nrdidade     INTEGER;
    vr_nmrepres     VARCHAR2(80);
    vr_dsdcargo     VARCHAR2(80);
    vr_vltarifa     crapfco.vltarifa%TYPE;
    
    vr_dsdireto     VARCHAR2(4000);
    vr_dscomand     VARCHAR2(4000);
    vr_typsaida     VARCHAR2(100); 
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml      CLOB;
    vr_txtcompl     VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
  
    vr_dsorigem  := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa  := 'Impressao de contrato de servico de SMS.';
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;  
    
    --> Verificar se ja existe contrato ativo
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO rw_contrato_sms;
    IF cr_contrato_sms%NOTFOUND THEN
      CLOSE cr_contrato_sms;
      vr_dscritic := 'Contrato '||pr_idcontrato||' não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_contrato_sms;
    END IF;
    
    IF rw_contrato_sms.inpessoa = 2 THEN
      
      --> Buscar pessoa que contratou o serviço 
      OPEN cr_crapavt ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => rw_contrato_sms.idseqttl);
      FETCH cr_crapavt INTO rw_crapavt;
      CLOSE cr_crapavt;
      
      vr_nmrepres := rw_crapavt.nmdavali;
      vr_dsdcargo := rw_crapavt.dsproftl;
      
    ELSE 
      
      vr_nrdidade := cada0001.fn_busca_idade(pr_dtnascto => rw_contrato_sms.dtnasctl,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt);
      
      IF vr_nrdidade >= 18 THEN
        --> Buscar nome do titular
        OPEN cr_crapttl ( pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_idseqttl => rw_contrato_sms.idseqttl);
        FETCH cr_crapttl INTO rw_crapttl;
        CLOSE cr_crapttl;
        
        vr_nmrepres := rw_crapttl.nmextttl;
        vr_dsdcargo := rw_crapttl.dsproftl;
      ELSE
        --> Buscar responsavel legal menor de idade
        OPEN cr_crapcrl;
        FETCH cr_crapcrl INTO rw_crapcrl;
        CLOSE cr_crapcrl;
        
        vr_nmrepres := rw_crapcrl.nmprimtl;
        vr_dsdcargo := rw_crapcrl.dsproftl;
         
      END IF;
    
      
    END IF;
    
    IF TRIM(rw_contrato_sms.nmcidade) IS NULL THEN
      vr_dscritic := 'Endereço do cooperado não encontrados ou incompleto.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar Valor tarifa
    IF rw_contrato_sms.cdtarifa IS NOT NULL THEN
      OPEN cr_crapfco(pr_cdcooper => pr_cdcooper ,
                      pr_cdtarifa => rw_contrato_sms.cdtarifa);
      FETCH cr_crapfco INTO vr_vltarifa;
      CLOSE cr_crapfco;
    END IF;
    
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    vr_dtmvtolt_ext := gene0005.fn_data_extenso(pr_dtmvtolt => rw_crapdat.dtmvtolt);
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
    pc_escreve_xml('<contrato>'||
                         --> Dados coop
                         '<nmextcop>'||  rw_contrato_sms.nmextcop    ||'</nmextcop>'||
                         '<nrdocnpj>'||  gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_contrato_sms.nrdocnpj,
                                                                   pr_inpessoa => 2)    ||'</nrdocnpj>'||
                         '<cdbcoctl>'||  rw_contrato_sms.cdbcoctl    ||'</cdbcoctl>'||   
                         '<cdagectl>'||  rw_contrato_sms.cdagectl    ||'</cdagectl>'||
                         '<dsendweb>'||  rw_contrato_sms.dsendweb    ||'</dsendweb>'||
                         '<nmcidcop>'||  rw_contrato_sms.nmcidcop    ||'</nmcidcop>'||
                         '<dtmvtolt_ext>'||  vr_dtmvtolt_ext      ||'</dtmvtolt_ext>'||
                         
                           --> dados associado
                         '<nrdconta>'||  TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'</nrdconta>'||
                         '<nrcpfcgc>'||  gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_contrato_sms.nrcpfcgc,
                                                                   pr_inpessoa => rw_contrato_sms.inpessoa)  ||'</nrcpfcgc>'||
                         '<nmprimtl>'||  rw_contrato_sms.nmprimtl    ||'</nmprimtl>'||
                         '<inpessoa>'||  rw_contrato_sms.inpessoa    ||'</inpessoa>'||
                         '<nmrepres>'||  vr_nmrepres                 ||'</nmrepres>'||
                         '<dsdcargo>'||  vr_dsdcargo                 ||'</dsdcargo>'||
                           --> Endereco
                         '<dsendere>'||  rw_contrato_sms.dsendere    ||'</dsendere>'||
                         '<nmcidade>'||  rw_contrato_sms.nmcidade    ||'</nmcidade>'||
                         '<cdufende>'||  rw_contrato_sms.cdufende    ||'</cdufende>'||
                         '<nrcepend>'||  rw_contrato_sms.nrcepend    ||'</nrcepend>'||
                           --> Contrato
                         '<idcontrato>'||  gene0002.fn_mask_contrato(rw_contrato_sms.idcontrato)||'</idcontrato>'||
                         '<dspacote>'||  rw_contrato_sms.dspacote    ||'</dspacote>'||  
                         '<dhadesao>'||  to_char(rw_contrato_sms.dhadesao,'DD/MM/RRRR HH24:MI:SS')   ||'</dhadesao>'||
                         '<vltarifa>'||  to_char(nvl(vr_vltarifa,0),'999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''')    ||'</vltarifa>'||  
                         
                   '</contrato>');
    
    pc_escreve_xml('</raiz>',TRUE);
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
      
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl729_'||pr_dsiduser||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
      
      
    pr_nmarqpdf := 'crrl729_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';
      
      
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'ATENDA'
                               , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/contrato'
                               , pr_dsjasper  => 'crrl729.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 729
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

      
    --> AyllosWeb
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
        
    ELSIF pr_idorigem = 3 THEN
      
      -- Copia o PDF para o IB
      GENE0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper,
                                      pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf,
                                      pr_des_erro => vr_dscritic);
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;  
    
    
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NULL
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
      
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'contrato',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => pr_idcontrato);
   
    COMMIT;    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_imprim_contrato_sms : '||SQLERRM;  
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
  END pc_imprim_contrato_sms;     
  
  --> Rotina para impressao do contrato de servico de SMS - Web
  PROCEDURE pc_imprim_contrato_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                       ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                       ,pr_dsiduser    IN VARCHAR2               --> id do usuario                                       
                                       ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_imprim_contrato_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para impressao do contrato de servico de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_nmarqpdf VARCHAR2(100);
    
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

    
    --> Rotina para impressao do contrato de servico de SMS
    pc_imprim_contrato_sms (pr_cdcooper    => vr_cdcooper    --> Codigo da cooperativa
                           ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                           ,pr_idcontrato  => pr_idcontrato  --> Numero do contrato de SMS
                           ,pr_idorigem    => vr_idorigem    --> id origem 
                           ,pr_cdoperad    => vr_cdoperad    --> Codigo do operador
                           ,pr_nmdatela    => vr_nmdatela    --> Identificador da tela da operacao
                           ,pr_dsiduser    => pr_dsiduser    --> id do usuario
                           -----> OUT <----                                   
                           ,pr_nmarqpdf    => vr_nmarqpdf    --> Retorna o nome do relatorio gerado
                           ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                           ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                   
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmarqpdf
                          ,pr_des_erro => vr_dscritic);
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_imprim_contrato_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_imprim_contrato_sms_web; 
  
  --> Rotina para impressao do termo de cancelamento de servico de SMS
  PROCEDURE pc_imprim_cancel_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                 ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao
                                 ,pr_dsiduser    IN VARCHAR2               --> id do usuario
                                 -----> OUT <----                                   
                                 ,pr_nmarqpdf   OUT VARCHAR2               --> Retorna o nome do relatorio gerado
                                 ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                 ,pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_imprim_cancel_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para impressao do termo de cancelamento de servico de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_contrato_sms IS
      SELECT --> Dados coop
             cop.nmextcop,
             cop.nrdocnpj,
             cop.dsendweb,
             cop.nmcidade nmcidcop,
             --> dados associado
             ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa,
             --> Contrato
             ctr.idcontrato,
             pct.dspacote,
             ctr.dhadesao,
             ctr.dhcancela,
             ctr.idseqttl
        FROM tbcobran_sms_contrato ctr,
             tbcobran_sms_pacotes pct,
             crapass ass,
             crapcop cop
       WHERE cop.cdcooper = ctr.cdcooper
         AND ctr.cdcooper = ass.cdcooper
         AND ctr.nrdconta = ass.nrdconta
         AND ctr.idpacote = pct.idpacote
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.idcontrato = pr_idcontrato
         AND ctr.dhcancela IS NOT NULL;
    rw_contrato_sms cr_contrato_sms%ROWTYPE;
    
    --> Buscar nome do titular
    CURSOR cr_crapttl ( pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_idseqttl crapsnh.idseqttl%TYPE)IS
      SELECT ttl.nmextttl,
             ttl.dsproftl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl; 
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --> Buscar pessoa que contratou o serviço 
    CURSOR cr_crapavt ( pr_cdcooper crapsnh.cdcooper%TYPE,
                        pr_nrdconta crapsnh.nrdconta%TYPE,
                        pr_idseqttl crapsnh.idseqttl%TYPE)IS
      SELECT nvl(trim(avt.nmdavali),ass.nmprimtl) nmdavali,
             avt.dsproftl
        FROM crapavt avt,
             crapass ass,
             crapsnh snh
       WHERE snh.cdcooper = avt.cdcooper
         AND snh.nrdconta = avt.nrdconta
         AND snh.nrcpfcgc = avt.nrcpfcgc
         AND avt.cdcooper = ass.cdcooper(+)
         AND avt.nrdctato = ass.nrdconta(+)
         AND avt.tpctrato = 6
         AND snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = pr_idseqttl
         AND snh.tpdsenha = 1;
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar responsavel legal menor de idade
    CURSOR cr_crapcrl IS
      SELECT ass.nmprimtl
            ,ass.dsproftl
        FROM crapcrl crl
            ,crapass ass
       WHERE crl.nrctamen = pr_nrdconta
         AND crl.cdcooper = pr_cdcooper
         AND crl.cdcooper = ass.cdcooper
         AND crl.nrdconta = ass.nrdconta;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_des_reto     VARCHAR2(100);
    vr_tab_erro     GENE0001.typ_tab_erro; 
    
    vr_dsorigem     craplgm.dsorigem%TYPE;
    vr_dstransa     craplgm.dstransa%TYPE;
    vr_nrdrowid     ROWID;
    vr_dtmvtolt_ext VARCHAR2(500);
    
    vr_dsdireto     VARCHAR2(4000);
    vr_dscomand     VARCHAR2(4000);
    vr_typsaida     VARCHAR2(100); 
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml      CLOB;
    vr_txtcompl     VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
  
    vr_dsorigem  := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa  := 'Impressao de termo de cancelamento de contrato de servico de SMS.';
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;  
    
    --> Verificar se ja existe contrato ativo
    OPEN cr_contrato_sms;
    FETCH cr_contrato_sms INTO rw_contrato_sms;
    IF cr_contrato_sms%NOTFOUND THEN
      CLOSE cr_contrato_sms;
      vr_dscritic := 'Contrato '||pr_idcontrato||' não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_contrato_sms;
    END IF;
    
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    vr_dtmvtolt_ext := gene0005.fn_data_extenso(pr_dtmvtolt => rw_crapdat.dtmvtolt);
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
    pc_escreve_xml('<contrato>'||
                         --> Dados coop
                         '<nmextcop>'||  rw_contrato_sms.nmextcop    ||'</nmextcop>'||
                         '<nrdocnpj>'||  gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_contrato_sms.nrdocnpj,
                                                                   pr_inpessoa => 2)    ||'</nrdocnpj>'||                         
                         '<dsendweb>'||  rw_contrato_sms.dsendweb    ||'</dsendweb>'||
                         '<nmcidcop>'||  rw_contrato_sms.nmcidcop    ||'</nmcidcop>'||
                         '<dtmvtolt_ext>'||  vr_dtmvtolt_ext      ||'</dtmvtolt_ext>'||
                         
                           --> dados associado
                         '<nrdconta>'||  TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'</nrdconta>'||
                         '<nrcpfcgc>'||  gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_contrato_sms.nrcpfcgc,
                                                                   pr_inpessoa => rw_contrato_sms.inpessoa)  ||'</nrcpfcgc>'||
                         '<nmprimtl>'||  rw_contrato_sms.nmprimtl    ||'</nmprimtl>'||
                         '<inpessoa>'||  rw_contrato_sms.inpessoa    ||'</inpessoa>'||
                           --> Contrato
                         '<idcontrato>'||  gene0002.fn_mask_contrato(rw_contrato_sms.idcontrato)||'</idcontrato>'||
                         '<dspacote>'||  rw_contrato_sms.dspacote    ||'</dspacote>'||  
                         '<dhadesao>'||   to_char(rw_contrato_sms.dhadesao,'DD/MM/RRRR HH24:MI:SS')    ||'</dhadesao>'||
                         '<dhcancela>'||  to_char(rw_contrato_sms.dhcancela,'DD/MM/RRRR HH24:MI:SS')   ||'</dhcancela>'||                         
                   '</contrato>');
    
    pc_escreve_xml('</raiz>',TRUE);
    
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => '/rl');
      
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl730_'||pr_dsiduser||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
      
      
    pr_nmarqpdf := 'crrl730_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';
      
      
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'ATENDA'
                               , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/contrato'
                               , pr_dsjasper  => 'crrl730.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 730
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
      
    --> AyllosWeb
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
        
    END IF;  
    
    
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NULL
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
      
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'contrato',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => pr_idcontrato);
   
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_imprim_cancel_sms : '||SQLERRM;  
      
      ROLLBACK;
      
      -- Gerar log ao cooperado (b1wgen0014 - gera_log);
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'contrato',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_idcontrato);
      
  END pc_imprim_cancel_sms; 
  
  --> Rotina para impressao do termo de cancelamento de servico de SMS - Chamada ayllos Web
  PROCEDURE pc_imprim_cancel_sms_web (pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                     ,pr_idcontrato  IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de SMS
                                     ,pr_dsiduser    IN VARCHAR2               --> id do usuario                                       
                                     ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                     ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                     ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_imprim_cancel_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para impressao do termo de cancelamento de servico de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_nmarqpdf VARCHAR2(100);
    
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

    
    --> Rotina para impressao do contrato de servico de SMS
    pc_imprim_cancel_sms (pr_cdcooper    => vr_cdcooper    --> Codigo da cooperativa
                         ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                         ,pr_idcontrato  => pr_idcontrato  --> Numero do contrato de SMS
                         ,pr_idorigem    => vr_idorigem    --> id origem 
                         ,pr_cdoperad    => vr_cdoperad    --> Codigo do operador
                         ,pr_nmdatela    => vr_nmdatela    --> Identificador da tela da operacao
                         ,pr_dsiduser    => pr_dsiduser    --> id do usuario
                         -----> OUT <----                                   
                         ,pr_nmarqpdf    => vr_nmarqpdf    --> Retorna o nome do relatorio gerado
                         ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                         ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                   
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmarqpdf
                          ,pr_des_erro => vr_dscritic);
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_imprim_cancel_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_imprim_cancel_sms_web; 
  
  --> Rotina para identificar os SMSs de cobrança pendente de envio e realizar o envio
  PROCEDURE pc_verifica_sms_a_enviar (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                     -----> OUT <----                                   
                                     ,pr_cdcritic   OUT  INTEGER               --> Retorna codigo de critica
                                     ,pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_verifica_sms_a_enviar
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : novembro/2016                     Ultima atualizacao: 14/03/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para identificar os SMSs de cobrança pendente de envio 
                   e realizar o envio

       Alteracoes: 14/03/2017 - Ajuste no select do cursor cr_sms_cobran (Aline)

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar cooperativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             prm.flglinha_digitavel
        FROM crapcop cop,
             tbcobran_sms_param_coop prm
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
         AND cop.flgativo = 1
         AND cop.cdcooper = prm.cdcooper;
    
    --> Buscar cooperados que possuem SMS Pendente
    CURSOR cr_ass_sms (pr_cdcooper crapcop.cdcooper%TYPE)IS
      SELECT DISTINCT cdcooper
                     ,nrdconta
        FROM TBCOBRAN_SMS
       WHERE cdcooper = pr_cdcooper
         AND instatus_sms = 1;
    
    --> Buscar SMS pendentes para o envio
    CURSOR cr_sms_cobran (pr_cdcooper crapcop.cdcooper%TYPE) IS    
      SELECT SUBSTR(sab.nrcelsac, 1, 2) as ddd
            ,SUBSTR(sab.nrcelsac, 3, 9) as celular
            ,cob.rowid rowid_cob
            ,cob.dtvencto
            ,cob.cdcooper
            ,cob.nrdconta
            ,pct.cdtarifa
            ,cob.inavisms
            ,cob.vlabatim
            ,cob.vlrmulta
            ,cob.tpdmulta
            ,cob.vljurdia
            ,cob.tpjurmor
            ,cob.vltitulo
            ,cob.cdbandoc
            ,cob.nrcnvcob
            ,cob.nrdocmto
            ,cob.cdcartei
            ,sms.idsms
            ,sms.rowid rowid_sms
            ,ctr.tpnome_emissao
            ,ctr.nmemissao_sms
            ,ctr.idcontrato
        FROM crapcob               cob
            ,tbcobran_sms          sms
            ,crapsab               sab
            ,tbcobran_sms_contrato ctr
            ,tbcobran_sms_pacotes  pct
       WHERE cob.cdcooper = sms.cdcooper
         AND cob.cdbandoc = sms.cdbandoc
         AND cob.nrdctabb = sms.nrdctabb
         AND cob.nrcnvcob = sms.nrcnvcob
         AND cob.nrdconta = sms.nrdconta
         AND cob.nrdocmto = sms.nrdocmto
         AND cob.cdcooper = sab.cdcooper
         AND cob.nrdconta = sab.nrdconta
         AND cob.nrinssac = sab.nrinssac
         AND cob.cdcooper = ctr.cdcooper
         AND cob.nrdconta = ctr.nrdconta
         AND ctr.dhcancela IS null
		 AND ctr.cdcooper = pct.cdcooper
         AND ctr.idpacote = pct.idpacote 
         AND cob.cdcooper = pr_cdcooper
         AND sab.nrcelsac <> 0 --ativo
         AND substr(sab.nrcelsac, 3, 9) > 69999999 -- –apenas celular
         AND sms.instatus_sms = 1; -- indicador que é para enviar o sms            

    --> Buscar nome fantasia da pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT jur.nmfansia
        FROM crapjur jur 
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    
    --> Buscar nome associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
              
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -------------->> TEMP-Table <<---------------
    TYPE typ_tab_serv_inativo IS TABLE OF PLS_INTEGER
         INDEX BY PLS_INTEGER;
    vr_tab_serv_inativo typ_tab_serv_inativo;
      
    -------------->> VARIAVEIS <<----------------
    vr_nomdojob     CONSTANT VARCHAR2(100) := 'JBCOBRAN_SMS_ENVIAR';
    vr_flgerlog     BOOLEAN := FALSE;  
    
    vr_nmarqlog     VARCHAR2(50);
    vr_dscdolog     VARCHAR2(2000);
    
    vr_exc_erro     EXCEPTION;
    vr_next_coop    EXCEPTION;
    vr_next         EXCEPTION;
    vr_next_sms     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_idctrati     tbcobran_sms_contrato.idcontrato%TYPE;
    vr_flsitsms     INTEGER;
    vr_dsalerta     VARCHAR2(4000);
    
    vr_flgerlot     BOOLEAN;
    vr_idlote_sms   tbgen_sms_lote.idlote_sms%TYPE;
    vr_idsms        tbgen_sms_controle.idsms%TYPE;
    
    
    vr_nrdconta_aux crapass.nrdconta%TYPE;
    vr_dslindig     VARCHAR2(500);
    vr_nmremsms     VARCHAR2(500);
    vr_dsdmensa     VARCHAR2(500);    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- procedimento para gerar log da debtar
    PROCEDURE pc_gera_log(pr_idtiplog IN NUMBER DEFAULT 1,
                          pr_dscdolog IN VARCHAR2) IS
    BEGIN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => pr_idtiplog
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || vr_nomdojob || ' --> '
                                                 || pr_dscdolog );
    END pc_gera_log;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => NULL           --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
    --> Procedimento para montar a linha digitavel do boleto
    PROCEDURE pc_ret_linha_digitavel (pr_rowid_cob IN ROWID,
                                      pr_dtmvtolt  IN DATE,
                                      pr_dslindig OUT VARCHAR2,
                                      pr_dscritic OUT VARCHAR2) IS
    
      --> buscar boleto
      CURSOR cr_crapcob IS
        SELECT cob.cdcooper,
               cob.nrdconta,               
               cob.cdbandoc,
               cob.nrcnvcob,
               cob.nrdocmto,
               cob.vltitulo,
               cob.vlmulpag,
               cob.vlabatim,
               cob.tpjurmor,
               cob.tpdmulta,
               cob.dtvencto,
               cob.vlrmulta,
               cob.vljurdia,
               cob.cdcartei,
               ceb.nrcnvceb
          FROM crapcob cob,
               crapceb ceb              
         WHERE cob.rowid    = pr_rowid_cob
           AND cob.cdcooper = ceb.cdcooper
           AND cob.nrdconta = ceb.nrdconta
           AND cob.nrcnvcob = ceb.nrconven;
      rw_crapcob cr_crapcob%ROWTYPE;
      
      
      -------------->> VARIAVEIS <<----------------
      vr_vlfatura   crapcob.vltitulo%TYPE;
      vr_vlrmulta   crapcob.vltitulo%TYPE;
      vr_vlrjuros   crapcob.vltitulo%TYPE;
      vr_cdbarras   VARCHAR2(60);
      vr_dslindig   VARCHAR2(60);
      vr_dtvencto   DATE;
         
    BEGIN
      
      --> Buscar boleto
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_crapcob;
      IF cr_crapcob%NOTFOUND THEN
        CLOSE cr_crapcob;
        vr_dscritic := 'Cobrança não encontrada.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcob;
      END IF;
    
      -- Busca valor de multa
      vr_vlfatura := rw_crapcob.vltitulo;
      -- Abatimento deve ser calculado antes dos juros/multa
      IF rw_crapcob.vlabatim > 0 THEN
        vr_vlfatura := vr_vlfatura - rw_crapcob.vlabatim;
      END IF;
      vr_vlrmulta := 0;

      --Se o boleto estiver vencido, calcular o valor da multa:
      IF rw_crapcob.dtvencto < pr_dtmvtolt THEN
      
        vr_dtvencto := pr_dtmvtolt;
      
        --> Valor
        IF rw_crapcob.tpdmulta = 1 THEN 
          vr_vlrmulta := rw_crapcob.vlrmulta;
        --> % de multa  
        ELSIF rw_crapcob.tpdmulta = 2 THEN 
          vr_vlrmulta := (rw_crapcob.vlrmulta * vr_vlfatura) / 100;
        END IF;

        --> MORA PARA ATRASO 
        vr_vlrjuros := 0;
        --> dias 
        IF rw_crapcob.tpjurmor = 1 THEN 
          vr_vlrjuros := rw_crapcob.vljurdia * (vr_dtvencto - rw_crapcob.dtvencto);
        --> Mes  
        ELSIF rw_crapcob.tpjurmor = 2 THEN
          vr_vlrjuros := (vr_vlfatura * ((rw_crapcob.vljurdia / 100) / 30) *
                                         (vr_dtvencto - rw_crapcob.dtvencto));
        END IF;
        
      ELSE 
        vr_dtvencto := rw_crapcob.dtvencto;
      END IF;
      
      -- Busca o codigo de barras
      -- Obs.: calcular codigo de barras com o valor atualizado
      cobr0005.pc_calc_codigo_barras
                 (pr_dtvencto => vr_dtvencto,
                  pr_cdbandoc => rw_crapcob.cdbandoc,
                  pr_vltitulo => nvl(rw_crapcob.vltitulo,0) + nvl(vr_vlrjuros,0) + nvl(vr_vlrmulta,0),
                  pr_nrcnvcob => rw_crapcob.nrcnvcob,
                  pr_nrcnvceb => rw_crapcob.nrcnvceb,
                  pr_nrdconta => rw_crapcob.nrdconta,
                  pr_nrdocmto => rw_crapcob.nrdocmto,
                  pr_cdcartei => rw_crapcob.cdcartei,
                  pr_cdbarras => vr_cdbarras);

      -- Busca a linha digitavel
      cobr0005.pc_calc_linha_digitavel
                  (pr_cdbarras => vr_cdbarras,
                   pr_lindigit => vr_dslindig);
    
    
      pr_dslindig := vr_dslindig;
    EXCEPTION 
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel gerar linha digitavel: '||SQLERRM;
    END pc_ret_linha_digitavel;
    
    --> Retornar mensagem 
    FUNCTION fn_mensagem_vencto ( pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_dslindig IN VARCHAR2              --> Linha digitavel
                                 ,pr_nmremsms IN VARCHAR2              --> Nome do remetente de SMS
                                 ,pr_dtvencto IN crapcob.dtvencto%TYPE --> Data de vencimento do boleto
                                 ,pr_dtmvtolt IN DATE                  --> Data atual do sistema
                                 )RETURN VARCHAR2 IS      
      
      -------------->> VARIAVEIS <<----------------
      vr_valores_dinamicos  VARCHAR2(200);
      vr_dsdmensg           VARCHAR2(500);
      vr_cdtpmens           INTEGER;
      
    BEGIN
      
      IF pr_dslindig IS NOT NULL THEN
        --> Antes do vencimento
        IF pr_dtvencto > pr_dtmvtolt THEN
          vr_cdtpmens := 8;
        --> No dia do vencimento  
        ELSIF pr_dtvencto = pr_dtmvtolt THEN
          vr_cdtpmens := 9;
        --> apos o vencimento
        ELSIF pr_dtvencto < pr_dtmvtolt THEN
          vr_cdtpmens := 10;
        END IF;   
      ELSE
        --> Antes do vencimento
        IF pr_dtvencto > pr_dtmvtolt THEN
          vr_cdtpmens := 11;
        --> No dia do vencimento  
        ELSIF pr_dtvencto = pr_dtmvtolt THEN
          vr_cdtpmens := 12;
        --> apos o vencimento
        ELSIF pr_dtvencto < pr_dtmvtolt THEN
          vr_cdtpmens := 13;
        END IF;
      END IF;
      
      
      --> Variavel para SMS
      vr_valores_dinamicos := '#Nome#=' ||pr_nmremsms ||';'|| 
                              '#LinhaDigitavel#='|| pr_dslindig;
      
      --> buscar mensagem
      vr_dsdmensg := GENE0003.fn_buscar_mensagem
                                 (pr_cdcooper        => pr_cdcooper
                                 ,pr_cdproduto       => 19
                                 ,pr_cdtipo_mensagem => vr_cdtpmens
                                 ,pr_sms             => 1
                                 ,pr_valores_dinamicos => vr_valores_dinamicos);
      
      
      
      RETURN vr_dsdmensg;
      
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;  
    END fn_mensagem_vencto;               
    
  BEGIN    
  
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'I');  
   
    vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    
    
    --> Buscar coops ativas
    FOR rw_crapcop IN cr_crapcop LOOP
    
      BEGIN
        
        SAVEPOINT trans_coop;
        
        vr_tab_serv_inativo.delete;
        vr_nrdconta_aux := 0;
      
        -- Leitura do calendario da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;  
        
        IF rw_crapdat.inproces > 1 THEN
          vr_dscritic := 'Processo noturno nao finalizado para esta cooperativa.';
          RAISE vr_next_coop; 
        END IF;
        
        gene0004.pc_executa_job(pr_cdcooper => rw_crapcop.cdcooper, --> Codigo da cooperativa
                                pr_fldiautl => 1,                    --> Flag se deve validar dia util
                                pr_flproces => 1,                    --> Flag se deve validar se esta no processo 
                                pr_flrepjob => 0,                    --> Flag para reprogramar o job
                                pr_flgerlog => NULL,                    --> indicador se deve gerar log
                                pr_nmprogra => NULL,                    --> Nome do programa que esta s
                                pr_dscritic => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_next_coop;
        END IF;
        
        ---->>>> Verificar se cooperados estão habilitados a enviar SMS <<<<-----
        --> Buscar cooperados que possuem SMS Pendente
        FOR rw_ass_sms IN cr_ass_sms (pr_cdcooper => rw_crapcop.cdcooper) LOOP
        
          
          --> Rotina para verificar se serviço de SMS, caso identifique algum problema
          --> Contrato é cancelado automaticamente
          pc_verifar_serv_sms(pr_cdcooper   => rw_crapcop.cdcooper       --> Codigo da cooperativa
                             ,pr_nrdconta   => rw_ass_sms.nrdconta       --> Conta do associado
                             ,pr_nmdatela   => 'JOB'                     --> Nome da tela
                             ,pr_idorigem   => 7                         --> Indicador de sistema origem
                             -----> OUT <----                                                                 
                             ,pr_idcontrato =>  vr_idctrati  --> Retornar Numero do contratro ativo
                             ,pr_flsitsms   =>  vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                             ,pr_dsalerta   =>  vr_dsalerta   --> Retorna alerta para o cooperado
                             ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                             ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
        
          -- Se retornou erro
          IF NVL(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN

            vr_dscdolog := 'Coop: '||rw_crapcop.cdcooper||' Cta: '||rw_ass_sms.nrdconta||
                           ' -> Erro ao verificar serviço de SMS: '||vr_dscritic;

            pc_gera_log(pr_idtiplog  => 2,
                        pr_dscdolog  => vr_dscdolog);
          
          END IF;
          
          --> Armazenar contas que nao possuem contrato de SMS ativo
          IF nvl(vr_idctrati,0) = 0 THEN
            vr_tab_serv_inativo(rw_ass_sms.nrdconta) := rw_ass_sms.nrdconta;
          END IF;
          
        END LOOP;
        --->>> FIM VALIDACAO DOS COOPERADOS <<<----
        
        --Controle de geracao de lote de SMS
        vr_flgerlot   := TRUE;
        vr_idlote_sms := 0;
        
        --> Buscar SMS pendentes para o envio
        FOR rw_sms_cobran IN cr_sms_cobran (pr_cdcooper => rw_crapcop.cdcooper) LOOP
        
          BEGIN           
            
            --> Verificar se o serviço esta inativo para o este cooperado
            IF vr_tab_serv_inativo.exists(rw_sms_cobran.nrdconta) THEN
              vr_dscritic := 'SMS não enviado, serviço inativo para o cooperado.';
              RAISE vr_next;              
            END IF;   
            
            IF vr_flgerlot THEN
              vr_flgerlot := FALSE;
              
              --Gerar lote de SMS
              esms0001.pc_cria_lote_sms(pr_cdproduto     => 19 -- SMS Cobrança
                                       ,pr_idtpreme      => 'SMSCOBRAN'                                   
                                       ,pr_dsagrupador   => rw_crapcop.nmrescop
                                       ,pr_idlote_sms    => vr_idlote_sms
                                       ,pr_dscritic      => vr_dscritic);
            
              IF pr_dscritic IS NOT NULL THEN
                
                vr_dscritic := 'Erro ao criar lote: '||vr_dscritic;
                RAISE vr_next_coop;              
                         
              END IF;
            END IF;
            
            --> Criar savepoint para controle da geracao de SMS
            SAVEPOINT trans_sms;
            
            vr_dslindig := NULL;
            --> Verificar se a cooperativa permite enviar a linah digitavel 
            --> e se o cooperado deseja enviar a linha digitavel
            IF rw_crapcop.flglinha_digitavel = 1 AND 
               rw_sms_cobran.inavisms = 1 THEN
               
              --> Montar a linha digitavel do boleto
              pc_ret_linha_digitavel (pr_rowid_cob => rw_sms_cobran.rowid_cob,
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                      pr_dslindig  => vr_dslindig,
                                      pr_dscritic  => vr_dscritic);
            
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_dscritic := 'Erro ao gerar linha digitavel: '|| vr_dscritic;
                RAISE vr_next_sms;              
              END IF;
              
            END IF;
            
            IF vr_nrdconta_aux <> rw_sms_cobran.nrdconta THEN
              
              vr_nrdconta_aux := rw_sms_cobran.nrdconta;
              vr_nmremsms := NULL;
               
              --> Definir nome de remetente para o SMS
              --> se selecionou outro
              IF rw_sms_cobran.tpnome_emissao = 3 THEN
                vr_nmremsms := rw_sms_cobran.nmemissao_sms;
              --> se selecionou Razao social/Nome
              ELSIF rw_sms_cobran.tpnome_emissao = 1 THEN
                --> Buscar nome na crapass
                OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_nrdconta => rw_sms_cobran.nrdconta);
                FETCH cr_crapass INTO vr_nmremsms;
                CLOSE cr_crapass;
                
              --> se selecionou Nome fantasia
              ELSIF rw_sms_cobran.tpnome_emissao = 2 THEN
              
                --> Buscar nome na crapjur
                OPEN cr_crapjur(pr_cdcooper => rw_crapcop.cdcooper,
                                pr_nrdconta => rw_sms_cobran.nrdconta);
                FETCH cr_crapjur INTO vr_nmremsms;
                CLOSE cr_crapjur;              
              END IF;  
            END IF; 
            
            --> Senao retornou mensagem, gerar critica e buscar proximo
            IF TRIM(vr_nmremsms) IS NULL THEN
              vr_dscritic := 'Não foi possivel definir nome de remetente para SMS.';
              RAISE vr_next_sms;              
            ELSE
              vr_nmremsms := substr(vr_nmremsms,1,15);
            END IF;            
            
            vr_dsdmensa := NULL;

            vr_dslindig := REPLACE(vr_dslindig,'.','');
            vr_dslindig := REPLACE(vr_dslindig,' ','');    

            --> Retornar mensagem 
            vr_dsdmensa := fn_mensagem_vencto 
                                     ( pr_cdcooper => rw_crapcop.cdcooper    --> Codigo da cooperativa
                                      ,pr_dslindig => vr_dslindig            --> Linha digitavel
                                      ,pr_nmremsms => vr_nmremsms            --> Nome do remetente de SMS
                                      ,pr_dtvencto => rw_sms_cobran.dtvencto --> Data de vencimento do boleto
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);  --> Data atual do sistema

            --> Senao retornou mensagem, gerar critica e buscar proximo
            IF TRIM(vr_dsdmensa) IS NULL THEN
              vr_dscritic := 'Não foi possivel definir descrição de mensagem para SMS. ';
              RAISE vr_next_sms;              
            END IF;
            
            --> Gerar registro de SMS
            esms0001.pc_escreve_sms(pr_idlote_sms => vr_idlote_sms
                                   ,pr_cdcooper   => rw_crapcop.cdcooper
                                   ,pr_nrdconta   => rw_sms_cobran.nrdconta
                                   ,pr_idseqttl   => 1
                                   ,pr_dhenvio    => SYSDATE
                                   ,pr_nrddd      => rw_sms_cobran.ddd
                                   ,pr_nrtelefone => rw_sms_cobran.celular
                                   ,pr_cdtarifa   => rw_sms_cobran.cdtarifa
                                   ,pr_dsmensagem => vr_dsdmensa
                                   
                                   ,pr_idsms      => vr_idsms
                                   ,pr_dscritic   => vr_dscritic);
                                   
            IF vr_dscritic IS NOT NULL THEN              
              vr_dscritic := 'Não foi possivel gerar SMS: '|| vr_dscritic;
              RAISE vr_next_sms;
            END IF;
            
            --> Atualizar registro de SMS de cobrança
            BEGIN
              UPDATE tbcobran_sms sms
                 SET sms.idlote_sms   = vr_idlote_sms,
                     sms.idsms        = vr_idsms,
                     sms.instatus_sms = 2,
                     sms.idcontrato   = rw_sms_cobran.idcontrato
               WHERE sms.rowid = rw_sms_cobran.rowid_sms;
                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar SMS: '||SQLERRM;
                RAISE vr_next_sms;
            END;          
          
          
          EXCEPTION
            WHEN vr_next_coop THEN
              RAISE vr_next_coop;
            
            --> Gerar critica sem rollback  
            WHEN vr_next THEN
              IF vr_dscritic IS NOT NULL THEN
                vr_dscdolog := 'Coop: '||rw_crapcop.cdcooper||' Cta: '||rw_sms_cobran.nrdconta||
                               ' idsms: '||rw_sms_cobran.idsms||
                               ' -> '|| vr_dscritic;

                pc_gera_log(pr_idtiplog  => 2,
                            pr_dscdolog  => vr_dscdolog);
              END IF;
              vr_dscritic := NULL;
              
            --> Gerar critica e rollback    
            WHEN vr_next_sms THEN
              
              --> rollback da geracao de SMS
              ROLLBACK TO trans_sms;
              
              IF vr_dscritic IS NOT NULL THEN
                vr_dscdolog := 'Coop: '||rw_crapcop.cdcooper||' Cta: '||rw_sms_cobran.nrdconta||
                               'idsms: '||rw_sms_cobran.idsms||
                               ' -> '|| vr_dscritic;

                pc_gera_log(pr_idtiplog  => 2,
                            pr_dscdolog  => vr_dscdolog);
              END IF;
              vr_dscritic := NULL;
              
            WHEN OTHERS THEN
               --> rollback da geracao de SMS
                ROLLBACK TO trans_sms;
               vr_dscritic := 'Erro ao gerar SMS: '|| SQLERRM;
               RAISE vr_exc_erro;
          END;     
        END LOOP;
        
        --> Fechar lote
        IF vr_idlote_sms > 0 THEN
                    
          --> Gravar dados antes de enviar para o Aymaru
          COMMIT;
          
          --> Enviar lote de SMS para o Aymaru
          pc_enviar_lote_SMS ( pr_idlotsms  => vr_idlote_sms
                              ,pr_dscritic  => vr_dscritic
                              ,pr_cdcritic  => vr_cdcritic );
                              
          IF TRIM(vr_dscritic) IS NOT NULL OR
             nvl(vr_cdcritic,0) > 0 THEN
            
            --> Caso retorne com erro mecessario atualizar a situacao do lote
            pc_atualiza_status_lote ( pr_idlotsms   => vr_idlote_sms,
                                      pr_idsituacao => 'F');
            -- Salvar alteração
            COMMIT;
            RAISE vr_next_coop; 
          END IF;   
          
          --> Fechar o lote apos o envio
          ESMS0001.pc_conclui_lote_sms(pr_idlote_sms  => vr_idlote_sms
                                      ,pr_dscritic    => vr_dscritic);
          
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            ROLLBACK TO trans_coop;
            RAISE vr_next_coop; 
          END IF;
          
          END IF;                   
        
        --> Commit apos enviar dados para o Aymaru, 
        -- para garantir que não seja mais dado rollback de informação que já foi enviado
        COMMIT;       
      
      EXCEPTION
        --> Ir para a proxima cooperativa
        WHEN vr_next_coop THEN
          IF vr_dscritic IS NOT NULL THEN
            vr_dscdolog := 'Coop: '||rw_crapcop.cdcooper ||
                           ' -> '|| vr_dscritic;

            pc_gera_log(pr_idtiplog  => 2,
                        pr_dscdolog  => vr_dscdolog);
          END IF;
          vr_dscritic := NULL;
          
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;  
        WHEN OTHERS THEN  
          vr_dscritic := 'Erro ao enviar SMS de cobrança da coop '||rw_crapcop.cdcooper||': '||SQLERRM;
          RAISE vr_exc_erro;
      END;      
    END LOOP;
   
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'F'); 
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_verifica_sms_a_enviar : '||SQLERRM;        
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
      
  END pc_verifica_sms_a_enviar; 
  
  --> Enviar lote de SMS para o Aymaru
  PROCEDURE pc_enviar_lote_SMS ( pr_idlotsms  IN tbgen_sms_lote.idlote_sms%TYPE
                                ,pr_dscritic OUT VARCHAR2 
                                ,pr_cdcritic OUT INTEGER )IS
                                  
  /* ............................................................................

       Programa: pc_enviar_lote_SMS
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para envio lote de SMS para o Aymaru

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(2000);
    vr_cdcritic  INTEGER;
    
    vr_resposta AYMA0001.typ_http_response_aymaru;
    vr_parametros WRES0001.typ_tab_http_parametros;
    vr_conteudo json := json();
      
    vr_code     VARCHAR2(10);
    vr_Message  VARCHAR2(1000);
    vr_Detail   VARCHAR2(4000);
      
  BEGIN
    
    vr_conteudo.put('CodigoLote', pr_idlotsms);
    AYMA0001.pc_consumir_ws_rest_aymaru
                        (pr_rota => '/Cobranca/Utils/EnviarAlertaBoletos'
                        ,pr_verbo => WRES0001.POST
                        ,pr_servico => 'SMS.BOLETOS'
                        ,pr_parametros => vr_parametros
                        ,pr_conteudo => vr_conteudo
                        ,pr_resposta => vr_resposta
                        ,pr_dscritic => vr_dscritic
                        ,pr_cdcritic => vr_cdcritic);
          
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
       RAISE vr_exc_erro;
    END IF;
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
    vr_code    := vr_resposta.conteudo.get('Code').to_char();--.print();
    vr_Message := vr_resposta.conteudo.get('Message').get_string();
    vr_Detail  := vr_resposta.conteudo.get('Detail').get_string();
      
    IF TRIM(vr_code) IS NOT NULL THEN
        vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
        vr_dscritic := REPLACE(vr_dscritic,CHR(14));
        RAISE vr_exc_erro;
      END IF;
    END IF;
      
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_cdcritic := vr_cdcritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel enviar SMS: '||SQLERRM;
  END pc_enviar_lote_SMS; 
  
  --> Rotina para atualizar situação do lote de SMS de cobrança
  PROCEDURE pc_atualiza_status_lote ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,
                                      pr_idsituacao IN tbgen_sms_lote.idsituacao%TYPE) IS --> Código da Situação
                                  
  /* ............................................................................

       Programa: pc_atualiza_status_lote
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situação do lote de SMS de cobrança

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);
    
    vr_dsdemail  VARCHAR2(500);
    vr_dsdcorpo  VARCHAR2(1000);
    vr_nmarqlog  VARCHAR2(50);
    vr_cdprodut  tbgen_sms_lote.cdproduto%TYPE;
    vr_dsassunt  VARCHAR2(100);
        
  BEGIN
    
    --> Atualizar registro
    UPDATE tbgen_sms_lote lote
       SET lote.idsituacao = pr_idsituacao,
           lote.dhretorno  = SYSDATE
     WHERE /*lote.cdproduto = 19
       AND lote.idtpreme = 'SMSCOBRAN'
       AND */idlote_sms = pr_idlotsms
     RETURNING lote.cdproduto INTO vr_cdprodut;         
    
    -- Ajustar mensagem de alerta conforme produto
    IF vr_cdprodut = 19 THEN
      vr_dsassunt := 'SMS COBRANÇA - ERRO AO ENVIAR LOTE';
    ELSIF vr_cdprodut = 21 THEN
      vr_dsassunt := 'SMS LIMITE CRÉDITO - ERRO AO ENVIAR LOTE';
    ELSE -- Seta mensagem padrão 
      vr_dsassunt := 'SMS - ERRO AO ENVIAR LOTE';
    END IF;
    
    --> Diferente de processado
    IF pr_idsituacao <> 'P' THEN
      vr_dsdemail := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 1,
                                               pr_cdacesso => 'EMAIL_ALERT_SMS_COBRAN');
                                             
    
      vr_dsdcorpo := 'Nao foi possivel realizar a envio do lote '||
                     pr_idlotsms  ||' para a Zenvia'||
                     '</br></br>' || 'As ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss');
      
      gene0003.pc_solicita_email(pr_cdcooper => 3 
                                ,pr_cdprogra => 'COBR0005'
                                ,pr_des_destino => vr_dsdemail
                                ,pr_des_assunto => vr_dsassunt
                                ,pr_des_corpo => vr_dsdcorpo 
                                ,pr_des_anexo => '' --> Não tem anexo.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' 
                                ,pr_flg_enviar => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro => vr_dscritic);
    
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;  
      
      END IF;
    END IF;
     
     
  EXCEPTION 
    WHEN vr_exc_erro THEN
      vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || 'COBR0005.pc_atualiza_status_lote --> '
                                                 || vr_dscritic );
    WHEN OTHERS THEN
      vr_dscritic := 'Não foi possivel atualizar lote SMS '||pr_idlotsms||': '||SQLERRM;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 3
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || 'COBR0005.pc_atualiza_status_lote --> '
                                                 || vr_dscritic );
                                                 
  END pc_atualiza_status_lote; 
  
  --> Rotina para atualizar situação do SMS
  PROCEDURE pc_atualiza_status_msg ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,    --> Numer do lote de SMS
                                     pr_idsms      IN tbgen_sms_controle.idsms%TYPE,     --> Identificador do SMS
                                     pr_cdretorn   IN tbgen_sms_controle.cdretorno%TYPE, --> Código de retorno
                                     pr_dsretorn   IN tbgen_sms_controle.dsdetalhe_retorno%TYPE, --> Detalhe do retorno
                                     pr_dscritic  OUT VARCHAR2) IS 
                                  
  /* ............................................................................

       Programa: pc_atualiza_status_msg
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situação do SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);           
    
  BEGIN
    
    --> Atualizar registro
    UPDATE tbgen_sms_controle sms
       SET sms.cdretorno   = pr_cdretorn,
           sms.dsdetalhe_retorno = substr(pr_dsretorn,1,120),
           sms.dhenvio_sms = SYSDATE
     WHERE sms.idlote_sms = pr_idlotsms
       AND sms.idsms      = pr_idsms;  
       
     IF SQL%ROWCOUNT <> 1 THEN
       vr_dscritic := 'Não foi possivel localizar sms a ser atualizada lote/sms:'||pr_idlotsms||'/'||pr_idsms;     
     END IF;
     
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar SMS '||pr_idlotsms||'-'||pr_idsms||': '||SQLERRM;
      
                                                 
  END pc_atualiza_status_msg; 
  
  --> Rotina para atualizar situação do SMS - chamada SOA
  PROCEDURE pc_atualiza_status_msg_soa ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,  --> Numer do lote de SMS
                                         pr_xmlrequi   IN xmltype) IS                      --> Requeisicao xml
                                  
  /* ............................................................................

       Programa: pc_atualiza_status_msg_soa
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situação do SMS - chamada SOA

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -------------->> VARIAVEIS <<----------------
    vr_idsms      INTEGER;
    vr_sucess     VARCHAR2(10);
    vr_cdretorn   VARCHAR2(10);
    vr_Detail     VARCHAR2(1000);
    
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;
    vr_nmarqlog   VARCHAR2(50);
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;    
    vr_nodo       xmldom.DOMNode;        
    vr_idx        VARCHAR2(500);
    
    vr_tab_campos gene0007.typ_mult_array;
    
    
  BEGIN
    
    vr_xmldoc:= xmldom.newDOMDocument(pr_xmlrequi); 
    
    ----------------------------------------------------
    --            GRAVAR OS DADOS DO CONTRATO         --
    ----------------------------------------------------      
    --> BUSCAR CONTRATOS DO ACORDO
    -- Listar nós contrado
    vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'mensagem');        
    FOR vr_linha IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
      --Buscar Nodo Corrente
      vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
      
      gene0007.pc_itera_nodos (pr_nodo       => vr_nodo      --> Xpath do nodo a ser pesquisado
                              ,pr_nivel      => 0            --> Nível que será pesquisado
                              ,pr_list_nodos => vr_tab_campos--> PL Table com os nodos resgatados
                              ,pr_des_erro   => vr_dscritic);
                      
      vr_idx := vr_tab_campos.first;
      WHILE vr_idx IS NOT NULL LOOP
      
        vr_idsms  := vr_tab_campos(vr_idx)('Id');
        vr_sucess := vr_tab_campos(vr_idx)('Success');  
        vr_Detail := vr_tab_campos(vr_idx)('Detail');  
        
          IF upper(vr_sucess) = 'TRUE' THEN
            vr_cdretorn := 00;
          ELSIF upper(vr_sucess) = 'FALSE' THEN 
            vr_cdretorn := 10;
          ELSE
            vr_dscritic := 'Valor invalido para o campo "Sucess": '||vr_sucess;
            RAISE vr_exc_erro;
          END IF;
        
        pc_atualiza_status_msg (pr_idlotsms   => pr_idlotsms  --> Numer do lote de SMS
                               ,pr_idsms      => vr_idsms     --> Identificador do SMS
                               ,pr_cdretorn   => vr_cdretorn  --> Código de retor
                               ,pr_dsretorn   => vr_Detail    --> Detalhe do retorno
                               ,pr_dscritic   => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        vr_idx := vr_tab_campos.next(vr_idx);
        
      END LOOP;
    END LOOP;            
                                                   
  EXCEPTION 
    WHEN vr_exc_erro THEN
      vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || 'COBR0005.pc_atualiza_status_msg_soa --> '
                                                 || vr_dscritic );
    WHEN OTHERS THEN
    
      vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                                                
      vr_dscritic := 'Não foi possivel atualizar SMS '||pr_idlotsms||'-'||vr_idsms||': '||SQLERRM;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 3
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || 'COBR0005.pc_atualiza_status_msg_soa --> '
                                                 || vr_dscritic );
  END pc_atualiza_status_msg_soa; 
  
  
  --> Rotina para validar a criação do contrato de sms de cobrança
  PROCEDURE pc_valida_contrato_sms( pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_cdagenci      IN crapage.cdagenci%TYPE --> Codigo de agencia
                                   ,pr_nrdcaixa      IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Codigo do operador
                                   ,pr_nmdatela      IN craptel.nmdatela%TYPE --> Nome da tela
                                   ,pr_idorigem      IN INTEGER               --> Identificador sistema origem
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado
                                   ,pr_idpacote      IN tbcobran_sms_pacotes.idpacote%TYPE --> Id do pacote de sms de cobrança
                                   -----> OUT <----                                                                                                      
                                   ,pr_flpossnh OUT  INTEGER                   --> Retornar se cooperado possui senha de Internet (1-Ok, 0-NOK)
                                   ,pr_cdcritic OUT  INTEGER                   --> Retorna codigo de critica
                                   ,pr_dscritic OUT  VARCHAR2) IS              --> Retorno de critica
                                  
  /* ............................................................................

       Programa: pc_valida_contrato_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : otina para validar a criação do contrato de sms de cobrança

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    -- cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro        EXCEPTION;
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);        
    
    -- PLTABLE
    vr_tab_sald        EXTR0001.typ_tab_saldos;
    vr_tab_pacote      TELA_CADSMS.typ_tab_pacote;
    vr_tab_erro        GENE0001.typ_tab_erro;
    vr_des_reto        VARCHAR2(1000);
    
    
    vr_idcontrato      tbcobran_sms_contrato.idcontrato%TYPE; -->Numero do contratro ativo
    vr_flsitsms        INTEGER;                               --> flag se serviço esta ok para o cooperado(1-Ok,0-NOK )
    vr_dsalerta        VARCHAR2(1000);                        --> Alerta para o cooperado
    
    --> Senha
    vr_tab_titulates   INET0002.typ_tab_titulates;
    vr_qtdiaace        INTEGER;
    vr_nmprimtl        crapass.nmprimtl%TYPE;
    
    
  BEGIN
    --> Inicializar como não possui senha IBank
    pr_flpossnh := 0;
  
    --> Rotina para verificar se serviço de SMS.
    pc_verifar_serv_sms(pr_cdcooper   => pr_cdcooper    --> Codigo da cooperativa
                       ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                       ,pr_nmdatela   => pr_nmdatela    --> Nome da tela
                       ,pr_idorigem   => pr_idorigem    --> Indicador de sistema origem
                       -----> OUT <----                                                                 
                       ,pr_idcontrato =>  vr_idcontrato --> Retornar Numero do contratro ativo
                       ,pr_flsitsms   =>  vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                       ,pr_dsalerta   =>  vr_dsalerta   --> Retorna alerta para o cooperado
                       ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                       ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
  
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --> Verificar se contem alerta que impede a criação do contrato
    IF vr_dsalerta IS NOT NULL THEN
      vr_dscritic := vr_dsalerta;
      RAISE vr_exc_erro;
    END IF;
    
    --> Verificar se o serviço esta ativo para a cooperativa/cooperado
    IF nvl(vr_flsitsms,0) = 0 THEN
      vr_dscritic := 'Serviço de Cobrança de SMS não esta habilitado para esta cooperativa ou cooperado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- datas da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      -- monta msg de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);     
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;  
    
    IF nvl(pr_idpacote,0) > 2 THEN
      
      --> buscar dados do pacote
      TELA_CADSMS.pc_consultar_pacote(pr_idpacote   => pr_idpacote     --> Indicador do pacote
                                     ,pr_cdcooper   => pr_cdcooper     --> Codigo da cooperativa
                                     ,pr_tab_pacote => vr_tab_pacote   --> Retornar dados do pacote de SMS  
                                     ,pr_cdcritic   => vr_cdcritic     --> Codigo da critica
                                     ,pr_dscritic   => vr_dscritic );  --> Descricao da critica
    
      
      IF TRIM(vr_dscritic) IS NOT NULL OR 
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;        
      END IF;
      
      IF vr_tab_pacote.count() = 0 THEN
        vr_dscritic := 'Pacote '||pr_idpacote||' não encontrado.';
        RAISE vr_exc_erro;
      END IF;      
      
      -- Chamar rotina para busca do saldo
      extr0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                             ,pr_rw_crapdat => rw_crapdat
                             ,pr_cdagenci   => pr_cdagenci
                             ,pr_nrdcaixa   => pr_nrdcaixa
                             ,pr_cdoperad   => pr_cdoperad
                             ,pr_nrdconta   => pr_nrdconta
                             ,pr_dtrefere   => rw_crapdat.dtmvtolt
                             ,pr_des_reto   => vr_des_reto
                             ,pr_tab_sald   => vr_tab_sald
                             ,pr_tab_erro   => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
        ELSE
          vr_dscritic := 'Retorno "NOK" na extr0001.pc_obtem_saldo e sem informação na pr_vet_erro, Conta: '||pr_nrdconta;

        END IF;
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_tab_pacote(vr_tab_pacote.first).vlpacote > (nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp,0) + nvl(vr_tab_sald(vr_tab_sald.FIRST).vllimcre,0)) THEN
        vr_dscritic := 'Saldo insuficiente para contratação do pacote de SMS.';
        RAISE vr_exc_erro;
      END IF;  
      
      
    END IF;    
    --> Carrega titulares
    INET0002.pc_carrega_ttl_internet (  pr_cdcooper  => pr_cdcooper --> Codigo Cooperativa
                                       ,pr_cdagenci  => pr_cdagenci --> Codigo de agencia
                                       ,pr_nrdcaixa  => pr_nrdcaixa --> Numero do caixa
                                       ,pr_cdoperad  => pr_cdoperad --> Codigo do operador
                                       ,pr_nmdatela  => pr_nmdatela --> Nome da tela
                                       ,pr_idorigem  => pr_idorigem --> Identificador sistema origem
                                       ,pr_nrdconta  => pr_nrdconta --> Conta do Associado
                                       ,pr_idseqttl  => 1           --> Titularidade do Associado
                                       ,pr_flgerlog  => 1           --> Identificador se gera log  
                                       ,pr_flmobile  => 0           --> identificador se é chamada mobile
                                       ,pr_floperad  => 0           --> identificador se deve carregar operadores                                     
                                               
                                       ,pr_tab_titulates => vr_tab_titulates --> Retorna titulares com acesso ao Ibank
                                       ,pr_qtdiaace      => vr_qtdiaace      --> Retornar dias do primeiro acesso
                                       ,pr_nmprimtl      => vr_nmprimtl      --> Retornar nome do cooperaro
                                       ,pr_cdcritic      => vr_cdcritic      --> Codigo do erro
                                       ,pr_dscritic      => vr_dscritic);    --> Descricao do erro                                   
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL AND
       (vr_dscritic NOT IN ('A senha para Conta On-Line foi cancelada',
                            'A senha para Conta On-Line nao foi cadastrada')) THEN
      RAISE vr_exc_erro;
    END IF;  
    
    IF vr_tab_titulates.count > 0 THEN
      --> Retornar informação que possui senha internet
      pr_flpossnh := 1;      
    END IF; 
    
     
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel validar criação do contrato: '||SQLERRM;
      
                                                 
  END pc_valida_contrato_sms; 
  
  --> Rotina para validar a criação do contrato de sms de cobrança - Chamada ayllos Web
  PROCEDURE pc_valida_contrato_sms_web (pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numero de conta do cooperado
                                       ,pr_idpacote   IN INTEGER                --> Numero do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_valida_contrato_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para validar a criação do contrato de sms de cobrança - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_flpossnh   INTEGER;
    
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

    pc_valida_contrato_sms( pr_cdcooper      => vr_cdcooper --> Codigo da cooperativa
                           ,pr_cdagenci      => vr_cdagenci --> Codigo de agencia
                           ,pr_nrdcaixa      => vr_nrdcaixa --> Numero do caixa
                           ,pr_cdoperad      => vr_cdoperad --> Codigo do operador
                           ,pr_nmdatela      => vr_nmdatela --> Nome da tela
                           ,pr_idorigem      => vr_idorigem --> Identificador sistema origem
                           ,pr_nrdconta      => pr_nrdconta --> Conta do associado
                           ,pr_idpacote      => pr_idpacote --> Id do pacote de sms de cobrança
                           -----> OUT <----                                                                                                      
                           ,pr_flpossnh      => vr_flpossnh    --> Retornar se cooperado possui senha de Internet (1-Ok, 0-NOK)
                           ,pr_cdcritic      => vr_cdcritic    --> Retorna codigo de critica
                           ,pr_dscritic      => vr_dscritic);  --> Retorno de critica
    
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flpossnh'
                          ,pr_tag_cont => vr_flpossnh
                          ,pr_des_erro => vr_dscritic);    
                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_valida_contrato_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_valida_contrato_sms_web; 
  
  --> Rotina para lançar tarifa do pacote de SMS
  PROCEDURE pc_gerar_tarifa_pacote (pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_gerar_tarifa_pacote
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para para lançar tarifa do pacote de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar contratos cujo existe tarifa de pacote a ser cobrada
    CURSOR cr_smsctr IS    
      SELECT ctr.nrdconta
            ,ctr.cdcooper
            ,ctr.vlpacote
            ,pct.cdtarifa
            ,ctr.qtdsms_pacote
        FROM tbcobran_sms_contrato ctr,
             tbcobran_sms_pacotes pct
       WHERE ctr.cdcooper = pct.cdcooper
         AND ctr.idpacote = pct.idpacote
         AND ctr.idpacote > 2
         AND ctr.dhcancela IS NULL
         AND trunc(ctr.dhadesao) < trunc(SYSDATE) 
         AND trunc(ctr.dhadesao) >= gene0005.fn_valida_dia_util(pr_cdcooper => 3, 
                                                                pr_dtmvtolt => SYSDATE -1 , 
                                                                pr_tipo     => 'A' );
    
    
    --> Verificar se lat ja foi criada
    CURSOR cr_craplat ( pr_cdcooper  craplat.cdcooper%TYPE,
                        pr_nrdconta  craplat.nrdconta%TYPE,
                        pr_dtmvtolt  craplat.dtmvtolt%TYPE,
                        pr_nrdolote  craplat.nrdolote%TYPE,
                        pr_tpdolote  craplat.tpdolote%TYPE,
                        pr_vltarifa  craplat.vltarifa%TYPE ) IS
      SELECT 1
        FROM craplat lat
       WHERE lat.cdcooper = pr_cdcooper
         AND lat.nrdconta = pr_nrdconta
         AND lat.dtmvtolt = pr_dtmvtolt 
         AND lat.nrdolote = pr_nrdolote
         AND lat.tpdolote = pr_tpdolote
         AND lat.vltarifa = pr_vltarifa;
    rw_craplat cr_craplat%ROWTYPE;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -------------->> TEMP-Table <<---------------    
    TYPE typ_rec_tarifa
         IS RECORD (cdhistor   INTEGER,
                    cdhisest   INTEGER,
                    vltarifa   NUMBER,
                    dtdivulg   DATE,
                    dtvigenc   DATE,
                    cdfvlcop   INTEGER);

    TYPE typ_tab_tarifa IS TABLE OF typ_rec_tarifa
         INDEX BY PLS_INTEGER;
    vr_tab_tarifa   typ_tab_tarifa;  
    vr_tab_erro     GENE0001.typ_tab_erro; 
      
    -------------->> VARIAVEIS <<----------------
    vr_nomdojob     CONSTANT VARCHAR2(100) := 'JBCOBRAN_SMS_ENVIAR';
    vr_flgerlog     BOOLEAN := FALSE;  
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_idxtar       tbcobran_sms_pacotes.cdtarifa%TYPE;
       
    vr_vltarsms     craplat.vltarifa%TYPE;
    vr_rowid_lat    ROWID;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
 
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => NULL           --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
    
       
  BEGIN    
  
    
    -->  Validar execução
    gene0004.pc_executa_job(pr_cdcooper => 3, --> Codigo da cooperativa
                            pr_fldiautl => 1,                        --> Flag se deve validar dia util
                            pr_flproces => 1,                        --> Flag se deve validar se esta no processo 
                            pr_flrepjob => 1,                        --> Flag para reprogramar o job
                            pr_flgerlog => 1,                        --> indicador se deve gerar log
                            pr_nmprogra => 'PC_GERAR_TARIFA_PACOTE', --> Nome do programa que esta s
                            pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'I');  
   
    
    -- datas da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      -- monta msg de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);     
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF; 
    
    vr_tab_tarifa.delete;
    vr_dscritic := NULL; 
    
    -->Buscar contratos cujo existe tarifa de pacote a ser cobrada
    FOR rw_smsctr IN cr_smsctr LOOP
      
      vr_idxtar := rw_smsctr.cdtarifa;
        
      --> Se ainda não foi buscada essa tarifa
      IF NOT vr_tab_tarifa.exists(vr_idxtar) THEN
        --> Carregar Tarifas de pessoa fisica e juridica      
        TARI0001.pc_carrega_dados_tar_vigente ( pr_cdcooper  => rw_smsctr.cdcooper   -- Codigo Cooperativa
                                               ,pr_cdtarifa  => rw_smsctr.cdtarifa   -- Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                               ,pr_vllanmto  => 0                    -- Valor Lancamento
                                               ,pr_cdprogra  => 'COBR0005'           -- Codigo Programa
                                               ,pr_cdhistor  => vr_tab_tarifa(vr_idxtar).cdhistor   -- Codigo Historico
                                               ,pr_cdhisest  => vr_tab_tarifa(vr_idxtar).cdhisest   -- Historico Estorno
                                               ,pr_vltarifa  => vr_tab_tarifa(vr_idxtar).vltarifa   -- Valor tarifa
                                               ,pr_dtdivulg  => vr_tab_tarifa(vr_idxtar).dtdivulg   -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_tab_tarifa(vr_idxtar).dtvigenc   -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_tab_tarifa(vr_idxtar).cdfvlcop   -- Codigo faixa valor cooperativa
                                               ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                               ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                               ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
        
      vr_vltarsms := rw_smsctr.vlpacote;
      
      
      --> Verificar se lat ja foi criada
      OPEN cr_craplat (pr_cdcooper => rw_smsctr.cdcooper,
                       pr_nrdconta => rw_smsctr.nrdconta,
                       pr_dtmvtolt => rw_crapdat.dtmvtolt,
                       pr_nrdolote => 33001,
                       pr_tpdolote => 18,
                       pr_vltarifa => vr_vltarsms);
      FETCH cr_craplat INTO rw_craplat;
      
      --> Caso nao encontre, deve criar
      IF cr_craplat%NOTFOUND THEN
        CLOSE cr_craplat;
        
        --> Gerar tarifa do pacote de SMS
        TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => rw_smsctr.cdcooper
                                        ,pr_nrdconta => rw_smsctr.nrdconta
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_tab_tarifa(vr_idxtar).cdhistor
                                        ,pr_vllanaut => vr_vltarsms
                                        ,pr_cdoperad => '1'
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 33001
                                        ,pr_tpdolote => 18
                                        ,pr_nrdocmto => 0
                                        ,pr_nrdctabb => rw_smsctr.nrdconta
                                        ,pr_nrdctitg => GENE0002.fn_mask(rw_smsctr.nrdconta,'99999999')
                                        ,pr_cdpesqbb => ' '
                                        ,pr_cdbanchq => 0
                                        ,pr_cdagechq => 0
                                        ,pr_nrctachq => 0
                                        ,pr_flgaviso => FALSE
                                        ,pr_tpdaviso => 0
                                        ,pr_cdfvlcop => vr_tab_tarifa(vr_idxtar).cdfvlcop
                                        ,pr_inproces => rw_crapdat.inproces
                                        ,pr_rowid_craplat => vr_rowid_lat
                                        ,pr_tab_erro => vr_tab_erro
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
    
      ELSE 
        --> caso ja exista, ir para o proximo
        CLOSE cr_craplat;
      END IF;
    END LOOP;
    
   
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'F'); 
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gerar_tarifa_pacote : '||SQLERRM;        
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
      
  END pc_gerar_tarifa_pacote; 
  
  --> Rotina para verificar e renovar os contratos/pacote de SMS
  PROCEDURE pc_verifica_renovacao_pacote (pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_verifica_renovacao_pacote
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: 14/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para para lançar tarifa do pacote de SMS

       Alteracoes: 13/06/2017 - Incluir cláusula para considerar apenas pacotes
                                na consulta do cursor CR_SMSCTR (Renato Darosci)

                   14/06/2017 - Incluir verificação de pacotes ativos, para que 
                                seja chamada a rotina de renovação apenas para 
                                pacotes que ainda estejam ativos. (Renato Darosci)
    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Verificar se lat ja foi criada
    CURSOR cr_smsctr  IS
      SELECT ctr.cdcooper,
             ctr.nrdconta,
             ctr.idcontrato,
             ctr.idpacote,
             ctr.idseqttl,
             ctr.nmemissao_sms,
             ctr.tpnome_emissao
        FROM tbcobran_sms_contrato ctr
       WHERE ctr.dhcancela IS NULL
         AND ctr.idpacote   > 2   -- Apenas pacotes
         AND trunc(ctr.dhadesao) < trunc(SYSDATE - 30);

    -- Verificar se o pacote a ser renovado encontra-se ativo
    CURSOR cr_pacote_ativo(pr_cdcooper  tbcobran_sms_pacotes.cdcooper%TYPE
                          ,pr_idpacote  tbcobran_sms_pacotes.idpacote%TYPE) IS
      SELECT 1
        FROM tbcobran_sms_pacotes t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.idpacote  = pr_idpacote
         AND t.flgstatus = 1; -- Flag indicando PACOTE ATIVO
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -------------->> TEMP-Table <<---------------    
      
    -------------->> VARIAVEIS <<----------------
    vr_nomdojob     CONSTANT VARCHAR2(100) := 'JBCOBRAN_SMS_RENOV';
    vr_flgerlog     BOOLEAN := FALSE;  
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_indativo     NUMBER;
    vr_idcontrato   NUMBER;
    vr_dsalerta     VARCHAR2(2000);
    vr_dsretorn     VARCHAR2(2000);
       
    vr_flsitsms     INTEGER;
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
 
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => NULL           --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
    
       
  BEGIN    
  
    
    -->  Validar execução
    gene0004.pc_executa_job(pr_cdcooper => 3, --> Codigo da cooperativa
                            pr_fldiautl => 1,                        --> Flag se deve validar dia util
                            pr_flproces => 0,                        --> Flag se deve validar se esta no processo 
                            pr_flrepjob => 0,                        --> Flag para reprogramar o job
                            pr_flgerlog => 1,                        --> indicador se deve gerar log
                            pr_nmprogra => 'PC_VERIFICA_RENOVACAO_PACOTE', --> Nome do programa que esta s
                            pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'I');  
   
    
    -- datas da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      -- monta msg de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);     
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF; 
    
    
    vr_dscritic := NULL; 
    
    -->Buscar contratos cujo existe tarifa de pacote a ser cobrada
    FOR rw_smsctr IN cr_smsctr LOOP
       --> Rotina para verificar se serviço de SMS.
      pc_verifar_serv_sms(pr_cdcooper   => rw_smsctr.cdcooper   --> Codigo da cooperativa
                         ,pr_nrdconta   => rw_smsctr.nrdconta   --> Conta do associado
                         ,pr_nmdatela   => 'COBR0005'           --> Nome da tela
                         ,pr_idorigem   => 7                    --> Indicador de sistema origem
                         -----> OUT <----                                                                 
                         ,pr_idcontrato =>  vr_idcontrato --> Retornar Numero do contratro ativo
                         ,pr_flsitsms   =>  vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                         ,pr_dsalerta   =>  vr_dsalerta   --> Retorna alerta para o cooperado
                         ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                         ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
    
      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
      
      --> Se serviço estiver habilitado
      IF vr_flsitsms = 1 THEN
        
        --> Cancelamento do contrato atual de SMS
        COBR0005.pc_cancel_contrato_sms 
                               (pr_cdcooper    => rw_smsctr.cdcooper    --> Codigo da cooperativa
                               ,pr_nrdconta    => rw_smsctr.nrdconta    --> Conta do associado
                               ,pr_idseqttl    => 1                     --> Sequencial do titular
                               ,pr_idcontrato  => rw_smsctr.idcontrato  --> Numero do contrato de SMS
                               ,pr_idorigem    => 13 /* Renovacao SMS */--> id origem 
                               ,pr_cdoperad    => 996            --> Codigo do operador
                               ,pr_nmdatela    => 'COBR0005'     --> Identificador da tela da operacao
                               ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                               ,pr_inaprpen    => 1              --> Indicador de aprovação de transacao pendente
                               -----> OUT <----           
                               ,pr_dsretorn    => vr_dsretorn    --> Mensagem de retorno             
                               ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                               ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                                
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;  
        
        -- Verifica se o pacote a ser renovado existe e está ativo
        OPEN  cr_pacote_ativo(rw_smsctr.cdcooper
                             ,rw_smsctr.idpacote);
        FETCH cr_pacote_ativo INTO vr_indativo;
      
        -- Se não houver retorno, indica pacote inexistente ou inativo
        IF cr_pacote_ativo%NOTFOUND THEN
          vr_indativo := 0;
        END IF;
                                                                
        -- Fechar o cursor
        CLOSE cr_pacote_ativo;
        
        -- Se o pacote estiver ativo
        IF NVL(vr_indativo,0) = 1 THEN
          --> Rotina para geração do novo contrato de SMS
        pc_gera_contrato_sms (pr_cdcooper  => rw_smsctr.cdcooper  --> Codigo da cooperativa
                             ,pr_nrdconta  => rw_smsctr.nrdconta  --> Conta do associado
                             ,pr_idseqttl  => rw_smsctr.idseqttl  --> Sequencial do titular
                             ,pr_idorigem  => 13                  --> id origem 
                             ,pr_cdoperad  => 0                   --> Codigo do operador
                             ,pr_nmdatela  => 'COBR0005'          --> Identificador da tela da operacao
                             ,pr_nrcpfope  => 0                   --> CPF do operador de conta juridica
                             ,pr_inaprpen  => 0                   --> Indicador de aprovação de transacao pendente                         
                             ,pr_idpacote  => rw_smsctr.idpacote  --> Indicador de pacote
                             ,pr_tpnmemis  => rw_smsctr.tpnome_emissao --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                             ,pr_nmemissa  => rw_smsctr.nmemissao_sms  --> Nome caso selecionado Outro
                             -----> OUT <----                                   
                             ,pr_idcontrato=> vr_idcontrato --> Numero do contrato
                             ,pr_dsretorn  => vr_dsretorn   --> Mensagem de retorno
                             ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                             ,pr_dscritic  => vr_dscritic); --> Retorno de critica
                                                              
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
          END IF; -- Critica
        END IF; -- Verificar pacote ativo
      END IF; -- Serviço habilitado
     
    END LOOP;
    
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'F'); 
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gerar_tarifa_pacote : '||SQLERRM;        
      ROLLBACK;
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
      
  END pc_verifica_renovacao_pacote; 
  
  --> Rotina para realizar a troca do pacote de SMS
  PROCEDURE pc_trocar_pacote_sms (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado                             
                                 ,pr_idorigem    IN INTEGER                --> id origem 
                                 ,pr_cdoperad    IN crapope.cdoperad%TYPE  --> Codigo do operador
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE  --> Identificador da tela da operacao                             
                                 ,pr_idpacote    IN INTEGER DEFAULT 0      --> Identificador do pacote de SMS                                 ,
                                 ,pr_idctratu    IN tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 -----> OUT <----                                   
                                 ,pr_idctrnov   OUT tbcobran_sms_contrato.idcontrato%TYPE --> Numero do contrato de sms
                                 ,pr_dsretorn   OUT VARCHAR2               --> Mensagem de retorno             
                                 ,pr_cdcritic   OUT INTEGER                --> Retorna codigo de critica
                                 ,pr_dscritic   OUT VARCHAR2) IS           --> Retorno de critica

  /* ............................................................................

       Programa: pc_trocar_pacote_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para realizar a troca do pacote de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar inf do contrato de SMS
    CURSOR cr_smsctr  (pr_cdcooper   tbcobran_sms_contrato.cdcooper%TYPE,  
                       pr_nrdconta   tbcobran_sms_contrato.nrdconta%TYPE,  
                       pr_idcontrato tbcobran_sms_contrato.idcontrato%TYPE) IS
      SELECT ctr.cdcooper,
             ctr.nrdconta,
             ctr.idcontrato,
             ctr.idpacote,
             ctr.idseqttl,
             ctr.nmemissao_sms,
             ctr.tpnome_emissao
        FROM tbcobran_sms_contrato ctr
       WHERE ctr.cdcooper   = pr_cdcooper
         AND ctr.nrdconta   = pr_nrdconta
         AND ctr.idcontrato = pr_idcontrato;
    rw_smsctr cr_smsctr%ROWTYPE;
    
    -------------->> TEMP-Table <<---------------    
      
    -------------->> VARIAVEIS <<----------------
    
    vr_exc_erro     EXCEPTION;    
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_idcontrato   NUMBER;
    vr_dsalerta     VARCHAR2(2000);
    vr_dsretorn     VARCHAR2(2000);
       
    vr_flsitsms     INTEGER;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
 
    
       
  BEGIN    
  
    
    --> Rotina para verificar se serviço de SMS.
    pc_verifar_serv_sms(pr_cdcooper   => pr_cdcooper   --> Codigo da cooperativa
                       ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                       ,pr_nmdatela   => 'COBR0005'           --> Nome da tela
                       ,pr_idorigem   => 7                    --> Indicador de sistema origem
                       -----> OUT <----                                                                 
                       ,pr_idcontrato =>  vr_idcontrato --> Retornar Numero do contratro ativo
                       ,pr_flsitsms   =>  vr_flsitsms   --> Retorna se serviço esta ok para o cooperado(1-Ok,0-NOK )
                       ,pr_dsalerta   =>  vr_dsalerta   --> Retorna alerta para o cooperado
                       ,pr_cdcritic   =>  vr_cdcritic   --> Retorna codigo de critica
                       ,pr_dscritic   =>  vr_dscritic); --> Retorno de critica  
    
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF nvl(vr_idcontrato,0) = 0 THEN  
      vr_dscritic := 'Não encontrado nenhum contrato ativo.';
      RAISE vr_exc_erro;    
    ELSIF nvl(vr_idcontrato,0) <> nvl(pr_idctratu,0) THEN
      vr_dscritic := 'Numero do contrato difere do contrato ativo.';
      RAISE vr_exc_erro;    
    END IF;
    
    --> Buscar inf do contrato de SMS
    OPEN cr_smsctr  (pr_cdcooper   => pr_cdcooper  ,  
                     pr_nrdconta   => pr_nrdconta  ,  
                     pr_idcontrato => pr_idctratu);
    FETCH cr_smsctr INTO rw_smsctr;
    IF cr_smsctr%NOTFOUND THEN
      CLOSE cr_smsctr;
      vr_dscritic := 'Ccontrato '||pr_idctratu||' não encontrado.';
      RAISE vr_exc_erro;    
    END IF;
      
    --> Canlemaneto do contrato de SMS
    COBR0005.pc_cancel_contrato_sms 
                           (pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                           ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                           ,pr_idseqttl    => 1              --> Sequencial do titular
                           ,pr_idcontrato  => pr_idctratu    --> Numero do contrato de SMS
                           ,pr_idorigem    => pr_idorigem    --> id origem 
                           ,pr_cdoperad    => pr_cdoperad   --> Codigo do operador
                           ,pr_nmdatela    => pr_nmdatela   --> Identificador da tela da operacao
                           ,pr_nrcpfope    => 0              --> CPF do operador de conta juridica
                           ,pr_inaprpen    => 1              --> Indicador de aprovação de transacao pendente
                           -----> OUT <----           
                           ,pr_dsretorn    => vr_dsretorn    --> Mensagem de retorno             
                           ,pr_cdcritic    => vr_cdcritic    --> Retorna codigo de critica
                           ,pr_dscritic    => vr_dscritic);  --> Retorno de critica
                                                                
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
        
    --> Rotina para geração do contrato de SMS
    pc_gera_contrato_sms (pr_cdcooper  => pr_cdcooper              --> Codigo da cooperativa
                         ,pr_nrdconta  => pr_nrdconta              --> Conta do associado
                         ,pr_idseqttl  => rw_smsctr.idseqttl       --> Sequencial do titular
                         ,pr_idorigem  => pr_idorigem              --> id origem 
                         ,pr_cdoperad  => pr_cdoperad              --> Codigo do operador
                         ,pr_nmdatela  => pr_nmdatela              --> Identificador da tela da operacao
                         ,pr_nrcpfope  => 0                        --> CPF do operador de conta juridica
                         ,pr_inaprpen  => 1                        --> Indicador de aprovação de transacao pendente                         
                         ,pr_idpacote  => pr_idpacote       --> Indicador de pacote
                         ,pr_tpnmemis  => rw_smsctr.tpnome_emissao --> Tipo de nome na emissao do boleto (0-outro, 1-nome razao/ 2-nome fantasia) 
                         ,pr_nmemissa  => rw_smsctr.nmemissao_sms  --> Nome caso selecionado Outro
                         -----> OUT <----                                   
                         ,pr_idcontrato=> pr_idctrnov   --> Numero do contrato
                         ,pr_dsretorn  => vr_dsretorn   --> Mensagem de retorno
                         ,pr_cdcritic  => vr_cdcritic   --> Codigo de critica
                         ,pr_dscritic  => vr_dscritic); --> Retorno de critica
                                                              
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
     
    pr_dsretorn := 'Alteração de pacote de SMS realizada com sucesso.';
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_trocar_pacote : '||SQLERRM;        
      ROLLBACK;      
      
  END pc_trocar_pacote_sms; 
   
  --> Rotina para realizar a troca do pacote de SMS - Chamada ayllos Web
  PROCEDURE pc_trocar_pacote_sms_web (  pr_nrdconta   IN crapass.nrdconta%TYPE  --> Numero de conta do cooperado
                                       ,pr_idcontrato IN INTEGER                --> indicador do contrato de serviço de SMS de Cobrança
                                       ,pr_idpacote   IN INTEGER                --> Numero do pacote de SMS
                                       ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_trocar_pacote_sms_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para realizar a troca do pacote de SMS - Chamada ayllos Web

       Alteracoes: ----

    ............................................................................ */  
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_idctrnov   INTEGER;
    vr_dsretorn   VARCHAR2(2000);
    
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

    
    pc_trocar_pacote_sms (pr_cdcooper    => vr_cdcooper   --> Codigo da cooperativa
                         ,pr_nrdconta    => pr_nrdconta   --> Conta do associado                             
                         ,pr_idorigem    => vr_idorigem   --> id origem 
                         ,pr_cdoperad    => vr_cdoperad   --> Codigo do operador
                         ,pr_nmdatela    => vr_nmdatela   --> Identificador da tela da operacao                             
                         ,pr_idpacote    => pr_idpacote   --> Identificador do pacote de SMS
                         ,pr_idctratu    => pr_idcontrato --> Numero do contrato de sms
                         -----> OUT <----                                   
                         ,pr_idctrnov    => vr_idctrnov   --> Numero do contrato de sms
                         ,pr_dsretorn    => vr_dsretorn   --> Mensagem de retorno             
                         ,pr_cdcritic    => vr_cdcritic   --> Retorna codigo de critica
                         ,pr_dscritic    => vr_dscritic );--> Retorno de critica
    
                                                          
    -- Se retornou erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idcontrato'
                          ,pr_tag_cont => vr_idctrnov
                          ,pr_des_erro => vr_dscritic);    
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dsretorn'
                          ,pr_tag_cont => vr_dsretorn
                          ,pr_des_erro => vr_dscritic);                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_trocar_pacote_sms_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´'),'"');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_trocar_pacote_sms_web; 
  
  --> Rotina para cobrar tarifas das SMSs enviadas 
  PROCEDURE pc_gera_tarifa_sms_enviados (pr_cdcooper    IN  INTEGER               --> Codigo da cooperativa                                         
                                        ,pr_dscritic   OUT  VARCHAR2) IS          --> Retorno de critica

  /* ............................................................................

       Programa: pc_gera_tarifa_sms_enviados
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana- AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para cobrar tarifas das SMSs enviadas 

       Alteracoes: ----

    ............................................................................ */
    
    --------------->> CURSORES <<----------------
    
    --> Buscar cooperativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             prm.flglinha_digitavel
        FROM crapcop cop,
             tbcobran_sms_param_coop prm
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) 
         AND cop.flgativo = 1
         AND cop.cdcooper = prm.cdcooper;
    
    --> Buscar SMS enviados com sucesso
    CURSOR cr_sms_cobran (pr_cdcooper crapcop.cdcooper%TYPE) IS    
      SELECT ctl.cdcooper, 
             ctl.nrdconta,
             ctl.cdtarifa, 
             COUNT(ctl.idsms) qtdsms
        FROM tbgen_sms_controle ctl,
             tbgen_sms_lote lot
       WHERE ctl.cdcooper   = pr_cdcooper
         AND lot.idlote_sms = ctl.idlote_sms
         AND lot.cdproduto  = 19
         AND lot.idtpreme   = 'SMSCOBRAN'
         AND cdretorno      = 00
         AND trunc(dhenvio_sms)  = trunc(SYSDATE)         
       GROUP BY ctl.cdcooper, ctl.nrdconta,ctl.cdtarifa;

    -->  Buscar contrato ativo
    CURSOR cr_smsctr (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ctr.idpacote,
             ctr.qtdsms_pacote,
             ctr.qtdsms_usados,
             ctr.vlunitario,
             ctr.rowid
        FROM tbcobran_sms_contrato ctr
       WHERE ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND ctr.dhcancela IS NULL;
    rw_smsctr cr_smsctr%ROWTYPE;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    -------------->> TEMP-Table <<---------------
    TYPE typ_rec_tarifa
         IS RECORD (cdhistor   INTEGER,
                    cdhisest   INTEGER,
                    vltarifa   NUMBER,
                    dtdivulg   DATE,
                    dtvigenc   DATE,
                    cdfvlcop   INTEGER);

    TYPE typ_tab_tarifa IS TABLE OF typ_rec_tarifa
         INDEX BY PLS_INTEGER;
    vr_tab_tarifa   typ_tab_tarifa;  
    
    -------------->> VARIAVEIS <<----------------
    vr_nomdojob     CONSTANT VARCHAR2(100) := 'JBCOBRAN_TARIFA_SMS';
    vr_flgerlog     BOOLEAN := FALSE;  
    vr_nmarqlog     VARCHAR2(200);
    
    vr_exc_erro     EXCEPTION;
    vr_next_coop    EXCEPTION;
    vr_exc_next     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_tab_erro     GENE0001.typ_tab_erro; 
    
    vr_rowid_lat    ROWID;
    vr_idxtar       PLS_INTEGER;
    vr_vltarsms     NUMBER;       
    vr_qtsmsdis     INTEGER;
    vr_qtdsms       INTEGER;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- procedimento para gerar log da debtar
    PROCEDURE pc_gera_log( pr_cdcooper IN NUMBER DEFAULT 3,
                           pr_idtiplog IN NUMBER DEFAULT 1,
                           pr_dscdolog IN VARCHAR2) IS
    BEGIN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => pr_idtiplog
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                 || vr_nomdojob || ' --> '
                                                 || pr_dscdolog );
    END pc_gera_log;
    
    -- procedimento para gerar email de alerta 
    PROCEDURE pc_email_critica(pr_dscritic IN VARCHAR2) IS
    
      vr_dsdemail VARCHAR2(500);
      vr_dsdcorpo VARCHAR2(1000);
    
    BEGIN
      vr_dsdemail := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 1,
                                               pr_cdacesso => 'EMAIL_ALERT_SMS_COBRAN');
                                             
    
      vr_dsdcorpo := 'Nao foi possivel criar lançamentos de tarifa de SMS :'||pr_dscritic;
      
      gene0003.pc_solicita_email(pr_cdcooper => 3 
                                ,pr_cdprogra => 'COBR0005'
                                ,pr_des_destino => vr_dsdemail
                                ,pr_des_assunto => 'SMS COBRANÇA - Lançamento de tarifas'
                                ,pr_des_corpo => vr_dsdcorpo 
                                ,pr_des_anexo => '' --> Não tem anexo.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' 
                                ,pr_flg_enviar => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro => vr_dscritic);
    END pc_email_critica;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => NULL           --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
    --> Rotina para notificar cooperado
    PROCEDURE pc_notifica_cooperado (pr_cdcooper IN crapass.cdcooper%TYPE,
                                     pr_nmrescop IN crapcop.nmrescop%TYPE,
                                     pr_nrdconta IN crapass.nrdconta%TYPE )IS
      
      --Selecionar titulares com senhas ativas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = pr_cdsitsnh
         AND crapsnh.tpdsenha = pr_tpdsenha;
         
      vr_dsdassun  crapmsg.dsdassun%TYPE;
      vr_dsdplchv  crapmsg.dsdplchv%TYPE;
      vr_dsdmensg  crapmsg.dsdmensg%TYPE;
    
    BEGIN
    
      vr_dsdassun := 'O limite de SMSs do seu Pacote foi excedido'; 
      vr_dsdplchv := 'Limite de SMSs'; 
      vr_dsdmensg := 'Informamos que o limite de SMSs de seu pacote foi excedido. A partir deste momento '||
                     'cada SMS enviado terá o custo do SMS individual, até que o pacote seja automaticamente renovado. '||
                     'Você também pode contratar um novo pacote de SMS. Caso seja de seu interesse, acesse o menu: '||
                     'Cobrança Bancária > SMS para boletos, para visualizar os pacotes disponíveis.';
    
      --> Buscar pessoas que possuem acesso a conta
      FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta
                                   ,pr_cdsitsnh  => 1
                                   ,pr_tpdsenha  => 1) LOOP
        --> Insere na tabela de mensagens (CRAPMSG)
        GENE0003.pc_gerar_mensagem
                              (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => rw_crapsnh.idseqttl --> Titular 
                              ,pr_cdprogra => 'COBR0005'          --> Programa 
                              ,pr_inpriori => 0
                              ,pr_dsdmensg => vr_dsdmensg         --> corpo da mensagem 
                              ,pr_dsdassun => vr_dsdassun         --> Assunto 
                              ,pr_dsdremet => pr_nmrescop 
                              ,pr_dsdplchv => vr_dsdplchv
                              ,pr_cdoperad => 1
                              ,pr_cdcadmsg => 0
                              ,pr_dscritic => vr_dscritic); 

      END LOOP;  
    END pc_notifica_cooperado;
    
  BEGIN
    
    vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                                              
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'I'); 
    
    --> Buscar coops ativas
    FOR rw_crapcop IN cr_crapcop LOOP
      
      vr_tab_tarifa.delete;
      vr_dscritic := NULL;
      
      -->  Validar execução
      gene0004.pc_executa_job(pr_cdcooper => rw_crapcop.cdcooper, --> Codigo da cooperativa
                              pr_fldiautl => 1,                    --> Flag se deve validar dia util
                              pr_flproces => 1,                    --> Flag se deve validar se esta no processo 
                              pr_flrepjob => 0,                    --> Flag para reprogramar o job
                              pr_flgerlog => NULL,                    --> indicador se deve gerar log
                              pr_nmprogra => NULL,                    --> Nome do programa que esta s
                              pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        continue;
      END IF;
      
      
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;  
      
      
      --> buscar SMSs enviados com sucesso
      FOR rw_sms_cobran IN cr_sms_cobran(pr_cdcooper => rw_crapcop.cdcooper) LOOP
        BEGIN
          
          --> Localizar contrato ativo
          OPEN cr_smsctr(pr_cdcooper => rw_sms_cobran.cdcooper,
                         pr_nrdconta => rw_sms_cobran.nrdconta);
          FETCH cr_smsctr INTO rw_smsctr;                 
          IF cr_smsctr%NOTFOUND THEN
            CLOSE cr_smsctr;
            vr_dscritic := 'Nenhum contrato de SMS de cobrança localizado para o cooperado '||rw_sms_cobran.nrdconta;
            RAISE vr_exc_erro;
          END IF;
		  CLOSE cr_smsctr;
          
          vr_qtsmsdis := 0;
          vr_qtdsms   := 0;
          vr_vltarsms := 0;
          
          IF rw_smsctr.idpacote > 2 THEN
          
            --> Calcular SMSs disponiveis
            vr_qtsmsdis := nvl(rw_smsctr.qtdsms_pacote,0) - nvl(rw_smsctr.qtdsms_usados,0);
            
            BEGIN
              UPDATE tbcobran_sms_contrato ctr
                 SET ctr.qtdsms_usados = nvl(ctr.qtdsms_usados,0) + nvl(rw_sms_cobran.qtdsms,0)
               WHERE ctr.rowid = rw_smsctr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Nao foi possivel atualizar contrato sms  cooperado '||rw_sms_cobran.nrdconta;
            END;
            
            IF vr_qtsmsdis <= 0 THEN
              vr_qtdsms := rw_sms_cobran.qtdsms;
            ELSE
              vr_qtdsms := vr_qtsmsdis - rw_sms_cobran.qtdsms;
            END IF;
            
            --> Se ainda nao utilizou todas as SMSs disponiveis
            IF vr_qtdsms >= 0 THEN
              --> nao precisa cobrar tarifa
              RAISE vr_exc_next;
            ELSE
              --> se ja utilizou, gerar tarifa dos SMSs adicionais
              vr_qtdsms   := abs(vr_qtdsms); 
              vr_vltarsms := vr_qtdsms * rw_smsctr.vlunitario;
            END IF;
            
            -- Se possuia qtd de SMSs disponiveis, porem ultrapassou a quantidade
            --> e irá cobrar SMS
            IF vr_qtsmsdis >= 0 AND vr_qtdsms > 0 THEN
              pc_notifica_cooperado (pr_cdcooper => rw_sms_cobran.cdcooper,
                                     pr_nmrescop => rw_crapcop.nmrescop,
                                     pr_nrdconta => rw_sms_cobran.nrdconta);            
            END IF;
          
          --> Individual
          ELSE
            vr_qtdsms := rw_sms_cobran.qtdsms;
          
          END IF;
          
          
          vr_idxtar := rw_sms_cobran.cdtarifa;
          
          --> Se ainda não foi buscada essa tarifa
          IF NOT vr_tab_tarifa.exists(vr_idxtar) THEN
          
            --> Carregar Tarifas de pessoa fisica e juridica      
            TARI0001.pc_carrega_dados_tar_vigente ( pr_cdcooper  => rw_sms_cobran.cdcooper   -- Codigo Cooperativa
                                                   ,pr_cdtarifa  => rw_sms_cobran.cdtarifa  --Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                                   ,pr_vllanmto  => 0             -- Valor Lancamento
                                                   ,pr_cdprogra  => 'COBR0005'    -- Codigo Programa
                                                   ,pr_cdhistor  => vr_tab_tarifa(vr_idxtar).cdhistor   -- Codigo Historico
                                                   ,pr_cdhisest  => vr_tab_tarifa(vr_idxtar).cdhisest   -- Historico Estorno
                                                   ,pr_vltarifa  => vr_tab_tarifa(vr_idxtar).vltarifa   -- Valor tarifa
                                                   ,pr_dtdivulg  => vr_tab_tarifa(vr_idxtar).dtdivulg   -- Data Divulgacao
                                                   ,pr_dtvigenc  => vr_tab_tarifa(vr_idxtar).dtvigenc   -- Data Vigencia
                                                   ,pr_cdfvlcop  => vr_tab_tarifa(vr_idxtar).cdfvlcop   -- Codigo faixa valor cooperativa
                                                   ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                                   ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                                   ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
            -- Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              -- Se possui erro no vetor
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel carregar a tarifa.';
              END IF;
              -- Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
          --> Para pacote individual, necessario buscar valor de tarifa atualizado
          IF rw_smsctr.idpacote <= 2 THEN
            vr_vltarsms := vr_qtdsms * vr_tab_tarifa(vr_idxtar).vltarifa;
          END IF;
          
          -- Criar Lancamento automatico tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => rw_sms_cobran.cdcooper
                                          ,pr_nrdconta      => rw_sms_cobran.nrdconta
                                          ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                          ,pr_cdhistor      => vr_tab_tarifa(vr_idxtar).cdhistor
                                          ,pr_vllanaut      => vr_vltarsms
                                          ,pr_cdoperad      => '1'
                                          ,pr_cdagenci      => 1
                                          ,pr_cdbccxlt      => 100
                                          ,pr_nrdolote      => 33001
                                          ,pr_tpdolote      => 18
                                          ,pr_nrdocmto      => 0
                                          ,pr_nrdctabb      => rw_sms_cobran.nrdconta
                                          ,pr_nrdctitg      => GENE0002.fn_mask(rw_sms_cobran.nrdconta,'99999999')
                                          ,pr_cdpesqbb      => ' '
                                          ,pr_cdbanchq      => 0
                                          ,pr_cdagechq      => 0
                                          ,pr_nrctachq      => 0
                                          ,pr_flgaviso      => FALSE
                                          ,pr_tpdaviso      => 0
                                          ,pr_cdfvlcop      => vr_tab_tarifa(vr_idxtar).cdfvlcop
                                          ,pr_inproces      => rw_crapdat.inproces
                                          ,pr_rowid_craplat => vr_rowid_lat
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento tarifa de sms de cobrança.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        EXCEPTION
          WHEN vr_exc_next THEN
            NULL;
          WHEN vr_exc_erro THEN
            pc_gera_log( pr_cdcooper => rw_crapcop.cdcooper,
                         pr_idtiplog => 1,
                         pr_dscdolog => vr_dscritic);
            vr_dscritic := NULL;                       
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel gerar tarifa de SMS para a conta '||
                            rw_sms_cobran.nrdconta ||': '|| SQLERRM;
            pc_gera_log( pr_cdcooper => rw_crapcop.cdcooper,
                         pr_idtiplog => 1,
                         pr_dscdolog => vr_dscritic);
          
        END;  
      END LOOP;
    
    END LOOP; --> Fim loop crapcop
    
   
    --> Controla log proc_batch
    pc_controla_log_batch(pr_dstiplog => 'F'); 
    
    COMMIT;       
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
      
      pc_email_critica(pr_dscritic);
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
      --> Commit apos gerar os alertas
      COMMIT;
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gera_tarifa_sms_enviados : '||SQLERRM;        
      ROLLBACK;
      
      pc_email_critica(pr_dscritic);
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
      
  END pc_gera_tarifa_sms_enviados; 
  
  --> Rotina responsavel por gerar o relatorio de resumo de envio de SMS
  PROCEDURE pc_relat_resumo_envio_sms (pr_cdcooper  IN  crapcop.cdcooper%TYPE          --> Codigo da cooperativa                                    
                                      ,pr_nrdconta  IN  crapass.nrdconta%TYPE          --> Numer de conta do cooperado                                     
                                      ,pr_dtiniper  IN  DATE                           --> Data inicio do periodo para relatorio
                                      ,pr_dtfimper  IN  DATE                           --> Data fim do periodo para relatorio
                                      ,pr_idorigem  IN INTEGER                         --> Codigo de origem do sistema
                                      ,pr_dsiduser   IN VARCHAR2                       --> id do usuario
                                      ,pr_instatus  IN INTEGER DEFAULT 0               --> Status do SMS (0 - para todos)
                                      --------->> OUT <<-----------
                                      ,pr_nmarqpdf OUT VARCHAR2                        --> Retorna o nome do relatorio gerado
                                      ,pr_dsxmlrel OUT CLOB                            --> Retorna xml do relatorio quando origem for 3 -InternetBank
                                      ,pr_cdcritic OUT NUMBER                          --> nome na emissao do boleto (1-nome razao/ 2-nome fantasia) 
                                      ,pr_dscritic OUT VARCHAR2) IS                    --> Retorno de critica

  /* ............................................................................

       Programa: pc_relat_resumo_envio_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por gerar o relatorio de resumo de envio de SMS

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    --> Buscar SMSs enviados 
    CURSOR cr_smsctr IS
      SELECT ctr.idpacote,
             pct.dspacote,
             ctr.idcontrato,
             ctr.dhcancela,
             pct.cdtarifa,
             ctr.qtdsms_pacote,
             ctr.qtdsms_usados,
             GREATEST(ctr.qtdsms_pacote - ctr.qtdsms_usados,0) qtsmsdis,
             GREATEST(ctr.qtdsms_usados - ctr.qtdsms_pacote,0) qtsmsadi,
             ctr.vlpacote,
             ctr.vlunitario,
             ass.nmprimtl
        FROM crapass ass, 
             tbcobran_sms_contrato ctr,
             tbcobran_sms_pacotes  pct
       WHERE ctr.cdcooper = pct.cdcooper
         AND ctr.idpacote = pct.idpacote
         AND ctr.cdcooper = ass.cdcooper
         AND ctr.nrdconta = ass.nrdconta
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.nrdconta = pr_nrdconta
         AND trunc(ctr.dhadesao) >= pr_dtiniper 
         AND trunc(ctr.dhadesao) <= pr_dtfimper
         ORDER BY ctr.dhadesao DESC;
    
    --> Buscar Valor tarifa
    CURSOR cr_crapfco(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdtarifa craptar.cdtarifa%TYPE) IS
      SELECT fco.vltarifa           
        FROM crapfco fco
            ,crapfvl fvl
       WHERE fco.cdcooper = pr_cdcooper
         AND fco.flgvigen = 1 --> ativa 
         AND fco.cdfaixav = fvl.cdfaixav 
         AND fvl.cdtarifa = pr_cdtarifa;
    
    --> Buscar quantidade de SMSs programadas/pendentes de envio
    CURSOR cr_smsprog IS   
      SELECT COUNT(1)
        FROM tbcobran_sms sms
       WHERE sms.cdcooper = pr_cdcooper
         AND sms.nrdconta = pr_nrdconta
         AND sms.instatus_sms IN ( 1,  --> A enviar
                                   2); --> processamento
    --> Buscar quantidade de SMSs enviadas
    CURSOR cr_smsenv (pr_cdcooper   tbcobran_sms.cdcooper%TYPE,  
                      pr_nrdconta   tbcobran_sms.nrdconta%TYPE,  
                      pr_idcontrato tbcobran_sms.idcontrato%TYPE )IS   
      SELECT COUNT(1)
        FROM tbcobran_sms sms
       WHERE sms.cdcooper   = pr_cdcooper
         AND sms.nrdconta   = pr_nrdconta
         AND sms.idcontrato = pr_idcontrato
         AND sms.instatus_sms = 4; -- Enviado
       
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
     
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    vr_des_reto     VARCHAR2(100);
    vr_tab_erro     GENE0001.typ_tab_erro; 
    
    vr_flexsreg     BOOLEAN := FALSE;
    vr_vltottar     NUMBER;
    vr_vlunitario   NUMBER;
    vr_qtsmspen     INTEGER;
    vr_qtsmspen_aux INTEGER;
    vr_qtsmsenv     INTEGER;
    
    vr_dsdireto     VARCHAR2(4000);
    vr_dscomand     VARCHAR2(4000);
    vr_typsaida     VARCHAR2(100); 
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml      CLOB;
    vr_txtcompl     VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
  
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;  
  
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    IF pr_idorigem <> '3' THEN
      --> INICIO
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl728 dtiniper="'||to_char(pr_dtiniper,'DD/MM/RRRR')||'"
                                                                     dtfimper="'||to_char(pr_dtfimper,'DD/MM/RRRR')||'">');
      
    ELSE
      pc_escreve_xml('<crrl728>');
    END IF;
    
    vr_qtsmspen := 0;
    --> Buscar quantidade de SMSs programadas/pendentes de envio
    OPEN cr_smsprog;
    FETCH cr_smsprog INTO vr_qtsmspen;
    CLOSE cr_smsprog;
    
    
    --> Buscar SMSs enviados 
    FOR rw_smsctr IN cr_smsctr LOOP
      vr_flexsreg := TRUE;
      
      IF rw_smsctr.idpacote IN (1,2) THEN
      
        --> Buscar Valor tarifa
        OPEN cr_crapfco(pr_cdcooper => pr_cdcooper,
                        pr_cdtarifa => rw_smsctr.cdtarifa);
        FETCH cr_crapfco INTO vr_vlunitario;
        CLOSE cr_crapfco;
        
        vr_qtsmsenv := 0;
        --> Buscar quantidade de SMSs enviadas
        OPEN cr_smsenv (pr_cdcooper   => pr_cdcooper,  
                        pr_nrdconta   => pr_nrdconta,  
                        pr_idcontrato => rw_smsctr.idcontrato);
        FETCH cr_smsenv INTO vr_qtsmsenv;
        CLOSE cr_smsenv;
        rw_smsctr.qtdsms_usados := vr_qtsmsenv;
        
        --> Nao precisa calcular apenas apresentar valor tarifa
        /*vr_vltottar := vr_qtsmsenv * vr_vlunitario;*/
        vr_vltottar := vr_vlunitario;
        
      ELSE
        --> Nao é necessario calcular, apenas apresenta valor do pacote
        vr_vltottar := rw_smsctr.vlpacote;
        /*vr_vltottar := rw_smsctr.vlpacote + 
                      nvl(rw_smsctr.qtsmsadi * rw_smsctr.vlunitario,0);*/
      END IF;
      
      --> Atribuir a qtd de sms pendente para o contrato que estiver ativo
      vr_qtsmspen_aux := NULL;
      IF rw_smsctr.dhcancela IS NULL THEN
        vr_qtsmspen_aux := nvl(vr_qtsmspen,0);
      END IF;
      
      pc_escreve_xml('<CONTRATO>'||   
                       '<nmprimtl>'||   rw_smsctr.nmprimtl       ||'</nmprimtl>'||
                       '<idpacote>'||   rw_smsctr.idpacote       ||'</idpacote>'||
                       '<dspacote>'||   rw_smsctr.dspacote       ||'</dspacote>'||
                       '<qtsmspct>'||   rw_smsctr.qtdsms_pacote  ||'</qtsmspct>'||
                       '<qtsmsusd>'||   rw_smsctr.qtdsms_usados  ||'</qtsmsusd>'||
                       '<qtsmsdis>'||   rw_smsctr.qtsmsdis       ||'</qtsmsdis>'||
                       '<qtsmsadi>'||   rw_smsctr.qtsmsadi       ||'</qtsmsadi>'||
                       '<qtsmspen>'||   vr_qtsmspen_aux          ||'</qtsmspen>'||                       
                       '<vlpacote>'||   to_char(rw_smsctr.vlpacote,'fm999G999G990D00')     ||'</vlpacote>'||
                       '<vlunitar>'||   to_char(rw_smsctr.vlunitario,'fm999G999G990D00')   ||'</vlunitar>'||
                       '<vltottar>'||   to_char(vr_vltottar,'fm999G999G990D00')            ||'</vltottar>'||
             '        </CONTRATO>');      
    END LOOP;
    
    pc_escreve_xml('</crrl728>',TRUE);
    
    IF vr_flexsreg = FALSE THEN
      vr_dscritic := 'Nenhum registro encontrado para o periodo informado.';
      RAISE vr_exc_erro;
    END IF;
    
    --Para origem InternetBank, já concluiu busca das informações, 
    --geração do relatorio ocorrerá no PHP    
    IF pr_idorigem = 3 THEN      
      pr_dsxmlrel := vr_des_xml;        
    END IF;  
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_relat_resumo_envio_sms : '||SQLERRM;  
  END pc_relat_resumo_envio_sms; 
  
  --> Rotina para verificar se é para apresentar popup do serviço de SMS para o cooperado
  PROCEDURE pc_verifar_oferta_sms(pr_cdcooper      IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  --> Conta do associado                                 
                                 -----> OUT <----                                                                                                  
                                 ,pr_flofesms OUT  INTEGER                   --> Retorna se deve exibir oferta de SMS
                                 ,pr_dsmensag OUT  VARCHAR2                  --> Retorna alerta para o cooperado
                                 ,pr_dscritic OUT  VARCHAR2) IS              --> Retorno de critica

  /* ............................................................................

       Programa: pc_verifar_oferta_sms
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Março/2017                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para verificar se é para apresentar popup do serviço de SMS para o cooperado

       Alteracoes: ----

    ............................................................................ */
    --------------->> CURSORES <<----------------
    
    --> Buscar dados do contrato de sms     
    CURSOR cr_smsparam IS
      SELECT 1 flgoferta_sms
        FROM cecred.tbcobran_sms_param_coop prm
       WHERE prm.cdcooper = pr_cdcooper
         AND prm.flgoferta_sms = 1
         AND trunc(SYSDATE) BETWEEN prm.dtini_oferta AND prm.dtfim_oferta
         AND NOT EXISTS (SELECT 1
                           FROM tbcobran_sms_contrato ctr
                          WHERE ctr.cdcooper = prm.cdcooper
                            AND ctr.nrdconta = pr_nrdconta
                            AND ctr.dhcancela IS NULL)
         --> Verificar se possui convenio de cobrança ativo
         AND EXISTS ( SELECT 1
                        FROM crapceb ceb
                       WHERE ceb.insitceb = 1
                         AND ceb.cdcooper = prm.cdcooper
                         AND ceb.nrdconta = pr_nrdconta
                         AND rownum <= 1);
    rw_smsparam cr_smsparam%ROWTYPE;
    
    CURSOR cr_msg (pr_cdcooper IN crapcco.cdcooper%TYPE) IS
      SELECT dsmensagem 
        FROM tbgen_mensagem 
       WHERE cdproduto = 19 
         AND cdtipo_mensagem = 7 
         AND cdcooper = pr_cdcooper; 
    rw_msg cr_msg%ROWTYPE;         
    
    
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_qtlatpen     INTEGER;
    vr_tot_qtlatpen INTEGER := 0;
    vr_existe       INTEGER := 0; 
    vr_dsalerta     VARCHAR2(2000);
    
  BEGIN
    pr_dsmensag := NULL;  
  
    --> Verificar se coop esta habilitada a enviar SMS de cobrança
    rw_smsparam := NULL;
    OPEN cr_smsparam;
    FETCH cr_smsparam INTO rw_smsparam;
    CLOSE cr_smsparam;
    
    pr_flofesms := nvl(rw_smsparam.flgoferta_sms,0);
    
    rw_msg := NULL;
    OPEN cr_msg(pr_cdcooper);
    FETCH cr_msg INTO rw_msg;
    CLOSE cr_msg;    

    pr_dsmensag := nvl(rw_msg.dsmensagem,'');    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_verifar_oferta_sms : '||SQLERRM;  
  END pc_verifar_oferta_sms; 
  
  
  

END COBR0005;
/
