CREATE OR REPLACE PROCEDURE CECRED.pc_crps573_1(pr_cdcooper  IN crapcop.cdcooper%TYPE             --> Cooperativa solicitada
                                               ,pr_dtrefere  IN crapdat.dtmvtolt%TYPE             --> Data de referência
                                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE             --> Data do calendário
                                               ,pr_dtultdma  IN crapdat.dtmvtolt%TYPE             --> Data do ultimo dia do mês anterior
                                               ,pr_inproces  IN crapdat.inproces%TYPE             --> Indicador do estado do processo
                                               ,pr_vlsalmin  IN NUMBER                            --> Valor do mínimo
                                               ,pr_txeanual  IN NUMBER                            --> Taxa anual
                                               ,pr_cdagenci  IN crapage.cdagenci%TYPE DEFAULT 0 --> Codigo Agencia
                                               ,pr_idparale  IN crappar.idparale%TYPE DEFAULT 0 --> Indicador de processoparalelo
                                               ,pr_flbbndes  IN VARCHAR2              DEFAULT 'N' --> Flag de execução específica do BNDES
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Critica encontrada
                                               ,pr_dscritic OUT VARCHAR2) IS                      --> Texto de erro/critica encontrada
  BEGIN
    
    /* .............................................................................

       Programa: pc_crps573_1 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos-Envolti
       Data    : Julho/2018                       Ultima atualizacao: 25/07/2019

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Gerar arquivo(3040) Dados Individualizados de Risco de Credito
                   Juncao do 3020 com o 3030
                   Geracao de relatorio para conferencia
                   Solicitacao : 80
                   Ordem do programa na solicitacao = 4.
                   Relatorio 566 e 567.
                   Programa baseado no crps368
                   Programa baseado no crps369 (tag <Agreg>)
                   Geração do arquivo 3040 BNDES quando solicitado via parâmetro

       Alteracoes :  04/07/2018 - P450 - Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos 
                                 (cdorigem = 3) estejam em Prejuízo (innivris = 10) - Daniel(AMcom)                                  

                     16/07/2018 - Ajustes no procedimento de paralelismo para ganho de performance. - Mario Bernat (Amcom).
                                            
                     20/08/2018 - P450 - Correção Ativo Problematio (Daniel/AMcom)
                                            
                     28/08/2018 - Quando o Juros60 for maior que o valor da divida, enviar o valor da divida, 
                                  senao subtrair do valor da divida o Juros60 para emprestimos em prejuizo. (P450 - Jaison)

                     18/09/2018 - P450 - Correção Juros60
                                  P450 - Correção no valor do contrato para a modalidade 0101(Reginaldo/AMcom)

                     25/09/2018 - P450 - Ajustes 3040
                                - Alterado as regras das faixas de classificação do porte para PF e PJ - Heckmann (AMcom)
                                - Alterado para adicionar a Tag '<Inf Tp="1998" />' quando:
                                  Utilizacao de aplicacao propria para cobertura da garantia da operacao (1-Sim)
                                  Ou
                                  Utilizacao de poupanca programada propria para cobertura (1-Sim) - Heckmann (AMcom)
                                - Busca taxa mensal do contrato do empréstimo (Tag taxeft) Renato Cordeiro - AMcom
                                - FINAME - Usar indexador da tabela e não fixo "11" (Guilherme/AMcom)
                                - Inclusão de Exception na inserção da tabela tbhist_ativo_probl (Fernando Ornelas AMcom)
                                - Criacao de regra de data de corte para considerar a Tag '<Inf Tp="1998" />' do
                                  Colateral Financeiro - Heckmann (AMcom)

                     10/10/2018 - P450 - Ajustes Gerais Juros60/ADP/Empr. (Guilherme/AMcom)
                     
                     19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável e 
                                  onde há Caminhao apenas, utilizar também Outros Veiculos (Marcos-Envolti)
                     
					 09/11/2018 - P450 - Correção na geração dos vencimentos para a modalidade 101 nas tags <Agreg>
							      (Reginaldo/AMcom)			

                     05/12/2018 - P438 - Sprint 7 - Paulo Martins
                                   Incluído Galpão, MAQUINA E EQUIPAMENTO                     

                     15/01/2019 - P450 - Ajuste BNDES / Taxa Mensal (Guilherme/AMcom)
                     
					 08/04/2019 - P450 - Ajuste BNDES / Codigo Indexador (Guilherme/AMcom)
                     
                     25/07/2019 - P450 - Ajuste Chave PJ nao preenchida
                                       - Ajuste Agrupamento CNPJ/Remover Duplicados
                                  (Guilherme/AMcom)

                     22/08/2019 - P485.6 - Alterar a rotina pc_inf_ente_consignante, para enviar CPF caso o empregador for 
                                  pessoa física. (Renato Darosci - Supero)
                     
    .............................................................................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS573';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- ** Daniel(AMcom)
      vr_atvprobl   NUMBER := 0;
      vr_reestrut   NUMBER := 0;
      vr_dtatvprobl varchar2(100);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.dsnomscr
              ,cop.dsemascr
              ,cop.dstelscr
              ,cop.nrcepend
              ,cop.cdufdcop
              ,cop.dsdircop
          FROM crapcop cop;
      TYPE typ_tab_crapcop IS
        TABLE OF cr_crapcop%ROWTYPE
          INDEX BY PLS_INTEGER;
      vr_tab_crapcop typ_tab_crapcop;

      -- Busca informacoes da central de risco
      CURSOR cr_crapris_relato(pr_cdcooper IN NUMBER
                              ,pr_dtrefere DATE) IS
        SELECT crapris.*
              ,ROW_NUMBER () OVER (PARTITION BY crapris.nrcpfcgc ORDER BY crapris.nrcpfcgc) nrseq
              ,COUNT(1)      OVER (PARTITION BY crapris.nrcpfcgc ORDER BY crapris.nrcpfcgc) qtreg
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto = 1 -- documento 3020
          ORDER BY crapris.nrcpfcgc, crapris.innivris, crapris.nrdconta;  

      -- Cursor de contas transferidas entre cooperativas
      CURSOR cr_craptco (pr_cdcooper IN NUMBER
                        ,pr_nrdconta craptco.nrdconta%TYPE) IS
        SELECT 1
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.nrdconta = pr_nrdconta
           AND craptco.tpctatrf <> 3;
      rw_craptco cr_craptco%ROWTYPE;

      -- Cursor de contas transferidas entre cooperativas
      CURSOR cr_craptco_b (pr_cdcooper IN NUMBER
                          ,pr_nrdconta     crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.nrdconta = pr_nrdconta
           AND craptco.tpctatrf <> 3
           AND craptco.cdageant IN (2, 4, 6, 7, 11);
      rw_craptco_b cr_craptco_b%ROWTYPE;

      -- Cursor sobre o cadastro de emprestimos
      CURSOR cr_crapepr (pr_cdcooper crapass.cdcooper%TYPE
                        ,pr_cdagenci crapass.cdcooper%TYPE) IS
        SELECT epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.dtmvtolt
              ,epr.cdlcremp
              ,epr.vlpreemp
              ,epr.vlemprst
              ,epr.dtprejuz
              ,epr.inprejuz
              ,epr.tpemprst
              ,epr.nrctaav1
              ,epr.nrctaav2
              ,epr.qtpreemp
              ,epr.dtdpagto          -- Prx Pagto
              ,wpr.dtdpagto dtdpripg -- Pri Pagto
              ,wpr.cddindex
              ,wpr.nrctrliq##1+
               wpr.nrctrliq##2+
               wpr.nrctrliq##3+
               wpr.nrctrliq##4+
               wpr.nrctrliq##5+
               wpr.nrctrliq##6+
               wpr.nrctrliq##7+
               wpr.nrctrliq##8+
               wpr.nrctrliq##9+
               wpr.nrctrliq##10+
               NVL(wpr.nrliquid,0)     qtctrliq -- Se houver qq contrato, teremos a soma + 0          
              ,wpr.idquapro
              ,epr.idquaprc
              ,epr.txmensal
          FROM crapepr epr
              ,crawepr wpr
              ,crapass ass
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.cdcooper = wpr.cdcooper
           AND epr.nrdconta = wpr.nrdconta
           AND epr.nrctremp = wpr.nrctremp
           AND epr.cdcooper = ass.cdcooper
           AND epr.nrdconta = ass.nrdconta
           and ass.cdagenci = Decode(pr_cdagenci,0, ass.cdagenci, pr_Cdagenci);
      
      -- Cursor sobre o cadastro de emprestimos
      CURSOR cr_crapepr_BNDEs IS
        SELECT epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.dtmvtolt
              ,epr.cdlcremp
              ,epr.vlpreemp
              ,epr.vlemprst
              ,epr.dtprejuz
              ,epr.inprejuz
              ,epr.tpemprst
              ,epr.nrctaav1
              ,epr.nrctaav2
              ,epr.qtpreemp
              ,epr.dtdpagto          -- Prx Pagto
              ,wpr.dtdpagto dtdpripg -- Pri Pagto
              ,wpr.cddindex
              ,wpr.nrctrliq##1+
               wpr.nrctrliq##2+
               wpr.nrctrliq##3+
               wpr.nrctrliq##4+
               wpr.nrctrliq##5+
               wpr.nrctrliq##6+
               wpr.nrctrliq##7+
               wpr.nrctrliq##8+
               wpr.nrctrliq##9+
               wpr.nrctrliq##10+
               NVL(wpr.nrliquid,0)     qtctrliq -- Se houver qq contrato, teremos a soma + 0          
              ,wpr.idquapro
              ,epr.idquaprc
              ,epr.txmensal
          FROM crapepr epr
              ,crawepr wpr
              ,craplcr lcr
         WHERE epr.cdcooper = wpr.cdcooper
           AND epr.nrdconta = wpr.nrdconta
           AND epr.nrctremp = wpr.nrctremp
           AND epr.cdcooper = lcr.cdcooper
           AND epr.cdlcremp = lcr.cdlcremp
           AND lcr.dsorgrec IN('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES');
      
      -- Cursor sobre a tabela de vencimento do risco buscando o maior codigo de vencimento
      CURSOR cr_crapvri_max(pr_cdcooper NUMBER
                           ,pr_nrdconta crapvri.nrdconta%TYPE
                           ,pr_dtrefere DATE
                           ,pr_innivris crapvri.innivris%TYPE
                           ,pr_cdmodali crapvri.cdmodali%TYPE
                           ,pr_nrctremp crapvri.nrctremp%TYPE) IS
        SELECT MAX(cdvencto) cdvencto
          FROM crapvri
         WHERE crapvri.cdcooper = pr_cdcooper
           AND crapvri.nrdconta = pr_nrdconta
           AND crapvri.dtrefere = pr_dtrefere
           AND crapvri.innivris = pr_innivris
           AND crapvri.cdmodali = pr_cdmodali
           AND crapvri.nrctremp = pr_nrctremp;
      rw_crapvri cr_crapvri_max%ROWTYPE;

      -- Cursor sobre a tabela de vencimento do risco
      CURSOR cr_crapvri_venct (pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_nrdconta crapvri.nrdconta%TYPE
                              ,pr_dtrefere DATE
                              ,pr_cdmodali crapvri.cdmodali%TYPE
                              ,pr_nrctremp crapvri.nrctremp%TYPE) IS
        SELECT cdvencto,
               vldivida,
               ROW_NUMBER () OVER (PARTITION BY crapvri.nrdconta, crapvri.cdvencto ORDER BY crapvri.nrdconta, crapvri.nrctremp) nrseq,
               COUNT(1)      OVER (PARTITION BY crapvri.nrdconta, crapvri.cdvencto ORDER BY crapvri.nrdconta, crapvri.nrctremp) qtreg
          FROM crapvri
         WHERE crapvri.cdcooper = pr_cdcooper
           AND crapvri.nrdconta = pr_nrdconta
           AND crapvri.dtrefere = pr_dtrefere
           AND crapvri.cdmodali = pr_cdmodali
           AND crapvri.nrctremp = pr_nrctremp;


      -- Cursor sobre a tabela de vencimento do risco
      CURSOR cr_crapvri(pr_cdcooper NUMBER
                       ,pr_dtrefere DATE) IS
         SELECT vri.cdcooper,
                vri.cdvencto,
                vri.vldivida,
                vri.nrdconta,
                vri.innivris,
                vri.cdmodali,
                vri.nrseqctr,
                vri.nrctremp
           FROM crapvri vri
               ,crapass ass
          WHERE vri.cdcooper = pr_cdcooper
            AND vri.dtrefere = pr_dtrefere
           AND vri.cdcooper = ass.cdcooper
           AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci)
           AND vri.nrdconta = ass.nrdconta;
      
      -- Cursor sobre os vencimentos para execuções BNDES
      CURSOR cr_crapvri_bndes(pr_dtrefere DATE) IS
         SELECT vri.cdcooper,
                vri.cdvencto,
                vri.vldivida,
                vri.nrdconta,
                vri.innivris,
                vri.cdmodali,
                vri.nrseqctr,
                vri.nrctremp
           FROM crapvri vri               
          WHERE vri.dtrefere = pr_dtrefere;

      -- Cursor para busca dos percentuais de risco
      CURSOR cr_craptab(pr_cdcooper NUMBER) IS
        SELECT dstextab
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND UPPER(nmsistem) = 'CRED'
           AND UPPER(tptabela) = 'GENERI'
           AND cdempres = 00
           AND UPPER(cdacesso) = 'PROVISAOCL';
      rw_craptab cr_craptab%ROWTYPE;

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrcpfcgc,
               inpessoa,
               dsnivris,
               dtadmiss
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

      vr_nrcpfcgc_ass crapass.nrcpfcgc%TYPE;
      vr_inpessoa_ass crapass.inpessoa%TYPE;
      vr_dsnivris_ass crapass.dsnivris%TYPE;
      vr_dtadmiss_ass crapass.dtadmiss%TYPE;
      
      -- Busca dados por CPF/CNPJ em todas as cooperativas trazendo a conta mais antiga
      -- Buscar o pior risco dentre todas as contas do CPF/CGC
      CURSOR cr_crapass_cpfcnpj(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
        SELECT /*+ index(crapass CRAPASS##CRAPASS9) */
               cdcooper
              ,dsnivris
              ,dtadmiss
          FROM crapass
         WHERE crapass.nrcpfcnpj_base = pr_nrcpfcgc;
      vr_cdcooper_ass crapass.cdcooper%TYPE;
      
      -- Cursor para busca dos titulares da conta
      CURSOR cr_crapttl(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT vlsalari,
               vldrendi##1,
               vldrendi##2,
               vldrendi##3,
               vldrendi##4,
               vldrendi##5,
               vldrendi##6
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Cursor para busca dos dados financeiros de PJ
      CURSOR cr_crapjfn(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS
        SELECT vlrftbru##1 + vlrftbru##2 + vlrftbru##3 + vlrftbru##4  + vlrftbru##5  + vlrftbru##6 +
               vlrftbru##7 + vlrftbru##8 + vlrftbru##9 + vlrftbru##10 + vlrftbru##11 + vlrftbru##12 vlrftbru
          FROM crapjfn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

      -- Verificacao no cadastro de emprestimos do BNDES
      CURSOR cr_crapebn(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ebn.cdcooper,
               ebn.cdsubmod,
               ebn.vlropepr,
               ebn.dtinictr,
               ebn.dtfimctr,
               ebn.dtprejuz,
               ebn.txefeanu,
               ebn.nrdconta,
               ebn.nrctremp,
               ebn.dtvctpro,
               ebn.vlparepr,
               ebn.qtparctr
              ,NVL(ebn.cdindxdr,11) cdindxdr -- Se, por acaso nao atualizou o indexador, assume 11, conforme antes
          FROM crapebn ebn
              ,crapass ass
         WHERE ebn.cdcooper = pr_cdcooper
           And ebn.cdcooper = ass.cdcooper
           And ebn.nrdconta = ass.nrdconta
           And ass.cdagenci = Decode(Pr_Cdagenci,0,Ass.Cdagenci,Pr_Cdagenci);
      
      -- Emprestimos BNDES de todas cooperativas
      CURSOR cr_crapebn_bndes IS     
        SELECT ebn.cdcooper,
               ebn.cdsubmod,
               ebn.vlropepr,
               ebn.dtinictr,
               ebn.dtfimctr,
               ebn.dtprejuz,
               ebn.txefeanu,
               ebn.nrdconta,
               ebn.nrctremp,
               ebn.dtvctpro,
               ebn.vlparepr,
               ebn.qtparctr
              ,NVL(ebn.cdindxdr,11) cdindxdr -- Se, por acaso nao atualizou o indexador, assume 11, conforme antes
          FROM crapebn ebn;
      
      -- Busca taxa de Juros Cartao BB e Bancoob
      CURSOR cr_tbrisco_prod IS
        SELECT tparquivo
              ,vltaxa_juros
          FROM tbrisco_provisgarant_prodt
         WHERE tparquivo IN('Cartao_Bancoob','Cartao_BB');
      vr_vltxabb NUMBER(6,2);
      vr_vltxban NUMBER(6,2);
      
      -- Cursor para buscar os dados do cartao de credito
      CURSOR cr_tbcrd_risco (pr_cdcooper IN tbcrd_risco.cdcooper%TYPE
                            ,pr_cdagenci IN crapass.cdagenci%TYPE
                            ,pr_dtrefere IN tbcrd_risco.dtrefere%TYPE) IS
        SELECT tbcrd_risco.cdcooper,
               tbcrd_risco.nrdconta,
               tbcrd_risco.nrcontrato,
               tbcrd_risco.cdtipo_cartao,
               SUM(tbcrd_risco.vlsaldo_devedor) vlropcrd
          FROM tbcrd_risco
              ,crapass 
         WHERE tbcrd_risco.cdcooper = pr_cdcooper
           AND tbcrd_risco.dtrefere = pr_dtrefere
           and tbcrd_risco.cdcooper = crapass.cdcooper
           and crapass.cdagenci = Decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
           and tbcrd_risco.nrdconta = crapass.nrdconta
         GROUP BY tbcrd_risco.cdcooper,
                  tbcrd_risco.nrdconta,
                  tbcrd_risco.nrcontrato,
                  tbcrd_risco.cdtipo_cartao;
                
      -- Busca de linhas de credito
      CURSOR cr_craplcr(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cdcooper
              ,cdlcremp
              ,cdmodali
              ,cdsubmod
              ,txjurfix
              ,dsorgrec
              ,cdusolcr
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper;
      
      -- Busca das linhas do BNDES
      CURSOR cr_craplcr_bndes IS
        SELECT cdcooper
              ,cdlcremp
              ,cdmodali
              ,cdsubmod
              ,txjurfix
              ,dsorgrec
              ,cdusolcr
          FROM craplcr
         WHERE craplcr.dsorgrec IN('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES');


      -- Cursor sobre a tabela de limite de credito
      CURSOR cr_craplim (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta craplim.nrdconta%TYPE
                        ,pr_nrctremp craplim.nrctrlim%TYPE
                        ,pr_tpctrlim craplim.tpctrlim%TYPE) IS
        SELECT cddlinha,
               dtinivig,
               vllimite,
               nrctaav1,
               nrctaav2,
               qtdiavig
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrctrlim = pr_nrctremp
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = pr_tpctrlim;
      rw_craplim cr_craplim%ROWTYPE;

      -- Cursor sobre a tabela de linhas de credito rotativo
      CURSOR cr_craplrt (pr_inpessoa crapass.inpessoa%TYPE,
                         pr_cddlinha craplim.cddlinha%TYPE) IS
        SELECT txmensal
              ,cdmodali
              ,cdsubmod
          FROM craplrt
         WHERE craplrt.cdcooper = pr_cdcooper
           AND craplrt.tpdlinha = pr_inpessoa
           AND craplrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;      
      
      -- Detalhes do Borderô Cheque para busca do limite
      CURSOR cr_crapbdc (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapbdc.nrdconta%TYPE
                        ,pr_nrborder crapbdc.nrborder%TYPE) IS
        SELECT nrctrlim
          FROM crapbdc
         WHERE crapbdc.cdcooper = pr_cdcooper
           AND crapbdc.nrdconta = pr_nrdconta
           AND crapbdc.nrborder = pr_nrborder;
      
      -- Detalhes do Borderô Titulo para busca do limite
      CURSOR cr_crapbdt (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapbdt.nrdconta%TYPE
                        ,pr_nrborder crapbdt.nrborder%TYPE) IS
        SELECT nrctrlim
          FROM crapbdt
         WHERE crapbdt.cdcooper = pr_cdcooper
           AND crapbdt.nrdconta = pr_nrdconta
           AND crapbdt.nrborder = pr_nrborder;         
      vr_nrctrlim crapbdt.nrctrlim%TYPE;             

      -- Descricao dos bens da proposta de emprestimo do cooperado.
      CURSOR cr_crapbpr(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_nrdconta crapebn.nrdconta%TYPE,
                        pr_nrctremp crapebn.nrctremp%TYPE,
                        pr_tpctrpro crapbpr.tpctrpro%TYPE,
                        pr_idordena PLS_INTEGER) IS  -- 1=Ordem ascendente, 0=Ordem descendente
        SELECT nrcpfbem,
               vlperbem,
               upper(dscatbem) dscatbem,
               vlmerbem,
               dschassi
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro = pr_tpctrpro
           AND crapbpr.flgbaixa = 0
           AND crapbpr.flcancel = 0
           AND crapbpr.nrcpfbem <> 0
         ORDER BY progress_recid * pr_idordena, progress_recid DESC;
      rw_crapbpr cr_crapbpr%ROWTYPE;

      -- Descricao dos bens da proposta de emprestimo do cooperado.
      CURSOR cr_tbepr_bens_hst_2(pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_nrdconta crapebn.nrdconta%TYPE
                                ,pr_nrctremp crapebn.nrctremp%TYPE
                                ,pr_tpctrpro crapbpr.tpctrpro%TYPE
                                ,pr_dtrefere DATE) IS
        SELECT nrcpfbem,
               vlperbem,
               upper(dscatbem) dscatbem,
               vlmerbem,
               dschassi
          FROM tbepr_bens_hst hst
         WHERE hst.cdcooper = pr_cdcooper
           AND hst.nrdconta = pr_nrdconta
           AND hst.nrctrpro = pr_nrctremp
           AND hst.tpctrpro = pr_tpctrpro
           AND hst.flgbaixa = 0
           AND hst.flcancel = 0
           AND hst.vlmerbem > 0
           AND hst.flgalien = 1
           AND hst.dtrefere = last_day(pr_dtrefere);

      -- Descricao dos bens da proposta de emprestimo do cooperado.
      CURSOR cr_crapbpr_3(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_nrdconta crapebn.nrdconta%TYPE,
                          pr_nrctremp crapebn.nrctremp%TYPE,
                          pr_tpctrpro crapbpr.tpctrpro%TYPE) IS
        SELECT nrcpfbem,
               vlperbem,
               upper(dscatbem) dscatbem,
               vlmerbem,
               dschassi
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro = pr_tpctrpro
           AND crapbpr.flgbaixa = 0
           AND crapbpr.flcancel = 0
           AND crapbpr.nrcpfbem = 0;

      -- Descricao dos bens da proposta de emprestimo do cooperado.
      CURSOR cr_tbepr_bens_hst_4(pr_cdcooper crapcop.cdcooper%TYPE,
                                 pr_nrdconta crapebn.nrdconta%TYPE,
                                 pr_nrctremp crapebn.nrctremp%TYPE,
                                 pr_tpctrpro crapbpr.tpctrpro%TYPE,
                                 pr_dtrefere DATE) IS
        SELECT nrcpfbem,
               vlperbem,
               upper(dscatbem) dscatbem,
               vlmerbem,
               dschassi,
               flgbaixa,
               flcancel,
               cdsitgrv,
               dtdbaixa,
               dtcancel,
               dtatugrv,
               dtmvtolt
          FROM tbepr_bens_hst hst
         WHERE hst.cdcooper = pr_cdcooper
           AND hst.nrdconta = pr_nrdconta
           AND hst.nrctrpro = pr_nrctremp
           AND hst.tpctrpro = pr_tpctrpro             
           AND hst.flgalien = 1
           AND hst.dtrefere = last_day(pr_dtrefere);

      --> Verificar se é emprestimo de cessao de credito
      CURSOR cr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                        pr_nrdconta crapepr.nrdconta%TYPE,
                        pr_nrctremp crapepr.nrctremp%TYPE)  IS
        SELECT 1 flcessao
          FROM tbcrd_cessao_credito ces
         WHERE ces.cdcooper = pr_cdcooper
           AND ces.nrdconta = pr_nrdconta
           AND ces.nrctremp = pr_nrctremp;
      rw_cessao cr_cessao%ROWTYPE;
      
      --> Busca os movimentos digitados manualmente para os contratos inddocto=5
      CURSOR cr_movtos_garprest(pr_cdcooper crapcop.cdcooper%TYPE
                               ,pr_dtrefere DATE) IS
        SELECT mvt.cdcooper
              ,idmovto_risco
              ,risc0003.fn_valor_opcao_dominio(mvt.idorigem_recurso) dsorigem
              ,risc0003.fn_valor_opcao_dominio(mvt.idindexador) dsindexa
              ,mvt.perindexador prindexa
              ,risc0003.fn_valor_opcao_dominio(mvt.idnat_operacao) dsnature
              ,mvt.vltaxa_juros vltaxajr
              ,risc0003.fn_valor_opcao_dominio(prd.idconta_cosif) dsccosif
              ,risc0003.fn_valor_opcao_dominio(prd.idvariacao_cambial) dsvarcam
              ,risc0003.fn_valor_opcao_dominio(prd.idcaract_especial) dscarces
              ,prd.idorigem_cep idorgcep
              ,mvt.vloperacao vloperac
          FROM tbrisco_provisgarant_prodt prd
              ,tbrisco_provisgarant_movto mvt
         WHERE mvt.idproduto = prd.idproduto
           AND mvt.dtbase    = pr_dtrefere
           AND mvt.cdcooper = pr_cdcooper ;
     
      --> Busca os movimentos digitados manualmente para os contratos inddocto=5 só BNDES    
      CURSOR cr_movtos_garprest_bndes(pr_dtrefere DATE) IS
        SELECT mvt.cdcooper
              ,idmovto_risco
              ,risc0003.fn_valor_opcao_dominio(mvt.idorigem_recurso) dsorigem
              ,risc0003.fn_valor_opcao_dominio(mvt.idindexador) dsindexa
              ,mvt.perindexador prindexa
              ,risc0003.fn_valor_opcao_dominio(mvt.idnat_operacao) dsnature
              ,mvt.vltaxa_juros vltaxajr
              ,risc0003.fn_valor_opcao_dominio(prd.idconta_cosif) dsccosif
              ,risc0003.fn_valor_opcao_dominio(prd.idvariacao_cambial) dsvarcam
              ,risc0003.fn_valor_opcao_dominio(prd.idcaract_especial) dscarces
              ,prd.idorigem_cep idorgcep
              ,mvt.vloperacao vloperac
          FROM tbrisco_provisgarant_prodt prd
              ,tbrisco_provisgarant_movto mvt
         WHERE mvt.idproduto = prd.idproduto
           AND mvt.dtbase    = pr_dtrefere
                -- Se não for execução BNDES, traz só dessa coop
           AND prd.tparquivo = 'Cartao_BNDES_BRDE';        

      -- Busca agencias com movimentação para criação de JOBs para paralelismo. Objetivo: Ganho de performance.
      CURSOR cr_crapris_age(pr_cdcooper in craprpp.cdcooper%type,
                            pr_dtrefere DATE,
                            pr_cdprogra in tbgen_batch_controle.cdprogra%type,
                            pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) IS
        Select Distinct (crapass.cdagenci)
          FROM crapris, crapass
         WHERE crapass.cdcooper = pr_cdcooper
           and crapris.cdcooper = crapass.cdcooper
           and crapris.nrdconta = crapass.nrdconta
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto IN (1, 3, 4, 5) -- Operações Ativas, Limite Não Utilizado, Cartão de Crédito e Garantias Prestadas
           AND crapris.cdmodali <> 0301 -- Dsc Tit 
           AND crapris.inpessoa IN (1, 2) -- Deve ser CPF ou CNPJ
           AND crapris.vldivida <> 0 -- Com divida
           AND nvl(crapris.cdinfadi, ' ') <> '0301' -- Remover saidas para Inddocto=5
        order by crapass.cdagenci;     
         
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      
      -- Definicao do tipo de tabela do crapris
      TYPE typ_reg_saida IS
       RECORD(nrdconta crapris.nrdconta%TYPE,
              dtrefere crapris.dtrefere%TYPE,
              innivris crapris.innivris%TYPE,
              qtdiaatr crapris.qtdiaatr%TYPE,
              vldivida crapris.vldivida%TYPE,
              vlsld59d crapris.vlsld59d%TYPE,
              vlvec180 crapris.vlvec180%TYPE,
              vlvec360 crapris.vlvec360%TYPE,
              vlvec999 crapris.vlvec999%TYPE,
              vldiv060 crapris.vldiv060%TYPE,
              vldiv180 crapris.vldiv180%TYPE,
              vldiv360 crapris.vldiv360%TYPE,
              vldiv999 crapris.vldiv999%TYPE,
              vlprjano crapris.vlprjano%TYPE,
              vlprjaan crapris.vlprjaan%TYPE,
              inpessoa crapris.inpessoa%TYPE,
              nrcpfcgc crapris.nrcpfcgc%TYPE,
              nrdocnpj crapris.nrcpfcgc%TYPE,
              vlprjant crapris.vlprjant%TYPE,
              inddocto crapris.inddocto%TYPE,
              cdmodali crapris.cdmodali%TYPE,
              nrctremp crapris.nrctremp%TYPE,
              nrseqctr crapris.nrseqctr%TYPE,
              dtinictr crapris.dtinictr%TYPE,
              cdorigem crapris.cdorigem%TYPE,
              cdagenci crapris.cdagenci%TYPE,
              innivori crapris.innivori%TYPE,
              cdcooper crapris.cdcooper%TYPE,
              vlprjm60 crapris.vlprjm60%TYPE,
              dtdrisco crapris.dtdrisco%TYPE,
              qtdriclq crapris.qtdriclq%TYPE,
              nrdgrupo crapris.nrdgrupo%TYPE,
              vljura60 crapris.vljura60%TYPE,
              inindris crapris.inindris%TYPE,
              cdinfadi crapris.cdinfadi%TYPE,
              nrctrnov crapris.nrctrnov%TYPE,
              cdmodnov crapris.cdmodali%TYPE,
              dsinfnov crapris.dsinfaux%TYPE,
              flgindiv crapris.flgindiv%TYPE,
              sbcpfcgc VARCHAR2(14),
              dsinfaux crapris.dsinfaux%TYPE,
              dtprxpar crapris.dtprxpar%TYPE,
              vlprxpar crapris.vlprxpar%TYPE,
              qtparcel crapris.qtparcel%TYPE,
              dtvencop crapris.dtvencop%TYPE);
      TYPE typ_tab_saida IS
        TABLE OF typ_reg_saida
          INDEX BY VARCHAR2(37); -- CPF/CNPJ(14) + Coop(3) + Contrato(10) + Sequencia (10)

      -- Vetor para armazenar as saídas de Operação da Central
      vr_tab_saida typ_tab_saida;
      
      -- Variavel para o indice
      vr_vlcont_crapris PLS_INTEGER := 0;
      vr_indice_crapris VARCHAR2(37);

      
      -- Tabela temporaria work da CRAPRIS
      TYPE typ_reg_individ IS
       RECORD(cdcooper crapris.cdcooper%TYPE,
              nrdconta crapris.nrdconta%TYPE,
              innivris crapris.innivris%TYPE,
              inpessoa crapris.inpessoa%TYPE,
              nrcpfcgc crapris.nrcpfcgc%TYPE,
              cdmodali crapris.cdmodali%TYPE,
              nrctremp crapris.nrctremp%TYPE,
              nrseqctr crapris.nrseqctr%TYPE,
              vldivida crapris.vldivida%TYPE,
              vlsld59d crapris.vlsld59d%TYPE,
              dtinictr crapris.dtinictr%TYPE,
              cdorigem crapris.cdorigem%TYPE,
              nrdocnpj VARCHAR2(15),
              qtdiaatr crapris.qtdiaatr%TYPE,
              qtdriclq crapris.qtdriclq%TYPE,
              vljura60 crapris.vljura60%TYPE,
              inddocto crapris.inddocto%TYPE,
              cdinfadi crapris.cdinfadi%TYPE,
              dsinfaux crapris.dsinfaux%TYPE,
              dtprxpar crapris.dtprxpar%TYPE,
              vlprxpar crapris.vlprxpar%TYPE,
              qtparcel crapris.qtparcel%TYPE,
              nrdgrupo crapris.nrdgrupo%TYPE,
              dtvencop crapris.dtvencop%TYPE,
              flcessao INTEGER);
      TYPE typ_tab_individ IS
        TABLE OF typ_reg_individ
          INDEX BY VARCHAR2(37); --> CPF/CNPJ(14) + Coop(3) + Contrato(10) + Sequencial(10)
      -- Vetor para armazenar os dados da central de risco para uma tabela work
      vr_tab_individ typ_tab_individ;
      -- Variavel para o indice
      vr_idx_individ VARCHAR2(37);

      -- Tabela temporaria auxiliar da vr_tab_agreg
      TYPE typ_reg_agreg IS
       RECORD(cdcooper crapris.cdcooper%TYPE
             ,nrdconta crapris.nrdconta%TYPE
             ,innivris crapris.innivris%TYPE
             ,inpessoa crapris.inpessoa%TYPE
             ,nrcpfcgc crapris.nrcpfcgc%TYPE
             ,cdmodali crapris.cdmodali%TYPE
             ,nrctremp crapris.nrctremp%TYPE
             ,nrseqctr crapris.nrseqctr%TYPE
             ,vldivida crapris.vldivida%TYPE
             ,dtinictr crapris.dtinictr%TYPE
             ,cdorigem crapris.cdorigem%TYPE
             ,qtoperac PLS_INTEGER
             ,qtcooper PLS_INTEGER
             ,cddfaixa PLS_INTEGER
             ,nrdocnpj VARCHAR(15)
             ,cddesemp PLS_INTEGER
             ,vljura60 crapris.vljura60%TYPE
             ,cdnatuop VARCHAR2(04)
             ,inddocto crapris.inddocto%TYPE
             ,dsinfaux crapris.dsinfaux%TYPE);
      TYPE typ_tab_agreg IS
        TABLE OF typ_reg_agreg
          INDEX BY VARCHAR2(18);
      -- Vetor para armazenar os dados da typ_tab_agreg
      vr_tab_agreg typ_tab_agreg;
      -- Variavel para o indice
      vr_indice_agreg VARCHAR2(18);


      -- Tabela de vencimentos da typ_reg_agreg
      TYPE typ_reg_venc_agreg IS
       RECORD(cdmodali crapris.cdmodali%TYPE
             ,innivris crapris.innivris%TYPE
             ,cddfaixa PLS_INTEGER
             ,inpessoa crapris.inpessoa%TYPE
             ,cdvencto PLS_INTEGER
             ,vldivida NUMBER(17,2)
             ,cddesemp PLS_INTEGER
             ,cdnatuop VARCHAR2(04));
      TYPE typ_tab_venc_agreg IS
        TABLE OF typ_reg_venc_agreg
          INDEX BY VARCHAR2(23);
      -- Vetor para armazenar os dados da typ_tab_venc_agreg
      vr_tab_venc_agreg typ_tab_venc_agreg;
      -- Variavel para o indice
      vr_indice_venc_agreg VARCHAR2(23);


      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));
      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os percentuais de risco
      vr_tab_percentual typ_tab_percentual;

      -- Tabela temporaria para os valores das dividas
      TYPE typ_reg_divida IS
       RECORD(divida NUMBER(21,2));
      TYPE typ_tab_divida IS
        TABLE OF typ_reg_divida
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os valores das dividas
      vr_tab_divida typ_tab_divida;


      -- Tabela temporaria para os vencimento
      TYPE typ_reg_venc IS
       RECORD(cdvencto PLS_INTEGER,
              vldivida NUMBER(17,2));
      TYPE typ_tab_venc IS
        TABLE OF typ_reg_venc
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os percentuais de risco
      vr_tab_venc typ_tab_venc;
      -- Variavel para o indice
      vr_indice_venc PLS_INTEGER;

      -- As Pl/Tables abaixos foram incluidas para melhora da performance
      TYPE typ_reg_crapvri IS
       RECORD(cdvencto crapvri.cdvencto%TYPE,
              vldivida crapvri.vldivida%TYPE);
      TYPE typ_tab_crapvri IS
        TABLE OF typ_reg_crapvri
          INDEX BY VARCHAR2(45);

      -- Vetor para armazenar os vencimentos de risco quando o vencimento for menor que 190
      vr_tab_crapvri_b typ_tab_crapvri;
      -- Variavel para o indice dos vencimentos de risco quando o vencimento for menor que 190
      vr_indice_crapvri_b VARCHAR2(45);

      -- Variáveis para paralelismo
      -- Qtde parametrizada de Jobs
      vr_qtdjobs       number;
      vr_seq_relato    number:= 0;
      vr_nrcgccpf      number:=0;
      -- Job name dos processos criados
      vr_jobname       varchar2(30);
      --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
      vr_idlog_ini_ger tbgen_prglog.idprglog%type;
      vr_idlog_ini_par tbgen_prglog.idprglog%type;
      vr_tpexecucao    tbgen_prglog.tpexecucao%type;
      vr_nrdaconta     tbgen_batch_relatorio_wrk.nrdconta%type; 
      Vr_Texto         varchar(5000);
      Vr_Chave         varchar(5000);

      -- ID para o paralelismo
      vr_idparale      integer;
      vr_qterro        number := 0; 
      -- Bloco PLSQL para chamar a execução paralela do pc_crps750
      vr_dsplsql       varchar2(4000);
      vr_texto_xml     varchar2(4000) := NULL;

      -- Definicao do tipo da tabela de Emprestimos do BNDES
      TYPE typ_reg_crapebn IS
       RECORD(cdsubmod crapebn.cdsubmod%TYPE,
              vlropepr crapebn.vlropepr%TYPE,
              dtinictr crapebn.dtinictr%TYPE,
              dtfimctr crapebn.dtfimctr%TYPE,
              dtprejuz crapebn.dtprejuz%TYPE,
              txefeanu crapebn.txefeanu%TYPE,
              nrdconta crapebn.nrdconta%TYPE,
              dtvctpro crapebn.dtvctpro%TYPE,
              vlparepr crapebn.vlparepr%TYPE,
              qtparctr crapebn.qtparctr%TYPE,
              cdindxdr crapebn.cdindxdr%TYPE);
      TYPE typ_tab_crapebn IS
        TABLE OF typ_reg_crapebn
          INDEX BY VARCHAR2(33);
      -- Vetor para armazenar os dados da tabela de emprestimos do Bndes
      vr_tab_crapebn typ_tab_crapebn;
      -- Variavel para o indice
      vr_ind_ebn VARCHAR2(33);

      -- Definicao do tipo da tabela de emprestimos
      TYPE typ_reg_crapepr IS
       RECORD(dtmvtolt crapepr.dtmvtolt%TYPE
             ,cdlcremp crapepr.cdlcremp%TYPE
             ,vlpreemp crapepr.vlpreemp%TYPE
             ,vlemprst crapepr.vlemprst%TYPE
             ,dtprejuz crapepr.dtprejuz%TYPE
             ,nrctaav1 crapepr.nrctaav1%TYPE
             ,nrctaav2 crapepr.nrctaav2%TYPE
             ,qtpreemp crapepr.qtpreemp%TYPE
             ,dtdpagto crapepr.dtdpagto%TYPE
             ,dtdpripg crawepr.dtdpagto%TYPE
             ,qtctrliq NUMBER
             ,inprejuz crapepr.inprejuz%TYPE
             ,tpemprst crapepr.tpemprst%TYPE
             ,cddindex crawepr.cddindex%TYPE
             ,idquapro NUMBER
             ,idquaprc NUMBER
             ,txmensal crapepr.txmensal%TYPE);
      TYPE typ_tab_crapepr IS
        TABLE OF typ_reg_crapepr
          INDEX BY VARCHAR2(33);
      -- Vetor para armazenar os dados da tabela de emprestimos
      vr_tab_crapepr typ_tab_crapepr;
      -- Variavel para o indice
      vr_ind_epr VARCHAR2(33);

      -- Definicao do tipo da tabela de risco do cartao de credito
      TYPE typ_reg_tbcrd_risco IS
       RECORD(vlropcrd tbcrd_risco.vlsaldo_devedor%TYPE
             ,cdtipcar tbcrd_risco.cdtipo_cartao%TYPE);
       
      TYPE typ_tab_tbcrd_risco IS
        TABLE OF typ_reg_tbcrd_risco
          INDEX BY VARCHAR2(23);
      -- Vetor para armazenar os dados da tabela de emprestimos
      vr_tab_tbcrd_risco typ_tab_tbcrd_risco;
      -- Variavel para o indice
      vr_ind_crd VARCHAR2(23);
      
      -- Definicao do tipo da tabela para linhas de credito
      TYPE typ_reg_craplcr IS
       RECORD(cdmodali craplcr .cdmodali%TYPE,
              cdsubmod craplcr.cdsubmod%TYPE,
              txjurfix craplcr.txjurfix%TYPE,
              dsorgrec craplcr.dsorgrec%TYPE,
              cdusolcr craplcr.cdusolcr%TYPE);	
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY VARCHAR2(8); -- Codigo da Linha
      -- Vetor para armazenar os dados de Linha de Credito
      vr_tab_craplcr typ_tab_craplcr;
      vr_idx_lcr VARCHAR2(8);

      -- Estrutura para armazenar os totais das modalidades no arquivo
      TYPE typ_tab_totmodali IS
        TABLE OF NUMBER
          INDEX BY PLS_INTEGER; --> A modalidade será a chave
      vr_tab_totmodali typ_tab_totmodali;    
      vr_idx_totmodali PLS_INTEGER;
      
      -- Estrutura para armazenar as informações digitadas nos 
      -- movimentos de origem dos contratos inddocto=5
      TYPE typ_reg_movto_garant_prestad IS
        RECORD(cdcooper NUMBER
              ,idmovto_risco NUMBER
              ,dsorigem VARCHAR2(100)
              ,dsindexa VARCHAR2(100)
              ,prindexa NUMBER
              ,dsnature VARCHAR2(100)
              ,vltaxajr NUMBER
              ,dsccosif VARCHAR2(100)
              ,dsvarcam VARCHAR2(100)
              ,dscarces VARCHAR2(100)
              ,idorgcep VARCHAR2(1)
              ,vloperac NUMBER);
      TYPE typ_tab_movto_garant_prestad IS
        TABLE OF typ_reg_movto_garant_prestad
          INDEX BY VARCHAR2(41);
      vr_tab_mvto_garant_prest typ_tab_movto_garant_prestad;    
      
      -- Estrutura para armazenar por associado qual sua 
      -- data de conta mais antiga, seu pior risco, e o cep
      -- da Cooperativa da conta mais antiga
      TYPE typ_reg_associ IS
        RECORD(cdcooper crapcop.cdcooper%TYPE
              ,dsnivris crapass.dsnivris%TYPE
              ,dtadmiss crapass.dtadmiss%TYPE
              ,nrcepend crapcop.nrcepend%TYPE);
      TYPE typ_tab_associ IS
        TABLE OF typ_reg_associ
          INDEX BY VARCHAR2(14);      
      vr_tab_associ typ_tab_associ;
      
      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis de XML
      vr_xml_3040      CLOB;
      vr_xml_3040_temp VARCHAR2(32767);
      vr_xml_566       CLOB;
      vr_xml_566_temp  VARCHAR2(32767);
      vr_xml_567       CLOB;
      vr_xml_567_temp  VARCHAR2(32767);

      -- Variaveis gerais
      vr_vldivida_0301 crapris.vldivida%TYPE; -- Variavel acumulativa do valor da divida
      vr_qtregarq PLS_INTEGER := 0;           -- Variavel contadora de registros
      vr_nrdocnpj VARCHAR2(14);
      vr_nrdocnpj_base  VARCHAR2(8);
      vr_nrdocnpj2 VARCHAR2(14);
      vr_cdnatuop VARCHAR2(02);
      vr_vtomaior PLS_INTEGER;
      vr_cdmodali VARCHAR2(04);
      vr_dsorgrec VARCHAR2(04);
      vr_fatanual NUMBER(17,2);
      vr_vlrrendi NUMBER(17,2);
      vr_portecli PLS_INTEGER;
      vr_dtabtcct DATE;
      vr_classcli VARCHAR2(05);
      vr_vldivida NUMBER(17,2);
      vr_caracesp VARCHAR2(100);
      vr_vlrctado NUMBER(17,2); --> Valor contratado
      vr_dsvlrctd VARCHAR2(50); --> Descritivo do valor contratado
      vr_stgpecon VARCHAR2(100);
      vr_stdiasat VARCHAR2(100);
      vr_stperidx VARCHAR2(50);
      vr_ctacosif VARCHAR2(10);
      vr_dtfimctr DATE;         -- Data de Fim do Contrato
      vr_diasvenc PLS_INTEGER;  -- Guardar quantidade de dias do vencimento
      vr_cdvencto crapvri.cdvencto%TYPE;
      vr_indice_crapvri VARCHAR2(45);
      vr_vlrdivid NUMBER(17,2);
      vr_vldivida_aux NUMBER(17,2); -- Variável auxiliar para o valor da dívida
      vr_cloperis VARCHAR2(03);
      vr_innivris PLS_INTEGER;
      vr_coddindx PLS_INTEGER;
      vr_tpemprst crapepr.tpemprst%TYPE;
      vr_cddindex crawepr.cddindex%TYPE;
      vr_dtcorte        DATE;
      -- Taxas anuais
      vr_txeanual     NUMBER(10,4);
      --
      vr_vlpercen NUMBER(17,4);
      vr_vlpreatr NUMBER(17,2) := 0;
      vr_flgatras NUMBER(01);
      vr_qtcalcat PLS_INTEGER;
      vr_ttldivid NUMBER(17,2); -- Total da divida
      vr_vljurfai NUMBER(17,2);
      vr_flgfirst PLS_INTEGER;
      vr_vlacumul NUMBER(17,2);
      vr_vldivnor NUMBER(17,2);
      vr_vldivida_jur60 NUMBER(17,2);
      vr_stsnrcal BOOLEAN;
      vr_inpessoa INTEGER;
      vr_iddident VARCHAR2(04);
      -- Variaveis para os arquivos
      vr_nom_direto VARCHAR2(100);
      vr_nom_dirsal VARCHAR2(100);
      vr_nom_dirmic VARCHAR2(100);
      -- Variaveis de valores de vencimento conforme prazo
      vr_rsvec180 number(17,2);
      vr_rsvec360 number(17,2);
      vr_rsvec999 number(17,2);
      vr_rsdiv060 number(17,2);
      vr_rsdiv180 number(17,2);
      vr_rsdiv360 number(17,2);
      vr_rsdiv999 number(17,2);
      vr_rsprjano number(17,2);
      vr_rsprjaan number(17,2);
      vr_rsdivida number(17,2);
      vr_rsprjant number(17,2);
      vr_nrcpfcgc varchar2(14);
      vr_vlprjano number(17,2) := 0;
      vr_vlprjaan number(17,2) := 0;
      vr_vlprjant number(17,2) := 0;
      vr_totgeral number(17,2) := 0;
      vr_qtreg9   PLS_INTEGER  := 0;
      vr_crapvri  PLS_INTEGER  := 0;
      vr_idcpfcgc VARCHAR2(08);
      vr_totalcli PLS_INTEGER := 0;
      vr_flgarant BOOLEAN; --> Flag de controle de envio dos avalistas
      vr_vljuro60 crapris.vljura60%TYPE;

      vr_cep_3040        Number;
      vr_nrcontrato_3040 VARCHAR2(40);         -- Numero do contrato formatado
      vr_numparte        PLS_INTEGER := 0;     -- Numero da participar do arquivo 3040
      vr_contacli        PLS_INTEGER := 0;     -- Variavel para contar a quantidade de clientes      
      vr_qtregarq_3040   PLS_INTEGER := 50000; -- Quantidade de clientes por arquivo no 3040
      vr_flgfimaq        BOOLEAN     := FALSE; -- Variavel de controle para informar qual sera o ultimo arquivo
      vr_totalcli_dup    PLS_INTEGER := 0;     -- Totais de clientes duplos (PA)
      vr_nmarqsai_tot    VARCHAR2(1000) := NULL;
      
      --------------------------- SUBROTINAS INTERNAS --------------------------
	    
      -- Controla Controla log
      PROCEDURE pc_controla_log_batch(pr_idtiplog     IN NUMBER       -- Tipo de Log
                                     ,pr_dscritic     IN VARCHAR2) IS -- Descrição do Log
        vr_dstiplog VARCHAR2 (10);
      BEGIN
        -- Descrição do tipo de log
        IF pr_idtiplog = 2 THEN
          vr_dstiplog := 'ERRO: ';
        ELSE
          vr_dstiplog := 'ALERTA: ';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => pr_idtiplog
                                  ,pr_cdprograma   => vr_cdprogra
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> ' || vr_dstiplog
                                                              || pr_dscritic );     
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
      END pc_controla_log_batch;       
	    
      -- Retorno do código de localidade cfme UF
      FUNCTION fn_localiza_uf(pr_sig_UF IN VARCHAR2) RETURN NUMBER IS
      BEGIN
        -- De acordo com a UF da cooperativa, busca o codigo localizador
        CASE pr_sig_UF 
          WHEN 'AC' THEN
            RETURN 10012;
          WHEN 'AL'THEN
            RETURN 10036;
          WHEN 'AM' THEN
            RETURN 10013;
          WHEN 'AP' THEN
            RETURN 10014;
          WHEN 'BA' THEN
            RETURN 10039;
          WHEN 'CE' THEN
            RETURN 10032;
          WHEN 'DF' THEN
            RETURN 10096;
          WHEN 'ES' THEN
            RETURN 10092;
          WHEN 'GO' THEN
            RETURN 10092;
          WHEN 'MA' THEN
            RETURN 10030;
          WHEN 'MG' THEN
            RETURN 10050;
          WHEN 'MS' THEN
            RETURN 10091;
          WHEN 'MT' THEN
            RETURN 10090;
          WHEN 'PA' THEN
            RETURN 10017;
          WHEN 'PB' THEN
            RETURN 10034;
          WHEN 'PE' THEN
            RETURN 10035;
          WHEN 'PI' THEN
            RETURN 10031;
          WHEN 'PR' THEN
            RETURN 10073;
          WHEN 'RJ' THEN
            RETURN 10054;
          WHEN 'RN' THEN
            RETURN 10033;
          WHEN 'RO' THEN
            RETURN 10093;
          WHEN 'RR' THEN
            RETURN 10018;
          WHEN 'RS' THEN
            RETURN 10077;
          WHEN 'SC' THEN
            RETURN 10075;
          WHEN 'SE' THEN
            RETURN 10038;
          WHEN 'SP' THEN
            RETURN 10058;
          WHEN 'TO' THEN
            RETURN 10094;
          ELSE
            RETURN 0;
        END CASE;
      END fn_localiza_uf;
      
      -- Procedure para verificar se eh conta de migracao da cooperativa AltoVale
      FUNCTION fn_eh_conta_migracao_573(pr_cdcooper IN  crapris.cdcooper%TYPE
                                       ,pr_nrdconta IN  crapris.nrdconta%TYPE
                                       ,pr_dtrefere IN  DATE) RETURN BOOLEAN IS
        -- Cursor de contas transferidas entre cooperativas
        CURSOR cr_craptco (pr_nrdconta     crapass.nrdconta%TYPE,
                           pr_cdcooper_ant crapass.cdcooper%TYPE) IS
          SELECT 1
            FROM craptco
           WHERE craptco.cdcooper = pr_cdcooper
             AND craptco.cdcopant = pr_cdcooper_ant
             AND craptco.nrdconta = pr_nrdconta
             AND craptco.tpctatrf <> 3
             AND (pr_cdcooper_ant <> 2 OR
                  craptco.cdageant IN (2, 4, 6, 7, 11));
        rw_craptco cr_craptco%ROWTYPE;

      BEGIN
        -- Migracao Viacredi -> Altovale
        IF  pr_cdcooper = 16
        AND pr_dtrefere <= to_date('31/12/2012', 'dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 1);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        -- Migracao Acredicop -> Viacredi
        ELSIF pr_cdcooper = 1
          AND pr_dtrefere <= to_date('31/12/2013', 'dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 2);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        --> Incorporação Tranculcred -> Tranpocred
        ELSIF pr_cdcooper = 9
          AND pr_dtrefere <= to_date('31/12/2016', 'dd/mm/yyyy') THEN
          -- Verifica se a conta eh de transferencia entre cooperativas
          OPEN cr_craptco(pr_nrdconta, 17);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            RETURN true;
          END IF;
          CLOSE cr_craptco;
        END IF;
        -- Não é migracao
        RETURN false;
      END fn_eh_conta_migracao_573;

      -- Busca os dias de vencimento de acordo com o codigo de vencimento
      FUNCTION fn_busca_dias_vencimento(pr_codvenci IN PLS_INTEGER) RETURN NUMBER IS

      BEGIN
        CASE pr_codvenci 
          WHEN 110 THEN  -- Se o vencimento for para 1 dia
            RETURN 1;
          WHEN 120 THEN -- Se o vencimento for para 31 dias
            RETURN 31;
          WHEN 130 THEN -- Se o vencimento for para 61 dias
            RETURN 61;
          WHEN 140 THEN -- Se o vencimento for para 91 dias
            RETURN 91;
          WHEN 150 THEN -- Se o vencimento for para 181 dias
            RETURN 181;
          WHEN 160 THEN -- Se o vencimento for para 361 dias
            RETURN 361;
          WHEN 165 THEN -- Se o vencimento for para 165 dias
            RETURN 721;
          WHEN 170 THEN -- Se o vencimento for para 1081 dias
            RETURN 1081;
          WHEN 175 THEN -- Se o vencimento for para 1441 dias
            RETURN 1441;
          WHEN 180 THEN -- Se o vencimento for para 1801 dias
            RETURN 1801;
          WHEN 190 THEN -- Se o vencimento for para 5401 dias
            RETURN 5401;
          ELSE
            RETURN null;  
        END CASE;
      END fn_busca_dias_vencimento;

      -- Busca a origem do recurso
      FUNCTION fn_busca_dsorgrec(pr_cdcooper      IN crapcop.cdcooper%TYPE
                                ,pr_cdmodali      IN PLS_INTEGER
                                ,pr_nrdconta      IN crapepr.nrdconta%TYPE
                                ,pr_nrctremp      IN crapepr.nrctremp%TYPE
                                ,pr_cdorigem      IN crapris.cdorigem%TYPE
                                ,pr_dsinfaux      IN crapris.dsinfaux%TYPE) RETURN VARCHAR2 IS

        vr_dsorgrec_out VARCHAR2(4);
      BEGIN
        -- Apenas uma condicao altera pr_dsorgrec_out
        vr_dsorgrec_out := '0199';
        -- Para Emprestimos ou Financiamentos
        IF pr_cdmodali in(0299,0499) AND pr_cdorigem = 3 THEN
          -- Para empréstimo Ayllos
          IF pr_dsinfaux != 'BNDES' THEN
            -- Buscaremos da Linha de Crédito Cfme Crapepr
            vr_ind_epr := lpad(pr_cdcooper,03,'0')
                       || lpad(pr_nrdconta,10,'0')
                       || lpad(pr_nrctremp,10,'0');  
            -- IDX da Linha de Credito
            vr_idx_lcr := lpad(pr_cdcooper,03,'0')
                       || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');
            -- Somente se existir linha de credito
            IF vr_tab_craplcr.EXISTS(vr_idx_lcr) THEN
              -- Se Origem Recurso BNDES, altera para '0202'
              IF vr_tab_craplcr(vr_idx_lcr).dsorgrec IN('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES') THEN
                vr_dsorgrec_out := '0202';
              END IF;
            END IF;
		      ELSE --se for BNDES - SD 426476
            vr_dsorgrec_out := '0203'; 			
          END IF;
        -- Para Contratos de Garantias Prestadas
        ELSIF pr_cdorigem = 7 THEN
          -- Verificar se existe o movimento na tabela de origem das informações
          IF vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper,03,'0')||pr_dsinfaux) THEN 
            -- Usaremos a origem de recurso gravada
            vr_dsorgrec_out := vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).dsorigem;
          END IF;  
        END IF;
        -- Retornar
        RETURN vr_dsorgrec_out;
      END fn_busca_dsorgrec;  

      -- Formata o codigo da modalidade
      FUNCTION fn_formata_numero_contrato(pr_cdcooper IN crapris.cdcooper%TYPE
                                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                                         ,pr_nrctremp IN crapris.nrctremp%TYPE
                                         ,pr_cdmodali IN crapris.cdmodali%TYPE) RETURN VARCHAR2 IS
        vr_nrmodalidade VARCHAR2(40);
      BEGIN
        vr_nrmodalidade := LPAD(pr_cdcooper,5,'0')  ||
                           LPAD(pr_nrdconta,15,'0') ||
                           LPAD(pr_nrctremp,15,'0') ||
                           LPAD(pr_cdmodali,5,'0');
        -- Retornar
        RETURN vr_nrmodalidade;
        
      END fn_formata_numero_contrato;   
      
      -- Buscar variacao cambial
      FUNCTION fn_varcambial(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_inddocto IN crapris.inddocto%TYPE
                            ,pr_dsinfaux IN crapris.dsinfaux%TYPE) RETURN NUMBER IS

      BEGIN
        -- Para indocto = 5 a variação cambial está em cadastro
        IF pr_inddocto = 5
        AND vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper, 03, '0') || pr_dsinfaux) THEN
          RETURN vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).dsvarcam;
        ELSE
          -- Outros casos é fixo
          RETURN '790';
        END IF;
      END;     
      
      -- Buscar CEP
      FUNCTION fn_cepende(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrcpfcgc in crapass.nrcpfcgc%TYPE
                         ,pr_inddocto IN crapris.inddocto%TYPE
                         ,pr_dsinfaux IN crapris.dsinfaux%TYPE
                         ,pr_flbbndes IN VARCHAR2) RETURN NUMBER IS
      BEGIN
        -- Para execução BNDES
        IF pr_flbbndes = 'S' THEN
          -- Retornar o valor da tabela se existir, senão virá da central
          IF vr_tab_associ.exists(pr_nrcpfcgc) THEN
            RETURN vr_tab_associ(pr_nrcpfcgc).nrcepend;
          ELSE 
            RETURN vr_tab_crapcop(3).nrcepend;
          END IF;
        -- Para indocto = 5 temos de ver como está definido o CEP 
        ELSIF pr_inddocto = 5
          AND vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper, 03, '0') || pr_dsinfaux) THEN
          IF vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).idorgcep = 'C' THEN 
            -- Usar cep da central
            RETURN vr_tab_crapcop(3).nrcepend;
          ELSE
            -- Usar da Singular
            RETURN vr_tab_crapcop(pr_cdcooper).nrcepend;
          END IF;
        ELSE
          -- Outros Usar da Singular
          RETURN vr_tab_crapcop(pr_cdcooper).nrcepend;
        END IF;
      END;
                                       
      -- Rotina para popular tabela de trabalho - Projeto Ligeirinho
    PROCEDURE pc_popular_tbgen_batch_rel_wrk(pr_cdcooper    IN tbgen_batch_relatorio_wrk.cdcooper%TYPE
                                            ,pr_cdagenci    IN tbgen_batch_relatorio_wrk.cdagenci%TYPE
                                            ,pr_nrdconta    IN tbgen_batch_relatorio_wrk.nrdconta%TYPE
                                            ,pr_nrcpfcgc    IN tbgen_batch_relatorio_wrk.tpparcel%TYPE
                                            ,pr_nmrelatorio IN tbgen_batch_relatorio_wrk.dsrelatorio%TYPE
                                            ,pr_dtmvtolt    IN tbgen_batch_relatorio_wrk.dtmvtolt%TYPE
                                            ,pr_dschave     IN tbgen_batch_relatorio_wrk.dschave%TYPE DEFAULT NULL
                                            ,pr_dscritic    IN tbgen_batch_relatorio_wrk.dscritic%TYPE DEFAULT NULL
                                            ,pr_valor       IN tbgen_batch_relatorio_wrk.vltitulo%TYPE
                                            ,pr_seq_relato  IN tbgen_batch_relatorio_wrk.nrctremp%TYPE
                                            ,pr_dsxml       IN tbgen_batch_relatorio_wrk.dsxml%TYPE
                                            ,pr_des_erro    OUT VARCHAR2) IS
      BEGIN      

      IF pr_dscritic IS NULL THEN
        NULL;
      ELSIF instr(pr_dscritic, '>') = 0
        AND pr_nmrelatorio NOT IN ('TAG_AGREG', 'VENC_AGREG', 'TAG_AGREG_VENC') THEN
        --'3040_ABRTAG <Vc'
          vr_texto_xml := vr_texto_xml || pr_dscritic;
      ELSE
          vr_texto_xml := vr_texto_xml || pr_dscritic;
                                                 
        INSERT INTO tbgen_batch_relatorio_wrk
               (cdcooper
               ,cdprograma 
               ,dsrelatorio
               ,dtmvtolt
               ,cdagenci
               ,nrdconta
               ,dschave
               ,dsxml
               ,dtvencto
               ,nrctremp
               ,tpparcel
               ,vltitulo
               ,dscritic ) 
        VALUES
              (pr_cdcooper
              ,'CRPS573'
              ,pr_nmrelatorio
              ,pr_dtmvtolt
              ,pr_cdagenci
              ,pr_nrdconta
              ,pr_dschave 
              ,pr_dsxml
              ,SYSDATE
              ,pr_seq_relato
              ,pr_nrcpfcgc
              ,pr_valor
              ,vr_texto_xml --pr_dscritic
              );
       
          -- Limpa linha atualizada         
          vr_texto_xml := '';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
         --Montar mensagem de erro
         pr_des_erro:= 'Erro ao inserir na tabela tbgen_batch_relatorio_wrk. '||SQLERRM;
         -- Gerar log
         pc_controla_log_batch(1, 'Erro: '||pr_des_erro );
      END pc_popular_tbgen_batch_rel_wrk;
       
      -- Carregar a base de risco, separando os contratos em individuais e agregados 
      PROCEDURE pc_carrega_base_risco(pr_cdcooper crapris.cdcooper%type
                                     ,pr_cdagenci crapris.cdagenci%Type
                                     ,pr_dtrefere DATE
                                     ,pr_flbbndes VARCHAR2) IS
        
        -- Busca informacoes da central de risco
        CURSOR cr_crapris_geral(pr_cdcooper in crapris.cdcooper%type
                               ,pr_cdagenci in crapris.cdagenci%Type
                               ,pr_dtrefere DATE) IS
          SELECT ris.nrdconta,
                 ris.dtrefere,
                 ris.innivris,
                 ris.qtdiaatr,
                 ris.vldivida,
                 ris.vlsld59d,
                 ris.vlvec180,
                 ris.vlvec360,
                 ris.vlvec999,
                 ris.vldiv060,
                 ris.vldiv180,
                 ris.vldiv360,
                 ris.vldiv999,
                 ris.vlprjano,
                 ris.vlprjaan,
                 ris.inpessoa,
                 ris.nrcpfcgc,
                 ris.vlprjant,
                 ris.inddocto,
                 ris.cdmodali,
                 ris.nrctremp,
                 ris.nrseqctr,
                 ris.dtinictr,
                 ris.cdorigem,
                 ris.cdagenci,
                 ris.innivori,
                 ris.cdcooper,
                 ris.vlprjm60,
                 ris.dtdrisco,
                 ris.qtdriclq,
                 ris.nrdgrupo,
                 ris.vljura60,
                 ris.inindris,
                 ris.cdinfadi,
                 ris.nrctrnov,
                 ris.flgindiv,
                 ris.progress_recid,
                 ris.dsinfaux,
                 ris.dtprxpar,
                 ris.vlprxpar,
                 ris.qtparcel,
                 ris.dtvencop,
                 0 flcessao
            FROM crapris ris
                ,crapass ass
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto IN(1,3,4,5) -- Operações Ativas, Limite Não Utilizado, Cartão de Crédito e Garantias Prestadas
             AND ris.cdmodali <> 0301 -- Dsc Tit 
             AND ris.inpessoa IN (1,2)-- Deve ser CPF ou CNPJ
             AND ris.vldivida <> 0    -- Com divida
             AND nvl(ris.cdinfadi,' ') <> '0301' -- Remover saidas para Inddocto=5
             and ris.cdcooper = ass.cdcooper
             AND ass.cdagenci = Decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci) 
             and ass.nrdconta = ris.nrdconta             
            ORDER BY DECODE(ris.inddocto,3,1,0) desc,ris.nrcpfcgc, ris.nrctremp, ris.cdmodali; --> IndDocto 3 virão primeiro... 

        -- Busca informacoes da central de risco de Dsc Titulo
        CURSOR cr_crapris_dsctit(pr_cdcooper in crapris.cdcooper%type
                                ,pr_cdagenci in crapris.cdagenci%Type
                                ,pr_dtrefere DATE) IS
          SELECT ris.*
                ,ROW_NUMBER () OVER (PARTITION BY ris.nrdconta, ris.nrctremp ORDER BY ris.nrdconta, ris.nrctremp) nrseq
                ,COUNT(1)      OVER (PARTITION BY ris.nrdconta, ris.nrctremp ORDER BY ris.nrdconta, ris.nrctremp) qtreg
            FROM crapris ris
                ,crapass ass
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto = 1     -- documento 3020
             AND ris.cdmodali = 0301  -- Dsc Tit 
             AND ris.cdorigem IN(4,5) -- 4 - Desconto Titulos
             AND ris.inpessoa IN (1,2)        -- Deve ser CPF ou CNPJ             
             AND vldivida <> 0
             and ris.cdcooper = ass.cdcooper
             AND ass.cdagenci = Decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci) 
             and ass.nrdconta = ris.nrdconta;
        
        -- Busca informacoes da central de risco somnte BNDES
        CURSOR cr_crapris_BNDEs(pr_dtrefere DATE) IS
          SELECT ris.nrdconta,
                 ris.dtrefere,
                 ris.innivris,
                 ris.qtdiaatr,
                 ris.vldivida,
                 ris.vlsld59d,
                 ris.vlvec180,
                 ris.vlvec360,
                 ris.vlvec999,
                 ris.vldiv060,
                 ris.vldiv180,
                 ris.vldiv360,
                 ris.vldiv999,
                 ris.vlprjano,
                 ris.vlprjaan,
                 ris.inpessoa,
                 ris.nrcpfcgc,
                 ris.vlprjant,
                 ris.inddocto,
                 ris.cdmodali,
                 ris.nrctremp,
                 ris.nrseqctr,
                 ris.dtinictr,
                 ris.cdorigem,
                 ris.cdagenci,
                 ris.innivori,
                 ris.cdcooper,
                 ris.vlprjm60,
                 ris.dtdrisco,
                 ris.qtdriclq,
                 ris.nrdgrupo,
                 ris.vljura60,
                 ris.inindris,
                 ris.cdinfadi,
                 ris.nrctrnov,
                 ris.flindbndes flgindiv, /* BNDES possui flg de individualização específica */
                 ris.progress_recid,
                 ris.dsinfaux,
                 ris.dtprxpar,
                 ris.vlprxpar,
                 ris.qtparcel,
                 ris.dtvencop,
                 0 flcessao
            FROM crapris ris
           WHERE ris.dtrefere = pr_dtrefere
             AND ris.inddocto IN(1,5) -- Operações Ativas e Garantias Prestadas
             AND ris.cdorigem in(1,3,7) -- Somente Limite, Empréstimos/Financiamentos e Garantias prestadas Coop
             AND ris.inpessoa IN (1,2)-- Deve ser CPF ou CNPJ
             AND ris.vldivida <> 0    -- Com divida
             AND nvl(ris.cdinfadi,' ') <> '0301' -- Remover saidas para Inddocto=5      
             AND (  ris.dsinfaux = 'BNDES' 
                 OR (ris.cdorigem = 1 AND EXISTS(SELECT 1
                                                   FROM craplim li
                                                       ,craplrt lr
                                                  WHERE li.cdcooper = ris.cdcooper
                                                    AND li.nrdconta = ris.nrdconta
                                                    AND li.nrctrlim = ris.nrctremp
                                                    AND li.cdcooper = lr.cdcooper
                                                    AND li.cddlinha = lr.cddlinha
                                                    AND lr.dsdlinha LIKE '%BNDES%'))
                 OR (ris.cdorigem = 3 AND exists(select 1
                                                   from crapepr ep
                                                   join craplcr lc
                                                     on lc.cdcooper = ep.cdcooper
                                                    AND lc.cdlcremp = ep.cdlcremp                     
                                                  WHERE ep.cdcooper = ris.cdcooper
                                                    AND ep.nrdconta = ris.nrdconta
                                                    AND ep.nrctremp = ris.nrctremp
                                                    AND lc.dsorgrec IN ('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES')))
                 OR (ris.inddocto = 5 AND EXISTS(SELECT 1
                                               FROM tbrisco_provisgarant_prodt prd
                                                   ,tbrisco_provisgarant_movto mvt
                                              WHERE mvt.idproduto     = prd.idproduto
                                                AND mvt.idmovto_risco = ris.dsinfaux
                                                and prd.tparquivo     = 'Cartao_BNDES_BRDE'))
               )               
            ORDER BY DECODE(ris.inddocto,3,1,0) desc,ris.nrcpfcgc, ris.nrctremp, ris.cdmodali; --> IndDocto 3 virão primeiro... 
        
        --> temptable dos dados dados da tabela de risco
        TYPE typ_rec_ris IS RECORD
            (nrdconta   crapris.nrdconta%TYPE, 
             dtrefere   crapris.dtrefere%TYPE, 
             innivris   crapris.innivris%TYPE, 
             qtdiaatr   crapris.qtdiaatr%TYPE, 
             vldivida   crapris.vldivida%TYPE, 
             vlsld59d   crapris.vlsld59d%TYPE,
             vlvec180   crapris.vlvec180%TYPE, 
             vlvec360   crapris.vlvec360%TYPE, 
             vlvec999   crapris.vlvec999%TYPE, 
             vldiv060   crapris.vldiv060%TYPE, 
             vldiv180   crapris.vldiv180%TYPE, 
             vldiv360   crapris.vldiv360%TYPE, 
             vldiv999   crapris.vldiv999%TYPE, 
             vlprjano   crapris.vlprjano%TYPE, 
             vlprjaan   crapris.vlprjaan%TYPE, 
             inpessoa   crapris.inpessoa%TYPE, 
             nrcpfcgc   crapris.nrcpfcgc%TYPE, 
             vlprjant   crapris.vlprjant%TYPE, 
             inddocto   crapris.inddocto%TYPE, 
             cdmodali   crapris.cdmodali%TYPE, 
             nrctremp   crapris.nrctremp%TYPE, 
             nrseqctr   crapris.nrseqctr%TYPE, 
             dtinictr   crapris.dtinictr%TYPE, 
             cdorigem   crapris.cdorigem%TYPE, 
             cdagenci   crapris.cdagenci%TYPE, 
             innivori   crapris.innivori%TYPE, 
             cdcooper   crapris.cdcooper%TYPE, 
             vlprjm60   crapris.vlprjm60%TYPE, 
             dtdrisco   crapris.dtdrisco%TYPE, 
             qtdriclq   crapris.qtdriclq%TYPE, 
             nrdgrupo   crapris.nrdgrupo%TYPE, 
             vljura60   crapris.vljura60%TYPE, 
             inindris   crapris.inindris%TYPE, 
             cdinfadi   crapris.cdinfadi%TYPE, 
             nrctrnov   crapris.nrctrnov%TYPE, 
             flgindiv   crapris.flgindiv%TYPE, 
             progress_recid crapris.progress_recid%TYPE, 
             dsinfaux   crapris.dsinfaux%TYPE, 
             dtprxpar   crapris.dtprxpar%TYPE, 
             vlprxpar   crapris.vlprxpar%TYPE, 
             qtparcel   crapris.qtparcel%TYPE,              
             dtvencop   crapris.dtvencop%TYPE,
             flcessao   INTEGER);
        
        -- Definicao do tipo da tabela de central de risco
        TYPE typ_tab_ris IS
          TABLE OF typ_rec_ris ---> crapris%ROWTYPE
            INDEX BY VARCHAR2(27); -- Cooper(3) || CPF/CNPJ(14) || Sequencial (10)
        -- Vetor para armazenar os dados da central de risco
        vr_tab_ris typ_tab_ris;

        -- Variavel para o indice
        vr_vlcont_ris PLS_INTEGER := 0;
        vr_indice_ris VARCHAR2(27);      
        
        -- Vetor para armazenar os dados da central de risco (temporario)
        vr_tab_crapris_temp typ_tab_ris;

        -- Variavel para o indice
        vr_indice_temp VARCHAR2(27);
        
        -- Vetor para armazenar os dados da central de risco para uma tabela work temporaria
        vr_tab_individ_copy typ_tab_individ;

        -- Variavel para o indice
        vr_vlcont_copy PLS_INTEGER := 0;
        vr_indice_copy VARCHAR2(37);
        
        -- Auxiliares
        vr_cpf      VARCHAR2(11);
        vr_cddfaixa PLS_INTEGER;
        vr_cddesemp PLS_INTEGER;
        
        vr_dtprxpar crapris.dtprxpar%TYPE;
        vr_vlprxpar crapris.vlprxpar%TYPE;
        vr_qtparcel crapris.qtparcel%TYPE;
        vr_dtvencop crapris.dtvencop%TYPE;
        vr_qtdiaatr crapris.qtdiaatr%TYPE;
             
      BEGIN
      
        -- Execução só de recursos BNDEs
        IF pr_flbbndes = 'S' THEN 
          
          -- Efetua loop sobre os dados da central de risco exclusivo BNDEs
          FOR rw_crapris IN cr_crapris_BNDEs(pr_dtrefere) LOOP
            
            -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
            IF rw_crapris.cdcooper IN (1,16,9) THEN
              -- Se for uma conta migrada nao deve processar
              IF fn_eh_conta_migracao_573(pr_cdcooper => rw_crapris.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta
                                         ,pr_dtrefere => rw_crapris.dtrefere) THEN
                continue; -- Volta para o inicio do for
              END IF;
            END IF;
            
            -- Incrementar contador
            vr_vlcont_ris := vr_vlcont_ris + 1;
            vr_indice_ris := lpad(rw_crapris.nrcpfcgc,14,'0')||lpad(rw_crapris.cdcooper,3,'0')||lpad(vr_vlcont_ris,10,'0');

            -- Adicionar a tabela
            vr_tab_ris(vr_indice_ris) := rw_crapris;  
     
          IF rw_crapris.inddocto = 1
          AND rw_crapris.cdmodali IN (0299, 0499) THEN
            -- Contratos de Emprestimo/Financiamento
            
              rw_cessao := NULL;
              --> Verificar se é emprestimo de cessao de credito
              OPEN cr_cessao (pr_cdcooper => rw_crapris.cdcooper,
                              pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_cessao INTO rw_cessao;
              CLOSE cr_cessao;
              
              vr_tab_ris(vr_indice_ris).flcessao := rw_cessao.flcessao;
              
            END IF;
            
          END LOOP; -- Fim do loop sobre a tabela crapris
        
        ELSE
          
          -- Efetua loop sobre os dados da central de risco (Exceto 301 - Dsc Titulos)
          FOR rw_crapris IN cr_crapris_geral(pr_cdcooper,pr_cdagenci,pr_dtrefere) LOOP

            -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
            IF rw_crapris.cdcooper IN (1,16,9) THEN
              -- Se for uma conta migrada nao deve processar
              IF fn_eh_conta_migracao_573(pr_cdcooper => rw_crapris.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta
                                         ,pr_dtrefere => rw_crapris.dtrefere) THEN
                continue; -- Volta para o inicio do for
              END IF;
            END IF;
            
            -- Incrementar contador
            vr_vlcont_ris := vr_vlcont_ris + 1;
            vr_indice_ris := lpad(rw_crapris.nrcpfcgc,14,'0')||lpad(rw_crapris.cdcooper,3,'0')||lpad(vr_vlcont_ris,10,'0');

            -- Adicionar a tabela
            vr_tab_ris(vr_indice_ris) := rw_crapris;  
     
          IF rw_crapris.inddocto = 1
          AND rw_crapris.cdmodali IN (0299, 0499) THEN
            -- Contratos de Emprestimo/Financiamento
            
              rw_cessao := NULL;
              --> Verificar se é emprestimo de cessao de credito
              OPEN cr_cessao (pr_cdcooper => rw_crapris.cdcooper,
                              pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_cessao INTO rw_cessao;
              CLOSE cr_cessao;
              
              vr_tab_ris(vr_indice_ris).flcessao := rw_cessao.flcessao;
              
            END IF;
            
          END LOOP; -- Fim do loop sobre a tabela crapris
          
          
          -- Efetua loop sobre os dados da central de risco de Dsc Titulos
          FOR rw_crapris_dsctit IN cr_crapris_dsctit(pr_cdcooper,pr_cdagenci,pr_dtrefere) LOOP

            -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred
            IF rw_crapris_dsctit.cdcooper IN (1,16,9) THEN
              -- Se for uma conta migrada nao deve processar
              IF fn_eh_conta_migracao_573(pr_cdcooper => rw_crapris_dsctit.cdcooper
                                         ,pr_nrdconta => rw_crapris_dsctit.nrdconta
                                         ,pr_dtrefere => rw_crapris_dsctit.dtrefere) THEN
                continue; -- Volta para o inicio do for
              END IF;
            END IF;
            -- Acumula o valor da divida
            vr_vldivida_0301 := nvl(vr_vldivida_0301,0) + rw_crapris_dsctit.vldivida;

            -- No primeiro registro, inicializamos as variaveis
            IF rw_crapris_dsctit.nrseq = 1 THEN
              vr_dtprxpar := NULL;
              vr_vlprxpar := 0;
              vr_qtparcel := 0;
              vr_dtvencop := rw_crapris_dsctit.dtvencop;
              vr_qtdiaatr := 0;
            END IF;
            -- Sempre acumularemos a maior quantidade de parcelas 
            vr_qtparcel := greatest(vr_qtparcel,rw_crapris_dsctit.qtparcel);
            -- Se o próximo pagamento armazenado não estiver no mesmo mês do registro atual
            IF trunc(vr_dtprxpar,'mm') != trunc(rw_crapris_dsctit.dtprxpar,'mm') THEN
              -- Iremos zerar a quantidade acumulada do próximo pagamento
              vr_vlprxpar := 0;
            END IF;
            -- O próximo pagamento deve sempre será o mais próximo
            vr_dtprxpar := least(vr_dtprxpar,rw_crapris_dsctit.dtprxpar);
            -- Se o registro atual possuir o próximo pagamento no mesmo
            -- mes do pagamento mais próximo
            IF trunc(vr_dtprxpar,'mm') = trunc(rw_crapris_dsctit.dtprxpar,'mm') THEN
              -- Acumularemos o valor a vencer deste registro, pois ele vence no 
              -- mesmo mÊs da próxima parcela mais próxima.
              vr_vlprxpar := vr_vlprxpar + rw_crapris_dsctit.vlprxpar;
            END IF;          
            --Guardar a maior data de vencimento
            vr_dtvencop := GREATEST(rw_crapris_dsctit.dtvencop,vr_dtvencop);
            vr_qtdiaatr := GREATEST(rw_crapris_dsctit.qtdiaatr,vr_qtdiaatr);
            
            -- Se for o ultimo registro da conta / contrato de limite do bordero, grava os valores
            IF rw_crapris_dsctit.nrseq = rw_crapris_dsctit.qtreg THEN
              -- Incrementar contador
              vr_vlcont_ris := vr_vlcont_ris + 1;
              vr_indice_ris := lpad(rw_crapris_dsctit.nrcpfcgc,14,'0')||lpad(rw_crapris_dsctit.cdcooper,3,'0')||lpad(vr_vlcont_ris,10,'0');

              -- Criar novo registro
              vr_tab_ris(vr_indice_ris).nrdconta := rw_crapris_dsctit.nrdconta;
              vr_tab_ris(vr_indice_ris).dtrefere := rw_crapris_dsctit.dtrefere;
              vr_tab_ris(vr_indice_ris).innivris := rw_crapris_dsctit.innivris;
              vr_tab_ris(vr_indice_ris).qtdiaatr := vr_qtdiaatr;
              vr_tab_ris(vr_indice_ris).vldivida := vr_vldivida_0301;
              vr_tab_ris(vr_indice_ris).vlvec180 := rw_crapris_dsctit.vlvec180;
              vr_tab_ris(vr_indice_ris).vlvec360 := rw_crapris_dsctit.vlvec360;
              vr_tab_ris(vr_indice_ris).vlvec999 := rw_crapris_dsctit.vlvec999;
              vr_tab_ris(vr_indice_ris).vldiv060 := rw_crapris_dsctit.vldiv060;
              vr_tab_ris(vr_indice_ris).vldiv180 := rw_crapris_dsctit.vldiv180;
              vr_tab_ris(vr_indice_ris).vldiv360 := rw_crapris_dsctit.vldiv360;
              vr_tab_ris(vr_indice_ris).vldiv999 := rw_crapris_dsctit.vldiv999;
              vr_tab_ris(vr_indice_ris).vlprjano := rw_crapris_dsctit.vlprjano;
              vr_tab_ris(vr_indice_ris).vlprjaan := rw_crapris_dsctit.vlprjaan;
              vr_tab_ris(vr_indice_ris).inpessoa := rw_crapris_dsctit.inpessoa;
              vr_tab_ris(vr_indice_ris).nrcpfcgc := rw_crapris_dsctit.nrcpfcgc;
              vr_tab_ris(vr_indice_ris).vlprjant := rw_crapris_dsctit.vlprjant;
              vr_tab_ris(vr_indice_ris).inddocto := rw_crapris_dsctit.inddocto;
              vr_tab_ris(vr_indice_ris).cdmodali := rw_crapris_dsctit.cdmodali;
              vr_tab_ris(vr_indice_ris).nrctremp := rw_crapris_dsctit.nrctremp;
              vr_tab_ris(vr_indice_ris).nrseqctr := rw_crapris_dsctit.nrseqctr;
              vr_tab_ris(vr_indice_ris).dtinictr := rw_crapris_dsctit.dtinictr;
              vr_tab_ris(vr_indice_ris).cdorigem := 4; -- Desconto Titulos 
              vr_tab_ris(vr_indice_ris).cdagenci := rw_crapris_dsctit.cdagenci;
              vr_tab_ris(vr_indice_ris).innivori := rw_crapris_dsctit.innivori;
              vr_tab_ris(vr_indice_ris).cdcooper := rw_crapris_dsctit.cdcooper;
              vr_tab_ris(vr_indice_ris).vlprjm60 := rw_crapris_dsctit.vlprjm60;
              vr_tab_ris(vr_indice_ris).dtdrisco := rw_crapris_dsctit.dtdrisco;
              vr_tab_ris(vr_indice_ris).qtdriclq := rw_crapris_dsctit.qtdriclq;
              vr_tab_ris(vr_indice_ris).nrdgrupo := rw_crapris_dsctit.nrdgrupo;
              vr_tab_ris(vr_indice_ris).vljura60 := rw_crapris_dsctit.vljura60;
              vr_tab_ris(vr_indice_ris).inindris := rw_crapris_dsctit.inindris;
              vr_tab_ris(vr_indice_ris).cdinfadi := rw_crapris_dsctit.cdinfadi;
              vr_tab_ris(vr_indice_ris).nrctrnov := rw_crapris_dsctit.nrctrnov;
              vr_tab_ris(vr_indice_ris).flgindiv := rw_crapris_dsctit.flgindiv;
              vr_tab_ris(vr_indice_ris).dsinfaux := rw_crapris_dsctit.dsinfaux;
              vr_tab_ris(vr_indice_ris).dtprxpar := rw_crapris_dsctit.dtprxpar;
              vr_tab_ris(vr_indice_ris).vlprxpar := rw_crapris_dsctit.vlprxpar;
              vr_tab_ris(vr_indice_ris).qtparcel := rw_crapris_dsctit.qtparcel;
              vr_tab_ris(vr_indice_ris).dtvencop := vr_dtvencop;
              -- Zera a variavel acumuladora
              vr_vldivida_0301 := 0;
            END IF;
          END LOOP; -- Fim do loop sobre a tabela crapris
        END IF;
        
        --Acessar primeiro registro da tabela de memoria
        vr_indice_ris := vr_tab_ris.FIRST;
        -- Varre a tabela de memoria vr_tab_crapris
        WHILE vr_indice_ris IS NOT NULL LOOP
          -- Conta o total de registros
          vr_qtregarq := vr_qtregarq + 1;

          -- Busca o CPF e CNPJ
          IF vr_tab_ris(vr_indice_ris).inpessoa = 1 THEN
            vr_cpf := substr(vr_tab_ris(vr_indice_ris).nrcpfcgc,1,11);
            vr_nrdocnpj := 0;
          ELSE
            vr_nrdocnpj := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0');
            vr_cpf      := SUBSTR(lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0'),1,8);
          END IF;
          -- Copia o registro da tabela temporaria CRAPRIS para uma tabela TEMP
          vr_tab_crapris_temp(vr_indice_ris) := vr_tab_ris(vr_indice_ris);
          -- monta o indice para a tabela temporaria work
          vr_vlcont_copy := vr_vlcont_copy + 1;
          vr_indice_copy := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0')
                         || lpad(vr_tab_ris(vr_indice_ris).cdcooper,3,'0')
                         || lpad(vr_tab_ris(vr_indice_ris).nrctremp,'0',10) 
                         || lpad(vr_vlcont_copy,10,'0');
          -- atualiza a tabela temporaria WORK
          vr_tab_individ_copy(vr_indice_copy).cdcooper := vr_tab_ris(vr_indice_ris).cdcooper;
          vr_tab_individ_copy(vr_indice_copy).nrdconta := vr_tab_ris(vr_indice_ris).nrdconta;
          vr_tab_individ_copy(vr_indice_copy).innivris := vr_tab_ris(vr_indice_ris).innivris;
          vr_tab_individ_copy(vr_indice_copy).inpessoa := vr_tab_ris(vr_indice_ris).inpessoa;
          vr_tab_individ_copy(vr_indice_copy).cdorigem := vr_tab_ris(vr_indice_ris).cdorigem;
          vr_tab_individ_copy(vr_indice_copy).cdmodali := vr_tab_ris(vr_indice_ris).cdmodali;
          vr_tab_individ_copy(vr_indice_copy).nrctremp := vr_tab_ris(vr_indice_ris).nrctremp;
          vr_tab_individ_copy(vr_indice_copy).nrseqctr := vr_tab_ris(vr_indice_ris).nrseqctr;
          vr_tab_individ_copy(vr_indice_copy).vldivida := vr_tab_ris(vr_indice_ris).vldivida;
          vr_tab_individ_copy(vr_indice_copy).vlsld59d := vr_tab_ris(vr_indice_ris).vlsld59d;
          vr_tab_individ_copy(vr_indice_copy).dtinictr := vr_tab_ris(vr_indice_ris).dtinictr;
          vr_tab_individ_copy(vr_indice_copy).nrcpfcgc := vr_cpf;
          vr_tab_individ_copy(vr_indice_copy).nrdocnpj := vr_nrdocnpj;
          vr_tab_individ_copy(vr_indice_copy).qtdiaatr := vr_tab_ris(vr_indice_ris).qtdiaatr;
          vr_tab_individ_copy(vr_indice_copy).qtdriclq := vr_tab_ris(vr_indice_ris).qtdriclq;
          vr_tab_individ_copy(vr_indice_copy).vljura60 := vr_tab_ris(vr_indice_ris).vljura60;
          vr_tab_individ_copy(vr_indice_copy).inddocto := vr_tab_ris(vr_indice_ris).inddocto;
          vr_tab_individ_copy(vr_indice_copy).cdinfadi := vr_tab_ris(vr_indice_ris).cdinfadi;
          vr_tab_individ_copy(vr_indice_copy).dsinfaux := vr_tab_ris(vr_indice_ris).dsinfaux;
          vr_tab_individ_copy(vr_indice_copy).dtprxpar := vr_tab_ris(vr_indice_ris).dtprxpar;
          vr_tab_individ_copy(vr_indice_copy).vlprxpar := vr_tab_ris(vr_indice_ris).vlprxpar;
          vr_tab_individ_copy(vr_indice_copy).qtparcel := vr_tab_ris(vr_indice_ris).qtparcel;
          vr_tab_individ_copy(vr_indice_copy).nrdgrupo := vr_tab_ris(vr_indice_ris).nrdgrupo;
          vr_tab_individ_copy(vr_indice_copy).dtvencop := vr_tab_ris(vr_indice_ris).dtvencop;
          vr_tab_individ_copy(vr_indice_copy).flcessao := vr_tab_ris(vr_indice_ris).flcessao;
          
          -- Verifica se eh o ultimo registro ou se o proximo registro possui o CNPJ / CPF do registro atual
          IF vr_tab_ris.next(vr_indice_ris) IS NULL OR
             vr_tab_ris(vr_indice_ris).nrcpfcgc <> vr_tab_ris(vr_tab_ris.next(vr_indice_ris)).nrcpfcgc THEN
             -- Acumula Total de Clientes para informar no Cabecalho 
             vr_totalcli := vr_totalcli + 1;
            -- Se nao for uma operacao individualizada do BC
            IF vr_tab_ris(vr_indice_ris).flgindiv = 0 THEN
              vr_cdnatuop := '01';
              vr_indice_temp := lpad(vr_tab_ris(vr_indice_ris).nrcpfcgc,14,'0')||lpad(vr_tab_ris(vr_indice_ris).cdcooper,3,'0')||'000000';

              vr_indice_temp := vr_tab_crapris_temp.next(vr_indice_temp);
              WHILE vr_indice_temp IS NOT NULL LOOP
                -- Sair do loop quando o nrcpfcgc for diferente do que esta sendo processado
                IF vr_tab_crapris_temp(vr_indice_temp).nrcpfcgc <> vr_tab_ris(vr_indice_ris).nrcpfcgc THEN
                  EXIT;
                END IF;
                vr_cdnatuop := '01';
                -- Tratamento Natureza operacao CONTA MIGRADA Acredicoop 
                -- 0299= Emprst, 0499=Financ 
                -- 3 - Emprestimos/Financiamentos 
                IF  vr_tab_crapris_temp(vr_indice_temp).cdcooper = 1
                AND vr_tab_crapris_temp(vr_indice_temp).cdmodali IN (0299, 0499)
                AND vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3 THEN
                  -- Abre o cursor de contas transferidas
                  OPEN cr_craptco_b(vr_tab_crapris_temp(vr_indice_temp).cdcooper,vr_tab_crapris_temp(vr_indice_temp).nrdconta);
                  FETCH cr_craptco_b INTO rw_craptco_b;
                  --Conta transferida e o empréstimo não é BNDES
                  IF cr_craptco_b%FOUND AND vr_tab_crapris_temp(vr_indice_temp).dsinfaux <> 'BNDES' THEN 
                    -- Verifica se possui emprestimo para o contrato e conta
                    vr_ind_epr := lpad(vr_tab_crapris_temp(vr_indice_temp).cdcooper,03,'0')
                               || lpad(vr_tab_crapris_temp(vr_indice_temp).nrdconta,10,'0')
                               || lpad(vr_tab_crapris_temp(vr_indice_temp).nrctremp,10,'0');
                    -- Se o empréstimo for inferior a 31/12/2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2013','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                    END IF;
                  END IF;
                  CLOSE cr_craptco_b;
                END IF;
                -- Tratamento Natureza operacao CONTA MIGRADA Altovale
                -- 0299 = Emprst, 0499 = Financ 
                -- 3 - Emprestimos/Financiamentos 
                IF  vr_tab_crapris_temp(vr_indice_temp).cdcooper = 16
                AND vr_tab_crapris_temp(vr_indice_temp).cdmodali IN (299, 499)
                AND vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3 THEN
                  -- Verifica se a conta eh de transferencia entre cooperativas
                  OPEN cr_craptco(vr_tab_crapris_temp(vr_indice_temp).cdcooper,vr_tab_crapris_temp(vr_indice_temp).nrdconta);
                  FETCH cr_craptco INTO rw_craptco;
                  --Conta transferida e o empréstimo não é BNDES
                  IF cr_craptco%FOUND AND vr_tab_crapris_temp(vr_indice_temp).dsinfaux <> 'BNDES' THEN 
                    -- Verifica se possui emprestimo para o contrato e conta
                    vr_ind_epr := lpad(vr_tab_crapris_temp(vr_indice_temp).cdcooper,03,'0')
                               || lpad(vr_tab_crapris_temp(vr_indice_temp).nrdconta,10,'0')
                               || lpad(vr_tab_crapris_temp(vr_indice_temp).nrctremp,10,'0');
                    -- Se o empréstimo for inferior a 31/12/2013
                    IF vr_tab_crapepr(vr_ind_epr).dtmvtolt < to_date('31/12/2012','dd/mm/yyyy') THEN
                      vr_cdnatuop := '02';
                    END IF;
                  END IF;
                  CLOSE cr_craptco;
                END IF;      
                
                --> Verificar se é cessao de credito
                IF vr_tab_crapris_temp(vr_indice_temp).flcessao = 1 THEN
                  vr_cdnatuop := '02';
                END IF;                        
                
                -- Verificar se é Garantia Prestada
                IF vr_tab_crapris_temp(vr_indice_temp).inddocto = 5 THEN
                  -- Buscar a natureza no cadastro do movimento
                  IF vr_tab_mvto_garant_prest.exists(lpad(vr_tab_crapris_temp(vr_indice_temp).cdcooper,03,'0')||vr_tab_crapris_temp(vr_indice_temp).dsinfaux) THEN 
                    vr_cdnatuop := vr_tab_mvto_garant_prest(lpad(vr_tab_crapris_temp(vr_indice_temp).cdcooper,03,'0')||vr_tab_crapris_temp(vr_indice_temp).dsinfaux).dsnature;
                  END IF;
                END IF;    
                
                -- Encontrar a faixa de valor conforme tabela
                --   Anexo 14: Faixa de valor da operação - FaixaVlr	
                --   Domínio   Descrição
                --         1   Acima de 0 a R$ 99,99
                --         2   R$ 100,00 a R$ 499,99
                --         3   R$ 500,00 a R$ 999,99
                --         4   R$ 1.000,00 a R$ 4.999,99
                --         5   acima de R$4999,99
                IF vr_tab_crapris_temp(vr_indice_temp).cdmodali = 0101 THEN
                  vr_vldivida_aux := vr_tab_crapris_temp(vr_indice_temp).vlsld59d;
                ELSE

                -- Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos (cdorigem = 3)
                -- estejam em Prejuízo (innivris = 10)
                IF  vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3 
                AND vr_tab_crapris_temp(vr_indice_temp).innivris = 10 THEN
                  vr_vljuro60 := nvl((PREJ0001.fn_juros60_emprej(pr_cdcooper => pr_cdcooper
                                                                ,pr_nrdconta => vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                                ,pr_nrctremp => vr_tab_crapris_temp(vr_indice_temp).nrctremp)),0);
                  vr_vldivida_aux := vr_tab_crapris_temp(vr_indice_temp).vldivida;

                  -- Se o valor da divida for maior que juros60
                  IF vr_vldivida_aux > vr_vljuro60 THEN
                    vr_vldivida_aux := vr_vldivida_aux - vr_vljuro60;
                  END IF;
                  ELSE
                    vr_vldivida_aux := vr_tab_crapris_temp(vr_indice_temp).vldivida - vr_tab_crapris_temp(vr_indice_temp).vljura60;
                  END IF;
                END IF;
                
							
                IF (vr_vldivida_aux) < 100 THEN
                  vr_cddfaixa := 1;
                ELSIF (vr_vldivida_aux) < 500 THEN
                  vr_cddfaixa := 2;
                ELSIF (vr_vldivida_aux) < 1000 THEN
                  vr_cddfaixa := 3;
                ELSIF (vr_vldivida_aux) < 5000 THEN
                  vr_cddfaixa := 4;  
                ELSE
                  vr_cddfaixa := 5;  
                END IF;
                vr_vtomaior := 0;
                vr_cddesemp := 1;

                vr_nrdaconta := vr_tab_crapris_temp(vr_indice_temp).nrdconta; 

                -- Buscar o desempenho da operacao a partir do crapvri.cdvencto 
                OPEN cr_crapvri_max(pr_cdcooper => vr_tab_crapris_temp(vr_indice_temp).cdcooper
                                   ,pr_nrdconta => vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                   ,pr_dtrefere => pr_dtrefere
                                   ,pr_innivris => vr_tab_crapris_temp(vr_indice_temp).innivris
                                   ,pr_cdmodali => vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                   ,pr_nrctremp => vr_tab_crapris_temp(vr_indice_temp).nrctremp);
                FETCH cr_crapvri_max INTO rw_crapvri;
                IF cr_crapvri_max%FOUND THEN
                  IF rw_crapvri.cdvencto    >= 310  THEN
                    vr_cddesemp := 06;
                  ELSIF rw_crapvri.cdvencto >= 240  THEN
                    vr_cddesemp := 05;
                  ELSIF rw_crapvri.cdvencto >= 230  THEN
                    vr_cddesemp := 04;
                  ELSIF rw_crapvri.cdvencto >= 220  THEN
                    vr_cddesemp := 03;
                  ELSIF rw_crapvri.cdvencto >= 210  THEN
                    vr_cddesemp := 02;
                  ELSIF rw_crapvri.cdvencto >= 205  THEN
                    vr_cddesemp := 01;
                  ELSE
                    IF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr = 0 OR vr_tab_crapris_temp(vr_indice_temp).cdmodali = 1901  THEN
                      vr_cddesemp := 01;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 30  THEN
                      vr_cddesemp := 02;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 60  THEN
                      vr_cddesemp := 03;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr <= 90  THEN
                      vr_cddesemp := 04;
                    ELSIF vr_tab_crapris_temp(vr_indice_temp).qtdiaatr > 90  THEN
                      vr_cddesemp := 05;
                    END IF;
                    -- Prejuizo 
                    IF vr_tab_crapris_temp(vr_indice_temp).innivris = 10  THEN
                      vr_cddesemp := 06;
                    END IF;
                  END IF;
                END IF;
                CLOSE cr_crapvri_max;
                                    
                -- Busca a modalidade com base nos emprestimos
                vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                        ,vr_tab_crapris_temp(vr_indice_temp).cdcooper
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrctremp
                                                        ,vr_tab_crapris_temp(vr_indice_temp).inpessoa
                                                        ,vr_tab_crapris_temp(vr_indice_temp).cdorigem
                                                        ,vr_tab_crapris_temp(vr_indice_temp).dsinfaux);
                -- Busca a origem recurso
                vr_dsorgrec := fn_busca_dsorgrec(vr_tab_crapris_temp(vr_indice_temp).cdcooper
                                                ,vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                ,vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                ,vr_tab_crapris_temp(vr_indice_temp).nrctremp
                                                ,vr_tab_crapris_temp(vr_indice_temp).cdorigem
                                                ,vr_tab_crapris_temp(vr_indice_temp).dsinfaux);                                                                      
                                    
                -- Monta a chave do indice da tabela vr_tab_agreg
                vr_indice_agreg := lpad(vr_cdmodali,5,'0')||
                                   lpad(vr_tab_crapris_temp(vr_indice_temp).innivris,5,'0')||
                                   vr_cddfaixa||
                                   vr_tab_crapris_temp(vr_indice_temp).inpessoa||
                                   lpad(vr_cdnatuop,4,'0')||
                                   lpad(vr_cddesemp,2,'0');
                -- Verifica se o registro nao existe na tabela temporaria, para poder criar
                IF NOT vr_tab_agreg.EXISTS(vr_indice_agreg) THEN
                  vr_tab_agreg(vr_indice_agreg).cdcooper := vr_tab_crapris_temp(vr_indice_temp).cdcooper;
                  vr_tab_agreg(vr_indice_agreg).nrdconta := vr_tab_crapris_temp(vr_indice_temp).nrdconta;
                  vr_tab_agreg(vr_indice_agreg).innivris := vr_tab_crapris_temp(vr_indice_temp).innivris;
                  vr_tab_agreg(vr_indice_agreg).inpessoa := vr_tab_crapris_temp(vr_indice_temp).inpessoa;
                  vr_tab_agreg(vr_indice_agreg).cdorigem := vr_tab_crapris_temp(vr_indice_temp).cdorigem;
                  vr_tab_agreg(vr_indice_agreg).cdmodali := vr_cdmodali;
                  vr_tab_agreg(vr_indice_agreg).nrctremp := vr_tab_crapris_temp(vr_indice_temp).nrctremp;
                  vr_tab_agreg(vr_indice_agreg).nrseqctr := vr_tab_crapris_temp(vr_indice_temp).nrseqctr;
                  vr_tab_agreg(vr_indice_agreg).vldivida := vr_tab_crapris_temp(vr_indice_temp).vldivida;
                  vr_tab_agreg(vr_indice_agreg).dtinictr := vr_tab_crapris_temp(vr_indice_temp).dtinictr;
                  vr_tab_agreg(vr_indice_agreg).vljura60 := vr_tab_crapris_temp(vr_indice_temp).vljura60;
                  vr_tab_agreg(vr_indice_agreg).nrcpfcgc := vr_cpf;
                  vr_tab_agreg(vr_indice_agreg).nrdocnpj := vr_nrdocnpj;
                  vr_tab_agreg(vr_indice_agreg).cddfaixa := vr_cddfaixa;
                  vr_tab_agreg(vr_indice_agreg).qtoperac := 1;
                  vr_tab_agreg(vr_indice_agreg).qtcooper := 1;
                  vr_tab_agreg(vr_indice_agreg).cddesemp := vr_cddesemp;
                  vr_tab_agreg(vr_indice_agreg).cdnatuop := vr_cdnatuop;
                  vr_tab_agreg(vr_indice_agreg).inddocto := vr_tab_crapris_temp(vr_indice_temp).inddocto;
                  vr_tab_agreg(vr_indice_agreg).dsinfaux := vr_tab_crapris_temp(vr_indice_temp).dsinfaux;
                ELSE
                  -- Atualizar somente se o cpf for diferente
                  IF vr_tab_agreg(vr_indice_agreg).nrcpfcgc <> vr_cpf THEN
                    vr_tab_agreg(vr_indice_agreg).qtcooper := vr_tab_agreg(vr_indice_agreg).qtcooper + 1;
                  END IF;
                  vr_tab_agreg(vr_indice_agreg).vldivida := vr_tab_agreg(vr_indice_agreg).vldivida + vr_tab_crapris_temp(vr_indice_temp).vldivida;
                  vr_tab_agreg(vr_indice_agreg).vljura60 := vr_tab_agreg(vr_indice_agreg).vljura60 + vr_tab_crapris_temp(vr_indice_temp).vljura60;
                  vr_tab_agreg(vr_indice_agreg).qtoperac := vr_tab_agreg(vr_indice_agreg).qtoperac + 1;
                END IF;
                -- efetua loop sobre os vencimentos do risco
                FOR rw_crapvri_venct IN cr_crapvri_venct(vr_tab_crapris_temp(vr_indice_temp).cdcooper
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                        ,pr_dtrefere
                                                        ,vr_tab_crapris_temp(vr_indice_temp).cdmodali
                                                        ,vr_tab_crapris_temp(vr_indice_temp).nrctremp) LOOP
                  -- Monta o indice para a pesquisa
                  vr_indice_venc_agreg := lpad(vr_cdmodali,5,'0')
                                       || lpad(vr_tab_crapris_temp(vr_indice_temp).innivris,5,'0')
                                       || vr_cddfaixa
                                       || vr_tab_crapris_temp(vr_indice_temp).inpessoa
                                       || lpad(vr_cdnatuop,4,'0')
                                       || lpad(vr_cddesemp,2,'0')
                                       || lpad(rw_crapvri_venct.cdvencto,5,'0');

                  vr_vldivida_jur60 := rw_crapvri_venct.vldivida;

                  -- Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos (cdorigem = 3)
                  -- estejam em Prejuízo (innivris = 10)
                  IF  vr_tab_crapris_temp(vr_indice_temp).cdorigem = 3
                  AND vr_tab_crapris_temp(vr_indice_temp).innivris = 10 THEN
                    vr_vljuro60 := nvl((PREJ0001.fn_juros60_emprej(pr_cdcooper => vr_tab_crapris_temp(vr_indice_temp).cdcooper
                                                                  ,pr_nrdconta => vr_tab_crapris_temp(vr_indice_temp).nrdconta
                                                                  ,pr_nrctremp => vr_tab_crapris_temp(vr_indice_temp).nrctremp)),0);
                    -- Se o valor da divida for maior que juros60
                    IF vr_vldivida_jur60 > vr_vljuro60 THEN
                      vr_vldivida_jur60 := vr_vldivida_jur60 - vr_vljuro60;
                    END IF;
                  END IF;

                  -- Verifica se nao existe o registro. Se nao existir ira criar
                  IF NOT vr_tab_venc_agreg.EXISTS(vr_indice_venc_agreg) THEN
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali := vr_cdmodali;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).innivris := vr_tab_crapris_temp(vr_indice_temp).innivris;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa := vr_cddfaixa;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa := vr_tab_crapris_temp(vr_indice_temp).inpessoa;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto := rw_crapvri_venct.cdvencto;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida := vr_vldivida_jur60;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp := vr_cddesemp;
                    vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop := vr_cdnatuop;
                  ELSE
                    vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida := vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida + vr_vldivida_jur60;
                  END IF;
                END LOOP;
                --Encontrar o proximo registro da tabela de memoria
                vr_indice_temp := vr_tab_crapris_temp.next(vr_indice_temp);
              END LOOP; -- Loop sobre a vr_tab_crapris_temp
          ELSE  -- Tratamento para INDIVIDUALIZADOS
              --Acessar primeiro registro da tabela de memoria
              vr_indice_copy := vr_tab_individ_copy.FIRST;
              -- Varre a tabela de memoria vr_tab_crapris
              WHILE vr_indice_copy IS NOT NULL LOOP
                -- Recriar o indice
                vr_vlcont_copy := vr_vlcont_copy + 1;
                vr_idx_individ := lpad(vr_tab_individ_copy(vr_indice_copy).nrcpfcgc,14,'0')
                               || lpad(vr_tab_individ_copy(vr_indice_copy).cdcooper,03,'0')
                               || lpad(vr_tab_individ_copy(vr_indice_copy).nrctremp,10,'0') 
                               || lpad(vr_vlcont_copy,10,'0');
                -- Copiar o registro novo 
                vr_tab_individ(vr_idx_individ) := vr_tab_individ_copy(vr_indice_copy);
                -- Vai para o proximo registro
                vr_indice_copy := vr_tab_individ_copy.next(vr_indice_copy);
              END LOOP;
            END IF; -- Final do flgindiv = 0
            --limpeza das tabelas temporarias
            vr_tab_individ_copy.delete;
            vr_tab_crapris_temp.delete;
          END IF; -- Final do if de verificacao de CNPJ / CPF diferente do proximo
          --Encontrar o proximo registro da tabela de memoria
          vr_indice_ris := vr_tab_ris.next(vr_indice_ris);
        END LOOP; -- fim do loop sobre a tabela de memoria vr_tab_crapris

        If vr_tpexecucao = 2 Then
          -- Procedimento para popular o total de Clientes da CRAPRIS na tbgen
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => 99999,
                                         pr_nrcpfcgc      => 8888888888,
                                         pr_nmrelatorio   => '3040_TOTCLI',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dscritic      => '>',
                                         pr_Valor         => vr_totalcli,
                                         pr_seq_relato    => vr_totalcli, 
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
            vr_dscritic:= '3040_TOTCLI - '||vr_dscritic;
            raise vr_exc_saida;
          end if;                                                     

          -- Procedimento para popular o total de regs da CRAPRIS na tbgen
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => 99999,
                                         pr_nrcpfcgc      => 8888888888,
                                         pr_nmrelatorio   => 'CRRL567_QTRIS',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dscritic      => '>',
                                         pr_Valor         => vr_qtregarq,
                                         pr_seq_relato    => vr_qtregarq, -- nrctremp
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
            vr_dscritic:= 'CRRL567_QTRIS - '||vr_dscritic;
            raise vr_exc_saida;
          end if;                                                     
        end if;
      END pc_carrega_base_risco;

      -- Carrega a temp-table vr_tab_saida com base na tabela CRAPRIS
      PROCEDURE pc_carrega_base_saida(pr_cdcooper NUMBER
                                     ,pr_dtrefere DATE
                                     ,pr_flbbndes VARCHAR2) IS

        -- Descricao dos bens da proposta de emprestimo do cooperado.
        CURSOR cr_crapris_renegociacao(pr_cdcooper crapris.cdcooper%TYPE,
                                       pr_nrdconta crapris.nrdconta%TYPE,
                                       pr_nrctremp crapris.nrctremp%TYPE,
                                       pr_dtrefere crapris.dtrefere%TYPE) IS
          SELECT cdmodali,
                 dsinfaux
            FROM crapris
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND dtrefere = pr_dtrefere
             AND cdorigem = 3
             AND inddocto = 1
             AND rownum   = 1;
        rw_crapris_renegociacao cr_crapris_renegociacao%ROWTYPE;
        
        -- Cursor sobre a tabela de risco com modalidade diferente de 301
        CURSOR cr_crapris (pr_cdcooper crapass.cdcooper%TYPE
                          ,pr_cdagenci crapass.cdagenci%TYPE
                          ,pr_dtrefere crapris.dtrefere%TYPE) IS
          SELECT ris.nrdconta,
                 ris.dtrefere,
                 ris.innivris,
                 ris.qtdiaatr,
                 ris.vldivida,
                 ris.vlsld59d,
                 ris.vlvec180,
                 ris.vlvec360,
                 ris.vlvec999,
                 ris.vldiv060,
                 ris.vldiv180,
                 ris.vldiv360,
                 ris.vldiv999,
                 ris.vlprjano,
                 ris.vlprjaan,
                 ris.inpessoa,
                 ris.nrcpfcgc,
                 ris.vlprjant,
                 ris.inddocto,
                 ris.cdmodali,
                 ris.nrctremp,
                 ris.nrseqctr,
                 ris.dtinictr,
                 ris.cdorigem,
                 ris.cdagenci,
                 ris.innivori,
                 ris.cdcooper,
                 ris.vlprjm60,
                 ris.dtdrisco,
                 ris.qtdriclq,
                 ris.nrdgrupo,
                 ris.vljura60,
                 ris.inindris,
                 ris.cdinfadi,
                 ris.nrctrnov,
                 ris.flgindiv,
                 DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) sbcpfcgc,
                 ris.dsinfaux,
                 ris.dtprxpar,
                 ris.vlprxpar,
                 ris.qtparcel,
                 ris.dtvencop,
                 ROW_NUMBER () OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8))) nrseq,
                 COUNT(1)      OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8))) qtreg
            FROM crapris ris
                ,crapass ass
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto IN(2,5) -- Saida ou Garantias Prestadas com Saida
             AND nvl(ris.cdinfadi,' ') <> ' '
             AND ris.cdmodali <> 0301 -- Dsc Tit
             AND ris.cdcooper = ass.cdcooper
             AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci) 
             AND ass.nrdconta = ris.nrdconta;

        -- Cursor sobre a tabela de risco com modalidade igual a 301
        CURSOR cr_crapris_dsctit (pr_cdcooper crapass.cdcooper%TYPE
                                 ,pr_cdagenci crapass.cdagenci%TYPE
                                 ,pr_dtrefere crapris.dtrefere%TYPE) IS
          SELECT ris.nrdconta,
                 ris.dtrefere,
                 ris.innivris,
                 ris.qtdiaatr,
                 ris.vldivida,
                 vlvec180,
                 vlvec360,
                 vlvec999,
                 vldiv060,
                 vldiv180,
                 vldiv360,
                 vldiv999,
                 vlprjano,
                 vlprjaan,
                 ris.inpessoa,
                 ris.nrcpfcgc,
                 vlprjant,
                 inddocto,
                 cdmodali,
                 nrctremp,
                 nrseqctr,
                 dtinictr,
                 cdorigem,
                 ris.cdagenci,
                 innivori,
                 ris.cdcooper,
                 vlprjm60,
                 dtdrisco,
                 qtdriclq,
                 nrdgrupo,
                 vljura60,
                 inindris,
                 cdinfadi,
                 nrctrnov,
                 flgindiv,
                 dsinfaux,
                 DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) sbcpfcgc,
                 dtprxpar,
                 vlprxpar,
                 qtparcel,
                 dtvencop,
                 ROW_NUMBER () OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)),ris.nrdconta,ris.nrctremp 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)),ris.nrdconta,ris.nrctremp) nrseq,
                 COUNT(1)      OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)),ris.nrdconta,ris.nrctremp 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)),ris.nrdconta,ris.nrctremp) qtreg
            FROM crapris ris
                ,crapass ass
           WHERE ris.cdcooper = pr_cdcooper
             AND ris.dtrefere = pr_dtrefere
             AND ris.inddocto = 2
             AND ris.cdmodali = 0301 -- Dsc Tit 
             AND ris.cdorigem IN(4,5)       /* Desconto Titulos */
             AND ris.cdcooper = ass.cdcooper
             AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci) 
             AND ass.nrdconta = ris.nrdconta;
        
        -- Cursor sobre a tabela de risco com modalidade diferente de 301
        CURSOR cr_crapris_BNDEs (pr_dtrefere crapris.dtrefere%TYPE) IS
          SELECT ris.nrdconta,
                 ris.dtrefere,
                 ris.innivris,
                 ris.qtdiaatr,
                 ris.vldivida,
                 ris.vlvec180,
                 ris.vlvec360,
                 ris.vlvec999,
                 ris.vldiv060,
                 ris.vldiv180,
                 ris.vldiv360,
                 ris.vldiv999,
                 ris.vlprjano,
                 ris.vlprjaan,
                 ris.inpessoa,
                 ris.nrcpfcgc,
                 ris.vlprjant,
                 ris.inddocto,
                 ris.cdmodali,
                 ris.nrctremp,
                 ris.nrseqctr,
                 ris.dtinictr,
                 ris.cdorigem,
                 ris.cdagenci,
                 ris.innivori,
                 ris.cdcooper,
                 ris.vlprjm60,
                 ris.dtdrisco,
                 ris.qtdriclq,
                 ris.nrdgrupo,
                 ris.vljura60,
                 ris.inindris,
                 ris.cdinfadi,
                 ris.nrctrnov,
                 ris.flindbndes flgindiv, /* BNDES possui flg de individualização específica */
                 DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) sbcpfcgc,
                 ris.dsinfaux,
                 ris.dtprxpar,
                 ris.vlprxpar,
                 ris.qtparcel,
                 ris.dtvencop,
                 ROW_NUMBER () OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8))) nrseq,
                 COUNT(1)      OVER (PARTITION BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8)) 
                               ORDER BY DECODE(ris.inpessoa,1,SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,14),SUBSTR(lpad(ris.nrcpfcgc,14,'0'),1,8))) qtreg
            FROM crapris ris
           WHERE ris.dtrefere = pr_dtrefere
             AND ris.inddocto IN(2,5) -- Saida ou Garantias Prestadas com Saida
             AND ris.cdorigem IN(1,3,7) -- Limite, Emprestimos e Financiamentos e Garantias Prestadas Coops
             AND nvl(ris.cdinfadi,' ') <> ' '
             AND (  ris.dsinfaux = 'BNDES'  
                 OR (ris.cdorigem = 1 AND EXISTS(SELECT 1
                                                   FROM craplim li
                                                       ,craplrt lr
                                                  WHERE li.cdcooper = ris.cdcooper
                                                    AND li.nrdconta = ris.nrdconta
                                                    AND li.nrctrlim = ris.nrctremp
                                                    AND li.cdcooper = lr.cdcooper
                                                    AND li.cddlinha = lr.cddlinha
                                                    AND lr.dsdlinha LIKE '%BNDES%'))
                  OR (ris.cdorigem = 3 AND exists(select 1
                                                    from crapepr ep
                                                    join craplcr lc
                                                      on lc.cdcooper = ep.cdcooper
                                                     AND lc.cdlcremp = ep.cdlcremp                     
                                                   WHERE ep.cdcooper = ris.cdcooper
                                                     AND ep.nrdconta = ris.nrdconta
                                                     AND ep.nrctremp = ris.nrctremp
                                                     AND lc.dsorgrec IN ('MICROCREDITO PNMPO BNDES AILOS','MICROCREDITO PNMPO BNDES')))
                  OR (ris.inddocto = 5 AND EXISTS(SELECT 1
                                                    FROM tbrisco_provisgarant_prodt prd
                                                        ,tbrisco_provisgarant_movto mvt
                                                   WHERE mvt.idproduto     = prd.idproduto
                                                     AND mvt.idmovto_risco = ris.dsinfaux
                                                     and prd.tparquivo     = 'Cartao_BNDES_BRDE'))
                 );
        
      BEGIN
        
        -- QUando execução de recursos BNDES
        IF pr_flbbndes = 'S' THEN
          
          -- leitura sobre a tabela de riscos onde a modalidade for diferente de 301
          FOR rw_crapris IN cr_crapris_BNDEs (pr_dtrefere) LOOP
            -- copia os dados do cursor para a tabela temporaria
            vr_vlcont_crapris := vr_vlcont_crapris + 1;
            vr_indice_crapris := lpad(rw_crapris.nrcpfcgc,14,'0')
                              || lpad(rw_crapris.cdcooper,03,'0')
                              || lpad(rw_crapris.nrctremp,10,'0')
                              || lpad(vr_vlcont_crapris,10,'0');
            vr_tab_saida(vr_indice_crapris).nrdconta := rw_crapris.nrdconta;
            vr_tab_saida(vr_indice_crapris).dtrefere := rw_crapris.dtrefere;
            vr_tab_saida(vr_indice_crapris).innivris := rw_crapris.innivris;
            vr_tab_saida(vr_indice_crapris).qtdiaatr := rw_crapris.qtdiaatr;
            vr_tab_saida(vr_indice_crapris).vldivida := rw_crapris.vldivida;
            vr_tab_saida(vr_indice_crapris).vlvec180 := rw_crapris.vlvec180;
            vr_tab_saida(vr_indice_crapris).vlvec360 := rw_crapris.vlvec360;
            vr_tab_saida(vr_indice_crapris).vlvec999 := rw_crapris.vlvec999;
            vr_tab_saida(vr_indice_crapris).vldiv060 := rw_crapris.vldiv060;
            vr_tab_saida(vr_indice_crapris).vldiv180 := rw_crapris.vldiv180;
            vr_tab_saida(vr_indice_crapris).vldiv360 := rw_crapris.vldiv360;
            vr_tab_saida(vr_indice_crapris).vldiv999 := rw_crapris.vldiv999;
            vr_tab_saida(vr_indice_crapris).vlprjano := rw_crapris.vlprjano;
            vr_tab_saida(vr_indice_crapris).vlprjaan := rw_crapris.vlprjaan;
            vr_tab_saida(vr_indice_crapris).inpessoa := rw_crapris.inpessoa;
            vr_tab_saida(vr_indice_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
            vr_tab_saida(vr_indice_crapris).vlprjant := rw_crapris.vlprjant;
            vr_tab_saida(vr_indice_crapris).inddocto := rw_crapris.inddocto;
            vr_tab_saida(vr_indice_crapris).cdmodali := rw_crapris.cdmodali;
            vr_tab_saida(vr_indice_crapris).nrctremp := rw_crapris.nrctremp;
            vr_tab_saida(vr_indice_crapris).nrseqctr := rw_crapris.nrseqctr;
            vr_tab_saida(vr_indice_crapris).dtinictr := rw_crapris.dtinictr;
            vr_tab_saida(vr_indice_crapris).cdorigem := rw_crapris.cdorigem;
            vr_tab_saida(vr_indice_crapris).cdagenci := rw_crapris.cdagenci;
            vr_tab_saida(vr_indice_crapris).innivori := rw_crapris.innivori;
            vr_tab_saida(vr_indice_crapris).cdcooper := rw_crapris.cdcooper;
            vr_tab_saida(vr_indice_crapris).vlprjm60 := rw_crapris.vlprjm60;
            vr_tab_saida(vr_indice_crapris).dtdrisco := rw_crapris.dtdrisco;
            vr_tab_saida(vr_indice_crapris).qtdriclq := rw_crapris.qtdriclq;
            vr_tab_saida(vr_indice_crapris).nrdgrupo := rw_crapris.nrdgrupo;
            vr_tab_saida(vr_indice_crapris).vljura60 := rw_crapris.vljura60;
            vr_tab_saida(vr_indice_crapris).inindris := rw_crapris.inindris;
            vr_tab_saida(vr_indice_crapris).cdinfadi := rw_crapris.cdinfadi;
            vr_tab_saida(vr_indice_crapris).nrctrnov := rw_crapris.nrctrnov;
            vr_tab_saida(vr_indice_crapris).flgindiv := rw_crapris.flgindiv;
            vr_tab_saida(vr_indice_crapris).dsinfaux := rw_crapris.dsinfaux;
            vr_tab_saida(vr_indice_crapris).dtprxpar := rw_crapris.dtprxpar;
            vr_tab_saida(vr_indice_crapris).vlprxpar := rw_crapris.vlprxpar;
            vr_tab_saida(vr_indice_crapris).qtparcel := rw_crapris.qtparcel;
            vr_tab_saida(vr_indice_crapris).sbcpfcgc := rw_crapris.sbcpfcgc;
            vr_tab_saida(vr_indice_crapris).dtvencop := rw_crapris.dtvencop;
            
            -- Vamos verificar se o contrato é de renegociacao
            IF vr_tab_saida(vr_indice_crapris).nrctrnov > 0 THEN
              -- Busca as informacoes do novo contrato
              OPEN cr_crapris_renegociacao(pr_cdcooper => vr_tab_saida(vr_indice_crapris).cdcooper
                                          ,pr_nrdconta => vr_tab_saida(vr_indice_crapris).nrdconta
                                          ,pr_nrctremp => vr_tab_saida(vr_indice_crapris).nrctrnov
                                          ,pr_dtrefere => vr_tab_saida(vr_indice_crapris).dtrefere);
              FETCH cr_crapris_renegociacao INTO rw_crapris_renegociacao;
              IF cr_crapris_renegociacao%FOUND THEN
                CLOSE cr_crapris_renegociacao;
                vr_tab_saida(vr_indice_crapris).cdmodnov := rw_crapris_renegociacao.cdmodali;
                vr_tab_saida(vr_indice_crapris).dsinfnov := rw_crapris_renegociacao.dsinfaux;
              ELSE
                CLOSE cr_crapris_renegociacao;
              END IF;  
            END IF;
            
          END LOOP;
        
        ELSE
      
          -- leitura sobre a tabela de riscos onde a modalidade for diferente de 301
          FOR rw_crapris IN cr_crapris (pr_cdcooper, pr_cdagenci, pr_dtrefere) LOOP
            -- copia os dados do cursor para a tabela temporaria
            vr_vlcont_crapris := vr_vlcont_crapris + 1;
            vr_indice_crapris := lpad(rw_crapris.nrcpfcgc,14,'0')
                              || lpad(rw_crapris.cdcooper,03,'0')
                              || lpad(rw_crapris.nrctremp,10,'0')
                              || lpad(vr_vlcont_crapris,10,'0');
            vr_tab_saida(vr_indice_crapris).nrdconta := rw_crapris.nrdconta;
            vr_tab_saida(vr_indice_crapris).dtrefere := rw_crapris.dtrefere;
            vr_tab_saida(vr_indice_crapris).innivris := rw_crapris.innivris;
            vr_tab_saida(vr_indice_crapris).qtdiaatr := rw_crapris.qtdiaatr;
            vr_tab_saida(vr_indice_crapris).vldivida := rw_crapris.vldivida;
            vr_tab_saida(vr_indice_crapris).vlsld59d := rw_crapris.vlsld59d;
            vr_tab_saida(vr_indice_crapris).vlvec180 := rw_crapris.vlvec180;
            vr_tab_saida(vr_indice_crapris).vlvec360 := rw_crapris.vlvec360;
            vr_tab_saida(vr_indice_crapris).vlvec999 := rw_crapris.vlvec999;
            vr_tab_saida(vr_indice_crapris).vldiv060 := rw_crapris.vldiv060;
            vr_tab_saida(vr_indice_crapris).vldiv180 := rw_crapris.vldiv180;
            vr_tab_saida(vr_indice_crapris).vldiv360 := rw_crapris.vldiv360;
            vr_tab_saida(vr_indice_crapris).vldiv999 := rw_crapris.vldiv999;
            vr_tab_saida(vr_indice_crapris).vlprjano := rw_crapris.vlprjano;
            vr_tab_saida(vr_indice_crapris).vlprjaan := rw_crapris.vlprjaan;
            vr_tab_saida(vr_indice_crapris).inpessoa := rw_crapris.inpessoa;
            vr_tab_saida(vr_indice_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
            vr_tab_saida(vr_indice_crapris).vlprjant := rw_crapris.vlprjant;
            vr_tab_saida(vr_indice_crapris).inddocto := rw_crapris.inddocto;
            vr_tab_saida(vr_indice_crapris).cdmodali := rw_crapris.cdmodali;
            vr_tab_saida(vr_indice_crapris).nrctremp := rw_crapris.nrctremp;
            vr_tab_saida(vr_indice_crapris).nrseqctr := rw_crapris.nrseqctr;
            vr_tab_saida(vr_indice_crapris).dtinictr := rw_crapris.dtinictr;
            vr_tab_saida(vr_indice_crapris).cdorigem := rw_crapris.cdorigem;
            vr_tab_saida(vr_indice_crapris).cdagenci := rw_crapris.cdagenci;
            vr_tab_saida(vr_indice_crapris).innivori := rw_crapris.innivori;
            vr_tab_saida(vr_indice_crapris).cdcooper := rw_crapris.cdcooper;
            vr_tab_saida(vr_indice_crapris).vlprjm60 := rw_crapris.vlprjm60;
            vr_tab_saida(vr_indice_crapris).dtdrisco := rw_crapris.dtdrisco;
            vr_tab_saida(vr_indice_crapris).qtdriclq := rw_crapris.qtdriclq;
            vr_tab_saida(vr_indice_crapris).nrdgrupo := rw_crapris.nrdgrupo;
            vr_tab_saida(vr_indice_crapris).vljura60 := rw_crapris.vljura60;
            vr_tab_saida(vr_indice_crapris).inindris := rw_crapris.inindris;
            vr_tab_saida(vr_indice_crapris).cdinfadi := rw_crapris.cdinfadi;
            vr_tab_saida(vr_indice_crapris).nrctrnov := rw_crapris.nrctrnov;
            vr_tab_saida(vr_indice_crapris).flgindiv := rw_crapris.flgindiv;
            vr_tab_saida(vr_indice_crapris).dsinfaux := rw_crapris.dsinfaux;
            vr_tab_saida(vr_indice_crapris).dtprxpar := rw_crapris.dtprxpar;
            vr_tab_saida(vr_indice_crapris).vlprxpar := rw_crapris.vlprxpar;
            vr_tab_saida(vr_indice_crapris).qtparcel := rw_crapris.qtparcel;
            vr_tab_saida(vr_indice_crapris).sbcpfcgc := rw_crapris.sbcpfcgc;
            vr_tab_saida(vr_indice_crapris).dtvencop := rw_crapris.dtvencop;
            
            -- Vamos verificar se o contrato é de renegociacao
            IF vr_tab_saida(vr_indice_crapris).nrctrnov > 0 THEN
              -- Busca as informacoes do novo contrato
              OPEN cr_crapris_renegociacao(pr_cdcooper => vr_tab_saida(vr_indice_crapris).cdcooper
                                          ,pr_nrdconta => vr_tab_saida(vr_indice_crapris).nrdconta
                                          ,pr_nrctremp => vr_tab_saida(vr_indice_crapris).nrctrnov
                                          ,pr_dtrefere => vr_tab_saida(vr_indice_crapris).dtrefere);
              FETCH cr_crapris_renegociacao INTO rw_crapris_renegociacao;
              IF cr_crapris_renegociacao%FOUND THEN
                CLOSE cr_crapris_renegociacao;
                vr_tab_saida(vr_indice_crapris).cdmodnov := rw_crapris_renegociacao.cdmodali;
                vr_tab_saida(vr_indice_crapris).dsinfnov := rw_crapris_renegociacao.dsinfaux;
              ELSE
                CLOSE cr_crapris_renegociacao;
              END IF;  
            END IF;
            
          END LOOP;

          vr_vldivida_0301 := 0;

          -- leitura sobre a tabela de riscos onde a modalidade for igual a 301
          FOR rw_crapris IN cr_crapris_dsctit (pr_cdcooper,pr_cdagenci,pr_dtrefere) LOOP

            vr_vldivida_0301 := vr_vldivida_0301 + rw_crapris.vldivida;
            -- Se for o ultimo registro com base na conta e numero do contrato, insere na tabela temporaria
            IF rw_crapris.nrseq = rw_crapris.qtreg THEN
              vr_vlcont_crapris := vr_vlcont_crapris + 1;
              vr_indice_crapris := lpad(rw_crapris.nrcpfcgc,14,'0')
                                || lpad(rw_crapris.cdcooper,03,'0')
                                || lpad(rw_crapris.nrctremp,10,'0')
                                || lpad(vr_vlcont_crapris,10,'0');
              vr_tab_saida(vr_indice_crapris).nrdconta := rw_crapris.nrdconta;
              vr_tab_saida(vr_indice_crapris).dtrefere := rw_crapris.dtrefere;
              vr_tab_saida(vr_indice_crapris).innivris := rw_crapris.innivris;
              vr_tab_saida(vr_indice_crapris).qtdiaatr := rw_crapris.qtdiaatr;
              vr_tab_saida(vr_indice_crapris).vldivida := vr_vldivida_0301;
              vr_tab_saida(vr_indice_crapris).vlvec180 := rw_crapris.vlvec180;
              vr_tab_saida(vr_indice_crapris).vlvec360 := rw_crapris.vlvec360;
              vr_tab_saida(vr_indice_crapris).vlvec999 := rw_crapris.vlvec999;
              vr_tab_saida(vr_indice_crapris).vldiv060 := rw_crapris.vldiv060;
              vr_tab_saida(vr_indice_crapris).vldiv180 := rw_crapris.vldiv180;
              vr_tab_saida(vr_indice_crapris).vldiv360 := rw_crapris.vldiv360;
              vr_tab_saida(vr_indice_crapris).vldiv999 := rw_crapris.vldiv999;
              vr_tab_saida(vr_indice_crapris).vlprjano := rw_crapris.vlprjano;
              vr_tab_saida(vr_indice_crapris).vlprjaan := rw_crapris.vlprjaan;
              vr_tab_saida(vr_indice_crapris).inpessoa := rw_crapris.inpessoa;
              vr_tab_saida(vr_indice_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
              vr_tab_saida(vr_indice_crapris).vlprjant := rw_crapris.vlprjant;
              vr_tab_saida(vr_indice_crapris).inddocto := rw_crapris.inddocto;
              vr_tab_saida(vr_indice_crapris).cdmodali := rw_crapris.cdmodali;
              vr_tab_saida(vr_indice_crapris).nrctremp := rw_crapris.nrctremp;
              vr_tab_saida(vr_indice_crapris).nrseqctr := rw_crapris.nrseqctr;
              vr_tab_saida(vr_indice_crapris).dtinictr := rw_crapris.dtinictr;
              vr_tab_saida(vr_indice_crapris).cdorigem := rw_crapris.cdorigem;
              vr_tab_saida(vr_indice_crapris).cdagenci := rw_crapris.cdagenci;
              vr_tab_saida(vr_indice_crapris).innivori := rw_crapris.innivori;
              vr_tab_saida(vr_indice_crapris).cdcooper := rw_crapris.cdcooper;
              vr_tab_saida(vr_indice_crapris).vlprjm60 := rw_crapris.vlprjm60;
              vr_tab_saida(vr_indice_crapris).dtdrisco := rw_crapris.dtdrisco;
              vr_tab_saida(vr_indice_crapris).qtdriclq := rw_crapris.qtdriclq;
              vr_tab_saida(vr_indice_crapris).nrdgrupo := rw_crapris.nrdgrupo;
              vr_tab_saida(vr_indice_crapris).vljura60 := rw_crapris.vljura60;
              vr_tab_saida(vr_indice_crapris).inindris := rw_crapris.inindris;
              vr_tab_saida(vr_indice_crapris).cdinfadi := rw_crapris.cdinfadi;
              vr_tab_saida(vr_indice_crapris).nrctrnov := rw_crapris.nrctrnov;
              vr_tab_saida(vr_indice_crapris).flgindiv := rw_crapris.flgindiv;
              vr_tab_saida(vr_indice_crapris).dsinfaux := rw_crapris.dsinfaux;
              vr_tab_saida(vr_indice_crapris).dtprxpar := rw_crapris.dtprxpar;
              vr_tab_saida(vr_indice_crapris).vlprxpar := rw_crapris.vlprxpar;
              vr_tab_saida(vr_indice_crapris).qtparcel := rw_crapris.qtparcel;            
              vr_tab_saida(vr_indice_crapris).sbcpfcgc := rw_crapris.sbcpfcgc;
              vr_tab_saida(vr_indice_crapris).dtvencop := rw_crapris.dtvencop;
              -- Zera variavel acumulativa
              vr_vldivida_0301 := 0;
            END IF;
          END LOOP;
        END IF;
      END pc_carrega_base_saida;

      -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
      FUNCTION fn_classifica_risco(pr_innivris in number) RETURN VARCHAR2 IS
      BEGIN
        CASE pr_innivris 
          WHEN 1 THEN
            RETURN 'AA';
          WHEN 2 THEN
            RETURN 'A';
          WHEN 3 THEN
            RETURN 'B';
          WHEN 4 THEN
            RETURN 'C';
          WHEN 5 THEN
            RETURN 'D';
          WHEN 6 THEN
            RETURN 'E';
          WHEN 7 THEN
            RETURN 'F';
          WHEN 8 THEN
            RETURN 'G';
          WHEN 9 THEN
            RETURN 'H';
          ELSE
            RETURN 'HH';
        END CASE;
      END fn_classifica_risco;

      -- Com base nos emprestimos / linhas de credito / linhas de desconto eh buscado a taxa efetiva anual
      FUNCTION fn_busca_taxeft(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_cdmodali IN PLS_INTEGER
                              ,pr_nrdconta IN craplim.nrdconta%TYPE
                              ,pr_nrctremp IN crapvri.nrctremp%TYPE
                              ,pr_inddocto in crapris.inddocto%TYPE
                              ,pr_inpessoa IN crapris.inpessoa%TYPE
                              ,pr_dsinfaux IN crapris.dsinfaux%TYPE
                              ,pr_cdorigem IN crapris.cdorigem%TYPE) RETURN NUMBER IS


        -- Cursor sobre a tabela de linhas de desconto
        CURSOR cr_crapldc (pr_cddlinha craplim.cddlinha%TYPE,
                           pr_tpdescto crapldc.tpdescto%TYPE) IS
          SELECT txjurmor
            FROM crapldc
           WHERE crapldc.cdcooper = pr_cdcooper
             AND crapldc.cddlinha = pr_cddlinha
             AND crapldc.tpdescto = pr_tpdescto;
        rw_crapldc cr_crapldc%ROWTYPE;
        
        -- Armazenamento da taxa
        vr_txeanual NUMBER(10,4) := 0;
        
        -- Tipo de contrato de limite para busca
        vr_tpctrlim craplim.tpctrlim%TYPE;
      BEGIN
        -- Para Garantias Prestadas
        IF pr_inddocto = 5 THEN 
          -- Buscar a taxa no cadastro do movimento
          IF vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper,03,'0')||pr_dsinfaux) THEN 
            vr_txeanual := vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).vltaxajr;
          END IF;
        -- Para cartões BB e Bancoob
        ELSIF pr_inddocto = 4 THEN
          -- Buscar taxa conforme cartão
          vr_ind_crd  := LPAD(pr_cdcooper,3,'0') || LPAD(pr_nrdconta,10,'0') || LPAD(pr_nrctremp,10,'0');
          IF vr_tab_tbcrd_risco.exists(vr_ind_crd) THEN 
            IF vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar = 1 THEN
              vr_txeanual := vr_vltxban;
            ELSIF vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar = 2 THEN 
              vr_txeanual := vr_vltxabb;
            ELSE 
              vr_txeanual := 0;
            END IF;
          ELSE 
            vr_txeanual := 0;
          END IF;
        -- Para Cheque especial e Limite não utilizado 
        ELSIF pr_cdmodali IN(0201,1901,0302,0301) THEN
          -- PAra Cheq Esp e Limite não Utilizado, já temos o contrato
          IF pr_cdmodali IN(0201,1901) THEN
            vr_nrctrlim := pr_nrctremp;
            -- Tipo 1
            vr_tpctrlim := 1;
          ELSE   
            -- Busca o número do contrato de limite de credito pelo Borderô
            vr_nrctrlim := 0;
            -- Buscar tabela de borderô conforme o tipo
            IF pr_cdmodali = 0302 THEN
              OPEN cr_crapbdc (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrborder => pr_nrctremp);
              FETCH cr_crapbdc
               INTO vr_nrctrlim;
              CLOSE cr_crapbdc;
              -- Tipo 2
              vr_tpctrlim := 2;
            ELSE
              OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrborder => pr_nrctremp);
              FETCH cr_crapbdt
               INTO vr_nrctrlim;
              CLOSE cr_crapbdt; 
              -- Tipo 3
              vr_tpctrlim := 3;
            END IF;  
          END IF;  
          -- Somente Se encontrou contrato de limite
          IF vr_nrctrlim <> 0 THEN
            -- busca sobre a tabela de limite de credito
            OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => vr_tpctrlim);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              -- Para Cheque Especial e Limite não Utilizado
              IF pr_cdmodali IN(0201,1901) THEN
                -- busca sobre a tabela de linhas de credito rotativo
                OPEN cr_craplrt(pr_inpessoa, rw_craplim.cddlinha );
                FETCH cr_craplrt INTO rw_craplrt;
                IF cr_craplrt%FOUND THEN
                  vr_txeanual := ROUND((POWER(1 + (rw_craplrt.txmensal / 100),12) - 1) * 100,2);
                ELSE
                  vr_txeanual := 0;
                END IF;
                CLOSE cr_craplrt;
              -- PAra descontos de Cheque e Titulos
              ELSE
                vr_vlrctado := rw_craplim.vllimite;
                -- Taxa Efetiva Anual conforme tipo de desconto
                IF pr_cdmodali = 0302 THEN
                  -- Tipo de desconto = 2
                  OPEN cr_crapldc(rw_craplim.cddlinha,2);
                ELSE
                  -- Tipo de desconto = 3
                  OPEN cr_crapldc(rw_craplim.cddlinha,3);
                END IF;  
                FETCH cr_crapldc INTO rw_crapldc;
                IF cr_crapldc%FOUND THEN
                  vr_txeanual := ROUND((POWER(1 + (rw_crapldc.txjurmor / 100),12) - 1) * 100,2);
                ELSE
                  vr_txeanual := 0;
                END IF;
                CLOSE cr_crapldc;
              END IF;  
            ELSE
              vr_txeanual := 0;
            END IF;
            CLOSE cr_craplim;
          ELSE
            vr_txeanual := 0;
          END IF; 
        -- 0299 - Emprest / 0499 - Financ  com origem 3
        ELSIF pr_cdmodali IN(0299,0499) AND pr_cdorigem = 3 THEN

          -- Busca sobre o cadastro de emprestimo do bndes
          IF pr_dsinfaux = 'BNDES' THEN         
            vr_ind_ebn := lpad(pr_cdcooper,03,'0')
                       || lpad(pr_nrdconta,10,'0')
                       || lpad(pr_nrctremp,10,'0');
            vr_txeanual := vr_tab_crapebn(vr_ind_ebn).txefeanu;
          ELSE
            -- busca sobre o cadastro de emprestimos
            vr_ind_epr := lpad(pr_cdcooper,03,'0')
                       || lpad(pr_nrdconta,10,'0')
                       || lpad(pr_nrctremp,10,'0');
             
            -- IDX da Linha de Credito
            vr_idx_lcr := lpad(pr_cdcooper,03,'0')
                       || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');          
                       
            -- Buscaremos a taxa de juros da linha de crédito
            IF vr_tab_craplcr.exists(vr_idx_lcr) THEN
              -- Usar taxa da linha
              vr_txeanual := ROUND((POWER(1 + (vr_tab_crapepr(vr_ind_epr).txmensal /100),12) - 1) * 100,2);
            ELSE
              -- Não há taxa
              vr_txeanual := 0;
            END IF;
          END IF;
        ELSE
          vr_txeanual := 0;
        END IF;
        -- Efetuar o retorno
        RETURN vr_txeanual;
      END fn_busca_taxeft;

      -- Com base nas faixas de vencimento, eh buscado o total da divida
      FUNCTION fn_total_divida(pr_faixasde IN  PLS_INTEGER
                              ,pr_faixapar IN  PLS_INTEGER
                              ,pr_tab_venc IN OUT NOCOPY typ_tab_venc) RETURN NUMBER IS
        -- Variavel para o indice
        vr_indice_venc_prm PLS_INTEGER;
        -- Total a acumular
        vr_ttldivid NUMBER(17,2);      
      BEGIN
        -- Inicializar
        vr_ttldivid := 0;
        -- Leitura da pltable para acumulo conforme faixas enviadas
        vr_indice_venc_prm := pr_tab_venc.first;
        WHILE vr_indice_venc_prm IS NOT NULL LOOP
          IF pr_tab_venc(vr_indice_venc_prm).cdvencto >= pr_faixasde AND pr_tab_venc(vr_indice_venc_prm).cdvencto <= pr_faixapar THEN
            vr_ttldivid := vr_ttldivid + pr_tab_venc(vr_indice_venc_prm).vldivida;
          END IF;
          -- Posicionar no proximo registro
          vr_indice_venc_prm := pr_tab_venc.next(vr_indice_venc_prm);
        END LOOP;
        -- Retornar valor acumulado
        RETURN vr_ttldivid;
      END fn_total_divida;

      -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
      FUNCTION fn_normaliza_juros(pr_ttldivid  IN NUMBER
                                 ,pr_vldivida  IN NUMBER
                                 ,pr_vljura60  IN NUMBER
                                 ,pr_flgtrunc  IN BOOLEAN) RETURN NUMBER IS
        -- Auxiliares ao calculo
        vr_vlacumul NUMBER;
        vr_vlpercen NUMBER(17,10);
      BEGIN
        -- Valor percentual com relação ao total da divida frente ao atual
        vr_vlpercen := pr_vldivida / pr_ttldivid;
        -- Valor total é a relação do percentual pendente * juros
        vr_vlacumul := pr_vldivida - (pr_vljura60 * vr_vlpercen);
        -- Se for para truncar em duas casas decimais no calculo
        if pr_flgtrunc THEN 
          vr_vlacumul := round(round(vr_vlacumul*100,2)/100,2);
        else
          vr_vlacumul := round(vr_vlacumul,2);
        end if;
        -- Retornar o valor calculado
        RETURN vr_vlacumul;
      END fn_normaliza_juros;

      -- Retorna os avalistas dos emprestimos e atualiza o arquivo com os mesmos
      PROCEDURE pc_verifica_garantidores IS
        vr_nrctaav1  crapass.nrdconta%TYPE; -- Avalista 01
        vr_nrctaav2  crapass.nrdconta%TYPE; -- Avalista 02
        vr_cpfcgcav crapass.nrcpfcgc%TYPE; -- Testes no cpgcgc
        vr_vlperbem VARCHAR2(50);           -- Percentual do bem
      BEGIN
        -- Limpar variaveis auxiliares
        vr_nrctaav1 := 0;
        vr_nrctaav2 := 0;
        vr_cpfcgcav := 0;
        vr_vlperbem := '';
        
        -- Busca dos avalistas conforme origem e Modalidade
        -- Para Origem 1 - Conta e Modalidade 2012 - Cheque Especial ou 1901 - Limite não Utilizado
        IF vr_tab_individ(vr_idx_individ).cdorigem = 1 AND vr_tab_individ(vr_idx_individ).cdmodali in(0201,1901) THEN 
          -- Busca os dados do limite de credito
          OPEN cr_craplim(vr_tab_individ(vr_idx_individ).cdcooper
                         ,vr_tab_individ(vr_idx_individ).nrdconta
                         ,vr_tab_individ(vr_idx_individ).nrctremp
                         ,1);
          FETCH cr_craplim INTO rw_craplim;
          IF cr_craplim%FOUND THEN
            vr_nrctaav1 := rw_craplim.nrctaav1;
            vr_nrctaav2 := rw_craplim.nrctaav2;
          END IF;
          CLOSE cr_craplim;
        -- Origem 2 - Desconto Cheques
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 2  THEN 
          -- Busca o número do contrato de limite de credito pelo Borderô
          OPEN cr_crapbdc (pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                          ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                          ,pr_nrborder => vr_tab_individ(vr_idx_individ).nrctremp);
          FETCH cr_crapbdc
           INTO vr_nrctrlim;
          -- Somente Se encontrar
          IF cr_crapbdc%FOUND THEN
            -- Então com o contrato de limite, buscar os avalistas
            OPEN cr_craplim(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                           ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => 2);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              vr_nrctaav1 := rw_craplim.nrctaav1;
              vr_nrctaav2 := rw_craplim.nrctaav2;
            END IF;
            CLOSE cr_craplim;
          END IF;
          CLOSE cr_crapbdc;  
        -- Origem 3 - Emprestimos/Financiamentos
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN 
          -- Se empréstimo for do BNDES
          IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
            -- Descricao dos bens da proposta de emprestimo do cooperado.
            vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0') 
                       || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') 
                       || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
            -- Busca a descricao dos bens da proposta de emprestimo
            OPEN cr_crapbpr(vr_tab_individ(vr_idx_individ).cdcooper,
                            vr_tab_individ(vr_idx_individ).nrdconta,
                            vr_tab_individ(vr_idx_individ).nrctremp,
                            95,
                            1); -- Ordenacao ascendente

            FETCH cr_crapbpr INTO rw_crapbpr;
            IF cr_crapbpr%FOUND THEN
              CLOSE cr_crapbpr;

              vr_nrdocnpj := rw_crapbpr.nrcpfbem;
              vr_vlperbem := rw_crapbpr.vlperbem;

              --Validar o cpf/cnpj
              gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrdocnpj
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);

              IF vr_inpessoa = 1 THEN
                vr_nrdocnpj := to_char(rw_crapbpr.nrcpfbem,'fm00000000000');
              ELSE
                vr_nrdocnpj := to_char(rw_crapbpr.nrcpfbem,'fm00000000000000');
              END IF;
              
              -- Salvar para usar na WRK e na escreve XML.
              vr_texto := '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                        || '" Ident="' || vr_nrdocnpj 
                                                        || '" PercGar="'
                                                          ||  vr_vlperbem || '"/>' ;  
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_GAR',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         => null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_Gar - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;                                                     
              Else
                -- Enviar Garantidor
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              End if;
              -- Descricao dos bens da proposta de emprestimo do cooperado.
              OPEN cr_crapbpr(vr_tab_individ(vr_idx_individ).cdcooper,
                              vr_tab_individ(vr_idx_individ).nrdconta,
                              vr_tab_individ(vr_idx_individ).nrctremp,
                               95,
                               0);  -- Ordenacao descendente
              FETCH cr_crapbpr INTO rw_crapbpr;
              CLOSE cr_crapbpr;
              vr_nrdocnpj2 := rw_crapbpr.nrcpfbem;
              vr_vlperbem  := rw_crapbpr.vlperbem;

              --Validar o cpf/cnpj
              gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrdocnpj2
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);
  
              IF vr_inpessoa = 1 THEN
                vr_nrdocnpj2 := to_char(rw_crapbpr.nrcpfbem,'fm00000000000');
              ELSE
                vr_nrdocnpj2 := to_char(rw_crapbpr.nrcpfbem,'fm00000000000000');
              END IF;
  
              IF vr_nrdocnpj <> vr_nrdocnpj2 THEN
                
                vr_texto := '            <Gar Tp="09' ||to_char(vr_inpessoa,'fm00')
                                                      || '" Ident="' || vr_nrdocnpj2 
                                                      || '" PercGar="' 
                                                      || vr_vlperbem ||'"/>' ;
                If vr_tpexecucao = 2 Then
                  vr_seq_relato := vr_seq_relato + 1;
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => '3040_GAR',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                                 pr_dscritic      => vr_texto,
                                                 pr_Valor         => null,
                                                 pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => null,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                    vr_dscritic:= '3040_Gar - '||vr_dscritic;
                    raise vr_exc_saida;
                  end if;                                                     
                else
                  -- Enviar garantidor
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                         ,pr_texto_completo => vr_xml_3040_temp
                                         ,pr_texto_novo     => vr_texto || chr(10));
                end if;
              END IF;
            END IF; --cr_crapbpr%FOUND
            -- Se o cursor ainda estiver aberto, fecha o mesmo
            IF cr_crapbpr%ISOPEN THEN
              CLOSE cr_crapbpr;
            END IF;
          ELSE
            -- Buscaremos do cadastro de empréstimos
            vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                       || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                       || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
            vr_nrctaav1 := vr_tab_crapepr(vr_ind_epr).nrctaav1;
            vr_nrctaav2 := vr_tab_crapepr(vr_ind_epr).nrctaav2;
          END IF; -- Se BNDES
        -- Desconto Titulos
        ELSIF vr_tab_individ(vr_idx_individ).cdorigem = 4  THEN    
          -- Busca o número do contrato de limite de credito pelo Borderô
          OPEN cr_crapbdt (pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                          ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                          ,pr_nrborder => vr_tab_individ(vr_idx_individ).nrctremp);
          FETCH cr_crapbdt
           INTO vr_nrctrlim;
          -- Somente Se encontrar
          IF cr_crapbdt%FOUND THEN
            -- Então com o contrato de limite, buscar os avalistas
            OPEN cr_craplim(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                           ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                           ,pr_nrctremp => vr_nrctrlim
                           ,pr_tpctrlim => 3);
            FETCH cr_craplim INTO rw_craplim;
            IF cr_craplim%FOUND THEN
              vr_nrctaav1 := rw_craplim.nrctaav1;
              vr_nrctaav2 := rw_craplim.nrctaav2;
            END IF;
            CLOSE cr_craplim;
          END IF;
          CLOSE cr_crapbdt;          
        END IF;
        
        -- Se encontrou avalista 1
        IF vr_nrctaav1 <> 0 THEN
          -- Busca seu cadastro de associado
          OPEN cr_crapass(vr_tab_individ(vr_idx_individ).cdcooper,vr_nrctaav1);
          FETCH cr_crapass INTO vr_nrcpfcgc_ass,vr_inpessoa_ass,vr_dsnivris_ass,vr_dtadmiss_ass;
          IF cr_crapass%FOUND THEN
            -- Guardar o CPF/CGC
            vr_cpfcgcav := vr_nrcpfcgc_ass;
              
            -- Montar cpf/cgc cfme tipo de pessoa
            IF vr_inpessoa_ass = 1 THEN
              vr_nrdocnpj := to_char(vr_nrcpfcgc_ass,'fm00000000000');
            ELSE
              vr_nrdocnpj := to_char(vr_nrcpfcgc_ass,'fm00000000000000');
            END IF;

            --Validar o cpf/cnpj
            gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrcpfcgc_ass
                                        ,pr_stsnrcal => vr_stsnrcal
                                        ,pr_inpessoa => vr_inpessoa);
              

            vr_texto := '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                       || '" Ident="' ||vr_nrdocnpj  
                                                     || '" PercGar="100.00"/>' ;                                        
            If vr_tpexecucao = 2 Then
              vr_seq_relato := vr_seq_relato + 1;
              -- Procedimento para gravar wrk, para posteriormente descarregar xml
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                             pr_nrcpfcgc      => vr_nrcgccpf,
                                             pr_nmrelatorio   => '3040_GAR2',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dscritic      => vr_texto,
                                             pr_Valor         => null,
                                             pr_seq_relato    => vr_seq_relato, -- nrctremp
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                raise vr_exc_saida;
              end if;                                                     
            else
              -- Enviar Garantidor
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => vr_texto || chr(10));
            end if;
          END IF; 
          CLOSE cr_crapass;
        END IF;
         
        -- Se existe avalista 2 e for diferente do avalista 1
        IF vr_nrctaav2 <> 0  AND vr_nrctaav2 <> vr_nrctaav1 THEN

            -- Busca seu cadastro de associados
            OPEN cr_crapass(vr_tab_individ(vr_idx_individ).cdcooper,vr_nrctaav2);
            FETCH cr_crapass INTO vr_nrcpfcgc_ass,vr_inpessoa_ass,vr_dsnivris_ass,vr_dtadmiss_ass;
            -- Se encontrou e o CPF/CGC do avalista 1 é diferente deste
            IF cr_crapass%FOUND AND vr_cpfcgcav <> vr_nrcpfcgc_ass THEN
              
              IF vr_inpessoa_ass = 1 THEN
                vr_nrdocnpj := to_char(vr_nrcpfcgc_ass,'fm00000000000');
              ELSE
                vr_nrdocnpj := to_char(vr_nrcpfcgc_ass,'fm00000000000000');
              END IF;
            
              --Validar o cpf/cnpj
              gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrcpfcgc_ass
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);
            
              vr_texto := '            <Gar Tp="09' || to_char(vr_inpessoa,'fm00') 
                                                        || '" Ident="' ||vr_nrdocnpj  
                                                        || '" PercGar="100.00"/>';
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_GAR2',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         => null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;                                                     
              else
                -- Enviar Garantidor
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto  || chr(10));
              end if;
            END IF;
            CLOSE cr_crapass;

          END IF;
      END pc_verifica_garantidores;

      -- Busca o tipo de alienacao e atualiza o arquivo com base no tipo
      PROCEDURE pc_garantia_alienacao_fid IS
        -- Tipo do atributo cfme descrição do bem
        vr_tpatribu INTEGER;
      BEGIN

        -- Se emprestimo (0299) ou financiamento (0499).  
        IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) THEN
          -- Descricao dos bens da proposta de emprestimo do cooperado.
          vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0') ||
                        lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') ||
                        lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
          IF NOT vr_tab_crapebn.exists(vr_ind_ebn) THEN
            -- Pesquisar os bens alienados dos contratos e caso exista gravar como garantia da operaçao.
            FOR rw_tbepr_bens_hst IN cr_tbepr_bens_hst_2(vr_tab_individ(vr_idx_individ).cdcooper
                                                        ,vr_tab_individ(vr_idx_individ).nrdconta
                                                        ,vr_tab_individ(vr_idx_individ).nrctremp
                                                        ,90
                                                        ,pr_dtrefere) LOOP
              -- Realizar de-para da categoria do bem cadastrado no sistema
              --  crapbpr.dscatbem com os codigos de garantias do Bacen. 
              IF rw_tbepr_bens_hst.dscatbem = 'AUTOMOVEL' THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'CASA' THEN
                vr_tpatribu := 0426;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'TERRENO' THEN
                vr_tpatribu := 0427;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'GALPAO' THEN
                vr_tpatribu := 0427;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'MOTO' THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem IN('EQUIPAMENTO','MAQUINA E EQUIPAMENTO') THEN /*Adicionado MAQUINA E EQUIPAMENTO - PRJ438*/
                vr_tpatribu := 0423;
              ELSIF rw_tbepr_bens_hst.dscatbem IN('CAMINHAO','OUTROS VEICULOS') THEN
                vr_tpatribu := 0424;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'APARTAMENTO' THEN
                vr_tpatribu := 0426;
              ELSIF rw_tbepr_bens_hst.dscatbem = 'MAQUINA DE COSTURA' THEN
                vr_tpatribu := 0423;
              ELSE
                vr_tpatribu := 0499;
              END IF;

              vr_texto := '            <Gar Tp="' || to_char(vr_tpatribu,'fm0000')
                                                          || '" VlrOrig="' ||replace(to_char(rw_tbepr_bens_hst.vlmerbem,'fm99999999999990D00'),',','.') 
                                                        || '"/>' ;
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_GAR2',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_valor         => NULL,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => NULL,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;                                                     
              else
                -- Enviar Garantidor
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto ||CHR(10));
              end if;
            END LOOP;
          ELSE --cr_crapebn%FOUND
            FOR rw_crapbpr IN cr_crapbpr_3(vr_tab_individ(vr_idx_individ).cdcooper,
                                           vr_tab_individ(vr_idx_individ).nrdconta,
                                           vr_tab_individ(vr_idx_individ).nrctremp,
                                           95) LOOP

              IF rw_crapbpr.dscatbem = 'EQUIPAMENTOS' THEN
                vr_tpatribu := 0423;
              ELSIF rw_crapbpr.dscatbem = 'VEICULOS' THEN
                vr_tpatribu := 0424;
              ELSIF rw_crapbpr.dscatbem = 'IMOVEIS RESIDENCIAIS' THEN
                vr_tpatribu := 0426;
              ELSIF rw_crapbpr.dscatbem = 'OUTROS IMOVEIS' THEN
                vr_tpatribu := 0427;
              ELSIF rw_crapbpr.dscatbem = 'OUTROS' THEN
                vr_tpatribu := 0499;
              END IF;
              
              vr_texto := '            <Gar Tp="' || to_char(vr_tpatribu,'fm0000')  
                                                        || '" VlrOrig="' || replace(to_char(rw_crapbpr.vlmerbem,'fm999999999999990D00'),',','.') || '"/>' 
                                                  ;
              If vr_tpexecucao = 2 Then
                 vr_seq_relato := vr_seq_relato + 1;
                 -- Procedimento para gravar wrk, para posteriormente descarregar xml
                 pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                                pr_cdagenci      => pr_cdagenci,
                                                pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                                pr_nrcpfcgc      => vr_nrcgccpf,
                                                pr_nmrelatorio   => '3040_GAR2',
                                                pr_dtmvtolt      => pr_dtrefere,
                                                pr_dscritic      => vr_texto,
                                                pr_Valor         => null,
                                                pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                pr_dsxml         => null,
                                                pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                  vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                     raise vr_exc_saida;
                    end if;                                                     
              else
                -- Enviar Garantidor
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              end if;
            END LOOP;
          END IF; --cr_crapebn%notfound
        END IF;
      END pc_garantia_alienacao_fid;
      

      -- Incluir informações do garantia
      PROCEDURE pc_garantia_cobertura_opera(pr_dscritic OUT crapcri.dscritic%TYPE) IS
        vr_tpcontrato    NUMBER := 0;
        vr_vlroriginal   NUMBER := 0;
        vr_vlratualizado NUMBER := 0;
        vr_nrcpfcnpj     VARCHAR2(20);
        --vr_nrcpfcnpj_valida NUMBER := 0;
        vr_inpessoa      NUMBER := 0;
        vr_stsnrcal      BOOLEAN := FALSE;
        vr_idcobertura   NUMBER := 0;
        vr_inaplicacao_propria  NUMBER := 0;
        vr_inpoupanca_propria   NUMBER := 0;
        vr_dscritic      crapcri.dscritic%TYPE;
        vr_exc_saida     EXCEPTION;

        CURSOR cr_cobertura (pr_cdcooper   IN tbgar_cobertura_operacao.cdcooper%TYPE
                            ,pr_nrdconta   IN tbgar_cobertura_operacao.nrdconta%TYPE
                            ,pr_tpcontrato IN tbgar_cobertura_operacao.tpcontrato%TYPE
                            ,pr_nrcontrato IN tbgar_cobertura_operacao.nrcontrato%TYPE) IS
          SELECT nvl(idcobertura, 0) idcobertura,
                 nvl(inaplicacao_propria, 0) inaplicacao_propria,
                 nvl(inpoupanca_propria, 0) inpoupanca_propria
            FROM tbgar_cobertura_operacao
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND tpcontrato = pr_tpcontrato
             AND nrcontrato = pr_nrcontrato
             AND insituacao = 1;
           
        BEGIN
          IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) THEN
            vr_tpcontrato := 90;
          ELSIF vr_tab_individ(vr_idx_individ).cdmodali = 0201 THEN
            vr_tpcontrato := 1;
          ELSIF vr_tab_individ(vr_idx_individ).cdmodali = 0301 THEN
            vr_tpcontrato := 2;
          ELSIF vr_tab_individ(vr_idx_individ).cdmodali = 0302 THEN
            vr_tpcontrato := 3;
          ELSE
            RETURN; -- Sair da rotina
          END IF;
          
         OPEN cr_cobertura(pr_cdcooper   => vr_tab_individ(vr_idx_individ).cdcooper
                          ,pr_nrdconta   => vr_tab_individ(vr_idx_individ).nrdconta
                          ,pr_tpcontrato => vr_tpcontrato
                          ,pr_nrcontrato => vr_tab_individ(vr_idx_individ).nrctremp);
         FETCH cr_cobertura
          INTO vr_idcobertura,
               vr_inaplicacao_propria,
               vr_inpoupanca_propria;
         
         IF nvl(vr_idcobertura,0) > 0 THEN
           bloq0001.pc_bloqueio_garantia_atualizad(pr_idcobert            => vr_idcobertura
                                                  ,pr_vlroriginal         => vr_vlroriginal
                                                  ,pr_vlratualizado       => vr_vlratualizado
                                                  ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj
                                                  ,pr_dscritic            => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
           IF vr_vlratualizado > 0 THEN
             --Validar o cpf/cnpj
             gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => vr_nrcpfcnpj
                                         ,pr_stsnrcal => vr_stsnrcal
                                         ,pr_inpessoa => vr_inpessoa);
             /*IF vr_inpessoa = 1 THEN
               vr_nrcpfcnpj := to_char(vr_nrcpfcnpj,'fm00000000000');
               --vr_nrcpfcnpj_valida := lpad(vr_nrcpfcnpj,11,'0');
             ELSE
               vr_nrcpfcnpj := to_char(vr_nrcpfcnpj,'fm00000000000000');
               --vr_nrcpfcnpj_valida := lpad(vr_nrcpfcnpj,8,'0');
             END IF;*/
             
             -- Se for pós fixado envia como TP105
             IF vr_tpemprst = 2 THEN
               vr_texto :=  '<Gar' || ' Tp="0105"' || ' VlrOrig="' || replace(to_char(vr_vlroriginal,'fm99999999999990D00'),',','.') || '"';
               If vr_tpexecucao = 2 Then
                 null;
               ELSE
                 -- Enviar dados da garantia operação
                 gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                 	                      ,pr_texto_completo => vr_xml_3040_temp
                                        ,pr_texto_novo     => '<Gar' 
                                                           || ' Tp="0105"' 
                                                           || ' VlrOrig="' || replace(to_char(vr_vlroriginal,'fm99999999999990D00'),',','.') || '"');
               END IF;
             ELSE
               vr_texto :=  '<Gar' || ' Tp="0104"' || ' VlrOrig="' || replace(to_char(vr_vlroriginal,'fm99999999999990D00'),',','.') || '"';
               If vr_tpexecucao = 2 Then
                 null;
               else
                 -- Enviar dados da garantia operação           
                 gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                        ,pr_texto_completo => vr_xml_3040_temp
                                        ,pr_texto_novo     => '<Gar'
                                                           || ' Tp="0104"' 
                                                           || ' VlrOrig="' || replace(to_char(vr_vlroriginal,'fm99999999999990D00'),',','.') || '"');
               END IF;
             END IF;                                          
             /* Retirado por causa da regra: O preenchimento do atributo 'VlrOrig' é obrigatório e os atributos 'Ident' 
                                             e 'PercGar' não podem ser preenchidos para 'Tp' diferente de '9'.
              
             -- Enviar o ident quando o CNPJ for diferente do contratante do empréstimo
             IF vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_nrcpfcnpj_valida THEN
               gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                      ,pr_texto_completo => vr_xml_3040_temp
                                      ,pr_texto_novo     => ' Ident="' || vr_nrcpfcnpj || '"');
             END IF;
             */
             IF vr_vlroriginal <> vr_vlratualizado THEN
               vr_texto := vr_texto || ' VlrData="' || replace(to_char(vr_vlratualizado ,'fm99999999999990D00'),',','.') || '"'
                                    || ' DtReav="' || to_char(pr_dtrefere,'YYYY-MM-DD') || '"';
               If vr_tpexecucao = 2 Then
                 null;
               else
                 gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                        ,pr_texto_completo => vr_xml_3040_temp
                                        ,pr_texto_novo     => ' VlrData="' || replace(to_char(vr_vlratualizado ,'fm99999999999990D00'),',','.') || '"'
                                                           || ' DtReav="' || to_char(pr_dtrefere,'YYYY-MM-DD') || '"');
               END IF;
             END IF;
             
             vr_texto := vr_texto || ' />';
             If vr_tpexecucao = 2 Then
               vr_seq_relato := vr_seq_relato + 1;
               -- Procedimento para gravar wrk, para posteriormente descarregar xml
               pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                              pr_cdagenci      => pr_cdagenci,
                                              pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                              pr_nrcpfcgc      => vr_nrcgccpf,
                                              pr_nmrelatorio   => '3040_GAR2',
                                              pr_dtmvtolt      => pr_dtrefere,
                                              pr_dscritic      => vr_texto,
                                              pr_Valor         => null,
                                              pr_seq_relato    => vr_seq_relato, -- nrctremp
                                              pr_dsxml         => null,
                                              pr_des_erro      => vr_dscritic);
               if vr_dscritic is not null then
                 vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                 raise vr_exc_saida;
               end if;
             else
             
               gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                      ,pr_texto_completo => vr_xml_3040_temp
                                      ,pr_texto_novo     => ' />');

               IF pr_dtmvtolt >= vr_dtcorte THEN
                 IF vr_inaplicacao_propria = 1
                 OR vr_inpoupanca_propria  = 1 THEN
                   gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                          ,pr_texto_completo => vr_xml_3040_temp
                                          ,pr_texto_novo     => '<Inf Tp="1998" />');
             END IF;
               END IF;
             END IF;
           END IF;
         END IF;
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na procedure pc_garantia_cobertura_opera. ' || SQLERRM;
      END pc_garantia_cobertura_opera;

      -- Imprime o tipo informando que eh aplicacao regulatoria, quando o emprestimo possuir linhas de credito
      PROCEDURE pc_inf_aplicacao_regulatoria(pr_cdcooper crapris.cdcooper%TYPE,
                                             pr_cdcopemp crapris.cdcooper%TYPE,
                                             pr_nrdconta crapris.nrdconta%TYPE,
                                             pr_nrctremp crapris.nrctremp%TYPE,
                                             pr_cdmodali crapris.cdmodali%TYPE,
                                             pr_cdorigem crapris.cdorigem%TYPE,
                                             pr_dsinfaux crapris.dsinfaux%TYPE) IS
      BEGIN
        -- Para origem 3 - Empr/Financ
        -- E modalidade 0299 - Emprest / 0499 - Financ
        IF pr_cdorigem = 3 AND pr_cdmodali IN(0299,0499) THEN 
          -- Se não for empréstimo BNDES
          IF pr_dsinfaux != 'BNDES' THEN
            -- Busca os dados de emprestimos
            vr_ind_epr := lpad(pr_cdcopemp,03,'0')
                       || lpad(pr_nrdconta,10,'0')
                       || lpad(pr_nrctremp,10,'0');
            -- IDX da Linha de Credito
            vr_idx_lcr := lpad(pr_cdcopemp,03,'0')
                       || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');   
            -- Somente se encontrou linha de credito e origem DIM
            IF vr_tab_craplcr.EXISTS(vr_idx_lcr) AND vr_tab_craplcr(vr_idx_lcr).dsorgrec LIKE '%DIM%' THEN
                            
              vr_texto := '            <Inf Tp="1408" />';
               If vr_tpexecucao = 2 Then
                  vr_seq_relato := vr_seq_relato + 1;
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper,
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => vr_tab_individ(vr_idx_individ).nrdconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => '3040_GAR2',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                                 pr_dscritic      => vr_texto,
                                                 pr_Valor         => null,
                                                 pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => null,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                  vr_dscritic:= '3040_Gar2 - '||vr_dscritic;
                     raise vr_exc_saida;
                  end if;                                                     
              else
                -- Enviar Informação do Financiamento
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => '            <Inf Tp="1408" />' ||chr(10));
              end if;
            END IF;
          END IF;
        END IF;
      END pc_inf_aplicacao_regulatoria;

      -- Caso o emprestimo for para bens alienáveis imprime o codigo do chassi do mesmo.
      PROCEDURE pc_verifica_inf_chassi(pr_cdcooper crapris.cdcooper%TYPE,
                                       pr_cdcopemp crapris.cdcooper%TYPE,
                                       pr_nrdconta crapris.nrdconta%TYPE,
                                       pr_nrctremp crapris.nrctremp%TYPE,
                                       pr_cdmodali crapris.cdmodali%TYPE,
                                       pr_cdorigem crapris.cdorigem%TYPE,
                                       pr_dsinfaux crapris.dsinfaux%TYPE) IS
      BEGIN
        -- Para Emprst ou Financ
        IF pr_cdmodali IN(0299,0499) THEN
          -- Busca a descricao dos bens da proposta de emprestimo
          FOR rw_tbepr_bens_hst IN cr_tbepr_bens_hst_4(pr_cdcopemp,pr_nrdconta, pr_nrctremp, 90, pr_dtrefere) LOOP
            IF (rw_tbepr_bens_hst.dschassi <> ' ') AND grvm0001.fn_valida_categoria_alienavel(rw_tbepr_bens_hst.dscatbem) = 'S' THEN
              -- Somente para empréstimo da COOP com origem 3
              IF pr_dsinfaux <> 'BNDES' AND pr_cdorigem = 3 THEN              

                -- Busca o cadastro de emprestimos
                vr_ind_epr := lpad(pr_cdcopemp,03,'0')
                           || lpad(pr_nrdconta,10,'0')
                           || lpad(pr_nrctremp,10,'0');
                -- IDX da Linha
                vr_idx_lcr := lpad(pr_cdcopemp,03,'0')
                           || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');
                -- Somente se encontrar Linha de Credito e a linha for Financiamento (Mod=4)
                -- e (Sub=01) Aquis de bens – veic automotores
                IF vr_tab_craplcr.EXISTS(vr_idx_lcr) AND vr_tab_craplcr(vr_idx_lcr).cdmodali = '04' AND vr_tab_craplcr(vr_idx_lcr).cdsubmod = '01' THEN
                   
                   IF (rw_tbepr_bens_hst.cdsitgrv = 4 AND rw_tbepr_bens_hst.dtdbaixa <= pr_dtrefere ) OR 
                      (rw_tbepr_bens_hst.cdsitgrv = 5 AND rw_tbepr_bens_hst.dtcancel <= pr_dtrefere) THEN
                     /*********************************************************************************
                     ** Alterado o Ident de 1 para 2 conforme solicitação realizada no chamado 541753
                     ** Renato Darosci - Supero
                     ** 24/10/2016
                     *********************************************************************************/

                   	 vr_texto := '            <Inf Tp="0401" Ident="2" />';
                     If vr_tpexecucao = 2 Then
                        vr_seq_relato := vr_seq_relato + 1;
                        -- Procedimento para gravar wrk, para posteriormente descarregar xml
                        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                       pr_cdagenci      => pr_cdagenci,
                                                       pr_nrdconta      => pr_nrdconta,
                                                       pr_nrcpfcgc      => vr_nrcgccpf,
                                                       pr_nmrelatorio   => '3040_INFEMP',
                                                       pr_dtmvtolt      => pr_dtrefere,
                                                       pr_dscritic      => vr_texto,
                                                       pr_Valor         => null,
                                                       pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                       pr_dsxml         => null,
                                                       pr_des_erro      => vr_dscritic);
                        if vr_dscritic is not null then
                           vr_dscritic:= '3040_INFEMP - '||vr_dscritic;
                         raise vr_exc_saida;
                        end if;
                     
                     else
                     	 -- Informação do Empréstimo
                       gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                              ,pr_texto_completo => vr_xml_3040_temp
                                              ,pr_texto_novo     => '            <Inf Tp="0401" Ident="2" />' || chr(10));
                     end if;
                   ELSE
                   
                     IF rw_tbepr_bens_hst.dtmvtolt <= pr_dtrefere THEN
                        
                       vr_texto := '            <Inf Tp="0401" Cd="'  
                                          || rw_tbepr_bens_hst.dschassi || '" />';
                        If vr_tpexecucao = 2 Then
                           vr_seq_relato := vr_seq_relato + 1;
                           -- Procedimento para gravar wrk, para posteriormente descarregar xml
                           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                          pr_cdagenci      => pr_cdagenci,
                                                          pr_nrdconta      => pr_nrdconta,
                                                          pr_nrcpfcgc      => vr_nrcgccpf,
                                                          pr_nmrelatorio   => '3040_INFEMP1',
                                                          pr_dtmvtolt      => pr_dtrefere,
                                                          pr_dscritic      => vr_texto,
                                                          pr_Valor         => null,
                                                          pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                          pr_dsxml         => null,
                                                          pr_des_erro      => vr_dscritic);
                           if vr_dscritic is not null then
                              vr_dscritic:= '3040_INFEMP1 - '||vr_dscritic;
                              raise vr_exc_saida;
                           end if;
                       else
                          -- Informação do Empréstimo
                         gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                                ,pr_texto_completo => vr_xml_3040_temp
                                                ,pr_texto_novo     => vr_texto || chr(10));
                       end if;
                     END IF;

                   END IF;
                END IF;
              END IF;  
            END IF;
          END LOOP;
        END IF;
      END pc_verifica_inf_chassi;

      -- Com base na modaliade retorna o Cosif (Plano Contábil das Instituições do Sistema Financeiro Nacional)
      FUNCTION fn_busca_cosif(pr_cdcooper IN NUMBER
                             ,pr_cdmodali IN VARCHAR2
                             ,pr_inpessoa IN NUMBER
                             ,pr_inddocto IN NUMBER
                             ,pr_dsinfaux IN VARCHAR2) RETURN VARCHAR2 IS
        vr_cdmodali VARCHAR2(4);
      BEGIN
        -- Para Garantia de Operacao
        IF pr_inddocto = 5 THEN
          -- Buscar a Conta COSIF no cadastro do movimento
          IF vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper,03,'0')||pr_dsinfaux) THEN 
            RETURN vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).dsccosif;
          END IF;
        ELSE 
          -- Garantir 4 posições
          vr_cdmodali := to_char(pr_cdmodali,'fm0000');
          -- Adiantamento Depositante
          IF vr_cdmodali LIKE '01%' THEN
            RETURN '1611000';
          -- Cheque especial ou Empréstimos
          ELSIF vr_cdmodali LIKE '02%' THEN 
            RETURN '1612000';
          -- Dsc Chq ou Dsc Tit
          ELSIF vr_cdmodali LIKE '03%' THEN
            RETURN '1613000';
          -- Financiamentos 
          ELSIF vr_cdmodali LIKE '04%' THEN
            RETURN '1621000';
          -- Repasse
          ELSIF vr_cdmodali LIKE '14%' THEN
            RETURN '1439000';
          -- Coobrigacao  
          ELSIF vr_cdmodali LIKE '15%' THEN
            RETURN '3013090';  
          -- Limite Não Utilizado PF
          ELSIF pr_cdmodali = 1901 AND pr_inpessoa = 1 THEN
            RETURN '3098620';
          -- Limite Não Utilizado PJ  
          ELSIF pr_cdmodali = 1901 AND pr_inpessoa = 2 THEN
            -- PJ
            RETURN '3098610';
          -- Cessao de credito  
          ELSIF pr_cdmodali = 1301 THEN
            RETURN '1811000';
          END IF;
        END IF;  
        RETURN '';
      END fn_busca_cosif;
      
      -- Incluir informações do fluxo financeiro
      PROCEDURE pc_gera_fluxo_financeiro(pr_cdcooper IN crapris.cdcooper%TYPE
                                        ,pr_cdcopemp IN crapris.cdcooper%TYPE
                                        ,pr_nrdconta IN crapris.nrdconta%type
                                        ,pr_dtrefere IN crapris.dtrefere%type
                                        ,pr_innivris IN crapris.innivris%type
                                        ,pr_inddocto IN crapris.inddocto%TYPE
                                        ,pr_cdinfadi IN crapris.cdinfadi%TYPE
                                        ,pr_cdmodali IN crapris.cdmodali%type
                                        ,pr_nrctremp IN crapris.nrctremp%type
                                        ,pr_nrseqctr IN crapris.nrseqctr%type
                                        ,pr_dtprxpar IN crapris.dtprxpar%type
                                        ,pr_vlprxpar IN crapris.vlprxpar%type
                                        ,pr_qtparcel IN crapris.qtparcel%type) IS
        -- Observações: Estes campos compreendem a necessidade da Circular 
        -- 3.649, de 09 de abril de 2014, onde os seguintes atributos referentes 
        -- ao fluxo financeiro esperado da operação de crédito deverão ser preenchidos a 
        -- partir da data-base Agosto/2014:
        --  >> "DtaProxParcela" - data da próxima prestação a vencer;
        --  >> "VlrProxParcela" - valor da próxima prestação a vencer;
        --  >> "QtdParcelas" - quantidade de prestações do contrato
        --  Fica dispensado o preenchimento dos campos para as seguintes submodalidades
        --  >> "0101 - Adiantamentos a depositantes"
        --  >> "0213 – Cheque especial"
        --  >> "0214 – Conta garantida"
        --  >> "0204 - Crédito rotativo vinculado a cartão de crédito"
        --  >> "15xx – Coobrigações"
        --  >> "18xx – Títulos de crédito (fora da carteira classificada)"
        --  >> "19xx – Limite"
        --  >> "20xx - Retenção de risco".
        
        -- Somente trataremos as modalidades Cecred:
        -- >> 302 - Dsc Chq 
        -- >> 301 - Dsc Tit
        -- >> 299 - Empréstimo
        -- >> 499 - Financiamento
        
        -- Busca de vencimentos inferiores a v205, ou seja, pelo menos um a vencer
        CURSOR cr_crapvri_vencer IS
          SELECT count(1)
            FROM crapvri vri
           WHERE vri.cdcooper = pr_cdcopemp
             AND vri.nrdconta = pr_nrdconta
             AND vri.dtrefere = pr_dtrefere
             AND vri.innivris = pr_innivris
             AND vri.cdmodali = pr_cdmodali
             AND vri.nrctremp = pr_nrctremp
             AND vri.nrseqctr = pr_nrseqctr
             -- Pelo menos um a vencer
             AND vri.cdvencto < 205;
        vr_qtvencer PLS_INTEGER := 0;
        
        -- Busca de vencimentos de prejuízo
        CURSOR cr_crapvri_prejuz IS
          SELECT 1
            FROM crapvri vri
           WHERE vri.cdcooper = pr_cdcopemp
             AND vri.nrdconta = pr_nrdconta
             AND vri.dtrefere = pr_dtrefere
             AND vri.innivris = pr_innivris
             AND vri.cdmodali = pr_cdmodali
             AND vri.nrctremp = pr_nrctremp
             AND vri.nrseqctr = pr_nrseqctr
             -- Somente de prejuizo
             AND vri.cdvencto >= 310 AND vri.cdvencto <= 330;
        vr_inprejuz PLS_INTEGER := 0;
        
      BEGIN
        -- A Circular preve que as informações de Fluxo sejam enviadas somente
        -- a partir de Agostro de 2014
        IF pr_dtrefere < to_date('01/08/2014','dd/mm/yyyy') THEN
          RETURN;
        END IF;
        -- As informações de fluxo financeiro devem ser omitidas quando
        -- a operação possuir informação adicional de saída (indocto = 2)
        IF pr_inddocto = 2 OR (pr_inddocto = 5 AND pr_cdinfadi = '0301' ) THEN
          -- Sair
          RETURN;
        END IF;
        -- Somente contemplaremos as modalides Cecred ou Inddocto=5 onde qualquer modalidade é aceita
        --   >> 302 - Dsc Chq 
        --   >> 301 - Dsc Tit
        --   >> 299 - Empréstimo
        --   >> 499 - Financiamento
        IF pr_cdmodali NOT IN(299,301,302,499) OR pr_inddocto = 5 THEN
          -- Sair
          RETURN;
        END IF;
        -- Validações abaixo não se aplicam a inddocto=5
        IF pr_inddocto <> 5 THEN 
          -- Buscar se a operação possui pelo menos um vertice de vencimento a vencer
          OPEN cr_crapvri_vencer;
          FETCH cr_crapvri_vencer
           INTO vr_qtvencer;
            CLOSE cr_crapvri_vencer;
          -- As informações de Fluxo Financeiro referem-se a parcelas a vencer
          -- e se a operação possuir 0 vencimentos a vencer, não devemos enviá-las
          IF vr_qtvencer = 0 THEN
            -- Sair
            RETURN;
          END IF;
          -- Para Emprst(299) ou Financ(499)
          IF pr_cdmodali IN(299,499) THEN
            -- Tratar § 1º : Os campos não deverão ser preenchidos no caso de 
            -- operações baixadas como prejuízo, e de avais e fianças prestadas ao cliente.
            OPEN cr_crapvri_prejuz;
            FETCH cr_crapvri_prejuz
             INTO vr_inprejuz;
            CLOSE cr_crapvri_prejuz; 
            -- Somente continuar em caso de não houver prejuizo
            IF vr_inprejuz > 0 THEN
              -- Sair
              RETURN;
            END IF;
          END IF;
        END IF;  
        -- Se chegamos até este pont, então todas as condições foram
        -- aceitas e utilizaremos as informações já preenchidas no risco
        -- para enviarmos ao Fluxo Financeiro - Desde que existam
        IF pr_dtprxpar IS NOT NULL AND NVL(pr_vlprxpar,0) > 0 THEN

           vr_Texto := ' DtaProxParcela="' || to_char(pr_dtprxpar,'YYYY-MM-DD')||'"'
                                                       || ' VlrProxParcela="' || replace(to_char(pr_vlprxpar,'fm99999999999999990D00'),',','.')||'"';
           If vr_tpexecucao = 2 Then
              vr_seq_relato := vr_seq_relato + 1;
              -- Procedimento para gravar wrk, para posteriormente descarregar xml
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => pr_nrdconta,
                                             pr_nrcpfcgc      => vr_nrcgccpf,
                                             pr_nmrelatorio   => '6 3040_FLXFIN',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dscritic      => vr_Texto,
                                             pr_Valor         =>  null,
                                             pr_seq_relato    => vr_seq_relato, -- nrctremp
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                 vr_dscritic:= '6 3040_FLXFIN - '||vr_dscritic;
                 raise vr_exc_saida;
              end if;
           else
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => ' DtaProxParcela="' || to_char(pr_dtprxpar,'YYYY-MM-DD')||'"'
                                                        || ' VlrProxParcela="' || replace(to_char(pr_vlprxpar,'fm99999999999999990D00'),',','.')||'"');
           end if;
        END IF;
        IF NVL(pr_qtparcel,0) > 0 THEN
        
          vr_Texto := ' QtdParcelas="' || to_char(pr_qtparcel,'fm9990')||'"';
            If vr_tpexecucao = 2 Then
               vr_seq_relato := vr_seq_relato + 1;
               -- Procedimento para gravar wrk, para posteriormente descarregar xml
               pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                              pr_cdagenci      => pr_cdagenci,
                                              pr_nrdconta      => pr_nrdconta,
                                              pr_nrcpfcgc      => vr_nrcgccpf,
                                              pr_nmrelatorio   => '7 3040_PARC',
                                              pr_dtmvtolt      => pr_dtrefere,
                                              pr_dscritic      => vr_Texto,
                                              pr_Valor         =>  null,
                                              pr_seq_relato    => vr_seq_relato, -- nrctremp
                                              pr_dsxml         => null,
                                              pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                 vr_dscritic:= '7 3040_PARC - '||vr_dscritic;
                 raise vr_exc_saida;
              end if;
          else
             -- Fim tratamento WRK
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => vr_Texto);
          end if;
        END IF;        
      END;
      
      -- Verificação / envio do Ente Consignante
      PROCEDURE pc_inf_ente_consignante(pr_cdcooper IN crapris.cdcooper%TYPE
                                       ,pr_nrdconta IN crapris.nrdconta%type
                                       ,pr_nrctremp IN crapris.nrctremp%type
                                       ,pr_cdmodali IN crapris.cdmodali%type
                                       ,pr_dsinfaux IN crapris.dsinfaux%TYPE) IS
        -- Observações: Informação do ente consignante atrelado à operação de crédito
        --
        --  Atributos de <Inf>: Tp, Ident e Cd.
        --  Onde: 
        --    Tp: tipo da informação adicional – 15XX, onde XX deve ser:
        --        01  público 
        --        02  privado 
        --        03  INSS 
        --
        --    Ident: CNPJ do Ente Consignante (com 14 dígitos).
        --
        --    Cd: Informação de Situação da Operação. Deve ser omitido se a operação
        --        estiver em seu curso normal; e deve ser preenchido com “1” se a 
        --        operação estiver desconsignada.
        -- 
        -- Somente trataremos as modalidades Cecred:
        -- >> 299 - Empréstimo
        -- >> 499 - Financiamento
        
        -- E dentre as mesmas, iremos na linha de crédito para verificar se a 
        -- a mesma é uma linha com consignação em Folha de Pagamento
        
        -- Testar se a linha de crédito do Empréstimo/Financiamento é 
        -- Consignação em Folha de Pagamento e já trazer a empresa
        CURSOR cr_consigna IS
          SELECT emp.nrdocnpj
                ,ttl.nrcpfemp
                ,epr.cdempres
                ,epr.inprejuz
            FROM crapttl ttl
                ,crapemp emp
                ,craplcr lcr
                ,crapepr epr
           WHERE epr.cdcooper = lcr.cdcooper
             AND epr.cdlcremp = lcr.cdlcremp 
             AND epr.cdcooper = emp.cdcooper
             AND epr.cdempres = emp.cdempres
             AND epr.cdcooper = ttl.cdcooper
             AND epr.nrdconta = ttl.nrdconta
             AND ttl.idseqttl = 1 --> Somente o titular
             AND epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp 
             AND lcr.tpdescto = 2; --> 2-Consig. Folha
        rw_consigna cr_consigna%ROWTYPE;
        
        -- Variáveis
        vr_nrcpfemp    VARCHAR2(20);
        
      BEGIN
        -- Empréstimos BNDES não são contemplados
        IF pr_dsinfaux = 'BNDES' THEN
          RETURN;
        END IF;
        -- Somente contemplaremos as modalides Cecred:
        --   >> 299 - Empréstimo
        --   >> 499 - Financiamento    
        IF pr_cdmodali IN(299,499) THEN
          -- Testar se a linha é de consignação em folha
          -- e quando for, já trazer também os dados da empresa
          OPEN cr_consigna;
          FETCH cr_consigna
           INTO rw_consigna;
          -- Se encontrou, é consignação
          IF cr_consigna%FOUND THEN
            CLOSE cr_consigna;
            -- Para casos de empréstimos em prejuizo
            IF rw_consigna.inprejuz = 1 THEN
              
               If vr_tpexecucao = 2 Then
                  vr_seq_relato := vr_seq_relato + 1;
                vr_texto := '            <Inf Tp="1502" Cd="1"/>';
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => pr_nrdconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => '3040_INFPREJ',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                                 pr_Valor         =>  null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => null,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                      vr_dscritic:= '3040_INFPREJ - '||vr_dscritic;
                      raise vr_exc_saida;
                   end if;
              else
                -- Enviavmos a informação adicional com Cd=1, que significa que a operação foi desconsignada
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => '            <Inf Tp="1502" Cd="1"/>'|| chr(10));  
              end if;            
            ELSE
               
               -- Se o CNPJ da empresa não foi informado
               IF nvl(rw_consigna.nrdocnpj,0) = 0 THEN
                 -- Se o documento do empregador não foi informado
                 IF nvl(rw_consigna.nrcpfemp,0) = 0 THEN
                   -- Deixa o documento em branco
                   vr_nrcpfemp := NULL;
                 ELSE 
                   -- Verifica se o empregador é PF
                   IF NVL(rw_consigna.cdempres,0) = 9998 THEN
                     -- Tratar como CPF
                     vr_nrcpfemp := LPAD(rw_consigna.nrcpfemp,11,'0');
                   ELSE 
                     -- TRatar como CNPJ
                     vr_nrcpfemp := LPAD(rw_consigna.nrcpfemp,14,'0');
                   END IF;
                 END IF;
               ELSE
                 -- Tratar como CNPJ
                 vr_nrcpfemp := LPAD(rw_consigna.nrcpfemp,14,'0');
               END IF;
                   
               If vr_tpexecucao = 2 Then
                  vr_seq_relato := vr_seq_relato + 1;
                --SD#855059
                IF vr_nrcpfemp IS NULL THEN
                  vr_texto := '            <Inf Tp="1502" Cd="1"/>';
                else
                  vr_texto := '            <Inf Tp="1502" Ident="' || vr_nrcpfemp || '"/>';
                end if;
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => pr_nrdconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => '3040_INFPREJ1',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                                 pr_dscritic      => vr_texto,
                                                 pr_Valor         =>  null,
                                                 pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => null,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                    vr_dscritic:= '3040_INFPREJ1 - '||vr_dscritic;
                    raise vr_exc_saida;
                  end if;
              else
                -- Devemos enviar a informação adicional com o CNPJ do Ente Consignante
                --SD#855059
                if vr_nrcpfemp IS NULL then
                  -- Enviamos a informação adicional com Cd=1, que significa que a operação foi desconsignada
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                         ,pr_texto_completo => vr_xml_3040_temp
                                         ,pr_texto_novo     => '            <Inf Tp="1502" Cd="1"/>'|| chr(10));
                else
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                         ,pr_texto_completo => vr_xml_3040_temp
                                         ,pr_texto_novo     => '            <Inf Tp="1502" Ident="'||vr_nrcpfemp||'"/>'|| chr(10));
                end if;
              end if;
            end if;
          ELSE
            CLOSE cr_consigna;
          END IF;
        END IF;
      END;    
      
      -- **
      -- Verifica Ativo Problemático - Daniel(AMcom)
      PROCEDURE pc_verif_ativo_problematico(pr_cdcooper    IN NUMBER       -- Cooperativa
                                           ,pr_nrdconta    IN NUMBER       -- Conta
                                           ,pr_nrctremp    IN NUMBER       -- Contrato
                                           ,pr_atvprobl   OUT NUMBER       -- Identificador de Ativo Problemático
                                           ,pr_reestrut   OUT NUMBER       -- 1-ComReestruturação 0-SemReestruturação
                                           ,pr_dtatvprobl OUT VARCHAR2     -- Data da Reestruturação
                                           ,pr_cdcritic   OUT PLS_INTEGER  -- Código da crítica
                                           ,pr_dscritic   OUT VARCHAR2) IS -- Erros do processo
        -- ** Motivos contemplados(TBGEN_MOTIVO) ** --
        -- select * from tbgen_motivo where cdproduto = 42
        --
        -- 57 - REESTRUTURAÇÃO
        -- 58 - ATRASO > 90 DIAS
        -- 59 - PREJUIZO
        -- 60 - SOCIO FALECIDO
        -- 61 - ACAO CONTRA
        -- 62 - COOPERADO PRESO
        -- 63 - FALENCIA PJ
        -- 64 - RECUPERACAO JUDICIAL PJ
        -- 65 - OUTROS

        -- Variáveis
        vr_cdcooper     NUMBER(5)    := NULL;
        vr_nrdconta     NUMBER(10)   := NULL;
        vr_nrctremp     NUMBER(10)   := NULL;
        vr_dtinreg      DATE         := NULL;
        vr_cdmotivo     NUMBER(5)    := NULL;
        vr_idtipo_envio NUMBER(5)    := NULL;
        vr_dsobservacao VARCHAR2(100) := NULL;


        -- Cursor REESTRUTURAÇÃO
        CURSOR cr_atvprb_reest(pr_cdcooper IN NUMBER
                              ,pr_nrdconta IN NUMBER
                              ,pr_nrctremp IN NUMBER) IS
          SELECT dtinreg
               , cdcooper
               , nrdconta
               , nrctremp
               , cdmotivo
               , idtipo_envio
               , idatvprobl
               , idreestrut
            FROM (SELECT DISTINCT
                         ris.cdcooper
                       , ris.nrdconta
                       , ris.nrctremp
                       , 57 cdmotivo -- 57 - REESTRUTURAÇÃO
                       , 1 idtipo_envio
                       , 1 idatvprobl
                       , 1 idreestrut
                       , ris.dtinictr dtinreg
                    FROM crapris ris, crapepr epr
                   WHERE epr.idquaprc IN (3, 4) -- Somente contrato 3-Renegociação
                                                --                  4-Composição de Dívida
                     AND ris.cdcooper  = epr.cdcooper
                     AND ris.nrdconta  = epr.nrdconta
                     AND ris.nrctremp  = epr.nrctremp
                     AND ris.cdcooper  = pr_cdcooper
                     AND ris.nrdconta  = pr_nrdconta
                     AND ris.nrctremp  = pr_nrctremp
                     AND ris.dtrefere  = pr_dtultdma)
           WHERE dtinreg IS NOT NULL
             AND ROWNUM = 1
        ORDER BY dtinreg;
         rw_atvprb_reest cr_atvprb_reest%ROWTYPE;

        -- Cursor PRINCIPAL
        CURSOR cr_atvprb(pr_cdcooper IN NUMBER
                        ,pr_nrdconta IN NUMBER
                        ,pr_nrctremp IN NUMBER) IS
          SELECT dtinreg
               , cdcooper
               , nrdconta
               , nrctremp
               , cdmotivo
               , idtipo_envio
               , idatvprobl
               , idreestrut
               , dsobservacao
            FROM (SELECT DISTINCT
                         ris.cdcooper
                       , ris.nrdconta
                       , ris.nrctremp
                       , 58 cdmotivo -- 58 - ATRASO > 90 DIAS
                       , 1 idtipo_envio
                       , 1 idatvprobl
                       , 0 idreestrut
                       , ris.dtinictr dtinreg
                       , null dsobservacao
                  FROM crapris ris, crapepr epr
                  -- Verifica se o contrato está atraso a mais de 90 dias ou se não foi quitado após estar em 90 dias de atraso
                 WHERE (ris.qtdiaatr > 90 or (ris.qtdiaatr >= 30 
                                         and exists(select distinct 1
                                                      from tbhist_ativo_probl his
                                                     where his.cdcooper  = ris.cdcooper
                                                       and his.nrdconta  = ris.nrdconta
                                                       and his.nrctremp  = ris.nrctremp
                                                       and his.cdmotivo  = 58 
                                                       and to_char(his.dthistreg, 'YYYYMM') = to_char(ADD_MONTHS(pr_dtultdma, -1), 'YYYYMM'))))
                   AND epr.idquaprc(+) NOT IN (3, 4) -- Somente contrato diferente 3-Renegociação
                                                     --                            4-Composição de Dívida
                   AND ris.cdcooper  = epr.cdcooper(+)
                   AND ris.nrdconta  = epr.nrdconta(+)
                   AND ris.nrctremp  = epr.nrctremp(+)
                   AND ris.cdcooper  = pr_cdcooper
                   AND ris.nrdconta  = pr_nrdconta
                   AND ris.nrctremp  = pr_nrctremp
                   AND ris.dtrefere  = pr_dtultdma
                   AND ris.innivris <> 10 -- Prejuízo
                 UNION
                SELECT DISTINCT
                         ris.cdcooper
                       , ris.nrdconta
                       , ris.nrctremp
                       , 59 cdmotivo -- 59 - PREJUIZO
                       , 1 idtipo_envio
                       , 1 idatvprobl
                       , 0 idreestrut
                       , ris.dtinictr dtinreg
                       , null dsobservacao                       
                  FROM crapris ris, crapepr epr
                 WHERE epr.idquaprc(+) NOT IN (3, 4) -- Somente contrato diferente 3-Renegociação
                                                     --                            4-Composição de Dívida
                   AND ris.cdcooper  = epr.cdcooper(+)
                   AND ris.nrdconta  = epr.nrdconta(+)
                   AND ris.nrctremp  = epr.nrctremp(+)
                   AND ris.cdcooper  = pr_cdcooper
                   AND ris.nrdconta  = pr_nrdconta
                   AND ris.nrctremp  = pr_nrctremp
                   AND ris.dtrefere  = pr_dtultdma
                   AND ris.innivris  >= 10
                 UNION
                SELECT DISTINCT
                         a.cdcooper
                       , a.nrdconta
                       , pr_nrctremp nrctremp
                       , 60 cdmotivo -- 60 - SOCIO FALECIDO
                       , 1 idtipo_envio
                       , 1 idatvprobl
                       , 0 idreestrut
                       , a.dtasitct dtinreg
                       , null dsobservacao                       
                  FROM crapass a
                 WHERE a.cdcooper = pr_cdcooper
                   AND a.nrdconta = pr_nrdconta
                   AND a.cdsitdct = 8
                 UNION
                SELECT DISTINCT
                       cyc.cdcooper
                     , cyc.nrdconta
                     , cyc.nrctremp
                     , 61 cdmotivo -- 61 - ACAO CONTRA
                     , 1 idtipo_envio
                     , 1 idatvprobl
                     , 0 idreestrut
                     , nvl(cyc.dtinclus, cyc.dtaltera) dtinreg
                     , null dsobservacao                     
                  from crapcyc cyc
                 where cyc.cdmotcin in (2,7)
                   and cyc.cdcooper = pr_cdcooper
                   AND cyc.nrdconta = pr_nrdconta
                   AND cyc.nrctremp = pr_nrctremp -- Ativo
                 UNION
                SELECT DISTINCT
                         ap.cdcooper
                       , ap.nrdconta
                       , ap.nrctremp
                       , ap.cdmotivo
                       , 2 idtipo_envio
                       , 1 idatvprobl
                       , 0 idreestrut
                       , ap.dtinclus dtinreg
                       , ap.dsobserv dsobservacao                       
                  FROM TBCADAST_ATIVO_PROBL AP
                 WHERE ap.cdcooper = pr_cdcooper
                   AND ap.nrdconta = pr_nrdconta
                   AND ap.nrctremp = decode(ap.nrctremp, 0, ap.nrctremp, pr_nrctremp)
                   AND ap.dtexclus is null
                   AND ap.cdmotivo IN( 60  -- SOCIO FALECIDO MANUAL
                                     , 62  -- COOPERADO PRESO
                                     , 63  -- FALENCIA PJ
                                     , 64  -- RECUPERACAO JUDICIAL PJ
                                     , 65) -- OUTROS
                   AND ap.idativo  = 1) -- Registro Ativo
           WHERE dtinreg IS NOT NULL
             AND ROWNUM = 1
        ORDER BY dtinreg;
        rw_atvprb cr_atvprb%ROWTYPE;

      BEGIN
           
       -- ** INÍCIO VERIFICAÇÃO ATIVO PROBLEMÁTICO ** --
       -- Inicializa variáveis de retorno
       pr_atvprobl   := 0;
       pr_reestrut   := 0;
       pr_dtatvprobl := NULL;
       pr_cdcritic   := NULL;
       pr_dscritic   := NULL;

       OPEN cr_atvprb_reest(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp);
      FETCH cr_atvprb_reest
       INTO rw_atvprb_reest;
      CLOSE cr_atvprb_reest;

      -- Verifica se existe Ativo Problemático para Reestruturação
      if rw_atvprb_reest.cdcooper is not null then
        -- Move informações para as variáveis de RETORNO
        pr_atvprobl   := rw_atvprb_reest.idatvprobl;
        pr_reestrut   := rw_atvprb_reest.idreestrut;
        pr_dtatvprobl := TO_CHAR(rw_atvprb_reest.dtinreg, 'YYYY-MM-DD');
        -- Move informações para as variáveis de INSERT
        vr_cdcooper     := rw_atvprb_reest.cdcooper;
        vr_nrdconta     := rw_atvprb_reest.nrdconta;
        vr_nrctremp     := rw_atvprb_reest.nrctremp;
        vr_dtinreg      := rw_atvprb_reest.dtinreg;
        vr_cdmotivo     := rw_atvprb_reest.cdmotivo;
        vr_idtipo_envio := rw_atvprb_reest.idtipo_envio;
        vr_dsobservacao := rw_atvprb.dsobservacao;        
      end if;

      -- Se não encontrou REESTRUTURAÇÃO, verifica os outros motivos
      if pr_reestrut = 0 and pr_atvprobl = 0 then
        --
        OPEN cr_atvprb(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
       FETCH cr_atvprb
        INTO rw_atvprb;
       CLOSE cr_atvprb;

        -- Move informações para as variáveis de RETORNO
        pr_atvprobl   := rw_atvprb.idatvprobl;
        pr_reestrut   := 0;
        pr_dtatvprobl := NULL;
         -- Move informações para as variáveis de INSERT
        vr_cdcooper     := rw_atvprb.cdcooper;
        vr_nrdconta     := rw_atvprb.nrdconta;
        vr_nrctremp     := rw_atvprb.nrctremp;
        vr_dtinreg      := rw_atvprb.dtinreg;
        vr_cdmotivo     := rw_atvprb.cdmotivo;
        vr_idtipo_envio := rw_atvprb.idtipo_envio;
        vr_dsobservacao := rw_atvprb.dsobservacao;
      end if;
       -- 
       
        --
        -- Gravar HISTORICO se existir um registro de Ativo Problemático
        if pr_atvprobl = 1 then
          BEGIN
              INSERT INTO TBHIST_ATIVO_PROBL(cdcooper
                                            ,nrdconta
                                            ,nrctremp
                                            ,dtinreg
                                            ,dthistreg
                                            ,cdmotivo
                                            ,dsobserv
                                            ,idtipo_envio)
                                      VALUES (vr_cdcooper
                                             ,vr_nrdconta
                                             ,vr_nrctremp
                                             ,vr_dtinreg
                                             ,pr_dtultdma  -- dthistreg
                                             ,vr_cdmotivo
                                             ,vr_dsobservacao
                                             ,vr_idtipo_envio);
        --
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
            WHEN OTHERS THEN
              pr_cdcritic := 0;
              pr_dscritic := 'Erro INSERT HISTORICO ATIVO PROBLEMATICO: '||SQLERRM;
              -- Efetuar rollback
              ROLLBACK;
          END;
        end if;
        --
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro PC_VERIF_ATIVO_PROBLEMATICO: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
      END pc_verif_ativo_problematico;
      
      -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
      PROCEDURE pc_busca_coddindx(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta IN crapris.nrdconta%TYPE
                                 ,pr_nrctremp IN crapris.nrctremp%TYPE
                                 ,pr_cdmodali IN crapris.cdmodali%TYPE
                                 ,pr_inddocto IN crapris.inddocto%TYPE
                                 ,pr_dsinfaux IN crapris.dsinfaux%TYPE
                                 ,pr_tpemprst IN crapepr.tpemprst%TYPE
                                 ,pr_cddindex IN crawepr.cddindex%TYPE
                                 ,pr_cdorigem IN crapris.cdorigem%TYPE
                                 ,pr_coddindx OUT PLS_INTEGER
                                 ,pr_stperidx OUT VARCHAR2) IS
      BEGIN
        pr_coddindx := 0;
        pr_stperidx := '';
        
        -- Para Garantias PRestadas 
        IF pr_inddocto = 5 AND vr_tab_mvto_garant_prest.exists(lpad(pr_cdcooper,03,'0')||pr_dsinfaux) THEN 
          -- Buscar indexador e percentual do cadastro de movimento
          pr_coddindx := vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).dsindexa;
          pr_stperidx := ' PercIndx="'||replace(to_char(vr_tab_mvto_garant_prest(lpad(pr_cdcooper,03,'0')||pr_dsinfaux).prindexa,'fm9990D0000000'),',','.')||'"';
        ELSE 
          -- Para 0201 - Cheq Especial / 0101 - Adiant. Deposit / 1901 - Limite não Utilizado
          IF pr_cdmodali IN (0201,0101,1901) THEN
            pr_coddindx := 21;
            pr_stperidx := ' PercIndx="100"';
          ELSE -- Todas outras

            -- 0299=Emprst, 0499=Financ e Origem 3 e Emprestimo Pos-Fixado
            IF pr_cdmodali IN(0299,0499) AND pr_cdorigem = 3 AND pr_tpemprst = 2 THEN
              IF pr_cddindex = 1 THEN -- CDI
                pr_coddindx := 31;
              ELSIF pr_cddindex = 2 THEN -- TR
                pr_coddindx := 21;
              END IF;
              pr_stperidx := ' PercIndx="100"';
            ELSE
              -- Validar se está no BNDES/FINAME
              vr_ind_ebn := lpad(pr_cdcooper,3,'0')||lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
              IF vr_tab_crapebn.EXISTS(vr_ind_ebn) THEN
                pr_coddindx := vr_tab_crapebn(vr_ind_ebn).cdindxdr;
              ELSE
            pr_coddindx := 11;
              END IF;
            pr_stperidx := ' PercIndx="0"';
          END IF;

        END IF;
        END IF;
      END pc_busca_coddindx;

      -- Busca a identificacao da sub-modalidade do emprestimo
      FUNCTION fn_busca_submodal(pr_cdcooper IN crapris.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                ,pr_cdmodali IN crapris.cdmodali%TYPE
                                ,pr_cdorigem IN crapris.cdorigem%TYPE
                                ,pr_dsinfaux IN crapris.dsinfaux%TYPE) RETURN VARCHAR2 IS
      BEGIN
        -- Sair em caso de empréstimo BNDES ou Origem <> 3
        IF pr_dsinfaux = 'BNDES' OR pr_cdorigem <> 3 THEN
          RETURN NULL;
        ELSE  
          -- monta a chave para a busca do emprestimo
          vr_ind_epr := lpad(pr_cdcooper,03,'0')||lpad(pr_nrdconta,10,'0')||lpad(pr_nrctremp,10,'0');
          -- IDX da Linha
          vr_idx_lcr := lpad(pr_cdcooper,03,'0')
                     || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');
          -- Se não existir Linha de Credito para o EPR
          IF NOT vr_tab_craplcr.EXISTS(vr_idx_lcr) THEN
            -- Se não existir a linha deve retornar Sem SubModal
            RETURN NULL;
          ELSE
            -- Se a linha de credito possuir modalidade s submodalidade
            IF trim(vr_tab_craplcr(vr_idx_lcr).cdmodali) IS NOT NULL AND
               trim(vr_tab_craplcr(vr_idx_lcr).cdsubmod) IS NOT NULL THEN
              -- Concatena as duas e retorna a submodalidade
              RETURN SUBSTR(vr_tab_craplcr(vr_idx_lcr).cdmodali,1,2) || SUBSTR(vr_tab_craplcr(vr_idx_lcr).cdsubmod,1,2);
            ELSE
              -- Usar a Modalidade
              RETURN to_char(pr_cdmodali,'fm0000');
            END IF;
          END IF;
        END IF;    
      END fn_busca_submodal;

      -- Envio da operação de saída enviada
      PROCEDURE pc_imprime_saida(pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_innivris crapris.innivris%TYPE
                                ,pr_idxsaida IN VARCHAR2) IS
        vr_dtvencop DATE := NULL;
        vr_stdtvenc VARCHAR(100);
      BEGIN
        vr_stdtvenc := '';

        If vr_tpexecucao = 2 Then
           vr_seq_relato := vr_seq_relato + 1;
          vr_texto := '        <Op';
           -- Procedimento para gravar wrk, para posteriormente descarregar xml
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_cdagenci      => pr_cdagenci,
                                          pr_nrdconta      => vr_nrdaconta,
                                          pr_nrcpfcgc      => vr_nrcgccpf,
                                          pr_nmrelatorio   => '3040_NVOPR',
                                          pr_dtmvtolt      => pr_dtrefere,
                                          pr_dscritic      => vr_texto,
                                          pr_Valor         =>  null,
                                          pr_seq_relato    => vr_seq_relato, -- nrctremp
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_dscritic);
           if vr_dscritic is not null then
              vr_dscritic:= '3040_NVOPR - '||vr_dscritic;
              raise vr_exc_saida;
           end if;
        else
          -- Iniciar nova Operação
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => '        <Op');
        end if;
        
        -- Para juridica, enviar CNPJ completo
        IF vr_tab_saida(pr_idxsaida).inpessoa <> 1 THEN 

          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            vr_texto := ' DetCli="' || to_char(vr_tab_saida(pr_idxsaida).nrcpfcgc,'fm00000000000000')||'"';
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_DETCLI',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
             vr_dscritic:= '3040_DETCLI - '||vr_dscritic;
             raise vr_exc_saida;
            end if;
          else
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => ' DetCli="' || to_char(vr_tab_saida(pr_idxsaida).nrcpfcgc,'fm00000000000000')||'"');
          end if;
        END IF; 
          
        -- Trecho comum      
        vr_caracesp := '';
        vr_innivris := pr_innivris;

        -- Reseta variaveis
        vr_tpemprst := NULL;
        vr_cddindex := NULL;

        -- Empréstimo da base Cecred
        IF vr_tab_saida(pr_idxsaida).cdmodali IN(0299,0499) AND vr_tab_saida(pr_idxsaida).cdorigem = 3 THEN
          vr_ind_epr  :=  lpad(vr_tab_saida(pr_idxsaida).cdcooper,03,'0') ||lpad(vr_tab_saida(pr_idxsaida).nrdconta,10,'0')||lpad(vr_tab_saida(pr_idxsaida).nrctremp,10,'0');
          IF vr_tab_crapepr.EXISTS(vr_ind_epr) THEN
            vr_tpemprst := vr_tab_crapepr(vr_ind_epr).tpemprst;
            vr_cddindex := vr_tab_crapepr(vr_ind_epr).cddindex;
          END IF;
        END IF;

        -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
        pc_busca_coddindx(pr_cdcooper => vr_tab_saida(pr_idxsaida).cdcooper
                         ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                         ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                         ,pr_cdmodali => vr_tab_saida(pr_idxsaida).cdmodali
                         ,pr_inddocto => vr_tab_saida(pr_idxsaida).inddocto
                         ,pr_dsinfaux => vr_tab_saida(pr_idxsaida).dsinfaux
                         ,pr_tpemprst => vr_tpemprst
                         ,pr_cddindex => vr_cddindex
                         ,pr_cdorigem => vr_tab_saida(pr_idxsaida).cdorigem
                         ,pr_coddindx => vr_coddindx
                         ,pr_stperidx => vr_stperidx);

        -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
        vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);

        -- Busca a modalidade com base nos emprestimos
        vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_saida(pr_idxsaida).cdmodali
                                                ,vr_tab_saida(pr_idxsaida).cdcooper
                                                ,vr_tab_saida(pr_idxsaida).nrdconta
                                                ,vr_tab_saida(pr_idxsaida).nrctremp
                                                ,vr_tab_saida(pr_idxsaida).inpessoa
                                                ,vr_tab_saida(pr_idxsaida).cdorigem
                                                ,vr_tab_saida(pr_idxsaida).dsinfaux);
        -- Busca a organização
        vr_dsorgrec := fn_busca_dsorgrec(vr_tab_saida(pr_idxsaida).cdcooper
                                        ,vr_tab_saida(pr_idxsaida).cdmodali
                                        ,vr_tab_saida(pr_idxsaida).nrdconta
                                        ,vr_tab_saida(pr_idxsaida).nrctremp
                                        ,vr_tab_saida(pr_idxsaida).cdorigem
                                        ,vr_tab_saida(pr_idxsaida).dsinfaux);
                              
        -- Com base na modalidade encontrada retornar o Cosif
        vr_ctacosif := fn_busca_cosif(vr_tab_saida(pr_idxsaida).cdcooper
                                     ,vr_cdmodali
                                     ,vr_tab_saida(pr_idxsaida).inpessoa
                                     ,vr_tab_saida(pr_idxsaida).inddocto
                                     ,vr_tab_saida(pr_idxsaida).dsinfaux);     
        
        -- Para Adiantamento Depositante, Limite não Utilizado, Cheque Especial, Desconto de Titulos, Desconto de Cheques, Emprestimo OU Inddocto=5
        IF vr_tab_saida(pr_idxsaida).cdmodali IN(0101,1901,0201,0301,0302,0499,0299) OR vr_tab_saida(pr_idxsaida).inddocto=5 THEN
          vr_dtvencop := vr_tab_saida(pr_idxsaida).dtvencop;
        END IF; -- modalidade
        
        -- 0101 - Para adiantamento depositante, utilizar o CL no calculo 
        IF vr_tab_saida(pr_idxsaida).cdmodali = 0101 AND vr_tab_saida(pr_idxsaida).inddocto <> 5 THEN
          -- Usar Taxa Efetiva Anual - TAB0004
          vr_txeanual := pr_txeanual;
        
          -- Para:
          -- 0302 - Dsc Chq
          -- 0301 - Dsc Tit
          -- 0201 - Chq Especial
          -- 1901 - Lim Não Utzd
          -- 0299 - Empréstimos
          -- 0499 - Financiamentos
          -- OU Indocto=5
        ELSIF vr_tab_saida(pr_idxsaida).cdmodali IN(0302,0301,0201,1901,0299,0499) OR vr_tab_saida(pr_idxsaida).inddocto=5  THEN 
          -- Buscar Taxa Efetiva
          vr_txeanual := fn_busca_taxeft(vr_tab_saida(pr_idxsaida).cdcooper
                                        ,vr_tab_saida(pr_idxsaida).cdmodali
                                        ,vr_tab_saida(pr_idxsaida).nrdconta
                                        ,vr_tab_saida(pr_idxsaida).nrctremp
                                        ,vr_tab_saida(pr_idxsaida).inddocto
                                        ,vr_tab_saida(pr_idxsaida).inpessoa
                                        ,vr_tab_saida(pr_idxsaida).dsinfaux
                                        ,vr_tab_saida(pr_idxsaida).cdorigem);
        ELSE
          -- Sem taxa
          vr_txeanual := 0;
        END IF;
        -- Para prejuizo a taxa anual é utilizado fixo 1,00%
        --   Consensado com Roberto e Mirtes em 20/09/2010 
        IF vr_tab_saida(pr_idxsaida).innivris = 10  THEN
          vr_txeanual := ROUND((POWER(1 + (1 / 100),12) - 1) * 100,2);
        END IF;
        
        IF vr_dtvencop IS NOT NULL THEN
          vr_stdtvenc := ' DtVencOp="' || NVL(to_char(vr_dtvencop,'YYYY-MM-DD'),'0000-00-00') || '"';        
        END IF;
        
        -- Numero do contrato formatado para o arquivo 3040
        vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => vr_tab_saida(pr_idxsaida).cdcooper
                                                        ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                                        ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                                                        ,pr_cdmodali => vr_cdmodali);
        -- Para inddocto=5 
        IF vr_tab_saida(pr_idxsaida).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(lpad(vr_tab_saida(pr_idxsaida).cdcooper,03,'0')||vr_tab_saida(pr_idxsaida).dsinfaux) THEN
          -- Buscar a natureza e caracteristica no cadastro do movimento
          vr_cdnatuop := vr_tab_mvto_garant_prest(lpad(vr_tab_saida(pr_idxsaida).cdcooper,03,'0')||vr_tab_saida(pr_idxsaida).dsinfaux).dsnature;
          vr_caracesp := vr_tab_mvto_garant_prest(lpad(vr_tab_saida(pr_idxsaida).cdcooper,03,'0')||vr_tab_saida(pr_idxsaida).dsinfaux).dscarces;
        ELSE
          vr_cdnatuop := '01';  
          vr_caracesp := '';
        END IF;
        
        -- **
        -- Verifica Ativo Problemático - Daniel(AMcom)
        pc_verif_ativo_problematico(pr_cdcooper => vr_tab_saida(pr_idxsaida).cdcooper -- Cooperativa
                                   ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta -- Conta
                                   ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp -- Contrato
                                   ,pr_atvprobl => vr_atvprobl                        -- Identificador de Ativo Problemático
                                   ,pr_reestrut => vr_reestrut                        -- 1-Reestruturação de crédito 0-Outros
                                   ,pr_dtatvprobl => vr_dtatvprobl                    -- Data do contrato de Reestruturação
                                   ,pr_cdcritic => vr_cdcritic                        -- Código da crítica
                                   ,pr_dscritic => vr_dscritic);                      -- Erros do processo
                                   
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          -- Se identificou como Ativo Problemático, envia CaracEspecial=19
          IF vr_atvprobl = 1 THEN
            IF vr_caracesp IS NOT NULL THEN
              vr_caracesp := vr_caracesp||';19';
            ELSE
              vr_caracesp := '19';
            END IF;
          END IF;
        END IF;
        

        vr_cep_3040 := fn_cepende(vr_tab_saida(pr_idxsaida).cdcooper
                                 ,vr_tab_saida(pr_idxsaida).sbcpfcgc
                                 ,vr_tab_saida(pr_idxsaida).inddocto
                                 ,vr_tab_saida(pr_idxsaida).dsinfaux,pr_flbbndes);
        
       vr_texto := ' Contrt="' || TRIM(vr_nrcontrato_3040) || '"' 
                                                    || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                    || ' Cosif="' || vr_ctacosif || '"' 
                                                    || ' OrigemRec="' || vr_dsorgrec || '"' -- Era fixo '0199', agora, retorna do pc_busca_modalidade
                                                    || ' Indx="' || vr_coddindx || '"' 
                                                    || vr_stperidx 
                                                    || ' VarCamb="'||fn_varcambial(vr_tab_saida(pr_idxsaida).cdcooper,vr_tab_saida(pr_idxsaida).inddocto,vr_tab_saida(pr_idxsaida).dsinfaux)||'"' 
                                                    || ' CEP="' ||vr_cep_3040 || '"'
                                                    || ' VlrContr="' || replace(to_char(vr_tab_saida(pr_idxsaida).vldivida,'fm99999999999999990D00'),',','.') || '"' 
                                                    || ' TaxEft="' || replace(to_char(vr_txeanual,'fm990D00'),',','.') || '"' 
                                                    || ' DtContr="' || to_char(vr_tab_saida(pr_idxsaida).dtinictr,'yyyy-mm-dd') || '"' 
                                                    || ' NatuOp="'||vr_cdnatuop||'"'
                                                    || vr_stdtvenc
                                                    || ' ClassOp="' || vr_cloperis || '"' 
                                                    || ' CaracEspecial="' || vr_caracesp ||'"';
        If vr_tpexecucao = 2 Then
          vr_seq_relato := vr_seq_relato + 1;
          -- Procedimento para gravar wrk, para posteriormente descarregar xml
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => vr_nrdaconta,
                                         pr_nrcpfcgc      => vr_nrcgccpf,
                                         pr_nmrelatorio   => '3 3040_CONT',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dscritic      => vr_texto,
                                         pr_Valor         =>  null,
                                         pr_seq_relato    => vr_seq_relato, -- nrctremp
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
            vr_dscritic:= '3040_CONT - '||vr_dscritic;
            raise vr_exc_saida;
          end if;
        Else        
          -- Enviar detalhes do contrato
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => vr_texto);
        End If; -- Fim tratamento WRK
        
        -- Tratar campos do Fluxo Financeiro
        pc_gera_fluxo_financeiro(pr_cdcooper => pr_cdcooper
                                ,pr_cdcopemp => vr_tab_saida(pr_idxsaida).cdcooper
                                ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                ,pr_dtrefere => pr_dtrefere
                                ,pr_innivris => vr_tab_saida(pr_idxsaida).innivris
                                ,pr_inddocto => vr_tab_saida(pr_idxsaida).inddocto
                                ,pr_cdinfadi => vr_tab_saida(pr_idxsaida).cdinfadi
                                ,pr_cdmodali => vr_tab_saida(pr_idxsaida).cdmodali
                                ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                                ,pr_nrseqctr => vr_tab_saida(pr_idxsaida).nrseqctr
                                ,pr_dtprxpar => vr_tab_saida(pr_idxsaida).dtprxpar
                                ,pr_vlprxpar => vr_tab_saida(pr_idxsaida).vlprxpar
                                ,pr_qtparcel => vr_tab_saida(pr_idxsaida).qtparcel);                                 
                                  
        If vr_tpexecucao = 2 Then
          vr_seq_relato := vr_seq_relato + 1;
          vr_texto :=  '>';
          -- Procedimento para gravar wrk, para posteriormente descarregar xml
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => vr_nrdaconta,
                                         pr_nrcpfcgc    => vr_tab_saida(vr_indice_crapris).sbcpfcgc,
                                         pr_nmrelatorio   => '3040_FECTAG >',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dscritic      => vr_texto,
                                         pr_Valor         =>  null,
                                         pr_seq_relato    => vr_seq_relato, -- nrctremp
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
            vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
            raise vr_exc_saida;
          end if;
        else
          -- Fechar a tah Op                                          
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                 ,pr_texto_completo => vr_xml_3040_temp
                                 ,pr_texto_novo     => '>' || chr(10));
        end if;

        IF vr_tab_saida(vr_indice_crapris).cdinfadi = '0305' THEN
          -- Busca a identificacao da sub-modalidade do emprestimo
          vr_iddident := fn_busca_submodal(vr_tab_saida(pr_idxsaida).cdcooper
                                          ,vr_tab_saida(pr_idxsaida).nrdconta
                                          ,vr_tab_saida(pr_idxsaida).nrctremp
                                          ,vr_tab_saida(pr_idxsaida).cdmodali
                                          ,vr_tab_saida(pr_idxsaida).cdorigem
                                          ,vr_tab_saida(pr_idxsaida).dsinfaux);

          -- Busca a modalidade com base nos emprestimos
          vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_saida(pr_idxsaida).cdmodnov
                                                  ,vr_tab_saida(pr_idxsaida).cdcooper
                                                  ,vr_tab_saida(pr_idxsaida).nrdconta
                                                  ,vr_tab_saida(pr_idxsaida).nrctrnov
                                                  ,vr_tab_saida(pr_idxsaida).inpessoa
                                                  ,vr_tab_saida(pr_idxsaida).cdorigem
                                                  ,vr_tab_saida(pr_idxsaida).dsinfnov);
                                                  
          -- Formata o numero do contrato
          vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => vr_tab_saida(pr_idxsaida).cdcooper
                                                          ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                                                          ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctrnov
                                                          ,pr_cdmodali => vr_cdmodali);
          vr_texto := '                        <Inf Tp="' || TRIM(vr_tab_saida(pr_idxsaida).cdinfadi) || '"' 
                                                    || ' Cd="' ||vr_nrcontrato_3040 || '"'  
                                                    || ' Ident="' || to_char(vr_iddident,'fm0000') || '"' 
                                                    || ' Valor="' || replace(to_char(vr_tab_saida(pr_idxsaida).vldivida,'fm99999999999999990D00'),',','.') || '"' 
                                                    || ' />';

          -- **
          -- Verifica Ativo Problemático(REESTRUTURAÇÃO) - Daniel(AMcom)
          IF vr_reestrut = 1 and vr_dtatvprobl is not null THEN
            -- Enviar informação adicional do contrato de Reestruturação
            vr_texto := vr_texto ||chr(10)|| '            <Inf Tp="1701"' -- Fixo
                                     || ' Cd="' ||vr_dtatvprobl || '"'
                                     || '/>';                                                
          END IF;
          
         If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,                                           
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_INFADCONT_TPVL',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         => vr_tab_saida(pr_idxsaida).vldivida,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
           if vr_dscritic is not null then
              vr_dscritic:= '3040_INFADCONT_TPVL - '||vr_dscritic;
              raise vr_exc_saida;
           end if;
          else
           -- Enviar informação adicional do contrato
           gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                  ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => vr_texto || chr(10));
          end if;
        ELSE
         vr_texto := '                        <Inf Tp="' || TRIM(vr_tab_saida(pr_idxsaida).cdinfadi) || '" />';

          -- **
          -- Verifica Ativo Problemático(REESTRUTURAÇÃO) - Daniel(AMcom)
          IF vr_reestrut = 1 and vr_dtatvprobl is not null THEN
            -- Enviar informação adicional do contrato de Reestruturação
            vr_texto := vr_texto||CHR(10)|| '                        <Inf Tp="1701"' -- Fixo
                                                 || ' Cd="' ||vr_dtatvprobl || '"'
                                                 || '/>';
          END IF;          
          --
         If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_tab_saida(vr_indice_crapris).sbcpfcgc, --vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_INFADCONT_TP',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         => 0,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
           if vr_dscritic is not null then
              vr_dscritic:= '3040_INFADCONT_TP - '||vr_dscritic;
              raise vr_exc_saida;
           end if;

          else
           -- Enviar informação adicional do contrato
           gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                  ,pr_texto_completo => vr_xml_3040_temp
                                 --,pr_texto_novo     => '                        <Inf Tp="' || TRIM(vr_tab_saida(pr_idxsaida).cdinfadi) || '" />' ||chr(10));
                                   ,pr_texto_novo     =>  vr_texto||chr(10));

          end if;
        END IF;
        -- Verificação do Ente Consignante
        pc_inf_ente_consignante(pr_cdcooper => vr_tab_saida(pr_idxsaida).cdcooper
                               ,pr_nrdconta => vr_tab_saida(pr_idxsaida).nrdconta
                               ,pr_nrctremp => vr_tab_saida(pr_idxsaida).nrctremp
                               ,pr_cdmodali => vr_tab_saida(pr_idxsaida).cdmodali
                               ,pr_dsinfaux => vr_tab_saida(pr_idxsaida).dsinfaux);

        If vr_tpexecucao = 2 Then
          vr_seq_relato := vr_seq_relato + 1;
          vr_texto := '        </Op>';
          -- Procedimento para gravar wrk, para posteriormente descarregar xml
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => vr_nrdaconta,
                                         pr_nrcpfcgc      => vr_tab_saida(vr_indice_crapris).sbcpfcgc, --vr_nrcgccpf,
                                         pr_nmrelatorio   => '3040_FECTAG </Op>',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dscritic      => vr_texto,
                                         pr_Valor         => null,
                                         pr_seq_relato    => vr_seq_relato, -- nrctremp
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
            vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
            raise vr_exc_saida;
          end if;
        else
           -- Fechar tag da operação de credito
           gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                  ,pr_texto_completo => vr_xml_3040_temp
                                  ,pr_texto_novo     => '        </Op>' || chr(10));
        end if;
      END pc_imprime_saida;

      -- Com base na temp-table vr_tab_saida eh gerado os dados e impresso no arquivo XML 3040
      PROCEDURE pc_busca_saidas(pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                               ,pr_innivris crapris.innivris%TYPE
                               ,pr_inpessoa crapris.inpessoa%TYPE) IS
        vr_nrcpfcgc      VARCHAR2(14);
        vr_indice_delete VARCHAR2(37);
      BEGIN
        
        -- Se for pessoa juridica, utiliza somente a base do CNPJ
        IF pr_inpessoa = 2 THEN 
          vr_nrcpfcgc := lpad(pr_nrcpfcgc,8,'0');
          vr_indice_crapris := vr_nrcpfcgc||'000000000000000';
        ELSE
          -- Se for pessoa fisica, utiliza todo o CPF
          vr_nrcpfcgc := lpad(pr_nrcpfcgc,14,'0');
          vr_indice_crapris := vr_nrcpfcgc||'000000000';
        END IF;

        -- Posicionar na pltable de riscos sob o primeiro risco desta pessoa
        vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
        
        -- varre a tabela vr_tab_saida
        WHILE vr_indice_crapris IS NOT NULL LOOP
          -- Sair se o  registro encontrado não for do CPF/CGC recebido
          IF vr_nrcpfcgc <> vr_tab_saida(vr_indice_crapris).sbcpfcgc THEN
            EXIT;
          END IF;        
          -- Chamar código comum para impressão da OP de saída
          pc_imprime_saida(pr_cdcooper => vr_tab_saida(vr_indice_crapris).cdcooper
                          ,pr_innivris => pr_innivris
                          ,pr_idxsaida => vr_indice_crapris);        
          -- Guardamos o indice para deleção posterior
          vr_indice_delete := vr_indice_crapris;
          -- Vai para o proximo registro
          vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
          -- Apagamos da tabela o registro anterior, pois o mesmo
          -- não precisa ser mais ser enviado ao documento
          vr_tab_saida.delete(vr_indice_delete);
        END LOOP;
        
      END pc_busca_saidas;

      -- Com base nos parametros passado, eh percorrido a temp-table e calculado o valor total da divida
      FUNCTION fn_total_divida_agreg(pr_faixasde       IN PLS_INTEGER
                                    ,pr_faixapar       IN PLS_INTEGER
                                    ,pr_cdmodali       IN crapris.cdmodali%TYPE
                                    ,pr_innivris       IN crapris.innivris%TYPE
                                    ,pr_cddfaixa       IN PLS_INTEGER
                                    ,pr_inpessoa       IN crapris.inpessoa%TYPE
                                    ,pr_cddesemp       IN PLS_INTEGER
                                    ,pr_cdnatuop       IN VARCHAR2
                                    ,pr_tab_venc_agreg IN OUT NOCOPY typ_tab_venc_agreg) RETURN NUMBER IS
        -- Indice para busca
        vr_ind_venc_agreg VARCHAR2(23);
        -- Total a acumular
        vr_ttldivid NUMBER(17,2); 
      BEGIN
        -- Inicializar
        vr_ttldivid := 0;
        -- Vai para o primeiro regisgtro da temp-table
        vr_ind_venc_agreg := pr_tab_venc_agreg.first;
        -- Iterar sob a pltable
        WHILE vr_ind_venc_agreg IS NOT NULL LOOP
          -- Se os parametros passados forem iguais aos da temp-table acumula o valor da divida
          IF pr_tab_venc_agreg(vr_ind_venc_agreg).cdvencto >= pr_faixasde AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdvencto <= pr_faixapar AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdmodali = pr_cdmodali  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).innivris = pr_innivris  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cddfaixa = pr_cddfaixa  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).inpessoa = pr_inpessoa  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cddesemp = pr_cddesemp  AND
             pr_tab_venc_agreg(vr_ind_venc_agreg).cdnatuop = pr_cdnatuop  THEN
            -- Acumular
            vr_ttldivid := vr_ttldivid + pr_tab_venc_agreg(vr_ind_venc_agreg).vldivida;
          END IF;
          -- Posicionar no próximo
          vr_ind_venc_agreg := pr_tab_venc_agreg.next(vr_ind_venc_agreg);
        END LOOP;
        -- Retornar valor acumular
        RETURN vr_ttldivid;
      END fn_total_divida_agreg;
      
      -- Classifica o porte do PF
      FUNCTION fn_classifi_porte_pf(pr_vlrrendi IN NUMBER) RETURN pls_integer IS
      BEGIN  
        
        --> 03/11/2016 - Renato Darosci - Alterado para considerar faixa "sem rendimento" até 0.01 - SD 549969
        --> 17/07/2018 - Heckmann (AMcom) - Alterado as regras das faixas 0, 1 e 2 - Product Backlog Item 9028:3040 - Porte Indisponível
      
      IF pr_dtmvtolt >= vr_dtcorte THEN
        -- Nova forma a partir de 01/11/2018
        IF pr_vlrrendi >= 0.01 AND pr_vlrrendi <= 1 THEN
          RETURN 0;
        ELSIF pr_vlrrendi = 0 THEN
          RETURN 1;
        ELSIF pr_vlrrendi > 1 AND pr_vlrrendi <= pr_vlsalmin THEN
          RETURN 2;
        ELSIF pr_vlrrendi > pr_vlsalmin AND pr_vlrrendi <= (pr_vlsalmin * 2) THEN
          RETURN 3;
        ELSIF pr_vlrrendi > pr_vlsalmin * 2 AND pr_vlrrendi <= pr_vlsalmin * 3 THEN
          RETURN 4;
        ELSIF pr_vlrrendi > pr_vlsalmin * 3 AND pr_vlrrendi <= pr_vlsalmin * 5 THEN
          RETURN 5;
        ELSIF pr_vlrrendi > pr_vlsalmin * 5 AND pr_vlrrendi <= pr_vlsalmin * 10 THEN
          RETURN 6;
        ELSIF pr_vlrrendi > pr_vlsalmin * 10 AND pr_vlrrendi <= pr_vlsalmin * 20 THEN
          RETURN 7;
        ELSIF pr_vlrrendi > pr_vlsalmin * 20 THEN
          RETURN 8;
        ELSE
          RETURN 0;
        END IF;
      ELSE
        -- Forma Atual até 01/11/2018
        IF pr_vlrrendi <= 0.01 THEN
          RETURN 1;
        ELSIF pr_vlrrendi > 0.01 AND pr_vlrrendi <= pr_vlsalmin THEN
          RETURN 2;
        ELSIF pr_vlrrendi > pr_vlsalmin AND pr_vlrrendi <= (pr_vlsalmin * 2) THEN
          RETURN 3;
        ELSIF pr_vlrrendi > pr_vlsalmin * 2 AND pr_vlrrendi <= pr_vlsalmin * 3 THEN
          RETURN 4;
        ELSIF pr_vlrrendi > pr_vlsalmin * 3 AND pr_vlrrendi <= pr_vlsalmin * 5 THEN
          RETURN 5;
        ELSIF pr_vlrrendi > pr_vlsalmin * 5 AND pr_vlrrendi <= pr_vlsalmin * 10 THEN
          RETURN 6;
        ELSIF pr_vlrrendi > pr_vlsalmin * 10 AND pr_vlrrendi <= pr_vlsalmin * 20 THEN
          RETURN 7;
        ELSIF pr_vlrrendi > pr_vlsalmin * 20 THEN
          RETURN 8;
        ELSE
          RETURN 0;
        END IF;
      END IF;

      END;
      
      -- Classifica o porte do PJ
      FUNCTION fn_classifi_porte_pj(pr_fatanual IN NUMBER) RETURN pls_integer IS
      BEGIN  
    --> 17/07/2018 - Heckmann (AMcom) - Alterado as regras das faixas 0 e 1 - Product Backlog Item 9028:3040 - Porte Indisponível
       
        IF pr_dtmvtolt >= vr_dtcorte THEN
          -- Nova forma a partir de 01/11/2018
        IF pr_fatanual >= 0 AND pr_fatanual <= 1 then
          RETURN 0;
        ELSIF pr_fatanual > 1 AND pr_fatanual <= 360000 THEN
          RETURN 1;
        ELSIF pr_fatanual > 360000 AND pr_fatanual <= 4800000 THEN
          RETURN 2;
        ELSIF pr_fatanual > 4800000 AND pr_fatanual <= 300000000 THEN
          RETURN 3;
        ELSIF pr_fatanual > 300000000 THEN
          RETURN 4;
        END IF;
        ELSE
          -- Forma Atual até 01/11/2018
        IF pr_fatanual <= 360000 THEN
          RETURN 1;
        ELSIF pr_fatanual > 360000 AND pr_fatanual <= 4800000 THEN
          RETURN 2;
        ELSIF pr_fatanual > 4800000 AND pr_fatanual <= 300000000 THEN
          RETURN 3;
        ELSIF pr_fatanual > 300000000 THEN
          RETURN 4;
        END IF;
        END IF;
      END;
      
      -- Busca dados Associado
      PROCEDURE pc_busca_dados_associ(pr_cdcooper in crapass.cdcooper%type
                                     ,pr_nrdconta in crapass.nrdconta%type
                                     ,pr_nrcpfcgc in crapass.nrcpfcgc%TYPE
                                     ,pr_dsnivris OUT crapass.dsnivris%type
                                     ,pr_dtadmiss OUT crapass.dtadmiss%type
                                     ,pr_cdcritic out number) is 
      BEGIN  
        -- Se for BNDES
        IF pr_flbbndes = 'S' THEN
          -- Busca dados por CPF/CNPJ em todas as cooperativas 
          IF NOT vr_tab_associ.exists(pr_nrcpfcgc) THEN
            -- Iniciar registro
            vr_tab_associ(pr_nrcpfcgc).cdcooper := 0;
            vr_tab_associ(pr_nrcpfcgc).dsnivris := 'A';
            vr_tab_associ(pr_nrcpfcgc).dtadmiss := trunc(SYSDATE);
            vr_tab_associ(pr_nrcpfcgc).nrcepend := 0;
            -- Buscaremos todos os registros em todas as coops deste CPF ou CNPJ
            OPEN cr_crapass_cpfcnpj(pr_nrcpfcgc);
            LOOP
              FETCH cr_crapass_cpfcnpj 
               INTO vr_cdcooper_ass,vr_dsnivris_ass,vr_dtadmiss_ass;
              EXIT WHEN cr_crapass_cpfcnpj%NOTFOUND;
              -- Manter o pior risco
              IF vr_dsnivris_ass > vr_tab_associ(pr_nrcpfcgc).dsnivris THEN
                vr_tab_associ(pr_nrcpfcgc).dsnivris := vr_dsnivris_ass;
              END IF;
              -- Guardar conta mais antiga
              IF vr_dtadmiss_ass < vr_tab_associ(pr_nrcpfcgc).dtadmiss THEN
                vr_tab_associ(pr_nrcpfcgc).dtadmiss := vr_dtadmiss_ass;
                vr_tab_associ(pr_nrcpfcgc).cdcooper := vr_cdcooper_ass;
                -- Buscar CEP desta Coop
                vr_tab_associ(pr_nrcpfcgc).nrcepend := vr_tab_crapcop(vr_cdcooper_ass).nrcepend;
              END IF;
            END LOOP;
            CLOSE cr_crapass_cpfcnpj;
          END IF;
              
          -- Se mesmo assim não encontrou 
          IF NOT vr_tab_associ.exists(pr_nrcpfcgc) THEN
            -- Encerra o programa com erro
            pr_cdcritic := 9;
          ELSE
            -- Copiar os valores para as variaveis para reaproveitamento de código abaixo 
            pr_dsnivris := vr_tab_associ(pr_nrcpfcgc).dsnivris;
            pr_dtadmiss := vr_tab_associ(pr_nrcpfcgc).dtadmiss;
          END IF;
        ELSE
          -- Busca os dados do associado por COop e Cta
          OPEN cr_crapass(pr_cdcooper,pr_nrdconta);
          FETCH cr_crapass INTO vr_nrcpfcgc_ass,vr_inpessoa_ass,pr_dsnivris,pr_dtadmiss;
          -- Se nao encontrar o associado encerra o programa com erro
          IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            pr_cdcritic := 9;
          END IF;
          CLOSE cr_crapass; -- Fecha o cursor de associados
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 9;
      END;
      
      -- Procedure para gerar o arquivo 3040 particionado
      PROCEDURE pc_solicita_relato_3040(pr_nrdocnpj      IN crapcop.nrdocnpj%TYPE      -- CNPJ da cooperativa
                                       ,pr_dsnomscr      IN crapcop.dsnomscr%TYPE      -- Nome do responsavel
                                       ,pr_dsemascr      IN crapcop.dsemascr%TYPE      -- Email do Responsavel
                                       ,pr_dstelscr      IN crapcop.dstelscr%TYPE      -- Telefone do Responsavel
                                       ,pr_cdprogra      IN crapprg.cdprogra%TYPE      -- Codigo do Programa
                                       ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE      -- Data de Movimento
                                       ,pr_dtrefere      IN DATE                       -- Data de Referencia
                                       ,pr_flbbndes      IN VARCHAR2                   -- Execução específica recursos BNDes
                                       ,pr_flgfimaq      IN BOOLEAN                    -- Define a ultima parte do arquivo
                                       ,pr_totalcli      IN INTEGER                    -- Total de Cliente
                                       ,pr_nom_direto    IN VARCHAR2                   -- Diretorio da cooperativa
                                       ,pr_nom_dirmic    IN VARCHAR2                   -- Diretorio micros da cooperativa
                                       ,pr_numparte      IN OUT INTEGER           	   -- Numero da parte do arquivo
                                       ,pr_xml_3040      IN OUT NOCOPY CLOB            -- XML do arquivo 3040
                                       ,pr_xml_3040_temp IN OUT VARCHAR2               -- XML do arquivo 3040
                                       ,pr_cdcritic      OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                                       ,pr_dscritic      OUT crapcri.dscritic%TYPE) IS -- Descricao da critica
                                       
        vr_xml_rel_parte        CLOB;            -- Variavel CLOB contendo o xml particionado      
        vr_xml_rel_parte_temp   VARCHAR2(32767); -- Variavel VARCHAR contendo o xml particionado
        vr_coopcnpj             VARCHAR2(14);    -- Armazenar o CNPJ da Cooperativa
        vr_nmarqsai             VARCHAR2(50);    -- Nome do arquivo 3040
      BEGIN
        pr_numparte := pr_numparte + 1;
        
        -- Definicao dos nomes dos arquivos de saida
        IF pr_flbbndes = 'S' THEN
          vr_nmarqsai := '3040' || LPAD(TO_CHAR(pr_numparte),2,'0') || to_char(pr_dtrefere,'MMYY')||'_BNDEs.xml';        
        ELSE
          vr_nmarqsai := '3040' || LPAD(TO_CHAR(pr_numparte),2,'0') || to_char(pr_dtrefere,'MMYY')||'.xml';        
        END IF;
        
        -- Armazenar todos os arquivos gerados
        IF vr_nmarqsai_tot IS NULL THEN
          vr_nmarqsai_tot := pr_nom_dirmic||'/'||vr_nmarqsai;
        ELSE
          vr_nmarqsai_tot := vr_nmarqsai_tot||chr(10)||
                             pr_nom_dirmic||'/'||vr_nmarqsai;
        END IF;
        
        -- Armazenar o CNPJ da Cooperativa
        vr_coopcnpj := substr(lpad(pr_nrdocnpj,14,'0'),1,8);        
        -- Inicializar o CLOB do relatorio particionado
        dbms_lob.createtemporary(vr_xml_rel_parte, TRUE);
        dbms_lob.open(vr_xml_rel_parte, dbms_lob.lob_readwrite);
        -- Insere o cabecalho no arquivo 3040
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||chr(10)
                                                     || '<Doc3040 DtBase="' || to_char(pr_dtrefere,'YYYY-MM') 
                                                     || '" CNPJ="'   || vr_coopcnpj 
                                                     || '" Remessa="1" Parte="'|| pr_numparte
                                                     || '" NomeResp="' || pr_dsnomscr 
                                                     || '" EmailResp="' || nvl(pr_dsemascr,'') 
                                                     || '" TelResp="' || pr_dstelscr
                                                     || '" TotalCli="' || pr_totalcli||'" ');
                                                     
        -- Condicao para verificar se eh a ultima parte do arquivo 3040
        IF pr_flgfimaq THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                                 ,pr_texto_completo => vr_xml_rel_parte_temp
                                 ,pr_texto_novo     => 'TpArq="F"');
        END IF;
        
        -- Fecha a tag do cabecalho
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '>' || chr(10)
                               ,pr_fecha_xml      => true);
        
        -- Concatena o corpo do XML
        dbms_lob.writeappend(pr_xml_3040, length(pr_xml_3040_temp), pr_xml_3040_temp);
        -- Concatena o Cabecalho + Corpo do XML
        dbms_lob.append(vr_xml_rel_parte, pr_xml_3040);        
        -- Fecha a tag do arquivo XML
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_rel_parte
                               ,pr_texto_completo => vr_xml_rel_parte_temp
                               ,pr_texto_novo     => '</Doc3040>'|| chr(10)
                               ,pr_fecha_xml      => true);
        -- gera o arquivo xml 3040
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper 
                                           ,pr_cdprogra  => pr_cdprogra
                                           ,pr_dtmvtolt  => pr_dtmvtolt
                                           ,pr_dsxml     => vr_xml_rel_parte
                                           ,pr_dsarqsaid => pr_nom_direto ||'/'|| vr_nmarqsai
                                           ,pr_cdrelato  => null
                                           ,pr_flg_gerar => 'N'              --> Apenas submeter
                                           ,pr_dspathcop => pr_nom_dirmic    --> Copiar para a Micros
                                           ,pr_fldoscop  => 'S'              --> Efetuar cópia com Ux2Dos
                                           ,pr_dscmaxcop => '| tr -d "\032"'
                                           ,pr_des_erro  => pr_dscritic);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_xml_rel_parte);
        dbms_lob.freetemporary(vr_xml_rel_parte);
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(pr_xml_3040);
        dbms_lob.freetemporary(pr_xml_3040);
        -- Limpa as variaveis
        pr_xml_3040      := NULL;
        pr_xml_3040_temp := NULL;
        
        -- Somente vamos criar, quando nao for o ultimo arquivo
        IF NOT pr_flgfimaq THEN
          -- Inicializar o CLOB do relatorio particionado
          dbms_lob.createtemporary(pr_xml_3040, TRUE);
          dbms_lob.open(pr_xml_3040, dbms_lob.lob_readwrite);        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
          
      END pc_solicita_relato_3040;    

    -- ----------------------------------------------------------------
    -- Rotina Principal     
    -- ----------------------------------------------------------------
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      
      IF pr_idparale = 0 THEN
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger);
      END IF;
      
      -- Gerar log
      pc_controla_log_batch(1, '1 - Inicio PA: '||pr_cdagenci );
      
      -- Carregar todas as cooperativas para memória
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_tab_crapcop(rw_crapcop.cdcooper) := rw_crapcop;
      END LOOP;
      
      -- Verifica se a cooperativa global esta cadastrada
      IF NOT vr_tab_crapcop.exists(pr_cdcooper) THEN
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      END IF;

      -- Inicio do paralelismo - Mauro 02/2018
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper,vr_cdprogra); 

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      -- Busca do rl
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      
      -- busca o diretorio salvar da coop
      vr_nom_dirsal := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar');
                                            
      -- busca o diretorio micros contab
      vr_nom_dirmic := gene0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');
                                            
      -- Inicializar o CLOB 3040
      dbms_lob.createtemporary(vr_xml_3040, TRUE);
      dbms_lob.open(vr_xml_3040, dbms_lob.lob_readwrite);
      

      -- data de corte para Colateral Financeiro e Porte Cliente
      vr_dtcorte := to_date(GENE0001.fn_param_sistema(pr_cdcooper => 0
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_cdacesso => 'DT_CORTE_COLFIN') ,'DD/MM/RRRR');
      
      -- Carrega as tabelas temporarias de vencimentos de risco
      IF pr_flbbndes = 'N' THEN
        FOR rw_crapvri IN cr_crapvri(pr_cdcooper,pr_dtrefere) LOOP
          vr_crapvri := vr_crapvri + 1;
          IF rw_crapvri.vldivida <> 0 THEN -- Carrega a tabela vr_tab_crapvri_b
            vr_indice_crapvri_b := lpad(rw_crapvri.cdcooper,03,'0') ||
                                   lpad(rw_crapvri.nrdconta,10,'0') ||
                                   lpad(rw_crapvri.innivris,05,'0') ||
                                   lpad(rw_crapvri.cdmodali,05,'0') ||
                                   lpad(rw_crapvri.nrseqctr,05,'0') ||
                                   lpad(rw_crapvri.nrctremp,10,'0') ||
                                   lpad(vr_crapvri,7,'0');
            vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto := rw_crapvri.cdvencto;
            vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida := rw_crapvri.vldivida;
          END IF;
        END LOOP;
      ELSE
        FOR rw_crapvri IN cr_crapvri_bndes(pr_dtrefere) LOOP
          vr_crapvri := vr_crapvri + 1;
          IF rw_crapvri.vldivida <> 0 THEN -- Carrega a tabela vr_tab_crapvri_b
            vr_indice_crapvri_b := lpad(rw_crapvri.cdcooper,03,'0') ||
                                   lpad(rw_crapvri.nrdconta,10,'0') ||
                                   lpad(rw_crapvri.innivris,05,'0') ||
                                   lpad(rw_crapvri.cdmodali,05,'0') ||
                                   lpad(rw_crapvri.nrseqctr,05,'0') ||
                                   lpad(rw_crapvri.nrctremp,10,'0') ||
                                   lpad(vr_crapvri,7,'0');
            vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto := rw_crapvri.cdvencto;
            vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida := rw_crapvri.vldivida;
          END IF;
        END LOOP;
      END IF;
      
      
      -- Carrega a tabela temporaria de emprestimos do Bndes
      IF pr_flbbndes = 'N' THEN        
        FOR rw_crapebn IN cr_crapebn(pr_cdcooper) LOOP
          vr_ind_ebn := lpad(rw_crapebn.cdcooper,3,'0')||lpad(rw_crapebn.nrdconta,10,'0')||lpad(rw_crapebn.nrctremp,10,'0');
          vr_tab_crapebn(vr_ind_ebn).cdsubmod := rw_crapebn.cdsubmod;
          vr_tab_crapebn(vr_ind_ebn).vlropepr := rw_crapebn.vlropepr;
          vr_tab_crapebn(vr_ind_ebn).dtinictr := rw_crapebn.dtinictr;
          vr_tab_crapebn(vr_ind_ebn).dtfimctr := rw_crapebn.dtfimctr;
          vr_tab_crapebn(vr_ind_ebn).dtprejuz := rw_crapebn.dtprejuz;
          vr_tab_crapebn(vr_ind_ebn).txefeanu := rw_crapebn.txefeanu;
          vr_tab_crapebn(vr_ind_ebn).nrdconta := rw_crapebn.nrdconta;
          vr_tab_crapebn(vr_ind_ebn).dtvctpro := rw_crapebn.dtvctpro;
          vr_tab_crapebn(vr_ind_ebn).vlparepr := rw_crapebn.vlparepr;
          vr_tab_crapebn(vr_ind_ebn).qtparctr := rw_crapebn.qtparctr;
          vr_tab_crapebn(vr_ind_ebn).cdindxdr := rw_crapebn.cdindxdr;
        END LOOP;
      ELSE       
        FOR rw_crapebn IN cr_crapebn_bndes LOOP
          vr_ind_ebn := lpad(rw_crapebn.cdcooper,3,'0')||lpad(rw_crapebn.nrdconta,10,'0')||lpad(rw_crapebn.nrctremp,10,'0');
          vr_tab_crapebn(vr_ind_ebn).cdsubmod := rw_crapebn.cdsubmod;
          vr_tab_crapebn(vr_ind_ebn).vlropepr := rw_crapebn.vlropepr;
          vr_tab_crapebn(vr_ind_ebn).dtinictr := rw_crapebn.dtinictr;
          vr_tab_crapebn(vr_ind_ebn).dtfimctr := rw_crapebn.dtfimctr;
          vr_tab_crapebn(vr_ind_ebn).dtprejuz := rw_crapebn.dtprejuz;
          vr_tab_crapebn(vr_ind_ebn).txefeanu := rw_crapebn.txefeanu;
          vr_tab_crapebn(vr_ind_ebn).nrdconta := rw_crapebn.nrdconta;
          vr_tab_crapebn(vr_ind_ebn).dtvctpro := rw_crapebn.dtvctpro;
          vr_tab_crapebn(vr_ind_ebn).vlparepr := rw_crapebn.vlparepr;
          vr_tab_crapebn(vr_ind_ebn).qtparctr := rw_crapebn.qtparctr;
          vr_tab_crapebn(vr_ind_ebn).cdindxdr := rw_crapebn.cdindxdr;
        END LOOP;
      END IF;
      
      
      -- Carrega a tabela temporaria do cartao de credito
      IF pr_flbbndes = 'N' THEN
        FOR rw_tbcrd_risco IN cr_tbcrd_risco(pr_cdcooper,pr_cdagenci,pr_dtrefere) LOOP
          vr_ind_crd := LPAD(rw_tbcrd_risco.cdcooper,3,'0')||LPAD(rw_tbcrd_risco.nrdconta,10,'0') || LPAD(rw_tbcrd_risco.nrcontrato,10,'0');
          vr_tab_tbcrd_risco(vr_ind_crd).vlropcrd := rw_tbcrd_risco.vlropcrd;
          vr_tab_tbcrd_risco(vr_ind_crd).cdtipcar := rw_tbcrd_risco.cdtipo_cartao;
        END LOOP;
        -- Busca taxa de Juros Cartao BB e Bancoob
        FOR rw_car IN cr_tbrisco_prod LOOP
          IF rw_car.tparquivo = 'Cartao_BB' THEN
            vr_vltxabb := rw_car.vltaxa_juros;
          ELSE
            vr_vltxban := rw_car.vltaxa_juros;
          END IF;  
        END LOOP;
      END IF;
      
      -- Carregar quando Sem Paralelo ou Job Paralelo
      if pr_inproces  < 3 OR vr_qtdjobs = 0 or pr_cdagenci   > 0 then 
        -- Execução normal
        IF pr_flbbndes = 'N' THEN
          -- Carrega a tabela temporaria de emprestimos
          FOR rw_crapepr IN cr_crapepr (pr_cdcooper,pr_cdagenci) LOOP
            vr_ind_epr := lpad(rw_crapepr.cdcooper,03,'0')||lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');
            vr_tab_crapepr(vr_ind_epr).dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_crapepr(vr_ind_epr).cdlcremp := rw_crapepr.cdlcremp;
            vr_tab_crapepr(vr_ind_epr).vlpreemp := rw_crapepr.vlpreemp;
            vr_tab_crapepr(vr_ind_epr).vlemprst := rw_crapepr.vlemprst;
            vr_tab_crapepr(vr_ind_epr).dtprejuz := rw_crapepr.dtprejuz;
            vr_tab_crapepr(vr_ind_epr).nrctaav1 := rw_crapepr.nrctaav1;
            vr_tab_crapepr(vr_ind_epr).nrctaav2 := rw_crapepr.nrctaav2;
            vr_tab_crapepr(vr_ind_epr).qtpreemp := rw_crapepr.qtpreemp;
            vr_tab_crapepr(vr_ind_epr).txmensal := rw_crapepr.txmensal;
            vr_tab_crapepr(vr_ind_epr).dtdpagto := rw_crapepr.dtdpagto; -- epr.dtdpagto
            vr_tab_crapepr(vr_ind_epr).dtdpripg := rw_crapepr.dtdpripg; -- wpr.dtdpagto
            vr_tab_crapepr(vr_ind_epr).qtctrliq := rw_crapepr.qtctrliq; -- Testes de existência de liquidação
            vr_tab_crapepr(vr_ind_epr).inprejuz := rw_crapepr.inprejuz;
            vr_tab_crapepr(vr_ind_epr).tpemprst := rw_crapepr.tpemprst;
            vr_tab_crapepr(vr_ind_epr).cddindex := rw_crapepr.cddindex;
            vr_tab_crapepr(vr_ind_epr).idquaprc := TRIM(TO_CHAR(rw_crapepr.idquaprc,'00'));
            vr_tab_crapepr(vr_ind_epr).idquapro := TRIM(TO_CHAR(rw_crapepr.idquapro,'00'));
          END LOOP;  
        ELSE
          -- Execução só do BNDES, precisamos varrer todas as coops
          FOR rw_crapepr IN cr_crapepr_BNDEs LOOP
            vr_ind_epr := lpad(rw_crapepr.cdcooper,03,'0')||lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');
            vr_tab_crapepr(vr_ind_epr).dtmvtolt := rw_crapepr.dtmvtolt;
            vr_tab_crapepr(vr_ind_epr).cdlcremp := rw_crapepr.cdlcremp;
            vr_tab_crapepr(vr_ind_epr).vlpreemp := rw_crapepr.vlpreemp;
            vr_tab_crapepr(vr_ind_epr).vlemprst := rw_crapepr.vlemprst;
            vr_tab_crapepr(vr_ind_epr).dtprejuz := rw_crapepr.dtprejuz;
            vr_tab_crapepr(vr_ind_epr).nrctaav1 := rw_crapepr.nrctaav1;
            vr_tab_crapepr(vr_ind_epr).nrctaav2 := rw_crapepr.nrctaav2;
            vr_tab_crapepr(vr_ind_epr).qtpreemp := rw_crapepr.qtpreemp;
            vr_tab_crapepr(vr_ind_epr).txmensal := rw_crapepr.txmensal;
            vr_tab_crapepr(vr_ind_epr).dtdpagto := rw_crapepr.dtdpagto; -- epr.dtdpagto
            vr_tab_crapepr(vr_ind_epr).dtdpripg := rw_crapepr.dtdpripg; -- wpr.dtdpagto
            vr_tab_crapepr(vr_ind_epr).qtctrliq := rw_crapepr.qtctrliq; -- Testes de existência de liquidação
            vr_tab_crapepr(vr_ind_epr).inprejuz := rw_crapepr.inprejuz;
            vr_tab_crapepr(vr_ind_epr).tpemprst := rw_crapepr.tpemprst;
            vr_tab_crapepr(vr_ind_epr).cddindex := rw_crapepr.cddindex;
            vr_tab_crapepr(vr_ind_epr).idquaprc := TRIM(TO_CHAR(rw_crapepr.idquaprc,'00'));
            vr_tab_crapepr(vr_ind_epr).idquapro := TRIM(TO_CHAR(rw_crapepr.idquapro,'00'));
          END LOOP;
        END IF;  
      end if;
      
      -- Carregar PLTABLE de Linhas de Credito
      IF pr_flbbndes = 'N' THEN
        FOR rw_craplcr IN cr_craplcr(pr_cdcooper) LOOP
          -- IDX da Linha
          vr_idx_lcr := lpad(rw_craplcr.cdcooper,03,'0')
                     || lpad(rw_craplcr.cdlcremp,05,'0');  
          -- Armazenar pltable
          vr_tab_craplcr(vr_idx_lcr).cdmodali := rw_craplcr.cdmodali;
          vr_tab_craplcr(vr_idx_lcr).cdsubmod := rw_craplcr.cdsubmod;
          vr_tab_craplcr(vr_idx_lcr).txjurfix := rw_craplcr.txjurfix;
          vr_tab_craplcr(vr_idx_lcr).dsorgrec := rw_craplcr.dsorgrec;
          vr_tab_craplcr(vr_idx_lcr).cdusolcr := rw_craplcr.cdusolcr;
        END LOOP;
      ELSE
        FOR rw_craplcr IN cr_craplcr_bndes LOOP
          -- IDX da Linha
          vr_idx_lcr := lpad(rw_craplcr.cdcooper,03,'0')
                     || lpad(rw_craplcr.cdlcremp,05,'0');  
          -- Armazenar pltable
          vr_tab_craplcr(vr_idx_lcr).cdmodali := rw_craplcr.cdmodali;
          vr_tab_craplcr(vr_idx_lcr).cdsubmod := rw_craplcr.cdsubmod;
          vr_tab_craplcr(vr_idx_lcr).txjurfix := rw_craplcr.txjurfix;
          vr_tab_craplcr(vr_idx_lcr).dsorgrec := rw_craplcr.dsorgrec;
          vr_tab_craplcr(vr_idx_lcr).cdusolcr := rw_craplcr.cdusolcr;
        END LOOP;      
      END IF;
      
      -- Carregar a pltable de riscos
      pc_carrega_base_saida(pr_cdcooper,pr_dtrefere,pr_flbbndes);
                   
      if pr_cdagenci = 0 then 
        -- Gerar log
        pc_controla_log_batch(1, '2 - Fim Carga PA: '||pr_cdagenci );
      end if;

      -- Paralelismo visando performance Rodar Somente no processo Noturno
      -- XML do BNDES não poderá rodar via paralelismo 
      IF pr_flbbndes = 'N' AND pr_inproces > 2 AND vr_qtdjobs > 0 AND pr_cdagenci = 0 then 

        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;
        
        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
           RAISE vr_exc_saida;
        END IF;
        
        -- Procedimento para limpeza da tabela WRK
        -- Em reexecução (restart) refaz todo o processo de geração do arquivo.
        Begin
          Delete Tbgen_Batch_Relatorio_Wrk A
           Where A.CDPROGRAMA = vr_cdprogra
             and a.cdcooper   = pr_cdcooper;
        Exception
          When Others Then     
            vr_dscritic := 'Erro ao limpeza tabela Tbgen_Batch_Relatorio_Wrk: '||SQLERRM;
            RAISE vr_exc_saida;
        END;         
        
        Commit;        
        
        -- Verifica se algum job paralelo executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => pr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);     

        -- Retorna as agências, com poupança programada
        -- Efetua loop sobre os dados da central de risco, buscando as agencias com Movto para 
        -- pararelismo. (Exceto 301 - Dsc Titulos)
        for rw_crapris_age in cr_crapris_age (pr_cdcooper,
                                              pr_dtrefere,
                                              vr_cdprogra,
                                              pr_dtmvtolt) loop
                                              
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := vr_cdprogra ||'_'|| rw_crapris_age.cdagenci || '$';  
        
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(rw_crapris_age.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);
                                    
          -- Testar saida com erro
          if vr_dscritic is not null then
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;     
          
          -- Montar o bloco PLSQL que será executado
          -- Ou seja, executaremos a geração dos dados
          -- para a agência atual atraves de Job no banco
          vr_dsplsql := 'DECLARE' || chr(13) || --
                        '  wpr_stprogra NUMBER;' || chr(13) || --
                        '  wpr_infimsol NUMBER;' || chr(13) || --
                        '  wpr_cdcritic NUMBER;' || chr(13) || --
                        '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                        'BEGIN' || chr(13) || --
                        '  pc_crps573_1('|| pr_cdcooper || ',' 
                                         || 'to_date('''||to_char(pr_dtrefere,'ddmmrrrr')||''',''ddmmrrrr''),'                                         
                                         || 'to_date('''||to_char(pr_dtmvtolt,'ddmmrrrr')||''',''ddmmrrrr''),'
                                         || 'to_date('''||to_char(pr_dtultdma,'ddmmrrrr')||''',''ddmmrrrr''),'
                                         || pr_inproces|| ','
                                         || replace(pr_vlsalmin,',','.')|| ','
                                         || replace(pr_txeanual,',','.')|| ','
                                         || rw_crapris_age.cdagenci || ',' 
                                         || vr_idparale || ',' 
                                         || '''N'','
                                         || 'wpr_cdcritic, wpr_dscritic);' 
                                         || chr(13) || --
                        'END;'; --  
           
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);    
                                
          -- Testar saida com erro
          if vr_dscritic is not null then 
             -- Levantar exceçao
             raise vr_exc_saida;
          end if;

          -- Chama rotina que irá pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execuçao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                      ,pr_des_erro => vr_dscritic);

          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;
           
        end LOOP;
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => vr_dscritic);
                                    
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;    

        -- Verifica se algum job executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => pr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);
        if vr_qterro > 0 then 
          vr_cdcritic := 0;
          vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
          raise vr_exc_saida;
        end if;
      else
        -- Teste para identificar o tipo de execução, quando pr_idparale <> 0, indica que é uma execução por JOB
        -- dessa forma, geramos a tabela WRK para que ao final da execução de todos os JOBs, descarregamos no arquivo.
        -- Caso contrário, é gerado aqruivo na rotina abaixo.
        if pr_idparale <> 0 then
           vr_tpexecucao := 2;
        else
           vr_tpexecucao := 1;
        end if;  
        -- Continuação do paralelismo - Mauro
        -- Grava controle de batch por agência
        gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                        ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                        ,pr_dtmvtolt    => pr_dtmvtolt       -- Data de Movimento
                                        ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                        ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                        ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                        ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                        ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                        ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                        ,pr_dscritic    => vr_dscritic); 

        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par); 
                     
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - AGENCIA: '||pr_cdagenci||' - INPROCES: '||pr_inproces,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  
                                        
        -- Carregar a base de risco, separando os contratos em individuais e agregados 
        pc_carrega_base_risco(pr_cdcooper,pr_cdagenci,pr_dtrefere,pr_flbbndes);
            
        -- Carrega os percentuais de risco
        FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
          vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
        END LOOP;
        -- De acordo com o BCB, no arquivo 3040 o prejuizo deve ser provisionado 100% igual risco H (9) 
        vr_tab_percentual(10).percentual := vr_tab_percentual(9).percentual;
            
        -- Busca os movimentos digitados manualmente para os contratos inddocto=5
        IF pr_flbbndes = 'N' THEN
          FOR rw_movtos IN cr_movtos_garprest(pr_cdcooper,pr_dtrefere) LOOP
            -- Alimentar pltable
            vr_tab_mvto_garant_prest(lpad(rw_movtos.cdcooper,3,'0')||rw_movtos.idmovto_risco) := rw_movtos;
          END LOOP;
        ELSE
          FOR rw_movtos IN cr_movtos_garprest_bndes(pr_dtrefere) LOOP
            -- Alimentar pltable
            vr_tab_mvto_garant_prest(lpad(rw_movtos.cdcooper,3,'0')||rw_movtos.idmovto_risco) := rw_movtos;
          END LOOP;
        END IF;
            
        -- Acessar primeiro registro da tabela de memoria
        vr_idx_individ := vr_tab_individ.FIRST;
        -- Varre a tabela de memoria dos contratos individualizados
        WHILE vr_idx_individ IS NOT NULL LOOP  
          vr_fatanual := 0;
          vr_vlrrendi := 0;
          vr_portecli := 0;
          vr_stgpecon := '';
          -- Informacoes do Cliente 
          IF vr_tab_individ.prior(vr_idx_individ) IS NULL OR  -- Se for o primeiro registro
             vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.prior(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do anterior
                 
            -- Zerar controle de avalistas
            vr_flgarant := FALSE;
            
            -- Busca dados do associado
            pc_busca_dados_associ(vr_tab_individ(vr_idx_individ).cdcooper
                                 ,vr_tab_individ(vr_idx_individ).nrdconta
                                 ,vr_tab_individ(vr_idx_individ).nrcpfcgc
                                 ,vr_dsnivris_ass
                                 ,vr_dtadmiss_ass
                                 ,vr_cdcritic);
            IF vr_cdcritic > 0 THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Se a data de admissao for vazia, ou se o ano de admissao for inferior a 1000
            IF vr_dtadmiss_ass IS NULL OR to_char(vr_dtadmiss_ass,'YYYY') < 1000 THEN 
              -- Atribui a data atual sem a hora
              vr_dtabtcct := trunc(SYSDATE); 
            ELSE
              -- Usar da tabela
              vr_dtabtcct := vr_dtadmiss_ass;
            END IF;
            -- Busca a classe do cliente
            IF vr_dsnivris_ass = 'HH' THEN
              vr_classcli := 'H';
            ELSIF TRIM(vr_dsnivris_ass) IS NOT NULL THEN
              vr_classcli := vr_dsnivris_ass;
            ELSE
              vr_classcli := 'A';
            END IF;
            
            -- Se for pessoa fisica
            IF vr_tab_individ(vr_idx_individ).inpessoa = 1 THEN
              -- Busca o titular da conta
              OPEN cr_crapttl(vr_tab_individ(vr_idx_individ).cdcooper,vr_tab_individ(vr_idx_individ).nrdconta);
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN
                -- Somar salário + aplicações
                vr_vlrrendi := NVL(rw_crapttl.vlsalari,0)    + 
                               NVL(rw_crapttl.vldrendi##1,0) + 
                               NVL(rw_crapttl.vldrendi##2,0) + 
                               NVL(rw_crapttl.vldrendi##3,0) +
                               NVL(rw_crapttl.vldrendi##4,0) + 
                               NVL(rw_crapttl.vldrendi##5,0) + 
                               NVL(rw_crapttl.vldrendi##6,0);
              END IF;
              CLOSE cr_crapttl; -- Fecha o cursor de titulares
              -- Busca o porte do cliente
              vr_portecli := fn_classifi_porte_pf(vr_vlrrendi);
              -- Valor do rendimento nao pode ser zero
              IF vr_vlrrendi = 0 THEN
                vr_vlrrendi := 0.01;
              END IF;
                  
              vr_nrcgccpf := lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,11,'0');          

              IF vr_tab_individ(vr_idx_individ).nrdgrupo > 0 THEN
                vr_stgpecon := ' CongEcon="' || To_CHAR(vr_tab_individ(vr_idx_individ).nrdgrupo) || '"';              
              END IF; 
       
              -- Procedimento para gravar WRK quando paralelismo 
              vr_Texto := '    <Cli Cd="' || lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,11,'0') || '"' 
                                          || ' Tp="1"' 
                                          || ' Autorzc="S"' 
                                          || ' PorteCli="' || TRIM(vr_portecli) || '"' 
                                          || ' IniRelactCli="' ||to_char(vr_dtabtcct,'YYYY-MM-DD') || '"' 
                                          || ' FatAnual="' || replace(to_char(vr_vlrrendi,'fm9999999999990D00'),',','.') || '"' 
                                          || vr_stgpecon
                                          || ' ClassCli="' || vr_classcli || '">' ;
       
               -- Se for uma execução do paralelismo, gravar a wrk e descarregar ao final de todas as agencias.
               If vr_tpexecucao = 2 Then
                  vr_seq_relato := vr_seq_relato + 1;
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => vr_nrdaconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => '3040_PFJ',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                                 pr_dscritic      => vr_texto,
                                                 pr_Valor         => null,
                                                 pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => null,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                     vr_dscritic:= '1 3040_PF - '||vr_dscritic;
                     raise vr_exc_saida;
                  end if;                                                     
               Else
                 -- Enviar detalhes do cliente fisico
                 gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                        ,pr_texto_completo => vr_xml_3040_temp
                                        ,pr_texto_novo     => vr_Texto || chr(10));
               end if;
             ELSE -- Se for pessoa juridica
               -- busca o valor de faturamento
               OPEN cr_crapjfn(vr_tab_individ(vr_idx_individ).cdcooper,vr_tab_individ(vr_idx_individ).nrdconta);
               FETCH cr_crapjfn INTO vr_fatanual;
               CLOSE cr_crapjfn; -- Fecha o cursor dos dados financeiros de PJ
               -- Validador nao aceita faturamento zerado nem negativo
               IF vr_fatanual <= 0 THEN
                 vr_fatanual := 1;
               END IF;
                  
               IF vr_tab_individ(vr_idx_individ).nrdgrupo > 0 THEN
                 vr_stgpecon := ' CongEcon="' || To_CHAR(vr_tab_individ(vr_idx_individ).nrdgrupo) || '"';              
               END IF; 
                  
               vr_nrcgccpf := lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,14,'0');   
       
               -- Classifica o porte do PJ
               vr_portecli := fn_classifi_porte_pj(vr_fatanual);
                  
               vr_texto := '    <Cli Cd="' || lpad(vr_tab_individ(vr_idx_individ).nrcpfcgc,8,'0') || '"' 
                                           || ' Tp="2"' 
                                           || ' Autorzc="S"' 
                                           || ' PorteCli="' || TRIM(vr_portecli) || '"' 
                                           || ' TpCtrl="01"' 
                                           || ' IniRelactCli="' || to_char(vr_dtabtcct,'YYYY-MM-DD') || '"' 
                                           || ' FatAnual="' || replace(to_char(vr_fatanual, 'fm99999999999999990D00'),',','.') || '"' 
                                           || vr_stgpecon
                                           || ' ClassCli="' || vr_classcli ||'">' ;
  
               -- Se for uma execução do paralelismo, gravar a wrk e descarregar ao final de todas as agencias.
               If vr_tpexecucao = 2 Then
                 vr_seq_relato := vr_seq_relato + 1;
                 -- Procedimento para gravar wrk, para posteriormente descarregar xml
                 pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                pr_cdagenci      => pr_cdagenci,
                                                pr_nrdconta      => vr_nrdaconta,
                                                pr_nrcpfcgc      => vr_nrcgccpf,
                                                pr_nmrelatorio   => '3040_PFJ',
                                                pr_dtmvtolt      => pr_dtrefere,
                                                pr_dscritic      => vr_texto,
                                                pr_Valor         =>  null,
                                                pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                pr_dsxml         => null,
                                                pr_des_erro      => vr_dscritic);
                 if vr_dscritic is not null then
                   vr_dscritic:= '3040_PJ - '||vr_dscritic;
                   raise vr_exc_saida;
                 end if;                                                     
               Else
                 -- Se não, gravar o xml, procedimento que já existia.                   
                 -- Enviar detalhes do cliente Juridico
                 gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                        ,pr_texto_completo => vr_xml_3040_temp
                                        ,pr_texto_novo     => vr_texto || chr(10));
               End If; -- Fim tratamento WRK

             END IF; -- Validacao de pessoa fisica ou jurisica
           END IF; -- Validacao do primeiro cpj/cnpj do cliente
        
           -- Limpar variaveis temporarias
           vr_tab_venc.delete;
           vr_vldivida := 0;
           vr_caracesp := '';
           vr_vlrctado := 0;
           vr_stperidx := '';
           vr_ctacosif := '';
           
           -- Para inddocto=5 
           IF vr_tab_individ(vr_idx_individ).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux) THEN
             -- Buscar a natureza no cadastro do movimento e já aproveitamos 
             -- a leitura para busca da data de vencimento da operação
             vr_cdnatuop := vr_tab_mvto_garant_prest(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux).dsnature;
           ELSE
             vr_cdnatuop := '01';  
           END IF;
              
           -- Efetua um loop sobre os vencimentos do risco
           FOR rw_crapvri_venct IN cr_crapvri_venct(vr_tab_individ(vr_idx_individ).cdcooper
                                                   ,vr_tab_individ(vr_idx_individ).nrdconta
                                                   ,pr_dtrefere
                                                   ,vr_tab_individ(vr_idx_individ).cdmodali
                                                   ,vr_tab_individ(vr_idx_individ).nrctremp) LOOP
             -- Zerar qtde dias vcto
             vr_diasvenc := 0;
             
             -- Se for o ultimo registro
             IF rw_crapvri_venct.nrseq = rw_crapvri_venct.qtreg THEN
               -- Guardar a data de inicio e nivel
               vr_innivris := vr_tab_individ(vr_idx_individ).innivris;
               -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
               vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);
    
               -- Reseta variaveis
               vr_tpemprst := NULL;
               vr_cddindex := NULL;
    
               -- Empréstimo da base Cecred
               IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) AND vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN
                 vr_ind_epr  := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')||lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                 IF vr_tab_crapepr.EXISTS(vr_ind_epr) THEN
                   vr_tpemprst := vr_tab_crapepr(vr_ind_epr).tpemprst;
                   vr_cddindex := vr_tab_crapepr(vr_ind_epr).cddindex;
                 END IF;
               END IF;
    
               -- Com base na modalidade retorna o codigo indexador e o percentual de indexacao
               pc_busca_coddindx(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                                ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                ,pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                                ,pr_inddocto => vr_tab_individ(vr_idx_individ).inddocto
                                ,pr_dsinfaux => vr_tab_individ(vr_idx_individ).dsinfaux
                                ,pr_tpemprst => vr_tpemprst
                                ,pr_cddindex => vr_cddindex
                                ,pr_cdorigem => vr_tab_individ(vr_idx_individ).cdorigem
                                ,pr_coddindx => vr_coddindx
                                ,pr_stperidx => vr_stperidx);
               -- Busca os dias de vencimento
               vr_diasvenc := fn_busca_dias_vencimento(rw_crapvri_venct.cdvencto);
               -- 0101 - Para adiantamento depositante ou INDDOCTO=5
               IF vr_tab_individ(vr_idx_individ).cdmodali = 0101 OR vr_tab_individ(vr_idx_individ).inddocto = 5 THEN
                 vr_vlrctado := vr_tab_individ(vr_idx_individ).vlsld59d; -- P450 - Reginaldo/AMcom
                 vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
               -- Para Limite não Utilizado, Cheque Especial, Desconto de Titulos e Desconto de Cheques
               ELSIF vr_tab_individ(vr_idx_individ).cdmodali IN(1901,0201,0301,0302) THEN
                 vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
               -- Cartões BB e Bancoob
               ELSIF vr_tab_individ(vr_idx_individ).inddocto = 4 THEN
                 vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
                 -- Valor contratado
                 vr_ind_crd  := LPAD(vr_tab_individ(vr_idx_individ).cdcooper,3,'0')||LPAD(vr_tab_individ(vr_idx_individ).nrdconta,10,'0') || LPAD(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                 IF vr_tab_tbcrd_risco.exists(vr_ind_crd) THEN 
                   vr_vlrctado := vr_tab_tbcrd_risco(vr_ind_crd).vlropcrd;
                 END IF;  
               -- 0299=Emprst,  0499=Financ e Origem 3  
               ELSIF vr_tab_individ(vr_idx_individ).cdmodali IN(0499,0299) AND vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN  
                 vr_cdvencto := 0;
                 vr_dtfimctr := vr_tab_individ(vr_idx_individ).dtvencop;
                 -- Para empréstimo BNDES
                 IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
                   -- Temos de buscar as informações da EBN
                   vr_ind_ebn := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                              || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                              || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                   -- Buscar informações que já existem na tabela                
                   vr_vlrctado := vr_tab_crapebn(vr_ind_ebn).vlropepr;                
                 ELSE
                   -- Armazenar valor contratado
                   vr_vlrctado := vr_tab_crapepr(vr_ind_epr).vlemprst;                
                   -- Tratamento da Natureza da Operacao de contratos de Empr/Fin Conta Migrada Altovale  
                   IF vr_tab_individ(vr_idx_individ).cdcooper = 16 THEN
                     -- Verifica se a conta eh de transferencia entre cooperativas
                     OPEN cr_craptco(vr_tab_individ(vr_idx_individ).cdcooper,vr_tab_individ(vr_idx_individ).nrdconta);
                     FETCH cr_craptco INTO rw_craptco;
                     -- Conta transferida 
                     IF cr_craptco%FOUND THEN 
                       -- Empréstimos anteriores a 2013
                       IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2012','dd/mm/yyyy') THEN
                         vr_cdnatuop := '02';
                         vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
                       END IF;
                     END IF;
                     CLOSE cr_craptco;
                   END IF;
                   -- Tratamento da Natureza da Operacao de contratos de Empr/Fin Conta Migrada Acredicoop  
                   IF vr_tab_individ(vr_idx_individ).cdcooper = 1 THEN
                     -- Abre o cursor de contas transferidas
                     OPEN cr_craptco_b(vr_tab_individ(vr_idx_individ).cdcooper,vr_tab_individ(vr_idx_individ).nrdconta);
                     FETCH cr_craptco_b INTO rw_craptco_b;
                     -- Conta transferida 
                     IF cr_craptco_b%FOUND THEN 
                       -- Empréstimos anteriores a 2013
                       IF vr_tab_crapepr(vr_ind_epr).dtmvtolt <= to_date('31/12/2013','dd/mm/yyyy') THEN
                         vr_cdnatuop := '02';
                         vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
                       END IF;
                     END IF;
                     CLOSE cr_craptco_b;
                   END IF;
                   
                   --> Verificar se é cessao de credito
                   IF vr_tab_individ(vr_idx_individ).flcessao = 1 THEN
                     vr_cdnatuop := '02';
                     vr_vlrdivid := vr_tab_crapepr(vr_ind_epr).vlemprst;
                   END IF;
                   
                 END IF; -- Crapebn%notfound
               END IF; -- modalidade
                  
               vr_txeanual := 0;
               -- Para:
               -- 0302 - Dsc Chq
               -- 0301 - Dsc Tit
               -- 0201 - Chq Especial
               -- 1901 - Lim Não Utzd
               -- 0299 - Empréstimos
               -- 0499 - Financiamentos
               -- 1513 - Coobrigacao
               -- OU Inddocto=5
               IF vr_tab_individ(vr_idx_individ).cdmodali IN(0302,0301,0201,1901,0299,0499,1513) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN 
                 -- Buscar Taxa Efetiva
                 vr_txeanual := fn_busca_taxeft(vr_tab_individ(vr_idx_individ).cdcooper
                                               ,vr_tab_individ(vr_idx_individ).cdmodali
                                               ,vr_tab_individ(vr_idx_individ).nrdconta
                                               ,vr_tab_individ(vr_idx_individ).nrctremp
                                               ,vr_tab_individ(vr_idx_individ).inddocto
                                               ,vr_tab_individ(vr_idx_individ).inpessoa
                                               ,vr_tab_individ(vr_idx_individ).dsinfaux
                                               ,vr_tab_individ(vr_idx_individ).cdorigem);
               -- 0101 - Para adiantamento depositante, utilizar o CL no calculo 
               ELSIF vr_tab_individ(vr_idx_individ).cdmodali = 0101  THEN
                 -- Usar Taxa Efetiva Anual - TAB0004
                 vr_txeanual := pr_txeanual;
               -- Para emprestimo/financia utilizar a data regular do final 
               ELSE
                 vr_txeanual := 0;
               END IF;
               -- Para prejuizo a taxa anual é utilizado fixo 1,00%
               --   Consensado com Roberto e Mirtes em 20/09/2010 
               IF vr_tab_individ(vr_idx_individ).innivris = 10  THEN
                 vr_txeanual := ROUND((POWER(1 + (1 / 100),12) - 1) * 100,2);
               END IF;            
             END IF; -- ultimo registro quebrado por conta e condigo de vencimento
                
             -- Se for vencimentos que ainda nao venceram
             IF rw_crapvri_venct.cdvencto >= 110 AND rw_crapvri_venct.cdvencto <= 290  THEN 
               vr_vldivida := vr_vldivida + rw_crapvri_venct.vldivida;
             END IF;
             -- Se for um vencimento ja vencido ha mais de 1621 dias
             IF rw_crapvri_venct.cdvencto = 330 THEN 
               vr_caracesp := '11';
             END IF;
             
             -- Acumula cada vencimento e seu valor 
             IF vr_tab_venc.EXISTS(rw_crapvri_venct.cdvencto) THEN
               vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida := vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida +
                                                                  rw_crapvri_venct.vldivida;
             ELSE
               vr_tab_venc(rw_crapvri_venct.cdvencto).cdvencto := rw_crapvri_venct.cdvencto;
               vr_tab_venc(rw_crapvri_venct.cdvencto).vldivida := rw_crapvri_venct.vldivida;
             END IF;
           END LOOP; -- loop sobre a cr_crapvri_venct
              
           -- Prejuizo com calc diferenciado 
           IF vr_vldivida <> 0  THEN 
             vr_vlpercen := vr_tab_percentual(vr_tab_individ(vr_idx_individ).innivris).percentual / 100;
             IF vr_tab_individ(vr_idx_individ).cdmodali = 101 THEN
               vr_vlpreatr := ROUND(( (vr_tab_individ(vr_idx_individ).vlsld59d) * vr_vlpercen),2);
             ELSE 
               vr_vlpreatr := ROUND(( (vr_vldivida - vr_tab_individ(vr_idx_individ).vljura60) * vr_vlpercen),2);
             END IF;
           END IF;

          -- Inicio da TAG de operacoes de credito <Op> 
          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            vr_texto := '        <Op';
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '2 3040_PFOP',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '2 3040_PFOP - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          ELSE 
            -- Inicio da TAG de operacoes de credito <Op> 
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '        <Op');
          End If; -- Fim tratamento WRK

          -- Se for pessoa juridica
          IF vr_tab_individ(vr_idx_individ).inpessoa = 2 THEN
            -- Imprime o numero do CNPJ
            If vr_tpexecucao = 2 Then
              vr_seq_relato := vr_seq_relato + 1;
              vr_texto := ' DetCli="' || lpad(vr_tab_individ(vr_idx_individ).nrdocnpj,14,'0') || '"';
              -- Procedimento para gravar wrk, para posteriormente descarregar xml
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => vr_nrdaconta,
                                             pr_nrcpfcgc      => vr_nrcgccpf,
                                             pr_nmrelatorio   => '2 3040_DetCli',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dscritic      => vr_texto,
                                             pr_Valor         =>  null,
                                             pr_seq_relato    => vr_seq_relato, -- nrctremp
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                vr_dscritic:= '2 3040_DetCli - '||vr_dscritic;
                raise vr_exc_saida;
              end if;
            Else   
              -- Imprime o numero do CNPJ
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => ' DetCli="' || lpad(vr_tab_individ(vr_idx_individ).nrdocnpj,14,'0') || '"');
            End If; -- Fim tratamento WRK
          END IF;

          -- Tratamento para Dias de Atraso da Parcela mais Atrasada 
          vr_flgatras := 0;
          vr_stdiasat := '';
          vr_qtcalcat := 0;
          vr_indice_venc := vr_tab_venc.last;
          WHILE vr_indice_venc IS NOT NULL LOOP
            -- Buscar somente os vencimentos entre 205 e 330
            IF vr_tab_venc(vr_indice_venc).cdvencto >= 205 AND  -- Se for dias em atraso (ja vencidos)
               vr_tab_venc(vr_indice_venc).cdvencto <= 330 THEN
              -- Calculo da qtde de dias da parcela mais atrasada 
              -- Traz o intervalo válido para a parcela em atrazo 
              vr_flgatras := 1;
              -- Para empréstimo / financiamentos ou Inddocto=5
              IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499,301,302) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
                vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdiaatr || '"';

                -- Se existir Crapepr
                vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                           || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                           || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                       
                -- Se encontrar o contrato
                IF vr_tab_crapepr.exists(vr_ind_epr) AND 
                  --> e o mesmo estiver em prejuizo
                  vr_tab_crapepr(vr_ind_epr).inprejuz = 1 THEN
                  --> utilizar os dias em atrasos calculados na central de risco(310_i)
                  vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdiaatr || '"';             
              
                ELSIF vr_tab_venc(vr_indice_venc).cdvencto = 205 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 1  OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 14) THEN
                  vr_stdiasat := ' DiaAtraso = "1"';
                ELSIF vr_tab_venc(vr_indice_venc).cdvencto = 210 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 15 OR
                                                                                 vr_tab_individ(vr_idx_individ).qtdiaatr > 30) THEN
                  vr_stdiasat := ' DiaAtraso = "15"';
                ELSIF vr_tab_venc(vr_indice_venc).cdvencto = 220 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 31 OR
                                                                                 vr_tab_individ(vr_idx_individ).qtdiaatr > 60) THEN
                  vr_stdiasat := ' DiaAtraso = "31"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 230 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 61 OR
                                                                                 vr_tab_individ(vr_idx_individ).qtdiaatr > 90) THEN
                  vr_stdiasat := ' DiaAtraso = "61"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 240 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 91 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 120) THEN
                  vr_stdiasat := ' DiaAtraso = "91"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 245 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 121 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 150) THEN
                  vr_stdiasat := ' DiaAtraso = "121"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 250 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 151 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 180) THEN
                  vr_stdiasat := ' DiaAtraso = "151"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 255 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 181 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 240) THEN
                  vr_stdiasat := ' DiaAtraso = "181"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 260 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 241 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 300) THEN
                  vr_stdiasat := ' DiaAtraso = "241"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 270 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 301 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 360) THEN
                  vr_stdiasat := ' DiaAtraso = "301"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 280 AND (vr_tab_individ(vr_idx_individ).qtdiaatr < 361 OR
                                                                                  vr_tab_individ(vr_idx_individ).qtdiaatr > 540) THEN
                  vr_stdiasat := ' DiaAtraso = "361"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 290 AND vr_tab_individ(vr_idx_individ).qtdiaatr < 541 THEN
                  vr_stdiasat := ' DiaAtraso = "541"';
                -- Baixado para prejuízo: Valores fixados
                ELSIF  (vr_tab_venc(vr_indice_venc).cdvencto = 310 OR vr_tab_venc(vr_indice_venc).cdvencto = 320)  THEN
                  vr_stdiasat := ' DiaAtraso = "541"';
                ELSIF  vr_tab_venc(vr_indice_venc).cdvencto = 330 THEN
                  vr_stdiasat := ' DiaAtraso = "1621"';
                END IF;
              ELSIF  vr_tab_individ(vr_idx_individ).cdmodali = 0101  THEN
                vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdriclq || '"';
              -- 1513 - Coobrigacao
              ELSIF  vr_tab_individ(vr_idx_individ).cdmodali = 1513  THEN
                vr_stdiasat := ' DiaAtraso = "' || vr_tab_individ(vr_idx_individ).qtdiaatr || '"';
              ELSE -- Para as demais modalidades nao terá operaçoes vencidas 
                vr_stdiasat := '';
              END IF;
              EXIT; -- Sai fora do while
            END IF;
            --ir para o registro anterior
          vr_indice_venc := vr_tab_venc.prior(vr_indice_venc);
          END LOOP;
          -- Se não encontrou no loop de atraso
          IF vr_flgatras = 0 THEN
            -- Limpar dias em atraso
            vr_stdiasat := '';
          END IF;
          -- Diferente de Cheque Especial / Conta Garantida / Limite não Utilizado ou INDDOCTO=5
          IF vr_tab_individ(vr_idx_individ).cdmodali NOT IN(0201,1901) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
            -- Para empréstimos / financiamentos OU inddocto=5
            IF vr_tab_individ(vr_idx_individ).cdmodali IN(0299,0499) OR vr_tab_individ(vr_idx_individ).inddocto=5 THEN
              -- Busca a modalidade com base nos emprestimos
              vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_individ(vr_idx_individ).cdmodali
                                                      ,vr_tab_individ(vr_idx_individ).cdcooper
                                                      ,vr_tab_individ(vr_idx_individ).nrdconta
                                                      ,vr_tab_individ(vr_idx_individ).nrctremp
                                                      ,vr_tab_individ(vr_idx_individ).inpessoa
                                                      ,vr_tab_individ(vr_idx_individ).cdorigem
                                                      ,vr_tab_individ(vr_idx_individ).dsinfaux);
              -- Busca a organização
              vr_dsorgrec := fn_busca_dsorgrec(vr_tab_individ(vr_idx_individ).cdcooper
                                              ,vr_tab_individ(vr_idx_individ).cdmodali
                                              ,vr_tab_individ(vr_idx_individ).nrdconta
                                              ,vr_tab_individ(vr_idx_individ).nrctremp
                                              ,vr_tab_individ(vr_idx_individ).cdorigem
                                              ,vr_tab_individ(vr_idx_individ).dsinfaux);
                                      
              -- Buscar valor do contrato para inddocto = 5
              IF vr_tab_individ(vr_idx_individ).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux) THEN
                -- Verificar se existe o movimento na tabela de origem das informações
                vr_vlrctado := vr_tab_mvto_garant_prest(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux).vloperac;
              ELSE 
                  
                -- Somente para emprestimos que não são do BNDES e origem 3
                IF vr_tab_individ(vr_idx_individ).dsinfaux <> 'BNDES' AND vr_tab_individ(vr_idx_individ).cdorigem = 3 THEN              
                  -- Se existir CrapEpr
                  vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');

                  -- Compara refinanciamento
                  IF vr_tab_crapepr(vr_ind_epr).idquaprc = vr_tab_crapepr(vr_ind_epr).idquapro then
                    -- Se o contrato for uma liquidação de outro contrato
                    IF vr_tab_crapepr(vr_ind_epr).qtctrliq > 0 THEN
                      IF vr_caracesp IS NOT NULL THEN
                        vr_caracesp := vr_caracesp||';';
                      END IF;
                      vr_caracesp := vr_caracesp || '01';
                    END IF;
                  ELSE
                    -- Se for refinanciamento                  
                    IF vr_caracesp IS NOT NULL THEN
                      vr_caracesp := vr_caracesp||';';
                    END IF;
                    vr_caracesp := vr_caracesp || '01';
                  END IF;
                  
                END IF; --Não BNDES
                                
                IF vr_tab_individ(vr_idx_individ).dsinfaux = 'BNDES' THEN
                      
                  vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                                 
                      
                  IF vr_tab_crapebn.exists(vr_ind_epr) THEN
                    IF vr_caracesp IS NULL THEN
                      vr_caracesp := '17';
                    ELSE
                      vr_caracesp := vr_caracesp || ';17';
                    END IF;
                  END IF;
                      
                ELSE
                  -- Se existir crapepr
                  vr_ind_epr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrdconta,10,'0')
                             || lpad(vr_tab_individ(vr_idx_individ).nrctremp,10,'0');
                  -- IDX da Linha
                  vr_idx_lcr := lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')
                             || lpad(vr_tab_crapepr(vr_ind_epr).cdlcremp,05,'0');
                                   
                  -- Verifica se linha de microcredito
                  IF vr_tab_craplcr.EXISTS(vr_idx_lcr) THEN

                    IF vr_tab_craplcr(vr_idx_lcr).dsorgrec <> ' ' AND vr_tab_craplcr(vr_idx_lcr).cdusolcr = 1  THEN
                        
                      IF vr_caracesp IS NULL THEN
                        vr_caracesp := '17';
                      ELSE
                        vr_caracesp := vr_caracesp || ';17';
                      END IF;
                        
                    END IF;  															
                  END IF;
                      
                END IF;
              END IF;
                  
            ELSE
              vr_cdmodali := vr_tab_individ(vr_idx_individ).cdmodali;
              vr_dsorgrec := '0199';
            END IF;
            -- Se for pessoa juridica e modalidade igual a 203
            IF vr_tab_individ(vr_idx_individ).inpessoa = 2 AND vr_cdmodali = '0203' THEN
              -- substituir modalidade 0203 pela 0206 capital de giro 
              vr_cdmodali := '0206';
            END IF;
            -- Montar informação do Valor Contratado
            vr_dsvlrctd := ' VlrContr="' || replace(to_char(vr_vlrctado,'fm99999999999999990D00'),',','.') || '"' ;
                
          ELSE
            -- Mod. Excluida - Antiga Chq Esp. e Conta Garantida
            IF vr_tab_individ(vr_idx_individ).cdmodali = 0201 THEN 
              -- P442 - Cecred substituir modalidade 0213 para 1401
              IF vr_tab_individ(vr_idx_individ).cdcooper = 3 THEN 
                -- Buscar limite cadastrado 
                rw_craplim := NULL;
                OPEN cr_craplim(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                               ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                               ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                               ,pr_tpctrlim => 1);
                FETCH cr_craplim INTO rw_craplim;
                CLOSE cr_craplim;
                -- busca sobre a tabela de linhas de credito rotativo
                rw_craplrt := NULL;
                OPEN cr_craplrt(vr_tab_individ(vr_idx_individ).inpessoa, rw_craplim.cddlinha );
                FETCH cr_craplrt INTO rw_craplrt;
                CLOSE cr_craplrt;
                -- Montar dados
                vr_cdmodali := nvl(rw_craplrt.cdmodali||rw_craplrt.cdsubmod,'1401'); 
                vr_dsorgrec := '0203';
                vr_dsvlrctd := ' VlrContr="' || replace(to_char(nvl(rw_craplim.vllimite,0),'fm99999999999999990D00'),',','.') || '"' ;
                IF vr_caracesp IS NOT NULL THEN
                  vr_caracesp := vr_caracesp||';';
                END IF;
                vr_caracesp := vr_caracesp || '17';
              ELSE
                vr_cdmodali := '0213';
                vr_dsorgrec := '0199';
                vr_dsvlrctd := ' ';
              END IF;
            ELSE
              vr_cdmodali := vr_tab_individ(vr_idx_individ).cdmodali;
              vr_dsorgrec := '0199';
              vr_dsvlrctd := ' ';
            END IF;
          END IF;
              
          -- Incluir caracteristica especial para inddocto=5
          IF vr_tab_individ(vr_idx_individ).inddocto = 5 AND vr_tab_mvto_garant_prest.exists(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux) THEN
            -- Buscar a caracteris no cadastro do movimento
            -- Se já existir algo
            IF vr_caracesp IS NOT NULL THEN
              vr_caracesp := vr_caracesp||';';
            END IF;
            vr_caracesp := vr_caracesp||vr_tab_mvto_garant_prest(lpad(vr_tab_individ(vr_idx_individ).cdcooper,03,'0')||vr_tab_individ(vr_idx_individ).dsinfaux).dscarces;
          END IF;

          -- Com base na modalidade encontrada retorna o Cosif (Plano Contábil das Instituições do Sistema Financeiro Nacional)
          vr_ctacosif := fn_busca_cosif(vr_tab_individ(vr_idx_individ).cdcooper
                                       ,vr_cdmodali
                                       ,vr_tab_individ(vr_idx_individ).inpessoa
                                       ,vr_tab_individ(vr_idx_individ).inddocto
                                       ,vr_tab_individ(vr_idx_individ).dsinfaux);
              
          -- Numero do contrato formatado para o arquivo 3040
          vr_nrcontrato_3040 := fn_formata_numero_contrato(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                                                          ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                                          ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                                          ,pr_cdmodali => vr_cdmodali);

          vr_cep_3040 := fn_cepende(vr_tab_individ(vr_idx_individ).cdcooper
                                   ,vr_tab_individ(vr_idx_individ).nrcpfcgc
                                   ,vr_tab_individ(vr_idx_individ).inddocto
                                   ,vr_tab_individ(vr_idx_individ).dsinfaux
                                   ,pr_flbbndes);                                                              

          -- **
          -- Verifica Ativo Problemático - Daniel(AMcom)
          pc_verif_ativo_problematico(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper -- Cooperativa
                                     ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta -- Conta
                                     ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp -- Contrato
                                     ,pr_atvprobl => vr_atvprobl                             -- Identificador de Ativo Problemático
                                     ,pr_reestrut => vr_reestrut                             -- 1-Reestruturação de crédito 0-Outros
                                     ,pr_dtatvprobl => vr_dtatvprobl                         -- Data da Reestruturação
                                     ,pr_cdcritic => vr_cdcritic                             -- Código da crítica
                                     ,pr_dscritic => vr_dscritic);                           -- Erros do processo
          -- Verifica erro
          IF vr_cdcritic = 0 THEN
            RAISE vr_exc_saida;
          ELSE
            -- Se identificou como Ativo Problemático, envia CaracEspecial=19
            IF vr_atvprobl = 1 THEN
              IF vr_caracesp IS NOT NULL THEN
                vr_caracesp := vr_caracesp||';19';
              ELSE
                vr_caracesp := '19';
              END IF;
            END IF;
          END IF;

          -- Tratamento para gravação da WRK
          vr_Texto := ' Contrt="' || TRIM(vr_nrcontrato_3040) || '"' 
                                                       || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                       || ' Cosif="' || vr_ctacosif || '"' 
                                                       || ' OrigemRec="' || vr_dsorgrec || '"'  -- Era fixo '0199', agora, retorna do pc_busca_modalidade
                                                       || ' Indx="' || vr_coddindx || '"' 
                                                       || vr_stperidx 
                                                       || ' VarCamb="'||fn_varcambial(vr_tab_individ(vr_idx_individ).cdcooper,vr_tab_individ(vr_idx_individ).inddocto,vr_tab_individ(vr_idx_individ).dsinfaux)||'"' 
                                                       || ' CEP="' || vr_cep_3040 || '"'
                                                       || ' TaxEft="' || replace(to_char(vr_txeanual,'fm990D00'),',','.') || '"' 
                                                       || ' DtContr="' || to_char(vr_tab_individ(vr_idx_individ).dtinictr,'yyyy-mm-dd') || '"' 
                                                       || vr_dsvlrctd
                                                       || ' NatuOp="' || TRIM(vr_cdnatuop) || '"' 
                                                       || ' DtVencOp="' || NVL(to_char(vr_dtfimctr,'YYYY-MM-DD'),'0000-00-00') || '"'  
                                                       || ' ClassOp="' || vr_cloperis || '"' 
                                                       || ' ProvConsttd="' ||replace(to_char(vr_vlpreatr,'fm99999999999999990D00'),',','.')||'"'
                                                       || vr_stdiasat 
                                                       || ' CaracEspecial="' || vr_caracesp ||'"';

          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3 3040_CONT',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_CONT - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          Else   
            -- Enviar detalhes da operação
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => vr_texto);
          end if;
              
          -- Tratar campos do Fluxo Financeiro
          pc_gera_fluxo_financeiro(pr_cdcooper => pr_cdcooper
                                  ,pr_cdcopemp => vr_tab_individ(vr_idx_individ).cdcooper
                                  ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                  ,pr_dtrefere => pr_dtrefere
                                  ,pr_inddocto => vr_tab_individ(vr_idx_individ).inddocto                                
                                  ,pr_cdinfadi => vr_tab_individ(vr_idx_individ).cdinfadi
                                  ,pr_innivris => vr_tab_individ(vr_idx_individ).innivris
                                  ,pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                                  ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                  ,pr_nrseqctr => vr_tab_individ(vr_idx_individ).nrseqctr
                                  ,pr_dtprxpar => vr_tab_individ(vr_idx_individ).dtprxpar
                                  ,pr_vlprxpar => vr_tab_individ(vr_idx_individ).vlprxpar
                                  ,pr_qtparcel => vr_tab_individ(vr_idx_individ).qtparcel); 
          -- Fechar a Tag Op                                         
          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            vr_texto :=  '>';
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_FECTAG >2',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
            vr_seq_relato := vr_seq_relato + 1;
            vr_texto := '            <Venc';
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_ABRTAG <Vc',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          Else   
            -- Fechar a tah Op                                          
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '>' || chr(10) 
                                                      ||'            <Venc');
          end if;
              
          -- Inicializar valores em atraso  
          vr_vlpreatr := 0;
          -- tratamento de normalizacao de juros com cdvencto >=230 ou <=290
          vr_indice_venc := vr_tab_venc.first;
          WHILE vr_indice_venc IS NOT NULL LOOP
            IF vr_tab_venc(vr_indice_venc).cdvencto >= 230 AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
              EXIT;
            END IF;
            vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
          END LOOP;
          -- Se encontrou vencimento
          IF vr_indice_venc IS NOT NULL THEN
            -- Calcular valor total da divida
            vr_ttldivid := fn_total_divida(230,290,vr_tab_venc);
            -- Acumula as faixas desprezando a primeira
            vr_vljurfai := 0;
            vr_flgfirst := 1;
            WHILE vr_indice_venc IS NOT NULL LOOP
              IF vr_tab_venc(vr_indice_venc).cdvencto >= 230 AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
                IF vr_flgfirst = 1 THEN
                   vr_flgfirst := 0;
                   vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
                   continue;
                END IF;
                -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
                vr_vlacumul := fn_normaliza_juros(vr_ttldivid
                                                 ,vr_tab_venc(vr_indice_venc).vldivida
                                                 ,vr_tab_individ(vr_idx_individ).vljura60
                                                 ,FALSE);
                vr_vljurfai := vr_vljurfai + vr_vlacumul;
              END IF;
              vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
            END LOOP;
           -- fim do acumula faixa 
          END IF;
          
          -- fim tratamento de normalizacao de juros 
          vr_flgfirst := 1;
          vr_indice_venc := vr_tab_venc.first;
          WHILE vr_indice_venc IS NOT NULL LOOP
            IF  vr_tab_venc(vr_indice_venc).cdvencto >= 230
            AND vr_tab_venc(vr_indice_venc).cdvencto <= 290 THEN
              IF vr_flgfirst = 1 THEN
                -- Para conta corrente, não desconta o valor dos juros +60 (os juros já foram subtraídos do valor da dívida - vlsld59d)
                IF vr_tab_individ(vr_idx_individ).cdmodali = 101 THEN
                  vr_vldivnor := vr_ttldivid - vr_vljurfai;
                ELSE
                  vr_vldivnor := vr_ttldivid - vr_tab_individ(vr_idx_individ).vljura60 - vr_vljurfai;
                END IF;
                vr_flgfirst := 0;
              ELSE
                -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
                IF vr_tab_individ(vr_idx_individ).cdmodali = 101 THEN
                  vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                                   ,vr_tab_venc(vr_indice_venc).vldivida
                                                   ,0
                                                   ,true);                  
                ELSE
                  vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                                   ,vr_tab_venc(vr_indice_venc).vldivida
                                                   ,vr_tab_individ(vr_idx_individ).vljura60
                                                   ,true);
                END IF;
              END IF;
            ELSE
              vr_vldivnor := vr_tab_venc(vr_indice_venc).vldivida;
            END IF;
            -- Se a modalidade ainda não foi inicializada
            IF NOT vr_tab_totmodali.exists(vr_cdmodali) THEN
              vr_tab_totmodali(vr_cdmodali) := 0;
            END IF;

            --IF vr_vldivnor <> 0 THEN
            IF vr_vldivnor > 0 or vr_vldivnor < -100 or nvl(vr_tab_venc.count,0) = 1 THEN /*SD#855059*/
              IF vr_vldivnor <= 0 and vr_vldivnor > -100 THEN /*SD#855059*/
                vr_vldivnor := 1/100; --atribui 0,01 /*SD#855059*/
              END IF; /*SD#855059*/
              -- Acumular
              vr_tab_totmodali(vr_cdmodali) := vr_tab_totmodali(vr_cdmodali) + nvl(vr_vldivnor,0);          
              
              -- ***
              -- Subtrair os Juros + 60 do valor total da dívida nos casos de empréstimos/ financiamentos (cdorigem = 3)
              -- estejam em Prejuízo (innivris = 10)
              IF vr_tab_individ(vr_idx_individ).cdorigem = 3 
              AND vr_tab_individ(vr_idx_individ).innivris = 10 THEN
                vr_vljuro60 := nvl((PREJ0001.fn_juros60_emprej(pr_cdcooper => pr_cdcooper
                                                              ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                                              ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp)),0);
                -- Se o valor da divida for maior que juros60
                IF vr_vldivnor > vr_vljuro60 THEN
                  vr_vldivnor := vr_vldivnor - vr_vljuro60;
                END IF;
              END IF;
              
              -- Enviar vencimento
              vr_texto := ' v' || vr_tab_venc(vr_indice_venc).cdvencto 
                                                          || '="' || replace(to_char(vr_vldivnor,'fm99999999990D00'),',','.') 
                                                          || '"';
               
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_nrdaconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_VCTO',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         =>  null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;
              Else   
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto);
              end if;
            END IF;  
                                                              
            vr_indice_venc := vr_tab_venc.next(vr_indice_venc);
          END LOOP;
              
          If vr_tpexecucao = 2 Then
            vr_texto := '/>';
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_FECTAG />',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_FECTAG - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          else
            -- Finaliza a TAG <Venc> 
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '/>'||chr(10));
          end if;
          -- Quando existir mais de um contrato de origem = 1 (Conta)
          -- os garantidores devem ir preferencialmente no limite não utilizado (1901),
          -- então testamos a flag que é ativa quando já foram enviados os garantidores no CPF
          IF vr_tab_individ(vr_idx_individ).cdorigem = 1 THEN
            -- Enviar sempre que for de Limite não utilizado, ou do contrário enviar somente 
            -- se a flag estiver falsa ainda, ou seja, ainda não enviamos pelo 1901 ou inexiste
            IF vr_tab_individ(vr_idx_individ).cdmodali = 1901 OR NOT vr_flgarant THEN
              -- Enviar Avalistas 
              pc_verifica_garantidores;          
            END IF;          
            -- Ativamos a Flag
            vr_flgarant := TRUE;
          ELSE
            -- Enviamos os garantidores independente da modalidade
            pc_verifica_garantidores;          
          END IF;  
          -- Bens Alienados 
          pc_garantia_alienacao_fid;
        
          -- Incluir garantias
          pc_garantia_cobertura_opera(vr_dscritic);
        
          -- Condicao para verificar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
             
        
          -- Imprime o tipo informando que eh aplicacao regulatoria, quando o emprestimo possuir linhas de credito
          pc_inf_aplicacao_regulatoria(pr_cdcooper,
                                       vr_tab_individ(vr_idx_individ).cdcooper,
                                       vr_tab_individ(vr_idx_individ).nrdconta,
                                       vr_tab_individ(vr_idx_individ).nrctremp,
                                       vr_tab_individ(vr_idx_individ).cdmodali,
                                       vr_tab_individ(vr_idx_individ).cdorigem,
                                       vr_tab_individ(vr_idx_individ).dsinfaux);
          -- Imprime o codigo do chassi
          pc_verifica_inf_chassi(pr_cdcooper,
                                 vr_tab_individ(vr_idx_individ).cdcooper,
                                 vr_tab_individ(vr_idx_individ).nrdconta,
                                 vr_tab_individ(vr_idx_individ).nrctremp,
                                 vr_tab_individ(vr_idx_individ).cdmodali,
                                 vr_tab_individ(vr_idx_individ).cdorigem,
                                 vr_tab_individ(vr_idx_individ).dsinfaux);
          vr_vlrdivid := vr_tab_individ(vr_idx_individ).vldivida - vr_tab_individ(vr_idx_individ).vljura60;
          -- TAG <Inf> para NatuOp="02" emprestimos/financiamentos migrados
          IF ( vr_cdnatuop = '02' ) THEN
            vr_idcpfcgc := '';
            -- Somente na Viacredi
            IF vr_tab_individ(vr_idx_individ).cdcooper = 1 THEN
              vr_idcpfcgc := substr(lpad(vr_tab_crapcop(2).nrdocnpj,14,'0'),1,8);
            -- Somente na AltoVale
            ELSIF vr_tab_individ(vr_idx_individ).cdcooper = 16 THEN
              vr_idcpfcgc := substr(lpad(vr_tab_crapcop(1).nrdocnpj,14,'0'),1,8);
            END IF;
                
            IF vr_tab_individ(vr_idx_individ).flcessao = 1 THEN
              vr_texto := '            <Inf Tp="1001" Cd="'|| to_char(vr_tab_individ(vr_idx_individ).dtinictr,'RRRR-MM-DD')
                                                           || '" Ident="02038232" '
                                                           || 'Valor="' || replace(to_char(vr_tab_crapepr(vr_ind_epr).vlemprst,'fm99999999999999990D00'),',','.')
                                                           || '"/>'; 
              -- **
              -- Verifica Ativo Problemático(REESTRUTURAÇÃO) - Daniel(AMcom)
              IF vr_reestrut = 1 AND vr_dtatvprobl IS NOT NULL THEN
                -- Enviar informação adicional do contrato de Reestruturação
                VR_TEXTO := vr_texto||chr(10)|| '            <Inf Tp="1701"' -- Fixo
                                                || ' Cd="' ||vr_dtatvprobl || '"'
                                                || '/>';
              END IF;
                                                            
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_nrdaconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_INFADCONT_TPID',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         => vr_tab_crapepr(vr_ind_epr).vlemprst,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_INFADCONT_TPID - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;
              Else
                -- Enviar informação adicional da operação
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              end if;
            ELSE
              vr_texto :=  '            <Inf Tp="1001" Cd="2013-01-02" Ident="'||vr_idcpfcgc||'" '
                                                              || 'Valor="' || replace(to_char(vr_vlrdivid,'fm99999999999999990D00'),',','.')
                                                      || '"/>';          
              -- **
              -- Verifica Ativo Problemático(REESTRUTURAÇÃO) - Daniel(AMcom)
              IF vr_reestrut = 1 AND vr_dtatvprobl IS NOT NULL THEN
                -- Enviar informação adicional do contrato de Reestruturação
                    VR_TEXTO := vr_texto||chr(10)|| '            <Inf Tp="1701"' -- Fixo
                                         || ' Cd="' ||vr_dtatvprobl || '"'
                                         || '/>';
              END IF;
                                                                                
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_nrdaconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_INFADCONT_TPCD',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         => vr_vlrdivid,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_INFADCONT_TPCD - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;
              else
                -- Enviar informação adicional da operação
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              end if;
              
            END IF;
          -- ****
          -- TAG <Inf Tp> para NatuOp <> "02", no caso de Ativo Problemático
          ELSE
            -- **
            -- Verifica Ativo Problemático(REESTRUTURAÇÃO) - Daniel(AMcom)
            IF vr_reestrut = 1 AND vr_dtatvprobl IS NOT NULL THEN
              -- Enviar informação adicional do contrato de Reestruturação
               VR_TEXTO := '            <Inf Tp="1701"' -- Fixo
                                        || ' Cd="' ||vr_dtatvprobl || '"'
                                        || '/>';
              -- Enviar informação adicional da operação
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => vr_texto || chr(10));              
              
              
            END IF;
          END IF;
          -- Verificação do Ente Consignante
          pc_inf_ente_consignante(pr_cdcooper => vr_tab_individ(vr_idx_individ).cdcooper
                                 ,pr_nrdconta => vr_tab_individ(vr_idx_individ).nrdconta
                                 ,pr_nrctremp => vr_tab_individ(vr_idx_individ).nrctremp
                                 ,pr_cdmodali => vr_tab_individ(vr_idx_individ).cdmodali
                                 ,pr_dsinfaux => vr_tab_individ(vr_idx_individ).dsinfaux);
          
          vr_texto := '        </Op>';
          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => '3040_INFADCONT',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_INFADCONT - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          else
            -- Finaliza a TAG <Op>
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '        </Op>' ||chr(10));
          end if;
               
          -- Verifica se eh o ultimo registro da conta
          IF vr_tab_individ.next(vr_idx_individ) IS NULL OR vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.next(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do proximo
            -- Imprimir as saidas deste cliente
            pc_busca_saidas(vr_tab_individ(vr_idx_individ).nrcpfcgc,
                            vr_tab_individ(vr_idx_individ).innivris,
                            vr_tab_individ(vr_idx_individ).inpessoa);

            vr_texto := '    </Cli>';
            If vr_tpexecucao = 2 Then
              vr_seq_relato := vr_seq_relato + 1;
              -- Procedimento para gravar wrk, para posteriormente descarregar xml
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => vr_nrdaconta,
                                             pr_nrcpfcgc      => vr_nrcgccpf,
                                             pr_nmrelatorio   => '3040_FECCONT',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dscritic      => vr_texto,
                                             pr_Valor         =>  null,
                                             pr_seq_relato    => vr_seq_relato, -- nrctremp
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                vr_dscritic:= '3040_FECCONT - '||vr_dscritic;
                raise vr_exc_saida;
              end if;
            else
              -- Finaliza a tag do cliente
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '    </Cli>' ||chr(10));
            end if;
          END IF;
              
          if vr_tpexecucao = 1 then  --execucao sem paralelismo

            IF vr_tab_individ.prior(vr_idx_individ) IS NULL OR  -- Se for o primeiro registro
              vr_tab_individ.next(vr_idx_individ)  IS NULL OR   -- ou se for o ultimo
              vr_tab_individ(vr_idx_individ).nrcpfcgc <> vr_tab_individ(vr_tab_individ.next(vr_idx_individ)).nrcpfcgc THEN -- Se o CGC/CPF for diferente do anterior
              -- Conta a quantidade de clientes do arquivo 3040
              vr_contacli := vr_contacli + 1;
              ------------------------------------------------------------------------------------------------
              -- INICIO PARA VERIFICAR A DIVISAO DO ARQUIVO 3040 EM PARTES
              ------------------------------------------------------------------------------------------------
              IF vr_contacli >= vr_qtregarq_3040 THEN
                
                -- Condicao para verificar se eh o ultimo arquivo particionado
                IF NOT vr_tab_individ.EXISTS(vr_tab_individ.NEXT(vr_idx_individ)) AND 
                  vr_tab_saida.first IS NULL AND vr_tab_agreg.first IS NULL      THEN
                  vr_flgfimaq := TRUE;
                END IF;
                 
                -- Solicita para gerar o arquivo 3040 particionado
                pc_solicita_relato_3040(pr_nrdocnpj      => vr_tab_crapcop(pr_cdcooper).nrdocnpj
                                       ,pr_dsnomscr      => vr_tab_crapcop(pr_cdcooper).dsnomscr
                                       ,pr_dsemascr      => vr_tab_crapcop(pr_cdcooper).dsemascr
                                       ,pr_dstelscr      => vr_tab_crapcop(pr_cdcooper).dstelscr
                                       ,pr_cdprogra      => vr_cdprogra
                                       ,pr_dtmvtolt      => pr_dtmvtolt
                                       ,pr_dtrefere      => pr_dtrefere
                                       ,pr_flbbndes      => pr_flbbndes
                                       ,pr_flgfimaq      => vr_flgfimaq
                                       ,pr_totalcli      => vr_totalcli
                                       ,pr_nom_direto    => vr_nom_dirsal
                                       ,pr_nom_dirmic    => vr_nom_dirmic
                                       ,pr_numparte      => vr_numparte
                                       ,pr_xml_3040      => vr_xml_3040
                                       ,pr_xml_3040_temp => vr_xml_3040_temp
                                       ,pr_cdcritic      => vr_cdcritic
                                       ,pr_dscritic      => vr_dscritic);
                                        
                -- Condicao para verificar se houve erro
                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
                 
                -- Zera o contador de cliente
                vr_contacli := 0;
              END IF;
            END IF;   
          END IF;  -- fim execucao sem paralelismo 
                
          -- Vai para o proximo registro
          vr_idx_individ := vr_tab_individ.next(vr_idx_individ);
        END LOOP; -- loop sobre a pl_table vr_tab_individ
            
        -- Imprimir contratos de saída da operação que ainda não foram enviados ao Doc3040
        -- OU seja, aqueles clientes que não possuiam nenhum contrato ativo
        vr_indice_crapris := vr_tab_saida.first;
        WHILE vr_indice_crapris IS NOT NULL LOOP
          vr_fatanual := 0;
          vr_vlrrendi := 0;
          vr_portecli := 0;
          -- Infos do Cliente
          IF vr_indice_crapris = vr_tab_saida.first OR -- Se for o primeiro registro
             vr_tab_saida(vr_indice_crapris).sbcpfcgc <> vr_tab_saida(vr_tab_saida.prior(vr_indice_crapris)).sbcpfcgc THEN -- Se o cpf/cnpj anterior for diferente do atual
            -- Busca dados do associado
            pc_busca_dados_associ(vr_tab_saida(vr_indice_crapris).cdcooper
                                 ,vr_tab_saida(vr_indice_crapris).nrdconta
                                 ,vr_tab_saida(vr_indice_crapris).sbcpfcgc
                                 ,vr_dsnivris_ass
                                 ,vr_dtadmiss_ass
                                 ,vr_cdcritic);
            IF vr_cdcritic > 0 THEN
              RAISE vr_exc_saida;
            END IF;
            IF vr_dtadmiss_ass IS NULL OR to_char(vr_dtadmiss_ass,'yyyy') < 1000 THEN
              vr_dtabtcct := trunc(SYSDATE);
            ELSE
              vr_dtabtcct := vr_dtadmiss_ass;
            END IF;
            IF vr_dsnivris_ass = 'HH' THEN
              vr_classcli := 'H';
            ELSIF TRIM(vr_dsnivris_ass) IS NOT NULL THEN
              vr_classcli := vr_dsnivris_ass;
            ELSE
              vr_classcli := 'A';  
            END IF;
            IF vr_tab_saida(vr_indice_crapris).inpessoa = 1 THEN
              -- Abre o cursor de titulares da conta
              OPEN cr_crapttl(vr_tab_saida(vr_indice_crapris).cdcooper,vr_tab_saida(vr_indice_crapris).nrdconta);
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN -- Se encontrou registro
                -- Somar salário + aplicações
                vr_vlrrendi := NVL(rw_crapttl.vlsalari,0)    + 
                               NVL(rw_crapttl.vldrendi##1,0) + 
                               NVL(rw_crapttl.vldrendi##2,0) + 
                               NVL(rw_crapttl.vldrendi##3,0) +
                               NVL(rw_crapttl.vldrendi##4,0) + 
                               NVL(rw_crapttl.vldrendi##5,0) + 
                               NVL(rw_crapttl.vldrendi##6,0);
              END IF;
              CLOSE cr_crapttl; -- Fecha o cursor de titulares da conta
              -- Classifica o porte do cliente
              vr_portecli := fn_classifi_porte_pf(vr_vlrrendi);
              -- Valor do rendimento nao pode ser zero
              IF vr_vlrrendi = 0 THEN
                vr_vlrrendi := 0.01;
              END IF;
              
              -- CPF
              vr_nrcgccpf := to_char(vr_tab_saida(vr_indice_crapris).nrcpfcgc,'fm00000000000');

             IF vr_tab_saida(vr_indice_crapris).nrdgrupo > 0 THEN
               vr_stgpecon := ' CongEcon="' ||to_char(vr_tab_saida(vr_indice_crapris).nrdgrupo) || '"';
             END IF;
              -- Gerar tag do Cliente Fisico
            vr_texto := '    <Cli Cd="' || to_char(vr_tab_saida(vr_indice_crapris).nrcpfcgc,'fm00000000000') || '"' || 
                                ' Tp="1"'         ||
                                ' Autorzc="S"'    ||
                                ' PorteCli="'     || vr_portecli || '"' ||
                                ' IniRelactCli="' || to_char(vr_dtabtcct, 'yyyy-mm-dd') || '"' ||
                                ' FatAnual="'     || REPLACE(to_char(vr_vlrrendi, 'fm9999999999990D00'),',','.') || '"' || 
                                  vr_stgpecon       ||
                                ' ClassCli="'     || vr_classcli || '">';
              If vr_tpexecucao = 2 Then
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_nrdaconta,
                                               pr_nrcpfcgc      => vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_CLIFI',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         =>  null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_CLIFI - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;
              Else                    
                -- Gerar tag do Cliente Fisico
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              end if;
            ELSE --vr_tab_saida(vr_indice_crapris).inpessoa <> 1

              -- PESSOA JURIDICA
              OPEN cr_crapjfn(vr_tab_saida(vr_indice_crapris).cdcooper,
                              vr_tab_saida(vr_indice_crapris).nrdconta);
              FETCH cr_crapjfn INTO vr_fatanual;
              CLOSE cr_crapjfn; -- Fecha o cursor dos dados financeiros de PJ
              -- Validador nao aceita faturamento zerado nem negativo 
              IF vr_fatanual <= 0 THEN
                vr_fatanual := 1;
              END IF;
              -- Classifica o porte do cliente
              vr_portecli := fn_classifi_porte_pj(vr_fatanual);
              -- Formatar cnpj
              vr_nrdocnpj := to_char(vr_tab_saida(vr_indice_crapris).nrcpfcgc,'fm00000000000000');

              vr_nrdocnpj_base := substr(vr_nrdocnpj, 1, 8);

              IF vr_tab_saida(vr_indice_crapris).nrdgrupo > 0 THEN
                vr_stgpecon := ' CongEcon="' ||to_char(vr_tab_saida(vr_indice_crapris).nrdgrupo) || '"';
              END IF;

              -- Salvando dados em variável de trabalho.                     
              vr_texto := '    <Cli Cd="' || vr_nrdocnpj_base || '"' ||
                                  ' Tp="2"'         ||
                                  ' Autorzc="S"'    ||
                                  ' PorteCli="'     || vr_portecli || '"' ||
                                  ' TpCtrl="01"'    ||
                                  ' IniRelactCli="' || to_char(vr_dtabtcct, 'yyyy-mm-dd') || '"' ||
                                  ' FatAnual="'     || REPLACE(to_char(vr_fatanual,'fm99999999999999990D00'),',','.') || '"' ||
                                    vr_stgpecon       ||
                                  ' ClassCli="'     || vr_classcli || '">';

            IF vr_tpexecucao = 2 THEN
                vr_seq_relato := vr_seq_relato + 1;
                -- Procedimento para gravar wrk, para posteriormente descarregar xml
                pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                               pr_cdagenci      => pr_cdagenci,
                                               pr_nrdconta      => vr_nrdaconta,
                                               pr_nrcpfcgc      => vr_nrdocnpj_base,--vr_nrcgccpf,
                                               pr_nmrelatorio   => '3040_CLIJU',
                                               pr_dtmvtolt      => pr_dtrefere,
                                               pr_dscritic      => vr_texto,
                                               pr_Valor         =>  null,
                                               pr_seq_relato    => vr_seq_relato, -- nrctremp
                                               pr_dsxml         => null,
                                               pr_des_erro      => vr_dscritic);
                if vr_dscritic is not null then
                  vr_dscritic:= '3040_CLIJU - '||vr_dscritic;
                  raise vr_exc_saida;
                end if;
              Else                    
                -- Gerar Tag do cliente Juridico
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => vr_texto || chr(10));
              end if;
            END IF; -- vr_tab_saida(vr_indice_crapris).inpessoa = 1
          END IF; -- Primeiro CPF / CNPF diferente
              
          -- Chamar código comum para impressão da OP de saída
          pc_imprime_saida(pr_cdcooper => vr_tab_saida(vr_indice_crapris).cdcooper
                          ,pr_innivris => vr_tab_saida(vr_indice_crapris).innivris
                          ,pr_idxsaida => vr_indice_crapris); 
                
          -- Se for o ultimo registro
        IF vr_tab_saida.next(vr_indice_crapris) IS NULL
        OR vr_tab_saida(vr_indice_crapris).sbcpfcgc <> vr_tab_saida(vr_tab_saida.next(vr_indice_crapris)).sbcpfcgc THEN
          -- Se o cpf/cnpj posterior for diferente do atual
          IF vr_tpexecucao = 2 THEN
              vr_seq_relato := vr_seq_relato + 1;
              vr_texto := '    </Cli>';
              -- Procedimento para gravar wrk, para posteriormente descarregar xml
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => vr_nrdaconta,
                                             pr_nrcpfcgc      => vr_tab_saida(vr_indice_crapris).sbcpfcgc,
                                             pr_nmrelatorio   => '3040_FECTAG /Cli',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dscritic      => vr_texto,
                                             pr_Valor         =>  null,
                                             pr_seq_relato    => vr_seq_relato, -- nrctremp
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
              if vr_dscritic is not null then
                vr_dscritic:= '3040_FECTAGCLI - '||vr_dscritic;
                raise vr_exc_saida;
              end if;
            else
              -- Encerrar a tag do cliente
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => '    </Cli>' || chr(10));
            end if;
          END IF;
          vr_indice_crapris := vr_tab_saida.next(vr_indice_crapris);
        END LOOP;
        -- fim da impressao das saídas
            
        IF vr_texto_xml IS NOT NULL THEN 
          -- Procedimento para gravar wrk, para posteriormente descarregar xml
          pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                         pr_cdagenci      => pr_cdagenci,
                                         pr_nrdconta      => vr_nrdaconta,
                                         pr_nrcpfcgc      => vr_nrcgccpf,
                                         pr_nmrelatorio   => '3040_FECTAGCLI',
                                         pr_dtmvtolt      => pr_dtrefere,
                                         pr_dschave       => 'ULTIMO_TEXTO',
                                         pr_dscritic      => vr_texto_xml,
                                         pr_Valor         =>  null,
                                         pr_seq_relato    => vr_seq_relato, -- nrctremp
                                         pr_dsxml         => null,
                                         pr_des_erro      => vr_dscritic);
          if vr_dscritic is not null then
             vr_dscritic:= '3040_FECTAGCLI - '||vr_dscritic;
             raise vr_exc_saida;
          end if;
        END IF;            
            
        -- Por fim, geração das informações agregadas
        vr_indice_agreg := vr_tab_agreg.first;
        WHILE vr_indice_agreg IS NOT NULL LOOP
          vr_vlpreatr := 0;
          vr_innivris := vr_tab_agreg(vr_indice_agreg).innivris;
          -- Com base no indicador de risco, eh retornardo a classe de operacao de risco
          vr_cloperis := fn_classifica_risco(pr_innivris => vr_innivris);
          -- Calcular a provisao 
          -- Para risco <> 10 soma as variveis de provisao 
          -- LImite não contratado (1901) também não calculará provisão
          IF  vr_tab_agreg(vr_indice_agreg).innivris <> 10
          AND vr_tab_agreg(vr_indice_agreg).cdmodali <> 1901 THEN
            vr_vlpercen := vr_tab_percentual(vr_tab_agreg(vr_indice_agreg).innivris).percentual / 100;
            vr_vlpreatr := ROUND(( (vr_tab_agreg(vr_indice_agreg).vldivida - vr_tab_agreg(vr_indice_agreg).vljura60 ) * vr_vlpercen),2);
          END IF;
          -- Busca a modalidade com base nos emprestimos
          vr_cdmodali := fn_busca_modalidade_bacen(vr_tab_agreg(vr_indice_agreg).cdmodali
                                                  ,vr_tab_agreg(vr_indice_agreg).cdcooper
                                                  ,vr_tab_agreg(vr_indice_agreg).nrdconta
                                                  ,vr_tab_agreg(vr_indice_agreg).nrctremp
                                                  ,vr_tab_agreg(vr_indice_agreg).inpessoa
                                                  ,vr_tab_agreg(vr_indice_agreg).cdorigem
                                                  ,vr_tab_agreg(vr_indice_agreg).dsinfaux);
          -- Busca a organização
          vr_dsorgrec := fn_busca_dsorgrec(vr_tab_agreg(vr_indice_agreg).cdcooper
                                          ,vr_tab_agreg(vr_indice_agreg).cdmodali
                                          ,vr_tab_agreg(vr_indice_agreg).nrdconta
                                          ,vr_tab_agreg(vr_indice_agreg).nrctremp
                                          ,vr_tab_agreg(vr_indice_agreg).cdorigem
                                          ,vr_tab_agreg(vr_indice_agreg).dsinfaux);                              
                          
          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Populado variável de trabalho para utilização na WRK
            vr_Texto := '    <Agreg' 
                        || ' NatuOp="' || vr_tab_agreg(vr_indice_agreg).cdnatuop || '"' 
                        || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                        || ' OrigemRec="0100"' 
                        || ' VincME="N"' 
                        || ' ClassOp="' || vr_cloperis || '"' 
                        || ' FaixaVlr="' || vr_tab_agreg(vr_indice_agreg).cddfaixa || '"' 
                        || ' Localiz="' || fn_localiza_uf(pr_sig_UF => vr_tab_crapcop(pr_cdcooper).cdufdcop) || '"' 
                        || ' TpCli="' || vr_tab_agreg(vr_indice_agreg).inpessoa || '"' 
                        || ' TpCtrl="01"' 
                        
                        || ' DesempOp="' || to_char(vr_tab_agreg(vr_indice_agreg).cddesemp,'fm00') || '"'; 
            vr_chave := vr_tab_agreg(vr_indice_agreg).cdnatuop || ';' 
                     || to_char(vr_cdmodali,'fm0000') || ';' 
                     || '0100' || ';'
                     || 'N' || ';'
                     || vr_cloperis || ';' 
                     || vr_tab_agreg(vr_indice_agreg).cddfaixa || ';' 
                     || fn_localiza_uf(pr_sig_UF => vr_tab_crapcop(pr_cdcooper).cdufdcop) || ';' 
                     || vr_tab_agreg(vr_indice_agreg).inpessoa || ';' 
                     || '01' || ';'
                     || to_char(vr_tab_agreg(vr_indice_agreg).cddesemp,'fm00') || ';                             '
                     || 'QtdOp='  || to_char(vr_tab_agreg(vr_indice_agreg).qtoperac,'fm0000000') || ';' 
                     || 'QtdCli=' || to_char(vr_tab_agreg(vr_indice_agreg).qtcooper,'fm0000000') || ';';

            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => 'TAG_AGREG',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dschave       => vr_chave,
                                           pr_dscritic      => vr_texto,
                                           pr_Valor         => vr_vlpreatr,
                                           pr_seq_relato    => vr_seq_relato ,-- nrctremp
                                           pr_dsxml         => vr_indice_agreg,
                                           pr_des_erro      => vr_dscritic);

            if vr_dscritic is not null then
              vr_dscritic:= '3040_INFAGRE - '||vr_dscritic;
              raise vr_exc_saida;
            end IF;
          Else   
            -- Enviar a informação agregada
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '    <Agreg' 
                                                      || ' NatuOp="' || vr_tab_agreg(vr_indice_agreg).cdnatuop || '"' 
                                                      || ' Mod="' || to_char(vr_cdmodali,'fm0000') || '"' 
                                                      || ' OrigemRec="0100"' 
                                                      || ' VincME="N"' 
                                                      || ' ClassOp="' || vr_cloperis || '"' 
                                                      || ' FaixaVlr="' || vr_tab_agreg(vr_indice_agreg).cddfaixa || '"' 
                                                      || ' Localiz="' || fn_localiza_uf(pr_sig_UF => vr_tab_crapcop(pr_cdcooper).cdufdcop) || '"' 
                                                      || ' TpCli="' || vr_tab_agreg(vr_indice_agreg).inpessoa || '"' 
                                                      || ' TpCtrl="01"' 
                                                      || ' DesempOp="' || to_char(vr_tab_agreg(vr_indice_agreg).cddesemp,'fm00') || '"' 
                                                      || ' ProvConsttd="' || replace(to_char(vr_vlpreatr,'fm999999990D00'),',','.') || '"' 
                                                      || ' QtdOp="' || vr_tab_agreg(vr_indice_agreg).qtoperac || '"' 
                                                      || ' QtdCli="' || vr_tab_agreg(vr_indice_agreg).qtcooper || '">' ||chr(10) 
                                                      || '        <Venc');
          end if;
              
          -- tratamento de normalizacao de juros com cdvencto >=230 ou <=290
          vr_indice_venc_agreg := vr_tab_venc_agreg.first;
          WHILE vr_indice_venc_agreg IS NOT NULL LOOP
            IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
              EXIT;
            END IF;
            vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
          END LOOP;
          IF vr_indice_venc_agreg IS NOT NULL THEN
            -- Retorna o valor total da divida da faixa 230 a 290
            vr_ttldivid := fn_total_divida_agreg(230
                                                ,290
                                                ,vr_tab_agreg(vr_indice_agreg).cdmodali
                                                ,vr_tab_agreg(vr_indice_agreg).innivris
                                                ,vr_tab_agreg(vr_indice_agreg).cddfaixa
                                                ,vr_tab_agreg(vr_indice_agreg).inpessoa
                                                ,vr_tab_agreg(vr_indice_agreg).cddesemp
                                                ,vr_tab_agreg(vr_indice_agreg).cdnatuop
                                                ,vr_tab_venc_agreg);
            -- acumular faixas desprezando a primeira 
            vr_vljurfai := 0;
            vr_flgfirst := 1;
            WHILE vr_indice_venc_agreg IS NOT NULL LOOP
              IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
                IF vr_flgfirst = 1 THEN
                  vr_flgfirst := 0;
                  vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
                  continue;
                END IF;
			    -- Reginaldo/AMcom/P450 (13/11/2018) - Correção da inconsistência nos valores dos vencimentos para a modalidade 101
			    IF vr_tab_agreg(vr_indice_agreg).cdorigem <> 1 THEN
                    -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
                    vr_vlacumul := fn_normaliza_juros(vr_ttldivid
                                                     ,vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida
                                                     ,vr_tab_agreg(vr_indice_agreg).vljura60
                                                     ,false);
                    vr_vljurfai := vr_vljurfai + vr_vlacumul;
			    ELSE
				    -- Reginaldo/AMcom/P450 (13/11/2018) - Correção da inconsistência nos valores dos vencimentos para a modalidade 101
				    vr_vljurfai := vr_vljurfai + vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida; 
			    END IF;
              END IF;
              vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
            END LOOP;
          END IF;
          -- fim tratamento de normalizacao de juros 
          vr_vlpreatr := 0;
          vr_flgfirst := 1;
          vr_indice_venc_agreg := vr_tab_venc_agreg.first;
          WHILE vr_indice_venc_agreg IS NOT NULL LOOP
            IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdmodali = vr_tab_agreg(vr_indice_agreg).cdmodali AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).innivris = vr_tab_agreg(vr_indice_agreg).innivris AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddfaixa = vr_tab_agreg(vr_indice_agreg).cddfaixa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).inpessoa = vr_tab_agreg(vr_indice_agreg).inpessoa AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cddesemp = vr_tab_agreg(vr_indice_agreg).cddesemp AND
               vr_tab_venc_agreg(vr_indice_venc_agreg).cdnatuop = vr_tab_agreg(vr_indice_agreg).cdnatuop THEN
              IF vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto >= 230 AND
                 vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto <= 290 THEN
                IF vr_flgfirst = 1 THEN

                  IF vr_tab_agreg(vr_indice_agreg).cdmodali = 101 THEN
                    vr_vldivnor := vr_ttldivid - vr_vljurfai;
                  ELSE
                    vr_vldivnor := vr_ttldivid - vr_tab_agreg(vr_indice_agreg).vljura60 - vr_vljurfai;
                  END IF;
                  vr_flgfirst := 0;
                ELSE
                  -- Com base nos juros e no valor da divida, eh calculado o valor total da divida
                  IF vr_tab_agreg(vr_indice_agreg).cdmodali = 101 THEN
                    vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                                     ,vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida
                                                     ,0
                                                     ,true);
                  ELSE
                    vr_vldivnor := fn_normaliza_juros(vr_ttldivid
                                                     ,vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida
                                                     ,vr_tab_agreg(vr_indice_agreg).vljura60
                                                     ,true);
                  END IF;
                END IF;
              ELSE
                vr_vldivnor := vr_tab_venc_agreg(vr_indice_venc_agreg).vldivida;
              END IF;
              -- Se a modalidade ainda não foi inicializada
              IF NOT vr_tab_totmodali.exists(vr_cdmodali) THEN
                vr_tab_totmodali(vr_cdmodali) := 0;
              END IF;

              --IF vr_vldivnor <> 0 THEN
              IF vr_vldivnor > 0 or vr_vldivnor < -100 or nvl(vr_tab_totmodali.count,0) = 1 THEN /*SD#855059*/
                IF vr_vldivnor <= 0 and vr_vldivnor > -100 THEN /*SD#855059*/
                  vr_vldivnor := 1/100; --atribui 0,01 /*SD#855059*/
                END IF; /*SD#855059*/
                -- Acumular
                vr_tab_totmodali(vr_cdmodali) := vr_tab_totmodali(vr_cdmodali) + nvl(vr_vldivnor,0);                      
                  
                IF vr_tpexecucao = 2 Then
                   vr_seq_relato := vr_seq_relato + 1;
                  
                  -- Populado variável de trabalho para utilização na WRK
                  vr_texto := ' v' || vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto 
                                   ||'="' || replace(to_char(vr_vldivnor, 'fm999999990D00'),',','.') 
                                   || '"';
            
                  -- Procedimento para gravar wrk, para posteriormente descarregar xml
                  pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                                 pr_cdagenci      => pr_cdagenci,
                                                 pr_nrdconta      => vr_nrdaconta,
                                                 pr_nrcpfcgc      => vr_nrcgccpf,
                                                 pr_nmrelatorio   => 'VENC_AGREG',
                                                 pr_dtmvtolt      => pr_dtrefere,
                                                 pr_dschave       => vr_chave,
                                                 pr_dscritic      => vr_texto,
                                                 pr_Valor         => vr_vldivnor,
                                                 pr_seq_relato    => vr_seq_relato, -- nrctremp
                                                 pr_dsxml         => vr_indice_agreg,
                                                 pr_des_erro      => vr_dscritic);
                  if vr_dscritic is not null then
                     vr_dscritic:= '3040_ENVVCTO - '||vr_dscritic;
                     raise vr_exc_saida;
                  end if;
                else
                  -- Enviar o vencimento
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                             ,pr_texto_completo => vr_xml_3040_temp
                                         ,pr_texto_novo     => ' v' || vr_tab_venc_agreg(vr_indice_venc_agreg).cdvencto 
                                                                || '="' || replace(to_char(vr_vldivnor, 'fm999999990D00'),',','.') || '"');
                end if;
              END IF;
            END IF;
            vr_indice_venc_agreg := vr_tab_venc_agreg.next(vr_indice_venc_agreg);
          END LOOP;

          If vr_tpexecucao = 2 Then
            vr_seq_relato := vr_seq_relato + 1;
            -- Procedimento para gravar wrk, para posteriormente descarregar xml
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_cdagenci      => pr_cdagenci,
                                           pr_nrdconta      => vr_nrdaconta,
                                           pr_nrcpfcgc      => vr_nrcgccpf,
                                           pr_nmrelatorio   => 'FIM_TAG_AGREG',
                                           pr_dtmvtolt      => pr_dtrefere,
                                           pr_dschave       => vr_chave,
                                           pr_dscritic      => '/>' || chr(10) || '    </Agreg>',
                                           pr_Valor         =>  null,
                                           pr_seq_relato    => vr_seq_relato, -- nrctremp
                                           pr_dsxml         => vr_indice_agreg,
                                           pr_des_erro      => vr_dscritic);
            if vr_dscritic is not null then
              vr_dscritic:= '3040_FIMTAGVCTO - '||vr_dscritic;
              raise vr_exc_saida;
            end if;
          else
            -- Finaliza a TAG <Venc> 
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => '/>' || chr(10) || '    </Agreg>' || chr(10));
          end if;
          vr_indice_agreg := vr_tab_agreg.next(vr_indice_agreg);
        END LOOP;
            
        -- Sem Paralelismo
        If vr_tpexecucao = 1 Then  
          -- Condicao para verificar se jah foi enviado a ultima parte do arquivo 3040
          IF NOT vr_flgfimaq THEN
            -- Solicita para gerar o arquivo 3040 particionado
            pc_solicita_relato_3040(pr_nrdocnpj      => vr_tab_crapcop(pr_cdcooper).nrdocnpj
                                   ,pr_dsnomscr      => vr_tab_crapcop(pr_cdcooper).dsnomscr
                                   ,pr_dsemascr      => vr_tab_crapcop(pr_cdcooper).dsemascr
                                   ,pr_dstelscr      => vr_tab_crapcop(pr_cdcooper).dstelscr
                                   ,pr_cdprogra      => vr_cdprogra
                                   ,pr_dtmvtolt      => pr_dtmvtolt
                                   ,pr_dtrefere      => pr_dtrefere
                                   ,pr_flbbndes      => pr_flbbndes
                                   ,pr_flgfimaq      => TRUE
                                   ,pr_totalcli      => vr_totalcli
                                   ,pr_nom_direto    => vr_nom_dirsal
                                   ,pr_nom_dirmic    => vr_nom_dirmic
                                   ,pr_numparte      => vr_numparte
                                   ,pr_xml_3040      => vr_xml_3040
                                   ,pr_xml_3040_temp => vr_xml_3040_temp
                                   ,pr_cdcritic      => vr_cdcritic
                                   ,pr_dscritic      => vr_dscritic);
                                      
            -- Condicao para verificar se houve erro
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
            END IF;      
          
          END IF; -- END IF NOT vr_flgfimaq THEN 
        else
          --Tratamento para gerar CRRL667
          vr_idx_totmodali := vr_tab_totmodali.first;
          LOOP
            EXIT WHEN vr_idx_totmodali IS NULL;
            
            If vr_tpexecucao = 2 Then
             -- Enviamos o nó correspondente a modalidade
              pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                             pr_cdagenci      => pr_cdagenci,
                                             pr_nrdconta      => vr_nrdaconta,
                                             pr_nrcpfcgc      => vr_nrcgccpf,
                                             pr_nmrelatorio   => 'CRRL567',
                                             pr_dtmvtolt      => pr_dtrefere,
                                             pr_dschave       =>  to_char(vr_tab_totmodali(vr_idx_totmodali),'fm999G999G999G999G990D00'),
                                             pr_dscritic      =>  '>',
                                             pr_Valor         =>  vr_tab_totmodali(vr_idx_totmodali),
                                             pr_seq_relato    =>  to_char(vr_idx_totmodali,'fm0000'),
                                             pr_dsxml         => null,
                                             pr_des_erro      => vr_dscritic);
            
              if vr_dscritic is not null then
                vr_dscritic:= 'Erro gravação WRK_567 - '||vr_dscritic;
                raise vr_exc_saida;
              end if;
            end if;
          -- Buscar o próximo
          vr_idx_totmodali := vr_tab_totmodali.next(vr_idx_totmodali);
          END LOOP;
        end if;
      end if;  -- fim paralelismo

      -- Rotina principal do paralelismo
      IF pr_flbbndes = 'N' AND pr_inproces > 2 AND vr_qtdjobs > 0 and pr_cdagenci = 0 then

        -- Gerar log
        pc_controla_log_batch(1, '2.1 - Trata TAGS duplicadas PA: '||pr_cdagenci);
         
        -- Trata TAGS duplicadas de clientes
        Declare
          Cursor Cr_arq3040_duplo Is 
            select w.tpparcel
                   ,count(*) vl_qtcpfcgc  
              from tbgen_batch_relatorio_wrk w
             where w.cdcooper = PR_CDCOOPER
               and w.cdprograma = vr_cdprogra
               and w.dtmvtolt   = pr_dtrefere
               and w.cdagenci > 0
               AND w.dsrelatorio IN ('3040_PFJ', '3040_CLIFI', '3040_CLIJU')
               and substr(w.dscritic,1,8) = '    <Cli' 
             group by w.tpparcel
            having count(*) > 1;
          rw_arq3040_duplo   cr_arq3040_duplo%ROWTYPE;
        
          -- Obtem TAG Abre
          Cursor Cr_arq3040_abre_tag (pr_tpparcel in number) Is 
            select a.CDCOOPER, A.TPPARCEL, A.CDAGENCI, A.NRCTREMP, a.rowid
              from tbgen_batch_relatorio_wrk a
             where a.cdcooper = PR_CDCOOPER
               and a.cdprograma = vr_cdprogra
               and a.dtmvtolt   = pr_dtrefere
               and a.cdagenci > 0
               AND a.dsrelatorio IN ('3040_PFJ', '3040_CLIFI', '3040_CLIJU')
               and substr(a.dscritic,1,8) = '    <Cli' 
               and a.tpparcel = pr_tpparcel
             order by A.CDCOOPER, A.TPPARCEL, A.CDAGENCI, A.NRCTREMP;
          rw_arq3040_abre_tag Cr_arq3040_abre_tag%ROWTYPE;

          -- Obtem TAG Fecha
          Cursor Cr_arq3040_fecha_tag (pr_tpparcel in NUMBER) Is 
            select a.CDCOOPER, A.TPPARCEL, A.CDAGENCI, A.NRCTREMP, a.rowid
              from tbgen_batch_relatorio_wrk a
             where a.cdcooper = PR_CDCOOPER
               and a.cdprograma = vr_cdprogra
               and a.dtmvtolt   = pr_dtrefere
               and a.cdagenci > 0
               and a.dsrelatorio in ('3040_FECCONT', '3040_FECTAG /Cli')
               and a.dscritic = '    </Cli>'
               and a.tpparcel = pr_tpparcel
             order by A.CDCOOPER, A.TPPARCEL, A.CDAGENCI desc, A.NRCTREMP desc;
          rw_arq3040_fecha_tag Cr_arq3040_fecha_tag%ROWTYPE;

        Begin
          FOR rw_arq3040_duplo IN Cr_arq3040_duplo LOOP
            OPEN Cr_arq3040_abre_tag (pr_tpparcel => rw_arq3040_duplo.tpparcel);
            FETCH Cr_arq3040_abre_tag INTO rw_arq3040_abre_tag;
            IF cr_arq3040_abre_tag%FOUND THEN
              CLOSE cr_arq3040_abre_tag;
          
              -- Acumula totais de duplos 
            vr_totalcli_dup := vr_totalcli_dup + (rw_arq3040_duplo.vl_qtcpfcgc - 1);

              -- Excluir TAG Abre
              begin
                delete tbgen_batch_relatorio_wrk a
                 where a.cdcooper = PR_CDCOOPER
                   and a.cdprograma = vr_cdprogra
                   and a.dtmvtolt   = pr_dtrefere
                   and a.cdagenci > 0
                   and a.dsrelatorio in ('3040_PFJ','3040_CLIFI')          
                   and substr(a.dscritic,1,8) = '    <Cli'
                   and a.tpparcel = rw_arq3040_duplo.tpparcel
                   and a.rowid <> rw_arq3040_abre_tag.rowid;
              exception
                when others then
                   pc_controla_log_batch(2, 'Erro Wrk 1 - PA: '||pr_cdagenci ||' '|| sqlerrm);
              end;
            ELSE
              CLOSE cr_arq3040_abre_tag;
            END IF;

            OPEN Cr_arq3040_fecha_tag (rw_arq3040_duplo.tpparcel);
            FETCH Cr_arq3040_fecha_tag INTO rw_arq3040_fecha_tag;
            IF cr_arq3040_fecha_tag%FOUND THEN
              CLOSE cr_arq3040_fecha_tag;

              -- Exclui TAG Fecha
              Begin
                delete tbgen_batch_relatorio_wrk a
                 where a.cdcooper = PR_CDCOOPER
                   and a.cdprograma = vr_cdprogra
                   and a.dtmvtolt   = pr_dtrefere
                   and a.cdagenci > 0
                   and a.dsrelatorio in ('3040_FECCONT', '3040_FECTAG /Cli')
                   and a.dscritic = '    </Cli>' 
                   and a.tpparcel = rw_arq3040_duplo.tpparcel
                   and a.rowid <> rw_arq3040_fecha_tag.rowid;
              exception
                when others then
                   pc_controla_log_batch(2, 'Erro Wrk 2 - PA: '||pr_cdagenci ||' '|| sqlerrm);
              end;
            ELSE
              CLOSE cr_arq3040_fecha_tag;
            END IF;  

          End loop;
        End;
           
        -- Trata Totais para paralelismo
        declare
          -- Gera operacoes para relatorio 567
          Cursor Cr_Rel567 Is 
            Select Sum(A.Vltitulo) Vltitulo, a.nrctremp nrctremp
              From Tbgen_Batch_Relatorio_Wrk A
             Where A.CDCOOPER    = PR_CDCOOPER
               And A.CDPROGRAMA  = vr_cdprogra
               and a.dtmvtolt    = pr_dtrefere
               And A.DSRELATORIO = 'CRRL567'
               And A.cdagenci > 0
             Group By A.nrctremp
             Order By A.nrctremp;

          -- Gera XML a partir do arquivo
          CURSOR cr_Arq3040 IS
            SELECT * FROM TBGEN_BATCH_RELATORIO_WRK A 
             WHERE A.CDPROGRAMA = VR_CDPROGRA
               AND A.CDCOOPER   = PR_CDCOOPER
               AND A.DTMVTOLT   = pr_dtrefere
               AND A.cdagenci > 0
               AND A.dsrelatorio not in ('CRRL567_QTRIS', '3040_TOTCLI', 'CRRL567'   -- Relatórios
                                        ,'TAG_AGREG', 'FIM_TAG_AGREG','VENC_AGREG')  -- Agregacao
          Order By A.CDCOOPER, A.TPPARCEL, A.CDAGENCI, A.NRCTREMP;

          Vr_contacliWrk Number :=0;
          Vr_ClienteWrk  Number :=0;
          vr_tag_cli_ini varchar2(30);
          vr_tag_cli_fim varchar2(30);                                       
        Begin
          --Inicializar variaveis erro
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;

          -- Obtem total de clientes
          Begin
            Select Sum(A.NRCTREMP)
              Into vr_totalcli
              From Tbgen_Batch_Relatorio_Wrk A
             Where A.CDPROGRAMA  = vr_cdprogra
               and a.cdcooper    = pr_cdcooper
               and a.dtmvtolt    = pr_dtrefere
               and a.dsrelatorio = '3040_TOTCLI'
               And a.cdagenci    > 0
               and a.nrdconta    = 99999
               and a.tpparcel    = 8888888888;
          exception
            when others then
               vr_totalcli := 0;
          End;    
          vr_totalcli := vr_totalcli - vr_totalcli_dup;

          -- Obtem total registros do arquivo para rel 567
          Begin
            Select Sum(A.NRCTREMP)
              Into vr_qtregarq
              From Tbgen_Batch_Relatorio_Wrk A
             Where A.CDPROGRAMA  = vr_cdprogra
               and a.cdcooper    = pr_cdcooper
               and a.dsrelatorio = 'CRRL567_QTRIS'
               and a.dtmvtolt    = pr_dtrefere
               And a.cdagenci    > 0
               and a.nrdconta    = 99999
               and a.tpparcel    = 8888888888;
          exception
            when others then
              vr_qtregarq := 0;
          End;    
          --vr_qtregarq := vr_qtregarq - vr_totalcli_dup;

          FOR rw_Rel567 IN cr_Rel567 LOOP

            -- Se a modalidade ainda não foi inicializada
            IF NOT vr_tab_totmodali.exists(Rw_Rel567.Nrctremp) THEN
              vr_tab_totmodali(Rw_Rel567.Nrctremp) := 0;
            END IF;

            -- Acumular
            vr_tab_totmodali(Rw_Rel567.Nrctremp) := vr_tab_totmodali(Rw_Rel567.Nrctremp) + nvl(Rw_Rel567.Vltitulo,0);
          End Loop;

          -- Gerar log
          pc_controla_log_batch(1, '3 - Carga 3040 wrk PA: '||pr_cdagenci);

          -- Efetua loop sobre os dados da Wrk para gerar o XML
          FOR Rw_Arq3040 IN cr_Arq3040 LOOP
        
            --Valida de cliente da WRK é diferente do salvo para acumular qtdade de clientes e posteriormente
            --particionar arquivo
            vr_tag_cli_ini := null;
            vr_tag_cli_fim := null;
         
            If Vr_ClienteWrk <> Rw_Arq3040.Tpparcel Then
              Vr_contacliWrk := Vr_contacliWrk + 1;
            End If;
          
            -- Validação para verificarmos se já atingimos a qtdade pré-estabelicada de clientes para particionar arquivo.
            IF Vr_contacliWrk >= vr_qtregarq_3040 THEN
            
              -- Solicita para gerar o arquivo 3040 particionado
              pc_solicita_relato_3040(pr_nrdocnpj      => vr_tab_crapcop(pr_cdcooper).nrdocnpj
                                     ,pr_dsnomscr      => vr_tab_crapcop(pr_cdcooper).dsnomscr
                                     ,pr_dsemascr      => vr_tab_crapcop(pr_cdcooper).dsemascr
                                     ,pr_dstelscr      => vr_tab_crapcop(pr_cdcooper).dstelscr
                                     ,pr_cdprogra      => vr_cdprogra
                                     ,pr_dtmvtolt      => pr_dtmvtolt
                                     ,pr_dtrefere      => pr_dtrefere
                                     ,pr_flbbndes      => pr_flbbndes
                                     ,pr_flgfimaq      => vr_flgfimaq
                                     ,pr_totalcli      => vr_totalcli
                                     ,pr_nom_direto    => vr_nom_dirsal
                                     ,pr_nom_dirmic    => vr_nom_dirmic
                                     ,pr_numparte      => vr_numparte
                                     ,pr_xml_3040      => vr_xml_3040
                                     ,pr_xml_3040_temp => vr_xml_3040_temp
                                     ,pr_cdcritic      => vr_cdcritic
                                     ,pr_dscritic      => vr_dscritic);

              Vr_contacliWrk := 0;
              
              -- Condicao para verificar se houve erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
                 
              -- Zera variáveis
              Vr_contacliWrk := 0;
            END IF;

            gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                   ,pr_texto_completo => vr_xml_3040_temp
                                   ,pr_texto_novo     => Rw_Arq3040.dscritic || chr(10));

            Vr_ClienteWrk := Rw_Arq3040.Tpparcel;

          END LOOP; -- Fim do loop sobre a tabela Wrk           

          -- Gerar parte de agregamento no arquivo ------------------
          -- Modo com Paralelismo
          declare
            -- Obtem Agregamentos 
            Cursor Cr_arq3040_Agreg Is 
              select substr(dschave,1,50) chave
                    ,w.dscritic
                    ,0  tpparcel
                    ,sum(w.vltitulo) ProvConsttd 
                    ,sum(to_number(substr(dschave,instr(dschave,'QtdOp=')+6,7))) QtdClOp
                    ,sum(to_number(substr(dschave,instr(dschave,'QtdCli=')+7,7))) QtdCli
                from tbgen_batch_relatorio_wrk w
               where w.cdcooper = pr_cdcooper
                 and w.cdprograma = vr_cdprogra
                 and w.dsrelatorio = 'TAG_AGREG'
                 and w.dtmvtolt = pr_dtrefere
                 and w.cdagenci > 0
               group by substr(dschave,1,50),w.dscritic--,w.tpparcel
               order by substr(dschave,1,50);
          
            -- Obtem Vencimentos dos Agregamentos
            Cursor Cr_arq3040_Venc (pr_chave in varchar2) Is 
              select substr(dschave,1,50) chave
                    ,(substr(w.dscritic,instr(w.dscritic,'v')+1,instr(w.dscritic,'=') -instr(w.dscritic,'v')-1 )) op
                    ,sum(w.vltitulo) vl
                from tbgen_batch_relatorio_wrk w
               where w.cdcooper = pr_cdcooper
                 and w.cdprograma = vr_cdprogra
                 and w.dtmvtolt = pr_dtrefere
                 and w.dsrelatorio = 'VENC_AGREG'
                 and substr(dschave,1,50) like pr_chave
               group by substr(dschave,1,50)
                       ,(substr(w.dscritic,instr(w.dscritic,'v')+1,instr(w.dscritic,'=') -instr(w.dscritic,'v')-1 ))
               order by substr(dschave,1,50),2;
          
            -- Linha do arquivo
            dslinha    varchar2(4000) := null;

          begin

            FOR rw_arq3040_Agreg IN Cr_arq3040_Agreg LOOP 
              --Incremento de cliente
              If Vr_ClienteWrk <> rw_arq3040_Agreg.Tpparcel Then
                Vr_contacliWrk := Vr_contacliWrk + 1;
              End If;

              --Montar linha Agregamento
              dslinha := rw_arq3040_Agreg.dscritic
                      ||  ' ProvConsttd="' ||replace(to_char(rw_arq3040_Agreg.ProvConsttd,'fm999999990D00'),',','.')
                      || '" QtdOp="'  ||rw_arq3040_Agreg.QtdClOp
                      || '" QtdCli="' ||rw_arq3040_Agreg.QtdCli || '">';          
              --Gerar XML
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => dslinha || chr(10));
              dslinha := null;
          
              FOR rw_arq3040_Venc  IN Cr_arq3040_Venc (rw_arq3040_Agreg.chave) LOOP
                --Montar linha Vencimento
                dslinha := dslinha || ' v'||rw_arq3040_Venc.op||'="'|| replace(to_char(rw_arq3040_Venc.vl, 'fm999999990D00'),',','.')||'"';
              END LOOP;

              if dslinha is not null then
                --Gerar Abertura do Vencimento
                dslinha := '        <Venc' || dslinha ||'/>';
                --Gerar XML
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                       ,pr_texto_completo => vr_xml_3040_temp
                                       ,pr_texto_novo     => dslinha || chr(10));
              end if;
          
              --Linha fechamento do agragamento
              dslinha := '    </Agreg>';
              --Gerar XML
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_3040
                                     ,pr_texto_completo => vr_xml_3040_temp
                                     ,pr_texto_novo     => dslinha || chr(10));
            
              Vr_ClienteWrk := rw_arq3040_Agreg.Tpparcel;
            END LOOP;
          end; 
          -- Fim gerar agregamento ------------
           
          -- Solicita para gerar o arquivo 3040 não particionado ou último
          pc_solicita_relato_3040(pr_nrdocnpj      => vr_tab_crapcop(pr_cdcooper).nrdocnpj
                                 ,pr_dsnomscr      => vr_tab_crapcop(pr_cdcooper).dsnomscr
                                 ,pr_dsemascr      => vr_tab_crapcop(pr_cdcooper).dsemascr
                                 ,pr_dstelscr      => vr_tab_crapcop(pr_cdcooper).dstelscr
                                 ,pr_cdprogra      => vr_cdprogra
                                 ,pr_dtmvtolt      => pr_dtmvtolt
                                 ,pr_dtrefere      => pr_dtrefere
                                 ,pr_flbbndes      => pr_flbbndes
                                 ,pr_flgfimaq      => TRUE --vr_flgfimaq
                                 ,pr_totalcli      => vr_totalcli
                                 ,pr_nom_direto    => vr_nom_dirsal
                                 ,pr_nom_dirmic    => vr_nom_dirmic
                                 ,pr_numparte      => vr_numparte
                                 ,pr_xml_3040      => vr_xml_3040
                                 ,pr_xml_3040_temp => vr_xml_3040_temp
                                 ,pr_cdcritic      => vr_cdcritic
                                 ,pr_dscritic      => vr_dscritic);
        END;
      End If; -- Fim Paralelismo

      if pr_idparale = 0 THEN
                    
        -- Somente quanto não for execução do BNDES
        IF pr_flbbndes = 'N' THEN
          -- Gerar log
          pc_controla_log_batch(1, '4 - Relatorios PA: '||pr_cdagenci );
          
          -- Impressao Relatorios -566 - RISCO 9(Tambem acumula p/rel 566)---- 
          -- Instanciar o CLOB
          dbms_lob.createtemporary(vr_xml_566, TRUE);
          dbms_lob.open(vr_xml_566, dbms_lob.lob_readwrite);
          -- Incializar o XML
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                 ,pr_texto_completo => vr_xml_566_temp
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="WINDOWS-1252"?>'
                                                    || '<crrl566>'||'<tipo9>');
          -- efetua um loop sobre as informacoes da central de risco
          for rw_crapris in cr_crapris_relato(pr_cdcooper,pr_dtrefere) loop
            if rw_crapris.nrseq = 1 then
              vr_rsvec180 := 0;
              vr_rsvec360 := 0;  -- Totais Risco 9 
              vr_rsvec999 := 0;
              vr_rsdiv060 := 0;
              vr_rsdiv180 := 0;
              vr_rsdiv360 := 0;
              vr_rsdiv999 := 0;
              vr_rsprjano := 0;
              vr_rsprjaan := 0;
              vr_rsdivida := 0;
              vr_rsprjant := 0;
              vr_nrcpfcgc := '';
              -- Se for pessoa juridica utiliza somente a base do CNPJ
              IF rw_crapris.inpessoa = 2 THEN
                 vr_nrcpfcgc := SUBSTR(lpad(rw_crapris.nrcpfcgc,14,'0'),1,8);
              end if;
            end if;
            -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
            IF rw_crapris.cdcooper IN (1,16,9) THEN
              -- Se for uma conta migrada nao deve processar
              IF fn_eh_conta_migracao_573(pr_cdcooper => rw_crapris.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta
                                         ,pr_dtrefere => rw_crapris.dtrefere) THEN
                continue; -- Volta para o inicio do for
              END IF;
            END IF;
            -- Efetua o loop sobre o os vencimentos do risco
            vr_indice_crapvri_b := lpad(rw_crapris.cdcooper,03,'0') ||
                                   lpad(rw_crapris.nrdconta,10,'0') ||
                                   lpad(rw_crapris.innivris,05,'0') ||
                                   lpad(rw_crapris.cdmodali,05,'0') ||
                                   lpad(rw_crapris.nrseqctr,05,'0') ||
                                   lpad(rw_crapris.nrctremp,10,'0') ||
                                   '0000000';
            vr_indice_crapvri := vr_indice_crapvri_b;
            vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
            WHILE vr_indice_crapvri_b IS NOT NULL LOOP
              -- Se nao for a mesma chave sai do loop
              IF substr(vr_indice_crapvri_b,1,35) <> substr(vr_indice_crapvri,1,35) THEN
                EXIT;
              END IF;
              -- Acumulando valores para o Resumo Rel.567 
              IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
                vr_vlprjano := vr_vlprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
                vr_vlprjaan := vr_vlprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 330 THEN
                vr_vlprjant := vr_vlprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSE
                if vr_tab_divida.exists(rw_crapris.innivris) then
                  vr_tab_divida(rw_crapris.innivris).divida :=
                        vr_tab_divida(rw_crapris.innivris).divida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                else
                  vr_tab_divida(rw_crapris.innivris).divida := vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                end if;
              end if;
              -- -- Risco 9 -- --
              IF rw_crapris.innivris = 9 THEN
                vr_rsdivida := vr_rsdivida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 110    AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 140 THEN
                  vr_rsvec180 := vr_rsvec180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto  = 150 THEN
                  vr_rsvec360 := vr_rsvec360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >  150 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 199 THEN
                  vr_rsvec999 := vr_rsvec999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 205 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 220 THEN
                  vr_rsdiv060 := vr_rsdiv060 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 230 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 250 THEN
                  vr_rsdiv180 := vr_rsdiv180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 255 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 270 THEN
                  vr_rsdiv360 := vr_rsdiv360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 280 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 290 THEN
                  vr_rsdiv999 := vr_rsdiv999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
                  vr_rsprjano := vr_rsprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
                  vr_rsprjaan := vr_rsprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                ELSE
                  vr_rsprjant := vr_rsprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
                END IF;
              end if;
              -- Vai para o proximo registro da pl/table
              vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
            end loop; -- CRAPVRI
            -- Se for o ultimo registro
            if rw_crapris.nrseq = rw_crapris.qtreg and vr_rsdivida > 0 THEN
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                     ,pr_texto_completo => vr_xml_566_temp
                                     ,pr_texto_novo     => '<conta>'
                                                        || '<nrdconta>'||gene0002.fn_mask_conta(rw_crapris.nrdconta)||'</nrdconta>'
                                                        || '<innivris>'||to_char(rw_crapris.innivris,'00')          ||'</innivris>'
                                                        || '<nrcpfcgc_raiz>'||vr_nrcpfcgc                           ||'</nrcpfcgc_raiz>'
                                                        || '<nrcpfcgc>'||rw_crapris.nrcpfcgc                        ||'</nrcpfcgc>'
                                                        || '<rsdivida>'||to_char(vr_rsdivida,'999G999G990D00')      ||'</rsdivida>' 
                                                        || '<rsvec180>'||to_char(vr_rsvec180,'999G999G990D00')      ||'</rsvec180>' 
                                                        || '<rsvec360>'||to_char(vr_rsvec360,'999G999G990D00')      ||'</rsvec360>' 
                                                        || '<rsvec999>'||to_char(vr_rsvec999,'999G999G990D00')      ||'</rsvec999>' 
                                                        || '<rsdiv060>'||to_char(vr_rsdiv060,'999G999G990D00')      ||'</rsdiv060>' 
                                                        || '<rsdiv180>'||to_char(vr_rsdiv180,'999G999G990D00')      ||'</rsdiv180>' 
                                                        || '<rsdiv360>'||to_char(vr_rsdiv360,'999G999G990D00')      ||'</rsdiv360>' 
                                                        || '<rsdiv999>'||to_char(vr_rsdiv999,'999G999G990D00')      ||'</rsdiv999>' 
                                                        || '<rsprjano>'||to_char(vr_rsprjano,'999G999G990D00')      ||'</rsprjano>' 
                                                        || '<rsprjaan>'||to_char(vr_rsprjaan,'999G999G990D00')      ||'</rsprjaan>' 
                                                        || '<rsprjant>'||to_char(vr_rsprjant,'999G999G990D00')      ||'</rsprjant>' 
                                                        || '</conta>');
              vr_qtreg9 := vr_qtreg9 + 1;
            END IF;
          END loop; -- CRAPRIS
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                 ,pr_texto_completo => vr_xml_566_temp
                                 ,pr_texto_novo     => '</tipo9>'
                                                    || '<qtreg9>'||vr_qtreg9||'</qtreg9>'
                                                    || '<vr1000>');

          -- Impressao Relatorios -566 - Valores > 1000 - Doc3040 --
          for rw_crapris in cr_crapris_relato(pr_cdcooper,pr_dtrefere) loop
            if rw_crapris.nrseq = 1 then
              vr_rsvec180 := 0;
              vr_rsvec360 := 0;  -- Vlr.> 1000 
              vr_rsvec999 := 0;
              vr_rsdiv060 := 0;
              vr_rsdiv180 := 0;
              vr_rsdiv360 := 0;
              vr_rsdiv999 := 0;
              vr_rsprjano := 0;
              vr_rsprjaan := 0;
              vr_rsdivida := 0;
              vr_rsprjant := 0;
              vr_nrcpfcgc := '';
              -- Se for pessoa juridica, utiliza somente a base do CNPJ
              IF rw_crapris.inpessoa = 2 THEN
                vr_nrcpfcgc := SUBSTR(lpad(rw_crapris.nrcpfcgc,14,'0'),1,8);
              end if;
            end if;
            -- Se a coooperativa for AltoVale ou Viacredi ou tranpocred verifica se a conta eh de migracao
            IF rw_crapris.cdcooper IN (1,16,9) THEN
              -- Se for uma conta migrada nao deve processar
              IF fn_eh_conta_migracao_573(pr_cdcooper => rw_crapris.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta
                                         ,pr_dtrefere => rw_crapris.dtrefere) THEN
                continue; -- Volta para o inicio do for
              END IF;
            END IF;
            -- Efetua o loop sobre o os vencimentos do risco
            vr_indice_crapvri_b := lpad(rw_crapris.cdcooper,03,'0') ||
                                   lpad(rw_crapris.nrdconta,10,'0') ||
                                   lpad(rw_crapris.innivris,05,'0') ||
                                   lpad(rw_crapris.cdmodali,05,'0') ||
                                   lpad(rw_crapris.nrseqctr,05,'0') ||
                                   lpad(rw_crapris.nrctremp,10,'0') ||
                                   '0000000';
            vr_indice_crapvri := vr_indice_crapvri_b;
            vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
            WHILE vr_indice_crapvri_b IS NOT NULL LOOP
              -- Se nao for a mesma chave sai do loop
              IF substr(vr_indice_crapvri_b,1,35) <> substr(vr_indice_crapvri,1,35) THEN
                EXIT;
              END IF;
              vr_rsdivida := vr_rsdivida + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              IF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 110    AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 140 THEN
                vr_rsvec180 := vr_rsvec180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto  = 150 THEN
                vr_rsvec360 := vr_rsvec360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >  150 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 199 THEN
                vr_rsvec999 := vr_rsvec999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 205 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 220 THEN
                vr_rsdiv060 := vr_rsdiv060 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 230 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 250 THEN
                vr_rsdiv180 := vr_rsdiv180 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 255 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 270 THEN
                vr_rsdiv360 := vr_rsdiv360 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto >= 280 AND vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto <= 290 THEN
                vr_rsdiv999 := vr_rsdiv999 + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 310 THEN
                vr_rsprjano := vr_rsprjano + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSIF vr_tab_crapvri_b(vr_indice_crapvri_b).cdvencto = 320 THEN
                vr_rsprjaan := vr_rsprjaan + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              ELSE
                vr_rsprjant := vr_rsprjant + vr_tab_crapvri_b(vr_indice_crapvri_b).vldivida;
              END IF;
              -- Vai para o proximo registro da pl/table
              vr_indice_crapvri_b := vr_tab_crapvri_b.next(vr_indice_crapvri_b);
            end loop;
            if rw_crapris.nrseq = rw_crapris.qtreg and rw_crapris.flgindiv > 0 THEN
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                     ,pr_texto_completo => vr_xml_566_temp
                                     ,pr_texto_novo     => '<conta>'
                                                        || '<nrdconta>'||gene0002.fn_mask_conta(rw_crapris.nrdconta)||'</nrdconta>'
                                                        || '<innivris>'||to_char(rw_crapris.innivris,'00')          ||'</innivris>'
                                                        || '<nrcpfcgc_raiz>'||vr_nrcpfcgc                           ||'</nrcpfcgc_raiz>'
                                                        || '<nrcpfcgc>'||rw_crapris.nrcpfcgc                        ||'</nrcpfcgc>'
                                                        || '<rsdivida>'||to_char(vr_rsdivida,'999G999G990D00')      ||'</rsdivida>' 
                                                        || '<rsvec180>'||to_char(vr_rsvec180,'999G999G990D00')      ||'</rsvec180>' 
                                                        || '<rsvec360>'||to_char(vr_rsvec360,'999G999G990D00')      ||'</rsvec360>' 
                                                        || '<rsvec999>'||to_char(vr_rsvec999,'999G999G990D00')      ||'</rsvec999>' 
                                                        || '<rsdiv060>'||to_char(vr_rsdiv060,'999G999G990D00')      ||'</rsdiv060>' 
                                                        || '<rsdiv180>'||to_char(vr_rsdiv180,'999G999G990D00')      ||'</rsdiv180>' 
                                                        || '<rsdiv360>'||to_char(vr_rsdiv360,'999G999G990D00')      ||'</rsdiv360>' 
                                                        || '<rsdiv999>'||to_char(vr_rsdiv999,'999G999G990D00')      ||'</rsdiv999>' 
                                                        || '<rsprjano>'||to_char(vr_rsprjano,'999G999G990D00')      ||'</rsprjano>' 
                                                        || '<rsprjaan>'||to_char(vr_rsprjaan,'999G999G990D00')      ||'</rsprjaan>' 
                                                        || '<rsprjant>'||to_char(vr_rsprjant,'999G999G990D00')      ||'</rsprjant>' 
                                                        ||'</conta>');
            END IF;
          END loop; -- CRAPRIS
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_566
                                 ,pr_texto_completo => vr_xml_566_temp
                                 ,pr_texto_novo     => '</vr1000></crrl566>'
                                 ,pr_fecha_xml      => true);
        
          -- Chamada do iReport para gerar o arquivo de saida
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                      pr_dtmvtolt  => pr_dtmvtolt,                    --> Data do movimento atual
                                      pr_dsxml     => vr_xml_566,                     --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crrl566',                     --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl566.jasper',               --> Arquivo de layout do iReport
                                      pr_dsparams  => null,                           --> Nao enviar parametro
                                      pr_dsarqsaid => vr_nom_direto||'/crrl566.lst',  --> Arquivo final
                                      pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                      pr_qtcoluna  => 234,                            --> Quantidade de colunas
                                      pr_nmformul  => '234dh',                        --> Nome do formulario
                                      pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                      pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                      pr_nrcopias  => 1,                              --> Numero de copias
                                      pr_des_erro  => vr_dscritic);                   --> Saida com erro
          -- Libera a memoria do clob vr_xml_566
          dbms_lob.close(vr_xml_566);
          dbms_lob.freetemporary(vr_xml_566);
          if vr_dscritic is not null then
            raise vr_exc_saida;
          end if;
        
          -- Impressao do relatorio resumido (567)
          -- Inicializando Clob
          dbms_lob.createtemporary(vr_xml_567, TRUE);
          dbms_lob.open(vr_xml_567, dbms_lob.lob_readwrite);
        
          -- Incializando xml
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="WINDOWS-1252"?>'
                                                    || '<crrl567>'
                                                    || '<dtrefere>' || to_char(pr_dtrefere,'YYYY/MM')          || '</dtrefere>' 
                                                    || '<arquivos>' || vr_nmarqsai_tot       
                                                    || '</arquivos>'
                                                    || '<qtregarq>' || to_char(vr_qtregarq,'999G999G990') || '</qtregarq>');
        
          -- Inicializar a tabela de Riscos
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '<riscos>');      
        
          -- Montar tabela de níveis de risco e valor
          for idx IN 1..9 LOOP
            if vr_tab_divida.exists(idx) then
              vr_totgeral := vr_totgeral + vr_tab_divida(idx).divida;
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                     ,pr_texto_completo => vr_xml_567_temp
                                     ,pr_texto_novo     => '<risco>'
                                                        || '<innivris>' || idx || '</innivris>'
                                                        || '<vldivida>'|| to_char(vr_tab_divida(idx).divida,'999G999G999G999G990D00') || '</vldivida>'
                                                        || '</risco>');
            end if;
          end loop;
        
          -- Fechar tabela de riscos
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '</riscos>');   
        
          -- Enviarmos os totais
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '<vlprjano>'|| to_char(vr_vlprjano,'9G999G999G990D00') || '</vlprjano>' 
                                                    || '<vlprjaan>'|| to_char(vr_vlprjaan,'9G999G999G990D00') || '</vlprjaan>' 
                                                    || '<vlprjant>'|| to_char(vr_vlprjant,'9G999G999G990D00') || '</vlprjant>' 
                                                    || '<totgeral>'|| to_char(vr_totgeral + vr_vlprjano + vr_vlprjaan + vr_vlprjant,'9G999G999G990D00') || '</totgeral>');      
          -- Inicializar a tabela de modalidades
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '<tabmodali>');      
          -- Iterar sobrar a tabela de totais por modalidade
          vr_idx_totmodali := vr_tab_totmodali.first;

          LOOP
            EXIT WHEN vr_idx_totmodali IS NULL;
            -- Enviamos o nó correspondente a modalidade
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                   ,pr_texto_completo => vr_xml_567_temp
                                   ,pr_texto_novo     => '<modali>' 
                                                      || '  <cdmodali>' || to_char(vr_idx_totmodali,'fm0000') || '</cdmodali>'
                                                      || '  <vlmodali>' || to_char(vr_tab_totmodali(vr_idx_totmodali),'fm999G999G999G999G990D00') || '</vlmodali>'
                                                      || '</modali>');
            -- Buscar o próximo
            vr_idx_totmodali := vr_tab_totmodali.next(vr_idx_totmodali);
          END LOOP;
          
          -- Encerrar a tabela de modalidades
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '</tabmodali>');      
          -- Encerrar o xml
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_567
                                 ,pr_texto_completo => vr_xml_567_temp
                                 ,pr_texto_novo     => '</crrl567>'
                                 ,pr_fecha_xml      => true);
        
          -- Chamada do iReport para gerar o arquivo de saida
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                      pr_dtmvtolt  => pr_dtmvtolt,                    --> Data do movimento atual
                                      pr_dsxml     => vr_xml_567,                     --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crrl567',                     --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl567.jasper',               --> Arquivo de layout do iReport
                                      pr_dsparams  => null,                           --> Nao enviar parametro
                                      pr_dsarqsaid => vr_nom_direto||'/crrl567.lst',  --> Arquivo final
                                      pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                      pr_qtcoluna  => 80,                             --> Quantidade de colunas
                                      pr_nmformul  => '80col',                        --> Nome do formulario
                                      pr_sqcabrel  => 3,                              --> Sequencia do cabecalho
                                      pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                      pr_nrcopias  => 1,                              --> Numero de copias
                                      pr_des_erro  => vr_dscritic);                   --> Saida com erro
          -- Libera a memoria do clob vr_xml_567
          dbms_lob.close(vr_xml_567);
          dbms_lob.freetemporary(vr_xml_567);
          if vr_dscritic is not null then
            raise vr_exc_saida;
          end if;
        END IF;

      End If;
              
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
            
      if pr_idparale = 0 then

        -- Gerar log
        pc_controla_log_batch(1, '5 - Fim PA: '||pr_cdagenci );

        if vr_idcontrole <> 0 then
          -- Atualiza finalização do batch na tabela de controle 
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => vr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => vr_dscritic);
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;                               
        end if; -- Fim IDControle    
                                                 
        -- Salvar informações atualizadas
        COMMIT;
      else
        -- Gerar log
        pc_controla_log_batch(1, '6 - Fim PA: '||pr_cdagenci );

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par);     
                    
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => vr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);  

        --Salvar informacoes no banco de dados
        COMMIT;
                                              
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);  

        --Salvar informacoes no banco de dados
        COMMIT;
      end if;                               
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Gerar log
        pc_controla_log_batch(1, '8 - Erro: '||pr_cdagenci ||' => '|| vr_dscritic);

        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
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
                                      ,pr_des_erro => vr_dscritic);
        ELSE
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
          END IF;
       end if; 

        -- Gerar log
        pc_controla_log_batch(1, '9 - Erro: '||pr_cdagenci ||' => '|| vr_dscritic);

       -- Efetuar rollback
       ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
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
                                      ,pr_des_erro => vr_dscritic);
       end if; 

       -- Efetuar rollback
       ROLLBACK;
    END;
  END pc_crps573_1;
/
