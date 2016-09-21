/* .............................................................................

   Programa: fontes/outros_rendi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

DEF VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 60 BY 4 
                    BUFFER-LINES 10       PFCOLOR 0    NO-UNDO.


FORM SKIP(1) 
     tel_dsobserv  NO-LABEL
     SKIP(1)
     "                      Incluir      Alterar"
     WITH ROW 13 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_outros_rendi.

assign glb_tldatela = "Outros Rendimentos".
       
DISP tel_dsobserv
     WITH FRame f_outros_rendi.

    
 