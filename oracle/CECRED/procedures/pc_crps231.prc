CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps231 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps231 (Fontes/crps231.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Julho/98.                          Ultima atualizacao: 26/05/2014

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 59.
                   Gera disquete para Receita.
                   Relatorio 186,188.
                   Solicitacao 59.
                   Ordem 1.

       Alteracoes: 19/07/1999 - Alterado para chamar a rotina de impressao (Edson).

                   12/01/2000 - Nao solicitar a gravacao em disquete (Deborah).

                   29/02/2000 - Adequar as novas instrucoes da receira
                                num. 12 de 02/02/2000 (Odair)

                   27/03/2000 - Tratar DOC C (Odair)

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   11/12/2007 - Incluidos valores do INSS - BANCOOB (Evandro).

                   26/05/2014 - Conversão Progress >> Oracle (Edison - AMcom)

    ............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS231';

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
              ,cop.nrdocnpj
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.nrcepend
              ,cop.nrcxapst
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --avalia os periodos de apuracao da CPFM
      CURSOR cr_crapper ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtinicpm IN DATE
                         ,pr_dtfimcpm IN DATE) IS
        SELECT crapper.dtiniper
              ,crapper.dtfimper
              ,crapper.vlbaschq##1
              ,crapper.vlbaschq##2
              ,crapper.vlretbas##1
              ,crapper.vlretbas##2
              ,crapper.vlpgtaut##1
              ,crapper.vlpgtaut##2
              ,crapper.vlretpgt##1
              ,crapper.vlretpgt##2
              ,crapper.vlopecrd##1
              ,crapper.vlopecrd##2
              ,crapper.vlretope##1
              ,crapper.vlretope##2
              ,crapper.vlaplfin##1
              ,crapper.vlaplfin##2
              ,crapper.vlretapl##1
              ,crapper.vlretapl##2
              ,crapper.vloutdeb##1
              ,crapper.vloutdeb##2
              ,crapper.vlretout##1
              ,crapper.vlretout##2
              ,crapper.vlbascsd##1
              ,crapper.vlbascsd##2
              ,crapper.vlretcsd##1
              ,crapper.vlretcsd##2
              ,crapper.vlsaqmgn##1
              ,crapper.vlsaqmgn##2
              ,crapper.vlretsaq##1
              ,crapper.vlretsaq##2
              ,crapper.vldccdeb##1
              ,crapper.vldccdeb##2
              ,crapper.vlretdcc##1
              ,crapper.vlretdcc##2
              ,crapper.vloutcop
              ,crapper.vltrfmtl
              ,crapper.vlestcri
              ,crapper.vldebntr
              ,crapper.vldspcco
              ,crapper.vlretdsp
              ,crapper.vlinvcco
              ,crapper.vlretinv
              ,crapper.vlimocco
              ,crapper.vlretimo
              ,crapper.vltrbcco
              ,crapper.vlrettrb
              ,crapper.vlcpmcps
              ,crapper.vlrbscps
              ,crapper.vlrcpcps
        FROM  crapper
        WHERE crapper.cdcooper =  pr_cdcooper
        AND   crapper.dtfimper >  pr_dtinicpm
        AND   crapper.dtfimper <= pr_dtfimcpm;

      /* Lancamentos do INSS - BANCOOB */
      CURSOR cr_craplpi ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtinicpm IN DATE
                         ,pr_dtfimcpm IN DATE) IS
        SELECT craplpi.vllanmto
              ,craplpi.vldoipmf
        FROM   craplpi
        WHERE craplpi.cdcooper  = pr_cdcooper
        AND   craplpi.dtmvtolt  > pr_dtinicpm
        AND   craplpi.dtmvtolt <= pr_dtfimcpm;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      --array de 2 posições
      vr_vlaplfin     dbms_sql.Number_Table;
      vr_vlbaschq     dbms_sql.Number_Table;
      vr_vlretchq     dbms_sql.Number_Table;
      vr_vlbascsd     dbms_sql.Number_Table;
      vr_vlopecrd     dbms_sql.Number_Table;
      vr_vloutdeb     dbms_sql.Number_Table;
      vr_vlpgtaut     dbms_sql.Number_Table;
      vr_vlsaqmgn     dbms_sql.Number_Table;
      vr_vldccdeb     dbms_sql.Number_Table;
      vr_vlretapl     dbms_sql.Number_Table;
      vr_vlretcsd     dbms_sql.Number_Table;
      vr_vlretope     dbms_sql.Number_Table;
      vr_vlretout     dbms_sql.Number_Table;
      vr_vlretpgt     dbms_sql.Number_Table;
      vr_vlretsaq     dbms_sql.Number_Table;
      vr_vlretdcc     dbms_sql.Number_Table;

      vr_dsmesref     VARCHAR2(100);
      vr_dtfimcpm     DATE;
      vr_dtinicpm     DATE;
      vr_rfmesano     VARCHAR2(100);
      vr_flgfirst     BOOLEAN;
      vr_dtiniper     DATE;
      vr_dtfimper     DATE;
      vr_nmarquiv     VARCHAR2(100);

      vr_vlrcpcps     NUMBER;
      vr_vlrbscps     NUMBER;
      vr_vloutcop     NUMBER;
      vr_vltrfmtl     NUMBER;
      vr_vlretinv     NUMBER;
      vr_vlretimo     NUMBER;
      vr_vlretdsp     NUMBER;
      vr_vlinvcco     NUMBER;
      vr_vlimocco     NUMBER;
      vr_vlestcri     NUMBER;
      vr_vldspcco     NUMBER;
      vr_vldebntr     NUMBER;
      vr_vltrbcco     NUMBER;
      vr_vlrettrb     NUMBER;
      vr_vlcpmcps     NUMBER;
      vr_tot_vlpesfis NUMBER;
      vr_tot_vlretfis NUMBER;
      vr_tot_vlpesjur NUMBER;
      vr_tot_vlretjur NUMBER;
      vr_ger_vlasscpm NUMBER;
      vr_ger_vlretass NUMBER;
      vr_tot_vlcpmncb NUMBER;
      vr_tot_vlcooper NUMBER;
      vr_tot_vlretcoo NUMBER;

      vr_tot_vlapurad NUMBER;
      vr_tot_vlcpmapu NUMBER;
      vr_ger_vlcpmcal NUMBER;
      vr_rel_dsperiod VARCHAR2(100);

      vr_nmextcop     VARCHAR2(100);
      vr_nrdocnpj     NUMBER;
      vr_dsendcop     VARCHAR2(100);
      vr_nrendcop     INTEGER;
      vr_dscomple     VARCHAR2(100);
      vr_nmbairro     VARCHAR2(100);
      vr_nmcidade     VARCHAR2(100);
      vr_cdufdcop     VARCHAR2(100);
      vr_nrcepend     INTEGER;
      vr_nrcxapst     INTEGER;
      vr_vlordpgt     NUMBER;
      vr_vlordret     NUMBER;
      vr_dsdircop     VARCHAR2(500);
      vr_dsdirarq     VARCHAR2(500);
      vr_dscomando    VARCHAR2(500);
      vr_typ_saida    VARCHAR2(3);

      -- Variaveis de controle xml
      vr_xml              CLOB;
      vr_xml_2            CLOB;
      vr_texto_completo   VARCHAR2(32767);
      vr_texto_completo_2 VARCHAR2(32767);
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

      --ultimo dia do mes anterior a data de movimento
      vr_dtfimcpm := TRUNC(rw_crapdat.dtmvtolt,'MONTH')-1;
      --ultimo dia do mes
      vr_dtinicpm := TRUNC(vr_dtfimcpm,'MONTH')-1;
      vr_rfmesano := TO_CHAR(vr_dtfimcpm,'MMYYYY');
      vr_dsmesref := TO_CHAR(vr_dtfimcpm,'MM/YYYY');
      vr_flgfirst := TRUE;

      --inicializando os arrays
      FOR vr_indice IN 1 .. 2 LOOP
        vr_vlaplfin(vr_indice) := 0;
        vr_vlbaschq(vr_indice) := 0;
        vr_vlretchq(vr_indice) := 0;
        vr_vlbascsd(vr_indice) := 0;
        vr_vlopecrd(vr_indice) := 0;
        vr_vloutdeb(vr_indice) := 0;
        vr_vlpgtaut(vr_indice) := 0;
        vr_vlsaqmgn(vr_indice) := 0;
        vr_vldccdeb(vr_indice) := 0;
        vr_vlretapl(vr_indice) := 0;
        vr_vlretcsd(vr_indice) := 0;
        vr_vlretope(vr_indice) := 0;
        vr_vlretout(vr_indice) := 0;
        vr_vlretpgt(vr_indice) := 0;
        vr_vlretsaq(vr_indice) := 0;
        vr_vlretdcc(vr_indice) := 0;
      END LOOP;

      --calculando a cpmf do periodo
      FOR rw_crapper IN cr_crapper( pr_cdcooper => pr_cdcooper
                                   ,pr_dtinicpm => vr_dtinicpm
                                   ,pr_dtfimcpm => vr_dtfimcpm)
      LOOP
        --alimenta as variaveis de controle no primeiro laco do loop
        IF vr_flgfirst THEN
          vr_dtiniper := rw_crapper.dtiniper;
          vr_flgfirst := FALSE;
        END IF;

        vr_rel_dsperiod := TO_CHAR(vr_dtiniper,'DD/MM/YYYY')||' A '||TO_CHAR(rw_crapper.dtfimper,'DD/MM/YYYY');
        vr_dtfimper    := rw_crapper.dtfimper;
        vr_vlbaschq(1) := vr_vlbaschq(1) + rw_crapper.vlbaschq##1;
        vr_vlbaschq(2) := vr_vlbaschq(2) + rw_crapper.vlbaschq##2;

        vr_vlretchq(1) := vr_vlretchq(1) + rw_crapper.vlretbas##1;
        vr_vlretchq(2) := vr_vlretchq(2) + rw_crapper.vlretbas##2;
        vr_vlpgtaut(1) := vr_vlpgtaut(1) + rw_crapper.vlpgtaut##1;
        vr_vlpgtaut(2) := vr_vlpgtaut(2) + rw_crapper.vlpgtaut##2;
        vr_vlretpgt(1) := vr_vlretpgt(1) + rw_crapper.vlretpgt##1;
        vr_vlretpgt(2) := vr_vlretpgt(2) + rw_crapper.vlretpgt##2;
        vr_vlopecrd(1) := vr_vlopecrd(1) + rw_crapper.vlopecrd##1;
        vr_vlopecrd(2) := vr_vlopecrd(2) + rw_crapper.vlopecrd##2;
        vr_vlretope(1) := vr_vlretope(1) + rw_crapper.vlretope##1;
        vr_vlretope(2) := vr_vlretope(2) + rw_crapper.vlretope##2;
        vr_vlaplfin(1) := vr_vlaplfin(1) + rw_crapper.vlaplfin##1;
        vr_vlaplfin(2) := vr_vlaplfin(2) + rw_crapper.vlaplfin##2;
        vr_vlretapl(1) := vr_vlretapl(1) + rw_crapper.vlretapl##1;
        vr_vlretapl(2) := vr_vlretapl(2) + rw_crapper.vlretapl##2;
        vr_vloutdeb(1) := vr_vloutdeb(1) + rw_crapper.vloutdeb##1;
        vr_vloutdeb(2) := vr_vloutdeb(2) + rw_crapper.vloutdeb##2;
        vr_vlretout(1) := vr_vlretout(1) + rw_crapper.vlretout##1;
        vr_vlretout(2) := vr_vlretout(2) + rw_crapper.vlretout##2;
        vr_vlbascsd(1) := vr_vlbascsd(1) + rw_crapper.vlbascsd##1;
        vr_vlbascsd(2) := vr_vlbascsd(2) + rw_crapper.vlbascsd##2;
        vr_vlretcsd(1) := vr_vlretcsd(1) + rw_crapper.vlretcsd##1;
        vr_vlretcsd(2) := vr_vlretcsd(2) + rw_crapper.vlretcsd##2;
        vr_vlsaqmgn(1) := vr_vlsaqmgn(1) + rw_crapper.vlsaqmgn##1;
        vr_vlsaqmgn(2) := vr_vlsaqmgn(2) + rw_crapper.vlsaqmgn##2;
        vr_vlretsaq(1) := vr_vlretsaq(1) + rw_crapper.vlretsaq##1;
        vr_vlretsaq(2) := vr_vlretsaq(2) + rw_crapper.vlretsaq##2;
        vr_vldccdeb(1) := vr_vldccdeb(1) + rw_crapper.vldccdeb##1;
        vr_vldccdeb(2) := vr_vldccdeb(2) + rw_crapper.vldccdeb##2;
        vr_vlretdcc(1) := vr_vlretdcc(1) + rw_crapper.vlretdcc##1;
        vr_vlretdcc(2) := vr_vlretdcc(2) + rw_crapper.vlretdcc##2;

        vr_vloutcop := nvl(vr_vloutcop,0) + rw_crapper.vloutcop;
        vr_vltrfmtl := nvl(vr_vltrfmtl,0) + rw_crapper.vltrfmtl;
        vr_vlestcri := nvl(vr_vlestcri,0) + rw_crapper.vlestcri;
        vr_vldebntr := nvl(vr_vldebntr,0) + rw_crapper.vldebntr;
        vr_vldspcco := nvl(vr_vldspcco,0) + rw_crapper.vldspcco;
        vr_vlretdsp := nvl(vr_vlretdsp,0) + rw_crapper.vlretdsp;
        vr_vlinvcco := nvl(vr_vlinvcco,0) + rw_crapper.vlinvcco;
        vr_vlretinv := nvl(vr_vlretinv,0) + rw_crapper.vlretinv;
        vr_vlimocco := nvl(vr_vlimocco,0) + rw_crapper.vlimocco;
        vr_vlretimo := nvl(vr_vlretimo,0) + rw_crapper.vlretimo;
        vr_vltrbcco := nvl(vr_vltrbcco,0) + rw_crapper.vltrbcco;
        vr_vlrettrb := nvl(vr_vlrettrb,0) + rw_crapper.vlrettrb;
        vr_vlcpmcps := nvl(vr_vlcpmcps,0) + rw_crapper.vlcpmcps;
        vr_vlrbscps := nvl(vr_vlrbscps,0) + (rw_crapper.vlrbscps * -1);
        vr_vlrcpcps := nvl(vr_vlrcpcps,0) + (rw_crapper.vlrcpcps * -1);
      END LOOP;

      /* Lancamentos do INSS - BANCOOB */
      FOR rw_craplpi IN cr_craplpi( pr_cdcooper => pr_cdcooper
                                   ,pr_dtinicpm => vr_dtinicpm
                                   ,pr_dtfimcpm => vr_dtfimcpm)
      LOOP
        vr_vlordpgt := nvl(vr_vlordpgt,0) + rw_craplpi.vllanmto;
        vr_vlordret := nvl(vr_vlordret,0) + rw_craplpi.vldoipmf;
      END LOOP;

      vr_tot_vlpesfis := vr_vlbaschq(1) + vr_vlpgtaut(1) +
                         vr_vlopecrd(1) + vr_vlaplfin(1) +
                         vr_vloutdeb(1) + vr_vlbascsd(1) +
                         vr_vlsaqmgn(1) + vr_vldccdeb(1);

      vr_tot_vlretfis := vr_vlretchq(1) + vr_vlretpgt(1) +
                         vr_vlretope(1) + vr_vlretapl(1) +
                         vr_vlretout(1) + vr_vlretcsd(1) +
                         vr_vlretsaq(1) + vr_vlretdcc(1);

      vr_tot_vlpesjur := vr_vlbaschq(2) + vr_vlpgtaut(2) +
                         vr_vlopecrd(2) + vr_vlaplfin(2) +
                         vr_vloutdeb(2) + vr_vlbascsd(2) +
                         vr_vlsaqmgn(2) + vr_vldccdeb(2);

      vr_tot_vlretjur := vr_vlretchq(2) + vr_vlretpgt(2) +
                         vr_vlretope(2) + vr_vlretapl(2) +
                         vr_vlretout(2) + vr_vlretcsd(2) +
                         vr_vlretsaq(2) + vr_vlretdcc(2);

      vr_ger_vlasscpm := vr_tot_vlpesfis + vr_tot_vlpesjur;

      vr_ger_vlretass := vr_tot_vlretfis + vr_tot_vlretjur;

      vr_tot_vlcooper := vr_vldspcco + vr_vlinvcco +
                         vr_vlimocco + vr_vltrbcco;

      vr_tot_vlretcoo := vr_vlretdsp + vr_vlretinv +
                         vr_vlretimo + vr_vlrettrb;

      vr_tot_vlcpmncb := vr_vltrfmtl + vr_vlestcri +
                         vr_vldebntr + vr_vloutcop;

      vr_tot_vlapurad := vr_tot_vlcooper + vr_ger_vlasscpm + vr_vlordpgt;
      vr_tot_vlcpmapu := vr_tot_vlretcoo + vr_ger_vlretass + vr_vlordret;
      vr_ger_vlcpmcal := vr_tot_vlcpmapu - vr_vlcpmcps + vr_vlrcpcps;

      --pasta micros da cooperativa
      vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'receita');

      --nome do arquivo
      vr_nmarquiv := 'cpmfmc.' ||vr_rfmesano;

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      -- Escreve no clob
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<?xml version="1.0" encoding="utf-8"?>'||
                             '<root dsperiod="'||vr_rel_dsperiod||'">'||chr(13)||
                             '<vlordpgt>'||nvl(vr_vlordpgt,0)||'</vlordpgt>'||
                             '<vlordret>'||nvl(vr_vlordret,0)||'</vlordret>'||
                             '<vlbaschq_1>'||nvl(vr_vlbaschq(1),0)||'</vlbaschq_1>'||
                             '<vlbaschq_2>'||nvl(vr_vlbaschq(2),0)||'</vlbaschq_2>'||
                             '<vlretchq_1>'||nvl(vr_vlretchq(1),0)||'</vlretchq_1>'||
                             '<vlretchq_2>'||nvl(vr_vlretchq(2),0)||'</vlretchq_2>'||
                             '<vlpgtaut_1>'||nvl(vr_vlpgtaut(1),0)||'</vlpgtaut_1>'||
                             '<vlpgtaut_2>'||nvl(vr_vlpgtaut(2),0)||'</vlpgtaut_2>'||
                             '<vlretpgt_1>'||nvl(vr_vlretpgt(1),0)||'</vlretpgt_1>'||
                             '<vlretpgt_2>'||nvl(vr_vlretpgt(2),0)||'</vlretpgt_2>'||
                             '<vlopecrd_1>'||nvl(vr_vlopecrd(1),0)||'</vlopecrd_1>'||
                             '<vlopecrd_2>'||nvl(vr_vlopecrd(2),0)||'</vlopecrd_2>'||
                             '<vlretope_1>'||nvl(vr_vlretope(1),0)||'</vlretope_1>'||
                             '<vlretope_2>'||nvl(vr_vlretope(2),0)||'</vlretope_2>'||
                             '<vlaplfin_1>'||nvl(vr_vlaplfin(1),0)||'</vlaplfin_1>'||
                             '<vlaplfin_2>'||nvl(vr_vlaplfin(2),0)||'</vlaplfin_2>'||
                             '<vlretapl_1>'||nvl(vr_vlretapl(1),0)||'</vlretapl_1>'||
                             '<vlretapl_2>'||nvl(vr_vlretapl(2),0)||'</vlretapl_2>'||
                             '<vlsaqmgn_1>'||nvl(vr_vlsaqmgn(1),0)||'</vlsaqmgn_1>'||
                             '<vlsaqmgn_2>'||nvl(vr_vlsaqmgn(2),0)||'</vlsaqmgn_2>'||
                             '<vlretsaq_1>'||nvl(vr_vlretsaq(1),0)||'</vlretsaq_1>'||
                             '<vlretsaq_2>'||nvl(vr_vlretsaq(2),0)||'</vlretsaq_2>'||
                             '<vloutdeb_1>'||nvl(vr_vloutdeb(1),0)||'</vloutdeb_1>'||
                             '<vloutdeb_2>'||nvl(vr_vloutdeb(2),0)||'</vloutdeb_2>'||
                             '<vlretout_1>'||nvl(vr_vlretout(1),0)||'</vlretout_1>'||
                             '<vlretout_2>'||nvl(vr_vlretout(2),0)||'</vlretout_2>'||
                             '<vlbascsd_1>'||nvl(vr_vlbascsd(1),0)||'</vlbascsd_1>'||
                             '<vlbascsd_2>'||nvl(vr_vlbascsd(2),0)||'</vlbascsd_2>'||
                             '<vlretcsd_1>'||nvl(vr_vlretcsd(1),0)||'</vlretcsd_1>'||
                             '<vlretcsd_2>'||nvl(vr_vlretcsd(2),0)||'</vlretcsd_2>'||
                             '<vldccdeb_1>'||nvl(vr_vldccdeb(1),0)||'</vldccdeb_1>'||
                             '<vldccdeb_2>'||nvl(vr_vldccdeb(2),0)||'</vldccdeb_2>'||
                             '<vlretdcc_1>'||nvl(vr_vlretdcc(1),0)||'</vlretdcc_1>'||
                             '<vlretdcc_2>'||nvl(vr_vlretdcc(2),0)||'</vlretdcc_2>'||
                             '<tot_vlpesfis>'||nvl(vr_tot_vlpesfis,0)||'</tot_vlpesfis>'||
                             '<tot_vlretfis>'||nvl(vr_tot_vlretfis,0)||'</tot_vlretfis>'||
                             '<tot_vlpesjur>'||nvl(vr_tot_vlpesjur,0)||'</tot_vlpesjur>'||
                             '<tot_vlretjur>'||nvl(vr_tot_vlretjur,0)||'</tot_vlretjur>'||
                             '<ger_vlasscpm>'||nvl(vr_ger_vlasscpm,0)||'</ger_vlasscpm>'||
                             '<ger_vlretass>'||nvl(vr_ger_vlretass,0)||'</ger_vlretass>'||
                             '<vldspcco>'||nvl(vr_vldspcco,0)||'</vldspcco>'||
                             '<vlretdsp>'||nvl(vr_vlretdsp,0)||'</vlretdsp>'||
                             '<vlinvcco>'||nvl(vr_vlinvcco,0)||'</vlinvcco>'||
                             '<vlretinv>'||nvl(vr_vlretinv,0)||'</vlretinv>'||
                             '<vlimocco>'||nvl(vr_vlimocco,0)||'</vlimocco>'||
                             '<vlretimo>'||nvl(vr_vlretimo,0)||'</vlretimo>'||
                             '<vltrbcco>'||nvl(vr_vltrbcco,0)||'</vltrbcco>'||
                             '<vlrettrb>'||nvl(vr_vlrettrb,0)||'</vlrettrb>'||
                             '<tot_vlcooper>'||nvl(vr_tot_vlcooper,0)||'</tot_vlcooper>'||
                             '<tot_vlretcoo>'||nvl(vr_tot_vlretcoo,0)||'</tot_vlretcoo>'||
                             '<tot_vlcpmncb>'||nvl(vr_tot_vlcpmncb,0)||'</tot_vlcpmncb>'||
                             '<vloutcop>'||nvl(vr_vloutcop,0)||'</vloutcop>'||
                             '<vltrfmtl>'||nvl(vr_vltrfmtl,0)||'</vltrfmtl>'||
                             '<vlestcri>'||nvl(vr_vlestcri,0)||'</vlestcri>'||
                             '<vldebntr>'||nvl(vr_vldebntr,0)||'</vldebntr>'||chr(13)||
                              --resumo1
                             '<ger_vlretass>'||nvl(vr_ger_vlretass,0)||'</ger_vlretass>'||
                             '<tot_vlretcoo>'||nvl(vr_tot_vlretcoo,0)||'</tot_vlretcoo>'||
                             '<tot_vlcpmapu>'||nvl(vr_tot_vlcpmapu,0)||'</tot_vlcpmapu>'||
                             '<vlordret>'||nvl(vr_vlordret,0)||'</vlordret>'||
                             '<vlcpmcps>'||nvl(vr_vlcpmcps,0)||'</vlcpmcps>'||
                             '<vlrcpcps>'||nvl(vr_vlrcpcps,0)||'</vlrcpcps>'||
                             '<ger_vlcpmcal>'||nvl(vr_ger_vlcpmcal,0)||'</ger_vlcpmcal>'||
                             --folha de rosto
                             '<dsmesref>'||vr_dsmesref||'</dsmesref>'||
                             '<nmarquiv>'||vr_dsdirarq||'/'||vr_nmarquiv||'</nmarquiv></root>'||chr(13),
                             TRUE);

      --pasta da cooperativa
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'rl');

      -- Gerando o relatório 186
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xml
                                 ,pr_dsxmlnode => '/root'
                                 ,pr_dsjasper  => 'crrl186.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_dsdircop||'/crrl186.lst'
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 132
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => ''
                                 ,pr_nrcopias  => 1
                                 ,pr_des_erro  => vr_dscritic);

      -- Gerando o relatório 188
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xml
                                 ,pr_dsxmlnode => '/root'
                                 ,pr_dsjasper  => 'crrl188.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_dsdircop||'/crrl188.lst'
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 80
                                 ,pr_sqcabrel  => 2
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '80col'
                                 ,pr_nrcopias  => 1
                                 ,pr_des_erro  => vr_dscritic);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

      ------------------------------------
      -- gerando o arquivo
      ------------------------------------
      vr_nmextcop := rw_crapcop.nmextcop;
      vr_nrdocnpj := rw_crapcop.nrdocnpj;
      vr_dsendcop := rw_crapcop.dsendcop;
      vr_nrendcop := rw_crapcop.nrendcop;
      vr_dscomple := rw_crapcop.dscomple;
      vr_nmbairro := rw_crapcop.nmbairro;
      vr_nmcidade := rw_crapcop.nmcidade;
      vr_cdufdcop := rw_crapcop.cdufdcop;
      vr_nrcepend := rw_crapcop.nrcepend;
      vr_nrcxapst := rw_crapcop.nrcxapst;

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml_2, TRUE);
      dbms_lob.open(vr_xml_2, dbms_lob.lob_readwrite);

      /* header */
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                              '01CPMFMC'||  /* tipo de registro e nome do arq */
                              vr_rfmesano||
                              LPAD(vr_nrdocnpj,14,'0')||
                              RPAD(vr_nmextcop,60,' ')||
                              '00000000ODCPMFMC'|| /* data da geracao devera ser preenchido com zeros */
                              RPAD(' ',408,' ')||chr(13)
                              );

      /* REGISTRO 2 */
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                              '02'||
                              RPAD(vr_dsendcop,40,' ')||
                              LPAD(vr_nrendcop,6,'0')||
                              RPAD(vr_dscomple,20,' ')||
                              RPAD(vr_nmbairro,20,' ')||
                              LPAD(vr_nrcepend,8,'0')||
                              LPAD(vr_nrcxapst,5,'0')||
                              RPAD(vr_nmcidade,30,' ')||
                              RPAD(vr_cdufdcop,2,' ')||
                              RPAD(' ',379,' ')||CHR(13)
                              );

     /* Debitos de lancamentos em conta corrente */
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '03'||
                             /* 2.2 */
                             LPAD(vr_vlbaschq(1) * 100,17,'0')||
                             LPAD(vr_vlbaschq(2) * 100,17,'0')||
                             LPAD((vr_vlretchq(1) + vr_vlretchq(2)) * 100,17,'0')||
                             /* 2.3  */
                             RPAD('0',51,'0')||
                             /* 2.4 */
                             LPAD(vr_vldccdeb(1) * 100,17,'0')||
                             LPAD(vr_vldccdeb(2) * 100,17,'0')||
                             LPAD((vr_vlretdcc(1) + vr_vlretdcc(2)) * 100,17,'0')||
                             /* 2.5 */
                             LPAD(vr_vlsaqmgn(1) * 100,17,'0')||
                             LPAD(vr_vlsaqmgn(2) * 100,17,'0')||
                             LPAD((vr_vlretsaq(1) + vr_vlretsaq(2)) * 100,17,'0')||
                             /* 2.6 */
                             LPAD(vr_vlpgtaut(1) * 100,17,'0')||
                             LPAD(vr_vlpgtaut(2) * 100,17,'0')||
                             LPAD((vr_vlretpgt(1) + vr_vlretpgt(2)) * 100,17,'0')||
                             /* 2.7 */
                             LPAD(vr_vlopecrd(1) * 100,17,'0')||
                             LPAD(vr_vlopecrd(2) * 100,17,'0')||
                             LPAD((vr_vlretope(1) + vr_vlretope(2)) * 100,17,'0')||
                             /* 2.8 */
                             LPAD(vr_vlaplfin(1) * 100,17,'0')||
                             LPAD(vr_vlaplfin(2) * 100,17,'0')||
                             LPAD((vr_vlretapl(1) + vr_vlretapl(2)) * 100,17,'0')||
                             /* 2.9 */
                             RPAD('0',51,'0')||
                             /* 2.10 */
                             LPAD(vr_vloutdeb(1) * 100,17,'0')||
                             LPAD(vr_vloutdeb(2) * 100,17,'0')||
                             LPAD((vr_vlretout(1) + vr_vlretout(2)) * 100,17,'0')||
                             /* total */
                             LPAD((vr_tot_vlpesfis - vr_vlbascsd(1)) * 100,17,'0')||
                             LPAD((vr_tot_vlpesjur - vr_vlbascsd(2)) * 100,17,'0')||
                             LPAD((vr_ger_vlretass - vr_vlretcsd(1) - vr_vlretcsd(2) ) * 100,17,'0')||CHR(13));

      --registro 04
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '04'||
                             RPAD('0',51,'0')||
                             LPAD(vr_vloutcop * 100,17,'0')||
                             LPAD(vr_vltrfmtl * 100,17,'0')||
                             LPAD(vr_vlestcri * 100,17,'0')||
                             LPAD(vr_vldebntr * 100,17,'0')||
                             LPAD((vr_vloutcop + vr_vltrfmtl + vr_vlestcri + vr_vldebntr) * 100,17,'0')||
                             RPAD(' ',374,' ')||chr(13));
      --registro 05
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '05'||
                             LPAD(vr_vlbascsd(1) * 100,17,'0')||
                             LPAD(vr_vlbascsd(2) * 100,17,'0')||
                             LPAD((vr_vlretcsd(1) + vr_vlretcsd(2)) * 100,17,'0')||
                             -- SUBTOTAL
                             LPAD(vr_vlbascsd(1) * 100,17,'0')||
                             LPAD(vr_vlbascsd(2) * 100,17,'0')||
                             LPAD((vr_vlretcsd(1) + vr_vlretcsd(2)) * 100,17,'0')||
                             RPAD(' ',408,' ')||chr(13));

      --registro 06
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '06'||
                             RPAD('0',357,'0')||
                             RPAD(' ',153,' ')||CHR(13));

      --registro 07
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '07'||
                             RPAD('0',238,'0')||
                             RPAD(' ',272,' ')||CHR(13));

      --registro 08
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '08'||
                             RPAD('0',204,'0')||
                             RPAD(' ',306,' ')||CHR(13));

      --registro 09
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '09'||
                             RPAD('0',136,'0')||
                             RPAD(' ',374,' ')||CHR(13));

      --registro 10
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '10'||
                             '00000000000000000'||
                             '00000000000000000'||
                             '00000000000000000'||
                             LPAD(vr_vlordpgt * 100,17,'0')||
                             '00000000000000000'||
                             LPAD(vr_vlordret * 100,17,'0')||
                             '00000000000000000'||
                             '00000000000000000'||
                             '00000000000000000'||
                             LPAD(vr_vlordpgt * 100,17,'0')||
                             '00000000000000000'||
                             LPAD(vr_vlordret * 100,17,'0')||
                             RPAD(' ',306,' ')||chr(13));

      --registro 11
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '11'||
                             LPAD(vr_vldspcco * 100,17,'0')||
                             LPAD(vr_vlretdsp * 100,17,'0')||
                             LPAD(vr_vlinvcco * 100,17,'0')||
                             LPAD(vr_vlretinv * 100,17,'0')||
                             LPAD(vr_vlimocco * 100,17,'0')||
                             LPAD(vr_vlretimo * 100,17,'0')||
                             LPAD(vr_vltrbcco * 100,17,'0')||
                             LPAD(vr_vlrettrb * 100,17,'0')||
                             LPAD(vr_tot_vlcooper * 100,17,'0')||
                             LPAD(vr_tot_vlretcoo * 100,17,'0')||
                             RPAD(' ',340,' ')||CHR(13));

      --registro 12
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '12'||
                             LPAD((vr_tot_vlapurad +
                               vr_vloutcop +
                               vr_vltrfmtl +
                               vr_vlestcri +
                               vr_vldebntr) * 100,17,'0')||
                             LPAD(vr_tot_vlcpmapu * 100,17,'0')||
                             LPAD((vr_vlcpmcps - vr_vlrcpcps) * 100,17,'0')||
                             LPAD(vr_ger_vlcpmcal * 100,17,'0')||
                             RPAD(' ',442,' ')||chr(13));

      --registro fim de arquivo
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             'T'||
                             RPAD('9',505,'9')||
                             vr_rfmesano||CHR(13),
                             TRUE);

      --pasta /salvar da cooperativa
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => 'salvar');

      --criando arquivo fisico
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_xml_2
                                   ,pr_caminho  => vr_dsdircop --diretorio micros/..
                                   ,pr_arquivo  => vr_nmarquiv
                                   ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

       -- Ao final, converter o arquivo para DOS e enviá-lo a pasta micros/<dsdircop>/contab
       vr_dscomando := 'ux2dos '||vr_dsdircop||'/'||vr_nmarquiv||' > '||
                                  vr_dsdirarq||'/'||vr_nmarquiv;

       --Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_dscomando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);

       --Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Nao foi possivel executar comando unix de conversão: '||vr_dscomando||'. Erro: '||vr_dscritic;
         RAISE vr_exc_saida;
       END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_2);
      dbms_lob.freetemporary(vr_xml_2);

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

  END pc_crps231;
/

