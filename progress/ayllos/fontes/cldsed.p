/*.............................................................................

   Programa: Fontes/cldsed.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MAIO/2011                          Ultima Atualizacao: 18/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Analise de movimentacao X renda - Sede.
   
   Alteracoes: 04/07/2011 - Ajuste na busca de registros ainda sem justificativa 
                            antes de realizar o fechamento (Henrique).
                            
               20/07/2011 - Alterado o format do campo tt-creditos.qtultren
                            para inteiro (Adriano).  
                            
               13/09/2011 - Incluidas as opcoes P e T (Henrique).                          
               
               13/03/2012 - Alterada a opcao de saída "A" para gerar arquivo
                            importável no excel (Lucas). 
                            
               12/07/2012 - Incluir layout do arq. gerado para Excel na
                            opcao T - Trf. 4012 (Ze).
                            
               26/08/2013 - Programa convertido para poder ser chamado pela WEB.
                            As regras de negócio foram retiradas e colocadas
                            todas na procedure b1wgen0173.p (Oliver - GATI).
               
               04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)            
                            
               10/06/2014 - Gravar zeros no indicador crapcld.flextjus 
                            quando cddjusti igual a 8 independente de possuir
                            texto de justificativa (Chamado 143945) - (Andrino - RKAM)
                            
               16/06/2014 - Aumento de casas decimais do campo tt-creditos.vlrendim.
                            Conforme chamado: 128240 data: 06/02/2014 - Jéssica(DB1).
                            
               15/07/2014 - #128240 - Versao com conversao web salva em
                            sistema/equipe/carlos/tarefas/128240/ (Carlos)
                            
               17/12/2014 - #228751 Inclusao de clausula crapcld.cdtipcld = 1 
                            (controle diario) na procedure carrega_pesquisa (Carlos)
               
               18/12/2014 - Realizar merge do processo que foi convertido pela 
                            GATI com o que está atualmente no Round Table.
                          - Remover o campo "Com Justificativa" quando cddopcao 
                            F e X.
                          - Realizado validação das funcionalidade para a
                            conversão WEB (Douglas - Chamado 143945)
                            
..............................................................................*/

{ includes/ctremp.i "NEW" }
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0173tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1. 

DEF VAR h-b1wgen0173  AS HANDLE                                        NO-UNDO.

/* ............................. QUERYS/BROWSES .............................. */
DEF QUERY q-creditos   FOR tt-creditos.
DEF QUERY q-just       FOR tt-just.
DEF QUERY q-pesquisa   FOR tt-pesquisa.
DEF QUERY q-atividade  FOR tt-atividade.

DEF BROWSE b-creditos QUERY q-creditos
    DISP tt-creditos.cdagenci FORMAT "zz9"
         tt-creditos.nrdconta
         tt-creditos.vlrendim FORMAT "zzz,zzz,zz9.99"
         tt-creditos.vltotcre
         tt-creditos.qtultren FORMAT "zzz,zzz,zz9"
         tt-creditos.dsstatus FORMAT "x(10)"
    WITH 05 DOWN NO-BOX.

DEF BROWSE b-pesquisa QUERY q-pesquisa
    DISP tt-pesquisa.cdagenci FORMAT "zz9"
         tt-pesquisa.dtmvtolt FORMAT "99/99/99"
         tt-pesquisa.nrdconta
         tt-pesquisa.vlrendim FORMAT "zzz,zzz,zz9.99"
         tt-pesquisa.vltotcre
         tt-pesquisa.qtultren FORMAT "zzz,zzz,zz9"         
    WITH 07 DOWN NO-BOX.

DEF BROWSE b-atividade QUERY q-atividade
    DISP tt-atividade.cdagenci FORMAT "zz9"
         tt-atividade.dtmvtolt FORMAT "99/99/99"
         tt-atividade.nrdconta
         tt-atividade.vlrendim FORMAT "zzz,zzz,zz9.99"
         tt-atividade.vltotcre
         tt-atividade.qtultren FORMAT "zzz,zzz,zz9"
         WITH 07 DOWN NO-BOX.

DEF BROWSE b-just QUERY q-just
    DISP tt-just.cddjusti
         tt-just.dsdjusti
    WITH 8 DOWN NO-LABELS TITLE "Justificativas" OVERLAY.

/* ................................ VARIAVEIS ................................ */

DEF VAR aux_confirma    AS CHAR FORMAT "(!)"                        NO-UNDO.
DEF VAR aux_dsstatus    AS CHAR FORMAT "x(10)"                      NO-UNDO.
DEF VAR aux_linharel    AS CHAR                                     NO-UNDO.
DEF VAR aux_flextjus    AS LOGI                                     NO-UNDO.
DEF VAR aux_infocoaf    AS CHAR                                     NO-UNDO.
DEF VAR aux_ffechrea    AS LOGI                                     NO-UNDO.
DEF VAR aux_nrdjusti    AS INTE                                     NO-UNDO.

