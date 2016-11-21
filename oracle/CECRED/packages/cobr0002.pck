CREATE OR REPLACE PACKAGE CECRED.COBR0002 AS

  /* Listar os lancamentos conforme parametro:
               pr_nmestrut     -> Tabela de lancamentos.
               pr_nmcampocta   -> Campo referente ao numero da conta no Banco do Brasil.
               pr_nmestrut_aux -> Segunda tabela de lancamentos (crps358) */
  PROCEDURE pc_gera_razao(pr_cdcooper     IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                         ,pr_dtperini     IN DATE                    --> Data inicial do periodo
                         ,pr_dtperfim     IN DATE                    --> Data final do periodo
                         ,pr_nmestrut     IN VARCHAR2                --> Tabela de lancamentos
                         ,pr_nmcampocta   IN VARCHAR2                --> Nome do campo que contera a conta do Banco do Brasil
                         ,pr_nmestrut_aux IN VARCHAR2                --> Segunda Tabela de lancamentos
                         ,pr_nmarquiv     IN VARCHAR2                --> Nome do arquivo que sera gerado
                         ,pr_stprogra     OUT PLS_INTEGER            --> Saída de termino da execução
                         ,pr_infimsol     OUT PLS_INTEGER            --> Saída de termino da solicitação
                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                         ,pr_dscritic OUT VARCHAR2);                 --> Texto de erro/critica encontrada



END COBR0002;
/

