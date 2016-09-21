
/*.............................................................................

   Programa: fontes/zoom_origem_log.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano
   Data    : Outubro/2010                   Ultima alteracao: 30/03/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela craplgm - tipo de origem.

   Alteracoes: 30/03/2012 - Alterada a origem "CASH/TAA" para somente "CASH"
                            porque na craplgm esta armazenado "CASH"
                            (Evandro).
               
............................................................................. */

DEF  OUTPUT PARAM  par_dsorige  AS CHAR                               NO-UNDO.

DEF TEMP-TABLE crawlgm NO-UNDO
    FIELD dsorige LIKE craplgm.dsorigem.

DEF QUERY  bcraplgm-q FOR crawlgm. 
DEF BROWSE bcraplgm-b QUERY bcraplgm-q
      DISP dsorige                      COLUMN-LABEL "Tipo"
           WITH 7 DOWN OVERLAY TITLE "TIPOS DE ORIGEM".    
          
FORM bcraplgm-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 9 FRAME f_alterar.          


ON RETURN OF bcraplgm-b
   DO:
       par_dsorige = crawlgm.dsorige.
          
       CLOSE QUERY bcraplgm-q.     

       APPLY "END-ERROR" TO bcraplgm-b.
   END.

   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "AYLLOS".
       
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "CAIXA".
       
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "CASH".
        
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "INTERNET".
        
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "INTRANET".
          
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "URA".
          
   CREATE crawlgm.
   ASSIGN crawlgm.dsorige = "TODOS".
          
   
   
OPEN QUERY bcraplgm-q FOR EACH crawlgm NO-LOCK.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET bcraplgm-b WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.


/*..........................................................................*/

             
