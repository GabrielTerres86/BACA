CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS280 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
  /* ..........................................................................

   Programa: pc_crps280 (Antigo Fontes/crps280.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Fevereiro/2000                      Ultima atualizacao: 15/04/2015

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

               11/03/2013 - Convers�o Progress >> Oracle PL-Sql (Marcos-Supero)

               26/08/2013 - Passagem do diret�rio da cooperativa para
                            a pc_crps280_i (Marcos-Supero)

               10/10/2013 - Ajuste para controle de criticas (Gabriel).

               07/03/2014 - Manuten��o 201402 (Edison-Amcom)
			   
     			     25/06/2014 - Incluso processo de exclus�o registros crapris e 
			                      crapvri SoftDesk 137892 (Daniel)
                            
               15/04/2015 - Projeto de separa��o cont�beis de PF e PJ.
                            (Andre Santos - SUPERO)

............................................................................. */

   DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros para parar a cadeia
      vr_exc_saida exception;
      -- Tratamento de erro sem parar a cadeia
      vr_exc_fimprg exception;
      -- Erro em chamadas da pc_gera_erro
      --vr_des_reto VARCHAR2(3);
      -- Codigo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      -- Descricao da critica
      vr_dscritic VARCHAR2(2000);

      --vr_tab_erro GENE0001.typ_tab_erro;

      ---------------- Cursores gen�ricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrctactl
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Valores para retorno da crps280.i
      vr_vltotprv NUMBER(14,2); --> Total acumulado de provis�o
      vr_vltotdiv NUMBER(14,2); --> Total acumulado de d�vida
      
      -- Variaveis verifica��o exclus�o de registros
      vr_datautil DATE;
      vr_delete   BOOLEAN;
      vr_dtmvtolt DATE;

   ---------------------------------------
   -- Inicio Bloco Principal pc_crps280
   ---------------------------------------

   BEGIN
      -- C�digo do programa
      vr_cdprogra := 'CRPS280';

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS280'
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
      
      -- Variavel de controle se registros crapris e crapvri ser�o deletados
      vr_delete   := TRUE;
        
      -- Variavel auxiliar para ser utilizada na bisca data util anterior.
      vr_dtmvtolt := rw_crapdat.dtmvtolt - 1;
        
      -- Fun��o para retornar dia �til anterior a data base
      vr_datautil  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,         -- Cooperativa
                                                  pr_dtmvtolt  => vr_dtmvtolt,         -- Data de referencia
                                                  pr_tipo      => 'A',                 -- Se n�o for dia �til, retorna primeiro dia �til anterior
                                                  pr_feriado   => TRUE,                -- Considerar feriados,
                                                  pr_excultdia => TRUE);               -- Considerar 31/12

      -- Caso mes da data util for diferente do mes da data de movimento entao � primeiro
      -- movimento do mes, nao exclui registro (que s�o os registros criados na mensal).                                               
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
               pr_dscritic := 'Erro ao efetuar a limpeza do registro semanal. Tabela de Vencimentos (CRAPVRI). Detalhes: '||sqlerrm;
               RAISE vr_exc_saida;
         END;
         --- Ap�s eliminar os riscos em si ---
         BEGIN
            DELETE
              FROM crapris
             WHERE cdcooper = pr_cdcooper
               AND dtrefere = vr_datautil; -- rw_crapdat.dtmvtolt;
         EXCEPTION
            WHEN OTHERS THEN
               pr_dscritic := 'Erro ao efetuar a limpeza do registro semanal. Tabela de Riscos (CRAPRIS). Detalhes: '||sqlerrm;
               RAISE vr_exc_saida;
         END;

      END IF;

      -- Chamar a rotina crps280_i (Antiga includes/crps280.i)
      pc_crps280_i(pr_cdcooper   => pr_cdcooper         --> Coop. conectada
                  ,pr_rw_crapdat => rw_crapdat          --> Vetor com calend�rio
                  ,pr_dtrefere   => rw_crapdat.dtultdia --> Data ref - Ultimo dia m�s corrente
                  ,pr_cdprogra   => vr_cdprogra         --> Codigo programa conectado
                  ,pr_dsdircop   => rw_crapcop.dsdircop --> Diret�rio base da cooperativa
                  ,pr_vltotprv   => vr_vltotprv         --> Total acumulado de provis�o
                  ,pr_vltotdiv   => vr_vltotdiv         --> Total acumulado de d�vida
                  ,pr_cdcritic   => vr_cdcritic         --> C�digo de erro encontrado
                  ,pr_dscritic   => vr_dscritic);       --> Descri��o de erro encontrado

      -- Retornar nome do m�dulo original, para que tire o action gerado pelo programa chamado acima
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);

      -- Testar sa�da de erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Somente quando n�o estivermos conectados a Cecred
      IF pr_cdcooper <> 3 THEN
         DECLARE
            vr_dsopera VARCHAR2(30);
         BEGIN
            -- Tenta atualizar as informa��es
            vr_dsopera := 'Atualizar';
            UPDATE crapbnd
               SET vltotprv = vr_vltotprv          --> Total acumulado de provis�o
                  ,vltotdiv = vr_vltotdiv          --> Total acumulado de d�vidas
             WHERE cdcooper = 3                    --> Cooperativa Gravar sempre na Cecred
               AND dtmvtolt = rw_crapdat.dtmvtolt  --> Data atual
               AND nrdconta = rw_crapcop.nrctactl; --> Conta da cooperativa conectada

            -- Se n�o conseguiu atualizar nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
               -- N�o encontrou nada para atualizar, ent�o inserimos
               vr_dsopera := 'Inserir';
               INSERT INTO crapbnd(cdcooper
                                  ,dtmvtolt
                                  ,nrdconta
                                  ,vltotprv
                                  ,vltotdiv)
                VALUES(3                      --> Cooperativa conectada
                      ,rw_crapdat.dtmvtolt    --> Data atual
                      ,rw_crapcop.nrctactl    --> Conta da cooperativa conectada
                      ,vr_vltotprv            --> Total acumulado de provis�o
                      ,vr_vltotdiv);          --> Total acumulado de d�vidas
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Erro ao '||vr_dsopera||' as informa��es na tabela CRAPBDN - Conta:'
                           || rw_crapcop.nrctactl||'. Detalhes: '||sqlerrm;
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
      WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas c�digo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descri��o
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
         -- Efetuar commit pois gravaremos o que foi processo at� ent�o
         COMMIT;
      WHEN vr_exc_saida THEN
         -- Se foi retornado apenas c�digo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descri��o
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos c�digo e critica encontradas
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
   END;
END pc_crps280;
/