DEF VAR tel_operacao    AS LOGICAL FORMAT "Credito/Saque"           NO-UNDO.
DEF VAR tel_flextjus    AS LOGICAL FORMAT "Sim/Nao"                 NO-UNDO.
DEF VAR tel_dtmvtolt    AS DATE FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_dtrefini    AS DATE                                     NO-UNDO.
DEF VAR tel_dtreffim    AS DATE                                     NO-UNDO.
DEF VAR tel_cdstatus    AS INTE     FORMAT "9"                      NO-UNDO.
DEF VAR tel_cdincoaf    AS INTE     FORMAT "9"                      NO-UNDO.
DEF VAR tel_tpdsaida    AS CHAR     FORMAT "!"                      NO-UNDO.
DEF VAR tel_nrdconta    LIKE crapass.nrdconta                       NO-UNDO.

/* Variaveis para a include cabrel132_1.i */
DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

/* Variaveis para impressao */
DEF VAR aux_nmarquiv    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqpdf    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscaminh    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmendter    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                     NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR    FORMAT "x(08)" INIT "Imprimir"   NO-UNDO.
DEF VAR tel_dscancel    AS CHAR    FORMAT "x(08)" INIT "Cancelar"   NO-UNDO.
DEF VAR aux_contador    AS INT                                      NO-UNDO.
DEF VAR aux_flgescra    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgfirst    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgrodar    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgcance    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_dsmessag    AS CHAR                                     NO-UNDO.

/* ............................... FORMULARIOS ............................... */
FORM aux_dscaminh FORMAT "x(20)"
     aux_nmarquiv FORMAT "x(20)"
     WITH NO-LABEL OVERLAY ROW 12 CENTERED FRAME f_arquivo.

FORM b-just
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 11 NO-LABELS NO-BOX CENTERED OVERLAY
     FRAME f_just.

FORM b-atividade
     WITH ROW 6 OVERLAY WIDTH 78 CENTERED FRAME f_atividade.

FORM "      Vinculo:" tt-atividade.tpvincul
     "      COAF:" tt-atividade.infrepcf    FORMAT "x(15)"
     "    Status:" tt-atividade.dsstatus    FORMAT "x(10)"
     SKIP
     "Justificativa:" tt-atividade.cddjusti
     "-"              tt-atividade.dsdjusti FORMAT "x(55)"
     SKIP
     "   Comp.Justi:"tt-atividade.dsobserv  FORMAT "x(55)"
     SKIP
     " Parecer Sede:" tt-atividade.dsobsctr FORMAT "x(55)"
     WITH OVERLAY ROW 17 COLUMN 2 NO-BOX NO-LABEL FRAME f_atividade_detalhe.

FORM b-pesquisa
     WITH ROW 7 OVERLAY WIDTH 78 CENTERED FRAME f_pesquisa.

FORM SKIP
     "Justificativa:" tt-pesquisa.dsdjusti 
     SKIP
     "         COAF:" tt-pesquisa.infrepcf   FORMAT "x(12)"
                                    HELP "Informar/Nao Informar"
     SKIP
     "       Status:" tt-pesquisa.dsstatus   FORMAT "x(10)"
     WITH OVERLAY ROW 18 COLUMN 2 NO-BOX NO-LABEL FRAME f_pesquisa_detalhe.

FORM b-creditos
     WITH ROW 6 OVERLAY WIDTH 80 CENTERED FRAME f_credito NO-BOX.

FORM SKIP
     "Nome:" tt-creditos.nmprimtl
     SKIP
     "Tp.Pessoa:" tt-creditos.inpessoa FORMAT "x(10)" 
     " Ope. PA:" tt-creditos.cdoperad 
     SPACE(5)
     "Ope. Sede:" tt-creditos.opeenvcf 
     SKIP
     "Justificativa:" tt-creditos.cddjusti 
        HELP "Informe o codigo da justificativa ou tecle F7 para listar."
        VALIDATE (INPUT tt-creditos.cddjusti <= aux_nrdjusti AND
                  INPUT tt-creditos.cddjusti > 0, "Codigo invalido")
     "-" tt-creditos.dsdjusti    FORMAT "x(55)"
        HELP "Informe a descricao da justificativa."                 
        VALIDATE (INPUT tt-creditos.dsdjusti <> "", "Informe uma descricao") 
     SKIP
     SPACE(2)  
     "Comp.Justi:" tt-creditos.dsobserv
     SKIP
     SPACE(8)   
     "COAF:" tt-creditos.infrepcf   FORMAT "x(12)"
                                    HELP "Informar/Nao Informar"
     SKIP
     "Parecer Sede:" tt-creditos.dsobsctr 
     WITH OVERLAY ROW 15 COLUMN 2 NO-BOX NO-LABEL FRAME f_credito_detalhe.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE " Analise de movimentacao X renda - Sede " FRAME f_moldura.
    
FORM SKIP
     tel_dtrefini LABEL "Inicial" AUTO-RETURN
        HELP "Informe a data inicial"
        VALIDATE (INPUT tel_dtrefini <> ? , 
                  "Data nao informada.")
     tel_dtreffim LABEL "Final" AUTO-RETURN
        HELP "Informe a data final"
        VALIDATE (INPUT tel_dtreffim <> ? OR
                  INPUT tel_dtrefini < tel_dtreffim,                  
                  "Data inicial deve ser menor que a final.")
     tel_tpdsaida LABEL "Saida" AUTO-RETURN  
        HELP "T-TELA,I-IMPRESSORA,A-ARQUIVO"
        VALIDATE (CAN-DO("A,I,T",tel_tpdsaida),"Saida Invalida.")
     WITH ROW 5 COLUMN 14 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldsed_t.

