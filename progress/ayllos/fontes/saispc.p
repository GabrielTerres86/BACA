/* .............................................................................
   
   Programa: Fontes/saispc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2012                       Ultima Atualizacao: 03/06/2015
   
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela SAISPC, que lista os cooperados que devem ser
               retirados do SPC.
   
   Alteracoes: 03/09/2012 - Inclusao de opcao "R" para gerar relatorio em 
                            arquivo (Lucas R.)
                            
              18/10/2012 - Inclusao de mensagem quando não listar nenhum registro. 
                           (Oscar)
                           
              24/02/2014 - Adicionado param. de paginacao em proc.
                           obtem-dados-emprestimos em BO 0002.(Jorge) 
                           
              03/06/2015 - Ajustado a busca do saldo do dia chamando a 
                           pc_obtem_saldo_dia_prog
                           (Douglas - Chamado 285228 - obtem-saldo-dia)
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF STREAM str_1 .


DEF VAR aux_dtmvtolt LIKE crapspc.dtmvtolt                        NO-UNDO.
DEF VAR aux_descrica AS CHAR FORMAT "x(10)"                       NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapspc.nrcpfcgc                        NO-UNDO.
DEF VAR aux_nrdconta LIKE crapspc.nrdconta                        NO-UNDO.
DEF VAR aux_nrctafia LIKE crapspc.nrdconta                        NO-UNDO.
DEF VAR aux_nrctremp LIKE crapspc.nrctremp                        NO-UNDO.
DEF VAR aux_vldivida LIKE crapspc.vldivida                        NO-UNDO.
DEF VAR aux_desorige AS CHAR FORMAT "x(16)"                       NO-UNDO.
DEF VAR aux_desinsti AS CHAR FORMAT "x(06)"                       NO-UNDO.

DEF VAR tel_nmdireto AS CHAR FORMAT "x(20)"                       NO-UNDO.
DEF VAR tel_nmarquiv AS CHAR FORMAT "x(25)"                       NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR FORMAT "X(25)"                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                      NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                      NO-UNDO.
DEF VAR aux_fill     AS CHAR FORMAT "x(114)"                      NO-UNDO.
DEF VAR aux_nmrescop LIKE crapcop.nmrescop                        NO-UNDO.
DEF VAR aux_dsdircop LIKE crapcop.dsdircop                        NO-UNDO.
DEF VAR aux_indopcao AS INT                                       NO-UNDO.
DEF VAR aux_listouum AS LOG                                       NO-UNDO.
DEF VAR aux_vlmincon AS DECI INIT 10                              NO-UNDO.


DEF VAR tel_dsbaixad AS CHAR FORMAT "x(13)"
               VIEW-AS COMBO-BOX LIST-ITEMS "1 - Aval",
                                            "2 - Aval/Devedor",
                                            "3 - Todos"
                                            PFCOLOR 2             NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE NO-UNDO.

DEF BUFFER crabspc FOR crapspc.
DEF BUFFER crabass FOR crapass.

DEF VAR aux_ctaavali LIKE crapspc.nrdconta.

FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "Informe a opcao desejada (R,T) "
        VALIDATE(CAN-DO("R,T",glb_cddopcao), "014 - Opcao errada.")
        
    tel_dsbaixad LABEL "Situacao" AT 20
        HELP "Selecione a situacao desejada."
        WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao. 

FORM "Diretorio:   "     AT 5
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.          

FORM aux_dtmvtolt COLUMN-LABEL "Dt. Mvto"
     aux_descrica COLUMN-LABEL "Tp. Devedor"  
     aux_nrcpfcgc
     aux_nrdconta COLUMN-LABEL "Devedor"
     aux_nrctafia COLUMN-LABEL "Conta/dv"
     aux_nrctremp FORMAT "zz,zzz,zz9"
     aux_vldivida  
     aux_desorige COLUMN-LABEL "Origem"  
     aux_desinsti COLUMN-LABEL "Instituicao"
     WITH DOWN WIDTH 300 FRAME f_listagem.

FORM aux_fill WITH NO-BOX NO-UNDERLINE NO-LABELS WIDTH 300 FRAME f_prenche.


     
ON RETURN OF tel_dsbaixad DO:
   APPLY "GO".
END.

FUNCTION fnGetDescOrigem RETURN CHAR(par_cdorigem AS INT):
   
    DEF VAR aux_dsorigem AS CHAR FORMAT "x(16)" NO-UNDO.

    CASE par_cdorigem:  
        WHEN 1 THEN
            aux_dsorigem = "Conta".
        WHEN 2 THEN
            aux_dsorigem = "Desconto Cheques".
        WHEN 3 THEN
            aux_dsorigem = "Emprestimos".
        OTHERWISE
        aux_dsorigem = "".
    END CASE.
          
    RETURN aux_dsorigem.

END.

FUNCTION fnGetDesctpinsttu RETURN CHAR(par_tpinsttu AS INT):
   
    DEF VAR aux_tpinsttu AS CHAR FORMAT "x(06)" NO-UNDO.

    CASE par_tpinsttu:  
        WHEN 1 THEN
            aux_tpinsttu = "SPC".
        WHEN 2 THEN
            aux_tpinsttu = "SERASA".
        OTHERWISE
        aux_tpinsttu = "".
    END CASE.
          
    RETURN aux_tpinsttu.

END.

FUNCTION fnGetDescDevedor RETURN CHAR(par_tpidenti AS INT):

    DEF VAR aux_dsidenti AS CHAR FORMAT "x(10)" NO-UNDO.

    CASE par_tpidenti:  
        WHEN 1 THEN
            aux_dsidenti = "Devedor 1".
        WHEN 2 THEN
            aux_dsidenti = "Devedor 2".
        WHEN 3 THEN
            aux_dsidenti = "Fiador 1".
        WHEN 4 THEN
            aux_dsidenti = "Fiador 2".
        OTHERWISE
        aux_dsidenti = "".
    END CASE.
          
    RETURN aux_dsidenti.
     
END FUNCTION.

FUNCTION fnGetPodeSairSPC RETURN LOG(INPUT par_cdcooper AS INT,
                                     INPUT par_nrdconta AS INT,
                                     INPUT par_cdsitdtl AS INT,
                                     INPUT par_cdagenci AS INT,
                                     INPUT par_nrctremp AS INT,
                                     INPUT par_cdorigem AS INT,
                                     INPUT par_dtmvtolt AS DATE,
                                     INPUT par_dtmvtoan AS DATE,
                                     INPUT par_nmdatela AS CHAR,
                                     INPUT par_cdoperad AS CHAR
                                     ):


    DEF VAR aux_flgpreju AS LOG  INIT FALSE                           NO-UNDO.
    DEF VAR aux_flgeprat AS LOG  INIT FALSE                           NO-UNDO.
    DEF VAR aux_flginadi AS LOG  INIT FALSE                           NO-UNDO.
    DEF VAR aux_contador AS INT  INIT 0                               NO-UNDO.
    DEF VAR aux_qtregist AS INT                                       NO-UNDO.
       
       ASSIGN aux_flgeprat = FALSE
              aux_flginadi = FALSE 
              aux_flgpreju = CAN-DO("5,6,7,8",STRING(par_cdsitdtl)).
              
       IF NOT aux_flgpreju THEN
          DO:
               RUN obtem-dados-emprestimos IN h-b1wgen0002 
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT 0,
                                                 INPUT 1,
                                                 INPUT par_nmdatela,
                                                 INPUT 1, /* Ayllos */
                                                 INPUT par_nrdconta,
                                                 INPUT 1,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtoan,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "",
                                                 INPUT FALSE,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /* par_flgcondc */
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
        
               /* Origem(1- Conta , 3 - Emprestimos)  */
               IF  (par_cdorigem = 3) THEN
                   DO:
                       /* Verificar se o contrato em questão ainda esta em atraso devedor ou esta em prejuizo  */
                       FIND FIRST tt-dados-epr WHERE (tt-dados-epr.nrctremp = par_nrctremp)
                                                 AND ((tt-dados-epr.vlpreapg > aux_vlmincon)
                                                 OR   (tt-dados-epr.inprejuz > 0)) NO-LOCK NO-ERROR.
                       IF AVAIL tt-dados-epr THEN
                          DO:
                             ASSIGN aux_flgpreju = tt-dados-epr.inprejuz > 0. 
                             IF  (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  AND
                                 tt-dados-epr.dtdpagto < par_dtmvtolt                    THEN
                                 DO:
                                     IF  CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto)))  OR
                                         CAN-FIND(crapfer WHERE 
                                                  crapfer.cdcooper = par_cdcooper              AND 
                                                  crapfer.dtferiad = tt-dados-epr.dtdpagto)    THEN 
                                         DO:
                                             IF  tt-dados-epr.dtdpagto < par_dtmvtoan  THEN
                                                 ASSIGN aux_flgeprat = TRUE. 
                                         END.
                                      ELSE 
                                         ASSIGN aux_flgeprat = TRUE.
                                 END.
                              ELSE
                              IF  tt-dados-epr.vlpreapg > aux_vlmincon                     AND
                                  tt-dados-epr.dtdpagto <> par_dtmvtolt                    AND        
                                  (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  THEN      
                                  DO:
                                      IF  CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto)))  OR
                                          CAN-FIND(crapfer WHERE 
                                                   crapfer.cdcooper = par_cdcooper              AND
                                                   crapfer.dtferiad = tt-dados-epr.dtdpagto)    THEN 
                                          .
                                      ELSE
                                          ASSIGN aux_flgeprat = TRUE.
                                  END.     
                          END.
        
        
        
                       IF  aux_flgeprat = FALSE AND
                           aux_flgpreju = FALSE THEN 
                           DO: 
                               FOR EACH  tt-dados-epr WHERE ((tt-dados-epr.vlpreapg > aux_vlmincon)
                                                        OR   (tt-dados-epr.inprejuz > 0)) NO-LOCK:
                           
                                   FIND crawepr WHERE crawepr.cdcooper = par_cdcooper    AND 
                                                      crawepr.nrdconta = tt-dados-epr.nrdconta    AND
                                                      crawepr.nrctremp = INTEGER(tt-dados-epr.nrctremp) NO-LOCK NO-ERROR.
                                    
                                   IF  AVAIL crawepr THEN
                                       DO:
                                           aux_contador = 1.
                                            
                                           DO  aux_contador = 1 TO 10 :
                                    
                                               IF  crawepr.nrctrliq[aux_contador] > 0 THEN
                                                   DO:
                                                     IF crawepr.nrctrliq[aux_contador] = crapspc.nrctremp THEN
                                                        DO:
                                                           aux_flgpreju = tt-dados-epr.inprejuz > 0. 
                                                           IF  (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  AND
                                                                tt-dados-epr.dtdpagto < par_dtmvtolt                    THEN
                                                                DO:
                                                                  IF  CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto)))  OR
                                                                      CAN-FIND(crapfer WHERE 
                                                                               crapfer.cdcooper = par_cdcooper              AND 
                                                                               crapfer.dtferiad = tt-dados-epr.dtdpagto)    THEN 
                                                                      DO:
                                                                         IF  tt-dados-epr.dtdpagto < par_dtmvtoan  THEN
                                                                             aux_flgeprat = TRUE. 
                                                                      END.
                                                                      ELSE 
                                                                         aux_flgeprat = TRUE.
                                                                END.
                                                           ELSE
                                                              IF  tt-dados-epr.vlpreapg > aux_vlmincon                     AND
                                                                  tt-dados-epr.dtdpagto <> par_dtmvtolt                    AND        
                                                                  (tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal) >= 0.01  THEN      
                                                                  DO:
                                                                      IF  CAN-DO("1,7",STRING(WEEKDAY(tt-dados-epr.dtdpagto)))  OR
                                                                          CAN-FIND(crapfer WHERE 
                                                                                   crapfer.cdcooper = par_cdcooper              AND
                                                                                   crapfer.dtferiad = tt-dados-epr.dtdpagto)    THEN 
                                                                          .
                                                                      ELSE
                                                                          ASSIGN aux_flgeprat = TRUE.
                                                                  END.     
        
                                                           IF aux_flgeprat OR
                                                              aux_flgpreju THEN
                                                              LEAVE.
                                                        END.
                                                   END. /* IF */
                                           END. /* DO */
                                       END.
        
                                  IF aux_flgeprat OR
                                     aux_flgpreju THEN
                                     LEAVE.
                               END.
                           END.
                   END.
                ELSE
                   DO:
                       FIND FIRST tt-dados-epr WHERE ((tt-dados-epr.vlpreapg > aux_vlmincon)
                                                 OR   (tt-dados-epr.inprejuz > 0)) NO-LOCK NO-ERROR.
                       
                       IF AVAIL tt-dados-epr THEN
                          ASSIGN aux_flgpreju = tt-dados-epr.inprejuz > 0. 

                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                       /* Utilizar o tipo de busca A, para carregar do dia anterior
                         (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
                       RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                           aux_handproc = PROC-HANDLE NO-ERROR
                                                   (INPUT par_cdcooper,
                                                    INPUT 0, /* cdagenci */
                                                    INPUT 0, /* nrdcaixa */
                                                    INPUT par_cdoperad, 
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT "A", /* Tipo Busca */
                                                    OUTPUT 0,
                                                    OUTPUT "").

                       CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                       FIND FIRST wt_saldos NO-LOCK NO-ERROR.
                       IF AVAIL wt_saldos THEN
                           DO:
                               ASSIGN aux_flginadi = (wt_saldos.vlsddisp < 0)
                                                     AND (((wt_saldos.vllimcre > 0) 
                                                     AND (wt_saldos.vllimutl >= wt_saldos.vllimcre) 
                                                     AND (ABS(wt_saldos.vlsddisp) > wt_saldos.vllimcre))
                                                     OR  (wt_saldos.vllimcre = 0)).
                           END.
                   END.
       END.
       
       RETURN (aux_flginadi = FALSE AND
               aux_flgpreju = FALSE AND
               aux_flgeprat = FALSE). 

