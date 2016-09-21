/* ............................................................................
 
   Programa: Fontes/relinf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Novembro/2012                  Ultima atualizacao:
   
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RELINF
   
   Alteracoes:


............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0142tt.i }

DEF STREAM str_1.

DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR tel_nmcooper AS CHAR     FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                 INNER-LINES 11                     NO-UNDO.
DEF VAR tel_nmarquiv AS CHAR                                        NO-UNDO.
DEF VAR tel_nmdireto AS CHAR                                        NO-UNDO.


DEF VAR h-b1wgen0142 AS HANDLE                                      NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao"       AT 13
            HELP "Informe a opcao desejada (C)."
            VALIDATE(glb_cddopcao = "C","014 - Opcao errada.")
     tel_nmcooper LABEL "Cooperativa" AT 33
            HELP "Informe a cooperativa desejada."            
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_relinf.


FORM "Diretorio:"                     AT 06  
     tel_nmdireto NO-LABEL            AT 17 FORMAT "x(21)"
     tel_nmarquiv NO-LABEL                  FORMAT "x(20)"
            HELP "Informe o nome do arquivo a ser gerado."
            VALIDATE(tel_nmarquiv <> "","357 - O campo deve ser preenchido.") 
     "(Sem extensao)"                 
     WITH ROW 12 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_relinf_2.


ON RETURN OF tel_nmcooper IN FRAME f_relinf DO:
    ASSIGN aux_cdcooper = INTE (tel_nmcooper:SCREEN-VALUE).
    APPLY "GO".
END.

ON ANY-KEY OF tel_nmarquiv IN FRAME f_relinf_2 DO:
    
    /* Nao permitir incluir espacos no nome do arquivo */
    IF   KEYFUNCTION(LASTKEY) = ""   THEN
         RETURN NO-APPLY.

    /* Nao permitir pontos no nome */
    IF   KEYFUNCTION(LASTKEY) = "."  THEN
         RETURN NO-APPLY.

END.


ASSIGN glb_cdcritic = 0
       glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE(0).

RUN sistema/generico/procedures/b1wgen0142.p PERSISTENT SET h-b1wgen0142.  

RUN pi_carrega_cooperativas IN h-b1wgen0142 (OUTPUT aux_nmcooper,
                                             OUTPUT TABLE tt-crapcop).

DELETE PROCEDURE h-b1wgen0142.

ASSIGN tel_nmcooper:LIST-ITEM-PAIRS IN FRAME f_relinf = SUBSTR(aux_nmcooper,9).

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        IF  glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
            END.

        NEXT-PROMPT tel_nmcooper WITH FRAME f_relinf.

        UPDATE glb_cddopcao
               tel_nmcooper WITH FRAME f_relinf.

        IF   aux_cddopcao <> INPUT glb_cddopcao  THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        IF   glb_dsdepart <> "TI"            AND
             glb_dsdepart <> "SUPORTE"       AND
             glb_dsdepart <> "COMUNICACAO"   THEN
             DO:
                 ASSIGN glb_cdcritic = 36.
                 NEXT.
             END.

        FIND crapcop WHERE crapcop.cdcooper = INTE(tel_nmcooper:SCREEN-VALUE)
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcop   THEN
             NEXT.

        ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/"
               tel_nmarquiv = "".

        DISPLAY tel_nmdireto WITH FRAME f_relinf_2.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_nmarquiv WITH FRAME f_relinf_2.
            LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             DO:
                 HIDE FRAME f_relinf_2.
                 NEXT.
             END.

        RUN gera-arquivos.

        HIDE FRAME f_relinf_2.

    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
         
             IF CAPS(glb_nmdatela) <> "RELINF" THEN
                DO:
                    HIDE FRAME f_relinf.
                    RETURN.
                END.
         END.
END.

PROCEDURE gera-arquivos:

    DEF VAR aux_contador AS INTE                                   NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                   NO-UNDO. 
    DEF VAR aux_nomedarq AS CHAR                                   NO-UNDO.
    DEF VAR aux_numarqui AS INTE INIT 1                            NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR                                   NO-UNDO.


    ASSIGN aux_nmarquiv = tel_nmdireto + tel_nmarquiv 
           aux_nomedarq = aux_nmarquiv + "01.txt".

    OUTPUT STREAM str_1 TO VALUE (aux_nomedarq).

    MESSAGE "Aguarde, gerando os arquivos ... ".

    FOR EACH  crapcra WHERE crapcra.cdcooper = aux_cdcooper     NO-LOCK,

        FIRST craptab WHERE craptab.cdcooper = 0                AND
                            craptab.nmsistem = "CRED"           AND
                            craptab.tptabela = "USUARI"         AND
                            craptab.cdempres = 11               AND
                            craptab.cdacesso = "FORENVINFO"     AND
                            craptab.tpregist = crapcra.cddfrenv NO-LOCK:

        IF   ENTRY(2,craptab.dstextab,",") <> "crapcem"   THEN
             NEXT.

        ASSIGN aux_contador = aux_contador + 1
               aux_dsdemail = "".

        FOR FIRST crapcem FIELDS(dsdemail) WHERE
                  crapcem.cdcooper = crapcra.cdcooper  AND
                  crapcem.nrdconta = crapcra.nrdconta  AND
                  crapcem.idseqttl = crapcra.idseqttl  AND
                  crapcem.cddemail = crapcra.cdseqinc  NO-LOCK:

            ASSIGN aux_dsdemail = crapcem.dsdemail.

        END.

        IF   aux_contador = 101   THEN
             DO:
                 OUTPUT STREAM str_1 CLOSE.

                 UNIX SILENT VALUE ("zipcecred.pl -silent -add "          +
                                    aux_nmarquiv + ".zip " + aux_nomedarq +
                                    " 2>/dev/null").

                 ASSIGN aux_contador = 1
                        aux_numarqui = aux_numarqui + 1
                        aux_nomedarq = aux_nmarquiv +
                                       STRING(aux_numarqui,"99") + ".txt".

                 OUTPUT STREAM str_1 TO VALUE  (aux_nomedarq).
             END.

        DISPLAY STREAM str_1 crapcra.nrdconta
                             crapcra.idseqttl
                             aux_dsdemail FORMAT "x(50)".

    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE ("zipcecred.pl -silent -add " +
                       aux_nmarquiv + ".zip " + aux_nomedarq + " 2>/dev/null").

    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "*.txt  2>/dev/null").

    HIDE MESSAGE NO-PAUSE.

    MESSAGE "Arquivo " + aux_nmarquiv + ".zip criado com sucesso." 
            VIEW-AS ALERT-BOX. 

END PROCEDURE.


/* ......................................................................... */
