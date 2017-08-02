/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0099.p
    Autor   : Gabriel
    Data    : Maio/2011               Ultima Atualizacao: 13/06/2017
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela DECONV.
                 
    Alteracoes: 13/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                 crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							 (Adriano - P339).	

.............................................................................*/

{ sistema/generico/includes/var_internet.i }                              
{ sistema/generico/includes/b1wgen0099tt.i }
{ sistema/generico/includes/gera_log.i     }                              
{ sistema/generico/includes/gera_erro.i    }

DEF STREAM str_1.
 
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.                         
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.


/*****************************************************************************
 Validar o convenio digitado na tela DECONV.
 Traz os titulares da conta para selecionar na tela DECONV
*****************************************************************************/
PROCEDURE valida-traz-titulares:

     DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdconven AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                          NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
     DEF OUTPUT PARAM par_nmempres AS CHAR                          NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-titulares.


     EMPTY TEMP-TABLE tt-erro.
     EMPTY TEMP-TABLE tt-titulares.

     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".

     DO WHILE TRUE:

        FIND gnconve WHERE gnconve.cdconven = par_cdconven NO-LOCK NO-ERROR.

        IF   NOT AVAIL gnconve   THEN
             DO:
                 IF   par_cdconven = 900   THEN /* Convenio nao cadastrado*/
                      DO:                           /* Mas permitido */
                          ASSIGN par_nmempres = "CARTAO BRADESCO VISA".
                      END.
                 ELSE
                      DO:
                          ASSIGN aux_dscritic = "Convenio nao Cadastrado."
                                 par_nmdcampo = "cdconven".
                          LEAVE.
                      END.
             END.
        ELSE
        IF   NOT gnconve.flgdecla   THEN
             DO:
                 ASSIGN aux_dscritic = 
                     "Convenio sem permissao para imprimir declaracao."
                        par_nmdcampo = "cdconven".
                 LEAVE.
             END.
        ELSE
        IF   NOT gnconve.flgativo   THEN
             DO:
                 ASSIGN aux_dscritic = "Convenio nao ativo."
                        par_nmdcampo = "cdconven".
                 LEAVE.
             END.
        ELSE                
             ASSIGN par_nmempres = gnconve.nmempres.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 ASSIGN aux_cdcritic = 9
                        par_nmdcampo = "nrdconta".
                 LEAVE.
             END.

        IF   crapass.dtdemiss <> ?  OR
             crapass.dtelimin <> ?  THEN
             DO:
                 ASSIGN aux_cdcritic = 64
                        par_nmdcampo = "nrdconta".
                 LEAVE.
             END.

        IF   crapass.inpessoa = 1   THEN  /* Pessoa fisica */
             DO:
                 FOR EACH crapttl NO-LOCK WHERE
                          crapttl.cdcooper = par_cdcooper   AND
                          crapttl.nrdconta = par_nrdconta:   
                               
                     CREATE tt-titulares.
                     ASSIGN tt-titulares.nrdconta = crapttl.nrdconta
                            tt-titulares.idseqttl = crapttl.idseqttl
                            tt-titulares.nmextttl = crapttl.nmextttl
                            tt-titulares.inpessoa = 1.
                 END.
             END.
        ELSE
             DO:
                 CREATE tt-titulares.
                 ASSIGN tt-titulares.nrdconta = crapass.nrdconta
                        tt-titulares.idseqttl = 1 
                        tt-titulares.nmextttl = crapass.nmprimtl
                        tt-titulares.inpessoa = 2.
             END.

        LEAVE.

     END.

     IF   aux_dscritic <> ""   OR
          aux_cdcritic <> 0    THEN
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,           
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic). 
              RETURN "NOK".
          END.
          
     RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Gerar a declaracao impressa da tela DECONV