CREATE OR REPLACE PACKAGE BODY CECRED.COBR0002 AS

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrlivdpv
              ,cop.nrlivepr
              ,cop.nrlivapl
              ,cop.nrlivcap
              ,cop.nrinsest
              ,cop.dsendcop
              ,cop.nmcidade
              ,cop.nmbairro
              ,cop.dscomple
              ,cop.cdufdcop
              ,cop.nrcepend
              ,cop.nrrjunta
              ,cop.dtrjunta
              ,cop.nrdocnpj
              ,cop.nrinsmun
              ,cop.nmtitcop
              ,cop.nrcpftit
              ,cop.nmctrcop
              ,cop.nrcpfctr
              ,cop.nrcrcctr
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- busca os dados do historico do sistema
      CURSOR cr_craphis(pr_cdcooper     crapcop.cdcooper%TYPE,
                        pr_nmestrut     craphis.nmestrut%TYPE,
                        pr_nmestrut_aux craphis.nmestrut%TYPE) IS
        SELECT cdhistor
              ,dsexthst
              ,nrctadeb
              ,nrctacrd
              ,indebcre
              ,tpctbcxa
          FROM craphis
         WHERE cdcooper  = pr_cdcooper
           AND (upper(nmestrut) = upper(pr_nmestrut)
            OR  upper(nmestrut) = upper(nvl(pr_nmestrut_aux,' ')))
          ORDER BY cdhistor;

      -- Cursor de cheques contidos do Bordero de desconto de cheques
      CURSOR cr_crapcdb(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt crapcdb.dtmvtolt%TYPE) IS
        SELECT 1
          FROM crapcdb
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt;
      rw_crapcdb cr_crapcdb%ROWTYPE;

      -- Cursor sobre o cadastro de associados
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT nrdconta,
               nmprimtl
          FROM crapass
         WHERE cdcooper = pr_cdcooper;

      -- Cursor sobre o cadastro de agencias
      CURSOR cr_crapage (pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cdagenci,
               cdcxaage,
               nmextage
          FROM crapage
         WHERE cdcooper = pr_cdcooper;

      -- Busca dos borderos de desconto de cheques
      CURSOR cr_crapbdc(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtlibbdc crapbdc.dtlibbdc%TYPE) IS
        SELECT nrborder,
               dtmvtolt
          FROM crapbdc
         WHERE crapbdc.cdcooper = pr_cdcooper
           AND crapbdc.dtlibbdc = pr_dtlibbdc
           AND crapbdc.insitbdc = 3;

      -- Busca dos cheques contidos do Bordero de desconto de cheques
      CURSOR cr_crapcdb_2(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_nrdorder crapcdb.nrborder%TYPE) IS
        SELECT vlcheque,
               nrdconta,
               vlliquid,
               dtmvtolt,
               cdagenci,
               nrborder,
               COUNT(1) OVER (PARTITION BY nrdconta) totreg,
               ROW_NUMBER () OVER (PARTITION BY nrdconta ORDER BY nrdconta) nrseq

          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrborder = pr_nrdorder
         ORDER BY nrdconta;

      -- Criacao de temp/table para a tabela de associados (crapass)
      TYPE typ_reg_crapass IS
        RECORD(nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(10);
      -- Vetor para armazenar os dados da tabela crapass
      vr_tab_crapass typ_tab_crapass;

      -- Criacao de temp/table para a tabela de agencias (crapage)
      TYPE typ_reg_crapage IS
        RECORD(cdcxaage crapage.cdcxaage%TYPE,
               nmextage crapage.nmextage%TYPE);
      TYPE typ_tab_crapage IS
        TABLE OF typ_reg_crapage
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados da tabela crapass
      vr_tab_crapage typ_tab_crapage;

      ------------------------------- VARIAVEIS --------------------------------

      -- Variaveis gerais
      vr_rel_tpdrazao VARCHAR2(50);                        --> Titulo do relatorio
      vr_rel_nmcooper crapcop.nmextcop%TYPE;               --> Nome da cooperativa
      vr_contdata     DATE;                                --> Variavel do loop que contem a data que esta sendo processado
      vr_existe_dados BOOLEAN := FALSE;                    --> Flag informando se existe lancamentos para a cooperativa
      vr_texto_completo VARCHAR2(32600);                   --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_clob      CLOB;                               --> CLOB do relatorio
      vr_texto_completo_2 VARCHAR2(32600);                 --> Variável para armazenar os dados do XML antes de incluir no CLOB para o termo de abertura
      vr_des_clob_2    CLOB;                               --> CLOB do relatorio para o termo de abertura
      vr_cdagenci_ant crapage.cdagenci%TYPE := 0;          --> Agencia anterior utilizado na execucao do loop de detalhes
      vr_dstextab     craptab.dstextab%TYPE;               --> Texto da tabela de paramentos gerais
      vr_contlinh     PLS_INTEGER := 0;                    --> Contador de linhas na pagina
      vr_dtperini     DATE;                                --> Data inicial do periodo
      vr_dtperfim     DATE;                                --> Data final do periodo

      -- Variáveis para criação de cursor dinâmico
      vr_num_cursor     number;
      vr_num_retor      number;
      vr_cursor         varchar2(32000);
      vr_num_cursor_aux number;
      vr_num_retor_aux  number;
      vr_cursor_aux     varchar2(32000);

      -- Constantes
      vr_novapagi       VARCHAR2(01) := '1';               --> Indicador de nova pagina
      vr_novalinh       VARCHAR2(01) := ' ';           --> Indicador de nova linha
      vr_pulalinh       VARCHAR2(01) := '0';               --> Indicador de salto de linha
      vr_rel_linhpon    VARCHAR2(132) := lpad('-',131,'-');--> Linha pontilhada do titulo
      vr_rel_linhastr   VARCHAR2(132);                     --> Asteriscos para complementacao de folha



      -- Variaveis utilizadas no cursor dinamico
      vr_cdcooper      craplcm.cdcooper%TYPE;
      vr_cdhistor      craplcm.cdhistor%TYPE;
      vr_dtmvtolt      craplcm.dtmvtolt%TYPE;
      vr_nrdconta      craplcm.nrdconta%TYPE;
      vr_vllanmto      craplcm.vllanmto%TYPE;
      vr_cdagenci      craplcm.cdagenci%TYPE := 0;
      vr_cdbccxlt      craplcm.cdbccxlt%TYPE;
      vr_nrdocmto      craplcm.nrdocmto%TYPE;
      vr_campocta      NUMBER(20);

      -- Variaveis utilizadas no relatorio
      vr_rel_cdhistor  craphis.cdhistor%TYPE;              --> codigo do historico do lancamento.
      vr_rel_dshistor  craphis.dsexthst%TYPE;              --> descricao do historico
      vr_rel_nrctadeb  craphis.nrctadeb%TYPE;              --> numero da conta a debitar.
      vr_rel_nrctacrd  craphis.nrctacrd%TYPE;              --> numero da conta a creditar.
      vr_histcred      BOOLEAN;                            --> Indicador se o lancamento eh de credito
      vr_tpctbcxa      craphis.tpctbcxa%TYPE;              --> (0-nao, 1-geral, 2-pac db, 3-pac cr, 4-bb db, 5-bb cr)
      vr_rel_ttcrddia  NUMBER(17,2) :=0;                   --> Total de credito do dia
      vr_rel_ttdebdia  NUMBER(17,2) :=0;                   --> Total de debito do dia
      vr_rel_nrdlivro  crapcop.nrlivdpv%TYPE;              --> numero do livro fiscal
      vr_rel_dtterabr  DATE;                               --> Data de termino do livro de abertura
      vr_rel_ttlanage  NUMBER(17,2) := 0;                  --> Total por PA
      vr_rel_ttlanmto  NUMBER(17,2) := 0;                  --> Total geral do relatorio
      vr_rel_dtlanmto  DATE;                               --> Data do lancamento
      vr_rel_nrdconta  craplap.nrdconta%TYPE;              --> Numero da conta
      vr_rel_vllancrd  craplap.vllanmto%TYPE;              --> Valor do lancamento de credito
      vr_rel_vllandeb  craplap.vllanmto%TYPE;              --> Valor do lancamento de debito
      vr_rel_nrdocmto  NUMBER(25);                         --> Numero do documento
      vr_rel_cdagenci  crapage.cdagenci%TYPE;              --> Codigo da agencia
      vr_rel_contapag  PLS_INTEGER := 1;                   --> Contador de paginas
      vr_rel_cablinha  VARCHAR2(200);                      --> Linha de cabecalho
      vr_rel_hislinha  VARCHAR2(200);                      --> Linha de historico

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'COBR0002';

  PROCEDURE pc_gera_razao_cab IS
/* ..........................................................................

   Programa: pc_gera_razao_cab    Antigo: includes/gerarazao_cab.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 17/03/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Gera cabecalho da pagina.

   Atualizacoes : 26/01/2004 - Alteracao no titulo de DIARIO AUXILIAR para
                               RAZAO AUXILIAR (Julio).
                  21/11/2005 - Alterar razao para diario(Mirtes)

                  06/11/2007 - Acerto no numero de pagina, estouro de campo (Ze)

                  17/03/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN
    -- Incrementa o contador de paginas
    vr_rel_contapag := vr_rel_contapag + 1;

    vr_rel_cablinha := vr_novapagi || lpad(' ', 64 - LENGTH(vr_rel_nmcooper) / 2,' ') ||vr_rel_nmcooper;
    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                              vr_rel_cablinha||chr(10));

    -- Volta o contador de linhas para 1
    vr_contlinh := 1;

    vr_rel_cablinha := vr_novalinh ||
               lpad(' ', 65 - LENGTH(TRIM('DIARIO AUXILIAR DE ' ||vr_rel_tpdrazao)) / 2,' ') ||
               'DIARIO AUXILIAR DE ' || vr_rel_tpdrazao;
    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                              vr_rel_cablinha||chr(10));

    -- incrementa o contador de linhas
    vr_contlinh := vr_contlinh + 1;

    vr_rel_cablinha := vr_novalinh || lpad(' ', 49,' ') || 'PERIODO: ' ||
                              to_char(vr_dtperini,'dd/mm/yyyy') || ' a ' ||
                              to_char(vr_dtperfim,'dd/mm/yyyy') || lpad(' ',37,' ')||'PAGINA: '||
                              TO_CHAR(vr_rel_contapag, 'FM00000');
    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                              vr_rel_cablinha||chr(10));

    -- incrementa o contador de linhas
    vr_contlinh := vr_contlinh + 1;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                              vr_novalinh || vr_rel_linhpon||chr(10));

    vr_contlinh := vr_contlinh + 2;
  END pc_gera_razao_cab;


  PROCEDURE pc_gera_razao_nul IS
/* ..........................................................................

   Programa: pc_gera_razao_nul    Antigo: includes/gerarazao_nul.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 17/03/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir asteristos nas linhas restantes das paginas.

   Alteracao : 17/03/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN
   WHILE vr_contlinh <= 84 LOOP

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                vr_novalinh || vr_rel_linhastr ||chr(10));
    vr_contlinh := vr_contlinh + 1;

   END LOOP;

  END pc_gera_razao_nul;

  PROCEDURE pc_gera_razao_tit IS
/* ..........................................................................

   Programa: pc_gera_razao_tit    Antigo: includes/gerarazao_tit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o titulo dos lancamentos.

   Alteracao : 17/11/2003 - Correcao na quebra de pagina (Julio).

               24/02/2011 - Ajuste no layout do titulo (Henrique).

               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).

               19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN

    -- Verifica se eh final de pagina
    IF vr_contlinh > 81 THEN
      pc_gera_razao_nul;
      pc_gera_razao_cab;
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
      vr_pulalinh||
      '        DATA HIST PA   NRD.CONTA NOME                                    '||
      'DOCUMENTO CTA.DEB. CTA.CRED.   VALOR DEBITO  VALOR CREDITO'||chr(10));

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
      vr_novalinh||
      '  ---------- ---- --- ---------- ----------------------------- ------------------- '||
      '-------- --------- -------------- --------------'||chr(10));

    vr_contlinh := vr_contlinh + 3;

  END;


  PROCEDURE pc_gera_razao_lan IS
/* ..........................................................................

   Programa: pc_gera_razao_lan    Antigo: includes/gerarazao_lan.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o lancamento do associado.

               {1} -> Nome do Associado

   Alteracao : 24/02/2011 - Ajuste no layout do titulo (Henrique).

               03/04/2012 - Ajuste para impressao de valor negativo (David).

               19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

               08/07/2014 - Se nao existir conta, mover espacos para o nome
                            do cooperado (Andrino/RKAM)
............................................................................. */
    vr_rel_vllamnto VARCHAR2(50);
    vr_nmprimtl     VARCHAR2(29);
  BEGIN

    -- Se estourou a pagina, vai para a proxima pagina
    IF vr_contlinh > 84   THEN
      pc_gera_razao_cab;
      pc_gera_razao_tit;
    END IF;

    -- Se o debito for vazio, ira imprimir somente o credito
    IF  vr_rel_vllandeb = 0   THEN
      vr_rel_vllamnto := lpad(' ',15,' ')||to_char(vr_rel_vllancrd, '999999G990D00');
    ELSE -- Senao imprime somente o debito
      vr_rel_vllamnto := to_char(vr_rel_vllandeb, '999999G990D00');
    END IF;

    IF NOT vr_tab_crapass.exists(vr_rel_nrdconta) THEN
      vr_nmprimtl := ' ';
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || 'Associado nao encontrado na tabela de '||vr_rel_tpdrazao);
    ELSE
      vr_nmprimtl := substr(vr_tab_crapass(vr_rel_nrdconta).nmprimtl,1,29);
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
          vr_novalinh ||
          '  ' ||
          to_char(vr_rel_dtlanmto, 'dd/mm/yyyy') ||
          to_char(vr_rel_cdhistor, '9990') ||
          to_char(vr_rel_cdagenci, '990')  || ' ' ||
          gene0002.fn_mask_conta(vr_rel_nrdconta) || ' ' ||
          rpad(vr_nmprimtl,29,' ')||
          to_char(vr_rel_nrdocmto, '9999999999999999990') ||
          to_char(vr_rel_nrctadeb, '99990000') ||
          to_char(vr_rel_nrctacrd, '999990000') ||
          vr_rel_vllamnto|| chr(10));

    vr_contlinh := vr_contlinh + 1;
  END;

  PROCEDURE pc_gera_razao_dat IS
