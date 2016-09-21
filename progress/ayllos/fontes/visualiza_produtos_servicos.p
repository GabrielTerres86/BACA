/* .............................................................................

   Programa: fontes/visualiza_produtos_servicos.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Jorge
   Data    : Fevereiro/2011                       Ultima atualizacao:   /   /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para mostrar na tela, Produtos e Servicos Ativos.

   Alteracoes:

............................................................................. */

{ sistema/generico/includes/b1wgen0052tt.i }

DEF INPUT PARAM TABLE FOR tt-prod_serv_ativos.

DEF VAR edi_prodserv AS CHAR VIEW-AS EDITOR SIZE 38 BY 8 PFCOLOR 0 NO-UNDO.
DEF VAR aux_conteudo AS CHAR NO-UNDO.    
DEF VAR aux_lastprod LIKE tt-prod_serv_ativos.cdseqcia NO-UNDO.

DEF FRAME fra_prodserv  
    edi_prodserv
    HELP "Pressione <F4> ou <END> para finalizar" 
    WITH TITLE "Produtos/Servicos ativos na conta" 
         ROW 8 SIZE 40 BY 10 NO-LABELS CENTERED OVERLAY.

PAUSE 0.

FOR EACH tt-prod_serv_ativos NO-LOCK:
    ASSIGN  aux_conteudo = aux_conteudo + 
            "- " + tt-prod_serv_ativos.nmproser + "\n".
END.   
    
/* retira a ultima quebra de linha */
ASSIGN aux_conteudo = SUBSTRING(aux_conteudo,1,LENGTH(aux_conteudo) - 1).
ASSIGN edi_prodserv = aux_conteudo.

DISPLAY edi_prodserv WITH FRAME fra_prodserv.
ASSIGN edi_prodserv:READ-ONLY IN FRAME fra_prodserv = TRUE.
ASSIGN edi_prodserv:CURSOR-LINE IN FRAME fra_prodserv = 1.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE edi_prodserv WITH FRAME fra_prodserv.
END.    

HIDE FRAME fra_prodserv NO-PAUSE.   

/* ..........................................................................*/
