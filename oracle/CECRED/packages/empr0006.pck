CREATE OR REPLACE PACKAGE CECRED.EMPR0006 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0006
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : Carlos Rafael Tanholi - CECRED
  --  Data     : Maio - 2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas relacionadas a Portabilidade de Credito
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    --Tipo de Registro para Extrato de Emprestimo (b1wgen0002tt.i/tt-extrato_epr) 
    TYPE typ_reg_retorno_xml IS RECORD
      (ispbif                NUMBER
      ,identdpartadmdo       NUMBER
      ,cnpjbase_iforcontrto  NUMBER
      ,nuportlddctc          VARCHAR2(21)
      ,codcontrtoor          VARCHAR2(40)
      ,tpcontrto             VARCHAR2(4)
      ,tpcli                 VARCHAR2(1)
      ,cnpj_cpfcli           NUMBER
      ,stportabilidade       VARCHAR2(3));  
    TYPE typ_tab_retorno_xml IS TABLE OF typ_reg_retorno_xml INDEX BY PLS_INTEGER;

  /* verifica se eh uma proposta de emprestimo de portabilidade */

  PROCEDURE pc_possui_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                   ,pr_nrdconta IN crapcop.nrdconta%TYPE --Numero da Conta
                                   ,pr_nrctremp IN crawepr.nrctremp%TYPE --Numero de Emprestimo
                                   ,pr_err_efet OUT PLS_INTEGER          --Erro na efetivacao (0/1)
                                   ,pr_des_reto OUT CHAR                 --Portabilidade(S/N)
                                   ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2);           --Descrição da crítica
  
  /* verifica se eh uma proposta de emprestimo de portabilidade */
  PROCEDURE pc_possui_portabilidade_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                       ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero de Emprestimo
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                       
  /* retorna finalidade de portabilidade */
  PROCEDURE pc_consulta_finalidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Portabilidade(S/N)  
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro                                   
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  /* retorna um XML com os dados da proposta de portabilidade */
  PROCEDURE pc_consulta_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE --Numero da Conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE --Numero de Emprestimo
                                     ,pr_tipo_consulta IN VARCHAR2         --(Proposta|Contrato)                                                                        
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Portabilidade(S/N)  
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro                                   
                                     ,pr_des_erro OUT VARCHAR2);           --Portabilidade(S/N)
                                      
  /* retorna um XML com os dados da proposta de portabilidade */
  PROCEDURE pc_consulta_portabil_crt(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Numero de Emprestimo
                                    ,pr_tpoperacao IN tbepr_portabilidade.tpoperacao%TYPE DEFAULT 0 --> tipo de portabilidade (0 - todos | 1 - compra | 2 - venda)
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType);   --> Arquivo de retorno do XML
  
  PROCEDURE pc_valida_portabilidade(pr_operacao IN VARCHAR2 
                                   ,pr_nrcnpjbase_if_origem IN tbepr_portabilidade.nrcnpjbase_if_origem%TYPE    
                                   ,pr_nmif_origem          IN tbepr_portabilidade.nmif_origem%TYPE
                                   ,pr_nrcontrato_if_origem IN tbepr_portabilidade.nrcontrato_if_origem%TYPE                                   
                                   ,pr_cdmodali IN VARCHAR2
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo             OUT VARCHAR2             --> Nome do campo com erro                                   
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo    

  --insere as novas portabilidades
  PROCEDURE pc_cadastra_portabilidade(pr_cdcooper             IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta             IN crapass.nrdconta%TYPE
                                     ,pr_nrctremp             IN crawepr.nrctremp%TYPE
                                     ,pr_tpoperacao           IN NUMBER -- tipo operacao (1-compra|2-venda)
                                     ,pr_nrcnpjbase_if_origem IN tbepr_portabilidade.nrcnpjbase_if_origem%TYPE    
                                     ,pr_nmif_origem          IN tbepr_portabilidade.nmif_origem%TYPE
                                     ,pr_nrcontrato_if_origem IN tbepr_portabilidade.nrcontrato_if_origem%TYPE
                                     ,pr_xmllog               IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic             OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic             OUT VARCHAR2             --> Descricao da critica
                                     ,pr_retxml               IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo             OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro             OUT VARCHAR2);           --> Erros do processo


  /* Rotina referente a consulta de carencias cadastrados */
  PROCEDURE pc_carrega_modalidades(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  -- Gera relatório pdf a partir do log de críticas de efetivação e liquidação de portabilidade
  PROCEDURE pc_gera_relatorio_prt(pr_cdopcao  IN VARCHAR2              --> Opcao (C: liquidação/D: efetivação)
                                 ,pr_dtlogini IN VARCHAR2              --> Data inicial da critica
                                 ,pr_dtlogfin IN VARCHAR2              --> Data final da critica
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
																 
		/* Procedure para Atualizar Situacao */														 
PROCEDURE pc_atualizar_situacao(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cód. Cooperativa
                               ,pr_idservic IN INTEGER                          --> Tipo de servico(1-Proponente/2-Credora)
		                           ,pr_cdlegado IN VARCHAR2                         --> Codigo Legado
															 ,pr_nrispbif IN VARCHAR2                         --> Numero ISPB IF
															 ,pr_nrcontrl IN VARCHAR2                         --> Numero de Controle
															 ,pr_nuportld IN VARCHAR2                         --> Numero Portabilidade CTC
															 ,pr_cdsittit IN VARCHAR2                         --> Codigo Situacao Titulo
															 ,pr_flgrespo OUT NUMBER                          --> 1 - Se o registro na JDCTC for atualizado com sucesso
															 ,pr_des_erro OUT VARCHAR2                        --> Indicador erro OK/NOK
															 ,pr_dscritic OUT VARCHAR2);                      --> Descricao erro

  /* Consulta situacao da portabilidade na JDCTC */
  PROCEDURE pc_consulta_situacao(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cdoigo da cooperativa
                                ,pr_idservic IN INTEGER          --Tipo de servico(1-Proponente/2-Credora)
                                ,pr_cdlegado IN VARCHAR2         --Codigo Legado
                                ,pr_nrispbif IN NUMBER           --Numero ISPB IF (085)
                                ,pr_idparadm IN NUMBER           --Identificador Participante Administrado
                                ,pr_ispbifcr IN NUMBER           --ISPB IF Credora Original do Contrato
                                ,pr_nrunipor IN VARCHAR2         --Número único da portabilidade na CTC
                                ,pr_cdconori IN VARCHAR2         --Código Contrato Original*
                                ,pr_tpcontra IN VARCHAR2         --Tipo Contrato*
                                ,pr_tpclient IN CHAR             --Tipo Cliente - Fixo 'F'*
                                ,pr_cnpjcpf  IN NUMBER           --CNPJ CPF Cliente*
                                ,pr_tab_portabilidade OUT  typ_reg_retorno_xml --Dados Portabilidade JDCTC
                                ,pr_des_erro OUT VARCHAR2        --Indicador erro OK/NOK
                                ,pr_dscritic OUT VARCHAR2);      --Descricao erro
																
	/* Consulta situacao da portabilidade na JDCTC para o Ayllos Caractere */
	PROCEDURE pc_consulta_situacao_car(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
																		,pr_idservic IN INTEGER               --Tipo de servico(1-Proponente/2-Credora)
																		,pr_cdlegado IN VARCHAR2              --Codigo Legado
																		,pr_nrispbif IN NUMBER                --Numero ISPB IF (085)
																		,pr_idparadm IN NUMBER                --Identificador Participante Administrado
																		,pr_cnpjbase IN NUMBER                --CNPJ Base IF Credora Original Contrato
																		,pr_nrunipor IN VARCHAR2              --Número único da portabilidade na CTC
																		,pr_cdconori IN VARCHAR2              --Código Contrato Original*
																		,pr_tpcontra IN VARCHAR2              --Tipo Contrato*
																		,pr_tpclient IN CHAR                  --Tipo Cliente - Fixo 'F'*
																		,pr_cnpjcpf  IN NUMBER                --CNPJ CPF Cliente*
																		--,pr_idgerlog  IN INTEGER            --Identificador de Log (0 – Não / 1 – Sim) 																 
																		,pr_clobxmlc OUT CLOB                 --XML com informações de LOG
																		,pr_des_erro OUT VARCHAR2             --Indicador erro OK/NOK
																		,pr_dscritic OUT VARCHAR2);           --Descrição da crítica																

  /* Aprovacao da portabilidade na JDCTC */
  PROCEDURE pc_aprovar_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato Emprestimo
                                    ,pr_nrunico_portabilidade IN tbepr_portabilidade.nrunico_portabilidade%TYPE --Numero da portabilidade
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --Erros do processo

  /* Procedure para Cancelar Situacao */
    PROCEDURE pc_cancelar_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cód. Cooperativa
		                                   ,pr_idservic IN NUMBER                           --> Tipo de servico(1-Proponente/2-Credora)
		                                   ,pr_cdlegado IN VARCHAR2                         --> Codigo Legado
																		   ,pr_nrispbif IN NUMBER                           --> Numero ISPB IF
																		   ,pr_inparadm IN NUMBER                           --> Identificador Participante Administrado
																		   ,pr_cnpjifcr IN NUMBER                           --> CNPJ Base IF Credora Original Contrato
																		   ,pr_nuportld IN VARCHAR2                         --> Numero Portabilidade CTC
																		   ,pr_mtvcance IN VARCHAR2                         --> Motivo Cancelamento Portabilidade
																		   ,pr_flgrespo OUT NUMBER                          --> 1 - Se o registro na JDCTC for atualizado com sucesso
																		   ,pr_des_erro OUT VARCHAR2                        --> Indicador erro OK/NOK
																		   ,pr_dscritic OUT VARCHAR2);                      --> Descricao erro

	/* Gerar termo de portabilidade */
  PROCEDURE pc_gera_termo(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo da cooperativa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato Emprestimo
                         ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --Erros do processo
												 
	/* Procedure para Incluir Pessoal */
  PROCEDURE pc_incluir_pessoal(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cód. cooperativa
                              ,pr_idservic IN INTEGER               --> Tipo de servico(1-Proponente/2-Credora)
		                          ,pr_cdlegado IN VARCHAR2              --> Codigo Legado
														  ,pr_nrispbif IN VARCHAR2              --> Numero ISPB IF
														  ,pr_inparadm IN VARCHAR2              --> Identificador Participante Administrado
															,pr_cdcntori IN VARCHAR2              --> Contrato Original
															,pr_tpcontrt IN VARCHAR2              --> Tipo de contrato(modalidade)
														  ,pr_cnpjifcr IN VARCHAR2              --> CNPJ Base IF Credora Original Contrato
															,pr_dtrefsld IN DATE                  --> Data Referência Saldo Devedor Contábil para Proposta
															,pr_vlslddev IN VARCHAR2              --> Valor Saldo Devedor Contábil para Proposta
															,pr_cnpjcpfc IN VARCHAR2              --> CNPJ/CPF do Cliente
															,pr_nmclient IN VARCHAR2              --> Nome do Cliente
															,pr_nrtelcli IN VARCHAR2              --> Telefone do cliente
															,pr_tpdetaxa IN VARCHAR2              --> Tipo de taxa
															,pr_txjurnom IN VARCHAR2              --> Taxa Juros Nominal % a.a.
															,pr_txjureft IN VARCHAR2              --> Taxa Juros Efetiva % a.a.
															,pr_txcet    IN VARCHAR2              --> Taxa CET
															,pr_cddmoeda IN VARCHAR2              --> Código da moeda
															,pr_regamrtz IN VARCHAR2              --> Regime Amortização
															,pr_dtcontop IN DATE                  --> Data Contratação Operação
															,pr_qtdtotpr IN VARCHAR2              --> Quantidade Total Parcelas Contrato
															,pr_flxpagto IN VARCHAR2              --> Fluxo de Pagamento
													    ,pr_vlparemp IN VARCHAR2              --> Valor Face Parcelas Contrato
															,pr_dtpripar IN DATE                  --> Data Vencimento Primeira Parcela Contrato
															,pr_dtultpar IN DATE                  --> Data Vencimento Última Parcela Contrato
															,pr_dsendcar IN VARCHAR2              --> Logradouro Endereço Carta Portabilidade
															,pr_dscmpend IN VARCHAR2              --> Complemento Endereço Carta Portabilidade
															,pr_nrentere IN VARCHAR2              --> Numero Endereço Carta Portabilidade
															,pr_cidadend IN VARCHAR2              --> Cidade Endereço Carta Portabilidade
															,pr_ufendere IN VARCHAR2              --> UF Endereço Carta Portabilidade
															,pr_cepender IN VARCHAR2              --> CEP Endereço Carta Portabilidade
															,pr_idsolici OUT INTEGER              --> ID da solicitação (0 - Se não foi realizada com sucesso) 
														  ,pr_des_erro OUT VARCHAR2             --> Indicador erro OK/NOK
														  ,pr_dscritic OUT VARCHAR2);           --> Descricao erro
															
	/* Procedure para Incluir Pessoal */
  PROCEDURE pc_incluir_veicular(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cód. cooperativa
                               ,pr_idservic IN INTEGER               --> Tipo de servico(1-Proponente/2-Credora)
		                           ,pr_cdlegado IN VARCHAR2              --> Codigo Legado
														   ,pr_nrispbif IN VARCHAR2              --> Numero ISPB IF
														   ,pr_inparadm IN VARCHAR2              --> Identificador Participante Administrado
															 ,pr_cdcntori IN VARCHAR2              --> Contrato Original
															 ,pr_tpcontrt IN VARCHAR2              --> Tipo de contrato(modalidade)
														   ,pr_cnpjifcr IN VARCHAR2              --> CNPJ Base IF Credora Original Contrato
															 ,pr_dtrefsld IN DATE                  --> Data Referência Saldo Devedor Contábil para Proposta
															 ,pr_vlslddev IN VARCHAR2              --> Valor Saldo Devedor Contábil para Proposta
															 ,pr_cnpjcpfc IN VARCHAR2              --> CNPJ/CPF do Cliente
															 ,pr_nmclient IN VARCHAR2              --> Nome do Cliente
															 ,pr_nrtelcli IN VARCHAR2              --> Telefone do cliente
															 ,pr_tpdetaxa IN VARCHAR2              --> Tipo de taxa
															 ,pr_txjurnom IN VARCHAR2              --> Taxa Juros Nominal % a.a.
															 ,pr_txjureft IN VARCHAR2              --> Taxa Juros Efetiva % a.a.
															 ,pr_txcet    IN VARCHAR2              --> Taxa CET
															 ,pr_cddmoeda IN VARCHAR2              --> Código da moeda
															 ,pr_regamrtz IN VARCHAR2              --> Regime Amortização
															 ,pr_dtcontop IN DATE                  --> Data Contratação Operação
															 ,pr_qtdtotpr IN VARCHAR2              --> Quantidade Total Parcelas Contrato
															 ,pr_flxpagto IN VARCHAR2              --> Fluxo de Pagamento
															 ,pr_vlparemp IN VARCHAR2              --> Valor Face Parcelas Contrato
															 ,pr_dtpripar IN DATE                  --> Data Vencimento Primeira Parcela Contrato
															 ,pr_dtultpar IN DATE                  --> Data Vencimento Última Parcela Contrato
															 ,pr_dsendcar IN VARCHAR2              --> Logradouro Endereço Carta Portabilidade
															 ,pr_nrentere IN VARCHAR2              --> Numero Endereço Carta Portabilidade
															 ,pr_cidadend IN VARCHAR2              --> Cidade Endereço Carta Portabilidade
															 ,pr_ufendere IN VARCHAR2              --> UF Endereço Carta Portabilidade
															 ,pr_cepender IN VARCHAR2              --> CEP Endereço Carta Portabilidade
															 ,pr_idsolici OUT INTEGER              --> ID da solicitação (0 - Se não foi realizada com sucesso) 
														   ,pr_des_erro OUT VARCHAR2             --> Indicador erro OK/NOK
														   ,pr_dscritic OUT VARCHAR2);           --> Descricao erro												 
  
  -- Verifica dados da proposta de portabilidade no JDCTC.
  PROCEDURE pc_verifica_dados_JDCTC_prt(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_nrdconta IN crawepr.nrdconta%TYPE --> número da conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Data da critica
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                       
	/* verifica se pode imprimir a declaração de isenção de IOF */
	PROCEDURE pc_pode_impr_dec_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
										  ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
										  ,pr_nrctrato IN crawepr.nrctremp%TYPE --> Numero de Emprestimo
										  ,pr_xmllog   IN VARCHAR2 --> XML com informac?es de LOG
										  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
										  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
										  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
										  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
										  ,pr_des_erro OUT VARCHAR2); --> Erros do processo
end EMPR0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0006 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0006
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : Carlos Rafael Tanholi - CECRED
  --  Data     : Maio - 2015.                   Ultima atualizacao: 24/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas relacionadas a Portabilidade de Credito
  --
  -- Alteracoes: 05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
  --                          (Adriano).
  --
  --             08/04/2016 - Correcao na pc_verifica_dados_JDCTC_prt especificamente na 
  --                          sequencia de validacoes das tags retornadas da JDCTC e 
  --                          alteracao das mensagem exibidas no retorno da rotina.
  --                         (SD 422199 - Carlos Rafael Tanholi)
  --
  --             24/08/2016 - Comentar para não apagar XML (Oscar)    
  --
  ---------------------------------------------------------------------------------------------------------------

  /* verifica se eh uma proposta de emprestimo de portabilidade */
  PROCEDURE pc_possui_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                   ,pr_nrdconta IN crapcop.nrdconta%TYPE --Numero da Conta
                                   ,pr_nrctremp IN crawepr.nrctremp%TYPE --Numero de Emprestimo
                                   ,pr_err_efet OUT PLS_INTEGER          --Erro na efetivacao (0/1)
                                   ,pr_des_reto OUT CHAR                 --Portabilidade(S/N)
                                   ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS         --Descrição da crítica
                                   
  BEGIN
  
    /* .............................................................................

     Programa: pc_possui_portabilidade
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 03/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de verificacao de portabilidade.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      CURSOR cr_tbepr_portabilidade (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT nrunico_portabilidade
              ,flgerro_efetivacao
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND tpoperacao = 1;
           
      rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;    
           
    BEGIN
      
      --Consulta o registro na tabela de portabilidade
      OPEN cr_tbepr_portabilidade(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          
      FETCH cr_tbepr_portabilidade INTO rw_tbepr_portabilidade;      
      
      IF cr_tbepr_portabilidade%FOUND THEN
         pr_des_reto := 'S';
      ELSE        
         pr_des_reto := 'N';
      END IF;
      
      --Flag de erro na efetivacao
      pr_err_efet := rw_tbepr_portabilidade.flgerro_efetivacao;
    
      CLOSE cr_tbepr_portabilidade;
    
    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        
    END;  

  END pc_possui_portabilidade;

  /* verifica se eh uma proposta de emprestimo de portabilidade */
  PROCEDURE pc_possui_portabilidade_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                       ,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero de Emprestimo
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                   
  BEGIN
  
    /* .............................................................................

     Programa: pc_possui_portabilidade
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 03/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de verificacao de portabilidade.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
     
    DECLARE
    
      --Variaveis
      vr_des_reto VARCHAR2(1);
      vr_err_efet INTEGER;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
    BEGIN
      -- Verifica se é portabilidade
      pc_possui_portabilidade(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_err_efet => vr_err_efet
                             ,pr_des_reto => vr_des_reto
                             ,pr_cdcritic => vr_dscritic
                             ,pr_dscritic => vr_dscritic);
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'ConfereDados'
                            ,pr_tag_cont => vr_des_reto
                            ,pr_des_erro => vr_dscritic);
    
    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  

  END pc_possui_portabilidade_web;

  /* retorna finalidade de portabilidade */
  PROCEDURE pc_consulta_finalidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Portabilidade(S/N)  
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro                                   
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo   
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_finalidade
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 22/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de finalidades de portabilidade (crapfin.tpfinali=2)

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_contador INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_xml_res XMLType;
      vr_des_erro VARCHAR(3); 
      
      
      /*CURSOR NA TABELA DE FINALIDADES (CRAPFIN)*/
      CURSOR cr_crapfin (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      
        SELECT cdfinemp, dsfinemp
          FROM crapfin
         WHERE cdcooper = pr_cdcooper
           AND tpfinali = 2;
      
      rw_crapfin cr_crapfin%ROWTYPE;       

    BEGIN
    
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);     
    
      --Busca dados da portabilidade
      OPEN cr_crapfin(pr_cdcooper);
          
      IF cr_crapfin%NOTFOUND THEN
          RAISE vr_exc_saida;
      ELSE        
             
         -- Criar cabeçalho do XML
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

         LOOP 
           FETCH cr_crapfin INTO rw_crapfin;
                              
           -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
           EXIT WHEN cr_crapfin%NOTFOUND; 
                              
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0,           pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crapfin.cdfinemp, pr_des_erro => vr_dscritic);
	         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dsfinemp', pr_tag_cont => rw_crapfin.dsfinemp, pr_des_erro => vr_dscritic);    
      
         END LOOP;            
         
         CLOSE cr_crapfin;                    
      
      END IF;


    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    
    END;                                         

  END pc_consulta_finalidade;

  /* retorna um XML com os dados da proposta de portabilidade */
  PROCEDURE pc_consulta_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE --Numero da Conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE --Numero de Emprestimo
                                     ,pr_tipo_consulta IN VARCHAR2         --(Proposta|Contrato)
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Portabilidade(S/N)  
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro                                   
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo                                           
  BEGIN
  
    /* .............................................................................

     Programa: pc_consulta_portabilidade
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 01/10/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta dos dados de portabilidade.

     Observacao: -----

     Alteracoes: 01/10/2015 - Alteracao na forma de carregamento da TAG nrunico_portabilidade
                              para a correta apresentacao das informacoes na tela de Portabilidade
                              (Projeto Portabilidade - Carlos Rafael Tanholi).

                 01/10/2015 - Alteracao na validacao da proposta de emprestimo de Portabilidade
                              com nova consistencia sobre o campo de data de aprovacao e situacao 
                              (Projeto Portabilidade - Lucas Reinert)
                              
                 23/11/2015 - Foi implementado o comando TRIM sobre o campo nrunico_portabilidade da 
                              tabela de portabilidade pois o mesmo possui valor default ' '(espaco).
                              (Projeto Portabilidade - Carlos Rafael Tanholi)
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_contador INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_xml_res XMLType;
      vr_des_erro VARCHAR(3); 
      
      vr_dssit_portabilidade VARCHAR(200);
      vr_cdmodali_portabilidade VARCHAR(4);
      vr_nrunico_portabilidade VARCHAR2(21);
      vr_nrcnpjbase_if_origem VARCHAR(20);
      
      vr_tab_portabilidade typ_reg_retorno_xml;
      
      /*CURSOR SOBRE EMPRESTIMOS DE PORTABILIDADE*/
      CURSOR cr_tbepr_portabilidade (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT tpoperacao
              ,nrunico_portabilidade
              ,nrcontrato_if_origem
              ,LPAD(nrcnpjbase_if_origem, 14, 0) AS nrcnpjbase_if_origem
              ,flgerro_efetivacao
              ,dtliquidacao
              ,dtaprov_portabilidade
              ,nmif_origem
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      
      rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;    
      

      /* CURSOR SOBRE PROPOSTAS DE EMPRESTIMOS */
      CURSOR cr_crawepr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapcop.nrdconta%TYPE
                        ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      
      SELECT craplcr.cdmodali || craplcr.cdsubmod AS cdmodali
            ,crawepr.insitapr
        FROM crawepr, craplcr
       WHERE crawepr.cdlcremp = craplcr.cdlcremp
         AND crawepr.cdcooper = craplcr.cdcooper
         AND crawepr.cdcooper = pr_cdcooper       
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp         
    GROUP BY craplcr.cdmodali,craplcr.cdsubmod, crawepr.insitapr;
           
      rw_crawepr cr_crawepr%ROWTYPE;    
      

      /* CURSOR SOBRE CONTRATOS DE EMPRESTIMOS */
      CURSOR cr_crapepr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapcop.nrdconta%TYPE
                        ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      
      SELECT craplcr.cdmodali || craplcr.cdsubmod AS cdmodali
        FROM crapepr, craplcr
       WHERE crapepr.cdlcremp = craplcr.cdlcremp
         AND crapepr.cdcooper = pr_cdcooper       
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp         
    GROUP BY craplcr.cdmodali,craplcr.cdsubmod;
           
      rw_crapepr cr_crapepr%ROWTYPE;    

     
      -- Buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagectl
              ,SUBSTR(LPAD(crapcop.nrdocnpj,14,0),1,8) cnpjbase
              ,LPAD(crapcop.nrdocnpj,14,0) nrdocnpj
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar os dados do banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT crapban.nrispbif 
          FROM crapban 
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;      
      
    
      -- Buscar o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT CASE crapass.inpessoa WHEN 1 
                 THEN LPAD(crapass.nrcpfcgc,11,0)
                 ELSE LPAD(crapass.nrcpfcgc,14,0)
               END nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      rw_crapass cr_crapass%ROWTYPE;    
    
      --cursor para tratamento das mensagens de retorno webservice  
      CURSOR cr_craprto(pr_cdoperac IN craprto.cdoperac%TYPE) IS
      
        SELECT dsretorn
          FROM craprto
         WHERE cdoperac = pr_cdoperac
           AND cdprodut = 2 --Portabilidade 
           AND nrtabela = 1;

      rw_craprto cr_craprto%ROWTYPE;    
    
    
    BEGIN
      
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);     
    
      --Busca dados da portabilidade
      OPEN cr_tbepr_portabilidade(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          
      IF cr_tbepr_portabilidade%NOTFOUND THEN
          CLOSE cr_tbepr_portabilidade;
          RAISE vr_exc_saida;
      ELSE        
             
         -- Criar cabeçalho do XML
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

         FETCH cr_tbepr_portabilidade INTO rw_tbepr_portabilidade;

         vr_nrcnpjbase_if_origem := GENE0002.fn_mask_cpf_cnpj(rw_tbepr_portabilidade.nrcnpjbase_if_origem, 2);
           
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0,           pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'tpoperacao', pr_tag_cont => rw_tbepr_portabilidade.tpoperacao, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcontrato_if_origem', pr_tag_cont => rw_tbepr_portabilidade.nrcontrato_if_origem, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcnpjbase_if_origem', pr_tag_cont => vr_nrcnpjbase_if_origem, pr_des_erro => vr_dscritic);         
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'flgerro_efetivacao', pr_tag_cont => rw_tbepr_portabilidade.flgerro_efetivacao, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtliquidacao', pr_tag_cont => rw_tbepr_portabilidade.dtliquidacao, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtaprov_portabilidade', pr_tag_cont => rw_tbepr_portabilidade.dtaprov_portabilidade, pr_des_erro => vr_dscritic);
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmif_origem', pr_tag_cont => rw_tbepr_portabilidade.nmif_origem, pr_des_erro => vr_dscritic);           
           
         CLOSE cr_tbepr_portabilidade;              
          
         IF (pr_tipo_consulta = 'PROPOSTA') THEN
           
            --busca dados da tabela de propostas de emprestimos
            OPEN cr_crawepr(pr_cdcooper, pr_nrdconta, pr_nrctremp);  
            FETCH cr_crawepr INTO rw_crawepr;
            
            IF cr_crawepr%NOTFOUND THEN
               CLOSE cr_crawepr;              
               RAISE vr_exc_saida;              
            ELSE
               CLOSE cr_crawepr;
               vr_cdmodali_portabilidade := rw_crawepr.cdmodali;--modalidade
            END IF;            
            
            --verifica a data de aprovacao ou sitacao da proposta
            IF (rw_tbepr_portabilidade.dtaprov_portabilidade IS NOT NULL) OR (rw_crawepr.insitapr <> 0) THEN

                -- Verifica se a cooperativa esta cadastrada
                OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
                FETCH cr_crapcop INTO rw_crapcop;
                -- Verificar se existe informação, e gerar erro caso não exista
                IF cr_crapcop%NOTFOUND THEN
                  -- Fechar o cursor
                  CLOSE cr_crapcop;
                  -- Gerar exceção
                  vr_cdcritic := 651;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  RAISE vr_exc_saida;
                ELSE
                  -- Fechar o cursor
                  CLOSE cr_crapcop;
                END IF;

                -- Verifica se o banco esta cadastrado
                OPEN cr_crapban(pr_cdbccxlt => 85); -- CECRED
                FETCH cr_crapban INTO rw_crapban;
                -- Verificar se existe informação, e gerar erro caso não exista
                IF cr_crapban%NOTFOUND THEN
                  -- Fechar o cursor
                  CLOSE cr_crapban;
                  -- Gerar exceção
                  vr_cdcritic := 57;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  RAISE vr_exc_saida;
                ELSE
                  -- Fechar o cursor
                  CLOSE cr_crapban;
                END IF;

                -- Verifica se o associado esta cadastrado
                OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                -- Verificar se existe informação, e gerar erro caso não exista
                IF cr_crapass%NOTFOUND THEN
                  -- Fechar o cursor
                  CLOSE cr_crapass;
                  -- Gerar exceção
                  vr_cdcritic := 9;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  RAISE vr_exc_saida;
                ELSE
                  -- Fechar o cursor
                  CLOSE cr_crapass;
                END IF;

               --consulta situacao da portabilidade (JDCTC)                       
               pc_consulta_situacao(pr_cdcooper => pr_cdcooper,
                                    pr_idservic => 1, -- Proponente
                                    pr_cdlegado => rw_crapcop.cdagectl, 
                                    pr_nrispbif => rw_crapban.nrispbif, 
                                    pr_idparadm => rw_crapcop.cnpjbase, 
                                    pr_ispbifcr => SUBSTR(LPAD(rw_tbepr_portabilidade.nrcnpjbase_if_origem,14,0),1,8),
                                    pr_nrunipor => rw_tbepr_portabilidade.nrunico_portabilidade, 
                                    pr_cdconori => rw_tbepr_portabilidade.nrcontrato_if_origem, 
                                    pr_tpcontra => vr_cdmodali_portabilidade, 
                                    pr_tpclient => 'F', 
                                    pr_cnpjcpf  => rw_crapass.nrcpfcgc, 
                                    pr_tab_portabilidade  => vr_tab_portabilidade, 
                                    pr_des_erro => vr_des_erro, 
                                    pr_dscritic => vr_dscritic);
               
               
               IF vr_tab_portabilidade.stportabilidade IS NOT NULL THEN
                  --consulta descricao do retorno
                  OPEN cr_craprto(pr_cdoperac => vr_tab_portabilidade.stportabilidade);
                  
                  FETCH cr_craprto INTO rw_craprto;

                  CLOSE cr_craprto;
                  
                 --recupera a situacao do XML de retorno                    
                 vr_dssit_portabilidade := rw_craprto.dsretorn;
                                
               END IF;
               
               /* consiste o numero da portabilidade na tbepr_portabilidade */
               IF TRIM(rw_tbepr_portabilidade.nrunico_portabilidade) IS NULL THEN
                  --recupera o numero unico de portabilidade retornado pela JD
                  vr_nrunico_portabilidade := vr_tab_portabilidade.nuportlddctc;                 
                  
                  IF NOT vr_nrunico_portabilidade IS NULL THEN

                     --atualiza o cadastro da proposta
                     BEGIN
                        UPDATE tbepr_portabilidade 
                          SET nrunico_portabilidade = vr_nrunico_portabilidade 
                        WHERE cdcooper = pr_cdcooper 
                          AND nrdconta = pr_nrdconta
                          AND nrctremp = pr_nrctremp;                        
	                   END;
                    
                  END IF; --IF NOT vr_nrunico_portabilidade IS NULL
                 
               END IF; --IF rw_tbepr_portabilidade.nrunico_portabilidade IS NULL
               
	          END IF; -- IF (rw_tbepr_portabilidade.dtaprov_portabilidade IS NOT NULL) OR ( rw_crawepr.insitaprv <> 0 ) THEN
         
                               
         ELSIF (pr_tipo_consulta = 'CONTRATO') THEN --se for um contrato a portabilidade ja esta concluida
           
            --busca dados da tabela de contratos de emprestimo
            OPEN cr_crapepr(pr_cdcooper, pr_nrdconta, pr_nrctremp);  
            FETCH cr_crapepr INTO rw_crapepr;
            
            IF cr_crapepr%NOTFOUND THEN
               CLOSE cr_crapepr;
               RAISE vr_exc_saida;              
            ELSE
               CLOSE cr_crapepr;           
               vr_cdmodali_portabilidade := rw_crapepr.cdmodali;--modalidade
            END IF;         
         
            vr_dssit_portabilidade := 'PORTADA';
         END IF;
         
         -- consiste o numero unico da portabilidade, apresenta o mesmo em tela
         IF vr_nrunico_portabilidade IS NULL THEN
           -- carrega a variavel com o valoreja existente na tbepr_portabilidade
           vr_nrunico_portabilidade := rw_tbepr_portabilidade.nrunico_portabilidade;
         END IF;         
         
         -- codigo da modalidade
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'cdmodali_portabilidade', pr_tag_cont => vr_cdmodali_portabilidade, pr_des_erro => vr_dscritic);
           
         -- situacao da portabilidade JDCTC
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dssit_portabilidade', pr_tag_cont => vr_dssit_portabilidade, pr_des_erro => vr_dscritic);

         -- carrega o numero unico da portabilidade
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrunico_portabilidade', pr_tag_cont => vr_nrunico_portabilidade, pr_des_erro => vr_dscritic);         

      END IF;
    
    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        
        
    END;

  END pc_consulta_portabilidade;
  
  /* retorna um XML com os dados da proposta de portabilidade */
  PROCEDURE pc_consulta_portabil_crt(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE  --> Numero da Conta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Numero de Emprestimo
                                    ,pr_tpoperacao IN tbepr_portabilidade.tpoperacao%TYPE DEFAULT 0 --> tipo de portabilidade (0 - todos | 1 - compra | 2 - venda)
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType) IS --> Arquivo de retorno do XML
  BEGIN
  
    /* .............................................................................

     Programa: pc_consulta_portabilidade
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 03/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta dos dados de portabilidade.

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_contador INTEGER := 0;
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      
      vr_nrunico_portabilidade VARCHAR2(21);
      vr_nrcnpjbase_if_origem VARCHAR(20);
      
      /*CURSOR SOBRE EMPRESTIMOS DE PORTABILIDADE*/
      CURSOR cr_tbepr_portabilidade (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT tpoperacao
              ,nrunico_portabilidade
              ,nrcontrato_if_origem
              ,LPAD(nrcnpjbase_if_origem, 14, 0) AS nrcnpjbase_if_origem
              ,flgerro_efetivacao
              ,dtliquidacao
              ,dtaprov_portabilidade
              ,nmif_origem
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND (tpoperacao = pr_tpoperacao OR 0 = pr_tpoperacao);
      
      rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;    
      
    BEGIN
      
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);     
    
      --Busca dados da portabilidade
      OPEN cr_tbepr_portabilidade(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          
      IF cr_tbepr_portabilidade%NOTFOUND THEN
          RAISE vr_exc_saida;
      ELSE        
             
         -- Criar cabeçalho do XML
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

         LOOP 
           FETCH cr_tbepr_portabilidade INTO rw_tbepr_portabilidade;
                              
           -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
           EXIT WHEN cr_tbepr_portabilidade%NOTFOUND; 

           vr_nrcnpjbase_if_origem := GENE0002.fn_mask_cpf_cnpj(rw_tbepr_portabilidade.nrcnpjbase_if_origem, 2);
                              
           vr_nrunico_portabilidade := rw_tbepr_portabilidade.nrunico_portabilidade;
           
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0,           pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'tpoperacao', pr_tag_cont => rw_tbepr_portabilidade.tpoperacao, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcontrato_if_origem', pr_tag_cont => rw_tbepr_portabilidade.nrcontrato_if_origem, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nrcnpjbase_if_origem', pr_tag_cont => vr_nrcnpjbase_if_origem, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'flgerro_efetivacao', pr_tag_cont => rw_tbepr_portabilidade.flgerro_efetivacao, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtliquidacao', pr_tag_cont => rw_tbepr_portabilidade.dtliquidacao, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'dtaprov_portabilidade', pr_tag_cont => rw_tbepr_portabilidade.dtaprov_portabilidade, pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => vr_contador, pr_tag_nova => 'nmif_origem', pr_tag_cont => rw_tbepr_portabilidade.nmif_origem, pr_des_erro => vr_dscritic);           
           
           --vr_contador := vr_contador + 1;                             
                              
         END LOOP;            
         
         CLOSE cr_tbepr_portabilidade;              
      
      END IF;
    
    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        
        
    END;

  END pc_consulta_portabil_crt;
  
  /* validacao de cadastro da portabilidade */
  PROCEDURE pc_valida_portabilidade(pr_operacao             IN VARCHAR2 
                                   ,pr_nrcnpjbase_if_origem IN tbepr_portabilidade.nrcnpjbase_if_origem%TYPE    
                                   ,pr_nmif_origem          IN tbepr_portabilidade.nmif_origem%TYPE
                                   ,pr_nrcontrato_if_origem IN tbepr_portabilidade.nrcontrato_if_origem%TYPE                                   
                                   ,pr_cdmodali             IN VARCHAR2
                                   ,pr_xmllog               IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic             OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic             OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml               IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo             OUT VARCHAR2             --> Nome do campo com erro                                   
                                   ,pr_des_erro             OUT VARCHAR2) IS         --> Erros do processo      
  
  BEGIN
    
    /* .............................................................................

     Programa: pc_valida_portabilidade
     Sistema : Portabilidade de Credito
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/14.                    Ultima atualizacao: 12/06/2015

     Dados referentes a modalidade do programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de manipulacao de portabilidade de propostas de emprestimos.

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/     
  
     DECLARE
  
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_contador INTEGER := 0;
      vr_cnpj_valido BOOLEAN;
      vr_inpessoa INTEGER;
      
      -- Variaveis de log
      vr_cdcooper INTEGER := 0;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);     
    
    
      /* CURSORES */ 
          
      -- Valida se eh um cnpj de uma cooperativa
      CURSOR cr_crapcop(pr_nrdocnpj IN crapcop.nrdocnpj%TYPE) IS
      
      SELECT crapcop.cdcooper
        FROM crapcop
       WHERE LPAD(nrdocnpj, 14, 0) = LPAD(pr_nrdocnpj, 14, 0);
         
      rw_crapcop cr_crapcop%ROWTYPE;
    
    
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
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- cria no de validacao
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'valida', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        
        -- valida insercao
        IF pr_operacao = 'PORTAB_CRED_I' THEN

           --VALIDA CNPJ
           GENE0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcnpjbase_if_origem, pr_stsnrcal => vr_cnpj_valido, pr_inpessoa => vr_inpessoa);
           IF (vr_cnpj_valido = TRUE) THEN
              
              OPEN cr_crapcop (pr_nrdocnpj => pr_nrcnpjbase_if_origem);
              FETCH cr_crapcop INTO rw_crapcop;
              
              IF cr_crapcop%FOUND THEN 
                 --caso o CNPJ seja de uma cooperativa retorna msg de erro pra tela
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'cnpj', pr_tag_cont => 'IN', pr_des_erro => vr_dscritic);
              ELSE
                 gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'cnpj', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);                
              END IF;
              
              CLOSE cr_crapcop;
           
           ELSE 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'cnpj', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
           END IF;                 

           --NOME INSTITUICAO FINANCEIRA
           IF (TRIM(pr_nmif_origem) IS NOT NULL) THEN
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nome', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
           ELSE 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'nome', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
           END IF;       
           
           --NUMERO DO CONTRATO
           IF NOT REGEXP_LIKE(pr_nrcontrato_if_origem, '\W') THEN --valida apenas letras e numeros
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'contrato', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
           ELSE 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'contrato', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
           END IF;     
           
           --VALIDA MODALIDADES ('0203,0401,0402,0403')
           IF gene0002.fn_existe_valor('0203,0401', pr_cdmodali, ',') = 'S' THEN
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);             
           ELSE
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);                          
           END IF;
             

        -- valida alteracao  
        ELSIF pr_operacao <> 'PORTAB_CRED_A' THEN

           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'cnpj', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'none', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);           
           
           --NUMERO DO CONTRATO
           IF NOT REGEXP_LIKE(pr_nrcontrato_if_origem, '\W') THEN --valida apenas letras e numeros
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'contrato', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
           ELSE 
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'contrato', pr_tag_cont => 'N', pr_des_erro => vr_dscritic);
           END IF;               
	
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'valida', pr_posicao => 0, pr_tag_nova => 'modalidade', pr_tag_cont => 'S', pr_des_erro => vr_dscritic);
           
        END IF;

      EXCEPTION

        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
                  
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;        

        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro Geral em Validação de Portabilidade: ' || SQLERRM;
                  
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;     
  
      END;
  
  END pc_valida_portabilidade;


  --insere as novas portabilidades
  PROCEDURE pc_cadastra_portabilidade(pr_cdcooper             IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta             IN crapass.nrdconta%TYPE
                                     ,pr_nrctremp             IN crawepr.nrctremp%TYPE
                                     ,pr_tpoperacao           IN NUMBER -- tipo operacao (1-compra|2-venda)
                                     ,pr_nrcnpjbase_if_origem IN tbepr_portabilidade.nrcnpjbase_if_origem%TYPE    
                                     ,pr_nmif_origem          IN tbepr_portabilidade.nmif_origem%TYPE
                                     ,pr_nrcontrato_if_origem IN tbepr_portabilidade.nrcontrato_if_origem%TYPE
                                     ,pr_xmllog               IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic             OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic             OUT VARCHAR2             --> Descricao da critica
                                     ,pr_retxml               IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo             OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro             OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_cadastra_portabilidade
     Sistema : Portabilidade de Credito
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 12/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de cadastro de portabilidade

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 

    DECLARE
  
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;
      vr_nrcnpjbase_if_origem VARCHAR2(40);

    BEGIN

      BEGIN 

        vr_nrcnpjbase_if_origem := LPAD(pr_nrcnpjbase_if_origem,14,'0');
        
        INSERT INTO tbepr_portabilidade(cdcooper, nrdconta, nrctremp, tpoperacao, nrcontrato_if_origem, 
                                        nrcnpjbase_if_origem, nmif_origem)
             VALUES(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_tpoperacao, pr_nrcontrato_if_origem, 
                    vr_nrcnpjbase_if_origem, UPPER(pr_nmif_origem));
                
      -- Verifica se houve problema na insercao de registros
      EXCEPTION
        WHEN OTHERS THEN
          -- Descricao do erro na insercao de registros
          vr_dscritic := 'Problema ao incluir Portabilidade: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;  
    
    EXCEPTION
      
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral no cadastro de portabilidade: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END;
    
  END pc_cadastra_portabilidade;  


 /* Rotina referente a consulta de carencias cadastrados */
  PROCEDURE pc_carrega_modalidades(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro 
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  
    /* .............................................................................

     Programa: pc_carrega_modalidades
     Sistema : Portabilidade de Credito
     Sigla   : EMPR
     Autor   : Carlos Rafael Tanholi
     Data    : Junho/15.                    Ultima atualizacao: 12/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de carregamento de modalidades

     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
    DECLARE
          
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;

      CURSOR cr_gnsbmod IS
                        
      SELECT cdmodali||cdsubmod cdmodali, 
             dssubmod
        FROM gnsbmod 
       WHERE (cdmodali = 2 AND cdsubmod = 3) 
          OR (cdmodali = 4 AND cdsubmod = 1);
          --OR (cdmodali = 4 AND cdsubmod = 2)
          --OR (cdmodali = 4 AND cdsubmod = 3);
      
       rw_gnsbmod cr_gnsbmod%ROWTYPE;


      BEGIN
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        --Busca administradoras de cartao
        OPEN cr_gnsbmod;

        LOOP
          FETCH cr_gnsbmod INTO rw_gnsbmod;
              
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_gnsbmod%NOTFOUND; 
              
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdmodali', pr_tag_cont => rw_gnsbmod.cdmodali, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dssubmod', pr_tag_cont => rw_gnsbmod.dssubmod, pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;                                
              
        END LOOP;        
        
        CLOSE cr_gnsbmod;

      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em Consulta de Modalidades: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_carrega_modalidades;

 
  -- Gera relatório pdf a partir do log de críticas de efetivação e liquidação de portabilidade
  PROCEDURE pc_gera_relatorio_prt(pr_cdopcao  IN VARCHAR2              --> Opcao (C: liquidação/D: efetivação)
                                 ,pr_dtlogini IN VARCHAR2              --> Data inicial da critica
                                 ,pr_dtlogfin IN VARCHAR2              --> Data final da critica
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_gera_relatorio_prt
     Sistema : Portabilidade de Emprestimos
     Sigla   : EMPR
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Junho/15.                    Ultima atualizacao: 10/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para gerar relatório pdf a partir do
                 log de críticas de efetivação e liquidação de
                 de portabilidade.

     Observacao: -----

     Alteracoes: 23/11/2015 - Correcao do erro(User-Defined Exception) gerado na impressao
                              de criticas na efetivação de contratos de portabilidade.
                              Decorrente do uso equivocado da variavel pr_dscritic.
                              Carlos Rafael Tanholi - Portabilidade.
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_sem_regis EXCEPTION;
      
      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      
      -- Variaveis para manipulacao do log
      vr_dir_log      VARCHAR(400);
      log             UTL_FILE.file_type;
      linha           VARCHAR(2000);
      vr_desc_tipo    VARCHAR(400);
      vr_nmarqpdf     VARCHAR(400);
      vr_descrela     VARCHAR(400);
      fim_log         BOOLEAN := FALSE;
      vr_posicao      INTEGER;
      contador        INTEGER := 0;
      vr_dtlogini     DATE;
      vr_dtlogfin     DATE;
      vr_dtmvtlog     DATE;
      vr_dtmvtlog_ant DATE;
      
      -- Variaveis do relatorio
      cl_relatorio CLOB;
      vr_conta         VARCHAR(500);
      vr_contrato      VARCHAR(500);
      vr_portabilidade VARCHAR(500);
      vr_critica       VARCHAR(500);
      vr_nmdireto      VARCHAR(1000);
      vr_nmarqimp      VARCHAR(100);
      
      vr_des_reto VARCHAR2(10);
      pr_tab_erro gene0001.typ_tab_erro;
      vr_cdprogra VARCHAR2(6) := 'LOGPRT';
      
      -- Buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT crapcop.nmrescop,
               crapcop.nrtelura,
               crapcop.dsdircop,
               crapcop.cdbcoctl,
               crapcop.cdagectl,
               crapcop.nrctactl,
               crapcop.cdcooper
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
        
      -- Cursor genérico de calendário
      rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
        
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_dados IN CLOB) IS
      BEGIN
        --Escrever no arquivo XML
        cl_relatorio := cl_relatorio || pr_dados;
      END;
        
    BEGIN
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
    
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar exceção
        vr_cdcritic := 651; -- Falta registro de controle da cooperativa
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Verificar se existe informação, e gerar erro caso não exista
      IF btch0001.cr_crapdat%NOTFOUND THEN

        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;

        -- Gerar exceção
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Busca do diretorio base da cooperativa
      vr_dir_log := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                           ,pr_cdcooper => vr_cdcooper
                                           ,pr_nmsubdir => '/log'); --> pasta log do sistema
            
      -- Leitura do arquivo de log
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dir_log --> Diretorio do arquivo
                              ,pr_nmarquiv => 'logprt.log'  --> Nome do arquivo
                              ,pr_tipabert => 'R'          --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => log  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);--> Descricão da critica
     
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'LogNaoEncontrado';
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica opção desejada
      IF pr_cdopcao = 'C' THEN
        vr_desc_tipo:= 'Liquidacao';
        vr_nmarqpdf := 'Relatorio criticas na liquidacao';
        vr_descrela := 'LIQUIDACAO';--'- Criticas na liquidacao automatica de portabilidade';
      ELSE 
        vr_desc_tipo := 'Efetivacao';
        vr_nmarqpdf := 'Relatorio criticas na efetivacao';
        vr_descrela := 'EFETIVACAO';--'- Criticas na efetivacao automatica de portabilidade';
      END IF;
      
      -- Converte a data de String pra Date
      vr_dtlogini := to_date(pr_dtlogini,'DD/MM/YYYY');
      vr_dtlogfin := to_date(pr_dtlogfin,'DD/MM/YYYY');            
      
      -- Passa por todas as linhas do arquivo
      WHILE (NOT fim_log) LOOP
        BEGIN
          utl_file.get_line(log, linha);
          
          vr_dtmvtlog := to_date(substr(linha, 0, 10),'DD/MM/YYYY');
          
          -- Verifica se a linha contém o tipo e a data solicitada
          IF instr(linha, vr_desc_tipo) <> 0 AND
             vr_dtmvtlog BETWEEN vr_dtlogini AND vr_dtlogfin THEN
            
            -- Verifica para mudar data
            IF vr_dtmvtlog_ant IS NOT NULL THEN
              IF trunc(vr_dtmvtlog) != trunc(vr_dtmvtlog_ant) THEN
                pc_escreve_xml('</data><data data="' || to_char(vr_dtmvtlog,'DD/MM/YYYY') || '" >');               
                vr_dtmvtlog_ant := vr_dtmvtlog;
              END IF;
            ELSE
              pc_escreve_xml('<data data="' || to_char(vr_dtmvtlog,'DD/MM/YYYY') || '" >');
              vr_dtmvtlog_ant := vr_dtmvtlog;
            END IF;
          
            linha := substr(linha, INSTR(linha, '|') + 1);
            
            -- Nao utiliza o PA
            vr_posicao := instr(linha, '|');
            vr_conta := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, '|') + 1);
            
            -- Numero da conta
            vr_posicao := instr(linha, '|');
            vr_conta := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, '|') + 1);
            
            -- Contrato
            vr_posicao := instr(linha, '|');
            vr_contrato := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, '|') + 1);
            
            -- Numero da portabilidade
            vr_posicao := instr(linha, '|');
            vr_portabilidade := substr(linha, 1, vr_posicao - 1);
            linha := substr(linha, instr(linha, '|') + 1);
            
            -- Critica
            vr_critica := linha;
            
            -- Escreve o registro no xml
            pc_escreve_xml('<reg>' ||
                               '<nrdconta>'      || vr_conta         || '</nrdconta>' ||
                               '<contrato>'      || vr_contrato      || '</contrato>' ||
                               '<portabilidade>' || vr_portabilidade || '</portabilidade>' ||
                               '<critica>'       || vr_critica       || '</critica>'  ||
                           '</reg>');
            contador := contador + 1;
          END IF;
        EXCEPTION
          --Se nao existir mais linhas
          WHEN no_data_found THEN
            fim_log := TRUE;
          WHEN OTHERS THEN
            CONTINUE;
        END;
      END LOOP;
      
      -- Fecha a ultima data
      pc_escreve_xml('</data>');
      
      IF contador = 0 THEN
        vr_dscritic := 'LogNaoEncontrado';
        RAISE vr_sem_regis;
      END IF;
      
      -- Busca do diretorio base da cooperativa
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      vr_nmarqimp:= 'relprt.lst';
      cl_relatorio := '<?xml version="1.0" encoding="utf-8"?>' || 
                      '<relprt ' || 
                          'cooperativa="' || rw_crapcop.nmrescop || '" ' ||
                          'descrela="' || vr_descrela || '">' ||                      
                          cl_relatorio ||
                      '</relprt>';

      --Gerar Arquivo XML Fisico
      gene0002.pc_clob_para_arquivo(pr_clob     => cl_relatorio   --> Instância do XML Type
                                   ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                   ,pr_arquivo  => 'logprt.xml'   --> Nome do arquivo de saída
                                   ,pr_des_erro => vr_dscritic);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Solicitar impressao
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => cl_relatorio        --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/relprt/data'       --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'logprt.jasper'     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqimp --> Arquivo final com codigo da agencia
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'N'                 --> Chamar a impressao (Imprim.p)
                                 ,pr_flg_gerar => 'S'                 --> gerar na hora
                                 ,pr_nmformul  => '132col'            --> Nome do formulario para impressao
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro
                  
      --Enviar arquivo para Web
      GENE0002.pc_envia_arquivo_web (pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa   --Numero do Caixa
                                    ,pr_nmarqimp => vr_nmarqimp   --Nome Arquivo Impressao
                                    ,pr_nmdireto => vr_nmdireto   --Nome Diretorio
                                    ,pr_nmarqpdf => vr_nmarqpdf   --Nome Arquivo PDF
                                    ,pr_des_reto => vr_des_reto   --Retorno OK/NOK
                                    ,pr_tab_erro => pr_tab_erro); --tabela erro
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        --Se tem erro na tabela 
        IF pr_tab_erro.COUNT > 0 THEN
          vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro ao enviar arquivo para web.';  
        END IF; 
        --Sair 
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml, 
                             pr_tag_pai  => 'Dados', 
                             pr_posicao  => 0, 
                             pr_tag_nova => 'nmarqpdf', 
                             pr_tag_cont => vr_nmarqpdf, 
                             pr_des_erro => vr_dscritic);
      ROLLBACK;
    EXCEPTION

      WHEN vr_sem_regis THEN
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN vr_exc_saida THEN        
        IF pr_cdcritic IS NOT NULL THEN
           pr_dscritic := vr_dscritic;
           pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(pr_cdcritic));
        ELSE
          /* tratamento feito para mensagem apresentada em tela */
          IF vr_dscritic = 'LogNaoEncontrado' THEN
            pr_dscritic := vr_dscritic;
          ELSE  
            pr_dscritic := 'Erro ao gerar relatorio na empr0006.pc_gera_relatorio_prt: ' || vr_dscritic;
          END IF;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro ao gerar relatorio na empr0006.pc_gera_relatorio_prt: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;        
        
    END;  

  END pc_gera_relatorio_prt;
		
	  /* Procedure para gerar cabecalho soap */
  PROCEDURE pc_gera_cabecalho_soap(pr_idservic IN PLS_INTEGER --> Tipo do serviço
                                  ,pr_nmmetodo IN VARCHAR2 --> Nome Metodo
                                  ,pr_xml      OUT xmltype --> Objeto do XML criado
                                  ,pr_des_erro OUT VARCHAR2 --> Descricao erro OK/NOK
                                  ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_cabecalho_soap
    --  Sistema  : Procedure para gerar cabecalho de envelope soap
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gerar cabecalho de envelope soap
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_nmservic VARCHAR2(50); --> Nome do serviço

    BEGIN
      vr_nmservic := CASE pr_idservic
                       WHEN 1 THEN
                        'ProponentePortabilidade'
                       WHEN 2 THEN
                        'CredoraPortabilidade'
                     END;

      -- Criar cabeçalho do envelope SOAP
      pr_xml := xmltype.createxml('<?xml version="1.0" ?>' ||
                                  '<SOAP-ENV:Envelope xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" ' ||
                                  'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" ' ||
                                  'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' || 
                                  'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >' ||
                                  '<SOAP-ENV:Header SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:NS1="urn:JDCTC_'||vr_nmservic||'Intf">' ||
                                  '<NS1:TAutenticacao xsi:type="NS1:TAutenticacao">' ||
                                  '<Usuario xsi:type="xsd:string">JDCTC</Usuario>' ||
                                  '<Senha xsi:type="xsd:string">JDCTC</Senha>' ||
                                  '</NS1:TAutenticacao>' ||
                                  '</SOAP-ENV:Header>' ||
                                  '<SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' ||
                                  '<NS2:' || pr_nmmetodo ||' xmlns:NS2="urn:JDCTC_' || vr_nmservic || 'Intf-IJDCTC_' || pr_nmmetodo || '">' ||
                                  '</NS2:' || pr_nmmetodo || '>' ||
                                  '</SOAP-ENV:Body>' ||
                                  '</SOAP-ENV:Envelope>');                                  

      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_gera_cabecalho_soap. ' ||
                       SQLERRM;
    END;
  END pc_gera_cabecalho_soap;
	
	PROCEDURE pc_cria_tag(pr_dsnomtag IN VARCHAR2 	                      --> Nome TAG que será criada
                       ,pr_dspaitag IN VARCHAR2                         --> Nome TAG pai
                       ,pr_dsvaltag IN VARCHAR2                         --> Valor TAG que será criada
                       ,pr_postag   IN PLS_INTEGER                      --> Posição da TAG criada no nodelist
                       ,pr_dstpdado IN VARCHAR2                         --> Tipo de dado da TAG
                       ,pr_deftpdad IN VARCHAR2                         --> Definição do tipo de dado
                       ,pr_xml      IN OUT NOCOPY XMLType               --> Handle XMLType
                       ,pr_des_erro OUT VARCHAR2                        --> Identificador erro OK/NOK
                       ,pr_dscritic OUT VARCHAR2) IS                    --> Descrição erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_tag    
    --  Sistema  : Procedure para criar tags no XML
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para criar tags XML
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_exc_erro EXCEPTION; --> Controle de erros

    BEGIN
      -- Gerar TAGs dos parâmetros para o método
      gene0007.pc_insere_tag(pr_xml      => pr_xml
                            ,pr_tag_pai  => pr_dspaitag
                            ,pr_posicao  => pr_postag
                            ,pr_tag_nova => pr_dsnomtag
                            ,pr_tag_cont => pr_dsvaltag
                            ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gera atributo com o tipo do dado
      gene0007.pc_gera_atributo(pr_xml      => pr_xml
                               ,pr_tag      => pr_dsnomtag
                               ,pr_atrib    => pr_deftpdad
                               ,pr_atval    => pr_dstpdado
                               ,pr_numva    => pr_postag
                               ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_cria_tag. ' ||
                       pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_cria_tag. ' || SQLERRM;
    END;
  END pc_cria_tag;
	
	/* Procedure para analisar retorno de erros do webservice */
  PROCEDURE pc_obtem_fault_packet(pr_xml      IN OUT NOCOPY xmltype --> XML de verificação
                                 ,pr_dsderror IN VARCHAR2           --> parâmetro para liberação de erros específicos
                                 ,pr_des_erro OUT VARCHAR2          --> Indicador erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2) IS      --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_obtem_fault_packet
    --  Sistema  : Procedure para Executar Baixa Operacional
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para validar retorno do webservice
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_cdderror   VARCHAR2(400) := '';      --> Código do erro de acesso
      vr_dsderror   VARCHAR2(400) := '';      --> Descrição do erro de acesso
      vr_countfault PLS_INTEGER := 0;         --> Contagem de fault-code
      vr_erro EXCEPTION;                      --> Controle de erros
      vr_tab_valores gene0007.typ_tab_tagxml; --> PL Table para armazenar valores das TAGs

    BEGIN
      -- Verifica se retornou fault-code
      gene0007.pc_lista_nodo(pr_xml      => pr_xml
                            ,pr_nodo     => 'Fault'
                            ,pr_cont     => vr_countfault
                            ,pr_des_erro => pr_dscritic);

      -- Verifica se retornou erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_erro;
      END IF;

      -- Faz processo de validação do erro retornado no XML
      IF vr_countfault > 0 THEN
        -- Recupera o código do erro
        gene0007.pc_itera_nodos(pr_xpath      => '//faultcode'
                               ,pr_xml        => pr_xml
                               ,pr_list_nodos => vr_tab_valores
                               ,pr_des_erro   => pr_dscritic);

        -- Verifica se retornou erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_erro;
        END IF;

        -- Grava valor e limpa PL Table
        vr_cdderror := vr_tab_valores(0).tag;
        vr_tab_valores.delete;

        -- Recupera a descrição do erro
        -- Recupera o código do erro
        gene0007.pc_itera_nodos(pr_xpath      => '//faultstring'
                               ,pr_xml        => pr_xml
                               ,pr_list_nodos => vr_tab_valores
                               ,pr_des_erro   => pr_dscritic);

        -- Verifica se retornou erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_erro;
        END IF;

        -- Grava valor e limpa PL Table
        vr_dsderror := vr_tab_valores(0).tag;
        vr_tab_valores.delete;

        -- Verifica se existe erro e se existe parâmetro para ignorar
        IF pr_dsderror IS NOT NULL
           AND vr_cdderror IS NOT NULL
           AND gene0002.fn_existe_valor(pr_base     => vr_cdderror
                                       ,pr_busca    => pr_dsderror
                                       ,pr_delimite => ',') = 'S' THEN
          pr_des_erro := 'OK';
        ELSE
          pr_des_erro := 'NOK';
          pr_dscritic := REPLACE(vr_cdderror,'SOAP-ENV:-','') || ' - ' || vr_dsderror;

          return;
        END IF;
      END IF;

      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro em EMPR0006.pc_obtem_fault_packet: ' ||
                       pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro em EMPR0006.pc_obtem_fault_packet: ' ||
                       SQLERRM;
    END;
  END pc_obtem_fault_packet;
	
	/* Procedure para Atualizar Situacao */
  PROCEDURE pc_atualizar_situacao(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cód. Cooperativa
                                 ,pr_idservic IN INTEGER                          --> Tipo de servico(1-Proponente/2-Credora)
		                             ,pr_cdlegado IN VARCHAR2                         --> Codigo Legado
																 ,pr_nrispbif IN VARCHAR2                         --> Numero ISPB IF
															   ,pr_nrcontrl IN VARCHAR2                         --> Numero de Controle
																 ,pr_nuportld IN VARCHAR2                         --> Numero Portabilidade CTC
																 ,pr_cdsittit IN VARCHAR2                         --> Codigo Situacao Titulo
															   ,pr_flgrespo OUT NUMBER                          --> 1 - Se o registro na JDCTC for atualizado com sucesso
																 ,pr_des_erro OUT VARCHAR2                        --> Indicador erro OK/NOK
																 ,pr_dscritic OUT VARCHAR2) IS                    --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_atualizar_situacao
    --  Sistema  : Procedure para atualizar situacao de portabilidade
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Atualizar Situacao
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml       XMLType;                   --> XML de requisição
      vr_exc_erro  EXCEPTION;                 --> Controle de exceção
      vr_nmetodo   VARCHAR2(100);             --> Método da requisição do cabeçalho
      vr_xml_res   XMLType;                   --> XML de resposta
      vr_tab_xml   GENE0007.typ_tab_tagxml;   --> PL Table para armazenar conteúdo XML
      vr_des_reto  VARCHAR2(1000);
      vr_arqenvio  VARCHAR2(100);
      vr_arqreceb  VARCHAR2(100);
      vr_nmarqtmp  VARCHAR2(100);
      vr_comando   VARCHAR2(32767);
      vr_nmdireto  VARCHAR2(100);
      vr_dshorari  VARCHAR2(10);
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000);
      vr_caminho   VARCHAR2(330);

      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;

    BEGIN
      vr_nmetodo := 'AtualizarSituacao';

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => pr_idservic
                            ,pr_nmmetodo => vr_nmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro != 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NumControle'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrcontrl
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NUPortlddCTC'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nuportld
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'JDCTCCdSit'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdsittit
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_des_reto);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => pr_idservic
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_des_reto);
      -- Verifica se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_des_reto    --> Descricao Erro
                                   ,pr_tipmodo  => 2);            --> 2 - Alternativo(usando blob)
      --Se Ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;  
      END IF;

      --Remove o arquivo XML fisico de envio
      /* GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF; */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => vr_des_reto);
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
        
      ELSE -- Busca valor do nodo dado o xPath        
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);

        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;

        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha ao atualizar registro de portabilidade.';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;
				
				IF UPPER(vr_tab_xml(0).tag) = 'TRUE' THEN
           pr_flgrespo := 1;
			  ELSE
           pr_flgrespo := 0;	
				END IF;				
      END IF;

      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag);

      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_des_reto IS NOT NULL THEN
					pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_des_reto));
				END IF;
        pr_des_erro := 'NOK';

      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_atualizar_situacao. ' ||
                       SQLERRM;
    END;
  END pc_atualizar_situacao;



  /* Cconsulta situacao da portabilidade na JDCTC */
  PROCEDURE pc_consulta_situacao(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                ,pr_idservic IN INTEGER          --Tipo de servico(1-Proponente/2-Credora)
                                ,pr_cdlegado IN VARCHAR2         --Codigo Legado
                                ,pr_nrispbif IN NUMBER           --Numero ISPB IF (085)
                                ,pr_idparadm IN NUMBER           --Identificador Participante Administrado
                                ,pr_ispbifcr IN NUMBER           --CNPJ Base IF Credora Original Contrato
                                ,pr_nrunipor IN VARCHAR2         --Número único da portabilidade na CTC
                                ,pr_cdconori IN VARCHAR2         --Código Contrato Original*
                                ,pr_tpcontra IN VARCHAR2         --Tipo Contrato*
                                ,pr_tpclient IN CHAR             --Tipo Cliente - Fixo 'F'*
                                ,pr_cnpjcpf  IN NUMBER           --CNPJ CPF Cliente*
                                ,pr_tab_portabilidade OUT  typ_reg_retorno_xml --Dados Portabilidade JDCTC
                                ,pr_des_erro OUT VARCHAR2        --Indicador erro OK/NOK
                                ,pr_dscritic OUT VARCHAR2) IS    --Descricao erro

  BEGIN
    
  /* .............................................................................
  
   Programa: pc_consulta_situacao
   Sistema : Portabilidade de Emprestimos
   Sigla   : EMPR
   Autor   : Carlos Rafael Tanholi
   Data    : Junho/15.                    Ultima atualizacao: 17/06/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina de consulta situacao de portabilidade na JDCTC.

   Observacao: -----

   Alteracoes:
   ..............................................................................*/   
  
    DECLARE
      vr_xml       XMLType;                   --> XML de requisição
      vr_exc_erro  EXCEPTION;                 --> Controle de exceção
      vr_nmetodo   VARCHAR2(100);             --> Método da requisição do cabeçalho
      vr_xml_res   XMLType;                   --> XML de resposta
      vr_tab_xml   GENE0007.typ_tab_tagxml;   --> PL Table para armazenar conteúdo XML
      vr_des_reto  VARCHAR2(1000);
      vr_arqenvio  VARCHAR2(100);
      vr_arqreceb  VARCHAR2(100);
      vr_nmarqtmp  VARCHAR2(100);
      vr_comando   VARCHAR2(32767);
      vr_nmdireto  VARCHAR2(100);
      vr_dshorari  VARCHAR2(10);
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000);
      vr_caminho   VARCHAR2(330);


      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;

    BEGIN
      vr_nmetodo := 'ConsultarSituacao';

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => pr_idservic
                            ,pr_nmmetodo => vr_nmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => 'LEG' -- pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => LPAD(pr_nrispbif, 8, '0')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;      
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => LPAD(pr_idparadm, 8, '0')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => LPAD(pr_ispbifcr, 8, '0')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;      

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NUPortlddCTC'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrunipor
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Caso seja Proponente
      IF pr_idservic = 1 THEN

        -- Gerar TAGs com os valores dos parâmetros
        pc_cria_tag(pr_dsnomtag => 'CodContrtoOr'
                   ,pr_dspaitag => vr_nmetodo
                   ,pr_dsvaltag => pr_cdconori
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'string'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => pr_des_erro
                   ,pr_dscritic => pr_dscritic);

        -- Verifica se ocorreu erro
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;

        -- Gerar TAGs com os valores dos parâmetros
        pc_cria_tag(pr_dsnomtag => 'TpContrto'
                   ,pr_dspaitag => vr_nmetodo
                   ,pr_dsvaltag => pr_tpcontra
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'string'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => pr_des_erro
                   ,pr_dscritic => pr_dscritic);

        -- Verifica se ocorreu erro
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;              

        -- Gerar TAGs com os valores dos parâmetros
        pc_cria_tag(pr_dsnomtag => 'TpCli'
                   ,pr_dspaitag => vr_nmetodo
                   ,pr_dsvaltag => pr_tpclient
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'string'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => pr_des_erro
                   ,pr_dscritic => pr_dscritic);

        -- Verifica se ocorreu erro
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;               

        -- Gerar TAGs com os valores dos parâmetros
        pc_cria_tag(pr_dsnomtag => 'CNPJ_CPFCli'
                   ,pr_dspaitag => vr_nmetodo
                   ,pr_dsvaltag => pr_cnpjcpf
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'string'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => pr_des_erro
                   ,pr_dscritic => pr_dscritic);

        -- Verifica se ocorreu erro
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_des_reto);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => pr_idservic
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_des_reto);
      -- Verifica se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_des_reto    --> Descricao Erro
                                   ,pr_tipmodo  => 2);            --> 2 - Alternativo(usando blob)
      --Se Ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;  
      END IF;

      --Remove o arquivo XML fisico de envio
    /*  GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;  */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => vr_des_reto);
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
        
      ELSE --Popular Colunas da PLTABLE de dados do WEBSERVICE
      
        --Numero de identificação da Instituicao Financeira no Sistema de Pagamentos Brasileiro
        gene0007.pc_itera_nodos(pr_xpath      => '//ISPBIF'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
        
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.ispbif := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;  
        
        --Identificador Participante Administrado      
        gene0007.pc_itera_nodos(pr_xpath      => '//IdentdPartAdmdo'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic); 

        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.identdpartadmdo := vr_tab_xml(0).tag;      
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;

        --CNPJ Base IF Credora Original Contrato  
        gene0007.pc_itera_nodos(pr_xpath      => '//CNPJBase_IFOrContrto'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.cnpjbase_iforcontrto := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;                
      
        --Número único da portabilidade na CTC
        gene0007.pc_itera_nodos(pr_xpath      => '//NUPortlddCTC'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);

        -- Busca Numero Portabilidade que pode nao retornar do XML 
        -- Este tratamento sera especifico para este campo devido a esta particularidade     
        IF vr_tab_xml.count > 0 THEN
           pr_tab_portabilidade.nuportlddctc:= vr_tab_xml(0).tag;
        END IF;

        --Código Contrato Original
        gene0007.pc_itera_nodos(pr_xpath      => '//CodContrtoOr'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.codcontrtoor := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;        
        
        --Tipo Contrato
        gene0007.pc_itera_nodos(pr_xpath      => '//TpContrto'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.tpcontrto := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;                        
        
        --Tipo Cliente – Fixo ‘F’
        gene0007.pc_itera_nodos(pr_xpath      => '//TpCli'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.tpcli := vr_tab_xml(0).tag; 
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;                                               
        
        --CNPJ CPF Cliente
        gene0007.pc_itera_nodos(pr_xpath      => '//CNPJ_CPFCli'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                                                          
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.cnpj_cpfcli := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;                       
        
        --Situação da Portabilidade
        gene0007.pc_itera_nodos(pr_xpath      => '//StPortabilidade'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF vr_tab_xml.FIRST IS NOT NULL THEN
           pr_tab_portabilidade.stportabilidade := vr_tab_xml(0).tag;
        ELSE
           vr_des_reto := 'Metodo "ConsultarSituacao" retornou vazio!';
           RAISE vr_exc_erro;
        END IF;              

      END IF;

      pr_des_erro := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_des_reto));
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_consulta_situacao. ' ||SQLERRM;
    END;
       
  END pc_consulta_situacao;
	
	PROCEDURE pc_consulta_situacao_car(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
																		,pr_idservic IN INTEGER               --Tipo de servico(1-Proponente/2-Credora)
																		,pr_cdlegado IN VARCHAR2              --Codigo Legado
																		,pr_nrispbif IN NUMBER                --Numero ISPB IF (085)
																		,pr_idparadm IN NUMBER                --Identificador Participante Administrado
																		,pr_cnpjbase IN NUMBER                --CNPJ Base IF Credora Original Contrato
																		,pr_nrunipor IN VARCHAR2              --Número único da portabilidade na CTC
																		,pr_cdconori IN VARCHAR2              --Código Contrato Original*
																		,pr_tpcontra IN VARCHAR2              --Tipo Contrato*
																		,pr_tpclient IN CHAR                  --Tipo Cliente - Fixo 'F'*
																		,pr_cnpjcpf  IN NUMBER                --CNPJ CPF Cliente*
																		--,pr_idgerlog  IN INTEGER            --Identificador de Log (0 – Não / 1 – Sim) 																 
																		,pr_clobxmlc OUT CLOB                 --XML com informações de LOG
																		,pr_des_erro OUT VARCHAR2             --Indicador erro OK/NOK
																		,pr_dscritic OUT VARCHAR2) IS         --Descrição da crítica

		BEGIN
/* .............................................................................
  
   Programa: pc_consulta_situacao_car
   Sistema : Portabilidade de Emprestimos
   Sigla   : EMPR
   Autor   : Lucas Reinert
   Data    : Julho/15.                    Ultima atualizacao: 99/99/9999

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina de consulta situacao de portabilidade na JDCTC para o 
	             ambiente caractere.

   Observacao: -----

   Alteracoes:
   ..............................................................................*/   
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_des_erro       VARCHAR2(3);

      -- Temp Table
      vr_tab_portabilidade typ_reg_retorno_xml;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
      vr_dshistor VARCHAR2(100); 
    BEGIN
      
		  -- Carrega PL table com aplicacoes da conta
         pc_consulta_situacao(pr_cdcooper => pr_cdcooper      --Codigo da cooperativa
														 ,pr_idservic => pr_idservic      --Tipo de servico(1-Proponente/2-Credora)
														 ,pr_cdlegado => pr_cdlegado      --Codigo Legado
														 ,pr_nrispbif => pr_nrispbif      --Numero ISPB IF (085)
													 	 ,pr_idparadm => pr_idparadm      --Identificador Participante Administrado
													 	 ,pr_ispbifcr => pr_cnpjbase      --CNPJ Base IF Credora Original Contrato
														 ,pr_nrunipor => pr_nrunipor      --Número único da portabilidade na CTC
														 ,pr_cdconori => pr_cdconori      --Código Contrato Original*
														 ,pr_tpcontra => pr_tpcontra      --Tipo Contrato*
														 ,pr_tpclient => pr_tpclient      --Tipo Cliente - Fixo 'F'*
														 ,pr_cnpjcpf  => pr_cnpjcpf       --CNPJ CPF Cliente*
--                                ,pr_idgerlog => pr_idgerlog    --Identificador de Log (0 – Não / 1 – Sim)   
                             ,pr_tab_portabilidade => vr_tab_portabilidade --Dados da Portabilidade
                             ,pr_des_erro => vr_des_erro      --Indicador erro OK/NOK
                             ,pr_dscritic => vr_dscritic);    --Descricao erro
														 
      IF vr_dscritic IS NOT NULL AND vr_des_erro <> 'OK' THEN
        RAISE vr_exc_saida;
      END IF;
     
			-- Criar documento XML
			dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
			dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
  			                                        															 														
			-- Montar XML com registros de aplicação
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '<portabilidade>'															                    
																								||  '<ispbif>' || NVL(TO_CHAR(vr_tab_portabilidade.ispbif),'0') || '</ispbif>'
																								||  '<identdpartadmdo>' || NVL(TO_CHAR(vr_tab_portabilidade.identdpartadmdo),'0') || '</identdpartadmdo>'
																								||  '<cnpjbase_iforcontrto>' || NVL(TO_CHAR(vr_tab_portabilidade.cnpjbase_iforcontrto),'0') || '</cnpjbase_iforcontrto>'
																								||  '<nuportlddctc>' || NVL(TO_CHAR(vr_tab_portabilidade.nuportlddctc),'0') || '</nuportlddctc>'																										
																								||  '<codcontrtoor>' || NVL(TO_CHAR(vr_tab_portabilidade.codcontrtoor),'0') || '</codcontrtoor>'
																								||  '<tpcontrto>' || NVL(TO_CHAR(vr_tab_portabilidade.tpcontrto),'0') || '</tpcontrto>'
																								||  '<tpcli>' || NVL(TO_CHAR(vr_tab_portabilidade.tpcli),' ') || '</tpcli>'
																								||  '<cnpj_cpfcli>' || NVL(TO_CHAR(vr_tab_portabilidade.cnpj_cpfcli),'0') || '</cnpj_cpfcli>'
																								||  '<stportabilidade>' || NVL(TO_CHAR(vr_tab_portabilidade.stportabilidade),'0') || '</stportabilidade>'
																								|| '</portabilidade>');	
  			
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
														 ,pr_texto_completo => vr_xml_temp 
														 ,pr_texto_novo     => '</root>' 
														 ,pr_fecha_xml      => TRUE);
				
			pr_des_erro := 'OK';
													 
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        pr_des_erro := vr_des_erro;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));

      WHEN OTHERS THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := 'Erro nao tratado na consulta da situacao de portabildade em EMPR0006.pc_consulta_situacao_car: ' || SQLERRM;

    END;
  END pc_consulta_situacao_car;


  /* Aprovacao da portabilidade na JDCTC */
  PROCEDURE pc_aprovar_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato Emprestimo
                                    ,pr_nrunico_portabilidade IN tbepr_portabilidade.nrunico_portabilidade%TYPE  --Numero da portabilidade
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --Erros do processo
                                             
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_aprovar_portabilidade
    --  Sistema  : Portabilidade de Emprestimos
    --  Sigla    : CRED
    --  Autor    : Jaison
    --  Data     : Junho/2015.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gerar a Aprovacao da portabilidade
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------

    DECLARE
      vr_xml            XMLType;                       --> XML de requisição
      vr_xml_res        XMLType;                       --> XML de resposta
      vr_exc_saida      EXCEPTION;                     --> Controle de exceção
      vr_nmmetodo       VARCHAR2(100);                 --> Método da requisição do cabeçalho
      vr_tab_xml        GENE0007.typ_tab_tagxml;       --> PL Table para armazenar conteúdo XML
      vr_tab_dados_epr  EMPR0001.typ_tab_dados_epr;    --> PL Table para armazenar os dados do emprestimo
      vr_tab_erro       GENE0001.typ_tab_erro;         --> PL Table para armazenar os dados de erro
      vr_des_reto       VARCHAR2(3);
      vr_cdcritic       crapcri.cdcritic%TYPE := 0;
      vr_dscritic       VARCHAR2(4000) := '';
      vr_qtregist       INTEGER;
      vr_cdcooper       INTEGER;
      vr_cdoperad       VARCHAR2(100);
      vr_nmdatela       VARCHAR2(100);
      vr_nmeacao        VARCHAR2(100);
      vr_cdagenci       VARCHAR2(100);
      vr_nrdcaixa       VARCHAR2(100);
      vr_idorigem       VARCHAR2(100);
      vr_cdmodsub       VARCHAR2(100);
      vr_arqenvio       VARCHAR2(100);
      vr_arqreceb       VARCHAR2(100);
      vr_nmarqtmp       VARCHAR2(100);
      vr_comando        VARCHAR2(32767);
      vr_nmdireto       VARCHAR2(100);
      vr_dshorari       VARCHAR2(10);
      vr_dscomora       VARCHAR2(1000); 
      vr_dsdirbin       VARCHAR2(1000);
      vr_vlsdeved       crapepr.vlsdeved%TYPE;
      vr_qtpreapg       NUMBER;
      vr_flgativo       INTEGER;

      vr_tab_portabilidade typ_reg_retorno_xml;      

      -- Buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagectl
              ,crapcop.nrctactl
              ,SUBSTR(LPAD(crapcop.nrdocnpj,14,0),1,8) cnpjbase
              ,LPAD(crapcop.nrdocnpj,14,0) nrdocnpj
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar os dados do banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT LPAD(crapban.nrispbif,8,0) nrispbif
          FROM crapban 
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

      -- Buscar o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT CASE crapass.inpessoa WHEN 1 
                 THEN LPAD(crapass.nrcpfcgc,11,0)
                 ELSE LPAD(crapass.nrcpfcgc,14,0)
               END nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Extrair dados do XML de requisição
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar exceção
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Verifica se o banco esta cadastrado
      OPEN cr_crapban(pr_cdbccxlt => 85); -- CECRED
      FETCH cr_crapban INTO rw_crapban;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapban%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapban;
        -- Gerar exceção
        vr_cdcritic := 57;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapban;
      END IF;

      -- Verifica se o associado esta cadastrado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapass;
        -- Gerar exceção
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapass;
      END IF;

      -- Verifica se existem contratos em acordo
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdorigem => 3
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_flgativo = 1 THEN
        vr_dscritic := 'Aprovacao nao permitida, emprestimo em acordo.';
        RAISE vr_exc_saida;
      END IF;

      -- Consulta situacao da portabilidade (JDCTC)
      pc_consulta_situacao(pr_cdcooper => vr_cdcooper                --Codigo da cooperativa
                          ,pr_idservic => 2                          --CREDORA
                          ,pr_cdlegado => rw_crapcop.cdagectl        --Codigo Legado
                          ,pr_nrispbif => rw_crapban.nrispbif        --Numero ISPB IF (085)
                          ,pr_idparadm => rw_crapcop.cnpjbase        --Identificador Participante Administrado
                          ,pr_ispbifcr => rw_crapcop.cnpjbase        --ISPB IF Credora Original do Contrato
                          ,pr_nrunipor => pr_nrunico_portabilidade   --Número único da portabilidade na CTC
                          ,pr_cdconori => ''                         --Código Contrato Original*
                          ,pr_tpcontra => ''                         --Tipo Contrato*
                          ,pr_tpclient => 'F'                        --Tipo Cliente - Fixo 'F'*
                          ,pr_cnpjcpf  => 0                          --CNPJ CPF Cliente*
                          ,pr_tab_portabilidade  => vr_tab_portabilidade --Dados da Portabilidade
                          ,pr_des_erro => vr_des_reto                --Indicador erro OK/NOK
                          ,pr_dscritic => vr_dscritic);              --Descricao erro
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Caso o numero de contrato ou CPF/CNPJ estiverem diferentes retorna excecao
      IF vr_tab_portabilidade.CodContrtoOr <> pr_nrctremp OR 
         vr_tab_portabilidade.CNPJ_CPFCli  <> rw_crapass.nrcpfcgc THEN
         -- Se for PF, caso contrario sera PJ
         IF rw_crapass.inpessoa = 1 THEN
           vr_dscritic := 'Contrato e/ou CPF nao confere(m) com a solicitacao de portabilidade recebida.';
         ELSE
           vr_dscritic := 'Contrato e/ou CNPJ nao confere(m) com a solicitacao de portabilidade recebida.';
         END IF;
         RAISE vr_exc_saida;
      END IF;

      -- Obter Dados do Emprestimo
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => vr_cdcooper            --> Cooperativa conectada
                                      ,pr_cdagenci => vr_cdagenci            --> Código da agência
                                      ,pr_nrdcaixa => vr_nrdcaixa            --> Número do caixa
                                      ,pr_cdoperad => vr_cdoperad            --> Código do operador
                                      ,pr_nmdatela => 'IMPRES'               --> Nome datela conectada
                                      ,pr_idorigem => vr_idorigem            --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta            --> Conta do associado
                                      ,pr_idseqttl => 1                      --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat           --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                   --> Data solicitada do calculo
                                      ,pr_nrctremp => pr_nrctremp            --> Número contrato empréstimo
                                      ,pr_cdprogra => 'IMPRES'               --> Programa conectado
                                      ,pr_inusatab => FALSE                  --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                    --> Gerar log S/N
                                      ,pr_flgcondc => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => rw_crapass.nmprimtl    --> Nome Primeiro Titular
                                      ,pr_tab_parempctl => NULL              --> Dados tabela parametro
                                      ,pr_tab_digitaliza => NULL             --> Dados tabela parametro
                                      ,pr_nriniseq => 0                      --> Numero inicial paginacao
                                      ,pr_nrregist => 0                      --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist            --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                      ,pr_des_reto => vr_des_reto            --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);          --> Tabela com possíves erros
      -- Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN 
        vr_dscritic := 'Nao foi possivel carregar o extrato.';
        RAISE vr_exc_saida;
      END IF;

      -- Concatena o codigo da modalidade com o da submodalidade
      vr_cdmodsub := vr_tab_dados_epr(1).cdmodali || vr_tab_dados_epr(1).cdsubmod;

      -- Verifica qual metodo executar conforme modalidade e submodalidade
      CASE vr_cdmodsub
        -- Credito pessoal - com consignacao em folha de pagamento
        WHEN '0202' THEN vr_nmmetodo := 'AprovarConsignado';
        -- Credito pessoal - sem consignacao em folha de pagamento
        WHEN '0203' THEN vr_nmmetodo := 'AprovarPessoal';
        -- Aquisicao de bens – veiculos automotores
        WHEN '0401' THEN vr_nmmetodo := 'AprovarVeicular';
        -- Aquisicao de bens – outros bens
        WHEN '0402' THEN vr_nmmetodo := 'AprovarOutros';
        -- Microcredito
        WHEN '0403' THEN vr_nmmetodo := 'AprovarOutros';
        ELSE NULL;
      END CASE;

      -- Caso a modalidade seja diferente das definidas abaixo nao sera permitido aprovar
      IF vr_cdmodsub NOT IN ('0202', '0203', '0401', '0402', '0403') THEN
         vr_dscritic := 'Operacao nao permitida para a modalidade: ' || vr_cdmodsub;
         RAISE vr_exc_saida;
      END IF;

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => 2 -- CredoraPortabilidade
                            ,pr_nmmetodo => vr_nmmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => vr_des_reto
                            ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Codigo do Sistema Legado de Origem da Solicitacao
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => 'LEG' -- rw_crapcop.cdagectl
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Numero de identificacao da Instituicao Financeira no Sistema de Pagamentos Brasileiro
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapban.nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Identificador Participante Administrado
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapcop.cnpjbase
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- CNPJ Base IF Credora Original Contrato
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapcop.cnpjbase
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Numero unico da portabilidade na CTC
      pc_cria_tag(pr_dsnomtag => 'NUPortlddCTC'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => pr_nrunico_portabilidade
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Codigo Moeda Contrato
      pc_cria_tag(pr_dsnomtag => 'CodMoeda'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => 9 -- REAL
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se for Credito pessoal - com consignacao em folha de pagamento
      IF vr_cdmodsub = '0202' THEN

        -- Tipo de Ente Consignante
        pc_cria_tag(pr_dsnomtag => 'TpEnteCons'
                   ,pr_dspaitag => vr_nmmetodo
                   ,pr_dsvaltag => 2 -- Consignado (Empresa Privada)
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'int'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => vr_des_reto
                   ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;

      END IF;

			-- Regime Amortizacao
      pc_cria_tag(pr_dsnomtag => 'RegmAmtzc'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => 1 -- PRICE
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Caso nao seja Credito pessoal - com consignacao em folha de pagamento
      IF vr_cdmodsub <> '0202' THEN
        -- Tipo de Taxa
        pc_cria_tag(pr_dsnomtag => 'TpTx'
                   ,pr_dspaitag => vr_nmmetodo
                   ,pr_dsvaltag => 1 -- PRE-FIXADA
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'int'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => vr_des_reto
                   ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

			-- Data Contratacao Operacao
      pc_cria_tag(pr_dsnomtag => 'DtContrOp'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_tab_dados_epr(1).dtmvtolt,'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Taxa Juros Efetiva % a.a.
      pc_cria_tag(pr_dsnomtag => 'TxJurosEft'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_tab_dados_epr(1).txanual,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Taxa CET
      pc_cria_tag(pr_dsnomtag => 'TxCET'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_tab_dados_epr(1).percetop,'fm9999999990d00000','NLS_NUMERIC_CHARACTERS=.,')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Data Referencia Saldo Devedor Contabil para Proposta
      pc_cria_tag(pr_dsnomtag => 'DtRefSaldDevdrContb'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Seta o Saldo Devedor somando com Multa e Juros Mora
      vr_vlsdeved := vr_tab_dados_epr(1).vlsdeved + --> Saldo devedor acumulado
                     vr_tab_dados_epr(1).vlmtapar + --> Valor da Multa
                     vr_tab_dados_epr(1).vlmrapar +
					 vr_tab_dados_epr(1).vliofcpl; --> Valor do Juros de Mora

			-- Valor Saldo Devedor Contabil para Proposta
      pc_cria_tag(pr_dsnomtag => 'VlrSaldDevdrContb'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_vlsdeved,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Quantidade Total Parcelas Contrato
      pc_cria_tag(pr_dsnomtag => 'QtdTotParclContrto'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => vr_tab_dados_epr(1).qtpreemp
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Seta o total de parcelas a vencer
      vr_qtpreapg := vr_tab_dados_epr(1).qtpreapg;
      -- Se o total de parcelas estiver zerado dividir o Saldo Devedor pelo valor da parcela
      IF vr_qtpreapg = 0 THEN
        vr_qtpreapg := vr_vlsdeved / vr_tab_dados_epr(1).vlpreemp;
      END IF;
      -- Faz o arredondamento para cima
      vr_qtpreapg := CEIL(vr_qtpreapg);

			-- Quantidade Total Parcelas Contrato Vencer
      pc_cria_tag(pr_dsnomtag => 'QtdTotParclContrtoVencr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => vr_qtpreapg
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Caso nao seja Credito pessoal - com consignacao em folha de pagamento
      IF vr_cdmodsub <> '0202' THEN
        -- Tipo de Taxa
        pc_cria_tag(pr_dsnomtag => 'FlxPagto'
                   ,pr_dspaitag => vr_nmmetodo
                   ,pr_dsvaltag => 'N' -- NORMAL
                   ,pr_postag   => 0
                   ,pr_dstpdado => 'string'
                   ,pr_deftpdad => 'xsi:type'
                   ,pr_xml      => vr_xml
                   ,pr_des_erro => vr_des_reto
                   ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

			-- Valor Face Parcelas Contrato
      pc_cria_tag(pr_dsnomtag => 'VlrFaceParclContrto'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_tab_dados_epr(1).vlpreemp,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Data da proxima parcela a vencer
      pc_cria_tag(pr_dsnomtag => 'DtPrimParclContrtoVencr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(vr_tab_dados_epr(1).dtdpagto,'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Data Vencimento ultima parcela Contrato
      pc_cria_tag(pr_dsnomtag => 'DtVencUltParclContrto'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => TO_CHAR(ADD_MONTHS(vr_tab_dados_epr(1).dtpripgt, vr_tab_dados_epr(1).qtpreemp - 1),'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Codigo do Contrato SCR
      pc_cria_tag(pr_dsnomtag => 'CodContrtoSCR'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => pr_nrctremp
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- CNPJ IF Credora Original
      pc_cria_tag(pr_dsnomtag => 'CNPJIFOrigdr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapcop.nrdocnpj
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'long'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- ISPB Banco IF Credora Original
      pc_cria_tag(pr_dsnomtag => 'ISPBBcoIFOrigdr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapban.nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Codigo Banco IF Credora Original
      pc_cria_tag(pr_dsnomtag => 'CodBcoIFOrigdr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => 85 -- CECRED
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Codigo Banco IF Credora Original
      pc_cria_tag(pr_dsnomtag => 'AgBancIFOrigdr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => 100 -- CECRED
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

			-- Conta Bancaria IF Credora Original (com digito)
      pc_cria_tag(pr_dsnomtag => 'CtBancIFOrigdr'
                 ,pr_dspaitag => vr_nmmetodo
                 ,pr_dsvaltag => rw_crapcop.nrctactl
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'long'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => vr_des_reto
                 ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => vr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz

      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');

      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;

      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;

      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      GENE0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_dscritic);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => vr_cdcooper
                                    ,pr_idservic => 2 -- CREDORA
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- SOAP retornado pelo WebService
      GENE0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => vr_des_reto    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_dscritic    --> Descricao Erro
                                   ,pr_tipmodo  => 2);            --> 2 - Alternativo(usando blob)
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;  
      END IF;

      --Remove o arquivo XML fisico de envio
   /*   GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => vr_des_reto
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_saida;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => vr_des_reto
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;  */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => vr_des_reto
                           ,pr_dscritic => vr_dscritic);
      -- Verifica o retorno de erro
      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_saida;
      ELSE
        -- Busca valor do nodo dado o xPath
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => vr_dscritic);
        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se retorno conteúdo na TAG
        IF UPPER(vr_tab_xml(0).tag) = 'TRUE' THEN
          BEGIN
            -- Faz uma tentativa de atualizar o registro
            UPDATE tbepr_portabilidade SET 
                   nrunico_portabilidade = pr_nrunico_portabilidade
                  ,dtaprov_portabilidade = TRUNC(SYSDATE)
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp;

            -- Caso nao consiga atualizar o registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Inclui o registro de Portabilidade
              INSERT INTO tbepr_portabilidade
                (cdcooper
                ,nrdconta
                ,nrctremp
                ,tpoperacao
                ,nrunico_portabilidade
                ,dtaprov_portabilidade)
              VALUES
                (vr_cdcooper
                ,pr_nrdconta
                ,pr_nrctremp
                ,2 -- VENDA
                ,pr_nrunico_portabilidade
                ,TRUNC(SYSDATE));
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao aprovar Portabilidade: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          vr_dscritic := 'Falha na consulta da situacao.';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Criar do XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => 'Portabilidade aprovada com sucesso.', pr_des_erro => vr_dscritic);

      -- Salvar informações
      COMMIT;

    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina EMPR0006.pc_aprovar_portabilidade. ' ||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END;

  END pc_aprovar_portabilidade;

  /* Procedure para Cancelar Situacao */
  PROCEDURE pc_cancelar_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cód. Cooperativa
		                                 ,pr_idservic IN NUMBER                           --> Tipo de servico(1-Proponente/2-Credora)
		                                 ,pr_cdlegado IN VARCHAR2                         --> Codigo Legado
																		 ,pr_nrispbif IN NUMBER                           --> Numero ISPB IF
																		 ,pr_inparadm IN NUMBER                           --> Identificador Participante Administrado
																		 ,pr_cnpjifcr IN NUMBER                           --> CNPJ Base IF Credora Original Contrato
																		 ,pr_nuportld IN VARCHAR2                         --> Numero Portabilidade CTC
																		 ,pr_mtvcance IN VARCHAR2                         --> Motivo Cancelamento Portabilidade
																		 ,pr_flgrespo OUT NUMBER                          --> 1 - Se o registro na JDCTC for atualizado com sucesso
																		 ,pr_des_erro OUT VARCHAR2                        --> Indicador erro OK/NOK
																		 ,pr_dscritic OUT VARCHAR2) IS                    --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cancelar_portabilidade
    --  Sistema  : Procedure para atualizar situacao de portabilidade
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para cancelar a portabilidade
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml       XMLType;                   --> XML de requisição
      vr_exc_erro  EXCEPTION;                 --> Controle de exceção
      vr_nmetodo   VARCHAR2(100);             --> Método da requisição do cabeçalho
      vr_xml_res   XMLType;                   --> XML de resposta
      vr_tab_xml   GENE0007.typ_tab_tagxml;   --> PL Table para armazenar conteúdo XML
      vr_des_reto  VARCHAR2(1000);
      vr_arqenvio  VARCHAR2(100);
      vr_arqreceb  VARCHAR2(100);
      vr_nmarqtmp  VARCHAR2(100);
      vr_comando   VARCHAR2(32767);
      vr_nmdireto  VARCHAR2(100);
      vr_dshorari  VARCHAR2(10);
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000);
      vr_caminho   VARCHAR2(330);

      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;
    BEGIN
      vr_nmetodo := 'Cancelar';

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => pr_idservic
                            ,pr_nmmetodo => vr_nmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro != 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_inparadm
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cnpjifcr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NUPortlddCTC'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nuportld
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'MtvCanceltPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_mtvcance
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_des_reto);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => pr_idservic
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_des_reto);
      -- Verifica se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_tipmodo  => 2              --> 2 - Alternativo(usando blob)
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_des_reto);  --> Descricao Erro
      --Se Ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;  
      END IF;

      --Remove o arquivo XML fisico de envio
/*      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF; */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => vr_des_reto);
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
        
      ELSE -- Busca valor do nodo dado o xPath        
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);

        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;

        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha ao cancelar uma operacao de portabilidade.';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;
				
				IF UPPER(vr_tab_xml(0).tag) = 'TRUE' THEN
           pr_flgrespo := 1;
			  ELSE
           pr_flgrespo := 0;	
				END IF;				
      END IF;

      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag);

      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_des_reto IS NOT NULL THEN
					pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_des_reto));
				END IF;
				
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_cancelar_portabilidade. ' ||
                       SQLERRM;
    END;
  END pc_cancelar_portabilidade;

  /* Gerar termo de portabilidade */
  PROCEDURE pc_gera_termo(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo da cooperativa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --Numero Contrato Emprestimo
                         ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS         --Erros do processo
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_gera_termo                                       Antigo: 
  Sistema  : Portabilidade de Emprestimos
  Sigla    : CRED
  Autor    : Jaison
  Data     : Junho/2015                           Ultima atualizacao: 05/04/2016
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo   : Procedure para Gerar termo de portabilidade
  
  Alterações : 05/04/2016 - Ajuste para retirar o "*" ao remover o arquivo
                            (Adriano).
               
  -------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.nmextcop
            ,crapcop.nmrescop
            ,crapcop.nrdocnpj
            ,crapcop.dsendcop
            ,crapcop.nrendcop
            ,crapcop.dscomple
            ,crapcop.nrcepend
            ,crapcop.nmcidade
            ,crapcop.cdufdcop
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Buscar o associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT CASE crapass.inpessoa WHEN 1 
               THEN GENE0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc,1)
               ELSE GENE0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc,2)
             END nrcpfcgc
            ,crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor da Proposta de Emprestimo
    CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                     ,pr_nrdconta IN crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crawepr.dtmvtolt
              ,crawepr.vlemprst
              ,crawepr.vlpreemp
              ,crawepr.qtpreemp
              ,crawepr.dtdpagto
              ,crawepr.percetop
              ,crawepr.txdiaria
              ,crawepr.cdlcremp
              ,crawepr.tpemprst
              ,(SELECT COUNT(1)
                  FROM crappep
                 WHERE crappep.cdcooper = crawepr.cdcooper
                   AND crappep.nrdconta = crawepr.nrdconta
                   AND crappep.nrctremp = crawepr.nrctremp
                   AND crappep.inliquid = 1
                   AND crappep.inprejuz = 0) qtprcpag
              ,(SELECT MAX(dtvencto)
                  FROM crappep
                 WHERE crappep.cdcooper = crawepr.cdcooper
                   AND crappep.nrdconta = crawepr.nrdconta
                   AND crappep.nrctremp = crawepr.nrctremp) dtvencto
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Cursor com os dados da portabilidade
    CURSOR cr_tbepr_portabilidade(pr_cdcooper IN tbepr_portabilidade.cdcooper%TYPE
                                 ,pr_nrdconta IN tbepr_portabilidade.nrdconta%TYPE
                                 ,pr_nrctremp IN tbepr_portabilidade.nrctremp%TYPE) IS
      SELECT tbepr_portabilidade.nmif_origem
            ,tbepr_portabilidade.nrcnpjbase_if_origem
            ,tbepr_portabilidade.nrcontrato_if_origem
        FROM tbepr_portabilidade
       WHERE tbepr_portabilidade.cdcooper = pr_cdcooper
         AND tbepr_portabilidade.nrdconta = pr_nrdconta
         AND tbepr_portabilidade.nrctremp = pr_nrctremp;
    rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;

    -- Cursor de Linha de Credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT craplcr.cdmodali
            ,craplcr.cdsubmod
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    -- Cursor para buscar a modalidade
    CURSOR cr_gnmodal(pr_cdmodali IN gnmodal.cdmodali%TYPE) IS
      SELECT gnmodal.cdmodali
            ,gnmodal.dsmodali
        FROM gnmodal
       WHERE gnmodal.cdmodali = pr_cdmodali;
    rw_gnmodal cr_gnmodal%ROWTYPE;

    -- Cursor para buscar a sub modalidade
    CURSOR cr_gnsbmod(pr_cdmodali IN gnsbmod.cdmodali%TYPE
                     ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE) IS
      SELECT gnsbmod.cdsubmod
            ,gnsbmod.dssubmod
        FROM gnsbmod
       WHERE gnsbmod.cdmodali = pr_cdmodali
         AND gnsbmod.cdsubmod = pr_cdsubmod;
    rw_gnsbmod cr_gnsbmod%ROWTYPE;

    -- Buscar o telefone do associado
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type
                      ,pr_idseqttl IN craptfc.idseqttl%type
                      ,pr_tptelefo IN craptfc.tptelefo%type) IS
      SELECT craptfc.nrdddtfc
            ,craptfc.nrtelefo
        FROM craptfc
       WHERE craptfc.cdcooper = pr_cdcooper
         AND craptfc.nrdconta = pr_nrdconta
         AND craptfc.idseqttl = pr_idseqttl
         AND craptfc.tptelefo = pr_tptelefo
       ORDER BY craptfc.progress_recid ASC;
    rw_craptfc cr_craptfc%ROWTYPE;

    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locais
    vr_cdcooper       INTEGER;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);
    vr_nrtelefo       VARCHAR2(100);
    vr_tpcontra       VARCHAR2(100);
    vr_dsdadata       VARCHAR2(100);
    vr_txanual        crawepr.txmensal%TYPE;
    vr_txnomina       crawepr.txmensal%TYPE;
    vr_nmdireto       VARCHAR2(1000);
    vr_nmarqimp       VARCHAR2(1000);
    vr_nmarquiv       VARCHAR2(1000);
    vr_comando        VARCHAR2(1000);
    vr_des_reto       VARCHAR2(3);
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    --Variaveis de Excecao
    vr_exc_saida EXCEPTION;
         
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_termo'
                                ,pr_action => NULL);

      -- Extrair dados do XML de requisição
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar exceção
        vr_cdcritic := 651;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se o associado esta cadastrado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapass;
        -- Gerar exceção
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapass;
      END IF;

      -- Verifica se a proposta esta cadastrada
      OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crawepr%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crawepr;
        -- Gerar exceção
        vr_cdcritic := 510;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crawepr;
      END IF;

      -- Verifica se a linha de credito esta cadastrada
      OPEN cr_craplcr(pr_cdcooper => vr_cdcooper
                     ,pr_cdlcremp => rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_craplcr%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplcr;
        -- Gerar exceção
        vr_cdcritic := 363;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craplcr;
      END IF;

      -- Verifica se a linha de credito esta cadastrada
      OPEN cr_tbepr_portabilidade(pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                     	           ,pr_nrctremp => pr_nrctremp);
      FETCH cr_tbepr_portabilidade INTO rw_tbepr_portabilidade;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_tbepr_portabilidade%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_tbepr_portabilidade;
        -- Gerar exceção
        vr_cdcritic := 0;
        vr_dscritic := 'Portabilidade nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_tbepr_portabilidade;
      END IF;

      --Selecionar Modalidade
      OPEN cr_gnmodal (pr_cdmodali => rw_craplcr.cdmodali);
      FETCH cr_gnmodal INTO rw_gnmodal;
      --Fechar Cursor
      CLOSE cr_gnmodal;

      --Selecionar Sub Modalidade
      OPEN cr_gnsbmod (pr_cdmodali => rw_craplcr.cdmodali
                      ,pr_cdsubmod => rw_craplcr.cdsubmod);
      FETCH cr_gnsbmod INTO rw_gnsbmod;
      --Fechar Cursor
      CLOSE cr_gnsbmod;

      --Selecionar telefone residencial
      OPEN cr_craptfc (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => 1
                      ,pr_tptelefo => 1); -- Residencial
      FETCH cr_craptfc INTO rw_craptfc;
      IF cr_craptfc%FOUND THEN
        vr_nrtelefo := rw_craptfc.nrdddtfc || ' ' || rw_craptfc.nrtelefo;
        --Fechar Cursor
        CLOSE cr_craptfc;
      ELSE
        --Fechar Cursor
        CLOSE cr_craptfc;

        --Selecionar telefone celular
        OPEN cr_craptfc (pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => 1
                        ,pr_tptelefo => 2); -- Celular
        FETCH cr_craptfc INTO rw_craptfc;
        IF cr_craptfc%FOUND THEN
          vr_nrtelefo := rw_craptfc.nrdddtfc || ' ' || rw_craptfc.nrtelefo;
          --Fechar Cursor
          CLOSE cr_craptfc;
        ELSE
          --Fechar Cursor
          CLOSE cr_craptfc;

          --Selecionar telefone celular
          OPEN cr_craptfc (pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => 1
                          ,pr_tptelefo => 3); -- Comercial
          FETCH cr_craptfc INTO rw_craptfc;
          IF cr_craptfc%FOUND THEN
            vr_nrtelefo := rw_craptfc.nrdddtfc || ' ' || rw_craptfc.nrtelefo;
            --Fechar Cursor
            CLOSE cr_craptfc;
          ELSE
            --Fechar Cursor
            CLOSE cr_craptfc;
            vr_nrtelefo := '';
          END IF;
        END IF;
      END IF;

      -- A utilizacao da taxa diaria para conversao anual eh devido o 
      -- contrato antigo nao possuir taxa mensal
      vr_txanual  := TRUNC((POWER(1 + (rw_crawepr.txdiaria / 100), 360) - 1) * 100, 5);
      vr_txnomina := TRUNC(((POWER(1 + (vr_txanual / 100), 1/12) - 1) * 12) * 100, 5);

      -- Descricao da cidade e data
      vr_dsdadata := INITCAP(rw_crapcop.nmcidade) || ', ' ||
                     TO_CHAR(SYSDATE, 'DD') || ' de ' || 
                     LOWER(GENE0001.vr_vet_nmmesano(TO_CHAR(SYSDATE,'MM'))) || ' de ' || 
                     TO_CHAR(SYSDATE, 'YYYY') ||'.';

      -- Tipo de contrato
      CASE rw_gnmodal.cdmodali || rw_gnsbmod.cdsubmod
        WHEN '0203' THEN vr_tpcontra := 'Crédito Pessoal';
        WHEN '0401' THEN vr_tpcontra := 'Financiamento de Veículos';
                    ELSE vr_tpcontra := 'Outros Créditos';
      END CASE;

      -- Diretorio para salvar
      vr_nmdireto := GENE0001.fn_diretorio (pr_tpdireto => 'C' --> usr/coop
                                           ,pr_cdcooper => vr_cdcooper
                                           ,pr_nmsubdir => 'rl'); 

      -- Nome Arquivo
      vr_nmarqimp := dbms_random.string('X',20) || '.pdf';

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');

      --Texto do Termo
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<dados>'||
        '  <nmextcop>'|| rw_crapcop.nmextcop ||'</nmextcop>'||
        '  <nmrescop>'|| rw_crapcop.nmrescop ||'</nmrescop>'||
        '  <nrdocnpj>'|| GENE0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2) ||'</nrdocnpj>'||
        '  <dsendcop>'|| rw_crapcop.dsendcop ||'</dsendcop>'||
        '  <nrendcop>'|| rw_crapcop.nrendcop ||'</nrendcop>'||
        '  <dscomple>'|| rw_crapcop.dscomple ||'</dscomple>'||
        '  <nrcepend>'|| rw_crapcop.nrcepend ||'</nrcepend>'||
        '  <nmcidade>'|| rw_crapcop.nmcidade ||'</nmcidade>'||
        '  <cdufdcop>'|| rw_crapcop.cdufdcop ||'</cdufdcop>'||
        '  <nmprimtl>'|| rw_crapass.nmprimtl ||'</nmprimtl>'||
        '  <nrcpfcgc>'|| rw_crapass.nrcpfcgc ||'</nrcpfcgc>'||
        '  <nrtelefo>'|| vr_nrtelefo ||'</nrtelefo>'||
        '  <tpcontra>'|| vr_tpcontra ||'</tpcontra>'||
        '  <cdmodali>'|| rw_gnmodal.cdmodali ||'</cdmodali>'||
        '  <dsmodali>'|| rw_gnmodal.dsmodali ||'</dsmodali>'||
        '  <cdsubmod>'|| rw_gnsbmod.cdsubmod ||'</cdsubmod>'||
        '  <dssubmod>'|| rw_gnsbmod.dssubmod ||'</dssubmod>'||
        '  <nmiforig>'|| rw_tbepr_portabilidade.nmif_origem ||'</nmiforig>'||
        '  <cnpjiforig>'|| GENE0002.fn_mask_cpf_cnpj(rw_tbepr_portabilidade.nrcnpjbase_if_origem,2) ||'</cnpjiforig>'||
        '  <ctriforig>'|| rw_tbepr_portabilidade.nrcontrato_if_origem ||'</ctriforig>'||
        '  <dtmvtolt>'|| TO_CHAR(rw_crawepr.dtmvtolt,'DD/MM/YYYY') ||'</dtmvtolt>'||
        '  <vlemprst>'|| to_char(rw_crawepr.vlemprst,'fm999999g999g990d00mi') ||'</vlemprst>'||
        '  <txnominal>'|| TO_CHAR(vr_txnomina,'fm9999g999g990d00000') ||'</txnominal>'||
        '  <txefetivo>'|| TO_CHAR(vr_txanual,'fm9999g999g990d00000') ||'</txefetivo>'||
        '  <txcet>'|| TO_CHAR(rw_crawepr.percetop,'fm9999g999g990d00000') ||'</txcet>'||
        '  <qtpreemp>'|| rw_crawepr.qtpreemp ||'</qtpreemp>'||
		'  <qtprcpag>'|| rw_crawepr.qtprcpag ||'</qtprcpag>'||
        '  <dtvencto>'|| rw_crawepr.dtvencto ||'</dtvencto>'||
        '  <vlpreemp>'|| TO_CHAR(rw_crawepr.vlpreemp,'fm9999g999g990d00') ||'</vlpreemp>'||
        '  <dtdpagto>'|| TO_CHAR(rw_crawepr.dtdpagto,'DD/MM/YYYY') ||'</dtdpagto>'||
        '  <dtultpgt>'|| TO_CHAR(ADD_MONTHS(rw_crawepr.dtdpagto, rw_crawepr.qtpreemp - 1),'DD/MM/YYYY') ||'</dtultpgt>'||
        '  <dsdadata>'|| vr_dsdadata ||'</dsdadata>'||
		'  <tpemprst>'|| rw_crawepr.tpemprst ||'</tpemprst>'||
        '</dados>');

      --Finaliza TAG Relatorio
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE);

      -- Gera relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => 'IMPRES'                      --> Programa chamador
                                 ,pr_dtmvtolt  => NULL                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/dados'                 --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl073_termo.jasper'        --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 73                            --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF; 

      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Ayllos Web       
      IF vr_idorigem = 5 THEN

        --Enviar arquivo para Web
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          --Sair 
          RAISE vr_exc_saida;
        END IF;
        
        -- Comando para remover arquivo do rl
        vr_comando:= 'rm '||vr_nmdireto || '/' || vr_nmarqimp||' 2>/dev/null';
        
        --Remover Arquivo pre-existente
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_des_reto
                             ,pr_des_saida   => vr_dscritic);
                             
        --Se ocorreu erro dar RAISE
        IF vr_des_reto = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);

    EXCEPTION

      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina EMPR0006.pc_aprovar_portabilidade. ' ||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

  END pc_gera_termo;
	
		/* Procedure para Incluir Pessoal */
  PROCEDURE pc_incluir_pessoal(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cód. cooperativa
                              ,pr_idservic IN INTEGER               --> Tipo de servico(1-Proponente/2-Credora)
		                          ,pr_cdlegado IN VARCHAR2              --> Codigo Legado
														  ,pr_nrispbif IN VARCHAR2              --> Numero ISPB IF
														  ,pr_inparadm IN VARCHAR2              --> Identificador Participante Administrado
															,pr_cdcntori IN VARCHAR2              --> Contrato Original
															,pr_tpcontrt IN VARCHAR2              --> Tipo de contrato(modalidade)
														  ,pr_cnpjifcr IN VARCHAR2              --> CNPJ Base IF Credora Original Contrato
															,pr_dtrefsld IN DATE                  --> Data Referência Saldo Devedor Contábil para Proposta
															,pr_vlslddev IN VARCHAR2              --> Valor Saldo Devedor Contábil para Proposta
															,pr_cnpjcpfc IN VARCHAR2              --> CNPJ/CPF do Cliente
															,pr_nmclient IN VARCHAR2              --> Nome do Cliente
															,pr_nrtelcli IN VARCHAR2              --> Telefone do cliente
															,pr_tpdetaxa IN VARCHAR2              --> Tipo de taxa
															,pr_txjurnom IN VARCHAR2              --> Taxa Juros Nominal % a.a.
															,pr_txjureft IN VARCHAR2              --> Taxa Juros Efetiva % a.a.
															,pr_txcet    IN VARCHAR2              --> Taxa CET
															,pr_cddmoeda IN VARCHAR2              --> Código da moeda
															,pr_regamrtz IN VARCHAR2              --> Regime Amortização
															,pr_dtcontop IN DATE                  --> Data Contratação Operação
															,pr_qtdtotpr IN VARCHAR2              --> Quantidade Total Parcelas Contrato
															,pr_flxpagto IN VARCHAR2              --> Fluxo de Pagamento
															,pr_vlparemp IN VARCHAR2              --> Valor Face Parcelas Contrato
															,pr_dtpripar IN DATE                  --> Data Vencimento Primeira Parcela Contrato
															,pr_dtultpar IN DATE                  --> Data Vencimento Última Parcela Contrato
															,pr_dsendcar IN VARCHAR2              --> Logradouro Endereço Carta Portabilidade
															,pr_dscmpend IN VARCHAR2              --> Complemento Endereço Carta Portabilidade
															,pr_nrentere IN VARCHAR2              --> Numero Endereço Carta Portabilidade
															,pr_cidadend IN VARCHAR2              --> Cidade Endereço Carta Portabilidade
															,pr_ufendere IN VARCHAR2              --> UF Endereço Carta Portabilidade
															,pr_cepender IN VARCHAR2              --> CEP Endereço Carta Portabilidade
															,pr_idsolici OUT INTEGER              --> ID da solicitação (0 - Se não foi realizada com sucesso) 
														  ,pr_des_erro OUT VARCHAR2             --> Indicador erro OK/NOK
														  ,pr_dscritic OUT VARCHAR2) IS         --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_pessoal
    --  Sistema  : Procedure para atualizar situacao de portabilidade
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para inclusão de uma Solicitação de Portabilidade do 
    --             tipo de contrato Pessoal na base do JDCTC para posterior envio desta 
    --             informação a CIP.
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml       XMLType;                   --> XML de requisição
      vr_exc_erro  EXCEPTION;                 --> Controle de exceção
      vr_nmetodo   VARCHAR2(100);             --> Método da requisição do cabeçalho
      vr_xml_res   XMLType;                   --> XML de resposta
      vr_tab_xml   GENE0007.typ_tab_tagxml;   --> PL Table para armazenar conteúdo XML
      vr_des_reto  VARCHAR2(1000);
      vr_arqenvio  VARCHAR2(100);
      vr_arqreceb  VARCHAR2(100);
      vr_nmarqtmp  VARCHAR2(100);
      vr_comando   VARCHAR2(32767);
      vr_nmdireto  VARCHAR2(100);
      vr_dshorari  VARCHAR2(10);
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000);
      vr_caminho   VARCHAR2(330);

      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;

    BEGIN
      vr_nmetodo := 'IncluirPessoal';

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => pr_idservic
                            ,pr_nmmetodo => vr_nmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_inparadm
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);								 								 
								 
			-- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NumCtrlIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(SYSDATE,'RRRRMMDD')||to_char(SYSTIMESTAMP,'SSSSSFF5') 
								 /* Data concatenado com segundos passados da meia noite, e cada segundo fracionados*/
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CodContrtoOr'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdcntori
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);								 								 
								 
			-- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cnpjifcr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => '0203'
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtRefSaldDevdrContb'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtrefsld, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
						
 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'VlrSaldDevdrContb'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => replace(pr_vlslddev,',','.')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => 'F'
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJ_CPFCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cnpjcpfc
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'long'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NomCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nmclient
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;			

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TelCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrtelcli
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF; 

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpTx'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_tpdetaxa
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxJurosNoml'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txjurnom
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxJurosEft'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txjureft
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxCET'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txcet
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CodMoeda'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cddmoeda
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'RegmAmtzc'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_regamrtz
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtContrOp'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtcontop, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'QtdTotParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_qtdtotpr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'FlxPagto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_flxpagto
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'VlrFaceParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_vlparemp
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtVencPrimParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtpripar, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtVencUltParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtultpar, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
									
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'LogradEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_dsendcar
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CompEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_dscmpend
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NumEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrentere
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CidEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cidadend
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'UFEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_ufendere
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CEPEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cepender
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_des_reto);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => pr_idservic
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_des_reto);
      -- Verifica se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_des_reto    --> Descricao Erro
                                   ,pr_tipmodo  => 2);            --> 2 - Alternativo(usando blob)
      --Se Ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;  
      END IF;

      --Remove o arquivo XML fisico de envio
   /*   GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;  */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => vr_des_reto);
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
        
      ELSE 
        -- Busca valor do nodo dado o xPath
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);

        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;

        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha ao incluir uma solicitação de portabilidade do tipo de contrato Pessoal.';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;
				
				pr_idsolici := to_number(vr_tab_xml(0).tag);
      END IF;

      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag);

      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_des_reto IS NOT NULL THEN
					pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_des_reto));
				END IF;
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_incluir_pessoal. ' ||
                       SQLERRM;
    END;
  END pc_incluir_pessoal;		
	
	/* Procedure para Incluir Veicular */
  PROCEDURE pc_incluir_veicular(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cód. cooperativa
                              ,pr_idservic IN INTEGER               --> Tipo de servico(1-Proponente/2-Credora)
		                          ,pr_cdlegado IN VARCHAR2              --> Codigo Legado
														  ,pr_nrispbif IN VARCHAR2              --> Numero ISPB IF
														  ,pr_inparadm IN VARCHAR2              --> Identificador Participante Administrado
															,pr_cdcntori IN VARCHAR2              --> Contrato Original
															,pr_tpcontrt IN VARCHAR2              --> Tipo de contrato(modalidade)
														  ,pr_cnpjifcr IN VARCHAR2              --> CNPJ Base IF Credora Original Contrato
															,pr_dtrefsld IN DATE                  --> Data Referência Saldo Devedor Contábil para Proposta
															,pr_vlslddev IN VARCHAR2              --> Valor Saldo Devedor Contábil para Proposta
															,pr_cnpjcpfc IN VARCHAR2              --> CNPJ/CPF do Cliente
															,pr_nmclient IN VARCHAR2              --> Nome do Cliente
															,pr_nrtelcli IN VARCHAR2              --> Telefone do cliente
															,pr_tpdetaxa IN VARCHAR2              --> Tipo de taxa
															,pr_txjurnom IN VARCHAR2              --> Taxa Juros Nominal % a.a.
															,pr_txjureft IN VARCHAR2              --> Taxa Juros Efetiva % a.a.
															,pr_txcet    IN VARCHAR2              --> Taxa CET
															,pr_cddmoeda IN VARCHAR2              --> Código da moeda
															,pr_regamrtz IN VARCHAR2              --> Regime Amortização
															,pr_dtcontop IN DATE                  --> Data Contratação Operação
															,pr_qtdtotpr IN VARCHAR2              --> Quantidade Total Parcelas Contrato
															,pr_flxpagto IN VARCHAR2              --> Fluxo de Pagamento
															,pr_vlparemp IN VARCHAR2              --> Valor Face Parcelas Contrato
															,pr_dtpripar IN DATE                  --> Data Vencimento Primeira Parcela Contrato
															,pr_dtultpar IN DATE                  --> Data Vencimento Última Parcela Contrato
															,pr_dsendcar IN VARCHAR2              --> Logradouro Endereço Carta Portabilidade
															,pr_nrentere IN VARCHAR2              --> Numero Endereço Carta Portabilidade
															,pr_cidadend IN VARCHAR2              --> Cidade Endereço Carta Portabilidade
															,pr_ufendere IN VARCHAR2              --> UF Endereço Carta Portabilidade
															,pr_cepender IN VARCHAR2              --> CEP Endereço Carta Portabilidade
															,pr_idsolici OUT INTEGER              --> ID da solicitação (0 - Se não foi realizada com sucesso) 
														  ,pr_des_erro OUT VARCHAR2             --> Indicador erro OK/NOK
														  ,pr_dscritic OUT VARCHAR2) IS         --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_veicular
    --  Sistema  : Procedure para atualizar situacao de portabilidade
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para inclusão de uma Solicitação de Portabilidade do 
    --             tipo de contrato Veicular na base do JDCTC para posterior envio desta 
    --             informação a CIP.
    --
    -- Alteracoes: 
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml       XMLType;                   --> XML de requisição
      vr_exc_erro  EXCEPTION;                 --> Controle de exceção
      vr_nmetodo   VARCHAR2(100);             --> Método da requisição do cabeçalho
      vr_xml_res   XMLType;                   --> XML de resposta
      vr_tab_xml   GENE0007.typ_tab_tagxml;   --> PL Table para armazenar conteúdo XML
      vr_des_reto  VARCHAR2(1000);
      vr_arqenvio  VARCHAR2(100);
      vr_arqreceb  VARCHAR2(100);
      vr_nmarqtmp  VARCHAR2(100);
      vr_comando   VARCHAR2(32767);
      vr_nmdireto  VARCHAR2(100);
      vr_dshorari  VARCHAR2(10);
      vr_dscomora  VARCHAR2(1000); 
      vr_dsdirbin  VARCHAR2(1000);
      vr_caminho   VARCHAR2(330);

      --Variaveis DOM
      vr_xmldoc     xmldom.DOMDocument;
      vr_root       DBMS_XMLDOM.DOMNode;
      vr_lista_nodo DBMS_XMLDOM.DOMNodelist;

    BEGIN
      vr_nmetodo := 'IncluirVeicular';

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => pr_idservic
                            ,pr_nmmetodo => vr_nmetodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_inparadm
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);								 								 
								 
			-- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NumCtrlIF'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(SYSDATE,'RRRRMMDD')||to_char(SYSTIMESTAMP,'SSSSSFF5') 
								 /* Data concatenado com segundos passados da meia noite, e cada segundo fracionados*/
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
						
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CodContrtoOr'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cdcntori
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);								 								 
								 
			-- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cnpjifcr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_tpcontrt
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtRefSaldDevdrContb'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtrefsld, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
						
 			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'VlrSaldDevdrContb'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => replace(pr_vlslddev,',','.')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => 'F'
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJ_CPFCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cnpjcpfc
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'long'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NomCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nmclient
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;			

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TelCli'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrtelcli
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF; 

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpTx'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_tpdetaxa
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxJurosNoml'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txjurnom
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxJurosEft'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txjureft
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TxCET'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_txcet
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CodMoeda'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cddmoeda
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'RegmAmtzc'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_regamrtz
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtContrOp'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtcontop, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'QtdTotParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_qtdtotpr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'FlxPagto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_flxpagto
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'VlrFaceParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_vlparemp
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'double'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtVencPrimParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtpripar, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);
      
      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
			-- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'DtVencUltParclContrto'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => to_char(pr_dtultpar, 'YYYYMMDD')
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'LogradEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_dsendcar
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NumEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_nrentere
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CidEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cidadend
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'UFEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_ufendere
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
			
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CEPEndCartaPortldd'
                 ,pr_dspaitag => vr_nmetodo
                 ,pr_dsvaltag => pr_cepender
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Segundos passados da meia noite, e cada segundo fracionados
      vr_dshorari:= TO_CHAR(SYSTIMESTAMP,'SSSSSFF5');
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari;
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari;
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_des_reto);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => pr_idservic
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_des_reto);
      -- Verifica se ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => vr_xml         --> Saida para o XML
                                   ,pr_tipmodo  => 2              --> 2 - Alternativo(usando blob)
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_des_reto);  --> Descricao Erro
      --Se Ocorreu erro
      IF vr_des_reto IS NOT NULL THEN
        RAISE vr_exc_erro;  
      END IF;

      --Remove o arquivo XML fisico de envio
    /*  GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_des_reto);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_erro;    
      END IF; */

      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => vr_des_reto);
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
        
      ELSE -- Busca valor do nodo dado o xPath        
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);

        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;

        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha ao incluir uma solicitação de portabilidade do tipo de contrato Pessoal.';
          pr_des_erro := 'NOK';

          RAISE vr_exc_erro;
        END IF;
				
				pr_idsolici := to_number(vr_tab_xml(0).tag);
      END IF;

      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag);

      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
				IF vr_des_reto IS NOT NULL THEN
					pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_des_reto));
				END IF;
				
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_incluir_veicular. ' ||
                       SQLERRM;
    END;
  END pc_incluir_veicular;		
  
  -- Envia requisicao WebService para o JDCTC acessando o método ConsultarDetalhePessoal ou ConsultarDetalheVeicular.
  PROCEDURE pc_consultar_detalhe(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_cdlegado IN VARCHAR2              --> Codigo Legado
                                ,pr_nrispbif IN VARCHAR2              --> Numero ISPB IF (085)
                                ,pr_idparadm IN VARCHAR2              --> Identificador Participante Administrado
                                ,pr_ispbifcr IN VARCHAR2              --> ISPB IF Credora Original do Contrato
                                ,pr_nrunipor IN VARCHAR2              --> Número único da portabilidade na CTC
                                ,pr_cdconori IN VARCHAR2              --> Código Contrato Original*
                                ,pr_tpcontra IN VARCHAR2              --> Tipo Contrato*
                                ,pr_tpclient IN CHAR                  --> Tipo Cliente - Fixo 'F'*
                                ,pr_cnpjcpf  IN VARCHAR2              --> CNPJ CPF Cliente*
                                ,pr_metodo   IN VARCHAR2              --> Metodo da requisicao
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                ,pr_xml_res  OUT xmltype              --> XML de resposta
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                        
  BEGIN
  /* .............................................................................

  Programa: pc_consultar_detalhe
  Sistema : Envia requisicao WebService para o JDCTC acessando o método 
            ConsultarDetalhePessoal ou ConsultarDetalheVeicular.
  Sigla   : EMPR
  Autor   : Lucas Afonso Lombardi Moreira
  Data    : Junho/15.                    Ultima atualizacao: 22/06/2015

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Executa método de consulta ConsultarDetalhePessoal no JDCTC
              e retorna o xml de retorno.
              
  Alteracoes:
  ..............................................................................*/ 
       
    DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
        
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
          
      -- Variaveis para WebService
      vr_nmetodo VARCHAR2(100);
      vr_xml     XMLType;
      vr_xml_res XMLType;
      
      vr_dshorari NUMBER;
      vr_nmdireto VARCHAR2(500);
      vr_arqreceb VARCHAR2(500);
      vr_nmarqtmp VARCHAR2(500);
      vr_arqenvio VARCHAR2(500);
      
    BEGIN

      -- Gerar cabeçalho do envelope SOAP
      pc_gera_cabecalho_soap(pr_idservic => 1
                            ,pr_nmmetodo => pr_metodo
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro != 'OK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CdLegado'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => 'LEG' -- LAL -- pr_cdlegado
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);
                     
      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
          
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ISPBIF'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_nrispbif
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;      
          
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'IdentdPartAdmdo'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_idparadm
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
         
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJBase_IFOrContrto'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_ispbifcr
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'int'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
         
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'NUPortlddCTC'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_nrunipor
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CodContrtoOr'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_cdconori
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpContrto'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_tpcontra
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;              
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'TpCli'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_tpclient
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;               
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'CNPJ_CPFCli'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => pr_cnpjcpf
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Gerar TAGs com os valores dos parâmetros
      pc_cria_tag(pr_dsnomtag => 'ID_Solicitacao'
                 ,pr_dspaitag => pr_metodo
                 ,pr_dsvaltag => ''
                 ,pr_postag   => 0
                 ,pr_dstpdado => 'string'
                 ,pr_deftpdad => 'xsi:type'
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca do diretorio base da cooperativa para a geração de arquivos
      vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			     	 	 		   	       ,pr_cdcooper => pr_cdcooper   --> Cooperativa
				  	   			    				         ,pr_nmsubdir => 'arq');       --> Raiz
                                         
      --Buscar Time
      vr_dshorari:= gene0002.fn_busca_time;  
                                             
      --Diretorio Arquivos Recebidos                                        
      vr_arqreceb:= vr_nmdireto||'/'||'PORTAB.SOAP.RET'||'.'||
                    TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||'.'||vr_dshorari||'.xml';
                    
      --Diretorio Arquivos Envio 
      vr_nmarqtmp:= 'PORTAB.SOAP.ENV'||'.'||TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY')||
                    '.'||vr_dshorari||'.xml';
                    
      --Arquivo de Envio com path                   
      vr_arqenvio:= vr_nmdireto||'/'||vr_nmarqtmp;

      --Gerar Arquivo XML Fisico
      gene0002.pc_XML_para_arquivo(pr_XML      => vr_xml         --> Instância do XML Type
                                  ,pr_caminho  => vr_nmdireto    --> Diretório para saída
                                  ,pr_arquivo  => vr_nmarqtmp    --> Nome do arquivo de saída
                                  ,pr_des_erro => vr_dscritic);  --> Retorno de erro, caso ocorra
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- REQUISICAO PARA O WEBSERVICE - JDCTC
      SOAP0001.pc_soap_jdctc_client (pr_cdcooper => pr_cdcooper
                                    ,pr_idservic => 1
                                    ,pr_arqenvio => vr_arqenvio
                                    ,pr_arqreceb => vr_arqreceb
                                    ,pr_des_reto => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      
      -- SOAP retornado pelo WebService
      gene0002.pc_arquivo_para_xml (pr_nmarquiv => vr_arqreceb    --> Nome do caminho completo) 
                                   ,pr_xmltype  => pr_xml_res     --> Saida para o XML
                                   ,pr_des_reto => pr_des_erro    --> Descrição OK/NOK
                                   ,pr_dscritic => vr_dscritic    --> Descricao Erro
                                   ,pr_tipmodo  => 2);            --> 2 - Alternativo(usando blob)

      --Se Ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;  
      END IF;
      
      --Remove o arquivo XML fisico de envio
   /*   GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqenvio||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_saida;    
      END IF;

      --Remove o arquivo XML fisico de retorno
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => 'rm '||vr_arqreceb||' 2> /dev/null'
                            ,pr_typ_saida   => pr_des_erro
                            ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF pr_des_erro = 'ERR' THEN
        RAISE vr_exc_saida;    
      END IF; */
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina EMPR0006.pc_consultar_detalhe_pessoal. ' ||SQLERRM;
    END;
  END pc_consultar_detalhe;
  
  -- Verifica dados da proposta de portabilidade no JDCTC.
  PROCEDURE pc_verifica_dados_JDCTC_prt(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_nrdconta IN crawepr.nrdconta%TYPE --> número da conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Data da critica
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_verifica_dados_JDCTC_prt
     Sistema : Verifica dados da proposta de portabilidade no JDCTC.
     Sigla   : EMPR
     Autor   : Lucas Afonso Lombardi Moreira
     Data    : Junho/15.                    Ultima atualizacao: 22/06/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Executa método de consulta para obter detalhes da operação no 
                 sistema JDCTC e valida se o Saldo devedor, quantidade de parcelas
                 a vencer e a data de vencimento da última parcela da proposta de 
                 portabilidade conferem com os dados retornados do JDCTC.
               
     Observacao: -----

     Alteracoes:
     ..............................................................................*/ 
     
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(400);
      vr_des_erro       VARCHAR2(400);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis extraídas do log
      vr_cdcooper INTEGER := 0;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      
      -- Variaveis Utilitarias
      vr_modalidade     VARCHAR2(4);
      vr_metodo         VARCHAR2(200);
      vr_hasfound       BOOLEAN;
      
      -- Variaveis para busca dos valores de retorno
      vr_qtd_parc_vencr VARCHAR2(200);
      vr_dt_ven_ult_par VARCHAR2(200);
      vr_vlr_sald_devdr VARCHAR2(200);
      
      vr_nodecount      INTEGER;
      vr_PortIddAprovd  xmldom.DOMNode;
      vr_filhos         gene0007.typ_mult_array;
      vr_domDoc         DBMS_XMLDOM.DOMDocument;
      
      -- XML de retorno da requisição WebService
      vr_xml_res XMLType;
      
      -- Retorno da PROCEDURE
      vr_confere_dados VARCHAR2(10) := 'S';
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar os dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagectl
              ,SUBSTR(LPAD(crapcop.nrdocnpj,14,0),1,8) cnpjbase
              ,LPAD(crapcop.nrdocnpj,14,0) nrdocnpj
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Buscar os dados do banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT LPAD(crapban.nrispbif,8,0) nrispbif
          FROM crapban 
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
      
      -- Busca os dados da proposta
      CURSOR cr_crawepr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crawepr.nrdconta%TYPE
                        ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT epr.cdlcremp
              ,epr.insitapr
              ,epr.vlemprst
              ,epr.qtpreemp
              ,pep.dtvencto dtultven
          FROM crawepr epr
              ,crappep pep
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND pep.cdcooper = epr.cdcooper
           AND pep.nrdconta = epr.nrdconta
           AND pep.nrctremp = epr.nrctremp
           AND pep.dtvencto = (SELECT MAX(dtvencto)
                                 FROM crappep pep
                                WHERE pep.cdcooper = epr.cdcooper
                                  AND pep.nrdconta = epr.nrdconta
                                  AND pep.nrctremp = epr.nrctremp);
      rw_crawepr cr_crawepr%ROWTYPE;
      
      --Busca modalidade e submodalidade concatenados da linha de credito
      CURSOR cr_craplcr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT nvl(cdmodali || cdsubmod, '0000') modalidade
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      --Busca numeracao unica de portabilidade
      CURSOR cr_tbepr_portabilidade (pr_cdcooper IN crapcob.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT nrunico_portabilidade nrunicop
              ,nrcontrato_if_origem  nrorigem
              ,nrcnpjbase_if_origem  cnpjorig
          FROM tbepr_portabilidade
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_tbepr_portabilidade cr_tbepr_portabilidade%ROWTYPE;
      
      --Busca cpf/cnpj do associado
      CURSOR cr_crapass (pr_cdcooper IN crapcob.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT nrcpfcgc
              ,nmprimtl
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
               
    BEGIN
      
      
      CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                     ,pr_cdcooper => vr_cdcooper
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_nmeacao  => vr_nmeacao
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
      /*
      vr_cdcooper := 7;
      vr_cdagenci := 0;
      vr_nrdcaixa := 0;
      vr_idorigem := 5;
      vr_cdoperad := 1;
      */
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcop;
        -- Gerar exceção
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Verifica se o banco esta cadastrado
      OPEN cr_crapban(pr_cdbccxlt => 85); -- CECRED
      FETCH cr_crapban INTO rw_crapban;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapban%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapban;
        -- Gerar exceção
        vr_cdcritic := 57;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapban;
      END IF;
      
      -- Busca o cpf/cnpj do cliente
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapass;
        vr_dscritic := 'Erro ao buscar o cpf/cnpj do cliente.';
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapass;
      END IF;
      
      -- Verifica se há numero unico de portabilidade
      OPEN cr_tbepr_portabilidade(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp); -- CECRED
      FETCH cr_tbepr_portabilidade INTO rw_tbepr_portabilidade;
      -- Encontrou portabilidade
      vr_hasfound := cr_tbepr_portabilidade%FOUND;      
      -- Fechar o cursor
      CLOSE cr_tbepr_portabilidade;
      
      -- Se for de portabilidade
      IF vr_hasfound  THEN
        
        -- Procura os dados da proposta
        OPEN cr_crawepr (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        FETCH cr_crawepr INTO rw_crawepr;         
        vr_hasfound := cr_crawepr%FOUND;
        CLOSE cr_crawepr;
            
        -- Se não encontrar a proposta.
        IF NOT vr_hasfound THEN
          vr_dscritic := 'Proposta nao encontrada.';
          RAISE vr_exc_saida;
        END IF;
        
        IF rw_crawepr.insitapr = 1 OR rw_crawepr.insitapr = 3 THEN
          
          -- Leitura do calendário da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_cdcritic:= 1;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
          END IF;
          
          --Acha modalidade da linha de credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                         ,pr_cdlcremp => rw_crawepr.cdlcremp);           
          FETCH cr_craplcr INTO rw_craplcr;
          CLOSE cr_craplcr;

          vr_modalidade := rw_craplcr.modalidade;
          
          IF vr_modalidade = '0000' THEN
            vr_dscritic := 'Linha de credito não encontrada!';
            RAISE vr_exc_saida;
          END IF;
          
          CASE vr_modalidade
          WHEN '0203' THEN
            vr_metodo := 'ConsultarDetalhePessoal';
          WHEN '0401' THEN
            vr_metodo := 'ConsultarDetalheVeicular';
          END CASE;
          
          pc_consultar_detalhe(pr_cdcooper => pr_cdcooper
                              ,pr_cdlegado => rw_crapcop.cdagectl 
                              ,pr_nrispbif => rw_crapban.nrispbif
                              ,pr_idparadm => rw_crapcop.cnpjbase
                              ,pr_ispbifcr => SUBSTR(LPAD(rw_tbepr_portabilidade.cnpjorig,14,0),1,8)
                              ,pr_nrunipor => rw_tbepr_portabilidade.nrunicop
                              ,pr_cdconori => rw_tbepr_portabilidade.nrorigem
                              ,pr_tpcontra => vr_modalidade
                              ,pr_tpclient => 'F'
                              ,pr_cnpjcpf  => to_char(lpad(rw_crapass.nrcpfcgc, 11, '0'))
                              ,pr_metodo   => vr_metodo
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_xml_res  => vr_xml_res 
                              ,pr_des_erro => pr_des_erro);
           
          IF pr_des_erro = 'NOK' THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Verifica se ocorreu retorno com erro no XML
          pc_obtem_fault_packet(pr_xml      => vr_xml_res
                               ,pr_dsderror => ''
                               ,pr_des_erro => pr_des_erro
                               ,pr_dscritic => vr_dscritic);
          
          -- Verifica o retorno de erro
          IF pr_des_erro = 'NOK' THEN
            RAISE vr_exc_saida;
          ELSE
            
              -- Verificar se existe a TAG PortIddAprovd
              gene0007.pc_lista_nodo(pr_xml      => vr_xml_res
                                    ,pr_nodo     => 'PortlddAprovd'
                                    ,pr_cont     => vr_nodecount
                                    ,pr_des_erro => vr_dscritic);

              -- Verifica se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_saida;
              END IF;

              -- Se existir
              IF vr_nodecount > 0 THEN
                
                -- Converte xml pra DOM
                vr_domDoc := DBMS_XMLDOM.newDOMDocument(vr_xml_res);
              
                --Buscar Nodo Corrente
                vr_PortIddAprovd := xmldom.item(xmldom.getElementsByTagName(vr_domDoc,'PortlddAprovd'),0);
                
                -- Pega os filhos
                gene0007.pc_itera_nodos(pr_nodo       => vr_PortIddAprovd --> Xpath do nodo a ser pesquisado
                                      , pr_nivel      => 1                --> Nível que será pesquisado
                                      , pr_list_nodos => vr_filhos        --> PL Table com os nodos resgatados
                                      , pr_des_erro   => vr_des_erro);    --> Descricao do erro                
                  
                vr_qtd_parc_vencr := vr_filhos(1)('QtdTotParclContrtoVencr');
                vr_dt_ven_ult_par := vr_filhos(1)('DtVencUltParclContrto');
                vr_vlr_sald_devdr := vr_filhos(1)('VlrSaldDevdrContb');
                
              END IF;

              -- Se não existir
              IF vr_nodecount = 0 THEN
              
                -- Verificar se existe a TAG PortIddRecsd
                gene0007.pc_lista_nodo(pr_xml      => vr_xml_res
                                      ,pr_nodo     => 'PortlddRecsd'
                                      ,pr_cont     => vr_nodecount
                                      ,pr_des_erro => vr_dscritic);

                -- Verifica se retornou erro
                IF vr_dscritic IS NOT NULL THEN
                  pr_dscritic := 'Portabilidade recusada pela IF Credora ou rejeitada pela CIP';
                RAISE vr_exc_saida;
              END IF;
           
                IF vr_nodecount > 0 THEN
                  pr_dscritic := 'Portabilidade recusada pela IF Credora ou rejeitada pela CIP';
                  RAISE vr_exc_saida;                 
            ELSE
                  pr_dscritic := 'Solicitacao de Portabilidade em andamento. Aguardando retorno dos dados atualizados da IF Credora';
              RAISE vr_exc_saida;
            END IF;
              END IF;
            -- Valida se os dados conferem com os dados retornados do JDCTC
            IF to_char(rw_crawepr.qtpreemp) <> vr_qtd_parc_vencr OR
               to_char(rw_crawepr.vlemprst) <> vr_vlr_sald_devdr OR
               to_char(rw_crawepr.dtultven,'RRRR-MM-DD') <> vr_dt_ven_ult_par THEN
              vr_confere_dados := 'N';
            END IF;
          END IF;
          
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
          gene0007.pc_insere_tag(pr_xml => pr_retxml
                                ,pr_tag_pai => 'Dados'
                                ,pr_posicao => 0
                                ,pr_tag_nova => 'ConfereDados'
                                ,pr_tag_cont => vr_confere_dados
                                ,pr_des_erro => vr_dscritic);
        END IF;
      END IF;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Dados'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'ConfereDados'
                            ,pr_tag_cont => vr_confere_dados
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;        

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro Geral em Consulta de Portabilidade: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;     
        
    END;

  END pc_verifica_dados_JDCTC_prt;
  /* verifica se pode imprimir a declaração de isenção de IOF */
  PROCEDURE pc_pode_impr_dec_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
										,pr_nrdconta IN crapcop.nrdconta%TYPE --> Numero da Conta
										,pr_nrctrato IN crawepr.nrctremp%TYPE --> Numero de Emprestimo
										,pr_xmllog   IN VARCHAR2 --> XML com informac?es de LOG
										,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
										,pr_dscritic OUT VARCHAR2 --> Descricao da critica
										,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
										,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
										,pr_des_erro OUT VARCHAR2) IS --> Erros do processo		
	BEGIN		
		/* .............................................................................        
        Programa: pc_pode_impr_dec_isencao_iof
        Sistema : AYLLOS
        Sigla   : EMPR
        Autor   : Diogo (MoutS)
        Data    : Outubro/17.                    Ultima atualizacao: 11/10/2017
        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina de verificacao de pode imprimir a DECLARAÇÃO DE UTILIZAÇÃO DE RECURSOS PARA ISENÇAO DE IOF
        Observacao: -----
        Alteracoes: 14/06/2018 - P410 - Ajustes IOF - Marcos (Envolti)
        ..............................................................................*/
	DECLARE				
		--Variaveis
		vr_des_reto VARCHAR2(1);
		vr_err_efet INTEGER;
		-- Variável de críticas
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(10000);
		
		-- Tratamento de erros
		vr_exc_saida EXCEPTION;
		CURSOR cr_pode_imprimir IS
			SELECT crawepr.nrctremp
			FROM crawepr
            ,craplcr 
            ,crapbpr 
            ,crapass 
       WHERE crapass.nrdconta = crawepr.nrdconta 
         AND crapass.cdcooper = crawepr.cdcooper
         
         AND CRAPLCR.CDLCREMP = crawepr.cdlcremp 
         AND craplcr.cdcooper = crawepr.cdcooper
         
         AND CRAPBPR.nrdconta = crawepr.nrdconta 
         AND CRAPBPR.cdcooper = crawepr.cdcooper 
         AND CRAPBPR.nrctrpro = crawepr.nrctremp
         
         -- FIltros
         AND crawepr.cdcooper = pr_cdcooper
				AND crawepr.nrdconta = pr_nrdconta
				AND crawepr.nrctremp = pr_nrctrato
                AND crapass.inpessoa = 1 --somente PF
				 AND upper(CRAPBPR.dscatbem) IN ('APARTAMENTO', 'CASA')
         AND craplcr.cdsubmod = '02'; -- Submodalidade Bacen = 02 Aquisições de Bens outros bens
		rw_pode_imprimir cr_pode_imprimir%ROWTYPE;
    
		BEGIN
			--Consulta
			OPEN cr_pode_imprimir;
			FETCH cr_pode_imprimir INTO rw_pode_imprimir;
			IF cr_pode_imprimir%FOUND THEN
				vr_des_reto := 'S';
			ELSE
				vr_des_reto := 'N';
			END IF;
			CLOSE cr_pode_imprimir;
      
			-- Criar cabeçalho do XML
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
			gene0007.pc_insere_tag(pr_xml      => pr_retxml,
								   pr_tag_pai  => 'Dados',
								   pr_posicao  => 0,
								   pr_tag_nova => 'ConfereDados',
								   pr_tag_cont => vr_des_reto,
								   pr_des_erro => vr_dscritic);
		EXCEPTION
			WHEN vr_exc_saida THEN
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := gene0007.fn_caract_acento(gene0007.fn_convert_web_db(vr_dscritic));
				pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
			WHEN OTHERS THEN
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro Geral em Consulta de Declaração de Isenção de IOF: ' || SQLERRM;
				pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
  END pc_pode_impr_dec_isencao_iof;
  
END EMPR0006;
/
