CREATE OR REPLACE PROCEDURE CECRED.pc_crps290 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> Codigo operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
 /* ..........................................................................

   Programa: Fontes/crps290.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2000.                      Ultima atualizacao: 30/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.
               Efetuar os lancamentos automaticos no sistema de cheques em
               custodia e titulos compensaveis.
               Emite relatorio 238.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               08/10/2003 - Atualizar craplcm.dtrefere (Margarete).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).

               11/11/2005 - Acertar leitura do crapfdc (Magui).

               10/12/2005 - Atualizar craprej.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).

               07/03/2007 - Ajustes para o Bancoob (Magui).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               17/07/2009 - incluido no for each a condição -
                            craplau.dsorigem <> 'PG555' - Precise - paulo

               02/06/2011 - incluido no for each a condição -
                            craplau.dsorigem <> 'TAA' (Evandro).

               03/10/2011 - Ignorado dsorigem = 'CARTAOBB' na leitura da
                            craplau. (Fabricio)

               24/10/2012 - Tratamento para os cheques das contas migradas
                            (Viacredi -> Alto Vale), realizado na procedure
                            proc_trata_custodia. (Fabricio)

               23/01/2013 - Criar de rejeicao para as criticas 680 e 681 apos
                            leitura da craplot (David).

               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> 'BLOQJUD' (Andre Santos - SUPERO)

               20/01/2014 - Efetuada correção na leitura da tabela craptco da
                            procedure 'proc_trata_custodia' (Diego).

               24/01/2014 - Incluir VALIDATE craplot, craplcm, craprej (Lucas R)
                            Incluido 'RELEASE craptco' para garantir que o
                            programa nao pegue um registro lido anteriormente.
                            (Fabricio)

               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> 'DAUT BANCOOB' (Lucas).

               28/09/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> 'CAIXA' (Lombardi).

               30/05/2016 - Incluir criticas 251, 695, 410, 95 no relatorio e
                            atualizar o insitlau para 3(Cancelado) (Lucas Ranghetti #449799)
............................................................................. */

   ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS290';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

     -- contas cheque
    TYPE typ_contas_cheque IS
      RECORD (cdcooper craptco.cdcooper%type,
              nrdconta craptco.nrdconta%type,
              nrdctabb craplau.nrdctabb%type,
              nrdctitg craplau.nrdctitg%type,
              cdhistor craplau.cdhistor%type,
              vllanmto craplau.vllanaut%type,
              cdbanchq crapfdc.cdbanchq%type,
              cdagechq crapfdc.cdagechq%type,
              nrctachq crapfdc.nrctachq%type,
              nrdocmto craplau.nrdocmto%type);

    -- Definicao do tipo de tabela que armazena
    -- registros do tipo acima detalhado
    TYPE typ_tab_contas_cheque IS
      TABLE OF typ_contas_cheque
      INDEX BY VARCHAR2(10);
    -- Vetores para armazenar as informacoes de moedas
    vr_tab_contas_cheque typ_tab_contas_cheque;
    vr_index number;
    vr_idx   number;
    vr_valor number;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB

    vr_rel_dshistor       VARCHAR2(1000);
    vr_caminho_integra VARCHAR2(1000);

    ------------------------------- CURSORES ---------------------------------

 --cursor final relatório 
   cursor cr_craplotrl(pr_cdcooper craplot.cdcooper%type,
                       pr_dtmvtopr craplot.dtmvtolt%type)is
    select  rowid,
            qtcompln,
            vlcompdb,
            vlcompcr,
            nrdolote,
            cdagenci,
            cdbccxlt,
            dtmvtolt,
            tplotmov,
            dtmvtopg,
            vlinfodb,
            vlinfocr,
            qtinfoln from craplot
            WHERE craplot.cdcooper = pr_cdcooper   AND
                  craplot.dtmvtolt = pr_dtmvtopr   AND
                 (craplot.nrdolote = 4500           OR
                  craplot.nrdolote = 4600);
  --cursor corpo relatório
    cursor cr_corpo_rel(pr_cdcooper craprej.cdcooper%type,
                        pr_dtmvtopr craprej.dtmvtolt%type,
                        pr_cdagenci craprej.cdagenci%type,
                        pr_cdbccxlt craprej.cdbccxlt%type,
                        pr_nrdolote craprej.nrdolote%type)is
    select  rowid,
            cdcritic,
            tpintegr,
            nraplica,
            cdpesqbb,
            vllanmto
       from  craprej
             WHERE craprej.cdcooper = pr_cdcooper  AND
                   craprej.dtmvtolt = pr_dtmvtopr  AND
                   craprej.cdagenci = pr_cdagenci  AND
                   craprej.cdbccxlt = pr_cdbccxlt  AND
                   craprej.nrdolote = pr_nrdolote  AND
                   craprej.cdcritic is not null    AND
                  (craprej.tpintegr = 19                 OR
                   craprej.tpintegr = 20);


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar lotes
    CURSOR cr_crablot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_dtmvtopr craplot.dtmvtopg%TYPE)IS
      SELECT craplot.rowid, 
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     tplotmov,
                     dtmvtolt,
                     nrseqdig,
                     qtinfoln,
                     qtcompln,
                     vlinfodb,
                     vlcompdb
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtopg >= pr_dtmvtolt
         AND craPlot.dtmvtopg <= pr_dtmvtopr
         AND craplot.tplotmov in (19,20);

    --
    CURSOR cr_craplau(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplau.dtmvtolt%TYPE,
                      pr_cdagenci craplau.cdagenci%type,
                      pr_cdbccxlt craplau.cdbccxlt%type,
                      pr_nrdolote craplau.nrdolote%type) is

    select 	rowid,
            vllanaut,
            cdcritic,
            cdhistor,
            nrdconta,
            nrdctabb,
            nrdctitg,
            nrseqdig,
            nrdocmto,
            cdseqtel,
            dtdebito,
            insitlau,
            dtmvtolt,
            cdagenci,
            cdbccxlt,
            nrdolote from craplau
           WHERE craplau.cdcooper  = pr_cdcooper       AND
                 craplau.dtmvtolt  = pr_dtmvtolt       AND
                 craplau.cdagenci  = pr_cdagenci       AND
                 craplau.cdbccxlt  = pr_cdbccxlt       AND
                 craplau.nrdolote  = pr_nrdolote       AND
                 craplau.insitlau  = 1                 AND
                 craplau.dsorigem <> 'CAIXA '           AND
                 craplau.dsorigem <> 'INTERNET'         AND
                 craplau.dsorigem <> 'TAA'              AND
                 craplau.dsorigem <> 'PG555'            AND
                 craplau.dsorigem <> 'CARTAOBB'         AND
                 craplau.dsorigem <> 'BLOQJUD'          AND
                 craplau.dsorigem <> 'DAUT BANCOOB';

    cursor cr_crapass(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_nrconta  crapass.nrdconta%type) is

     select crapass.cdcooper from  crapass
        WHERE crapass.cdcooper = pr_cdcooper   AND
              crapass.nrdconta = pr_nrconta;
     rw_crapass cr_crapass%ROWTYPE;
    --------------------
    cursor cr_craplot1(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtopr craplot.dtmvtolt%type,
                      pr_nrdolote craplot.nrdolote%type ) is
     select rowid,
            dtmvtolt,
            cdagenci,
            cdbccxlt,
            nrdolote,
            tplotmov from  craplot
       WHERE craplot.cdcooper =  pr_cdcooper   AND
             craplot.dtmvtolt =  pr_dtmvtopr   AND
             craplot.cdagenci = 1              AND
             craplot.cdbccxlt = 100            AND
             craplot.nrdolote = pr_nrdolote;

    
    ------------------------------- VARIAVEIS -------------------------------
    vr_nrdocmt2   craplcm.nrdocmto%TYPE;
    
    vr_cdagenci   NUMBER;
    vr_cdbccxlt   NUMBER;
    vr_nrdolote   NUMBER;
    vr_tplotmov   NUMBER;
    vr_dtmvtolt   VARCHAR2(10);
    vr_nrcustod   NUMBER;
    ----------------variaveis do relatório
    vr_rel_qtdifeln number(8,2);
    vr_rel_vldifedb number(8,2);
    vr_rel_vldifecr number(8,2);
    vr_rel_dsintegr varchar2(1000);
    pr_regexist  boolean;


