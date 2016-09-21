/* .............................................................................

   Programa: Fontes/tabela.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 02/02/20067

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TABELA.

   Alteracoes: 19/08/94 - Alterado para mudar a tab003.

               28/10/94 - Incluida a tabela TAB008 (Deborah).

               11/08/95 - Incluida a tabela TAB009 (Deborah).

               21/03/96 - Incluir a tabela TAB010 (Odair).

               26/03/96 - Incluir a tabela TAB011 (Odair).

               29/04/96 - Incluir a tabela TAB012 (Odair).

               07/10/96 - Incluir a tabela TAB013 (Deborah).

               14/10/96 - Incluir a tabela TAB014 (Deborah).

               15/10/96 - Incluir a tabela TAB015 (Deborah).

               05/11/96 - Incluida a tabela TAB016 (Edson).
               
               11/05/99 - Incluir a tabela TAB017 (Odair).
               
               04/10/99 - Incluir a tabela TAB018 (Odair).

               28/05/2003 - Incluir as tabelas TAB019 e TAB020 (Edson).
               
               29/01/2004 - Alterado layout da tela (Junior).

               13/04/2004 - Alteradas tabelas para rotina 7(Mirtes).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 
............................................................................. */

DEF       VAR       aux_titlmenu AS CHAR  FORMAT "x(40)" EXTENT 5     NO-UNDO. 
DEF       VAR       aux_posregis AS ROWID                             NO-UNDO.  

DEF QUERY q_tela FOR craptel. 
                                     
DEF BROWSE b_tela QUERY q_tela 
           DISP craptel.nmdatela COLUMN-LABEL "Tela"   FORMAT "x(6)"           
                craptel.tldatela COLUMN-LABEL "Titulo" FORMAT "x(40)"
                WITH 11 DOWN TITLE "Tabelas do Sistema" CENTERED.
                
DEF FRAME f_tela 
          b_tela HELP "Pressione <F4> ou <END> para finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 6.       

{ includes/var_online.i }

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

VIEW FRAME f_moldura.

PAUSE(0).

OPEN QUERY q_tela
     FOR EACH  craptel WHERE craptel.cdcooper = glb_cdcooper       AND
                             craptel.nrmodulo = 7                  AND
                             craptel.flgtelbl                      AND
                             craptel.tlrestel <> ""                AND
                             INDEX(craptel.nmdatela, "TAB") <> 0   AND
                             INDEX(craptel.nmdatela, "TABELA") = 0 NO-LOCK.
                           
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
           
      HIDE FRAME f_tela NO-PAUSE.    
      RETURN.
   END.

WAIT-FOR RETURN, END-ERROR OF DEFAULT-WINDOW.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TABELA"   THEN
                      DO:
                          HIDE FRAME f_tela NO-PAUSE.
                          RETURN.
                         END.
                 ELSE
                      NEXT.
             END.

/* .......................................................................... */
