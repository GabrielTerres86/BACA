/* .............................................................................

   Programa: Fontes/crps446.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2005.                     Ultima atualizacao: 04/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratar arq. de retorno BB - devolucao de cheques.
   
   Alteracoes: 23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               10/01/2006 - Correcao das mensagens para o LOG (Evandro).

               07/02/2006 - Alterado para nao imprimir relatorio para
                            Viacredi (Diego).
                               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               20/02/2006 - Acerto na mensagem arquivo processado (Evandro).

               10/04/2006 - Excluido envio de e-mail para
                            marcospaulo@cecred.coop.br (Diego).
                            
               26/04/2006 - Implementado tratamento de recusa total (Evandro).
               
               28/05/2007 - Retirado vinculacao da execucao do imprim.p
                            ao codigo da cooperativa(Guilherme).
               
               09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme)
               
               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                
               20/05/2009 - Incluido e-mail suporte.operacional@cecred.coop.br
                            para envio dos erros do COO507 (Fernando).
                            
               21/06/2010 - Alteracao tamanho SET STREAM e extensao .ret (Vitor).            
               
               20/09/2010 - Inclusao do e-mail cartoes@cecred.coop.br (Adriano).
               
               28/11/2011 - Tratado recusa parcial e codigo de processamento 
                            de remessa invalido. (Fabricio)

               31/05/2012 - Alteracao de email suporte para compe - Trf. 46725 
                           (Ze)              
                           
               28/08/2012 - Ajuste do format no campo nmrescop (Diego).
               
               28/08/2012 - Inclusão de e-mail cobranca@cecred.coop.br na rotina
                            enviar_email, exclusão de william@cecred.coop.br
                            (Lucas R.)
                  
               17/12/2012 - Envio de emails referente ao COO500 a COO599 para
                            convenios@cecred.coop.br ao inves de 
                            compe@cecred.coop.br (Tiago).
                            
               15/04/2013 - Retirado e-mail de cobranca na rotina enviar_email
                           (Daniele).    
                           
               04/08/2014 - Alteração da Nomeclatura para PA (Vanessa).                      
............................................................................. */
DEF STREAM str_1.     /*  Para relatorio  */
DEF STREAM str_2.     /*  Para arquivo de leitura  */
DEF STREAM str_3. /* arquivo anexo para enviar via email */

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEFINE TEMP-TABLE cratrej
       FIELD cdagenci  LIKE crapass.cdagenci
       FIELD nrdctitg  LIKE crapass.nrdctitg      
       FIELD nrdconta  LIKE crapass.nrdconta
       FIELD nrdocmto  AS   INTEGER   FORMAT "zzz,zzz,9"
       FIELD vllanmto  AS   DECIMAL   FORMAT "zzz,zzz,zz9.99"
       FIELD cdcritic  AS   INTEGER   FORMAT "99"
       FIELD dscritic  AS   CHAR      
       FIELD dscomand  AS   CHAR
       FIELD cdalinea  LIKE crapali.cdalinea
       INDEX cratrej_1 AS   PRIMARY nrdconta cdagenci.

DEFINE TEMP-TABLE crawarq                                          NO-UNDO
       FIELD nmarquiv  AS CHAR              
       FIELD nrsequen  AS INTEGER
       FIELD qtassoci  AS INTEGER
       INDEX crawarq1  AS PRIMARY nmarquiv nrsequen.

{ includes/var_batch.i } 
 
DEF    VARIABLE rel_nmempres AS CHAR    FORMAT "x(15)"             NO-UNDO.
DEF    VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5    NO-UNDO.
DEF    VARIABLE rel_nmresemp AS CHAR                               NO-UNDO.
DEF    VARIABLE rel_nrmodulo AS INT     FORMAT "9"                 NO-UNDO.
DEF    VARIABLE rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]            NO-UNDO.

DEF    VARIABLE aux_cdseqtab AS INT                                NO-UNDO.

DEF    VARIABLE aux_nmarquiv AS CHAR                               NO-UNDO.
DEF    VARIABLE aux_setlinha AS CHAR                               NO-UNDO.
DEF    VARIABLE aux_flgfirst AS LOGICAL                            NO-UNDO.

DEF    VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.
DEF    VARIABLE aux_contador AS INT                                NO-UNDO.
DEF    VARIABLE aux_nmarqdat AS CHAR                               NO-UNDO.
DEF    VARIABLE tot_qtdcriti AS INT                                NO-UNDO.
DEF    VARIABLE aux_flaglast AS LOGICAL                            NO-UNDO.

   /* variaveis para as criticas */
DEF    VARIABLE aux_dsprogra AS CHAR     FORMAT "x(6)"             NO-UNDO.
DEF    VARIABLE aux_tpregist AS INT                                NO-UNDO.
DEF    VARIABLE aux_cdocorre AS INT                                NO-UNDO.
DEF    VARIABLE aux_dscritic AS CHAR     FORMAT "x(50)"            NO-UNDO.

/* nome do arquivo de log */
DEF    VARIABLE aux_nmarqlog AS CHAR                               NO-UNDO.

DEF BUFFER crabtab FOR craptab.

 
 FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):
       
    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.

 END. /* FUNCTION */

ASSIGN glb_cdprogra = "crps446"
       glb_flgbatch = FALSE
       aux_dsprogra = "COO407"
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

/*FOR EACH crawarq:
    DELETE crawarq.
END.*/
EMPTY TEMP-TABLE crawarq.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/compel/recepcao/COO507*.ret"
       aux_flgfirst = TRUE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/coo507" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            STRING(aux_contador,"999").

   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.
      
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
 
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,040,05)) /* Quoter*/
          crawarq.nmarquiv = aux_nmarqdat
          aux_flgfirst     = FALSE.

   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO507 - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 507 NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.    

/* sequencia de rotorno esperada */
ASSIGN aux_cdseqtab = INTEGER(SUBSTR(craptab.dstextab,01,05)).
  

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper  AND
                   crabtab.nmsistem = "CRED"        AND
                   crabtab.tptabela = "GENERI"      AND
                   crabtab.cdempres = 00            AND
                   crabtab.cdacesso = "NRARQMVITG"  AND
                   crabtab.tpregist = 407           NO-ERROR NO-WAIT.

IF   NOT AVAILABLE crabtab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RUN fontes/fimprg.p.
         RETURN.
     END.    

/* pre-filtragem dos arquivos */
FOR EACH crawarq BREAK BY crawarq.nrsequen:

    IF   LAST-OF(crawarq.nrsequen)   THEN
         DO:
            IF   crawarq.nrsequen = aux_cdseqtab   THEN
                 ASSIGN aux_cdseqtab = aux_cdseqtab + 1.
            ELSE
                 DO:
                     /* sequencia errada */
                     glb_cdcritic = 476.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - COO507 - " + glb_cdprogra + 
                                       "' --> '"  +
                                       glb_dscritic + " " +
                                       "SEQ.BB " + STRING(crawarq.nrsequen) + 
                                       " " + "SEQ.COOP " + 
                                       STRING(aux_cdseqtab) + " - " +
                                       crawarq.nmarquiv +
                                       " >> " + aux_nmarqlog).
                     ASSIGN glb_cdcritic = 0
                            aux_nmarquiv = "integra/err" +
                                           SUBSTR(crawarq.nmarquiv,12,29).

                     /* move o arquivo para o /integra */
                     UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                                       aux_nmarquiv).

                     /* Apaga o arquivo QUOTER */
                     UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                                       ".q 2> /dev/null").
                                       
                     /* E-mail para CENTRAL avisando sobre a ERRO DE SEQ. */
                     
                     /* criar arquivo anexo para email */
                     ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra + 
                                           "_ANEXO" + STRING(TIME).
                     OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).
    
                     PUT STREAM str_3 "ERRO DE SEQUENCIA no arquivo "
                                      "COO507 da cooperativa "
                                      crapcop.nmrescop FORMAT "X(20)" 
                                      " / DIA: "
                                      STRING(glb_dtmvtolt,"99/99/9999")
                                      SKIP.
                                     
                     OUTPUT STREAM str_3 CLOSE.
              
                     /* Move para diretorio converte para utilizar na BO */
                     UNIX SILENT VALUE
                          ("cp " + aux_nmarqimp + " /usr/coop/" +
                           crapcop.dsdircop + "/converte" +
                           " 2> /dev/null").
                     
                     /* envio de email */ 
                     RUN sistema/generico/procedures/b1wgen0011.p
                         PERSISTENT SET b1wgen0011.
          
                         RUN enviar_email IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "convenios@cecred.coop.br," +  
                                         "cartoes@cecred.coop.br",
                                   INPUT '"ERRO DE SEQUENCIA - "' +
                                         '"COO507 - "' +
                                         crapcop.nmrescop,
                                   INPUT SUBSTRING(aux_nmarqimp, 5),
                                   INPUT FALSE).

                     DELETE PROCEDURE b1wgen0011.

                     /* remover arquivo criado de anexo */
                     UNIX SILENT VALUE("rm " + aux_nmarqimp +
                                       " 2>/dev/null").

                     DELETE crawarq.    
                     NEXT.
                 END.
         END. 
END.

/* processar os arquivos que ja foram pre-filtrados */
FOR EACH crawarq BREAK BY crawarq.nrsequen
                         BY crawarq.nmarquiv:  

    IF   LAST-OF(crawarq.nrsequen)   THEN
         aux_flaglast = YES.
    ELSE
         aux_flaglast = NO.
    
    RUN proc_processa_arquivo.
    
    IF   glb_cdcritic = 0   THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO507 - " + glb_cdprogra + "' --> '"  +
                           "ARQUIVO PROCESSADO COM SUCESSO - " +
                           SUBSTRING(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1) +
                           " >> " + aux_nmarqlog).
END.    

