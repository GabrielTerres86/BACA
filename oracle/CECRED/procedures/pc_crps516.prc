CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS516" ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                          ,pr_flgresta  IN PLS_INTEGER           --> Indicador para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
  /* ............................................................................

     Programa: pc_crps516 (Antigo Fontes/crps516.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Gabriel
     Data    : Setembro/2008                   Ultima Atualizacao: 20/02/2018

     Dados referentes ao programa:

     Frequencia: Semanal.
     Objetivo  : Atende a solicitaao 32.
                 Emite relatorio da provisao para creditos de liquidacao
                 duvidosa (227).

     Alteracoes: 04/11/2008 - Efetuar limpeza das tabelas crapris e crapvri
                              (Diego).

                 16/01/2009 - Efetuada correcao na eliminacao das tabelas crapris
                              e crapvri (Mirtes)

                 04/12/2009 - Retirar o nao uso mais do buffer crabass e
                              aux_recid (Gabriel).

                 24/08/2010 - Incluir w-crapris.qtdatraso (Magui).

                 25/08/2010 - Inclusao das variaveis aux_rel1731_1, aux_rel1731_2,
                              aux_rel1731_1_v, aux_rel1731_2_v. Devido a alteracao
                              na includes crps280.i (Adriano).

                 19/10/2012 - Inclusao das variaveis aux_rel1724_* devido a
                              alteracao na include crps280.i (Rafael).

                 05/11/2012 - Descomentado bloco que apaga os registros das
                              tabelas - crapris e crapvri (Rafael).
                            - Ajuste nos deletes das tabelas crapvri e crapris
                              para realizar commit por PAC (Rafael).

                 22/04/2013 - Incluido os campos qtdiaatr, cdorigem na criacao
                              da temp-table w-crapris (Adriano).

                 11/06/2013 - Conversão Progress >> Oracle PL-Sql (Marcos-Supero)
                 
                 26/08/2013 - Passagem do diretório da cooperativa para 
                              a pc_crps280_i (Marcos-Supero)
							  
				 25/06/2014 - Alterado processo de exclusão da crapris e crapvri.
 				              SoftDesk 137892 (Daniel)	  

                 20/02/2018 - Paralelismo - Projeto Ligeirinho (Fabiano B. Dias - AMcom)											
  ............................................................................. */

    DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS516';
      -- Tratamento de erros
      vr_exc_erro exception;
			
      -- Paralelismo - Projeto Ligeirinho
      vpr_stprogra   PLS_INTEGER; --> Saída de termino da execução
      vpr_infimsol   PLS_INTEGER; --> Saída de termino da solicitação, 
			
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

      -- Teste de existencia de risco calculado para a data atual
      CURSOR cr_crapris IS
        SELECT 'S'
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND dtrefere = rw_crapdat.dtmvtolt --> Data atual
           AND inddocto = 1;                  --> Docto 3020
      vr_ind_exis_risco CHAR(1) := 'N';

      -- Valores para retorno da crps280.i
      vr_vltotprv NUMBER(14,2); --> Total acumulado de provisão
      vr_vltotdiv NUMBER(14,2); --> Total acumulado de dívida
      
      vr_datautil DATE;
      vr_delete   BOOLEAN;
      vr_dtmvtolt DATE;

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
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
        
      -- Deve eliminar registros caso vr_delete = TRUE
      IF vr_delete = TRUE THEN
        
        ---- Efetuar a limpeza do registro semanal ---
        --- Primeiramente dos vencimentos do risco ---
        BEGIN
          DELETE
            FROM crapvri
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_datautil;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao efetuar a limpeza do registro semanal. Tabela de Vencimentos (CRAPVRI). Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        --- Após eliminar os riscos em si ---
        BEGIN
          DELETE
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND dtrefere = vr_datautil;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao efetuar a limpeza do registro semanal. Tabela de Riscos (CRAPRIS). Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      
      

      -- Verificar a existencia de risco calculado para a data atual
      OPEN cr_crapris;
      FETCH cr_crapris
       INTO vr_ind_exis_risco;
      CLOSE cr_crapris;
      -- Somente continuar se existe risco para a data atual e não estivermos no fechamento mensal
      IF vr_ind_exis_risco = 'S' AND trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm') THEN
        -- Chamar a rotina crps280_i (Antiga includes/crps280.i)
        pc_crps280_i(pr_cdcooper   => pr_cdcooper         --> Coop. conectada
                    ,pr_rw_crapdat => rw_crapdat          --> Vetor com calendário
                    ,pr_dtrefere   => rw_crapdat.dtmvtolt --> Data corrente
                    ,pr_cdprogra   => vr_cdprogra         --> Codigo programa conectado
                    ,pr_dsdircop   => rw_crapcop.dsdircop --> Diretório base da cooperativa
										----
										,pr_cdagenci  => 0                    --> Código da agência, utilizado no paralelismo
										,pr_idparale  => 0                    --> Identificador do job executando em paralelo.
										,pr_flgresta  => 1                    --> Flag padrão para utilização de restart
										,pr_stprogra  => vpr_stprogra         --> Saída de termino da execução
										,pr_infimsol  => vpr_infimsol         --> Saída de termino da solicitação,                                               
										----
                    ,pr_vltotprv   => vr_vltotprv         --> Total acumulado de provisão
                    ,pr_vltotdiv   => vr_vltotdiv         --> Total acumulado de dívida
                    ,pr_cdcritic   => pr_cdcritic         --> Código de erro encontrado
                    ,pr_dscritic   => pr_dscritic);       --> Descrição de erro encontrado
        
        -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                  ,pr_action => NULL); 
        
        -- Testar saída de erro
        IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
          
          
      END IF;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);      
      -- Efetuar commit final
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps516;
/
