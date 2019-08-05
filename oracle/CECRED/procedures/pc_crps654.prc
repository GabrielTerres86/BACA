CREATE OR REPLACE PROCEDURE CECRED.pc_crps654 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Codigo do operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps654 (Fontes/crps654.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Fabricio
       Data    : Agosto/2013                     Ultima atualizacao: 01/02/2019

       Dados referentes ao programa:

       Frequencia: Diario
       Objetivo  : Atende a solicitacao 040.
               Tentar debitar o valor pendente da parcela do plano de COTAS,
               seja plano com Débito em Conta ou vinculado a FOLHA.
               Emite relatorio 137.

       Alteracoes:  17/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
                    06/02/2014 - Nao considerar saldo bloqueado (Diego).             
               
                    07/02/2014 - Conversão Progress -> Oracle - Andrino (RKAM)
       
                    16/06/2014 - replicação das manutenções do progres de 02/2014 (Odirlei/AMcom)
                    
                    07/04/2015 - Inclusão do parametro pr_tipo_busca na chamada da procedure 
                                 extr0001.pc_obtem_saldo_dia para melhoria de performance.
                                 Alisson (AMcom)
                    
                    27/07/2015 - Adicionado na insercao da craplcm os seguintes campos,
                                 cdpesqbb adicionado o nome do programa,
                                 hrtransa adicionado a hora da transacao.
                                 (Jorge/Thiago) - SD 294256
                    
                    02/06/2016 - Ajuste para melhora de desempenho, conforne
                                 solicitado no chamado 463036 (Kelvin)             

                    27/04/2018 - Ajuste no nome do arquivo gerado no relatorio e 
                                 adicionado hora/minuto/segundo ao nrdocto(Projeto Debitador Unico - Fabiano B. Dias - AMcom).
                                                                 
                    04/07/2018 - PJ450 Regulatório de Credito - Substituido o Insert na tabela craplcm 
                                 pela chamada da rotina lanc0001.pc_gerar_lancamento_conta. (Josiane Stiehler - AMcom)  
                   
                    13/12/2018 - Remoção da atualização da Capa de Lote
                                 Yuri - Mouts
  
                    01/02/2019 - P450 - Ajuste na geracao do prejuizo (Guilherme/AMcom)	 
             
                    12/07/2019 - RITM0011923 - Criado uma condição onde, dependendo a cooperativa em questão
                                 será considerado ou desconsiderado o valor do limite de crédito. (Daniel Lombardi - Mout's)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS654';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro;
      vr_horaminseg NUMBER; -- 27/04/2018-deb.unico.
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.vlmidbco
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;


      -- Busca os dados dos planos de capitalização
      CURSOR cr_crappla IS
        SELECT nrdconta,
               vlpenden,
               flgpagto,
               indpagto,
               dtdpagto,
               vlprepla,
               nrctrpla,
               dtultpag,
               vlpagmes,
               vlprepag,
               ROWID
          FROM crappla
         WHERE crappla.cdcooper = pr_cdcooper
           AND crappla.tpdplano = 1
           AND crappla.cdsitpla = 1                 /*Plano Ativo */
           AND crappla.indpagto = 0                 /*Nao debitou parcela total*/
           AND crappla.vlpenden > 0;

      -- Busca os dados dos associados
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT cdagenci,
               vllimcre,
               nmprimtl,
               cdsecext
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca os dados das cotas dos associados
      CURSOR cr_crapcot(pr_nrdconta crapcot.nrdconta%TYPE) IS
        SELECT vldcotas,
               qtprpgpl,
               ROWID
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;

      -- Cursor sobre as capas de lotes
      CURSOR cr_craplot(pr_nrdolote craplot.nrdolote%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE) IS
        SELECT nrseqdig,
               ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Cursor para a busca dos dados da agencia
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Estrutura para PL Table de debitos pendentes para utilizacao no relatorio
      TYPE typ_reg_deb_pen IS
        RECORD(cdagenci crapass.cdagenci%TYPE,
               nrdconta crapass .nrdconta%TYPE,
               nmprimtl crapass.nmprimtl%TYPE,
               vlrplano NUMBER(17,2),
               vldebito NUMBER(17,2),
               vlpenden NUMBER(17,2));
      TYPE typ_tab_deb_pen IS TABLE OF typ_reg_deb_pen INDEX BY VARCHAR2(25);

      ------------------------------- VARIAVEIS -------------------------------

      vr_tab_sald      EXTR0001.typ_tab_saldos;   --> Temp-Table com o saldo do dia
      vr_tab_deb_pen   typ_tab_deb_pen;           --> Temp-Table de debitos pendentes para utilizacao no relatorio
      vr_ind_sald      PLS_INTEGER;               --> Indice sobre a temp-table vr_tab_sald
      vr_ind_deb_pen   VARCHAR2(25);              --> Indice sobre a temp-table vr_tab_deb_ped
      vr_vlsddisp      NUMBER(17,2);              --> Valor de saldo disponivel
      vr_vldebito      NUMBER(17,2);              --> Valor de debito
      vr_flgsomar      BOOLEAN;                   --> Flag indicando se deve somar o valor das prestacoes ja pagas no mes
      vr_nmresage      crapage.nmresage%TYPE;     --> Nome da agencia
      vr_des_xml       CLOB;                      --> Variável para armazenar as informações em XML
      vr_dstexto       VARCHAR2(32767);           --> Texto para o CLOB
      vr_nom_diretorio VARCHAR2(200);             --> Caminho do arquivo base
      vr_qtdplano      PLS_INTEGER  := 0;         --> Quantidade de planos por PA
      vr_qtdplano_ger  PLS_INTEGER  := 0;         --> Quantidade geral de planos
      vr_vlpenden      NUMBER(17,2) := 0;         --> Valor pendente por PA
      vr_vlpenden_ger  NUMBER(17,2) := 0;         --> Valor pendente geral
      vr_hrtransa      NUMBER(5)    := 0;         --> Hora da transacao
      -- PJ450
      vr_incrineg      INTEGER;
      vr_tab_retorno   LANC0001.typ_reg_retorno;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------
      
      -- Hora da transacao
      vr_hrtransa := gene0002.fn_busca_time;
      
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

      -- Efetua um loop sobre os planos de capitalizacao
      FOR rw_crappla IN cr_crappla LOOP
        -- Busca os dados dos associados
        OPEN cr_crapass(rw_crappla.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || gene0001.fn_busca_critica(9) );
          CLOSE cr_crapass;
          continue; -- Volta para o inicio do loop
        END IF;
        CLOSE cr_crapass;        

        

        extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => rw_crapass.cdagenci,
                                    pr_nrdcaixa   => 0,
                                    pr_cdoperad   => pr_cdoperad,
                                    pr_nrdconta   => rw_crappla.nrdconta,
                                    pr_vllimcre   => rw_crapass.vllimcre,
                                    pr_dtrefere   => rw_crapdat.dtmvtolt, 
                                    pr_tipo_busca => 'A', --Usa data anterior na crapsda
                                    pr_des_reto   => vr_des_erro,
                                    pr_tab_sald   => vr_tab_sald,
                                    pr_tab_erro   => vr_tab_erro);
        -- VERIFICA SE HOUVE ERRO NO RETORNO
        IF vr_des_erro = 'NOK' THEN
          -- ENVIO CENTRALIZADO DE LOG DE ERRO
          IF vr_tab_erro.count > 0 THEN
            -- RECEBE DESCRICAO DO ERRO QUE OCORREU NA PC_CARREGA_PAR_TARIFA_VIGENTE
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            -- GERA LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratato
                                       pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' -' || vr_cdprogra || ' --> ' || vr_dscritic);
          END IF;
          continue; -- Volta para o inicio do loop
        END IF;

        vr_ind_sald := vr_tab_sald.last;

        --> Daniel Mout's - Se o crapprm.dsvlrprm da coperativa considera o limite de crédito.
        IF (APLI0009.UsarLimCredParaDebPlanoCotas(pr_cdcooper => pr_cdcooper)) then  
          -- Faz a somatória normal levando em conta o valor do limite de crédtido
          vr_vlsddisp := vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vlsdchsl 
                       + vr_tab_sald(vr_ind_sald).vllimcre;
                    
        ELSE -- Se a coperativa desconsidera
          -- Faz o somatório sem o valor do limite de créditido.
          vr_vlsddisp := vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vlsdchsl 
        END IF;
                    
        vr_vldebito := 0;


        /* Se Valor disponivel >= Valor minimo parametrizado para debito */
        IF vr_vlsddisp >= rw_crapcop.vlmidbco AND vr_vlsddisp > 0 THEN
          
          -- Busca os as cotas dos associados
          OPEN cr_crapcot(rw_crappla.nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          IF cr_crapcot%NOTFOUND THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || gene0001.fn_busca_critica(10) );
            CLOSE cr_crapcot;
            continue; -- Volta para o inicio do loop
          END IF;
          CLOSE cr_crapcot;
        
          /* Se Valor disponivel >= Valor pendente, debita TOTAL pendente */
          IF vr_vlsddisp >= rw_crappla.vlpenden THEN
            vr_vldebito := rw_crappla.vlpenden;
            rw_crappla.vlpenden := 0;

            IF rw_crappla.flgpagto = 1 THEN /*Plano Folha*/
              rw_crappla.indpagto := 1;
            ELSE /* Plano com debito em conta */
              /* Se estiver no mes do proximo debito da parcela, permanece
                 indicador com 0 para que o programa crps172 debite a parcela
                 atual normalmente */
              IF trunc(rw_crappla.dtdpagto,'MM') = trunc(rw_crapdat.dtmvtolt,'MM') THEN
                rw_crappla.indpagto := 0;
              ELSE
                rw_crappla.indpagto := 1; /*debitou valor pendente do mes*/
              END IF;
            END IF;
            -- Atualiza a tabela de planos de capitalizacao com o valor pendente igual a zeros
            BEGIN
              UPDATE crappla
                 SET crappla.vlpenden = rw_crappla.vlpenden,
                     crappla.indpagto = rw_crappla.indpagto
                WHERE ROWID = rw_crappla.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPPLA: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

          ELSE /* Senao, debita saldo em c/c */
            vr_vldebito := vr_vlsddisp;
            rw_crappla.vlpenden := rw_crappla.vlpenden - vr_vldebito;
            rw_crappla.indpagto := 0;

            -- Atualiza a tabela de planos de capitalizacao com o valor pendente subtraido do debito
            BEGIN
              UPDATE crappla
                 SET crappla.vlpenden = rw_crappla.vlpenden,
                     crappla.indpagto = rw_crappla.indpagto
                WHERE ROWID = rw_crappla.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPPLA: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            /* relatorio de valores pendentes */
            vr_ind_deb_pen := lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crappla.nrdconta,10,'0');
            vr_tab_deb_pen(vr_ind_deb_pen).cdagenci := rw_crapass.cdagenci;
            vr_tab_deb_pen(vr_ind_deb_pen).nrdconta := rw_crappla.nrdconta;
            vr_tab_deb_pen(vr_ind_deb_pen).nmprimtl := rw_crapass.nmprimtl;
            vr_tab_deb_pen(vr_ind_deb_pen).vlrplano := rw_crappla.vlprepla;
            vr_tab_deb_pen(vr_ind_deb_pen).vldebito := vr_vldebito;
            vr_tab_deb_pen(vr_ind_deb_pen).vlpenden := rw_crappla.vlpenden;

          END IF; -- vr_vlsddisp >= rw_crappla.vlpenden

          /* Lancamento de débito em c/c */
          OPEN cr_craplot(8454, rw_crapdat.dtmvtolt);
          FETCH cr_craplot INTO rw_craplot;
          -- Se nao existir vai criar a capa de lote
          IF cr_craplot%NOTFOUND THEN
            BEGIN
              INSERT INTO craplot
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 tplotmov,
                 nrseqdig,
                 vlcompcr,
                 vlinfocr,
                 cdhistor,
                 cdoperad,
                 cdcooper)
              VALUES
                (rw_crapdat.dtmvtolt,
                 1,
                 100,
                 8454,
                 1,
                 0,
                 0,
                 0,
                 0,
                 '1',
                 pr_cdcooper)
               RETURNING ROWID INTO rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            rw_craplot.nrseqdig := 0;
          END IF;
          CLOSE cr_craplot;

          -- Atualiza o sequencial da capa do lote
          -- Atualiza o sequencial da capa do lote
          rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                                 pr_nmdcampo => 'NRSEQDIG',
                                 pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||
                                                ';1;100;8454');
