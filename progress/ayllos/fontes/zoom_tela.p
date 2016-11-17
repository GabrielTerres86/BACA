/*.............................................................................

   Programa: fontes/zoom_tela.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei
   Data    : Outubro/2008                        Ultima alteracao: 09/12/2008 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela craptel - Cadastro de telas.

   Alteracoes: 09/12/2008 - Incluida condicao para listagem de telas do Progrid
                            (Diego).
    
............................................................................. */

{ includes/var_online.i}

DEF SHARED VAR shr_nmdatela LIKE craptel.nmdatela                      NO-UNDO.
  
DEF QUERY q_craptel FOR craptel.
 
DEF BROWSE b_craptel QUERY q_craptel
    DISPLAY craptel.nmdatela COLUMN-LABEL "Nome"
            craptel.tldatela COLUMN-LABEL "Tela"
            WITH 10 DOWN OVERLAY TITLE "TELA".    
          
FORM b_craptel HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_craptel.

ON END-ERROR OF b_craptel
   DO:
       HIDE FRAME f_craptel.
   END.

ON RETURN OF b_craptel
   DO:
       ASSIGN shr_nmdatela = craptel.nmdatela.
          
       CLOSE QUERY q_craptel.
       
       APPLY "END-ERROR" TO b_craptel.
   END.
     
   OPEN QUERY q_craptel FOR EACH craptel NO-LOCK
                           WHERE craptel.cdcooper = glb_cdcooper  AND
                                (craptel.idsistem = 2 OR  /* Progrid */ 
                                 craptel.nmrotina = "")
                              BY craptel.nmdatela.
   
   SET b_craptel WITH FRAME f_craptel.

/* .......................................................................... */
