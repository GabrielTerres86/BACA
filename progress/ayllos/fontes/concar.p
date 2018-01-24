/* ............................................................................

   Programa: Fontes/concar.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Marco/2012                        Ultima Atualizacao: 04/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar relatorio de Operacoes de Credito com Carencia.

   Alteracao : 28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               12/02/2014 - Correção no tamanho da página do rel621 (Lucas).
               
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               04/08/2017 - Inclusao dos historicos de pagamento de
                            emprestimo do Pos-Fixado. (Jaison/James - PRJ298)

............................................................................ */

{ includes/var_online.i }


DEF        STREAM str_1.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_tpimprim AS LOGI    FORMAT "G/I"                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
                                                                     
DEF        VAR tel_nrdconta AS INTE                                  NO-UNDO.
DEF        VAR tel_dtiniper AS DATE                                  NO-UNDO.
DEF        VAR tel_dtfimper AS DATE                                  NO-UNDO.
DEF        VAR tel_nmdireto AS CHAR  FORMAT "x(21)"                  NO-UNDO.
DEF        VAR tel_nmarquiv AS CHAR  FORMAT "x(30)"                  NO-UNDO.

/* Variaveis de impressao */
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.   
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

/* Variaveis do relatorio */
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
                                                                     
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dsrelato AS CHAR                                  NO-UNDO.


FORM SKIP(1)
     "Opcao:"     AT 3
     glb_cddopcao AT 10 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada, (T)ela  ou (I)mpressao."
                  VALIDATE (CAN-DO("T,I",STRING(glb_cddopcao)),
                            "014 - Opcao errada.")

     SKIP(1)
     tel_nrdconta AT 4 LABEL "Conta/dv"    FORMAT "zzzz,zzz,9"
                  HELP "Entre com a Conta/dv ou 0 (zero) para todas."

     tel_dtiniper AT 28 LABEL "Data Inicio" FORMAT "99/99/9999"
                  HELP "Entre com a data de inicio."
                  VALIDATE(tel_dtiniper <> ?,"Informe a data de inicio.")

     tel_dtfimper AT 55 LABEL "Data Fim"    FORMAT "99/99/9999"
                  HELP "Entre com a data fim."
                  VALIDATE(tel_dtfimper <> ?,"Informe a data fim.")
     SKIP(12)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_tela.

FORM "Diretorio:   "     AT 4
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio. 


glb_cddopcao = "T".

RUN fontes/inicia.p.

DO WHILE TRUE:
        
   IF   glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.
        END.
        
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao
             tel_nrdconta
             tel_dtiniper
             tel_dtfimper WITH FRAME f_tela.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CONCAR"   THEN
                 DO:
                     HIDE FRAME f_tela.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
             { includes/acesso.i }
             aux_cddopcao = INPUT glb_cddopcao.
        END.

   IF   tel_nrdconta <> 0   THEN
        DO:
            IF   NOT CAN-FIND (crapass WHERE 
                               crapass.cdcooper = glb_cdcooper   AND
                               crapass.nrdconta = tel_nrdconta   NO-LOCK)   THEN
                 DO:
                     glb_cdcritic = 9.
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_tela.
                     NEXT.
                 END.
        END.

   IF   tel_dtiniper > tel_dtfimper   THEN
        DO:
            MESSAGE "Data de inicio nao pode ser maior que data fim.".
            NEXT-PROMPT tel_dtiniper WITH FRAME f_tela.
            NEXT.
        END.

   IF   INTERVAL(tel_dtfimper,tel_dtiniper,"months") > 6   THEN
        DO:
            MESSAGE "Intervalo das datas nao pode ser maior que 6 meses.".
            NEXT-PROMPT tel_dtiniper WITH FRAME f_tela.
            NEXT.
        END.

   IF   glb_cddopcao = "T"   THEN /* Opcao visualizar em Tela */
        DO:
            RUN gera_crrl621.

            RUN fontes/visrel.p (INPUT aux_nmarqimp).
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN /* Impressao ou arquivo */
        DO:            
            ASSIGN aux_tpimprim = TRUE.

            DO WHILE TRUE ON ENDKEY UNDO , LEAVE:

                MESSAGE "Voce deseja (G)erar o arquivo ou (I)mprimir ? (G/I)" 
                    UPDATE aux_tpimprim.
                LEAVE.

            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            RUN gera_crrl621.

            IF   RETURN-VALUE <> "OK"   THEN
                 NEXT.

            IF   aux_tpimprim   THEN  /* Gerar arquivo */
                 DO:
                    IF   SEARCH ( aux_nmarqimp) <> ?   THEN
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             MESSAGE "Arquivo gerado com sucesso em:" 
                                      SKIP(1)
                                     aux_nmarqimp VIEW-AS ALERT-BOX.
                             LEAVE.
                         END.
                    ELSE
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             MESSAGE "Nao foi possivel gerar o arquivo." 
                                     SKIP
                                     "Verifique a pasta de destino."
                                      VIEW-AS ALERT-BOX.
                             LEAVE.
                         END.
                 END.
            ELSE                      /* Imprimir */
                 DO:
                     FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                              NO-LOCK NO-ERROR.

                     ASSIGN glb_nrdevias = 1
                            glb_nmformul = "234dh".

                     { includes/impressao.i }
                 END.
        END.
