create or replace procedure cecred.pc_crps408 (pr_cdcooper in craptab.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS408 (Antigo Fontes/crps408.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Setembro/2004.                  Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 027.
               Gerar arquivo de pedido de cheques.
               Relatorios :  392 e 393 (Cheque)
                             572 e 573 (Formulario Continuo)

   Alteracoes: 14/03/2005 - Modificada a busca da data do tempo de conta do
                            associado (Evandro).

               18/03/2005 - Modificado o FORMAT da C/C INTEGRACAO (Evandro).

               05/07/2005 - Alimentado campo cdcooper das tabelas crapchq e
                            crapped (Diego).

               16/08/2005 - Alterar recebimento de email de talonarios (de
                            fabio@cecred para douglas@cecred) (Junior).

               03/10/2005 - Formulario Continuo ITG (Ze).

               13/10/2005 - Ajuste no "Cooperado desde" (Ze).

               17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               31/10/2005 - Tratar crapchq.nrdctitg, crapreq.dtpedido e
                            crapreq.nrpedido (Ze).

               02/11/2005 - Substituicao da condicao crapfdc.nrdctitg = STRING(
                            aux_nrdctitg por crapfdc.nrdctitg =
                            crapass.nrdctitg. (SQLWorks - Andre).

               07/12/2005 - Revisao do crapfdc (Ze Eduardo).

               23/12/2005 - Inclusao do parametro "tipo de cheque" no fonte
                            calc_cmc7.p  (Julio).

               20/01/2006 - Acerto no relatorio de criticas (Ze).

               09/02/2006 - Nao solicitar para Cta. Aplicacao (Ze).

               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               18/08/2006 - Alteracao para solicitar taloes de 10 folhas
                            (Julio)

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David)
                            Mudanca de CGC para CNPJ (Ze).

               29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                            mais de um titular (Ze).

               13/12/2006 - Alterado envio de e-mail de makelly@cecred.coop.br
                            para jonathan@cecred.coop.br (David).

               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).

               27/02/2007 - Tirar condicao p/ tipo 3 - tratar conforme qtd.
                            folhas no cadastro do cooperado (ass).
                            Tirar condicao p/ tipo 3 - put no arq.p/ interprint
                            qdo conta <> conta_ant e tprequis <> tprequis_ant
                            (Ze Eduardo).

               19/03/2007 - Padronizacao dos nomes de arquivo (Ze).

               21/03/2007 - Acerto no programa (Ze).

               18/04/2007 - Tratar sequencia do nro pedido atraves do gnsequt
                            Sequencia unica para todas as cooperativas e
                            Acerto no programa para conta com 8 digitos (Ze).

               30/04/2007 - Para Bancoob eliminar Grp. SETEC e tratar C1 E
                            Acerto no CHEQUE ESPECIAL para Bancoob (Ze).

               18/05/2007 - Mudanca de leiate referente ao Grp. SETEC
                            Segundo Digito do 3o Campo do CMC-7 (Ze).

               14/08/2007 - Alterado para pegar a data de abertura de conta mais
                            antiga do cooperado cadastrada na crapsfn (Elton).

               09/10/2007 - Remover envio de email de talonarios (douglas@cecred
                            e jonathan@cecred) (Guilherme).

               25/02/2008 - Enviar arquivos para Interprint atraves da Nexxera
                            (Julio).

               02/07/2008 - Nao tratar mais os formularios continuos pois o
                            programa crps296.p faz isso (Evandro).

               19/08/2008 - Tratar pracas de compensacao (Magui).

               02/12/2008 - Utilizar agencia na geracao do arq BB pelo
                            crapcop.cdageitg e calcular o digito da agencia
                            (Guilherme).

               27/02/2009 - Acerto na formatacao do crapcop.cdageitg - digito
                            da agencia (Ze).

               26/05/2009 - Permitir gerar relatorios de pedidos zerados para
                            Intranet (Diego).

               30/09/2009 - Adaptacoes projeto IF CECRED
                          - Alterar inhabmen da crapass para crapttl(Guilherme).

               01/03/2010 - Tratar formulario continuo para IF CECRED
                            (Voltar alteraçao do dia 02/07/2008) (Guilherme).

               30/07/2010 - Verificar AVAIL crapage para endereco do PAC
                            (Guilherme).

               25/08/2010 - A pedidos do suprimentos, criar relatorios 572 e 573
                            para Form. Cont. baseado no 247 e 248 (Guilherme).

               11/10/2010 - Acerto no rel. 572 - rel_cdagenci (Trf.35393) (Ze).

               10/02/2011 - Utilizar camnpos ref. Nome no talao - crapttl
                           (Diego).

               18/08/2011 - Alimentar campo da Data Confec. do Cheque (Ze).

               12/12/2011 - Imprimir somente os relatorios do Banco 085
                            - Trf. 43974 (Ze).

               24/09/2013 - Conversão Progress >> Oracle PL/SQL (Andrino - RKAM).

               12/12/2011 - Imprimir somente os relatorios do Banco 085
                            - Trf. 43974 (Ze).

               22/01/2014 - Incluir VALIDATE crapped, crapfdc (Lucas R.)

               23/01/2014 - Incluido variavel aux_flggerou na procedure
                            p_gera_talonario, afim de controlar se foi
                            gerado arquivo de requisicao de talao/formulario
                            de cheque, para disponibilizar tais arquivos no
                            diretorio de envio a Nexxera. (Fabricio)

               20/02/2014 - Conversão das alterações de 01/2014 (Daniel - Supero)

               10/11/2014 - Alterado tamanho do nmrescop de 11 posições para 20
                            (Lucas R./Gielow Softdesk #6850)

               27/02/2015 - Retirado 9 posições da geração do arquivo 314 para 305
                            na parte final do arquivo (Lucas R.)
                            
               17/09/2015 - Ajustes referente impressão de cheque com empresa RRD
                            (Daniel)             
                            
               22/01/2016 - Inclusao do CNPJ da Cooperativa no resumo de Pedido
                            (Daniel)      
							
			         01/09/2016 - Geração de arquivos de formularios continuos para
                            RRD (Elton - SD 511158)			                   
                            
               25/10/2016 - #524279 Ajustado para que os pedidos sejam acumulados e enviados ao fornecedor 
                            quinzenalmente (todo dia 1º e todo dia 15 de cada mês, quando se tratar de finais 
                            de semana ou feriados devem ser enviados no primeiro dia útil posterior). (Carlos)

			   21/03/2017 - Ajuste para gerar número de pedido distinto por tipo de requisição (Rafael Monteiro)

               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).


               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)
