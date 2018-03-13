CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS310" (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Coop conectada
                                                ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) AS           --> Texto de erro/critica encontrada
    /* ............................................................................

     Programa: PC_CRPS310 (antigo Fontes/crps310.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Margarete
     Data    : Maio/2001                       Ultima atualizacao: 13/03/2018

     Dados referentes ao programa:

     Frequencia: Mensal
     Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.

     Alteracoes: 20/08/2001 - Tratar pagamentos dos prejuizos (Margarete).

                 09/11/2001 - Alterar forma dos 12 meses ou mais (Margarete).

                 02/01/2002 - Corrigir prejuizo no mesmo mes (Margarete).

                 14/06/2002 - Incluir prejuizo a +48 meses (Margarete).

                 13/05/2003 - Desprezar os contratos em prejuizo que nao tenham
                              mais saldo (Deborah).

                 16/06/2003 - Eliminar if do CL (Margarete).

                 30/07/2003 - Tratar o desconto de cheques e o restart (Edson).

                 12/08/2003 - Nao considerar bloqueado como disponivel (Deborah).

                 08/09/2003 - Novo tratamento do risco para o desconto de cheques
                              (Edson).

                 04/11/2003 - Substituido comando QUIT pelo RETURN(Mirtes)

                 05/11/2003 - Gerar informacoes(inddocto = 1) Arq.3020(Mirtes)

                 02/12/2003 - Diminuir 1 do campo mes decorrido , se vencimento
                              do contrato cair apos final de mes - dia nao util
                              (Mirtes).

                 27/02/2004 - Novo calculo do risco para os cheques descontados
                              (Edson).

                 19/04/2004 - Alterado para assumir menor risco(Arrasto)
                              (Somente p/3020/3010)(Mirtes)

                 03/05/2004 - Utilizar (novo) campo data credito liquicao risco
                              (Substituido campo crapsld.dtdsdclq pelo
                               campo crapsld.dtrisclq)(Mirtes)

                 07/06/2004 - Gravar risco calculado nos contratos(Mirtes)

                 08/10/2004 - Assumir risco inicial do Rating(se existir)(Mirtes)

                 05/05/2005 - Atualizar nivel de risco/recalculo data atraso
                              quando CL(Mirtes)

                 25/05/2005 - Atualizar campo dsnivris na tabela crapass(CORVU)
                              e atualizado campo cooperativa tab.crapris
                              e tab.crapvri (Mirtes)

                 12/08/2005 - Qdo contrato em prejuizo - obrigatorio o risco H
                              no docto 3010(Mirtes)

                 15/09/2005 - Docto 3010 - prejuizo = risco H(Mirtes)

                 21/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 11/01/2006 - Alterado nivel risco(assumir menor) quando em
                              dia(Mirtes)
                 02/02/2006 - Assumir risco do rating quando atraso(Mirtes)

                 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 20/04/2007 - Substituir craptab "LIMCHEQESP" pelo craplrt (Ze).

                 11/05/2007 - Enxergar os abonos do prejuizo (Magui).

                 02/09/2008 - Alterado para chamar includes/crps310.i (Diego).

                 27/10/2008 - Controlar prejuizo a +48M (Magui).

                 04/04/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                 09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                              o restart (Marcos-Supero)

                 10/10/2013 - Ajuste para controle de criticas (Gabriel).

                 25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

                 13/03/2018 - Ajustes na passagem dos parâmetros para controle paralelismo (Mario-AMcom)

  ..............................................................................*/
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
      -- Erro sem parar a cadeia
      vr_exc_fimprg exception;

      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variável genérica de calendário com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variável para retorno de busca na craptab
      vr_dstextab craptab.dstextab%TYPE;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
      vr_inrestar INTEGER;              --> Indicador de Restart

      -- Valor de arrastro cfme parâmetros
      vr_vlr_arrasto NUMBER;

      vr_cdcritic crapcri.cdcritic%TYPE; --> Codigo da critica
      vr_dscritic VARCHAR2(2000);        --> Descricao da critica

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS310';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS310'
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
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

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código da critica
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;

      -- Chamar função que busca o dstextab para retornar o valor de arrasto
      -- no parâmetro de sistema RISCOBACEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 000);
      -- Se a variavel voltou vazia
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 55;
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      -- Se a informação da primeira coluna não for 2
      IF SUBSTR(vr_dstextab,1,1) <> '2' THEN
        -- Gerar critica
        vr_cdcritic := 411;
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 12
      vr_vlr_arrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
      -- Se o valor estiver null ou deu erro de conversão ou veio vazio
      IF vr_vlr_arrasto IS NULL THEN
        -- Gerar erro
        vr_dscritic := 'Erro ao converter o valor de arrasto do parâmetro RISCOBACEN('||vr_dstextab||')';
        RAISE vr_exc_saida;
      END IF;
      -- Por fim, chamar a 310i, que é a responsável por todo o processo de criação dos riscos
      pc_crps310_i(pr_cdcooper   => pr_cdcooper    --> Coop conectada
                  ,pr_cdagenci   => 0              --> Codigo Agencia 
                  ,pr_idparale   => 0              --> Indicador de processoparalelo
                  ,pr_rw_crapdat => rw_crapdat     --> Rowtype de informações da crapdat
                  ,pr_cdprogra   => vr_cdprogra    --> Codigo programa conectado
                  ,pr_vlarrasto  => vr_vlr_arrasto --> Valor parametrizado para arrasto
                  ,pr_flgresta   => pr_flgresta    --> Flag 0/1 para utilização de restart
                  ,pr_nrctares   => vr_nrctares    --> Conta do ultimo restart
                  ,pr_dsrestar   => vr_dsrestar    --> Descrição genérica de restart
                  ,pr_inrestar   => vr_inrestar    --> Indicador se há ou não restart
                  ,pr_cdcritic   => vr_cdcritic    --> Código de erro encontrado
                  ,pr_dscritic   => vr_dscritic);  --> Descrição de erro encontrado

      -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;

   EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps310;
/
