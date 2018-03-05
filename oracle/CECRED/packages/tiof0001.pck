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
                                    
                                    
  PROCEDURE pc_calcula_valor_iof_epr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                    ,pr_vltotope in number DEFAULT 0      --> Valor total da operacao
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                    ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                    ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                    ,pr_vliofpri OUT NUMBER               --> Valor do IOF principal
                                    ,pr_vliofadi OUT NUMBER               --> Valor do IOF adicional
                                    ,pr_vliofcpl OUT NUMBER               --> Valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune OUT PLS_INTEGER          --> Possui imunidade tributária
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                                    
                                    
  PROCEDURE pc_verifica_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo                                                                        
                                    ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                    ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                    ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                                
                                
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
                          ,pr_cdcritic       OUT NUMBER                                             --> Código da Crítica
                          ,pr_dscritic       OUT VARCHAR2);

  PROCEDURE pc_busca_taxa_iof(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                             ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                             ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                             ,pr_cdlcremp     IN crawepr.cdlcremp%type default 0
                             ,pr_vlemprst     IN crapepr.vlemprst%TYPE
                             ,pr_vltxiofpri   OUT NUMBER                   --> Taxa de IOF principal
                             ,pr_vltxiofadc   OUT NUMBER                   --> Taxa de IOF adicional
                             ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                             ,pr_dscritic     OUT VARCHAR2);               --> Descrição da Crítica
                          
  PROCEDURE pc_busca_taxa_iof_prg(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                                 ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                                 ,pr_cdlcremp     IN crawepr.cdlcremp%type default 0
                                 ,pr_vlemprst     IN crapepr.vlemprst%TYPE
                                 ,pr_vltxiofpri   OUT VARCHAR2                   --> Taxa de IOF principal
                                 ,pr_vltxiofadc   OUT VARCHAR2                   --> Taxa de IOF adicional
                                 ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                                 ,pr_dscritic     OUT VARCHAR2);            --> Descrição da Crítica
                          
  PROCEDURE pc_carrega_taxas_iof(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data de movimento
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);  --> Descricao da Critica
  
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
/*-- retirar a gravação do loh antes de ir para produção
BTCH0001 .pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                          ,pr_ind_tipo_log => 2 -- Erro tratato
                          ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '||chr(10)
                                           || 'pr_tpproduto='||pr_tpproduto || ' - '||chr(10)
                                           || 'pr_tpoperacao='||pr_tpoperacao || ' - '||chr(10)
                                           || 'pr_cdcooper='||pr_cdcooper || ' - '||chr(10)
                                           || 'pr_nrdconta='||pr_nrdconta || ' - '||chr(10)
                                           || 'pr_inpessoa='||pr_inpessoa || ' - '||chr(10)
                                           || 'pr_natjurid='||pr_natjurid || ' - '||chr(10)
                                           || 'pr_dtmvtolt='||pr_dtmvtolt || ' - '||chr(10)
                                           || 'pr_qtdiaiof='||pr_qtdiaiof || ' - '||chr(10)
                                           || 'pr_vloperacao='||pr_vloperacao || ' - '||chr(10)
                                           || 'pr_vltotalope='||pr_vltotalope || ' - '||chr(10)
                                           || 'pr_vltaxa_iof_atraso='||pr_vltaxa_iof_atraso
                          ,pr_nmarqlog => 'TIOF_CALC_IOF');
-- FIM - retirar a gravação do loh antes de ir para produção*/
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
      /* Cursores */
      CURSOR cr_tabgen_iof(pr_dtmvtolt IN DATE) IS
        SELECT vltaxa_iof, 
               tpiof
          FROM tbgen_iof_taxa
         WHERE pr_dtmvtolt BETWEEN dtinicio_vigencia AND dtfinal_vigencia;

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
      -- Tipo de taxa de IOF (1-Taxa para Simples Nacional/ 2-Taxa IOF Principal PF/ 3-Taxa IOF Principal PJ/ 
      --                      4-Taxa IOF Adicional)
      ----------------------------------------------------------------------------------------------------------------------
      -- Valor Taxa Adicional
      vr_vltaxa_iof_adicional := vr_tab_taxas_iof(4);
      -- Pessoa Fisica
      IF pr_inpessoa = 1 THEN
        vr_vltaxa_iof_principal := vr_tab_taxas_iof(2);
      -- Pessoa Juridica  
      ELSE
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
          
          /*IF NVL(pr_vltaxa_iof_atraso,0) > 0 THEN
             pr_vliofcpl := pr_vloperacao * NVL(pr_vltaxa_iof_atraso,0) * vr_qtdiaiof;
          ELSE
             IF NVL(pr_vltaxa_iof_atraso,0) = 0 THEN --condição para contratos anteriores à publicação da nova lei do IOF
               pr_vliofcpl := 0;
             ELSE
               pr_vliofcpl := pr_vloperacao * NVL(vr_vltaxa_iof_principal,0) * vr_qtdiaiof;
             END IF;
          END IF;*/
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
    
  PROCEDURE pc_calcula_valor_iof_epr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                    ,pr_vltotope in number DEFAULT 0      --> Valor total da operacao
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
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

       Alteracoes:  
				 .............................................................................*/
    DECLARE
      vr_exc_erro EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_vltaxa_iof_atraso NUMBER := null;
      vr_vltotope          number;
      vr_existe_epr        BOOLEAN := FALSE;
      
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
             ,t.dtinsori
       FROM crapepr t
       WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.nrctremp = pr_nrctremp
             AND t.tpemprst IN(1, 2) 
             AND t.dtmvtolt >= TO_DATE('03/04/2017','dd/mm/yyyy'); 
             /*Para operações em atraso do produto Price Pré-fixado, deverá ser cobrado IOF complementar de atraso
             nas operações contratadas após o dia 03 de abril de 2017*/
     rw_crapepr cr_crapepr%ROWTYPE;
       
    -- Cursor de portabilidade
    CURSOR cr_portabilidade(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapcop.nrdconta%TYPE
                           ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
    SELECT nrunico_portabilidade
          ,flgerro_efetivacao
      FROM tbepr_portabilidade
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
    rw_portabilidade cr_portabilidade%ROWTYPE;    
       
    BEGIN
      OPEN cr_pessoa(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_pessoa INTO rw_pessoa;
      
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;
        vr_dscritic := 'Associado não localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_pessoa;
      
      IF pr_nrctremp IS NOT NULL THEN
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
         FETCH cr_crapepr INTO rw_crapepr;
         IF cr_crapepr%FOUND THEN
            vr_existe_epr := TRUE;
            vr_vltaxa_iof_atraso := rw_crapepr.vlaqiofc;
         END IF;
         CLOSE cr_crapepr;  
      END IF;
      
      IF pr_vltotope = 0 then
         vr_vltotope := pr_vlemprst;
      ELSE
         vr_vltotope := pr_vltotope;
      END IF;
      
      -- Procedure para calcular o valor do IOF
      pc_calcula_valor_iof(pr_tpproduto            => 1 --> 1 - Emprestimo
                          ,pr_tpoperacao           => 3 --> 3 Todos: IOF principal, adicional e complementare
                          ,pr_cdcooper             => pr_cdcooper
                          ,pr_nrdconta             => pr_nrdconta
                          ,pr_inpessoa             => rw_pessoa.inpessoa
                          ,pr_natjurid             => rw_pessoa.natjurid
                          ,pr_tpregtrb             => rw_pessoa.tpregtrb
                          ,pr_dtmvtolt             => pr_dtmvtolt
                          ,pr_qtdiaiof             => pr_qtdiaiof
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
        IF rw_crapepr.dtinsori < TO_DATE('04/04/2017','dd/mm/yyyy') THEN
          pr_vliofcpl := 0;
        END IF;
        
        --IF rw_pessoa.inpessoa = 1 THEN
        IF NOT vr_existe_epr THEN
          pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper --> Código da cooperativa referente ao contrato de empréstimos
                                 ,pr_nrdconta => pr_nrdconta --> Número da conta referente ao empréstimo
                                 ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                 ,pr_dscatbem => pr_dscatbem --> Descrição da categoria do bem, valor default NULO 
                                 ,pr_cdlcremp => pr_cdlcremp --> Linha de crédito do empréstimo                                                                        
                                 ,pr_vliofpri => pr_vliofpri --> Valor do IOF principal
                                 ,pr_vliofadi => pr_vliofadi --> Valor do IOF adicional
                                 ,pr_vliofcpl => pr_vliofcpl --> Valor do IOF complementar
                                 ,pr_dscritic => vr_dscritic); --> Descrição da crítica
        END IF;
         
         
        --Consulta o registro na tabela de portabilidade, se tiver portabilidade, não cobra IOF
        OPEN cr_portabilidade(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp);
        FETCH cr_portabilidade INTO rw_portabilidade;
        IF cr_portabilidade%FOUND THEN
           pr_vliofpri := 0;
           pr_vliofadi := 0;
        END IF;
        CLOSE cr_portabilidade;

                               
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
        pr_dscritic := 'Erro ao calcular IOF-EPR. Rotina TIOF0001.pc_calcula_valor_iof_epr. '||sqlerrm;
    END;
      
  END pc_calcula_valor_iof_epr;
    
  PROCEDURE pc_verifica_isencao_iof(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                   ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                   ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                   ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo                                                                        
                                   ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                   ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                   ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
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
			 Objetivo  :  Calcular o valor do IOF, respeitando as regras de isenção do IOF
                 
                 Regras:
                    1 - Aquisição de motos/motonetas/motocicletas
                         valor do IOF principal assumirá zero
                         valor do IOF adicional deve ser calculado 
                         valor do IOF complementar de atraso assumirá zero
                         
                    2 - Habitação (casa ou apartamento) e linha de crédito for hipoteca
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso assumirá zero
                         
                    3 - Linha de crédito isenta de IOF
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso assumirá zero
                         
                    3.1 - Caso a linha de crédito for 800, 850 e 900
                         valor do IOF principal assumirá zero
                         valor do IOF adicional assumirá zero
                         valor do IOF complementar de atraso deverá ser calculado
                         
                    4 - Outras situações
                        Calcular os valores normalmente
			
       Alteracoes:  
				 .............................................................................*/
         
  DECLARE
      vr_exc_erro EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;
      
       -- Cursor da linha de crédito do empréstimo
       CURSOR cr_craplcr(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
         SELECT a.tpctrato, a.flgtaiof, a.cdlcremp
         FROM craplcr a
         WHERE a.cdcooper = pr_cdcooper AND a.cdlcremp = pr_cdlcremp;
       rw_craplcr cr_craplcr%ROWTYPE;
       
       CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT inpessoa
         FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta;
         rw_crapass cr_crapass%ROWTYPE;
       
  BEGIN
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;
      
      -- 1 - Aquisição de motos/motonetas/motocicletas
      IF  UPPER(pr_dscatbem) like '%MOTO%'
      and rw_crapass.inpessoa = 1 THEN
        pr_vliofpri := 0;
      --  pr_vliofcpl := 0;
      END IF;

      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper, pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
         
      -- 2 - Habitação (casa ou apartamento) e linha de crédito for hipoteca
      IF UPPER(pr_dscatbem) like '%CASA%' OR
         UPPER(pr_dscatbem) like '%APARTAMENTO%' THEN
      --IF UPPER(pr_dscatbem) IN ('CASA', 'APARTAMENTO') THEN
         
         IF  cr_craplcr%FOUND AND rw_craplcr.tpctrato = 3 
         AND rw_crapass.inpessoa = 1 THEN
            pr_vliofpri := 0;
            pr_vliofadi := 0;
            pr_vliofcpl := 0;
         END IF;
      END IF;
      
      -- 3 - Linha de crédito isenta de IOF (flgtaiof = 0 ==> isentar cobrança de IOF)
      IF  cr_craplcr%FOUND 
      AND rw_craplcr.flgtaiof = 0 THEN
         pr_vliofpri := 0;
         pr_vliofadi := 0;
         -- 3.1 - Caso a linha de crédito for 800, 850 e 900 não isentar cobrança de IOF por atraso
         IF rw_craplcr.cdlcremp NOT IN (800,850,900,6901) THEN
            pr_vliofcpl := 0;
         END IF;
      END IF;
      CLOSE cr_craplcr;

      -- 4 - Outras situações (retornar valores calculados)
             
                   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao verificar isenção de IOF. Rotina TIOF0001.pc_verifica_isencao_iof. '||sqlerrm;
    END;
  END pc_verifica_isencao_iof;
                                    
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
  BEGIN    

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
                    ,pr_flgimune
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
                    ,pr_flgimune
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
                    ,pr_flgimune
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
    Alteracoes:
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
         WHERE tbgen_iof_lancamento.cdcooper   = pr_cdcooper
           AND tbgen_iof_lancamento.nrdconta   = pr_nrdconta
           AND tbgen_iof_lancamento.nrcontrato = pr_nrcontrato
           AND tbgen_iof_lancamento.tpproduto  = pr_tpproduto
           AND tbgen_iof_lancamento.idlautom     IS NULL
  	       AND tbgen_iof_lancamento.dtmvtolt_lcm IS NULL
           AND tbgen_iof_lancamento.cdagenci_lcm IS NULL
           AND tbgen_iof_lancamento.cdbccxlt_lcm IS NULL
           AND tbgen_iof_lancamento.nrdolote_lcm IS NULL
           AND tbgen_iof_lancamento.nrseqdig_lcm IS NULL;
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
  
  
  PROCEDURE pc_busca_taxa_iof(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                             ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                             ,pr_dtmvtolt     IN  crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                             ,pr_cdlcremp     IN crawepr.cdlcremp%type default 0
                             ,pr_vlemprst     IN crapepr.vlemprst%TYPE
                             ,pr_vltxiofpri   OUT NUMBER                   --> Taxa de IOF principal
                             ,pr_vltxiofadc   OUT NUMBER                   --> Taxa de IOF adicional
                             ,pr_cdcritic     OUT NUMBER                   --> Código da Crítica
                             ,pr_dscritic     OUT VARCHAR2)  IS            --> Descrição da Crítica
  BEGIN
   /* .............................................................................
    Programa: pc_busca_taxa_iof
    Sistema : CRED
    Sigla   : TIOF
    Autor   : Diogo - MoutS
    Data    : Dezembro/2017.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para retornar a taxa do IOF principal e adicional, 
                observando as regras para PF, PJ, PJ cooperativa e linha de 
                crédito do contrato

    Observacao: -----
    Alteracoes:
    ..............................................................................*/
    DECLARE
      -- Tratamento de erros
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(10000);
      vr_exc_erro EXCEPTION;
      vr_dtmvtolt DATE;
      vr_vliofcpl NUMBER;
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
      
     -- Cursor para buscar dados do contrato
      /*CURSOR cr_crawepr (pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE, pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT t.vlemprst
        FROM crawepr t
        WHERE t.cdcooper = pr_cdcooper 
              AND t.nrdconta = pr_nrdconta 
              AND t.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;*/
      
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
      
      -- Busca dados do contrato
      /*OPEN cr_crawepr(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;      
      CLOSE cr_crawepr;*/
      
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
      
      vr_dscatbem := '';
            
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta, pr_nrctremp => pr_nrctremp) LOOP
          vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem || '|';
      END LOOP;

        pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper           --> Código da cooperativa referente ao contrato de empréstimos
                               ,pr_nrdconta => pr_nrdconta           --> Número da conta referente ao empréstimo
                               ,pr_nrctremp => pr_nrctremp           --> Número do contrato de empréstimo
                           ,pr_dscatbem => vr_dscatbem           --> Descrição da categoria do bem, valor default NULO 
                           ,pr_cdlcremp => pr_cdlcremp           --> rw_crapepr.cdlcremp   --> Linha de crédito do empréstimo                                                                        
                               ,pr_vliofpri => pr_vltxiofpri         --> Valor do IOF principal
                               ,pr_vliofadi => pr_vltxiofadc         --> Valor do IOF adicional
                               ,pr_vliofcpl => vr_vliofcpl           --> Valor do IOF complementar
                               ,pr_dscritic => vr_dscritic);         --> Descrição da crítica


      -- Valor do IOF
      IF pr_vltxiofpri <> 0 THEN
        imut0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_dtmvtolt => vr_dtmvtolt,
                                            pr_flgrvvlr => false,
                                            pr_cdinsenc => 0, 
                                            pr_vlinsenc => 0, 
                                            pr_inpessoa => 0, 
                                            pr_nrcpfcgc => 0, 
                                            pr_flgimune => vr_flgimuneB,
                                            pr_dsreturn => vr_dsreturn,
                                            pr_tab_erro => vr_tab_erro );
      end if;
                                             
      if vr_flgimuneB then
         pr_vltxiofpri := 0;
         pr_vltxiofadc := 0;
         vr_vliofcpl   := 0;
      end if;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao buscar taxas do IOF. Rotina TIOF0001.pc_busca_taxa_iof. ' || SQLERRM;
    END;
  END pc_busca_taxa_iof;
  
  
  PROCEDURE pc_busca_taxa_iof_prg(pr_cdcooper	    IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa 
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da Conta Corrente
                                 ,pr_nrctremp     IN NUMBER                    --> Numero do Contrato
                                 ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE DEFAULT NULL    --> Data do movimento para busca na tabela de IOF
                                 ,pr_cdlcremp     IN crawepr.cdlcremp%type default 0
                                 ,pr_vlemprst     IN crapepr.vlemprst%TYPE
                                 ,pr_vltxiofpri   OUT VARCHAR2                   --> Taxa de IOF principal
                                 ,pr_vltxiofadc   OUT VARCHAR2                   --> Taxa de IOF adicional
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
    BEGIN
      
       TIOF0001.pc_busca_taxa_iof(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdlcremp => pr_cdlcremp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_vltxiofpri => vr_vltxiofpri
                                 ,pr_vltxiofadc => vr_vltxiofadc
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);
      
      pr_vltxiofpri := TO_CHAR(vr_vltxiofpri);
      pr_vltxiofadc := TO_CHAR(vr_vltxiofadc);
      
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
