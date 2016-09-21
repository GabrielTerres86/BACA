/*............................................................................

   Programa: fontes/zoom_finalidades_de_emprestimo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Setembro/2009                       Ultima Atualizacao: 19/09/2011
     
   Dados referente ao programa:

   Frequencia: Sempre que chamado por outros programas (On-line).
   Objetivo  : Zoom das finalidades dos emprestimos. 

   Alteracoes: 01/04/2011 - Busca dados da BO generica p/ ZOOM (Gabriel, DB1)


.............................................................................*/

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }


DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INTE                              NO-UNDO.
DEF INPUT  PARAM par_nrctremp AS INTE                              NO-UNDO.

DEF OUTPUT PARAM par_nraditiv AS INTE                              NO-UNDO.


DEF VAR          aux_contador AS INTE                              NO-UNDO.
DEF VAR          aux_flgregis AS LOGI                              NO-UNDO.

DEF QUERY q-aditivos FOR tt-crapadt.


DEF BROWSE b_aditivos QUERY q-aditivos
    DISPLAY tt-crapadt.nraditiv    COLUMN-LABEL "Aditivo"
            tt-crapadt.cdaditiv    COLUMN-LABEL "Tipo"
            WITH 7 DOWN  WIDTH 25 OVERLAY TITLE " Aditivos Contratuais ".
            

FORM b_aditivos
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar." 
     SKIP
     
      WITH NO-BOX CENTERED OVERLAY ROW 8 WIDTH 25 FRAME f_alterar.

/* .........................................................................*/
    IF  NOT aux_fezbusca THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                RUN sistema/generico/procedures/b1wgen0059.p
                    PERSISTENT SET h-b1wgen0059.
            
                RUN busca-crapadt IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_nrctremp,
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapadt ).

                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.
               
        END.

/* .........................................................................*/
               
               
ON RETURN OF b_aditivos DO:
               
   IF   AVAILABLE tt-crapadt   THEN
        DO:
            ASSIGN par_nraditiv = tt-crapadt.nraditiv.
                   
                   
        END.
   
   CLOSE QUERY q-aditivos.
                  
   APPLY "END-ERROR" TO b_aditivos.     
             
END.              

OPEN QUERY q-aditivos FOR EACH tt-crapadt NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET b_aditivos WITH FRAME f_alterar.
   
   LEAVE.

END.

HIDE FRAME f_alterar.


/*............................................................................*/
