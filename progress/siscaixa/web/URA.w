&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

   Programa: URA.w
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2006.                    Ultima atualizacao: 29/05/2018
      
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa que gera os dados para a URA.
   
   Alteracoes: 30/03/2006 - Criada PROCEDURE p_cria_crapura para registrar
                            os 4 tipos de operacoes de extrato (Diego).
                            
               13/09/2006 - Acerto para evitar duplicates no crapura (Ze).
               
               06/02/2007 - Usar a include var_ibank.i do diretorio
                            sistema/internet/includes (Evandro).
                 
               21/05/2007 - Colocar aux_cdcooper nas leituras (Magui).
               
               27/07/2007 - Acrescentar parametro na BO b1wgen0004.p (Ze).
               
               01/08/2007 - Tratamento para aplicacoes RDC (David).

               21/09/2007 - Retirar campo crapass.cddsenha (David).
               
               04/10/2007 - Acerto no tratamento de aplicacoes RDC (Ze).
               
               19/12/2007 - Tratamento para Transpocred (Junior).

               06/03/2008 - Utilizar includes de temp-tables 
                          - Retirar include var_ibank.i (David).

               28/05/2008 - Incluir parametro na consulta-extrato (David).
               
               11/03/2009 - Incluir logo das novas cooperativas (Ze).
               
               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).
                            
               31/01/2011 - Aumento de 7 para 8 digitos o numero do conta
                            corrente (Ze).
                            
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].
                            
               06/06/2013 - Incluir chamada para procedure retorna-valor-blqjud
                            e tratamento para mostrar vlblqjud (Lucas R.)
                            
               25/06/2013 - Ajuste para executar a msg de "Dados incorretos"
                            quando a o cod. da cooperativa for invalido 
                            (Ze).
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               26/08/2013 - Alteracao referente a nova consulta de saldo de
                            aplicacoes (Jean Michel)
                            
               04/09/2013 - Alteracao referente a listagem de antigos e novas
                            aplicacoes na opcao "4 - p_extrato_apl" (Jean Michel)

               23/06/2015 - Ajustado a pesquisa do saldo da conta para utilizar 
                            a procedure pc_obtem_saldo_dia_prog
                            (Douglas - Chamado 285228 - obtem-saldo-dia)

			   10/10/2016 - Ajuste referente Projeto 291 (Daniel)	
                            
               29/11/2017 - Inclusao do valor de bloqueio em garantia. 
                            PRJ404 - Garantia.(Odirlei-AMcom)        
               12/03/2018 - #856961 Correção das imagens das cooperativas na
                            rotina p_imprime_cabec, incluindo a Altovale, 
                            retirando as inativas e atualizando os novos 
                            nomes (Acredicoop e Acentra) (Carlos)
  
		       29/05/2018 - Ajustes referente alteracao da nova marca (Jonata Mouts - P413 ).					  
                            
               30/05/2018 - valida dscomple e concatena com tt-extrato_conta.dsextrat 
			               (Alcemir Mout's - Prj. 467).							  
                            
               04/07/2019 - Ajustes referente alteracao da marca CREDIFIESC para UNILOS (Andre Bohn Mouts). 
                            
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

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }

{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                           NO-UNDO.
DEF VAR aux_inproces AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_dsdsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_operacao AS INTE                                           NO-UNDO.
DEF VAR aux_dsdlinha AS CHAR                                           NO-UNDO. 
DEF VAR aux_vllimcre AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldant AS DECI                                           NO-UNDO.
DEF VAR aux_dsdcabec AS CHAR                                           NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                           NO-UNDO.
DEF VAR aux_dttermin AS DATE                                           NO-UNDO.
DEF VAR aux_caracter AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdparam AS CHAR                                           NO-UNDO.
DEF VAR aux_vltotrdc AS DECI                                           NO-UNDO.
DEF VAR aux_vltotppr AS DECI                                           NO-UNDO.
DEF VAR aux_dsdahora AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_vlsddisp AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"              NO-UNDO.
DEF VAR aux_vlsdrdca AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"              NO-UNDO.
DEF VAR aux_vlsdrdpp AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.            
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.            
DEF VAR aux_dscomple AS CHAR                                           NO-UNDO.
DEF VAR aux_vlblqapl_gar  AS DECI                                      NO-UNDO.
DEF VAR aux_vlblqpou_gar  AS DECI                                      NO-UNDO.          

DEF VAR aux_vlsldapl AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldtot AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldrgt AS DECI                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_cdcritic LIKE crapcri.cdcritic                             NO-UNDO.
DEF VAR aux_dscritic LIKE crapcri.dscritic                             NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen01   AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen04   AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen06   AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE URA.html

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.

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
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

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

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_conta_teste w-html  _WEB-HTM-OFFSETS
PROCEDURE p_conta_teste:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   /* Conta TESTE */
   IF   aux_nrdconta = 999          AND
        aux_dsdsenha = "01123456"   THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = aux_cdcooper   AND
                               crapass.nrdconta = 396
                               USE-INDEX crapass1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass THEN
                 {&OUT} "falso".
            ELSE                    
                 DO:
                     FIND FIRST crapsnh WHERE 
                                crapsnh.cdcooper = aux_cdcooper     AND  
                                crapsnh.nrdconta = crapass.nrdconta AND
                                crapsnh.tpdsenha = 2   
                                NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapsnh THEN
                          {&OUT} "falso".
                          
                     ASSIGN aux_nrdconta = crapass.nrdconta
                            aux_dsdsenha = STRING(crapsnh.cddsenha,"99999999")
                            aux_nmprimtl = "CONTA  TESTE".
                 END.
        END.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_trataerro w-html  _WEB-HTM-OFFSETS
PROCEDURE p_trataerro:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   FIND FIRST tt-erro.
           
   IF   AVAILABLE tt-erro THEN
        {&OUT} "erro".
 
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_imprime_cabec w-html  _WEB-HTM-OFFSETS
PROCEDURE p_imprime_cabec:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   FIND crapass WHERE crapass.cdcooper = aux_cdcooper   AND
                      crapass.nrdconta = aux_nrdconta   NO-LOCK NO-ERROR.
          
   IF   NOT AVAILABLE crapass THEN
        DO:
            RUN p_trataerro.
            LEAVE.
        END.
   ELSE
        /*   Se estiver preenchido refere-se a conta teste  */
        IF   aux_nmprimtl = "" THEN
             aux_nmprimtl = crapass.nmprimtl.
            
   /*  Busca limite de credito da conta-corrente  */
               
   FIND FIRST craplim WHERE craplim.cdcooper = aux_cdcooper AND
                            craplim.nrdconta = aux_nrdconta AND
                            craplim.tpctrlim = 1            AND
                            craplim.insitlim = 2            NO-LOCK NO-ERROR.

   IF   AVAILABLE craplim THEN
        aux_vllimcre = craplim.vllimite.
   ELSE
        aux_vllimcre = 0.     
             
                 
   /* -----------------------  Imprime  IMAGEM  ---------------------------- */

   IF   aux_cdcooper = 1   THEN
        aux_dsdlinha = "@@imagem /dg/som/viacredi.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 2   THEN 
	    aux_dsdlinha = "@@imagem /dg/som/acredicoop.bmp,16,0".
   ELSE                       
   IF   aux_cdcooper = 5   THEN 
        aux_dsdlinha = "@@imagem /dg/som/acentra.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 6   THEN
        aux_dsdlinha = "@@imagem /dg/som/unilos.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 7   THEN
        aux_dsdlinha = "@@imagem /dg/som/credcrea.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 8   THEN
        aux_dsdlinha = "@@imagem /dg/som/credelesc.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 9   THEN
        aux_dsdlinha = "@@imagem /dg/som/transpocred.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 10  THEN
        aux_dsdlinha = "@@imagem /dg/som/credicomin.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 11  THEN
        aux_dsdlinha = "@@imagem /dg/som/credifoz.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 12  THEN
        aux_dsdlinha = "@@imagem /dg/som/crevisc.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 13  THEN
        aux_dsdlinha = "@@imagem /dg/som/civia.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 14  THEN
        aux_dsdlinha = "@@imagem /dg/som/evolua.bmp,16,0".
   ELSE
   IF   aux_cdcooper = 16  THEN
        aux_dsdlinha = "@@imagem /dg/som/altovale.bmp,16,0".
     
   /* Configura 66 linhas por página */
   {&OUT} CHR(27) + CHR(67) + CHR(66) '"' aux_dsdlinha '"\n'.
                              
   /*  Espacamento  */
   DO  aux_contador = 1 TO 8:
       {&OUT} '\n'.
   END.
  
   /* ----------------------  Imprime  CABECALHO  -------------------------- */

  
   CASE aux_operacao:
        WHEN 4 THEN ASSIGN aux_dsdcabec = 
               "                         EXTRATO DE APLICACOES              ".
        WHEN 5 THEN ASSIGN aux_dsdcabec =
               "                       EXTRATO DE CONTA CORRENTE           ".
        WHEN 6 THEN ASSIGN aux_dsdcabec =
               "               EXTRATO DE CONTA CORRENTE (ULTIMOS 5 DIAS)  ".
        WHEN 7 THEN ASSIGN aux_dsdcabec =
               "                EXTRATO DE CONTA CORRENTE (MES ANTERIOR)   ".
   END CASE.

   ASSIGN aux_dsdlinha = aux_dsdcabec + "EMISSAO: " +
                         STRING(TODAY,"99/99/9999").
            
   
   {&OUT} aux_dsdlinha '\n'.
   {&OUT} '\n'.
             
   aux_dsdlinha = "CONTA/DV: " + STRING(aux_nrdconta,"zzzz,zzz,9") +
                  "           TITULAR: " + STRING(aux_nmprimtl,"x(40)").
            
   {&OUT} aux_dsdlinha '\n'.
   {&OUT} '\n'.

   IF   aux_operacao <> 4 THEN    /*   Para  Extratos LCM   */
        DO:
            FIND FIRST tt-saldos NO-LOCK NO-ERROR.
                             
            ASSIGN aux_vlsldant = tt-saldos.vlsddisp +
                                  tt-saldos.vlsdchsl +
                                  tt-saldos.vlsdbloq +
                                  tt-saldos.vlsdblpr +
                                  tt-saldos.vlsdblfp.
           
            aux_dsdlinha = "LIMITE DE CREDITO: " + 
                           STRING(aux_vllimcre,"zzz,zzz,zz9.99") +
                           "               SALDO ANTERIOR: " +
                           STRING(aux_vlsldant,"zzz,zzz,zz9.99-").
            
            {&OUT} aux_dsdlinha '\n'.
            {&OUT} '\n'.
            
            aux_dsdlinha = "DATA     HISTORICO             LIBER   " +
                           "DOCUMENTO         VALOR           SALDO". 
            
                            
            {&OUT} aux_dsdlinha '\n'.
            
            aux_dsdlinha = "-------- --------------------- ----- -----------" +
                           " ------------ - --------------".
             
                           
            {&OUT} aux_dsdlinha '\n'.

            /* Começa com 16 linhas para o cabeçalho */ 
            ASSIGN aux_contador = 16.
        END.
 
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_imprime_cabec_2 w-html  _WEB-HTM-OFFSETS
PROCEDURE p_imprime_cabec_2:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
   IF   aux_operacao <> 4 THEN    /*   Para  Extratos LCM   */
        DO:
            aux_dsdlinha = "DATA     HISTORICO             LIBER   " +
                           "DOCUMENTO         VALOR           SALDO". 

            {&OUT} aux_dsdlinha '\n'.

            aux_dsdlinha = "-------- --------------------- ----- -----------" +
                           " ------------ - --------------".

            {&OUT} aux_dsdlinha '\n'.
        END.
   ELSE                           /*   Para  Extratos APL e PPR   */
        DO:
            aux_dsdlinha = aux_dsdlinha                               +
                           "DATA       TIPO                       VALOR"  +
                           "   DOCUMENTO      DIA SITUAC.           SALDO" +
                           "\n"                                       +
                           "---------- -------------------- ---------------"  +
                           " ----------- --- ------- ---------------" +
                           "\n".
        END.


   /* 2 linhas no novo cabeçalho */
   aux_contador = 2.
 
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_imprime_cabec_3 w-html  _WEB-HTM-OFFSETS
PROCEDURE p_imprime_cabec_3:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  
    aux_dsdlinha = aux_dsdlinha                               +
                   "\n" + "\n" +
                   "DATA       TIPO                 VALOR"  +
                   "   DOCUMENTO DIA  DT.VENCTO S        SALDO" +
                   "\n"                                       +
                   "---------- -------------- -----------"  +
                   " ----------- --- ---------- - ------------" +
                   "\n".
  
    {&OUT} aux_dsdlinha.
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_imprime_cabec_4 w-html  _WEB-HTM-OFFSETS
PROCEDURE p_imprime_cabec_4:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
   aux_dsdlinha = "DATA       TIPO                         VALOR " +
                           "  DOCTO  DT.VENCTO S        SALDO".
                            
    {&OUT} aux_dsdlinha '\n'.
    
    aux_dsdlinha = "---------- -------------------- ------------- " +
                   "------- ---------- - ------------".
                   
    {&OUT} aux_dsdlinha '\n'.
    
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_imprime_trailer w-html  _WEB-HTM-OFFSETS
PROCEDURE p_imprime_trailer:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   aux_dsdlinha = " ".
   
   {&OUT} aux_dsdlinha '\n'.

   aux_dsdlinha = "===============================================" +
                  "================================".
                           
   {&OUT} aux_dsdlinha '\n'.

   aux_dsdlinha = "@".
   
   {&OUT} aux_dsdlinha.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_validasenha w-html  _WEB-HTM-OFFSETS
PROCEDURE p_validasenha:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes: 
------------------------------------------------------------------------------*/
   FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper
                        AND crapass.nrdconta = aux_nrdconta
   NO-LOCK NO-ERROR.
   IF NOT AVAILABLE crapass THEN
   DO:
     FIND crapcri WHERE crapcri.cdcritic = 564 NO-LOCK NO-ERROR.
     IF AVAILABLE crapcri THEN
       ASSIGN aux_cdcritic = 564
              aux_dscritic = TRIM(crapcri.dscritic).
     ELSE
       ASSIGN aux_cdcritic = 0
              aux_dscritic =  "Conta invalida".
              
       ASSIGN aux_dsmsgerr = "<CECRED><pr_dscritic>" + TRIM(aux_dscritic) + 
                             "</pr_dscritic>"+
                             "<pr_cdmsgerr>" + STRING(aux_cdcritic) + 
                             "</pr_cdmsgerr></CECRED>".
           
       {&OUT} aux_dsmsgerr.
   END.
   ELSE
   DO: 
     FIND FIRST crapsnh WHERE crapsnh.cdcooper = aux_cdcooper  AND
                              crapsnh.nrdconta = aux_nrdconta  AND
                              crapsnh.tpdsenha = 2
                              USE-INDEX crapsnh1 NO-LOCK NO-ERROR.
     
     IF NOT AVAILABLE crapsnh THEN
     DO:
       FIND crapcri WHERE crapcri.cdcritic = 1125 NO-LOCK NO-ERROR.
         IF AVAILABLE crapcri THEN
           ASSIGN aux_cdcritic = 1125
                  aux_dscritic = TRIM(crapcri.dscritic).
         ELSE
           ASSIGN aux_cdcritic = 0
                  aux_dscritic =  "Falha ao buscar senha".
                  
         ASSIGN aux_dsmsgerr = "<CECRED><pr_dscritic>" + TRIM(aux_dscritic) + 
                               "</pr_dscritic>"+
                               "<pr_cdmsgerr>" + STRING(aux_cdcritic) + 
                               "</pr_cdmsgerr></CECRED>".
          
         {&OUT} aux_dsmsgerr.
     END.
     ELSE
     DO:
       /*Verificar a senha*/
       IF INTEGER(crapsnh.cddsenha) = INTEGER(aux_dsdsenha) THEN 
       DO: /*Se a senha informada existir*/
         {&OUT} "<CECRED><pr_dscritic></pr_dscritic><pr_cdmsgerr></pr_cdmsgerr></CECRED>". 
       END.
       ELSE
       DO: /*Caso a senha seja diferente*/
         /* Conta Teste */
         IF   aux_nmprimtl = "CONTA  TESTE"   THEN
         DO:
           {&OUT} "<CECRED><pr_dscritic></pr_dscritic><pr_cdmsgerr></pr_cdmsgerr></CECRED>". 
         END.
         ELSE
         DO: /*Apresentar erro generico*/
           FIND crapcri WHERE crapcri.cdcritic = 3 NO-LOCK NO-ERROR.
           IF AVAILABLE crapcri THEN
             ASSIGN aux_cdcritic = 3
                    aux_dscritic = TRIM(crapcri.dscritic).
            ELSE
              ASSIGN aux_cdcritic = 0
                     aux_dscritic =  "Senha invalida".
              ASSIGN aux_dsmsgerr = "<CECRED><pr_dscritic>" + TRIM(aux_dscritic) + 
                                    "</pr_dscritic>"+
                                    "<pr_cdmsgerr>" + STRING(aux_cdcritic) + 
                                    "</pr_cdmsgerr></CECRED>".
                 
           {&OUT} aux_dsmsgerr.
         END.       
       END.
     END.
   END.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_cria_crapura w-html              ~    _WEB-HTM-OFFSETS
PROCEDURE p_cria_crapura:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   DO  TRANSACTION ON ERROR UNDO, LEAVE:
   
       aux_dsdahora = STRING(TIME,"HH:MM:SS").
       
       DO WHILE TRUE:
       
          FIND crapura WHERE crapura.cdcooper = aux_cdcooper   AND
                             crapura.dtconsul = aux_dtmvtolt   AND
                             crapura.hrconsul = aux_dsdahora   AND
                             crapura.nrdconta = aux_nrdconta   AND
                             crapura.tpconsul = aux_operacao
                             NO-LOCK NO-ERROR.

          IF   AVAILABLE crapura THEN
               aux_dsdahora = STRING(TIME + 10,"HH:MM:SS").
          ELSE
               LEAVE.
          
       END.  /*  Fim do DO WHILE TRUE  */

       CREATE crapura.
       ASSIGN crapura.cdcooper = aux_cdcooper
              crapura.dtconsul = aux_dtmvtolt
              crapura.hrconsul = aux_dsdahora
              crapura.nrdconta = aux_nrdconta
              crapura.tpconsul = aux_operacao.
      VALIDATE crapura.
   END.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
 

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_saldos w-html  _WEB-HTM-OFFSETS
PROCEDURE p_saldos:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    /* Busca saldos de C/C */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        
    /* Utilizar o tipo de busca A, para carregar do dia anterior
      (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
    RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper,
                                              INPUT 1, /* cdagenci */
                                              INPUT 999, /* nrdcaixa */
                                              INPUT "996", 
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT "A", /* Tipo Busca */
                                             OUTPUT 0,
                                             OUTPUT "").
        
    CLOSE STORED-PROC pc_obtem_saldo_dia_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                              WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                              WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
        
    IF aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
    DO: 
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic 
               tt-erro.dscritic = aux_dscritic. 
        RUN p_trataerro.
        LEAVE.
    END.
    ELSE 
    DO:
        /* Atribuir os saldos */
        /*************************************************************/
        FIND FIRST wt_saldos NO-LOCK NO-ERROR.
        IF AVAIL wt_saldos THEN
        DO:
            ASSIGN aux_vlsddisp = wt_saldos.vlsddisp +
                                  wt_saldos.vlsdchsl +
                                  wt_saldos.vlsdbloq +
                                  wt_saldos.vlsdblpr +
                                  wt_saldos.vlsdblfp.
        END.
    END.

   /* Busca saldo e limite de conta-corrente */
               
   FIND FIRST craplim WHERE craplim.cdcooper = aux_cdcooper AND
                            craplim.nrdconta = aux_nrdconta AND
                            craplim.tpctrlim = 1            AND
                            craplim.insitlim = 2
                            NO-LOCK NO-ERROR.

   IF   AVAILABLE craplim THEN
        aux_vllimcre = craplim.vllimite.
   ELSE
        aux_vllimcre = 0.
        
   /* Busca e calcula saldo total de aplicacoes */

   FIND FIRST craprda WHERE craprda.cdcooper = aux_cdcooper AND
                            craprda.nrdconta = aux_nrdconta AND
                            craprda.insaqtot = 0 
                            USE-INDEX craprda3  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craprda THEN
        ASSIGN aux_vlsdrdca = 0.
   ELSE
        DO:
             /** Saldo das aplicacoes **/
             RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                SET h-b1wgen0081.        
           
             IF  VALID-HANDLE(h-b1wgen0081)  THEN
                DO:
                    
                    RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                              (INPUT aux_cdcooper,
                                               INPUT 996,
                                               INPUT 1,
                                               INPUT 1,
                                               INPUT "URA",
                                               INPUT 6,
                                               INPUT aux_nrdconta,
                                               INPUT 1,
                                               INPUT 0,
                                               INPUT "URA",
                                               INPUT FALSE,
                                               INPUT ?,
                                               INPUT ?,
                                               OUTPUT aux_vlsldtot,
                                               OUTPUT TABLE tt-saldo-rdca,
                                               OUTPUT TABLE tt-erro).
                
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            DELETE PROCEDURE h-b1wgen0081.
                            
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                         
                            IF  AVAILABLE tt-erro  THEN
                                ASSIGN aux_cdcritic = tt-erro.cdcritic
                                       aux_dscritic = tt-erro.dscritic.
                        
                            RUN proc_gerar_log (INPUT aux_cdcooper,
                                                INPUT 1,
                                                INPUT aux_dscritic,
                                                INPUT "URA",
                                                INPUT "Consulta de Saldo de Aplicacao",
                                                INPUT FALSE,
                                                INPUT 1,
                                                INPUT "URA",
                                                INPUT aux_nrdconta,
                                               OUTPUT aux_nrdrowid).
                
                            RETURN "NOK".
                        END.
        
                    ASSIGN aux_vlsldapl = aux_vlsldtot.
        
                    DELETE PROCEDURE h-b1wgen0081.
                END.
             
             ASSIGN aux_vlsldtot = 0
                    aux_vlsldrgt = 0.
            
             /*Busca Saldo Novas Aplicacoes*/
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        
              RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT aux_cdcooper, /* Código da Cooperativa */
                                         INPUT '996',            /* Código do Operador */
                                         INPUT "URA", /* Nome da Tela */
                                         INPUT 6,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT aux_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                         INPUT aux_dtmvtolt, /* Data de Movimento */
                                         INPUT 0,            /* Código do Produto */
                                         INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                         INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                        OUTPUT 0,            /* Saldo Total da Aplicação */
                                        OUTPUT 0,            /* Saldo Total para Resgate */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descrição da crítica */
              
              CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
              
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_vlsldtot = 0
                     aux_vlsldrgt = 0
                     aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                     WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                     aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                                     WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                     aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                                     WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
                     aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                     WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.
              
              IF aux_cdcritic <> 0   OR
                 aux_dscritic <> ""  THEN
                 DO:
                     IF aux_dscritic = "" THEN
                        DO:
                           FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                              NO-LOCK NO-ERROR.
            
                           IF AVAIL crapcri THEN
                              ASSIGN aux_dscritic = crapcri.dscritic.
            
                        END.
            
                     CREATE tt-erro.
            
                     ASSIGN tt-erro.cdcritic = aux_cdcritic
                            tt-erro.dscritic = aux_dscritic.
              
                     RETURN "NOK".
                                    
                 END.
             
             ASSIGN aux_vlsdrdca = aux_vlsldapl + aux_vlsldrgt.
             
             /*Fim Busca Saldo Novas Aplicacoes*/
        END.

   
   /* Busca e calcula saldo total de poupanca programada */
           
   FIND FIRST craprpp WHERE craprpp.cdcooper = aux_cdcooper AND
                            craprpp.nrdconta = aux_nrdconta NO-LOCK NO-ERROR.

   IF   AVAILABLE craprpp THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0006.p 
                PERSISTENT SET h-b1wgen06.                      
                                                                               
            IF  VALID-HANDLE(h-b1wgen06)  THEN
                DO:
                    RUN consulta-poupanca IN h-b1wgen06 
                                         (INPUT aux_cdcooper,
                                          INPUT 1,
                                          INPUT 999,
                                          INPUT "996",
                                          INPUT "URA",
                                          INPUT 6,
                                          INPUT aux_nrdconta,
                                          INPUT 1,
                                          INPUT 0,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_dtmvtopr,
                                          INPUT aux_inproces,
                                          INPUT "URA",
                                          INPUT FALSE,
                                         OUTPUT aux_vlsdrdpp,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dados-rpp).
                                                                 
                    DELETE PROCEDURE h-b1wgen06.

                    IF   RETURN-VALUE = "NOK"   THEN                   
                         DO:
                             RUN p_trataerro.
                             LEAVE.
                         END.                                        
                    ELSE                                            
                         ASSIGN aux_vlsdrdca = aux_vlsdrdca + aux_vlsdrdpp.
                END.
        END.

   IF   aux_vlsddisp < 0 THEN
        aux_dsdlinha = "saldo=" + STRING(aux_vlsddisp,"-999999999.99").
   ELSE 
        aux_dsdlinha = "saldo=" + STRING(aux_vlsddisp,"999999999.99"). 
       
   aux_dsdlinha = aux_dsdlinha + " limite=" + 
                                 STRING(aux_vllimcre,"999999999.99").
                        
   IF   aux_vlsdrdca < 0 THEN
        aux_dsdlinha = aux_dsdlinha + " apl=" +
                       STRING(aux_vlsdrdca,"-999999999.99").
   ELSE 
        aux_dsdlinha = aux_dsdlinha + " apl=" +
                       STRING(aux_vlsdrdca,"999999999.99").
                                 
   aux_dsdlinha = aux_dsdlinha.
 
   {&OUT} aux_dsdlinha '\n'.
   
   RUN p_cria_crapura.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
                                  
                                  

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_extrato_mes w-html  _WEB-HTM-OFFSETS
PROCEDURE p_extrato_mes:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

   /*   Calcula data de inicio e data de fim dos Lancamentos   */
   
   CASE aux_operacao:
        WHEN 5 THEN ASSIGN aux_dtinicio = DATE(MONTH(aux_dtmvtolt),
                                               01,
                                               YEAR(aux_dtmvtolt))
                           aux_dttermin = aux_dtmvtolt.
        WHEN 6 THEN ASSIGN aux_dtinicio = aux_dtmvtolt - 5
                           aux_dttermin = aux_dtmvtolt.
        WHEN 7 THEN ASSIGN aux_dttermin = aux_dtmvtolt - DAY(aux_dtmvtolt)
                           aux_dtinicio = DATE(MONTH(aux_dttermin),01,
                                               YEAR(aux_dttermin)).
   END CASE.

 

   RUN sistema/generico/procedures/b1wgen0001.p
       PERSISTENT SET h-b1wgen01.

   RUN obtem-saldo IN h-b1wgen01 (INPUT aux_cdcooper,
                                  INPUT 1,
                                  INPUT 999,
                                  INPUT "996",
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtinicio,
                                  INPUT 6,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-saldos).
                    
   IF   VALID-HANDLE(h-b1wgen01) THEN
        DELETE PROCEDURE h-b1wgen01.
   
   IF   RETURN-VALUE = "NOK" THEN
        DO:
            RUN p_trataerro.
            LEAVE.
        END.
   ELSE
        DO:
            RUN sistema/generico/procedures/b1wgen0001.p
                PERSISTENT SET h-b1wgen01.

            RUN consulta-extrato IN h-b1wgen01 (INPUT aux_cdcooper,
                                                INPUT 1,
                                                INPUT 999,
                                                INPUT "996",
                                                INPUT aux_nrdconta,
                                                INPUT aux_dtinicio,
                                                INPUT aux_dttermin,
                                                INPUT 6,
                                                INPUT 1,
                                                INPUT "URA",
                                                INPUT TRUE, /** Log **/
                                               OUTPUT TABLE tt-erro,
                                               OUTPUT TABLE tt-extrato_conta).

            IF   VALID-HANDLE(h-b1wgen01) THEN
                 DELETE PROCEDURE h-b1wgen01.
            
            IF   RETURN-VALUE = "NOK" THEN
                 DO:
                     RUN p_trataerro.
                     LEAVE.
                 END.
            ELSE
                 DO:
                     RUN p_imprime_cabec.   /*   Imprime Cabecalho FAX  */

                     FOR EACH tt-extrato_conta NO-LOCK 
                             BREAK BY tt-extrato_conta.nrdconta
                                      BY tt-extrato_conta.dtmvtolt
                                         BY tt-extrato_conta.nrsequen:

						 
                         ASSIGN aux_dscomple = "".
                         IF tt-extrato_conta.dscomple <> ?  AND  
                            tt-extrato_conta.dscomple <> "" THEN						 						
						    aux_dscomple =  STRING(" - " + tt-extrato_conta.dscomple).    
						                           
                         aux_dsdlinha = STRING(tt-extrato_conta.dtmvtolt,
                                               "99/99/99") + " " +
                                        STRING(tt-extrato_conta.dsextrat + aux_dscomple,
                                               "x(21)") + " " +
                                        STRING(SUBSTR(tt-extrato_conta.dtliblan,2,5),
                                              "X(05)") + " " +
                                        STRING(tt-extrato_conta.nrdocmto,
                                               "X(11)") + " " +
                                        STRING(tt-extrato_conta.vllanmto,
                                               "zzzzz,zz9.99") + " " +
                                        STRING(tt-extrato_conta.indebcre,
                                               "x") + " ".

                         IF   tt-extrato_conta.vlsdtota <> 0 THEN
                              aux_dsdlinha = aux_dsdlinha +
                                             STRING(tt-extrato_conta.vlsdtota,
                                                    "zz,zzz,zz9.99-").

                         {&OUT} aux_dsdlinha '\n'.

                         ASSIGN aux_dsdlinha = ""
                                aux_contador = aux_contador + 1.

                         /* Imprimiu uma página inteira */
                         IF   aux_contador = 66   THEN
                              RUN p_imprime_cabec_2.
                     END.

                     FIND FIRST tt-saldos WHERE tt-saldos.cdcooper = aux_cdcooper
                                            AND tt-saldos.nrdconta = aux_nrdconta
                                            NO-LOCK NO-ERROR.

                     IF  AVAIL tt-saldos THEN
                         DO:
                            IF  tt-saldos.vlblqjud > 0 THEN
                                DO:
                                   aux_dsdlinha = "Valor Bloqueado Judicialmente "
                                                + "e de: " + 
                                                   STRING(tt-saldos.vlblqjud,
                                                          "zzz,zzz,zzz,zz9.99").

                                   {&OUT} aux_dsdlinha '\n'.
                                END.
                         END.

                     RUN p_imprime_trailer.   /*   Imprime Trailer FAX  */

                 END.
        END.

   RUN p_cria_crapura.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p_extrato_apl w-html  _WEB-HTM-OFFSETS
