CREATE OR REPLACE PROCEDURE CECRED.pc_crps075 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps075       (Fontes/crps075.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Dezembro/93                         Ultima atualizacao: 02/03/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 013.
                   Fazer limpeza mensal dos lancamentos automaticos.
                   Rodara na primeira sexta-feira apos o processo mensal.

       Alteracoes: 29/06/95 - Alterado para tratar os lotes tipo 12 (Deborah).

                   18/09/98 - Alterado para tratar os lotes tipo 17 (Deborah).

                   10/01/2000 - Padronizar mensagens (Deborah).

                   13/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   04/06/2008 - Campo dsorigem nas leituras da craplau (David)

                   14/07/2009 - incluido no for each a condiçao -
                                craplau.dsorigem <> "PG555" - Precise - Paulo

                   02/06/2011 - incluido no for each a condiçao -
                                craplau.dsorigem <> "TAA" (Evandro).

                   30/09/2011 - incluido no for each a condigco -
                                craplau.dsorigem <> "CARTAOBB" (Ze).

                   04/07/2013 - incluido no for each a condigco -
                                craplau.dsorigem <> "BLOQJUD" (Ze).

                   09/12/2013 - Alterado indice leitura craplot (Daniel)

                   31/03/2014 - incluido nas consultas da craplau
                                craplau.dsorigem <> "DAUT BANCOOB" (Lucas).

                   21/07/2014 - conversão progres -> oracle (Odirlei-AMcom)

                   28/09/2015 - incluido nas consultas da craplau
                                craplau.dsorigem <> "CAIXA" (Lombardi).

                   20/05/2016 - Incluido nas consultas da craplau
                                craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)

                   22/09/2016 - Alterei a gravacao do log 661 do proc_batch para
                                o proc_message SD 402979. (Carlos Rafael Tanholi)

                   02/03/2017 - Incluido nas consultas da craplau
                                craplau.dsorigem <> "ADIOFJUROS" (Lucas Ranghetti M338.1)

                   27/07/2017 - Incluido delete na tbconv_det_agendamento antes de excluir da
                                CRAPLAU, devido a existencia de FK.
                                Heitor (Mouts) - Chamado 706691
    --             06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
    --                          após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
    --                          Alteração específica neste programa acrescentando o tratamento para a origem
    --                          BLQPREJU
    --                          (Renato Cordeiro - AMcom)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS075';

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
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca lotes
      CURSOR cr_craplot(pr_dtlimite DATE) IS
        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               rowid
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtopg < pr_dtlimite
           AND craplot.tplotmov in ( 6 ,
                                     12,  -- Lancamentos Automaticos
                                     17 ) -- Debitos de Cartao de Credito
        ORDER BY cdcooper, dtmvtopg, cdagenci,
                 cdbccxlt, nrdolote;

      -- Busca lancamentos automaticos
      CURSOR cr_craplau (pr_cdcooper craplau.cdcooper%type,
                         pr_dtmvtolt craplot.dtmvtolt%type,
                         pr_cdagenci craplot.cdagenci%type,
                         pr_cdbccxlt craplot.cdbccxlt%type,
                         pr_nrdolote craplot.nrdolote%type) IS
        SELECT insitlau
              ,dtmvtopg
              ,idlancto
              ,ROWID
          FROM craplau
         WHERE craplau.cdcooper = pr_cdcooper
           AND craplau.dtmvtolt = pr_dtmvtolt
           AND craplau.cdagenci = pr_cdagenci
           AND craplau.cdbccxlt = pr_cdbccxlt
           AND craplau.nrdolote = pr_nrdolote
           AND craplau.dsorigem NOT IN ('CAIXA'
                                       ,'INTERNET'
                                       ,'TAA'
                                       ,'PG555'
                                       ,'CARTAOBB'
                                       ,'BLOQJUD'
                                       ,'DAUT BANCOOB'
                                       ,'TRMULTAJUROS'
                                       ,'BLQPREJU'
                                       ,'ADIOFJUROS');

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_dstextab   craptab.dstextab%type;  --> desc texto do valor da tabela generica
      vr_qtlaudel   NUMBER:= 0;             --> qtd de registros limpos da tabela craplau
      vr_qtlotdel   NUMBER:= 0;             --> qtd de registros limpos da tabela crapmdp
      vr_dtlimite   DATE;                   --> data limite utilizada para buscar registros
      vr_flgdelet   BOOLEAN;                --> controle se deletou

      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      vr_dstextab := null;
      -- Buscar parametro na tabela generica EXELIMPEZA
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper,
                                                 pr_nmsistem => 'CRED',
                                                 pr_tptabela => 'GENERI',
                                                 pr_cdempres => 00,
                                                 pr_cdacesso => 'EXELIMPEZA',
                                                 pr_tpregist => 001);

      -- Se não localizar valor, gerar critica e abortar
      IF TRIM(vr_dstextab) is null THEN
        vr_cdcritic := 176; --> 176 - Falta tabela de execucao de limpeza - registro 001
        raise vr_exc_saida;
      ELSIF trim(vr_dstextab) = '1' THEN
        vr_cdcritic := 177; --> 177 - Limpeza ja rodou este mes.
        raise vr_exc_saida;
      END IF;

      /*  Monta data limite para efetuar a limpeza  */
      -- inicio do mês anterior
      vr_dtlimite := trunc(add_months(rw_crapdat.dtmvtolt,-1),'MM');

      vr_qtlaudel := 0;
      vr_qtlotdel := 0;
      vr_flgdelet := TRUE;

      /*  Le os lotes a serem excluidos  */
      FOR rw_craplot IN cr_craplot (pr_dtlimite => vr_dtlimite) LOOP

        -- Limpeza da Tabela de Lancamentos Automaticos
        BEGIN

          -- Buscar lançamentos automaticos
          FOR rw_craplau IN cr_craplau ( pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craplot.dtmvtolt,
                                         pr_cdagenci => rw_craplot.cdagenci,
                                         pr_cdbccxlt => rw_craplot.cdbccxlt,
                                         pr_nrdolote => rw_craplot.nrdolote) LOOP

            -- Deletar apenas se for a situação 2,3
            IF rw_craplau.insitlau in (2,3) AND
                (
                  -- e tipo de movimento 12 ou 17 e
                  -- com a data de pagamento menor que a data limite
                  ( rw_craplot.tplotmov in (12,17) AND
                    rw_craplau.dtmvtopg < vr_dtlimite)
                  -- senao for dos tipos de movimento acima, tbm deleta
                  OR
                   rw_craplot.tplotmov not in (12,17)
                  ) THEN

              --Deletar detalhe do lancamento automatico
              delete tbconv_det_agendamento
               where idlancto = rw_craplau.idlancto;
              
              -- deletar lançamentos automaticos
              delete craplau
               where rowid = rw_craplau.rowid;
              -- contar registros deletados
              vr_qtlaudel := vr_qtlaudel + 1;
            ELSE
              -- marcar como não deletado, para não deletar o lote
              vr_flgdelet := FALSE;
            END IF;

          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel efetuar limpeza da tabela craplau: '||SQLerrm;
            raise vr_exc_saida;
        END;

        -- se eliminou registro deletar craplot
        IF vr_flgdelet THEN
          -- Limpeza da Tabela de lotes
          BEGIN
            DELETE craplot
            WHERE rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel efetuar limpeza da tabela craplot: '||SQLerrm;
              raise vr_exc_saida;
          END;
          -- contar lotes deletados
          vr_qtlotdel := vr_qtlotdel + 1;
        ELSE
          -- iniciar variaveis
          vr_flgdelet := TRUE;
        END IF;

      END LOOP;  -- Fim loop craplot

      /*  Imprime no log do processo os totais das exclusoes   */
      vr_cdcritic := 661;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      /*Mostra CRAPLAU*/
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic||
                                                     ' LAU = '|| trim(to_char(vr_qtlaudel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');

      /*Mostra CRAPCRD e CRAPLOT*/
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic||
                                                     ' LOT = '|| trim(to_char(vr_qtlotdel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');


      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
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
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
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
    END;

  END pc_crps075;