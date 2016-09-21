/* .............................................................................

   Programa: Fontes/empres.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93.                        Ultima atualizacao: 13/11/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela EMPRES - Calculo do saldo devedor de emprestimos.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               05/03/98 - Alterado para usar o campo qtprecal no lugar do
                          qtprepag (Edson).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               08/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               29/06/2004 - Acessar Tabela Avalistas Terceiros(Mirtes)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               02/03/2006 - Considerar lancamentos durante o mes para calculo
                            das prestacoes pagas;
                          - Incluido "A Regularizar" e "Meses Decor."(Evandro).
               08/04/2008 - Alterado formato do campo "crapepr.qtpreemp" de 
                            "z9" para "zz9" - Kbase IT Solutions - Paulo 
                            Ricardo Maciel.
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               05/08/2011 - Nao apresentar contratos liquidados(Mirtes)
               
               12/03/2012 - Declarado variaveis necessarias para utilizacao
                            da include lelem.i (Tiago).
                            
               31/07/2013 - Adaptado para uso de BO (GATI - Rener).
               
               07/03/2014 - Ajustes para deixar codigo no padrao (Lucas R.)
               
               09/05/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                           posicoes (Tiago/Gielow SD137074).
                           
               13/11/2014 - Adicionado parametro em Busca_Contrato.
                            (Jorge/Elton) - SD 168151 
............................................................................ */

{ includes/ctremp.i "NEW" }
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0165tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEFINE VARIABLE tel_nrdconta AS INTEGER     FORMAT "zzzz,zzz,9"     NO-UNDO.
DEFINE VARIABLE tel_nrctremp AS INTEGER     FORMAT "zz,zzz,zz9"     NO-UNDO.
DEFINE VARIABLE tel_cdtipsfx AS INTEGER     FORMAT "9"              NO-UNDO.
DEFINE VARIABLE tel_dtcalcul AS DATE        FORMAT "99/99/9999"     NO-UNDO.
DEFINE VARIABLE tel_nmprimtl AS CHARACTER   FORMAT "x(35)"          NO-UNDO.
DEFINE VARIABLE epr_nrctremp AS INTEGER     EXTENT 99               NO-UNDO.
DEFINE VARIABLE aux_nrctatos AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrctremp AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_stimeout AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_cddopcao AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nmdcampo AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_dtlimcal AS DATE                                NO-UNDO.

DEFINE VARIABLE h-b1wgen0165 AS HANDLE                              NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta               AT  3 LABEL "Conta/dv" AUTO-RETURN
                                      HELP "Informe o numero da conta do associado"
     tel_nmprimtl               AT 25 LABEL "Titular"
     tel_cdtipsfx               AT 71 LABEL "T.F."
     WITH NO-BOX ROW 6 COLUMN 2 OVERLAY SIDE-LABELS FRAME f_conta.

