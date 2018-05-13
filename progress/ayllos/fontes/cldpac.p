/*.............................................................................

   Programa: Fontes/cldpac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao: 15/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Analise de movimentacao X renda - PAC.
   
   Alteracoes: Alterada variável aux_confirma para aux_confirem (confirma 
               remocao) e aux_confiinc (confirma inclusao) para a procedure
               grava_dados receber o parametro de confirmacao de remocao
               (Reinert).
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               08/04/2014 - Ajuste WHOLE-INDEX; adicionado filtro com
                            cdcooper na leitura da temp-table.
                            Comentado procedure carrega-creditos; motivo:
                            procedure nao esta sendo chamada no fonte.
                            (Fabricio)
                            
               10/06/2014 - Fazer leitura na CRAPFLD para verificar se o 
                            fechamento ja foi realizado 
							(Chamado 143945) - (Andrino-RKAM).
               
               15/12/2014 - Ajustar format do PA para 3 digitos.
                            (Douglas - Chamado 229676)
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0152tt.i }
    

/* ............................. QUERYS/BROWSES .............................. */
DEF QUERY q-creditos FOR tt-creditos.
/***** Nao sera necessario conforme conversa com Roberto
DEF QUERY q-saques   FOR tt-saques.
******/
DEF QUERY q-just     FOR tt-just.
DEF QUERY q-crapage  FOR crapage.

DEF BROWSE b-crapage QUERY q-crapage
    DISP crapage.cdagenci
         crapage.nmresage
    WITH 07 DOWN NO-BOX.

DEF BROWSE b-creditos QUERY q-creditos
    DISP tt-creditos.nrdconta
         tt-creditos.nmprimtl FORMAT "x(18)"
         tt-creditos.inpessoa FORMAT "x(6)"
         tt-creditos.vlrendim 
         tt-creditos.vltotcre
         tt-creditos.flextjus 
    WITH 07 DOWN NO-BOX.
/***** Nao sera necessario conforme conversa com Roberto
DEF BROWSE b-saques QUERY q-saques
    DISP tt-saques.nrdconta
         tt-saques.nmpesrcb  FORMAT "x(26)"
         tt-saques.nrdocmto
         tt-saques.vllanmto
         tt-saques.ilicita
    WITH 07 DOWN NO-BOX.
******/
DEF BROWSE b-just QUERY q-just
    DISP tt-just.cddjusti
         tt-just.dsdjusti
    WITH 8 DOWN NO-LABELS TITLE "Justificativas" OVERLAY.

/* ................................ VARIAVEIS ................................ */
DEF VAR aux_confirem AS CHAR FORMAT "(!)" INITIAL "N"                NO-UNDO.
DEF VAR aux_confiinc AS CHAR FORMAT "(!)"                            NO-UNDO.
DEF VAR aux_nrdjusti AS INTE                                         NO-UNDO.
DEF VAR aux_pergunta AS CHAR                                         NO-UNDO.
DEF VAR aux_flextjus AS LOGICAL                                      NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
                                                                     
DEF VAR tel_operacao AS LOGICAL FORMAT "Credito/Saque"               NO-UNDO.
DEF VAR tel_cdagenci AS INTE FORMAT "zz9"                            NO-UNDO.
DEF VAR tel_dtmvtolt AS DATE FORMAT "99/99/9999"                     NO-UNDO.

DEF VAR tel_cddjusti AS INTE                                         NO-UNDO.
DEF VAR tel_dsdjusti AS CHAR                                         NO-UNDO.
DEF VAR tel_dstrecur AS CHAR                                         NO-UNDO.
DEF VAR tel_dsobserv AS CHAR                                         NO-UNDO.
DEF VAR h-b1wgen0152 AS HANDLE                                       NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
    
/* ............................... FORMULARIOS ............................... */
FORM b-crapage
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 5 COLUMN 15 NO-LABEL OVERLAY FRAME f_crapage.

FORM b-just
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 11 NO-LABELS NO-BOX CENTERED OVERLAY
     FRAME f_just.

FORM b-creditos
     WITH ROW 6 OVERLAY WIDTH 78 CENTERED FRAME f_credito.

FORM SKIP(1)
     "Justificativa:" tel_cddjusti               FORMAT "z9"
              HELP "Informe o codigo da justificativa ou tecle F7 para listar."
     "-"  tel_dsdjusti                           FORMAT "x(55)"
          HELP "Informe a descricao da justificativa."
          /*VALIDATE (INPUT tel_dsdjusti <> "", "Informe uma descricao")*/
    SKIP
    "Comp.Justi.:" tel_dsobserv FORMAT "x(60)"
    WITH OVERLAY ROW 17 COLUMN 2 NO-BOX NO-LABEL FRAME f_credito_detalhe.
/***** Nao sera necessario conforme conversa com Roberto
FORM b-saques
     WITH ROW 6 OVERLAY WIDTH 78 CENTERED FRAME f_saque.

FORM SKIP(2)
     "      Destino:" tel_dstrecur   FORMAT "x(60)"
     SKIP
     "Justificafiva:" tel_dsdjusti   FORMAT "x(60)"
     WITH OVERLAY ROW 17 COLUMN 2 NO-BOX NO-LABEL FRAME f_saque_detalhe.
******/
FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Analise de movimentacao X renda - PA " FRAME f_moldura.
    
FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(C - Consulta, J - Justificativa)"
        VALIDATE (CAN-DO("C,J",glb_cddopcao),"014 - Opcao Errada.")        AT 3
     tel_operacao LABEL "Operacao" AUTO-RETURN
        HELP "Creditos/Saques"                                             AT 16
     tel_cdagenci LABEL "PA"
        HELP "Informe o PA desejado ou tecle F7 para listar."
        VALIDATE (INPUT tel_cdagenci > 0,"PA deve ser maior que zero.")    AT 41
     tel_dtmvtolt LABEL "Data"
        HELP "Informe a data desejada"
        VALIDATE (INPUT tel_dtmvtolt = glb_dtmvtoan,"Data invalida")       AT 54
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldpac.

/* ................................. EVENTOS ................................. */
ON "RETURN" OF b-just DO:
    ASSIGN tel_cddjusti = tt-just.cddjusti
           tel_dsdjusti = IF tt-just.cddjusti <> 7 THEN 
                             tt-just.dsdjusti
                          ELSE
                              "".
    DISP tel_cddjusti tel_dsdjusti WITH FRAME  f_credito_detalhe.
    APPLY "GO".
END.

ON "RETURN" OF b-crapage DO:
    ASSIGN tel_cdagenci = crapage.cdagenci.
    DISP tel_cdagenci WITH FRAME f_cldpac.

    APPLY "GO".
END.

ON "ENTRY" OF b-creditos DO:
    APPLY "VALUE-CHANGED" TO b-creditos.
END.

ON "RETURN" OF b-creditos DO:
    IF  glb_cddopcao = "J" THEN
        DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

            IF  tt-creditos.flextjus THEN
                DO:
                    /* Verifica se ja foi enviado para conferencia */
                    FIND crapfld WHERE crapfld.cdcooper = glb_cdcooper AND
                                       crapfld.dtmvtolt = tel_dtmvtolt AND
                                       crapfld.cdtipcld = 1 /* DIARIO COOP */
                                       NO-LOCK NO-ERROR.
                                       
                    IF  AVAIL crapfld THEN
                        DO:
                           MESSAGE "Fechamento para esta data ja realizado".
                           PAUSE 2 NO-MESSAGE.    
                           LEAVE.
                        END.
                    ELSE
                        DO:
                           ASSIGN  aux_pergunta = "Deseja remover a justificativa?".

                           RUN fontes/confirma.p (INPUT  aux_pergunta,
                                                  OUTPUT aux_confirem).

                           IF  tt-creditos.flextjus AND aux_confirem = "S" THEN
                               DO:
                                    ASSIGN tel_cddjusti = 0
                                           tel_dsdjusti = ""
                                           tel_dsobserv = ""
                                           aux_cdoperad = ""
                                           aux_flextjus = NO.
                               END.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN  aux_pergunta = "Deseja incluir a justificativa?".
                
                    UPDATE tel_cddjusti WITH FRAME  f_credito_detalhe
                    EDITING:
                        
                        READKEY.
                        
                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                OPEN QUERY q-just FOR EACH tt-just NO-LOCK.
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        
                                    UPDATE b-just WITH FRAME f_just.
                                    LEAVE.
                                END.
                        
                                HIDE FRAME f_just.
                        
                                NEXT.
                            END.
                        ELSE
                            APPLY LASTKEY.
                        
                    END. /* FIM EDITING */
                        
                    FIND tt-just WHERE tt-just.cddjusti = tel_cddjusti 
                                        NO-LOCK NO-ERROR.
                        
                    IF  AVAIL tt-just     AND 
                        tel_cddjusti <> 7 THEN
                        ASSIGN tel_dsdjusti = tt-just.dsdjusti.
                        
                    DISP tel_dsdjusti WITH FRAME  f_credito_detalhe.
                    
                    IF  tel_cddjusti = 7 THEN
                        DO:
                            ASSIGN tel_dsdjusti = "".
                            UPDATE tel_dsdjusti WITH FRAME  f_credito_detalhe.
                        END.
                        
                    UPDATE tel_dsobserv WITH FRAME  f_credito_detalhe.
                
                    RUN fontes/confirma.p (INPUT  aux_pergunta,
                                           OUTPUT aux_confiinc).
                
                
                    IF  NOT tt-creditos.flextjus THEN
                        DO:
                            IF aux_confiinc = "S" THEN
                                ASSIGN aux_cdoperad = glb_cdoperad
                                       aux_confirem = "N"
                                       aux_flextjus = IF   tel_cddjusti = 8 THEN 
                                                           NO            
                                                      ELSE YES.
                            ELSE
                                APPLY "VALUE-CHANGED" TO b-creditos.
                        END.
                END.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.
            ASSIGN tt-creditos.flextjus = aux_flextjus
                   tt-creditos.cddjusti = tel_cddjusti 
                   tt-creditos.dsdjusti = tel_dsdjusti 
                   tt-creditos.dsobserv = tel_dsobserv
                   tt-creditos.cdoperad = aux_cdoperad.

            b-creditos:REFRESH().
            APPLY "VALUE-CHANGED" TO b-creditos.

            LEAVE.

        END.