FORM SKIP
     tel_nrdconta LABEL "Conta/DV" AUTO-RETURN
     tel_dtrefini LABEL "Inicial" AUTO-RETURN
        HELP "Informe a data inicial"
        VALIDATE (INPUT tel_dtrefini <> ? , 
                  "Data nao informada.")
     tel_dtreffim LABEL "Final" AUTO-RETURN
        HELP "Informe a data final"
        VALIDATE (INPUT tel_dtreffim <> ? OR
                  INPUT tel_dtrefini < tel_dtreffim,                  
                  "Data inicial deve ser menor que a final.")
     SKIP
     tel_cdstatus LABEL "Status" AUTO-RETURN    AT 03
        HELP "1-TODOS,2-EM ANALISE,3-FECHADO"
        VALIDATE (CAN-DO("1,2,3",tel_cdstatus),"Status Invalido.")
     tel_cdincoaf LABEL "COAF" AUTO-RETURN      AT 25
        HELP "1-TODOS,2-JA INFORMADO"
        VALIDATE (CAN-DO("1,2",tel_cdincoaf),"Codigo Invalido.")
     tel_tpdsaida LABEL "Saida" AUTO-RETURN     AT 40
        HELP "T-TELA,I-IMPRESSORA,A-ARQUIVO"
        VALIDATE (CAN-DO("A,I,T",tel_tpdsaida),"Saida Invalida.")
    WITH ROW 5 COLUMN 14 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldsed_p.

FORM SKIP
     tel_operacao LABEL "Operacao" AUTO-RETURN
        HELP "Creditos/Saques"                                             
     tel_flextjus LABEL "Com Justificativa"
        HELP "Sim/Nao"                                                     AT 19
     tel_dtmvtolt LABEL "Data"                                             AT 45
        HELP "Informe a data desejada"
     WITH ROW 5 COLUMN 14 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldsed.

FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(C,F,J,X,P,T)"
        VALIDATE (CAN-DO("C,F,J,X,P,T",glb_cddopcao),"014 - Opcao Errada.") AT 3
    WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cddopcao.

/* ................................. EVENTOS ................................. */
ON "RETURN" OF  b-just DO:
    ASSIGN tt-creditos.cddjusti = tt-just.cddjusti
           tt-creditos.dsdjusti = IF tt-just.cddjusti <> 7 THEN 
                                     tt-just.dsdjusti
                                  ELSE
                                     "".

    DISP tt-creditos.cddjusti tt-creditos.dsdjusti WITH FRAME f_credito_detalhe.

    APPLY "GO".
END.

ON "ENTRY" OF b-atividade DO:
    APPLY "VALUE-CHANGED" TO b-atividade.
END.

ON "VALUE-CHANGED" OF b-atividade DO:    

    DISP tt-atividade.tpvincul
         tt-atividade.infrepcf
         tt-atividade.dsstatus
         tt-atividade.cddjusti
         tt-atividade.dsdjusti
         tt-atividade.dsobserv          
         tt-atividade.dsobsctr
         WITH FRAME f_atividade_detalhe.

END.

ON "ENTRY" OF b-pesquisa DO:
    APPLY "VALUE-CHANGED" TO b-pesquisa.
END.

ON "VALUE-CHANGED" OF b-pesquisa DO:    

    DISP tt-pesquisa.dsdjusti 
         tt-pesquisa.infrepcf 
         tt-pesquisa.dsstatus
         WITH FRAME f_pesquisa_detalhe.

END.

ON "ENTRY" OF b-creditos DO:
    APPLY "VALUE-CHANGED" TO b-creditos.
END.

ON "VALUE-CHANGED" OF b-creditos DO:    
    
    DISP tt-creditos.nmprimtl
         tt-creditos.inpessoa 
         tt-creditos.cdoperad
         tt-creditos.opeenvcf
         tt-creditos.infrepcf
         tt-creditos.cddjusti 
         tt-creditos.dsdjusti 
         tt-creditos.dsobserv
         tt-creditos.dsobsctr
         WITH FRAME f_credito_detalhe.
END.


