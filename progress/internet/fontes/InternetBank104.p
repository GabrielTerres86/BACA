/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank104.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas
   Data    : Agosto/2014.                       Ultima atualizacao: 14/08/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Valida se o valor para resgate de aplica��es esta dentro 
               do limite (internet) parametrizado na cooperativa.
   
   Alteracoes: 11/12/2015 - Adicionado validacao do representante legal da conta.
                            (Jorge/David) - Proj. 131 Assinatura Multipla.
                            
               14/08/2018 - Inclusao da TAG <cdmsgerr> nos retornos de erro do XML,
                            Prj.427 - URA (Jean Michel)

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
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_vlresgat LIKE craprda.vlaplica                     NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valid_repre_legal_trans
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  1,  /* pr_flvldrep */
                    OUTPUT 0,
                    OUTPUT "").

CLOSE STORED-PROC pc_valid_repre_legal_trans 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
       aux_dscritic = TRIM(pc_valid_repre_legal_trans.pr_dscritic)
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
   DO:
      IF TRIM(aux_dscritic) = "" THEN
         DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
            
            IF AVAILABLE crapcri THEN
               ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
            ELSE
               ASSIGN aux_dscritic = "Nao foi possivel validar o Representante Legal.".

         END.

      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                            "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".

      RETURN "NOK".

   END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valida_limite_internet
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_vlresgat,
                             INPUT "R", /* Tipo de Movimenta��o "R" - Resgate */
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_valida_limite_internet 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valida_limite_internet.pr_cdcritic 
                          WHEN pc_valida_limite_internet.pr_cdcritic <> ?
       aux_dscritic = TRIM(pc_valida_limite_internet.pr_dscritic)
                          WHEN pc_valida_limite_internet.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
   DO:
       IF TRIM(aux_dscritic) = "" THEN
          DO:
             FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
             
             IF AVAILABLE crapcri THEN
                ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel validar o limite de internet.".

          END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                             "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".
       
       RETURN "NOK".

   END.

RETURN "OK".

/*............................................................................*/