/* ..........................................................................

   Programa: pc_gera_razao_dat    Antigo: includes/gerarazao_dat.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total de lancamentos da data.

   Alteracao : 19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN
    -- Se estourou a pagina, vai para a proxima pagina
    IF vr_contlinh > 83 THEN
      pc_gera_razao_nul;
      pc_gera_razao_cab;
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
        vr_pulalinh ||'TOTAL DO DIA ( ' ||
                        to_char(vr_contdata,'dd/mm/yyyy') || ' )' ||
                        rpad(' ', 25, ' ') || rpad('-', 47, '-') || '> ' ||
                        to_char(vr_rel_ttdebdia, '999G999G990D00') ||
                        to_char(vr_rel_ttcrddia, '999G999G990D00')||chr(10));

    vr_contlinh := vr_contlinh + 2;

  END;

  PROCEDURE pc_gera_razao_tot IS
/* ..........................................................................

   Programa: pc_gera_razao_tot    Antigo: includes/gerarazao_tot.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total do historico.

   Alteracao : 19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
    vr_rel_vllamnto PLS_INTEGER; --> Quantidade de espacos para o total
  BEGIN
    -- Verifica se eh final de pagina
    IF vr_contlinh > 84 THEN
      pc_gera_razao_cab;
    END IF;

    -- Verifica se o lancamento eh de debito
    IF NOT vr_histcred THEN
      vr_rel_vllamnto := 12;
    ELSE
      vr_rel_vllamnto := 27;
    END IF;

    -- Preenche a linha de total
    vr_rel_hislinha := '  TOTAL HISTORICO ( ' ||
               to_char(vr_rel_cdhistor, 'fm9990') || ' - ' ||
               rpad(vr_rel_dshistor ||' )',52,' ')||
               lpad(' ', 12 - LENGTH(vr_rel_cdhistor),' ') ||
               lpad('=', vr_rel_vllamnto,'=') || '> ' ||
               to_char(vr_rel_ttlanmto, '999G999G990D00')||chr(10);

    -- Se for um historico de total geral
    IF vr_rel_cdhistor < 9998   THEN
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
        vr_novalinh || vr_rel_hislinha);
    ELSE
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
        vr_pulalinh || vr_rel_hislinha);
    END IF;

    vr_contlinh := vr_contlinh + 1;

  END;


  PROCEDURE pc_gera_razao_pac IS
/* ..........................................................................

   Programa: pc_gera_razao_pac    Antigo: includes/gerarazao_pac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o total de lancamentos do PAC.

   Alteracao : Inclusao do tratamento para imprimir asteriscos ao final da
               pagina (Julio).

               03/02/2006 - Unificacao dos bancos - Eder

               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).

               19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
    vr_rel_vllamnto VARCHAR2(50);
  BEGIN
    -- Verifica se eh final de pagina
    IF vr_contlinh > 82 THEN
      pc_gera_razao_nul;
      pc_gera_razao_cab;
    ELSE
      -- verifica em que posicao ficara a linha de total
      IF NOT vr_histcred   THEN
        gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
              vr_novalinh || lpad(' ', 102,' ') ||
                               lpad('-', 14,'-') || chr(10));
      ELSE
        gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
              vr_novalinh || lpad(' ', 118,' ') ||
                               lpad('-', 13,'-') || chr(10));
      END IF;
      vr_contlinh := vr_contlinh + 1;
    END IF;

    -- verifica se nao eh credito
    IF NOT vr_histcred  THEN
      vr_rel_vllamnto := to_char(vr_rel_ttlanage, '999G999G990D00');
    ELSE
      vr_rel_vllamnto := lpad(' ',15,' ') || to_char(vr_rel_ttlanage, '999G999G990D00');
    END IF;

    -- Se nao existir a agencia, atribuir valor vazio
    IF NOT vr_tab_crapage.exists(vr_cdagenci_ant) THEN
      vr_tab_crapage(vr_cdagenci_ant).cdcxaage := vr_cdagenci_ant;
      vr_tab_crapage(vr_cdagenci_ant).nmextage := '';
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
       vr_novalinh || '    TOTAL PA  ( ' ||
                        rpad(to_char(vr_cdagenci_ant,'fm990') || ' - ' ||
                        vr_tab_crapage(vr_cdagenci_ant).nmextage || ' )  ',54,' ') ||
                        lpad('-', 13,'-') || '>  ' ||
                        to_char(vr_rel_nrctadeb, '9990') || '     ' ||
                        to_char(vr_rel_nrctacrd, '9990') ||
                        vr_rel_vllamnto||chr(10));

    vr_contlinh := vr_contlinh + 1;

  END;
  PROCEDURE pc_gera_razao_det(pr_cdcooper   crapcop.cdcooper%TYPE,
                              pr_cursor     VARCHAR2,
                              pr_nrctacrd   craphis.nrctacrd%TYPE,
                              pr_nrctadeb   craphis.nrctadeb%TYPE) IS
/* ..........................................................................

   Programa: pc_gera_razao_det    Antigo: includes/gerarazao_det.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                       Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme o historico.

               {1} -> Tabela de lancamentos
               {2} -> Campo referente ao numero da conta no Banco do Brasil

   Alteracoes: 30/03/2004 - Tratar o tipo de contabilizacao por caixa 6
                            (Edson).

               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               18/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
..............................................................................*/
  BEGIN
    vr_rel_ttlanmto := 0;
    vr_cdagenci_ant := -1;
    -- Cria cursor dinâmico
    vr_num_cursor := dbms_sql.open_cursor;

    -- Comando Parse
    dbms_sql.parse(vr_num_cursor, pr_cursor, 1);

    -- Definindo Colunas de retorno
    dbms_sql.define_column(vr_num_cursor, 1, vr_cdcooper);
    dbms_sql.define_column(vr_num_cursor, 2, vr_cdhistor);
    dbms_sql.define_column(vr_num_cursor, 3, vr_dtmvtolt);
    dbms_sql.define_column(vr_num_cursor, 4, vr_nrdconta);
    dbms_sql.define_column(vr_num_cursor, 5, vr_vllanmto);
    dbms_sql.define_column(vr_num_cursor, 6, vr_cdagenci);
    dbms_sql.define_column(vr_num_cursor, 7, vr_cdbccxlt);
    dbms_sql.define_column(vr_num_cursor, 8, vr_nrdocmto);
    dbms_sql.define_column(vr_num_cursor, 9, vr_campocta);

    -- Execução do select dinamico
    vr_num_retor := dbms_sql.execute(vr_num_cursor);
    -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
    WHILE dbms_sql.fetch_rows(vr_num_cursor) > 0 LOOP
      -- Carrega variáveis com o retorno do cursor
      dbms_sql.column_value(vr_num_cursor, 1, vr_cdcooper);
      dbms_sql.column_value(vr_num_cursor, 2, vr_cdhistor);
      dbms_sql.column_value(vr_num_cursor, 3, vr_dtmvtolt);
      dbms_sql.column_value(vr_num_cursor, 4, vr_nrdconta);
      dbms_sql.column_value(vr_num_cursor, 5, vr_vllanmto);
      dbms_sql.column_value(vr_num_cursor, 6, vr_cdagenci);
      dbms_sql.column_value(vr_num_cursor, 7, vr_cdbccxlt);
      dbms_sql.column_value(vr_num_cursor, 8, vr_nrdocmto);
      dbms_sql.column_value(vr_num_cursor, 9, vr_campocta);

      -- Verifica se a agencia anterior eh diferente da agencia atual, ou seja, a ultima agencia
      IF vr_cdagenci <> vr_cdagenci_ant AND vr_cdagenci_ant <> -1 THEN
        -- Efetua o total do PA
        pc_gera_razao_pac;
        vr_rel_ttlanage := 0;
      END IF;


      vr_rel_dtlanmto := vr_dtmvtolt;
      vr_rel_nrdconta := vr_nrdconta;
      vr_rel_vllancrd := vr_vllanmto;
      vr_rel_vllandeb := vr_vllanmto;
      vr_rel_nrdocmto := vr_nrdocmto;
      vr_rel_ttlanmto := vr_rel_ttlanmto + vr_vllanmto;
      vr_rel_ttlanage := vr_rel_ttlanage + vr_vllanmto;
      vr_rel_cdagenci := vr_cdagenci;

      IF NOT vr_histcred  THEN  /* Verifica se o historico e Deb. ou Cred.*/
        vr_rel_vllancrd := 0;
        vr_rel_ttdebdia := vr_rel_ttdebdia + vr_vllanmto;
      ELSE
        vr_rel_vllandeb := 0;
        vr_rel_ttcrddia := vr_rel_ttcrddia + vr_vllanmto;
      END IF;

      IF vr_tpctbcxa = 2   THEN -- Se for PA Debito
        vr_rel_nrctadeb := vr_tab_crapage(vr_cdagenci).cdcxaage;
        vr_rel_nrctacrd := pr_nrctacrd;
      ELSIF vr_tpctbcxa = 3  THEN -- Se for PA Credito
        vr_rel_nrctadeb := pr_nrctadeb;
        vr_rel_nrctacrd := vr_tab_crapage(vr_cdagenci).cdcxaage;
      ELSIF vr_tpctbcxa > 3  THEN -- 4-bb db, 5-bb cr
        -- Busca os valores de juros da tabela de parametros
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'CONTAB'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => vr_campocta
                                                 ,pr_tpregist => vr_cdbccxlt);

        IF vr_tpctbcxa = 4 OR vr_tpctbcxa = 6  THEN -- bb debito
          IF vr_dstextab IS NOT NULL THEN
            vr_rel_nrctadeb := vr_dstextab;
          END IF;
          vr_rel_nrctacrd := pr_nrctacrd;
        ELSE
          IF vr_dstextab IS NOT NULL THEN
            vr_rel_nrctacrd := vr_dstextab;
          END IF;
          vr_rel_nrctadeb := pr_nrctadeb;
        END IF;
      ELSE
        vr_rel_nrctadeb := pr_nrctadeb;
        vr_rel_nrctacrd := pr_nrctacrd;
      END IF;

      IF vr_cdagenci <> vr_cdagenci_ant THEN
        -- Efetua a abertura do no do PA
        pc_gera_razao_tit;
      END IF;

      -- Imprime o lancamento
      pc_gera_razao_lan;

      -- Atualiza a agencia anterior
      vr_cdagenci_ant := vr_cdagenci;
    END LOOP;

    -- Efetua o total do PA
    pc_gera_razao_pac;
    vr_rel_ttlanage := 0;

    -- Fecha o cursor dinamico
    dbms_sql.close_cursor(vr_num_cursor);


  END;



  PROCEDURE pc_gera_razao_his IS
