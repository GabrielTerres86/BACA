CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS153 ( pr_cdcooper  IN crapcop.cdcooper%TYPE
                      ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                      ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

    Programa: pc_crps153                       Antigo Fontes/crps153.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odair
    Data    : Marco/96.                       Ultima atualizacao: 25/08/2015

    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de extrato.

    Alteracoes: 18/07/97 - Fazer a cobranca de todos os extratos tarifados(Odair)

                27/08/97 - Alterado para incluir o campo flgproce na criacao
                           do crapavs (Deborah).

                26/09/97 - Nao emitir aviso de taxa de extrato (Odair)

              02/02/2000 - Quando a conta for transferida, debitar na
                          conta nova (Deborah).

              02/10/2001 - Incluir insitext = 5 no for each (Margarete).

              30/12/2003 - NAO ISENTAR mais as pessoas juridicas (Edson).

              29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                          craplcm e crapavs (Diego).

              10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

              16/01/2006 - Nao tarifar contas eliminadas(Mirtes).

              15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

              21/10/2010 - Atualizar operações no TAA para processado (Diego).

              17/12/2010 - Utilizar as tarifas de extrato de balcao ou TAA
                          adequadamente (Evandro).

              28/03/2011 - Utilizar o nro do TAA para diferenciar extrato de
                          C/C do TAA com o de balcao (Evandro).

              20/04/2012 - Criado uma validação para não duplicar tabela de
                          lançamentos em depósito a vista (Guilherme Maba).
                         - Ajuste para controle de restart (David Kistner).

             15/05/2013 - Retirado busca valor tarifa utilizando tabela craptab
                          retirado  (Daniel).   
             
             19/06/2013 - Incluida leitura da craptex para gravacao dos 
                          lancamentos na craplat atraves da b1wgen0153
                          (Tiago).

              20/08/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom)
              
              10/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                         - Incluso regra para verificar utilizacao TAA (Daniel).
               
              25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                           tari0001.pc_cria_lan_auto_tarifa, projeto de 
                           Tarifas-218(Jean Michel) 

    ............................................................................. */
    DECLARE
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

	    -- craptex : Extratos emitidos para fins de tarifação
	    CURSOR cr_craptex (pr_cdcooper IN craptex.cdcooper%TYPE
                        ,pr_dtemiext IN craptex.dtemiext%TYPE
                        ,pr_inisenta IN craptex.inisenta%TYPE) IS
        SELECT craptex.nrdconta
              ,craptex.cdhistor
              ,craptex.vltarifa
              ,craptex.cdfvlcop
              ,craptex.rowid
        FROM craptex
        WHERE craptex.cdcooper = pr_cdcooper
        AND   craptex.dtemiext = pr_dtemiext
        AND   craptex.inisenta = pr_inisenta;
      
      /* Declaração de variáveis */
      rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
      --Tipo de tabela de erro
      vr_tab_erro      GENE0001.typ_tab_erro;
      -- Código do programa
      vr_cdprogra      crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_erro      exception;
      -- Variáveis diversas
      vr_rowid_craplat ROWID;
      --Variaveis de Erro
      vr_cdcritic      crapcri.cdcritic%TYPE := 0;
      vr_dscritic      VARCHAR2(4000);

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS153';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS153'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_erro;
      END IF;
            
      -- Busca todos os extratos emitidos no dia.
      FOR rw_craptex IN cr_craptex (pr_cdcooper => pr_cdcooper
                                   ,pr_dtemiext => rw_crapdat.dtmvtolt
                                   ,pr_inisenta => 0)
      LOOP
                
        -- Criando o lançamento automático da tarifa       
        TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                        ,pr_nrdconta => rw_craptex.nrdconta --Numero da Conta
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Lancamento
                                        ,pr_cdhistor => rw_craptex.cdhistor --Codigo Historico
                                        ,pr_vllanaut => rw_craptex.vltarifa  --Valor lancamento automatico
                                        ,pr_cdoperad => '1' --Codigo Operador
                                        ,pr_cdagenci => 1  --Codigo Agencia
                                        ,pr_cdbccxlt => 100  --Codigo banco caixa
                                        ,pr_nrdolote => 8452  --Numero do lote
                                        ,pr_tpdolote => 1  --Tipo do lote
                                        ,pr_nrdocmto => 0   --Numero do documento
                                        ,pr_nrdctabb => rw_craptex.nrdconta  --Numero da conta
                                        ,pr_nrdctitg => GENE0002.fn_mask(rw_craptex.nrdconta,'99999999') --Numero da conta integracao
                                        ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY') --Codigo pesquisa
                                        ,pr_cdbanchq => 0  --Codigo Banco Cheque
                                        ,pr_cdagechq => 0  --Codigo Agencia Cheque
                                        ,pr_nrctachq => 0  --Numero Conta Cheque
                                        ,pr_flgaviso => FALSE  --Flag aviso
                                        ,pr_tpdaviso => 0  --Tipo aviso
                                        ,pr_cdfvlcop => rw_craptex.cdfvlcop  --Codigo cooperativa
                                        ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                        ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                        ,pr_tab_erro => vr_tab_erro --Tabela retorno erro
                                        ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                        ,pr_dscritic => vr_dscritic);  --Descricao Critica
        IF  vr_dscritic IS NOT NULL THEN
          --Montar mensagem de erro com base na critica
          vr_dscritic := GENE0002.fn_mask(rw_craptex.nrdconta,'zzzz,zz9,9')
                        ||' - '||vr_dscritic;
          --Sair do programa
          RAISE vr_exc_erro;
        END IF;
        
        -- Atualizar o registro da CRAPEXT - Operação no TAA (Renato - Supero)
        BEGIN
          UPDATE crapext 
             SET crapext.insitext  = 5 -- Processado TAA
           WHERE crapext.cdcooper  = pr_cdcooper          -- Cooperativa
             AND crapext.nrdconta  = rw_craptex.nrdconta  -- Conta
             AND crapext.tpextrat  = 1                    -- C/C
             AND crapext.dtreffim  = rw_crapdat.dtmvtolt  -- Data final de referencia do extrato.
             AND crapext.inisenta  = 0                    -- Não Isenta
             AND crapext.nrterfin <> 0;                   -- Numero do Cash
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de erro
            vr_dscritic := GENE0002.fn_mask(rw_craptex.nrdconta,'zzzz,zz9,9')
                           ||' - Erro ao atualizar CRAPEXT: '||SQLERRM;
            -- Sair do programa
            RAISE vr_exc_erro;     
        END;
        
      END LOOP;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      --Salvar informacoes no banco de dados
	    COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
    END;
END pc_crps153;
/

