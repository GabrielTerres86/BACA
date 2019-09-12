/* ..........................................................................

   Programa: includes/crps460.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio       
   Data    : Janeiro/2006.                   Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Chamado pelo fontes/crps460.p
   Objetivo  : Gerar formulario de cheque pronto para impressao (crrl434
               Este trecho de codigo foi separado do fontes crps460.p para 
               com streams diferentes poder-se aproveitar as mesmas frames.
               
   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               28/09/2006 - Alteracao da denominacao de CGC para CNPJ (Julio)
               
               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).
                            
               18/04/2007 - Acerto no programa para conta com 8 digitos (Ze).
               
               30/04/2007 - Tratar cheque especial para tipos de conta BANCOOB
                            (Julio)
                            
               17/08/2007 - Pega data de abertura de conta mais antiga do
                            cooperado cadastrado na crapsfn para ser incluida 
                            no arquivo ( Elton). 
                                          
               15/08/2008 - Aceitar qualquer compe (Magui).
               
               10/02/2011 - Utilizar campo "Nome no talao" - crapttl (Diego).
               
               18/08/2011 - Alimentar campo da Data Confec. do Cheque (Ze).
               
               06/10/2011 - Incluir a data de confecção no arquivo de dados
                            (Isara - RKAM)
                            
               03/11/2011 - Acerto na impressao da data confeccao do chq (Ze).
               
               22/11/2012 - Ajsute na var. aux_dsimgcop para AltoVale (Ze).
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                            
               17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)                             
............................................................................ */

FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                   crapage.cdagenci = crapreq.cdagenci NO-LOCK NO-ERROR.

IF   crapreq.cdagenci <> aux_cdagenci THEN
     DO:
         IF   NOT AVAILABLE crapage   THEN
              ASSIGN rel_cdagenci = crapreq.cdagenci
                     rel_nmresage = FILL("*",15)
                     rel_cdcomchq = 16.
         ELSE
              ASSIGN rel_cdagenci = crapreq.cdagenci
                     rel_nmresage = crapage.nmresage
                     rel_cdcomchq = crapage.cdcomchq.

         ASSIGN rel_nrseqage = 1
                rel_qttalage = 0
                rel_qttalrej = 0
                rel_dsrelato = IF crapreq.tprequis = 2 THEN
                                  "REQUISICOES CHEQUE TB ATENDIDAS:"
                               ELSE
                                  "REQUISICOES ATENDIDAS:"
                aux_flgfirst = TRUE.

         PAGE STREAM {&rl_str}.
         DISPLAY STREAM {&rl_str} rel_cdagenci  rel_nmresage
                                  aux_nrpedido  rel_nrseqage
                                  WITH FRAME f_agencia.
     END.

ASSIGN glb_cdcritic = 0
       aux_cdagenci = crapreq.cdagenci
       aux_tpcheque = IF   crapreq.tprequis = 5  THEN
                           1
                      ELSE 2.


DO WHILE TRUE:

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                      crapass.nrdconta = crapreq.nrdconta
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   IF   NOT AVAILABLE crapass   THEN
        IF   LOCKED crapass   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 ASSIGN glb_cdcritic = 9.
                 LEAVE.
             END.

   IF   aux_tpctaini = 12  AND
        glb_cdcritic = 0   THEN
        DO:
            IF   crapass.flgctitg <> 2 THEN
                 glb_cdcritic = 837.
            ELSE
                 IF   crapass.nrdctitg = "" THEN
                      glb_cdcritic = 837.
        END.
   
   IF   glb_cdcritic = 0   THEN
        DO:
            IF   crapass.cdsitdct <> 1   THEN
                 glb_cdcritic = 64.
            ELSE
                 IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))  THEN
                      glb_cdcritic = 695.
                 ELSE
                      IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
                           glb_cdcritic = 95.
                      ELSE
                           IF   crapass.inlbacen <> 0 THEN
                                glb_cdcritic = 720.
        END.
                             
   LEAVE.
     
END. /* DO WHILE TRUE */