FORM tel_nrctremp               AT  3 LABEL "Contrato" 
                                      AUTO-RETURN
                                      HELP "Informe o numero do contrato ou F7 para listar"
     tel_dtcalcul               AT 28 LABEL "Calcular ate" 
                                      AUTO-RETURN
                                      HELP "Informe a data de calculo"
     tt-pesqsr.cdpesqui     AT 32 LABEL "Pesquisa"
     SKIP(1)
     tt-pesqsr.vlemprst     AT  5 LABEL "Valor Emprestado"
     tt-pesqsr.txdjuros     AT 48 LABEL "Taxa de juros"     
                                  FORMAT "zz,zz9.9999999"
     SKIP
     tt-pesqsr.vlsdeved     AT  8 LABEL "Saldo Devedor"
     tt-pesqsr.vljurmes     AT 49 LABEL "Juros do Mes"
     SKIP
     tt-pesqsr.vlpreemp     AT  3 LABEL "Valor da Prestacao"
     tt-pesqsr.vljuracu     AT 45 LABEL "Juros Acumulados"
     SKIP
     tt-pesqsr.vlprepag     AT  4 LABEL "Valor Pago no Mes"
     tt-pesqsr.qtmesdec     AT 45 LABEL "Meses Decorridos"  
                                  FORMAT "           zz9"
     SKIP
     tt-pesqsr.vlpreapg     AT  8 LABEL "A Regularizar"     
                                  FORMAT "        zzz,zz9.99"
     tt-pesqsr.dsdpagto     AT 42 NO-LABEL
     SKIP(1)
     "Prestacoes:"          AT  2
     tt-pesqsr.qtprecal     AT 16 LABEL "Pagas"
     tt-pesqsr.dslcremp     AT 35 LABEL "L. Credito"
     SKIP
     tt-pesqsr.qtpreapg     AT 14 LABEL "A Pagar"
     tt-pesqsr.dsfinemp     AT 35 LABEL "Finalidade"
     SKIP(1)
     tt-pesqsr.nrctaav1     AT  2 LABEL "Aval 1"
     tt-pesqsr.cpfcgc1      AT 20 NO-LABEL
     tt-pesqsr.nmdaval1     AT 35 NO-LABEL FORMAT "x(28)"    
     tt-pesqsr.nrraval1     AT 65 LABEL "Ramal"
     SKIP
     tt-pesqsr.nrctaav2     AT  2 LABEL "Aval 2"
     tt-pesqsr.cpfcgc2      AT 20 NO-LABEL
     tt-pesqsr.nmdaval2     AT 35 NO-LABEL FORMAT "x(28)"    
     tt-pesqsr.nrraval2     AT 65 LABEL "Ramal"
     WITH NO-BOX ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78 FRAME f_empres.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_conta.
VIEW FRAME f_empres.

