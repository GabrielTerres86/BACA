/* .............................................................................

   Programa: fontes/pesqdp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2004                         Ultima atualizacao: 27/06/2014

   Dados referenftes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PESQDP.
   
   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               09/02/2006 - Inclusao da opcao NO-LOCK e NO-ERROR - SQLWorks - 
                            Andre
                            
               12/01/2011 - Inserido o format no campo nmprimtl
               
               02/02/2011 - Inclusão do campo Compe. (Fabrício)
               
               22/07/2011 - Inclusão do campo "Capturado" (Isara - RKAM)
               
               01/03/2012 - Inclusão da opção "R" (Isara - RKAM)
               
               24/06/2013 - Correção do diretório do arquivo da impressão
                            do relatório. (Carlos)
                            
               28/06/2013 - Correção do update do campo tel_cdbccxlt no 
                            frame f_pesqdp_r. (Reinert)
                            
               11/07/2013 - Correção na atribuição de valor na variável 
                            tel_dsdocmc7 e correção no caminho da geração de
                            relatório. (Reinert)
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
               04/06/2014 - Adicionado campo do codigo de agencia destino no 
                            browse b-valor (Reinert).
                            
               27/06/2014 - Adicionado opcao "D". (Reinert)
............................................................................ */

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0144tt.i }

/* DEF STREAM str_1. /* Para impressao */ */

DEF VAR h-b1wgen0144 AS HANDLE NO-UNDO.

DEF   VAR rel_nmresemp  AS CHAR       FORMAT "x(15)"                   NO-UNDO.
DEF   VAR rel_nmempres  AS CHAR       FORMAT "x(15)"                   NO-UNDO.
DEF   VAR rel_nmrelato  AS CHAR       FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF   VAR rel_nmmodulo  AS CHAR       FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

DEF   VAR rel_nrmodulo  AS INTE       FORMAT "9"                       NO-UNDO.

DEF   VAR tel_dtmvtolt  AS DATE       FORMAT "99/99/9999"              NO-UNDO.
DEF   VAR tel_vlcheque  AS DECIMAL    FORMAT "zzz,zzz,zzz,zz9.99"      NO-UNDO.
DEF   VAR tel_dsdocmc7  AS CHAR       FORMAT "x(40)"                   NO-UNDO.
DEF   VAR tel_tipocons  AS LOGICAL    FORMAT "VALOR/CMC-7"   INIT "V"  NO-UNDO.
DEF   VAR aux_cddopcao  AS CHAR                                        NO-UNDO.

DEF   VAR tel_dtmvtini  AS DATE       FORMAT "99/99/9999"              NO-UNDO.
DEF   VAR tel_dtmvtfim  AS DATE       FORMAT "99/99/9999"              NO-UNDO.
DEF   VAR tel_cdbccxlt  AS CHAR       FORMAT "x(08)" VIEW-AS COMBO-BOX
                                      INNER-LINES 06                   NO-UNDO.
DEF   VAR tel_tpdsaida  AS CHAR       FORMAT "!(1)"                    NO-UNDO.
DEF   VAR aux_nmendter  AS CHAR       FORMAT "x(20)"                   NO-UNDO.

/* Variaveis para a include impressao.i */
DEF   VAR tel_dsimprim  AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF   VAR tel_dscancel  AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF   VAR aux_flgescra  AS LOGI                                        NO-UNDO.
DEF   VAR aux_dscomand  AS CHAR                                        NO-UNDO.
DEF   VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF   VAR aux_nmarqpdf  AS CHAR                                        NO-UNDO.
DEF VAR aux_qtregist AS INTE NO-UNDO.

DEF   VAR par_flgrodar  AS LOGI                                        NO-UNDO.
DEF   VAR par_flgfirst  AS LOGI                                        NO-UNDO.
DEF   VAR par_flgcance  AS LOGI                                        NO-UNDO.
DEF   VAR aux_contador  AS INTE                                        NO-UNDO.

/*Variaveis opcao "D"*/
DEF   VAR tel_dtdevolu  AS DATE       FORMAT "99/99/9999"              NO-UNDO.

/* Variaveis para impressao */
DEF VAR aux_nmarquiv    AS CHAR                                        NO-UNDO.
DEF VAR aux_dscaminh    AS CHAR                                        NO-UNDO.

DEF VAR tel_nrcampo1 AS INT     FORMAT "99999999"                      NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "9999999999"                    NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "999999999999"                  NO-UNDO.
DEF VAR aux_lsdigctr AS CHAR                                         NO-UNDO.


DEF QUERY q-valor FOR tt-crapchd.

