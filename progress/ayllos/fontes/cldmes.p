/*.............................................................................

   Programa: Fontes/cldmes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao: 17/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Analise de movimentacao X renda - Mensal.
   
   
   Alteracoes:  20/07/2011 - Alterado o format do campo tt-creditos.qtultren
                             para inteiro (Adriano).
                
                28/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita sera PA (Andre Euzebio - Supero).  
                        
                30/08/2013 - Alteracao para utilizacao de BOs (Gati - Oliver).
                
                17/02/2014 - Identado nos padroes CECRED (Tiago)    
                
                24/02/2014 - Incluir chamada da procedure para calculo do 
                             ultimo dia util do mes calcula_ultimo_dia_util
                             (Lucas R.)
                             
                07/03/2014 - Ajustando fonte. Identacao e retirada de vars
                             nao utilizadas (Carlos)
                             
                04/06/2014 - Concatena o numero do servidor no endereco do
                             terminal (Tiago-RKAM).
                             
                24/11/2014 - Ajustes para liberação (Adriano).
                
                17/12/2014 - Ajustar format cdagenci para "zz9".
                             (Douglas - Chamado 229676)
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen9998tt.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0174tt.i }

DEFINE VARIABLE h-b1wgen0174 AS HANDLE                              NO-UNDO.
DEFINE VARIABLE par_arquivo AS CHARACTER                            NO-UNDO.

/* ............................. QUERYS/BROWSES .............................. */
DEF QUERY q-creditos FOR tt-creditos.

DEF QUERY q-crapage  FOR tt-crapage.

DEF BROWSE b-crapage QUERY q-crapage
    DISP tt-crapage.cdagenci
         tt-crapage.nmresage
    WITH 07 DOWN NO-BOX.

DEF BROWSE b-creditos QUERY q-creditos
    DISP tt-creditos.cdagenci FORMAT "zz9"
         tt-creditos.nrdconta
         tt-creditos.nmprimtl FORMAT "x(10)"
         tt-creditos.vlrendim
         tt-creditos.vltotcre
         tt-creditos.qtultren FORMAT "zzz,zzz,zz9"
         WITH 11 DOWN NO-BOX.
/* ................................ VARIAVEIS ................................ */
DEF VAR aux_confirma    AS CHAR FORMAT "(!)"                        NO-UNDO.

DEF VAR tel_operacao    AS LOGICAL FORMAT "Credito/Saque"           NO-UNDO.

DEF VAR tel_dtmvtolt    AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_cdagenci    AS INTE FORMAT "zz9"                        NO-UNDO.

/* Para impressao */
DEF VAR aux_nmarqimp AS CHARACTER                                   NO-UNDO.
DEF VAR aux_nmarqpdf AS CHARACTER                                   NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
                                                                    
DEF VAR aux_flgescra AS LOG                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INT                                         NO-UNDO.
DEF VAR aux_tpimprim AS LOGI FORMAT "T/I"  INIT "T"                 NO-UNDO.
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                         NO-UNDO.
                                                                    
DEF VAR par_flgfirst AS LOG                                         NO-UNDO.
DEF VAR par_flgcance AS LOG                                         NO-UNDO.
DEF VAR aux_qtregist AS INT                                         NO-UNDO.

/* ............................... FORMULARIOS ............................... */

FORM b-crapage
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 5 COLUMN 26 NO-LABEL OVERLAY FRAME f_crapage.

FORM b-creditos
     WITH ROW 6 OVERLAY WIDTH 78 CENTERED FRAME f_credito.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Analise de movimentacao X renda - Mensal " FRAME f_moldura.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Detalhes de movimentacao " FRAME f_visrel.
    
FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(C-Consulta,F-Fechamento)"
        VALIDATE (CAN-DO("C,F",glb_cddopcao),"014 - Opcao Errada.")      AT 3
     tel_operacao LABEL "Operacao" AUTO-RETURN
        HELP "Creditos/Saques"                                           AT 14
     tel_dtmvtolt LABEL "Data"                                           
        HELP "Informe a data desejada"                                   AT 33
     tel_cdagenci LABEL "PA"                                             AT 53
        HELP "Informe 0 para todos, o PA desejado ou tecle F7 para listar."          
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldmes.

/* ................................. EVENTOS ................................. */

ON "RETURN" OF b-crapage 
    DO:
        ASSIGN tel_cdagenci = tt-crapage.cdagenci.
        DISP tel_cdagenci WITH FRAME f_cldmes.    
    
        APPLY "GO".
    END.

ON "END-ERROR" OF b-creditos 
    DO:
        IF  VALID-HANDLE(h-b1wgen0174) THEN
            DELETE OBJECT h-b1wgen0174.
    END.

ON "RETURN" OF b-creditos DO:
    
    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT CLOSE.

    ASSIGN aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF NOT VALID-HANDLE(h-b1wgen0174) THEN
       RUN sistema/generico/procedures/b1wgen0174.p 
           PERSISTENT SET h-b1wgen0174.

    RUN Gera_relatorio_diario IN h-b1wgen0174(INPUT glb_cdcooper,
                                              INPUT glb_cdagenci,
                                              INPUT 0 /*nrdcaixa*/,
                                              INPUT glb_cdoperad,
                                              INPUT glb_dtmvtolt,
                                              INPUT 1 /*idorigem*/,
                                              INPUT glb_nmdatela,
                                              INPUT glb_cdprogra,
                                              INPUT tt-creditos.nrdconta,
                                              INPUT tel_dtmvtolt,
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqpdf,
                                              OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0174) THEN
        DELETE OBJECT h-b1wgen0174.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na geracao do relatorio.".

            PAUSE.
            RETURN 'NOK'.
        END.

    MESSAGE "Voce deseja visualizar o relatorio em TELA ou na IMPRESSORA? (T/I)"
            UPDATE aux_tpimprim.
    
    IF  aux_tpimprim = FALSE THEN 
        DO:
            MESSAGE "AGUARDE... Imprimindo relatorio!".
    
            FIND FIRST crapass NO-LOCK NO-ERROR.
    
            ASSIGN glb_nmformul    = "132col"
                   glb_nrcopias    = 1
                   glb_cdempres    = 11
                   glb_cdrelato[1] = 0
                   aux_nmarqimp    = aux_nmarqimp
                   aux_tpimprim    = TRUE.
    
            { includes/impressao.i }

        END.
    ELSE 
        DO:
            HIDE FRAME f_credito.
            VIEW FRAME f_visrel.
            PAUSE 0.
    
            RUN fontes/visrel.p (INPUT aux_nmarqimp).
    
            HIDE FRAME f_visrel.
            VIEW FRAME f_credito.
        END.

    HIDE MESSAGE NO-PAUSE.

    IF  aux_tpimprim = FALSE THEN
        IF  NOT par_flgcance THEN
            MESSAGE "Retire o relatorio da impressora!".
        ELSE
            MESSAGE "Impressao cancelada!".

    /* Remover arquivo gerado */
    UNIX SILENT VALUE ("rm rl/" + glb_nmarqimp + " 2> /dev/null").

END.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_cldmes.                                    
PAUSE(0).

ASSIGN glb_cddopcao = "C"
       tel_operacao = TRUE
       tel_dtmvtolt = (glb_dtmvtolt - DAY(glb_dtmvtolt)).