IF   glb_cdcritic = 0   THEN
     DO:
         IF   aux_tpctaini = 12  THEN
              aux_nrdctitg = f_ver_contaitg(crapass.nrdctitg).
         ELSE
              aux_nrdctitg = crapass.nrdconta.
              
         ASSIGN aux_qtreqtal = 1
                aux_nrflcheq = crapass.nrflcheq + 1
                rel_nrinichq = aux_nrflcheq
                aux_nrtalchq = crapass.flchqitg + 1
                aux_confecca = "Confeccao: " +
                               STRING(MONTH(glb_dtmvtolt)) + "/" + 
                               STRING(YEAR(glb_dtmvtolt)).


         /*   Calcula C1   */
         
         glb_nrcalcul = DECI(STRING(rel_cdcomchq, "999") + 
                             STRING(aux_cdbanchq, "999") +
                             STRING(aux_cdagechq, "9999") + 
                             STRING(aux_cddigage, "9")).
         RUN fontes/digfun.p.
         aux_cddigtc1 = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                       LENGTH(STRING(glb_nrcalcul)),1)).

         /*   Calcula C2   */
         
         glb_nrcalcul = INTEGER(STRING(aux_nrdctitg,"99999999") + "0").
         RUN fontes/digfun.p.
         aux_cddigtc2 = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                       LENGTH(STRING(glb_nrcalcul)),1)).
         
         IF   aux_flgfirst   THEN
              DO:
                  DISPLAY STREAM {&rl_str} rel_dsrelato WITH FRAME f_dsrelato.

                  aux_flgfirst = FALSE.
              END.
                   
          
         DO WHILE aux_qtreqtal <= crapreq.qtreqtal:
                          
            /*   Calcula Digito do Cheque   */
         
            glb_nrcalcul = (aux_nrflcheq * 10).
            RUN fontes/digfun.p.
            aux_nrdigchq = INTEGER(SUBSTR(STRING(glb_nrcalcul),
                                   LENGTH(STRING(glb_nrcalcul)),1)).
         
            /*   Calcula CMC-7 do Cheque   */

            RUN fontes/calc_cmc7_difcompe.p (INPUT  aux_cdbanchq,
                                    INPUT  crapage.cdcomchq,
                                    INPUT  aux_cdagechq,
                                    INPUT  aux_nrdctitg,
                                    INPUT  aux_nrflcheq,
                                    INPUT  aux_tpcheque,
                                    OUTPUT aux_dsdocmc7).

            CREATE crapfdc.
            ASSIGN crapfdc.nrdconta = crapass.nrdconta
                   crapfdc.nrdctabb = aux_nrdctitg
                   crapfdc.nrctachq = aux_nrdctitg
                   crapfdc.nrdctitg = IF   aux_tpctaini = 12  THEN
                                           crapass.nrdctitg
                                      ELSE ""    
                   crapfdc.nrpedido = aux_nrpedido
                   crapfdc.nrcheque = aux_nrflcheq
                   crapfdc.nrseqems = aux_nrtalchq
                   crapfdc.nrdigchq = aux_nrdigchq
                   crapfdc.tpcheque = aux_tpcheque
                   crapfdc.dtemschq = ?
                   crapfdc.dsdocmc7 = aux_dsdocmc7
                   crapfdc.cdagechq = aux_cdagechq
                   crapfdc.cdbanchq = aux_cdbanchq
                   crapfdc.cdcmpchq = rel_cdcomchq
                   crapfdc.cdcooper = glb_cdcooper
                   crapfdc.tpforchq = crapreq.tpforchq
                   crapfdc.dtconchq = glb_dtmvtolt.
            VALIDATE crapfdc.       
            ASSIGN aux_nrflcheq = aux_nrflcheq + 1
                   aux_nrtalchq = crapass.flchqitg + 1
                   aux_qtreqtal = aux_qtreqtal + 1.
            
            IF   crapreq.tprequis = 5   THEN
                 aux_qtfolhas = aux_qtfolhas + 1.
            ELSE 
                 aux_qtfolhtb = aux_qtfolhtb + 1.

         END.
         
         glb_nrcalcul = rel_nrinichq * 10.
         RUN fontes/digfun.p.
         rel_nrinichq = glb_nrcalcul.
                    /* Mirtes */
         glb_nrcalcul = (aux_nrflcheq - 1) * 10.
         RUN fontes/digfun.p.  
         rel_nrfinchq = glb_nrcalcul.

         ASSIGN rel_nrdconta = crapass.nrdconta
                rel_nrctaitg = IF   aux_tpctaini = 12  THEN
                                    STRING(crapass.nrdctitg,"9.999.999-X")
                               ELSE STRING(STRING(rel_nrdconta,"99999999"),
                                           "9.999.999-X")
                rel_nrtalchq = aux_nrtalchq
                rel_nmprimtl = crapass.nmprimtl
                rel_nmsegntl = crapass.nmsegntl
                rel_qttalage = rel_qttalage + 1
                aux_nmtitdes = IF   crapreq.tprequis = 2   THEN
                                    TRIM(crapass.nmprimtl) + " " +
                                    TRIM(crapass.nmsegntl)
                               ELSE     
                                    "".
                                    
         IF   crapreq.tprequis = 5   THEN
              ASSIGN rel_qttalger = rel_qttalger + 1.
         ELSE 
              ASSIGN rel_qtdtaltb = rel_qtdtaltb + 1.

         DISPLAY STREAM {&rl_str} rel_nrdconta   rel_nrctaitg   
                                  rel_nrtalchq   rel_nrinichq   
                                  rel_nrfinchq   rel_nmprimtl
                                  rel_nmsegntl   WITH FRAME f_talonarios.
                         
         DOWN STREAM {&rl_str} WITH FRAME f_talonarios.

         IF   LINE-COUNTER({&rl_str}) > PAGE-SIZE({&rl_str})   THEN
              DO:
                  PAGE STREAM {&rl_str}.

                  rel_nrseqage = rel_nrseqage + 1.

                  DISPLAY STREAM {&rl_str} rel_dsrelato WITH FRAME f_dsrelato.
                                    
                  DISPLAY STREAM {&rl_str}  rel_cdagenci  rel_nmresage  
                                        aux_nrpedido  rel_nrseqage
                                        WITH FRAME f_agencia.
              END.

         IF  crapass.inpessoa = 1   THEN
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx    ").
         ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
         
         ASSIGN aux_dtabtcct = ?
                aux_dtabtcc2 = ?.
                
         /* busca data na tabela do Sist. Financeiro. */
         FOR EACH crapsfn WHERE crapsfn.cdcooper = glb_cdcooper     AND
                                crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                                crapsfn.tpregist = 1                NO-LOCK
                                    BY crapsfn.dtabtcct DESCENDING:
             
             ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct.
             
         END.
         
         IF  crapass.dtabtcct <> ?               AND
             crapass.dtabtcct < crapass.dtadmiss THEN
             ASSIGN aux_dtabtcct = crapass.dtabtcct.
         ELSE
             ASSIGN aux_dtabtcct = crapass.dtadmiss.
                   
         IF  aux_dtabtcc2 <> ?  AND
             aux_dtabtcc2 < aux_dtabtcct THEN
             DO:
                 aux_dstmpcta = "Cliente Bancario desde " +
                                SUBSTR(STRING(aux_dtabtcc2,"99/99/9999"),4,7).
             END.
         ELSE
            DO:
                aux_dstmpcta =  "       Cooperado desde " +
                                SUBSTR(STRING(aux_dtabtcct,"99/99/9999"),4,7).
            END.
         

         ASSIGN aux_dschqesp = ""
                aux_tpdocptl = " "
                aux_nrdocptl = " "
                aux_cdoedptl = " "
                aux_cdufdptl = " "
                aux_dscpfcgc = IF crapass.inpessoa = 1
                                  THEN "CPF: "
                                  ELSE "CNPJ:"
                aux_nmprital = ""
                aux_nmsegtal = "".
                                          
         IF   crapage.dsinform[1] = ""  AND
              crapage.dsinform[2] = ""  AND
              crapage.dsinform[3] = ""  THEN
              ASSIGN aux_dsender1 = TRIM(STRING(crapcop.dsendcop,"x(30)"))+
                                    ", " +
                                    TRIM(STRING(crapcop.nrendcop,"zz,zz9"))
                     aux_dsender2 = TRIM(STRING(crapcop.nmbairro,"x(15)")) +
                                    " - " + 
                                    TRIM(STRING(crapcop.nmcidade,"x(25)")) +
                                    " - " + STRING(crapcop.cdufdcop,"XX")
                     aux_dsender3 = "Fone: " +
                                    TRIM(STRING(crapcop.nrtelvoz,"x(15)")).
         ELSE
              ASSIGN aux_dsender1 = STRING(crapage.dsinform[1],"x(40)")
                     aux_dsender2 = STRING(crapage.dsinform[2],"x(40)")
                     aux_dsender3 = STRING(crapage.dsinform[3],"x(40)").
        
         IF   crapass.cdtipcta =  9 OR
              crapass.cdtipcta = 11 OR
              crapass.cdtipcta = 13 OR
              crapass.cdtipcta = 15 THEN
              ASSIGN aux_dschqesp = "CHEQUE ESPECIAL".
                                     
         IF   crapass.inpessoa = 1 THEN
         DO:
              ASSIGN aux_tpdocptl = crapass.tpdocptl
                     aux_nrdocptl = crapass.nrdocptl
                     aux_cdufdptl = crapass.cdufdptl.
                     
              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

              ASSIGN aux_cdoedptl = "".
              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT crapass.idorgexp,
                                  OUTPUT aux_cdoedptl,
                                  OUTPUT glb_cdcritic, 
                                  OUTPUT glb_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.               
         END.

         IF   crapass.inpessoa = 1  THEN
              DO:
                  FIND crapttl WHERE
                       crapttl.cdcooper = glb_cdcooper      AND
                       crapttl.nrdconta = crapass.nrdconta  AND
                       crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

                  IF   AVAIL crapttl THEN
                       DO:
                           IF  crapttl.nmtalttl <> " " THEN
                               ASSIGN aux_nmprital = crapttl.nmtalttl.
                           ELSE
                               ASSIGN aux_nmprital = crapass.nmprimtl.
                       END.

                  FIND crapttl WHERE 
                       crapttl.cdcooper = glb_cdcooper      AND
                       crapttl.nrdconta = crapass.nrdconta  AND
                       crapttl.idseqttl = 2 NO-LOCK NO-ERROR.

                  IF   AVAIL crapttl THEN
                       DO:
                           IF  crapttl.nmtalttl <> " " THEN
                               ASSIGN aux_nmsegtal = crapttl.nmtalttl.
                           ELSE
                               ASSIGN aux_nmsegtal = crapass.nmsegntl.
                       END.
              END.
         ELSE
              DO:
                  FIND crapjur WHERE 
                       crapjur.cdcooper = glb_cdcooper  AND
                       crapjur.nrdconta = crapass.nrdconta
                       NO-LOCK NO-ERROR.

                  IF   AVAIL crapjur  THEN
                       DO:
                           IF  crapjur.nmtalttl <> " " THEN
                               ASSIGN aux_nmprital = crapjur.nmtalttl.
                           ELSE
                               ASSIGN aux_nmprital = crapass.nmprimtl.
                       END.

                  ASSIGN aux_nmsegtal = crapass.nmsegntl.

              END.

         
         ASSIGN aux_dsconta1 = aux_nmprital.             
                                
         IF   crapass.cdtipcta = 8    OR
              crapass.cdtipcta = 9    OR
              crapass.cdtipcta = 12   OR
              crapass.cdtipcta = 13   THEN
              ASSIGN aux_dsconta2 = aux_dscpfcgc +
                                    STRING(rel_nrcpfcgc,"x(18)") +
                                    FILL(" ",7) +
                                    STRING(rel_nrdconta,"zzzz,zzz,z")
                     aux_dsconta3 = aux_tpdocptl + " " +
                                    TRIM(aux_nrdocptl) + " " +
                                    TRIM(aux_cdoedptl) + " " +
                                    TRIM(aux_cdufdptl)
                     aux_dsconta4 = "" .
         ELSE
              ASSIGN aux_dsconta2 = STRING(aux_nmsegtal,"x(40)")
                     aux_dsconta3 = aux_dscpfcgc +
                                    STRING(rel_nrcpfcgc,"x(18)") +
                                    FILL(" ",7) +
                                    STRING(rel_nrdconta,"zzzz,zzz,z")
                     aux_dsconta4 = aux_tpdocptl + " " +
                                    TRIM(aux_nrdocptl) + " " +
                                    TRIM(aux_cdoedptl) + " " +
                                    TRIM(aux_cdufdptl).
         
         IF   crapreq.qtreqtal > 0 THEN
              DO:
                  FOR EACH crapfdc WHERE crapfdc.cdcooper = glb_cdcooper     AND
                                         crapfdc.nrdconta = crapass.nrdconta AND
                                         crapfdc.nrpedido = aux_nrpedido     AND
                                         crapfdc.tpcheque = aux_tpcheque     AND
                                         crapfdc.dtemschq = ?    EXCLUSIVE-LOCK
                                         BY crapfdc.cdcooper
                                            BY crapfdc.nrdconta
                                               BY crapfdc.nrpedido
                                                  BY crapfdc.nrcheque:
                       
                       IF   aux_tpctaini = 12  THEN
                            ASSIGN aux_dsctaitg = crapfdc.nrdctitg
                                   aux_dsctaitg = 
                                           f_tirazero(string(aux_dsctaitg, 
                                                             "9999.999-X")).
                       ELSE
                            ASSIGN aux_dsctaitg = STRING(crapass.nrdconta,
                                                         "9999,999,9")
                                   aux_dsctaitg = f_tirazero(aux_dsctaitg).
                            
                       PUT STREAM str_3
                         "001"                          /* NUM. SERIE    */
                         SKIP
                         STRING(crapfdc.nrcheque, "999,999") + "-" +
                         STRING(crapfdc.nrdigchq, "9") FORMAT "x(9)" 
                                                       /* NUM. CHEQUE    */
                         SKIP
                         crapfdc.cdcmpchq  FORMAT "999" /* COD. COMP.    */
                         SKIP
                         crapfdc.cdbanchq  FORMAT "999" /* BANCO         */
                         SKIP
                         crapfdc.cdagechq FORMAT "9999" /* AGENCIA       */
                         SKIP
                         aux_cddigage     FORMAT "9"    /* DIG. AGENCIA  */
                         SKIP
                         aux_cddigtc1     FORMAT "9"    /* C1            */
                         SKIP
                         aux_dsctaitg     FORMAT  "x(10)" /* CONTA ITG   */
                         SKIP
                         aux_cddigtc2     FORMAT "9"    /* C2            */
                         SKIP
                         "001"                          /* NUM. SERIE    */
                         SKIP
                         crapfdc.nrcheque FORMAT "999999" /* NRD. CHEQUE */
                         SKIP
                         crapfdc.nrdigchq FORMAT "9"    /* C3            */
                         SKIP
                         aux_dschqesp     FORMAT "x(15)" /* CHQ ESPECIAL */
                         SKIP
                         aux_nmtitdes     FORMAT "x(80)" /* Nome titulares */
                         SKIP
                         aux_dstmpcta     FORMAT "x(30)" /* COOPER. DESDE */
                         SKIP
                         aux_dsender1     FORMAT "x(40)" /* RUA COOP     */
                         SKIP
                         aux_dsender2     FORMAT "x(40)" /* BAIRRO / CID */
                         SKIP
                         aux_dsender3     FORMAT "x(40)" /* FONE E CEP   */
                         SKIP
                         aux_confecca     FORMAT "x(18)" /* Confecção */
                         SKIP
                         aux_dsconta1     FORMAT "x(40)" /* NOME Prim.   */
                         SKIP
                         aux_dsconta2     FORMAT "x(40)" /*2.o Tit ou Doc*/
                         SKIP
                         aux_dsconta3     FORMAT "x(40)" /* Documento   */
                         SKIP
                         aux_dsconta4     FORMAT "x(40)" /* Documento   */
                         SKIP
                         aux_dsimgcop     FORMAT "x(31)" /*Logo cooper  */
                         SKIP
                         f_cmc7(1, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(2, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(3, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(4, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(5, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(6, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(7, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(8, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(9, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(10, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(11, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(12, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(13, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(14, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(15, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(16, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(17, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(18, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(19, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(20, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(21, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(22, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(23, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(24, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(25, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(26, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP                                      
                         f_cmc7(27, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(28, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(29, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(30, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(31, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP    
                         f_cmc7(32, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(33, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP
                         f_cmc7(34, crapfdc.dsdocmc7) FORMAT "x(30)" /*CMC7*/
                         SKIP.
           
                   ASSIGN crapass.nrflcheq = crapfdc.nrcheque
                          crapass.flchqitg = crapfdc.nrseqems.
                  END.
                  
              END.                              
            
         ASSIGN crapreq.insitreq = 2.
     
     END.
ELSE
     ASSIGN crapreq.insitreq = 3
            crapreq.cdcritic = glb_cdcritic
            rel_qttalrej     = rel_qttalrej + crapreq.qtreqtal
            rel_qtrejger     = rel_qtrejger + crapreq.qtreqtal.       
            
ASSIGN crapreq.dtpedido = glb_dtmvtolt
       crapreq.nrpedido = aux_nrpedido.

IF   NOT LAST-OF(crapreq.cdagenci) THEN    /*  Le proxima requisicao  */
     NEXT.   

IF   LINE-COUNTER({&rl_str}) > 77   THEN
     DO:
         PAGE STREAM {&rl_str}.

         rel_nrseqage = rel_nrseqage + 1.

         DISPLAY STREAM {&rl_str} rel_dsrelato WITH FRAME f_dsrelato.
                     
         DISPLAY STREAM {&rl_str} rel_cdagenci  rel_nmresage  
                                  aux_nrpedido  rel_nrseqage
                                  WITH FRAME f_agencia.
     END.
ELSE
     VIEW STREAM {&rl_str} FRAME f_linha.

DISPLAY STREAM {&rl_str} rel_qttalage rel_qttalrej WITH FRAME f_qttalage.

/* .......................................................................... */
