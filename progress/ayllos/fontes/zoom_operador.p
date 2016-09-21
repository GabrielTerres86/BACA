/*.............................................................................

   Programa: fontes/zoom_operador.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Outubro/2004                          Ultima alteracao: 06/09/2013 
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do cadastro de empresas.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               04/09/2006 - Retirado conversao do cdoperad para int na abertura
                            da query (David).
               
               18/10/2006 - Incluido "PAC"  e "valor limite" do operador na
                            query (Elton).
                             
               18/05/2008 - Listagem de operadores feita em ordem alfabetica
                            (Gabriel)
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
............................................................................. */
DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
                 
DEF QUERY  bgnetcvla-q FOR crapope. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP cdoperad                            COLUMN-LABEL "Cod"
           nmoperad        FORMAT "x(40)"      COLUMN-LABEL "Nome"
           cdagenci                            COLUMN-LABEL "PA"
           vlpagchq                            COLUMN-LABEL "LIMITE"
           WITH 9 DOWN OVERLAY TITLE " Operadores ".
          
FORM bgnetcvla-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_alterar.          

ON RETURN OF bgnetcvla-b 
   DO:
       par_cdoperad = crapope.cdoperad.
          
       CLOSE QUERY bgnetcvla-q.               
       APPLY "END-ERROR" TO bgnetcvla-b.
   END.

OPEN QUERY bgnetcvla-q FOR EACH crapope WHERE 
                                crapope.cdcooper = par_cdcooper
                                NO-LOCK BY crapope.nmoperad.
   
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET bgnetcvla-b WITH FRAME f_alterar.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */

