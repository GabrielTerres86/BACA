

/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank96.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Agosto/2014.                       Ultima atualizacao: 14/08/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Valida o horario limite de inicio/fim para utilizacao de
               operacoes pertinentes a aplicacao.
   
   Alteracoes: 14/08/2018 - Inclusao da TAG <cdmsgerr> nos retornos de erro do XML,
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
DEF INPUT PARAM par_tpvalida AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_hrlimini AS INT                                            NO-UNDO.
DEF VAR aux_hrlimfim AS INT                                            NO-UNDO.
DEF VAR aux_idesthor AS INT                                            NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_horario_limite
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT par_idorigem,
                             INPUT par_tpvalida,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT "").

CLOSE STORED-PROC pc_horario_limite 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_hrlimini = pc_horario_limite.pr_hrlimini
                          WHEN pc_horario_limite.pr_hrlimini <> ?
       aux_hrlimfim = pc_horario_limite.pr_hrlimfim
                          WHEN pc_horario_limite.pr_hrlimfim <> ?
       aux_idesthor = pc_horario_limite.pr_idesthor
                          WHEN pc_horario_limite.pr_idesthor <> ?
       aux_cdcritic = pc_horario_limite.pr_cdcritic 
                          WHEN pc_horario_limite.pr_cdcritic <> ?
       aux_dscritic = TRIM(pc_horario_limite.pr_dscritic)
                          WHEN pc_horario_limite.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
   DO:
      IF TRIM(aux_dscritic) = "" THEN
         DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
            
            IF AVAILABLE crapcri THEN
               ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
            ELSE
               ASSIGN aux_dscritic =  "Nao foi possivel validar o horario limite.".
         END.

      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                            "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".

      RETURN "NOK".

   END.

CREATE xml_operacao.

ASSIGN xml_operacao.dslinxml = "<HORARIO>" + 
                                    "<hrlimini>" + TRIM(STRING(aux_hrlimini,"HH:MM:SS")) + "</hrlimini>" + 
                                    "<hrlimfim>" + TRIM(STRING(aux_hrlimfim,"HH:MM:SS")) + "</hrlimfim>" +
                                    "<idesthor>" + TRIM(STRING(aux_idesthor))            + "</idesthor>" +
                               "</HORARIO>".

RETURN "OK".

/*............................................................................*/