/* ..........................................................................

   Programa: pc_gera_razao_his    Antigo: includes/gerarazao_his.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprime Titulo do historico.

               {1} -> Descricao do Historico.

   Alteracao : 17/11/2003 - Correcao na quebra de pagina (Julio)

               18/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN
    -- Verifica se eh final de pagina
    IF vr_contlinh > 79 THEN
      pc_gera_razao_nul;
      pc_gera_razao_cab;
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
      vr_pulalinh ||'  '||rpad(to_char(vr_rel_cdhistor, 'fm9990') || ' - ' ||
                             substr(vr_rel_dshistor,1,50),57,' ')||rpad(' ',45,' ')||
                             '( D -' ||to_char(vr_rel_nrctadeb, '9990') || ' )   ( C -'||
                                        to_char(vr_rel_nrctacrd, '9990') || ' )'||chr(10));
   vr_contlinh := vr_contlinh + 2;
  END;


  PROCEDURE pc_gera_razao_dtl(pr_dtrefere IN DATE) IS
/* ..........................................................................

   Programa : pc_gera_razao_dtl    Antigo: includes/gerarazao_dtl.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir cabecalho de inicio de lancamentos por data.

   Alteracoes : 18/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
............................................................................. */
  BEGIN
    -- Se for inicio de pagina imprime o cabecalho
    IF vr_contlinh = 0   THEN
      pc_gera_razao_cab;
    ELSIF vr_contlinh >= 76 THEN -- Se for final de pagina
      pc_gera_razao_nul;
      pc_gera_razao_cab;
    ELSE
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
         vr_novalinh || vr_rel_linhpon||chr(10));
      vr_contlinh := vr_contlinh + 1;
    END IF;

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
       vr_novalinh || 'LANCAMENTOS DO DIA ' || to_char(pr_dtrefere,'DD/MM/YYYY')||chr(10));

    gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
       vr_novalinh || vr_rel_linhpon||chr(10));

    vr_contlinh := vr_contlinh + 2;

  END;

  PROCEDURE pc_gera_razao_abr(pr_nrpagina     IN VARCHAR2,
                              pr_cablinha     IN VARCHAR2) IS
