CREATE OR REPLACE PACKAGE CECRED.INET0002 AS

/*..............................................................................

    Programa: INET0002                         
    Autor   : Jorge Hamaguchi / Jean Deschamps
    Data    : Novembro/2015                      Ultima Atualizacao: 20/02/2019

    Dados referentes ao programa:

    Objetivo  : BO para controlar operacoes de Multiplas Assinaturas PJ.

    Alteracoes: 24/11/2015 - Inclusao da procedure pc_inicia_senha_ass_conj para o
                             PRJ. Assinatura Conjunta (Jean Michel).

			          25/04/2016 - Remocao de caracteres invalidos no nome da agencia 
							               conforme solicitado no chamado 429584 (Kelvin)
    
						    24/03/2016 - Adicionados parâmetros para geraçao de LOG na 'PC_CRIA_TRANS_PEND_TRANSF'
                            (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
    
                20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
                             varias procedures desta package.(Carlos Rafael Tanholi). 
                
                18/07/2016 - Criação da procedure pc_cria_trans_pend_darf_das para o
                             Prj. 338, Pagamento de DARF e DAS (Jean Michel) 

                02/09/2016 - Ajustes na procedure pc_busca_trans_pend, SD 514239 (Jean Michel).

        				11/01/2018 - PJ 454 - SM 1 - Inclusão da procedure de pendência de resgate de cheques 
                             em custódia(Márcio Mouts)

                27/06/2018 - Ajustes de exception em comandos DML e procedures. (Jean Michel)
				
				12/11/2018 - Ajustes no retorno dos dados de transações pendentes, correção para retornar '0,00' quando o valor for ' '. (Guilherme Kuhnen - INC0023927)
                
                20/02/2019 - Inclusão da pc_ret_trans_pend_prop para trnasacoes pendente de emprestimos
                             (PRJ438 - Douglas Pagel / AMcom).   
                
..............................................................................*/

  --Tipo de Registro para limites transacoes pendentes
  TYPE typ_reg_limite_pend IS
    RECORD (tipodtra NUMBER --Tipo de Transacao
           ,hrinipag VARCHAR2(5)
           ,hrfimpag VARCHAR2(5));

  --Tipo de tabela de memoria para limites transacoes pendentes
  TYPE typ_tab_limite_pend IS TABLE OF typ_reg_limite_pend INDEX BY PLS_INTEGER;

  -- PL/TABLE que contem os dados de pagamentos de DARF/DAS
	TYPE typ_reg_darf_das IS
	  RECORD(cdtransacao_pendente	tbpagto_darf_das_trans_pend.cdtransacao_pendente%TYPE
          ,cdcooper             tbpagto_darf_das_trans_pend.cdcooper%TYPE
          ,nrdconta             tbpagto_darf_das_trans_pend.nrdconta%TYPE
          ,tppagamento          tbpagto_darf_das_trans_pend.tppagamento%TYPE
          ,tpcaptura            tbpagto_darf_das_trans_pend.tpcaptura%TYPE
          ,dsidentif_pagto      tbpagto_darf_das_trans_pend.dsidentif_pagto%TYPE
          ,dsnome_fone          tbpagto_darf_das_trans_pend.dsnome_fone%TYPE
          ,dscod_barras         tbpagto_darf_das_trans_pend.dscod_barras%TYPE
          ,dslinha_digitavel    tbpagto_darf_das_trans_pend.dslinha_digitavel%TYPE
          ,dtapuracao           tbpagto_darf_das_trans_pend.dtapuracao%TYPE
          ,nrcpfcgc             tbpagto_darf_das_trans_pend.nrcpfcgc%TYPE
          ,cdtributo            tbpagto_darf_das_trans_pend.cdtributo%TYPE
          ,nrrefere             tbpagto_darf_das_trans_pend.nrrefere%TYPE
          ,vlprincipal          tbpagto_darf_das_trans_pend.vlprincipal%TYPE
          ,vlmulta              tbpagto_darf_das_trans_pend.vlmulta%TYPE
          ,vljuros              tbpagto_darf_das_trans_pend.vljuros%TYPE
          ,vlreceita_bruta      tbpagto_darf_das_trans_pend.vlreceita_bruta%TYPE
          ,vlpercentual         tbpagto_darf_das_trans_pend.vlpercentual%TYPE
          ,dtvencto             tbpagto_darf_das_trans_pend.dtvencto%TYPE
          ,tpleitura_docto      tbpagto_darf_das_trans_pend.tpleitura_docto%TYPE
          ,vlpagamento          tbpagto_darf_das_trans_pend.vlpagamento%TYPE
          ,dtdebito             tbpagto_darf_das_trans_pend.dtdebito%TYPE
          ,idagendamento        tbpagto_darf_das_trans_pend.idagendamento%TYPE
          ,idrowid              VARCHAR2(200));
					
  TYPE typ_tab_darf_das IS
	  TABLE OF typ_reg_darf_das
		INDEX BY BINARY_INTEGER;

  -- PL/TABLE que contem os dados de pagamentos de tributos
  TYPE typ_reg_tributos IS
    RECORD(cdtransacao_pendente tbpagto_tributos_trans_pend.cdtransacao_pendente%TYPE, 
           cdcooper             tbpagto_tributos_trans_pend.cdcooper%TYPE, 
           nrdconta             tbpagto_tributos_trans_pend.nrdconta%TYPE, 
           tppagamento          tbpagto_tributos_trans_pend.tppagamento%TYPE, 
           dscod_barras         tbpagto_tributos_trans_pend.dscod_barras%TYPE, 
           dslinha_digitavel    tbpagto_tributos_trans_pend.dslinha_digitavel%TYPE, 
           nridentificacao      tbpagto_tributos_trans_pend.nridentificacao%TYPE, 
           cdtributo            tbpagto_tributos_trans_pend.cdtributo%TYPE, 
           dtvalidade           tbpagto_tributos_trans_pend.dtvalidade%TYPE, 
           dtcompetencia        tbpagto_tributos_trans_pend.dtcompetencia%TYPE, 
           nrseqgrde            tbpagto_tributos_trans_pend.nrseqgrde%TYPE, 
           nridentificador      tbpagto_tributos_trans_pend.nridentificador%TYPE, 
           dsidenti_pagto       tbpagto_tributos_trans_pend.dsidenti_pagto%TYPE, 
           vlpagamento          tbpagto_tributos_trans_pend.vlpagamento%TYPE, 
           dtdebito             tbpagto_tributos_trans_pend.dtdebito%TYPE, 
           idagendamento        tbpagto_tributos_trans_pend.idagendamento%TYPE,
           idrowid              VARCHAR2(200));
    
  TYPE typ_tab_tributos IS
	  TABLE OF typ_reg_tributos
		INDEX BY BINARY_INTEGER;  
    
    --> Temptable para armazenar titulares com acesso ao internet bank - antigo b1wnet0002.i-tt-titulares.
    TYPE typ_rec_titulares
        IS RECORD (idseqttl  crapttl.idseqttl%TYPE,
                   nmtitula  crapttl.nmextttl%TYPE,
                   nrcpfope  crapttl.nrcpfcgc%TYPE,
                   incadsen  INTEGER,
                   inbloque  INTEGER,
                   inpessoa  crapass.inpessoa%TYPE);

   TYPE typ_tab_titulates IS TABLE OF typ_rec_titulares
        INDEX BY PLS_INTEGER;
        
-- Início SM 454-1
  --Tipo de Registro para cheques em custódia pendentes de resgate 
  TYPE typ_reg_resgate_cst IS
    RECORD (idcustod crapcst.idcustod%type);
         
  --Tipo de tabela de memoria para cheques em custódia pendentes de resgate 
  TYPE typ_tab_resgate_cst IS TABLE OF typ_reg_resgate_cst INDEX BY PLS_INTEGER;
-- Fim SM 454 - 1
        
  --Tipo de registro de memoria para armazenar os dados dos contratos
  TYPE typ_reg_ctd IS
  RECORD (cdtransacao_pendente tbctd_trans_pend.cdtransacao_pendente%TYPE
         ,cdcooper             tbctd_trans_pend.cdcooper%TYPE
         ,nrdconta             tbctd_trans_pend.nrdconta%TYPE
         ,tpcontrato           tbctd_trans_pend.tpcontrato%TYPE
         ,dscontrato           tbctd_trans_pend.dscontrato%TYPE
         ,nrcontrato           tbctd_trans_pend.nrcontrato%TYPE
         ,vlcontrato           tbctd_trans_pend.vlcontrato%TYPE
         ,dhcontrato           tbctd_trans_pend.dhcontrato%TYPE
         ,cdoperad             tbctd_trans_pend.cdoperad%TYPE
         ,cdrecid_crapcdc      tbctd_trans_pend.cdrecid_crapcdc%TYPE);
   
  TYPE typ_tab_ctd IS
  TABLE of typ_reg_ctd INDEX BY PLS_INTEGER;
         
  /* Procedure para  identificar se a operação de autoatendimento 
     foi executada por uma conta PJ que exija ura conjunta*/
  PROCEDURE pc_verifica_rep_assinatura (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%type  --Conta do Associado
                                       ,pr_idseqttl IN crapttl.idseqttl%type  --Titularidade do Associado
                                       ,pr_cdorigem IN INTEGER                --Codigo Origem
                                       ,pr_idastcjt OUT crapass.idastcjt%TYPE --Codigo 1 exige Ass. Conj.
                                       ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE --CPF do Rep. Legal
                                       ,pr_nmprimtl OUT crapass.nmprimtl%TYPE --Nome do Rep. Legal
                                       ,pr_flcartma OUT INTEGER               --Cartao Magnetico conjunta, 0 nao, 1 sim
                                       ,pr_cdcritic OUT INTEGER    --Codigo do erro
                                       ,pr_dscritic OUT VARCHAR2); --Descricao do erro

  PROCEDURE pc_inicia_senha_ass_conj(pr_cdcooper IN crappod.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_nrdconta IN crappod.nrdconta%TYPE -- Numero da conta
                                    ,pr_nrcpfpro IN crappod.nrcpfpro%TYPE -- Numero do CPF do Procurador
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operador
                                    ,pr_cdcritic   OUT INTEGER            -- Codigo do erro
                                    ,pr_dscritic   OUT VARCHAR2);         -- Descricao do erro
																		
	PROCEDURE pc_verifica_validade_procurac(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Nr. da Conta
                                         ,pr_inpessoa IN crapass.inpessoa%TYPE  -- PF/PJ
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencia do titular
                                         ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  -- Nr. CPF/CNPJ
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cód. Crítica
                                         ,pr_dscritic OUT VARCHAR2);            -- Descrição da crítica
  
  --> Rotina responsavel pela criacao de registros de aprovacao
  PROCEDURE pc_cria_aprova_transpend(pr_cdagenci    IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                    ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                    ,pr_nmdatela    IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                    ,pr_idorigem    IN INTEGER                                      --> Origem da solicitacao
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                    ,pr_cdcooper    IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                    ,pr_nrcpfrep    IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                    ,pr_dtmvtolt    IN DATE                                         --> Data do movimento     
                                    ,pr_cdtiptra    IN INTEGER                                      --> Codigo do tipo de transação    
                                    ,pr_cdtranpe    IN tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                    ,pr_tab_crapavt IN CADA0001.typ_tab_crapavt_58                  --> Tabela de procuradore
                                    ,pr_cdcritic  OUT INTEGER                                       --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2);                                    --> Descrição da crítica       

                                         
  /* Antiga proc. exclui_transacoes da BO16*/
  PROCEDURE pc_exclui_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                 ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                 ,pr_cdagenci IN INTEGER                --Numero da agencia
                                 ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                 ,pr_dtmvtolt IN DATE                   --Data da operacao
                                 ,pr_cdorigem IN INTEGER                --Codigo Origem
                                 ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                 ,pr_cdditens IN VARCHAR2               --Itens
                                 ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                 ,pr_flgerlog IN INTEGER                --Flag de log
                                 ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                 ,pr_dscritic OUT VARCHAR2);            --Descricao do erro

  -- Procedimentos para criaco de mensagens referente a Assinatura Conjunta                                 
  PROCEDURE pc_cria_msgs_trans (pr_cdcooper IN crapcop.cdcooper%TYPE                      -- Codigo Cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE                      -- Conta do Associado
                               ,pr_nrdcaixa IN INTEGER                                    -- Numero do caixa
                               ,pr_cdagenci IN INTEGER                                    -- Numero da agencia
                               ,pr_cdoperad IN VARCHAR2                                   -- Numero do operador
                               ,pr_dtmvtolt IN DATE                                       -- Data da operacao
                               ,pr_cdorigem IN INTEGER                                    -- Codigo Origem
                               ,pr_nmdatela IN VARCHAR2                                   -- Nome da tela
                               ,pr_cdtranpe IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Codigo da Transacao Principal
                               ,pr_tptransa IN INTEGER                                    -- Tipo de Transacao
                               ,pr_dsdmensg OUT VARCHAR2							                    -- Descricao da mensagem
                               ,pr_cdcritic OUT INTEGER                                   -- Codigo do erro
                               ,pr_dscritic OUT VARCHAR2);                                -- Descricao do erro
    
  /* Antiga proc. exclui_transacoes da BO16*/
  PROCEDURE pc_reprova_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                  ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                  ,pr_cdagenci IN INTEGER                --Numero da agencia
                                  ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                  ,pr_dtmvtolt IN DATE                   --Data da operacao
                                  ,pr_cdorigem IN INTEGER                --Codigo Origem
                                  ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                  ,pr_cdditens IN VARCHAR2               --Itens
                                  ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                  ,pr_idseqttl IN NUMBER 				 --Sequencial de Titularidade
                                  ,pr_flgerlog IN INTEGER                --Flag de log
                                  ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2);            --Descricao do erro                                 

  -- Procedure para validacao de representantes legais por transacao
  PROCEDURE pc_valid_repre_legal_trans(pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta  IN crapsnh.nrdconta%TYPE
                                      ,pr_idseqttl  IN crapsnh.idseqttl%TYPE
                                      ,pr_flvldrep  IN INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Procedure de criacao de transacao de pagamentos
  PROCEDURE pc_cria_trans_pend_pagto(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                    ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                    ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                    ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                    ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                    ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                    ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                    ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                    ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                    ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                    ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                    ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                    ,pr_cdctrlcs  IN tbpagto_trans_pend.cdctrlcs%TYPE          --> Código de controle de consulta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                   --> Descricao de Critica

  -- Procedure de criacao de transacao de TED
  PROCEDURE pc_cria_trans_pend_ted(pr_cdagenci  IN crapage.cdagenci%TYPE                         --> Codigo do PA
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                         --> Numero do Caixa
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE                         --> Codigo do Operados
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE                         --> Nome da Tela
                                  ,pr_idorigem  IN INTEGER                                       --> Origem da solicitacao
                                  ,pr_idseqttl  IN crapttl.idseqttl%TYPE                         --> Sequencial de Titular            
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do operador juridico
                                  ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do representante legal
                                  ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                --> Cooperativa do Terminal
                                  ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                --> Agencia do Terminal
                                  ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                --> Numero do Terminal Financeiro
                                  ,pr_dtmvtolt  IN DATE                                          --> Data do movimento     
                                  ,pr_cdcooper  IN tbspb_trans_pend.cdcooper%TYPE                --> Codigo da cooperativa
                                  ,pr_nrdconta  IN tbspb_trans_pend.nrdconta%TYPE                --> Numero da Conta
                                  ,pr_vllanmto  IN tbspb_trans_pend.vlted%TYPE                   --> Valor de Lancamento
                                  ,pr_nrcpfcnpj IN tbspb_trans_pend.nrcpfcnpj_favorecido%TYPE    --> CPF/CNPJ do Favorecido
                                  ,pr_nmtitula  IN tbspb_trans_pend.nmtitula_favorecido%TYPE     --> Nome to Titular Favorecido
                                  ,pr_tppessoa  IN tbspb_trans_pend.tppessoa_favorecido%TYPE     --> Tipo de pessoa do Favorecido
                                  ,pr_tpconta   IN tbspb_trans_pend.tpconta_favorecido%TYPE      --> Tipo da conta do Favorecido
                                  ,pr_dtmvtopg  IN tbspb_trans_pend.dtdebito%TYPE                --> Data do Pagamento
                                  ,pr_idagenda  IN tbspb_trans_pend.idagendamento%TYPE           --> Indicador de agendamento
                                  ,pr_cddbanco  IN tbspb_trans_pend.cdbanco_favorecido%TYPE      --> Codigo do banco
                                  ,pr_cdageban  IN tbspb_trans_pend.cdagencia_favorecido%TYPE    --> Codigo da agencia bancaria
                                  ,pr_nrctadst  IN tbspb_trans_pend.nrconta_favorecido%TYPE      --> Conta de destino
                                  ,pr_cdfinali  IN tbspb_trans_pend.cdfinalidade%TYPE            --> Codigo da finalidade
                                  ,pr_dstransf  IN tbspb_trans_pend.dscodigo_identificador%TYPE  --> Descricao da transferencia
                                  ,pr_dshistor  IN tbspb_trans_pend.dshistorico%TYPE             --> Descricao do historico
                                  ,pr_nrispbif  IN tbspb_trans_pend.nrispb_banco_favorecido%TYPE --> Codigo unico do banco
                                  ,pr_idastcjt  IN crapass.idastcjt%TYPE                         --> Indicador de Assinatura Conjunta
                                  ,pr_lsdatagd  IN VARCHAR2
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                         --> Codigo de Critica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE);                       --> Descricao de Critica
  

  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_transf(pr_cdtiptra  IN INTEGER                                         --> Tipo da Transacao
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE                           --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                           --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                           --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                           --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                         --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                           --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                  --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                  --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                  --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                            --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE               --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE               --> Numero da Conta
                                     ,pr_vllanmto  IN tbtransf_trans_pend.vltransferencia%TYPE        --> Valor de Lancamento
                                     ,pr_dtmvtopg  IN tbtransf_trans_pend.dtdebito%TYPE               --> Data do Pagamento
                                     ,pr_idagenda  IN tbtransf_trans_pend.idagendamento%TYPE          --> Indicador de agendamento
                                     ,pr_cdageban  IN tbtransf_trans_pend.cdagencia_coop_destino%TYPE --> Codigo da agencia bancaria
                                     ,pr_nrctadst  IN tbtransf_trans_pend.nrconta_destino%TYPE        --> Conta de destino
                                     ,pr_lsdatagd  IN VARCHAR2                                        --> Lista de datas para agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                           --> Indicador de Assinatura Conjunta
									 ,pr_flmobile  IN tbtransf_trans_pend.indmobile%TYPE              --> Indicador Mobile
									 ,pr_idtipcar  IN tbtransf_trans_pend.indtipo_cartao%TYPE         --> Indicador Tipo Cartão Utilizado
									 ,pr_nrcartao  IN tbtransf_trans_pend.nrcartao%TYPE               --> Numero Cartao
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                           --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);                         --> Descricao de Critica  

  -- Procedure de criacao de transacao de credito pré-aprovado
  PROCEDURE pc_cria_trans_pend_credito(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                      ,pr_vlemprst  IN tbepr_trans_pend.vlemprestimo%TYPE      --> Valor do emprestimo
                                      ,pr_qtpreemp  IN tbepr_trans_pend.nrparcelas%TYPE        --> Numero de parcelas
                                      ,pr_vlpreemp  IN tbepr_trans_pend.vlparcela%TYPE         --> Valor da parcela
                                      ,pr_dtdpagto  IN tbepr_trans_pend.dtprimeiro_vencto%TYPE --> Data de vencimento da primeira parcela	
                                      ,pr_percetop  IN tbepr_trans_pend.vlpercentual_cet%TYPE  --> Valor percentual do CET
                                      ,pr_vlrtarif  IN tbepr_trans_pend.vltarifa%TYPE          --> Valor da tarifa do emprestimo
                                      ,pr_txmensal  IN tbepr_trans_pend.vltaxa_mensal%TYPE     --> Valor da taxa mensal de juros
                                      ,pr_vltariof  IN tbepr_trans_pend.vliof%TYPE             --> Valor de IOF
                                      ,pr_vltaxiof  IN tbepr_trans_pend.vlpercentual_iof%TYPE  --> Valor percentual do IOF
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);                 --> Descricao de Critica

  -- Início Projeto 454 - SM 1 
  -- Procedure de criacao de transacao de resgate de cheque em custódia
  PROCEDURE pc_cria_trans_pend_resgate_cst(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Conta
                                          ,pr_idseqttl    IN crapttl.idseqttl%TYPE             --> Número do Titular
                                          ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do representante legal
                                          ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do operador juridico
                                          ,pr_cdcoptfn    IN tbgen_trans_pend.cdcoptfn%TYPE    --> Cooperativa do Terminal
                                          ,pr_cdagetfn    IN tbgen_trans_pend.cdagetfn%TYPE    --> Agencia do Terminal
                                          ,pr_nrterfin    IN tbgen_trans_pend.nrterfin%TYPE    --> Numero do Terminal Financeiro
                                          ,pr_idastcjt    IN crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                          ,pr_dscheque    IN VARCHAR2                          --> Lista de CMC7s
                                          ,pr_xmllog      IN VARCHAR2                          --> XML com informações de LOG
                                          ,pr_cdcritic    OUT PLS_INTEGER                      --> Código da crítica
                                          ,pr_dscritic    OUT VARCHAR2                         --> Descrição da crítica
                                          ,pr_retxml      IN OUT NOCOPY xmltype                --> Arquivo de retorno do XML
                                          ,pr_nmdcampo    OUT VARCHAR2                         --> Nome do campo com erro
                                          ,pr_des_erro    OUT VARCHAR2);                       --> Descricao do Erro 

  -- Procedure de verificação de necessidade de assinatura conjunta
  PROCEDURE pc_verifica_nec_ass_conjunta(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Contaimento     
                                        ,pr_idastcjt   OUT crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                        ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo de Critica
                                        ,pr_dscritic   OUT crapcri.dscritic%TYPE);
  -- Fim Projeto 454 - SM 1 
  -- Procedure de criacao de transacao de aplicacoes
  PROCEDURE pc_cria_trans_pend_aplica(pr_cdagenci  IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                      --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                         --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE            --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE            --> Numero da Conta
                                     ,pr_idoperac  IN tbcapt_trans_pend.tpoperacao%TYPE            --> Identifica tipo da operacao (1 – Cancelamento Aplicacao / 2 – Resgate / 3 – Agendamento Resgate / 4 – Cancelamento Total Agendamento / 5 – Cancelamento Item Agendamento)
                                     ,pr_idtipapl  IN tbcapt_trans_pend.tpaplicacao%TYPE           --> Tipo da aplicacao (A – Antigos Produtos / N – Novos Produtos)
                                     ,pr_nraplica  IN tbcapt_trans_pend.nraplicacao%TYPE           --> Numero da aplicacao
                                     ,pr_cdprodut  IN tbcapt_trans_pend.cdproduto_aplicacao%TYPE   --> Codigo do produto da aplicacao
                                     ,pr_tpresgat  IN tbcapt_trans_pend.tpresgate%TYPE             --> Indicador do tipo de resgate (1 – Parcial / 2 – Total)
                                     ,pr_vlresgat  IN tbcapt_trans_pend.vlresgate%TYPE             --> Valor do resgate
                                     ,pr_nrdocmto  IN tbcapt_trans_pend.nrdocto_agendamento%TYPE   --> Numero de documento do agendamento
                                     ,pr_idtipage  IN tbcapt_trans_pend.tpagendamento%TYPE         --> Identifica o tipo de agendamento (0 – Aplicacao / 1 – Resgate)
                                     ,pr_idperage  IN tbcapt_trans_pend.idperiodo_agendamento%TYPE --> Identifica a periodicidade do agendamento (0 – Unico / 1 – Mensal)
                                     ,pr_qtmesage  IN tbcapt_trans_pend.qtmeses_agendamento%TYPE   --> Quantidade de meses do agendamento
                                     ,pr_dtdiaage  IN tbcapt_trans_pend.nrdia_agendamento%TYPE     --> Dia em que o agendamento deve ser efetivado
                                     ,pr_dtiniage  IN tbcapt_trans_pend.dtinicio_agendamento%TYPE  --> Data de inicio do agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                        --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);                      --> Descricao de Critica

  -- Procedure de criacao de transacao de debitos automaticos
  PROCEDURE pc_cria_trans_pend_deb_aut(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                      ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                      ,pr_cdhisdeb  IN tbconv_trans_pend.cdhist_convenio%TYPE     --> Codigo do historico do convenio
                                      ,pr_idconsum  IN tbconv_trans_pend.iddebito_automatico%TYPE --> Identificacao do debito automatico
                                      ,pr_dshisext  IN tbconv_trans_pend.dshist_debito%TYPE       --> Descricao complementar do historico do debito
                                      ,pr_vlmaxdeb  IN tbconv_trans_pend.vlmaximo_debito%TYPE     --> Valor maximo do debito
                                      ,pr_cdempcon  IN tbconv_trans_pend.cdconven%TYPE            --> Codigo do convenio
                                      ,pr_cdsegmto  IN tbconv_trans_pend.cdsegmento_conven%TYPE   --> Codigo do segmento do convenio
                                      ,pr_dtmvtopg  IN tbconv_trans_pend.dtdebito_fatura%TYPE     --> Data de debito automatico da fatura
                                      ,pr_nrdocmto  IN tbconv_trans_pend.nrdocumento_fatura%TYPE  --> Numero do documento da fatura
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica

  -- Procedure de criacao de transacao de folha de pagamento
  PROCEDURE pc_cria_trans_pend_folha(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                    ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_flsolest  IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                    ,pr_indrowid  IN VARCHAR2                                   --> Lista de ROWIDS
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica
	
	--> Rotina para criação de transação pendente de pacote de tarifas															
  PROCEDURE pc_cria_trans_pend_pacote_tar (pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
																					,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
																					,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
																					,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
																					,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
																					,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
																					,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
																					,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
																					,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
																					,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
																					,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
																					,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
																					,pr_cdcooper  IN tbtarif_pacote_trans_pend.cdcooper%TYPE    --> Codigo da cooperativa
																					,pr_nrdconta  IN tbtarif_pacote_trans_pend.nrdconta%TYPE    --> Numero da Conta
																					,pr_cdpacote  IN tbtarif_pacote_trans_pend.cdpacote%TYPE    --> Cód. pacote de tarifas
																					,pr_dtvigenc  IN tbtarif_pacote_trans_pend.dtinicio_vigencia%TYPE--> Data de inicio de vigencia
																					,pr_dtdiadbt  IN tbtarif_pacote_trans_pend.nrdiadebito%TYPE     --> Dia débito
																					,pr_vlpacote  IN tbtarif_pacote_trans_pend.vlpacote%TYPE
																					,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
																					,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
																					,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica																		
  
  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_descto(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                     ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE             --> Número do Titular
                                     ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do representante legal
                                     ,pr_cdagenci    IN crapage.cdagenci%TYPE             --> Codigo do PA
                                     ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE             --> Numero do Caixa
                                     ,pr_cdoperad    IN crapope.cdoperad%TYPE             --> Codigo do Operados
                                     ,pr_nmdatela    IN craptel.nmdatela%TYPE             --> Nome da Tela
                                     ,pr_idorigem    IN INTEGER                           --> Origem da solicitacao
                                     ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do operador juridico
                                     ,pr_cdcoptfn    IN tbgen_trans_pend.cdcoptfn%TYPE    --> Cooperativa do Terminal
                                     ,pr_cdagetfn    IN tbgen_trans_pend.cdagetfn%TYPE    --> Agencia do Terminal
                                     ,pr_nrterfin    IN tbgen_trans_pend.nrterfin%TYPE    --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt    IN DATE                              --> Data do movimento     
                                     ,pr_idastcjt    IN crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                     ,pr_tab_cheques IN dscc0001.typ_tab_cheques          --> Lista de Cheques
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo de Critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE);           --> Descricao de Critica
  
  --> Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
  PROCEDURE pc_cria_transacao_operador(pr_cdagenci   IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                      ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                      ,pr_cdoperad   IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                      ,pr_nmdatela   IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                      ,pr_idorigem   IN INTEGER                                      --> Origem da solicitacao
                                      ,pr_idseqttl   IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                      ,pr_cdcooper   IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                      ,pr_nrdconta   IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                      ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep   IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn   IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                      ,pr_cdagetfn   IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                      ,pr_nrterfin   IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt   IN DATE                                         --> Data do movimento     
                                      ,pr_cdtiptra   IN INTEGER                                      --> Codigo do tipo de transação    
                                      ,pr_idastcjt   IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                      ,pr_tab_crapavt OUT CADA0001.typ_tab_crapavt_58 
                                      ,pr_cdtranpe  OUT tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                      ,pr_dscritic  OUT VARCHAR2);                                   --> Descrição da crítica       
  
  -- Rotina para obter o horario limite das aprovacoes de transacoes pendentes
  PROCEDURE pc_horario_trans_pend( pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE
                                  ,pr_idorigem  IN INTEGER
                                  ,pr_tab_limite_pend OUT INET0002.typ_tab_limite_pend --Tabelas de retorno de horarios limite transacoes pendente
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE);
                                  
  --> Rotina responsavel pela consulta de ROWID 
  PROCEDURE pc_obtem_rowid_folha(pr_cdcooper  IN crappfp.cdcooper%TYPE   --> Codigo da cooperativa
                                ,pr_cdempres  IN crappfp.cdempres%TYPE   --> Codigo da empresa
                                ,pr_nrseqpag  IN crappfp.nrseqpag%TYPE   --> Sequencia de folha de pagamento
                                ,pr_rowidpag OUT VARCHAR2                --> ROWID da folha de pagamento
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo de Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao de Critica

  --> Rotina responsavel pela Busca de Informacoes das Transacoes Pendentes 
  PROCEDURE pc_busca_trans_pend(pr_cdcooper IN  crapcop.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_nrdconta IN  crapass.nrdconta%TYPE --> Numero conta
                               ,pr_idseqttl IN  crapsnh.idseqttl%TYPE --> Titularidade 
                               ,pr_nrcpfope IN  crapsnh.nrcpfcgc%TYPE --> CPF operador
                               ,pr_cdagenci IN  crapage.cdagenci%TYPE --> Numero PA
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE --> Data Movimentacao
                               ,pr_cdorigem IN  INTEGER               --> Id de origem
                               ,pr_cdtransa IN  tbgen_trans_pend.cdtransacao_pendente%TYPE DEFAULT 0 --> Código da transação pendente
                               ,pr_insittra IN  INTEGER               --> Id de situacao da transacao
                               ,pr_dtiniper IN  DATE                  --> Data Inicio
                               ,pr_dtfimper IN  DATE                  --> Data final
                               ,pr_nrregist IN  INTEGER               --> Numero da qtd de registros da pagina
                               ,pr_nriniseq IN  INTEGER               --> Numero do registro inicial
                               ,pr_clobxmlc OUT CLOB                  --> XML com informações
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2);            --> Descricao da crítica

  --> Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  PROCEDURE pc_cria_trans_pend_darf_das(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (1 – DARF / 2 – DAS)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia
                                       ,pr_dsnomfon  IN VARCHAR2 						                  --> Nome e telefone da guia
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_nrrefere  IN VARCHAR2 						                  --> Número de referência da guia
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_vlrprinc  IN NUMBER 							                  --> Valor principal da guia
                                       ,pr_vlrmulta  IN NUMBER 							                  --> Valor da multa da guia
                                       ,pr_vlrjuros  IN NUMBER 							                  --> Valor dos juros da guia
                                       ,pr_vlrecbru  IN NUMBER 							                  --> Valor da receita bruta acumulada da guia
                                       ,pr_vlpercen  IN NUMBER 							                  --> Valor do percentual da guia
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2);      	                    --> Descriçao do erro
  --                                       
  PROCEDURE pc_cria_trans_pend_pag_gps(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                      ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                      ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                      ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                      ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                      ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                      ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                      ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                      ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                      ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                      ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                      ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                      ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                      ,pr_nrdrowid  OUT ROWID
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                      ,pr_dscritic  OUT crapcri.dscritic%TYPE);                   --> Descricao de Critica                                       

  /******************************************************************************/
  /**     Procedure para carregar titulares/operadores para acesso a conta     **/
  /******************************************************************************/
  PROCEDURE pc_carrega_ttl_internet ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo de agencia
                                     ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE --> Nome da tela
                                     ,pr_idorigem  IN INTEGER               --> Identificador sistema origem
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do Associado
                                     ,pr_idseqttl  IN crapttl.idseqttl%type --> Titularidade do Associado
                                     ,pr_flgerlog  IN INTEGER               --> Identificador se gera log  
                                     ,pr_flmobile  IN INTEGER               --> identificador se é chamada mobile
                                     ,pr_floperad  IN INTEGER DEFAULT 1     --> identificador se deve carregar operadores                                     
                                     
                                     ,pr_tab_titulates OUT typ_tab_titulates --> Retorna titulares com acesso ao Ibank
                                     ,pr_qtdiaace      OUT INTEGER               --> Retornar dias do primeiro acesso
                                     ,pr_nmprimtl      OUT crapass.nmprimtl%TYPE --> Retornar nome do cooperaro

                                     ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro
                                     
  PROCEDURE pc_carrega_ttl_internet_web ( pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                         ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro   OUT VARCHAR2);             --> Erros do processo
                                 
  --> Criar transaçao pendente para a inclusao do contrato de serviço de SMS  
  PROCEDURE pc_cria_trans_pend_sms_cobran( pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                          ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                          ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                          ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                          ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                          ,pr_cdtiptra  IN tbgen_trans_pend.tptransacao%TYPE          --> Tipo de transacao (16 - Adesao, 17 - Cancelamento)
                                          ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                          ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal) 
                                          ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                          ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                          ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                          ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                          ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                          ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                          ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                          ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                          ,pr_idpacote  IN tbcobran_sms_pacotes.idpacote%TYPE         --> Codigo do pacote de SMS
                                          ,pr_vlservico IN crapfco.vltarifa%TYPE                      --> Valor de tarifa do SMS/Pacote de SMS
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica
  PROCEDURE pc_busca_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                 ,pr_idorigem IN INTEGER               --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
																 ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  PROCEDURE pc_cria_trans_pend_recarga(pr_cdagenci  IN crapage.cdagenci%TYPE -- Cód. Agência
																		  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE -- Nr. do caixa
																		  ,pr_cdoperad  IN crapope.cdoperad%TYPE -- Cód. operador
																		  ,pr_nmdatela  IN craptel.nmdatela%TYPE -- Nome da tela
																	 	  ,pr_idorigem  IN INTEGER               -- Id. origem
																		  ,pr_idseqttl  IN INTEGER               -- Id. do titular
                                      ,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Cpf do operador da conta
																			,pr_nrcpfrep  IN crapsnh.nrcpfcgc%TYPE -- Cpf do representante legal
																			,pr_cdcoptfn  IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (TAA)
																			,pr_cdagetfn  IN crapage.cdagenci%TYPE -- Agência do terminal financeiro (TAA)
																			,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (TAA)
																			,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data de movimento
																			,pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
																			,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta
																			,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
																			,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
																			,pr_lsdatagd  IN VARCHAR2                          -- Lista de datas de recarga (Apenas em agendamento recorrente)
																			,pr_tprecarga IN INTEGER                           -- Tipo recarga (1-Online / 2-Agendada)
																			,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE     -- DDD
																			,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
																			,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Operadora
																			,pr_cdprodut  IN tbrecarga_produto.cdproduto%TYPE   -- Produto
																			,pr_idastcjt  IN INTEGER                            -- Id. assinatura conjunta
																			,pr_cdcritic  OUT PLS_INTEGER                       -- Cód. da crítica
																			,pr_dscritic  OUT VARCHAR2);                      -- Desc. da crítica																			
                                 
PROCEDURE pc_busca_limite_preposto(pr_cdcooper IN VARCHAR2 
                                    ,pr_nrdconta IN VARCHAR2 
                                    ,pr_nrcpf    IN VARCHAR2 
                                    ,pr_xmllog   IN  VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER                       
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);
                                     
  PROCEDURE pc_valida_limite_preposto(pr_cdcooper           IN VARCHAR2
                                     ,pr_nrdconta           IN VARCHAR2 
                                     ,pr_idseqttl           IN VARCHAR2
                                     ,pr_vllimtrf           IN VARCHAR2 
                                     ,pr_vllimpgo           IN VARCHAR2
                                     ,pr_vllimted           IN VARCHAR2 
                                     ,pr_vllimvrb           IN VARCHAR2 
                                     ,pr_vllimflp           IN VARCHAR2 
                                     ,pr_xmllog             IN VARCHAR2
                                     ,pr_cdcritic       OUT PLS_INTEGER                       
                                     ,pr_dscritic       OUT VARCHAR2
                                     ,pr_retxml        IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); 

  PROCEDURE pc_altera_limite_preposto(pr_cdcooper           IN VARCHAR2
                                     ,pr_nrdconta           IN VARCHAR2 
                                     ,pr_nrcpf              IN VARCHAR2 
                                     ,pr_idseqttl           IN VARCHAR2
                                     ,pr_cdoperad           IN VARCHAR2 
                                     ,pr_vllimtrf           IN VARCHAR2 
                                     ,pr_vllimpgo           IN VARCHAR2
                                     ,pr_vllimted           IN VARCHAR2 
                                     ,pr_vllimvrb           IN VARCHAR2 
                                     ,pr_vllimflp           IN VARCHAR2
                                     ,pr_xmllog             IN  VARCHAR2
                                     ,pr_cdcritic       OUT PLS_INTEGER                       
                                     ,pr_dscritic       OUT VARCHAR2
                                     ,pr_retxml        IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_busca_preposto_master(pr_cdcooper IN VARCHAR2 
                                    ,pr_nrdconta IN VARCHAR2 
                                    ,pr_xmllog   IN  VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER                       
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_altera_preposto_master(pr_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                   ,pr_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE 
                                   ,pr_nrcpf    IN TBCC_LIMITE_PREPOSTO.nrcpf%TYPE 
                                   ,pr_xmllog   IN  VARCHAR2
                                   ,pr_cdcritic OUT PLS_INTEGER                       
                                   ,pr_dscritic OUT VARCHAR2
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); 
-- Validar aprovacao preposto master
PROCEDURE pc_valida_apv_master (pr_cdcooper IN crapsnh.cdcooper%TYPE 
                               ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                               ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE
                               ,pr_cdtransacao_pendente IN tbgen_aprova_trans_pend.cdtransacao_Pendente%type
                               ,pr_conttran OUT INTEGER -- Identificador se deve finalizar o processo ou nao
                               ,pr_cdcritic OUT PLS_INTEGER                       
                               ,pr_dscritic OUT VARCHAR2);

PROCEDURE pc_corrigi_limite_preposto(pr_cdcooper IN VARCHAR2
                                     ,pr_nrdconta IN VARCHAR2 
                                     ,pr_idseqttl IN VARCHAR2
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_vllimtrf IN VARCHAR2 
                                     ,pr_vllimpgo IN VARCHAR2
                                     ,pr_vllimted IN VARCHAR2 
                                     ,pr_vllimvrb IN VARCHAR2 
                                     ,pr_xmllog   IN VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER                       
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);    
                                                                                              
PROCEDURE pc_busca_resp_assinatura(pr_cdcooper IN VARCHAR2 
                                    ,pr_nrdconta IN VARCHAR2 
                                    ,pr_xmllog   IN  VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER                       
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);                                         
                                                                                              
--> Rotina responsavel pela criacao de transacoes pendentes de pagamentos de tributos
  PROCEDURE pc_cria_trans_pend_tributos(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (3 – FGTS / 4 – DAE)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia                                      
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrsqgrde  IN NUMBER                                --> Numero da guia GRDE
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_identifi  IN VARCHAR2 						                  --> Número de identificacao CNPJ/CPF/CEI
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_identificador IN VARCHAR2                          --> Identificador                                       
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2);   			                    --> Descriçao do erro                                        
                                       

  PROCEDURE pc_ret_trans_pend_trib( pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                            --> Identificador de Origem 
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                                   ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                                   ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                   ,pr_tab_tributos OUT INET0002.typ_tab_tributos);   --> Tabela com os dados de tributos
                                   
  PROCEDURE pc_ret_trans_pend_trib_car( pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                       ,pr_idorigem IN INTEGER               --> Identificador de Origem 
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                       ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
                                       ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														 		       ,pr_dscritic OUT VARCHAR2);         --> Descrição da crítica                                       
                                 
  PROCEDURE pc_cria_trans_pend_dscto_tit(pr_cdcooper          IN tbdsct_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta          IN tbdsct_trans_pend.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl          IN crapttl.idseqttl%TYPE           --> Número do Titular
                                        ,pr_nrcpfrep          IN crapopi.nrcpfope%TYPE           --> Numero do cpf do representante legal
                                        ,pr_cdagenci          IN crapage.cdagenci%TYPE           --> Codigo do PA
                                        ,pr_nrdcaixa          IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                        ,pr_cdoperad          IN crapope.cdoperad%TYPE           --> Codigo do Operados
                                        ,pr_nmdatela          IN craptel.nmdatela%TYPE           --> Nome da Tela
                                        ,pr_idorigem          IN INTEGER                         --> Origem da solicitacao
                                        ,pr_nrcpfope          IN crapopi.nrcpfope%TYPE           --> Numero do cpf do operador juridico
                                        ,pr_cdcoptfn          IN tbgen_trans_pend.cdcoptfn%TYPE  --> Cooperativa do Terminal
                                        ,pr_cdagetfn          IN tbgen_trans_pend.cdagetfn%TYPE  --> Agencia do Terminal
                                        ,pr_nrterfin          IN tbgen_trans_pend.nrterfin%TYPE  --> Numero do Terminal Financeiro
                                        ,pr_dtmvtolt          IN DATE                            --> Data do movimento     
                                        ,pr_idastcjt          IN crapass.idastcjt%TYPE           --> Indicador de Assinatura Conjunta
                                        ,pr_tab_dados_titulos IN tela_atenda_dscto_tit.typ_tab_dados_titulos --> Titulos para desconto
                                        ,pr_cdcritic         OUT crapcri.cdcritic%TYPE           --> Codigo de Critica
                                        ,pr_dscritic         OUT crapcri.dscritic%TYPE);         --> Descricao de Critica
  --PJ470
  PROCEDURE pc_ret_trans_pend_ctd(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE       --> Nome da Tela
                                 ,pr_idorigem IN INTEGER                     --> Identificador de Origem
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2                    --> Codigo da Transacao
                                 ,pr_cdcritic OUT INTEGER                    --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                                 ,pr_tab_ctd OUT INET0002.typ_tab_ctd);      --> Tabela com os dados de tributos

  --PJ470
  PROCEDURE pc_ret_trans_pend_ctd_car (pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE       --> Nome da Tela
                                      ,pr_idorigem IN INTEGER                     --> Identificador de Origem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Titular da Conta
                                      ,pr_cdtrapen IN VARCHAR2                    --> Codigo da Transacao
                                      ,pr_clobxmlc OUT CLOB                       --> XML com informações de Log
                                      ,pr_cdcritic OUT INTEGER                    --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);                 --> Descrição da crítica

  PROCEDURE pc_cria_trans_pend_efet_prop(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                        ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                        ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                        ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                        ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                        ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                        ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                        ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                        ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                        ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                        ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                        ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                        ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                        ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                        ,pr_nrctremp  IN crawepr.nrctremp%TYPE                   --> numero do da proposta
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);                 --> Descricao de Critica


  PROCEDURE pc_ret_trans_pend_prop( pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                            --> Identificador de Origem 
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                                   ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                                   ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                   ,pr_nrctremp OUT tbepr_trans_pend_efet_proposta.nrctremp%TYPE   --> Número da proposta da pendencia
                                   ,pr_vlemprst OUT crawepr.vlemprst%TYPE);   --> Número da proposta da pendencia
                                      
																								 
END INET0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INET0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : INET0002
  --  Sistema  : Procedimentos Multiplas Assinaturas PJ
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi / Jean Deschamps
  --  Data     : Novembro/2015.                   Ultima atualizacao: 20/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos Multiplas Assinaturas PJ
  --
  -- Alteracoes: 24/11/2015 - Inclusao da procedure pc_inicia_senha_ass_conj para o
  --                          PRJ. Assinatura Conjunta (Jean Michel).
  --  
  --             16/02/2016 - Inclusao do parametro conta na chamada da
  --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
  --  
  --    	       24/03/2016 - Adicionados parâmetros para geraçao de LOG na 'PC_CRIA_TRANS_PEND_TRANSF'
  --                          (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
  --
  --             20/06/2016 - Correcao para o uso da function fn_busca_dstextabem da TABE0001 em 
  --                          varias procedures desta package.(Carlos Rafael Tanholi).   
  --
  --             21/06/2016 - Ajuste para incluir alterações perdidas na realização de merge entre versões
  -- 					               (Adriano).
  --
  --             18/07/2016 - Criação da procedure pc_cria_trans_pend_darf_das para o
  --                          Prj. 338, Pagamento de DARF e DAS (Jean Michel)    
  --
  --             02/09/2016 - Ajustes na procedure pc_busca_trans_pend, SD 514239 (Jean Michel).                  	                         
  --
  --
  --             02/09/2016 - Ajustes na procedure pc_busca_trans_pend, SD 514239 (Jean Michel).                  
  --
  --             28/11/2016 - Criaçao pc_cria_trans_pend_sms_cobran e inclusao dos transaçoes pendentes
  --                          16 e 17. PRJ319 - SMS Cobrança (Odirlei-AMcom) 
  --
  --             12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
	--
	--             03/11/2017 - Ajuste para tratar agendamentos de recarga de celular duplicados. (Reinert)	
  --
  --      			 11/01/2018 - PJ 454 - SM 1 - Inclusão da procedure de pendência de resgate de cheques (Márcio Mouts)
  --
  --             18/05/2018 - Adicionado o procedimento pc_cria_trans_pend_dscto_tit (Paulo Penteado (GFT))
  --
  --      			 27/06/2018 - Ajustes de exception em comandos DML e procedures. (Jean Michel)
  --
  --             20/02/2019 - Inclusão da pc_ret_trans_pend_prop para trnasacoes pendente de emprestimos
  --                          (PRJ438 - Douglas Pagel / AMcom).  
  --                        
  ---            21/02/2019 - Alteração das rotinas pc_cria_msgs_trans, pc_reprova_trans_pend
  --                          para contemplar o novo Tipo Transacao = 21 (Emprestimos/Financiamentos)
  --                          (PJ 438 - Rafael R. Santos / AMcom).  
  --                        - Inclusão da procedure pc_cria_trans_pend_efet_prop
  --
  --             05/08/2019 - INC0021893 - Adicionada validação de duplicidade nas transações pendentes 
  --                          criadas em contas com assinatura conjunta ou operadores.
  --                          (Guilherme Kuhnen - f0032175)
  --
  ---------------------------------------------------------------------------------------------------------------

  --INC0011323
  vr_cdprogra VARCHAR2(20) := 'INET0002';
  
  ------------------------------ PROCEDURES --------------------------------    
  --> Grava informações para validar erro de programa/ sistema
  PROCEDURE pc_gera_log(pr_cdcooper      IN PLS_INTEGER           --> Cooperativa
                       ,pr_dstiplog      IN VARCHAR2              --> Tipo Log
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2
                       ,pr_nmarqlog      IN tbgen_prglog.nmarqlog%type DEFAULT NULL
                       ,pr_tpexecucao    IN tbgen_prglog.tpexecucao%type DEFAULT 1 -- cadeia - 12/02/2019 - REQ0035813
                       ) IS
    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana Lúcia E. Volles
    --  Data     : Abril/2019             Ultima atualizacao: 17/04/2019
    --  Chamado  : INC0011323
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla gravação de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    --
  BEGIN         
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpocorrencia  => pr_ind_tipo_log, 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_tpexecucao    => pr_tpexecucao,
                           pr_cdcriticidade => pr_cdcriticidade,
                           pr_cdmensagem    => pr_cdmensagem,    
                           pr_dsmensagem    => pr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => pr_nmarqlog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_gera_log;
  --
  
  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_verifica_rep_assinatura (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta do Associado
                                       ,pr_idseqttl IN crapttl.idseqttl%type  --Titularidade do Associado
                                       ,pr_cdorigem IN INTEGER                --Codigo Origem
                                       ,pr_idastcjt OUT crapass.idastcjt%TYPE --Codigo 1 exige Ass. Conj.
                                       ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE --CPF do Rep. Legal
                                       ,pr_nmprimtl OUT crapass.nmprimtl%TYPE --Nome do Rep. Legal          
                                       ,pr_flcartma OUT INTEGER               --Cartao Magnetico conjunta, 0 nao, 1 sim
                                       ,pr_cdcritic OUT INTEGER      --Codigo do erro
                                       ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_representante_assinatura
  --  Sistema  : Procedimentos para verificar o representando da assinatura
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar o representando da assinatura
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nmprintl crapass.nmprimtl%TYPE;
      vr_idastcjt crapass.idastcjt%TYPE;
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
      vr_dtvalida crapavt.dtvalida%TYPE;
      
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      
      
      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.idastcjt
              ,crapass.nmprimtl
              ,crapass.nrcpfppt
         FROM  crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                        ,pr_nrdconta IN crapsnh.nrdconta%type
                        ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
        SELECT crapsnh.nrcpfcgc
        FROM   crapsnh
        WHERE  crapsnh.cdcooper = pr_cdcooper
        AND    crapsnh.nrdconta = pr_nrdconta
        AND    crapsnh.idseqttl = pr_idseqttl
        AND    crapsnh.tpdsenha = 1; --Internet
      
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
        SELECT crapavt.nrdctato,
               crapavt.nmdavali,
               crapavt.dtvalida
        FROM   crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper
        AND    crapavt.nrdconta = pr_nrdconta
        AND    crapavt.nrcpfcgc = pr_nrcpfcgc
        AND    crapavt.tpctrato = 6; -- Juridico
      
      /* Busca se preposto do cartao magnetico eh responsavel pelo assinatura conjunta */
      CURSOR cr_crappod(pr_cdcooper IN crappod.cdcooper%TYPE
                       ,pr_nrdconta IN crappod.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crappod.nrcpfpro%TYPE) IS
        SELECT crappod.nrdconta 
        FROM   crappod 
        WHERE  crappod.cdcooper = pr_cdcooper
        AND    crappod.nrdconta = pr_nrdconta
        AND    crappod.nrcpfpro = pr_nrcpfcgc
        AND    crappod.cddpoder = 10
        AND    crappod.flgconju = 1;
      
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      pr_flcartma:= 0;
      
      --Consulta se exige assinatura multipla na conta principal
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO pr_idastcjt --parametro de interesse
                           ,vr_nmprintl
                           ,pr_nrcpfcgc;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro do cooperado nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      
      IF NVL(pr_cdorigem,0) NOT IN (4,6) THEN
          pr_nrcpfcgc := 0;      
      
		  IF (pr_idastcjt = 1 AND pr_idseqttl > 1) OR 
			 (pr_idastcjt = 0) THEN 

			 --Consulta do cpf do representante na crapsnh
			 OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
							,pr_nrdconta => pr_nrdconta
							,pr_idseqttl => pr_idseqttl);
			 FETCH cr_crapsnh INTO pr_nrcpfcgc;
			 --Se nao encontrou 
			 IF cr_crapsnh%NOTFOUND THEN
				--Fechar Cursor
				CLOSE cr_crapsnh;
				vr_cdcritic:= 0;
				vr_dscritic:= 'Registro de senha nao encontrado.';
				--Levantar Excecao
				RAISE vr_exc_erro;
      END IF;
			 --Fechar Cursor
			 CLOSE cr_crapsnh;
		  END IF;
      END IF;
	  
      IF pr_nrcpfcgc > 0 THEN
        --Consulta do nome
        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_crapavt INTO vr_nrdconta
                             ,pr_nmprimtl
                             ,vr_dtvalida;
        --Se nao encontrou 
        IF cr_crapavt%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapavt;
            vr_cdcritic:= 1124;
            vr_dscritic:= GENE0001.fn_busca_critica(vr_cdcritic);
            --Levantar Excecao
            RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapavt;      
        
        --Se tiver conta, busca nome da crapass
        IF  vr_nrdconta > 0 THEN
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
            FETCH cr_crapass INTO vr_idastcjt
                                 ,pr_nmprimtl
                                 ,vr_nrcpfcgc;
            --Se nao encontrou 
            IF cr_crapass%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapass;
                vr_cdcritic:= 9;
                vr_dscritic:= GENE0001.fn_busca_critica(vr_cdcritic);
                --Levantar Excecao
                RAISE vr_exc_erro;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapass;
        END IF;
        
        --Se for origem TAA, verificar preposto do cartao magnetico 
        IF pr_cdorigem = 4 THEN
			     OPEN cr_crappod(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrcpfcgc => pr_nrcpfcgc);
           FETCH cr_crappod INTO vr_nrdconta;
           --Se encontrou 
           IF cr_crappod%FOUND THEN
                --Atribui flga de cartao mag.
                pr_flcartma := 1;
                --Fechar Cursor
                CLOSE cr_crappod;
                --Verifica validade da atividade do representante
                IF vr_dtvalida < SYSDATE THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
                   RAISE vr_exc_erro;
                END IF;
           ELSE
                --Fechar Cursor
                CLOSE cr_crappod;
           END IF;
        END IF;
           
      END IF; --IF pr_nrcpfcgc > 0 
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         
         pr_cdcritic:= NVL(vr_cdcritic,0);

         IF NVL(pr_cdcritic,0) > 0 THEN
           pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic); 
         ELSE  
           pr_dscritic:= vr_dscritic;
         END IF;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
    END;
  END pc_verifica_rep_assinatura;
  
  PROCEDURE pc_inicia_senha_ass_conj(pr_cdcooper IN crappod.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_nrdconta IN crappod.nrdconta%TYPE -- Numero da conta
                                    ,pr_nrcpfpro IN crappod.nrcpfpro%TYPE -- Numero do CPF do Procurador
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operador
                                    ,pr_cdcritic   OUT INTEGER            -- Codigo do erro
                                    ,pr_dscritic   OUT VARCHAR2) IS       -- Descricao do erro

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_inicia_senha_ass_conj           Antigo:
  --  Sistema  : Procedimentos para inicializar o registro de senha de acesso à Internet
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Novembro/2015.                   Ultima atualizacao: 24/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Chamada para ser utilizada no Progress -
  --             Procedure para para inicializar o registro de senha de acesso à Internet
  --
  -- Alteracoes:
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  -------------------------> CURSORES <-------------------------
  BEGIN
  DECLARE  
  -- Selecionar senhas
  CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                    ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                    ,pr_nrcpfpro IN crapsnh.nrcpfcgc%TYPE) IS
    SELECT crapsnh.idseqttl
      FROM crapsnh
     WHERE crapsnh.cdcooper = pr_cdcooper AND
           crapsnh.nrdconta = pr_nrdconta AND
           crapsnh.tpdsenha = 1 /* INTERNET */  AND
           crapsnh.nrcpfcgc = pr_nrcpfpro;

  rw_crapsnh cr_crapsnh%ROWTYPE;

  -- Selecionar maximo idseqttl de senhas
  CURSOR cr_crapsnh_max(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS

    SELECT /*+index_desc (crapsnh CRAPSNH##CRAPSNH1)*/ 
           crapsnh.idseqttl
          ,ROWID 
      FROM crapsnh
      WHERE crapsnh.cdcooper = pr_cdcooper
        AND crapsnh.nrdconta = pr_nrdconta
        AND crapsnh.tpdsenha = pr_tpdsenha;

  rw_crapsnh_max cr_crapsnh_max%ROWTYPE;
  
  -------------------------> VARIAVEIS <-------------------------    
  
    vr_cdcritic crapcri.cdcritic%TYPE;  
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;
    vr_idseqttl crapsnh.idseqttl%TYPE;

  BEGIN

    OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta 
                   ,pr_nrcpfpro => pr_nrcpfpro);
    
    FETCH cr_crapsnh INTO rw_crapsnh;

    --Se nao encontrou
    IF cr_crapsnh%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_crapsnh;

      OPEN cr_crapsnh_max(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta 
                         ,pr_tpdsenha => 1);

      FETCH cr_crapsnh_max INTO rw_crapsnh_max;

      IF cr_crapsnh_max%NOTFOUND OR NVL(rw_crapsnh_max.idseqttl,0) = 0 THEN        
        -- Iniciar com sequência 2(idseqttl) devido ao registro de letras de cartão magnético
        vr_idseqttl := 2;
      ELSE
        vr_idseqttl := rw_crapsnh_max.idseqttl + 1;
      END IF;

      -- Fecha cursor
      CLOSE cr_crapsnh_max;

      BEGIN
        INSERT INTO
          crapsnh(
               cdcooper
              ,nrdconta
              ,tpdsenha
              ,idseqttl
              ,cdsitsnh
              ,cdoperad
              ,nrcpfcgc)
             VALUES(
               pr_cdcooper
              ,pr_nrdconta
              ,1
              ,vr_idseqttl
              ,0
              ,pr_cdoperad
              ,pr_nrcpfpro);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro de senha(CRAPSNH). Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapsnh;  
    END IF;

   EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := NVL(vr_cdcritic,0);

      IF NVL(pr_cdcritic,0) > 0 THEN    
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em PC_INICIA_SENHA_ASS_CONJ. Erro: ' || SQLERRM;
   END;         
  END pc_inicia_senha_ass_conj; 

  PROCEDURE pc_verifica_validade_procurac(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Nr. da Conta
                                         ,pr_inpessoa IN crapass.inpessoa%TYPE  -- PF/PJ
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencia do titular
                                         ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  -- Nr. CPF/CNPJ
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cód. Crítica
                                         ,pr_dscritic OUT VARCHAR2) IS          -- Descrição da crítica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_validade_procurac
  --  Sistema  : INET0002
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar a validade da procuração
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
	BEGIN
  DECLARE
	
  vr_qtmespro NUMBER;
	vr_dsdmensg VARCHAR2(32000) := ' ';
	
	-- Tratamento de críticas
	vr_dscritic crapcri.dscritic%TYPE;
	vr_cdcritic crapcri.cdcritic%type;
	vr_exc_saida EXCEPTION;	
	
  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;
	
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;
	
    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 7;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 3;
	
	CURSOR cr_crapavt IS
    SELECT avt.idmsgvct
		      ,avt.dtvalida
					,avt.ROWID
		  FROM crapavt avt
		 WHERE avt.cdcooper = pr_cdcooper
		   AND avt.nrdconta = pr_nrdconta
			 AND avt.tpctrato = 6
			 AND avt.nrcpfcgc = pr_nrcpfcgc;
	rw_crapavt cr_crapavt%ROWTYPE;
	
	-- Busca nome do titular
	CURSOR cr_crapass IS
	  SELECT ass.nmprimtl
		  FROM crapass ass
		 WHERE ass.cdcooper = pr_cdcooper
		   AND ass.nrdconta = pr_nrdconta;
	rw_crapass cr_crapass%ROWTYPE;
	
	-- Buscar nome da cooperativa
	CURSOR cr_crapcop IS
	  SELECT cop.nmrescop
		  FROM crapcop cop
		 WHERE cop.cdcooper = pr_cdcooper;
	rw_crapcop cr_crapcop%ROWTYPE;
  BEGIN		   	             			 
		
	  -- Leitura do calendário da cooperativa
		OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat
		INTO rw_crapdat;
		-- Se não encontrar
		IF btch0001.cr_crapdat%NOTFOUND THEN
			-- Fechar o cursor pois efetuaremos raise
			CLOSE btch0001.cr_crapdat;
			-- Montar mensagem de critica
			vr_cdcritic := 1;
			RAISE vr_exc_saida;
		ELSE
			-- Apenas fechar o cursor
			CLOSE btch0001.cr_crapdat;
		END IF;
	
		-- Busca parametro de quantidade de meses para o vencimento da procuração
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'LIMINTERNT'
                                             ,pr_tpregist => pr_inpessoa);       
                                             
    vr_qtmespro := gene0002.fn_busca_entrada(pr_postext => 29
    																		    ,pr_dstext => vr_dstextab
																		        ,pr_delimitador => ';');  				

		-- Busca representante
		OPEN cr_crapavt;
		FETCH cr_crapavt INTO rw_crapavt;
				
		IF cr_crapavt%FOUND THEN
      CLOSE cr_crapavt;
			-- Verifica se a mensagem ainda não foi gerada
			IF rw_crapavt.idmsgvct = 0 THEN
				-- Se a procuração vencerá
				IF rw_crapdat.dtmvtolt > add_months(rw_crapavt.dtvalida, - vr_qtmespro) THEN
						   
					 OPEN cr_crapass;
					 FETCH cr_crapass INTO rw_crapass;		 
           CLOSE cr_crapass;

					 OPEN cr_crapcop;
					 FETCH cr_crapcop INTO rw_crapcop;
					 CLOSE cr_crapcop;
	
					 vr_dsdmensg := 'Atenção, ' || TO_CHAR(rw_crapass.nmprimtl) || '!'  ||
													'<br><br>Informamos que sua atividade como sócio(a) ou procuração possui data de '  ||
													'vencimento para <b>' || to_char(rw_crapavt.dtvalida, 'dd/mm/rrrr') || '</b>.<br><br>' ||
													'A partir do vencimento as operações que exigem assinatura eletrônica '     ||
													'serão bloqueadas.';
					 -- Gerar mensagem
					 gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
																		 ,pr_nrdconta => pr_nrdconta
																		 ,pr_idseqttl => pr_idseqttl
																		 ,pr_cdprogra => 'INET0002'
																		 ,pr_inpriori => 0
																		 ,pr_dsdmensg => vr_dsdmensg
																		 ,pr_dsdassun => 'Vencimento Representação/Procuração'
																		 ,pr_dsdremet => rw_crapcop.nmrescop
																		 ,pr_dsdplchv => 'Vencimento Procuração'
																		 ,pr_cdoperad => 1
																		 ,pr_cdcadmsg => 0
																		 ,pr_dscritic => vr_dscritic);
																				 
						IF vr_dscritic IS NOT NULL THEN
							RAISE vr_exc_saida;
              CLOSE cr_crapavt;
						END IF;
				      
           vr_variaveis_notif('#dtvalida') := to_char(rw_crapavt.dtvalida, 'dd/mm/rrrr');

           -- Cria uma notificação
           noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                       ,pr_cdmotivo_mensagem => vr_notif_motivo
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl 
                                       ,pr_variaveis => vr_variaveis_notif);             
            
           --
				      
					 -- Indicar que mensagem já foi gerada
					 UPDATE crapavt
             SET crapavt.idmsgvct = 1
					   WHERE crapavt.rowid = rw_crapavt.rowid;							 
				END IF;
		  END IF;
    ELSE
      CLOSE cr_crapavt;  
		END IF;	 
		
		COMMIT;
	
	 EXCEPTION
		WHEN vr_exc_saida THEN

      pr_cdcritic := NVL(vr_cdcritic,0);

			IF NVL(pr_cdcritic,0) > 0 THEN
   	    pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
			ELSE
			  pr_dscritic := vr_dscritic;
		  END IF;

		WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em PC_VERIFICA_VALIDADE_PROCURAC. Erro: ' || SQLERRM;
   END;
	END pc_verifica_validade_procurac;

  /* Procedure para excluir transacoes pendentes */
  PROCEDURE pc_exclui_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                 ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                 ,pr_cdagenci IN INTEGER                --Numero da agencia
                                 ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                 ,pr_dtmvtolt IN DATE                   --Data da operacao
                                 ,pr_cdorigem IN INTEGER                --Codigo Origem
                                 ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                 ,pr_cdditens IN VARCHAR2               --Itens
                                 ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                 ,pr_flgerlog IN INTEGER                --Flag de log
                                 ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                 ,pr_dscritic OUT VARCHAR2) IS          --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_exclui_trans_pend
  --  Sistema  : Procedimentos para excluir transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para excluir transacoes pendentes
  --
  -- Alteração : 19/05/2017 - Inclusão de tratativa para quando for tipo 13 - Recarga de celular
  --                          pois o controle é feito pela tbrecarga_trans_pend. Projeto 321. (Lombardi)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_dsorigem VARCHAR2(50);
      vr_dstransa VARCHAR2(100);
      vr_idastcjt NUMBER;
      vr_nrcpfcgc NUMBER(14);
      vr_nrdctato crapavt.nrdctato%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_cddoitem tbgen_trans_pend.cdtransacao_pendente%TYPE;
      -- Array para guardar o split dos dados contidos na dstextab
      vr_cdditens gene0002.typ_split;
      vr_auxditem gene0002.typ_split;
      -- Rowid tabela de log
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
  
      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.idastcjt,
               crapass.nmprimtl
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                        ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
        SELECT crapsnh.nrcpfcgc
        FROM   crapsnh
        WHERE  crapsnh.cdcooper = pr_cdcooper
        AND    crapsnh.nrdconta = pr_nrdconta
        AND    crapsnh.idseqttl = 1
        AND    crapsnh.tpdsenha = 1; --Internet
              
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                       ,pr_nrdconta IN crapavt.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
        SELECT crapavt.nrdctato,
               crapavt.nmdavali
        FROM   crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper
        AND    crapavt.nrdconta = pr_nrdconta
        AND    crapavt.nrcpfcgc = pr_nrcpfcgc
        AND    crapavt.tpctrato = 6; -- Juridico
      
      CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT tbgen_trans_pend.nrcpf_operador,
               tbgen_trans_pend.idsituacao_transacao,
               tbgen_trans_pend.cdtransacao_pendente,
               tbgen_trans_pend.tptransacao
        FROM   tbgen_trans_pend 
        WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
      
      CURSOR cr_tbrecarga_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT tbrecarga_trans_pend.idoperacao
          FROM tbrecarga_trans_pend
         WHERE tbrecarga_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbrecarga_trans_pend cr_tbrecarga_trans_pend%ROWTYPE;
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      
      IF pr_flgerlog = 1 THEN
        -- Buscar a origem
        vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_cdorigem);
        -- Buscar Transacao
        vr_dstransa:= 'Excluir transacoes de operadores de conta.';
      END IF;
      
      /* Dados da conta */
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_cdcritic:= 9;
          vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
          --Fechar Cursor
          CLOSE cr_crapass;
      END IF;
      
      --Se conta nao exige assinatura multipla
      IF vr_idastcjt = 0 THEN
         --Consulta do cpf do representante na crapsnh
         OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapsnh INTO vr_nrcpfcgc;
         --Se nao encontrou 
         IF cr_crapsnh%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapsnh;
             vr_cdcritic:= 1125;
             vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Levantar Excecao
             RAISE vr_exc_erro;
         ELSE
             --Fechar Cursor
             CLOSE cr_crapsnh;
         END IF;  
      
         --Consulta do nome do Preposto
         OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcpfcgc => vr_nrcpfcgc);
         FETCH cr_crapavt INTO vr_nrdctato
                              ,vr_nmprimtl;
         --Se nao encontrou 
         IF cr_crapavt%NOTFOUND THEN
            --Fechar Cursor
              CLOSE cr_crapavt;
             vr_cdcritic:= 0;
             vr_dscritic:= 'Necessario habilitar um preposto.';
             --Levantar Excecao
             RAISE vr_exc_erro;
         ELSE                             
             --Fechar Cursor
             CLOSE cr_crapavt;      
         END IF;
      END IF;  
      
         
      vr_cdditens := GENE0002.fn_quebra_string(pr_string  => pr_cdditens, 
                                               pr_delimit => '/');
      
      FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                  pr_delimit => '|');
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                  pr_delimit => ',');
         vr_cddoitem := TO_NUMBER(vr_auxditem(3));
         OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
         FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;   
         
         IF cr_tbgen_trans_pend%FOUND THEN
            CLOSE cr_tbgen_trans_pend;
            -- Operador nao pode excluir transacao de outro operador.
            IF pr_nrcpfope > 0 AND rw_tbgen_trans_pend.nrcpf_operador <> pr_nrcpfope THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Transacao nao pode ser excluida pelo operador.';
               --Levantar Excecao
               RAISE vr_exc_erro;
            END IF;
			
			      IF rw_tbgen_trans_pend.idsituacao_transacao <> 1 THEN
			         vr_cdcritic:= 0;
               vr_dscritic:= 'Somente Transacoes pendentes podem ser excluidas.';
               --Levantar Excecao
               RAISE vr_exc_erro;
		        END IF;
            
            IF vr_nrdctato > 0 THEN
              OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_nrdctato);
              FETCH cr_crapass INTO vr_idastcjt,
                                    vr_nmprimtl;
              --Se nao encontrou 
              IF cr_crapass%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  vr_cdcritic:= 9;
                  vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              ELSE 
                  --Fechar Cursor
                  CLOSE cr_crapass;
              END IF;
            END IF;
            
            UPDATE tbgen_trans_pend SET 
                   tbgen_trans_pend.idsituacao_transacao = 3, /* Excluída */
                   tbgen_trans_pend.dtalteracao_situacao = trunc(SYSDATE)
             WHERE tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            
            /* Alimentar dados do preposto somente se ele efetuar a exclusao */
            IF  pr_nrcpfope = 0  THEN
                UPDATE tbgen_trans_pend SET 
                       tbgen_trans_pend.nrcpf_representante  = vr_nrcpfcgc
                 WHERE tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            END IF;
            
            IF rw_tbgen_trans_pend.tptransacao = 13 THEN
              
              OPEN cr_tbrecarga_trans_pend(pr_cddoitem => vr_cddoitem);
              FETCH cr_tbrecarga_trans_pend INTO  rw_tbrecarga_trans_pend;
              
              IF cr_tbrecarga_trans_pend%FOUND THEN
                
                CLOSE cr_tbrecarga_trans_pend;
                
                UPDATE tbrecarga_operacao
                   SET insit_operacao = 4 /* cancelada transação pendente */ 
                 WHERE idoperacao =  rw_tbrecarga_trans_pend.idoperacao;
              ELSE
                CLOSE cr_tbrecarga_trans_pend;
              END IF;
            END IF;
         ELSE
            CLOSE cr_tbgen_trans_pend;
         END IF;
      END LOOP;
      
      IF  pr_flgerlog = 1 THEN
          
          FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
              vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                       pr_delimit => '|');
              vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                       pr_delimit => ',');
              vr_cddoitem := TO_NUMBER(vr_auxditem(3));
              
              OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
              FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
              
              IF cr_tbgen_trans_pend%FOUND THEN
                CLOSE cr_tbgen_trans_pend;
                GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                                     ,pr_cdoperad => pr_cdoperad 
                                     ,pr_dscritic => ''         
                                     ,pr_dsorigem => vr_dsorigem
                                     ,pr_dstransa => vr_dstransa
                                     ,pr_dttransa => pr_dtmvtolt
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => gene0002.fn_busca_time
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
                               
                GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Codigo da Transacao Pendente', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( rw_tbgen_trans_pend.cdtransacao_pendente));
                
                IF vr_idastcjt = 0 THEN
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                            pr_nmdcampo => 'Nome do Preposto', 
                                            pr_dsdadant => '', 
                                            pr_dsdadatu => vr_nmprimtl);
                                            
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                            pr_nmdcampo => 'CPF do Preposto', 
                                            pr_dsdadant => '', 
                                            pr_dsdadatu => TO_CHAR( vr_nrcpfcgc));
                END IF;
              ELSE
                CLOSE cr_tbgen_trans_pend;                             
              END IF;
          END LOOP;
      END IF;
      
      COMMIT;
      
    EXCEPTION
       WHEN vr_exc_erro THEN

         pr_cdcritic:= NVL(vr_cdcritic,0);

         IF NVL(pr_cdcritic,0) > 0 THEN
           pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
         ELSE
           pr_dscritic:= vr_dscritic;
         END IF;
            
         ROLLBACK;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0002.pc_exclui_trans_pend. '||SQLERRM;
		     ROLLBACK;
    END;
  END pc_exclui_trans_pend;

  --> Rotina responsavel pela criacao de registros de aprovacao
  PROCEDURE pc_cria_aprova_transpend(pr_cdagenci    IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                    ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                    ,pr_nmdatela    IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                    ,pr_idorigem    IN INTEGER                                      --> Origem da solicitacao
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                    ,pr_cdcooper    IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                    ,pr_nrcpfrep    IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                    ,pr_dtmvtolt    IN DATE                                         --> Data do movimento     
                                    ,pr_cdtiptra    IN INTEGER                                      --> Codigo do tipo de transação    
                                    ,pr_cdtranpe    IN tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                    ,pr_tab_crapavt IN CADA0001.typ_tab_crapavt_58                  --> Tabela de procuradore
                                    ,pr_cdcritic  OUT INTEGER                                       --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2) IS                                  --> Descrição da crítica       

     /* .............................................................................

      Programa: pc_cria_aprova_transpend
      Sistema : Rotinas acessadas pelas telas de cadastros Web
      Sigla   : INET
      Autor   : Jean Michel
      Data    : Dezembro/2015.                  Ultima atualizacao: 22/12/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel pela criacao de registros de aprovacao.
      Observacao: -----

      Alteracoes:      
     ..............................................................................*/ 
     ----------------> CURSORES <-----------------
      -- Buscar nome da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
   
      CURSOR cr_crapass IS
      SELECT
        ass.idastcjt
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapsnh(pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
      SELECT
        snh.idseqttl
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.nrcpfcgc = pr_nrcpfcgc
         AND snh.tpdsenha = 1;
    
    rw_crapsnh cr_crapsnh%ROWTYPE;

     ----------------> VARIAVEIS <-----------------
     vr_exc_saida EXCEPTION;
     vr_cdcritic  crapcri.cdcritic%TYPE; -- Codigo de erro
     vr_dscritic  crapcri.dscritic%TYPE; -- Retorno de Erro
     vr_dsdmensg  VARCHAR2(4000);
	 vr_dsdmensg_notif  VARCHAR2(4000);
     vr_idsitapr  INTEGER; -- Situacao de Aprovacao
     vr_ind       INTEGER;

     -- Objetos para armazenar as variáveis da notificação
     vr_variaveis_notif NOTI0001.typ_variaveis_notif;
     vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 6;
     vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 1;      

   BEGIN

    --Dados da Cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    
    --Se nao encontrou 
    IF cr_crapcop%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapcop;   
       
       vr_cdcritic:= 794;
       vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapcop; 

    /*********/
    --Dados da Cooperativa
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    
    --Se nao encontrou 
    IF cr_crapass%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapass;   
       
       vr_cdcritic:= 9;
       vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapass;

    FOR vr_ind IN pr_tab_crapavt.FIRST..pr_tab_crapavt.LAST LOOP

      IF pr_tab_crapavt(vr_ind).idrspleg <> 1 THEN
        CONTINUE;
      END IF;

      vr_idsitapr := 1; -- PENDENTE  

      IF rw_crapass.idastcjt = 1 AND pr_nrcpfrep = pr_tab_crapavt(vr_ind).nrcpfcgc THEN
         vr_idsitapr := 2; -- APROVADA
      END IF;
   
      BEGIN
       UPDATE tbgen_aprova_trans_pend
         SET idsituacao_aprov = vr_idsitapr
       WHERE
             cdtransacao_pendente = pr_cdtranpe
         AND nrcpf_responsavel_aprov = pr_tab_crapavt(vr_ind).nrcpfcgc;

       IF SQL%ROWCOUNT = 0 THEN
         BEGIN
          INSERT INTO 
             tbgen_aprova_trans_pend(
                cdtransacao_pendente
               ,cdcooper
               ,nrdconta
               ,nrcpf_responsavel_aprov
               ,dtalteracao_situacao
               ,hralteracao_situacao
               ,idsituacao_aprov)
            VALUES(
                pr_cdtranpe
               ,pr_cdcooper
               ,pr_nrdconta
               ,pr_tab_crapavt(vr_ind).nrcpfcgc
               ,TRUNC(SYSDATE)
               ,GENE0002.fn_busca_time()
               ,vr_idsitapr);
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := '01 - Erro ao incluir registro na tabela TBGEN_APROVA_TRANS_PEND. Erro: ' || SQLERRM;
             RAISE vr_exc_saida;
         END;  
       END IF;   
      EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro de aprovacao TBGEN_APROVA_TRANS_PEND. Erro: ' || SQLERRM;
         RAISE vr_exc_saida; 
      END;     
 
      IF vr_idsitapr = 1 AND rw_crapass.idastcjt = 1 THEN
        pc_cria_msgs_trans (pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta   -- Conta do Associado
                           ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do caixa
                           ,pr_cdagenci => pr_cdagenci   -- Numero da agencia
                           ,pr_cdoperad => pr_cdoperad   -- Numero do operador
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data da operacao
                           ,pr_cdorigem => pr_idorigem   -- Codigo Origem
                           ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                           ,pr_cdtranpe => pr_cdtranpe   -- Codigo da Transacao Principal
                           ,pr_tptransa => pr_cdtiptra   -- Tipo de Transacao
                           ,pr_dsdmensg => vr_dsdmensg	 -- Descricao da mensagem
                           ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                           ,pr_dscritic => vr_dscritic); -- Descricao do erro
                  
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic is NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

		    vr_dsdmensg_notif := vr_dsdmensg;
        vr_dsdmensg := 'Atenção, ' || pr_tab_crapavt(vr_ind).nmdavali || '!<br><br>Informamos que a seguinte transação está pendente de aprovação:<br><br>' || vr_dsdmensg;

        --Sequencial do titular
        OPEN cr_crapsnh(pr_nrcpfcgc => pr_tab_crapavt(vr_ind).nrcpfcgc);
        FETCH cr_crapsnh INTO rw_crapsnh;
        
        --Se nao encontrou 
        IF cr_crapsnh%NOTFOUND THEN 
           --Fechar Cursor
           CLOSE cr_crapsnh;   
           
           vr_cdcritic:= 1125;
           vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Levantar Excecao
           RAISE vr_exc_saida;
        END IF;

        --Fechar Cursor
        CLOSE cr_crapsnh;

        -- Gerar mensagem
        gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => rw_crapsnh.idseqttl
                                  ,pr_cdprogra => pr_nmdatela
                                  ,pr_inpriori => 0
                                  ,pr_dsdmensg => vr_dsdmensg
                                  ,pr_dsdassun => 'Transação pendente'
                                  ,pr_dsdremet => rw_crapcop.nmrescop
                                  ,pr_dsdplchv => 'Transação pendente'
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdcadmsg => 0
                                  ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF; 
        --
        -- ews
        vr_variaveis_notif('#dsdmensg')     := vr_dsdmensg_notif;
                
        -- Cria uma notificação
        noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                    ,pr_cdmotivo_mensagem => vr_notif_motivo
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => rw_crapsnh.idseqttl
                                    ,pr_variaveis => vr_variaveis_notif);         
        --
      END IF;
    END LOOP; 	
     
   EXCEPTION
     WHEN vr_exc_saida THEN

       pr_cdcritic := NVL(vr_cdcritic,0);

       IF NVL(pr_cdcritic,0) > 0 THEN         
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
       ELSE      
         pr_dscritic := vr_dscritic;
       END IF;
         
       ROLLBACK;
     WHEN OTHERS THEN
       pr_dscritic := 'Erro no procedimento INET0002.pc_cria_aprova_transpend: ' || SQLERRM;      
       ROLLBACK;
   END pc_cria_aprova_transpend;

  -- Procedimentos para criaco de mensagens referente a Assinatura Conjunta
  PROCEDURE pc_cria_msgs_trans (pr_cdcooper  IN crapcop.cdcooper%TYPE                      -- Codigo Cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE                      -- Conta do Associado
                               ,pr_nrdcaixa  IN INTEGER                                    -- Numero do caixa
                               ,pr_cdagenci  IN INTEGER                                    -- Numero da agencia
                               ,pr_cdoperad  IN VARCHAR2                                   -- Numero do operador
                               ,pr_dtmvtolt  IN DATE                                       -- Data da operacao
                               ,pr_cdorigem  IN INTEGER                                    -- Codigo Origem
                               ,pr_nmdatela  IN VARCHAR2                                   -- Nome da tela
                               ,pr_cdtranpe  IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Codigo da Transacao Principal
                               ,pr_tptransa  IN INTEGER                                    -- Tipo de Transacao
                               ,pr_dsdmensg OUT VARCHAR2							                     -- Descricao da mensagem
                               ,pr_cdcritic OUT INTEGER                                    -- Codigo do erro
                               ,pr_dscritic OUT VARCHAR2) IS                               -- Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_msgs_trans
  --  Sistema  : Procedimentos para criaco de mensagens referente a Assinatura Conjunta
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 02/12/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para criar mensagens transacoes pendentes
  --
  -- Alteração : 25/02/2016 - Remover obrigatoriedade de crapcti nas TEDs (Marcos-Supero)
  --
  --             19/07/2016 - Inclusao da opcao de pagamento de DARF/DAS (Jean Michel)
  --
  --             02/12/2016 - Inclusao da opcao de desconto de cheque (Lombardi)
  --
  --             16/11/2016 - Inclusao do tipo de transacao 16 e 17 --> SMS Cobrança 
  --                          PRJ319-SMS Cobrança (Odirlei-AMcom)
  --             29/01/2018 - Incluir o tipo de transação 18 - Resgate de cheques
  --                          SM 454.1 Márcio Mouts  
  --
  --             12/03/2018 - (AmCom) - Add tptransa 21 - emprestimos/financiamentos
  --
  --             27/03/2019 - Ajustes para permitir criar as transações para o TED Judicial
  --                          Jose Dill - Mouts (P475 - REQ39)  
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Cursores
      
      -- Busca dos dados do associado 
      CURSOR cr_crapcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT crapcop.cdcooper
      FROM   crapcop
      WHERE  crapcop.cdagectl = pr_cdagectl;      

      -- Busca dos dados do associado 
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.idastcjt,
             crapass.nmprimtl
      FROM   crapass
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;      

      --Cursor (Pai) Transacoes Pendentes
      CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbgen_trans_pend.cdcooper
            ,tbgen_trans_pend.dtmvtolt
      FROM   tbgen_trans_pend 
      WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
  	    	  
      --Tipo Transacao 1,3,5 (Transferencia)
      CURSOR cr_tbtransf_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbtransf_trans_pend.cdagencia_coop_destino 
            ,tbtransf_trans_pend.nrconta_destino
            ,tbtransf_trans_pend.idagendamento
            ,tbtransf_trans_pend.vltransferencia
            ,tbtransf_trans_pend.dtdebito
      FROM   tbtransf_trans_pend 
      WHERE  tbtransf_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbtransf_trans_pend cr_tbtransf_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 2 (Pagamento)
      CURSOR cr_tbpagto_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_trans_pend.tppagamento
            ,tbpagto_trans_pend.dscedente
            ,tbpagto_trans_pend.idagendamento
            ,tbpagto_trans_pend.vlpagamento
            ,tbpagto_trans_pend.dtdebito
      FROM   tbpagto_trans_pend 
      WHERE  tbpagto_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbpagto_trans_pend cr_tbpagto_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 4 (TED)
      CURSOR cr_tbspb_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbspb_trans_pend.cdcooper 
            ,tbspb_trans_pend.nrdconta
            ,tbspb_trans_pend.cdbanco_favorecido
            ,tbspb_trans_pend.cdagencia_favorecido
            ,tbspb_trans_pend.nrconta_favorecido
            ,tbspb_trans_pend.dtdebito
            ,tbspb_trans_pend.vlted
            ,tbspb_trans_pend.nmtitula_favorecido
            ,tbspb_trans_pend.idagendamento
      FROM   tbspb_trans_pend 
      WHERE  tbspb_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbspb_trans_pend cr_tbspb_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 6 (Credito Pre-Aprovado)
      CURSOR cr_tbepr_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbepr_trans_pend.cdcooper
            ,tbepr_trans_pend.vlemprestimo
            ,tbepr_trans_pend.dtprimeiro_vencto
      FROM   tbepr_trans_pend 
      WHERE  tbepr_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbepr_trans_pend cr_tbepr_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 7 (Aplicacao)
      CURSOR cr_tbcapt_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbcapt_trans_pend.tpoperacao
            ,tbcapt_trans_pend.tpaplicacao
            ,tbcapt_trans_pend.nraplicacao
            ,tbcapt_trans_pend.vlresgate
            ,tbcapt_trans_pend.dtinicio_agendamento
            ,tbcapt_trans_pend.nrdia_agendamento
            ,tbcapt_trans_pend.qtmeses_agendamento
            ,tbcapt_trans_pend.nrdocto_agendamento
            ,tbcapt_trans_pend.tpagendamento
            ,tbcapt_trans_pend.idperiodo_agendamento
            ,tbcapt_trans_pend.tpresgate
      FROM   tbcapt_trans_pend 
      WHERE  tbcapt_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbcapt_trans_pend cr_tbcapt_trans_pend%ROWTYPE;
  	
      --Tipo Transacao 8 (Debito Automatico)
      CURSOR cr_tbconv_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbconv_trans_pend.cdcooper
            ,tbconv_trans_pend.tpoperacao
            ,tbconv_trans_pend.cdsegmento_conven
            ,tbconv_trans_pend.cdconven
            ,tbconv_trans_pend.cdhist_convenio
            ,tbconv_trans_pend.nrdocumento_fatura
            ,tbconv_trans_pend.dtdebito_fatura
      FROM   tbconv_trans_pend 
      WHERE  tbconv_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbconv_trans_pend cr_tbconv_trans_pend%ROWTYPE;
      	  
      --Tipo Transacao 9 (Folha de Pagamento)
      CURSOR cr_tbfolha_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbfolha_trans_pend.vlfolha
            ,tbfolha_trans_pend.dtdebito
      FROM   tbfolha_trans_pend 
      WHERE  tbfolha_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbfolha_trans_pend cr_tbfolha_trans_pend%ROWTYPE;
      
      --Tipo Transacao 11 (DARF/DAS)
      CURSOR cr_tbpagto_darf_das_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_darf_das_trans_pend.tppagamento
            ,tbpagto_darf_das_trans_pend.dsidentif_pagto
            ,tbpagto_darf_das_trans_pend.idagendamento
            ,tbpagto_darf_das_trans_pend.dtdebito
            ,tbpagto_darf_das_trans_pend.vlpagamento
      FROM   tbpagto_darf_das_trans_pend
      WHERE  tbpagto_darf_das_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbpagto_darf_das_trans_pend cr_tbpagto_darf_das_trans_pend%ROWTYPE;
			
      --Tipo Transacao 14/15 - FGTS/DAE
      CURSOR cr_tbtrib_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT trib.tppagamento
            ,trib.dsidenti_pagto
            ,trib.idagendamento
            ,trib.dtdebito
            ,trib.vlpagamento
      FROM   tbpagto_tributos_trans_pend trib
      WHERE  trib.cdtransacao_pendente = pr_cddoitem;
      rw_tbtrib_trans_pend cr_tbtrib_trans_pend%ROWTYPE;
      
      --Tipo Transacao 12 (Desconto de Cheque)
      CURSOR cr_tbdscc_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT SUM(dscc.vlcheque) vltotchq
              ,COUNT(1) qtcheque
          FROM tbdscc_trans_pend dscc
         WHERE dscc.cdtransacao_pendente = pr_cddoitem
         GROUP BY dscc.cdtransacao_pendente;
      rw_tbdscc_trans_pend cr_tbdscc_trans_pend%ROWTYPE;

			--Tipo transacao 13 (Recarga de celular)
			CURSOR cr_tbrecarga_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tope.nrddd
			      ,tope.nrcelular
						,tope.dtrecarga
						,tope.vlrecarga
						,trec.tprecarga
			  FROM tbrecarga_trans_pend trec
				    ,tbrecarga_operacao tope
			 WHERE trec.cdtransacao_pendente = pr_cddoitem
			   AND tope.idoperacao = trec.idoperacao;
      rw_tbrecarga_trans_pend cr_tbrecarga_trans_pend%ROWTYPE;

      --Cadastro de Transferencias pela Internet.
      CURSOR cr_crapcti( pr_cdcooper IN crapcti.cdcooper%TYPE,
                         pr_nrdconta IN crapcti.nrdconta%TYPE,
                         pr_cddbanco IN crapcti.cddbanco%TYPE,
                         pr_cdageban IN crapcti.cdageban%TYPE,
                         pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS  
      SELECT crapcti.nmtitula 
      FROM   crapcti
      WHERE  crapcti.cdcooper = pr_cdcooper
      AND    crapcti.nrdconta = pr_nrdconta
      AND	   crapcti.cddbanco = pr_cddbanco
      AND	   crapcti.cdageban = pr_cdageban 
      AND	   crapcti.nrctatrf = pr_nrctatrf;

      --Cadastro de convenios.
      CURSOR cr_crapcon( pr_cdcooper IN crapcon.cdcooper%TYPE,
                         pr_cdsegmto IN crapcon.cdsegmto%TYPE,
                         pr_cdempcon IN crapcon.cdempcon%TYPE) IS
      SELECT crapcon.nmrescon 
      FROM   crapcon
      WHERE  crapcon.cdcooper = pr_cdcooper 
      AND    crapcon.cdsegmto = pr_cdsegmto 
      AND    crapcon.cdempcon = pr_cdempcon;

      -- Consulta autorizacao de debitos
      CURSOR cr_autodeb(pr_cdcooper IN crapatr.cdcooper%TYPE,
                       pr_nrdconta IN crapatr.nrdconta%TYPE,
                       pr_cdhistor IN crapatr.cdhistor%TYPE,
                       pr_cdrefere IN crapatr.cdrefere%TYPE,
                       pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
        SELECT crapcon.nmrescon, craplau.vllanaut 
        FROM   crapatr, crapcon, craplau
        WHERE  crapatr.cdcooper = pr_cdcooper 
        AND    crapatr.nrdconta = pr_nrdconta 
        AND    crapatr.cdhistor = pr_cdhistor 
        AND    crapatr.cdrefere = pr_cdrefere
        --AND    crapatr.tpautori <> 0 
        AND    crapcon.cdcooper(+) = crapatr.cdcooper 
        AND    crapcon.cdsegmto(+) = crapatr.cdsegmto 
        AND    crapcon.cdempcon(+) = crapatr.cdempcon 
        AND    craplau.cdcooper = crapatr.cdcooper 
        AND    craplau.nrdconta = crapatr.nrdconta 
        AND    craplau.cdhistor = crapatr.cdhistor 
        AND    craplau.nrdocmto = crapatr.cdrefere 
        AND    craplau.dtmvtopg = pr_dtmvtopg
        AND    craplau.insitlau = 1;
				
			-- Cursor para buscar a transação de adesão de pacote de tarifa pendente
			CURSOR cr_pactar IS
			  SELECT tpend.cdpacote
				      ,tpac.dspacote
				  FROM tbtarif_pacote_trans_pend tpend
					    ,tbtarif_pacotes tpac
				 WHERE tpend.cdtransacao_pendente = pr_cdtranpe			
				   AND tpac.cdpacote = tpend.cdpacote;
			rw_pactar cr_pactar%ROWTYPE;

-- Início SM 454.1      
      --Tipo Transacao 18 (Resgate de Cheque)
      CURSOR cr_tbcst_trans_pend_det(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT SUM(c.vlcheque) vltotchq
              ,COUNT(1) qtcheque
          FROM tbcst_trans_pend_det dscc,
               crapcst c
         WHERE dscc.cdtransacao_pendente = pr_cddoitem
           and dscc.idcustodia = c.idcustod
         GROUP BY dscc.cdtransacao_pendente;
      rw_tbcst_trans_pend_det cr_tbcst_trans_pend_det%ROWTYPE;
-- Fim SM 454.1      

      --Tipo Transacao 19 (Borderô Desconto de Titulo)
      CURSOR cr_tbdsct_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT SUM(dsct.vltitulo) vltotbdt
              ,COUNT(1) qttitulo
          FROM tbdsct_trans_pend dsct
         WHERE dsct.cdtransacao_pendente = pr_cddoitem
         GROUP BY dsct.cdtransacao_pendente;
      rw_tbdsct_trans_pend cr_tbdsct_trans_pend%ROWTYPE;

      --Tipo Transacao 20 (Autorizacao de contratos por senha)
      CURSOR cr_tbctd_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT *
        FROM tbctd_trans_pend trec
        WHERE trec.cdtransacao_pendente = pr_cddoitem;
      
      rw_tbctd_trans_pend cr_tbctd_trans_pend%ROWTYPE;
   
      --Tipo Transacao 21 (Emprestimos/Financiamentos)
      CURSOR cr_pend_efet_proposta( pr_cddoitem IN tbepr_trans_pend_efet_proposta.cdtransacao_pendente%TYPE) IS  
      SELECT pep.cdcooper
            ,pep.nrctremp 
            ,wepr.vlemprst           
      FROM   tbepr_trans_pend_efet_proposta pep,
             crawepr wepr
      WHERE  pep.cdtransacao_pendente = pr_cddoitem
        AND  pep.cdcooper = wepr.cdcooper
        AND  pep.nrdconta = wepr.nrdconta
        AND  pep.nrctremp = wepr.nrctremp;
      --/
      rw_pend_efet_proposta cr_pend_efet_proposta%ROWTYPE;
      --

      --Variaveis Locais
      vr_idastcjt crapass.idastcjt%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_nmtitula crapass.nmprimtl%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;     
      vr_cdhistor craplot.cdhistor%TYPE;
      vr_nrindice NUMBER;
      vr_nmrescon crapcon.nmrescon%TYPE;
      vr_vllanaut craplau.vllanaut%TYPE;
      vr_tab_agen APLI0002.typ_tab_agen; 
      vr_tab_agen_det APLI0002.typ_tab_agen_det; 
      vr_dsdtefet VARCHAR2(20);
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_vlresgat VARCHAR2(100);      
      vr_saldo_rdca APLI0001.typ_tab_saldo_rdca; --Tabela para o saldo da aplicação
      vr_dstransa   VARCHAR2(80);


      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
  
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      
      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      
	    --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN 
         --Fechar Cursor
         CLOSE cr_crapass;   
         
         vr_cdcritic:= 9;
         vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Levantar Excecao
         RAISE vr_exc_erro;
      END IF;

      --Fechar Cursor
      CLOSE cr_crapass;
      
      OPEN cr_tbgen_trans_pend(pr_cddoitem => pr_cdtranpe);
      FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
                  
      IF cr_tbgen_trans_pend%NOTFOUND THEN
          CLOSE cr_tbgen_trans_pend;
          vr_cdcritic:= 1121;
          vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;      
      ELSE
          CLOSE cr_tbgen_trans_pend;
      END IF;
                          
			-- Tipos de transacoes
			CASE 
					WHEN pr_tptransa IN(1,3,5) THEN --Transferencia
							 OPEN cr_tbtransf_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbtransf_trans_pend INTO rw_tbtransf_trans_pend;
							 IF cr_tbtransf_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
								 CLOSE cr_tbtransf_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de ' || 
																(CASE WHEN pr_tptransa = 3 THEN 'Credito Salario' ELSE 'Transferencia' END) ||
																'pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbtransf_trans_pend;
							 END IF;
               
               OPEN cr_crapcop(pr_cdagectl => rw_tbtransf_trans_pend.cdagencia_coop_destino);
               FETCH cr_crapcop INTO vr_cdcooper;
                
               --Se nao encontrou 
               IF cr_crapcop%NOTFOUND THEN 
                  --Fechar Cursor
                  CLOSE cr_crapcop;   
                  
                  vr_cdcritic:= 1079;
                  vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  --Levantar Excecao
                  RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_crapcop;
               END IF;
               
               OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => rw_tbtransf_trans_pend.nrconta_destino);
               FETCH cr_crapass INTO rw_crapass;
               IF cr_crapass %NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  vr_cdcritic:= 1081;
                  vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  --Levantar Excecao
                  RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_crapass;
               END IF;
               
							 pr_dsdmensg := pr_dsdmensg || (CASE WHEN pr_tptransa = 3 THEN '<b>Crédito de Salário' ELSE '<b>Transferência' END) || '</b> para ';
               pr_dsdmensg := pr_dsdmensg || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.cdagencia_coop_destino,'0000') || '</b>';
               pr_dsdmensg := pr_dsdmensg || '|' || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.nrconta_destino) || '</b> - <b>';
   						 pr_dsdmensg := pr_dsdmensg || TO_CHAR(SUBSTR(rw_crapass.nmprimtl,1,20)) || '</b>';
							 pr_dsdmensg := pr_dsdmensg || (CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END);
							 pr_dsdmensg := pr_dsdmensg || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ';
 							 pr_dsdmensg := pr_dsdmensg || TO_CHAR(TO_CHAR(rw_tbtransf_trans_pend.vltransferencia),'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa = 2 THEN --Pagamento
							 OPEN cr_tbpagto_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
							 IF cr_tbpagto_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_trans_pend;      
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Pagamento pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbpagto_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg || 
															'<b>Pagamento de ' ||
															(CASE WHEN rw_tbpagto_trans_pend.tppagamento = 1 THEN 
                                      'Convênio' 
                                    WHEN rw_tbpagto_trans_pend.tppagamento = 2 THEN   
                                      'Título'
                                    ELSE 
                                      'GPS' END) || '</b> de ' ||
															'<b>' || rw_tbpagto_trans_pend.dscedente || '</b>' ||
															(CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END) ||
															'<b>' || TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ' ||
															TO_CHAR(rw_tbpagto_trans_pend.vlpagamento,'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa IN (4,22) THEN --TED E TED JUDICIAL --REQ39
							 OPEN cr_tbspb_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbspb_trans_pend INTO rw_tbspb_trans_pend;				
							IF cr_tbspb_trans_pend%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_tbspb_trans_pend;
								 vr_cdcritic:= 0;
								 vr_dscritic:= 'Registro de TED pendente nao encontrado.';
								 --Levantar Excecao
								 RAISE vr_exc_erro;
              ELSE
                 --Fechar Cursor
							   CLOSE cr_tbspb_trans_pend;
							END IF;
						  /*REQ39 - Não validar cadastro de transferência para TED Judicial */
              IF pr_tptransa <> 22 THEN
                OPEN cr_crapcti(pr_cdcooper => rw_tbspb_trans_pend.cdcooper,
                                pr_nrdconta => rw_tbspb_trans_pend.nrdconta,
                                pr_cddbanco => rw_tbspb_trans_pend.cdbanco_favorecido,
                                pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido,
                                pr_nrctatrf => rw_tbspb_trans_pend.nrconta_favorecido);
                FETCH cr_crapcti INTO vr_nmtitula;	
                IF cr_crapcti%NOTFOUND THEN
                   --Fechar Cursor
                   CLOSE cr_crapcti;

                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Registro de Cadastro de transferencias nao encontrado.';
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                ELSE
                   --Fechar Cursor
                   CLOSE cr_crapcti;
                END IF;
              END IF;

							pr_dsdmensg := pr_dsdmensg ||
														 '<b>TED</b> para <b>' ||
														 TO_CHAR(rw_tbspb_trans_pend.nrconta_favorecido) || ' - ' ||
														 SUBSTR(vr_nmtitula,1,20) || '</b> ' || 
                             (CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN
                                ' com débito em ' 
                              ELSE
                                ' agendado para ' END) ||
														 '<b>' || TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR') || 
                             '</b> no valor de <b>R$ ' ||
														 TO_CHAR(rw_tbspb_trans_pend.vlted,'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa = 6 THEN --Credito Pre-Aprovado
							 OPEN cr_tbepr_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbepr_trans_pend INTO rw_tbepr_trans_pend;
							 IF cr_tbepr_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbepr_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Credito Pre-Aprovado pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbepr_trans_pend;
							 END IF;
               
							 pr_dsdmensg := pr_dsdmensg ||
															'<b>Crédito Pré-Aprovado</b> no valor de <b>R$ ' ||
															TO_CHAR(rw_tbepr_trans_pend.vlemprestimo,'fm999g999g990d00') || '</b> com débito em <b>' ||
															TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR') || '</b>.<br>';
					
					WHEN pr_tptransa = 7 THEN --Aplicacao
							 OPEN cr_tbcapt_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbcapt_trans_pend INTO rw_tbcapt_trans_pend;
							 IF cr_tbcapt_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbcapt_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Aplicacao pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbcapt_trans_pend;
							 END IF;
	
							 CASE
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 1 THEN --Cancelamento Aplicacao
												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Cancelamento da Aplicação número <b>' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao) || '</b>.';

									 WHEN rw_tbcapt_trans_pend.tpoperacao = 2 THEN --Resgate
                        IF rw_tbcapt_trans_pend.tpresgate = 2 THEN
                           apli0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                                       ,pr_cdoperad => pr_cdoperad
                                                       ,pr_nmdatela => pr_nmdatela
                                                       ,pr_idorigem => pr_cdorigem
                                                       ,pr_nrdcaixa => pr_nrdcaixa
                                                       ,pr_nrdconta => pr_nrdconta
                                                       ,pr_idseqttl => 1
                                                       ,pr_cdagenci => pr_cdagenci
                                                       ,pr_cdprogra => pr_nmdatela
                                                       ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                       ,pr_cdprodut => 0
                                                       ,pr_dtmvtolt => pr_dtmvtolt 
                                                       ,pr_idconsul => 2 
                                                       ,pr_idgerlog => 0
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic
                                                       ,pr_saldo_rdca => vr_saldo_rdca);
                                                       
                           vr_nrindice := vr_saldo_rdca.FIRST; 
                          
                           WHILE vr_nrindice IS NOT NULL LOOP                                                          
                             vr_vlresgat := TO_CHAR(vr_saldo_rdca(vr_nrindice).sldresga,'fm999g999g990d00');
                             EXIT;
                           END LOOP;
                        ELSE
                           vr_vlresgat := TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00');
                        END IF;
                        
												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Resgate</b> no valor de <b>R$ ' || 
																			 vr_vlresgat || 
																			 '</b> da aplicacao numero <b>' ||
                                       TO_CHAR(rw_tbcapt_trans_pend.nraplicacao) || '</b> com credito em ' || 
																			 TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR') || '</b>.<br>';

									 WHEN rw_tbcapt_trans_pend.tpoperacao = 3 THEN --Agendamento Resgate

                        IF rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN
                           pr_dsdmensg := pr_dsdmensg || 'Resgate no valor de <b>R$ ' || TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') ||
                                          '</b> agendado para <b>' || TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR') || '</b>.';
                        ELSIF rw_tbcapt_trans_pend.idperiodo_agendamento = 1 THEN
                           vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                                             
                           IF (TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR')) <= pr_dtmvtolt THEN 
                              vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(ADD_MONTHS(pr_dtmvtolt,1),'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                           END IF;
                            
                           pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Resgate</b> no valor de <b>R$ ' || 
																			 TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') || 
																			 '</b> agendado para crédito no <b>dia ' ||
																			 TO_CHAR(rw_tbcapt_trans_pend.nrdia_agendamento,'00') || '</b> durante <b>' ||
																			 TO_CHAR(rw_tbcapt_trans_pend.qtmeses_agendamento,'99') || ' meses</b> ' ||
																			 'iniciando em <b>' || vr_dsdtefet || '</b>.<br>';

                        END IF;                        
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 4 THEN --Cancelamento Total Agendamento
												APLI0002.pc_consulta_agendamento(pr_cdcooper => pr_cdcooper
																												,pr_flgtipar => 2 -- Todos Agendamentos 
																												,pr_nrdconta => pr_nrdconta 
																												,pr_idseqttl => 0 -- Todos Titulares 
																												,pr_nrctraar => rw_tbcapt_trans_pend.nrdocto_agendamento 
                                                        ,pr_cdsitaar => 0
																												,pr_cdcritic => vr_cdcritic 
																												,pr_dscritic => vr_dscritic
																												,pr_tab_agen => vr_tab_agen);                      
			
												vr_nrindice := vr_tab_agen.FIRST;
                          
                        WHILE vr_nrindice IS NOT NULL LOOP
														--Aplicacao
														IF vr_tab_agen(vr_nrindice).flgtipar = 0 THEN
                               IF vr_tab_agen(vr_nrindice).flgtipin = 1 THEN -- Mensal
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendada para o <b>dia ' || 
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtdiaaar,'00') || '</b> durante <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).qtmesaar) || ' meses</b> iniciando em <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';	
                               ELSE -- Único
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendada para <b>dia ' ||                                                  
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';	
                               END IF;
														ELSE --Resgate
                               IF vr_tab_agen(vr_nrindice).flgtipin = 1 THEN -- Mensal
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendado para crédito no <b>dia ' || 
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtdiaaar,'00') || '</b> durante <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).qtmesaar) || ' meses</b> iniciando em <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';
                               ELSE -- Único
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendado para crédito em <b>' ||                                                   
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';                                 
                               END IF;
														END IF;
                          EXIT;
												END LOOP;
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 5 THEN --Cancelamento Item Agendamento
												--aplicacao
												IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
													 vr_nrdolote := 32001;
													 vr_cdhistor := 527;
												ELSE --resgate
													 vr_nrdolote := 32002;
													 vr_cdhistor := 530;
												END IF;
												
												APLI0002.pc_consulta_det_agendmto(pr_cdcooper => pr_cdcooper
																												 ,pr_nrdocmto => substr(to_char(rw_tbcapt_trans_pend.nrdocto_agendamento),6,10)
																												 ,pr_nrdolote => vr_nrdolote
																												 ,pr_nrdconta => pr_nrdconta
																												 ,pr_cdhistor => vr_cdhistor
																												 ,pr_cdcritic => vr_cdcritic
																												 ,pr_dscritic => vr_dscritic
																												 ,pr_tab_agen_det => vr_tab_agen_det);

												IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
													RAISE vr_exc_erro;
												END IF;			

												vr_nrindice := vr_tab_agen_det.FIRST;                        
                          
                        WHILE vr_nrindice IS NOT NULL LOOP
                          IF vr_tab_agen_det(vr_nrindice).nrdocmto <> rw_tbcapt_trans_pend.nrdocto_agendamento THEN
                             vr_nrindice := vr_tab_agen_det.NEXT(vr_nrindice);
                             CONTINUE;
                          END IF;
                             
                          --Aplicacao
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                             pr_dsdmensg := pr_dsdmensg ||
                                            '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' || 
                                            TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00') || 
                                            '</b> agendada para <b>' || TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR') || '</b>.<br>';
                          ELSE --Resgate
                             pr_dsdmensg := pr_dsdmensg || 
                                            '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' || 
                                            TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00') || 
                                            '</b> agendado para <b>' || TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR') || '</b>.<br>';
												  END IF;
                          EXIT;
                        END LOOP;

							 END CASE; -- END CASE
	
					WHEN pr_tptransa = 8 THEN --Debito Automatico
							 OPEN cr_tbconv_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbconv_trans_pend INTO rw_tbconv_trans_pend;
							 IF cr_tbconv_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbconv_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro Debito Automatico nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbconv_trans_pend;
							 END IF;
	
							 CASE 
									 WHEN rw_tbconv_trans_pend.tpoperacao = 1 THEN --Autorizacao Debito Automatico
												OPEN cr_crapcon(pr_cdcooper => pr_cdcooper,
																				pr_cdsegmto => rw_tbconv_trans_pend.cdsegmento_conven,
																				pr_cdempcon => rw_tbconv_trans_pend.cdconven);
												FETCH cr_crapcon INTO vr_nmrescon;
												
												IF cr_crapcon%NOTFOUND THEN
                           --Fechar Cursor
                           CLOSE cr_crapcon;

													 vr_cdcritic:= 558;
													 vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
													 --Levantar Excecao
													 RAISE vr_exc_erro;
												END IF;

                        --Fechar Cursor
												CLOSE cr_crapcon;

												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Autorização de Débito Automático</b> para faturas da <b>' || vr_nmrescon || '</b>.<br>';
									 WHEN rw_tbconv_trans_pend.tpoperacao = 2 OR   --Bloqueio Debito Automatico
												rw_tbconv_trans_pend.tpoperacao = 3 THEN --Desbloqueio Debito Automatico
												OPEN cr_autodeb(pr_cdcooper => pr_cdcooper,
																				pr_nrdconta => pr_nrdconta,
																				pr_cdhistor => rw_tbconv_trans_pend.cdhist_convenio,
																				pr_cdrefere => rw_tbconv_trans_pend.nrdocumento_fatura,
                                        pr_dtmvtopg => rw_tbconv_trans_pend.dtdebito_fatura);
												FETCH cr_autodeb INTO vr_nmrescon,
																							vr_vllanaut;
												
												IF cr_autodeb%NOTFOUND THEN
                           --Fechar Cursor
                           CLOSE cr_autodeb;

													 vr_cdcritic:= 0;
													 vr_dscritic:= 'Registro Bloqueio/Desbloqueio Debito Automatico nao encontrado.';
													 --Levantar Excecao
													 RAISE vr_exc_erro;
												END IF;

                        --Fechar Cursor
												CLOSE cr_autodeb;

												pr_dsdmensg := pr_dsdmensg ||
																			 (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN '<b>Bloqueio' ELSE '<b>Desbloqueio' END) ||
																			 '</b> de lançamento de <b>Débito Automático</b> da <b>' || vr_nmrescon || 
																			 '</b> no valor de <b>R$ ' || TO_CHAR(vr_vllanaut,'fm999g999g990d00') || 
																			 '</b> agendado para <b>' || 
																			 TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR') || '</b>.<br>';
							 END CASE; --End Case
					WHEN pr_tptransa = 9 THEN --Folha Pagamento
							 OPEN cr_tbfolha_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbfolha_trans_pend INTO rw_tbfolha_trans_pend; 
							 IF cr_tbfolha_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbfolha_trans_pend;
									vr_cdcritic:= 1122;
									vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => 1122);
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbfolha_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg ||
															'<b>Folha de Pagamento</b> no valor total de <b>R$ ' ||
															TO_CHAR(rw_tbfolha_trans_pend.vlfolha,'fm999g999g990d00') || 
															'</b> com débito programado para <b>' || 
															TO_CHAR(rw_tbfolha_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>.<br>';
          WHEN pr_tptransa = 10 THEN --Pacote de tarifas
						OPEN cr_pactar;
						FETCH cr_pactar INTO rw_pactar;
								 
						IF cr_pactar%NOTFOUND THEN
							-- Fecha cursor
							CLOSE cr_pactar;
							vr_cdcritic := 0;
							vr_dscritic := 'Registro de Adesao de servico nao encontrado.';
							-- Levantar exceção
							RAISE vr_exc_erro;
						ELSE
							-- Fecha cursor
							CLOSE cr_pactar;							
						END IF;
						pr_dsdmensg := pr_dsdmensg ||
													    '<b>Adesão do Serviço Cooperativo</b> ' ||
															TO_CHAR(rw_pactar.cdpacote,'fm999') || ' - ' ||
                              rw_pactar.dspacote || '.<br>';
						

          WHEN pr_tptransa = 11 THEN -- Pagamento DARF/DAS
							 OPEN cr_tbpagto_darf_das_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbpagto_darf_das_trans_pend INTO rw_tbpagto_darf_das_trans_pend;
							 IF cr_tbpagto_darf_das_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;      
									vr_cdcritic:= 1123;
									vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbpagto_darf_das_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg || 
															'<b>Pagamento de ' ||
															(CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 THEN 'DARF' ELSE 'DAS' END) || '</b>' ||
															(CASE WHEN TRIM(rw_tbpagto_darf_das_trans_pend.dsidentif_pagto) IS NOT NULL THEN
                               ' para ' || '<b>' || rw_tbpagto_darf_das_trans_pend.dsidentif_pagto || '</b>' ELSE '' END) ||
															(CASE WHEN rw_tbpagto_darf_das_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END) ||
															'<b>' || TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ' ||
															TO_CHAR(rw_tbpagto_darf_das_trans_pend.vlpagamento,'fm999g999g990d00') || '</b>.<br>';
             WHEN pr_tptransa = 12 THEN -- Desconto de Cheque
               OPEN cr_tbdscc_trans_pend (pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbdscc_trans_pend INTO rw_tbdscc_trans_pend;
			   IF cr_tbdscc_trans_pend%NOTFOUND THEN
						 --Fechar Cursor
                  CLOSE cr_tbdscc_trans_pend;      
						 vr_cdcritic:= 0;
				     vr_dscritic:= 'Registro de Desconto de Cheque pendente nao encontrado.';
						 --Levantar Excecao
						 RAISE vr_exc_erro;
				  ELSE
						 --Fechar Cursor
				  CLOSE cr_tbdscc_trans_pend;
				  END IF;
					pr_dsdmensg := pr_dsdmensg ||
			  				  '<b>Borderô de desconto</b> no valor total de <b>R$ ' ||
                              TO_CHAR(rw_tbdscc_trans_pend.vltotchq,'fm999g999g990d00') || 
                              '</b> com <b>' || rw_tbdscc_trans_pend.qtcheque || '</b> cheques.<br>';			
															
				WHEN pr_tptransa = 13 THEN -- Recarga de celular
					OPEN cr_tbrecarga_trans_pend(pr_cddoitem => pr_cdtranpe);
					FETCH cr_tbrecarga_trans_pend INTO rw_tbrecarga_trans_pend;
					
				  IF cr_tbrecarga_trans_pend%NOTFOUND THEN
						 --Fechar Cursor
						 CLOSE cr_tbrecarga_trans_pend;
						 vr_cdcritic:= 0;
						 vr_dscritic:= 'Registro de Recarga de Celular pendente nao encontrado.';
						 --Levantar Excecao
						 RAISE vr_exc_erro;
				  ELSE
						 --Fechar Cursor
						 CLOSE cr_tbrecarga_trans_pend;
				  END IF;
					pr_dsdmensg := pr_dsdmensg ||
											'<b>Recarga de celular</b> para <b>'||
											'(' || to_char(rw_tbrecarga_trans_pend.nrddd, 'fm00') || ')'|| 
											to_char(rw_tbrecarga_trans_pend.nrcelular, 'fm00000g0000','nls_numeric_characters=.-') || '</b> '|| 
											(CASE WHEN rw_tbrecarga_trans_pend.tprecarga = 1 THEN
											' em '
											ELSE
											' agendado para ' END) ||
											'<b>'||
											TO_CHAR(rw_tbrecarga_trans_pend.dtrecarga,'DD/MM/RRRR') ||
											'</b> no valor de <b>R$ '||
											TO_CHAR(rw_tbrecarga_trans_pend.vlrecarga,'fm9g999g990d00') || 
											'</b>.<br>';
											
			  WHEN pr_tptransa IN(14,15) THEN -- Pagamento FGTS/DAE
          
          --> definir descricao
          vr_dstransa := NULL;
          IF pr_tptransa = 14 THEN
            vr_dstransa := 'FGTS';
          ELSIF pr_tptransa = 15 THEN
            vr_dstransa := 'DAE';
          END IF;
          OPEN cr_tbtrib_trans_pend(pr_cddoitem => pr_cdtranpe);
          FETCH cr_tbtrib_trans_pend INTO rw_tbtrib_trans_pend;
          IF cr_tbtrib_trans_pend%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_tbtrib_trans_pend;      
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro de Pagamento de '||vr_dstransa||' pendente nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Fechar Cursor
            CLOSE cr_tbtrib_trans_pend;
          END IF;

          pr_dsdmensg := pr_dsdmensg || 
                        '<b>Pagamento de ' || vr_dstransa || '</b>' ||
                        (CASE WHEN TRIM(rw_tbtrib_trans_pend.dsidenti_pagto) IS NOT NULL THEN
                         ' para ' || '<b>' || rw_tbtrib_trans_pend.dsidenti_pagto || '</b>' ELSE '' END) ||
                        (CASE WHEN rw_tbtrib_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END) ||
                        '<b>' || TO_CHAR(rw_tbtrib_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ' ||
                        TO_CHAR(rw_tbtrib_trans_pend.vlpagamento,'fm999g999g990d00') || '</b>.<br>';
             
			  WHEN pr_tptransa = 16 THEN -- SMS cobrança          
          pr_dsdmensg := pr_dsdmensg || 'Adesão ao serviço de SMS de Cobrança';
        WHEN pr_tptransa = 17 THEN -- Cancelamento SMS cobrança          
          pr_dsdmensg := pr_dsdmensg || 'Cancelamento de serviço de SMS de Cobrança';  
-- Início SM 454.1      
        WHEN pr_tptransa = 18 THEN -- Resgate de cheque em custodia          
         OPEN cr_tbcst_trans_pend_det (pr_cddoitem => pr_cdtranpe);
 			   FETCH cr_tbcst_trans_pend_det INTO rw_tbcst_trans_pend_det;
			   IF cr_tbcst_trans_pend_det%NOTFOUND THEN
            --Fechar Cursor
           CLOSE cr_tbcst_trans_pend_det;      
            vr_cdcritic:= 0;
				    vr_dscritic:= 'Registro de Resgate de Cheque em Custódia pendente nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Fechar Cursor
				  CLOSE cr_tbcst_trans_pend_det;
          END IF;
          pr_dsdmensg := pr_dsdmensg || 
			  				  '<b>Borderô de resgate de cheque em custódia</b> no valor total de <b>R$ ' ||
                              TO_CHAR(rw_tbcst_trans_pend_det.vltotchq,'fm999g999g990d00') || 
                              '</b> com <b>' || rw_tbcst_trans_pend_det.qtcheque || '</b> cheques.<br>';			
             
-- Fim SM 454.1    


		WHEN pr_tptransa = 19 THEN -- Bordero Desconto de Titulo
          OPEN  cr_tbdsct_trans_pend(pr_cddoitem => pr_cdtranpe);
		  FETCH cr_tbdsct_trans_pend INTO rw_tbdsct_trans_pend;
		
	      IF cr_tbdsct_trans_pend%NOTFOUND THEN
            CLOSE cr_tbdsct_trans_pend;      
			
            vr_cdcritic := 0;
			vr_dscritic := 'Registro de Borderô de Desconto de Título pendente nao encontrado.';
			RAISE vr_exc_erro;
          ELSE
		    CLOSE cr_tbdsct_trans_pend;
		  END   IF;

		  pr_dsdmensg := pr_dsdmensg || '<b>Borderô de desconto de título</b> no valor total de <b>R$ ' ||
                         TO_CHAR(rw_tbdsct_trans_pend.vltotbdt,'fm999g999g990d00') || 
                         '</b> com <b>' || rw_tbdsct_trans_pend.qttitulo || '</b> títulos.<br>';
							 
-- Projeto 470
      WHEN pr_tptransa = 20 THEN -- Contratos
        OPEN cr_tbctd_trans_pend(pr_cddoitem => pr_cdtranpe);
        FETCH cr_tbctd_trans_pend
        INTO rw_tbctd_trans_pend;
        
        --
        IF cr_tbctd_trans_pend%NOTFOUND THEN

           CLOSE cr_tbctd_trans_pend;
           vr_cdcritic := 0;
           vr_dscritic := 'Registro de Contrato pendente nao encontrado.';
           RAISE vr_exc_erro;

        ELSE
              CLOSE cr_tbctd_trans_pend;
      END IF;

      -- PJ470
      pr_dsdmensg := pr_dsdmensg || '<b>Autorização de contrato de</b> '||rw_tbctd_trans_pend.dscontrato
                                 || '<b> realizado em</b> '||TO_CHAR(rw_tbctd_trans_pend.dhcontrato,'dd/mm/yyyy')
                                 || '<b> no valor de R$</b> '||TO_CHAR(rw_tbctd_trans_pend.vlcontrato,'fm999g999g990d00');
      -- Fim PJ470

        WHEN pr_tptransa = 21 THEN -- Emprestimos/financiamentos          

         OPEN cr_pend_efet_proposta(pr_cddoitem => pr_cdtranpe);
         FETCH cr_pend_efet_proposta INTO rw_pend_efet_proposta;
         IF cr_pend_efet_proposta%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_pend_efet_proposta;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro de Proposta de  Emprestimo/financiamento pendente nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
            
         ELSE
            --Fechar Cursor
            CLOSE cr_pend_efet_proposta;
         END IF;
         --/ 
         pr_dsdmensg := pr_dsdmensg ||
                        '<b>Proposta de emprestimo/financiamento </b> no valor de <b>R$ ' ||
                        TO_CHAR(rw_pend_efet_proposta.vlemprst,'fm999g999g990d00')||'</b>.<br>';

        

        ELSE
          vr_dscritic := 'Tipo de transação invalida.';
          RAISE vr_exc_erro;
			END CASE; -- End  Case
			      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE	
          pr_dscritic := vr_dscritic;
        END IF;        
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina INET0002.pc_cria_msgs_trans. '||SQLERRM;        
    END;
  END pc_cria_msgs_trans;

  /* Procedure para reprovar transacoes pendentes */
  PROCEDURE pc_reprova_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                  ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                  ,pr_cdagenci IN INTEGER                --Numero da agencia
                                  ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                  ,pr_dtmvtolt IN DATE                   --Data da operacao
                                  ,pr_cdorigem IN INTEGER                --Codigo Origem
                                  ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                  ,pr_cdditens IN VARCHAR2               --Itens
                                  ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                  ,pr_idseqttl IN NUMBER                 --Sequencial de Titularidade
                                  ,pr_flgerlog IN INTEGER                --Flag de log
                                  ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2) IS          --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_reprova_trans_pend
  --  Sistema  : Procedimentos para reprovar transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para reprovar transacao pendente
  --
  -- Alteração :  19/05/2017 - Inclusão de tratativa para quando for tipo 13 - Recarga de celular
  --                          pois o controle é feito pela tbrecarga_trans_pend. Projeto 321. (Lombardi)
  --
  --              12/03/2019 - Rafael (AmCom) Inclusão da pc_atualiza_proposta para tipo transacao 21 Emprestimos/financiamentos
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
  DECLARE
    
    --Variaveis Locais
	  vr_nmrescop crapcop.nmrescop%TYPE;
	  vr_idseqttl crapsnh.idseqttl%TYPE;
    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(100);
    vr_idastcjt NUMBER;
    vr_nrcpfcgc NUMBER(14);
    vr_nrdctato crapavt.nrdctato%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
	  vr_dtvalida crapavt.dtvalida%TYPE;
	  vr_tptransa NUMBER(2);
    vr_cddoitem tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dsdmensg VARCHAR2(32000) := ' ';
	  vr_dsdmensg_notif VARCHAR2(32000) := ' ';
    vr_ncctarep crapavt.nrdctato%TYPE;
    vr_auxnumbe NUMBER;
    vr_msgretor VARCHAR2(1000);
    
    -- Array para guardar o split dos dados contidos na dstextab
    vr_cdditens gene0002.typ_split;
    vr_auxditem gene0002.typ_split;
    -- Rowid tabela de log
    vr_nrdrowid ROWID;
	  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
		
    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 6;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 2;
		
	  -- Buscar nome da cooperativa
	  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		SELECT cop.nmrescop
		FROM   crapcop cop
		WHERE  cop.cdcooper = pr_cdcooper;	
		
    -- Busca dos dados do associado 
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.idastcjt,
           crapass.nmprimtl
    FROM   crapass
    WHERE  crapass.cdcooper = pr_cdcooper
    AND    crapass.nrdconta = pr_nrdconta;
    
    --Selecionar informacoes de senhas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE
				              ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
    SELECT crapsnh.nrcpfcgc
    FROM   crapsnh
    WHERE  crapsnh.cdcooper = pr_cdcooper
    AND    crapsnh.nrdconta = pr_nrdconta
    AND    crapsnh.idseqttl = pr_idseqttl
    AND    crapsnh.tpdsenha = 1; --Internet
		
	  --Selecionar informacoes de senhas
    CURSOR cr_crapsnh2 (pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
    SELECT crapsnh.idseqttl
    FROM   crapsnh
    WHERE  crapsnh.cdcooper = pr_cdcooper
    AND    crapsnh.nrdconta = pr_nrdconta
    AND    crapsnh.nrcpfcgc = pr_nrcpfcgc
    AND    crapsnh.tpdsenha = 1; --Internet
              
    -- Busca do nome do representante/procurador
    CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                     ,pr_nrdconta IN crapavt.nrdconta%TYPE
                     ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT crapavt.nrdctato,
           crapavt.nmdavali,
           crapavt.dtvalida
    FROM   crapavt
    WHERE  crapavt.cdcooper = pr_cdcooper
    AND    crapavt.nrdconta = pr_nrdconta
    AND    crapavt.nrcpfcgc = pr_nrcpfcgc
    AND    crapavt.tpctrato = 6; -- Juridico
	  
	  --Cursor (Pai) Transacoes Pendentes
	  CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
    SELECT tbgen_trans_pend.cdtransacao_pendente,
           tbgen_trans_pend.tptransacao
    FROM   tbgen_trans_pend 
    WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
    rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
	  
	  --Cursor de aprovacao
    CURSOR cr_tbgen_aprova_trans_pend( pr_cddoitem IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE,
                                       pr_nrcpfcgc IN tbgen_aprova_trans_pend.nrcpf_responsavel_aprov%TYPE,
                                       pr_inoutros IN NUMBER) IS  
    SELECT tbgen_aprova_trans_pend.nrdconta,
           tbgen_aprova_trans_pend.nrcpf_responsavel_aprov 
    FROM   tbgen_aprova_trans_pend
    WHERE  tbgen_aprova_trans_pend.cdtransacao_pendente    = pr_cddoitem
    AND    ((pr_inoutros = 0 AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = pr_nrcpfcgc) OR
            (pr_inoutros = 1 AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov <> pr_nrcpfcgc));
    rw_tbgen_aprova_trans_pend cr_tbgen_aprova_trans_pend%ROWTYPE;
	      	  
    --Cursor de transação pendente exclusivo de recarga de celular
    CURSOR cr_tbrecarga_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
    SELECT tbrecarga_trans_pend.idoperacao
    FROM   tbrecarga_trans_pend
    WHERE  tbrecarga_trans_pend.cdtransacao_pendente = pr_cddoitem;
    rw_tbrecarga_trans_pend cr_tbrecarga_trans_pend%ROWTYPE;
	      	  
    PROCEDURE pc_atualiza_proposta(pr_cdtransacao_pendente IN tbepr_trans_pend_efet_proposta.cdtransacao_pendente%TYPE) IS      
    --
    --/
    CURSOR cr_pend_efet_proposta(pr_cdtransacao_pendente IN tbepr_trans_pend_efet_proposta.cdtransacao_pendente%TYPE) IS
       SELECT cdtransacao_pendente, 
              cdcooper, 
              nrdconta, 
              nrctremp
         FROM tbepr_trans_pend_efet_proposta pep
        WHERE pep.cdtransacao_pendente = pr_cdtransacao_pendente; 
    --
    rw_pend_efet_proposta cr_pend_efet_proposta%ROWTYPE;
    --/      
    vr_des_erro VARCHAR2(100);
    --/
    BEGIN
    
     OPEN cr_pend_efet_proposta(pr_cdtransacao_pendente);
     FETCH cr_pend_efet_proposta INTO rw_pend_efet_proposta;
       IF cr_pend_efet_proposta%FOUND
         THEN 
          --/ atualiza a proposta
          UPDATE crawepr epr
             SET epr.insitest = 6
           WHERE epr.cdcooper = rw_pend_efet_proposta.cdcooper
             AND epr.nrctremp = rw_pend_efet_proposta.nrctremp
             AND epr.nrdconta = rw_pend_efet_proposta.nrdconta;
          --/
          empr0001.pc_insere_motivo_anulacao
                     (pr_cdcooper => rw_pend_efet_proposta.cdcooper, 
                      pr_cdagenci => pr_cdagenci, 
                      pr_nrdcaixa => pr_nrdcaixa, 
                      pr_cdoperad => pr_cdoperad, 
                      pr_nmdatela => pr_nmdatela, 
                      pr_idorigem => pr_cdorigem, 
                      pr_tpproduto => 1, -- emprestimo
                      pr_nrdconta => rw_pend_efet_proposta.nrdconta,
                      pr_nrctrato => rw_pend_efet_proposta.nrctremp,
                      pr_tpctrlim => NULL, 
                      pr_cdmotivo => 9,
                      pr_dsmotivo => 'Transação pendente não aprovada pelo sócio',
                      pr_dsobservacao => 'Transação pendente não aprovada pelo sócio', 
                      pr_cdcritic => vr_cdcritic, 
                      pr_dscritic => vr_dscritic, 
                      pr_des_erro => vr_des_erro);
         --/
         IF NOT ( vr_dscritic IS NULL )
           THEN
             CLOSE cr_pend_efet_proposta;
             RAISE vr_exc_erro;                                              
         END IF;
       
       END IF; 
     CLOSE cr_pend_efet_proposta;
     --/
     --/
    END pc_atualiza_proposta;

	  ------------------------------------------------------
	
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    
	BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      
      IF pr_flgerlog = 1 THEN
         -- Buscar a origem
         vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_cdorigem);
         -- Buscar Transacao
         vr_dstransa:= 'Reprovar transacoes pendentes de operadores de conta.';
      END IF;
      
	    --Dados da Cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO vr_nmrescop;
      
	    --Se nao encontrou 
      IF cr_crapcop%NOTFOUND THEN    
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic := 794;
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
	  
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      
	    --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN    
        --Fechar Cursor
        CLOSE cr_crapass;
          vr_cdcritic := 9;
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapass;
      -- se for preposto
      IF pr_nrcpfope = 0 THEN
      --Consulta do cpf do representante na crapsnh
      OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
			               ,pr_idseqttl => pr_idseqttl);
      FETCH cr_crapsnh INTO vr_nrcpfcgc;
      
	    --Se nao encontrou 
      IF cr_crapsnh%NOTFOUND THEN  
        --Fechar Cursor
        CLOSE cr_crapsnh;  
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de senha nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapsnh;

      --Se conta exige assinatura multipla
      IF vr_idastcjt = 1 THEN
         --Consulta do nome do Representante
         OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcpfcgc => vr_nrcpfcgc);
         FETCH cr_crapavt INTO vr_nrdctato
                              ,vr_nmprimtl
				                      ,vr_dtvalida;
         
		     --Se nao encontrou 
         IF cr_crapavt%NOTFOUND THEN    
            --Fechar Cursor
            CLOSE cr_crapavt;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Dados do Representante nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
         END IF;                             
        
         --Fechar Cursor
         CLOSE cr_crapavt;

         -- Valida data de vigencia do representante 
         IF vr_dtvalida < TRUNC(SYSDATE) THEN
			      vr_cdcritic:= 0;
            vr_dscritic:= 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
            --Levantar Excecao
            RAISE vr_exc_erro;
		     END IF;
      END IF;
	    END IF;
      vr_cdditens := GENE0002.fn_quebra_string(pr_string  => pr_cdditens, 
                                               pr_delimit => '/');
      
      FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                  pr_delimit => '|');
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                  pr_delimit => ',');
         vr_cddoitem := TO_NUMBER(vr_auxditem(3));
         OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
         FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
                  
         IF cr_tbgen_trans_pend%FOUND THEN
            -- Se for preposto
            IF pr_nrcpfope = 0 THEN
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend;

            OPEN cr_tbgen_aprova_trans_pend(pr_cddoitem => vr_cddoitem,
                                            pr_nrcpfcgc => vr_nrcpfcgc,
                                            pr_inoutros => 0); -- buscar registro do cpf informado
            FETCH cr_tbgen_aprova_trans_pend INTO rw_tbgen_aprova_trans_pend;
			      
			      IF cr_tbgen_aprova_trans_pend%NOTFOUND THEN	
               --Fechar Cursor
               CLOSE cr_tbgen_aprova_trans_pend;
               vr_cdcritic:= 0;
               vr_dscritic:= 'Transacao nao pode ser reprovada pelo representante legal.';
               --Levantar Excecao
               RAISE vr_exc_erro;
			      END IF;
			
            --Fechar Cursor
            CLOSE cr_tbgen_aprova_trans_pend;
            END IF;
            -- Se for operador, validar o limite diario
            IF pr_nrcpfope > 0 THEN
              INET0001.pc_verifica_limite_ope_prog(pr_cdcooper => pr_cdcooper, 
                                                   pr_nrdconta => pr_nrdconta, 
                                                   pr_idseqttl => pr_idseqttl, 
                                                   pr_nrcpfope => pr_nrcpfope, 
                                                   pr_cdoperad => pr_cdoperad, 
                                                   pr_cddoitem => vr_cddoitem, 
                                                   pr_dtmvtopg => sysdate, 
                                                   pr_dsorigem => GENE0001.vr_vet_des_origens(pr_cdorigem), 
                                                   pr_msgretor => vr_msgretor, 
                                                   pr_cdcritic => pr_cdcritic, 
                                                   pr_dscritic => pr_dscritic);

              IF vr_msgretor <> 'OK' THEN
                pr_cdcritic:= 0;
                vr_dscritic:= vr_msgretor;
                --Levantar Excecao
                RAISE vr_exc_erro; 
              ELSIF pr_dscritic IS NOT NULL THEN 
                RAISE vr_exc_erro; 
              END IF; 

            END IF;

			      BEGIN
               --Atualiza para reprovada a transacao
               UPDATE tbgen_trans_pend 
               SET	   tbgen_trans_pend.idsituacao_transacao = 6, -- Reprovada
                       tbgen_trans_pend.dtalteracao_situacao = TRUNC(SYSDATE)
               WHERE   tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            EXCEPTION
               WHEN OTHERS THEN
                    pr_cdcritic:= 0;
                    pr_dscritic:= 'Erro na rotina INET0002.pc_reprova_trans_pend(01): ' || SQLERRM;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
            END;
            -- Se for preposto
			      IF pr_nrcpfope = 0 THEN
              BEGIN
                 --Atualiza registro de aprovacao do responsavel legal 
                 UPDATE tbgen_aprova_trans_pend
                 SET    tbgen_aprova_trans_pend.idsituacao_aprov = 3 -- Reprovada
                       ,tbgen_aprova_trans_pend.dtalteracao_situacao = TRUNC(SYSDATE)
                       ,tbgen_aprova_trans_pend.hralteracao_situacao = gene0002.fn_busca_time
                 WHERE  tbgen_aprova_trans_pend.cdtransacao_pendente = vr_cddoitem
                 AND    tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = vr_nrcpfcgc;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_cdcritic:= 0;
                  pr_dscritic:= 'Erro na rotina INET0002.pc_reprova_trans_pend(02): ' || SQLERRM;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
			      END IF;
            --
            IF rw_tbgen_trans_pend.tptransacao = 13 THEN
              
              OPEN cr_tbrecarga_trans_pend(pr_cddoitem => vr_cddoitem);
              FETCH cr_tbrecarga_trans_pend INTO  rw_tbrecarga_trans_pend;
              
              IF cr_tbrecarga_trans_pend%FOUND THEN
                
                CLOSE cr_tbrecarga_trans_pend;
                
                BEGIN
                  UPDATE tbrecarga_operacao
                     SET insit_operacao = 6 /* não aprovada transação pendente */ 
                   WHERE idoperacao =  rw_tbrecarga_trans_pend.idoperacao;
                 EXCEPTION
                   WHEN OTHERS THEN
                     pr_cdcritic:= 0;
                     pr_dscritic:= 'Erro na rotina INET0002.pc_reprova_trans_pend(03): ' || SQLERRM;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END;
              ELSE 
                CLOSE cr_tbrecarga_trans_pend;
              END IF;
            
            ELSIF rw_tbgen_trans_pend.tptransacao = 21 -- Emprestimos/financiamentos 
              THEN
               --/
               pc_atualiza_proposta(rw_tbgen_trans_pend.cdtransacao_pendente);
            
            END IF;
			
			      FOR rw_tbgen_aprova_trans_pend IN cr_tbgen_aprova_trans_pend (pr_cddoitem  => vr_cddoitem
                                                                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                                                                         ,pr_inoutros  => 1) LOOP --trazer todos menos o cpf informado
				        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
							                 ,pr_nrdconta => pr_nrdconta
                               ,pr_nrcpfcgc => rw_tbgen_aprova_trans_pend.nrcpf_responsavel_aprov);
				        FETCH cr_crapavt INTO vr_ncctarep,
									                    vr_nmprimtl,
                                      vr_dtvalida;
                
                --Se nao encontrou 
                IF cr_crapavt%NOTFOUND THEN
                   --Fechar Cursor
                   CLOSE cr_crapavt;
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Registro do representante nao encontrado.';
                   --Levantar Excecao
					         RAISE vr_exc_erro;
				        END IF;				
                --Fechar Cursor
                CLOSE cr_crapavt;              
                
                IF vr_ncctarep > 0 THEN
                   OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_ncctarep);
                   FETCH cr_crapass INTO vr_auxnumbe,
                                         vr_nmprimtl;
                   --Se nao encontrou 
                   IF cr_crapass%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapass;
                       vr_cdcritic:= 9;
                       vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END IF; 
                   --Fechar Cursor
                   CLOSE cr_crapass;
                END IF;
                
                --Consulta do idseqttl do representante na crapsnh
                OPEN cr_crapsnh2(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_tbgen_aprova_trans_pend.nrdconta
                                ,pr_nrcpfcgc => rw_tbgen_aprova_trans_pend.nrcpf_responsavel_aprov);
                FETCH cr_crapsnh2 INTO vr_idseqttl;
                
                --Se nao encontrou 
                IF cr_crapsnh2%NOTFOUND THEN  
                   --Fechar Cursor
                   CLOSE cr_crapsnh2;  
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Registro de senha nao encontrado.(2)';
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                END IF;
				
                --Fechar Cursor
                CLOSE cr_crapsnh2;

				        vr_tptransa := rw_tbgen_trans_pend.tptransacao;
				
				        -- Criacao de mensagens de transacao
                INET0002.pc_cria_msgs_trans (pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                            ,pr_nrdconta => pr_nrdconta   -- Conta do Associado
                                            ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do caixa
                                            ,pr_cdagenci => pr_cdagenci   -- Numero da agencia
                                            ,pr_cdoperad => pr_cdoperad   -- Numero do operador
                                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data da operacao
                                            ,pr_cdorigem => pr_cdorigem   -- Codigo Origem
                                            ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                                            ,pr_cdtranpe => vr_cddoitem   -- Codigo da Transacao Principal
                                            ,pr_tptransa => vr_tptransa   -- Tipo de Transacao
                                            ,pr_dsdmensg => vr_dsdmensg		-- Descricao da mensagem
                                            ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                            ,pr_dscritic => vr_dscritic); -- Descricao do erro
    
                vr_dsdmensg_notif := vr_dsdmensg;
                vr_dsdmensg := 'Atenção, ' || vr_nmprimtl || '!<br><br>' ||
                               'Informamos que a seguinte transação foi reprovada:<br><br>' || vr_dsdmensg;
                            
				        -- Gerar mensagem
				        gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_tbgen_aprova_trans_pend.nrdconta
                                          ,pr_idseqttl => vr_idseqttl
                                          ,pr_cdprogra => 'INET0002'
                                          ,pr_inpriori => 0
                                          ,pr_dsdmensg => vr_dsdmensg
                                          ,pr_dsdassun => 'Transação reprovada'
                                          ,pr_dsdremet => vr_nmrescop
                                          ,pr_dsdplchv => 'Transação reprovada'
                                          ,pr_cdoperad => 1
                                          ,pr_cdcadmsg => 0
                                          ,pr_dscritic => vr_dscritic);
			
                --
                vr_variaveis_notif('#dsdmensg')     := vr_dsdmensg_notif;
                -- Cria uma notificação
                noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                            ,pr_cdmotivo_mensagem => vr_notif_motivo
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_tbgen_aprova_trans_pend.nrdconta
                                            ,pr_idseqttl => vr_idseqttl   
                                            ,pr_variaveis => vr_variaveis_notif);                 
                --
			
			      END LOOP;
			      
			      --Geracao de log 
			      IF  pr_flgerlog = 1 THEN
          
				        GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                                     ,pr_cdoperad => pr_cdoperad 
                                     ,pr_dscritic => ''         
                                     ,pr_dsorigem => vr_dsorigem
                                     ,pr_dstransa => vr_dstransa
                                     ,pr_dttransa => pr_dtmvtolt
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => gene0002.fn_busca_time
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_nrdconta => pr_nrdconta
				     		 	                   ,pr_nrdrowid => vr_nrdrowid);
							 
				        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Codigo da Transacao Pendente', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( rw_tbgen_trans_pend.cdtransacao_pendente));
			  
			          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Nome do Representante', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => vr_nmprimtl);
							  IF pr_nrcpfope = 0 THEN
			          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'CPF do Representante', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( vr_nrcpfcgc));
                ELSE
			            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                            pr_nmdcampo => 'CPF do Operador', 
                                            pr_dsdadant => '', 
                                            pr_dsdadatu => TO_CHAR(pr_nrcpfope));                 
                END IF;
			      
            END IF;  --IF  pr_flgerlog = 1 THEN
         ELSE
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend;

         END IF; --IF cr_tbgen_trans_pend%FOUND THEN
         
      END LOOP;
      
      COMMIT;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(vr_cdcritic,0); 
           
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic);
      ELSE
        pr_dscritic:= vr_dscritic;
      END IF;
         
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Others Erro na rotina INET0002.pc_reprova_trans_pend: ' || SQLERRM;
      ROLLBACK;
    END;
           
  END pc_reprova_trans_pend;
  
  
  -- Procedure para validacao de representantes legais por transacao
  PROCEDURE pc_valid_repre_legal_trans(pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta  IN crapsnh.nrdconta%TYPE
                                      ,pr_idseqttl  IN crapsnh.idseqttl%TYPE
                                      ,pr_flvldrep  IN INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valid_repre_legal_trans
  --  Sistema  : Procedimentos para valicao de representantes legais
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 08/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validacao de representantes legais
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
  
  DECLARE  
    -- Cursores
    -- Informacoes sobre a conta
    CURSOR cr_crapass IS
      SELECT
        ass.idastcjt
       ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Consulta de poderes
    CURSOR cr_crappod(pr_nrcpfcgc IN crappod.nrcpfpro%TYPE) IS
      SELECT pod.nrdconta
        FROM crappod pod 
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.nrcpfpro = pr_nrcpfcgc
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;

    rw_crappod cr_crappod%ROWTYPE;

    -- Consulta quantidade de responsaveis com poderes de assinatura conjunta
    CURSOR cr_crappod_cont IS
      SELECT COUNT(pod.nrdconta) AS contador
        FROM crappod pod 
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;

    rw_crappod_cont cr_crappod_cont%ROWTYPE;
     
    -- Consulta registro de senha para INTERNET
    CURSOR cr_crapsnh IS
      SELECT snh.nrcpfcgc
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = pr_idseqttl
         AND snh.tpdsenha = 1;

    rw_crapsnh cr_crapsnh%ROWTYPE;

    -- Consulta registro de validade de procuracao
    CURSOR cr_crapavt(pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT avt.dtvalida
		  FROM crapavt avt
		 WHERE avt.cdcooper = pr_cdcooper
		   AND avt.nrdconta = pr_nrdconta
			 AND avt.tpctrato = 6
			 AND avt.nrcpfcgc = pr_nrcpfcgc;

	  rw_crapavt cr_crapavt%ROWTYPE;

    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    
  BEGIN
   
  -- Consulta conta 
  OPEN cr_crapass;

  FETCH cr_crapass INTO rw_crapass;

  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_cdcritic := 9;
    RAISE vr_exec_saida;
  ELSE
    CLOSE cr_crapass;
  END IF;

  -- Verifica se conta requer assinatura conjunta
  IF rw_crapass.idastcjt = 1 THEN
    OPEN cr_crappod_cont;
    
    FETCH cr_crappod_cont INTO rw_crappod_cont;
    CLOSE cr_crappod_cont;

    -- Verifica quantidade de procuradores da conta
    IF rw_crappod_cont.contador >= 2 THEN
      IF pr_flvldrep = 1 THEN 
        OPEN cr_crapsnh;

        FETCH cr_crapsnh INTO rw_crapsnh;

        -- Verifica se procurador tem acesso
        IF cr_crapsnh%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_crapsnh;
          vr_dscritic := 'Transacao deve ser registrada por um representante legal.';
          RAISE vr_exec_saida;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapsnh;
        END IF;

        -- Verifica se procurador tem poder de assinatura conjunta
        OPEN cr_crappod(pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);

        FETCH cr_crappod INTO rw_crappod;

        IF cr_crappod%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_crappod;
          -- Critica por responsavel nao ter poderes de assinatura conjunta
          vr_dscritic := 'Operação disponível somente para representantes legais.';
          RAISE vr_exec_saida;
        ELSE
          CLOSE cr_crappod;
        END IF;

        -- Consulta registro 
        OPEN cr_crapavt(pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);

        FETCH cr_crapavt INTO rw_crapavt;

        -- Verifica registro de procurador
        IF cr_crapavt%NOTFOUND THEN
          -- Fecha Cursor
          vr_dscritic := 'Procurador não encontrado.';
          CLOSE cr_crapavt;
          RAISE vr_exec_saida;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapavt;
          
          IF rw_crapavt.dtvalida < SYSDATE THEN
            vr_dscritic := 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
            RAISE vr_exec_saida;
          END IF;
        END IF;
      END IF;
    ELSE
      vr_dscritic := 'A conta deve possuir no minimo 2 representantes legais habilitados.';
      RAISE vr_exec_saida;
    END IF;
    
  END IF;

  EXCEPTION
    WHEN vr_exec_saida THEN
            
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) <> 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_valid_repre_legal_trans. Erro: '|| SQLERRM; 
      ROLLBACK; 
    END;    
  END pc_valid_repre_legal_trans;

  -- Procedure de criacao de transacao de pagamentos
  PROCEDURE pc_cria_trans_pend_pagto(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                    ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                    ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                    ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                    ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                    ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                    ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                    ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                    ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                    ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                    ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                    ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                    ,pr_cdctrlcs  IN tbpagto_trans_pend.cdctrlcs%TYPE          --> Código de controle de consulta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                 --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_pagto
    --  Sistema  : Procedure de criacao de transacao de pagamentos
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 03/12/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure de criacao de transacao de pagamentos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    BEGIN
      DECLARE
      -- Variáveis
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      vr_exec_saida EXCEPTION;
      vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
      vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas    
      -- log verlog
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);

    BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 2
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbpagto_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta             
          ,tppagamento          
          ,vlpagamento          
          ,dtdebito             
          ,idagendamento        
          ,dscedente            
          ,dscodigo_barras      
          ,dslinha_digitavel    
          ,vldocumento          
          ,dtvencimento         
          ,tpcaptura            
          ,idtitulo_dda
          ,cdctrlcs)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idtippag
          ,pr_vllanmto
          ,pr_dtmvtopg
          ,pr_idagenda
          ,pr_dscedent
          ,pr_dscodbar
          ,pr_dslindig
          ,pr_vlrdocto
          ,pr_dtvencto
          ,pr_tpcptdoc
          ,pr_idtitdda
          ,nvl(pr_cdctrlcs,' '));
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_trans_pend: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 2 
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;
    --
    vr_nrdrowid := NULL;
    vr_dstransa := '2 - Transacao de pagamento pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Lancamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vllanmto);
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'CPF do Preposto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfrep);


    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_pagto. Erro: '|| SQLERRM; 
      ROLLBACK; 
    END;
  END pc_cria_trans_pend_pagto;

  -- Procedure de criacao de transacao de TED
  PROCEDURE pc_cria_trans_pend_ted(pr_cdagenci  IN crapage.cdagenci%TYPE                         --> Codigo do PA
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                         --> Numero do Caixa
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE                         --> Codigo do Operados
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE                         --> Nome da Tela
                                  ,pr_idorigem  IN INTEGER                                       --> Origem da solicitacao
                                  ,pr_idseqttl  IN crapttl.idseqttl%TYPE                         --> Sequencial de Titular            
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do operador juridico
                                  ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do representante legal
                                  ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                --> Cooperativa do Terminal
                                  ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                --> Agencia do Terminal
                                  ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                --> Numero do Terminal Financeiro
                                  ,pr_dtmvtolt  IN DATE                                          --> Data do movimento     
                                  ,pr_cdcooper  IN tbspb_trans_pend.cdcooper%TYPE                --> Codigo da cooperativa
                                  ,pr_nrdconta  IN tbspb_trans_pend.nrdconta%TYPE                --> Numero da Conta
                                  ,pr_vllanmto  IN tbspb_trans_pend.vlted%TYPE                   --> Valor de Lancamento
                                  ,pr_nrcpfcnpj IN tbspb_trans_pend.nrcpfcnpj_favorecido%TYPE    --> CPF/CNPJ do Favorecido
                                  ,pr_nmtitula  IN tbspb_trans_pend.nmtitula_favorecido%TYPE     --> Nome to Titular Favorecido
                                  ,pr_tppessoa  IN tbspb_trans_pend.tppessoa_favorecido%TYPE     --> Tipo de pessoa do Favorecido
                                  ,pr_tpconta   IN tbspb_trans_pend.tpconta_favorecido%TYPE      --> Tipo da conta do Favorecido
                                  ,pr_dtmvtopg  IN tbspb_trans_pend.dtdebito%TYPE                --> Data do Pagamento
                                  ,pr_idagenda  IN tbspb_trans_pend.idagendamento%TYPE           --> Indicador de agendamento
                                  ,pr_cddbanco  IN tbspb_trans_pend.cdbanco_favorecido%TYPE      --> Codigo do banco
                                  ,pr_cdageban  IN tbspb_trans_pend.cdagencia_favorecido%TYPE    --> Codigo da agencia bancaria
                                  ,pr_nrctadst  IN tbspb_trans_pend.nrconta_favorecido%TYPE      --> Conta de destino
                                  ,pr_cdfinali  IN tbspb_trans_pend.cdfinalidade%TYPE            --> Codigo da finalidade
                                  ,pr_dstransf  IN tbspb_trans_pend.dscodigo_identificador%TYPE  --> Descricao da transferencia
                                  ,pr_dshistor  IN tbspb_trans_pend.dshistorico%TYPE             --> Descricao do historico
                                  ,pr_nrispbif  IN tbspb_trans_pend.nrispb_banco_favorecido%TYPE --> Codigo unico do banco
                                  ,pr_idastcjt  IN crapass.idastcjt%TYPE                         --> Indicador de Assinatura Conjunta
                                  ,pr_lsdatagd  IN VARCHAR2
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                         --> Codigo de Critica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                     --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_ted
    --  Sistema  : Procedure de criacao de transacao de TED
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 25/02/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure de criacao de transacao de TED
    --
    -- Alteração : 25/02/2016 - Receber e gravar novos campos das transacoes TED (Marcos-Supero)
    --
    --             27/03/2019 - Ajustes para permitir criar as transações para o TED Judicial
    --                          Jose Dill - Mouts (P475 - REQ39)
    ---------------------------------------------------------------------------------------------------------------
                 
    -- Cursores
    
    --INC0021893    
    CURSOR cr_tbgen_trans_pend_dup (pr_cdcooper IN tbspb_trans_pend.cdcooper%TYPE
                                    ,pr_nrdconta IN tbspb_trans_pend.nrdconta%TYPE
                                    ,pr_dtdebito IN tbspb_trans_pend.dtdebito%TYPE
                                    ,pr_dtregistro_transacao IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                    ,pr_cdagencia_coop_destino IN tbspb_trans_pend.cdagencia_favorecido%TYPE
                                    ,pr_nrconta_destino IN tbspb_trans_pend.nrconta_favorecido%TYPE
                           	        ,pr_vltransferencia IN tbspb_trans_pend.vlted%TYPE) IS
      SELECT MAX (ttp2.hrregistro_transacao)
        FROM tbspb_trans_pend ttp
             ,tbgen_trans_pend ttp2
       WHERE ttp2.cdcooper = ttp.cdcooper
         AND ttp2.nrdconta = ttp.nrdconta
         AND ttp.cdtransacao_pendente = ttp2.cdtransacao_pendente
         AND ttp.cdcooper = pr_cdcooper
         AND ttp.nrdconta = pr_nrdconta
         AND ttp.dtdebito = pr_dtdebito
         AND ttp2.dtmvtolt = pr_dtregistro_transacao
         AND ttp.cdagencia_favorecido = pr_cdagencia_coop_destino
         AND ttp.nrconta_favorecido = pr_nrconta_destino
         AND ttp.vlted = pr_vltransferencia;
    
    vr_hrregistro_transacao_dup tbgen_trans_pend.hrregistro_transacao%TYPE; 
    vr_exc_erro EXCEPTION;   
    /*INC0021893*/
                        
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas 
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_dtmvtopg DATE;    
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);   
    vr_cdtiptra INTEGER; --REQ39 
    
  BEGIN

    --INC0021893
    OPEN cr_tbgen_trans_pend_dup(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtdebito => pr_dtmvtopg
                                 ,pr_dtregistro_transacao => pr_dtmvtolt
                                 ,pr_cdagencia_coop_destino => pr_cdageban
                                 ,pr_nrconta_destino => pr_nrctadst
                                 ,pr_vltransferencia => pr_vllanmto);
            --Posicionar no proximo registro
            FETCH cr_tbgen_trans_pend_dup INTO vr_hrregistro_transacao_dup;
              --Se encontrar
              IF cr_tbgen_trans_pend_dup%FOUND THEN
                --Compara os segundos do último lançamento para não haver duplicidade
                IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrregistro_transacao_dup) <= 600 THEN
                
                  --Fechar Cursor
                  CLOSE cr_tbgen_trans_pend_dup;  
                
                  vr_cdcritic := 0;
                  vr_dscritic := 'Ja existe transacao pendente do mesmo valor e favorecido. Consulte suas pendencias.';
                  
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                    
                END IF;
              END IF;  
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend_dup;    
    /*INC0021893*/
 
    IF pr_idagenda > 1 THEN
      vr_idagenda := 2;
    ELSE
      vr_idagenda := pr_idagenda;
    END IF;

    -- Verificar se possui mais de uma data de agendamento
    IF instr(pr_lsdatagd,',') > 0  THEN
      
      -- quebrar string 
      vr_tab_lsdatagd := gene0002.fn_quebra_string(pr_string => pr_lsdatagd, 
                                                   pr_delimit => ',');
          
      -- Varrer loop de datas
      FOR i IN vr_tab_lsdatagd.first..vr_tab_lsdatagd.last LOOP
      
        vr_dtmvtopg := to_date(vr_tab_lsdatagd(i),'DD/MM/RRRR');
        /* REQ39 - Quando for um TED Judicial deve ser passado o tipo de transação 22*/
        IF pr_cdfinali = 100 THEN
           vr_cdtiptra:= 22;
        ELSE
           vr_cdtiptra:= 4; 
        END IF;   
        --
        INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => vr_cdtiptra --REQ39
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                       
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbspb_trans_pend(
               cdtransacao_pendente
              ,cdcooper               
              ,nrdconta               
              ,vlted                  
              ,dtdebito               
              ,idagendamento          
              ,cdbanco_favorecido     
              ,cdagencia_favorecido   
              ,nrconta_favorecido     
              ,cdfinalidade           
              ,dscodigo_identificador 
              ,dshistorico            
              ,nrispb_banco_favorecido
              ,nrcpfcnpj_favorecido
              ,nmtitula_favorecido 
              ,tppessoa_favorecido 
              ,tpconta_favorecido)
            VALUES(
               vr_cdtranpe
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,vr_dtmvtopg
              ,pr_idagenda
              ,pr_cddbanco
              ,pr_cdageban
              ,pr_nrctadst
              ,pr_cdfinali
              ,pr_dstransf
              ,pr_dshistor
              ,pr_nrispbif
              ,pr_nrcpfcnpj
              ,pr_nmtitula
              ,pr_tppessoa
              ,pr_tpconta);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbspb_trans_pend: ' || SQLERRM;
            RAISE vr_exec_saida;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrcpfrep => pr_nrcpfrep
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdtiptra => vr_cdtiptra --REQ39
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_cdtranpe => vr_cdtranpe
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;
      END LOOP;

    ELSE
      /* REQ39 - Quando for um TED Judicial deve ser passado o tipo de transação 22*/
      IF pr_cdfinali = 100 THEN
         vr_cdtiptra:= 22;
      ELSE
         vr_cdtiptra:= 4; 
      END IF;  
      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => vr_cdtiptra --REQ39
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                           
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbspb_trans_pend(
               cdtransacao_pendente
              ,cdcooper               
              ,nrdconta               
              ,vlted                  
              ,dtdebito               
              ,idagendamento          
              ,cdbanco_favorecido     
              ,cdagencia_favorecido   
              ,nrconta_favorecido     
              ,cdfinalidade           
              ,dscodigo_identificador 
              ,dshistorico            
              ,nrispb_banco_favorecido
              ,nrcpfcnpj_favorecido
              ,nmtitula_favorecido 
              ,tppessoa_favorecido 
              ,tpconta_favorecido)
            VALUES(
               vr_cdtranpe
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,pr_dtmvtopg
              ,vr_idagenda
              ,pr_cddbanco
              ,pr_cdageban
              ,pr_nrctadst
              ,pr_cdfinali
              ,pr_dstransf
              ,pr_dshistor
              ,pr_nrispbif
              ,pr_nrcpfcnpj
              ,pr_nmtitula
              ,pr_tppessoa
              ,pr_tpconta);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbspb_trans_pend: ' || SQLERRM;
            RAISE vr_exec_saida;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrcpfrep => pr_nrcpfrep
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdtiptra => vr_cdtiptra --REQ39 
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_cdtranpe => vr_cdtranpe
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;
    
    END IF;      
      
    vr_nrdrowid := NULL;
    vr_dstransa := '4 - Transacao de TED pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor do Lancamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vllanmto);
                              
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'CPF do Preposto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfrep);                                  
      
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;
      
    --INC0021893
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;      
      ROLLBACK;
    /*INC0021893*/

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_ted: ' || SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_ted;

  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_transf(pr_cdtiptra  IN INTEGER                                         --> Tipo da Transacao
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE                           --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                           --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                           --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                           --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                         --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                           --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                  --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                  --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                  --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                            --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE               --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE               --> Numero da Conta
                                     ,pr_vllanmto  IN tbtransf_trans_pend.vltransferencia%TYPE        --> Valor de Lancamento
                                     ,pr_dtmvtopg  IN tbtransf_trans_pend.dtdebito%TYPE               --> Data do Pagamento
                                     ,pr_idagenda  IN tbtransf_trans_pend.idagendamento%TYPE          --> Indicador de agendamento
                                     ,pr_cdageban  IN tbtransf_trans_pend.cdagencia_coop_destino%TYPE --> Codigo da agencia bancaria
                                     ,pr_nrctadst  IN tbtransf_trans_pend.nrconta_destino%TYPE        --> Conta de destino
                                     ,pr_lsdatagd  IN VARCHAR2                                        --> Lista de datas para agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                           --> Indicador de Assinatura Conjunta
 								     ,pr_flmobile  IN tbtransf_trans_pend.indmobile%TYPE              --> Indicador Mobile
									 ,pr_idtipcar  IN tbtransf_trans_pend.indtipo_cartao%TYPE         --> Indicador Tipo Cartão Utilizado
									 ,pr_nrcartao  IN tbtransf_trans_pend.nrcartao%TYPE               --> Numero Cartao
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                           --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                       --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_transf
    --  Sistema  : Procedimentos de criacao de transacao de transferencia
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 03/12/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos de criacao de transacao de transferencia
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Cursores
    
    --INC0021893    
    CURSOR cr_tbgen_trans_pend_dup (pr_cdcooper IN tbtransf_trans_pend.cdcooper%TYPE
                                    ,pr_nrdconta IN tbtransf_trans_pend.nrdconta%TYPE
                                    ,pr_dtdebito IN tbtransf_trans_pend.dtdebito%TYPE
                                    ,pr_dtregistro_transacao IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                    ,pr_cdagencia_coop_destino IN tbtransf_trans_pend.cdagencia_coop_destino%TYPE
                                    ,pr_nrconta_destino IN tbtransf_trans_pend.nrconta_destino%TYPE
                           	        ,pr_vltransferencia IN tbtransf_trans_pend.vltransferencia%TYPE) IS
      SELECT MAX (ttp2.hrregistro_transacao)
        FROM tbtransf_trans_pend ttp
             ,tbgen_trans_pend ttp2
       WHERE ttp2.cdcooper = ttp.cdcooper
         AND ttp2.nrdconta = ttp.nrdconta
         AND ttp.cdtransacao_pendente = ttp2.cdtransacao_pendente
         AND ttp.cdcooper = pr_cdcooper
         AND ttp.nrdconta = pr_nrdconta
         AND ttp.dtdebito = pr_dtdebito
         AND ttp2.dtmvtolt = pr_dtregistro_transacao
         AND ttp.cdagencia_coop_destino = pr_cdagencia_coop_destino
         AND ttp.nrconta_destino = pr_nrconta_destino
         AND ttp.vltransferencia = pr_vltransferencia;
    
    vr_hrregistro_transacao_dup tbgen_trans_pend.hrregistro_transacao%TYPE; 
    vr_exc_erro EXCEPTION;   
    /*INC0021893*/
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dtmvtopg DATE;
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);
        
  BEGIN
   
    --INC0021893
    OPEN cr_tbgen_trans_pend_dup(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_dtdebito => pr_dtmvtopg
                                 ,pr_dtregistro_transacao => pr_dtmvtolt
                                 ,pr_cdagencia_coop_destino => pr_cdageban
                                 ,pr_nrconta_destino => pr_nrctadst
                                 ,pr_vltransferencia => pr_vllanmto);
            --Posicionar no proximo registro
            FETCH cr_tbgen_trans_pend_dup INTO vr_hrregistro_transacao_dup;
              --Se encontrar
              IF cr_tbgen_trans_pend_dup%FOUND THEN
                --Compara os segundos do último lançamento para não haver duplicidade
                IF (((SYSDATE-TRUNC(SYSDATE))*(24*60*60)) - vr_hrregistro_transacao_dup) <= 600 THEN
                
                  --Fechar Cursor
                  CLOSE cr_tbgen_trans_pend_dup;  
                
                  vr_cdcritic := 0;
                  vr_dscritic := 'Ja existe transacao pendente do mesmo valor e favorecido. Consulte suas pendencias.';
                  
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                    
                END IF;
              END IF;  
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend_dup;    
    /*INC0021893*/
 
    IF pr_idagenda > 1 THEN
      vr_idagenda := 2;
    ELSE
      vr_idagenda := pr_idagenda;
    END IF;

    -- Verificar se possui mais de uma data de agendamento
    IF instr(pr_lsdatagd,',') > 0  THEN
      
      -- quebrar string 
      vr_tab_lsdatagd := gene0002.fn_quebra_string(pr_string => pr_lsdatagd, 
                                                   pr_delimit => ',');
          
      -- Varrer loop de datas
      FOR i IN vr_tab_lsdatagd.first..vr_tab_lsdatagd.last LOOP
      
        vr_dtmvtopg := to_date(vr_tab_lsdatagd(i),'DD/MM/RRRR');

        INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => pr_cdtiptra
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                       
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbtransf_trans_pend(
               cdtransacao_pendente  
              ,cdcooper              
              ,nrdconta              
              ,vltransferencia       
              ,dtdebito              
              ,idagendamento         
              ,cdagencia_coop_destino 
              ,nrconta_destino
			        ,indmobile
			        ,indtipo_cartao
			        ,nrcartao)
            VALUES(
               vr_cdtranpe          
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,vr_dtmvtopg
              ,vr_idagenda
              ,pr_cdageban
              ,pr_nrctadst
			        ,pr_flmobile
			        ,pr_idtipcar
			        ,pr_nrcartao);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbtransf_trans_pend: ' || SQLERRM;
            RAISE vr_exec_saida;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => pr_cdtiptra
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

      END LOOP;

    ELSE -- se existir somente um registro para criar
      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                         ,pr_nrdcaixa => pr_nrdcaixa
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_idorigem => pr_idorigem
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrcpfope => pr_nrcpfope
                                         ,pr_nrcpfrep => pr_nrcpfrep
                                         ,pr_cdcoptfn => pr_cdcoptfn
                                         ,pr_cdagetfn => pr_cdagetfn
                                         ,pr_nrterfin => pr_nrterfin
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdtiptra => pr_cdtiptra
                                         ,pr_idastcjt => pr_idastcjt
                                         ,pr_tab_crapavt => vr_tab_crapavt
                                         ,pr_cdtranpe => vr_cdtranpe
                                         ,pr_dscritic => vr_dscritic);
                                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;

      BEGIN
        INSERT INTO
          tbtransf_trans_pend(
             cdtransacao_pendente  
            ,cdcooper              
            ,nrdconta              
            ,vltransferencia       
            ,dtdebito              
            ,idagendamento         
            ,cdagencia_coop_destino 
            ,nrconta_destino
			      ,indmobile
			      ,indtipo_cartao
			      ,nrcartao)
          VALUES(
             vr_cdtranpe          
            ,pr_cdcooper
            ,pr_nrdconta
            ,pr_vllanmto
            ,pr_dtmvtopg
            ,vr_idagenda
            ,pr_cdageban
            ,pr_nrctadst
			      ,pr_flmobile
			      ,pr_idtipcar
			      ,pr_nrcartao);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro tbtransf_trans_pend: ' || SQLERRM;
          RAISE vr_exec_saida;
      END;
      
      pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => pr_cdtiptra
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;

    END IF;

    -- Gerar LOG VERLOG
    vr_nrdrowid := NULL;
    vr_dstransa := pr_cdtiptra||' - Transacao de '||(CASE WHEN pr_cdtiptra = 3 THEN 'Credito Salario' ELSE 'Transferencia' END)||' pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor do Lancamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vllanmto);
                             
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'CPF do Preposto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfrep);                             
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    --INC0021893
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;      
      ROLLBACK;
    /*INC0021893*/

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_transf: ' || SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_transf;

  -- Procedure de criacao de transacao de credito pré-aprovado
  PROCEDURE pc_cria_trans_pend_credito(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                      ,pr_vlemprst  IN tbepr_trans_pend.vlemprestimo%TYPE      --> Valor do emprestimo
                                      ,pr_qtpreemp  IN tbepr_trans_pend.nrparcelas%TYPE        --> Numero de parcelas
                                      ,pr_vlpreemp  IN tbepr_trans_pend.vlparcela%TYPE         --> Valor da parcela
                                      ,pr_dtdpagto  IN tbepr_trans_pend.dtprimeiro_vencto%TYPE --> Data de vencimento da primeira parcela	
                                      ,pr_percetop  IN tbepr_trans_pend.vlpercentual_cet%TYPE  --> Valor percentual do CET
                                      ,pr_vlrtarif  IN tbepr_trans_pend.vltarifa%TYPE          --> Valor da tarifa do emprestimo
                                      ,pr_txmensal  IN tbepr_trans_pend.vltaxa_mensal%TYPE     --> Valor da taxa mensal de juros
                                      ,pr_vltariof  IN tbepr_trans_pend.vliof%TYPE             --> Valor de IOF
                                      ,pr_vltaxiof  IN tbepr_trans_pend.vlpercentual_iof%TYPE  --> Valor percentual do IOF
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS               --> Descricao de Critica

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_credito
    --  Sistema  : Procedimentos de criacao de transacao de crédito
    --  Sigla    : CRED
    --  Autor    : 
    --  Data     :              .                   Ultima atualizacao: 17/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos de criacao de transacao de transferencia
    --
    -- Alteração : 17/04/2019 - Inclusão de log par mapeamentos de erros de atualização 
    --                          da tabela tbepr_trans_pend
    --                          INC0011323 - Ana Volles
    --
    ---------------------------------------------------------------------------------------------------------------
    -- Variáveis
    vr_cdcritic    crapcri.cdcritic%TYPE := 0;
    vr_dscritic    crapcri.dscritic%TYPE := '';
    vr_exec_saida  EXCEPTION;
    vr_cdtranpe    tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    --INC0011323
    vr_dsparame    VARCHAR2(2000);
  BEGIN
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'INET0002.pc_cria_trans_pend_credito');

    vr_dsparame := ' - pr_cdagenci:'||pr_cdagenci||', pr_nrdcaixa:'||pr_nrdcaixa
                  ||', pr_cdoperad:'||pr_cdoperad||', pr_nmdatela:'||pr_nmdatela
                  ||', pr_idorigem:'||pr_idorigem||', pr_idseqttl:'||pr_idseqttl
                  ||', pr_nrcpfope:'||pr_nrcpfope||', pr_nrcpfrep:'||pr_nrcpfrep
                  ||', pr_cdcoptfn:'||pr_cdcoptfn||', pr_cdagetfn:'||pr_cdagetfn
                  ||', pr_nrterfin:'||pr_nrterfin||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdcooper:'||pr_cdcooper||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_vlemprst:'||pr_vlemprst||', pr_qtpreemp:'||pr_qtpreemp
                  ||', pr_vlpreemp:'||pr_vlpreemp||', pr_dtdpagto:'||pr_dtdpagto
                  ||', pr_percetop:'||pr_percetop||', pr_vlrtarif:'||pr_vlrtarif
                  ||', pr_txmensal:'||pr_txmensal||', pr_vltariof:'||pr_vltariof
                  ||', pr_vltaxiof:'||pr_vltaxiof||', pr_idastcjt:'||pr_idastcjt
                  ||', pr_cdcritic:'||pr_cdcritic||', pr_dscritic:'||pr_dscritic;

    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 6
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'INET0002.pc_cria_trans_pend_credito');

    BEGIN
      INSERT INTO
        tbepr_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta             
          ,vlemprestimo         
          ,nrparcelas           
          ,vlparcela            
          ,dtprimeiro_vencto       
          ,vlpercentual_cet     
          ,vltarifa             
          ,vltaxa_mensal        
          ,vliof                
          ,vlpercentual_iof)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_vlemprst
          ,pr_qtpreemp
          ,pr_vlpreemp
          ,pr_dtdpagto
          ,pr_percetop
          ,pr_vlrtarif
          ,pr_txmensal
          ,pr_vltariof
          ,pr_vltaxiof);
    EXCEPTION
      WHEN OTHERS THEN
        --Gravar tabela especifica de log - INC0011323
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1034;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbepr_trans_pend:'||
        ' cdtransacao_pendente:'||vr_cdtranpe||
        ', cdcooper:'||pr_cdcooper||
        ', nrdconta:'||pr_nrdconta||
        ', vlemprestimo:'||pr_vlemprst||
        ', nrparcelas:'||pr_qtpreemp||
        ', vlparcela:'||pr_vlpreemp||
        ', dtprimeiro_vencto:'||pr_dtdpagto||
        ', vlpercentual_cet:'||pr_percetop||
        ', vltarifa:'||pr_vlrtarif||
        ', vltaxa_mensal:'||pr_txmensal||
        ', vliof:'||pr_vltariof||
        ', vlpercentual_iof:'||pr_vltaxiof||
        '. '||sqlerrm;

        RAISE vr_exec_saida;
    END;
    
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 6
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;
    -- Inclui nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'INET0002.pc_cria_trans_pend_credito');

    COMMIT;

    -- Limpa nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic, vr_dscritic);

      --Grava tabela de log - INC0011323
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic in (1034, 9999) THEN
        pr_cdcritic := 0; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(1224);
      END IF;            
        
      ROLLBACK;

    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'INET0002.pc_cria_trans_pend_credito. '||sqlerrm;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 0;
      pr_dscritic := gene0001.fn_busca_critica(1224);

      ROLLBACK; 
      
  END pc_cria_trans_pend_credito;
  
  -- Início Projeto 454 - SM 1 
  -- Procedure de criacao de transacao de resgate de cheque em custódia
  PROCEDURE pc_cria_trans_pend_resgate_cst(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Conta
                                          ,pr_idseqttl    IN crapttl.idseqttl%TYPE             --> Número do Titular
                                          ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do representante legal
                                          ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do operador juridico
                                          ,pr_cdcoptfn    IN tbgen_trans_pend.cdcoptfn%TYPE    --> Cooperativa do Terminal
                                          ,pr_cdagetfn    IN tbgen_trans_pend.cdagetfn%TYPE    --> Agencia do Terminal
                                          ,pr_nrterfin    IN tbgen_trans_pend.nrterfin%TYPE    --> Numero do Terminal Financeiro
                                          ,pr_idastcjt    IN crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                          ,pr_dscheque    IN VARCHAR2                          --> Lista de CMC7s
                                          ,pr_xmllog      IN VARCHAR2                          --> XML com informações de LOG
                                          ,pr_cdcritic    OUT PLS_INTEGER                      --> Código da crítica
                                          ,pr_dscritic    OUT VARCHAR2                         --> Descrição da crítica
                                          ,pr_retxml      IN OUT NOCOPY xmltype                --> Arquivo de retorno do XML
                                          ,pr_nmdcampo    OUT VARCHAR2                         --> Nome do campo com erro
                                          ,pr_des_erro    OUT VARCHAR2) IS                     --> Descricao do Erro

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_resgate_cst
    --  Sistema  : Procedimentos de criacao de transacao de resgate de cheque em custódia
    --  Sigla    : CRED
    --  Autor    : Márcio(Mouts)
    --  Data     : Janeiro/2018.               Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos de criacao de transacao pendente de resgate de cheques
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exc_erro EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dtmvtopg DATE;
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas

    -- Variaveis locais      
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_ret_all_cheques gene0002.typ_split;
    vr_ret_des_cheques gene0002.typ_split;
    vr_dsdocmc7 VARCHAR2(4000);
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Busca detalhes da custódia de cheque
		CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE
		                 ,pr_nrdconta IN crapcst.nrdconta%TYPE
										 ,pr_dsdocmc7 IN crapcst.dsdocmc7%TYPE) IS
			SELECT cst.idcustod
				FROM crapcst cst
			 WHERE cst.cdcooper = pr_cdcooper
			   AND cst.nrdconta = pr_nrdconta
				 AND cst.dsdocmc7 = gene0002.fn_mask(pr_dsdocmc7,'<99999999<9999999999>999999999999:');
      rw_crapcst cr_crapcst%ROWTYPE;
    
  BEGIN
    
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      -- gera excecao
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;                            
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci    => vr_cdagenci
                                       ,pr_nrdcaixa    => vr_nrdcaixa
                                       ,pr_cdoperad    => vr_cdoperad
                                       ,pr_nmdatela    => vr_nmdatela
                                       ,pr_idorigem    => vr_idorigem
                                       ,pr_idseqttl    => pr_idseqttl
                                       ,pr_cdcooper    => pr_cdcooper
                                       ,pr_nrdconta    => pr_nrdconta
                                       ,pr_nrcpfope    => pr_nrcpfope
                                       ,pr_nrcpfrep    => pr_nrcpfrep
                                       ,pr_cdcoptfn    => pr_cdcoptfn
                                       ,pr_cdagetfn    => pr_cdagetfn
                                       ,pr_nrterfin    => pr_nrterfin
                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                       ,pr_cdtiptra    => 18 -- Desconto de Cheque
                                       ,pr_idastcjt    => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe    => vr_cdtranpe
                                       ,pr_dscritic    => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    BEGIN
      INSERT INTO
        tbcst_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta
          ,dtmvtolt
          ,nrcpf_representante)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,sysdate
          ,pr_nrcpfrep);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbcst_trans_pend: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Criando um Array com todos os cheques que vieram como parametro
    vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
    
    FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP

        -- Pega informações do cheque (CMC7 e inconcil)
        vr_ret_des_cheques := gene0002.fn_quebra_string( vr_ret_all_cheques(vr_auxcont), '#');     
				
				-- Pega CMC7
				vr_dsdocmc7 := vr_ret_des_cheques(1);
        
        -- Buscar remessa de cheque
        OPEN cr_crapcst(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dsdocmc7 => vr_dsdocmc7);
        FETCH cr_crapcst INTO rw_crapcst;
  			
        -- Se não encontrou
        IF cr_crapcst%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapcst;
          -- Data para Deposito invalida
          vr_cdcritic := 0;
          vr_dscritic := 'Custódia não encontrada';
          -- Executa RAISE para sair das validações
          RAISE vr_exc_erro;				
        END IF;
        -- Fecha cursor
        CLOSE cr_crapcst;
        
        BEGIN
          INSERT INTO
            tbcst_trans_pend_det(cdtransacao_pendente
                             ,idcustodia)
                       VALUES(vr_cdtranpe          
                             ,rw_crapcst.idcustod);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbcst_trans_pend_det: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
    END LOOP;       
        
    pc_cria_aprova_transpend(pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_idorigem => vr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_cdtiptra => 18 -- Resgate de Cheque
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_resgate_cst: '|| SQLERRM; 
      ROLLBACK;  
  END pc_cria_trans_pend_resgate_cst;
  
    -- Procedure de verificação de necessidade de assinatura conjunta
  PROCEDURE pc_verifica_nec_ass_conjunta(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Contaimento     
                                        ,pr_idastcjt   OUT crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                        ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo de Critica
                                        ,pr_dscritic   OUT crapcri.dscritic%TYPE ) IS
---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_verifica_rep_assinatura
    --  Sistema  : Procedimentos de verificação de necessidade de assinatura conjunta
    --  Sigla    : CRED
    --  Autor    : Márcio(Mouts)
    --  Data     : Janeiro/2018.               Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimento para verificar se para a conta recebida como parâmetro é
    --             necessário assinatura conjunta
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dtmvtopg DATE;
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas

  BEGIN
    BEGIN
      select
             ca.idastcjt
      into
             pr_idastcjt
      from
             crapass ca
      where
             ca.cdcooper = pr_cdcooper
         and ca.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_cdcritic := 9;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exec_saida;        
      WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao selecionar indicador de assinatura conjunta do cooperado. Erro: ' || SQLERRM;        
          RAISE vr_exec_saida;        
    END;
                                               
  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_verifica_rep_assinatura. Erro: '|| SQLERRM; 
      ROLLBACK;  
  END pc_verifica_nec_ass_conjunta;
  
  -- Fim Projeto 454 - SM 1
  -- Procedure de criacao de transacao de aplicacoes
  PROCEDURE pc_cria_trans_pend_aplica(pr_cdagenci  IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                      --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                         --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE            --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE            --> Numero da Conta
                                     ,pr_idoperac  IN tbcapt_trans_pend.tpoperacao%TYPE            --> Identifica tipo da operacao (1 – Cancelamento Aplicacao / 2 – Resgate / 3 – Agendamento Resgate / 4 – Cancelamento Total Agendamento / 5 – Cancelamento Item Agendamento)
                                     ,pr_idtipapl  IN tbcapt_trans_pend.tpaplicacao%TYPE           --> Tipo da aplicacao (A – Antigos Produtos / N – Novos Produtos)
                                     ,pr_nraplica  IN tbcapt_trans_pend.nraplicacao%TYPE           --> Numero da aplicacao
                                     ,pr_cdprodut  IN tbcapt_trans_pend.cdproduto_aplicacao%TYPE   --> Codigo do produto da aplicacao
                                     ,pr_tpresgat  IN tbcapt_trans_pend.tpresgate%TYPE             --> Indicador do tipo de resgate (1 – Parcial / 2 – Total)
                                     ,pr_vlresgat  IN tbcapt_trans_pend.vlresgate%TYPE             --> Valor do resgate
                                     ,pr_nrdocmto  IN tbcapt_trans_pend.nrdocto_agendamento%TYPE   --> Numero de documento do agendamento
                                     ,pr_idtipage  IN tbcapt_trans_pend.tpagendamento%TYPE         --> Identifica o tipo de agendamento (0 – Aplicacao / 1 – Resgate)
                                     ,pr_idperage  IN tbcapt_trans_pend.idperiodo_agendamento%TYPE --> Identifica a periodicidade do agendamento (0 – Unico / 1 – Mensal)
                                     ,pr_qtmesage  IN tbcapt_trans_pend.qtmeses_agendamento%TYPE   --> Quantidade de meses do agendamento
                                     ,pr_dtdiaage  IN tbcapt_trans_pend.nrdia_agendamento%TYPE     --> Dia em que o agendamento deve ser efetivado
                                     ,pr_dtiniage  IN tbcapt_trans_pend.dtinicio_agendamento%TYPE  --> Data de inicio do agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                        --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                    --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 7
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbcapt_trans_pend(
           cdtransacao_pendente  
          ,cdcooper                   
          ,nrdconta                  
          ,tpoperacao                
          ,tpaplicacao               
          ,nraplicacao               
          ,cdproduto_aplicacao         
          ,tpresgate                 
          ,vlresgate                 
          ,nrdocto_agendamento       
          ,tpagendamento             
          ,idperiodo_agendamento
          ,qtmeses_agendamento  
          ,nrdia_agendamento    
          ,dtinicio_agendamento)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idoperac
          ,pr_idtipapl
          ,pr_nraplica
          ,pr_cdprodut
          ,pr_tpresgat
          ,pr_vlresgat
          ,pr_nrdocmto
          ,pr_idtipage
          ,pr_idperage
          ,pr_qtmesage
          ,pr_dtdiaage
          ,pr_dtiniage);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbcapt_trans_pend: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;
    
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 7
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_aplica: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_aplica;

  -- Procedure de criacao de transacao de debitos automaticos
  PROCEDURE pc_cria_trans_pend_deb_aut(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                      ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                      ,pr_cdhisdeb  IN tbconv_trans_pend.cdhist_convenio%TYPE     --> Codigo do historico do convenio
                                      ,pr_idconsum  IN tbconv_trans_pend.iddebito_automatico%TYPE --> Identificacao do debito automatico
                                      ,pr_dshisext  IN tbconv_trans_pend.dshist_debito%TYPE       --> Descricao complementar do historico do debito
                                      ,pr_vlmaxdeb  IN tbconv_trans_pend.vlmaximo_debito%TYPE     --> Valor maximo do debito
                                      ,pr_cdempcon  IN tbconv_trans_pend.cdconven%TYPE            --> Codigo do convenio
                                      ,pr_cdsegmto  IN tbconv_trans_pend.cdsegmento_conven%TYPE   --> Codigo do segmento do convenio
                                      ,pr_dtmvtopg  IN tbconv_trans_pend.dtdebito_fatura%TYPE     --> Data de debito automatico da fatura
                                      ,pr_nrdocmto  IN tbconv_trans_pend.nrdocumento_fatura%TYPE  --> Numero do documento da fatura
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 8
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbconv_trans_pend(
           cdtransacao_pendente   
          ,cdcooper                    
          ,nrdconta                   
          ,tpoperacao                 
          ,cdhist_convenio            
          ,iddebito_automatico        
          ,dshist_debito                
          ,vlmaximo_debito            
          ,cdconven                   
          ,cdsegmento_conven          
          ,dtdebito_fatura            
          ,nrdocumento_fatura )
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idoperac
          ,pr_cdhisdeb
          ,pr_idconsum
          ,pr_dshisext
          ,pr_vlmaxdeb
          ,pr_cdempcon
          ,pr_cdsegmto
          ,pr_dtmvtopg
          ,pr_nrdocmto);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbconv_trans_pend. Erro: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;
   
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 8
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_deb_aut: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_deb_aut;

  -- Procedure de criacao de transacao de folha de pagamento
  PROCEDURE pc_cria_trans_pend_folha(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                    ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_flsolest  IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                    ,pr_indrowid  IN VARCHAR2                                   --> Lista de ROWIDS
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Busca o valor da tarifa
    CURSOR cr_pfp_cfp(pr_rowid VARCHAR2) IS
       SELECT pfp.dtdebito
             ,pfp.vltarapr
             ,pfp.idopdebi
             ,pfp.vllctpag
             ,pfp.qtlctpag
             ,pfp.nrseqpag
             ,pfp.cdempres
             ,folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag) vltarifa
         FROM crapemp emp
             ,crappfp pfp
        WHERE pfp.rowid    = pr_rowid
          AND pfp.cdcooper = emp.cdcooper
          AND pfp.cdempres = emp.cdempres;
    rw_pfp_cfp cr_pfp_cfp%ROWTYPE;
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_indrowid GENE0002.typ_split;
    vr_rowid    VARCHAR2(50);
    vr_dtdebpfp crappfp.dtdebito%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);
    
  BEGIN
    --
    -- Gerar LOG VERLOG
    vr_nrdrowid := NULL;
    vr_dstransa := '9 - Transacao de Folha de Pagamento pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);  
    -- Quebra a string contendo o rowid separado por virgula
    vr_indrowid := gene0002.fn_quebra_string(pr_string => pr_indrowid, pr_delimit => ',');

    -- Para cada registro selecionado, faremos as validacoes necessarias
    FOR vr_index IN 1..vr_indrowid.COUNT() LOOP
      -- ROWID do pagamento
      vr_rowid := vr_indrowid(vr_index);

      -- Busca o valor da tarifa e a data de debito
      OPEN  cr_pfp_cfp(pr_rowid => vr_rowid);
      FETCH cr_pfp_cfp INTO rw_pfp_cfp;
      CLOSE cr_pfp_cfp;

      -- Caso seja a primeira vez guarda a data de debito
      IF vr_dtdebpfp IS NULL THEN
        vr_dtdebpfp := rw_pfp_cfp.dtdebito;
      END IF;

      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 9
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;

      BEGIN
        INSERT INTO
          tbfolha_trans_pend(
             cdtransacao_pendente   
            ,cdcooper                     
            ,nrdconta                    
            ,cdempres                    
            ,nrsequencia_folha           
            ,idestouro                   
            ,vlfolha                       
            ,nrlanctos                   
            ,dtdebito                    
            ,vltarifa                    
            ,idopcao_debito)
          VALUES(
             vr_cdtranpe
            ,pr_cdcooper
            ,pr_nrdconta
            ,rw_pfp_cfp.cdempres
            ,rw_pfp_cfp.nrseqpag
            ,pr_flsolest
            ,rw_pfp_cfp.vllctpag
            ,rw_pfp_cfp.qtlctpag
            ,rw_pfp_cfp.dtdebito
            ,rw_pfp_cfp.vltarapr
            ,rw_pfp_cfp.idopdebi);

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro tbfolha_trans_pend: ' || SQLERRM;
          RAISE vr_exec_saida;
      END;  
      
      pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_idorigem => pr_idorigem
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfrep => pr_nrcpfrep
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdtiptra => 9
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_cdtranpe => vr_cdtranpe
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exec_saida;
      END IF;
      -- Item LOG VERLOG
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'ROWID'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_rowid);   
      
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor da Transacao'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => rw_pfp_cfp.vllctpag);
 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'CPF do Preposto'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => pr_nrcpfrep);   
                                    
    END LOOP;
 
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_folha: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_folha;

  PROCEDURE pc_cria_trans_pend_pacote_tar (pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
																					,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
																					,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
																					,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
																					,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
																					,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
																					,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
																					,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
																					,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
																					,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
																					,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
																					,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
																					,pr_cdcooper  IN tbtarif_pacote_trans_pend.cdcooper%TYPE    --> Codigo da cooperativa
																					,pr_nrdconta  IN tbtarif_pacote_trans_pend.nrdconta%TYPE    --> Numero da Conta
																					,pr_cdpacote  IN tbtarif_pacote_trans_pend.cdpacote%TYPE    --> Cód. pacote de tarifas
																					,pr_dtvigenc  IN tbtarif_pacote_trans_pend.dtinicio_vigencia%TYPE--> Data de inicio de vigencia
																					,pr_dtdiadbt  IN tbtarif_pacote_trans_pend.nrdiadebito%TYPE     --> Dia débito
																					,pr_vlpacote  IN tbtarif_pacote_trans_pend.vlpacote%TYPE
																					,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
																					,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
																					,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 10
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbtarif_pacote_trans_pend(cdtransacao_pendente
                          			 ,cdcooper
				                         ,nrdconta
																 ,cdpacote
																 ,nrdiadebito
																 ,dtinicio_vigencia,
																  vlpacote)
        VALUES(vr_cdtranpe
							,pr_cdcooper
							,pr_nrdconta
							,pr_cdpacote
							,pr_dtdiadbt
							,pr_dtvigenc
							,pr_vlpacote);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbtarif_pacote_trans_pend: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;
   
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 10
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    COMMIT;
		
  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_pacote_tar: '|| SQLERRM; 
      ROLLBACK; 		
	END pc_cria_trans_pend_pacote_tar;

  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_descto(pr_cdcooper    IN tbtransf_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                     ,pr_nrdconta    IN tbtransf_trans_pend.nrdconta%TYPE --> Numero da Conta
                                     ,pr_idseqttl    IN crapttl.idseqttl%TYPE             --> Número do Titular
                                     ,pr_nrcpfrep    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do representante legal
                                     ,pr_cdagenci    IN crapage.cdagenci%TYPE             --> Codigo do PA
                                     ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE             --> Numero do Caixa
                                     ,pr_cdoperad    IN crapope.cdoperad%TYPE             --> Codigo do Operados
                                     ,pr_nmdatela    IN craptel.nmdatela%TYPE             --> Nome da Tela
                                     ,pr_idorigem    IN INTEGER                           --> Origem da solicitacao
                                     ,pr_nrcpfope    IN crapopi.nrcpfope%TYPE             --> Numero do cpf do operador juridico
                                     ,pr_cdcoptfn    IN tbgen_trans_pend.cdcoptfn%TYPE    --> Cooperativa do Terminal
                                     ,pr_cdagetfn    IN tbgen_trans_pend.cdagetfn%TYPE    --> Agencia do Terminal
                                     ,pr_nrterfin    IN tbgen_trans_pend.nrterfin%TYPE    --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt    IN DATE                              --> Data do movimento     
                                     ,pr_idastcjt    IN crapass.idastcjt%TYPE             --> Indicador de Assinatura Conjunta
                                     ,pr_tab_cheques IN dscc0001.typ_tab_cheques          --> Lista de Cheques
                                     ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo de Critica
                                     ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS         --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_descto
    --  Sistema  : Procedimentos de criacao de transacao de desconto de cheque
    --  Sigla    : CRED
    --  Autor    : Lombardi
    --  Data     : Novembro/2016.               Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos de criacao de transacao de desconto de cheque
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dtmvtopg DATE;
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci    => pr_cdagenci
                                       ,pr_nrdcaixa    => pr_nrdcaixa
                                       ,pr_cdoperad    => pr_cdoperad
                                       ,pr_nmdatela    => pr_nmdatela
                                       ,pr_idorigem    => pr_idorigem
                                       ,pr_idseqttl    => pr_idseqttl
                                       ,pr_cdcooper    => pr_cdcooper
                                       ,pr_nrdconta    => pr_nrdconta
                                       ,pr_nrcpfope    => pr_nrcpfope
                                       ,pr_nrcpfrep    => pr_nrcpfrep
                                       ,pr_cdcoptfn    => pr_cdcoptfn
                                       ,pr_cdagetfn    => pr_cdagetfn
                                       ,pr_nrterfin    => pr_nrterfin
                                       ,pr_dtmvtolt    => pr_dtmvtolt
                                       ,pr_cdtiptra    => 12 -- Desconto de Cheque
                                       ,pr_idastcjt    => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe    => vr_cdtranpe
                                       ,pr_dscritic    => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;
      
    FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
      
      BEGIN
        INSERT INTO
          tbdscc_trans_pend(cdtransacao_pendente
                           ,cdcooper
                           ,nrdconta
                           ,cdcmpchq
                           ,cdbanchq
                           ,cdagechq
                           ,nrctachq
                           ,nrcheque
                           ,vlcheque
                           ,dtlibera
                           ,dtemissa
                           ,dsdocmc7
                           ,nrremret)
                     VALUES(vr_cdtranpe          
                           ,pr_cdcooper
                           ,pr_nrdconta
                           ,pr_tab_cheques(idx).cdcmpchq
                           ,pr_tab_cheques(idx).cdbanchq
                           ,pr_tab_cheques(idx).cdagechq
                           ,pr_tab_cheques(idx).nrctachq
                           ,pr_tab_cheques(idx).nrcheque
                           ,pr_tab_cheques(idx).vlcheque
                           ,pr_tab_cheques(idx).dtlibera
                           ,pr_tab_cheques(idx).dtdcaptu
                           ,pr_tab_cheques(idx).dsdocmc7
                           ,nvl(pr_tab_cheques(idx).nrremret,0));
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro tbdscc_trans_pend: ' || SQLERRM;
          RAISE vr_exec_saida;
      END;
      
		END LOOP;
    
      pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_idorigem => pr_idorigem
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfrep => pr_nrcpfrep
                              ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 12 -- Desconto de Cheque
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_cdtranpe => vr_cdtranpe
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;
    
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_descto: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_descto;

  --> Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
  PROCEDURE pc_cria_transacao_operador(pr_cdagenci   IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                      ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                      ,pr_cdoperad   IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                      ,pr_nmdatela   IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                      ,pr_idorigem   IN INTEGER                                      --> Origem da solicitacao
                                      ,pr_idseqttl   IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                      ,pr_cdcooper   IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                      ,pr_nrdconta   IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                      ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep   IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn   IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                      ,pr_cdagetfn   IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                      ,pr_nrterfin   IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt   IN DATE                                         --> Data do movimento     
                                      ,pr_cdtiptra   IN INTEGER                                      --> Codigo do tipo de transação    
                                      ,pr_idastcjt   IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                      ,pr_tab_crapavt OUT CADA0001.typ_tab_crapavt_58 
                                      ,pr_cdtranpe  OUT tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                      ,pr_dscritic  OUT VARCHAR2) IS                                 --> Descrição da crítica       

    /* .............................................................................

     Programa: pc_cria_transacao_operador (Antiga: b1wgen0016.cria_transacao_operador)
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : CADA
     Autor   : Odirlei Busana - AMcom
     Data    : Maio/2015.                  Ultima atualizacao: 03/12/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
     Observacao: -----

     Alteracoes: 07/05/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
        
                 05/08/2015 - Adição do parametro pr_idtitdda (Douglas - Chamado 291387)

                 03/12/2015 - Alteração para o projeto de Ass. Conjunta  (Jean Michel).
     
    ..............................................................................*/ 
    ----------------> CURSORES <-----------------
       
    -- Buscar nome da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
   
    ----------------> VARIAVEIS <-----------------
    vr_exc_saida EXCEPTION;
    vr_idsituac  INTEGER;  
    vr_ind       INTEGER;
    vr_contaresp INTEGER := 0;
    vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo de erro
    vr_dscritic crapcri.dscritic%TYPE; -- Retorno de Erro
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens CADA0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro GENE0001.typ_tab_erro;          --Tabela Erro
   
  BEGIN
      
    --Dados da Cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    
    --Se nao encontrou 
    IF cr_crapcop%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapcop;   
       
       vr_cdcritic:= 794;
       vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapcop;   
          
    CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_idorigem => pr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => 0
                              ,pr_flgerlog => FALSE
                              ,pr_cddopcao => 'C'
                              ,pr_nrdctato => 0
                              ,pr_nrcpfcto => 0
                              ,pr_nrdrowid => NULL
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_tab_bens => vr_tab_bens
                              ,pr_tab_erro => vr_tab_erro
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se existem representantes legais para conta
    IF vr_tab_crapavt.COUNT() <= 0 THEN
      vr_dscritic := 'Nao existem responsaveis legais para a conta informada.';
      RAISE vr_exc_saida;
    END IF; 

    -- Inicializa variavel
    vr_contaresp := 0;

    IF vr_tab_crapavt.COUNT() > 0 THEN
      -- Leitura de registros de avalistas, representantes e procuradores
      FOR i IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
        -- Verifica se ha representante legal
        IF vr_tab_crapavt(i).idrspleg = 1 THEN
          vr_contaresp := vr_contaresp + 1;
        END IF;
      END LOOP;
    END IF;
    IF vr_contaresp = 0 THEN
      vr_dscritic := 'Conta exige cadastramento de responsavel legal.';
      RAISE vr_exc_saida;
    END IF;

    vr_ind := vr_tab_crapavt.FIRST;
    WHILE vr_ind IS NOT NULL LOOP
      -- Operação realizada por responsável da assinatura conjunta
      IF pr_nrcpfrep = vr_tab_crapavt(vr_ind).nrcpfcgc AND
         vr_tab_crapavt(vr_ind).idrspleg = 1 THEN
        vr_idsituac := 5; -- Parcialmente Aprovada
        EXIT;
      ELSE -- Operação realizada por operador 
        vr_idsituac := 1; -- Pendente
      END IF;
      vr_ind := vr_tab_crapavt.NEXT(vr_ind);
    END LOOP;

    BEGIN
      INSERT INTO tbgen_trans_pend(
         cdcooper              
        ,nrdconta              
        ,nrcpf_operador        
        ,nrcpf_representante   
        ,dtmvtolt              
        ,dtregistro_transacao  
        ,hrregistro_transacao  
        ,idorigem_transacao    
        ,tptransacao           
        ,idassinatura_conjunta 
        ,idsituacao_transacao  
        ,cdcoptfn              
        ,cdagetfn              
        ,nrterfin)
      VALUES(
         pr_cdcooper          
        ,pr_nrdconta
        ,pr_nrcpfope
        ,pr_nrcpfrep
        ,pr_dtmvtolt
        ,TRUNC(SYSDATE)
        ,GENE0002.fn_busca_time
        ,pr_idorigem
        ,pr_cdtiptra
        ,NVL(pr_idastcjt,0)
        ,vr_idsituac
        ,pr_cdcoptfn
        ,pr_cdagetfn
        ,pr_nrterfin)RETURNING cdtransacao_pendente INTO pr_cdtranpe;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir registro TBGEN_TRANS_PEND: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    pr_tab_crapavt := vr_tab_crapavt;
          
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF NVL(vr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => NVL(vr_cdcritic,0));
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro no procedimento INET0002.pc_cria_transacao_operador: ' || SQLERRM;      
  END pc_cria_transacao_operador;  
  
  PROCEDURE pc_horario_trans_pend( pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE
                                  ,pr_idorigem  IN INTEGER
                                  ,pr_tab_limite_pend OUT INET0002.typ_tab_limite_pend --Tabelas de retorno de horarios limite transacoes pendente
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_horario_trans_pend
  --  Sistema  : Procedimentos para obter horario limite de aprovacao das transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 10/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para obter horario limite de aprovacao de transacao pendente
  --             1 - Transferencia
  --             2 - Pagamento
  --             3 - Cobranca
  --             4 - TED
  --             5 - Intercooperativa
  --             6 - VR Boleto
  --             7 - Credito Pre-Aprovado
  --             8 - Aplicacao
  --            11 - Debito Auto Facil
  --            12 - Folha Pagamento (Agenda)
  --            13 - Folha Pagamento (Portabilidade)              
  --            14 - Folha Pagamento (Solicitacao Estouro Conta)
  --            15 - Pagamento de tributos federais DARF/DAS
  --            16 - Contrato SMS Cobrança
  --            17 - Cancelamento de Contrato SMS Cobrança
  --            18 - Desconto de Cheque
  --            19 - Folha Pagamento (Cooperativa)
  --            20 - Pagamento de tributos FGTS
  --            21 - Pagamento de tributos DAE
  --
  --
  -- Alteração : 10/10/2017 - Adicionar o horario Folha Pagamento (Coop) - 19
  --                          (Douglas - Chamado 707072)
  --
  --             26/12/2017 - Adicionar validação FGTS/DAE. PRJ406 - FGTS(Odirlei-AMcom)
  --
  --             29/01/2018 - Incluir tratamento para desconto de cheque - SM 454.1 (Márcio - Mouts)
  ---------------------------------------------------------------------------------------------------------------

    --Variaveis Locais
    vr_hrlimini INTEGER; --horario inicio
    vr_hrlimfim INTEGER; --horario fim
    vr_idesthor INTEGER; --indicador estouro horario
    vr_hrlimage VARCHAR2(5); --horario folha agendamento
    vr_hrlimptb VARCHAR2(5); --horario folha portabilidade
    vr_hrlimsol VARCHAR2(5); --horario folha solicitacao Estouro
    vr_hrlimcop VARCHAR2(5); --horario folha cooperativa
    vr_index_limite INTEGER;
    vr_index_limite_pend INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    --Tabela de memória de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  BEGIN
      --Inicializar retorno erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Limpar tabela de memória
    vr_tab_limite.DELETE;
    pr_tab_limite_pend.DELETE;

    --Buscar Horario Operacao
    INET0001.pc_horario_operacao (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                 ,pr_cdagenci => pr_cdagenci  --Agencia do Associado
                                 ,pr_tpoperac => 0            --Tipo de Operacao (0=todos)
                                 ,pr_inpessoa => 2            --Tipo de Pessoa
                                 ,pr_idagenda => 0            --Tipo de agendamento
                                 ,pr_cdtiptra => 0            --Tipo de transferencia
                                 ,pr_tab_limite => vr_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic => vr_cdcritic    --Código do erro
                                 ,pr_dscritic => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --Se encontrou limites
    vr_index_limite:= vr_tab_limite.FIRST;
    WHILE vr_index_limite IS NOT NULL LOOP
      --Criar registro para tabela limite horarios transacoes pendentes
      vr_index_limite_pend:= vr_tab_limite(vr_index_limite).idtpdpag;
      
      CASE 
        WHEN vr_index_limite_pend IN (1,2,3,4) THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra := vr_index_limite_pend; -- Transferência, Pagto Título/Convênio, Cobrança, TED, FGTS, DAE
        WHEN vr_index_limite_pend = 6  THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 20;  -- VR-Boleto
        WHEN vr_index_limite_pend = 7  THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 6;  -- Pré-Aprovado
        WHEN vr_index_limite_pend = 11 THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 8;  -- Débito Automático
        WHEN vr_index_limite_pend = 15 THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 11; -- DARF/DAS
        WHEN vr_index_limite_pend IN (20,21) THEN pr_tab_limite_pend(vr_index_limite_pend).tipodtra := 19; -- FGTS, DAE 
      ELSE
        pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= vr_index_limite;          
      END CASE;
      
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= vr_tab_limite(vr_index_limite).hrinipag;
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_tab_limite(vr_index_limite).hrfimpag;

      --Encontrar proximo registro
      vr_index_limite:= vr_tab_limite.NEXT(vr_index_limite);
    END LOOP;

    --Selecionar Horarios Limites Aplicacao 
    APLI0002.pc_horario_limite( pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem               
                               ,pr_tpvalida => 0 -- Não Valida horario
                               ,pr_hrlimini => vr_hrlimini
                               ,pr_hrlimfim => vr_hrlimfim
                               ,pr_idesthor => vr_idesthor
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    -- Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    ELSE                 
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 8; --Aplicacao
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 7; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= GENE0002.fn_converte_time_data(vr_hrlimini);
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrlimfim);
    END IF;
      
    --Selecionar Horarios Limites Folha de Pagamento 
    FOLH0002.pc_hrlimite(  pr_cdcooper => pr_cdcooper --> Codigo da Cooperativa
                          ,pr_hrlimage => vr_hrlimage --> Horario limite agenda
                          ,pr_hrlimptb => vr_hrlimptb --> Horario limite portabilidade
                          ,pr_hrlimsol => vr_hrlimsol --> Horario limite solicitacao Estouro conta
                          ,pr_cdcritic => vr_cdcritic --> Codigo da critica
                          ,pr_dscritic => vr_dscritic); --> Descricao da critica 
    -- Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 12; --Folha Pagamento Agenda
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '00:00';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimage;
        
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 13; --Folha Pagamento Portabilidade
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '00:00';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimptb;

      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 14; --Folha Pagamento Solicitacao Estouro de conta
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '00:00';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimsol;

      --Criar registro para tabela limite horarios
      vr_hrlimcop := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'FOLHAIB_HOR_LIM_PAG_COOP');
      vr_index_limite_pend:= 19; --Folha Pagamento Cooperativa
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '00:00';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimcop;

    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic:= 'Erro na rotina INET002.pc_horario_trans_pend. '||sqlerrm; 
  END pc_horario_trans_pend;                                

  --> Rotina responsavel pela consulta de ROWID 
  PROCEDURE pc_obtem_rowid_folha(pr_cdcooper  IN crappfp.cdcooper%TYPE     --> Codigo da cooperativa
                                ,pr_cdempres  IN crappfp.cdempres%TYPE     --> Codigo da empresa
                                ,pr_nrseqpag  IN crappfp.nrseqpag%TYPE     --> Sequencia de folha de pagamento
                                ,pr_rowidpag OUT VARCHAR2                  --> ROWID da folha de pagamento
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo de Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao de Critica

     /* .............................................................................

      Programa: pc_obtem_rowid_folha
      Sistema : Rotinas acessadas pelas telas de cadastros Web
      Sigla   : INET
      Autor   : Jean Michel
      Data    : Dezembro/2015.                  Ultima atualizacao: 17/12/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel pela consulta de ROWID de folhas de pagamento.
      Observacao: -----

      Alteracoes:      
     ..............................................................................*/ 
     ----------------> CURSORES <-----------------
    
     -- Buscar nome da cooperativa
     CURSOR cr_crappfp IS
       SELECT crappfp.rowid
         FROM crappfp 
        WHERE crappfp.cdcooper = pr_cdcooper
          AND crappfp.cdempres = pr_cdempres
          AND crappfp.nrseqpag = pr_nrseqpag;

     rw_crappfp cr_crappfp%ROWTYPE;
    
     ----------------> VARIAVEIS <-----------------
     vr_exc_saida EXCEPTION;
     vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo de erro
     vr_dscritic crapcri.dscritic%TYPE; -- Retorno de Erro
    
   BEGIN
       
     OPEN cr_crappfp;

     FETCH cr_crappfp INTO rw_crappfp;

     IF cr_crappfp%NOTFOUND THEN
       CLOSE cr_crappfp;
       vr_dscritic := 'Registro de folha de pagamento inexistente.';
       RAISE vr_exc_saida;
     ELSE
       CLOSE cr_crappfp;
       pr_rowidpag := TO_CHAR(rw_crappfp.rowid);
     END IF;   
     
   EXCEPTION
     WHEN vr_exc_saida THEN

       pr_cdcritic := NVL(vr_cdcritic,0);
      
       IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
       ELSE	
         pr_dscritic := vr_dscritic;
       END IF;
         
       ROLLBACK;
     WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro no procedimento INET0002.pc_obtem_rowid_folha: ' || SQLERRM;      
   END pc_obtem_rowid_folha; 
         
   PROCEDURE pc_busca_trans_pend(pr_cdcooper IN  crapcop.cdcooper%TYPE --> Código da Cooperativa
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE --> Numero conta
                                ,pr_idseqttl IN  crapsnh.idseqttl%TYPE --> Sequencia de Titularidade
                                ,pr_nrcpfope IN  crapsnh.nrcpfcgc%TYPE --> CPF operador
                                ,pr_cdagenci IN  crapage.cdagenci%TYPE --> Numero PA
                                ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE --> Data Movimentacao
                                ,pr_cdorigem IN  INTEGER               --> Id de origem
                                ,pr_cdtransa IN  tbgen_trans_pend.cdtransacao_pendente%TYPE DEFAULT 0 --> Código da transação pendente
                                ,pr_insittra IN  INTEGER               --> Id de situacao da transacao                                
                                ,pr_dtiniper IN  DATE                  --> Data Inicio
                                ,pr_dtfimper IN  DATE                  --> Data final
                                ,pr_nrregist IN  INTEGER               --> Numero da qtd de registros da pagina
                                ,pr_nriniseq IN  INTEGER               --> Numero do registro inicial
                                ,pr_clobxmlc OUT CLOB                  --> XML com informações
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_busca_trans_pend
     Sistema : Transacoes Pendentes
     Sigla   : INET
     Autor   : Jorge Hamaguchi
     Data    : Dezembro/2015.                  Ultima atualizacao: 01/04/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para buscar Transacoes pendentes.

     Observacao: -----

     Alteração : 25/02/2016 - Remover obrigatoriedade de crapcti nas TEDs (Marcos-Supero)
     
				         21/06/2016 - Ajuste para incluir alterações perdidas na realização de merge entre versões
							               (Adriano).
                             
                 29/06/2016 - Utilizar rotina generico para busca registro na craptab
                              (Adriano).             

                 19/07/2016 - Ajustes para o Prj. 338 - Pagamento de DARF/DAS (Jean Michel).             

	               04/08/2016 - Ajustes realizado na tela conforme solicitado no chamado
                              442860 (Kelvin).

                 02/09/2016 - Ajustada para retornar os aprovadores da transação que
                              está sendo consultada., SD 514239 (Jean Michel).                          
                 
                 28/11/2016 - Inclusao dos transaçoes pendentes 16 e 17. 
                              PRJ319 - SMS Cobrança (Odirlei-AMcom)                                   

                 30/01/2017 - Adição do campo idsituacao_transacao no xml de retorno para utilização no
                              Cecred Mobile (Dionathan)
                              
                 01/04/2017 - Remover o campo Percentual do IOF. (James)              
    ..............................................................................*/
    DECLARE
     
      -- Buscar nome da cooperativa
      CURSOR cr_crapcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop
      FROM   crapcop cop
      WHERE  cop.cdagectl = pr_cdagectl;
    
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.idastcjt,
             crapass.nmprimtl
      FROM   crapass
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass  cr_crapass%ROWTYPE;
      rw_crapass2 cr_crapass%ROWTYPE;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                        ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                        ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
      SELECT crapsnh.nrcpfcgc
      FROM   crapsnh
      WHERE  crapsnh.cdcooper = pr_cdcooper
      AND    crapsnh.nrdconta = pr_nrdconta
      AND    crapsnh.idseqttl = pr_idseqttl
      AND    crapsnh.tpdsenha = 1; --Internet
      
      --Selecionar primeira senha tiva
      CURSOR cr_crapsnh_seq (pr_cdcooper IN crapsnh.cdcooper%TYPE
                            ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.idseqttl
      FROM   crapsnh
      WHERE  crapsnh.cdcooper = pr_cdcooper
      AND    crapsnh.nrdconta = pr_nrdconta
      AND    crapsnh.cdsitsnh = 1
      AND    crapsnh.tpdsenha = 1; --Internet
              
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                       ,pr_nrdconta IN crapavt.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.nrdctato,
             crapavt.nmdavali
      FROM   crapavt
      WHERE  crapavt.cdcooper = pr_cdcooper
      AND    crapavt.nrdconta = pr_nrdconta
      AND    crapavt.nrcpfcgc = pr_nrcpfcgc
      AND    crapavt.tpctrato = 6; -- Juridico
        
      CURSOR cr_tbgen_trans_pend (pr_cdcooper IN tbgen_trans_pend.cdcooper%TYPE
                                 ,pr_nrdconta IN tbgen_trans_pend.nrdconta%TYPE
                                 ,pr_cdtransa IN tbgen_trans_pend.cdtransacao_pendente%TYPE
                                 ,pr_dtiniper IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                 ,pr_dtfimper IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                 ,pr_insittra IN tbgen_trans_pend.idsituacao_transacao%TYPE) IS
        SELECT dados.nrdconta nrdconta
              ,dados.tptransacao tptransacao
              ,dados.cdtransacao_pendente cdtransacao_pendente
              ,dados.dtregistro_transacao dtregistro_transacao
              ,dados.hrregistro_transacao hrregistro_transacao
              ,dados.idorigem_transacao idorigem_transacao
              ,dados.dtmvtolt dtmvtolt
              ,dados.idsituacao_transacao idsituacao_transacao
              ,dados.dtalteracao_situacao dtalteracao_situacao
              ,dados.dscritica dscritica
              ,dados.dtcritica dtcritica
              ,dados.nrcpf_representante nrcpf_representante
              ,dados.nrcpf_operador nrcpf_operador
              ,nvl(dados.ord1,0) + nvl(dados.ord2,0) + nvl(dados.ord3,0) + nvl(dados.ord4,0) + 
               nvl(dados.ord5,0) + nvl(dados.ord6,0) + nvl(dados.ord7,0) + nvl(dados.ord8,0) + 
               nvl(dados.ord9,0) 
               -- Início SM 454.1
               + nvl(dados.ord11,0)
               -- Fim SM 454.1
               orderby
          FROM (SELECT gtp.nrdconta nrdconta
                      ,gtp.tptransacao tptransacao
                      ,gtp.cdtransacao_pendente cdtransacao_pendente
                      ,gtp.dtregistro_transacao dtregistro_transacao
                      ,gtp.hrregistro_transacao hrregistro_transacao
                      ,gtp.idorigem_transacao idorigem_transacao
                      ,gtp.dtmvtolt dtmvtolt
                      ,gtp.idsituacao_transacao idsituacao_transacao
                      ,gtp.dtalteracao_situacao dtalteracao_situacao
                      ,gtp.dscritica dscritica
                      ,gtp.dtcritica dtcritica
                      ,gtp.nrcpf_representante nrcpf_representante
                      ,gtp.nrcpf_operador nrcpf_operador
                      ,(SELECT DECODE(ttp.idagendamento,1,1,0)
                          FROM tbtransf_trans_pend ttp
                         WHERE ttp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord1
                      ,(SELECT DECODE(ptp.idagendamento,1,1,0)
                          FROM tbpagto_trans_pend ptp
                         WHERE ptp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord2    
                      ,(SELECT DECODE(stp.idagendamento,1,1,0)
                          FROM tbspb_trans_pend stp
                         WHERE stp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord3   
                      ,(SELECT 1
                          FROM tbepr_trans_pend etp
                         WHERE etp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord4    
                      ,(SELECT DECODE(ctp.tpoperacao,1,1,0)
                          FROM tbcapt_trans_pend ctp
                         WHERE ctp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord5    
                      ,(SELECT DECODE(ctp.tpoperacao,2,1,0)
                          FROM tbcapt_trans_pend ctp
                         WHERE ctp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord6      
                      ,(SELECT 1
                          FROM tbconv_trans_pend vtp
                         WHERE vtp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord7 
                      ,(SELECT 1
                          FROM tbtarif_pacote_trans_pend tptp
                         WHERE tptp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord8  
                      ,(SELECT 1
                          FROM tbpagto_darf_das_trans_pend darf
                         WHERE darf.cdtransacao_pendente = gtp.cdtransacao_pendente) ord9   
                      ,(SELECT 1
                          FROM tbdscc_trans_pend dscc
                         WHERE dscc.cdtransacao_pendente = gtp.cdtransacao_pendente) ord10   
                         -- Início SM 454.1
                      ,(SELECT 1
                          FROM tbcst_trans_pend dcst
                         WHERE dcst.cdtransacao_pendente = gtp.cdtransacao_pendente) ord11  
                      -- Fim SM 454.1    
                  FROM tbgen_trans_pend gtp
                 WHERE gtp.cdcooper = pr_cdcooper
                   AND gtp.nrdconta = pr_nrdconta
                   AND ((pr_cdtransa <> 0 AND gtp.cdtransacao_pendente = pr_cdtransa) OR 
                       (pr_cdtransa =  0 AND gtp.idsituacao_transacao <> 2
                   AND ((pr_insittra = 15 AND (gtp.idsituacao_transacao = 1 OR /*Pendente*/ gtp.idsituacao_transacao = 5))
                                OR (gtp.idsituacao_transacao = DECODE(pr_insittra,0,gtp.idsituacao_transacao,pr_insittra)))))
                 ORDER BY ord1) dados
                ORDER BY orderby DESC
                        ,dados.tptransacao;                                 
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;  
        
      --Tipo Transacao 1,3,5 (Transferencia)
      CURSOR cr_tbtransf_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbtransf_trans_pend.cdagencia_coop_destino 
            ,tbtransf_trans_pend.nrconta_destino
            ,tbtransf_trans_pend.idagendamento
            ,tbtransf_trans_pend.vltransferencia
            ,tbtransf_trans_pend.dtdebito
      FROM   tbtransf_trans_pend 
      WHERE  tbtransf_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbtransf_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbtransf_trans_pend cr_tbtransf_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 2 (Pagamento)
      CURSOR cr_tbpagto_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_trans_pend.tppagamento
            ,tbpagto_trans_pend.dscedente
            ,tbpagto_trans_pend.idagendamento
            ,tbpagto_trans_pend.vlpagamento
            ,tbpagto_trans_pend.dtdebito
            ,tbpagto_trans_pend.dscodigo_barras
            ,tbpagto_trans_pend.dslinha_digitavel
            ,tbpagto_trans_pend.dtvencimento
            ,tbpagto_trans_pend.vldocumento
            ,tbpagto_trans_pend.idtitulo_dda
      FROM   tbpagto_trans_pend 
      WHERE  tbpagto_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbpagto_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));        
      rw_tbpagto_trans_pend cr_tbpagto_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 4 (TED)
      CURSOR cr_tbspb_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbspb_trans_pend.cdcooper 
            ,tbspb_trans_pend.nrdconta
            ,tbspb_trans_pend.cdbanco_favorecido
            ,tbspb_trans_pend.cdagencia_favorecido
            ,tbspb_trans_pend.nrconta_favorecido
            ,tbspb_trans_pend.dtdebito
            ,tbspb_trans_pend.vlted
            ,tbspb_trans_pend.idagendamento
            ,tbspb_trans_pend.nrispb_banco_favorecido
            ,tbspb_trans_pend.dshistorico
            ,tbspb_trans_pend.dscodigo_identificador
            ,tbspb_trans_pend.cdfinalidade
            ,tbspb_trans_pend.nrcpfcnpj_favorecido
            ,tbspb_trans_pend.nmtitula_favorecido
      FROM   tbspb_trans_pend 
      WHERE  tbspb_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbspb_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbspb_trans_pend cr_tbspb_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 6 (Credito Pre-Aprovado)
      CURSOR cr_tbepr_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbepr_trans_pend.cdcooper
            ,tbepr_trans_pend.vlemprestimo
            ,tbepr_trans_pend.dtprimeiro_vencto
            ,tbepr_trans_pend.nrparcelas
            ,tbepr_trans_pend.vlparcela
            ,tbepr_trans_pend.vlpercentual_cet
            ,tbepr_trans_pend.vltarifa
            ,tbepr_trans_pend.vltaxa_mensal
            ,tbepr_trans_pend.vliof
            ,tbepr_trans_pend.vlpercentual_iof
      FROM   tbepr_trans_pend 
      WHERE  tbepr_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbepr_trans_pend cr_tbepr_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 7 (Aplicacao)
      CURSOR cr_tbcapt_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbcapt_trans_pend.tpoperacao
            ,tbcapt_trans_pend.tpaplicacao
            ,tbcapt_trans_pend.nraplicacao
            ,tbcapt_trans_pend.vlresgate
            ,tbcapt_trans_pend.dtinicio_agendamento
            ,tbcapt_trans_pend.nrdia_agendamento
            ,tbcapt_trans_pend.qtmeses_agendamento
            ,tbcapt_trans_pend.nrdocto_agendamento
            ,tbcapt_trans_pend.tpagendamento
            ,tbcapt_trans_pend.tpresgate
            ,tbcapt_trans_pend.idperiodo_agendamento
      FROM   tbcapt_trans_pend 
      WHERE  tbcapt_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbcapt_trans_pend cr_tbcapt_trans_pend%ROWTYPE;
  	
      --Tipo Transacao 8 (Debito Automatico)
      CURSOR cr_tbconv_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbconv_trans_pend.cdcooper
            ,tbconv_trans_pend.tpoperacao
            ,tbconv_trans_pend.cdsegmento_conven
            ,tbconv_trans_pend.cdconven
            ,tbconv_trans_pend.cdhist_convenio
            ,tbconv_trans_pend.nrdocumento_fatura
            ,tbconv_trans_pend.dtdebito_fatura
            ,tbconv_trans_pend.iddebito_automatico
            ,tbconv_trans_pend.dshist_debito
            ,tbconv_trans_pend.vlmaximo_debito
      FROM   tbconv_trans_pend 
      WHERE  tbconv_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbconv_trans_pend.dtdebito_fatura BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbconv_trans_pend cr_tbconv_trans_pend%ROWTYPE;
      	  
      --Tipo Transacao 9 (Folha de Pagamento)
      CURSOR cr_tbfolha_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbfolha_trans_pend.vlfolha
            ,tbfolha_trans_pend.dtdebito
            ,tbfolha_trans_pend.nrlanctos
            ,tbfolha_trans_pend.idestouro
            ,tbfolha_trans_pend.vltarifa
      FROM   tbfolha_trans_pend 
      WHERE  tbfolha_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbfolha_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbfolha_trans_pend cr_tbfolha_trans_pend%ROWTYPE;

      --Tipo Transacao 10 - Cursor para buscar a transação de adesão de pacote de tarifa pendente
			CURSOR cr_pactar (pr_cdtranpe IN tbtarif_pacote_trans_pend.cdtransacao_pendente%TYPE)IS
			  SELECT tpend.vlpacote
				      ,tpend.dtinicio_vigencia dtinivig
				      ,(tpac.cdpacote || ' - ' || tpac.dspacote) dspacote
							,tpend.nrdiadebito dtdiadeb
				  FROM tbtarif_pacote_trans_pend tpend
					    ,tbtarif_pacotes tpac
				 WHERE tpend.cdtransacao_pendente = pr_cdtranpe			
				   AND tpac.cdpacote = tpend.cdpacote;
			rw_pactar cr_pactar%ROWTYPE;

      --Tipo Transacao 11 (DARF/DAS)
      CURSOR cr_tbpagto_darf_das_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_darf_das_trans_pend.*
      FROM   tbpagto_darf_das_trans_pend
      WHERE  tbpagto_darf_das_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND tbpagto_darf_das_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper)
         OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbpagto_darf_das_trans_pend cr_tbpagto_darf_das_trans_pend%ROWTYPE;
           
      --Tipo Transacao 12 (Desconto de Cheque)
      CURSOR cr_tbdscc_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT x.*
        FROM (SELECT SUM(d.vlcheque) vltotchq
                    ,count(1) qtcheque
                    ,g.dtmvtolt
                FROM tbdscc_trans_pend d
                    ,tbgen_trans_pend g
               WHERE d.cdtransacao_pendente = pr_cddoitem
                 AND g.cdtransacao_pendente = d.cdtransacao_pendente
                 AND ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND g.dtmvtolt BETWEEN  pr_dtiniper AND pr_dtfimper)
                  OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL))
            GROUP BY g.dtmvtolt) x
           WHERE x.qtcheque > 0;
      rw_tbdscc_trans_pend cr_tbdscc_trans_pend%ROWTYPE;
      
      --Tipo Transacao 12 (Desconto de Cheque)
      CURSOR cr_tbdscc_cheques(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT to_char(dtlibera,'DD/MM/RRRR') dtlibera
            ,to_char(dtemissa,'DD/MM/RRRR') dtemissa
            ,cdbanchq
            ,cdagechq
            ,nrctachq
            ,nrcheque
            ,to_char(vlcheque,'fm999g999g990d00') vlcheque
        FROM tbdscc_trans_pend
       WHERE cdtransacao_pendente = pr_cddoitem;
      
      --Tipo Transacao 14/15 (FGTS/DAE)
      CURSOR cr_tbtrib_pend (pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT trib.*
      FROM   tbpagto_tributos_trans_pend trib
      WHERE  trib.cdtransacao_pendente = pr_cddoitem
			  AND ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND trib.dtdebito BETWEEN  pr_dtiniper AND pr_dtfimper)
				 OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL));
      rw_tbtrib_pend cr_tbtrib_pend%ROWTYPE;
      --Cadastro de Transferencias pela Internet.
      CURSOR cr_crapcti( pr_cdcooper IN crapcti.cdcooper%TYPE,
                         pr_nrdconta IN crapcti.nrdconta%TYPE,
                         pr_cddbanco IN crapcti.cddbanco%TYPE,
                         pr_cdageban IN crapcti.cdageban%TYPE,
                         pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS  
      SELECT crapcti.nmtitula, crapcti.nrcpfcgc 
      FROM   crapcti
      WHERE  crapcti.cdcooper = pr_cdcooper
      AND    crapcti.nrdconta = pr_nrdconta
      AND	   crapcti.cddbanco = pr_cddbanco
      AND	   crapcti.cdageban = pr_cdageban 
      AND	   crapcti.nrctatrf = pr_nrctatrf;
      rw_crapcti cr_crapcti%ROWTYPE;
      
      CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                        ,pr_nrdconta IN craprda.nrdconta%TYPE
                        ,pr_nraplica IN craprda.nraplica%TYPE) IS
      SELECT craprda.vlaplica 
      FROM   craprda 
      WHERE  craprda.cdcooper = pr_cdcooper 
      AND    craprda.nrdconta = pr_nrdconta 
      AND    craprda.nraplica = pr_nraplica;
      
      CURSOR cr_crapopi (pr_cdcooper IN crapopi.cdcooper%TYPE
                        ,pr_nrdconta IN crapopi.nrdconta%TYPE
                        ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad 
      FROM   crapopi
      WHERE  crapopi.cdcooper = pr_cdcooper 
      AND    crapopi.nrdconta = pr_nrdconta 
      AND    crapopi.nrcpfope = pr_nrcpfope;
      
      --Cadastro de convenios.
      CURSOR cr_crapcon( pr_cdcooper IN crapcon.cdcooper%TYPE,
                         pr_cdsegmto IN crapcon.cdsegmto%TYPE,
                         pr_cdempcon IN crapcon.cdempcon%TYPE) IS
      SELECT crapcon.nmrescon 
      FROM   crapcon
      WHERE  crapcon.cdcooper = pr_cdcooper 
      AND    crapcon.cdsegmto = pr_cdsegmto 
      AND    crapcon.cdempcon = pr_cdempcon;
      
      -- Consulta autorizacao de debitos
      CURSOR cr_autodeb(pr_cdcooper IN crapatr.cdcooper%TYPE,
                       pr_nrdconta IN crapatr.nrdconta%TYPE,
                       pr_cdhistor IN crapatr.cdhistor%TYPE,
                       pr_cdrefere IN crapatr.cdrefere%TYPE,
                       pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
      SELECT crapcon.nmrescon, craplau.vllanaut 
      FROM   crapatr, crapcon, craplau
      WHERE  crapatr.cdcooper = pr_cdcooper 
      AND    crapatr.nrdconta = pr_nrdconta 
      AND    crapatr.cdhistor = pr_cdhistor 
      AND    crapatr.cdrefere = pr_cdrefere
      AND    crapatr.tpautori <> 0 
      AND    crapcon.cdcooper = crapatr.cdcooper 
      AND    crapcon.cdsegmto = crapatr.cdsegmto 
      AND    crapcon.cdempcon = crapatr.cdempcon 
      AND    craplau.cdcooper = crapatr.cdcooper 
      AND    craplau.nrdconta = crapatr.nrdconta 
      AND    craplau.cdhistor = crapatr.cdhistor 
      AND    craplau.nrdocmto = crapatr.cdrefere 
      AND    craplau.dtmvtopg = pr_dtmvtopg
      AND    craplau.insitlau = 1;
      
      CURSOR cr_crapban1 (pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.cdbccxlt,
             crapban.nmextbcc
      FROM   crapban
      WHERE  crapban.cdbccxlt = pr_cdbccxlt;
      
      CURSOR cr_crapban2 (pr_nrispbif IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.cdbccxlt,
             crapban.nmextbcc
      FROM   crapban
      WHERE  crapban.nrispbif = pr_nrispbif;
      
      CURSOR cr_crapagb (pr_cddbanco IN crapagb.cddbanco%TYPE 
                        ,pr_cdageban IN crapagb.cdageban%TYPE) IS
      SELECT gene0007.fn_caract_acento(crapagb.nmageban,1) nmageban 
      FROM   crapagb
      WHERE  crapagb.cddbanco = pr_cddbanco 
      AND    crapagb.cdageban = pr_cdageban;
      
      CURSOR cr_tbaprova(pr_cdtransa IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE
                        ,pr_nrcpfope IN tbgen_aprova_trans_pend.nrcpf_responsavel_aprov%TYPE) IS
        SELECT cdtransacao_pendente
          FROM tbgen_aprova_trans_pend
         WHERE cdtransacao_pendente = pr_cdtransa
           AND nrcpf_responsavel_aprov = pr_nrcpfope;

      rw_tbaprova cr_tbaprova%ROWTYPE;     

      CURSOR cr_tbaprova_rep(pr_cdtransa IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT apr.cdtransacao_pendente
              ,apr.nrcpf_responsavel_aprov AS cpf_responsavel
              ,apr.idsituacao_aprov idsituacao
              ,DECODE(apr.idsituacao_aprov,1,'Pendente',2,'Aprovada',3,'Reprovada',4,'Expirada','Sem Situacao') AS situacao
          FROM tbgen_aprova_trans_pend apr
         WHERE cdtransacao_pendente = pr_cdtransa;

      rw_tbaprova_rep cr_tbaprova_rep%ROWTYPE;

      --> Contrato de SMS - Transacao 16
      CURSOR cr_sms_trans_pend (pr_cdtransa IN tbcobran_sms_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT pen.vlservico
              ,pen.dtassinatura dtassinatura
              ,(pct.idpacote || ' - ' || pct.dspacote) dspacote
          FROM tbcobran_sms_trans_pend pen
              ,tbcobran_sms_pacotes pct
         WHERE pct.idpacote = pen.idpacote
           AND pen.cdtransacao_pendente = pr_cdtransa;	

      rw_sms_trans_pend cr_sms_trans_pend%ROWTYPE;
      
      --> Recarga Celular - Transacao 13
      CURSOR cr_tbrecarga_trans_pend (pr_cdtransa IN tbrecarga_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT ('(' || ope.nrddd || ') ' || gene0002.fn_mask(ope.nrcelular,'99999-9999')) telefone
              ,ope.vlrecarga
              ,ope.dtrecarga
              ,ope.dttransa
              ,pdt.nmproduto
              ,pen.tprecarga
          FROM tbrecarga_trans_pend pen
              ,tbrecarga_produto pdt
              ,tbrecarga_operacao ope
         WHERE ope.idoperacao = pen.idoperacao
           AND pdt.cdoperadora = ope.cdoperadora
           AND pdt.cdproduto = ope.cdproduto
           AND pen.cdtransacao_pendente = pr_cdtransa;	
      
      rw_tbrecarga_trans_pend cr_tbrecarga_trans_pend%ROWTYPE;
      --
      -- buscar o numero do CPF
      CURSOR cr_crapsnh2 (prc_cdcooper crapsnh.cdcooper%type,
                         prc_nrdconta crapsnh.nrdconta%type,
                         prc_idseqttl crapsnh.idseqttl%type)IS
        SELECT c.nrcpfcgc,
               c.vllimweb
          FROM crapsnh c
         WHERE c.cdcooper = prc_cdcooper
           AND c.nrdconta = prc_nrdconta
           AND c.idseqttl = prc_idseqttl
           AND c.tpdsenha = 1 -- INTERNET
           ;
      --
      CURSOR cr_crapopi2 (prc_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                         ,prc_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                         ,prc_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Operador
                         ) IS
        SELECT 1
          FROM crapopi opi
         WHERE opi.cdcooper = prc_cdcooper
           AND opi.nrdconta = prc_nrdconta
           AND opi.nrcpfope = prc_nrcpfope
          ;       
          
          --Início SM 454.1
      --Tipo Transacao 18 (Resgate de Cheque em Custódia)
      CURSOR cr_tbcst_trans_pend_det(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT x.*
        FROM (SELECT SUM(c.vlcheque) vltotchq
                    ,count(1) qtcheque
                    ,g.dtmvtolt
                FROM tbcst_trans_pend_det d
                    ,tbgen_trans_pend g
                    ,crapcst c
               WHERE d.cdtransacao_pendente = pr_cddoitem
                 AND g.cdtransacao_pendente = d.cdtransacao_pendente
                 and c.idcustod             = d.idcustodia
                 AND ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND g.dtmvtolt BETWEEN  pr_dtiniper AND pr_dtfimper)
                  OR  (pr_dtiniper IS NULL AND pr_dtfimper IS NULL))
            GROUP BY g.dtmvtolt) x
           WHERE x.qtcheque > 0;
      rw_tbcst_trans_pend_det cr_tbcst_trans_pend_det%ROWTYPE;
      
      --Tipo Transacao 18 (Resgate de Cheque em Custódia
      CURSOR cr_tbcst_cheques(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT to_char(c.dtlibera,'DD/MM/RRRR') dtlibera
            ,to_char(c.dtemissa,'DD/MM/RRRR') dtemissa
            ,c.cdbanchq
            ,c.cdagechq
            ,c.nrctachq
            ,c.nrcheque
            ,to_char(c.vlcheque,'fm999g999g990d00') vlcheque
        FROM tbcst_trans_pend_det d
            ,crapcst c
       WHERE cdtransacao_pendente = pr_cddoitem
         and c.idcustod           = d.idcustodia      
       ;
      
--Fim SM 454.1    
      
      --Tipo Transacao 19 (Borderô Desconto de Titulo)
      CURSOR cr_tbdsct_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT x.*
      FROM ( SELECT SUM(d.vltitulo) vltotbdt
                   ,count(1) qttitulo
                   ,g.dtmvtolt
             FROM   tbdsct_trans_pend d
                   ,tbgen_trans_pend g
             WHERE  d.cdtransacao_pendente = pr_cddoitem
             AND    g.cdtransacao_pendente = d.cdtransacao_pendente
             AND    ((pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND g.dtmvtolt BETWEEN  pr_dtiniper AND pr_dtfimper) OR
                     (pr_dtiniper IS NULL AND pr_dtfimper IS NULL))
             GROUP BY g.dtmvtolt) x
      WHERE  x.qttitulo > 0;
      rw_tbdsct_trans_pend cr_tbdsct_trans_pend%ROWTYPE;   

      --Tipo Transacao 20
      CURSOR cr_tbctd_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT *
        FROM tbctd_trans_pend trec
        WHERE trec.cdtransacao_pendente  = pr_cddoitem;
        rw_tbctd_trans_pend cr_tbctd_trans_pend%ROWTYPE;      

      
      --Tipo Transacao 21 (Emprestimos/Financiamentos)
      CURSOR cr_pend_efet_proposta(pr_cddoitem IN tbepr_trans_pend_efet_proposta.cdtransacao_pendente%TYPE) IS  
      SELECT pep.cdcooper
            ,wepr.vlemprst
            ,wepr.dtdpagto AS dtprimeiro_vencto
            ,wepr.qtpreemp AS nrparcelas
            ,wepr.vlpreemp AS vlparcela
            ,wepr.percetop AS vlpercentual_cet
            ,sim.vlrtarif AS vltarifa
            ,wepr.txmensal AS vltaxa_mensal
            ,sim.vliofepr AS vliof
            ,NULL vlpercentual_iof
       FROM  tbepr_trans_pend_efet_proposta pep,
             crawepr wepr,
             crapsim sim
       WHERE pep.cdtransacao_pendente = pr_cddoitem
         AND pep.cdcooper = wepr.cdcooper
         AND pep.nrdconta = wepr.nrdconta
         AND pep.nrctremp = wepr.nrctremp
         AND wepr.nrsimula = sim.nrsimula(+)
         AND wepr.nrdconta = sim.nrdconta(+)
         AND wepr.cdcooper = sim.cdcooper(+);
      --/
      rw_pend_efet_proposta cr_pend_efet_proposta%ROWTYPE;
      --
      --

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      --
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      --Variáveis locais
      vr_nriniseq INTEGER := 0;
      vr_idastcjt NUMBER := 0;
      vr_nrcpfcgc NUMBER(14) := 0;
      vr_nrcpfgui VARCHAR2(100) := '';
      vr_nrdctato crapavt.nrdctato%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_dstransa VARCHAR2(500);
      vr_indiacao NUMBER := 0;
      vr_tptranpe NUMBER := 0;
      vr_cdtranpe NUMBER := 0;
      vr_dsvltran VARCHAR2(20);
      vr_dsdtefet VARCHAR2(20);
      vr_dsdescri VARCHAR2(100);
      vr_dstptran VARCHAR2(100);
      vr_dsagenda VARCHAR2(10);
      vr_nrindice NUMBER := 0;
      vr_nmagenda VARCHAR2(100);
      vr_dttranpe VARCHAR2(10);
      vr_hrtranpe VARCHAR2(8);
      vr_dsoritra VARCHAR2(50);
      vr_dtmvttra VARCHAR2(10);
      vr_idsittra NUMBER;
      vr_dssittra VARCHAR2(50);
      vr_dtreptra VARCHAR2(10);
      vr_dtexctra VARCHAR2(10);
      vr_dtexptra VARCHAR2(10);
      vr_dscritra VARCHAR2(500);
      vr_dtvalida VARCHAR2(10);
      vr_vlaplica NUMBER(10,2) := 0;
      vr_nrdolote NUMBER := 0;
      vr_cdhistor NUMBER := 0;
      vr_nmrescon VARCHAR2(500);
      vr_vllanaut NUMBER(10,2) := 0;
      vr_nmextbcc crapban.nmextbcc%TYPE;
      vr_cddbanco NUMBER := 0;
      vr_nrdocmto VARCHAR2(100);
      vr_qttotpen NUMBER := 0;
      vr_vlasomar NUMBER(10,2) := 0;
      vr_vltotpen NUMBER(10,2) := 0;
      vr_dtaltera VARCHAR2(10);
      vr_idseqttl crapsnh.idseqttl%TYPE; 
      vr_labnmage VARCHAR2(100);
      va_existe_operador NUMBER(1);
      va_nrcpfcgc crapsnh.nrcpfcgc%type;
      va_vllimweb crapsnh.vllimweb%type;
      vr_vllimpgo crapsnh.vllimpgo%type;
      vr_vllimtrf crapsnh.vllimtrf%type;
      vr_vllimted crapsnh.vllimted%type;
      vr_vllimvrb crapsnh.vllimvrb%type;
	    vr_stsnrcal BOOLEAN;
	    vr_inpessoa INTEGER;
      vr_nrcntato tbctd_trans_pend.nrcontrato%TYPE; -- PJ470
      vr_dsdata_debito VARCHAR2(1000); -- PJ470
      
      --Pagamento
      vr_cdcopdes VARCHAR2(100);
      vr_nrcondes VARCHAR2(100);
      vr_dtdebito VARCHAR2(100);
      vr_nmcednte VARCHAR2(100);
      vr_nrcodbar VARCHAR2(100);
      vr_dslindig VARCHAR2(100);
      vr_dtvencto VARCHAR2(100);
      vr_vldocmto varCHAR2(100);
      vr_identdda varCHAR2(100);
      
      --TED
      vr_nmbanfav VARCHAR2(100);
      vr_nmdoispb VARCHAR2(100);
      vr_nmagenci VARCHAR2(100);
      vr_nrctafav VARCHAR2(100);
      vr_nomdofav VARCHAR2(100);
      vr_cpfcgcfv VARCHAR2(100);
      vr_dsfindad VARCHAR2(100);
      vr_dshistco VARCHAR2(100);
      vr_cdidenti VARCHAR2(100);
      vr_dtdodebi VARCHAR2(100);
      vr_dsagenci VARCHAR2(100);
      
      --Credito Pre-Aprovado
      vr_qtdparce VARCHAR2(100);
      vr_vldparce VARCHAR2(100);
      vr_dtpriven VARCHAR2(100);
      vr_vlpercet VARCHAR2(100);
      vr_vltarifa VARCHAR2(100);
      vr_vltaxmen VARCHAR2(100);
      vr_vlrdoiof VARCHAR2(100);
      vr_vlperiof VARCHAR2(100);
      
      --Aplicacao
      vr_tpopeapl VARCHAR2(100);
      vr_nraplica VARCHAR2(100);
      vl_dtaplica VARCHAR2(100);
      vr_nmdprodu VARCHAR2(100);
      vr_carencia VARCHAR2(100);
      vr_dtcarenc VARCHAR2(100);
      vr_dtrdavct VARCHAR2(100);
      
      --Aplicacao (tipo 2 - resgate)
      vr_sldresga VARCHAR2(100);
      vr_dtresgat VARCHAR2(100);
      vr_vlresgat VARCHAR2(100);
      vr_tpresgat VARCHAR2(100);
      
      --Aplicacao (tipo 3 - Agenda resgate)
      vr_flageuni VARCHAR2(100);
      vr_nrdiacre VARCHAR2(100);
      vr_qtdmeses VARCHAR2(100);
      
      --Aplicacao (tipo 4 - Cancelamento Total)
      vr_tpagenda VARCHAR2(100);
      vr_docagend VARCHAR2(100);
      vr_dtdiacre VARCHAR2(100);
      vr_qtdiacar VARCHAR2(100);
      vr_dtacrenc VARCHAR2(100);
      vr_dtagevct VARCHAR2(100);
      vr_dtdiaaar VARCHAR2(100);
      vr_qtmesaar VARCHAR2(100);
       
      --Debito Automatico       
      vr_tpopconv NUMBER := 0;
      vr_iddebaut VARCHAR2(100);
      vr_dshistor VARCHAR2(100);
      vr_vlmaxdeb VARCHAR2(100);
      vr_dtdebfat VARCHAR2(100);
      vr_nrdocfat VARCHAR2(100);
      
      --Folha de Pagamento
      vr_nrqtlnac VARCHAR2(100);
      vr_solestou VARCHAR2(100);

      -- Pacote de tarifas
			vr_dspacote VARCHAR2(100);
			vr_vlpacote VARCHAR2(100);
			vr_dtdiadeb VARCHAR2(100);
			vr_dtinivig VARCHAR2(100);

      --DARF/DAS
      vr_tpcaptura INTEGER := 0;
      vr_dstipcapt VARCHAR2(50);
      vr_dsnomfone VARCHAR2(50);
      vr_dscod_barras tbpagto_darf_das_trans_pend.dscod_barras%TYPE;
      vr_dslinha_digitavel tbpagto_darf_das_trans_pend.dslinha_digitavel%TYPE;
      vr_dtapuracao tbpagto_darf_das_trans_pend.dtapuracao%TYPE;           -- Período de Apuração
      vr_cdtributo tbpagto_darf_das_trans_pend.cdtributo%TYPE;             -- Código da Receita
      vr_nrrefere tbpagto_darf_das_trans_pend.nrrefere%TYPE;               -- Número de Referência (retornar se estiver preenchido)
      vr_vlprincipal tbpagto_darf_das_trans_pend.vlprincipal%TYPE;         -- Valor do Principal
      vr_vlmulta tbpagto_darf_das_trans_pend.vlmulta%TYPE;                 -- Valor da Multa
      vr_vljuros tbpagto_darf_das_trans_pend.vljuros%TYPE;                 -- Valor dos Juros
      vr_vlrtotal tbpagto_darf_das_trans_pend.vlmulta%TYPE;                -- Valor Total
      vr_vlreceita_bruta tbpagto_darf_das_trans_pend.vlreceita_bruta%TYPE; -- Receita Bruta Acumulada  (retornar se estiver preenchido)
      vr_vlpercentual tbpagto_darf_das_trans_pend.vlpercentual%TYPE;       -- Percentual (retornar se estiver preenchido)
      vr_idagendamento tbpagto_darf_das_trans_pend.idagendamento%TYPE;     -- Indicador de Agendamento     
      
      -- Desconto de Cheques
      vr_vltotchq VARCHAR2(100);
      vr_qtcheque INTEGER := 0;

      --Recarga de Celular
      vr_telefone  VARCHAR2(200);
      vr_vlrecarga VARCHAR2(200);
      vr_dtrecarga VARCHAR2(200);
      vr_dttransa  VARCHAR2(200);
      vr_nmproduto VARCHAR2(200);
      
      --Emprestimos/Financiamentos
      vr_qtdparce_ef VARCHAR2(100);
      vr_vldparce_ef VARCHAR2(100);
      vr_dtpriven_ef VARCHAR2(100);
      vr_vlpercet_ef VARCHAR2(100);
      vr_vltarifa_ef VARCHAR2(100);
      vr_vltaxmen_ef VARCHAR2(100);
      vr_vlrdoiof_ef VARCHAR2(100);
      vr_vlperiof_ef VARCHAR2(100);
      
      --> Tributos
      vr_dsidenti_pagto   tbpagto_tributos_trans_pend.dsidenti_pagto%TYPE;
      vr_nridentificacao  VARCHAR2(20);
      vr_nridentificador  tbpagto_tributos_trans_pend.nridentificador%TYPE;
      vr_nrseqgrde        tbpagto_tributos_trans_pend.nrseqgrde%TYPE;            
      vr_nrdocdae         tbpagto_tributos_trans_pend.nridentificador%TYPE;
      
      -- Bordero Desconto de titulo
      vr_vltotbdt VARCHAR2(100);
      vr_qttitulo INTEGER := 0;

      --Variavel de indice
      vr_ind NUMBER := 0;
      
      vr_tab_limite_pend INET0002.typ_tab_limite_pend;
      vr_tab_internet    INET0001.typ_tab_internet;
      vr_tab_internet_conta INET0001.typ_tab_internet;
      vr_tab_agen        APLI0002.typ_tab_agen; 
      vr_tab_agen_det    APLI0002.typ_tab_agen_det;
      vr_tab_crapavt     CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
      vr_tab_bens        CADA0001.typ_tab_bens;       --Tabela bens
      vr_tab_erro        GENE0001.typ_tab_erro;       --Tabela Erro
      vr_saldo_rdca      APLI0001.typ_tab_saldo_rdca; --Tabela para o saldo da aplicação
      vr_tab_convenios   PAGA0002.typ_tab_convenios;  --Tabela Convenios aceitos
      
      -- Variaveis de XML 
      vr_xml_auxi VARCHAR2(32767);
      vr_xml_temp VARCHAR2(32767);
      
      rw_cr_tbctd_trans_pend cr_tbctd_trans_pend%ROWTYPE;
    ----------------------------------------------------------------  
    ---------------------- INICIO DO PROGRAMA ----------------------  
    ----------------------------------------------------------------
    
    BEGIN

      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapass;  
      END IF;
      
      vr_idastcjt := rw_crapass.idastcjt;
      vr_nmprimtl := rw_crapass.nmprimtl;
      vr_idseqttl := pr_idseqttl;
      
      --Se conta nao exige assinatura multipla, verificar preposto
      IF vr_idastcjt = 0 THEN
        --Consulta do cpf do representante na crapsnh
        OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => 1);
        FETCH cr_crapsnh INTO vr_nrcpfcgc;
        --Se nao encontrou 
        IF cr_crapsnh%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapsnh;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de senha nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapsnh;
        END IF;
        
        --Consulta do nome do Preposto
        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrcpfcgc => vr_nrcpfcgc);
        FETCH cr_crapavt INTO vr_nrdctato
                             ,vr_nmprimtl;
        --Se nao encontrou 
        IF cr_crapavt%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapavt;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Necessario habilitar um preposto.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE                             
          --Fechar Cursor
          CLOSE cr_crapavt;      
        END IF;
      ELSE --Se conta exige assinatura multipla
        IF pr_nrcpfope = 0 THEN
          --Consulta do cpf do representante na crapsnh
          OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_idseqttl => pr_idseqttl);
          FETCH cr_crapsnh INTO vr_nrcpfcgc;
          --Se nao encontrou 
          IF cr_crapsnh%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapsnh;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro de senha nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Fechar Cursor
            CLOSE cr_crapsnh;
          END IF;
        ELSE
           --Consulta primeiro registro de senha ativo
          OPEN cr_crapsnh_seq(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapsnh_seq INTO vr_idseqttl;
          CLOSE cr_crapsnh_seq;
        END IF;
        
      END IF;
      
      -- Atualiza somente se for pesquisa de todas as transações no período informado
      IF NVL(pr_cdtransa,0) = 0 AND pr_dtiniper IS NULL AND pr_dtfimper IS NULL AND pr_nrregist = 0 THEN
        PAGA0001.pc_atualiza_trans_nao_efetiv(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_dstransa => vr_dstransa
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);                                                       
                                           
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;                                        
      END IF;
      
      -------------------------------------------------------------------------------
      ------------------------------  Criacao do XML --------------------------------
      -------------------------------------------------------------------------------
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<raiz>'); 
      
      --Montar Tag Xml de Informativo
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<dstransa>'||vr_dstransa||'</dstransa>');
      
      -- Retornar somente se for pesquisa geral ou específica para consultar parâmetros gerais
      IF NVL(pr_cdtransa,0) = 0 THEN
        --Limpar Tabela Memoria de Horarios
        vr_tab_limite_pend.DELETE;
        
        --Buscar Horario Operacao
        INET0002.pc_horario_trans_pend (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                       ,pr_cdagenci => pr_cdagenci  --Agencia do Associado
                                       ,pr_cdoperad => '996'        --Operador
                                       ,pr_nrdcaixa => 900          --Nr do caixa
                                       ,pr_nmdatela => 'INTERNETBANK' --Nome da tela
                                       ,pr_idorigem => 3            --Id de Origem
                                       ,pr_tab_limite_pend => vr_tab_limite_pend --Tabelas de retorno de horarios limite
                                       ,pr_cdcritic => vr_cdcritic    --Código do erro
                                       ,pr_dscritic => vr_dscritic);  --Descricao do erro
            
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Montar Tag Xml de Horarios
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<horarios>');       
        
        vr_ind := vr_tab_limite_pend.FIRST;
        WHILE vr_ind IS NOT NULL LOOP
           
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => '<horario>'
                                                     ||   '<idtiphor>'||vr_ind||'</idtiphor>'
                                                     ||   '<idtiptra>'||nvl(vr_tab_limite_pend(vr_ind).tipodtra,0)||'</idtiptra>'
                                                     ||   '<hrinipag>'||nvl(vr_tab_limite_pend(vr_ind).hrinipag,' ')||'</hrinipag>'
                                                     ||   '<hrfimpag>'||nvl(vr_tab_limite_pend(vr_ind).hrfimpag,' ')||'</hrfimpag>'
                                                     || '</horario>'); 
           vr_ind := vr_tab_limite_pend.NEXT(vr_ind);
        END LOOP;
        
        --Fecha Tag de Horarios
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</horarios>'); 
        
        --Limpar Tabela Memoria de Limites
        vr_tab_internet.DELETE;
        vr_tab_internet_conta.DELETE;
        BEGIN
          -- Inicializa variavel
          va_existe_operador := 0;
          -- Se for assinatura conjunta habilitada
          IF vr_idastcjt = 1 THEN
            FOR rw_crapopi2 in cr_crapopi2 (pr_cdcooper
                                           ,pr_nrdconta
                                           ,pr_nrcpfope) LOOP
   
              va_existe_operador := 1;                        
            END LOOP;
            --
            
            -- Se for preposto
            IF va_existe_operador = 0 THEN
              
              va_nrcpfcgc := null;
              va_vllimweb := null;
              IF pr_nrcpfope IS NULL OR
                 pr_nrcpfope <= 0 THEN
                FOR rw_crapsnh2 IN cr_crapsnh2(pr_cdcooper,
                                               pr_nrdconta,
                                               vr_idseqttl) LOOP
                  va_nrcpfcgc := rw_crapsnh2.nrcpfcgc;
                  va_vllimweb := rw_crapsnh2.vllimweb;
                END LOOP;     
              END IF;
              -- buscar limites preposto
              INET0001.pc_busca_limites_prepo_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                                   ,pr_nrdconta     => pr_nrdconta   --Numero da conta
                                                   ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                                   ,pr_nrcpfope	    => NVL(va_nrcpfcgc,pr_nrcpfope)  --Numero do CPF
                                                   ,pr_dtmvtopg     => pr_dtmvtolt  --Data do proximo pagamento
                                                   ,pr_dsorigem     => GENE0001.vr_vet_des_origens(pr_cdorigem)  --Descricao Origem
                                                   ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de horarios limite
                                                   ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                                   ,pr_dscritic     => vr_dscritic); --Descricao do erro;
              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; -- Levantar Excecao
              END IF;
                             
            ELSE -- Se for operador
              -- Buscar limites operador do sistema
              INET0001.pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                                   ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                                   ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                                   ,pr_nrcpfope	    => pr_nrcpfope  --Numero do CPF
                                                   ,pr_dtmvtopg     => pr_dtmvtolt  --Data do proximo pagamento
                                                   ,pr_dsorigem     => GENE0001.vr_vet_des_origens(pr_cdorigem)  --Descricao Origem
                                                   ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de horarios limite
                                                   ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                                   ,pr_dscritic     => vr_dscritic); --Descricao do erro;

              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro; -- Levantar Excecao
              END IF;        
            END IF;
          -- Comentado pois fará a busca de limites da conta mais abaixo independente se possui assinatura conjunta
          /*
        ELSE   
            -- Buscar Limites da internet 
          INET0001.pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                    ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                    ,pr_flglimdp     => FALSE         --Indicador limite deposito
                                    ,pr_dtmvtopg     => pr_dtmvtolt  --Data do proximo pagamento
                                    ,pr_flgctrag     => FALSE  --Indicador validacoes
                                    ,pr_dsorigem     => GENE0001.vr_vet_des_origens(pr_cdorigem)  --Descricao Origem
                                    ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de horarios limite
                                    ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                    ,pr_dscritic     => vr_dscritic); --Descricao do erro;
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;  -- Validar se esá habilitado assinatura conjunta                                      
          */
        END IF; 
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao buscar os limites '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        --Buscar Limites  
        INET0001.pc_busca_limites(pr_cdcooper     => pr_cdcooper   --Codigo Cooperativa
                                 ,pr_nrdconta     => pr_nrdconta   --Numero da conta
                                 ,pr_idseqttl     => vr_idseqttl   --Seq de Titularidade
                                 ,pr_flglimdp     => FALSE         --Indicador limite deposito
                                 ,pr_dtmvtopg     => pr_dtmvtolt   --Data do proximo pagamento
                                 ,pr_flgctrag     => FALSE         --Indicador validacoes
                                 ,pr_dsorigem     => GENE0001.vr_vet_des_origens(pr_cdorigem)
                                 ,pr_tab_internet => vr_tab_internet_conta --Tabelas de retorno de limites
                                 ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                 ,pr_dscritic     => vr_dscritic); --Descricao do erro 

        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; -- Levantar Excecao
        END IF;
        
        --Montar Tag Xml de Limites
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<limites>'); 
        
        vr_ind := vr_tab_internet_conta.FIRST;
        WHILE vr_ind IS NOT NULL LOOP
           
           vr_vllimpgo := CASE WHEN vr_tab_internet.COUNT > 0 AND nvl(vr_tab_internet(vr_ind).vllimpgo,0) > 0 THEN nvl(vr_tab_internet(vr_ind).vllimpgo,0) ELSE nvl(vr_tab_internet_conta(vr_ind).vllimpgo,0) END;
           vr_vllimtrf := CASE WHEN vr_tab_internet.COUNT > 0 AND nvl(vr_tab_internet(vr_ind).vllimtrf,0) > 0 THEN nvl(vr_tab_internet(vr_ind).vllimtrf,0) ELSE nvl(vr_tab_internet_conta(vr_ind).vllimtrf,0) END; 
           vr_vllimted := CASE WHEN vr_tab_internet.COUNT > 0 AND nvl(vr_tab_internet(vr_ind).vllimted,0) > 0 THEN nvl(vr_tab_internet(vr_ind).vllimted,0) ELSE nvl(vr_tab_internet_conta(vr_ind).vllimted,0) END; 
           vr_vllimvrb := CASE WHEN vr_tab_internet.COUNT > 0 AND nvl(vr_tab_internet(vr_ind).vllimvrb,0) > 0 THEN nvl(vr_tab_internet(vr_ind).vllimvrb,0) ELSE nvl(vr_tab_internet_conta(vr_ind).vllimvrb,0) END; 
           
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => '<limite>' 
                                                     ||   '<idseqttl>'||nvl(vr_tab_internet_conta(vr_ind).idseqttl,0)||'</idseqttl>'
                                                     ||   '<vllimweb>'||TO_CHAR(nvl(va_vllimweb,nvl(vr_tab_internet_conta(vr_ind).vllimweb,0)),'fm999g999g990d00')||'</vllimweb>'
                                                     ||   '<vllimpgo>'||TO_CHAR(vr_vllimpgo,'fm999g999g990d00')||'</vllimpgo>'
                                                     ||   '<vllimtrf>'||TO_CHAR(vr_vllimtrf,'fm999g999g990d00')||'</vllimtrf>'
                                                     ||   '<vllimted>'||TO_CHAR(vr_vllimted,'fm999g999g990d00')||'</vllimted>'
                                                     ||   '<vllimvrb>'||TO_CHAR(vr_vllimvrb,'fm999g999g990d00')||'</vllimvrb>'
                                                     ||   '<vlutlweb>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlutlweb,0),'fm999g999g990d00')||'</vlutlweb>'
                                                     ||   '<vlutlpgo>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlutlpgo,0),'fm999g999g990d00')||'</vlutlpgo>'
                                                     ||   '<vlutltrf>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlutltrf,0),'fm999g999g990d00')||'</vlutltrf>'
                                                     ||   '<vlutlted>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlutlted,0),'fm999g999g990d00')||'</vlutlted>'
                                                     ||   '<vldspweb>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vldspweb,0),'fm999g999g990d00')||'</vldspweb>'
                                                     ||   '<vldsppgo>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vldsppgo,0),'fm999g999g990d00')||'</vldsppgo>'
                                                     ||   '<vldsptrf>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vldsptrf,0),'fm999g999g990d00')||'</vldsptrf>'
                                                     ||   '<vldspted>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vldspted,0),'fm999g999g990d00')||'</vldspted>'
                                                     ||   '<vlwebcop>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlwebcop,0),'fm999g999g990d00')||'</vlwebcop>'
                                                     ||   '<vlpgocop>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlpgocop,0),'fm999g999g990d00')||'</vlpgocop>'
                                                     ||   '<vltrfcop>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vltrfcop,0),'fm999g999g990d00')||'</vltrfcop>'
                                                     ||   '<vltedcop>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vltedcop,0),'fm999g999g990d00')||'</vltedcop>'
                                                     ||   '<vlvrbcop>'||TO_CHAR(nvl(vr_tab_internet_conta(vr_ind).vlvrbcop,0),'fm999g999g990d00')||'</vlvrbcop>'
                                                     || '</limite>'); 
           vr_ind := vr_tab_internet.NEXT(vr_ind);
        END LOOP;
        
        --Fecha Tag de Horarios
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</limites>'); 
                               
        --Limpar Tabela Memoria de Convenios
        vr_tab_convenios.DELETE;
        
        --Buscar Horario Operacao
        PAGA0002.pc_convenios_aceitos  (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                       ,pr_tab_convenios => vr_tab_convenios --Tabelas de retorno de horarios limite
                                       ,pr_cdcritic => vr_cdcritic    --Código do erro
                                       ,pr_dscritic => vr_dscritic);  --Descricao do erro
                                     
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Montar Tag Xml de Horarios
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<convenios>'); 
        
        vr_ind := vr_tab_convenios.FIRST;
        WHILE vr_ind IS NOT NULL LOOP
           
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => '<convenio>'
                                                     ||   '<nmextcon>'||nvl(vr_tab_convenios(vr_ind).nmextcon,' ')||'</nmextcon>'
                                                     ||   '<nmrescon>'||nvl(vr_tab_convenios(vr_ind).nmrescon,' ')||'</nmrescon>'
                                                     ||   '<cdempcon>'||nvl(vr_tab_convenios(vr_ind).cdempcon,0)||'</cdempcon>'
                                                     ||   '<cdsegmto>'||nvl(vr_tab_convenios(vr_ind).cdsegmto,0)||'</cdsegmto>'
                                                     ||   '<hhoraini>'||nvl(vr_tab_convenios(vr_ind).hhoraini,' ')||'</hhoraini>'
                                                     ||   '<hhorafim>'||nvl(vr_tab_convenios(vr_ind).hhorafim,' ')||'</hhorafim>'
                                                     ||   '<hhoracan>'||nvl(vr_tab_convenios(vr_ind).hhoracan,' ')||'</hhoracan>'
                                                     || '</convenio>'); 
           vr_ind := vr_tab_convenios.NEXT(vr_ind);
        END LOOP;
        
        --Fecha Tag de Horarios
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</convenios>');   
      END IF;                          
                             
      -- Se for pesquisa geral ou específica para determinada transação
      IF (pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND pr_nrregist > 0) OR (NVL(pr_cdtransa,0) > 0) THEN      
        --Montar Tag Xml das transacoes pendentes
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<transacoes>');
        --------------------------------------------------------------------------------------
        --Buscar transacoes pendentes (pai)
        --------------------------------------------------------------------------------------
        --Limpar Tabela Memoria
        vr_tab_crapavt.DELETE;

        CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => 900
                                  ,pr_cdoperad => '996'
                                  ,pr_nmdatela => 'INTERNETBANK'
                                  ,pr_idorigem => 3
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 0
                                  ,pr_flgerlog => FALSE
                                  ,pr_cddopcao => 'C'
                                  ,pr_nrdctato => 0
                                  ,pr_nrcpfcto => 0
                                  ,pr_nrdrowid => NULL
                                  ,pr_tab_crapavt => vr_tab_crapavt
                                  ,pr_tab_bens => vr_tab_bens
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Verifica se existem representantes legais para conta
        IF vr_tab_crapavt.COUNT() <= 0 THEN
          vr_dscritic := 'Nao existem responsaveis legais para a conta informada.';
          RAISE vr_exc_erro;
        END IF; 
        
        -- IB Antigo passa o parâmetro com valores pares (Ex.: 0, 10, 20)
        -- Novo IB está padronizado para iniciar a sequencia com valor 1. 
        -- Para manter as 2 plataformas funcionais durante o piloto do novo IB é necessário decremetar o valor
        IF MOD(pr_nriniseq,2) <> 0 THEN
          vr_nriniseq := pr_nriniseq - 1;
        ELSE
          vr_nriniseq := pr_nriniseq;
        END IF;

        FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend (pr_cdcooper => pr_cdcooper
                                                       ,pr_nrdconta => pr_nrdconta
                                                       ,pr_cdtransa => pr_cdtransa
                                                       ,pr_dtiniper => pr_dtiniper
                                                       ,pr_dtfimper => pr_dtfimper
                                                       ,pr_insittra => pr_insittra) LOOP                                                       
                          
           --Zerando Variaveis
           vr_indiacao := 0;   vr_cddbanco := 0;   vr_vlasomar := 0;   vr_vlaplica := 0;   vr_vllanaut := 0;
           vr_cdcopdes := ' '; vr_nrcondes := ' '; vr_dtdebito := ' '; vr_nmcednte := ' '; vr_nrcodbar := ' ';
           vr_dslindig := ' '; vr_dtvencto := ' '; vr_vldocmto := ' '; vr_identdda := ' '; vr_labnmage := ' '; 
           vr_nmextbcc := ' '; vr_dsfindad := ' '; vr_nmbanfav := ' '; vr_nmdoispb := ' '; vr_nmagenci := ' '; 
           vr_nrctafav := ' '; vr_nomdofav := ' '; vr_cpfcgcfv := ' '; vr_dshistco := ' '; vr_cdidenti := ' '; 
           vr_dtdodebi := ' '; vr_qtdparce := ' '; vr_vldparce := ' '; vr_dtpriven := ' '; vr_vlpercet := ' '; 
           vr_vltarifa := ' '; vr_vltaxmen := ' '; vr_vlrdoiof := ' '; vr_vlperiof := ' '; vr_tpopeapl := ' '; 
           vr_nraplica := ' '; vr_tpagenda := ' '; vr_docagend := ' '; vr_flageuni := ' '; vr_nrdiacre := ' '; 
           vr_qtdmeses := ' '; vl_dtaplica := ' '; vr_nmdprodu := ' '; vr_carencia := ' '; 
           vr_dtcarenc := ' '; vr_dtrdavct := ' '; vr_sldresga := ' '; vr_dtresgat := ' '; vr_vlresgat := ' '; 
           vr_tpresgat := ' '; vr_dtdiacre := ' '; vr_qtdiacar := ' '; vr_dtacrenc := ' '; vr_dtdiaaar := ' ';
           vr_qtmesaar := ' '; vr_dtagevct := ' '; vr_nmrescon := ' '; vr_iddebaut := ' '; vr_dshistor := ' '; 
           vr_vlmaxdeb := ' '; vr_dtdebfat := ' '; vr_nrdocfat := ' '; vr_nrqtlnac := ' '; 
           vr_solestou := ' '; vr_xml_auxi := ' '; vr_dtmvttra := ' '; vr_nmagenda := ' ';
           vr_tpcaptura := 0; vr_dstipcapt := ''; vr_dsnomfone := ''; vr_dscod_barras := ''; vr_dslinha_digitavel := '';
           vr_dtapuracao := null; vr_cdtributo := '0'; vr_nrrefere := 0; vr_vlprincipal := 0; vr_vlmulta := 0; vr_vljuros := 0;
           vr_vlrtotal := 0; vr_vlreceita_bruta := 0; vr_vlpercentual := 0; vr_idagendamento := 0; 

           --Atribuicao de variaveis genericas
           vr_tptranpe := rw_tbgen_trans_pend.tptransacao;
           vr_cdtranpe := rw_tbgen_trans_pend.cdtransacao_pendente;
           vr_dttranpe := TO_CHAR(rw_tbgen_trans_pend.dtregistro_transacao,'DD/MM/RRRR');
           vr_hrtranpe := TO_CHAR(to_date(rw_tbgen_trans_pend.hrregistro_transacao,'sssss'),'hh24:mi:ss');
           vr_dsoritra := GENE0001.vr_vet_des_origens(rw_tbgen_trans_pend.idorigem_transacao);
           vr_dtmvttra := TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR');
           vr_idsittra := rw_tbgen_trans_pend.idsituacao_transacao;
           vr_dssittra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 1 THEN 'Pendente'
                               WHEN rw_tbgen_trans_pend.idsituacao_transacao = 2 THEN 'Aprovada'
                               WHEN rw_tbgen_trans_pend.idsituacao_transacao = 3 THEN 'Excluida'
                               WHEN rw_tbgen_trans_pend.idsituacao_transacao = 4 THEN 'Expirada'
                               WHEN rw_tbgen_trans_pend.idsituacao_transacao = 5 THEN 'Parcialmente Aprovada'
                               WHEN rw_tbgen_trans_pend.idsituacao_transacao = 6 THEN 'Reprovada'
                          END;
           vr_dtaltera := TO_CHAR(rw_tbgen_trans_pend.dtalteracao_situacao,'DD/MM/RRRR');
           vr_dtreptra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 6 THEN TO_CHAR(rw_tbgen_trans_pend.dtalteracao_situacao,'DD/MM/RRRR') END;
           vr_dtexctra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 3 THEN TO_CHAR(rw_tbgen_trans_pend.dtalteracao_situacao,'DD/MM/RRRR') END;
           vr_dtexptra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 4 THEN TO_CHAR(rw_tbgen_trans_pend.dtalteracao_situacao,'DD/MM/RRRR') END;
           vr_dscritra := rw_tbgen_trans_pend.dscritica;
           vr_dtvalida := TO_CHAR(rw_tbgen_trans_pend.dtcritica,'DD/MM/RRRR');
           vr_labnmage := CASE WHEN rw_tbgen_trans_pend.nrcpf_operador > 0 THEN 'Operador' ELSE 'Representante' END;
                 
           IF rw_tbgen_trans_pend.nrcpf_operador > 0 THEN
              OPEN cr_crapopi (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfope => rw_tbgen_trans_pend.nrcpf_operador);
              FETCH cr_crapopi INTO vr_nmagenda;
              --Se nao encontrou 
              IF cr_crapopi%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapopi;
                  vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                          ,pr_inpessoa => 1);
              ELSE                             
                  --Fechar Cursor
                  CLOSE cr_crapopi;
                  vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                          ,pr_inpessoa => 1) || ' - ' || vr_nmagenda;                
              END IF;
           ELSE -- Consultar Representante
              vr_ind := vr_tab_crapavt.FIRST;
              WHILE vr_ind IS NOT NULL LOOP
                -- Operação realizada por responsável da assinatura conjunta
                IF vr_tab_crapavt(vr_ind).nrcpfcgc = rw_tbgen_trans_pend.nrcpf_representante THEN
                  vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapavt(vr_ind).nrcpfcgc
                                                          ,pr_inpessoa => 1) 
                                 || ' - ' || vr_tab_crapavt(vr_ind).nmdavali;
                  EXIT;
                END IF;
                vr_ind := vr_tab_crapavt.NEXT(vr_ind);
              END LOOP;
           END IF; 
                 
           IF vr_nmagenda IS NULL THEN
              vr_nmagenda := CASE WHEN rw_tbgen_trans_pend.nrcpf_operador > 0 THEN 
                                  gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                           ,pr_inpessoa => 1)
                             ELSE gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_representante
                                                           ,pr_inpessoa => 1)
                             END;
           END IF;
                 
           --Controle de operacao (indica 1 que pode alterar)
           IF rw_tbgen_trans_pend.idsituacao_transacao = 1 OR   --Pendente
              rw_tbgen_trans_pend.idsituacao_transacao = 5 THEN --Parcialmente Aprovada
             IF pr_nrcpfope > 0 THEN --Consulta efetuada por operador PJ
               IF rw_tbgen_trans_pend.idsituacao_transacao = 1     AND
                  rw_tbgen_trans_pend.nrcpf_operador = pr_nrcpfope THEN
                  vr_indiacao := 1;
               END IF;
           ELSE
               OPEN cr_tbaprova(pr_cdtransa => vr_cdtranpe
                               ,pr_nrcpfope => vr_nrcpfcgc);

               FETCH cr_tbaprova INTO rw_tbaprova;                                    

               IF cr_tbaprova%FOUND THEN
                  vr_indiacao := 1;
               END IF;

               CLOSE cr_tbaprova;
           END IF; 
         END IF;         

           --Case para cada tipo de transacao (filhos)                                           
           CASE 
              WHEN vr_tptranpe = 1 OR --Transferencias
                   vr_tptranpe = 3 OR
                   vr_tptranpe = 5 THEN
                         
                   OPEN cr_tbtransf_trans_pend(pr_cddoitem => vr_cdtranpe);
                   FETCH cr_tbtransf_trans_pend INTO rw_tbtransf_trans_pend;
                   IF cr_tbtransf_trans_pend%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_tbtransf_trans_pend;
                      CONTINUE;
                   ELSE
                      --Fechar Cursor
                      CLOSE cr_tbtransf_trans_pend;
                            
                      --Controle de paginacao
                      vr_qttotpen := vr_qttotpen + 1;
                      IF ((vr_qttotpen <= vr_nriniseq) OR
                         (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                         CONTINUE;
                 END IF;

                 END IF;
                 
                 OPEN cr_crapcop (pr_cdagectl => rw_tbtransf_trans_pend.cdagencia_coop_destino);
                 FETCH cr_crapcop INTO rw_crapcop;

                 IF cr_crapcop %NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapcop;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Cooperativa destino nao encontrada.';
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapcop;
                 END IF;

                 OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrdconta => rw_tbtransf_trans_pend.nrconta_destino);
                 FETCH cr_crapass INTO rw_crapass2;
                 IF cr_crapass %NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapass;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Conta destino nao encontrado.';
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapass;
                 END IF;

                 --Valor a somar
                 vr_vlasomar := rw_tbtransf_trans_pend.vltransferencia;

                 --Variaveis do resumo
                 vr_dsvltran := TO_CHAR(rw_tbtransf_trans_pend.vltransferencia,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                 vr_dsdescri := rw_tbtransf_trans_pend.cdagencia_coop_destino || '/' || rw_tbtransf_trans_pend.nrconta_destino || '-' || SUBSTR(rw_crapass2.nmprimtl,1,20); -- Descricao
                 vr_dstptran := CASE WHEN rw_tbgen_trans_pend.tptransacao = 3 THEN 'Crédito de Salário' ELSE 'Transferência' END; -- Tipo de Transacao
                 vr_dsagenda := CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                 
                 --Variaveis especificas
                 vr_cdcopdes := TO_CHAR(rw_tbtransf_trans_pend.cdagencia_coop_destino) || '-' || rw_crapcop.nmrescop;
                 vr_nrcondes := TO_CHAR(rw_tbtransf_trans_pend.nrconta_destino) || '-' || SUBSTR(rw_crapass2.nmprimtl,1,20);
                 vr_dtdebito := TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR');

            WHEN vr_tptranpe = 2 THEN --Pagamento
                 
                 OPEN cr_tbpagto_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
                 IF cr_tbpagto_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbpagto_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbpagto_trans_pend;
                   
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                      IF ((vr_qttotpen <= vr_nriniseq) OR
                         (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                         
                   --Valor a somar
                   vr_vlasomar := rw_tbpagto_trans_pend.vlpagamento;
                         
                   --Variaveis do resumo
                   vr_dsvltran := TO_CHAR(rw_tbpagto_trans_pend.vlpagamento,'fm999g999g990d00'); -- Valor
                   vr_dsdtefet := CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                   vr_dsdescri := rw_tbpagto_trans_pend.dscedente; -- Descricao
                   vr_dstptran := CASE WHEN rw_tbpagto_trans_pend.tppagamento = 1 THEN 
                                         'Pagamento de Convênio' 
                                       WHEN rw_tbpagto_trans_pend.tppagamento = 2 THEN
                                         'Pagamento de Boletos Diversos'
                                       ELSE 
                                          'Pagamento de GPS' END; -- Tipo de Transacao
                   vr_dsagenda := CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                         
                   --Variaveis especificas
                   vr_nmcednte := rw_tbpagto_trans_pend.dscedente;
                   vr_nrcodbar := rw_tbpagto_trans_pend.dscodigo_barras;
                   vr_dslindig := rw_tbpagto_trans_pend.dslinha_digitavel;
                   vr_dtvencto := TO_CHAR(rw_tbpagto_trans_pend.dtvencimento,'DD/MM/RRRR');
                   vr_vldocmto := TO_CHAR(rw_tbpagto_trans_pend.vldocumento,'fm999g999g990d00');
                   vr_dtdebito := TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR');
                   vr_identdda := CASE WHEN rw_tbpagto_trans_pend.idtitulo_dda = 0 THEN 'NÃO' ELSE 'SIM' END;
                         
              WHEN vr_tptranpe IN (4,22) THEN --TED /*REQ39*/
                         
                   OPEN cr_tbspb_trans_pend(pr_cddoitem => vr_cdtranpe);
                   FETCH cr_tbspb_trans_pend INTO rw_tbspb_trans_pend;
                   IF cr_tbspb_trans_pend%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_tbspb_trans_pend;
                      CONTINUE;
                   ELSE
                      --Fechar Cursor
                      CLOSE cr_tbspb_trans_pend;

                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 IF vr_tptranpe <> 22 THEN /*REQ39*/      
                   --Cadastro de Transferencias pela Internet
                   OPEN cr_crapcti( pr_cdcooper => rw_tbspb_trans_pend.cdcooper,
                                    pr_nrdconta => rw_tbspb_trans_pend.nrdconta,
                                    pr_cddbanco => rw_tbspb_trans_pend.cdbanco_favorecido,
                                    pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido,
                                    pr_nrctatrf => rw_tbspb_trans_pend.nrconta_favorecido);
                   FETCH cr_crapcti INTO rw_crapcti;	
                   IF cr_crapcti%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapcti;

                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Registro de Cadastro de transferencias nao encontrado.';
                      --Levantar Excecao
                      RAISE vr_exc_erro;
                   ELSE
                      --Fechar Cursor
                      CLOSE cr_crapcti;
                   END IF;
                 END IF; 
                 
                 --Buscar nome do banco favorecido
                 IF rw_tbspb_trans_pend.nrispb_banco_favorecido = 0 THEN
                    OPEN cr_crapban1 (pr_cdbccxlt => rw_tbspb_trans_pend.cdbanco_favorecido);
                    FETCH cr_crapban1 INTO vr_cddbanco,
                                           vr_nmextbcc;
                    --Fechar Cursor
                    CLOSE cr_crapban1;
                 ELSE 
                    OPEN cr_crapban2 (pr_nrispbif => rw_tbspb_trans_pend.nrispb_banco_favorecido);
                    FETCH cr_crapban2 INTO vr_cddbanco,
                                           vr_nmextbcc;
                    --Fechar Cursor
                    CLOSE cr_crapban2;
                 END IF;
                 
                 IF vr_nmextbcc IS NULL OR vr_nmextbcc = ' ' THEN
                    vr_nmextbcc := 'BANCO NAO CADASTRADO';
                 END IF;
                 
                 --Buscar Finalidade
                 vr_dsfindad := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_tbspb_trans_pend.cdcooper
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'GENERI'
                                                          ,pr_cdempres => 0
                                                          ,pr_cdacesso => 'FINTRFTEDS'
                                                          ,pr_tpregist => rw_tbspb_trans_pend.cdfinalidade);  
                  
                 IF vr_dsfindad IS NULL THEN
                   vr_dsfindad := 'FINALIDADE NAO CADASTRADA';
                 END IF;
                 
                 IF vr_tptranpe <> 22 THEN /*REQ39*/
                   --Buscar Agencia
                   OPEN cr_crapagb( pr_cddbanco => vr_cddbanco ,
                                    pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido);
                   FETCH cr_crapagb INTO vr_dsagenci;	
                   IF cr_crapagb%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapagb;
                      vr_dsagenci := 'AGENCIA NAO CADASTRADA';
                   ELSE
                      --Fechar Cursor
                      CLOSE cr_crapagb;
                   END IF;
                 ELSE
                   vr_dsagenci:= NULL;
                 END IF;                 
                 --Valor a somar
                 vr_vlasomar := rw_tbspb_trans_pend.vlted;
                 
                 --Variaveis de resumo
                 vr_dsvltran := TO_CHAR(rw_tbspb_trans_pend.vlted,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                 IF vr_tptranpe <> 22 THEN /*REQ39*/
                    vr_dsdescri := TO_CHAR(rw_tbspb_trans_pend.nrconta_favorecido) || ' - ' || SUBSTR(rw_crapcti.nmtitula,1,20); -- Descricao
                    vr_nomdofav := rw_crapcti.nmtitula; --Nome do Favorecido
                    vr_cpfcgcfv := rw_crapcti.nrcpfcgc; --CPF/CNPJ do Favorecido
                 ELSE
                    /*REQ39 - TED Judicial não possui dados de favorecido*/
                    vr_dsdescri := TO_CHAR(vr_cddbanco)||' - '||UPPER(vr_nmextbcc) ; -- Nome do banco
                    vr_nomdofav := NULL; --Nome do Favorecido
                    vr_cpfcgcfv := NULL; --CPF/CNPJ do Favorecido  
                 END IF;
                 vr_dstptran := 'TED'; -- Tipo de Transacao
                 vr_dsagenda := CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                 
                 --Variaveis especificas
                 vr_nmbanfav := rw_tbspb_trans_pend.cdbanco_favorecido || '-' || vr_nmextbcc; --Banco Favorecido
                 vr_nmdoispb := rw_tbspb_trans_pend.nrispb_banco_favorecido || '-' || vr_nmextbcc; --ISPB
                 vr_nmagenci := rw_tbspb_trans_pend.cdagencia_favorecido || '-' || vr_dsagenci; --Agencia do Favorecido
                 vr_nrctafav := rw_tbspb_trans_pend.nrconta_favorecido; --Conta do Favorecido
                 vr_dshistco := rw_tbspb_trans_pend.dshistorico; --Historico Complementar
                 vr_cdidenti := rw_tbspb_trans_pend.dscodigo_identificador; --Codigo Identificador
                 vr_dtdodebi := TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR'); --Debito Em
                 
            WHEN vr_tptranpe = 6 THEN --Credito Pre-Aprovado
                 
                 OPEN cr_tbepr_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbepr_trans_pend INTO rw_tbepr_trans_pend;
                 IF cr_tbepr_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbepr_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbepr_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbepr_trans_pend.vlemprestimo;
                 
                 --Variaveis resumo
                 vr_dsvltran := TO_CHAR(rw_tbepr_trans_pend.vlemprestimo,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                 vr_dsdescri := 'CRÉDITO PRÉ-APROVADO - ' || TO_CHAR(rw_tbepr_trans_pend.nrparcelas) || ' vezes de R$ ' || TO_CHAR(rw_tbepr_trans_pend.vlparcela,'fm999g999g990d00'); -- Descricao
                 vr_dstptran := 'Crédito Pré-Aprovado'; -- Tipo de Transacao
                 vr_dsagenda := 'NÃO'; -- Agendamento
                 
                 --Variaveis especificas
                 vr_qtdparce := rw_tbepr_trans_pend.nrparcelas; --Quantidade de Parcelas
                 vr_vldparce := TO_CHAR(rw_tbepr_trans_pend.vlparcela,'fm999g999g990d00'); --Valor da Parcela
                 vr_dtpriven := TO_CHAR(rw_tbepr_trans_pend.dtprimeiro_vencto,'DD/MM/RRRR'); --Primeiro Vencimento
                 vr_vlpercet := TO_CHAR(rw_tbepr_trans_pend.vlpercentual_cet,'fm999g999g990d00'); --CET
                 vr_vltarifa := TO_CHAR(rw_tbepr_trans_pend.vltarifa,'fm999g999g990d00'); --Tarifa
                 vr_vltaxmen := TO_CHAR(rw_tbepr_trans_pend.vltaxa_mensal,'fm999g999g990d00'); --Taxa Mensal
                 vr_vlrdoiof := TO_CHAR(rw_tbepr_trans_pend.vliof,'fm999g999g990d00'); --IOF
                 vr_vlperiof := TO_CHAR(rw_tbepr_trans_pend.vlpercentual_iof,'fm999g999g990d0000'); --Percentual IOF
                 
            WHEN vr_tptranpe = 7 THEN --Aplicacao
                 
                 OPEN cr_tbcapt_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbcapt_trans_pend INTO rw_tbcapt_trans_pend;
                 IF cr_tbcapt_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbcapt_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbcapt_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 vr_tpopeapl := rw_tbcapt_trans_pend.tpoperacao; -- Tipo de Operacao (da Aplicacao)
                 vr_nraplica := rw_tbcapt_trans_pend.nraplicacao; --Número da Aplicacao
                 vr_tpagenda := rw_tbcapt_trans_pend.tpagendamento; --Tipo do Agendamento: 
                 vr_docagend := rw_tbcapt_trans_pend.nrdocto_agendamento; --Documento Agendamento
                 vr_flageuni := rw_tbcapt_trans_pend.idperiodo_agendamento; --Agendamento (0) unico ou (1) mensal
                 vr_nrdiacre := rw_tbcapt_trans_pend.nrdia_agendamento; --Creditar no dia
                 vr_qtdmeses := rw_tbcapt_trans_pend.qtmeses_agendamento; --Qtd meses agendado
                 
                 CASE
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 1 THEN --Cancelamento Aplicacao
                          OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao);
                          FETCH cr_craprda INTO vr_vlaplica;
                          IF cr_craprda%NOTFOUND THEN
                             --Fechar Cursor
                             CLOSE cr_craprda;
                          ELSE
                             --Fechar Cursor
                             CLOSE cr_craprda;
                                                    
                             apli0005.pc_lista_aplicacoes ( pr_cdcooper => pr_cdcooper
                                                           ,pr_cdoperad => 900
                                                           ,pr_nmdatela => 'INTERNETBANK'
                                                           ,pr_idorigem => 3
                                                           ,pr_nrdcaixa => '996'
                                                           ,pr_nrdconta => pr_nrdconta
                                                           ,pr_idseqttl => 1
                                                           ,pr_cdagenci => 90
                                                           ,pr_cdprogra => 'INTERNETBANK'
                                                           ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                           ,pr_cdprodut => 0
                                                           ,pr_dtmvtolt => pr_dtmvtolt 
                                                           ,pr_idconsul => 2 
                                                           ,pr_idgerlog => 0
                                                           ,pr_cdcritic => vr_cdcritic
                                                           ,pr_dscritic => vr_dscritic
                                                           ,pr_saldo_rdca => vr_saldo_rdca);                             
                          END IF;    
                                
                          --Filtro data
                          IF pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND rw_tbgen_trans_pend.dtregistro_transacao NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;
                                
                          --Valor a somar
                          vr_vlasomar := vr_vlaplica;
                          
                          vr_dsvltran := TO_CHAR(vr_vlaplica,'fm999g999g990d00'); -- Valor
                          vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                          vr_dsdescri := 'CANCELAMENTO APLICACAO NR. ' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao); -- Descricao
                          vr_dstptran := 'Cancelamento Aplicação'; -- Tipo de Transacao
                          vr_dsagenda := 'NÃO'; -- Agendamento
                          
                          -- Vai para o primeiro registro
                          vr_ind := vr_saldo_rdca.FIRST; 
                          WHILE vr_ind IS NOT NULL LOOP
                             vl_dtaplica := TO_CHAR(vr_saldo_rdca(vr_ind).dtmvtolt,'DD/MM/RRRR'); --Data da Aplicacao
                             vr_nmdprodu := vr_saldo_rdca(vr_ind).dshistor; --Nome do Produto
                             vr_carencia := vr_saldo_rdca(vr_ind).qtdiacar; --Carencia
                             vr_dtcarenc := TO_CHAR(vr_saldo_rdca(vr_ind).dtcarenc,'DD/MM/RRRR'); --Data da Carencia
                             vr_dtrdavct := TO_CHAR(vr_saldo_rdca(vr_ind).dtvencto,'DD/MM/RRRR'); --Data de Vencimento
                             EXIT;
                          END LOOP;
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 2 THEN --Resgate
                          
                          apli0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                                      ,pr_cdoperad => '996'
                                                      ,pr_nmdatela => 'INTERNETBANK'
                                                      ,pr_idorigem => 3
                                                      ,pr_nrdcaixa => 900
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_idseqttl => 1
                                                      ,pr_cdagenci => 90
                                                      ,pr_cdprogra => 'INTERNETBANK'
                                                      ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                      ,pr_cdprodut => 0
                                                      ,pr_dtmvtolt => pr_dtmvtolt 
                                                      ,pr_idconsul => 2 
                                                      ,pr_idgerlog => 0
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic
                                                      ,pr_saldo_rdca => vr_saldo_rdca);
                                                           
                          --Valor a somar
                          vr_vlasomar := rw_tbcapt_trans_pend.vlresgate;
                                         
                          vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                          vr_dsdescri := 'RESGATE ' || (CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN 'PARCIAL' ELSE 'TOTAL' END) || ' NA APLICACAO NR. ' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao);-- Descricao
                          vr_dstptran := 'Resgate de Aplicação'; -- Tipo de Transacao
                          vr_dsagenda := 'NÃO'; -- Agendamento
                          
                          -- Vai para o primeiro registro
                          vr_ind := vr_saldo_rdca.FIRST; 
                          
                          WHILE vr_ind IS NOT NULL LOOP
                             vr_nmdprodu := vr_saldo_rdca(vr_ind).dshistor; --Nome do Produto
                             vr_dtrdavct := TO_CHAR(vr_saldo_rdca(vr_ind).dtvencto,'DD/MM/RRRR'); --Data de Vencimento
                             vr_sldresga := TO_CHAR(vr_saldo_rdca(vr_ind).sldresga,'fm999g999g990d00'); --Saldo Resgate
                             vr_vlresgat := CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') ELSE vr_sldresga END; --Valor do Resgate
                             EXIT;
                          END LOOP;
                          
                          vr_dsvltran := vr_vlresgat; -- Valor
                          vr_dtresgat := TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR'); --Data do Resgate                          
                          vr_tpresgat := CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN 'PARCIAL' ELSE 'TOTAL' END; --Tipo do Resgate
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 3 THEN --Agendamento Resgate
                          
                          --Valor a somar

                          vr_vlasomar := rw_tbcapt_trans_pend.vlresgate;
                          
                          vr_dsvltran := TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00'); -- Valor
                          --vr_dsdtefet := TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR'); -- Data Efetivacao
               
                          IF rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN
                            vr_dsdtefet := TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR');                    
                          ELSE
                            vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                                             
                            IF (TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR')) <= pr_dtmvtolt THEN 
                               vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(ADD_MONTHS(pr_dtmvtolt,1),'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                            END IF;                    
                          END IF;

                          IF pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;
                          
                          vr_dsdescri := 'RESGATE COM AGENDAMENTO ' || (CASE WHEN rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                          vr_dstptran := 'Agendamento de Resgate'; -- Tipo de Transacao
                          vr_dsagenda := 'SIM'; -- Agendamento                       
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 4 THEN --Cancelamento Total Agendamento
                          APLI0002.pc_consulta_agendamento(pr_cdcooper => pr_cdcooper
                                                          ,pr_flgtipar => 2 -- Todos Agendamentos 
                                                          ,pr_nrdconta => pr_nrdconta 
                                                          ,pr_idseqttl => 0 -- Todos Titulares 
                                                          ,pr_nrctraar => rw_tbcapt_trans_pend.nrdocto_agendamento 
                                                          ,pr_cdsitaar => 0
                                                          ,pr_cdcritic => vr_cdcritic 
                                                          ,pr_dscritic => vr_dscritic
                                                          ,pr_tab_agen => vr_tab_agen);                                                         
                                                   			                  
                          vr_nrindice := vr_tab_agen.FIRST;
                          
                          WHILE vr_nrindice IS NOT NULL LOOP
                              IF vr_tab_agen(vr_nrindice).flgtipar = 0 THEN --Aplicacao
                                 vr_dsdescri := 'CANCELAR APLICACAO COM AGENDAMENTO ' || (CASE WHEN vr_tab_agen(vr_nrindice).flgtipin = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                                 vr_dstptran := 'Cancelamento Agendamento Aplicação'; -- Tipo de Transacao
                                 vr_dsagenda := 'SIM'; -- Agendamento
                              ELSE --Resgate
                                 vr_dsdescri := 'CANCELAR RESGATE COM AGENDAMENTO ' || (CASE WHEN vr_tab_agen(vr_nrindice).flgtipin = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                                 vr_dstptran := 'Cancelamento Agendamento Resgate'; -- Tipo de Transacao
                                 vr_dsagenda := 'SIM'; -- Agendamento
                              END IF;                                
                          
                              --Valor a somar
                              vr_vlasomar := vr_tab_agen(vr_nrindice).vlparaar;
                              vr_flageuni := vr_tab_agen(vr_nrindice).flgtipin;
                              vr_tpagenda := vr_tab_agen(vr_nrindice).flgtipar;
                              vr_nrdiacre := vr_tab_agen(vr_nrindice).dtdiaaar;
                              vr_dsvltran := TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00'); -- Valor
                              vr_dsdtefet := TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR'); -- Data Efetivacao                              
                              vr_qtdmeses := vr_tab_agen(vr_nrindice).qtmesaar; --Durante
                              
                              EXIT;
                          END LOOP; 

                          IF pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;                    
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 5 THEN --Cancelamento Item Agendamento
                          --aplicacao
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                             vr_nrdolote := 32001;
                             vr_cdhistor := 527;
                          ELSE --resgate
                             vr_nrdolote := 32002;
                             vr_cdhistor := 530;
                          END IF;
  												
                          --separar o nrdocmto, pois vem concatenado com nrdolote || nrdocmto 
                          vr_nrdocmto := SUBSTR(rw_tbcapt_trans_pend.nrdocto_agendamento,6,10);
                          
                          APLI0002.pc_consulta_det_agendmto(pr_cdcooper => pr_cdcooper
                                                           ,pr_nrdocmto => vr_nrdocmto
                                                           ,pr_nrdolote => vr_nrdolote
                                                           ,pr_nrdconta => pr_nrdconta
                                                           ,pr_cdhistor => vr_cdhistor
                                                           ,pr_cdcritic => vr_cdcritic
                                                           ,pr_dscritic => vr_dscritic
                                                           ,pr_tab_agen_det => vr_tab_agen_det);
                          
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                            vr_dsdescri := 'CANCELAR AGENDAMENTO APLICAÇÃO';-- Descricao
                            vr_dstptran := 'Cancelamento Agendamento Aplicação'; -- Tipo de Transacao
                            vr_dsagenda := 'SIM'; -- Agendamento
                               
                          ELSE --Resgate
                            vr_dsdescri := 'CANCELAR AGENDAMENTO RESGATE';-- Descricao
                            vr_dstptran := 'Cancelamento Agendamento Resgate'; -- Tipo de Transacao
                            vr_dsagenda := 'SIM'; -- Agendamento                               
                          END IF;
                             
                          vr_nrindice := vr_tab_agen_det.FIRST;
                          
                          WHILE vr_nrindice IS NOT NULL LOOP
                             
                             IF vr_tab_agen_det(vr_nrindice).nrdocmto <> rw_tbcapt_trans_pend.nrdocto_agendamento THEN
                                vr_nrindice := vr_tab_agen_det.NEXT(vr_nrindice);
                                CONTINUE;
                             END IF;
                              
                             --Valor a somar
                             vr_vlasomar := vr_tab_agen_det(vr_nrindice).vllanaut; 
                                
                             vr_dsvltran := TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00'); -- Valor do aplicacao
                             vr_dsdtefet := TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR'); -- Data efetivacao                               
                             
                             EXIT;
                          END LOOP;  
                                
                          IF pr_dtiniper IS NOT NULL AND pr_dtfimper IS NOT NULL AND to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;   
                          
                 END CASE; -- END CASE
               
            WHEN vr_tptranpe = 8 THEN --Debito Automatico
                 
                 OPEN cr_tbconv_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbconv_trans_pend INTO rw_tbconv_trans_pend;
                 IF cr_tbconv_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbconv_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbconv_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 vr_tpopconv := rw_tbconv_trans_pend.tpoperacao;
                 
                 IF rw_tbconv_trans_pend.tpoperacao = 1 THEN --Autorizacao Debito Automatico
                    OPEN cr_crapcon(pr_cdcooper => pr_cdcooper,
                                    pr_cdsegmto => rw_tbconv_trans_pend.cdsegmento_conven,
                                    pr_cdempcon => rw_tbconv_trans_pend.cdconven);
                    FETCH cr_crapcon INTO vr_nmrescon;
                    IF cr_crapcon%NOTFOUND THEN
                       --Fechar Cursor
                       CLOSE cr_crapcon;
                       vr_nmrescon := 'EMPRESA CONVENIADA NAO CADASTRADA';  
                    ELSE
                       --Fechar Cursor
                       CLOSE cr_crapcon;
                    END IF;
                    
                    --Valor a somar
                    vr_vlasomar := 0;
                          
                    vr_dsvltran := '0,00'; -- Valor
                    vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                    vr_dsdescri := 'DEBITO AUTOMATICO - ' || vr_nmrescon;-- Descricao
                    vr_dstptran := 'Autorização Débito Automático'; -- Tipo de Transacao
                    vr_dsagenda := 'NÃO'; -- Agendamento
                        
                    vr_iddebaut := rw_tbconv_trans_pend.iddebito_automatico; --Identificação do Consumidor: 
                    vr_dshistor := rw_tbconv_trans_pend.dshist_debito; --Histórico Complementar
                    vr_vlmaxdeb := TO_CHAR(rw_tbconv_trans_pend.vlmaximo_debito,'fm999g999g990d00'); --Limite Máximo Para Débito
												
								ELSIF rw_tbconv_trans_pend.tpoperacao = 2 OR   --Bloqueio Debito Automatico
								      rw_tbconv_trans_pend.tpoperacao = 3 THEN --Desbloqueio Debito Automatico
                    OPEN cr_autodeb(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_cdhistor => rw_tbconv_trans_pend.cdhist_convenio,
                                    pr_cdrefere => rw_tbconv_trans_pend.nrdocumento_fatura,
                                    pr_dtmvtopg => rw_tbconv_trans_pend.dtdebito_fatura);
                    FETCH cr_autodeb INTO vr_nmrescon,
                                          vr_vllanaut;
                    IF cr_autodeb%NOTFOUND THEN
                       --Fechar Cursor
                       CLOSE cr_autodeb;
                       
                       vr_vllanaut := 0;
                       vr_nmrescon := '';                       
                    ELSE
                       --Fechar Cursor
                       CLOSE cr_autodeb;
                       
                       vr_nmrescon := ' - ' || vr_nmrescon;
                    END IF;
                        
                    --Valor a somar
                    vr_vlasomar := vr_vllanaut;                        
                    
                    vr_dsvltran := TO_CHAR(vr_vllanaut,'fm999g999g990d00'); -- Valor
                    vr_dsdtefet := TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR'); -- Data Efetivacao
                    vr_dsdescri := (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN 'BLOQUEIO' ELSE 'DESBLOQUEIO' END) || ' DEBITO AUTOMATICO ' || vr_nmrescon;-- Descricao
                    vr_dstptran := (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN 'Bloqueio' ELSE 'Desbloqueio' END) || ' Débito Automático'; -- Tipo de Transacao
                    vr_dsagenda := 'NÃO'; -- Agendamento
                          
                    vr_dtdebfat := TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR'); --Data do Débito
                    vr_nrdocfat := rw_tbconv_trans_pend.nrdocumento_fatura; --Documento do Débito                    
							  END IF;
                 
            WHEN vr_tptranpe = 9 THEN --Folha de Pagamento
                 
                 OPEN cr_tbfolha_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbfolha_trans_pend INTO rw_tbfolha_trans_pend;
                 IF cr_tbfolha_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbfolha_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbfolha_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbfolha_trans_pend.vlfolha;
                    
                 vr_dsvltran := TO_CHAR(rw_tbfolha_trans_pend.vlfolha,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := TO_CHAR(rw_tbfolha_trans_pend.dtdebito,'DD/MM/RRRR'); -- Data Efetivacao
                 vr_dsdescri := 'FOLHA DE PAGAMENTO';-- Descricao
                 vr_dstptran := 'Folha de Pagamento'; -- Tipo de Transacao
                 vr_dsagenda := 'NÃO'; -- Agendamento
                 
                 vr_nrqtlnac := rw_tbfolha_trans_pend.nrlanctos; --Quantidade de Lançamentos
                 vr_solestou := CASE WHEN rw_tbfolha_trans_pend.idestouro = 0 THEN 'NÃO' ELSE 'SIM' END; --Solicitado Estouro
                 vr_vltarifa := TO_CHAR(rw_tbfolha_trans_pend.vltarifa,'fm999g999g990d00'); --Valor da Tarifa

            WHEN vr_tptranpe = 10 THEN --Pacote de tarifas
							
						     OPEN cr_pactar(vr_cdtranpe);
								 FETCH cr_pactar INTO rw_pactar;
								 
								 IF cr_pactar%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_pactar;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_pactar;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= vr_nriniseq) OR
                       (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                       CONTINUE;
                    END IF;
                 END IF;
      						
                 vr_vlasomar := 0;
                 vr_dsvltran := '0,00'; -- Valor
                 vr_dsdtefet := 'Mes atual'; -- Data Efetivacao
                 vr_dsdescri := 'SERVIÇOS COOPERATIVOS'; -- Descricao
                 vr_dstptran := 'Adesão de Serviços Cooperativos'; -- Tipo de Transacao
                 vr_dsagenda := 'NÃO'; -- Agendamento
      								 
                 vr_vlpacote := to_char(rw_pactar.vlpacote,'fm999g999g990d00');
                 vr_dspacote := rw_pactar.dspacote;
                 vr_dtinivig := to_char(rw_pactar.dtinivig, 'dd/mm/rrrr');
                 vr_dtdiadeb := rw_pactar.dtdiadeb;     
                  
            WHEN vr_tptranpe = 11 THEN -- DARF/DAS                 
               OPEN cr_tbpagto_darf_das_trans_pend (pr_cddoitem => vr_cdtranpe);
               FETCH cr_tbpagto_darf_das_trans_pend INTO rw_tbpagto_darf_das_trans_pend;
               IF cr_tbpagto_darf_das_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;
                  CONTINUE;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;
				          --Controle de paginação
                  vr_qttotpen := vr_qttotpen + 1;
                  IF ((vr_qttotpen <= vr_nriniseq) OR
                    (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                    CONTINUE;
                  END IF;	
               END IF;

               -- Tipo de Captura (1 => Código de Barras / 2 => Manual)
               vr_tpcaptura := rw_tbpagto_darf_das_trans_pend.tpcaptura;
               vr_dstipcapt := (CASE WHEN vr_tpcaptura = 1 THEN 'Com Código de Barras' ELSE 'Sem Código de Barras' END);
               -- DADOS DO RESUMO
               vr_cdtranpe := rw_tbpagto_darf_das_trans_pend.cdtransacao_pendente;                -- Código Único da Transação
               vr_dsdtefet := CASE WHEN rw_tbpagto_darf_das_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao 
               vr_dsvltran := TO_CHAR(rw_tbpagto_darf_das_trans_pend.vlpagamento,'fm999g999g990d00'); -- Valor (retornar valor total do pagamento)
               vr_dsdescri := TRIM((CASE
                                WHEN TRIM(rw_tbpagto_darf_das_trans_pend.dsidentif_pagto) IS NULL THEN 
                                  (CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 
                                    THEN 'Pagamento de DARF' ELSE 'Pagamento de DAS' END) 
                                ELSE TRIM(rw_tbpagto_darf_das_trans_pend.dsidentif_pagto) END));  -- Descrição
               vr_dstptran := (CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 THEN
                                'Pagamento de DARF' ELSE 'Pagamento de DAS' END);                 -- Tipo da Transação
               vr_dsagenda := (CASE WHEN rw_tbpagto_darf_das_trans_pend.IDAGENDAMENTO = 1 THEN
                               'NAO' ELSE 'SIM' END);                                             -- Indicador de Agendamento
               vr_dsnomfone := rw_tbpagto_darf_das_trans_pend.dsnome_fone;
                 
               --DADOS ESPECIFICOS
               IF vr_tpcaptura = 1 THEN
                 vr_dslinha_digitavel := rw_tbpagto_darf_das_trans_pend.dslinha_digitavel; -- Linha Digitável
                 vr_dscod_barras := rw_tbpagto_darf_das_trans_pend.dscod_barras; -- Código de Barras
               ELSIF vr_tpcaptura = 2 THEN 
                 vr_dtapuracao      := rw_tbpagto_darf_das_trans_pend.dtapuracao;
                 vr_nrcpfgui        := rw_tbpagto_darf_das_trans_pend.nrcpfcgc;
                 vr_cdtributo       := NVL(rw_tbpagto_darf_das_trans_pend.cdtributo,'0');
                 vr_nrrefere        := NVL(rw_tbpagto_darf_das_trans_pend.nrrefere,0);
                 vr_dtvencto        := TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtvencto,'dd/mm/RRRR');
                 vr_vlprincipal     := NVL(rw_tbpagto_darf_das_trans_pend.vlprincipal,0);
                 vr_vlmulta         := NVL(rw_tbpagto_darf_das_trans_pend.vlmulta,0);
                 vr_vljuros         := NVL(rw_tbpagto_darf_das_trans_pend.vljuros,0);
                 vr_vlreceita_bruta := NVL(rw_tbpagto_darf_das_trans_pend.vlreceita_bruta,0);
                 vr_vlpercentual    := NVL(rw_tbpagto_darf_das_trans_pend.vlpercentual,0);
               END IF; 
               vr_vlrtotal        := NVL(rw_tbpagto_darf_das_trans_pend.vlpagamento,0);
               vr_dtdebito        := TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtdebito,'DD/MM/RRRR');
               vr_idagendamento   := NVL(rw_tbpagto_darf_das_trans_pend.idagendamento,0); 
               vr_vlasomar        := vr_vlrtotal;            
            
			WHEN vr_tptranpe = 12 THEN --Desconto de cheque
							
			 OPEN cr_tbdscc_trans_pend(vr_cdtranpe);
			 FETCH cr_tbdscc_trans_pend INTO rw_tbdscc_trans_pend;
    							 
			 IF cr_tbdscc_trans_pend%NOTFOUND THEN
                --Fechar Cursor
				CLOSE cr_tbdscc_trans_pend;
                CONTINUE;
              ELSE
                --Fechar Cursor
				CLOSE cr_tbdscc_trans_pend;
                        
                --Controle de paginação
                vr_qttotpen := vr_qttotpen + 1;
                IF ((vr_qttotpen <= vr_nriniseq) OR
                   (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                   CONTINUE;
                END IF;
              END IF;
              
			 vr_dsagenda := 'NÃO'; -- Agendamento
						 vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
			 vr_dsdescri := 'Bordero de Desconto de Cheques';
							 vr_dstptran := 'Bordero de Desconto de Cheques';
							 vr_dsvltran := to_char(rw_tbdscc_trans_pend.vltotchq,'fm999g999g990d00');
			 vr_vltotchq := to_char(rw_tbdscc_trans_pend.vltotchq,'fm999g999g990d00');
							 vr_dtdebito := to_char(rw_tbdscc_trans_pend.dtmvtolt,'DD/MM/RRRR');
			 vr_qtcheque := rw_tbdscc_trans_pend.qtcheque;
			 vr_vlasomar := rw_tbdscc_trans_pend.vltotchq;   
              
            WHEN vr_tptranpe = 13 THEN
              OPEN cr_tbrecarga_trans_pend(vr_cdtranpe);
              FETCH cr_tbrecarga_trans_pend INTO rw_tbrecarga_trans_pend;
    							 
              IF cr_tbrecarga_trans_pend%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_tbrecarga_trans_pend;
                CONTINUE;
              ELSE
                --Fechar Cursor
                CLOSE cr_tbrecarga_trans_pend;
                        
                --Controle de paginação
                vr_qttotpen := vr_qttotpen + 1;
                IF ((vr_qttotpen <= vr_nriniseq) OR
                   (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                   CONTINUE;
                END IF;
              END IF;
              
              vr_dsagenda := CASE WHEN rw_tbrecarga_trans_pend.tprecarga = 1
                                  THEN 'NÃO' ELSE
                                  'SIM'
                              END;
              
              vr_dsdtefet := CASE WHEN rw_tbrecarga_trans_pend.tprecarga = 1
                                  THEN 'Nesta Data' ELSE
                                  to_char(rw_tbrecarga_trans_pend.dtrecarga,'DD/MM/RRRR')
                                END; -- Data Efetivacao
              
              vr_dsdescri := rw_tbrecarga_trans_pend.telefone || ' – ' || rw_tbrecarga_trans_pend.nmproduto;
              vr_dstptran := 'Recarga de Celular';
              vr_dsvltran := to_char(rw_tbrecarga_trans_pend.vlrecarga,'fm999g999g990d00');
              vr_telefone := rw_tbrecarga_trans_pend.telefone;
              vr_vlrecarga := to_char(rw_tbrecarga_trans_pend.vlrecarga,'fm999g999g990d00');
              vr_dtrecarga := to_char(rw_tbrecarga_trans_pend.dtrecarga,'DD/MM/RRRR');
              vr_dttransa := to_char(rw_tbrecarga_trans_pend.dttransa,'DD/MM/RRRR');
              vr_nmproduto := rw_tbrecarga_trans_pend.nmproduto;
              vr_vlasomar := rw_tbrecarga_trans_pend.vlrecarga;
              
            WHEN vr_tptranpe IN(14,15) THEN -- FGTS/DAE
               --> Buscar detalhes transacoes pendente
               OPEN cr_tbtrib_pend (pr_cddoitem => vr_cdtranpe);
               FETCH cr_tbtrib_pend INTO rw_tbtrib_pend;
               IF cr_tbtrib_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbtrib_pend;
                  CONTINUE;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_tbtrib_pend;
				          --Controle de paginação
                  vr_qttotpen := vr_qttotpen + 1;
                IF ((vr_qttotpen <= vr_nriniseq) OR
                   (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                    CONTINUE;
                  END IF;	
               END IF;
                 
               --Valor a somar  
               vr_vlasomar := rw_tbtrib_pend.vlpagamento;
               --Variaveis do resumo                   
               vr_dsvltran := TO_CHAR(rw_tbtrib_pend.vlpagamento,'fm999g999g990d00');                   
               vr_dsdtefet := CASE 
                                WHEN rw_tbtrib_pend.idagendamento = 1 THEN 'Nesta Data' 
                                ELSE TO_CHAR(rw_tbtrib_pend.dtdebito,'DD/MM/RRRR')  -- Data Efetivacao     
                              END;             
               IF vr_tptranpe = 14 THEN
                 vr_dstptran := 'Pagamento de FGTS';
               ELSIF vr_tptranpe = 15 THEN  
                 vr_dstptran := 'Pagamento de DAE';
               END IF;
               
               -- Agendamento
               vr_dsagenda := CASE 
                                WHEN rw_tbtrib_pend.idagendamento = 1 THEN 'NÃO' 
                                ELSE 'SIM' 
                              END; 
               
               vr_dsdescri          := rw_tbtrib_pend.dsidenti_pagto;
               vr_dsidenti_pagto    := rw_tbtrib_pend.dsidenti_pagto;     -- Identificação do Pagamento 
               vr_dscod_barras      := rw_tbtrib_pend.dscod_barras  ;     -- Código de Barras    
               vr_dslinha_digitavel := rw_tbtrib_pend.dslinha_digitavel ; -- Linha Digitável    
               vr_vlrtotal          := rw_tbtrib_pend.vlpagamento  ;      -- Valor Total   
               vr_dtdebito          := to_char(rw_tbtrib_pend.dtdebito, 'DD/MM/RRRR') ;          -- Débito Em   
               vr_idagendamento     := NVL(rw_tbtrib_pend.idagendamento,0);   
               
							 gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => trim(rw_tbtrib_pend.nridentificacao)    -- CNPJ / CEI Empresa / CPF  
																					,pr_stsnrcal => vr_stsnrcal
																					,pr_inpessoa => vr_inpessoa);							 
							 
               --Variaveis especificas FGTS: tipo 14                              
               vr_nridentificacao   := CASE WHEN vr_stsnrcal THEN gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbtrib_pend.nridentificacao
							                                                                             ,pr_inpessoa => vr_inpessoa)
																						ELSE rw_tbtrib_pend.nridentificacao END;
               vr_cdtributo         := rw_tbtrib_pend.cdtributo  ;        -- Cod. Convênio  
               vr_dtvencto          := to_char(rw_tbtrib_pend.dtvalidade, 'DD/MM/RRRR');       -- Data da Validade   
               vr_dtapuracao        := rw_tbtrib_pend.dtcompetencia  ;    -- Competência      
               vr_nrseqgrde         := rw_tbtrib_pend.nrseqgrde  ;        -- Sequencial da GRDE                 
               vr_nridentificador   := rw_tbtrib_pend.nridentificador  ;  -- Identificador   
               
               --Variaveis especificas DAE: tipo 15 
               vr_nrdocdae          := rw_tbtrib_pend.nridentificador  ;  -- Número Documento (DAE)                     
               
            --> CONTRATO DE SMS
            WHEN vr_tptranpe IN (16,17) THEN
            
              --> Contrato de SMS - Transacao 16
              OPEN cr_sms_trans_pend (pr_cdtransa => vr_cdtranpe);
              FETCH cr_sms_trans_pend INTO rw_sms_trans_pend;
              IF cr_sms_trans_pend%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_sms_trans_pend;
                CONTINUE;            
            ELSE
                CLOSE cr_sms_trans_pend;
              END IF;
              
              --Valor a somar
              vr_vlasomar := 0;
                 
              --Variaveis do resumo
              vr_dsvltran := '0,00'; -- Valor
              vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
              vr_dsdescri := rw_sms_trans_pend.dspacote; -- Descricao
              IF vr_tptranpe IN (16) THEN
                vr_dstptran := 'Adesão Serviço SMS de Cobrança'; -- Tipo de Transacao
                vr_dsdescri := 'Adesão SMS de Cobrança - '||rw_sms_trans_pend.dspacote; -- Descricao
              ELSE
                vr_dstptran := 'Cancelamento do Serviço SMS de Cobrança'; -- Tipo de Transacao
                vr_dsdescri := 'Cancelamento SMS de Cobrança - '||rw_sms_trans_pend.dspacote; -- Descricao
              END IF;
              vr_dsagenda := 'NÃO'; -- Agendamento  

              -- Início SM 454.1
      WHEN vr_tptranpe = 18 THEN --Resgate de cheque em Custódia
      							
       OPEN cr_tbcst_trans_pend_det(vr_cdtranpe);
       FETCH cr_tbcst_trans_pend_det INTO rw_tbcst_trans_pend_det;
          							 
       IF cr_tbcst_trans_pend_det%NOTFOUND THEN
                --Fechar Cursor
        CLOSE cr_tbcst_trans_pend_det;
                CONTINUE;
            ELSE
                --Fechar Cursor
        CLOSE cr_tbcst_trans_pend_det;
                              
                --Controle de paginação
                vr_qttotpen := vr_qttotpen + 1;
                IF ((vr_qttotpen <= vr_nriniseq) OR
                   (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                   CONTINUE;
                END IF;
              END IF;
                    
              vr_dsagenda := 'NÃO'; -- Agendamento  
             vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
       vr_dsdescri := 'Bordero de Resgate de Cheques em Custódia';
               vr_dstptran := 'Bordero de Resgate de Cheques em Custódia';
               vr_dsvltran := to_char(rw_tbcst_trans_pend_det.vltotchq,'fm999g999g990d00');
       vr_vltotchq := to_char(rw_tbcst_trans_pend_det.vltotchq,'fm999g999g990d00');
               vr_dtdebito := to_char(rw_tbcst_trans_pend_det.dtmvtolt,'DD/MM/RRRR');
       vr_qtcheque := rw_tbcst_trans_pend_det.qtcheque;
       vr_vlasomar := rw_tbcst_trans_pend_det.vltotchq;   
--Fim SM 454.1  

	 WHEN vr_tptranpe = 19 THEN --Bordero Desconto de titulo
	   OPEN  cr_tbdsct_trans_pend(vr_cdtranpe);
	   FETCH cr_tbdsct_trans_pend INTO rw_tbdsct_trans_pend;
	
 	   IF cr_tbdsct_trans_pend%NOTFOUND THEN
	     CLOSE cr_tbdsct_trans_pend;
         CONTINUE;
       ELSE
		 CLOSE cr_tbdsct_trans_pend;
         --Controle de paginação
         vr_qttotpen := vr_qttotpen + 1;
         IF  ((vr_qttotpen <= vr_nriniseq) OR
              (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
           CONTINUE;
         END IF;
       END IF;

	     vr_dsagenda := 'NÃO'; -- Agendamento
	     vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
		 vr_dsdescri := 'Bordero de Desconto de Titulos';
		 vr_dstptran := 'Bordero de Desconto de Titulos';
		 vr_dsvltran := to_char(rw_tbdsct_trans_pend.vltotbdt,'fm999g999g990d00');
		 vr_vltotbdt := to_char(rw_tbdsct_trans_pend.vltotbdt,'fm999g999g990d00');
		 vr_dtdebito := to_char(rw_tbdsct_trans_pend.dtmvtolt,'DD/MM/RRRR');
		 vr_qttitulo := rw_tbdsct_trans_pend.qttitulo;
		 vr_vlasomar := rw_tbdsct_trans_pend.vltotbdt;
		
      --inicio pj470
      WHEN vr_tptranpe = 20 THEN

      OPEN cr_tbctd_trans_pend(vr_cdtranpe);
      FETCH cr_tbctd_trans_pend 
      INTO rw_cr_tbctd_trans_pend;
      
      --
      IF cr_tbctd_trans_pend%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_tbctd_trans_pend;
        CONTINUE;
            ELSE
      
        --Fechar Cursor
        CLOSE cr_tbctd_trans_pend;
        
        --Controle de paginação
        vr_qttotpen := vr_qttotpen + 1;
        IF ((vr_qttotpen <= vr_nriniseq) OR (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
           CONTINUE;
        END IF;
      
      END IF;
 
            vr_dsdescri := rw_cr_tbctd_trans_pend.dscontrato;
            vr_dstptran := 'Autorização de Contrato';
            vr_nrcntato := rw_cr_tbctd_trans_pend.nrcontrato;
            vr_dsoritra := 'Posto de Atendimento';
            vr_dsvltran := TO_CHAR(rw_cr_tbctd_trans_pend.vlcontrato,'fm999g999g990d00');
            vr_dsdtefet := NULL;
      --Fim PJ470  

      WHEN vr_tptranpe = 21 THEN -- Emprestimos/Financiamentos
      --/
       OPEN cr_pend_efet_proposta(pr_cddoitem => vr_cdtranpe);
         FETCH cr_pend_efet_proposta INTO rw_pend_efet_proposta;
          IF cr_pend_efet_proposta%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_pend_efet_proposta;
              CONTINUE;
          ELSE
              --Fechar Cursor
              CLOSE cr_pend_efet_proposta;
                      
              --Controle de paginação
              vr_qttotpen := vr_qttotpen + 1;
            IF ((vr_qttotpen <= vr_nriniseq) OR
                   (vr_qttotpen > (vr_nriniseq + pr_nrregist))) AND NVL(pr_nrregist,0) > 0 THEN
                   CONTINUE;
            END IF;
          END IF;
           --
           --/Valor a somar
           vr_vlasomar := rw_pend_efet_proposta.vlemprst;
           --
           --/Variaveis resumo
           vr_dsvltran := TO_CHAR(rw_pend_efet_proposta.vlemprst,'fm999g999g990d00'); -- Valor
           vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
           vr_dsdescri := 'Proposta de Emprestimo/Financiamento - ' || TO_CHAR(rw_pend_efet_proposta.nrparcelas) || ' vezes de R$ ' || TO_CHAR(rw_pend_efet_proposta.vlparcela,'fm999g999g990d00'); -- Descricao
           vr_dstptran := 'Emprestimo/Financiamento'; -- Tipo de Transacao
           vr_dsagenda := 'NÃO'; -- Agendamento
           --  
           -- Variaveis especificas
           vr_qtdparce_ef := rw_pend_efet_proposta.nrparcelas; --Quantidade de Parcelas
           vr_vldparce_ef := TO_CHAR(rw_pend_efet_proposta.vlparcela,'fm999g999g990d00'); --Valor da Parcela
           vr_dtpriven_ef := TO_CHAR(rw_pend_efet_proposta.dtprimeiro_vencto,'DD/MM/RRRR'); --Primeiro Vencimento
           vr_vlpercet_ef := TO_CHAR(rw_pend_efet_proposta.vlpercentual_cet,'fm999g999g990d00'); --CET
           vr_vltarifa_ef := TO_CHAR(rw_pend_efet_proposta.vltarifa,'fm999g999g990d00'); --Tarifa
           vr_vltaxmen_ef := TO_CHAR(rw_pend_efet_proposta.vltaxa_mensal,'fm999g999g990d00'); --Taxa Mensal
           vr_vlrdoiof_ef := TO_CHAR(rw_pend_efet_proposta.vliof,'fm999g999g990d00'); --IOF
           vr_vlperiof_ef := TO_CHAR(rw_pend_efet_proposta.vlpercentual_iof,'fm999g999g990d0000'); --Percentual IOF
           --
         ELSE

                vr_dscritic := 'Tipo de transação não encontrado.';
                --Levantar Excecao
                RAISE vr_exc_erro;
         END CASE; --case     
         
         --Soma Total da pagina
         vr_vltotpen := vr_vltotpen + vr_vlasomar;
         
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<transacao>');
         -- PJ470
         IF vr_tptranpe <> 20 THEN
           vr_dsdata_debito := '   <data_debito>' || CASE WHEN UPPER(vr_dsdtefet) = 'NESTA DATA' THEN TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR') 
                                                          WHEN UPPER(vr_dsdtefet) = 'MES ATUAL' THEN TO_CHAR(TRUNC(pr_dtmvtolt,'MM'),'DD/MM/RRRR') 
                                                          ELSE vr_dsdtefet 
                                                      END || '</data_debito>';
         ELSE
           vr_dsdata_debito := NULL;
         END IF;
         -- Fim PJ470
         --Resumo da transacao
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<dados_resumo>'
                                                   || '   <codigo_transacao>'   ||vr_cdtranpe||'</codigo_transacao>'
                                                   || '   <data_efetivacao>'    ||vr_dsdtefet||'</data_efetivacao>'
                                                   || '   <valor_transacao>'    ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor_transacao>'
                                                   || '   <descricao_transacao>'||vr_dsdescri||'</descricao_transacao>'
                                                   || '   <id_tipo_transacao>'  ||vr_tptranpe||'</id_tipo_transacao>'
                                                   || '   <tipo_transacao>'     ||vr_dstptran||'</tipo_transacao>'
                                                   || '   <agendamento>'        ||vr_dsagenda||'</agendamento>'
                                                   || '   <situacao_transacao>' ||vr_dssittra||'</situacao_transacao>'
                                                   || '   <data_alteracao_sit>' ||vr_dtaltera||'</data_alteracao_sit>'
                                                   || '   <pode_alterar>'       ||vr_indiacao||'</pode_alterar>'
                                                   || '   <idsituacao_transacao>' ||vr_idsittra||'</idsituacao_transacao>'
                                                   || vr_dsdata_debito -- PJ470
                                                   || '   <data_sistema>' || TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR') || '</data_sistema>'
                                                   || '   <data_cadastro>' || vr_dttranpe || '</data_cadastro>'
                                                   || '</dados_resumo>');

         --Detalhes da Transacao
         vr_xml_auxi := '<dados_detalhe>';
         
         --Dados genericos
         vr_xml_auxi := vr_xml_auxi
         || '   <dados_campo><label>'||vr_labnmage||'</label><valor>'   ||vr_nmagenda||'</valor></dados_campo>'
         || '   <dados_campo><label>Data da Transação</label><valor>'   ||vr_dttranpe||'</valor></dados_campo>'
         || '   <dados_campo><label>Hora da Transação</label><valor>'   ||vr_hrtranpe||'</valor></dados_campo>'
         || '   <dados_campo><label>Data de Movimentação</label><valor>'||vr_dtmvttra||'</valor></dados_campo>'
         || '   <dados_campo><label>Situação</label><valor>'            ||vr_dssittra||'</valor></dados_campo>'
         || '   <dados_campo><label>Tipo de Transação</label><valor>'   ||vr_dstptran||'</valor></dados_campo>'
         || '   <dados_campo><label>Origem da Transação</label><valor>' ||vr_dsoritra||'</valor></dados_campo>'
         || CASE WHEN TRIM(vr_dtreptra) IS NOT NULL THEN '<dados_campo><label>Data da Reprovação</label><valor>'  ||vr_dtreptra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtexctra) IS NOT NULL THEN '<dados_campo><label>Data da Exclusão</label><valor>'    ||vr_dtexctra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtexptra) IS NOT NULL THEN '<dados_campo><label>Data de Expiração</label><valor>'   ||vr_dtexptra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dscritra) IS NOT NULL THEN '<dados_campo><label>Crítica de Validação</label><valor>'||vr_dscritra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtvalida) IS NOT NULL THEN '<dados_campo><label>Data da Validação</label><valor>'   ||vr_dtvalida||'</valor></dados_campo>' ELSE ' ' END;
         
         --Dados especificos
         IF vr_tptranpe IN (1,3,5) THEN --Transferencia
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Cooperativa Destino</label><valor>'     ||vr_cdcopdes||'</valor></dados_campo>'
            || '<dados_campo><label>Conta Destino</label><valor>'           ||vr_nrcondes||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Transferência</label><valor>'  ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdebito||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';
         ELSIF vr_tptranpe = 2 THEN --Pagamento
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Cedente</label><valor>'                 ||vr_nmcednte||'</valor></dados_campo>'
            || '<dados_campo><label>Código de Barras</label><valor>'        ||vr_nrcodbar||'</valor></dados_campo>'
            || '<dados_campo><label>Linha Digitável</label><valor>'         ||vr_dslindig||'</valor></dados_campo>'
            || '<dados_campo><label>Data do Vencimento</label><valor>'      ||vr_dtvencto||'</valor></dados_campo>'
            || '<dados_campo><label>Valor do Documento</label><valor>'      ||vr_vldocmto||'</valor></dados_campo>'
            || '<dados_campo><label>Valor do Pagamento</label><valor>'      ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdebito||'</valor></dados_campo>'
            || '<dados_campo><label>Identificação DDA</label><valor>'       ||vr_identdda||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';
         ELSIF vr_tptranpe IN (4,22) THEN --TED /*REQ39*/
              IF vr_tptranpe = 4 THEN
                vr_xml_auxi := vr_xml_auxi
                || '<dados_campo><label>Banco do Favorecido</label><valor>'     ||vr_nmbanfav||'</valor></dados_campo>'
                || '<dados_campo><label>ISPB</label><valor>'                    ||vr_nmdoispb||'</valor></dados_campo>'
                || '<dados_campo><label>Agência do Favorecido</label><valor>'   ||vr_nmagenci||'</valor></dados_campo>'
                || '<dados_campo><label>Conta do Favorecido</label><valor>'     ||vr_nrctafav||'</valor></dados_campo>'
                || '<dados_campo><label>Nome do Favorecido</label><valor>'      ||vr_nomdofav||'</valor></dados_campo>'
                || '<dados_campo><label>CPF/CNPJ do Favorecido</label><valor>'  ||vr_cpfcgcfv||'</valor></dados_campo>'
                || '<dados_campo><label>Finalidade</label><valor>'              ||vr_dsfindad||'</valor></dados_campo>'
                || '<dados_campo><label>Histórico Complementar</label><valor>'  ||vr_dshistco||'</valor></dados_campo>'
                || '<dados_campo><label>Código Identificador</label><valor>'    ||vr_cdidenti||'</valor></dados_campo>'
                || '<dados_campo><label>Valor da TED</label><valor>'            ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdodebi||'</valor></dados_campo>'
                || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';            
              ELSE
                vr_xml_auxi := vr_xml_auxi
                || '<dados_campo><label>Banco do Favorecido</label><valor>'     ||vr_nmbanfav||'</valor></dados_campo>'
                || '<dados_campo><label>ISPB</label><valor>'                    ||vr_nmdoispb||'</valor></dados_campo>'
                || '<dados_campo><label>Finalidade</label><valor>'              ||vr_dsfindad||'</valor></dados_campo>'
                || '<dados_campo><label>Código Identificador</label><valor>'    ||vr_cdidenti||'</valor></dados_campo>'
                || '<dados_campo><label>Valor da TED</label><valor>'            ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdodebi||'</valor></dados_campo>'
                || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';            
              END IF;                
         ELSIF vr_tptranpe = 6 THEN --Credito Pre-Aprovado
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor do Crédito</label><valor>'      ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Parcelas</label><valor>'||vr_qtdparce||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Parcela</label><valor>'      ||vr_vldparce||'</valor></dados_campo>'
            || '<dados_campo><label>Primeiro Vencimento</label><valor>'   ||vr_dtpriven||'</valor></dados_campo>'
            || '<dados_campo><label>CET</label><valor>'                   ||vr_vlpercet||'</valor></dados_campo>'
            || '<dados_campo><label>Tarifa</label><valor>'                ||vr_vltarifa||'</valor></dados_campo>'
            || '<dados_campo><label>Taxa Mensal</label><valor>'           ||vr_vltaxmen||'</valor></dados_campo>'
            || '<dados_campo><label>IOF</label><valor>'                   ||vr_vlrdoiof||'</valor></dados_campo>';
         /*   || '<dados_campo><label>Percentual IOF</label><valor>'        ||vr_vlperiof||'</valor></dados_campo>';  */
         ELSIF vr_tptranpe = 7 THEN --Aplicacao
            IF vr_tpopeapl = 1 THEN --Cancelamento Aplicacao
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Número da Aplicação</label><valor>'||vr_nraplica||'</valor></dados_campo>'
               || '<dados_campo><label>Valor da Aplicação</label><valor>' ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
               || '<dados_campo><label>Data da Aplicação</label><valor>'  ||vl_dtaplica||'</valor></dados_campo>'
               || '<dados_campo><label>Nome do Produto</label><valor>'    ||vr_nmdprodu||'</valor></dados_campo>'
               || '<dados_campo><label>Carência</label><valor>'           ||vr_carencia||'</valor></dados_campo>'
               || '<dados_campo><label>Data da Carência</label><valor>'   ||vr_dtcarenc||'</valor></dados_campo>'
               || '<dados_campo><label>Data de Vencimento</label><valor>' ||vr_dtrdavct||'</valor></dados_campo>';
            ELSIF vr_tpopeapl = 2 THEN --Resgate
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Número da Aplicação</label><valor>'||vr_nraplica||'</valor></dados_campo>'
               || '<dados_campo><label>Nome do Produto</label><valor>'    ||vr_nmdprodu||'</valor></dados_campo>'
               || '<dados_campo><label>Data de Vencimento</label><valor>' ||vr_dtrdavct||'</valor></dados_campo>'
               || '<dados_campo><label>Saldo para Resgate</label><valor>' ||vr_sldresga||'</valor></dados_campo>'
               || '<dados_campo><label>Data do Resgate</label><valor>'    ||vr_dtresgat||'</valor></dados_campo>'
               || '<dados_campo><label>Valor do Resgate</label><valor>'   ||vr_vlresgat||'</valor></dados_campo>'
               || '<dados_campo><label>Tipo do Resgate</label><valor>'    ||vr_tpresgat||'</valor></dados_campo>';
            ELSIF vr_tpopeapl = 3 THEN --Agendamento Resgate
               IF vr_flageuni = 0 THEN -- Agendamento Único
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                  || '<dados_campo><label>Data do Resgate</label><valor>' ||vr_dsdtefet||'</valor></dados_campo>';
               ELSIF vr_flageuni = 1 THEN --Agendamento Mensal
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                  || '<dados_campo><label>Creditar no Dia</label><valor>' ||vr_nrdiacre||'</valor></dados_campo>'
                  || '<dados_campo><label>Durante</label><valor>'         ||vr_qtdmeses||'</valor></dados_campo>'
                  || '<dados_campo><label>Iniciando Em</label><valor>'    ||vr_dsdtefet||'</valor></dados_campo>';
               END IF;
            ELSIF vr_tpopeapl = 4 THEN --Cancelamento Total Agendamento
               IF vr_flageuni = 0 THEN --Unico
                  IF vr_tpagenda = 1 THEN --Resgate
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor do Resgate</label><valor>'     ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                     || '<dados_campo><label>Data do Resgate</label><valor>'      ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  ELSE --Aplicacao
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                     || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  END IF;
               ELSIF vr_flageuni = 1 THEN --Mensal
                  IF vr_tpagenda = 1 THEN --Resgate
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor do Resgate</label><valor>'     ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                     || '<dados_campo><label>Creditar no Dia</label><valor>'      ||vr_nrdiacre||'</valor></dados_campo>'
                     || '<dados_campo><label>Durante</label><valor>'              ||vr_qtdmeses||'</valor></dados_campo>'
                     || '<dados_campo><label>Iniciando Em</label><valor>'         ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  ELSE --Aplicacao
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                     || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_nrdiacre||'</valor></dados_campo>'
                     || '<dados_campo><label>Durante</label><valor>'              ||vr_qtdmeses||'</valor></dados_campo>'
                     || '<dados_campo><label>Iniciando Em</label><valor>'         ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  END IF;   
               END IF;
            ELSIF vr_tpopeapl = 5 THEN --Cancelamento Item Agendamento
               IF vr_tpagenda = 0 THEN --Aplicacao
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                  || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_dsdtefet||'</valor></dados_campo>'
                  || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                  || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';   
               ELSE --Resgate
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'     ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
                  || '<dados_campo><label>Data do Resgate</label><valor>'      ||vr_dsdtefet||'</valor></dados_campo>'
                  || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                  || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';   
               END IF;
            END IF;
         ELSIF vr_tptranpe = 8 THEN --Debito Automatico
            IF vr_tpopconv = 1 THEN --Autorizacao Debito Automatico
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Empresa Conveniada</label><valor>'         ||vr_nmrescon||'</valor></dados_campo>'
               || '<dados_campo><label>Identificação do Consumidor</label><valor>'||vr_iddebaut||'</valor></dados_campo>'
               || '<dados_campo><label>Histórico Complementar</label><valor>'     ||vr_dshistor||'</valor></dados_campo>'
               || '<dados_campo><label>Limite Máximo Para Débito</label><valor>'  ||vr_vlmaxdeb||'</valor></dados_campo>';
            ELSIF vr_tpopconv = 2 OR   --Bloqueio Debito Automatico
                  vr_tpopconv = 3 THEN --Desbloqueio Debito Automatico
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Empresa Conveniada</label><valor>' ||vr_nmrescon||'</valor></dados_campo>'
               || '<dados_campo><label>Data do Débito</label><valor>'     ||vr_dtdebfat||'</valor></dados_campo>'
               || '<dados_campo><label>Valor do Débito</label><valor>'    ||vr_vllanaut||'</valor></dados_campo>'
               || '<dados_campo><label>Documento do Débito</label><valor>'||vr_nrdocfat||'</valor></dados_campo>';
            END IF;
         ELSIF vr_tptranpe = 9 THEN --Folha de Pagamento
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor do Pagamento</label><valor>'       ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Lançamentos</label><valor>'||vr_nrqtlnac||'</valor></dados_campo>'
            || '<dados_campo><label>Solicitado Estouro</label><valor>'       ||vr_solestou||'</valor></dados_campo>'
            || '<dados_campo><label>Data de Débito</label><valor>'           ||vr_dsdtefet||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Tarifa</label><valor>'          ||vr_vltarifa||'</valor></dados_campo>';
		     ELSIF vr_tptranpe = 10 THEN --Pacote de Tarifas
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Serviço</label><valor>'           ||vr_dspacote||'</valor></dados_campo>'
            || '<dados_campo><label>Valor</label><valor>'             ||vr_vlpacote||'</valor></dados_campo>'
            || '<dados_campo><label>Dia do Débito</label><valor>'     ||vr_dtdiadeb||'</valor></dados_campo>'
            || '<dados_campo><label>Início da Vigência</label><valor>'||vr_dtinivig||'</valor></dados_campo>';
         ELSIF vr_tptranpe = 11 THEN --Pagamento DARF/DAS          

            vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Tipo de Captura</label><valor>'||vr_dstipcapt||'</valor></dados_campo>';
            
            IF TRIM(vr_dsdescri) IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Identificação do Pagamento</label><valor>'||vr_dsdescri||'</valor></dados_campo>';
            END IF;
            
            IF TRIM(vr_dsnomfone) IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi|| '<dados_campo><label>Nome e Telefone</label><valor>'||vr_dsnomfone||'</valor></dados_campo>';
            END IF;

            IF vr_tpcaptura = 1 THEN
              vr_xml_auxi := vr_xml_auxi
              || '<dados_campo><label>Código de Barras</label><valor>'||vr_dscod_barras||'</valor></dados_campo>'
              || '<dados_campo><label>Linha Digitável</label><valor>'||vr_dslinha_digitavel||'</valor></dados_campo>';
            ELSIF vr_tpcaptura = 2 THEN
              vr_xml_auxi := vr_xml_auxi
              || '<dados_campo><label>Período de Apuração</label><valor>'||TO_CHAR(vr_dtapuracao,'dd/mm/RRRR')||'</valor></dados_campo>'
              || '<dados_campo><label>Número do CPF ou CNPJ</label><valor>'||TO_CHAR(vr_nrcpfgui)||'</valor></dados_campo>'
              || '<dados_campo><label>Código da Receita</label><valor>'|| TO_CHAR(vr_cdtributo) ||'</valor></dados_campo>';
              
              vr_xml_auxi := vr_xml_auxi   
              || '<dados_campo><label>Valor do Principal</label><valor>'||TO_CHAR(vr_vlprincipal,'fm999g999g990d00')||'</valor></dados_campo>'
              || '<dados_campo><label>Valor da Multa</label><valor>'||TO_CHAR(vr_vlmulta,'fm999g999g990d00')||'</valor></dados_campo>'
              || '<dados_campo><label>Valor dos Juros</label><valor>'||TO_CHAR(vr_vljuros,'fm999g999g990d00')||'</valor></dados_campo>';
            END IF;

            vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Valor Total</label><valor>'||TO_CHAR(vr_vlrtotal,'fm999g999g990d00')||'</valor></dados_campo>';           

            IF vr_tpcaptura = 2 THEN
              IF vr_cdtributo = '6106' THEN
                vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Receita Bruta Acumulada</label><valor>'||TO_CHAR(vr_vlreceita_bruta,'fm999g999g990d00')||'</valor></dados_campo>'
                                           || '<dados_campo><label>Percentual</label><valor>'||TO_CHAR(vr_vlpercentual,'fm999g999g990d00')||'</valor></dados_campo>';
              ELSE
                vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Data de Vencimento</label><valor>'||vr_dtvencto||'</valor></dados_campo>'
                                           || '<dados_campo><label>Número de Referência</label><valor>'||vr_nrrefere||'</valor></dados_campo>';
              END IF;
            END IF;           

            vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Débito Em</label><valor>'||vr_dtdebito||'</valor></dados_campo>'
                                       || '<dados_campo><label>Indicador de Agendamento</label><valor>'||(CASE WHEN vr_idagendamento = 1 THEN
                                                                                                          'NAO' ELSE 'SIM' END)||'</valor></dados_campo>';
 
         ELSIF vr_tptranpe = 12 THEN -- Desconto de Cheques
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor Total</label><valor>'          ||vr_vltotchq||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Cheques</label><valor>'||vr_qtcheque||'</valor></dados_campo>';
            
         ELSIF vr_tptranpe = 13 THEN -- Recarga de Celular
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor</label><valor>'                   ||vr_vlrecarga||'</valor></dados_campo>'
            || '<dados_campo><label>Operadora</label><valor>'               ||vr_nmproduto||'</valor></dados_campo>'
            || '<dados_campo><label>DDD/Telefone</label><valor>'            ||vr_telefone ||'</valor></dados_campo>'
            || '<dados_campo><label>Data da Recarga</label><valor>'         ||vr_dtrecarga||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda ||'</valor></dados_campo>';
            
         ELSIF vr_tptranpe = 14 THEN --FGTS
         
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Identificação do Pagamento </label><valor>'   || vr_dsidenti_pagto      ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Código de Barras           </label><valor>'   || vr_dscod_barras        ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Linha Digitável            </label><valor>'   || vr_dslinha_digitavel   ||'</valor></dados_campo>' ;
                            
             --> Nao exibir para convenios 239 e 451
             IF vr_cdtributo NOT IN (0239,0451) THEN
               vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>CNPJ/CEI/CPF               </label><valor>'   || vr_nridentificacao     ||'</valor></dados_campo>';
             END IF;  
                          
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Cod. Convênio              </label><valor>'   || vr_cdtributo           ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Data do Vencimento         </label><valor>'   || vr_dtvencto            ||'</valor></dados_campo>';
                            
             IF vr_cdtributo IN (0178,0240) THEN
               vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Competência                </label><valor>'   || to_char(vr_nrseqgrde, 'fm000') ||'</valor></dados_campo>';
                            
             --> Mostrar para convenios 239 e 451
             ELSIF vr_cdtributo IN (0239,0451) THEN
               vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Identificador              </label><valor>'   || lpad(vr_nridentificador,15, '0')     ||'</valor></dados_campo>';
             --> Mostrar para convenio 181
             ELSIF vr_cdtributo = 181 THEN
               vr_xml_auxi := vr_xml_auxi ||
               							'<dados_campo><label>Competência                </label><valor>'   || to_char(vr_dtapuracao,'MM/RRRR')          ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Identificador              </label><valor>'   || lpad(vr_nridentificador,16, '0')     ||'</valor></dados_campo>';
             ELSE
               vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Competência                </label><valor>'   || to_char(vr_dtapuracao,'MM/RRRR')          ||'</valor></dados_campo>';
             END IF;
             
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Valor Total                </label><valor>'   || to_char(vr_vlrtotal,'fm999g999g990d00')            ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Débito Em                  </label><valor>'   || vr_dtdebito            ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Indicador de Agendamento   </label><valor>'   || vr_dsagenda            ||'</valor></dados_campo>';
                            
    
         ELSIF vr_tptranpe = 15 THEN --DAE
         
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Identificação do Pagamento </label><valor>'   || vr_dsidenti_pagto      ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Código de Barras           </label><valor>'   || vr_dscod_barras        ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Linha Digitável            </label><valor>'   || vr_dslinha_digitavel   ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Cod. Convênio              </label><valor>'   || vr_cdtributo           ||'</valor></dados_campo>';
                      
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Número Documento           </label><valor>'   || LPAD(vr_nrdocdae,17,'0') ||'</valor></dados_campo>';
                                                      
             vr_xml_auxi := vr_xml_auxi ||
                            '<dados_campo><label>Valor Total                </label><valor>'   || vr_vlrtotal            ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Débito Em                  </label><valor>'   || vr_dtdebito            ||'</valor></dados_campo>' ||
                            '<dados_campo><label>Indicador de Agendamento   </label><valor>'   || vr_dsagenda            ||'</valor></dados_campo>';
         
                            
         ELSIF vr_tptranpe IN (16,17) THEN --> Contrato de SMS
            vr_xml_auxi := vr_xml_auxi            
            || '<dados_campo><label>Serviço</label><valor>'  || rw_sms_trans_pend.dspacote ||'</valor></dados_campo>'
            || '<dados_campo><label>Início</label><valor>'   || to_char(rw_sms_trans_pend.dtassinatura,'DD/MM/RRRR')      ||'</valor></dados_campo>';
         
         -- Início SM 454.1
         ELSIF vr_tptranpe = 18 THEN -- Resgate de Cheques em Custódia
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor Total</label><valor>'          ||vr_vltotchq||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Cheques</label><valor>'||vr_qtcheque||'</valor></dados_campo>';
-- Fim SM 454.1
 
         ELSIF vr_tptranpe = 19 THEN -- Bordero Desconto de titulo
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor Total</label><valor>'          ||vr_vltotbdt||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Titulos</label><valor>'||vr_qttitulo||'</valor></dados_campo>';

         -- Início Prj 470
         ELSIF vr_tptranpe = 20 THEN -- Contratos
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor</label><valor>'||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Número do Contrato</label><valor>'||vr_nrcntato||'</valor></dados_campo>'
            || '<dados_campo><label>Tipo de Documento</label><valor>'||vr_dsdescri||'</valor></dados_campo>';
         -- Fim Prj 470	  

         ELSIF vr_tptranpe = 21 THEN -- Emprestimos/Financiamentos
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor do Emprestimo/Financiamento</label><valor>'      ||NVL(TRIM(vr_dsvltran), '0,00')||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Parcelas</label><valor>'||vr_qtdparce_ef||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Parcela</label><valor>'      ||vr_vldparce_ef||'</valor></dados_campo>'
            || '<dados_campo><label>Primeiro Vencimento</label><valor>'   ||vr_dtpriven_ef||'</valor></dados_campo>'
            || '<dados_campo><label>CET</label><valor>'                   ||vr_vlpercet_ef||'</valor></dados_campo>'
            || '<dados_campo><label>Tarifa</label><valor>'                ||vr_vltarifa_ef||'</valor></dados_campo>'
            || '<dados_campo><label>Taxa Mensal</label><valor>'           ||vr_vltaxmen_ef||'</valor></dados_campo>'
            || '<dados_campo><label>IOF</label><valor>'                   ||vr_vlrdoiof_ef||'</valor></dados_campo>';



         END IF;
         
         vr_xml_auxi := vr_xml_auxi || '</dados_detalhe>';
         
				 vr_xml_auxi := vr_xml_auxi || '<aprovadores>';
         vr_nmagenda := '';

         FOR rw_tbaprova_rep IN cr_tbaprova_rep (pr_cdtransa  => vr_cdtranpe) LOOP
           
           vr_ind := vr_tab_crapavt.FIRST;
           WHILE vr_ind IS NOT NULL LOOP
             -- Operação realizada por responsável da assinatura conjunta
             IF vr_tab_crapavt(vr_ind).nrcpfcgc = rw_tbaprova_rep.cpf_responsavel THEN
               vr_nmagenda := vr_tab_crapavt(vr_ind).nmdavali;
               EXIT;
             END IF;
             vr_ind := vr_tab_crapavt.NEXT(vr_ind);
           END LOOP;

           vr_xml_auxi := vr_xml_auxi || '<aprovador><nmaprova>' || TO_CHAR(NVL(vr_nmagenda,TO_CHAR(rw_tbaprova_rep.cpf_responsavel) || '-' || 'APROVADOR NAO CADASTRADO')) || '</nmaprova>'
                                      || '<situacao>' || rw_tbaprova_rep.situacao || '</situacao>'
                                      || '<idsituacao>' || rw_tbaprova_rep.idsituacao || '</idsituacao></aprovador>';

         END LOOP;
         
         vr_xml_auxi := vr_xml_auxi || '</aprovadores><bordero>';	

         IF vr_tptranpe = 12 THEN -- Desconto de Cheques
           FOR rw_tbdscc_cheques IN cr_tbdscc_cheques(vr_cdtranpe) LOOP
             vr_xml_auxi := vr_xml_auxi || '<cheque>' ||
                                               '<dtlibera>' || rw_tbdscc_cheques.dtlibera || '</dtlibera>' ||
                                               '<dtemissa>' || rw_tbdscc_cheques.dtemissa || '</dtemissa>' ||
                                               '<cdbanchq>' || rw_tbdscc_cheques.cdbanchq || '</cdbanchq>' ||
                                               '<cdagechq>' || rw_tbdscc_cheques.cdagechq || '</cdagechq>' ||
                                               '<nrctachq>' || rw_tbdscc_cheques.nrctachq || '</nrctachq>' ||
                                               '<nrcheque>' || rw_tbdscc_cheques.nrcheque || '</nrcheque>' ||
                                               '<vlcheque>' || rw_tbdscc_cheques.vlcheque || '</vlcheque>' ||
                                           '</cheque>';	
         END LOOP;
         --início SM 454.1         
         ELSIF  vr_tptranpe = 18 THEN -- Resgate de Cheques em Custódia
           FOR rw_tbcst_cheques IN cr_tbcst_cheques(vr_cdtranpe) LOOP
             vr_xml_auxi := vr_xml_auxi || '<cheque>' ||
                                               '<dtlibera>' || rw_tbcst_cheques.dtlibera || '</dtlibera>' ||
                                               '<dtemissa>' || rw_tbcst_cheques.dtemissa || '</dtemissa>' ||
                                               '<cdbanchq>' || rw_tbcst_cheques.cdbanchq || '</cdbanchq>' ||
                                               '<cdagechq>' || rw_tbcst_cheques.cdagechq || '</cdagechq>' ||
                                               '<nrctachq>' || rw_tbcst_cheques.nrctachq || '</nrctachq>' ||
                                               '<nrcheque>' || rw_tbcst_cheques.nrcheque || '</nrcheque>' ||
                                               '<vlcheque>' || rw_tbcst_cheques.vlcheque || '</vlcheque>' ||
                                           '</cheque>';	
           END LOOP;                                           
--Fim Sm 454.1  
         END IF;

         vr_xml_auxi := vr_xml_auxi || '</bordero></transacao>';	
				 
         --Dados Detalhados da transacao
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => vr_xml_auxi);
      
        END LOOP;
        --Fim loop de transacoes
              
        --Montar Tag de fechamento das transacoes pendentes
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</transacoes>');
              
        --Montar Tag Xml de Total
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<total>'
                                                  || '  <quantidade>'||vr_qttotpen||'</quantidade>'
                                                  || '  <valortotal>'||TO_CHAR(vr_vltotpen,'fm999g999g990d00')||'</valortotal>'
                                                  || '</total>');
      END IF;      
      
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</raiz>' 
                             ,pr_fecha_xml      => TRUE);
                                                 
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
      
        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE	
          pr_dscritic := vr_dscritic;
        END IF;

        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro geral em Consulta de Transacoes Pendentes INET0002.pc_busca_trans_pend: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_busca_trans_pend;
    
  --> Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  PROCEDURE pc_cria_trans_pend_darf_das(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (1 – DARF / 2 – DAS)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia
                                       ,pr_dsnomfon  IN VARCHAR2 						                  --> Nome e telefone da guia
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_nrrefere  IN VARCHAR2 						                  --> Número de referência da guia
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_vlrprinc  IN NUMBER 							                  --> Valor principal da guia
                                       ,pr_vlrmulta  IN NUMBER 							                  --> Valor da multa da guia
                                       ,pr_vlrjuros  IN NUMBER 							                  --> Valor dos juros da guia
                                       ,pr_vlrecbru  IN NUMBER 							                  --> Valor da receita bruta acumulada da guia
                                       ,pr_vlpercen  IN NUMBER 							                  --> Valor do percentual da guia
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2) IS 			                    --> Descriçao do erro 
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_trans_pend_darf_das
  --  Sistema  : Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------   
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; -- Tabela Avalistas 
    vr_lindigit VARCHAR2(500) := '';
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);

    -- Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 11          -- DARF/DAS
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_lindigit := SUBSTR(TO_CHAR(pr_lindigi1,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi1,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi2,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi2,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi3,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi3,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi4,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi4,'fm000000000000'),12,1);

    BEGIN
      INSERT INTO
        tbpagto_darf_das_trans_pend(
           cdtransacao_pendente
          ,cdcooper
          ,nrdconta
          ,tppagamento
          ,tpcaptura
          ,dsidentif_pagto
          ,dsnome_fone
          ,dscod_barras
          ,dslinha_digitavel
          ,dtapuracao
          ,nrcpfcgc
          ,cdtributo
          ,nrrefere
          ,vlprincipal
          ,vlmulta
          ,vljuros
          ,vlreceita_bruta
          ,vlpercentual
          ,dtvencto
          ,tpleitura_docto
          ,vlpagamento
          ,dtdebito
          ,idagendamento)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_tpdaguia
          ,pr_tpcaptur
          ,pr_dsidepag
          ,pr_dsnomfon
          ,pr_cdbarras
          ,vr_lindigit
          ,pr_dtapurac
          ,pr_nrcpfcgc
          ,pr_cdtribut
          ,pr_nrrefere
          ,pr_vlrprinc
          ,pr_vlrmulta
          ,pr_vlrjuros
          ,pr_vlrecbru
          ,pr_vlpercen
          ,pr_dtvencto
          ,pr_tpleitur
          ,pr_vlrtotal
          ,pr_dtagenda  
          ,pr_idagenda);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_darf_das_trans_pend: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 11         -- DARF/DAS
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_nrdrowid := NULL;
    vr_dstransa := '11 - Transacao de DARF-DAS pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'VLRTOTAL'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vlrtotal);
                             
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'NRCPFREP'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfrep);                             
    COMMIT;

  EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
      
        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE	
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina INET002.pc_cria_trans_pend_darf_das. '||sqlerrm; 
      ROLLBACK;
  END pc_cria_trans_pend_darf_das;  
  --
  PROCEDURE pc_cria_trans_pend_pag_gps(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                        ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                        ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                        ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                        ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                        ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                        ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                        ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                        ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                        ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                        ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                        ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                        ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                        ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                        ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                        ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                        ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                        ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                        ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                        ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                        ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                        ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                        ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                        ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                        ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                        ,pr_nrdrowid  OUT ROWID
                                        ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                        ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS                 --> Descricao de Critica

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_pagto
    --  Sistema  : Procedure de criacao de transacao de pagamentos de GPS
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Junho/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure de criacao de transacao de pagamentos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    BEGIN
    DECLARE
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas    
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);
    
    BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 2 --  Pagamento
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbpagto_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta             
          ,tppagamento          
          ,vlpagamento          
          ,dtdebito             
          ,idagendamento        
          ,dscedente            
          ,dscodigo_barras      
          ,dslinha_digitavel    
          ,vldocumento          
          ,dtvencimento         
          ,tpcaptura            
          ,idtitulo_dda)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idtippag
          ,pr_vllanmto
          ,pr_dtmvtopg
          ,pr_idagenda
          ,pr_dscedent
          ,pr_dscodbar
          ,pr_dslindig
          ,pr_vlrdocto
          ,pr_dtvencto
          ,pr_tpcptdoc
          ,pr_idtitdda);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_trans_pend: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 2 
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;
    --
    vr_nrdrowid := NULL;
    vr_dstransa := 'GPS Transacao de pagamento pendente de aprovacao de assinatura conjunta';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'gpscdtransacao_pendente'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_cdtranpe);    
    pr_nrdrowid := vr_nrdrowid;    
    --COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_pagto. Erro: '|| SQLERRM; 
      ROLLBACK; 
    END;
  END pc_cria_trans_pend_pag_gps;  
  --
  PROCEDURE pc_busca_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                             ,pr_idorigem IN INTEGER                            --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                             ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                             ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                             ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                             ,pr_tab_darf_das OUT INET0002.typ_tab_darf_das) IS --> Tabela com os dados da DARF/DAS

   BEGIN															 
	 /* .............................................................................

     Programa: pc_busca_darf_das
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de DARF/DAS.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		
		DECLARE
	
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_saida EXCEPTION;
            
			-- Declaração da tabela que conterá os dados de DARF/DAS
			vr_tab_darf_das INET0002.typ_tab_darf_das;
			vr_ind_darf_das PLS_INTEGER := 0;

      -- Seleciona registro de DARF/DAS    
	    CURSOR cr_darfdas(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS 
			  SELECT darf.cdtransacao_pendente AS cdtransacao_pendente
              ,darf.cdcooper             AS cdcooper
              ,darf.nrdconta             AS nrdconta
              ,darf.tppagamento          AS tppagamento
              ,darf.tpcaptura            AS tpcaptura
              ,darf.dsidentif_pagto      AS dsidentif_pagto
              ,darf.dsnome_fone          AS dsnome_fone
              ,darf.dscod_barras         AS dscod_barras
              ,darf.dslinha_digitavel    AS dslinha_digitavel
              ,darf.dtapuracao           AS dtapuracao
              ,darf.nrcpfcgc             AS nrcpfcgc
              ,darf.cdtributo            AS cdtributo
              ,darf.nrrefere             AS nrrefere
              ,darf.vlprincipal          AS vlprincipal
              ,darf.vlmulta              AS vlmulta
              ,darf.vljuros              AS vljuros
              ,darf.vlreceita_bruta      AS vlreceita_bruta
              ,darf.vlpercentual         AS vlpercentual
              ,darf.dtvencto             AS dtvencto
              ,darf.tpleitura_docto      AS tpleitura_docto
              ,darf.vlpagamento          AS vlpagamento
              ,darf.dtdebito             AS dtdebito
              ,darf.idagendamento        AS idagendamento
              ,ROWID
				  FROM tbpagto_darf_das_trans_pend darf
         WHERE (darf.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND (darf.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
           AND (pr_cdtrapen IS NULL OR (darf.cdtransacao_pendente IN (SELECT regexp_substr(pr_cdtrapen, '[^;]+', 1, ROWNUM) parametro
               FROM dual CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_cdtrapen ,'[^;]+','')) + 1)));

			rw_darfdas cr_darfdas%ROWTYPE;
			
			-- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
	  BEGIN
			
			-- Para cada registro de DARF/DAS
			FOR rw_darfdas IN cr_darfdas(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP      

	      -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
	      vr_ind_darf_das := vr_tab_darf_das.COUNT() + 1;

			  vr_tab_darf_das(vr_ind_darf_das).cdtransacao_pendente := rw_darfdas.cdtransacao_pendente;
        vr_tab_darf_das(vr_ind_darf_das).cdcooper							:= rw_darfdas.cdcooper;
        vr_tab_darf_das(vr_ind_darf_das).nrdconta             := rw_darfdas.nrdconta;
        vr_tab_darf_das(vr_ind_darf_das).tppagamento          := rw_darfdas.tppagamento;
        vr_tab_darf_das(vr_ind_darf_das).tpcaptura            := rw_darfdas.tpcaptura;
        vr_tab_darf_das(vr_ind_darf_das).dsidentif_pagto      := rw_darfdas.dsidentif_pagto;
        vr_tab_darf_das(vr_ind_darf_das).dsnome_fone          := rw_darfdas.dsnome_fone;
        vr_tab_darf_das(vr_ind_darf_das).dscod_barras         := rw_darfdas.dscod_barras;
        vr_tab_darf_das(vr_ind_darf_das).dslinha_digitavel    := rw_darfdas.dslinha_digitavel;
        vr_tab_darf_das(vr_ind_darf_das).dtapuracao           := rw_darfdas.dtapuracao;
        vr_tab_darf_das(vr_ind_darf_das).nrcpfcgc             := rw_darfdas.nrcpfcgc;
        vr_tab_darf_das(vr_ind_darf_das).cdtributo            := rw_darfdas.cdtributo;
        vr_tab_darf_das(vr_ind_darf_das).nrrefere             := rw_darfdas.nrrefere;
        vr_tab_darf_das(vr_ind_darf_das).vlprincipal          := rw_darfdas.vlprincipal;
        vr_tab_darf_das(vr_ind_darf_das).vlmulta              := rw_darfdas.vlmulta;
        vr_tab_darf_das(vr_ind_darf_das).vljuros              := rw_darfdas.vljuros;
        vr_tab_darf_das(vr_ind_darf_das).vlreceita_bruta      := rw_darfdas.vlreceita_bruta;
        vr_tab_darf_das(vr_ind_darf_das).vlpercentual         := rw_darfdas.vlpercentual;
        vr_tab_darf_das(vr_ind_darf_das).dtvencto             := rw_darfdas.dtvencto;
        vr_tab_darf_das(vr_ind_darf_das).tpleitura_docto      := rw_darfdas.tpleitura_docto;
        vr_tab_darf_das(vr_ind_darf_das).vlpagamento          := rw_darfdas.vlpagamento;
        vr_tab_darf_das(vr_ind_darf_das).dtdebito             := rw_darfdas.dtdebito;
        vr_tab_darf_das(vr_ind_darf_das).idagendamento        := rw_darfdas.idagendamento;
        vr_tab_darf_das(vr_ind_darf_das).idrowid              := rw_darfdas.ROWID;				
			END LOOP; -- FOR rw_darfdas

			-- Alimenta parâmetro com a PL/Table gerada
			pr_tab_darf_das := vr_tab_darf_das;
						
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_cdcritic := NVL(vr_cdcritic,0);
      
        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE	
          pr_dscritic := vr_dscritic;
        END IF;
        
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na INET0002.pc_busca_darf_das: ' || SQLERRM;
		END;
	END pc_busca_darf_das;

  PROCEDURE pc_busca_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                 ,pr_idorigem IN INTEGER               --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
												    		 ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
												 	 	 		 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														 		 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

		BEGIN
	 /* .............................................................................

     Programa: pc_busca_darf_das_car
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de DARF/DAS

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declaração da tabela que conterá os dados de DARF/DAS
			vr_tab_darf_das INET0002.typ_tab_darf_das;
			vr_ind_darf_das PLS_INTEGER := 0;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
		  -- Procedure para buscar informações da aplicação
      INET0002.pc_busca_darf_das(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                ,pr_cdoperad => pr_cdoperad           --> Código do Operador
                                ,pr_nmdatela => pr_nmdatela           --> Nome da Tela
                                ,pr_idorigem => pr_idorigem           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                ,pr_nrdconta => pr_nrdconta           --> Número da Conta
                                ,pr_idseqttl => pr_idseqttl           --> Titular da Conta 		
                                ,pr_cdtrapen => pr_cdtrapen           --> Codigo da Transacao														 
                                ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                ,pr_dscritic => vr_dscritic           --> Descrição da crítica
                                ,pr_tab_darf_das => vr_tab_darf_das); --> Tabela com os dados de DARF/DAS
																					
			-- Se retornou alguma critica
			IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_saida;
			END IF;
			
			-- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
			
			IF vr_tab_darf_das.count() > 0 THEN
				-- Percorre todas as DARF/DAS
				FOR vr_contador IN vr_tab_darf_das.FIRST..vr_tab_darf_das.LAST LOOP
					-- Montar XML com registros de DARF/DAS
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     => '<darf>'
                                                      || '<cdtransacao_pendente>' || NVL(vr_tab_darf_das(vr_contador).cdtransacao_pendente,'0')               || '</cdtransacao_pendente>'
                                                      || '<cdcooper>'             || NVL(vr_tab_darf_das(vr_contador).cdcooper,'0')                           || '</cdcooper>'
                                                      || '<nrdconta>'             || NVL(vr_tab_darf_das(vr_contador).nrdconta,'0')                           || '</nrdconta>'
                                                      || '<tppagamento>'          || NVL(vr_tab_darf_das(vr_contador).tppagamento,'0')                        || '</tppagamento>'
                                                      || '<tpcaptura>'            || NVL(vr_tab_darf_das(vr_contador).tpcaptura,'0')                          || '</tpcaptura>'
                                                      || '<dsidentif_pagto>'      || NVL(vr_tab_darf_das(vr_contador).dsidentif_pagto,' ')                  || '</dsidentif_pagto>'
                                                      || '<dsnome_fone>'          || NVL(vr_tab_darf_das(vr_contador).dsnome_fone,' ')                      || '</dsnome_fone>'
                                                      || '<dscod_barras>'         || NVL(vr_tab_darf_das(vr_contador).dscod_barras,' ')                     || '</dscod_barras>'
                                                      || '<dslinha_digitavel>'    || NVL(vr_tab_darf_das(vr_contador).dslinha_digitavel,' ')                || '</dslinha_digitavel>'
                                                      || '<dtapuracao>'           || NVL(TO_CHAR(vr_tab_darf_das(vr_contador).dtapuracao,'dd/mm/RRRR'),' ') || '</dtapuracao>'
                                                      || '<nrcpfcgc>'             || NVL(vr_tab_darf_das(vr_contador).nrcpfcgc,'0')                           || '</nrcpfcgc>'
                                                      || '<cdtributo>'            || NVL(vr_tab_darf_das(vr_contador).cdtributo,'0')                          || '</cdtributo>'
                                                      || '<nrrefere>'             || NVL(vr_tab_darf_das(vr_contador).nrrefere,'0')                           || '</nrrefere>'
                                                      || '<vlprincipal>'          || NVL(vr_tab_darf_das(vr_contador).vlprincipal,'0,00')                   || '</vlprincipal>'
                                                      || '<vlmulta>'              || NVL(vr_tab_darf_das(vr_contador).vlmulta,'0,00')                       || '</vlmulta>'
                                                      || '<vljuros>'              || NVL(vr_tab_darf_das(vr_contador).vljuros,'0,00')                       || '</vljuros>'
                                                      || '<vlreceita_bruta>'      || NVL(vr_tab_darf_das(vr_contador).vlreceita_bruta,'0,00')               || '</vlreceita_bruta>'
                                                      || '<vlpercentual>'         || NVL(vr_tab_darf_das(vr_contador).vlpercentual,'0,00')                  || '</vlpercentual>'
                                                      || '<dtvencto>'             || NVL(TO_CHAR(vr_tab_darf_das(vr_contador).dtvencto,'dd/mm/RRRR'),' ')   || '</dtvencto>'
                                                      || '<tpleitura_docto>'      || vr_tab_darf_das(vr_contador).tpleitura_docto                           || '</tpleitura_docto>'
                                                      || '<vlpagamento>'          || NVL(vr_tab_darf_das(vr_contador).vlpagamento,'0,00')                   || '</vlpagamento>'
                                                      || '<dtdebito>'             || NVL(TO_CHAR(vr_tab_darf_das(vr_contador).dtdebito,'dd/mm/RRRR'),' ')   || '</dtdebito>'
                                                      || '<idagendamento>'        || NVL(vr_tab_darf_das(vr_contador).idagendamento,'0')                      || '</idagendamento>'
                                                      || '<idrowid>'              || NVL(vr_tab_darf_das(vr_contador).idrowid,'0')                            || '</idrowid>'
																										|| '</darf>');
        END LOOP;

			END IF;

			-- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</raiz>' 
                             ,pr_fecha_xml      => TRUE);
			
		EXCEPTION
			WHEN vr_exc_saida THEN

        pr_cdcritic := NVL(vr_cdcritic,0);
      
        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE	
          pr_dscritic := vr_dscritic;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes INET0002.pc_busca_darf_das_car: ' || SQLERRM;

    END;
  END pc_busca_darf_das_car;

  --> Criar transaçao pendente para a inclusao do contrato de serviço de SMS  
  PROCEDURE pc_cria_trans_pend_sms_cobran( pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                          ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                          ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                          ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                          ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                          ,pr_cdtiptra  IN tbgen_trans_pend.tptransacao%TYPE          --> Tipo de transacao (16 - Adesao, 17 - Cancelamento)
                                          ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                          ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal) 
                                          ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                          ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                          ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                          ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                          ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                          ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                          ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                          ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                          ,pr_idpacote  IN tbcobran_sms_pacotes.idpacote%TYPE         --> Codigo do pacote de SMS
                                          ,pr_vlservico IN crapfco.vltarifa%TYPE                      --> Valor de tarifa do SMS/Pacote de SMS
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  /* .............................................................................

     Programa: pc_cria_trans_pend_sms_cobran 
     Sistema : InternetBank
     Sigla   : INET
     Autor   : Odirlei Busana - AMcom
     Data    : Novembro/2015.                  Ultima atualizacao: 16/11/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina responsavel por Criar transaçao pendente para a inclusao do contrato de serviço de SMS
     Observacao: -----
     Alteracoes: 
     
    ..............................................................................*/ 
    ----------------> CURSORES <-----------------
       
    -- Buscar nome da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
   
    ----------------> VARIAVEIS <-----------------
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE; -- Codigo de erro
    vr_dscritic   VARCHAR2(2000);        -- Retorno de Erro
    
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    
  BEGIN
  
    --> Gerar tbgen_trans_pend 
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => pr_cdtiptra --> SMS Cobrança
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    BEGIN
      
      INSERT INTO
        tbcobran_sms_trans_pend
                ( cdtransacao_pendente, 
                  cdcooper, 
                  nrdconta, 
                  idpacote, 
                  dtassinatura, 
                  vlservico)
        VALUES ( vr_cdtranpe
                ,pr_cdcooper
                ,pr_nrdconta
                ,pr_idpacote
                ,pr_dtmvtolt
                ,pr_vlservico);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbcobran_sms_trans_pend. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
   
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => pr_cdtiptra --> SMS Cobrança
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;
  
  EXCEPTION  
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_sms_cobran. Erro: '|| SQLERRM; 

  END pc_cria_trans_pend_sms_cobran;

  /******************************************************************************/
  /**     Procedure para carregar titulares/operadores para acesso a conta     **/
  /******************************************************************************/
  PROCEDURE pc_carrega_ttl_internet ( pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo de agencia
                                     ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE --> Nome da tela
                                     ,pr_idorigem  IN INTEGER               --> Identificador sistema origem
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do Associado
                                     ,pr_idseqttl  IN crapttl.idseqttl%type --> Titularidade do Associado
                                     ,pr_flgerlog  IN INTEGER               --> Identificador se gera log  
                                     ,pr_flmobile  IN INTEGER               --> identificador se é chamada mobile
                                     ,pr_floperad  IN INTEGER DEFAULT 1     --> identificador se deve carregar operadores                                     
                                     
                                     ,pr_tab_titulates OUT typ_tab_titulates --> Retorna titulares com acesso ao Ibank
                                     ,pr_qtdiaace      OUT INTEGER               --> Retornar dias do primeiro acesso
                                     ,pr_nmprimtl      OUT crapass.nmprimtl%TYPE --> Retornar nome do cooperaro

                                     ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_carrega_ttl_internet         (antiga: b1wnet0002.p/carrega-titulares)
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : outubro/2016.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para carregar titulares/operadores para acesso a conta
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
    --------------->> CURSORES <<----------------
    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.idastcjt
            ,crapass.nmprimtl
            ,crapass.inpessoa
       FROM  crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
      
    --Selecionar informacoes de senhas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%type
                      ,pr_idseqttl IN crapsnh.idseqttl%TYPE
                      ,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE) IS
                      
      SELECT snh.nrcpfcgc,
             snh.cdsitsnh,
             snh.dssenweb,
             snh.dtlibera,
             snh.idseqttl
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = decode(pr_idseqttl, 0, snh.idseqttl,pr_idseqttl)
         AND snh.cdsitsnh = decode(pr_cdsitsnh, 0, snh.cdsitsnh,pr_cdsitsnh) 
         AND snh.tpdsenha = 1; --Internet
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    --Selecionar informacoes de senhas por cpf
    CURSOR cr_crapsnh_2 (pr_cdcooper IN crapsnh.cdcooper%type
                        ,pr_nrdconta IN crapsnh.nrdconta%type
                        ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
      SELECT snh.nrcpfcgc
            ,snh.cdsitsnh
            ,snh.dssenweb
            ,snh.dtlibera
            ,snh.idseqttl
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.nrcpfcgc = pr_nrcpfcgc
         AND snh.tpdsenha = 1 --Internet
         AND snh.cdsitsnh = 1; 
       
    --> Verificar titulares
    CURSOR cr_crapttl (pr_cdcooper crapttl.cdcooper%TYPE,
                       pr_nrdconta crapttl.nrdconta%TYPE ) IS
      SELECT ttl.idseqttl,
             ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --> Buscar operadores juridicos
    CURSOR cr_crapopi (pr_cdcooper crapttl.cdcooper%TYPE,
                       pr_nrdconta crapttl.nrdconta%TYPE ) IS
      SELECT opi.dtlibera,
             opi.nmoperad,
             opi.nrcpfope,
             opi.dsdfrase
        FROM crapopi opi
       WHERE opi.cdcooper = pr_cdcooper
         AND opi.nrdconta = pr_nrdconta
         AND opi.flgsitop = 1
       ORDER BY opi.nmoperad;
    
         
    --> Busca do nome do representante/procurador 
    CURSOR cr_crapavt(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
      SELECT crapavt.nrdctato,
             crapavt.nmdavali,
             crapavt.dtvalida
      FROM   crapavt
      WHERE  crapavt.cdcooper = pr_cdcooper
      AND    crapavt.nrdconta = pr_nrdconta
      AND    crapavt.nrcpfcgc = pr_nrcpfcgc
      AND    crapavt.tpctrato = 6; -- Juridico
    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     INTEGER;
    vr_dscritic     VARCHAR2(2000);
    vr_tab_erro     GENE0001.typ_tab_erro;       --Tabela Erro
    
    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(100);
    
    vr_qtdiaace INTEGER;
    vr_inbloque INTEGER;
    vr_incadsen INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    vr_idxdottl PLS_INTEGER;
    
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens CADA0001.typ_tab_bens;          --Tabela bens
    
    -- Rowid tabela de log
    vr_nrdrowid ROWID;
    
  BEGIN
    --Inicializar varaivel retorno erro
    vr_cdcritic:= NULL;
    vr_dscritic:= NULL;
      
    IF pr_flgerlog = 1 THEN
      -- Buscar a origem
      vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);
      -- Buscar Transacao
      vr_dstransa:= 'Obter titulares/operadores para acesso a conta.';
    END IF;
    
    --> Bloqueio internet durante e apos incorporacoes - desativada em 29/11/2014
    IF pr_cdcooper IN (4,15) THEN
      vr_dscritic := 'Sistema indisponivel. Tente novamente mais tarde!';
      RAISE vr_exc_erro;
    END IF;
    
    -- Busca dados cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta );

    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    --> Verifica se existe pelo menos uma senha cadastrada
    OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_idseqttl => 0
                    ,pr_cdsitsnh => 0);
    FETCH cr_crapsnh INTO rw_crapsnh;
    IF cr_crapsnh%NOTFOUND THEN
      CLOSE cr_crapsnh;
      vr_dscritic := 'A senha para Conta On-Line nao foi cadastrada';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapsnh;  
    END IF;
    
    --> verififcar situacao apenas contas sem assinatura conjunta
    IF rw_crapass.idastcjt = 0 AND rw_crapsnh.cdsitsnh <> 1  THEN
      IF rw_crapsnh.cdsitsnh = 2  THEN
        vr_dscritic := 'A senha para Conta On-Line foi bloqueada';
      ELSIF rw_crapsnh.cdsitsnh = 3  THEN
        vr_dscritic := 'A senha para Conta On-Line foi cancelada';
      ELSE
        vr_dscritic := 'A senha para Conta On-Line nao foi cadastrada';
      END IF; 
      
      RAISE vr_exc_erro;
    END IF;
    
    --> Seta o nome da conta apenas se for assinatura conjunta 
    IF rw_crapass.idastcjt = 1 THEN
      pr_nmprimtl := rw_crapass.nmprimtl;
    END IF;  
    
    --> Pessoa Fisica 
    IF  rw_crapass.inpessoa = 1  THEN  
      --> Verificar titulares
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta );
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;
        vr_dscritic := 'Nao existem titulares cadastrados.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapttl;
      END IF;  
      
      --> Tabela com os limites para internet
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED'      , 
                                                 pr_tptabela => 'GENERI'    , 
                                                 pr_cdempres => 0           , 
                                                 pr_cdacesso => 'LIMINTERNT', 
                                                 pr_tpregist => 1           );
      
      IF trim(vr_dstextab) IS NOT NULL THEN
        vr_qtdiaace := gene0002.fn_busca_entrada(pr_postext => 3, 
                                                 pr_dstext  => vr_dstextab, 
                                                 pr_delimitador => ';');
      ELSE
        vr_qtdiaace := 3;
      END IF;   
      
      --> Buscar titulares da conta
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta ) LOOP
                                    
        vr_incadsen := 0;
        vr_inbloque := 0;
        
        --> Verifica se senha esta ativa
        rw_crapsnh := NULL;
        OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => rw_crapttl.idseqttl
                        ,pr_cdsitsnh => 1); --> Ativo
        FETCH cr_crapsnh INTO rw_crapsnh;
        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          continue;
        ELSE
          CLOSE cr_crapsnh;
        END IF;
        
        --> se estiver sem frase senha cadastrado
        IF TRIM(rw_crapsnh.dssenweb) IS NULL THEN
          vr_incadsen := 1;
                        
          IF (trunc(SYSDATE) - rw_crapsnh.dtlibera) > vr_qtdiaace  THEN 
            vr_inbloque := 1;
        
          ELSE
            vr_inbloque := 0;
          END IF;
        ELSE
          vr_inbloque := 0;
          vr_incadsen := 0;
        END IF;
        
        vr_idxdottl := pr_tab_titulates.count + 1;
        pr_tab_titulates(vr_idxdottl).idseqttl := rw_crapttl.idseqttl;
        pr_tab_titulates(vr_idxdottl).nmtitula := rw_crapttl.nmextttl;
        pr_tab_titulates(vr_idxdottl).nrcpfope := 0;
        pr_tab_titulates(vr_idxdottl).incadsen := vr_incadsen;
        pr_tab_titulates(vr_idxdottl).inbloque := vr_inbloque;
        pr_tab_titulates(vr_idxdottl).inpessoa := rw_crapass.inpessoa;
        
      END LOOP;                  
                         
    --->>> Pessoa Juridica <<<---
    ELSE 
      --> Tabela com os limites para internet
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED'      , 
                                                 pr_tptabela => 'GENERI'    , 
                                                 pr_cdempres => 0           , 
                                                 pr_cdacesso => 'LIMINTERNT', 
                                                 pr_tpregist => 2           );
      
      IF trim(vr_dstextab) IS NOT NULL THEN
        vr_qtdiaace := gene0002.fn_busca_entrada(pr_postext => 3, 
                                                 pr_dstext  => vr_dstextab, 
                                                 pr_delimitador => ';');
      ELSE
        vr_qtdiaace := 3;
      END IF;
      
      --> se nao nescessita assinatura conjunta 
      IF rw_crapass.idastcjt = 0 THEN
        --> se estiver sem frase senha cadastrado
        IF TRIM(rw_crapsnh.dssenweb) IS NULL THEN
          vr_incadsen := 1;
                        
          IF (trunc(SYSDATE) - rw_crapsnh.dtlibera) > vr_qtdiaace  THEN 
            vr_inbloque := 1;
        
          ELSE
            vr_inbloque := 0;
          END IF;
        ELSE
          vr_inbloque := 0;
          vr_incadsen := 0;
        END IF;
        
        vr_idxdottl := pr_tab_titulates.count + 1;
        pr_tab_titulates(vr_idxdottl).idseqttl := 1;
        pr_tab_titulates(vr_idxdottl).nmtitula := rw_crapass.nmprimtl;
        pr_tab_titulates(vr_idxdottl).nrcpfope := 0;
        pr_tab_titulates(vr_idxdottl).incadsen := vr_incadsen;
        pr_tab_titulates(vr_idxdottl).inbloque := vr_inbloque;
        pr_tab_titulates(vr_idxdottl).inpessoa := rw_crapass.inpessoa;
      
      --> Exige assinatura conjunta
      ELSE
        CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => 0
                                  ,pr_nrdcaixa => 0
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 0
                                  ,pr_flgerlog => FALSE
                                  ,pr_cddopcao => 'C'
                                  ,pr_nrdctato => 0
                                  ,pr_nrcpfcto => 0
                                  ,pr_nrdrowid => NULL
                                  ,pr_tab_crapavt => vr_tab_crapavt
                                  ,pr_tab_bens => vr_tab_bens
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF vr_tab_crapavt.COUNT() > 0 THEN
          -- Leitura de registros de avalistas, representantes e procuradores
          FOR i IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
            -- Verifica se ha representante legal
            IF vr_tab_crapavt(i).idrspleg = 1 THEN
              --> Verifica se senha esta ativa
              rw_crapsnh := NULL;
              OPEN cr_crapsnh_2 (pr_cdcooper => vr_tab_crapavt(i).cdcooper
                                ,pr_nrdconta => vr_tab_crapavt(i).nrdconta
                                ,pr_nrcpfcgc => vr_tab_crapavt(i).nrcpfcgc);
              FETCH cr_crapsnh_2 INTO rw_crapsnh;
              IF cr_crapsnh_2%NOTFOUND THEN
                CLOSE cr_crapsnh_2;
                continue;
              ELSE
                CLOSE cr_crapsnh_2;
              END IF;
              
              --> se estiver sem frase senha cadastrado
              IF TRIM(rw_crapsnh.dssenweb) IS NULL THEN
                vr_incadsen := 1;
                              
                IF (trunc(SYSDATE) - rw_crapsnh.dtlibera) > vr_qtdiaace  THEN 
                  vr_inbloque := 1;
              
                ELSE
                  vr_inbloque := 0;
                END IF;
              ELSE
                vr_inbloque := 0;
                vr_incadsen := 0;
              END IF;
              
              vr_idxdottl := pr_tab_titulates.count + 1;
              pr_tab_titulates(vr_idxdottl).idseqttl := rw_crapsnh.idseqttl;
              pr_tab_titulates(vr_idxdottl).nmtitula := vr_tab_crapavt(i).nmdavali;
              pr_tab_titulates(vr_idxdottl).nrcpfope := 0;
              pr_tab_titulates(vr_idxdottl).incadsen := vr_incadsen;
              pr_tab_titulates(vr_idxdottl).inbloque := vr_inbloque;
              pr_tab_titulates(vr_idxdottl).inpessoa := rw_crapass.inpessoa;
            
            END IF;
          END LOOP;
        END IF; -- Fim vr_tab_crapavt.COUNT() >
      END IF; -- Fim IF rw_crapass.idastcjt = 0 THEN
      
      --> Não deve carregar operadores quando for Mobile 
      --> e estiver marcado para carregar
      IF pr_flmobile = 0 AND
         pr_floperad = 1 THEN 
         
        --> Carregar operadores liberados para a conta juridica 
        FOR rw_crapopi IN cr_crapopi(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP
        
          
          --> se estiver sem frase senha cadastrado
          IF TRIM(rw_crapopi.dsdfrase) IS NULL THEN
            vr_incadsen := 1;
                              
            IF (trunc(SYSDATE) - rw_crapopi.dtlibera) > vr_qtdiaace  THEN 
              vr_inbloque := 1;              
            ELSE
              vr_inbloque := 0;
            END IF;
          ELSE
            vr_inbloque := 0;
            vr_incadsen := 0;
          END IF;
              
          vr_idxdottl := pr_tab_titulates.count + 1;
          pr_tab_titulates(vr_idxdottl).idseqttl := 1;
          pr_tab_titulates(vr_idxdottl).nmtitula := rw_crapopi.nmoperad;
          pr_tab_titulates(vr_idxdottl).nrcpfope := rw_crapopi.nrcpfope;
          pr_tab_titulates(vr_idxdottl).incadsen := vr_incadsen;
          pr_tab_titulates(vr_idxdottl).inbloque := vr_inbloque;
          pr_tab_titulates(vr_idxdottl).inpessoa := rw_crapass.inpessoa;
        END LOOP;                        
      END IF;       
    END IF;
    
    --> Senao encontrou nenhuma conta que possui acesso
    IF pr_tab_titulates.count = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'A senha para Conta On-Line nao foi cadastrada';
      RAISE vr_exc_erro;
    END IF;
    
    pr_qtdiaace := vr_qtdiaace;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
        
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;
      
      --> Gerar log 
      IF pr_flgerlog = 1 THEN
        GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdoperad 
                             ,pr_dscritic => pr_dscritic
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => trunc(SYSDATE)
                             ,pr_flgtrans => 0
                             ,pr_hrtransa => gene0002.fn_busca_time
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nmdatela => pr_nmdatela
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel carregar titulares com acesso ao IBank: '||SQLERRM;
    
      --> Gerar log 
      IF pr_flgerlog = 1 THEN
        GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdoperad 
                             ,pr_dscritic => pr_dscritic
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => trunc(SYSDATE)
                             ,pr_flgtrans => 0
                             ,pr_hrtransa => gene0002.fn_busca_time
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nmdatela => pr_nmdatela
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
      END IF;      
  END pc_carrega_ttl_internet;
  
  /******************************************************************************/
  /**  Procedure para carregar titulares/operadores para acesso a conta -WEB   **/
  /******************************************************************************/
  PROCEDURE pc_carrega_ttl_internet_web ( pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta do associado
                                         ,pr_xmllog      IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic   OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic   OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN  OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo   OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro   OUT VARCHAR2) IS           --> Erros do processo

  /* ............................................................................

       Programa: pc_carrega_ttl_internet_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busan - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Procedure para carregar titulares/operadores para acesso a conta - Chamada ayllos Web

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
    
    vr_tab_titulates typ_tab_titulates;
    vr_qtdiaace      INTEGER;
    vr_nmprimtl      crapass.nmprimtl%TYPE;
    
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

    
    --> Carrega titulares
    pc_carrega_ttl_internet ( pr_cdcooper  => vr_cdcooper --> Codigo Cooperativa
                             ,pr_cdagenci  => vr_cdagenci --> Codigo de agencia
                             ,pr_nrdcaixa  => vr_nrdcaixa --> Numero do caixa
                             ,pr_cdoperad  => vr_cdoperad --> Codigo do operador
                             ,pr_nmdatela  => vr_nmdatela --> Nome da tela
                             ,pr_idorigem  => vr_idorigem --> Identificador sistema origem
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
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>');
    
    pc_escreve_xml('<Dados>'||
                       '<qtdiaace>'|| vr_qtdiaace ||'</qtdiaace>'||
                       '<nmprimtl>'|| vr_nmprimtl ||'</nmprimtl>'||
                       '<Titulares>');
                           
    IF vr_tab_titulates.count() > 0 THEN
      FOR idx IN vr_tab_titulates.first..vr_tab_titulates.last LOOP
    
      pc_escreve_xml('<titular>'||
                        '<idseqttl>'|| vr_tab_titulates(idx).idseqttl  ||'</idseqttl>'||
                        '<nmtitula>'|| vr_tab_titulates(idx).nmtitula  ||'</nmtitula>'||
                        '<nrcpfope>'|| vr_tab_titulates(idx).nrcpfope  ||'</nrcpfope>'||
                        '<incadsen>'|| vr_tab_titulates(idx).incadsen  ||'</incadsen>'||
                        '<inbloque>'|| vr_tab_titulates(idx).inbloque  ||'</inbloque>'||
                        '<inpessoa>'|| vr_tab_titulates(idx).inpessoa  ||'</inpessoa>'||
                      '</titular>');  
      END LOOP;                
    END IF;
                      
    pc_escreve_xml('</Titulares></Dados></Root>',TRUE);
                          
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML(vr_des_xml);
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE	
        pr_dscritic := vr_dscritic;
      END IF;

      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_carrega_ttl_internet_web: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_carrega_ttl_internet_web; 

  PROCEDURE pc_cria_trans_pend_recarga(pr_cdagenci  IN crapage.cdagenci%TYPE -- Cód. Agência
																		  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE -- Nr. do caixa
																			,pr_cdoperad  IN crapope.cdoperad%TYPE -- Cód. operador
																			,pr_nmdatela  IN craptel.nmdatela%TYPE -- Nome da tela
																			,pr_idorigem  IN INTEGER               -- Id. origem
																			,pr_idseqttl  IN INTEGER               -- Id. do titular
																			,pr_nrcpfope  IN crapsnh.nrcpfcgc%TYPE -- Cpf do operador da conta
																			,pr_nrcpfrep  IN crapsnh.nrcpfcgc%TYPE -- Cpf do representante legal
																			,pr_cdcoptfn  IN crapcop.cdcooper%TYPE -- Cód. da cooperativa do terminal financeiro (TAA)
																			,pr_cdagetfn  IN crapage.cdagenci%TYPE -- Agência do terminal financeiro (TAA)
																			,pr_nrterfin  IN craptfn.nrterfin%TYPE -- Nr. do terminal financeiro (TAA)
																			,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE -- Data de movimento
																			,pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa
																			,pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta
																			,pr_vlrecarga IN tbrecarga_valor.vlrecarga%TYPE -- Valor de recarga
																			,pr_dtrecarga IN tbrecarga_operacao.dtrecarga%TYPE -- Data de recarga
																			,pr_lsdatagd  IN VARCHAR2                          -- Lista de datas de recarga (Apenas em agendamento recorrente)
																			,pr_tprecarga IN INTEGER                           -- Tipo recarga (1-Online / 2-Agendada)
																			,pr_nrdddtel  IN tbrecarga_favorito.nrddd%TYPE     -- DDD
																			,pr_nrtelefo  IN tbrecarga_favorito.nrcelular%TYPE -- Telefone
																			,pr_cdopetel  IN tbrecarga_operadora.cdoperadora%TYPE -- Operadora
																			,pr_cdprodut  IN tbrecarga_produto.cdproduto%TYPE   -- Produto
																			,pr_idastcjt  IN INTEGER                            -- Id. assinatura conjunta
																			,pr_cdcritic  OUT PLS_INTEGER                       -- Cód. da crítica
																			,pr_dscritic  OUT VARCHAR2) IS                      -- Desc. da crítica
  BEGIN																			
  /* .............................................................................
    Programa: pc_cria_trans_pend_recarga
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Fevereiro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para efetuar transação pendente de recarga de celular

    Alteracoes: -----
    ..............................................................................*/						
	  DECLARE
		  -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
			
			-- Variáveis auxiliares
			vr_lsdatagd gene0002.typ_split;
	    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; -- Tabela Avalistas
      vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
			
			-- Operação agendada duplicada
			CURSOR cr_operacao_duplicada(pr_cdcooper IN tbrecarga_operacao.cdcooper%TYPE
			                            ,pr_nrdconta IN tbrecarga_operacao.nrdconta%TYPE
																	,pr_dtrecarg IN tbrecarga_operacao.dtrecarga%TYPE
																	,pr_nrdddtel IN tbrecarga_operacao.nrddd%TYPE
																	,pr_nrtelefo IN tbrecarga_operacao.nrcelular%TYPE
																	,pr_vlrecarg IN tbrecarga_operacao.vlrecarga%TYPE) IS
				SELECT 1
				  FROM tbrecarga_operacao ope
				 WHERE ope.cdcooper  = pr_cdcooper
				   AND ope.nrdconta  = pr_nrdconta
					 AND ope.dtrecarga = pr_dtrecarg
					 AND ope.nrddd     = pr_nrdddtel
					 AND ope.nrcelular = pr_nrtelefo
					 AND ope.vlrecarga = pr_vlrecarg
					 AND ope.insit_operacao IN (1,3); -- Agendada / Transação Pendente
			rw_operacao_duplicada cr_operacao_duplicada%ROWTYPE;				 						
			
			-- Subrotinas
			PROCEDURE pc_cria_operacao_pendente(pr_cdtranpe IN tbrecarga_trans_pend.cdtransacao_pendente%TYPE
				                                 ,pr_tprecarga IN tbrecarga_trans_pend.tprecarga%TYPE
				                                 ,pr_dtrecarg IN tbrecarga_operacao.dtrecarga%TYPE) IS
				-- Id. operação
				vr_idoperacao tbrecarga_operacao.idoperacao%TYPE;
			BEGIN
				INSERT INTO tbrecarga_operacao(cdcooper
																			,nrdconta
																			,nrddd
																			,nrcelular
																			,cdoperadora
																			,dttransa
																			,dtrecarga
																			,cdcanal
																			,vlrecarga
																			,insit_operacao
																			,cdproduto)
																VALUES(pr_cdcooper
																			,pr_nrdconta
																			,pr_nrdddtel
																			,pr_nrtelefo
																			,pr_cdopetel
																			,SYSDATE
																			,pr_dtrecarg
																			,pr_idorigem
																			,pr_vlrecarga
																			,3        -- Transação Pendente
																			,pr_cdprodut) RETURNING idoperacao INTO vr_idoperacao;
																			
				-- Cria transação pendente
				INSERT INTO tbrecarga_trans_pend(cdtransacao_pendente, tprecarga, idoperacao)
				                          VALUES(pr_cdtranpe, pr_tprecarga, vr_idoperacao);
			EXCEPTION
				WHEN OTHERS THEN
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao inserir operação pendente: ' ||SQLERRM;
					-- Levantar exceção
					RAISE vr_exc_erro;
			END pc_cria_operacao_pendente;
    BEGIN
			-- Se é agendamento recorrente
		  IF TRIM(pr_lsdatagd) IS NOT NULL THEN
				-- Quebrar as datas de agendamento
				vr_lsdatagd := GENE0002.fn_quebra_string(pr_string  => pr_lsdatagd, 
                                                 pr_delimit => ',');
				-- Devemos gerar uma transação pendente para cada data de agendamento
        FOR i IN vr_lsdatagd.FIRST..vr_lsdatagd.LAST LOOP
				  -- Cria transação operador
				  pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
					                          ,pr_nrdcaixa => pr_nrdcaixa
																		,pr_cdoperad => pr_cdoperad
																		,pr_nmdatela => pr_nmdatela
																		,pr_idorigem => pr_idorigem
																		,pr_idseqttl => pr_idseqttl
																		,pr_cdcooper => pr_cdcooper
																		,pr_nrdconta => pr_nrdconta
																		,pr_nrcpfope => pr_nrcpfope
																		,pr_nrcpfrep => pr_nrcpfrep
																		,pr_cdcoptfn => pr_cdcoptfn
																		,pr_cdagetfn => pr_cdagetfn
																		,pr_nrterfin => pr_nrterfin
																		,pr_dtmvtolt => pr_dtmvtolt
																		,pr_cdtiptra => 13
																		,pr_idastcjt => pr_idastcjt
																		,pr_tab_crapavt => vr_tab_crapavt
																		,pr_cdtranpe => vr_cdtranpe
																		,pr_dscritic => vr_dscritic);
                                    
          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Cria operação de recarga para data agendada																		 
					pc_cria_operacao_pendente(pr_cdtranpe => vr_cdtranpe
					                         ,pr_tprecarga => pr_tprecarga
					                         ,pr_dtrecarg => to_date(vr_lsdatagd(i),'DD/MM/RRRR'));
					
				  pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
					                        ,pr_nrdcaixa => pr_nrdconta
																	,pr_cdoperad => pr_cdoperad
																	,pr_nmdatela => pr_nmdatela
																	,pr_idorigem => pr_idorigem
																	,pr_idseqttl => pr_idseqttl
																	,pr_cdcooper => pr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_nrcpfrep => pr_nrcpfrep
																	,pr_dtmvtolt => pr_dtmvtolt
																	,pr_cdtiptra => 13
																	,pr_cdtranpe => vr_cdtranpe
																	,pr_tab_crapavt => vr_tab_crapavt
																	,pr_cdcritic => vr_cdcritic
																	,pr_dscritic => vr_dscritic);
                                    
          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
				END LOOP;
			ELSE
				 -- Verificar agendamento duplicado
         OPEN cr_operacao_duplicada(pr_cdcooper => pr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
																	 ,pr_dtrecarg => pr_dtrecarga
																	 ,pr_nrdddtel => pr_nrdddtel
																	 ,pr_nrtelefo => pr_nrtelefo
																	 ,pr_vlrecarg => pr_vlrecarga);
				 FETCH cr_operacao_duplicada INTO rw_operacao_duplicada;
				 
				 -- Se encontrou agendamento já existe
				 IF cr_operacao_duplicada%FOUND THEN
					 -- Fechar cursor
					 CLOSE cr_operacao_duplicada;
					 -- Gerar crítica
           vr_cdcritic := 0;
					 vr_dscritic := '<![CDATA[Você já possui uma transação pendente de aprovação com os mesmos dados informados. </br>'
											 || '<center>Consulte suas transações pendentes.</center>]]>';
					-- Levantar exceção
					RAISE vr_exc_erro;					 
				 END IF;
				 -- Fechar cursor
				 CLOSE cr_operacao_duplicada;
			
				 -- Cria transação operador
				 pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
																	 ,pr_nrdcaixa => pr_nrdcaixa
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_idorigem => pr_idorigem
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_cdcooper => pr_cdcooper
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrcpfope => pr_nrcpfope
																	 ,pr_nrcpfrep => pr_nrcpfrep
																	 ,pr_cdcoptfn => pr_cdcoptfn
																	 ,pr_cdagetfn => pr_cdagetfn
																	 ,pr_nrterfin => pr_nrterfin
																	 ,pr_dtmvtolt => pr_dtmvtolt
																	 ,pr_cdtiptra => 13
																	 ,pr_idastcjt => pr_idastcjt
																	 ,pr_tab_crapavt => vr_tab_crapavt
																	 ,pr_cdtranpe => vr_cdtranpe
																	 ,pr_dscritic => vr_dscritic);
                                    
          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
         -- Cria operação de recarga para data agendada																		 
				 pc_cria_operacao_pendente(pr_cdtranpe => vr_cdtranpe
					                        ,pr_tprecarga => pr_tprecarga				 
				                          ,pr_dtrecarg => pr_dtrecarga);

         pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
					                       ,pr_nrdcaixa => pr_nrdconta
																 ,pr_cdoperad => pr_cdoperad
																 ,pr_nmdatela => pr_nmdatela
																 ,pr_idorigem => pr_idorigem
																 ,pr_idseqttl => pr_idseqttl
																 ,pr_cdcooper => pr_cdcooper
																 ,pr_nrdconta => pr_nrdconta
																 ,pr_nrcpfrep => pr_nrcpfrep
																 ,pr_dtmvtolt => pr_dtmvtolt
																 ,pr_cdtiptra => 13
																 ,pr_cdtranpe => vr_cdtranpe
																 ,pr_tab_crapavt => vr_tab_crapavt
																 ,pr_cdcritic => vr_cdcritic
																 ,pr_dscritic => vr_dscritic);
                                    
          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
			    END IF;
          
			END IF;
			
		EXCEPTION
			WHEN vr_exc_erro THEN
	      pr_cdcritic := NVL(vr_cdcritic,0);
			
				IF NVL(pr_cdcritic,0) <> 0 THEN
					 pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
				ELSE	
					 pr_dscritic := vr_dscritic;
				END IF;
	        
				ROLLBACK;

			WHEN OTHERS THEN
				pr_cdcritic := 0;
				pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_recarga. Erro: '|| SQLERRM; 
				ROLLBACK; 		
		END;		
	END pc_cria_trans_pend_recarga;

  PROCEDURE pc_busca_limite_preposto(pr_cdcooper IN VARCHAR2 
                                    ,pr_nrdconta IN VARCHAR2 
                                    ,pr_nrcpf    IN VARCHAR2 
                                    ,pr_xmllog   IN  VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER                       
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_limite_preposto
    --  Sistema  : Ayllos - Procedure buscar limites cadastrado de preposto
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar os limites pre cadastrados de prepostos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------                                    

    CURSOR cr_tbcc_limite_preposto (prc_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                   ,prc_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE 
                                   ,prc_nrcpf    IN TBCC_LIMITE_PREPOSTO.nrcpf%TYPE) IS
      SELECT vllimite_transf,
             dtlimite_transf,
             vllimite_pagto,
             dtlimite_pagto,
             vllimite_ted,
             dtlimite_ted,
             vllimite_vrboleto,
             dtlimite_vrboleto,
             vllimite_folha,
             dtlimite_folha
        FROM tbcc_limite_preposto 
       WHERE tbcc_limite_preposto.cdcooper = prc_cdcooper
         AND tbcc_limite_preposto.nrdconta = prc_nrdconta
         AND tbcc_limite_preposto.nrcpf    = prc_nrcpf;
    rw_tbcc_limite_preposto cr_tbcc_limite_preposto%ROWTYPE;
    --                
    vr_cdcooper           TBCC_LIMITE_PREPOSTO.cdcooper%TYPE; 
    vr_nrdconta           TBCC_LIMITE_PREPOSTO.nrdconta%TYPE; 
    vr_nrcpf              TBCC_LIMITE_PREPOSTO.nrcpf%TYPE;
    vr_vllimite_transf    TBCC_LIMITE_PREPOSTO.vllimite_transf%TYPE; 
    vr_dtlimite_transf    TBCC_LIMITE_PREPOSTO.dtlimite_transf%TYPE;  
    vr_vllimite_pagto     TBCC_LIMITE_PREPOSTO.vllimite_pagto%TYPE;
    vr_dtlimite_pagto     TBCC_LIMITE_PREPOSTO.dtlimite_pagto%TYPE;
    vr_vllimite_ted       TBCC_LIMITE_PREPOSTO.vllimite_ted%TYPE;
    vr_dtlimite_ted       TBCC_LIMITE_PREPOSTO.dtlimite_ted%TYPE; 
    vr_vllimite_vrboleto  TBCC_LIMITE_PREPOSTO.vllimite_vrboleto%TYPE; 
    vr_dtlimite_vrboleto  TBCC_LIMITE_PREPOSTO.dtlimite_vrboleto%TYPE; 
    vr_vllimite_folha     TBCC_LIMITE_PREPOSTO.vllimite_folha%TYPE; 
    vr_dtlimite_folha     TBCC_LIMITE_PREPOSTO.dtlimite_folha%TYPE;
    
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767);    
  BEGIN
    --
    vr_cdcooper := gene0002.fn_char_para_number(pr_dsnumtex => pr_cdcooper);
    vr_nrdconta := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrdconta); 
    vr_nrcpf    := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrcpf);
    --
    BEGIN
      OPEN cr_tbcc_limite_preposto (prc_cdcooper => vr_cdcooper
                                   ,prc_nrdconta => vr_nrdconta
                                   ,prc_nrcpf    => vr_nrcpf);
      FETCH cr_tbcc_limite_preposto INTO rw_tbcc_limite_preposto;
      -- Se nao existir preposto, inserir
      IF cr_tbcc_limite_preposto%FOUND THEN
        vr_vllimite_transf   := rw_tbcc_limite_preposto.vllimite_transf;
        vr_dtlimite_transf   := rw_tbcc_limite_preposto.dtlimite_transf;
        vr_vllimite_pagto    := rw_tbcc_limite_preposto.vllimite_pagto;
        vr_dtlimite_pagto    := rw_tbcc_limite_preposto.dtlimite_pagto;
        vr_vllimite_ted      := rw_tbcc_limite_preposto.vllimite_ted;
        vr_dtlimite_ted      := rw_tbcc_limite_preposto.dtlimite_ted;
        vr_vllimite_vrboleto := rw_tbcc_limite_preposto.vllimite_vrboleto;
        vr_dtlimite_vrboleto := rw_tbcc_limite_preposto.dtlimite_vrboleto;
        vr_vllimite_folha    := rw_tbcc_limite_preposto.vllimite_folha;
        vr_dtlimite_folha    := rw_tbcc_limite_preposto.dtlimite_folha;
      ELSE
        vr_vllimite_transf := 0;
        vr_dtlimite_transf := null;
        vr_vllimite_pagto  := 0;
        vr_dtlimite_pagto  := null;
        vr_vllimite_ted    := 0;
        vr_dtlimite_ted    := null;
        vr_vllimite_vrboleto := 0;
        vr_dtlimite_vrboleto := null;
        vr_vllimite_folha  := 0;
        vr_dtlimite_folha  := null;      
      END IF; 
      CLOSE cr_tbcc_limite_preposto;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_busca_limite_preposto. cursor crw_tbcc_limite_preposto Erro: '|| SQLERRM;
    END;    
    --
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'preposto', pr_tag_cont => null, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'preposto', pr_posicao => 0, pr_tag_nova => 'pr_vllimite_transf', pr_tag_cont => vr_vllimite_transf, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'preposto', pr_posicao => 0, pr_tag_nova => 'pr_vllimite_pagto', pr_tag_cont => vr_vllimite_pagto, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'preposto', pr_posicao => 0, pr_tag_nova => 'pr_vllimite_ted', pr_tag_cont => vr_vllimite_ted, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'preposto', pr_posicao => 0, pr_tag_nova => 'pr_vllimite_vrboleto', pr_tag_cont => vr_vllimite_vrboleto, pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'preposto', pr_posicao => 0, pr_tag_nova => 'pr_vllimite_folha', pr_tag_cont => vr_vllimite_folha, pr_des_erro => pr_dscritic);    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em pc_busca_limite_preposto: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    --
  END pc_busca_limite_preposto;                                       

  PROCEDURE pc_valida_limite_preposto(pr_cdcooper           IN VARCHAR2
                                     ,pr_nrdconta           IN VARCHAR2 
                                     ,pr_idseqttl           IN VARCHAR2
                                     ,pr_vllimtrf           IN VARCHAR2 
                                     ,pr_vllimpgo           IN VARCHAR2
                                     ,pr_vllimted           IN VARCHAR2 
                                     ,pr_vllimvrb           IN VARCHAR2 
                                     ,pr_vllimflp           IN VARCHAR2 
                                     ,pr_xmllog             IN VARCHAR2
                                     ,pr_cdcritic       OUT PLS_INTEGER                       
                                     ,pr_dscritic       OUT VARCHAR2
                                     ,pr_retxml        IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) is
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_valida_limite_preposto
    --  Sistema  : Ayllos - Procedure para validar limite de preposto
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Validar os limites pre cadastrados de prepostos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------  
    
    CURSOR cr_crapsnh (prc_cdcooper IN crapsnh.cdcooper%TYPE
                      ,prc_nrdconta IN crapsnh.nrdconta%TYPE
                      ,prc_idseqttl IN crapsnh.idseqttl%TYPE) IS
      SELECT crapsnh.vllimted,
             crapsnh.vllimtrf,
             crapsnh.vllimpgo,
             crapsnh.vllimvrb
        FROM crapsnh 
       WHERE crapsnh.cdcooper = prc_cdcooper
         AND crapsnh.nrdconta = prc_nrdconta
         AND crapsnh.idseqttl = prc_idseqttl
         AND crapsnh.tpdsenha = 1;  
    rw_crapsnh cr_crapsnh%ROWTYPE;
    --
    CURSOR cr_crapemp (prc_cdcooper IN crapemp.cdcooper%TYPE
                      ,prc_nrdconta IN crapemp.nrdconta%TYPE) IS 
      SELECT vllimfol 
        FROM crapemp 
       WHERE crapemp.cdcooper = prc_cdcooper 
         AND crapemp.nrdconta = prc_nrdconta; 
    rw_crapemp cr_crapemp%ROWTYPE;
         
   --
    vr_cdcooper          TBCC_LIMITE_PREPOSTO.cdcooper%TYPE; 
    vr_nrdconta          TBCC_LIMITE_PREPOSTO.nrdconta%TYPE; 
    vr_idseqttl          crapsnh.idseqttl%TYPE;
    vr_vllimtrf          TBCC_LIMITE_PREPOSTO.vllimite_transf%TYPE; 
    vr_vllimpgo          TBCC_LIMITE_PREPOSTO.vllimite_pagto%TYPE;
    vr_vllimted          TBCC_LIMITE_PREPOSTO.vllimite_ted%TYPE; 
    vr_vllimvrb          TBCC_LIMITE_PREPOSTO.vllimite_vrboleto%TYPE; 
    vr_vllimflp          TBCC_LIMITE_PREPOSTO.vllimite_folha%TYPE;   
    vrb_vllimted         crapsnh.vllimted%TYPE;
    vrb_vllimtrf         crapsnh.vllimtrf%TYPE;
    vrb_vllimpgo         crapsnh.vllimpgo%TYPE;
    vrb_vllimvrb         crapsnh.vllimvrb%TYPE;
    vrb_vllimfol         crapemp.vllimfol%TYPE;
    vr_alerta            varchar2(2000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;    
  BEGIN
    --
    --vr_alerta := 'OKww'||'/'||pr_cdcooper||'/'||pr_nrdconta||'/'||pr_idseqttl||'/'||pr_vllimtrf||'/'||
    --   pr_vllimpgo||'/'||pr_vllimted||'/'||pr_vllimvrb||'/'||pr_vllimflp ;
    --
    vr_alerta := 'OK';
    --
    vr_cdcooper          := gene0002.fn_char_para_number(pr_dsnumtex => pr_cdcooper);
    vr_nrdconta          := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrdconta); 
    vr_idseqttl          := gene0002.fn_char_para_number(pr_dsnumtex => pr_idseqttl); 
    vr_vllimtrf          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimtrf);
    vr_vllimpgo          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimpgo);
    vr_vllimted          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimted);
    vr_vllimvrb          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimvrb); 
    vr_vllimflp          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimflp);
    --
    BEGIN
      OPEN cr_crapsnh (prc_cdcooper => vr_cdcooper
                      ,prc_nrdconta => vr_nrdconta
                      ,prc_idseqttl => vr_idseqttl);
      FETCH cr_crapsnh INTO rw_crapsnh;
      --
      IF cr_crapsnh%FOUND THEN
      
        vrb_vllimted := rw_crapsnh.vllimted;
        vrb_vllimtrf := rw_crapsnh.vllimtrf;
        vrb_vllimpgo := rw_crapsnh.vllimpgo;
        vrb_vllimvrb := rw_crapsnh.vllimvrb;
      
      ELSE
        vrb_vllimted := 0;
        vrb_vllimtrf := 0;
        vrb_vllimpgo := 0;
        vrb_vllimvrb := 0;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapsnh;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        vr_alerta := 'Erro pc_valida_limite_preposto - cursor cr_crapsnh - Erro: '|| SQLERRM;
        RAISE vr_exc_erro;
    END;     
    --
    
    BEGIN
    OPEN cr_crapemp (prc_cdcooper => vr_cdcooper
                    ,prc_nrdconta => vr_nrdconta);
    FETCH cr_crapemp INTO rw_crapemp;
      IF cr_crapemp%FOUND THEN
        vrb_vllimfol := rw_crapemp.vllimfol;
      ELSE 
        vrb_vllimfol := 0;
      END IF;
      -- Fechar Cursor 
      CLOSE cr_crapemp;
    EXCEPTION
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         vr_alerta := 'Erro pc_valida_limite_preposto. cursor cr_crapemp - Erro: '|| SQLERRM;
         RAISE vr_exc_erro;
    END;
    --
    IF vr_vllimtrf > vrb_vllimtrf THEN
       pr_cdcritic := 0;
       vr_alerta :=  'Valor do limite de tranfer&ecirc;ncia superior ao liberado no cadastro da conta';
    ELSIF vr_vllimpgo > vrb_vllimpgo THEN
       pr_cdcritic := 0;
       vr_alerta := 'Valor do limite de pagamento superior ao liberado no cadastro da conta'||vr_vllimpgo||'-'||vrb_vllimpgo;      
    ELSIF vr_vllimted > vrb_vllimted THEN
       pr_cdcritic := 0;
       vr_alerta := 'Valor do limite de TED superior ao liberado no cadastro da conta';      
    ELSIF vr_vllimvrb > vrb_vllimvrb THEN
       pr_cdcritic := 0;
       vr_alerta := 'Valor do limite de Boleto superior ao liberado no cadastro da conta';      
    ELSIF vr_vllimflp > vrb_vllimfol THEN
       pr_cdcritic := 0;
       vr_alerta := 'Valor do limite de Folha de pagamento superior ao liberado no cadastro da Empresa';    
    END IF;
    --
    --vr_alerta := pr_dscritic;
    --
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pr_alerta', pr_tag_cont => vr_alerta, pr_des_erro => pr_dscritic);
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_alerta;    
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_valida_limite_preposto. - Erro: '|| SQLERRM;      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
  END pc_valida_limite_preposto;
  
  PROCEDURE pc_altera_limite_preposto(pr_cdcooper           IN VARCHAR2
                                     ,pr_nrdconta           IN VARCHAR2 
                                     ,pr_nrcpf              IN VARCHAR2 
                                     ,pr_idseqttl           IN VARCHAR2
                                     ,pr_cdoperad           IN VARCHAR2 
                                     ,pr_vllimtrf           IN VARCHAR2 
                                     ,pr_vllimpgo           IN VARCHAR2
                                     ,pr_vllimted           IN VARCHAR2 
                                     ,pr_vllimvrb           IN VARCHAR2 
                                     ,pr_vllimflp           IN VARCHAR2
                                     ,pr_xmllog             IN VARCHAR2
                                     ,pr_cdcritic       OUT PLS_INTEGER                       
                                     ,pr_dscritic       OUT VARCHAR2
                                     ,pr_retxml        IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) is
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_altera_limite_preposto
    --  Sistema  : Procedure para alterar limite de preposto
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Alterar os limites dos prepostos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------                                       
     --
     CURSOR cr_tbcc_limite_preposto (prc_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                    ,prc_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE 
                                    ,prc_nrcpf    IN TBCC_LIMITE_PREPOSTO.nrcpf%TYPE) IS
       SELECT vllimite_transf,
              vllimite_pagto,
              vllimite_ted,
              vllimite_vrboleto,
              vllimite_folha,
              dtlimite_transf,
              dtlimite_pagto,
              dtlimite_ted,
              dtlimite_vrboleto,
              dtlimite_folha
         FROM tbcc_limite_preposto 
        WHERE tbcc_limite_preposto.cdcooper = prc_cdcooper
          AND tbcc_limite_preposto.nrdconta = prc_nrdconta
          AND tbcc_limite_preposto.nrcpf    = prc_nrcpf;    

     rw_tbcc_limite_preposto cr_tbcc_limite_preposto%ROWTYPE;     
     --
     vr_cdcooper          TBCC_LIMITE_PREPOSTO.cdcooper%TYPE; 
     vr_nrdconta          TBCC_LIMITE_PREPOSTO.nrdconta%TYPE; 
     vr_nrcpf             TBCC_LIMITE_PREPOSTO.nrcpf%TYPE;
     vr_idseqttl          crapsnh.idseqttl%TYPE;
     vr_vllimtrf          TBCC_LIMITE_PREPOSTO.Vllimite_Transf%TYPE;
     vr_vllimpgo          TBCC_LIMITE_PREPOSTO.Vllimite_Pagto%TYPE;
     vr_vllimted          TBCC_LIMITE_PREPOSTO.Vllimite_Ted%TYPE;
     vr_vllimvrb          TBCC_LIMITE_PREPOSTO.Vllimite_Vrboleto%TYPE;
     vr_vllimflp          TBCC_LIMITE_PREPOSTO.Vllimite_Folha%TYPE;

     vrb_Dtlimite_Transf   TBCC_LIMITE_PREPOSTO.Dtlimite_Transf%TYPE;
     vrb_Dtlimite_Pagto    TBCC_LIMITE_PREPOSTO.Dtlimite_Pagto%TYPE;
     vrb_Dtlimite_Ted      TBCC_LIMITE_PREPOSTO.Dtlimite_Ted%TYPE;
     vrb_Dtlimite_Vrboleto TBCC_LIMITE_PREPOSTO.Dtlimite_Vrboleto%TYPE;
     vrb_Dtlimite_Folha    TBCC_LIMITE_PREPOSTO.Dtlimite_Folha%TYPE;
          
     vr_reg               number(1) := 1;
     vr_opi_vllbolet      crapopi.vllbolet%TYPE;
     vr_opi_vllimtrf      crapopi.vllimtrf%TYPE;
     vr_opi_vllimted      crapopi.vllimted%TYPE;
     vr_opi_vllimvrb      crapopi.vllimvrb%TYPE;
     vr_opi_vllimflp      crapopi.vllimflp%TYPE;
     vr_alerta            varchar2(2000);
     vr_nrdrowid          ROWID;
     vr_operador          varchar2(1) := 'N';
     --Variaveis de Excecao
     vr_exc_erro          EXCEPTION;
     
     CURSOR C_OPERADOR IS
        SELECT opi.cdcooper,
               opi.nrdconta,
               opi.nrcpfope,
               opi.vllbolet,
               opi.vllimtrf,
               opi.vllimted,
               opi.vllimvrb,
               opi.vllimflp
          FROM crapopi opi
         WHERE opi.cdcooper = vr_cdcooper
           AND opi.nrdconta = vr_nrdconta
           AND (opi.vllbolet > vr_vllimpgo OR
                opi.vllimtrf > vr_vllimtrf OR
                opi.vllimted > vr_vllimted OR
                opi.vllimvrb > vr_vllimvrb OR 
                opi.vllimflp > vr_vllimflp);     

  BEGIN
    --
    --vr_alerta := 'OKww'||'/'||pr_cdcooper||'/'||pr_nrdconta||'/'||pr_nrcpf||'/'||pr_idseqttl||'/'||pr_cdoperad||'/'||pr_vllimtrf||'/'||
    --   pr_vllimpgo||'/'||pr_vllimted||'/'||pr_vllimvrb||'/'||pr_vllimflp ;
    --
    vr_alerta := 'OK';
    --
    vr_cdcooper          := gene0002.fn_char_para_number(pr_dsnumtex => pr_cdcooper);
    vr_nrdconta          := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrdconta); 
    vr_nrcpf             := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrcpf); 
    vr_idseqttl          := gene0002.fn_char_para_number(pr_dsnumtex => pr_idseqttl); 
    vr_vllimtrf          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimtrf);
    vr_vllimpgo          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimpgo);
    vr_vllimted          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimted);
    vr_vllimvrb          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimvrb); 
    vr_vllimflp          := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimflp);    
    --
    OPEN cr_tbcc_limite_preposto (prc_cdcooper => pr_cdcooper
                                 ,prc_nrdconta => pr_nrdconta
                                 ,prc_nrcpf    => pr_nrcpf);
    FETCH cr_tbcc_limite_preposto INTO rw_tbcc_limite_preposto;
    -- Se nao existir preposto, inserir
    IF cr_tbcc_limite_preposto%NOTFOUND THEN
      --
      BEGIN
        INSERT into TBCC_LIMITE_PREPOSTO
        (cdcooper,
         nrdconta,
         nrcpf,
         cdoperad,
         vllimite_transf,
         dtlimite_transf,
         vllimite_pagto,
         dtlimite_pagto,
         vllimite_ted,
         dtlimite_ted,
         vllimite_vrboleto,
         dtlimite_vrboleto,
         vllimite_folha,
         dtlimite_folha
        )
        values
        (vr_cdcooper,
         vr_nrdconta,
         vr_nrcpf,
         pr_cdoperad,
         vr_vllimtrf,
         sysdate,
         vr_vllimpgo,
         sysdate,
         vr_vllimted,
         sysdate,
         vr_vllimvrb,
         sysdate,
         vr_vllimflp,
         sysdate);
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          vr_alerta := 'Erro pc_altera_limite_preposto - insert TBCC_LIMITE_PREPOSTO - Erro: '|| SQLERRM;
          raise vr_exc_erro;
      END;
      --
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(1) --> Origem enviada
                          ,pr_dstransa => 'Inserir Limite de Preposto.'
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => vr_idseqttl
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid); 
                          
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Transferencia'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vllimtrf);
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Boleto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vllimpgo); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de TED'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vllimted); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de VR Boleto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vllimvrb); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Folha PGTO'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vllimflp);                             
                                                                                                                                    
      --
      CLOSE cr_tbcc_limite_preposto;
    ELSE
      --
      IF vr_vllimtrf   <> rw_tbcc_limite_preposto.vllimite_transf THEN
         vrb_Dtlimite_Transf   := sysdate;
      END IF;
      --
      IF vr_vllimpgo <> rw_tbcc_limite_preposto.vllimite_pagto THEN
         vrb_dtlimite_pagto    := sysdate;
      END IF;
      --
      IF vr_vllimted   <> rw_tbcc_limite_preposto.vllimite_ted THEN
         vrb_dtlimite_ted      := sysdate;
      END IF;
      --
      IF vr_vllimvrb <> rw_tbcc_limite_preposto.vllimite_vrboleto THEN
         vrb_dtlimite_vrboleto := sysdate;
      END IF;
      --
      IF vr_vllimflp <> rw_tbcc_limite_preposto.vllimite_folha THEN
         vrb_dtlimite_folha    := sysdate;
      END IF;
      --
      BEGIN
        UPDATE TBCC_LIMITE_PREPOSTO
           SET cdoperad = pr_cdoperad,
               vllimite_transf   = vr_vllimtrf,
               dtlimite_transf   = nvl(vrb_dtlimite_transf,dtlimite_transf),
               vllimite_pagto    = vr_vllimpgo,
               dtlimite_pagto    = nvl(vrb_dtlimite_pagto,dtlimite_pagto),
               vllimite_ted      = vr_vllimted,
               dtlimite_ted      = nvl(vrb_dtlimite_ted,dtlimite_ted),
               vllimite_vrboleto = vr_vllimvrb,
               dtlimite_vrboleto = nvl(vrb_dtlimite_vrboleto,dtlimite_vrboleto),
               vllimite_folha    = vr_vllimflp,
               dtlimite_folha    = nvl(vrb_dtlimite_folha,dtlimite_folha)
         WHERE TBCC_LIMITE_PREPOSTO.cdcooper = vr_cdcooper
           AND TBCC_LIMITE_PREPOSTO.nrdconta = vr_nrdconta
           AND TBCC_LIMITE_PREPOSTO.nrcpf    = vr_nrcpf;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          vr_alerta := 'Erro pc_altera_limite_preposto update TBCC_LIMITE_PREPOSTO: ' || sqlerrm;          
          raise vr_exc_erro;
      END;
      --
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(1) --> Origem enviada
                          ,pr_dstransa => 'Altera Limite de Preposto.'
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => vr_idseqttl
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Transferencia'
                             ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_transf
                             ,pr_dsdadatu => vr_vllimtrf);
                               
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Boleto'
                             ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_pagto
                             ,pr_dsdadatu => vr_vllimpgo); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de TED'
                             ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_ted
                             ,pr_dsdadatu => vr_vllimted); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de VR Boleto'
                             ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_vrboleto
                             ,pr_dsdadatu => vr_vllimvrb); 
                             
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor de Folha PGTO'
                             ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_folha
                             ,pr_dsdadatu => vr_vllimflp);
             
      --
      FOR R_OPERADOR IN C_OPERADOR LOOP
        --
        IF r_operador.vllbolet > vr_vllimpgo THEN
           vr_opi_vllbolet := vr_vllimpgo;
        ELSE
           vr_opi_vllbolet := r_operador.vllbolet;
        END IF;
        --
        IF r_operador.vllimtrf > vr_vllimtrf THEN
           vr_opi_vllimtrf := vr_vllimtrf;
        ELSE
           vr_opi_vllimtrf := r_operador.vllimtrf;
        END IF;       
        --
        IF r_operador.vllimted > vr_vllimted THEN
           vr_opi_vllimted := vr_vllimted;
        ELSE
           vr_opi_vllimted := r_operador.vllimted;
        END IF;       
        --  
        IF r_operador.vllimvrb > vr_vllimvrb THEN
           vr_opi_vllimvrb := vr_vllimvrb;
        ELSE
           vr_opi_vllimvrb := r_operador.vllimvrb;
        END IF;  
        --  
        IF r_operador.vllimflp > vr_vllimflp THEN
           vr_opi_vllimflp := vr_vllimflp;
        ELSE
           vr_opi_vllimflp := r_operador.vllimflp;
        END IF;             
        --                
        BEGIN
          UPDATE crapopi opi
             SET opi.vllbolet = vr_opi_vllbolet,
                 opi.vllimtrf = vr_opi_vllimtrf,
                 opi.vllimted = vr_opi_vllimted,
                 opi.vllimvrb = vr_opi_vllimvrb,
                 opi.vllimflp = vr_opi_vllimflp
           WHERE opi.cdcooper = R_OPERADOR.CDCOOPER
             AND opi.nrdconta = R_OPERADOR.NRDCONTA
             AND opi.nrcpfope = R_OPERADOR.NRCPFOPE;
        EXCEPTION  
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            vr_alerta := 'Erro pc_altera_limite_preposto - update crapopi: ' || SQLERRM;          
            raise vr_exc_erro;
        END; 
        --
        vr_operador := 'S';
        --
      END LOOP;
      --
      CLOSE cr_tbcc_limite_preposto;
    END IF;
    --
    --
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pr_alerta', pr_tag_cont => vr_alerta, pr_des_erro => pr_dscritic);    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pr_operador', pr_tag_cont => vr_operador, pr_des_erro => pr_dscritic);    
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
         pr_cdcritic := 0;
         --vr_alerta := 'Erro geral na procedure pc_altera_limite_preposto. - Erro: ';      
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pr_alerta', pr_tag_cont => vr_alerta, pr_des_erro => pr_dscritic);    
 
    WHEN OTHERS THEN 
         pr_cdcritic := 0;
         vr_alerta := 'Erro geral na procedure pc_altera_limite_preposto. - Erro: '|| SQLERRM;      
         -- Carregar XML padrão para variável de retorno não utilizada.
         -- Existe para satisfazer exigência da interface.
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  commit;                                                             
  END pc_altera_limite_preposto;
  
  PROCEDURE pc_busca_preposto_master(pr_cdcooper IN VARCHAR2 
                                    ,pr_nrdconta IN VARCHAR2 
                                    ,pr_xmllog   IN  VARCHAR2
                                    ,pr_cdcritic OUT PLS_INTEGER                       
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_preposto_master
    --  Sistema  : Procedure buscar preposto master
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar o preposto master
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------                                                                           
    BEGIN
    DECLARE
       vr_cdcooper           TBCC_LIMITE_PREPOSTO.cdcooper%TYPE; 
       vr_nrdconta           TBCC_LIMITE_PREPOSTO.nrdconta%TYPE; 
       vr_nrcpf              TBCC_LIMITE_PREPOSTO.nrcpf%TYPE;
       vr_flgmaster          TBCC_LIMITE_PREPOSTO.flgmaster%TYPE;
    
       -- Variaveis de XML
       vr_xml_temp VARCHAR2(32767); 
      -- Cursores
      CURSOR cr_preposto_master IS
        SELECT tbcc_limite_preposto.cdcooper,
               tbcc_limite_preposto.nrcpf,
               tbcc_limite_preposto.nrdconta,  
               tbcc_limite_preposto.flgmaster      
        FROM tbcc_limite_preposto 
       WHERE tbcc_limite_preposto.cdcooper = pr_cdcooper
         AND tbcc_limite_preposto.nrdconta = pr_nrdconta
         AND tbcc_limite_preposto.flgmaster = 1;
    
      rw_preposto_master cr_preposto_master%ROWTYPE;
    
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
      
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
      FOR rw_preposto_master IN cr_preposto_master LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'preposto',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'preposto',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => rw_preposto_master.cdcooper,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'preposto',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrdconta',
                               pr_tag_cont => rw_preposto_master.nrdconta,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'preposto',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrcpf',
                               pr_tag_cont => rw_preposto_master.nrcpf,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'preposto',
                              pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgmaster',
                               pr_tag_cont => rw_preposto_master.flgmaster,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em pc_busca_preposto_master: ' || SQLERRM;
        pr_dscritic := pr_des_erro;
    END;
  END pc_busca_preposto_master;

  PROCEDURE pc_altera_preposto_master(pr_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                     ,pr_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE 
                                     ,pr_nrcpf    IN TBCC_LIMITE_PREPOSTO.nrcpf%TYPE 
                                     ,pr_xmllog   IN  VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER                       
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_altera_preposto_master
    --  Sistema  : Procedure alterar preposto master
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Alterar preposto master
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------                                      

    CURSOR cr_tbcc_limite_preposto (prc_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                   ,prc_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE 
                                   ,prc_nrcpf    IN TBCC_LIMITE_PREPOSTO.nrcpf%TYPE) IS
      SELECT tbcc_limite_preposto.cdcooper,
             tbcc_limite_preposto.nrcpf,
             tbcc_limite_preposto.nrdconta,  
             tbcc_limite_preposto.flgmaster
        FROM tbcc_limite_preposto 
       WHERE tbcc_limite_preposto.cdcooper = prc_cdcooper
         AND tbcc_limite_preposto.nrdconta = prc_nrdconta
         AND tbcc_limite_preposto.nrcpf    = prc_nrcpf;    

    rw_tbcc_limite_preposto cr_tbcc_limite_preposto%ROWTYPE;

    -- Variaveis local
    vr_flgmaster          TBCC_LIMITE_PREPOSTO.flgmaster%TYPE;
    
    -- Variaveis de XML
    vr_xml_temp VARCHAR2(32767); 
    -- Cursores
    
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    --vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);


    -- Variaveis de critica
    vr_dscritic crapcri.dscritic%TYPE;
    
  BEGIN
    OPEN cr_tbcc_limite_preposto (prc_cdcooper => pr_cdcooper
                                 ,prc_nrdconta => pr_nrdconta
                                 ,prc_nrcpf    => pr_nrcpf);
    FETCH cr_tbcc_limite_preposto INTO rw_tbcc_limite_preposto;
    -- Se nao existir preposto, inserir
    IF cr_tbcc_limite_preposto%NOTFOUND THEN

      BEGIN
        INSERT INTO tbcc_limite_preposto
          (cdcooper
	        ,nrdconta
          ,nrcpf
          ,flgmaster
          ,cdoperad
          ,vllimite_transf
          ,dtlimite_transf
          ,vllimite_pagto
          ,dtlimite_pagto
          ,vllimite_ted
          ,dtlimite_ted
          ,vllimite_vrboleto
          ,dtlimite_vrboleto
          ,vllimite_folha
          ,dtlimite_folha
          )
          VALUES
          (pr_cdcooper --cdcooper
          ,pr_nrdconta --nrdconta
          ,pr_nrcpf    --nrcpf
          ,1           --flgmaster
          ,1           --cdoperad
          ,0           --vllimite_transf
          ,SYSDATE     --dtlimite_transf
          ,0           --vllimite_pagto
          ,SYSDATE     --dtlimite_pagto
          ,0           --vllimite_ted
          ,SYSDATE     --dtlimite_ted
          ,0           --vllimite_vrboleto
          ,SYSDATE     --dtlimite_vrboleto
          ,0           --vllimite_folha
          ,SYSDATE     --dtlimite_folha
          );
      EXCEPTION
        WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro ao alterar tabela tbcc_limite_preposto: ' || SQLERRM;
        pr_dscritic := pr_des_erro;          
      END;
      CLOSE cr_tbcc_limite_preposto;
    ELSE
     if(rw_tbcc_limite_preposto.flgmaster = 1) then
       vr_flgmaster := 0;            
     else
       vr_flgmaster := 1;
     end if;
   
     BEGIN
       UPDATE tbcc_limite_preposto
          SET flgmaster = vr_flgmaster 
        WHERE tbcc_limite_preposto.cdcooper = pr_cdcooper
          AND tbcc_limite_preposto.nrdconta = pr_nrdconta
          AND tbcc_limite_preposto.nrcpf = pr_nrcpf;
     EXCEPTION
       WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro ao alterar tabela tbcc_limite_preposto: ' || SQLERRM;
        pr_dscritic := pr_des_erro;
      END;
      
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 0
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(1) --> Origem enviada
                          ,pr_dstransa => 'Altera Preposto Master'
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Preposto Master'
                             ,pr_dsdadant => nvl(rw_tbcc_limite_preposto.flgmaster,0)
                             ,pr_dsdadatu => vr_flgmaster);      
      CLOSE cr_tbcc_limite_preposto;
    END IF; 
    
    -- Confirma a transacao
    COMMIT;

  END pc_altera_preposto_master;
  
  PROCEDURE pc_valida_apv_master (pr_cdcooper IN crapsnh.cdcooper%TYPE 
                                 ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                                 ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE
                                 ,pr_cdtransacao_pendente IN tbgen_aprova_trans_pend.cdtransacao_Pendente%type
                                 ,pr_conttran OUT INTEGER -- Identificador se deve finalizar o processo ou nao
                                 ,pr_cdcritic OUT PLS_INTEGER                       
                                 ,pr_dscritic OUT VARCHAR2)IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_valida_apv_master
    --  Sistema  : Valida aprovação de preposto master
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Valida se o preposto que está aprovando uma transação pendente é um master.
    --
    -- Alteração : 05/10/2017 - Ajuste no cursor cr_tbgen_aprova_trans_pend para restringir também o CPF
    --                          (Rafael Monteiro - Mouts).
    --
    ---------------------------------------------------------------------------------------------------------------                                  

    -- Busca preposto master pela conta
    CURSOR cr_tbcc_limite_preposto IS
      SELECT 1
        FROM tbcc_limite_preposto t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.nrdconta  = pr_nrdconta
         AND t.flgmaster = 1 -- preposto master
         AND rownum      = 1;
    -- Buscar preposto master aprovador    
    CURSOR cr_tbcc_limite_preposto2 IS
      SELECT 1
        FROM tbcc_limite_preposto t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.nrdconta  = pr_nrdconta
         AND t.nrcpf     = pr_nrcpfcgc
         AND t.flgmaster = 1 -- preposto master 
         AND rownum      = 1;
    -- Busca aprovacoes da transacao em questao
    CURSOR cr_tbgen_aprova_trans_pend IS
       SELECT 1
        FROM tbgen_aprova_trans_pend  t,
             tbcc_limite_preposto     tl
       WHERE t.cdcooper                = pr_cdcooper
         AND t.nrdconta                = pr_nrdconta
         AND t.cdtransacao_pendente    = pr_cdtransacao_pendente 
         AND t.idsituacao_aprov        = 2  -- Aprovado 
         AND t.cdcooper                = tl.cdcooper
         AND t.nrdconta                = tl.nrdconta
         AND t.nrcpf_responsavel_aprov = tl.nrcpf
         AND tl.flgmaster              = 1 -- eh master
         AND rownum                    = 1;
    -- Variaveis
    va_aprovador_master NUMBER(1);
    va_preposto_ja_aprovou NUMBER(1);
  BEGIN
    
    pr_conttran := 1;
    
    -- Valida se existe preposto master para a conta
    FOR rw_tbcc_limite_preposto IN cr_tbcc_limite_preposto LOOP
      -- Validar se o aprovador eh preposto master
      va_aprovador_master := 0;
      FOR rw_tbcc_limite_preposto2 IN cr_tbcc_limite_preposto2 LOOP
        va_aprovador_master := 1;
      END LOOP;
      -- Se for preposto master o aprovador, devera retornar 1 
      IF va_aprovador_master = 1 THEN
        NULL; -- nao realizar nenhuma alteracao
      ELSE 
        -- Verifica se teve o preposto ja aprovou esta transacao
        va_preposto_ja_aprovou := 0;
        FOR rw_tbgen_aprova_trans_pend IN cr_tbgen_aprova_trans_pend LOOP
          va_preposto_ja_aprovou := 1;
        END LOOP;
        IF va_preposto_ja_aprovou = 1 THEN
          null; -- nao realizar nenhuma alteracao
        ELSE
          pr_dscritic := 'Necessário ter aprovação do presposto master.';
        END IF;
      END IF;
      
    END LOOP;
  
  END pc_valida_apv_master;
  
 PROCEDURE pc_corrigi_limite_preposto(pr_cdcooper IN VARCHAR2
                                     ,pr_nrdconta IN VARCHAR2 
                                     ,pr_idseqttl IN VARCHAR2
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_vllimtrf IN VARCHAR2 
                                     ,pr_vllimpgo IN VARCHAR2
                                     ,pr_vllimted IN VARCHAR2 
                                     ,pr_vllimvrb IN VARCHAR2 
                                     ,pr_xmllog   IN VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER                       
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_corrigi_limite_preposto
    --  Sistema  : Valida aprovação de preposto master
    --  Sigla    : CRED
    --  Autor    : Rafael Monteiro
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Corrige automaticamente os limites de prepostos e operadores para igual o menor limite de um 
    --             preposto.
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------                                      
    
    CURSOR cr_crapemp (prc_cdcooper IN crapemp.cdcooper%TYPE
                      ,prc_nrdconta IN crapemp.nrdconta%TYPE) IS 
      SELECT vllimfol 
        FROM crapemp 
       WHERE crapemp.cdcooper = prc_cdcooper 
         AND crapemp.nrdconta = prc_nrdconta; 
    rw_crapemp cr_crapemp%ROWTYPE;
    
    CURSOR cr_tbcc_limite_preposto (prc_cdcooper IN TBCC_LIMITE_PREPOSTO.cdcooper%TYPE 
                                   ,prc_nrdconta IN TBCC_LIMITE_PREPOSTO.nrdconta%TYPE) IS
      SELECT nrcpf,
             vllimite_transf,
             dtlimite_transf,
             vllimite_pagto,
             dtlimite_pagto,
             vllimite_ted,
             dtlimite_ted,
             vllimite_vrboleto,
             dtlimite_vrboleto,
             vllimite_folha,
             dtlimite_folha
        FROM tbcc_limite_preposto 
       WHERE tbcc_limite_preposto.cdcooper = prc_cdcooper
         AND tbcc_limite_preposto.nrdconta = prc_nrdconta;
    rw_tbcc_limite_preposto cr_tbcc_limite_preposto%ROWTYPE;
    --
    CURSOR cr_crapopi (prc_cdcooper       IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                      ,prc_nrdconta       IN crapass.nrdconta%TYPE ) IS
      SELECT opi.nrcpfope,
             opi.vllbolet, --  Valor Limite Boleto, Convenio e Todos os Tributos
             opi.vllimtrf, --	Valor Limite Transferencia
             opi.vllimted, --	Valor Limite TED
             opi.vllimvrb, --	Valor Limite VR Boleto
             opi.vllimflp  --	Valor Limite Folha de Pagamento
        FROM crapopi opi
       WHERE opi.cdcooper = prc_cdcooper
         AND opi.nrdconta = prc_nrdconta;    
    -- Variaveis
    vr_cdcooper crapsnh.cdcooper%type;
    vr_nrdconta crapsnh.nrdconta%type;
    vr_idseqttl crapsnh.idseqttl%type;
    
    vr_vllimtrf crapsnh.vllimtrf%type;
    vr_vllimpgo crapsnh.vllimpgo%type;
    vr_vllimted crapsnh.vllimted%type;
    vr_vllimvrb crapsnh.vllimvrb%type;
    vr_vllimflp crapsnh.vllimflp%type;
    
    vr_nvlimtrf crapsnh.vllimtrf%type;
    vr_nvlimpgo crapsnh.vllimpgo%type;
    vr_nvlimted crapsnh.vllimted%type;
    vr_nvlimvrb crapsnh.vllimvrb%type;
    vr_nvlimflp crapsnh.vllimflp%type;
    
    vrb_dtlimite_transf tbcc_limite_preposto.dtlimite_transf%type;
    vrb_dtlimite_pagto tbcc_limite_preposto.dtlimite_pagto%type; 
    vrb_dtlimite_ted tbcc_limite_preposto.dtlimite_ted%type;
    vrb_dtlimite_vrboleto tbcc_limite_preposto.dtlimite_vrboleto%type;
    vrb_dtlimite_folha tbcc_limite_preposto.dtlimite_folha%type;

    vrb_vllimfol crapemp.vllimfol%type;
    
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    --vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);
    
    vr_update number(1);
    vr_alterou BOOLEAN;
    vr_alerta   varchar2(1000);
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;    
        
  BEGIN

    vr_alerta := 'OK';
    vr_alterou  := FALSE; -- veifica se sera necessario commit
    --
    vr_cdcooper := gene0002.fn_char_para_number(pr_dsnumtex => pr_cdcooper);
    vr_nrdconta := gene0002.fn_char_para_number(pr_dsnumtex => pr_nrdconta); 
    vr_idseqttl := gene0002.fn_char_para_number(pr_dsnumtex => pr_idseqttl); 
    vr_vllimtrf := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimtrf);
    vr_vllimpgo := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimpgo);
    vr_vllimted := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimted);
    vr_vllimvrb := gene0002.fn_char_para_number(pr_dsnumtex => pr_vllimvrb); 
    --
    BEGIN
      OPEN cr_crapemp (prc_cdcooper => vr_cdcooper
                      ,prc_nrdconta => vr_nrdconta);
      FETCH cr_crapemp INTO rw_crapemp;
        IF cr_crapemp%FOUND THEN
          vrb_vllimfol := rw_crapemp.vllimfol;
        ELSE 
          vrb_vllimfol := NULL;
        END IF;
        -- Fechar Cursor 
        CLOSE cr_crapemp;
    EXCEPTION
      WHEN OTHERS THEN
         pr_cdcritic := 0;
         vr_alerta := 'Erro pc_corrigi_limite_preposto. cursor cr_crapemp - Erro: '|| SQLERRM;
         RAISE vr_exc_erro;
    END;
    --
    -- Valida os limites dos prepostos   
    FOR rw_tbcc_limite_preposto IN cr_tbcc_limite_preposto(vr_cdcooper, vr_nrdconta) LOOP
      --
      vr_nvlimtrf := NULL;
      vr_nvlimpgo := NULL;
      vr_nvlimted := NULL;
      vr_nvlimvrb := NULL;
      vr_nvlimflp := NULL;
      vr_update   := 0; -- verifica se é ncessario realizar update
      --
      IF vr_vllimtrf < rw_tbcc_limite_preposto.vllimite_transf THEN
        vr_nvlimtrf := vr_vllimtrf;
        vr_update := 1;
        vrb_dtlimite_transf := sysdate;
      END IF;
      IF vr_vllimpgo < rw_tbcc_limite_preposto.vllimite_pagto THEN
        vr_nvlimpgo := vr_vllimpgo;
        vr_update := 1;
        vrb_dtlimite_pagto := sysdate;
      END IF; 
      IF vr_vllimted < rw_tbcc_limite_preposto.vllimite_ted THEN
        vr_nvlimted := vr_vllimted;
        vr_update := 1;
        vrb_dtlimite_ted := sysdate;
      END IF;
      IF vr_vllimvrb < rw_tbcc_limite_preposto.vllimite_vrboleto THEN
        vr_nvlimvrb := vr_vllimvrb;
        vr_update := 1;
        vrb_dtlimite_vrboleto := sysdate;
      END IF;
      IF vrb_vllimfol < rw_tbcc_limite_preposto.vllimite_folha THEN
        vr_nvlimflp := vrb_vllimfol;
        vr_update := 1;
        vrb_dtlimite_folha := sysdate;
      END IF;

      IF vr_update = 1 THEN
        vr_alterou := TRUE;
        BEGIN
          UPDATE TBCC_LIMITE_PREPOSTO t
             SET t.cdoperad          = pr_cdoperad,
                 t.vllimite_transf   = NVL(vr_nvlimtrf,t.vllimite_transf),
                 t.dtlimite_transf   = NVL(vrb_dtlimite_transf,t.dtlimite_transf),
                 t.vllimite_pagto    = NVL(vr_nvlimpgo,t.vllimite_pagto),
                 t.dtlimite_pagto    = NVL(vrb_dtlimite_pagto,t.dtlimite_pagto),
                 t.vllimite_ted      = NVL(vr_nvlimted,t.vllimite_ted),
                 t.dtlimite_ted      = NVL(vrb_dtlimite_ted,t.dtlimite_ted),
                 t.vllimite_vrboleto = NVL(vr_nvlimvrb,t.vllimite_vrboleto),
                 t.dtlimite_vrboleto = NVL(vrb_dtlimite_vrboleto,t.dtlimite_vrboleto),
                 t.vllimite_folha    = NVL(vr_nvlimflp,t.vllimite_folha),
                 t.dtlimite_folha    = NVL(vrb_dtlimite_folha,t.dtlimite_folha)
           WHERE t.cdcooper = vr_cdcooper
             AND t.nrdconta = vr_nrdconta
             AND t.nrcpf    = rw_tbcc_limite_preposto.nrcpf;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            vr_alerta := 'Erro pc_corrigi_limite_preposto update TBCC_LIMITE_PREPOSTO:' || SQLERRM;
            raise vr_exc_erro;
        END;
        --
        BEGIN   
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_alerta
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(1) --> Origem enviada
                            ,pr_dstransa => 'Corrige Limite de Preposto.'
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => vr_idseqttl
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => vr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Valor de Transferencia'
                                   ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_transf
                                   ,pr_dsdadatu => vr_nvlimtrf);
                                         
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de Boleto'
                                  ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_pagto
                                  ,pr_dsdadatu => vr_nvlimpgo); 
                                       
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de TED'
                                  ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_ted
                                  ,pr_dsdadatu => vr_nvlimted); 
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de VR Boleto'
                                  ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_vrboleto
                                  ,pr_dsdadatu => vr_nvlimvrb); 
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de Folha PGTO'
                                  ,pr_dsdadant => rw_tbcc_limite_preposto.vllimite_folha
                                  ,pr_dsdadatu => vr_nvlimflp);
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'CPF do Preposto'
                                  ,pr_dsdadant => rw_tbcc_limite_preposto.nrcpf
                                  ,pr_dsdadatu => vr_nvlimflp);                        
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            vr_alerta := 'Erro ao gerar LOG. ' || SQLERRM;
            raise vr_exc_erro;
        END;  
      END IF;
    END LOOP;
    --
    FOR rw_crapopi IN cr_crapopi(vr_cdcooper, vr_nrdconta) LOOP
      --
      vr_nvlimtrf := NULL;
      vr_nvlimpgo := NULL;
      vr_nvlimted := NULL;
      vr_nvlimvrb := NULL;
      vr_nvlimflp := NULL;
      vr_update   := 0; -- verifica se é ncessario realizar update
      --
      IF vr_vllimtrf < rw_crapopi.vllimtrf THEN
        vr_nvlimtrf := vr_vllimtrf;
        vr_update := 1;
      END IF;
      IF vr_vllimpgo < rw_crapopi.vllbolet THEN
        vr_nvlimpgo := vr_vllimpgo;
        vr_update := 1;
      END IF; 
      IF vr_vllimted < rw_crapopi.vllimted THEN
        vr_nvlimted := vr_vllimted;
        vr_update := 1;

      END IF;
      IF vr_vllimvrb < rw_crapopi.vllimvrb THEN
        vr_nvlimvrb := vr_vllimvrb;
        vr_update := 1;
      END IF;
      IF vrb_vllimfol < rw_crapopi.vllimflp THEN
        vr_nvlimflp := vrb_vllimfol;
        vr_update := 1;
      END IF;

      IF vr_update = 1 THEN
        vr_alterou := TRUE;
        BEGIN
          UPDATE crapopi t
             SET t.vllimtrf = NVL(vr_nvlimtrf,t.vllimtrf),
                 t.vllbolet = NVL(vr_nvlimpgo,t.vllbolet),
                 t.vllimted = NVL(vr_nvlimted,t.vllimted),
                 t.vllimvrb = NVL(vr_nvlimvrb,t.vllimvrb),
                 t.vllimflp = NVL(vr_nvlimflp,t.vllimflp)
           WHERE t.cdcooper = vr_cdcooper
             AND t.nrdconta = vr_nrdconta
             AND t.nrcpfope = rw_crapopi.nrcpfope;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            vr_alerta := 'Erro pc_corrigi_limite_preposto update crapopi: ' || SQLERRM;
            raise vr_exc_erro;
        END;
        --
        BEGIN   
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_alerta
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(1) --> Origem enviada
                              ,pr_dstransa => 'Corrige Limite de Operador.'
                              ,pr_dttransa => trunc(sysdate)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => vr_idseqttl
                              ,pr_nmdatela => 'ATENDA'
                              ,pr_nrdconta => vr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Valor de Transferencia'
                                   ,pr_dsdadant => rw_crapopi.vllimtrf
                                   ,pr_dsdadatu => vr_nvlimtrf);
                                         
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de Boleto'
                                  ,pr_dsdadant => rw_crapopi.vllbolet
                                  ,pr_dsdadatu => vr_nvlimpgo); 
                                       
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de TED'
                                  ,pr_dsdadant => rw_crapopi.vllimted
                                  ,pr_dsdadatu => vr_nvlimted); 
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de VR Boleto'
                                  ,pr_dsdadant => rw_crapopi.vllimvrb
                                  ,pr_dsdadatu => vr_nvlimvrb); 
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'Valor de Folha PGTO'
                                  ,pr_dsdadant => rw_crapopi.vllimflp
                                  ,pr_dsdadatu => vr_nvlimflp);
                                      
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                  ,pr_nmdcampo => 'CPF do Operador'
                                  ,pr_dsdadant => rw_crapopi.nrcpfope
                                  ,pr_dsdadatu => vr_nvlimflp);                        
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            vr_alerta := 'Erro ao gerar LOG operador: ' || SQLERRM;
            raise vr_exc_erro;
        END;  
      END IF;
    END LOOP;    

    -- Confirma a transacao
    IF vr_alterou THEN
      COMMIT;
    END IF;
     --
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'preposto',
                           pr_tag_cont => NULL,
                           pr_des_erro => pr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'preposto',
                           pr_posicao  => 0,
                           pr_tag_nova => 'pralerta',
                           pr_tag_cont => vr_alerta,
                           pr_des_erro => pr_dscritic);
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := pr_cdcritic;
      --pr_dscritic := vr_alerta;   
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'alerta',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'alerta',
                             pr_posicao  => 0,
                             pr_tag_nova => 'pralerta',
                             pr_tag_cont => vr_alerta,
                             pr_des_erro => pr_dscritic);     
                           
/*     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><pralerta>' || pr_dscritic || '</pralerta></Root>'); */
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      vr_alerta := 'Erro geral na procedure pc_corrigi_limite_preposto. - Erro: '|| SQLERRM;      
      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'alerta',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'alerta',
                             pr_posicao  => 0,
                             pr_tag_nova => 'pralerta',
                             pr_tag_cont => vr_alerta,
                             pr_des_erro => pr_dscritic);                                          

                                        
  END pc_corrigi_limite_preposto;
  
PROCEDURE pc_busca_resp_assinatura(pr_cdcooper IN VARCHAR2 
                                  ,pr_nrdconta IN VARCHAR2 
                                  ,pr_xmllog   IN  VARCHAR2
                                  ,pr_cdcritic OUT PLS_INTEGER                       
                                  ,pr_dscritic OUT VARCHAR2
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
    --  Programa : pc_busca_resp_assinatura
    --  Sistema  : Procedure buscar os responsaveis por assinatura
  --  Sigla    : CRED
    --  Autor    : Mateus Zimmermann (Mouts)
    --  Data     : Janeiro/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
    -- Objetivo  : Buscar os responsaveis por assinatura
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------   
    BEGIN
		DECLARE

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
      -- Cursores
      CURSOR cr_resp_assinatura IS
        SELECT crapass.nmprimtl
              ,crapass.nrcpfcgc
        FROM crapavt,
             crappod,
             crapass
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crappod.cdcooper = crapavt.cdcooper
         AND crappod.nrdconta = crapavt.nrdconta 
         AND crappod.nrcpfpro = crapavt.nrcpfcgc 
         AND crappod.nrctapro = crapavt.nrdctato
         AND crappod.cddpoder = 10
         AND crapass.cdcooper = crapavt.cdcooper
         AND crapass.nrdconta = crappod.nrctapro;
      rw_resp_assinatura cr_resp_assinatura%ROWTYPE;
 
      -- Variaveis locais
      vr_contador INTEGER := 0;
    
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
      
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Responsaveis',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
																					
    FOR rw_resp_assinatura IN cr_resp_assinatura LOOP
			
        gene0007.pc_insere_tag(pr_xml => pr_retxml,
                               pr_tag_pai => 'Responsaveis',
                               pr_posicao => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml,
                               pr_tag_pai => 'inf',
                               pr_posicao => vr_contador, 
                               pr_tag_nova => 'nmprimtl', 
                               pr_tag_cont => rw_resp_assinatura.nmprimtl, 
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,
                               pr_tag_pai => 'inf',
                               pr_posicao => vr_contador, 
                               pr_tag_nova => 'nrcpfcgc', 
                               pr_tag_cont => rw_resp_assinatura.nrcpfcgc, 
                               pr_des_erro => vr_dscritic);
			
        vr_contador := vr_contador + 1;	
        
        END LOOP;

		EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em pc_busca_resp_assinatura: ' || SQLERRM;
        pr_dscritic := pr_des_erro;
    END;
  END pc_busca_resp_assinatura;

    --> Rotina responsavel pela criacao de transacoes pendentes de pagamentos de tributos
  PROCEDURE pc_cria_trans_pend_tributos(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (3 – FGTS / 4 – DAE)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia                                      
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrsqgrde  IN NUMBER                                --> Numero da guia GRDE
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_identifi  IN VARCHAR2 						                  --> Número de identificacao CNPJ/CPF/CEI
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_identificador IN VARCHAR2                          --> Identificador                                       
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2) IS 			                    --> Descriçao do erro 
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_trans_pend_tributos
  --  Sistema  : Rotina responsavel pela criacao de transacoes pendentes de pagamentos de tributos
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Janeiro/2018                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotina responsavel pela criacao de transacoes pendentes de pagamentos de tributos
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------   
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; -- Tabela Avalistas 
    vr_lindigit VARCHAR2(500) := '';
    -- log verlog
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(100);
    vr_dsorigem VARCHAR2(100) := GENE0001.vr_vet_des_origens(pr_idorigem);

    -- Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN
  
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => ( CASE pr_tpdaguia
                                                           WHEN 3 THEN 14 -- FGTS
                                                           WHEN 4 THEN 15 -- DAE
                                                           ELSE 14
                                                         END )
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_lindigit := SUBSTR(TO_CHAR(pr_lindigi1,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi1,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi2,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi2,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi3,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi3,'fm000000000000'),12,1) ||' '||
                   SUBSTR(TO_CHAR(pr_lindigi4,'fm000000000000'),1,11) ||'-'||
                   SUBSTR(TO_CHAR(pr_lindigi4,'fm000000000000'),12,1);

    BEGIN
      INSERT INTO
        tbpagto_tributos_trans_pend(
                  cdtransacao_pendente, 
                  cdcooper, 
                  nrdconta, 
                  tppagamento, 
                  dscod_barras, 
                  dslinha_digitavel, 
                  nridentificacao, 
                  cdtributo, 
                  dtvalidade, 
                  dtcompetencia, 
                  nrseqgrde, 
                  nridentificador, 
                  dsidenti_pagto, 
                  vlpagamento, 
                  dtdebito, 
                  idagendamento)
                  
        VALUES(  vr_cdtranpe       -- cdtransacao_pendente
                ,pr_cdcooper       -- cdcooper
                ,pr_nrdconta       -- nrdconta
                ,pr_tpdaguia       -- tppagamento
                ,pr_cdbarras       -- dscod_barras
                ,vr_lindigit       -- dslinha_digitavel
                ,pr_identifi       -- nridentificacao
                ,pr_cdtribut       -- cdtributo
                ,pr_dtvencto       -- dtvalidade
                ,pr_dtapurac       -- dtcompetencia
                ,pr_nrsqgrde       -- nrseqgrde
                ,TRIM(pr_identificador)  -- nridentificador
                ,pr_dsidepag       -- dsidenti_pagto
                ,pr_vlrtotal       -- vlpagamento
                ,pr_dtagenda       -- dtdebito
                ,pr_idagenda       -- idagendamento
                );
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_tributos_trans_pend: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => ( CASE pr_tpdaguia
                                                WHEN 3 THEN 14 -- FGTS
                                                WHEN 4 THEN 15 -- DAE
                                                ELSE 14
                                              END )
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_nrdrowid := NULL;
    CASE pr_tpdaguia
      WHEN 3 THEN -- FGTS
        vr_dstransa := '14 - Transacao de FGTS pendente de aprovacao de assinatura conjunta';
      WHEN 4 THEN -- DAE
        vr_dstransa := '15 - Transacao de DAE pendente de aprovacao de assinatura conjunta';
      ELSE vr_dstransa := ' ';
    END CASE;
    
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'VLRTOTAL'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vlrtotal);
                             
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'NRCPFREP'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfrep);                             
    COMMIT;

  EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= NVL(vr_cdcritic,0);

        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE
          pr_dscritic:= vr_dscritic;
        END IF;

        ROLLBACK;
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina INET002.pc_cria_trans_pend_tributos. '||sqlerrm; 
      ROLLBACK;
  END pc_cria_trans_pend_tributos;  
  
  --
  PROCEDURE pc_ret_trans_pend_trib( pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                            --> Identificador de Origem 
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                                   ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                                   ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                   ,pr_tab_tributos OUT INET0002.typ_tab_tributos) IS --> Tabela com os dados de tributos

   BEGIN															 
	 /* .............................................................................

     Programa: pc_ret_trans_pend_trib
     Sistema : 
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de transacao pendente de tributos.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		
		DECLARE
	
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_saida EXCEPTION;
            
			-- Declaração da tabela que conterá os dados de DARF/DAS
			vr_tab_tributos INET0002.typ_tab_tributos;
			vr_ind          PLS_INTEGER := 0;

      -- Seleciona registro de trans. pend.
	    CURSOR cr_tbtrib_pend(pr_cdcooper IN crapass.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE
                           ,pr_cdtrapen IN VARCHAR2) IS 
			  SELECT trib.cdtransacao_pendente, 
               trib.cdcooper, 
               trib.nrdconta, 
               trib.tppagamento, 
               trib.dscod_barras, 
               trib.dslinha_digitavel, 
               trib.nridentificacao, 
               trib.cdtributo, 
               trib.dtvalidade, 
               trib.dtcompetencia, 
               trib.nrseqgrde, 
               trib.nridentificador, 
               trib.dsidenti_pagto, 
               trib.vlpagamento, 
               trib.dtdebito, 
               trib.idagendamento,
               trib.ROWID
				  FROM tbpagto_tributos_trans_pend trib
         WHERE (trib.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND (trib.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
           AND (pr_cdtrapen IS NULL OR (trib.cdtransacao_pendente IN (SELECT regexp_substr(pr_cdtrapen, '[^;]+', 1, ROWNUM) parametro
               FROM dual CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_cdtrapen ,'[^;]+','')) + 1)));

			rw_tbtrib_pend cr_tbtrib_pend%ROWTYPE;
			
			-- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
	  BEGIN
			
			-- Listar reg. trans pend
			FOR rw_tbtrib_pend IN cr_tbtrib_pend(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_cdtrapen => pr_cdtrapen) LOOP      

	      -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
	      vr_ind := vr_tab_tributos.COUNT() + 1;
        
        vr_tab_tributos(vr_ind).cdtransacao_pendente := rw_tbtrib_pend.cdtransacao_pendente;
        vr_tab_tributos(vr_ind).cdcooper             := rw_tbtrib_pend.cdcooper         ;
        vr_tab_tributos(vr_ind).nrdconta             := rw_tbtrib_pend.nrdconta         ;
        vr_tab_tributos(vr_ind).tppagamento          := rw_tbtrib_pend.tppagamento      ;
        vr_tab_tributos(vr_ind).dscod_barras         := rw_tbtrib_pend.dscod_barras     ;
        vr_tab_tributos(vr_ind).dslinha_digitavel    := rw_tbtrib_pend.dslinha_digitavel;
        vr_tab_tributos(vr_ind).nridentificacao      := rw_tbtrib_pend.nridentificacao  ;
        vr_tab_tributos(vr_ind).cdtributo            := rw_tbtrib_pend.cdtributo        ;
        vr_tab_tributos(vr_ind).dtvalidade           := rw_tbtrib_pend.dtvalidade       ;
        vr_tab_tributos(vr_ind).dtcompetencia        := rw_tbtrib_pend.dtcompetencia    ;
        vr_tab_tributos(vr_ind).nrseqgrde            := rw_tbtrib_pend.nrseqgrde        ;
        vr_tab_tributos(vr_ind).nridentificador      := rw_tbtrib_pend.nridentificador  ;
        vr_tab_tributos(vr_ind).dsidenti_pagto       := rw_tbtrib_pend.dsidenti_pagto   ;
        vr_tab_tributos(vr_ind).vlpagamento          := rw_tbtrib_pend.vlpagamento      ;
        vr_tab_tributos(vr_ind).dtdebito             := rw_tbtrib_pend.dtdebito         ;
        vr_tab_tributos(vr_ind).idagendamento        := rw_tbtrib_pend.idagendamento    ;
        
        vr_tab_tributos(vr_ind).idrowid              := rw_tbtrib_pend.ROWID;				
			END LOOP; -- FOR rw_darfdas

			-- Alimenta parâmetro com a PL/Table gerada
			pr_tab_tributos := vr_tab_tributos;
						
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_cdcritic:= NVL(vr_cdcritic,0);

        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE
          pr_dscritic:= vr_dscritic;
        END IF;
        
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na INET0002.pc_ret_trans_pend_trib: ' || SQLERRM;
		END;
	END pc_ret_trans_pend_trib;

  PROCEDURE pc_ret_trans_pend_trib_car( pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                       ,pr_idorigem IN INTEGER               --> Identificador de Origem 
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                       ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
                                       ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														 		       ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

		BEGIN
	 /* .............................................................................

     Programa: pc_ret_trans_pend_trib_car
     Sistema : 
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de transacao pendente de tributos.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declaração da tabela que conterá os dados de tributos
			vr_tab_tributos INET0002.typ_tab_tributos;
			vr_ind          PLS_INTEGER := 0;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
		  -- Procedure para buscar informações tributos
      INET0002.pc_ret_trans_pend_trib( pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad           --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela           --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem           --> Identificador de Origem 
                                      ,pr_nrdconta => pr_nrdconta           --> Número da Conta
                                      ,pr_idseqttl => pr_idseqttl           --> Titular da Conta 		
                                      ,pr_cdtrapen => pr_cdtrapen           --> Codigo da Transacao														 
                                      ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                      ,pr_dscritic => vr_dscritic           --> Descrição da crítica
                                      ,pr_tab_tributos => vr_tab_tributos); --> Tabela com os dados
																					
			-- Se retornou alguma critica
			IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				RAISE vr_exc_saida;
			END IF;
			
			-- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
			
			IF vr_tab_tributos.count() > 0 THEN
				-- Percorre dados
				FOR vr_contador IN vr_tab_tributos.FIRST..vr_tab_tributos.LAST LOOP
        
					-- Montar XML com registros
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     => '<registro>' ||
                                                          '<cdtransacao_pendente>' || NVL(vr_tab_tributos(vr_contador).cdtransacao_pendente,0)         || '</cdtransacao_pendente>' || 
                                                          '<cdcooper>            ' || NVL(vr_tab_tributos(vr_contador).cdcooper,0)                     || '</cdcooper>            ' );
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>                                                 
                                                          '<nrdconta>            ' || NVL(vr_tab_tributos(vr_contador).nrdconta,0)                     || '</nrdconta>            ' || 
                                                          '<tppagamento>         ' || NVL(vr_tab_tributos(vr_contador).tppagamento,0)                  || '</tppagamento>         ' || 
                                                          '<dscod_barras>        ' || NVL(vr_tab_tributos(vr_contador).dscod_barras,' ')               || '</dscod_barras>        ' ); 
                                                          
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>    '<dslinha_digitavel>   ' || NVL(vr_tab_tributos(vr_contador).dslinha_digitavel,' ')          || '</dslinha_digitavel>   ' || 
                                                          '<nridentificacao>     ' || NVL(vr_tab_tributos(vr_contador).nridentificacao,' ')            || '</nridentificacao>     ' || 
                                                          '<cdtributo>           ' || NVL(vr_tab_tributos(vr_contador).cdtributo,' ')                  || '</cdtributo>           ' || 
                                                          '<dtvalidade>          ' || to_char(vr_tab_tributos(vr_contador).dtvalidade,'DD/MM/RRRR')    || '</dtvalidade>          ' );
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>    '<dtcompetencia>       ' || to_char(vr_tab_tributos(vr_contador).dtcompetencia,'DD/MM/RRRR') || '</dtcompetencia>       ' || 
                                                          '<nrseqgrde>           ' || NVL(vr_tab_tributos(vr_contador).nrseqgrde,0)                    || '</nrseqgrde>           ' );
          
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>    '<nridentificador>     ' || (case when vr_tab_tributos(vr_contador).cdtributo in ('239','451') then
                                                                                      NVL(lpad(vr_tab_tributos(vr_contador).nridentificador, 15, '0'),0)              
                                                                                      when vr_tab_tributos(vr_contador).cdtributo = '181' then
                                                                                      NVL(lpad(vr_tab_tributos(vr_contador).nridentificador, 16, '0'),0)         
                                                                                      else
                                                                                      NVL(lpad(vr_tab_tributos(vr_contador).nridentificador, 17, '0'),0)
                                                                                      end) || '</nridentificador>     ' || 
                                                          '<dsidenti_pagto>      ' || NVL(vr_tab_tributos(vr_contador).dsidenti_pagto,' ')             || '</dsidenti_pagto>      ' );
                                                          
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>    '<vlpagamento>         ' || NVL(vr_tab_tributos(vr_contador).vlpagamento,0)                  || '</vlpagamento>         ' || 
                                                          '<dtdebito>            ' || to_char(vr_tab_tributos(vr_contador).dtdebito,'DD/MM/RRRR')      || '</dtdebito>            ' || 
                                                          '<idagendamento>       ' || NVL(vr_tab_tributos(vr_contador).idagendamento,0)                || '</idagendamento>       ' );
                                                          
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     =>                                                 
                                                                    
                                                          '<idrowid>'              || NVL(vr_tab_tributos(vr_contador).idrowid,'0')                    || '</idrowid>            ' ||
																										   '</registro>');
        END LOOP;

			END IF;

			-- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</raiz>' 
                             ,pr_fecha_xml      => TRUE);
			
		EXCEPTION
			WHEN vr_exc_saida THEN

        pr_cdcritic:= NVL(vr_cdcritic,0);

        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE
          pr_dscritic:= vr_dscritic;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes INET0002.pc_ret_trans_pend_trib_car: ' || SQLERRM;

    END;
  END pc_ret_trans_pend_trib_car;

  PROCEDURE pc_cria_trans_pend_dscto_tit(pr_cdcooper          IN tbdsct_trans_pend.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_nrdconta          IN tbdsct_trans_pend.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl          IN crapttl.idseqttl%TYPE           --> Número do Titular
                                        ,pr_nrcpfrep          IN crapopi.nrcpfope%TYPE           --> Numero do cpf do representante legal
                                        ,pr_cdagenci          IN crapage.cdagenci%TYPE           --> Codigo do PA
                                        ,pr_nrdcaixa          IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                        ,pr_cdoperad          IN crapope.cdoperad%TYPE           --> Codigo do Operados
                                        ,pr_nmdatela          IN craptel.nmdatela%TYPE           --> Nome da Tela
                                        ,pr_idorigem          IN INTEGER                         --> Origem da solicitacao
                                        ,pr_nrcpfope          IN crapopi.nrcpfope%TYPE           --> Numero do cpf do operador juridico
                                        ,pr_cdcoptfn          IN tbgen_trans_pend.cdcoptfn%TYPE  --> Cooperativa do Terminal
                                        ,pr_cdagetfn          IN tbgen_trans_pend.cdagetfn%TYPE  --> Agencia do Terminal
                                        ,pr_nrterfin          IN tbgen_trans_pend.nrterfin%TYPE  --> Numero do Terminal Financeiro
                                        ,pr_dtmvtolt          IN DATE                            --> Data do movimento     
                                        ,pr_idastcjt          IN crapass.idastcjt%TYPE           --> Indicador de Assinatura Conjunta
                                        ,pr_tab_dados_titulos IN tela_atenda_dscto_tit.typ_tab_dados_titulos --> Titulos para desconto
                                        ,pr_cdcritic         OUT crapcri.cdcritic%TYPE           --> Codigo de Critica
                                        ,pr_dscritic         OUT crapcri.dscritic%TYPE           --> Descricao de Critica
                                        ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_cria_trans_pend_dscto_tit
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Procedimentos de criacao de transacao de bordero de desconto de titulos

    Alteração : 18/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_cdtranpe     tbgen_trans_pend.cdtransacao_pendente%TYPE;
  vr_tab_crapavt  CADA0001.typ_tab_crapavt_58; --Tabela Avalistas

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exec_saida EXCEPTION;
    
  BEGIN
    pc_cria_transacao_operador(pr_cdagenci    => pr_cdagenci
                              ,pr_nrdcaixa    => pr_nrdcaixa
                              ,pr_cdoperad    => pr_cdoperad
                              ,pr_nmdatela    => pr_nmdatela
                              ,pr_idorigem    => pr_idorigem
                              ,pr_idseqttl    => pr_idseqttl
                              ,pr_cdcooper    => pr_cdcooper
                              ,pr_nrdconta    => pr_nrdconta
                              ,pr_nrcpfope    => pr_nrcpfope
                              ,pr_nrcpfrep    => pr_nrcpfrep
                              ,pr_cdcoptfn    => pr_cdcoptfn
                              ,pr_cdagetfn    => pr_cdagetfn
                              ,pr_nrterfin    => pr_nrterfin
                              ,pr_dtmvtolt    => pr_dtmvtolt
                              ,pr_cdtiptra    => 19 -- bordero desconto cheque
                              ,pr_idastcjt    => pr_idastcjt
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_cdtranpe    => vr_cdtranpe
                              ,pr_dscritic    => vr_dscritic);
                                         
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exec_saida;
    END IF;

    FOR idx IN pr_tab_dados_titulos.first..pr_tab_dados_titulos.last LOOP
        BEGIN
          INSERT INTO tbdsct_trans_pend
                 (cdtransacao_pendente
                 ,cdcooper
                 ,nrdconta
                 ,cdbandoc
                 ,nrdctabb
                 ,nrcnvcob
                 ,nrdocmto
                 ,dtmvtolt
                 ,vltitulo
                 ,dtvencto
                 ,idseqttl
                 ,nrnosnum
                 ,nrinssac
                 ,nmdsacad)
          VALUES (vr_cdtranpe
                 ,pr_cdcooper
                 ,pr_nrdconta
                 ,pr_tab_dados_titulos(idx).cdbandoc
                 ,pr_tab_dados_titulos(idx).nrdctabb
                 ,pr_tab_dados_titulos(idx).nrcnvcob
                 ,pr_tab_dados_titulos(idx).nrdocmto
                 ,pr_tab_dados_titulos(idx).dtmvtolt
                 ,pr_tab_dados_titulos(idx).vltitulo
                 ,pr_tab_dados_titulos(idx).dtvencto
                 ,pr_idseqttl
                 ,pr_tab_dados_titulos(idx).nrnosnum
                 ,pr_tab_dados_titulos(idx).nrinssac
                 ,pr_tab_dados_titulos(idx).nmdsacad);
        EXCEPTION
          WHEN OTHERS THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao incluir registro tbdsct_trans_pend. Erro: ' || SQLERRM;
        END;
  		END LOOP;

    pc_cria_aprova_transpend(pr_cdagenci    => pr_cdagenci
                            ,pr_nrdcaixa    => pr_nrdcaixa
                            ,pr_cdoperad    => pr_cdoperad
                            ,pr_nmdatela    => pr_nmdatela
                            ,pr_idorigem    => pr_idorigem
                            ,pr_idseqttl    => pr_idseqttl
                            ,pr_cdcooper    => pr_cdcooper
                            ,pr_nrdconta    => pr_nrdconta
                            ,pr_nrcpfrep    => pr_nrcpfrep
                            ,pr_dtmvtolt    => pr_dtmvtolt
                            ,pr_cdtiptra    => 19 -- bordero desconto cheque
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe    => vr_cdtranpe
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);

    IF  NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exec_saida;
    END IF;
    
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
         pr_cdcritic := vr_cdcritic;
         IF  vr_cdcritic <> 0 THEN
             pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         ELSE	
             pr_dscritic := vr_dscritic;
         END IF;
         ROLLBACK;

    WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_dscto_tit. Erro: '|| SQLERRM; 
         ROLLBACK; 
  END pc_cria_trans_pend_dscto_tit;	

  --Busca registros de transações pendentes de contrato
  PROCEDURE pc_ret_trans_pend_ctd_car (pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE       --> Nome da Tela
                                      ,pr_idorigem IN INTEGER                     --> Identificador de Origem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Titular da Conta
                                      ,pr_cdtrapen IN VARCHAR2                    --> Codigo da Transacao
                                      ,pr_clobxmlc OUT CLOB                       --> XML com informações de Log
                                      ,pr_cdcritic OUT INTEGER                    --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2)                  --> Descrição da crítica
  IS
  BEGIN
/* .............................................................................
   Programa: pc_ret_trans_pend_ctd_car
   Sistema :
   Sigla : CRED
   Autor : Marcelo Telles Coelho - Mouts
   Data : Dezembro/2018. Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo : Rotina referente a busca de registros de transacao pendente de Contratos.

   Observacao: -----

   Alteracoes: -----
..............................................................................*/
DECLARE
  
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(10000);

   -- Tratamento de erros
   vr_exc_saida EXCEPTION;

   -- Declaração da tabela que conterá os dados de Contrato
   vr_tab_ctd INET0002.typ_tab_ctd;
   vr_ind PLS_INTEGER := 0;
  
   -- Variaveis de XML
   vr_xml_temp VARCHAR2(32767);
  
  BEGIN
  -- Procedure para buscar informações tributos
  INET0002.pc_ret_trans_pend_ctd( pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                 ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                 ,pr_nmdatela => pr_nmdatela --> Nome da Tela
                                 ,pr_idorigem => pr_idorigem --> Identificador de Origem
                                 ,pr_nrdconta => pr_nrdconta --> Número da Conta
                                 ,pr_idseqttl => pr_idseqttl --> Titular da Conta
                                 ,pr_cdtrapen => pr_cdtrapen --> Codigo da Transacao
                                 ,pr_cdcritic => vr_cdcritic --> Código da crítica
                                 ,pr_dscritic => vr_dscritic --> Descrição da crítica
                                 ,pr_tab_ctd => vr_tab_ctd); --> Tabela com os dados

  -- Se retornou alguma critica
  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  -- Criar documento XML
  dbms_lob.createtemporary(pr_clobxmlc, TRUE);
  dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

  -- Insere o cabeçalho do XML
  gene0002.pc_escreve_xml(pr_xml => pr_clobxmlc
                         ,pr_texto_completo => vr_xml_temp
                         ,pr_texto_novo => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

  IF vr_tab_ctd.count() > 0 THEN
  -- Percorre dados

    FOR vr_contador IN vr_tab_ctd.FIRST..vr_tab_ctd.LAST LOOP

    -- Montar XML com registros
    gene0002.pc_escreve_xml(pr_xml => pr_clobxmlc
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo => '<registro>' || '<cdtransacao_pendente>' ||
                           NVL(vr_tab_ctd(vr_contador).cdtransacao_pendente,0) || '</cdtransacao_pendente>' ||
                           '<cdcooper> ' ||
                           NVL(vr_tab_ctd(vr_contador).cdcooper,0) ||
                           '</cdcooper> ' );
                           
    gene0002.pc_escreve_xml(pr_xml => pr_clobxmlc
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo => '<nrdconta> ' || NVL(vr_tab_ctd(vr_contador).nrdconta,0) || '</nrdconta> ' ||
                          '<tpcontrato> ' || NVL(vr_tab_ctd(vr_contador).tpcontrato,0) || '</tpcontrato> ' ||
                          '<dscontrato> ' || NVL(vr_tab_ctd(vr_contador).dscontrato,' ') ||
                          '</dscontrato> ' );

    gene0002.pc_escreve_xml(pr_xml => pr_clobxmlc
                          ,pr_texto_completo => vr_xml_temp
                          ,pr_texto_novo => '<nrcontrato> ' || NVL(TO_CHAR(vr_tab_ctd(vr_contador).nrcontrato),' ') || '</nrcontrato> ' ||
                          '<vlcontrato> ' || NVL(vr_tab_ctd(vr_contador).vlcontrato,0) || '</vlcontrato> ' ||
                          '<cdoperad> ' ||   NVL(vr_tab_ctd(vr_contador).cdoperad,' ') || '</cdoperad> ' ||
                          '<cdrecid_crapcdc> ' || NVL(TO_CHAR(vr_tab_ctd(vr_contador).cdrecid_crapcdc),' ') || '</cdrecid_crapcdc> ' ||
                          '<dhcontrato> ' || to_char(vr_tab_ctd(vr_contador).dhcontrato,'DD/MM/RRRR') || '</dhcontrato> ' ||
                          '</registro>');
    END LOOP;
  END IF;

  -- Encerrar a tag raiz
  gene0002.pc_escreve_xml(pr_xml => pr_clobxmlc
                         ,pr_texto_completo => vr_xml_temp
                         ,pr_texto_novo => '</raiz>'
                         ,pr_fecha_xml => TRUE);

  EXCEPTION
  WHEN vr_exc_saida THEN
  pr_cdcritic:= NVL(vr_cdcritic,0);

  IF NVL(pr_cdcritic,0) > 0 THEN
     pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
  ELSE
     pr_dscritic:= vr_dscritic;
  END IF;

  WHEN OTHERS THEN
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na busca de aplicacoes INET0002.pc_ret_trans_pend_ctd_car: ' || SQLERRM;
  END;

END pc_ret_trans_pend_ctd_car;    
  
  PROCEDURE pc_ret_trans_pend_ctd(pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE       --> Nome da Tela
                                 ,pr_idorigem IN INTEGER                     --> Identificador de Origem
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2                    --> Codigo da Transacao
                                 ,pr_cdcritic OUT INTEGER                    --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                                 ,pr_tab_ctd OUT INET0002.typ_tab_ctd)       --> Tabela com os dados de tributos
  IS
  BEGIN
/* .............................................................................

    Programa: pc_ret_trans_pend_ctd
    Sistema : CRED
    Sigla : 
    Autor : Marcelo Telles Coelho - Mouts
    Data : Dezembro/2018. Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo : Rotina referente a busca de registros de transacao pendente de contratos.

    Observacao: -----

    Alteracoes: -----
.............................................................................. */
DECLARE

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION;

  -- Declaração da tabela que conterá os dados de Contratos
  vr_tab_ctd INET0002.typ_tab_ctd;
  vr_ind PLS_INTEGER := 0;

  -- Seleciona registro de trans. pend.
  CURSOR cr_tbctd_pend(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_cdtrapen IN VARCHAR2) IS
  SELECT cdtransacao_pendente,
         cdcooper,
         nrdconta,
         tpcontrato,
         dscontrato,
         nrcontrato,
         vlcontrato,
         dhcontrato,
         cdoperad,
         cdrecid_crapcdc
  FROM tbctd_trans_pend ctd
  WHERE (ctd.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
  AND (ctd.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
  AND (pr_cdtrapen IS NULL OR (ctd.cdtransacao_pendente IN (SELECT regexp_substr(pr_cdtrapen, '[^;]+', 1, ROWNUM) parametro
  FROM dual CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_cdtrapen ,'[^;]+','')) + 1)));

  rw_tbctd_pend cr_tbctd_pend%ROWTYPE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

BEGIN

  -- Listar reg. trans pend
  FOR rw_tbctd_pend IN cr_tbctd_pend(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_cdtrapen => pr_cdtrapen) 
  LOOP
  
    -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
    vr_ind := vr_tab_ctd.COUNT() + 1;
    vr_tab_ctd(vr_ind).cdtransacao_pendente := rw_tbctd_pend.cdtransacao_pendente;
    vr_tab_ctd(vr_ind).cdcooper := rw_tbctd_pend.cdcooper;
    vr_tab_ctd(vr_ind).nrdconta := rw_tbctd_pend.nrdconta;
    vr_tab_ctd(vr_ind).tpcontrato := rw_tbctd_pend.tpcontrato;
    vr_tab_ctd(vr_ind).dscontrato := rw_tbctd_pend.dscontrato;
    vr_tab_ctd(vr_ind).nrcontrato := rw_tbctd_pend.nrcontrato;
    vr_tab_ctd(vr_ind).dhcontrato := rw_tbctd_pend.dhcontrato;
    vr_tab_ctd(vr_ind).vlcontrato := rw_tbctd_pend.vlcontrato;
    vr_tab_ctd(vr_ind).cdoperad := rw_tbctd_pend.cdoperad;
    vr_tab_ctd(vr_ind).cdrecid_crapcdc := rw_tbctd_pend.cdrecid_crapcdc;
  
  END LOOP; -- FOR rw_tbctd_pend

  -- Alimenta parâmetro com a PL/Table gerada
  pr_tab_ctd := vr_tab_ctd;

  EXCEPTION
  WHEN vr_exc_saida THEN
  
    pr_cdcritic:= NVL(vr_cdcritic,0);

    IF NVL(pr_cdcritic,0) > 0 THEN
       pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    ELSE
       pr_dscritic:= vr_dscritic;
    END IF;

  WHEN OTHERS THEN
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := 'Erro nao tratado na INET0002.pc_ret_trans_pend_ctd: ' || SQLERRM;
  END;
END pc_ret_trans_pend_ctd;

PROCEDURE pc_cria_trans_pend_efet_prop(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                        ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                        ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                        ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                        ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                        ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                        ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                        ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                        ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                        ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                        ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                        ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                        ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                        ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                        ,pr_nrctremp  IN crawepr.nrctremp%TYPE                   --> numero do da proposta
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS               --> Descricao de Critica
    /* .............................................................................

     Programa: pc_cria_trans_pend_efet_prop
     Sistema : 
     Sigla   : CRED
     Autor   : Rafael R. Santos - AMcom
     Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a geração de registro de pendencia referente a proposta de emprestimo/financiamento

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/	


    --
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    --/
  BEGIN
    --/
    inet0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 21 --/ Emprestimos/financiamento
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;
    --/
    BEGIN
      --/
      INSERT INTO
        tbepr_trans_pend_efet_proposta
            (cdtransacao_pendente, 
             cdcooper, 
             nrdconta, 
             nrctremp)
        VALUES
            (vr_cdtranpe
            ,pr_cdcooper
            ,pr_nrdconta
            ,pr_nrctremp);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbepr_trans_pend_efet_proposta: ' || SQLERRM;
        RAISE vr_exec_saida;
    END;
    --/
    inet0002.pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_idseqttl => pr_idseqttl
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrcpfrep => pr_nrcpfrep
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdtiptra => 21 --/ Emprestimos/financiamento
                                     ,pr_tab_crapavt => vr_tab_crapavt
                                     ,pr_cdtranpe => vr_cdtranpe
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
    --/
    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := NVL(vr_cdcritic,0);
      
      IF NVL(pr_cdcritic,0) > 0 THEN
         pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      ELSE  
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_efet_prop: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_efet_prop;

  PROCEDURE pc_ret_trans_pend_prop( pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                            --> Identificador de Origem 
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                                   ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                                   ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                   ,pr_nrctremp OUT tbepr_trans_pend_efet_proposta.nrctremp%TYPE   --> Número da proposta da pendencia
                                   ,pr_vlemprst OUT crawepr.vlemprst%TYPE) IS                      --> Valor da proposta da pendencia            
  BEGIN
    /* .............................................................................

     Programa: pc_ret_trans_pend_prop
     Sistema : 
     Sigla   : CRED
     Autor   : Douglas Pagel - AMcom
     Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de transacao pendente de propostas.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/	
  
  DECLARE
                                       
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_saida EXCEPTION;  
      
       -- Seleciona registro de trans. pend.
	    CURSOR cr_tbtrans_prop(pr_cdcooper IN crapass.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_cdtrapen IN VARCHAR2) IS 
			  SELECT prop.nrctremp
				  FROM tbepr_trans_pend_efet_proposta prop
         WHERE (prop.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND (prop.nrdconta = pr_nrdconta OR pr_nrdconta = 0)
           AND (pr_cdtrapen IS NULL OR (prop.cdtransacao_pendente IN (SELECT regexp_substr(pr_cdtrapen, '[^;]+', 1, ROWNUM) parametro
               FROM dual CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_cdtrapen ,'[^;]+','')) + 1)));  
               
      CURSOR cr_crawepr(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE 
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT epr.vlemprst
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;                         
  
  BEGIN
      OPEN cr_tbtrans_prop(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdtrapen => pr_cdtrapen);
      FETCH cr_tbtrans_prop INTO pr_nrctremp; --parametro de interesse
                           
      --Se nao encontrou 
      IF cr_tbtrans_prop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_tbtrans_prop;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro da pendencia nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_saida;
      ELSE
        OPEN cr_crawepr (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crawepr INTO pr_vlemprst;
        
        IF cr_crawepr%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_crawepr;
           vr_cdcritic:= 0;
           vr_dscritic:= 'Registro da proposta nao encontrado.';
           --Levantar Excecao
           RAISE vr_exc_saida;
        END IF;
        
          
      END IF;
      --Fechar Cursor
      CLOSE cr_tbtrans_prop;
      CLOSE cr_crawepr;
      
  EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_cdcritic:= NVL(vr_cdcritic,0);

        IF NVL(pr_cdcritic,0) > 0 THEN
          pr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        ELSE
          pr_dscritic:= vr_dscritic;
        END IF;
        
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na INET0002.pc_ret_trans_pend_prop: ' || SQLERRM;
		END;    
    
  END pc_ret_trans_pend_prop;
END INET0002;
/
