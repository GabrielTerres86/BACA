CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS084(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                             ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                             ,pr_dscritic OUT VARCHAR2) IS
BEGIN

  /* .............................................................................

  Programa: pc_crps084                      Antigo: Fontes/crps084.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Deborah/Edson                   Ultima atualizacao: 17/08/2015
  Data    : Janeiro/94.

  Dados referentes ao programa:

  Frequencia: Diario (Batch - Background).
  Objetivo  : Atende a solicitacao 044.
             Emite relatorio com os 100 maiores devedores e
             daqueles com dividas superiores a 50.000,00.

  Alteracoes: 01/12/95 - Acerto no numero de vias. (Deborah)

             24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             19/11/2004 - Gerar tambem relatorio com TODOS os devedores
                          (rl/crrl071_99.lst);
                          Mudado a logica de leitura e geracao dos arquivos
                          (Evandro).

             09/05/2005 - Incluida a coluna de Saldo Desconto de Cheques;
                          Corrigido o display do total de todos os devedores;
                          Modificada a coluna DEPOSITO VISTA para o valor
                          UTILIZADO (Evandro).

             06/12/2005 - Gerar relatorio dos 100 maiores devedores sem
                          quebras de pagina e com envio de email
                          (crrl071_ .txt) (Diego).

             21/12/2005 - Dpv utilizado calculado de outra forma (Magui).

             03/02/2006 - Modificado nome relatorio(str_4), e alterado
                          para listar TODOS DEVEDORES (Diego).

             15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

             07/11/2006 - Incluido PAC do associado nos relatorios (Elton).

             09/04/2006 - Gerar arquivo com totais das operacoes por CPF
                          (David).

             02/05/2007 - Incluido chave na TEMP-TABLE (Magui).

             13/07/2007 - Retirado envio de email. Alterado nome do arquivo
                          que e salvo na pasta 'rl/' crrl071 e sua extensao
                          para .lst (Guilherme).

             06/02/2008 - Lista os 100 maiores devedores e aqueles com dividas
                          maiores que 50.000,00 (Elton).

             01/09/2008 - Alteracao CDEMPRES (Kbase).

             15/10/2008 - Adaptacao para desconto de titulos (David).

             09/04/2009 - D+1 para titulos em desconto(Guilherme).

             14/04/2009 - Inclusao da coluna RISCO nos relatorios (Elton).

             21/05/2009 - Considerar em divida titulos que vencem em
                          glb_dtmvtolt (Guilherme).

             29/06/2009 - Corrigida limpeza da variavel dec_vldjuros para o
                          desconto de titulos (Evandro).

             10/06/2010 - Incluido tratamento para pagamento realizado atraves
                          de TAA (Elton).

             30/11/2010 - (001) Alteração de format dos campos da tabela para
                          x(50) Leonardo Américo (Kbase).

             27/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                          (Diego).

             23/04/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

             22/07/2013 - Adicionado colunas CONTA/DV, NR.GE, TOTAL GE no
                          relatorio crrl071_*cooperativa*_CPF. (Fabricio)

             25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                          inpessoa (Marcos-Supero)

             26/07/2013 - Leitura da crapebn para somar emprestimos do BNDES
                          ao saldo devedor de emprestimos. (Fabricio)

             28/08/2013 - Adequação Modificações Progress - Alisson (AMcom)
             
             12/11/2013 - Ajustes nos relatórios para PAC por PA e também remoção
                          da chamada ao imprim.p para deixar a geração do PDF 
                          somente para os relatórios com os 100 maiores devedores
                          (Marcos-Supero)
                                 
             18/02/2014 - Alterado totalizador de PAs de 99 para 999. (Gabriel)              
             
             12/12/2014 - Corrigido problemas no relatorio _CPF de registros
                          repetidos e de contas que ficavam em grupos errados
                          (Tiago SD232405)
                          
             17/08/2015 - Ajuste no calculo do Risco, Projeto de Provisao. (James)
  ............................................................................. */

