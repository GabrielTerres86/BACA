/*.............................................................................

   Programa: fontes/zoom_ramo_atividades.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                      Ultima alteracao: 15/03/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela gnrativ - ramo de atividades.

   Alteracoes: 15/03/2010 - Adaptado para usar BO (Jose Luis, DB1)
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF INPUT PARAM par_cdseteco AS INT                              NO-UNDO.

DEF SHARED VAR shr_cdrmativ AS INTEGER                           NO-UNDO.
DEF SHARED VAR shr_nmrmativ AS CHAR      FORMAT "x(30)"          NO-UNDO.

DEF        VAR tel_dspesqrm AS CHAR      FORMAT "x(20)"          NO-UNDO.
                 
DEF QUERY  bgnrativ-q FOR tt-gnrativ. 
DEF BROWSE bgnrativ-b QUERY bgnrativ-q
      DISP tt-gnrativ.cdrmativ                 COLUMN-LABEL "Cod."
           tt-gnrativ.nmrmativ FORMAT "x(30)"  COLUMN-LABEL "Ramo Atividades"
           WITH 10 DOWN OVERLAY TITLE "RAMO DE ATIVIDADES".    
          
FORM bgnrativ-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          
          
FORM tel_dspesqrm   LABEL "Ramo"
     WITH TITLE "PESQUISA RAMO DE ATIVIDADE" SIDE-LABELS CENTERED OVERLAY ROW 6
          FRAME f_pesquisa.

/***************************************************/

   ON RETURN OF bgnrativ-b 
      DO:
          IF NOT AVAIL tt-gnrativ THEN
             RETURN.
             
          ASSIGN shr_cdrmativ = tt-gnrativ.cdrmativ
                 shr_nmrmativ = tt-gnrativ.nmrmativ.
          
          CLOSE QUERY bgnrativ-q.               
          APPLY "END-ERROR" TO bgnrativ-b.
                 
      END.

   UPDATE tel_dspesqrm WITH FRAME f_pesquisa
   EDITING:
      READKEY.
      APPLY LASTKEY.
      IF  GO-PENDING THEN
          DO:
              ASSIGN INPUT tel_dspesqrm.

              IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                  RUN sistema/generico/procedures/b1wgen0059.p
                      PERSISTENT SET h-b1wgen0059.
    
              RUN busca-gnrativ IN h-b1wgen0059
                  ( INPUT par_cdseteco,
                    INPUT 0,
                    INPUT tel_dspesqrm,
                    INPUT 999999,
                    INPUT 1,
                   OUTPUT aux_qtregist,
                   OUTPUT TABLE tt-gnrativ ).
    
              DELETE PROCEDURE h-b1wgen0059.
          END.
   END.

   HIDE FRAME f_pesquisa.

   OPEN QUERY bgnrativ-q FOR EACH tt-gnrativ BY tt-gnrativ.nmrmativ.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET bgnrativ-b WITH FRAME f_alterar.
      
   LEAVE.
         
END.  /*  Fim do DO WHILE TRUE  */
         
HIDE FRAME f_alterar NO-PAUSE.
   
           
/****************************************************************************/
