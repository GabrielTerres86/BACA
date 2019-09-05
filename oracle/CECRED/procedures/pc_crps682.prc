CREATE OR REPLACE PROCEDURE CECRED.pc_crps682(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_cdagenci IN PLS_INTEGER DEFAULT 0   --> Codigo Agencia
                                             ,pr_idparale IN PLS_INTEGER DEFAULT 0   --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* .............................................................................

     Programa: pc_crps682
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Maio/2014                     Ultima atualizacao: 06/03/2018

     Dados referentes ao programa:

     Frequencia: Semanal (Segunda-feira)
     Objetivo  : Seleção de cooperados que terão crédito pré aprovado

     Alteracoes: 06/10/2014 - Ajuste para alimentar o campo crapcpa.vllimdis. (James)

                 07/10/2014 - Ajuste para quando tiver rodando o crps durante o dia,
                              no cursor crapsda pegar o dtmvtoan e quando tiver rodando
                              no processo batch utilizar dtmvtolt. (James)

                 29/10/2014 - Ajuste para copiar o relatorio para a pasta
                              /micros/cecred/preaprovado/carga/. (James)

                 03/11/2014 - Inclusao de titulo no cabecalho do arquivo TXT
                              da carga. (Jaison)

                 04/11/2014 - Inclusao de Calculo do Risco Cooperado quando
                              nao esta calculado e Alteracao dos nomes dos
                              arquivos de exportacao para SPC. (Jaison)

                 06/11/2014 - No cursor cr_crapass foi colocado o filtro
                              por tipo de conta. (Jaison)

                 20/11/2014 - Verificacao se eh geracao manual ou se processo
                              noturno esta rodando e tbm eh segunda-feira.
                              (Jaison)

                 04/12/2014 - Incluir validacao para verificar a idade do cooperado.
                              (James)

                              No momento da exportacao para o SERASA nao verificar o
                              campo crapass.flginspc. (James)

                              Incluir verificacao se o cooperado estah no CYBER.(James)

                 15/12/2014 - Incluir no arquivo de carga o telefone celular do cooperarado
                              (James)

                 30/12/2014 - Tratamento para evitar problema de divisor igual a zero quando
                              calculado os rendimentos brutos de pessoa juridica ( Renato - Supero )

                 17/08/2015 - Ajuste na busca do pior Risco, Projeto de Provisao. (James)

                 14/01/2016 - Pre-Aprovado fase II. (Jaison/Anderson)

                 16/02/2016 - Inclusão da coluna "Bloqueado" no relatorio de carga do pre-aprovado.
                              Alterado para no somatório de limites de cartão de crédito da adm. Bancoob,
                              considerar apenas os cartões cuja situação esteja [4 - em uso] (Anderson)

                 12/07/2016 - Pre-Aprovado fase III. (Lombardi)

                 03/02/2017 - Inclusao de mais um digito no campo de telefone do arquivo de pre-aprovado.
                              Andrey (Mouts) - Chamado 577203

                 19/06/2017 - Melhoria 441
                            - Nova regra de validação : verificar se a conta corrente do cooperado possui
                              uma carga manual vigente e liberada. (crítica 51-Carga Manual).
                            - Armazenamento de atributos de decisão. Todas as críticas deverão ser feitas e as
                              informações utilizadas deverão ser armazenadas para consultas posteriores.

                 30/08/2017 - Incluido commit antes de iniciar a manipulacao dos arquivos.
                              Melhorias na geracao de LOG de erros para identificar possiveis erros.
                              Heitor (Mouts)
                 13/12/2017 - Projeto Ligeirinho - Tratar paralelismo para ganho de performance - Mauro

                 06/03/2017 - Incluso procedimento para execução a partir da LANPRE. Cursor CRAPDAT precisou
                              ficar no mesmo Loop da leitura das Cooperativas - CRAPCOP - Mauro

                 20/03/2018 - Alterados cursores para retornar apenas contas com tipos de conta que
                              tenham o produto "25 – CREDITO PRE-APROVADO". PRJ366 (Lombardi).

                 30/04/2018 - Alterados codigos de situacao "ass.cdsitdct". PRJ366 (Lombardi).

                 23/05/2018 - Adicionado campo "dtvigencia" no where. PRJ366 (Lombardi).

                 15/06/2018 - Ao buscar os dados do cooperado de todas as agencias pelo cpf/cnpj,
                              não deve considerar as contas que estão na situação 4. (Renato - Supero)
                              
                 20/05/2019 - Ajustado para a nova versão do pre-aprovado, onde irá gerar somente os 
                              motivos selecionados (Petter - Envolti)

  ............................................................................ */

  DECLARE
    -- Codigo do programa
    vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS682';
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_idprglog   NUMBER;

    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca a Data Base Bacen
    CURSOR cr_max_opf IS
      SELECT MAX(dtrefere) AS dtrefere FROM crapopf;
    rw_max_opf cr_max_opf%ROWTYPE;

    -- Listagem de parametros
    CURSOR cr_crappre(pr_cdcooper IN crappre.cdcooper%TYPE
                     ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
      SELECT vlepratr
            ,qtepratr
            ,vlavlatr
            ,qtavlatr
            ,qtavlope
            ,vlcjgatr
            ,qtcjgatr
            ,qtcjgope
            ,vltitulo
            ,qtdtitul
            ,vlctaatr
            ,qtctaatr
            ,vldiaest
            ,qtdiaest
            ,qtdevolu
            ,vldiadev
            ,qtdiadev
            ,dslstali
            ,qtestour
        FROM crappre
       WHERE cdcooper = pr_cdcooper
         AND inpessoa = pr_inpessoa;
    rw_crappre_pf cr_crappre%ROWTYPE;
    rw_crappre_pj cr_crappre%ROWTYPE;

    -- Listagem de Operacoes Vencidas ou em Prejuizo
    CURSOR cr_crapvop(pr_nrcpfcgc IN crapvop.nrcpfcgc%TYPE
                     ,pr_dtrefere IN crapvop.dtrefere%TYPE
                     ,pr_dtmovto  IN DATE
                     ,pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT SUM(vlvencto) vlvencto
      FROM crapvop
      WHERE nrcpfcgc IN (SELECT ass.nrcpfcgc
                         FROM crapass ass
                         WHERE ass.cdcooper = pr_cdcooper
                           AND ass.nrcpfcnpj_base = pr_nrcpfcgc)
        AND dtrefere = pr_dtrefere
        AND (pr_dtmovto - pr_dtrefere) > 28
        AND ((cdvencto >= 205 AND cdvencto <= 290)   --> Operacoes Vencidas
               OR
             (cdvencto >= 310 AND cdvencto <= 330));  --> Operacoes em Prejuizo
      rw_crapvop cr_crapvop%ROWTYPE;

    -- Verifica se possui registro no CYBER
    CURSOR cr_crapcyb(pr_cdcooper        IN crapcyb.cdcooper%TYPE,
                      pr_nrcpfcnpj_base  IN crapass.nrcpfcnpj_base%TYPE,
                      pr_cdorigem        IN VARCHAR2,
                      pr_qtdiaatr        IN crapcyb.qtdiaatr%TYPE,
                      pr_qtddias         IN NUMBER,
                      pr_vlratrs         IN NUMBER) IS
      SELECT MAX(qtdiaatr) qtdiaatr
            ,MAX(vlpreapg) vlpreapg
        FROM crapcyb
       WHERE crapcyb.cdcooper = pr_cdcooper
         AND crapcyb.nrdconta IN (SELECT CASE WHEN ass.inpessoa = 2 THEN
                                           ass.nrdconta
                                         ELSE
                                           CASE WHEN NVL(ttl.idseqttl, 0) = 1 THEN
                                             ass.nrdconta
                                           END
                                         END conta
                                  FROM crapass ass
                                    LEFT JOIN crapttl ttl ON ttl.cdcooper = ass.cdcooper AND ttl.nrdconta = ass.nrdconta AND ROWNUM = 1
                                  WHERE ass.cdcooper = pr_cdcooper--crapcyb.cdcooper
                                    AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
         AND ','||pr_cdorigem||',' LIKE ('%,'||crapcyb.cdorigem||',%')
         AND crapcyb.qtdiaatr > pr_qtdiaatr
         AND crapcyb.dtdbaixa IS NULL
         AND qtdiaatr > pr_qtddias
         AND vlpreapg > pr_vlratrs;
    rw_crapcyb cr_crapcyb%ROWTYPE;

    -- Buscar qtd de controle dos saldos negativos e devolucoes de cheques
    CURSOR cr_crapneg_qtd (pr_cdcooper       IN crapneg.cdcooper%TYPE
                          ,pr_nrcpfcnpj_base IN crapneg.nrdconta%TYPE
                          ,pr_cdhisest       IN crapneg.cdhisest%TYPE
                          ,pr_dtiniest       IN crapneg.dtiniest%TYPE
                          ,pr_cdobserv VARCHAR2) IS
      SELECT COUNT(1) quantidade_estouros
            ,SUM(crapneg.vlestour) vlestou
            ,MAX(crapneg.qtdiaest) dias_estouro
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
         AND crapneg.nrdconta IN (SELECT CASE WHEN ass.inpessoa = 2 THEN
                                           ass.nrdconta
                                         ELSE
                                           CASE WHEN NVL(ttl.idseqttl, 0) = 1 THEN
                                             ass.nrdconta
                                           END
                                         END conta
                                  FROM crapass ass
                                    LEFT JOIN crapttl ttl ON ttl.cdcooper = ass.cdcooper AND ttl.nrdconta = ass.nrdconta AND ROWNUM = 1
                                  WHERE ass.cdcooper = pr_cdcooper--crapneg.cdcooper
                                    AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
         AND crapneg.cdhisest = pr_cdhisest
         AND crapneg.dtiniest >= pr_dtiniest
         AND (pr_cdobserv = '0'
          OR ','||pr_cdobserv||',' LIKE ('%,'||crapneg.cdobserv||',%'));
    rw_crapneg_qtd cr_crapneg_qtd%ROWTYPE;

    -- Buscar informacoes de operacoes como avalista
    CURSOR cr_avalist_qtd (pr_cdcooper       IN crapneg.cdcooper%TYPE
                          ,pr_nrcpfcnpj_base IN crapneg.nrdconta%TYPE) IS
      SELECT MAX(nvl(cyb.qtdiaatr,0)) dias_atraso   /* Dias em atraso */
            ,COUNT(1)                 qtd_operacoes /* Qtd. de Operações */
            ,SUM(case when cyb.flgpreju = 1
                      then nvl(cyb.vlsdprej,0)
                      else nvl(cyb.vlpreapg,0)
                  end) total_atraso                 /* Total em Atraso */
        FROM crapavl avl
        JOIN crapcyb cyb
          ON cyb.cdcooper = avl.cdcooper
         AND cyb.nrdconta = avl.nrctaavd
         AND cyb.cdorigem in (2,3)
         AND cyb.nrctremp = avl.nrctravd
       WHERE avl.cdcooper = pr_cdcooper
         AND avl.nrdconta IN (SELECT ass.nrdconta
                              FROM crapass ass
                              WHERE ass.cdcooper = cyb.cdcooper
                                AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base) /* Avalista */
         AND avl.tpctrato = 1           /* Emprestimo */
         AND cyb.dtdbaixa IS NULL;
    rw_avalist_qtd cr_avalist_qtd%ROWTYPE;
    
    -- Dados do Conjuge
    CURSOR cr_crapcje(pr_cdcooper       IN crapcje.cdcooper%TYPE
                     ,pr_nrcpfcnpj_base IN crapneg.nrdconta%TYPE
                     ,pr_idseqttl       IN crapcje.idseqttl%TYPE) IS
      SELECT crapcje.cdcooper
            ,crapcje.nrctacje
            ,crapcje.vlsalari
            ,NVL(crapass.nrcpfcgc, crapcje.nrcpfcjg) nrcpfcjg
      FROM crapcje, crapass
      WHERE crapcje.cdcooper = pr_cdcooper
        AND crapcje.nrdconta IN (SELECT ass.nrdconta
                                 FROM crapass ass
                                 WHERE ass.cdcooper = crapcje.cdcooper
                                   AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
        AND crapcje.idseqttl = pr_idseqttl
        AND crapcje.cdcooper = crapass.cdcooper(+)
        AND crapcje.nrctacje = crapass.nrdconta(+)
        AND rownum = 1
        AND EXISTS (SELECT 1
                    FROM crapcje cje,
                         crapttl ttl 
                    WHERE ttl.cdcooper = cje.cdcooper
                      AND ttl.nrdconta   = cje.nrdconta 
                      AND ttl.idseqttl   = cje.idseqttl
                      AND ttl.nrdconta   = crapcje.nrdconta --pr_nrdconta
                      AND ttl.cdcooper   = crapcje.cdcooper --pr_cdcooper
                      AND ttl.idseqttl   = 2);
    rw_crapcje cr_crapcje%ROWTYPE;

    -- Buscar informacoes de operacoes de conjuge
    CURSOR cr_conjuge_qtd (pr_cdcooper crapneg.cdcooper%TYPE
                          ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      SELECT MAX(nvl(cyb.qtdiaatr,0)) dias_atraso   /* Dias em atraso */
            ,COUNT(1)                 qtd_operacoes /* Qtd. de Operações */
            ,SUM(case when cyb.flgpreju = 1
                      then nvl(cyb.vlsdprej,0)
                      else nvl(cyb.vlpreapg,0)
                  end) total_atraso                 /* Total em Atraso */
        FROM crapcyb cyb
       WHERE cyb.cdcooper = pr_cdcooper
         AND cyb.nrdconta = pr_nrdconta
         AND cyb.cdorigem IN (2,3)
         AND cyb.dtdbaixa IS NULL;
    rw_conjuge_qtd cr_conjuge_qtd%ROWTYPE;

    -- Cursor de associados para a cooperativa
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT ass.nrcpfcnpj_base nrcpfcnpj_base
            ,ass.inpessoa
            ,cpa.cdsituacao
            ,cpa.iddcarga
      FROM crapass              ass
          ,crapcpa              cpa
          ,tbepr_carga_pre_aprv car
      WHERE cpa.cdcooper = ass.cdcooper
        AND cpa.tppessoa = ass.inpessoa
        AND cpa.nrcpfcnpj_base = ass.nrcpfcnpj_base
        AND cpa.iddcarga = car.idcarga
        AND car.indsituacao_carga  = 2
        AND car.flgcarga_bloqueada = 0
        AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
        AND cpa.cdsituacao IN ('A', 'B')
        AND ass.cdcooper = pr_cdcooper;

    -- Cursor para buscar atraso de titulos do Cyber
    CURSOR cr_cyber_tit(pr_cdcooper       IN crapcyb.cdcooper%TYPE
                       ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
      SELECT SUM(cyb.vlpreapg) + SUM(cyb.vljura60) vlraberto
            ,TRUNC(SYSDATE - MIN(tdb.dtvencto)) qtdiaatr
        FROM craptdb tdb
       INNER JOIN tbdsct_titulo_cyber tcy
          ON tcy.cdcooper = tdb.cdcooper
         AND tcy.nrdconta = tdb.nrdconta
         AND tcy.nrborder = tdb.nrborder
         AND tcy.nrtitulo = tdb.nrtitulo
       INNER JOIN crapcyb cyb
          ON cyb.cdcooper = tcy.cdcooper
         AND cyb.nrdconta = tcy.nrdconta
         AND cyb.nrctremp = tcy.nrctrdsc
       WHERE tdb.insittit = 4 -- liberado
         AND cyb.cdcooper = pr_cdcooper
         AND cyb.nrdconta IN (SELECT CASE WHEN ass.inpessoa = 2 THEN
                                       ass.nrdconta
                                     ELSE
                                       CASE WHEN NVL(ttl.idseqttl, 0) = 1 THEN
                                         ass.nrdconta
                                       END
                                     END conta
                              FROM crapass ass
                                LEFT JOIN crapttl ttl ON ttl.cdcooper = ass.cdcooper AND ttl.nrdconta = ass.nrdconta AND ROWNUM = 1
                              WHERE ass.cdcooper = pr_cdcooper--cyb.cdcooper
                                AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
         AND cyb.cdorigem = 4
         AND cyb.dtdbaixa IS NULL;
    rw_cyber_tit cr_cyber_tit%ROWTYPE;

    ------------------------------- VARIAVEIS -------------------------------
    vr_tipessoa    VARCHAR2(2);           --> Sigla Tipo de pessoa
    vr_flgachou    BOOLEAN;               --> Booleano para controle
    vr_inpessoa    crapass.inpessoa%TYPE; --> Tipo de pessoa
    vr_dslstali    crappre.dslstali%TYPE; --> Lista com codigos de alineas de devolucao de cheque
    vr_dslstali_pj VARCHAR2(4000);
    vr_dslstali_pf VARCHAR2(4000);
    vr_qtdiasut    INTEGER;               --> Quantidade de dias uteis
    vr_dtiniest    DATE;                  --> Data inicial para busca de estouro de conta
    vr_dtinidev    DATE;                  --> Data inicial para busca de devolucoes de cheques
    Nr_DConta      Crapass.Nrdconta%Type :=0;
    vr_vlepratr_pre_pf crappre.vlepratr%TYPE;
    vr_qtepratr_pre_pf crappre.qtepratr%TYPE;
    vr_vlavlatr_pre_pf crappre.vlavlatr%TYPE;
    vr_qtavlatr_pre_pf crappre.qtavlatr%TYPE;
    vr_qtavlope_pre_pf crappre.qtavlope%TYPE;
    vr_vlcjgatr_pre_pf crappre.vlcjgatr%TYPE;
    vr_qtcjgatr_pre_pf crappre.qtcjgatr%TYPE;
    vr_qtcjgope_pre_pf crappre.qtcjgope%TYPE;
    vr_vltitulo_pre_pf crappre.vltitulo%TYPE;
    vr_qtdtitul_pre_pf crappre.qtdtitul%TYPE;
    vr_vlctaatr_pre_pf crappre.vlctaatr%TYPE;
    vr_qtctaatr_pre_pf crappre.qtctaatr%TYPE;
    vr_vldiaest_pre_pf crappre.vldiaest%TYPE;
    vr_qtdiaest_pre_pf crappre.qtdiaest%TYPE;
    vr_qtdevolu_pre_pf crappre.qtdevolu%TYPE;
    vr_vldiadev_pre_pf crappre.vldiadev%TYPE;
    vr_qtdiadev_pre_pf crappre.qtdiadev%TYPE;
    vr_qtestour_pre_pf crappre.qtestour%TYPE;
    vr_vlepratr_pre_pj crappre.vlepratr%TYPE;
    vr_qtepratr_pre_pj crappre.qtepratr%TYPE;
    vr_vlavlatr_pre_pj crappre.vlavlatr%TYPE;
    vr_qtavlatr_pre_pj crappre.qtavlatr%TYPE;
    vr_qtavlope_pre_pj crappre.qtavlope%TYPE;
    vr_vlcjgatr_pre_pj crappre.vlcjgatr%TYPE;
    vr_qtcjgatr_pre_pj crappre.qtcjgatr%TYPE;
    vr_qtcjgope_pre_pj crappre.qtcjgope%TYPE;
    vr_vltitulo_pre_pj crappre.vltitulo%TYPE;
    vr_qtdtitul_pre_pj crappre.qtdtitul%TYPE;
    vr_vlctaatr_pre_pj crappre.vlctaatr%TYPE;
    vr_qtctaatr_pre_pj crappre.qtctaatr%TYPE;
    vr_vldiaest_pre_pj crappre.vldiaest%TYPE;
    vr_qtdiaest_pre_pj crappre.qtdiaest%TYPE;
    vr_qtdevolu_pre_pj crappre.qtdevolu%TYPE;
    vr_vldiadev_pre_pj crappre.vldiadev%TYPE;
    vr_qtdiadev_pre_pj crappre.qtdiadev%TYPE;
    vr_qtestour_pre_pj crappre.qtestour%TYPE;
    vr_vlepratr_pre    crappre.vlepratr%TYPE;
    vr_qtepratr_pre    crappre.qtepratr%TYPE;
    vr_vlavlatr_pre    crappre.vlavlatr%TYPE;
    vr_qtavlatr_pre    crappre.qtavlatr%TYPE;
    vr_qtavlope_pre    crappre.qtavlope%TYPE;
    vr_vlcjgatr_pre    crappre.vlcjgatr%TYPE;
    vr_qtcjgatr_pre    crappre.qtcjgatr%TYPE;
    vr_qtcjgope_pre    crappre.qtcjgope%TYPE;
    vr_vltitulo_pre    crappre.vltitulo%TYPE;
    vr_qtdtitul_pre    crappre.qtdtitul%TYPE;
    vr_vlctaatr_pre    crappre.vlctaatr%TYPE;
    vr_qtctaatr_pre    crappre.qtctaatr%TYPE;
    vr_vldiaest_pre    crappre.vldiaest%TYPE;
    vr_qtdiaest_pre    crappre.qtdiaest%TYPE;
    vr_qtdevolu_pre    crappre.qtdevolu%TYPE;
    vr_vldiadev_pre    crappre.vldiadev%TYPE;
    vr_qtdiadev_pre    crappre.qtdiadev%TYPE;
    vr_qtestour_pre    crappre.qtestour%TYPE;

    --Mauro
    -- ID para o paralelismo
    vr_qtdjobs       NUMBER;
    vr_idprglog      NUMBER;
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
    vr_idlog_ini_ger tbgen_prglog.idprglog%TYPE;
    vr_idlog_ini_par tbgen_prglog.idprglog%TYPE;
    vr_tpexecucao    tbgen_prglog.tpexecucao%TYPE;

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    vr_flgachou := BTCH0001.cr_crapdat%FOUND;
    CLOSE BTCH0001.cr_crapdat;

    -- Se nao achou
    IF NOT vr_flgachou THEN
       vr_cdcritic := 1;
       RAISE vr_exc_saida;
    END IF;

    -- Buscar parametros da CADPRE segmentada por tipo de pessoa
    -- Listagem de parametros PF
    OPEN cr_crappre(pr_cdcooper => pr_cdcooper, pr_inpessoa => 1);
    FETCH cr_crappre INTO rw_crappre_pf;
    CLOSE cr_crappre;

    -- Listagem de parametros PJ
    OPEN cr_crappre(pr_cdcooper => pr_cdcooper, pr_inpessoa => 2);
    FETCH cr_crappre INTO rw_crappre_pj;
    CLOSE cr_crappre;

    -- Listagem de Tipo de Pessoa
    FOR vr_inpessoa IN 1..2 LOOP
      IF vr_inpessoa = 1 THEN
         vr_tipessoa := 'PF';

         -- Emprestimos/Financiamentos
         vr_vlepratr_pre_pf := NVL(rw_crappre_pf.vlepratr, 0);
         vr_qtepratr_pre_pf := NVL(rw_crappre_pf.qtepratr, 0);
         -- Avalista
         vr_vlavlatr_pre_pf := NVL(rw_crappre_pf.vlavlatr, 0);
         vr_qtavlatr_pre_pf := NVL(rw_crappre_pf.qtavlatr, 0);
         vr_qtavlope_pre_pf := NVL(rw_crappre_pf.qtavlope, 0);
         -- Conjuge
         vr_vlcjgatr_pre_pf := NVL(rw_crappre_pf.vlcjgatr, 0);
         vr_qtcjgatr_pre_pf := NVL(rw_crappre_pf.qtcjgatr, 0);
         vr_qtcjgope_pre_pf := NVL(rw_crappre_pf.qtcjgope, 0);
         -- Borderô (Desconto de titulos)
         vr_vltitulo_pre_pf := NVL(rw_crappre_pf.vltitulo, 0);
         vr_qtdtitul_pre_pf := NVL(rw_crappre_pf.qtdtitul, 0);
         -- Conta corrente
         vr_vlctaatr_pre_pf := NVL(rw_crappre_pf.vlctaatr, 0);
         vr_qtctaatr_pre_pf := NVL(rw_crappre_pf.qtctaatr, 0);
         -- Estouro de conta corrente
         vr_vldiaest_pre_pf := NVL(rw_crappre_pf.vldiaest, 0);
         vr_qtdiaest_pre_pf := NVL(rw_crappre_pf.qtdiaest, 0);
         vr_qtestour_pre_pf := NVL(rw_crappre_pf.qtestour, 0);
         -- Cheques
         vr_qtdevolu_pre_pf := NVL(rw_crappre_pf.qtdevolu, 0);
         vr_vldiadev_pre_pf := NVL(rw_crappre_pf.vldiadev, 0);
         vr_qtdiadev_pre_pf := NVL(rw_crappre_pf.qtdiadev, 0);
         vr_dslstali_pf := REPLACE(rw_crappre_pj.dslstali, ';', ',');
      ELSE
         vr_tipessoa := 'PJ';

         -- Emprestimos/Financiamentos
         vr_vlepratr_pre_pj := NVL(rw_crappre_pj.vlepratr, 0);
         vr_qtepratr_pre_pj := NVL(rw_crappre_pj.qtepratr, 0);
         -- Avalista
         vr_vlavlatr_pre_pj := NVL(rw_crappre_pj.vlavlatr, 0);
         vr_qtavlatr_pre_pj := NVL(rw_crappre_pj.qtavlatr, 0);
         vr_qtavlope_pre_pj := NVL(rw_crappre_pj.qtavlope, 0);
         -- Conjuge
         vr_vlcjgatr_pre_pj := NVL(rw_crappre_pj.vlcjgatr, 0);
         vr_qtcjgatr_pre_pj := NVL(rw_crappre_pj.qtcjgatr, 0);
         vr_qtcjgope_pre_pj := NVL(rw_crappre_pj.qtcjgope, 0);
         -- Borderô (Desconto de titulos)
         vr_vltitulo_pre_pj := NVL(rw_crappre_pj.vltitulo, 0);
         vr_qtdtitul_pre_pj := NVL(rw_crappre_pj.qtdtitul, 0);
         -- Conta corrente
         vr_vlctaatr_pre_pj := NVL(rw_crappre_pj.vlctaatr, 0);
         vr_qtctaatr_pre_pj := NVL(rw_crappre_pj.qtctaatr, 0);
         -- Estouro de conta corrente
         vr_vldiaest_pre_pj := NVL(rw_crappre_pj.vldiaest, 0);
         vr_qtdiaest_pre_pj := NVL(rw_crappre_pj.qtdiaest, 0);
         vr_qtestour_pre_pj := NVL(rw_crappre_pf.qtestour, 0);
         -- Cheques
         vr_qtdevolu_pre_pj := NVL(rw_crappre_pj.qtdevolu, 0);
         vr_vldiadev_pre_pj := NVL(rw_crappre_pj.vldiadev, 0);
         vr_qtdiadev_pre_pj := NVL(rw_crappre_pj.qtdiadev, 0);
         vr_dslstali_pj := REPLACE(rw_crappre_pj.dslstali, ';', ',');
      END IF;
    END LOOP;
    
    -- Data de referencia BACEN
    OPEN cr_max_opf;
    FETCH cr_max_opf INTO rw_max_opf;
    CLOSE cr_max_opf;

    -- Buscar os cooperados que tenham pre-aprovado para bloquear ou recuperar
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
      -- Processar motivos somente para
      IF NVL(rw_crapass.iddcarga, 0) > 0 THEN
        -- Carregar variáveis do método por tipo de pessoa
        IF rw_crapass.inpessoa = 1 THEN
          vr_vlepratr_pre := vr_vlepratr_pre_pf;
          vr_qtepratr_pre := vr_qtepratr_pre_pf;
          vr_vlavlatr_pre := vr_vlavlatr_pre_pf;
          vr_qtavlatr_pre := vr_qtavlatr_pre_pf;
          vr_qtavlope_pre := vr_qtavlope_pre_pf;
          vr_vlcjgatr_pre := vr_vlcjgatr_pre_pf;
          vr_qtcjgatr_pre := vr_qtcjgatr_pre_pf;
          vr_qtcjgope_pre := vr_qtcjgope_pre_pf;
          vr_vltitulo_pre := vr_vltitulo_pre_pf;
          vr_qtdtitul_pre := vr_qtdtitul_pre_pf;
          vr_vlctaatr_pre := vr_vlctaatr_pre_pf;
          vr_qtctaatr_pre := vr_qtctaatr_pre_pf;
          vr_vldiaest_pre := vr_vldiaest_pre_pf;
          vr_qtdiaest_pre := vr_qtdiaest_pre_pf;
          vr_qtdevolu_pre := vr_qtdevolu_pre_pf;
          vr_vldiadev_pre := vr_vldiadev_pre_pf;
          vr_qtdiadev_pre := vr_qtdiadev_pre_pf;
          vr_qtestour_pre := vr_qtestour_pre_pf;
          vr_dslstali     := vr_dslstali_pf;
        ELSE
          vr_vlepratr_pre := vr_vlepratr_pre_pj;
          vr_qtepratr_pre := vr_qtepratr_pre_pj;
          vr_vlavlatr_pre := vr_vlavlatr_pre_pj;
          vr_qtavlatr_pre := vr_qtavlatr_pre_pj;
          vr_qtavlope_pre := vr_qtavlope_pre_pj;
          vr_vlcjgatr_pre := vr_vlcjgatr_pre_pj;
          vr_qtcjgatr_pre := vr_qtcjgatr_pre_pj;
          vr_qtcjgope_pre := vr_qtcjgope_pre_pj;
          vr_vltitulo_pre := vr_vltitulo_pre_pj;
          vr_qtdtitul_pre := vr_qtdtitul_pre_pj;
          vr_vlctaatr_pre := vr_vlctaatr_pre_pj;
          vr_qtctaatr_pre := vr_qtctaatr_pre_pj;
          vr_vldiaest_pre := vr_vldiaest_pre_pj;
          vr_qtdiaest_pre := vr_qtdiaest_pre_pj;
          vr_qtdevolu_pre := vr_qtdevolu_pre_pj;
          vr_vldiadev_pre := vr_vldiadev_pre_pj;
          vr_qtdiadev_pre := vr_qtdiadev_pre_pj;
          vr_qtestour_pre := vr_qtestour_pre_pj;
          vr_dslstali     := vr_dslstali_pj;
        END IF;

        OPEN cr_crapcyb(pr_cdcooper       => pr_cdcooper,
                        pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base,
                        pr_cdorigem       => '1', -- Conta
                        pr_qtdiaatr       => vr_qtctaatr_pre,
                        pr_qtddias        => vr_qtctaatr_pre,
                        pr_vlratrs        => vr_vlctaatr_pre);
        FETCH cr_crapcyb INTO rw_crapcyb;
         
        -- Controlar motivos
        IF cr_crapcyb%FOUND THEN
          IF rw_crapcyb.vlpreapg > vr_vlctaatr_pre AND rw_crapcyb.qtdiaatr > vr_qtctaatr_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 14
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 14
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 14
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        CLOSE cr_crapcyb;

        -- Calcula a data inicial para busca de estouro de conta
        vr_qtdiasut := 0;
        vr_dtiniest := rw_crapdat.dtmvtolt;

        WHILE vr_qtdiasut < vr_qtdiaest_pre LOOP
              vr_dtiniest := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                        ,pr_dtmvtolt => vr_dtiniest - 1
                                                        ,pr_tipo     => 'A');
              vr_qtdiasut := vr_qtdiasut + 1;
        END LOOP;

        -- Buscar qtd de estouro de conta
        OPEN cr_crapneg_qtd (pr_cdcooper => pr_cdcooper
                            ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                            ,pr_cdhisest => 5 -- Estouro
                            ,pr_dtiniest => vr_dtiniest
                            ,pr_cdobserv => '0');
        FETCH cr_crapneg_qtd INTO rw_crapneg_qtd;
        
        IF cr_crapneg_qtd%FOUND THEN
          -- Gerar ou remover motivo 16
          IF rw_crapneg_qtd.vlestou > vr_vldiaest_pre AND rw_crapneg_qtd.quantidade_estouros > vr_qtestour_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 16
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 16
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 16
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        CLOSE cr_crapneg_qtd;
        
        OPEN cr_crapcyb(pr_cdcooper        => pr_cdcooper,
                        pr_nrcpfcnpj_base  => rw_crapass.nrcpfcnpj_base,
                        pr_cdorigem        => '2,3', -- 2-Descontos / 3–Emprestimo
                        pr_qtdiaatr        => vr_qtepratr_pre,
                        pr_qtddias         => vr_qtepratr_pre,
                        pr_vlratrs         => vr_vlepratr_pre);
        FETCH cr_crapcyb INTO rw_crapcyb;
        
        IF cr_crapcyb%FOUND THEN
          IF rw_crapcyb.vlpreapg > vr_vlepratr_pre AND rw_crapcyb.qtdiaatr > vr_qtepratr_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 15
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE         
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 15
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);
   
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper   => pr_cdcooper
                                                ,pr_idcarga    => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo   => 15
                                                ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                                                ,pr_dscritic   => vr_dscritic);
 
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        CLOSE cr_crapcyb;

        -- Buscar informacoes de operacoes como avalista
        OPEN cr_avalist_qtd (pr_cdcooper => pr_cdcooper, pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base);
        FETCH cr_avalist_qtd INTO rw_avalist_qtd;

        IF cr_avalist_qtd%FOUND THEN
          -- Avaliar quantidade de dias em aberto com a CADPRE
          IF NVL(rw_avalist_qtd.dias_atraso, 0) > vr_qtavlatr_pre AND
             NVL(rw_avalist_qtd.total_atraso, 0) > vr_vlavlatr_pre AND
             NVL(rw_avalist_qtd.qtd_operacoes, 0) > vr_qtavlope_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 33
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 33
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 33
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;

        CLOSE cr_avalist_qtd;

        -- Buscar se o cooperado possui conjuge
        OPEN cr_crapcje(pr_cdcooper       => pr_cdcooper
                       ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                       ,pr_idseqttl       => 1);
        FETCH cr_crapcje INTO rw_crapcje;

        IF cr_crapcje%FOUND THEN
          -- Buscar informacoes de operacoes de conjuge
          OPEN cr_conjuge_qtd(pr_cdcooper => pr_cdcooper, pr_nrdconta => rw_crapcje.nrctacje);
          FETCH cr_conjuge_qtd INTO rw_conjuge_qtd;
          CLOSE cr_conjuge_qtd;
 
          -- Verificar se a situção do conjuge rompeu os limites da CADPRE
          IF NVL(rw_conjuge_qtd.total_atraso, 0) > vr_vlcjgatr_pre AND
             NVL(rw_conjuge_qtd.qtd_operacoes, 0) > vr_qtcjgope_pre AND
             NVL(rw_conjuge_qtd.dias_atraso, 0) > vr_qtcjgatr_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 54
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSIF NVL(rw_conjuge_qtd.total_atraso, 0) <= vr_vlcjgatr_pre OR
                NVL(rw_conjuge_qtd.qtd_operacoes, 0) <= vr_qtcjgope_pre OR
                NVL(rw_conjuge_qtd.dias_atraso, 0) <= vr_qtcjgatr_pre THEN
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 54
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Buscar prejuízo do conjuge
          OPEN cr_crapvop(pr_nrcpfcgc => rw_crapcje.nrcpfcjg
                         ,pr_dtrefere => rw_max_opf.dtrefere
                         ,pr_dtmovto => rw_crapdat.dtmvtolt
                         ,pr_cdcooper => pr_cdcooper);
          FETCH cr_crapvop INTO rw_crapvop;
          CLOSE cr_crapvop;

          -- Verificar se a situção do conjuge rompeu os limites da CADPRE
          IF rw_crapvop.vlvencto > 0 THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 54
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 54
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF;
        
        CLOSE cr_crapcje;

        -- Endividamento SFN
        OPEN cr_crapvop(pr_nrcpfcgc => rw_crapass.nrcpfcnpj_base
                       ,pr_dtrefere => rw_max_opf.dtrefere
                       ,pr_dtmovto => rw_crapdat.dtmvtolt
                       ,pr_cdcooper => pr_cdcooper);
        FETCH cr_crapvop INTO rw_crapvop;
        CLOSE cr_crapvop;

        -- Validar endividamento em aberto
        IF rw_crapvop.vlvencto > 0 THEN
          empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                              ,pr_idcarga         => rw_crapass.iddcarga
                                              ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                              ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                              ,pr_idmotivo        => 5
                                              ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                              ,pr_valoratr        => 0 --> valor não será mais enviado
                                              ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 5
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Calcula a data inicial para busca de devolucao de cheque
        vr_qtdiasut := 0;
        vr_dtinidev:= rw_crapdat.dtmvtolt;

        WHILE vr_qtdiasut < vr_qtdiadev_pre LOOP
          vr_dtinidev := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtinidev - 1
                                                    ,pr_tipo     => 'A');
          vr_qtdiasut := vr_qtdiasut + 1;
        END LOOP;

        -- Buscar qtd de devolucao de cheque
        OPEN cr_crapneg_qtd (pr_cdcooper => pr_cdcooper
                            ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                            ,pr_cdhisest => 1 -- Devolucao de Cheque
                            ,pr_dtiniest => vr_dtinidev
                            ,pr_cdobserv => vr_dslstali);
        FETCH cr_crapneg_qtd INTO rw_crapneg_qtd;

        IF cr_crapneg_qtd%FOUND THEN
          IF rw_crapneg_qtd.quantidade_estouros > vr_qtdevolu_pre AND rw_crapneg_qtd.vlestou > vr_vldiadev_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 13
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 13
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 13
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
       
        CLOSE cr_crapneg_qtd;
        
        -- Buscar titulos em aberto
        OPEN cr_cyber_tit(pr_cdcooper => pr_cdcooper, pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base);
        FETCH cr_cyber_tit INTO rw_cyber_tit;

        IF cr_cyber_tit%FOUND THEN
          IF rw_cyber_tit.vlraberto > vr_vltitulo_pre AND rw_cyber_tit.qtdiaatr > vr_qtdtitul_pre THEN
            empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_idmotivo        => 78
                                                ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                ,pr_valoratr        => 0 --> valor não será mais enviado
                                                ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                  ,pr_idcarga         => rw_crapass.iddcarga
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                  ,pr_idmotivo        => 78
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_dscritic        => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                                ,pr_idcarga         => rw_crapass.iddcarga
                                                ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base
                                                ,pr_idmotivo        => 78
                                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF; 
        
        CLOSE cr_cyber_tit;
        
      END IF;
    END LOOP;

    -- Grava LOG de ocorrência final do cursor cr_crapcop
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Consistencias finais: '||pr_cdagenci||' - INPROCES: '||rw_crapdat.inproces,
                    PR_IDPRGLOG           => vr_idlog_ini_par);

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
    COMMIT;

    IF pr_idparale = 0 THEN
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

      IF vr_idcontrole <> 0 THEN
      -- Atualiza finalização do batch na tabela de controle
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => vr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);

        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
      END IF;

      IF vr_qtdjobs > 0 THEN
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger,
                        pr_flgsucesso => 1);
      END IF;

      --Salvar informacoes no banco de dados
      COMMIT;
    ELSE
      -- Atualiza finalização do batch na tabela de controle
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => vr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                ,pr_des_erro => vr_dscritic);

      --Salvar informacoes no banco de dados
      COMMIT;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Erro: '||pr_cdagenci||' '||pr_dscritic ,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      IF pr_idparale <> 0 THEN
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => pr_dscritic);
      END IF;

      -- Efetuar rollback
      ROLLBACK;

      IF pr_idparale <> 0 THEN
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => pr_dscritic);
      END IF;

      COMMIT;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM||' Nr Conta '||Nr_DConta;

      pc_internal_exception(pr_cdcooper => pr_cdcooper);


      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Erro1: '||pr_cdagenci||' '||pr_dscritic ,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      -- Efetuar rollback
      ROLLBACK;

      IF pr_idparale <> 0 THEN
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => pr_dscritic);
      END IF;

      COMMIT;
  END;
END pc_crps682;