DO WHILE TRUE:
    
   IF NOT VALID-HANDLE(h-b1wgen0174) THEN
      RUN sistema/generico/procedures/b1wgen0174.p PERSISTENT SET h-b1wgen0174.

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

       UPDATE glb_cddopcao WITH FRAME f_cldmes.
       { includes/acesso.i }
       LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.

          IF CAPS(glb_nmdatela) <> "CLDMES" THEN 
             DO:
                IF VALID-HANDLE(h-b1wgen0174) THEN
                   DELETE OBJECT h-b1wgen0174.
      
                HIDE FRAME f_cldmes.
                HIDE FRAME f_moldura.
                RETURN.
             END.
          ELSE
             NEXT.

      END.  

   principal: 
   DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

      DISP tel_operacao WITH FRAME f_cldmes.

      IF glb_cddopcao = "C" THEN 
         DO:
            UPDATE tel_dtmvtolt 
                   tel_cdagenci
                   WITH FRAME f_cldmes
         
            EDITING:

              READKEY.
   
              IF FRAME-FIELD = "tel_cdagenci" AND 
                 LASTKEY = KEYCODE("F7")      THEN 
                 DO:
                     RUN fontes/zoom_pac.p (OUTPUT tel_cdagenci).
                     DISPLAY tel_cdagenci WITH FRAME f_cldmes.
                 END.
              ELSE 
                 APPLY LASTKEY.
   
            END. /* FIM EDITING */

         END.
      ELSE 
         DISP tel_dtmvtolt WITH FRAME f_cldmes.

      IF tel_operacao THEN /* CREDITO */ 
         DO:
            IF glb_cddopcao = "F" THEN
               DO TRANSACTION: 

                  RUN fontes/confirma.p (INPUT  "",
                                         OUTPUT aux_confirma).

                  IF aux_confirma = "S" THEN 
                     DO:
                        IF NOT VALID-HANDLE(h-b1wgen0174) THEN
                           RUN sistema/generico/procedures/b1wgen0174.p 
                               PERSISTENT SET h-b1wgen0174.

                        RUN Fechamento_diario IN h-b1wgen0174 
                                                (INPUT glb_cdcooper,
                                                 INPUT tel_cdagenci,
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 1, /*idorigem*/
                                                 INPUT glb_nmdatela,
                                                 INPUT glb_cdprogra,
                                                 INPUT tel_dtmvtolt,
                                                 OUTPUT TABLE tt-erro).
                  
                        IF VALID-HANDLE(h-b1wgen0174) THEN
                           DELETE OBJECT h-b1wgen0174.
               
                        IF RETURN-VALUE <> "OK"   THEN
                           DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.

                              IF  AVAIL tt-erro   THEN
                                  MESSAGE tt-erro.dscritic.
                              ELSE
                                  MESSAGE "Erro no fechamento diario.".

                              PAUSE.
                           
                              HIDE MESSAGE.
                              NEXT principal.
                           END.
                  
                        MESSAGE "Fechamento realizado com sucesso.".
               
                        HIDE MESSAGE.
                        LEAVE.
                         
                     END. /* FIM aux_confirma */
                  ELSE 
                     LEAVE.
              
               END. /*DO TRANSACTION:*/
            ELSE 
               DO:
                  IF NOT VALID-HANDLE(h-b1wgen0174) THEN 
                     RUN sistema/generico/procedures/b1wgen0174.p 
                         PERSISTENT SET h-b1wgen0174.
                  
                  RUN Carrega_creditos IN h-b1wgen0174 
                                      (INPUT glb_cdcooper,
                                       INPUT glb_cdagenci,
                                       INPUT 0, /*nrdcaixa*/
                                       INPUT glb_cdoperad,
                                       INPUT glb_dtmvtolt,
                                       INPUT 1,  /*idorigem*/
                                       INPUT glb_nmdatela,
                                       INPUT glb_cdprogra,
                                       INPUT tel_cdagenci,
                                       INPUT tel_dtmvtolt,
                                       INPUT 99999, /*nrregist*/
                                       INPUT 0,     /*nriniseq*/
                                       OUTPUT aux_qtregist,
                                       OUTPUT TABLE tt-creditos,
                                       OUTPUT TABLE tt-erro).

                  IF RETURN-VALUE <> "OK"   THEN
                     DO:
                        IF VALID-HANDLE(h-b1wgen0174) THEN
                           DELETE OBJECT h-b1wgen0174.

                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                        ELSE
                           MESSAGE "Erro no carregamento de " + 
                                   "creditos.".
                        
                        PAUSE.
                        RETURN 'NOK'.
         
                     END.
                  
                  OPEN QUERY q-creditos FOR EACH tt-creditos.
                      
                  UPDATE b-creditos WITH FRAME f_credito.
                 
               END. /* else */

         END. /* if credito */
      
      IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */ 
         DO:
            IF VALID-HANDLE(h-b1wgen0174) THEN
               DELETE OBJECT h-b1wgen0174.
   
            LEAVE.
         END.

   END. /* do while principal */

END. /* Fim do DO WHILE TRUE */
