/* .............................................................................

   Programa: fontes/outros_rendi_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
{includes/var_online.i "new"}

DEF VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 60 BY 4 
                    BUFFER-LINES 10       PFCOLOR 0    NO-UNDO.


FORM SKIP(1) 
     tel_dsobserv  NO-LABEL
     SKIP(1)
     "            Consultar    Incluir    Alterar   Excluir              "
     WITH ROW 13 OVERLAY SIDE-LABELS TITLE glb_tldatela CENTERED 
          FRAME f_outros_rendi_juridica.

assign glb_tldatela = "Outras Receitas".
       
DISP tel_dsobserv
     WITH FRame f_outros_rendi_juridica.

    
 