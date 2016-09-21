/* ............................................................................

   Programa: fontes/crps443.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2005                   Ultima atualizacao: 24/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivo com COMANDOS DE CHEQUES (COO406) - Contra-Ordens
               Emite relatorio crrl383.

   Alteracoes: 01/07/2005 - Alimentado campo cdcooper da tabela crapeca (Diego).

               29/07/2005 - Alterada mensagem Log referente critica 847 (Diego).
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               13/10/2005 - Alterado para nao imprimir relatorio para
                            Viacredi (Diego).

               23/12/2005 - Efetuado acerto formato cheque(Mirtes).
               
               10/01/2006 - Correcao das mensagens para o LOG (Evandro).
               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               01/03/2007 - Incluido campo cdbanchq na leitura da tabela 
                            crapcch, e substituido campo crapcch.flgstlcm por
                            crapcch.tpopelcm (Diego).

               14/03/2008 - Incluida coluna tipo de operacao no cheque
                            (Gabriel). 
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               24/01/2014 - Incluir VALIDATE crapeca (Lucas R.) 
............................................................................ */
{ includes/var_batch.i }

DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(70)"                 NO-UNDO.

DEF     VAR aux_cdcomand AS INT                                      NO-UNDO.
DEF     VAR aux_motctror AS CHAR      FORMAT "x(2)"                  NO-UNDO.
DEF     VAR aux_nrchqini AS INT                                      NO-UNDO.
DEF     VAR aux_nrchqfim AS INT                                      NO-UNDO.
DEF     VAR aux_maxcon   AS INT                                      NO-UNDO.
DEF     VAR aux_nrdconta LIKE crapcch.nrdconta                       NO-UNDO.
DEF     VAR aux_tpopelcm AS CHAR     FORMAT "x(37)"                  NO-UNDO.

/* variaveis para conta de integracao */
DEF BUFFER crabass5 FOR crapass.
DEF     VAR aux_nrctaass AS INT       FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF     VAR aux_ctpsqitg LIKE craplcm.nrdctabb                       NO-UNDO.
DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.
DEF     VAR aux_nrdigitg AS CHAR                                     NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

/* nome do arquivo de log */
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.

/* para os que foram enviados */
DEF TEMP-TABLE w_enviados
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmprimtl   AS CHAR FORMAT "x(37)"
    FIELD nrchqini   AS INTE FORMAT "zzzzzz9"
    FIELD nrchqfim   AS INTE FORMAT "zzzzzz9"
    FIELD tpopelcm   AS CHAR FORMAT "x(37)"
    INDEX w_enviados1
          cdagenci
          nrdconta.
          
FORM w_enviados.nrdconta   AT    5  LABEL "Conta/DV"
     w_enviados.nrdctitg   AT   16  LABEL "Conta Itg"
     w_enviados.nmprimtl   AT   28  LABEL "Nome"
     w_enviados.nrchqini   AT   66  LABEL "Cheque Inicial"
     w_enviados.nrchqfim   AT   81  LABEL "Cheque Final"
     w_enviados.tpopelcm   AT   94  LABEL "Operacao"
     WITH DOWN NO-LABELS WIDTH 132  FRAME f_enviados.

ASSIGN glb_cdprogra = "crps443"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 406           NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.    
ELSE
     IF   INTEGER(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
          DO:
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - COO406 - " + glb_cdprogra + "' --> '"  +
                                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                                " >> " + aux_nmarqlog).
              RUN fontes/fimprg.p.
              RETURN.
          END.
     
{ includes/proc_conta_integracao.i }

RUN abre_arquivo.

