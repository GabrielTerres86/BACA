/* ..........................................................................

   Programa: Fontes/crps205.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/97.                       Ultima atualizacao: 27/04/2011

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 074.
               Gerar arquivo trimestral - CPMF para receita federal.
               Emite relatorio 235.

   Alteracoes: 09/06/1999 - Tratar CPMF (Deborah).

               19/07/1999 - Alterado para chamar a rotina de impressao (Edson).
               
               28/10/1999 - Tratar nova resolucao. (odair)

               18/04/2000 - Mudar nome de saida do arquivo de arq/crps205.dat
                            para /micros/XXXX/receita/cpmft99999.
                                 referencia = r            ryyyy  year
                 
               28/10/1999 - Salvo antigo como bacalhau/crpb191.p (Odair)

               20/07/2005 - Mudanca no layout do arquivo (Ze Eduardo).
               
               22/11/2005 - Mudanca no layout do arquivo (Ze Eduardo).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               12/01/2007 - Modificado layout do arquivo (Diego).
               
               14/12/2007 - Incluidos valores do INSS - BANCOOB (Evandro).
               
               27/04/2011 - Nao imprimir mais o relatorio (Magui).
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio de saida */

{ includes/var_batch.i "new" } 

{ includes/var_cpmf.i } 

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.

DEF TEMP-TABLE cratcpm                                               NO-UNDO
    FIELD inpessoa AS INT
    FIELD incpfcgc AS INT
    FIELD nrcpfcgc AS DECIMAL
    FIELD nrdconta AS INT
    FIELD intrimes AS INT
    FIELD vlbasipm AS DECIMAL
    FIELD vldoipmf AS DECIMAL
    INDEX cratcpm1 AS PRIMARY inpessoa incpfcgc.
    
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dtiniper AS DATE                                  NO-UNDO.
DEF        VAR aux_dtfimper AS DATE                                  NO-UNDO.
DEF        VAR aux_dtiniarq AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtfimarq AS CHAR                                  NO-UNDO.
DEF        VAR aux_intrimes AS INT                                   NO-UNDO.
DEF        VAR aux_cdtrimes AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_vlbasipm AS DECIMAL DECIMALS 2                    NO-UNDO.
DEF        VAR aux_vldoipmf AS DECIMAL DECIMALS 2                    NO-UNDO.

DEF        VAR tot_vlipmass AS DECIMAL  EXTENT 3                     NO-UNDO.
DEF        VAR tot_vlbasass AS DECIMAL  EXTENT 3                     NO-UNDO.

DEF        VAR ger_vlipmass AS DECIMAL  EXTENT 3                     NO-UNDO.
DEF        VAR ger_vlbasass AS DECIMAL  EXTENT 3                     NO-UNDO.

DEF        VAR sub_vlipmass AS DECIMAL  EXTENT 3                     NO-UNDO.
DEF        VAR sub_vlbasass AS DECIMAL  EXTENT 3                     NO-UNDO.


DEF        VAR aux_tppessoa AS CHAR                                  NO-UNDO.
DEF        VAR aux_inpessoa AS INT                                   NO-UNDO.
DEF        VAR aux_incpfcgc AS INT                                   NO-UNDO.
DEF        VAR set_nrcpfcgc AS DECIMAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_dstrimes AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdmesref AS INT                                   NO-UNDO.

DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.

DEF        VAR aux_nrdocnpj AS DECI                                  NO-UNDO.
DEF        VAR aux_nmextcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsendcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrendcop AS INT                                   NO-UNDO.
DEF        VAR aux_dscomple AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcxapos AS INT                                   NO-UNDO.
DEF        VAR aux_cdufdcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmbairro AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcepend AS INT                                   NO-UNDO.
DEF        VAR aux_dsdircop AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcpfcgc AS DECI                                  NO-UNDO.
DEF        VAR aux_nmtitcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmctrcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcpfctr AS DECI                                  NO-UNDO.
DEF        VAR aux_nrcpftit AS DECI                                  NO-UNDO.
DEF        VAR aux_caracter AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrtelvoz AS CHAR                                  NO-UNDO.
DEF        VAR aux_telefone AS CHAR                                  NO-UNDO.
DEF        VAR aux_dddtelef AS CHAR                                  NO-UNDO.
DEF        VAR aux_verifica AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtanoref AS INT                                   NO-UNDO.

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA",
                                             "CAPITAL",
                                             "EMPRESTIMOS",
                                             "DIGITACAO",
                                             "GENERICO"]             NO-UNDO.