/* ..........................................................................

   Programa : pc_gera_razao_abr    Antigo: includes/gerarazao_abr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o termo de abertura do razao auxiliar.

                {1} -> Numero da Pagina
                {2} -> Titulo do termo (abertura ou encerramento)

   Alteracoes : 14/11/2003 - Campo CRC contador foi alterado para STRING (Julio)

                28/09/2005 - Modificado FIND FIRST para FIND na tabela
                             crapcop.cdcooper = glb_cdcooper (Diego).

                21/11/2005 - Alterar Razao para Diario(Mirtes)

                06/11/2007 - Acerto no numero de pagina, estouro de campo (Ze).

                18/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

............................................................................. */
    vr_nrinsest VARCHAR2(20); --> numero da inscricao estadual
    vr_cablinha VARCHAR2(200); --> Variavel para centralizar o texto
    vr_dstexto  VARCHAR2(4000); --> Texto que sera inserido no clob
    vr_rel_cablinha VARCHAR2(1000); --> Variavel que contem o texto do relatorio
    vr_linha01      VARCHAR2(200); --> Variavel que contem a linha 1 do resumo
    vr_linha02      VARCHAR2(200); --> Variavel que contem a linha 2 do resumo
    vr_linha03      VARCHAR2(200); --> Variavel que contem a linha 3 do resumo
    vr_linha04      VARCHAR2(200); --> Variavel que contem a linha 4 do resumo
  BEGIN

    -- Se a inscricao estadual for zero, escreve a palavra Isenta
    IF rw_crapcop.nrinsest = 0 THEN
      vr_nrinsest := 'ISENTO';
    ELSE
      vr_nrinsest := to_char(rw_crapcop.nrinsest, '999G999G990');
    END IF;

    -- Titulo do relatorio
    vr_cablinha := 'DIARIO AUXILIAR '||+ vr_rel_tpdrazao || ' Nr. ' || to_char(vr_rel_nrdlivro, 'fm9990');

    vr_rel_cablinha := 'Contem este livro mensal ' || to_char(vr_rel_contapag, 'fm99990') || ' paginas, ' ||
               'numeradas eletronicamente e seguidamente do Nr. 1 ao Nr. ' ||
               to_char(vr_rel_contapag, 'fm99990') || ' e ';

    -- Se for termo de abertura, devera informar que o livro fiscal SERVIRA, caso constrario, o livro fiscal SERVIU
    IF pr_cablinha = 'TERMO DE ABERTURA' THEN
      vr_rel_cablinha := vr_rel_cablinha || 'servira';
    ELSE
      vr_rel_cablinha := vr_rel_cablinha || 'serviu';
    END IF;

    vr_rel_cablinha := vr_rel_cablinha || ' para os lancamentos das operacoes ' ||
               'proprias do estabelecimento do contribuinte abaixo descrito:';

    -- Quebra o texto e justifica o mesmo
    LIMP0001.pc_quebra_str(vr_rel_cablinha,
                           80,
                           80,
                           80,
                           80,
                           vr_linha01,
                           vr_linha02,
                           vr_linha03,
                           vr_linha04);

    vr_dstexto :=           '1'||chr(10)||
                            '0'||lpad(' ',64-(length(vr_rel_nmcooper)/2),' ')||vr_rel_nmcooper ||chr(10)||
                            lpad(' ',119,' ')||'PAGINA: '||pr_nrpagina                         ||chr(10)||
                            lpad(' ',65-(length(vr_cablinha)/2),' ')||vr_cablinha              ||chr(10)||
                            '0'||lpad(' ',64-(length(pr_cablinha)/2),' ')||pr_cablinha         ||chr(10)||
                            '0'                                                                ||chr(10)||
                            '0'||lpad(' ',25,' ')||vr_linha01                                  ||chr(10)||
                            lpad(' ',26,' ')||vr_linha02                                       ||chr(10)||
                            lpad(' ',26,' ')||vr_linha03                                       ||chr(10)||
                            lpad(' ',26,' ')||vr_linha04                                       ||chr(10)||
                            '0'||lpad(' ',25,' ')||'Nome da empresa    : '||vr_rel_nmcooper    ||chr(10)||
                            '0'||lpad(' ',25,' ')||'Endereco           : '||rw_crapcop.dsendcop||chr(10)||
                            '0'||lpad(' ',25,' ')||'Cidade             : '||rw_crapcop.nmcidade||chr(10)||
                            '0'||lpad(' ',25,' ')||'Bairro             : '||rw_crapcop.nmbairro||chr(10)||
                            '0'||lpad(' ',25,' ')||'Complemento        : '||rw_crapcop.dscomple||chr(10)||
                            '0'||lpad(' ',25,' ')||'Estado             : '||rw_crapcop.cdufdcop||chr(10)||
                            '0'||lpad(' ',25,' ')||'CEP                : '||gene0002.fn_mask(rw_crapcop.nrcepend,'99.999-999')||chr(10)||
                            '0'||lpad(' ',25,' ')||'Registro na Junta  : '||to_char(rw_crapcop.nrrjunta,'fm99999G999999G0')||chr(10)||
                            '0'||lpad(' ',25,' ')||'Data do Registro   : '||to_char(rw_crapcop.dtrjunta,'DD/MM/YYYY')||chr(10)||
                            '0'||lpad(' ',25,' ')||'CNPJ               : '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)||chr(10)||
                            '0'||lpad(' ',25,' ')||'Inscricao Estadual : '||vr_nrinsest        ||chr(10)||
                            '0'||lpad(' ',25,' ')||'Inscricao Municipal: '||trim(gene0002.fn_mask(rw_crapcop.nrinsmun,'zzz.zzz-z'))||chr(10)||
                            '0'                                                                ||chr(10)||
                            '0'||lpad(' ',25,' ')||initcap(rw_crapcop.nmcidade)||', ' ||to_char(vr_rel_dtterabr,'DD')||
                                ' de ' || to_char(vr_rel_dtterabr,'Month','nls_date_language =''brazilian portuguese''')||
                                'de ' || to_char(vr_rel_dtterabr,'YYYY')||'.'                  ||chr(10)||
                            '0'                                                                ||chr(10)||
                            '0'||lpad(' ',25,' ')||'Titular da Empresa : '||rw_crapcop.nmtitcop||chr(10)||
                                 lpad(' ',26,' ')||'CPF                : '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrcpftit,1)||chr(10)||
                            '0'                                                                ||chr(10)||
                            '0'                                                                ||chr(10)||
                            '0'||lpad(' ',25,' ')||'Contador Responsavel: '||rw_crapcop.nmctrcop||chr(10)||
                                 lpad(' ',26,' ')||'CPF                 : '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrcpfctr,1)||chr(10)||
                                 lpad(' ',26,' ')||'CRC                 : '||rw_crapcop.nrcrcctr||chr(10);

    -- Se for termo de abertura eh gerado em outra variavel CLOB, pois ela sera gerada somente no final do relatorio
    IF pr_cablinha = 'TERMO DE ABERTURA' THEN
      gene0002.pc_escreve_xml(vr_des_clob_2, vr_texto_completo_2, vr_dstexto,TRUE);
    ELSE
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo, vr_dstexto);
    END IF;

  END;


  PROCEDURE pc_gera_razao_chq(pr_cdcooper crapcop.cdcooper%TYPE) IS
