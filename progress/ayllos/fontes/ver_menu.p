/* .............................................................................

   Programa: Fontes/ver_menu.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Julho/2003.                         Ultima atualizacao: 08/04/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Listar as telas de acordo com o modulo passado como parametro.

   Alteracoes: 24/12/2005 - Alterado para montar o menu somente com 
                            craptel.idevento <> 2. O campo craptel.idevento = 2 
                            eh para o progrid. (Rosangela)

               06/06/2006 - Alimentado campo cdcooper da tabela craptel(David).
               
               08/04/2013 - Adicionado condicao de trazer crapatel quando for 
                            crapatel.idambtel = 1 ou 0. (Jorge)
               
..............................................................................*/

DEF INPUT PARAMETER par_nrmodulo AS INTEGER                           NO-UNDO.
DEF INPUT PARAMETER par_dstitulo AS CHAR                              NO-UNDO.

DEF       VAR       aux_titlmenu AS CHAR  FORMAT "x(40)" EXTENT 5     NO-UNDO. 
DEF       VAR       aux_posregis AS ROWID                             NO-UNDO.  

DEF QUERY q_tela FOR craptel. 
                                     
DEF BROWSE b_tela QUERY q_tela 
           DISP craptel.nmdatela COLUMN-LABEL "Tela"   FORMAT "x(6)"           
                craptel.tldatela COLUMN-LABEL "Titulo" FORMAT "x(40)"
                WITH 11 DOWN TITLE TRIM(par_dstitulo) CENTERED.
                
DEF FRAME f_tela b_tela HELP "Pressione <F4> ou <END> para finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 6.       

{ includes/var_online.i }


OPEN QUERY q_tela
     FOR EACH  craptel WHERE craptel.cdcooper = glb_cdcooper AND
                             craptel.nrmodulo = par_nrmodulo AND
                             craptel.flgtelbl                AND
                             craptel.tlrestel <> ""          AND
                  /*         craptel.idsistem <> 2           AND  */
                             INDEX(craptel.nmdatela, "MENU0") = 0   AND
                             LENGTH(craptel.nmdatela) <= 6   AND
                             (craptel.idambtel = 1 OR
                              craptel.idambtel = 0)
                             NO-LOCK.
                           
ENABLE b_tela WITH FRAME f_tela.

ON VALUE-CHANGED, ENTRY OF b_tela
   DO:
      aux_posregis = ROWID(craptel).
   END.

ON RETURN OF b_tela
   DO:
      glb_nmtelant = glb_nmdatela.
      FIND craptel WHERE ROWID(craptel) = aux_posregis NO-LOCK NO-ERROR.
      
      IF   AVAILABLE craptel   THEN 
           glb_nmdatela = craptel.nmdatela.
      ELSE 
           MESSAGE "Opcao Invalida !" VIEW-AS ALERT-BOX.
           
      HIDE FRAME f-tela NO-PAUSE.    
      RETURN.
   END.
            
WAIT-FOR RETURN OF DEFAULT-WINDOW.

/* .......................................................................... */

