CREATE OR REPLACE PACKAGE CECRED.WEBS0001 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0001
  --  Sistema  : Rotinas referentes ao WebService de Propostas
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Janeiro - 2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de propostas
  --
  -- Alteracoes:
  --
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
																			 ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
																			 ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
																			 ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
																			 ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
																			 ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
																			 ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
																			 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
																			 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																			 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																			 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
																			 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
	                             
END WEBS0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WEBS0001 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0001
  --  Sistema  : Rotinas referentes ao WebService de propostas
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Janeiro - 2016.                   Ultima atualizacao: 05/05/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de propostas
  --
  -- Alteracoes: 05/05/2017 - Package adaptada para prever o retorno do Motor
	--                          de crédito - Projeto 337 - Motor de Crédito. (Reinert)
  --
  ---------------------------------------------------------------------------  
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
        UPDATE tbepr_acionamento a
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
               crawepr.qtpreemp
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
                                 
      vr_txjuranu := TRUNC((POWER(1 + (rw_crawepr.txdiaria / 100), 360) - 1) * 100, 5);
      vr_txjurnom := REPLACE(TO_CHAR(TRUNC(((POWER(1 + (vr_txjuranu / 100), 1/12) - 1) * 12) * 100, 5)),',','.');
      vr_txjurefp := REPLACE(TRIM(TO_CHAR(vr_txjureft,'99999999990D00')),',','.');
      vr_vlrtxcet := REPLACE(TRIM(TO_CHAR(rw_crawepr.percetop,'99999999990D00000')),',','.');
      vr_vlpreemp := REPLACE(TRIM(TO_CHAR(rw_crawepr.vlpreemp,'9999999999990D00')),',','.');
      
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
                                     pr_tpdetaxa => '01',
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
                                    pr_tpdetaxa => '01',
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
																					,pr_nrnotrat    IN NUMBER   DEFAULT NULL     --> Valor do rating calculado para a operação
																					,pr_nrinfcad    IN NUMBER   DEFAULT NULL     --> Valor do item Informações Cadastrais calculado no Rating
																					,pr_nrliquid    IN NUMBER   DEFAULT NULL     --> Valor do item Liquidez calculado no Rating
																					,pr_nrgarope    IN NUMBER   DEFAULT NULL     --> Valor das Garantias calculada no Rating
																					,pr_nrparlvr    IN NUMBER   DEFAULT NULL     --> Valor do Patrimônio Pessoal Livre calculado no Rating
																					,pr_nrperger    IN NUMBER   DEFAULT NULL     --> Valor da Percepção Geral da Empresa calculada no Rating
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
     Data    : Janeiro/16.                    Ultima atualizacao: 30/05/2016

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
      
      vr_nrdrowid      ROWID;
      vr_exc_saida     EXCEPTION;
      vr_exc_erro_500  EXCEPTION;
    BEGIN
      
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
        pr_msg_detalhe := 'Parecer nao foi atualizado, a proposta nao foi encontrada no sistema Ayllos.';
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
        pr_msg_detalhe := 'Parecer nao foi atualizado, a conta-corrente nao foi encontrada no sistema Ayllos.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      --> Tratar para nao validar criticas qnt for 99-expirado
      IF pr_insitapr <> 99 THEN
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
          pr_msg_detalhe := 'Parecer nao foi atualizado, proposta nao foi enviada para a esteira de credito.';
          RAISE vr_exc_saida;
        END IF;
      END IF; --> Fim IF pr_insitapr <> 99 THEN
      
      -- Proposta Expirado
      IF rw_crawepr.insitest = 4 THEN
        pr_status      := 202;
        pr_cdcritic    := 975;
        pr_msg_detalhe := 'Parecer nao foi atualizado, o prazo para analise da proposta exipirou.';
        RAISE vr_exc_saida;
      END IF;
      
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
        pr_msg_detalhe := 'Parecer da proposta nao foi atualizado, a proposta ja esta efetivada no sistema Ayllos.';
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
                ,crawepr.dtdscore = NVL(pr_dtdscore,nvl(crawepr.dtdscore,trunc(SYSDATE)))
                ,crawepr.dsdscore = NVL(pr_dsdscore,crawepr.dsdscore)
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
                          ,pr_dsorigem => 'AYLLOS'
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
     
     SELECT
       CASE pr_insitapr
        WHEN  0 THEN 'NAO ANALISADO'
        WHEN  1 THEN 'APROVADO'
        WHEN  2 THEN 'NAO APROVADO'
        WHEN  4 THEN 'REFAZER'
        WHEN  3 THEN 'COM RESTRICAO'
        WHEN 99 THEN 'EXPIRADO'
        ELSE 'Desconhecida'
      END
      INTO vr_dssitapr
      FROM dual;
      
      -- Para cada requisicao sera criado um numero de transacao
      ESTE0001.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                     pr_cdagenci                 => 1, 
                                     pr_cdoperad                 => 'ESTEIRA',
                                     pr_cdorigem                 => 9,
                                     pr_nrctrprp                 => pr_nrctremp,
                                     pr_nrdconta                 => pr_nrdconta,
                                     pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                     pr_dsoperacao               => 'RETORNO PROPOSTA - '||vr_dssitapr,
                                     pr_dsuriservico             => pr_namehost,
                                     pr_dtmvtolt                 => NULL,
                                     pr_cdstatus_http            => 0,
                                     pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                     pr_dsresposta_requisicao    => NULL,
                                     pr_idacionamento            => vr_nrtransacao,
                                     pr_dscritic                 => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || pr_nrctremp ||': '||SQLERRM,
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
        vr_msg_detalhe := 'Parecer nao foi atualizado, o processo batch CECRED esta em execucao.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Proposta de Emprestimo
      IF pr_tpprodut = 1 THEN
        -- Atualiza os dados da proposta do servico 01
        pc_atualiza_prop_srv_emprestim(pr_cdcooper    => pr_cdcooper    --> Codigo da cooperativa
                                      ,pr_nrdconta    => pr_nrdconta    --> Numero da conta
                                      ,pr_nrctremp    => pr_nrctremp    --> Numero do contrato
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
          ESTE0001.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                         pr_cdagenci                 => 1, 
                                         pr_cdoperad                 => 'ESTEIRA',
                                         pr_cdorigem                 => 9,
                                         pr_nrctrprp                 => pr_nrctremp,
                                         pr_nrdconta                 => pr_nrdconta,
                                         pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                         pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO PROPOSTA - '||vr_dssitapr,
                                         pr_dsuriservico             => NULL,
                                         pr_dtmvtolt                 => NULL,
                                         pr_cdstatus_http            => 0,
                                         pr_dsconteudo_requisicao    => NULL,
                                         pr_dsresposta_requisicao    => NULL,
                                         pr_idacionamento            => vr_nrtransacao,
                                         pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || pr_nrctremp ||': '||SQLERRM,
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
          ESTE0001.pc_grava_acionamento( pr_cdcooper                 => pr_cdcooper,
                                         pr_cdagenci                 => 1, 
                                         pr_cdoperad                 => 'ESTEIRA',
                                         pr_cdorigem                 => 9,
                                         pr_nrctrprp                 => pr_nrctremp,
                                         pr_nrdconta                 => pr_nrdconta,
                                         pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                         pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO PROPOSTA - '||vr_dssitapr,
                                         pr_dsuriservico             => NULL,
                                         pr_dtmvtolt                 => NULL,
                                         pr_cdstatus_http            => 0,
                                         pr_dsconteudo_requisicao    => NULL,
                                         pr_dsresposta_requisicao    => NULL,
                                         pr_idacionamento            => vr_nrtransacao,
                                         pr_dscritic                 => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - WEBS0001 --> Erro ao gravar acionamento para conta '||pr_nrdconta||' contrato' || pr_nrctremp ||': '||SQLERRM,
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
     Data    : Abril/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gravar mensagem de erro no LOG

     Observacao: -----
     
     Alteracoes:      
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
      vr_des_log  := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                     ' - ' || 
                     'Requisicao: ' || pr_dsrequis  || 
                     ' - ' || 
                     'Resposta: ' || pr_dsmessag;
                     
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
																			 ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
																			 ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
																			 ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
																			 ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
																			 ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
																			 ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
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
	 Data    : Maio/17.                    Ultima atualizacao:

	 Dados referentes ao programa:

	 Frequencia: Sempre que for chamado

	 Objetivo  : Receber as informações da análise automática da Esteira e gravar 
	             na base

	 Observacao: -----
     
	 Alteracoes:      
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
          FROM tbepr_acionamento aci
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
              ,wpr.cdagenci
              ,wpr.cdopeste
              ,wpr.insitest
              ,decode(wpr.insitapr, 0, 'EM ESTUDO', 1, 'APROVADO', 2, 'NAO APROVADO', 3, 'RESTRICAO', 4, 'REFAZER', 'SITUACAO DESCONHECIDA') dssitapr
              ,wpr.rowid
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp
           AND wpr.dsprotoc = pr_dsprotoc/*
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
			vr_nrparlvr VARCHAR2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
			vr_nrperger VARCHAR2(100); --> Valor da Percepção Geral da Empresa calculada no Rating
      vr_desscore VARCHAR2(100); --> Descricao do Score Boa Vista
      vr_datscore VARCHAR2(100); --> Data do Score Boa Vista
      
      -- Bloco PLSQL para chamar a execução paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Job name dos processos criados
      vr_jobname VARCHAR2(100);
      
      -- Variaveis para DEBUG
      vr_flgdebug VARCHAR2(100) := 'S';
      vr_idaciona tbepr_acionamento.idacionamento%TYPE;
      
           
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
        este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                      pr_cdagenci              => 1,          
                                      pr_cdoperad              => 'MOTOR',          
                                      pr_cdorigem              => pr_cdorigem,          
                                      pr_nrctrprp              => rw_crawepr.nrctremp,      
                                      pr_nrdconta              => rw_crawepr.nrdconta,  
                                      pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                      pr_dsoperacao            => 'INICIO RETORNO ANALISE',       
                                      pr_dsuriservico          => pr_namehost,       
                                      pr_dtmvtolt              => trunc(sysdate),       
                                      pr_cdstatus_http         => 0,
                                      pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao => null,
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
        ESTE0001.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
                                      pr_cdagenci                 => 1, 
                                      pr_cdoperad                 => 'MOTOR',
                                      pr_cdorigem                 => pr_cdorigem,
                                      pr_nrctrprp                 => rw_crawepr.nrctremp,
                                      pr_nrdconta                 => rw_crawepr.nrdconta,
                                      pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
                                      pr_dsoperacao               => 'RETORNO ANALISE AUTOMATICA - '||vr_dssitret,
                                      pr_dsuriservico             => pr_namehost,
                                      pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
                                      pr_cdstatus_http            => 200,
                                      pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao    => NULL,
                                      pr_dsprotocolo              => pr_dsprotoc,
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
                       || 'CECRED esta em execucao.';
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
      vr_nrnotrat := fn_converte_null(pr_nrnotrat);
      vr_nrinfcad := fn_converte_null(pr_nrinfcad);
      vr_nrliquid := fn_converte_null(pr_nrliquid);
      vr_nrgarope := fn_converte_null(pr_nrgarope);
      vr_nrparlvr := fn_converte_null(pr_nrparlvr);
      vr_nrperger := fn_converte_null(pr_nrperger);
      vr_desscore := fn_converte_null(pr_desscore);
      vr_datscore := fn_converte_null(pr_datscore);
      
			-- Buscar o tipo de pessoa
			OPEN cr_crapass(pr_cdcooper => rw_crawepr.cdcooper
			               ,pr_nrdconta => rw_crawepr.nrdconta);
			FETCH cr_crapass INTO vr_inpessoa;
			CLOSE cr_crapass;
      
			IF lower(pr_dsresana) IN ('aprovar', 'reprovar', 'derivar') THEN
        -- NEste caso testes retornos obrigatórios
        IF (TRIM(vr_indrisco) IS NULL OR
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
																		,pr_nrnotrat    => gene0002.fn_char_para_number(vr_nrnotrat)    --> Calculo do Rating na Analise 
																		,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informação Cadastral da Analise 
																		,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise 
																		,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise 
																		,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise 
																		,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepção Geral Empresa na Analise 
																		,pr_dsdscore    => vr_desscore    --> Descrição Score Boa Vista
																		,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD')    --> Data Score Boa Vista
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
        este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                      pr_cdagenci              => 1,          
                                      pr_cdoperad              => 'MOTOR',          
                                      pr_cdorigem              => pr_cdorigem,          
                                      pr_nrctrprp              => rw_crawepr.nrctremp,      
                                      pr_nrdconta              => rw_crawepr.nrdconta,  
                                      pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                      pr_dsoperacao            => 'FINAL RETORNO ANALISE',       
                                      pr_dsuriservico          => pr_namehost,       
                                      pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                      pr_cdstatus_http         => 0,
                                      pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                      pr_dsresposta_requisicao => null,
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
            este0001.pc_grava_acionamento(pr_cdcooper              => rw_crawepr.cdcooper,         
                                          pr_cdagenci              => 1,          
                                          pr_cdoperad              => 'MOTOR',          
                                          pr_cdorigem              => pr_cdorigem,          
                                          pr_nrctrprp              => rw_crawepr.nrctremp,      
                                          pr_nrdconta              => rw_crawepr.nrdconta,  
                                          pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                          pr_dsoperacao            => 'FINAL RETORNO CONAUT',       
                                          pr_dsuriservico          => pr_namehost,       
                                          pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                          pr_cdstatus_http         => 0,
                                          pr_dsconteudo_requisicao => replace(pr_dsrequis,'&quot;','"'),
                                          pr_dsresposta_requisicao => null,
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
                     || 'ESTE0001.pc_incluir_proposta_est(pr_cdcooper => '||rw_crawepr.cdcooper ||chr(13)
                     || '                                ,pr_cdagenci => '||rw_crawepr.cdagenci ||chr(13)
                     || '                                ,pr_cdoperad => '''||rw_crawepr.cdopeste||''''||chr(13)
                     || '                                ,pr_cdorigem => 9'                    ||chr(13)
                     || '                                ,pr_nrdconta => '||rw_crawepr.nrdconta ||chr(13)
                     || '                                ,pr_nrctremp => '||rw_crawepr.nrctremp ||chr(13)
                     || '                                ,pr_dtmvtolt => to_date('''||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr'')'||chr(13)
                     || '                                ,pr_nmarquiv => NULL'                  ||chr(13)
                     || '                                ,pr_dsmensag => vr_dsmensag'           ||chr(13)
                     || '                                ,pr_cdcritic => vr_cdcritic'           ||chr(13)
                     || '                                ,pr_dscritic => vr_dscritic);'         ||chr(13)
                     /*|| '  -- Em caso de erro '||chr(13)
                     || '  IF nvl(vr_cdcritic,0) >= 0 AND vr_dscritic IS NOT NULL THEN '||chr(13)
                     || '  -- Adicionar ao LOG e continuar o processo'||chr(13)
                     || '  btch0001.pc_gera_log_batch(pr_cdcooper     => 3,'||chr(13)
                     || '                             pr_ind_tipo_log => 2,'||chr(13)
                     || '                             pr_des_log      => '''||to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')||''''||chr(13)
                     || '                                             || '' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '''||chr(13)
                     || '                                             || '' do Protocolo: '||pr_dsprotoc||''''||chr(13)
                     || '                                             || '', erro: ''||vr_cdcritic||''-''||vr_dscritic,'||chr(13)
                     || '                             pr_nmarqlog     => '''||gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE')||''','||chr(13)
                     || '                             pr_flnovlog     => ''N'','||chr(13)
                     || '                             pr_flfinmsg     => ''S'','||chr(13)
                     || '                             pr_dsdirlog     => NULL,'||chr(13)
                     || '                             pr_dstiplog     => ''O'','||chr(13)
                     || '                             PR_CDPROGRAMA   => NULL);'||chr(13)
                     || '  END IF;'||chr(13)*/
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
          ESTE0001.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
																				pr_cdagenci                 => 1, 
																				pr_cdoperad                 => 'MOTOR',
																				pr_cdorigem                 => 9,
																				pr_nrctrprp                 => rw_crawepr.nrctremp,
																				pr_nrdconta                 => rw_crawepr.nrdconta,
																				pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
																				pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE AUTO – '
																																		||rw_crawepr.dssitapr,
																				pr_dsuriservico             => pr_namehost,
																				pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
																				pr_cdstatus_http            => 0,
																				pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
																				pr_dsresposta_requisicao    => NULL,
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
          ESTE0001.pc_grava_acionamento(pr_cdcooper                 => rw_crawepr.cdcooper,
																				pr_cdagenci                 => 1, 
																				pr_cdoperad                 => 'MOTOR',
																				pr_cdorigem                 => 9,
																				pr_nrctrprp                 => rw_crawepr.nrctremp,
																				pr_nrdconta                 => rw_crawepr.nrdconta,
																				pr_tpacionamento            => 2,  -- 1 - Envio, 2 – Retorno 
																				pr_dsoperacao               => 'ERRO ACIONAMENTO RETORNO ANALISE '
																																		|| 'PROPOSTA - '||rw_crawepr.dssitapr,
																				pr_dsuriservico             => pr_namehost,
																				pr_dtmvtolt                 => rw_crapdat.dtmvtolt,
																				pr_cdstatus_http            => 0,
																				pr_dsconteudo_requisicao    => replace(pr_dsrequis,'&quot;','"'),
																				pr_dsresposta_requisicao    => NULL,
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
END WEBS0001;
/
