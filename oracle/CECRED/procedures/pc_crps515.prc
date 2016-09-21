CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS515 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................

       Programa: PC_CRPS515 (Antigo Fontes/crps515.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Diego
       Data    : Setembro/2008                       Ultima atualizacao: 23/02/2016

       Dados referentes ao programa:

       Frequencia: Semanal
       Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.

       Alteracoes:

                 09/05/2013 - Convers�o Progress >> Oracle PLSQL (Marcos-Supero)

                 09/08/2013 - Inclus�o de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)

                 25/11/2013 - Ajustes na passagem dos par�metros para restart (Marcos-Supero)
                 
                 25/01/2016 - Incluido tratamento temporario para chamar rotina alternativa com
                              melhorias de performace apenas para cooperativa 16 SD385161 (Odirlei-AMcom)

                 23/02/2016 - Incluido cooperativa 1 - Viacredi para rodar nova vers�o com ajustes de performace
                              SD385161 (Odirlei-AMcom) 

    ..............................................................................*/

    DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;

      ---------------- Cursores gen�ricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.nrctactl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Vari�vel gen�rica de calend�rio com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Vari�vel para retorno de busca na craptab
      vr_dstextab craptab.dstextab%TYPE;

      -- Vari�veis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> N�mero da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String gen�rica com informa��es para restart
      vr_inrestar INTEGER;              --> Indicador de Restart

      -- Valor de arrastro cfme par�metros
      vr_vlr_arrasto NUMBER;

    BEGIN
      -- C�digo do programa
      vr_cdprogra := 'CRPS515';
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS515'
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descri��o da cr�tica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      -- N�o rodar no mensal
      IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm')  THEN
        -- Tratamento e retorno de valores de restart
        btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra   --> C�digo do programa
                                  ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                  ,pr_nrctares  => vr_nrctares   --> N�mero da conta de restart
                                  ,pr_dsrestar  => vr_dsrestar   --> String gen�rica com informa��es para restart
                                  ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                  ,pr_cdcritic  => pr_cdcritic   --> C�digo da critica
                                  ,pr_des_erro  => pr_dscritic); --> Sa�da de erro
        -- Se encontrou erro, gerar exce��o
        IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Se houver indicador de restart, mas n�o veio conta
        IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
          -- Remover o indicador
          vr_inrestar := 0;
        END IF;
        -- Chamar fun��o que busca o dstextab para retornar o valor de arrasto
        -- no par�metro de sistema RISCOBACEN
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'RISCOBACEN'
                                                 ,pr_tpregist => 000);
        -- Se a variavel voltou vazia
        IF vr_dstextab IS NULL THEN
          -- Buscar descri��o da cr�tica 55
          pr_cdcritic := 55;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 55);
          -- Envio centralizado de log de erro
          RAISE vr_exc_erro;
        END IF;
        -- Por fim, tenta converter o valor de arrasto presente na posi��o 3 at� 9
        vr_vlr_arrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
        -- Se o valor estiver null ou deu erro de convers�o ou veio vazio
        IF vr_vlr_arrasto IS NULL THEN
          -- Gerar erro
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao converter o valor de arrasto do par�metro RISCOBACEN('||vr_dstextab||')';
          RAISE vr_exc_erro;
        END IF;

        -- Por fim, chamar a 310i, que � a respons�vel por todo o processo de cria��o dos riscos
          pc_crps310_i(pr_cdcooper   => pr_cdcooper    --> Coop conectada
                      ,pr_rw_crapdat => rw_crapdat     --> Rowtype de informa��es da crapdat
                      ,pr_cdprogra   => vr_cdprogra    --> Codigo programa conectado
                      ,pr_vlarrasto  => vr_vlr_arrasto --> Valor parametrizado para arrasto
                      ,pr_flgresta   => pr_flgresta    --> Flag 0/1 para utiliza��o de restart
                      ,pr_nrctares   => vr_nrctares    --> Conta do ultimo restart
                      ,pr_dsrestar   => vr_dsrestar    --> Descri��o gen�rica de restart
                      ,pr_inrestar   => vr_inrestar    --> Indicador se h� ou n�o restart
                      ,pr_cdcritic   => pr_cdcritic    --> C�digo de erro encontrado
                      ,pr_dscritic   => pr_dscritic);  --> Descri��o de erro encontrado
        
        -- Retornar nome do m�dulo original, para que tire o action gerado pelo programa chamado acima
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                  ,pr_action => NULL);

        -- Testar sa�da de erro
        IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Chamar rotina para elimina��o do restart para evitarmos
        -- reprocessamento das aplica��es indevidamente
        btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                   ,pr_cdprogra => vr_cdprogra   --> C�digo do programa
                                   ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                   ,pr_des_erro => pr_dscritic); --> Sa�da de erro
        -- Testar sa�da de erro
        IF pr_dscritic IS NOT NULL THEN
          -- Sair do processo
          pr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        -- Processo OK, devemos chamar a fimprg
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit final
        COMMIT;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps515;
/

