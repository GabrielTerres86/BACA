/*.............................................................................

   Programa: fontes/zoom_linhas_de_credito.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Outubro/2004                         Ultima alteracao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de linhas de credito.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
   
               13/02/2006 - Inclusao do parametro par_cdcooper para a unificacao
                            dos Bancos de dados - SQLWorks - Fernando.
                            
               11/05/2009 - Incluido coluna "Garantia" no browser (Elton).

               07/08/2009 - Alterado para poder ser utilizado na proposta
                            de emprestimo (Gabriel).

               01/04/2011 - Busca dados da BO generica p/ ZOOM (Gabriel, DB1)
               
               02/08/2011 - Ajustado para mostrar a "situacao" no browse
                            bgnetcvla-b como "liberada" ou "bloqueda"
                            (Adriano).
                            
               15/04/2014 - Adicionado campos de Taxa, Prest. Max. e Garantia
                            no browse bgnetcvla-b2. (Reinert)             
               
               12/08/2015 - Pasagem do parametro cdmodali para a procedure 
                            busca-craplcr. Projeto Portabilidade (Carlos Rafael Tanholi)             
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i }

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF INPUT  PARAM par_cdfinemp AS INT                             NO-UNDO.
DEF INPUT  PARAM par_flglinha AS LOG                             NO-UNDO.   

DEF OUTPUT PARAM par_cdlcremp AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_dslcremp AS CHAR                            NO-UNDO.
                 
DEF QUERY  bgnetcvla-q FOR tt-craplcr. 

DEF QUERY  bgnetcvla-q2 FOR tt-craplcr.

DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP cdlcremp                            COLUMN-LABEL "Cod"
           dslcremp        FORMAT "x(30)"      COLUMN-LABEL "Descricao"
           (IF tt-craplcr.flgstlcr  THEN 
               "Liberada" 
            ELSE
               "Bloqueada") FORMAT "x(9)"      COLUMN-LABEL "Situacao"
           tpctrato                            COLUMN-LABEL "Garantia" 
           WITH 7 DOWN OVERLAY TITLE " Linhas de Credito ".    

DEF BROWSE bgnetcvla-b2 QUERY bgnetcvla-q2
      DISP cdlcremp        FORMAT "zzz9"                COLUMN-LABEL "Codigo"
           dslcremp        FORMAT "x(30)"               COLUMN-LABEL "Descricao"
           STRING(txbaspre, "9.99") + "%" FORMAT "x(5)" COLUMN-LABEL "Taxa"           
           nrfimpre        FORMAT "zz9"                 COLUMN-LABEL "Prest Max"
           STRING(tpgarant, "z") + " " + dsgarant FORMAT "x(18)"    
                                                        COLUMN-LABEL "Garantia"
           WITH 7 DOWN OVERLAY TITLE " Linhas de Credito ".    

          
FORM bgnetcvla-b 
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar." 
     SKIP 
     
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

FORM bgnetcvla-b2
        HELP "Use as <SETAS> para navegar <ENTER> para selecionar."
     SKIP
             
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar2.

/* .........................................................................*/
    IF  NOT aux_fezbusca THEN
        DO:
           ASSIGN aux_flggener = f_verconexaogener().

           IF  aux_flggener OR f_conectagener()  THEN  
               DO:
                  IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                      RUN sistema/generico/procedures/b1wgen0059.p
                          PERSISTENT SET h-b1wgen0059.
        
                  RUN busca-craplcr IN h-b1wgen0059
                      ( INPUT par_cdcooper,
                        INPUT 0,
                        INPUT "",
                        INPUT par_cdfinemp,
                        INPUT par_flglinha,
                        INPUT 999999,
                        INPUT 1,
                        INPUT "", /*cdmodali*/
                       OUTPUT aux_qtregist,
                       OUTPUT TABLE tt-craplcr ).
        
                  DELETE PROCEDURE h-b1wgen0059.
                  
                  IF  NOT aux_flggener  THEN
                      RUN p_desconectagener.

                  ASSIGN aux_fezbusca = YES.
               END.
        END.

/* .........................................................................*/

ON RETURN OF bgnetcvla-b, bgnetcvla-b2  DO:

    ASSIGN par_cdlcremp = tt-craplcr.cdlcremp
           par_dslcremp = tt-craplcr.dslcremp.
          
    IF   par_flglinha   THEN
         DO:
             CLOSE QUERY bgnetcvla-q2.
             APPLY "END-ERROR" TO bgnetcvla-b2.
            
         END.
    ELSE 
         DO:
             CLOSE QUERY bgnetcvla-q.
             APPLY "END-ERROR" TO bgnetcvla-b.
         END.
            
END.

/* Linhas liberadas  - Linha e descricao */
IF   par_flglinha  THEN
     DO:
         OPEN QUERY bgnetcvla-q2 FOR EACH tt-craplcr NO-LOCK.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
            SET bgnetcvla-b2 WITH FRAME f_alterar2.
      
            LEAVE.
      
         END.  /*  Fim do DO WHILE TRUE  */
     
     END.
     /* Linhas liberadas e bloqueadas - Linha , descricao , situacao, garantia*/
ELSE
     DO:
         OPEN QUERY bgnetcvla-q FOR EACH tt-craplcr NO-LOCK.

            
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
            SET bgnetcvla-b WITH FRAME f_alterar.
      
            LEAVE.
      
         END.  /*  Fim do DO WHILE TRUE  */
     
     END.
                      
HIDE FRAME f_alterar  NO-PAUSE.

HIDE FRAME f_alterar2 NO-PAUSE.

/* .......................................................................... */

