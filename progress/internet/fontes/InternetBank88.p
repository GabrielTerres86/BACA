
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank88.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Junho/2014.                       Ultima atualizacao: 22/02/2017
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Encontra o protocolo solicitado
   
   Alteracoes: 14/10/2014 - Alterado o tipo do parametro de entrada "nrdocmto"
                            para atender os ajustes de emissao de protocolos
                            de resgate de aplicacoes
                            (Adriano). 
                            
               22/02/2017 - Alteraçoes para compor comprovantes DARF/DAS 
                            Modelo Sicredi (Lucas Lunelli)
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
DEF INPUT PARAM par_dtmvtolt AS DATE                                   NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_cdtippro LIKE crappro.cdtippro                     NO-UNDO.
DEF INPUT PARAM par_nrdocmto AS CHAR                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao88.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_busca_protocolo_wt
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT par_nrdconta,
                             INPUT par_cdtippro,
                             INPUT par_idorigem,
                             INPUT par_nrdocmto,
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_busca_protocolo_wt
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dslinxml = ""
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_busca_protocolo_wt.pr_cdcritic 
                          WHEN pc_busca_protocolo_wt.pr_cdcritic <> ?
       aux_dscritic = pc_busca_protocolo_wt.pr_dscritic
                          WHEN pc_busca_protocolo_wt.pr_dscritic <> ?.

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
               ASSIGN aux_dscritic = "Nao foi possivel encontrar o protocolo.".

         END.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                            "</dsmsgerr>".  
      
      RETURN "NOK".
       
   END.

FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAIL crapcop  THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>Cooperativa nao encontrada.</dsmsgerr>".  
        RETURN "NOK".   
    END.     