END FUNCTION.

PROCEDURE ListaRegistros:
    
    IF  crapspc.dtdbaixa <> ? THEN
         DO:
             FIND FIRST crabspc WHERE 
                        crabspc.nrdconta = crapspc.nrdconta  AND
                        crabspc.cdcooper = crapspc.cdcooper  AND
                        crabspc.nrctremp = crapspc.nrctremp  AND
                        crabspc.dtdbaixa = ?                 AND
                        crabspc.tpidenti <> 1
                        USE-INDEX crapspc1 NO-LOCK NO-ERROR.

             IF   NOT AVAIL crabspc THEN
                  NEXT.
         END.
     ELSE
         DO:
             ASSIGN aux_listouum = TRUE
                    aux_descrica = fnGetDescDevedor(crapspc.tpidenti)         
                    aux_desorige = fnGetDescOrigem(crapspc.cdorigem)       
                    aux_desinsti = fnGetDesctpinsttu(crapspc.tpinsttu)
                    aux_dtmvtolt = crapspc.dtmvtolt 
                    aux_nrcpfcgc = crapspc.nrcpfcgc
                    aux_nrdconta = crapspc.nrdconta
                    aux_nrctafia = crapass.nrdconta
                    aux_nrctremp = crapspc.nrctremp
                    aux_vldivida = crapspc.vldivida.         
             
             DISPLAY STREAM str_1 aux_fill WITH FRAME f_prenche.

             DISPLAY STREAM str_1 
                            aux_dtmvtolt 
                            aux_descrica 
                            aux_nrcpfcgc 
                            aux_nrdconta 
                            aux_nrctafia
                            aux_nrctremp FORMAT "zz,zzz,zz9"
                            aux_vldivida
                            aux_desorige
                            aux_desinsti 
                            WITH FRAME f_listagem.
            
             DOWN WITH FRAME f_listagem.            
         END.

     FOR EACH crabspc WHERE crabspc.nrdconta = crapspc.nrdconta  AND
                            crabspc.cdcooper = crapspc.cdcooper  AND
                            crabspc.nrctremp = crapspc.nrctremp  AND
                            crabspc.dtdbaixa = ?                 AND
                            crabspc.tpidenti <> 1
                            USE-INDEX crapspc1 NO-LOCK BY crabspc.tpidenti:
         
         FIND FIRST crabass WHERE crabass.cdcooper = crabspc.cdcooper AND
                                  crabass.nrcpfcgc = crabspc.nrcpfcgc
                                  NO-LOCK NO-ERROR.
         
         IF   AVAIL crabass THEN
              aux_nrctafia = crabass.nrdconta.
         ELSE
              aux_nrctafia = 0.
         
         ASSIGN aux_listouum = TRUE
                aux_descrica = fnGetDescDevedor(crabspc.tpidenti)         
                aux_desorige = fnGetDescOrigem(crabspc.cdorigem)        
                aux_desinsti = fnGetDesctpinsttu(crabspc.tpinsttu)
                aux_dtmvtolt = crabspc.dtmvtolt 
                aux_nrcpfcgc = crabspc.nrcpfcgc
                aux_nrdconta = crabspc.nrdconta
                aux_nrctremp = crabspc.nrctremp
                aux_vldivida = crabspc.vldivida.         

         DISPLAY STREAM str_1 
                        aux_dtmvtolt 
                        aux_descrica 
                        aux_nrcpfcgc 
                        aux_nrdconta 
                        aux_nrctafia
                        aux_nrctremp FORMAT "zz,zzz,zz9"
                        aux_vldivida
                        aux_desorige
                        aux_desinsti 
                        WITH FRAME f_listagem.
          
         DOWN WITH FRAME f_listagem.

     END.