ON "RETURN" OF b-creditos DO:

    FIND CURRENT tt-creditos NO-LOCK.

    IF AVAIL tt-creditos THEN
    DO:
    IF  glb_cddopcao = "J" THEN
        DO TRANSACTION:
            ASSIGN aux_flextjus = tt-creditos.flextjus.

            UPDATE tt-creditos.cddjusti WITH FRAME f_credito_detalhe
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

            IF  tt-creditos.cddjusti = 7 THEN
                UPDATE tt-creditos.dsdjusti WITH FRAME f_credito_detalhe.
            ELSE
            IF  tt-creditos.cddjusti > 0 THEN
                DO:
                    FIND tt-just 
                        WHERE tt-just.cddjusti = tt-creditos.cddjusti
                        NO-LOCK NO-ERROR.

                    ASSIGN tt-creditos.dsdjusti = tt-just.dsdjusti.

                    DISP tt-creditos.dsdjusti 
                         WITH FRAME f_credito_detalhe.
                END.

            UPDATE tt-creditos.infrepcf WITH FRAME f_credito_detalhe
            EDITING:
                READKEY.
            
                IF  KEYFUNCTION(LASTKEY) = "I" OR
                    KEYFUNCTION(LASTKEY) = "i" THEN 
                   DO:
                       ASSIGN tt-creditos.infrepcf = "Informar".
                       DISP tt-creditos.infrepcf 
                            WITH FRAME f_credito_detalhe.
                   END.
                ELSE
                IF  KEYFUNCTION(LASTKEY) = "N" OR
                   KEYFUNCTION(LASTKEY) = "n" THEN 
                   DO:
                       ASSIGN tt-creditos.infrepcf = "Nao Informar".
                       DISP tt-creditos.infrepcf 
                            WITH FRAME f_credito_detalhe.
                   END.
                ELSE
                IF  KEYFUNCTION(LASTKEY) = "RETURN"    OR
                    KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    APPLY LASTKEY.
                ELSE
                   NEXT.
            END. /* Fim do EDITING */             

            UPDATE tt-creditos.dsobsctr WITH FRAME f_credito_detalhe
            EDITING:
                READKEY.

                IF  KEYFUNCTION(LASTKEY) = "RETURN" OR
                    KEYFUNCTION(LASTKEY) = "GO"     THEN
                    DO:
                        IF (tt-creditos.infrepcf = "Informar" OR
                            tt-creditos.cddjusti = 8)         AND
                            INPUT tt-creditos.dsobsctr = ""   THEN
                            DO:
                                MESSAGE "Informe um parecer.".
                                NEXT.
                            END.
                        ELSE
                            LEAVE.
                    END.
                ELSE
                    APPLY LASTKEY.

            END. /* Fim do EDITING */ 

            ASSIGN tt-creditos.opeenvcf = glb_cdoperad.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).
    
            IF aux_confirma = "S" THEN
                DO:
                    RUN verifica-cria-handle.
                    RUN Justifica_movimento IN h-b1wgen0173(INPUT glb_cdcooper,
                                                            INPUT glb_cdagenci,
                                                            INPUT 0, /* nrdcaixa */
                                                            INPUT glb_cdoperad,
                                                            INPUT glb_dtmvtolt,
                                                            INPUT 1, /* idorigem */
                                                            INPUT glb_nmdatela,
                                                            INPUT glb_cdprogra,
                                                            INPUT tt-creditos.nrdrowid,
                                                            INPUT tt-creditos.cddjusti,
                                                            INPUT tt-creditos.dsdjusti,
                                                            INPUT tt-creditos.dsobsctr,
                                                            INPUT tt-creditos.opeenvcf,
                                                            INPUT tt-creditos.infrepcf,
                                                            INPUT tel_dtmvtolt,
                                                           OUTPUT TABLE tt-erro).
                    RUN verifica-deleta-handle.
                    
                    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                        FOR EACH tt-erro.
                            MESSAGE tt-erro.dscritic.
                        END.
                        RETURN "NOK".  
                    END.


                    IF  NOT aux_flextjus THEN
                        DELETE tt-creditos.
                    
                    FIND FIRST tt-creditos NO-LOCK NO-ERROR.

                    b-creditos:REFRESH().
                    IF  AVAIL tt-creditos THEN
                        DO:  
                            APPLY "VALUE-CHANGED" TO b-creditos. 
                        END.
                    ELSE
                        DO:
                            DISP "" @ tt-creditos.nmprimtl
                                 "" @ tt-creditos.inpessoa 
                                 "" @ tt-creditos.cdoperad
                                 "" @ tt-creditos.opeenvcf
                                 "" @ tt-creditos.infrepcf
                                 "" @ tt-creditos.cddjusti 
                                 "" @ tt-creditos.dsdjusti 
                                 "" @ tt-creditos.dsobserv
                                 "" @ tt-creditos.dsobsctr
                                 WITH FRAME f_credito_detalhe.
                        END.
                END. 
        END. /* FIM Opcao J */
    
    END. /* Existem registros */

END.
/* ........................................................................... */

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_cddopcao.                                    
PAUSE(0).

RUN verifica-cria-handle.
RUN Dados_cooperativa IN h-b1wgen0173(INPUT  glb_cdcooper,
                                      INPUT  glb_cdagenci,
                                      INPUT  0, /* nrdcaixa */
                                      INPUT  glb_cdoperad,
                                      INPUT  glb_dtmvtolt,
                                      INPUT  1, /* idorigem */
                                      INPUT  glb_nmdatela,
                                      INPUT  glb_cdprogra,
                                     OUTPUT TABLE tt-crapcop,
                                     OUTPUT TABLE tt-erro).
RUN verifica-deleta-handle.

IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
    FOR EACH tt-erro.
        MESSAGE tt-erro.dscritic.
    END.
    RETURN "NOK".  
END.

FIND FIRST tt-crapcop NO-ERROR.
IF NOT AVAIL tt-crapcop THEN DO:
    MESSAGE glb_dscritic.

    ASSIGN glb_cdcritic = 0.
    RETURN "NOK".
END.

ASSIGN glb_cddopcao = "C"
       tel_operacao = TRUE
       tel_dtmvtolt = glb_dtmvtoan
       aux_dscaminh = "/micros/" + tt-crapcop.dsdircop + "/".

