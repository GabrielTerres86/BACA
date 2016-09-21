/*.............................................................................

   Programa: Fontes/coninf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder
   Data    : Julho/2011                          Ultima Atualizacao: 08/04/2014

   Dados referentes ao programa :

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar consulta de informativos dos associados.
   
   Alterações: 28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               08/04/2014 - Ajuste WHOLE-INDEX; adicionado filtro com
                            cdcooper na leitura da temp-table. (Fabricio)       

..............................................................................*/

{ includes/var_online.i  }
{ sistema/generico/includes/b1wgen0142tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0142 AS HANDLE                                         NO-UNDO.
DEF VAR tel_cdcooper AS INTE        FORMAT "zz9"                       NO-UNDO.
DEF VAR aux_cdcooper AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                    INNER-LINES 11                     NO-UNDO.
DEF VAR tel_dtmvtol1 AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_dtmvtol2 AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_cdagenci AS INTE        FORMAT "zz9"                       NO-UNDO.
DEF VAR tel_tpdocmto AS INTE        FORMAT "zz9"                       NO-UNDO.
DEF VAR aux_tpdocmto AS CHAR        FORMAT "X(31)" VIEW-AS COMBO-BOX   
                                    INNER-LINES 12                     NO-UNDO.
DEF VAR tel_indespac AS INTE        FORMAT "9"                         NO-UNDO.
DEF VAR tel_cdfornec AS INTE        FORMAT "zzzz9"                     NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR tel_tpdsaida AS LOGI        FORMAT "Arquivo/Tela"              NO-UNDO.
DEF VAR aux_nmdireto AS CHAR        FORMAT "X(35)"                     NO-UNDO.
DEF VAR tel_nmdireto AS CHAR        FORMAT "X(40)"                     NO-UNDO.
DEF VAR tel_nmarquiv AS CHAR        FORMAT "X(25)"                     NO-UNDO.

DEF VAR aux_nmtpdcto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdircop AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEFINE VARIABLE aux_nmcooper AS CHARACTER   NO-UNDO.

DEF QUERY q_crapinf FOR tt-crapinf.

DEF BROWSE b_crapinf QUERY q_crapinf
    DISPLAY tt-crapinf.cdcooper FORMAT ">>9"      COLUMN-LABEL "Coop."
            tt-crapinf.dtmvtolt FORMAT "99/99/99" COLUMN-LABEL "Data"
            tt-crapinf.cdagenci FORMAT "zz9"      COLUMN-LABEL "PA"
            tt-crapinf.dstpdcto                   COLUMN-LABEL "Tipo Carta"
            tt-crapinf.qtinform FORMAT ">>>,>>9"  COLUMN-LABEL "Qtde."
            tt-crapinf.dsdespac                   COLUMN-LABEL "Destino"
            tt-crapinf.nmfornec                   COLUMN-LABEL "Fornec."
            WITH 10 DOWN.

FORM SKIP
     aux_cdcooper COLON 13 LABEL "Cooperativa"
                  HELP "Selecione a Cooperativa ou a opcao 'TODAS'."
     tel_dtmvtol1 COLON 45 LABEL "Periodo"
                  HELP "Informe a data inicial do periodo."
     "a"
     tel_dtmvtol2 NO-LABEL 
                  HELP "Informe a data final do periodo."
     SKIP
     tel_cdagenci COLON 13 LABEL "PA"
                  HELP "Informe o numero do PA ou zero '0' para todos."
     aux_tpdocmto COLON 41 LABEL "Tipo Carta"
                  HELP "Selecione o Tipo de Carta ou a opcao 'TODOS'."
     SKIP
     tel_indespac COLON 13 LABEL "Destino"
                  HELP "Informe 0-Todos,1-Correio,2-Balcao."

     tel_cdfornec COLON 45 LABEL "Fornecedor"
                  HELP "Informe 0-Todos,1-Postmix,2-Engecopy."
     SKIP
     tel_tpdsaida COLON 13 LABEL "Saida"
                  HELP "Informe T-Tela,A-Arquivo."
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_consulta.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nmdireto FORMAT "X(40)" AT 01
     tel_nmarquiv FORMAT "X(25)" AT 42
     ".csv"                      AT 68
     WITH ROW 12 COLUMN 2 NO-LABELS WIDTH 78 OVERLAY NO-BOX 
          CENTERED FRAME f_arquivo.

FORM SKIP(1)
     b_crapinf
     HELP "Use as <SETAS> p/ navegar ou <F4> p/ sair."
     WITH CENTERED OVERLAY NO-BOX ROW 6 WIDTH 78 SIDE-LABELS FRAME f_crapinf.

ON   RETURN OF aux_cdcooper
     DO:
         ASSIGN tel_cdcooper = INT(aux_cdcooper:SCREEN-VALUE 
                                                IN FRAME f_consulta).

         APPLY "GO".
     END.

ON   RETURN OF b_crapinf
     APPLY "GO".

ON   RETURN OF aux_tpdocmto
     APPLY "TAB".

RUN Carrega_Tela.

ASSIGN glb_cdcritic = 0.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

        IF  glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.
            END.
        
        ASSIGN tel_cdcooper = 0
               tel_dtmvtol1 = ?
               tel_dtmvtol2 = ?
               tel_cdagenci = 0
               tel_indespac = 0
               tel_cdfornec = 0
               tel_tpdsaida = NO.

        DISP aux_cdcooper
             tel_dtmvtol1
             tel_dtmvtol2
             tel_cdagenci
             aux_tpdocmto
             tel_indespac
             tel_cdfornec
             tel_tpdsaida
             WITH FRAME f_consulta.

        /* Se nao estiver na CECRED, nao habilita campo Cooper */
        IF  glb_cdcooper <> 3 THEN
            DO:
                ASSIGN aux_cdcooper = STRING(glb_cdcooper)
                       tel_cdcooper = glb_cdcooper.

                DISP    aux_cdcooper WITH FRAME f_consulta.
                DISABLE aux_cdcooper WITH FRAME f_consulta.
            END.
        ELSE
            DO:
                ASSIGN aux_cdcooper = "0"
                       tel_cdcooper = 0.

                DISP    aux_cdcooper WITH FRAME f_consulta.
                UPDATE  aux_cdcooper WITH FRAME f_consulta.
            END.

        DO  WHILE TRUE:

            UPDATE tel_dtmvtol1 tel_dtmvtol2 tel_cdagenci aux_tpdocmto
                   tel_indespac tel_cdfornec tel_tpdsaida WITH FRAME f_consulta
            EDITING:
      
                READKEY.
                APPLY LASTKEY.
          
                HIDE MESSAGE NO-PAUSE.
          
                IF  GO-PENDING THEN
                    DO:
                        RUN Busca_Dados.
          
                        IF  RETURN-VALUE <> "OK" THEN
                            DO:
                                {sistema/generico/includes/foco_campo.i
                                    &VAR-GERAL=SIM
                                    &NOME-FRAME="f_consulta"
                                    &NOME-CAMPO=aux_nmdcampo }
                            END.
                    END.
             
            END. /*  Fim do EDITING  */

            LEAVE.
        END.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */ 

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "CONINF"   THEN
                DO:
                    HIDE FRAME f_consulta NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  tel_tpdsaida THEN /* Arquivo */
        DO:
            MESSAGE "Arquivo gerado com sucesso.".
            PAUSE 2 NO-MESSAGE.
        END.
    ELSE
        DO:
            OPEN QUERY q_crapinf FOR EACH tt-crapinf 
                        WHERE tt-crapinf.cdcooper = glb_cdcooper NO-LOCK.
            
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_crapinf WITH FRAME f_crapinf.
                LEAVE.
            END.   

            HIDE FRAME f_crapinf NO-PAUSE.
        END.

END.  /* Fim do DO WHILE TRUE */  

/*............................................................................*/

PROCEDURE pi_carrega_cooperativas:

    ASSIGN aux_cdcooper:LIST-ITEM-PAIRS IN FRAME f_consulta = aux_nmcooper
           aux_cdcooper:SCREEN-VALUE    IN FRAME f_consulta = "0".

    RETURN "OK".

END PROCEDURE. /* pi_carrega_cooperativas */

PROCEDURE pi_carrega_tipos_carta:

    ASSIGN aux_tpdocmto:LIST-ITEM-PAIRS IN FRAME f_consulta = aux_nmtpdcto
           aux_tpdocmto:SCREEN-VALUE    IN FRAME f_consulta = "0".

    RETURN "OK".

END PROCEDURE. /* pi_carrega_cooperativas */

PROCEDURE Carrega_Tela:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0142) THEN
        RUN sistema/generico/procedures/b1wgen0142.p
            PERSISTENT SET h-b1wgen0142.

    RUN Carrega_Tela IN h-b1wgen0142
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
         OUTPUT aux_nmcooper,
         OUTPUT aux_nmtpdcto,
         OUTPUT aux_dsdircop,
         OUTPUT TABLE tt-crapcop,
         OUTPUT TABLE tt-tpodcto,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0142) THEN
        DELETE OBJECT h-b1wgen0142.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RUN pi_carrega_cooperativas.
    RUN pi_carrega_tipos_carta.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Dados:

    DO WITH FRAME f_consulta:
    
        ASSIGN tel_dtmvtol1
               tel_dtmvtol2
               tel_cdagenci
               aux_tpdocmto
               tel_indespac
               tel_cdfornec
               tel_tpdsaida.
    END.

    IF  tel_tpdsaida THEN /* Arquivo */
        DO:
            ASSIGN aux_nmdireto = "/micros/" + TRIM(aux_dsdircop) + "/"
                   tel_nmdireto = "Arquivo: " + aux_nmdireto
                   tel_nmdireto = FILL(" ",40 - LENGTH(tel_nmdireto)) + 
                                  tel_nmdireto.

            DO  WHILE TRUE:

                DISP tel_nmdireto   WITH FRAME f_arquivo.
                UPDATE tel_nmarquiv WITH FRAME f_arquivo.

                IF  tel_nmarquiv = ""   THEN
                    DO:
                        MESSAGE "Arquivo nao informado.".
                        NEXT.
                    END.

                HIDE FRAME f_arquivo NO-PAUSE.
                LEAVE.
            END.

        END.

    ASSIGN tel_tpdocmto = INTE(aux_tpdocmto).

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0142) THEN
        RUN sistema/generico/procedures/b1wgen0142.p
            PERSISTENT SET h-b1wgen0142.

    MESSAGE "Aguarde, carregando dados... ".

    RUN Busca_Dados IN h-b1wgen0142
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT tel_nmarquiv,
          INPUT tel_cdcooper,
          INPUT tel_cdagenci,
          INPUT tel_tpdocmto,
          INPUT tel_indespac,
          INPUT tel_cdfornec,
          INPUT tel_dtmvtol1,
          INPUT tel_dtmvtol2,
          INPUT tel_tpdsaida,
          INPUT 0,
          INPUT 0,
          INPUT FALSE, /* flgerlog */
         OUTPUT aux_qtregist,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-crapinf,
         OUTPUT TABLE tt-crapinf-aux,
         OUTPUT TABLE tt-erro).

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0142) THEN
        DELETE OBJECT h-b1wgen0142.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */
