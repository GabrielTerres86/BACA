CREATE OR REPLACE PACKAGE CECRED.limp0001 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMP0001
  --  Sistema  : Rotinas para limpeza de microfilmagens
  --  Sigla    : LIMP
  --  Autor    : Alisson C. Berrido  - AMcom
  --  Data     : Fevereiro/2014.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Limpeza de dados das microfilmagens
  ---------------------------------------------------------------------------------------------------------------


  /* Rotina responsavel por calcular a quantidade de anos e meses entre as datas */
  PROCEDURE pc_limpeza_microfilmagem (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                     ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                     ,pr_cdprogra IN VARCHAR2                --> Nome Programa da Execucao crps019/crps076
                                     ,pr_flgtrans IN BOOLEAN                 --> Transmite ou nao o arquivo
                                     ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                     ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                     ,pr_dscritic OUT VARCHAR2);             --> Descricao da Critica

  /* Procedure que processa as contas para microfilmagem */
  PROCEDURE pc_crps046_i (pr_tipo         IN PLS_INTEGER                  --> Identificador do Cabecalho
                         ,pr_tab_clob     IN OUT NOCOPY CADA0001.typ_tab_linha --> Clob de dados
                         ,pr_nrdordem     IN OUT INTEGER                  --> Numero da ordem
                         ,pr_indsalto     IN OUT VARCHAR2                 --> Indicador de Salto
                         ,pr_tab_cabmex   IN OUT NOCOPY CADA0001.typ_tab_char --> Tabela de Memoria com Cabecalhos
                         ,pr_reg_lindetal IN VARCHAR2                     --> Linha Detalhe
                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE       --> Codigo da Critica
                         ,pr_dscritic     OUT VARCHAR2);                  --> Descricao da Critica

  /* Rotina responsavel em quebrar uma string em quatro linhas, e justifica-las. */
  PROCEDURE pc_quebra_str(pr_dsstring IN  VARCHAR2          --> String que sera quebrada
                         ,pr_qtcolun1 IN  PLS_INTEGER       --> Quantidade de colunas da primeira linha
                         ,pr_qtcolun2 IN  PLS_INTEGER       --> Quantidade de colunas da segunda linha
                         ,pr_qtcolun3 IN  PLS_INTEGER       --> Quantidade de colunas da terceira linha
                         ,pr_qtcolun4 IN  PLS_INTEGER       --> Quantidade de colunas da quarta linha
                         ,pr_dslinha1 OUT VARCHAR2          --> Primeira linha centralizada
                         ,pr_dslinha2 OUT VARCHAR2          --> Segunda linha centralizada
                         ,pr_dslinha3 OUT VARCHAR2          --> Terceira linha centralizada
                         ,pr_dslinha4 OUT VARCHAR2);        --> Quarta linha centralizada




  PROCEDURE pc_crps157_i (pr_tipo         IN PLS_INTEGER                  --> Identificador do Cabecalho
                         ,pr_tab_clob     IN OUT NOCOPY CADA0001.typ_tab_linha --> Clob de dados
                         ,pr_nrdordem     IN OUT INTEGER                  --> Numero da ordem
                         ,pr_indsalto     IN OUT VARCHAR2                 --> Indicador de Salto
                         ,pr_tab_cabmex   IN OUT NOCOPY CADA0001.typ_tab_char --> Tabela de Memoria com Cabecalhos
                         ,pr_reg_lindetal IN VARCHAR2                     --> Linha Detalhe
                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE       --> Codigo da Critica
                         ,pr_dscritic     OUT VARCHAR2);                --> Descricao da Critica