DECLARE

  /* Tipos e registros da pc_crps084 */
  
  -- Definicao do vetor de tipo de relatorio
  TYPE typ_vet_cdrelato IS
    TABLE OF NUMBER(3)
    INDEX BY BINARY_INTEGER;
  vr_vet_cdrelato typ_vet_cdrelato;
  
  -- Definicao do vetor do nome do relatorio
  TYPE typ_vet_nmrelato IS
    TABLE OF VARCHAR2(40)
    INDEX BY BINARY_INTEGER;
  vr_vet_nmrelato typ_vet_nmrelato;
  
  -- Definicao do vetor do nome do destino
  TYPE typ_vet_nmdestin IS
    TABLE OF VARCHAR2(40)
    INDEX BY BINARY_INTEGER;
  vr_vet_nmdestin  typ_vet_nmdestin;
  
  --Definicao do tipo de registro para relatorio geral
  TYPE typ_reg_devedores IS
    RECORD (nrdconta NUMBER
           ,cdagenci NUMBER
           ,nrcpfcgc NUMBER
           ,inpessoa NUMBER
           ,vldivsld NUMBER
           ,vldivepr NUMBER
           ,vldeschq NUMBER
           ,vldestit NUMBER
           ,vldivtot NUMBER
           ,nivrisco VARCHAR2(5)
           ,nrgrpeco INTEGER
           ,vlrtotge NUMBER
           ,nmprimtl crapass.nmprimtl%TYPE
           ,nrmatric crapass.nrmatric%TYPE);
  
  --Definicao do tipo de registro para relatorio por cpf
  TYPE typ_reg_cpf IS
    RECORD (cdcooper INTEGER
           ,nrdconta INTEGER
           ,nrcpfcgc NUMBER
           ,inpessoa NUMBER
           ,vldivsld NUMBER
           ,vldivepr NUMBER
           ,vldeschq NUMBER
           ,vldestit NUMBER
           ,vldivtot NUMBER
           ,nivrisco VARCHAR2(3)
           ,nrgrpeco INTEGER
           ,vlrtotge NUMBER
           ,nmprimtl crapass.nmprimtl%TYPE);
  
  --Definicao do tipo de registro para relatorio crrl071
  TYPE typ_reg_relato IS
    RECORD (cdagenci NUMBER
           ,nrdconta NUMBER
           ,inpessoa NUMBER
           ,nrcpfcgc NUMBER
           ,vldivsld NUMBER
           ,vldivepr NUMBER
           ,vldeschq NUMBER
           ,vldestit NUMBER
           ,vldivtot NUMBER
           ,nivrisco VARCHAR2(5)
           ,nmprimtl crapass.nmprimtl%TYPE
           ,nrmatric crapass.nrmatric%TYPE);
  
  --Definicao do tipo de registro para informacoes associados
  TYPE typ_reg_crapass IS
    RECORD (nrdconta crapass.nrdconta%TYPE
           ,nrcpfcgc crapass.nrcpfcgc%TYPE
           ,nmprimtl crapass.nmprimtl%TYPE
           ,nrmatric crapass.nrmatric%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,inpessoa crapass.inpessoa%TYPE
           ,dsnivris crapass.dsnivris%TYPE);
  
  --Definicao do tipo de registro para juros titulos
  TYPE typ_reg_crapljt IS
    RECORD (vldjuros NUMBER
           ,vlrestit NUMBER);
  
  --Definicao dos tipos de tabelas de memoria
  TYPE typ_tab_tot       IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE typ_tab_cpf       IS TABLE OF typ_reg_cpf INDEX BY VARCHAR2(51);
  TYPE typ_tab_crapgrp   IS TABLE OF crapgrp.nrdgrupo%type INDEX BY VARCHAR2(40);
  TYPE typ_tab_relato    IS TABLE OF typ_reg_relato INDEX BY VARCHAR2(200);
  TYPE typ_tab_crapass   IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
  TYPE typ_tab_crapcdb   IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE typ_tab_devedores IS TABLE OF typ_reg_devedores INDEX BY VARCHAR2(25);
  TYPE typ_tab_dsdrisco  IS TABLE OF VARCHAR2(2) INDEX BY PLS_INTEGER;
  TYPE typ_tab_crapljt   IS TABLE OF typ_reg_crapljt INDEX BY VARCHAR2(60);
  TYPE typ_tab_crapljd   IS TABLE OF NUMBER INDEX BY VARCHAR2(85);
  
  --Definicao das tabelas de memoria
  vr_tab_devedores    typ_tab_devedores;
  vr_tab_dev_conta    typ_tab_devedores;
  vr_tab_dsdrisco     typ_tab_dsdrisco;
  vr_tab_crapass      typ_tab_crapass;
  vr_tab_crapgrp      typ_tab_crapgrp;
  vr_tab_relato       typ_tab_relato;
  vr_tab_crapepr      typ_tab_tot;
  vr_tab_crapebn      typ_tab_tot;
  vr_tab_craptdb      typ_tab_tot;
  vr_tab_crapris      typ_tab_tot;
  vr_tab_crapcdb      typ_tab_crapcdb;
  vr_tab_crapljt      typ_tab_crapljt;
  vr_tab_crapljd      typ_tab_crapljd;
  vr_tab_crapcob      typ_tab_crapljd;
  vr_tab_cpf          typ_tab_cpf;
  
  
  --Cursores da rotina crps323
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.nrtelura
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.dsdircop
          ,cop.nrctactl
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  --Registro do tipo calendario
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  
  --Selecionar informacoes dos programas
  CURSOR cr_crapprg (pr_cdcooper IN crapprg.cdcooper%TYPE
                    ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
    SELECT crapprg.inctrprg
          ,crapprg.nrsolici
          ,crapprg.cdrelato##1
          ,crapprg.cdrelato##2
          ,crapprg.cdrelato##3
          ,crapprg.cdrelato##4
          ,crapprg.cdrelato##5
    FROM crapprg crapprg
    WHERE  crapprg.cdcooper = pr_cdcooper
    AND    upper(crapprg.cdprogra) = upper(pr_cdprogra);
  rw_crapprg cr_crapprg%ROWTYPE;
  
  --Selecionar informacoes dos relatorios
  CURSOR cr_craprel (pr_cdcooper  IN crapcop.cdcooper%TYPE
                    ,pr_cdrelato  IN craprel.cdrelato%TYPE) IS
    SELECT craprel.nmrelato
          ,craprel.nrmodulo
          ,craprel.nmdestin
    FROM craprel craprel
    WHERE craprel.cdcooper = pr_cdcooper
    AND   craprel.cdrelato = pr_cdrelato;
  rw_craprel cr_craprel%ROWTYPE;
  
  --Selecionar informacoes das solicitacoes dos processos
  CURSOR cr_crapsol (pr_cdcooper IN crapsol.cdcooper%TYPE
                    ,pr_dtrefere IN crapsol.dtrefere%TYPE
                    ,pr_nrsolici IN crapsol.nrsolici%TYPE
                    ,pr_insitsol IN crapsol.insitsol%TYPE) IS
    SELECT crapsol.dsparame
          ,crapsol.nrseqsol
          ,crapsol.nrdevias
          ,crapsol.ROWID
    FROM crapsol crapsol
    WHERE crapsol.cdcooper = pr_cdcooper
    AND   crapsol.dtrefere = pr_dtrefere
    AND   crapsol.nrsolici = pr_nrsolici
    AND   crapsol.insitsol = pr_insitsol;
  
  --Selecionar informacoes dos associados
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE) IS
    SELECT /*+ INDEX (crapass crapass##crapass7) */
           crapass.cdagenci
          ,crapass.nrdconta
          ,crapass.inpessoa
          ,crapass.nrmatric
          ,crapass.nmprimtl
          ,crapass.nrcpfcgc
          ,crapass.dsnivris
    FROM crapass crapass
    WHERE crapass.cdcooper = pr_cdcooper;
  
  --Selecionar informacoes do saldo das aplicacoes
  CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
    SELECT crapsld.nrdconta
          ,crapsld.vlsddisp
          ,crapsld.vlsdchsl
    FROM crapsld crapsld
    WHERE crapsld.cdcooper = pr_cdcooper
    ORDER BY crapsld.nrdconta;
  
  --Selecionar informacoes dos emprestimos
  CURSOR cr_crapepr (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
    SELECT  crapepr.nrdconta
           ,Nvl(Sum(Nvl(crapepr.vlsdeved,0)),0) vlsdeved
    FROM crapepr crapepr
    WHERE crapepr.cdcooper = pr_cdcooper
    GROUP BY crapepr.nrdconta;
  
  --Selecionar informacoes dos emprestimos bndes
  CURSOR cr_crapebn (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
    SELECT  crapebn.nrdconta
           ,Nvl(Sum(Nvl(crapebn.vlsdeved,0)),0) vlsdeved
    FROM crapebn crapebn
    WHERE crapebn.cdcooper = pr_cdcooper
    AND   crapebn.insitctr IN ('N','A','P')
    GROUP BY crapebn.nrdconta;
  
  --Selecionar juros descontos de cheque
  CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                    ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                    ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE
                    ,pr_dtmvtopr IN crapcdb.dtlibera%TYPE) IS
    SELECT crapcdb.cdcooper
          ,crapcdb.nrdconta
          ,crapcdb.nrborder
          ,crapcdb.cdcmpchq
          ,crapcdb.cdbanchq
          ,crapcdb.cdagechq
          ,crapcdb.nrctachq
          ,crapcdb.nrcheque
          ,Nvl(crapcdb.vlcheque,0) vlcheque
    FROM crapcdb crapcdb
    WHERE crapcdb.cdcooper = pr_cdcooper
    AND   crapcdb.dtlibera > pr_dtmvtolt
    AND   crapcdb.dtlibbdc < pr_dtmvtopr
    AND   crapcdb.nrdconta = pr_nrdconta
    AND   (crapcdb.dtdevolu IS NULL OR
          (crapcdb.dtdevolu IS NOT NULL AND crapcdb.dtdevolu > pr_dtmvtolt));
  
  --Selecionar contas com desconto de cheques
  CURSOR cr_crapcdb_carga (pr_cdcooper IN crapcdb.cdcooper%type
                          ,pr_dtmvtolt IN crapcdb.dtlibera%type
                          ,pr_dtmvtopr IN crapcdb.dtlibera%type) IS
    SELECT /*+ INDEX (crapcdb crapcdb##crapcdb3) */
           crapcdb.nrdconta
    FROM crapcdb crapcdb
    WHERE crapcdb.cdcooper = pr_cdcooper
    AND   crapcdb.dtlibera > pr_dtmvtolt
    AND   crapcdb.dtlibbdc < pr_dtmvtopr
    AND   (crapcdb.dtdevolu IS NULL OR
          (crapcdb.dtdevolu IS NOT NULL AND crapcdb.dtdevolu > pr_dtmvtolt));
                                      
  --Selecionar lancamentos de juros de desconto de cheque
  CURSOR cr_crapljd (pr_cdcooper IN crapljd.cdcooper%TYPE
                    ,pr_dtrefere IN crapljd.dtrefere%TYPE) IS
    SELECT  crapljd.nrdconta
           ,crapljd.nrborder
           ,crapljd.cdcmpchq
           ,crapljd.cdbanchq
           ,crapljd.cdagechq
           ,crapljd.nrctachq
           ,crapljd.nrcheque
           ,nvl(sum(nvl(crapljd.vldjuros,0)),0) vldjuros 
    FROM crapljd crapljd
    WHERE crapljd.cdcooper = pr_cdcooper
    AND   crapljd.dtrefere > pr_dtrefere
    GROUP BY crapljd.nrdconta
           ,crapljd.nrborder
           ,crapljd.cdcmpchq
           ,crapljd.cdbanchq
           ,crapljd.cdagechq
           ,crapljd.nrctachq
           ,crapljd.nrcheque;
  
  --Selecionar lancamentos de juros de desconto de titulos
  CURSOR cr_crapljt (pr_cdcooper IN crapljd.cdcooper%TYPE
                    ,pr_dtrefere IN crapljd.dtrefere%TYPE) IS
    SELECT  crapljt.nrdconta
           ,crapljt.nrborder
           ,crapljt.cdbandoc
           ,crapljt.nrdctabb
           ,crapljt.nrcnvcob
           ,crapljt.nrdocmto
           ,Nvl(Sum(Nvl(crapljt.vldjuros,0)),0) vldjuros
           ,Nvl(Sum(Nvl(crapljt.vlrestit,0)),0) vlrestit
    FROM crapljt crapljt
    WHERE crapljt.cdcooper = pr_cdcooper
    AND   crapljt.dtrefere > pr_dtrefere
    GROUP BY crapljt.nrdconta
            ,crapljt.nrborder
            ,crapljt.cdbandoc
            ,crapljt.nrdctabb
            ,crapljt.nrcnvcob
            ,crapljt.nrdocmto;
  
  
  --Selecionar informacoes dos titulos do bordero descontados
  CURSOR cr_craptdb_conta (pr_cdcooper IN craptdb.cdcooper%TYPE
                          ,pr_dtmvtotl IN craptdb.dtdpagto%TYPE) IS
    SELECT craptdb.nrdconta
          ,craptdb.insittit
    FROM craptdb  craptdb
    WHERE craptdb.cdcooper = pr_cdcooper
    AND  ((craptdb.insittit = 4 AND craptdb.dtvencto >= pr_dtmvtotl) OR
          (craptdb.insittit = 2 AND craptdb.dtdpagto = pr_dtmvtotl));
  
  --Selecionar informacoes dos titulos do bordero descontados
  CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE
                    ,pr_nrdconta IN craptdb.nrdconta%TYPE
                    ,pr_dtmvtotl IN craptdb.dtdpagto%TYPE) IS
    SELECT craptdb.cdbandoc
          ,craptdb.nrdctabb
          ,craptdb.nrcnvcob
          ,craptdb.nrdconta
          ,craptdb.nrdocmto
          ,craptdb.insittit
          ,craptdb.nrborder
          ,craptdb.vltitulo
          ,craptdb.ROWID
    FROM craptdb  craptdb
    WHERE craptdb.cdcooper = pr_cdcooper
    AND   craptdb.nrdconta = pr_nrdconta
    AND  ((craptdb.insittit = 4 AND craptdb.dtvencto >= pr_dtmvtotl) OR
          (craptdb.insittit = 2 AND craptdb.dtdpagto = pr_dtmvtotl));
  
  --Selecionar informacoes de cobranca
  CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                    ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                    ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
    SELECT crapcob.indpagto
    FROM  crapcob crapcob
    WHERE crapcob.cdcooper = pr_cdcooper
    AND   crapcob.cdbandoc = pr_cdbandoc
    AND   crapcob.nrdctabb = pr_nrdctabb
    AND   crapcob.nrcnvcob = pr_nrcnvcob
    AND   crapcob.nrdconta = pr_nrdconta
    AND   crapcob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%ROWTYPE;
  
  -- Selecionar os dados da tabela Generica
  CURSOR cr_craptab (pr_cdcooper   craptab.cdcooper%TYPE
                    ,pr_nmsistem   craptab.nmsistem%TYPE
                    ,pr_tptabela   craptab.tptabela%TYPE
                    ,pr_cdempres   craptab.cdempres%TYPE
                    ,pr_cdacesso   craptab.cdacesso%TYPE) IS
    SELECT  GENE0002.fn_char_para_number(SubStr(craptab.dstextab,12,2)) contador
           ,TRIM(SUBSTR(craptab.dstextab,8,3)) dsdrisco
    FROM craptab  craptab
    WHERE craptab.cdcooper = pr_cdcooper
    AND   craptab.nmsistem = pr_nmsistem
    AND   craptab.tptabela = pr_tptabela
    AND   craptab.cdempres = pr_cdempres
    AND   craptab.cdacesso = pr_cdacesso;
  
   -- Busca dos dados do ultimo risco Doctos 3020/3030
   CURSOR cr_crapris_last(pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_dtultdia IN DATE) IS
     SELECT crapris.innivris
     FROM crapris crapris
     WHERE crapris.cdcooper = pr_cdcooper
     AND   crapris.nrdconta = pr_nrdconta
     AND   crapris.dtrefere = pr_dtultdia
     AND   crapris.inddocto = 1 -- 3020 e 3030
     ORDER BY CDCOOPER DESC, NRDCONTA DESC, DTREFERE DESC, INNIVRIS DESC;
   rw_crapris_last cr_crapris_last%ROWTYPE;
  
   --Carregar Riscos
   CURSOR cr_crapris_teste (pr_cdcooper IN crapris.cdcooper%TYPE                           
                           ,pr_vldivida IN crapris.vldivida%TYPE
                           ,pr_dtultdia IN DATE) IS
     WITH cte as
     ( SELECT nrdconta,
              innivris,
              row_Number() OVER ( partition by nrdconta order by progress_recid desc) as rn
         from crapris
        WHERE crapris.cdcooper = pr_cdcooper
          AND crapris.inddocto = 1
          and crapris.dtrefere = pr_dtultdia
          AND crapris.vldivida > pr_vldivida
     ORDER BY CDCOOPER DESC, NRDCONTA DESC, DTREFERE DESC, INNIVRIS DESC
      )
      SELECT nrdconta,innivris
      from cte where rn = 1;  
  
   --Selecionar informacoes dos grupos
   CURSOR cr_crapgrp (pr_cdcooper IN crapgrp.cdcooper%type) IS
     SELECT  crapgrp.nrctasoc
            ,crapgrp.nrcpfcgc
            ,crapgrp.nrdgrupo
            ,crapgrp.dsdrisco
            ,crapgrp.innivris
            ,crapgrp.innivrge
     FROM crapgrp
     WHERE crapgrp.cdcooper = pr_cdcooper;
   rw_crapgrp cr_crapgrp%ROWTYPE;
  
  --Tipo do Cursor de risco para Bulk Collect
  TYPE typ_crapris IS TABLE of cr_crapris_teste%ROWTYPE;
  vr_tab_crapris_teste typ_crapris;
        
  --Variaveis Locais
  
  /* Totalizadores */
  vr_set_vldivsld NUMBER:= 0;
  vr_set_vldivepr NUMBER:= 0;
  vr_set_vldeschq NUMBER:= 0;
  vr_set_vldestit NUMBER:= 0;
  vr_set_vldivtot NUMBER:= 0;
  vr_set_nrgrpeco NUMBER:= 0;
  
  /* Variaveis Auxiliares */
  vr_vldivsld     NUMBER;
  vr_vldivepr     NUMBER;
  vr_vldivtot     NUMBER;
  vr_vldeschq     NUMBER;
  vr_vldestit     NUMBER;
  vr_contador     INTEGER;
  vr_cdcritic     INTEGER;
  vr_nrdgrupo     INTEGER;
  vr_cdprogra     VARCHAR2(10);
  vr_index        NUMBER;
  vr_nrcpfcgc     NUMBER;
  vr_vlrtotge     NUMBER;
  vr_regexist     BOOLEAN;
  vr_flg_crapris  BOOLEAN;
  vr_dtrefere     DATE;
  vr_dec_vldjuros NUMBER;
  vr_dec_vljurchq NUMBER;
  vr_set_nivrisco VARCHAR2(5);
  vr_vlr_arrasto  NUMBER;
  vr_saldo_atual  NUMBER;
  vr_novo_saldo   NUMBER;
  vr_rel_dsrelato VARCHAR2(200);
  
  --Variavel usada para montar o indice da tabela de memoria
  vr_index_dev      VARCHAR2(25);
  vr_index_relato   VARCHAR2(200);
  vr_index_cpf      VARCHAR2(51);
  vr_index_crapgrp  VARCHAR2(40);
  vr_index_crapljt  VARCHAR2(60);
  vr_index_crapljd  VARCHAR2(85);
  
  --Variaveis da Crapdat
  vr_dtmvtolt     DATE;
  vr_dtmvtopr     DATE;
  vr_dtultdia     DATE;
  
  -- Variável para armazenar as informações em XML
  vr_des_xml        CLOB;
  vr_des_xml_quebra CLOB;
  vr_texto          VARCHAR2(32767);
  vr_texto_quebra   VARCHAR2(32767);
  
  --Variaveis para retorno de erro
  vr_des_erro    VARCHAR2(4000);
  vr_dstextab    VARCHAR2(1000);
  
  --Variavel para arquivo de dados e xml
  vr_nom_direto  VARCHAR2(100);
  vr_nom_arquivo VARCHAR2(100);
  vr_nom_arquivo_quebra VARCHAR2(100);
  
  --Variaveis de Excecao
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_exc_pula   EXCEPTION;
  
  --Procedure para limpar os dados das tabelas de memoria
  PROCEDURE pc_limpa_tabela IS
  BEGIN
    vr_tab_devedores.DELETE;
    vr_tab_dev_conta.DELETE;
    vr_tab_dsdrisco.DELETE;
    vr_tab_crapepr.DELETE;
    vr_tab_crapebn.DELETE;
    vr_tab_craptdb.DELETE;
    vr_tab_crapass.DELETE;
    vr_tab_crapgrp.DELETE;
    vr_tab_relato.DELETE;
    vr_tab_crapcdb.DELETE;
    vr_tab_crapljt.DELETE;
    vr_tab_crapljd.DELETE;
    vr_tab_crapcob.DELETE;
    vr_tab_crapris.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      --Variavel de erro recebe erro ocorrido
      vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps084.pc_limpa_tabela. '||sqlerrm;
      --Sair do programa
      RAISE vr_exc_saida;
  END;
  
  --Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,pr_grava IN BOOLEAN) IS
  BEGIN
    IF NOT pr_grava THEN
      vr_texto:= vr_texto||pr_des_dados;
    ELSE
      --Escrever no arquivo XML
      dbms_lob.writeappend(vr_des_xml,length(vr_texto),vr_texto);
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
    --Escrever no arquivo XML
    dbms_lob.writeappend(vr_des_xml,length(vr_texto),vr_texto);
    --Reiniciar a variavel
    vr_texto:= pr_des_dados;
  END;
  
  --Escrever no arquivo CLOB de quebra
  PROCEDURE pc_escreve_xml_quebra(pr_des_dados IN VARCHAR2,pr_grava IN BOOLEAN) IS
  BEGIN
    IF NOT pr_grava THEN
      vr_texto_quebra:= vr_texto_quebra||pr_des_dados;
    ELSE
      dbms_lob.writeappend(vr_des_xml_quebra,length(vr_texto_quebra),vr_texto_quebra);
      dbms_lob.writeappend(vr_des_xml_quebra,length(pr_des_dados),pr_des_dados);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
    --Escrever no arquivo XML
    dbms_lob.writeappend(vr_des_xml_quebra,length(vr_texto_quebra),vr_texto_quebra);
    --Reiniciar a variavel
    vr_texto_quebra:= pr_des_dados;
  END;
  
  --Geração do relatório por crrl071
  PROCEDURE pc_imprime_crrl071 (pr_nmarqimp IN VARCHAR2
                               ,pr_dsrelato IN VARCHAR2
                               ,pr_des_erro OUT VARCHAR2) IS
    --Variavel de Exceção
    vr_exc_saida EXCEPTION;
  BEGIN
    --Inicializar variavel de erro
    pr_des_erro:= NULL;
    -- Busca do diretório base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  
    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    --Inicializar variavel de texto do clob
    vr_texto:= NULL;
    -- Inicilizar as informações do XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl071><contas>',FALSE);
  
    --Inicializar contador
    vr_contador:= 0;
    --Acessar primeiro registro da tabela de memoria de detalhe
    vr_index_relato:= vr_tab_relato.FIRST;
    WHILE vr_index_relato IS NOT NULL  LOOP
      --Incrementar Contador
      vr_contador:= vr_contador + 1;
      --Sair se o contador passar de 100 e valor divida menor 50.000
      IF vr_contador > 100  AND vr_tab_relato(vr_index_relato).vldivtot < 50000  THEN
        EXIT;
      ELSE
        --Montar tag da conta para arquivo XML
        pc_escreve_xml
        ('<conta>
           <cdagenci>'||vr_tab_relato(vr_index_relato).cdagenci||'</cdagenci>
           <nrdordem>'||vr_contador||'</nrdordem>
           <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_relato(vr_index_relato).nrdconta)||'</nrdconta>
           <nrcpfcgc>'||GENE0002.fn_mask_cpf_cnpj(vr_tab_relato(vr_index_relato).nrcpfcgc,vr_tab_relato(vr_index_relato).inpessoa)||'</nrcpfcgc>
           <nmprimtl>'||SUBSTR(vr_tab_relato(vr_index_relato).nmprimtl,1,40)||'</nmprimtl>
           <nrmatric>'||GENE0002.fn_mask_matric(vr_tab_relato(vr_index_relato).nrmatric)||'</nrmatric>
           <vldivsld>'||To_Char(vr_tab_relato(vr_index_relato).vldivsld,'fm999g999g999g990d00')||'</vldivsld>
           <vldivepr>'||To_Char(vr_tab_relato(vr_index_relato).vldivepr,'fm999g999g999g990d00')||'</vldivepr>
           <vldeschq>'||To_Char(vr_tab_relato(vr_index_relato).vldeschq,'fm999g999g999g990d00')||'</vldeschq>
           <vldestit>'||To_Char(vr_tab_relato(vr_index_relato).vldestit,'fm999g999g999g990d00')||'</vldestit>
           <vldivtot>'||To_Char(vr_tab_relato(vr_index_relato).vldivtot,'fm999g999g999g990d00')||'</vldivtot>
           <nivrisco>'||vr_tab_relato(vr_index_relato).nivrisco||'</nivrisco>
        </conta>',FALSE);
        --Encontrar o proximo registro da tabela de memoria
        vr_index_relato:= vr_tab_relato.NEXT(vr_index_relato);
      END IF;
    END LOOP;
    --Finalizar tag detalhe
    pc_escreve_xml('</contas></crrl071>',TRUE);
  
    -- Efetuar solicitação de geração de relatório --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl071/contas/conta'       --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl071.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => 'PR_DSRELATO##'||pr_dsrelato||'@@PR_SHOWCAB##S'  --> Titulo do relatório
                               ,pr_dsarqsaid => vr_nom_direto||'/'||pr_nmarqimp||'.lst' --> Arquivo final
                               ,pr_qtcoluna  => 234                 --> 234 colunas
                               ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                               ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '234dh'             --> Nome do formulário para impressão
                               ,pr_nrcopias  => 2                   --> Número de cópias
                               ,pr_flg_gerar => 'N'                 --> gerar PDF
                               ,pr_des_erro  => vr_des_erro);       --> Saída com erro
    -- Testar se houve erro
    IF vr_des_erro IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
  
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro:= vr_des_erro;
    WHEN OTHERS THEN
      pr_des_erro:= 'Erro ao imprimir relatório crrl071. '||sqlerrm;
  END;
  
  --Impressao do cabecalho do relatorio crrl564
  PROCEDURE pc_imprime_cabecalho (pr_nmrescop   IN VARCHAR2
                                 ,pr_nmrelato   IN VARCHAR2
                                 ,pr_dtmvtolt   IN DATE
                                 ,pr_nmmodulo   IN VARCHAR2
                                 ,pr_cdrelato   IN NUMBER
                                 ,pr_progerad   IN VARCHAR2
                                 ,pr_pagnum     IN NUMBER
                                 ,pr_nmdestin   IN VARCHAR2
                                 ,pr_dsrelato   IN VARCHAR2) IS
    --Variaveis Locais
    vr_setlinha  VARCHAR2(1000);
  
  BEGIN
    --Montar string de cabecalho
    vr_setlinha:=  RPad(pr_nmrescop,15,' ') ||
                   '- ' ||
                   RPad(pr_nmrelato,91,' ') ||
                   ' - REF.' ||
                   '  '||
                   To_Char(pr_dtmvtolt,'DD/MM/YYYY')||
                   '  '||
                   RPad(pr_nmmodulo,67,' ')||
                   LPad(gene0002.fn_mask(pr_cdrelato,'999'),3,' ')||
                   '/'||
                   RPad(pr_progerad,3,' ')||
                   ' EM '||
                   To_Char(SYSDATE,'DD/MM/YYYY')||
                   ' AS '||
                   To_Char(SYSDATE,'HH24:MI')||
                   ' '||
                   'HR PAG.'||
                   ' '||
                   Lpad(gene0002.fn_mask(pr_pagnum,'zz9'),3,' ')||Chr(13);
  
    -- Adiciona a linha de cabecalho
    pc_escreve_xml_quebra(vr_setlinha,FALSE);
    --Adicionar linha em branco
    pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
    vr_setlinha:= 'DESTINO: '||RPad(pr_nmdestin,40,' ')||Chr(13);
    pc_escreve_xml_quebra(vr_setlinha,FALSE);
    --Adicionar linha em branco
    pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
    pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
    vr_setlinha:= 'SOLICITADO: '||pr_dsrelato||Chr(13);
    pc_escreve_xml_quebra(vr_setlinha,FALSE);
    pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
    pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
    vr_setlinha:= RPad('PA ',3,' ')||LPad(' ',4,' ')||'ORD'||LPad(' ',3,' ')||
                  'CONTA/DV'||' '||'MATRIC.'||' '|| 'ASSOCIADO'||LPad(' ',42,' ')||
                  'CPF/CNPJ'||' '||'DPV.UTILIZADO'||LPad(' ',3,' ')||
                  'EMPRESTIMOS'||LPad(' ',2,' ')||'DSC. CHEQUES'||LPad(' ',2,' ')||
                  'DSC. TITULOS'||LPad(' ',10,' ')||'TOTAL RISCO'||Chr(13);
    pc_escreve_xml_quebra(vr_setlinha,FALSE);
    vr_setlinha:= LPad('-',3,'-')||'  '||LPad('-',5,'-')||' '||LPad('-',10,'-')||' '||
                  LPad('-',7,'-')||' '||LPad('-',40,'-')||' '||LPad('-',18,'-')||' '||
                  LPad('-',13,'-')||' '||LPad('-',13,'-')||' '||LPad('-',13,'-')||' '||
                  LPad('-',13,'-')||' '||LPad('-',14,'-')||' '||LPad('-',5,'-')||Chr(13);
    pc_escreve_xml_quebra(vr_setlinha,FALSE);
  END pc_imprime_cabecalho;
  
  --Geração do relatório por crrl071_99
  PROCEDURE pc_imprime_crrl071_99 (pr_cdprogra IN VARCHAR2
                                  ,pr_dsrelato IN VARCHAR2
                                  ,pr_des_erro OUT VARCHAR2) IS
  
    --Variavel para arquivo saida
    vr_rel_nrmodulo VARCHAR2(100);
    vr_setlinha     VARCHAR2(4000);
  
    -- Variaveis auxiliares para busca tabela memoria
    vr_aux_cdagenci  crapass.cdagenci%TYPE;
    vr_aux_nrdconta  crapass.nrdconta%TYPE;
    vr_aux_nrmatric  crapass.nrmatric%TYPE;
    vr_aux_nmprimtl  crapass.nmprimtl%TYPE;
    vr_aux_nrcpfcgc  crapass.nrcpfcgc%TYPE;
    vr_aux_inpessoa  crapass.inpessoa%TYPE;
    vr_aux_vldivsld  NUMBER;
    vr_aux_vldivepr  NUMBER;
    vr_aux_vldivtot  NUMBER;
    vr_aux_vldeschq  NUMBER;
    vr_aux_vldestit  NUMBER;
    vr_aux_nivrisco  VARCHAR2(5);
  
    --Variavel de Exceção
    vr_exc_saida EXCEPTION;
    BEGIN
  
      --Inicializar variavel de erro
      pr_des_erro:= NULL;
      -- Busca do diretório base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  
      --Selecionar informacoes dos programas
      OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                      ,pr_cdprogra => pr_cdprogra);
      --Posicionar no proximo registro
      FETCH cr_crapprg INTO rw_crapprg;
      --Fechar Cursor
      CLOSE cr_crapprg;
  
      --Popular vetor vr_vet_cdrelato com os codigos dos relatorios
      vr_vet_cdrelato(1):= rw_crapprg.cdrelato##1;
      vr_vet_cdrelato(2):= rw_crapprg.cdrelato##2;
      vr_vet_cdrelato(3):= rw_crapprg.cdrelato##3;
      vr_vet_cdrelato(4):= rw_crapprg.cdrelato##4;
      vr_vet_cdrelato(5):= rw_crapprg.cdrelato##5;
  
      --Atribuir valores para os nomes e destinos dos relatorios
      FOR vr_ind_relato IN 1..5 LOOP
        vr_vet_nmdestin(vr_ind_relato):= NULL;
        --Selecionar informacoes dos relatorios
        FOR rw_craprel IN cr_craprel (pr_cdcooper => pr_cdcooper
                                     ,pr_cdrelato => vr_vet_cdrelato(vr_ind_relato)) LOOP
          --Atualizar vetor com o nome do destino em Maiúsculo
          vr_vet_nmdestin(vr_ind_relato):= Upper(rw_craprel.nmdestin);
          --Atualizar vetor com o nome do relatorio em Maiusculo
          vr_vet_nmrelato(vr_ind_relato):= Upper(rw_craprel.nmrelato);
          vr_rel_nrmodulo:= Upper(rw_craprel.nrmodulo);
        END LOOP;
      END LOOP;
  
      --Determinar o nome do arquivo que será gerado
      vr_nom_arquivo := 'crrl071_999';
      --Determinar o nome do arquivo sem quebras que será gerado
      vr_nom_arquivo_quebra:= 'crrl071'||rw_crapcop.dsdircop||'.lst';
  
      -- Inicializar o CLOB para o crrl071_99
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  
      -- Inicializar o CLOB para o crrl071_99 sem quebras
      dbms_lob.createtemporary(vr_des_xml_quebra, TRUE);
      dbms_lob.open(vr_des_xml_quebra, dbms_lob.lob_readwrite);
  
      --Inicializar variavel de texto do clob
      vr_texto:= NULL;
      vr_texto_quebra:= NULL;
  
      --Imprimir o cabecalho no arquivo lst
      pc_imprime_cabecalho (pr_nmrescop   => rw_crapcop.nmrescop
                           ,pr_nmrelato   => vr_vet_nmrelato(4)
                           ,pr_dtmvtolt   => vr_dtmvtolt
                           ,pr_nmmodulo   => GENE0001.vr_vet_nmmodulo(vr_rel_nrmodulo)
                           ,pr_cdrelato   => vr_vet_cdrelato(4)
                           ,pr_progerad   => SubStr(vr_cdprogra,5,3)
                           ,pr_pagnum     => 1
                           ,pr_nmdestin   => vr_vet_nmdestin(4)
                           ,pr_dsrelato   => pr_dsrelato);
  
      --Inicializar contador
      vr_contador:= 0;
      --Inicializar totalizadores
      vr_vldivsld:= 0;
      vr_vldivepr:= 0;
      vr_vldivtot:= 0;
      vr_vldeschq:= 0;
      vr_vldestit:= 0;
  
      -- Inicilizar as informações do XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl071><contas>',FALSE);
  
      --Acessar primeiro registro da tabela de memoria de detalhe
      vr_index_relato:= vr_tab_relato.FIRST;
      WHILE vr_index_relato IS NOT NULL LOOP
        --Atribuir valores para variaveis aux
        vr_aux_cdagenci:= vr_tab_relato(vr_index_relato).cdagenci;
        vr_aux_nrdconta:= vr_tab_relato(vr_index_relato).nrdconta;
        vr_aux_nrmatric:= vr_tab_relato(vr_index_relato).nrmatric;
        vr_aux_nmprimtl:= vr_tab_relato(vr_index_relato).nmprimtl;
        vr_aux_nrcpfcgc:= vr_tab_relato(vr_index_relato).nrcpfcgc;
        vr_aux_inpessoa:= vr_tab_relato(vr_index_relato).inpessoa;
        vr_aux_vldivsld:= vr_tab_relato(vr_index_relato).vldivsld;
        vr_aux_vldivepr:= vr_tab_relato(vr_index_relato).vldivepr;
        vr_aux_vldivtot:= vr_tab_relato(vr_index_relato).vldivtot;
        vr_aux_vldeschq:= vr_tab_relato(vr_index_relato).vldeschq;
        vr_aux_vldestit:= vr_tab_relato(vr_index_relato).vldestit;
        vr_aux_nivrisco:= vr_tab_relato(vr_index_relato).nivrisco;
        --Incrementar Contador
        vr_contador:= vr_contador + 1;
        --Montar tag da conta para arquivo XML
        pc_escreve_xml
          ('<conta>
             <cdagenci>'||vr_aux_cdagenci||'</cdagenci>
             <nrdordem>'||vr_contador||'</nrdordem>
             <nrdconta>'||GENE0002.fn_mask_conta(vr_aux_nrdconta)||'</nrdconta>
             <nrcpfcgc>'||GENE0002.fn_mask_cpf_cnpj(vr_aux_nrcpfcgc,vr_aux_inpessoa)||'</nrcpfcgc>
             <nmprimtl>'||SUBSTR(vr_aux_nmprimtl,1,40)||'</nmprimtl>
             <nrmatric>'||GENE0002.fn_mask_matric(vr_aux_nrmatric)||'</nrmatric>
             <vldivsld>'||To_Char(vr_aux_vldivsld,'fm999g999g999g990d00')||'</vldivsld>
             <vldivepr>'||To_Char(vr_aux_vldivepr,'fm999g999g999g990d00')||'</vldivepr>
             <vldeschq>'||To_Char(vr_aux_vldeschq,'fm999g999g999g990d00')||'</vldeschq>
             <vldestit>'||To_Char(vr_aux_vldestit,'fm999g999g999g990d00')||'</vldestit>
             <vldivtot>'||To_Char(vr_aux_vldivtot,'fm999g999g999g990d00')||'</vldivtot>
             <nivrisco>'||vr_aux_nivrisco||'</nivrisco>
          </conta>',FALSE);
  
        --Montar linha para gravar no arquivo
        vr_setlinha:= LPad(vr_aux_cdagenci,3,' ')||' '||
                      LPad(vr_contador,6,' ')||' '||
                      LPad(GENE0002.fn_mask_conta(vr_aux_nrdconta),10,' ')||' '||
                      LPad(GENE0002.fn_mask_matric(vr_aux_nrmatric),7,' ')||' '||
                      SUBSTR(RPad(vr_aux_nmprimtl,40,' '),1,40)||' '||
                      LPad(GENE0002.fn_mask_cpf_cnpj(vr_aux_nrcpfcgc,vr_aux_inpessoa),18,' ')||' '||
                      LPad(To_Char(vr_aux_vldivsld,'fm999g999g999g990d00'),13,' ')||' '||
                      LPad(To_Char(vr_aux_vldivepr,'fm999g999g999g990d00'),13,' ')||' '||
                      LPad(To_Char(vr_aux_vldeschq,'fm999g999g999g990d00'),13,' ')||' '||
                      LPad(To_Char(vr_aux_vldestit,'fm999g999g999g990d00'),13,' ')||' '||
                      LPad(To_Char(vr_aux_vldivtot,'fm999g999g999g990d00'),14,' ')||' '||
                      vr_aux_nivrisco||Chr(13);
       --Escrever informacoes no arquivo
        pc_escreve_xml_quebra(vr_setlinha,FALSE);
        --Acumular totais
        vr_vldivsld:= vr_vldivsld + vr_aux_vldivsld;
        vr_vldivepr:= vr_vldivepr + vr_aux_vldivepr;
        vr_vldivtot:= vr_vldivtot + vr_aux_vldivtot;
        vr_vldeschq:= vr_vldeschq + vr_aux_vldeschq;
        vr_vldestit:= vr_vldestit + vr_aux_vldestit;
  
        --Encontrar o proximo registro da tabela de memoria
        vr_index_relato:= vr_tab_relato.NEXT(vr_index_relato);
      END LOOP;
  
      --Finalizar tag contas arquivo crrl071
      pc_escreve_xml('</contas></crrl071>',TRUE);
  
      --Escrever informacoes no arquivo sem quebras
      pc_escreve_xml_quebra(Chr(10)||Chr(13),FALSE);
  
      --Imprimir cabecalho dos totais
      vr_setlinha:= LPad(' ',59,' ')||'DEPOSITOS A VISTA'||LPad(' ',9,' ')||'EMPRESTIMOS'||'  '||
                    'DESCONTOS DE CHEQUES'||'  '||'DESCONTOS DE TITULOS'||LPad(' ',15,' ')||'TOTAL'||Chr(13);
      --Escrever informacoes no arquivo
      pc_escreve_xml_quebra(vr_setlinha,FALSE);
  
      --Imprimir totais
      vr_setlinha:= LPad(' ',43,' ')||
                    'TOTAIS ==>'||
                    LPad(To_Char(vr_vldivsld,'fm999g999g999g990d00'),23,' ')||
                    LPad(To_Char(vr_vldivepr,'fm999g999g999g990d00'),20,' ')||
                    LPad(To_Char(vr_vldeschq,'fm999g999g999g990d00'),22,' ')||
                    LPad(To_Char(vr_vldestit,'fm999g999g999g990d00'),22,' ')||
                    LPad(To_Char(vr_vldivtot,'fm999g999g999g990d00'),20,' ')||Chr(13);
      --Escrever informacoes no arquivo
      pc_escreve_xml_quebra(vr_setlinha,TRUE);
  
      -- Efetuar solicitação de geração de relatório crrl071_99 --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl071/contas/conta'       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl071.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'PR_DSRELATO##'||pr_dsrelato||'@@PR_SHOWCAB##S' --> Titulo do relatório
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                 ,pr_qtcoluna  => 234                 --> 234 colunas
                                 ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                 ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_des_erro);       --> Saída com erro
      -- Testar se houve erro
      IF vr_des_erro IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
  
      --Solicitar geracao do arquivo
      GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper             --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_xml_quebra    --> Arquivo XML de dados
                                         ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo_quebra                 --> Path/Nome do arquivo PDF gerado
                                         ,pr_cdrelato  => 071                  --> Código fixo para o relatório
                                         ,pr_flg_impri => 'N'                  --> Chamar a impressão (Imprim.p)
                                         ,pr_flg_gerar => 'N'                  --> Gerar o arquivo na hora
                                         ,pr_nmformul  => '234dh'              --> Nome do formulário para impressão
                                         ,pr_nrcopias  => 1                    --> Número de cópias para impressão
                                         ,pr_dspathcop => NULL                 --> Lista sep. por ';' de diretórios a copiar o arquivo
                                         ,pr_dsmailcop => NULL                 --> Lista sep. por ';' de emails para envio do arquivo
                                         ,pr_dsassmail => NULL                 --> Assunto do e-mail que enviará o arquivo
                                         ,pr_dscormail => NULL                 --> HTML corpo do email que enviará o arquivo
                                         ,pr_des_erro  => vr_des_erro);        --> Retorno de Erro
      --Se ocorreu erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
  
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  
      -- Liberando a memória alocada pro CLOB sem quebra
      dbms_lob.close(vr_des_xml_quebra);
      dbms_lob.freetemporary(vr_des_xml_quebra);
  
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro:= vr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro ao imprimir relatório crrl071_999. '||sqlerrm;
    END;
  
    --Geração do relatório por cpf
    PROCEDURE pc_imprime_crrl071_cpf (pr_cdprogra IN  VARCHAR2
                                     ,pr_des_erro OUT VARCHAR2) IS
      --Variavel para arquivo saida
      vr_rel_nrmodulo VARCHAR2(100);
      vr_setlinha     VARCHAR2(4000);
      vr_vlrtotge     NUMBER:= 0;
      --Variavel de Exceção
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar variavel de erro
      pr_des_erro:= NULL;
      -- Busca do diretório base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      --Determinar o nome do arquivo que será gerado
      vr_nom_arquivo := 'crrl071'||rw_crapcop.dsdircop||'_CPF.lst';
  
      --Selecionar informacoes dos programas
      OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                      ,pr_cdprogra => pr_cdprogra);
      --Posicionar no proximo registro
      FETCH cr_crapprg INTO rw_crapprg;
      --Fechar Cursor
      CLOSE cr_crapprg;
  
      --Popular vetor vr_vet_cdrelato com os codigos dos relatorios
      vr_vet_cdrelato(1):= rw_crapprg.cdrelato##1;
      vr_vet_cdrelato(2):= rw_crapprg.cdrelato##2;
      vr_vet_cdrelato(3):= rw_crapprg.cdrelato##3;
      vr_vet_cdrelato(4):= rw_crapprg.cdrelato##4;
      vr_vet_cdrelato(5):= rw_crapprg.cdrelato##5;
  
      --Atribuir valores para os nomes e destinos dos relatorios
      FOR vr_ind_relato IN 1..5 LOOP
        vr_vet_nmdestin(vr_ind_relato):= NULL;
        --Selecionar informacoes dos relatorios
        FOR rw_craprel IN cr_craprel (pr_cdcooper => pr_cdcooper
                                     ,pr_cdrelato => vr_vet_cdrelato(vr_ind_relato)) LOOP
          --Atualizar vetor com o nome do destino em Maiúsculo
          vr_vet_nmdestin(vr_ind_relato):= Upper(rw_craprel.nmdestin);
          --Atualizar vetor com o nome do relatorio em Maiusculo
          vr_vet_nmrelato(vr_ind_relato):= Upper(rw_craprel.nmrelato);
          vr_rel_nrmodulo:= Upper(rw_craprel.nrmodulo);
        END LOOP;
      END LOOP;
  
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  
      --Inicializar variavel texto do clob
      vr_texto:= NULL;
      --Imprimir cabecalho do arquivo
      vr_setlinha:= 'COOP'||' '||rpad('CONTA/DV',10,' ')||' '||rpad('NOME',50,' ')||' '||rpad('CPF/CNPJ',18,' ')||' '||
                    rpad('DPV.UTILIZADO',17,' ')||' '||rpad('EMPRESTIMOS',17,' ')||' '||rpad('DESC.CHEQUES',17,' ')||' '||
                    rpad('DESC.TITULOS',17,' ')||' '||rpad('TOTAL',17,' ')||' '||'RISCO'||' '||rpad('Nr.GE',8,' ')||' '||
                    rpad('Total GE',14,' ')||Chr(13);
      --Escrever informacoes no arquivo
      pc_escreve_xml(vr_setlinha,FALSE);
      --Imprimir linha do cabecalho
      vr_setlinha:= LPad('-',4,'-')||' '||lpad('-',10,'-')||' '||LPad('-',50,'-')||' '||LPad('-',18,'-')||' '||
                    LPad('-',17,'-')||' '||LPad('-',17,'-')||' '||LPad('-',17,'-')||' '||
                    LPad('-',17,'-')||' '||LPad('-',17,'-')||' '||LPad('-',5,'-')||' '||LPad('-',8,'-')||' '||
                    LPad('-',14,'-')||Chr(13);
      --Escrever informacoes no arquivo
      pc_escreve_xml(vr_setlinha,FALSE);
  
      --Acessar primeiro registro da tabela de memoria de detalhe
      vr_index_cpf:= vr_tab_cpf.FIRST;
      WHILE vr_index_cpf IS NOT NULL LOOP
  
        --Se grupo diferente de zero
        IF vr_tab_cpf(vr_index_cpf).nrgrpeco <> 0 THEN
          --total recebe valor divida
          --vr_vlrtotge:= vr_tab_cpf(vr_index_cpf).vldivtot;
          --Montar linha para gravar no arquivo
          vr_setlinha:= To_Char(vr_tab_cpf(vr_index_cpf).cdcooper,'fm0009')||' '||
                      lpad(GENE0002.fn_mask_conta(vr_tab_cpf(vr_index_cpf).nrdconta),10,' ')||' '||
                      RPad(vr_tab_cpf(vr_index_cpf).nmprimtl,50,' ')||' '||
                      LPad(GENE0002.fn_mask_cpf_cnpj(vr_tab_cpf(vr_index_cpf).nrcpfcgc,vr_tab_cpf(vr_index_cpf).inpessoa),18,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivsld,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivepr,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldeschq,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldestit,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivtot,'fm999g999g999g990d00'),17,' ')||' '||
                      NVL(lpad(vr_tab_cpf(vr_index_cpf).nivrisco,5,' '),LPad(' ',5,' '))||' '||
                      NVL(lpad(vr_tab_cpf(vr_index_cpf).nrgrpeco,8,' '),LPad(' ',8,' '))||' '||
                      lpad(to_char(vr_tab_cpf(vr_index_cpf).vldivtot,'fm999g999g999g990d00'),14,' ')||' '||Chr(13);
          --Zerar valor total
          --vr_vlrtotge:= 0;
        ELSE 
          --Montar linha para gravar no arquivo
          vr_setlinha:= To_Char(vr_tab_cpf(vr_index_cpf).cdcooper,'fm0009')||' '||
                      lpad(GENE0002.fn_mask_conta(vr_tab_cpf(vr_index_cpf).nrdconta),10,' ')||' '||
                      RPad(vr_tab_cpf(vr_index_cpf).nmprimtl,50,' ')||' '||
                      LPad(GENE0002.fn_mask_cpf_cnpj(vr_tab_cpf(vr_index_cpf).nrcpfcgc,vr_tab_cpf(vr_index_cpf).inpessoa),18,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivsld,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivepr,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldeschq,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldestit,'fm999g999g999g990d00'),17,' ')||' '||
                      LPad(To_Char(vr_tab_cpf(vr_index_cpf).vldivtot,'fm999g999g999g990d00'),17,' ')||' '||
                      Nvl(lpad(vr_tab_cpf(vr_index_cpf).nivrisco,5,' '),LPad(' ',5,' '))||' '||
                      Nvl(lpad(vr_tab_cpf(vr_index_cpf).nrgrpeco,8,' '),LPad(' ',8,' '))||' '||
                      lpad(to_char(0,'fm999g999g999g990d00'),14,' ')||' '||Chr(13);
        END IF; 
        --Escrever informacoes no arquivo
        pc_escreve_xml(vr_setlinha,FALSE);
        --Acumular valor total
        vr_vlrtotge:= nvl(vr_vlrtotge,0) + nvl(vr_tab_cpf(vr_index_cpf).vldivtot,0);
        --Se existir proximo registro
        IF vr_tab_cpf.NEXT(vr_index_cpf) IS NOT NULL THEN
          --Se for o ultimo registro do grupo
          IF vr_tab_cpf(vr_index_cpf).nrgrpeco <> vr_tab_cpf(vr_tab_cpf.NEXT(vr_index_cpf)).nrgrpeco THEN
            --Se a conta for diferente do grupo
            IF vr_tab_cpf(vr_index_cpf).nrgrpeco <> vr_tab_cpf(vr_index_cpf).nrdconta THEN
              --Montar linha para gravar no arquivo
              vr_setlinha:= lpad(' ',4,' ')||' '||
                            lpad(' ',10,' ')||' '||
                            LPad(' ',50,' ')||' '||
                            LPad(' ',18,' ')||' '||
                            LPad(' ',17,' ')||' '||
                            LPad(' ',17,' ')||' '||
                            LPad(' ',17,' ')||' '||
                            LPad(' ',17,' ')||' '||
                            LPad(' ',17,' ')||' '||
                            lpad(' ',5,' ')||' '||
                            lpad(vr_tab_cpf(vr_index_cpf).nrgrpeco,8,' ')||' '||
                            lpad(to_char(vr_vlrtotge,'fm999g999g999g990d00'),14,' ')||' '||Chr(13);
              --Escrever informacoes no arquivo
              pc_escreve_xml(vr_setlinha,FALSE);
            END IF;
            --Zerar total
            vr_vlrtotge:= 0;
          END IF;
        END IF;
        --Encontrar o proximo registro da tabela de memoria
        vr_index_cpf:= vr_tab_cpf.NEXT(vr_index_cpf);
      END LOOP;
  
      --Escrever informacoes no arquivo
      pc_escreve_xml(' ',TRUE);
  
      --Solicitar geracao do arquivo
      GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper             --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                         ,pr_dsxml     => vr_des_xml           --> Arquivo XML de dados
                                         ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo                 --> Path/Nome do arquivo PDF gerado
                                         ,pr_cdrelato  => 071                  --> Código fixo para o relatório
                                         ,pr_flg_impri => 'N'                  --> Chamar a impressão (Imprim.p)
                                         ,pr_flg_gerar => 'N'                  --> Gerar o arquivo na hora
                                         ,pr_dspathcop => NULL                 --> Lista sep. por ';' de diretórios a copiar o arquivo
                                         ,pr_dsmailcop => NULL                 --> Lista sep. por ';' de emails para envio do arquivo
                                         ,pr_dsassmail => NULL                 --> Assunto do e-mail que enviará o arquivo
                                         ,pr_dscormail => NULL                 --> HTML corpo do email que enviará o arquivo
                                         ,pr_des_erro  => vr_des_erro);        --> Retorno de Erro
      --Se ocorreu erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
  
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro:= vr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro:= 'Erro ao imprimir relatório crrl071 por cpf. '||sqlerrm;
    END;
  
  ---------------------------------------
  -- Inicio Bloco Principal pc_crps084
  ---------------------------------------
  BEGIN
 
    --Atribuir o nome do programa que está executando
    vr_cdprogra:= 'CRPS084';
 
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS084'
                              ,pr_action => NULL);
 
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      -- Montar mensagem de critica
      vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
 
    -- Verifica se a cooperativa esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      --Atribuir a data do movimento
      vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      --Atribuir a proxima data do movimento
      vr_dtmvtopr:= rw_crapdat.dtmvtopr;
      --Atribuir o ultimo dia do mes 
      vr_dtultdia := rw_crapdat.dtultdia;
    END IF; 
 
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);
 
    --Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      --Sair do programa
      RAISE vr_exc_saida;
    END IF;
 
    --Zerar tabelas de memoria auxiliar
    pc_limpa_tabela;
 
    --Selecionar valor de arrasto da tabela generica
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'RISCOBACEN'
                                            ,pr_tpregist => 0);
    --Atribuir valor do arrasto
    vr_vlr_arrasto:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
 
    --Carregar tabela de memoria de emprestimos
    FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapepr(rw_crapepr.nrdconta):= rw_crapepr.vlsdeved;
    END LOOP;
 
    --Carregar tabela de memoria de emprestimos bndes
    FOR rw_crapebn IN cr_crapebn (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapebn(rw_crapebn.nrdconta):= rw_crapebn.vlsdeved;
    END LOOP;
 
    --Carregar tabela de memoria de bordero de descontos
    FOR rw_craptdb IN cr_craptdb_conta (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtotl => vr_dtmvtolt) LOOP
      --Popular tabela de memoria
      vr_tab_craptdb(rw_craptdb.nrdconta):= 0;
    END LOOP;
 
    --Carregar tabela de memoria de contas com bordero
    FOR rw_crapcdb IN cr_crapcdb_carga (pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => vr_dtmvtolt
                                       ,pr_dtmvtopr => vr_dtmvtopr) LOOP
      vr_tab_crapcdb(rw_crapcdb.nrdconta):= 0;                                 
    END LOOP;                                   
         
    --Carregar tabela de memoria de nivel de risco
    FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                 ,pr_nmsistem => 'CRED'
                                 ,pr_tptabela => 'GENERI'
                                 ,pr_cdempres => 0
                                 ,pr_cdacesso => 'PROVISAOCL') LOOP
      --Atribuir descricao do risco para a tabela de memoria
      vr_tab_dsdrisco(rw_craptab.contador):= rw_craptab.dsdrisco;
    END LOOP;
 
    --Carregar tabela de memoria de associados
    FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapass(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
      vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
      vr_tab_crapass(rw_crapass.nrdconta).nrmatric:= rw_crapass.nrmatric;
      vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
      vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc:= rw_crapass.nrcpfcgc;
      vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
      vr_tab_crapass(rw_crapass.nrdconta).dsnivris:= rw_crapass.dsnivris;
    END LOOP;
 
    --Carregar tabela de memoria de emprestimos bndes
    FOR rw_crapgrp IN cr_crapgrp (pr_cdcooper => pr_cdcooper) LOOP
      --Montar Indice para acesso tabela memoria
      vr_index_crapgrp:= lpad(rw_crapgrp.nrctasoc,10,'0')||
                         lpad(rw_crapgrp.nrcpfcgc,25,'0');
      vr_tab_crapgrp(vr_index_crapgrp):= rw_crapgrp.nrdgrupo;
    END LOOP;
 
    --Carregar tabela de memoria de juros de titulos
    FOR rw_crapljt IN cr_crapljt (pr_cdcooper => pr_cdcooper
                                 ,pr_dtrefere => Last_Day(vr_dtmvtolt)) LOOP
 
      --Montar indice para acessar tabela
      vr_index_crapljt:= LPad(rw_crapljt.nrdconta,10,'0')||
                         LPad(rw_crapljt.nrborder,10,'0')||
                         LPad(rw_crapljt.cdbandoc,10,'0')||
                         LPad(rw_crapljt.nrdctabb,10,'0')||
                         LPad(rw_crapljt.nrcnvcob,10,'0')||
                         LPad(rw_crapljt.nrdocmto,10,'0');
       --Carregar tabela de memoria
       vr_tab_crapljt(vr_index_crapljt).vldjuros:= rw_crapljt.vldjuros;
       vr_tab_crapljt(vr_index_crapljt).vlrestit:= rw_crapljt.vlrestit;
    END LOOP;
 
    --Carregar tabela de memoria de juros de titulos
    FOR rw_crapljd IN cr_crapljd (pr_cdcooper => pr_cdcooper
                                 ,pr_dtrefere => Last_Day(vr_dtmvtolt)) LOOP
 
      --Montar indice para acessar tabela
      vr_index_crapljd:= LPad(rw_crapljd.nrdconta,10,'0')||
                         LPad(rw_crapljd.nrborder,10,'0')||
                         LPad(rw_crapljd.cdcmpchq,10,'0')||
                         LPad(rw_crapljd.cdbanchq,10,'0')||
                         LPad(rw_crapljd.cdagechq,10,'0')||
                         LPad(rw_crapljd.nrctachq,25,'0')||
                         LPad(rw_crapljd.nrcheque,10,'0');
       --Carregar tabela de memoria
       vr_tab_crapljd(vr_index_crapljd):= rw_crapljd.vldjuros;
    END LOOP;
 
    --Carregar tabela memoria riscos          
    OPEN cr_crapris_teste (pr_cdcooper => pr_cdcooper
                          ,pr_vldivida => vr_vlr_arrasto
                          ,pr_dtultdia => vr_dtultdia);
    --Carregar Bulk Collect                      
    FETCH cr_crapris_teste BULK COLLECT INTO vr_tab_crapris_teste;
    --Fechar Cursor
    CLOSE cr_crapris_teste;
        
    --Montar o indice por conta a partir do bulk collect
    FOR idx IN vr_tab_crapris_teste.FIRST..vr_tab_crapris_teste.LAST LOOP
      vr_tab_crapris(vr_tab_crapris_teste(idx).nrdconta):= vr_tab_crapris_teste(idx).innivris;
    END LOOP;  
        
    --Atribuir false para existe registro
    vr_regexist:= FALSE;
 
    --Pesquisar todas as solicitacoes de processo
    FOR rw_crapsol IN cr_crapsol (pr_cdcooper => pr_cdcooper
                                 ,pr_dtrefere => vr_dtmvtolt
                                 ,pr_nrsolici => 44
                                 ,pr_insitsol => 1) LOOP
 
      --Limpar tabelas de memória para a solicitacao
      vr_tab_cpf.DELETE;
      vr_tab_relato.DELETE;
      vr_tab_dev_conta.DELETE;
      vr_tab_devedores.DELETE;
 
      --Atribuir verdadeiro para existe registro
      vr_regexist:= TRUE;
 
      --Pesquisar todos os saldos dos associados
      FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
 
        --Zerar valor saldo divida
        vr_set_vldivsld:= 0;
        --Zerar valor divida emprestimo
        vr_set_vldivepr:= 0;
        --Zerar variaveis desconto cheque
        vr_set_vldeschq:= 0;
        --Zerar valor desconto titulos
        vr_set_vldestit:= 0;
        --Zerar valor total divida
        vr_set_vldivtot:= 0;
 
        --Verificar informacoes do associado
        IF NOT vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) THEN
          vr_cdcritic:= 251;
          --Sair do programa
          RAISE vr_exc_saida;
        ELSE
          --Atribuir o cpf/cnpj encontrado
          vr_nrcpfcgc:= vr_tab_crapass(rw_crapsld.nrdconta).nrcpfcgc;
        END IF;
 
        --Bloco necessário para controle fluxo
        BEGIN
          --Valor divida saldo recebe valor disponivel + saldo cheque salario
          vr_set_vldivsld:= Nvl(rw_crapsld.vlsddisp,0) + Nvl(rw_crapsld.vlsdchsl,0);
          --Zerar valor divida emprestimos
          vr_set_vldivepr:= 0;
          --Se o valor da divida for maior igual a zero recebe zero
          IF vr_set_vldivsld >= 0 THEN
            vr_set_vldivsld:= 0;
          ELSE
            --Inverter sinal
            vr_set_vldivsld:= vr_set_vldivsld * -1;
          END IF;
 
          --Selecionar o saldo devedor dos emprestimos
          IF vr_tab_crapepr.EXISTS(rw_crapsld.nrdconta) THEN
            --Acumular valor da divida de emprestimos
            vr_set_vldivepr:= Nvl(vr_set_vldivepr,0) + vr_tab_crapepr(rw_crapsld.nrdconta);
          END IF;
 
          /* BNDES - Emprestimos Ativos e em Prejuizo */
          IF vr_tab_crapebn.EXISTS(rw_crapsld.nrdconta) THEN
            --Acumular valor da divida de emprestimos
            vr_set_vldivepr:= Nvl(vr_set_vldivepr,0) + vr_tab_crapebn(rw_crapsld.nrdconta);
          END IF;
 
          /* saldo de desconto de cheques */
 
          --Zerar valor cheque descontado
          vr_set_vldeschq:= 0;
          --Iniciar data referencia com ultimo dia mes corrente
          vr_dtrefere:= Last_Day(vr_dtmvtolt);
 
          IF vr_tab_crapcdb.EXISTS(rw_crapsld.nrdconta) THEN
            --Encontrar borderos de desconto de cheque
            FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_crapsld.nrdconta
                                         ,pr_dtmvtolt => vr_dtmvtolt
                                         ,pr_dtmvtopr => vr_dtmvtopr) LOOP
              --Zerar valor juros cheque
              vr_dec_vljurchq:= 0;
                
              --Montar indice acesso
              vr_index_crapljd:= LPad(rw_crapcdb.nrdconta,10,'0')||
                                 LPad(rw_crapcdb.nrborder,10,'0')||
                                 LPad(rw_crapcdb.cdcmpchq,10,'0')||
                                 LPad(rw_crapcdb.cdbanchq,10,'0')||
                                 LPad(rw_crapcdb.cdagechq,10,'0')||
                                 LPad(rw_crapcdb.nrctachq,25,'0')||
                                 LPad(rw_crapcdb.nrcheque,10,'0');
              --Se existir juros
              IF vr_tab_crapljd.EXISTS(vr_index_crapljd) THEN
                vr_dec_vljurchq:= Nvl(vr_tab_crapljd(vr_index_crapljd),0);
              END IF;
              --Acumular valor descontado cheque
              vr_set_vldeschq:= Nvl(vr_set_vldeschq,0) +
                                Nvl(rw_crapcdb.vlcheque,0) -
                                Nvl(vr_dec_vljurchq,0);
            END LOOP; --rw_crapcdb
          END IF;
          /* saldo de desconto de titulos */
 
          --Zerar valor desconto titulo
          vr_set_vldestit:= 0;
 
          --Verificar as contas que possuem bordero de desconto
          IF vr_tab_craptdb.EXISTS(rw_crapsld.nrdconta) THEN
 
            --Selecionar informacoes dos titulos do bordero descontos
            FOR rw_craptdb IN cr_craptdb (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_crapsld.nrdconta
                                         ,pr_dtmvtotl => vr_dtmvtolt) LOOP
 
              --bloco necessário para controle fluxo
              BEGIN
                --Selecionar informacoes de cobranca
                OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                                ,pr_cdbandoc => rw_craptdb.cdbandoc
                                ,pr_nrdctabb => rw_craptdb.nrdctabb
                                ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                ,pr_nrdconta => rw_craptdb.nrdconta
                                ,pr_nrdocmto => rw_craptdb.nrdocmto);
                --Posicionar no primeiro registro
                FETCH cr_crapcob INTO rw_crapcob;
                --Verificar se existe titulo cobranca crapcob
                IF cr_crapcob%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapcob;
                  --Montar descricao do erro
                  vr_des_erro:= 'Titulo em desconto nao encontrado no crapcob '||
                                '- ROWID(craptdb) = '||rw_craptdb.ROWID;
                  -- Envio centralizado de log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_des_erro );
                  --Pular para proximo registro
                  RAISE vr_exc_pula;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapcob;
 
                --Ignorar registro se o titulo estiver pago
                --e o indicador de pagto for caixa/Internetbank/TAA
                IF (rw_craptdb.insittit = 2  AND (rw_crapcob.indpagto IN (1,3,4))) THEN
                  --Pular para proximo registro
                  RAISE vr_exc_pula;
                END IF;
 
                --Zerar valor dos juros
                vr_dec_vldjuros:= 0;
 
                --Se o titulo estiver liberado
                IF rw_craptdb.insittit = 4  THEN
                  --Encontrar lancamentos de juros de desconto de cheque
                  vr_index_crapljt:= LPad(rw_craptdb.nrdconta,10,'0')||
                                     LPad(rw_craptdb.nrborder,10,'0')||
                                     LPad(rw_craptdb.cdbandoc,10,'0')||
                                     LPad(rw_craptdb.nrdctabb,10,'0')||
                                     LPad(rw_craptdb.nrcnvcob,10,'0')||
                                     LPad(rw_craptdb.nrdocmto,10,'0');
                  --Se existir juros
                  IF vr_tab_crapljt.EXISTS(vr_index_crapljt) THEN
                    vr_dec_vldjuros:= Nvl(vr_dec_vldjuros,0) +
                                      Nvl(vr_tab_crapljt(vr_index_crapljt).vldjuros,0) +
                                      Nvl(vr_tab_crapljt(vr_index_crapljt).vlrestit,0);
                  END IF;
                  --Acumular Valor descontado titulo
                  vr_set_vldestit:= Nvl(vr_set_vldestit,0) +
                                    Nvl(rw_craptdb.vltitulo,0) -
                                    Nvl(vr_dec_vldjuros,0);
                END IF;
              EXCEPTION
                WHEN vr_exc_pula THEN NULL;
              END;
            END LOOP;
          END IF; --vr_tab_craptdb.EXISTS
 
          --Acumular valor total da divida
          vr_set_vldivtot:= Nvl(vr_set_vldivsld,0) +
                            Nvl(vr_set_vldivepr,0) +
                            Nvl(vr_set_vldeschq,0) +
                            Nvl(vr_set_vldestit,0);
 
          --Ignorar registro de valor da divida for menor ou igual a zero
          IF Nvl(vr_set_vldivtot,0) <= 0 THEN
            RAISE vr_exc_pula;
          END IF;
 
          --Inicializar nivel risco com NULL
          vr_set_nivrisco:= NULL;
          --Marcar que nao encontrou
          vr_flg_crapris:= FALSE;
 
          --Se existir risco
          IF vr_tab_crapris.EXISTS(rw_crapsld.nrdconta) THEN
            --Buscar a descricao do risco
            IF vr_tab_dsdrisco.EXISTS(vr_tab_crapris(rw_crapsld.nrdconta)) THEN
              --Atribuir valor no nivel de risco encontrado
              vr_set_nivrisco:= vr_tab_dsdrisco(vr_tab_crapris(rw_crapsld.nrdconta));             
            ELSE
              --Atribuir nulo para nivel risco
              vr_set_nivrisco:= NULL;
            END IF;
          ELSE
            --Selecionar o ultimo risco
            OPEN cr_crapris_last(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_crapsld.nrdconta
                                ,pr_dtultdia => vr_dtultdia);
            --Posicionar no primeiro registro
            FETCH cr_crapris_last INTO rw_crapris_last;
            --Se encontrou
            IF cr_crapris_last%FOUND THEN
              --Verificar se o nivel de risco está cadastrado
              IF vr_tab_dsdrisco.EXISTS(rw_crapris_last.innivris) THEN
                --Atribuir valor no nivel de risco encontrado
                IF rw_crapris_last.innivris = 10 THEN
                  vr_set_nivrisco:= vr_tab_dsdrisco(rw_crapris_last.innivris);
                ELSE
                  vr_set_nivrisco:= vr_tab_dsdrisco(2);
                  
                END IF;             
                
              ELSE
                --Atribuir nulo para nivel risco
                vr_set_nivrisco:= NULL;
              END IF;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapris_last;
          END IF;
          --CLOSE cr_crapris_teste;
 
          --Se o nivel de risco for AA
          IF Trim(vr_set_nivrisco) = 'AA' THEN
            --Atribuir nulo para nivel risco
            vr_set_nivrisco:= NULL;
          END IF;
 
          --Informacoes do Grupo Economico
          vr_nrdgrupo:= 0;
          --Montar indice para grupo
          vr_index_crapgrp:= lpad(rw_crapsld.nrdconta,10,'0')||
                             lpad(vr_tab_crapass(rw_crapsld.nrdconta).nrcpfcgc,25,'0');
          --Se existir o grupo
          IF vr_tab_crapgrp.EXISTS(vr_index_crapgrp) THEN
            --utilizar o grupo encontrado
            vr_nrdgrupo:= vr_tab_crapgrp(vr_index_crapgrp);
          END IF;

          vr_set_nrgrpeco:= vr_nrdgrupo;
 
          --Montar indice para tabela memoria devedores por conta
          vr_index_dev:= LPad(rw_crapsld.nrdconta,25,'0');
          --Criar registro na tabela de memoria de devedores por conta
          vr_tab_dev_conta(vr_index_dev).nrdconta:= rw_crapsld.nrdconta;
          vr_tab_dev_conta(vr_index_dev).inpessoa:= vr_tab_crapass(rw_crapsld.nrdconta).inpessoa;
          vr_tab_dev_conta(vr_index_dev).cdagenci:= vr_tab_crapass(rw_crapsld.nrdconta).cdagenci;
          vr_tab_dev_conta(vr_index_dev).nmprimtl:= vr_tab_crapass(rw_crapsld.nrdconta).nmprimtl;
          vr_tab_dev_conta(vr_index_dev).nrmatric:= vr_tab_crapass(rw_crapsld.nrdconta).nrmatric;
          vr_tab_dev_conta(vr_index_dev).nrcpfcgc:= vr_nrcpfcgc;
          vr_tab_dev_conta(vr_index_dev).vldivsld:= vr_set_vldivsld;
          vr_tab_dev_conta(vr_index_dev).vldivepr:= vr_set_vldivepr;
          vr_tab_dev_conta(vr_index_dev).vldeschq:= vr_set_vldeschq;
          vr_tab_dev_conta(vr_index_dev).vldestit:= vr_set_vldestit;
          vr_tab_dev_conta(vr_index_dev).vldivtot:= vr_set_vldivtot;
          vr_tab_dev_conta(vr_index_dev).nivrisco:= vr_set_nivrisco;
 
          --Montar indice para tabela memoria devedores ordenado por cpf/cnpj
          vr_index_dev:= LPad(vr_nrcpfcgc,25,'0');
          --Armazenar tabela de memoria de devedores
          IF NOT vr_tab_devedores.EXISTS(vr_index_dev) THEN
            --Criar registro na tabela de memoria
            vr_tab_devedores(vr_index_dev).nrdconta:= rw_crapsld.nrdconta;
            vr_tab_devedores(vr_index_dev).inpessoa:= vr_tab_crapass(rw_crapsld.nrdconta).inpessoa;
            vr_tab_devedores(vr_index_dev).cdagenci:= vr_tab_crapass(rw_crapsld.nrdconta).cdagenci;
            vr_tab_devedores(vr_index_dev).nmprimtl:= vr_tab_crapass(rw_crapsld.nrdconta).nmprimtl;
            vr_tab_devedores(vr_index_dev).nrmatric:= vr_tab_crapass(rw_crapsld.nrdconta).nrmatric;
            vr_tab_devedores(vr_index_dev).nrcpfcgc:= vr_nrcpfcgc;
            vr_tab_devedores(vr_index_dev).vldivsld:= vr_set_vldivsld;
            vr_tab_devedores(vr_index_dev).vldivepr:= vr_set_vldivepr;
            vr_tab_devedores(vr_index_dev).vldeschq:= vr_set_vldeschq;
            vr_tab_devedores(vr_index_dev).vldestit:= vr_set_vldestit;
            vr_tab_devedores(vr_index_dev).vldivtot:= vr_set_vldivtot;
            vr_tab_devedores(vr_index_dev).nivrisco:= vr_set_nivrisco;
            vr_tab_devedores(vr_index_dev).nrgrpeco:= vr_set_nrgrpeco;
          ELSE
            --Verificar se o saldo que será somado é maior que o anterior
            CASE rw_crapsol.dsparame
              WHEN '1' THEN 
                vr_saldo_atual:= vr_tab_devedores(vr_index_dev).vldivepr;
                vr_novo_saldo:= vr_set_vldivepr; 
              WHEN '2' THEN 
                vr_saldo_atual:= vr_tab_devedores(vr_index_dev).vldivsld;
                vr_novo_saldo:= vr_set_vldivsld;
              WHEN '3' THEN 
                vr_saldo_atual:= vr_tab_devedores(vr_index_dev).vldeschq;
                vr_novo_saldo:= vr_set_vldeschq; 
              WHEN '4' THEN 
                vr_saldo_atual:= vr_tab_devedores(vr_index_dev).vldivtot;
                vr_novo_saldo:= vr_set_vldivtot; 
              WHEN '5' THEN 
                vr_saldo_atual:= vr_tab_devedores(vr_index_dev).vldestit;
                vr_novo_saldo:= vr_set_vldestit; 
            END CASE;
            --Se o valor anterior na tabela for menor que o atual tem que trocar a 
            --conta da tabela 
            IF vr_saldo_atual < vr_novo_saldo THEN
              --Atualizar a conta 
              vr_tab_devedores(vr_index_dev).nrdconta:= rw_crapsld.nrdconta;
              vr_tab_devedores(vr_index_dev).inpessoa:= vr_tab_crapass(rw_crapsld.nrdconta).inpessoa;
              vr_tab_devedores(vr_index_dev).cdagenci:= vr_tab_crapass(rw_crapsld.nrdconta).cdagenci;
              vr_tab_devedores(vr_index_dev).nmprimtl:= vr_tab_crapass(rw_crapsld.nrdconta).nmprimtl;
              vr_tab_devedores(vr_index_dev).nrmatric:= vr_tab_crapass(rw_crapsld.nrdconta).nrmatric;
              vr_tab_devedores(vr_index_dev).nrcpfcgc:= vr_nrcpfcgc;
              vr_tab_devedores(vr_index_dev).nivrisco:= vr_set_nivrisco;
              vr_tab_devedores(vr_index_dev).nrgrpeco:= vr_set_nrgrpeco;
            END IF;
            --Atualizar tabela de memoria
            vr_tab_devedores(vr_index_dev).vldivsld:= vr_tab_devedores(vr_index_dev).vldivsld + vr_set_vldivsld;
            vr_tab_devedores(vr_index_dev).vldivepr:= vr_tab_devedores(vr_index_dev).vldivepr + vr_set_vldivepr;
            vr_tab_devedores(vr_index_dev).vldeschq:= vr_tab_devedores(vr_index_dev).vldeschq + vr_set_vldeschq;
            vr_tab_devedores(vr_index_dev).vldestit:= vr_tab_devedores(vr_index_dev).vldestit + vr_set_vldestit;
            vr_tab_devedores(vr_index_dev).vldivtot:= vr_tab_devedores(vr_index_dev).vldivtot + vr_set_vldivtot;
          END IF;
        EXCEPTION
          WHEN vr_exc_pula THEN NULL;
        END;
      END LOOP; --rw_crapsld
 
      --Determinar o nome do relatorio
      CASE rw_crapsol.dsparame
        WHEN '1' THEN
          vr_rel_dsrelato:= 'EMPRESTIMOS';
        WHEN '2' THEN
          vr_rel_dsrelato:= 'DEPOSITOS A VISTA';
        WHEN '3' THEN
          vr_rel_dsrelato:= 'DESCONTO DE CHEQUES';
        WHEN '4' THEN
          vr_rel_dsrelato:= 'EMPRESTIMOS E DEPOSITOS A VISTA';
        WHEN '5' THEN
          vr_rel_dsrelato:= 'DESCONTO DE TITULOS';
      END CASE;
 
      --Percorrer a tabela de memoria de devedores por conta e aplicar
      --a ordenação na vr_tab_relato conforme parametro
      vr_index_dev:= vr_tab_dev_conta.FIRST;
      WHILE vr_index_dev IS NOT NULL LOOP
        --Determinar o indice para o relatorio final: está * 100 para retirar decimais
        CASE rw_crapsol.dsparame
          WHEN '1' THEN vr_index:= 99999999999999999999 - (vr_tab_dev_conta(vr_index_dev).vldivepr * 100);
          WHEN '2' THEN vr_index:= 99999999999999999999 - (vr_tab_dev_conta(vr_index_dev).vldivsld * 100);
          WHEN '3' THEN vr_index:= 99999999999999999999 - (vr_tab_dev_conta(vr_index_dev).vldeschq * 100);
          WHEN '4' THEN vr_index:= 99999999999999999999 - (vr_tab_dev_conta(vr_index_dev).vldivtot * 100);
          WHEN '5' THEN vr_index:= 99999999999999999999 - (vr_tab_dev_conta(vr_index_dev).vldestit * 100);
        END CASE;
        --Montar o indice usando o parametro concatenado com o nivel de risco,
        --nome do associado e conta do associado
        vr_index_relato:= vr_index || --20
                          RPad(Nvl(vr_tab_dev_conta(vr_index_dev).nivrisco,'Z'),5,'#')|| --5
                          SubStr(Rpad(vr_tab_dev_conta(vr_index_dev).nmprimtl,100,' '),1,100)||
                          LPad(vr_tab_dev_conta(vr_index_dev).nrdconta,10,'0');
        --Inserir valores na tabela de memoria para relatorio crrl071_99
        vr_tab_relato(vr_index_relato).cdagenci:= vr_tab_dev_conta(vr_index_dev).cdagenci;
        vr_tab_relato(vr_index_relato).nrdconta:= vr_tab_dev_conta(vr_index_dev).nrdconta;
        vr_tab_relato(vr_index_relato).inpessoa:= vr_tab_dev_conta(vr_index_dev).inpessoa;
        vr_tab_relato(vr_index_relato).nrcpfcgc:= vr_tab_dev_conta(vr_index_dev).nrcpfcgc;
        vr_tab_relato(vr_index_relato).nmprimtl:= vr_tab_dev_conta(vr_index_dev).nmprimtl;
        vr_tab_relato(vr_index_relato).nrmatric:= vr_tab_dev_conta(vr_index_dev).nrmatric;
        vr_tab_relato(vr_index_relato).vldivsld:= vr_tab_dev_conta(vr_index_dev).vldivsld;
        vr_tab_relato(vr_index_relato).vldivepr:= vr_tab_dev_conta(vr_index_dev).vldivepr;
        vr_tab_relato(vr_index_relato).vldeschq:= vr_tab_dev_conta(vr_index_dev).vldeschq;
        vr_tab_relato(vr_index_relato).vldestit:= vr_tab_dev_conta(vr_index_dev).vldestit;
        vr_tab_relato(vr_index_relato).vldivtot:= vr_tab_dev_conta(vr_index_dev).vldivtot;
        vr_tab_relato(vr_index_relato).nivrisco:= vr_tab_dev_conta(vr_index_dev).nivrisco;
        --Buscar o proximo indice
        vr_index_dev:= vr_tab_dev_conta.NEXT(vr_index_dev);
      END LOOP;
 
      --Percorrer a tabela de memoria de devedores para ordenar pelo numero grupo decrescente
      --Essa tabela de memória é usada no relatório por cpf
      vr_index_dev:= vr_tab_devedores.FIRST;
      WHILE vr_index_dev IS NOT NULL LOOP
        --Determinar o indice para a tabela de memoria por cpf pelo grupo decrescente
        vr_index:= 99999999999999999999 - Nvl(vr_tab_devedores(vr_index_dev).nrgrpeco,0);
        --Montar o indice definitivo
        vr_index_cpf:= vr_index|| --20
                       vr_index_dev|| --25
                       RPad(Nvl(vr_tab_devedores(vr_index_dev).nivrisco,'Z'),5,'#')||
                       SubStr(vr_tab_devedores(vr_index_dev).nmprimtl,1,1);
        --Inserir informacoes na tabela de memoria de cpf
        vr_tab_cpf(vr_index_cpf).cdcooper:= pr_cdcooper;
        vr_tab_cpf(vr_index_cpf).nrdconta:= vr_tab_devedores(vr_index_dev).nrdconta;
        vr_tab_cpf(vr_index_cpf).nrcpfcgc:= vr_tab_crapass(vr_tab_devedores(vr_index_dev).nrdconta).nrcpfcgc;
        vr_tab_cpf(vr_index_cpf).inpessoa:= vr_tab_crapass(vr_tab_devedores(vr_index_dev).nrdconta).inpessoa;
        vr_tab_cpf(vr_index_cpf).nmprimtl:= vr_tab_devedores(vr_index_dev).nmprimtl;
        vr_tab_cpf(vr_index_cpf).vldivsld:= vr_tab_devedores(vr_index_dev).vldivsld;
        vr_tab_cpf(vr_index_cpf).vldivepr:= vr_tab_devedores(vr_index_dev).vldivepr;
        vr_tab_cpf(vr_index_cpf).vldeschq:= vr_tab_devedores(vr_index_dev).vldeschq;
        vr_tab_cpf(vr_index_cpf).vldestit:= vr_tab_devedores(vr_index_dev).vldestit;
        vr_tab_cpf(vr_index_cpf).vldivtot:= vr_tab_devedores(vr_index_dev).vldivtot;
        vr_tab_cpf(vr_index_cpf).nivrisco:= vr_tab_devedores(vr_index_dev).nivrisco;
        vr_tab_cpf(vr_index_cpf).nrgrpeco:= vr_tab_devedores(vr_index_dev).nrgrpeco;
        vr_tab_cpf(vr_index_cpf).vlrtotge:= vr_tab_devedores(vr_index_dev).vlrtotge;
        --Buscar o proximo indice
        vr_index_dev:= vr_tab_devedores.NEXT(vr_index_dev);
      END LOOP;
 
      --Executar procedure geração relatorio 100 maiores depositantes
      pc_imprime_crrl071 (pr_nmarqimp => 'crrl071_'||To_Char(rw_crapsol.nrseqsol,'fm09')
                         ,pr_dsrelato => vr_rel_dsrelato
                         ,pr_des_erro => vr_des_erro);
      --Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;
 
      --Executar procedure geração relatorio crrl071_99
      pc_imprime_crrl071_99 (pr_cdprogra => vr_cdprogra
                            ,pr_dsrelato => vr_rel_dsrelato
                            ,pr_des_erro => vr_des_erro);
      --Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;
 
      --Gerar relatorio devedores por CPF
      pc_imprime_crrl071_cpf (pr_cdprogra => vr_cdprogra
                             ,pr_des_erro => vr_des_erro);
      --Se retornou erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;
 
      --Atualizar situacao da solicitacao
      BEGIN
        UPDATE crapsol SET crapsol.insitsol = 2
        WHERE crapsol.ROWID = rw_crapsol.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_des_erro:= 'Erro ao atualizar tabela crapsol. '||SQLERRM;
      END;
    END LOOP; --rw_crapsol
 
    --Se nao processou nenhum registro
    IF NOT vr_regexist THEN
      vr_cdcritic:= 157;
      --Descricao do erro recebe mensagam da critica
      vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_des_erro || ' - SOL044' );
    END IF;
 
    --Atribuir verdadeiro para flag retorno fim solicitacao
    pr_infimsol:= 1;
 
    --Zerar tabelas de memoria auxiliar
    pc_limpa_tabela;
 
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    --Salvar informacoes no banco de dados
    COMMIT;
 
  EXCEPTION
   WHEN vr_exc_fimprg THEN
     -- Se foi retornado apenas código
     IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
       -- Buscar a descrição
       vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
     END IF;
     -- Envio centralizado de log de erro
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 -- Erro tratato
                               ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                || vr_cdprogra || ' --> '
                                                || vr_des_erro );
     -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
     btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);
      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;
     -- Efetuar commit
     COMMIT;
   WHEN vr_exc_saida THEN
     -- Se foi retornado apenas código
     IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
       -- Buscar a descrição
       vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
     END IF;
     -- Devolvemos código e critica encontradas
     pr_cdcritic := NVL(vr_cdcritic,0);
     pr_dscritic := vr_des_erro;
 
     --Zerar tabela de memoria auxiliar
     pc_limpa_tabela;
 
     -- Efetuar rollback
     ROLLBACK;
   WHEN OTHERS THEN
     -- Efetuar retorno do erro não tratado
     pr_cdcritic := 0;
     pr_dscritic := sqlerrm;
 
      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;
 
     -- Efetuar rollback
     ROLLBACK;
  END;
END pc_crps084;
/

