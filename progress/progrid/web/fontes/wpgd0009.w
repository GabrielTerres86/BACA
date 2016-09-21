/* ..................................................................................

Altera�oes:  27/11/2007 - Incluidas atribui�oes dos campos "cratidp.nrdconta" e
                          "cratidp.idseqttl" na op�ao "A" da procedure 
                          local-assign-record (Diego).

             26/02/2008 - Nao permitir inscri�oes quando o mes da Data Final do
                          evento j� estiver Fechado, E usu�rio nao possuir
                          permissao de acesso 'U' (Diego).

             04/06/2008 - Melhoria de performance (Evandro).

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
			 
             13/05/2010 - Gravar nos historicos dos eventos (craphep) quando
                          evento for encerrado.
                          Gravar a data e operador quando a situacao da inscricao 
                          mudar (Gabriel).
						  
             05/06/2012 - Adapta�ao dos fontes para projeto Oracle. Alterado
                          busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                          
             08/01/2013 - Alterado os "FIND craptfc" para "FIND FIRST craptfc" 
                          na procedure NomeCooperado (Adriano).
                                       
             10/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                          a escrita ser� PA (Andr� Euz�bio - Supero).
                          
             13/11/2013 - Ajustes referentes a tarefa softdesk 104385 (Lucas R.)
             
             11/12/2013 - Incluir VALIDATE craphep. (Lucas R.)
             
             21/02/2014 - Incluir valida�ao da crapadp.dtfineve pra nao enviar
                          data nula para o javascript (Lucas R.)
                          
             25/02/2014 - Incluir limpeza dos registros apos o cadastro (Lucas R)
             
             14/03/2014 - Tratamento para chamar a funcao FocaCampo() somente se 
                          opcao nao for conf (Lucas R.)
                          
             28/03/2014 - Incluir ajuste para aceitar inclusao de PJ na inscri�ao
                          da procedure NomeCooperado (Lucas R.)
                          
             18/06/2014 - Ajutes para validar se cooperado possui inscri�ao em 
                          em outro PA Softdesk 141143 (Lucas R.)
                          
             26/01/2015 - Ajustado procedure CriaListaEventos, estava estourando
                          o tamanho da variavel, adicionado .push para adicionar
                          somente um evento por vez dentro do for each 
                          (Lucas R. #245866 )
             
             23/02/2015 - Incluir busca da crapjur na procedure NomeCooperado validar 
                          se existe conta juridica (Lucas R. #251850)
                          
             05/10/2015 - Incluido atribuicao para qtd max de participantes da table
                          crapeap.qtmaxtur (Jean Michel).
						  
              14/01/2016 - Alterado procedure AtualizaConfirm para que caso a situacao 
                         selecionada for igual a anterior nao deve atualizar os registros 
                         e somente atualizar a data de confirmacao se  situacao for 2 
                         (Lucas Ranghetti #379258)	
             
             15/01/2016 - Incluido filtro por nome do inscrito. (Lombardi #386129)
             
             26/01/2016 - Incluido filtro por conta do inscrito. (Lombardi #392513)

             02/02/2016 - Ajustes para Prj. 229. (Jean Michel)
             08/03/2016 - Alterado para que os eventos do tipo EAD 
                          e EAD Assemblear nao sejam apresentados.
                          Projeto 229 - Melhorias OQS (Lombardi)  		

             03/05/2016 - Incluir idevento na busca do codigo do evento na crapadp na 
                          PROCEDURE CriaListaInscritos (Lucas Eduardo Ranghetti #443848)
                          
             06/05/2016 - Correcao no cadastro de inscricoes de pessoas da comunidade 
                          para os eventos do Progrid. (Carlos Rafael Tanholi).
                          
             19/05/2016 - Correcao na validacao de contas inscritas no evento, assim como
                          a regra de carregamento do cooperado a partir do numero da conta
                          (Carlos Rafael Tanholi).                                      
                          
             27/05/2016 - Ajustado a rotina CriaListaInscritos para garantir
                          que nao ocorre estouro da variavel da rodascript 
                          ao carregar a lista SD443848 (Odirlei-AMcom)
                          
             01/07/2016 - Ajustes Projeto 229 - Melhorias OQS RF6.(Odirlei-AMcom)
             
             24/08/2016 - Corre��o para permitir salvar somente um inscrito(Jean Michel)             
                           
................................................................................... */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdgraupr AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgcompr AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgrest  AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lscoment AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsfaleve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsconfir AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nminseve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrconfir AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrcompar AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_excrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrinscri AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER 
       FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_tpinseve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_tppartic AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idademin AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD nmresage     AS CHARACTER
       FIELD origem       AS CHARACTER FORMAT "X(256)":U 
       FIELD pagina       AS CHARACTER FORMAT "X(256)":U 
       FIELD cdageins     AS CHARACTER 
       FIELD nrseqeve     AS CHARACTER 
       FIELD aux_carregar AS CHARACTER
       FIELD aux_reginils AS CHARACTER
       FIELD aux_regfimls AS CHARACTER
       FIELD aba          AS CHARACTER
       FIELD aux_flgalter AS CHARACTER
       FIELD aux_flginscr AS CHARACTER
       FIELD aux_dsinscri AS CHARACTER FORMAT "X(2000)":U 
       FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nminscri AS CHARACTER FORMAT "X(256)":U
       FIELD aux_tpfiltro AS CHARACTER
       FIELD aux_nrcpfcgc AS CHARACTER
       FIELD aux_nrcpfcgc_fil AS CHARACTER
       FIELD aux_nrdconta_cpfcgc AS CHARACTER.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0009"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0009.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER             NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER           NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER             NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER           NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER           NO-UNDO.

/*** Declara�ao de BOs ***/
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE              NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp             LIKE crapidp.

DEFINE VARIABLE vetorpac              AS CHAR                NO-UNDO.
DEFINE VARIABLE vetorevento           AS CHAR                NO-UNDO.
DEFINE VARIABLE vetorinscri           AS CHAR                NO-UNDO.
DEFINE VARIABLE aux_dadoseve          AS CHAR                NO-UNDO.
DEFINE VARIABLE vetorNome             AS CHAR                NO-UNDO.

DEFINE VARIABLE aux_crapcop           AS CHAR                NO-UNDO.
DEFINE VARIABLE aux_contador          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_nrdconta          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_idseqttl          AS INT                 NO-UNDO.
DEFINE VARIABLE aux_idstains          LIKE crapidp.idstains  NO-UNDO.

DEFINE BUFFER crabidp FOR crapidp.
DEFINE BUFFER crabedp FOR crapedp.   
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0009.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapidp.cdcooper crapidp.cdgraupr ~
crapidp.dsdemail crapidp.flgdispe ~
crapidp.idseqttl crapidp.nminseve crapidp.nrdconta crapidp.nrdddins ~
crapidp.nrtelins crapidp.tpinseve crapidp.dsobsins
&Scoped-define ENABLED-TABLES ab_unmap crapidp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapidp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_nminseve ~
ab_unmap.aux_tpinseve ab_unmap.aux_nrseqeve ab_unmap.aux_nrconfir ab_unmap.aux_nrcompar ~
ab_unmap.aux_nrinscri ab_unmap.aux_flgcompr ab_unmap.aux_flgrest ab_unmap.aux_qtmaxtur ~
ab_unmap.aux_idstaeve ab_unmap.origem ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdgraupr ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lscoment ab_unmap.aux_lsconfir ab_unmap.aux_lsfaleve ~
ab_unmap.aux_lspermis ab_unmap.aux_lsseqdig ab_unmap.aux_nrdrowid ab_unmap.aux_excrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_tppartic ab_unmap.aux_nmcooper ab_unmap.aux_nrdconta_cpfcgc ~
ab_unmap.nmresage     ab_unmap.pagina       ab_unmap.cdageins ~
ab_unmap.nrseqeve     ab_unmap.aux_carregar ab_unmap.aux_reginils ~
ab_unmap.aux_regfimls ab_unmap.aba          ab_unmap.aux_flgalter ~
ab_unmap.aux_flginscr ab_unmap.aux_dsinscri ab_unmap.aux_idademin ~
ab_unmap.aux_fechamen ab_unmap.aux_nminscri ab_unmap.aux_tpfiltro ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrcpfcgc_fil
&Scoped-Define DISPLAYED-FIELDS crapidp.cdcooper crapidp.cdgraupr ~
crapidp.dsdemail crapidp.flgdispe ~
crapidp.idseqttl crapidp.nminseve crapidp.nrdconta crapidp.nrdddins ~
crapidp.nrtelins crapidp.tpinseve crapidp.dsobsins
&Scoped-define DISPLAYED-TABLES ab_unmap crapidp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapidp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_nminseve ~
ab_unmap.aux_tpinseve ab_unmap.aux_nrseqeve ~
ab_unmap.aux_nrconfir ab_unmap.aux_nrinscri ab_unmap.aux_flgcompr ab_unmap.aux_flgrest ~
ab_unmap.aux_nrcompar ab_unmap.aux_qtmaxtur ab_unmap.aux_idstaeve ab_unmap.origem ~
ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdgraupr ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lscoment ab_unmap.aux_lsfaleve ~
ab_unmap.aux_lsconfir ab_unmap.aux_lspermis ab_unmap.aux_lsseqdig ~
ab_unmap.aux_nrdrowid ab_unmap.aux_excrowid ab_unmap.aux_stdopcao ab_unmap.aux_tppartic ~
ab_unmap.aux_nmcooper ab_unmap.aux_nrdconta_cpfcgc ab_unmap.nmresage ab_unmap.pagina ~
ab_unmap.cdageins     ab_unmap.nrseqeve     ab_unmap.aux_carregar ~
ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aba ~
ab_unmap.aux_flgalter ab_unmap.aux_flginscr ab_unmap.aux_dsinscri ~
ab_unmap.aux_idademin ab_unmap.aux_fechamen ab_unmap.aux_nminscri ~
ab_unmap.aux_tpfiltro ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrcpfcgc_fil

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     crapidp.dsobsins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nminseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tpinseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.nrseqeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrconfir AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrcompar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrinscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgcompr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_flgrest AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtmaxtur AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.origem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdgraupr AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1            
     ab_unmap.aux_nrcpfcgc_fil AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lscoment AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsfaleve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1   
     ab_unmap.aux_lsconfir AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_excrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 57.2 BY 15.19.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tppartic AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_idademin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	  ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_tpfiltro  AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.aux_nminscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdageins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.cdcooper AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.cdgraupr AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.dsdemail AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.flgdispe AT ROW 1 COL 1
          LABEL "Dispensa Confirmacao"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1 
     crapidp.idseqttl AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_nrdconta_cpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
     crapidp.nminseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmresage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrdconta AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrdddins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.nrtelins AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapidp.tpinseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "tpinseve 2", 2, "tpinseve 1", 1
          SIZE 20 BY 3
     ab_unmap.aux_carregar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_reginils AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_regfimls AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aba AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgalter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_flginscr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dsinscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(2000)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 57.2 BY 15.19.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdgraupr AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgcompr AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgrest  AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lscoment AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsconfir AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nminseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrconfir AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrinscri AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqeve AS CHARACTER 
          FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tpinseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idademin AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tppartic AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmcooper AS CHARACTER
          FIELD nmresage AS CHARACTER FORMAT "X(256)":U 
          FIELD origem AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
          FIELD aux_nminscri AS CHARACTER FORMAT "X(256)":U
          FIELD aux_tpfiltro AS CHARACTER
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 15.19
         WIDTH              = 57.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdgraupr IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgcompr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgrest IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idstaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lscoment IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsconfir IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nminseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrconfir IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrinscri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqeve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtmaxtur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_tpinseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_tppartic IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idademin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_fechamen IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tpfiltro IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nminscri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.cdgraupr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.dsdemail IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX crapidp.flgdispe IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN crapidp.idseqttl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nmcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN crapidp.nminseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nmresage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.nrdconta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrdddins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrseqeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapidp.nrtelins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.origem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.pagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR RADIO-SET crapidp.tpinseve IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 

