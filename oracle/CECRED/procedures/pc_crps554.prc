CREATE OR REPLACE PROCEDURE CECRED.pc_crps554 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> Codigo do operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps554    (Fontes/crps554.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Gabriel
     Data    : Janeiro/2010                       Ultima Atualizacao: 13/04/2015
         
     Dados referentes ao programa:
         
     Frequencia: Mensal.
     Objetivo  : Realiza a desativa�ao dos Ratings antigos (sem vincula�ao
                 a uma opera�ao de credito) quando nao existir op. de credito
                 ativas.
                  
     Alteracoes: 13/04/2015 - Convers�o Progress -> Oracle (Odirlei-AMcom)

  ............................................................................ */


    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- C�digo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS554';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    CURSOR cr_crapnrc IS
      SELECT crapnrc.nrdconta
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.tpctrrat = 0
         AND crapnrc.nrctrrat = 0
         AND crapnrc.flgativo = 1; --TRUE

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_erro  gene0001.typ_tab_erro;
     
    ------------------------------- VARIAVEIS -------------------------------
    -- Vari�veis auxiliares ao processo
    vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
    vr_inusatab     BOOLEAN;
    vr_flgopera     NUMBER;
    vr_des_reto     VARCHAR2(100);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se n�o encontrar
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

    -- Valida��es iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro � <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    -- Se encontrar
    IF vr_dstextab IS NOT NULL THEN
      -- Se a primeira posi��o do campo
      -- dstextab for diferente de zero
      IF SUBSTR(vr_dstextab,1,1) != '0' THEN
        -- � porque existe tabela parametrizada
        vr_inusatab := TRUE;
      ELSE
        -- N�o existe
        vr_inusatab := FALSE;
      END IF;
    ELSE
      -- N�o existe
      vr_inusatab := FALSE;
    END IF;
    
    FOR rw_crapnrc IN cr_crapnrc LOOP
     
     /******************************************************************************
        Verifica se alguma operacao de Credito esta ativa.
        Limite de credito, descontos e emprestimo.
        Usada para ver se o Rating antigo pode ser desativado.
      ******************************************************************************/
      RATI0001.pc_verifica_operacoes( pr_cdcooper    => pr_cdcooper       --> Codigo Cooperativa
                                     ,pr_cdagenci    => 0                 --> Codigo Agencia
                                     ,pr_nrdcaixa    => 0                 --> Numero Caixa
                                     ,pr_cdoperad    => pr_cdoperad       --> Codigo Operador
                                     ,pr_rw_crapdat  => rw_crapdat        --> Vetor com dados de par�metro (CRAPDAT)                                 
                                     ,pr_nrdconta    => rw_crapnrc.nrdconta  --> Numero da Conta
                                     ,pr_idseqttl    => 1                 --> Sequencia de titularidade da conta
                                     ,pr_idorigem    => 1                 --> Indicador da origem da chamada
                                     ,pr_nmdatela    => vr_cdprogra       --> Nome da tela
                                     ,pr_flgerlog    => 0 /* false */     --> Identificador de gera��o de log
                                     ----- OUT ----
                                     ,pr_flgopera    => vr_flgopera       --> Tabela com os registros processados
                                     ,pr_tab_erro    => vr_tab_erro       --> Tabela de retorno de erro
                                     ,pr_des_reto    => vr_des_reto       --> Ind. de retorno OK/NOK
                                     ) ;
      -- se retornou erro                               
      IF vr_des_reto <> 'OK' THEN
        
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          -- Gravar critica no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_tab_erro(vr_tab_erro.first).dscritic );
        END IF;
        -- buscar proximo
        continue;
      END IF;
      
      
      /* Se tiver operacoes ativas ... proximo */
      IF vr_flgopera = 1  THEN
        continue;
      END IF;  
      
      /* Desativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado. */
      RATI0001.pc_desativa_rating( pr_cdcooper   => pr_cdcooper          --> C�digo da Cooperativa
                                  ,pr_cdagenci   => 0                    --> C�digo da ag�ncia
                                  ,pr_nrdcaixa   => 0               	 --> N�mero do caixa
                                  ,pr_cdoperad   => pr_cdoperad          --> C�digo do operador
                                  ,pr_rw_crapdat => rw_crapdat           --> Vetor com dados de par�metro (CRAPDAT)
                                  ,pr_nrdconta   => rw_crapnrc.nrdconta  --> Conta do associado
                                  ,pr_tpctrrat   => 0                    --> Tipo do Rating
                                  ,pr_nrctrrat   => 0                    --> N�mero do contrato de Rating
                                  ,pr_flgefeti   => 0 /*false*/          --> Flag para efetiva��o ou n�o do Rating
                                  ,pr_idseqttl   => 1                    --> Sequencia de titularidade da conta
                                  ,pr_idorigem   => 1                    --> Indicador da origem da chamada
                                  ,pr_inusatab   => vr_inusatab          --> Indicador de utiliza��o da tabela de juros
                                  ,pr_nmdatela   => vr_cdprogra          --> Nome datela conectada
                                  ,pr_flgerlog   => 'N'                  --> Gerar log S/N
                                  ,pr_des_reto   => vr_des_reto          --> Retorno OK / NOK
                                  ,pr_tab_erro   => vr_tab_erro);        --> Tabela com poss�ves erros
    
      -- se retornou erro                               
      IF vr_des_reto <> 'OK' THEN
        
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          -- Gravar critica no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_tab_erro(vr_tab_erro.first).dscritic );
        END IF;
        -- buscar proximo
        continue;
      END IF;
      
    END LOOP;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informa��es atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps554;
/

