CREATE OR REPLACE PACKAGE CECRED.WEBS0001 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0001
  --  Sistema  : Rotinas referentes ao WebService de Propostas
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Janeiro - 2016.                   Ultima atualizacao: 18/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de propostas
  --
  -- Alteracoes: 23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
  --                          referentes a proposta. (Lindon Carlos Pecile - GFT)
  --
  --             26/04/2018 - Adicionado os procedimentos pc_atualiza_prop_srv_border.
  --                        - Adaptado o procedimento pc_atuaretorn_proposta_esteira para utilizaçao do Borderô de
  --                          desconto de títulos (Andrew Albuquerque (GFT))
  --             05/05/2018 - Inclusão da procedure pc_retorno_analise_cartao (Paulo Silva (Supero))

  --             01/08/2018 - Incluir novo campo liquidOpCredAtraso no retorno do 		  
  --                          motor de credito e enviar para esteira - Diego Simas (AMcom)
  --
  --             18/09/2018 - Incluso novo parametro na pc_retorno_analise_aut e ajustado para ela gerenciar
  --  						  as chamadas das procedures de atualização de limite de desc titulo e emprestimo (Daniel)
  --     
  --             18/04/2019 - Incluido novo campo segueFluxoAtacado no retorno do motor de credito
  --                          P637 - Luciano Kienolt - Supero)
  ---------------------------------------------------------------------------
  PROCEDURE pc_atuaretorn_proposta_esteira(pr_usuario  IN VARCHAR2              --> Usuario
                                          ,pr_senha    IN VARCHAR2              --> Senha
                                          ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                          ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                          ,pr_insitapr IN crawepr.insitapr%TYPE --> Situacao da proposta
                                          ,pr_dsobscmt IN crawepr.dsobscmt%TYPE --> Observação recebida da esteira de crédito
                                          ,pr_dsdscore IN crapass.dsdscore%TYPE --> Consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_dtdscore IN VARCHAR2              --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_tpprodut IN NUMBER                --> Tipo de Servico
                                          ,pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                          ,pr_namehost IN VARCHAR2              --> Host acionado pela Esteira
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                          
  PROCEDURE pc_grava_requisicao_erro(pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                    ,pr_dsmessag IN VARCHAR2              --> Descricao da mensagem de erro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
             
	PROCEDURE pc_retorno_analise_proposta(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
																			 ,pr_dsprotoc IN VARCHAR2           --> Protocolo da análise
																			 ,pr_nrtransa IN NUMBER             --> Transacao do acionamento
																			 ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
																			 ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
																			 ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
																		 	 ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
																		 	 ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
																		 	 ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                       ,pr_inopeatr IN NUMBER                -->   
																			 ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
																			 ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
																			 ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
																			 ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
																			 ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
																			 ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                       ,pr_idfluata IN BOOLEAN DEFAULT FALSE  --> Indicador Segue Fluxo Atacado -- P637
																			 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
																			 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																			 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																			 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																			 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
	                             
  PROCEDURE pc_retorno_analise_limdesct(pr_cdorigem in number             --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                       ,pr_dsprotoc in varchar2           --> Protocolo da análise
                                       ,pr_nrtransa in number             --> Transacao do acionamento
                                       ,pr_dsresana in varchar2           --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                       ,pr_indrisco in varchar2           --> Nível do risco calculado para a operação
                                       ,pr_nrnotrat in varchar2           --> Valor do rating calculado para a operação
                                       ,pr_nrinfcad in varchar2           --> Valor do item Informações Cadastrais calculado no Rating
                                       ,pr_nrliquid in varchar2           --> Valor do item Liquidez calculado no Rating
                                       ,pr_nrgarope in varchar2           --> Valor das Garantias calculada no Rating
                                       ,pr_nrparlvr in varchar2           --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                       ,pr_nrperger in varchar2           --> Valor da Percepção Geral da Empresa calculada no Rating
                                       ,pr_desscore in varchar2           --> Descrição do Score Boa Vista
                                       ,pr_datscore in varchar2           --> Data do Score Boa Vista
                                       ,pr_dsrequis in varchar2           --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                                       ,pr_namehost in varchar2           --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                       ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado --P637                                                           
                                       ,pr_xmllog   in varchar2           --> XML com informações de LOG
                                       ,pr_cdcritic out pls_integer       --> Código da crítica
                                       ,pr_dscritic out varchar2          --> Descrição da crítica
                                       ,pr_retxml   in out nocopy xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo out varchar2          --> Nome do campo com erro
                                       ,pr_des_erro out varchar2          --> Erros do processo
                                       ); 

  PROCEDURE pc_retorno_analise_aut(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                  ,pr_dsprotoc IN VARCHAR2              --> Protocolo da análise
                                  ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                                  ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                  ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                                  ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                                  ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                                  ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                                  ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                  ,pr_inopeatr IN NUMBER                --> Contem o identificador da operacao de credito em atraso que vai para esteira
                                  ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                  ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                                  ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                                  ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                                  ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                                  ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                  ,pr_idfluata IN BOOLEAN DEFAULT FALSE              --> Indicador Segue Fluxo Atacado --P637                                                                                                         
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
-- Processa retorno da análise do cartão
  PROCEDURE pc_retorno_analise_cartao(pr_cdorigem IN NUMBER             --> Origem da Requisiçao (9-Esteira ou 5-Ayllos)
                                     ,pr_dsrequis IN VARCHAR2           --> Conteúdo da requisiçao oriunda da Análise Automática na Esteira
                                     ,pr_namehost IN VARCHAR2           --> Nome do host oriundo da requisiçao da Análise Automática na Esteira
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informaçoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descriçao da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2          --> Erros do processo
                                     );

  PROCEDURE pc_atualiza_prop_srv_emprestim(pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp    IN crawepr.nrctremp%TYPE     --> Numero do contrato
										                      ,pr_tpretest    IN VARCHAR2                  --> Tipo do retorno recebido ('M' - Motor/ 'E' - Esteira)
                                          ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_insitapr    IN crawepr.insitapr%TYPE     --> Situacao da proposta
                                          ,pr_dsobscmt    IN crawepr.dsobscmt%TYPE DEFAULT NULL    --> Observação recebida da esteira de crédito
                                          ,pr_dsdscore    IN crapass.dsdscore%TYPE DEFAULT NULL    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_dtdscore    IN crapass.dtdscore%TYPE DEFAULT NULL    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                    										  ,pr_indrisco    IN VARCHAR2 DEFAULT NULL     --> Nível do risco calculado para a operação
															  ,pr_inopeatr    IN crawepr.inliquid_operac_atraso%TYPE DEFAULT NULL --> Identificador da operacao de credito em atraso
										                      ,pr_nrnotrat    IN NUMBER   DEFAULT NULL     --> Valor do rating calculado para a operação
                     										  ,pr_nrinfcad    IN NUMBER   DEFAULT NULL     --> Valor do item Informações Cadastrais calculado no Rating
										                      ,pr_nrliquid    IN NUMBER   DEFAULT NULL     --> Valor do item Liquidez calculado no Rating
                     										  ,pr_nrgarope    IN NUMBER   DEFAULT NULL     --> Valor das Garantias calculada no Rating
										                      ,pr_nrparlvr    IN NUMBER   DEFAULT NULL     --> Valor do Patrimônio Pessoal Livre calculado no Rating
                     										  ,pr_nrperger    IN NUMBER   DEFAULT NULL     --> Valor da Percepção Geral da Empresa calculada no Rating
                                          ,pr_flgpreap    IN NUMBER   DEFAULT 0        --> Indicador de Pré-Aprovado
                                          ,pr_idfluata    IN BOOLEAN  DEFAULT FALSE    --> Indicador Segue Fluxo Atacado --P637
                                          ,pr_status      OUT PLS_INTEGER              --> Status
                                          ,pr_cdcritic    OUT PLS_INTEGER              --> Codigo da critica
                                          ,pr_dscritic    OUT VARCHAR2                 --> Descricao da critica
                                          ,pr_msg_detalhe OUT VARCHAR2                 --> Detalhe da mensagem
                                          ,pr_des_reto    OUT VARCHAR2);               --> Erros do processo

  procedure pc_atualiza_prop_srv_border
                (pr_cdcooper    in crapcop.cdcooper%type     --> Codigo da cooperativa
                ,pr_nrdconta    in crapass.nrdconta%type     --> Numero da conta
                ,pr_nrborder    IN crapbdt.nrborder%TYPE     --> Número do Borderô
                ,pr_rw_crapdat  in btch0001.rw_crapdat%type  --> Vetor com dados de parâmetro (CRAPDAT)
                ,pr_insitapr    in crapbdt.insitapr%type     --> Situacao da aprovação do bordero
                ,pr_dsobscmt    in long default null         --> Observaçao recebida da esteira de crédito
                ,pr_dsdscore    in crapass.dsdscore%type default null    --> Consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_dtdscore    in crapass.dtdscore%type default null    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_status      out pls_integer              --> Status
                ,pr_cdcritic    out pls_integer              --> Codigo da critica
                ,pr_dscritic    out varchar2                 --> Descricao da critica
                ,pr_msg_detalhe out varchar2                 --> Detalhe da mensagem
                ,pr_des_reto    out varchar2);

END WEBS0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WEBS0001 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0001
  --  Sistema  : Rotinas referentes ao WebService de propostas
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Janeiro - 2016.                   Ultima atualizacao: 28/06/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de propostas
  --
  -- Alteracoes: 05/05/2017 - Package adaptada para prever o retorno do Motor
	--                          de crédito - Projeto 337 - Motor de Crédito. (Reinert)
  --
  --             27/02/2018 - Adicionado os procedimentos pc_atualiza_prop_srv_limdesct e pc_retorno_analise_limdesct
  --                        - Adaptado o procedimento pc_atuaretorn_proposta_esteira para utilização do limite de
  --                          desconto de títulos (Paulo Penteado (GFT))
  --
  --             23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
  --                          referentes a proposta. (Lindon Carlos Pecile - GFT)
  --
  --             26/04/2018 - Adicionado os procedimentos pc_atualiza_prop_srv_border.
  --                        - Adaptado o procedimento pc_atuaretorn_proposta_esteira para utilizaçao do Borderô de
  --                          desconto de títulos (Andrew Albuquerque (GFT))
  --             05/05/2018 - pc_retorno_analise_cartao (Paulo Silva (Supero))
  --
  --	 	         01/08/2018 - Incluir novo campo liquidOpCredAtraso no retorno do 
  --                          motor de credito e enviar para esteira - Diego Simas (AMcom)				
  --
  --             14/05/2019 - Adicionado a pc_notifica_ib e suas chamadas ( AmCom - p438 )
  --
  --             28/06/2019 - Incluir dtcancel e retirar a titularidade quando proposta
  --                          rejeitada na esteira (Lucas Ranghetti PRB0041968)
  --
  --             16/07/2019 - Movido a rotina pc_notifica_ib para a este0001.pc_notificacoes_prop
  --
  ---------------------------------------------------------------------------  
  --

  PROCEDURE pc_gera_retor_proposta_esteira(pr_status       IN PLS_INTEGER,           --> Status
                                           pr_nrtransacao  IN NUMBER,                --> Numero da transacao
                                           pr_cdcritic     IN PLS_INTEGER,           --> Codigo da critica
                                           pr_dscritic     IN VARCHAR2 DEFAULT NULL, --> Descricao da critica
                                           pr_msg_detalhe  IN VARCHAR2,              --> Detalhe da mensagem
                                           pr_dtmvtolt     IN DATE,                  --> Data do movimento
                                           pr_retxml       OUT NOCOPY XMLType) IS    --> Arquivo de retorno do XML
  BEGIN                                        
    /* .............................................................................
     Programa: pc_gera_retor_proposta_esteira
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : James Prust Junior
     Data    : Janeiro/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gerar retorno para a proposta de esteira

     Observacao: -----
     Alteracoes:
     ..............................................................................*/                                    
    DECLARE
      -- Tratamento de erros
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(10000);
    BEGIN
      
      vr_dscritic := pr_dscritic;        
      -- Caso somente foi passado como parametro o codigo da critica, vamos buscar a descricao da critica
      IF pr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;    
    
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => pr_status, pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(pr_nrtransacao,20,'0'), pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(pr_cdcritic,0), pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => pr_msg_detalhe, pr_des_erro => vr_des_erro);
      
      BEGIN
        UPDATE tbgen_webservice_aciona a
           SET a.cdstatus_http = pr_status,
               a.dsresposta_requisicao = pr_retxml.getClobVal(),
               a.dtmvtolt              = pr_dtmvtolt
         WHERE a.idacionamento = pr_nrtransacao;
      EXCEPTION 
        WHEN OTHERS THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - WEBS0001 --> Nao foi possivel atualizar acionamento ' || pr_nrtransacao ||': '||SQLERRM,
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
      
      END;
    END;
  
  END pc_gera_retor_proposta_esteira;
  
  PROCEDURE pc_atualiza_propost_portabilid(pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp    IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                          ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_insitapr    IN crawepr.insitapr%TYPE     --> Situacao da proposta
                                          ,pr_cdcritic    OUT PLS_INTEGER              --> Codigo da critica
                                          ,pr_dscritic    OUT VARCHAR2                 --> Descricao da critica                                          
                                          ,pr_des_reto    OUT VARCHAR2) IS             --> Erros do processo
  BEGIN                                         
    /* .............................................................................
     Programa: pc_atualiza_propost_portabilid
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : 
     Data    : Janeiro/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Atualizar os dados da proposta de Portabilidade

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor para buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT nrdocnpj
              ,dsendcop
              ,nrendcop
              ,nmcidade
              ,cdufdcop
              ,nrcepend
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor para buscar os dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrcpfcgc,
               crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor para buscar os dados da proposta
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE,
                        pr_nrdconta IN crawepr.nrdconta%TYPE,
                        pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crawepr.vlemprst,
               crawepr.txmensal,
               crawepr.cdlcremp,
               crawepr.txdiaria,
               crawepr.percetop,
               crawepr.vlpreemp,
               crawepr.qtpreemp,
               crawepr.tpemprst,
               crawepr.cddindex
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      -- Cursor para buscar os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE,
                        pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.cdmodali,
               craplcr.cdsubmod
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      -- Cursor para buscar os dados do telefone
      CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%TYPE,
                        pr_nrdconta IN craptfc.nrdconta%TYPE) IS
        SELECT craptfc.nrdddtfc,
               craptfc.nrtelefo
          FROM craptfc
         WHERE craptfc.cdcooper = pr_cdcooper
           AND craptfc.nrdconta = pr_nrdconta
      ORDER BY craptfc.tptelefo;
      rw_craptfc cr_craptfc%ROWTYPE;
      
      -- Cursor para buscar a primeira parcela e a ultima parcla
      CURSOR cr_crappep_max_min(pr_cdcooper IN crappep.cdcooper%TYPE,
                                pr_nrdconta IN crappep.nrdconta%TYPE,
                                pr_nrctremp IN crappep.nrctremp%TYPE) IS
			  SELECT MAX(crappep.dtvencto) max_dtvencto,
               MIN(crappep.dtvencto) min_dtvencto
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp;
      rw_crappep_max_min cr_crappep_max_min%ROWTYPE;
      
      -- Cursor para buscar os dados do banco
      CURSOR cr_crapban IS
        SELECT nrispbif
          FROM crapban
         WHERE crapban.cdbccxlt = 85;
      rw_crapban cr_crapban%ROWTYPE;
      
      -- Cursor para buscar os dados da portabilidade
      CURSOR cr_tbepr_portabilidade(pr_cdcooper IN tbepr_portabilidade.cdcooper%TYPE,
                                    pr_nrdconta IN tbepr_portabilidade.nrdconta%TYPE,
                                    pr_nrctremp IN tbepr_portabilidade.nrctremp%TYPE) IS
        SELECT dtaprov_portabilidade
              ,nrcnpjbase_if_origem
              ,nrcontrato_if_origem              
              ,nrunico_portabilidade              
          FROM tbepr_portabilidade
         WHERE tbepr_portabilidade.cdcooper = pr_cdcooper
           AND tbepr_portabilidade.nrdconta = pr_nrdconta
           AND tbepr_portabilidade.nrctremp = pr_nrctremp;         
      rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;
      
      -- Temp-Table
      vr_tab_portabilidade      EMPR0006.typ_reg_retorno_xml;
      
      -- Variaveis tratamento de erros
      vr_cdcritic               crapcri.cdcritic%TYPE;
      vr_dscritic               crapcri.dscritic%TYPE;
      vr_exc_saida              EXCEPTION;
      
      -- Variaveis procedure
      vr_dtprvcto               crappep.dtvencto%TYPE;
      vr_dtulvcto               crappep.dtvencto%TYPE;
      vr_txjuranu               crawepr.txmensal%TYPE;
      vr_indRemun               VARCHAR2(2); -- IndRemun (06 - TR, 08 -	CDI)
      vr_txjurnom               VARCHAR2(100);
      vr_txjurefp               VARCHAR2(100);
      vr_vlrtxcet               VARCHAR2(100);
      vr_vlpreemp               VARCHAR2(100);
      vr_txjureft               NUMBER(25,2);
      vr_idsolici               PLS_INTEGER;
      vr_inparadm               NUMBER(25);
      vr_cnpjifcr               NUMBER(25);
      vr_flgrespo               NUMBER(25);
      vr_nrtelefo               VARCHAR2(15);
      vr_des_erro               VARCHAR2(3);
      vr_cdmodali_portabilidade VARCHAR2(50);
      vr_tpdetaxa               VARCHAR2(2) := 01; --(01 -- PRICE FIX, 02 -- POS FIX)
    BEGIN
      vr_nrtelefo := ' ';      
    
      -- Buscar os dados da proposta de emprestimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_cdcritic := 356;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crawepr;
      END IF;
      
      -- Buscar os dados da linha de credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                      pr_cdlcremp => rw_crawepr.cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craplcr;
      END IF;
      
      -- Buscar os dados do Banco
      OPEN cr_crapban;
      FETCH cr_crapban
       INTO rw_crapban;
      -- Condicao para verificar se o banco existe
      IF cr_crapban%NOTFOUND THEN
        CLOSE cr_crapban;
        vr_cdcritic := 57;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapban;
      END IF;
      
      -- Buscar os dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Condicao para verificar se o banco existe
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;
      
      -- Buscar os dados da proposta de portabilidade
      OPEN cr_tbepr_portabilidade(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_nrctremp => pr_nrctremp);
      FETCH cr_tbepr_portabilidade
       INTO rw_tbepr_portabilidade;
      -- Condicao para verificar se o contrato estah na tabela de portabilidade
      IF cr_tbepr_portabilidade%NOTFOUND THEN
        CLOSE cr_tbepr_portabilidade;
        vr_cdcritic := 0;
        vr_dscritic := 'Operacao de portabilidade nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_tbepr_portabilidade;
      END IF;
      
      -- Buscar os dados do associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      -- Identificador Participante Administrado
      vr_inparadm := SUBSTR(gene0002.fn_mask(rw_crapcop.nrdocnpj,'99999999999999'),1,8);
      -- CNPJ Base IF Credora Original Contrato
      vr_cnpjifcr := SUBSTR(gene0002.fn_mask(rw_tbepr_portabilidade.nrcnpjbase_if_origem,'99999999999999'),1,8); 
      /* Se campo o tbepr_portabilidade.nrunico_portabilidade estiver alimentado,
         a proposta de portabilidade já existe na JDCTC e precisa ser cancelada 
         para a inclusao de outra proposta */
      IF rw_tbepr_portabilidade.dtaprov_portabilidade IS NOT NULL AND pr_insitapr = 2 THEN
        -- Código da modalidade da portabilidade
        vr_cdmodali_portabilidade := rw_craplcr.cdmodali || rw_craplcr.cdsubmod;      
        -- Consulta situacao da portabilidade no JDCTC
        EMPR0006.pc_consulta_situacao(pr_cdcooper => pr_cdcooper
                                     ,pr_idservic => 1 -- Proponente
                                     ,pr_cdlegado => 'LEG'
                                     ,pr_nrispbif => rw_crapban.nrispbif
                                     ,pr_idparadm => rw_crapcop.nrdocnpj
                                     ,pr_ispbifcr => SUBSTR(LPAD(rw_tbepr_portabilidade.nrcnpjbase_if_origem,14,0),1,8)
                                     ,pr_nrunipor => rw_tbepr_portabilidade.nrunico_portabilidade
                                     ,pr_cdconori => rw_tbepr_portabilidade.nrcontrato_if_origem
                                     ,pr_tpcontra => vr_cdmodali_portabilidade
                                     ,pr_tpclient => 'F'
                                     ,pr_cnpjcpf  => rw_crapass.nrcpfcgc
                                     ,pr_tab_portabilidade => vr_tab_portabilidade
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL OR vr_des_erro <> 'OK' THEN
          -- Condicao para verificar se retornou alguma critica
          IF vr_dscritic IS NULL THEN
            vr_dscritic := 'Nao foi possivel consultar a situacao da portabilidade no sistema JDCTC.';            
          END IF;
          RAISE vr_exc_saida;
        END IF;        
        
        -- Se portabilidade ainda nao foi cancelada no JDCTC
        IF vr_tab_portabilidade.stportabilidade NOT IN ('PS7,PX7,RX9,SXA,SXB,SX7,SX9,SI3,SR6,SR7,SI8') THEN
          -- Chama metodo de cancelamento no JDCTC
          EMPR0006.pc_cancelar_portabilidade(pr_cdcooper => pr_cdcooper
                                            ,pr_idservic => 1                    -- Tipo de servico(1-Proponente/2-Credora)
                                            ,pr_cdlegado => 'LEG'                -- Codigo Legado
                                            ,pr_nrispbif => rw_crapban.nrispbif  -- Nr. ISPB IF
                                            ,pr_inparadm => vr_inparadm          -- Identificador Participante Administrado
                                            ,pr_cnpjifcr => vr_cnpjifcr          -- CNPJ Base IF Credora Original Contrato
                                            ,pr_nuportld => vr_tab_portabilidade.nuportlddctc -- Número único da portabilidade na CTC
                                            ,pr_mtvcance => '002'                -- Motivo do cancelamento
                                            ,pr_flgrespo => vr_flgrespo          -- 1 - Se o registro na JDCTC for atualizado com sucesso
                                            ,pr_des_erro => vr_des_erro          -- Indicador erro OK/NOK
                                            ,pr_dscritic => vr_dscritic);        -- Descricao do erro
                                             
          IF vr_des_erro <> 'OK' OR vr_flgrespo <> 1 THEN
            IF vr_dscritic IS NULL THEN
              vr_dscritic := 'Nao foi possivel efetuar o cancelamento da portabilidade no sistema JDCTC.';
            END IF;
            RAISE vr_exc_saida;
          END IF;
          
        END IF;
        
        /* Quando cancelada a portabilidade devemos zerar os campos de nr de portabilidade e 
           data de aprovacao para que o contrato possa ser aprovado novamente */
        BEGIN
          UPDATE tbepr_portabilidade
             SET tbepr_portabilidade.nrunico_portabilidade = NULL
                ,tbepr_portabilidade.dtaprov_portabilidade = NULL
           WHERE tbepr_portabilidade.cdcooper = pr_cdcooper
             AND tbepr_portabilidade.nrdconta = pr_nrdconta
             AND tbepr_portabilidade.nrctremp = pr_nrctremp
          RETURNING nrunico_portabilidade
                   ,dtaprov_portabilidade
               INTO rw_tbepr_portabilidade.nrunico_portabilidade
                   ,rw_tbepr_portabilidade.dtaprov_portabilidade;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar portabilidade. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;        
      END IF;
      
      -- Buscar os dados do telefone
      OPEN cr_craptfc(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_craptfc
       INTO rw_craptfc;
      IF cr_craptfc%FOUND THEN
        CLOSE cr_craptfc;        
        -- Formatar o numero do telefone
        vr_nrtelefo := gene0002.fn_mask(rw_craptfc.nrdddtfc,'z99') || gene0002.fn_mask(rw_craptfc.nrtelefo,'zz99999999');        
      ELSE
        CLOSE cr_craptfc;        
      END IF;
      
      -- Buscar os dados da parcela do emprestimo
      OPEN cr_crappep_max_min(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_max_min
       INTO rw_crappep_max_min;
      IF cr_crappep_max_min%FOUND THEN
        CLOSE cr_crappep_max_min;
        
        vr_dtprvcto := rw_crappep_max_min.min_dtvencto;
        vr_dtulvcto := rw_crappep_max_min.max_dtvencto;
      ELSE
        CLOSE cr_crappep_max_min;
      END IF;

      -- Procedure para calcular a taxa de juros
      CCET0001.pc_calc_taxa_juros(pr_cdcooper => pr_cdcooper            -- Cooperativa
                                 ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt -- Data Movimento
                                 ,pr_tpdjuros => 0                      -- Tipo do juros
                                 ,pr_vllanmto => rw_crawepr.vlemprst    -- Valor a calcular
                                 ,pr_txmensal => rw_crawepr.txmensal    -- Taxa Juros
                                 ,pr_cddlinha => 0                      -- Codigo Linha credito
                                 ,pr_tpctrlim => 0                      -- Tipo de Limite
                                 ,pr_vlrjuros => vr_txjureft            -- Valor Juros
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
                                 
      
      IF rw_crawepr.tpemprst = 2 THEN
        -- POS já grava o valor correto, por isso nao precisa dividir /100
        vr_txjuranu := TRUNC((POWER(1 + (rw_crawepr.txdiaria), 360) - 1) * 100, 5);
        vr_indRemun := (CASE WHEN rw_crawepr.cddindex = 1 THEN '08' ELSE '06' END); -- IndRemun (06 - TR, 08 -	CDI)
      ELSE
        vr_txjuranu := TRUNC((POWER(1 + (rw_crawepr.txdiaria / 100), 360) - 1) * 100, 5);
      END IF;

      vr_txjurnom := REPLACE(TO_CHAR(TRUNC(((POWER(1 + (vr_txjuranu / 100), 1/12) - 1) * 12) * 100, 5)),',','.');
      
      vr_txjurefp := REPLACE(TRIM(TO_CHAR(vr_txjureft,'99999999990D00')),',','.');
      vr_vlrtxcet := REPLACE(TRIM(TO_CHAR(rw_crawepr.percetop,'99999999990D00000')),',','.');
      vr_vlpreemp := REPLACE(TRIM(TO_CHAR(rw_crawepr.vlpreemp,'9999999999990D00')),',','.');
      vr_tpdetaxa := (CASE WHEN rw_crawepr.tpemprst = 2 THEN '02' ELSE '01' END);
      
      /* IncluirVeicular */
      IF (rw_craplcr.cdmodali || rw_craplcr.cdsubmod) = '0401' AND pr_insitapr IN (1,3) AND rw_tbepr_portabilidade.dtaprov_portabilidade IS NULL  THEN
        -- Incluir os dados
        EMPR0006.pc_incluir_veicular(pr_cdcooper => pr_cdcooper,
                                     pr_idservic => 1, 
                                     pr_cdlegado => 'LEG', 
                                     pr_nrispbif => gene0002.fn_mask(rw_crapban.nrispbif,'99999999'),
                                     pr_inparadm => vr_inparadm, 
                                     pr_cdcntori => TO_CHAR(rw_tbepr_portabilidade.nrcontrato_if_origem),
                                     pr_tpcontrt => '0401',
                                     pr_cnpjifcr => vr_cnpjifcr,
                                     pr_dtrefsld => pr_rw_crapdat.dtmvtolt,
                                     pr_vlslddev => TO_CHAR(rw_crawepr.vlemprst),
                                     pr_cnpjcpfc => TO_CHAR(rw_crapass.nrcpfcgc),
                                     pr_nmclient => rw_crapass.nmprimtl,
                                     pr_nrtelcli => vr_nrtelefo,
                                     pr_tpdetaxa => vr_tpdetaxa,
                                     pr_txjurnom => vr_txjurnom,
                                     pr_txjureft => vr_txjurefp,
                                     pr_txcet    => vr_vlrtxcet,
                                     pr_cddmoeda => '09', 
                                     pr_regamrtz => '01', 
                                     pr_dtcontop => pr_rw_crapdat.dtmvtolt, 
                                     pr_qtdtotpr => TO_CHAR(rw_crawepr.qtpreemp),
                                     pr_flxpagto => 'N', 
                                     pr_vlparemp => vr_vlpreemp,
                                     pr_dtpripar => vr_dtprvcto, 
                                     pr_dtultpar => vr_dtulvcto,
                                     pr_dsendcar => rw_crapcop.dsendcop,
                                     pr_nrentere => TO_CHAR(rw_crapcop.nrendcop),
                                     pr_cidadend => rw_crapcop.nmcidade,
                                     pr_ufendere => rw_crapcop.cdufdcop,
                                     pr_cepender => TO_CHAR(rw_crapcop.nrcepend), 
                                     pr_idsolici => vr_idsolici,
                                     pr_indRemun => vr_indRemun,
                                     pr_des_erro => vr_des_erro, 
                                     pr_dscritic => vr_dscritic);
                                     
        -- Condicao para verificar se ocorreu erro                             
        IF vr_idsolici = 0 OR vr_des_erro <> 'OK' OR vr_dscritic IS NOT NULL THEN
          IF vr_dscritic IS NULL THEN
            vr_dscritic := 'Nao foi possivel incluir a proposta no sistema JDCTC.';
          END IF;
          RAISE vr_exc_saida;
        END IF;
        
        BEGIN
          UPDATE tbepr_portabilidade
             SET tbepr_portabilidade.dtaprov_portabilidade = pr_rw_crapdat.dtmvtolt
           WHERE tbepr_portabilidade.cdcooper = pr_cdcooper
             AND tbepr_portabilidade.nrdconta = pr_nrdconta
             AND tbepr_portabilidade.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar portabilidade. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      ELSIF (rw_craplcr.cdmodali || rw_craplcr.cdsubmod) = '0203' AND pr_insitapr IN (1,3) AND rw_tbepr_portabilidade.dtaprov_portabilidade IS NULL THEN        
        -- Incluir os dados
        EMPR0006.pc_incluir_pessoal(pr_cdcooper => pr_cdcooper, 
                                    pr_idservic => 1,
                                    pr_cdlegado => 'LEG',
                                    pr_nrispbif => gene0002.fn_mask(rw_crapban.nrispbif,'99999999'),
                                    pr_inparadm => vr_inparadm,
                                    pr_cdcntori => TO_CHAR(rw_tbepr_portabilidade.nrcontrato_if_origem),
                                    pr_tpcontrt => '0203', 
                                    pr_cnpjifcr => vr_cnpjifcr,
                                    pr_dtrefsld => pr_rw_crapdat.dtmvtolt,
                                    pr_vlslddev => TO_CHAR(rw_crawepr.vlemprst),
                                    pr_cnpjcpfc => TO_CHAR(rw_crapass.nrcpfcgc),
                                    pr_nmclient => rw_crapass.nmprimtl, 
                                    pr_nrtelcli => vr_nrtelefo,
                                    pr_tpdetaxa => vr_tpdetaxa,
                                    pr_txjurnom => vr_txjurnom,
                                    pr_txjureft => vr_txjurefp,
                                    pr_txcet    => vr_vlrtxcet,
                                    pr_cddmoeda => '09', 
                                    pr_regamrtz => '01', 
                                    pr_dtcontop => pr_rw_crapdat.dtmvtolt,
                                    pr_qtdtotpr => TO_CHAR(rw_crawepr.qtpreemp),
                                    pr_flxpagto => 'N',
                                    pr_vlparemp => vr_vlpreemp,
                                    pr_dtpripar => vr_dtprvcto,
                                    pr_dtultpar => vr_dtulvcto,
                                    pr_dsendcar => rw_crapcop.dsendcop,
                                    pr_dscmpend => ' ', 
                                    pr_nrentere => TO_CHAR(rw_crapcop.nrendcop), 
                                    pr_cidadend => rw_crapcop.nmcidade, 
                                    pr_ufendere => rw_crapcop.cdufdcop, 
                                    pr_cepender => TO_CHAR(rw_crapcop.nrcepend), 
                                    pr_idsolici => vr_idsolici, 
                                    pr_indRemun => vr_indRemun,
                                    pr_des_erro => vr_des_erro,
                                    pr_dscritic => vr_dscritic);
                            
        IF vr_idsolici = 0 OR vr_des_erro <> 'OK' OR vr_dscritic IS NOT NULL THEN
          IF vr_dscritic IS NULL THEN
            vr_dscritic := 'Nao foi possivel incluir a proposta no sistema JDCTC.';
          END IF;
          RAISE vr_exc_saida; 
        END IF;
        
        BEGIN
          UPDATE tbepr_portabilidade
             SET tbepr_portabilidade.dtaprov_portabilidade = pr_rw_crapdat.dtmvtolt
           WHERE tbepr_portabilidade.cdcooper = pr_cdcooper
             AND tbepr_portabilidade.nrdconta = pr_nrdconta
             AND tbepr_portabilidade.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar portabilidade. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END IF;
      
      pr_des_reto := 'OK';                            
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_reto := 'NOK';
        pr_cdcritic := vr_cdcritic;
        
        IF pr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				ELSE 
          pr_dscritic := vr_dscritic;
				END IF;
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na WEBS0001.pc_atualiza_propost_portabilid ' || sqlerrm;
    END;
    
  END pc_atualiza_propost_portabilid;   
  
  PROCEDURE pc_atualiza_prop_srv_emprestim(pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp    IN crawepr.nrctremp%TYPE     --> Numero do contrato
																					,pr_tpretest    IN VARCHAR2                  --> Tipo do retorno recebido ('M' - Motor/ 'E' - Esteira)
                                          ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_insitapr    IN crawepr.insitapr%TYPE     --> Situacao da proposta
                                          ,pr_dsobscmt    IN crawepr.dsobscmt%TYPE DEFAULT NULL    --> Observação recebida da esteira de crédito
                                          ,pr_dsdscore    IN crapass.dsdscore%TYPE DEFAULT NULL    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_dtdscore    IN crapass.dtdscore%TYPE DEFAULT NULL    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
																					,pr_indrisco    IN VARCHAR2 DEFAULT NULL     --> Nível do risco calculado para a operação
                                          ,pr_inopeatr    IN crawepr.inliquid_operac_atraso%TYPE DEFAULT NULL --> Identificador da operacao de credito em atraso
																					,pr_nrnotrat    IN NUMBER   DEFAULT NULL     --> Valor do rating calculado para a operação
																					,pr_nrinfcad    IN NUMBER   DEFAULT NULL     --> Valor do item Informações Cadastrais calculado no Rating
																					,pr_nrliquid    IN NUMBER   DEFAULT NULL     --> Valor do item Liquidez calculado no Rating
																					,pr_nrgarope    IN NUMBER   DEFAULT NULL     --> Valor das Garantias calculada no Rating
																					,pr_nrparlvr    IN NUMBER   DEFAULT NULL     --> Valor do Patrimônio Pessoal Livre calculado no Rating
																					,pr_nrperger    IN NUMBER   DEFAULT NULL     --> Valor da Percepção Geral da Empresa calculada no Rating
                                          ,pr_flgpreap    IN NUMBER   DEFAULT 0        --> Indicador de Pré-Aprovado
                                          ,pr_idfluata    IN BOOLEAN  DEFAULT FALSE    --> Indicador Segue Fluxo Atacado --P637
                                          ,pr_status      OUT PLS_INTEGER              --> Status
                                          ,pr_cdcritic    OUT PLS_INTEGER              --> Codigo da critica
                                          ,pr_dscritic    OUT VARCHAR2                 --> Descricao da critica
                                          ,pr_msg_detalhe OUT VARCHAR2                 --> Detalhe da mensagem
                                          ,pr_des_reto    OUT VARCHAR2) IS             --> Erros do processo
  BEGIN                                         
    /* .............................................................................
     Programa: pc_atualiza_prop_srv_emprestim
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : James Prust Junior
     Data    : Janeiro/16.                    Ultima atualizacao: 01/08/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Atualizar os dados da proposta de Emprestimo/Financiamento

     Observacao: -----
     Alteracoes: 22/03/2016 - Incluido tratamento para pr_insitapr = 99,
                              alterar proposta para expirada.
                              PRJ207 - Esteira (Odirlei-AMcom)
                              
                 30/05/2016 - Ajustado critica portabilidade.
                              PRJ207 - Esteira (Odirlei-AMcom)
                              
                 16/06/2016 - Ajustes para não estourar variavel dsobscmt.             
                              PRJ207 - Esteira (Odirlei-AMcom)

                 21/01/2018 - Chamado 732952 - Melhorar a mensagem para ficar
				              mais claro a Ibratan quando a proposta esta em 
							  situacao que nao permite atualizacao (Andrei-MOUTs)

			     01/08/2018 - Incluir novo campo liquidOpCredAtraso na esteira
                              Diego Simas (AMcom) 

                 21/11/2017 - Inclusão do parametro pr_flgpreap, Prj. 402 (Jean Michel)   
				 
				 26/09/2018 - Incluso coalesce ao atualizar crawpepr campo  dsratori  
				              Alcemir Mout's - INC0023901.
                 08/03/2019 - P637 – Motor de Crédito - Criar um atributo de retorno após 
                              a execução do motor que irá identificar que essa proposta 
                              pertence ao “seguefluxoatacado”, quando essa proposta for 
                              enviada para a esteira de crédito, esse atributo deverá ser 
                              enviado para que a Ibratan identifique que essa proposta 
                              seguirá para um fluxo especifico. (Luciano Kienolt - Supero)

         07/05/2019 - Incluso chamadas rotina empr0017.pc_cria_notificacao (AmCom)
     ..............................................................................*/
    DECLARE
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crawepr.insitest
              ,crawepr.dtaltpro
              ,crawepr.insitapr
              ,crawepr.cdopeapr
              ,crawepr.dtaprova
              ,crawepr.hraprova
              ,crawepr.dsobscmt
              ,crawepr.cdcomite
              ,crawepr.cdfinemp
              ,crawepr.dtenvest
							,crawepr.dsnivris
							,crawepr.idfluata
              ,crawepr.cdorigem
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
      rw_crawepr     cr_crawepr%ROWTYPE;
      rw_crawepr_log cr_crawepr%ROWTYPE;
      
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.dtdscore
              ,crapass.dsdscore
							,crapass.dsnivris
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass     cr_crapass%ROWTYPE;
      rw_crapass_log cr_crapass%ROWTYPE;
      
      CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                       ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT crapfin.tpfinali
          FROM crapfin
         WHERE crapfin.cdcooper = pr_cdcooper
           AND crapfin.cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
      
      -- Busca dos dados do contrato
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                         pr_nrdconta IN crapepr.nrdconta%TYPE,
                         pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      vr_flgexepr PLS_INTEGER := 0;
      
      CURSOR cr_empr_cdc (pr_cdcooper IN tbepr_cdc_emprestimo.cdcooper%TYPE
                         ,pr_nrdconta IN tbepr_cdc_emprestimo.nrdconta%TYPE
                         ,pr_nrctremp IN tbepr_cdc_emprestimo.nrctremp%TYPE) IS
        SELECT rowid
          FROM tbepr_cdc_emprestimo e
         WHERE e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.nrctremp = pr_nrctremp;
      rw_empr_cdc cr_empr_cdc%rowtype;
      
      vr_nrdrowid      ROWID;
      vr_exc_saida     EXCEPTION;
      vr_exc_erro_500  EXCEPTION;
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic crapcri.dscritic%type;
      vr_insitpro NUMBER(2);
      vr_idfluata NUMBER(1);

      /*M438*/
            --PL tables
      vr_tab_rating_sing      RATI0001.typ_tab_crapras;
      vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
      vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
      vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;      
      vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
      vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
      vr_tab_ratings          RATI0001.typ_tab_ratings;
      vr_tab_crapras          RATI0001.typ_tab_crapras;
      vr_tab_erro             GENE0001.typ_tab_erro;
      vr_ind                  PLS_INTEGER; --> Indice da tabela de retorno  
      vr_rating               VARCHAR2(2) := NULL;
      vr_flgcriar             NUMBER;
      vr_des_reto             VARCHAR2(100);
      /*Fim 438*/
      
    BEGIN
      --Limpar tabela erro      
      vr_tab_erro.DELETE;      
      -- Buscar os dados da proposta de emprestimo
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      -- Condicao para verificar se a proposta existe
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        pr_status      := 202;
        pr_cdcritic    := 535;
        pr_msg_detalhe := 'Parecer nao foi atualizado, a proposta nao foi encontrada no sistema Aimaro.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crawepr;      
      END IF;
      
      -- Buscar os dados do cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      -- Condicao para verificar se a proposta existe
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        pr_status      := 202;
        pr_cdcritic    := 564;
        pr_msg_detalhe := 'Parecer nao foi atualizado, a conta-corrente nao foi encontrada no sistema Aimaro.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      --> Tratar para nao validar criticas qnt for 99-expirado
      IF pr_insitapr <> 99 THEN

        OPEN cr_empr_cdc(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        FETCH cr_empr_cdc INTO rw_empr_cdc;
          
        -- se for CDC novo deve ser verificado tbm a aprovacao da esteira
        IF cr_empr_cdc%FOUND THEN
          CLOSE cr_empr_cdc;
          -- se tiver sido finalizada a analise e nao for aprovacao deve recusar
          IF rw_crawepr.insitest = 3 and pr_insitapr != 1 THEN
            -- Montar mensagem de critica
            pr_status      := 202;
            pr_cdcritic    := 974;
            pr_msg_detalhe := 'Parecer nao foi atualizado, a analise da proposta ja foi finalizada.';
            RAISE vr_exc_saida;        
          END IF;		
        ELSE
          CLOSE cr_empr_cdc;
          -- Proposta Finalizada
          IF rw_crawepr.insitest = 3 THEN
            pr_status      := 202;
            pr_cdcritic    := 974;
            pr_msg_detalhe := 'Parecer nao foi atualizado, a analise da proposta ja foi finalizada.';
            RAISE vr_exc_saida;
          END IF;
          
          -- 1 – Enviada para Analise, 2 – Reenviado para Analise
          IF rw_crawepr.insitest NOT IN (1,2) THEN
            pr_status      := 202;
            pr_cdcritic    := 971;
            pr_msg_detalhe := 'Parecer nao foi atualizado, proposta em situacao que nao permite esta operacao.';
            RAISE vr_exc_saida;
          END IF;
        END IF;        
      END IF; --> Fim IF pr_insitapr <> 99 THEN
      
      -- Proposta Expirado
      IF rw_crawepr.insitest = 4 THEN
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer nao foi atualizado, o prazo para analise da proposta exipirou.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Início PJ 438 - Márcio (Mouts)
      -- Proposta Expirada por decurso de prazo
      IF rw_crawepr.insitest = 5 THEN
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer nao foi atualizado, proposta exipirou por decurso de prazo.';
        RAISE vr_exc_saida;
      END IF;
      -- Fim PJ 438 - Márcio (Mouts)
      
      -- Início PJ 438 - Paulo Martins (Mouts)
      -- Proposta Anulada
      IF rw_crawepr.insitest = 6 THEN
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer nao foi atualizado, proposta esta anulada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fim PJ 438 - Paulo Martins (Mouts)      
      
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
       INTO vr_flgexepr;
      CLOSE cr_crapepr;       
      -- Condicao para verificar se a proposta jah foi efetivado
      IF NVL(vr_flgexepr,0) = 1 THEN
        pr_status      := 202;
        pr_cdcritic    := 970;
        pr_msg_detalhe := 'Parecer da proposta nao foi atualizado, a proposta ja esta efetivada no sistema Aimaro.';
        RAISE vr_exc_saida;
      END IF;
      
      rw_crawepr_log := rw_crawepr;
			
      /* Caso o retorno seja oriundo da política de Crédito */      
			IF pr_tpretest = 'M' THEN
				BEGIN
					/* Atualizar as perguntas do Rating */      
					UPDATE crapprp prp
						 SET prp.nrinfcad = NVL(pr_nrinfcad,prp.nrinfcad)
								,prp.nrgarope = NVL(pr_nrgarope,prp.nrgarope)
								,prp.nrliquid = NVL(pr_nrliquid,prp.nrliquid)
								,prp.nrpatlvr = NVL(pr_nrparlvr,prp.nrpatlvr)
								,prp.nrperger = NVL(pr_nrperger,prp.nrperger)
					 WHERE prp.cdcooper = pr_cdcooper
						 AND prp.nrdconta = pr_nrdconta
						 AND prp.nrctrato = pr_nrctremp;
        EXCEPTION 
          WHEN OTHERS THEN 
						pr_status      := 400;
						pr_cdcritic    := 976;
						pr_msg_detalhe := 'Analise Automatica nao foi atualizada, houve erro no preenchi-'
													 || 'mento dos campos do Rating: '||sqlerrm;
            RAISE vr_exc_saida;                              
				END;
        /* Grava rating do cooperado nas tabelas crapttl ou crapjur */
        RATI0001.pc_grava_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                                ,pr_cdagenci => 1           --> Codigo Agencia
                                ,pr_nrdcaixa => 1           --> Numero Caixa
                                ,pr_cdoperad => '1'         --> Codigo Operador
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                                ,pr_inpessoa => rw_crapass.inpessoa --> Tipo Pessoa
                                ,pr_nrinfcad => pr_nrinfcad --> Informacoes Cadastrais
                                ,pr_nrpatlvr => pr_nrparlvr --> Patrimonio pessoal livre
                                ,pr_nrperger => pr_nrperger --> Percepção Geral Empresa
                                ,pr_idseqttl => 1           --> Sequencial do Titular
                                ,pr_idorigem => 9                     --> Identificador Origem
                                ,pr_nmdatela => 'WEBS0001'            --> Nome da tela
                                ,pr_flgerlog => 0                     --> Identificador de geração de log
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);
        
        IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
          pr_status      := 400;
          pr_msg_detalhe := 'Parecer nao foi atualizado: '||pr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        
      END IF;			
      /*Inicio M438*/
      -- Calcular Rating para atualiza no campo rating original
      vr_flgcriar := 0;
      RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                ,pr_cdagenci => 1   --> Codigo Agencia
                                ,pr_nrdcaixa => 1   --> Numero Caixa
                                ,pr_cdoperad => '1'   --> Codigo Operador
                                ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                ,pr_tpctrato => 90   --> Tipo Contrato Rating
                                ,pr_nrctrato => pr_nrctremp   --> Numero Contrato Rating
                                ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                                ,pr_flgcalcu => 1   --> Indicador de calculo
                                ,pr_idseqttl => 1   --> Sequencial do Titular
                                ,pr_idorigem => 9   --> Identificador Origem
                                ,pr_nmdatela => 'WEBS0001'   --> Nome da tela
                                ,pr_flgerlog => 'N'   --> Identificador de geração de log
                                ,pr_tab_rating_sing  => vr_tab_rating_sing      --> Registros gravados para rati
                                ,pr_flghisto => 0
                                -- OUT
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_des_reto);           --> Ind. de retorno OK/NOK
      --Limpar tabela erro 
      -- Para o calculo de rating, caso houver erro não devemos tratar para 
      -- não travar o processo de retorno
      vr_tab_erro.DELETE;                                 
      vr_des_reto := 'OK';
      vr_ind := vr_tab_impress_risco_cl.first; -- Vai para o primeiro registro            
      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        vr_rating := vr_tab_impress_risco_cl(vr_ind).dsdrisco;
        -- Vai para o proximo registro
        vr_ind := vr_tab_impress_risco_cl.next(vr_ind);
      END LOOP;          
      /*Fim 438*/	
      
      /* Verificar se a analise da proposta expirou na esteira*/      
      IF pr_insitapr = 99 THEN
        BEGIN
          UPDATE crawepr epr
             SET epr.insitest = 4 --> Expirado
           WHERE epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp
          RETURNING insitapr
                   ,cdopeapr
                   ,dtaprova
                   ,hraprova
                   ,dsobscmt
                   ,cdcomite
                   ,insitest
               INTO rw_crawepr.insitapr
                   ,rw_crawepr.cdopeapr
                   ,rw_crawepr.dtaprova
                   ,rw_crawepr.hraprova
                   ,rw_crawepr.dsobscmt                 
                   ,rw_crawepr.cdcomite
                   ,rw_crawepr.insitest;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE vr_exc_erro_500;
        END;  
      
      ELSE
      
        -- Buscar os dados da finalidade
        OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                       ,pr_cdfinemp => rw_crawepr.cdfinemp);
        FETCH cr_crapfin
         INTO rw_crapfin;
        -- Condicao para verificar se a proposta existe
        IF cr_crapfin%NOTFOUND THEN
          CLOSE cr_crapfin;
          RAISE vr_exc_erro_500;
        ELSE
          CLOSE cr_crapfin;      
        END IF;
        
        -- Condicao para verificar se a finalidade eh de portabilidade
        IF rw_crapfin.tpfinali = 2 THEN
          -- Atualiza os dados da proposta de portabilidade
          pc_atualiza_propost_portabilid(pr_cdcooper   => pr_cdcooper
                                        ,pr_nrdconta   => pr_nrdconta
                                        ,pr_nrctremp   => pr_nrctremp
                                        ,pr_rw_crapdat => pr_rw_crapdat
                                        ,pr_insitapr   => pr_insitapr
                                        ,pr_cdcritic   => pr_cdcritic
                                        ,pr_dscritic   => pr_dscritic
                                        ,pr_des_reto   => pr_des_reto);
                                    
          IF pr_des_reto <> 'OK' THEN
            pr_status      := 400;
            pr_cdcritic    := 976;
            pr_msg_detalhe := 'Parecer nao foi atualizado: '||pr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          
        END IF;        
        
        vr_idfluata := 0;
        IF pr_idfluata THEN
           vr_idfluata := 1;              
        END IF;
        
        -- Atualiza os dados da proposta de emprestimo
        BEGIN
          UPDATE crawepr
             SET crawepr.insitapr = pr_insitapr
                ,crawepr.cdopeapr = DECODE(pr_tpretest,'M','MOTOR','ESTEIRA')
                ,crawepr.dtaprova = pr_rw_crapdat.dtmvtolt
                ,crawepr.hraprova = gene0002.fn_busca_time
                ,crawepr.cdcomite = 3
                ,crawepr.insitest = 3 -- Finalizada                
                -- Aprovação via Esteira 
                ,crawepr.dsobscmt = DECODE(pr_tpretest,'E',substr(pr_dsobscmt,1,678)
                                                          ,crawepr.dsobscmt)                -- Aprovação via Motor
                ,crawepr.dsnivris = DECODE(pr_tpretest,'M',NVL(pr_indrisco,crawepr.dsnivris)
                                                          ,crawepr.dsnivris)
                ,crawepr.inliquid_operac_atraso = DECODE(pr_tpretest,'M',NVL(pr_inopeatr,crawepr.inliquid_operac_atraso)
                                                                            ,crawepr.inliquid_operac_atraso)
                ,crawepr.dtdscore = NVL(pr_dtdscore,nvl(crawepr.dtdscore,trunc(SYSDATE)))
                ,crawepr.dsdscore = NVL(pr_dsdscore,crawepr.dsdscore)
                ,crawepr.vlempori = crawepr.vlemprst /*M438*/
                ,crawepr.vlpreori = crawepr.vlpreemp /*M438*/
                ,crawepr.dsratori = coalesce(vr_rating,crawepr.dsratori,' ') /* M438 */
                ,crawepr.flgpreap = NVL(pr_flgpreap,crawepr.flgpreap)
                ,crawepr.idfluata = vr_idfluata -- P637
           WHERE crawepr.cdcooper = pr_cdcooper
             AND crawepr.nrdconta = pr_nrdconta
             AND crawepr.nrctremp = pr_nrctremp
          RETURNING insitapr
                   ,cdopeapr
                   ,dtaprova
                   ,hraprova
                   ,dsobscmt
                   ,cdcomite
                   ,insitest
                   ,dsnivris
               INTO rw_crawepr.insitapr
                   ,rw_crawepr.cdopeapr
                   ,rw_crawepr.dtaprova
                   ,rw_crawepr.hraprova
                   ,rw_crawepr.dsobscmt                 
                   ,rw_crawepr.cdcomite
                   ,rw_crawepr.insitest
                   ,rw_crawepr.dsnivris;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE vr_exc_erro_500;
        END;      
      END IF; -- fim if pr_insitapr = 99
      
      rw_crapass_log := rw_crapass;
      
      -- Atualiza os dados do cooperado
      BEGIN
        UPDATE crapass
           SET crapass.dtdscore = NVL(pr_dtdscore,crapass.dtdscore)
              ,crapass.dsdscore = NVL(pr_dsdscore,crapass.dsdscore)
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
        RETURNING dtdscore
                 ,dsdscore
                 ,dsnivris
             INTO rw_crapass.dtdscore
                 ,rw_crapass.dsdscore
                 ,rw_crapass.dsnivris;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_erro_500;
      END;      
      -- Gerar informações do log
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 'ESTEIRA'
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'AIMARO'
                          ,pr_dstransa => 'Parecer da proposta atualizado com sucesso'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> FALSE
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ESTEIRA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
      IF nvl(rw_crawepr_log.insitapr,0) <> nvl(rw_crawepr.insitapr,0) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitapr'
                                 ,pr_dsdadant => rw_crawepr_log.insitapr
                                 ,pr_dsdadatu => rw_crawepr.insitapr);
      END IF;
      
      IF nvl(rw_crawepr_log.cdopeapr,' ') <> nvl(rw_crawepr.cdopeapr,' ') THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdopeapr'
                                 ,pr_dsdadant => rw_crawepr_log.cdopeapr
                                 ,pr_dsdadatu => rw_crawepr.cdopeapr);
      END IF;
      
      IF nvl(rw_crawepr_log.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crawepr.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtaprova'
                                 ,pr_dsdadant => rw_crawepr_log.dtaprova
                                 ,pr_dsdadatu => rw_crawepr.dtaprova);
      END IF;
      
      IF nvl(rw_crawepr_log.hraprova,0) <> nvl(rw_crawepr.hraprova,0) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'hraprova'
                                 ,pr_dsdadant => rw_crawepr_log.hraprova
                                 ,pr_dsdadatu => rw_crawepr.hraprova);
      END IF;
      
      IF nvl(rw_crawepr_log.dsobscmt,' ') <> nvl(rw_crawepr.dsobscmt,' ') THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsobscmt'
                                 ,pr_dsdadant => rw_crawepr_log.dsobscmt
                                 ,pr_dsdadatu => rw_crawepr.dsobscmt);
      END IF;
      
      IF nvl(rw_crawepr_log.cdcomite,0) <> nvl(rw_crawepr.cdcomite,0) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdcomite'
                                 ,pr_dsdadant => rw_crawepr_log.cdcomite
                                 ,pr_dsdadatu => rw_crawepr.cdcomite);
      END IF;
      
      IF nvl(rw_crawepr_log.insitest,0) <> nvl(rw_crawepr.insitest,0) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitest'
                                 ,pr_dsdadant => rw_crawepr_log.insitest
                                 ,pr_dsdadatu => rw_crawepr.insitest);
      END IF;
      
      IF nvl(rw_crawepr_log.idfluata,0) <> nvl(rw_crawepr.idfluata,0) THEN -- P637
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'idfluata'
                                 ,pr_dsdadant => rw_crawepr_log.idfluata
                                 ,pr_dsdadatu => rw_crawepr.idfluata);
      END IF;     
      
      IF nvl(rw_crapass_log.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crapass.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtdscore'
                                 ,pr_dsdadant => rw_crapass_log.dtdscore
                                 ,pr_dsdadatu => rw_crapass.dtdscore);
      END IF;
      
      IF nvl(rw_crapass_log.dsdscore,' ') <> nvl(rw_crapass.dsdscore,' ') THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsdscore'
                                 ,pr_dsdadant => rw_crapass_log.dsdscore
                                 ,pr_dsdadatu => rw_crapass.dsdscore);
      END IF;
			
			IF nvl(rw_crapass_log.dsnivris,' ') <> nvl(rw_crapass.dsnivris,' ') THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsnivris'
                                 ,pr_dsdadant => rw_crapass_log.dsnivris
                                 ,pr_dsdadatu => rw_crapass.dsnivris);
      END IF;

      -- se for CDC ira notificar a alteracao da proposta via push
      IF rw_crapfin.tpfinali = 3 and pr_insitapr in (1,2) THEN

        -- avisar o pagamento efetuado para a push
        -- (1 aprovado, 3 aprovado), (2 reprovada, 4 nao aprovado)
        IF pr_insitapr= 1 THEN
          vr_insitpro := 3;
        ELSE
          vr_insitpro := 4;
        END IF;

        EMPR0012.pc_registra_push_sit_prop_cdc (pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_insitpro => vr_insitpro
                                               ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                                               ,pr_dscritic => vr_dscritic); --> Descricao da critica
      END IF;
      
      -- Caso nao ocorreu nenhum erro, vamos retorna como status de OK
      pr_status      := 202;      
      pr_msg_detalhe := 'Parecer da proposta atualizado com sucesso.';
      pr_des_reto    := 'OK';
      COMMIT;
            
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_des_reto := 'NOK';        
      WHEN vr_exc_erro_500 THEN
        ROLLBACK;
        pr_des_reto    := 'NOK';
        pr_status      := 500;
        pr_cdcritic    := 978;
        pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(1) ';          
        --/ P438 
          --/
        
      WHEN OTHERS THEN
        ROLLBACK;
        pr_des_reto    := 'NOK';
        pr_status      := 500;
        pr_cdcritic    := 978;
        pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(2):';
        --
          --/
        
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 3, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - WEBS0001 --> Nao foi possivel atualizar retorno de proposta: '||SQLERRM,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
    END;                            
      
  END pc_atualiza_prop_srv_emprestim;                                  
  
  PROCEDURE pc_atualiza_prop_srv_dsccheque(pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp    IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                          ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_insitapr    IN crawepr.insitapr%TYPE     --> Situacao da proposta
                                          ,pr_dsobscmt    IN crawepr.dsobscmt%TYPE     --> Observação recebida da esteira de crédito
                                          ,pr_dsdscore    IN crapass.dsdscore%TYPE     --> Consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_dtdscore    IN crapass.dtdscore%TYPE     --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_status      OUT PLS_INTEGER              --> Status
                                          ,pr_cdcritic    OUT PLS_INTEGER              --> Codigo da critica
                                          ,pr_dscritic    OUT VARCHAR2                 --> Descricao da critica
                                          ,pr_msg_detalhe OUT VARCHAR2                 --> Detalhe da mensagem
                                          ,pr_des_reto    OUT VARCHAR2) IS             --> Erros do processo
  BEGIN                                         
    /* .............................................................................
     Programa: pc_atualiza_prop_srv_dsccheque
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : 
     Data    : Janeiro/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Atualizar os dados da proposta de desconto de cheque

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE

    BEGIN
      NULL;     
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;                            
      
  END pc_atualiza_prop_srv_dsccheque;
                                           
  
  
  procedure pc_atualiza_prop_srv_limdesct
                (pr_cdcooper    in crapcop.cdcooper%type     --> Codigo da cooperativa
                ,pr_nrdconta    in crapass.nrdconta%type     --> Numero da conta
                ,pr_nrctrlim    in crawlim.nrctrlim%type     --> Numero do contrato
                ,pr_tpctrlim    in crawlim.tpctrlim%type     --> Tipo do contrato
																,pr_tpretest    in varchar2                  --> Tipo do retorno recebido ('M' - Motor/ 'E' - Esteira)
                ,pr_rw_crapdat  in btch0001.rw_crapdat%type  --> Vetor com dados de parâmetro (CRAPDAT)
                ,pr_insitapr    in crawlim.insitapr%type     --> Situacao da proposta
                ,pr_dsobscmt    in long default null         --> Observação recebida da esteira de crédito
                ,pr_dsdscore    in crapass.dsdscore%type default null    --> Consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_dtdscore    in crapass.dtdscore%type default null    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_indrisco    in varchar2 default null     --> Nível do risco calculado para a operação
                ,pr_nrnotrat    in number   default null     --> Valor do rating calculado para a operação
                ,pr_nrinfcad    in number   default null     --> Valor do item Informações Cadastrais calculado no Rating
				,pr_nrliquid    in number   default null     --> Valor do item Liquidez calculado no Rating
				,pr_nrgarope    in number   default null     --> Valor das Garantias calculada no Rating
				,pr_nrparlvr    in number   default null     --> Valor do Patrimônio Pessoal Livre calculado no Rating
                ,pr_nrperger    in number   default null     --> Valor da Percepção Geral da Empresa calculada no Rating
                ,pr_idfluata    in BOOLEAN  default FALSE    --> Indicador Segue Fluxo Atacado --P637                 
                ,pr_status      out pls_integer              --> Status
                ,pr_cdcritic    out pls_integer              --> Codigo da critica
                ,pr_dscritic    out varchar2                 --> Descricao da critica
                ,pr_msg_detalhe out varchar2                 --> Detalhe da mensagem
                ,pr_des_reto    out varchar2) is             --> Erros do processo
  begin                                         
    /* .............................................................................
    Programa: pc_atualiza_prop_srv_limdesct
    Sistema : Rotinas referentes ao WebService
    Sigla   : WEBS
    Autor   : Paulo Penteado (GFT) 
    Data    : Fevereiro/2018.                    Ultima atualizacao: 27/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Atualizar os dados da proposta de limite de desconto de titulos

    Observacao: -----
    Alteracoes: 27/02/2018 Criação (Paulo Penteado (GFT))

    ..............................................................................*/
  declare
    cursor cr_crawlim is
    select lim.insitest
          ,lim.dtmanute
          ,lim.insitapr
          ,lim.cdopeapr
          ,lim.dtaprova
          ,lim.hraprova
          ,lim.dsobscmt
          ,lim.dtenvest
							   ,lim.dsnivris
          ,lim.insitlim
          ,lim.idfluata
    from   crawlim lim
    where  lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
    rw_crawlim     cr_crawlim%rowtype;
    rw_crawlim_log cr_crawlim%rowtype;
      
    cursor cr_crapass(pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type) is
    select crapass.dtdscore
          ,crapass.dsdscore
				   			,crapass.dsnivris
          ,crapass.inpessoa
    from   crapass
    where  crapass.cdcooper = pr_cdcooper
    and    crapass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%rowtype;
    rw_crapass_log cr_crapass%rowtype;
      
    vr_nrdrowid      rowid;
    vr_exc_saida     exception;
    vr_exc_erro_500  exception;
    vr_idfluata      NUMBER(1);
  
  begin
      
    -- Buscar os dados da proposta
    open  cr_crawlim;
    fetch cr_crawlim into rw_crawlim;
    if    cr_crawlim%notfound then
          close cr_crawlim;
          pr_status      := 202;
          pr_cdcritic    := 535;
          pr_msg_detalhe := 'Parecer nao foi atualizado, a proposta nao foi encontrada no sistema Aimaro.';
          raise vr_exc_saida;
    else
          --  Verificar se o limite já foi confirmado e está ativo
          if  rw_crawlim.insitlim = 2 then
              close cr_crawlim;
              pr_status      := 202;
              pr_cdcritic    := 970;
              pr_msg_detalhe := 'Parecer da proposta nao foi atualizado, a proposta ja esta efetivada no sistema Aimaro.';
              raise vr_exc_saida;
          end if;
    end   if;
    close cr_crawlim;

    -- Buscar os dados do cooperado
    open  cr_crapass(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    fetch cr_crapass into rw_crapass;
    if    cr_crapass%notfound then
          close cr_crapass;
          pr_status      := 202;
          pr_cdcritic    := 564;
          pr_msg_detalhe := 'Parecer nao foi atualizado, a conta-corrente nao foi encontrada no sistema Aimaro.';
          raise vr_exc_saida;
    else
          close cr_crapass;
    end   if;

    --> Tratar para nao validar criticas qnt for 99-expirado
    if  pr_insitapr <> 99 then
        -- Proposta Finalizada
        if  rw_crawlim.insitest = 3 then
            pr_status      := 202;
            pr_cdcritic    := 974;
            pr_msg_detalhe := 'Parecer nao foi atualizado, a analise da proposta ja foi finalizada.';
            raise vr_exc_saida;
        end if;

        -- 1 – Enviada para Analise, 2 – Reenviado para Analise
        if  rw_crawlim.insitest not in (1,2) then
            pr_status      := 202;
            pr_cdcritic    := 971;
            pr_msg_detalhe := 'Parecer nao foi atualizado, proposta nao foi enviada para a esteira de credito.';
            raise vr_exc_saida;
        end if;
    end if; --> Fim IF pr_insitapr <> 99 THEN

    --  Proposta Expirado
    if  rw_crawlim.insitest = 4 then
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer nao foi atualizado, o prazo para analise da proposta exipirou.';
        raise vr_exc_saida;
    end if;

    rw_crawlim_log := rw_crawlim;
			
    /*  Caso o retorno seja oriundo da política de Crédito */      
			 if  pr_tpretest = 'M' then
				    begin
					     /* Atualizar as perguntas do Rating */      
					     update crapprp prp
						    set    nrinfcad = nvl(pr_nrinfcad, prp.nrinfcad)
								        ,nrgarope = nvl(pr_nrgarope, prp.nrgarope)
								        ,nrliquid = nvl(pr_nrliquid, prp.nrliquid)
								        ,nrpatlvr = nvl(pr_nrparlvr, prp.nrpatlvr)
								        ,nrperger = nvl(pr_nrperger, prp.nrperger)
					     where  prp.cdcooper = pr_cdcooper
						    and    prp.nrdconta = pr_nrdconta
						    and    prp.nrctrato = pr_nrctrlim;
        exception 
          when others then 
						         pr_status      := 400;
						         pr_cdcritic    := 976;
						         pr_msg_detalhe := 'Analise Automatica nao foi atualizada, houve erro no preenchimento dos campos do Rating: '||sqlerrm;
               raise vr_exc_saida;                              
				    end;
        
        /* Grava rating do cooperado nas tabelas crapttl ou crapjur */
        rati0001.pc_grava_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                                ,pr_cdagenci => 1           --> Codigo Agencia
                                ,pr_nrdcaixa => 1           --> Numero Caixa
                                ,pr_cdoperad => '1'         --> Codigo Operador
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                                ,pr_inpessoa => rw_crapass.inpessoa --> Tipo Pessoa
                                ,pr_nrinfcad => pr_nrinfcad --> Informacoes Cadastrais
                                ,pr_nrpatlvr => pr_nrparlvr --> Patrimonio pessoal livre
                                ,pr_nrperger => pr_nrperger --> Percepção Geral Empresa
                                ,pr_idseqttl => 1           --> Sequencial do Titular
                                ,pr_idorigem => 9                     --> Identificador Origem
                                ,pr_nmdatela => 'WEBS0001'            --> Nome da tela
                                ,pr_flgerlog => 0                     --> Identificador de geração de log
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);
        
        if  pr_cdcritic > 0 or pr_dscritic is not null then
            pr_status      := 400;
            pr_msg_detalhe := 'Parecer nao foi atualizado: '||pr_dscritic;
            raise vr_exc_saida;
        end if;
    end if;			
      
    vr_idfluata := 0;
    IF pr_idfluata THEN
       vr_idfluata := 1;              
    END IF;    		
      
    /*  Verificar se a analise da proposta expirou na esteira*/      
    if  pr_insitapr = 99 then
        begin
           update crawlim lim
           set    insitest = 4 --> Expirado
           where  lim.cdcooper = pr_cdcooper
           and    lim.nrdconta = pr_nrdconta
           and    lim.nrctrlim = pr_nrctrlim
           and    lim.tpctrlim = pr_tpctrlim
           returning insitapr
                    ,cdopeapr
                    ,dtaprova
                    ,hraprova
                    ,dsobscmt
                    ,insitest
           into      rw_crawlim.insitapr
                    ,rw_crawlim.cdopeapr
                    ,rw_crawlim.dtaprova
                    ,rw_crawlim.hraprova
                    ,rw_crawlim.dsobscmt                 
                    ,rw_crawlim.insitest;
        exception
           when others then
                raise vr_exc_erro_500;
        end;  
    else      
        -- Atualiza os dados da proposta
        begin
           update crawlim lim
           set    insitlim = case when pr_insitapr = 0 then 1 -- [erro]     em estudo
                                  when pr_insitapr = 1 then 5 -- [aprovar]  aprovado
                                  when pr_insitapr = 2 then 6 -- [reprovar] nao aprovado
                                  when pr_insitapr = 3 then 1 -- [derivar]  em estudo
                                  else 1 -- em estudo
                             end
                 ,insitest = case when pr_insitapr = 0 then 0 -- [erro]     nao enviado
                                  when pr_insitapr = 1 then 3 -- [aprovar]  analise finalizada
                                  when pr_insitapr = 2 then 3 -- [reprovar] analise finalizada
                                  when pr_insitapr = 3 then 2 -- [derivar ou com restricao]  enviada analise manual
                                  when pr_insitapr = 4 then 3 -- [refazer]  analise finalizada
                                  else 0 -- nao enviado
                             end
                 ,insitapr = case when pr_tpretest = 'M' then
                                       case when pr_insitapr = 0 then 0 -- [erro]     nao analisado
                                  when pr_insitapr = 1 then 1 -- [aprovar]  aprovado automaticamente
                                  when pr_insitapr = 2 then 5 -- [reprovar] rejeitado automaticamente
                                  when pr_insitapr = 3 then 0 -- [derivar]  nao analisado
                                  else 0 -- nao analisado
                             end
                                  else
                                       case when pr_insitapr = 0 then 0 -- [nao analisado] nao analisado
                                            when pr_insitapr = 1 then 2 -- [aprovado]      aprovado manual
                                            when pr_insitapr = 2 then 4 -- [nao aprovado]  rejeitado manual
                                            when pr_insitapr = 4 then 8 -- [refazer]       refazer
                                            when pr_insitapr = 3 then 4 -- [com restricao] rejeitado manual
                                            else 0 -- nao analisado
                                       end
                             end
                 ,cdopeapr = decode(pr_tpretest,'M','MOTOR','ESTEIRA')
                 ,dtaprova = pr_rw_crapdat.dtmvtolt
                 ,hraprova = gene0002.fn_busca_time
                 ,dsobscmt = decode(pr_tpretest, 'E', substr(pr_dsobscmt,1,678), lim.dsobscmt) -- Aprovação via Motor
                 ,dsnivris = decode(pr_tpretest, 'M', nvl(pr_indrisco, lim.dsnivris), lim.dsnivris)
                 ,dtdscore = nvl(pr_dtdscore, nvl(lim.dtdscore,trunc(sysdate)))
                 ,dsdscore = nvl(pr_dsdscore, lim.dsdscore)
                 ,nrinfcad = decode(pr_tpretest, 'M', nvl(pr_nrinfcad, lim.nrinfcad), lim.nrinfcad)
                 ,nrgarope = decode(pr_tpretest, 'M', nvl(pr_nrgarope, lim.nrinfcad), lim.nrgarope)
                 ,nrliquid = decode(pr_tpretest, 'M', nvl(pr_nrliquid, lim.nrinfcad), lim.nrliquid)
                 ,nrpatlvr = decode(pr_tpretest, 'M', nvl(pr_nrparlvr, lim.nrinfcad), lim.nrpatlvr)
                 ,nrperger = decode(pr_tpretest, 'M', nvl(pr_nrperger, lim.nrinfcad), lim.nrperger)
                 ,idfluata = vr_idfluata -- P637

           where  lim.cdcooper = pr_cdcooper
           and    lim.nrdconta = pr_nrdconta
           and    lim.nrctrlim = pr_nrctrlim
           and    lim.tpctrlim = pr_tpctrlim
           returning insitapr
                    ,cdopeapr
                    ,dtaprova
                    ,hraprova
                    ,dsobscmt
                    ,insitest
                    ,dsnivris
           into      rw_crawlim.insitapr
                    ,rw_crawlim.cdopeapr
                    ,rw_crawlim.dtaprova
                    ,rw_crawlim.hraprova
                    ,rw_crawlim.dsobscmt                 
                    ,rw_crawlim.insitest
                    ,rw_crawlim.dsnivris
                    ;
        exception
           when others then
                raise vr_exc_erro_500;
        end;      
    end if; -- fim if pr_insitapr = 99
      
    rw_crapass_log := rw_crapass;
      
    -- Atualiza os dados do cooperado
    begin
       update crapass
       set    dtdscore = nvl(pr_dtdscore, crapass.dtdscore)
             ,dsdscore = nvl(pr_dsdscore, crapass.dsdscore)
       where  crapass.cdcooper = pr_cdcooper
       and    crapass.nrdconta = pr_nrdconta
       returning dtdscore
                ,dsdscore
                ,dsnivris
       into      rw_crapass.dtdscore
                ,rw_crapass.dsdscore
                ,rw_crapass.dsnivris;
    exception
       when others then
            raise vr_exc_erro_500;
    end;      
    
    -- Gerar informações do log
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 'ESTEIRA'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => 'Parecer da proposta atualizado com sucesso'
                        ,pr_dttransa => trunc(sysdate)
                        ,pr_flgtrans => 1 --> FALSE
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ESTEIRA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                          
    if  nvl(rw_crawlim_log.insitapr,0) <> nvl(rw_crawlim.insitapr,0) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitapr'
                                 ,pr_dsdadant => rw_crawlim_log.insitapr
                                 ,pr_dsdadatu => rw_crawlim.insitapr);
    end if;
      
    if  nvl(rw_crawlim_log.cdopeapr,' ') <> nvl(rw_crawlim.cdopeapr,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdopeapr'
                                 ,pr_dsdadant => rw_crawlim_log.cdopeapr
                                 ,pr_dsdadatu => rw_crawlim.cdopeapr);
    end if;
      
    if  nvl(rw_crawlim_log.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crawlim.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtaprova'
                                 ,pr_dsdadant => rw_crawlim_log.dtaprova
                                 ,pr_dsdadatu => rw_crawlim.dtaprova);
    end if;
      
    if  nvl(rw_crawlim_log.hraprova,0) <> nvl(rw_crawlim.hraprova,0) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'hraprova'
                                 ,pr_dsdadant => rw_crawlim_log.hraprova
                                 ,pr_dsdadatu => rw_crawlim.hraprova);
    end if;
      
    if  nvl(rw_crawlim_log.dsobscmt,' ') <> nvl(rw_crawlim.dsobscmt,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsobscmt'
                                 ,pr_dsdadant => rw_crawlim_log.dsobscmt
                                 ,pr_dsdadatu => rw_crawlim.dsobscmt);
    end if;
      
    if  nvl(rw_crawlim_log.insitest,0) <> nvl(rw_crawlim.insitest,0) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitest'
                                 ,pr_dsdadant => rw_crawlim_log.insitest
                                 ,pr_dsdadatu => rw_crawlim.insitest);
    end if;
      
    if  nvl(rw_crawlim_log.idfluata,0) <> nvl(rw_crawlim.idfluata,0) then --P637
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'idfluata'
                                 ,pr_dsdadant => rw_crawlim_log.idfluata
                                 ,pr_dsdadatu => rw_crawlim.idfluata);
    end if; 
        
    if  nvl(rw_crapass_log.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crapass.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtdscore'
                                 ,pr_dsdadant => rw_crapass_log.dtdscore
                                 ,pr_dsdadatu => rw_crapass.dtdscore);
    end if;
      
    if  nvl(rw_crapass_log.dsdscore,' ') <> nvl(rw_crapass.dsdscore,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsdscore'
                                 ,pr_dsdadant => rw_crapass_log.dsdscore
                                 ,pr_dsdadatu => rw_crapass.dsdscore);
    end if;
			
			 if  nvl(rw_crapass_log.dsnivris,' ') <> nvl(rw_crapass.dsnivris,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsnivris'
                                 ,pr_dsdadant => rw_crapass_log.dsnivris
                                 ,pr_dsdadatu => rw_crapass.dsnivris);
    end if;
      
    -- Caso nao ocorreu nenhum erro, vamos retorna como status de OK
    pr_status      := 202;      
    pr_msg_detalhe := 'Parecer da proposta atualizado com sucesso.';
    pr_des_reto    := 'OK';
    
    commit;
            
  exception
     when vr_exc_saida then
          rollback;
          pr_des_reto := 'NOK';        

     when vr_exc_erro_500 then
          rollback;
          pr_des_reto    := 'NOK';
          pr_status      := 500;
          pr_cdcritic    := 978;
          pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(1) ';          
        
     when others then
          rollback;
          pr_des_reto    := 'NOK';
          pr_status      := 500;
          pr_cdcritic    := 978;
          pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(2):';
        
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 3
                                    ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - WEBS0001 --> Nao foi possivel atualizar retorno de proposta: '||sqlerrm
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                 ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  end;                            
  end pc_atualiza_prop_srv_limdesct;       

  procedure pc_atualiza_prop_srv_border
                (pr_cdcooper    in crapcop.cdcooper%type     --> Codigo da cooperativa
                ,pr_nrdconta    in crapass.nrdconta%type     --> Numero da conta
                ,pr_nrborder    IN crapbdt.nrborder%TYPE     --> Número do Borderô
                ,pr_rw_crapdat  in btch0001.rw_crapdat%type  --> Vetor com dados de parâmetro (CRAPDAT)
                ,pr_insitapr    in crapbdt.insitapr%type     --> Situacao da aprovação do bordero
                ,pr_dsobscmt    in long default null         --> Observaçao recebida da esteira de crédito
                ,pr_dsdscore    in crapass.dsdscore%type default null    --> Consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_dtdscore    in crapass.dtdscore%type default null    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                ,pr_status      out pls_integer              --> Status
                ,pr_cdcritic    out pls_integer              --> Codigo da critica
                ,pr_dscritic    out varchar2                 --> Descricao da critica
                ,pr_msg_detalhe out varchar2                 --> Detalhe da mensagem
                ,pr_des_reto    out varchar2) is             --> Erros do processo
  begin
    /* .............................................................................
    Programa: pc_atualiza_prop_srv_border
    Sistema : Rotinas referentes ao WebService
    Sigla   : WEBS
    Autor   : Andrew Albuquerque (GFT)
    Data    : Abril/2018.                    Ultima atualizacao: 26/04/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Atualizar os dados de borderô de desconto de titulos

    Observacao: -----
    Alteracoes: 26/04/2018 Criaçao (Andrew Albuquerque (GFT))

    ..............................................................................*/
  declare
    --> CARREGAR OS DADOS DO BORDERÔ
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                      ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                      ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
      SELECT bdt.rowid
            ,bdt.*
        FROM crapbdt bdt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    rw_crapbdt_log cr_crapbdt%rowtype;

    cursor cr_crapass(pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type) is
    select crapass.dtdscore
          ,crapass.dsdscore
                 ,crapass.dsnivris
          ,crapass.inpessoa
    from   crapass
    where  crapass.cdcooper = pr_cdcooper
    and    crapass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%rowtype;
    rw_crapass_log cr_crapass%rowtype;

    vr_nrdrowid      rowid;
    vr_exc_saida     exception;
    vr_exc_erro_500  exception;

    --> Acionamentos de retorno
    cursor cr_aciona_retorno(pr_cdcooper IN crapbdt.cdcooper%TYPE
                            ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                            ,pr_nrborder IN crapbdt.nrborder%TYPE) is
      select ac.dsconteudo_requisicao
      from   tbgen_webservice_aciona ac
      where  ac.cdcooper      = pr_cdcooper
      and    ac.nrdconta      = pr_nrdconta
      and    ac.nrctrprp      = pr_nrborder
      and    ac.tpacionamento = 2
      ORDER BY ac.dhacionamento DESC
    ;  
    --> Somente Retorno
    vr_dsconteudo_requisicao tbgen_webservice_aciona.dsconteudo_requisicao%TYPE;