FOR EACH crapcch WHERE crapcch.cdcooper = glb_cdcooper AND
                       crapcch.flgctitg = 0            AND
                       crapcch.cdbanchq = 1   BY crapcch.cdhistor
              /* 1o Inclusao, depois Exclusao*/ BY crapcch.tpopelcm 
                                                  BY crapcch.nrdconta:

    /* Limpa os erros do associado */
    FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper     AND
                           crapeca.tparquiv = 506              AND
                           crapeca.nrdconta = crapcch.nrdconta EXCLUSIVE-LOCK:
        DELETE crapeca.
    END.
    
    ASSIGN aux_ctpsqitg = crapcch.nrdctabb.
    RUN existe_conta_integracao.

    IF   aux_nrdctitg = ""   THEN
         DO:
            ASSIGN crapcch.flgctitg = 4.  /* reprocessar */

            CREATE crapeca.
            ASSIGN crapeca.nrdconta = crapcch.nrdconta
                   crapeca.tparquiv = 506
                   crapeca.dscritic = "Associado nao possui C/C INTEGRACAO"
                   crapeca.cdcooper = glb_cdcooper.
            VALIDATE crapeca.
            NEXT.
         END.
    
    /* inicial e final do intervalo de cheques - sem digito */
    ASSIGN aux_nrchqini = INTEGER(SUBSTRING(STRING(crapcch.nrchqini,"9999999")
                                            ,1,6))
           aux_nrchqfim = INTEGER(SUBSTRING(STRING(crapcch.nrchqfim,"9999999")
                                            ,1,6)).

    /* codigo de comando*/
                                      /* 1 = Inclusao do registro no BB*/
    IF   crapcch.cdhistor = 2   AND   
         crapcch.tpopelcm = "1"  THEN
         aux_cdcomand = 2.
    ELSE
    IF   crapcch.cdhistor = 0   THEN
         aux_cdcomand = 9.
    ELSE                              /* 2 = Exclusao do registro no BB*/
    IF   crapcch.cdhistor = 2   AND   crapcch.tpopelcm = "2"  THEN
         aux_cdcomand = 8.
    ELSE                        /* CONTRA-ORDENS */
         DO:
             /* INCLUSAO de contra-ordens NO BB */
             IF   crapcch.tpopelcm = "1"  THEN
                  DO:
                     IF   crapcch.cdhistor = 818   OR
                          crapcch.cdhistor = 835   THEN
                          DO:
                              aux_cdcomand = 5.  /* com ocorrencia policial */
                              aux_motctror = "J".
                          END.
                     ELSE 
                          DO:
                              aux_cdcomand = 6.  /* sem ocorrencia policial */
             
                              IF   crapcch.cdhistor = 800   OR
                                   crapcch.cdhistor = 810   THEN
                                   aux_motctror = "P".  /*perdido/roubado sem 
                                                          ocorrencia policial*/
                              ELSE
                                   aux_motctror = "A".
                          END.
                  END.  /* fim da inclusao */
             ELSE
             IF   crapcch.tpopelcm = "2"  THEN
                  /* EXCLUSAO de contra-ordens NO BB */
                  ASSIGN aux_cdcomand = 7
                         aux_motctror = "".

         END.    

    ASSIGN aux_nrdconta = crapcch.nrdconta.
           
    CASE aux_cdcomand:
        
        WHEN 2 THEN aux_tpopelcm = "Baixado".
        WHEN 4 THEN aux_tpopelcm = "Liquidado".
        WHEN 5 THEN aux_tpopelcm = "Contra-ordem com ocorrencia policial".     
        WHEN 6 THEN aux_tpopelcm = "Contra-ordem sem ocorrencia policial".
        WHEN 7 THEN aux_tpopelcm = "Baixa de contra-ordem".
        WHEN 8 THEN aux_tpopelcm = "Cadastrar cheque baixado ou liquidado".
        WHEN 9 THEN aux_tpopelcm = "Cadastrar cheque confeccionado".
    
    END.
    
    RUN registro.
    
    /* atualiza flag (flgctitg) da crapcch para enviada(1) */
    ASSIGN crapcch.flgctitg = 1.

END.

RUN fecha_arquivo.

RUN rel_enviados. /* relatorio de enviados */

RUN fontes/fimprg.p.                   

PROCEDURE abre_arquivo:
     
   ASSIGN aux_nrtextab = INT(SUBSTRING(craptab.dstextab,1,5))
          aux_nmarqimp = "coo406" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0.
       
   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

   /* header */
   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") + 
                         STRING(crapcop.nrctaitg,"99999999") + 
                         "COO406  " + 
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999").
                         /* o restante sao brancos */
                      
   PUT STREAM str_1  aux_dsdlinha SKIP.

END PROCEDURE.

PROCEDURE fecha_arquivo:

   /* trailer */
                         /* total de registros + header + trailer */
   ASSIGN aux_nrregist = aux_nrregist + 2
          aux_dsdlinha = "9999999"  +
                         STRING(aux_nrregist,"9999999999").
                         /* o restante sao brancos */
                         
   PUT STREAM str_1 aux_dsdlinha.

   OUTPUT STREAM str_1 CLOSE.

   /* verifica se o arquivo gerado nao tem registros "detalhe", ai elimina-o */
   IF   aux_nrregist <= 2   THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.        
        END.

   /* mensagem no log, para enviar o arquivo */
   glb_cdcritic = 847.
   RUN fontes/critic.p.
            
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO406 - " + glb_cdprogra + "' --> '" + glb_dscritic +                       " - " + aux_nmarqimp + " >> " + aux_nmarqlog).

   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                     ' | tr -d "\032"' +  
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").

   UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 

   /* atualizacao da craptab */
   ASSIGN aux_nrtextab = aux_nrtextab + 1.
   ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab,"99999").
   ASSIGN aux_maxcon = 0.

END PROCEDURE.

PROCEDURE registro:

    IF  aux_maxcon >   9988  THEN  /* Maximo 9990 */
        DO:
           RUN fecha_arquivo.
           RUN abre_arquivo.
        END.
    
    /* registro (tipo unico) */             
    ASSIGN aux_maxcon   = aux_maxcon + 1.
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(aux_nrregist,"9999999") +
                          STRING(SUBSTRING(aux_nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(aux_nrdctitg,8,1),"x(1)") +
                          STRING(aux_nrchqini,"999999")              +
                          STRING(aux_nrchqfim,"999999")              +
                          STRING(aux_cdcomand,"99")                  +
                          STRING(aux_motctror,"x(2)")                +
                          STRING(aux_nrdconta,"99999999").
                          /* o restante sao brancos */

    PUT STREAM str_1  aux_dsdlinha SKIP.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = aux_nrdconta NO-LOCK NO-ERROR.
    
    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = aux_nrdconta
           w_enviados.nrdctitg = crapass.nrdctitg
           w_enviados.nmprimtl = crapass.nmprimtl
           w_enviados.nrchqini = aux_nrchqini
           w_enviados.nrchqfim = aux_nrchqfim
           w_enviados.tpopelcm = aux_tpopelcm.

END PROCEDURE.

PROCEDURE rel_enviados:

    ASSIGN aux_nmarqrel = "rl/crrl383_" + STRING(TIME) + ".lst".

    { includes/cabrel132_1.i }  /* Monta o cabecalho */
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
       
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.cdagenci    
                                        BY w_enviados.nrdconta:

        IF   FIRST-OF(w_enviados.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                    crapage.cdagenci = w_enviados.cdagenci
                                    NO-LOCK NO-ERROR.
                                
                 PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
    
        DISPLAY STREAM str_1
                w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.nrdctitg  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.nmprimtl  WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.nrchqini
                w_enviados.nrchqfim
                w_enviados.tpopelcm
                WITH FRAME f_enviados.
            
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF   LAST-OF(w_enviados.nrdconta)   THEN  /*pular linha a cada conta*/
             PUT STREAM str_1 SKIP(1).
                
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                   crapage.nmresage SKIP.
             END.
         
    END.

    OUTPUT STREAM str_1 CLOSE.
    
    IF   glb_cdcooper <> 1  THEN
         DO:
             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "132col"
                    glb_nmarqimp = aux_nmarqrel.
       
             RUN fontes/imprim.p.
         END.

    /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
    IF   glb_inproces = 1   THEN
         UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                           SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                           LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

END PROCEDURE.
/*...........................................................................*/

