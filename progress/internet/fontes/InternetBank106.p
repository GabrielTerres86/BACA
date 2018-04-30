
/*..............................................................................

   Programa: siscaixa/web/InternetBank106.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Julho/2014.                       Ultima atualizacao: 11/12/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Validacao incluir agendamentos de aplicacoes e resgates.
   
   Alteracoes: 11/12/2015 - Adicionado validacao de representante quando for 
                            agendamento de resgate (Jorge/David) - Proj. 131
                            Assinatura Multipla.
                            
               05/04/2018 - Adicionada chamada da proc pc_valida_valor_adesao 
                            para verificar se o valor informado está no range 
                            permitido pelo tipo de conta. PRJ366 (Lombardi).
                            
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT PARAM par_cdcooper  LIKE    crapcop.cdcooper                 NO-UNDO.
DEF INPUT PARAM par_flgtipar  AS      INTE                             NO-UNDO.
DEF INPUT PARAM par_nrdconta  LIKE    crapaar.nrdconta                 NO-UNDO.
DEF INPUT PARAM par_idseqttl  LIKE    crapaar.idseqttl                 NO-UNDO.
DEF INPUT PARAM par_vlparaar  LIKE    crapaar.vlparaar                 NO-UNDO.
DEF INPUT PARAM par_flgtipin  AS      INTE                             NO-UNDO.
DEF INPUT PARAM par_qtdiacar  LIKE    crapaar.qtdiacar                 NO-UNDO.
DEF INPUT PARAM par_qtmesaar  LIKE    crapaar.qtmesaar                 NO-UNDO.
DEF INPUT PARAM par_dtiniaar  LIKE    crapaar.dtiniaar                 NO-UNDO.
DEF INPUT PARAM par_dtdiaaar  LIKE    crapaar.dtdiaaar                 NO-UNDO.
DEF INPUT PARAM par_dtvencto  LIKE    crapaar.dtvencto                 NO-UNDO.
DEF INPUT PARAM par_cdoperad  LIKE    crapaar.cdoperad                 NO-UNDO.
DEF INPUT PARAM par_cdprogra  AS      CHAR                             NO-UNDO.
DEF INPUT PARAM par_idorigem  AS      INTE                             NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_solcoord AS INTE                                           NO-UNDO.


ASSIGN aux_dstransa = "Validacao da inclusao de agendamentos de aplicacoes e resgates.".


FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.
/* agendamento de resgate */
IF par_flgtipar = 1 THEN
DO:
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
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic
                              WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?. 
    
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
                   ASSIGN aux_dscritic =  "Nao foi possivel validar o Representante " +
                                          "Legal.".
    
             END.
    
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                "</dsmsgerr>".  

          RUN proc_geracao_log (INPUT FALSE).
    
          RETURN "NOK".
       END.
END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_valida_valor_adesao
aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                     INPUT par_nrdconta, /* Numero da conta */
                                     INPUT 3,            /* Aplicaçao */
                                     INPUT par_vlparaar, /* Valor contratado */
                                     INPUT par_idorigem, /* Codigo do produto */
                                    OUTPUT 0,            /* Solicita senha coordenador */
                                    OUTPUT 0,            /* Codigo da crítica */
                                    OUTPUT "").          /* Descriçao da crítica */

CLOSE STORED-PROC pc_valida_valor_adesao
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_solcoord = 0
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_solcoord = pc_valida_valor_adesao.pr_solcoord 
                      WHEN pc_valida_valor_adesao.pr_solcoord <> ?
       aux_cdcritic = pc_valida_valor_adesao.pr_cdcritic 
                      WHEN pc_valida_valor_adesao.pr_cdcritic <> ?
       aux_dscritic = pc_valida_valor_adesao.pr_dscritic
                      WHEN pc_valida_valor_adesao.pr_dscritic <> ?.

IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
     DO:
         IF aux_dscritic = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                   NO-LOCK NO-ERROR.
                
                IF AVAIL crapcri THEN
                   ASSIGN aux_dscritic = crapcri.dscritic.
                ELSE
                   ASSIGN aux_dscritic =  "Nao foi possivel validar o valor de adesao.".
             END.
    
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                "</dsmsgerr>".  

          RUN proc_geracao_log (INPUT FALSE).
    
          RETURN "NOK".
     END.

RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
    SET h-b1wgen0081.
                
IF VALID-HANDLE(h-b1wgen0081)  THEN
   DO: 
      RUN validar-novo-agendamento
          IN h-b1wgen0081 (INPUT par_cdcooper,
                           INPUT par_flgtipar,
                           INPUT par_nrdconta,  
                           INPUT par_idseqttl,  
                           INPUT par_vlparaar,  
                           INPUT par_flgtipin,  
                           INPUT par_qtdiacar,  
                           INPUT par_qtmesaar,  
                           INPUT par_dtiniaar,  
                           INPUT par_dtdiaaar,  
                           INPUT par_dtvencto,  
                           INPUT "966",  
                           INPUT "INTERNETBANK",
                           INPUT 3,
                           OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0081.
         
      IF RETURN-VALUE = "NOK"  THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE
                ASSIGN aux_dscritic = "Nao foi possivel consultar agendamentos.".
                 
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

             RUN proc_geracao_log (INPUT FALSE).
             
             RETURN "NOK".
         END.

      RUN proc_geracao_log (INPUT TRUE). 
           

      RETURN "OK".
   END.

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.
/*............................................................................*/