--------------------------- SUBROTINAS INTERNAS --------------------------
  --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

      PROCEDURE pc_processamento_tco is

        vr_contareg number;
        vr_nrlotetc number;
        vr_nrlottco number;
        vr_nrdocmt2 number;
        vr_nrdocmto number;
        vr_cdcritic number;
        vr_validatab number;

        cursor cr_craplcm(pr_nrdctabb craplcm.nrdctabb%TYPE,
                          pr_nrdocmt2 craplcm.nrdocmto%type) is
             select
             craplot.nrseqdig     
            ,craplot.nrdolote
            ,craplot.dtmvtolt
            ,craplot.cdagenci
            ,craplot.cdbccxlt
            ,craplot.vlcompdb 
            ,craplot.vlinfodb
            ,craplot.qtcompln
            ,craplot.qtinfoln
         from craplcm,
              craplot
            WHERE craplcm.cdcooper = craplot.cdcooper   AND
                  craplcm.dtmvtolt = craplot.dtmvtolt   AND
                  craplcm.cdagenci = craplot.cdagenci   AND
                  craplcm.cdbccxlt = craplot.cdbccxlt   AND
                  craplcm.nrdolote = craplot.nrdolote   AND
                  craplcm.nrdctabb = pr_nrdctabb        AND
                  craplcm.nrdocmto = pr_nrdocmt2;
        rw_craplcm cr_craplcm%rowtype;
       begin
           vr_idx := vr_tab_contas_cheque.FIRST;
            LOOP
              vr_nrlottco := 0;
            EXIT WHEN vr_idx IS NULL;
               vr_contareg := vr_contareg + 1;
               vr_nrlotetc := 4500;

               IF vr_contareg = 1 THEN
                begin
                  insert into craplot
                             (craplot.cdcooper,
                              craplot.dtmvtolt,
                              craplot.cdagenci,
                              craplot.cdbccxlt,
                              craplot.nrdolote,
                              craplot.tplotmov)
                              values
                              (vr_tab_contas_cheque(vr_idx).cdcooper,
                               rw_crapdat.dtmvtopr,
                               1,
                               100,
                               vr_nrlottco,
                               1);
                  vr_nrlotetc := vr_nrlotetc + 1;
                  exception
                     when others then
                       update craplot
                          set craplot.cdagenci = 1
                              ,craplot.cdbccxlt = 100
                      where craplot.cdcooper = vr_tab_contas_cheque(vr_idx).cdcooper
                        and craplot.dtmvtolt = rw_crapdat.dtmvtopr
                        AND craplot.nrdolote = vr_nrlotetc;
                 end;
                 vr_nrlottco := vr_nrlotetc;
               else
                 select count(*)
                   into
                   vr_validatab
                   from craplot
                   WHERE craplot.cdcooper = vr_tab_contas_cheque(vr_idx).cdcooper   AND
                         craplot.dtmvtolt = rw_crapdat.dtmvtopr AND
                         craplot.cdagenci = 1                   AND
                         craplot.cdbccxlt = 100                 AND
                         craplot.nrdolote = vr_nrlottco;
                  if vr_validatab = 0 then
                     vr_cdcritic := 60;
                  end if;
               end if;
               vr_nrdocmt2 := vr_tab_contas_cheque(vr_idx).nrdocmto;

               OPEN cr_craplcm(vr_tab_contas_cheque(vr_index).nrdctabb ,
                               vr_nrdocmt2 );
               FETCH cr_craplcm
               INTO rw_craplcm;
               IF cr_craplcm%NOTFOUND THEN
                  pr_cdcritic := 680;
                  vr_nrcustod := 0;
                  CLOSE cr_craplcm;
               else
                 vr_nrdocmt2 := (vr_nrdocmt2 + 1000000);
               end if;
               begin
                 insert into craplcm
                 (craplcm.dtmvtolt,
                  craplcm.dtrefere,
                  craplcm.cdagenci,
                  craplcm.cdbccxlt,
                  craplcm.nrdolote,
                  craplcm.nrdconta,
                  craplcm.nrdctabb,
                  craplcm.nrdctitg,
                  craplcm.nrdocmto,
                  craplcm.cdhistor,
                  craplcm.vllanmto,
                  craplcm.nrseqdig,
                  craplcm.cdcooper,
                  craplcm.cdbanchq,
                  craplcm.cdagechq,
                  craplcm.nrctachq,
                  craplcm.cdpesqbb)
                  values
                  (
                  rw_craplcm.dtmvtolt,
                  rw_craplcm.dtmvtolt,
                  rw_craplcm.cdagenci,
                  rw_craplcm.cdbccxlt,
                  rw_craplcm.nrdolote,
                  vr_tab_contas_cheque(vr_index).nrdconta,
                  vr_tab_contas_cheque(vr_index).nrdctabb,
                  vr_tab_contas_cheque(vr_index).nrdctitg,
                  vr_nrdocmto,
                  vr_tab_contas_cheque(vr_index).cdhistor,
                  vr_tab_contas_cheque(vr_index).vllanmto,
                  rw_craplcm.nrseqdig + 1,
                  vr_tab_contas_cheque(vr_index).cdcooper,
                  vr_tab_contas_cheque(vr_index).cdbanchq,
                  vr_tab_contas_cheque(vr_index).cdagechq,
                  vr_tab_contas_cheque(vr_index).nrctachq,
                  'LANCAMENTO DE CONTA MIGRADA');
                exception
                 when others then
                 vr_dscritic := 'Problema ao inserir dados craplcm '||sqlerrm;

               end;


               begin
                update craplot
                   set craplot.qtinfoln = rw_craplcm.qtinfoln + 1,
                       craplot.qtcompln = rw_craplcm.qtcompln + 1,
                       craplot.vlinfodb = rw_craplcm.vlinfodb + vr_tab_contas_cheque(vr_index).vllanmto,
                       craplot.vlcompdb = rw_craplcm.vlcompdb + vr_tab_contas_cheque(vr_index).vllanmto,
                       craplot.nrseqdig = rw_craplcm.nrseqdig + 1;
               exception
                when others then
                  vr_dscritic := 'Problema ao alterar dados craplot '||sqlerrm;
               end;

            END LOOP;


      end pc_processamento_tco;
      PROCEDURE pc_trata_custodia(vr_cdcooper in number, pr_craplau cr_craplau%ROWTYPE,
                                   pr_craplot cr_crablot%rowtype) is


          cursor cr_crapcst(pr_cdcooper crapcst.cdcooper%type,
                            pr_dtmvtolt crapcst.dtmvtolt%type,
                            pr_cdagenci crapcst.cdagenci%type,
                            pr_cdbccxlt crapcst.cdbccxlt%type,
                            pr_nrdolote crapcst.nrdolote%type,
                            pr_cdcmpchq crapcst.cdcmpchq%type,
                            pr_cdbanchq crapcst.cdbanchq%type,
                            pr_cdagechq crapcst.cdagechq%type,
                            pr_nrctachq crapcst.nrctachq%type,
                            pr_nrcheque crapcst.nrcheque%type) is

              select  rowid,
                      nrdconta,
                      cdbanchq,
                      cdagechq,
                      nrctachq,
                      nrcheque from crapcst
                       where crapcst.cdcooper = pr_cdcooper
                         and crapcst.dtmvtolt = pr_dtmvtolt
                         and crapcst.cdagenci = PR_cdagenci
                         and crapcst.cdbccxlt = pr_cdbccxlt
                         and crapcst.nrdolote = pr_nrdolote
                         and crapcst.cdcmpchq = pr_cdcmpchq
                         and crapcst.cdbanchq = pr_cdbanchq
                         and crapcst.cdagechq = pr_cdagechq
                         and crapcst.nrctachq = pr_nrctachq
                         and crapcst.nrcheque = pr_nrcheque;

          rw_crapcst cr_crapcst%ROWTYPE;
        --Cadastro de folhas de cheques emitidos para o cooperado.
        cursor cr_crapfdc(pr_cdcooper crapfdc.cdcooper%type,
                           pr_cdbanchq crapfdc.cdbanchq%type,
                           pr_cdagechq crapfdc.cdagechq%type,
                           pr_nrctachq crapfdc.nrctachq%type,
                           pr_nrcheque crapfdc.nrcheque%type) is

          select crapfdc.rowid,
                 dtemschq,
                 tpcheque,
                 dtretchq,
                 incheque,
                 vlcheque,
                 cdbanchq,
                 cdagechq,
                 nrctachq from crapfdc
            WHERE crapfdc.cdcooper = pr_cdcooper       AND
                  crapfdc.cdbanchq = pr_cdbanchq       AND
                  crapfdc.cdagechq = pr_cdagechq       AND
                  crapfdc.nrctachq = pr_nrctachq       AND
                  crapfdc.nrcheque = pr_nrcheque;

         rw_crapfdc cr_crapfdc%ROWTYPE;



         cursor cr_craplcm(pr_cdcooper craplcm.cdcooper%type,
                           pr_dtmvtopr craplcm.dtmvtolt%type,
                           pr_cdagenci craplcm.cdagenci%type,
                           pr_cdbccxlt craplcm.cdbccxlt%type,
                           pr_nrdolote craplcm.nrdolote%type,
                           pr_nrdctabb craplcm.nrdctabb%type,
                           pr_nrdocmto craplcm.nrdocmto%type)is
               select * from craplcm
                 WHERE craplcm.cdcooper = pr_cdcooper AND
                       craplcm.dtmvtolt = pr_dtmvtopr AND
                       craplcm.cdagenci = pr_cdagenci AND
                       craplcm.cdbccxlt = pr_cdbccxlt AND
                       craplcm.nrdolote = pr_nrdolote AND
                       craplcm.nrdctabb = pr_nrdctabb AND
                       craplcm.nrdocmto = pr_nrdocmto;

          rw_craplcm cr_craplcm%rowtype;
          vr_nrconta crapcot.nrdconta%type;
          vr_contamigrada number;
          pr_cdcopant  number;
          pr_dtmvtolt  date;
          PR_cdagenci  NUMBER;
          pr_cdbccxlt  NUMBER;
          pr_nrdolote  NUMBER;
          pr_cdcmpchq  NUMBER;
          pr_cdbanchq  NUMBER;
          pr_cdagechq  NUMBER;
          pr_nrctachq  NUMBER;
          pr_nrcheque  NUMBER;
          pr_flgentra  boolean;
          vr_cooper number;

       -- armazena a cooperativa anterior no caso de verificar a tco 
       begin

       IF   vr_cdcooper = 1 THEN
            pr_cdcopant := 2;

       ELSE
        IF  vr_cdcooper = 16 THEN
            pr_cdcopant := 1;
        END IF;
       END IF;

        begin
             pr_dtmvtolt := to_date(SUBSTR(pr_craplau.cdseqtel,1,10),'dd/mm/rrrr');
        exception
            when others then
             pr_dtmvtolt := to_date(SUBSTR(pr_craplau.cdseqtel,1,10),'dd/mm/rrrr');

        end;
        pr_cdagenci := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,12,3));
        pr_cdbccxlt := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,16,3));
        pr_nrdolote := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,20,6));
        pr_cdcmpchq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,27,3));
        pr_cdbanchq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,31,3));
        pr_cdagechq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,35,4));
        pr_nrctachq := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,40,8));
        pr_nrcheque := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,49,6));
        --          VARIAVEL SECUNDÁRIA           
        
       OPEN cr_crapcst(pr_cdcooper ,
                       pr_dtmvtolt ,
                       pr_cdagenci ,
                       pr_cdbccxlt ,
                       pr_nrdolote ,
                       pr_cdcmpchq ,
                       pr_cdbanchq ,
                       pr_cdagechq ,
                       pr_nrctachq ,
                       pr_nrcheque );
       FETCH cr_crapcst
       INTO rw_crapcst;
       IF cr_crapcst%NOTFOUND THEN
          pr_cdcritic := 680;
          vr_nrcustod := 0;
          CLOSE cr_crapcst;

          begin
             update craplau
              set craplau.insitlau = 3,
                  craplau.dtdebito = pr_dtmvtolt,
                  craplau.cdcritic = pr_cdcritic
                  where craplau.rowid = pr_craplau.rowid;
          exception
            when others then
              vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
          end;
           begin
                          insert into craprej
                           (craprej.dtmvtolt,
                            craprej.cdagenci,
                            craprej.cdbccxlt,
                            craprej.nrdolote,
                            craprej.tplotmov,
                            craprej.cdhistor,
                            craprej.nraplica,
                            craprej.nrdconta,
                            craprej.nrdctabb,
                            craprej.nrdctitg,
                            craprej.nrseqdig,
                            craprej.nrdocmto,
                            craprej.vllanmto,
                            craprej.cdpesqbb,
                            craprej.cdcritic,
                            craprej.tpintegr,
                            craprej.cdcooper)
                            values
                            (
                            vr_dtmvtolt,
                            vr_cdagenci,
                            vr_cdbccxlt,
                            vr_nrdolote,
                            vr_tplotmov,
                            pr_craplau.cdhistor,
                            vr_nrcustod,
                            pr_craplau.nrdconta,
                            pr_craplau.nrdctabb,
                            pr_craplau.nrdctitg,
                            pr_craplau.nrseqdig,
                            pr_craplau.nrdocmto,
                            pr_craplau.vllanaut,
                            pr_craplau.cdseqtel,
                            vr_cdcritic,
                            pr_craplot.tplotmov,
                            pr_cdcooper
                            );
             exception
               when others then
                 vr_dscritic := 'Problema ao inserir dados craprej '||sqlerrm;

             end;
        else
          vr_nrcustod := rw_crapcst.nrdconta;

           begin
             select crapcri.dscritic
                    into
                     vr_dscritic
                     from crapcri
              where crapcri.cdcritic = pr_craplau.cdcritic;
             exception
               when others then
                 vr_dscritic := null;
           end;
        end if;
       --- fim do while
        pr_cdcritic := 0;
        pr_flgentra := TRUE;

    IF   pr_craplau.cdhistor NOT IN (21,26)   THEN
           pr_cdcritic := 245;
    ELSE
      -- Verifica antes se eh conta migrada 
          begin
             select craptco.nrcarant,
                    craptco.nrdconta
              into
              vr_contamigrada,
              vr_nrconta from craptco
             where craptco.cdcopant = pr_cdcopant          AND
                   craptco.nrctaant = to_number(rw_crapcst.nrctachq) AND
                   craptco.tpctatrf = 1                     AND
                   craptco.flgativo = 1;
            exception
               when others then
                 vr_contamigrada := null;
                 vr_nrconta      := 0;
          end;

        if (vr_contamigrada is not null)  then
          vr_cooper := pr_cdcopant;
        else
          vr_cooper := pr_cdcooper;
        end if;
        --fim validação

         OPEN cr_crapfdc(vr_cooper,
                         rw_crapcst.cdbanchq,
                         rw_crapcst.cdagechq,
                         nvl(vr_contamigrada,rw_crapcst.nrctachq),
                         rw_crapcst.nrcheque);
         FETCH cr_crapfdc
         INTO rw_crapfdc;
         IF cr_crapfdc%NOTFOUND THEN
           close cr_crapfdc;
         else

           IF (rw_crapfdc.dtemschq is null)   THEN
               pr_cdcritic := 108;
           ELSE
                 IF (rw_crapfdc.tpcheque = 2) THEN
                    pr_cdcritic := 646;
                 ELSE
                   IF (rw_crapfdc.dtretchq is null)   THEN
                       pr_cdcritic := 109;
                   ELSE
                     IF rw_crapfdc.incheque in (5,6,7)   THEN
                        pr_cdcritic := 97;
                     ELSIF (rw_crapfdc.incheque = 8)   THEN
                            pr_cdcritic := 320;
                        ELSE
                          IF (rw_crapfdc.tpcheque = 3) AND -- cheque salario 
                             (rw_crapfdc.incheque = 1) THEN
                              pr_cdcritic := 96;
                          ELSE
                            IF (rw_crapfdc.tpcheque = 3) AND -- cheque salario 
                               (rw_crapfdc.vlcheque <> pr_craplau.vllanaut) THEN
                                pr_cdcritic := 269;
                            END IF;
                     END IF;
                   END IF;
                 END IF;
           END IF;
         END IF;

      END IF;
     END IF;
     if pr_cdcritic = 0 then

       BEGIN

        OPEN cr_craplcm(pr_cdcooper,
                        rw_crapdat.dtmvtopr,
                        pr_craplot.cdagenci,
                        pr_craplot.cdbccxlt,
                        pr_craplot.nrdolote,
                        pr_craplau.nrdctabb,
                        pr_craplau.nrdocmto);
       FETCH cr_craplcm
       INTO rw_craplcm;
        IF cr_craplcm%NOTFOUND THEN
           IF pr_craplau.cdhistor = 26   THEN
              IF rw_crapfdc.incheque = 2   THEN
                 pr_cdcritic := 287;
              end if;
           ELSE
             IF pr_craplau.cdhistor = 21 THEN
                IF rw_crapfdc.incheque = 2   THEN
                   pr_cdcritic := 257;
                ELSE
                  IF rw_crapfdc.incheque = 1   THEN
                     pr_cdcritic := 96;
                  end if;
                end if;
             end if;
           end if;
        else
          pr_cdcritic := 92;
          close cr_craplcm;
        end if;
       end;
     end if;
     IF pr_cdcritic > 0 THEN
          -- rejeitados 
             begin
               insert into craprej
                          (craprej.dtmvtolt,
                           craprej.cdagenci,
                           craprej.cdbccxlt,
                           craprej.nrdolote,
                           craprej.tplotmov,
                           craprej.cdhistor,
                           craprej.nraplica,
                           craprej.nrdconta,
                           craprej.nrdctabb,
                           craprej.nrdctitg,
                           craprej.nrseqdig,
                           craprej.nrdocmto,
                           craprej.vllanmto,
                           craprej.cdpesqbb,
                           craprej.cdcritic,
                           craprej.tpintegr,
                           craprej.cdcooper)
                           values
                           (
                           vr_dtmvtolt,
                           vr_cdagenci,
                           vr_cdbccxlt,
                           vr_nrdolote,
                           vr_tplotmov,
                           pr_craplau.cdhistor,
                           vr_nrcustod,
                           pr_craplau.nrdconta,
                           pr_craplau.nrdctabb,
                           pr_craplau.nrdctitg,
                           pr_craplau.nrseqdig,
                           pr_craplau.nrdocmto,
                           pr_craplau.vllanaut,
                           pr_craplau.cdseqtel,
                           vr_cdcritic,
                           pr_craplot.tplotmov,
                           pr_cdcooper
                           );
             exception
               when others then
                 vr_dscritic := 'Problema ao inserir dados craprej '||sqlerrm;
             end;
             IF pr_cdcritic in (257,287) THEN
                pr_flgentra := TRUE;
             ELSE
                pr_flgentra := FALSE;
             end if;
     end if;
      --ULTIMA VALIDAÇÃO

      IF pr_flgentra THEN
         -- Verifica se eh conta migrada 
         IF (vr_contamigrada <> 0 ) THEN
             IF pr_cdcooper = 1 AND
                rw_crapcst.nrdconta = 85448 THEN
                begin
                  update craplau
                     set craplau.dtdebito = pr_craplot.dtmvtolt,
                         craplau.cdcritic = pr_cdcritic,
                         craplau.insitlau = 3
                   where craplau.rowid = pr_craplau.rowid;
                   exception
                     when others then
                      vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;                       
                   end;
                   begin
                     update crapcst
                        set crapcst.insitchq = 4
                     where crapcst.rowid = rw_crapcst.rowid;
                     exception
                      when others then
                        vr_dscritic := 'Problema ao alterar dados crapcst '||sqlerrm;                       

                   end;
             ELSE
               -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
               vr_index := vr_tab_contas_cheque.COUNT() + 1;
               -- Criar um registro no vetor de contas cheque
               vr_tab_contas_cheque(vr_index).nrdconta := vr_nrconta;
               vr_tab_contas_cheque(vr_index).nrdctabb := pr_craplau.nrdctabb;
               vr_tab_contas_cheque(vr_index).nrdctitg := pr_craplau.nrdctitg;
               vr_tab_contas_cheque(vr_index).cdhistor := pr_craplau.cdhistor;
               vr_tab_contas_cheque(vr_index).vllanmto := pr_craplau.vllanaut;
               vr_tab_contas_cheque(vr_index).cdbanchq := rw_crapfdc.cdbanchq;
               vr_tab_contas_cheque(vr_index).cdagechq := rw_crapfdc.cdagechq;
               vr_tab_contas_cheque(vr_index).nrctachq := rw_crapfdc.nrctachq;
               vr_tab_contas_cheque(vr_index).nrdocmto := pr_craplau.nrdocmto;
               begin
                 update craplau
                    set craplau.dtdebito = pr_craplot.dtmvtolt,
                        craplau.insitlau = 2
                 where craplau.rowid = pr_craplau.rowid;
                 exception
                   when others then
                   vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;                                           
               end;
               begin
                 update crapcst
                    set crapcst.insitchq = 4
                 where crapcst.rowid = rw_crapcst.rowid;
                 exception
                   when others then
                    vr_dscritic := 'Problema ao alterar dados crapcst '||sqlerrm;                                                                

               end;
               IF pr_craplau.cdhistor = 26 THEN
                  begin
                    update crapfdc
                       set crapfdc.incheque = rw_crapfdc.incheque + 5,
                           crapfdc.dtliqchq = rw_crapdat.dtmvtopr,
                           crapfdc.vlcheque = pr_craplau.vllanaut
                    where crapfdc.rowid = rw_crapfdc.rowid;
                    exception
                      when others then
                       vr_dscritic := 'Problema ao alterar dados crapfdc '||sqlerrm;
                  end;
               ELSE
                 IF pr_craplau.cdhistor = 21 THEN
                    begin
                      update crapfdc
                         set crapfdc.incheque = rw_crapfdc.incheque + 5,
                             crapfdc.dtliqchq = rw_crapdat.dtmvtopr,
                             crapfdc.vlcheque = pr_craplau.vllanaut
                      where crapfdc.rowid = rw_crapfdc.rowid;
                      exception
                        when others then
                          vr_dscritic := 'Problema ao alterar dados crapfdc '||sqlerrm;
                    end;
                 end if;
               end if;
             end if;
        ELSE
              begin
                 insert into craplcm(
                             craplcm.dtmvtolt ,
                             craplcm.dtrefere ,
                             craplcm.cdagenci ,
                             craplcm.cdbccxlt ,
                             craplcm.nrdolote ,
                             craplcm.nrdconta ,
                             craplcm.nrdctabb ,
                             craplcm.nrdctitg ,
                             craplcm.nrdocmto ,
                             craplcm.cdhistor ,
                             craplcm.vllanmto ,
                             craplcm.nrseqdig ,
                             craplcm.cdcooper ,
                             craplcm.cdbanchq ,
                             craplcm.cdagechq ,
                             craplcm.nrctachq ,
                             craplcm.cdpesqbb )
                             values
                             ( pr_craplot.dtmvtolt
                              ,pr_craplot.dtmvtolt
                              ,pr_craplot.cdagenci
                              ,pr_craplot.cdbccxlt
                              ,pr_craplot.nrdolote
                              ,vr_nrconta
                              ,pr_craplau.nrdctabb
                              ,pr_craplau.nrdctitg
                              ,pr_craplau.nrdocmto
                              ,pr_craplau.cdhistor
                              ,pr_craplau.vllanaut
                              ,pr_craplot.nrseqdig + 1
                              ,pr_cdcooper
                              ,rw_crapfdc.cdbanchq
                              ,rw_crapfdc.cdagechq
                              ,rw_crapfdc.nrctachq
                              ,to_char(pr_craplau.dtmvtolt,'DD/MM/RRRR')||'-' ||
                               TO_CHAR(pr_craplau.cdagenci,'999')       ||'-' ||
                               TO_CHAR(pr_craplau.cdbccxlt,'999')       ||'-' ||
                               TO_CHAR(pr_craplau.nrdolote,'999999')    ||'-' ||
                               to_char(pr_craplau.nrseqdig,'99999'));
                     exception
                        when others then
                          BEGIN
                           update craplcm
                              set craplcm.vllanmto = pr_craplau.vllanaut
                              where CDCOOPER = pr_cdcooper
                                and DTMVTOLT = pr_craplot.dtmvtolt
                                and CDAGENCI = pr_craplau.cdagenci
                                and CDBCCXLT = pr_craplau.cdbccxlt
                                and NRDOLOTE = pr_craplot.nrdolote
                                and NRSEQDIG = pr_craplot.nrseqdig + 1;

                          END;                   --  CHQ. OK - prg. 287~  
              end;
              begin
                    update  craplot
                    set craplot.qtinfoln = pr_craplot.qtinfoln + 1,
                        craplot.qtcompln = pr_craplot.qtcompln + 1,
                        craplot.vlinfodb = pr_craplot.vlinfodb + pr_craplau.vllanaut,
                        craplot.vlcompdb = pr_craplot.vlcompdb + pr_craplau.vllanaut
                        where craplot.rowid = pr_CRAPLOT.Rowid;


                    exception
                      when others then
                       vr_dscritic := 'Problema ao alterar dados craplot '||sqlerrm;                        
                  end;

                    begin
                      update crapcst
                        set crapcst.insitchq = 4
                        where crapcst.rowid = rw_crapcst.rowid;

                      exception
                        when others then
                       vr_dscritic := 'Problema ao alterar dados crapcst '||sqlerrm;
                    end;
                      IF   pr_craplau.cdhistor = 26   THEN
                         begin
                          update crapfdc
                             set crapfdc.incheque  = rw_crapfdc.incheque + 5,
                                  crapfdc.dtliqchq = rw_crapdat.dtmvtopr,
                                  crapfdc.vlcheque = pr_craplau.vllanaut
                             where crapfdc.rowid = rw_crapfdc.rowid;
                          exception
                            when others then
                            vr_dscritic := 'Problema ao alterar dados crapfdc '||sqlerrm;                              
                         end;
                      ELSE
                        IF   pr_craplau.cdhistor = 21 THEN
                             begin
                              update crapfdc
                                 set crapfdc.incheque  = rw_crapfdc.incheque + 5,
                                      crapfdc.dtliqchq = rw_crapdat.dtmvtopr,
                                      crapfdc.vlcheque = pr_craplau.vllanaut
                                 where crapfdc.rowid = rw_crapfdc.rowid;
                              exception
                                when others then
                                  vr_dscritic := 'Problema ao alterar dados crapfdc '||sqlerrm;
                             end;
                        END if;
                      end if;
             end if;

      ELSE
        BEGIN
          update craplau
            set craplau.insitlau = 3,
                craplau.dtdebito = pr_craplot.dtmvtolt
                ,craplau.cdcritic = pr_cdcritic
                where craplau.rowid = pr_craplau.rowid;
          exception
            when others then
              vr_dscritic := 'Problema ao inserir dados craplau '||sqlerrm;
        end;
      end if;
  

  

      end pc_trata_custodia;
      PROCEDURE pc_trata_titulo(vr_cdcooper in number, pr_craplau cr_craplau%ROWTYPE,
                                   pr_craplot cr_crablot%rowtype) is
      -- variaveis 
       pr_dtmvtolt date;
       pr_cdagenci number;
       pr_cdbccxlt number;
       pr_nrdolote number;
       pr_dscodbar number;

       


       CURSOR CR_CRAPLOT01 (PR_CDCOOPER CRAPLOT.CDCOOPER%TYPE,
                           pr_dtmvtopr CRAPLOT.DTMVTOLT%TYPE)IS

        select CRAPLOT.ROWID, CRAPLOT.* from craplot WHERE craplot.cdcooper = pr_cdcooper   AND
                          craplot.dtmvtolt = pr_dtmvtopr   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = 4600;

       RW_CRAPLOT Cr_CRAPLOT01%ROWTYPE;

       cursor cr_craptit (pr_cdcooper craptit.cdcooper%type,
                          pr_dtmvtolt craptit.dtmvtolt%type,
                          pr_cdagenci craptit.cdagenci%type,
                          pr_cdbccxlt craptit.cdbccxlt%type,
                          pr_nrdolote craptit.nrdolote%type,
                          pr_dscodbar craptit.dscodbar%type) is
       select craptit.rowid,  craptit.* from  craptit
                    WHERE craptit.cdcooper = pr_cdcooper   AND
                          craptit.dtmvtolt = pr_dtmvtolt   AND
                          craptit.cdagenci = pr_cdagenci   AND
                          craptit.cdbccxlt = pr_cdbccxlt   AND
                          craptit.nrdolote = pr_nrdolote   AND
                          craptit.dscodbar = pr_dscodbar;

       RW_CRAPTIT cr_craptit%ROWTYPE;





       begin
       pr_dtmvtolt := TO_DATE(SUBSTR(pr_craplau.cdseqtel,4,2)||'/'||
                               SUBSTR(pr_craplau.cdseqtel,1,2)||'/'||
                               SUBSTR(pr_craplau.cdseqtel,7,4),'DD/MM/RRRR');

        pr_cdagenci := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,12,3));
        pr_cdbccxlt := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,16,3));
        pr_nrdolote := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,20,6));
        pr_dscodbar := TO_NUMBER(SUBSTR(pr_craplau.cdseqtel,27,44));


        OPEN CR_CRAPLOT01(vr_cdcooper,
                          rw_crapdat.dtmvtopr);
        FETCH CR_CRAPLOT01
        INTO RW_CRAPLOT;

        IF CR_CRAPLOT01%NOTFOUND THEN
             begin
              insert into craplot
                   (craplot.dtmvtolt,
                    craplot.cdagenci,
                    craplot.cdbccxlt,
                    craplot.nrdolote,
                    craplot.tplotmov,
                    craplot.cdcooper)
                    values
                    (rw_crapdat.dtmvtopr
                     ,1
                     ,100
                     ,4600
                     ,1
                     ,pr_cdcooper);
               exception
                 when others then
                   vr_dscritic := 'Problema ao inserir dados craplot '||sqlerrm;
             end;
          CLOSE CR_CRAPLOT01;
        END IF;
           

        OPEN CR_CRAPTIT(pr_cdcooper,
                        pr_dtmvtolt,
                        pr_cdagenci,
                        pr_cdbccxlt,
                        pr_nrdolote,
                        pr_dscodbar);
        FETCH CR_CRAPTIT
        INTO RW_CRAPTIT;
        IF CR_CRAPTIT%NOTFOUND THEN
           PR_cdcritic     := 681;
           BEGIN
             UPDATE craplau
               SET craplau.insitlau = 3
                  ,craplau.dtdebito = RW_craplot.dtmvtolt
                  ,craplau.cdcritic = PR_cdcritic
             WHERE craplau.ROWID = pr_craplau.ROWID;
           EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;

           END;

            begin
                insert into craprej
                           (craprej.dtmvtolt,
                            craprej.cdagenci,
                            craprej.cdbccxlt,
                            craprej.nrdolote,
                            craprej.tplotmov,
                            craprej.cdhistor,
                            craprej.nraplica,
                            craprej.nrdconta,
                            craprej.nrdctabb,
                            craprej.nrdctitg,
                            craprej.nrseqdig,
                            craprej.nrdocmto,
                            craprej.vllanmto,
                            craprej.cdpesqbb,
                            craprej.cdcritic,
                            craprej.tpintegr,
                            craprej.cdcooper)
                            values
                            (
                            vr_dtmvtolt,
                            vr_cdagenci,
                            vr_cdbccxlt,
                            vr_nrdolote,
                            vr_tplotmov,
                            pr_craplau.cdhistor,
                            vr_nrcustod,
                            pr_craplau.nrdconta,
                            pr_craplau.nrdctabb,
                            pr_craplau.nrdctitg,
                            pr_craplau.nrseqdig,
                            pr_craplau.nrdocmto,
                            pr_craplau.vllanaut,
                            pr_craplau.cdseqtel,
                            vr_cdcritic,
                            pr_craplot.tplotmov,
                            pr_cdcooper
                            );
            exception
              when others then
                vr_dscritic := 'Problema ao inserir dados craprej '||sqlerrm;
            end;
           CLOSE CR_CRAPTIT;
        END IF;
        begin
         insert into craplcm
            (
            craplcm.dtmvtolt,
            craplcm.cdagenci,
            craplcm.cdbccxlt,
            craplcm.nrdolote,
            craplcm.nrdconta,
            craplcm.nrdctabb,
            craplcm.nrdctitg,
            craplcm.nrdocmto,
            craplcm.cdhistor,
            craplcm.vllanmto,
            craplcm.nrseqdig,
            craplcm.cdcooper,
            craplcm.cdpesqbb)
            values
            (
            rw_craplot.dtmvtolt,
            rw_craplot.cdagenci,
            rw_craplot.cdbccxlt,
            rw_craplot.nrdolote,
            pr_craplau.nrdconta,
            pr_craplau.nrdconta,
            to_char(pr_craplau.nrdconta,'99999999'),
            pr_craplau.nrdocmto,
            pr_craplau.cdhistor,
            pr_craplau.vllanaut,
            pr_craplot.nrseqdig + 1,
            pr_cdcooper,
            to_char(pr_craplau.dtmvtolt,'99/99/9999') || '-' || to_char(pr_craplau.cdagenci,'999') || '-' || to_char(pr_craplau.cdbccxlt,'999')|| '-' || to_char(pr_craplau.nrdolote,'999999') || '-' || to_char(pr_craplau.nrseqdig,'99999'));
        exception
           when others then
            update craplcm
              set craplcm.nrdconta = pr_craplau.nrdconta,
                  craplcm.nrdctabb = pr_craplau.nrdconta,
                  craplcm.nrdctitg = to_char(pr_craplau.nrdconta,'99999999'),
                  craplcm.nrdocmto = pr_craplau.nrdocmto,
                  craplcm.cdhistor = pr_craplau.cdhistor,
                  craplcm.vllanmto = pr_craplau.vllanaut

              where CDCOOPER = pr_cdcooper
                and DTMVTOLT = rw_craplot.dtmvtolt
                and CDAGENCI = rw_craplot.cdagenci
                and CDBCCXLT = rw_craplot.cdbccxlt
                and NRDOLOTE = rw_craplot.nrdolote
                and NRSEQDIG = pr_craplot.nrseqdig + 1;
        end;

        begin
          update  craplot
          set craplot.qtinfoln = rw_craplot.qtinfoln + 1,
             craplot.qtcompln = rw_craplot.qtcompln + 1,
             craplot.vlinfodb = rw_craplot.vlinfodb + pr_craplau.vllanaut,
             craplot.vlcompdb = rw_craplot.vlcompdb + pr_craplau.vllanaut,
             craplot.nrseqdig = pr_craplot.nrseqdig + 1
              where craplot.rowid = RW_CRAPLOT.Rowid;

          exception
            when others then
              vr_dscritic := 'Problema ao alterar dados craplot '||sqlerrm;
        end;

        begin
          update craplau
            set craplau.dtdebito = rw_craplot.dtmvtolt,
                craplau.insitlau = 2
            where craplau.rowid = pr_craplau.rowid;
          exception
            when others then
              vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
        end;

        begin
          update craptit
            set craptit.insittit = 2
            where craptit.rowid = RW_CRAPTIT.Rowid;
          exception
            when others then
              vr_dscritic := 'Problema ao inserir dados craptit '||sqlerrm;
        end;

      end pc_trata_titulo;
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
    vr_dtmvtolt := TO_CHAR(to_date(rw_crapdat.dtmvtolt,'mm/dd/rrrr'),'DD/MM/RRRR');

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
    -- buscar lotes
   vr_idx := 0;
    FOR rw_crablot IN cr_crablot (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                  pr_dtmvtopr => rw_crapdat.dtmvtopr)LOOP

      FOR rw_craplau in cr_craplau(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdagenci => rw_crablot.cdagenci,
                                   pr_cdbccxlt => rw_crablot.cdbccxlt,
                                   pr_nrdolote => rw_crablot.nrdolote) loop


         IF cr_crapass%isopen THEN
           Close cr_crapass;
         END IF;
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrconta => rw_craplau.nrdconta);
          FETCH cr_crapass
          INTO rw_crapass;
            if cr_crapass%NOTFOUND THEN
               CLOSE cr_crapass;
            END IF;

               vr_dtmvtolt   := null;
               vr_cdagenci   := 0;
               vr_cdbccxlt   := 0;
               vr_nrdolote   := 0;
               vr_tplotmov   := 0;
               IF rw_crablot.tplotmov = 19 THEN
                    vr_nrdolote := 4500;
               ELSE
                    vr_nrdolote := 4600;

               end if;
               for rw_craplot in cr_craplot1(pr_cdcooper => pr_cdcooper,
                                            pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                            pr_nrdolote => vr_nrdolote) loop




                    begin

                           insert into CRAPLOT
                              (dtmvtolt,
                               cdagenci,
                               cdbccxlt,
                               nrdolote,
                               tplotmov,
                               cdcooper)
                               values
                               (rw_crapdat.dtmvtopr,
                                1, --cdagencia
                                100, -- cdbccxlt
                                vr_nrdolote,
                                1,
                                pr_cdcooper);
                           exception
                             when others then
                                update CRAPLOT
                                 set tplotmov = 1
                                   where CRAPLOT.rowid = rw_CRAPLOT.rowid;
                        end;

                        begin
                          update craplau
                            set
                            craplau.insitlau = 3
                           ,craplau.dtdebito = rw_crapdat.dtmvtopr
                           ,craplau.cdcritic = pr_cdcritic
                          where rowid = rw_craplau.rowid;
                        exception
                          when others then
                            vr_dscritic := 'Problema ao alterar dados craplau '||sqlerrm;
                        end;
                        VR_nrcustod := 0;
                        vr_dtmvtolt := rw_craplot.dtmvtolt;
                        vr_cdagenci := rw_craplot.cdagenci;
                        vr_cdbccxlt := rw_craplot.cdbccxlt;
                        vr_nrdolote := rw_craplot.nrdolote;
                        vr_tplotmov := rw_craplot.tplotmov;
                        begin
                          insert into craprej
                           (craprej.dtmvtolt,
                            craprej.cdagenci,
                            craprej.cdbccxlt,
                            craprej.nrdolote,
                            craprej.tplotmov,
                            craprej.cdhistor,
                            craprej.nraplica,
                            craprej.nrdconta,
                            craprej.nrdctabb,
                            craprej.nrdctitg,
                            craprej.nrseqdig,
                            craprej.nrdocmto,
                            craprej.vllanmto,
                            craprej.cdpesqbb,
                            craprej.cdcritic,
                            craprej.tpintegr,
                            craprej.cdcooper)
                            values
                            (
                            vr_dtmvtolt,
                            vr_cdagenci,
                            vr_cdbccxlt,
                            vr_nrdolote,
                            vr_tplotmov,
                            rw_craplau.cdhistor,
                            vr_nrcustod,
                            rw_craplau.nrdconta,
                            rw_craplau.nrdctabb,
                            rw_craplau.nrdctitg,
                            rw_craplau.nrseqdig,
                            rw_craplau.nrdocmto,
                            rw_craplau.vllanaut,
                            rw_craplau.cdseqtel,
                            vr_cdcritic,
                            rw_crablot.tplotmov,
                            pr_cdcooper
                            );
                    exception
                      when others then
                       vr_dscritic := 'Problema ao inserir dados craprej '||sqlerrm; 
                    end;
              end loop; -- rw_craplot


        IF  rw_crablot.tplotmov = 19   THEN
             pc_trata_custodia(pr_cdcooper,rw_craplau, rw_crablot);
        ELSIF rw_crablot.tplotmov = 20   THEN
             pc_trata_titulo(pr_cdcooper,rw_craplau, rw_crablot);
        END IF;


      END LOOP;
    END LOOP;    --Fim loop crablot
    vr_idx := 0;
    FOR vr_idx IN 1 .. vr_tab_contas_cheque.COUNT LOOP
      pc_processamento_tco;
    END LOOP;
        -- Geração Relatorio crrl626 
        -- Inicializar o CLOB
         select count(*) into vr_valor from craplot
            WHERE craplot.cdcooper = pr_cdcooper   AND
                  craplot.dtmvtolt = rw_crapdat.dtmvtopr   AND
                 (craplot.nrdolote = 4500           OR
                  craplot.nrdolote = 4600);
    
    if vr_valor >= 1 then
                      
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl238>');

       
     --Cabeçalho Relatório 
     FOR rw_relat IN cr_craplotrl(pr_cdcooper,
                                rw_crapdat.dtmvtopr) LOOP

           vr_rel_qtdifeln := rw_relat.qtcompln ;
           vr_rel_vldifedb := rw_relat.vlcompdb ;
           vr_rel_vldifecr := rw_relat.vlcompcr ;
             IF rw_relat.nrdolote = 4500 THEN
               vr_rel_dsintegr := 'CHEQUES EM CUSTODIA ' || upper(rw_crapcop.nmrescop);
             ELSE
               vr_rel_dsintegr := 'TITULOS COMPENSAVEIS';
             end if;
             pr_regexist := TRUE;

       FOR rw_corpo_rel in cr_corpo_rel(pr_cdcooper,
                                       rw_crapdat.dtmvtopr,
                                       rw_relat.cdagenci,
                                       rw_relat.cdbccxlt,
                                       rw_relat.nrdolote)loop

                vr_cdcritic :=  rw_corpo_rel.cdcritic;
                   begin
                       select crapcri.dscritic
                              into
                               vr_dscritic
                               from crapcri
                        where crapcri.cdcritic = vr_cdcritic;
                      exception
                         when others then
                          vr_dscritic := null;
                     end;


                 IF rw_corpo_rel.cdcritic  in (257,287) THEN
                    vr_dscritic := '* ' || vr_dscritic;
                 end if;

             IF rw_corpo_rel.tpintegr = 19   THEN
                vr_rel_dshistor := TO_CHAR(gene0002.fn_mask(rw_corpo_rel.nraplica,'zzz.zzz.9')) ||
                                ' ==> ' || TRIM(rw_corpo_rel.cdpesqbb) || '    ' ||
                                to_char(rw_corpo_rel.vllanmto,'fm999G999G999G999G990d00') ||
                                ' --> ' || vr_dscritic;
             ELSIF rw_corpo_rel.tpintegr = 20   THEN
                   vr_rel_dshistor := TRIM(rw_corpo_rel.cdpesqbb) || '    ' ||
                                to_char(rw_corpo_rel.vllanmto,'fm999G999G999G999G990d00') ||
                                ' --> ' || vr_dscritic;
             ELSE
                   vr_rel_dshistor := TRIM(rw_corpo_rel.cdpesqbb) || '    ' ||
                                to_char(rw_corpo_rel.vllanmto,'fm999G999G999G999G990d00') ||
                                ' --> ' || vr_dscritic;
             END IF;

          pc_escreve_xml('<rejeitados>
                          <reldspesqbb>'|| vr_rel_dsintegr                          ||'</reldspesqbb>
                          <dtmvtolt>'   || to_char(rw_relat.dtmvtolt,'DD/MM/RRRR')  ||'</dtmvtolt>
                          <cdagenci>'   || rw_relat.cdagenci                        ||'</cdagenci>
                          <cdbccxlt>'   || rw_relat.cdbccxlt                        ||'</cdbccxlt>
                          <nrdolote>'   || rw_relat.nrdolote                        ||'</nrdolote>
                          <tplotmov>'   || rw_relat.tplotmov                        ||'</tplotmov>
                          <dtmvtopg>'   || to_char(rw_relat.dtmvtopg,'DD/MM/RRRR')  ||'</dtmvtopg>
                          <resgate>RESGATAR OS SEGUINTES CHEQUES/TITULOS</resgate>
                          <corte>------------------------------------------------------------------------------------------------------------------------------------</corte>
                          <cdpesqbb>'   || rw_corpo_rel.cdpesqbb                    ||'</cdpesqbb>
                          <dshistor>'   || vr_rel_dshistor                         ||'</dshistor>
                          <rel_qtdifeln>'|| vr_rel_qtdifeln                        ||'</rel_qtdifeln>
                          <rel_vldifedb>'|| to_char(vr_rel_vldifedb,'fm999G999G999G999G990d00')||'</rel_vldifedb>
                          <rel_vldifecr>'|| to_char(vr_rel_vldifecr,'fm999G999G999G999G990d00') ||'</rel_vldifecr>
                          <vlinfodb>'|| to_char(rw_relat.vlinfodb,'fm999G999G999G999G990d00') ||'</vlinfodb>
                          <vlinfocr>'|| to_char(rw_relat.vlinfocr,'fm999G999G999G999G990d00') ||'</vlinfocr>
                          <qtinfoln>'|| rw_relat.qtinfoln                                     ||'</qtinfoln>
                          <tqtd>'    || (vr_rel_qtdifeln - rw_relat.qtinfoln)                  ||'</tqtd>
                          <tdb>'    ||  to_char((vr_rel_vldifedb - rw_relat.vlinfodb),'fm999G999G999G999G990d00') ||'</tdb>
                          <tcr>'    ||  to_char((vr_rel_vldifecr - rw_relat.vlinfocr),'fm999G999G999G999G990d00') ||'</tcr>
                      </rejeitados>');


       end loop;
       if (vr_rel_dshistor is null) then
         pc_escreve_xml('<rejeitados>
                          <reldspesqbb>'|| vr_rel_dsintegr                            ||'</reldspesqbb>
                          <dtmvtolt>'   || to_char(rw_relat.dtmvtolt,'DD/MM/RRRR')  ||'</dtmvtolt>
                          <cdagenci>'   || rw_relat.cdagenci                        ||'</cdagenci>
                          <cdbccxlt>'   || rw_relat.cdbccxlt                        ||'</cdbccxlt>
                          <nrdolote>'   || rw_relat.nrdolote                        ||'</nrdolote>
                          <tplotmov>'   || rw_relat.tplotmov                        ||'</tplotmov>
                          <dtmvtopg>'   || to_char(rw_relat.dtmvtopg,'DD/MM/RRRR')  ||'</dtmvtopg>
                          <resgate></resgate>
                          <corte></corte>
                          <cdpesqbb>''</cdpesqbb>
                          <dshistor>'   || vr_rel_dshistor                          ||'</dshistor>
                          <rel_qtdifeln>'|| vr_rel_qtdifeln                            ||'</rel_qtdifeln>
                          <rel_vldifedb>'|| to_char(vr_rel_vldifedb,'fm999G999G999G999G990d00')||'</rel_vldifedb>
                          <rel_vldifecr>'|| to_char(vr_rel_vldifecr,'fm999G999G999G999G990d00') ||'</rel_vldifecr>
                          <vlinfodb>'|| to_char(rw_relat.vlinfodb,'fm999G999G999G999G990d00') ||'</vlinfodb>
                          <vlinfocr>'|| to_char(rw_relat.vlinfocr,'fm999G999G999G999G990d00') ||'</vlinfocr>
                          <qtinfoln>'|| rw_relat.qtinfoln                                     ||'</qtinfoln>
                          <tqtd>'    || (vr_rel_qtdifeln - rw_relat.qtinfoln)                  ||'</tqtd>
                          <tdb>'    ||  to_char((vr_rel_vldifedb - rw_relat.vlinfodb),'fm999G999G999G999G990d00') ||'</tdb>
                          <tcr>'    ||  to_char((vr_rel_vldifecr - rw_relat.vlinfocr),'fm999G999G999G999G990d00') ||'</tcr>
                      </rejeitados>');
       end if;

    END LOOP;

     pc_escreve_xml('</crrl238>');
     ----------------- gerar relatório -----------------
           -- Busca do diretório base da cooperativa para PDF
           vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Efetuar solicitação de geração de relatório --

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl238/rejeitados'    --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl238.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Sem parametros
                                      ,pr_dsarqsaid => vr_caminho_integra||'/crrl238.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Saída com erro

    end if;
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
 --   COMMIT;

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

  END pc_crps290;
/
