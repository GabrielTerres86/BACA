CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS465(pr_cdcooper   IN  crapcop.cdcooper%TYPE   --> Cooperativa
                                      ,pr_flgresta   IN PLS_INTEGER            --> Indicador para utiliza��o de restart
                                      ,pr_stprogra  OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                      ,pr_infimsol  OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                      ,pr_cdcritic  OUT NUMBER                  --> C�digo cr�tica
                                      ,pr_dscritic  OUT VARCHAR2) IS            --> Descri��o cr�tica
BEGIN
  /*.............................................................................

   Programa: PC_CRPS465                Antigo: Fontes/crps465.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego/Elton
   Data    : Junho/2006                        Ultima atualizacao: 14/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Relatorio dos 100 maiores avalistas/fiadores

   Alteracoes: 04/07/2006 - Alterado FORMAT dos campos Saldo e Total (Diego).

               16/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).

               11/07/2013 - Convers�o Progress >> PL/SQL (Oracle). Petter - Supero.

               25/11/2013 - Limpar parametros de saida de critica no caso da
                            exce��o vr_exc_fimprg (Marcos-Supero)

               14/01/2014 - Corre��o no tamanho do campo typ_reg_devedores>>>nmdavali
                            pois estava com 40 caracteres e pode receber o nome do
                            avalista da crapavt que tem at� 50 caracteres
                            (Marcos-Supero)

.............................................................................*/
  DECLARE
    /* �rea de PL Table */
    -- PL Table para armazenar informa��es de devedores
    TYPE typ_reg_devedores IS
      RECORD(cdagenci PLS_INTEGER
            ,nrdconta PLS_INTEGER
            ,nmdavali VARCHAR2(50)
            ,nrctremp PLS_INTEGER
            ,nrcpfcg1 VARCHAR2(18)
            ,nrctava1 PLS_INTEGER
            ,tpctrato PLS_INTEGER
            ,dstpctra VARCHAR2(12)
            ,slddeved NUMBER(15,2));

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_devedores IS TABLE OF typ_reg_devedores INDEX BY VARCHAR2(800);

    -- PL Table para armazenar informa��es da tabela CRAWEPR
    TYPE typ_reg_crawepr IS
      RECORD(nrdconta crawepr.nrdconta%TYPE
            ,nrctremp crawepr.nrctremp%TYPE
            ,nrctaav1 crawepr.nrctaav1%TYPE
            ,nrctaav2 crawepr.nrctaav2%TYPE);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY VARCHAR2(80);

    -- PL Table para armazenar informa��es da tabela CRAPAVT
    TYPE typ_reg_crapavt IS
      RECORD(nmdavali crapavt.nmdavali%TYPE
            ,nrcpfcgc crapavt.nrcpfcgc%TYPE
            ,tpctrato crapavt.tpctrato%TYPE
            ,nrdconta crapavt.nrdconta%TYPE
            ,nrctremp crapavt.nrctremp%TYPE);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_crapavt IS TABLE OF typ_reg_crapavt INDEX BY VARCHAR2(80);

    -- PL Table para armazenar informa��es da tabela CRAPASS
    TYPE typ_reg_crapass IS
      RECORD(nrdconta crapass.nrdconta%TYPE
            ,inpessoa crapass.inpessoa%TYPE
            ,cdagenci crapass.cdagenci%TYPE
            ,nmprimtl crapass.nmprimtl%TYPE
            ,nrcpfcgc crapass.nrcpfcgc%TYPE);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(80);

    -- PL Table para armazenar informa��es da tabela CRAPLIM
    TYPE typ_reg_craplim IS
      RECORD(nrdconta craplim.nrdconta%TYPE
            ,nrctrlim craplim.nrctrlim%TYPE
            ,tpctrlim craplim.tpctrlim%TYPE
            ,nrctaav1 craplim.nrctaav1%TYPE
            ,nrctaav2 craplim.nrctaav2%TYPE
            ,cddlinha craplim.cddlinha%TYPE
            ,ordem    PLS_INTEGER);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_craplim IS TABLE OF typ_reg_craplim INDEX BY VARCHAR2(80);

    -- PL Table para armazenar informa��es da tabela CRAPEPR e CRAPLCR
    TYPE typ_reg_lincre IS
      RECORD(cdlcremp crapepr.cdlcremp%TYPE
            ,dslcremp craplcr.dslcremp%TYPE
            ,nrctremp crapepr.nrctremp%TYPE
            ,nrdconta crapepr.nrdconta%TYPE
            ,ordem    PLS_INTEGER);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_lincre IS TABLE OF typ_reg_lincre INDEX BY VARCHAR2(80);

    -- PL Table para armazenar informa��es da tabela CRAPLDC
    TYPE typ_reg_crapldc IS
      RECORD(cddlinha crapldc.cddlinha%TYPE
            ,dsdlinha crapldc.dsdlinha%TYPE);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_crapldc IS TABLE OF typ_reg_crapldc INDEX BY VARCHAR2(80);

    /* Area de vari�veis */
    vr_nmarqimp       VARCHAR2(400);               --> Nome do arquivo de impress�o
    vr_nmformul       VARCHAR2(400);               --> Nome do formul�rio
    vr_nrdconta       crawepr.nrdconta%TYPE;       --> N�mero da conta
    vr_tpctrato       PLS_INTEGER;                 --> Tipo de contrato
    vr_contador       PLS_INTEGER;                 --> Contador
    vr_somacpf        NUMBER(15,2);                --> Soma do CPF
    vr_cdlincrd       PLS_INTEGER;                 --> C�digo linha de cr�dito
    vr_dslincrd       VARCHAR2(20);                --> Descri��o linha de cr�dito
    vr_lindcred       VARCHAR2(26);                --> Linha de cr�dito
    vr_cdprogra       VARCHAR2(40);                --> Nome do programa
    vr_nom_dir        VARCHAR2(4000);              --> Nome do diret�rio para relat�rio
    vr_exc_saida      EXCEPTION;                   --> Controle de exce��o
    rw_crapdat        btch0001.cr_crapdat%ROWTYPE; --> Tipo para receber o fetch de dados
    vr_exc_fimprg     EXCEPTION;                   --> Controle para finaliza��o
    vr_tab_devedores  typ_tab_devedores;           --> PL Table para devedores
    vr_tab_devedores2 typ_tab_devedores;           --> PL Table para devedores (novos)
    vr_tab_crawepr    typ_tab_crawepr;             --> PL Table para armazenar tabela CRAWEPR
    vr_tab_crapavt    typ_tab_crapavt;             --> PL Table para armazenar tabela CRAPAVT
    vr_index          VARCHAR2(256);               --> Vari�vel para �ndice de carga das PL Table�s de dados
    vr_tab_crapass    typ_tab_crapass;             --> PL Table para armazenar tabela CRAPASS
    vr_tab_craplim    typ_tab_craplim;             --> PL Table para armazenar tabela CRAPLIM
    vr_crawepr        VARCHAR(100);                --> �ndice para PL Table CRAWEPR
    vr_crapavt        VARCHAR(100);                --> �ndice para PL Table CRAPAVT
    vr_cindex         PLS_INTEGER := 0;            --> �ndice para gerar devedores
    vr_vindex         VARCHAR2(80);                --> �ndice para gerar devedores (�ndice total)
    vr_craplim        VARCHAR2(100);               --> �ndice para PL Table CRAPLIM
    vr_cindexfim      VARCHAR2(80);                --> �ndice para gerar devedores
    vr_inxctrl        BOOLEAN := FALSE;            --> Controle para pontuar indice de marca��o
    vr_tab_lincre     typ_tab_lincre;              --> PL Table para armazenar tabela CRAPEPR e CRAPLCR
    vr_tab_crapldc    typ_tab_crapldc;             --> PL Table para armazenar tabela CRAPLDC
    vr_xml            CLOB;                        --> Vari�vel para armazenar XML
    vr_bxml           VARCHAR2(32767);             --> Vari�vel para criar buffer para CLOB do XML
    vr_idxxml         VARCHAR2(300);               --> �ndice para construir XML
    vr_idxtemp        VARCHAR2(300);               --> �ndice para construir XML
    vr_devconta       VARCHAR2(15);                --> �ndice de busca por conta
    vr_devtremp       VARCHAR2(30);                --> �ndice de busca por contrato

    /* Busca dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dados saldos devedores de emprestimos, desconto de cheques e custodia de cheques */
    CURSOR cr_crapsdv(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cs.tpdsaldo
            ,cs.nrdconta
            ,cs.nrctrato
            ,cs.vldsaldo
            ,cs.dtmvtolt
      FROM crapsdv cs
      WHERE cs.cdcooper = pr_cdcooper
      ORDER BY cs.CDCOOPER, cs.NRDCONTA, cs.DTMVTOLT, cs.TPDSALDO, cs.NRCTRATO;

    /* Busca dados do cadastro auxiliar de emprestimos */
    CURSOR cr_crawepr(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cw.nrdconta
            ,cw.nrctremp
            ,cw.nrctaav1
            ,cw.nrctaav2
      FROM crawepr cw
      WHERE cw.cdcooper = pr_cdcooper
        AND cw.nrdconta = cw.nrdconta
        AND cw.nrctremp = cw.nrctremp;

    /* Busca dados do cadastro de avalistas terceiros, contatos da pessoa fisica e referencias comerciais e bancarias da pessoa juridica */
    CURSOR cr_crapavt(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT REPLACE(REPLACE(REPLACE(cv.nmdavali, Chr(38), Chr(38)||'AMP;'), '"', Chr(38)||'QUOT;'), '''', Chr(38)||'APOS;') nmdavali
            ,cv.nrcpfcgc
            ,cv.tpctrato
            ,cv.nrdconta
            ,cv.nrctremp
      FROM crapavt cv
      WHERE cv.cdcooper = pr_cdcooper
      ORDER BY cv.progress_recid;

    /* Busca dados dos associados */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cs.nrdconta
            ,cs.inpessoa
            ,cs.cdagenci
            ,REPLACE(REPLACE(REPLACE(cs.nmprimtl, Chr(38), Chr(38)||'AMP;'), '"', Chr(38)||'QUOT;'), '''', Chr(38)||'APOS;') nmprimtl
            ,cs.nrcpfcgc
      FROM crapass cs
      WHERE cs.cdcooper = pr_cdcooper;

    /* Busca dados dos contratos de limite de cr�dito */
    CURSOR cr_craplim(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cm.nrdconta
            ,cm.nrctrlim
            ,cm.tpctrlim
            ,cm.nrctaav1
            ,cm.nrctaav2
            ,cm.cddlinha
      FROM craplim cm
      WHERE cm.cdcooper = pr_cdcooper
      ORDER BY cm.cddlinha DESC;

      /* Busca dados da descri��o da linha de cr�dito */
      CURSOR cr_linhacredito(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
        SELECT cr.cdlcremp
              ,cl.dslcremp
              ,cr.nrctremp
              ,cr.nrdconta
        FROM crapepr cr, craplcr cl
        WHERE cr.cdcooper = cl.cdcooper
          AND cr.cdlcremp = cl.cdlcremp
          AND cr.cdcooper = pr_cdcooper
        ORDER BY cr.cdlcremp DESC;

    /* Busca dados da descri��o da linha */
    CURSOR cr_crapldc(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cd.cddlinha
            ,cd.dsdlinha
      FROM crapldc cd
      WHERE cd.cdcooper = pr_cdcooper
        AND cd.tpdescto = 2;

    -- Procedure para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2                --> String que ser� adicionada ao CLOB
                        ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que ir� receber a string
    BEGIN
      dbms_lob.writeappend(pr_clob, length(pr_des_dados), pr_des_dados);
    END pc_xml_tag;

    -- Procedure para limpar o buffer da vari�vel e imprimir seu conte�do para o CLOB
    PROCEDURE pc_limpa_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Vari�vel com o conte�do de buffer
                             ,pr_str     IN OUT NOCOPY CLOB) AS   --> Vari�vel CLOB que ir� receber o buffer
    BEGIN
      IF LENGTH(pr_buffer) >= 32500 THEN     -- Renato Darosci - 14/01/2014 - Ajuste de 32650 para 32500
        pc_xml_tag(pr_buffer, pr_str);
        pr_buffer := '';
      END IF;
    END pc_limpa_buffer;

    -- Procedure para finalizar a execu��o do buffer e imprimir seu conte�do no CLOB
    PROCEDURE pc_final_buffer(pr_buffer  IN OUT NOCOPY VARCHAR2   --> Vari�vel com o conte�do de buffer
                             ,pr_str     IN OUT NOCOPY CLOB) AS   --> Vari�vel CLOB que ir� receber o buffer
    BEGIN
      pc_xml_tag(pr_buffer, pr_str);
      pr_buffer := '';
    END pc_final_buffer;

    -- Procedure para criar registros na pesquisa de avalistas
    PROCEDURE pc_pesquisa_crawepr_avalistas(pr_nrdconta IN crawepr.nrdconta%TYPE      --> N�mero da conta
                                           ,pr_nrctremp IN crawepr.nrctremp%TYPE      --> N�mero de contrato
                                           ,pr_vldsaldo IN crapsdv.vldsaldo%TYPE      --> Valor de saldo
                                           ,pr_contactr IN crawepr.nrdconta%TYPE) IS  --> N�mero da conta para pesquisa
    BEGIN
      -- Verifica se existe registro
      IF vr_tab_crapass.exists(lpad(pr_contactr, 15, '0')) THEN
        -- Verifica tipo da pessoa
        IF vr_tab_crapass(lpad(pr_contactr, 15, '0')).inpessoa <> 3 THEN
          -- Gerar �ndice para a PL Table
          vr_cindex := vr_cindex + 1;
          vr_vindex := lpad(vr_tab_crapass(lpad(pr_contactr, 15, '0')).nrcpfcgc, 20, '0') || lpad(vr_cindex, 50, '0');

          -- Cria registros de devedores na PL Table
          vr_tab_devedores(vr_vindex).cdagenci := vr_tab_crapass(lpad(pr_contactr, 15, '0')).cdagenci;
          vr_tab_devedores(vr_vindex).nrdconta := pr_nrdconta;
          vr_tab_devedores(vr_vindex).nrctremp := pr_nrctremp;
          vr_tab_devedores(vr_vindex).nmdavali := substr(vr_tab_crapass(lpad(pr_contactr, 15, '0')).nmprimtl, 0, 40);
          vr_tab_devedores(vr_vindex).nrctava1 := pr_contactr;
          vr_tab_devedores(vr_vindex).nrcpfcg1 := vr_tab_crapass(lpad(pr_contactr, 15, '0')).nrcpfcgc;
          vr_tab_devedores(vr_vindex).tpctrato := 1;
          vr_tab_devedores(vr_vindex).slddeved := pr_vldsaldo;
        END IF;
      END IF;
    END pc_pesquisa_crawepr_avalistas;

    -- Procedure para criar registros na pesquisa de avalistas (CRAPLIM)
    PROCEDURE pc_pesquisa_craplim_avalistas(pr_contactr IN craplim.nrdconta%TYPE      --> N�mero da conta para pesquisa
                                           ,pr_nrdconta IN craplim.nrdconta%TYPE      --> N�mero da conta
                                           ,pr_nrctrlim IN craplim.nrctrlim%TYPE      --> N�mero de contrato
                                           ,pr_tpctrato IN PLS_INTEGER                --> Tipo de contrato
                                           ,pr_vldsaldo IN crapsdv.vldsaldo%TYPE) IS  --> --> Valor de saldo
    BEGIN
      -- Verifica se existe registro
      IF vr_tab_crapass.exists(lpad(pr_contactr, 15, '0')) THEN
        -- Verifica tipo da pessoa
        IF vr_tab_crapass(lpad(pr_contactr, 15, '0')).inpessoa <> 3 THEN
          -- Gerar �ndice para a PL Table
          vr_cindex := vr_cindex + 1;
          vr_vindex := lpad(vr_tab_crapass(lpad(pr_contactr, 15, '0')).nrcpfcgc, 20, '0') || lpad(vr_cindex, 50, '0');

          -- Cria registros de devedores na PL Table
          vr_tab_devedores(vr_vindex).cdagenci := vr_tab_crapass(lpad(pr_contactr, 15, '0')).cdagenci;
          vr_tab_devedores(vr_vindex).nrdconta := pr_nrdconta;
          vr_tab_devedores(vr_vindex).nrctremp := pr_nrctrlim;
          vr_tab_devedores(vr_vindex).nmdavali := substr(vr_tab_crapass(lpad(pr_contactr, 15, '0')).nmprimtl, 0, 40);
          vr_tab_devedores(vr_vindex).nrctava1 := pr_contactr;
          vr_tab_devedores(vr_vindex).nrcpfcg1 := vr_tab_crapass(lpad(pr_contactr, 15, '0')).nrcpfcgc;
          vr_tab_devedores(vr_vindex).tpctrato := pr_tpctrato;
          vr_tab_devedores(vr_vindex).slddeved := pr_vldsaldo;
        END IF;
      END IF;
    END pc_pesquisa_craplim_avalistas;

  BEGIN
    -- C�digo do programa
    vr_cdprogra := 'CRPS465';
    vr_nmarqimp := 'crrl440.lst';

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS465'
                              ,pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Valida��es iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => pr_cdcritic);

    -- Se a variavel de erro � <> 0
    IF pr_cdcritic <> 0 THEN
      -- Buscar descri��o da cr�tica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    --Posicionar no proximo registro
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    --Fechar Cursor
    CLOSE btch0001.cr_crapdat;

    -- Se pr�xima data de movimento estiver no m�s atual
    IF to_char(rw_crapdat.dtmvtopr, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
      RAISE vr_exc_fimprg;
    END IF;

    -- Carregar PL Table
    vr_contador := 0;
    vr_index := NULL;
    FOR rw_crawepr IN cr_crawepr(pr_cdcooper) LOOP
      -- Cria �ndice para a PL Table
      IF vr_index IS NULL THEN
        vr_index := lpad(rw_crawepr.nrdconta, 15, '0') || lpad(rw_crawepr.nrctremp, 30, '0');
      ELSE
        IF vr_index <> lpad(rw_crawepr.nrdconta, 15, '0') || lpad(rw_crawepr.nrctremp, 30, '0') THEN
          vr_contador := 0;
          vr_index := lpad(rw_crawepr.nrdconta, 15, '0') || lpad(rw_crawepr.nrctremp, 30, '0');
        END IF;
      END IF;

      vr_tab_crawepr(vr_index || lpad(vr_contador, 10, '0')).nrdconta := rw_crawepr.nrdconta;
      vr_tab_crawepr(vr_index || lpad(vr_contador, 10, '0')).nrctremp := rw_crawepr.nrctremp;
      vr_tab_crawepr(vr_index || lpad(vr_contador, 10, '0')).nrctaav1 := rw_crawepr.nrctaav1;
      vr_tab_crawepr(vr_index || lpad(vr_contador, 10, '0')).nrctaav2 := rw_crawepr.nrctaav2;

      -- Incrementar �ndice
      vr_contador := vr_contador + 1;
    END LOOP;

    -- Carregar PL Table
    vr_contador := 0;
    vr_index := NULL;
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper) LOOP
      -- Cria �ndice para a PL Table
      IF vr_index IS NULL THEN
        vr_index := lpad(rw_crapavt.nrdconta, 15, '0') || lpad(rw_crapavt.nrctremp, 30, '0') || lpad(rw_crapavt.tpctrato, 5, '0');
      ELSE
        IF vr_index <> lpad(rw_crapavt.nrdconta, 15, '0') || lpad(rw_crapavt.nrctremp, 30, '0') || lpad(rw_crapavt.tpctrato, 5, '0') THEN
          vr_contador := 0;
          vr_index := lpad(rw_crapavt.nrdconta, 15, '0') || lpad(rw_crapavt.nrctremp, 30, '0') || lpad(rw_crapavt.tpctrato, 5, '0');
        END IF;
      END IF;

      vr_tab_crapavt(vr_index || lpad(vr_contador, 10, '0')).nmdavali := rw_crapavt.nmdavali;
      vr_tab_crapavt(vr_index || lpad(vr_contador, 10, '0')).nrcpfcgc := rw_crapavt.nrcpfcgc;
      vr_tab_crapavt(vr_index || lpad(vr_contador, 10, '0')).tpctrato := rw_crapavt.tpctrato;
      vr_tab_crapavt(vr_index || lpad(vr_contador, 10, '0')).nrdconta := rw_crapavt.nrdconta;
      vr_tab_crapavt(vr_index || lpad(vr_contador, 10, '0')).nrctremp := rw_crapavt.nrctremp;

      -- Incrementar �ndice
      vr_contador := vr_contador + 1;
    END LOOP;

    -- Carregar PL Table
    vr_contador := 0;
    vr_index := NULL;
    FOR rw_craplim IN cr_craplim(pr_cdcooper) LOOP
      -- Cria �ndice para a PL Table
      IF vr_index IS NULL THEN
        vr_index := lpad(rw_craplim.nrdconta, 15, '0') || lpad(rw_craplim.nrctrlim, 30, '0') || lpad(rw_craplim.tpctrlim, 5, '0');
      ELSE
        IF vr_index <> lpad(rw_craplim.nrdconta, 15, '0') || lpad(rw_craplim.nrctrlim, 30, '0') || lpad(rw_craplim.tpctrlim, 5, '0') THEN
          vr_contador := 0;
          vr_index := lpad(rw_craplim.nrdconta, 15, '0') || lpad(rw_craplim.nrctrlim, 30, '0') || lpad(rw_craplim.tpctrlim, 5, '0');
        END IF;
      END IF;

      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).nrdconta := rw_craplim.nrdconta;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).nrctrlim := rw_craplim.nrctrlim;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).tpctrlim := rw_craplim.tpctrlim;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).nrctaav1 := rw_craplim.nrctaav1;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).nrctaav2 := rw_craplim.nrctaav2;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).cddlinha := rw_craplim.cddlinha;
      vr_tab_craplim(vr_index || lpad(vr_contador, 10, '0')).ordem := vr_contador;

      -- Incrementar �ndice
      vr_contador := vr_contador + 1;
    END LOOP;

    -- Carregar PL Table
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).nrdconta := rw_crapass.nrdconta;
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).inpessoa := rw_crapass.inpessoa;
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).cdagenci := rw_crapass.cdagenci;
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).nmprimtl := rw_crapass.nmprimtl;
      vr_tab_crapass(lpad(rw_crapass.nrdconta, 15, '0')).nrcpfcgc := rw_crapass.nrcpfcgc;
    END LOOP;

    -- Carregar PL Table
    vr_contador := 0;
    FOR rw_linhacredito IN cr_linhacredito(pr_cdcooper) LOOP
      -- Incrementar ordenador para criar �ndice na PL Table de ordenamento
      vr_contador := vr_contador + 1;

      vr_tab_lincre(lpad(rw_linhacredito.nrdconta, 15, '0') || lpad(rw_linhacredito.nrctremp, 30, '0')).cdlcremp := rw_linhacredito.cdlcremp;
      vr_tab_lincre(lpad(rw_linhacredito.nrdconta, 15, '0') || lpad(rw_linhacredito.nrctremp, 30, '0')).nrctremp := rw_linhacredito.nrctremp;
      vr_tab_lincre(lpad(rw_linhacredito.nrdconta, 15, '0') || lpad(rw_linhacredito.nrctremp, 30, '0')).dslcremp := rw_linhacredito.dslcremp;
      vr_tab_lincre(lpad(rw_linhacredito.nrdconta, 15, '0') || lpad(rw_linhacredito.nrctremp, 30, '0')).ordem := vr_contador + 10987000;
    END LOOP;

    -- Carregar PL Table
    FOR rw_crapldc IN cr_crapldc(pr_cdcooper) LOOP
      vr_tab_crapldc(rw_crapldc.cddlinha).dsdlinha := rw_crapldc.dsdlinha;
    END LOOP;

    -- Buscar dados de empr�stimos e cheques
    FOR rw_crapsdv IN cr_crapsdv(pr_cdcooper) LOOP
      -- Para empr�stimos
      IF rw_crapsdv.tpdsaldo = 1 THEN
        -- Criar �ndice para PL Table
        vr_crawepr := lpad(rw_crapsdv.nrdconta, 15, '0') || lpad(rw_crapsdv.nrctrato, 30, '0') || '0000000000';

        -- Verifica se �ndice existe
        IF vr_tab_crawepr.exists(vr_crawepr) THEN
          LOOP
            EXIT WHEN vr_crawepr IS NULL;

            -- Criar �ndice para PL Table
            vr_crapavt := lpad(vr_tab_crawepr(vr_crawepr).nrdconta, 15, '0') ||
                          lpad(vr_tab_crawepr(vr_crawepr).nrctremp, 30, '0') || '000010000000000';

            -- Verifica se �ndice existe
            IF vr_tab_crapavt.exists(vr_crapavt) THEN
              LOOP
                EXIT WHEN vr_crapavt IS NULL;

                -- Cria registros de devedores na PL Table
                vr_cindex := vr_cindex + 1;
                vr_vindex := lpad(vr_tab_crapavt(vr_crapavt).nrcpfcgc, 20, '0') || lpad(vr_cindex, 50, '0');

                vr_tab_devedores(vr_vindex).cdagenci := 0;
                vr_tab_devedores(vr_vindex).nrdconta := vr_tab_crawepr(vr_crawepr).nrdconta;
                vr_tab_devedores(vr_vindex).nrctremp := vr_tab_crawepr(vr_crawepr).nrctremp;
                vr_tab_devedores(vr_vindex).nmdavali := vr_tab_crapavt(vr_crapavt).nmdavali;
                vr_tab_devedores(vr_vindex).nrctava1 := 0;
                vr_tab_devedores(vr_vindex).nrcpfcg1 := vr_tab_crapavt(vr_crapavt).nrcpfcgc;
                vr_tab_devedores(vr_vindex).tpctrato := vr_tab_crapavt(vr_crapavt).tpctrato;
                vr_tab_devedores(vr_vindex).slddeved := rw_crapsdv.vldsaldo;

                -- Verifica se mudou de registro
                IF vr_tab_crapavt.next(vr_crapavt) IS NOT NULL THEN
                  IF vr_tab_crapavt(vr_crapavt).nrdconta || vr_tab_crapavt(vr_crapavt).nrctremp <>
                     vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrdconta || vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrctremp THEN
                    vr_crapavt := NULL;
                  ELSE
                    -- Busca pr�ximo �ndice
                    vr_crapavt := vr_tab_crapavt.next(vr_crapavt);
                  END IF;
                ELSE
                  vr_crapavt := NULL;
                END IF;
              END LOOP;
            END IF;

            -- Verifica valor maior que zero
            IF vr_tab_crawepr(vr_crawepr).nrctaav1 > 0 THEN
              vr_nrdconta := vr_tab_crawepr(vr_crawepr).nrctaav1;

              -- Executa pesquisa
              pc_pesquisa_crawepr_avalistas(pr_nrdconta => vr_tab_crawepr(vr_crawepr).nrdconta
                                           ,pr_nrctremp => vr_tab_crawepr(vr_crawepr).nrctremp
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo
                                           ,pr_contactr => vr_nrdconta);
            END IF;

            -- Verifica valor maior que zero
            IF vr_tab_crawepr(vr_crawepr).nrctaav2 > 0 THEN
              vr_nrdconta := vr_tab_crawepr(vr_crawepr).nrctaav2;

              -- Executa pesquisa
              pc_pesquisa_crawepr_avalistas(pr_nrdconta => vr_tab_crawepr(vr_crawepr).nrdconta
                                           ,pr_nrctremp => vr_tab_crawepr(vr_crawepr).nrctremp
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo
                                           ,pr_contactr => vr_nrdconta);
            END IF;

            -- Verifica se mudou de registro
            IF vr_tab_crawepr.next(vr_crawepr) IS NOT NULL THEN
              IF vr_tab_crawepr(vr_crawepr).nrdconta || vr_tab_crawepr(vr_crawepr).nrctremp <>
                 vr_tab_crawepr(vr_tab_crawepr.next(vr_crawepr)).nrdconta || vr_tab_crawepr(vr_tab_crawepr.next(vr_crawepr)).nrctremp THEN
                vr_crawepr := NULL;
              ELSE
                -- Busca pr�ximo �ndice
                vr_crawepr := vr_tab_crawepr.next(vr_crawepr);
              END IF;
            ELSE
              vr_crawepr := NULL;
            END IF;
          END LOOP;
        END IF;
      ELSIF rw_crapsdv.tpdsaldo = 2 THEN /* Desconto de cheque */
        -- Criar �ndice para PL Table
        vr_craplim := lpad(rw_crapsdv.nrdconta, 15, '0') || lpad(rw_crapsdv.nrctrato, 30, '0') || lpad(rw_crapsdv.tpdsaldo, 5, '0') || '0000000000';

        -- Verifica se o �ndice existe
        IF vr_tab_craplim.exists(vr_craplim) THEN
          LOOP
            EXIT WHEN vr_craplim IS NULL;

            -- Criar �ndice para PL Table
            vr_crapavt := lpad(vr_tab_craplim(vr_craplim).nrdconta, 15, '0') || lpad(vr_tab_craplim(vr_craplim).nrctrlim, 30, '0') ||
                          lpad(vr_tab_craplim(vr_craplim).tpctrlim, 5, '0') || '0000000000';

            -- Verifica se �ndice existe
            IF vr_tab_crapavt.exists(vr_crapavt) THEN
              LOOP
                EXIT WHEN vr_crapavt IS NULL;

                -- Cria registros de devedores na PL Table
                vr_cindex := vr_cindex + 1;
                vr_vindex := lpad(vr_tab_crapavt(vr_crapavt).nrcpfcgc, 20, '0') || lpad(vr_cindex, 50, '0');

                vr_tab_devedores(vr_vindex).cdagenci := 0;
                vr_tab_devedores(vr_vindex).nrdconta := vr_tab_craplim(vr_craplim).nrdconta;
                vr_tab_devedores(vr_vindex).nrctremp := vr_tab_craplim(vr_craplim).nrctrlim;
                vr_tab_devedores(vr_vindex).nmdavali := vr_tab_crapavt(vr_crapavt).nmdavali;
                vr_tab_devedores(vr_vindex).nrctava1 := 0;
                vr_tab_devedores(vr_vindex).nrcpfcg1 := vr_tab_crapavt(vr_crapavt).nrcpfcgc;
                vr_tab_devedores(vr_vindex).tpctrato := 2;
                vr_tab_devedores(vr_vindex).slddeved := rw_crapsdv.vldsaldo;

                -- Verifica se mudou de registro
                IF vr_tab_crapavt.next(vr_crapavt) IS NOT NULL THEN
                  IF vr_tab_crapavt(vr_crapavt).nrdconta || vr_tab_crapavt(vr_crapavt).nrctremp <>
                     vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrdconta || vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrctremp THEN
                    vr_crapavt := NULL;
                  ELSE
                    -- Busca pr�ximo �ndice
                    vr_crapavt := vr_tab_crapavt.next(vr_crapavt);
                  END IF;
                ELSE
                  vr_crapavt := NULL;
                END IF;
              END LOOP;
            END IF;

            -- Verifica se valores � maior que zero
            IF vr_tab_craplim(vr_craplim).nrctaav1 > 0 THEN
              vr_nrdconta := vr_tab_craplim(vr_craplim).nrctaav1;
              vr_tpctrato := 2;

              -- Executa pesquisa
              pc_pesquisa_craplim_avalistas(pr_contactr => vr_nrdconta
                                           ,pr_nrdconta => vr_tab_craplim(vr_craplim).nrdconta
                                           ,pr_nrctrlim => vr_tab_craplim(vr_craplim).nrctrlim
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo);
            END IF;

            -- Verifica se valores � maior que zero
            IF vr_tab_craplim(vr_craplim).nrctaav2 > 0 THEN
              vr_nrdconta := vr_tab_craplim(vr_craplim).nrctaav2;
              vr_tpctrato := 2;

              -- Executa pesquisa
              pc_pesquisa_craplim_avalistas(pr_contactr => vr_nrdconta
                                           ,pr_nrdconta => vr_tab_craplim(vr_craplim).nrdconta
                                           ,pr_nrctrlim => vr_tab_craplim(vr_craplim).nrctrlim
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo);
            END IF;

            -- Verifica se mudou de registro
            IF vr_tab_craplim.next(vr_craplim) IS NOT NULL THEN
              -- Verifica se mudou de registro
              IF vr_tab_craplim(vr_craplim).nrdconta || vr_tab_craplim(vr_craplim).nrctrlim || vr_tab_craplim(vr_craplim).tpctrlim <>
                 vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).nrdconta || vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).nrctrlim ||
                  vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).tpctrlim THEN
                vr_craplim := NULL;
              ELSE
                -- Busca pr�ximo �ndice
                vr_craplim := vr_tab_craplim.next(vr_craplim);
              END IF;
            ELSE
              vr_craplim := NULL;
            END IF;
          END LOOP;
        END IF;
      ELSIF rw_crapsdv.tpdsaldo = 5 OR rw_crapsdv.tpdsaldo = 6 THEN /* Cheque especial */
        -- Criar �ndice para PL Table
        vr_craplim := lpad(rw_crapsdv.nrdconta, 15, '0') || lpad(rw_crapsdv.nrctrato, 30, '0') || '000010000000000';

        -- Verifica se o �ndice existe
        IF vr_tab_craplim.exists(vr_craplim) THEN
          LOOP
            EXIT WHEN vr_craplim IS NULL;

            -- Criar �ndice para PL Table
            vr_crapavt := lpad(vr_tab_craplim(vr_craplim).nrdconta, 15, '0') || lpad(vr_tab_craplim(vr_craplim).nrctrlim, 30, '0') ||
                          lpad(vr_tab_craplim(vr_craplim).tpctrlim, 5, '0') || '0000000000';

            -- Verifica se �ndice existe
            IF vr_tab_crapavt.exists(vr_crapavt) THEN
              LOOP
                EXIT WHEN vr_crapavt IS NULL;

                -- Cria registros de devedores na PL Table
                vr_cindex := vr_cindex + 1;
                vr_vindex := lpad(vr_tab_crapavt(vr_crapavt).nrcpfcgc, 20, '0') || lpad(vr_cindex, 50, '0');

                vr_tab_devedores(vr_vindex).cdagenci := 0;
                vr_tab_devedores(vr_vindex).nrdconta := vr_tab_craplim(vr_craplim).nrdconta;
                vr_tab_devedores(vr_vindex).nrctremp := vr_tab_craplim(vr_craplim).nrctrlim;
                vr_tab_devedores(vr_vindex).nmdavali := vr_tab_crapavt(vr_crapavt).nmdavali;
                vr_tab_devedores(vr_vindex).nrctava1 := 0;
                vr_tab_devedores(vr_vindex).nrcpfcg1 := vr_tab_crapavt(vr_crapavt).nrcpfcgc;
                vr_tab_devedores(vr_vindex).tpctrato := 3;
                vr_tab_devedores(vr_vindex).slddeved := rw_crapsdv.vldsaldo;

                -- Verifica se mudou de registro
                IF vr_tab_crapavt.next(vr_crapavt) IS NOT NULL THEN
                  IF vr_tab_crapavt(vr_crapavt).nrdconta || vr_tab_crapavt(vr_crapavt).nrctremp <>
                     vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrdconta || vr_tab_crapavt(vr_tab_crapavt.next(vr_crapavt)).nrctremp THEN
                    vr_crapavt := NULL;
                  ELSE
                    -- Busca pr�ximo �ndice
                    vr_crapavt := vr_tab_crapavt.next(vr_crapavt);
                  END IF;
                ELSE
                  vr_crapavt := NULL;
                END IF;
              END LOOP;
            END IF;

            -- Verifica se valor � maior do que zero
            IF vr_tab_craplim(vr_craplim).nrctaav1 > 0 THEN
              vr_nrdconta := vr_tab_craplim(vr_craplim).nrctaav1;
              vr_tpctrato := 3;

              -- Executa pesquisa
              pc_pesquisa_craplim_avalistas(pr_contactr => vr_nrdconta
                                           ,pr_nrdconta => vr_tab_craplim(vr_craplim).nrdconta
                                           ,pr_nrctrlim => vr_tab_craplim(vr_craplim).nrctrlim
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo);
            END IF;

            -- Verifica se valor � maior do que zero
            IF vr_tab_craplim(vr_craplim).nrctaav2 > 0 THEN
              vr_nrdconta := vr_tab_craplim(vr_craplim).nrctaav2;
              vr_tpctrato := 3;

              -- Executa pesquisa
              pc_pesquisa_craplim_avalistas(pr_contactr => vr_nrdconta
                                           ,pr_nrdconta => vr_tab_craplim(vr_craplim).nrdconta
                                           ,pr_nrctrlim => vr_tab_craplim(vr_craplim).nrctrlim
                                           ,pr_tpctrato => vr_tpctrato
                                           ,pr_vldsaldo => rw_crapsdv.vldsaldo);
            END IF;

            -- Verifica se mudou de registro
            IF vr_tab_craplim.next(vr_craplim) IS NOT NULL THEN
              IF vr_tab_craplim(vr_craplim).nrdconta || vr_tab_craplim(vr_craplim).nrctrlim || vr_tab_craplim(vr_craplim).tpctrlim <>
                 vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).nrdconta || vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).nrctrlim ||
                  vr_tab_craplim(vr_tab_craplim.next(vr_craplim)).tpctrlim THEN
                vr_craplim := NULL;
              ELSE
                -- Busca pr�ximo �ndice
                vr_craplim := vr_tab_craplim.next(vr_craplim);
              END IF;
            ELSE
              vr_craplim := NULL;
            END IF;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    -- Gerar PL Table para gerar sumariza��o por CNPJ/CPF
    -- Gerar �ndice inicial
    vr_idxxml := vr_tab_devedores.first;
    vr_cindex := 9999999;

    LOOP
      EXIT WHEN vr_idxxml IS NULL;

      -- Valida CNPJ/CPF e cria PL Table de cabe�alho
      IF vr_tab_devedores(vr_idxxml).nrcpfcg1 <> ' ' AND vr_tab_devedores(vr_idxxml).nrcpfcg1 <> '0' THEN
        -- Sumariza saldo devedor por CPF/CNPJ
        vr_somacpf := nvl(vr_somacpf, 0) + vr_tab_devedores(vr_idxxml).slddeved;

        vr_cindex := vr_cindex - 1;

        -- Verifica se � o �ltimo registro
        IF vr_tab_devedores.next(vr_idxxml) IS NOT NULL THEN
          vr_idxtemp := lpad((vr_somacpf * 100), 50, '0') ||
                        lpad(vr_cindex, 10, '0') ||
                        lpad(vr_tab_devedores(vr_idxxml).nrcpfcg1, 20, '0') ||
                        lpad(vr_tab_devedores(vr_idxxml).nmdavali, 150, '0');

          IF vr_tab_devedores(vr_idxxml).nrcpfcg1 <> vr_tab_devedores(vr_tab_devedores.next(vr_idxxml)).nrcpfcg1 THEN
            -- Armazena �ltimo valor sumarizado e valida igualdades
            vr_tab_devedores2(vr_idxtemp).nrcpfcg1 := vr_tab_devedores(vr_idxxml).nrcpfcg1;
            vr_tab_devedores2(vr_idxtemp).slddeved := vr_somacpf;
            vr_tab_devedores2(vr_idxtemp).nmdavali := vr_tab_devedores(vr_idxxml).nmdavali;

            -- Zerar valor
            vr_somacpf := 0;
          END IF;
        ELSE
          vr_idxtemp := lpad((vr_somacpf * 100), 50, '0') ||
                        lpad(vr_cindex, 10, '0') ||
                        lpad(vr_tab_devedores(vr_idxxml).nrcpfcg1, 20, '0') ||
                        lpad(vr_tab_devedores(vr_idxxml).nmdavali, 150, '0');

          vr_tab_devedores2(vr_idxtemp).nrcpfcg1 := vr_tab_devedores(vr_idxxml).nrcpfcg1;
          vr_tab_devedores2(vr_idxtemp).slddeved := vr_somacpf;
          vr_tab_devedores2(vr_idxtemp).nmdavali := vr_tab_devedores(vr_idxxml).nmdavali;

          -- Zerar valor
          vr_somacpf := 0;
        END IF;
      END IF;

      -- Gerar pr�ximo �ndice
      vr_idxxml := vr_tab_devedores.next(vr_idxxml);
    END LOOP;

    -- Inicializar CLOB
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Gerar cabe�alho do XML
    vr_bxml := '<?xml version="1.0" encoding="utf-8"?><dados>';

    -- Itera��o entre PL Tables para gerar relat�rio
    -- Gerar �ndice inicial
    vr_idxxml := vr_tab_devedores2.last;
    vr_contador := 0;

    LOOP
      EXIT WHEN vr_idxxml IS NULL;

      -- Contagem de registros
      vr_contador := vr_contador + 1;

      -- Valida 100 primeiros registros
      IF vr_contador <= 100 THEN
        -- Gerar dados para o relat�rio
        vr_bxml := vr_bxml || '<dado><cabecalho><contador>' || vr_contador || '</contador>';
        pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
        vr_bxml := vr_bxml || '<nrcpfcg1>' || vr_tab_devedores2(vr_idxxml).nrcpfcg1 || '</nrcpfcg1>';
        pc_limpa_buffer(pr_buffer => vr_bxml,pr_str => vr_xml);
        vr_bxml := vr_bxml || '<nmdavali><![CDATA[' || vr_tab_devedores2(vr_idxxml).nmdavali || ']]></nmdavali>';
        pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
        vr_bxml := vr_bxml || '<slddeved>' || to_char(vr_tab_devedores2(vr_idxxml).slddeved, 'FM999G999G999G999G990D00') || '</slddeved></cabecalho>';
        pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);

        -- Gerar �ndice
        vr_cindexfim := lpad(vr_tab_devedores2(vr_idxxml).nrcpfcg1, 20, '0') || lpad('0', 50, '0');
        vr_inxctrl := TRUE;

        LOOP
          EXIT WHEN vr_cindexfim IS NULL;

          -- Verifica se � registro marcador
          IF vr_inxctrl THEN
            vr_cindexfim := vr_tab_devedores.next(vr_cindexfim);
            vr_inxctrl := FALSE;
          END IF;

          -- Verifica o CPF/CNPJ das duas PL Tables
          IF vr_tab_devedores.exists(vr_cindexfim) THEN
            -- Descri��o de tipo
            IF vr_tab_devedores(vr_cindexfim).tpctrato = 1 THEN
              vr_tab_devedores(vr_cindexfim).dstpctra := 'Emprestimo';
            ELSIF vr_tab_devedores(vr_cindexfim).tpctrato = 2 THEN
              vr_tab_devedores(vr_cindexfim).dstpctra := 'Desc.Chq';
            ELSE
              vr_tab_devedores(vr_cindexfim).dstpctra := 'Ch. Especial';
            END IF;

            -- Gerar �ndice de busca
            vr_devconta := lpad(vr_tab_devedores(vr_cindexfim).nrdconta, 15, '0');
            vr_devtremp := lpad(vr_tab_devedores(vr_cindexfim).nrctremp, 30, '0');

            -- Validar tipo de contrato
            IF vr_tab_devedores(vr_cindexfim).tpctrato = 1 THEN
              IF vr_tab_lincre.exists(vr_devconta || vr_devtremp) THEN
                vr_lindcred := substr(vr_tab_lincre(vr_devconta || lpad(vr_tab_devedores(vr_cindexfim).nrctremp, 30, '0')).cdlcremp || '-' ||
                                      vr_tab_lincre(vr_devconta || lpad(vr_tab_devedores(vr_cindexfim).nrctremp, 30, '0')).dslcremp, 0, 26);
              END IF;
            ELSIF vr_tab_devedores(vr_cindexfim).tpctrato = 2 THEN
              -- Verifica se existe registro
              IF vr_tab_craplim.exists(vr_devconta || vr_devtremp || lpad('2', 5, '0') ||'0000000000') THEN
                -- Verifica se existe registro
                IF vr_tab_crapldc.exists(vr_tab_craplim(vr_devconta || vr_devtremp || lpad('2', 5, '0') ||'0000000000').cddlinha) THEN
                  vr_lindcred := substr(vr_tab_craplim(vr_devconta || vr_devtremp || lpad('2', 5, '0') ||'0000000000').cddlinha || '-' ||
                                        vr_tab_crapldc(vr_tab_craplim(vr_devconta || vr_devtremp || lpad('2', 5, '0') ||'0000000000').cddlinha).dsdlinha , 0, 26);
                END IF;
              END IF;
            ELSIF vr_tab_devedores(vr_cindexfim).tpctrato = 3 THEN
              vr_cdlincrd := 0;
              vr_dslincrd := ' ';
              vr_lindcred := ' ';
            END IF;

            -- Gera XML para relat�rio
            vr_bxml := vr_bxml || '<detalhe exibir="' || vr_contador || '">';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<cdagenci>' || vr_tab_devedores(vr_cindexfim).cdagenci || '</cdagenci>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<nrctava1>' || to_char(vr_tab_devedores(vr_cindexfim).nrctava1, 'FM9999G999G9') || '</nrctava1>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<nrdconta>' || to_char(vr_tab_devedores(vr_cindexfim).nrdconta, 'FM9999G999G9') || '</nrdconta>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<nrctremp>' || to_char(vr_tab_devedores(vr_cindexfim).nrctremp, 'FM999G999G999') || '</nrctremp>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<dstpctra>' || vr_tab_devedores(vr_cindexfim).dstpctra || '</dstpctra>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<ccdagenci>' || vr_tab_crapass(lpad(vr_tab_devedores(vr_cindexfim).nrdconta, 15, '0')).cdagenci || '</ccdagenci>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<nmprimtl><![CDATA[' ||
                                               vr_tab_crapass(lpad(vr_tab_devedores(vr_cindexfim).nrdconta, 15, '0')).nmprimtl ||
                                             ']]></nmprimtl>' ||
                                 '<lindcred><![CDATA[' || substr(vr_lindcred, 0, 26) || ']]></lindcred>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
            vr_bxml := vr_bxml || '<slddeved>' || to_char(vr_tab_devedores(vr_cindexfim).slddeved, 'FM999G999G999G999G990D00') ||
                                  '</slddeved></detalhe>';
            pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);

            -- Limpa vari�vel
            vr_lindcred := ' ';
          ELSE
            vr_cindexfim := NULL;
          END IF;

          -- Gerar pr�ximo �ndice
          IF vr_tab_devedores.next(vr_cindexfim) IS NOT NULL THEN
            IF vr_tab_devedores(vr_cindexfim).nrcpfcg1 = vr_tab_devedores(vr_tab_devedores.next(vr_cindexfim)).nrcpfcg1 THEN
               vr_cindexfim := vr_tab_devedores.next(vr_cindexfim);
            ELSE
              vr_cindexfim := NULL;
            END IF;
          ELSE
            vr_cindexfim := NULL;
          END IF;
        END LOOP;

        -- Gerar TAG de finalizar grupo
        vr_bxml := vr_bxml || '</dado>';
        pc_limpa_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);
      END IF;

      -- Gerar pr�ximo �ndice
      vr_idxxml := vr_tab_devedores2.prior(vr_idxxml);
    END LOOP;

    -- Finalizar TAG root do XML
    vr_bxml := vr_bxml || '</dados>';
    pc_final_buffer(pr_buffer => vr_bxml, pr_str => vr_xml);

    -- Gerar relat�rio
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml
                               ,pr_dsxmlnode => '/dados/dado'
                               ,pr_dsjasper  => 'crrl440.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqimp
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => 1
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => pr_dscritic);

    -- Liberar dados do CLOB da mem�ria
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);

    -- Verifica se ocorreram erros
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;

  EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF nvl(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || pr_dscritic );
        END IF;
        -- Limpar variaveis de saida de critica pois eh um erro tratado
        pr_cdcritic := 0;
        pr_dscritic := null;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo at� ent�o
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
  END;
END PC_CRPS465;
/