DO WHILE TRUE:
    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_cddopcao.

        { includes/acesso.i }

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
            DO:
               RUN fontes/novatela.p.
               IF  CAPS(glb_nmdatela) <> "CLDSED"  THEN
                   DO:
                      RUN verifica-deleta-handle.
                      
                      HIDE FRAME f_cldsed.
                      HIDE FRAME f_cldsed_p.
                      HIDE FRAME f_cldsed_t.
                      HIDE FRAME f_cddopcao.
                      HIDE FRAME f_moldura.

                      RETURN.
                   END.
                ELSE
                    NEXT.
            END.

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
        
        DISP tel_operacao WITH FRAME f_cldsed.
        
        IF tel_operacao THEN /* CREDITO */
            DO:
                IF  glb_cddopcao = "F" THEN
                    DO TRANSACTION: 
                        ASSIGN tel_dtmvtolt = ?.

                        HIDE FRAME f_cldsed_p NO-PAUSE.
                        HIDE FRAME f_cldsed_t NO-PAUSE.
                        VIEW FRAME f_cldsed.

                        tel_flextjus:VISIBLE IN FRAME f_cldsed = FALSE.

                        UPDATE tel_dtmvtolt
                               WITH FRAME f_cldsed.

                        RUN verifica-cria-handle.
                        RUN Valida_nao_justificado IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                   INPUT glb_cdagenci,
                                                                   INPUT 0, /* nrdcaixa */
                                                                   INPUT glb_cdoperad,
                                                                   INPUT tel_dtmvtolt,
                                                                   INPUT glb_dtmvtolt,
                                                                   INPUT 1, /* idorigem */
                                                                   INPUT glb_nmdatela,
                                                                   INPUT glb_cdprogra,
                                                                   OUTPUT TABLE tt-erro).
                        RUN verifica-deleta-handle.

                        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                            FOR EACH tt-erro.
                                MESSAGE tt-erro.dscritic.
                            END.
                            LEAVE.
                        END.                        

                        RUN fontes/confirma.p (INPUT  "",
                                               OUTPUT aux_confirma).

                        IF aux_confirma = "S" THEN
                        DO:
                            RUN verifica-cria-handle.
                            RUN Valida_COAF IN h-b1wgen0173(INPUT glb_cdcooper,
                                                            INPUT glb_cdagenci,
                                                            INPUT 0, /* nrdcaixa */
                                                            INPUT glb_cdoperad,
                                                            INPUT tel_dtmvtolt,
                                                            INPUT 1, /* idorigem */
                                                            INPUT glb_nmdatela,
                                                            INPUT glb_cdprogra,
                                                           OUTPUT aux_infocoaf,
                                                           OUTPUT TABLE tt-erro).
                            RUN verifica-deleta-handle.
                            
                            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FOR EACH tt-erro.
                                    MESSAGE tt-erro.dscritic.
                                END.
                                RETURN "NOK".  
                            END.

                            IF  aux_infocoaf <> "" THEN
                                DO:
                                    RUN fontes/confirma.p 
                                        (INPUT aux_infocoaf,
                                         OUTPUT aux_confirma).

                                    IF  aux_confirma = "N" THEN
                                        DO:
                                            LEAVE.
                                        END.
                                    HIDE MESSAGE NO-PAUSE.

                                END.

                            RUN verifica-cria-handle.
                            RUN Efetiva_fechamento IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                   INPUT glb_cdagenci,
                                                                   INPUT 0, /* nrdcaixa */
                                                                   INPUT glb_cdoperad,
                                                                   INPUT glb_dtmvtolt,
                                                                   INPUT 1, /* idorigem */
                                                                   INPUT glb_nmdatela,
                                                                   INPUT glb_cdprogra,
                                                                   INPUT tel_dtmvtolt,
                                                                  OUTPUT TABLE tt-erro).
                            RUN verifica-deleta-handle.
                            
                            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FOR EACH tt-erro.
                                    MESSAGE tt-erro.dscritic.
                                END.
                                RETURN "NOK".  
                            END.
                            
                            MESSAGE "Fechamento realizado com sucesso.".
                            PAUSE 2 NO-MESSAGE.

                            RETURN.
                        END. /* FIM IF confirma */
                    END.
                ELSE
                IF  glb_cddopcao = "X" THEN
                    DO TRANSACTION:
                        ASSIGN tel_dtmvtolt = ?.

                        HIDE FRAME f_cldsed_p NO-PAUSE.
                        HIDE FRAME f_cldsed_t NO-PAUSE.
                        VIEW FRAME f_cldsed.

                        tel_flextjus:VISIBLE IN FRAME f_cldsed = FALSE.

                        UPDATE tel_dtmvtolt
                               WITH FRAME f_cldsed.
                        
                        RUN fontes/confirma.p (INPUT  "",
                                               OUTPUT aux_confirma).    

                        IF  aux_confirma = "S" THEN
                            DO:
                                RUN verifica-cria-handle.
                                RUN Cancela_fechamento IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                       INPUT glb_cdagenci,
                                                                       INPUT 0, /* nrdcaixa */
                                                                       INPUT glb_cdoperad,
                                                                       INPUT glb_dtmvtolt,
                                                                       INPUT 1, /* idorigem */
                                                                       INPUT glb_nmdatela,
                                                                       INPUT glb_cdprogra,
                                                                       INPUT tel_dtmvtolt,
                                                                      OUTPUT TABLE tt-erro).
                                RUN verifica-deleta-handle.
                                
                                IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                    FOR EACH tt-erro.
                                        MESSAGE tt-erro.dscritic.
                                        PAUSE 2 NO-MESSAGE.    
                                    END.
                                    RETURN "NOK".  
                                END.
                                ELSE
                                    MESSAGE "Fechamento desfeito.".

                                PAUSE 2 NO-MESSAGE.    

                                RETURN.
                            END.
                        CLEAR FRAME f_cldsed   NO-PAUSE.
                    END.
                ELSE
                IF glb_cddopcao = "J" THEN
                    DO:
                        ASSIGN tel_dtmvtolt = ?.    

                        HIDE FRAME f_cldsed_p NO-PAUSE.
                        HIDE FRAME f_cldsed_t NO-PAUSE.
                        VIEW FRAME f_cldsed.

                        tel_flextjus:VISIBLE IN FRAME f_cldsed = TRUE.

                        UPDATE tel_flextjus
                               tel_dtmvtolt
                               WITH FRAME f_cldsed.
                        
                        RUN verifica-cria-handle.
                        RUN Carrega_justificativas IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                   INPUT glb_cdagenci,
                                                                   INPUT 0, /* nrdcaixa */
                                                                   INPUT glb_cdoperad,
                                                                   INPUT glb_dtmvtolt,
                                                                   INPUT 1, /* idorigem */
                                                                   INPUT glb_nmdatela,
                                                                   INPUT glb_cdprogra,
                                                                  OUTPUT aux_nrdjusti,
                                                                  OUTPUT TABLE tt-just,
                                                                  OUTPUT TABLE tt-erro).
                        
                        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                            RUN verifica-deleta-handle.
                            FOR EACH tt-erro.
                                MESSAGE tt-erro.dscritic.
                            END.
                            RETURN "NOK".  
                        END.

                        RUN Valida_fechamento IN h-b1wgen0173(INPUT glb_cdcooper,
                                                              INPUT glb_cdagenci,
                                                              INPUT 0, /* nrdcaixa */
                                                              INPUT glb_cdoperad,
                                                              INPUT tel_dtmvtolt,
                                                              INPUT tel_dtmvtolt,
                                                              INPUT 1, /* idorigem */
                                                              INPUT glb_nmdatela,
                                                             OUTPUT aux_ffechrea,
                                                             OUTPUT TABLE tt-erro).
                        
                        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                            RUN verifica-deleta-handle.
                            FOR EACH tt-erro.
                                MESSAGE tt-erro.dscritic.
                            END.
                            RETURN "NOK".  
                        END.

                        IF  aux_ffechrea /* Fechamento realizado */ THEN
                            DO:
                                RUN verifica-deleta-handle.

                                MESSAGE "Fechamento para esta data ja realizado".
                                NEXT-PROMPT tel_dtmvtolt WITH FRAME f_cldsed.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                RUN verifica-cria-handle.
                                RUN Carrega_creditos IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                     INPUT glb_cdagenci,
                                                                     INPUT 0, /* nrdcaixa */
                                                                     INPUT glb_cdoperad,
                                                                     INPUT tel_dtmvtolt,
                                                                     INPUT 1, /* idorigem */
                                                                     INPUT glb_nmdatela,
                                                                     INPUT glb_cdprogra,
                                                                     INPUT tel_flextjus,
                                                                    OUTPUT TABLE tt-creditos,
                                                                    OUTPUT TABLE tt-erro).
                                RUN verifica-deleta-handle.

                                IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                    FOR EACH tt-erro.
                                        MESSAGE tt-erro.dscritic.
                                    END.
                                END.
                                ELSE DO:
                                    OPEN QUERY q-creditos FOR EACH tt-creditos.
                        
                                    UPDATE b-creditos WITH FRAME f_credito.
                        
                                    HIDE FRAME f_credito_detalhe.
                                END.
                                HIDE FRAME f_credito NO-PAUSE.
                                HIDE FRAME f_credito_detalhe NO-PAUSE.                                
                            END.
                    END.
                ELSE
                IF  glb_cddopcao = "P" THEN
                    DO:
                        ASSIGN tel_nrdconta = 0
                               tel_dtrefini = ?
                               tel_dtreffim = glb_dtmvtolt
                               tel_cdstatus = 1 
                               tel_cdincoaf = 1
                               tel_tpdsaida = "T".    
                    
                        HIDE FRAME f_cldsed   NO-PAUSE.
                        HIDE FRAME f_cldsed_t NO-PAUSE.
                        VIEW FRAME f_cldsed_p.

                        UPDATE tel_nrdconta
                               tel_dtrefini
                               tel_dtreffim
                               tel_cdstatus
                               tel_cdincoaf
                               tel_tpdsaida
                               WITH FRAME f_cldsed_p.
                        
                        RUN carrega_pesquisa.
                        HIDE FRAME f_pesquisa NO-PAUSE.
                        HIDE FRAME f_pesquisa_detalhe NO-PAUSE.
                    END. /* FIM Opcao P */
                ELSE
                IF  glb_cddopcao = "T" THEN
                    DO:
                        ASSIGN tel_dtrefini = ?
                               tel_dtreffim = glb_dtmvtolt
                               tel_tpdsaida = "T".
                    
                        HIDE FRAME f_cldsed   NO-PAUSE.
                        HIDE FRAME f_cldsed_p NO-PAUSE.
                        VIEW FRAME f_cldsed_t.

                        UPDATE tel_dtrefini
                               tel_dtreffim
                               tel_tpdsaida
                               WITH FRAME f_cldsed_t.

                        RUN carrega_atividade.
                        HIDE FRAME f_atividade NO-PAUSE.
                        HIDE FRAME f_atividade_detalhe NO-PAUSE.
                    END. /* FIM Opcao T */
                ELSE
                    DO:
                        ASSIGN tel_dtmvtolt = ?.

                        HIDE FRAME f_cldsed_p NO-PAUSE.
                        HIDE FRAME f_cldsed_t NO-PAUSE.
                        VIEW FRAME f_cldsed.                                            

                        tel_flextjus:VISIBLE IN FRAME f_cldsed = TRUE.

                        UPDATE tel_flextjus
                               tel_dtmvtolt
                               WITH FRAME f_cldsed.

                        RUN verifica-cria-handle.
                        RUN Carrega_creditos IN h-b1wgen0173(INPUT glb_cdcooper,
                                                             INPUT glb_cdagenci,
                                                             INPUT 0, /* nrdcaixa */
                                                             INPUT glb_cdoperad,
                                                             INPUT tel_dtmvtolt,
                                                             INPUT 1, /* idorigem */
                                                             INPUT glb_nmdatela,
                                                             INPUT glb_cdprogra,
                                                             INPUT tel_flextjus,
                                                            OUTPUT TABLE tt-creditos,
                                                            OUTPUT TABLE tt-erro).
                        RUN verifica-deleta-handle.

                        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                            FOR EACH tt-erro.
                                MESSAGE tt-erro.dscritic.
                            END.
                        END.
                        ELSE DO:
                            OPEN QUERY q-creditos FOR EACH tt-creditos.
                
                            UPDATE b-creditos WITH FRAME f_credito.
                
                            HIDE FRAME f_credito_detalhe.
                        END.

                        HIDE FRAME f_credito NO-PAUSE.
                        HIDE FRAME f_credito_detalhe NO-PAUSE.
                    END.
            END.

    END. /* Fim do DO WHILE TRUE das opcoes */
    