FORM SKIP(15)
     "PROTOCOLO PARA GERACAO DE ARQUIVO PARA RECEITA FEDERAL REF:" AT 10      
     SKIP(1)
     aux_cdtrimes NO-LABELS FORMAT "99" AT 30
     "/TRIMESTRE DE" AT 32
     aux_dtanoref FORMAT "9999"
     SKIP(2)
     "CONFERIR NOMES:" AT 10 SKIP(1)
     "- REPRESENTANTE LEGAL:" AT 10 aux_nmtitcop  SKIP
     "- RESPONSAVEL PREENCHIMENTO:" AT 10 aux_nmctrcop
     SKIP(3)
     "ARQUIVO PARA GERAR:" AT 10
     aux_nmarquiv FORMAT "x(50)" NO-LABELS
     SKIP(6)
     "TRANSMISSAO ________/________/_________"   AT 10
     SKIP(6)
     "VISTO      ____________________________"   AT 10
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_receita.


FUNCTION f_tira_caracteres_especiais RETURN CHAR(INPUT par_nmcooper AS CHAR):

  DO  aux_contador = 1 TO LENGTH(par_nmcooper):

      IF   SUBSTR(par_nmcooper,aux_contador,1) <> ""    AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "A"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "B"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "C"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "D"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "E"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "F"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "G"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "H"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "I"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "J"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "K"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "L"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "M"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "N"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "O"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "P"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "Q"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "R"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "S"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "T"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "U"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "V"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "X"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "W"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "Y"   AND
           SUBSTR(par_nmcooper,aux_contador,1) <> "Z"   THEN
           SUBSTR(par_nmcooper,aux_contador,1) = " ". 
  END.

  RETURN par_nmcooper.

END FUNCTION.



ASSIGN glb_cdprogra = "crps205".  

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

{ includes/cabrel080_1.i } 

ASSIGN aux_dtfimper = glb_dtmvtolt - DAY(glb_dtmvtolt)  
       aux_dtiniper = aux_dtfimper - DAY(aux_dtfimper)
       aux_dtiniper = aux_dtiniper - DAY(aux_dtiniper)
       aux_dtiniper = aux_dtiniper - DAY(aux_dtiniper) + 1.

IF  MONTH(aux_dtiniper) = 1 THEN
    aux_cdtrimes = 1.
ELSE
IF  MONTH(aux_dtiniper) = 4 THEN
    aux_cdtrimes = 2.
ELSE
IF  MONTH(aux_dtiniper) = 7 THEN
    aux_cdtrimes = 3.
ELSE
IF  MONTH(aux_dtiniper) = 10 THEN
    aux_cdtrimes = 4.

aux_dstrimes = STRING(aux_cdtrimes,"9") + ". TRIMESTRE/" +
               STRING(YEAR(aux_dtiniper),"9999").

{ includes/cpmf.i } 

FOR EACH crapper WHERE crapper.cdcooper = glb_cdcooper      AND
                       crapper.indebito = 2                 AND
                       crapper.dtfimper >= aux_dtiniper     AND
                       crapper.dtfimper <= aux_dtfimper  NO-LOCK:

    aux_intrimes = MONTH(crapper.dtfimper) - MONTH(aux_dtiniper) + 1.

    FOR EACH crapipm WHERE crapipm.cdcooper = glb_cdcooper      AND
                           crapipm.indebito = 2                 AND
                           crapipm.dtdebito = crapper.dtdebito  AND
                           crapipm.inisipmf = 0                 NO-LOCK,
        /* EACH crapass OF crapipm NO-LOCK */
        EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.nrdconta = crapipm.nrdconta  NO-LOCK:

        IF   crapipm.vlbasipm <= 0 THEN
             aux_vlbasipm = crapipm.vldoipmf / tab_txcpmfcc.
        ELSE
             aux_vlbasipm = crapipm.vlbasipm.

        glb_nrcalcul = crapass.nrcpfcgc.

        RUN fontes/cpfcgc.p.

        IF   NOT glb_stsnrcal  THEN

             /* Usado somente para identificar se o cpf/cnpj esta errado */

             ASSIGN aux_inpessoa = 8                       
                    aux_incpfcgc = 8.
        ELSE 
             ASSIGN aux_inpessoa = 1
                    aux_incpfcgc = IF   crapass.inpessoa = 3 THEN
                                        2
                                   ELSE crapass.inpessoa.

        CREATE cratcpm.
        ASSIGN cratcpm.inpessoa = aux_inpessoa
               cratcpm.incpfcgc = aux_incpfcgc
               cratcpm.nrcpfcgc = crapass.nrcpfcgc
               cratcpm.nrdconta = crapipm.nrdconta
               cratcpm.intrimes = aux_intrimes
               cratcpm.vlbasipm = aux_vlbasipm
               cratcpm.vldoipmf = crapipm.vldoipmf.

    END.  /*  Fim do FOR EACH -- Leitura dos ipm  */

END. /* FIM da leitura do PER */

OUTPUT STREAM str_1 TO VALUE("salvar/cpmft" + STRING(aux_cdtrimes,"9") +
                             "." + STRING(YEAR(aux_dtiniper),"9999")). 
                             
FOR EACH crapcop WHERE crapcop.cdcooper = glb_cdcooper  NO-LOCK:
    ASSIGN aux_nmextcop = f_tira_caracteres_especiais(crapcop.nmextcop)
           aux_nrdocnpj = crapcop.nrdocnpj
           aux_dsendcop = crapcop.dsendcop
           aux_nrendcop = crapcop.nrendcop
           aux_nmbairro = crapcop.nmbairro
           aux_nmcidade = crapcop.nmcidade
           aux_cdufdcop = crapcop.cdufdcop
           aux_nrcepend = crapcop.nrcepend
           aux_dsdircop = crapcop.dsdircop
           aux_nmtitcop = crapcop.nmtitcop
           aux_nmctrcop = crapcop.nmctrcop
           aux_nrcpfctr = crapcop.nrcpfctr
           aux_nrcpftit = crapcop.nrcpftit
           aux_nrtelvoz = crapcop.nrtelvoz.
END.

/* Separa o DDD do NUMERO do telefone */
ASSIGN aux_verifica = FALSE.

DO aux_contador = 1  TO  LENGTH(aux_nrtelvoz):

   ASSIGN aux_caracter = SUBSTRING(STRING(aux_nrtelvoz),aux_contador,1).

   IF   aux_caracter = "("  OR
        aux_caracter = "-"  OR
        aux_caracter = " "  OR
        aux_caracter = "."  THEN
        NEXT.
        
   IF   aux_caracter  = ")"  THEN
        DO:
            ASSIGN aux_verifica = TRUE.
            NEXT.   
        END.
  
   IF   NOT aux_verifica  THEN     
        ASSIGN aux_dddtelef = aux_dddtelef + aux_caracter. /* DDD */
   ELSE
        ASSIGN aux_telefone = aux_telefone + aux_caracter. /* TELEFONE */ 
END.

ASSIGN aux_nmarquiv = "/micros/" + aux_dsdircop + "/receita/cpmft" +
                      STRING(aux_cdtrimes,"9") + "." +
                      STRING(YEAR(aux_dtiniper),"9999")
                      
       aux_dtanoref = YEAR(aux_dtiniper).