FOR EACH wt_protocolo NO-LOCK:

    CREATE xml_operacao88.

    ASSIGN xml_operacao88.dscabini = "<DADOS>"
           xml_operacao88.cdtippro = "<cdtippro>" +
                                      (IF wt_protocolo.cdtippro <> ? THEN
                                          STRING(wt_protocolo.cdtippro)
                                       ELSE 
                                          "") +
                                     "</cdtippro>"
           xml_operacao88.dtmvtolt = "<dtmvtolt>" + 
                                    (IF wt_protocolo.dtmvtolt <> ? THEN
                                        STRING(wt_protocolo.dtmvtolt,"99/99/9999")
                                     ELSE
                                        "") + 
                                     "</dtmvtolt>"
           xml_operacao88.dttransa = "<dttransa>" + 
                                     (IF wt_protocolo.dttransa <> ? THEN
                                         STRING(wt_protocolo.dttransa,"99/99/9999")
                                      ELSE
                                         "") + 
                                     "</dttransa>"
           xml_operacao88.hrautent = "<hrautent>" +
                                    (IF wt_protocolo.hrautent <> ? THEN
                                        STRING(wt_protocolo.hrautent,"HH:MM:SS") 
                                     ELSE
                                        "") +
                                     "</hrautent>"
           xml_operacao88.vldocmto = "<vldocmto>" +
                                    (IF wt_protocolo.vldocmto <> ? THEN
                                        TRIM(STRING(wt_protocolo.vldocmto,"zzz,zzz,zz9.99")) 
                                     ELSE
                                        "") +
                                     "</vldocmto>"
           xml_operacao88.nrdocmto = "<nrdocmto>" +
                                    (IF wt_protocolo.nrdocmto <> ? THEN
                                        TRIM(STRING(wt_protocolo.nrdocmto,"zzzzzzz9")) 
                                     ELSE
                                        "") +
                                     "</nrdocmto>"
           xml_operacao88.nrseqaut = "<nrseqaut>" +
                                    (IF wt_protocolo.nrseqaut <> ? THEN
                                        TRIM(STRING(wt_protocolo.nrseqaut,"zzzzzzz9")) 
                                     ELSE
                                        "") +
                                     "</nrseqaut>"
           xml_operacao88.dsinfor1 = "<dsinfor1>" +
                                    (IF wt_protocolo.dsinform[1] <> ? THEN
                                        TRIM(wt_protocolo.dsinform[1]) 
                                     ELSE
                                        "") +
                                     "</dsinfor1>"
           xml_operacao88.dsinfor2 = "<dsinfor2>" +
                                    (IF wt_protocolo.dsinform[2] <> ? THEN
                                        TRIM(wt_protocolo.dsinform[2]) 
                                     ELSE
                                        "") +
                                     "</dsinfor2>"
           xml_operacao88.dsinfor3 = "<dsinfor3>" +
                                    (IF wt_protocolo.dsinform[3] <> ? THEN
                                        TRIM(wt_protocolo.dsinform[3])
                                     ELSE
                                        "") +
                                     "</dsinfor3>"
           xml_operacao88.dsprotoc = "<dsprotoc>" + 
                                    (IF wt_protocolo.dsprotoc <> ? THEN
                                        TRIM(wt_protocolo.dsprotoc)
                                     ELSE
                                        "") +
                                     "</dsprotoc>"
           xml_operacao88.dscedent = "<dscedent>" +
                                    (IF wt_protocolo.dscedent <> ? THEN
                                        TRIM(wt_protocolo.dscedent)
                                     ELSE
                                        "") + 
                                     "</dscedent>"
           xml_operacao88.flgagend = "<cdagenda>" +
                                    (IF wt_protocolo.flgagend <> ? THEN
                                       (IF  wt_protocolo.flgagend = 1 THEN
                                            "S"
                                        ELSE
                                           "N") 
                                      ELSE
                                         "") +
                                     "</cdagenda>"
           xml_operacao88.nmprepos = "<nmprepos>" + 
                                    (IF wt_protocolo.nmprepos <> ? THEN 
                                        TRIM(wt_protocolo.nmprepos) 
                                     ELSE
                                        "") +
                                     "</nmprepos>"
           xml_operacao88.nrcpfpre = "<nrcpfpre>" +
                                    (IF wt_protocolo.nrcpfpre <> ? THEN
                                        STRING(wt_protocolo.nrcpfpre)
                                     ELSE
                                        "") +
                                     "</nrcpfpre>"
           xml_operacao88.nmoperad = "<nmoperad>" +
                                    (IF wt_protocolo.nmoperad <> ? THEN
                                        TRIM(wt_protocolo.nmoperad)
                                     ELSE
                                        "") +
                                     "</nmoperad>"
           xml_operacao88.nrcpfope  = "<nrcpfope>" +
                                    (IF wt_protocolo.nrcpfope <> ? THEN
                                        STRING(wt_protocolo.nrcpfope)
                                     ELSE
                                        "") +
                                     "</nrcpfope>"
           xml_operacao88.cdbcoctl = "<cdbcoctl>" +
                                    (IF wt_protocolo.cdbcoctl <> ? THEN
											STRING(wt_protocolo.cdbcoctl, "999")
                                     ELSE
                                        IF par_cdtippro = 16 OR 
                                           par_cdtippro = 17 OR
                                           par_cdtippro = 18 OR
                                           par_cdtippro = 19 THEN
                                           STRING(crapcop.cdbcoctl, "999")
                                        ELSE 
											"") +
                                     "</cdbcoctl>" 
           xml_operacao88.cdagectl = "<cdagectl>" +
                                    (IF wt_protocolo.cdagectl <> ? THEN
                                        STRING(wt_protocolo.cdagectl, "9999") 
                                     ELSE
                                        IF par_cdtippro = 16 OR 
                                           par_cdtippro = 17 OR
                                           par_cdtippro = 18 OR
                                           par_cdtippro = 19 THEN
                                           STRING(crapcop.cdagectl, "9999")
                                        ELSE 
											"") +
                                     "</cdagectl>"
           xml_operacao88.cdagesic = "<cdagesic>" +
                                    (IF par_cdtippro = 16 OR 
                                        par_cdtippro = 17 OR
                                        par_cdtippro = 18 OR
                                        par_cdtippro = 19 THEN
                                        STRING(crapcop.cdagesic, "9999")
                                     ELSE 
                                         "") +
                                     "</cdagesic>"
           xml_operacao88.dscabfim = "</DADOS>".

END.

RETURN "OK".


/*............................................................................*/