END. /* Fim do DO WHILE TRUE */

/* ............................... PROCEDURES ............................... */
PROCEDURE carrega_atividade:
    
    RUN verifica-cria-handle.
    RUN Carrega_atividade IN h-b1wgen0173(INPUT glb_cdcooper,
                                          INPUT glb_cdagenci,
                                          INPUT 0, /* nrdcaixa */
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT 1, /* idorigem */
                                          INPUT glb_nmdatela,
                                          INPUT glb_cdprogra,
                                          INPUT tel_dtrefini,
                                          INPUT tel_dtreffim,
                                         OUTPUT TABLE tt-atividade,
                                         OUTPUT TABLE tt-erro).
    RUN verifica-deleta-handle.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
        FOR EACH tt-erro.
            MESSAGE tt-erro.dscritic.
        END.
        RETURN "NOK".  
    END.


    FIND FIRST tt-atividade NO-LOCK NO-ERROR.

    IF  AVAIL tt-atividade THEN
        DO:
            IF  tel_tpdsaida = "T" THEN
                DO:
                    OPEN QUERY q-atividade FOR EACH tt-atividade 
                                           BY tt-atividade.cdagenci
                                           BY tt-atividade.dtmvtolt
                                           BY tt-atividade.nrdconta.
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-atividade WITH FRAME f_atividade.
                        LEAVE.
                    END.

                    HIDE FRAME f_atividade_detalhe.
                    CLOSE QUERY q-atividade.
                END.
            ELSE
                DO:
                    /* Inicializa Variaveis Relatorio */
                    ASSIGN glb_cdcritic = 0
                           glb_cdempres = 11
                           glb_cdrelato[1] = 611.

                    { includes/cabrel132_1.i }
                    
                    IF  tel_tpdsaida = "A" THEN
                        DO:
                            ASSIGN aux_dsmessag = 
                                   "Deseja gerar arquivo para o EXCEL? (S/N):".
                        
                            RUN fontes/confirma.p (INPUT  aux_dsmessag,
                                                   OUTPUT aux_confirma).

                            ASSIGN aux_nmarquiv = "".

                            DISP aux_dscaminh WITH FRAME f_arquivo.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                UPDATE aux_nmarquiv WITH FRAME f_arquivo.

                                LEAVE.
                            END.
                            
                            HIDE FRAME f_arquivo NO-PAUSE.

                            IF aux_nmarquiv = "" THEN
                                RETURN "NOK".

                            ASSIGN aux_nmarquiv = "/micros/" + tt-crapcop.dsdircop 
                                                  + "/" + aux_nmarquiv.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_nmarquiv = "rl/cldsed_" + STRING(TIME) 
                                                  + ".lst". 
                        END.

                    RUN verifica-cria-handle.
                    RUN Gera_imprime_arq_atividade IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                   INPUT glb_cdagenci,
                                                                   INPUT 0, /* nrdcaixa */
                                                                   INPUT glb_cdoperad,
                                                                   INPUT glb_dtmvtolt,
                                                                   INPUT 1, /* idorigem */ 
                                                                   INPUT glb_nmdatela,
                                                                   INPUT glb_cdprogra,
                                                                   INPUT tel_tpdsaida,
                                                                   INPUT aux_confirma, /* gerar em excel? */
                                                                   INPUT TABLE tt-atividade,
                                                                   INPUT-OUTPUT aux_nmarquiv,
                                                                  OUTPUT aux_nmarqpdf,
                                                                  OUTPUT TABLE tt-erro).
                    RUN verifica-deleta-handle.
                    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                        FOR EACH tt-erro.
                            MESSAGE tt-erro.dscritic.
                        END.
                        RETURN "NOK".  
                    END.
                END.

        END.
    ELSE
        MESSAGE "Nao existem lancamentos a serem listados.".

    RETURN "OK".
