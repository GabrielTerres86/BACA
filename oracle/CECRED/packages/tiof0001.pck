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
  
  PROCEDURE pc_calcula_valor_iof(pr_tpproduto     IN  PLS_INTEGER           --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                ,pr_tpoperacao    IN  PLS_INTEGER           --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                ,pr_cdcooper      IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE --> Número da conta
                                ,pr_inpessoa      IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                ,pr_natjurid      IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                ,pr_tpregtrb      IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                ,pr_dtmvtolt      IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                ,pr_qtdiaiof      IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                ,pr_vloperacao    IN  NUMBER                --> Valor da operação
                                ,pr_vltotalope    IN  NUMBER                --> Valor Total da Operacao
                                ,pr_vliofpri      OUT NUMBER                --> Retorno do valor do IOF principal
                                ,pr_vliofadi      OUT NUMBER                --> Retorno do valor do IOF adicional
                                ,pr_vliofcpl      OUT NUMBER                --> Retorno do valor do IOF complementar
                                ,pr_dscritic      OUT crapcri.dscritic%TYPE);         

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
  PROCEDURE pc_calcula_valor_iof(pr_tpproduto     IN  PLS_INTEGER --> Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante)
                                ,pr_tpoperacao    IN  PLS_INTEGER --> Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso)
                                ,pr_cdcooper      IN  crapcop.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE --> Número da conta
                                ,pr_inpessoa      IN  crapass.inpessoa%TYPE --> Tipo de Pessoa
                                ,pr_natjurid      IN  crapjur.natjurid%TYPE --> Natureza Juridica
                                ,pr_tpregtrb      IN  crapjur.tpregtrb%TYPE --> Tipo de Regime Tributario
                                ,pr_dtmvtolt      IN  crapdat.dtmvtolt%TYPE --> Data do movimento para busca na tabela de IOF
                                ,pr_qtdiaiof      IN  NUMBER DEFAULT 0      --> Qde dias em atraso (cálculo IOF atraso)
                                ,pr_vloperacao    IN  NUMBER                --> Valor da operação
                                ,pr_vltotalope    IN  NUMBER                --> Valor Total da Operacao
                                ,pr_vliofpri      OUT NUMBER   --> Retorno do valor do IOF principal
                                ,pr_vliofadi      OUT NUMBER   --> Retorno do valor do IOF adicional
                                ,pr_vliofcpl      OUT NUMBER   --> Retorno do valor do IOF complementar
                                ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
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
      vr_flgimune             BOOLEAN     := FALSE;
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
      -- Emprestimo
      IF pr_tpproduto IN (1) THEN
        NULL;
           
      -- Adiantamento a Depositante
      ELSIF pr_tpproduto IN (2,3,4,5) THEN
        -- Inclusao da Operacao
        IF pr_tpoperacao = 1 THEN
          -- Cálculo do IOF principal
          pr_vliofpri := pr_vloperacao * vr_vltaxa_iof_principal * vr_qtdiaiof;
          -- Cálculo do IOF adicional
          pr_vliofadi := pr_vloperacao * vr_vltaxa_iof_adicional;        
        -- Pagamento em Atraso  
        ELSIF pr_tpoperacao = 2 THEN
          pr_vliofcpl := pr_vloperacao * vr_vltaxa_iof_principal * vr_qtdiaiof;
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
      
      -- Caso o cooperado for Imune devemos retornar o valor do IOF zerado
      IF vr_flgimune THEN
        pr_vliofpri := 0;
        pr_vliofadi := 0;
        pr_vliofcpl := 0;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
      pr_dscritic := 'Erro ao calcular IOF. Rotina TIOF0001.pc_calcula_valor_iof. '||sqlerrm;
    END;
  END pc_calcula_valor_iof;
  
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
	  vr_flgimune     BOOLEAN     := FALSE;
    vr_flgimune_int PLS_INTEGER := 0;
	
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(10000);
    vr_cdcritic     INTEGER;
	  vr_dsreturn     VARCHAR2(100);
    vr_exc_erro     EXCEPTION;
	  vr_tab_erro     GENE0001.typ_tab_erro;
  BEGIN    
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
	
    IF vr_flgimune THEN
      vr_flgimune_int := 1;
    END IF;	
	
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
                    ,vr_flgimune_int
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
                    ,vr_flgimune_int
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
                    ,vr_flgimune_int
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
