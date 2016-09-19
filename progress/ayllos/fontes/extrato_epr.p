/* ............................................................................

   Programa: Fontes/extrato_epr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel Capoia - DB1
   Data    : Maio/2011.                       Ultima atualizacao: 16/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina que gera extratos da tela ATENDA.

   Alteracoes: 26/08/2011 - Inclusao da coluna numero da parcela - nrparepr
                            para tipo de emprestimo  = 1 (Diego B. - GATI)
                            
               06/01/2012 - Aumento FORMAT do campo tt-extrato_epr.nrdocmto
                            (Diego).
                            
               04/07/2012 - Nao exigir data para o emprestimo tipo 1 
                            (Gabriel)
                            
               03/02/2014 - Adicionado condicao para nao listar no extrato os 
                            historicos 1040, 1041, 1042 e 1043. (James)

               16/04/2015 - Alterado o formato do campo nrdocmto para 10
                            posicoes. (Jaison/Gielow - SD: 277183)

............................................................................ */

DEF INPUT PARAM par_nrdconta AS INTE                                 NO-UNDO.
DEF INPUT PARAM par_nrctremp AS INTE                                 NO-UNDO.
DEF INPUT PARAM par_tpemprst AS INTE                                 NO-UNDO.

{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/b1wgen0002tt.i }

DEF VAR aux_flgretor AS LOGICAL                                      NO-UNDO.
DEF VAR aux_regexist AS LOGICAL                                      NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                       NO-UNDO.
DEF VAR aux_cdtmvtol AS CHAR                                         NO-UNDO.

FORM tt-extrato_epr.dtmvtolt AT 02 COLUMN-LABEL "   Data" 
     tt-extrato_epr.dshistor COLUMN-LABEL "Historico" FORMAT "x(25)"
     tt-extrato_epr.nrdocmto COLUMN-LABEL " Documento" FORMAT "z,zzz,zzz,zz9"
     tt-extrato_epr.indebcre COLUMN-LABEL "D/C" FORMAT " x(2)"
     tt-extrato_epr.nrparepr COLUMN-LABEL "Par" FORMAT "x(4)"
     tt-extrato_epr.vllanmto COLUMN-LABEL "Valor" FORMAT "zzz,zzz,zz9.99"
     WITH WIDTH  80 ROW 9 CENTERED OVERLAY 9 DOWN TITLE " Extrato " 
     FRAME f_lanctos.

ASSIGN aux_flgretor = FALSE
       aux_regexist = FALSE
       aux_contador = 0
       aux_dtpesqui = ?.

CLEAR FRAME f_lanctos ALL NO-PAUSE.

IF   par_tpemprst <> 1   THEN
     DO:
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
     
            UPDATE aux_dtpesqui WITH FRAME f_data.
            LEAVE.
     
         END.
     
         IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             aux_dtpesqui = ?.
         
         HIDE FRAME f_data.
     
     END.

IF  aux_dtpesqui = ? THEN
    aux_dtpesqui = 01/01/0001.

 IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
     RUN sistema/generico/procedures/b1wgen0002.p
        PERSISTENT SET h-b1wgen0002.

 RUN obtem-extrato-emprestimo IN h-b1wgen0002
     ( INPUT glb_cdcooper,
       INPUT 0,  /** agencia **/
       INPUT 0,  /** caixa **/
       INPUT glb_cdoperad,
       INPUT "extrato_epr.p",
       INPUT 1,  /** origem **/
       INPUT par_nrdconta,
       INPUT 1,  /** idseqttl **/
       INPUT par_nrctremp,
       INPUT aux_dtpesqui,
       INPUT glb_dtmvtolt,
       INPUT FALSE, /** Log **/
      OUTPUT TABLE tt-erro,
      OUTPUT TABLE tt-extrato_epr ).

 IF  VALID-HANDLE(h-b1wgen0002) THEN
     DELETE OBJECT h-b1wgen0002.
 
 IF  RETURN-VALUE = "NOK"  THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF  AVAILABLE tt-erro  THEN
             ASSIGN glb_dscritic = tt-erro.dscritic.
         ELSE
             ASSIGN glb_dscritic = "Erro no carregamento"
                                  + " dos extratos.".
         RETURN "NOK".
     END.


FOR EACH tt-extrato_epr WHERE tt-extrato_epr.flglista = TRUE 
                              NO-LOCK:

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF  aux_contador = 1   THEN
        IF  aux_flgretor   THEN
            DO:
                PAUSE MESSAGE
                      "Tecle <Entra> para continuar ou <Fim> para encerrar.".
                CLEAR FRAME f_lanctos ALL NO-PAUSE.
            END.

    PAUSE (0).
    
    IF  tt-extrato_epr.dtmvtolt = 01/01/9999 THEN
        aux_cdtmvtol = "FOLHA".
    ELSE
        aux_cdtmvtol = STRING(tt-extrato_epr.dtmvtolt).

    
    DISPLAY aux_cdtmvtol @ tt-extrato_epr.dtmvtolt
          tt-extrato_epr.dshistor
          tt-extrato_epr.nrdocmto 
          tt-extrato_epr.indebcre 
          tt-extrato_epr.nrparepr
          tt-extrato_epr.vllanmto
          WITH FRAME f_lanctos.

    IF  aux_contador = 9   THEN
        ASSIGN aux_contador = 0
               aux_flgretor = TRUE.
    ELSE
        DOWN WITH FRAME f_lanctos.
        
    

END.  /*  Fim do FOR EACH  */

IF  NOT aux_regexist   THEN
    DO:
        glb_cdcritic = 81.
        RUN fontes/critic.p.
        CLEAR FRAME f_lanctos ALL NO-PAUSE.
        BELL.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        PAUSE 2 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        RETURN.
    END.

IF  KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN    /*   F4 OU FIM   */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <Entra> para continuar ou <Fim> para encerrar.".
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_lanctos NO-PAUSE.
