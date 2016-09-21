CREATE OR REPLACE PROCEDURE CECRED.pc_crps682(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padr�o para utiliza��o de restart
                                             ,pr_flgexpor IN PLS_INTEGER             --> Flag de controle de exportacao para SPC/Serasa
                                             ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* .............................................................................

     Programa: pc_crps682
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Maio/2014                     Ultima atualizacao: 14/01/2016

     Dados referentes ao programa:

     Frequencia: Semanal (Segunda-feira)
     Objetivo  : Sele��o de cooperados que ter�o cr�dito pr� aprovado

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

                 16/02/2016 - Inclus�o da coluna "Bloqueado" no relatorio de carga do pre-aprovado.
                              Alterado para no somat�rio de limites de cart�o de cr�dito da adm. Bancoob,
                              considerar apenas os cart�es cuja situa��o esteja [4 - em uso] (Anderson)
                              
                 12/07/2016 - Pre-Aprovado fase III. (Lombardi)
                              
  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS682';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.vllimmes
            ,cop.vlmaxleg
            ,cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1;

    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca a Data Base Bacen
    CURSOR cr_max_opf IS
      SELECT MAX(dtrefere) AS dtrefere
        FROM crapopf;
    rw_max_opf cr_max_opf%ROWTYPE;

    -- Cadastro de associados
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_inpessoa IN crapass.inpessoa%TYPE
                     ,pr_cdsitdct IN VARCHAR2) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inrisctl
            ,ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.inserasa
            ,ass.cdsitdct
            ,ass.nmprimtl
            ,ass.dtdemiss
            ,ass.cdagenci
            ,ass.dtadmiss
            /* Se a conta estiver sem pre-aprovado e o operador estiver
               preechido, significa que foi bloqueado manualmente atrav�s da tela contas */
            ,case when (par.flglibera_pre_aprv = 0)
                  then 'SIM'
                  else 'NAO'
             end bloqueado
            ,cdsitdtl
        FROM crapass ass        
   LEFT JOIN tbepr_param_conta par
          ON par.cdcooper = ass.cdcooper
         AND par.nrdconta = ass.nrdconta
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.dtdemiss IS NULL
         AND ass.dtelimin IS NULL
         AND ','||pr_cdsitdct||',' LIKE ('%,'||ass.cdsitdct||',%')
         AND ass.cdtipcta IN (1, 2, 3, 4, 8, 9, 10, 11)
         AND ass.inpessoa = pr_inpessoa;

    -- Listagem de parametros
    CURSOR cr_crappre(pr_cdcooper IN crappre.cdcooper%TYPE
                     ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
      SELECT dssitdop, nrmcotas, vllimmin, vlpercom, nrrevcad,
             vlmaxleg, vlmulpli, cdfinemp, qtmescta, qtmesadm,
             qtmesemp, qtctaatr, qtepratr, qtestour, qtdiaest,
             dslstali, qtdevolu, qtdiadev, qtavlatr, vlavlatr,
             qtavlope, qtcjgatr, vlcjgatr, qtcjgope, qtdiaver
        FROM crappre                      
       WHERE cdcooper = pr_cdcooper       
         AND inpessoa = pr_inpessoa;      
    rw_crappre_pf cr_crappre%ROWTYPE;     
    rw_crappre_pj cr_crappre%ROWTYPE;     

    -- Risco com divida (Valor Arrasto)
    CURSOR cr_ris_comdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_inddocto IN crapris.inddocto%TYPE
                        ,pr_vldivida IN crapris.vldivida%TYPE) IS
      SELECT MAX(innivris) innivris
        FROM crapris
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtrefere = pr_dtrefere
         AND inddocto = pr_inddocto
         AND vldivida > pr_vldivida;
    rw_ris_comdiv cr_ris_comdiv%ROWTYPE;

    -- Risco sem divida
    CURSOR cr_ris_semdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_inddocto IN crapris.inddocto%TYPE) IS
      SELECT MAX(innivris) innivris
        FROM crapris
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtrefere = pr_dtrefere
         AND inddocto = pr_inddocto;
    rw_ris_semdiv cr_ris_semdiv%ROWTYPE;

    -- Listagem de alteracoes cadastrais
    CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                     ,pr_nrdconta IN crapalt.nrdconta%TYPE
                     ,pr_dtaltera IN crapalt.dtaltera%TYPE) IS
      SELECT dtaltera
        FROM crapalt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtaltera >= pr_dtaltera
         AND tpaltera = 1; --> Recadastramento
    rw_crapalt cr_crapalt%ROWTYPE;

    -- Listagem de Operacoes Vencidas ou em Prejuizo
    CURSOR cr_crapvop(pr_nrcpfcgc IN crapvop.nrcpfcgc%TYPE
                     ,pr_dtrefere IN crapvop.dtrefere%TYPE) IS
      SELECT dtrefere
        FROM crapvop
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND dtrefere = pr_dtrefere
         AND (
              (cdvencto >= 205 AND cdvencto <= 290) --> Operacoes Vencidas
               OR
              (cdvencto >= 310 AND cdvencto <= 330) --> Operacoes em Prejuizo
             );
    rw_crapvop cr_crapvop%ROWTYPE;

    -- Listagem de Parcelas a vencer de 60 a 90 dias
    CURSOR cr_crapvop_avc(pr_nrcpfcgc IN crapvop.nrcpfcgc%TYPE
                         ,pr_dtrefere IN crapvop.dtrefere%TYPE) IS
      SELECT vlvencto
        FROM crapvop
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND dtrefere = pr_dtrefere
         -- Desconsiderar desconto de duplicatas e desconto de cheques
         AND cdmodali NOT IN ('0301','0302')
         AND cdvencto = 130;

    -- Listagem de saldos diarios
    CURSOR cr_crapsda(pr_cdcooper IN crapsda.cdcooper%TYPE
                     ,pr_nrdconta IN crapsda.nrdconta%TYPE
                     ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE) IS
      SELECT vlsdcota
            ,vlsdempr
            ,vlsdfina
            ,vllimcre
            ,vllimtit
            ,vllimdsc
        FROM crapsda
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND nrdconta = pr_nrdconta;
    rw_crapsda cr_crapsda%ROWTYPE;

    -- Listagem dos Cartoes de Credito
    CURSOR cr_crawcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE
                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
      SELECT cdcooper
            ,cdadmcrd
            ,tpcartao
            ,cdlimcrd
            ,insitcrd
            ,vllimcrd
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    -- Listagem dos Limites de Cartoes de Credito
    CURSOR cr_craptlc(pr_cdcooper IN craptlc.cdcooper%TYPE
                     ,pr_cdadmcrd IN craptlc.cdadmcrd%TYPE
                     ,pr_tpcartao IN craptlc.tpcartao%TYPE
                     ,pr_cdlimcrd IN craptlc.cdlimcrd%TYPE) IS
      SELECT vllimcrd
        FROM craptlc
       WHERE cdcooper = pr_cdcooper
         AND cdadmcrd = pr_cdadmcrd
         AND tpcartao = pr_tpcartao
         AND cdlimcrd = pr_cdlimcrd
         AND dddebito = 0;
    rw_craptlc cr_craptlc%ROWTYPE;

    -- Dados do Conjuge
    CURSOR cr_crapcje(pr_cdcooper IN crapcje.cdcooper%TYPE
                     ,pr_nrdconta IN crapcje.nrdconta%TYPE
                     ,pr_idseqttl IN crapcje.idseqttl%TYPE) IS
      SELECT crapcje.cdcooper
            ,crapcje.nrctacje
            ,crapcje.vlsalari
            ,NVL(crapass.nrcpfcgc, crapcje.nrcpfcjg) nrcpfcjg
     FROM crapcje, crapass
    WHERE crapcje.cdcooper = pr_cdcooper
      AND crapcje.nrdconta = pr_nrdconta
      AND crapcje.idseqttl = pr_idseqttl
      AND crapcje.cdcooper = crapass.cdcooper(+)
      AND crapcje.nrctacje = crapass.nrdconta(+);
    rw_crapcje cr_crapcje%ROWTYPE;

    -- Listagem dos Rendimentos de PJ
    CURSOR cr_crapjfn(pr_cdcooper IN crapcje.cdcooper%TYPE
                     ,pr_nrdconta IN crapcje.nrdconta%TYPE) IS
      SELECT vlrftbru##1
            ,vlrftbru##2
            ,vlrftbru##3
            ,vlrftbru##4
            ,vlrftbru##5
            ,vlrftbru##6
            ,vlrftbru##7
            ,vlrftbru##8
            ,vlrftbru##9
            ,vlrftbru##10
            ,vlrftbru##11
            ,vlrftbru##12
        FROM crapjfn
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;

    -- Somatoria do Credito Pre Aprovado utilizado
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_cdfinemp IN crapepr.cdfinemp%TYPE) IS
      SELECT NVL(SUM(vlsdeved), 0) vlsdeved
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND inliquid = 0 --> Nao liquidado
         AND cdfinemp = pr_cdfinemp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- Dados da Linha de Credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT txmensal
            ,nrfimpre
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    -- Busca dados do Titular
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                     ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT nrcpfcgc
            ,dtnasttl
            ,vlsalari
            ,vldrendi##1
            ,vldrendi##2
            ,vldrendi##3
            ,vldrendi##4
            ,vldrendi##5
            ,vldrendi##6
            ,dtadmemp
            ,tpcttrab
        FROM crapttl
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Busca dados da empresa
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT dtiniatv
        FROM crapjur
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    -- Busca as Contas do Cooperado
    CURSOR cr_contas_coop(pr_cdcooper IN crapttl.cdcooper%TYPE
                         ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE
                         ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT ttl.cdcooper
            ,ttl.nrdconta
        FROM crapttl ttl
            ,crapass ass
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrcpfcgc = pr_nrcpfcgc
         AND ttl.idseqttl = pr_idseqttl
         AND ttl.cdcooper = ass.cdcooper
         AND ttl.nrdconta = ass.nrdconta
         AND ass.dtdemiss IS NULL;

    -- Busca a Ultima Data de Alteracao e Conta
    CURSOR cr_max_alt(pr_cdcooper IN crapalt.cdcooper%TYPE
                     ,pr_nrdconta IN crapalt.nrdconta%TYPE) IS
      SELECT MAX(dtaltera) AS dtaltera
            ,nrdconta
        FROM crapalt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
    GROUP BY nrdconta;
    rw_max_alt cr_max_alt%ROWTYPE;

    -- Verifica se possui registro no CYBER
    CURSOR cr_crapcyb(pr_cdcooper IN crapcyb.cdcooper%TYPE,
                      pr_nrdconta IN crapcyb.nrdconta%TYPE,
                      pr_cdorigem VARCHAR2,
                      pr_qtdiaatr IN crapcyb.qtdiaatr%TYPE) IS
      SELECT qtdiaatr
        FROM crapcyb
       WHERE crapcyb.cdcooper = pr_cdcooper
         AND crapcyb.nrdconta = pr_nrdconta
         AND ','||pr_cdorigem||',' LIKE ('%,'||crapcyb.cdorigem||',%')
         AND crapcyb.qtdiaatr > pr_qtdiaatr
         AND crapcyb.dtdbaixa IS NULL
         AND ROWNUM = 1;
    rw_crapcyb cr_crapcyb%ROWTYPE;

    -- Seleciona o telefone do cooperado
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type
                      ,pr_idseqttl IN craptfc.idseqttl%type
                      ,pr_tptelefo IN craptfc.tptelefo%type) IS
      SELECT craptfc.nrdddtfc,
             craptfc.nrtelefo
        FROM craptfc
       WHERE craptfc.cdcooper = pr_cdcooper
         AND craptfc.nrdconta = pr_nrdconta
         AND craptfc.idseqttl = pr_idseqttl
         AND craptfc.tptelefo = pr_tptelefo
       ORDER BY craptfc.progress_recid ASC;
    rw_craptfc cr_craptfc%ROWTYPE;

    -- Verifica de tem aluguel
    CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%type
                      ,pr_nrdconta IN crapenc.nrdconta%type
                      ,pr_idseqttl IN crapenc.idseqttl%TYPE) IS
      SELECT NVL(SUM(vlalugue), 0)
        FROM crapenc
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = pr_idseqttl
         AND incasprp = 3; -- Alugado

    -- Buscar qtd de controle dos saldos negativos e devolucoes de cheques
    CURSOR cr_crapneg_qtd (pr_cdcooper crapneg.cdcooper%TYPE
                          ,pr_nrdconta crapneg.nrdconta%TYPE
                          ,pr_cdhisest crapneg.cdhisest%TYPE
                          ,pr_dtiniest crapneg.dtiniest%TYPE
                          ,pr_cdobserv VARCHAR2) IS
      SELECT COUNT(1)
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
         AND crapneg.nrdconta = pr_nrdconta
         AND crapneg.cdhisest = pr_cdhisest
         AND crapneg.dtiniest >= pr_dtiniest
         AND (pr_cdobserv = '0'
          OR ','||pr_cdobserv||',' LIKE ('%,'||crapneg.cdobserv||',%'));
    
    -- Buscar informacoes de operacoes como avalista
    CURSOR cr_avalist_qtd (pr_cdcooper crapneg.cdcooper%TYPE
                          ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      SELECT MAX(nvl(cyb.qtdiaatr,0)) dias_atraso   /* Dias em atraso */
            ,COUNT(1)                 qtd_operacoes /* Qtd. de Opera��es */
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
         AND avl.nrdconta = pr_nrdconta /* Avalista */
         AND avl.tpctrato = 1           /* Emprestimo */
         AND cyb.dtdbaixa IS NULL;
    rw_avalist_qtd cr_avalist_qtd%ROWTYPE;

    -- Buscar informacoes de operacoes de conjuge
    CURSOR cr_conjuge_qtd (pr_cdcooper crapneg.cdcooper%TYPE
                          ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      SELECT MAX(nvl(cyb.qtdiaatr,0)) dias_atraso   /* Dias em atraso */
            ,COUNT(1)                 qtd_operacoes /* Qtd. de Opera��es */
            ,SUM(nvl(cyb.vlpreapg,0)) total_atraso  /* Total em Atraso */
        FROM crapcyb cyb
       WHERE cyb.cdcooper = pr_cdcooper
         AND cyb.nrdconta = pr_nrdconta
         AND cyb.cdorigem IN (2,3)
         AND cyb.dtdbaixa IS NULL;
    rw_conjuge_qtd cr_conjuge_qtd%ROWTYPE;
    
    -- Busca operacoes inclusas
    CURSOR cr_opera_inclusas (pr_cdcooper crapneg.cdcooper%TYPE
                             ,pr_nrdconta crapneg.nrdconta%TYPE
                             ,pr_qtdiaver crappre.qtdiaver%TYPE) IS
      SELECT nvl(SUM(epr.vlpreemp),0) vlpreemp
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.dtmvtolt >= trunc(SYSDATE) - pr_qtdiaver
         AND epr.inliquid = 0;
    rw_opera_inclusas cr_opera_inclusas%ROWTYPE;
    
    -- Buscar dados dos riscos do pre-aprovado
    CURSOR cr_riscos IS
      SELECT epr.cdcooper
            ,epr.inpessoa
            ,ris.dsrisco
            ,nvl(epr.vllimite,0) vllimite
            ,nvl(epr.cdlcremp,0) cdlcremp
        FROM (SELECT LEVEL AS cdrisco
                     ,DECODE(LEVEL,1,'AA',2,'A',3,'B',4,'C'
                             ,5,'D',6,'E',7,'F',8,'G',9,'H'
                             ,10,'HH') AS dsrisco
                 FROM dual
                WHERE LEVEL NOT IN (1,10)
              CONNECT BY LEVEL <= 10) ris
         JOIN tbepr_linha_pre_aprv epr
           ON epr.cdrisco = ris.cdrisco
        ORDER BY epr.cdcooper, epr.inpessoa, ris.dsrisco;
    
    -- Busca dados do cooperado de todas as agencias pelo cpf/cnpj
    CURSOR cr_crapass_cpfcnpj (pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      select ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
            ,ass.inrisctl
            ,ass.dtmvtolt
        from crapass ass
       where ass.nrcpfcgc = pr_nrcpfcgc
         and ass.cdsitdct in (1,3,5,6,9);
    
    -- Verifica se pre aprovado esta liberado
    CURSOR cr_param_conta (pr_cdcooper crapneg.cdcooper%TYPE
                          ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      SELECT flglibera_pre_aprv
        FROM tbepr_param_conta 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_param_conta cr_param_conta%ROWTYPE;
    
    -- Verifica se cooperado esta inserido na tela Alerta
    CURSOR cr_crapcrt (pr_nrcpfcgc crapcrt.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM crapcrt
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND cdsitreg = 1 /* Inserido */
         AND ROWNUM = 1;
    rw_crapcrt cr_crapcrt%ROWTYPE;
    
    -- Busca titular da conta com opera��o em Preju�zo
    CURSOR cr_titopepre (pr_cdcooper crapneg.cdcooper%TYPE
                        ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      select epr.cdcooper
        from crapepr epr
       where epr.cdcooper = pr_cdcooper
         and epr.nrdconta = pr_nrdconta
         and epr.vlsdprej > 0 
         and epr.inprejuz = 1
         and rownum = 1;
    rw_titopepre cr_titopepre%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Tabela temporaria para os tipos de risco
    TYPE typ_reg_craptab IS RECORD(dsdrisco craptab.dstextab%TYPE);
    TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY PLS_INTEGER;
    -- Vetor para armazenar os riscos
    vr_tab_craptab typ_tab_craptab;

    -- Tabela temporaria para os CPF/CNPJ
    TYPE typ_reg_cpfcnpj IS RECORD(nrcpfcgc VARCHAR2(14)
                                  ,inpessoa crapass.inpessoa%TYPE);
    TYPE typ_tab_cpfcnpj IS TABLE OF typ_reg_cpfcnpj INDEX BY VARCHAR2(14);
    -- Vetor para armazenar os CPF/CNPJ
    vr_tab_cpfcnpj typ_tab_cpfcnpj;
    
    -- Tabela temporaria para os Riscos
    TYPE typ_reg_risco IS RECORD(vllimite tbepr_linha_pre_aprv.vllimite%TYPE
                                ,cdlcremp tbepr_linha_pre_aprv.cdlcremp%TYPE);
    TYPE typ_tab_risco IS TABLE OF typ_reg_risco INDEX BY VARCHAR2(10);
    -- Vetor para armazenar os Riscos
    vr_tab_risco typ_tab_risco;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_tipessoa    VARCHAR2(2);           --> Sigla Tipo de pessoa
    vr_cdsitdct    crappre.dssitdop%TYPE; --> Situacoes das contas
    vr_cdsit_pf    crappre.dssitdop%TYPE; --> Situacoes das contas PF
    vr_cdsit_pj    crappre.dssitdop%TYPE; --> Situacoes das contas PJ
    vr_arqhandl    utl_file.file_type;    --> Handle do arquivo aberto
    vr_arqhand2    utl_file.file_type;    --> Handle do arquivo aberto
    vr_arq_path    VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
    vr_path_cop    VARCHAR2(1000);        --> Diretorio que sera a copia do relatorio
    vr_arq_nome    VARCHAR2(100);         --> Nome do arquivo
    vr_arq_temp    VARCHAR2(100);         --> Nome do arquivo Temporario
    vr_arq_nom2    VARCHAR2(100);         --> Nome do arquivo
    vr_arq_tmp2    VARCHAR2(100);         --> Nome do arquivo Temporario
    vr_dscomand    VARCHAR2(1000);        --> Comando de conversao ux2dos
    vr_typsaida    VARCHAR2(3);           --> Retorno da execucao
    vr_vet_rend    GENE0002.typ_split;    --> Array para guardar o split dos Rendimentos
    vr_flgachou    BOOLEAN;               --> Booleano para controle
    vr_proxregi    BOOLEAN;               --> Booleano para controle
    vr_vlmaximo    crapcop.vlmaxleg%TYPE; --> Total de Valor Maximo Legal
    vr_dstextab    VARCHAR2(1000);        --> Campo da tabela generica
    vr_vlarrast    NUMBER;                --> Valor Arrasto
    vr_dtaltera    DATE;                  --> Data de revisao cadastral
    vr_nivrisco    VARCHAR2(2);           --> Nivel de Risco
    vr_notacoop    NUMBER;                --> Nota do Risco Cooperado
    vr_riscoope    VARCHAR2(2);           --> Risco Cooperado
    vr_riscoass    VARCHAR2(2);           --> Risco Cooperado
    vr_riscodiv    VARCHAR2(2);           --> Risco Cooperado com/sem divida
    vr_inpessoa    crapass.inpessoa%TYPE; --> Tipo de pessoa
    vr_vllimmax    NUMBER;                --> Valor Limite M�ximo
    vr_vlsdcota    crapsda.vlsdcota%TYPE; --> Saldo de Cotas
    vr_vldescon    crapsda.vlsdcota%TYPE; --> Valor para Desconto
    vr_vlimcota    crapsda.vlsdcota%TYPE; --> Valor Limitado de Cotas
    vr_vlalugue    NUMBER;                --> Valor de aluguel
    vr_vlparcav    NUMBER;                --> Valor de parcelas a vencer
    vr_vltotren    NUMBER;                --> Valor total de Rendimento
    vr_nummeses    NUMBER;                --> Numero de meses
    vr_flgmaior    BOOLEAN;               --> Flag para maior de Idade
    vr_vlrendim    NUMBER;                --> Valor de Rendimento
    vr_dtadmemp    DATE;                  --> Data de admissao do titular na empresa
    vr_tpcttrab    NUMBER;                --> Tipo ctr.trabalho
    vr_vlmaxpar    NUMBER(25, 2);         --> Valor Maximo de Parcela
    vr_vlsldcpa    crapepr.vlsdeved%TYPE; --> Credito Pre Aprovado contratado
    vr_vlpresen    NUMBER(25, 2);         --> Valor calculado presente (PV)
    vr_txjurmes    NUMBER(25, 10);        --> Taxa de Juros Mensal
    vr_qtmaxpar    NUMBER(10);            --> Quantidade maxima de parcelas
    vr_txjur_pf    NUMBER(25, 10);        --> Taxa de Juros Mensal PF
    vr_qtpar_pf    NUMBER(10);            --> Quantidade maxima de parcelas PF
    vr_txjur_pj    NUMBER(25, 10);        --> Taxa de Juros Mensal PJ
    vr_qtpar_pj    NUMBER(10);            --> Quantidade maxima de parcelas PJ
    vr_dtdolaco    DATE;                  --> Data de Alteracao do looping
    vr_nrdconta    NUMBER;                --> Numero da conta do looping
    vr_nrmcotas    crappre.nrmcotas%TYPE; --> Numero de Cotas
    vr_cdfinemp    crappre.cdfinemp%TYPE; --> Codigo da Finalidade
    vr_vllimmin    crappre.vllimmin%TYPE; --> Valor Minimo Ofertado
    vr_vlmulpli    crappre.vlmulpli%TYPE; --> Valores Multiplos
    vr_vlpercom    crappre.vlpercom%TYPE; --> Percentual de Rendimento
    vr_qtdiaver    crappre.qtdiaver%TYPE; --> Verificar operacoes inclusas ha
    vr_nrrevcad    crappre.nrrevcad%TYPE; --> Numero de Meses da Revisao Cadastral
    vr_vlmaxleg    crappre.vlmaxleg%TYPE; --> Percentual de Valor Maximo Legal
    vr_qtmescta    crappre.qtmescta%TYPE; --> Tempo de abertura da conta (em meses)
    vr_qtiniemp    crappre.qtmesadm%TYPE; --> Tempo de admissao no emprego atual (em meses)
    vr_dtadmiss    crapass.dtadmiss%TYPE; --> Data de admissao do associado
    vr_dtiniatv    crapjur.dtiniatv%TYPE; --> Contem a data de inicio das atividades
    vr_qtctaatr    crappre.qtctaatr%TYPE; --> Quantidade de dias de conta corrente em atraso
    vr_qtepratr    crappre.qtepratr%TYPE; --> Quantidade de dias de emprestimo em atraso
    vr_qtestour    crappre.qtestour%TYPE; --> Quantidade de estouros de conta
    vr_qtdiaest    crappre.qtdiaest%TYPE; --> Quantidade de dias para calc. estouro de conta
    vr_qtavlatr    crappre.qtavlatr%TYPE; --> Quantidade dias em atraso. Avalista
    vr_vlavlatr    crappre.vlavlatr%TYPE; --> Valor em atraso. Avalista
    vr_qtavlope    crappre.qtavlope%TYPE; --> Quantidade de operacoes em atraso. Avalista
    vr_qtcjgatr    crappre.qtcjgatr%TYPE; --> Quantidade dias em atraso. Conjuge
    vr_vlcjgatr    crappre.vlcjgatr%TYPE; --> Valor em atraso. Conjuge
    vr_qtcjgope    crappre.qtcjgope%TYPE; --> Quantidade de operacoes em atraso. Conjuge
    vr_dslstali    crappre.dslstali%TYPE; --> Lista com codigos de alineas de devolucao de cheque
    vr_qtdevolu    crappre.qtdevolu%TYPE; --> Quantidade de devolucoes de cheque
    vr_qtdiadev    crappre.qtdiadev%TYPE; --> Quantidade de dias para calc. devolucao de cheque
    vr_cdlcremp    crapcpa.cdlcremp%TYPE; --> Codigo da linha de credito da Carga
    vr_qtnegati    INTEGER;               --> Controle de saldos negativos e devlucoes
    vr_qtdiasut    INTEGER;               --> Quantidade de dias uteis
    vr_dtiniest    DATE;                  --> Data inicial para busca de estouro de conta
    vr_dtinidev    DATE;                  --> Data inicial para busca de devolucoes de cheques
    vr_dtiniemp    DATE;                  --> Data de admissao no emprego atual ou fundacao da empresa
    vr_dtmvtolt    DATE;                  --> Data utilizada no cursor crapsda
    vr_nrtelefo    VARCHAR2(30);          --> Telefone do cooperado
    vr_comando     VARCHAR2(1000);
    vr_cabinici    VARCHAR2(122);
    vr_cabmarge    NUMBER;
    vr_des_reto    VARCHAR2(3);
    vr_idx         VARCHAR2(15);
    vr_chave_risco VARCHAR2(10);
    vr_idcarga     tbepr_carga_pre_aprv.idcarga%TYPE; --> Codigo da carga
    vr_vltot_pf    tbepr_carga_pre_aprv.vltotal_pre_aprv_pf%TYPE; --> Valor Total de Credito PF
    vr_vltot_pj    tbepr_carga_pre_aprv.vltotal_pre_aprv_pj%TYPE; --> Valor Total de Credito PJ
    vr_tab_erro    GENE0001.typ_tab_erro;
    vr_tab_crapras RATI0001.typ_tab_crapras;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Calcula os Rendimentos do Associado
    PROCEDURE pc_consulta_rendimentos(pr_cdcooper IN crapttl.cdcooper%TYPE
                                     ,pr_nrdconta IN crapttl.nrdconta%TYPE
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE
                                     ,pr_flgmaior OUT BOOLEAN
                                     ,pr_vltotren OUT NUMBER
                                     ,pr_dtadmemp OUT DATE
                                     ,pr_tpcttrab OUT NUMBER) IS
    BEGIN

      DECLARE
        -- Numero de anos
        vr_numdanos NUMBER;

      BEGIN
        -- Consulta os Valores
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => pr_idseqttl);
        FETCH cr_crapttl INTO rw_crapttl;
        vr_flgachou := cr_crapttl%FOUND;
        CLOSE cr_crapttl;
        -- Se nao achou
        IF NOT vr_flgachou THEN
          pr_flgmaior := FALSE;
          pr_vltotren := 0;
          pr_dtadmemp := NULL;
          pr_tpcttrab := 0;
        ELSE
          vr_numdanos := TRUNC((SYSDATE - rw_crapttl.dtnasttl) / 365, 0);
          IF vr_numdanos >= 18 AND vr_numdanos <= 69 THEN
            pr_flgmaior := TRUE;
          ELSE
            pr_flgmaior := FALSE;
          END IF;

          pr_vltotren := rw_crapttl.vlsalari +
                         rw_crapttl.vldrendi##1 +
                         rw_crapttl.vldrendi##2 +
                         rw_crapttl.vldrendi##3 +
                         rw_crapttl.vldrendi##4 +
                         rw_crapttl.vldrendi##5 +
                         rw_crapttl.vldrendi##6;

          pr_dtadmemp := rw_crapttl.dtadmemp;
          pr_tpcttrab := rw_crapttl.tpcttrab;
        END IF;
      END;
    END pc_consulta_rendimentos;

    -- Atualiza o status da carga
    PROCEDURE pc_atualiza_status(pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE,
                                 pr_insitcar IN tbepr_carga_pre_aprv.indsituacao_carga%TYPE,
                                 pr_flgexpor IN PLS_INTEGER) IS --> Flag de controle de exportacao para SPC/Serasa
    BEGIN
    	-- Caso NAO seja uma exportacao para SPC/Serasa
      IF pr_flgexpor = 0 THEN
        BEGIN
          UPDATE tbepr_carga_pre_aprv
             SET indsituacao_carga = pr_insitcar
           WHERE idcarga = pr_idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao alterar o status do Credito Pre-Aprovado: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    END pc_atualiza_status;

    -- Inclui o motivo de nao receber o Credito Pre-aprovado
    PROCEDURE pc_inclui_motivo(pr_cdcooper IN tbepr_motivo_nao_aprv.cdcooper%TYPE,
                               pr_nrdconta IN tbepr_motivo_nao_aprv.nrdconta%TYPE,
                               pr_idcarga  IN tbepr_motivo_nao_aprv.idcarga%TYPE,
                               pr_idmotivo IN tbepr_motivo_nao_aprv.idmotivo%TYPE,
                               pr_dsvalor  IN tbepr_motivo_nao_aprv.dsvalor%TYPE) IS
    BEGIN

    	-- Seta como Bloqueado o Credito Pre Aprovado e Zera o Total Calculado
      BEGIN
        INSERT INTO tbepr_motivo_nao_aprv (cdcooper,nrdconta,idcarga,idmotivo,dsvalor)
             VALUES (pr_cdcooper,pr_nrdconta,pr_idcarga,pr_idmotivo,pr_dsvalor);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir o motivo do Pre-Aprovado: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END pc_inclui_motivo;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Busca a Data Base Bacen
    OPEN cr_max_opf;
    FETCH cr_max_opf INTO rw_max_opf;
    vr_flgachou := cr_max_opf%FOUND;
    CLOSE cr_max_opf;
    -- Se nao achou
    IF NOT vr_flgachou THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Data Base Bacen nao encontrada!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Carrega os riscos
    FOR rw_riscos IN cr_riscos LOOP
      vr_tab_risco(rw_riscos.cdcooper || rw_riscos.inpessoa || rw_riscos.dsrisco).vllimite := rw_riscos.vllimite;
      vr_tab_risco(rw_riscos.cdcooper || rw_riscos.inpessoa || rw_riscos.dsrisco).cdlcremp := rw_riscos.cdlcremp;
    END LOOP;
    
    -- Listagem de cooperativas
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

      -- Leitura do calendario
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_flgachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se nao achou
      IF NOT vr_flgachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      END IF;

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se possui erro
      IF vr_cdcritic <> 0 THEN
        RAISE vr_exc_saida;
      END IF;

      IF (rw_crapdat.inproces = 1) -- Caso seja uma geracao manual (carga ou SPC/Serasa) e o processo esteja on-line
      OR (rw_crapdat.inproces <> 1 AND TO_CHAR(rw_crapdat.dtmvtolt,'D') = 2) -- Processo noturno rodando e tbm eh segunda-feira
      THEN
          -- Listagem de parametros PF
          OPEN cr_crappre(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_inpessoa => 1);
          FETCH cr_crappre INTO rw_crappre_pf;
          vr_flgachou := cr_crappre%FOUND;
          CLOSE cr_crappre;
          -- Se nao achou
          IF NOT vr_flgachou THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Parametrizacao PF nao encontrada!';
            RAISE vr_exc_saida;
          END IF;
          
          -- Listagem de parametros PJ
          OPEN cr_crappre(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_inpessoa => 2);
          FETCH cr_crappre INTO rw_crappre_pj;
          vr_flgachou := cr_crappre%FOUND;
          CLOSE cr_crappre;
          -- Se nao achou
          IF NOT vr_flgachou THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Parametrizacao PJ nao encontrada!';
            RAISE vr_exc_saida;
          END IF;
          
          -- Caso NAO seja uma exportacao para SPC/Serasa
          IF pr_flgexpor = 0 THEN
            -- Exclui as cargas bloqueadas
            EMPR0002.pc_exclui_carga_bloqueada (pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_dscritic => vr_dscritic);
            -- Se possui critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Cria a carga
            EMPR0002.pc_inclui_carga (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_idcarga  => vr_idcarga
                                     ,pr_dscritic => vr_dscritic);
            -- Se possui critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Atualiza para Executando
            pc_atualiza_status(pr_idcarga  => vr_idcarga
                              ,pr_insitcar => 3 -- Executando
                              ,pr_flgexpor => pr_flgexpor);
            COMMIT;
            
            -- Habilitar contas suspensas PF
            EMPR0002.pc_habilita_contas_suspensas (pr_cdcooper => rw_crapcop.cdcooper
                                                  ,pr_inpessoa => 1
                                                  ,pr_dscritic => vr_dscritic);
            -- Se possui critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Habilitar contas suspensas PJ
            EMPR0002.pc_habilita_contas_suspensas (pr_cdcooper => rw_crapcop.cdcooper
                                                  ,pr_inpessoa => 2
                                                  ,pr_dscritic => vr_dscritic);
            -- Se possui critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
          
          -- Caso NAO seja uma exportacao para SPC/Serasa
          IF pr_flgexpor = 0 THEN
            -- Busca do diretorio base da cooperativa e a subpasta de relatorios
            vr_arq_path := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                ,pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
            vr_arq_nome := 'crrl682.txt';
            vr_arq_temp := 'crrl682.lst';
          ELSE
            -- Caso seja uma exportacao para SPC/Serasa
            vr_arq_path := GENE0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CRPS682_EXPORTA');
            vr_arq_nome := 'F' || LPAD(rw_crapcop.cdcooper, 2, '0') ||'_'|| TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') || '.txt';
            vr_arq_temp := 'F' || LPAD(rw_crapcop.cdcooper, 2, '0') ||'_'|| TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') || '.lst';
            vr_arq_nom2 := 'J' || LPAD(rw_crapcop.cdcooper, 2, '0') ||'_'|| TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') || '.txt';
            vr_arq_tmp2 := 'J' || LPAD(rw_crapcop.cdcooper, 2, '0') ||'_'|| TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR') || '.lst';

            -- Abrir arquivo
            GENE0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diret�rio do arquivo
                                    ,pr_nmarquiv => vr_arq_tmp2   --> Nome do arquivo
                                    ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_arqhand2   --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic); --> Erro
            IF vr_dscritic IS NOT NULL THEN
              -- Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Abrir arquivo
          GENE0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diret�rio do arquivo
                                  ,pr_nmarquiv => vr_arq_temp   --> Nome do arquivo
                                  ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_arqhandl   --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic); --> Erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar Excecao
            RAISE vr_exc_saida;
          END IF;

          -- Verifica se possui limite disponivel para emprestimo
          IF rw_crapcop.vllimmes > 0 THEN

            -- Caso NAO seja uma exportacao para SPC/Serasa
            IF pr_flgexpor = 0 THEN

              -- Cabecalho do arquivo
              vr_cabinici := 'PRE-APROVADO CONCEDIDOS COOPERATIVA ' || rw_crapcop.nmrescop ||
                             ' REFERENTE A ' || TO_CHAR(SYSDATE, 'dd/mm/rrrr') ||
                             ' AS ' || TO_CHAR(SYSDATE, 'hh24:mi:ss');
              -- Margem inicial da primeira linha ((Total da Linha / 2) - (Total de Texto / 2))
              vr_cabmarge := 61 - ROUND((LENGTH(vr_cabinici) / 2));
              -- Escreve o Cabecalho do arquivo
              GENE0001.pc_escr_linha_arquivo(vr_arqhandl,
                             LPAD(' ', vr_cabmarge, ' ') || vr_cabinici || chr(13) || chr(13) ||
                             '       CONTA/DV ' || 'TIPO ' || 'RISCO ' ||
                             '          COTAS ' || '       DESCONTO ' ||
                             '        CREDITO ' || ' PARCELA VENCER ' ||
                             '     RENDIMENTO ' || ' PARCELA MAXIMA' ||
                             '     CELULAR '    || ' BLOQUEADO' || chr(13));

            END IF;

            -- Carrega os tipos de riscos
            vr_tab_craptab(1).dsdrisco := 'AA';
            vr_tab_craptab(2).dsdrisco := 'A';
            vr_tab_craptab(3).dsdrisco := 'B';
            vr_tab_craptab(4).dsdrisco := 'C';
            vr_tab_craptab(5).dsdrisco := 'D';
            vr_tab_craptab(6).dsdrisco := 'E';
            vr_tab_craptab(7).dsdrisco := 'F';
            vr_tab_craptab(8).dsdrisco := 'G';
            vr_tab_craptab(9).dsdrisco := 'H';
            vr_tab_craptab(10).dsdrisco := 'H';

            -- Seleciona valor de arrasto da tabela generica
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'USUARI'
                                                     ,pr_cdempres => 11
                                                     ,pr_cdacesso => 'RISCOBACEN'
                                                     ,pr_tpregist => 0);
            -- Atribui o valor do arrasto
            vr_vlarrast := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab, 3, 9));

            -- Substitui o ';' por ',' das situacoes da conta
            vr_cdsit_pf := REPLACE(rw_crappre_pf.dssitdop, ';', ',');
            vr_cdsit_pj := REPLACE(rw_crappre_pj.dssitdop, ';', ',');

            -- Somatoria de credito
            vr_vltot_pf := 0;
            vr_vltot_pj := 0;

            -- Limpa PL TABLE de CPF/CNPJ
            vr_tab_cpfcnpj.DELETE;

            -- Listagem de Tipo de Pessoa
            FOR vr_inpessoa IN 1..2 LOOP

              -- Carrega valores iniciais
              IF vr_inpessoa = 1 THEN
                vr_tipessoa := 'PF';
                vr_vlmaxleg := rw_crappre_pf.vlmaxleg;
                vr_nrmcotas := rw_crappre_pf.nrmcotas;
                vr_cdfinemp := rw_crappre_pf.cdfinemp;
                vr_vllimmin := rw_crappre_pf.vllimmin;
                vr_vlmulpli := rw_crappre_pf.vlmulpli;
                vr_qtdiaver := rw_crappre_pf.qtdiaver;
                vr_nrrevcad := rw_crappre_pf.nrrevcad;
                vr_qtmescta := rw_crappre_pf.qtmescta;
                vr_qtiniemp := rw_crappre_pf.qtmesadm;
                vr_qtctaatr := rw_crappre_pf.qtctaatr;
                vr_qtepratr := rw_crappre_pf.qtepratr;
                vr_qtestour := rw_crappre_pf.qtestour;
                vr_qtdiaest := rw_crappre_pf.qtdiaest;
                vr_qtavlatr := rw_crappre_pf.qtavlatr;
                vr_vlavlatr := rw_crappre_pf.vlavlatr;
                vr_qtavlope := rw_crappre_pf.qtavlope;
                vr_qtcjgatr := rw_crappre_pf.qtcjgatr;
                vr_vlcjgatr := rw_crappre_pf.vlcjgatr;
                vr_qtcjgope := rw_crappre_pf.qtcjgope;
                vr_dslstali := REPLACE(rw_crappre_pf.dslstali, ';', ',');
                vr_qtdevolu := rw_crappre_pf.qtdevolu;
                vr_qtdiadev := rw_crappre_pf.qtdiadev;
                vr_cdsitdct := vr_cdsit_pf;
              ELSE
                vr_tipessoa := 'PJ';
                vr_vlmaxleg := rw_crappre_pj.vlmaxleg;
                vr_nrmcotas := rw_crappre_pj.nrmcotas;
                vr_cdfinemp := rw_crappre_pj.cdfinemp;
                vr_vllimmin := rw_crappre_pj.vllimmin;
                vr_vlmulpli := rw_crappre_pj.vlmulpli;
                vr_qtdiaver := rw_crappre_pj.qtdiaver;
                vr_nrrevcad := rw_crappre_pj.nrrevcad;
                vr_qtmescta := rw_crappre_pj.qtmescta;
                vr_qtiniemp := rw_crappre_pj.qtmesemp;
                vr_qtctaatr := rw_crappre_pj.qtctaatr;
                vr_qtepratr := rw_crappre_pj.qtepratr;
                vr_qtestour := rw_crappre_pj.qtestour;
                vr_qtdiaest := rw_crappre_pj.qtdiaest;
                vr_qtavlatr := rw_crappre_pj.qtavlatr;
                vr_vlavlatr := rw_crappre_pj.vlavlatr;
                vr_qtavlope := rw_crappre_pj.qtavlope;
                vr_qtcjgatr := rw_crappre_pj.qtcjgatr;
                vr_vlcjgatr := rw_crappre_pj.vlcjgatr;
                vr_qtcjgope := rw_crappre_pj.qtcjgope;
                vr_dslstali := REPLACE(rw_crappre_pj.dslstali, ';', ',');
                vr_qtdevolu := rw_crappre_pj.qtdevolu;
                vr_qtdiadev := rw_crappre_pj.qtdiadev;
                vr_cdsitdct := vr_cdsit_pj;
              END IF;

              -- Data de Admissao do cooperado
              vr_dtadmiss := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt), - vr_qtmescta);

              -- Data de Admissao no Emprego Atual ou Fundacao da Empresa
              vr_dtiniemp := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt), - vr_qtiniemp);

              -- Diminui os meses da data atual
              vr_dtaltera := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt), - vr_nrrevcad);

              -- Valor maximo legal multiplicado pelo percentual do parametro
              vr_vlmaximo := (rw_crapcop.vlmaxleg * (vr_vlmaxleg / 100));

              -- Calcula a data inicial para busca de estouro de conta
              vr_qtdiasut := 0;
              vr_dtiniest := rw_crapdat.dtmvtolt;
              WHILE vr_qtdiasut < vr_qtdiaest LOOP
                vr_dtiniest := GENE0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper
                                                          ,pr_dtmvtolt => vr_dtiniest - 1
                                                          ,pr_tipo     => 'A');
                vr_qtdiasut := vr_qtdiasut + 1;
              END LOOP;

              -- Calcula a data inicial para busca de devolucao de cheque
              vr_qtdiasut := 0;
              vr_dtinidev:= rw_crapdat.dtmvtolt;
              WHILE vr_qtdiasut < vr_qtdiadev LOOP
                vr_dtinidev := GENE0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper
                                                          ,pr_dtmvtolt => vr_dtinidev - 1
                                                          ,pr_tipo     => 'A');
                vr_qtdiasut := vr_qtdiasut + 1;
              END LOOP;

              -- Listagem de Associados da Cooperativa
              FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_inpessoa => vr_inpessoa
                                          ,pr_cdsitdct => vr_cdsitdct) LOOP
                
	              -- Cooperativa Libera Cr�dito Pr�-Aprovado
                OPEN cr_param_conta (rw_crapcop.cdcooper, rw_crapass.nrdconta);
                FETCH cr_param_conta INTO rw_param_conta;
                vr_flgachou := cr_param_conta%FOUND;
                CLOSE cr_param_conta;
                -- se pre-aprovado estiver liberado para essa conta (1 - Sim, 0 - N�o)
                IF vr_flgachou AND rw_param_conta.flglibera_pre_aprv = 0 THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 35 -- Bloqueio da Cooperativa
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Titular cadastrado na tela ALERTA
                OPEN cr_crapcrt (rw_crapass.nrcpfcgc);
                FETCH cr_crapcrt INTO rw_crapcrt;
                vr_flgachou := cr_crapcrt%FOUND;
                CLOSE cr_crapcrt;
                -- se conter o codigo da situacao do registro restritivo = 1-Inserido
                IF vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 36 -- Titular cadastrado na ALERTA
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;
                
                --Titular bloqueado na tela DCTROR
                --Se a situa��o do titular for 
                --2 - NORMAL C/BLOQ
                --4 - DEMITIDO C/BLOQ
                --6 - NORMAL BLQ.PREJ
                --8 - DEM. BLOQ.PREJ
                --Essas situa��es indicam que a conta est� bloqueada na tela DCTROR
                IF rw_crapass.cdsitdtl IN (2,4,6,8) THEN 
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 37 -- Conta bloqueada na DCTROR
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Data de admissao do associado na CCOH for maior que a data calculada
                IF rw_crapass.dtadmiss > vr_dtadmiss THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 10 -- Tempo de Conta
                                    ,pr_dsvalor  => TO_CHAR(rw_crapass.dtadmiss,'DD/MM/RRRR'));
                  END IF;
                  CONTINUE;
                END IF;

                -- Se NAO for exportacao para SPC/Serasa e Estiver marcado como Restricao(1)
                IF pr_flgexpor = 0 AND rw_crapass.inserasa = 1 THEN
                  -- Grava o motivo
                  pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_idcarga  => vr_idcarga
                                  ,pr_idmotivo => 1 -- Restricao no Serasa
                                  ,pr_dsvalor  => '');
                  CONTINUE;
                END IF;

                -- Buscar qtd de estouro de conta
                OPEN cr_crapneg_qtd (pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_cdhisest => 5 -- Estouro
                                    ,pr_dtiniest => vr_dtiniest
                                    ,pr_cdobserv => '0');
                FETCH cr_crapneg_qtd INTO vr_qtnegati;
                CLOSE cr_crapneg_qtd;
                -- Se qtd de negativos for maior que qtd de estouros
                IF vr_qtnegati > vr_qtestour THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 16 -- Estouro de Conta
                                    ,pr_dsvalor  => vr_qtnegati || ' estouro(s)');
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Buscar informacoes de operacoes como avalista
                OPEN cr_avalist_qtd (pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta);
                FETCH cr_avalist_qtd INTO rw_avalist_qtd;
                CLOSE cr_avalist_qtd;
                
                -- Se qtd de dias em atraso for maior que o estipulado
                IF rw_avalist_qtd.dias_atraso > vr_qtavlatr THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 33 -- Avalista de Opera��es em Atraso
                                    ,pr_dsvalor  => 'Qtd. dias: ' || rw_avalist_qtd.dias_atraso);
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Se total do valor em atraso for maior que o estipulado
                IF rw_avalist_qtd.total_atraso  > vr_vlavlatr THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 33 -- Avalista de Opera��es em Atraso
                                    ,pr_dsvalor  => 'Valor total: ' || rw_avalist_qtd.total_atraso);
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Se qtd de operacoes em atraso for maior que o estipulado
                IF rw_avalist_qtd.qtd_operacoes > vr_qtavlope THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 33 -- Avalista de Opera��es em Atraso
                                    ,pr_dsvalor  => 'Qtd. opera��es: ' || rw_avalist_qtd.qtd_operacoes);
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Buscar qtd de devolucao de cheque
                OPEN cr_crapneg_qtd (pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_cdhisest => 1 -- Devolucao de Cheque
                                    ,pr_dtiniest => vr_dtinidev
                                    ,pr_cdobserv => vr_dslstali);
                FETCH cr_crapneg_qtd INTO vr_qtnegati;
                CLOSE cr_crapneg_qtd;
                -- Se qtd de negativos for maior que qtd de devolucoes
                IF vr_qtnegati > vr_qtdevolu THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 13 -- Devolucao Cheques
                                    ,pr_dsvalor  => vr_qtnegati || ' cheque(s)');
                  END IF;
                  CONTINUE;
                END IF;
                
                --Limpa o campo de risco
                vr_riscoope := ' ';
                vr_nivrisco := ' ';
                
                --Limpa o campo de controle
                vr_proxregi := FALSE;
                
                FOR rw_crapass_cpfcnpj IN cr_crapass_cpfcnpj(rw_crapass.nrcpfcgc) LOOP

                  --Titular da conta com opera��o em Preju�zo
                  OPEN cr_titopepre (rw_crapass_cpfcnpj.cdcooper
                                    ,rw_crapass_cpfcnpj.nrdconta);
                  FETCH cr_titopepre INTO rw_titopepre;
                  vr_flgachou := cr_titopepre%FOUND;
                  CLOSE cr_titopepre;
                  --Se estive em preju�zo
                  IF vr_flgachou THEN
                    -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                    IF pr_flgexpor = 0 THEN
                      pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_idcarga  => vr_idcarga
                                      ,pr_idmotivo => 38 -- Titular com Opera��o em Preju�zo
                                      ,pr_dsvalor  => 'Cooperativa: ' || rw_titopepre.cdcooper);
                    END IF;
                    vr_proxregi := TRUE;
                    EXIT;
                  END IF;
                  
                  -- Risco Cooperado
                  vr_riscoass := rw_crapass_cpfcnpj.inrisctl;
                  
                  -- Calcula o Risco Cooperado caso nao esteja calculado
                  IF vr_riscoass = ' ' THEN
                    -- Busca data da cooperativa da conta atual
                    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapass_cpfcnpj.cdcooper);
                    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
                    vr_flgachou := BTCH0001.cr_crapdat%FOUND;
                    CLOSE BTCH0001.cr_crapdat;
                    -- Se nao achou
                    IF NOT vr_flgachou THEN
                      vr_cdcritic := 1;
                      RAISE vr_exc_saida;
                    END IF;
                    
                    IF vr_inpessoa = 1 THEN
                      RATI0001.pc_risco_cooperado_pf(pr_flgdcalc    => 1,
                                                     pr_cdcooper    => rw_crapass_cpfcnpj.cdcooper,
                                                     pr_cdagenci    => rw_crapass_cpfcnpj.cdagenci,
                                                     pr_nrdcaixa    => 0,
                                                     pr_cdoperad    => '1',
                                                     pr_idorigem    => 1,
                                                     pr_nrdconta    => rw_crapass_cpfcnpj.nrdconta,
                                                     pr_idseqttl    => 1,
                                                     pr_rw_crapdat  => rw_crapdat,
                                                     pr_tpctrato    => 0,
                                                     pr_nrctrato    => 0,
                                                     pr_inusatab    => FALSE,
                                                     pr_flgcriar    => 0,
                                                     pr_flgttris    => FALSE,
                                                     pr_tab_crapras => vr_tab_crapras,
                                                     pr_notacoop    => vr_notacoop,
                                                     pr_clascoop    => vr_riscoass,
                                                     pr_tab_erro    => vr_tab_erro,
                                                     pr_des_reto    => vr_des_reto);

                    ELSE
                      RATI0001.pc_risco_cooperado_pj(pr_flgdcalc    => 1,
                                                     pr_cdcooper    => rw_crapass_cpfcnpj.cdcooper,
                                                     pr_cdagenci    => rw_crapass_cpfcnpj.cdagenci,
                                                     pr_nrdcaixa    => 0,
                                                     pr_cdoperad    => '1',
                                                     pr_idorigem    => 1,
                                                     pr_nrdconta    => rw_crapass_cpfcnpj.nrdconta,
                                                     pr_idseqttl    => 1,
                                                     pr_rw_crapdat  => rw_crapdat,
                                                     pr_tpctrato    => 0,
                                                     pr_nrctrato    => 0,
                                                     pr_inusatab    => FALSE,
                                                     pr_flgcriar    => 0,
                                                     pr_flgttris    => FALSE,
                                                     pr_tab_crapras => vr_tab_crapras,
                                                     pr_notacoop    => vr_notacoop,
                                                     pr_clascoop    => vr_riscoass,
                                                     pr_tab_erro    => vr_tab_erro,
                                                     pr_des_reto    => vr_des_reto);
                    END IF;
                    
                    IF vr_des_reto = 'OK' THEN
                      -- Atualiza o Risco Cooperado calculado
                      UPDATE crapass
                         SET nrnotatl = vr_notacoop,
                             inrisctl = vr_riscoass,
                             dtrisctl = rw_crapdat.dtmvtolt
                       WHERE cdcooper = rw_crapass_cpfcnpj.cdcooper
                         AND nrdconta = rw_crapass_cpfcnpj.nrdconta;
                    -- Caso NAO seja uma exportacao para SPC/Serasa e possui erro
                    ELSIF pr_flgexpor = 0 AND vr_tab_erro(0).dscritic IS NOT NULL THEN
                      -- Grava o motivo
                      pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_idcarga  => vr_idcarga
                                      ,pr_idmotivo => 18 -- Impossibilidade Calc. Risco Cooperado
                                      ,pr_dsvalor  => 'Conta: ' || rw_crapass_cpfcnpj.cdcooper ||
                                                      '-' || rw_crapass_cpfcnpj.nrdconta ||' ' ||
                                                       SUBSTR(vr_tab_erro(0).dscritic,1,79));
                      
                      vr_proxregi := TRUE;
                      EXIT;
                    END IF;
                    
                  END IF; -- vr_riscoass = ' '
                  
                  -- Caso seja uma classificacao antiga
                  IF vr_riscoass = 'AA' THEN
                    vr_riscoass := 'A';
                  END IF;
                  
                  IF vr_riscoass = 'HH' THEN
                    vr_riscoass := 'H';
                  END IF;
                  
                  -- Pega o pior risco
                  IF vr_riscoope = ' ' THEN
                    vr_riscoope := vr_riscoass;
                  ELSE 
                    IF vr_riscoope < vr_riscoass THEN
                       vr_riscoope := vr_riscoass;
                    END IF;
                  END IF;
                  
                  -- Risco com divida (Valor Arrasto)
                  OPEN cr_ris_comdiv(pr_cdcooper => rw_crapass_cpfcnpj.cdcooper
                                    ,pr_nrdconta => rw_crapass_cpfcnpj.nrdconta
                                    ,pr_dtrefere => rw_crapdat.dtultdma
                                    ,pr_inddocto => 1
                                    ,pr_vldivida => vr_vlarrast);
                  FETCH cr_ris_comdiv INTO rw_ris_comdiv;
                  CLOSE cr_ris_comdiv;
                  -- Se encontrar
                  IF rw_ris_comdiv.innivris IS NOT NULL THEN
                    vr_riscodiv := TRIM(vr_tab_craptab(rw_ris_comdiv.innivris).dsdrisco);
                  ELSE
                    -- Risco sem divida
                    OPEN cr_ris_semdiv(pr_cdcooper => rw_crapass_cpfcnpj.cdcooper
                                      ,pr_nrdconta => rw_crapass_cpfcnpj.nrdconta
                                      ,pr_dtrefere => rw_crapdat.dtultdma
                                      ,pr_inddocto => 1);
                    FETCH cr_ris_semdiv INTO rw_ris_semdiv;
                    CLOSE cr_ris_semdiv;
                    -- Se encontrar
                    IF rw_ris_semdiv.innivris IS NOT NULL THEN
                      -- Quando possuir operacao em Prejuizo, o risco da central sera H
                      IF rw_ris_semdiv.innivris = 10 THEN
                         vr_riscodiv := TRIM(vr_tab_craptab(rw_ris_semdiv.innivris).dsdrisco);
                      ELSE
                         vr_riscodiv := TRIM(vr_tab_craptab(2).dsdrisco);
                      END IF;
                    ELSE
                      vr_riscodiv := TRIM(vr_tab_craptab(2).dsdrisco);
                    END IF;
                  END IF;

                  -- Caso seja uma classificacao antiga
                  IF vr_riscodiv = 'AA' THEN
                    vr_riscodiv := 'A';
                  END IF;
                  
                  IF vr_riscodiv = 'HH' THEN
                    vr_riscodiv := 'H';
                  END IF;
                  
                  -- Pega o pior risco
                  IF vr_nivrisco = ' ' THEN
                    vr_nivrisco := vr_riscodiv;
                  ELSE 
                    IF vr_nivrisco < vr_riscodiv THEN
                       vr_nivrisco := vr_riscodiv;
                    END IF;
                  END IF;
                  
                END LOOP; --rw_crapass_cpfcnpj
                
                -- Caso n�o seja aprovado
                IF vr_proxregi THEN
                  CONTINUE;
                END IF;
                
                -- Volta para a data da cooperativa atual
                OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
                FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
                vr_flgachou := BTCH0001.cr_crapdat%FOUND;
                CLOSE BTCH0001.cr_crapdat;
                -- Se nao achou
                IF NOT vr_flgachou THEN
                  vr_cdcritic := 1;
                  RAISE vr_exc_saida;
                END IF;
                
                -- Caso o Risco Cooperado seja uma classificacao maior que o Risco
                IF vr_riscoope > vr_nivrisco THEN
                  vr_nivrisco := vr_riscoope;
                END IF;
                
                -- Constroi chave para o risco na temp-table
                vr_chave_risco := rw_crapcop.cdcooper || rw_crapass.inpessoa || vr_riscoope;
                
                -- Se o Risco Cooperado NAO estiver no parametro vai para o proximo
                IF NOT vr_tab_risco .EXISTS(vr_chave_risco) THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 2 -- Risco do Cooperado
                                    ,pr_dsvalor  => 'Risco ' || vr_riscoope);
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Dados da Linha de Credito PF
                OPEN cr_craplcr(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdlcremp => vr_tab_risco(vr_chave_risco).cdlcremp);
                FETCH cr_craplcr INTO rw_craplcr;
                vr_flgachou := cr_craplcr%FOUND;
                CLOSE cr_craplcr;
                -- Se nao achou
                IF NOT vr_flgachou THEN
                  vr_cdcritic := 0;
                  IF vr_inpessoa = 1 THEN
                    vr_dscritic := 'Linha de Credito PF nao encontrada!';
                  ELSE
                    vr_dscritic := 'Linha de Credito PJ nao encontrada!';
                  END IF;
                  RAISE vr_exc_saida;
                ELSE
                  IF vr_inpessoa = 1 THEN
                    vr_txjur_pf := rw_craplcr.txmensal;
                    vr_qtpar_pf := rw_craplcr.nrfimpre;
                  ELSE
                    vr_txjur_pj := rw_craplcr.txmensal;
                    vr_qtpar_pj := rw_craplcr.nrfimpre;
                  END IF;
                END IF;
                
                -- Se o Risco Cooperado NAO estiver no parametro vai para o proximo
                IF NOT vr_tab_risco.EXISTS(rw_crapcop.cdcooper || rw_crapass.inpessoa || vr_nivrisco) THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 3 -- Risco Operacoes de Credito
                                    ,pr_dsvalor  => 'Risco ' || vr_nivrisco);
                  END IF;
                  CONTINUE;
                END IF;
                
                -- Constroi chave para o risco na temp-table
                vr_chave_risco := rw_crapcop.cdcooper || rw_crapass.inpessoa || vr_nivrisco;
                
                -- Grava o codigo da linha de credito para a carga
                vr_cdlcremp := vr_tab_risco(vr_chave_risco).cdlcremp;
                
                -- Revisao Cadastral
                OPEN cr_crapalt(pr_cdcooper => rw_crapass.cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_dtaltera => vr_dtaltera);
                FETCH cr_crapalt INTO rw_crapalt;
                vr_flgachou := cr_crapalt%FOUND;
                CLOSE cr_crapalt;
                -- Se NAO encontrar alteracao passa para o proximo registro
                IF NOT vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 4 -- Revisao Cadastral
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;

                -- Endividamento SFN
                OPEN cr_crapvop(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                               ,pr_dtrefere => rw_max_opf.dtrefere);
                FETCH cr_crapvop INTO rw_crapvop;
                vr_flgachou := cr_crapvop%FOUND;
                CLOSE cr_crapvop;
                -- Se encontrar valor vencido ou em prejuizo vai para o proximo
                IF vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 5 -- Endiv. Vencido/Prejuizo
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;

                -- Limite maximo por tipo de pessoa e classificacao
                vr_vllimmax := vr_tab_risco(rw_crapcop.cdcooper ||
                                            vr_inpessoa ||
                                            vr_nivrisco).vllimite;
                
                IF rw_crapdat.inproces >= 3 THEN
                  vr_dtmvtolt := rw_crapdat.dtmvtolt;
                ELSE
                  vr_dtmvtolt := rw_crapdat.dtmvtoan;
                END IF;

                -- Valores do Cooperado
                OPEN cr_crapsda(pr_cdcooper => rw_crapass.cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_dtmvtolt => vr_dtmvtolt);
                FETCH cr_crapsda INTO rw_crapsda;
                vr_flgachou := cr_crapsda%FOUND;
                CLOSE cr_crapsda;
                -- Se NAO encontrar valor vai para o proximo
                IF NOT vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 17 -- Inconsistencia de Dados
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                ELSE
                  -- Saldo de cotas multiplicado pelo numero de vezes do parametro
                  vr_vlsdcota := rw_crapsda.vlsdcota * vr_nrmcotas;

                  -- Valor para descontar das cotas
                  vr_vldescon := rw_crapsda.vlsdempr +
                                 rw_crapsda.vlsdfina +
                                 rw_crapsda.vllimcre +
                                 rw_crapsda.vllimtit +
                                 rw_crapsda.vllimdsc;

                  -- Listagem dos Cartoes de Credito
                  FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper => rw_crapass.cdcooper
                                              ,pr_nrdconta => rw_crapass.nrdconta) LOOP

                    IF rw_crawcrd.cdadmcrd < 10 OR rw_crawcrd.cdadmcrd > 80 THEN
                      -- Se estiver em uso soma o valor total de limite de todos os cartoes */
                      IF rw_crawcrd.insitcrd = 4 OR rw_crawcrd.insitcrd = 7 THEN
                        -- Limite do Cartao de Credito
                        OPEN cr_craptlc(pr_cdcooper => rw_crawcrd.cdcooper
                                       ,pr_cdadmcrd => rw_crawcrd.cdadmcrd
                                       ,pr_tpcartao => rw_crawcrd.tpcartao
                                       ,pr_cdlimcrd => rw_crawcrd.cdlimcrd);
                        FETCH cr_craptlc INTO rw_craptlc;
                        vr_flgachou := cr_craptlc%FOUND;
                        CLOSE cr_craptlc;
                        -- Se encontrar adiciona o limite no desconto
                        IF vr_flgachou THEN
                          vr_vldescon := vr_vldescon + rw_craptlc.vllimcrd;
                        END IF;
                      END IF;
                    ELSE
                      -- Caso o cart�o esteja com situa��o = [4 - "Em uso"].
                      IF rw_crawcrd.insitcrd = 4 THEN
                        -- Adiciona o limite no desconto
                        vr_vldescon := vr_vldescon + rw_crawcrd.vllimcrd;
                      END IF;
                    END IF;

                  END LOOP; -- cr_crawcrd

                END IF; -- cr_crapsda

                -- Somatoria do Credito Pre Aprovado utilizado
                OPEN cr_crapepr(pr_cdcooper => rw_crapass.cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_cdfinemp => vr_cdfinemp);
                FETCH cr_crapepr INTO rw_crapepr;
                CLOSE cr_crapepr;

                -- Saldo de Credito Pre Aprovado contratado
                vr_vlsldcpa := rw_crapepr.vlsdeved;

                -- Subtrai dos descontos o Credito Pre Aprovado contratado
                vr_vldescon := vr_vldescon - vr_vlsldcpa;

                -- Subtrai do Saldo de Cotas o Valor de Desconto
                vr_vlsdcota := vr_vlsdcota - vr_vldescon;

                -- Zera os totais de parcelas a vencer e rendimentos, e seta o limite de cotas
                vr_vlparcav := 0;
                vr_vltotren := 0;
                vr_vlimcota := CASE WHEN vr_vlsdcota > vr_vllimmax THEN vr_vllimmax ELSE vr_vlsdcota END;

                -- Subtrai do Limite de Cotas o Credito Pre Aprovado contratado
                vr_vlimcota := vr_vlimcota - vr_vlsldcpa;

                -- O limite da cota NAO pode ser menor que valor minimo ofertado
                IF vr_vlimcota < vr_vllimmin THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 6 -- Limite de cotas
                                    ,pr_dsvalor  => 'R$ ' || TO_CHAR(vr_vlimcota,'fm999g999g999g990d00'));
                  END IF;
                  CONTINUE;
                END IF;

                -- Verifica se o cooperado possui conta em atraso no CYBER
                OPEN cr_crapcyb(pr_cdcooper => rw_crapass.cdcooper,
                                pr_nrdconta => rw_crapass.nrdconta,
                                pr_cdorigem => '1', -- Conta
                                pr_qtdiaatr => vr_qtctaatr);
                FETCH cr_crapcyb INTO rw_crapcyb;
                vr_flgachou := cr_crapcyb%FOUND;
                CLOSE cr_crapcyb;
                -- Se encontrar registro no CYBER vai para o proximo
                IF vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 14 -- Conta em Atraso
                                    ,pr_dsvalor  => rw_crapcyb.qtdiaatr || ' dia(s)');
                  END IF;
                  CONTINUE;
                END IF;

                -- Verifica se o cooperado possui algum emprestimo em atraso no CYBER
                OPEN cr_crapcyb(pr_cdcooper => rw_crapass.cdcooper,
                                pr_nrdconta => rw_crapass.nrdconta,
                                pr_cdorigem => '2,3', -- 2-Descontos / 3�Emprestimo
                                pr_qtdiaatr => vr_qtepratr);
                FETCH cr_crapcyb INTO rw_crapcyb;
                vr_flgachou := cr_crapcyb%FOUND;
                CLOSE cr_crapcyb;
                -- Se encontrar registro no CYBER vai para o proximo
                IF vr_flgachou THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 15 -- Emprestimo em Atraso
                                    ,pr_dsvalor  => rw_crapcyb.qtdiaatr || ' dia(s)');
                  END IF;
                  CONTINUE;
                END IF;

                -- Valor maximo da prestacao mensal
                IF vr_inpessoa = 1 THEN

                  -- PF
                  pc_consulta_rendimentos(pr_cdcooper => rw_crapass.cdcooper
                                         ,pr_nrdconta => rw_crapass.nrdconta
                                         ,pr_idseqttl => 1
                                         ,pr_flgmaior => vr_flgmaior
                                         ,pr_vltotren => vr_vlrendim
                                         ,pr_dtadmemp => vr_dtadmemp
                                         ,pr_tpcttrab => vr_tpcttrab);
                  -- Soma os Rendimentos
                  vr_vltotren := vr_vltotren + vr_vlrendim;

                  -- Caso seja um menor de idade vai para o proximo
                  IF vr_flgmaior = FALSE THEN
                    -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                    IF pr_flgexpor = 0 THEN
                      pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_idcarga  => vr_idcarga
                                      ,pr_idmotivo => 7 -- Menor de Idade
                                      ,pr_dsvalor  => '');
                    END IF;
                    CONTINUE;
                  END IF;

                  -- Ignorar esta regra quando Tipo Contrato Trabalho: Sem Vinculo(3) ou Autonomo(4)
                  IF vr_tpcttrab NOT IN (3,4) THEN
                    -- Data de admissao do emprego for maior que a data calculada ou nula
                    IF vr_dtadmemp > vr_dtiniemp OR vr_dtadmemp IS NULL THEN
                      -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
	                    IF pr_flgexpor = 0 THEN
                        pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_idcarga  => vr_idcarga
                                        ,pr_idmotivo => 12 -- Tempo Admissao Emprego
                                        ,pr_dsvalor  => TO_CHAR(vr_dtadmemp,'DD/MM/RRRR'));
                      END IF;
                      CONTINUE;
                    END IF;
                  END IF;

                  -- Dados do Conjuge
                  OPEN cr_crapcje(pr_cdcooper => rw_crapass.cdcooper
                                 ,pr_nrdconta => rw_crapass.nrdconta
                                 ,pr_idseqttl => 1);
                  FETCH cr_crapcje INTO rw_crapcje;
                  vr_flgachou := cr_crapcje%FOUND;
                  CLOSE cr_crapcje;
                  -- Se encontrar Conjuge
                  IF vr_flgachou THEN

                    -- Se o conjuge nao possui conta informada no cadastro
                    IF rw_crapcje.nrctacje = 0 OR rw_crapcje.nrctacje IS NULL THEN

                      -- Inicializa as variaveis
                      vr_nrdconta := 0;
                      vr_dtdolaco := to_date('01/01/0001','dd/mm/yyyy');

                      -- Listagem das Contas do cooperado
                      FOR rw_contas_coop IN cr_contas_coop(pr_cdcooper => rw_crapcje.cdcooper
                                                          ,pr_nrcpfcgc => rw_crapcje.nrcpfcjg
                                                          ,pr_idseqttl => 1) LOOP
                        -- Listagem de alteracoes e contas
                        OPEN cr_max_alt(pr_cdcooper => rw_contas_coop.cdcooper
                                       ,pr_nrdconta => rw_contas_coop.nrdconta);
                        FETCH cr_max_alt INTO rw_max_alt;
                        vr_flgachou := cr_max_alt%FOUND;
                        CLOSE cr_max_alt;
                        -- Se encontrar
                        IF vr_flgachou THEN
                          IF rw_max_alt.dtaltera > vr_dtdolaco THEN
                            vr_nrdconta := rw_max_alt.nrdconta;
                            vr_dtdolaco := rw_max_alt.dtaltera;
                          END IF;
                        ELSE
                          vr_nrdconta := rw_contas_coop.nrdconta;
                        END IF;
                      END LOOP;

                      -- Se nao encontrou nenhuma conta
                      IF vr_nrdconta = 0 THEN
                        vr_vltotren := vr_vltotren + rw_crapcje.vlsalari;
                      ELSE
                        -- Busca os rendimentos do conjuge como Segundo Titular
                        pc_consulta_rendimentos(pr_cdcooper => rw_crapcje.cdcooper
                                               ,pr_nrdconta => vr_nrdconta
                                               ,pr_idseqttl => 1
                                               ,pr_flgmaior => vr_flgmaior
                                               ,pr_vltotren => vr_vlrendim
                                               ,pr_dtadmemp => vr_dtadmemp
                                               ,pr_tpcttrab => vr_tpcttrab);
                        -- Soma os rendimentos do conjuge
                        vr_vltotren := vr_vltotren + vr_vlrendim;
                      END IF;

                    ELSE
                      vr_nrdconta := rw_crapcje.nrctacje;
                      -- Busca os rendimentos do conjuge
                      pc_consulta_rendimentos(pr_cdcooper => rw_crapcje.cdcooper
                                             ,pr_nrdconta => rw_crapcje.nrctacje
                                             ,pr_idseqttl => 1
                                             ,pr_flgmaior => vr_flgmaior
                                             ,pr_vltotren => vr_vlrendim
                                             ,pr_dtadmemp => vr_dtadmemp
                                             ,pr_tpcttrab => vr_tpcttrab);
                      -- Soma os rendimentos do conjuge
                      vr_vltotren := vr_vltotren + vr_vlrendim;
                    END IF; -- rw_crapcje.nrctacje = 0 OR rw_crapcje.nrctacje IS NULL
                    
                    -- Se nao encontrou nenhuma conta
                    IF vr_nrdconta > 0 THEN
                      -- Buscar informacoes de operacoes de conjuge
                      OPEN cr_conjuge_qtd (pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nrdconta => vr_nrdconta);
                      FETCH cr_conjuge_qtd INTO rw_conjuge_qtd;
                      CLOSE cr_conjuge_qtd;
                      
                      -- Se qtd de dias em atraso for maior que o estipulado
                      IF rw_conjuge_qtd.dias_atraso > vr_qtcjgatr THEN
                        -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                        IF pr_flgexpor = 0 THEN
                          pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta
                                          ,pr_idcarga  => vr_idcarga
                                          ,pr_idmotivo => 34 -- C�njuge com Opera��es em Atraso
                                          ,pr_dsvalor  => 'Qtd. dias: ' || rw_conjuge_qtd.dias_atraso);
                        END IF;
                        CONTINUE;
                      END IF;
                      
                      -- Se total do valor em atraso for maior que o estipulado
                      IF rw_conjuge_qtd.total_atraso  > vr_vlcjgatr THEN
                        -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                        IF pr_flgexpor = 0 THEN
                          pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta
                                          ,pr_idcarga  => vr_idcarga
                                          ,pr_idmotivo => 34 -- C�njuge com Opera��es em Atraso
                                          ,pr_dsvalor  => 'Valor total: ' || rw_conjuge_qtd.total_atraso);
                        END IF;
                        CONTINUE;
                      END IF;
                      
                      -- Se qtd de operacoes em atraso for maior que o estipulado
                      IF rw_conjuge_qtd.qtd_operacoes > vr_qtcjgope THEN
                        -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                        IF pr_flgexpor = 0 THEN
                          pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta
                                          ,pr_idcarga  => vr_idcarga
                                          ,pr_idmotivo => 34 -- C�njuge com Opera��es em Atraso
                                          ,pr_dsvalor  => 'Qtd. opera��es: ' || rw_conjuge_qtd.qtd_operacoes);
                        END IF;
                        CONTINUE;
                      END IF;
                    END IF; -- nrdconta > 0
                    
                    -- Parcelas a vencer de 60 a 90 dias
                    FOR rw_crapvop_avc IN cr_crapvop_avc(pr_nrcpfcgc => rw_crapcje.nrcpfcjg
                                                        ,pr_dtrefere => rw_max_opf.dtrefere) LOOP
                      -- Soma as Parcelas a Vencer
                      vr_vlparcav := vr_vlparcav + rw_crapvop_avc.vlvencto;
                    END LOOP;

                  END IF; -- cr_crapcje

                  -- Seta a Taxa de Juros e Numero Maximo de Parcelas
                  vr_txjurmes := vr_txjur_pf / 100;
                  vr_qtmaxpar := vr_qtpar_pf;

                ELSE

                  -- Consulta os dados de PJ
                  OPEN cr_crapjur(pr_cdcooper => rw_crapass.cdcooper
                                 ,pr_nrdconta => rw_crapass.nrdconta);
                  FETCH cr_crapjur INTO vr_dtiniatv;
                  CLOSE cr_crapjur;
                  -- Se Data da Fundacao da Empresa for maior que a data calculada ou nula
                  IF vr_dtiniatv > vr_dtiniemp OR vr_dtiniatv IS NULL THEN
                    -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                    IF pr_flgexpor = 0 THEN
                      pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_idcarga  => vr_idcarga
                                      ,pr_idmotivo => 11 -- Tempo Fund. Empresa
                                      ,pr_dsvalor  => TO_CHAR(vr_dtiniatv,'DD/MM/RRRR'));
                    END IF;
                    CONTINUE;
                  END IF;

                  -- Rendimentos de PJ
                  OPEN cr_crapjfn(pr_cdcooper => rw_crapass.cdcooper
                                 ,pr_nrdconta => rw_crapass.nrdconta);
                  FETCH cr_crapjfn
                   INTO rw_crapjfn;
                  -- Se encontrar
                  IF cr_crapjfn%FOUND THEN
                    vr_nummeses := 0;
                    -- Efetua o split das informacoes separados por ;
                    vr_vet_rend := gene0002.fn_quebra_string(pr_string  => rw_crapjfn.vlrftbru##1 || ';'
                                                                        || rw_crapjfn.vlrftbru##2 || ';'
                                                                        || rw_crapjfn.vlrftbru##3 || ';'
                                                                        || rw_crapjfn.vlrftbru##4 || ';'
                                                                        || rw_crapjfn.vlrftbru##5 || ';'
                                                                        || rw_crapjfn.vlrftbru##6 || ';'
                                                                        || rw_crapjfn.vlrftbru##7 || ';'
                                                                        || rw_crapjfn.vlrftbru##8 || ';'
                                                                        || rw_crapjfn.vlrftbru##9 || ';'
                                                                        || rw_crapjfn.vlrftbru##10 || ';'
                                                                        || rw_crapjfn.vlrftbru##11 || ';'
                                                                        || rw_crapjfn.vlrftbru##12
                                                            ,pr_delimit => ';');
                    -- Para cada registro encontrado
                    FOR vr_pos IN 1 .. vr_vet_rend.count LOOP
                      IF vr_vet_rend(vr_pos) > 0 THEN
                        vr_vltotren := vr_vltotren + vr_vet_rend(vr_pos);
                        vr_nummeses := vr_nummeses + 1;
                      END IF;
                    END LOOP;

                    -- Se n�mero de meses for igual a zero
                    IF NVL(vr_nummeses,0) = 0 THEN
                      vr_vltotren := 0;
                    ELSE
                      -- Calcula a Media de Rendimento
                      vr_vltotren := vr_vltotren / vr_nummeses;
                    END IF;
                  END IF;
                  CLOSE cr_crapjfn;

                  -- Seta a Taxa de Juros e Numero Maximo de Parcelas
                  vr_txjurmes := vr_txjur_pj / 100;
                  vr_qtmaxpar := vr_qtpar_pj;

                END IF; -- vr_inpessoa = 1

                -- Caso NAO tenha rendimento passa para o proximo registro
                IF vr_vltotren <= 0 THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 8 -- Nao possui Rendimentos
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;

                -- Parcelas a vencer de 60 a 90 dias
                FOR rw_crapvop_avc IN cr_crapvop_avc(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                    ,pr_dtrefere => rw_max_opf.dtrefere) LOOP
                  -- Soma as Parcelas a Vencer
                  vr_vlparcav := vr_vlparcav + rw_crapvop_avc.vlvencto;
                END LOOP;
                
                OPEN cr_opera_inclusas (pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_nrdconta => rw_crapass.nrdconta
                                       ,pr_qtdiaver => vr_qtdiaver);
                FETCH cr_opera_inclusas INTO rw_opera_inclusas;
                CLOSE cr_opera_inclusas;
                
                vr_vlparcav := vr_vlparcav + rw_opera_inclusas.vlpreemp;
                
                -- Verifica se tem aluguel
                OPEN cr_crapenc (pr_cdcooper => rw_crapass.cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_idseqttl => 1);
                FETCH cr_crapenc INTO vr_vlalugue;
                CLOSE cr_crapenc;

                -- % de comprometimento de renda
                vr_vlpercom := CASE WHEN vr_inpessoa = 1 THEN rw_crappre_pf.vlpercom ELSE rw_crappre_pj.vlpercom END;
                vr_vlpercom := vr_vlpercom / 100;

                -- Valor maximo de parcela
                vr_vlmaxpar := (vr_vltotren * vr_vlpercom) - vr_vlparcav - vr_vlalugue;

                -- Caso nao tenha valor de parcela passa para o proximo
                IF vr_vlmaxpar <= 0 THEN
                  -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                  IF pr_flgexpor = 0 THEN
                    pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idcarga  => vr_idcarga
                                    ,pr_idmotivo => 9 -- Sem Parcela Disponivel
                                    ,pr_dsvalor  => '');
                  END IF;
                  CONTINUE;
                END IF;

                -- Calcula o Valor Presente com a formula da HP financeira, ou seja, qual eh o valor a ser emprestado
                vr_vlpresen := ((((POWER(1 + vr_txjurmes, vr_qtmaxpar) - 1) / vr_txjurmes) * vr_vlmaxpar) /
                                POWER(1 + vr_txjurmes, vr_qtmaxpar));

                -- Caso o Valor Presente seja menor que o Limite de Cotas
                IF vr_vlpresen < vr_vlimcota THEN
                  vr_vlimcota := vr_vlpresen;

                  -- O limite da cota NAO pode ser menor que valor minimo ofertado
                  IF vr_vlimcota < vr_vllimmin THEN
                    -- Caso NAO seja uma exportacao para SPC/Serasa grava o motivo
                    IF pr_flgexpor = 0 THEN
                      pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_idcarga  => vr_idcarga
                                      ,pr_idmotivo => 6 -- Limite de cotas
                                      ,pr_dsvalor  => 'R$ ' || TO_CHAR(vr_vlimcota,'fm999g999g999g990d00'));
                    END IF;
                    CONTINUE;
                  END IF;
                END IF;

                -- Se NAO for exportacao para SPC/Serasa e NAO foi consultado(0)
                IF pr_flgexpor = 0 AND rw_crapass.inserasa = 0 THEN
                  -- Grava o motivo
                  pc_inclui_motivo(pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_idcarga  => vr_idcarga
                                  ,pr_idmotivo => 19 -- Sem Consulta no Serasa
                                  ,pr_dsvalor  => '');
                  CONTINUE;
                END IF;

                -- Caso NAO seja uma exportacao para SPC/Serasa
                IF pr_flgexpor = 0 THEN

                  -- Calcula o Credito com multiplo cadastrado na crappre, pegando o menor valor
                  vr_vlimcota := vr_vlimcota / vr_vlmulpli;
                  vr_vlimcota := TRUNC(vr_vlimcota, 0);
                  vr_vlimcota := vr_vlimcota * vr_vlmulpli;

                  -- Somatoria de Credito
                  IF vr_inpessoa = 1 THEN
                    vr_vltot_pf := vr_vltot_pf + vr_vlimcota;
                  ELSE
                    vr_vltot_pj := vr_vltot_pj + vr_vlimcota;
                  END IF;

                  -- Selecionar primeiro telefone celular
                  OPEN cr_craptfc (pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_idseqttl => 1
                                  ,pr_tptelefo => 2); -- Celular
                  -- Posicionar primeiro registro
                  FETCH cr_craptfc INTO rw_craptfc;
                  vr_flgachou := cr_craptfc%FOUND;
                  CLOSE cr_craptfc;
                  -- Se encontrar
                  IF vr_flgachou THEN
                    vr_nrtelefo := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
                  ELSE
                    vr_nrtelefo := ' ';
                  END IF;

                  -- Monta o relatorio .txt
                  GENE0001.pc_escr_linha_arquivo(vr_arqhandl,
                                 LPAD(gene0002.fn_mask_conta(rw_crapass.nrdconta), 15, ' ') || ' ' ||
                                 LPAD(vr_tipessoa, 4, ' ') || ' ' ||
                                 LPAD(vr_nivrisco, 5, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vlsdcota,'fm999g999g999g990d00'), 15, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vldescon,'fm999g999g999g990d00'), 15, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vlimcota,'fm999g999g999g990d00'), 15, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vlparcav,'fm999g999g999g990d00'), 15, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vltotren,'fm999g999g999g990d00'), 15, ' ') || ' ' ||
                                 LPAD(TO_CHAR(vr_vlmaxpar,'fm999g999g999g990d00'), 15, ' ') || '  ' ||
                                 LPAD(vr_nrtelefo, 10, ' ') || '  ' ||
                                 LPAD(rw_crapass.bloqueado, 9, ' '));

                  -- Grava os dados calculados na tabela de Credito Pre Aprovado
                  BEGIN
                    INSERT INTO crapcpa (cdcooper
                                        ,nrdconta
                                        ,dtmvtolt
                                        ,vlcalpre
                                        ,vlcalcot
                                        ,vlcaldes
                                        ,vlcalpar
                                        ,vlcalren
                                        ,vlcalven
                                        ,dscalris
                                        ,vllimdis
                                        ,iddcarga
                                        ,cdlcremp)
                                 VALUES (rw_crapass.cdcooper
                                        ,rw_crapass.nrdconta
                                        ,rw_crapdat.dtmvtolt
                                        ,vr_vlimcota
                                        ,vr_vlsdcota
                                        ,vr_vldescon
                                        ,vr_vlmaxpar
                                        ,vr_vltotren
                                        ,vr_vlparcav
                                        ,vr_nivrisco
                                        ,vr_vlimcota
                                        ,vr_idcarga
                                        ,vr_cdlcremp);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Problema ao incluir dados na tabela crapcpa: ' || sqlerrm;
                      RAISE vr_exc_saida;
                  END;

                ELSE

                  -- Monta indice
                  vr_idx := rw_crapass.nrcpfcgc;
                  -- Se nao existir cria o registro
                  IF NOT vr_tab_cpfcnpj.EXISTS(vr_idx) THEN
                    vr_tab_cpfcnpj(vr_idx).inpessoa := vr_inpessoa;
                    IF vr_inpessoa = 1 THEN -- PF
                      vr_tab_cpfcnpj(vr_idx).nrcpfcgc := LPAD(rw_crapass.nrcpfcgc,11,'0');
                    ELSE -- PJ
                      vr_tab_cpfcnpj(vr_idx).nrcpfcgc := LPAD(rw_crapass.nrcpfcgc,14,'0');
                    END IF;
                  END IF;

                END IF;

              END LOOP; -- Fim do Loop da crapass

            END LOOP; -- Fim do Loop do tipo de pessoa

            -- Caso NAO seja uma exportacao para SPC/Serasa
            IF pr_flgexpor = 0 THEN

              -- Atualiza o Total de Credito Disponivel
              BEGIN
                UPDATE tbepr_carga_pre_aprv
                   SET vltotal_pre_aprv_pf = vr_vltot_pf
                      ,vltotal_pre_aprv_pj = vr_vltot_pj
                      ,dtcalculo = SYSDATE
                 WHERE idcarga = vr_idcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao atualizar Total de Credito: ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;

              -- Escreve os Totais
              GENE0001.pc_escr_linha_arquivo(vr_arqhandl,'');
              GENE0001.pc_escr_linha_arquivo(vr_arqhandl, 'Total de Credito: ' || TO_CHAR((vr_vltot_pf + vr_vltot_pj),'fm999g999g999g990d00'));
              GENE0001.pc_escr_linha_arquivo(vr_arqhandl, 'Valor Maximo Legal: ' || TO_CHAR(vr_vlmaximo,'fm999g999g999g990d00'));

            -- Caso seja uma exportacao para SPC/Serasa, monta o relatorio .txt
            ELSE

              -- Ler registros de CPF/CNPJ
              vr_idx := vr_tab_cpfcnpj.FIRST;
              WHILE vr_idx IS NOT NULL LOOP
                IF vr_tab_cpfcnpj(vr_idx).inpessoa = 1 THEN -- PF
                  GENE0001.pc_escr_linha_arquivo(vr_arqhandl, vr_tab_cpfcnpj(vr_idx).nrcpfcgc);
                ELSE -- PJ
                  GENE0001.pc_escr_linha_arquivo(vr_arqhand2, vr_tab_cpfcnpj(vr_idx).nrcpfcgc);
                END IF;
                -- Buscar o proximo registro
                vr_idx := vr_tab_cpfcnpj.NEXT(vr_idx);
              END LOOP;

            END IF;

          END IF; -- rw_crapcop.vllimmes > 0

          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl); --> Handle do arquivo aberto

          -- Montar Comando para converter o arquivo para DOS
          vr_dscomand := 'ux2dos '|| vr_arq_path || '/' || vr_arq_temp || ' > '
                                  || vr_arq_path || '/' || vr_arq_nome;

          -- Converter de UNIX para DOS o arquivo
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_dscomand
                               ,pr_typ_saida   => vr_typsaida
                               ,pr_des_saida   => vr_dscritic);

          IF vr_typsaida = 'ERR' THEN
             -- O comando shell executou com erro, gerar log e sair do processo
             vr_dscritic := 'Erro ao converter arquivo.' || vr_dscritic;
             RAISE vr_exc_saida;
          END IF;

          -- Remover arquivo lst gerado
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'rm -f '|| vr_arq_path || '/' || vr_arq_temp
                               ,pr_typ_saida   => vr_typsaida
                               ,pr_des_saida   => vr_dscritic);

          IF vr_typsaida = 'ERR' THEN
             -- O comando shell executou com erro, gerar log e sair do processo
             vr_dscritic := 'Erro ao remover arquivo.' || vr_dscritic;
             RAISE vr_exc_saida;
          END IF;

          -- Caso seja uma exportacao para SPC/Serasa
          IF pr_flgexpor = 1 THEN

            -- Fechar o arquivo
            GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhand2); --> Handle do arquivo aberto

            -- Montar Comando para converter o arquivo para DOS
            vr_dscomand := 'ux2dos '|| vr_arq_path || '/' || vr_arq_tmp2 || ' > '
                                    || vr_arq_path || '/' || vr_arq_nom2;

            -- Converter de UNIX para DOS o arquivo
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_dscomand
                                 ,pr_typ_saida   => vr_typsaida
                                 ,pr_des_saida   => vr_dscritic);

            IF vr_typsaida = 'ERR' THEN
               -- O comando shell executou com erro, gerar log e sair do processo
               vr_dscritic := 'Erro ao converter arquivo.' || vr_dscritic;
               RAISE vr_exc_saida;
            END IF;

            -- Remover arquivo lst gerado
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => 'rm -f '|| vr_arq_path || '/' || vr_arq_tmp2
                                 ,pr_typ_saida   => vr_typsaida
                                 ,pr_des_saida   => vr_dscritic);

            IF vr_typsaida = 'ERR' THEN
               -- O comando shell executou com erro, gerar log e sair do processo
               vr_dscritic := 'Erro ao remover arquivo.' || vr_dscritic;
               RAISE vr_exc_saida;
            END IF;

            -- Muda status para sem consulta
            BEGIN
              UPDATE crapass
                 SET crapass.inserasa = 0 -- Sem consulta
               WHERE crapass.cdcooper = rw_crapcop.cdcooper;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar crapass: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          -- Caso NAO seja uma exportacao para SPC/Serasa
          ELSIF pr_flgexpor = 0 THEN

            -- Fazer uma copia para a pasta /micros/cecred/preaprovado/carga/
            vr_path_cop := GENE0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CRPS682_CARGA');

            -- Copiar arquivo para o diretorio encontrado
            vr_comando:= 'cp '||vr_arq_path||'/'||vr_arq_nome||' '
                              ||vr_path_cop||'/'||UPPER(rw_crapcop.dsdircop)||'_'
                              ||TO_CHAR(rw_crapdat.dtmvtolt, 'DDMMRRRR')||'_'
                              ||TO_CHAR(sysdate, 'hh24miss')||'.txt';

            -- Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typsaida
                                 ,pr_des_saida   => vr_dscritic);
            -- Se ocorreu erro
            IF vr_typsaida = 'ERR' THEN
              vr_dscritic:= 'N�o foi poss�vel executar comando unix. '||vr_comando||' Erro: '||vr_dscritic;
              RAISE vr_exc_saida;
            END IF;

          END IF;

          -- Atualiza para Gerada
          pc_atualiza_status(pr_idcarga  => vr_idcarga
                            ,pr_insitcar => 1 -- Gerada
                            ,pr_flgexpor => pr_flgexpor);

      END IF;

      -- Processo OK, devemos chamar a fimprg
      BTCH0001.pc_valida_fimprg(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

    END LOOP; -- cr_crapcop

    -- Caso NAO seja uma exportacao para SPC/Serasa
    IF pr_flgexpor = 0 THEN

      -- Efetua a limpeza do diretorio Carga
      vr_path_cop := GENE0001.fn_param_sistema('CRED',0,'CRPS682_CARGA');
      EMPR0002.pc_limpeza_diretorio(pr_nmdireto => vr_path_cop
                                   ,pr_dscritic => vr_dscritic);

      -- Efetua a limpeza do diretorio Exporta
      vr_path_cop := GENE0001.fn_param_sistema('CRED',0,'CRPS682_EXPORTA');
      EMPR0002.pc_limpeza_diretorio(pr_nmdireto => vr_path_cop
                                   ,pr_dscritic => vr_dscritic);

      -- Efetua a limpeza do diretorio Importa
      vr_path_cop := GENE0001.fn_param_sistema('CRED',0,'CRPS682_IMPORTA');
      EMPR0002.pc_limpeza_diretorio(pr_nmdireto => vr_path_cop
                                   ,pr_dscritic => vr_dscritic);

    END IF;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := nvl(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

      -- Atualiza para Gerada
      pc_atualiza_status(pr_idcarga  => vr_idcarga
                        ,pr_insitcar => 1 -- Gerada
                        ,pr_flgexpor => pr_flgexpor);
      COMMIT;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

      -- Atualiza para Gerada
      pc_atualiza_status(pr_idcarga  => vr_idcarga
                        ,pr_insitcar => 1 -- Gerada
                        ,pr_flgexpor => pr_flgexpor);
      COMMIT;
  END;

END pc_crps682;
/
