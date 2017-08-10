CREATE OR REPLACE PROCEDURE CECRED.pc_crps220(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: PC_CRPS220     (Antigo Fontes/crps220.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Outubro/95.                     Ultima atualizacao: 05/06/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Emitir os extratos das aplicacoes    RDCA no aniversario.
                   Atende a solicitacao 02.
                   Gera relatorio 174.
                   Exclusividade 2 (Paralelo).

       Alteracao : 05/12/95 - Alterado para desprezar extratos de dezembro com
                              saldos minusculos. (Odair Deborah Edson).

                   22/02/96 - Alterado a selecao do craprda e craplap devido ao
                              modulo de aplicacao programada (Odair).

                   26/11/96 - Tratar rdcaII (Odair).

                   02/12/97 - Tratar RDCA30 (Deborah).

                   12/02/98 - Alterado para preparar arquivo de extrato de aplica-
                              cao em formulario laser (Edson).

                   29/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   05/04/2000 - Emitir pedido de impressao direto para fila (Odair)

                   03/10/2000 - Altera forma saida do arquivo (Margarete/Planner)

                   19/12/2000 - Nao gerar automaticamente o pedido de impressao.
                                (Eduardo).

                   05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)

                   12/12/2003 - Incluir histor IRRF (Margarete).

                   09/01/2004 - Quando saldo negativo zerar (Margarete).

                   27/01/2004 - Incluir histor do abono e Ir do abono (Margarete).

                   28/06/2004 - Emitir so tipo extrato = 1 individual (Margarete).

                   22/09/2004 - Incluidos historicos 492/493/494/495(CI)(Mirtes)

                   16/12/2004 - Incluidos hist. 875/877/876(Ajuste IR)(Mirtes)

                   06/01/2005 - Incluida observacao sobre IRRF nos campos de
                                mensagem interna (Evandro).

                   25/04/2005 - Incluido, na 1a linha da mensagem interna, o nro do
                                cadastro do cooperado na empresa (Evandro).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   22/06/2007 - Faz verificacao somente das aplicacoes RDCA30 e
                                RDCA60 (Elton).

                   06/09/2007 - Alterado de FormXpress para FormPrint (Diego).

                   31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao(Guilherme).

                   30/04/2008 - Tratar campos referente "Data de Vencimento",
                                utilizado no Extrato Poup. Programada (crps221)
                                (Diego).

                   20/06/2008 - Incluído a chave de acesso (craphis.cdcooper =
                                glb_cdcooper) no "for each" da tabela CRAPHIS.
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   19/02/2009 - Envio de Informativo para PostMix (Diego).

                   29/09/2009 - Efetuada correcao para mostrar SALDO ATUAL quando
                                nao existirem lancamentos de aplicacao (Diego).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   08/03/2010 - Alteracao Historico (GATI)

                   19/07/2011 - Gravar PAC na cratext.
                                Unificacao das includes que geram os dados.
                                (Gabriel).
                              - Tratamento para envio das cartas para a Engecopy
                                (Elton).

                   03/10/2012 - Trocado campo dshistor para dsextrat, inclusive na
                                tt-hist. (Jorge)

                   10/06/2013 - Alteraçao funçao enviar_email_completo para
                                nova versao (Jean Michel).

                   04/04/2014 - Conversão Progress >> Oracle (Petter - Supero)
                                                             (Edison - AMcom)
                                                             
                   20/05/2014 - Correção - não estava populando a tabela de 
                                memória vr_tab_crapjur (Renato - Supero)

                   05/06/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                    crapass, crapttl, crapjur 
							    (Adriano - P339).

    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra      CONSTANT crapprg.cdprogra%TYPE := 'CRPS220';

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar dados dos históricos
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE) IS
        SELECT his.cdhistor
              ,his.dsextrat
              ,his.indebcre
        FROM craphis his
        WHERE his.cdcooper = pr_cdcooper;

      -- Buscar dados do cadastro de empresas
      CURSOR cr_crapemp(pr_cdcooper IN crapemp.cdcooper%TYPE) IS
        SELECT emp.cdempres
              ,emp.nmresemp
        FROM crapemp emp
        WHERE emp.cdcooper = pr_cdcooper;

      --seleciona dados do cadastro de aplicações RDA de todos os cooperados
      --da cooperativa conectada que completaram um mês, com quantidade de
      --meses para emissao de extrato de 3 meses, tipo de aplicacao 3-RDCA e 5-RDCAII
      --e tipo de impressao do extrato 1-individual.
      CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_dtmvtolt IN craprda.dtcalcul%TYPE) IS
        SELECT rda.dtsdrdan
              ,rda.vlsdrdan
              ,rda.tpemiext
              ,rda.nrdconta
              ,rda.dtiniext
              ,rda.dtfimext
              ,rda.nraplica
              ,rda.tpaplica
              ,rda.dtmvtolt
              ,rda.vlaplica
              ,rda.vlsdrdca
              ,rda.dtiniper
        FROM craprda rda
        WHERE rda.cdcooper = pr_cdcooper
          AND rda.dtcalcul = pr_dtmvtolt --Proximo dia a ser calculado.
          AND rda.dtmvtolt <> pr_dtmvtolt
          AND rda.inaniver = 1      --Indicador de aniversaorio (0-nao completou 1 mes, 1-completou).
          AND rda.qtmesext = 3      --Quantidade de meses para emissao do extrato.
          AND rda.tpaplica IN (3, 5)--Tipo de aplicacao 1 RDC pre, 2 RDC pos, 3 RDCA, 4 Poup.Prog, 5 RDCAII
          AND rda.tpemiext = 1      --Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
        ORDER BY rda.cdageass
                ,rda.cdsecext
                ,rda.nrdconta
                ,rda.nraplica;
      rw_craprda cr_craprda%ROWTYPE;

      -- Buscar dados dos associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdagenci
              ,crapass.cdsecext
              ,crapass.inpessoa
              ,crapass.nmprimtl
        FROM  crapass
        WHERE crapass.cdcooper = pr_cdcooper;

      --cadastro de destinos
      CURSOR cr_crapdes( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdagenci IN crapdes.cdagenci%TYPE
                        ,pr_cdsecext IN crapdes.cdsecext%TYPE) IS
        SELECT crapdes.nmsecext
        FROM   crapdes
        WHERE  crapdes.cdcooper = pr_cdcooper
        AND    crapdes.cdagenci = pr_cdagenci
        AND    crapdes.cdsecext = pr_cdsecext;

      rw_crapdes cr_crapdes%ROWTYPE;

      --dados das agencias
      CURSOR cr_crapage( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapage.cdagenci
              ,crapage.nmresage
        FROM   crapage
        WHERE  cdcooper = pr_cdcooper;

      -- cadastro de titulares da conta
      CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapttl.cdempres
              ,crapttl.nrdconta
        FROM   crapttl
        WHERE  crapttl.cdcooper = pr_cdcooper
        AND    crapttl.idseqttl = 1;
        
      -- Cadastro de pessoas juridicas
      CURSOR cr_crapjur(pr_cdcooper  crapjur.cdcooper%TYPE) IS
        SELECT cdempres
             , nrdconta
          FROM crapjur 
         WHERE crapjur.cdcooper = pr_cdcooper;

      --Cadastro dos lancamentos da aplicacao RDCA do cooperado
      CURSOR cr_craplap( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN craplap.nrdconta%TYPE
                        ,pr_dtiniext IN DATE
                        ,pr_dtfimext IN DATE
                        ,pr_nraplica IN craplap.nraplica%TYPE) IS
        SELECT craplap.cdcooper
              ,craplap.cdhistor
              ,craplap.dtmvtolt
              ,craplap.nrdocmto
              ,craplap.txaplmes
              ,craplap.vllanmto
        FROM   craplap
        WHERE  craplap.cdcooper  = pr_cdcooper
        AND    craplap.nrdconta  = pr_nrdconta
        AND    craplap.dtrefere  > pr_dtiniext
        AND    craplap.dtrefere <= pr_dtfimext
        AND    craplap.nraplica  = pr_nraplica
        AND    craplap.cdhistor IN ( 113 --APLIC. RDCA
                                    ,116 --RENDIMENTO
                                    ,118 --RESGATE
                                    ,119 --DIF.TX. MAIOR
                                    ,121 --DIF.TX. MENOR
                                    ,126 --SAQ.S/REND.30
                                    ,143 --RESG.P/UNIF.
                                    ,144 --UNIFIC. RDCA
                                    ,176 --APLIC. RDCA60
                                    ,178 --RESGATE
                                    ,179 --RENDIMENTO
                                    ,183 --SAQ.S/REND.60
                                    ,262 --APL.RDCA30ESP
                                    ,264 --RESGATE
                                    ,272 --FARMACIA SESI
                                    ,273 --FARMACIA SESI
                                    ,492 --RESGATE
                                    ,493 --SAQ.S/REND.30
                                    ,494 --RESGATE
                                    ,495 --SAQ.S/REND.60
                                    ,861 --DB.IRRF
                                    ,862 --DB.IRRF
                                    ,868 --IR ABONO APLIC
                                    ,871 --IR ABONO APL.
                                    ,875 --AJT RGT IR-30
                                    ,876 --AJT RGT IR-60
                                    ,877 --AJT REN IR-30
                                    )
      ORDER BY craplap.nraplica;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --estrutura de registro para armazenar os dados de historicos
      TYPE typ_reg_craphis IS
        RECORD(codigo       PLS_INTEGER
              ,vr_dsextrat  VARCHAR2(4000)
              ,vr_indebcre  VARCHAR2(4000));
      --tipo de registro para armazenar os historicos
      TYPE typ_tab_craphis IS TABLE OF typ_reg_craphis INDEX BY PLS_INTEGER;

      --estrutura de registro para armazenar os dados de associados
      TYPE typ_reg_crapass IS
        RECORD( nrdconta crapass.nrdconta%TYPE
               ,cdagenci crapass.cdagenci%TYPE
               ,cdsecext crapass.cdsecext%TYPE
               ,inpessoa crapass.inpessoa%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE);
      --tipo de registro para armazenar os associados
      TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;

      --estrutura de registro para armazenar as agencias
      TYPE typ_reg_crapage IS
        RECORD(nmresage crapage.nmresage%TYPE);
      --tipo de registro para armazenar as agencias
      TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

      --tipo para armazenar a estrutura do cadastro de titulares
      TYPE typ_reg_crapttl IS
        RECORD( cdempres crapttl.cdempres%TYPE
        );
      --estrutura do cadastro de titulares
      TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY PLS_INTEGER;

      --tipo para armazenar a estrutura do cadastro de pessoas juridicas
      TYPE typ_reg_crapjur IS
        RECORD( cdempres crapjur.cdempres%TYPE
        );
      --estrutura do cadastro de pessoas juridicas
      TYPE typ_tab_crapjur IS TABLE OF typ_reg_crapjur INDEX BY PLS_INTEGER;

      ------------------------------- VARIAVEIS -------------------------------
      -- Variáveis de negócio
      vr_nmdsecao      VARCHAR2(400);
      vr_nmresemp      dbms_sql.Varchar2_Table;

      vr_nrseqext      PLS_INTEGER;
      vr_nrextarq      PLS_INTEGER;
      vr_nrregext      VARCHAR2(140);--PLS_INTEGER;
      vr_nrdordem      PLS_INTEGER;
      vr_contador      PLS_INTEGER;
      vr_sldatual      NUMBER(20,2);
      vr_cdempres      PLS_INTEGER;
      vr_nom_dir       VARCHAR2(400);
      vr_nmarqdat      VARCHAR2(4000);
      vr_cdacesso      VARCHAR2(400);
      vr_imlogoin      VARCHAR2(4000);
      vr_imlogoex      VARCHAR2(4000);
      vr_nrarquiv      PLS_INTEGER;
      vr_nmagenci      VARCHAR2(500);
      -- variaveis de controle de comandos shell
      vr_comando			VARCHAR2(500);
      vr_typ_saida    VARCHAR2(1000);

      --tabelas temporarias
      vr_tab_craphis   typ_tab_craphis;
      vr_tab_crapass   typ_tab_crapass;
      vr_tab_crapage   typ_tab_crapage;
      vr_tab_crapttl   typ_tab_crapttl;
      vr_tab_crapjur   typ_tab_crapjur;
      vr_tab_cratext   form0001.typ_tab_cratext;

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Insere dados na temp table vr_tab_cratext
      PROCEDURE pc_criaext( pr_nrdordem IN INTEGER
                           ,pr_nrregext OUT VARCHAR2
                           ,pr_contador OUT INTEGER) IS
      BEGIN
        DECLARE
          vr_nmsecext   VARCHAR2(100);
          vr_indcrapext VARCHAR2(140);
        BEGIN
          vr_nrextarq := nvl(vr_nrextarq,0) + 1;
                    
          IF vr_tab_crapass(rw_craprda.nrdconta).inpessoa = 1 THEN
            --se existir informacao no cadastro de pessoa fisica
            IF vr_tab_crapttl.EXISTS(rw_craprda.nrdconta) THEN
              IF vr_tab_crapass(rw_craprda.nrdconta).cdsecext <> 0 THEN
                vr_nmsecext := vr_nmdsecao;
              END IF;
              -- codigo da empresa
              vr_cdempres   := vr_tab_crapttl(rw_craprda.nrdconta).cdempres;
            ELSE
              IF vr_tab_crapass(rw_craprda.nrdconta).cdsecext = 0 THEN
                vr_nmsecext := NULL;
              ELSE
                vr_nmsecext := vr_nmdsecao;
              END IF;
            END IF;
          ELSE
            --se existir informacao no cadastro de pessoa juridica
            IF vr_tab_crapjur.EXISTS(vr_tab_crapass(rw_craprda.nrdconta).nrdconta) THEN
              vr_cdempres := vr_tab_crapjur(vr_tab_crapass(rw_craprda.nrdconta).nrdconta).cdempres;
            END IF;
          END IF;

          -- indice da tabela
          vr_indcrapext := LPAD(vr_tab_cratext.count + 1, 10, '0');

          vr_tab_cratext(vr_indcrapext).nmsecext := vr_nmsecext;
          vr_tab_cratext(vr_indcrapext).nmempres := vr_nmresemp(vr_cdempres);
          vr_nmagenci := vr_tab_crapage(vr_tab_crapass(rw_craprda.nrdconta).cdagenci).nmresage;
          vr_tab_cratext(vr_indcrapext).nmagenci := vr_tab_crapage(vr_tab_crapass(rw_craprda.nrdconta).cdagenci).nmresage;
          vr_tab_cratext(vr_indcrapext).nrdconta := rw_craprda.nrdconta;
          vr_tab_cratext(vr_indcrapext).cdagenci := vr_tab_crapass(rw_craprda.nrdconta).cdagenci;
          vr_tab_cratext(vr_indcrapext).nmprimtl := vr_tab_crapass(rw_craprda.nrdconta).nmprimtl;
          vr_tab_cratext(vr_indcrapext).dtemissa := rw_crapdat.dtmvtolt;
          vr_tab_cratext(vr_indcrapext).nrdordem := pr_nrdordem;
          vr_tab_cratext(vr_indcrapext).nrsequen := vr_nrseqext;
          vr_tab_cratext(vr_indcrapext).tpdocmto := 11;
          vr_tab_cratext(vr_indcrapext).indespac := 2;   /* SECAO */
          vr_tab_cratext(vr_indcrapext).nrseqint := vr_nrextarq;

          /* Dados internos */
          IF rw_craprda.tpaplica = 3 THEN
            vr_tab_cratext(vr_indcrapext).dsintern(1)  := '     EXTRATO DE APLICACAO RDCA';
          ELSIF rw_craprda.tpaplica = 5 THEN
            vr_tab_cratext(vr_indcrapext).dsintern(1)  := '  EXTRATO DE APLICACAO RDCA 60';
          ELSE
            vr_tab_cratext(vr_indcrapext).dsintern(1)  := '  EXTRATO DE APLICACAO RDCA 30';
          END IF;

          vr_tab_cratext(vr_indcrapext).dsintern(2)  := RPAD(vr_tab_crapass(rw_craprda.nrdconta).nmprimtl, 40,' ') ||
                                                        RPAD(' ',13,' ')||
                                                        gene0002.fn_mask_conta(vr_tab_crapass(rw_craprda.nrdconta).nrdconta);

          vr_tab_cratext(vr_indcrapext).dsintern(3)  := TO_CHAR(rw_craprda.dtmvtolt,'DD/MM/YYYY');
          vr_tab_cratext(vr_indcrapext).dsintern(4)  := RPAD(' ',18,' ');
          vr_tab_cratext(vr_indcrapext).dsintern(5)  := RPAD(' ',10,' ');
          vr_tab_cratext(vr_indcrapext).dsintern(6)  := gene0002.fn_mask(rw_craprda.nraplica,'z.zzz.zz9');
          vr_tab_cratext(vr_indcrapext).dsintern(7)  := ' VALOR APLICADO';
          vr_tab_cratext(vr_indcrapext).dsintern(8)  := TO_CHAR(rw_craprda.vlaplica,'999G999G990D00');

          pr_contador := 8;
          pr_nrregext := vr_indcrapext;
        END;
      EXCEPTION
        WHEN OTHERS THEN          
          --codigo da critica
          vr_cdcritic := 11;
          --descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' Conta: ' ||gene0002.fn_mask_conta(rw_craprda.nrdconta);

          --aborta a execucao
          RAISE vr_exc_saida;
      END pc_criaext;

      --fnaliza a insercao dos dados na temp-table
      PROCEDURE pc_finalext( pr_nrregext IN VARCHAR2) IS
      BEGIN
        --Utilizado para preencher o vetor com todas as posicoes
        --antes de finalizar
        IF vr_contador < 22 THEN
          FOR vr_ind IN (vr_contador+1) .. 22 LOOP
            vr_tab_cratext(pr_nrregext).dsintern(vr_ind) := '';
          END LOOP;
        END IF;

        vr_tab_cratext(pr_nrregext).dsintern(23) := ' Obs.: Saldo sujeito a alteracao devido a';
        vr_tab_cratext(pr_nrregext).dsintern(24) := '       complementacao do IRRF (Lei 11.033/2004).';
        vr_tab_cratext(pr_nrregext).dsintern(25) := '#';

      END pc_finalext;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

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

      vr_tab_craphis.delete;
      -- Gravar dados de histórico na PL Table
      FOR rw_craphis IN cr_craphis(pr_cdcooper) LOOP
        vr_tab_craphis(rw_craphis.cdhistor).codigo := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).vr_dsextrat := rw_craphis.dsextrat;
        vr_tab_craphis(rw_craphis.cdhistor).vr_indebcre := rw_craphis.indebcre;
      END LOOP;

      -- Gravar array com dados das empresas
      FOR rw_crapemp IN cr_crapemp(pr_cdcooper) LOOP
        vr_nmresemp(rw_crapemp.cdempres) := rw_crapemp.nmresemp;
      END LOOP;

      vr_tab_crapass.delete;
      -- Gravar array com dados dos cooperados
      FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;

      vr_tab_crapage.delete;
      -- Gravar array com dados das agencias
      FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;

      --limpa a tabela de titulares
      vr_tab_crapttl.delete;
      --carrega a tabela temporaria de titulares
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapttl(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
      END LOOP;
      
      -- limpa a tabela pessoas juridicas
      vr_tab_crapjur.DELETE;
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapjur(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;
      
      -- Capturar pasta de operação
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '');

      -- Assimilar valores em variáveis
      vr_nmarqdat := LPAD(pr_cdcooper, 2, '0')  || 'crrl174_' || TO_CHAR(rw_crapdat.dtmvtolt, 'DD') || TO_CHAR(rw_crapdat.dtmvtolt, 'MM') || '_02.dat';
      vr_cdacesso := 'MSGEXTRAPL';
      vr_imlogoin := 'laser/imagens/logo_' || TRIM(rw_crapcop.nmrescop) || '_interno.pcx';
      vr_imlogoex := 'laser/imagens/logo_' || TRIM(rw_crapcop.nmrescop) || '_externo.pcx';
      vr_nrseqext := 0;
      vr_nrextarq := 0;
      vr_contador := 0;

      -- Processar aplicações RDA
      OPEN cr_craprda(pr_cdcooper, rw_crapdat.dtmvtolt);
      LOOP
        FETCH cr_craprda INTO rw_craprda;
        EXIT WHEN cr_craprda%NOTFOUND;

        -- Desprezar saldos menos que R$ 1,00 em dezembro de 1.995
        IF rw_craprda.dtsdrdan > TO_DATE('31/10/1995', 'DD/MM/RRRR') AND rw_craprda.dtsdrdan < TO_DATE('01/12/1995', 'DD/MM/RRRR') AND
           rw_craprda.vlsdrdan > 0 AND rw_craprda.vlsdrdan < 1 THEN
          CONTINUE;
        END IF;

        -- Desprezar extratos que não sejam individuais
        IF rw_craprda.tpemiext <> 1 THEN
          CONTINUE;
        END IF;

        --verifica se a conta existe
        IF NOT vr_tab_crapass.EXISTS(rw_craprda.nrdconta) THEN

          --codigo da critica
          vr_cdcritic := 251;

          --descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' Conta: ' ||gene0002.fn_mask_conta(rw_craprda.nrdconta);

          --aborta a execucao
          RAISE vr_exc_saida;
        END IF;

        /*  Leitura do destino  */
        OPEN cr_crapdes( pr_cdcooper => pr_cdcooper
                        ,pr_cdagenci => vr_tab_crapass(rw_craprda.nrdconta).cdagenci
                        ,pr_cdsecext => vr_tab_crapass(rw_craprda.nrdconta).cdsecext);
        FETCH cr_crapdes INTO rw_crapdes;

        --verifica se encontrou informacao
        IF cr_crapdes%FOUND THEN
          vr_nmdsecao := rw_crapdes.nmsecext;
        ELSE
          vr_nmdsecao := 'SECAO EXCLUIDA';
        END IF;
        --fechando o cursor
        CLOSE cr_crapdes;

        --concatena
        vr_nrseqext := nvl(vr_nrseqext,0) + 1;

        --grava informacoes na tabela temporaria
        pc_criaext( pr_nrdordem => 1
                   ,pr_nrregext => vr_nrregext
                   ,pr_contador => vr_contador);

        --incrementa o contador de registros dsintern
        vr_contador := nvl(vr_contador,0) + 1;

        --gera informacoes dos lancamentos
        vr_tab_cratext(vr_nrregext).dsintern(vr_contador) := TO_CHAR(rw_craprda.dtsdrdan,'DD/MM/YYYY')||
                                                             ' SALDO ANTERIOR' || RPAD(' ',37,' ') ||
                                                             TO_CHAR(rw_craprda.vlsdrdan,'999G999G990D00');
        --inicializa o numero de ordem
        vr_nrdordem := 1;

        --percorre os lancamentos de aplicacoes RDCA para a conta
        FOR rw_craplap IN cr_craplap( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_craprda.nrdconta
                                     ,pr_dtiniext => rw_craprda.dtiniext
                                     ,pr_dtfimext => rw_craprda.dtfimext
                                     ,pr_nraplica => rw_craprda.nraplica)
        LOOP
          --incrementa o contador de registros dsintern
          vr_contador := vr_contador + 1;

          --se tem mais de 20 lancamentos
          --efetua quebra de pagina
          IF vr_contador > 20 THEN
            --finaliza a pagina da temptable
            pc_finalext(pr_nrregext => vr_nrregext);

            --incrementa o numero de ordem
            vr_nrdordem := nvl(vr_nrdordem,0) + 1;

            --insere novo registro na tabela temporaria
            pc_criaext( pr_nrdordem => vr_nrdordem
                       ,pr_nrregext => vr_nrregext
                       ,pr_contador => vr_contador);

            --incrementa o contador de registros dsintgern
            vr_contador := vr_contador + 1;
          END IF;

          --se não encontrar o historico, vai para o proximo registro
          IF NOT vr_tab_craphis.EXISTS(rw_craplap.cdhistor) THEN
            CONTINUE;
          END IF;

          -- insere nova informacao na lista de lancamentos
          vr_tab_cratext(vr_nrregext).dsintern(vr_contador) := TO_CHAR(rw_craplap.dtmvtolt,'DD/MM/YYYY') || ' ' ||
                                                               RPAD(vr_tab_craphis(rw_craplap.cdhistor).vr_dsextrat,21,' ') || '  ' ||
                                                               gene0002.fn_mask(rw_craplap.nrdocmto,'zzz.zzz.zzz') || '  ';

          --se o histórico:
          --861-DB.IRRF
          --862-DB.IRRF
          --868-IR ABONO APLIC
          --871-IR ABONO APL.
          --ou, se indicar movimento de credito e taxa mensal maior que zero
          IF rw_craplap.cdhistor  IN (862, 861, 868, 871)  OR
             (vr_tab_craphis(rw_craplap.cdhistor).vr_indebcre = 'C' AND rw_craplap.txaplmes > 0) THEN
            --gera lancamento  informando a taxa mensal
            vr_tab_cratext(vr_nrregext).dsintern(vr_contador) := vr_tab_cratext(vr_nrregext).dsintern(vr_contador)||
                                                                 TO_CHAR(rw_craplap.txaplmes,'990D999999')||'  '||
                                                                 vr_tab_craphis(rw_craplap.cdhistor).vr_indebcre||'  '||
                                                                 TO_CHAR(rw_craplap.vllanmto,'999G999G990D99MI');
          ELSE
            --gera lancamento omitindo a taxa mensal
            vr_tab_cratext(vr_nrregext).dsintern(vr_contador) := vr_tab_cratext(vr_nrregext).dsintern(vr_contador)||
                                                                 '            ' ||
                                                                 vr_tab_craphis(rw_craplap.cdhistor).vr_indebcre||
                                                                 '  '||TO_CHAR(rw_craplap.vllanmto,'999G999G990D99MI');
          END IF;
        END LOOP;--FOR rw_craplap IN cr_craplap

        --incrementa o contador de registros dsintgern
        vr_contador := vr_contador + 1;

        --se tem mais de 20 lancamentos
        --efetua quebra de pagina
        IF vr_contador > 20 THEN
          --finaliza o lancamendo da pagina
          pc_finalext(pr_nrregext => vr_nrregext);

          --incrementa o contador de registros
          vr_nrdordem := vr_nrdordem + 1;

          --insere novo registro na tabela temporaria
          pc_criaext( pr_nrdordem => vr_nrdordem
                     ,pr_nrregext => vr_nrregext
                     ,pr_contador => vr_contador);

          --incrementa o contador de registros dsintgern
          vr_contador := vr_contador + 1;
        END IF;

        --se o saldo menor que zero zera o saldo
        IF rw_craprda.vlsdrdca < 0 THEN
          vr_sldatual := 0;
        ELSE
          --senao armazena o saldo
          vr_sldatual := rw_craprda.vlsdrdca;
        END IF;

        vr_tab_cratext(vr_nrregext).dsintern(vr_contador) := TO_CHAR(rw_craprda.dtiniper,'DD/MM/YYYY')||
                                                             ' SALDO ATUAL' || RPAD(' ',40,' ')||
                                                             TO_CHAR(vr_sldatual,'999G999G990D99MI');

        pc_finalext(pr_nrregext => vr_nrregext);

      END LOOP;--OPEN cr_craprda

      --inicializa a ordem do arquivo
      vr_nrarquiv := 1;

      /* Gerar os dados para a frente e verso dos informativos. */
      FORM0001.pc_gera_dados_inform( pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_cdacesso => vr_cdacesso
                                    ,pr_qtmaxarq => 0
                                    ,pr_nrarquiv => vr_nrarquiv
                                    ,pr_dsdireto => vr_nom_dir||'/arq'
                                    ,pr_nmarqdat => vr_nmarqdat
                                    ,pr_tab_cratext => vr_tab_cratext
                                    ,pr_imlogoex    => vr_imlogoex
                                    ,pr_imlogoin    => vr_imlogoin
                                    ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      --se tem dados pra gerar
      IF nvl(vr_nrextarq,0) > 0 THEN

        -- Comando para copiar o arquivo para a pasta salvar
        vr_comando:= 'mv '||vr_nom_dir||'/arq/'||vr_nmarqdat||' '||vr_nom_dir||'/salvar/';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => pr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
         pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
         -- retornando ao programa chamador
         RETURN;
        END IF;


        /* COOPERATIVAS QUE TRABALHAM COM A ENGECOPY */
        IF pr_cdcooper IN (1,2,4) THEN
          -- Chamar o envio a Blucopy --
          FORM0001.pc_envia_dados_blucopy(pr_cdcooper => pr_cdcooper
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_dslstarq => vr_nom_dir||'/salvar/'||vr_nmarqdat --> Lista de arquivos a enviar
                                         ,pr_dsasseml => 'Cartas '||rw_crapcop.nmrescop||' - Arquivo ['||to_char(vr_nrarquiv,'fm00')||']'
                                         ,pr_dscoreml => 'Em anexo o arquivo('||SUBSTR(vr_nmarqdat,1,INSTR(vr_nmarqdat,'.')-1)||'.zip) contendo as cartas da cooperativa '||rw_crapcop.nmrescop||'.'
                                         ,pr_des_erro => vr_dscritic);
          -- Testar saída com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levanta exceção
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;
        ELSE
          -- Chamar o envio dos dados a Postmix
          FORM0001.pc_envia_dados_postmix(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_nmarqdat => vr_nmarqdat || to_char(vr_nrarquiv,'fm00') || '.dat'
                                         ,pr_nmarqenv => 'salvar/'||vr_nmarqdat
                                         ,pr_inaguard => 'N'
                                         ,pr_des_erro => vr_dscritic);
          -- Testar saída com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levanta exceção
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;

        END IF;

      END IF;

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
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic);

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
        pr_dscritic := SQLERRM;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps220;
/