DEF BROWSE b-valor QUERY q-valor
      DISPLAY tt-crapchd.nmresbcc LABEL "Banco"
              SPACE(2)
              tt-crapchd.cdagenci LABEL "PA"
              SPACE(2)
              tt-crapchd.cdagedst LABEL "Age Dst."
              SPACE(2)
              tt-crapchd.nrdconta LABEL "Conta/DV"
              SPACE(2)
              tt-crapchd.nrcheque LABEL "Cheque"
              SPACE(2)
              tt-crapchd.vlcheque LABEL "Valor"
              WITH 5 DOWN WIDTH 78 NO-LABELS OVERLAY.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C,R)."
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_dtmvtolt  AT 1 LABEL "Data do deposito"
                        HELP "Entre com a data do deposito."
                        VALIDATE(tel_dtmvtolt <= glb_dtmvtolt,
                                 "013 - Data errada.")
     tel_tipocons AT 37 LABEL "Consultar por"
                        HELP "Entre com (V)ALOR ou (C)MC-7 para atualizar."
     SKIP(14)            
     WITH ROW 6 COLUMN 18 SIDE-LABELS OVERLAY NO-BOX FRAME f_pesqdp_c.

FORM tel_vlcheque  AT  2   LABEL "Valor do cheque"
                           HELP "Entre com o valor do cheque."
                           VALIDATE(tel_vlcheque > 0,"269 - Valor errado.")
     WITH ROW 8 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_valor.
     
FORM b-valor
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse.

FORM tt-crapchd.nrdconta   AT  2   LABEL "Conta/DV"
     tt-crapchd.nmprimtl   AT 30   LABEL "Titular" FORMAT "x(40)"
     SKIP(1)
     tt-crapchd.cdagenci   AT  2   LABEL "PA"
     "- "                  AT 15
     tt-crapchd.nmextage   AT 18 
     WITH NO-LABELS ROW 8 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_age.
     
FORM SKIP(1)
     tt-crapchd.cdbccxlt   AT  2   LABEL "Banco"
     " - "
     tt-crapchd.nmextbcc   AT 17   
     SKIP(1)
     tt-crapchd.cdagechq   AT  2   LABEL "Agencia"
     tt-crapchd.vlcheque   AT 55   LABEL "Valor"       
     SKIP(1)
     tt-crapchd.nrctachq   AT  2   LABEL "Conta"
     SKIP(1)
     tt-crapchd.dsdocmc7   AT  2   LABEL "CMC-7"      
     tt-crapchd.nrcheque   AT 54   LABEL "Cheque"
     WITH ROW 12 CENTERED WIDTH 78 NO-LABELS TITLE " DADOS DO CHEQUE " 
     SIDE-LABELS OVERLAY FRAME f_dados_chq.

FORM tt-crapchd.cdcmpchq   AT  2   LABEL "Compe"
     tt-crapchd.cdbccxlt   AT 20   LABEL "Banco"
     tt-crapchd.cdagechq   AT 36   LABEL "Agencia"
     tt-crapchd.nrcheque   AT 55   LABEL "Cheque"
     SKIP
     tt-crapchd.nrctachq   AT  2   LABEL "Conta"
     tt-crapchd.vlcheque   AT 56   LABEL "Valor"       
     SKIP
     tt-crapchd.dsdocmc7   AT  2   LABEL "CMC-7"     
     tt-crapchd.dsbccxlt       AT 52   LABEL "Capturado"
     WITH ROW 18 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes.

FORM tel_dtmvtini  AT 1 LABEL "Data inicial"
                        HELP "Entre com a data do deposito."
                        VALIDATE(tel_dtmvtini <= glb_dtmvtolt,
                                 "013 - Data errada.")
     tel_dtmvtfim  AT 30 LABEL "Data final"
                         HELP "Entre com a data do deposito."
                         VALIDATE(tel_dtmvtfim >= INPUT FRAME f_pesqdp_r tel_dtmvtini AND
                                  tel_dtmvtfim <= glb_dtmvtolt,
                                  "013 - Data errada.")
     tel_cdbccxlt  AT 01 LABEL "Captura" AUTO-RETURN
                         HELP "Selecione o tipo de captura."
     WITH ROW 6 COLUMN 18 SIDE-LABELS OVERLAY NO-BOX FRAME f_pesqdp_r.

FORM aux_dscaminh FORMAT "x(25)"
     aux_nmarquiv FORMAT "x(20)"
     WITH NO-LABEL OVERLAY ROW 12 CENTERED FRAME f_arquivo.

FORM SKIP(1)
         "<"            AT  3
         tel_nrcampo1   AT  4
         "<"            AT 12
         tel_nrcampo2   AT 13
         ">"            AT 23
         tel_nrcampo3   AT 24
         ":  "          AT 36
         SKIP(1)
         WITH ROW 15 CENTERED NO-LABEL
              OVERLAY TITLE " Digite o CMC-7 " FRAME f_cmc7.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK.