RUN p_imprime_rejeitados.           /*  Imprime Relatorio com Criticas  */

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE proc_processa_arquivo:

   DEF  VAR aux_qtregist AS INTEGER       INIT   0                NO-UNDO.
   DEF  VAR aux_nrdctitg AS INTEGER       FORMAT "9999999"        NO-UNDO.
                   
   DEF  VAR arq_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.
   DEF  VAR arq_nrcheque AS INTEGER                               NO-UNDO.
   DEF  VAR arq_vlcheque AS DECIMAL                               NO-UNDO.
   DEF  VAR arq_cdmotivo AS INT                                   NO-UNDO.
   DEF  VAR arq_cdcomand AS INT                                   NO-UNDO. 
   
   INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv) NO-ECHO.
   
   glb_cdcritic = 0.

   /*   Header do Arquivo   */
    
   IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
                     
   IF   SUBSTR(aux_setlinha,01,05) <> "00000" THEN
        glb_cdcritic = 468.
   
   IF   INTEGER(SUBSTR(aux_setlinha,06,04)) <> crapcop.cdageitg THEN
        glb_cdcritic = 134.

   IF   INTEGER(SUBSTR(aux_setlinha,10,08)) <> crapcop.nrctaitg THEN
        glb_cdcritic = 127.
   
   IF   INTEGER(SUBSTR(aux_setlinha,52,09)) <> crapcop.cdcnvitg THEN
        glb_cdcritic = 563.
    
   IF   glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_2 CLOSE.
            RUN fontes/critic.p.
            aux_nmarquiv = "integra/err" + SUBSTR(crawarq.nmarquiv,12,29).
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - COO507 - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
            RETURN.
        END.
        
        
   IF   INTEGER(SUBSTR(aux_setlinha,76,03)) <> 1 THEN /*  Processado */
        DO:
            ASSIGN aux_cdocorre = INTEGER(SUBSTR(aux_setlinha,76,03)).
            
            /*   Recusa Total do Arquivo  */
            IF   aux_cdocorre = 2   OR
                 aux_cdocorre = 3   OR
                 aux_cdocorre = 5   OR
                 aux_cdocorre = 6   OR
                 aux_cdocorre = 8   THEN
                RUN p_recusa(INPUT "RECUSA TOTAL").
            ELSE
            IF aux_cdocorre = 4 THEN /* Recusa parcial */
                RUN p_recusa(INPUT "RECUSA PARCIAL").
            ELSE
                RUN p_recusa
                        (INPUT "Codigo de Processamento de Remessa Invalido").
                 
            RETURN.
        END.         /*   Fim  da  Recusa  */

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
      IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

      ASSIGN glb_cdcritic = 0
             aux_qtregist = aux_qtregist + 1.
      
      /*  Verifica se eh final do Arquivo  */
      
      IF   INTEGER(SUBSTR(aux_setlinha,01,05)) = 99999 THEN
           DO:
                /*   Conferir o total do arquivo   */

                IF   (aux_qtregist + 1) <> 
                     DECIMAL(SUBSTR(aux_setlinha,06,09)) THEN
                     DO:
                         ASSIGN glb_cdcritic = 504
                                aux_nmarquiv = "integra/err" +
                                               SUBSTR(crawarq.nmarquiv,12,29).
                         
                         RUN fontes/critic.p.
                         INPUT STREAM str_2 CLOSE.
                         UNIX SILENT VALUE("rm " + crawarq.nmarquiv +
                                           ".q 2> /dev/null").
                         UNIX SILENT VALUE("mv " + crawarq.nmarquiv +
                                           " " + aux_nmarquiv).
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - COO507 - " + glb_cdprogra + 
                                           "' --> '" +
                                           glb_dscritic + 
                                           " - ARQUIVO PROCESSADO - " +
                                           aux_nmarquiv +
                                           " >> " + aux_nmarqlog).
                     END.

                LEAVE.
           END.

      /* se ocorreu erro no registro */
      IF   INTEGER(SUBSTRING(aux_setlinha,76,03)) <> 0   THEN
           DO:
      
              ASSIGN arq_nrdctitg = SUBSTR(aux_setlinha,13,07) + 
                                    SUBSTR(aux_setlinha,20,01)
                     arq_cdcomand = INT(SUBSTR(aux_setlinha,21,2))
                     arq_nrcheque = INT(SUBSTR(aux_setlinha,23,06)) * 10
                     arq_vlcheque = DEC(SUBSTR(aux_setlinha,29,17)) / 100.
      
              /* calcula o digito do cheque */
              glb_nrcalcul = arq_nrcheque.
              RUN fontes/digfun.p.
              arq_nrcheque = glb_nrcalcul.              

              FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                 crapass.nrdctitg = arq_nrdctitg  
                                 NO-LOCK NO-ERROR.
      
              CREATE cratrej.
              ASSIGN cratrej.cdagenci = crapass.cdagenci  WHEN AVAIL crapass
                     cratrej.nrdctitg = arq_nrdctitg     
                     cratrej.nrdconta = crapass.nrdconta  WHEN AVAIL crapass
                     cratrej.nrdocmto = arq_nrcheque 
                     cratrej.vllanmto = arq_vlcheque
                     cratrej.cdalinea = INT(SUBSTR(aux_setlinha,46,4))
                     cratrej.cdcritic = INT(SUBSTR(aux_setlinha,76,3))
                     cratrej.dscomand = IF arq_cdcomand = 1 THEN
                                           STRING(arq_cdcomand,"z9") +
                                           "-Inclusao"
                                        ELSE
                                           STRING(arq_cdcomand,"z9") +
                                           "-Exclusao".

              IF   cratrej.cdcritic = 999   THEN
                   cratrej.dscritic = SUBSTR(aux_setlinha,72,32).
              ELSE
                   DO:
                       ASSIGN aux_tpregist = 1
                              aux_cdocorre = cratrej.cdcritic.
                       
                       { includes/criticas_coo.i }
                       
                       cratrej.dscritic = aux_dscritic.
                   END.
              
              ASSIGN tot_qtdcriti = tot_qtdcriti + 1.

           END.     

   END.  /*   Fim  do DO WHILE TRUE  */

   INPUT STREAM str_2 CLOSE.

   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").

   /* Apaga o arquivo QUOTER */
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
    
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

       /*   Atualiza a sequencia da remessa  */
               
       DO WHILE TRUE:

          FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                             craptab.nmsistem = "CRED"        AND
                             craptab.tptabela = "GENERI"      AND
                             craptab.cdempres = 00            AND
                             craptab.cdacesso = "NRARQMVITG"  AND
                             craptab.tpregist = 507
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craptab   THEN
               IF   LOCKED craptab   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 55.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> " + aux_nmarqlog).
                        LEAVE.
                    END.    
          ELSE
               glb_cdcritic = 0.

          LEAVE.
       
       END.  /*  Fim do DO .. TO  */

       IF   glb_cdcritic > 0 THEN
            RETURN.

       IF   aux_flaglast = YES   THEN   /* e eh o ultimo da sequencia */
            ASSIGN SUBSTRING(craptab.dstextab,1,5) = 
                             STRING(crawarq.nrsequen + 1,"99999").

   END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE p_imprime_rejeitados:
   
   DEFINE VARIABLE rel_dsagenci AS CHAR       FORMAT "x(21)"          NO-UNDO.
   DEFINE VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.
   DEFINE VARIABLE aux_dtmvtopr AS DATE                               NO-UNDO.
   DEFINE VARIABLE aux_dscritic AS CHAR       FORMAT "x(65)"          NO-UNDO.

   FORM rel_dsagenci AT  1 FORMAT "x(21)" LABEL "AGENCIA"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_agencia.

   FORM cratrej.cdagenci AT 01 FORMAT "zz9"            LABEL "PA" 
        cratrej.nrdconta AT 06 FORMAT "zzz,zzz,9"      LABEL "CONTA/DV"
        cratrej.nrdctitg AT 17 FORMAT "9.999.999-X"    LABEL "CONTA ITG."
        cratrej.nrdocmto AT 30 FORMAT "zzz,zzz,9"      LABEL "CHEQUE"
        cratrej.vllanmto AT 41 FORMAT "zzz,zzz,zz9.99" LABEL "VALOR"
        cratrej.dscomand AT 57 FORMAT "x(11)"          LABEL "COMANDO"
        cratrej.cdalinea AT 70 FORMAT "zzz9"           LABEL "ALI"
        aux_dscritic     AT 76 FORMAT "x(56)"          LABEL "MOTIVO DA CRITICA"
        WITH NO-BOX NO-LABELS DOWN  WIDTH 132 FRAME f_descricao.

   FORM SKIP(1)
        "TOTAL  DE  REJEITADOS ==>"    AT  30
        tot_qtdcriti                   AT  57 FORMAT "zzz,zz9"
        SKIP(2)
        WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_age.

   { includes/cabrel132_1.i }  /*  Monta cabecalho do relatorio  */

   ASSIGN aux_nmarqimp = "rl/crrl420_" + STRING(TIME) + ".lst".
          
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             
   VIEW STREAM str_1 FRAME f_cabrel132_1.

   FOR EACH cratrej BY cratrej.cdagenci
                      BY cratrej.nrdconta
                        BY cratrej.nrdocmto:
   
       ASSIGN aux_dscritic = STRING(cratrej.cdcritic) + "-" + cratrej.dscritic.
            
       DISPLAY STREAM str_1 cratrej.cdagenci  cratrej.nrdconta  
                            cratrej.nrdctitg  cratrej.nrdocmto
                            cratrej.vllanmto  cratrej.dscomand
                            cratrej.cdalinea  aux_dscritic
                            WITH FRAME f_descricao.

       DOWN STREAM str_1 WITH FRAME f_descricao.
 
       IF   LINE-COUNTER(str_1) >= 83   THEN
            PAGE STREAM str_1.
       
   END.           /*   Fim  do  For Each   */
   
   DISPLAY STREAM str_1 tot_qtdcriti WITH FRAME f_total_age.

   OUTPUT STREAM str_1 CLOSE.
   
   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqimp.
   
   RUN fontes/imprim.p.                   
                   
END.   /*  fim da PROCEDURE  */


PROCEDURE p_recusa:

    DEF INPUT PARAM par_tprecusa AS CHAR NO-UNDO.

    /* Bloquear tabela de envio */
    ASSIGN SUBSTRING(crabtab.dstextab,1,7) = SUBSTR(aux_setlinha,39,05) + " 1".
    
    /* Deixar sequencia que estou processando arq.recebimento */
    ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(crawarq.nrsequen,"99999"). 
               
    /* E-mail para CENTRAL avisando sobre a RECUSA */

    /* criar arquivo anexo para email */
    ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra + 
                          "_ANEXO" + STRING(TIME).
    OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).
    
    PUT STREAM str_3 par_tprecusa '" no arquivo COO507 da cooperativa "'
                     crapcop.nmrescop FORMAT "X(20)"  " / DIA: "
                     STRING(glb_dtmvtolt,"99/99/9999")
                     SKIP.
                                     
    OUTPUT STREAM str_3 CLOSE.
              
    /* Move para diretorio converte para utilizar na BO */
    UNIX SILENT VALUE
               ("cp " + aux_nmarqimp + " /usr/coop/" +
                crapcop.dsdircop + "/converte" +
                " 2> /dev/null").
                     
    /* envio de email */ 
    RUN sistema/generico/procedures/b1wgen0011.p
        PERSISTENT SET b1wgen0011.
          
    RUN enviar_email IN b1wgen0011
                       (INPUT glb_cdcooper,
                        INPUT glb_cdprogra,
                        INPUT "convenios@cecred.coop.br," +
                              "cartoes@cecred.coop.br",
                        INPUT par_tprecusa + '" - COO507 - "' +
                              crapcop.nmrescop,
                        INPUT SUBSTRING(aux_nmarqimp, 5),
                        INPUT FALSE).
                                 
    DELETE PROCEDURE b1wgen0011.

    /* remover arquivo criado de anexo */
    UNIX SILENT VALUE("rm " + aux_nmarqimp +
                      " 2>/dev/null").


    INPUT STREAM str_1 CLOSE.
            
    aux_nmarquiv = "integra/err" + SUBSTR(crawarq.nmarquiv,12,29).
            
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
    
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).

    IF   glb_cdcritic <> 0 THEN
    DO:
        RUN fontes/critic.p.
                 
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - COO507 - " + glb_cdprogra + 
                          "' --> '" +
                          glb_dscritic + " - " + 
                          par_tprecusa + " - " +
                           /*crawarq.nmarquiv +*/
                          aux_nmarquiv +
                          " >> " + aux_nmarqlog).
    END.
    ELSE
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - COO507 - " + glb_cdprogra + 
                          "' --> '" +
                          par_tprecusa + " - " +
                           /*crawarq.nmarquiv + */
                          aux_nmarquiv +
                          " >> " + aux_nmarqlog).
                     
        glb_cdcritic = 182.
    END.
                      
END.   /*   Fim da Procedure  */

/* ......................................................................... */

