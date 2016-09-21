/*.............................................................................

   Programa: fontes/zoom_empresa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei
   Data    : Outubro/2008                        Ultima alteracao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom das rotina da tabela craptel - Cadastro de telas.

   Alteracoes:   /  /     - 
    
............................................................................. */

{ includes/var_online.i}

DEF SHARED VAR shr_nmdatela LIKE craptel.nmdatela                    NO-UNDO.
DEF SHARED VAR shr_nmrotina LIKE craptel.nmrotina                    NO-UNDO.
  
DEF BUFFER b-craptel FOR craptel.
                 
DEF QUERY q_craptel FOR craptel.
 
DEF BROWSE b_craptel QUERY q_craptel
    DISPLAY craptel.nmrotina COLUMN-LABEL "Rotina"
            WITH 10 DOWN OVERLAY TITLE "ROTINA".
          
FORM b_craptel HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_craptel.

ON END-ERROR OF b_craptel
   DO:
       HIDE FRAME f_craptel.
   END.

ON RETURN OF b_craptel
   DO:
       ASSIGN shr_nmrotina = craptel.nmrotina.
          
       CLOSE QUERY q_craptel.
       
       APPLY "END-ERROR" TO b_craptel.
   END.
     
   OPEN QUERY q_craptel FOR EACH craptel NO-LOCK
                           WHERE craptel.cdcooper = glb_cdcooper
                             AND craptel.nmdatela = shr_nmdatela
                              BY craptel.nmrotina.
   
   SET b_craptel WITH FRAME f_craptel.

/* .......................................................................... */
