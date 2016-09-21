/* .............................................................................

   Programa: fontes/crps301.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Dezembro/2000                      Ultima atualizacao: 13/10/2014
   
   Dados referentes ao programa:

   Frequencia: Por solicitacao
   Objetivo  : Atende a solicitacao 16.
               Ordem do programa na solicitacao: 1. 
               Emite relatorio 253.
               Listar etiquetas para com dados dos associados para selar cartas
               
   Alteracoes: 02/01/2001 - Acerto na selecao quinzenal. (Eduardo).
   
               16/01/2001 - Acerto da critica 660. (Eduardo). 

               06/02/2001 - Alterado para imprimir etiquetas (no mensal) para
                            as contas com tipo de emissao igual a 0 - Tipos de
                            conta 6 ou 7 (Edson).
                            
               27/04/2001 - Trocado para solicitacao 37 e outra tabela de 
                            controle. Passa a rodar dia > 10 e > 20 
                            (Deborah).
                            
               05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)

               04/12/2002 - Gerar etiquetas de extrato quinzenal se o dia for
                            menor que 20 e gerar etiquetas para todos os ex-
                            tratos se dia for maior que 20.
                            Nao faz mais o controle pela tabela (Junior).

               07/04/2005 - Pular uma linha na primeira pagina de cada arquivo
                            de etiquetas (Evandro).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               19/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               28/07/2006 - Efetuado acerto no campo rel_linhaimp[3] (Diego).
               
               23/11/2006 - Modificado layout das etiquetas (Diego).
               
               26/12/2006 - Corrigidas as contagens das etiquetas (Evandro).

               14/01/2008 - Atualizar craptab utilizada na geracao da 
                            solicitacao 37 (David).
                            
               19/03/2008 - Alterar p/ CONCREDI gerar etiquetas para todos os
                            associados, desconsiderando destino de extrato (Ze)
                            
               25/04/2011 - Aumentar o formato dos campos cidade e bairro
                            (Gabriel)
                            
               13/10/2014 - #161125 Aumento de extent de aux_nmresage para 999
                            (Carlos)
............................................................................ */

DEF STREAM str_1.

{ includes/var_batch.i "NEW" } 

DEF        VAR aux_nmarqsai AS CHAR                                  NO-UNDO.
DEF        VAR rel_linhaimp AS CHAR   EXTENT 6                       NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contetiq AS INT    INIT 1                         NO-UNDO.
DEF        VAR aux_nrseqetq AS INT    INIT 1                         NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.
DEF        VAR aux_tpextrat AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmresage AS CHAR   EXTENT 999                     NO-UNDO.
DEF        VAR aux_controla AS LOGICAL                               NO-UNDO.

FORM rel_linhaimp[1] AT 1  FORMAT "x(128)" NO-LABEL
     rel_linhaimp[2] AT 1  FORMAT "x(128)" NO-LABEL
     rel_linhaimp[3] AT 1  FORMAT "x(128)" NO-LABEL
     rel_linhaimp[4] AT 1  FORMAT "x(128)" NO-LABEL
     rel_linhaimp[5] AT 1  FORMAT "x(128)" NO-LABEL
     SKIP(1)
     rel_linhaimp[6] AT 1  FORMAT "x(128)" NO-LABEL
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 140 FRAME f_etiqueta.
     
ASSIGN glb_cdprogra = "crps301"
       aux_controla = FALSE
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/*   Carrega tabela de agencias do sistema   */

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper  NO-LOCK:
    aux_nmresage[crapage.cdagenci] = crapage.nmresage.
END.
                                               