END.

VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "T"
       glb_cdcritic =  0.

ASSIGN aux_fill = FILL("-", 114). 

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_opcao.
      LEAVE.

   END.

   IF   KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
        DO:
            RUN fontes/novatela.p.
        
            IF   CAPS(glb_nmdatela) <> "SAISPC"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE tel_dsbaixad WITH FRAME f_opcao.
       LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
   
   IF glb_cddopcao = "R" THEN
       DO:
           FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
       
                IF AVAIL(crapcop) THEN
                   DO:
                     ASSIGN aux_nmrescop = crapcop.nmrescop
                            aux_dsdircop = crapcop.dsdircop.
                   END.
                ELSE
                   ASSIGN aux_nmrescop = ""
                          aux_dsdircop = "".
                
                ASSIGN tel_nmdireto = "/micros/" + aux_dsdircop + "/" .
                
                DISP tel_nmdireto WITH FRAME f_diretorio.
                              
                UPDATE tel_nmarquiv WITH FRAME f_diretorio.
                
                ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.

       END.

   MESSAGE "Aguarde, carregando dados... ".

   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                         "/rl/spc" + STRING(TIME) + ".lst".

   OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv).

   RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.
   
   ASSIGN aux_listouum = FALSE
          aux_indopcao = tel_dsbaixad:LOOKUP(tel_dsbaixad:SCREEN-VALUE).      
   
   CASE aux_indopcao :
        WHEN 1 THEN
        DO:
             FOR EACH crapspc WHERE (crapspc.cdcooper = glb_cdcooper)   AND 
                                    (crapspc.dtdbaixa <> ?)             AND
                                    (crapspc.cdorigem = 1               OR 
                                     crapspc.cdorigem = 3)              AND
                                    (crapspc.tpidenti = 1)              AND 
                                    (crapspc.vldivida <> 1)              NO-LOCK,

                 FIRST crapass WHERE crapass.cdcooper = crapspc.cdcooper   AND
                                     crapass.nrdconta = crapspc.nrdconta   NO-LOCK:
                 
                 
                 IF fnGetPodeSairSPC (INPUT crapspc.cdcooper,
                                      INPUT crapspc.nrdconta,
                                      INPUT crapass.cdsitdtl,
                                      INPUT glb_cdagenci,
                                      INPUT crapspc.nrctremp,
                                      INPUT crapspc.cdorigem,
                                      INPUT glb_dtmvtolt,
                                      INPUT glb_dtmvtoan,
                                      INPUT glb_nmdatela,
                                      INPUT glb_cdoperad) THEN
                    RUN ListaRegistros.
             END.
        END.
        WHEN 2 THEN
        DO:
            FOR EACH crapspc WHERE (crapspc.cdcooper = glb_cdcooper)   AND 
                                   (crapspc.dtdbaixa = ?)              AND
                                   (crapspc.cdorigem = 1               OR 
                                    crapspc.cdorigem = 3)              AND
                                   (crapspc.tpidenti = 1)              AND 
                                   (crapspc.vldivida <> 1)              NO-LOCK,

                FIRST crapass WHERE crapass.cdcooper = crapspc.cdcooper   AND
                                    crapass.nrdconta = crapspc.nrdconta   NO-LOCK:
                
                IF fnGetPodeSairSPC(INPUT crapspc.cdcooper,
                                    INPUT crapspc.nrdconta,
                                    INPUT crapass.cdsitdtl,
                                    INPUT glb_cdagenci,
                                    INPUT crapspc.nrctremp,
                                    INPUT crapspc.cdorigem,
                                    INPUT glb_dtmvtolt,
                                    INPUT glb_dtmvtoan,
                                    INPUT glb_nmdatela,
                                    INPUT glb_cdoperad) THEN
                   RUN ListaRegistros.
            END.
        END.
        OTHERWISE
        DO:
          FOR EACH crapspc WHERE (crapspc.cdcooper = glb_cdcooper)   AND 
                                 (crapspc.cdorigem = 1               OR 
                                  crapspc.cdorigem = 3)              AND
                                 (crapspc.tpidenti = 1)              AND 
                                 (crapspc.vldivida <> 1)             
                            
                                 NO-LOCK,

            FIRST crapass WHERE crapass.cdcooper = crapspc.cdcooper   AND
                                crapass.nrdconta = crapspc.nrdconta   NO-LOCK:
            
            IF fnGetPodeSairSPC(INPUT crapspc.cdcooper,
                                INPUT crapspc.nrdconta,
                                INPUT crapass.cdsitdtl,
                                INPUT glb_cdagenci,
                                INPUT crapspc.nrctremp,
                                INPUT crapspc.cdorigem,
                                INPUT glb_dtmvtolt,
                                INPUT glb_dtmvtoan,
                                INPUT glb_nmdatela,
                                INPUT glb_cdoperad) THEN
               RUN ListaRegistros.
          END. 
       END.
   END CASE.

   IF  NOT aux_listouum  THEN
       MESSAGE "Nao foi encontrado nenhum registro para a opcao escolhida." VIEW-AS ALERT-BOX.
   
   HIDE MESSAGE NO-PAUSE.

   DELETE PROCEDURE h-b1wgen0002.
   
   OUTPUT STREAM str_1 CLOSE.

   IF glb_cddopcao = "R" THEN
       DO:
           UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + " > " + 
                       aux_nmarqimp).                      

           HIDE FRAME f_diretorio.
       END.
   ELSE                                                             
   RUN fontes/visrel.p (INPUT aux_nmarquiv).

                                                                    
   IF   aux_nmarquiv  <> ""   THEN
        UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2> /dev/null" ).

   
        
    
END. /* DO WHILE TRUE */

/* ..........................................................................*/