--    vr_dsprotoc Crapbdt.dsprotoc%TYPE;
    
    --> Objetos para retorno das mensagens
    vr_obj_retorno cecred.json := json();
    vr_obj_lst cecred.json_list := json_list();
    vr_obj_tit cecred.json := json(); 
    
    --> variáveis para fazer o tratamento das mensagens e atualizar os títulos e borderô.
    vr_chavetitulo VARCHAR2(100);
    vr_sittitulo  VARCHAR2(100);
    vr_nrdcontaPk craptdb.nrdconta%TYPE;
    vr_nrborderPk craptdb.nrborder%TYPE;
    vr_nrdocmtoPk craptdb.nrdocmto%TYPE;
    vr_Aprovados  PLS_INTEGER;
    vr_Reprovados PLS_INTEGER;
    v_insitapr    crapbdt.insitapr%TYPE;
  begin
    
    -- buscar os dados do borderô
    OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdt into rw_crapbdt;
    IF cr_crapbdt%NOTFOUND THEN
      CLOSE cr_crapbdt;
      pr_status      := 202;
      pr_cdcritic    := 1166;
      pr_msg_detalhe := 'Parecer não foi atualizado, o borderô não foi encontrado no sistema Aimaro.';
      raise vr_exc_saida;
    ELSE
      -- Verificar se o Borderô já está Liberado. Se ele estiver apenas 2-Analisado, pode receber a resposta de uma re-analise.
      IF rw_crapbdt.insitbdt > 2 THEN -- 3 Liberado / 4-Liquidado / 5-Rejeitado
        pr_status      := 202;
        pr_cdcritic    := 970;
        pr_msg_detalhe := 'Parecer do borderô não foi atualizado, o borderô já está efetivado no sistema Aimaro.';
        raise vr_exc_saida;
      END IF;
    END IF;      
    close cr_crapbdt;
    
    -- pegando o protocolo de envio do borderô