--          rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig,0) + 1;

          -- Atualiza a capa do lote
/*          BEGIN
            UPDATE craplot
               SET nrseqdig = rw_craplot.nrseqdig,
                   qtcompln = qtcompln + 1,
                   qtinfoln = qtcompln + 1,
                   vlcompdb = vlcompdb + vr_vldebito,
                   vlinfodb = vlcompdb + vr_vldebito
             WHERE ROWID = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
          END;*/

          vr_horaminseg := TO_NUMBER(TO_CHAR(SYSDATE, 'hh24mmss')); -- 27/04/2018-deb.unico.

          -- PJ450 - Insere Lancamento 
          LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                                            ,pr_cdagenci => 1
                                            ,pr_cdbccxlt => 100
                                            ,pr_nrdolote => 8454
                                            ,pr_nrdconta => rw_crappla.nrdconta
                                            ,pr_nrdctabb => rw_crappla.nrdconta
                                            ,pr_nrdctitg => to_char(rw_crappla.nrdconta,'00000000')
                                            ,pr_nrdocmto => rw_crappla.nrctrpla || vr_horaminseg
                                            ,pr_cdpesqbb => vr_cdprogra
                                            ,pr_hrtransa => vr_hrtransa
                                            ,pr_cdhistor => 127 -- DB. COTAS 
                                            ,pr_nrseqdig => rw_craplot.nrseqdig
                                            ,pr_vllanmto => vr_vldebito
                                            ,pr_inprolot => 0                    -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                            ,pr_tplotmov => 0                    -- Tipo Movimento 
                                            ,pr_cdcritic => vr_cdcritic          -- Codigo Erro
                                            ,pr_dscritic => vr_dscritic          -- Descricao Erro
                                            ,pr_incrineg => vr_incrineg          -- Indicador de crítica de negócio
                                            ,pr_tab_retorno => vr_tab_retorno    -- Registro com dados do retorno
                                            );

          -- Conforme tipo de erro realiza acao diferenciada
          IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            IF vr_incrineg = 1 THEN
              -- Critica de que não pode debitar. Segue para o próximo
              CONTINUE;
            END IF;
              RAISE vr_exc_saida;
          END IF;

          /* Quando debitar valor total para plano C/C cria crapavs,
             conforme crps172. No caso de plano FOLHA, este registro eh
             criado pelo crps036 ou crps370 */
          IF rw_crappla.vlpenden = 0 AND rw_crappla.flgpagto = 0 THEN
            -- Insere no cadastro dos avisos de debito em conta corrente
            BEGIN
              INSERT INTO crapavs
                (cdagenci,
                 cdempres,
                 cdhistor,
                 cdsecext,
                 dtdebito,
                 dtmvtolt,
                 dtrefere,
                 insitavs,
                 nrdconta,
                 nrdocmto,
                 nrseqdig,
                 tpdaviso,
                 vldebito,
                 vlestdif,
                 vllanmto,
                 flgproce,
                 cdcooper)
               VALUES
                (rw_crapass.cdagenci,
                 0,
                 127,
                 rw_crapass.cdsecext,
                 rw_crapdat.dtmvtolt,
                 rw_crapdat.dtmvtolt,
                 rw_crapdat.dtmvtolt,
                 1, /* debitado */
                 rw_crappla.nrdconta,
                 rw_crappla.nrctrpla|| vr_horaminseg, -- debitador unico
                 rw_craplot.nrseqdig ,
                 2,
                 0,
                 0,
                 vr_vldebito,
                 1, /* processado */
                 pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir crapavs: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;


          OPEN cr_craplot(8464, rw_crapdat.dtmvtolt);
          FETCH cr_craplot INTO rw_craplot;
          -- Se nao existir vai criar a capa de lote
          IF cr_craplot%NOTFOUND THEN
            BEGIN
              INSERT INTO craplot
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 tplotmov,
                 nrseqdig,
                 vlcompcr,
                 vlinfocr,
                 tpdmoeda,
                 cdoperad,
                 cdcooper)
              VALUES
                (rw_crapdat.dtmvtolt,
                 1,
                 100,
                 8464,
                 3,
                 0,
                 0,
                 0,
                 1,
                 '1',
                 pr_cdcooper)
               RETURNING ROWID INTO rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            rw_craplot.nrseqdig := 0;
          END IF;
          CLOSE cr_craplot;

          -- Verifica se deve somar o saldo do pagamento anterior no pagto do mes.
          IF rw_crappla.dtultpag = to_date('01/01/0001','dd/mm/yyyy') THEN
            vr_flgsomar := TRUE;
          ELSIF to_char(rw_crapdat.dtmvtolt,'MM') = to_char(rw_crappla.dtultpag,'MM') THEN -- Se o mes do processo for igual ao mes do ultimo pagamento
            vr_flgsomar := TRUE;
          ELSE
            vr_flgsomar := FALSE;
          END IF;

          -- Retirada a atualização da capa de lote. Yuri - Mouts
          -- Atualiza o sequencial da capa do lote
          rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                                 pr_nmdcampo => 'NRSEQDIG',
                                 pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||
                                                ';1;100;8464');

--          rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig,0) + 1;

          -- Atualiza a capa do lote
/*          BEGIN
            UPDATE craplot
               SET nrseqdig = rw_craplot.nrseqdig,
                   qtcompln = qtcompln + 1,
                   qtinfoln = qtcompln + 1,
                   vlcompcr = vlcompcr + vr_vldebito,
                   vlinfocr = vlcompcr + vr_vldebito
             WHERE ROWID = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
              RAISE vr_exc_saida;
          END;*/

          -- Insere na tabela de cotas / capital
          BEGIN
            INSERT INTO craplct
              (cdcooper,
               cdagenci,
               cdbccxlt,
               nrdolote,
               dtmvtolt,
               cdhistor,
               nrctrpla,
               nrdconta,
               nrdocmto,
               nrseqdig,
               vllanmto)
             VALUES
              (pr_cdcooper,
               1,
               100,
               8464,
               rw_crapdat.dtmvtolt,
               075, /*PG. PLANO C/C*/
               rw_crappla.nrctrpla,
               rw_crappla.nrdconta,
               rw_crappla.nrctrpla || vr_horaminseg,
               rw_craplot.nrseqdig,
               vr_vldebito);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na craplct: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualiza data do ultimo pagamento
          rw_crappla.dtultpag := rw_crapdat.dtmvtolt;
          /*Valor que foi pago no mes corrente*/
          IF vr_flgsomar THEN
            rw_crappla.vlpagmes := rw_crappla.vlpagmes + vr_vldebito;
          ELSE
            rw_crappla.vlpagmes := vr_vldebito;
          END IF;

          /*Valor acumulado das prestacoes ja pagas*/
          rw_crappla.vlprepag := rw_crappla.vlprepag + vr_vldebito;

          -- Atualiza a tabela de planos de capitalizacao
          BEGIN
            UPDATE crappla
               SET dtultpag = rw_crappla.dtultpag,
                   vlpagmes = rw_crappla.vlpagmes,
                   vlprepag = rw_crappla.vlprepag
             WHERE ROWID = rw_crappla.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crappla: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          rw_crapcot.vldcotas := rw_crapcot.vldcotas + vr_vldebito;
          rw_crapcot.qtprpgpl := rw_crapcot.qtprpgpl + 1;

          -- Atualiza a tabela de cotas dos associados
          BEGIN
            UPDATE crapcot
               SET vldcotas = rw_crapcot.vldcotas,
                   qtprpgpl = rw_crapcot.qtprpgpl
             WHERE ROWID = rw_crapcot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapcot: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          /* Nao permite efetuar debito */
          /* relatorio de valores pendentes */
          
          vr_ind_deb_pen := lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crappla.nrdconta,10,'0')
                            ||lpad(vr_tab_deb_pen.count,10,'0');
            
          vr_tab_deb_pen(vr_ind_deb_pen).cdagenci := rw_crapass.cdagenci;
          vr_tab_deb_pen(vr_ind_deb_pen).nrdconta := rw_crappla.nrdconta;
          vr_tab_deb_pen(vr_ind_deb_pen).nmprimtl := rw_crapass.nmprimtl;
          vr_tab_deb_pen(vr_ind_deb_pen).vlrplano := rw_crappla.vlprepla;
          vr_tab_deb_pen(vr_ind_deb_pen).vldebito := vr_vldebito;
          vr_tab_deb_pen(vr_ind_deb_pen).vlpenden := rw_crappla.vlpenden;
        END IF; --vr_vlsddisp >= rw_crapcop.vlmidbco AND vr_vlsddisp > 0
      END LOOP;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Escrece o cabecalho do XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><raiz>');


      -- Efetua o loop sobre a pl/table de debitos pendentes para montagem do relatorio
      vr_ind_deb_pen := vr_tab_deb_pen.first;
      WHILE vr_ind_deb_pen IS NOT NULL LOOP
        -- Verifica se eh o primeiro registro do PA
        IF vr_ind_deb_pen = vr_tab_deb_pen.first OR -- Verifica se eh o primeiro registro
           vr_tab_deb_pen(vr_ind_deb_pen).cdagenci <> vr_tab_deb_pen(vr_tab_deb_pen.prior(vr_ind_deb_pen)).cdagenci THEN -- ou se o PA eh diferente do anterior

          -- Zera os acumuladores por PA
          vr_qtdplano := 0;
          vr_vlpenden := 0;

          -- Busca o nome da agencia
          OPEN cr_crapage(vr_tab_deb_pen(vr_ind_deb_pen).cdagenci);
          FETCH cr_crapage INTO vr_nmresage;
          IF cr_crapage%NOTFOUND THEN
            vr_nmresage := 'PA NAO CADASTRADO';
          END IF;
          CLOSE cr_crapage;
          
          -- Abre o no de agencia e insere o nome da agencia
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
            '<pac><nmresage>'||to_char(vr_tab_deb_pen(vr_ind_deb_pen).cdagenci,'990')||' - '||vr_nmresage||'</nmresage>');

        END IF;

        -- Escreve a linha de detalhe
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                        '<plano>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_deb_pen(vr_ind_deb_pen).nrdconta) ||'</nrdconta>'||
                         '<nmprimtl>'||substr(vr_tab_deb_pen(vr_ind_deb_pen).nmprimtl,1,40)            ||'</nmprimtl>'||
                         '<vlrplano>'||to_char(vr_tab_deb_pen(vr_ind_deb_pen).vlrplano,'99G999G990D00')||'</vlrplano>'||
                         '<vldebito>'||to_char(vr_tab_deb_pen(vr_ind_deb_pen).vldebito,'99G999G990D00')||'</vldebito>'||
                         '<vlpenden>'||to_char(vr_tab_deb_pen(vr_ind_deb_pen).vlpenden,'99G999G990D00')||'</vlpenden>'||
                       '</plano>');

        -- Efetua o acumulador
        vr_qtdplano     := vr_qtdplano + 1;
        vr_qtdplano_ger := vr_qtdplano_ger + 1;
        vr_vlpenden     := vr_vlpenden + vr_tab_deb_pen(vr_ind_deb_pen).vlpenden;
        vr_vlpenden_ger := vr_vlpenden_ger + vr_tab_deb_pen(vr_ind_deb_pen).vlpenden;

        -- Verifica se eh o ultimo registro do PA
        IF vr_ind_deb_pen = vr_tab_deb_pen.last OR -- Verifica se eh o ultimo registro
           vr_tab_deb_pen(vr_ind_deb_pen).cdagenci <> vr_tab_deb_pen(vr_tab_deb_pen.next(vr_ind_deb_pen)).cdagenci THEN -- ou se o PA eh diferente do proximo
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                           '<qtdplano>'    ||to_char(vr_qtdplano,'fm999G990')         ||'</qtdplano>'||
                           '<vlpenden>'    ||to_char(vr_vlpenden,'99G999G990D00')     ||'</vlpenden>'||
                           '<qtdplano_ger>'||to_char(vr_qtdplano_ger,'fm999G990')     ||'</qtdplano_ger>'||
                           '<vlpenden_ger>'||to_char(vr_vlpenden_ger,'99G999G990D00') ||'</vlpenden_ger>'||
                         '</pac>');
        END IF;

        -- Vai para o proximo registro da pl/table
        vr_ind_deb_pen := vr_tab_deb_pen.next(vr_ind_deb_pen);
      END LOOP;

      -- Finaliza o no principal
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</raiz>',true);

      -- Busca do diretorio base da cooperativa
      vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'rl'); --> Utilizaremos o contab


      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/raiz/pac/plano',              --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl137.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_diretorio||'/crrl137_'||to_char( gene0002.fn_busca_time )||'.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 2,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

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

  END pc_crps654;
/