ASSIGN glb_cddopcao = "C"
       par_flgrodar = TRUE
       aux_dscaminh = "/micros/" + crapcop.dsdircop + "/".

ON ENTRY OF tel_cdbccxlt   
   DO:
       tel_cdbccxlt:LIST-ITEM-PAIRS IN FRAME f_pesqdp_r = 
                   "TODOS,0,CAIXA,1,CUSTODIA,2,DESCONTO,3,LANCHQ,4".
       
       DISPLAY tel_cdbccxlt
               WITH FRAME f_pesqdp_r.
   END.

ON ENTER OF tel_cdbccxlt OR
     TAB OF tel_cdbccxlt
    DO:
        tel_cdbccxlt = tel_cdbccxlt:SCREEN-VALUE.
        APPLY "GO".
        ASSIGN tel_tpdsaida = "T"
               aux_nmarqimp = ""
               aux_nmarqimp = "pesqdp".

        MESSAGE "(T)erminal, (I)mpressora ou (A)rquivo: " UPDATE tel_tpdsaida.

        HIDE FRAME f_pesqdp_r.

        HIDE MESSAGE NO-PAUSE.

        IF  tel_tpdsaida = "T"  THEN
            DO:

                INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
                INPUT CLOSE.
                
                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                      aux_nmendter.
                
                RUN Gera_Relatorio.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN.

                RUN fontes/visrel.p (INPUT aux_nmarqimp).

            END.
        ELSE
        IF  tel_tpdsaida = "I"  THEN
            DO: 
                INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
                INPUT CLOSE.
                
                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                      aux_nmendter.

                RUN Gera_Relatorio.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN.

                FIND FIRST crapass WHERE
                           crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
               
                { includes/impressao.i }
                
            END.
        ELSE
        IF  tel_tpdsaida = "A"  THEN
            DO: 
                ASSIGN aux_nmarquiv = "".

                DISPLAY aux_dscaminh WITH FRAME f_arquivo.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE aux_nmarquiv WITH FRAME f_arquivo.

                    LEAVE.
                END.
                
                HIDE FRAME f_arquivo NO-PAUSE.

                IF  aux_nmarquiv = "" THEN
                    RETURN "NOK".

                ASSIGN aux_nmendter = aux_nmarquiv.

                RUN Gera_Relatorio.

                FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK.
                
                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " +
                                  aux_dscaminh + "/" + aux_nmarquiv).

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN.

                MESSAGE "Arquivo gerado com sucesso!".
                PAUSE 2 NO-MESSAGE.
                HIDE MESSAGE.
            END.

       EMPTY TEMP-TABLE tt-crapchd.
   END.

ON ITERATION-CHANGED OF b-valor
   DO:
       DISPLAY tt-crapchd.cdagechq tt-crapchd.cdbccxlt tt-crapchd.dsdocmc7
               tt-crapchd.nrcheque tt-crapchd.nrctachq tt-crapchd.vlcheque
               tt-crapchd.cdcmpchq tt-crapchd.dsbccxlt WITH FRAME f_detalhes.
   END.

RUN fontes/inicia.p.
     