PROCEDURE p_extrato_apl:
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    DEF VAR aux_flgregis AS LOGI      NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE            NO-UNDO.   
    DEF VAR xRoot         AS HANDLE            NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE            NO-UNDO.  
    DEF VAR xField        AS HANDLE            NO-UNDO. 
    DEF VAR xText         AS HANDLE            NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER           NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER           NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR            NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR          NO-UNDO.

    DEF VAR aux_cdcritic AS INT                NO-UNDO.
    DEF VAR aux_dscritic AS CHAR               NO-UNDO.    

    DEF VAR aux_vldsaldo AS DECI               NO-UNDO.
    DEF VAR aux_vlsldapl AS DECIMAL DECIMALS 8 NO-UNDO.
    DEF VAR aux_vlsldrgt AS DECI               NO-UNDO.
    
    RUN p_imprime_cabec. /* Imprime Cabecalho FAX */
    
    ASSIGN aux_vltotrdc = 0
           aux_vltotppr = 0
           aux_flgregis = FALSE
           aux_dsdlinha = ""
           aux_vlblqjud = 0
           aux_vlresblq = 0
           aux_vlblqapl_gar = 0
           aux_vlblqpou_gar = 0.

    /*** Busca Saldo Bloqueado Judicial ***/
    FIND FIRST crapdat WHERE crapdat.cdcooper = aux_cdcooper 
                       NO-LOCK NO-ERROR.
    
    IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.
    
    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT aux_cdcooper,
                                             INPUT aux_nrdconta,
                                             INPUT 0, /* fixo - nrcpfcgc */
                                             INPUT 0, /* fixo - cdtipmov */
                                             INPUT 2, /* 2 - Aplicacao */
                                             INPUT crapdat.dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).
    
    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

    /*** Busca Saldo Bloqueado Garantia ***/
    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p 
            PERSISTENT SET h-b1wgen0112.

    RUN calcula_bloq_garantia IN h-b1wgen0112
                             ( INPUT aux_cdcooper,
                               INPUT aux_nrdconta,                                             
                              OUTPUT aux_vlblqapl_gar,
                              OUTPUT aux_vlblqpou_gar,
                              OUTPUT aux_dscritic).

    IF aux_dscritic <> "" THEN
    DO:
       
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic 
               tt-erro.dscritic = aux_dscritic. 
        RUN p_trataerro.
        LEAVE.         
    END.
        
    IF  VALID-HANDLE(h-b1wgen0112) THEN
        DELETE PROCEDURE h-b1wgen0112. 

    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/
    
    EMPTY TEMP-TABLE tt-saldo-rdca.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_lista_aplicacoes_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper,     /* Código da Cooperativa */
                                            INPUT "996",            /* Código do Operador */
                                            INPUT "InternetBank",   /* Nome da Tela */
                                            INPUT 3,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT 900,              /* Numero do Caixa */
                                            INPUT aux_nrdconta,     /* Número da Conta */
                                            INPUT 1,                /* Titular da Conta */
                                            INPUT 90,               /* Codigo da Agencia */
                                            INPUT "InternetBank",   /* Codigo do Programa */
                                            INPUT 0,                /* Número da Aplicação - Parâmetro Opcional */
                                            INPUT 0,                /* Código do Produto – Parâmetro Opcional */ 
                                            INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                            INPUT 6,                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                            INPUT 1,                /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
                                           OUTPUT ?,                /* XML com informações de LOG */
                                           OUTPUT 0,                /* Código da crítica */
                                           OUTPUT "").              /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_lista_aplicacoes_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                          WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
           aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                          WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.
    
    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic 
               tt-erro.dscritic = aux_dscritic. 
        RUN p_trataerro.
        LEAVE.    
     END.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
     
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
        IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT. 
    
        IF xRoot2:NUM-CHILDREN > 0 THEN
          CREATE tt-saldo-rdca.
          
        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
            
            xRoot2:GET-CHILD(xField,aux_cont).
                
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
            
            xField:GET-CHILD(xText,1).
            
            ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
            ASSIGN tt-saldo-rdca.qtdiauti = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
            ASSIGN tt-saldo-rdca.vlaplica = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
            ASSIGN tt-saldo-rdca.nrdocmto =      xText:NODE-VALUE  WHEN xField:NAME = "nrdocmto".
            ASSIGN tt-saldo-rdca.indebcre =      xText:NODE-VALUE  WHEN xField:NAME = "indebcre".
            ASSIGN tt-saldo-rdca.vlaplica = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
            ASSIGN tt-saldo-rdca.vllanmto = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
            ASSIGN tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
            ASSIGN tt-saldo-rdca.cddresga =      xText:NODE-VALUE  WHEN xField:NAME = "cddresga".
            ASSIGN tt-saldo-rdca.txaplmax =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmax".
            ASSIGN tt-saldo-rdca.txaplmin =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmin".
            ASSIGN tt-saldo-rdca.dshistor =      xText:NODE-VALUE  WHEN xField:NAME = "dshistor".
            ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
            ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
            ASSIGN tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto".
            ASSIGN tt-saldo-rdca.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
            ASSIGN tt-saldo-rdca.idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".
            ASSIGN tt-saldo-rdca.tpaplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "tpaplica".
              
        END. 
        
    END.
    
    SET-SIZE(ponteiro_xml) = 0. 
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
            
    VALIDATE tt-saldo-rdca.

    IF NOT TEMP-TABLE tt-saldo-rdca:HAS-RECORDS THEN
        DO:
            LEAVE.
        END.
    
    RUN p_imprime_cabec_4.

    ASSIGN aux_dsdlinha = "".

    FOR EACH tt-saldo-rdca NO-LOCK:
                
        aux_dsdlinha = aux_dsdlinha + 
                       STRING(tt-saldo-rdca.dtmvtolt,"99/99/9999") 
                       + " " +
                       STRING(tt-saldo-rdca.dshistor,"x(20)") 
                       + " " +
                       STRING(tt-saldo-rdca.vlaplica,"zzzzzz,zz9.99") 
                       + " " +
                       STRING(int(tt-saldo-rdca.nrdocmto),"zzzzzz9").

        ASSIGN aux_dsdlinha = aux_dsdlinha + " ".

        IF tt-saldo-rdca.idtipapl = "A" AND 
           (tt-saldo-rdca.tpaplica = 3 OR
            tt-saldo-rdca.tpaplica = 5) THEN
            aux_dsdlinha = aux_dsdlinha + "          ".
        ELSE
            aux_dsdlinha = aux_dsdlinha +
                           STRING(tt-saldo-rdca.dtvencto,"99/99/9999").
                       
        aux_dsdlinha = aux_dsdlinha + " ".
         
        IF tt-saldo-rdca.indebcre <> "" THEN
          ASSIGN aux_dsdlinha = aux_dsdlinha + TRIM(STRING(tt-saldo-rdca.indebcre,"x(3)")).
        ELSE
          ASSIGN aux_dsdlinha = aux_dsdlinha + " ".
                       
        aux_dsdlinha = aux_dsdlinha + " ".

        IF tt-saldo-rdca.sldresga >= 0  THEN
            ASSIGN aux_dsdlinha = aux_dsdlinha + STRING(dec(tt-saldo-rdca.sldresga), "z,zzz,zz9.99")
                   aux_vltotrdc = DEC(aux_vltotrdc) + DEC(tt-saldo-rdca.sldresga). 
        ELSE
            ASSIGN aux_dsdlinha = aux_dsdlinha + STRING(0,"z,zzz,zz9.99").

        ASSIGN aux_dsdlinha = aux_dsdlinha + "\n"
               aux_contador = aux_contador + 1
               aux_flgregis = TRUE.

        /* Imprimiu uma página inteira */
        IF aux_contador = 66  THEN
            RUN p_imprime_cabec_2.
            

    END. /* Fim do FOR EACH tt-saldo-rdca */
    
    {&OUT} aux_dsdlinha '\n'.

    IF aux_flgregis  THEN
      DO:
                
        aux_dsdlinha = "                                       " +
                       "                            ------------".
        
        {&OUT} aux_dsdlinha '\n'.
        
        aux_dsdlinha = "                                       " +
                       "                          " +
                       STRING(aux_vltotrdc,"zzz,zzz,zz9.99") .
        
        {&OUT} aux_dsdlinha '\n'.
        {&OUT} '\n'.
      END.
    
    ASSIGN aux_flgregis = FALSE.

    /*******FIM CONSULTA APLICACAOES**********/
    
    aux_dsdlinha = "".

    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
        SET h-b1wgen06.                      
                                                                               
    IF  VALID-HANDLE(h-b1wgen06)  THEN
        DO:
            FOR EACH tt-dados-rpp:
                DELETE tt-dados-rpp.
            END.
                                 
            RUN consulta-poupanca IN h-b1wgen06 (INPUT aux_cdcooper,
                                                 INPUT 1,
                                                 INPUT 999,
                                                 INPUT "996",
                                                 INPUT "URA",
                                                 INPUT 6,
                                                 INPUT aux_nrdconta,
                                                 INPUT 1,
                                                 INPUT 0,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_inproces,
                                                 INPUT "URA",
                                                 INPUT FALSE,
                                                OUTPUT aux_vlsdrdpp,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-rpp).
                                                                 
            DELETE PROCEDURE h-b1wgen06.
            
            IF  RETURN-VALUE = "NOK"  THEN                   
                DO:
                    RUN p_trataerro.
                    LEAVE.
                END.                                        
            
            IF NOT TEMP-TABLE tt-dados-rpp:HAS-RECORDS THEN
                DO:
                    LEAVE.
                END.

            RUN p_imprime_cabec_3.

            FOR EACH tt-dados-rpp NO-LOCK:
                         
                aux_dsdlinha = STRING(tt-dados-rpp.dtmvtolt,"99/99/9999") 
                               + " Poupanca Prog." +
                               STRING(tt-dados-rpp.vlprerpp,"z,zzz,zz9.99") 
                               + " " +
                               STRING(tt-dados-rpp.nrctrrpp,"zzz,zzz,zz9") 
                               + "  " +
                               STRING(tt-dados-rpp.indiadeb,"99") 
                               + "            " +
                               STRING(tt-dados-rpp.dssitrpp,"x") 
                               + " ". 

                IF  tt-dados-rpp.vlsdrdpp >= 0  THEN
                    ASSIGN aux_dsdlinha = aux_dsdlinha +  STRING(DEC(tt-dados-rpp.vlsdrdpp),"z,zzz,zz9.99")
                           aux_vltotppr = DEC(aux_vltotppr + tt-dados-rpp.vlsdrdpp). 
                ELSE
                    ASSIGN aux_dsdlinha = aux_dsdlinha + STRING(0,"z,zzz,zz9.99").

                {&OUT} aux_dsdlinha '\n'.

                aux_flgregis = TRUE.
                    
            END. /* Fim do FOR EACH tt-dados-rpp */
            

            IF  aux_flgregis  THEN
                DO:
                    aux_dsdlinha = "                                       " +
                                   "                            ------------".

                    {&OUT} aux_dsdlinha '\n'.

                    aux_dsdlinha = "                                       " +
                                   "                          " +
                                   STRING(aux_vltotppr,"zzz,zzz,zz9.99").

                    {&OUT} aux_dsdlinha '\n'.
                    {&OUT} '\n'.
                END.
        END.
         
    ASSIGN aux_vltotrdc = aux_vltotrdc + aux_vltotppr
           aux_dsdlinha = "                                       " +
                          " TOTAL DAS APLICACOES:    " +
                          STRING(aux_vltotrdc,"zzz,zzz,zz9.99").
   
    {&OUT} aux_dsdlinha '\n'.

    IF  aux_vlblqjud > 0 THEN
        DO:
            aux_dsdlinha = "Valor Bloqueado Judicialmente e de: " + 
                           STRING(aux_vlblqjud,"zzz,zzz,zzz,zz9.99").

            {&OUT} aux_dsdlinha '\n'.
        END.

    IF aux_vlblqapl_gar > 0 THEN 
        DO: 
            aux_dsdlinha = "Valor Bloqueado Cobertura de Garantia e de: " + 
                           STRING(aux_vlblqapl_gar,"zzz,zzz,zzz,zz9.99"). 

            {&OUT} aux_dsdlinha '\n'.
        END.
   
    RUN p_imprime_trailer.   /*   Imprime Trailer FAX  */

    RUN p_cria_crapura.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.   
  RUN outputHeader.
   */ 
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */
    
    /* STEP 4 -
     * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
     * another Web request -OR- STEP 4.2 to return the original form (the
     * default action).
     *
     * STEP 4.1 -
     * To simulate another Web request, change the REQUEST_METHOD to GET
     * and RUN the Web object here.  For example,
     *
     *  ASSIGN REQUEST_METHOD = "GET":U.
     *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
     */
     
    /* STEP 4.2 -
     * To return the form again, set data values, display them, and output 
     * them to the WEB stream.  
     *
     * STEP 4.2a -
     * Set any values that need to be set, then display them. */
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
    
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
       
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
                    
    RUN outputHeader.
                    
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
     

    /*  Recebe os parametros da URA (cooperativa) */
    ASSIGN aux_cdcooper = INT(GET-VALUE("cooperativa")).
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = aux_cdcooper  NO-LOCK NO-ERROR.

    IF   AVAILABLE crapdat THEN
         ASSIGN aux_dtmvtolt = crapdat.dtmvtolt
                aux_dtmvtopr = crapdat.dtmvtopr
                aux_inproces = crapdat.inproces.
    ELSE
         DO:
             {&OUT} "falso".
             RETURN.
         END.    
         
    
    /*  Recebe os parametros da URA (conta, senha e operacao) */
    
    ASSIGN aux_nrdconta = INT(GET-VALUE("conta"))
           aux_dsdsenha = GET-VALUE("senha")
           aux_operacao = INT(GET-VALUE("operacao")).

    FIND FIRST crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapcop THEN
         DO:
             {&OUT} "falso".
             RETURN.
         END.    

    /*   Verifica se eh conta-teste  */
    RUN p_conta_teste.

    CASE aux_operacao:
         WHEN 0 THEN RUN p_validasenha. 
         WHEN 1 THEN RUN p_saldos.
         WHEN 4 THEN RUN p_extrato_apl.
         WHEN 5 THEN RUN p_extrato_mes.
         WHEN 6 THEN RUN p_extrato_mes.
         WHEN 7 THEN RUN p_extrato_mes.   
    END CASE.

      
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    /*
    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
    */
  END.
  
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