/* ..........................................................................

   Programa: pc_gera_razao_chq    Antigo: includes/gerarazao_chq.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003                      Ultima atualizacao: 20/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme parametro.

   Alteracoes:
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               19/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
..............................................................................*/
  BEGIN
    -- Zera o acumulador de totais
    vr_rel_ttlanmto := 0;

    -- Abre o no de historico
    pc_gera_razao_his;

    -- Abre o no de PAC
    pc_gera_razao_tit;

    -- Busca dos borderos de desconto de cheques
    FOR rw_crapbdc IN cr_crapbdc(pr_cdcooper, vr_contdata) LOOP

      -- Busca dos cheques contidos do Bordero de desconto de cheques
      FOR rw_crapcdb IN cr_crapcdb_2(pr_cdcooper, rw_crapbdc.nrborder) LOOP

        IF vr_rel_cdhistor = 9998 THEN
          vr_rel_vllandeb := vr_rel_vllandeb + rw_crapcdb.vlcheque;
          vr_rel_vllancrd := 0;
        ELSIF vr_rel_cdhistor = 9999 THEN
          vr_rel_vllancrd := vr_rel_vllancrd +
                                (rw_crapcdb.vlcheque - rw_crapcdb.vlliquid);
          vr_rel_vllandeb := 0;
        END IF;

        -- Se for o ultimo registro da conta
        IF rw_crapcdb.totreg = rw_crapcdb.nrseq THEN

          -- Se nao existir associado volta para o inicio do loop
          IF NOT vr_tab_crapass.exists(rw_crapcdb.nrdconta) THEN
            continue; -- Volta para o inicio do loop
          END  IF;

          vr_rel_dtlanmto := rw_crapbdc.dtmvtolt;
          vr_rel_nrdconta := rw_crapcdb.nrdconta;
          vr_rel_cdagenci := rw_crapcdb.cdagenci;
          vr_rel_nrdocmto := rw_crapcdb.nrborder;
          vr_rel_ttlanmto := vr_rel_ttlanmto + vr_rel_vllancrd +
                                         vr_rel_vllandeb;
          vr_rel_ttcrddia := vr_rel_ttcrddia + vr_rel_vllancrd;
          vr_rel_ttdebdia := vr_rel_ttdebdia + vr_rel_vllandeb;

          -- imprime a linha de detalhes
          pc_gera_razao_lan;

          vr_rel_vllandeb := 0;
          vr_rel_vllancrd := 0;
        END IF;
      END LOOP;
    END LOOP;

    pc_gera_razao_tot;

  END;

  PROCEDURE pc_gera_razao(pr_cdcooper     IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                         ,pr_dtperini     IN DATE                    --> Data inicial do periodo
                         ,pr_dtperfim     IN DATE                    --> Data final do periodo
                         ,pr_nmestrut     IN VARCHAR2                --> Tabela de lancamentos
                         ,pr_nmcampocta   IN VARCHAR2                --> Nome do campo que contera a conta do Banco do Brasil
                         ,pr_nmestrut_aux IN VARCHAR2                --> Segunda Tabela de lancamentos
                         ,pr_nmarquiv     IN VARCHAR2                --> Nome do arquivo que sera gerado
                         ,pr_stprogra     OUT PLS_INTEGER            --> Saída de termino da execução
                         ,pr_infimsol     OUT PLS_INTEGER            --> Saída de termino da solicitação
                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                         ,pr_dscritic OUT VARCHAR2) IS               --> Texto de erro/critica encontrada

