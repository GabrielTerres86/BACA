CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS280 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
  /* ..........................................................................

   Programa: pc_crps280 (Antigo Fontes/crps280.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Fevereiro/2000                      Ultima atualizacao: 16/01/2018

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 4.
               Emite relatorio da provisao para creditos de liquidacao duvidosa (227).

   Alteracoes: 24/03/2000 - Acerto para imprimir os totais mesmo quando nao
                            houver emprestimos em atraso. (Deborah).

               17/11/2000 - Ajuste para auditoria (Edson).

               28/12/2000 - Acerto no total em atraso - limitar ao saldo
                            devedor (Deborah).

               11/11/2003 - Alterado para enviar por email o relatorio gerado
                            (Edson).

               19/11/2003 - Calcula Provisao pelo Risco - Arq.crapris(Mirtes)

               20/05/2004 - Gerar relatorio para  Auditoria(354). Todos os
                            contratos(e nao apenas os em atraso)(Mirtes).

               03/05/2005 - Alterado numero de copias para impressao na
                            Viacredi (Diego).

               02/06/2005 - Gera arq.Texto(Daniela) com contratos com nivel
                            de risco <> 2("A") e em dia(Mirtes)

               19/07/2005 - Incluido PAC no arquivo texto(Mirtes)

               30/08/2005 - Incluido no arquivo texto  - flag indicando se
                            Rating pode ou nao ser atualizado(Mirtes)

               03/02/2006 - Trocados os valores da coluna "Parcela" com a
                            coluna "Saldo Devedor" e incluida a coluna "Risco"
                            (Evandro).

               08/02/2006 - Separado o programa em uma include (crps280.i) para
                            poder ser chamado tambem pela tela RISCO (Evandro).

               16/02/2006 - Criadas variaveis p/ listagem de Riscos por PAC
                            (Diego).

               04/12/2009 - Retirar o nao uso mais do buffer crabass e
                            aux_recid (Gabriel).

               09/08/2010 - Incluido campo "qtatraso" na Temp-Table w-crapris
                            (Elton).

               25/08/2010 - Inclusao das variaveis aux_rel1725, aux_rel1726,
                            aux_rel1725_v, aux_rel1726_v. Devido a alteracao
                            na includes crps280.i (Adriano).

               27/08/2010 - Inserir na crapbnd total de provisoes e dividas sem
                            prejuizo. Tarefa 34667. (Henrique)

               14/05/2012 - Incluido tratamento de LOCK na atualizacao do
                            registro da tabela crapbnd. (Fabricio)

               09/10/2012 - Novas variaveis para ajustar os relatorios 227
                            e 354 - Desc. Tit. Cob. Registrada. (Rafael)

               11/03/2013 - Conversão Progress >> Oracle PL-Sql (Marcos-Supero)

               26/08/2013 - Passagem do diretório da cooperativa para
                            a pc_crps280_i (Marcos-Supero)

               10/10/2013 - Ajuste para controle de criticas (Gabriel).

               07/03/2014 - Manutenção 201402 (Edison-Amcom)
			   
     			     25/06/2014 - Incluso processo de exclusão registros crapris e 
			                      crapvri SoftDesk 137892 (Daniel)
                            
               15/04/2015 - Projeto de separação contábeis de PF e PJ.
                            (Andre Santos - SUPERO)

               16/01/2018 - Alteração procedimento INSERT/UPDATE na tabela CRAPBND
                            Melhorias sustentação
                            Retirada exception vr_exc_fimprg, pois a mesma não é utilizada
                            (Ana - Envolti - Chamado 822997)

............................................................................. */

   DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros para parar a cadeia
      vr_exc_saida exception;
      -- Erro em chamadas da pc_gera_erro
      --vr_des_reto VARCHAR2(3);
      -- Codigo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      -- Descricao da critica
      vr_dscritic VARCHAR2(2000);

      --vr_tab_erro GENE0001.typ_tab_erro;

      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrctactl
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Valores para retorno da crps280.i
      vr_vltotprv NUMBER(14,2); --> Total acumulado de provisão
      vr_vltotdiv NUMBER(14,2); --> Total acumulado de dívida
      
      -- Variaveis verificação exclusão de registros
      vr_datautil DATE;
      vr_delete   BOOLEAN;
      vr_dtmvtolt DATE;

	    --> Controla log proc_batch, atualizando parâmetros conforme tipo de ocorrência
      PROCEDURE pc_gera_log(pr_cdcooper    IN crapcop.cdcooper%TYPE,
                          pr_dstiplog      IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                          pr_dscritic      IN VARCHAR2 DEFAULT NULL,
                          pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,
                          pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0,
                          pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS

      -----------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_gera_log
      --  Sistema  : Rotina para gravar logs em tabelas
      --  Sigla    : CRED
      --  Autor    : Ana Lúcia E. Volles - Envolti
      --  Data     : Janeiro/2018          Ultima atualizacao: 16/01/2018
      --  Chamado  : 822997
      --
      -- Dados referentes ao programa:
      -- Frequencia: Rotina executada em qualquer frequencia.
      -- Objetivo  : Controla gravação de log em tabelas.
      --
      -- Alteracoes:  
      --             
      ------------------------------------------------------------------------------------------------------------   
    BEGIN     
      --> Controlar geração de log de execução dos jobs
      --Como executa na cadeira, utiliza pc_gera_log_batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                                ,pr_ind_tipo_log  => pr_ind_tipo_log
                                ,pr_nmarqlog      => 'proc_batch.log'                 
                                ,pr_dstiplog      => NVL(pr_dstiplog,'E')             
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- batch                       
                                ,pr_cdcriticidade => pr_cdcriticidade                      
                                ,pr_cdmensagem    => pr_cdmensagem                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                    || vr_cdprogra || ' --> '|| pr_dscritic);
    EXCEPTION  
      WHEN OTHERS THEN  
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
    END pc_gera_log;
    --

    ---------------------------------------
    -- Inicio Bloco Principal pc_crps280
    ---------------------------------------
    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS280';

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS280'
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
      
      -- Variavel de controle se registros crapris e crapvri serão deletados
      vr_delete   := TRUE;
        
      -- Variavel auxiliar para ser utilizada na bisca data util anterior.
      vr_dtmvtolt := rw_crapdat.dtmvtolt - 1;
        
      -- Função para retornar dia útil anterior a data base
      vr_datautil  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,         -- Cooperativa
                                                  pr_dtmvtolt  => vr_dtmvtolt,         -- Data de referencia
                                                  pr_tipo      => 'A',                 -- Se não for dia útil, retorna primeiro dia útil anterior
                                                  pr_feriado   => TRUE,                -- Considerar feriados,
                                                  pr_excultdia => TRUE);               -- Considerar 31/12

      -- Caso mes da data util for diferente do mes da data de movimento entao é primeiro
      -- movimento do mes, nao exclui registro (que são os registros criados na mensal).                                               
      IF to_char(vr_datautil,'MM') <> to_char(rw_crapdat.dtmvtolt,'MM') THEN  
         vr_delete := FALSE;
      END IF;

      -- Deve eliminar registros caso vr_delete VERDADEIRO
      IF vr_delete THEN
         ---- Efetuar a limpeza do registro semanal ---
         --- Primeiramente dos vencimentos do risco ---
         BEGIN
            DELETE
              FROM crapvri
             WHERE cdcooper = pr_cdcooper
               AND dtrefere = vr_datautil; -- rw_crapdat.dtmvtolt;
         EXCEPTION
            WHEN OTHERS THEN
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapvri '||
                             'com cdcooper:'||pr_cdcooper||
                             ', dtrefere:'  ||vr_datautil||
                             '. '||sqlerrm;

               --Inclusão na tabela de erros Oracle - Chamado 822997
               CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
               RAISE vr_exc_saida;
         END;
         --- Após eliminar os riscos em si ---
         BEGIN
            DELETE
              FROM crapris
             WHERE cdcooper = pr_cdcooper
               AND dtrefere = vr_datautil; -- rw_crapdat.dtmvtolt;
         EXCEPTION
            WHEN OTHERS THEN
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapris '||
                             'com cdcooper:'||pr_cdcooper||
                             ', dtrefere:'  ||vr_datautil||
                             '. '||sqlerrm;

               --Inclusão na tabela de erros Oracle - Chamado 822997
               CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
               RAISE vr_exc_saida;
         END;
      END IF;

      -- Chamar a rotina crps280_i (Antiga includes/crps280.i)
      pc_crps280_i(pr_cdcooper   => pr_cdcooper         --> Coop. conectada
                  ,pr_rw_crapdat => rw_crapdat          --> Vetor com calendário
                  ,pr_dtrefere   => rw_crapdat.dtultdia --> Data ref - Ultimo dia mês corrente
                  ,pr_cdprogra   => vr_cdprogra         --> Codigo programa conectado
                  ,pr_dsdircop   => rw_crapcop.dsdircop --> Diretório base da cooperativa
                  ,pr_vltotprv   => vr_vltotprv         --> Total acumulado de provisão
                  ,pr_vltotdiv   => vr_vltotdiv         --> Total acumulado de dívida
                  ,pr_cdcritic   => vr_cdcritic         --> Código de erro encontrado
                  ,pr_dscritic   => vr_dscritic);       --> Descrição de erro encontrado

      -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Testar saída de erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Somente quando não estivermos conectados a Cecred
      IF pr_cdcooper <> 3 THEN
        --Chamado 822997 - inversão ordem comandos INSERT/UPDATE
        --Atualizar informacoes tabela bndes
        BEGIN
           INSERT INTO crapbnd(cdcooper
                              ,dtmvtolt
                              ,nrdconta
                              ,vltotprv
                              ,vltotdiv)
            VALUES(3                      --> Cooperativa conectada
                  ,rw_crapdat.dtmvtolt    --> Data atual
                  ,rw_crapcop.nrctactl    --> Conta da cooperativa conectada
                  ,vr_vltotprv            --> Total acumulado de provisão
                  ,vr_vltotdiv);          --> Total acumulado de dívidas
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE crapbnd
                 SET vltotprv = vr_vltotprv       --> Total acumulado de provisão
                    ,vltotdiv = vr_vltotdiv      --> Total acumulado de dívidas
               WHERE cdcooper = 3                    --> Cooperativa Gravar sempre na Cecred
                 AND dtmvtolt = rw_crapdat.dtmvtolt  --> Data atual
                 AND nrdconta = rw_crapcop.nrctactl; --> Conta da cooperativa conectada
            EXCEPTION
              WHEN OTHERS THEN
                --Montar mensagem de erro
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapbnd: '||
                              'vltotprv:'  ||vr_vltotprv||
                              ', vltotdiv:'||vr_vltotdiv||
                              ' com cdcooper:3, dtmvtolt:'||rw_crapdat.dtmvtolt||
                              ', nrdconta:'||rw_crapcop.nrctactl||
                              '. '||sqlerrm;

                --Inclusão na tabela de erros Oracle - Chamado 822997
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                --Levantar Excecao
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            --Montar mensagem de erro
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapbnd: '||
                          'cdcooper:3, dtmvtolt:'||rw_crapdat.dtmvtolt||
                          ', nrdconta:'||rw_crapcop.nrctactl||
                          ', vltotprv:'||vr_vltotprv||
                          ', vltotdiv:'||vr_vltotdiv||
                          '. '||sqlerrm;

            --Inclusão na tabela de erros Oracle - Chamado 822997
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar commit final
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
         -- Se foi retornado apenas código
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;

        --Grava tabela de log - Ch 822997
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

         -- Efetuar rollback
         ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        --Inclusão na tabela de erros Oracle - Chamado 822997
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

        --Grava tabela de log - Ch 822997
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 3);

        -- Efetuar rollback
        ROLLBACK;
    END;
END pc_crps280;
/
