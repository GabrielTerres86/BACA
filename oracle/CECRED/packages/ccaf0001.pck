CREATE OR REPLACE PACKAGE CECRED.CCAF0001 AS

/*..............................................................................

   Programa: CCAF0001                          Antigo: generico/procedures/b1wgen0044.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2009                      Ultima atualizacao: 02/04/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : BO para controles de cheque relacionado ao CAF

   Alteracoes: 23/03/2010 - Corrigido tratamento para liberacao da custodia
                            (Evandro).

               14/07/2010 - Adequacao a nova regra do Banco Central (Evandro).


               10/02/2012 - Criado a procedure verifica_feriado (Adriano).

               05/03/2012 - Criado procedure prox_dia_util (Rafael).

               29/05/2012 - Corrigir verifica_feriado para tratar final de semana
                            que antecede o feriado como data boa para pagto
                            (Guilherme).

               11/07/2013 - Conversao Progress para Oracle (Alisson - AMcom)

               12/11/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (Guilherme Gielow)

               16/01/2014 - Alterada para critica 962 ao nao encontrar PA.
                            (Reinert)

               02/04/2014 - Tratamento para nao receber cheques de determinados
                            Bancos (Elton).
                              
               06/06/2017 - Colocar saida da CCAF0001 para gravar LOG no padrão 
                            Incluido set de modulo
                            Incluidos códigos de critica 1027 e 9999 ( Belli Envolti ) - Ch 665812
                            
..............................................................................*/

  /* Procedure para verificar se a data de vencimento do titulo caiu em um
   feriado e, se este, esta sendo pago no proximo dia util em relacao ao seu vencimento.  */
  PROCEDURE pc_verifica_feriado (pr_cdcooper IN INTEGER  --Codigo da cooperativa
                                ,pr_dtmvtolt IN DATE     --Data para verificacao
                                ,pr_cdagenci IN INTEGER  --Codigo da Agencia
                                ,pr_dtboleto IN DATE     --Data do Titulo
                                ,pr_flgvenci OUT BOOLEAN --Indicador titulo vencido
                                ,pr_cdcritic OUT INTEGER --Codigo do erro
                                ,pr_dscritic OUT VARCHAR2 --Descricao do erro
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro);   --Tabela de erros

  /* Calcular a data de bloqueio de um cheque depositado.*/
  PROCEDURE pc_calcula_bloqueio_cheque (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                       ,pr_dtrefere IN DATE     --Data Deposito Cheque
                                       ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                       ,pr_cdbanchq IN INTEGER  --Codigo Banco cheque
                                       ,pr_cdagechq IN INTEGER  --Codigo Agencia cheque
                                       ,pr_vlcheque IN NUMBER   --Valor Cheque
                                       ,pr_dstextab IN VARCHAR2 --Parametro maiores cheques
                                       ,pr_dtblqchq OUT DATE    --Data do Bloqueio do Cheque
                                       ,pr_cdcritic OUT INTEGER  --Codigo erro
                                       ,pr_dscritic OUT VARCHAR2  --Descricao erro
                                       ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela de erros
                                       
   /* Validar Banco e Agencia */
   PROCEDURE pc_valida_banco_agencia (pr_cdbanchq IN INTEGER  --Codigo Banco cheque
                                     ,pr_cdagechq IN INTEGER  --Codigo Agencia cheque
                                     ,pr_cdcritic OUT INTEGER  --Codigo erro
                                     ,pr_dscritic OUT VARCHAR2  --Descricao erro
                                     ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela de erros                                     

END CCAF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCAF0001 AS

/*..............................................................................

   Programa: CCAF0001                          Antigo: generico/procedures/b1wgen0044.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2009                      Ultima atualizacao: 06/06/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : BO para controles de cheque relacionado ao CAF

   Alteracoes: 23/03/2010 - Corrigido tratamento para liberacao da custodia
                            (Evandro).

               14/07/2010 - Adequacao a nova regra do Banco Central (Evandro).


               10/02/2012 - Criado a procedure verifica_feriado (Adriano).

               05/03/2012 - Criado procedure prox_dia_util (Rafael).

               29/05/2012 - Corrigir verifica_feriado para tratar final de semana
                            que antecede o feriado como data boa para pagto
                            (Guilherme).

               11/07/2013 - Conversao Progress para Oracle (Alisson - AMcom)

               02/04/2014 - Tratamento para nao receber cheques de determinados
                            Bancos (Elton).
                            
               22/10/2014 - Ajuste na procedure pc_verifica_feriado - cursor
                            cr_crapfsf ficava aberto. (Rafael).
                            
		       25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
               06/06/2017 - Colocar saida da CCAF0001 para gravar LOG no padrão 
                            Incluido set de modulo
                            Incluidos códigos de critica 1027 e 9999 ( Belli Envolti ) - Ch 665812

..............................................................................*/

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nmextcop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.cdagenci
          ,crapage.nmresage
          ,crapage.qtddaglf
          ,crapage.cdagepac
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
          ,crapban.cdbccxlt
    FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt;
  rw_crapban cr_crapban%ROWTYPE;

  --Selecionar Informacoes das Agencias
  CURSOR cr_crapagb (pr_cddbanco IN crapagb.cddbanco%TYPE
                    ,pr_cdageban IN crapage.cdagepac%TYPE) IS
    SELECT crapagb.cddbanco
          ,crapagb.cdcidade
          ,crapagb.cdsitagb
    FROM crapagb
    WHERE crapagb.cddbanco = pr_cddbanco
    AND   crapagb.cdageban = pr_cdageban;
  rw_crapagb cr_crapagb%ROWTYPE;

  --Selecionar a cidade da agencia
  CURSOR cr_crapcaf (pr_cdcidade IN crapcaf.cdcidade%type) IS
    SELECT crapcaf.cdcidade
    FROM crapcaf
    WHERE crapcaf.cdcidade = pr_cdcidade;
  rw_crapcaf cr_crapcaf%ROWTYPE;

  --Selecionar Feriado Nacional
  CURSOR cr_crapfer (pr_cdcooper IN crapfer.cdcooper%type
                    ,pr_dtferiad IN crapfer.dtferiad%type) IS
    SELECT crapfer.dtferiad
    FROM crapfer
    WHERE crapfer.cdcooper = pr_cdcooper
    AND   crapfer.dtferiad = pr_dtferiad;
  rw_crapfer cr_crapfer%ROWTYPE;

  -- Selecionar Feriado Municipal
  CURSOR cr_crapfsf (pr_cdcidade IN crapfsf.cdcidade%type
                    ,pr_dtferiad IN crapfsf.dtferiad%type) IS
    SELECT crapfsf.cdcidade
    FROM crapfsf
    WHERE crapfsf.cdcidade = pr_cdcidade
    AND   crapfsf.dtferiad = pr_dtferiad;
  rw_crapfsf cr_crapfsf%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;


  /* Procedure para verificar se a data de vencimento do titulo caiu em um
   feriado e, se este, esta sendo pago no proximo dia util em relacao ao seu vencimento.  */
  PROCEDURE pc_verifica_feriado (pr_cdcooper IN INTEGER  --Codigo da cooperativa
                                ,pr_dtmvtolt IN DATE     --Data para verificacao
                                ,pr_cdagenci IN INTEGER  --Codigo da Agencia
                                ,pr_dtboleto IN DATE     --Data do Titulo
                                ,pr_flgvenci OUT BOOLEAN --Indicador titulo vencido
                                ,pr_cdcritic OUT INTEGER --Codigo do erro
                                ,pr_dscritic OUT VARCHAR2 --Descricao do erro
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS   --Tabela de erros
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_feriado             Antigo: generico/procedures/b1wgen0044.p/verifica_feriado
  --  Sistema  : Procedure para verificar se a data de pagto do titulo eh feriado
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar se a data de pagto do titulo eh feriado

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      /* Verifica a cidade da agencia */
      CURSOR cr_crapcaf (pr_cdcidade IN crapagb.cdcidade%TYPE) IS
        SELECT crapcaf.cdcidade
        FROM  crapcaf
        WHERE crapcaf.cdcidade = pr_cdcidade;
      rw_crapcaf cr_crapcaf%ROWTYPE;

      --Selecionar feriados
      CURSOR cr_crapfer (pr_cdcooper IN crapfer.cdcooper%TYPE
                        ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT crapfer.dtferiad
        FROM crapfer
        WHERE crapfer.cdcooper = pr_cdcooper
        AND   crapfer.dtferiad = pr_dtferiad;
      rw_crapfer cr_crapfer%ROWTYPE;

      --Selecionar feriados sistema financeiro
      CURSOR cr_crapfsf (pr_cdcidade IN crapfsf.cdcidade%TYPE
                        ,pr_dtferiad IN crapfsf.dtferiad%TYPE) IS
        SELECT crapfsf.dtferiad
        FROM crapfsf
        WHERE crapfsf.cdcidade = pr_cdcidade
        AND   crapfsf.dtferiad = pr_dtferiad;
      rw_crapfsf cr_crapfsf%ROWTYPE;

      --Variaveis Locais
      vr_proxutil  DATE;
      vr_dtferiado DATE;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      --Tipo de Dados para cursor cooperativa
      rw_crabcop  cr_crapcop%ROWTYPE;
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 665812 06/06/2017
		  GENE0001.pc_set_modulo(pr_module => 'CCAF0001', pr_action => 'CCAF0001.pc_verifica_feriado');
      
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Proximo dia util
      vr_proxutil:= pr_dtboleto + 1;
      --Flag vencida
      pr_flgvenci:= TRUE;

      /* Verifica a cooperativa */
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 794
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Retornar erro
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      /* Verifica o PAC */
      OPEN cr_crapage (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_cdagenci => pr_cdagenci);
      --Posicionar no proximo registro
      FETCH cr_crapage INTO rw_crapage;
      --Se nao encontrar
      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;
        vr_dscritic:= NULL;
        --gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => 962
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapage;
      --Verificar agencia que esta executando
      IF rw_crapage.cdagenci NOT IN (90,91) AND rw_crapage.cdagepac <> 0 THEN
        /* Verifica a data do sistema */
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se n¿o encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haver¿ raise
          CLOSE BTCH0001.cr_crapdat;
          --gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => 0
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => 1
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        /* Busca o registro do banco */
        OPEN cr_crapban (pr_cdbccxlt => rw_crapcop.cdbcoctl);
        --Posicionar no proximo registro
        FETCH cr_crapban INTO rw_crapban;
        --Fechar Cursor
        CLOSE cr_crapban;
        --Selecionar Agencias
        OPEN cr_crapagb (pr_cddbanco => rw_crapban.cdbccxlt
                        ,pr_cdageban => rw_crapage.cdagepac);
        --Posicionar no primeiro registro
        FETCH cr_crapagb INTO rw_crapagb;
        --Fechar Cursor
        CLOSE cr_crapagb;
        /* Verifica a cidade da agencia */
        OPEN cr_crapcaf (pr_cdcidade => rw_crapagb.cdcidade);
        --Posicionar no proximo registro
        FETCH cr_crapcaf INTO rw_crapcaf;
        --Se nao encontrar
        IF cr_crapcaf%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcaf;
          --Mensagem erro
          vr_dscritic:= 'Cidade nao cadastrada.';
          --gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => 0
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcaf;

        --Loop procurando por feriados
        WHILE TRUE LOOP
          --Verificar se o dia eh feriado
          vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_proxutil
                                                    ,pr_tipo     => 'P');
          --Selecionar feriados sistema financeiro
          OPEN cr_crapfsf (pr_cdcidade => rw_crapcaf.cdcidade
                          ,pr_dtferiad => vr_dtferiado);
          --Posicionar no proximo registro
          FETCH cr_crapfsf INTO rw_crapfsf;
          --Se nao encontrar
          IF cr_crapfsf%FOUND THEN
            --Vencida recebe false
            vr_proxutil:= vr_proxutil+1;
          ELSE
            
            IF cr_crapfsf%ISOPEN THEN 
               CLOSE cr_crapfsf;
            END IF;
            
            EXIT;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapfsf;
        END LOOP;

        --Se a data informada igual proximo dia util
        IF pr_dtmvtolt = vr_dtferiado THEN
          --Se for final de semana
          IF To_Number(To_Char(pr_dtboleto,'D')) IN (1,7) THEN
            --Vencida recebe false
            pr_flgvenci:= FALSE;
          ELSE
            --Selecionar feriados
            OPEN cr_crapfer (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_dtferiad => pr_dtboleto);
            --Posicionar no proximo registro
            FETCH cr_crapfer INTO rw_crapfer;
            --Se nao encontrar
            IF cr_crapfer%FOUND THEN
              --Vencida recebe false
              pr_flgvenci:= FALSE;
            ELSE
              --Selecionar feriados sistema financeiro
              OPEN cr_crapfsf (pr_cdcidade => rw_crapcaf.cdcidade
                              ,pr_dtferiad => pr_dtboleto);
              --Posicionar no proximo registro
              FETCH cr_crapfsf INTO rw_crapfsf;
              --Se nao encontrar
              IF cr_crapfsf%FOUND THEN
                --Vencida recebe false
                pr_flgvenci:= FALSE;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapfsf;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapfer;
          END IF;
        ELSE
          --Vencida recebe true
          pr_flgvenci:= TRUE;
        END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CCAF0001.pc_verifica_feriado. '||SQLERRM;
    END;
  END pc_verifica_feriado;

  /* Validar Banco e Agencia */
  PROCEDURE pc_valida_banco_agencia (pr_cdbanchq IN INTEGER  --Codigo Banco cheque
                                    ,pr_cdagechq IN INTEGER  --Codigo Agencia cheque
                                    ,pr_cdcritic OUT INTEGER  --Codigo erro
                                    ,pr_dscritic OUT VARCHAR2  --Descricao erro
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de erros
  /* .............................................................................

   Programa: pc_valida_banco_agencia            Antigo: b1wgen0044.p --> valida_banco_agencia
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : WEB
   Autor   : David
   Data    : Maio/2013.                        Ultima atualizacao: 22/06/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Verificar o banco e agencia do cheque.

   Alteracoes: 09/08/2013 - Conversao Progress >> Oracle (PLSQL) (Alisson-Amcom)

               20/03/2014 - Incluido upper na leitura do campo rw_crapagb.cdsitagb (Odirlei-AMcom)

               22/06/2016 - Adicionado dscritic = 'Nenhuma agencia ativa no banco.' para quando
                            nao encontrar agencias ativas para o Banco. A mensagem esta no Progress
                            e nao foi convertida no Oracle (Douglas - 417655)
               
               06/06/2017 - Colocar saida da CCAF0001 para gravar LOG no padrão 
                            Incluido set de modulo
                            Incluidos códigos de critica 1027 e 9999 ( Belli Envolti ) - Ch 665812
                            
  ............................................................................. */
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapagb_ativa (pr_cddbanco IN crapagb.cddbanco%type) IS
        SELECT crapagb.cdsitagb
        FROM crapagb crapagb
        WHERE crapagb.cddbanco = pr_cddbanco
        AND upper(crapagb.cdsitagb) = 'S';
      rw_crapagb_ativa cr_crapagb_ativa%ROWTYPE;

      --Variaveis de erro
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 665812 06/06/2017
		  GENE0001.pc_set_modulo(pr_module => 'CCAF0001', pr_action => 'CCAF0001.pc_valida_banco_agencia');
      
      --Inicializar retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      /* Verifica o banco do cheque */
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbanchq);
      --Posicionar no primeiro registro
      FETCH cr_crapban INTO rw_crapban;
      --Se Nao encontrou
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        --Gerar erro
        pr_cdcritic := 57;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;

      -- Tratamento para nao receber cheques de determinados bancos
      IF rw_crapban.cdbccxlt IN (8,347,353,356/** Banco Real **/,409,453) THEN
        --Gerar erro
        pr_cdcritic := 57;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;


      /* Verifica a agencia do cheque */
      OPEN cr_crapagb (pr_cddbanco => rw_crapban.cdbccxlt
                      ,pr_cdageban => pr_cdagechq);
      --Posicionar no primeiro registro
      FETCH cr_crapagb INTO rw_crapagb;
      --Se Nao encontrou
      IF cr_crapagb%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapagb;
        --Gerar erro
                                     
        pr_cdcritic := 15;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapagb;

      /* Verifica se a agencia esta ativa */
      IF upper(rw_crapagb.cdsitagb) <> 'S' THEN
        /* Verifica se o banco possui alguma agencia ATIVA */
        OPEN cr_crapagb_ativa (pr_cddbanco => rw_crapban.cdbccxlt);
        --Posicionar no primeiro registro
        FETCH cr_crapagb_ativa INTO rw_crapagb_ativa;
        --Se Nao encontrou
        IF cr_crapagb_ativa%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapagb_ativa;
          -- Mensagem que esta no Progress e nao foi convertida
          -- vr_dscritic := 'Nenhuma agencia ativa no banco.';
          
          pr_cdcritic := 1027;
                    
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapagb_ativa;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        GENE0001.pc_gera_erro(pr_cdcooper => 0
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 -- Sequencia 
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
        pr_dscritic := vr_dscritic;
                             
      WHEN OTHERS THEN
          
        pr_cdcritic := 9999;
        
        GENE0001.pc_gera_erro(pr_cdcooper => 0
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 -- Sequencia 
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
           
        pr_dscritic := vr_dscritic || ' CCAF0001.pc_valida_banco_agencia - ' ||sqlerrm;
    END;
  END pc_valida_banco_agencia;


  /* Calcular a data de bloqueio de um cheque depositado.*/
  PROCEDURE pc_calcula_bloqueio_cheque (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                       ,pr_dtrefere IN DATE     --Data Deposito Cheque
                                       ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                       ,pr_cdbanchq IN INTEGER  --Codigo Banco cheque
                                       ,pr_cdagechq IN INTEGER  --Codigo Agencia cheque
                                       ,pr_vlcheque IN NUMBER   --Valor Cheque
                                       ,pr_dstextab IN VARCHAR2 --Parametro maiores cheques
                                       ,pr_dtblqchq OUT DATE    --Data do Bloqueio do Cheque
                                       ,pr_cdcritic OUT INTEGER  --Codigo erro
                                       ,pr_dscritic OUT VARCHAR2  --Descricao erro
                                       ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de erros
  /* .............................................................................

   Programa: pc_calcula_bloqueio_cheque            Antigo: b1wgen0044.p --> calcula_bloqueio_cheque
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : WEB
   Autor   : David
   Data    : Maio/2013.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Calcular a data de bloqueio de um cheque depositado.

       Observacao: 1- A liberacao do cheque para credito em conta do associado
                      acontece no proximo dia util em relacao a data que for
                      retornada por esta procedure.

                   2- O dia 31/12 eh considerado dia util normalmente, porem
                      no sistema ele fica como feriado durante o ano e eh
                      liberado somente dia 30/12 a noite para evitar que
                      sejam lancados descontos de cheques, etc para esta
                      data durante o ano.

                   3- Conforme acordado, caso a agencia do cheque esteja
                      INATIVA, sera verificado se o BANCO possuir alguma
                      agencia ATIVA, caso isso seja verdadeiro o tratamento
                      sera como se a agencia do cheque estivesse ATIVA e
                      sera acrescentado 1 dia ao prazo de bloqueio.
					  
				   4-Verificação de agência inativa adicionar 1 dia ao prazo 
				      de bloqueio removida, de acordo com os ajustes do 'P367
					  Compe sessão única' e ocorrência RITM0014144.					  

   Alteracoes: 09/08/2013 - Convers¿o Progress >> Oracle (PLSQL) (Alisson-Amcom)

               20/03/2014 - Incluido upper na leitura do campo rw_crapagb.cdsitagb (Odirlei-AMcom)

               06/06/2017 - Colocar saida da CCAF0001 para gravar LOG no padrão 
                            Incluido set de modulo
                            Incluido código de critica 9999 ( Belli Envolti ) - Ch 665812

  ............................................................................. */
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_vlcheque NUMBER;
      vr_qtdiasut INTEGER;
      vr_tmp_qtdiasut INTEGER;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      
      -- Chamado 665812 06/06/2017 
      vr_ja_tem_tab_erro VARCHAR2(3) := null;
      
    BEGIN
	    -- Incluir nome do módulo logado - Chamado 665812 06/06/2017
		  GENE0001.pc_set_modulo(pr_module => 'CCAF0001', pr_action => 'CCAF0001.pc_calcula_bloqueio_cheque');
      
      --Inicializar retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Validacao dos parametros */

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se n¿o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapcop;
        --Mensagem de erro
        pr_cdcritic:= 794;
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      /* Verifica o PAC */
      --Selecionar agencia 1
      OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                      ,pr_cdagenci => pr_cdagenci);
      --Posicionar no proximo registro
      FETCH cr_crapage INTO rw_crapage;
      --Se nao encontrar
      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;
        --Mensagem de erro
        pr_cdcritic:= 962;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapage;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        --Mensagem de erro
        pr_cdcritic:= 1;
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      /* Verifica o valor de cheques maiores */
      IF pr_dstextab IS NULL THEN
        vr_vlcheque:= 1;
      ELSE
        vr_vlcheque:= GENE0002.fn_char_para_number(SUBSTR(pr_dstextab,1,15));
      END IF;

      /* Validacao do cheque */
      IF pr_vlcheque <= 0 THEN
        --Mensagem de erro
        pr_cdcritic:= 269;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Validacao generica de Banco e Agencia */
      CCAF0001.pc_valida_banco_agencia (pr_cdbanchq => pr_cdbanchq  --Codigo Banco cheque
                                       ,pr_cdagechq => pr_cdagechq  --Codigo Agencia cheque
                                       ,pr_cdcritic => vr_cdcritic  --Codigo erro
                                       ,pr_dscritic => vr_dscritic  --Descricao erro
                                       ,pr_tab_erro => pr_tab_erro); --Tabela de erros;
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_ja_tem_tab_erro := 'sim';
        pr_dscritic:= vr_dscritic;
        pr_cdcritic:= vr_cdcritic;
        RAISE vr_exc_erro;
      END IF;

      /* Busca o registro do banco */
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbanchq);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;

      /* Busca o registro da agencia */
      OPEN cr_crapagb (pr_cddbanco => rw_crapban.cdbccxlt
                      ,pr_cdageban => pr_cdagechq);
      --Posicionar no proximo registro
      FETCH cr_crapagb INTO rw_crapagb;
      --Se nao encontrar
      IF cr_crapagb%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapagb;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapagb;

      /* Verifica a cidade da agencia */
      OPEN cr_crapcaf (pr_cdcidade => rw_crapagb.cdcidade);
      --Posicionar no proximo registro
      FETCH cr_crapcaf INTO rw_crapcaf;
      --Se nao encontrar
      IF cr_crapcaf%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcaf;
        --Mensagem de erro
        vr_dscritic:= 'Cidade nao cadastrada.';
        pr_cdcritic:= 0;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcaf;

      /* Calcula da quantidade de dias uteis para bloqueio */
      IF pr_vlcheque >= vr_vlcheque THEN
        vr_qtdiasut:= 1;
      ELSE
        vr_qtdiasut:= 2;
      END IF;
      /* Quando a agencia do cheque estiver INATIVA, acrescenta 1 dia ao bloqueio
       para minimizar o risco operacional */
	  /* Verificação removida de acordo com os ajustes do 
	   P367 - Compe sessão única e ocorrência RITM0014144 
      IF upper(rw_crapagb.cdsitagb) <> 'S' THEN
        vr_qtdiasut:= vr_qtdiasut + 1;
      END IF;*/
	  
      /* Calculo da data de liberacao */
      /* 1- Para pagamento no caixa, o lancamento ocorre on-line e comeca a contar os
          dias a partir do dia seguinte (dtmvtopr)

       2- Para a custodia, o lancamento ocorre para o dia seguinte (dtmvtopr) entao
          comeca a contar no proximo dia util depois da data informada */
      IF pr_dtrefere = rw_crapdat.dtmvtolt THEN
        --Data liberacao bloqueio
        pr_dtblqchq:= rw_crapdat.dtmvtopr;
      ELSE
        /* Proximo dia util em relacao a data informada */
        pr_dtblqchq:= pr_dtrefere + 1;
        --Verificar o proximo dia util
        pr_dtblqchq:= GENE0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper --> Cooperativa conectada
                                                 ,pr_dtmvtolt => pr_dtblqchq         --> Data do movimento
                                                 ,pr_tipo     => 'P');               --> Tipo de busca (P = pr¿ximo, A = anterior)
      END IF;
      --Inicializa dias uteis
      vr_tmp_qtdiasut:= 1;

      WHILE TRUE LOOP
        --verifica se eh final semana
        IF To_Number(To_Char(pr_dtblqchq,'D')) IN (1,7) THEN
          --incrementa dia
          pr_dtblqchq:= pr_dtblqchq + 1;
        ELSE
          /* Feriado Nacional */
          OPEN cr_crapfer (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_dtferiad => pr_dtblqchq);
          --Posicionar no proximo registro
          FETCH cr_crapfer INTO rw_crapfer;
          --Se encontrar
          IF cr_crapfer%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crapfer;
            /* Considera o dia 31/12 como dia normal conforme observacao numero 2 desta procedure */
            IF To_Number(TO_CHAR(pr_dtblqchq,'DDMM')) != 3112 THEN
              --Incrementar + 1 dia
              pr_dtblqchq:= pr_dtblqchq + 1;
              --Proxima iteracao loop
              CONTINUE;
            END IF;
          END IF;
          --Fechar Cursor
          IF cr_crapfer%ISOPEN THEN
            CLOSE cr_crapfer;
          END IF;

          /* Feriado Municipal */
          OPEN cr_crapfsf (pr_cdcidade => rw_crapcaf.cdcidade
                          ,pr_dtferiad => pr_dtblqchq);
          --Posicionar no proximo registro
          FETCH cr_crapfsf INTO rw_crapfsf;
          --Se encontrar
          IF cr_crapfsf%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crapfsf;
            --Incrementar dia
            pr_dtblqchq:= pr_dtblqchq + 1;
            --Proxima iteracao loop
            CONTINUE;
          END IF;
          --Fechar Cursor
          IF cr_crapfsf%ISOPEN THEN
            CLOSE cr_crapfsf;
          END IF;

          /* Verifica se ja "pulou" a quantidade de dias uteis de bloqueio */
          IF vr_tmp_qtdiasut = vr_qtdiasut THEN
            EXIT;
          END IF;

          /* Contabiliza +1 dia */
          vr_tmp_qtdiasut:= vr_tmp_qtdiasut + 1;
          pr_dtblqchq:= pr_dtblqchq + 1;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        if vr_ja_tem_tab_erro is null then
            GENE0001.pc_gera_erro(
                              pr_cdcooper => 0
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
             pr_dscritic := vr_dscritic;
          
        end if;
                 
      WHEN OTHERS THEN
        
        pr_cdcritic := 9999;
                
        GENE0001.pc_gera_erro(pr_cdcooper => 0
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 -- Sequencia 
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                                            
        pr_dscritic:= vr_dscritic || ' CCAF0001.pc_calcula_bloqueio_cheque - '  || sqlerrm;
    END;
  END pc_calcula_bloqueio_cheque;

END CCAF0001;
/