............................................................................. */

  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;

  -- Cursor para buscar os dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) is
    select crapcop.nmextcop,
           crapcop.cdageitg,
           crapcop.cdagebcb,
           crapcop.cdagectl,
           crapcop.cdbcoctl,
           crapcop.nmrescop,
           crapcop.dsendcop,
           crapcop.nrendcop,
           crapcop.nmbairro,
           crapcop.nrtelvoz,
           crapcop.nmcidade,
           crapcop.cdufdcop,
           crapcop.nrdocnpj
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor para buscar os dados do ultimo cheque
  CURSOR cr_craptab(pr_cdcooper in craptab.cdcooper%type) is
    SELECT dstextab
      FROM craptab
     WHERE craptab.cdcooper = pr_cdcooper
      AND  upper(craptab.nmsistem) = 'CRED'
      AND  upper(craptab.tptabela) = 'GENERI'
      AND  craptab.cdempres = 0
      AND  upper(craptab.cdacesso) = 'NUMULTCHEQ'
      AND  craptab.tpregist = 0;
  rw_craptab cr_craptab%ROWTYPE;

  -- Codigo do programa
  vr_cdprogra      crapprg.cdprogra%type;
  
  -- Lista Endereco de Email RRD
  vr_email_dest    VARCHAR2(4000) := NULL;

  -- Tratamento de erros
  vr_exc_fimprg    EXCEPTION;
  vr_exc_saida     EXCEPTION;

  -- Variavel para armazenar as informacoes em XML
  vr_des_xml          clob;
  vr_des_xml_rej      clob;
  vr_des_xml_fc       clob;
  vr_des_xml_fc_rej   clob;


  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;

  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);

  -- Codigo da Empresa a ser Impresso os Cheques
  vr_cdempres      NUMBER := 0;
  vr_cdempres2     NUMBER := 0;
  vr_nmempres      VARCHAR2(20);

  -- Quantidade de Linhas no Arquivo
  vr_qtlinhas      NUMBER := 0;

  vr_cdacesso      VARCHAR2(30);

  vr_dscomora  VARCHAR2(1000);
  vr_dsdirbin  VARCHAR2(1000);

  -- Variaveis envio SFTP
  vr_serv_sftp  VARCHAR2(100);
  vr_user_sftp  VARCHAR2(100);
  vr_pass_sftp  VARCHAR2(100);
  vr_comando    VARCHAR2(4000);
  vr_typ_saida  VARCHAR2(3);
  vr_dir_remoto VARCHAR2(4000);
  vr_script     VARCHAR2(4000);
  vr_des_saida  VARCHAR2(4000);
  
  vr_qtfoltal_10     NUMBER := 0;
  vr_qtfoltal_20     NUMBER := 0;

  -- Procedimento para inserir texto no CLOB do arquivo XML
  PROCEDURE pc_escreve_xml(pr_des_dados in VARCHAR2,
                           pr_tpxml     IN NUMBER) is
  BEGIN
    IF pr_tpxml = 1 THEN -- Se o tipo de XML for de requisicoes aprovadas
      dbms_lob.writeappend(vr_des_xml,        length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 2 THEN -- Se o tipo de XML for de requisicoes rejeitadas
      dbms_lob.writeappend(vr_des_xml_rej,    length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 3 THEN -- Se o tipo de XML for de requisicoes aprovadas de formulário continuo
      dbms_lob.writeappend(vr_des_xml_fc,     length(pr_des_dados), pr_des_dados);
    ELSIF pr_tpxml = 4 THEN -- Se o tipo de XML for de requisicoes rejeitadas de formulário continuo
      dbms_lob.writeappend(vr_des_xml_fc_rej, length(pr_des_dados), pr_des_dados);
    END IF;
  end;

  -- Subrotina que vai gerar o relatorio sobre o talonario
  PROCEDURE Pc_Gera_Talonario(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                              pr_cdtipcta_ini IN crapreq.cdtipcta%TYPE,
                              pr_cdtipcta_fim IN crapreq.cdtipcta%TYPE,
                              pr_cdbanchq     IN crapass.cdbcochq%TYPE,
                              pr_nrcontab     IN NUMBER,
                              pr_nrdserie     IN NUMBER,
                              pr_nmarqui1     IN VARCHAR2,
                              pr_nmarqui2     IN VARCHAR2,
                              pr_nmarqui3     IN VARCHAR2,
                              pr_nmarqui4     IN VARCHAR2,
                              pr_flg_impri    IN VARCHAR2,
                              pr_cdempres     IN gnsequt.cdsequtl%TYPE,
                              pr_tprequis     IN crapreq.tprequis%type) IS

    -- Cursor sobre arquivo de controle
    CURSOR cr_gnsequt IS
      SELECT rowid,
             gnsequt.vlsequtl
        FROM gnsequt
       WHERE gnsequt.cdsequtl = 001
       FOR UPDATE;
    rw_gnsequt cr_gnsequt%ROWTYPE;

    -- Cursor para leitura de requisicoes de talonarios
    CURSOR cr_crapreq(pr_cdcooper     IN crapreq.cdcooper%TYPE,
                      pr_cdbanchq     IN crapcop.cdbcoctl%TYPE,
                      pr_cdtipcta_ini IN crapreq.cdtipcta%TYPE,
                      pr_cdtipcta_fim IN crapreq.cdtipcta%TYPE,
                      pr_tprequis     in crapreq.tprequis%TYPE) IS
      SELECT crapreq.ROWID,
             crapreq.cdagenci,
             crapreq.nrdconta,
             crapreq.qtreqtal,
             crapreq.tprequis,
             crapreq.insitreq,
             crapreq.tpformul
        FROM crapass,
             crapreq
       WHERE crapreq.cdcooper  = pr_cdcooper
         AND (crapreq.tprequis  = 1
          OR  (crapreq.tprequis = 3
         AND   crapreq.tpformul = 999))         
         AND crapreq.cdtipcta BETWEEN pr_cdtipcta_ini and pr_cdtipcta_fim         
         AND crapreq.insitreq IN (1,4,5)
         AND crapass.cdcooper = crapreq.cdcooper
         AND crapass.nrdconta = crapreq.nrdconta
         AND crapass.cdbcochq = pr_cdbanchq
         AND crapreq.qtreqtal > 0 -- Somente quando tiver solicitacao de talao
         AND crapreq.tprequis = pr_tprequis
       ORDER BY crapreq.cdagenci,
                crapreq.nrdconta;

    -- Cursor para buscar os dados da agencia
    CURSOR cr_crapage(pr_cdcooper    IN crapage.cdcooper%TYPE,
                      pr_cdagenci    IN crapage.cdagenci%TYPE) IS
      SELECT crapage.nmresage,
             crapage.cdcomchq,
             crapage.dsinform##1,
             crapage.dsinform##2,
             crapage.dsinform##3
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper    IN crapass.cdcooper%TYPE,
                      pr_nrdconta    IN crapass.nrdconta%TYPE) IS
      SELECT ROWID,
             nrdconta,
             nrdctitg,
             flchqitg,
             nrflcheq,
             qtfoltal,
             nmprimtl,
             cdtipcta,
             cdsitdtl,
             inlbacen,
             dtdemiss,
             cdsitdct,
             flgctitg,
             inpessoa,
             nrcpfcgc,
             tpdocptl,
             nrdocptl,
             idorgexp,
             cdufdptl,
             dtabtcct,
             dtadmiss
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa fisica
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE) IS
      SELECT nmtalttl
            ,nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper  = pr_cdcooper
         AND crapttl.nrdconta  = pr_nrdconta
         AND crapttl.idseqttl >= pr_idseqttl
       ORDER BY crapttl.idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Cursor sobre os titulares da conta para pessoa juridica
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE,
                      pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT nmtalttl
        FROM crapjur
       WHERE crapjur.cdcooper  = pr_cdcooper
         AND crapjur.nrdconta  = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- Cursor para buscar o tipo de conta para os rejeitados
    CURSOR cr_craptip(pr_cdcooper IN craptip.cdcooper%TYPE,
                      pr_cdtipcta IN craptip.cdtipcta%TYPE) IS
      SELECT dstipcta
        FROM craptip
       WHERE craptip.cdcooper = pr_cdcooper
         AND craptip.cdtipcta = pr_cdtipcta;
    rw_craptip cr_craptip%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT substr(nmresbcc,1,15) nmresbcc
        FROM crapban
       WHERE cdbccxlt = pr_cdbccxlt;

    -- Cursor para buscar a data em que o cooperado é cliente bancário
    CURSOR cr_crapsfn(pr_cdcooper IN crapsfn.cdcooper%TYPE,
                      pr_nrcpfcgc IN crapsfn.nrcpfcgc%TYPE) IS
      SELECT crapsfn.dtabtcct
        FROM crapsfn
       WHERE crapsfn.cdcooper = pr_cdcooper
         AND crapsfn.nrcpfcgc = pr_nrcpfcgc
         AND crapsfn.tpregist = 1
         AND crapsfn.dtabtcct IS NOT NULL
       ORDER BY crapsfn.dtabtcct;
    rw_crapsfn cr_crapsfn%ROWTYPE;

    -- Variavel da agencia anterior do loop de requisicoes;
    vr_cdagenci_ant    crapage.cdagenci%TYPE;
    vr_cdagenci_ant_fc crapage.cdagenci%TYPE;

    -- Variaveis auxiliares
    vr_nrctaitg        crapass.nrdctitg%TYPE;
    vr_nrinichq        crapass.nrflcheq%TYPE;
    vr_nrinichq_fc     crapass.nrflcheq%TYPE;
    vr_nrultchq        crapass.nrflcheq%TYPE;
    vr_nrflcheq        crapass.nrflcheq%TYPE;
    vr_nrflcheq_aux    crapass.nrflcheq%TYPE;
    vr_nrdigchq        crapfdc.nrdigchq%TYPE;
    vr_cdagechq        crapfdc.cdagechq%TYPE;
    vr_dsdocmc7        crapfdc.dsdocmc7%TYPE;
    vr_cdcritic        crapreq.cdcritic%TYPE;
    vr_insitreq        crapreq.insitreq%TYPE;
    vr_nmbanco         crapban.nmresbcc%TYPE;
    vr_retorno         BOOLEAN;
    vr_idrejeit_tl     BOOLEAN;
    vr_fechapac_req_tl BOOLEAN;
    vr_fechapac_rej_tl BOOLEAN;
    vr_idrejeit_fc     BOOLEAN;
    vr_fechapac_req_fc BOOLEAN;
    vr_fechapac_rej_fc BOOLEAN;
    vr_qttotreq        NUMBER(10);
    vr_qttotreq_tl     NUMBER(10);
    vr_qttotrej_tl     NUMBER(10);
    vr_qttottrf_tl     NUMBER(10);
    vr_qttotreq_fc     NUMBER(10);
    vr_qttotrej_fc     NUMBER(10);
    vr_qttottrf_fc     NUMBER(10);
    vr_qttotchq_tl     NUMBER(10);
    vr_qttottal_tl     NUMBER(10);
    vr_qttottal_fc     NUMBER(10);
    vr_qttotgerreq_fc  NUMBER(10);
    vr_qtreqtal        NUMBER(10);
    vr_dstipreq        VARCHAR2(02);
    vr_dssitdct        VARCHAR2(50);
    vr_dscritic        VARCHAR2(200);
    vr_auxiliar        NUMBER(15);
    vr_auxiliar2       NUMBER(15);
    vr_cddigage        NUMBER(01);
    vr_cddigtc1        NUMBER(01);
    vr_nrdctitg        VARCHAR2(07);
    vr_nrdigctb        VARCHAR2(01);
    vr_nrdctitg_aux    crapass.nrdctitg%TYPE;
    vr_nrcpfcgc        VARCHAR2(18);
    vr_tpdocptl        crapass.tpdocptl%TYPE;
    vr_nrdocptl        crapass.nrdocptl%TYPE;
    vr_cdorgexp        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_cdufdptl        crapass.cdufdptl%TYPE;
    vr_nmprital        crapass.nmprimtl%TYPE;
    vr_nmsegtal        crapttl.nmextttl%TYPE;
    vr_dtabtcc2        DATE;
    vr_literal2        VARCHAR2(200);
    vr_literal3        VARCHAR2(200);
    vr_literal4        VARCHAR2(200);
    vr_literal5        VARCHAR2(200);
    vr_literal6        VARCHAR2(15);
    vr_literal7        VARCHAR2(200);
    vr_literal8        VARCHAR2(200);
    vr_literal9        VARCHAR2(200);
    vr_tpformul        VARCHAR2(02);
    vr_nrfolhas        NUMBER(10);
    vr_nrdigtc2        NUMBER(01);
    vr_dscpfcgc        VARCHAR2(05);
    vr_dsarqdad        VARCHAR2(2000);
    vr_numtalon        crapass.flchqitg%TYPE;

    -- Variaveis para geracao do arquivo texto via utl_file
    vr_nmarqped        VARCHAR2(50);
    vr_nmarqtransm     VARCHAR2(50);
    vr_nmarqctrped     VARCHAR2(50);
    vr_nmarqdadped     VARCHAR2(50);
    vr_input_file_dad  utl_file.file_type;
    vr_input_file_ctr  utl_file.file_type;

    -- Variável que indica se foi gerado arquivo de requisicao de talao/formulario de cheque
    vr_flggerou        boolean;
    
    -- variavel para verificacao do dia de processamento de envio da requisicao
    vr_dtcalcul        DATE;

  BEGIN

    -- Verifica arquivo de controle para buscar sequencial do talao.
    OPEN cr_gnsequt;
    FETCH cr_gnsequt INTO rw_gnsequt;
    IF cr_gnsequt%NOTFOUND THEN
      CLOSE cr_gnsequt;
      pr_cdcritic := 151;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      raise vr_exc_saida;
    END IF;

    rw_gnsequt.vlsequtl := rw_gnsequt.vlsequtl + 1;

    -- Atualiza arquivo de controle
    BEGIN
      UPDATE gnsequt
         SET vlsequtl = rw_gnsequt.vlsequtl
       WHERE ROWID = rw_gnsequt.rowid;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao atualizar gnsequt: '||SQLERRM;
      RAISE vr_exc_saida;
    END;

    -- Definição dos nomes dos arquivos UTL_FILE
    IF pr_cdempres = 1 THEN -- InterPrint
      vr_nmempres    := 'INTERPRINT';
      vr_nmarqped    := 'pd'||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqtransm := 'd' ||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqctrped := 'ct'||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqdadped := 'da'||to_char(pr_cdcooper,'fm000')||'-ctr-';
    ELSE
      vr_nmempres    := 'RR DONNELLEY';
      vr_nmarqped    := 'RRD'   ||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqtransm := 'dRRD'  ||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqctrped := 'ctRRD' ||to_char(pr_cdcooper,'fm000')||'-ctr-';
      vr_nmarqdadped := 'daRRD' ||to_char(pr_cdcooper,'fm000')||'-ctr-';
    END IF;

    vr_nmarqped    := vr_nmarqped    || to_char(rw_gnsequt.vlsequtl,'fm000000');
    vr_nmarqtransm := vr_nmarqtransm || to_char(rw_gnsequt.vlsequtl,'fm000000');
    vr_nmarqctrped := vr_nmarqctrped || to_char(rw_gnsequt.vlsequtl,'fm000000');
    vr_nmarqdadped := vr_nmarqdadped || to_char(rw_gnsequt.vlsequtl,'fm000000');
    vr_flggerou := FALSE;


    -- Tenta abrir o arquivo de detalhes em modo gravacao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio||'/arq'   --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqdadped             --> Nome do arquivo
                            ,pr_tipabert => 'W'                        --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file_dad          --> Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic);              --> Erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;


    -- Inicializar o CLOB para armazenar os arquivos XML
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    vr_des_xml_fc := NULL;
    dbms_lob.createtemporary(vr_des_xml_fc, TRUE);
    dbms_lob.open(vr_des_xml_fc, dbms_lob.lob_readwrite);

    vr_des_xml_rej := NULL;
    dbms_lob.createtemporary(vr_des_xml_rej, TRUE);
    dbms_lob.open(vr_des_xml_rej, dbms_lob.lob_readwrite);

    vr_des_xml_fc_rej := NULL;
    dbms_lob.createtemporary(vr_des_xml_fc_rej, TRUE);
    dbms_lob.open(vr_des_xml_fc_rej, dbms_lob.lob_readwrite);

    -- Inicializa a variavel de indicador de existencia de associado rejeitado
    vr_idrejeit_tl := FALSE;
    vr_idrejeit_fc := FALSE;

    -- Inicializa a variavel de fechamento de pac, informando que a mesma esta fechada
    vr_fechapac_req_tl := TRUE;
    vr_fechapac_rej_tl := TRUE;

    vr_fechapac_req_fc := TRUE;
    vr_fechapac_rej_fc := TRUE;

    -- Inicializa as variaveis totalizadoras
    vr_qttotreq       := 0;
    vr_qttotchq_tl    := 0;
    vr_qttottal_tl    := 0;
    vr_qttotreq_tl    := 0;
    vr_qttottrf_tl    := 0;
    vr_qttotrej_tl    := 0;
    vr_qttottal_fc    := 0;
    vr_qttotgerreq_fc := 0;
    vr_qttotreq_fc    := 0;
    vr_qttottrf_fc    := 0;
    vr_qttotrej_fc    := 0;

    -- Inicializa o arquivo XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps408>',1);
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps408>',3);

    -- Busca o codigo da agencia do cheque
    vr_cdagechq := rw_crapcop.cdagectl;

    -- Insere o nó inicial do relatorio de pedidos do XML
    pc_escreve_xml('<pedido>'||
                    '<requisicoes>',1);
    pc_escreve_xml( '<rejeitados>',2);

    pc_escreve_xml('<pedido>'||
                    '<requisicoes>',3);
    pc_escreve_xml( '<rejeitados>',4);

    -- Verifica se ha requisicoes a serem atendidas
    FOR rw_crapreq IN cr_crapreq(pr_cdcooper,
                                 pr_cdbanchq,
                                 pr_cdtipcta_ini,
                                 pr_cdtipcta_fim,
                                 pr_tprequis) LOOP

      -- Verifica se é o primeiro dia útil do mês ou primeiro dia útil a partir do dia 15, pois as
      -- solicitações de formulário continuo só acontecerão de 15 em 15 dias, apenas para a empresa RR Donnelley
      IF (rw_crapreq.tprequis = 3 AND 
          rw_crapreq.tpformul = 999) THEN
        
        IF pr_cdempres <> 2 THEN
          CONTINUE;
        END IF;
        
        -- Definindo a data do calculo
        -- se for primeira quinzena
        IF vr_dtmvtolt < to_date('15/' || to_char(vr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR') THEN
          -- primeiro dia útil do mes atual
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper , 
                                                     pr_dtmvtolt => trunc(vr_dtmvtolt,'MM')); 
        ELSE
          vr_dtcalcul := to_date('15/' || to_char(vr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
          -- primeiro dia útil da segunda quinzena do mes atual
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper , 
                                                     pr_dtmvtolt => vr_dtcalcul);
        END IF;

        -- Incrementa a data do processamento enquanto a empresa for diferente de 2
        vr_cdacesso := 'CRPS408_CHEQUE_' || to_char(vr_dtcalcul,'DY','NLS_DATE_LANGUAGE = PORTUGUESE');
        vr_cdempres2 := NVL(gene0001.fn_param_sistema('CRED',0,vr_cdacesso),0);
        WHILE vr_dtcalcul <= vr_dtmvtolt AND 
              vr_cdempres2 <> 2 LOOP
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper , 
                                                     pr_dtmvtolt => vr_dtcalcul + 1);
          vr_cdacesso := 'CRPS408_CHEQUE_' || to_char(vr_dtcalcul,'DY','NLS_DATE_LANGUAGE = PORTUGUESE');
          vr_cdempres2 := NVL(gene0001.fn_param_sistema('CRED',0,vr_cdacesso),0);
        END LOOP;        
        
        -- Se a data atual for diferente da data a ser processada é pq não é a primeira ter, qua ou sex da 
        -- quinzena; vai para a próxima rw_crapreq
        IF vr_dtmvtolt <> vr_dtcalcul THEN
          continue; 
        END IF;

      END IF;

      -- Busca os dados do associado
      OPEN cr_crapass(pr_cdcooper,
                      rw_crapreq.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      vr_cdcritic := 0;

      -- Verificacao se o cooperado nao esta rejeitado
      IF pr_cdtipcta_ini = 12 THEN -- NORMAL ITG
        IF rw_crapass.cdtipcta < 12 THEN
          vr_cdcritic := 65; -- 065 - Tipo de conta nao permite req.
        ELSIF rw_crapass.flgctitg <> 2 THEN -- Situação da conta diferente de cadastrada
          vr_cdcritic := 837; -- 837 - Conta de Integracao incorreta.
        ELSIF rw_crapass.cdtipcta > 16 THEN -- Conta de aplicação
          vr_cdcritic := 65; -- 065 - Tipo de conta nao permite req.
        ELSIF rw_crapass.nrdctitg IS NULL THEN -- Se nao tiver numero de conta de integracao
          vr_cdcritic := 837; -- 837 - Conta de Integracao incorreta.
        END IF;
      ELSIF pr_cdtipcta_ini = 8 THEN -- NORMAL CONVENIO
        IF rw_crapass.cdtipcta < 8  OR rw_crapass.cdtipcta > 11 THEN
          vr_cdcritic := 65;-- 065 - Tipo de conta nao permite req.
        END IF;
      END IF;

      -- Se não houver rejeição no associado
      IF vr_cdcritic = 0 THEN
        IF rw_crapass.cdsitdct <> 1 THEN -- Se a situação da conta for diferente de ativo
          vr_cdcritic := 18; --018 - Situacao da conta errada.
        ELSIF rw_crapass.cdsitdtl IN (5,6,7,8) THEN --5=NORMAL C/PREJ., 6=NORMAL BLQ.PREJ, 7=DEMITIDO C/PREJ, 8=DEM. BLOQ.PREJ.
          vr_cdcritic := 695; --695 - ATENCAO! Houve prejuizo nessa conta
        ELSIF rw_crapass.cdsitdtl IN (2,4) THEN --2=NORMAL C/BLOQ., 4=DEMITIDO C/BLOQ
          vr_cdcritic := 95; --095 - Titular da conta bloqueado.
        ELSIF rw_crapass.inlbacen <> 0 THEN -- Indicador se o associado consta na lista do Banco Central
          vr_cdcritic := 720; --720 - Associado esta no CCF.
        END IF;
      END IF;

      -- Abre o cursor contendo os titulares da conta, mas somente a segunda pessoa em diante
      OPEN cr_crapttl(pr_cdcooper,
                      rw_crapass.nrdconta,
                      2);
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%FOUND AND vr_cdcritic = 0 THEN
        IF rw_crapass.cdtipcta IN (1,2,7,8,9,12,13,18) THEN --1=NORMAL, 2=ESPECIAL, 7=CTA APLIC INDIV, 8=NORMAL CONVENIO
                                                            --9=ESPEC. CONVENIO, 12=NORMAL ITG, 13=ESPECIAL ITG, 18=CTA APL.IND.ITG
          vr_cdcritic := 832; --832 - Tipo de conta nao permite MAIS DE UM TITULAR.
        END IF;
      END IF;
      CLOSE cr_crapttl;

      -- Verifica se é formulario continuo
      -- Em caso positivo, faz os processos para o mesmo
      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN
        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant_fc,0) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

          -- Se teve registro anterior, entao fecha-se o no
          IF nvl(vr_cdagenci_ant_fc,0) <> 0 THEN
            pc_escreve_xml( '<qttotreq>'||vr_qttotreq_fc||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_fc||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_fc||'</qttotrej>'||
                           '</pac>',3);
          END IF;

          -- Insere o nó inicial
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'||rw_gnsequt.vlsequtl||'</vlsequtl>',3);
          vr_fechapac_req_fc := FALSE;

          -- Zera as variaveis de totais
          vr_qttotreq_fc := 0;
          vr_qttotrej_fc := 0;
          vr_qttottrf_fc := 0;

          -- Se no PAC anterior teve rejeitados, entao deve-se fechar o nó
          IF vr_idrejeit_fc THEN
            vr_fechapac_rej_fc := TRUE;
            pc_escreve_xml('</pac>',4);
            -- Limpa indicador de requisicoes rejeitadas
            vr_idrejeit_fc := FALSE;
          END IF;

        END IF; -- If de agencia diferente de formulario continuo

      ELSE -- Se nao for formulario contionuo

        -- Verifica se é uma agencia diferente do registro anterior
        IF rw_crapreq.cdagenci <> nvl(vr_cdagenci_ant,0) THEN

          -- busca o nome da agencia
          OPEN cr_crapage(pr_cdcooper,
                          rw_crapreq.cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          IF cr_crapage%NOTFOUND THEN
            rw_crapage.nmresage := LPAD('*',15,'*');
            rw_crapage.cdcomchq := 16;
          END IF;
          CLOSE cr_crapage;

          -- Se tiver agencia anterior deve-se fechar o nó do PAC
          IF nvl(vr_cdagenci_ant,0) <> 0 THEN
            pc_escreve_xml( '<qttotreq>'||vr_qttotreq_tl||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_tl||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_tl||'</qttotrej>'||
                           '</pac>',1);
          END IF;

          -- Insere o no do PAC
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'||rw_gnsequt.vlsequtl||'</vlsequtl>',1);
          vr_fechapac_req_tl := FALSE;

          -- Zera as variaveis de totais
          vr_qttotreq_tl := 0;
          vr_qttotrej_tl := 0;
          vr_qttottrf_tl := 0;

          -- Se no PAC anterior teve rejeitados, entao deve-se fechar o nó
          IF vr_idrejeit_tl THEN
            vr_fechapac_rej_tl := TRUE;
            pc_escreve_xml('</pac>',2);
            -- Limpa indicador de requisicoes rejeitadas
            vr_idrejeit_tl := FALSE;
          END IF;
        END IF;  -- If de agencia diferente para formulario comum
      END IF;

      -- Se o cooperado nao estiver com situacao de rejeitado
      IF vr_cdcritic = 0 THEN
        -- Inicializa variavel auxiliar de contados de taloes
        vr_qtreqtal := 1;

        -- Acumula o total de taloes
        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          vr_qttottal_fc    := vr_qttottal_fc + rw_crapreq.qtreqtal;
          vr_qttotgerreq_fc := vr_qttotgerreq_fc + 1;
          vr_nrinichq_fc    := 0;
        ELSE  -- Se for taloes
          vr_qttottal_tl := vr_qttottal_tl + rw_crapreq.qtreqtal;
        END IF;

        -- Contador para executar a cada solicitacao de talão, pois a mesma requisição pode solicitar mais de um talão
        LOOP
          EXIT WHEN vr_qtreqtal > rw_crapreq.qtreqtal;

          -- Busca do numero da conta de integracao
          IF pr_cdtipcta_ini = 12 THEN  -- NORMAL ITG
            vr_nrctaitg := rw_crapass.nrdctitg;
          ELSE
            vr_nrctaitg := rw_crapass.nrdconta;
          END IF;

          -- Atualiza o numero do talao
          rw_crapass.flchqitg := rw_crapass.flchqitg + 1;

          -- Busca o numero da folha inicial do cheque
          vr_nrinichq := (rw_crapass.nrflcheq + 1)*10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrinichq); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa
          -- Atualiza o número da folha de cheque igualando ao numero da primeira folha de cheque sem o digito
          vr_nrflcheq := trunc(vr_nrinichq/10,0);

          IF vr_nrinichq_fc = 0 THEN
            vr_nrinichq_fc := vr_nrinichq;
          END IF;

          -- Se for Talão, entao busca a quantidade de cheques por talão
          IF  rw_crapreq.tprequis = 1  THEN
              vr_nrultchq := vr_nrflcheq + (rw_crapass.qtfoltal - 1);
          ELSE
              vr_nrultchq := vr_nrflcheq; -- Se for FC, vai ter apenas uma folha de cheque no talão
          END IF;

          -- Rotina para criar a tabela de cadastro de folhas de cheques emitidas para o cooperado.
          LOOP
            -- Calcula o digito do cheque
            vr_nrflcheq_aux := vr_nrflcheq * 10;
            vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrflcheq_aux); -- O retorno é ignorado, pois a variável vr_nrflcheq_aux é atualiza pelo programa
            vr_nrdigchq := MOD(vr_nrflcheq_aux,10);

            -- busca o CMC-7 do cheque
            cheq0001.pc_calc_cmc7_difcompe(pr_cdbanchq => pr_cdbanchq,
                                           pr_cdcmpchq => rw_crapage.cdcomchq,
                                           pr_cdagechq => vr_cdagechq,
                                           pr_nrctachq => vr_nrctaitg,
                                           pr_nrcheque => vr_nrflcheq,
                                           pr_tpcheque => 1,
                                           pr_dsdocmc7 => vr_dsdocmc7,
                                           pr_des_erro => pr_dscritic);
            IF pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;


            -- Insere na tabela de cadastro de folhas de cheques emitidas para o cooperado.
            BEGIN
              INSERT INTO crapfdc
                (nrdconta,
                 nrdctabb,
                 nrctachq,
                 nrdctitg,
                 nrpedido,
                 nrcheque,
                 nrseqems,
                 nrdigchq,
                 tpcheque,
                 dtemschq,
                 dsdocmc7,
                 cdagechq,
                 cdbanchq,
                 cdcmpchq,
                 cdcooper,
                 dtconchq,
                 tpforchq)
               VALUES
                 (rw_crapass.nrdconta,  --nrdconta
                  vr_nrctaitg,          --nrdctabb
                  vr_nrctaitg,          --nrctachq
                  decode(pr_cdtipcta_ini,
                           12,rw_crapass.nrdctitg
                             ,' '),    --nrdctitg
                  rw_gnsequt.vlsequtl,  --nrpedido
                  vr_nrflcheq,          --nrcheque
                  rw_crapass.flchqitg,  --nrseqems
                  vr_nrdigchq,          --nrdigchq
                  1,                    --tpcheque
                  NULL,                 --dtemschq
                  vr_dsdocmc7,          --dsdocmc7
                  vr_cdagechq,          --cdagechq
                  pr_cdbanchq,          --cdbanchq
                  rw_crapage.cdcomchq,  --cdcmpchq
                  pr_cdcooper,          --cdcooper
                  vr_dtmvtolt,          --dtconchq
                  decode(rw_crapreq.tprequis,
                           3,'FC'
                            ,'TL'));
            EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir crapfdc na conta '||rw_crapass.nrdconta||' e cheque '||
                             vr_nrflcheq||': '||SQLERRM;
              RAISE vr_exc_saida;
            END;

            -- Acumula o total de folhas de cheques
            IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se for Talao
              vr_qttotchq_tl := vr_qttotchq_tl + 1;
            END IF;

            EXIT WHEN vr_nrflcheq >= vr_nrultchq;
            vr_nrflcheq := vr_nrflcheq + 1;
          END LOOP;

          -- Atualiza o numero da ultima folha de cheque com o digito
          vr_nrultchq := vr_nrultchq*10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrultchq); -- O retorno é ignorado, pois a variável vr_nrinichq é atualiza pelo programa

          -- Busca o tipo de requisicao
          IF rw_crapreq.tprequis = 3 THEN -- Se for formulario continuo
             vr_dstipreq := 'FC';
          ELSIF rw_crapreq.insitreq = 1 THEN -- Conta existente
             vr_dstipreq := '';
          ELSE
             vr_dstipreq := ' A';  -- CTA NOVA
          END IF;

		  -- Inicializa variaveis
          vr_tpdocptl := ' ';
          vr_nrdocptl := ' ';
          vr_cdorgexp := ' ';
          vr_cdufdptl := ' ';
          vr_nmsegtal := ' ';
          vr_literal6 := ' ';
		  vr_nmprital := rw_crapass.nmprimtl;

		  -- Busca o nome do primeito titular da conta
          IF rw_crapass.inpessoa = 1 THEN -- Se for pessoa fisica

            vr_dscpfcgc := 'CPF: ';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'999.999.999-99');
            vr_tpdocptl := rw_crapass.tpdocptl;
            vr_nrdocptl := rw_crapass.nrdocptl;
            vr_cdufdptl := rw_crapass.cdufdptl;

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapttl(pr_cdcooper,
                            rw_crapass.nrdconta,
                            1);

            FETCH cr_crapttl INTO rw_crapttl;

            IF cr_crapttl%FOUND THEN
              IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapttl.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

              -- Faz mais um fetch para buscar o segundo titular
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%FOUND THEN
                IF nvl(rw_crapttl.nmtalttl,' ') <> ' ' THEN
                  vr_nmsegtal := rw_crapttl.nmtalttl;
                ELSE
                  vr_nmsegtal := rw_crapttl.nmextttl;
                END IF;
              END IF;

            END IF;

            CLOSE cr_crapttl;

          ELSE -- Se for pessoa juridica

            vr_dscpfcgc := 'CNPJ:';
            vr_nrcpfcgc := gene0002.fn_mask(rw_crapass.nrcpfcgc,'99.999.999/9999-99');

            -- Abre o cursor contendo os titulares da conta
            OPEN cr_crapjur(pr_cdcooper,
                            rw_crapass.nrdconta);

            FETCH cr_crapjur INTO rw_crapjur;

            IF cr_crapjur%FOUND THEN
              IF nvl(rw_crapjur.nmtalttl,' ') <> ' ' THEN
                vr_nmprital := rw_crapjur.nmtalttl;
              ELSE
                vr_nmprital := rw_crapass.nmprimtl;
              END IF;

            END IF;

            CLOSE cr_crapjur;

            vr_nmsegtal := '';

          END IF;

          IF NOT (rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999) THEN -- Se nao for FC
            -- Insere as informações de detalhes do pedido da requisicao no XML
            pc_escreve_xml('<requisicao>'||
                             '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                             '<nrctaitg>'||gene0002.fn_mask(vr_nrctaitg,'9.999.999-9')       ||'</nrctaitg>'||
                             '<flchqitg>'||gene0002.fn_mask(rw_crapass.flchqitg,'zz.zzz')    ||'</flchqitg>'||
                             '<nrinichq>'||gene0002.fn_mask(vr_nrinichq,'zzz.zzz.z')         ||'</nrinichq>'||
                             '<nrultchq>'||gene0002.fn_mask(vr_nrultchq,'zzz.zzz.z')         ||'</nrultchq>'||
                             '<qtfoltal>'||to_char(rw_crapass.qtfoltal)  ||'</qtfoltal>'||
                             '<nmprimtl>'||substr(rw_crapass.nmprimtl,1,40)  ||'</nmprimtl>'||
                             '<nmsegntl>'||substr(vr_nmsegtal,1,38)  ||'</nmsegntl>'|| -- Colocado tamanho maximo de 38, pois se for maior vai distorcer o relatorio
                             '<dstipreq>'||vr_dstipreq||        '</dstipreq>'||
                           '</requisicao>',1);
            -- Atualiza o contador de REQUISICOES ou TRANSF/ABT
            IF rw_crapreq.insitreq IN (4,5) THEN
              vr_qttottrf_tl := vr_qttottrf_tl + 1;
            ELSE
              vr_qttotreq_tl := vr_qttotreq_tl + 1;
            END IF;
            
            IF rw_crapass.qtfoltal = 10 THEN
              vr_qtfoltal_10 := vr_qtfoltal_10 + 1;
            ELSE
              vr_qtfoltal_20 := vr_qtfoltal_20 + 1;
            END IF;

          END IF;

          rw_crapass.nrflcheq := vr_nrflcheq;
          -- Atualiza o numero do cheque
          BEGIN
            UPDATE crapass
               SET flchqitg = rw_crapass.flchqitg,
                   nrflcheq = vr_nrflcheq
             WHERE ROWID = rw_crapass.rowid;
          EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao marcar atualizar crapass: '||sqlerrm;
            raise vr_exc_saida;
          END;
          -- Indica que foi gerado arquivo de requisicao de talao/formulario de cheque
          vr_flggerou := true;

          /*-----------------------------------------------------*/
          -- Informações para serem geradas no arquivo de detalhe
          /*-----------------------------------------------------*/

          -- Inicializa variaveis
          rw_crapsfn.dtabtcct := NULL;

          -- Define o tipo de formulario
          IF rw_crapreq.tprequis = 1 THEN
            vr_tpformul := 'TL';
            vr_nrfolhas := rw_crapass.qtfoltal;
            vr_numtalon := rw_crapass.flchqitg;
          ELSE
            vr_tpformul := 'FC';
            vr_nrfolhas := rw_crapreq.qtreqtal;
            vr_numtalon := 0;
          END IF;

          -- Define a conta base
          IF pr_cdtipcta_ini = 12 THEN --NORMAL ITG
            IF rw_crapass.nrdctitg IS NULL THEN -- numero da conta de integracao
              vr_nrdctitg_aux := 0;
            ELSE
              -- Se o digito não for numerico
              IF SUBSTR(rw_crapass.nrdctitg,-1,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN
                vr_nrdctitg_aux := rw_crapass.nrdctitg;
              ELSE
                vr_nrdctitg_aux := substr(rw_crapass.nrdctitg,1,length(rw_crapass.nrdctitg)-1);
              END IF;
            END IF;
            vr_nrdctitg := SUBSTR(rw_crapass.nrdctitg,1,7);
            vr_nrdigctb := SUBSTR(rw_crapass.nrdctitg,8,1);
          ELSE -- Igual para IF CECRED e Bancoob
            vr_nrdctitg_aux := rw_crapass.nrdconta;
            vr_nrdctitg := substr(to_char(rw_crapass.nrdconta,'fm00000000'),1,7);
            vr_nrdigctb := substr(rw_crapass.nrdconta,-1,1);
          END IF;

          vr_auxiliar := vr_nrdctitg_aux * 10;
          vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar); -- O retorno é ignorado, pois a variável vr_agencia é atualiza pelo programa
          vr_nrdigtc2 := MOD(vr_auxiliar,10);

          --> Buscar orgão expedidor
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp, 
                                            pr_cdorgao_expedidor => vr_cdorgexp, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
            TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdorgexp := 'NAO CADAST.';
            vr_nmorgexp := NULL; 
          END IF;  

          -- Busca os dados cadastrais do titular
          IF rw_crapass.cdtipcta = 12   OR --NORMAL ITG
             rw_crapass.cdtipcta = 13   THEN --ESPECIAL ITG
            vr_literal2 := vr_dscpfcgc ||
                           rpad(vr_nrcpfcgc,18,' ')||
                           rpad(' ',7,' ') ||
                           gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z');
            vr_literal3 := rpad(vr_tpdocptl,3,' ') ||
                           SUBSTR(TRIM(vr_nrdocptl),1,15) || ' '||
                           TRIM(vr_cdorgexp)|| ' '||
                           TRIM(vr_cdufdptl);
            vr_literal4 := '';
          ELSE
            vr_literal2 := vr_nmsegtal;
            vr_literal3 := vr_dscpfcgc ||
                           rpad(vr_nrcpfcgc,18,' ')||
                           rpad(' ',7,' ') ||
                           gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z');
            vr_literal4 := rpad(vr_tpdocptl,3,' ') ||
                           SUBSTR(TRIM(vr_nrdocptl),1,15) || ' '||
                           TRIM(vr_cdorgexp)|| ' '||
                           TRIM(vr_cdufdptl);
          END IF;


          OPEN cr_crapsfn(pr_cdcooper,
                          rw_crapass.nrcpfcgc);
          FETCH cr_crapsfn INTO rw_crapsfn;
          CLOSE cr_crapsfn;

          IF rw_crapass.dtabtcct IS NOT NULL AND -- Se existir data de abertura da conta corrente
             rw_crapass.dtabtcct < rw_crapass.dtadmiss THEN -- Se a data de abertura da CC for menor que a data de admissao na CCOH
            vr_dtabtcc2 := rw_crapass.dtabtcct; -- utiliza a data de abertura da conta
          ELSE
            vr_dtabtcc2 := rw_crapass.dtadmiss; -- Utiliza a data de admissao como associado na CCOH
          END IF;


          IF rw_crapsfn.dtabtcct IS NOT NULL AND -- Se existir data de abertura de conta corrente no sistema financeiro do banco central
             rw_crapsfn.dtabtcct < vr_dtabtcc2 THEN
            vr_literal5 := 'Cliente Bancario desde: '||to_char(rw_crapsfn.dtabtcct,'MM/YYYY')||'   ';
          ELSE
            vr_literal5 := 'Cooperado desde: '||to_char(vr_dtabtcc2,'MM/YYYY')|| '          ';
          END IF;

          IF rw_crapass.cdtipcta IN (9,  --ESPEC. CONVENIO
                                     11, --CONJ.ESP.CONV.
                                     13, --ESPECIAL ITG
                                     15) THEN --ESPEC.CJTA ITG
            vr_literal6 := 'CHEQUE ESPECIAL';
          END IF;

          IF nvl(rw_crapage.dsinform##1,' ') = ' ' AND
             nvl(rw_crapage.dsinform##2,' ') = ' ' AND
             nvl(rw_crapage.dsinform##3,' ') = ' ' THEN
            vr_literal7 := rw_crapcop.dsendcop ||','||
                           gene0002.fn_mask(rw_crapcop.nrendcop,'zz,zz9');
            vr_literal8 := rw_crapcop.nmbairro ||  ' - ' ||
                           rw_crapcop.nrtelvoz;
            vr_literal9 := rw_crapcop.nmcidade || ' - '||
                           rw_crapcop.cdufdcop;
          ELSE
            vr_literal7 := rw_crapage.dsinform##1;
            vr_literal8 := rw_crapage.dsinform##2;
            vr_literal9 := rw_crapage.dsinform##3;
          END IF;

          -- Se for formulario continuo ira gerar apenas uma vez o registro
          IF vr_tpformul = 'FC' AND vr_qtreqtal > 1 THEN
            NULL;
          ELSE
            --Escrever a linha de detalhe no arquivo
            vr_dsarqdad := vr_tpformul                               || -- TIPO FORMUL
                           to_char(rw_crapreq.cdagenci,'fm000')      || -- FILIAL
                           to_char(pr_nrcontab,'fm000')              || -- NUM. CONTAB
                           vr_nrdctitg                               || -- CONTA BASE
                           vr_nrdigctb                               || -- DIG CTA BASE
                           vr_nrdigtc2                               || -- DIG CTA BASE
                           to_char(rw_crapreq.nrdconta,'fm00000000') || -- CONTA/DV
                           to_char(vr_numtalon,'fm00000')            || -- NUM TALONAR.
                           to_char(pr_nrdserie,'fm000')              || -- NUM. SERIE
                           to_char(trunc(vr_nrinichq/10),'fm000000') || -- INICIO CHQ
                           to_char(vr_nrfolhas,'fm000000')           || -- NR FOLH. CONT
                           to_char(rw_crapage.cdcomchq,'fm000')      || -- CODIGO COMP.
                           rpad(vr_nmprital,40,' ')                  || -- LITERAL 1
                           rpad(vr_literal2,40,' ')                  || -- LITERAL 2
                           rpad(vr_literal3,40,' ')                  || -- LITERAL 3
                           rpad(vr_literal4,40,' ')                  || -- LITERAL 4
                           rpad(vr_literal5,34,' ')                  || -- LITERAL 5
                           rpad(vr_literal6,15,' ')                  || -- LITERAL 6
                           rpad(UPPER(vr_literal7),40,' ')           || -- LITERAL 7
                           rpad(UPPER(vr_literal8),40,' ')           || -- LITERAL 8
                           rpad(UPPER(vr_literal9),40,' ');          -- LITERAL 9

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_dad --> Handle do arquivo aberto
                                          ,pr_des_text => vr_dsarqdad);

            -- Quantidade de Linhas do Arquivo
            vr_qtlinhas := vr_qtlinhas + 1;
          END IF;

          -- Atualiza o contados de requisicoes de talões
          vr_qtreqtal := vr_qtreqtal + 1;
        END LOOP;

        -- Se for formulario continuo, imprime somente depois do loop
        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          pc_escreve_xml('<requisicao>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<flchqitg>'||rw_crapreq.qtreqtal                               ||'</flchqitg>'||
                           '<nrinichq>'||gene0002.fn_mask(vr_nrinichq_fc,'zzz.zzz.z')      ||'</nrinichq>'||
                           '<nrultchq>'||gene0002.fn_mask(vr_nrultchq,'zzz.zzz.z')         ||'</nrultchq>'||
                           '<nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>'||
                         '</requisicao>',3);
          -- Atualiza o contador de REQUISICOES ou TRANSF/ABT
          IF rw_crapreq.insitreq IN (4,5) THEN
            vr_qttottrf_fc := vr_qttottrf_fc + 1;
          ELSE
            vr_qttotreq_fc := vr_qttotreq_fc + 1;
          END IF;
        END IF;

        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 2;

        -- Acumula o total de requisicoes para ser utilizado na insercao do crapped
        vr_qttotreq := vr_qttotreq + 1;

      ELSE -- Senao dos rejeitados

        -- Se for a primeira vez que esta entrando no rejeitados para o PAC, então
        --   cria o cabecalho do PAC
        IF NOT vr_idrejeit_tl THEN
          vr_fechapac_rej_tl := FALSE;
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'||rw_gnsequt.vlsequtl||'</vlsequtl>',2);

          -- Atualiza indicador informando que houve requisicoes rejeitadas para o PAC
          vr_idrejeit_tl := TRUE;
        END IF;

        IF NOT vr_idrejeit_fc THEN
          vr_fechapac_rej_fc := FALSE;
          pc_escreve_xml('<pac>'||
                           '<cdagenci>'||rw_crapreq.cdagenci||'</cdagenci>'||
                           '<nmresage>'||rw_crapage.nmresage||'</nmresage>'||
                           '<vlsequtl>'||rw_gnsequt.vlsequtl||'</vlsequtl>',4);

          -- Atualiza indicador informando que houve requisicoes rejeitadas para o PAC
          vr_idrejeit_fc := TRUE;
        END IF;

        -- Abre o cursor de tipo de conta
        OPEN cr_craptip(pr_cdcooper,
                        rw_crapass.cdtipcta);
        FETCH cr_craptip INTO rw_craptip;
        IF cr_craptip%NOTFOUND THEN
          rw_craptip.dstipcta := '';
        END IF;
        CLOSE cr_craptip;

        -- Busca a situacao da conta
        IF rw_crapass.cdsitdct = 1   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'NORMAL';
        ELSIF rw_crapass.cdsitdct = 2   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'ENC.P/ASSOCIADO';
        ELSIF rw_crapass.cdsitdct = 3   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'ENC. PELA COOP';
        ELSIF rw_crapass.cdsitdct = 4   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'ENC.P/DEMISSAO';
        ELSIF rw_crapass.cdsitdct = 5   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'NAO APROVADA';
        ELSIF rw_crapass.cdsitdct = 6   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'NORMAL S/TALAO';
        ELSIF rw_crapass.cdsitdct = 9   THEN
          vr_dssitdct := rw_crapass.cdsitdct||'-'||'ENC.P/O MOTIVO';
        ELSE
          vr_dssitdct := '';
        END IF;

        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);

        IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
          pc_escreve_xml('<rejeitado>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>'||
                           '<dtdemiss>'||to_char(rw_crapass.dtdemiss,'DD/MM/YYYY')||'</dtdemiss>'||
                           '<dstipcta>'||lpad(rw_crapass.cdtipcta,2,'0')||'-'||rw_craptip.dstipcta||'</dstipcta>'||
                           '<dssitdct>'||vr_dssitdct        ||'</dssitdct>'||
                           '<qtreqtal>'||rw_crapreq.qtreqtal||'</qtreqtal>'||
                           '<dscritic>'||substr(vr_dscritic,1,34)    ||'</dscritic>'||
                         '</rejeitado>',4);
          vr_qttotrej_fc := vr_qttotrej_fc + 1;
        ELSE
          pc_escreve_xml('<rejeitado>'||
                           '<nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzz.zzz.z')||'</nrdconta>'||
                           '<nmprimtl>'||substr(rw_crapass.nmprimtl,1,30)||'</nmprimtl>'||
                           '<dtdemiss>'||to_char(rw_crapass.dtdemiss,'DD/MM/YYYY')||'</dtdemiss>'||
                           '<dstipcta>'||lpad(rw_crapass.cdtipcta,2,'0')||'-'||rw_craptip.dstipcta||'</dstipcta>'||
                           '<dssitdct>'||vr_dssitdct        ||'</dssitdct>'||
                           '<qtreqtal>'||rw_crapreq.qtreqtal||'</qtreqtal>'||
                           '<dscritic>'||substr(vr_dscritic,1,34)||'</dscritic>'||
                         '</rejeitado>',2);
          vr_qttotrej_tl := vr_qttotrej_tl + 1;
        END IF;
        -- Atualiza a variavel de situacao de requisicao para depois atualizar na tabela CRAPREQ
        vr_insitreq := 3;
      END IF;

      IF rw_crapreq.tprequis = 3 AND rw_crapreq.tpformul = 999 THEN -- Se for FC
        vr_cdagenci_ant_fc := rw_crapreq.cdagenci;
      ELSE
        vr_cdagenci_ant := rw_crapreq.cdagenci;
      END IF;
      -- Atualiza a situacao da CRAPREQ
      BEGIN
        UPDATE crapreq
           SET insitreq = vr_insitreq,
               dtpedido = vr_dtmvtolt,
               nrpedido = rw_gnsequt.vlsequtl,
               cdcritic = decode(vr_cdcritic,0,cdcritic,vr_cdcritic)
         WHERE ROWID = rw_crapreq.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar CRAPREQ para a conta '||rw_crapreq.nrdconta||': '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END LOOP;

    -- Se nao teve requisicoes gera mensagem de alerta
    IF nvl(vr_qttotreq,0) + nvl(vr_qttotrej_fc,0) + nvl(vr_qttotrej_tl,0) = 0 AND  pr_cdtipcta_ini = 12 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                          ,pr_ind_tipo_log => 2 -- Erro tratado
                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || vr_cdprogra || ' --> NAO HA REQUISICOES PARA CHEQUES NORMAIS');
    END IF;



    -- Verifica se a tag PAC das requisicoes de Talões esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_req_tl THEN
      pc_escreve_xml(       '<qttotreq>'||vr_qttotreq_tl||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_tl||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_tl||'</qttotrej>'||
                          '</pac>',1);
    END IF;
    pc_escreve_xml(     '</requisicoes>',1);

    -- Verifica se a tag PAC das requisicoes de FC esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_req_fc THEN
      pc_escreve_xml(       '<qttotreq>'||vr_qttotreq_fc||'</qttotreq>'||
                            '<qttottrf>'||vr_qttottrf_fc||'</qttottrf>'||
                            '<qttotrej>'||vr_qttotrej_fc||'</qttotrej>'||
                          '</pac>',3);
    END IF;
    pc_escreve_xml(     '</requisicoes>',3);

    -- Verifica se a tag PAC dos rejeitados de Talões esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_rej_tl THEN
      pc_escreve_xml(     '</pac>',2);
    END IF;
    pc_escreve_xml(   '</rejeitados>'||
                     '</pedido>'||
                   '</crps408>',2);
    dbms_lob.append(vr_des_xml,vr_des_xml_rej);

    -- Verifica se a tag PAC dos rejeitados de FC esta fechada. Em caso negativo, fecha a tag.
    IF NOT vr_fechapac_rej_fc THEN
      pc_escreve_xml(     '</pac>',4);
    END IF;
    pc_escreve_xml(   '</rejeitados>'||
                     '</pedido>'||
                   '</crps408>',4);
    dbms_lob.append(vr_des_xml_fc,vr_des_xml_fc_rej);
    --
    IF pr_nmarqui1 IS NOT NULL THEN
    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crps408/pedido',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl392.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui1||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                pr_nrcopias  => 1,                  --> Numero de copias
                                pr_dsextmail => 'pdf', 
                                pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                pr_dsassmail => 'PEDIDO DE TALONARIOS - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                pr_des_erro  => pr_dscritic);       --> Saida com erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    END IF;

    IF vr_qttotgerreq_fc > 0 THEN -- Gerar relatorio de FC somente se existir dados
      IF pr_nmarqui3 IS NOT NULL THEN      
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml_fc,       --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crps408/pedido',   --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl572.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                  pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui3||'.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,
                                  pr_sqcabrel  => 3,
                                  pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                  pr_nrcopias  => 1,                  --> Numero de copias
                                  
                                  pr_dsextmail => 'pdf', 
                                  pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                  pr_dsassmail => 'REQUISICAO DE FORMULARIO CONTINUO - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                  pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                  pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail

                                  pr_des_erro  => pr_dscritic);       --> Saida com erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    dbms_lob.close(vr_des_xml_fc);
    dbms_lob.freetemporary(vr_des_xml_fc);
    dbms_lob.close(vr_des_xml_rej);
    dbms_lob.freetemporary(vr_des_xml_rej);
    dbms_lob.close(vr_des_xml_fc_rej);
    dbms_lob.freetemporary(vr_des_xml_fc_rej);


    ---------------------------------------------------------------------
    -- Inicio da geração do arquivo de cabecalho
    ---------------------------------------------------------------------

    -- Tenta abrir o arquivo de cabecalho em modo gravacao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio||'/arq'   --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarqctrped             --> Nome do arquivo
                            ,pr_tipabert => 'W'                        --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file_ctr          --> Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic);              --> Erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

      --  Header do Arq. para CENTRAL

      -- Calcula o digito da agencia
      vr_auxiliar := rw_crapcop.cdagectl * 10;
      vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar); -- O retorno é ignorado, pois a variável vr_agencia é atualiza pelo programa
      vr_cddigage := MOD(vr_auxiliar,10);

      -- Calcula o C1
      vr_auxiliar  := to_char(rw_crapage.cdcomchq) || to_char(rw_crapcop.cdbcoctl,'fm000');
      vr_auxiliar2 := to_char(vr_auxiliar)||to_char(rw_crapcop.cdagectl,'fm0000')||'0';
      vr_retorno   := gene0005.fn_calc_digito(pr_nrcalcul => vr_auxiliar2);
      vr_cddigtc1  := MOD(vr_auxiliar2,10);

      --Escrever o cabecalho no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_ctr --> Handle do arquivo aberto
                                    ,pr_des_text => rpad(rw_crapcop.nmrescop,20,' ') ||       -- IDENTIFIC
                                                    to_char(vr_dtmvtolt,'DD/MM/YYYY')||       -- DATA PEDIDO
                                                    to_char(rw_gnsequt.vlsequtl,'fm000000')|| -- NR DO PEDIDO
                                                    to_char(rw_crapcop.cdbcoctl,'fm000')||    -- CD BANCO
                                                    to_char(rw_crapcop.cdagectl,'fm0000')||   -- CD AGENCIA
                                                    vr_cddigage||                             -- DIG. AGE.
                                                    vr_cddigtc1||                             -- DIGITO C1
                                                    to_char(vr_qttottal_tl,'fm00000')||       -- QTD TALONAR.
                                                    to_char(vr_qttotchq_tl,'fm000000')||      -- QTD FOL CHQ
                                                    to_char(pr_cdcooper,'fm000')||            -- COOPERATIVA
                                                    'CECRED     '||                           -- CENTRAL
                                                    '00'||                                    -- GRUPO SETEC
                                                    rpad(' ',305,' '));                       -- ESPACOS

      -- Quantidade de Linhas do Arquivo
      vr_qtlinhas := vr_qtlinhas + 1;

    -- Fecha o arquivo de cabecalho
    BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file_ctr); --> Handle do arquivo aberto;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Problema ao fechar o arquivo <'||vr_nmarqctrped||'>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;

    -- Deve gerar Trailer apenas se for RR Donnelley
    IF pr_cdempres = 2 THEN

      -- Inclui Registro Trailer
      vr_qtlinhas := vr_qtlinhas + 1;

      vr_dsarqdad := '99' ||
                     to_char(vr_qtlinhas,'fm000000')||  -- Qtd. Linhas
                     rpad(' ',369,' '); -- Brancos

      -- Escreve Registro Trailher
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file_dad --> Handle do arquivo aberto
                                     ,pr_des_text => vr_dsarqdad);

    END IF;

    -- Fecha o arquivo de detalhes
    BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file_dad); --> Handle do arquivo aberto;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Problema ao fechar o arquivo <'||vr_nmarqdadped||'>: ' || sqlerrm;
        RAISE vr_exc_saida;
    END;


    ---------------------------------------------------------------------
    -- Inicio da geração do resumo
    ---------------------------------------------------------------------

    -- Insere no cadatro de pedidos de talonarios
    IF vr_flggerou THEN
      BEGIN
        INSERT INTO crapped
          (cdcooper,
           cdbanchq,
           nrpedido,
           nrseqped,
           dtsolped,
           nrdctabb,
           nrinichq,
           nrfinchq)
        VALUES
          (pr_cdcooper,
           pr_cdbanchq,
           rw_gnsequt.vlsequtl,
           1,
           vr_dtmvtolt,
           0,
           0,
           vr_qttotreq);
      EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir crapped no banco '||pr_cdbanchq||': '||SQLERRM;
        RAISE vr_exc_saida;
      END;
    END IF;

    -- Inicializar o CLOB para armazenar os arquivos XML
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      OPEN cr_crapban(pr_cdbanchq);
      FETCH cr_crapban INTO vr_nmbanco;
      CLOSE cr_crapban;

    -- Escreve o resumo para taloes
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                   '<crps408>'||
                     '<pedido>'||
                       '<vlsequtl>'||rw_gnsequt.vlsequtl              ||'</vlsequtl>'||
                       '<dtmvtolt>'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>'||
                       '<nmbanco>' ||vr_nmbanco                       ||'</nmbanco>'||
                       '<qttotchq>'||vr_qttotchq_tl                   ||'</qttotchq>'||
                       '<qttottal>'||vr_qttottal_tl                   ||'</qttottal>'||
                       '<qtfoltal10>'||vr_qtfoltal_10                   ||'</qtfoltal10>'||
                       '<qtfoltal20>'||vr_qtfoltal_20                   ||'</qtfoltal20>'||
                       '<nmrescop>'|| rw_crapcop.nmrescop             ||'</nmrescop>'||
                       '<nrdocnpj>'|| TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) ||'</nrdocnpj>'||
                     '</pedido>'||
                   '</crps408>',1);
    IF pr_nmarqui2 IS NOT NULL THEN
    -- Chamada do iReport para gerar o arquivo de saida
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crps408/pedido',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl393.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui2||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 2,
                                pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                pr_nrcopias  => 2,                  --> Numero de copias
                                pr_dsextmail => 'pdf', 
                                pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                pr_dsassmail => 'RESUMO PEDIDO DE TALONARIOS - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                pr_des_erro  => pr_dscritic);       --> Saida com erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    -- Escreve o resumo para Formulario continuo
    IF vr_qttotgerreq_fc > 0 THEN
      IF pr_nmarqui4 IS NOT NULL THEN
      vr_des_xml_fc := NULL;
      dbms_lob.createtemporary(vr_des_xml_fc, true);
      dbms_lob.open(vr_des_xml_fc, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                     '<crps408>'||
                       '<pedido>'||
                         '<vlsequtl>'||rw_gnsequt.vlsequtl              ||'</vlsequtl>'||
                         '<dtmvtolt>'||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>'||
                         '<nmbanco>' ||vr_nmbanco                       ||'</nmbanco>'||
                         '<qttotchq>'||vr_qttottal_fc                   ||'</qttotchq>'||
                         '<qttotreq>'||vr_qttotgerreq_fc                ||'</qttotreq>'||
                       '</pedido>'||
                     '</crps408>',3);

      -- Gerar arquivos XML
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml_fc,       --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crps408/pedido',   --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl573.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => 'PR_NMEMPRES##'||vr_nmempres, --> Enviar como parametro apenas a agencia
                                  pr_dsarqsaid => vr_nom_diretorio||'/rl/'||pr_nmarqui4||'.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,
                                  pr_sqcabrel  => 3,
                                  pr_flg_impri => pr_flg_impri,       --> Indicador se imprimira o relatorio
                                  pr_nrcopias  => 2,                  --> Numero de copias
                                  
                                  pr_dsextmail => 'pdf', 
                                  pr_dsmailcop => vr_email_dest, --> Lista sep. por ';' de emails para envio do arquivo
                                  pr_dsassmail => 'RESUMO REQUISICOES DE FORMULARIO CONTINUO - ' || rw_crapcop.nmrescop, --> Assunto do e-mail que enviará o arquivo
                                  pr_dscormail => NULL, --> HTML corpo do email que enviará o arquivo
                                  pr_fldosmail => 'S', --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                  
                                  pr_des_erro  => pr_dscritic);       --> Saida com erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_des_xml_fc);
      dbms_lob.freetemporary(vr_des_xml_fc);
    END IF;
    END IF;

    -- Acumula o arquivo de cabecalho com o arquivo de dados no arquivo principal
    gene0001.pc_OScommand_Shell(pr_des_comando => 'cat '||vr_nom_diretorio||'/arq/'||vr_nmarqctrped || ' ' ||
                                                          vr_nom_diretorio||'/arq/'||vr_nmarqdadped || ' > ' ||
                                                          vr_nom_diretorio||'/arq/'||vr_nmarqped    ||
                                                          ' 2> /dev/null');

    -- Gera o arquivo de transmissao vazio
    gene0001.pc_OScommand_Shell(pr_des_comando => '> '||vr_nom_diretorio||'/arq/'||vr_nmarqtransm || ' 2> /dev/null');

    -- Efetua o processo de copia e/ou exclusao de arquivos
    IF vr_flggerou THEN

      IF pr_cdempres = 1 THEN
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_nom_diretorio||'/arq/'||vr_nmarqped || ' '||
                                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'DIR_NEXXERA'));
      ELSE

        -- Caminho do script que envia/recebe via SFTP
        vr_script    := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'RRD_SCRIPT');
        -- Endereço do Servidor SFTP                                                      
        vr_serv_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_SERV_SFTP');
        -- Usuario do Servidor SFTP                                                      
        vr_user_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_USER_FTP');
        -- Password do Servidor SFTP 
        vr_pass_sftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'RRD_PASS_FTP');
        -- Diretotio Remoto de Upload no Servidor SFTP                                         
        vr_dir_remoto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => '0'
                                                  ,pr_cdacesso => 'RRD_DIR_UPLOAD');

        vr_comando := vr_script                                      || ' ' || -- Script Shell
    --  '-recebe'                                                    || ' ' ||
        '-envia'                                                     || ' ' || -- Enviar/Receber
        '-srv '         || vr_serv_sftp                              || ' ' || -- Servidor
        '-usr '         || vr_user_sftp                              || ' ' || -- Usuario
        '-pass '        || vr_pass_sftp                              || ' ' || -- Senha
        '-arq '         || CHR(39) || vr_nmarqped || CHR(39)         || ' ' || -- Nome do Arquivo .RET
        '-dir_local '   || vr_nom_diretorio || '/arq/'               || ' ' || -- /usr/coop/<cooperativa>/arq
        '-dir_remoto '  || vr_dir_remoto                             || ' ' || -- /<conta do cooperado>/RETORNO
        '-salvar '      || vr_nom_diretorio || '/salvar'             || ' ' || -- /usr/coop/<cooperativa>/salvar
        '-log '         || vr_nom_diretorio || '/log/env_arq_ftp_rrd.log';     -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log


        --Buscar parametros
        vr_dscomora:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
        vr_dsdirbin:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');

        -- Comando para criptografar o arquivo
        vr_comando:= vr_dscomora ||' perl_remoto ' || vr_comando;

        --vr_comando := replace(vr_comando,'coopd','coop');
        --vr_comando := replace(vr_comando,'cooph','coop');
        
        -- Ajuste temporario, apenas para garantir a
        -- geração do arquivo antes de enviar.
        IF pr_cdcooper = 1 THEN
          -- Aguardar 10 segundos
          sys.dbms_lock.sleep(10);
        END IF;  
        
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_des_saida);

        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          -- Envio Centralizado de Log de Erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- ERRO TRATATO
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' -' || vr_cdprogra || ' --> ' ||
                                                        'ERRO ao enviar arquivo(' || vr_nmarqped ||
                                                        ') via SFTP - ' || vr_des_saida);
        END IF;


      END IF;
    ELSE
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nom_diretorio||'/arq/'||vr_nmarqdadped||' 2> /dev/null');
    END IF;

    -- Efetua a movimentacao para o diretorio SALVAR
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nom_diretorio||'/arq/'||vr_nmarqped || ' '||
                                                         vr_nom_diretorio||'/salvar');

  END;


