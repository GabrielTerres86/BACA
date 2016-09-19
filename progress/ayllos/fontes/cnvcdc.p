/* ............................................................................

   Programa: fontes/cnvcdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Janeiro/2015.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Cadastro de Convenio CDC

   Alteracoes:
   
............................................................................ */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF INPUT PARAM par_cdcooper LIKE crapass.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_cdoperad AS CHAR                                   NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR             FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF VAR tel_dscancel AS CHAR             FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.

DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgedita AS LOG                                            NO-UNDO.

DEF VAR tel_cddopcao AS CHAR             FORMAT "!(1)" INIT "T"        NO-UNDO.

DEF VAR tel_flgativo AS LOGI FORMAT "SIM/NAO" INIT NO                  NO-UNDO.
DEF VAR tel_dtcnvcdc AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 1 INIT ["Alterar"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 1 INIT ["A"]                       NO-UNDO.
DEF VAR reg_contador AS INTE          INIT 0                           NO-UNDO.
DEF VAR aux_dsdentid AS CHAR                           FORMAT "x(60)"  NO-UNDO.
DEF VAR aux_cddentid AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitcad LIKE crapimt.cdsitcad                             NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0194 AS HANDLE                                         NO-UNDO.


FORM  SKIP(3)
      tel_flgativo   AT 16  LABEL "Possui Convenio CDC"
      HELP "Possui Convenio CDC? (SIM/NAO)"
      SKIP(1)
      tel_dtcnvcdc   AT 15  LABEL "Data Inicio Convenio"
      HELP "Data Inicio Convenio CDC"
      SKIP(2)
      reg_dsdopcao[1] AT 35  NO-LABEL                   FORMAT "x(7)"
      HELP "Pressione ENTER para Alterar / F4 ou END para sair"
      WITH ROW 12 WIDTH 78 OVERLAY SIDE-LABELS TITLE " CONVENIO CDC "
                  CENTERED FRAME f_dados_convenio.


ASSIGN tel_flgativo = NO
       tel_dtcnvcdc = ?
       aux_flgsuces = FALSE.

ON ENTER OF reg_dsdopcao[1] /* Alterar */
DO:
    reg_contador = 1.
END.

Principal: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN pi-busca-convenio.

    DISPLAY reg_dsdopcao
            WITH FRAME f_dados_convenio.

    CHOOSE FIELD reg_dsdopcao 
                 WITH FRAME f_dados_convenio.

    IF  reg_cddopcao[reg_contador] = "A" THEN DO: /* Alterar */

        UPDATE tel_flgativo
               WITH FRAME f_dados_convenio.

        IF  tel_flgativo THEN
            UPDATE tel_dtcnvcdc
                   WITH FRAME f_dados_convenio.

        RUN pi-altera-convenio.

        IF  aux_flgsuces THEN DO:
            BELL.
            MESSAGE "Convenio CDC atualizado com sucesso!".
            PAUSE.
            HIDE MESSAGE NO-PAUSE.
        END.
    
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S"                THEN
        NEXT Principal.
    ELSE DO:
        IF  aux_flgsuces THEN
            NEXT Principal.
    END.

END. /* Fim DO WHILE TRUE Principal */

HIDE FRAME f_dados_convenio NO-PAUSE.
HIDE MESSAGE NO-PAUSE.

/*...........................................................................*/

PROCEDURE pi-busca-convenio:

    ASSIGN glb_nmrotina = "CONVENIO CDC"
           glb_cddopcao = "C".

    { includes/acesso.i }

    IF  NOT VALID-HANDLE(h-b1wgen0194) THEN
        RUN sistema/generico/procedures/b1wgen0194.p
        PERSISTENT SET h-b1wgen0194.

    RUN pc-busca-convenios IN h-b1wgen0194
                          (INPUT par_cdcooper,
                           INPUT glb_dtmvtolt,
                           INPUT par_nmdatela,
                           INPUT glb_cddopcao,
                           INPUT 1,
                           INPUT par_cdoperad,
                           INPUT tel_nrdconta,
                           OUTPUT tel_flgativo,
                           OUTPUT tel_dtcnvcdc,
                           OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0194) THEN
        DELETE PROCEDURE h-b1wgen0194.

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro  THEN DO:
            BELL.
            MESSAGE tt-erro.dscritic.
            PAUSE.
            HIDE MESSAGE NO-PAUSE.
        END.
    END.

    DISPLAY tel_flgativo
            tel_dtcnvcdc
            WITH FRAME f_dados_convenio.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi-altera-convenio:

    ASSIGN glb_nmrotina = "CONVENIO CDC"
           glb_cddopcao = "A".

    { includes/acesso.i }


    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        glb_cdcritic = 0.
        MESSAGE COLOR NORMAL glb_dscritic
        UPDATE aux_confirma.
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S"                THEN DO:
        ASSIGN glb_cdcritic = 79.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        ASSIGN glb_cdcritic = 0.
        PAUSE 2 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        ASSIGN aux_flgsuces = FALSE.
        RETURN "OK".
    END.
    ELSE DO:
        IF  NOT VALID-HANDLE(h-b1wgen0194) THEN
            RUN sistema/generico/procedures/b1wgen0194.p
            PERSISTENT SET h-b1wgen0194.

        RUN pc-alterar-convenios IN h-b1wgen0194
                                (INPUT par_cdcooper,
                                 INPUT glb_dtmvtolt,
                                 INPUT par_nmdatela,
                                 INPUT glb_cddopcao,
                                 INPUT 1,
                                 INPUT par_cdoperad,
                                 INPUT tel_nrdconta,
                                 INPUT tel_flgativo,
                                 INPUT tel_dtcnvcdc,
                                 OUTPUT TABLE tt-erro).
    
        IF  VALID-HANDLE(h-b1wgen0194) THEN
            DELETE PROCEDURE h-b1wgen0194.

        IF  RETURN-VALUE <> "OK" THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                PAUSE.
                HIDE MESSAGE NO-PAUSE.
            END.
        END.
        
        ASSIGN aux_flgsuces = TRUE.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/