*****************************************************************************/
PROCEDURE gera-declaracao:

     DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_idseqttl AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_cdconven AS INTE                          NO-UNDO.
     DEF  INPUT PARAM par_nmendter AS CHAR                          NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                          NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-erro.
     DEF OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
     DEF OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.

     DEF VAR rel_nmprimtl AS CHAR FORMAT "x(40)"                    NO-UNDO.
     DEF VAR rel_nrdocptl LIKE crapass.nrdocptl                     NO-UNDO.
     DEF VAR rel_identifi AS CHAR FORMAT "x(12)"                    NO-UNDO.
     DEF VAR rel_dsmvtolt AS CHAR FORMAT "x(50)"                    NO-UNDO.
     DEF VAR rel_nrcpfcgc AS CHAR FORMAT "x(18)"                    NO-UNDO.
     DEF VAR rel_nmempres AS CHAR FORMAT "x(40)"                    NO-UNDO.
     DEF VAR rel_nmempre2 LIKE gnconve.nmempres                     NO-UNDO.
     DEF VAR rel_nmassina AS CHAR FORMAT "x(40)"                    NO-UNDO.

     DEF VAR aux_dsmesref AS CHAR                                   NO-UNDO.
     DEF VAR aux_nmcidade AS CHAR                                   NO-UNDO.
     DEF VAR aux_flgtrans AS LOGI                                   NO-UNDO.  


     
     FORM SKIP(8)
          "\033\016"
          rel_nmempres  AT 06   
          SKIP(7)
          "\033\105"
          "DECLARACAO/AUTORIZACAO"   AT 19
          "\033\106" 
          SKIP(3)
          "Declaramos  a "  rel_nmempre2  " ,  que   o(a)   Sr.(a)"  "\033\105"
          SKIP(1)
          rel_nmprimtl  AT  1 "\033\106"  ",   portador   do"
          SKIP(1)                                                      
          "CPF "    rel_nrcpfcgc   "      e    do    documento       de"
          SKIP(1) 
		  "identificacao"          
          rel_nrdocptl FORMAT "x(40)" "   ," 
		  SKIP(1)
		  "e'    cooperado     da     "
		  crapcop.nmrescop FORMAT "x(13)" "\033\106" "               -"   SKIP(1)
          crapcop.nmextcop FORMAT "x(50)"
          "\033\106"        "    sob"           SKIP(1)
          "identificador " "\033\105" rel_identifi "\033\106" "."   
          SKIP(4)
     WITH NO-BOX NO-LABEL COLUMN 10 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara.

     FORM "O(a)   Sr.(a) " "\033\105" rel_nmprimtl "\033\106"           
          SKIP(1)
          "autoriza,  atraves deste  documento,  o  debito  da  fatura" 
          SKIP(1)
          "mensal da" gnconve.nmempres ", de  sua titularidade  e de"
          SKIP(1)
          "seus dependentes,  em sua conta corrente.  Da  mesma  forma"
          SKIP(1)
          "autoriza a" crapcop.nmrescop FORMAT "x(20)"
          ", na qualidade  de  filiada"     
          SKIP(1)
          "a  conveniada,  no caso de desvinculo  com  a  Cooperativa,"   
          SKIP(1)
          "encerrar  o debito  automatico da fatura de sua titularida-"   
          SKIP(1)   
          "de  e de seus dependentes."                         
          SKIP(1)
          "Em caso de insuficiencia  de fundos,  o valor das  mensali-"   
          SKIP(1)
          "dades nao sera debitado  em conta corrente."                   
          SKIP(6)
     WITH NO-BOX NO-LABEL COLUMN 10 SIDE-LABELS DOWN WIDTH 80 FRAME f_autoriza.

     FORM SKIP(8)
          "\033\105"
          "DECLARACAO" AT 35
          "\033\106" SKIP(3)
          "\033\105" "COOPERADO(A):" "\033\106" crapttl.nmextttl FORMAT "x(40)"
          ",  portador(a)  do" 
          SKIP(1)
          " CPF " rel_nrcpfcgc "Conta corrente: " crapass.nrdconta "." SKIP(3)
          "Vem pela presente informar que nesta data, ao receber o extrato, tomou conhe-"
               SKIP(1)
          "cimento  do lancamento de  um valor  em  sua conta de cartao de credito, cujo"
               SKIP(1)
          "valor nao reconhece como sendo sua despesa." SKIP(3)
          
          "Diante  do ocorrido,  veio contestar  o referido  valor e o imediato estorno/"
               SKIP(1)
          "ressarcimento do montante debitado indevidamente, cujo  valor prontamente lhe" 
               SKIP(1)
          "foi creditado, pela  Cooperativa, nesta data, em  sua conta corrente." SKIP(3)

          "Por outro lado, autoriza desde ja, de forma expressa,  que a Cooperativa, por"
               SKIP(1) 
          "ter ressarcido o valor, inicie um  processo de contestacao do credito junto a"
               SKIP(1)
          "Administradora  de  Cartoes,   para a   elucidacao  dos  fatos  e apuracao de"
               SKIP(1)
          "responsabilidades." SKIP(3)
          
          "Por final, caso seja comprovado, apos analise e verificacao da Administradora"
               SKIP(1)
          "de Cartoes,  que a despesa  seja  devida, o(a) Cooperado(a), subscritor desta"
               SKIP(1)
          "declaracao,  autoriza o  imediato  debito do  valor  e  de  eventuais  outras"
               SKIP(1)
          "despesas em conta corrente supra identificada."
          SKIP(3)
     WITH NO-BOX NO-LABEL COLUMN 06 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara2.

     FORM SKIP(8)
          "\033\105"
          "DECLARACAO" AT 31
          "\033\106" SKIP(3)
          "\033\105" "COOPERADO(A):" "\033\106" rel_nmprimtl   ",  inscrito(a)  no" 
          SKIP(1)
          " CNPJ " rel_nrcpfcgc "Conta corrente: " crapass.nrdconta "." SKIP(3)
          "Vem pela presente informar que nesta data, ao receber o extrato, tomou conhe-"
          SKIP(1)
          "cimento  do lancamento de  um valor  em  sua conta de cartao de credito, cujo" 
          SKIP(1)
          "valor nao reconhece como sendo sua despesa." SKIP(3)
          "Diante  do ocorrido,  veio contestar  o referido  valor e o imediato estorno/" 
          SKIP(1)
          "ressarcimento do montante debitado indevidamente, cujo  valor prontamente lhe" 
          SKIP(1)
          "foi creditado, pela  Cooperativa, nesta data, em  sua conta corrente." SKIP(3)
          "Por outro lado, autoriza desde ja, de forma expressa,  que a Cooperativa, por" 
          SKIP(1)
          "ter ressarcido o valor, inicie um  processo de contestacao do credito junto a" 
          SKIP(1) 
          "Administradora  de  Cartoes,   para a   elucidacao  dos  fatos  e apuracao de" 
          SKIP(1)
          "responsabilidades." SKIP(3)
          "Por final, caso seja comprovado, apos analise e verificacao da Administradora" 
          SKIP(1)
          "de Cartoes,  que a despesa  seja  devida, o(a) Cooperado(a), subscritor desta" 
          SKIP(1)
          "declaracao,  autoriza o  imediato  debito do  valor  e  de  eventuais  outras" 
          SKIP(1)
          "despesas em conta corrente supra identificada."
          SKIP(3)
     WITH NO-BOX NO-LABEL COLUMN 06 SIDE-LABELS DOWN WIDTH 80 FRAME f_declara3.

     FORM rel_dsmvtolt 
          SKIP(5)
          crapcop.nmextcop
          SKIP(5)
          rel_nmassina    SKIP
          "Conta/dv:"                                           
          crapass.nrdconta
     WITH NO-BOX NO-LABEL COLUMN 10 SIDE-LABELS DOWN WIDTH 80 FRAME f_assina.

     FORM rel_dsmvtolt 
          SKIP(5)         
          crapcop.nmextcop
          SKIP(5)
          "____________________________________________" SKIP
          rel_nmassina    SKIP
     WITH NO-BOX NO-LABEL COLUMN 6 SIDE-LABELS DOWN WIDTH 80 FRAME f_assina2.


     IF   par_flgerlog   THEN
          ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                 aux_dstransa = "Gerar a declaracao da tela DECONV.".

     ASSIGN aux_cdcritic = 0
            aux_dscritic = "".

     EMPTY TEMP-TABLE tt-erro.

     DO WHILE TRUE:

         FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

         IF   NOT AVAIL crapcop   THEN
              DO:
                  ASSIGN aux_cdcritic = 651.
                  LEAVE.
              END.

         FIND gnconve WHERE gnconve.cdconven = par_cdconven NO-LOCK NO-ERROR.

         IF   NOT AVAIL gnconve   THEN
              DO:
                 IF   par_cdconven <> 900   THEN
                      DO:
                          ASSIGN aux_cdcritic = 474.
                          LEAVE.
                      END.                 
              END.

         FIND crapass WHERE crapass.cdcooper = par_cdcooper    AND
                            crapass.nrdconta = par_nrdconta    NO-LOCK NO-ERROR.

         IF   NOT AVAIL crapass   THEN
              DO:
                  ASSIGN aux_cdcritic = 9.
                  LEAVE.
              END.

         IF   crapass.inpessoa = 1    THEN
              DO:
                  FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                     crapttl.nrdconta = par_nrdconta   AND
                                     crapttl.idseqttl = par_idseqttl  
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAIL crapttl   THEN
                       DO:
                           ASSIGN aux_cdcritic = 821.
                           LEAVE.
                       END.

                  ASSIGN rel_nrcpfcgc = STRING(crapttl.nrcpfcgc,"99999999999")                                                                   
                         rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx")                                                     
                         rel_nmprimtl = crapttl.nmextttl     
                         rel_nmassina = crapttl.nmextttl
                         rel_nrdocptl = crapttl.nrdocttl.                       
              END.
         ELSE
              DO:
                  ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                         rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx")
                         rel_nmprimtl = crapass.nmprimtl 
                         rel_nmassina = crapass.nmprimtl
                         rel_nrdocptl = crapass.nrdocptl.
              END.

         ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                               par_nmendter + "deconv.ex"
             
                aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,"    +
                               "MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO," +
                               "OUTUBRO,NOVEMBRO,DEZEMBRO"
                    
                aux_nmcidade = CAPS(TRIM(crapcop.nmcidade))
                             
                aux_nmcidade = SUBSTRING(aux_nmcidade,1,1) + 
                              LC(SUBSTRING(aux_nmcidade,2,LENGTH(aux_nmcidade)))

                rel_nmprimtl = rel_nmprimtl + " " + FILL("*",
                               40 - (LENGTH(rel_nmprimtl) + 1))
                                                       
                rel_identifi = "9" + STRING(crapcop.cdcooper,"999") +
                               STRING(crapass.nrdconta,"99999999")

                rel_dsmvtolt = (TRIM(aux_nmcidade) + ", "  + 
                               STRING(DAY(par_dtmvtolt),"99") +  " de " +
                               LC(STRING(ENTRY(MONTH(par_dtmvtolt),
                               aux_dsmesref),"x(9)")) + " de " +
                               STRING(YEAR(par_dtmvtolt),"9999") + ".").

                
         UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + 
                           par_nmendter + "deconv* 2> /dev/null").

         OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

         IF   par_cdconven <> 900   THEN
              DO:
                  ASSIGN rel_nmempres = "CONVENIO " + gnconve.nmempres +
                                        " - CECRED"
             
                         rel_nmempre2 = gnconve.nmempres.

                  DISPLAY STREAM str_1 rel_nmempres     rel_nmempre2
                                       rel_nmprimtl
                                       rel_nrcpfcgc     rel_nrdocptl
                                       crapcop.nmrescop crapcop.nmextcop
                                       rel_identifi WITH FRAME f_declara.

                  /* Verifica autorizacao do debito */
                  IF   gnconve.flgautdb   THEN 
                       DISPLAY STREAM str_1 rel_nmprimtl
                                            gnconve.nmempres 
                                            crapcop.nmrescop     
                                            rel_nmempres WITH FRAME f_autoriza.

                  DISPLAY STREAM str_1 rel_nmassina  
                                       crapcop.nmextcop
                                       crapass.nrdconta         
                                       rel_dsmvtolt 
                                       WITH FRAME f_assina.                    
              END.
         ELSE    
              DO:
                  ASSIGN rel_nmempre2 = "CARTAO BRADESCO VISA".

                  IF   crapass.inpessoa = 1   THEN
                       DO:
                           DISPLAY STREAM str_1 crapttl.nmextttl
                                                rel_nrcpfcgc    
                                                crapass.nrdconta
                                                WITH FRAME f_declara2.
                       END.
                  ELSE   
                       DO:
                           DISPLAY STREAM str_1 rel_nmprimtl 
                                                rel_nrcpfcgc    
                                                crapass.nrdconta 
                                                WITH FRAME f_declara3.
                       END.

                  DISPLAY STREAM str_1 rel_nmassina  
                                       crapcop.nmextcop
                                       rel_dsmvtolt  
                                       WITH FRAME f_assina2.
              END.

         RUN gera_arquivo_log (INPUT par_cdoperad,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT par_cdconven,
                               INPUT rel_nmempre2).

         OUTPUT STREAM str_1 CLOSE.

         IF   par_idorigem = 5   THEN /* Copiar PDF para o Ayllos Web */
              DO:
                  RUN sistema/generico/procedures/b1wgen0024.p
                      PERSISTENT SET h-b1wgen0024.

                  RUN envia-arquivo-web IN h-b1wgen0024
                                           (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_nmarqimp,
                                           OUTPUT par_nmarqpdf,
                                           OUTPUT TABLE tt-erro).     

                  DELETE PROCEDURE h-b1wgen0024.

                  IF   RETURN-VALUE <> "OK"   THEN
                       LEAVE.
              END.

         ASSIGN aux_flgtrans = TRUE.
         LEAVE.

     END. /* Fim tratamento principal */

     IF   NOT aux_flgtrans  THEN
          DO:
              IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,           
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).                 
              RETURN "NOK".         
          END.

     RETURN "OK".

 END PROCEDURE.


 /* ....................... PROCEDURES INTERNAS .............................*/

 PROCEDURE gera_arquivo_log:

    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdconven AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmempres AS CHAR                            NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")+ " "  +   
                      STRING(TIME,"HH:MM:SS") + "' --> '"               + 
                      " Operador " + par_cdoperad                       +
                      " gerou declaracao ref. " + STRING(par_cdconven)  +
                      "-"  +  par_nmempres  + " para a conta "          + 
                      STRING(par_nrdconta)  + 
                      " >> /usr/coop/" + crapcop.dsdircop + "/log/deconv.log").
END.

/* ......................................................................... */