/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AtualizaConfirm w-html 
PROCEDURE AtualizaConfirm :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR i              AS INT        NO-UNDO.
    DEF VAR aux_msg-erro   AS CHAR       NO-UNDO.
    
    DEF BUFFER bf1-crapidp FOR crapidp.
     
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
    DO:
        /* Encontra o codigo do evento */
        FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                           crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                           NO-LOCK NO-ERROR.
  
        DO  i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsseqdig): 

            /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
            IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
               ASSIGN aux_idstains = 2. /* confirmado */
            ELSE
                ASSIGN aux_idstains = 1. /* pendente */ 

            /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
            IF  crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
                ASSIGN aux_idstains = 1. /* pendente */ 

            FIND bf1-crapidp WHERE bf1-crapidp.idevento = INT(ab_unmap.aux_idevento)  AND
                                   bf1-crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                   bf1-crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                   bf1-crapidp.cdageins = INT(ab_unmap.cdageins)      AND
                                   bf1-crapidp.cdevento = crapadp.cdevento            AND
                                   bf1-crapidp.nrseqeve = INT(ab_unmap.nrseqeve)      AND
                                   bf1-crapidp.nrseqdig = INT(ENTRY(i, ab_unmap.aux_lsseqdig)) 
                                   NO-LOCK NO-ERROR.
        
            IF AVAIL bf1-crapidp THEN
            DO:
                FOR EACH cratidp EXCLUSIVE-LOCK:
                    DELETE cratidp NO-ERROR.
                END.
        
                CREATE cratidp.
                BUFFER-COPY bf1-crapidp TO cratidp.
        
                ASSIGN cratidp.dsobsins = ENTRY(i, ab_unmap.aux_lscoment, "�")
                       cratidp.qtfaleve = INT(ENTRY(i, ab_unmap.aux_lsfaleve, "�"))
                       cratidp.idstains = INT(ENTRY(i, ab_unmap.aux_lsconfir)) 
                       cratidp.dtaltera = TODAY
                       cratidp.cdopinsc = gnapses.cdoperad.
     
				/* Grava data de confirma�ao somente se for 2 - Confirmacao */
                IF  cratidp.idstains = 2 THEN
                    DO:
                      /* Caso a situacao selecionada for igual a anterior nao deve atualizar os registros */
						if INT(ENTRY(i, ab_unmap.aux_lsconfir)) <> bf1-crapidp.idstains then
                         cratidp.dtconins = TODAY.					
                    END.
                ELSE
					do:
                        IF  cratidp.idstains = 1 THEN
                            cratidp.dtconins = ?.
					end.                
        
                RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT aux_msg-erro).
    
                msg-erro = msg-erro + aux_msg-erro.
            END.
        END.
    
        /* "mata" a inst�ncia da BO */
        DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_idademin AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgrest  AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrfaltan AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrcompar AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
           INITIAL ["Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho",
                    "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
    DEFINE VARIABLE aux_fechamen AS CHAR NO-UNDO.
    
    DEF VAR cont AS INTE NO-UNDO.

    DEFINE BUFFER bf-crapidp FOR crapidp.

    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                            gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                            gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

    FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "CONFIG"       AND
                             craptab.cdempres = 0              AND
                             craptab.cdacesso = "PGTPPARTIC"   AND
                             craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    /* Lucas R. */
    ASSIGN vetorevento = "".
    RUN RodaJavaScript("var mevento=new Array();"). 

                             /* PROGRID */
    FOR EACH  crapeap WHERE (crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                             crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                             crapeap.cdagenci = INT(ab_unmap.cdageins)       AND
                             crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                             crapeap.flgevsel = YES)                               OR

                             /* ASSEMBLEIAS */
                            (crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                             crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                             crapeap.cdagenci = 0                            AND
                             crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                             crapeap.flgevsel = YES)                         NO-LOCK,

        FIRST crapedp WHERE  crapedp.cdevento = crapeap.cdevento             AND
                             crapedp.idevento = crapeap.idevento             AND
                             crapedp.cdcooper = crapeap.cdcooper             AND
                             crapedp.dtanoage = crapeap.dtanoage             AND
                             crapedp.tpevento <> 10                          AND
                             crapedp.tpevento <> 11 NO-LOCK,

        EACH  crapadp WHERE  crapadp.idevento = crapeap.idevento             AND
                             crapadp.cdcooper = crapeap.cdcooper             AND
                             crapadp.cdagenci = crapeap.cdagenci             AND
                             crapadp.dtanoage = crapeap.dtanoage             AND
                             crapadp.cdevento = crapeap.cdevento             NO-LOCK
                             BREAK BY crapadp.cdagenci
                                   BY crapedp.nmevento
                                   BY crapadp.nrseqdig:

        /***************/        
        IF crapeap.qtmaxtur > 0 THEN
          ASSIGN aux_qtmaxtur = STRING(crapeap.qtmaxtur).
        ELSE
          DO:
            /* para a frequencia minima */
            FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) AND 
                                     crabedp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                                     crabedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND 
                                     crabedp.cdevento = crapadp.cdevento NO-LOCK. 
            IF AVAILABLE crabedp THEN
              DO:
                IF crabedp.qtmaxtur > 0 THEN
                  ASSIGN aux_qtmaxtur = STRING(crabedp.qtmaxtur).
                ELSE
                  DO:
                    FIND FIRST crabedp WHERE crabedp.idevento = INT(ab_unmap.aux_idevento) AND 
                                             crabedp.cdcooper = 0 AND
                                             crabedp.dtanoage = 0 AND 
                                             crabedp.cdevento = crapadp.cdevento NO-LOCK.
                                        
                    IF AVAILABLE crabedp THEN
                      ASSIGN aux_qtmaxtur = STRING(crabedp.qtmaxtur).
                  END.
              END.
          END.
        /****************/
        /* Para o PROGRID, verifica se a agenda do PA esta com situacao "5-Enviada aos pa's", senao ignora */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = crapeap.cdcooper            AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapeap.cdagenci            AND
                                 crapagp.idstagen = 5                           NO-LOCK NO-ERROR.
     
        IF NOT AVAIL crapagp AND ab_unmap.aux_idevento = "1" THEN NEXT. 
            
        IF   AVAILABLE craptab   THEN
             aux_tppartic = ENTRY(LOOKUP(STRING(crapedp.tppartic), craptab.dstextab) - 1, craptab.dstextab).

        IF   aux_tppartic = ?   THEN
             aux_tppartic = "".
       
        IF   crapedp.flgcompr = TRUE   THEN
             aux_flgcompr = "TERMO DE COMPROMISSO".
        ELSE
             aux_flgcompr = "".
        
        IF   crapedp.flgrest = TRUE   THEN
             aux_flgrest = "PR�-INSCRI��ES SOMENTE PARA ASSOCIADOS DO PA".
        ELSE
             aux_flgrest = "".
       
       /*ASSIGN aux_qtmaxtur = STRING(crapeap.qtmaxtur).
       
       IF INT(aux_qtmaxtur) <= 0 THEN
        DO:
          IF crapedp.qtmaxtur <> ?   THEN
            ASSIGN aux_qtmaxtur = STRING(crapedp.qtmaxtur).
        ELSE
            ASSIGN aux_qtmaxtur = "0".
        END.*/

        IF   crapedp.nridamin <> 0   THEN
             aux_idademin = "IDADE M�NIMA DE " + STRING(crapedp.nridamin) + " ANOS".
        ELSE
             aux_idademin = "SEM RESTRI�AO DE IDADE".
            
        ASSIGN aux_nrinscri = 0
               aux_nrconfir = 0.

        /* Somente contabiliza os inscritos do evento que ja tiver sido escolhido */
        IF  crapadp.nrseqdig = INT(GET-VALUE("aux_nrseqeve"))   THEN
		    DO: 
                 /* Assembleias */
                 IF   crapeap.idevento = 2   AND
                      crapeap.cdagenci = 0   THEN
                      FOR EACH bf-crapidp WHERE bf-crapidp.idevento = crapeap.idevento   AND
                                                bf-crapidp.cdcooper = crapeap.cdcooper   AND
                                                bf-crapidp.dtanoage = crapeap.dtanoage   AND
                                                bf-crapidp.cdagenci = 0                  AND
                                                bf-crapidp.cdevento = crapeap.cdevento   AND
                                                bf-crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK:
     
                          /* Pendentes e Confirmados */
                          IF   bf-crapidp.idstains < 5   THEN
                               aux_nrinscri = aux_nrinscri + 1.
        
                          /* Somente Confirmados */            
                          IF   bf-crapidp.idstains = 2   THEN
                               aux_nrconfir = aux_nrconfir + 1.
                               
                          /**** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas 
                               (extraido da wpgd0038a)****/
                          IF bf-crapidp.IdStaIns = 2  AND bf-crapidp.QtFalEve > 0 AND crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                            IF ((bf-crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                                ASSIGN aux_nrfaltan = aux_nrfaltan + 1.
                      END.
                          END.     
                               
                      END.
                 ELSE 
                      FOR EACH bf-crapidp WHERE bf-crapidp.idevento = int(crapeap.idevento)   AND
                                                bf-crapidp.cdcooper = crapeap.cdcooper   AND
                                                bf-crapidp.dtanoage = crapeap.dtanoage   AND
                                                bf-crapidp.cdageins = crapeap.cdagenci   AND
                                                bf-crapidp.cdevento = crapeap.cdevento   AND
                                                bf-crapidp.nrseqeve = crapadp.nrseqdig   NO-LOCK:

                          /* Pendentes e Confirmados */
                          IF   bf-crapidp.idstains < 5   THEN
                               aux_nrinscri = aux_nrinscri + 1.
                 
                          /* Somente Confirmados */            
                          IF   bf-crapidp.idstains = 2   THEN
                               aux_nrconfir = aux_nrconfir + 1.

                          /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas
                                (extraido da wpgd0038a) ****/
                          IF bf-crapidp.IdStaIns = 2  AND bf-crapidp.QtFalEve > 0 AND crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
                             IF ((bf-crapidp.qtfaleve * 100) / crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
                                 ASSIGN aux_nrfaltan = aux_nrfaltan + 1.
                      END.
            END.

                      END.
            END.
        
        IF crapadp.dtfineve < TODAY AND crapadp.idstaeve <> 2  THEN
        DO:   
          ASSIGN aux_nrcompar = aux_nrconfir - aux_nrfaltan.
        END.
        
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN
                                 crapadp.nrseqdig
                              ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
       IF  crapadp.dtinieve <> ?   THEN
           aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
       ELSE
       IF  crapadp.nrmeseve <> 0   AND
           crapadp.nrmeseve <> ?   THEN
           aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
       IF  crapadp.dshroeve <> ""   THEN
           aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
       
       aux_fechamen = "N�o".  
       DO  aux_contador = 1 TO NUM-ENTRIES(gnpapgd.lsmesctb):

           IF  INT(ENTRY(aux_contador,gnpapgd.lsmesctb)) = MONTH(crapadp.dtfineve)  THEN
               DO:
	              ASSIGN aux_fechamen = "Sim".
	              LEAVE.
	           END.
       END.              
       
       
       vetorevento = "~{" +
                     "cdagenci:'" +  STRING(crapeap.cdagenci) + "'," + 
                     "cdcooper:'" +  STRING(crapeap.cdcooper) + "'," +
                     "cdevento:'" +  STRING(crapeap.cdevento) + "'," +
                     "nmevento:'" +  STRING(aux_nmevento)     + "'," + 
                     "idstaeve:'" +  STRING(crapadp.idstaeve) + "'," +
                     "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                     "flgrest:'"  +  STRING(aux_flgrest)      + "'," +
                     "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                     "nrinscri:'" +  STRING(aux_nrinscri)     + "'," +
                     "nrconfir:'" +  STRING(aux_nrconfir)     + "'," +
                     "nrcompar:'" +  STRING(aux_nrcompar)     + "'," +
                     "nrfaltan:'" +  STRING(aux_nrfaltan)     + "'," +
                     "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                     "idademin:'" +  STRING(aux_idademin)     + "'," +
                     "tppartic:'" +  STRING(aux_tppartic)     + "'," +
                     "dtfineve:'" + (IF  crapadp.dtfineve = ? THEN
                                        ""
                                     ELSE
                                     STRING(crapadp.dtfineve)) 
                                                              + "'," +    
                     /* facilitar validacao no javascript, enviar
                       S se ja finalizou o evento */                                         
                     "dsfineve:'" + (IF  crapadp.dtfineve <= TODAY THEN
                                        "N"
                                     ELSE "S" )               + "'," +                                          
                     "dtmvtolt:'" +  STRING(TODAY)            + "'," + 
                     "fechamen:'" +  STRING(aux_fechamen)     +  "'"  + "~}".
				
						
           RUN RodaJavaScript("mevento.push("  + vetorevento + ");").    

           ASSIGN vetorevento = "".
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaInscritos w-html 
PROCEDURE CriaListaInscritos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    DEF VAR aux_qtpagina AS INT  INIT 60                NO-UNDO.
    DEF VAR aux_qtregist AS INT  INIT 0                 NO-UNDO.
    DEF VAR aux_nmextttl AS CHAR                        NO-UNDO.
    DEF VAR aux_qtstinsc AS CHAR                        NO-UNDO.
    DEF VAR aux_dtconins AS CHAR                        NO-UNDO.
    DEF VAR aux_cdgraupr AS CHAR                        NO-UNDO.
    DEF VAR aux_nmresage AS CHAR                        NO-UNDO.
    DEF VAR aux_internet AS CHAR                        NO-UNDO.
    DEF VAR aux_dados    AS CHAR                        NO-UNDO.
    DEF VAR vetorstatus  AS CHAR                        NO-UNDO.
    DEF VAR aux_dsstatus AS CHAR                        NO-UNDO.
    DEF VAR aux_count    AS INT  INIT 0                 NO-UNDO.
    DEF VAR aux_rowid_first AS CHAR                     NO-UNDO.

    DEF BUFFER bf1-crapidp FOR crapidp.

    DEF QUERY q_inscritos FOR bf1-crapidp SCROLLING.

    RUN RodaJavaScript("var minscri = new Array();").
    
    /* Encontra o codigo do evento */
    FIND crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento) AND     
                       crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                       crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                       NO-LOCK NO-ERROR.

    /* Vinculo */
    FIND FIRST craptab WHERE craptab.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                             craptab.nmsistem = "CRED"                       AND
                             craptab.tptabela = "GENERI"                     AND
                             craptab.cdempres = 0                            AND
                             craptab.cdacesso = "VINCULOTTL"                 AND
                             craptab.tpregist = 0
                             NO-LOCK NO-ERROR.

    /* PROGRID ou ASSEMBLEIA com PA especifico */
    IF   INT(ab_unmap.cdageins) <> 0   THEN
         OPEN QUERY q_inscritos FOR EACH bf1-crapidp WHERE bf1-crapidp.idevento = INT(ab_unmap.aux_idevento)   AND
                                                           bf1-crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                                           bf1-crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                                                           bf1-crapidp.cdageins = INT(ab_unmap.cdageins)       AND
                                                           bf1-crapidp.cdevento = crapadp.cdevento             AND
                                                           bf1-crapidp.nrseqeve = INT(ab_unmap.nrseqeve)       AND
                                                         ((INT(ab_unmap.aux_tpfiltro) = 1 AND
                                                           bf1-crapidp.nminseve MATCHES "*" + ab_unmap.aux_nminscri + "*") OR 
                                                          (INT(ab_unmap.aux_tpfiltro) = 2 AND 
                                                           bf1-crapidp.nrdconta = INT(ab_unmap.aux_nminscri)))
                                                           USE-INDEX crapidp5 NO-LOCK 
                                                           INDEXED-REPOSITION MAX-ROWS aux_qtpagina.
    ELSE
    /* Assembl�ia - PA TODOS */
    IF   INT(ab_unmap.aux_idevento)  = 2   AND
         INT(ab_unmap.cdageins)      = 0   AND
         INT(ab_unmap.nrseqeve)     <> 0   THEN
         OPEN QUERY q_inscritos FOR EACH bf1-crapidp WHERE bf1-crapidp.idevento = INT(ab_unmap.aux_idevento)   AND
                                                           bf1-crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                                           bf1-crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                                                           bf1-crapidp.cdevento = crapadp.cdevento             AND
                                                           bf1-crapidp.nrseqeve = INT(ab_unmap.nrseqeve)       AND
                                                           bf1-crapidp.nminseve MATCHES "*" + ab_unmap.aux_nminscri + "*"       
                                                           USE-INDEX crapidp5  NO-LOCK 
                                                           INDEXED-REPOSITION MAX-ROWS aux_qtpagina.

    /* Buscar rowid do primeiro registro
       para ao navegar para o proximo onde o primeiro
       registro seja o primeiro da consulta nao ser necessario reposicionar
       pois apresenta falha - Odirlei */
    GET FIRST  q_inscritos.            
    IF avail bf1-crapidp THEN
         DO:
      aux_rowid_first = STRING(ROWID(bf1-crapidp)).
    END.  
    /* retornar ao registro inicial para o inicio da leitura*/
    GET prev q_inscritos.  

    IF   ab_unmap.aux_carregar = "proximos" AND  
         ab_unmap.aux_regfimls <> aux_rowid_first THEN
         DO:
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
            REPOSITION q_inscritos FORWARDS aux_qtpagina.
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
         END.
    ELSE
    IF   ab_unmap.aux_carregar = "anteriores"   THEN
         DO:
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_reginils).
            REPOSITION q_inscritos BACKWARDS aux_qtpagina - 1.
         END.

    /* Verifica se a Query abriu */
    IF   NUM-RESULTS("q_inscritos") <> ?   THEN
         DO aux_qtregist = 1 TO aux_qtpagina:
         
            GET NEXT q_inscritos.
            
            IF   AVAILABLE bf1-crapidp   THEN
                 DO:
                    IF   aux_qtregist = 1   THEN
                         ab_unmap.aux_reginils = STRING(CURRENT-RESULT-ROW("q_inscritos")).
         
                    ASSIGN ab_unmap.aux_regfimls = STRING(ROWID(bf1-crapidp)).

                    aux_dtconins = IF bf1-crapidp.dtconins <> ? THEN STRING(bf1-crapidp.dtconins,"99/99/9999") ELSE "".
       
                    aux_nmextttl = "N�o encontrado".
                    aux_nmresage = "".

                    FIND FIRST crapttl WHERE crapttl.cdcooper = bf1-crapidp.cdcooper AND
                                             crapttl.nrdconta = bf1-crapidp.nrdconta AND
                                             crapttl.idseqttl = bf1-crapidp.idseqttl
                                             NO-LOCK NO-ERROR.

                    IF   AVAIL crapttl   THEN
                         DO: 
                             ASSIGN aux_nmextttl = crapttl.nmextttl.

                             FIND FIRST crapass WHERE crapass.cdcooper = crapttl.cdcooper   AND
                                                      crapass.nrdconta = crapttl.nrdconta
                                                      NO-LOCK NO-ERROR.
    
                             IF   AVAIL crapass   THEN
                                  FIND FIRST crapage WHERE crapage.cdcooper = crapttl.cdcooper   AND
                                                           crapage.cdagenci = crapass.cdagenci   NO-LOCK NO-ERROR.

                             IF   AVAIL crapage   THEN
                                  aux_nmresage = crapage.nmresage.
                         END.
                    ELSE
                        DO:
                            
                             FIND FIRST crapass WHERE crapass.cdcooper = bf1-crapidp.cdcooper AND
                                                      crapass.nrdconta = bf1-crapidp.nrdconta
                                                      NO-LOCK NO-ERROR.
    
                             IF  AVAIL crapass   THEN
                                 DO:
                                     ASSIGN aux_nmextttl = crapass.nmprimtl.
                                     FIND FIRST crapage WHERE crapage.cdcooper = crapass.cdcooper   AND
                                                              crapage.cdagenci = crapass.cdagenci   NO-LOCK NO-ERROR.
                                     
                                     IF   AVAIL crapage   THEN
                                          aux_nmresage = crapage.nmresage.
                                 END.
                        END.
       
                    aux_cdgraupr = "".
                    IF   AVAIL craptab   THEN
                         ASSIGN aux_cdgraupr = ENTRY(LOOKUP(STRING(bf1-crapidp.cdgraupr),craptab.dstextab) - 1,
                                                            craptab.dstextab).

                    /* verifica se a inscri�ao foi feita pela internet*/
                    IF   bf1-crapidp.flginsin = YES   THEN
                         aux_internet = "Sim".
                    ELSE
                         aux_internet = "N�o".

                    aux_dados = '~{' +
                                'nminseve:' + '"' + STRING(bf1-crapidp.nminseve)      + '"' + ',' +
                                'nmextttl:' + '"' + STRING(aux_nmextttl)              + '"' + ',' +
                                'idseqttl:' + '"' + STRING(bf1-crapidp.idseqttl)      + '"' + ',' +
                                'nrdconta:' + '"' + STRING(bf1-crapidp.nrdconta)      + '"' + ',' +
                                'nrdddins:' + '"' + STRING(bf1-crapidp.nrdddins)      + '"' + ',' +
                                'nrtelins:' + '"' + STRING(bf1-crapidp.nrtelins)      + '"' + ',' +
                                'dsobsins:' + '"' + REPLACE(STRING(bf1-crapidp.dsobsins),'"','')  + '"' + ',' +
                                'cdagenci:' + '"' + STRING(bf1-crapidp.cdagenci)      + '"' + ',' +
                                'cdageins:' + '"' + STRING(bf1-crapidp.cdageins)      + '"' + ',' +
                                'cdcooper:' + '"' + STRING(bf1-crapidp.cdcooper)      + '"' + ',' +
                                'cdevento:' + '"' + STRING(bf1-crapidp.cdevento)      + '"' + ',' +
                                'nrseqdig:' + '"' + STRING(bf1-crapidp.nrseqdig)      + '"' + ',' +
                                'nrseqeve:' + '"' + STRING(bf1-crapidp.nrseqeve)      + '"' + ',' +
                                'dtconins:' + '"' + STRING(aux_dtconins)              + '"' + ',' +
                                'cdgraupr:' + '"' + STRING(aux_cdgraupr)              + '"' + ',' +
                                'nmresage:' + '"' + STRING(aux_nmresage)              + '"' + ',' +
                                'idstains:' + '"' + STRING(bf1-crapidp.idstains)      + '"' + ',' +
                                'nrdrowid:' + '"' + STRING(ROWID(bf1-crapidp))        + '"' + ',' +
                                'dtpreins:' + '"' + STRING(bf1-crapidp.dtpreins)      + '"' + ',' +
                                'qtfaleve:' + '"' + STRING(bf1-crapidp.qtfaleve)      + '"' + ',' +
                                'flginsin:' + '"' + STRING(aux_internet)              + '"' + ''  + '~}'.

                    IF  vetorinscri = '' THEN
                        vetorinscri = aux_dados.
                    ELSE
                        vetorinscri = vetorinscri + ',' + aux_dados.
                 
                    IF aux_count = 30 THEN
                    DO:
                      
                      RUN RodaJavaScript("minscri.push(" + vetorinscri + ");").
                      
                      ASSIGN aux_count = 0
                             vetorinscri = "".
                 END.
                    
                 ASSIGN aux_count = aux_count + 1.
              END.

         END.

    IF vetorinscri <> "" THEN
    DO:      
      RUN RodaJavaScript("minscri.push(" + vetorinscri + ");").
      ASSIGN vetorinscri = "".
    END.
    CLOSE QUERY q_inscritos.


    FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "CONFIG"     AND    
                             craptab.cdempres = 0            AND  
                             craptab.cdacesso = "PGSTINSCRI" AND  
                             craptab.tpregist = 0            NO-LOCK NO-ERROR.
    
    DO i = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
        
        /* Remover desistente e excluido */
        IF ENTRY(2 * i,craptab.dstextab) = "3" OR   
           ENTRY(2 * i,craptab.dstextab) = "5" THEN
          NEXT.
        
        ASSIGN aux_dsstatus = ENTRY(2 * i - 1,craptab.dstextab).
        
        IF  vetorstatus = "" THEN
            vetorstatus = "~{" +
                "dsstatus:'" + aux_dsstatus + "'," +
                "cdstatus:'" + ENTRY(2 * i,craptab.dstextab) + "'" + "~}".
        ELSE
            vetorstatus = vetorstatus + "," + "~{" +
                "dsstatus:'" + aux_dsstatus + "'," +
                "cdstatus:'" + ENTRY(2 * i,craptab.dstextab) + "'" + "~}". 
    END.
    
   RUN RodaJavaScript("var mstatus=new Array();mstatus=[" + vetorstatus + "]").
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_nmresag2 AS CHAR NO-UNDO.

    /*  Progrid */
    IF ab_unmap.aux_idevento = "1" THEN
       DO: 
           IF ab_unmap.origem = "" THEN
              DO:
                  { includes/wpgd0099.i ab_unmap.aux_dtanoage }
              END.
           ELSE  /* Chamado por outra tela */
              DO:
                  /* Para o PROGRID, sempre que abrir por outra tela, passa o PA por parametro*/
                  FIND crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                     crapage.cdagenci = INT(ab_unmap.cdageins)
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE crapage   THEN
                       vetorpac = "~{" + "cdcooper:"   + "'" + TRIM(STRING(crapage.cdcooper))
                                       + "',cdagenci:" + "'" + TRIM(STRING(crapage.cdagenci))
                                       + "',nmresage:" + "'" + crapage.nmresage + "'~}".
              END.
       END.
    ELSE
       DO:
          /* Se abriu a tela wpgd0009 ou foi chamado por outra tela sem passagem de PA por parametro */
          IF ab_unmap.origem        = "" OR
             INT(ab_unmap.cdageins) = 0  THEN
             DO:
                 { includes/wpgd0097.i }
             END.
          ELSE  /* Chamado por outra tela */
             DO:
                  /* Se abrir por outra tela passando o PA por parametro */
                  FIND crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                     crapage.cdagenci = INT(ab_unmap.cdageins)
                                     NO-LOCK NO-ERROR.

                  IF   AVAILABLE crapage   THEN
                       vetorpac = "~{" + "cdcooper:"   + "'" + TRIM(STRING(crapage.cdcooper))
                                       + "',cdagenci:" + "'" + TRIM(STRING(crapage.cdagenci))
                                       + "',nmresage:" + "'" + crapage.nmresage + "'~}".
             END.
       END.

    RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EncerraMatricula w-html 
PROCEDURE EncerraMatricula :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF VAR i AS INT NO-UNDO.
    DEF VAR aux_msg-erro AS CHAR NO-UNDO.

    FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                       crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                       NO-LOCK NO-ERROR.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
           FOR EACH crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                  crapidp.idevento = INT(ab_unmap.aux_idevento)  AND
                                  crapidp.cdevento = crapadp.cdevento            AND
                                  crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                  crapidp.cdageins = INT(ab_unmap.cdageins)      NO-LOCK:
           
               FOR EACH cratidp EXCLUSIVE-LOCK:
                   DELETE cratidp NO-ERROR.
               END.
       
               CREATE cratidp.
               BUFFER-COPY crapidp TO cratidp.
       
               IF   cratidp.idstains = 1 THEN
                    ASSIGN cratidp.idstains = 4.
               
               RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT aux_msg-erro).
       
               msg-erro = msg-erro + aux_msg-erro.
       
           END.
       
           /* "mata" a inst�ncia da BO */
           DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
       END.
														
    FIND FIRST crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)  AND
                             crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                             crapadp.cdagenci = INT(ab_unmap.cdageins)      AND
                             crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                             crapadp.nrseqdig = INT(ab_unmap.nrseqeve)      EXCLUSIVE-LOCK NO-ERROR.
    
    IF   AVAIL crapadp   THEN
	     DO:
			 ASSIGN crapadp.idstaeve = 4. 
			 
			 CREATE craphep.
             ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
		            craphep.cdagenci  = crapadp.nrseqdig
                    craphep.dshiseve  = "Evento encerrado em " + STRING(TODAY,"99/99/9999") + " pelo usu�rio " + gnapses.cdoperad + "."
                    craphep.dtmvtolt  = TODAY.  
             VALIDATE craphep.                 
	     END.     
    ELSE
         msg-erro = msg-erro + "Problemas para encerrar matr�culas. ".

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EncerraMatricula w-html 
PROCEDURE ExcluirInscricao:

    DEF VAR i AS INT NO-UNDO.
    DEF VAR aux_msg-erro AS CHAR NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
           FOR EACH crapidp 
              WHERE ROWID(crapidp) = TO-ROWID(ab_unmap.aux_excrowid) NO-LOCK:
           
               FOR EACH cratidp EXCLUSIVE-LOCK:
                   DELETE cratidp NO-ERROR.
               END.
       
               CREATE cratidp.
               BUFFER-COPY crapidp TO cratidp.
               
               /*Atribuir a situacao de excluido para nao validar a situacao
                 na exclusao */
               ASSIGN cratidp.idstains = 5.
               
               RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT aux_msg-erro).       
               msg-erro = msg-erro + aux_msg-erro.
               
           END.
       
           /* "mata" a inst�ncia da BO */
           DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
       END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdgraupr":U,"ab_unmap.aux_cdgraupr":U,ab_unmap.aux_cdgraupr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobsins":U,"crapidp.dsobsins":U,crapidp.dsobsins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgcompr":U,"ab_unmap.aux_flgcompr":U,ab_unmap.aux_flgcompr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgrest":U,"ab_unmap.aux_flgrest":U,ab_unmap.aux_flgrest:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idstaeve":U,"ab_unmap.aux_idstaeve":U,ab_unmap.aux_idstaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscoment":U,"ab_unmap.aux_lscoment":U,ab_unmap.aux_lscoment:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfaleve":U,"ab_unmap.aux_lsfaleve":U,ab_unmap.aux_lsfaleve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsconfir":U,"ab_unmap.aux_lsconfir":U,ab_unmap.aux_lsconfir:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsseqdig":U,"ab_unmap.aux_lsseqdig":U,ab_unmap.aux_lsseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nminseve":U,"ab_unmap.aux_nminseve":U,ab_unmap.aux_nminseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrconfir":U,"ab_unmap.aux_nrconfir":U,ab_unmap.aux_nrconfir:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcompar":U,"ab_unmap.aux_nrcompar":U,ab_unmap.aux_nrcompar:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_excrowid":U,"ab_unmap.aux_excrowid":U,ab_unmap.aux_excrowid:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrinscri":U,"ab_unmap.aux_nrinscri":U,ab_unmap.aux_nrinscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtmaxtur":U,"ab_unmap.aux_qtmaxtur":U,ab_unmap.aux_qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpinseve":U,"ab_unmap.aux_tpinseve":U,ab_unmap.aux_tpinseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tppartic":U,"ab_unmap.aux_tppartic":U,ab_unmap.aux_tppartic:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idademin":U,"ab_unmap.aux_idademin":U,ab_unmap.aux_idademin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpfiltro":U,"ab_unmap.aux_tpfiltro":U,ab_unmap.aux_tpfiltro:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nminscri":U,"ab_unmap.aux_nminscri":U,ab_unmap.aux_nminscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdageins":U,"ab_unmap.cdageins":U,ab_unmap.cdageins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"crapidp.cdcooper":U,crapidp.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdgraupr":U,"crapidp.cdgraupr":U,crapidp.cdgraupr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsdemail":U,"crapidp.dsdemail":U,crapidp.dsdemail:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgdispe":U,"crapidp.flgdispe":U,crapidp.flgdispe:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("idseqttl":U,"crapidp.idseqttl":U,crapidp.idseqttl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmcooper":U,"ab_unmap.aux_nmcooper":U,ab_unmap.aux_nmcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdconta_cpfcgc":U,"ab_unmap.aux_nrdconta_cpfcgc":U,ab_unmap.aux_nrdconta_cpfcgc:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("nminseve":U,"crapidp.nminseve":U,crapidp.nminseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmresage":U,"ab_unmap.nmresage":U,ab_unmap.nmresage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdconta":U,"crapidp.nrdconta":U,crapidp.nrdconta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddins":U,"crapidp.nrdddins":U,crapidp.nrdddins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelins":U,"crapidp.nrtelins":U,crapidp.nrtelins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("origem":U,"ab_unmap.origem":U,ab_unmap.origem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tpinseve":U,"crapidp.tpinseve":U,crapidp.tpinseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_carregar":U,"ab_unmap.aux_carregar":U,ab_unmap.aux_carregar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_reginils":U,"ab_unmap.aux_reginils":U,ab_unmap.aux_reginils:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_regfimls":U,"ab_unmap.aux_regfimls":U,ab_unmap.aux_regfimls:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aba":U,"ab_unmap.aba":U,ab_unmap.aba:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgalter":U,"ab_unmap.aux_flgalter":U,ab_unmap.aux_flgalter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flginscr":U,"ab_unmap.aux_flginscr":U,ab_unmap.aux_flginscr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsinscri":U,"ab_unmap.aux_dsinscri":U,ab_unmap.aux_dsinscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc_fil":U,"ab_unmap.aux_nrcpfcgc_fil":U,ab_unmap.aux_nrcpfcgc_fil:HANDLE IN FRAME {&FRAME-NAME}).  
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
    DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEFINE VARIABLE tmp_cdevento AS INT                NO-UNDO.
    DEFINE VARIABLE tmp_cdagenci LIKE crapidp.cdagenci NO-UNDO.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:          
              
          DO WITH FRAME {&FRAME-NAME}:
            
             IF opcao = "inclusao" THEN
                DO: 
                    FIND FIRST crabidp WHERE 
                               crabidp.idevento = INT(ab_unmap.aux_idevento) AND
                               crabidp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                               crabidp.dtanoage = INT(ab_unmap.aux_dtanoage) AND
                               crabidp.nrdconta = aux_nrdconta               AND
                               crabidp.idseqttl = aux_idseqttl               AND
                               crabidp.cdevento = tmp_cdevento               AND
                               crapidp.cdageins = INTEGER(ab_unmap.cdageins)
                               NO-LOCK NO-ERROR.
                    
                    /* Se ja tiver cadastro para cooperado da um next */
                    IF AVAILABLE crabidp THEN
                        NEXT.

                    FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                                         AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

                    IF NOT AVAIL crapadp THEN NEXT.
    
                    ASSIGN tmp_cdevento = crapadp.cdevento.
                    
                    /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
                    IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
                       ASSIGN aux_idstains = 2. /* confirmado */
                    ELSE
                        ASSIGN aux_idstains = 1. /* pendente */ 

                    /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
                    IF  crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
                        ASSIGN aux_idstains = 1. /* pendente */  

                    FIND FIRST crapedp WHERE crapedp.cdevento = tmp_cdevento                AND
                                             crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                             crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                             crapedp.idevento = INT(ab_unmap.aux_idevento)  
                                             NO-LOCK NO-ERROR.
                    
                    IF crapedp.tpevento = 7 THEN /* � assembl�ia */
                        ASSIGN tmp_cdagenci = 0.
                    ELSE
                        ASSIGN tmp_cdagenci = INT(ab_unmap.cdageins).
                    
                    /* a conta pode nao ser informada */
                    IF aux_nrdconta <> 0 THEN 
                    DO:
                      FOR FIRST crapass FIELDS(inpessoa) WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                           AND crapass.nrdconta = aux_nrdconta NO-LOCK. END.                    
                    END.
                    
                    CREATE cratidp.
                    ASSIGN cratidp.cdagenci = tmp_cdagenci
                           cratidp.cdageins = INT(ab_unmap.cdageins)
                           cratidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           cratidp.cdevento = tmp_cdevento
                           cratidp.nrseqeve = INT(ab_unmap.nrseqeve)
                           cratidp.cdgraupr = IF INT(ab_unmap.aux_cdgraupr) = 0 THEN 5 
                                              ELSE INT(ab_unmap.aux_cdgraupr)
                           cratidp.cdoperad = gnapses.cdoperad  
                           cratidp.dsdemail = INPUT crapidp.dsdemail
                           cratidp.flgdispe = INPUT crapidp.flgdispe 
                           cratidp.tpinseve = INT(ab_unmap.aux_tpinseve)
                           cratidp.dsobsins = INPUT crapidp.dsobsins
                           cratidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           cratidp.dtconins = IF cratidp.flgdispe THEN TODAY 
                                              ELSE ?
                           cratidp.dtpreins = TODAY
                           cratidp.idevento = INT(ab_unmap.aux_idevento)
                           cratidp.idseqttl = aux_idseqttl
                           cratidp.idstains = aux_idstains
                           cratidp.nminseve = INPUT crapidp.nminseve
                           cratidp.nrdconta = aux_nrdconta
                           cratidp.nrdddins = INPUT crapidp.nrdddins
                           cratidp.nrseqdig = 0
                           cratidp.cdopeori = gnapses.cdoperad
                           cratidp.cdageori = 999 
                           cratidp.dtinsori = TODAY
                           cratidp.nrtelins = INPUT crapidp.nrtelins.

                     /* valida a execucao da consulta e o tipo da conta */
                    IF AVAILABLE crapass AND crapass.inpessoa = 2 THEN       
                      DO:
                        
                        FIND FIRST crapavt WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
                                             AND crapavt.nrdconta = aux_nrdconta 
                                             AND crapavt.tpctrato = 6
                                             AND crapavt.nrctremp = 0 NO-LOCK.
                                             
                        ASSIGN cratidp.cdcopavl = INT(ab_unmap.aux_cdcooper)
                               cratidp.tpctrato = 6
                               cratidp.nrctremp = 0
                               cratidp.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc).
                      END.

                    RUN inclui-registro IN h-b1wpgd0009(INPUT  TABLE cratidp, 
                                                        OUTPUT msg-erro, 
                                                        OUTPUT ab_unmap.aux_nrdrowid). 
                END.
             ELSE  /* alteracao */
                DO:
                    FIND FIRST crapadp WHERE
                               crapadp.nrseqdig = INT(ab_unmap.nrseqeve) AND
                               crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                               NO-LOCK NO-ERROR.

                    IF NOT AVAIL crapadp THEN NEXT.
                   
                    /* se campo dispensar confirmacao tiver checkado, status sera confirmado */
                    IF INPUT FRAME {&frame-name} crapidp.flgdispe THEN
                       ASSIGN aux_idstains = 2. /* confirmado */
                    ELSE
                        ASSIGN aux_idstains = 1. /* pendente */ 

                    /* se evento estiver encerrado e nao tiver sido realizado a inscri�ao sera pendente */
                    IF  crapadp.idstaeve = 4 AND crapadp.dtfineve > TODAY THEN
                        ASSIGN aux_idstains = 1. /* pendente */ 
                    
				    /* cria a temp-table e joga o novo valor digitado 
                       para o campo */
                 /*    CREATE cratidp.
                     BUFFER-COPY crapidp TO cratidp. */
     
                     ASSIGN 
                         cratidp.cdgraupr = IF INT(ab_unmap.aux_cdgraupr) = 0 THEN 9
                                                            ELSE INT(ab_unmap.aux_cdgraupr)
                                         cratidp.cdoperad = gnapses.cdoperad
                         cratidp.dsdemail = INPUT crapidp.dsdemail
                         cratidp.dtpreins = TODAY
                         cratidp.nminseve = INPUT crapidp.nminseve
                         cratidp.nrdddins = INPUT crapidp.nrdddins
                         cratidp.nrtelins = INPUT crapidp.nrtelins
                         cratidp.flgdispe = INPUT crapidp.flgdispe 
                         cratidp.tpinseve = INT(ab_unmap.aux_tpinseve)
                         cratidp.dtconins = IF cratidp.flgdispe THEN TODAY ELSE ? 
                         cratidp.idstains = aux_idstains
                         cratidp.dsobsins = INPUT crapidp.dsobsins
     					 cratidp.nrdconta = aux_nrdconta
     					 cratidp.idseqttl = aux_idseqttl
                         cratidp.nminseve = INPUT crapidp.nminseve
                         cratidp.nrdddins = INPUT crapidp.nrdddins
                         cratidp.nrseqdig = ?
                         cratidp.nrtelins = INPUT crapidp.nrtelins.
  
                      RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro). 
   
                 END.    
                aux_nrdconta = 0. 
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0009) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
    /*********
	/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
          CREATE cratxxx. 
          BUFFER-COPY crapxxx TO cratxxx.
              
          RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratxxx, OUTPUT msg-erro).
    
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.  
       END.
    ***********/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
    RUN displayFields.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NomeCooperado w-html 
PROCEDURE NomeCooperado :
/*-----------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-----------------------------------------------------------------------------*/
    DEFINE BUFFER bf1-crapidp FOR crapidp.

    DEF VAR aux_nmtitular  AS CHAR NO-UNDO.
    DEF VAR aux_cdcooper   AS INTE NO-UNDO.
    DEF VAR aux_cdagenci   AS INTE NO-UNDO.
    DEF VAR aux_conta      AS INTE NO-UNDO.
    DEF VAR aux_seqttl     AS INTE NO-UNDO.
    DEF VAR aux_flgcrapass AS LOG  NO-UNDO.
    DEF VAR aux_flgcrapttl AS LOG  NO-UNDO.
    
    DEF VAR aux_nrtelefo AS CHAR NO-UNDO.
    DEF VAR aux_nrdddtfc AS CHAR NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR NO-UNDO.
    DEF VAR aux_nmresage AS CHAR NO-UNDO.

    ASSIGN vetorNome = "".

    IF INT(aux_nrdconta) = 0 THEN
      RETURN "NOK".

    RUN RodaJavaScript("var vetNome = new Array();").
    
    FOR FIRST crapass FIELDS(inpessoa dsdemail nmprimtl cdagenci) WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                                    AND crapass.nrdconta = INT(aux_nrdconta) NO-LOCK. END.

    IF NOT AVAILABLE crapass THEN                    
      DO:
        ASSIGN msg-erro-aux = 11.
        RETURN "NOK".
      END.

    ASSIGN aux_nmprimtl = STRING(crapass.nmprimtl).

    FOR FIRST crapage FIELDS(nmresage) WHERE crapage.cdcooper = crapass.cdcooper
                                         AND crapage.cdagenci = crapass.cdagenci NO-LOCK. END.
                
    /* Insere valor no campo de PA */
    IF NOT AVAILABLE crapass THEN                    
                        DO:
        ASSIGN ab_unmap.nmresage = "SEM PA"
                    aux_nmresage = "SEM PA".
      END.
            ELSE    
      DO:
        ASSIGN ab_unmap.nmresage = STRING(crapage.nmresage)
                    aux_nmresage = STRING(crapage.nmresage).
        END.

    IF crapass.inpessoa = 1 THEN /* PESSOA FISICA */
       DO:
        FOR EACH crapttl WHERE crapttl.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                               crapttl.nrdconta = INT(aux_nrdconta) NO-LOCK:
      
		  ASSIGN aux_dsinscri = '' aux_flginscr = ''.	
						
		  FOR EACH crapidp WHERE crapidp.idevento = INTEGER(ab_unmap.aux_idevento) AND 
		  						 crapidp.cdcooper = INTEGER(ab_unmap.aux_cdcooper) AND
								 crapidp.dtanoage = INTEGER(ab_unmap.aux_dtanoage) AND
								 crapidp.nrdconta = aux_nrdconta                   AND
								 crapidp.idseqttl = crapttl.idseqttl               AND
								 crapidp.cdevento = crapadp.cdevento               AND
								 crapidp.nrseqeve = INT(ab_unmap.nrseqeve) 		   AND
								 crapidp.cdageins = INT(ab_unmap.cdageins)
                                             NO-LOCK:

		    ASSIGN aux_flginscr = "S".
                 
			FIND FIRST crapage WHERE crapage.cdcooper = crapidp.cdcooper AND
									 crapage.cdagenci = crapidp.cdageins 
                                              NO-LOCK NO-ERROR.
                 
                     IF  AVAIL crapage THEN  
				ASSIGN aux_dsinscri = aux_dsinscri + " Pa: " + crapage.nmresage + " Inscrito: " + crapidp.nminseve.
                     ELSE /* para assembleias o pa = 0 */ 
				ASSIGN aux_dsinscri = aux_dsinscri + "Inscrito: " + crapidp.nminseve.
						
                 
                 END.   

          ASSIGN aux_nrtelefo = "".
          
          FOR FIRST crapcem FIELDS(dsdemail cddemail) WHERE crapcem.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                                                            crapcem.nrdconta = INT(aux_nrdconta) NO-LOCK. END.  
                                                      
          IF AVAILABLE crapcem THEN                    
            DO:
              ASSIGN aux_dsdemail = crapcem.dsdemail.
             END.

          /* Busca algum dos telefones do titular */
          FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                   craptfc.nrdconta = crapttl.nrdconta AND
                                   craptfc.idseqttl = crapttl.idseqttl AND
                                   craptfc.tptelefo = 2 /*Celular*/    
                                   NO-LOCK NO-ERROR.

          IF NOT AVAILABLE craptfc   THEN
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                      craptfc.nrdconta = crapttl.nrdconta AND
                                      craptfc.idseqttl = crapttl.idseqttl AND
                                   craptfc.tptelefo = 1 /*Residencial*/ 
                                   NO-LOCK NO-ERROR.

          IF NOT AVAIL craptfc   THEN
             FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                      craptfc.nrdconta = crapttl.nrdconta AND
                                      craptfc.idseqttl = crapttl.idseqttl AND
                                      craptfc.tptelefo = 3 /*Comercial*/  
                                      NO-LOCK NO-ERROR.

          IF AVAILABLE craptfc THEN
             ASSIGN aux_nrtelefo = STRING(craptfc.nrtelefo)
                    aux_nrdddtfc = STRING(craptfc.nrdddtfc).

          IF TRIM(vetorNome) <> "" THEN
            ASSIGN vetorNome = vetorNome + ",".
              
           ASSIGN vetorNome = vetorNome + "~{nmextttl:" + "'" + TRIM(crapttl.nmextttl)
                                        + "',idseqttl:" + "'" + STRING(crapttl.idseqttl)
                                        + "',nrdddtfc:" + "'" + STRING(aux_nrdddtfc)
                                        + "',nrtelefo:" + "'" + STRING(aux_nrtelefo)
                                        + "',dsdemail:" + "'" + TRIM(aux_dsdemail)
                                        + "',nmprimtl:" + "'" + STRING(aux_nmprimtl)
                                        + "',tppessoa:" + "'F" 
                                        + "',nmresage:" + "'" + STRING(aux_nmresage)                                 
                                        + "',flginscr:" + "'" + STRING(aux_flginscr)	
                                        + "',dsinscri:" + "'" + STRING(aux_dsinscri)	
                                        + "',nrcpfcgc:" + "'" + STRING(crapttl.nrcpfcgc) + "'~}".
     
        END. /* FIM FOR EACH CRAPTTL */
      END. /* FIM PESSOA FISICA */
    ELSE IF crapass.inpessoa = 2 THEN /* PESSOA JURIDICA */
        DO:  
        FOR EACH crapavt WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapavt.nrdconta = INT(aux_nrdconta)
                           AND crapavt.tpctrato = 6
                           AND crapavt.nrctremp = 0 NO-LOCK:

          IF crapavt.nrdctato <> 0 AND crapavt.nrdctato <> ? THEN
            DO:
             
              FOR EACH crapttl WHERE crapttl.cdcooper = crapavt.cdcooper AND 
                                     crapttl.nrdconta = crapavt.nrdctato NO-LOCK:
             
				         ASSIGN aux_dsinscri = '' aux_flginscr = ''.	
                    
                 FOR EACH crapidp 
                       WHERE crapidp.idevento = INTEGER(ab_unmap.aux_idevento) AND 
                             crapidp.cdcooper = INTEGER(ab_unmap.aux_cdcooper) AND
                             crapidp.dtanoage = INTEGER(ab_unmap.aux_dtanoage) AND
                             crapidp.nrdconta = aux_nrdconta                   AND
                             /* Alterado para validar atraves do CNPJ, pois como
                                � gravado o idseqttl das contas do socio, ocorre de 
                                apresentar dados do titular do outro socio */
                             /*crapidp.idseqttl = crapttl.idseqttl               AND*/
                             crapidp.nrcpfcgc = crapttl.nrcpfcgc               AND
                             crapidp.cdevento = crapadp.cdevento               AND
                             crapidp.nrseqeve = INT(ab_unmap.nrseqeve) 		     AND
                             crapidp.cdageins = INT(ab_unmap.cdageins)
                                                NO-LOCK:
                    
					          ASSIGN aux_flginscr = "S".
                    
                    FIND FIRST crapage WHERE crapage.cdcooper = crapidp.cdcooper AND
                                 crapage.cdagenci = crapidp.cdageins 
                                                 NO-LOCK NO-ERROR.
                    
                        IF  AVAIL crapage THEN  
                      ASSIGN aux_dsinscri = aux_dsinscri + " Pa: " + crapage.nmresage + " Inscrito: " + crapidp.nminseve.
                        ELSE /* para assembleias o pa = 0 */ 
                        ASSIGN aux_dsinscri = aux_dsinscri + "Inscrito: " + crapidp.nminseve.					
                    
                    END.   
             
                ASSIGN aux_nrtelefo = "".
                
                FOR FIRST crapcem FIELDS(dsdemail cddemail) WHERE crapcem.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                              AND crapcem.nrdconta = INT(aux_nrdconta) NO-LOCK. END.  
                                                      
                IF AVAILABLE crapcem THEN                    
                  DO:
                    ASSIGN aux_dsdemail = crapcem.dsdemail.
                END.
             
             /* Busca algum dos telefones do titular */
                FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                         craptfc.nrdconta = crapttl.nrdconta AND
                                         craptfc.idseqttl = crapttl.idseqttl AND
                                         craptfc.tptelefo = 2 /*Celular*/    
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL craptfc THEN
                   FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                            craptfc.nrdconta = crapttl.nrdconta AND
                                            craptfc.idseqttl = crapttl.idseqttl AND
                                      craptfc.tptelefo = 1 /*Residencial*/ 
                                      NO-LOCK NO-ERROR.
             
             IF NOT AVAIL craptfc   THEN
                   FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                            craptfc.nrdconta = crapttl.nrdconta AND
                                            craptfc.idseqttl = crapttl.idseqttl AND
                                         craptfc.tptelefo = 3 /*Comercial*/  
                                         NO-LOCK NO-ERROR.
             
                IF AVAILABLE craptfc THEN
                   ASSIGN aux_nrtelefo = STRING(craptfc.nrtelefo)
                          aux_nrdddtfc = STRING(craptfc.nrdddtfc).
                            
                IF TRIM(vetorNome) <> "" THEN
                  ASSIGN vetorNome = vetorNome + ",".
                
                ASSIGN vetorNome = vetorNome + "~{nmextttl:" + "'" + TRIM(STRING(crapttl.nmextttl))
                                             + "',idseqttl:" + "'" + STRING(crapttl.idseqttl)
                                             + "',nrdddtfc:" + "'" + STRING(aux_nrdddtfc)
                                             + "',nrtelefo:" + "'" + STRING(aux_nrtelefo) 
                                             + "',dsdemail:" + "'" + STRING(aux_dsdemail)
                                             + "',nmprimtl:" + "'" + STRING(aux_nmprimtl)
                                             + "',tppessoa:" + "'J" 
                                             + "',nmresage:" + "'" + STRING(aux_nmresage)                                                 
                                             + "',flginscr:" + "'" + STRING(aux_flginscr)      
                                             + "',dsinscri:" + "'" + STRING(aux_dsinscri)													 
                                             + "',nrcpfcgc:" + "'" + STRING(crapttl.nrcpfcgc) + "'~}".
                  
               
              END.
            END. /* FIM IF NRDCTATO THEN*/
          ELSE
            DO:

              IF TRIM(vetorNome) <> "" THEN
                ASSIGN vetorNome = vetorNome + ",".  
                  
              ASSIGN vetorNome = vetorNome + "~{" + "nmextttl:" + "'" + TRIM(STRING(crapavt.nmdavali))
                                           + "',idseqttl:" + "'0" 
                                           + "',nrdddtfc:" + "'"  
                                           + "',nrtelefo:" + "'" + STRING(crapavt.nrfonres)
                                           + "',dsdemail:" + "'" + STRING(crapavt.dsdemail)
                                           + "',nmprimtl:" + "'" + STRING(aux_nmprimtl)
                                           + "',tppessoa:" + "'J" 
                                           + "',nmresage:" + "'" + STRING(aux_nmresage)                                             
                                           + "',flginscr:" + "'" + STRING(aux_flginscr)		
                                           + "',dsinscri:" + "'" + STRING(aux_dsinscri)												 
                                           + "',nrcpfcgc:" + "'" + STRING(crapavt.nrcpfcgc) + "'~}".
                  
            END.                                           
        END. /* FIM FOR EACH CRAPAVT PESSOA JURIDICA */
        
      END. /* FIM PESSOA JURIDICA */    
    
    RUN RodaJavaScript("vetNome = ["  + vetorNome + "];").
   
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NomeCooperado w-html 
PROCEDURE BuscarCooperadoCPFCGC:
  
  DEF VAR vetCoopCpfCgc AS CHAR NO-UNDO INIT "".
  
  ASSIGN vetCoopCpfCgc = "".
  
  FOR EACH crapass 
     WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapass.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
      IF vetCoopCpfCgc <> "" THEN 
         ASSIGN vetCoopCpfCgc = vetCoopCpfCgc + ",".
         
      ASSIGN vetCoopCpfCgc =  vetCoopCpfCgc 
                          + "~{" + "  nrdconta:" + "'" + STRING(crapass.nrdconta)
                                 + "',nmprimtl:" + "'" + crapass.nmprimtl
                          + "'~}".         
  END.     
  
  /* Titulares */
  FOR EACH crapttl 
     WHERE crapttl.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapttl.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapttl.idseqttl <> 1
       NO-LOCK,
      EACH crapass 
     WHERE crapass.cdcooper = crapttl.cdcooper
       AND crapass.nrdconta = crapttl.nrdconta
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
      IF vetCoopCpfCgc <> "" THEN 
         ASSIGN vetCoopCpfCgc = vetCoopCpfCgc + ",".
         
      ASSIGN vetCoopCpfCgc =  vetCoopCpfCgc 
                          + "~{" + "  nrdconta:" + "'" + STRING(crapttl.nrdconta)
                                 + "',nmprimtl:" + "'" + crapass.nmprimtl
                          + "'~}".         
  END. 
  
  /* Avalistas */
  FOR EACH crapavt 
     WHERE crapavt.cdcooper = INT(ab_unmap.aux_cdcooper)
       AND crapavt.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc_fil)
       AND crapavt.tpctrato = 6 
       NO-LOCK,
      EACH crapass 
     WHERE crapass.cdcooper = crapavt.cdcooper
       AND crapass.nrdconta = crapavt.nrdconta
       AND crapass.dtdemiss = ?
       NO-LOCK:
      
      IF vetCoopCpfCgc <> "" THEN 
         ASSIGN vetCoopCpfCgc = vetCoopCpfCgc + ",".
         
      ASSIGN vetCoopCpfCgc =  vetCoopCpfCgc 
                          + "~{" + "  nrdconta:" + "'" + STRING(crapavt.nrdconta)
                                 + "',nmprimtl:" + "'" + crapass.nmprimtl
                          + "'~}".         
        
    END. /* FIM FOR EACH CRAPAVT PESSOA JURIDICA */
    	
  RUN RodaJavaScript("var vetCoopCpfCgc=new Array();vetCoopCpfCgc=["  + vetCoopCpfCgc + "]"). 
  
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :
/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
   DO:
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j� � o primeiro registro.')").
               
               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".

           END.
   END.
ELSE 
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :
    FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
    
    
    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
        ASSIGN ab_unmap.aux_nrdrowid  = "?"
               ab_unmap.aux_stdopcao = "".
    ELSE
        ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
               ab_unmap.aux_stdopcao = "".  /* aqui p */
    
    /* Nao traz inicialmente nenhum registro */ 
    RELEASE {&SECOND-ENABLED-TABLE}.
    
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.


IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j� � o �ltimo registro.')").

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".
           END.
    END.
ELSE
    RUN PosicionaNoUltimo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :
    FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
    
    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
        ASSIGN ab_unmap.aux_nrdrowid = "?".
    ELSE
        ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
               ab_unmap.aux_stdopcao = "".   /* aqui u */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Versao WebSpeed 2.1
  Autor: B&T/Solusoft
 Fun�ao: Processo de requisi�ao web p/ cadastros simples na web - Versao WebSpeed 3.0
  Notas: Este � o procedimento principal onde ter� as requisi�oes GET e POST.
         GET - � ativa quando o formul�rio � chamado pela 1a vez
         POST - Ap�s o get somente ocorrer� POST no formul�rio      
         Caso seja necess�rio custimiz�-lo para algum programa espec�fico 
         Favor c�piar este procedimento para dentro do procedure process-web-requeste 
         fa�a l� altera�oes necess�rias.
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.

ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_excrowid    = GET-VALUE("aux_excrowid") 
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_lsconfir    = GET-VALUE("aux_lsconfir")
       ab_unmap.aux_lscoment    = GET-VALUE("aux_lscoment")
       ab_unmap.aux_lsfaleve    = GET-VALUE("aux_lsfaleve")
       ab_unmap.aux_lsseqdig    = GET-VALUE("aux_lsseqdig")
       ab_unmap.aux_cdgraupr    = GET-VALUE("aux_cdgraupr")
       ab_unmap.aux_idstaeve    = GET-VALUE("aux_idstaeve")
       ab_unmap.pagina          = GET-VALUE("pagina")
       ab_unmap.origem          = GET-VALUE("origem")
       ab_unmap.aux_tpinseve    = GET-VALUE("aux_tpinseve")
       ab_unmap.aux_nminseve    = GET-VALUE("aux_nminseve")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.cdageins        = GET-VALUE("cdageins")
       ab_unmap.nrseqeve        = GET-VALUE("nrseqeve")
       ab_unmap.aux_carregar    = GET-VALUE("aux_carregar")
       ab_unmap.aux_reginils    = GET-VALUE("aux_reginils")
       ab_unmap.aux_regfimls    = GET-VALUE("aux_regfimls")
       ab_unmap.aba             = GET-VALUE("aba")
       ab_unmap.aux_dsinscri    = GET-VALUE("aux_nminseve")
       ab_unmap.aux_nminscri    = GET-VALUE("aux_nminscri")
       ab_unmap.aux_tpfiltro    = GET-VALUE("aux_tpfiltro")
       ab_unmap.aux_nrcpfcgc    = GET-VALUE("aux_nrcpfcgc")
       ab_unmap.aux_nrcpfcgc_fil= GET-VALUE("aux_nrcpfcgc_fil")
       ab_unmap.aux_nrdconta_cpfcgc = GET-VALUE("aux_nrdconta_cpfcgc").
       
RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.
              
/* Se a cooperativa ainda nao foi escolhida, pega a da sessao do usu�rio */
IF  INT(ab_unmap.aux_cdcooper) = 0   THEN
    ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PA ainda nao foi escolhido, pega o da sessao do usu�rio */
IF  INT(ab_unmap.cdageins) = 0   THEN
    ab_unmap.cdageins = STRING(gnapses.cdagenci).

/* Posiciona por default, na agenda atual */
IF  ab_unmap.aux_dtanoage = ""   THEN
    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                            gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                            gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
ELSE
    /* Se informou a data da agenda, permite que veja a agenda de um ano nao atual */
    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                            gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                            gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

IF  NOT AVAILABLE gnpapgd THEN
    DO:
       IF  ab_unmap.aux_dtanoage <> ""   THEN
           DO:
               RUN RodaJavaScript("alert('N�o existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
               opcao = "".
           END.
    
       FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                               gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.
    
    END.

IF  AVAILABLE gnpapgd THEN
    DO:
        IF  ab_unmap.aux_dtanoage = ""   THEN
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
        ELSE
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
    END.
ELSE
    ASSIGN ab_unmap.aux_dtanoage = "".

ASSIGN ab_unmap.aux_tpfiltro:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Pr�-Inscrito,1,Conta,2".

FIND FIRST craptab WHERE craptab.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                         craptab.nmsistem = "CRED"                     AND
                         craptab.tptabela = "GENERI"                   AND
                         craptab.cdempres = 0                          AND
                         craptab.cdacesso = "VINCULOTTL"               AND
                         craptab.tpregist = 0                          NO-LOCK NO-ERROR.

IF  AVAILABLE craptab   THEN
    ASSIGN ab_unmap.aux_cdgraupr:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = craptab.dstextab.

/* m�todo POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
    
      RUN inputFields.           
   
      IF INPUT FRAME {&frame-name} crapidp.nrdconta <> 0 THEN
          ASSIGN aux_nrdconta = INPUT FRAME {&frame-name} crapidp.nrdconta
                 aux_idseqttl = INPUT FRAME {&frame-name} crapidp.idseqttl
                 ab_unmap.aux_cdagenci    = GET-VALUE("aux_cdagenci").
        
      ELSE
          ASSIGN aux_nrdconta = 0
                 aux_idseqttl = 0
                 ab_unmap.aux_cdagenci = "1". 
   
      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO: 
                    IF  ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                             ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
                            ELSE 
                            DO:
                               ASSIGN msg-erro-aux = 10
                                      ab_unmap.aux_stdopcao = "al".

                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                /*  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro nao existe */
                                         RUN PosicionaNoSeguinte.
                                     END. */
                            END.

                       /* RUN RodaJavaScript("Recarrega();").  */

                        END.  /* fim inclusao */
                    ELSE     /* altera�ao */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                        
                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               ASSIGN msg-erro = "Registro n�o encontrado para altera�ao"
                                      msg-erro-aux = 3.
                            ELSE
                                DO:
                                    RUN local-assign-record ("alteracao").   
                                    IF msg-erro <> "" THEN
                                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
                                    ELSE 
                                       ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                               END.
                        END.    /* fim altera�ao */ 
                    
                END.   /* fim salvar */ 

           WHEN "in" THEN /* inclusao */
                DO:
                    IF ab_unmap.aux_stdopcao <> "i" THEN
                       DO:
                           CLEAR FRAME {&FRAME-NAME}.
                           ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */ 

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o pr�ximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou pr�ximo registro entao procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN aux_nrdrowid-auxiliar = "?".
                       END.          
                       
                    /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR. 
                    
                    /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                      /* ELSE
                          ASSIGN msg-erro-aux = 2. /* registro nao existe */ */
                    ELSE
                       DO:
                          IF msg-erro = "" THEN
                             DO:
                                RUN local-delete-record.
                                DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                   ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
                                END.    

                                IF msg-erro = " " THEN
                                   DO:
                                       IF aux_nrdrowid-auxiliar = "?" THEN
                                          RUN PosicionaNoPrimeiro.
                                       ELSE
                                          DO:
                                              ASSIGN ab_unmap.aux_nrdrowid = aux_nrdrowid-auxiliar.
                                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                              
                                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                                 RUN PosicionaNoSeguinte.
                                          END.   
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
                       END.  
                END. /* fim exclusao */

           WHEN "pe" THEN /* pesquisar */
                DO:   
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.

                END. /* fim pesquisar */

           WHEN "li" THEN /* listar */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.

                END. /* fim listar */

           WHEN "pr" THEN /* primeiro */
                RUN PosicionaNoPrimeiro.
      
           WHEN "ul" THEN /* ultimo */
                RUN PosicionaNoUltimo.
      
           WHEN "an" THEN /* anterior */
                RUN PosicionaNoAnterior.
      
           WHEN "se" THEN /* seguinte */
                RUN PosicionaNoSeguinte.

          WHEN "conf" THEN /* salva confirma�oes */
               DO:
                   RUN AtualizaConfirm.  

                   IF msg-erro = "" THEN
                      ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   ELSE
                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
               END.
          
          WHEN "enc" THEN /* encerra incri�oes */
               DO:
                   RUN EncerraMatricula.
                   IF msg-erro = "" THEN
                      ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   ELSE
                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
               END.
          WHEN "exi" THEN /* Excluir inscri�ao */
               DO:
                   RUN ExcluirInscricao.
                   IF msg-erro = "" THEN
                      ASSIGN msg-erro-aux = 10. /* Solicita�ao realizada com sucesso */ 
                   ELSE
                      ASSIGN msg-erro-aux = 3. /* erros da valida�ao de dados */
               END.
          WHEN "bcc" THEN /* buscar cooperado pelo cpf\cnpj */   
            DO:
              RUN buscarCooperadoCPFCGC.
            
            END.
      END CASE. 
	  
      RUN CriaListaPac.
      RUN CriaListaEventos.
      RUN CriaListaInscritos.
    
      IF aux_nrdconta <> 0 AND aux_nrdconta <> ? THEN
        DO:
      RUN NomeCooperado.  
        END.
	  
      /* limpar variavel para nao apresentar critica ao carregar tela */  
      ab_unmap.aux_cdagenci = "".
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.
	  
     CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usu�rio. Solicita�ao n�o pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN RUN RodaJavaScript("alert('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN
           DO:
               IF  GET-VALUE("origem") <> "" THEN 
                   DO:
                       RUN RodaJavaScript("window.opener.Recarrega();").
                       RUN RodaJavaScript("self.close();").
                   END.
               ELSE
                   DO:
                      IF opcao <> "exi" THEN 
                        RUN RodaJavaScript('alert("Atualiza��o executada com sucesso.")'). 
                      ELSE
                        RUN RodaJavaScript('alert("Inscri��o exclu�da com sucesso.")'). 
                      
                      IF  opcao <> "conf" AND 
                          opcao <> "enc"  AND
                          opcao <> "exi"  THEN
                          RUN RodaJavaScript(" FocaCampo(); ").
                   END.
           END.

           /* Conta e titularidade nao encontrados no cadastro */
           WHEN 11 THEN RUN RodaJavaScript('alert("Cooperado n�o encontrado.")'). 

      END CASE.

      IF GET-VALUE("origem") <> "" THEN
      DO:
         RUN RodaJavaScript("TravaTudo();").
         RUN RodaJavaScript("document.form.cdageins.value = '" + GET-VALUE('cdageins') + "'").
         RUN RodaJavaScript("PosicionaPAC();").
         RUN RodaJavaScript("PosicionaPAC();").
         
      END.
     
      IF opcao = "bcc" THEN
      DO:
         RUN RodaJavaScript("carregaContaNrcpccgc(" + ab_unmap.aux_nrdconta_cpfcgc + ");").
      END.

     /* RUN RodaJavaScript('top.frames[0].ZeraOp()').   */

   END. /* Fim do m�todo POST */
ELSE /* M�todo GET */ 
   DO:              
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).

	  CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
          
           OTHERWISE
           DO:
               IF GET-VALUE("LinkRowid") <> "" THEN
                   DO:
                       FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                       
                       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                     ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                     ab_unmap.aux_tpinseve = STRING(crapidp.tpinseve)
                                     ab_unmap.aux_nminseve = crapidp.nminseve
                                     ab_unmap.aux_dtanoage = STRING(crapidp.dtanoage)
                                     ab_unmap.aux_cdcooper = STRING(crapidp.cdcooper)
                                     ab_unmap.nrseqeve     = STRING(crapidp.nrseqeve)
                                     ab_unmap.cdageins     = STRING(crapidp.cdageins)
                                     ab_unmap.aux_dsinscri = crapidp.nminseve.
                   
                              /*FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
                   
                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                 ASSIGN ab_unmap.aux_stdopcao = "u".
                              ELSE
                                 DO:
                                     FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     
                                     FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
                   
                                     IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                        ASSIGN ab_unmap.aux_stdopcao = "p".        
                                     ELSE
                                        ASSIGN ab_unmap.aux_stdopcao = "?".
                                 END.
                   
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                              */ 
                          END.  
                       ELSE
                          ASSIGN ab_unmap.aux_nrdrowid = "?"
                                 ab_unmap.aux_stdopcao = "?".
                   END.  
               ELSE
                   RUN PosicionaNoPrimeiro.

		   	   RUN CriaListaPac.
               RUN CriaListaEventos.
               RUN CriaListaInscritos.

               IF aux_nrdconta <> 0 AND aux_nrdconta <> ? THEN
               RUN NomeCooperado.
		    		
               RUN displayFields.
               RUN enableFields.
               RUN outputFields.
               RUN RodaJavaScript('FechaZoom()').
               RUN RodaJavaScript('CarregaPrincipal()').
		    		
		       IF GET-VALUE("LinkRowid") = "" THEN
                  DO:
                      RUN RodaJavaScript('LimparCampos();').
                      RUN RodaJavaScript('Incluir();').
                  END.

               IF GET-VALUE("origem") <> "" THEN
                  DO:
                      RUN RodaJavaScript("document.form.cdageins.value = '" + GET-VALUE('cdageins') + "'").
                      RUN RodaJavaScript("PosicionaPAC();").
                      RUN RodaJavaScript("document.form.nrseqeve.value = '" + GET-VALUE('nrseqeve') + "'").
                      RUN RodaJavaScript("PosicionaEventos();").
                      RUN RodaJavaScript("TravaTudo();").
                      /* Seguran�a de PAs */
                      IF (gnapses.nvoperad = 1 OR gnapses.nvoperad = 2)  AND 
                          gnapses.cdagenci <> int(GET-VALUE('cdageins')) AND 
                          INT(GET-VALUE('cdageins')) <> 0                THEN DO: 
                          /* Se este PA nao � o seu, nao pode efetuar confirma�ao nem dispens�-la */
                          RUN RodaJavaScript("document.all.salvaconfirm.style.visibility = 'hidden';").
                      END.
                  
                  END.

           END. /* fim otherwise */                  
      END CASE. 
END. /* fim do m�todo GET */

/* Show error messages. */
IF AnyMessage() THEN 
   DO:
      /* ShowDataMessage may return a Progress column name. This means you
       * can use the function as a parameter to HTMLSetFocus instead of 
       * calling it directly.  The first parameter is the form name.   
       *
       * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
      ShowDataMessages().
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :

    {includes/rodajava.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