END.


PROCEDURE gera_crrl621:

    DEF VAR aux_qtcarenc AS INTE                                NO-UNDO.
    DEF VAR aux_dsdavali AS CHAR                                NO-UNDO.
    DEF VAR aux_vltotemp AS DECI                                NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                NO-UNDO.
    DEF VAR aux_dshistor AS CHAR                                NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                                NO-UNDO.
    DEF VAR h-b1wgen0084 AS HANDLE                              NO-UNDO.

                                            
    FORM crapepr.cdcooper COLUMN-LABEL "Coop;"
         ";"
         crapepr.cdagenci COLUMN-LABEL "PA;"   
         ";"
         crapepr.nrdconta COLUMN-LABEL "Conta/dv;"                         
         ";"
         crapepr.cdlcremp COLUMN-LABEL "Linha;"     
         ";"
         crapepr.nrctremp COLUMN-LABEL "Contrato;"                         
         ";"
         crapass.dsnivris COLUMN-LABEL "Risco Conta;"    FORMAT "x(7)"
         ";"
         crawepr.dtmvtolt COLUMN-LABEL "Dt. Proposta;" 
         ";"   
         crawepr.dsnivris COLUMN-LABEL "Risco Prop.;" FORMAT "x(10)"
         ";"
         crapepr.dtmvtolt COLUMN-LABEL "Dt. Efetivacao;"      
         ";"
         aux_dsdavali     COLUMN-LABEL "Garantia;" FORMAT "x(40)"
         ";"
         aux_qtcarenc     COLUMN-LABEL "Carencia;" 
         ";"
         crapepr.vlemprst COLUMN-LABEL "Vl. Emprestado;"
         ";"
         crawepr.dtdpagto COLUMN-LABEL "Primeiro Vencto;"
         ";"
         aux_dtmvtolt     COLUMN-LABEL "Data Prim. Pagto;" FORMAT "99/99/9999"
         WITH NO-UNDERLINE DOWN WIDTH 300 FRAME f_ctr_planilha.

    FORM crapepr.cdcooper COLUMN-LABEL "Coop"
         crapepr.cdagenci COLUMN-LABEL "PA"   
         crapepr.nrdconta COLUMN-LABEL "Conta/dv"                         
         crapepr.cdlcremp COLUMN-LABEL "Linha"     
         crapepr.nrctremp COLUMN-LABEL "Contrato"   
         crapass.dsnivris COLUMN-LABEL "Risco Conta"    FORMAT "x(7)"
         crawepr.dtmvtolt COLUMN-LABEL "Dt. Proposta." 
         crawepr.dsnivris COLUMN-LABEL "Risco Prop."    FORMAT "x(10)"
         crapepr.dtmvtolt COLUMN-LABEL "Dt. Efetivacao"
         aux_dsdavali     COLUMN-LABEL "Garantia"       FORMAT "x(40)"
         aux_qtcarenc     COLUMN-LABEL "Carencia" 
         crapepr.vlemprst COLUMN-LABEL "Vl. Emprestado"
         crawepr.dtdpagto COLUMN-LABEL "Primeiro Vencto"
         aux_dtmvtolt     COLUMN-LABEL "Data Prim. Pagto"    FORMAT "99/99/9999"
         WITH DOWN WIDTH 300 FRAME f_ctr_normal.
         
    FORM aux_vltotemp LABEL ";;;;;;;;;;;Total" FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABELS WIDTH 40 FRAME f_tot_planilha.

    FORM aux_vltotemp AT 1 LABEL "Total" FORMAT "zzz,zzz,zz9.99"
         WITH COLUMN 141 SIDE-LABELS WIDTH 30 FRAME f_tot_normal.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    /* Se eh planilha */
    IF   glb_cddopcao = "I"   AND   aux_tpimprim   THEN
         DO:
             ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
          
             DISP tel_nmdireto WITH FRAME f_diretorio.
                          
             DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
                 UPDATE tel_nmarquiv WITH FRAME f_diretorio.
                 LEAVE.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  RETURN "NOK".

             ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
                 
             OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp).
         END.
    ELSE        /* Relatorio normal */
         DO:
             INPUT THROUGH basename `tty` NO-ECHO.
             SET aux_nmendter WITH FRAME f_terminal.
             INPUT CLOSE.
             
             aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                   aux_nmendter.
              
             UNIX SILENT VALUE ("rm /usr/coop/" + crapcop.dsdircop + "/rl" + 
                                "/crrl621_" + aux_nmendter + "* 2>/dev/null").

             ASSIGN glb_cdrelato[1] = 621 

                    aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                                   "/rl/crrl621_" + aux_nmendter + 
                                   STRING(TIME) + ".lst".

             OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 62.
        
             { includes/cabrel234_1.i }
         
             VIEW STREAM str_1 FRAME f_cabrel234_1.              
         END.
         
    ASSIGN aux_contador = 0
           aux_vltotemp = 0.

    RUN sistema/generico/procedures/b1wgen0084.p PERSISTENT SET h-b1wgen0084.

    FOR EACH crapepr  WHERE crapepr.cdcooper  = glb_cdcooper    AND 
                            
                            (IF   tel_nrdconta <> 0   THEN
                                  crapepr.nrdconta = tel_nrdconta
                            ELSE  TRUE)                         AND

                            crapepr.dtmvtolt >= tel_dtiniper    AND 
                            crapepr.dtmvtolt <= tel_dtfimper    AND 
                            crapepr.inliquid = 0                NO-LOCK,

        FIRST craplcr WHERE craplcr.cdcooper = crapepr.cdcooper AND 
                            craplcr.cdlcremp = crapepr.cdlcremp AND 
                            craplcr.qtcarenc <> 0               NO-LOCK,

        FIRST crawepr WHERE crawepr.cdcooper = crapepr.cdcooper AND 
                            crawepr.nrdconta = crapepr.nrdconta AND 
                            crawepr.nrctremp = crapepr.nrctremp NO-LOCK,

        FIRST crapass WHERE crapass.cdcooper = crapepr.cdcooper AND 
                            crapass.nrdconta = crapepr.nrdconta NO-LOCK
                            BY crapepr.cdagenci
                               BY crapepr.nrdconta
                                   BY crapepr.nrctremp:

        ASSIGN aux_contador = aux_contador + 1
               aux_vltotemp = aux_vltotemp + crapepr.vlemprst.
                    
        IF   crapepr.tpemprst = 0   THEN /* Price TR */
             DO:
                 ASSIGN aux_qtcarenc = crawepr.dtdpagto - crapepr.dtmvtolt.
             END.
        ELSE                             /* Prefixada */
             DO:
                 ASSIGN aux_qtcarenc = crawepr.dtdpagto - crawepr.dtlibera.
             END.
             
             /* Se tem avalistas */   
        IF   crapepr.nrctaav1 <> 0   OR   crapepr.nrctaav2 <> 0   THEN
             ASSIGN aux_dsdavali = TRIM(STRING(crapepr.nrctaav1,"zzzz,zzz,9")) + 
                                   " / " + 
                                   TRIM(STRING(crapepr.nrctaav2,"zzzz,zzz,9")).
        ELSE            /* Se nao tem garantia de avalistas */
             DO:      
                 ASSIGN aux_dsdavali = "".   

                 /* Bens alienados */
                 FOR EACH crapbpr WHERE 
                          crapbpr.cdcooper = crapepr.cdcooper   AND
                          crapbpr.nrdconta = crapepr.nrdconta   AND
                          crapbpr.tpctrpro = 90                 AND
                          crapbpr.nrctrpro = crapepr.nrctremp   AND
                          crapbpr.flgalien = TRUE               NO-LOCK:

                     IF   aux_dsdavali <>  ""   THEN
                          ASSIGN aux_dsdavali = aux_dsdavali + "/".
                                           
                     ASSIGN aux_dsdavali = aux_dsdavali + crapbpr.dscatbem + 
                                     " - " + 
                              TRIM(STRING(crapbpr.vlmerbem,"zzz,zzz,zz9.99")).                                            
                 END.
             END.

        ASSIGN aux_dshistor =
             "91,92,93,95,393,353,1044,1045,1046,1039,1057,1058,2331,2330,2335,2334". 

        FIND FIRST craplem WHERE craplem.cdcooper = glb_cdcooper        AND
                                 craplem.nrdconta = crapepr.nrdconta  AND
                                 craplem.nrctremp = crapepr.nrctremp  AND
                                 CAN-DO(aux_dshistor,STRING(craplem.cdhistor))
                                 NO-LOCK NO-ERROR.   

        IF   AVAIL craplem   THEN
             ASSIGN aux_dtmvtolt = craplem.dtmvtolt.
        ELSE
             ASSIGN aux_dtmvtolt = ?.
       
        /* Se arquivo para planilha */
        IF   glb_cddopcao = "I"   AND   aux_tpimprim   THEN
             DO:
                 DISPLAY STREAM str_1 crapepr.cdcooper   crapepr.cdagenci
                                      crapepr.nrdconta   crapepr.cdlcremp 
                                      crapepr.nrctremp   crawepr.dsnivris 
                                      crapass.dsnivris   aux_qtcarenc 
                                      crawepr.dtdpagto   crawepr.dtmvtolt 
                                      crapepr.vlemprst   aux_dsdavali    
                                      crapepr.dtmvtolt   aux_dtmvtolt
                                      WITH FRAME f_ctr_planilha. 
           
                 DOWN WITH FRAME f_ctr_planilha.
             END.
        ELSE       /* Impressao ou visualizacao na tela */
             DO:
                 DISPLAY STREAM str_1 crapepr.cdcooper   crapepr.cdagenci
                                      crapepr.nrdconta   crapepr.cdlcremp 
                                      crapepr.nrctremp   crawepr.dsnivris 
                                      crapass.dsnivris   aux_qtcarenc 
                                      crawepr.dtdpagto   crawepr.dtmvtolt 
                                      crapepr.vlemprst   aux_dsdavali    
                                      crapepr.dtmvtolt   aux_dtmvtolt
                                      WITH FRAME f_ctr_normal. 
           
                 DOWN WITH FRAME f_ctr_normal.
             END.
    END.

    DELETE PROCEDURE h-b1wgen0084.

     /* Se eh planilha */
    IF   glb_cddopcao = "I"   AND   aux_tpimprim   THEN
          DISPLAY STREAM str_1 aux_vltotemp WITH FRAME f_tot_planilha. 
    ELSE
          DISPLAY STREAM str_1 aux_vltotemp WITH FRAME f_tot_normal. 

    IF   aux_contador = 0   THEN
         DO:
             PUT STREAM str_1
                  "Nao foi encontrado nenhum emprestimo nessas condicoes.".
         END.

    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE.


/* ..........................................................................*/
