/* ..........................................................................

   Programa: fontes/dirf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Janeiro/2005                       Ultima atualizacao: 22/02/2005

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Atende a solicitacao 50 ordem _. 
               Tela para digitacao dos dados para DIRF, importacao e geracao
               de arquivo.

   Alteracoes: 22/02/2005 - Alteracoes para funcionar o 'F2 - AJUDA' (Evandro). 

............................................................................ */

{ includes/var_online.i }

{ includes/gg0000.i }

DEF    VAR   tel_telasdrf AS CHAR   LABEL ""
             VIEW-AS SELECTION-LIST INNER-LINES 7 
             INNER-CHARS 50 list-items 
             "DIRFD - DIGITACAO DE DADOS DIRF",
             "DIRFI - INTEGRACAO DE ARQUIVO DIRF", 
             "DIRFV - VISUALIZACAO DE DADOS DIRF",
             "DIRFS - STATUS DA PREPARACAO DIRF",
             "DIRFG - GERACAO DE ARQUIVO DIRF" 
             INITIAL "DIRFD - DIGITACAO DE DADOS DIRF".

FORM SKIP(3)
     "ESCOLHA UMA DAS OPCOES:"      AT 13
     SKIP
     tel_telasdrf AT 13 
                  HELP "Pressione ENTER para selecionar / <F4> para finalizar"
     SKIP(3)
     WITH NO-LABEL CENTERED OVERLAY ROW 4 WIDTH 80 TITLE glb_tldatela 
          FRAME f_tela.

ON RETURN OF tel_telasdrf
   RUN VALUE("fontes/" + LC(SUBSTRING(tel_telasdrf:SCREEN-VALUE,1,5)) + ".p").

ON VALUE-CHANGED OF tel_telasdrf DO:
   HIDE MESSAGE NO-PAUSE.
END.

VIEW FRAME f_tela.

f_conectagener().

glb_cddopcao = "C".

RUN fontes/inicia.p.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE tel_telasdrf WITH FRAME f_tela.
    LEAVE.
END.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         RUN fontes/novatela.p.
         IF   glb_nmdatela <> "DIRF"   THEN
              DO:
                  HIDE FRAME f_aditiv.
                  RUN p_desconectagener.
                  RETURN.
              END.
         ELSE
              NEXT.
     END.

/* ......................................................................... */