DO WHILE TRUE:

    RUN fontes/inicia.p.
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF NOT VALID-HANDLE(h-b1wgen0165) THEN
           RUN sistema/generico/procedures/b1wgen0165.p 
               PERSISTENT SET h-b1wgen0165.

        UPDATE tel_nrdconta WITH FRAME f_conta
        EDITING:

            ASSIGN aux_stimeout = 0.

            DO  WHILE TRUE:

                READKEY PAUSE 1.

                IF  LASTKEY = -1 THEN 
                    DO:
                        ASSIGN aux_stimeout = aux_stimeout + 1.
                    
                        IF  aux_stimeout > glb_stimeout THEN
                            QUIT.

                        NEXT.
                    END.
            
                APPLY LASTKEY.
                
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
        END.  /*  Fim do EDITING  */

        LEAVE.

    END.  /*  Fim do WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
        DO: 
            RUN fontes/novatela.p.
            
            IF  glb_nmdatela <> "EMPRES" THEN 
                DO:
                   IF  VALID-HANDLE(h-b1wgen0165) THEN
                       DELETE OBJECT h-b1wgen0165.
                   
                   HIDE FRAME f_empres.
                   HIDE FRAME f_conta.
                   HIDE FRAME f_moldura.
                   RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN 
        DO:
           { includes/acesso.i}
           ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        RUN busca_contrato.
         
        IF  RETURN-VALUE = "OK" THEN
            LEAVE.
        ELSE 
            DO: 
                
                CLEAR FRAME f_empres NO-PAUSE.
                
                UPDATE tel_nrdconta WITH FRAME f_conta
                EDITING:
                               
                  ASSIGN aux_stimeout = 0.
                
                    DO  WHILE TRUE:
                
                        READKEY PAUSE 1.
                        
                        IF  LASTKEY = -1 THEN 
                            DO:         
                                ASSIGN aux_stimeout = aux_stimeout + 1.
                            
                                IF  aux_stimeout > glb_stimeout THEN
                                    QUIT.
                        
                                NEXT.
                            END.
                        
                        APPLY LASTKEY.
                        
                        LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */
                END.  /*  Fim do EDITING  */
            END.
    END.
    
    DISPLAY tel_nmprimtl tel_cdtipsfx WITH FRAME f_conta.
    
    IF  aux_nrctatos = 0 THEN 
        DO:
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

    DO  WHILE TRUE:
        
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IF  glb_cdcritic > 0 THEN 
                DO:
                    BELL.
                    CLEAR FRAME f_empres NO-PAUSE.
                    glb_cdcritic = 0.
                END.

            IF  aux_nrctatos = 1 THEN 
                DO:
                    NEXT-PROMPT tel_dtcalcul WITH FRAME f_empres.
                    ASSIGN tel_nrctremp = aux_nrctremp.
                END.
            

            UPDATE tel_nrctremp tel_dtcalcul WITH FRAME f_empres
            EDITING:
                
                ASSIGN aux_stimeout = 0.
                
                DO WHILE TRUE:
                    
                    READKEY PAUSE 1.

                    IF  LASTKEY = -1 THEN 
                        DO:
                            ASSIGN aux_stimeout = aux_stimeout + 1.
                            
                            IF  aux_stimeout > glb_stimeout THEN 
                                QUIT.

                            NEXT.
                        END.

                    IF  LASTKEY     = KEYCODE("F7") AND 
                        FRAME-FIELD = "tel_nrctremp" THEN 
                        DO:
                           IF  s_chextent > 0 THEN 
                               DO:
                                  ASSIGN s_row      = 10
                                         s_column   = 15
                                         s_hide     = TRUE
                                         s_title    = " Contratos "
                                         s_dbfilenm = "crapepr"
                                         s_multiple = FALSE
                                         s_wide     = TRUE.
                                  
                                  RUN fontes/ctremp.p.
                                  
                                  IF  s_chcnt > 0 THEN 
                                      DO:
                                         ASSIGN tel_nrctremp = 
                                                epr_nrctremp[s_choice[s_chcnt]].
                                         
                                         DISPLAY tel_nrctremp WITH FRAME f_empres.
                                      END. 
                               END.
                        END.

                    APPLY LASTKEY.
                    
                    LEAVE.
                END.  /*  Fim do DO WHILE TRUE  */
            END.  /*  Fim do EDITING  */

            RUN Busca_emprestimo.

            IF  RETURN-VALUE <> "NOK" THEN
                DO:
                    FOR EACH tt-pesqsr NO-LOCK:
                    
                        DISPLAY tt-pesqsr.nrctremp @ tel_nrctremp   
                                tt-pesqsr.cdpesqui 
                                tt-pesqsr.vlemprst 
                                tt-pesqsr.txdjuros
                                tt-pesqsr.vlsdeved
                                tt-pesqsr.vljurmes 
                                tt-pesqsr.vlpreemp 
                                tt-pesqsr.vljuracu 
                                tt-pesqsr.vlprepag 
                                tt-pesqsr.qtmesdec 
                                tt-pesqsr.vlpreapg 
                                tt-pesqsr.dsdpagto 
                                tt-pesqsr.qtprecal 
                                tt-pesqsr.dslcremp 
                                tt-pesqsr.qtpreapg 
                                tt-pesqsr.dsfinemp 
                                tt-pesqsr.nrctaav1 
                                tt-pesqsr.cpfcgc1  
                                tt-pesqsr.nmdaval1 
                                tt-pesqsr.nrraval1
                                tt-pesqsr.nrctaav2 
                                tt-pesqsr.cpfcgc2  
                                tt-pesqsr.nmdaval2 
                                tt-pesqsr.nrraval2
                                WITH FRAME f_empres.
                    END.
                END.

            LEAVE.
        END.  /*  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  */

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  
            DO:
                CLEAR FRAME f_empres NO-PAUSE.
                LEAVE.
            END.      
    
    END.  /*  Fim do DO WHILE TRUE  */
END.  /*  Fim do DO WHILE TRUE:  */

/* ..........................................................................*/

