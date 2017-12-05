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
                                ,pr_dscritic             OUT crapcri.dscritic%TYPE --> Descricao da Critica
                                ,pr_flgimune             OUT BOOLEAN);             --> Possui imunidade tributária
  
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
                                    ,pr_dscritic             OUT crapcri.dscritic%TYPE --> Descricao da Critica
                                    ,pr_flgimune             OUT NUMBER);             --> Possui imunidade tributária (1 - Sim / 0 - Não)
                                    
  PROCEDURE pc_calcula_valor_iof_epr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa referente ao contrato de empréstimos
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta referente ao empréstimo
                                    ,pr_nrctremp IN NUMBER DEFAULT NULL   --> Número do contrato de empréstimo
                                    ,pr_vlemprst IN NUMBER                --> Valor do empréstimo para efeito de cálculo
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                    ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                    ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                    ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                    ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                    ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune OUT BOOLEAN              --> Possui imunidade tributária
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
                                
  PROCEDURE pc_calcula_valor_iof_inclusao(pr_tpproduto            IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                         ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                         ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                         ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                         ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                         ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                         ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                         ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                         ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                         ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                         ,pr_flgimune             OUT BOOLEAN               --> Define se eh Imunidade Tributaria
                                         ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                         ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                         ,pr_vltaxa_iof_principal OUT NUMBER                --> Valor da Taxa do IOF Principal
                                         ,pr_dscritic             OUT crapcri.dscritic%TYPE);
                                         
  PROCEDURE pc_calcula_valor_iof_atraso(pr_tpproduto  IN  PLS_INTEGER           --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                       ,pr_cdcooper   IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_nrdconta   IN  crapass.nrdconta%TYPE --> Número da conta
                                       ,pr_dtmvtolt   IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                       ,pr_vltaxa_iof IN  NUMBER                --> Valor da Taxa do IOF
                                       ,pr_vloperacao IN  NUMBER                --> Valor da operação
                                       ,pr_qtdiaiof   IN  PLS_INTEGER DEFAULT 0 --> Qde dias em atraso (cálculo IOF atraso)
                                       ,pr_flgimune   OUT BOOLEAN      --> Define se eh Imunidade Tributaria
                                       ,pr_vliofcpl   OUT NUMBER       --> Retorno do valor do IOF complementar
                                       ,pr_dscritic   OUT crapcri.dscritic%TYPE);                                      
                                
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
                                ,pr_dscritic             OUT crapcri.dscritic%TYPE --> Descricao da Critica
                                ,pr_flgimune             OUT BOOLEAN) IS           --> Possui imunidade tributária
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
         
      -- Variaveis de Excecao
      vr_dscritic             VARCHAR2(3000);
      vr_dsreturn             VARCHAR2(100);
      vr_exc_erro             EXCEPTION;
      vr_tab_erro             GENE0001.typ_tab_erro;              
    BEGIN
      pr_vliofpri := 0;
      pr_vliofadi := 0;
      pr_vliofcpl := 0;
         
      -- Condicao para verificar se a taxa jah foi carregada
      IF vr_tab_taxas_iof.COUNT = 0 THEN
        -- Buscar todas as taxas
        FOR rw_tabgen_iof IN cr_tabgen_iof (pr_dtmvtolt => pr_dtmvtolt) LOOP
          vr_tab_taxas_iof(rw_tabgen_iof.tpiof) := rw_tabgen_iof.vltaxa_iof;
        END LOOP;
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
        IF pr_tpoperacao = 1 THEN
          -- Cálculo do IOF principal
          pr_vliofpri := pr_vloperacao * vr_vltaxa_iof_principal * vr_qtdiaiof;
          -- Cálculo do IOF adicional
          pr_vliofadi := pr_vloperacao * vr_vltaxa_iof_adicional;        
        -- Pagamento em Atraso  
        ELSIF pr_tpoperacao = 2 THEN
          pr_vliofcpl := pr_vloperacao * NVL(pr_vltaxa_iof_atraso,0) * vr_qtdiaiof;
        END IF;  
      END IF;
         
      -- Condicao para verificar a imunidade tributaria
      IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_flgrvvlr => FALSE
                                         ,pr_cdinsenc => 0
                                         ,pr_vlinsenc => 0
                                         ,pr_flgimune => pr_flgimune
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
      
      --Quem chama deve verificar se é imune
      /*-- Caso o cooperado for Imune devemos retornar o valor do IOF zerado
      IF pr_flgimune THEN
        pr_vliofpri := 0;
        pr_vliofadi := 0;
        pr_vliofcpl := 0;
      END IF;*/
      
      IF pr_flgimune THEN
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
                                    ,pr_dscritic             OUT crapcri.dscritic%TYPE --> Descricao da Critica
                                    ,pr_flgimune             OUT NUMBER) IS           --> Possui imunidade tributária (1 - Sim / 0 - Não)
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
      vr_vltaxa_iof_principal tbgen_iof_taxa.vltaxa_iof%TYPE;
      vr_flgimune BOOLEAN := FALSE;
      
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
                          ,pr_dscritic             => pr_dscritic
                          ,pr_flgimune             => vr_flgimune);
                          
      IF vr_flgimune THEN
        pr_flgimune := 1;
      ELSE
        pr_flgimune := 0;
      END IF;
                          
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
                                    ,pr_dscatbem IN VARCHAR2              --> Descrição da categoria do bem, valor default NULO 
                                    ,pr_cdlcremp IN NUMBER                --> Linha de crédito do empréstimo
                                    ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                    ,pr_qtdiaiof IN NUMBER DEFAULT 0      --> Quantidade de dias em atraso
                                    ,pr_vliofpri IN OUT NUMBER            --> Valor do IOF principal
                                    ,pr_vliofadi IN OUT NUMBER            --> Valor do IOF adicional
                                    ,pr_vliofcpl IN OUT NUMBER            --> Valor do IOF complementar
                                    ,pr_vltaxa_iof_principal OUT NUMBER   --> Valor da Taxa do IOF Principal
                                    ,pr_flgimune OUT BOOLEAN              --> Possui imunidade tributária
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
      
      -- Cursor para dados da PF, PJ, PJ Cooperativa e regime tributário
      CURSOR cr_pessoa(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT a.inpessoa, NVL(j.natjurid,0) natjurid, NVL(j.tpregtrb,0) tpregtrb
         FROM crapass a
         LEFT JOIN crapjur j ON j.cdcooper = a.cdcooper AND j.nrdconta = a.nrdconta
         WHERE a.nrdconta = pr_nrdconta AND a.cdcooper = pr_cdcooper;
       rw_pessoa cr_pessoa%ROWTYPE;  
       
    BEGIN
      OPEN cr_pessoa(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
      FETCH cr_pessoa INTO rw_pessoa;
      
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;
        vr_dscritic := 'Associado não localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_pessoa;
      
      -- Procedure para calcular o valor do IOF
      pc_calcula_valor_iof(pr_tpproduto            => 1 --> 1 - Emprestimo
                          ,pr_tpoperacao           => 1 --> 1 Calculo IOF/Atraso
                          ,pr_cdcooper             => pr_cdcooper
                          ,pr_nrdconta             => pr_nrdconta
                          ,pr_inpessoa             => rw_pessoa.inpessoa
                          ,pr_natjurid             => rw_pessoa.natjurid
                          ,pr_tpregtrb             => rw_pessoa.tpregtrb
                          ,pr_dtmvtolt             => pr_dtmvtolt
                          ,pr_qtdiaiof             => pr_qtdiaiof
                          ,pr_vloperacao           => pr_vlemprst
                          ,pr_vltotalope           => pr_vlemprst
                          ,pr_vltaxa_iof_atraso    => 0
                          ,pr_vliofpri             => pr_vliofpri
                          ,pr_vliofadi             => pr_vliofadi
                          ,pr_vliofcpl             => pr_vliofcpl
                          ,pr_vltaxa_iof_principal => pr_vltaxa_iof_principal
                          ,pr_dscritic             => vr_dscritic
                          ,pr_flgimune             => pr_flgimune);
                          
        IF NVL(vr_dscritic, ' ') <> ' ' THEN
          RAISE vr_exc_erro;
        END IF;
        
        pc_verifica_isencao_iof(pr_cdcooper => pr_cdcooper --> Código da cooperativa referente ao contrato de empréstimos
                               ,pr_nrdconta => pr_nrdconta --> Número da conta referente ao empréstimo
                               ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                               ,pr_dscatbem => pr_dscatbem --> Descrição da categoria do bem, valor default NULO 
                               ,pr_cdlcremp => pr_cdlcremp --> Linha de crédito do empréstimo                                                                        
                               ,pr_vliofpri => pr_vliofpri --> Valor do IOF principal
                               ,pr_vliofadi => pr_vliofadi --> Valor do IOF adicional
                               ,pr_vliofcpl => pr_vliofcpl --> Valor do IOF complementar
                               ,pr_dscritic => vr_dscritic); --> Descrição da crítica
      
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
       
  BEGIN
      
      -- 1 - Aquisição de motos/motonetas/motocicletas
      IF UPPER(pr_dscatbem) = 'MOTO' THEN
        pr_vliofpri := 0;
        pr_vliofcpl := 0;
      END IF;

      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper, pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
         
      -- 2 - Habitação (casa ou apartamento) e linha de crédito for hipoteca
      IF UPPER(pr_dscatbem) IN ('CASA', 'APARTAMENTO') THEN
         IF cr_craplcr%FOUND AND rw_craplcr.tpctrato = 3 THEN
            pr_vliofpri := 0;
            pr_vliofadi := 0;
            pr_vliofcpl := 0;
         END IF;
      END IF;
      
      -- 3 - Linha de crédito isenta de IOF (flgtaiof = 0 ==> isentar cobrança de IOF)
      IF cr_craplcr%FOUND AND rw_craplcr.flgtaiof = 0 THEN
         pr_vliofpri := 0;
         pr_vliofadi := 0;
         -- 3.1 - Caso a linha de crédito for 800, 850 e 900 não isentar cobrança de IOF por atraso
         IF rw_craplcr.cdlcremp NOT IN (800,850,900) THEN
            pr_vliofcpl := 0;
         END IF;
      END IF;
      CLOSE cr_craplcr;

      -- 4 - Outras situações, retornar valores calculados
             
                   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao verificar isenção de IOF. Rotina TIOF0001.pc_verifica_isencao_iof. '||sqlerrm;
    END;
  END pc_verifica_isencao_iof;
                                    
  
  PROCEDURE pc_calcula_valor_iof_inclusao(pr_tpproduto            IN  PLS_INTEGER           --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                         ,pr_cdcooper             IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                         ,pr_nrdconta             IN  crapass.nrdconta%TYPE --> Número da conta
                                         ,pr_inpessoa             IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                         ,pr_natjurid             IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                         ,pr_tpregtrb             IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                         ,pr_dtmvtolt             IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                         ,pr_qtdiaiof             IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                         ,pr_vloperacao           IN  NUMBER                --> Valor da operação
                                         ,pr_vltotalope           IN  NUMBER                --> Valor Total da Operacao
                                         ,pr_flgimune             OUT BOOLEAN               --> Define se eh Imunidade Tributaria
                                         ,pr_vliofpri             OUT NUMBER                --> Retorno do valor do IOF principal
                                         ,pr_vliofadi             OUT NUMBER                --> Retorno do valor do IOF adicional
                                         ,pr_vltaxa_iof_principal OUT NUMBER                --> Valor da Taxa do IOF Principal
                                         ,pr_dscritic             OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
  BEGIN
    /* ..........................................................................
		   Programa : pc_calcula_valor_iof_inclusao
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Outubro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
       
			 Frequencia: Sempre que for solicitado
       Objetivo  :  Calcular o IOF no momento da inclusao da operacao
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
         
      -- Variaveis de Excecao
      vr_dscritic             VARCHAR2(3000);
      vr_dsreturn             VARCHAR2(100);
      vr_exc_erro             EXCEPTION;
      vr_tab_erro             GENE0001.typ_tab_erro;              
    BEGIN
      pr_vliofpri := 0;
      pr_vliofadi := 0;
         
      -- Condicao para verificar se a taxa jah foi carregada
      IF vr_tab_taxas_iof.COUNT = 0 THEN
        -- Buscar todas as taxas
        FOR rw_tabgen_iof IN cr_tabgen_iof (pr_dtmvtolt => pr_dtmvtolt) LOOP
          vr_tab_taxas_iof(rw_tabgen_iof.tpiof) := rw_tabgen_iof.vltaxa_iof;
        END LOOP;
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
      -- Emprestimo
      IF pr_tpproduto IN (1) THEN
        NULL;
           
      -- Adiantamento a Depositante
      ELSIF pr_tpproduto IN (2,3,4,5) THEN
        -- Cálculo do IOF principal
        pr_vliofpri := pr_vloperacao * vr_vltaxa_iof_principal * vr_qtdiaiof;
        -- Cálculo do IOF adicional
        pr_vliofadi := pr_vloperacao * vr_vltaxa_iof_adicional;        
      END IF;
         
      -- Condicao para verificar a imunidade tributaria
      IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_flgrvvlr => FALSE
                                         ,pr_cdinsenc => 0
                                         ,pr_vlinsenc => 0
                                         ,pr_flgimune => pr_flgimune
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
      
      -- Taxa do IOF Principal
      pr_vltaxa_iof_principal := NVL(vr_vltaxa_iof_principal,0);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao calcular IOF. Rotina TIOF0001.pc_calcula_valor_iof_inclusao. '||sqlerrm;
    END;
  END pc_calcula_valor_iof_inclusao;  
  
  PROCEDURE pc_calcula_valor_iof_atraso(pr_tpproduto  IN  PLS_INTEGER           --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                       ,pr_cdcooper   IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_nrdconta   IN  crapass.nrdconta%TYPE --> Número da conta
                                       ,pr_dtmvtolt   IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                       ,pr_vltaxa_iof IN  NUMBER                --> Valor da Taxa do IOF
                                       ,pr_vloperacao IN  NUMBER                --> Valor da operação
                                       ,pr_qtdiaiof   IN  PLS_INTEGER DEFAULT 0 --> Qde dias em atraso (cálculo IOF atraso)
                                       ,pr_flgimune   OUT BOOLEAN               --> Define se eh Imunidade Tributaria
                                       ,pr_vliofcpl   OUT NUMBER                --> Retorno do valor do IOF complementar
                                       ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
  BEGIN
    /* ..........................................................................
		   Programa : pc_calcula_valor_iof_atraso
			 Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
 	     Autor   : Diogo - MoutS
			 Data    : Outubro/2017                    Ultima atualizacao: 
			 Dados referentes ao programa:
			 Frequencia: Sempre que for solicitado
       
			 Objetivo  :  Calcular o IOF no momento da inclusao do atraso da operacao
			
       Alteracoes:  
				 .............................................................................*/
    DECLARE
      vr_qtdiaiof             PLS_INTEGER;
         
      -- Variaveis de Excecao
      vr_dscritic             VARCHAR2(3000);
      vr_dsreturn             VARCHAR2(100);
      vr_exc_erro             EXCEPTION;
      vr_tab_erro             GENE0001.typ_tab_erro;              
    BEGIN
      pr_vliofcpl := 0;
      
      -- Condicao para verificar se a quantidade de dias de calculo de iof é superior a 365 dias
      vr_qtdiaiof := pr_qtdiaiof;
      IF vr_qtdiaiof > 365 THEN
        vr_qtdiaiof := 365;
      END IF;
         
      ----------------------------------------------------------------------------------------------------------------------
      -- Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 
      --                  5-> Adiantamento Depositante)
      ----------------------------------------------------------------------------------------------------------------------
      -- Emprestimo
      IF pr_tpproduto IN (1) THEN
        NULL;
           
      -- Adiantamento a Depositante
      ELSIF pr_tpproduto IN (2,3,4,5) THEN
        pr_vliofcpl := pr_vloperacao * NVL(pr_vltaxa_iof,0) * vr_qtdiaiof;
      END IF;
         
      -- Condicao para verificar a imunidade tributaria
      IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_flgrvvlr => FALSE
                                         ,pr_cdinsenc => 0
                                         ,pr_vlinsenc => 0
                                         ,pr_flgimune => pr_flgimune
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
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao calcular IOF. Rotina TIOF0001.pc_calcula_valor_iof_atraso. '||sqlerrm;
    END;
  END pc_calcula_valor_iof_atraso;
    
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
  
END TIOF0001;
/
