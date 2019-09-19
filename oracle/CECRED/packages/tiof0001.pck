CREATE OR REPLACE PACKAGE CECRED.TIOF0001 IS
  /*---------------------------------------------------------------------------------------------------------------
    Programa : TIOF0001
    Sistema  : Rotinas para calcular o valor do IOF
    Sigla    : GENE
    Autor    : James Prust Junior
    Data     : Novembro/2017.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para calcular valor de IOF
  
   Observacoes: 
                
   Alterações:   
  ---------------------------------------------------------------------------------------------------------------*/
  TYPE typ_tab_taxas_iof IS
    TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;  
  
  -- Vetor para armazenamento
  vr_tab_taxas_iof typ_tab_taxas_iof;  
  
  PROCEDURE pc_calcula_valor_iof(pr_tpproduto            IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                ,pr_tpoperacao           IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                ,pr_vltaxa_iof_atraso    IN  NUMBER DEFAULT 0      --> Valor da Taxa do IOF em Atraso
                                ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                ,pr_vliofcpl             OUT NUMBER                --> Retorno do valor do IOF complementar
                                ,pr_vltaxa_iof_principal OUT NUMBER                --> Valor da Taxa do IOF Principal
                                ,pr_flgimune             OUT PLS_INTEGER           --> Possui imunidade tributária
                                ,pr_dscritic             OUT crapcri.dscritic%TYPE); --> Descricao da Critica);
  
  PROCEDURE pc_calcula_valor_iof_prg(pr_tpproduto            IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                    ,pr_tpoperacao           IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                    ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                    ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                    ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                    ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                    ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                    ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                    ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                    ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                    ,pr_vltaxa_iof_atraso    IN  VARCHAR2              --> Valor da Taxa do IOF em Atraso
                                    ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                    ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                    ,pr_vliofcpl             OUT NUMBER                --> Retorno do valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT VARCHAR2              --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune             OUT PLS_INTEGER           --> Possui imunidade tributária (1 - Sim / 0 - Não)
                                    ,pr_dscritic             OUT crapcri.dscritic%TYPE); --> Descricao da Critica                              
                        
						                                                                 
  PROCEDURE pc_calcula_valor_iof_epr(pr_tpoperac IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso, 3-> Todos)
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                    ,pr_vltotope in number DEFAULT 0      --> Valor total da operacao
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                    ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo      
                                    ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                    ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                    ,pr_vliofpri OUT NUMBER               --> Valor do IOF principal
                                    ,pr_vliofadi OUT NUMBER               --> Valor do IOF adicional
                                    ,pr_vliofcpl OUT NUMBER               --> Valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune OUT PLS_INTEGER          --> Possui imunidade tributária
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                                    
  -- Verificar a isenção de IOF                                    
  PROCEDURE pc_verifica_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                   ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                   ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                   ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo                                                                       
                                   ,pr_idisepri OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_idiseadi OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_idisecpl OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                                    
  -- Verificar e calcular insecao de IOF
  PROCEDURE pc_calcula_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo                                                                        
                                  ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo                                                                        
                                    ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                    ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                    ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                                
    -- Busca da taxa do IOF
  PROCEDURE pc_busca_taxa_iof(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                             ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                             ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                             ,pr_cdlcremp     IN crawepr.cdlcremp%type                 --> Linha de crédito do empréstimo
                             ,pr_cdfinemp     IN crawepr.cdfinemp%TYPE                 --> Finalidade do empréstimo
                             ,pr_vlemprst     IN crapepr.vlemprst%TYPE                 --> Valor do empréstimo
                             ,pr_vltxiofpri   OUT NUMBER                   --> Taxa de IOF principal
                             ,pr_vltxiofadc   OUT NUMBER                   --> Taxa de IOF adicional
                             ,pr_vltxiofcpl   out number                   --> Taxa de IOF Complementar por atraso
                             ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                             ,pr_dscritic     OUT VARCHAR2);               --> Descrição da Crítica

  -- Busca da taxa do IOF pelo Progress                        
  PROCEDURE pc_busca_taxa_iof_prg(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                                 ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                                 ,pr_cdlcremp     IN crawepr.cdlcremp%type                 --> Linha de Crédito do emprestimo  
                                 ,pr_cdfinemp     IN crawepr.cdfinemp%type                 --> Finalidade do emprestimo  
                                 ,pr_vlemprst     IN crapepr.vlemprst%TYPE                 --> valor do Empréstimo
                                 ,pr_vltxiofpri   OUT VARCHAR2                   --> Taxa de IOF principal
                                 ,pr_vltxiofadc   OUT VARCHAR2                   --> Taxa de IOF adicional
                                 ,pr_vltxiofcpl   out number                   --> Taxa de IOF Complementar por atraso
                                 ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                                 ,pr_dscritic     OUT VARCHAR2);            --> Descrição da Crítica
                          
  PROCEDURE pc_carrega_taxas_iof(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data de movimento
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Descricao da Critica
  
  PROCEDURE pc_calcula_iof_pos_fixado(pr_cdcooper        IN crapcop.cdcooper%TYPE      --> Codigo da Cooperativa
                                     ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Conta do associado
                                     ,pr_nrctremp        IN crapepr.nrctremp%TYPE DEFAULT null                                      
                                     ,pr_dtcalcul        IN crapdat.dtmvtolt%TYPE      --> Data de Calculo
                                     ,pr_cdlcremp        IN crapepr.cdlcremp%TYPE      --> Codigo da linha de credito
                                     ,pr_cdfinemp        IN crapepr.cdfinemp%TYPE      --> Finalidade
                                     ,pr_vlemprst        IN crapepr.vlemprst%TYPE      --> Valor do emprestimo
                                     ,pr_qtpreemp        IN crapepr.qtpreemp%TYPE      --> Quantidade de parcelas
                                     ,pr_dtdpagto        IN crapepr.dtdpagto%TYPE      --> Data do pagamento
                                     ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      --> Data da Carencia
                                     ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                     ,pr_taxaiof         IN NUMBER                     --> Valor da taxa do IOF principal
                                     ,pr_taxaiofadi      IN NUMBER                     --> Valor da taxa do IOF adicional
                                     ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL      --> Bens em garantia (separados por "|")
                                     ,pr_vltariof        OUT NUMBER                    --> Valor de IOF principal
                                     ,pr_vltariofadi     OUT NUMBER                    --> valor do IOF Adicional
                                     ,pr_tab_parcelas    OUT empr0011.typ_tab_parcelas --> Parcelas do Emprestimo
                                     ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic        OUT crapcri.dscritic%TYPE);
                                
  /* Efetuar calculo do IOF de Empréstimo */                                     
  PROCEDURE pc_calcula_iof_epr(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                              ,pr_nrctremp  IN crapepr.nrctremp%TYPE DEFAULT null
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                              ,pr_inpessoa  IN crapass.inpessoa%TYPE
                              ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                              ,pr_cdfinemp  IN crapepr.cdfinemp%TYPE
                              ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE
                              ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE
                              ,pr_vlemprst  IN crapepr.vlemprst%TYPE
                              ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE
                              ,pr_dtlibera  IN crawepr.dtlibera%TYPE
                              ,pr_tpemprst  IN crawepr.tpemprst%TYPE
                              ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE
                              ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE
                              ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL            -- Bens em garantia (separados por "|")
                              ,pr_idfiniof        IN crapepr.idfiniof%TYPE DEFAULT 1  -- Indicador se financia IOF e tarifa
                              ,pr_dsctrliq        IN VARCHAR2 DEFAULT NULL            -- Lista de contratos a liquidar (Não necessário se passar pr_nrctremp)
                              ,pr_idgravar        IN VARCHAR2 DEFAULT 'N'             -- Indicador para gravação do IOF calculado na tabela de Parcelas
                              ,pr_vlpreclc       OUT craplcm.vllanmto%TYPE -- Valor calculado da parcela
                              ,pr_valoriof       OUT craplcm.vllanmto%TYPE -- Valor calculado com o iof (principal + adicional)
                              ,pr_vliofpri       OUT craplcm.vllanmto%TYPE -- Valor calculado do iof principal
                              ,pr_vliofadi       OUT craplcm.vllanmto%TYPE -- Valor calculado do iof adicional
                              ,pr_flgimune       OUT PLS_INTEGER
                              ,pr_dscritic OUT VARCHAR2);          --> Descricão da critica
                              
  /* Interface para chamada via AyllosWeb da pc_calcula_iof_epr */
  PROCEDURE pc_calcula_iof_epr_web(pr_cdcooper        IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE DEFAULT null
                                  ,pr_dtmvtolt        IN VARCHAR2
                                  ,pr_inpessoa        IN crapass.inpessoa%TYPE
                                  ,pr_cdlcremp        IN crapepr.cdlcremp%TYPE
                                  ,pr_cdfinemp        IN crapepr.cdfinemp%TYPE
                                  ,pr_qtpreemp        IN crapepr.qtpreemp%TYPE
                                  ,pr_vlpreemp        IN crapepr.vlpreemp%TYPE
                                  ,pr_vlemprst        IN crapepr.vlemprst%TYPE
                                  ,pr_dtdpagto        IN VARCHAR2
                                  ,pr_dtlibera        IN VARCHAR2
                                  ,pr_tpemprst        IN crawepr.tpemprst%TYPE
                                  ,pr_dtcarenc        IN VARCHAR2
                                  ,pr_idcarencia      IN crawepr.idcarenc%TYPE
                                  ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL            -- Bens em garantia (separados por "|")
                                  ,pr_idfiniof        IN crapepr.idfiniof%TYPE DEFAULT 1  -- Indicador se financia IOF e tarifa
                                  ,pr_dsctrliq        IN VARCHAR2 DEFAULT NULL
                                  ,pr_idgravar        IN VARCHAR2 DEFAULT 'N'             -- Indicador S/N para gravação do IOF calculado na tabela de Parcelas
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo                             
                                                                     
  
  /* Gravação do IOF lançado em tabela */
  PROCEDURE pc_insere_iof (pr_cdcooper	     IN tbgen_iof_lancamento.cdcooper%TYPE                    --> Codigo da Cooperativa 
                          ,pr_nrdconta       IN tbgen_iof_lancamento.nrdconta%TYPE                    --> Numero da Conta Corrente
                          ,pr_dtmvtolt       IN tbgen_iof_lancamento.dtmvtolt%TYPE                    --> Data de Movimento
                          ,pr_tpproduto      IN tbgen_iof_lancamento.tpproduto%TYPE                   --> Tipo de Produto
                          ,pr_nrcontrato     IN tbgen_iof_lancamento.nrcontrato%TYPE                  --> Numero do Contrato
                          ,pr_idlautom       IN tbgen_iof_lancamento.idlautom%TYPE     DEFAULT NULL   --> Chave: Id dos Lancamentos Futuros
                          ,pr_dtmvtolt_lcm   IN tbgen_iof_lancamento.dtmvtolt_lcm%TYPE DEFAULT NULL   --> Chave: Data de Movimento Lancamento
                          ,pr_cdagenci_lcm   IN tbgen_iof_lancamento.cdagenci_lcm%TYPE DEFAULT NULL   --> Chave: Agencia do Lancamento
                          ,pr_cdbccxlt_lcm   IN tbgen_iof_lancamento.cdbccxlt_lcm%TYPE DEFAULT NULL   --> Chave: Caixa do Lancamento
                          ,pr_nrdolote_lcm   IN tbgen_iof_lancamento.nrdolote_lcm%TYPE DEFAULT NULL   --> Chave: Lote do Lancamento
                          ,pr_nrseqdig_lcm   IN tbgen_iof_lancamento.nrseqdig_lcm%TYPE DEFAULT NULL   --> Chave: Sequencia do Lancamento
                          ,pr_vliofpri       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Principal
                          ,pr_vliofadi       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Adicional
                          ,pr_vliofcpl       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Complementar
                          ,pr_flgimune       IN PLS_INTEGER                                           --> Possui imunidade tributária (1 - Sim / 0 - Não)
                          ,pr_cdcritic       OUT NUMBER                                               --> Código da Crítica
                          ,pr_dscritic       OUT VARCHAR2);
                          
  /* Alteração do IOF lançado em tabela */
  PROCEDURE pc_altera_iof (pr_cdcooper	     IN tbgen_iof_lancamento.cdcooper%TYPE                  --> Codigo da Cooperativa 
                          ,pr_nrdconta       IN tbgen_iof_lancamento.nrdconta%TYPE                  --> Numero da Conta Corrente
                          ,pr_dtmvtolt       IN tbgen_iof_lancamento.dtmvtolt%TYPE                  --> Data de Movimento
                          ,pr_tpproduto      IN tbgen_iof_lancamento.tpproduto%TYPE                 --> Tipo de Produto
                          ,pr_nrcontrato     IN tbgen_iof_lancamento.nrcontrato%TYPE                --> Numero do Contrato
                          ,pr_idlautom       IN tbgen_iof_lancamento.idlautom%TYPE     DEFAULT NULL --> Chave: Id dos Lancamentos Futuros
                          ,pr_cdagenci_lcm   IN tbgen_iof_lancamento.cdagenci_lcm%TYPE DEFAULT NULL --> Chave: Agencia do Lancamento
                          ,pr_cdbccxlt_lcm   IN tbgen_iof_lancamento.cdbccxlt_lcm%TYPE DEFAULT NULL --> Chave: Caixa do Lancamento
                          ,pr_nrdolote_lcm   IN tbgen_iof_lancamento.nrdolote_lcm%TYPE DEFAULT NULL --> Chave: Lote do Lancamento
                          ,pr_nrseqdig_lcm   IN tbgen_iof_lancamento.nrseqdig_lcm%TYPE DEFAULT NULL --> Chave: Sequencia do Lancamento
                          ,pr_nracordo       IN tbgen_iof_lancamento.nracordo%TYPE DEFAULT NULL     --> Chave: nr acordo
                          ,pr_cdcritic       OUT NUMBER                                             --> Código da Crítica
                          ,pr_dscritic       OUT VARCHAR2);                          
  
  --Rotina chamada no processo de desfazer a efetivacao de uma proposta
  PROCEDURE pc_exclui_iof(pr_cdcooper IN  crapepr.cdcooper%TYPE    --> Cooperativa
                         ,pr_nrdconta IN  crapepr.nrdconta%TYPE    --> Numero da conta
                         ,pr_nrctremp IN  crapepr.nrctremp%TYPE    --> Numero do contrato
                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Codigo da critica
                         ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Descricao da critica

END TIOF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TIOF0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TIOF0001
  --  Sistema  : Rotinas para calcular o valor do IOF
  --  Sigla    : GENE
  --  Autor    : James Prust Junior
  --  Data     : Novembro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas auxiliares para buscas de informacões do negocio
  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;


  PROCEDURE pc_calcula_valor_iof(pr_tpproduto            IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                ,pr_tpoperacao           IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso, 3-> Todos)
                                ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                ,pr_vltaxa_iof_atraso    IN  NUMBER DEFAULT 0      --> Valor da Taxa do IOF em Atraso
                                ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                ,pr_vliofcpl             OUT NUMBER                --> Retorno do valor do IOF complementar
                                ,pr_vltaxa_iof_principal OUT NUMBER                --> Valor da Taxa do IOF Principal
                                ,pr_flgimune             OUT PLS_INTEGER           --> Possui imunidade tributária
                                ,pr_dscritic             OUT crapcri.dscritic%TYPE ) IS --> Descricao da Critica
  BEGIN
    /* ..........................................................................
		   Programa : pc_calcula_valor_iof
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Outubro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
			 Objetivo  :  Calcular o valor do IOF                   
			
       Alteracoes:  
				 .............................................................................*/
    DECLARE
      --  Variáveis gerais
      vr_vltaxa_iof_adicional tbgen_iof_taxa.vltaxa_iof%TYPE;
      vr_vltaxa_iof_principal tbgen_iof_taxa.vltaxa_iof%TYPE;
      vr_qtdiaiof             PLS_INTEGER;
      vr_flgimune             BOOLEAN;
      
      -- Variaveis de Excecao
      vr_dscritic             VARCHAR2(3000);
      vr_dsreturn             VARCHAR2(100);
      vr_exc_erro             EXCEPTION;
      vr_tab_erro             GENE0001.typ_tab_erro;              
    BEGIN
      pr_vliofpri := 0;
      pr_vliofadi := 0;
      pr_vliofcpl := 0;
         
      -- Carrega as taxas do IOF
      pc_carrega_taxas_iof(pr_dtmvtolt => pr_dtmvtolt
                          ,pr_dscritic => vr_dscritic);
      IF NVL(vr_dscritic,' ') <> ' ' THEN
        RAISE vr_exc_erro;
      END IF;
         
      -- Condicao para verificar se a quantidade de dias de calculo de iof é superior a 365 dias
      vr_qtdiaiof := pr_qtdiaiof;
      IF vr_qtdiaiof > 365 THEN
        vr_qtdiaiof := 365;
      END IF;
         
      ----------------------------------------------------------------------------------------------------------------------
      -- Tipo de taxa de IOF --> 1-Taxa para Simples Nacional
      --                         2-Taxa IOF Principal PF    
      --                         3-Taxa IOF Principal PJ
      --                      4-Taxa IOF Adicional)
      ----------------------------------------------------------------------------------------------------------------------
      -- Valor Taxa Adicional
      vr_vltaxa_iof_adicional := vr_tab_taxas_iof(4);
      -- Pessoa Fisica
      IF pr_inpessoa = 1 THEN
        vr_vltaxa_iof_principal := vr_tab_taxas_iof(2);
      ELSE-- Pessoa Juridica  
      -- Simples Nacional
        IF pr_tpregtrb = 1 AND pr_vltotalope <= 30000 THEN
          vr_vltaxa_iof_principal := vr_tab_taxas_iof(1);
        ELSE
          vr_vltaxa_iof_principal := vr_tab_taxas_iof(3);
        END IF;
        -- Se for pessoa jurídica Cooperativa, não cobra IOF
        IF pr_natjurid = 2143 THEN 
          vr_vltaxa_iof_principal := 0;
        END IF;
      END IF;
         
      ----------------------------------------------------------------------------------------------------------------------
      -- Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 
      --                  5-> Adiantamento Depositante)
      ----------------------------------------------------------------------------------------------------------------------
      IF pr_tpproduto IN (1,2,3,4,5) THEN
        -- Inclusao da Operacao
        IF pr_tpoperacao = 1 OR pr_tpoperacao = 3 THEN
          -- Cálculo do IOF principal
          pr_vliofpri := pr_vloperacao * vr_vltaxa_iof_principal * vr_qtdiaiof;
          -- Cálculo do IOF adicional
          pr_vliofadi := pr_vloperacao * vr_vltaxa_iof_adicional;        
        END IF;
        
        -- Pagamento em Atraso  
        IF pr_tpoperacao = 2 OR pr_tpoperacao = 3 THEN
          if pr_vltaxa_iof_atraso is null then
             pr_vliofcpl := 0;
          else
          IF NVL(pr_vltaxa_iof_atraso,0) > 0 THEN
          pr_vliofcpl := pr_vloperacao * NVL(pr_vltaxa_iof_atraso,0) * vr_qtdiaiof;
          ELSE
             pr_vliofcpl := pr_vloperacao * NVL(vr_vltaxa_iof_principal,0) * vr_qtdiaiof;
        END IF;  
      END IF;
        END IF;  
      END IF;
      
      -- Condicao para verificar a imunidade tributaria
      IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_flgrvvlr => FALSE
                                         ,pr_cdinsenc => 0
                                         ,pr_vlinsenc => 0
                                         ,pr_flgimune => vr_flgimune
                                         ,pr_dsreturn => vr_dsreturn
                                         ,pr_tab_erro => vr_tab_erro);
         
      -- Condicao para verificar se houve erro
      IF vr_dsreturn <> 'OK' THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic || ' - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Não foi possivel verificar a imunidade tributaria';
        END IF;
        RAISE vr_exc_erro;
      END IF;
      
      pr_flgimune := CASE WHEN vr_flgimune THEN 1 ELSE 0 END;

      IF pr_flgimune > 0 THEN
        vr_vltaxa_iof_principal := 0;
      END IF;
      
      -- Taxa do IOF Principal
      pr_vltaxa_iof_principal := NVL(vr_vltaxa_iof_principal,0);
      
      -- Devolver os valores já arredondando em duas casas decimais
      pr_vliofpri := round(pr_vliofpri,2);
      pr_vliofadi := round(pr_vliofadi,2); 
      pr_vliofcpl := round(pr_vliofcpl,2);
      

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao calcular IOF. Rotina TIOF0001.pc_calcula_valor_iof. '||sqlerrm;
    END;
  END pc_calcula_valor_iof;
  
  PROCEDURE pc_calcula_valor_iof_prg(pr_tpproduto            IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                    ,pr_tpoperacao           IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                    ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                    ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                    ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                    ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                    ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                    ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                    ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                    ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                    ,pr_vltaxa_iof_atraso    IN  VARCHAR2              --> Valor da Taxa do IOF em Atraso
                                    ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                    ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                    ,pr_vliofcpl             OUT NUMBER                --> Retorno do valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT VARCHAR2              --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune             OUT PLS_INTEGER           --> Possui imunidade tributária (1 - Sim / 0 - Não)
                                    ,pr_dscritic             OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
  BEGIN
    /* ..........................................................................
		   Programa : pc_calcula_valor_iof_prg
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Outubro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
			 Objetivo  :  Calcular o valor do IOF                   
			
       Alteracoes:  
				 .............................................................................*/
    DECLARE
      vr_vltaxa_iof_principal tbgen_iof_taxa.vltaxa_iof%TYPE;
      
    BEGIN
      -- Procedure para calcular o valor do IOF
      pc_calcula_valor_iof(pr_tpproduto            => pr_tpproduto
                          ,pr_tpoperacao           => pr_tpoperacao
                          ,pr_cdcooper             => pr_cdcooper
                          ,pr_nrdconta             => pr_nrdconta
                          ,pr_inpessoa             => pr_inpessoa
                          ,pr_natjurid             => pr_natjurid
                          ,pr_tpregtrb             => pr_tpregtrb
                          ,pr_dtmvtolt             => pr_dtmvtolt
                          ,pr_qtdiaiof             => pr_qtdiaiof
                          ,pr_vloperacao           => pr_vloperacao
                          ,pr_vltotalope           => pr_vltotalope
                          ,pr_vltaxa_iof_atraso    => TO_NUMBER(pr_vltaxa_iof_atraso)
                          ,pr_vliofpri             => pr_vliofpri
                          ,pr_vliofadi             => pr_vliofadi
                          ,pr_vliofcpl             => pr_vliofcpl
                          ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                          ,pr_flgimune             => pr_flgimune
                          ,pr_dscritic             => pr_dscritic);
                          
      pr_vltaxa_iof_principal := TO_CHAR(vr_vltaxa_iof_principal);
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao calcular IOF. Rotina TIOF0001.pc_calcula_valor_iof_prg. '||sqlerrm;
    END;
  END pc_calcula_valor_iof_prg;  
  
  PROCEDURE pc_calcula_valor_iof_epr(pr_tpoperac IN PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso, 3-> Todos)
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                    ,pr_vltotope in number DEFAULT 0      --> Valor total da operacao
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                    ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo      
                                    ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                    ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                    ,pr_vliofpri OUT NUMBER               --> Valor do IOF principal
                                    ,pr_vliofadi OUT NUMBER               --> Valor do IOF adicional
                                    ,pr_vliofcpl OUT NUMBER               --> Valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune OUT PLS_INTEGER          --> Possui imunidade tributária
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* ..........................................................................
		   Programa : pc_calcula_valor_iof_epr
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Dezembro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
			 Objetivo  :  Calcular o valor do IOF para empréstimos. Ao final, verificar as 
                    regras de isenção do empréstimo

       Alteracoes: 10/05/2018 - P410 - Ajustes no IOF - Marcos (Envolti) 
				 .............................................................................*/
    DECLARE
      vr_exc_erro EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_vltaxa_iof_atraso NUMBER := null;
      vr_vltotope          number;
      vr_qtdiaiof          NUMBER;
      vr_dtvencto          DATE;
      
      -- Cursor para dados da PF, PJ, PJ Cooperativa e regime tributário
      CURSOR cr_pessoa(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT a.inpessoa, NVL(j.natjurid,0) natjurid, NVL(j.tpregtrb,0) tpregtrb
         FROM crapass a
         LEFT JOIN crapjur j ON j.cdcooper = a.cdcooper AND j.nrdconta = a.nrdconta
         WHERE a.nrdconta = pr_nrdconta AND a.cdcooper = pr_cdcooper;
       rw_pessoa cr_pessoa%ROWTYPE; 
       
     CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
       SELECT t.vlaqiofc
              ,t.dtmvtolt
       FROM crapepr t
       WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.nrctremp = pr_nrctremp
             AND t.tpemprst IN(1, 2) 
             AND t.dtmvtolt >= TO_DATE('03/04/2017','dd/mm/yyyy'); 
             /*Para operações em atraso do produto Price Pré-fixado, deverá ser cobrado IOF complementar de atraso
             nas operações contratadas após o dia 03 de abril de 2017*/
     rw_crapepr cr_crapepr%ROWTYPE;
       
    BEGIN
      -- Inicializar retornos
      pr_vliofpri             := 0;
      pr_vliofadi             := 0;
      pr_vliofcpl             := 0;
      pr_vltaxa_iof_principal := 0;
      pr_flgimune             := 0;
      vr_qtdiaiof             := pr_qtdiaiof;
       
      -- Retornar tipo da pessoa
      OPEN cr_pessoa(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_pessoa INTO rw_pessoa;
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;
        vr_dscritic := 'Associado não localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_pessoa;
      
      -- Se foi enviado contrato, iremos buscar suas informações
      IF pr_nrctremp IS NOT NULL THEN
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
         FETCH cr_crapepr INTO rw_crapepr;
         IF cr_crapepr%FOUND THEN
            vr_vltaxa_iof_atraso := rw_crapepr.vlaqiofc;
         END IF;
         CLOSE cr_crapepr;  
      END IF;
      
      IF pr_vltotope = 0 then
         vr_vltotope := pr_vlemprst;
      ELSE
         vr_vltotope := pr_vltotope;
      END IF;
      
      -- Para pagamento em atraso
      IF pr_tpoperac = 2 AND vr_qtdiaiof > 0 THEN 
        -- Calcular data do vencimento (Diminuimos data pagamento - dias em atraso pra chegar no dia do vencimento)
        vr_dtvencto := pr_dtmvtolt - vr_qtdiaiof;
        -- Regra 01 - Pagamentos superiores a 365 dias da contratação
        IF (pr_dtmvtolt - rw_crapepr.dtmvtolt ) >= 365 THEN 
          -- Descontamos os dios de IOF já cobrados na liberação
          vr_qtdiaiof := 365 - (vr_dtvencto - rw_crapepr.dtmvtolt);
        ELSE -- Regra 02 - PAgamentos entre 365 dias da contratação
          -- Diferença entre a data do pagamento e o vencimento
          vr_qtdiaiof := pr_dtmvtolt - vr_dtvencto;
        END IF;
        -- Garantir que a quantidade de dias não fique negativa
        vr_qtdiaiof := greatest(vr_qtdiaiof,0);
      END IF;
      
      -- Procedure para calcular o valor do IOF
      pc_calcula_valor_iof(pr_tpproduto            => 1 --> 1 - Emprestimo
                          ,pr_tpoperacao           => pr_tpoperac
                          ,pr_cdcooper             => pr_cdcooper
                          ,pr_nrdconta             => pr_nrdconta
                          ,pr_inpessoa             => rw_pessoa.inpessoa
                          ,pr_natjurid             => rw_pessoa.natjurid
                          ,pr_tpregtrb             => rw_pessoa.tpregtrb
                          ,pr_dtmvtolt             => pr_dtmvtolt
                          ,pr_qtdiaiof             => vr_qtdiaiof
                          ,pr_vloperacao           => pr_vlemprst
                          ,pr_vltotalope           => vr_vltotope
                          ,pr_vltaxa_iof_atraso    => vr_vltaxa_iof_atraso
                          ,pr_vliofpri             => pr_vliofpri
                          ,pr_vliofadi             => pr_vliofadi
                          ,pr_vliofcpl             => pr_vliofcpl
                          ,pr_vltaxa_iof_principal => pr_vltaxa_iof_principal
                          ,pr_dscritic             => vr_dscritic
                          ,pr_flgimune             => pr_flgimune);
                          
        IF NVL(vr_dscritic, ' ') <> ' ' THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Não calcular IOF em atraso para contratos com data anterior a 04/04/2017
      IF rw_crapepr.dtmvtolt < TO_DATE('04/04/2017','dd/mm/yyyy') THEN
          pr_vliofcpl := 0;
        END IF;
        
        
      -- Checar isenção de IOF
      pc_Calcula_isencao_iof(pr_cdcooper => pr_cdcooper --> Código da cooperativa referente ao contrato de empréstimos
                                 ,pr_nrdconta => pr_nrdconta --> Número da conta referente ao empréstimo
                                 ,pr_dscatbem => pr_dscatbem --> Descrição da categoria do bem, valor default NULO 
                                 ,pr_cdlcremp => pr_cdlcremp --> Linha de crédito do empréstimo                                                                        
                            ,pr_cdfinemp => pr_cdfinemp --> Finalidade
                                 ,pr_vliofpri => pr_vliofpri --> Valor do IOF principal
                                 ,pr_vliofadi => pr_vliofadi --> Valor do IOF adicional
                                 ,pr_vliofcpl => pr_vliofcpl --> Valor do IOF complementar
                                 ,pr_dscritic => vr_dscritic); --> Descrição da crítica
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
        END IF;
         
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
        pr_dscritic := 'Erro ao calcular IOF-EPR. Rotina TIOF0001.pc_calcula_valor_iof_epr. '||sqlerrm;
    END;
      
  END pc_calcula_valor_iof_epr;
    

  -- Verificar a isenção de IOF                                      
  PROCEDURE pc_verifica_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                   ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                   ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo                                                                        
                                   ,pr_cdfinemp IN NUMBER                --> Finalidade do Empréstimo
                                   ,pr_idisepri OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_idiseadi OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_idisecpl OUT NUMBER               --> Id 0/1 - Isento / Não Isento
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
     /* ..........................................................................
		   Programa : pc_verifica_isencao_iof
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Dezembro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
		 Objetivo  :  Verificar insenção do IOF e devolver ID para aplicação nos valores 
                 
                 Regras:
                   1 - Aquisição de motos/motonetas/motocicletas por PF E SUbmodalidade Bacen = 01 Aquisições de Bens Veículos Automotores.
                         valor do IOF principal assumirá zero
                         valor do IOF adicional deve ser calculado 
                         valor do IOF complementar de atraso assumirá zero
                         
                   2 - Habitação (casa ou apartamento) por PF e Submodalidade Bacen = 02 Aquisições de Bens outros bens
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso assumirá zero
                         
                    3 - Linha de crédito isenta de IOF
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso assumirá zero
                         
                   3.1 - Caso a linha de crédito for 800, 850 e 900 ou Cessão de Crédito
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso deverá ser calculado
                         
                   4 - Portabilidade não cobrará IOF
                        valor do IOF principal assumirá zero
                        valor do IOF adicional assumirá zero
                        valor do IOF complementar de atraso deverá ser calculado
			
       Alteracoes:  
			.............................................................................*/
         
    DECLARE
      -- Checagem do tipo da pessoa   
       CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT inpessoa
         FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta;
         rw_crapass cr_crapass%ROWTYPE;
         
      -- Cursor da linha de crédito do empréstimo
      CURSOR cr_craplcr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT lcr.tpctrato
              ,lcr.flgtaiof
              ,lcr.cdsubmod
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper 
           AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
    BEGIN
      -- Default é cobrar
      pr_idisepri := 1;  
      pr_idiseadi := 1;
      pr_idisecpl := 1;
         
      -- Retornar tipo da pessoa
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;
      
      -- Checar linha de crédito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper, pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;
         
      -- Somente para PF
      IF rw_crapass.inpessoa = 1 THEN
        -- 1 - Aquisição de motos/motonetas/motocicletas com SubModalidade Bacen = 01 Aquisições de Bens Veículos Automotores.
        IF rw_craplcr.cdsubmod = '01' AND UPPER(pr_dscatbem) like '%MOTO%' THEN
          pr_idisepri := 0;
          pr_idisecpl := 0;
        -- 2 - Habitação (casa ou apartamento) e submodalidade Bacen = 02 Aquisições de Bens outros bens
        ELSIF rw_craplcr.cdsubmod = '02' AND (UPPER(pr_dscatbem) like '%CASA%' OR UPPER(pr_dscatbem) like '%APARTAMENTO%') THEN
          pr_idisepri := 0;
          pr_idiseadi := 0;
          pr_idisecpl := 0;
      END IF;
      END IF;
         
      -- 3 - Linha de crédito isenta de IOF (flgtaiof = 0 ==> isentar cobrança de IOF)
      IF rw_craplcr.flgtaiof = 0 THEN
        pr_idisepri := 0;
        pr_idiseadi := 0;
        -- 3.1 - Não isentar cobrança de IOF por atraso
        --     - Caso a linha de crédito for 800, 850 e 900 
        --     - ou finalidade de cessão de crédito 
        IF pr_cdlcremp NOT IN (800,850,900) AND empr0001.fn_tipo_finalidade(pr_cdcooper,pr_cdfinemp) <> 1 THEN
           pr_idisecpl := 0;
         END IF;
      END IF;
             
      -- 4 -Portabilidade não cobrará IOF
      IF empr0001.fn_tipo_finalidade(pr_cdcooper,pr_cdfinemp) = 2 THEN
        -- Não haverá incidência IOF na contratação
        pr_idisepri := 0;
        pr_idiseadi := 0;
      END IF;
                   
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao verificar isenção de IOF. Rotina TIOF0001.pc_verifica_isencao_iof --> '||sqlerrm;
    END;
  END pc_verifica_isencao_iof;
                                    
  -- Verificar e calcular insecao de IOF
  PROCEDURE pc_calcula_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                  ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                  ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo                                                                        
                                  ,pr_cdfinemp IN NUMBER                --> Finalidade do empréstimo
                                  ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                  ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                  ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
                                  ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica    
  BEGIN
     /* ..........................................................................
       Programa : pc_calcula_isencao_iof
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Martini - Envolti
       Data    : Dezembro/2017                    Ultima atualizacao: 
    Dados referentes ao programa:
       Frequencia: Sempre que for solicitado
       Objetivo  :  Chamar rotina de insenção e aplicar sobre o valor passado

    Alteracoes:
         .............................................................................*/
	
    DECLARE
      -- IDs de aplicação de Isenção
      vr_idisepri PLS_INTEGER := 1;
      vr_idiseadi PLS_INTEGER := 1;
      vr_idisecpl PLS_INTEGER := 1;
      -- Tratamento de critica
      vr_dscritic VARCHAR2(4000);
    vr_exc_erro     EXCEPTION;

      BEGIN
    
      
      -- Acionar rotina de verificação de isenção
      pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_dscatbem => pr_dscatbem
                             ,pr_cdlcremp => pr_cdlcremp
                             ,pr_cdfinemp => pr_cdfinemp
                             ,pr_idisepri => vr_idisepri
                             ,pr_idiseadi => vr_idiseadi
                             ,pr_idisecpl => vr_idisecpl
                             ,pr_dscritic => vr_dscritic);
      -- Chechar erro 
      IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
    END IF;    
      -- Aplicar id de insenção (Quando é isento volta 0 e ai zera)
      pr_vliofpri := pr_vliofpri * vr_idisepri;
      pr_vliofadi := pr_vliofadi * vr_idiseadi;
      pr_vliofcpl := pr_vliofcpl * vr_idisecpl;  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;      
    WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao verificar calcular de IOF. Rotina TIOF0001.pc_calcula_isencao_iof --> '||sqlerrm;
      END;
  END pc_calcula_isencao_iof;
  
  -- Busca da taxa do IOF
  PROCEDURE pc_busca_taxa_iof(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                             ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                             ,pr_dtmvtolt     IN  crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                             ,pr_cdlcremp     IN crawepr.cdlcremp%type                 --> Linha de crédito do empréstimo
                             ,pr_cdfinemp     IN crawepr.cdfinemp%TYPE                 --> Finalidade do empréstimo
                             ,pr_vlemprst     IN crapepr.vlemprst%TYPE                 --> Valor do empréstimo
                             ,pr_vltxiofpri   OUT NUMBER                   --> Taxa de IOF principal
                             ,pr_vltxiofadc   OUT NUMBER                   --> Taxa de IOF adicional
                             ,pr_vltxiofcpl   out number                   --> Taxa de IOF Complementar por atraso
                             ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                             ,pr_dscritic     OUT VARCHAR2)  IS            --> Descrição da Crítica
  BEGIN
   /* .............................................................................
    Programa: pc_busca_taxa_iof
    Sistema : CRED
    Sigla   : TIOF
    Autor   : Diogo - MoutS
    Data    : Dezembro/2017.                    Ultima atualizacao: 10/05/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para retornar a taxa do IOF principal e adicional, 
                observando as regras para PF, PJ, PJ cooperativa e linha de 
                crédito do contrato

    Observacao: -----
    Alteracoes: 10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)
    ..............................................................................*/
    DECLARE
      -- Tratamento de erros
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(10000);
      vr_exc_erro EXCEPTION;
      vr_dtmvtolt DATE;
      vr_flgimuneB boolean;
      vr_dsreturn  varchar2(1000);
      vr_tab_erro  GENE0001.typ_tab_erro;
      vr_dscatbem  varchar2(1000);
      -- Cursores
      -- Cursor para buscar a data de movimento
      CURSOR cr_crapdat IS
        SELECT t.dtmvtolt
        FROM crapdat t
        WHERE t.cdcooper = pr_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;
      
      -- Cursor para buscar dados do associado PF / PJ
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT t.nrdconta, NVL(j.natjurid, 0) natjurid, NVL(j.tpregtrb,0) tpregtrb,
               t.inpessoa
        FROM crapass t
        LEFT JOIN crapjur j ON j.cdcooper = t.cdcooper AND j.nrdconta = t.nrdconta
        WHERE t.cdcooper = pr_cdcooper 
              AND t.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor para buscar dados dos bens do contrato
      CURSOR cr_crapbpr (pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE, pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT b.dscatbem
        FROM crapepr t
        INNER JOIN craplcr l ON l.cdlcremp = t.cdlcremp AND t.cdcooper = l.cdcooper
        INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
        WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp
              AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO');
      rw_crapbpr cr_crapbpr%ROWTYPE;
    
    BEGIN
      
      -- Busca dados do associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Associado não encontrado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      
      --Busca a data de movimento
      IF pr_dtmvtolt IS NULL THEN
        OPEN cr_crapdat;
        FETCH cr_crapdat INTO rw_crapdat;
        CLOSE cr_crapdat;
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtmvtolt := pr_dtmvtolt;
      END IF;
      
      -- Carrega as taxas do IOF
      pc_carrega_taxas_iof(pr_dtmvtolt => vr_dtmvtolt
                          ,pr_dscritic => vr_dscritic);
    
      ----------------------------------------------------------------------------------------------------------------------
      -- Tipo de taxa de IOF (1-Taxa para Simples Nacional/ 2-Taxa IOF Principal PF/ 3-Taxa IOF Principal PJ/ 
      --                      4-Taxa IOF Adicional)
      ----------------------------------------------------------------------------------------------------------------------
      -- Valor Taxa Adicional
      pr_vltxiofadc := vr_tab_taxas_iof(4);
      
      -- Pessoa Fisica
      IF rw_crapass.inpessoa = 1 THEN
        pr_vltxiofpri := vr_tab_taxas_iof(2);
      -- Pessoa Juridica  
      ELSE
      -- Simples Nacional
        IF rw_crapass.tpregtrb = 1 
        and nvl(pr_vlemprst,0) < 30000 THEN
          pr_vltxiofpri := vr_tab_taxas_iof(1);
        ELSE
          pr_vltxiofpri := vr_tab_taxas_iof(3);
        END IF;
           
        -- Se for pessoa jurídica Cooperativa, não cobra IOF
        IF rw_crapass.natjurid = 2143 THEN 
          pr_vltxiofpri := 0;
        END IF;
      END IF;
         
      if pr_cdlcremp in (800, 850, 900, 6901) then
         pr_vltxiofcpl := pr_vltxiofpri;  
      end if;
           
      vr_dscatbem := '';
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_nrctremp => pr_nrctremp) LOOP
          vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem || '|';
      END LOOP;

      -- Chamar rotina para checar isenção de IOF
      pc_calcula_isencao_iof(pr_cdcooper => pr_cdcooper           --> Código da cooperativa referente ao contrato de empréstimos
                               ,pr_nrdconta => pr_nrdconta           --> Número da conta referente ao empréstimo
                           ,pr_dscatbem => vr_dscatbem           --> Descrição da categoria do bem, valor default NULO 
                            ,pr_cdlcremp => pr_cdlcremp           --> Linha de crédito do empréstimo                                                                        
                            ,pr_cdfinemp => pr_cdfinemp           --> Finalidade do empréstimo
                               ,pr_vliofpri => pr_vltxiofpri         --> Valor do IOF principal
                               ,pr_vliofadi => pr_vltxiofadc         --> Valor do IOF adicional
                           ,pr_vliofcpl => pr_vltxiofcpl         --> Valor do IOF complementar
                               ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
         
      -- Se há IOF
      IF (pr_vltxiofpri + pr_vltxiofadc + pr_vltxiofcpl) <> 0 THEN
        -- Checar imunidade tributária
        imut0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                           ,pr_dtmvtolt => vr_dtmvtolt
                                           ,pr_flgrvvlr => FALSE
                                           ,pr_cdinsenc => 0
                                           ,pr_vlinsenc => 0
                                           ,pr_inpessoa => 0 
                                           ,pr_nrcpfcgc => 0 
                                           ,pr_flgimune => vr_flgimuneB
                                           ,pr_dsreturn => vr_dsreturn
                                           ,pr_tab_erro => vr_tab_erro);

        -- Condicao para verificar se houve erro
        IF vr_dsreturn <> 'OK' THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic || ' - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic := 'Não foi possivel verificar a imunidade tributaria';
          END IF;
          RAISE vr_exc_erro;
      END IF;
      end if;
      
      -- Caso imune
      if vr_flgimuneB then
         pr_vltxiofpri := 0;
         pr_vltxiofadc := 0;
      end if;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao buscar taxas do IOF. Rotina TIOF0001.pc_busca_taxa_iof --> ' || SQLERRM;
    END;
  END pc_busca_taxa_iof;
  
  -- Busca a taxa do IOF pelo Progress
  PROCEDURE pc_busca_taxa_iof_prg(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                                 ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                                 ,pr_cdlcremp     IN crawepr.cdlcremp%type                 --> Linha de Crédito do emprestimo  
                                 ,pr_cdfinemp     IN crawepr.cdfinemp%type                 --> Finalidade do emprestimo  
                                 ,pr_vlemprst     IN crapepr.vlemprst%TYPE                 --> valor do Empréstimo
                                 ,pr_vltxiofpri   OUT VARCHAR2                   --> Taxa de IOF principal
                                 ,pr_vltxiofadc   OUT VARCHAR2                   --> Taxa de IOF adicional
                                 ,pr_vltxiofcpl   out number                   --> Taxa de IOF Complementar por atraso
                                 ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                                 ,pr_dscritic     OUT VARCHAR2)  IS            --> Descrição da Crítica
  BEGIN
   /* .............................................................................
    Programa: pc_busca_taxa_iof_prg
    Sistema : CRED
    Sigla   : TIOF
    Autor   : Diogo - MoutS
    Data    : Dezembro/2017.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina chamar a TIOF0001 pelo Progress. Retorna os campos via VARCHAR pois o Progress nula
                valores com mais de 6 casas decimais

    Observacao: -----
    Alteracoes:
    ..............................................................................*/
    
    DECLARE
       vr_vltxiofpri NUMBER;
       vr_vltxiofadc NUMBER;
       vr_vltxiofcpl NUMBER;
    BEGIN
      -- Acionar calculo da taxa
       TIOF0001.pc_busca_taxa_iof(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdlcremp => pr_cdlcremp
                                ,pr_cdfinemp => pr_cdfinemp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_vltxiofpri => vr_vltxiofpri
                                 ,pr_vltxiofadc => vr_vltxiofadc
                                 ,pr_vltxiofcpl => vr_vltxiofcpl
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);
      -- Converter para texto
      pr_vltxiofpri := TO_CHAR(vr_vltxiofpri);
      pr_vltxiofadc := TO_CHAR(vr_vltxiofadc);
      pr_vltxiofcpl := to_char(vr_vltxiofcpl);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao buscar taxas do IOF. Rotina TIOF0001.pc_busca_taxa_iof_prg. ' || SQLERRM;
    END;
  END pc_busca_taxa_iof_prg;
  
  
  
  PROCEDURE pc_carrega_taxas_iof(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de movimento
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
    BEGIN
    /* ..........................................................................
		   Programa : pc_carrega_taxas_iof
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Dezembrp/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
			 Objetivo  :  Carregar as taxas de IOF na tabela temporária
       
       Alteracoes:  
				 .............................................................................*/
    DECLARE
      CURSOR cr_tabgen_iof(pr_dtmvtolt IN DATE) IS
        SELECT vltaxa_iof, 
               tpiof
          FROM tbgen_iof_taxa
         WHERE pr_dtmvtolt BETWEEN dtinicio_vigencia AND dtfinal_vigencia;
         
    BEGIN
      -- Condicao para verificar se a taxa jah foi carregada
      IF vr_tab_taxas_iof.COUNT = 0 THEN
        -- Buscar todas as taxas
        FOR rw_tabgen_iof IN cr_tabgen_iof (pr_dtmvtolt => pr_dtmvtolt) LOOP
          vr_tab_taxas_iof(rw_tabgen_iof.tpiof) := rw_tabgen_iof.vltaxa_iof;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
      pr_dscritic := 'Erro ao carregar taxas de IOF. Rotina TIOF0001.pc_carrega_taxas_iof. '||sqlerrm;
    END;
  END pc_carrega_taxas_iof;
      
  PROCEDURE pc_calcula_iof_pos_fixado(pr_cdcooper        IN crapcop.cdcooper%TYPE      --> Codigo da Cooperativa
                                     ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Conta do associado
                                     ,pr_nrctremp        IN crapepr.nrctremp%TYPE DEFAULT null                                      
                                     ,pr_dtcalcul        IN crapdat.dtmvtolt%TYPE      --> Data de Calculo
                                     ,pr_cdlcremp        IN crapepr.cdlcremp%TYPE      --> Codigo da linha de credito
                                     ,pr_cdfinemp        IN crapepr.cdfinemp%TYPE      --> Finalidade
                                     ,pr_vlemprst        IN crapepr.vlemprst%TYPE      --> Valor do emprestimo
                                     ,pr_qtpreemp        IN crapepr.qtpreemp%TYPE      --> Quantidade de parcelas
                                     ,pr_dtdpagto        IN crapepr.dtdpagto%TYPE      --> Data do pagamento
                                     ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      --> Data da Carencia
                                     ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
                                     ,pr_taxaiof         IN NUMBER                     --> Valor da taxa do IOF principal
                                     ,pr_taxaiofadi      IN NUMBER                     --> Valor da taxa do IOF adicional
                                     ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL      --> Bens em garantia (separados por "|")
                                     ,pr_vltariof        OUT NUMBER                    --> Valor de IOF principal
                                     ,pr_vltariofadi     OUT NUMBER                    --> valor do IOF Adicional                                     
                                     ,pr_tab_parcelas    OUT empr0011.typ_tab_parcelas --> Parcelas do Emprestimo
                                     ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_iof_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2017                         Ultima atualizacao: 10/05/2018 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o IOF para Pos-Fixado.

       Alteracoes: 10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)
    ............................................................................. */

    DECLARE
    
      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
              ,cddindex
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca os dados da taxa do CDI
      CURSOR cr_craptxi (pr_cddindex IN craptxi.cddindex%TYPE
                        ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS
        SELECT vlrdtaxa
          FROM craptxi
         WHERE cddindex = pr_cddindex
           AND dtiniper = pr_dtiniper;
      rw_craptxi cr_craptxi%ROWTYPE;
      
      rw_crapdat   btch0001.cr_crapdat%rowtype;
      -- Vetor para armazenamento
      vr_tab_total_juros     empr0011.typ_tab_total_juros;
      vr_tab_saldo_projetado empr0011.typ_tab_saldo_projetado;
          
      -- Variaveis Calculo da Parcela
      vr_dtmvtoan          DATE;
      vr_dtmvtolt          DATE;
      vr_datainicial       DATE;
      vr_datafinal         DATE;
      vr_dtultpag          DATE;
      vr_nrparepr          crappep.nrparepr%TYPE;
      vr_vlbase_iof        NUMBER(25,2) := 0;
      vr_qtdias_iof        PLS_INTEGER;      
      vr_vliofadi_acumulad number(25,8) := 0;
      
      -- Variaveis tratamento de erros
      vr_cdcritic          crapcri.cdcritic%TYPE;
      vr_dscritic          VARCHAR2(4000);
      vr_exc_erro          EXCEPTION;     
      
      -- Checagem isencao IOF
      vr_idisepri PLS_INTEGER := 1;
      vr_idiseadi PLS_INTEGER := 1;
      vr_idisecpl PLS_INTEGER := 1;
             

    BEGIN
      vr_tab_saldo_projetado.DELETE;
      vr_tab_total_juros.DELETE;
      
      -- Busca do Calendário
      open btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;
      
      vr_dtmvtolt := pr_dtcalcul;
      -- Função para retornar o dia anterior
      /*vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                                 pr_dtmvtolt  => vr_dtmvtolt - 1,   --> Data do movimento
                                                 pr_tipo      => 'A'); */
      -- ajustado devido a simulacao usar uma data futura, para isso deve respeitar sempre a data anterior atual
      vr_dtmvtoan := rw_crapdat.dtmvtoan;
                                                 
      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- se achou registro
      IF cr_craplcr%FOUND THEN
        CLOSE cr_craplcr;
      ELSE
        CLOSE cr_craplcr;
        -- Gerar erro
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;      
      
      -- Buscar a taxa acumulada do CDI
      OPEN cr_craptxi (pr_cddindex => rw_craplcr.cddindex
                      ,pr_dtiniper => vr_dtmvtoan);
      FETCH cr_craptxi INTO rw_craptxi;
      -- se achou registro
      IF cr_craptxi%FOUND THEN
        CLOSE cr_craptxi;
      ELSE
        CLOSE cr_craptxi;
        -- Gerar erro
        vr_dscritic := 'Taxa do CDI nao cadastrada. Data: ' || TO_CHAR(vr_dtmvtoan,'DD/MM/RRRR');
        RAISE vr_exc_erro;
      END IF;
    
      -- Checar isenção de IOF
      tiof0001.pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper   --> Código da cooperativa referente ao contrato de empréstimos
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta referente ao empréstimo
                                      ,pr_dscatbem => pr_dscatbem   --> Descrição da categoria do bem, valor default NULO
                                      ,pr_cdlcremp => pr_cdlcremp   --> Linha de crédito do empréstimo
                                      ,pr_cdfinemp => pr_cdfinemp   --> Finalidade Empréstimo
                                      ,pr_idisepri => vr_idisepri   --> Valor do IOF principal
                                      ,pr_idiseadi => vr_idiseadi   --> Valor do IOF adicional
                                      ,pr_idisecpl => vr_idisecpl   --> Valor do IOF complementar
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Procedure para calcular as Parcelas do Pos Fixado
      empr0011.pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                             ,pr_flgbatch        => FALSE
                                             ,pr_dtcalcul        => pr_dtcalcul
                                             ,pr_cdlcremp        => pr_cdlcremp
                                             ,pr_dtcarenc        => pr_dtcarenc
                                             ,pr_qtdias_carencia => pr_qtdias_carencia
                                             ,pr_dtdpagto        => pr_dtdpagto
                                             ,pr_qtpreemp        => pr_qtpreemp
                                             ,pr_vlemprst        => pr_vlemprst
                                             ,pr_tab_parcelas    => pr_tab_parcelas
                                             ,pr_cdcritic        => vr_cdcritic
                                             ,pr_dscritic        => vr_dscritic);
       
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Calcular o valor do IOF adicional
      pr_vltariofadi := ROUND(pr_vlemprst * pr_taxaiofadi,2);
      -- Aplicar multiplicadores de isenção
      pr_vltariofadi := pr_vltariofadi * vr_idiseadi;
      
      -- Condicao para verificar qual será a data final para fins de calculo (Data do Pagamento ou Ultimo dia do Mes)
      IF TO_NUMBER(TO_CHAR(pr_dtdpagto,'DD')) > TO_NUMBER(TO_CHAR(vr_dtmvtolt,'DD')) THEN
        vr_datafinal := TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||'/'||TO_CHAR(vr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
      ELSE
        vr_datafinal := LAST_DAY(vr_dtmvtolt);
      END IF;      
      
      -- Data Inicial será a data de efetivação do contrato
      vr_datainicial     := vr_dtmvtolt;
      vr_nrparepr        := 1;
      vr_dtultpag        := pr_tab_parcelas(pr_tab_parcelas.last).dtvencto;
      -- Loop para calcular o saldo devedor
      WHILE vr_datafinal <= vr_dtultpag LOOP
        -- Somente vamos calcular o Saldo Devedor Projetado caso nao for no periodo da carencia
        IF pr_tab_parcelas(vr_nrparepr).flcarenc = 0 THEN       
          -- Procedure para calcular o saldo projetado
          empr0011.pc_calcula_saldo_projetado(pr_cdcooper            => pr_cdcooper
                                             ,pr_flgbatch            => FALSE
                                             ,pr_dtefetiv            => pr_dtcalcul
                                             ,pr_datainicial         => vr_datainicial
                                             ,pr_datafinal           => vr_datafinal
                                             ,pr_nrparepr            => vr_nrparepr
                                             ,pr_dtvencto            => vr_datafinal
                                             ,pr_vlparepr_principal  => pr_tab_parcelas(vr_nrparepr).vlparepr
                                             ,pr_vlrdtaxa            => rw_craptxi.vlrdtaxa
                                             ,pr_dtdpagto            => pr_dtdpagto
                                             ,pr_txmensal            => rw_craplcr.txmensal
                                             ,pr_vlsprojt            => pr_vlemprst
                                             ,pr_tab_saldo_projetado => vr_tab_saldo_projetado
                                             ,pr_tab_total_juros     => vr_tab_total_juros
                                             ,pr_cdcritic            => vr_cdcritic
                                             ,pr_dscritic            => vr_dscritic);
                                            
          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
  
        -- Caso for no dia do vencimento da parcela iremos avancar para a proxima parcela
        IF pr_tab_parcelas(vr_nrparepr).dtvencto = vr_datafinal THEN
          -- Condicao para verificar se a parcela eh do Juros da Carencia
          IF pr_tab_parcelas(vr_nrparepr).flcarenc = 0 THEN
            -- Valor Base do IOF
            vr_vlbase_iof := pr_tab_parcelas(vr_nrparepr).vlparepr - vr_tab_total_juros(vr_nrparepr).valor_total_juros;
            IF vr_vlbase_iof < 0 THEN
              vr_vlbase_iof := 0;
            END IF;
            
            -- Quantidade de Dias do IOF
            vr_qtdias_iof := pr_tab_parcelas(vr_nrparepr).dtvencto - vr_dtmvtolt;
            IF vr_qtdias_iof > 365 THEN
              vr_qtdias_iof := 365;
            END IF;
            
            -- Valor do IOF principal (jah aplicando multiplicador de isenção)
            pr_tab_parcelas(vr_nrparepr).vliofpri := round((vr_vlbase_iof * vr_qtdias_iof * pr_taxaiof),2) * vr_idisepri;
            -- Acumular total
            pr_vltariof   := ROUND(NVL(pr_vltariof,0) + pr_tab_parcelas(vr_nrparepr).vliofpri,2);
            
            -- Na ultima parcela apenas utiliza a sobra do IOF Adicional, para evitar problemas de arredondamento
            IF vr_nrparepr = pr_tab_parcelas.count() THEN
              -- Calcular a sobra
              pr_tab_parcelas(vr_nrparepr).vliofadc := pr_vltariofadi - vr_vliofadi_acumulad;
            ELSE
              -- Efetua o calculo proporcional
              pr_tab_parcelas(vr_nrparepr).vliofadc := round(vr_vlbase_iof / pr_vlemprst * pr_vltariofadi,2);          
            END IF;
            
            -- Aplicar multiplicador de isenção adicional
            pr_tab_parcelas(vr_nrparepr).vliofadc := pr_tab_parcelas(vr_nrparepr).vliofadc * vr_idiseadi;
            
            -- Adicionar IOF adicional e acumular ao total        
            vr_vliofadi_acumulad := abs(vr_vliofadi_acumulad + round(nvl(pr_tab_parcelas(vr_nrparepr).vliofadc,0),2));
        
          END IF;        
          
          vr_nrparepr := vr_nrparepr + 1;          
        END IF;
        
        vr_datainicial := vr_datafinal;
        IF TO_CHAR(vr_datafinal,'DD') = TO_CHAR(pr_dtdpagto,'DD') AND vr_datafinal <> LAST_DAY(vr_datafinal) THEN
          vr_datafinal := LAST_DAY(vr_datafinal);
        ELSE
          vr_datafinal := ADD_MONTHS(TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||TO_CHAR(vr_datafinal,'/MM/RRRR'),'DD/MM/RRRR'),1);
        END IF;
      END LOOP;
            
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variavel de saida
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_iof_pos_fixado: ' || SQLERRM;

    END;

  END pc_calcula_iof_pos_fixado;
      
  
  /* Procedure para verificar IOF de Refinanciamento */
  PROCEDURE pc_calculo_epr_iof_refin (pr_cdcooper in crapepr.cdcooper%type     --> Cooperativa
                                     ,pr_nrdconta in crapepr.nrdconta%TYPE     --> Conta
                                     ,pr_inpessoa IN crapass.inpessoa%TYPE     --> Tipo Pessoa
                                     ,pr_nrctremp in crapepr.nrctremp%TYPE     --> Contrato
                                     ,pr_dsctrliq in varchar2                  --> Lista liquidações (Quanto pr_nrctremp=0)
                                     ,pr_vlbasiof IN out number                --> Valor base cobranças IOF
                                     ,pr_vliofpri out number                   --> Valor IOF Principal de parcelas pendentes 
                                     ,pr_vliofadi OUT NUMBER                   --> Valor IOF Adicional de parcelas pendentes 
                                     ,pr_dscritic out varchar2) IS    -- Descrição de erro
  BEGIN
    DECLARE
      -- Buscar informações da operação a ser calculada
      cursor cr_crawepr is
         select TO_CHAR(NRCTRLIQ##1) || ';' || TO_CHAR(NRCTRLIQ##2) || ';' ||
                TO_CHAR(NRCTRLIQ##3) || ';' || TO_CHAR(NRCTRLIQ##4) || ';' ||
                TO_CHAR(NRCTRLIQ##5) || ';' || TO_CHAR(NRCTRLIQ##6) || ';' ||
                TO_CHAR(NRCTRLIQ##7) || ';' || TO_CHAR(NRCTRLIQ##8) || ';' ||
                TO_CHAR(NRCTRLIQ##9) || ';' || TO_CHAR(NRCTRLIQ##10) dsliquid
          FROM crawepr
         where crawepr.cdcooper = pr_cdcooper
           and crawepr.nrdconta = pr_nrdconta
           and crawepr.nrctremp = pr_nrctremp;
       rw_crawepr cr_crawepr%rowtype;

      -- Buscar informações das operações a liquidar
      cursor cr_crapepr(pr_cdcooper crapepr.cdcooper%type
                       ,pr_nrdconta crapepr.nrdconta%type
                       ,pr_nrctremp crapepr.nrctremp%type) is
        select crapepr.dtmvtolt
              ,crapepr.txjuremp
              ,crapepr.vliofepr
              ,crapepr.qtpreemp
              ,crapepr.tpemprst
              ,crapepr.vliofpri
              ,crapepr.vliofadc 
          from crapepr
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and nrctremp = pr_nrctremp;
         rw_crapepr cr_crapepr%ROWTYPE;
         
      -- Buscar das parcelas das operações a liquidar
      cursor cr_crappep(pr_cdcooper crapepr.cdcooper%type
                       ,pr_nrdconta crapepr.nrdconta%type
                       ,pr_nrctremp crapepr.nrctremp%type) is
        select sum(nvl(pep.vliofpri,0)) vliofpri 
              ,sum(nvl(pep.vliofadc,0)) vliofadc
          from crappep pep
         where pep.cdcooper = pr_cdcooper
           and pep.nrdconta = pr_nrdconta
           and pep.nrctremp = pr_nrctremp
           AND pep.inliquid = 0;
      rw_crappep cr_crappep%ROWTYPE;      
      
      
      /* Tratamento de erro */
      vr_des_erro VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_dscritic VARCHAR2(4000);

      /* Erro em chamadas da pc_gera_erro */
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Lista e Tabela temporaria Contratos Liquidados
      vr_tab_nrctrliq GENE0002.typ_split;
      vr_dsctrliq varchar2(1000);
      
      -- Variaveis acumuladoras de saldo
      vr_taxaiofp   NUMBER(25,8);
      vr_taxaiofa   NUMBER(25,8);
      rw_crapdat   btch0001.cr_crapdat%rowtype;
      vr_vlsdeved  NUMBER;
      vr_vlmrapar  crappep.vlmrapar%TYPE;
      vr_vlmtapar  crappep.vlmtapar%TYPE;
      vr_vliofcpl  crappep.vliofcpl%TYPE;
      vr_qtregist   NUMBER;
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;

    BEGIN

      -- Zerar valor pendente IOF
      pr_vliofpri := 0;
      pr_vliofadi := 0;

      -- Busca do Calendário
      open btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;

      -- Caso tenha sido enviado contrato
      if nvl(pr_nrctremp,0) > 0 THEN
        -- Lista de liquidações já vem na query
        open cr_crawepr;
        fetch cr_crawepr into rw_crawepr;
        close cr_crawepr;
        vr_dsctrliq := rw_crawepr.dsliquid;
      ELSE
        -- Ajustar a lista de contratos removendo pontos e trocando vírgula por ;
        vr_dsctrliq := replace(replace(pr_dsctrliq,'.',''),',',';');
      END IF;
      
      -- Calcular taxa caso tenhamos alguma operação de TR em liquidação
      IF pr_inpessoa = 1 THEN
        vr_taxaiofp := 0.03 ; --+ vr_taxaiof;
      ELSE -- Se PJ
        vr_taxaiofp := 0.015 ; --+ vr_taxaiof;
      END IF;
      vr_taxaiofa := 0.0038;

      -- Converter lista para tabela de memória
      vr_tab_nrctrliq := GENE0002.fn_quebra_string(pr_string  => vr_dsctrliq,pr_delimit => ';');

      -- Se houver algo na lista
      IF vr_tab_nrctrliq.count() > 0 THEN
        -- Listagem de pagamentos informados
        FOR vr_idx IN 1..vr_tab_nrctrliq.COUNT LOOP
          IF NVL(vr_tab_nrctrliq(vr_idx),0) > 0 THEN
            -- Buscar dados do empréstimo a liquidar
            OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => vr_tab_nrctrliq(vr_idx));
            FETCH cr_crapepr INTO rw_crapepr;
            IF cr_crapepr%FOUND THEN
              CLOSE cr_crapepr;
              -- Reiniciar variáveis
              vr_vlsdeved := 0;
              vr_vlmrapar := 0;
              vr_vlmtapar := 0;
              vr_vliofcpl := 0;
              -- Calcular saldo devedor
              empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper                       --> Cooperativa conectada
                                              ,pr_cdagenci       => 1                                 --> Código da agência
                                              ,pr_nrdcaixa       => 1                                 --> Número do caixa
                                              ,pr_cdoperad       => 1                                 --> Código do Operador
                                              ,pr_nmdatela       => 'ATENDA'                          --> Código do programa corrente
                                              ,pr_idorigem       => 5                                 --> Id do módulo de sistema
                                              ,pr_nrdconta       => pr_nrdconta                       --> Número da conta
                                              ,pr_idseqttl       => 1                                 --> Seq titula
                                              ,pr_rw_crapdat     => rw_crapdat                        --> Vetor com dados de parâmetro (CRAPDAT)
                                              ,pr_dtcalcul       => rw_crapdat.dtmvtolt               --> Data para calculo do empréstimo
                                              ,pr_nrctremp       => vr_tab_nrctrliq(vr_idx)           --> Numero ctrato empréstimo
                                              ,pr_cdprogra       => 'ATENDA'                          --> Código do programa corrente
                                              ,pr_inusatab       => FALSE                             --> 
                                              ,pr_flgerlog       => 'N'                               --> Gerar log S/N 
                                              ,pr_flgcondc       => true         --> Mostrar emprestimos liquidados sem prejuizo
                                              ,pr_nmprimtl       => ''           --> Nome Primeiro Titular
                                              ,pr_tab_parempctl  => ''           --> Dados tabela parametro
                                              ,pr_tab_digitaliza => ''           --> Dados tabela parametro
                                              ,pr_nriniseq       => 0            --> Numero inicial da paginacao
                                              ,pr_nrregist       => 0            --> Numero de registros por pagina
                                              ,pr_qtregist       => vr_qtregist  --> Qtde total de registros
                                              ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                              ,pr_des_reto       => vr_des_reto  --> Retorno OK / NOK
                                              ,pr_tab_erro       => vr_tab_erro);  --> Tabela com possíves erros)
              -- Tratar possíveis erros
              IF vr_des_erro = 'NOK' THEN
                IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                ELSE
                  vr_dscritic := 'Não foi possivel calcular emprestimo.';
                END IF;
                RAISE vr_exc_erro;
              END IF;
              
              IF vr_tab_dados_epr.first IS NOT NULL THEN 
                -- calcular saldo devedor 
                vr_vlsdeved := nvl(vr_tab_dados_epr(vr_tab_dados_epr.first).vlsdeved,0);
                vr_vlmrapar := nvl(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmrapar,0);
                vr_vlmtapar := nvl(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmtapar,0);
                vr_vliofcpl := nvl(vr_tab_dados_epr(vr_tab_dados_epr.first).vliofcpl,0);
              END IF;
              
              -- Conforme deta da liberação
              IF rw_crapepr.dtmvtolt > to_date('31/03/2017','dd/mm/yyyy') THEN
                -- Descontar IOF complementar de atraso da base de calculo
                pr_vlbasiof := pr_vlbasiof - nvl(vr_vliofcpl, 0);
                -- Para TR 
                IF rw_crapepr.tpemprst = 0 THEN
                  -- Calcular o valor de IOF Principal e Adicional sobre o saldo devedor e acumular
                  pr_vliofpri := pr_vliofpri + ROUND((vr_vlsdeved /*+ vr_vlmrapar + vr_vlmtapar + vr_vliofcpl*/) * vr_taxaiofp,2);
                  pr_vliofadi := pr_vliofadi + ROUND((vr_vlsdeved /*+ vr_vlmrapar + vr_vlmtapar + vr_vliofcpl*/) * vr_taxaiofa,2);
                ELSE
                  -- Busca no cadastro de parcelas o IOF principal e adicional das parcelas pendentes
                  rw_crappep := NULL;
                  OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => vr_tab_nrctrliq(vr_idx)); 
                  FETCH cr_crappep
                   INTO rw_crappep;
                  CLOSE cr_crappep;
                  -- Para PP e Pós acumular o valor de IOF das parcelas pendentes
                  pr_vliofpri := pr_vliofpri + (rw_crappep.vliofpri);
                  pr_vliofadi := pr_vliofadi + (rw_crappep.vliofadc);
                END IF;  
              ELSE               
                -- Descontar o saldo devedor total da base de cálculo para IOF
                pr_vlbasiof := pr_vlbasiof - vr_vlsdeved /*+ vr_vlmrapar + vr_vlmtapar + vr_vliofcpl*/;
              END IF;
            ELSE
              CLOSE cr_crapepr;  
            END IF;            
          END IF;
        END LOOP;
        
        -- Garantir que a base de calculo não fique negativa
        pr_vlbasiof := greatest(0,pr_vlbasiof);
        
      END IF;


    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na EMPR0001.pc_calculo_epr_iof_refin --> ' ||SQLERRM;
    END;
  END pc_calculo_epr_iof_refin;      

  /* Calculo do IOF da proposta/empréstimo enviado */
  PROCEDURE pc_calcula_iof_epr(pr_cdcooper  IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta do associado
                              ,pr_nrctremp  IN crapepr.nrctremp%TYPE DEFAULT null
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                              ,pr_inpessoa  IN crapass.inpessoa%TYPE
                              ,pr_cdlcremp  IN crapepr.cdlcremp%TYPE
                              ,pr_cdfinemp  IN crapepr.cdfinemp%TYPE
                              ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE
                              ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE
                              ,pr_vlemprst  IN crapepr.vlemprst%TYPE
                              ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE
                              ,pr_dtlibera  IN crawepr.dtlibera%TYPE
                              ,pr_tpemprst  IN crawepr.tpemprst%TYPE
                              ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE
                              ,pr_qtdias_carencia IN tbepr_posfix_param_carencia.qtddias%TYPE
                              ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL            -- Bens em garantia (separados por "|")
                              ,pr_idfiniof        IN crapepr.idfiniof%TYPE DEFAULT 1  -- Indicador se financia IOF e tarifa
                              ,pr_dsctrliq        IN VARCHAR2 DEFAULT NULL            -- Lista de contratos a liquidar (Não necessário se passar pr_nrctremp)
                              ,pr_idgravar        IN VARCHAR2 DEFAULT 'N'             -- Indicador para gravação do IOF calculado na tabela de Parcelas
                              ,pr_vlpreclc       OUT craplcm.vllanmto%TYPE -- Valor calculado da parcela
                              ,pr_valoriof       OUT craplcm.vllanmto%TYPE -- Valor calculado com o iof (principal + adicional)
                              ,pr_vliofpri       OUT craplcm.vllanmto%TYPE -- Valor calculado do iof principal
                              ,pr_vliofadi       OUT craplcm.vllanmto%TYPE -- Valor calculado do iof adicional
                              ,pr_flgimune       OUT PLS_INTEGER
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descricão da critica
  /* .............................................................................
     Programa: pc_calcula_iof_epr
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : James Prust Junior
     Data    : Abril/2017                        Ultima atualizacao: 12/04/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamada
     Objetivo  : Calcular IOF para emprestimo/financiamento

     Alteracoes: 07/04/2017 - Implementar tratamento e calculo para empréstimos do
                              tipo PP. ( Renato Darosci )

                 09/05/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

                 12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)

  ............................................................................. */


    -- Busca os dados da linha de credito
    CURSOR cr_craplcr IS
      SELECT txmensal
            ,cdusolcr
            ,tpctrato
            ,flgtaiof
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    -- Tipo para armazenar as informações das parcelas
    TYPE typ_reg_parcela IS
      RECORD(nrparepr       crappep.nrparepr%TYPE
            ,dtvencto       crappep.dtvencto%TYPE
            ,qtdias         PLS_INTEGER
            ,vlparepr       NUMBER(25,2)
            ,vljuros        NUMBER(25,8)
            ,vlprincipal    NUMBER(25,8)
            ,vlsaldodevedor NUMBER(25,8)
            ,vliofprincipal NUMBER(25,2)
            ,vliofadicional NUMBER(25,2));

    -- Tabela para armazenar registros do tipo acima
    TYPE typ_tab_parcela IS TABLE OF typ_reg_parcela INDEX BY PLS_INTEGER;

    vr_tab_parcelas EMPR0011.typ_tab_parcelas;

    vr_tab_parcela       typ_tab_parcela;

    vr_dtmvtolt          DATE;                  -- Data do lançamento do IOF

    vr_saldo_devedor     NUMBER(25,2) := 0;
    vr_saldo_vlprsnt     NUMBER(25,2) := 0;
    vr_txmensal          number(25,8);          --craplcr.txmensal%TYPE;
    vr_txdiaria          number(25,8);          -- craplcr.txdiaria%TYPE;
    vr_dtvencto          DATE;
    vr_dtiniiof          DATE;
    vr_dtfimiof          DATE;
    vr_qtdias            PLS_INTEGER;
    vr_taxaiof           NUMBER(25,8);
    vr_txiofadc          number(25,8);
    vr_txiofcpl          number(25,8);
    vr_vltariof          NUMBER(25,8);
    vr_dstextab          VARCHAR2(500);
    vr_qtdedias          number;
    vr_diafinal          number;
    vr_mesfinal          number;
    vr_anofinal          NUMBER;
    
    vr_vlioftot          number(25,8) := 0;
    vr_vliofpri          number(25,8) := 0;
    vr_vliofpritt        number(25,8) := 0;
    vr_vliofadi          number(25,8) := 0;
    vr_vliofaditt        number(25,8) := 0;
    vr_vliofadi_base     number(25,8) := 0;
    vr_vliofcpl          number(25,8) := 0;
    vr_vlpreemp          number(25,8);
    vr_vltarifa          number;
    vr_vltarifaN         number;
    vr_vltarifaES        number;
    vr_vltarifaGT        number;
    vr_vlbasiof         number;
    vr_cdhistor          craphis.cdhistor%type;
    vr_cdfvlcop          crapfco.cdfvlcop%type;
    vr_cdhisgar          craphis.cdhistor%type;
    vr_cdfvlgar          crapfco.cdfvlcop%type;
    vr_vliofpri_ant      number;
    vr_vliofadi_ant      number;
    vr_flgimune     BOOLEAN;
    
    
    -- Checagem isencao IOF
    vr_idisepri PLS_INTEGER;
    vr_idiseadi PLS_INTEGER;
    vr_idisecpl PLS_INTEGER;
    
    /* Tratamento de erro */
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_dsreturn VARCHAR2(100);
    vr_tab_erro gene0001.typ_tab_erro;

         
    BEGIN
    -- Inicializar parâmetros de saída
    pr_vlpreclc     := pr_vlpreemp;
    pr_vliofpri     := 0;
    pr_vliofadi     := 0;
    pr_valoriof     := 0;
    pr_flgimune     := 0;

    -- Inicializar variáveis
    vr_vlpreemp     := pr_vlpreemp;
    vr_tab_parcela.DELETE;
    vr_taxaiof      := 0;
    vr_vlbasiof     := pr_vlemprst;
    vr_vltarifaN    := 0;    
    vr_idisepri     := 1;   
    vr_idiseadi     := 1;
    vr_idisecpl     := 1;
    vr_vliofpri_ant := 0;
    vr_vliofadi_ant := 0;
    
    -- Data base
    vr_dtmvtolt := nvl(pr_dtlibera, pr_dtmvtolt);


    -- Nova regra vale somente a partir de 25/01/2017
    IF vr_dtmvtolt < to_date('25/01/2017','DD/MM/RRRR') THEN
      RETURN;
    END IF;
    
    -- Quando pr_idgravar = 'C', não acionaremos esta rotina, pois estamos na nova execução
    -- da rotina onde devemos calcular o IOF para a operação completa, sem descontos de refin em 
    -- contratos anteriores 
    IF pr_idgravar <> 'C' THEN
      /* Em caso de Refin ajustar base de calculo e retornar IOF parcelas pendentes de liquidação */
      IF (trim(pr_dsctrliq) is not null
      and lower(pr_dsctrliq) NOT IN('0','sem liquidacoes')) OR nvl(pr_nrctremp,0) > 0 THEN
        -- Calcular enquadramento do IOF levando em conta contratos refinanciados
        pc_calculo_epr_iof_refin(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_inpessoa => pr_inpessoa
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_dsctrliq => pr_dsctrliq
                                ,pr_vlbasiof => vr_vlbasiof /* Base para IOF ajustada */
                                ,pr_vliofpri => vr_vliofpri_ant /* Lançamento IOF Principal Pendente  */
                                ,pr_vliofadi => vr_vliofadi_ant /* Lançamento IOF Principal Pendente  */
                                ,pr_dscritic => vr_dscritic);
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      end if;
    END IF;
  
    -- Buscar dados da linha de crédito e sua a taxa de juros
    OPEN cr_craplcr;
    FETCH cr_craplcr INTO rw_craplcr;
    -- se achou registro
    IF cr_craplcr%FOUND THEN
      -- Taxa de juros remunerados mensal
      vr_txmensal := ROUND((POWER(1 + (nvl(rw_craplcr.txmensal,0) / 100),1) - 1) * 100,2);
      vr_txdiaria := POWER((1 + (rw_craplcr.txmensal / 100)),(1/30))-1;
    END IF;
    CLOSE cr_craplcr;
    
    -- Caso financie tarifa e IOF
    if nvl(pr_idfiniof,0) = 1 then
      -- Calcular valor da tarifa
      TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_cdlcremp => pr_cdlcremp
                                ,pr_vlemprst => pr_vlemprst
                                ,pr_cdusolcr => rw_craplcr.cdusolcr
                                ,pr_tpctrato => rw_craplcr.tpctrato
                                ,pr_dsbemgar => pr_dscatbem
                                ,pr_cdprogra => 'ATENDA'
                                ,pr_flgemail => 'N'
                                ,pr_vlrtarif => vr_vltarifa
                                ,pr_vltrfesp => vr_vltarifaES
                                ,pr_vltrfgar => vr_vltarifaGT
                                ,pr_cdhistor => vr_cdhistor
                                ,pr_cdfvlcop => vr_cdfvlcop
                                ,pr_cdhisgar => vr_cdhisgar
                                ,pr_cdfvlgar => vr_cdfvlgar
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Sair em caso de erro 
      if nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
        raise vr_exc_erro;
      end if;
      -- Acumular tarifa 
      vr_vltarifaN := vr_vltarifa + vr_vltarifaES + vr_vltarifaGT;
    end if;
    
    -- Checar isenção de IOF
    tiof0001.pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper   --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta => pr_nrdconta   --> Número da conta referente ao empréstimo
                                    ,pr_dscatbem => pr_dscatbem   --> Descrição da categoria do bem, valor default NULO
                                    ,pr_cdlcremp => pr_cdlcremp   --> Linha de crédito do empréstimo
                                    ,pr_cdfinemp => pr_cdfinemp   --> Finalidade Empréstimo
                                    ,pr_idisepri => vr_idisepri   --> Valor do IOF principal
                                    ,pr_idiseadi => vr_idiseadi   --> Valor do IOF adicional
                                    ,pr_idisecpl => vr_idisecpl   --> Valor do IOF complementar
                                    ,pr_dscritic => vr_dscritic); --> Descrição da crítica
    -- Se retornou erro
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    ------------------------------------------------------------------------------------------------
    --                                 CALCULO DO NOVO IOF
    ------------------------------------------------------------------------------------------------


    -- Empréstimo do tipo TR
    IF pr_tpemprst = 0 THEN
     
      -- Se há base de IOF
      IF vr_vlbasiof > 0 THEN 
        -- Condicao Pessoa Fisica
        IF pr_inpessoa = 1 THEN
          vr_taxaiof := 0.03 ; --+ vr_taxaiof;
        ELSE -- Se PJ
          vr_taxaiof := 0.015 ; --+ vr_taxaiof;
        END IF;

        -- Valor do IOF (TR possui apenas Principal)
        vr_vliofpritt := ROUND(vr_vlbasiof * vr_taxaiof,2);
        vr_vliofaditt := ROUND(vr_vlbasiof * 0.0038,2);
              
        -- Aplicar multiplicadores de isenção
        vr_vliofpritt := vr_vliofpritt * vr_idisepri;
        vr_vliofaditt := vr_vliofaditt * vr_idiseadi;
      END IF;

    -- Se o empréstimo for do tipo PP
    ELSIF pr_tpemprst = 1 THEN
      
      -- Buscar a taxa do IOF "0,038"
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'VLIOFOPFIN'
                                               ,pr_tpregist => 1);

      IF vr_dstextab IS NOT NULL THEN
        -- Povoar as informacões conforme as regras da versão anterior
        vr_dtiniiof := TO_DATE(SUBSTR(vr_dstextab,1,10),'DD/MM/YYYY');
        vr_dtfimiof := TO_DATE(SUBSTR(vr_dstextab,12,10),'DD/MM/YYYY');
        IF vr_dtmvtolt BETWEEN vr_dtiniiof AND vr_dtfimiof THEN
          vr_taxaiof := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,23,14));
        END IF;
      END IF;    
      
      -- Calcular quantideade de dias entre data atual e data do pagtamento
      vr_diafinal := to_char(pr_dtdpagto, 'dd');             
      vr_mesfinal := to_char(pr_dtdpagto, 'mm');
      vr_anofinal := to_char(pr_dtdpagto, 'yyyy');
      empr0001.pc_calc_dias360 (pr_ehmensal => false
                               ,pr_dtdpagto => to_char(pr_dtdpagto,'DD')
                               ,pr_diarefju => to_char(vr_dtmvtolt,'DD')
                               ,pr_mesrefju => to_char(vr_dtmvtolt,'MM')
                               ,pr_anorefju => to_char(vr_dtmvtolt,'YYYY')
                               ,pr_diafinal => vr_diafinal
                               ,pr_mesfinal => vr_mesfinal
                               ,pr_anofinal => vr_anofinal
                               ,pr_qtdedias => vr_qtdedias );
      
      -- Se financia IOF e Tarifa
      if nvl(pr_idfiniof,0) = 1 THEN
        -- Acumular a tarifa na base de cálculo do IOF
        vr_saldo_devedor := vr_vlbasiof + nvl(vr_vltarifaN,0);
      else
        vr_saldo_devedor := vr_vlbasiof;
      end if;
      
      -- Somente calcular caso financie IOF, tenha tarifa ou base de IOF
      IF vr_saldo_devedor > 0 THEN
                                 
        -- Primeiro cálculo Base IOF + Tarifa 
        vr_saldo_devedor := ROUND((vr_vlbasiof + nvl(vr_vltarifaN,0)) * (POWER((1 + vr_txdiaria),((vr_qtdedias) - 30))),2);
        -- Manter valor presente armazenado
        vr_saldo_vlprsnt := vr_saldo_devedor;
        -- Calcular IOF adicional sobre a base
        vr_vliofadi_base := round((vr_vlbasiof + nvl(vr_vltarifaN,0)) * vr_taxaiof,2);

        -- Recalcula prestacao do emprestimo sob este valor
        vr_vlpreemp := vr_saldo_vlprsnt * (vr_txmensal / 100) / (1 - POWER((1 + (vr_txmensal / 100)), - pr_qtpreemp));
        
        -- Calcular Parcela por Parcela
        FOR vr_ind IN 1..pr_qtpreemp LOOP
          IF vr_ind > 1 THEN
            vr_saldo_devedor := vr_tab_parcela(vr_ind - 1).vlsaldodevedor;
          END IF;

          -- Data de Vencimento da Parcela
          vr_dtvencto := ADD_MONTHS(pr_dtdpagto,vr_ind - 1);

          -- Somente eh permitido calcular o IOF para 365 dias
          vr_qtdias := vr_dtvencto - vr_dtmvtolt;

          if vr_qtdias < 0 then
            vr_qtdias := abs(vr_qtdias);
          end if;

          IF vr_qtdias > 365 THEN
            vr_qtdias := 365;
          END IF;

          -- Valor do Juros
          vr_tab_parcela(vr_ind).vljuros := (vr_txmensal / 100) * vr_saldo_devedor;
          -- Valor Amortizacao/Principal
          if vr_vlbasiof + nvl(vr_vltarifaN,0) = 0 then
            vr_tab_parcela(vr_ind).vlprincipal := 0;
          else
            vr_tab_parcela(vr_ind).vlprincipal := vr_vlpreemp - vr_tab_parcela(vr_ind).vljuros;
          end if;
          
          -- Valor Saldo Devedor
          vr_tab_parcela(vr_ind).vlsaldodevedor := vr_saldo_devedor - vr_tab_parcela(vr_ind).vlprincipal;

          -- Calculo do valor do IOF de acordo com as novas regras
          tiof0001.pc_calcula_valor_iof_epr(pr_tpoperac => 1 -- Contratação
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vlemprst => vr_tab_parcela(vr_ind).vlprincipal
                                           ,pr_vltotope => vr_vlbasiof + nvl(vr_vltarifaN,0)
                                           ,pr_dscatbem => pr_dscatbem
                                           ,pr_cdlcremp => pr_cdlcremp
                                           ,pr_cdfinemp => pr_cdfinemp
                                           ,pr_dtmvtolt => vr_dtmvtolt
                                           ,pr_qtdiaiof => vr_qtdias
                                           ,pr_vliofpri => vr_vliofpri
                                           ,pr_vliofadi => vr_vliofadi
                                           ,pr_vliofcpl => vr_vliofcpl
                                           ,pr_vltaxa_iof_principal => vr_vltariof
                                           ,pr_flgimune => pr_flgimune
                                           ,pr_dscritic => vr_dscritic );
          -- Em caso de erro
          if vr_dscritic is NOT null THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Acumular IOF principal desta parcela
          vr_vliofpritt := abs(vr_vliofpritt + round(nvl(vr_vliofpri,0),2));
          vr_tab_parcela(vr_ind).vliofprincipal := round(nvl(vr_vliofpri,0),2);
          
          -- Na ultima parcela apenas utiliza a sobra do IOF Adicional, para evitar problemas de arredondamento
          IF vr_ind = pr_qtpreemp THEN
            -- Calcular a sobra
            vr_vliofadi := vr_vliofadi_base - vr_vliofaditt;
          ELSE
            -- Efetua o calculo proporcional
            vr_vliofadi := vr_tab_parcela(vr_ind).vlprincipal / vr_saldo_vlprsnt * vr_vliofadi_base;          
          END IF;
          
          -- Aplicar multiplicador de isenção adicional
          vr_vliofadi := vr_vliofadi * vr_idiseadi;
          vr_tab_parcela(vr_ind).vliofadicional := round(nvl(vr_vliofadi,0),2);
          
          -- Adicionar IOF adicional e acumular ao total        
          vr_vliofaditt := abs(vr_vliofaditt + round(nvl(vr_vliofadi,0),2));
          
        END LOOP;

        -- Refazer o calculo de IOF com base no financiamento Tarifa e IOF
        IF nvl(pr_idfiniof,0) = 1 THEN 
          
          -- Se há IOF ou Tarifa
          IF vr_vliofpritt + vr_vliofaditt + vr_vltarifaN > 0 THEN 

            -- Somar IOF total descontando IOFs pendentes anteriormente
            vr_vlioftot := greatest(vr_vliofpritt + vr_vliofaditt - nvl(vr_vliofpri_ant,0) - nvl(vr_vliofadi_ant,0),0);
          
            -- calcula saldo devedor com base no emprestimo + tarifa e incide o IOF já calculado
            vr_saldo_devedor := round(vr_vlbasiof + vr_vltarifaN,2);
            vr_saldo_devedor := ROUND(vr_saldo_devedor / ((vr_saldo_devedor - (vr_vlioftot)) / vr_saldo_devedor),2);
            -- Calcular IOF adicional base
            vr_vliofadi_base := round(vr_saldo_devedor * vr_taxaiof,2);
            -- Acha o VP (valor presente do saldo devedor)
            vr_saldo_devedor := ROUND(vr_saldo_devedor * (POWER((1 + vr_txdiaria),((vr_qtdedias) - 30))),2);
            vr_saldo_vlprsnt := vr_saldo_devedor;
            -- Recalcula prestacao do emprestimo
            vr_vlpreemp := vr_saldo_vlprsnt * (vr_txmensal / 100) / (1 - POWER((1 + (vr_txmensal / 100)), - pr_qtpreemp));
                
            -- Resetar valores de IOF
            vr_vliofpritt := 0;
            vr_vliofaditt := 0;
            
            -- Calcular todas as prestações
            FOR vr_ind IN 1..pr_qtpreemp LOOP
              IF vr_ind > 1 THEN
                vr_saldo_devedor := vr_tab_parcela(vr_ind - 1).vlsaldodevedor;
              END IF;

              -- Data de Vencimento da Parcela
              vr_dtvencto := ADD_MONTHS(pr_dtdpagto,vr_ind - 1);

              -- Somente eh permitido calcular o IOF para 365 dias
              vr_qtdias   := vr_dtvencto - vr_dtmvtolt;
              IF vr_qtdias > 365 THEN
                vr_qtdias := 365;
              END IF;

              -- Valor do Juros
              vr_tab_parcela(vr_ind).vljuros        := (vr_txmensal / 100) * vr_saldo_devedor;
              -- Valor Amortizacao/Principal
              vr_tab_parcela(vr_ind).vlprincipal    := vr_vlpreemp - vr_tab_parcela(vr_ind).vljuros;
              -- Valor Saldo Devedor
              vr_tab_parcela(vr_ind).vlsaldodevedor := vr_saldo_devedor - vr_tab_parcela(vr_ind).vlprincipal;

              -- Calculo do valor do IOF de acordo com as novas regras
              tiof0001.pc_calcula_valor_iof_epr(pr_tpoperac => 1 -- Contratação
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_vlemprst => vr_tab_parcela(vr_ind).vlprincipal
                                               ,pr_vltotope => vr_vlbasiof + nvl(vr_vltarifaN,0)
                                               ,pr_dscatbem => pr_dscatbem
                                               ,pr_cdlcremp => pr_cdlcremp
                                               ,pr_cdfinemp => pr_cdfinemp
                                               ,pr_dtmvtolt => vr_dtmvtolt
                                               ,pr_qtdiaiof => vr_qtdias
                                               ,pr_vliofpri => vr_vliofpri
                                               ,pr_vliofadi => vr_vliofadi
                                               ,pr_vliofcpl => vr_vliofcpl
                                               ,pr_vltaxa_iof_principal => vr_vltariof
                                               ,pr_flgimune => pr_flgimune
                                               ,pr_dscritic => vr_dscritic );
              -- Em caso de erro
              if vr_dscritic is NOT null THEN
                RAISE vr_exc_erro;
              END IF;
              
              -- Acumular IOF principal desta parcela
              vr_vliofpritt := abs(vr_vliofpritt + round(nvl(vr_vliofpri,0),2));
              vr_tab_parcela(vr_ind).vliofprincipal := round(nvl(vr_vliofpri,0),2);
              
              -- Na ultima parcela apenas utiliza a sobra do IOF Adicional, para evitar problemas de arredondamento
              IF vr_ind = pr_qtpreemp THEN
                -- Calcular a sobra
                vr_vliofadi := vr_vliofadi_base - vr_vliofaditt;
              ELSE
                -- Efetua o calculo proporcional
                vr_vliofadi := vr_tab_parcela(vr_ind).vlprincipal / vr_saldo_vlprsnt * vr_vliofadi_base;          
              END IF;
              
              -- Aplicar multiplicador de isenção
              vr_vliofadi := vr_vliofadi * vr_idiseadi;
              vr_tab_parcela(vr_ind).vliofadicional := round(nvl(vr_vliofadi,0),2);
              
              -- Adicionar IOF adicional e acumular ao total        
              vr_vliofaditt := abs(vr_vliofaditt + round(nvl(vr_vliofadi,0),2));

            END LOOP;
          end if;
        end if;

      END IF;  
      -- Converter tabela de memória temporária desta para a tabela genérica para reaproveitamento de código posterior
      FOR vr_ind IN 1..pr_qtpreemp LOOP
        -- Se não existir
        IF NOT vr_tab_parcela.exists(vr_ind) THEN 
          vr_tab_parcelas(vr_ind).nrparepr := vr_ind;
          vr_tab_parcelas(vr_ind).vliofpri := 0;
          vr_tab_parcelas(vr_ind).vliofadc := 0;          
        ELSE 
          vr_tab_parcelas(vr_ind).nrparepr := vr_ind;
          vr_tab_parcelas(vr_ind).vliofpri := vr_tab_parcela(vr_ind).vliofprincipal;
          vr_tab_parcelas(vr_ind).vliofadc := vr_tab_parcela(vr_ind).vliofadicional;
        END IF;
      END LOOP;
    ELSIF pr_tpemprst = 2 THEN  -- Se o emprestimo for Pos-Fixado
      
      -- Se financia IOF e Tarifa
      if nvl(pr_idfiniof,0) = 1 THEN
        -- Acumular a tarifa na base de cálculo do IOF
        vr_saldo_devedor := vr_vlbasiof + nvl(vr_vltarifaN,0);
      else
        vr_saldo_devedor := vr_vlbasiof;
      end if;
      
      -- Se há saldo devedor
      IF vr_saldo_devedor > 0 THEN
        
        -- Busca Taxa de IOF
        tiof0001.pc_busca_taxa_iof(pr_cdcooper   => pr_cdcooper
                                  ,pr_nrdconta   => pr_nrdconta
                                  ,pr_nrctremp   => pr_nrctremp
                                  ,pr_dtmvtolt   => vr_dtmvtolt
                                  ,pr_cdlcremp   => pr_cdlcremp
                                  ,pr_cdfinemp   => pr_cdfinemp
                                  ,pr_vlemprst   => vr_vlbasiof
                                  ,pr_vltxiofpri => vr_taxaiof
                                  ,pr_vltxiofadc => vr_txiofadc
                                  ,pr_vltxiofcpl => vr_txiofcpl
                                  ,pr_cdcritic   => vr_cdcritic
                                  ,pr_dscritic   => vr_dscritic);
        -- Em caso de erro
        if vr_cdcritic > 0 OR vr_dscritic is not null then
          raise vr_exc_erro;
        end if;      
      
        -- Chama o calculo de IOF para Pos-Fixado (1º Cálculo)
        TIOF0001.pc_calcula_iof_pos_fixado(pr_cdcooper        => pr_cdcooper
                                          ,pr_nrdconta        => pr_nrdconta
                                          ,pr_nrctremp        => pr_nrctremp
                                          ,pr_dtcalcul        => vr_dtmvtolt
                                          ,pr_cdlcremp        => pr_cdlcremp
                                          ,pr_cdfinemp        => pr_cdfinemp
                                          ,pr_vlemprst        => vr_saldo_devedor
                                          ,pr_qtpreemp        => pr_qtpreemp
                                          ,pr_dtdpagto        => pr_dtdpagto
                                          ,pr_dtcarenc        => pr_dtcarenc
                                          ,pr_qtdias_carencia => pr_qtdias_carencia
                                          ,pr_taxaiof         => vr_taxaiof
                                          ,pr_taxaiofadi      => vr_txiofadc
                                          ,pr_dscatbem        => pr_dscatbem
                                          ,pr_vltariof        => vr_vliofpritt
                                          ,pr_vltariofadi     => vr_vliofaditt
                                          ,pr_tab_parcelas    => vr_tab_parcelas
                                          ,pr_cdcritic        => vr_cdcritic
                                          ,pr_dscritic        => vr_dscritic);
        -- Se retornou erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Calcula IOF Adicional com base no saldo devedor
        vr_vliofaditt := ROUND((vr_vlbasiof + nvl(vr_vltarifaN,0)) * vr_txiofadc,2);
        
        -- Aplicar multiplicador de isenção
        vr_vliofaditt := vr_vliofaditt * vr_idiseadi;
        
        -- Armazenar IOF Principal e Adicional do primeiro cálculo
        vr_vliofpri := vr_vliofpritt;
        vr_vliofadi := vr_vliofaditt;

        -- Caso financie IOF ou tarifa
        if pr_idfiniof = 1 THEN
          
          -- Se há IOF ou Tarifa
          IF vr_vliofpritt + vr_vliofaditt + vr_vltarifaN > 0 THEN 
            -- Somar IOF total descontando IOFs pendentes anteriormente
            vr_vlioftot := greatest(vr_vliofpritt + vr_vliofaditt - nvl(vr_vliofpri_ant,0) - nvl(vr_vliofadi_ant,0),0);
            
            -- recalcula valor devedor, chama novamente o calculo de iof pós-fixado
            vr_saldo_devedor := round(vr_vlbasiof + nvl(vr_vltarifaN,0),2);
            IF vr_saldo_devedor > 0 THEN
              vr_saldo_devedor := (ROUND(vr_saldo_devedor / ((vr_saldo_devedor - nvl(vr_vlioftot,0)) / vr_saldo_devedor),2))+0.01;
            END IF;

            --Recalcula o valor do IOF adicional
            vr_vliofaditt := ROUND(vr_saldo_devedor * vr_txiofadc,2);
          
            -- Aplicar multiplicador de isenção
            vr_vliofaditt := vr_vliofaditt * vr_idiseadi;
      
            -- Calcula IOF após novo valor 
            TIOF0001.pc_calcula_iof_pos_fixado(pr_cdcooper        => pr_cdcooper
                                              ,pr_nrdconta        => pr_nrdconta
                                              ,pr_nrctremp        => pr_nrctremp
                                              ,pr_dtcalcul        => vr_dtmvtolt
                                              ,pr_cdlcremp        => pr_cdlcremp
                                              ,pr_cdfinemp        => pr_cdfinemp
                                              ,pr_vlemprst        => vr_saldo_devedor
                                              ,pr_qtpreemp        => pr_qtpreemp
                                              ,pr_dtdpagto        => pr_dtdpagto
                                              ,pr_dtcarenc        => pr_dtcarenc
                                              ,pr_qtdias_carencia => pr_qtdias_carencia
                                              ,pr_taxaiof         => vr_taxaiof
                                              ,pr_taxaiofadi      => vr_txiofadc
                                              ,pr_dscatbem        => pr_dscatbem
                                              ,pr_vltariof        => vr_vliofpritt
                                              ,pr_vltariofadi     => vr_vliofaditt
                                              ,pr_tab_parcelas    => vr_tab_parcelas
                                              ,pr_cdcritic        => vr_cdcritic
                                              ,pr_dscritic        => vr_dscritic);
            -- Se retornou erro
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
      END IF;
        end IF;
         
      END IF; 
           
      END IF;
         
    -- Retornar o valor de IOF Principal e Adicional conforme o cálculo
    pr_vliofpri := vr_vliofpritt;
    pr_vliofadi := vr_vliofaditt;
    
    -- Se tem refinanciamento, descontamos o IOF já pago anteriormente
    IF (trim(pr_dsctrliq) is not null
      and lower(pr_dsctrliq) NOT IN('0','sem liquidacoes')) THEN
    
      pr_vliofpri := greatest(vr_vliofpritt - vr_vliofpri_ant,0); 
      pr_vliofadi := greatest(vr_vliofaditt - vr_vliofadi_ant,0);
      
    END IF;
    
    -- Enfim calcular o IOF a ser cobrado descontando IOFs anteriores
    -- Aqui não pode haver valor negativo quando descontado o IOF anterior. 
    -- Não há previsão para tratar IOF negativo.
    pr_valoriof := greatest( greatest(vr_vliofpritt - vr_vliofpri_ant,0) + greatest(vr_vliofaditt - vr_vliofadi_ant,0), 0);
    
    -- Descontar IOFs anteriores tambem para o IOF do primeiro calculo (Usado no Pós)
    vr_vliofpri := greatest(vr_vliofpri-vr_vliofpri_ant,0);
    vr_vliofadi := greatest(vr_vliofadi-vr_vliofadi_ant,0);
    
    -- Somente para Pós, e na execução sem gravação de IOF
    IF pr_tpemprst = 2 AND pr_idgravar NOT IN('C','S') THEN
      -- Retornaremos o IOF Principal e Adicional do primeiro cálculo
      pr_vliofpri := vr_vliofpri;
      pr_vliofadi := vr_vliofadi;
    END IF;
    
    -- Checar imunidade tributária
    IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dtmvtolt => vr_dtmvtolt
                                       ,pr_inpessoa => pr_inpessoa
                                       ,pr_flgrvvlr => FALSE
                                       ,pr_cdinsenc => 0
                                       ,pr_vlinsenc => pr_valoriof
                                       ,pr_flgimune => Vr_flgimune
                                       ,pr_dsreturn => vr_dsreturn
                                       ,pr_tab_erro => vr_tab_erro);

    -- Condicao para verificar se houve erro
    IF vr_dsreturn <> 'OK' THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.COUNT > 0 THEN
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic || ' - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic := 'Não foi possivel verificar a imunidade tributaria';
        END IF;
      RAISE vr_exc_erro;
    END IF;

    -- No caso de imunidade, nao cobra IOF
    IF vr_flgimune then
      pr_flgimune := 1;
      pr_valoriof := 0;
      pr_vliofpri := 0;
      pr_vliofadi := 0;
      vr_vliofpri := 0;
      vr_vliofadi := 0;      
    ELSE
      pr_flgimune := 0;
    END IF;
    
    -- Calculo da Prestação (Somente para PP e Pós)
    IF pr_tpemprst in(1,2) THEN
      -- SAldo devedor inicial = Valor Empréstimo
      vr_saldo_devedor := pr_vlemprst;
      -- Calcular o Saldo Devedor original + (IOF + Tarifa se finaciados)
      if nvl(pr_idfiniof,0) = 1 THEN
        -- Acumular a tarifa na base de cálculo do IOF
        vr_saldo_devedor := vr_saldo_devedor + nvl(vr_vltarifaN,0);
        -- Para PP
        IF pr_tpemprst = 1 THEN
          -- Acumular IOF ao saldo devedor
          vr_saldo_devedor := vr_saldo_devedor + nvl(pr_valoriof,0);  
        ELSE
          -- Pós
          vr_saldo_devedor := round(vr_saldo_devedor/((vr_saldo_devedor-nvl(vr_vliofpri,0)-nvl(vr_vliofadi,0))/vr_saldo_devedor),2)+0.01;
        END IF;
      END IF;
      -- Para PP
      IF pr_tpemprst = 1 THEN 
        -- Recalcular valor presente do saldo devedor
        vr_saldo_devedor := ROUND(vr_saldo_devedor * (POWER((1 + vr_txdiaria),((vr_qtdedias) - 30))),2);
        -- Recalcula prestacao do emprestimo
        vr_vlpreemp := vr_saldo_devedor * (vr_txmensal / 100) / (1 - POWER((1 + (vr_txmensal / 100)), - pr_qtpreemp));
      ELSE
        -- Acionar novamente a rotina de cálculo das Parcelas, desta vez teremos o saldo original do contrato e não mais a base do IOF
        TIOF0001.pc_calcula_iof_pos_fixado(pr_cdcooper        => pr_cdcooper
                                          ,pr_nrdconta        => pr_nrdconta
                                          ,pr_nrctremp        => pr_nrctremp
                                          ,pr_dtcalcul        => vr_dtmvtolt
                                          ,pr_cdlcremp        => pr_cdlcremp
                                          ,pr_cdfinemp        => pr_cdfinemp
                                          ,pr_vlemprst        => vr_saldo_devedor
                                          ,pr_qtpreemp        => pr_qtpreemp
                                          ,pr_dtdpagto        => pr_dtdpagto
                                          ,pr_dtcarenc        => pr_dtcarenc
                                          ,pr_qtdias_carencia => pr_qtdias_carencia
                                          ,pr_taxaiof         => vr_taxaiof
                                          ,pr_taxaiofadi      => vr_txiofadc
                                          ,pr_dscatbem        => pr_dscatbem
                                          ,pr_vltariof        => vr_vliofpri /* Sera desprezado */
                                          ,pr_vltariofadi     => vr_vliofadi /* Sera desprezado */
                                          ,pr_tab_parcelas    => vr_tab_parcelas
                                          ,pr_cdcritic        => vr_cdcritic
                                          ,pr_dscritic        => vr_dscritic);
        -- Se retornou erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Buscar a primeira parcela sem carencia
				FOR vr_indice IN 1..vr_tab_parcelas.count() LOOP
					--
					IF vr_tab_parcelas(vr_indice).flcarenc = 0 THEN
						--
						vr_vlpreemp := vr_tab_parcelas(vr_indice).vlparepr;
						EXIT;
						--
      END IF;  
					--
				END LOOP;
				--
      END IF; 
			-- 
    END IF;
    
    -- Retornar a prestação calculada
    pr_vlpreclc := vr_vlpreemp;   
    
    -- Se foi enviado contrato, cooperado não é imune e id gravação <> 'N'
    IF pr_nrctremp > 0 AND pr_idgravar <> 'N' AND NOT vr_flgimune THEN 
    
      -- Se foi solicitada a gravação do IOF 
      IF pr_idgravar = 'S' THEN
        
        -- Acionaremos esta mesma rotina, desta vez passando a flag como C, isto fará com
        -- que a rotina recalcule e grave o IOF por completo, evitando descontos de contratos anteriores
        pc_calcula_iof_epr(pr_cdcooper        => pr_cdcooper       
                          ,pr_nrdconta        => pr_nrdconta       
                          ,pr_nrctremp        => pr_nrctremp       
                          ,pr_dtmvtolt        => pr_dtmvtolt       
                          ,pr_inpessoa        => pr_inpessoa       
                          ,pr_cdlcremp        => pr_cdlcremp       
                          ,pr_cdfinemp        => pr_cdfinemp       
                          ,pr_qtpreemp        => pr_qtpreemp       
                          ,pr_vlpreemp        => pr_vlpreemp       
                          ,pr_vlemprst        => pr_vlemprst       
                          ,pr_dtdpagto        => pr_dtdpagto       
                          ,pr_dtlibera        => pr_dtlibera       
                          ,pr_tpemprst        => pr_tpemprst       
                          ,pr_dtcarenc        => pr_dtcarenc       
                          ,pr_qtdias_carencia => pr_qtdias_carencia
                          ,pr_dscatbem        => pr_dscatbem       
                          ,pr_idfiniof        => pr_idfiniof       
                          ,pr_dsctrliq        => pr_dsctrliq       
                          ,pr_idgravar        => 'C'
                          ,pr_vlpreclc        => vr_vlpreemp -- Não será utilizada 
                          ,pr_valoriof        => vr_vlbasiof 
                          ,pr_vliofpri        => vr_vliofpritt
                          ,pr_vliofadi        => vr_vliofaditt
                          ,pr_flgimune        => pr_flgimune
                          ,pr_dscritic        => vr_dscritic);        
        -- Se retornou erro
        IF  vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- NEste caso houve recalculo do IOF Principal e Adicional, 
        -- então iremos atualizar os valores a ser devolvidos
        -- Obs: O valor do IOF cobrado persiste o valor do calculo da 
        --      primeira chamada da rotina, ou seja, onde desconsideramos
        --      IOFs de contratos anteriores
      --  pr_vliofpri := vr_vliofpritt;
      --  pr_vliofadi := vr_vliofaditt;
      END IF;
      
      -- Se solicitado a gravação do IOF Completo nas Parcelas e o cálculo retornou IOF para a operação
      IF pr_idgravar = 'C' THEN
        -- Varrer todas as parcelas e então atualizar CRAPPEP (Somente PP e Pós)
        FOR vr_indice IN 1..vr_tab_parcelas.count() LOOP
          -- Se encontrar e há valor de IOF adicional ou principal
          IF vr_tab_parcelas.exists(vr_indice) THEN
            -- Atualizar CRAPPEP
            BEGIN  
              UPDATE crappep
                 SET vliofpri = nvl(vr_tab_parcelas(vr_indice).vliofpri,0)
                    ,vliofadc = nvl(vr_tab_parcelas(vr_indice).vliofadc,0)
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND nrparepr = vr_tab_parcelas(vr_indice).nrparepr;
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crappep: '
                            || 'vliofpri:' || vr_tab_parcelas(vr_indice).vliofpri 
                            || ' ,vliofadc:' || vr_tab_parcelas(vr_indice).vliofadc
                            || ' com cdcooper: '||pr_cdcooper
                            || ' ,nrdconta: '||pr_nrdconta
                            || ' ,nrctremp: '||pr_nrctremp
                            || ' ,nrparepr: '||vr_tab_parcelas(vr_indice).nrparepr||'. '||sqlerrm;
                RAISE vr_exc_erro;
            END;
          END IF;
        END LOOP;
      END IF;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na EMPR0001.pc_calcula_iof_epr --> ' || SQLERRM;
  END pc_calcula_iof_epr;
  
  /* Interface para chamada via AyllosWeb da pc_calcula_iof_epr */
  PROCEDURE pc_calcula_iof_epr_web(pr_cdcooper        IN crapepr.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrctremp        IN crapepr.nrctremp%TYPE DEFAULT null
                                  ,pr_dtmvtolt        IN VARCHAR2
                                  ,pr_inpessoa        IN crapass.inpessoa%TYPE
                                  ,pr_cdlcremp        IN crapepr.cdlcremp%TYPE
                                  ,pr_cdfinemp        IN crapepr.cdfinemp%TYPE
                                  ,pr_qtpreemp        IN crapepr.qtpreemp%TYPE
                                  ,pr_vlpreemp        IN crapepr.vlpreemp%TYPE
                                  ,pr_vlemprst        IN crapepr.vlemprst%TYPE
                                  ,pr_dtdpagto        IN VARCHAR2
                                  ,pr_dtlibera        IN VARCHAR2
                                  ,pr_tpemprst        IN crawepr.tpemprst%TYPE
                                  ,pr_dtcarenc        IN VARCHAR2
                                  ,pr_idcarencia      IN crawepr.idcarenc%TYPE
                                  ,pr_dscatbem        IN VARCHAR2 DEFAULT NULL            -- Bens em garantia (separados por "|")
                                  ,pr_idfiniof        IN crapepr.idfiniof%TYPE DEFAULT 1  -- Indicador se financia IOF e tarifa
                                  ,pr_dsctrliq        IN VARCHAR2 DEFAULT NULL
                                  ,pr_idgravar        IN VARCHAR2 DEFAULT 'N'             -- Indicador S/N para gravação do IOF calculado na tabela de Parcelas
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    -- ........................................................................
    --
    --  Programa : pc_calcula_iof_epr_web
    --  Sistema  : Cred
    --  Sigla    : EMPR0001
    --  Autor    : Diogo Carlassara (MoutS)
    --  Data     : 19/01/2015.                      Ultima atualizacao: 12/04/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : calcular valor do iof - chamada pela web
    --   Alterações
    --               12/04/2018 - P410 - Melhorias IOF (Marcos-Envolti)
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_vlpreclc NUMBER;
      vr_valoriof NUMBER;
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_flgimune PLS_INTEGER;
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;
      vr_dtdpagto crapepr.dtdpagto%TYPE;
      vr_dtlibera crawepr.dtlibera%TYPE;
      vr_dtcarenc crawepr.dtcarenc%TYPE;
      vr_qtdias_carencia  pls_integer;
    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt, 'DD/MM/YYYY');
      vr_dtdpagto := TO_DATE(pr_dtdpagto, 'DD/MM/YYYY');
      vr_dtlibera := TO_DATE(pr_dtlibera, 'DD/MM/YYYY');
      vr_dtcarenc := TO_DATE(pr_dtcarenc, 'DD/MM/YYYY');

      -- Busca quantidade de dias da carencia
      EMPR0011.pc_busca_qtd_dias_carencia(pr_idcarencia => pr_idcarencia
                                         ,pr_qtddias    => vr_qtdias_carencia
                                         ,pr_cdcritic   => vr_cdcritic
                                         ,pr_dscritic   => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Acionar o calculo do IOF
      pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_inpessoa => pr_inpessoa
                        ,pr_cdfinemp => pr_cdfinemp
                        ,pr_cdlcremp => pr_cdlcremp
                        ,pr_qtpreemp => pr_qtpreemp
                        ,pr_vlpreemp => pr_vlpreemp
                        ,pr_vlemprst => pr_vlemprst
                        ,pr_dtdpagto => vr_dtdpagto
                        ,pr_dtlibera => vr_dtlibera
                        ,pr_tpemprst => pr_tpemprst
                        ,pr_dtcarenc => vr_dtcarenc
                        ,pr_qtdias_carencia => vr_qtdias_carencia
                        ,pr_valoriof => vr_valoriof
                        ,pr_dscatbem => pr_dscatbem
                        ,pr_vlpreclc => vr_vlpreclc
                        ,pr_idfiniof => pr_idfiniof
                        ,pr_dsctrliq => pr_dsctrliq
                        ,pr_idgravar => pr_idgravar
                        ,pr_vliofpri => vr_vliofpri
                        ,pr_vliofadi => vr_vliofadi
                        ,pr_flgimune => vr_flgimune
                        ,pr_dscritic => vr_dscritic);

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => TO_CHAR(pr_cdcooper), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(pr_nrdconta), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrctremp', pr_tag_cont => TO_CHAR(pr_nrctremp), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => TO_CHAR(pr_inpessoa), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdlcremp', pr_tag_cont => TO_CHAR(pr_cdlcremp), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtpreemp', pr_tag_cont => TO_CHAR(pr_qtpreemp), pr_des_erro => vr_dscritic);
        if nvl(vr_vlpreclc,0) > 0 then
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlpreemp', pr_tag_cont => TO_CHAR(vr_vlpreclc, 'fm999g999g990d00'), pr_des_erro => vr_dscritic);
        else
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlpreemp', pr_tag_cont => TO_CHAR(nvl(pr_vlpreemp,0), 'fm999g999g990d00'), pr_des_erro => vr_dscritic);
        end if;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'tpemprst', pr_tag_cont => TO_CHAR(pr_tpemprst), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdias_carencia', pr_tag_cont => TO_CHAR(vr_qtdias_carencia), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'valoriof', pr_tag_cont => TO_CHAR(vr_valoriof,'fm999g999g990d00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsctrliq', pr_tag_cont => TO_CHAR(pr_dsctrliq), pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || SQLERRM || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0001.pc_calcula_iof_epr_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_calcula_iof_epr_web;    
    
  PROCEDURE pc_insere_iof (pr_cdcooper	     IN tbgen_iof_lancamento.cdcooper%TYPE                    --> Codigo da Cooperativa 
                          ,pr_nrdconta       IN tbgen_iof_lancamento.nrdconta%TYPE                    --> Numero da Conta Corrente
                          ,pr_dtmvtolt       IN tbgen_iof_lancamento.dtmvtolt%TYPE                    --> Data de Movimento
                          ,pr_tpproduto      IN tbgen_iof_lancamento.tpproduto%TYPE                   --> Tipo de Produto
                          ,pr_nrcontrato     IN tbgen_iof_lancamento.nrcontrato%TYPE                  --> Numero do Contrato
                          ,pr_idlautom       IN tbgen_iof_lancamento.idlautom%TYPE     DEFAULT NULL   --> Chave: Id dos Lancamentos Futuros
                          ,pr_dtmvtolt_lcm   IN tbgen_iof_lancamento.dtmvtolt_lcm%TYPE DEFAULT NULL   --> Chave: Data de Movimento Lancamento
                          ,pr_cdagenci_lcm   IN tbgen_iof_lancamento.cdagenci_lcm%TYPE DEFAULT NULL   --> Chave: Agencia do Lancamento
                          ,pr_cdbccxlt_lcm   IN tbgen_iof_lancamento.cdbccxlt_lcm%TYPE DEFAULT NULL   --> Chave: Caixa do Lancamento
                          ,pr_nrdolote_lcm   IN tbgen_iof_lancamento.nrdolote_lcm%TYPE DEFAULT NULL   --> Chave: Lote do Lancamento
                          ,pr_nrseqdig_lcm   IN tbgen_iof_lancamento.nrseqdig_lcm%TYPE DEFAULT NULL   --> Chave: Sequencia do Lancamento
                          ,pr_vliofpri       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Principal
                          ,pr_vliofadi       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Adicional
                          ,pr_vliofcpl       IN tbgen_iof_lancamento.vliof%TYPE DEFAULT 0             --> Valor do IOF Complementar
                          ,pr_flgimune       IN PLS_INTEGER                                           --> Possui imunidade tributária (1 - Sim / 0 - Não)
                          ,pr_cdcritic       OUT NUMBER                                               --> Código da Crítica
                          ,pr_dscritic       OUT VARCHAR2)  IS                                        --> Descrição da Crítica
  
   /* .............................................................................
    Programa: pc_insere_iof
    Sistema : Rotina para inserir valor do IOF
    Sigla   : TIOF
    Autor   : James Prust Junior
    Data    : Novembro/2017.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar o valor do IOF

    Observacao: -----
    Alteracoes:
    ..............................................................................*/
	
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(10000);
    vr_cdcritic     INTEGER;
    vr_exc_erro     EXCEPTION;
    vr_flgimune     PLS_INTEGER;
  BEGIN    

    vr_flgimune := NVL(pr_flgimune, 0);

    -- Condicao para verificar se devemos lancar valor do IOF Principal
    IF pr_vliofpri > 0 THEN
      BEGIN
        INSERT INTO tbgen_iof_lancamento
                    (cdcooper
                    ,nrdconta
                    ,dtmvtolt
                    ,tpproduto
                    ,tpiof
                    ,nrcontrato
                    ,idlautom
                    ,dtmvtolt_lcm
                    ,cdagenci_lcm
                    ,cdbccxlt_lcm
                    ,nrdolote_lcm
                    ,nrseqdig_lcm
                    ,inimunidade
                    ,vliof)
             VALUES (pr_cdcooper
                    ,pr_nrdconta
                    ,pr_dtmvtolt
                    ,pr_tpproduto
                    ,1 --> IOF Principal
                    ,pr_nrcontrato
                    ,pr_idlautom
                    ,pr_dtmvtolt_lcm
                    ,pr_cdagenci_lcm
                    ,pr_cdbccxlt_lcm
                    ,pr_nrdolote_lcm
                    ,pr_nrseqdig_lcm
                    ,vr_flgimune
                    ,pr_vliofpri);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela de IOF: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;  
    
    -- Condicao para verificar se devemos lancar valor do IOF Adicional
    IF pr_vliofadi > 0 THEN
      BEGIN
        INSERT INTO tbgen_iof_lancamento
                    (cdcooper
                    ,nrdconta
                    ,dtmvtolt
                    ,tpproduto
                    ,tpiof
                    ,nrcontrato
                    ,idlautom
                    ,dtmvtolt_lcm
                    ,cdagenci_lcm
                    ,cdbccxlt_lcm
                    ,nrdolote_lcm
                    ,nrseqdig_lcm
                    ,inimunidade
                    ,vliof)
             VALUES (pr_cdcooper
                    ,pr_nrdconta
                    ,pr_dtmvtolt
                    ,pr_tpproduto
                    ,2 --> IOF Adicional
                    ,pr_nrcontrato
                    ,pr_idlautom
                    ,pr_dtmvtolt_lcm
                    ,pr_cdagenci_lcm
                    ,pr_cdbccxlt_lcm
                    ,pr_nrdolote_lcm
                    ,pr_nrseqdig_lcm
                    ,vr_flgimune
                    ,pr_vliofadi);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela de IOF: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;    
      
    -- Condicao para verificar se devemos lancar valor do IOF Complementar
    IF pr_vliofcpl > 0 THEN
      BEGIN
        INSERT INTO tbgen_iof_lancamento
                    (cdcooper
                    ,nrdconta
                    ,dtmvtolt
                    ,tpproduto
                    ,tpiof
                    ,nrcontrato
                    ,idlautom
                    ,dtmvtolt_lcm
                    ,cdagenci_lcm
                    ,cdbccxlt_lcm
                    ,nrdolote_lcm
                    ,nrseqdig_lcm
                    ,inimunidade
                    ,vliof)
             VALUES (pr_cdcooper
                    ,pr_nrdconta
                    ,pr_dtmvtolt
                    ,pr_tpproduto
                    ,3 --> IOF Complementar
                    ,pr_nrcontrato
                    ,pr_idlautom
                    ,pr_dtmvtolt_lcm
                    ,pr_cdagenci_lcm
                    ,pr_cdbccxlt_lcm
                    ,pr_nrdolote_lcm
                    ,pr_nrseqdig_lcm
                    ,vr_flgimune
                    ,pr_vliofcpl);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela de IOF: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gravar valor do IOF. Rotina TIOF0001.pc_insere_iof. ' || SQLERRM;
  END pc_insere_iof;
  
  PROCEDURE pc_altera_iof (pr_cdcooper	     IN tbgen_iof_lancamento.cdcooper%TYPE                  --> Codigo da Cooperativa 
                          ,pr_nrdconta       IN tbgen_iof_lancamento.nrdconta%TYPE                  --> Numero da Conta Corrente
                          ,pr_dtmvtolt       IN tbgen_iof_lancamento.dtmvtolt%TYPE                  --> Data de Movimento
                          ,pr_tpproduto      IN tbgen_iof_lancamento.tpproduto%TYPE                 --> Tipo de Produto
                          ,pr_nrcontrato     IN tbgen_iof_lancamento.nrcontrato%TYPE                --> Numero do Contrato
                          ,pr_idlautom       IN tbgen_iof_lancamento.idlautom%TYPE     DEFAULT NULL --> Chave: Id dos Lancamentos Futuros
                          ,pr_cdagenci_lcm   IN tbgen_iof_lancamento.cdagenci_lcm%TYPE DEFAULT NULL --> Chave: Agencia do Lancamento
                          ,pr_cdbccxlt_lcm   IN tbgen_iof_lancamento.cdbccxlt_lcm%TYPE DEFAULT NULL --> Chave: Caixa do Lancamento
                          ,pr_nrdolote_lcm   IN tbgen_iof_lancamento.nrdolote_lcm%TYPE DEFAULT NULL --> Chave: Lote do Lancamento
                          ,pr_nrseqdig_lcm   IN tbgen_iof_lancamento.nrseqdig_lcm%TYPE DEFAULT NULL --> Chave: Sequencia do Lancamento
                          ,pr_nracordo       IN tbgen_iof_lancamento.nracordo%TYPE DEFAULT NULL     --> Chave: nr acordo
                          ,pr_cdcritic       OUT NUMBER                                             --> Código da Crítica
                          ,pr_dscritic       OUT VARCHAR2)  IS                                      --> Descrição da Crítica
  
   /* .............................................................................
    Programa: pc_altera_iof
    Sistema : Rotina para inserir valor do IOF
    Sigla   : TIOF
    Autor   : James Prust Junior
    Data    : Novembro/2017.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar o valor do IOF

    Observacao: -----
    Alteracoes:	07/05/2018 - Inclusao do campo nracordo. PRJ450(Odirlei-AMcom)
    ..............................................................................*/
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(10000);
    vr_exc_erro EXCEPTION;
  BEGIN    
	
    -- Tipo do produto (1-Emprestimo/ 2-Desconto Titulo/ 3-Desconto Cheque/ 4-Limite Credito /5-Adiantamento Depositante)
    IF pr_tpproduto = 5 THEN
      BEGIN
        UPDATE tbgen_iof_lancamento SET
               tbgen_iof_lancamento.idlautom     = pr_idlautom
  	          ,tbgen_iof_lancamento.dtmvtolt_lcm = pr_dtmvtolt
              ,tbgen_iof_lancamento.cdagenci_lcm = pr_cdagenci_lcm
              ,tbgen_iof_lancamento.cdbccxlt_lcm = pr_cdbccxlt_lcm
              ,tbgen_iof_lancamento.nrdolote_lcm = pr_nrdolote_lcm
              ,tbgen_iof_lancamento.nrseqdig_lcm = pr_nrseqdig_lcm
              ,tbgen_iof_lancamento.nracordo     = pr_nracordo
         WHERE tbgen_iof_lancamento.cdcooper   = pr_cdcooper
           AND tbgen_iof_lancamento.nrdconta   = pr_nrdconta
           AND tbgen_iof_lancamento.nrcontrato = pr_nrcontrato
           AND tbgen_iof_lancamento.tpproduto  = pr_tpproduto
           AND tbgen_iof_lancamento.idlautom     IS NULL
  	       AND tbgen_iof_lancamento.dtmvtolt_lcm IS NULL
           AND tbgen_iof_lancamento.cdagenci_lcm IS NULL
           AND tbgen_iof_lancamento.cdbccxlt_lcm IS NULL
           AND tbgen_iof_lancamento.nrdolote_lcm IS NULL
           AND tbgen_iof_lancamento.nrseqdig_lcm IS NULL
           AND tbgen_iof_lancamento.nracordo     IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar a tabela de IOF: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gravar valor do IOF. Rotina TIOF0001.pc_altera_iof. ' || SQLERRM;
  END pc_altera_iof;  
  
  PROCEDURE pc_exclui_iof(pr_cdcooper IN  crapepr.cdcooper%TYPE      --> Cooperativa
                         ,pr_nrdconta IN  crapepr.nrdconta%TYPE      --> Numero da conta
                         ,pr_nrctremp IN  crapepr.nrctremp%TYPE      --> Numero do contrato
                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica
                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  --> Descricao da critica
  BEGIN
    DELETE tbgen_iof_lancamento t
     WHERE t.cdcooper   = pr_cdcooper
       AND t.nrdconta   = pr_nrdconta
       AND t.nrcontrato = pr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao excluir IOF. Rotina TIOF0001.pc_exclui_iof. '||sqlerrm;
  END pc_exclui_iof;
END TIOF0001;
/