END.

ON "VALUE-CHANGED" OF b-creditos DO:
    ASSIGN tel_cddjusti = tt-creditos.cddjusti
           tel_dsdjusti = tt-creditos.dsdjusti
           tel_dsobserv = tt-creditos.dsobserv.
           
    DISP tel_cddjusti tel_dsdjusti
         tel_dsobserv WITH FRAME f_credito_detalhe.
END.

/***** Nao sera necessario conforme conversa com Roberto
ON "ENTRY" OF b-saques DO:
    APPLY "VALUE-CHANGED" TO b-saques.
END.

ON "RETURN" OF b-saques DO:
    IF  glb_cddopcao = "J" THEN
        DO TRANSACTION:
            IF  tt-saques.ilicita THEN
                DO:
                    ASSIGN aux_pergunta = "Deseja cancelar o envio ao COAF?".

                    RUN fontes/confirma.p (INPUT  aux_pergunta,
                                           OUTPUT aux_confirma).

                    IF  tt-saques.ilicita AND aux_confirma = "S" THEN
                        DO:
                            FIND crapcme 
                                 WHERE ROWID(crapcme) = tt-saques.nrdrowid
                                 EXCLUSIVE-LOCK NO-ERROR.

                            ASSIGN crapcme.ilicita    = NO
                                    crapcme.opecdili   = ""
                                    crapcme.dsdjusti   = ""
                                    tt-saques.ilicita  = NO
                                    tt-saques.opecdili = ""
                                    tt-saques.dsdjusti = "".
                        END.
                END.
            ELSE
                DO:
                    ASSIGN aux_pergunta = "Deseja enviar o registro ao COAF?".

                    UPDATE tel_dsdjusti WITH FRAME f_saque_detalhe.

                    RUN fontes/confirma.p (INPUT  aux_pergunta,
                                           OUTPUT aux_confirma).
                    
                    IF NOT tt-saques.ilicita AND aux_confirma = "S" THEN
                        DO:
                            FIND crapcme 
                                 WHERE ROWID(crapcme) = tt-saques.nrdrowid
                                 EXCLUSIVE-LOCK NO-ERROR.
                            
                            ASSIGN crapcme.ilicita    = YES
                                   crapcme.opecdili   = glb_cdoperad
                                   crapcme.dsdjusti   = tel_dsdjusti
                                   tt-saques.ilicita  = YES
                                   tt-saques.opecdili = glb_cdoperad
                                   tt-saques.dsdjusti = tel_dsdjusti.
                        END.
                    
                END.
                    
                b-saques:REFRESH().
                APPLY "VALUE-CHANGED" TO b-saques.

                FIND CURRENT crapcme NO-LOCK.
        END.
END.

ON "VALUE-CHANGED" OF b-saques DO:
    
    ASSIGN tel_dstrecur = tt-saques.dstrecur
           tel_dsdjusti = tt-saques.dsdjusti.

    DISP tel_dstrecur 
         tel_dsdjusti 
         WITH FRAME f_saque_detalhe.
END.       

******/

/* ........................................................................... */

ASSIGN glb_cddopcao = "C"
       tel_cdagenci = 0
       tel_operacao = TRUE
       tel_dtmvtolt = glb_dtmvtoan.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_cldpac.
