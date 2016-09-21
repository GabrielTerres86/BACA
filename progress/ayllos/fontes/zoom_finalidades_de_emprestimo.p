/*............................................................................

   Programa: fontes/zoom_finalidades_de_emprestimo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2009                        Ultima Atualizacao: 22/05/2014
     
   Dados referente ao programa:

   Frequencia: Sempre que chamado por outros programas (On-line).
   Objetivo  : Zoom das finalidades dos emprestimos. 

   Alteracoes: 01/04/2011 - Busca dados da BO generica p/ ZOOM (Gabriel, DB1)

               22/05/2014 - Removido parametro par_cdlcrhab (Reinert)
.............................................................................*/

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i }

DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
DEF INPUT  PARAM par_flgfinal AS LOGI                              NO-UNDO.

DEF OUTPUT PARAM par_cdfinemp AS INTE                              NO-UNDO.
DEF OUTPUT PARAM par_dsfinemp AS CHAR                              NO-UNDO.


DEF VAR          aux_contador AS INTE                              NO-UNDO.
DEF VAR          aux_flgregis AS LOGI                              NO-UNDO.

DEF QUERY q_crapfin FOR tt-crapfin.


DEF BROWSE b_crapfin QUERY q_crapfin
    DISPLAY tt-crapfin.cdfinemp    COLUMN-LABEL "Codigo"
            tt-crapfin.dsfinemp    COLUMN-LABEL "Descricao"  FORMAT "x(35)"
            WITH 7 DOWN OVERLAY TITLE " Finalidades de Emprestimo ".
            

FORM b_crapfin
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar." 
     SKIP
     
      WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.

/* .........................................................................*/
    IF  NOT aux_fezbusca THEN
       DO:
           ASSIGN aux_flggener = f_verconexaogener().

           IF  aux_flggener OR f_conectagener()  THEN  
               DO:
    
                  IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                      RUN sistema/generico/procedures/b1wgen0059.p
                          PERSISTENT SET h-b1wgen0059.
        
                  RUN busca-crapfin IN h-b1wgen0059
                      ( INPUT par_cdcooper,
                        INPUT 0,
                        INPUT "",
                        INPUT par_flgfinal,
                        INPUT 999999,
                        INPUT 1,
                       OUTPUT aux_qtregist,
                       OUTPUT TABLE tt-crapfin ).
        
                  DELETE PROCEDURE h-b1wgen0059.
                  
                  IF  NOT aux_flggener  THEN
                      RUN p_desconectagener.

                  ASSIGN aux_fezbusca = YES.
               END.
       END.

/* .........................................................................*/
               
               
ON RETURN OF b_crapfin DO:
               
   IF   AVAILABLE tt-crapfin   THEN
        DO:
            ASSIGN par_cdfinemp = tt-crapfin.cdfinemp
                   par_dsfinemp = tt-crapfin.dsfinemp.
                   
        END.
   
   CLOSE QUERY q_crapfin.
                  
   APPLY "END-ERROR" TO b_crapfin.     
             
END.              

OPEN QUERY q_crapfin FOR EACH tt-crapfin NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET b_crapfin WITH FRAME f_alterar.
   
   LEAVE.

END.

HIDE FRAME f_alterar.


/*............................................................................*/
