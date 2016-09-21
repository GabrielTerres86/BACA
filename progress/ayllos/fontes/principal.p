/* .............................................................................

   Programa: Fontes/principal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 08/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Controlar o processo on-line do sistema.

   Alteracao : 06/11/96 - Aumento (+ 1 dia) do prazo de bloqueio dos depositos
                          em cheque da praca (Deborah).

               01/10/1999 - Alterado para acessar crapcop (Edson).

               22/02/2000 - Novos prazos de bloqueio
                            1 dia praca e 3 dias fora praca (Deborah).

               14/02/2000 - Alterado para tratar glb_nmrotina (Edson).

               21/11/2000 - Inserir o nome da impressora no titulo 
                            da janela (Eduardo).

               30/09/2002 - Novas datas de liberacao de cheques (Margarete).

               16/04/2004 - Capturar o nome do login (Edson).

               15/08/2005 - Utilizar o campo glb_cdcooper(1) para acessar o 
                            cadastro de cooperativas (Edson).
                            (1) O campo eh alimentado na rotina fontes/inicia.p
                            
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               17/12/2007 - Excluir procedures persistentes a cada 
                            mudanca de tela (Julio)

               14/11/2008 - Inclusao do ON ERROR UNDO, RETRY para nao cair no
                            editor quando na chamada de um fonte que nao existe
                            (Julio)

               08/04/2013 - Adicionado campo craptel.idambtel. (Jorge)
                                       
............................................................................. */

{ includes/var_online.i NEW }

DEF            VAR aux_contador AS INT                               NO-UNDO.
DEF            VAR aux_nmdlogin AS CHAR                              NO-UNDO.
DEF            VAR aux_dsimpres AS CHAR FORMAT "x(8)"                NO-UNDO.

FORM glb_nmrescop FORMAT "x(11)" AT 2
     WITH FRAME f_nmdaempr ROW  1 COLUMN  1 OVERLAY NO-LABEL WIDTH 15.

FORM SPACE(1) glb_nmdatela
     WITH FRAME f_nmdatela ROW  1 COLUMN 16 OVERLAY NO-LABEL WIDTH 10.

FORM glb_nmmodulo[glb_nrmodulo]  FORMAT "x(39)"
     WITH FRAME f_nmmodulo ROW  1 COLUMN 26 OVERLAY NO-LABEL WIDTH 41.

FORM SPACE(1) glb_dtmvtolt  FORMAT "99/99/9999"
     WITH FRAME f_dtmvtolt ROW  1 COLUMN 67 OVERLAY NO-LABEL WIDTH 14.

STATUS DEFAULT "".
STATUS INPUT  "Tecle algo ou pressione " + KBLABEL("END-ERROR") + " para sair!".

HIDE ALL NO-PAUSE.

ASSIGN glb_cdprogra = "principal"
       glb_nmdatela = "IDENTI".

RUN fontes/inicia.p.

/*  Acessa dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         
         DISPLAY SKIP(2) 
                 "  " glb_dscritic FORMAT "x(66)" "  "
                 SKIP(2)
                 WITH ROW 10 NO-LABELS OVERLAY CENTERED FRAME f_erro.
        
         PAUSE 5 NO-MESSAGE.
        
         HIDE ALL NO-PAUSE.
         QUIT.
      END.

INPUT THROUGH echo $LOGNAME NO-ECHO.

SET aux_nmdlogin WITH FRAME f_login.

INPUT CLOSE.

ASSIGN glb_nmrescop = crapcop.nmrescop
       glb_nmrotina = "".

/*  Monta a data de liberacao para depositos da praca e fora da praca */
glb_dtlibfpr = glb_dtmvtolt.