PAUSE(0).

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_cldpac.

        { includes/acesso.i }

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "CLDPAC"  THEN
                DO:
                    HIDE FRAME f_saque.
                    HIDE FRAME f_cldpac.
                    HIDE FRAME f_moldura.
                    HIDE FRAME f_credito.
                    HIDE FRAME f_saque_detalhe.
                    HIDE FRAME f_credito_detalhe.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        DISP tel_operacao WITH FRAME f_cldpac.

        UPDATE tel_cdagenci tel_dtmvtolt
            WITH FRAME f_cldpac
        EDITING:

            READKEY.

            IF  FRAME-FIELD = "tel_cdagenci" AND
                LASTKEY = KEYCODE("F7") THEN
                DO:
                    RUN fontes/zoom_pac.p(OUTPUT tel_cdagenci).
                    DISPLAY tel_cdagenci WITH FRAME f_cldpac.

                    NEXT.
                END.
            ELSE
                APPLY LASTKEY.

        END. /* FIM EDITING */

        IF  tel_operacao THEN /* CREDITO */
            DO:
                RUN Busca_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                OPEN QUERY q-creditos FOR EACH tt-creditos 
                                WHERE tt-creditos.cdcooper = glb_cdcooper.
                     /*BY tt-creditos.nrdconta.*/

                UPDATE b-creditos WITH FRAME f_credito.
    
                HIDE FRAME f_credito_detalhe.
        
                HIDE FRAME f_credito NO-PAUSE.
                HIDE FRAME f_credito_detalhe NO-PAUSE.
            END.
        /***** Nao sera necessario conforme conversa com Roberto
        ELSE                 /* SAQUE */
            DO:
                RUN carrega-saques.
        
                HIDE FRAME f_saque NO-PAUSE.
                HIDE FRAME f_saque_detalhe NO-PAUSE.  
            END.
        ******/    
    END.

END. /* Fim do DO WHILE TRUE */
/*
PROCEDURE carrega-creditos:

    OPEN QUERY q-creditos FOR EACH tt-creditos BY tt-creditos.nrdconta.

    UPDATE b-creditos WITH FRAME f_credito.

    HIDE FRAME f_credito_detalhe.

END PROCEDURE. */ /* FIM carrega-creditos */
/***** Nao sera necessario conforme conversa com Roberto
PROCEDURE carrega-saques:

    EMPTY TEMP-TABLE tt-saques.

    FOR EACH crapcme WHERE crapcme.cdcooper = glb_cdcooper 
                       AND crapcme.dtmvtolt = tel_dtmvtolt
                       AND crapcme.cdagenci = tel_cdagenci
                       AND crapcme.tpoperac = 2
                       NO-LOCK:

        CREATE tt-saques.
        ASSIGN tt-saques.nrdconta = crapcme.nrdconta
               tt-saques.nmpesrcb = crapcme.nmpesrcb
               tt-saques.nrdocmto = crapcme.nrdocmto
               tt-saques.vllanmto = crapcme.vllanmto
               tt-saques.dstrecur = crapcme.dstrecur
               tt-saques.ilicita  = crapcme.ilicita
               tt-saques.dsdjusti = crapcme.dsdjusti 
               tt-saques.opecdili = crapcme.opecdili
               tt-saques.nrdrowid = ROWID(crapcme).

    END.

    FIND FIRST tt-saques NO-LOCK NO-ERROR.

    IF  AVAIL tt-saques THEN
        DO:
            OPEN QUERY q-saques FOR EACH tt-saques BY tt-saques.nrdconta.

            UPDATE b-saques WITH FRAME f_saque.
        END.
    ELSE
        MESSAGE "Nao existem lancamento a serem listados.".

END PROCEDURE. /* FIM carrega-saques */
********/

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-creditos.
    EMPTY TEMP-TABLE tt-just.
    
    IF  NOT VALID-HANDLE(h-b1wgen0152) THEN
        RUN sistema/generico/procedures/b1wgen0152.p
            PERSISTENT SET h-b1wgen0152.

    MESSAGE "Aguarde...buscando dados...".

    RUN Busca_Dados IN h-b1wgen0152
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_cddopcao,
          INPUT tel_cdagenci,
          INPUT tel_dtmvtolt,
          INPUT TRUE, /* flgerlog */
          INPUT glb_dtmvtoan,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-creditos,
         OUTPUT TABLE tt-just,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0152) THEN
        DELETE OBJECT h-b1wgen0152.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.
    
    IF  NOT VALID-HANDLE(h-b1wgen0152) THEN
        RUN sistema/generico/procedures/b1wgen0152.p
            PERSISTENT SET h-b1wgen0152.

    MESSAGE "Aguarde...buscando dados...".

    RUN Grava_Dados IN h-b1wgen0152
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdprogra,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT aux_flextjus,
          INPUT tel_cddjusti,
          INPUT tel_dsdjusti,
          INPUT tel_dsobserv,
          INPUT aux_cdoperad,
          INPUT tt-creditos.nrdrowid,
          INPUT aux_confirem,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0152) THEN
        DELETE OBJECT h-b1wgen0152.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */
