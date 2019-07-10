CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS575 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_cdoperad IN craplot.cdoperad%TYPE   --> Codigo operador
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS575                      Antigo: Fontes/CRPS575.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2012.                    Ultima atualizacao: 02/02/2015

   Dados referentes ao programa:

   Frequencia: Mensal
   Objetivo  : Calculo dos juros do saldo devedor sobre emprestimos.

   Alteracoes: 07/01/2013 - Modificar atualizacao do indicador de saldo
                            devedor das linhas de credito (Gabriel).

               25/02/2013 - Tratar transacao por contrato (Gabriel).

               27/02/2013 - Atribuir valor de referencia dos juros somente
                            quanto este for positivo (Gabriel).

               05/11/2013 - Ajuste para inclusao do parametro cdpactra na
                            procedures lanca_juro_contrato (Adriano).

               27/11/2013 - Enviado cdagenci/cdpactra = 1 na procedure
                            lanca_juro_contrato (Adriano).

               14/01/2014 - Alteracao referente a integracao Progress X
                            Dataserver Oracle
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

               24/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)

               29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).

               23/10/2014 - Ajuste na atualizacao do juros na tabela crapcot. (James)

               21/01/2015 - Ajuste na regra para quando o contrato for prejuizo. (James)

               26/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)

               02/02/2016 - Incluso novo parametro cdorigem. (Daniel)
               
               10/07/2019 - P437 - Consignado - Não considerar os contratos de emprestimos do consignado,
                            Josiane Stiehler (AMcom).
     ............................................................................. */

     DECLARE

       /* tabelas de Memoria */
       vr_tab_craplcr CADA0001.typ_tab_number;
       vr_tab_erro    GENE0001.typ_tab_erro;

       /*Cursores Locais */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
         FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       --Selecionar Linhas de Credito
       CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE) IS
         SELECT craplcr.cdlcremp
         FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper;

       --Selecionar Moedas
       CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                         ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
         SELECT crapmfx.cdcooper
               ,crapmfx.vlmoefix
         FROM   crapmfx
         WHERE crapmfx.cdcooper = pr_cdcooper
         AND   crapmfx.dtmvtolt = pr_dtmvtolt
         AND   crapmfx.tpmoefix = pr_tpmoefix;
       rw_crapmfx cr_crapmfx%ROWTYPE;

       --Selecionar Emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_tpemprst IN crapepr.tpemprst%TYPE) IS
         SELECT crapepr.inprejuz
               ,crapepr.dtprejuz
               ,crapepr.cdlcremp
               ,crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.vlsdeved
               ,crapepr.vljuracu
               ,crapepr.txjuremp
               ,crapepr.dtdpagto
               ,crapepr.dtmvtolt
               ,crapepr.cdagenci
               ,crapepr.cdbccxlt
               ,crapepr.nrdolote
               ,crapepr.vlemprst
               ,crapepr.qtpreemp
               ,crapepr.nrctaav1
               ,crapepr.nrctaav2
               ,crapepr.cdfinemp
               ,crapepr.diarefju
               ,crapepr.mesrefju
               ,crapepr.anorefju
               ,crapepr.qtmesdec
               ,crapepr.dtinipag
               ,crapepr.rowid
          FROM crapepr
          WHERE crapepr.cdcooper  = pr_cdcooper
          AND   crapepr.tpemprst  = pr_tpemprst
          AND   crapepr.inprejuz  = 0
          AND  (crapepr.vlsdeved  <> 0 OR crapepr.inliquid = 0)
          AND ((crapepr.tpemprst  = 1 AND -- P437-Consignado - não considerar emprestimo consignado
                  crapepr.tpdescto <> 2)
             OR (crapepr.tpemprst  <> 1))
          ORDER BY cdcooper,nrdconta,nrctremp;

       -- Cursor para buscar os Emprestimos que estao liquidados dentro do mes
       CURSOR cr_crapepr_liq (pr_cdcooper IN crapepr.cdcooper%TYPE
                             ,pr_tpemprst IN crapepr.tpemprst%TYPE
                             ,pr_dtamvini IN craplem.dtmvtolt%TYPE
                             ,pr_dtamvfin IN craplem.dtmvtolt%TYPE) IS
         SELECT crapepr.nrdconta,
                crapepr.nrctremp
           FROM crapepr
          WHERE crapepr.cdcooper  = pr_cdcooper
            AND crapepr.tpemprst  = pr_tpemprst
            AND crapepr.dtultpag >= pr_dtamvini
            AND crapepr.dtultpag <= pr_dtamvfin
            AND crapepr.vlsdeved  = 0
            AND crapepr.inliquid  = 1
            AND crapepr.inprejuz  = 0
            AND ((crapepr.tpemprst  = 1 AND -- P437-Consignado - não considerar emprestimo consignado
                  crapepr.tpdescto <> 2)
             OR (crapepr.tpemprst  <> 1)); 
            
       --Selecionar Parcelas emprestimo
       CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                         ,pr_nrdconta  IN crappep.nrdconta%TYPE
                         ,pr_nrctremp  IN crappep.nrctremp%TYPE
                         ,pr_dtvencto  IN crappep.dtvencto%TYPE) IS
         SELECT crappep.dtvencto
         FROM   crappep
         WHERE crappep.cdcooper = pr_cdcooper
         AND   crappep.nrdconta = pr_nrdconta
         AND   crappep.nrctremp = pr_nrctremp
         AND   trunc(crappep.dtvencto) = pr_dtvencto;
       rw_crappep cr_crappep%ROWTYPE;

       --Selecionar Cotas
       CURSOR cr_crapcot (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
         SELECT crapcot.ROWID
         FROM crapcot
         WHERE crapcot.cdcooper = pr_cdcooper
         AND   crapcot.nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;

       --Selecionar Registro de Microfilmagem
       CURSOR cr_crapmcr (pr_cdcooper IN crapmcr.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapmcr.dtmvtolt%TYPE
                         ,pr_cdagenci IN crapmcr.cdagenci%TYPE
                         ,pr_cdbccxlt IN crapmcr.cdbccxlt%TYPE
                         ,pr_nrdolote IN crapmcr.nrdolote%TYPE
                         ,pr_nrdconta IN crapmcr.nrdconta%TYPE
                         ,pr_nrcontra IN crapmcr.nrcontra%TYPE
                         ,pr_tpctrmif IN crapmcr.tpctrmif%TYPE) IS
         SELECT crapmcr.cdcooper
         FROM crapmcr
         WHERE crapmcr.cdcooper = pr_cdcooper
         AND   crapmcr.dtmvtolt = pr_dtmvtolt
         AND   crapmcr.cdagenci = pr_cdagenci
         AND   crapmcr.cdbccxlt = pr_cdbccxlt
         AND   crapmcr.nrdolote = pr_nrdolote
         AND   crapmcr.nrdconta = pr_nrdconta
         AND   crapmcr.nrcontra = pr_nrcontra
         AND   crapmcr.tpctrmif = pr_tpctrmif;
       rw_crapmcr cr_crapmcr%ROWTYPE;

       --Selecionar Detalhes Emprestimo
       CURSOR cr_crawepr (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crawepr.cdcooper
               ,crawepr.nrdconta
               ,crawepr.nrctremp
               ,crawepr.dtlibera
         FROM crawepr, crapepr
         WHERE crawepr.cdcooper = crapepr.cdcooper
         AND   crawepr.nrdconta = crapepr.nrdconta
         AND   crawepr.nrctremp = crapepr.nrctremp
         AND   crapepr.cdcooper = pr_cdcooper
         AND   crapepr.tpemprst = 1
         AND  (crapepr.vlsdeved <> 0 OR crapepr.inliquid = 0);

       CURSOR cr_craplem_sum(pr_cdcooper IN craplem.cdcooper%TYPE,
                             pr_nrdconta IN craplem.nrdconta%TYPE,
                             pr_nrctremp IN craplem.nrctremp%TYPE,
                             pr_dtamvini IN craplem.dtmvtolt%TYPE,
                             pr_dtamvfin IN craplem.dtmvtolt%TYPE) IS
         SELECT sum(craplem.vllanmto) as total
           FROM craplem
          WHERE craplem.cdcooper = pr_cdcooper
            AND craplem.nrdconta = pr_nrdconta
            AND craplem.nrctremp = pr_nrctremp
            AND craplem.cdhistor in (1037,1038)
            AND craplem.dtmvtolt >= pr_dtamvini
            AND craplem.dtmvtolt <= pr_dtamvfin;
       vr_vllanmto craplem.vllanmto%TYPE;

       --tabela de Memoria dos detalhes de emprestimo
       vr_tab_crawepr EMPR0001.typ_tab_crawepr;

       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS575';


       --Variaveis Locais
       vr_nrdconta INTEGER;
       vr_diarefju INTEGER;
       vr_mesrefju INTEGER;
       vr_anorefju INTEGER;
       vr_ehmensal BOOLEAN;
       vr_flnormal BOOLEAN;
       vr_dtvencto DATE;
       vr_dtinipag DATE;
       vr_vljurmes NUMBER;
       vr_nrctremp crapepr.nrctremp%TYPE;
       vr_vlsdeved crapepr.vlsdeved%TYPE;
       vr_vljuracu crapepr.vljuracu%TYPE;
       vr_txjuremp NUMBER(25,7);

       --Variaveis de Indices
       vr_index_crawepr VARCHAR2(30);

       --Variaveis para retorno de erro
       vr_des_erro      VARCHAR2(3);
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final     EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_craplcr.DELETE;
         vr_tab_crawepr.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS575.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_limpa_tabela;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS575
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Selecionar Valor Moeda
       OPEN cr_crapmfx (pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_tpmoefix => 2);
       FETCH cr_crapmfx INTO rw_crapmfx;
       --Se nao encontrou
       IF cr_crapmfx%NOTFOUND THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 140;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' da UFIR.';
         RAISE vr_exc_saida;
       END IF;

       --Limpar Tabela
       pc_limpa_tabela;

       --Carregar tabela linhas credito
       FOR rw_craplcr IN cr_craplcr (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craplcr(rw_craplcr.cdlcremp):= 0;
       END LOOP;

       --Carregar Tabela crawepr
       FOR rw_crawepr IN cr_crawepr (pr_cdcooper => pr_cdcooper) LOOP
         --Montar Indice
         vr_index_crawepr:= lpad(rw_crawepr.cdcooper,10,'0')||
                            lpad(rw_crawepr.nrdconta,10,'0')||
                            lpad(rw_crawepr.nrctremp,10,'0');
         vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crawepr.dtlibera;
       END LOOP;

       /*  Leitura dos contratos de emprestimos do associado  */
       FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                    ,pr_tpemprst => 1) LOOP

         --verificar Linha Credito
         IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
           -- Montar mensagem de critica
           vr_cdcritic:= 363;
           vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Complementar mensagem
           vr_dscritic:= vr_dscritic ||' - Linha = '||gene0002.fn_mask(rw_crapepr.cdlcremp,'zzz9');
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
           --Proximo registro
           CONTINUE;
         END IF;

         /*  Inicialiazacao das variaves para a rotina de calculo  */
         vr_nrdconta:= rw_crapepr.nrdconta;
         vr_nrctremp:= rw_crapepr.nrctremp;
         vr_vlsdeved:= rw_crapepr.vlsdeved;
         vr_vljuracu:= rw_crapepr.vljuracu;
         vr_txjuremp:= rw_crapepr.txjuremp;
         vr_vllanmto:= 0;

         --Selecionar Parcelas emprestimo
         OPEN cr_crappep (pr_cdcooper  => pr_cdcooper
                         ,pr_nrdconta  => vr_nrdconta
                         ,pr_nrctremp  => vr_nrctremp
                         ,pr_dtvencto  => trunc(rw_crapdat.dtmvtolt,'MM')); --mesmo ano e mes
         --Posicionar no Primeiro Registro
         FETCH cr_crappep INTO rw_crappep;
         --Se Encontrou
         IF cr_crappep%FOUND AND rw_crappep.dtvencto > rw_crapdat.dtmvtolt THEN
           --mensal
           vr_ehmensal:= FALSE;
           --Normal
           vr_flnormal:= TRUE;
           --vencimento
           vr_dtvencto:= rw_crappep.dtvencto;
         ELSE
           --mensal
           vr_ehmensal:= TRUE;
           --Normal
           vr_flnormal:= FALSE;
           --vencimento
           vr_dtvencto:= NULL;
         END IF;
         --Fechar Cursor
         CLOSE cr_crappep;

         /* Calcular o juro do contrato */
         EMPR0001.pc_lanca_juro_contrato (pr_cdcooper => pr_cdcooper           --Codigo Cooperativa
                                         ,pr_cdagenci => 1                     --Codigo Agencia
                                         ,pr_nrdcaixa => 0                     --Codigo Caixa
                                         ,pr_nrdconta => vr_nrdconta           --Numero da Conta
                                         ,pr_nrctremp => vr_nrctremp           --Numero Contrato
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Emprestimo
                                         ,pr_cdoperad => pr_cdoperad           --Operador
                                         ,pr_cdpactra => 1                     --Posto Atendimento
                                         ,pr_flnormal => vr_flnormal           --Lancamento Normal
                                         ,pr_dtvencto => vr_dtvencto           --Data vencimento
                                         ,pr_ehmensal => vr_ehmensal           --Indicador Mensal
                                         ,pr_dtdpagto => rw_crapepr.dtdpagto   --Data pagamento
                                         ,pr_tab_crawepr => vr_tab_crawepr     --Tabela com Contas e Contratos
                                         ,pr_cdorigem => 7 -- 7) Batch
                                         ,pr_vljurmes => vr_vljurmes           --Valor Juros no Mes
                                         ,pr_diarefju => vr_diarefju           --Dia Referencia Juros
                                         ,pr_mesrefju => vr_mesrefju           --Mes Referencia Juros
                                         ,pr_anorefju => vr_anorefju           --Ano Referencia Juros
                                         ,pr_tab_erro => vr_tab_erro           --tabela Erros
                                         ,pr_des_reto => vr_des_erro);         --Retorno Ok/NOK

         --Se ocorreu erro
         IF vr_des_erro <> 'OK' THEN
           -- Se tem erro
           IF vr_tab_erro.count > 0 THEN
             vr_cdcritic:= 0;
             vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
             --Proximo registro
             CONTINUE;
           END IF;
         END IF;

         /* Somar todos os JUROS REMUN. dentro do mês */
         OPEN cr_craplem_sum(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapepr.nrdconta,
                             pr_nrctremp => rw_crapepr.nrctremp,
                             pr_dtamvini => TO_DATE('01' || TO_CHAR(rw_crapdat.dtmvtolt,'/MM/RRRR'), 'DD/MM/RRRR'),
                             pr_dtamvfin => LAST_DAY(rw_crapdat.dtmvtolt));

         FETCH cr_craplem_sum
          INTO vr_vllanmto;
         CLOSE cr_craplem_sum;

         /*  Se teve juros pra lancar  */
         IF nvl(vr_vllanmto,0) > 0 THEN
           /*  Atualiza valor dos juros pagos em moeda fixa no crapcot  */
           OPEN cr_crapcot (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapepr.nrdconta);
           --Proximo Registro
           FETCH cr_crapcot INTO rw_crapcot;
           --Se nao encontrou
           IF cr_crapcot%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapcot;
             vr_cdcritic:= 169;
             vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Complementar Mensagem
             vr_dscritic:= vr_dscritic||' - CONTA = '||gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zz9.9');
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
             --Proximo registro
             CONTINUE;
           ELSE
             --Fechar Cursor
             CLOSE cr_crapcot;
             --Atualizar tabela cotas
             BEGIN
               UPDATE crapcot SET crapcot.qtjurmfx = nvl(crapcot.qtjurmfx,0) +
                                   ROUND(vr_vllanmto / rw_crapmfx.vlmoefix,4)
               WHERE crapcot.rowid = rw_crapcot.rowid;
             EXCEPTION
               WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar tabela crapcot. '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_saida;
             END;
           END IF;
         END IF;

         /*  Inicializa os meses decorridos para os contratos do mes  */
         IF to_char(rw_crapepr.dtmvtolt,'YYYYMM') = to_char(rw_crapdat.dtmvtolt,'YYYYMM') THEN

           /*** Criacao do registro para Microfilmagem dos Contratos ***/
           OPEN cr_crapmcr (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_crapepr.dtmvtolt
                           ,pr_cdagenci => rw_crapepr.cdagenci
                           ,pr_cdbccxlt => rw_crapepr.cdbccxlt
                           ,pr_nrdolote => rw_crapepr.nrdolote
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_nrcontra => rw_crapepr.nrctremp
                           ,pr_tpctrmif => 1); /*emprestimo*/
           FETCH cr_crapmcr INTO rw_crapmcr;
           --Se Encontrou
           IF cr_crapmcr%FOUND THEN
             --Fechar Cursor
             CLOSE cr_crapmcr;
             --Complementar Mensagem
             vr_dscritic:= 'ATENCAO: Contrato ja microfilmado. Conta: '||
                           gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zzz9.9')||'  Contrato: '||
                           gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9');
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
           ELSE
             --Fechar Cursor
             CLOSE cr_crapmcr;
             --Inserir registro microfilmagem
             BEGIN
               INSERT INTO crapmcr
                 (crapmcr.dtmvtolt
                 ,crapmcr.cdagenci
                 ,crapmcr.cdbccxlt
                 ,crapmcr.nrdolote
                 ,crapmcr.nrdconta
                 ,crapmcr.nrcontra
                 ,crapmcr.tpctrmif
                 ,crapmcr.vlcontra
                 ,crapmcr.qtpreemp
                 ,crapmcr.nrctaav1
                 ,crapmcr.nrctaav2
                 ,crapmcr.cdlcremp
                 ,crapmcr.cdfinemp
                 ,crapmcr.cdcooper)
               VALUES
                 (rw_crapepr.dtmvtolt
                 ,rw_crapepr.cdagenci
                 ,rw_crapepr.cdbccxlt
                 ,rw_crapepr.nrdolote
                 ,rw_crapepr.nrdconta
                 ,rw_crapepr.nrctremp
                 ,1
                 ,rw_crapepr.vlemprst
                 ,rw_crapepr.qtpreemp
                 ,nvl(rw_crapepr.nrctaav1,0)
                 ,nvl(rw_crapepr.nrctaav2,0)
                 ,rw_crapepr.cdlcremp
                 ,rw_crapepr.cdfinemp
                 ,pr_cdcooper);
             EXCEPTION
               WHEN OTHERS THEN
                 --Fechar Cursor
                 -- CLOSE cr_crapmcr; Já está sendo encerrado antes do insert
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao inserir CRAPMCR: '||rw_crapepr.nrdconta||'-'||rw_crapepr.nrctremp||'. '||SQLERRM;
                 --Levantar Excecao
                 --RAISE vr_exc_saida; Não parar o processo
                 -- Envio centralizado de log de erro
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                           ,pr_ind_tipo_log => 2 -- Erro tratato
                                           ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_dscritic );
                                                              
                 -- Limpar a variável de erro
                 vr_dscritic := NULL;
             END;
           END IF;
         END IF;

         --Valor Juros > 0
         IF nvl(vr_vljurmes,0) > 0   THEN
           --Dia/mes/Ano referencia Juros
           rw_crapepr.diarefju:= vr_diarefju;
           rw_crapepr.mesrefju:= vr_mesrefju;
           rw_crapepr.anorefju:= vr_anorefju;
         END IF;

         --Determinar Data Inicio Pagamento
         IF rw_crapepr.qtmesdec = 1 THEN
           --Primeiro dia mes
           vr_dtinipag:= trunc(rw_crapdat.dtmvtolt,'MM');
         ELSE
           vr_dtinipag:= rw_crapepr.dtinipag;
         END IF;

         --Atualizar Emprestimo
         BEGIN
           UPDATE crapepr SET crapepr.diarefju = rw_crapepr.diarefju
                             ,crapepr.mesrefju = rw_crapepr.mesrefju
                             ,crapepr.anorefju = rw_crapepr.anorefju
                             ,crapepr.vlsdeved = nvl(vr_vlsdeved,0) + nvl(vr_vljurmes,0)
                             ,crapepr.vljuracu = nvl(vr_vljuracu,0) + nvl(vr_vljurmes,0)
                             ,crapepr.vljurmes = nvl(crapepr.vljuratu,0) + nvl(vr_vljurmes,0)
                             ,crapepr.vljuratu = 0
                             ,crapepr.dtinipag = vr_dtinipag
                             ,crapepr.indpagto = 0
                             ,crapepr.vlpagmes = 0
           WHERE crapepr.rowid = rw_crapepr.rowid
           RETURNING crapepr.vlsdeved INTO rw_crapepr.vlsdeved;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao atualizar linha credito. '||SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_saida;
         END;

         --verifica se a linha de credito ja foi atualizada
         IF vr_tab_craplcr(rw_crapepr.cdlcremp) = 0 AND nvl(rw_crapepr.vlsdeved,0) > 0 THEN
           /*  Atualizacao do indicador de saldo devedor  */
           BEGIN
             UPDATE craplcr SET craplcr.flgsaldo = 1
             WHERE craplcr.cdcooper = pr_cdcooper
             AND   craplcr.cdlcremp = rw_crapepr.cdlcremp;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar linha credito. '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_saida;
           END;
           --Marcar que ja atualizou essa linha Emprestimo
           vr_tab_craplcr(rw_crapepr.cdlcremp):= 1;
         END IF;

       END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

       /* Leitura dos contratos que foram liquidados dentro do mes */
       FOR rw_crapepr IN cr_crapepr_liq (pr_cdcooper => pr_cdcooper,
                                         pr_tpemprst => 1,
                                         pr_dtamvini => TO_DATE('01' || TO_CHAR(rw_crapdat.dtmvtolt,'/MM/RRRR'), 'DD/MM/RRRR'),
                                         pr_dtamvfin => LAST_DAY(rw_crapdat.dtmvtolt)) LOOP

         vr_vllanmto:= 0;

         /* Somar todos os JUROS REMUN. dentro do mês */
         OPEN cr_craplem_sum(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapepr.nrdconta,
                             pr_nrctremp => rw_crapepr.nrctremp,
                             pr_dtamvini => TO_DATE('01' || TO_CHAR(rw_crapdat.dtmvtolt,'/MM/RRRR'), 'DD/MM/RRRR'),
                             pr_dtamvfin => LAST_DAY(rw_crapdat.dtmvtolt));

         FETCH cr_craplem_sum
          INTO vr_vllanmto;
         CLOSE cr_craplem_sum;

         /*  Se teve juros pra lancar  */
         IF nvl(vr_vllanmto,0) > 0 THEN

           /*  Atualiza valor dos juros pagos em moeda fixa no crapcot  */
           OPEN cr_crapcot (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapepr.nrdconta);
           --Proximo Registro
           FETCH cr_crapcot INTO rw_crapcot;
           --Se nao encontrou
           IF cr_crapcot%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapcot;
             vr_cdcritic:= 169;
             vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Complementar Mensagem
             vr_dscritic:= vr_dscritic||' - CONTA = '||gene0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zz9.9');
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
             --Proximo registro
             CONTINUE;
           ELSE
             --Fechar Cursor
             CLOSE cr_crapcot;
             --Atualizar tabela cotas
             BEGIN
               UPDATE crapcot SET crapcot.qtjurmfx = nvl(crapcot.qtjurmfx,0) +
                                   ROUND(vr_vllanmto / rw_crapmfx.vlmoefix,4)
               WHERE crapcot.rowid = rw_crapcot.rowid;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar tabela crapcot. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END;
           END IF;

         END IF; -- END IF nvl(vr_vllanmto,0) > 0 THEN

       END LOOP; -- END FOR rw_crapepr

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao da critica
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
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS575;
/