VIEW FRAME f_moldura.
PAUSE 0.

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao  WITH FRAME f_opcao.
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "PESQDP"  THEN
                DO:
                    HIDE FRAME f_opcao.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "C"   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_dtmvtolt tel_tipocons WITH FRAME f_pesqdp_c.

                IF  tel_tipocons THEN   
                    DO:
                        UPDATE tel_vlcheque WITH FRAME f_valor.

                        RUN Busca_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.
            
                       OPEN QUERY q-valor FOR EACH tt-crapchd NO-LOCK.

                       ENABLE b-valor WITH FRAME f_browse.

                       DISPLAY tt-crapchd.cdagechq tt-crapchd.cdbccxlt 
                               tt-crapchd.dsdocmc7 tt-crapchd.nrcheque
                               tt-crapchd.nrctachq tt-crapchd.vlcheque
                               tt-crapchd.dsbccxlt WITH FRAME f_detalhes.
                       
                       WAIT-FOR CLOSE OF CURRENT-WINDOW.
                       
                    END.
                ELSE
                    DO: 
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            UPDATE tel_nrcampo1 tel_nrcampo2 tel_nrcampo3 WITH FRAME f_cmc7.
                        
                            ASSIGN tel_dsdocmc7 = "<" + STRING(tel_nrcampo1,"99999999") +
                                                  "<" + STRING(tel_nrcampo2,"9999999999") +
                                                  ">" + STRING(tel_nrcampo3,"999999999999") + ":".
                        
                            RUN Busca_Dados.
                            
                            IF  glb_nrcalcul > 0   THEN
                                DO:
                                    IF  glb_nrcalcul = 1   THEN
                                        NEXT-PROMPT tel_nrcampo1 WITH FRAME f_cmc7.
                                    ELSE
                                    IF  glb_nrcalcul = 2   THEN
                                        NEXT-PROMPT tel_nrcampo2 WITH FRAME f_cmc7.
                                    ELSE
                                    IF  glb_nrcalcul = 3   THEN
                                        NEXT-PROMPT tel_nrcampo3 WITH FRAME f_cmc7.
                                    glb_cdcritic = 8.
                                    NEXT.
                                END.
                              
                           LEAVE.
                        
                        END.  /*  Fim do DO WHILE TRUE  */
                        
                        HIDE FRAME f_cmc7 NO-PAUSE.

                        ASSIGN  tel_nrcampo1 = 0
                                tel_nrcampo2 = 0
                                tel_nrcampo3 = 0
                                tel_dsdocmc7 = "".
                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FIND FIRST tt-crapchd NO-ERROR.

                        IF  NOT AVAIL tt-crapchd THEN
                            NEXT.

                        DISPLAY tt-crapchd.cdagenci tt-crapchd.nmextage
                                tt-crapchd.nrdconta tt-crapchd.nmprimtl 
                                WITH FRAME f_age.

                        DISPLAY tt-crapchd.cdbccxlt tt-crapchd.cdagechq 
                                tt-crapchd.nrcheque tt-crapchd.nrctachq
                                tt-crapchd.vlcheque tt-crapchd.dsdocmc7  
                                tt-crapchd.nmextbcc WITH FRAME f_dados_chq.

                        HIDE FRAME f_age.
                        HIDE FRAME f_dados_chq.

                    
                    END.

            END. /*Fim DO WHILE TRUE ..*/

    END. /* IF  glb_cddopcao = "C" */
    ELSE 
    IF  glb_cddopcao = "R" THEN
        DO:
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                HIDE FRAME f_pesqdp_c.
                HIDE FRAME f_valor.

                UPDATE tel_dtmvtini tel_dtmvtfim WITH FRAME f_pesqdp_r.

                UPDATE tel_cdbccxlt WITH FRAME f_pesqdp_r
                EDITING:

                    READKEY.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
                        DO:
                        /* HIDE FRAME f_detalhes_rel. */
                            VIEW FRAME f_pesqdp_r.
                            RETURN.
                        END.

                    APPLY "ENTER" TO tel_cdbccxlt IN FRAME f_pesqdp_r.

                    LEAVE.

                END.

            END. /* DO WHILE TRUE */

        END. /* IF  glb_cddopcao = "R" */    
END.
                                                                               
PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapchd.
    
    IF  NOT VALID-HANDLE(h-b1wgen0144) THEN
        RUN sistema/generico/procedures/b1wgen0144.p
            PERSISTENT SET h-b1wgen0144.

    MESSAGE "Aguarde...buscando dados...".

    RUN Busca_Dados IN h-b1wgen0144
        ( INPUT glb_cdcooper,       
          INPUT 0,                  
          INPUT 0,                  
          INPUT glb_cdoperad,       
          INPUT glb_nmdatela,       
          INPUT 1, /* idorigem */   
          INPUT tel_dtmvtolt,       
          INPUT tel_tipocons,       
          INPUT tel_vlcheque,       
          INPUT tel_dsdocmc7,       
          INPUT 0,
          INPUT 0,
          INPUT TRUE,/* flgerlog */
          INPUT glb_dtmvtolt, 
         OUTPUT aux_qtregist,
         OUTPUT glb_nrcalcul,
         OUTPUT TABLE tt-crapchd,
         OUTPUT TABLE tt-crapchd-aux,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0144) THEN
        DELETE OBJECT h-b1wgen0144.

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

PROCEDURE Gera_Relatorio:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0144) THEN
        RUN sistema/generico/procedures/b1wgen0144.p
            PERSISTENT SET h-b1wgen0144.

    MESSAGE "Aguarde...Gerando Relatorio...".

    RUN Gera_Relatorio IN h-b1wgen0144
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT aux_nmendter,
          INPUT tel_cdbccxlt,
          INPUT tel_dtmvtini,
          INPUT tel_dtmvtfim,
          INPUT tel_tpdsaida,
          INPUT TRUE,
         OUTPUT glb_nrcalcul,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro)NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0144) THEN
        DELETE OBJECT h-b1wgen0144.

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

END PROCEDURE. /* Gera_Relatorio */

