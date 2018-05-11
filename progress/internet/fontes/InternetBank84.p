

/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank84.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Maio/2014.                       Ultima atualizacao: 14/10/2014 
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Realiza validação e inclusão de novas apliações.
   
   Alteracoes: 14/10/2014 - Devido a limitacao de caracters, foi-se necessario
                            diminuir o nome da procedure oracle
                            (Adriano).
                            

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_inproces AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                     NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_vllanmto AS DEC                                    NO-UNDO.
DEF INPUT PARAM par_tpaplica LIKE craprda.tpaplica                     NO-UNDO.
DEF INPUT PARAM par_nraplica LIKE craprda.nraplica                     NO-UNDO.
DEF INPUT PARAM par_qtdiaapl LIKE craprda.qtdiaapl                     NO-UNDO.
DEF INPUT PARAM par_dtresgat AS DATE                                   NO-UNDO.
DEF INPUT PARAM par_qtdiacar AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdperapl AS INT                                    NO-UNDO.
DEF INPUT PARAM par_flgdebci AS INT                                    NO-UNDO.
DEF INPUT PARAM par_flgerlog AS INT                                    NO-UNDO.
DEF INPUT PARAM par_flgvalid AS LOGICAL                                NO-UNDO.
DEF INPUT PARAM par_idtipapl AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocmto AS DEC                                            NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                           NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

IF par_flgvalid THEN
   DO:
      RUN STORED-PROCEDURE pc_validar_nova_aplic_wt
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_inproces,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_cddopcao,
                                   INPUT par_tpaplica,
                                   INPUT par_nraplica,
                                   INPUT par_qtdiaapl,
                                   INPUT par_dtresgat,
                                   INPUT par_qtdiacar,
                                   INPUT par_cdperapl,
                                   INPUT par_flgdebci,
                                   INPUT par_vllanmto,
                                   INPUT par_flgerlog,
                                   OUTPUT "",                             
                                   OUTPUT 0,
                                   OUTPUT "").
      
      CLOSE STORED-PROC pc_validar_nova_aplic_wt
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_dslinxml = ""
             aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_validar_nova_aplic_wt.pr_cdcritic 
                                WHEN pc_validar_nova_aplic_wt.pr_cdcritic <> ?
             aux_dscritic = pc_validar_nova_aplic_wt.pr_dscritic
                                WHEN pc_validar_nova_aplic_wt.pr_dscritic <> ?. 

      IF aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO: 
             IF aux_dscritic = "" THEN
                DO:
                   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                      NO-LOCK NO-ERROR.
      
                   IF AVAIL crapcri THEN
                      ASSIGN aux_dscritic = crapcri.dscritic.
                   ELSE
                      ASSIGN aux_dscritic =  "Nao foi possivel validar " +
                                             "os dados da aplicacao.".
      
                END.
      
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                   "</dsmsgerr>".  
      
             RETURN "NOK".
             
         END.
   END.
ELSE
   DO:
       RUN STORED-PROCEDURE pc_incluir_nova_aplic_wt
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_tpaplica,
                                   INPUT par_qtdiaapl,
                                   INPUT par_dtresgat,
                                   INPUT par_qtdiacar,
                                   INPUT par_cdperapl,
                                   INPUT par_flgdebci,
                                   INPUT par_vllanmto,
                                   INPUT par_flgerlog,
                                   INPUT par_idtipapl,
                                   OUTPUT "",   
                                   OUTPUT 0,
                                   OUTPUT "",
                                   OUTPUT 0,
                                   OUTPUT "").
      
      CLOSE STORED-PROC pc_incluir_nova_aplic_wt
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_dslinxml = ""
             aux_cdcritic = 0
             aux_dscritic = ""
             aux_cdcritic = pc_incluir_nova_aplic_wt.pr_cdcritic 
                                WHEN pc_incluir_nova_aplic_wt.pr_cdcritic <> ?
             aux_dscritic = pc_incluir_nova_aplic_wt.pr_dscritic
                                WHEN pc_incluir_nova_aplic_wt.pr_dscritic <> ?
             aux_nrdocmto = pc_incluir_nova_aplic_wt.pr_nrdocmto
                                WHEN pc_incluir_nova_aplic_wt.pr_nrdocmto <> ?
             aux_dsprotoc = pc_incluir_nova_aplic_wt.pr_dsprotoc
                                WHEN pc_incluir_nova_aplic_wt.pr_dsprotoc <> ?.

      IF aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO: 
             IF aux_dscritic = "" THEN
                DO:
                   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                      NO-LOCK NO-ERROR.
      
                   IF AVAIL crapcri THEN
                      ASSIGN aux_dscritic = crapcri.dscritic.
                   ELSE
                      ASSIGN aux_dscritic =  "Nao foi possivel validar " +
                                             "os dados da aplicacao.".
      
                END.
      
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                   "</dsmsgerr>".  
      
             RETURN "NOK".
             
         END.

      ASSIGN aux_dslinxml = "<dsprotoc>" + aux_dsprotoc + "</dsprotoc>". 

   END.

FOR EACH wt_msg_confirma NO-LOCK:
    
    
    ASSIGN aux_dslinxml = aux_dslinxml + 
                          "<MSGCONFIRMA>" + 
                              "<inconfir>" + STRING(wt_msg_confirma.inconfir) + "</inconfir>" +
                              "<dsmensag>" + STRING(wt_msg_confirma.dsmensag) + "</dsmensag>" +
                              "<nrdocmto>" + STRING(aux_nrdocmto) + "</nrdocmto>" +
                          "</MSGCONFIRMA>".

END.

CREATE xml_operacao.
    
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

RETURN "OK".


/*............................................................................*/