/*------------------------------------
-- INICIO DA ROTINA PRINCIPAL
--------------------------------------*/
BEGIN
  -- Nome do programa
  vr_cdprogra := 'CRPS408';
  -- Validacões iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS408',
                             pr_action => vr_cdprogra);


  -- Busca os dados da cooperativa
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;

  -- Busca a data do movimento
  OPEN cr_crapdat(pr_cdcooper);
    FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;

  -- busca numero do ultimo cheque
  OPEN cr_craptab(pr_cdcooper);
  FETCH cr_craptab INTO rw_craptab;
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    pr_cdcritic := 247;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    raise vr_exc_saida;
  END IF;
  CLOSE cr_craptab;

  -- Rotina para buscar o diretorio onde o arquivo sera gerado
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl


  -- Monta Busca de Parametro com base dia da semana
  vr_cdacesso := 'CRPS408_CHEQUE_' || to_char(vr_dtmvtolt,'DY','NLS_DATE_LANGUAGE = PORTUGUESE'); 
     
  -- Busca Codigo da Empresa
  vr_cdempres := to_number(NVL(gene0001.fn_param_sistema('CRED',0,vr_cdacesso),0));

  -- Segunda e Quinta      - InterPrint
  -- Terça, Quarta e Sexta - RR Donnelley

  -- Caso não Encontrar Empresa
  IF NVL(vr_cdempres,0) = 0 THEN
    vr_cdempres := 2; -- RR Donnelley
  END IF;
  
  -- Sempre que for RR Donnelley busca lista de email
  IF ( vr_cdempres = 2 ) THEN
    --Recuperar emails de destino
    vr_email_dest := gene0001.fn_param_sistema('CRED',0,'CRPS408_EMAIL_RRD');
  ELSE 
    vr_email_dest := NULL;  
  END IF;  

  -- CECRED
  Pc_Gera_Talonario(pr_cdcooper     => pr_cdcooper,
                    pr_cdtipcta_ini => 08, --NORMAL CONVENIO
                    pr_cdtipcta_fim => 11, --CONJ.ESP.CONV.
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => 'crrl392_03',
                    pr_nmarqui2     => 'crrl393_03',
                    pr_nmarqui3     => NULL, --'crrl572_03',
                    pr_nmarqui4     => NULL, --'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 1);
  -- CECRED
  Pc_Gera_Talonario(pr_cdcooper     => pr_cdcooper,
                    pr_cdtipcta_ini => 08, --NORMAL CONVENIO
                    pr_cdtipcta_fim => 11, --CONJ.ESP.CONV.
                    pr_cdbanchq     => rw_crapcop.cdbcoctl,
                    pr_nrcontab     => 0,
                    pr_nrdserie     => 1,
                    pr_nmarqui1     => NULL, --'crrl392_03',
                    pr_nmarqui2     => NULL, --'crrl393_03',
                    pr_nmarqui3     => 'crrl572_03',
                    pr_nmarqui4     => 'crrl573_03',
                    pr_flg_impri    => 'S',
                    pr_cdempres     => vr_cdempres,
                    pr_tprequis     => 3);   


  -- Testar se houve erro
  IF pr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    pr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  COMMIT;
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || pr_dscritic );
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;
    pr_cdcritic := 0;
    pr_dscritic := NULL;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END;
/