ASSIGN aux_dtiniarq = STRING(YEAR(aux_dtiniper),"9999") +
                      STRING(MONTH(aux_dtiniper),"99") +
                      STRING(DAY(aux_dtiniper),"99")
       aux_dtfimarq = STRING(YEAR(aux_dtfimper),"9999") +
                      STRING(MONTH(aux_dtfimper),"99") +
                      STRING(DAY(aux_dtfimper),"99").

PUT STREAM str_1
    /* registro tipo 1 */
    "000000011"   
    aux_nrdocnpj FORMAT "99999999999999"  
    aux_cdtrimes FORMAT "9"
    STRING(YEAR(aux_dtiniper),"9999") FORMAT "x(04)"
    aux_dtiniarq FORMAT "x(08)"
    aux_dtfimarq FORMAT "x(08)"
    "00000000000"
    aux_cdufdcop FORMAT "x(02)"
    aux_nmextcop FORMAT "x(60)"
    "CPMFTR"
    FILL (" ",19) FORMAT "x(19)"
    SKIP

    /* registro tipo 2 */
    "000000022"
    aux_nrcpftit          FORMAT "99999999999"
    INTEGER(aux_dddtelef) FORMAT "9999"
    INTEGER(aux_telefone) FORMAT "999999999"
    "00000"
    aux_nrcpfctr          FORMAT "99999999999"
    INTEGER(aux_dddtelef) FORMAT "9999"
    INTEGER(aux_telefone) FORMAT "999999999"
    "00000"
    FILL (" ",75) FORMAT "x(75)"
    SKIP.


/* Lancamentos do INSS - BANCOOB */
FOR EACH craplpi WHERE craplpi.cdcooper  = glb_cdcooper   AND
                       craplpi.dtmvtolt >= aux_dtiniper   AND
                       craplpi.dtmvtolt <= aux_dtfimper   NO-LOCK:
                              
    FIND crapcbi WHERE crapcbi.cdcooper = craplpi.cdcooper   AND
                       crapcbi.nrrecben = craplpi.nrrecben   AND
                       crapcbi.nrbenefi = 0
                       NO-LOCK NO-ERROR.
                              
    IF   NOT AVAILABLE crapcbi   THEN
         FIND crapcbi WHERE crapcbi.cdcooper = craplpi.cdcooper   AND
                            crapcbi.nrrecben = 0                  AND
                            crapcbi.nrbenefi = craplpi.nrbenefi
                            NO-LOCK NO-ERROR.
                                   
    /* Indicador de trimestre */
    aux_intrimes = MONTH(craplpi.dtmvtolt) - MONTH(aux_dtiniper) + 1.

    CREATE cratcpm.
    ASSIGN cratcpm.inpessoa = 1
           cratcpm.incpfcgc = 1
           cratcpm.nrcpfcgc = crapcbi.nrcpfcgc
           cratcpm.nrdconta = crapcbi.nrdconta
           cratcpm.intrimes = aux_intrimes
           cratcpm.vlbasipm = craplpi.vllanmto
           cratcpm.vldoipmf = craplpi.vldoipmf.
END.


aux_nrseqarq = 2.    