--    vr_dsprotoc := rw_crapbdt.dsprotoc;

    -- Buscar os dados do cooperado
    open  cr_crapass(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    fetch cr_crapass into rw_crapass;
    if    cr_crapass%notfound then
          close cr_crapass;
          pr_status      := 202;
          pr_cdcritic    := 564;
          pr_msg_detalhe := 'Parecer não foi atualizado, a conta-corrente não foi encontrada no sistema Aimaro.';
          raise vr_exc_saida;
    else
          close cr_crapass;
    end   if;

    --> Tratar para nao validar criticas qnt for 99-expirado
    if  pr_insitapr <> 99 then
      -- Análise Finalizada (3-Aprovado Automaticamente 4-Aprovado 5-Reprovado)
      if  rw_crapbdt.insitapr in (3,4,5,7) then
          pr_status      := 202;
          pr_cdcritic    := 974;
          pr_msg_detalhe := 'Parecer não foi atualizado, a análise do borderô já foi finalizada.';
          raise vr_exc_saida;
      end if;

      -- 6-Enviado Esteira
      if  rw_crapbdt.insitapr <> 6 then
          pr_status      := 202;
          pr_cdcritic    := 971;
          pr_msg_detalhe := 'Parecer não foi atualizado, borderô não foi enviado para a esteira de crédito.';
          raise vr_exc_saida;
      end if;
    end if;

    --  7-Prazo expirado
    if  rw_crapbdt.insitapr = 7 then
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer não foi atualizado, o prazo para análise dp borderô exipirou.';
        raise vr_exc_saida;
    end if;

    /*  Verificar se a analise da proposta expirou na esteira*/
    IF pr_insitapr = 99 THEN
      BEGIN
        UPDATE crapbdt bdt
           SET bdt.insitapr = 7 -->expirado
         WHERE bdt.cdcooper = pr_cdcooper
           AND bdt.nrdconta = pr_nrdconta
           AND bdt.nrborder = pr_nrborder
           RETURNING insitapr
                    ,cdopeapr
                    ,dtaprova
                    ,hraprova
           INTO      rw_crapbdt.insitapr
                    ,rw_crapbdt.cdopeapr
                    ,rw_crapbdt.dtaprova
                    ,rw_crapbdt.hraprova;
      EXCEPTION
         WHEN OTHERS THEN
              RAISE vr_exc_erro_500;
      END;
    ELSE
      /* AWAE: Ler o JSON de Resposta e atualizar cada um dos Títulos que retornaram.
               Após, se pelo menos UM Título retornou como aprovado, deve então fazer
               a aprovação do BORDERÔ. Se nenhum título estiver aprovado na lista, então
               o borderô deve ficar com decisão de aprovação  = REPROVADO também.
      */
      -->    Buscar os detalhes do acionamento de retorno
      OPEN cr_aciona_retorno(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrborder => pr_nrborder);
      FETCH cr_aciona_retorno INTO vr_dsconteudo_requisicao;
      IF cr_aciona_retorno%FOUND THEN
        -- Se achou, é aqui que será feita a atualização dos títulos e do borderô.
        --> Efetuar cast para JSON
        vr_obj_retorno := json(REPLACE(vr_dsconteudo_requisicao,'&quot',''));

        vr_Aprovados  := 0;
        vr_Reprovados := 0;
        
        -- se existir o objeto de array de titulos
        IF vr_obj_retorno.exist('titulo') THEN
          vr_obj_lst := json_list(vr_obj_retorno.get('titulo').to_char());
          
          --> para cada título.
          FOR vr_idx in 1..vr_obj_lst.count() LOOP
            BEGIN
              vr_obj_tit := json( vr_obj_lst.get(vr_idx));

              -->  Se encontrar o atributo idTitulo e situacaoTitulo
              IF vr_obj_tit.exist('idTitulo') and vr_obj_tit.exist('situacaoTitulo') THEN
                vr_chavetitulo := rtrim(ltrim(vr_obj_tit.get('idTitulo').to_char(),'"'),'"');
                vr_sittitulo   := upper(rtrim(ltrim(vr_obj_tit.get('situacaoTitulo').to_char(),'"'),'"'));
                    
                -- Atualizar o Status do Título corrente.
                BEGIN
                  UPDATE craptdb tdb
                     SET tdb.insitapr = decode(vr_sittitulo,'APROVADO',1,'REPROVADO',2,tdb.insitapr)
                        ,tdb.cdoriapr = 2 -- Esteira IBRATAN
                   WHERE tdb.nrtitulo = vr_chavetitulo
                     AND tdb.nrborder = pr_nrborder
                     AND tdb.cdcooper = pr_cdcooper;

                  -- contagem de aprovados e reprovados para uso quando for atualizar o borderô.
                  IF vr_sittitulo = 'APROVADO' THEN
                    vr_Aprovados := vr_Aprovados + 1;
                  ELSIF vr_sittitulo = 'REPROVADO' THEN
                    vr_Reprovados := vr_Reprovados + 1;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE vr_exc_erro_500;
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                NULL; --> IGNORAR ESSA LINHA
            END;
          END LOOP;
          --> Verifica se ocorreu atualização, se sim, altera o status do borderô de acordo com 
          --> a contagem de aprovados e reprovados.
          IF (vr_Aprovados + vr_Reprovados) > 0 THEN
            IF vr_aprovados > 0 THEN
              v_insitapr := 4;
            ELSIF (vr_aprovados = 0) and (vr_reprovados >0) THEN
              v_insitapr := 5;
            END IF;
            BEGIN
              UPDATE crapbdt bdt
                 SET bdt.insitapr = v_insitapr
                    ,bdt.dtaprova = pr_rw_crapdat.dtmvtolt
                    ,bdt.hraprova = gene0002.fn_busca_time
                    ,bdt.cdopeapr = 'ESTEIRA'
                    ,bdt.insitbdt = 2
               WHERE bdt.cdcooper = pr_cdcooper
                 AND bdt.nrdconta = pr_nrdconta
                 AND bdt.nrborder = pr_nrborder
                 RETURNING insitapr
                          ,cdopeapr
                          ,dtaprova
                          ,hraprova
                 INTO      rw_crapbdt.insitapr
                          ,rw_crapbdt.cdopeapr
                          ,rw_crapbdt.dtaprova
                          ,rw_crapbdt.hraprova;
            EXCEPTION
               WHEN OTHERS THEN
                    RAISE vr_exc_erro_500;
            END;
          END IF;
          
        END IF;
      END IF;  
    END IF; -- fim if pr_insitapr = 99

    rw_crapass_log := rw_crapass;

    -- Atualiza os dados do cooperado
    begin
       update crapass
       set    dtdscore = nvl(pr_dtdscore, crapass.dtdscore)
             ,dsdscore = nvl(pr_dsdscore, crapass.dsdscore)
       where  crapass.cdcooper = pr_cdcooper
       and    crapass.nrdconta = pr_nrdconta
       returning dtdscore
                ,dsdscore
                ,dsnivris
       into      rw_crapass.dtdscore
                ,rw_crapass.dsdscore
                ,rw_crapass.dsnivris;
    exception
       when others then
            raise vr_exc_erro_500;
    end;

    -- Gerar informaçoes do log
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 'ESTEIRA'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => 'Parecer do borderô atualizado com sucesso'
                        ,pr_dttransa => trunc(sysdate)
                        ,pr_flgtrans => 1 --> FALSE
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ESTEIRA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    if  nvl(rw_crapbdt_log.insitapr,0) <> nvl(rw_crapbdt.insitapr,0) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitapr'
                                 ,pr_dsdadant => rw_crapbdt.insitapr
                                 ,pr_dsdadatu => rw_crapbdt.insitapr);
    end if;

    if  nvl(rw_crapbdt_log.cdopeapr,' ') <> nvl(rw_crapbdt.cdopeapr,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cdopeapr'
                                 ,pr_dsdadant => rw_crapbdt_log.cdopeapr
                                 ,pr_dsdadatu => rw_crapbdt.cdopeapr);
    end if;

    if  nvl(rw_crapbdt_log.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crapbdt.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtaprova'
                                 ,pr_dsdadant => rw_crapbdt_log.dtaprova
                                 ,pr_dsdadatu => rw_crapbdt.dtaprova);
    end if;

    if  nvl(rw_crapbdt_log.hraprova,0) <> nvl(rw_crapbdt.hraprova,0) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'hraprova'
                                 ,pr_dsdadant => rw_crapbdt_log.hraprova
                                 ,pr_dsdadatu => rw_crapbdt.hraprova);
    end if;

    if  nvl(rw_crapass_log.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crapass.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtdscore'
                                 ,pr_dsdadant => rw_crapass_log.dtdscore
                                 ,pr_dsdadatu => rw_crapass.dtdscore);
    end if;

    if  nvl(rw_crapass_log.dsdscore,' ') <> nvl(rw_crapass.dsdscore,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsdscore'
                                 ,pr_dsdadant => rw_crapass_log.dsdscore
                                 ,pr_dsdadatu => rw_crapass.dsdscore);
    end if;

       if  nvl(rw_crapass_log.dsnivris,' ') <> nvl(rw_crapass.dsnivris,' ') then
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsnivris'
                                 ,pr_dsdadant => rw_crapass_log.dsnivris
                                 ,pr_dsdadatu => rw_crapass.dsnivris);
    end if;

    -- Caso nao ocorreu nenhum erro, vamos retorna como status de OK
    pr_status      := 202;
    pr_msg_detalhe := 'Parecer do borderô atualizado com sucesso.';
    pr_des_reto    := 'OK';

    commit;

  exception
     when vr_exc_saida then
          rollback;
          pr_des_reto := 'NOK';

     when vr_exc_erro_500 then
          rollback;
          pr_des_reto    := 'NOK';
          pr_status      := 500;
          pr_cdcritic    := 978;
          pr_msg_detalhe := 'Parecer não foi atualizado, ocorreu uma erro interno no sistema.(1) ';

     when others then
          rollback;
          pr_des_reto    := 'NOK';
          pr_status      := 500;
          pr_cdcritic    := 978;
          pr_msg_detalhe := 'Parecer não foi atualizado, ocorreu uma erro interno no sistema.(2):';

          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 3
                                    ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - WEBS0001 --> Não foi possível atualizar retorno de borderô: '||sqlerrm
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                 ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  end;
  end pc_atualiza_prop_srv_border;

  --Atualiza Proposta de cartão
  PROCEDURE pc_atualiza_prop_srv_cartao(pr_cdcooper    IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                       ,pr_nrdconta    IN crapass.nrdconta%TYPE     --> Numero da conta
                                       ,pr_nrctrcrd    IN crawcrd.nrctrcrd%TYPE     --> Numero do contrato
                                       ,pr_nrctrest    IN crawcrd.nrctrcrd%TYPE DEFAULT NULL    --> Numero do contrato original da esteira (tratamento limite credito)
                                       ,pr_tpretest    IN VARCHAR2                  --> Tipo do retorno recebido ('M' - Motor/ 'E' - Esteira)
                                       ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_insitapr    IN crawepr.insitapr%TYPE     --> Situacao da proposta
                                       ,pr_dsdscore    IN crapass.dsdscore%TYPE DEFAULT NULL    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                       ,pr_dtdscore    IN crapass.dtdscore%TYPE DEFAULT NULL    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                       ,pr_nrinfcad    IN NUMBER   DEFAULT NULL     --> Valor do item Informaçoes Cadastrais calculado no Rating
                                       ,pr_nrliquid    IN NUMBER   DEFAULT NULL     --> Valor do item Liquidez calculado no Rating
                                       ,pr_nrgarope    IN NUMBER   DEFAULT NULL     --> Valor das Garantias calculada no Rating
                                       ,pr_nrparlvr    IN NUMBER   DEFAULT NULL     --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                       ,pr_nrperger    IN NUMBER   DEFAULT NULL     --> Valor da Percepçao Geral da Empresa calculada no Rating
                                       ,pr_status      OUT PLS_INTEGER              --> Status
                                       ,pr_cdcritic    OUT PLS_INTEGER              --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2                 --> Descricao da critica
                                       ,pr_msg_detalhe OUT VARCHAR2                 --> Detalhe da mensagem
                                       ,pr_des_reto    OUT VARCHAR2) IS             --> Erros do processo
  BEGIN
    /* .............................................................................
     Programa: pc_atualiza_prop_srv_cartao
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Paulo Silva (Supero)
     Data    : Maio/2018.                    Ultima atualizacao: 28/06/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Atualizar os dados da proposta de Cartão

     Observacao: -----
     Alteracoes: 09/07/2018 - Alterada chamada da procedure ccrd0007.pc_alterar_cartao_bancoob passando o parâmetro pr_idseqttl fixo 1. Paulo Silva (Supero).

                 05/06/2019 - Implementado LOG caso não encontra o registro de alteração de limite de cartão
                              e ajustado cursor cr_limatu. 
                              Alcemir Jr. (INC0012482).
                              
                 28/06/2019 - Incluir dtcancel e retirar a titularidade quando proposta
                              rejeitada na esteira (Lucas Ranghetti PRB0041968)
     ..............................................................................*/
    DECLARE
      --Busca dados da Proposta
      CURSOR cr_crawcrd(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctrcrd IN crawepr.nrctremp%TYPE) IS
        SELECT crawcrd.insitdec
              ,crawcrd.dtaprova
              ,crawcrd.insitcrd
              ,crawcrd.nrcrcard
              ,crawcrd.vllimcrd
              ,crawcrd.flgprcrd
              ,crawcrd.inupgrad
              ,crawcrd.cdadmcrd
              ,crawcrd.nrcctitg
          FROM crawcrd
         WHERE crawcrd.cdcooper = pr_cdcooper
           AND crawcrd.nrdconta = pr_nrdconta
           AND crawcrd.nrctrcrd = pr_nrctrcrd;
      rw_crawcrd     cr_crawcrd%ROWTYPE;
      rw_crawcrd_log cr_crawcrd%ROWTYPE;

      --Busca dados Associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.dtdscore
              ,crapass.dsdscore
              ,crapass.dsnivris
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass     cr_crapass%ROWTYPE;
      rw_crapass_log cr_crapass%ROWTYPE;

      -- Busca dos dados do contrato
      CURSOR cr_crapcrd (pr_cdcooper IN crapcrd.cdcooper%TYPE,
                         pr_nrdconta IN crapcrd.nrdconta%TYPE,
                         pr_nrctrcrd IN crapcrd.nrctrcrd%TYPE) IS
        SELECT 1
          FROM crapcrd
         WHERE crapcrd.cdcooper = pr_cdcooper
           AND crapcrd.nrdconta = pr_nrdconta
           AND crapcrd.nrctrcrd = pr_nrctrcrd;
      vr_flgexepr PLS_INTEGER := 0;

      vr_nrdrowid      ROWID;
      vr_exc_saida     EXCEPTION;
      vr_exc_erro_500  EXCEPTION;
      
      vr_insitdec      crawcrd.insitdec%TYPE;
      vr_insitcrd      crawcrd.insitcrd%TYPE;
      vr_tpsituac      tbcrd_limite_atualiza.tpsituacao%TYPE;
      
      --Busca Histórico Alteração de Crédito
      CURSOR cr_limatu IS
        SELECT a.*
              ,a.rowid
          FROM tbcrd_limite_atualiza a
          JOIN crawcrd crd
            ON crd.cdcooper = a.cdcooper
           AND crd.nrdconta = a.nrdconta
           AND crd.nrctrcrd = a.nrctrcrd
           AND crd.nrcctitg > 0 /* Se a proposta nao tem conta cartao 
                                   ela nao foi pro bancoob, logo nao
                                   pode ter uma alteracao de limite */
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.nrctrcrd = pr_nrctrcrd 
           AND a.nrproposta_est = pr_nrctrest
           AND a.tpsituacao = 6 --Em Análise
           AND a.insitdec   = 1 --Sem aprovacao 
           AND a.dtalteracao = (select max(x.dtalteracao)
                                  from tbcrd_limite_atualiza x
                                 where a.cdcooper = x.cdcooper
                                   AND a.nrdconta = x.nrdconta
                                   AND a.nrctrcrd = x.nrctrcrd 
                                   AND a.nrproposta_est = x.nrproposta_est
                                   AND x.tpsituacao = 6 --Em Análise
                                   AND x.insitdec   = 1 --Sem aprovacao
                                   ); 
      rw_limatu cr_limatu%ROWTYPE;
      
      CURSOR cr_limatu_log IS
        SELECT a.idatualizacao,
               a.cdcooper,
               a.nrdconta,
               a.nrconta_cartao,
               a.dtalteracao,
               a.tpsituacao,
               a.vllimite_anterior,
               a.vllimite_alterado,
               a.cdcanal,
               a.cdoperad,
               a.insitdec,
               a.nrctrcrd,
               a.nrproposta_est                    
          FROM tbcrd_limite_atualiza a
          JOIN crawcrd crd
            ON crd.cdcooper = a.cdcooper
           AND crd.nrdconta = a.nrdconta
           AND crd.nrctrcrd = a.nrctrcrd
           AND crd.nrcctitg > 0 /* Se a proposta nao tem conta cartao 
                                   ela nao foi pro bancoob, logo nao
                                   pode ter uma alteracao de limite */
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.nrctrcrd = pr_nrctrcrd 
           AND a.nrproposta_est = pr_nrctrest;
       rw_limatu_log cr_limatu_log%ROWTYPE;
      
      ----- VARIÁVEIS -----
      vr_vllimite     crawcrd.vllimcrd%TYPE;
      vr_idprglog     NUMBER;
    
    BEGIN

      IF pr_tpretest = 'E' THEN --Apenas para retorno da Esteira
        -- Buscar os dados da proposta de cartão
        OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrcrd => pr_nrctrcrd);
        FETCH cr_crawcrd INTO rw_crawcrd;
        
        -- Condicao para verificar se a proposta existe
        IF cr_crawcrd%NOTFOUND THEN
          CLOSE cr_crawcrd;
          pr_status      := 202;
          pr_cdcritic    := 535;
          pr_msg_detalhe := 'Parecer nao foi atualizado, a proposta nao foi encontrada no sistema Aimaro.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crawcrd;
        END IF;
        
        OPEN cr_limatu;
        FETCH cr_limatu INTO rw_limatu;
        IF cr_limatu%FOUND THEN
          vr_vllimite := rw_limatu.vllimite_alterado;
        ELSE
          
          FOR rw_limatu_log  IN cr_limatu_log LOOP
                                          
            cecred.pc_log_programa(PR_DSTIPLOG   => 'E'
                                  ,PR_CDPROGRAMA => 'WEBS0001_log_crd' 
                                  ,pr_cdcooper   => pr_cdcooper
                                  ,pr_dsmensagem => 'cdcooper: ' || rw_limatu_log.cdcooper || 
                                                    ' nrdconta: ' || rw_limatu_log.nrdconta ||
                                                    ' nrconta_cartao: ' || rw_limatu_log.nrconta_cartao || 
                                                    ' dtalteracao: ' || to_char(rw_limatu_log.dtalteracao) || 
                                                    ' tpsituacao: ' || rw_limatu_log.tpsituacao || 
                                                    ' vllimite_anterior: ' || rw_limatu_log.vllimite_anterior || 
                                                    ' vllimite_alterado: ' || rw_limatu_log.vllimite_alterado || 
                                                    ' cdcanal: ' || rw_limatu_log.cdcanal || 
                                                    ' cdoperad: ' || rw_limatu_log.cdoperad || 
                                                    ' insitdec: ' || rw_limatu_log.insitdec || 
                                                    ' nrctrcrd: ' || rw_limatu_log.nrctrcrd || 
                                                    ' nrproposta_est: ' || rw_limatu_log.nrproposta_est                                                                                                                                                                    
                                  ,PR_IDPRGLOG   => vr_idprglog);

            
          END LOOP;
          
        END IF;
        CLOSE cr_limatu;
       
      END IF;

      -- Buscar os dados do cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      -- Condicao para verificar se a proposta existe
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        pr_status      := 202;
        pr_cdcritic    := 564;
        pr_msg_detalhe := 'Parecer nao foi atualizado, a conta-corrente nao foi encontrada no sistema Aimaro.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      IF pr_tpretest = 'E' THEN --Apenas para retorno da Esteira
        --> Tratar para nao validar criticas qnt for 99-expirado
        IF pr_insitapr <> 99 THEN
          -- Proposta 2- Aprovado Auto, 3- Aprovado Manual -- somente para Nova proposta
          IF pr_nrctrest is null THEN
          IF rw_crawcrd.insitcrd = 1 AND rw_crawcrd.insitdec IN (2,3) THEN
            pr_status      := 202;
            pr_cdcritic    := 974;
            pr_msg_detalhe := 'Parecer nao foi atualizado, a analise da proposta ja foi finalizada.';
            RAISE vr_exc_saida;
          END IF;

          -- 1 – Sem Aprovação
          IF rw_crawcrd.insitcrd = 1 AND rw_crawcrd.insitdec <> 1 THEN
            pr_status      := 202;
            pr_cdcritic    := 971;
            pr_msg_detalhe := 'Parecer nao foi atualizado, proposta em situacao que nao permite esta operacao.';
            RAISE vr_exc_saida;
          END IF;
          END IF; --> FIM IF pr_nrctrest is null
        END IF; --> Fim IF pr_insitapr <> 99 THEN

        -- Proposta Expirado
        IF rw_crawcrd.insitdec = 7 AND  pr_nrctrest is null THEN
          pr_status      := 202;
          pr_cdcritic    := 975;
          pr_msg_detalhe := 'Parecer nao foi atualizado, o prazo para analise da proposta exipirou.';
          RAISE vr_exc_saida;
        END IF;

        -- se e alteracao de limite
        IF pr_nrctrest IS NULL THEN
          OPEN cr_crapcrd(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrctrcrd => pr_nrctrcrd);
          FETCH cr_crapcrd INTO vr_flgexepr;
          CLOSE cr_crapcrd;
          
          -- Condicao para verificar se a proposta jah foi efetivado
          IF NVL(vr_flgexepr,0) = 1 THEN
            pr_status      := 202;
            pr_cdcritic    := 970;
            pr_msg_detalhe := 'Parecer da proposta nao foi atualizado, a proposta ja esta efetivada no sistema Aimaro.';
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        rw_crawcrd_log := rw_crawcrd;
      
        BEGIN
          /* Atualizar as perguntas do Rating */      
          UPDATE crapprp prp
             SET prp.nrinfcad = NVL(pr_nrinfcad,prp.nrinfcad)
                ,prp.nrgarope = NVL(pr_nrgarope,prp.nrgarope)
                ,prp.nrliquid = NVL(pr_nrliquid,prp.nrliquid)
                ,prp.nrpatlvr = NVL(pr_nrparlvr,prp.nrpatlvr)
                ,prp.nrperger = NVL(pr_nrperger,prp.nrperger)
           WHERE prp.cdcooper = pr_cdcooper
             AND prp.nrdconta = pr_nrdconta
             AND prp.nrctrato = pr_nrctrcrd;
        EXCEPTION 
          WHEN OTHERS THEN 
            pr_status      := 400;
            pr_cdcritic    := 976;
            pr_msg_detalhe := 'Analise Automatica nao foi atualizada, houve erro no preenchimento dos campos do Rating: '||sqlerrm;
            RAISE vr_exc_saida;                              
        END;
        
        /* Grava rating do cooperado nas tabelas crapttl ou crapjur */
        rati0001.pc_grava_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                                ,pr_cdagenci => 1           --> Codigo Agencia
                                ,pr_nrdcaixa => 1           --> Numero Caixa
                                ,pr_cdoperad => '1'         --> Codigo Operador
                                ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data de movimento
                                ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                                ,pr_inpessoa => rw_crapass.inpessoa --> Tipo Pessoa
                                ,pr_nrinfcad => pr_nrinfcad --> Informacoes Cadastrais
                                ,pr_nrpatlvr => pr_nrparlvr --> Patrimonio pessoal livre
                                ,pr_nrperger => pr_nrperger --> Percepçao Geral Empresa
                                ,pr_idseqttl => 1           --> Sequencial do Titular
                                ,pr_idorigem => 9                     --> Identificador Origem
                                ,pr_nmdatela => 'WEBS0001'            --> Nome da tela
                                ,pr_flgerlog => 0                     --> Identificador de geraçao de log
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);

        IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
          pr_status      := 400;
          pr_msg_detalhe := 'Parecer nao foi atualizado: '||pr_dscritic;
          RAISE vr_exc_saida;
        END IF;

        /* Verificar se a analise da proposta expirou na esteira*/
        IF pr_insitapr = 99 THEN
          BEGIN
            UPDATE crawcrd crd
               SET crd.insitdec = 7 --> Expirado
             WHERE crd.cdcooper = pr_cdcooper
               AND crd.nrdconta = pr_nrdconta
               AND crd.nrctrcrd = pr_nrctrcrd
            RETURNING dtaprova
                     ,insitdec
                 INTO rw_crawcrd.dtaprova
                     ,rw_crawcrd.insitdec;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE vr_exc_erro_500;
          END;

        END IF; -- fim if pr_insitapr = 99
      END IF;

      rw_crapass_log := rw_crapass;

      -- Atualiza os dados do cooperado
      BEGIN
        UPDATE crapass
           SET crapass.dtdscore = NVL(pr_dtdscore,crapass.dtdscore)
              ,crapass.dsdscore = NVL(pr_dsdscore,crapass.dsdscore)
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
        RETURNING dtdscore
                 ,dsdscore
                 ,dsnivris
             INTO rw_crapass.dtdscore
                 ,rw_crapass.dsdscore
                 ,rw_crapass.dsnivris;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_erro_500;
      END;

      IF pr_tpretest = 'E' THEN --Esteira
        -- alteracao de limite
        IF pr_nrctrest IS NOT NULL THEN
        
          -- Caso for alteracao de limite
          IF pr_insitapr = 1 THEN
            -- Caso aprovado
            vr_insitdec := 3; -- Aprovado Manual
            vr_tpsituac := 6; -- Em Análise (mantem com o status atual - na sequencia vai enviar ao bcb)
          ELSIF pr_insitapr = 2 THEN
            -- Caso nao aprovado
            vr_insitdec := 5; -- Rejeitada
            vr_tpsituac := 4; -- Critica
          ELSE
            -- Caso for refazer ou outra situacao
            vr_insitdec := 6; -- Refazer
            vr_tpsituac := 6; -- Em Análise (mantem com o status atual)
          END IF;
          
          BEGIN
            UPDATE tbcrd_limite_atualiza
               SET insitdec   = vr_insitdec
                  ,tpsituacao = vr_tpsituac
             WHERE tbcrd_limite_atualiza.rowid = rw_limatu.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE vr_exc_erro_500;            
          END;
          
          IF pr_insitapr = 1 THEN 
            BEGIN
              ccrd0007.pc_alterar_cartao_bancoob(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => 1
                                       ,pr_cdoperad => 'ESTEIRA'
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctrcrd => pr_nrctrcrd
                                       ,pr_idorigem => 5
                                       ,pr_vllimite => vr_vllimite
                                       ,pr_idseqttl => 1--rw_crawcrd.flgprcrd /*09/07/2018 - Paulo Silva (Supero)*/
                                       ,pr_cdcritic => pr_cdcritic
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_des_erro => pr_des_reto);
                                       
              IF pr_cdcritic > 0  OR TRIM(pr_dscritic) IS NOT NULL THEN
                -- Não vamos estourar a crítica do BCB para a esteira.
                pr_cdcritic := 0;
                pr_dscritic := '';
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                -- Não vamos estourar a crítica do BCB para a esteira.
                pr_cdcritic := 0;
                pr_dscritic := '';
            END;
            
          END IF;
        ELSIF rw_crawcrd.inupgrad = 1 THEN
          -- Caso for upgrade
          IF pr_insitapr = 1 THEN
            -- Caso aprovado
            vr_insitdec := 3; -- Aprovado Manual
            vr_insitcrd := 1; -- Aprovado
          ELSIF pr_insitapr = 2 THEN
            -- Caso nao aprovado
            vr_insitdec := 5; -- Rejeitada
            vr_insitcrd := 6; -- Cancelado
          ELSE
            -- Caso for refazer ou outra situacao
            vr_insitdec := 6; -- Refazer
            vr_insitcrd := 0; -- Em Estudo
          END IF;
          -- Atualiza os dados de todas as propostas de upgrade
          -- (caso existir adicional, eles também devem ser alterados)
          BEGIN
            UPDATE crawcrd
               SET crawcrd.dtaprova = pr_rw_crapdat.dtmvtolt
                  ,crawcrd.insitcrd = vr_insitcrd 
                  ,crawcrd.insitdec = vr_insitdec
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.inupgrad = 1  /* flag upgrade */
               AND crawcrd.cdadmcrd = rw_crawcrd.cdadmcrd /* adminstradora */
               AND crawcrd.nrcctitg = rw_crawcrd.nrcctitg /* mesma conta cartao */
               /* 1 - Sem aprovacao, 4 - Erro, 6 - Refazer */
               AND crawcrd.insitdec in (1,4,6);
               /* Cuidado para considerar as 5 - Rejeitada aqui tbm.
               Pode ser que existam outras propostas rejeitadas antigas
               que nao devam ser consideradas aqui. */
          EXCEPTION
            WHEN OTHERS THEN
              RAISE vr_exc_erro_500;
          END;
          
        ELSE

        /* pr_insitapr
         when  0 then 'NAO ANALISADO'
         when  1 then 'APROVADO'
         when  2 then 'NAO APROVADO'
         when  4 then 'REFAZER'
         when  3 then 'COM RESTRICAO'
         when 99 then 'EXPIRADO' */

                    
          -- Vamos verificar a situacao do retorno da esteira
          IF (pr_insitapr = 1) THEN
            -- Se for aprovado             
          
            -- Atualiza os dados da proposta do cartão
            BEGIN
              UPDATE crawcrd
                 SET crawcrd.dtaprova = pr_rw_crapdat.dtmvtolt
                    ,crawcrd.insitdec = 3 -- Aprovada Manual
               WHERE crawcrd.cdcooper = pr_cdcooper
                 AND crawcrd.nrdconta = pr_nrdconta
                 AND crawcrd.nrctrcrd = pr_nrctrcrd;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE vr_exc_erro_500;
            END;
            
            /* Para garantir que rollbacks dentro da solicitacao de cartao bcb
               nao cancelem a alteracao da crawcrd. */
            COMMIT;
          
            -- Envia para o Bancoob.
            BEGIN
              ccrd0007.pc_solicitar_cartao_bancoob_pl(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 1
                                     ,pr_cdoperad => 'ESTEIRA'
                                     ,pr_idorigem => 9
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctrcrd => pr_nrctrcrd
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic);
              
              IF pr_cdcritic > 0  OR TRIM(pr_dscritic) IS NOT NULL THEN
                -- Não vamos estourar a crítica do BCB para a esteira.
                pr_cdcritic := 0;
                pr_dscritic := '';
              END IF;
            EXCEPTION
              WHEN OTHERS THEN  
                 -- Não vamos estourar a crítica do BCB para a esteira.
                 pr_cdcritic := 0;
                 pr_dscritic := '';
            END;
            
              
          ELSIF (pr_insitapr = 2) THEN            
            -- Nao aprovado, vamos cancelar a proposta.
            
            -- Atualiza os dados da proposta do cartão
            BEGIN
              UPDATE crawcrd
                 SET crawcrd.dtaprova = pr_rw_crapdat.dtmvtolt
                    ,crawcrd.insitdec = 5 -- Rejeitada
                    ,crawcrd.insitcrd = 6 -- Cancelada
                    ,crawcrd.dtcancel = pr_rw_crapdat.dtmvtolt
                    ,crawcrd.flgprcrd = 0
               WHERE crawcrd.cdcooper = pr_cdcooper
                 AND crawcrd.nrdconta = pr_nrdconta
                 AND crawcrd.nrctrcrd = pr_nrctrcrd;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE vr_exc_erro_500;
            END;
            
          ELSIF(pr_insitapr = 4) THEN            
            -- Refazer, volta para "Em Estudo".
            BEGIN
              UPDATE crawcrd
                 SET crawcrd.dtaprova = pr_rw_crapdat.dtmvtolt
                    ,crawcrd.insitdec = 6 -- Refazer
                    ,crawcrd.insitcrd = 0 -- Em Estudo
               WHERE crawcrd.cdcooper = pr_cdcooper
                 AND crawcrd.nrdconta = pr_nrdconta
                 AND crawcrd.nrctrcrd = pr_nrctrcrd;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE vr_exc_erro_500;
            END;
          ELSE
            -- Se vier uma situacao desconhecida, consideraremos refazer.
            BEGIN
                UPDATE crawcrd
                   SET crawcrd.dtaprova = pr_rw_crapdat.dtmvtolt
                      ,crawcrd.insitdec = 6 -- Refazer
                      ,crawcrd.insitcrd = 0 -- Em Estudo
                 WHERE crawcrd.cdcooper = pr_cdcooper
                   AND crawcrd.nrdconta = pr_nrdconta
                   AND crawcrd.nrctrcrd = pr_nrctrcrd;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE vr_exc_erro_500;
              END;
          END IF;
        END IF;
      END IF;
      
      -- Gerar informaçoes do log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 'ESTEIRA'
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'AIMARO'
                          ,pr_dstransa => 'Parecer da proposta atualizado com sucesso'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> FALSE
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ESTEIRA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      IF pr_tpretest = 'E' THEN --Esteira
        IF nvl(rw_crawcrd_log.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crawcrd.dtaprova,to_date('01/01/1900','DD/MM/RRRR')) THEN
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'dtaprova'
                                   ,pr_dsdadant => rw_crawcrd_log.dtaprova
                                   ,pr_dsdadatu => rw_crawcrd.dtaprova);
        END IF;

        IF nvl(rw_crawcrd_log.insitdec,0) <> nvl(rw_crawcrd.insitdec,0) THEN
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'insitdec'
                                   ,pr_dsdadant => rw_crawcrd_log.insitdec
                                   ,pr_dsdadatu => rw_crawcrd.insitdec);
        END IF;
      END IF;

      IF nvl(rw_crapass_log.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) <> nvl(rw_crapass.dtdscore,to_date('01/01/1900','DD/MM/RRRR')) THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dtdscore'
                                 ,pr_dsdadant => rw_crapass_log.dtdscore
                                 ,pr_dsdadatu => rw_crapass.dtdscore);
      END IF;

      IF nvl(rw_crapass_log.dsdscore,' ') <> nvl(rw_crapass.dsdscore,' ') THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsdscore'
                                 ,pr_dsdadant => rw_crapass_log.dsdscore
                                 ,pr_dsdadatu => rw_crapass.dsdscore);
      END IF;

      IF nvl(rw_crapass_log.dsnivris,' ') <> nvl(rw_crapass.dsnivris,' ') THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'dsnivris'
                                 ,pr_dsdadant => rw_crapass_log.dsnivris
                                 ,pr_dsdadatu => rw_crapass.dsnivris);
      END IF;

      -- Caso nao ocorreu nenhum erro, vamos retorna como status de OK
      pr_status      := 202;
      pr_msg_detalhe := 'Parecer da proposta atualizado com sucesso.';
      pr_des_reto    := 'OK';
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_des_reto := 'NOK';
      WHEN vr_exc_erro_500 THEN
        ROLLBACK;
        pr_des_reto    := 'NOK';
        pr_status      := 500;
        pr_cdcritic    := 978;
        pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(1) ';

      WHEN OTHERS THEN
        ROLLBACK;
        pr_des_reto    := 'NOK';
        pr_status      := 500;
        pr_cdcritic    := 978;
        pr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(2):';

        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 3,
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - WEBS0001 --> Nao foi possivel atualizar retorno de proposta: '||SQLERRM,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
    END;

  END pc_atualiza_prop_srv_cartao;                           
                                           
  PROCEDURE pc_atuaretorn_proposta_esteira(pr_usuario  IN VARCHAR2              --> Usuario
                                          ,pr_senha    IN VARCHAR2              --> Senha
                                          ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
                                          ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                          ,pr_insitapr IN crawepr.insitapr%TYPE --> Situacao da proposta
                                          ,pr_dsobscmt IN crawepr.dsobscmt%TYPE --> Observação recebida da esteira de crédito
                                          ,pr_dsdscore IN crapass.dsdscore%TYPE --> Consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_dtdscore IN VARCHAR2              --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                          ,pr_tpprodut IN NUMBER                --> Tipo de Servico
                                          ,pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                          ,pr_namehost IN VARCHAR2              --> Host acionado pela Esteira
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
     Programa: pc_atuaretorn_proposta_esteira
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : James Prust Junior
     Data    : Janeiro/16.                    Ultima atualizacao: 31/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Identificar qual servico sera chamado para atualizar a proposta

     Observacao: -----
     
     Alteracoes: 22/03/2016 - Incluido log de acionamento 
                              PRJ207 - Esteira (Odirlei-AMcom)
                 
                 31/05/2016 - Incluido tratamento para monitoracao do serviço.
                              PRJ207 - Esteira (Odirlei-AMcom)          
     
                 27/02/2018 - Adaptado o procedimento pc_atuaretorn_proposta_esteira para utilização do limite de
                              desconto de títulos (Paulo Penteado (GFT))        
     
                 27/04/2018 - Adaptado o procedimento pc_atuaretorn_proposta_esteira para utilizaçao do Borderô de
                              desconto de títulos (Andrew Albuquerque (GFT))
     ..............................................................................*/
    DECLARE
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;    
      
      -- Tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_des_reto     VARCHAR2(3);
      vr_exc_saida    EXCEPTION;
      
      vr_dtdscore     crapass.dtdscore%TYPE;
      vr_chavereq     VARCHAR2(10000);      --> Cliente ID
      vr_chavecli     VARCHAR2(10000);      --> Cliente ID
      vr_nrtransacao  NUMBER(25) := 0;      --> Numero da transacao
      vr_status       PLS_INTEGER;          --> Status
      vr_msg_detalhe  VARCHAR2(10000);      --> Detalhe da mensagem    
      vr_dssitapr     VARCHAR2(50);
      vr_tpproduto    NUMBER;
      vr_nrctrprp     NUMBER(10);
      vr_nrctrest     NUMBER(10); --> usado para cartao de credito atualiza limite

      
      --Busca dados proposta alteração
      CURSOR cr_limatu IS
        SELECT nrctrcrd
              ,nrproposta_est
          FROM tbcrd_limite_atualiza
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrproposta_est = pr_nrctremp;
      rw_limatu cr_limatu%ROWTYPE;
    
    BEGIN
     
     -- Produto 999 = Monitoração do serviço
     IF pr_tpprodut = 999 THEN
       
       -- Apenas gerar retorno de sucesso para a esteira
       pc_gera_retor_proposta_esteira(pr_status      => 200  --> Status
                                     ,pr_nrtransacao => NULL --> Numero da transacao
                                     ,pr_cdcritic    => 0    --> Codigo da critica
                                     ,pr_dscritic    => 0    --> Descricao da critica
                                     ,pr_msg_detalhe => 'Monitoracao' --> Mensagem de detalhe
                                     ,pr_dtmvtolt    => NULL
                                     ,pr_retxml      => pr_retxml);  
       RETURN;
     END IF;
     
     -- 1 – Empréstimos/Financiamento 
     -- 2 – Desconto Cheques - Limite
     -- 3 – Desconto Títulos - Limite
     -- 4 – Cartão de Crédito
     -- 5 – Limite de Crédito
     -- 6 – Desconto Cheque – Borderô
     -- 7 – Desconto de Título – Borderô 

     if    pr_tpprodut = 1 then -- Proposta de Emprestimo
           vr_tpproduto := 0;
     elsif pr_tpprodut = 3 then -- Limite Desconto Titulo
           vr_tpproduto := 3;
     elsif pr_tpprodut = 4 then -- Cartão de Crédito
           vr_tpproduto := 4;
     elsif pr_tpprodut = 7 then -- Borderô de Desconto de Título
           vr_tpproduto := 7;
     end   if;

     select case pr_insitapr when  0 then 'NAO ANALISADO'
                             when  1 then 'APROVADO'
                             when  2 then 'NAO APROVADO'
                             when  4 then 'REFAZER'
                             when  3 then 'COM RESTRICAO'
                             when 99 then 'EXPIRADO'
                             else 'Desconhecida'
            end
     into   vr_dssitapr
     from   dual;
      
      --Se Cartão, verifica se é proposta de alteração de limite, então pega a proposta original para gerar os acionamentos
      IF vr_tpproduto = 4 THEN
        OPEN cr_limatu;
        FETCH cr_limatu INTO rw_limatu;
        IF cr_limatu%FOUND THEN
          CLOSE cr_limatu;
          vr_nrctrest := pr_nrctremp;
          vr_nrctrprp := rw_limatu.nrctrcrd;
        ELSE
          CLOSE cr_limatu;
          vr_nrctrprp := pr_nrctremp;
        END IF;
      ELSE
        vr_nrctrprp := pr_nrctremp;
      END IF;
      
      -- Para cada requisicao sera criado um numero de transacao
      WEBS0003.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                     pr_cdagenci                 => 1, 
                                     pr_cdoperad                 => 'ESTEIRA',
                                     pr_cdorigem                 => 9,
                                    pr_nrctrprp                 => vr_nrctrprp,
                                     pr_nrdconta                 => pr_nrdconta,
                                     pr_cdcliente                => 1,
                                     pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                     pr_dsoperacao               => 'RETORNO PROPOSTA - '||vr_dssitapr,
                                     pr_dsuriservico             => pr_namehost,
                                     pr_dsmetodo                 => 'PUT',
                                     pr_dtmvtolt                 => NULL,
                                     pr_cdstatus_http            => 0,
                                     pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                     pr_dsresposta_requisicao    => NULL,
                                     pr_flgreenvia               => 0,
                                     pr_nrreenvio                => 0,
                                     pr_tpconteudo               => 1,
                                     pr_tpproduto                => vr_tpproduto,
                                     pr_idacionamento            => vr_nrtransacao,
                                     pr_dscritic                 => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || vr_nrctrprp ||': '||SQLERRM,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                   
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(3)';
        RAISE vr_exc_saida;
      END IF; 
      
      --vr_nrtransacao := fn_sequence(pr_nmtabela => 'TBWBS_ESTEIRA', pr_nmdcampo => 'NRTRANSACAO',pr_dsdchave => pr_cdcooper);            
      vr_dscritic    := NULL;
      vr_dtdscore    := TO_DATE(pr_dtdscore,'DD/MM/RRRR');
      vr_chavecli    := utl_encode.text_encode(pr_usuario || ':' || pr_senha,'WE8ISO8859P1', UTL_ENCODE.BASE64);
      
      -- Vamos verificar a chave de acesso (Desenvolvimento/Producao)
      vr_chavereq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'IDWEBSRVICE_ESTEIRA_IBRA');
                                              
      -- Condicao para verificar se o cliente tem acesso
      IF vr_chavecli <> vr_chavereq THEN
        -- Montar mensagem de critica
        vr_status      := 403;
        vr_cdcritic    := 977;
        vr_msg_detalhe := 'Parecer nao foi atualizado, credenciais de acesso nao autorizada.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat
       INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(4)';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Condicao para verificar se o processo estah rodando
      IF NVL(rw_crapdat.inproces,0) <> 1 THEN
        -- Montar mensagem de critica
        vr_status      := 400;
        vr_cdcritic    := 138;
        vr_msg_detalhe := 'Parecer nao foi atualizado, o processo batch AILOS esta em execucao.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Proposta de Emprestimo
      IF pr_tpprodut = 1 THEN
        -- Atualiza os dados da proposta do servico 01
        pc_atualiza_prop_srv_emprestim(pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                      ,pr_nrdconta    => pr_nrdconta    --> Numero da conta
                                      ,pr_nrctremp    => vr_nrctrprp    --> Numero do contrato
																			,pr_tpretest    => 'E'            --> Tipo do retorno
                                      ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                      ,pr_insitapr    => pr_insitapr    --> Situacao da proposta
                                      ,pr_dsobscmt    => pr_dsobscmt    --> Observação recebida da esteira de crédito
                                      ,pr_dsdscore    => pr_dsdscore    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                      ,pr_dtdscore    => vr_dtdscore    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                      ,pr_status      => vr_status      --> Status
                                      ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                      ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                      ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                      ,pr_des_reto    => vr_des_reto);  --> Erros do processo
        RAISE vr_exc_saida;
        
     --    Limite Desconto Titulos   
     elsif pr_tpprodut = 3 then
           pc_atualiza_prop_srv_limdesct(pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                        ,pr_nrdconta    => pr_nrdconta    --> Numero da conta
                                        ,pr_nrctrlim    => vr_nrctrprp
                                        ,pr_tpctrlim    => vr_tpproduto
                                        ,pr_tpretest    => 'E'            --> Tipo do retorno
                                        ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                        ,pr_insitapr    => pr_insitapr    --> Situacao da proposta
                                        ,pr_dsobscmt    => pr_dsobscmt    --> Observação recebida da esteira de crédito
                                        ,pr_dsdscore    => pr_dsdscore    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                        ,pr_dtdscore    => vr_dtdscore    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                        ,pr_status      => vr_status      --> Status
                                        ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                        ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                        ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                        ,pr_des_reto    => vr_des_reto);  --> Erros do processo);
        RAISE vr_exc_saida;
     -- Cartão de Crédito
     elsif pr_tpprodut = 4 then
           pc_atualiza_prop_srv_cartao(pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                      ,pr_nrdconta    => pr_nrdconta    --> Numero da conta
                                      ,pr_nrctrcrd    => vr_nrctrprp    --> Numero do contrato
                                      ,pr_nrctrest    => vr_nrctrest    --> Numero contrato esteira limite credito
                                      ,pr_tpretest    => 'E'            --> Tipo do retorno
                                      ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                      ,pr_insitapr    => pr_insitapr    --> Situacao da proposta
                                      ,pr_dsdscore    => pr_dsdscore    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                      ,pr_dtdscore    => vr_dtdscore    --> Data da consulta do score feita na Boa Vista pela esteira de crédito
                                      ,pr_status      => vr_status      --> Status
                                      ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                      ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                      ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                      ,pr_des_reto    => vr_des_reto);  --> Erros do processo
        RAISE vr_exc_saida;

     --    Borderô de Desconto Titulos
     elsif pr_tpprodut = 7 then
            pc_atualiza_prop_srv_border (pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                        ,pr_nrdconta    => pr_nrdconta    --> Numero da conta
                                        ,pr_nrborder    => pr_nrctremp    --> Número do Borderô
                                        ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                        ,pr_insitapr    => pr_insitapr    --> Situacao da proposta
                                        ,pr_dsobscmt    => pr_dsobscmt    --> Observaçao recebida da esteira de crédito
                                        ,pr_dsdscore    => pr_dsdscore    --> Consulta do score feita na Boa Vista pela esteira de crédito
                                        ,pr_dtdscore    => vr_dtdscore    --> Data da consulta do score feita na Boa Vista pela esteira de crédito crédito
                                        ,pr_status      => vr_status      --> Status
                                        ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                        ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                        ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                        ,pr_des_reto    => vr_des_reto);  --> Erros do processo);
        RAISE vr_exc_saida;

      ELSE
        vr_status      := 202;
        vr_cdcritic    := 973;
        vr_msg_detalhe := 'Parecer nao foi atualizado, o tipo de produto nao foi implementado para a aprovacao pela esteira.';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        
        IF vr_nrtransacao = 0 THEN
          -- Para cada requisicao sera criado um numero de transacao
          WEBS0003.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                         pr_cdagenci                 => 1, 
                                         pr_cdoperad                 => 'ESTEIRA',
                                         pr_cdorigem                 => 9,
                                         pr_nrctrprp                 => vr_nrctrprp,
                                         pr_nrdconta                 => pr_nrdconta,
                                         pr_cdcliente                => 1,
                                         pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                         pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO PROPOSTA - '||vr_dssitapr,
                                         pr_dsuriservico             => NULL,
                                         pr_dsmetodo                 => NULL,
                                         pr_dtmvtolt                 => NULL,
                                         pr_cdstatus_http            => 0,
                                         pr_dsconteudo_requisicao    => NULL,
                                         pr_dsresposta_requisicao    => NULL,
                                         pr_flgreenvia               => 0,
                                         pr_nrreenvio                => 0,
                                         pr_tpconteudo               => 1,
										 pr_tpproduto                => vr_tpproduto,
                                         pr_idacionamento            => vr_nrtransacao,
                                         pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || vr_nrctrprp ||': '||SQLERRM,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));                        
          END IF;
        END IF;
        
        -- Gera retorno da proposta para a esteira
        pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                      ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                      ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                      ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                      ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                      ,pr_retxml      => pr_retxml);      
      WHEN OTHERS THEN
        
        IF vr_nrtransacao = 0 THEN
          -- Para cada requisicao sera criado um numero de transacao
          WEBS0003.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                         pr_cdagenci                 => 1, 
                                         pr_cdoperad                 => 'ESTEIRA',
                                         pr_cdorigem                 => 9,
                                         pr_nrctrprp                 => vr_nrctrprp,
                                         pr_nrdconta                 => pr_nrdconta,
                                         pr_cdcliente                => 1,
                                         pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                         pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO PROPOSTA - '||vr_dssitapr,
                                         pr_dsuriservico             => NULL,
                                         pr_dsmetodo                 => NULL,
                                         pr_dtmvtolt                 => NULL,
                                         pr_cdstatus_http            => 0,
                                         pr_dsconteudo_requisicao    => NULL,
                                         pr_dsresposta_requisicao    => NULL,
                                         pr_flgreenvia               => 0,
                                         pr_nrreenvio                => 0,
                                         pr_tpconteudo               => 1,
                                         pr_tpproduto                => vr_tpproduto,
                                         pr_idacionamento            => vr_nrtransacao,
                                         pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || vr_nrctrprp ||': '||SQLERRM,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));                        
          END IF;
        END IF;
        
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 3, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - WEBS0001 --> Nao foi possivel atualizar retorno de proposta ' || vr_nrtransacao ||': '||SQLERRM,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
        -- Gera retorno da proposta para a esteira
        pc_gera_retor_proposta_esteira(pr_status      => 500              --> Status
                                      ,pr_nrtransacao => vr_nrtransacao   --> Numero da transacao
                                      ,pr_cdcritic    => 978              --> Codigo da critica
                                      ,pr_msg_detalhe => 'Parecer nao foi atualizado, ocorreu uma erro interno no sistema.(5)'
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                      ,pr_retxml      => pr_retxml);
    END;                            
      
  END pc_atuaretorn_proposta_esteira;
  
  PROCEDURE pc_grava_requisicao_erro(pr_dsrequis IN VARCHAR2              --> Requisicao de entrada em json 
                                    ,pr_dsmessag IN VARCHAR2              --> Descricao da mensagem de erro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo  
  BEGIN
    /* .............................................................................
     Programa: pc_grava_requisicao_erro
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : James Prust Junior
     Data    : Abril/16.                    Ultima atualizacao: 26/06/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gravar mensagem de erro no LOG

     Observacao: 
     
     Alteracoes: 26/06/2019 - Restringir o tamanho da mensagem de log em 3850 caracteres,
                              isso porque dentro do btch0001.pc_gera_log_batch são concatenados
                              mais alguns caracteres (PRB0041610 - AJFink)     

     ..............................................................................*/
    DECLARE
      vr_des_log        VARCHAR2(4000);      
      vr_dsdirlog       VARCHAR2(100);
    BEGIN
      -- Diretorio do arquivo      
      vr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => 'log/webservices');      
      -- Mensagem de LOG
      vr_des_log  := trim(substr(trim(TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                     ' - ' || 
                     'Requisicao: ' || pr_dsrequis  || 
                     ' - ' || 
                                      'Resposta: ' || pr_dsmessag),1,3850)); --PRB0041610
                     
      -- Criacao do arquivo
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => DBMS_XMLGEN.CONVERT(vr_des_log, DBMS_XMLGEN.ENTITY_DECODE)
                                ,pr_nmarqlog     => 'esteira-' || TO_CHAR(SYSDATE,'DD-MM-RRRR')
                                ,pr_dsdirlog     => vr_dsdirlog);
                                
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    END;                            
      
  END pc_grava_requisicao_erro;
             
	PROCEDURE pc_retorno_analise_proposta(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
																			 ,pr_dsprotoc IN VARCHAR2              --> Protocolo da análise
																			 ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
																			 ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                       ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
																			 ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
																		 	 ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
																		 	 ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
																		 	 ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                       ,pr_inopeatr IN NUMBER                --> Contem o identificador da operacao de credito em atraso que vai para esteira
																			 ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
																			 ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
																			 ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
																			 ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
																			 ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
																			 ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                       ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado --P637                                                                              
																			 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
																			 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																			 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																			 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																			 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
	/* .............................................................................
	 Programa: pc_retorno_analise_proposta
	 Sistema : Rotinas referentes ao WebService
	 Sigla   : WEBS
	 Autor   : Lucas Reinert
   Data    : Maio/17.                    Ultima atualizacao: 01/08/2018

	 Dados referentes ao programa:

	 Frequencia: Sempre que for chamado

	 Objetivo  : Receber as informações da análise automática da Esteira e gravar 
	             na base

	 Observacao: -----
     
	 Alteracoes:  15/12/2017 - P337 - SM - Acionar nova rotina Derivação (Marcos-Supero)
        
                  01/08/2018 - P450 - Incluir novo campo liquidOpCredAtraso no retorno do 
                               motor de credito - Diego Simas (AMcom)              
        
                  21/11/2017 - Alterações referente ao Prj. 402 (Jean Michel).           
                  
                  12/03/2019 - P438 (AMcom) Add sub-rotina pc_notifica_ib

				  29/04/2019 - P438 Tratativa para agencia quando for origem 3. (Douglas Pagel / AMcom)
          
	 ..............................................................................*/	
		DECLARE
		  -- Tratamento de críticas
			vr_exc_saida EXCEPTION;
			vr_cdcritic PLS_INTEGER;
			vr_dscritic VARCHAR2(4000);
			vr_des_reto VARCHAR2(10);
			
			-- Variáveis auxiliares
		  vr_msg_detalhe  VARCHAR2(10000);      --> Detalhe da mensagem    
      vr_status       PLS_INTEGER;          --> Status
			vr_dssitret     VARCHAR2(100);        --> Situação de retorno
      vr_nrtransacao  NUMBER(25) := 0;      --> Numero da transacao	
			vr_inpessoa     PLS_INTEGER := 0;     --> 1 - PF/ 2 - PJ		
			vr_insitapr     crawepr.insitapr%TYPE; --> Situacao Aprovacao(0-Em estudo/1-Aprovado/2-Nao aprovado/3-Restricao/4-Refazer)
			
      -- Acionamento 
      CURSOR cr_aciona IS
        SELECT aci.cdcooper    
              ,aci.nrdconta    
              ,aci.nrctrprp    nrctremp
              ,aci.dsprotocolo dsprotoc
          FROM tbgen_webservice_aciona aci
         WHERE aci.dsprotocolo   = pr_dsprotoc
           AND aci.tpacionamento = 1; /*Envio*/
      rw_aciona cr_aciona%ROWTYPE;
      
		  -- Buscar a proposta de empréstimo vinculada ao protocolo
		  CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE
                       ,pr_nrdconta crawepr.nrdconta%TYPE
                       ,pr_nrctremp crawepr.nrctremp%TYPE) IS
			  SELECT wpr.cdcooper
              ,wpr.nrdconta
              ,wpr.nrctremp
              ,DECODE(wpr.cdorigem, 3, ass.cdagenci, wpr.cdagenci) cdagenci
              ,wpr.cdopeste
              ,wpr.insitest
              ,decode(wpr.insitapr, 0, 'EM ESTUDO', 1, 'APROVADO', 2, 'NAO APROVADO', 3, 'RESTRICAO', 4, 'REFAZER', 'SITUACAO DESCONHECIDA') dssitapr
              ,wpr.rowid
              ,wpr.cdorigem
          FROM crawepr wpr
              ,crapass ass
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp
           AND wpr.dsprotoc = pr_dsprotoc
           AND ass.cdcooper = wpr.cdcooper
           AND ass.nrdconta = wpr.nrdconta/*
           FOR UPDATE*/;  
		  rw_crawepr cr_crawepr%ROWTYPE;
			
			-- Buscar o tipo de pessoa que contratou o empréstimo
			CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
			                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
				SELECT ass.inpessoa
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			
			rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
      -- Variaveis temp para ajuste valores recebidos nos indicadores
      vr_indrisco VARCHAR2(100); --> Nível do risco calculado para a operação
			vr_nrnotrat VARCHAR2(100); --> Valor do rating calculado para a operação
			vr_nrinfcad VARCHAR2(100); --> Valor do item Informações Cadastrais calculado no Rating
			vr_nrliquid VARCHAR2(100); --> Valor do item Liquidez calculado no Rating
			vr_nrgarope VARCHAR2(100); --> Valor das Garantias calculada no Rating
      vr_inopeatr VARCHAR2(100); --> Identificador da operacao de credito em atraso
			vr_nrparlvr VARCHAR2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
			vr_nrperger VARCHAR2(100); --> Valor da Percepção Geral da Empresa calculada no Rating
      vr_desscore VARCHAR2(100); --> Descricao do Score Boa Vista
      vr_datscore VARCHAR2(100); --> Data do Score Boa Vista
      vr_idfluata BOOLEAN;       --> Segue Fluxo Atacado --P637
      
      -- Bloco PLSQL para chamar a execução paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Job name dos processos criados
      vr_jobname VARCHAR2(100);
      
      -- Variaveis para DEBUG
      vr_flgdebug VARCHAR2(100) := 'S';
      vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
      
           
      -- Função para verificar se parâmetro passado é numérico
			FUNCTION fn_is_number(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
			BEGIN
			  IF TRIM(gene0002.fn_char_para_number(pr_vlparam)) IS NULL THEN
          RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;  
			EXCEPTION
				WHEN OTHERS THEN
					RETURN FALSE;
			END fn_is_number;
      
   -- Função para verificar se parâmetro passado é Data
      FUNCTION fn_is_date(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
        vr_data date;
      BEGIN
        vr_data := TO_DATE(pr_vlparam,'RRRRMMDD');
        IF vr_data IS NULL THEN 
          RETURN FALSE;
        ELSE
          RETURN TRUE;  
        END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
      END fn_is_date;
      
   -- Função para trocar o litereal "null" por null
      FUNCTION fn_converte_null(pr_dsvaltxt IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        IF pr_dsvaltxt = 'null' THEN
          RETURN NULL;
        ELSE
          RETURN pr_dsvaltxt;
        END IF;
      END;
											 
		BEGIN
    
     -- Produto 999 = Monitoração do serviço
     IF pr_dsprotoc = 'PoliticaGeralMonitoramento' THEN
       
       -- Apenas gerar retorno de sucesso para a esteira
       pc_gera_retor_proposta_esteira(pr_status      => 200  --> Status
                                     ,pr_nrtransacao => NULL --> Numero da transacao
                                     ,pr_cdcritic    => 0    --> Codigo da critica
                                     ,pr_dscritic    => 0    --> Descricao da critica
                                     ,pr_msg_detalhe => 'Monitoracao' --> Mensagem de detalhe
                                     ,pr_dtmvtolt    => NULL
                                     ,pr_retxml      => pr_retxml);  
       RETURN;
     END IF;    
    
      -- Se o acionamento já foi gravado na origem
      IF nvl(pr_nrtransa,0) > 0 THEN
        vr_nrtransacao := pr_nrtransa;
      END IF;  
      
      -- Acionamento 
      OPEN cr_aciona;
     FETCH cr_aciona 
	  INTO rw_aciona;
      CLOSE cr_aciona; 
      
			-- Buscar a proposta de empréstimo a partir do protocolo
			OPEN cr_crawepr(rw_aciona.cdcooper
                     ,rw_aciona.nrdconta
                     ,rw_aciona.nrctremp);
			FETCH cr_crawepr INTO rw_crawepr;
			
      -- Se não encontrou a proposta
			IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
				btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
																	 pr_ind_tipo_log => 2, 
																	 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
																									 ||' - WEBS0001 --> Erro ao gravar resultado da analise automatica '
																									 ||'de proposta – Procolo '||pr_dsprotoc||' inexistente',                     
																	 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
																														                    pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Resultado Analise Automatica nao foi atualizado, ocorreu '
                       || 'erro interno no Sistema(1).';
        RAISE vr_exc_saida;
			END IF;
      CLOSE cr_crawepr;
      
      -- Verificar se o DEBUG está ativo
      vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crawepr.cdcooper,'DEBUG_MOTOR_IBRA');
      
      -- Se o DEBUG estiver habilitado
      IF vr_flgdebug = 'S' THEN
        --> Gravar dados log acionamento
        WEBS0003.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                      pr_cdagenci              => 1,          
                                      pr_cdoperad              => 'MOTOR',          
                                      pr_cdorigem              => pr_cdorigem,          
                                      pr_nrctrprp              => rw_crawepr.nrctremp,      
                                      pr_nrdconta              => rw_crawepr.nrdconta,  
                                      pr_cdcliente             => 1,
                                      pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                      pr_dsoperacao            => 'INICIO RETORNO ANALISE',       
                                      pr_dsuriservico          => pr_namehost,       
                                      pr_dsmetodo              => 'PUT',
                                      pr_dtmvtolt              => trunc(sysdate),       
                                      pr_cdstatus_http         => 0,
                                      pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao => null,
                                      pr_flgreenvia            => 0,
                                      pr_nrreenvio             => 0,
                                      pr_tpconteudo            => 1,
                                      pr_tpproduto             => 0,
                                      pr_dsprotocolo           => pr_dsprotoc,
                                      pr_idacionamento         => vr_idaciona,
                                      pr_dscritic              => vr_dscritic);
        -- Sem tratamento de exceção para DEBUG                    
        --IF TRIM(vr_dscritic) IS NOT NULL THEN
        --  RAISE vr_exc_erro;
        --END IF;
      END IF; 
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crawepr.cdcooper);
      FETCH BTCH0001.cr_crapdat
       INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno
                           no sistema(2)';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
			-- Montar a mensagem que será gravada no acionamento
      CASE lower(pr_dsresana)
        WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
        WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
        WHEN 'derivar'  THEN vr_dssitret := 'ANALISAR MANUAL';
        WHEN 'erro'     THEN vr_dssitret := 'ERRO';
        ELSE vr_dssitret := 'DESCONHECIDA';
      END CASE;
		
      -- Se o acionamento ainda não foi gravado
      IF vr_nrtransacao = 0 THEN 				
        -- Gravar o acionamento 
        WEBS0003.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
                                      pr_cdagenci                 => 1, 
                                      pr_cdoperad                 => 'MOTOR',
                                      pr_cdorigem                 => pr_cdorigem,
                                      pr_nrctrprp                 => rw_crawepr.nrctremp,
                                      pr_nrdconta                 => rw_crawepr.nrdconta,
                                      pr_cdcliente                => 1,
                                      pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                      pr_dsoperacao               => 'RETORNO ANALISE AUTOMATICA - '||vr_dssitret,
                                      pr_dsuriservico             => pr_namehost,
                                      pr_dsmetodo                 => 'PUT',
                                      pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
                                      pr_cdstatus_http            => 200,
                                      pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao    => vr_dssitret,
                                      pr_dsprotocolo              => pr_dsprotoc,
                                      pr_flgreenvia               => 0,
                                      pr_nrreenvio                => 0,
                                      pr_tpconteudo               => 1,
                                      pr_tpproduto                => 0,
                                      pr_idacionamento            => vr_nrtransacao,
                                      pr_dscritic                 => vr_dscritic);
        -- Se retornou crítica
        IF vr_dscritic IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2, 
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                     || ' - WEBS0001 --> Erro ao gravar acionamento para conta '
                                                     ||rw_crawepr.nrdconta||' contrato' || rw_crawepr.nrctremp 
                                                     ||': '||vr_dscritic,
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                  pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu uma erro '
                         || 'interno no sistema(3).';
          RAISE vr_exc_saida;
        END IF; 

	    END IF;
      
      -- Condicao para verificar se o processo esta rodando
      IF NVL(rw_crapdat.inproces,0) <> 1 THEN
        -- Montar mensagem de critica
        vr_status      := 400;
        vr_cdcritic    := 138;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, o processo batch '
                       || 'AILOS esta em execucao.';
        RAISE vr_exc_saida;
      END IF;	
      
      -- Somente se a proposta não foi atualizada ainda
      IF rw_crawepr.insitest <> 1 THEN
        -- Montar mensagem de critica
        vr_status      := 400;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Situacao da Proposta jah foi alterada - analise nao sera recebida.';
        RAISE vr_exc_saida;        
      END IF;		
			
      -- Se algum dos parâmetros abaixo não foram informados
			IF nvl(pr_cdorigem, 0) = 0 OR
				 TRIM(pr_dsprotoc) IS NULL OR
				 TRIM(pr_dsresana) IS NULL THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                       || 'erro interno no sistema(4)';
        RAISE vr_exc_saida;
		  END IF;
			
			-- Se os parâmetros abaixo possuirem algum valor diferente do verificado
			IF NOT pr_cdorigem IN(5,9) OR 
				 NOT lower(pr_dsresana) IN('aprovar', 'reprovar', 'derivar', 'erro') THEN
				 -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                       || 'erro interno no sistema(5)';
        RAISE vr_exc_saida;
			END IF;
			
      -- Copia dos valores dos parâmetros para variaveis já corrigindo
      -- possiveis problemas com a vinda de parâmetros "null"
      vr_indrisco := fn_converte_null(pr_indrisco);
      vr_inopeatr := fn_converte_null(pr_inopeatr);
      vr_nrnotrat := fn_converte_null(pr_nrnotrat);
      vr_nrinfcad := fn_converte_null(pr_nrinfcad);
      vr_nrliquid := fn_converte_null(pr_nrliquid);
      vr_nrgarope := fn_converte_null(pr_nrgarope);
      vr_nrparlvr := fn_converte_null(pr_nrparlvr);
      vr_nrperger := fn_converte_null(pr_nrperger);
      vr_desscore := fn_converte_null(pr_desscore);
      vr_datscore := fn_converte_null(pr_datscore);
      vr_idfluata := pr_idfluata; --PJ637
      
			-- Buscar o tipo de pessoa
			OPEN cr_crapass(pr_cdcooper => rw_crawepr.cdcooper
			               ,pr_nrdconta => rw_crawepr.nrdconta);
			FETCH cr_crapass INTO vr_inpessoa;
			CLOSE cr_crapass;
      
			IF lower(pr_dsresana) IN ('aprovar', 'reprovar', 'derivar') THEN
        -- NEste caso testes retornos obrigatórios
        IF (TRIM(vr_indrisco) IS NULL OR
            TRIM(vr_inopeatr) IS NULL OR
				 TRIM(vr_nrnotrat) IS NULL OR
				 TRIM(vr_nrinfcad) IS NULL OR
				 TRIM(vr_nrliquid) IS NULL OR
				 TRIM(vr_nrgarope) IS NULL OR
				 TRIM(vr_nrparlvr) IS NULL OR
				(TRIM(vr_nrperger) IS NULL AND vr_inpessoa = 2)) THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                         || 'erro interno no sistema(6)';
          RAISE vr_exc_saida;
        END IF;
        
        -- Se risco não for um dos verificados abaixo
        IF NOT pr_indrisco IN('AA','A','B','C','D','E','F','G','H') THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                         || 'erro interno no sistema(7)';
          RAISE vr_exc_saida;
        END IF;
        
        -- Se algum dos parâmetros abaixo não forem números
        IF NOT fn_is_number(vr_nrnotrat) OR
           NOT fn_is_number(vr_nrinfcad) OR
           NOT fn_is_number(vr_inopeatr) OR
           NOT fn_is_number(vr_nrliquid) OR
           NOT fn_is_number(vr_nrgarope) OR
           NOT fn_is_number(vr_nrparlvr) OR
           (NOT fn_is_number(vr_nrperger) AND vr_inpessoa = 2 ) THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                         || 'erro interno no sistema(8)';
          RAISE vr_exc_saida;
        END IF;
        
        -- Se nao for uma data valida
        IF vr_datscore IS NOT NULL AND NOT fn_is_date(vr_datscore) THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                         || 'erro interno no sistema(9)';
          RAISE vr_exc_saida;
        END IF;
        
		  END IF;
			
			-- Tratar status
      IF lower(pr_dsresana) = 'aprovar' THEN
			  vr_insitapr := 1; -- Aprovado
			ELSIF lower(pr_dsresana) = 'reprovar' THEN
				vr_insitapr := 2; -- Reprovado
      ELSIF lower(pr_dsresana) = 'derivar' THEN
        vr_insitapr := 5; -- Derivada
      ELSE
        vr_insitapr := 6; -- Erro
			END IF;
        
			-- Atualizar proposta de empréstimo
      pc_atualiza_prop_srv_emprestim(pr_cdcooper    => rw_crawepr.cdcooper --> Codigo da cooperativa
																		,pr_nrdconta    => rw_crawepr.nrdconta --> Numero da conta
																		,pr_nrctremp    => rw_crawepr.nrctremp --> Numero do contrato
																		,pr_tpretest    => 'M'            --> Retorno Motor  
																		,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
																		,pr_insitapr    => vr_insitapr    --> Situação da Aprovação
																		,pr_indrisco    => vr_indrisco    --> Nível do Risco calculado na Analise 
                                    ,pr_inopeatr    => vr_inopeatr         --> Identificador da operacao de credito em atraso
																		,pr_nrnotrat    => gene0002.fn_char_para_number(vr_nrnotrat)    --> Calculo do Rating na Analise 
																		,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informação Cadastral da Analise 
																		,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise 
																		,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise 
																		,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise 
																		,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepção Geral Empresa na Analise 
																		,pr_dsdscore    => vr_desscore    --> Descrição Score Boa Vista
																		,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD')    --> Data Score Boa Vista
                                    ,pr_flgpreap    => 0                                  --> Indicador de Pré Aprovado
                                    ,pr_idfluata    => vr_idfluata    --> Indicador Segue Fluxo Atacado --P637                                    
																		,pr_status      => vr_status      --> Status
																		,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
																		,pr_dscritic    => vr_dscritic    --> Descricao da critica
																		,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
																		,pr_des_reto    => vr_des_reto);  --> Erros do processo
			
      -- Gera retorno da proposta para a esteira
      pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                    ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                    ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                    ,pr_dscritic    => vr_dscritic    --> Descricao critica  
                                    ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                    ,pr_retxml      => pr_retxml);    
      -- Se o DEBUG estiver habilitado
      IF vr_flgdebug = 'S' THEN
        --> Gravar dados log acionamento
        WEBS0003.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                      pr_cdagenci              => 1,          
                                      pr_cdoperad              => 'MOTOR',          
                                      pr_cdorigem              => pr_cdorigem,          
                                      pr_nrctrprp              => rw_crawepr.nrctremp,      
                                      pr_nrdconta              => rw_crawepr.nrdconta,  
                                      pr_cdcliente             => 1,  
                                      pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                      pr_dsoperacao            => 'FINAL RETORNO ANALISE',       
                                      pr_dsuriservico          => pr_namehost,       
                                      pr_dsmetodo              => 'PUT',
                                      pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                      pr_cdstatus_http         => 0,
                                      pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao => null,
                                      pr_flgreenvia            => 0,
                                      pr_nrreenvio             => 0,
                                      pr_tpconteudo            => 1,
                                      pr_tpproduto             => 0,
                                      pr_dsprotocolo           => pr_dsprotoc,
                                      pr_idacionamento         => vr_idaciona,
                                      pr_dscritic              => vr_dscritic);
        -- Sem tratamento de exceção para DEBUG                    
        --IF TRIM(vr_dscritic) IS NOT NULL THEN
        --  RAISE vr_exc_erro;
        --END IF;
      END IF; 
      
      -- Caso nao tenha havido erro na atualizado 
			IF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL AND TRIM(pr_dsprotoc) IS NOT NULL THEN 
      
        -- Se resultado da análise não retornou erro
        IF lower(pr_dsresana) <> 'erro' THEN
          -- Acionar rotina para processamento consultas automatizadas
          SSPC0001.pc_retorna_conaut_esteira(rw_crawepr.cdcooper
                                            ,rw_crawepr.nrdconta
                                            ,rw_crawepr.nrctremp
                                            ,pr_dsprotoc
                                            ,vr_cdcritic
                                            ,vr_dscritic);
          -- Em caso de erro 
          IF vr_dscritic IS NOT NULL THEN 
            -- Adicionar ao LOG e continuar o processo
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2,
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                       || ' - WEBS0001 --> Erro ao solicitor retorno nas '
                                                       || 'Consulta Automaticas do Protocolo: '||pr_dsprotoc
                                                       || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
          END IF;
          -- Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            WEBS0003.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                          pr_cdagenci              => 1,          
                                          pr_cdoperad              => 'MOTOR',          
                                          pr_cdorigem              => pr_cdorigem,          
                                          pr_nrctrprp              => rw_crawepr.nrctremp,      
                                          pr_nrdconta              => rw_crawepr.nrdconta,  
                                          pr_cdcliente             => 1,
                                          pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                          pr_dsoperacao            => 'FINAL RETORNO CONAUT',       
                                          pr_dsuriservico          => pr_namehost,       
                                          pr_dsmetodo              => 'PUT',      
                                          pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                          pr_cdstatus_http         => 0,
                                          pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                          pr_dsresposta_requisicao => null,
                                          pr_flgreenvia            => 0,
                                          pr_nrreenvio             => 0,
                                          pr_tpconteudo            => 1,
                                          pr_tpproduto             => 0,
                                          pr_dsprotocolo           => pr_dsprotoc,
                                          pr_idacionamento         => vr_idaciona,
                                          pr_dscritic              => vr_dscritic);
            -- Sem tratamento de exceção para DEBUG                    
            --IF TRIM(vr_dscritic) IS NOT NULL THEN
            --  RAISE vr_exc_erro;
            --END IF;
          END IF;
        END IF;
        
        -- Caso seja derivação
        IF lower(pr_dsresana) = 'derivar' THEN
          -- Acionar rotina para derivação automatica em  paralelo
          vr_dsplsql := 'DECLARE'||chr(13)
                     || '  vr_dsmensag VARCHAR2(4000);'||chr(13)
                     || '  vr_cdcritic NUMBER;'||chr(13)
                     || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                     || 'BEGIN'||chr(13)
                     || '  ESTE0001.pc_derivar_proposta_est(pr_cdcooper => '||rw_crawepr.cdcooper ||chr(13)
                     || '                                ,pr_cdagenci => '||rw_crawepr.cdagenci ||chr(13)
                     || '                                ,pr_cdoperad => '''||rw_crawepr.cdopeste||''''||chr(13)
                     || '                                ,pr_cdorigem => 9'                    ||chr(13)
                     || '                                ,pr_nrdconta => '||rw_crawepr.nrdconta ||chr(13)
                     || '                                ,pr_nrctremp => '||rw_crawepr.nrctremp ||chr(13)
                     || '                                  ,pr_dtmvtolt => to_date('''||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr''));'||chr(13)
                     || 'END;';
                     
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := 'JBEPR_DRMT_$';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => rw_crawepr.cdcooper  --> Código da cooperativa
                                ,pr_cdprogra  => 'ATENDA'     --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva   => null         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Adicionar ao LOG e continuar o processo
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                       || ' - WEBS0001 --> Erro ao solicitor derivação '
                                                       || ' Automatica do Protocolo: '||pr_dsprotoc
                                                       || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                    pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
          END IF; 
        END IF; 
      END IF;      
      
      -- Gravar
      COMMIT;                                 
			
		EXCEPTION
			WHEN vr_exc_saida THEN
        -- Se ainda nao houve geracao id Acionamento
        IF vr_nrtransacao = 0 AND rw_crawepr.nrdconta IS NOT NULL THEN
          -- Para cada requisicao sera criado um numero de transacao
          WEBS0003.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
																				pr_cdagenci                 => 1, 
																				pr_cdoperad                 => 'MOTOR',
																				pr_cdorigem                 => 9,
																				pr_nrctrprp                 => rw_crawepr.nrctremp,
																				pr_nrdconta                 => rw_crawepr.nrdconta,
                                        pr_cdcliente                => 1,
																				pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
																				pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE AUTO – '
																																		||rw_crawepr.dssitapr,
																				pr_dsuriservico             => pr_namehost,
                                        pr_dsmetodo                 => 'PUT',
																				pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
																				pr_cdstatus_http            => 0,
																				pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
																				pr_dsresposta_requisicao    => NULL,
                                        pr_flgreenvia               => 0,
                                        pr_nrreenvio                => 0,
                                        pr_tpconteudo               => 1,
                                        pr_tpproduto                => 0,
																				pr_idacionamento            => vr_nrtransacao,
																				pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
																			 pr_ind_tipo_log => 2, 
																			 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
																											 || ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise ' 
																											 || ' para conta '|| rw_crawepr.nrdconta||' contrato ' 
																											 || rw_crawepr.nrctremp ||': '||SQLERRM,
																			 pr_nmarqlog     => gene0001.fn_param_sistema
																															(pr_nmsistem => 'CRED',
																															 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));                        
          END IF;
        END IF;
        
        -- Mudaremos a situação da analise para encerrada com erro para que possa haver o Re-envio
        IF rw_crawepr.rowid IS NOT NULL THEN 
          BEGIN
            UPDATE crawepr
               SET crawepr.insitapr = 6 -- Erro
                  ,crawepr.cdopeapr = 'MOTOR'
                  ,crawepr.dtaprova = rw_crapdat.dtmvtolt
                  ,crawepr.hraprova = gene0002.fn_busca_time
                  ,crawepr.cdcomite = 3
                  ,crawepr.insitest = 3 -- Finalizada
             WHERE crawepr.rowid = rw_crawepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := vr_dscritic || ' e erro na atualiza Proposta: '||sqlerrm;
          END; 
        END IF;  

        -- Gera retorno da proposta para a esteira
        pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                      ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                      ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                      ,pr_dscritic    => vr_dscritic    --> Descricao critica  
                                      ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                      ,pr_retxml      => pr_retxml);    
        -- Gravar
        COMMIT;                                        
      WHEN OTHERS THEN
        -- Se ainda nao houve geracao id Acionamento
        IF vr_nrtransacao = 0 AND rw_crawepr.nrdconta IS NOT NULL THEN
          -- Para cada requisicao sera criado um numero de transacao
          WEBS0003.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
																				pr_cdagenci                 => 1, 
																				pr_cdoperad                 => 'MOTOR',
																				pr_cdorigem                 => 9,
																				pr_nrctrprp                 => rw_crawepr.nrctremp,
																				pr_nrdconta                 => rw_crawepr.nrdconta,
                                        pr_cdcliente                => 1,
																				pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
																				pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE '
																																		|| 'PROPOSTA - '||rw_crawepr.dssitapr,
																				pr_dsuriservico             => pr_namehost,
                                        pr_dsmetodo                 => 'PUT',
																				pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
																				pr_cdstatus_http            => 0,
																				pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
																				pr_dsresposta_requisicao    => NULL,
                                        pr_flgreenvia               => 0,
                                        pr_nrreenvio                => 0,
                                        pr_tpconteudo               => 1,
                                        pr_tpproduto                => 0,
																				pr_idacionamento            => vr_nrtransacao,
																				pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
																			 pr_ind_tipo_log => 2, 
																			 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
																											 || ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise' 
																											 || ' para conta ' || rw_crawepr.nrdconta||' contrato' 
																											 || rw_crawepr.nrctremp ||': '||SQLERRM,
																			 pr_nmarqlog     => gene0001.fn_param_sistema
																															(pr_nmsistem => 'CRED', 
																															 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));                        
          END IF;
        END IF; 
        
        -- Mudaremos a situação da analise para encerrada com erro para que possa haver o Re-envio
        IF rw_crawepr.rowid IS NOT NULL THEN 
          BEGIN
            UPDATE crawepr
               SET crawepr.insitapr = 6 -- Erro
                  ,crawepr.cdopeapr = 'MOTOR'
                  ,crawepr.dtaprova = rw_crapdat.dtmvtolt
                  ,crawepr.hraprova = gene0002.fn_busca_time
                  ,crawepr.cdcomite = 3
                  ,crawepr.insitest = 3 -- Finalizada
             WHERE crawepr.rowid = rw_crawepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := vr_dscritic || ' e erro na atualiza Proposta: '||sqlerrm;
          END; 
        END IF;  

        -- Somente se ocorreu encontro da proposta
        pc_gera_retor_proposta_esteira(pr_status      => 500              --> Status
                                      ,pr_nrtransacao => vr_nrtransacao   --> Numero transacao
                                      ,pr_cdcritic    => 978              --> Codigo da critica
                                      ,pr_msg_detalhe => 'Retorno Analise Automatica '
                                                      || 'nao foi atualizado, ocorreu '
                                                      || 'uma erro interno no sistema.(9)'
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                      ,pr_retxml      => pr_retxml);
                                      
        -- Enviar LOG geral, independente de ter encontro de proposta 
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
																	 pr_ind_tipo_log => 3, 
																	 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
																										|| ' - WEBS0001 --> Nao foi possivel atualizar retorno da Analise '
																										|| 'Automatica da proposta ' || vr_nrtransacao ||': '||SQLERRM,
																	 pr_nmarqlog     => gene0001.fn_param_sistema
																													(pr_nmsistem => 'CRED', 
																													 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));        
       -- Gravar
       COMMIT;
    END;      
  END pc_retorno_analise_proposta;	                                                     	
             
  PROCEDURE pc_retorno_analise_limdesct
                    (pr_cdorigem in number             --> Origem da Requisição (9-Esteira ou 5-Ayllos)
					,pr_dsprotoc in varchar2           --> Protocolo da análise
					,pr_nrtransa in number             --> Transacao do acionamento
                    ,pr_dsresana in varchar2           --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                    ,pr_indrisco in varchar2           --> Nível do risco calculado para a operação
                    ,pr_nrnotrat in varchar2           --> Valor do rating calculado para a operação
                    ,pr_nrinfcad in varchar2           --> Valor do item Informações Cadastrais calculado no Rating
					,pr_nrliquid in varchar2           --> Valor do item Liquidez calculado no Rating
					,pr_nrgarope in varchar2           --> Valor das Garantias calculada no Rating
					,pr_nrparlvr in varchar2           --> Valor do Patrimônio Pessoal Livre calculado no Rating
                    ,pr_nrperger in varchar2           --> Valor da Percepção Geral da Empresa calculada no Rating
                    ,pr_desscore in varchar2           --> Descrição do Score Boa Vista
					,pr_datscore in varchar2           --> Data do Score Boa Vista
                    ,pr_dsrequis in varchar2           --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                    ,pr_namehost in varchar2           --> Nome do host oriundo da requisição da Análise Automática na Esteira
                    ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado --P637                    
                    ,pr_xmllog   in varchar2           --> XML com informações de LOG
					,pr_cdcritic out pls_integer       --> Código da crítica
                    ,pr_dscritic out varchar2          --> Descrição da crítica
					,pr_retxml   in out nocopy xmltype --> Arquivo de retorno do XML
					,pr_nmdcampo out varchar2          --> Nome do campo com erro
					,pr_des_erro out varchar2          --> Erros do processo
                    ) is
  BEGIN
	 /* .............................................................................
	 Programa: pc_retorno_analise_limdesct
	 Sistema : Rotinas referentes ao WebService
	 Sigla   : WEBS
	 Autor   : Paulo Penteado (GFT) 
	 Data    : Fevereiro/2018.                    Ultima atualizacao: 27/02/2018

	 Dados referentes ao programa:

	 Frequencia: Sempre que for chamado

   Objetivo  : Receber as informações da análise automática da Esteira e gravar 
	             na base

   Alteracoes:  27/02/2018 Criação (Paulo Penteado (GFT))
          
	 ..............................................................................*/	
  DECLARE
     -- Tratamento de críticas
     vr_exc_saida exception;
     vr_cdcritic pls_integer;
     vr_dscritic varchar2(4000);
     vr_des_reto varchar2(10);
  			
     -- Variáveis auxiliares
     vr_msg_detalhe  varchar2(10000);      --> Detalhe da mensagem    
     vr_status       pls_integer;          --> Status
     vr_dssitret     varchar2(100);        --> Situação de retorno
     vr_nrtransacao  number(25) := 0;      --> Numero da transacao	
     vr_inpessoa     pls_integer := 0;     --> 1 - PF/ 2 - PJ		
     vr_insitapr     crawlim.insitapr%type; --> Situacao Aprovacao(0-Em estudo/1-Aprovado/2-Nao aprovado/3-Restricao/4-Refazer)
  			
     -- Acionamento 
     cursor cr_aciona is
     select aci.cdcooper    
           ,aci.nrdconta    
           ,aci.nrctrprp
           ,aci.dsprotocolo dsprotoc
           ,aci.cdagenci_acionamento
     from   tbgen_webservice_aciona aci
     where  aci.dsprotocolo   = pr_dsprotoc
     and    aci.tpacionamento = 1; /*Envio*/
     rw_aciona cr_aciona%rowtype;
        
     -- Buscar o limite de desconto de titulo vinculado ao protocolo
     cursor cr_crawlim is
     select lim.cdcooper
           ,lim.nrdconta
           ,lim.nrctrlim
           ,lim.tpctrlim
           ,lim.cdagenci
           ,lim.cdopeste
           ,lim.insitest
           ,decode(lim.insitapr, 0, 'Nao Analisado'
                               , 1, 'Aprovado Automaticamente'
                               , 2, 'Aprovado Manual'
                               , 3, 'Aprovada Contengencia'
                               , 4, 'Rejeitado Manual'
                               , 5, 'Rejeitado Automaticamente'
                               , 6, 'Rejeitado Contingencia'
                               , 7, 'Nao Analisado'
                               , 8, 'Refazer'
                               , 'Sit Aprov Desconhecida') dssitapr
           ,lim.rowid
     from   crawlim lim
     where  lim.cdcooper = rw_aciona.cdcooper
     and    lim.nrdconta = rw_aciona.nrdconta
     and    lim.nrctrlim = rw_aciona.nrctrprp
     and    lim.dsprotoc = pr_dsprotoc
     /*FOR UPDATE*/;  
     rw_crawlim cr_crawlim%rowtype;
  			
     -- Buscar o tipo de pessoa que contratou o empréstimo
     cursor cr_crapass(pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
     select ass.inpessoa
     from   crapass ass
     where  ass.cdcooper = pr_cdcooper
     and    ass.nrdconta = pr_nrdconta;
     rw_crapdat btch0001.cr_crapdat%rowtype;
   			
     -- Variaveis temp para ajuste valores recebidos nos indicadores
     vr_indrisco varchar2(100); --> Nível do risco calculado para a operação
     vr_nrnotrat varchar2(100); --> Valor do rating calculado para a operação
     vr_nrinfcad varchar2(100); --> Valor do item Informações Cadastrais calculado no Rating
     vr_nrliquid varchar2(100); --> Valor do item Liquidez calculado no Rating
     vr_nrgarope varchar2(100); --> Valor das Garantias calculada no Rating
     vr_nrparlvr varchar2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
     vr_nrperger varchar2(100); --> Valor da Percepção Geral da Empresa calculada no Rating
     vr_desscore varchar2(100); --> Descricao do Score Boa Vista
     vr_datscore varchar2(100); --> Data do Score Boa Vista
     vr_idfluata BOOLEAN;       --> Segue Fluxo Atacado

     -- Bloco PLSQL para chamar a execução paralela do pc_crps414
     vr_dsplsql varchar2(4000);
     -- Job name dos processos criados
     vr_jobname varchar2(100);
         
     -- Variaveis para DEBUG
     vr_flgdebug varchar2(100) := 'S';
     vr_idaciona tbgen_webservice_aciona.idacionamento%type;
         
              
     -- Função para verificar se parâmetro passado é numérico
     function fn_is_number(pr_vlparam in varchar2) return boolean is
     begin
       if trim(gene0002.fn_char_para_number(pr_vlparam)) is null then
          return false;
       else
          return true;
       end if;  
     exception
       when others then
            return false;
     end fn_is_number;
         
     -- Função para verificar se parâmetro passado é Data
     function fn_is_date(pr_vlparam in varchar2) return boolean is
       vr_data date;
     begin
       vr_data := to_date(pr_vlparam,'RRRRMMDD');
       if  vr_data is null then 
           return false;
       else
           return true;  
       end if;  
     exception
       when others then
            return false;
     end fn_is_date;
         
     -- Função para trocar o litereal "null" por null
     function fn_converte_null(pr_dsvaltxt in varchar2) return varchar2 is
     begin
        if  pr_dsvaltxt = 'null' then
            return null;
        else
            return pr_dsvaltxt;
        end if;
     end;
  											 
  BEGIN
     pr_des_erro := 'OK';

     --  Produto 999 = Monitoração do serviço
     if  pr_dsprotoc = 'PoliticaGeralMonitoramento' then
         -- Apenas gerar retorno de sucesso para a esteira
         pc_gera_retor_proposta_esteira(pr_status      => 200  --> Status
                                       ,pr_nrtransacao => null --> Numero da transacao
                                       ,pr_cdcritic    => 0    --> Codigo da critica
                                       ,pr_dscritic    => 0    --> Descricao da critica
                                       ,pr_msg_detalhe => 'Monitoracao' --> Mensagem de detalhe
                                       ,pr_dtmvtolt    => null
                                       ,pr_retxml      => pr_retxml);  
         return;
     end if;    
      
     --  Se o acionamento já foi gravado na origem
     if  nvl(pr_nrtransa,0) > 0 then
         vr_nrtransacao := pr_nrtransa;
     end if;  
      
     open  cr_aciona;
     fetch cr_aciona into rw_aciona;
     close cr_aciona; 
      
     open  cr_crawlim;
     fetch cr_crawlim into rw_crawlim;
     if    cr_crawlim%notfound then
           close cr_crawlim;
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                     ,pr_ind_tipo_log => 2
                                     ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                         ' - WEBS0001 --> Erro ao gravar resultado da analise automatica '||
                                                         'de proposta – Procolo '||pr_dsprotoc||' inexistente'
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                  ,pr_cdacesso     => 'NOME_ARQ_LOG_MESSAGE'));
           vr_status      := 500;
           vr_cdcritic    := 978;
           vr_msg_detalhe := 'Resultado Analise Automatica nao foi atualizado, ocorreu erro interno no Sistema(1).';
           raise vr_exc_saida;
     end   if;
     close cr_crawlim;
        
     -- Verificar se o DEBUG está ativo
     vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crawlim.cdcooper,'DEBUG_MOTOR_IBRA');
        
     --  Se o DEBUG estiver habilitado
     if  vr_flgdebug = 'S' then
         este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawlim.cdcooper
                                      ,pr_cdagenci              => rw_aciona.cdagenci_acionamento
                                      ,pr_cdoperad              => 'MOTOR'
                                      ,pr_cdorigem              => pr_cdorigem
                                      ,pr_nrctrprp              => rw_crawlim.nrctrlim
                                      ,pr_nrdconta              => rw_crawlim.nrdconta
                                      ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                      ,pr_dsoperacao            => 'INICIO RETORNO ANALISE'
                                      ,pr_dsuriservico          => pr_namehost
                                      ,pr_dtmvtolt              => trunc(sysdate)
                                      ,pr_cdstatus_http         => 0
                                      ,pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"')
                                      ,pr_dsresposta_requisicao => null
                                   --   ,pr_tpconteudo            => 1
                                      ,pr_tpproduto             => 3
                                      ,pr_dsprotocolo           => pr_dsprotoc
                                      ,pr_idacionamento         => vr_idaciona
                                      ,pr_dscritic              => vr_dscritic);
         -- Sem tratamento de exceção para DEBUG                    
         --IF TRIM(vr_dscritic) IS NOT NULL THEN
         --  RAISE vr_exc_erro;
         --END IF;
     end if; 
        
     -- Verifica se a data esta cadastrada
     open  btch0001.cr_crapdat(pr_cdcooper => rw_crawlim.cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     if    btch0001.cr_crapdat%notfound then
           close btch0001.cr_crapdat;
           vr_status      := 500;
           vr_cdcritic    := 978;
           vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno no sistema(2)';
          raise vr_exc_saida;
     else
          close btch0001.cr_crapdat;
     end  if;

     -- Montar a mensagem que será gravada no acionamento
     case lower(pr_dsresana)
         when 'aprovar'      then vr_dssitret := 'APROVADO AUTOM.';
         when 'reprovar'     then vr_dssitret := 'REJEITADA AUTOM.';
         when 'derivar'      then vr_dssitret := 'ENVIADA ANALISE MANUAL';
         when 'erro'         then vr_dssitret := 'ERRO';
         else vr_dssitret := 'DESCONHECIDA';
     end case;
  		
     --  Se o acionamento ainda nao foi gravado
     if  vr_nrtransacao = 0 then 			
         este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawlim.cdcooper
                                      ,pr_cdagenci              => rw_aciona.cdagenci_acionamento
                                      ,pr_cdoperad              => 'MOTOR'
                                      ,pr_cdorigem              => pr_cdorigem
                                      ,pr_nrctrprp              => rw_crawlim.nrctrlim
                                      ,pr_nrdconta              => rw_crawlim.nrdconta
                                      ,pr_tpacionamento         => 2  -- 1 - Envio, 2 – Retorno 
                                      ,pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA '||vr_dssitret
                                      ,pr_dsuriservico          => pr_namehost
                                      ,pr_dtmvtolt              => rw_crapdat.dtmvtolt
                                      ,pr_cdstatus_http         => 200
                                      ,pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"')
                                      ,pr_dsresposta_requisicao => null
                                      ,pr_dsprotocolo           => pr_dsprotoc
                                 --     ,pr_tpconteudo            => 1
                                      ,pr_tpproduto             => 3
                                      ,pr_idacionamento         => vr_nrtransacao
                                      ,pr_dscritic              => vr_dscritic);
                                       
         if  vr_dscritic is not null then
             btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                       ,pr_ind_tipo_log => 2
                                       ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                           ' - WEBS0001 --> Erro ao gravar acionamento para conta '||
                                                           rw_crawlim.nrdconta||' contrato' || rw_crawlim.nrctrlim ||': '||vr_dscritic
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                    ,pr_cdacesso     => 'NOME_ARQ_LOG_MESSAGE'));
             vr_status      := 500;
             vr_cdcritic    := 978;
             vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu uma erro interno no sistema(3).';
             raise vr_exc_saida;
         end if; 
     end if;
        
     --  Condicao para verificar se o processo esta rodando
     if  nvl(rw_crapdat.inproces,0) <> 1 then
         vr_status      := 400;
         vr_cdcritic    := 138;
         vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, o processo batch AILOS esta em execucao.';
         raise vr_exc_saida;
     end if;	
        
     --  Somente se a proposta nao foi atualizada ainda
     /*if  rw_crawlim.insitest <> 2 then
         vr_status      := 400;
         vr_cdcritic    := 978;
         vr_msg_detalhe := 'Situacao da Proposta jah foi alterada - analise nao sera recebida.';
         raise vr_exc_saida;        
     end if;		*/

     --  Se algum dos parâmetros abaixo nao foram informados
     if  nvl(pr_cdorigem, 0) = 0 or trim(pr_dsprotoc) is null or trim(pr_dsresana) is null then
         vr_status      := 500;
         vr_cdcritic    := 978;
         vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(4)';
         raise vr_exc_saida;
     end if;

     --  Se os parâmetros abaixo possuirem algum valor diferente do verificado
     if  not pr_cdorigem in(5,9) /*or not lower(pr_dsresana) in('aprovar', 'reprovar', 'derivar', 'erro')*/ then
         vr_status      := 500;
         vr_cdcritic    := 978;
         vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                        || 'erro interno no sistema(5)';
         raise vr_exc_saida;
     end if;
  			
     -- Copia dos valores dos parâmetros para variaveis já corrigindo
     -- possiveis problemas com a vinda de parâmetros "null"
     vr_indrisco := fn_converte_null(pr_indrisco);
     vr_nrnotrat := fn_converte_null(pr_nrnotrat);
     vr_nrinfcad := fn_converte_null(pr_nrinfcad);
     vr_nrliquid := fn_converte_null(pr_nrliquid);
     vr_nrgarope := fn_converte_null(pr_nrgarope);
     vr_nrparlvr := fn_converte_null(pr_nrparlvr);
     vr_nrperger := fn_converte_null(pr_nrperger);
     vr_desscore := fn_converte_null(pr_desscore);
     vr_datscore := fn_converte_null(pr_datscore);
     vr_idfluata := pr_idfluata; -- PJ637
        
     -- Buscar o tipo de pessoa
     open cr_crapass(pr_cdcooper => rw_crawlim.cdcooper
                    ,pr_nrdconta => rw_crawlim.nrdconta);
     fetch cr_crapass into vr_inpessoa;
     close cr_crapass;
        
     if  lower(pr_dsresana) in ('aprovar', 'reprovar', 'derivar') then
         --  NEste caso testes retornos obrigatórios
         if  (trim(vr_indrisco) is null or trim(vr_nrnotrat) is null or
              trim(vr_nrinfcad) is null or trim(vr_nrliquid) is null or
              trim(vr_nrgarope) is null or trim(vr_nrparlvr) is null or
              (trim(vr_nrperger) is null and vr_inpessoa = 2)) then
             vr_status      := 500;
             vr_cdcritic    := 978;
             vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(6)';
             raise vr_exc_saida;
         end if;
          
         -- Se risco nao for um dos verificados abaixo
         if  not pr_indrisco in('AA','A','B','C','D','E','F','G','H') then
             vr_status      := 500;
             vr_cdcritic    := 978;
             vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(7)';
             raise vr_exc_saida;
         end if;
           
         -- Se algum dos parâmetros abaixo nao forem números
         if  not fn_is_number(vr_nrnotrat) or not fn_is_number(vr_nrinfcad) or not fn_is_number(vr_nrliquid) or
             not fn_is_number(vr_nrgarope) or not fn_is_number(vr_nrparlvr) or
             (not fn_is_number(vr_nrperger) and vr_inpessoa = 2 ) then
             vr_status      := 500;
             vr_cdcritic    := 978;
             vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(8)';
             raise vr_exc_saida;
         end if;

         --  Se nao for uma data valida
         if  vr_datscore is not null and not fn_is_date(vr_datscore) then
             vr_status      := 500;
             vr_cdcritic    := 978;
             vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(9)';
             raise vr_exc_saida;
         end if;
     end if;
  			
     --  Tratar status
     if    lower(pr_dsresana) = 'aprovar' then
           vr_insitapr := 1;
     elsif lower(pr_dsresana) = 'reprovar' then
           vr_insitapr := 2;
     elsif lower(pr_dsresana) = 'derivar' then
           vr_insitapr := 3;
     else
           vr_insitapr := 0;
     end if;
          
     -- Atualizar proposta
     pc_atualiza_prop_srv_limdesct
                  (pr_cdcooper    => rw_crawlim.cdcooper
                  ,pr_nrdconta    => rw_crawlim.nrdconta
                  ,pr_nrctrlim    => rw_crawlim.nrctrlim
                  ,pr_tpctrlim    => rw_crawlim.tpctrlim
                  ,pr_tpretest    => 'M'                             --> Retorno Motor
                  ,pr_rw_crapdat  => rw_crapdat
                  ,pr_insitapr    => vr_insitapr
                  ,pr_dsdscore    => vr_desscore                     --> Descrição Score Boa Vista
                  ,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD') --> Data Score Boa Vista
                  ,pr_indrisco    => vr_indrisco                     --> Nível do Risco calculado na Analise 
                  ,pr_nrnotrat    => gene0002.fn_char_para_number(vr_nrnotrat)    --> Calculo do Rating na Analise 
                  ,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informação Cadastral da Analise 
                  ,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise 
                  ,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise 
                  ,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise 
                  ,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepção Geral Empresa na Analise 
                  ,pr_idfluata    => vr_idfluata -- PJ637
                  ,pr_status      => vr_status
                  ,pr_cdcritic    => vr_cdcritic
                  ,pr_dscritic    => vr_dscritic
                  ,pr_msg_detalhe => vr_msg_detalhe
                  ,pr_des_reto    => vr_des_reto);
  			
     -- Gera retorno da proposta para a esteira
     pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                   ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                   ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                   ,pr_dscritic    => vr_dscritic    --> Descricao critica  
                                   ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                   ,pr_retxml      => pr_retxml);    

     --  Se o DEBUG estiver habilitado
     if  vr_flgdebug = 'S' then
         --> Gravar dados log acionamento
         este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawlim.cdcooper
                                      ,pr_cdagenci              => rw_aciona.cdagenci_acionamento
                                      ,pr_cdoperad              => 'MOTOR'
                                      ,pr_cdorigem              => pr_cdorigem
                                      ,pr_nrctrprp              => rw_crawlim.nrctrlim
                                      ,pr_nrdconta              => rw_crawlim.nrdconta
                                      ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                      ,pr_dsoperacao            => 'FINAL RETORNO ANALISE'
                                      ,pr_dsuriservico          => pr_namehost
                                      ,pr_dtmvtolt              => rw_crapdat.dtmvtolt
                                      ,pr_cdstatus_http         => 0
                                      ,pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"')
                                      ,pr_dsresposta_requisicao => null
                                --      ,pr_tpconteudo            => 1
                                      ,pr_tpproduto             => 3
                                      ,pr_dsprotocolo           => pr_dsprotoc
                                      ,pr_idacionamento         => vr_idaciona
                                      ,pr_dscritic              => vr_dscritic);
         -- Sem tratamento de exceção para DEBUG                    
         --IF TRIM(vr_dscritic) IS NOT NULL THEN
         --  RAISE vr_exc_erro;
         --END IF;
     end if; 
        
     --  Caso nao tenha havido erro na atualizado 
     if  nvl(vr_cdcritic,0) = 0 and vr_dscritic is null and trim(pr_dsprotoc) is not null then 
        
         --  Se resultado da análise nao retornou erro
         if  lower(pr_dsresana) <> 'erro' then
             -- Acionar rotina para processamento consultas automatizadas
             sspc0001.pc_retorna_conaut_est_limdesct(rw_crawlim.cdcooper
                                                    ,rw_crawlim.nrdconta
                                                    ,rw_crawlim.nrctrlim
                                                    ,rw_crawlim.tpctrlim
                                                    ,pr_dsprotoc
                                                    ,vr_cdcritic
                                                    ,vr_dscritic);
             --  Em caso de erro 
             if  vr_dscritic is not null then 
                 -- Adicionar ao LOG e continuar o processo
                 btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 2
                                           ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')
                                                               || ' - WEBS0001 --> Erro ao solicitor retorno nas '
                                                               || 'Consulta Automaticas do Protocolo: '||pr_dsprotoc
                                                               || ', erro: '||vr_cdcritic||'-'||vr_dscritic
                                           ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                        ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
             end if;

             --  Se o DEBUG estiver habilitado
             if  vr_flgdebug = 'S' then
                 --> Gravar dados log acionamento
                 este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawlim.cdcooper
                                              ,pr_cdagenci              => rw_aciona.cdagenci_acionamento
                                              ,pr_cdoperad              => 'MOTOR'
                                              ,pr_cdorigem              => pr_cdorigem
                                              ,pr_nrctrprp              => rw_crawlim.nrctrlim
                                              ,pr_nrdconta              => rw_crawlim.nrdconta
                                              ,pr_tpacionamento         => 0  /* 0 - DEBUG */      
                                              ,pr_dsoperacao            => 'FINAL RETORNO CONAUT'
                                              ,pr_dsuriservico          => pr_namehost
                                              ,pr_dtmvtolt              => rw_crapdat.dtmvtolt
                                              ,pr_cdstatus_http         => 0
                                              ,pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"')
                                              ,pr_dsresposta_requisicao => null
                                       --       ,pr_tpconteudo            => 1
                                              ,pr_tpproduto             => 3
                                              ,pr_dsprotocolo           => pr_dsprotoc
                                              ,pr_idacionamento         => vr_idaciona
                                              ,pr_dscritic              => vr_dscritic);
                 -- Sem tratamento de exceção para DEBUG                    
                 --IF TRIM(vr_dscritic) IS NOT NULL THEN
                 --  RAISE vr_exc_erro;
                 --END IF;
             end if;
         end if;

         -- Caso seja derivação
         if  lower(pr_dsresana) = 'derivar' then
             -- Acionar rotina para derivação automatica em  paralelo
             vr_dsplsql := 'DECLARE'||chr(13)
                       || '  vr_dsmensag VARCHAR2(4000);'||chr(13)
                       || '  vr_cdcritic NUMBER;'||chr(13)
                       || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                       || 'BEGIN'||chr(13)
                       || '  ESTE0003.pc_derivar_proposta(pr_cdcooper => '||rw_crawlim.cdcooper ||chr(13)
                       || '                              ,pr_cdagenci => '||rw_crawlim.cdagenci ||chr(13)
                       || '                              ,pr_cdoperad => '''||rw_crawlim.cdopeste||''''||chr(13)
                       || '                              ,pr_cdorigem => 9'                    ||chr(13)
                       || '                              ,pr_nrdconta => '||rw_crawlim.nrdconta ||chr(13)
                       || '                              ,pr_nrctrlim => '||rw_crawlim.nrctrlim ||chr(13)
                       || '                              ,pr_tpctrlim => '||rw_crawlim.tpctrlim ||chr(13)
                       || '                              ,pr_dtmvtolt => to_date('''||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr''));'||chr(13)
                       || 'END;';
                       
             -- Montar o prefixo do código do programa para o jobname
             vr_jobname := 'JBEPR_DRMT_$';
             -- Faz a chamada ao programa paralelo atraves de JOB
             gene0001.pc_submit_job(pr_cdcooper  => rw_crawlim.cdcooper  --> Código da cooperativa
                                   ,pr_cdprogra  => 'ATENDA'     --> Código do programa
                                   ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                   ,pr_dthrexe   => systimestamp --> Executar nesta hora
                                   ,pr_interva   => null         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                   ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                   ,pr_des_erro  => vr_dscritic);
             -- Testar saida com erro
             if  vr_dscritic is not null then
                 -- Adicionar ao LOG e continuar o processo
                 btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 2
                                           ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                               ' - WEBS0001 --> Erro ao solicitor derivação '||
                                                               ' Automatica do Protocolo: '||pr_dsprotoc||
                                                               ', erro: '||vr_cdcritic||'-'||vr_dscritic
                                           ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                        ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
             end if; 
         end if; 
     end if;      
        
     COMMIT;
  			
  EXCEPTION
     when vr_exc_saida then
          -- Se ainda nao houve geracao id Acionamento
          if  vr_nrtransacao = 0 and rw_crawlim.nrdconta is not null then
              -- Para cada requisicao sera criado um numero de transacao
              este0001.pc_grava_acionamento(pr_cdcooper                 => rw_crawlim.cdcooper
                                           ,pr_cdagenci                 => rw_aciona.cdagenci_acionamento
                                           ,pr_cdoperad                 => 'MOTOR'
                                           ,pr_cdorigem                 => 9
                                           ,pr_nrctrprp                 => rw_crawlim.nrctrlim
                                           ,pr_nrdconta                 => rw_crawlim.nrdconta
                                           ,pr_tpacionamento            => 2  -- 1 - Envio, 2 – Retorno 
                                           ,pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE AUTO – '||rw_crawlim.dssitapr
                                           ,pr_dsuriservico             => pr_namehost
                                           ,pr_dtmvtolt                 => rw_crapdat.dtmvtolt
                                           ,pr_cdstatus_http            => 0
                                           ,pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"')
                                           ,pr_dsresposta_requisicao    => null
                                        --   ,pr_tpconteudo               => 1
                                           ,pr_tpproduto                => 3
                                           ,pr_idacionamento            => vr_nrtransacao
                                           ,pr_dscritic                 => vr_dscritic);

              if  vr_dscritic is not null then
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                            ,pr_ind_tipo_log => 2
                                            ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                                ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise '||
                                                                ' para conta '|| rw_crawlim.nrdconta||' contrato '||
                                                                rw_crawlim.nrctrlim ||': '||sqlerrm
                                            ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                         ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));                        
              end if;
          end if;
          
          --  Mudaremos a situação da analise para encerrada com erro para que possa haver o Re-envio
          if  rw_crawlim.rowid is not null then 
              begin
                 update crawlim lim
                 set    insitapr = 8 -- Erro
                       ,cdopeapr = 'MOTOR'
                       ,dtaprova = rw_crapdat.dtmvtolt
                       ,hraprova = gene0002.fn_busca_time
                       ,insitest = 3 -- Finalizada
                       ,insitlim = 1
                 where  lim.rowid = rw_crawlim.rowid;
              exception
                 when others then
                      vr_dscritic := vr_dscritic || ' e erro na atualiza Proposta: '||sqlerrm;
              end; 
          end if;  

          -- Gera retorno da proposta para a esteira
          pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                        ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                        ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                        ,pr_dscritic    => vr_dscritic    --> Descricao critica  
                                        ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                        ,pr_retxml      => pr_retxml);    

          COMMIT;

     when others then
          -- Se ainda nao houve geracao id Acionamento
          if  vr_nrtransacao = 0 and rw_crawlim.nrdconta is not null then
              -- Para cada requisicao sera criado um numero de transacao
              este0001.pc_grava_acionamento(pr_cdcooper                 => rw_crawlim.cdcooper
                                           ,pr_cdagenci                 => rw_aciona.cdagenci_acionamento
                                           ,pr_cdoperad                 => 'MOTOR'
                                           ,pr_cdorigem                 => 9
                                           ,pr_nrctrprp                 => rw_crawlim.nrctrlim
                                           ,pr_nrdconta                 => rw_crawlim.nrdconta
                                           ,pr_tpacionamento            => 2  -- 1 - Envio, 2 – Retorno 
                                           ,pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE PROPOSTA - '||rw_crawlim.dssitapr
                                           ,pr_dsuriservico             => pr_namehost
                                           ,pr_dtmvtolt                 => rw_crapdat.dtmvtolt
                                           ,pr_cdstatus_http            => 0
                                           ,pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"')
                                           ,pr_dsresposta_requisicao    => null
                                   --        ,pr_tpconteudo               => 1
                                           ,pr_tpproduto                => 3
                                           ,pr_idacionamento            => vr_nrtransacao
                                           ,pr_dscritic                 => vr_dscritic);

              if  vr_dscritic is not null then
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                            ,pr_ind_tipo_log => 2
                                            ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                                ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise'||
                                                                ' para conta ' || rw_crawlim.nrdconta||' contrato'||
                                                                rw_crawlim.nrctrlim ||': '||sqlerrm
                                            ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                         ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
              end if;
          end if; 
          
          --  Mudaremos a situação da analise para encerrada com erro para que possa haver o Re-envio
          if  rw_crawlim.rowid is not null then 
              begin
                 update crawlim lim
                 set    insitapr = 8 -- Erro
                       ,cdopeapr = 'MOTOR'
                       ,dtaprova = rw_crapdat.dtmvtolt
                       ,hraprova = gene0002.fn_busca_time
                       ,insitest = 3 -- Finalizada
                       ,insitlim = 1
                 where  lim.rowid = rw_crawlim.rowid;
              exception
                 when others then
                      vr_dscritic := vr_dscritic || ' e erro na atualiza Proposta: '||sqlerrm;
              end; 
          end if;  

          -- Somente se ocorreu encontro da proposta
          pc_gera_retor_proposta_esteira(pr_status      => 500              --> Status
                                        ,pr_nrtransacao => vr_nrtransacao   --> Numero transacao
                                        ,pr_cdcritic    => 978              --> Codigo da critica
                                        ,pr_msg_detalhe => 'Retorno Analise Automatica '
                                                        || 'nao foi atualizado, ocorreu '
                                                        || 'uma erro interno no sistema.(9)'
                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                        ,pr_retxml      => pr_retxml);
                                        
          -- Enviar LOG geral, independente de ter encontro de proposta 
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 3
                                    ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                        ' - WEBS0001 --> Nao foi possivel atualizar retorno da Analise '||
                                                        'Automatica da proposta ' || vr_nrtransacao ||': '||sqlerrm
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                 ,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));        
          
          COMMIT;
  END;
  END pc_retorno_analise_limdesct;	                                                     	
  
  PROCEDURE pc_retorno_analise_aut(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                  ,pr_dsprotoc IN VARCHAR2              --> Protocolo da análise
                                  ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                                  ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                  ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                                  ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                                  ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                                  ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                                  ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                  ,pr_inopeatr IN NUMBER                --> Contem o identificador da operacao de credito em atraso que vai para esteira
                                  ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                  ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                                  ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                                  ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                                  ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                                  ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                  ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado   --P637                                                                       
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
	   /* .............................................................................
       Programa: pc_retorno_analise_aut
       Sistema : Rotinas referentes ao WebService
       Sigla   : WEBS
       Autor   : Daniel Zimmerman (CECRED) / Paulo Penteado (GFT) 
       Data    : Maio/18

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado

       Objetivo  : Receber as informações da análise automática do motor

       Alteracoes:  14/05/2018 - Criação Daniel Zimmerman (CECRED) / Paulo Penteado (GFT) 
             
    ..............................................................................*/	
		BEGIN
    --  Produto 999 = Monitoração do serviço
    IF  pr_dsprotoc = 'PoliticaGeralMonitoramento' THEN
        -- Apenas gerar retorno de sucesso para a esteira
        pc_gera_retor_proposta_esteira(pr_status      => 200  --> Status
                                      ,pr_nrtransacao => NULL --> Numero da transacao
                                      ,pr_cdcritic    => 0    --> Codigo da critica
                                      ,pr_dscritic    => 0    --> Descricao da critica
                                      ,pr_msg_detalhe => 'Monitoracao' --> Mensagem de detalhe
                                      ,pr_dtmvtolt    => NULL
                                      ,pr_retxml      => pr_retxml);  
        RETURN;
    END IF;    

    IF  pr_dsprotoc LIKE 'PoliticaDescontoTitulos%' THEN
        pc_retorno_analise_limdesct
                    (pr_cdorigem => pr_cdorigem          
                    ,pr_dsprotoc => pr_dsprotoc
                    ,pr_nrtransa => pr_nrtransa
                    ,pr_dsresana => pr_dsresana
                    ,pr_indrisco => pr_indrisco
                    ,pr_nrnotrat => pr_nrnotrat
                    ,pr_nrinfcad => pr_nrinfcad
                    ,pr_nrliquid => pr_nrliquid
                    ,pr_nrgarope => pr_nrgarope
                    ,pr_nrparlvr => pr_nrparlvr
                    ,pr_nrperger => pr_nrperger
                    ,pr_desscore => pr_desscore
                    ,pr_datscore => pr_datscore
                    ,pr_dsrequis => pr_dsrequis
                    ,pr_namehost => pr_namehost
                    ,pr_idfluata => pr_idfluata --P637
                    ,pr_xmllog   => pr_xmllog  
                    ,pr_cdcritic => pr_cdcritic
                    ,pr_dscritic => pr_dscritic
                    ,pr_retxml   => pr_retxml  
                    ,pr_nmdcampo => pr_nmdcampo
                    ,pr_des_erro => pr_des_erro
                    );
    ELSE
        pc_retorno_analise_proposta
                    (pr_cdorigem => pr_cdorigem          
                    ,pr_dsprotoc => pr_dsprotoc
                    ,pr_nrtransa => pr_nrtransa
                    ,pr_dsresana => pr_dsresana
                    ,pr_indrisco => pr_indrisco
                    ,pr_nrnotrat => pr_nrnotrat
                    ,pr_nrinfcad => pr_nrinfcad
                    ,pr_nrliquid => pr_nrliquid
                    ,pr_nrgarope => pr_nrgarope
                    ,pr_inopeatr => pr_inopeatr
                    ,pr_nrparlvr => pr_nrparlvr
                    ,pr_nrperger => pr_nrperger
                    ,pr_desscore => pr_desscore
                    ,pr_datscore => pr_datscore
                    ,pr_dsrequis => pr_dsrequis
                    ,pr_namehost => pr_namehost
                    ,pr_idfluata => pr_idfluata --P637
                    ,pr_xmllog   => pr_xmllog  
                    ,pr_cdcritic => pr_cdcritic
                    ,pr_dscritic => pr_dscritic
                    ,pr_retxml   => pr_retxml  
                    ,pr_nmdcampo => pr_nmdcampo
                    ,pr_des_erro => pr_des_erro
                    );
    END IF;
		EXCEPTION
    WHEN OTHERS THEN
         -- Enviar LOG geral, independente de ter encontro de proposta 
         btch0001.pc_gera_log_batch(pr_cdcooper     => 3
									,pr_ind_tipo_log => 3
									,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')||
                                    ' - WEBS0001 --> Nao foi possivel atualizar retorno da Analise: '||SQLERRM
									,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
									,pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
         -- Gravar
         COMMIT;
  END pc_retorno_analise_aut;  

-- Processa retorno da análise do cartão
  PROCEDURE pc_retorno_analise_cartao(pr_cdorigem IN NUMBER             --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                     ,pr_dsrequis IN VARCHAR2           --> Conteúdo da requisiçao oriunda da Análise Automática na Esteira
                                     ,pr_namehost IN VARCHAR2           --> Nome do host oriundo da requisiçao da Análise Automática na Esteira
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informaçoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descriçao da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  
    /* .............................................................................
     Programa: pc_retorno_analise_cartao
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Paulo Silva (Supero
     Data    : Maio/2018.                    Ultima atualizacao: 05/05/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Receber as informaçoes da análise automática da Esteira e gravar 
                 na base

     Observacao: -----
       
     Alteracoes:       
          
     ..............................................................................*/  
    -- Tratamento de críticas
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_des_reto  VARCHAR2(10);

    -- Variáveis auxiliares
    vr_msg_detalhe  VARCHAR2(10000);      --> Detalhe da mensagem
    vr_status       PLS_INTEGER;          --> Status
    vr_dssitret     VARCHAR2(100);        --> Situaçao de retorno
    vr_nrtransacao  NUMBER(25) := 0;      --> Numero da transacao
    vr_inpessoa     PLS_INTEGER := 0;     --> 1 - PF/ 2 - PJ
    vr_insitapr     NUMBER;
    
    -- Variaveis temp para ajuste valores recebidos nos indicadores
    vr_indrisco VARCHAR2(100); --> Nível do risco calculado para a operaçao
    vr_nrnotrat VARCHAR2(100); --> Valor do rating calculado para a operaçao
    vr_nrinfcad VARCHAR2(100); --> Valor do item Informaçoes Cadastrais calculado no Rating
    vr_nrliquid VARCHAR2(100); --> Valor do item Liquidez calculado no Rating
    vr_nrgarope VARCHAR2(100); --> Valor das Garantias calculada no Rating
    vr_nrparlvr VARCHAR2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
    vr_nrperger VARCHAR2(100); --> Valor da Percepçao Geral da Empresa calculada no Rating
    vr_desscore VARCHAR2(100); --> Descricao do Score Boa Vista
    vr_datscore VARCHAR2(100); --> Data do Score Boa Vista
    vr_dsprotoc VARCHAR2(100); --> Protocolo
    vr_tpprodut VARCHAR2(100); --> Tipo produto (MJ=Majoracao, LM=Limite Novo)
    vr_dsresana VARCHAR2(100); --> Resultado da Análise
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := 'S';
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    vr_tplimcrd NUMERIC(1) := 0; -- 0=concessao, 1=alteracao
    
    --Objeto JSON e CLOB
    vr_objeto         json := json();
    vr_obj_indicador  json := json();
    vr_obj_generic2   json := json();
    vr_lst_generic2   json_list := json_list();
    vr_objeto_clob    CLOB;
    
    -- Acionamento
    CURSOR cr_aciona (pr_dsprotoc tbgen_webservice_aciona.dsprotocolo%TYPE) IS
      SELECT aci.cdcooper
            ,aci.cdagenci_acionamento
            ,aci.nrdconta
            ,aci.nrctrprp
            ,aci.dsprotocolo dsprotoc
        FROM tbgen_webservice_aciona aci
       WHERE aci.dsprotocolo   = pr_dsprotoc
         AND aci.tpacionamento = 1 /*Envio*/
         AND aci.tpproduto = 4; 
    rw_aciona cr_aciona%ROWTYPE;

    -- Buscar o tipo de pessoa que contratou o empréstimo
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    --Busca caterogias de cartão
    CURSOR cr_catcrd(pr_cdcooper IN crapass.cdcooper%TYPE
                    ,pr_tpctahab crapadc.tpctahab%TYPE
                    ,pr_tplimcrd IN tbcrd_config_categoria.tplimcrd%TYPE) IS
      SELECT tcc.cdadmcrd
            ,adc.nmresadm
            ,tcc.vllimite_minimo
            ,tcc.vllimite_maximo
        FROM crapadc adc
            ,tbcrd_config_categoria tcc
       WHERE tcc.cdcooper = pr_cdcooper
         AND tcc.tplimcrd = nvl(pr_tplimcrd, 0)
         AND adc.cdcooper = tcc.cdcooper
         AND adc.cdadmcrd = tcc.cdadmcrd
         AND adc.tpctahab = pr_tpctahab
         AND adc.insitadc = 0 --Normal
       ORDER BY tcc.cdadmcrd;
    rw_catcrd cr_catcrd%ROWTYPE;

    -- Funçao para verificar se parâmetro passado é numérico
    FUNCTION fn_is_number(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
      IF TRIM(gene0002.fn_char_para_number(pr_vlparam)) IS NULL THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END fn_is_number;

    -- Funçao para verificar se parâmetro passado é Data
    FUNCTION fn_is_date(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
      vr_data date;
    BEGIN
      vr_data := TO_DATE(pr_vlparam,'RRRRMMDD');
      IF vr_data IS NULL THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END fn_is_date;

    -- Funçao para trocar o litereal "null" por null
    FUNCTION fn_converte_null(pr_dsvaltxt IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      IF pr_dsvaltxt = 'null' THEN
        RETURN NULL;
      ELSE
        RETURN pr_dsvaltxt;
      END IF;
    END;
    
  BEGIN
    vr_objeto := json(replace(pr_dsrequis,'&quot;','"'));

    --Protocolo
    IF vr_objeto.exist('protocolo') THEN
      vr_dsprotoc := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_objeto.get('protocolo').to_char(),'"'),'"'),'\u','\'))));
    END IF;
    
    --resultadoAnaliseRegra
    IF vr_objeto.exist('resultadoAnaliseRegra') THEN
      vr_dsresana := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_objeto.get('resultadoAnaliseRegra').to_char(),'"'),'"'),'\u','\'))));
    END IF;
    
    --indicadoresGeradosRegra
    IF vr_objeto.exist('indicadoresGeradosRegra') THEN
      vr_obj_indicador := json(vr_objeto.get('indicadoresGeradosRegra'));
      
      --nivelRisco
      IF vr_obj_indicador.exist('nivelRisco') THEN
        vr_indrisco := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('nivelRisco').to_char(),'"'),'"'),'\u','\'))));
      END IF;
    
      --notaRating
      IF vr_obj_indicador.exist('notaRating') THEN
        vr_nrnotrat := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('notaRating').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --informacaoCadastral
      IF vr_obj_indicador.exist('informacaoCadastral') THEN
        vr_nrinfcad := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('informacaoCadastral').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --liquidez
      IF vr_obj_indicador.exist('liquidez') THEN
        vr_nrliquid := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('liquidez').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --garantia
      IF vr_obj_indicador.exist('garantia') THEN
        vr_nrgarope := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('garantia').to_char(),'"'),'"'),'\u','\'))));
      END IF;
     
      --patrimonioPessoalLivre
      IF vr_obj_indicador.exist('patrimonioPessoalLivre') THEN
        vr_nrparlvr := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('patrimonioPessoalLivre').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --percepcaoGeralEmpresa
      IF vr_obj_indicador.exist('percepcaoGeralEmpresa') THEN
        vr_nrperger := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('percepcaoGeralEmpresa').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --descricaoScoreBVS
      IF vr_obj_indicador.exist('descricaoScoreBVS') THEN
        vr_desscore := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('descricaoScoreBVS').to_char(),'"'),'"'),'\u','\'))));
      END IF;
      
      --dataScoreBVS
      IF vr_obj_indicador.exist('dataScoreBVS') THEN
        vr_datscore := fn_converte_null(gene0007.fn_convert_web_db(UNISTR(REPLACE(RTRIM(LTRIM(vr_obj_indicador.get('dataScoreBVS').to_char(),'"'),'"'),'\u','\'))));
      END IF;

    END IF;

    -- Produto 999 = Monitoraçao do serviço
    IF vr_dsprotoc = 'PoliticaGeralMonitoramento' THEN

      -- Apenas gerar retorno de sucesso para a esteira
      pc_gera_retor_proposta_esteira(pr_status      => 200  --> Status
                                    ,pr_nrtransacao => NULL --> Numero da transacao
                                    ,pr_cdcritic    => 0    --> Codigo da critica
                                    ,pr_dscritic    => 0    --> Descricao da critica
                                    ,pr_msg_detalhe => 'Monitoracao' --> Mensagem de detalhe
                                    ,pr_dtmvtolt    => NULL
                                    ,pr_retxml      => pr_retxml);
      
      RETURN;
    END IF;

    -- Acionamento
    OPEN cr_aciona(vr_dsprotoc);
    FETCH cr_aciona INTO rw_aciona;
    CLOSE cr_aciona;

    -- Verificar se o DEBUG está ativo
    vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_aciona.cdcooper,'DEBUG_MOTOR_IBRA');

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento(pr_cdcooper              => rw_aciona.cdcooper,
                                    pr_cdagenci              => 1,
                                    pr_cdoperad              => 'MOTOR',
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => NULL,
                                    pr_nrdconta              => rw_aciona.nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'INICIO RETORNO ANALISE',
                                    pr_dsuriservico          => pr_namehost,
                                    pr_dtmvtolt              => trunc(SYSDATE),
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => REPLACE(pr_dsrequis,'&quot;','"'),
                                    pr_dsresposta_requisicao => NULL,
                                    pr_tpproduto             => 4,
                                    pr_dsprotocolo           => vr_dsprotoc,
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
    END IF;

    -- Verifica se a data esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_aciona.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE btch0001.cr_crapdat;
        
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno no sistema(2)';
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Montar a mensagem que será gravada no acionamento
    CASE LOWER(vr_dsresana)
      WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
      WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
      WHEN 'derivar'  THEN vr_dssitret := 'ANALISAR MANUAL';
      WHEN 'erro'     THEN vr_dssitret := 'ERRO';
      ELSE vr_dssitret := 'DESCONHECIDA';
    END CASE;

    -- Buscar o tipo de pessoa
    OPEN cr_crapass(pr_cdcooper => rw_aciona.cdcooper
                   ,pr_nrdconta => rw_aciona.nrdconta);
    FETCH cr_crapass INTO vr_inpessoa;
    CLOSE cr_crapass;

    FOR rw_catcrd IN cr_catcrd(rw_aciona.cdcooper
                              ,vr_inpessoa
                              ,vr_tplimcrd) LOOP
      -- Criar objeto para a operação e enviar suas informações 
      vr_obj_generic2 := json();
      vr_obj_generic2.put('codigo',rw_catcrd.cdadmcrd);
      vr_obj_generic2.put('descricao',rw_catcrd.nmresadm);
      vr_obj_generic2.put('vlLimiteMinimo',rw_catcrd.vllimite_minimo);
      vr_obj_generic2.put('vlLimiteMaximo',rw_catcrd.vllimite_maximo);

      -- Adicionar Operação na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      
    END LOOP; -- Final da leitura das categorias

    -- Adicionar o array seguro no objeto informações adicionais
    vr_objeto.put('categoriasCartaoCecred', vr_lst_generic2);
    
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_objeto_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_objeto_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_objeto,vr_objeto_clob);
    
    -- Gravar o acionamento
    este0001.pc_grava_acionamento(pr_cdcooper                 => rw_aciona.cdcooper,
                                  pr_cdagenci                 => 1,
                                  pr_cdoperad                 => 'MOTOR',
                                  pr_cdorigem                 => pr_cdorigem,
                                  pr_nrctrprp                 => rw_aciona.nrctrprp,
                                  pr_nrdconta                 => rw_aciona.nrdconta,
                                  pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno
                                  pr_dsoperacao               => 'RETORNO ANALISE AUTOMATICA - '||vr_dssitret,
                                  pr_dsuriservico             => pr_namehost,
                                  pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
                                  pr_cdstatus_http            => 200,
                                  pr_dsconteudo_requisicao    => vr_objeto_clob,
                                  pr_dsresposta_requisicao    => vr_dssitret,
                                  pr_dsprotocolo              => vr_dsprotoc,
                                  pr_idacionamento            => vr_nrtransacao,
                                  pr_dscritic                 => vr_dscritic,
                                  pr_tpproduto                => 4); --Cartão

    -- Se retornou crítica
    IF vr_dscritic IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - WEBS0001 --> Erro ao gravar acionamento para conta '
                                                 ||rw_aciona.nrdconta||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
          
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu uma erro interno no sistema(3).';
      RAISE vr_exc_saida;
    END IF;

    -- Condicao para verificar se o processo esta rodando
    IF NVL(rw_crapdat.inproces,0) <> 1 THEN
      -- Montar mensagem de critica
      vr_status      := 400;
      vr_cdcritic    := 138;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, o processo batch CECRED esta em execucao.';
      RAISE vr_exc_saida;
    END IF;

    -- Se algum dos parâmetros abaixo nao foram informados
    IF nvl(pr_cdorigem, 0) = 0 OR
       TRIM(vr_dsprotoc) IS NULL OR
       TRIM(vr_dsresana) IS NULL THEN
        
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(4)';
      RAISE vr_exc_saida;
    END IF;

    -- Se os parâmetros abaixo possuirem algum valor diferente do verificado
    IF NOT pr_cdorigem IN(5,9) OR
       NOT LOWER(vr_dsresana) IN ('aprovar', 'reprovar', 'derivar', 'erro') THEN
        
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(5)';
      RAISE vr_exc_saida;
    END IF;

    IF lower(vr_dsresana) IN ('aprovar', 'reprovar', 'derivar') THEN
      
      -- Se nao for uma data valida
      IF vr_datscore IS NOT NULL AND NOT fn_is_date(vr_datscore) THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(9)';
        RAISE vr_exc_saida;
      END IF;

    END IF;
    
    -- Tratar status
    IF lower(vr_dsresana) = 'aprovar' THEN
      vr_insitapr := 1; -- Aprovado
    ELSIF lower(vr_dsresana) = 'reprovar' THEN
      vr_insitapr := 5; -- Reprovado
    ELSIF lower(vr_dsresana) = 'derivar' THEN
      vr_insitapr := 7; -- Derivada
    ELSE
      vr_insitapr := 4; -- Erro
    END IF;

    -- Atualizar proposta do cartão
    pc_atualiza_prop_srv_cartao (pr_cdcooper    => rw_aciona.cdcooper --> Codigo da cooperativa
                                ,pr_nrdconta    => rw_aciona.nrdconta --> Numero da conta
                                ,pr_nrctrcrd    => NULL               --> Numero do contrato
                                ,pr_tpretest    => 'M'                --> Retorno Motor  
                                ,pr_rw_crapdat  => rw_crapdat         --> Cursor da crapdat
                                ,pr_insitapr    => vr_insitapr
                                ,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informaçao Cadastral da Analise 
                                ,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise
                                ,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise
                                ,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise
                                ,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepçao Geral Empresa na Analise 
                                ,pr_dsdscore    => vr_desscore    --> Descriçao Score Boa Vista
                                ,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD')              --> Data Score Boa Vista
                                ,pr_status      => vr_status      --> Status
                                ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                ,pr_des_reto    => vr_des_reto);  --> Erros do processo

    -- Gera retorno da proposta para a esteira
    pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                  ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                  ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                  ,pr_dscritic    => vr_dscritic    --> Descricao critica
                                  ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                  ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                  ,pr_retxml      => pr_retxml);

    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      este0001.pc_grava_acionamento(pr_cdcooper              => rw_aciona.cdcooper,
                                    pr_cdagenci              => 1,
                                    pr_cdoperad              => 'MOTOR',
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => NULL,
                                    pr_nrdconta              => rw_aciona.nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'FINAL RETORNO ANALISE',
                                    pr_dsuriservico          => pr_namehost,
                                    pr_dtmvtolt              => rw_crapdat.dtmvtolt,
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                    pr_dsresposta_requisicao => null,
                                    pr_dsprotocolo           => vr_dsprotoc,
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic,
                                    pr_tpproduto                => 4); --Cartão
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_objeto_clob);
    dbms_lob.freetemporary(vr_objeto_clob);

    -- Gravar
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se ainda nao houve geracao id Acionamento
      IF vr_nrtransacao = 0 THEN
        -- Para cada requisicao sera criado um numero de transacao
        este0001.pc_grava_acionamento(pr_cdcooper                 => rw_aciona.cdcooper,
                                      pr_cdagenci                 => 1,
                                      pr_cdoperad                 => 'MOTOR',
                                      pr_cdorigem                 => 9,
                                      pr_nrctrprp                 => NULL,
                                      pr_nrdconta                 => rw_aciona.nrdconta,
                                      pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno
                                      pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE AUTO',
                                      pr_dsuriservico             => pr_namehost,
                                      pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
                                      pr_cdstatus_http            => 0,
                                      pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao    => NULL,
                                      pr_idacionamento            => vr_nrtransacao,
                                      pr_dscritic                 => vr_dscritic,
                                      pr_tpproduto                => 4); --Cartão

        IF vr_dscritic IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                     || ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise '
                                                     || ' para conta '|| rw_aciona.nrdconta||': '||SQLERRM,
                                     pr_nmarqlog     => gene0001.fn_param_sistema
                                                            (pr_nmsistem => 'CRED',
                                                             pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
      END IF;

      -- Gera retorno da proposta para a esteira
      pc_gera_retor_proposta_esteira(pr_status      => vr_status      --> Status
                                    ,pr_nrtransacao => vr_nrtransacao --> Numero da transacao
                                    ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                    ,pr_dscritic    => vr_dscritic    --> Descricao critica
                                    ,pr_msg_detalhe => vr_msg_detalhe --> Mensagem de detalhe
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                    ,pr_retxml      => pr_retxml);
      -- Gravar
      COMMIT;
        
    WHEN OTHERS THEN
      -- Se ainda nao houve geracao id Acionamento
      IF vr_nrtransacao = 0 THEN
        -- Para cada requisicao sera criado um numero de transacao
        este0001.pc_grava_acionamento(pr_cdcooper                 => rw_aciona.cdcooper,
                                      pr_cdagenci                 => 1,
                                      pr_cdoperad                 => 'MOTOR',
                                      pr_cdorigem                 => 9,
                                      pr_nrctrprp                 => NULL,
                                      pr_nrdconta                 => rw_aciona.nrdconta,
                                      pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno
                                      pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE PROPOSTA',
                                      pr_dsuriservico             => pr_namehost,
                                      pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
                                      pr_cdstatus_http            => 0,
                                      pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao    => NULL,
                                      pr_idacionamento            => vr_nrtransacao,
                                      pr_dscritic                 => vr_dscritic,
                                      pr_tpproduto                => 4); --Cartão

        IF vr_dscritic IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                     || ' - WEBS0001 --> Erro ao gravar acionamento Retorno Analise'
                                                     || ' para conta ' || rw_aciona.nrdconta||': '||SQLERRM,
                                     pr_nmarqlog     => gene0001.fn_param_sistema
                                                            (pr_nmsistem => 'CRED',
                                                             pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
      END IF;

      -- Somente se ocorreu encontro da proposta
      pc_gera_retor_proposta_esteira(pr_status      => 500              --> Status
                                    ,pr_nrtransacao => vr_nrtransacao   --> Numero transacao
                                    ,pr_cdcritic    => 978              --> Codigo da critica
                                    ,pr_msg_detalhe => 'Retorno Analise Automatica '
                                                    || 'nao foi atualizado, ocorreu '
                                                    || 'uma erro interno no sistema.(10)'||': '||SQLERRM
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                    ,pr_retxml      => pr_retxml);

      -- Enviar LOG geral, independente de ter encontro de proposta
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 3,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - WEBS0001 --> Nao foi possivel atualizar retorno da Analise '
                                                  || 'Automatica da proposta ' || vr_nrtransacao ||': '||SQLERRM,
                                 pr_nmarqlog     => gene0001.fn_param_sistema
                                                        (pr_nmsistem => 'CRED',
                                                         pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- Gravar
      COMMIT;
  END pc_retorno_analise_cartao;
  
END WEBS0001;
/
