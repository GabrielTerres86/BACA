create or replace procedure cecred.pc_crps535(pr_cdcooper  in craptab.cdcooper%type,
                                       pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                       pr_nmtelant  IN VARCHAR2,               --> Descricao da tela anterior
                                       pr_stprogra out pls_integer,            --> Saída de termino da execução
                                       pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                       pr_cdcritic out crapcri.cdcritic%type,
                                       pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps535 - antigo Fontes/crps535.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Dezembro/2009                   Ultima atualizacao: 03/04/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Processamento de devolucoes dos depositos em cheques que foram
               devolvidos.
               Emite relatorio 529 e 530.

   Alteracoes: 15/12/2009 - Versao Inicial (Guilherme/SUPERO)

               04/06/2010 - Acertos Gerais (Ze).

               08/06/2010 - Nao ler crapass qdo nao encontrar crapchd (Magui).

               15/06/2010 - Nao usar campos de arquivos na procedure
                            pi_cria_generica(Magui).

               16/06/2010 - Acertos Gerais (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               13/09/2010 - Acerto para geracao do relatorio no diretorio
                            rlnsv (Vitor)

               10/12/2010 - Incluir Historico 881 - IF Cecred (Ze).

               14/01/2011 - Alterado layout do relatorio devido a alteracao
                            do format do campo nmprimtl (Henrique).

               07/02/2011 - Tratamento de Cheques em Custodia e Contas Trans-
                            ferida - semelhante ao crps360 BB (Ze).

               21/03/2011 - Alterado p/ separar o relatorio 530 por PAC (Vitor)

               24/05/2011 - Evitar o duplicates no gncpdev (Ze).

               06/06/2011 - Incluido as colunas produto, Lote/Bordero,
                            Entrada, Liberacao, Nro. Previa (Adriano/Elton).

               07/06/2011 - Para custodia/desconto considerar o PAC do crapcst
                            ou crapcdb (Ze).

               03/08/2011 - Tratamento para LANCHQ (Elton).

               25/10/2011 - Incluido coluna "C/ IMAGEM" no relatorio 529
                            (Adriano).

               22/11/2011 - Alterado de NAO para Espacos a inf. da coluna
                            C/Imagem - ate a nova DLL (Ze).

               19/04/2012 - Alteracao de espaco em branco para "NAO" a
                            informacao da coluna C/Imagem (Elton).

               15/08/2012 - Alterado posigues do gncpdev.cdtipdoc de 52,2
                            para 148,3 (Lucas R.).

               17/08/2012 - Tratamento cheque VLB (Fabricio).

               20/12/2012 - Adaptacao para Migracao da AltoVale (Ze).

               22/04/2013 - Alterar o layout do relatorio 530,reduzido
                            as linhas em branco e inserida tabela no
                            final da pagina (Daniele).

               02/08/2013 - Alterado para pegar o telefone da tabela
                            craptfc ao invés da crapass (James).

               13/11/2013 - Conversão Progress >> Oracle PL/SQL (Andrino - RKAM).

               05/12/2013 - Implementar nova metodologia de listagem de arquivos (Petter - Supero).

               01/10/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               05/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).

               22/01/2014 - Alterado a validação de final de arquivo, pois o
                            comando tail -1 no oracle retorna o caracter de final de arquivo
                            diferentemente se for executado direto no unix. (Odirlei-AMcom)

						   11/06/2014 - Alterado para permitir devoluções de cheques inter-
							              cooperativa. (Reinert)

               17/09/2014 - Incluso tratamento para incorporação cooperativa (Daniel)

			         21/11/2014 - Incluso tratamento para incorporação VIACON SCRMIL (Reinert)
               
               18/12/2014 - Ajustes tratamento para incorporação VIACON SCRMIL (Daniel)
               
               01/04/2015 - Remocao da formatacao da mascara do campo nrprevia do XML.
                            (Jaison/Elton - SD: 269550)
                            
               18/01/2016 - Alterado log do proc_batch para o proc_message (Daniel)             

               25/04/2016 - Ajustes no relatorio 530 referente a melhoria 112
                            (Tiago/Elton).
                            
               24/06/2016 - Verificar se a agencia acolhedora possui informacao ZERO, se 
                            possuir deve utilizar a agencia de destino (Douglas - Chamado 431378)
                            
			   22/07/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica de cheques
                            (Lucas Ranghetti #484923)

               25/08/2016 - Permite integrar arquivos de cheques DVA615 devido
                            aos cheques VLB (Elton - SD 476261)

			   04/11/2016 - Ajustar cursor de custodia de cheques - Projeto 300 (Rafael)                            

               02/12/2016 - Incorporação Transulcred (Guilherme/SUPERO)

               07/04/2017 - #642531 Tratamento do tail para pegar/validar os dados da última linha
                            do arquivo corretamente (Carlos)	 

               21/06/2017 - Remoção do processamento do arquivo de cheque VLB(DVN) e tratado novo 
                            arquivo de devolução em contingência(DCG). Ajuste nos historicos.
                            PRJ367 - Compe Sessao Unica (Lombardi)
                            
               03/04/2018 - Tratamento historicos COMPE SESSAO UNICA (Diego).

			   11/04/2018 - Correção na nomenclatura do arquivo de contingência - COMPE SESSAO UNICA (Diego).
               
               23/05/2018 - P450 - Alteração INSERT na craplcm e lot pelas chamadas da rotina LANC0001
                            Renato Cordeiro (AMcom)         
............................................................................. */

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Leitura sobre a tabela de cooperativas
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%type) is
    SELECT cdagectl,
           nrtelsac,
           nrtelouv,
           hrinisac,
           hrfimsac,
           hriniouv,
           hrfimouv
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Buscar informações da cooperativa antiga
  CURSOR cr_crabcop(pr_cdcopant craptco.cdcopant%TYPE) IS
    SELECT crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcopant;
  rw_crabcop cr_crabcop%ROWTYPE;

  -- Cursor para busca de cooperativa a partir da agencia na central
  CURSOR cr_crapcop_ctl(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdagectl = pr_cdagectl;
  rw_crapcop_ctl cr_crapcop_ctl%ROWTYPE;


  -- Cursor sobre cadastro de dados genericos
  CURSOR cr_craptab(pr_cdcooper in craptab.cdcooper%TYPE,
                    pr_tptabela IN craptab.tptabela%TYPE,
                    pr_cdacesso IN craptab.cdacesso%TYPE,
                    pr_tpregist IN craptab.tpregist%TYPE) is
    SELECT dstextab
      FROM craptab
     WHERE craptab.cdcooper = 1
       AND craptab.nmsistem = 'CRED'
       AND craptab.tptabela = pr_tptabela
       AND craptab.cdempres = 0
       AND craptab.cdacesso = pr_cdacesso
       AND craptab.tpregist = pr_tpregist;
  rw_craptab cr_craptab%ROWTYPE;

  -- cursor sobre o cadastro de cheques
  CURSOR cr_crapchd(pr_cdcooper in crapchd.cdcooper%TYPE,
                    pr_cdbanchq IN crapchd.cdbanchq%TYPE,
                    pr_cdagechq IN crapchd.cdagechq%TYPE,
                    pr_nrctachq IN crapchd.nrctachq%TYPE,
                    pr_nrcheque IN crapchd.nrcheque%TYPE) is
    SELECT nrdconta,
           cdagenci,
           cdbccxlt,
           nrdolote,
           nrdocmto,
           nrcheque,
           nrctachq,
           cdagechq,
           cdcmpchq,
           cdbanchq,
           vlcheque,
           dsdocmc7,
           nrcnvbol,
           nrctabol,
           nrboleto,
           nrprevia,
           dtmvtolt,
           insitprv,
					 nrctadst
      FROM crapchd
     WHERE crapchd.cdcooper = pr_cdcooper
       AND crapchd.cdbanchq = pr_cdbanchq
       AND crapchd.cdagechq = pr_cdagechq
       AND crapchd.nrctachq = pr_nrctachq
       AND crapchd.nrcheque = pr_nrcheque;
  rw_crapchd cr_crapchd%ROWTYPE;

  --Selecionar informacoes dos associados e saldos das contas
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT nmprimtl,
		       cdagenci
      FROM crapass crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

    -- Buscar Cadastro dos numeros de telefone de cada titular da conta.
  CURSOR cr_craptfc (pr_cdcooper IN craptab.cdcooper%TYPE,
                     pr_nrdconta IN craptfc.nrdconta%TYPE,
                     pr_idseqttl IN craptfc.idseqttl%TYPE) IS
    SELECT nrdddtfc,
           nrtelefo
      FROM craptfc
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND idseqttl = pr_idseqttl
      ORDER BY progress_recid;
  rw_craptfc cr_craptfc%ROWTYPE;

  --Selecionar Transferencias entre cooperativas
  CURSOR cr_craptco (pr_cdcooper IN craptco.cdcopant%TYPE
                    ,pr_nrctaant IN craptco.nrctaant%TYPE
                    ,pr_tpctatrf IN craptco.tpctatrf%TYPE
                    ,pr_flgativo IN craptco.flgativo%TYPE) IS
    SELECT craptco.cdcopant
          ,craptco.nrctaant
          ,craptco.nrdconta
          ,craptco.cdcooper
    FROM craptco craptco
    WHERE craptco.cdcopant = pr_cdcooper
    AND   craptco.nrctaant = pr_nrctaant
    AND   craptco.tpctatrf = pr_tpctatrf
    AND   craptco.flgativo = pr_flgativo;
   rw_craptco cr_craptco%ROWTYPE;

  CURSOR cr_craptco_inc (pr_cdcooper IN craptco.cdcooper%TYPE
                        ,pr_cdcopant in craptco.cdcopant%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE) IS
        SELECT craptco.cdcopant
              ,craptco.nrctaant
              ,craptco.nrdconta
              ,craptco.cdcooper
        FROM craptco craptco
        WHERE craptco.cdcopant = pr_cdcopant
        AND   craptco.cdcooper = pr_cdcooper
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo;
   rw_craptco_inc cr_craptco_inc%ROWTYPE;


  --Cursor de cheques devolvidos
  CURSOR cr_gncpdev(pr_cdcooper gncpdev.cdcooper%TYPE,
                    pr_dtmvtolt gncpdev.dtmvtolt%TYPE,
                    pr_cdbanchq gncpdev.cdbanchq%TYPE,
                    pr_cdagechq gncpdev.cdagechq%TYPE,
                    pr_nrctachq gncpdev.nrctachq%TYPE,
                    pr_nrcheque gncpdev.nrcheque%TYPE) IS
    SELECT cdcooper
      FROM gncpdev
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = pr_dtmvtolt
       AND cdbanchq = pr_cdbanchq
       AND cdagechq = pr_cdagechq
       AND nrctachq = pr_nrctachq
       AND nrcheque = pr_nrcheque;
  rw_gncpdev cr_gncpdev%ROWTYPE;

  -- Buscar informações de depósitos bloqueados
  CURSOR cr_crapdpb(pr_cdcooper crapdpb.cdcooper%TYPE,
                    pr_dtmvtolt crapdpb.dtmvtolt%TYPE,
                    pr_cdagenci crapdpb.cdagenci%TYPE,
                    pr_cdbccxlt crapdpb.cdbccxlt%TYPE,
                    pr_nrdolote crapdpb.nrdolote%TYPE,
                    pr_nrdconta crapdpb.nrdconta%TYPE,
                    pr_nrdocmto crapdpb.nrdocmto%TYPE) IS
    SELECT dpb.inlibera
          ,dpb.dtliblan
          ,dpb.cdhistor
          ,dpb.vllanmto
          ,ROWID
      FROM crapdpb dpb
     WHERE dpb.cdcooper = pr_cdcooper
       AND dpb.dtmvtolt = pr_dtmvtolt
       AND dpb.cdagenci = pr_cdagenci
       AND dpb.cdbccxlt = pr_cdbccxlt
       AND dpb.nrdolote = pr_nrdolote
       AND dpb.nrdconta = pr_nrdconta
       AND dpb.nrdocmto = pr_nrdocmto;
  rw_crapdpb cr_crapdpb%ROWTYPE;

  -- cursor de capas de lote
  CURSOR cr_craplot (pr_cdcooper  IN craplrg.cdcooper%TYPE      --> Código cooperativa
                    ,pr_dtmvtolt  IN craplrg.dtresgat%TYPE      --> Data movimento atual
                    ,pr_cdagenci  IN craplap.cdagenci%TYPE      --> código agência
                    ,pr_cdbccxlt  IN craplap.cdbccxlt%TYPE      --> Código caixa/banco
                    ,pr_nrdolote  IN craplap.nrdolote%TYPE) IS  --> Número do lote
    SELECT co.nrseqdig
          ,co.vlinfodb
          ,co.vlcompdb
          ,co.tplotmov
          ,co.qtinfoln
          ,co.qtcompln
          ,co.vlinfocr
          ,co.vlcompcr
          ,ROWID
    FROM craplot co
    WHERE co.cdcooper = pr_cdcooper
      AND co.dtmvtolt = pr_dtmvtolt
      AND co.cdagenci = pr_cdagenci
      AND co.cdbccxlt = pr_cdbccxlt
      AND co.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  --Selecionar informacoes dos lancamentos na conta
  CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE
                    ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                    ,pr_cdagenci craplcm.cdagenci%TYPE
                    ,pr_cdbccxlt craplcm.cdbccxlt%TYPE
                    ,pr_nrdolote craplcm.nrdolote%TYPE
                    ,pr_nrdctabb craplcm.nrdctabb%TYPE
                    ,pr_nrdocmto craplcm.nrdocmto%TYPE) IS
    SELECT /*+ INDEX (craplcm craplcm##craplcm1) */
          craplcm.vllanmto
     FROM craplcm craplcm
    WHERE cdcooper = pr_cdcooper
      AND dtmvtolt = pr_dtmvtolt
      AND cdagenci = pr_cdagenci
      AND cdbccxlt = pr_cdbccxlt
      AND nrdolote = pr_nrdolote
      AND nrdctabb = pr_nrdctabb
      AND nrdocmto = pr_nrdocmto;
  rw_craplcm cr_craplcm%ROWTYPE;

  -- Cursor sobre a tabela de custodia de cheques
  CURSOR cr_crapcst (pr_cdcooper crapcst.cdcooper%TYPE
                    ,pr_dsdocmc7 crapcst.dsdocmc7%TYPE) IS
    SELECT nrdolote,
           dtmvtolt,
           dtlibera,
           cdagenci,
           insitprv,
           dtprevia
      FROM crapcst
     WHERE crapcst.cdcooper        = pr_cdcooper
       AND upper(crapcst.dsdocmc7) = upper(pr_dsdocmc7)
       AND crapcst.nrborder        = 0
      ORDER BY PROGRESS_RECID DESC;
  rw_crapcst cr_crapcst%ROWTYPE;

  -- Cursor sobre a tabela de Cheques contidos do Bordero de desconto de cheques
  CURSOR cr_crapcdb (pr_cdcooper crapcdb.cdcooper%TYPE
                    ,pr_dsdocmc7 crapcdb.dsdocmc7%TYPE) IS
    SELECT nrborder,
           dtmvtolt,
           dtlibera,
           cdagenci,
           insitprv,
           dtprevia,
           dtlibbdc
      FROM crapcdb
     WHERE cdcooper        = pr_cdcooper
       AND upper(dsdocmc7) = upper(pr_dsdocmc7)
      ORDER BY PROGRESS_RECID DESC;
  rw_crapcdb cr_crapcdb%ROWTYPE;

  -- Cursor para buscar a descricao do Alinea
  CURSOR cr_crapali(pr_cdalinea crapali.cdalinea%TYPE) IS
    SELECT dsalinea
      FROM crapali
     WHERE cdalinea = pr_cdalinea;

  --Selecionar informacoes das agencias
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE,
                     pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.nmresage
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  --Buscar flag de reapresentação automatica de cheque
  CURSOR cr_reapr (pr_cdcooper IN craptab.cdcooper%TYPE,
                   pr_nrdconta IN craptfc.nrdconta%TYPE) IS
    SELECT flgreapre_autom as flgreapr
      FROM tbchq_param_conta
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  rw_reapr cr_reapr%ROWTYPE;  

  -- Tipo de registro para armazenar o conteudo dos arquivos
  TYPE typ_crawrel  IS
  RECORD (cdagenci crapass.cdagenci%TYPE
         ,nrdconta crapass.nrdconta%TYPE
         ,nmprimtl crapass.nmprimtl%TYPE
         ,nrfonres VARCHAR2(20)
         ,cdcmpchq crapchd.cdcmpchq%TYPE
         ,cdagechq crapchd.cdagechq%TYPE
         ,cdbanchq crapchd.cdbanchq%TYPE
         ,nrctachq crapchd.nrctachq%TYPE
         ,nrcheque crapchd.nrcheque%TYPE
         ,nralinea PLS_INTEGER
         ,dsprodut VARCHAR2(100)
         ,lotborde crapcst.nrdolote%TYPE
         ,nrprevia NUMBER(10)
         ,vlcheque crapchd.vlcheque%TYPE
         ,dtmvtolt DATE
         ,dtlibera DATE
         ,insitprv NUMBER(03)
         ,flgmigra NUMBER(01)
     ,cdageapr crapcop.cdagectl%TYPE
     ,flgreapr tbchq_param_conta.flgreapre_autom%TYPE);

  -- Tipo de registro para armazenar o conteudo dos boletos
  TYPE typ_crawbol  IS
  RECORD (cdagenci crapchd.cdagenci%TYPE
         ,nrboleto crapchd.nrboleto%TYPE
         ,nrctabol crapchd.nrctabol%TYPE
         ,nrcnvbol crapchd.nrcnvbol%TYPE
         ,vlcheque crapchd.vlcheque%TYPE);

  -- Definicao do tipo de tabela para a conteudo do arquivo
  TYPE typ_tab_crawrel IS
    TABLE OF typ_crawrel
    INDEX BY VARCHAR2(41);

  -- Definicao do tipo de tabela para a conteudo dos boletos
  TYPE typ_tab_crawbol IS
    TABLE OF typ_crawbol
    INDEX BY PLS_INTEGER;

  -- Tipo de registro para armazenar os arquivos lidos do diretorio
  TYPE typ_diretorio IS RECORD (idarquivo     NUMBER  -- 1 = DDN e DNN; 2 = DNC
                               ,nmarquivo     VARCHAR2(200));
  TYPE typ_tabarq  IS TABLE OF typ_diretorio INDEX BY BINARY_INTEGER;

  --
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_cdcritic      PLS_INTEGER;
  vr_dscritic      VARCHAR2(4000);
  -- Variaveis de impressao
  vr_vltarifa      NUMBER(12,2);
  -- Variaveis para a leitura dos arquivos
  vr_utlfileh      UTL_FILE.file_type;
  vr_diretori      VARCHAR2(100);
  vr_diretori_rl   VARCHAR2(100);
  vr_array_arquivo GENE0002.typ_split;
  vr_arquivos      typ_tabarq;
  vr_dstexto       VARCHAR2(500);
  ww_nrlinha       NUMBER(06);
  vr_dspathcop     VARCHAR2(100);
  -- Vetores de memoria
  vr_tab_crawrel   typ_tab_crawrel;
  vr_tab_crawrel_2 typ_tab_crawrel; -- Esta variavel sera igual a vr_tab_crawrel, porem com outra ordenacao
  vr_tab_crawbol   typ_tab_crawbol;
  -- Variaveis do comando unix
  vr_typ_saida     VARCHAR2(50);
  vr_des_saida     VARCHAR2(500);
  -- Variaveis temporarias para processo do arquivo
  vr_cdbanchq      crapchd.cdbanchq%TYPE;
  vr_cdagechq      crapchd.cdagechq%TYPE;
  vr_nrctachq      crapchd.nrctachq%TYPE;
  vr_nrcheque      crapchd.nrcheque%TYPE;
  vr_nrcheque_tmp  crapchd.nrcheque%TYPE;
  vr_cdalinea      PLS_INTEGER;
  vr_nrtelefo      VARCHAR2(20);
  vr_cdperdev      NUMBER(01);
	vr_cdageapr      NUMBER(04);              -- Código da agencia apresentante
	vr_nrctachd      crapchd.nrdconta%TYPE;   -- Nr. da conta de depósito
	vr_dtdapres      crapddi.dtdeposi%TYPE;
  -- Variaveis utilizadas para processo de depositos bloqueados
  vr_dpb_cdagenci  crapchd.cdagenci%TYPE;
  vr_dpb_cdbccxlt  crapchd.cdbccxlt%TYPE;
  vr_dpb_nrdolote  crapchd.nrdolote%TYPE;
  vr_cdhistor      PLS_INTEGER;
  -- Variaveis de indices
  vr_ind_crawrel   VARCHAR2(31);
  vr_ind_crawrel_2 VARCHAR2(41);
  vr_nrcontad      NUMBER(05) := 0;
  -- Variaveis do XML
  vr_des_xml       CLOB;
  vr_des_xml_tmp   CLOB;
  vr_des_xml_999   CLOB;
  -- Variaveis utilizadas para geracao do CRRL530
  vr_qtdecheq      PLS_INTEGER;
  vr_totdcheq      NUMBER(15,2);
  vr_dsalinea      crapali.dsalinea%TYPE;
  -- Variaveis utilizadas para geracao do CRRL529
  vr_qtdcstod      PLS_INTEGER  :=0;
  vr_totcstod      NUMBER(15,2) :=0;
  vr_qtddscon      PLS_INTEGER  :=0;
  vr_totdscon      NUMBER(15,2) :=0;
  vr_qtdlnchq      PLS_INTEGER  :=0;
  vr_totlnchq      NUMBER(15,2) :=0;
  vr_qtdcaixa      PLS_INTEGER  :=0;
  vr_totcaixa      NUMBER(15,2) :=0;
  vr_qtdcstod_ger  PLS_INTEGER  :=0;
  vr_totcstod_ger  NUMBER(15,2) :=0;
  vr_qtddscon_ger  PLS_INTEGER  :=0;
  vr_totdscon_ger  NUMBER(15,2) :=0;
  vr_qtdlnchq_ger  PLS_INTEGER  :=0;
  vr_totlnchq_ger  NUMBER(15,2) :=0;
  vr_qtdcaixa_ger  PLS_INTEGER  :=0;
  vr_totcaixa_ger  NUMBER(15,2) :=0;
  vr_email_dest    VARCHAR2(200);
  vr_dsassmail     VARCHAR2(200);
  -- Variaveis gerais
  vr_dtleiarq      DATE;
  vr_lscontas      VARCHAR2(500);
  vr_flgrejei      BOOLEAN;
  vr_rowid_craplot VARCHAR2(50);
  vr_nmarquiv      VARCHAR2(50);
  vr_dssitprv      VARCHAR2(03);
  vr_listarq       VARCHAR2(32767);
  vr_cdcoptfn      PLS_INTEGER :=0;
  vr_cdcooper      crapcop.cdcooper%TYPE;
  vr_nrdconta      craptco.nrdconta%TYPE;
  vr_cdagenci_ass      crapchd.cdagenci%TYPE;
  vr_cdcopaco      crapcop.cdcooper%type;
  
    vr_rowid     ROWID;
    vr_nmtabela  VARCHAR2(100);
    vr_incrineg  INTEGER;

  vr_nome_arq_log  VARCHAR2(1000);

  vr_rw_craplot  lanc0001.cr_craplot%ROWTYPE;
  vr_tab_retorno lanc0001.typ_reg_retorno;
  vr_flgreapr    VARCHAR2(03);

  PROCEDURE pc_escreve_xml(pr_des_dados in VARCHAR2,
                           pr_idtipo    IN NUMBER) IS
  BEGIN
    IF pr_idtipo = 1 THEN -- Arquivo quebrado por agencia
      dbms_lob.writeappend(vr_des_xml,        length(pr_des_dados), pr_des_dados);
    ELSIF pr_idtipo = 3 THEN -- Arquivo temporario quebrado por agencia
      dbms_lob.writeappend(vr_des_xml_tmp,    length(pr_des_dados), pr_des_dados);
    ELSE -- Arquivo agrupador (arquivo 999)
      dbms_lob.writeappend(vr_des_xml_999,     length(pr_des_dados), pr_des_dados);
    END IF;
  END;

  -- Rotina utilizada para inserir dados sobre a GNCPDEV (Compensacao de Cheques Devolvidos da Central)
  PROCEDURE PC_CRIA_GENERICA(pr_cdcritic IN NUMBER,
                             pr_cdalinea IN NUMBER,
                             pr_nmarquiv IN VARCHAR2) IS
  BEGIN

    -- Se já existir registro de devolucao nao faz insert
    OPEN cr_gncpdev(pr_cdcooper => nvl(rw_craptco.cdcooper, pr_cdcooper),
                    pr_dtmvtolt => vr_dtleiarq,
                    pr_cdbanchq => vr_cdbanchq,
                    pr_cdagechq => vr_cdagechq,
                    pr_nrctachq => vr_nrctachq,
                    pr_nrcheque => vr_nrcheque);
    FETCH cr_gncpdev INTO rw_gncpdev;
    IF cr_gncpdev%NOTFOUND THEN
      -- Criação de registro de cheques devolvidos
      BEGIN
        INSERT INTO gncpdev
          (cdcooper,
           cdagenci,
           dtmvtolt,
           dtliquid,
           cdagectl,
           cdbanchq,
           cdagechq,
           nrctachq,
           nrcheque,
           nrddigv2,
           cdcmpchq,
           cdtipchq,
           nrddigv1,
           vlcheque,
           nrdconta,
           nmarquiv,
           cdoperad,
           hrtransa,
           cdtipreg,
           flgconci,
           flgpcctl,
           nrseqarq,
           cdcritic,
           cdalinea,
           cdperdev,
           cdtipdoc,
           nrddigv3)
         VALUES
          (nvl(rw_craptco.cdcooper, pr_cdcooper),
           1,
           vr_dtleiarq,
           rw_crapdat.dtmvtolt,
           rw_crapcop.cdagectl,
           vr_cdbanchq,
           vr_cdagechq,
           vr_nrctachq,
           vr_nrcheque,
           SUBSTR(vr_dstexto,11,1),
           SUBSTR(vr_dstexto,01,3),
           SUBSTR(vr_dstexto,51,1),
           SUBSTR(vr_dstexto,24,1),
           SUBSTR(vr_dstexto,34,17) / 100,
           nvl(vr_nrctachd,0),
           pr_nmarquiv,
           1,
           to_char(SYSDATE,'sssss'),
           decode(pr_cdcritic,0,4,3),
           0,
           0,
           SUBSTR(vr_dstexto,151,10),
           pr_cdcritic,
           pr_cdalinea,
           vr_cdperdev,
           SUBSTR(vr_dstexto,148,3),
           SUBSTR(vr_dstexto,31,1));
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir gncpdev: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
    CLOSE cr_gncpdev;
  END;


-- Programa principal
BEGIN
  -- Nome do programa
  vr_cdprogra := 'CRPS535';

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS535',
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  close btch0001.cr_crapdat;
  --

  -- Buscar a os dados da cooperativa
  OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
  CLOSE cr_crapcop;
  --
  
  -- Busca nome do arquivo de log
  vr_nome_arq_log := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');

  -- VIACON - Tratamento para buscar dados cooperativa incorporada
  IF pr_cdcooper IN (1,9,13) THEN

    CASE pr_cdcooper
      WHEN 1   THEN vr_cdcooper := 4;  --    VIACREDI --> CONCREDI
      WHEN 13  THEN vr_cdcooper := 15; --     SCRCRED --> CREDIMILSUL
      WHEN 9   THEN vr_cdcooper := 17; -- TRANSPOCRED --> TRANSULCRED
    END CASE;

    -- Buscar os dados da cooperativa
    OPEN  cr_crabcop(vr_cdcooper);
    FETCH cr_crabcop INTO rw_crabcop;
    CLOSE cr_crabcop;

  END IF;

  --  Verifica se a Cooperativa esta preparada para executar COMPE 85 - ABBC
  OPEN cr_craptab(pr_cdcooper => pr_cdcooper,
                  pr_tptabela => 'GENERI',
                  pr_cdacesso => 'EXECUTAABBC',
                  pr_tpregist => 0);
  FETCH cr_craptab INTO rw_craptab;
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    RAISE vr_exc_fimprg;
  ELSIF rw_craptab.dstextab <> 'SIM' THEN
    CLOSE cr_craptab;
    RAISE vr_exc_fimprg;
  END IF;
  CLOSE cr_craptab;

  --  Busca a tarifa para cada cheque
  OPEN cr_craptab(pr_cdcooper => pr_cdcooper,
                  pr_tptabela => 'USUARI',
                  pr_cdacesso => 'VLTARIF351',
                  pr_tpregist => 1);
  FETCH cr_craptab INTO rw_craptab;
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    vr_cdcritic := 55;
    RAISE vr_exc_fimprg;
  END IF;
  CLOSE cr_craptab;
  vr_vltarifa := rw_craptab.dstextab;

  -- Verifica qual a tela anterior para utilizacao da data de leitura do arquivo
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtleiarq := rw_crapdat.dtmvtoan;
    vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper) || '/rlnsv';
  ELSE
    vr_dtleiarq := rw_crapdat.dtmvtolt;
  END IF;

  --Tabela que contem as contas isentas de tarifa
  OPEN cr_craptab(pr_cdcooper => pr_cdcooper,
                  pr_tptabela => 'USUARI',
                  pr_cdacesso => 'ISTARIF351',
                  pr_tpregist => 1);
  FETCH cr_craptab INTO rw_craptab;
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    vr_cdcritic := 55;
    RAISE vr_exc_fimprg;
  END IF;
  CLOSE cr_craptab;
  vr_lscontas := ','||replace(rw_craptab.dstextab,' ','');

  -- Busca do diretório INTEGRA base da cooperativa
  vr_diretori    := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper) || '/integra';

  -- Busca do diretório RL base da cooperativa
  vr_diretori_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper) || '/rl';


  -- Retorna um array com todos os arquivos do diretório
  gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                            ,pr_pesq      => '%.D%'
                            ,pr_listarq   => vr_listarq
                            ,pr_des_erro  => vr_dscritic);

  -- Verifica se ocorreram erros no processo de lsitagem de arquivos
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => vr_nome_arq_log,
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
  END IF;

  -- Verifica se retorno arquivos na listagem
  IF TRIM(vr_listarq) IS NOT NULL THEN

    vr_array_arquivo := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');

    -- Percorre todos os arquivos retornados
    FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP

      -- Verifica através da extensão do arquivo a qual grupo o mesmo pertence
      IF    vr_array_arquivo(ind) LIKE ('1'||lpad(rw_crapcop.cdagectl,4,'0')||'%.D%N') THEN
        -- Grupo de arquivos DDN e DNN
        vr_arquivos(vr_arquivos.COUNT()+1).idarquivo := 1;
        vr_arquivos(vr_arquivos.COUNT()  ).nmarquivo := vr_array_arquivo(ind);

      ELSIF vr_array_arquivo(ind) LIKE ('1'||lpad(rw_crapcop.cdagectl,4,'0')||'%.DNC') THEN
        -- Grupo de arquivos .DNC
        vr_arquivos(vr_arquivos.COUNT()+1).idarquivo := 2;
        vr_arquivos(vr_arquivos.COUNT()  ).nmarquivo := vr_array_arquivo(ind);

      END IF;

      -- VIACON - Tratamento para incluir arquivos das cooperativas incorporadas
      IF  pr_cdcooper IN (1,9,13) THEN

        -- Verifica através da extensão do arquivo a qual grupo o mesmo pertence
        IF    vr_array_arquivo(ind) LIKE ('1'||lpad(rw_crabcop.cdagectl,4,'0')||'%.D%N') THEN
          -- Grupo de arquivos DDN e DNN
          vr_arquivos(vr_arquivos.COUNT()+1).idarquivo := 3;
          vr_arquivos(vr_arquivos.COUNT()  ).nmarquivo := vr_array_arquivo(ind);

        ELSIF vr_array_arquivo(ind) LIKE ('1'||lpad(rw_crabcop.cdagectl,4,'0')||'%.DNC') THEN
          -- Grupo de arquivos .DNC
          vr_arquivos(vr_arquivos.COUNT()+1).idarquivo := 4;
          vr_arquivos(vr_arquivos.COUNT()  ).nmarquivo := vr_array_arquivo(ind);

        END IF;

      END IF;

    END LOOP; -- Arquivos do diretório

  END IF; -- Se retornou arquivos do diretório

  -- Se não tiver arquivo para processar encerra o programa com erro 182
  IF vr_arquivos.COUNT() = 0 THEN
    vr_cdcritic := 182;
    RAISE vr_exc_fimprg;
  END IF;

  -- Comeca o processo dos arquivos
  -- Percorre todos os arquivos retornados
  FOR ind IN vr_arquivos.FIRST..vr_arquivos.LAST LOOP
    -- Gera o log com o nome do arquivo que sera processado
    vr_cdcritic := 219;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - Arquivo: '||vr_diretori ||'/'|| vr_arquivos(ind).nmarquivo;
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_nmarqlog     => vr_nome_arq_log
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic);


    -- Atualiza variaveis iniciais do controle
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    ww_nrlinha  := 0;
    vr_flgrejei := FALSE;

    -- Verificar se o arquivo esta completo - inicio
    gene0001.pc_OScommand_Shell(pr_des_comando => 'tail -1 ' || vr_diretori ||'/'||
                                                                vr_arquivos(ind).nmarquivo || ' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    -- Verificar se a ultima linha contem o caracter de quebra de arquivo (asc 26)
    -- controle necessario pois o comando tail -1 executado via oracle traz essa linha,
    -- diferentemente de quando executado diretamente no unix que o ignora
    IF  TRIM(vr_des_saida) IS NULL OR
        ASCII(vr_des_saida) = 26   THEN
        -- caso idendificar o comando de final de arquivo(asc=26), buscar a penultima linha
        gene0001.pc_OScommand_Shell(pr_des_comando => 'tail -2 ' || vr_diretori ||'/'||
                                                                    vr_arquivos(ind).nmarquivo || ' 2> /dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);
    END IF;

    -- Se o comeco da linha nao for 9, criticar
    IF SUBSTR(vr_des_saida,1,10) <> '9999999999' AND
       SUBSTR(vr_des_saida,162,10) <> '9999999999' THEN
      -- Gerar critica de identificacao invalida
      vr_cdcritic := 258;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_nmarqlog     => vr_nome_arq_log
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic);
      vr_cdcritic := 0;
      vr_dscritic := null;
    END IF;

    -- Abrir o arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretori
                            ,pr_nmarquiv => vr_arquivos(ind).nmarquivo
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Ler todas as linhas do arquivo
    LOOP
      -- Atualiza variaveis iniciais do controle
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      BEGIN
        -- Busca as informacoes da linha do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstexto); --> Texto lido
      EXCEPTION
        WHEN no_data_found THEN -- não encontrar mais linhas
          EXIT;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro arquivo ['||vr_arquivos(ind).nmarquivo||']: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualiza a variavel contadora de linhas
      ww_nrlinha := ww_nrlinha + 1;

      -- Verifica se é final de arquivo
      IF SUBSTR(vr_dstexto,1,10)  = '9999999999' AND
         SUBSTR(vr_dstexto,48,06) = 'CEL615'    THEN 
		IF substr(vr_dstexto,151,10) <> ww_nrlinha THEN
            vr_cdcritic := 166;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1
                                      ,pr_nmarqlog     => vr_nome_arq_log
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_dscritic);

            vr_nrdconta := SUBSTR(vr_dstexto,67,12);           

            vr_flgrejei := TRUE;
            -- Atualiza a tabela de memoria de dados do arquivo
            vr_nrcontad := vr_nrcontad + 1;
            vr_ind_crawrel := '0'||                                      --flgmigra
                              '00000'||                                  --agencia
                                 lpad(vr_nrdconta,10,'0')||              --conta
                                 lpad(SUBSTR(vr_dstexto,25,06),10,'0')|| --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).cdagenci := 0;
            vr_tab_crawrel(vr_ind_crawrel).nrdconta   := vr_nrdconta;
            vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
            vr_tab_crawrel(vr_ind_crawrel).nralinea   := substr(vr_dstexto,54,02);
            vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
            vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := substr(vr_dstexto,04,03);
            vr_tab_crawrel(vr_ind_crawrel).cdagechq   := substr(vr_dstexto,07,04);
            vr_tab_crawrel(vr_ind_crawrel).nrctachq   := substr(vr_dstexto,12,12);
            vr_tab_crawrel(vr_ind_crawrel).nrcheque   := substr(vr_dstexto,25,06);
            vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;

            -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
            vr_ind_crawrel_2 :=  vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
            vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

         END IF;
         EXIT;
      END IF; -- Final da verificacao de final de arquivo

      -- Faz validacoes especificas para a primeira linha
      IF ww_nrlinha = 1 THEN
        IF  SUBSTR(vr_dstexto,48,06) <> 'CEL615' THEN 
          vr_cdcritic := 473; --Codigo de remessa invalido.
        ELSIF SUBSTR(vr_dstexto,151,10) <> ww_nrlinha THEN
          vr_cdcritic := 166; -- Sequencia errada
        ELSIF SUBSTR(vr_dstexto,66,08) <> to_char(vr_dtleiarq,'YYYYMMDD') THEN
          vr_cdcritic := 013; -- Data errada
        END IF;

        -- Se encontrou erros entao gera mensagem no log
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_nmarqlog     => vr_nome_arq_log
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic);
          EXIT;
        END IF;
      ELSE -- Se nao for primeira linha
        vr_cdbanchq := SUBSTR(vr_dstexto,04,03);
        vr_cdagechq := SUBSTR(vr_dstexto,07,04);
        vr_nrctachq := SUBSTR(vr_dstexto,12,12);
        vr_nrcheque := SUBSTR(vr_dstexto,25,06);
        vr_cdalinea := SUBSTR(vr_dstexto,54,02);
				vr_cdageapr := to_number(SUBSTR(vr_dstexto,59,04));
				vr_nrctachd := to_number(SUBSTR(vr_dstexto,67,12));
				vr_dtdapres := to_date(SUBSTR(vr_dstexto,82,8), 'RRRR/MM/DD');

        -- Verificar se a agencia acolhedora possui informacao ZERO
        IF vr_cdageapr = 0 THEN
          -- Se for zero utilizar a agencia de destino
          vr_cdageapr := to_number(SUBSTR(vr_dstexto,63,04));
        END IF;

        -- Se for um arquivo do tipo DNN = Noturna = 1
        IF SUBSTR(vr_arquivos(ind).nmarquivo,-2,1) = 'N' THEN
          vr_cdperdev := 1;
        ELSE -- DDN / DNC = Diurna  = 2
          vr_cdperdev := 2;
        END IF;

        OPEN cr_crapcop_ctl(pr_cdagectl => vr_cdageapr);
				FETCH cr_crapcop_ctl INTO vr_cdcopaco;

        IF cr_crapcop_ctl%FOUND THEN
          /* Tratamento para incorporação viacon scrmil */
          IF (pr_cdcooper = 1  AND vr_cdcopaco = 4 ) OR
             (pr_cdcooper = 13 AND vr_cdcopaco = 15) OR
             (pr_cdcooper = 9  AND vr_cdcopaco = 17) THEN
             OPEN cr_craptco_inc(pr_cdcooper => pr_cdcooper,
                                 pr_cdcopant => vr_cdcopaco,
                                 pr_nrctaant => vr_nrctachd,
                                 pr_flgativo => 1);
             FETCH cr_craptco_inc INTO rw_craptco_inc;

             IF cr_craptco_inc%FOUND THEN
                /* Variaveis recebem valores da nova conta */
                vr_nrctachd := rw_craptco_inc.nrdconta;
                vr_cdcopaco := pr_cdcooper;
             END IF;
             CLOSE cr_craptco_inc;

          END IF;
					-- Abre o cursor contendo os dados dos cheques
					OPEN cr_crapchd(pr_cdcooper => vr_cdcopaco,
													pr_cdbanchq => vr_cdbanchq,
													pr_cdagechq => vr_cdagechq,
													pr_nrctachq => vr_nrctachq,
													pr_nrcheque => vr_nrcheque);
					FETCH cr_crapchd INTO rw_crapchd;
					IF cr_crapchd%NOTFOUND THEN
						vr_cdcritic := 244; -- Cheque inexistente
						rw_crapchd := NULL;
					END IF;
					CLOSE cr_crapchd;
				ELSE
					vr_dscritic := 'Agencia apresentante inválida';
        END IF;

				CLOSE cr_crapcop_ctl;

        IF vr_cdcritic = 0   AND
					 TRIM(vr_dscritic) IS NULL THEN
          -- Abre o cursor de cooperados
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => vr_nrctachd);
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%NOTFOUND THEN
            vr_cdcritic := 009; -- Associado nao cadastrado
          END IF;
          CLOSE cr_crapass;
        END IF;

        -- Se nao tiver inconsistencias
        IF vr_cdcritic = 0   AND
					 TRIM(vr_dscritic) IS NULL THEN
          -- Abre o cursor de numeros de telefone do cooperado
          OPEN cr_craptfc(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => vr_nrctachd,
                          pr_idseqttl => 1);
          FETCH cr_craptfc INTO rw_craptfc;
          IF cr_craptfc%NOTFOUND THEN
            vr_nrtelefo := '';
          ELSE
            vr_nrtelefo := '('|| rw_craptfc.nrdddtfc || ') '||rw_craptfc.nrtelefo;
          END IF;
          CLOSE cr_craptfc;
        END IF;

        -- Se encontrar inconsistencias
        IF vr_cdcritic <> 0 THEN
          -- Abre o cursor de contas transferidas entre cooperativas
          OPEN cr_craptco(pr_cdcooper => pr_cdcooper,
                          pr_nrctaant => vr_nrctachd,
                          pr_tpctatrf => 1,
                          pr_flgativo => 1);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            vr_cdcritic := 951; -- Conta Migrada
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- Cria registros na tabela de cheques devolvidos
            pc_cria_generica(pr_cdcritic => vr_cdcritic,
                             pr_cdalinea => vr_cdalinea,
                             pr_nmarquiv => vr_arquivos(ind).nmarquivo);

            -- Atualiza a tabela de memoria de dados do arquivo
            vr_nrcontad := vr_nrcontad + 1;
            vr_ind_crawrel := '1'||                                      --flgmigra
                              '00000'||                                  --agencia
                                 lpad(SUBSTR(vr_dstexto,67,12),10,'0')|| --conta
                                 lpad(vr_nrcheque,10,'0')||              --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).cdagenci   := 0;
            vr_tab_crawrel(vr_ind_crawrel).nrdconta   := SUBSTR(vr_dstexto,67,12);
            vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 1;
            vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
            vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
            vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := vr_cdbanchq;
            vr_tab_crawrel(vr_ind_crawrel).cdagechq   := vr_cdagechq;
            vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
            vr_tab_crawrel(vr_ind_crawrel).nrcheque   := vr_nrcheque;
            vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;
			vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);

            -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
            vr_ind_crawrel_2 := vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
            vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

            -- Volta a situaçao para ficar sem criticas
            vr_cdcritic := 0;
            vr_flgrejei := TRUE;  -- Coloca o registro como rejeitado

          ELSE
            rw_craptco  := NULL;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- Cria registros na tabela de cheques devolvidos
            pc_cria_generica(pr_cdcritic => vr_cdcritic,
                             pr_cdalinea => vr_cdalinea,
                             pr_nmarquiv => vr_arquivos(ind).nmarquivo);

            vr_nrdconta := SUBSTR(vr_dstexto,67,12);

            IF (pr_cdcooper IN (1,9,13)) AND
                vr_arquivos(ind).idarquivo > 2 THEN
                
              OPEN cr_craptco_inc(pr_cdcooper => pr_cdcooper,
                                  pr_cdcopant => vr_cdcopaco,
                                  pr_nrctaant => vr_nrctachd,
                                  pr_flgativo => 1);
              FETCH cr_craptco_inc INTO rw_craptco_inc;

              IF cr_craptco_inc%FOUND THEN
                /* Variaveis recebem valores da nova conta */
                vr_nrdconta := rw_craptco_inc.nrdconta;
              END IF;
              CLOSE cr_craptco_inc;  
                
            END IF;

            -- Atualiza a tabela de memoria de dados do arquivo
            vr_nrcontad := vr_nrcontad + 1;
            vr_ind_crawrel := '0'||                                      --flgmigra
                              '00000'||                                  --agencia
                                 lpad(vr_nrdconta,10,'0')||              --conta
                                 lpad(vr_nrcheque,10,'0')||              --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).cdagenci := 0;
            vr_tab_crawrel(vr_ind_crawrel).nrdconta   := vr_nrdconta;
            vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
            vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
            vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
            vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := vr_cdbanchq;
            vr_tab_crawrel(vr_ind_crawrel).cdagechq   := vr_cdagechq;
            vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
            vr_tab_crawrel(vr_ind_crawrel).nrcheque   := vr_nrcheque;
            vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;
			vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);

            -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
            vr_ind_crawrel_2 := vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
            vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

            -- Volta a situaçao para ficar sem criticas
            vr_cdcritic := 0;
            vr_flgrejei := TRUE; -- Coloca o registro como rejeitado

          END IF; -- verificacao de craptco%found
          CLOSE cr_craptco;
          CONTINUE;

        END IF;

        -- Se for Viacredi ou Creditextil
        IF pr_cdcooper in (1,2)THEN

          -- Abre o cursor de contas transferidas entre cooperativas
          OPEN cr_craptco(pr_cdcooper => pr_cdcooper,
                          pr_nrctaant => vr_nrctachd,
                          pr_tpctatrf => 1,
                          pr_flgativo => 1);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            vr_cdcritic := 951; -- Conta Migrada
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- Cria registros na tabela de cheques devolvidos
            pc_cria_generica(pr_cdcritic => vr_cdcritic,
                             pr_cdalinea => vr_cdalinea,
                             pr_nmarquiv => vr_arquivos(ind).nmarquivo);

            -- Atualiza a tabela de memoria de dados do arquivo
            vr_nrcontad := vr_nrcontad + 1;
            vr_ind_crawrel := '1'||                                      --flgmigra
                              '00000'||                                  --agencia
                                 lpad(SUBSTR(vr_dstexto,67,12),10,'0')|| --conta
                                 lpad(vr_nrcheque,10,'0')||              --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).cdagenci := 0;
            vr_tab_crawrel(vr_ind_crawrel).nrdconta   := SUBSTR(vr_dstexto,67,12);
            vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 1;
            vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
            vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
            vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := vr_cdbanchq;
            vr_tab_crawrel(vr_ind_crawrel).cdagechq   := vr_cdagechq;
            vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
            vr_tab_crawrel(vr_ind_crawrel).nrcheque   := vr_nrcheque;
            vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;
			vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);

            -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
            vr_ind_crawrel_2 := vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
            vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

            -- Volta a situaçao para ficar sem criticas
            vr_cdcritic := 0;
            vr_flgrejei := TRUE; -- Coloca o registro como rejeitado
            CLOSE cr_craptco;
            CONTINUE;
          ELSE
            rw_craptco  := NULL;
            CLOSE cr_craptco;
          END IF;
        END IF; -- verificacao se for Viacredi

        IF rw_crapchd.cdbccxlt = 600 THEN -- Cheque custodia
          vr_dpb_cdagenci := 1;
          vr_dpb_cdbccxlt := 100;
          vr_dpb_nrdolote := 4500;
					vr_cdcoptfn := 0;
        ELSIF vr_cdcopaco <> pr_cdcooper THEN -- se foi deposito intercooperativo
          vr_dpb_cdagenci := 1;
          vr_dpb_cdbccxlt := 100;
          vr_dpb_nrdolote := 10118;
					vr_cdcoptfn := vr_cdcopaco;
        ELSE
          vr_dpb_cdagenci := rw_crapchd.cdagenci;
          vr_dpb_cdbccxlt := rw_crapchd.cdbccxlt;
          vr_dpb_nrdolote := rw_crapchd.nrdolote;
					vr_cdcoptfn := 0;
        END IF;

        -- Abre o cursor de depositos bloqueados
        OPEN cr_crapdpb(pr_cdcooper,
                        rw_crapchd.dtmvtolt,
                        vr_dpb_cdagenci,
                        vr_dpb_cdbccxlt,
                        vr_dpb_nrdolote,
                        vr_nrctachd,
                        rw_crapchd.nrdocmto);
        FETCH cr_crapdpb INTO rw_crapdpb;
        IF cr_crapdpb%NOTFOUND THEN
          vr_cdhistor := 351;
        ELSE
          IF rw_crapdpb.inlibera = 1 THEN -- Se a situacao de liberacao for normal
            IF rw_crapdpb.dtliblan <= rw_crapdat.dtmvtolt THEN
              vr_cdhistor := 351; --CH.DEV.CUST.
            ELSE
              IF rw_crapdpb.cdhistor = 3 OR rw_crapdpb.cdhistor = 1526 OR  --DEP.CHQ.PR. / 1526 - DEP. INTERCOOP.
                 rw_crapdpb.cdhistor = 2433 THEN -- DEPOSITO BLOQ - COMPE SESSAO UNICA
                 vr_cdhistor := 24;
              ELSIF rw_crapdpb.cdhistor = 4 OR rw_crapdpb.cdhistor = 1523 OR --DEP.CHQ.FPR. / 1523 - DEP.INTERCOOP.
                    rw_crapdpb.cdhistor = 2658 THEN -- DEPOSITO BLOQ - COMPE SESSAO UNICA
                    vr_cdhistor := 27;
              ELSIF rw_crapdpb.cdhistor IN (357,881) THEN --DEP.BLOQ.CUST
                vr_cdhistor := 657; --CH.DEV.CUST.
              ELSE
                vr_cdhistor := 351; --CH.DEV.CUST.
              END IF;
            END IF;
          ELSE
            vr_cdhistor := 351; --CH.DEV.CUST.
          END IF;
        END IF;
        CLOSE cr_crapdpb;

        IF rw_crapchd.cdbccxlt = 700 THEN  /*  desconto de cheques  */
          vr_cdhistor := 399; --DEV.CH.DESCTO
        END IF;

        IF rw_crapchd.cdbccxlt = 500  OR    /*  Rotina 14 */
           (rw_crapchd.cdbccxlt = 11     AND
            rw_crapchd.nrdolote > 30000  AND
            rw_crapchd.nrdolote < 30999) THEN  /*  Lanchq  */
          vr_cdhistor := 351; --CH.DEV.CUST.
        END IF;

        -- Abre o cursor de capas de lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                     pr_cdagenci => 1,
                     pr_cdbccxlt => 100,
                     pr_nrdolote => 4650);
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN -- Se nao existir insere a capa de lote
          BEGIN
            INSERT INTO craplot
              (dtmvtolt,
               dtmvtopg,
               cdagenci,
               cdbccxlt,
               cdoperad,
               nrdolote,
               tplotmov,
               tpdmoeda,
               cdcooper)
            VALUES
              (rw_crapdat.dtmvtolt,
               rw_crapdat.dtmvtopr,
               1,
               100,
               1,
               4650,
               1,
               1,
               pr_cdcooper)
             RETURNING ROWID INTO vr_rowid_craplot;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPLOT: ' ||SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSE
          vr_rowid_craplot := rw_craplot.rowid;
        END IF;
        CLOSE cr_craplot;

        -- Atualiza a tabela de capas de lote
        BEGIN
          UPDATE craplot
             SET nrseqdig = nrseqdig + 1,
                 qtcompln = qtcompln + 1,
                 qtinfoln = qtinfoln + 1,
                 vlcompdb = vlcompdb + (SUBSTR(vr_dstexto,34,17) / 100),
                 vlcompcr = 0,
                 vlinfodb = vlcompdb + (SUBSTR(vr_dstexto,34,17) / 100),
                 vlinfocr = 0
           WHERE ROWID = vr_rowid_craplot;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
        END;

        -- rotina para buscar de um numero de cheque disponivel
        vr_nrcheque_tmp := rw_crapchd.nrcheque;
        LOOP
          OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_cdagenci => 1,
                          pr_cdbccxlt => 100,
                          pr_nrdolote => 4650,
                          pr_nrdctabb => vr_nrctachd,
                          pr_nrdocmto => vr_nrcheque_tmp);
          FETCH cr_craplcm INTO rw_craplcm;
          IF cr_craplcm%FOUND THEN
             vr_nrcheque_tmp := vr_nrcheque_tmp + 1000000;
             CLOSE cr_craplcm;
          ELSE
             CLOSE cr_craplcm;
             EXIT;
          END IF;
        END LOOP;

        -- insere o cheque na tabela de lancamentos
        BEGIN
          vr_dscritic := '';
          vr_cdcritic := 0;
          
          LANC0001.pc_gerar_lancamento_conta(
          pr_dtmvtolt => rw_crapdat.dtmvtolt                   , 
          pr_cdagenci => 1,
          pr_cdbccxlt => 100, 
          pr_nrdolote => 4650,
          pr_nrdconta => vr_nrctachd, 
          pr_nrdocmto => vr_nrcheque_tmp,
          pr_cdhistor => vr_cdhistor, 
          pr_nrseqdig => nvl(rw_craplot.nrseqdig,0) + 1,
          pr_vllanmto => SUBSTR(vr_dstexto,34,17) / 100, 
          pr_nrdctabb => vr_nrctachd,
          pr_nrdctitg => gene0002.fn_mask(vr_nrctachd,'99999999'),
          pr_cdpesqbb => vr_cdalinea,
          pr_vldoipmf => 0,
          pr_nrautdoc => 0, 
          pr_nrsequni => 0,
          pr_cdbanchq => rw_crapchd.cdbanchq, 
          pr_cdcmpchq => rw_crapchd.cdcmpchq,
          pr_cdagechq => rw_crapchd.cdagechq, 
          pr_nrctachq => rw_crapchd.nrctachq,
          pr_nrlotchq => 0, 
          pr_sqlotchq => 0,
          pr_cdcooper => pr_cdcooper, 
          pr_dsidenti => 'CTL',
          pr_cdcoptfn => vr_cdcoptfn,
          pr_tab_retorno => vr_tab_retorno,
          pr_incrineg => vr_incrineg,
                  pr_cdcritic => vr_cdcritic,
                  pr_dscritic => vr_dscritic) ;

          IF (nvl(vr_cdcritic,0) <> 0 or vr_dscritic IS NOT NULL) THEN
            IF vr_incrineg = 0 THEN -- Nao tem critica de negocio / Erro de processamento
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              -- Cria registros na tabela de cheques devolvidos
              pc_cria_generica(pr_cdcritic => vr_cdcritic,
                               pr_cdalinea => vr_cdalinea,
                               pr_nmarquiv => vr_arquivos(ind).nmarquivo);

              -- Atualiza a tabela de memoria de dados do arquivo
              vr_nrcontad := vr_nrcontad + 1;
              vr_ind_crawrel := '1'||                                      --flgmigra
                                '00000'||                                  --agencia
                                   lpad(SUBSTR(vr_dstexto,67,12),10,'0')|| --conta
                                   lpad(vr_nrcheque_tmp,10,'0')||              --cheque
                                   lpad(vr_nrcontad,5,'0');                --sequencial
              vr_tab_crawrel(vr_ind_crawrel).cdagenci   := 0;
              vr_tab_crawrel(vr_ind_crawrel).nrdconta   := SUBSTR(vr_dstexto,67,12);
              vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
              vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 1;
              vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
              vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
              vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := vr_cdbanchq;
              vr_tab_crawrel(vr_ind_crawrel).cdagechq   := vr_cdagechq;
              vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
              vr_tab_crawrel(vr_ind_crawrel).nrcheque   := vr_nrcheque;
              vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;
              vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);

              -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
              vr_ind_crawrel_2 := vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
              vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

              -- Volta a situaçao para ficar sem criticas
              vr_cdcritic := 0;
              vr_flgrejei := TRUE;  -- Coloca o registro como rejeitado

              -- Desfaz atualização do LOTE
              BEGIN
                UPDATE craplot
                   SET nrseqdig = nrseqdig - 1,
                       qtcompln = qtcompln - 1,
                       qtinfoln = qtinfoln - 1,
                       vlcompdb = vlcompdb - (SUBSTR(vr_dstexto,34,17) / 100),
                       vlcompcr = 0,
                       vlinfodb = vlcompdb - (SUBSTR(vr_dstexto,34,17) / 100),
                       vlinfocr = 0
                 WHERE ROWID = vr_rowid_craplot;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
              END;

              CONTINUE;
            ELSE  -- Critica de negocio.
              vr_dscritic := '';
              vr_cdcritic := 0;
              -- Gravar na Transitoria
              PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                                          , pr_nrdconta => vr_nrctachd
                                          , pr_vlrlanc  => SUBSTR(vr_dstexto,34,17) / 100
                                          , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          , pr_cdcritic => pr_cdcritic
                                          , pr_dscritic => pr_dscritic);
                                            
              IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                -- Cria registros na tabela de cheques devolvidos
                pc_cria_generica(pr_cdcritic => vr_cdcritic,
                                 pr_cdalinea => vr_cdalinea,
                                 pr_nmarquiv => vr_arquivos(ind).nmarquivo);

                -- Atualiza a tabela de memoria de dados do arquivo
                vr_nrcontad := vr_nrcontad + 1;
                vr_ind_crawrel := '1'||                                      --flgmigra
                                  '00000'||                                  --agencia
                                     lpad(SUBSTR(vr_dstexto,67,12),10,'0')|| --conta
                                     lpad(vr_nrcheque_tmp,10,'0')||              --cheque
                                     lpad(vr_nrcontad,5,'0');                --sequencial
                vr_tab_crawrel(vr_ind_crawrel).cdagenci   := 0;
                vr_tab_crawrel(vr_ind_crawrel).nrdconta   := SUBSTR(vr_dstexto,67,12);
                vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := vr_dscritic;
                vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 1;
                vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
                vr_tab_crawrel(vr_ind_crawrel).cdcmpchq   := substr(vr_dstexto,01,03);
                vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := vr_cdbanchq;
                vr_tab_crawrel(vr_ind_crawrel).cdagechq   := vr_cdagechq;
                vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
                vr_tab_crawrel(vr_ind_crawrel).nrcheque   := vr_nrcheque;
                vr_tab_crawrel(vr_ind_crawrel).vlcheque   := substr(vr_dstexto,34,17) / 100;
                vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);

                -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
                vr_ind_crawrel_2 := vr_ind_crawrel; --substr(vr_ind_crawrel,1,16)||substr(vr_ind_crawrel,27,5);
                vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

                -- Volta a situaçao para ficar sem criticas
                vr_cdcritic := 0;
                vr_flgrejei := TRUE;  -- Coloca o registro como rejeitado

                -- Desfaz atualização do LOTE
                BEGIN
                  UPDATE craplot
                     SET nrseqdig = nrseqdig - 1,
                         qtcompln = qtcompln - 1,
                         qtinfoln = qtinfoln - 1,
                         vlcompdb = vlcompdb - (SUBSTR(vr_dstexto,34,17) / 100),
                         vlcompcr = 0,
                         vlinfodb = vlcompdb - (SUBSTR(vr_dstexto,34,17) / 100),
                         vlinfocr = 0
                   WHERE ROWID = vr_rowid_craplot;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
                END;
                
                CONTINUE;
              END IF; 
            END IF;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

				-- Se é depósito intercoop.
				IF vr_cdcopaco <> pr_cdcooper THEN

					BEGIN
						INSERT INTO crapddi
									 (cdcooper,
										cdcopaco,
										nrdconta,
										cdbanchq,
										cdagechq,
										nrctachq,
										nrcheque,
										vlcheque,
										cdalinea,
										dtmvtolt,
										dtdeposi)
						 VALUES(pr_cdcooper,
										vr_cdcopaco,
										vr_nrctachd,
										rw_crapchd.cdbanchq,
										rw_crapchd.cdagechq,
										rw_crapchd.nrctachq,
										vr_nrcheque_tmp,
										(substr(vr_dstexto,34,17) / 100),
										vr_cdalinea,
										rw_crapdat.dtmvtolt,
										vr_dtdapres);
					EXCEPTION
						WHEN OTHERS THEN
							vr_cdcritic := 0;
							vr_dscritic := 'Erro ao inserir CRAPDDI: ' || SQLERRM;
							RAISE vr_exc_saida;
					END;
				END IF;

        pc_cria_generica(pr_cdcritic => 0,
                         pr_cdalinea => vr_cdalinea,
                         pr_nmarquiv => vr_arquivos(ind).nmarquivo);

        -- Tratamento de cheques bloqueados
        IF vr_cdhistor = 24  OR
           vr_cdhistor = 27  OR
           vr_cdhistor = 657 THEN  -- Se entrou neste if quer dizer que existe na CRAPDPB, pois os historicos são somente
                                   -- para os casos onde encontrou registro na CRAPDPB
          IF round(SUBSTR(vr_dstexto,34,17) / 100,2) = rw_crapdpb.vllanmto THEN
             rw_crapdpb.inlibera := 2;   -- Dep. Estornado
          ELSE
             --  Deposito com varios cheques
             rw_crapdpb.vllanmto := rw_crapdpb.vllanmto -
                                    round(SUBSTR(vr_dstexto,34,17) / 100,2);
          END IF;

          -- Atualiza tabela de depositos bloqueados
          BEGIN
            UPDATE crapdpb
               SET inlibera = rw_crapdpb.inlibera,
                   vllanmto = rw_crapdpb.vllanmto
             WHERE ROWID = rw_crapdpb.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar CRAPDPB: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;  -- Final da validacao de cheques bloqueados

        -- Atualiza indice da tabela temporaria
        vr_nrcontad := vr_nrcontad + 1;
        vr_ind_crawrel := '0'||                                      --flgmigra
                             '00000'||                               --agencia
                             lpad(SUBSTR(vr_dstexto,67,12),10,'0')|| --conta
                             lpad(rw_crapchd.nrcheque,10,'0')||      --cheque
                             lpad(vr_nrcontad,5,'0');                --sequencial

        -- Faz processo para cheques de custodia
        IF rw_crapchd.cdbccxlt = 600 THEN
          OPEN cr_crapcst(pr_cdcooper => pr_cdcooper,
                          pr_dsdocmc7 => rw_crapchd.dsdocmc7);
          FETCH cr_crapcst INTO rw_crapcst;
          IF cr_crapcst%FOUND THEN

            -- VIACON
            -- Se for conta migrada das cooperativas 4 ou 15 nas condicoes
            -- abaixo devera atribui para crawrel.cdagenci o codigo do novo
            -- PA na coopertaiva nova
            IF  (pr_cdcooper IN (1,9,13))
            AND vr_arquivos(ind).idarquivo > 3 THEN
              
              OPEN cr_craptco_inc(pr_cdcooper => pr_cdcooper,
                                  pr_cdcopant => vr_cdcopaco,
                                  pr_nrctaant => vr_nrctachd,
                                  pr_flgativo => 1);
              FETCH cr_craptco_inc INTO rw_craptco_inc;

              IF cr_craptco_inc%FOUND THEN
                /* Variaveis recebem valores da nova conta */
                vr_nrdconta := rw_craptco_inc.nrdconta;
              END IF;
              CLOSE cr_craptco_inc;  
              
            END IF;

            -- Atualiza a tabela de memoria de dados do arquivo
            vr_ind_crawrel := '0'||                                      --flgmigra
                              lpad(rw_crapcst.cdagenci,5,'0')||          --agencia
                                 lpad(vr_nrctachd,10,'0')||      --conta
                                 lpad(rw_crapchd.nrcheque,10,'0')||      --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).dsprodut   := 'CUSTODIA';
            vr_tab_crawrel(vr_ind_crawrel).lotborde   := rw_crapcst.nrdolote;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
            IF rw_crapcst.dtprevia IS NOT NULL THEN
              vr_tab_crawrel(vr_ind_crawrel).nrprevia := rw_crapcst.nrdolote;
            ELSE
              vr_tab_crawrel(vr_ind_crawrel).nrprevia := 0;
            END IF;
            vr_tab_crawrel(vr_ind_crawrel).dtmvtolt   := rw_crapcst.dtmvtolt;
            vr_tab_crawrel(vr_ind_crawrel).dtlibera   := rw_crapcst.dtlibera;
            vr_tab_crawrel(vr_ind_crawrel).cdagenci   := rw_crapcst.cdagenci;
            vr_tab_crawrel(vr_ind_crawrel).insitprv   := rw_crapcst.insitprv;
          END IF;
          CLOSE cr_crapcst;
        ELSIF rw_crapchd.cdbccxlt = 700 THEN
          OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper,
                          pr_dsdocmc7 => rw_crapchd.dsdocmc7);
          FETCH cr_crapcdb INTO rw_crapcdb;
          IF cr_crapcdb%FOUND THEN
            -- Atualiza a tabela de memoria de dados do arquivo
            vr_ind_crawrel := '0'||                                      --flgmigra
                              lpad(rw_crapcdb.cdagenci,5,'0')||          --agencia
                                 lpad(vr_nrctachd,10,'0')||              --conta
                                 lpad(rw_crapchd.nrcheque,10,'0')||      --cheque
                                 lpad(vr_nrcontad,5,'0');                --sequencial
            vr_tab_crawrel(vr_ind_crawrel).dsprodut   := 'DESCONTO';
            vr_tab_crawrel(vr_ind_crawrel).lotborde   := rw_crapcdb.nrborder;
            vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
            IF rw_crapcdb.dtprevia IS NOT NULL THEN
              vr_tab_crawrel(vr_ind_crawrel).nrprevia := rw_crapcdb.nrborder;
            ELSE
              vr_tab_crawrel(vr_ind_crawrel).nrprevia := 0;
            END IF;
            vr_tab_crawrel(vr_ind_crawrel).dtmvtolt   := rw_crapcdb.dtlibbdc;
            vr_tab_crawrel(vr_ind_crawrel).dtlibera   := rw_crapcdb.dtlibera;
            vr_tab_crawrel(vr_ind_crawrel).cdagenci   := rw_crapcdb.cdagenci;
            vr_tab_crawrel(vr_ind_crawrel).insitprv   := rw_crapcdb.insitprv;
            vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
          END IF;
          CLOSE cr_crapcdb;
        ELSIF rw_crapchd.cdbccxlt = 11
          AND rw_crapchd.nrdolote > 30000
          AND rw_crapchd.nrdolote < 30999
          AND rw_crapchd.nrcnvbol = 0
          AND rw_crapchd.nrctabol = 0
          AND rw_crapchd.nrboleto = 0     THEN
          -- Atualiza a tabela de memoria de dados do arquivo
          vr_ind_crawrel := '0'||                                      --flgmigra
                               lpad(rw_crapchd.cdagenci,5,'0')||       --agencia
                               lpad(vr_nrctachd,10,'0')||      --conta
                               lpad(rw_crapchd.nrcheque,10,'0')||      --cheque
                               lpad(vr_nrcontad,5,'0');                --sequencial
          vr_tab_crawrel(vr_ind_crawrel).dsprodut   := 'LANCHQ';
          vr_tab_crawrel(vr_ind_crawrel).lotborde   := SUBSTR(gene0002.fn_mask(rw_crapchd.nrdolote,'99999'),3,3);
          vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
          vr_tab_crawrel(vr_ind_crawrel).nrprevia   := rw_crapchd.nrprevia;
          vr_tab_crawrel(vr_ind_crawrel).dtmvtolt   := rw_crapchd.dtmvtolt;
          vr_tab_crawrel(vr_ind_crawrel).dtlibera   := rw_crapchd.dtmvtolt;
          vr_tab_crawrel(vr_ind_crawrel).cdagenci   := rw_crapchd.cdagenci;
          vr_tab_crawrel(vr_ind_crawrel).insitprv   := rw_crapchd.insitprv;
          vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
        ELSE
					IF vr_cdcopaco <> pr_cdcooper THEN
						vr_cdagenci_ass := rw_crapass.cdagenci;
					ELSE
						vr_cdagenci_ass := rw_crapchd.cdagenci;
					END IF;
          vr_ind_crawrel := '0'||                                    --flgmigra
                             lpad(vr_cdagenci_ass,5,'0')||           --agencia
                             lpad(vr_nrctachd,10,'0')||              --conta
                               lpad(rw_crapchd.nrcheque,10,'0')||      --cheque
                               lpad(vr_nrcontad,5,'0');                --sequencial
          vr_tab_crawrel(vr_ind_crawrel).dsprodut   := 'CAIXA';
          vr_tab_crawrel(vr_ind_crawrel).lotborde   := SUBSTR(gene0002.fn_mask(rw_crapchd.nrdolote,'99999'),3,3);
          vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
          vr_tab_crawrel(vr_ind_crawrel).nrprevia   := rw_crapchd.nrprevia;
          vr_tab_crawrel(vr_ind_crawrel).dtmvtolt   := rw_crapchd.dtmvtolt;
          vr_tab_crawrel(vr_ind_crawrel).dtlibera   := rw_crapchd.dtmvtolt;
          vr_tab_crawrel(vr_ind_crawrel).cdagenci   := vr_cdagenci_ass;
          vr_tab_crawrel(vr_ind_crawrel).insitprv   := rw_crapchd.insitprv;
          vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
        END IF;

        -- Atualiza a tabela de memoria de dados do arquivo
        IF NOT vr_tab_crawrel.exists(vr_ind_crawrel) THEN
          vr_tab_crawrel(vr_ind_crawrel).cdagenci := 0;
        END IF;
        vr_tab_crawrel(vr_ind_crawrel).nrdconta   := vr_nrctachd;
        vr_tab_crawrel(vr_ind_crawrel).nmprimtl   := rw_crapass.nmprimtl;
        vr_tab_crawrel(vr_ind_crawrel).flgmigra   := 0;
        vr_tab_crawrel(vr_ind_crawrel).nrfonres   := vr_nrtelefo;
        vr_tab_crawrel(vr_ind_crawrel).cdbanchq   := rw_crapchd.cdbanchq;
        vr_tab_crawrel(vr_ind_crawrel).nrcheque   := rw_crapchd.nrcheque;
        vr_tab_crawrel(vr_ind_crawrel).nralinea   := vr_cdalinea;
        vr_tab_crawrel(vr_ind_crawrel).vlcheque   := rw_crapchd.vlcheque;
		    vr_tab_crawrel(vr_ind_crawrel).cdageapr   := substr(vr_dstexto,59,04);
        vr_tab_crawrel(vr_ind_crawrel).nrctachq   := vr_nrctachq;
        -- move os dados para a variavel vr_tab_crawrel_2 com outra ordenacao
        vr_ind_crawrel_2 := substr(vr_ind_crawrel,1,6)|| -- flgmigra e Agencia
                            vr_tab_crawrel(vr_ind_crawrel).dsprodut ||-- Produto
                            substr(vr_ind_crawrel,7,10)||  -- Conta
                            substr(vr_ind_crawrel,17,10)|| -- Cheque
                            substr(vr_ind_crawrel,27,5);   -- Sequencial
        -- Busca a flag de reapresentacao
        OPEN cr_reapr(pr_cdcooper => pr_cdcooper,
                pr_nrdconta => vr_tab_crawrel(vr_ind_crawrel).nrdconta);
        FETCH cr_reapr INTO rw_reapr;
        CLOSE cr_reapr; 
        
        vr_tab_crawrel(vr_ind_crawrel).flgreapr   := rw_reapr.flgreapr;   

        vr_tab_crawrel_2(vr_ind_crawrel_2) := vr_tab_crawrel(vr_ind_crawrel);

        -- Se existir boletos atualiza tabela temporaria de boletos
        IF rw_crapchd.nrboleto <> 0 THEN
          vr_tab_crawbol(vr_tab_crawbol.COUNT()+1).cdagenci := rw_crapchd.cdagenci;
          vr_tab_crawbol(vr_tab_crawbol.COUNT()).nrboleto   := rw_crapchd.nrboleto;
          vr_tab_crawbol(vr_tab_crawbol.COUNT()).nrctabol   := rw_crapchd.nrctabol;
          vr_tab_crawbol(vr_tab_crawbol.COUNT()).nrcnvbol   := rw_crapchd.nrcnvbol;
          vr_tab_crawbol(vr_tab_crawbol.COUNT()).vlcheque   := rw_crapchd.vlcheque;
        END IF;

        -- Atualiza tabela de emitentes de cheques
        BEGIN
          UPDATE crapcec
             SET dtultdev = rw_crapdat.dtmvtolt,
                 qtchqdev = qtchqdev + 1
          WHERE crapcec.cdcooper = pr_cdcooper
            AND crapcec.cdcmpchq = rw_crapchd.cdcmpchq
            AND crapcec.cdbanchq = rw_crapchd.cdbanchq
            AND crapcec.cdagechq = rw_crapchd.cdagechq
            AND crapcec.nrctachq = rw_crapchd.nrctachq
            AND crapcec.nrdconta = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela CRAPCEC: ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF; -- Final de validação para do corpo do arquivo (quando NAO EH primeira linha)
    END LOOP; -- Loop das linhas do arquivo

    -- Se ocorreu erro no processamento do arquivo, deve mover como erro e desconsiderar o mesmo
    IF nvl(vr_cdcritic,0) IN (473, 116, 13) THEN
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_diretori ||'/'|| vr_arquivos(ind).nmarquivo || ' '||
                                                             vr_diretori ||'/err'||substr(vr_arquivos(ind).nmarquivo,4,99) ||' 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      continue;
    END IF;
    -- Move o arquivo para o diretorio salvar
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_diretori||'/'||vr_arquivos(ind).nmarquivo|| ' ' ||
                                                        gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                                                             ,pr_cdcooper => pr_cdcooper) || '/salvar');

    -- Gera no log se houve ou nao rejeitados no arquivo
    IF vr_flgrejei THEN
      vr_cdcritic := 191; -- Integrado com rejeitados
    ELSE
      vr_cdcritic := 190; -- Integrado com sucesso
    END IF;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - Arquivo: '||vr_diretori ||'/'|| vr_arquivos(ind).nmarquivo;
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_nmarqlog     => vr_nome_arq_log
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic);
  END LOOP; -- Loop dos arquivos do diretorio


  ---------------------------------
  -- Inicio Layout CRRL530
  ---------------------------------

  -- Inicializar o CLOB para armazenar os arquivos XML
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  -- Inicializa o arquivo XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',1);

  -- busca o indice do primeiro registro da pl/table vr_tab_crawrel
  vr_ind_crawrel := vr_tab_crawrel.first;

  -- Inicia o loop para o arquivo CRRL530
  LOOP
    EXIT WHEN vr_ind_crawrel IS NULL;

    -- Se a agencia for zerada deve ignorar, pois eh um registro rejeitado
    IF vr_tab_crawrel(vr_ind_crawrel).cdagenci = 0 THEN
      vr_ind_crawrel := vr_tab_crawrel.next(vr_ind_crawrel);
      continue;
    END IF;

    -- Verifica se a conta eh diferente da anterior
    IF vr_tab_crawrel.prior(vr_ind_crawrel) IS NULL OR -- Se for o primeiro registro da pl table
       vr_tab_crawrel(vr_tab_crawrel.prior(vr_ind_crawrel)).cdagenci <> vr_tab_crawrel(vr_ind_crawrel).cdagenci OR -- Se a agencia anterior for diferente da agencia atual
       vr_tab_crawrel(vr_tab_crawrel.prior(vr_ind_crawrel)).nrdconta <> vr_tab_crawrel(vr_ind_crawrel).nrdconta THEN -- Se a conta anterior for diferente da conta atual
      -- Insere o cabecalho da conta
      pc_escreve_xml('<conta nrtelsac="'||rw_crapcop.nrtelsac
                   ||'" nrtelouv="'||rw_crapcop.nrtelouv
                   ||'" hrinisac="'||to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'MI'),'00')
                   ||'" hrfimsac="'||to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'MI'),'00')
                   ||'" hriniouv="'||to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'MI'),'00')
                   ||'" hrfimouv="'||to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'MI'),'00')||'" >'||
                       '<cdagenci>'|| vr_tab_crawrel(vr_ind_crawrel).cdagenci                         ||'</cdagenci>'||
                       '<nrdconta>'|| gene0002.fn_mask_conta(vr_tab_crawrel(vr_ind_crawrel).nrdconta) ||'</nrdconta>'||
                       '<nmprimtl>'|| vr_tab_crawrel(vr_ind_crawrel).nmprimtl                         ||'</nmprimtl>'||
                       '<nrfonres>'|| vr_tab_crawrel(vr_ind_crawrel).nrfonres                         ||'</nrfonres>',1);
      -- Zera os totalizadores
      vr_qtdecheq := 0;
      vr_totdcheq := 0;
    END IF; -- Final da validacao da conta diferente da anterior

    -- Atualiza os totalizadores
    vr_qtdecheq := vr_qtdecheq + 1;
    vr_totdcheq := vr_totdcheq + vr_tab_crawrel(vr_ind_crawrel).vlcheque;

    -- busca a descricao do Aliena
    OPEN cr_crapali(pr_cdalinea => vr_tab_crawrel(vr_ind_crawrel).nralinea);
    FETCH cr_crapali INTO vr_dsalinea;
    IF cr_crapali%NOTFOUND THEN
      vr_dsalinea := 'NAO CADASTRADA';
    END IF;
    CLOSE cr_crapali;

    -- Verifica se eh uma conta migrada
    IF vr_tab_crawrel(vr_ind_crawrel).flgmigra = 1 THEN
       vr_dsalinea := 'CONTA MIGRADA';
    END IF;

    -- Insere a linha de detalhes com os dados dos cheques
    pc_escreve_xml('<cheque>'||
		                 '<cdageapr>'|| vr_tab_crawrel(vr_ind_crawrel).cdageapr                             ||'</cdageapr>'||
                     '<cdbanchq>'|| vr_tab_crawrel(vr_ind_crawrel).cdbanchq                             ||'</cdbanchq>'||
                     '<nrcheque>'|| to_char(vr_tab_crawrel(vr_ind_crawrel).nrcheque,'999G999G990')      ||'</nrcheque>'||
                     '<nralinea>'|| vr_tab_crawrel(vr_ind_crawrel).nralinea                             ||'</nralinea>'||
                     '<dsalinea>'|| substr(vr_dsalinea,1,25)                                            ||'</dsalinea>'||
                     '<vlcheque>'|| 'R$ '||to_char(vr_tab_crawrel(vr_ind_crawrel).vlcheque,'FM99G999G990D00')  ||'</vlcheque>'||
                     '<nrctachq>'|| vr_tab_crawrel(vr_ind_crawrel).nrctachq                             ||'</nrctachq>'|| 
                  '</cheque>',1);

    -- Verifica se a conta posterior eh diferente da conta atual
    IF vr_tab_crawrel.next(vr_ind_crawrel) IS NULL OR -- Se o proximo registro da pl table nao existir
       vr_tab_crawrel(vr_tab_crawrel.next(vr_ind_crawrel)).cdagenci <> vr_tab_crawrel(vr_ind_crawrel).cdagenci OR -- Se a agencia posterior for diferente da agencia atual
       vr_tab_crawrel(vr_tab_crawrel.next(vr_ind_crawrel)).nrdconta <> vr_tab_crawrel(vr_ind_crawrel).nrdconta THEN -- Se a conta posterior for diferente da conta atual

      -- Verifica se deverá cobrar a tarifa de cheque
      IF instr(vr_lscontas,vr_tab_crawrel(vr_ind_crawrel).nrdconta) > 0 THEN
        pc_escreve_xml('<vltarifa> </vltarifa>',1); --Isento
      ELSE
        pc_escreve_xml('<vltarifa>'|| to_char(vr_vltarifa,'FM99G999G990D00') ||'</vltarifa>',1);
      END IF;


      pc_escreve_xml(  '<qtdecheq>'|| vr_qtdecheq                                   ||'</qtdecheq>'||
                       '<totdcheq>'|| 'R$ '||to_char(vr_totdcheq,'FM99G999G990D00') ||'</totdcheq>'||
                     '</conta>',1);
    END IF;

    -- Verifica se eh o ultimo registro da agencia. Neste caso devera solicitar a impressao
    IF vr_tab_crawrel.next(vr_ind_crawrel) IS NULL OR -- Se for o ultimo registro da Pl Table
       vr_tab_crawrel(vr_tab_crawrel.next(vr_ind_crawrel)).cdagenci <> vr_tab_crawrel(vr_ind_crawrel).cdagenci THEN -- Se o proximo registro possui uma agencia diferente

      -- Finaliza o arquivo xml
      pc_escreve_xml('</crps535>',1);

      IF pr_nmtelant = 'COMPEFORA' THEN
        vr_dspathcop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper) || '/rlnsv';
      END IF;

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crps535/conta',    --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl530.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => NULL,                --> nao enviar parametros
                                  pr_dsarqsaid =>  vr_diretori_rl||'/crrl530_'||lpad(vr_tab_crawrel(vr_ind_crawrel).cdagenci,3,'0')||'.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 80,                  --> Quantidade de colunas
                                  pr_sqcabrel  => 1,                   --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                  pr_nmformul  => '80col',             --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                  pr_dspathcop => vr_dspathcop,        --> Diretorio para copia dos arquivos
                                  pr_nrvergrl => 1,
                                  pr_des_erro  => vr_dscritic);        --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Inicializar o CLOB para armazenar os arquivos XML
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o arquivo XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',1);

    END IF; -- Fim da mudanca de agencia

    vr_ind_crawrel := vr_tab_crawrel.next(vr_ind_crawrel);
  END LOOP;


  ---------------------------------
  -- Inicio Layout CRRL529
  ---------------------------------

  -- Inicializar o CLOB para armazenar o arquivo XML agrupador de agencias
  vr_des_xml_999 := NULL;
  dbms_lob.createtemporary(vr_des_xml_999, true);
  dbms_lob.open(vr_des_xml_999, dbms_lob.lob_readwrite);

  -- Inicializa o arquivo XML agrupador de agencias
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',2);

  -- Inicializar o CLOB para armazenar os arquivos XMLs temporarios de agencias
  vr_des_xml_tmp := NULL;
  dbms_lob.createtemporary(vr_des_xml_tmp, true);
  dbms_lob.open(vr_des_xml_tmp, dbms_lob.lob_readwrite);

  -- Inicializar o CLOB para armazenar os arquivos XMLs de agencias
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  -- Inicializa o arquivo XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',1);

  -- busca o indice do primeiro registro da pl/table vr_tab_crawrel
  vr_ind_crawrel_2 := vr_tab_crawrel_2.first;

  -- Inicia o loop para o arquivo CRRL529
  LOOP
    EXIT WHEN vr_ind_crawrel_2 IS NULL;

    -- Atualiza os totais de acordo com o produto do cheque
    IF vr_tab_crawrel_2(vr_ind_crawrel_2).dsprodut = 'CUSTODIA' THEN
      vr_qtdcstod := vr_qtdcstod + 1;
      vr_totcstod := vr_totcstod + vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque;
    ELSIF vr_tab_crawrel_2(vr_ind_crawrel_2).dsprodut = 'DESCONTO' THEN
      vr_qtddscon := vr_qtddscon + 1;
      vr_totdscon := vr_totdscon + vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque;
    ELSIF vr_tab_crawrel_2(vr_ind_crawrel_2).dsprodut = 'LANCHQ'  THEN
      vr_qtdlnchq := vr_qtdlnchq + 1;
      vr_totlnchq := vr_totlnchq + vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque;
    ELSE
      vr_qtdcaixa := vr_qtdcaixa + 1;
      vr_totcaixa := vr_totcaixa + vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque;
    END IF;

    -- Se a agencia for zerada deve-se jogar no erro
    IF vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci = 0 THEN
      -- Efetua tratativa para abertura de nó inicial
      IF vr_tab_crawrel_2.prior(vr_ind_crawrel_2) IS NULL OR -- Se for o primeiro registro
         vr_tab_crawrel_2(vr_tab_crawrel_2.prior(vr_ind_crawrel_2)).flgmigra <> vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra THEN  -- ou se o flag de migracao anterior for diferente do flag de migracao atual
        -- Abre o nó de erro
        pc_escreve_xml('<erro>',3);
      END IF;

      pc_escreve_xml('<cheque>'||
                       '<nmprimtl>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nmprimtl                             ||'</nmprimtl>'||
                       '<nrdconta>'|| gene0002.fn_mask_conta(vr_tab_crawrel_2(vr_ind_crawrel_2).nrdconta)     ||'</nrdconta>'||
                       '<cdcmpchq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdcmpchq                             ||'</cdcmpchq>'||
                       '<cdbanchq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdbanchq                             ||'</cdbanchq>'||
                       '<cdagechq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdagechq                             ||'</cdagechq>'||
                       '<vlcheque>'|| to_char(vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque,'FM99G999G990D00')  ||'</vlcheque>'||
                       '<nralinea>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nralinea                             ||'</nralinea>'||
                       '<nrcheque>'|| gene0002.fn_mask(vr_tab_crawrel_2(vr_ind_crawrel_2).nrcheque,'zzz.zz9') ||'</nrcheque>'||
											 '<cdageapr>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdageapr                             ||'</cdageapr>'||
 											 '<nrctachq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nrctachq                             ||'</nrctachq>'||
                     '</cheque>',3);

      -- Se for o ultimo registro de erro, fecha o nó de erro
      IF vr_tab_crawrel_2.next(vr_ind_crawrel_2) IS NULL OR -- Se for o ultimo registro
         vr_tab_crawrel_2(vr_tab_crawrel_2.next(vr_ind_crawrel_2)).cdagenci <> 0 OR -- Se o proximo registro nao for de erro
         vr_tab_crawrel_2(vr_tab_crawrel_2.next(vr_ind_crawrel_2)).flgmigra <> vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra THEN  -- ou se o flag de migracao posterior for diferente do flag de migracao atual
        -- Fecha o nó de erro
        pc_escreve_xml('</erro>',3);
      END IF;

    ELSE -- Se agencia for diferente de zeros

      -- Busca a descricao da agencia
      OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci =>  vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      IF cr_crapage %NOTFOUND THEN
        CLOSE cr_crapage;
        vr_cdcritic := 15;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_nmarqlog     => vr_nome_arq_log
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic);
        vr_ind_crawrel_2 := vr_tab_crawrel_2.next(vr_ind_crawrel_2);
        CONTINUE;
      END IF;
      CLOSE cr_crapage;

      -- Verifica se a agencia é diferente da anterior
      IF vr_tab_crawrel_2.prior(vr_ind_crawrel_2) IS NULL OR -- Se for o primeiro registro
         vr_tab_crawrel_2(vr_tab_crawrel_2.prior(vr_ind_crawrel_2)).cdagenci <>  vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci OR -- For diferente da agencia anterior
         vr_tab_crawrel_2(vr_tab_crawrel_2.prior(vr_ind_crawrel_2)).flgmigra <>  vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra THEN -- For diferente da flag de migracao anterior
        -- Insere o cabecalho da AGENCIA
        pc_escreve_xml('<agencia>' ||
                         '<cdagenci>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci ||'</cdagenci>'||
                         '<nmresage>'|| rw_crapage.nmresage                         ||'</nmresage>',3);
      END IF;

      IF vr_tab_crawrel_2(vr_ind_crawrel_2).insitprv IN (0,1) THEN -- Nao enviado ou gerado
        vr_dssitprv := 'NAO';
      ELSE
        vr_dssitprv := 'SIM';
      END IF;

      IF vr_tab_crawrel_2(vr_ind_crawrel_2).flgreapr = 1 THEN 
        vr_flgreapr := 'SIM';
      ELSE
        vr_flgreapr := 'NAO';
      END IF;

      -- Insere detalhes
      pc_escreve_xml('<cheque>' ||
                       '<nrdconta>'|| gene0002.fn_mask_conta(vr_tab_crawrel_2(vr_ind_crawrel_2).nrdconta)        ||'</nrdconta>'||
                       '<nmprimtl>'|| substr(vr_tab_crawrel_2(vr_ind_crawrel_2).nmprimtl,1,23)                   ||'</nmprimtl>'||
                       '<nrcheque>'|| gene0002.fn_mask(vr_tab_crawrel_2(vr_ind_crawrel_2).nrcheque,'zzz.zz9')    ||'</nrcheque>'||
											 '<cdageapr>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdageapr                                ||'</cdageapr>'||
                       '<cdbanchq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).cdbanchq                                ||'</cdbanchq>'||
                       '<nralinea>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nralinea                                ||'</nralinea>'||
                       '<vlcheque>'|| 'R$ '||to_char(vr_tab_crawrel_2(vr_ind_crawrel_2).vlcheque,'FM99G999G990D00')     ||'</vlcheque>'||
                       '<dsprodut>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).dsprodut                                ||'</dsprodut>'||
                       '<lotborde>'|| to_char(vr_tab_crawrel_2(vr_ind_crawrel_2).lotborde,'FM999G999G990')       ||'</lotborde>'||
                       '<dtmvtolt>'|| to_char(vr_tab_crawrel_2(vr_ind_crawrel_2).dtmvtolt,'DD/MM/YY')            ||'</dtmvtolt>'||
                       '<dtlibera>'|| to_char(vr_tab_crawrel_2(vr_ind_crawrel_2).dtlibera,'DD/MM/YY')            ||'</dtlibera>'||
                       '<nrprevia>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nrprevia                                ||'</nrprevia>'||
                       '<insitprv>'|| vr_dssitprv                                                                ||'</insitprv>'||
 											 '<nrctachq>'|| vr_tab_crawrel_2(vr_ind_crawrel_2).nrctachq                                ||'</nrctachq>'||
             '<flgreapr>'|| vr_flgreapr                                                                ||'</flgreapr>'||
                     '</cheque>',3);

    END IF; -- Final do IF de verificacao de agencia igual ou diferente de zeros

    -- Verifica se a linha posterior eh diferente da agencia atual
    IF vr_tab_crawrel_2.next(vr_ind_crawrel_2) IS NULL OR -- Se o proximo registro da pl table nao existir
       vr_tab_crawrel_2(vr_tab_crawrel_2.next(vr_ind_crawrel_2)).cdagenci <> vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci OR   -- Se a agencia posterior for diferente da agencia atual
       vr_tab_crawrel_2(vr_tab_crawrel_2.next(vr_ind_crawrel_2)).flgmigra <> vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra THEN -- Se o flag de migracao posterior for diferente do flag de migracao atual

      -- nao imprimir o total de agencia se a agencia for zeros
      IF vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci <> 0 THEN
        -- Escreve os totais e finaliza o arquivo
        pc_escreve_xml(  '<qtdcstod>'|| vr_qtdcstod                                   ||'</qtdcstod>'||
                         '<totcstod>'|| to_char(vr_totcstod,'FM99G999G990D00')        ||'</totcstod>'||
                         '<qtddscon>'|| vr_qtddscon                                   ||'</qtddscon>'||
                         '<totdscon>'|| to_char(vr_totdscon,'FM99G999G990D00')        ||'</totdscon>'||
                         '<qtdlnchq>'|| vr_qtdlnchq                                   ||'</qtdlnchq>'||
                         '<totlnchq>'|| to_char(vr_totlnchq,'FM99G999G990D00')        ||'</totlnchq>'||
                         '<qtdcaixa>'|| vr_qtdcaixa                                   ||'</qtdcaixa>'||
                         '<totcaixa>'|| to_char(vr_totcaixa,'FM99G999G990D00')        ||'</totcaixa>'||
                         '<qtdecheq>'|| to_char(vr_qtdcstod + vr_qtddscon +
                                        vr_qtdlnchq + vr_qtdcaixa)                    ||'</qtdecheq>'||
                         '<totdcheq>'|| 'R$ '||to_char(vr_totcstod+vr_totdscon+vr_totlnchq+
                                                vr_totcaixa,'FM99G999G990D00')        ||'</totdcheq>'||
                       '</agencia>',3);
      END IF;

      -- Acumulador geral dos totais
      vr_qtdcstod_ger := vr_qtdcstod_ger + vr_qtdcstod;
      vr_totcstod_ger := vr_totcstod_ger + vr_totcstod;
      vr_qtddscon_ger := vr_qtddscon_ger + vr_qtddscon;
      vr_totdscon_ger := vr_totdscon_ger + vr_totdscon;
      vr_qtdlnchq_ger := vr_qtdlnchq_ger + vr_qtdlnchq;
      vr_totlnchq_ger := vr_totlnchq_ger + vr_totlnchq;
      vr_qtdcaixa_ger := vr_qtdcaixa_ger + vr_qtdcaixa;
      vr_totcaixa_ger := vr_totcaixa_ger + vr_totcaixa;

      -- Zera as variaveis de totais por agencia
      vr_qtdcstod := 0;
      vr_totcstod := 0;
      vr_qtddscon := 0;
      vr_totdscon := 0;
      vr_qtdlnchq := 0;
      vr_totlnchq := 0;
      vr_qtdcaixa := 0;
      vr_totcaixa := 0;

      -- Joga o conteudo do xml temporario dentro do xml de agencia (que possui o cabecalho)
      dbms_lob.append(vr_des_xml,vr_des_xml_tmp);

      -- Joga o conteudo do xml temporario por agencia dentro do totalizador geral
      dbms_lob.append(vr_des_xml_999,vr_des_xml_tmp);

      -- Finaliza o arquivo xml
      pc_escreve_xml('</crps535>',1);

      -- Imprimir o quebrado por agencia somente se nao for migrado e se nao for agencia 0
      IF vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra = 0 AND
         vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci <> 0 THEN

        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/crps535',          --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl529.jasper',    --> Arquivo de layout do iReport
                                    pr_dsparams  => 'PR_TPRELATO##0',                --> Enviar como parametro apenas a agencia
                                    pr_dsarqsaid =>  vr_diretori_rl||'/crrl529_'||lpad(vr_tab_crawrel_2(vr_ind_crawrel_2).cdagenci,3,'0')||'.lst', --> Arquivo final
                                    pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                    pr_qtcoluna  => 234,
                                    pr_sqcabrel  => 1,
                                    pr_flg_impri => 'N',                 --> Chamar a impressão (Imprim.p)
                                    pr_nmformul  => '234dh',            --> Nome do formulário para impressão
                                    pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                    pr_dspathcop => vr_dspathcop,        --> Diretorio para copia dos arquivos
                                    pr_nrvergrl => 1,
                                    pr_des_erro  => vr_dscritic);        --> Saida com erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END IF; -- Final da validacao da agencia igual a zeros para impressao


      -- Liberando a memoria alocada para os CLOBs
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      dbms_lob.close(vr_des_xml_tmp);
      dbms_lob.freetemporary(vr_des_xml_tmp);

      -- Inicializar o CLOB para armazenar os arquivos XML
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      vr_des_xml_tmp := NULL;
      dbms_lob.createtemporary(vr_des_xml_tmp, true);
      dbms_lob.open(vr_des_xml_tmp, dbms_lob.lob_readwrite);

      -- Inicializa o arquivo XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',1);

      -- Se mudar o flag de migracao ou for o final do arquivo, imprime o arquivo totalizador (CRRL529_99)
      IF vr_tab_crawrel_2.next(vr_ind_crawrel_2) IS NULL OR -- Se o proximo registro da pl table nao existir
         vr_tab_crawrel_2(vr_tab_crawrel_2.next(vr_ind_crawrel_2)).flgmigra <> vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra THEN -- Se o flag de migracao posterior for diferente do flag de migracao atual

        -- Inclui os totalizadores
        pc_escreve_xml(  '<qtdcstod_ger>'|| vr_qtdcstod_ger                                   ||'</qtdcstod_ger>'||
                         '<totcstod_ger>'|| to_char(vr_totcstod_ger,'FM99G999G990D00')        ||'</totcstod_ger>'||
                         '<qtddscon_ger>'|| vr_qtddscon_ger                                   ||'</qtddscon_ger>'||
                         '<totdscon_ger>'|| to_char(vr_totdscon_ger,'FM99G999G990D00')        ||'</totdscon_ger>'||
                         '<qtdlnchq_ger>'|| vr_qtdlnchq_ger                                   ||'</qtdlnchq_ger>'||
                         '<totlnchq_ger>'|| to_char(vr_totlnchq_ger,'FM99G999G990D00')        ||'</totlnchq_ger>'||
                         '<qtdcaixa_ger>'|| vr_qtdcaixa_ger                                   ||'</qtdcaixa_ger>'||
                         '<totcaixa_ger>'|| to_char(vr_totcaixa_ger,'FM99G999G990D00')        ||'</totcaixa_ger>'||
                         '<qtdecheq_ger>'|| to_char(vr_qtdcstod_ger + vr_qtddscon_ger +
                                        vr_qtdlnchq_ger + vr_qtdcaixa_ger)                    ||'</qtdecheq_ger>'||
                         '<totdcheq_ger>'|| to_char(vr_totcstod_ger+vr_totdscon_ger+vr_totlnchq_ger+
                                                vr_totcaixa_ger,'FM99G999G990D00')            ||'</totdcheq_ger>',2);

        -- Finaliza o arquivo xml
        pc_escreve_xml('</crps535>',2);

        -- Se o flag de migracao for igual a zeros, eh arquivo nao migrado
        IF vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra = 0 THEN
          vr_nmarquiv := 'crrl529_'||
                         gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
        ELSE -- Se nao for zero, entao eh referente a contas migradas
          vr_nmarquiv := 'crrl529_'||
                          gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'_migrado.lst';
          -- Atualiza as variaveis para envio do arquivo por email
          vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL529_EMAIL');
          vr_dsassmail  := 'Relatorio de Devolucao Cheques Dep. AILOS';
        END IF;

        -- Nao imprimir se for migrado e cooperativa diferente de 1
        IF NOT (vr_tab_crawrel_2(vr_ind_crawrel_2).flgmigra = 1 AND pr_cdcooper <> 1) THEN

          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                      pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                      pr_dsxml     => vr_des_xml_999,       --> Arquivo XML de dados (CLOB)
                                      pr_dsxmlnode => '/crps535',          --> No base do XML para leitura dos dados
                                      pr_dsjasper  => 'crrl529.jasper',    --> Arquivo de layout do iReport
                                      pr_dsparams  => 'PR_TPRELATO##99',     --> Enviar como parametro apenas a agencia
                                      pr_dsarqsaid =>  vr_diretori_rl||'/'||vr_nmarquiv, --> Arquivo final
                                      pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                      pr_qtcoluna  => 234,
                                      pr_sqcabrel  => 2,
                                      pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                      pr_nmformul  => '234dh',            --> Nome do formulário para impressão
                                      pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                      pr_dsmailcop => vr_email_dest,       --> Lista sep. por ';' de emails para envio do relatório
                                      pr_dsassmail => vr_dsassmail,        --> Assunto do e-mail que enviará o relatório
                                      pr_dscormail => NULL,                --> HTML corpo do email que enviará o relatório
                                      pr_fldosmail => 'S',                              --> Converter anexo para DOS antes de enviar
                                      pr_dscmaxmail => ' | tr -d "\032"',               --> Complemento do comando converte-arquivo
                                      pr_dspathcop => vr_dspathcop,        --> Diretorio para copia dos arquivos
                                      pr_nrvergrl => 1,                                      
                                      pr_des_erro  => vr_dscritic);        --> Saida com erro
        END IF;

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Zera as variaveis de total geral
        vr_qtdcstod_ger := 0;
        vr_totcstod_ger := 0;
        vr_qtddscon_ger := 0;
        vr_totdscon_ger := 0;
        vr_qtdlnchq_ger := 0;
        vr_totlnchq_ger := 0;
        vr_qtdcaixa_ger := 0;
        vr_totcaixa_ger := 0;

        -- Liberando a memoria alocada para os CLOBs
        dbms_lob.close(vr_des_xml_999);
        dbms_lob.freetemporary(vr_des_xml_999);

        -- Inicializar o CLOB para armazenar os arquivos XML
        vr_des_xml_999 := NULL;
        dbms_lob.createtemporary(vr_des_xml_999, true);
        dbms_lob.open(vr_des_xml_999, dbms_lob.lob_readwrite);

        -- Inicializa o arquivo XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps535>',2);


      END IF; -- Fim da impressao do totalizador

    END IF; -- Fim da mudanca de agencia

    vr_ind_crawrel_2 := vr_tab_crawrel_2.next(vr_ind_crawrel_2);
  END LOOP;


  --
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => vr_nome_arq_log,
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- EFETUAR ROLLBACK
    ROLLBACK;
END;
/