FOR EACH cratcpm NO-LOCK BREAK BY cratcpm.inpessoa 
                                  BY cratcpm.incpfcgc
                                      BY cratcpm.nrcpfcgc:
                              
    ASSIGN tot_vlbasass[cratcpm.intrimes] = tot_vlbasass[cratcpm.intrimes] +
                                            cratcpm.vlbasipm
           tot_vlipmass[cratcpm.intrimes] = tot_vlipmass[cratcpm.intrimes] +
                                            cratcpm.vldoipmf
           ger_vlbasass[cratcpm.intrimes] = ger_vlbasass[cratcpm.intrimes] +
                                            cratcpm.vlbasipm
           ger_vlipmass[cratcpm.intrimes] = ger_vlipmass[cratcpm.intrimes] +
                                            cratcpm.vldoipmf
           sub_vlbasass[cratcpm.intrimes] = sub_vlbasass[cratcpm.intrimes] +
                                            cratcpm.vlbasipm
           sub_vlipmass[cratcpm.intrimes] = sub_vlipmass[cratcpm.intrimes] +
                                            cratcpm.vldoipmf.

    IF   LAST-OF(cratcpm.nrcpfcgc)   THEN
         DO:
             CASE cratcpm.incpfcgc:
                  WHEN 1 THEN DO:
                                  ASSIGN aux_tppessoa = "F"
                                         aux_inpessoa = 3.
                              END.
                  WHEN 2 THEN DO:
                                  ASSIGN aux_tppessoa = "J"
                                         aux_inpessoa = 3.
                              END.
                  WHEN 8 THEN DO:
                                  ASSIGN aux_tppessoa = "I"
                                         aux_inpessoa = 5.
                              END.
             END CASE.                 
              
             ASSIGN aux_nrseqarq = aux_nrseqarq + 1.
              
             IF   cratcpm.inpessoa = 8 THEN
                  aux_nrcpfcgc = DECIMAL("99999999999999").
             ELSE aux_nrcpfcgc = cratcpm.nrcpfcgc.    
                   
             PUT STREAM str_1
                        aux_nrseqarq FORMAT "99999999"    
                        aux_inpessoa FORMAT "9"       /* tipo de reg */
                        aux_tppessoa FORMAT "x(01)"
                        aux_nrcpfcgc FORMAT "99999999999999".

             DO  aux_contador = 1 TO 3 :
                  
                 aux_cdmesref = MONTH(aux_dtiniper) - 1 + aux_contador.

                 IF   cratcpm.inpessoa = 8 THEN
                      PUT STREAM str_1
                            aux_cdmesref FORMAT "99"
                            SUBSTR(STRING(tot_vlbasass[aux_contador],
                            "999999999999999.99"),1,15) FORMAT "x(15)"
                            SUBSTR(STRING(tot_vlbasass[aux_contador],
                            "999999999999999.99"),17,2) FORMAT "x(02)"
                            FILL (" ",17) FORMAT "x(17)".
                 ELSE
                      PUT STREAM str_1
                            aux_cdmesref FORMAT "99"
                            SUBSTR(STRING(tot_vlbasass[aux_contador],
                            "999999999999999.99"),1,15) FORMAT "x(15)"
                            SUBSTR(STRING(tot_vlbasass[aux_contador],
                            "999999999999999.99"),17,2) FORMAT "x(02)"
                            SUBSTR(STRING(tot_vlipmass[aux_contador],
                            "999999999999999.99"),1,15) FORMAT "x(15)"
                            SUBSTR(STRING(tot_vlipmass[aux_contador],
                            "999999999999999.99"),17,2) FORMAT "x(02)".
             END.

             PUT STREAM str_1 
                        SUBSTR(STRING(aux_nrdocnpj,"99999999999999"),1,8)
                        FORMAT "x(08)"
                        "  "  SKIP.

             ASSIGN tot_vlbasass = 0
                    tot_vlipmass = 0.
         END.

   
    IF   LAST-OF(cratcpm.inpessoa)   THEN
         DO:
             aux_nrseqarq = aux_nrseqarq + 1.

             IF   cratcpm.inpessoa = 8 THEN
                  aux_inpessoa = 6.
             ELSE aux_inpessoa = 4.                         
                     
             PUT STREAM str_1 aux_nrseqarq FORMAT "99999999"     
                              aux_inpessoa FORMAT "9"       /* tipo de reg */
                              FILL (" ",15) FORMAT "x(15)".

             DO  aux_contador = 1 TO 3 :

                 aux_cdmesref = MONTH(aux_dtiniper) - 1 + aux_contador.

                 IF   cratcpm.inpessoa = 8   THEN
                      PUT STREAM str_1
                              aux_cdmesref FORMAT "99"
                              SUBSTR(STRING(sub_vlbasass[aux_contador],
                              "999999999999999.99"),1,15) FORMAT "x(15)"
                              SUBSTR(STRING(sub_vlbasass[aux_contador],
                              "999999999999999.99"),17,2) FORMAT "x(02)"
                              FILL (" ",17) FORMAT "x(17)".
                 ELSE
                      PUT STREAM str_1
                              aux_cdmesref FORMAT "99"
                              SUBSTR(STRING(sub_vlbasass[aux_contador],
                              "999999999999999.99"),1,15) FORMAT "x(15)"
                              SUBSTR(STRING(sub_vlbasass[aux_contador],
                              "999999999999999.99"),17,2) FORMAT "x(02)"
                              SUBSTR(STRING(sub_vlipmass[aux_contador],
                              "999999999999999.99"),1,15) FORMAT "x(15)"
                              SUBSTR(STRING(sub_vlipmass[aux_contador],
                              "999999999999999.99"),17,2) FORMAT "x(02)".
             END.

             PUT STREAM str_1 SUBSTR(STRING(aux_nrdocnpj,"99999999999999"),1,8)
                              FORMAT "x(08)"
                              "  "  SKIP.

             ASSIGN sub_vlbasass = 0
                    sub_vlipmass = 0.                
         END.