END LIMP0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.limp0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMP0001
  --  Sistema  : Rotinas para limpeza de microfilmagens
  --  Sigla    : LIMP
  --  Autor    : Alisson C. Berrido  - AMcom
  --  Data     : Fevereiro/2014.                   Ultima atualizacao: 02/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Limpeza de dados das microfilmagens	
  
  --            02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --                         crapass, crapttl, crapjur 
  --           		  				 (Adriano - P339).
  --
  --            05/12/2018 - SCTASK38225 (Yuri - Mouts)
  --                         Substituido o m�todo XSLPROCESSOR pela chamada da GENE0002.
                           
  ---------------------------------------------------------------------------------------------------------------

  /* Procedure que processa as contas para microfilmagem */
  PROCEDURE pc_crps019_i (pr_cdcooper     IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                         ,pr_cdprogra     IN crapprg.cdprogra%TYPE       --> Nome Programa
                         ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE       --> Data Movimento
                         ,pr_vr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data Inicio Lancamento
                         ,pr_vr_dtlimite  IN crapdat.dtmvtolt%TYPE       --> Data Limite
                         ,pr_nrdconta     IN crapass.nrdconta%TYPE       --> Conta Associado
                         ,pr_nmprimtl     IN crapass.nmprimtl%TYPE       --> Nome Associado
                         ,pr_inpessoa     IN crapass.inpessoa%TYPE       --> Indicador Pessoa Fisica/Juridica
                         ,pr_tab_craphis  IN CADA0001.typ_tab_craphis    --> Tabela Historicos
                         ,pr_tab_clob     IN OUT NOCOPY CADA0001.typ_tab_linha --> Clob de dados
                         ,pr_flgfirst     IN OUT BOOLEAN                 --> Indicador primeiro registro
                         ,pr_regexist     IN OUT BOOLEAN                 --> Existe Registro
                         ,pr_contlinh     IN OUT INTEGER                 --> Contador Linha
                         ,pr_nmmesref     IN VARCHAR2                    --> Nome mes referencia
                         ,pr_lshistor     IN VARCHAR2                    --> Lista Historico
                         ,pr_tab_cabmex   IN OUT NOCOPY CADA0001.typ_tab_char --> Tabela de Memoria com Cabecalhos
                         ,pr_tab_craplcm  IN OUT NOCOPY CADA0001.typ_tab_grpconta --> Tabela de Memoria com Lancamentos
                         ,pr_craptax      IN BOOLEAN                     --> Indicador possui taxa
                         ,pr_dtmvttax     IN craptax.dtmvtolt%TYPE       --> Data da taxa
                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE      --> Codigo da Critica
                         ,pr_dscritic     OUT VARCHAR2) IS               --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps019_i                             Antigo: Includes/crps019.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima atualizacao: 14/01/2015

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p ou crps076.p.
   Objetivo  : Geracao dos arquivos de microfilmagem.

   Alteracoes: 30/09/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 47 (Deborah).

               06/10/94 - Alterado para mostrar no codigo de pesquisa do histo-
                          rico 47 a descricao da alinea de devolucao (Odair).

               25/10/94 - Alterado para mostrar no codigo de pesquisa do histo-
                          rico 78 a descricao da alinea de devolucao (Odair).

               03/11/94 - Alterado para comparar tambem o codigo de historico
                          46 (Odair).

               24/01/97 - Tratamento historico 191. (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/09/98 - Alterado para NAO tratar o historico 289 (Edson).

               24/06/99 - Tratar historico 338 (Odair).

               23/03/2000 - Tratar arquivos que nao tem lancamentos para funcao
                            transmic (Odair)

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               04/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               16/01/2001 - Mostrar no extrato de conta corrente as taxas de
                            juros utilizadas  Limite de Credito.
                            (Eduardo).

               27/06/2001 - Gravar dados da 3030 (Margarete).

               13/08/2001 - Acerto no Limite de Credito (Ze Eduardo).

               29/08/2001 - Identificar depositos da cooperativa (Margarete).

               08/10/2001 - Aumentar o campo nrdocmto para 11 histor. 040
                            (Ze Eduardo).

               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               07/01/2003 - Mudanca na procura do craptax (Deborah)

               13/03/2003 - Alterado para tratar novos campos craplim (Edson).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).

               21/05/2003 - Alterado para tratar os historicos 104, 302 e 303
                            (Edson).

               06/08/2003 - Tratamento Historico 156 (Julio).

               26/09/2003 - ERRO: gravado compe duas vezes e nao gravado
                            agencia do crapchd (Margarete).

               07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                            da cooperativa (Diego).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               27/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

               03/07/2007 - Prever historicos transferencia Internet(Mirtes).

               08/08/2007 - Acerto na taxas - Lim. Cheque (Ze).

               30/10/2008 - Alteracao CDEMPRES (Diego).

               09/09/2009 - Incluir historicos de transferencia de credito de
                            salario (David).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)

               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).

               24/02/2011 - Ajuste do format do nrdocmto (Henrique)

               07/01/2013 - Formatar data de liberacao da crapdpb conforme
                            regra da b1wgen0001.p (David).

               04/02/2013 - Conversao Progress -> Oracle (Alisson - Amcom)
							 
							 09/10/2014 - Adicionado tratamento para deposito intercooperativa na
							              procedure pc_proc_crapchd.(Reinert)
               
               14/01/2015 - Adicionado ao log da cr�tica 347 tais informa��es como:
                            - Tipo de taxa;
                            - �ltimo dia do m�s;
                            - C�digo da linha de cr�dito;
                            - C�digo do hist�rico. (Kelvin - SD 242477)
                            
               07/04/2015 - Ajustado critica duplicada. (Daniel).
               
               07/04/2015 - Retirado acentua��o ao efetuar log de erro (Daniel)     
                        

     ............................................................................. */

     DECLARE


     /* Cursores da rotina CRPS019_I */

     --Selecionar lancamentos
     CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                       ,pr_nrdconta IN craplcm.nrdconta%TYPE
                       ,pr_dtinic   IN craplcm.dtmvtolt%TYPE
                       ,pr_dtfinal  IN craplcm.dtmvtolt%TYPE) IS
       SELECT /*+ INDEX (craplcm craplcm##craplcm2) */
             craplcm.cdhistor
            ,craplcm.cdpesqbb
            ,craplcm.nrdocmto
            ,craplcm.nrdconta
            ,craplcm.dtmvtolt
            ,craplcm.vllanmto
            ,craplcm.cdagenci
            ,craplcm.cdbccxlt
            ,craplcm.nrdolote
            ,craplcm.cdbanchq
            ,craplcm.cdagechq
            ,craplcm.cdcmpchq
            ,craplcm.nrlotchq
            ,craplcm.sqlotchq
            ,craplcm.nrctachq
            ,row_number() over (PARTITION BY craplcm.nrdconta
                                ORDER BY craplcm.cdcooper
                                        ,craplcm.nrdconta
                                        ,craplcm.dtmvtolt
                                        ,craplcm.cdhistor
                                        ,craplcm.nrdocmto
                                        ,craplcm.cdagenci
                                        ,craplcm.cdbccxlt
                                        ,craplcm.nrdolote
                                        ,craplcm.nrseqdig) nrseqreg
            ,COUNT(1) over (PARTITION BY craplcm.nrdconta) nrtotreg
       FROM craplcm
       WHERE craplcm.cdcooper  = pr_cdcooper
       AND   craplcm.nrdconta  = pr_nrdconta
       AND   craplcm.dtmvtolt >= pr_dtinic
       AND   craplcm.dtmvtolt  < pr_dtfinal
       AND   craplcm.cdhistor <> 289;
     rw_craplcm cr_craplcm%ROWTYPE;

     --Selecionar Saldo
     CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE
                       ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS
       SELECT crapsld.nrdconta
             ,crapsld.vlsdextr
             ,crapsld.vlsdmesa
       FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
       AND   crapsld.nrdconta = pr_nrdconta;
     rw_crapsld cr_crapsld%ROWTYPE;

     --Selecionar Limites Conta
     CURSOR cr_craplim (pr_cdcooper IN crapsld.cdcooper%TYPE
                       ,pr_nrdconta IN crapsld.nrdconta%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                       ,pr_insitlim IN craplim.insitlim%TYPE) IS
       SELECT  craplim.cddlinha
              ,craplim.vllimite
       FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
       AND   craplim.nrdconta = pr_nrdconta
       AND   craplim.tpctrlim = pr_tpctrlim
       AND   craplim.insitlim = pr_insitlim
       ORDER BY craplim.progress_recid ASC;
     rw_craplim cr_craplim%ROWTYPE;

     --Selecionar Historicos de Limites Conta
     CURSOR cr_craplim1 (pr_cdcooper IN crapsld.cdcooper%TYPE
                        ,pr_nrdconta IN crapsld.nrdconta%TYPE
                        ,pr_insitlim IN craplim.insitlim%TYPE
                        ,pr_dtfimvig IN craplim.dtfimvig%TYPE) IS
       SELECT  craplim.cddlinha
              ,craplim.vllimite
              ,craplim.dtfimvig
       FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
       AND   craplim.nrdconta = pr_nrdconta
       AND   craplim.insitlim = pr_insitlim
       AND   craplim.dtfimvig >= pr_dtfimvig
       ORDER BY nrdconta,dtfimvig,vllimite ;

     --Selecionar informacoes do titular
     CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                       ,pr_nrdconta IN crapttl.nrdconta%type
                       ,pr_idseqttl IN crapttl.idseqttl%type) IS
       SELECT crapttl.nmextttl
             ,crapttl.nrcpfcgc
             ,crapttl.cdempres
       FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
       AND   crapttl.nrdconta = pr_nrdconta
       AND   crapttl.idseqttl = pr_idseqttl;
     rw_crapttl cr_crapttl%ROWTYPE;

     --Selecionar dados Pessoa Juridica
     CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                       ,pr_nrdconta IN crapjur.nrdconta%type) IS
       SELECT crapjur.nmextttl
             ,crapjur.cdempres
       FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
       AND   crapjur.nrdconta = pr_nrdconta;
     rw_crapjur cr_crapjur%ROWTYPE;

     --Selecionar Alineas
     CURSOR cr_crapali (pr_cdalinea IN crapali.cdalinea%TYPE) IS
       SELECT crapali.dsalinea
       FROM crapali
       WHERE crapali.cdalinea = pr_cdalinea;
     rw_crapali cr_crapali%ROWTYPE;

     --Selecionar Depositos Bloqueados
     CURSOR cr_crapdpb (pr_cdcooper IN crapdpb.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplcm.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplcm.nrdolote%TYPE
                       ,pr_nrdconta IN craplcm.nrdconta%TYPE
                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
       SELECT crapdpb.dtliblan
             ,crapdpb.inlibera
       FROM crapdpb
       WHERE crapdpb.cdcooper = pr_cdcooper
       AND   crapdpb.dtmvtolt = pr_dtmvtolt
       AND   crapdpb.cdagenci = pr_cdagenci
       AND   crapdpb.cdbccxlt = pr_cdbccxlt
       AND   crapdpb.nrdolote = pr_nrdolote
       AND   crapdpb.nrdconta = pr_nrdconta
       AND   crapdpb.nrdocmto = pr_nrdocmto;
     rw_crapdpb cr_crapdpb%ROWTYPE;


     --Selecionar Taxas
     CURSOR cr_craptax  (pr_cdcooper IN craptax.cdcooper%TYPE
                        ,pr_dtmvtolt IN craptax.dtmvtolt%TYPE
                        ,pr_tpdetaxa IN craptax.tpdetaxa%TYPE
                        ,pr_cdlcremp IN craptax.cdlcremp%TYPE) IS
       SELECT craptax.dtmvtolt
             ,craptax.txmensal
         FROM craptax
        WHERE craptax.cdcooper = pr_cdcooper
          AND craptax.dtmvtolt  = pr_dtmvtolt
          AND craptax.tpdetaxa  = pr_tpdetaxa
          AND craptax.cdlcremp  = pr_cdlcremp;
     rw_craptax cr_craptax%ROWTYPE;

     --Tipos de Tabelas de Memoria
     TYPE typ_tab_dslimite IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER;

     --Tabelas de Memoria
     vr_tab_dslimite typ_tab_dslimite;

     --Constantes
     vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS019_I';

     --Variaveis Locais
     vr_salvalim   NUMBER;
     vr_ahlimite   BOOLEAN;
     vr_craptax    BOOLEAN;
     vr_prmchqcc   BOOLEAN;
     vr_cdlcremp   INTEGER;
     vr_cdempres   INTEGER;
     vr_incremnt   INTEGER;
     vr_nrdordem   INTEGER;
     vr_tpdetaxa   INTEGER;
     vr_index      INTEGER;
     vr_prdiames   DATE;
     vr_uldiames   DATE;
     vr_nrdocmto   VARCHAR2(100);
     vr_dsstring   VARCHAR2(1000);
     vr_dslimite   VARCHAR2(1000);

     --Variaveis Registro
     vr_mex_indsalto VARCHAR2(1);
     vr_mex_registro VARCHAR2(1000);
     vr_reg_lindetal VARCHAR2(1000);
     vr_reg_ddmvtolt VARCHAR2(1000);
     vr_reg_dshistor VARCHAR2(1000);
     vr_reg_nrdocmto VARCHAR2(1000);
     vr_reg_vllanmto VARCHAR2(1000);
     vr_reg_cdagenci VARCHAR2(1000);
     vr_reg_cdbccxlt VARCHAR2(1000);
     vr_reg_nrdolote VARCHAR2(1000);
     vr_reg_indebcre VARCHAR2(1000);
     vr_reg_dtliblan VARCHAR2(1000);
     vr_reg_cdpesqbb VARCHAR2(1000);
     vr_reg_dstptaxa VARCHAR2(1000);

     --Variaveis para retorno de erro
     vr_cdcritic        INTEGER:= 0;
     vr_dscritic        VARCHAR2(4000);

     --Variaveis de Excecao
     vr_exc_final       EXCEPTION;
     vr_exc_saida       EXCEPTION;
     vr_exc_fimprg      EXCEPTION;


     --Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       vr_idx     PLS_INTEGER;
     BEGIN
       --Verificar o registro corrente
       vr_idx:= pr_tab_clob.COUNT;
       --Se for o primeiro registro
       IF vr_idx = 0 THEN
         pr_tab_clob(1):= pr_des_dados;
       ELSIF nvl(length(pr_tab_clob(vr_idx)),0) + nvl(length(pr_des_dados),0) > 32000 THEN
         --Gravar informacao na tabela memoria
         pr_tab_clob(vr_idx+1):= pr_des_dados;
         --Limpar Buffer
       ELSE
         --Concatenar conteudo na linha atual da temp-table
         pr_tab_clob(vr_idx):= pr_tab_clob(vr_idx) ||pr_des_dados;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_saida;
     END pc_escreve_xml;

     --Escrever Cabecalhos no Clob
     PROCEDURE pc_gera_cabecalho (pr_tipo     IN INTEGER
                                 ,pr_nrdordem IN OUT INTEGER
                                 ,pr_incremnt IN OUT INTEGER
                                 ,pr_indsalto IN OUT VARCHAR2) IS
       vr_index PLS_INTEGER;
       vr_texto VARCHAR2(4000);
     BEGIN
       CASE pr_tipo
         WHEN 01 THEN
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(1),132,' ');
         WHEN 02 THEN
           pr_nrdordem:= pr_nrdordem + 1;
           pr_indsalto:= ' ';
           vr_texto:= pr_indsalto|| rpad(pr_tab_cabmex(2)||to_char(pr_nrdordem,'999g990'),132,' ');
         WHEN 03 THEN
           pr_indsalto:= ' ';
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(3),132,' ');
         WHEN 04 THEN
           pr_indsalto:= '0';
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(4),132,' ');
         WHEN 05 THEN
           pr_indsalto:= ' ';
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(5),132,' ');
         WHEN 06 THEN
           pr_indsalto:= '0';
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(6),132,' ');
         WHEN 07 THEN
           pr_indsalto:= ' ';
           vr_texto:= pr_indsalto ||rpad(vr_reg_lindetal,132,' ');
         WHEN 08 THEN
           --Inicializar Incremento
           pr_incremnt:= 1;
           pr_indsalto:= ' ';
           --percorrer Limites
           vr_index:= vr_tab_dslimite.FIRST;
           WHILE vr_index IS NOT NULL LOOP
             vr_texto:= pr_indsalto ||rpad(vr_tab_dslimite(vr_index),132,' ');
             --Escrever no Clob
             pc_escreve_xml(vr_texto||chr(10));
             --Proximo registro
             pr_incremnt:= pr_incremnt + 1;
             vr_index:= vr_tab_dslimite.NEXT(vr_index);
           END LOOP;
         WHEN 09 THEN
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(9),132,' ');
         WHEN 10 THEN
           vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(10),132,' ');
         ELSE NULL;
       END CASE;
       --Escrever no Clob
       IF pr_tipo <> 8 THEN
         pc_escreve_xml(vr_texto||chr(10));
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever cabecalho na pc_crps019_i.pc_gera_cabecalho. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_saida;
     END pc_gera_cabecalho;

     --Gerar Cheques Acolhidos para depositos
     PROCEDURE pc_proc_crapchd (pr_cdcooper    IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                               ,pr_nrdconta    IN crapass.nrdconta%TYPE  --> Conta Associado
                               ,pr_vr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data Inicio Lancamento
                               ,pr_vr_dtlimite IN crapdat.dtmvtolt%TYPE  --> Data Limite
                               ,pr_indsalto    IN OUT VARCHAR2           --> Indicador Salto
                               ,pr_nrdordem    IN OUT NUMBER             --> Numero ordem
                               ,pr_contlinh    IN OUT INTEGER            --> Contador Linha
                               ,pr_incremnt    IN OUT INTEGER            --> Incremento
                               ,pr_prmchqcc    IN OUT BOOLEAN            --> Primeiro Cheque
                               ,pr_cdcritic    OUT INTEGER               --> Codigo Critica
                               ,pr_dscritic    OUT VARCHAR2) IS          --> Descricao Erro
      BEGIN
        DECLARE
          --Selecionar Cheques Acolhidos
          CURSOR cr_crapchd (pr_cdcooper IN crapchd.cdcooper%TYPE
                            ,pr_nrdconta IN crapchd.nrdconta%TYPE
                            ,pr_dtinic   IN crapchd.dtmvtolt%TYPE
                            ,pr_dtfinal  IN crapchd.dtmvtolt%TYPE) IS
														
						SELECT * FROM (
						SELECT /*+ INDEX( crapchd CRAPCHD##CRAPCHD2) */ 
						       crapchd.dtmvtolt
                  ,crapchd.cdbanchq
                  ,crapchd.cdagechq
                  ,crapchd.cdcmpchq
                  ,crapchd.nrctachq
                  ,crapchd.nrcheque
                  ,crapchd.cdtipchq
                  ,crapchd.nrddigc1
                  ,crapchd.nrddigc2
                  ,crapchd.nrddigc3
                  ,crapchd.nrddigv1
                  ,crapchd.nrddigv2
                  ,crapchd.nrddigv3
                  ,crapchd.vlcheque
                  ,crapchd.dsdocmc7
            FROM crapchd
            WHERE crapchd.cdcooper = pr_cdcooper
            AND   crapchd.nrdconta = pr_nrdconta
            AND   crapchd.dtmvtolt >= pr_dtinic
            AND   crapchd.dtmvtolt <  pr_dtfinal
						UNION
						SELECT /*+ INDEX( crapchd CRAPCHD##CRAPCHD5) */ 
                   crapchd.dtmvtolt
                  ,crapchd.cdbanchq
                  ,crapchd.cdagechq
                  ,crapchd.cdcmpchq
                  ,crapchd.nrctachq
                  ,crapchd.nrcheque
                  ,crapchd.cdtipchq
                  ,crapchd.nrddigc1
                  ,crapchd.nrddigc2
                  ,crapchd.nrddigc3
                  ,crapchd.nrddigv1
                  ,crapchd.nrddigv2
                  ,crapchd.nrddigv3
                  ,crapchd.vlcheque
                  ,crapchd.dsdocmc7
            FROM crapchd,
						     crapcop
            WHERE crapcop.cdcooper = pr_cdcooper
						AND   crapchd.cdagedst = crapcop.cdagectl
						AND   crapchd.nrctadst = pr_nrdconta
            AND   crapchd.dtmvtolt >= pr_dtinic
            AND   crapchd.dtmvtolt <  pr_dtfinal) crapchd
						ORDER BY crapchd.dtmvtolt;
											
          --Variaveis Locais
          vr_cdcritic INTEGER;
          vr_dscritic VARCHAR2(4000);
          vr_exc_erro EXCEPTION;
        BEGIN
          --Inicializar parametros
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;
					
          --Percorrer
          FOR rw_crapchd IN cr_crapchd (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dtinic   => pr_vr_dtmvtolt
                                       ,pr_dtfinal  => pr_vr_dtlimite) LOOP
            --Primeiro Cheque
            IF pr_prmchqcc THEN
              --Contador
              IF pr_contlinh > 81 THEN
                --indicador salto
                pr_indsalto:= '1';
                pc_gera_cabecalho(1,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 1    */
                pc_gera_cabecalho(2,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 2    */
                --Contador Linha
                pr_contlinh:= 2;
              END IF;
              pc_gera_cabecalho(9,pr_nrdordem,pr_incremnt,pr_indsalto);   /* cabecalho 9    */
              pc_gera_cabecalho(10,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 10    */
              --Setar que nao eh mais primeiro cheque
              pr_prmchqcc:= FALSE;
              --Incrementar Contador Linha
              pr_contlinh:= pr_contlinh + 2;
            END IF;
            --Montar Linha Detalhe
            vr_reg_lindetal:= ' '||
                              to_char(rw_crapchd.dtmvtolt,'DD')                 || ' ' ||
                              gene0002.fn_mask(rw_crapchd.cdbanchq,'999')       || ' ' ||
                              gene0002.fn_mask(rw_crapchd.cdagechq,'9999')      || ' ' ||
                              gene0002.fn_mask(rw_crapchd.cdcmpchq,'999')       || ' ' ||
                              lpad(to_char(rw_crapchd.nrctachq,'fm99g999g999g999g9'),16,' ') || ' ' ||
                              lpad(to_char(rw_crapchd.nrcheque,'fm999g990'),7,' ')     || ' ' ||
                              gene0002.fn_mask(rw_crapchd.cdtipchq,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigc1,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigc2,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigc3,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigv1,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigv2,'9')         || '  ' ||
                              gene0002.fn_mask(rw_crapchd.nrddigv3,'9')         || ' ' ||
                              to_char(rw_crapchd.vlcheque,'999g999g990d00')     || ' ' ||
                              rw_crapchd.dsdocmc7;
            --Verificar Quebra
            IF pr_contlinh = 84 THEN
              --indicador salto
              pr_indsalto:= '1';
              pc_gera_cabecalho(1,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 1    */
              pc_gera_cabecalho(2,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 2    */
              pc_gera_cabecalho(9,pr_nrdordem,pr_incremnt,pr_indsalto);  /* cabecalho 9    */
              pc_gera_cabecalho(10,pr_nrdordem,pr_incremnt,pr_indsalto); /* cabecalho 10   */
              --Setar Contador
              pr_contlinh:= 4;
            END IF;
            pc_gera_cabecalho(7,pr_nrdordem,pr_incremnt,pr_indsalto);  /* linha detalhe */
            --Incrementar Contador linha
            pr_contlinh:= pr_contlinh + 1;
          END LOOP;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_cdcritic:= vr_cdcritic;
           pr_dscritic:= vr_dscritic;
         WHEN OTHERS THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro ao escrever cabecalho na pc_crps019_i.pc_proc_crapchd. '||sqlerrm;
       END;
     END pc_proc_crapchd;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS019_i
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       /*  Verifica se o associado teve lancamentos no mes, caso contrario nao imprime o extrato  */
       IF NOT pr_tab_craplcm.EXISTS(pr_nrdconta) THEN
         --Sair sem erro
         RAISE vr_exc_final;
       END IF;

       --Inicializar variaveis
       pr_regexist:= TRUE;
       vr_prmchqcc:= TRUE;
       vr_cdlcremp:= 0;
       vr_cdempres:= 0;
       --Selecionar Saldo
       OPEN cr_crapsld (pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
       FETCH cr_crapsld INTO rw_crapsld;
       --Se nao encontrou
       IF cr_crapsld%NOTFOUND THEN
         --Fechar Cursor
         CLOSE cr_crapsld;
         vr_cdcritic:= 10;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --levantar Excecao
         RAISE vr_exc_saida;
       END IF;
       --Fechar Cursor
       CLOSE cr_crapsld;
       /*   Verifica somente o Limite de credito indicado no cabecalho   */
       OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrlim => 1
                       ,pr_insitlim => 2);
       FETCH cr_craplim INTO rw_craplim;
       --Se encontrou
       IF cr_craplim%FOUND THEN
         --Linha Credito
         vr_cdlcremp:= rw_craplim.cddlinha;
         --Valor Limite
         vr_salvalim:= rw_craplim.vllimite;
       ELSE
         --Valor Limite
         vr_salvalim:= 0;
       END IF;
       --Fechar Cursor
       CLOSE cr_craplim;
       /*   Calcula se houve mudancas no limite de credito durante o mes   */
       vr_prdiames:= trunc(pr_dtmvtolt,'MM');
       vr_dsstring:= NULL;
       vr_dslimite:= NULL;
       vr_incremnt:= 1;
       vr_ahlimite:= FALSE;

       --Percorrer Limites
       FOR rw_craplim1 IN cr_craplim1 (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_insitlim => 3
                                      ,pr_dtfimvig => pr_vr_dtmvtolt) LOOP
         --Se nao existir limite
         IF NOT vr_ahlimite THEN
           vr_ahlimite:= TRUE;
         END IF;
         --Descricao nula
         IF TRIM(vr_dsstring) IS NOT NULL THEN
           --Montar descricao limite
           vr_tab_dslimite(vr_incremnt):= vr_dsstring ||to_char(rw_craplim1.vllimite,'fm99g999g990d00');
           --Limpar String
           vr_dsstring:= NULL;
         ELSE
           --Montar descricao limite
           vr_tab_dslimite(vr_incremnt):= 'HISTORICO DE LIMITE DE CREDITO';
         END IF;
         --Incrementar contador
         vr_incremnt:= vr_incremnt + 1;
         --Descricao
         vr_dsstring:= to_char(rw_craplim1.dtfimvig, 'DD/MM/YYYY')|| ' DE '||
                       to_char(rw_craplim1.vllimite, 'fm99g999g990d00') || ' PARA ';
         --Linha credito zerada
         IF nvl(vr_cdlcremp,0) = 0 THEN
           --Linha credito recebe codigo da linha
           vr_cdlcremp:= rw_craplim1.cddlinha;
         END IF;
       END LOOP;
       --Existe limite
       IF vr_ahlimite THEN
         vr_tab_dslimite(vr_incremnt):= vr_dsstring ||to_char(vr_salvalim,'fm99g999g990d00');
       END IF;
       --Pessoa Fisica
       IF pr_inpessoa = 1 THEN
         --Selecionar Titular
         OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_idseqttl => 1);
         --Posicionar Primeiro Registro
         FETCH cr_crapttl INTO rw_crapttl;
         --Se Encontrou
         IF cr_crapttl%FOUND THEN
           --Codigo Empresa
           vr_cdempres:= rw_crapttl.cdempres;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapttl;
       ELSE
         /** Lista o nome da empresa **/
         OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapjur INTO rw_crapjur;
         --Se Encontrou
         IF cr_crapjur%FOUND THEN
           --Codigo Empresa
           vr_cdempres:= rw_crapjur.cdempres;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapjur;
       END IF;
       --Zerar Numero Ordem
       vr_nrdordem:= 0;
       --Registro Cabecalho 2
       pr_tab_cabmex(2):= ' '||gene0002.fn_mask(vr_cdempres,'99999')|| '  '||
                              gene0002.fn_mask(pr_nrdconta,'Z.ZZZ.ZZZ.9') || '  '||
                              rpad(pr_nmprimtl,36,' ')|| '   '||
                              rpad(pr_nmmesref,14,' ')|| rpad(' ',50,' ');
       --Registro Cabecalho 3
       pr_tab_cabmex(3):= 'LIMITE CREDITO: '||
                          to_char(vr_salvalim,'99g999g990d00') || '   '||
                          'SALDO ANTERIOR: '||
                          to_char(rw_crapsld.vlsdextr,'999g999g999g990d00mi')||
                          rpad(' ',33,' ');
       --Registro Cabecalho 5
       pr_tab_cabmex(5):= rpad(' ',32,' ')|| '   SALDO ATUAL: '||
                          to_char(rw_crapsld.vlsdmesa,'999g999g999g990d00mi')||
                          rpad(' ',33,' ');
       --Se for primeiro registro
       IF pr_flgfirst THEN
         --Marcar False
         pr_flgfirst:= FALSE;
         --Indicador Salto
         vr_mex_indsalto:= '+';
       ELSE
         --Contador linha
         IF pr_contlinh > 77 THEN
           --Indicador salto
           vr_mex_indsalto:= '1';
           --Zerar Contador linha
           pr_contlinh:= 0;
         ELSE
           --Indicador salto
           vr_mex_indsalto:= '0';
           --Zerar Contador linha
           pr_contlinh:= pr_contlinh + 1;
         END IF;
       END IF;

       -- Gerar Cabecalhos
       pc_gera_cabecalho(1,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /*  Imprime cabecalho 1 (reg_cabmex01) */
       pc_gera_cabecalho(2,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /*  Imprime cabecalho 2 (reg_cabmex02) */
       pc_gera_cabecalho(3,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /*  Imprime cabecalho 3 (reg_cabmex03) */
       pc_gera_cabecalho(4,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /*  Imprime cabecalho 4 (reg_cabmex04) */
       --Incrementar linhas
       pr_contlinh:= pr_contlinh + 5;

       --Percorrer lancamentos
       FOR rw_craplcm IN cr_craplcm (pr_cdcooper  => pr_cdcooper
                                    ,pr_nrdconta  => pr_nrdconta
                                    ,pr_dtinic    => pr_vr_dtmvtolt
                                    ,pr_dtfinal   => pr_vr_dtlimite) LOOP

         /* TRANSF CARTAO, TRF.CARTAO I., CR.TRF.CARTAO, TR.INTERNET, TR.INTERNET I,
            CR. INTERNET, TR. SALARIO, CR. SALARIO */
         IF rw_craplcm.cdhistor IN (375,376,377,537,538,539,771,772) THEN
           --Numero Documento
           vr_nrdocmto:= gene0002.fn_mask_conta(to_number(SUBSTR(rw_craplcm.cdpesqbb,45,8)));
         ELSIF rw_craplcm.cdhistor IN (104,302,303) THEN /* TRF.MESM.TTL., DB.P/TRANSFER, CR.TRANSFEREN */
           --Codigo Pesquisa nao nulo
           IF TO_NUMBER(rw_craplcm.cdpesqbb) > 0 THEN
             vr_nrdocmto:= to_char(to_number(rw_craplcm.cdpesqbb),'fm99999g999g0');
           ELSE
             vr_nrdocmto:= to_char(rw_craplcm.nrdocmto,'fm999g999g990');
           END IF;
         ELSE
           --C.P.M.F.
           IF  rw_craplcm.cdhistor = 100 THEN
             --Codigo Pesquisa nao nulo
             IF TRIM(rw_craplcm.cdpesqbb) IS NOT NULL THEN
               vr_nrdocmto:= rw_craplcm.cdpesqbb;
             ELSE
               vr_nrdocmto:= to_char(rw_craplcm.nrdocmto,'fm9999999g990');
             END IF;
           ELSE
             --Verificar Historico na string
             IF gene0002.fn_existe_valor(pr_base  => pr_lshistor
                                        ,pr_busca => rw_craplcm.cdhistor
                                        ,pr_delimite => ',') = 'S' THEN
               vr_nrdocmto:= to_char(rw_craplcm.nrdocmto,'fm99999g990g0');
             ELSE
               --Conta menor 10 digitos
               IF nvl(length(rw_craplcm.nrdocmto),0) < 10 THEN
                 vr_nrdocmto:= to_char(rw_craplcm.nrdocmto,'fm9999999g990');
               ELSE
                 vr_nrdocmto:= substr(to_char(rw_craplcm.nrdocmto,'9999999999999999990'),5,11);
               END IF;
             END IF;
           END IF;
         END IF;
         --Dia Movimento
         vr_reg_ddmvtolt:= TO_CHAR(rw_craplcm.dtmvtolt,'DD');
         /* CH.DEV.PRC., CH.DEV.FPR., CHQ.DEVOL., CH.DEV.TRF., DEV.CH.DEP., DEV.CH.DESCTO */
         IF rw_craplcm.cdhistor IN (24,27,47,78,156,191,338,351,399,573) THEN
           IF pr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
             vr_reg_dshistor:= rpad(pr_tab_craphis(rw_craplcm.cdhistor).dshistor||
                                    rw_craplcm.cdpesqbb,21,' ');
           ELSE
             vr_reg_dshistor:= rpad(rw_craplcm.cdpesqbb,21,' ');
           END IF;
         ELSE
           --Se existir na tabela
           IF pr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
             vr_reg_dshistor:= rpad(pr_tab_craphis(rw_craplcm.cdhistor).dshistor,21,' ');
           ELSE
             vr_reg_dshistor:= rpad(' ',21,' ');
           END IF;
         END IF;
         --Numero Documento
         vr_reg_nrdocmto:= vr_nrdocmto;
         --Valor Lancamento
         vr_reg_vllanmto:= to_char(rw_craplcm.vllanmto,'fm9999g999g990d00');
         --Codigo Agencia
         vr_reg_cdagenci:= gene0002.fn_mask(rw_craplcm.cdagenci,'zz9');
         --banco/Caixa
         vr_reg_cdbccxlt:= gene0002.fn_mask(rw_craplcm.cdbccxlt,'zz9');
         --Numero Lote
         vr_reg_nrdolote:= gene0002.fn_mask(rw_craplcm.nrdolote,'zzzzz9');
         --Indicador Debito/Credito
         IF pr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
           vr_reg_indebcre:= rpad(pr_tab_craphis(rw_craplcm.cdhistor).indebcre,1,' ');
         ELSE
           vr_reg_indebcre:= ' ';
         END IF;

         /* CH.DEV.PRC., CH.DEV.FPR., CHQ.DEVOL., CH.DEV.TRF., DEV.CH.DEP., DEV.CH.DESCTO */
         IF rw_craplcm.cdhistor IN (24,27,47,78,156,191,338,351,399,573) AND
           TRIM(rw_craplcm.cdpesqbb) IS NOT NULL THEN
           --Selecionar Alineas
           OPEN cr_crapali (pr_cdalinea => to_number(rw_craplcm.cdpesqbb));
           FETCH cr_crapali INTO rw_crapali;
           --Se nao encontrou
           IF cr_crapali%NOTFOUND THEN
             vr_reg_cdpesqbb:= 'ALINEA '||rw_craplcm.cdpesqbb;
           ELSE
             vr_reg_cdpesqbb:= upper(rw_crapali.dsalinea);
           END IF;
           --Fechar Cursor
           CLOSE cr_crapali;
         ELSE
           /* CHEQUE COMP., CREDITO DOC, DOC SEG.SAUDE, CHQ.TRF.COMP., DEPOS.BANCOOB, CHQ.SAL.COMP */
           IF rw_craplcm.cdhistor IN (358,340,313,314,319,339,345) THEN
             --Codigo Pesquisa
             vr_reg_cdpesqbb:= gene0002.fn_mask(rw_craplcm.cdbanchq,'999')     || '-' ||
                               gene0002.fn_mask(rw_craplcm.cdagechq,'9999')    || '-' ||
                               gene0002.fn_mask(rw_craplcm.cdcmpchq,'999')     || '-' ||
                               gene0002.fn_mask(rw_craplcm.nrlotchq,'9999999') || '-' ||
                               gene0002.fn_mask(rw_craplcm.sqlotchq,'999999')  || '-' ||
                               rw_craplcm.nrctachq;
           ELSE
             --Codigo Pesquisa
             vr_reg_cdpesqbb:= rw_craplcm.cdpesqbb;
           END IF;
         END IF;
         --Indicador Historico
         IF pr_tab_craphis.EXISTS(rw_craplcm.cdhistor) AND
            pr_tab_craphis(rw_craplcm.cdhistor).inhistor IN (3,4,5) THEN
           --Selecionar Depositos Bloqueados
           OPEN cr_crapdpb (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                           ,pr_cdagenci => rw_craplcm.cdagenci
                           ,pr_cdbccxlt => rw_craplcm.cdbccxlt
                           ,pr_nrdolote => rw_craplcm.nrdolote
                           ,pr_nrdconta => rw_craplcm.nrdconta
                           ,pr_nrdocmto => rw_craplcm.nrdocmto);
           FETCH cr_crapdpb INTO rw_crapdpb;
           --Se nao Encontrou
           IF cr_crapdpb%NOTFOUND THEN
             vr_reg_dtliblan:= '**/**';
           ELSIF rw_crapdpb.inlibera = 1 THEN
             vr_reg_dtliblan:= SUBSTR(to_char(rw_crapdpb.dtliblan,'DD/MM/YY'),1,5);
           ELSE
             vr_reg_dtliblan:= 'Estor';
           END IF;
           --Fechar Cursor
           CLOSE cr_crapdpb;
         ELSE
           --Data Liberacao Lancamento
           vr_reg_dtliblan:= rpad(' ',5,' ');
         END IF;
         /*   Encontra data em que foi gerado o craptax */
         /*   Essa taxa deve ser selecionada no programa chamador e passada como parametro */
         --Se possui taxa
         IF pr_craptax THEN
           --Ultimo dia Mes
           vr_uldiames:= pr_dtmvttax;
         ELSE
           /* Calcula o ultimo dia util do mes para o craptax */
           vr_uldiames:= last_day(add_months(pr_dtmvtolt,-1));
           --Buscar o dia util anterior
           vr_uldiames:= gene0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_uldiames
                                                     ,pr_tipo => 'A');
                                                     
           vr_uldiames := to_date('30/09/2014','dd/mm/yyyy');                                                                                               
         END IF;
         /*  Verifica as taxas de juros  */
         vr_reg_dstptaxa:= NULL;
         vr_tpdetaxa:= 0;
         --Historico
         IF rw_craplcm.cdhistor IN (38,57,37) THEN
           --Determinar tipo da taxa
           CASE rw_craplcm.cdhistor
             WHEN 37 THEN vr_tpdetaxa:= 4;
             WHEN 38 THEN vr_tpdetaxa:= 2;
             WHEN 57 THEN vr_tpdetaxa:= 3;
           END CASE;
           /* Juros do Cheque Especial */
           IF vr_tpdetaxa = 2 THEN
             --Selecionar a taxa
             OPEN cr_craptax  (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => vr_uldiames
                              ,pr_tpdetaxa => vr_tpdetaxa
                              ,pr_cdlcremp => vr_cdlcremp);
             FETCH cr_craptax INTO rw_craptax;
             --Verificar se encontrou ou nao
             vr_craptax:= cr_craptax%FOUND;
             --Fechar Cursor
             CLOSE cr_craptax;
           ELSE
             --Selecionar a taxa
             OPEN cr_craptax  (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => vr_uldiames
                              ,pr_tpdetaxa => vr_tpdetaxa
                              ,pr_cdlcremp => 0);
             FETCH cr_craptax INTO rw_craptax;
             --Verificar se encontrou ou nao
             vr_craptax:= cr_craptax%FOUND;
             --Fechar Cursor
             CLOSE cr_craptax;
           END IF;
  
           --Nao encontrou taxa
           IF NOT vr_craptax THEN
             -- Montar mensagem de critica
             vr_cdcritic:= 347;
             vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic ||' ('
                                                           || 'Tipo taxa: ' || vr_tpdetaxa ||' - ' 
                                                           || 'Ultimo dia mes: ' || vr_uldiames ||' - '
                                                           || 'Linha de Credito: ' || vr_cdlcremp ||' - ' 
                                                           || 'Historico: '|| rw_craplcm.cdhistor || ')');
             --Limpar a descricao da taxa
             vr_reg_dstptaxa:= NULL;
           ELSE
             --Descricao tipo da taxa
             vr_reg_dstptaxa:= to_char(rw_craptax.txmensal,'fm990d000000')||'%a.m';
           END IF;
         END IF;
         --Montar Linha Detalhe
         vr_reg_lindetal:= ' ' ||
                           lpad(vr_reg_ddmvtolt,02,' ') || ' ' ||
                           lpad(vr_reg_dshistor,18,' ') || ' '  ||
                           lpad(vr_reg_nrdocmto,11,' ') || ' '  ||
                           lpad(vr_reg_dtliblan,05,' ') || ' '  ||
                           lpad(vr_reg_vllanmto,15,' ') || '  ' ||
                           lpad(vr_reg_indebcre,01,' ') || '  ' ||
                           lpad(vr_reg_cdagenci,03,' ') || ' '   ||
                           lpad(vr_reg_cdbccxlt,03,' ') || ' '   ||
                           lpad(vr_reg_nrdolote,06,' ') || ' '  ||
                           lpad(vr_reg_cdpesqbb,41,' ') || ' '  ||
                           lpad(vr_reg_dstptaxa,14,' ');
         --Quebra Página
         IF pr_contlinh = 84 THEN
           --Ultima Conta
           IF rw_craplcm.nrseqreg = rw_craplcm.nrtotreg THEN
             --Indicador Salto
             vr_mex_indsalto:= '1';
             pc_gera_cabecalho(1,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 1    */
             pc_gera_cabecalho(2,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 2    */
             pc_gera_cabecalho(4,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 4    */
             pc_gera_cabecalho(7,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* linha detalhe  */
             pc_gera_cabecalho(5,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 5    */
             pc_gera_cabecalho(8,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* limite credito */
             --Incrementar Contador Linha
             pr_contlinh:= vr_incremnt + 6;

             --Gerar Cheques Acolhidos para depositos
             pc_proc_crapchd (pr_cdcooper    => pr_cdcooper     --> Codigo Cooperativa
                             ,pr_nrdconta    => pr_nrdconta     --> Conta Associado
                             ,pr_vr_dtmvtolt => pr_vr_dtmvtolt  --> Data Inicio Lancamento
                             ,pr_vr_dtlimite => pr_vr_dtlimite  --> Data Limite
                             ,pr_indsalto    => vr_mex_indsalto --> Indicador Salto
                             ,pr_nrdordem    => vr_nrdordem     --> Numero ordem
                             ,pr_contlinh    => pr_contlinh     --> Contador Linha
                             ,pr_incremnt    => vr_incremnt     --> Incremento
                             ,pr_prmchqcc    => vr_prmchqcc     --> Primeiro Cheque
                             ,pr_cdcritic    => vr_cdcritic     --> Codigo Erro
                             ,pr_dscritic    => vr_dscritic);   --> Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             pc_gera_cabecalho(6,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 6    */
             pr_contlinh:= pr_contlinh + 2; /*1*/
             --Sair do Loop
             RAISE vr_exc_final;
           ELSE
             --Indicador Salto
             vr_mex_indsalto:= '1';
             pc_gera_cabecalho(1,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 1    */
             pc_gera_cabecalho(2,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 2    */
             pc_gera_cabecalho(4,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 4    */
             pc_gera_cabecalho(7,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* linha detalhe  */
             --Setar contador Linha
             pr_contlinh:= 5;
           END IF;
         ELSE
           --Ultima Conta
           IF rw_craplcm.nrseqreg = rw_craplcm.nrtotreg THEN
             pc_gera_cabecalho(7,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* linha detalhe  */
             --Incrementar contador linha
             pr_contlinh:= pr_contlinh + 1;
             --Se quebrou pagina
             IF pr_contlinh = 84 THEN
               --Indicador Salto
               vr_mex_indsalto:= '1';
               pc_gera_cabecalho(1,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 1    */
               pc_gera_cabecalho(2,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 2    */
               pc_gera_cabecalho(5,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 5    */
               pc_gera_cabecalho(8,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* limite credito */
               --Incrementar Contador Linha
               pr_contlinh:= vr_incremnt + 3;

               --Gerar Cheques Acolhidos para depositos
               pc_proc_crapchd (pr_cdcooper    => pr_cdcooper     --> Codigo Cooperativa
                               ,pr_nrdconta    => pr_nrdconta     --> Conta Associado
                               ,pr_vr_dtmvtolt => pr_vr_dtmvtolt  --> Data Inicio Lancamento
                               ,pr_vr_dtlimite => pr_vr_dtlimite  --> Data Limite
                               ,pr_indsalto    => vr_mex_indsalto --> Indicador Salto
                               ,pr_nrdordem    => vr_nrdordem     --> Numero ordem
                               ,pr_contlinh    => pr_contlinh     --> Contador Linha
                               ,pr_incremnt    => vr_incremnt     --> Incremento
                               ,pr_prmchqcc    => vr_prmchqcc     --> Primeiro Cheque
                               ,pr_cdcritic    => vr_cdcritic     --> Codigo Erro
                               ,pr_dscritic    => vr_dscritic);   --> Descricao Erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;
               pc_gera_cabecalho(6,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 6    */
               pr_contlinh:= pr_contlinh + 2; /*1*/
               --Sair do Loop
               RAISE vr_exc_final;
             END IF;

             pc_gera_cabecalho(5,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 5    */
             --Incrementar Contador linha
             pr_contlinh:= pr_contlinh + 1;
             --Contador > 82
             IF pr_contlinh > 82 THEN
               --Gerar Cheques Acolhidos para depositos
               pc_proc_crapchd (pr_cdcooper    => pr_cdcooper     --> Codigo Cooperativa
                               ,pr_nrdconta    => pr_nrdconta     --> Conta Associado
                               ,pr_vr_dtmvtolt => pr_vr_dtmvtolt  --> Data Inicio Lancamento
                               ,pr_vr_dtlimite => pr_vr_dtlimite  --> Data Limite
                               ,pr_indsalto    => vr_mex_indsalto --> Indicador Salto
                               ,pr_nrdordem    => vr_nrdordem     --> Numero ordem
                               ,pr_contlinh    => pr_contlinh     --> Contador Linha
                               ,pr_incremnt    => vr_incremnt     --> Incremento
                               ,pr_prmchqcc    => vr_prmchqcc     --> Primeiro Cheque
                               ,pr_cdcritic    => vr_cdcritic     --> Codigo Erro
                               ,pr_dscritic    => vr_dscritic);   --> Descricao Erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;
               --Sair do Loop
               RAISE vr_exc_final;
             END IF;  --pr_contlinh > 82
             --Inicializar incremento
             vr_incremnt:= 1;              /* limite credito */
             --Limpar Indicador Salto
             vr_mex_indsalto:= ' ';
             --Percorrer Limites
             vr_index:= vr_tab_dslimite.FIRST;
             WHILE vr_index IS NOT NULL LOOP
               --Se tiver valor
               IF TRIM(vr_tab_dslimite(vr_index)) IS NOT NULL THEN
                 vr_mex_registro:= vr_mex_indsalto ||rpad(vr_tab_dslimite(vr_index),132,' ');
                 --Incrementar contador
                 vr_incremnt:= vr_incremnt + 1;
                 --Escrever no Clob
                 pc_escreve_xml(vr_mex_registro||chr(10));
                 --Controlar Quebra
                 IF pr_contlinh = 84 THEN
                   vr_mex_indsalto:= '1';
                   pr_contlinh:= 1;
                 ELSE
                   --Incrementar Linha
                   pr_contlinh:= pr_contlinh + 1;
                   vr_mex_indsalto:= ' ';
                 END IF;
               END IF;
               --Proximo registro
               vr_index:= vr_tab_dslimite.NEXT(vr_index);
             END LOOP;
             --Contador linha > 82
             IF pr_contlinh > 82 THEN
               --Gerar Cheques Acolhidos para depositos
               pc_proc_crapchd (pr_cdcooper    => pr_cdcooper     --> Codigo Cooperativa
                               ,pr_nrdconta    => pr_nrdconta     --> Conta Associado
                               ,pr_vr_dtmvtolt => pr_vr_dtmvtolt  --> Data Inicio Lancamento
                               ,pr_vr_dtlimite => pr_vr_dtlimite  --> Data Limite
                               ,pr_indsalto    => vr_mex_indsalto --> Indicador Salto
                               ,pr_nrdordem    => vr_nrdordem     --> Numero ordem
                               ,pr_contlinh    => pr_contlinh     --> Contador Linha
                               ,pr_incremnt    => vr_incremnt     --> Incremento
                               ,pr_prmchqcc    => vr_prmchqcc     --> Primeiro Cheque
                               ,pr_cdcritic    => vr_cdcritic     --> Codigo Erro
                               ,pr_dscritic    => vr_dscritic);   --> Descricao Erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_saida;
               END IF;
               --Sair do loop
               RAISE vr_exc_final;
             END IF;
             --Incrementar contador linha
             pr_contlinh:= pr_contlinh + 1;
             --Gerar Cheques Acolhidos para depositos
             pc_proc_crapchd (pr_cdcooper    => pr_cdcooper     --> Codigo Cooperativa
                             ,pr_nrdconta    => pr_nrdconta     --> Conta Associado
                             ,pr_vr_dtmvtolt => pr_vr_dtmvtolt  --> Data Inicio Lancamento
                             ,pr_vr_dtlimite => pr_vr_dtlimite  --> Data Limite
                             ,pr_indsalto    => vr_mex_indsalto --> Indicador Salto
                             ,pr_nrdordem    => vr_nrdordem     --> Numero ordem
                             ,pr_contlinh    => pr_contlinh     --> Contador Linha
                             ,pr_incremnt    => vr_incremnt     --> Incremento
                             ,pr_prmchqcc    => vr_prmchqcc     --> Primeiro Cheque
                             ,pr_cdcritic    => vr_cdcritic     --> Codigo Erro
                             ,pr_dscritic    => vr_dscritic);   --> Descricao Erro
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
             pc_gera_cabecalho(6,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* cabecalho 6    */
             pr_contlinh:= pr_contlinh + 1;
             --Sair do loop
             RAISE vr_exc_final;
           ELSE
             pc_gera_cabecalho(7,vr_nrdordem,vr_incremnt,vr_mex_indsalto);  /* linha detalhe  */
             pr_contlinh:= pr_contlinh + 1;
           END IF; --ultima conta
         END IF;
       END LOOP; --rw_craplcm
     EXCEPTION
       WHEN vr_exc_final THEN
         --Sair da rotina sem erro
         pr_cdcritic := NULL;
         pr_dscritic := NULL;
       WHEN vr_exc_saida THEN
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina crps019_i. '||sqlerrm;
     END;
   END pc_crps019_i;


  /* Procedure que processa as contas para microfilmagem */
  PROCEDURE pc_crps046_i (pr_tipo         IN PLS_INTEGER                  --> Identificador do Cabecalho
                         ,pr_tab_clob     IN OUT NOCOPY CADA0001.typ_tab_linha --> Clob de dados
                         ,pr_nrdordem     IN OUT INTEGER                  --> Numero da ordem
                         ,pr_indsalto     IN OUT VARCHAR2                 --> Indicador de Salto
                         ,pr_tab_cabmex   IN OUT NOCOPY CADA0001.typ_tab_char --> Tabela de Memoria com Cabecalhos
                         ,pr_reg_lindetal IN VARCHAR2                     --> Linha Detalhe
                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE       --> Codigo da Critica
                         ,pr_dscritic     OUT VARCHAR2) IS                --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps046_i                             Antigo: Includes/crps046_1.i até crps046_7.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 03/12/93

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps046.p.
   Objetivo  : Gera cabecalho numero 1.

   Alterações:
               17/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)

     ............................................................................. */

     DECLARE

       --Variaveis para retorno de erro
       vr_cdcritic        INTEGER:= 0;
       vr_dscritic        VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final       EXCEPTION;
       vr_exc_saida       EXCEPTION;
       vr_exc_fimprg      EXCEPTION;


       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
         vr_idx     PLS_INTEGER;
       BEGIN
         --Verificar o registro corrente
         vr_idx:= pr_tab_clob.COUNT;
         --Se for o primeiro registro
         IF vr_idx = 0 THEN
           pr_tab_clob(1):= pr_des_dados;
         ELSIF nvl(length(pr_tab_clob(vr_idx)),0) + nvl(length(pr_des_dados),0) > 32000 THEN
           --Gravar informacao na tabela memoria
           pr_tab_clob(vr_idx+1):= pr_des_dados;
           --Limpar Buffer
         ELSE
           --Concatenar conteudo na linha atual da temp-table
           pr_tab_clob(vr_idx):= pr_tab_clob(vr_idx) ||pr_des_dados;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_escreve_xml;

       --Escrever Cabecalhos no Clob
       PROCEDURE pc_gera_cabecalho IS
         vr_index PLS_INTEGER;
         vr_texto VARCHAR2(4000);
       BEGIN
         CASE pr_tipo
           WHEN 01 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(1),132,' ');
           WHEN 02 THEN
             pr_nrdordem:= pr_nrdordem + 1;
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto|| rpad(pr_tab_cabmex(2)||to_char(pr_nrdordem,'9990'),132,' ');
           WHEN 03 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(3),132,' ');
           WHEN 05 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(5),132,' ');
           WHEN 06 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(6),132,' ');
           WHEN 07 THEN
             pr_indsalto:= ' ';
             vr_texto:= pr_indsalto ||rpad(pr_reg_lindetal,132,' ');
           WHEN 09 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(9),132,' ');
           WHEN 10 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(10),132,' ');
           ELSE NULL;
         END CASE;
         --Escrever no Clob
         pc_escreve_xml(vr_texto||chr(10));
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever cabecalho na pc_crps046_i.pc_gera_cabecalho. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_gera_cabecalho;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS046_i
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       --Gerar Cabecalho
       pc_gera_cabecalho;

     EXCEPTION
       WHEN vr_exc_final THEN
         --Sair da rotina sem erro
         pr_cdcritic := NULL;
         pr_dscritic := NULL;
       WHEN vr_exc_saida THEN
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina crps046_i. '||sqlerrm;
     END;
   END pc_crps046_i;
   
   /* Procedure que processa as contas para microfilmagem */
  PROCEDURE pc_crps157_i (pr_tipo         IN PLS_INTEGER                  --> Identificador do Cabecalho
                         ,pr_tab_clob     IN OUT NOCOPY CADA0001.typ_tab_linha --> Clob de dados
                         ,pr_nrdordem     IN OUT INTEGER                  --> Numero da ordem
                         ,pr_indsalto     IN OUT VARCHAR2                 --> Indicador de Salto
                         ,pr_tab_cabmex   IN OUT NOCOPY CADA0001.typ_tab_char --> Tabela de Memoria com Cabecalhos
                         ,pr_reg_lindetal IN VARCHAR2                     --> Linha Detalhe
                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE       --> Codigo da Critica
                         ,pr_dscritic     OUT VARCHAR2) IS                --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps157_i                             Antigo: Includes/crps157_1.i até crps157_9.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                           Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps157.p.
   Objetivo  : Gera cabecalho numero 1.

  ................................................................................. */

     DECLARE

       --Variaveis para retorno de erro
       vr_cdcritic        INTEGER:= 0;
       vr_dscritic        VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final       EXCEPTION;
       vr_exc_saida       EXCEPTION;
       vr_exc_fimprg      EXCEPTION;


       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
         vr_idx     PLS_INTEGER;
       BEGIN
         --Verificar o registro corrente
         vr_idx:= pr_tab_clob.COUNT;
         --Se for o primeiro registro
         IF vr_idx = 0 THEN
           pr_tab_clob(1):= pr_des_dados;
         ELSIF nvl(length(pr_tab_clob(vr_idx)),0) + nvl(length(pr_des_dados),0) > 32000 THEN
           --Gravar informacao na tabela memoria
           pr_tab_clob(vr_idx+1):= pr_des_dados;
           --Limpar Buffer
         ELSE
           --Concatenar conteudo na linha atual da temp-table
           pr_tab_clob(vr_idx):= pr_tab_clob(vr_idx) ||pr_des_dados;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_escreve_xml;

       --Escrever Cabecalhos no Clob
       PROCEDURE pc_gera_cabecalho IS
         vr_index PLS_INTEGER;
         vr_texto VARCHAR2(4000);
       BEGIN
         CASE pr_tipo
           WHEN 01 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(1),132,' ');
           WHEN 02 THEN
             pr_nrdordem:= pr_nrdordem + 1;
             pr_indsalto:= ' ';
             vr_texto:= pr_indsalto|| rpad(pr_tab_cabmex(2) || to_char(pr_nrdordem,'9990'),132,' ');
           WHEN 03 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(3),132,' ');
           WHEN 04 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(4),132,' ');
           WHEN 05 THEN
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(5),132,' ');
           WHEN 06 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(6),132,' ');
           WHEN 07 THEN
             pr_indsalto:= ' ';
             vr_texto:= pr_indsalto ||rpad(pr_reg_lindetal,132,' ');
           WHEN 08 THEN
             pr_indsalto:= '0';
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(8),132,' ');
           WHEN 09 THEN
             pr_indsalto:= '0';						 
             vr_texto:= pr_indsalto ||rpad(pr_tab_cabmex(9),132,' ');
           ELSE NULL;
         END CASE;
         --Escrever no Clob
         pc_escreve_xml(vr_texto||chr(10));
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever cabecalho na pc_crps157_i.pc_gera_cabecalho. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_gera_cabecalho;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS157_i
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       --Gerar Cabecalho
       pc_gera_cabecalho;

     EXCEPTION
       WHEN vr_exc_final THEN
         --Sair da rotina sem erro
         pr_cdcritic := NULL;
         pr_dscritic := NULL;
       WHEN vr_exc_saida THEN
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina crps157_i. '||sqlerrm;
     END;
   END pc_crps157_i;

  /* Rotina de Limpeza de Microfilmagem */
  PROCEDURE pc_limpeza_crps019_crps076 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_cdprogra IN VARCHAR2                --> Nome Programa da Execucao crps019/crps076
                                       ,pr_flgtrans IN BOOLEAN                 --> Transmite ou nao o arquivo
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_limpeza_crps019_crps076      Antigo: Fontes/CRPS019.p e Fontes/CRPS076.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima atualizacao: 02/08/2017

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
               Emite: arquivo geral de extratos de conta para microfilmagem
                      ate a conta 559999.

   Alteracoes: 03/11/94 - Alterado para criar a variavel com os historicos refe-
                          rentes a cheques (Deborah).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               03/04/97 - Alterado para trocar do /win10 para o /win12 (Deborah)

               04/02/98 - Incluir funcao transmic (Odair)

               09/03/98 - Alterado para passar novo parametro para o shell
                          transmic (Deborah).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               24/06/99 - Incluir na lista historicos 338,340 (Odair)

               02/08/99 - Alterado para ler a lista de historicos de uma tabela
                          (Edson).

               05/10/1999 - Parametrizar o diretorio (Deborah).

               10/01/2000 - Padronizar mensagens (Deborah).

               23/02/2000 - Tratar arquivos quando nao ha lancamentos nao
                            transmitir para Hering (Odair)

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               04/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               16/01/2001 - Mostrar no extrato de conta corrente as taxas de
                            juros utilizadas. (Eduardo).

               27/06/2001 - Gravar dados da 3030 (Margarete).

               29/08/2001 - Identificar os depositos da cooperativa (Margarete)

               02/08/2004 - Alterar diretorio do win12 (Margarete).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               01/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

               30/10/2008 - Alteracao CDEMPRES (Diego).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               13/04/2011 - Alterado da conta 730000 p/ 2625500 (Guilherme).

               07/01/2013 - Alterar RETURN por QUIT (David).

               04/02/2013 - Conversao Progress -> Oracle (Alisson - Amcom)

               02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
                            crapass, crapttl, crapjur 
               						 (Adriano - P339).
  


     ............................................................................. */

     DECLARE


     /* Cursores da rotina CRPS019 */

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT crapcop.cdcooper
             ,crapcop.nmrescop
             ,crapcop.nrtelura
             ,crapcop.cdbcoctl
             ,crapcop.cdagectl
             ,crapcop.dsdircop
             ,crapcop.nrctactl
             ,crapcop.cdagedbb
             ,crapcop.cdageitg
             ,crapcop.nrdocnpj
       FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     --Selecionar associados
     CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
       SELECT crapass.nrdconta
             ,crapass.nmprimtl
             ,crapass.vllimcre
             ,crapass.nrcpfcgc
             ,crapass.inpessoa
             ,crapass.cdcooper
             ,crapass.cdagenci
             ,crapass.ROWID
       FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND  ((pr_cdprogra = 'CRPS019' AND crapass.nrdconta <= pr_nrdconta) OR
             (pr_cdprogra = 'CRPS076' AND crapass.nrdconta > pr_nrdconta))
       ORDER BY crapass.nrdconta;

     --Selecionar Historicos
     CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE) IS
       SELECT craphis.cdhistor
             ,craphis.inhistor
             ,craphis.indebcre
             ,craphis.dshistor
       FROM craphis
       WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.tplotmov IN (0,1);

     --Selecionar Taxas
     CURSOR cr_craptax(pr_cdcooper IN craptax.cdcooper%TYPE
                      ,pr_dtmvtolt IN craptax.dtmvtolt%TYPE
                      ,pr_tpdetaxa IN craptax.tpdetaxa%TYPE) IS
       SELECT craptax.dtmvtolt
             ,craptax.txmensal
       FROM craptax
       WHERE craptax.cdcooper = pr_cdcooper
       AND  craptax.dtmvtolt  < pr_dtmvtolt
       AND  craptax.tpdetaxa  = pr_tpdetaxa
       ORDER BY craptax.progress_recid DESC;
     rw_craptax cr_craptax%ROWTYPE;

     --Selecionar Lancamentos
     CURSOR cr_craplcm (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtinic   IN crapdat.dtmvtolt%TYPE
                       ,pr_dtfinal  IN crapdat.dtmvtolt%TYPE
                       ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
        SELECT /*+ INDEX (craplcm craplcm##craplcm2) */
            craplcm.nrdconta
       FROM craplcm, crapass
       WHERE craplcm.cdcooper = pr_cdcooper
       AND   craplcm.dtmvtolt >= pr_dtinic
       AND   craplcm.dtmvtolt < pr_dtfinal
       AND   craplcm.cdhistor <> 289
       AND   craplcm.cdcooper = crapass.cdcooper
       AND   craplcm.nrdconta = crapass.nrdconta
       AND   ((pr_cdprogra = 'CRPS019' AND crapass.nrdconta <= pr_nrdconta) OR
              (pr_cdprogra = 'CRPS076' AND crapass.nrdconta > pr_nrdconta))
       ORDER BY craplcm.nrdconta;

     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     --Tabela de Memoria do Clob de dados
     vr_tab_clob CADA0001.typ_tab_linha;

     --Tabela de Memoria para armazenar cabecalhos
     vr_tab_cabmex CADA0001.typ_tab_char;

     --Tabela de Memoria com Lancamentos
     vr_tab_craplcm CADA0001.typ_tab_grpconta;

     --Tabela de Memoria de Historicos
     vr_tab_craphis CADA0001.typ_tab_craphis;

     --Constantes
     vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= upper(pr_cdprogra);

     --Variaveis Locais
     vr_nmsufixo     VARCHAR2(100);
     vr_typ_saida    VARCHAR2(100);
     vr_caminho      VARCHAR2(1000);
     vr_comando      VARCHAR2(1000);
     vr_nmarquiv     VARCHAR2(1000);
     vr_cfg_regis000 VARCHAR2(1000);
     vr_cfg_regis019 VARCHAR2(1000);
     vr_ctalimite    INTEGER;
     vr_contlinh     INTEGER;
     vr_flgfirst     BOOLEAN;
     vr_regexist     BOOLEAN;
     vr_craptax      BOOLEAN;
     vr_dtmvtolt     DATE;
     vr_dtlimite     DATE;
     vr_dtrefere     DATE;
     vr_lshistor     craptab.dstextab%TYPE;
     vr_dstextab     craptab.dstextab%TYPE;

     --Variaveis Cabecalho MEX
     vr_reg_cabmex01 VARCHAR2(1000);
     vr_reg_cabmex04 VARCHAR2(1000);
     vr_reg_cabmex06 VARCHAR2(1000);
     vr_reg_cabmex09 VARCHAR2(1000);
     vr_reg_cabmex10 VARCHAR2(1000);
     vr_reg_nmmesref VARCHAR2(1000);

     --Variaveis para retorno de erro
     vr_cdcritic        INTEGER:= 0;
     vr_dscritic        VARCHAR2(4000);

     --Variaveis de Excecao
     vr_exc_final       EXCEPTION;
     vr_exc_saida       EXCEPTION;
     vr_exc_fimprg      EXCEPTION;

     --Variaveis de Indice para temp-tables
     vr_index_clob     PLS_INTEGER;
     -- Variavel para armazenar as informacoes em XML
     vr_des_xml        CLOB;

     --Procedure para Inicializar os CLOBs
     PROCEDURE pc_inicializa_clob IS
     BEGIN
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps019.pc_inicializa_clob. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_inicializa_clob;

     --Procedure para Finalizar os CLOBs
     PROCEDURE pc_finaliza_clob IS
     BEGIN
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao finalizar CLOB. Rotina pc_crps019.pc_finaliza_clob. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_finaliza_clob;

     --Procedure para limpar os dados das tabelas de memoria
     PROCEDURE pc_limpa_tabela IS
     BEGIN
       vr_tab_craphis.DELETE;
       vr_tab_clob.DELETE;
       vr_tab_cabmex.DELETE;
       vr_tab_craplcm.DELETE;
     EXCEPTION
       WHEN OTHERS THEN
         --Variavel de erro recebe erro ocorrido
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_crps019.pc_limpa_tabela. '||sqlerrm;
         --Sair do programa
         RAISE vr_exc_saida;
     END pc_limpa_tabela;

     --Escrever no arquivo CLOB
     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
     BEGIN
       --Se foi passada infomacao
       IF pr_des_dados IS NOT NULL THEN
         --Escrever no Clob
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_saida;
     END pc_escreve_xml;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS019
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       /*  Historico de cheques  */
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HSTCHEQUES'
                                               ,pr_tpregist => 0);

       --Se nao encontrou
       IF vr_dstextab IS NOT NULL THEN
         vr_lshistor:= vr_dstextab;
       ELSE
         vr_lshistor:= '999';
       END IF;

       /*  Diretorio no MAINFRAME da CIA HERING  */
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => rw_crapcop.cdcooper
                                               ,pr_cdacesso => 'MICROFILMA'
                                               ,pr_tpregist => 0);

       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 652;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' - CRED-CONFIG-NN-MICROFILMA-000';
         RAISE vr_exc_saida;
       ELSE
         --Configuracao
         vr_cfg_regis000:= vr_dstextab;
       END IF;


       /*  Carrega tabela de indicadores de historicos  */
       FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craphis(rw_craphis.cdhistor).cdhistor:= rw_craphis.cdhistor;
         vr_tab_craphis(rw_craphis.cdhistor).inhistor:= rw_craphis.inhistor;
         vr_tab_craphis(rw_craphis.cdhistor).indebcre:= rw_craphis.indebcre;
         vr_tab_craphis(rw_craphis.cdhistor).dshistor:= gene0002.fn_mask(rw_craphis.cdhistor,'9999')||'-'||
                                                        rw_craphis.dshistor;
       END LOOP;

       --Determinar nome arquivo
       IF vr_cdprogra = 'CRPS019' THEN
         vr_nmarquiv:= 'cradmex1';
       ELSIF vr_cdprogra = 'CRPS076' THEN
         vr_nmarquiv:= 'cradmex2';
       ELSE
         --Critica
         vr_cdcritic:= 0;
         vr_dscritic:= 'O parametro pr_cdprogra deve ser passado como crps019 ou crps076.';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Buscar Diretorio padrao Microfilmagens para a cooperativa
       vr_caminho:= gene0001.fn_diretorio(pr_tpdireto => 'W' --> Usr/Coop/Win12
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'microfilmagem');
       --Se nao encontrou
       IF vr_caminho IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Diretorio padrao de microfilmagem não encontrado!';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Inicializar variaveis
       vr_contlinh:= 0;
       vr_flgfirst:= TRUE;
       vr_regexist:= FALSE;

       --Primeiro dia do mes anterior
       vr_dtmvtolt:= trunc(add_months(rw_crapdat.dtmvtolt,-1),'MM');

       --Data Limite recebe primeiro dia do mes
       vr_dtlimite:= trunc(rw_crapdat.dtmvtolt,'MM');

       --Data Referencia recebe ultimo dia mes anterior
       vr_dtrefere:= last_day(add_months(rw_crapdat.dtmvtolt,-1));

       --Nome Sufixo
       vr_nmsufixo:= '.'|| to_char(vr_dtrefere,'YYYYMM');

       --Juntar nome final arquivo
       vr_nmarquiv:= vr_nmarquiv||vr_nmsufixo;

       --Cabecalho 1
       vr_tab_cabmex(1):= '   EMP     CONTA/DV  TITULAR'|| rpad(' ',13,' ')||
                          'EXTRATO MENSAL DE DEPOSITOS A VISTA' || rpad(' ',50,' ')||
                          'ORDEM';
       --Cabecalho 4
       vr_tab_cabmex(4):= 'DIA HISTORICO            DOCUMENTO LIBER '||
                          'VLR  LANCAMENTO D/C AG. BCX   LOTE'||
                          ' BCO-AGEN-COM-  LOTE -SQCOMP-CTA  ACOLHIDA'||
                          '  TAXA DE JUROS';
       --Cabecalho 6
       vr_tab_cabmex(6):= rpad('-',133,'-');  /* 120 */

       --Cabecalho 9
       vr_tab_cabmex(9):= 'DEPOSITOS FEITOS NO PERIODO';

       --Cabecalho 10
       vr_tab_cabmex(10):= 'DIA BCO AGEN COM            CONTA  CHEQUE T C1 C2 C3'||
                           ' V1 V2 V3          VALOR CMC7';

       --Mes Referencia
       vr_reg_nmmesref:= GENE0001.vr_vet_nmmesano (to_number(to_char(vr_dtmvtolt,'MM'))) ||'/'||
                         to_char(vr_dtmvtolt,'YYYY');

       --Buscar conta limite para execução nos parametros
       vr_ctalimite:= to_number(gene0001.fn_param_sistema('CRED',pr_cdcooper,'CTA_LIMITE_CRPS019'));
       --Se nao Encontrar
       IF vr_ctalimite IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Nao foi encontrado parametro de conta limite para execucao do programa.';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Inicializar Clob
       pc_inicializa_clob;

       /* Encontra data em que foi gerado o craptax */
       OPEN cr_craptax(pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_tpdetaxa => 2);
       FETCH cr_craptax INTO rw_craptax;
       --Marcar se encontrou ou nao
       vr_craptax:= cr_craptax%FOUND;
       --Fechar Cursor
       CLOSE cr_craptax;

       --Carregar tabela de memoria para indicar quais contas possuem lancamentos
       FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_ctalimite
                                    ,pr_dtinic   => vr_dtmvtolt
                                    ,pr_dtfinal  => vr_dtlimite
                                    ,pr_cdprogra => vr_cdprogra) LOOP
         --Inserir dados na temp-table
         vr_tab_craplcm(rw_craplcm.nrdconta).tabcraplcm(1).cdhistor:= 0;
       END LOOP;


       /*  Le cadastro de associados  */
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_ctalimite
                                    ,pr_cdprogra => vr_cdprogra) LOOP
         --Executar rotina geracao informacoes para microfilmagem
         LIMP0001.pc_crps019_i (pr_cdcooper     => pr_cdcooper          --> Codigo Cooperativa
                               ,pr_cdprogra     => vr_cdprogra          --> Nome Programa
                               ,pr_dtmvtolt     => rw_crapdat.dtmvtolt  --> Data movimento
                               ,pr_vr_dtmvtolt  => vr_dtmvtolt          --> Data Inicio Lancamento
                               ,pr_vr_dtlimite  => vr_dtlimite          --> Data Limite
                               ,pr_nrdconta     => rw_crapass.nrdconta  --> Conta Associado
                               ,pr_nmprimtl     => rw_crapass.nmprimtl  --> Nome Associado
                               ,pr_inpessoa     => rw_crapass.inpessoa  --> Indicador Pessoa Fisica/Juridica
                               ,pr_tab_craphis  => vr_tab_craphis       --> Tabela Historicos
                               ,pr_tab_clob     => vr_tab_clob          --> Tabela para os dados
                               ,pr_flgfirst     => vr_flgfirst          --> Indicador primeiro registro
                               ,pr_regexist     => vr_regexist          --> Existe Registro
                               ,pr_contlinh     => vr_contlinh          --> Contador Linha
                               ,pr_nmmesref     => vr_reg_nmmesref      --> Nome mes referencia
                               ,pr_lshistor     => vr_lshistor          --> Lista Historico
                               ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                               ,pr_tab_craplcm  => vr_tab_craplcm       --> Tabela de Memoria com Lancamentos
                               ,pr_craptax      => vr_craptax           --> Indicador possui taxa
                               ,pr_dtmvttax     => rw_craptax.dtmvtolt  --> Data da taxa
                               ,pr_cdcritic     => vr_cdcritic          --> Codigo Erro
                               ,pr_dscritic     => vr_dscritic);        --> Descricao Erro
         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           --levantar Excecao
           RAISE vr_exc_saida;
         END IF;

         --Descarregar tabela a cada 5.000 contas
         IF MOD(cr_crapass%ROWCOUNT,5000) = 0 THEN
           --Buscar primeira linha do Clob
           vr_index_clob:= vr_tab_clob.FIRST;
           WHILE vr_index_clob IS NOT NULL LOOP
             --Gravar tamp-table no Clob
             pc_escreve_xml(pr_des_dados => vr_tab_clob(vr_index_clob));
             --Pegar Proximo registro
             vr_index_clob:= vr_tab_clob.NEXT(vr_index_clob);
           END LOOP;
           --Limpar tabela
           vr_tab_clob.DELETE;
         END IF;
       END LOOP; /*  Fim do FOR EACH da leitura do cadastro de associados  */

       --Buscar primeira linha do Clob para descarregar a tabela toda
       vr_index_clob:= vr_tab_clob.FIRST;
       WHILE vr_index_clob IS NOT NULL LOOP
         --Gravar tamp-table no Clob
         pc_escreve_xml(pr_des_dados => vr_tab_clob(vr_index_clob));
         --Pegar Proximo registro
         vr_index_clob:= vr_tab_clob.NEXT(vr_index_clob);
       END LOOP;

       --Verificar tamanho do Arquivo
       IF dbms_lob.getlength(vr_des_xml) > 0 THEN
         -- Geracao do arquivo
         -- SCTASK0038225 (Yuri - Mouts)
         -- Com a migra��o para vers�o Oracle 12C necess�rio altera��o no procedimento de gerar arquivo
         --Criar o arquivo no diretorio especificado 
         gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml 
                                      ,pr_caminho  => vr_caminho
                                      ,pr_arquivo  => vr_nmarquiv
                                      ,pr_des_erro => vr_dscritic);
         IF vr_dscritic IS NOT NULL THEN
           --levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         -- FIM SCTASK0038225
/*       dbms_xslprocessor.clob2file(vr_des_xml, vr_caminho, vr_nmarquiv ,0);*/
       END IF;

       --Transmitir Arquivo para CIA HERING
       IF pr_flgtrans AND vr_regexist THEN
         /*  Transm. para CIA HERING  */
         --Montar Comando Unix para transmitir
         vr_comando:= 'transmic . '||vr_caminho||'/'||vr_nmarquiv||
                      '  AX/'||upper(vr_cfg_regis000)||'/MICEXT1 '||gene0002.fn_busca_time;
         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;
         --Escrever mensagem log
         vr_cdcritic:= 658;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar Mensagem
         vr_dscritic:= vr_dscritic||' '||vr_caminho||'/'||vr_nmarquiv||' PARA HERING';
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
       END IF;

       --Limpar Memoria alocada pelo Clob
       pc_finaliza_clob;
       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

    EXCEPTION
       WHEN vr_exc_saida THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
         --Limpar Memoria alocada pelo Clob
         pc_finaliza_clob;
         --Zerar tabelas de memoria auxiliar
         pc_limpa_tabela;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         --Limpar Memoria alocada pelo Clob
         pc_finaliza_clob;
         --Zerar tabelas de memoria auxiliar
         pc_limpa_tabela;
     END;
   END pc_limpeza_crps019_crps076;


  /* Gera arquivos de microfilmagem do capital. */
  PROCEDURE pc_crps038_i( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                     ,pr_cdprogra IN crapprg.cdprogra%TYPE   --> Codigo do programa chamador
                     ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                     ,pr_tab_crapass IN CADA0001.typ_tab_crapass --> tabela com informacoes do associado
                     ,pr_tab_craphis IN CADA0001.typ_tab_craphis --> tabela com informacoes do historico
                     ,pr_tab_crappla IN CADA0001.typ_tab_crappla --> tabela com informacoes de planos de capitalizacao
                     ,pr_tab_grpconta IN CADA0001.typ_tab_grpconta --> tabela com informacoes de lancamentos de cotas de capital
                     ,pr_tab_crapttl IN CADA0001.typ_tab_crapttl   --> tabela com informacoes dos titulares da conta
                     ,pr_tab_crapjur IN CADA0001.typ_tab_crapjur   --> tabela com informacoes da pessoa juridica
                     ,pr_tab_crapcot IN CADA0001.typ_tab_crapcot   --> tabela com informacoes das cotas e recursos dos associados
                     ,pr_tab_linha   IN OUT NOCOPY CADA0001.typ_tab_linha --> tabela com conteudo do arquivo
                     ,pr_dtrefere IN DATE                    --> Data de referencia
                     ,pr_cabmex01 IN VARCHAR2                --> cabecalho 01
                     ,pr_cabmex04 IN VARCHAR2                --> cabecalho 04
                     ,pr_contlinh IN OUT NUMBER              --> linha atual
                     ,pr_flgfirst IN OUT BOOLEAN             --> indica se é a primeira chamada da include
                     ,pr_regexist IN OUT BOOLEAN             --> indica se tem registros
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                     ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps038_i  (Antigo: Includes/crps038.i)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Janeiro/94.                         Ultima atualizacao: 03/01/2012

       Dados referentes ao programa:

       Frequencia: Sempre que executado o programa crps038.p ou crps077.p.
       Objetivo  : Gera arquivos de microfilmagem do capital.

       Alteracao : 21/03/95 - Alterado para ajustar o layout para mostrar os
                              lancamentos em  moeda fixa (Odair).

                   23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   23/03/2000 - Tratar arquivos de microfilmagem, transmitindo
                                para Hering somente arquivos com registros (Odair).

                   30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

                   14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   30/10/2008 - Alteracao cdempres (Kbase IT).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   1/12/2010 - (001) Alteraçao de format para x(50)
                               Leonardo Américo (Kbase).

                   03/01/2012 - Ajuste tamanho nr.documento (David).

                   03/02/2014 - Conversao Progress -> Oracle (Edison - AMcom)

    ............................................................................ */

    DECLARE
      -- constantes
      vr_cabmex06 CONSTANT VARCHAR2(112) := rpad('-',112,'-');

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa

      -- Tratamento de erros
      vr_exc_retorna  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- VARIAVEIS -------------------------------
      vr_nrdordem NUMBER;
      vr_cabmex02 VARCHAR2(1000);
      vr_cabmex03 VARCHAR2(1000);
      vr_cabmex05 VARCHAR2(1000);
      vr_lindetal VARCHAR2(1000);
      vr_ddmvtolt VARCHAR2(15);
      vr_dshistor VARCHAR2(100);
      vr_nrdocmto VARCHAR2(100);
      vr_vllanmto VARCHAR2(100);
      vr_vllanmfx VARCHAR2(100);
      vr_indebcre VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_cdbccxlt VARCHAR2(100);
      vr_nrdolote VARCHAR2(100);
      vr_nrctrpla VARCHAR2(100);
      vr_dtinipla VARCHAR2(100);
      vr_indsalto VARCHAR2(1);
      vr_contlinh NUMBER;
      vr_cdempres VARCHAR2(10);
      vr_tamanho    NUMBER := 0;
      vr_nrdconta NUMBER;
      --indice da tabela temporaria dos planos de capitalizacao
      vr_indcrappla VARCHAR2(100);
      --indice da tabela temporaria de lancamentos de cotas de capital
      vr_indcraplct VARCHAR2(100);
      --indice da tabela temporaria de titulares da conta
      vr_indcrapttl VARCHAR2(100);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Procedure que armazena a linha na tabela temporaria
      PROCEDURE pc_escreve_linha(pr_linha IN VARCHAR2) IS
      BEGIN
        --se a tabela não possuir registros, inicializa com registro em branco
        IF pr_tab_linha.count = 0 THEN
          --inicializa com um registro em branco
          pr_tab_linha(pr_tab_linha.count + 1) := '';
        END IF;

        --calcula o tamanho final da string
        vr_tamanho := length(pr_tab_linha(pr_tab_linha.count)) + length(pr_linha);
        -- se o tamanho ultrapassar o limite da variavel, gera novo registro na tabela temporaria
        IF vr_tamanho > 32000 THEN
          --inicia novo registro na tabela temporaria
          pr_tab_linha(pr_tab_linha.count + 1) := pr_linha;
        ELSE
          --adiciona o conteudo na linha atual do procesamento
          pr_tab_linha(pr_tab_linha.count) := pr_tab_linha(pr_tab_linha.count)||pr_linha;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          --gerando a critica
          vr_dscritic := 'Erro no procedimento pc_crps038_i.pc_escreve_linha. Conta: '||pr_tab_crapass(pr_tab_crapass.first).nrdconta||'. '||SQLERRM;
          --retorna ao programa principal
          RAISE vr_exc_retorna;
      END;

      -- procedure para gerar os cabecalhos 1,3,4,5,6,7
      PROCEDURE pc_gera_cabecalho_1( pr_indsalto IN VARCHAR2
                                    ,pr_linha IN VARCHAR2) IS
      BEGIN
        /* ..........................................................................
           Programas: pc_gera_cabecalho_1 (Antigo: Includes/crps038_1.i)
                                          (Antigo: Includes/crps038_3.i)
                                          (Antigo: Includes/crps038_4.i)
                                          (Antigo: Includes/crps038_5.i)
                                          (Antigo: Includes/crps038_6.i)
                                          (Antigo: Includes/crps038_7.i)
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Deborah/Edson
           Data    : Outubro/92.                         Ultima atualizacao: 08/12/93

           Dados referentes ao programa:

           Frequencia: Sempre que executado o programa crps038.p.
           Objetivo  : Gera cabecalho numero 1,3,4,5,6,7.
        ............................................................................. */
        BEGIN
          -- gera nova linha no clob com quebra de linha
          pc_escreve_linha(pr_indsalto || rpad(pr_linha,132,' ') || chr(13));
        EXCEPTION
          WHEN OTHERS THEN
            --gerando a critica
            vr_dscritic := 'Erro no procedimento pc_crps038_i.pc_gera_cabecalho_1. Conta: '||pr_tab_crapass(pr_tab_crapass.first).nrdconta||'. '||SQLERRM;
            --retorna ao programa principal
            RAISE vr_exc_retorna;
        END;
      END pc_gera_cabecalho_1;

      -- procedure para gerar cabecalho numero 2.
      PROCEDURE pc_gera_cabecalho_2( pr_indsalto  IN VARCHAR2
                                    ,pr_linha     IN VARCHAR2
                                    ,pr_nrdordem  IN OUT NUMBER) IS
      BEGIN
        /* ..........................................................................
           Programa: pc_gera_cabecalho_2 (Antigo: Includes/crps038_2.i)
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Deborah/Edson
           Data    : Outubro/92.                         Ultima atualizacao: 08/12/93

           Dados referentes ao programa:

           Frequencia: Sempre que executado o programa crps038.p.
           Objetivo  : Gera cabecalho numero 2.
        ............................................................................. */
        BEGIN
          -- incrementando a ordem
          pr_nrdordem := nvl(pr_nrdordem,0) + 1;
          -- gera nova linha no clob com quebra de linha
          pc_escreve_linha(pr_indsalto || rpad(pr_linha || to_char(pr_nrdordem,'fm999G999') ,132,' ') || chr(13));
          -- retornando o contador com o valor atualizado
        EXCEPTION
          WHEN OTHERS THEN
            --gerando a critica
            vr_dscritic := 'Erro no procedimento pc_crps038_i.pc_gera_cabecalho_2. Conta: '||pr_tab_crapass(pr_tab_crapass.first).nrdconta||'. '||SQLERRM;
            --retorna ao programa principal
            RAISE vr_exc_retorna;
        END;
      END pc_gera_cabecalho_2;

    BEGIN
      --se é a primeira chamada do procedimento
      IF pr_flgfirst THEN
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS038_I'
                                  ,pr_action => 'PC_'||pr_cdprogra);
      END IF;

      -- inicializando as variaveis
      vr_contlinh := pr_contlinh;
      vr_cdempres := '11';
      vr_nrdconta := pr_nrdconta;

      --se o associado nao estiver na tabela temporaria, aborta a execucao
      IF NOT pr_tab_crapass.EXISTS(vr_nrdconta) THEN
        vr_dscritic := 'Associado nao localizado na tabela temporaria.';
        -- volta para o programa principal
        RAISE vr_exc_retorna;
      END IF;

      -- Se não existir lancamentos de cotas de capital para o associado
      -- volta para o programa principal
      IF NOT pr_tab_grpconta.EXISTS(vr_nrdconta) THEN
        -- volta para o programa principal
        RAISE vr_exc_retorna;
      END IF;

      -- se não encontrou cotas de capital, retorna o processamento ao programa chamador
      pr_regexist := TRUE;

      --verifica informacoes referentes a cotas e recursos do associado
      --se não existir informacoes de cotas e recursos
      --gera critica  e aborta o processamento
      IF NOT pr_tab_crapcot.EXISTS(vr_nrdconta) THEN
        --169 - Associado sem registro de cotas!!! - Erro do sistema!!!!
        vr_cdcritic := 169;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- retorna ao programa chamador para tratar a excecao
        RAISE vr_exc_retorna;
      END IF;

      -- se o asociado é pessoa fisica
      IF pr_tab_crapass(vr_nrdconta).inpessoa = 1 THEN
        --seleciona os titulares da conta que possuem a
        --sequencia do titular = 1
        -- se encontrar informacao, associa o codigo da empresa
        vr_indcrapttl := lpad(vr_nrdconta,10,'0');
        IF pr_tab_crapttl.exists(vr_indcrapttl) THEN
          vr_cdempres := pr_tab_crapttl(vr_indcrapttl).cdempres;
        END IF;
      ELSE
        -- se localizar a pessoa juridica, associa o codigo da empresa
        IF pr_tab_crapjur.exists(vr_nrdconta) THEN
          vr_cdempres := pr_tab_crapjur(vr_nrdconta).cdempres;
        END IF;
      END IF;

      --inicializando o contador
      vr_nrdordem := 0;
      --montando o cabecalho 2
      vr_cabmex02 := ' ' ||
                     lpad(vr_cdempres,5,'0') ||
                     '    ' ||
                     gene0002.fn_mask(vr_nrdconta,'z.zzz.zzz.z') ||
                     '   ' ||
                     rpad(pr_tab_crapass(vr_nrdconta).nmprimtl,50,' ') ||
                     '     ' ||
                     'ANO REF. ' ||
                     to_char(pr_dtrefere,'YYYY') ||
                     '                ';
      --montando o cabecalho 3
      vr_cabmex03 := rpad(' ',11,' ') ||
                     'SALDO ANTERIOR: EM VALOR:  ' ||
                     to_char(nvl(pr_tab_crapcot(vr_nrdconta).vlcotext,0),'99999G999G990D00mi')   ||
                     'MFX: ' ||
                     to_char(nvl(pr_tab_crapcot(vr_nrdconta).qtextmfx,0),'999G999G999G990D0000mi') ||
                     rpad(' ',29,' ');
      --montando o cabecalho 5
      vr_cabmex05 := rpad(' ',12,' ') ||
                     'SALDO ATUAL: EM VALOR:    '||
                     to_char(nvl(pr_tab_crapcot(vr_nrdconta).vlcotant,0),'99999G999G990D00mi')||
                     'MFX: ' ||
                     to_char(nvl(pr_tab_crapcot(vr_nrdconta).qtantmfx,0),'999G999G999G990D0000mi') ||
                     rpad(' ',29,' ');


      -- verifica se eh a primeira chamada do procedimento
      IF pr_flgfirst THEN
        -- muda para false para não entrar mais nessa condicao nas proximas chamadas
        pr_flgfirst := FALSE;
        -- inicializa a variavel indicando inicio do arquivo
        vr_indsalto := '+';
      ELSE
        -- se tem mais de 77 linhas, inicia uma nova pagina
        IF vr_contlinh > 77 THEN
          --inicaliza a variavel indicando totalizador de página
          vr_indsalto := '1';
          --inicializa o contador de linhas
          vr_contlinh := 0;
        ELSE
          --inicializa a variavel indicando cabecalho de colunas
          vr_indsalto := '0';
          vr_contlinh := nvl(vr_contlinh,0) + 1;
        END IF;
      END IF;

      /*  Imprime cabecalho 1 (reg_cabmex01) */
      pc_gera_cabecalho_1( pr_indsalto => vr_indsalto
                          ,pr_linha    => pr_cabmex01);

      /*  Imprime cabecalho 2 (reg_cabmex02) */
      pc_gera_cabecalho_2( pr_indsalto => ' '
                          ,pr_linha    => vr_cabmex02
                          ,pr_nrdordem => vr_nrdordem);

      /*  Imprime cabecalho 3 (reg_cabmex03) */
      pc_gera_cabecalho_1( pr_indsalto => ' '
                          ,pr_linha    => vr_cabmex03);

      /*  Imprime cabecalho 4 (reg_cabmex04) */
      pc_gera_cabecalho_1( pr_indsalto => '0'
                          ,pr_linha    => pr_cabmex04);

      -- incrementando a contagem de linhas em 5 posicoes
      vr_contlinh := nvl(vr_contlinh,0) + 5;

      --seleciona os lançamentos de cotas de capital do associado
      --que foram efetuados no ano da data de referencia
      --posiciona no primeiro registro da tabela
      vr_indcraplct := pr_tab_grpconta(vr_nrdconta).tabcraplct.first;
      LOOP
        EXIT WHEN vr_indcraplct IS NULL;
        --verifica se o numero do contrato do plano é maior que zero
        IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrctrpla > 0 THEN

          -- monta o indice de pesquisa do plano de capitalizacao
          vr_indcrappla := lpad(pr_cdcooper,10,'0')||
                           lpad(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrdconta,10,'0')||
                           '00001'||
                           lpad(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrctrpla,10,'0');

          --seleciona planos de capitalizacao do associado pelo numero
          --do contrato e tipo do plano
          IF pr_tab_crappla.EXISTS(vr_indcrappla) THEN
            -- recebe a data de inicio do plano
            vr_dtinipla := to_char(pr_tab_crappla(vr_indcrappla).dtinipla,'DD/MM/YYYY');
          ELSE
            --limpa a variavel
            vr_dtinipla := '';
          END IF;

          -- recebe o numero do contrato
          vr_nrctrpla := to_char(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrctrpla,'fm999G999');
        ELSE
          -- limpa as variaveis
          vr_dtinipla := '';
          vr_nrctrpla := '';
        END IF;--IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrctrpla > 0 THEN

        -- busca o dia e o mes da data do movimento
        vr_ddmvtolt := to_char(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).dtmvtolt,'DD/MM');

        --verifica se o historico possui descricao
        IF pr_tab_craphis(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdhistor).dshistor IS NULL THEN
          -- preenche a descricao com o codigo do historico
          vr_dshistor := gene0002.fn_mask(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdhistor,'zzz9') || ' - ';
        ELSE
          --preenche a descricao com a descricao do historico
          vr_dshistor := pr_tab_craphis(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdhistor).dshistor;
        END IF;

        -- formatando o numero do documento
        vr_nrdocmto := gene0002.fn_mask(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrdocmto,'zzz.zzz.zz9');
        --formatando o valor do lancamento
        vr_vllanmto := to_char(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).vllanmto,'fm999G999G990D00');
        --formatando o valor do lancamento em moeda fixa
        vr_vllanmfx := to_char(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).qtlanmfx,'fm999G999G999G990D0000');

        -- se o codigo do historico for 66
        IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdhistor IN (66) THEN
          --atribui * ao campo que indica se eh debito ou credito
          vr_indebcre := '*';
        ELSE
          --senão, busca o indicador de debito/credito na tabela de historicos
          vr_indebcre := pr_tab_craphis(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdhistor).indebcre;
        END IF;
        --formatando o codigo da agencia
        vr_cdagenci := gene0002.fn_mask(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdagenci,'zz9');
        --formatando o codigo do banco/caixa
        vr_cdbccxlt := gene0002.fn_mask(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).cdbccxlt,'zz9');
        --formatando o numero do lote
        vr_nrdolote := gene0002.fn_mask(pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).nrdolote,'zzzzz9');

        --montando a linha de detalhe
        vr_lindetal := vr_ddmvtolt || ' ' ||
                       rpad(vr_dshistor,20,' ') || ' ' ||
                       lpad(vr_nrdocmto,11,' ') || ' ' ||
                       lpad(vr_vllanmto,16,' ') || '  ' ||
                       vr_indebcre || '   ' ||
                       lpad(vr_vllanmfx,20,' ') || ' ' ||
                       lpad(vr_cdagenci,3,' ') || ' ' ||
                       lpad(vr_cdbccxlt,3,' ') || ' ' ||
                       lpad(vr_nrdolote,6,' ') || ' ' ||
                       lpad(vr_nrctrpla,7,' ') || ' ' ||
                       lpad(vr_dtinipla,10,' ');

        --se estiver na linha 84, efetua a quebra de pagina
        IF vr_contlinh = 84 THEN
          -- se eh o ultimo lancamento da conta, finaliza e totaliza a pagina
          IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).sqnrdcta = pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).qtnrdcta THEN
            --indica que eh totalizador de página
            vr_indsalto := '1';
            /* cabecalho 1   */
            pc_gera_cabecalho_1( pr_indsalto => vr_indsalto
                                ,pr_linha    => pr_cabmex01);
            /* cabecalho 2   */
            pc_gera_cabecalho_2( pr_indsalto => ' '
                                ,pr_linha    => vr_cabmex02
                                ,pr_nrdordem => vr_nrdordem);
            /* cabecalho 4   */
            pc_gera_cabecalho_1( pr_indsalto => '0'
                                ,pr_linha    => pr_cabmex04);
            /* linha detalhe */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_lindetal);
            /* cabecalho 5   */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_cabmex05);
            /* cabecalho 6   */
            pc_gera_cabecalho_1( pr_indsalto => '0'
                                ,pr_linha    => vr_cabmex06);
            -- reiinicializa o contador de linhas
            vr_contlinh := 8;
            -- volta para o programa chamador
            RAISE vr_exc_retorna;
          ELSE
            --indica que eh totalizador de página
            vr_indsalto := '1';
            /* cabecalho 1   */
            pc_gera_cabecalho_1( pr_indsalto => vr_indsalto
                                ,pr_linha    => pr_cabmex01);
            /* cabecalho 2   */
            pc_gera_cabecalho_2( pr_indsalto => ' '
                                ,pr_linha    => vr_cabmex02
                                ,pr_nrdordem => vr_nrdordem);
            /* cabecalho 4   */
            pc_gera_cabecalho_1( pr_indsalto => '0'
                                ,pr_linha    => pr_cabmex04);
            /* linha detalhe */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_lindetal);
            -- reiinicializa o contador de linhas
            vr_contlinh := 5;
          END IF;
        ELSE--IF vr_contlinh = 84 THEN
           --se eh o ultimo registro da conta
          IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).sqnrdcta = pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).qtnrdcta THEN
            /* linha detalhe */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_lindetal);
            --incrementa o contador de linhas em uma posicao
            vr_contlinh := nvl(vr_contlinh,0) + 1;

            --se estiver na linha 84, efetua a quebra de pagina
            IF vr_contlinh = 84 THEN
              --indica que eh totalizador de página
              vr_indsalto := '1';
              /* cabecalho 1   */
              pc_gera_cabecalho_1( pr_indsalto => vr_indsalto
                                  ,pr_linha    => pr_cabmex01);
              /* cabecalho 2   */
              pc_gera_cabecalho_2( pr_indsalto => ' '
                                  ,pr_linha    => vr_cabmex02
                                  ,pr_nrdordem => vr_nrdordem);
              /* cabecalho 5   */
              pc_gera_cabecalho_1( pr_indsalto => ' '
                                  ,pr_linha    => vr_cabmex05);
              /* cabecalho 6   */
              pc_gera_cabecalho_1( pr_indsalto => '0'
                                  ,pr_linha    => vr_cabmex06);
              --reinicializa o contador de linhas
              vr_contlinh := 5;
              --volta ao programa chamador
              RAISE vr_exc_retorna;
            END IF;

            /* cabecalho 5   */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_cabmex05);

            -- incrementando o contador de linhas
            vr_contlinh := nvl(vr_contlinh,0) + 1;

            --se a quantidade de linhas for maior que 82 volta para o programa chamador
            IF vr_contlinh > 82 THEN
              -- volta para o programa chamador
              RAISE vr_exc_retorna;
            END IF;
            /* cabecalho 6   */
            pc_gera_cabecalho_1( pr_indsalto => '0'
                                ,pr_linha    => vr_cabmex06);
            --incrementa o contador de linhas e duas posicoes
            vr_contlinh := nvl(vr_contlinh,0) + 2;
            -- volta para o programa chamador
            RAISE vr_exc_retorna;
          ELSE --IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).qtde_reg = cr_craplct%ROWCOUNT THEN
            /* linha detalhe */
            pc_gera_cabecalho_1( pr_indsalto => ' '
                                ,pr_linha    => vr_lindetal);
            --incrementa o contador de linhas
            vr_contlinh := nvl(vr_contlinh,0) + 1;
          END IF;--IF pr_tab_grpconta(vr_nrdconta).tabcraplct(vr_indcraplct).qtde_reg = cr_craplct%ROWCOUNT THEN
        END IF;--IF vr_contlinh = 84 THEN
        -- vai para o proximo registro da temp table
        vr_indcraplct := pr_tab_grpconta(vr_nrdconta).tabcraplct.next(vr_indcraplct);
      END LOOP;--OPEN cr_craplct ( pr_cdcooper => pr_cdcooper

      -- retornando ao programa chamador
      RAISE vr_exc_retorna;

    --controle de excecoes
    EXCEPTION
      --exception para controlar o retorno dos parametros
      WHEN vr_exc_retorna THEN
        --retorna a linha atual
        pr_contlinh := vr_contlinh;
        --retorna o codigo da critica
        pr_cdcritic := vr_cdcritic;
        --retorna a descricao da critica
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        --retorna o erro ao programa chamador
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado no procedimento pc_crps038_i. Conta: '||vr_nrdconta||'. '||SQLERRM;
    END;--BEGIN
  END pc_crps038_i;

  /* Rotina de Limpeza de Microfilmagem */
  PROCEDURE pc_limpeza_crps038_crps077 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_cdprogra IN VARCHAR2                --> Nome Programa da Execucao crps019/crps076
                                       ,pr_flgtrans IN BOOLEAN                 --> Indica se o arquivo deve ser transmitido
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN
    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE := pr_cdprogra;

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
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- cadastro de associados com a conta maior
      -- que o parametro de conta que foi informado
      CURSOR cr_crapass( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.inpessoa
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta > pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS077'
        UNION
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.inpessoa
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta <= pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS038'
      ORDER BY 1, 2;

      -- cadastro de historicos
      CURSOR cr_craphis( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
              ,craphis.dshistor
              ,craphis.indebcre
              ,craphis.inhistor
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper
        AND    craphis.tplotmov IN (0,2,3,10);--tipo do lote

      --seleciona planos de capitalizacao do associado pelo numero
      --do contrato e tipo do plano
      CURSOR cr_crappla ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        --crps077
        SELECT  crappla.cdcooper
               ,crappla.nrdconta
               ,crappla.tpdplano
               ,crappla.nrctrpla
               ,crappla.dtinipla
        FROM   crappla
        WHERE  crappla.cdcooper = pr_cdcooper
        AND    crappla.nrdconta > pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS077'
        UNION
        --CRPS038
        SELECT  crappla.cdcooper
               ,crappla.nrdconta
               ,crappla.tpdplano
               ,crappla.nrctrpla
               ,crappla.dtinipla
        FROM   crappla
        WHERE  crappla.cdcooper = pr_cdcooper
        AND    crappla.nrdconta <= pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS038';



      --seleciona os lançamentos de cotas de capital do associado
      -- que foram efetuados no ano da data de referencia
      CURSOR cr_craplct ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtrefere IN DATE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        --crps038
        SELECT craplct.cdcooper
              ,craplct.nrctrpla
              ,craplct.nrdconta
              ,craplct.dtmvtolt
              ,craplct.nrdocmto
              ,craplct.vllanmto
              ,craplct.qtlanmfx
              ,craplct.cdhistor
              ,craplct.cdagenci
              ,craplct.cdbccxlt
              ,craplct.nrdolote
              ,row_number() over(PARTITION BY craplct.cdcooper, craplct.nrdconta
                                 ORDER BY craplct.cdcooper, craplct.nrdconta) sqnrdcta
              ,COUNT(*) over(PARTITION BY craplct.nrdconta) qtnrdcta
        FROM   craplct
        WHERE craplct.cdcooper = pr_cdcooper
        AND   trunc(craplct.dtmvtolt,'YEAR') = trunc(pr_dtrefere,'YEAR')
        AND   craplct.nrdconta <= pr_nrdconta
        AND   upper(pr_cdprogra) = 'CRPS038'

        UNION
        --crps077
        SELECT craplct.cdcooper
              ,craplct.nrctrpla
              ,craplct.nrdconta
              ,craplct.dtmvtolt
              ,craplct.nrdocmto
              ,craplct.vllanmto
              ,craplct.qtlanmfx
              ,craplct.cdhistor
              ,craplct.cdagenci
              ,craplct.cdbccxlt
              ,craplct.nrdolote
              ,row_number() over(PARTITION BY craplct.cdcooper, craplct.nrdconta
                                 ORDER BY craplct.cdcooper, craplct.nrdconta) sqnrdcta
              ,COUNT(*) over(PARTITION BY craplct.nrdconta) qtnrdcta
        FROM   craplct
        WHERE craplct.cdcooper = pr_cdcooper
        AND   trunc(craplct.dtmvtolt,'YEAR') = trunc(pr_dtrefere,'YEAR')
        AND   craplct.nrdconta > pr_nrdconta
        AND   upper(pr_cdprogra) = 'CRPS077'
        ORDER BY cdcooper
                ,nrdconta
                ,dtmvtolt
                ,cdhistor
                ,nrdocmto;

      --seleciona os titulares da conta que possuem de acordo
      --com a sequencia do titular
      CURSOR cr_crapttl ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        --crps077
        SELECT crapttl.cdempres
              ,crapttl.nrdconta
              ,crapttl.idseqttl
        FROM   crapttl
        WHERE  crapttl.cdcooper = pr_cdcooper
          AND  crapttl.idseqttl = 1
          AND  crapttl.nrdconta > pr_nrdconta
          AND  upper(pr_cdprogra) = 'CRPS077'
        UNION
        --crps038
        SELECT crapttl.cdempres
              ,crapttl.nrdconta
              ,crapttl.idseqttl
        FROM   crapttl
        WHERE  crapttl.cdcooper = pr_cdcooper
          AND  crapttl.idseqttl = 1
          AND  crapttl.nrdconta <= pr_nrdconta
          AND  upper(pr_cdprogra) = 'CRPS038';


      -- seleciona o cadastro de pessoa juridica
      CURSOR cr_crapjur ( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapjur.cdempres
              ,crapjur.nrdconta
        FROM   crapjur
        WHERE crapjur.cdcooper = pr_cdcooper;

      -- informacoes referentes a cotas e recursos do associado
      CURSOR cr_crapcot ( pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapcot.nrdconta
              ,crapcot.vlcotext
              ,crapcot.qtextmfx
              ,crapcot.vlcotant
              ,crapcot.qtantmfx
        FROM   crapcot
        WHERE  crapcot.cdcooper = pr_cdcooper
        AND    crapcot.nrdconta > pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS077'
        UNION
        SELECT crapcot.nrdconta
              ,crapcot.vlcotext
              ,crapcot.qtextmfx
              ,crapcot.vlcotant
              ,crapcot.qtantmfx
        FROM   crapcot
        WHERE  crapcot.cdcooper = pr_cdcooper
        AND    crapcot.nrdconta <= pr_nrdconta
        AND    upper(pr_cdprogra) = 'CRPS038';


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --tabela temporaria de historicos
      vr_tab_craphis CADA0001.typ_tab_craphis;

      --tabela temporaria de associados
      vr_tab_crapass CADA0001.typ_tab_crapass;

      --tabela temporaria de planos de capitalização
      vr_tab_crappla cada0001.typ_tab_crappla;

      --tabela temporaria de lancamentos de cotas de capital
      vr_tab_grpconta cada0001.typ_tab_grpconta;

      --tabela temporaria de lancamentos de titulares da conta
      vr_tab_crapttl cada0001.typ_tab_crapttl;

      --tabela temporaria de lancamentos de pessoa juridica
      vr_tab_crapjur cada0001.typ_tab_crapjur;

      --tabela temporaria de cotas e recursos dos associados
      vr_tab_crapcot cada0001.typ_tab_crapcot;

      --Tipo de registro para armazenar texto
      vr_tab_linha cada0001.typ_tab_linha;

      ------------------------------- VARIAVEIS -------------------------------
      vr_nrdconta   NUMBER;
      vr_patcharq   VARCHAR2(500);
      vr_regis000   craptab.dstextab%TYPE;
      vr_cabmex01   VARCHAR2(1000);
      vr_cabmex04   VARCHAR2(1000);
      vr_nmarquiv   VARCHAR2(1000);
      vr_regexist   BOOLEAN;
      vr_flgfirst   BOOLEAN;
      vr_contlinh   NUMBER;
      vr_nmsufixo   VARCHAR2(100);
      vr_dtrefere   DATE;
      vr_comando    VARCHAR2(500);
      vr_typ_saida  VARCHAR2(1000);
      vr_dstextab   craptab.dstextab%TYPE;
      vr_indcraplct VARCHAR2(100);
      vr_contador   NUMBER;
      -- Variável de Controle de XML
      vr_des_clob   CLOB;

      --------------------------- SUBROTINAS INTERNAS --------------------------
      -- procedimento para limpar as tabelas temporarias
      PROCEDURE pc_limpa_temporaria IS
      BEGIN
        --tabela temporaria de historicos
        vr_tab_craphis.delete;
        --tabela temporaria de associados
        vr_tab_crapass.delete;
        --tabela temporaria de planos de capitalização
        vr_tab_crappla.delete;
        --tabela temporaria de cotas de capital
        vr_tab_grpconta.delete;
        --tabela temporaria de titulares da conta
        vr_tab_crapttl.delete;
        --tabela temporaria de pessoa juridica
        vr_tab_crapjur.delete;
        --tabela temporaria de pessoa juridica
        vr_tab_crapcot.delete;
        --tabela que controla o buffer do arquivo
        vr_tab_linha.delete;
      END;
    BEGIN
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- busca o valor do parametro EXELIMPEZA
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'EXELIMPCOT'
                                                ,pr_tpregist => 1);

      -- se nao encontrar o parametro, aborta a execucao
      IF vr_dstextab IS NULL THEN
        -- gera critica 176 - Falta tabela de execucao de limpeza - registro 001
        vr_cdcritic := 176;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      -- se o parametro é diferente de zero, indica que o processo já foi executado
      IF vr_dstextab <> '0' THEN
        -- gera critica 177 - Limpeza ja rodou este mes.
        vr_cdcritic := 177;
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      /*  Diretorio no MAINFRAME da CIA HERING  */
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'CONFIG'
                                                ,pr_cdempres => pr_cdcooper
                                                ,pr_cdacesso => 'MICROFILMA'
                                                ,pr_tpregist => 0);

      -- se nao encontrar o parametro, aborta a execucao
      IF vr_dstextab IS NULL THEN
        -- gera critica 652 - 652 - Falta tabela de configuracao da cooperativa
        vr_cdcritic := 652;
        -- busca descricao da critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' - CRED-CONFIG-NN-MICROFILMA-000';
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      vr_regis000 := vr_dstextab;

      -- busca a conta a partir da qual serao gerados os arquivos
      vr_nrdconta := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CTA_MINIMA_MICROFILMAGEM');

      -- se nao encontrar o parametro, aborta a execucao
      IF vr_nrdconta IS NULL THEN
        -- gera critica
        vr_cdcritic := 0;
        -- busca descricao da critica
        vr_dscritic := 'Nao foi localizada a conta do associado a partir da qual deve ser gerado o arquivo';
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      --busca o local onde deve ser gerado o arquivo
      vr_patcharq := gene0001.fn_diretorio( pr_tpdireto => 'W' --> Usr/Coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'microfilmagem');

      --inicializando o contador de linhas
      vr_contlinh := 0;
      --inicializando o indicador de primeiro registro
      vr_flgfirst := TRUE;
      --inicializando o indicador de existencia de registros
      vr_regexist := FALSE;
      --calculando a data de referencia
      vr_dtrefere := TRUNC(rw_crapdat.dtmvtolt,'YEAR')-1;
      --gerando o sufixo do arquivo
      vr_nmsufixo := '.' || to_char(vr_dtrefere,'YYYY');

      -- configura o nome do arquivo conforme a chamada do programa
      IF upper(vr_cdprogra) = 'CRPS077' THEN
        --nome do arquivo
        vr_nmarquiv := 'cradmct2';
      ELSIF (upper(vr_cdprogra) = 'CRPS038') THEN
        --nome do arquivo
        vr_nmarquiv := 'cradmct1';
      END IF;

      --inicializando a linha de cabecalho 01
      vr_cabmex01 := '   EMP       CONTA/DV   TITULAR' || rpad(' ',18,' ') ||
                     'EXTRATO ANUAL DE CAPITAL' || rpad(' ',37,' ') || 'ORDEM';
      --inicializando a linha do cabecalho 04
      vr_cabmex04 := 'DD/MM HISTORICO              DOCUMENTO      ' ||
                     'LANCAMENTOS D/C           LANCAMENTOS AG. BCX   LOTE ' ||
                     '  PLANO     INICIO';

      --limpa todas as tabelas temporarias utilizadas pelo programa
      pc_limpa_temporaria;

      -- carrega a tabela temporaria de historicos
      FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).dshistor := gene0002.fn_mask(rw_craphis.cdhistor,'zzz9') ||
                                                        ' - ' || rw_craphis.dshistor;
        vr_tab_craphis(rw_craphis.cdhistor).indebcre := rw_craphis.indebcre;
        vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
      END LOOP;

      -- carrega a tabela temporaria de planos de capitalização
      FOR rw_crappla IN cr_crappla(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta) LOOP
        -- carrega a data do inicio do plano na tabela temporaria
        vr_tab_crappla( lpad(rw_crappla.cdcooper,10,'0')||
                        lpad(rw_crappla.nrdconta,10,'0')||
                        lpad(rw_crappla.tpdplano, 5,'0')||
                        lpad(rw_crappla.nrctrpla,10,'0')).dtinipla := rw_crappla.dtinipla;
      END LOOP;

      -- carrega a tabela temporaria de lancamentos de cotas de capital
      FOR rw_craplct IN cr_craplct( pr_cdcooper => pr_cdcooper
                                   ,pr_dtrefere => vr_dtrefere
                                   ,pr_nrdconta => vr_nrdconta) LOOP

        -- gera o indice da tabela de lancamentos de cotas de capital
        vr_indcraplct := lpad(rw_craplct.nrdconta,10,'0')||
                         lpad(rw_craplct.sqnrdcta, 5,'0');

        -- carrega a tabela temporaria de lancamentos de cotas de capital
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).cdcooper := rw_craplct.cdcooper;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).nrctrpla := rw_craplct.nrctrpla;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).nrdconta := rw_craplct.nrdconta;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).dtmvtolt := rw_craplct.dtmvtolt;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).nrdocmto := rw_craplct.nrdocmto;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).vllanmto := rw_craplct.vllanmto;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).qtlanmfx := rw_craplct.qtlanmfx;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).cdhistor := rw_craplct.cdhistor;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).cdagenci := rw_craplct.cdagenci;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).cdbccxlt := rw_craplct.cdbccxlt;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).nrdolote := rw_craplct.nrdolote;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).sqnrdcta := rw_craplct.sqnrdcta;
        vr_tab_grpconta(rw_craplct.nrdconta).tabcraplct(vr_indcraplct).qtnrdcta := rw_craplct.qtnrdcta;
      END LOOP;

      -- carrega a tabela temporaria de titulares da conta
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta) LOOP
        -- carrega o codigo da empresa
        vr_tab_crapttl(lpad(rw_crapttl.nrdconta,10,'0')).cdempres := rw_crapttl.cdempres;
      END LOOP;

      -- carrega a tabela temporaria de pessoa juridica
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper => pr_cdcooper) LOOP
        -- carrega o codigo da empresa
        vr_tab_crapjur(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;

      -- carrega a tabela temporaria de cotas e recursos dos asscciados
      FOR rw_crapcot IN cr_crapcot(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta) LOOP
        -- carrega o codigo da empresa
        vr_tab_crapcot(rw_crapcot.nrdconta).vlcotext := rw_crapcot.vlcotext;
        vr_tab_crapcot(rw_crapcot.nrdconta).qtextmfx := rw_crapcot.qtextmfx;
        vr_tab_crapcot(rw_crapcot.nrdconta).vlcotant := rw_crapcot.vlcotant;
        vr_tab_crapcot(rw_crapcot.nrdconta).qtantmfx := rw_crapcot.qtantmfx;
      END LOOP;

      -- Inicializa o CLOB
      dbms_lob.createtemporary(vr_des_clob, TRUE);
      dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);

      /*  Le cadastro de associados  */
      FOR rw_crapass IN cr_crapass( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta)
      LOOP
        vr_contador := nvl(vr_contador,0)+1;

        --carrega as informacoes do associado
        vr_tab_crapass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;

        -- chamando a include que controla a geracao das linhas do arquivo
        pc_crps038_i( pr_cdcooper    => pr_cdcooper    --> Cooperativa solicitada
                     ,pr_cdprogra    => vr_cdprogra    --> Codigo do programa chamador
                     ,pr_nrdconta    => rw_crapass.nrdconta --> Conta do associado
                     ,pr_tab_crapass => vr_tab_crapass --> tabela com informacoes do associado
                     ,pr_tab_craphis => vr_tab_craphis --> tabela com informacoes do historico
                     ,pr_tab_crappla => vr_tab_crappla --> tabela com informacoes de planos de capitalizacao
                     ,pr_tab_grpconta => vr_tab_grpconta --> tabela com informacoes dos lançamentos de cotas
                     ,pr_tab_crapttl => vr_tab_crapttl --> tabela com informacoes dos titulares da conta
                     ,pr_tab_crapjur => vr_tab_crapjur --> tabela com informacoes da pessoa juridica
                     ,pr_tab_crapcot => vr_tab_crapcot --> tabela com informacoes das cotas e recursos dos associados
                     ,pr_tab_linha   => vr_tab_linha   --> tabela com conteudo do arquivo
                     ,pr_dtrefere    => vr_dtrefere    --> Data de referencia
                     ,pr_cabmex01    => vr_cabmex01    --> cabecalho 01
                     ,pr_cabmex04    => vr_cabmex04    --> cabecalho 04
                     ,pr_contlinh    => vr_contlinh    --> linha atual
                     ,pr_flgfirst    => vr_flgfirst    --> indica se é a primeira chamada da include
                     ,pr_regexist    => vr_regexist    --> indica se tem registros
                     ,pr_cdcritic    => vr_cdcritic    --> Critica encontrada
                     ,pr_dscritic    => vr_dscritic);  --> Texto de erro/critica encontrada

        --se retornar algum erro finaliza o programa
        IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
          --finaliza a execucao do programa
          RAISE vr_exc_saida;
        END IF;

        --para melhorar a performance, a cada 100 linhas esvazia a tabela
        --temporaria e grava no clob
        IF vr_tab_linha.count > 100 THEN
          --descarrega a tabela temporaria no clob
          FOR vr_indice IN vr_tab_linha.first .. vr_tab_linha.count LOOP
            --escreve no clob
            dbms_lob.writeappend(vr_des_clob, length(vr_tab_linha(vr_indice)), vr_tab_linha(vr_indice));
          END LOOP;
          -- limpa a tabela temporaria
          vr_tab_linha.delete;
        END IF;

      END LOOP;--FOR rw_crapass IN cr_crapass( pr_cdcooper => pr_cdcooper

      --descarrega a tabela temporaria no clob
      FOR vr_indice IN vr_tab_linha.first .. vr_tab_linha.count LOOP
        --escreve no clob
        dbms_lob.writeappend(vr_des_clob, length(vr_tab_linha(vr_indice)), vr_tab_linha(vr_indice));
      END LOOP;

      -- SCTASK0038225 (Yuri - Mouts)
      -- Com a migra��o para vers�o Oracle 12C necess�rio altera��o no procedimento de gerar arquivo
      --Criar o arquivo no diretorio especificado
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_clob
                                   ,pr_caminho  => vr_patcharq
                                   ,pr_arquivo  => vr_nmarquiv
                                   ,pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        --levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      -- FIM SCTASK0038225
/*    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_clob, vr_patcharq, vr_nmarquiv || vr_nmsufixo, 0);*/

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_clob);
      dbms_lob.freetemporary(vr_des_clob);

      IF upper(vr_cdprogra) = 'CRPS077' THEN
        -- atualizando a tabela de parametros
        BEGIN
          UPDATE craptab
             SET craptab.dstextab = '1'
          WHERE  craptab.cdcooper = pr_cdcooper
          AND    craptab.nmsistem = 'CRED'
          AND    craptab.tptabela = 'GENERI'
          AND    craptab.cdempres = 0
          AND    craptab.cdacesso = 'EXELIMPCOT'
          AND    craptab.tpregist = 1;

        EXCEPTION
          WHEN OTHERS THEN
            -- gerando a descricao do erro
            vr_dscritic := 'Erro ao atualizar o parametro EXELIMPCOT. '||SQLERRM;
            -- finalizando a execucao do programa
            RAISE vr_exc_saida;
        END;
        -- se nao atualizar nenhuma linha gera critica
        IF SQL%ROWCOUNT = 0 THEN
          -- gera critica 176 - Falta tabela de execucao de limpeza - registro 001
          vr_cdcritic := 176;
          -- finaliza a execucao
          RAISE vr_exc_saida;
        END IF;
      END IF;

      --transmitindo o arquivo para a Hering
      IF pr_flgtrans AND vr_regexist THEN
        --  Transm. para CIA HERING
        vr_comando := 'transmic . ' || vr_patcharq ||'/'|| vr_nmarquiv || vr_nmsufixo || ' AX/' ||
                     upper(vr_regis000) || '/MICCOT2 ' || gene0002.fn_busca_time;

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
         -- retornando ao programa chamador
         RAISE vr_exc_saida;
        END IF;

        -- gera critica
        vr_cdcritic := 658;
        -- busca descricao da critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                       ' ' || vr_nmarquiv + vr_nmsufixo ||' PARA HERING';

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );

        -- limpando as variáveis de critica
        vr_cdcritic := 0;
        vr_dscritic := NULL;
      END IF;

      --limpa todas as tabelas temporarias utilizadas pelo programa
      pc_limpa_temporaria;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
    END;
  END pc_limpeza_crps038_crps077;
  
   /* Rotina responsavel por calcular a quantidade de anos e meses entre as datas */
   PROCEDURE pc_limpeza_microfilmagem (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                      ,pr_flgresta IN PLS_INTEGER               --> Flag padrao para utilizacao de restart
                                      ,pr_cdprogra IN VARCHAR2                  --> Nome Programa da Execucao crps019/crps076
                                      ,pr_flgtrans IN BOOLEAN                   --> Transmite ou nao o arquivo
                                      ,pr_stprogra OUT PLS_INTEGER              --> Saida de termino da execucao
                                      ,pr_infimsol OUT PLS_INTEGER              --> Saida de termino da solicitacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Codigo da Critica
                                      ,pr_dscritic OUT VARCHAR2) IS             --> Descricao da Critica
   BEGIN
   /* ..........................................................................

     Programa: pc_limpeza_microfilmagem
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Fevereiro/2014.                        Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Executar a limpeza das microfilmagens

     Alteracoes: 14/02/14 - Desenvolvimento da rotina

  ............................................................................. */
   DECLARE
       --Variaveis Locais
       vr_cdcritic INTEGER;
       vr_dscritic VARCHAR2(4000);

       --Variaveis Excecao
       vr_exc_erro     EXCEPTION;           --> Controle de exception

     BEGIN
       --Inicializar variavel de erro
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       --Verificar programa que deve ser executado
 	     IF upper(pr_cdprogra) IN ('CRPS019','CRPS076') THEN
 	       pc_limpeza_crps019_crps076 (pr_cdcooper => pr_cdcooper         --> Codigo Cooperativa
                                    ,pr_flgresta => pr_flgresta         --> Flag padrao para utilizacao de restart
                                    ,pr_cdprogra => pr_cdprogra         --> Nome Programa da Execucao crps019/crps076
                                    ,pr_flgtrans => pr_flgtrans         --> Transmite ou nao o arquivo
                                    ,pr_stprogra => pr_stprogra         --> Saida de termino da execucao
                                    ,pr_infimsol => pr_infimsol         --> Saida de termino da solicitacao
                                    ,pr_cdcritic => vr_cdcritic         --> Codigo da Critica
                                    ,pr_dscritic => vr_dscritic);       --> Descricao da Critica
		     --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
         END IF;
		   ELSIF upper(pr_cdprogra) IN ('CRPS038','CRPS077') THEN
	       pc_limpeza_crps038_crps077 (pr_cdcooper => pr_cdcooper         --> Codigo Cooperativa
                                    ,pr_flgresta => pr_flgresta         --> Flag padrao para utilizacao de restart
                                    ,pr_cdprogra => pr_cdprogra         --> Nome Programa da Execucao crps038/crps077
                                    ,pr_flgtrans => pr_flgtrans         --> Transmite ou nao o arquivo
                                    ,pr_stprogra => pr_stprogra         --> Saida de termino da execucao
                                    ,pr_infimsol => pr_infimsol         --> Saida de termino da solicitacao
                                    ,pr_cdcritic => vr_cdcritic         --> Codigo da Critica
                                    ,pr_dscritic => vr_dscritic);       --> Descricao da Critica
	    	 --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
         END IF;

       END IF;
     EXCEPTION
	     WHEN vr_exc_erro THEN
	       pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
  	     pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina LIMP0001.pc_limpeza_microfilmagem: ' || SQLERRM;
     END;
   END;

  /* Rotina responsavel em quebrar uma string em quatro linhas, e justifica-las. */
  PROCEDURE pc_quebra_str(pr_dsstring IN  VARCHAR2          --> String que sera quebrada
                         ,pr_qtcolun1 IN  PLS_INTEGER       --> Quantidade de colunas da primeira linha
                         ,pr_qtcolun2 IN  PLS_INTEGER       --> Quantidade de colunas da segunda linha
                         ,pr_qtcolun3 IN  PLS_INTEGER       --> Quantidade de colunas da terceira linha
                         ,pr_qtcolun4 IN  PLS_INTEGER       --> Quantidade de colunas da quarta linha
                         ,pr_dslinha1 OUT VARCHAR2          --> Primeira linha centralizada
                         ,pr_dslinha2 OUT VARCHAR2          --> Segunda linha centralizada
                         ,pr_dslinha3 OUT VARCHAR2          --> Terceira linha centralizada
                         ,pr_dslinha4 OUT VARCHAR2) IS      --> Quarta linha centralizada