END PROCEDURE. /* carrega_atividade */

PROCEDURE carrega_pesquisa:

    RUN verifica-cria-handle.
    RUN Carrega_pesquisa IN h-b1wgen0173(INPUT glb_cdcooper,
                                         INPUT glb_cdagenci,
                                         INPUT 0, /* nrdcaixa */
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT 1, /* idorigem */
                                         INPUT glb_nmdatela,
                                         INPUT glb_cdprogra,
                                         INPUT tel_nrdconta,
                                         INPUT tel_cdincoaf,
                                         INPUT tel_cdstatus,
                                         INPUT tel_dtrefini,
                                         INPUT tel_dtreffim,
                                        OUTPUT TABLE tt-pesquisa,
                                        OUTPUT TABLE tt-erro).
    RUN verifica-deleta-handle.
    
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
        FOR EACH tt-erro.
            MESSAGE tt-erro.dscritic.
        END.
        RETURN "NOK".  
    END.

    FIND FIRST tt-pesquisa NO-LOCK NO-ERROR.

    IF  AVAIL tt-pesquisa THEN
        DO:
            IF  tel_tpdsaida = "T" THEN
                DO:
                    OPEN QUERY q-pesquisa FOR EACH tt-pesquisa 
                                              BY tt-pesquisa.cdagenci
                                              BY tt-pesquisa.dtmvtolt
                                              BY tt-pesquisa.nrdconta.
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-pesquisa WITH FRAME f_pesquisa.
                        LEAVE.
                    END.

                    HIDE FRAME f_pesquisa_detalhe.
                    CLOSE QUERY q-pesquisa.

                END.
            ELSE
                DO:
                    
                    IF  tel_tpdsaida = "A" THEN
                        DO:
                            ASSIGN aux_nmarquiv = "".

                            DISP aux_dscaminh WITH FRAME f_arquivo.

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                UPDATE aux_nmarquiv WITH FRAME f_arquivo.
                                LEAVE.
                            END.
                            
                            HIDE FRAME f_arquivo NO-PAUSE.

                            IF aux_nmarquiv = "" THEN
                                RETURN "NOK".

                            RUN verifica-cria-handle.
                            RUN Gera_imprime_arq_pesquisa IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                          INPUT glb_cdagenci,
                                                                          INPUT 0, /* nrdcaixa */ 
                                                                          INPUT glb_cdoperad,
                                                                          INPUT glb_dtmvtolt,
                                                                          INPUT 1, /* idorigem */ 
                                                                          INPUT glb_nmdatela,
                                                                          INPUT glb_cdprogra,
                                                                          INPUT tel_tpdsaida,
                                                                          INPUT TABLE tt-pesquisa,
                                                                          INPUT-OUTPUT aux_nmarquiv,
                                                                         OUTPUT aux_nmarqpdf,
                                                                         OUTPUT TABLE tt-erro).
                            RUN verifica-deleta-handle.
                            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FOR EACH tt-erro.
                                    MESSAGE tt-erro.dscritic.
                                END.
                                RETURN "NOK".  
                            END.

                        END.

                    IF  tel_tpdsaida = "I" THEN
                        DO:
                            RUN verifica-cria-handle.
                            RUN Gera_imprime_arq_pesquisa IN h-b1wgen0173(INPUT glb_cdcooper,
                                                                          INPUT glb_cdagenci,
                                                                          INPUT 0, /* nrdcaixa */ 
                                                                          INPUT glb_cdoperad,
                                                                          INPUT glb_dtmvtolt,
                                                                          INPUT 1, /* idorigem */ 
                                                                          INPUT glb_nmdatela,
                                                                          INPUT glb_cdprogra,
                                                                          INPUT tel_tpdsaida,
                                                                          INPUT TABLE tt-pesquisa,
                                                                          INPUT-OUTPUT aux_nmarquiv,
                                                                         OUTPUT aux_nmarqpdf,
                                                                         OUTPUT TABLE tt-erro).
                            RUN verifica-deleta-handle.
                            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                                FOR EACH tt-erro.
                                    MESSAGE tt-erro.dscritic.
                                END.
                                RETURN "NOK".  
                            END.

                        END.
                END.
        END.
    ELSE
        MESSAGE "Nao existem lancamentos a serem listados.".

    RETURN "OK".    
END PROCEDURE. /* carrega_pesquisa */

/* Procedure para validar se existe o HANDLE da b1wgen0173 e criar */
PROCEDURE verifica-cria-handle:
    IF NOT VALID-HANDLE(h-b1wgen0173) THEN
        RUN sistema/generico/procedures/b1wgen0173.p 
            PERSISTENT SET h-b1wgen0173.
END PROCEDURE.

/* Procedure para validar se existe o HANDLE da b1wgen0173 e deletar */
PROCEDURE verifica-deleta-handle:
    IF  VALID-HANDLE(h-b1wgen0173) THEN
        DELETE OBJECT h-b1wgen0173.
END PROCEDURE.