END.

/* colocar tipo de registro 6 zerado */

FIND FIRST cratcpm WHERE cratcpm.inpessoa = 8   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE cratcpm THEN
     DO:
         aux_nrseqarq = aux_nrseqarq + 1.

         PUT STREAM str_1 aux_nrseqarq FORMAT "99999999"     
                          "6"                             /* tipo de reg */
                          FILL (" ",15) FORMAT "x(15)".

         DO  aux_contador = 1 TO 3 :

             aux_cdmesref = MONTH(aux_dtiniper) - 1 + aux_contador.

             PUT STREAM str_1 aux_cdmesref                  FORMAT "99"
                              "00000000000000000"
                              FILL (" ",17) FORMAT "x(17)".
         END.

         PUT STREAM str_1 SUBSTR(STRING(aux_nrdocnpj,"99999999999999"),1,8)
                          FORMAT "x(08)"
                          "  "  
                          SKIP.
     END.

ASSIGN ger_vlbasass = 0
       ger_vlipmass = 0.

PUT STREAM str_1  "T"
                  FILL("9",136) FORMAT "x(136)"
                  aux_cdtrimes FORMAT "9"
                  STRING(YEAR(aux_dtiniper),"9999") FORMAT "x(04)"
                  SKIP.

OUTPUT STREAM str_1 CLOSE.

OUTPUT STREAM str_1 TO rl/crrl235.lst.

VIEW STREAM str_1  FRAME f_cabrel080_1.

DISPLAY STREAM str_1 aux_cdtrimes aux_dtanoref aux_nmarquiv
                     aux_nmtitcop aux_nmctrcop
                     WITH FRAME f_receita.

OUTPUT STREAM str_1 CLOSE.

UNIX SILENT VALUE("ux2dos salvar/cpmft" + STRING(aux_cdtrimes,"9") + "." + 
                   STRING(YEAR(aux_dtiniper),"9999") + 
                   " > " + aux_nmarquiv).
                   
glb_cdcritic = 663.
RUN fontes/critic.p.

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + " >> log/proc_batch.log").
         
UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                 glb_cdprogra + "' --> '" + glb_dscritic +
                 " " + aux_nmarquiv + 
                 " - AT.  V: __________" + 
                 " >> log/proc_batch.log").
                   
UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + " >> log/proc_batch.log").

glb_infimsol = TRUE.              
/*** Magui, sem cpmf
ASSIGN glb_nmarqimp = "rl/crrl235.lst"
       glb_nrcopias = 1
       glb_nmformul = "80col".
                                     
RUN fontes/imprim.p.
***/

RUN fontes/fimprg.p.

/* .......................................................................... */
