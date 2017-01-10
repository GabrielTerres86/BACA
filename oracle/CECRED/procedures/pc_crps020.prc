CREATE OR REPLACE PROCEDURE CECRED.pc_crps020(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER               --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER              --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER              --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS             --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

     Programa: pc_crps020                              Antigo: Fontes/crps020.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Marco/92.                         Ultima atualizacao: 18/06/2014

     Dados referentes ao programa:

     Frequencia: Diario (Batch - Background).
     Objetivo  : Atende a solicitacao 013.
                 Fazer limpeza mensal dos lancamentos ja microfilmados.
                 Rodara na primeira sexta-feira apos o processo mensal.

     Alteracoes: 10/01/2000 - Padronizar mensagens (Deborah).

                 15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                              registro do cadastro de tabelas, com qual numero de
                              conta que se esta trabalhando. O numero sera
                              armazenado na variavel aux_lsconta3 (Julio).

                 01/06/2005 - Nao selecionar mais lancamentos do tipo de lote 1
                              (Edson).

                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                              glb_cdcooper) no "for each" da tabela CRAPHIS.
                            - Kbase IT Solutions - Paulo Ricardo Maciel.

                 19/10/2009 - Alteracao Codigo Historico (Kbase).

                 08/03/2010 - Alteracao Historico (Gati)

                 15/05/2012 - substituição do FIND craptab para os registros
                              CONTACONVE pela chamada do fontes ver_ctace.p
                              (Lucas R.)

                 12/03/2014 - Conversão PROGRESS => ORACLE. (Reinert)

                 08/05/2014 - Programa ajustado para seguir padronização de
								              fontes PLSQL. (Reinert)

                 18/06/2014 - Exclusao da tabela craplli/crapcar.
                              (Chamado 118128) (Tiago Castro - RKAM)
                              
	               21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                              (Carlos Rafael Tanholi).
                              
				 05/01/2017 - Mostrar mensagem apenas se efetivamente houve exclusao de 
				              lotes (Rodrigo - 587076)
  ............................................................................. */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS020';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    -- Guardar registro dstextab
    vr_dstextab craptab.dstextab%TYPE;    

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor para verificar os lotes que devem ser excluidos
    CURSOR cr_craplot(pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
      SELECT lot.dtmvtolt,
             lot.cdagenci,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.ROWID
        FROM craplot lot
			 WHERE lot.cdcooper = pr_cdcooper AND      -- Cooperativa
             lot.tplotmov = 7           AND      -- Tipo de lote 7 - Limite de crédito
             lot.dtmvtolt < pr_dtmvtolt;
    rw_craplot cr_craplot%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------

    vr_dtlimite DATE;                  -- Data Limite
    vr_qtlotdel INTEGER := 0;          -- Quantidade de registros deletados na craplot

    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
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
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Buscar configuração na tabela
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'EXELIMPEZA'
                                             ,pr_tpregist => 001);

    IF TRIM(vr_dstextab) IS NULL THEN
      -- Critica: 176 - Falta tabela de execucao de limpeza - registro 001.
      vr_cdcritic := 176;
      -- Busca critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Gera log no proc_batch
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
			                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra  ||
                                                    ' --> ' || vr_dscritic);
      RAISE vr_exc_saida;
    ELSIF vr_dstextab = '1' THEN
			-- Critica: 177 - Limpeza ja rodou este mes.
			vr_cdcritic := 177;
			-- Busca Critica
			vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			-- Gera log no proc_batch
			btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
															  ,pr_ind_tipo_log => 2 -- Erro tratato
									  ,pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
																										' - ' || vr_cdprogra  ||
																										' --> ' || vr_dscritic);
			RAISE vr_exc_saida;
    END IF;

    -- Monta a data limite para efetuar a limpeza sempre com o primeiro dia do mês anterior
    vr_dtlimite := trunc(trunc(SYSDATE, 'mm') - 1, 'mm');

	  -- Percorre todos os lotes com data inferior a data limite e tipo de lote 7
    FOR rw_craplot IN cr_craplot(pr_dtmvtolt => vr_dtlimite) LOOP
      BEGIN
        -- Remove capa de lote
        DELETE FROM craplot
         WHERE craplot.ROWID = rw_craplot.ROWID;
        -- Incrementa a quantidade de registros deletados
        vr_qtlotdel := vr_qtlotdel + 1;
      EXCEPTION
				-- Se houve algum erro ao executar a query acima
        WHEN OTHERS THEN
					-- Alimenta descrição da crítica
          vr_dscritic := 'Erro ao deletar registro da craplot. Detalhes: ' ||
                         SQLERRM;
					-- Levanta exception
          RAISE vr_exc_saida;
      END;

    END LOOP;

    -- Imprime no log do processo os totais das exclusoes
    vr_cdcritic := 661;

	IF vr_qtlotdel > 0 THEN
    -- Imprime o total de registros deletados na CRAPLOT
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
		                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                     ' - '   || vr_cdprogra          ||
                                                     ' --> ' || vr_dscritic          ||
                                                     ' Lotes excluidos = '           ||
                                                     gene0002.fn_mask(vr_qtlotdel, 'z.zzz.zz9'));
	END IF;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
			                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra  ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps020;
/