DO aux_contador = 1 TO 4:

   glb_dtlibfpr = glb_dtlibfpr + 1.

   IF   WEEKDAY(glb_dtlibfpr) = 1   THEN                        /* (DOMINGO) */
        glb_dtlibfpr = glb_dtlibfpr + 1.
   ELSE  
        IF   WEEKDAY(glb_dtlibfpr) = 7   THEN                   /* (SABADO)  */
             glb_dtlibfpr = glb_dtlibfpr + 2.

   DO WHILE TRUE:

      FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                         crapfer.dtferiad = glb_dtlibfpr    NO-LOCK NO-ERROR.

      IF   AVAILABLE crapfer   THEN
           DO:
               IF   WEEKDAY(glb_dtlibfpr + 1) = 1   THEN        /* (DOMINGO) */
                    glb_dtlibfpr = glb_dtlibfpr + 2.
               ELSE
                    IF   WEEKDAY(glb_dtlibfpr + 1) = 7   THEN   /* (SABADO) */
                         glb_dtlibfpr = glb_dtlibfpr + 3.
                    ELSE
                         glb_dtlibfpr = glb_dtlibfpr + 1.       /* (FERIADO) */
               NEXT.
           END.

      IF   aux_contador = 1   THEN
           glb_dtlibdma = glb_dtlibfpr. /* cheques maiores da praca */
      ELSE
           IF   aux_contador = 2   THEN
                glb_dtlibdpr = glb_dtlibfpr. /* cheques menores da praca */
           ELSE
                IF   aux_contador = 3   THEN
                     glb_dtlibfma = glb_dtlibfpr. /* cheq maiores fora praca */
                     
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

END.   /* Fim do DO .. TO  --  montagem das datas de liberacao  */

DISPLAY glb_nmrescop WITH FRAME f_nmdaempr.

VIEW FRAME f_nmdatela.
VIEW FRAME f_nmmodulo.

DISPLAY glb_dtmvtolt WITH FRAME f_dtmvtolt.

DO WHILE TRUE ON ERROR UNDO, RETRY:

   IF   glb_nmdatela <> ""   THEN
        DO:
            IF   glb_nmdatela = "FIM"   THEN
                 DO:
                     HIDE ALL NO-PAUSE.
                     QUIT.
                 END.

            FIND craptel WHERE craptel.cdcooper = glb_cdcooper AND 
                               craptel.nmdatela = glb_nmdatela AND
                               craptel.nmrotina = ""           AND         
                               (craptel.idambtel = 1 OR
                                craptel.idambtel = 0)
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE craptel   THEN
                 IF   craptel.flgtelbl   THEN
                      DO:
                          DO WHILE VALID-HANDLE(SESSION:FIRST-PROCEDURE):
                              IF  glb_nmpacote = "pkgdesen"  THEN
                                  MESSAGE "HANDLE" 
                                     SESSION:FIRST-PROCEDURE 
                                    "NAO FOI DELETADO." VIEW-AS ALERT-BOX.
                              DELETE PROCEDURE SESSION:FIRST-PROCEDURE.       
                          END.

                          IF   glb_nmdafila = "" THEN
                               aux_dsimpres = "Escrava".
                          ELSE 
                               aux_dsimpres = glb_nmdafila.
    
                          ASSIGN glb_cdprogra = LC(glb_nmdatela)
                                 glb_nrmodulo = craptel.nrmodulo
                                 glb_tldatela = " " + craptel.tldatela +
                                                IF glb_nmdatela = "IDENTI"
                                                   THEN " "
                                                   ELSE " (Usuario: " +
                                                   ENTRY(1,glb_nmoperad," ") +
                                                        " - Imp: " +
                                                        TRIM(aux_dsimpres) +
                                                        ") ".
                                                                           
                          DISPLAY glb_nmdatela WITH FRAME f_nmdatela.
                          
                          IF   aux_nmdlogin = "consulta"   THEN
                               DO:
                                   COLOR DISPLAY MESSAGES 
                                         glb_nmmodulo[glb_nrmodulo]
                                         WITH FRAME f_nmmodulo.

                                   DISPLAY "     " +
                                           "** SISTEMA DE TREINAMENTO **" @
                                           glb_nmmodulo[glb_nrmodulo]  
                                           WITH FRAME f_nmmodulo.
                               END.
                          ELSE
                               DISPLAY glb_nmmodulo[glb_nrmodulo]
                                           WITH FRAME f_nmmodulo.
                         
                          IF  SEARCH("fontes/" + LC(glb_nmdatela) + ".p") <> ?  THEN
                              RUN VALUE("fontes/" + LC(glb_nmdatela) + ".p").
                          ELSE
                              glb_nmdatela = "MENU00".
                      END.
                 ELSE 
                      glb_nmdatela = "MENU00".
            ELSE
                 glb_nmdatela = "MENU00".
        END.
   ELSE
        glb_nmdatela = "MENU00".

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

