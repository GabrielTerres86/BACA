/*.............................................................................

   Programa: fontes/zoom_banco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze
   Data    : Novembro/2006                       Ultima alteracao: 15/12/2006       

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela crapban - Cadastro de Bancos

   Alteracoes: 15/12/2006 - Criado evento para tratar saida do browse (Diego).
   
............................................................................. */

DEF SHARED VAR shr_cdbccxlt LIKE crapban.cdbccxlt                      NO-UNDO.
DEF SHARED VAR shr_nmresbcc LIKE crapban.nmresbcc                      NO-UNDO.
                 
DEF QUERY q_crapban FOR crapban.
 
DEF BROWSE b_crapban QUERY q_crapban
    DISPLAY crapban.cdbccxlt COLUMN-LABEL "Codigo"
            crapban.nmresbcc COLUMN-LABEL "Banco"
            WITH 10 DOWN OVERLAY TITLE "BANCO".    
          
FORM b_crapban HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_crapban.          

ON END-ERROR OF b_crapban
   DO:
       HIDE FRAME f_crapban.
   END.


ON RETURN OF b_crapban
   DO:
       ASSIGN shr_cdbccxlt = crapban.cdbccxlt
              shr_nmresbcc = crapban.nmresbcc.
          
       CLOSE QUERY q_crapban.               
       HIDE FRAME f_crapban NO-PAUSE.
       APPLY "END-ERROR" TO b_crapban.
                 
   END.

   OPEN QUERY q_crapban FOR EACH crapban NO-LOCK.
   
   SET b_crapban WITH FRAME f_crapban.
   
/* .......................................................................... */