/* ..........................................................................

   Programa : pc_gera_razao    Antigo: includes/gerarazao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                       Ultima atualizacao: 18/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme parametro.

               {1} -> Tabela de lancamentos.
               {2} -> Campo referente ao numero da conta no Banco do Brasil.
               {3} -> Segunda tabela de lancamentos (crps358)

   Alteracoes: 14/11/2003 - Alteracao na atualizacao do numero do livro no
                            crapcop, vai atualizar somente apos a impressao
                            dos lancamento. (Julio).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "for each" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               27/04/2009 - Acertar logica de FOR EACH que utiliza OR (David).

               18/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

.............................................................................*/

  BEGIN
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

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
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

    vr_rel_nmcooper := rw_crapcop.nmextcop;
    vr_rel_dtterabr := pr_dtperini;
    vr_dtperini     := pr_dtperini;
    vr_dtperfim     := pr_dtperfim;
    vr_rel_contapag := 1;
    vr_rel_linhastr := '    ********** **** *** ********** *********************************** '||
                       '*********** ******** ********** ************** *************';

    -- Carrega a tabela de memoria CRAPASS
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
    END LOOP;

    -- Carrega a tabela de memoria CRAPAGE
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_tab_crapage(rw_crapage.cdagenci).cdcxaage := rw_crapage.cdcxaage;
      vr_tab_crapage(rw_crapage.cdagenci).nmextage := rw_crapage.nmextage;
    END LOOP;

    -- Inicializar o CLOB
    vr_des_clob := null;
    dbms_lob.createtemporary(vr_des_clob, true);
    dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);

    vr_des_clob_2 := null;
    dbms_lob.createtemporary(vr_des_clob_2, true);
    dbms_lob.open(vr_des_clob_2, dbms_lob.lob_readwrite);

    -- Define o titulo do relatorio
    IF  upper(pr_nmestrut) = 'CRAPLCM'  THEN
      vr_rel_tpdrazao := 'DEPOSITOS A VISTA';
    ELSIF upper(pr_nmestrut) = 'CRAPLEM' THEN
      vr_rel_tpdrazao := 'EMPRESTIMOS';
    ELSIF upper(pr_nmestrut) = 'CRAPLCT' THEN
      vr_rel_tpdrazao := 'CAPITAL';
    ELSIF upper(pr_nmestrut) = 'CRAPLAP' AND upper(pr_nmestrut_aux) = 'CRAPLPP'   THEN
      vr_rel_tpdrazao := 'APLICACOES';
    END IF;

    /*------------------------ Efetua a abertura do arquivo --------------------------------------*/
    IF    upper(pr_nmestrut) = 'CRAPLCM' THEN
       vr_rel_nrdlivro := rw_crapcop.nrlivdpv;
    ELSIF upper(pr_nmestrut) = 'CRAPLEM' THEN
       vr_rel_nrdlivro := rw_crapcop.nrlivepr;
    ELSIF upper(pr_nmestrut) = 'CRAPLCT' THEN
       vr_rel_nrdlivro := rw_crapcop.nrlivcap;
    ELSIF upper(pr_nmestrut) = 'CRAPLAP' AND upper(pr_nmestrut_aux) = 'CRAPLPP'   THEN
       vr_rel_nrdlivro := rw_crapcop.nrlivapl;
    END IF;

    -- Atualiza a tabela de cooperativa com a numeracao dos livros
    BEGIN
      UPDATE crapcop a
         SET a.nrlivdpv = nrlivdpv + decode(upper(pr_nmestrut),'CRAPLCM',1,0),
             a.nrlivepr = nrlivepr + decode(upper(pr_nmestrut),'CRAPLEM',1,0),
             a.nrlivcap = nrlivcap + decode(upper(pr_nmestrut),'CRAPLCT',1,0),
             a.nrlivapl = nrlivapl + decode(upper(pr_nmestrut),'CRAPLAP',
                                       decode(upper(pr_nmestrut_aux),'CRAPLPP',1,0),0)
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCOP: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    /*------------------------ Efetua o corpo do arquivo --------------------------------------*/

    -- efetua o loop dia a dia da data inicial ate a data final
    FOR vr_dia IN to_char(pr_dtperini,'dd')..to_char(pr_dtperfim,'dd') LOOP

      vr_contdata := to_date(to_char(pr_dtperini,'YYYYMM')||to_char(vr_dia,'00'),'YYYYMMDD');
      -- Define a query do cursor dinâmico
      vr_cursor := 'select x.cdcooper,'||
                         ' x.cdhistor,'||
                         ' x.dtmvtolt,'||
                         ' x.nrdconta,'||
                         ' x.vllanmto,'||
                         ' x.cdagenci,'||
                         ' x.cdbccxlt,'||
                         ' x.nrdocmto,'||
                         ' x.'||pr_nmcampocta||' pr_nmcampocta '||
                    ' from '||pr_nmestrut||' x '||
                   ' where x.cdcooper = '||pr_cdcooper||
                     ' and rownum < 2 ' ||
                     ' and x.dtmvtolt = to_date('''||to_char(vr_contdata, 'ddmmyyyy')||''', ''ddmmyyyy'')';
      -- Cria cursor dinâmico
      vr_num_cursor := dbms_sql.open_cursor;

      -- Comando Parse
      dbms_sql.parse(vr_num_cursor, vr_cursor, 1);

      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_cdcooper);
      dbms_sql.define_column(vr_num_cursor, 2, vr_cdhistor);
      dbms_sql.define_column(vr_num_cursor, 3, vr_dtmvtolt);
      dbms_sql.define_column(vr_num_cursor, 4, vr_nrdconta);
      dbms_sql.define_column(vr_num_cursor, 5, vr_vllanmto);
      dbms_sql.define_column(vr_num_cursor, 6, vr_cdagenci);
      dbms_sql.define_column(vr_num_cursor, 7, vr_cdbccxlt);
      dbms_sql.define_column(vr_num_cursor, 8, vr_nrdocmto);
      dbms_sql.define_column(vr_num_cursor, 9, vr_campocta);

      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);
      -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
      vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
      -- Fecha o mesmo
      dbms_sql.close_cursor(vr_num_cursor);
      -- Verifica se há alguma linha de retorno do cursor
      if vr_num_retor = 0 THEN
        -- Define a query do cursor dinâmico
        vr_cursor_aux := 'select x.cdcooper,'||
                               ' x.cdhistor,'||
                               ' x.dtmvtolt,'||
                               ' x.nrdconta,'||
                               ' x.vllanmto,'||
                               ' x.cdagenci,'||
                               ' x.cdbccxlt,'||
                               ' x.nrdocmto,'||
                               ' x.'||pr_nmcampocta||' pr_nmcampocta '||
                          ' from '||pr_nmestrut_aux||' x '||
                         ' where x.cdcooper = '||pr_cdcooper||
                           ' and rownum < 2 ' ||
                           ' and x.dtmvtolt = to_date('''||to_char(vr_contdata, 'ddmmyyyy')||''', ''ddmmyyyy'')';
        -- Cria cursor dinâmico
        vr_num_cursor_aux := dbms_sql.open_cursor;

        -- Comando Parse
        dbms_sql.parse(vr_num_cursor_aux, vr_cursor_aux, 1);

        -- Definindo Colunas de retorno
        dbms_sql.define_column(vr_num_cursor_aux, 1, vr_cdcooper);
        dbms_sql.define_column(vr_num_cursor_aux, 2, vr_cdhistor);
        dbms_sql.define_column(vr_num_cursor_aux, 3, vr_dtmvtolt);
        dbms_sql.define_column(vr_num_cursor_aux, 4, vr_nrdconta);
        dbms_sql.define_column(vr_num_cursor_aux, 5, vr_vllanmto);
        dbms_sql.define_column(vr_num_cursor_aux, 6, vr_cdagenci);
        dbms_sql.define_column(vr_num_cursor_aux, 7, vr_cdbccxlt);
        dbms_sql.define_column(vr_num_cursor_aux, 8, vr_nrdocmto);
        dbms_sql.define_column(vr_num_cursor_aux, 9, vr_campocta);

        -- Execução do select dinamico
        vr_num_retor_aux := dbms_sql.execute(vr_num_cursor_aux);
        -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
        vr_num_retor_aux := dbms_sql.fetch_rows(vr_num_cursor_aux);
        -- Fecha o mesmo
        dbms_sql.close_cursor(vr_num_cursor_aux);
        -- Verifica se há alguma linha de retorno do cursor
        if vr_num_retor_aux = 0 THEN
          continue; -- Volta para o inicio do loop
        END IF;
      END IF;

      -- Gera o cabeacalho do dia
      pc_gera_razao_dtl(vr_contdata);

      -- Busca os dados do historico do sistema
      FOR rw_craphis IN cr_craphis(pr_cdcooper, pr_nmestrut, pr_nmestrut_aux) LOOP

        IF rw_craphis.cdhistor = 1168 THEN
          dbms_output.put_line('teste');
        END IF;
        vr_rel_cdhistor := rw_craphis.cdhistor;
        vr_rel_dshistor := rw_craphis.dsexthst;
        vr_rel_nrctadeb := rw_craphis.nrctadeb;
        vr_rel_nrctacrd := rw_craphis.nrctacrd;
        vr_histcred     := upper(rw_craphis.indebcre) = 'C';
        vr_tpctbcxa     := rw_craphis.tpctbcxa;

        -- Define a query do cursor dinâmico
        vr_cursor := 'select x.cdcooper,'||
                           ' x.cdhistor,'||
                           ' x.dtmvtolt,'||
                           ' x.nrdconta,'||
                           ' x.vllanmto,'||
                           ' x.cdagenci,'||
                           ' x.cdbccxlt,'||
                           ' x.nrdocmto,'||
                           ' x.'||pr_nmcampocta||' pr_nmcampocta '||
                      ' from '||pr_nmestrut||' x '||
                     ' where x.cdcooper = '||pr_cdcooper||
                       ' and x.cdhistor = '||vr_rel_cdhistor||
                       ' and x.dtmvtolt = to_date('''||to_char(vr_contdata, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                       ' order by x.cdagenci, x.nrdconta, x.nrdocmto, x.vllanmto';
        -- Cria cursor dinâmico
        vr_num_cursor := dbms_sql.open_cursor;

        -- Comando Parse
        dbms_sql.parse(vr_num_cursor, vr_cursor, 1);

        -- Definindo Colunas de retorno
        dbms_sql.define_column(vr_num_cursor, 1, vr_cdcooper);
        dbms_sql.define_column(vr_num_cursor, 2, vr_cdhistor);
        dbms_sql.define_column(vr_num_cursor, 3, vr_dtmvtolt);
        dbms_sql.define_column(vr_num_cursor, 4, vr_nrdconta);
        dbms_sql.define_column(vr_num_cursor, 5, vr_vllanmto);
        dbms_sql.define_column(vr_num_cursor, 6, vr_cdagenci);
        dbms_sql.define_column(vr_num_cursor, 7, vr_cdbccxlt);
        dbms_sql.define_column(vr_num_cursor, 8, vr_nrdocmto);
        dbms_sql.define_column(vr_num_cursor, 9, vr_campocta);

        -- Execução do select dinamico
        vr_num_retor := dbms_sql.execute(vr_num_cursor);
        -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
        vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
        -- Fecha o mesmo
        dbms_sql.close_cursor(vr_num_cursor);
        -- Verifica se há alguma linha de retorno do cursor
        if vr_num_retor = 0 THEN
          -- Define a query do cursor dinâmico
          vr_cursor_aux := 'select x.cdcooper,'||
                                 ' x.cdhistor,'||
                                 ' x.dtmvtolt,'||
                                 ' x.nrdconta,'||
                                 ' x.vllanmto,'||
                                 ' x.cdagenci,'||
                                 ' x.cdbccxlt,'||
                                 ' x.nrdocmto,'||
                                 ' x.'||pr_nmcampocta||' pr_nmcampocta '||
                            ' from '||pr_nmestrut_aux||' x '||
                           ' where x.cdcooper = '||pr_cdcooper||
                             ' and x.cdhistor = '||vr_rel_cdhistor||
                             ' and x.dtmvtolt = to_date('''||to_char(vr_contdata, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                             ' order by x.cdagenci, x.nrdconta, x.nrdocmto, x.vllanmto';
          -- Cria cursor dinâmico
          vr_num_cursor_aux := dbms_sql.open_cursor;

          -- Comando Parse
          dbms_sql.parse(vr_num_cursor_aux, vr_cursor_aux, 1);

          -- Definindo Colunas de retorno
          dbms_sql.define_column(vr_num_cursor_aux, 1, vr_cdcooper);
          dbms_sql.define_column(vr_num_cursor_aux, 2, vr_cdhistor);
          dbms_sql.define_column(vr_num_cursor_aux, 3, vr_dtmvtolt);
          dbms_sql.define_column(vr_num_cursor_aux, 4, vr_nrdconta);
          dbms_sql.define_column(vr_num_cursor_aux, 5, vr_vllanmto);
          dbms_sql.define_column(vr_num_cursor_aux, 6, vr_cdagenci);
          dbms_sql.define_column(vr_num_cursor_aux, 7, vr_cdbccxlt);
          dbms_sql.define_column(vr_num_cursor_aux, 8, vr_nrdocmto);
          dbms_sql.define_column(vr_num_cursor_aux, 9, vr_campocta);

          -- Execução do select dinamico
          vr_num_retor_aux := dbms_sql.execute(vr_num_cursor_aux);
          -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
          vr_num_retor_aux := dbms_sql.fetch_rows(vr_num_cursor_aux);
          -- Fecha o mesmo
          dbms_sql.close_cursor(vr_num_cursor_aux);
          -- Verifica se há alguma linha de retorno do cursor
          if vr_num_retor_aux = 0 THEN
            continue; -- Volta para o inicio do loop;
          END IF;
        END IF;

        vr_existe_dados := TRUE;

        -- gera o cabecalho de historico
        pc_gera_razao_his;

        IF vr_num_retor > 0 THEN
          -- gera as linhas de detalhes com base na primeira tabela
          pc_gera_razao_det(pr_cdcooper, vr_cursor, rw_craphis.nrctacrd, rw_craphis.nrctadeb);
        ELSE
          -- gera as linhas de detalhes com base na tabela auxiliar
          pc_gera_razao_det(pr_cdcooper, vr_cursor_aux, rw_craphis.nrctacrd, rw_craphis.nrctadeb);
        END IF;

        -- gera a linha de total do historico
        pc_gera_razao_tot;

      END LOOP; -- loop do craphis

      IF upper(pr_nmestrut) = 'CRAPLEM' THEN
        -- Busca os cheques contidos do Bordero de desconto de cheques
        OPEN cr_crapcdb(pr_cdcooper, vr_contdata);
        FETCH cr_crapcdb INTO rw_crapcdb;
        IF cr_crapcdb%FOUND THEN
          vr_rel_cdhistor := 9998;
          vr_rel_dshistor := 'DEBITO DESCONTO DE CHEQUES';
          vr_rel_nrctadeb := 1641;
          vr_rel_nrctacrd := 4954;
          vr_histcred     := FALSE;

          -- Lista os lancamentos de cheques
          pc_gera_razao_chq(pr_cdcooper);

          vr_rel_cdhistor := 9999;
          vr_rel_dshistor := 'CREDITO DESCONTO DE CHEQUES';
          vr_rel_nrctadeb := 4954;
          vr_rel_nrctacrd := 1642;
          vr_histcred     := TRUE;

          -- Lista os lancamentos de cheques
          pc_gera_razao_chq(pr_cdcooper);
        END IF;
        CLOSE cr_crapcdb;
      END IF;          /*  Fim IF craplem  */

      -- Gera a linha de total do dia
      pc_gera_razao_dat;
      vr_rel_ttcrddia := 0;
      vr_rel_ttdebdia := 0;

    END LOOP; /* Fim do LOOP vr_contdata */

    -- Verifica se existe informacao gerada
    IF vr_existe_dados THEN

      pc_gera_razao_nul;
      vr_rel_contapag := vr_rel_contapag + 1;

      -- Cria o termo de abertura
      pc_gera_razao_abr('00001','TERMO DE ABERTURA');

      vr_rel_dtterabr := pr_dtperfim;

      -- Cria o termo de encerramento
      pc_gera_razao_abr(to_char(vr_rel_contapag),'TERMO DE ENCERRAMENTO');

      -- Fecha o arquivo XML
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo,
                             '',TRUE);

      -- Concatena o termo de abertura no CLOB principal
      dbms_lob.append(vr_des_clob_2, vr_des_clob);

      gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                                  --> Cooperativa conectada
                                         ,pr_cdprogra  => 'CRPS358'                                    --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                          --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_clob_2                                --> Arquivo CLOB de dados
                                         ,pr_cdrelato  => '359'                                        --> Código do relatório
                                         ,pr_dsarqsaid => pr_nmarquiv                                  --> Arquivo final com o path
                                         ,pr_flg_gerar => 'S'                                          --> Geraçao na hora
                                         ,pr_des_erro  => vr_dscritic);                                --> Saída com erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Converte o relatorio para um arquivo temporario para o formato DOS
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos ' ||pr_nmarquiv || ' > '||pr_nmarquiv||'.dos' ||' 2> /dev/null');

      -- Move o arquivo temporario para o arquivo do relatorio
      gene0001.pc_oscommand_shell(pr_des_comando => 'mv ' ||pr_nmarquiv||'.dos ' || pr_nmarquiv);

    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
  END;

END COBR0002;
/