PROCEDURE busca_contrato:

    EMPTY TEMP-TABLE tt-crapass.
    EMPTY TEMP-TABLE tt-crapepr.
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde, carregando contratos...".

    RUN Busca_contrato IN h-b1wgen0165 (INPUT glb_cdcooper, 
                                        INPUT glb_cdagenci,
                                        INPUT 0, /*nrdcaixa*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1, /*idorigem*/
                                        INPUT glb_nmdatela,
                                        INPUT glb_cdprogra,
                                        INPUT tel_nrdconta,
                                        INPUT FALSE, /*glb_flgerlog*/
                                        INPUT glb_cdbccxlt,
                                        INPUT FALSE, /* apenas tpemprst 0 */
                                        OUTPUT aux_nmdcampo,
                                        OUTPUT TABLE tt-crapass,
                                        OUTPUT TABLE tt-crapepr,
                                        OUTPUT TABLE tt-erro) .
    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:

           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro THEN
               MESSAGE tt-erro.dscritic.
           ELSE
               MESSAGE "Erro na busca de contratos.".
               
           PAUSE.
           
           RETURN "NOK".

        END.

    FOR EACH tt-crapass NO-LOCK:

        ASSIGN tel_cdtipsfx = tt-crapass.cdtipsfx
               tel_nmprimtl = tt-crapass.nmprimtl.
    END.

    ASSIGN aux_nrctatos = 0 
             s_chextent = 0 
           tel_dtcalcul = ?.

    FOR FIRST tt-crapepr NO-LOCK BY tt-crapepr.dtmvtolt:
        
        ASSIGN aux_nrctremp = tt-crapepr.nrctremp
               tel_nrctremp = aux_nrctremp.
    END.

    FOR EACH tt-crapepr NO-LOCK BY tt-crapepr.dtmvtolt DESC:

        ASSIGN aux_nrctatos = aux_nrctatos + 1
               epr_nrctremp[aux_nrctatos] = tt-crapepr.nrctremp
               s_chextent = s_chextent + 1
               s_chlist[s_chextent] = STRING(tt-crapepr.nrctremp,
                                      "z,zzz,zz9") + " " +
                                      STRING(tt-crapepr.dtmvtolt,
                                      "99/99/9999") + " " +
                                      STRING(tt-crapepr.vlemprst,
                                      "zzzz,zzz,zz9.99") + " " +
                                      STRING(tt-crapepr.qtpreemp,
                                      "zz9") + " x " +
                                      STRING(tt-crapepr.vlpreemp,
                                      "zzz,zzz,zz9.99") + " " + 
                                      "LC " + STRING(tt-crapepr.cdlcremp,
                                      "9999") + " " + "Fin " + 
                                      STRING(tt-crapepr.cdfinemp,"999").
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_emprestimo.

    DEFINE VARIABLE h-b1wgen0002 AS HANDLE      NO-UNDO.

    EMPTY TEMP-TABLE tt-pesqsr.
    EMPTY TEMP-TABLE tt-erro.

    MESSAGE "Aguarde, carregando dados do contrato...".

    RUN Busca_emprestimo IN h-b1wgen0165 (INPUT glb_cdcooper,
                                          INPUT glb_cdagenci,
                                          INPUT glb_cdbccxlt,
                                          INPUT glb_cdoperad,
                                          INPUT "EMPRES",
                                          INPUT 1,  /* Ayllos */
                                          INPUT tel_nrdconta,
                                          INPUT 1, /*par_idseqttl*/
                                          INPUT glb_dtmvtolt,
                                          INPUT glb_dtmvtopr,
                                          INPUT tel_dtcalcul,
                                          INPUT tel_nrctremp,
                                          INPUT glb_cdprogra,
                                          INPUT glb_inproces,
                                          INPUT 0, /*nrdcaixa*/
                                          INPUT FALSE,
                                          INPUT FALSE, /*glb_flgcondc*/
                                          OUTPUT aux_nmdcampo,
                                          OUTPUT TABLE tt-pesqsr,
                                          OUTPUT TABLE tt-erro).
    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:

           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
           IF  AVAIL tt-erro   THEN
               MESSAGE tt-erro.dscritic.
           ELSE
               MESSAGE "Erro na busca de emprestimos.".
           
           PAUSE.
           
           RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE. /* Busca_emprestimo */