/* .............................................................................

   Programa: LIMP0001.pc_quebra_str (fontes/quebra_str.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando/Julio
   Data    : Julho/2003                         Ultima Atualizacao: 20/10/2003

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Quebrar um string em quatro linhas, e justifica-las.

   Alteracoes: 20/10/2003 - Procedure conta_fim, estava somando incorretamente
                            dentro da condicao do while a variavel
                            aux_contafim (Julio).

               17/03/2014 - Conversao Progress -> Oracle (Andrino - RKAM)

............................................................................. */

      vr_containi  PLS_INTEGER := 0;
      vr_contafim  PLS_INTEGER := 0;
      vr_nrocolun  PLS_INTEGER := 0;
      vr_contalet  PLS_INTEGER := 0;

    -- Conta os ultimos caracteres depois da primeira separacao de palavras
    PROCEDURE pc_conta_fim(pr_qtcoluna PLS_INTEGER) IS
      BEGIN
        vr_containi := vr_contafim + 1;
        vr_contafim := vr_containi + pr_qtcoluna;

        WHILE SUBSTR(pr_dsstring, vr_contafim, 1) <> ' ' AND  vr_contafim > 0 LOOP
          vr_contafim := vr_contafim - 1;
        END LOOP;

        vr_nrocolun := vr_contafim - vr_containi;
      END pc_conta_fim;

    -- Rotina para justificar o texto
    PROCEDURE pc_justifica(pr_linhaatu IN  VARCHAR2,
                           pr_qtdcolun IN  PLS_INTEGER,
                           pr_linharet OUT VARCHAR2) IS
      vr_espacobr VARCHAR2(80) := ' ';
      vr_linhaatu VARCHAR2(100);
    BEGIN

      vr_linhaatu := pr_linhaatu;
      vr_contalet := vr_nrocolun - 1;

      IF LENGTH(TRIM(pr_linhaatu)) > 0 THEN
        WHILE LENGTH(TRIM(vr_linhaatu)) < pr_qtdcolun AND
              vr_contalet > 0 AND
              LENGTH(TRIM(vr_linhaatu)) > pr_qtdcolun / 2 LOOP

          IF SUBSTR(TRIM(vr_linhaatu), vr_contalet, 1) = substr(vr_espacobr,1,1) THEN
            vr_linhaatu := TRIM(SUBSTR(vr_linhaatu, 1, vr_contalet) ||
                                    ' ' || SUBSTR(vr_linhaatu, vr_contalet + 1, pr_qtdcolun - vr_contalet));
          END IF;

          IF vr_contalet > 1 THEN
            vr_contalet := vr_contalet - 1;
          ELSE
            vr_contalet := pr_qtdcolun;
            vr_espacobr := vr_espacobr || ' ';
          END IF;

        END LOOP;
      END IF;

      pr_linharet := vr_linhaatu;
    END pc_justifica;

    BEGIN -- Rotina principal da pc_quebra_str
      pc_Conta_Fim(pr_qtcolun1);
      pr_dslinha1 := TRIM(SUBSTR(pr_dsstring, vr_containi, vr_nrocolun + 1));
      pc_justifica(pr_dslinha1, pr_qtcolun1, pr_dslinha1);

      pc_Conta_Fim(pr_qtcolun2);
      pr_dslinha2 := TRIM(SUBSTR(pr_dsstring, vr_containi, vr_nrocolun + 1));
      pc_justifica(pr_dslinha2, pr_qtcolun2, pr_dslinha2);

      pc_Conta_Fim(pr_qtcolun3);
      pr_dslinha3 := TRIM(SUBSTR(pr_dsstring, vr_containi, vr_nrocolun + 1));
      pc_justifica(pr_dslinha3, pr_qtcolun3, pr_dslinha3);

      pc_Conta_Fim(pr_qtcolun4);
      pr_dslinha4 := TRIM(SUBSTR(pr_dsstring, vr_containi, vr_nrocolun + 1));
      pc_justifica(pr_dslinha4, pr_qtcolun4, pr_dslinha4);

    END pc_quebra_str;



END LIMP0001;
/