FOR EACH crapdes WHERE crapdes.cdcooper = glb_cdcooper  NO-LOCK:
                                              
    IF   crapdes.cdcooper <> 4 AND
         crapdes.indespac <> 1 THEN
         NEXT.
    
    aux_nmarqsai = "rl/crrl253_" + STRING(crapdes.cdsecext,"999") + ".lst".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqsai) PAGED PAGE-SIZE 93.
     
    ASSIGN  aux_contetiq = 1
            aux_nrseqetq = 0
            rel_linhaimp = "".
                               
    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.cdagenci = crapdes.cdagenci  AND 
                           crapass.dtdemiss = ?                 AND
                           crapass.cdsecext = crapdes.cdsecext 
                           NO-LOCK USE-INDEX crapass3:
                                
        /***   Seleciona extrato quinzenal se o dia for MENOR que 20 OU 
               seleciona todos os extratos se dia for MAIOR que 20.     ***/
        
        IF  (crapass.tpextcta = 2       AND
             DAY(glb_dtmvtolt) < 20)    OR
            (DAY(glb_dtmvtolt) > 20)    THEN
             DO:
                 IF   NOT aux_controla THEN
                      aux_controla = TRUE.   
                 
                 FIND crapenc WHERE
                      crapenc.cdcooper = glb_cdcooper      AND
                      crapenc.nrdconta = crapass.nrdconta  AND
                      crapenc.idseqttl = 1                 AND
                      crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
                      
                 ASSIGN aux_nmcidade = TRIM(crapenc.nmcidade) + " - " +
                                       TRIM(crapenc.cdufende)
                        aux_tpextrat = IF   crapass.tpextcta = 1
                                       THEN "M"
                                       ELSE
                                            IF   crapass.tpextcta = 2
                                                 THEN "Q"
                                            ELSE " "
                        rel_linhaimp[1] = rel_linhaimp[1] +
                                     STRING(crapass.nmprimtl,"x(40)") + "     "
                        rel_linhaimp[2] = rel_linhaimp[2] +
                                  STRING(aux_nmresage[crapass.cdagenci],"x(15)")
                                  + "              " + 
                                  STRING(crapass.nrdconta,"zzzzzz99")  +
                                  STRING(aux_tpextrat,"x(1)") + "       " 
                        rel_linhaimp[3] = rel_linhaimp[3] +
                                  STRING(SUBSTRING(crapenc.dsendere,1,32) + " "
                                  +
                                  TRIM(STRING(crapenc.nrendere, "zzz,zzz" )),
                                  "x(40)") + "     "
                        rel_linhaimp[4] = rel_linhaimp[4] +
                                     STRING(crapenc.complend,"x(40)") + "     "
                        rel_linhaimp[5] = rel_linhaimp[5] +
                                          STRING(crapenc.nmbairro,"x(40)") +
                                          "     " 
                        rel_linhaimp[6] = rel_linhaimp[6] +
                                          STRING(crapenc.nrcepend,"zzzzz,zz9")
                                          + "   " +
                                          STRING(aux_nmcidade,"x(30)") + "   "
                        aux_nrseqetq = aux_nrseqetq + 1
                        aux_contetiq = aux_contetiq + 1.

                 IF   aux_contetiq >= 4 THEN
                      DO:
                          DISPLAY STREAM str_1
                                  rel_linhaimp[1]   rel_linhaimp[2]
                                  rel_linhaimp[3]   rel_linhaimp[4]
                                  rel_linhaimp[5]   rel_linhaimp[6]
                                  WITH FRAME f_etiqueta.
                                  
                          DOWN STREAM str_1 WITH FRAME f_etiqueta.
                    
                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                               PAGE STREAM str_1.
                
                          ASSIGN  aux_contetiq = 1.
                                  rel_linhaimp = "".
                      END.
             END.  /*  Fim do IF  */  
    END. /*  FOR EACH crapass  */    
                                  
    IF   aux_contetiq <> 1 THEN 
         DO:
            DISPLAY STREAM str_1 
                    rel_linhaimp[1]   rel_linhaimp[2] 
                    rel_linhaimp[3]   rel_linhaimp[4]
                    rel_linhaimp[5]   rel_linhaimp[6]
                    WITH FRAME f_etiqueta.

            DOWN STREAM str_1 WITH FRAME f_etiqueta.

            IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                 PAGE STREAM str_1.
         END.            

    OUTPUT STREAM str_1 CLOSE.  
    
    IF   aux_nrseqetq > 0 THEN
         DO:
             ASSIGN glb_nmformul = "etqcorreio"
                    glb_nrcopias = 1
                    glb_nmarqimp = aux_nmarqsai.
     
             RUN fontes/imprim.p.
         END.   

END.  /*  FOR EACH do crapdes  */  

IF   aux_controla THEN
     DO:
         glb_cdcritic = 660.

         RUN fontes/critic.p.

         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.

/*** Atualiza parametro utilizado na geracao da solicitacao 37 ***/
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "EXESOLAPLI" AND
                   craptab.tpregist = 001          
                   EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

IF  AVAILABLE craptab  THEN
    DO:
        IF  INTE(craptab.dstextab) = 0  THEN
            craptab.dstextab = "1".
        ELSE
        IF  INTE(craptab.dstextab) = 1  THEN
            craptab.dstextab = "2".
    END.

RELEASE craptab.

RUN fontes/fimprg.p.
/* ......................................................................... */

