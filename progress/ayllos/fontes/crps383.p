/* ...........................................................................
   Programa: Fontes/crps383.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Fevereiro/2004                      Ultima atualizacao: 28/09/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 082.
               Integrar arquivo de faturas BRADESCO CECRED
               Emite relatorio 339.

   Alteracoes: 22/04/2004 - Retirado a rotina para conectar e desconectar o
                            banco gener.db (Julio).

               07/06/2004 - Tratamento para registros iguais no craplau (Julio)
                
               28/06/2004 - Correcao do totalizador de rejeitados para central
                            (Julio)

               05/07/2004 - Controle para Registros duplicados (Julio). 

               01/07/2005 - Alimentado campo cdcoper das tabelas craprej,
                            craplot e craplau (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego). 
                            
               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               16/01/2007 - Se a data de integracao do arquivo for superior a 
                            data de debito, jogar data do debito para o dia
                            seguinte (Julio)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               04/02/2009 - Listar rejeitados, soh na CECRED (Gabriel). 
               
               25/03/2009 - Tratamento no caso de recebimentos de contas com 
                            caractere invalido (Elton).
                            
               17/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               22/11/2010 - Nao limitar o tamanho do arquivo de origem (Ze).
               
               10/12/2010 - Corrigido somas, quantidades e tratamento
                            para quando o cdcooper nao existir (Adriano).
                            
               29/12/2010 - Desprezar o arquivo original - Para extrato (Ze).
               
               07/04/2011 - Alteracao para atender as diferencas (Ze).
               
               27/09/2011 - Não mover o arquivo .original para o salvar
                            Arquivo será tratado pelo crps602.p (Irlan)
                            
               01/11/2011 - Incluido tratamento da critica 564 para quando
                            for montado o relatorio da central (Adriano).
                            
               26/10/2012 - Migracao AltoVale (Tiago).
               
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).
                            
               10/01/2013 - Ajuste migracao AltoVale (Gabriel).
               
               10/01/2013 - Incluso tratamento para lançar automaticamente creditos
                            631 (Daniel).
                            
               03/06/2013 - Incluido no DO WHILE CAN-FIND craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
               
               07/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
             
               07/11/2013 - Alterado totalizador de PAs de 99 para 999. 
                            (Guilherme Gielow) 
               
               02/12/2013 - Migracao Acredicop - Viacredi, incluido geracao
                            de critica 951 para as contas migradas (Tiago).
                            
               21/01/2014 - Incluir VALIDATE craprej,  craplot, crablot, 
                            craplau, crablau (Lucas R.)
                            
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).                            
                       
               06/05/2014 - Remover a crítica 190 do log (Douglas Quisinski).
               
               25/07/2014 - Ajuste para nao concatenar .err ao arquivo
                            quando o mesmo ja possuir esta extensao
                            pois ocorria um erro de arquivo muito grande
                            (Tiago/Elton SD168694).
                            
              11/09/2014 - Ajuste na p_gravalinha para gerar criticas das 
                            contas migradas da Concredi e Credimilsul
                            (Odirlei/AMcom).
              
              28/07/2015 - Ajuste na leitura do nome do arquivo para nao estourar 
                           o tamanho da variavel SD306534 (Odirlei/AMcom).
                            
              28/09/2015 - Incluido nas consultas da craplau
                           craplau.dsorigem <> "CAIXA" (Lombardi).
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */
DEF STREAM str_3.   /*  Para arquivo temporario */

{ includes/var_batch.i  {1} }

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contaant AS INT                                   NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR u            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(300)"               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT  INIT 6904                        NO-UNDO.
DEF        VAR aux_tplotmov AS INT                                   NO-UNDO.

DEF        VAR aux_tpregist AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR aux_nrdconta AS INTEGER                               NO-UNDO.
DEF        VAR aux_nrctacri AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.

DEF        VAR tot_qtcrdrec AS INT   EXTENT 99                       NO-UNDO.
DEF        VAR tot_qtcrdint AS INT   EXTENT 99                       NO-UNDO.
DEF        VAR tot_qtcrdrjd AS INT   EXTENT 99                       NO-UNDO.
DEF        VAR tot_qtcrdrjc AS INT   EXTENT 99                       NO-UNDO.

DEF        VAR tot_vlnacrec AS DECI  EXTENT 99                       NO-UNDO.
DEF        VAR tot_vlnacint AS DECI  EXTENT 99                       NO-UNDO.
DEF        VAR tot_vlnacrjd AS DECI  EXTENT 99                       NO-UNDO.
DEF        VAR tot_vlnacrjc AS DECI  EXTENT 99                       NO-UNDO.

DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlemreal AS DECI                                  NO-UNDO.
DEF        VAR aux_dtmvtopg AS DATE                                  NO-UNDO.
DEF        VAR aux_nrcrcard AS DECI                                  NO-UNDO.
DEF        VAR aux_cdcooper AS INT                                   NO-UNDO.
DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_nmtitula AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlfatura AS DECI                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrseqlan AS INT                                   NO-UNDO.
DEF        VAR aux_qtcooper AS INT                                   NO-UNDO.
DEF        VAR fun_prhandle AS HANDLE                                NO-UNDO.
DEF        VAR aux_qttotrej AS INT                                   NO-UNDO.
DEF        VAR aux_vltotrej AS DECI                                  NO-UNDO.


DEF        VAR aux_cdhistor LIKE craplot.cdhistor                    NO-UNDO.


DEF BUFFER crablot FOR craplot.
DEF BUFFER crablau FOR craplau.

DEF TEMP-TABLE w-craprej                                             NO-UNDO
    FIELD cdcooper LIKE crapass.cdcooper  FORMAT  "zzz,zzz,zz9"
    FIELD nrdconta LIKE crapass.nrdconta 
    FIELD nmtitula LIKE crapass.nmprimtl
    FIELD nrcrcard LIKE crawcrd.nrcrcard
    FIELD dtmvtopg AS   DATE
    FIELD vlfatura AS   DEC               FORMAT "z,zzz,zz9.99"
    FIELD dscritic AS   CHAR              FORMAT "x(36)".


FORM aux_setlinha  FORMAT "x(300)"
     WITH FRAME AA WIDTH 300 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01
     aux_nmarquiv       AT 10 FORMAT "x(35)"    NO-LABEL
     aux_dtmvtopg       AT 45 LABEL "DATA DO DEBITO" FORMAT "99/99/9999"
     SKIP(1)
     glb_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     aux_cdagenci       AT 18 FORMAT "zz9"        LABEL "PA"
     aux_cdbccxlt       AT 30 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     aux_nrdolote       AT 49 FORMAT "zzz,zz9"    LABEL "LOTE"
     aux_tplotmov       AT 63 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM craprej.cdpesqbb AT 01 FORMAT "x(19)"            LABEL "CARTAO"
     aux_nrctacri     AT 21                           LABEL "CONTA/DV"
     craprej.dshistor AT 32 FORMAT "x(30)"            LABEL "NOME"
     craprej.vlsdapli AT 63 FORMAT "zzzz,zzz,zz9.99-" LABEL "TOTAL NACIONAL"
     aux_dscritic     AT 80 FORMAT "x(36)"            LABEL "CRITICA"
     WITH NO-BOX NO-LABELS COLUMN 8 DOWN WIDTH 132 FRAME f_lanctos.

FORM SKIP(1)                                   
     "RECEBIDOS      INTEGRADOS    DEBITOS REJ.   CREDITOS REJ."   AT  28
     SKIP(1)
     "QTD.CARTOES:"                 AT 10
     tot_qtcrdrec[aux_cdcooper]     AT 30 FORMAT "zzz,zz9"
     tot_qtcrdint[aux_cdcooper]     AT 46 FORMAT "zzz,zz9"
     tot_qtcrdrjd[aux_cdcooper]     AT 62 FORMAT "zzz,zz9"
     tot_qtcrdrjc[aux_cdcooper]     AT 78 FORMAT "zzz,zz9"
     SKIP
     "TOTAL NACIONAL:"              AT 07
     tot_vlnacrec[aux_cdcooper]     AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacint[aux_cdcooper]     AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacrjd[aux_cdcooper]     AT 55 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacrjc[aux_cdcooper]     AT 71 FORMAT "zzz,zzz,zz9.99-"
     SKIP(2)
     WITH NO-BOX NO-LABELS DOWN COLUMN 8 WIDTH 132 FRAME f_total.

FORM SKIP(1)
     "** TOTAL **" AT 7
     SKIP(1)
     "RECEBIDOS      INTEGRADOS    DEBITOS REJ.   CREDITOS REJ."  AT  28
     SKIP(1)
     "QTD.CARTOES:"                 AT 10
     tot_qtcrdrec[3]     AT 30 FORMAT "zzz,zz9"
     tot_qtcrdint[3]     AT 46 FORMAT "zzz,zz9"
     tot_qtcrdrjd[3]     AT 62 FORMAT "zzz,zz9"
     tot_qtcrdrjc[3]     AT 78 FORMAT "zzz,zz9"
     SKIP
     "TOTAL NACIONAL:"              AT 07
     tot_vlnacrec[3]     AT 23 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacint[3]     AT 39 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacrjd[3]     AT 55 FORMAT "zzz,zzz,zz9.99-"
     tot_vlnacrjc[3]     AT 71 FORMAT "zzz,zzz,zz9.99-"
     SKIP(2)
     WITH NO-BOX NO-LABELS DOWN COLUMN 8 WIDTH 132 FRAME f_total_geral.

FORM crapass.nrdconta crapass.nmprimtl
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_cooperado.

FORM w-craprej.cdcooper        FORMAT "zzzz9"
     w-craprej.nrdconta   
     w-craprej.nmtitula        FORMAT "x(27)"
     w-craprej.nrcrcard 
     w-craprej.dtmvtopg        FORMAT "99/99/9999"
     w-craprej.vlfatura        FORMAT "zzzz,zzz,zz9.99-"
     w-craprej.dscritic        FORMAT "x(34)"
     WITH WIDTH 132 COLUMN 1 DOWN NO-LABELS FRAME f_rejeitados.

FORM "COOP.   CONTA/DV NOME                           NUMERO DO CARTAO" 
     "DATA DEBITO  VALOR DEBITADO CRITICA" 
     SKIP
     "----- ---------- --------------------------- -------------------"  
     "----------- --------------- ----------------------------------"
     WITH WIDTH 132 COLUMN 1 NO-LABELS NO-ATTR-SPACE
          FRAME f_cabec_rejeitados_deb.
     
FORM "COOP.   CONTA/DV NOME                           NUMERO DO CARTAO"
     "DATA DEBITO VALOR CREDITADO CRITICA" 
     SKIP
     "----- ---------- --------------------------- -------------------"
     "----------- --------------- ----------------------------------"
     WITH WIDTH 132 COLUMN 1 NO-ATTR-SPACE NO-LABELS 
          FRAME f_cabec_rejeitados_cre.
     
FORM "TOTAL:" 
     aux_qttotrej    AT 58     FORMAT "zzz,zz9"
     aux_vltotrej    AT 78     FORMAT "zzz,zzz,zz9.99-"
     SKIP
     WITH WIDTH 132 COLUMN 1 NO-LABELS FRAME f_total_rejeitados.
     

/* Funcao utilizada para procurar a partir do numero da conta o codigo da 
          cooperativa, a busca eh feita na tabela CTADEBVISA                 */
          
FUNCTION f_cdcooper RETURN INTEGER (INPUT par_nrdconta AS INT):

  DEF   VAR fun_cdcooper    AS  INT                                 NO-UNDO.
  
  IF   crapcop.cdcooper = 3   THEN
       DO:
           RUN fontes/util_cecred.p PERSISTENT SET fun_prhandle.
            
           RUN p_cdcooper IN fun_prhandle (INPUT  par_nrdconta, 
                                           OUTPUT fun_cdcooper).
            
           DELETE PROCEDURE fun_prhandle.
            
           RETURN fun_cdcooper.
            
       END.
  ELSE
       RETURN 0.
       
END.    

glb_cdprogra = "crps383".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
  
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").

         RETURN.

     END.
 

IF   glb_cdcooper = 3 THEN
     DO:
         RUN fontes/util_cecred.p PERSISTENT SET fun_prhandle.
            
         RUN f_cdultimacoop IN fun_prhandle(OUTPUT aux_qtcooper).
            
         DELETE PROCEDURE fun_prhandle.

     END.       


{ includes/cabrel132_1.i }

RUN p_consistearq(OUTPUT aux_contador).

aux_contaant = aux_contador.

DO  i = 1 TO aux_contador:
    
    ASSIGN aux_flgrejei = FALSE
           aux_flgfirst = TRUE
           aux_vlemreal = 0
           aux_nmtitula = "".
    
    INPUT STREAM str_2 FROM VALUE("bradesco/" + tab_nmarqtel[i] + ".q") NO-ECHO.

    DO WHILE TRUE:
       
       SET STREAM str_2 aux_setlinha  WITH FRAME AA.
       
       aux_tpregist = SUBSTR(aux_setlinha,1,1).
    
       IF   aux_tpregist <> "0" THEN
            NEXT.
       
       LEAVE.     
            
    END.
    
    IF   aux_tpregist <> "0" THEN
         NEXT.
                      
    ASSIGN aux_diarefer = INTEGER(SUBSTR(aux_setlinha,118,2))
           aux_mesrefer = INTEGER(SUBSTR(aux_setlinha,116,2))
           aux_anorefer = INTEGER(SUBSTR(aux_setlinha,112,4))
           aux_dtmvtopg = DATE(aux_mesrefer,aux_diarefer,aux_anorefer).
                                          
    IF   aux_dtmvtopg <= glb_dtmvtolt   THEN
         ASSIGN aux_dtmvtopg = glb_dtmvtopr.
         
    IF   glb_inrestar <> 0 AND glb_nrctares = 0 THEN 
         FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                craprej.dtrefere = glb_cdprogra  AND
                                craprej.dtmvtolt = aux_dtmvtopg 
                                EXCLUSIVE-LOCK TRANSACTION:
             DELETE craprej.

         END.
    
    IF   glb_inrestar <> 0 THEN
         DO:
             ASSIGN aux_nrdolote = INT(glb_dsrestar)
                    glb_inrestar = 0.
                    
             IF   aux_nrdolote = 0 THEN
                  aux_nrdolote = 6870.

         END.         
    ELSE
         DO WHILE TRUE:
               
            IF   CAN-FIND(craplot WHERE
                          craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtolt   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = aux_nrdolote         
                          USE-INDEX craplot1) THEN

                 DO:
                     aux_nrdolote = aux_nrdolote + 1.
                     NEXT.

                 END.

            LEAVE.
         END.   
    
    ASSIGN aux_tpregist = "".
    

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 300.

       IF   aux_tpregist = SUBSTR(aux_setlinha, 1, 1) THEN
            DO:
                RUN p_LogaErro(aux_nrdconta, aux_cdcooper).
                NEXT.

            END.

       aux_tpregist = SUBSTR(aux_setlinha, 1, 1).

       IF (aux_tpregist = "3")   THEN
           DO:
              IF crapcop.cdcooper = 3   THEN
                 DO:
                     CREATE craprej.
                     ASSIGN craprej.dtrefere = glb_cdprogra
                            craprej.dtmvtolt = aux_dtmvtopg
                            craprej.nrdconta = 99999999
                            craprej.nrseqdig = 
                                    INT(SUBSTR(aux_setlinha,42,7))
                            craprej.vldaviso = 
                                    DECI(SUBSTR(aux_setlinha,82,17)) / 100
                            craprej.vllanmto = 
                                    DECI(SUBSTR(aux_setlinha,64,17)) / 100
                            craprej.cdcritic = 1
                            craprej.cdcooper = glb_cdcooper.
                     VALIDATE craprej.
           
                 END.
           
           END.
       ELSE
         IF aux_tpregist = "0" THEN
            DO:
                NEXT.
         
            END.
         ELSE
           IF aux_tpregist = "1" THEN
              DO:   
                 /* tratamento normal do tipo 1 */  
                 ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,256,15)) 
                        aux_nrctacri = ""                              
                        NO-ERROR.
                 
                 IF  ERROR-STATUS:ERROR THEN      
                     ASSIGN aux_nrctacri = SUBSTR(aux_setlinha,256,15)
                            aux_nrdconta = 0.                                 
                 
                 ASSIGN aux_nrcrcard = DECI(SUBSTR(aux_setlinha,23,19))
                        aux_nmtitula = SUBSTR(aux_setlinha,42,30)
                        aux_cdcooper = INT(SUBSTR(aux_setlinha,187,7))
                        aux_vlemreal = 0
                        aux_vlfatura = 0 
                        aux_flgfirst = FALSE.
           
              END.
           ELSE
             IF aux_tpregist = "2" THEN
                DO:
                   IF aux_cdcooper     = crapcop.cdcooper   OR
                      crapcop.cdcooper = 3                  THEN
                      DO:
                          aux_vllanmto = DECIMAL(SUBSTR(aux_setlinha,59,13)) / 
                                         100.
                   
                          IF CAN-DO("C,c",SUBSTR(aux_setlinha,187,1)) THEN
                             DO:
                                 aux_vllanmto = aux_vllanmto * -1.

                             END.          
                                         
                          aux_vlemreal = aux_vlemreal + aux_vllanmto.
                      END.
                   
                   IF   aux_vlemreal <> 0 THEN
                        RUN p_gravalinha(INPUT aux_cdcooper).

                END.
                  
    END. /* FIM do DO WHILE TRUE TRANSACTION */

    INPUT STREAM str_2 CLOSE.

    /* CRIACAO DO LAU */ 
        
    IF crapcop.cdcooper <> 3   THEN
       DO:

          ASSIGN tot_qtcrdrec = 0    tot_qtcrdrjd = 0
                 tot_qtcrdint = 0    tot_qtcrdrjc = 0
                 tot_vlnacrec = 0    tot_vlnacint = 0
                 tot_vlnacrjc = 0    tot_vlnacrjd = 0
                 aux_cdcooper = crapcop.cdcooper
                 glb_cdcritic = 0    aux_flgfirst = TRUE.
          
          TRANS_2:
          FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                 craprej.dtrefere = glb_cdprogra  AND
                                 craprej.dtmvtolt = aux_dtmvtopg  AND
                                 (craprej.cdcritic = 0 OR craprej.cdcritic = 631)
                                 BY craprej.nrdconta TRANSACTION:

               IF (craprej.cdcritic = 0) THEN
                    aux_cdhistor = 293. /* Debito VISA  */
               ELSE
                    aux_cdhistor = 956. /* Credito VISA */

              /* Verifica se eh uma cta migrada nao ativa
                 Fatura de 01/01/2013 */
              FIND craptco WHERE craptco.cdcopant = craprej.cdcooper AND
                                 craptco.nrctaant = craprej.nrdconta AND
                                 craptco.flgativo = FALSE            AND
                                 craptco.tpctatrf <> 3
                                 NO-LOCK NO-ERROR.
              
              ASSIGN tot_qtcrdint[aux_cdcooper] = 
                          tot_qtcrdint[aux_cdcooper] + 1
                     tot_vlnacint[aux_cdcooper] = 
                          tot_vlnacint[aux_cdcooper] + craprej.vlsdapli
                     tot_qtcrdrec[aux_cdcooper] = 
                          tot_qtcrdrec[aux_cdcooper] + 1
                     tot_vlnacrec[aux_cdcooper] = 
                          tot_vlnacrec[aux_cdcooper] + craprej.vlsdapli.

              IF   glb_nrctares >= craprej.nrdconta THEN
                   NEXT.
      
              DO WHILE TRUE: 
                              
                 FIND craplot WHERE  craplot.cdcooper = glb_cdcooper  AND
                                     craplot.dtmvtolt = glb_dtmvtolt  AND
                                     craplot.cdagenci = 1             AND
                                     craplot.cdbccxlt = 100           AND
                                     craplot.nrdolote = aux_nrdolote
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE craplot   THEN
                      IF   LOCKED craplot   THEN
                           DO:
                               PAUSE 2 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:

                               CREATE craplot.
                               ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                      craplot.dtmvtopg = aux_dtmvtopg
                                      craplot.cdagenci = 1
                                      craplot.cdbccxlt = 100
                                      craplot.cdbccxpg = 237
                                      craplot.cdhistor = 293
                                      craplot.cdoperad = "1"
                                      craplot.nrdolote = aux_nrdolote
                                      craplot.tplotmov = 17
                                      craplot.tpdmoeda = 1
                                      craplot.cdcooper = glb_cdcooper.
                               VALIDATE craplot.
                           END.

                 LEAVE.
      
              END.  /*  Fim do DO WHILE TRUE  */
 
              /*cria lot para as contas migradas*/
              IF  AVAIL(craptco) THEN
                  DO:

                    DO WHILE TRUE: 
                                  
                     FIND crablot WHERE  crablot.cdcooper = craptco.cdcooper AND
                                         crablot.dtmvtolt = glb_dtmvtolt     AND
                                         crablot.cdagenci = 1                AND
                                         crablot.cdbccxlt = 100              AND
                                         crablot.nrdolote = aux_nrdolote
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                     IF   NOT AVAILABLE crablot   THEN
                          IF   LOCKED crablot   THEN
                               DO:
                                   PAUSE 2 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE
                               DO:
                                   CREATE crablot.
                                   ASSIGN crablot.dtmvtolt = glb_dtmvtolt
                                          crablot.dtmvtopg = aux_dtmvtopg
                                          crablot.cdagenci = 1
                                          crablot.cdbccxlt = 100
                                          crablot.cdbccxpg = 237
                                          crablot.cdhistor = 293
                                          crablot.cdoperad = "1"
                                          crablot.nrdolote = aux_nrdolote
                                          crablot.tplotmov = 17
                                          crablot.tpdmoeda = 1
                                          crablot.cdcooper = craptco.cdcooper.
                                   VALIDATE crablot.
                               END.
                    
                     LEAVE.
                    
                    END.  /*  Fim do DO WHILE TRUE  */

                  END.

              DO WHILE TRUE:

                 FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                    crapres.cdprogra = glb_cdprogra
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapres   THEN
                      IF   LOCKED crapres   THEN
                           DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT.

                           END.
                      ELSE
                           DO: 

                               glb_cdcritic = 151.
                               RUN fontes/critic.p.
                               UNIX SILENT
                                    VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> log/proc_batch.log").

                               UNDO TRANS_2, RETURN.  

                           END.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

              DO WHILE CAN-FIND(craplau WHERE 
                                craplau.cdcooper  = glb_cdcooper     AND
                                craplau.nrdconta  = craprej.nrdconta AND
                                craplau.nrdocmto  = craprej.nrdocmto AND
                                craplau.cdhistor  = craplot.cdhistor AND
                                craplau.dtmvtopg  = craplot.dtmvtopg AND
                                craplau.dsorigem <> "CAIXA"          AND
                                craplau.dsorigem <> "INTERNET"       AND
                                craplau.dsorigem <> "TAA"            AND
                                craplau.dsorigem <> "PG555"          AND 
                                craplau.dsorigem <> "BLOQJUD"        AND
                                craplau.dsorigem <> "DAUT BANCOOB"   NO-LOCK):

                 ASSIGN craprej.nrdocmto = craprej.nrdocmto + 1000.     

              END.

              CREATE craplau.
              ASSIGN craplau.cdagenci = craplot.cdagenci
                     craplau.cdbccxlt = craplot.cdbccxlt
                     craplau.cdbccxpg = craplot.cdbccxpg
                     craplau.cdcritic = 0               
                     craplau.cdhistor = aux_cdhistor
                     craplau.dtdebito = ?               
                     craplau.dtmvtolt = craplot.dtmvtolt
                     craplau.dtmvtopg = craplot.dtmvtopg
                     craplau.insitlau = 3               
                     craplau.nrcrcard = DECI(craprej.cdpesqbb)
                     craplau.nrdconta = craprej.nrdconta    
                     craplau.nrdctabb = craprej.nrdconta    
                     craplau.nrdocmto = craprej.nrdocmto
                     craplau.nrdolote = craplot.nrdolote
                     craplau.nrseqdig = craprej.nrdocmto
                     craplau.nrseqlan = craprej.nrdocmto                   
                     craplau.tpdvalor = 1                   
                     craplau.cdseqtel = ""                   
                     craplau.vllanaut = IF ( craprej.vllanmto > 0 ) THEN
                                            craprej.vllanmto
                                        ELSE
                                            craprej.vllanmto * -1 
                     craplau.cdcooper = glb_cdcooper
              

                     craplot.nrseqdig = craplot.nrseqdig + 1 
                     craplot.qtcompln = craplot.qtcompln + 1 
                     craplot.qtinfoln = craplot.qtinfoln + 1 
                     crapres.nrdconta = craprej.nrdconta
                     crapres.dsrestar = STRING(aux_nrdolote).

              VALIDATE craplau.

              IF aux_cdhistor = 293 THEN
                  DO:
                      ASSIGN craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut 
                             craplot.vlinfodb = craplot.vlcompdb.
                  END.
              ELSE
                  DO:
                      ASSIGN craplot.vlcompcr = craplot.vlcompcr + craplau.vllanaut
                             craplot.vlinfocr = craplot.vlcompcr.
                  END.

              /*cria lau para as contas migradas*/
              IF  AVAIL(craptco) THEN
                  DO:          
                      RUN cria-lau-ctamigrada(INPUT craptco.cdcooper,
                                              INPUT crablot.cdagenci,
                                              INPUT crablot.cdbccxlt,
                                              INPUT crablot.cdbccxpg,
                                              INPUT aux_cdhistor,
                                              INPUT crablot.dtmvtolt,
                                              INPUT crablot.dtmvtopg,
                                              INPUT DECI(craprej.cdpesqbb),
                                              INPUT craptco.nrdconta,
                                              INPUT crablot.nrdolote,
                                              INPUT craprej.nrdocmto,
                                              INPUT craprej.vllanmto).

                      /*atualiza lot das contas migradas*/
                      ASSIGN crablot.nrseqdig = crablot.nrseqdig + 1 
                             crablot.qtcompln = crablot.qtcompln + 1 
                             crablot.qtinfoln = crablot.qtinfoln + 1. 
                          
                      IF aux_cdhistor = 293 THEN
                          DO:
                              ASSIGN craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
                                     craplot.vlinfodb = craplot.vlcompdb.
                          END.
                      ELSE
                          DO:
                              ASSIGN craplot.vlcompcr = craplot.vlcompcr + craplau.vllanaut
                                     craplot.vlinfocr = craplot.vlcompcr.
                          END.

                  END.        

          END.  /* FOR EACH CRAPREJ */  

          FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                 craprej.dtrefere = glb_cdprogra  AND
                                 craprej.dtmvtolt = aux_dtmvtopg  AND
                                 (craprej.cdcritic = 0  OR craprej.cdcritic = 631)
                                 EXCLUSIVE-LOCK TRANSACTION:

              DELETE craprej.
      
          END.

          ASSIGN aux_nmarqimp    = "rl/crrl339_" + STRING(i,"999") + ".lst"
                 aux_cdagenci    = 1
                 aux_cdbccxlt    = 100
                 aux_tplotmov    = 17
                 aux_flgrejei    = FALSE
                 aux_nmarquiv    = tab_nmarqtel[i].

          OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

          VIEW STREAM str_1 FRAME f_cabrel132_1.
 
          DISPLAY STREAM str_1  aux_nmarquiv     aux_dtmvtopg
                                glb_dtmvtolt     aux_cdagenci
                                aux_cdbccxlt     aux_nrdolote
                                aux_tplotmov     WITH FRAME f_cab.

          DOWN STREAM str_1 WITH FRAME f_cab.
 
          /* CRIACAO DO RELATORIO  */
          FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                 craprej.dtrefere = glb_cdprogra  AND
                                 craprej.dtmvtolt = aux_dtmvtopg  AND 
                                 craprej.cdcritic > 0             AND
                                 craprej.cdcritic <> 631 /* Nao listar creditos Visa como critica */
                                 NO-LOCK BY craprej.nrdconta:

              glb_cdcritic = craprej.cdcritic.
      
              RUN fontes/critic.p.
      
              aux_dscritic = glb_dscritic.
 
              ASSIGN tot_qtcrdrec[aux_cdcooper] = 
                          tot_qtcrdrec[aux_cdcooper] + 1
                     tot_vlnacrec[aux_cdcooper] = 
                          tot_vlnacrec[aux_cdcooper] + craprej.vlsdapli.

              IF   LINE-COUNTER(str_1) > 80 THEN
                   DO:
                       PAGE STREAM str_1.
           
                       DISPLAY STREAM str_1
                               aux_nmarquiv     aux_dtmvtopg
                               glb_dtmvtolt     aux_cdagenci     
                               aux_cdbccxlt     aux_nrdolote     
                               aux_tplotmov     WITH FRAME f_cab.

                       DOWN STREAM str_1 WITH FRAME f_cab.

                       aux_flgfirst = FALSE.

                   END.

              IF   craprej.vlsdapli > 0 THEN
                   ASSIGN tot_qtcrdrjd[aux_cdcooper] = 
                            tot_qtcrdrjd[aux_cdcooper] + 1
                          tot_vlnacrjd[aux_cdcooper] = 
                            tot_vlnacrjd[aux_cdcooper] + craprej.vlsdapli.
              ELSE
                   ASSIGN tot_qtcrdrjc[aux_cdcooper] = 
                            tot_qtcrdrjc[aux_cdcooper] + 1
                          tot_vlnacrjc[aux_cdcooper] = 
                            tot_vlnacrjc[aux_cdcooper] + craprej.vlsdapli.


              IF  craprej.nrdctitg <> "" THEN 
                  aux_nrctacri = STRING(craprej.nrdctitg,"xxxx.xxx.x").  
              ELSE 
                  aux_nrctacri = STRING(craprej.nrdconta,"zzzz,zzz,z").
              
              DISPLAY STREAM str_1
                             craprej.cdpesqbb  aux_nrctacri
                             craprej.dshistor  
                             craprej.vlsdapli  WHEN craprej.vlsdapli <> 0 
                             aux_dscritic      
                             WITH FRAME f_lanctos.
                      
              DOWN STREAM str_1 WITH FRAME f_lanctos.       
               
          END.
          
          IF   LINE-COUNTER(str_1) > 77 THEN
               DO:
                   PAGE STREAM str_1.
                    
                   DISPLAY STREAM str_1 aux_nmarquiv     aux_dtmvtopg
                                        glb_dtmvtolt     aux_cdagenci
                                        aux_cdbccxlt     aux_nrdolote
                                        aux_tplotmov     
                                        WITH FRAME f_cab.

                   DOWN STREAM str_1 WITH FRAME f_cab.

               END.
                         
          DISPLAY STREAM str_1 tot_qtcrdrec[aux_cdcooper] 
                               tot_qtcrdint[aux_cdcooper] 
                               tot_qtcrdrjd[aux_cdcooper] 
                               tot_qtcrdrjc[aux_cdcooper] 
                               tot_vlnacrec[aux_cdcooper] 
                               tot_vlnacint[aux_cdcooper] 
                               tot_vlnacrjd[aux_cdcooper]
                               tot_vlnacrjc[aux_cdcooper]
                               WITH FRAME f_total.           

          OUTPUT STREAM str_1 CLOSE.

       END.
    ELSE
      DO:
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  
                                NO-LOCK:
         
             aux_cdcooper = f_cdcooper(crapass.nrdconta).
             
             IF aux_cdcooper > 0 /*AND tot_qtcrdrec[aux_cdcooper] > 0*/  THEN
                DO:
                    ASSIGN 
                       tot_qtcrdrec[3] = 
                             tot_qtcrdrec[3] + tot_qtcrdrec[aux_cdcooper]
                       tot_vlnacrec[3] = 
                             tot_vlnacrec[3] + tot_vlnacrec[aux_cdcooper]

                       tot_qtcrdint[3] = 
                             tot_qtcrdint[3] + tot_qtcrdint[aux_cdcooper]
                       tot_vlnacint[3] = 
                             tot_vlnacint[3] + tot_vlnacint[aux_cdcooper]
                  
                       tot_qtcrdrjd[3] = 
                             tot_qtcrdrjd[3] + tot_qtcrdrjd[aux_cdcooper]
                       tot_vlnacrjd[3] = 
                             tot_vlnacrjd[3] + tot_vlnacrjd[aux_cdcooper]
                             
                       tot_qtcrdrjc[3] = 
                             tot_qtcrdrjc[3] + tot_qtcrdrjc[aux_cdcooper]
                       tot_vlnacrjc[3] = 
                            tot_vlnacrjc[3] + tot_vlnacrjc[aux_cdcooper].
      
           
                    IF   glb_nrctares >= crapass.nrdconta THEN
                         NEXT.
      
                    DO WHILE TRUE: 
                          
                       FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                          craplot.dtmvtolt = glb_dtmvtolt AND
                                          craplot.cdagenci = 1            AND
                                          craplot.cdbccxlt = 100          AND
                                          craplot.nrdolote = aux_nrdolote
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF   NOT AVAILABLE craplot   THEN
                            IF   LOCKED craplot   THEN
                                 DO:
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:

                                     CREATE craplot.
                                     ASSIGN 
                                         craplot.dtmvtolt = glb_dtmvtolt
                                         craplot.dtmvtopg = aux_dtmvtopg
                                         craplot.cdagenci = 1
                                         craplot.cdbccxlt = 100
                                         craplot.cdbccxpg = 237
                                         craplot.cdhistor = 293
                                         craplot.cdoperad= "1"
                                         craplot.nrdolote = aux_nrdolote
                                         craplot.tplotmov = 17
                                         craplot.tpdmoeda = 1
                                         craplot.cdcooper = glb_cdcooper.
                                 END.

                       LEAVE.
      
                    END.  /*  Fim do DO WHILE TRUE  */
 
                    DO WHILE TRUE:

                       FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                          crapres.cdprogra = glb_cdprogra
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF   NOT AVAILABLE crapres   THEN
                            IF   LOCKED crapres   THEN
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     glb_cdcritic = 151. 
                                     RUN fontes/critic.p.
                                     UNIX SILENT
                                     VALUE("echo " +
                                           STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + 
                                           "' --> '" + glb_dscritic +
                                           " >> log/proc_batch.log").

                                     RETURN. 
                                 END.
                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */    
 
                    CREATE craplau.
                    ASSIGN craplau.cdagenci = craplot.cdagenci
                           craplau.cdbccxlt = craplot.cdbccxlt
                           craplau.cdbccxpg = craplot.cdbccxpg
                           craplau.cdcritic = 0               
                           craplau.cdhistor =  IF (tot_vlnacint[aux_cdcooper] > 0) THEN
                                                    293 /* Debito VISA */
                                                ELSE
                                                    956 /* Credito VISA */
                           craplau.dtdebito = ?               
                           craplau.dtmvtolt = craplot.dtmvtolt
                           craplau.dtmvtopg = craplot.dtmvtopg
                           craplau.insitlau = 3               
                           craplau.nrdconta = crapass.nrdconta    
                           craplau.nrdctabb = crapass.nrdconta    
                           craplau.nrdocmto = aux_cdcooper
                           craplau.nrdolote = craplot.nrdolote
                           craplau.nrseqdig = aux_cdcooper    
                           craplau.nrseqlan = aux_cdcooper    
                           craplau.tpdvalor = 1                   
                           craplau.cdseqtel = ""                   
                           craplau.vllanaut = IF (tot_vlnacint[aux_cdcooper] > 0) THEN 
                                                    tot_vlnacint[aux_cdcooper]
                                              ELSE 
                                                    tot_vlnacint[aux_cdcooper] * -1
                           craplau.cdcooper = glb_cdcooper
 
                           craplot.nrseqdig = craplot.nrseqdig + 1 
                           craplot.qtcompln = craplot.qtcompln + 1 
                           craplot.qtinfoln = craplot.qtinfoln + 1. 
                                                                                  
                    VALIDATE craplau.

                    ASSIGN crapres.nrdconta = crapass.nrdconta
                           crapres.dsrestar = STRING(aux_nrdolote).
                           
                    
                    IF (tot_vlnacint[aux_cdcooper] > 0) THEN
                        DO:
                            ASSIGN craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
                                   craplot.vlcompcr = 0
                                   craplot.vlinfodb = craplot.vlcompdb
                                   craplot.vlinfocr = 0. 
                        END.
                    ELSE
                        DO:
                            ASSIGN craplot.vlcompdb = 0
                                   craplot.vlcompcr = craplot.vlcompcr + craplau.vllanaut
                                   craplot.vlinfodb = 0
                                   craplot.vlinfocr = craplot.vlcompdb.
                        END.

                    VALIDATE craplot.
                END.

         END.  /* for each crpasss */
          
         ASSIGN aux_nmarqimp    = "rl/crrl339_" + STRING(i,"999") + ".lst"
                aux_cdagenci    = 1
                aux_cdbccxlt    = 100
                aux_tplotmov    = 17
                aux_flgrejei    = FALSE
                aux_cdcooper    = 3
                aux_nmarquiv    = tab_nmarqtel[i].

         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

         VIEW STREAM str_1 FRAME f_cabrel132_1.
 
         DISPLAY STREAM str_1  aux_nmarquiv     aux_dtmvtopg
                               glb_dtmvtolt     aux_cdagenci
                               aux_cdbccxlt     aux_nrdolote
                               aux_tplotmov     
                               WITH FRAME f_cab.

         DOWN STREAM str_1 WITH FRAME f_cab.
         
         FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  
                                NO-LOCK:
             
             aux_cdcooper = f_cdcooper(crapass.nrdconta).
             
             IF   aux_cdcooper > 0   THEN
                  DO:
                      IF   LINE-COUNTER(str_1) > 77 THEN
                           DO:
                               PAGE STREAM str_1.
                  
                               DISPLAY STREAM str_1 
                                              aux_nmarquiv  aux_dtmvtopg
                                              glb_dtmvtolt  aux_cdagenci
                                              aux_cdbccxlt  aux_nrdolote
                                              aux_tplotmov
                                              WITH FRAME f_cab.

                               DOWN STREAM str_1 WITH FRAME f_cab.

                           END.

                      DISPLAY STREAM str_1 crapass.nrdconta
                                           crapass.nmprimtl
                                           WITH FRAME f_cooperado.

                      DOWN STREAM str_1 WITH FRAME f_cooperado.
                                           
                      DISPLAY STREAM str_1 tot_qtcrdrec[aux_cdcooper] 
                                           tot_qtcrdint[aux_cdcooper] 
                                           tot_qtcrdrjd[aux_cdcooper] 
                                           tot_qtcrdrjc[aux_cdcooper] 
                                           tot_vlnacrec[aux_cdcooper] 
                                           tot_vlnacint[aux_cdcooper] 
                                           tot_vlnacrjd[aux_cdcooper]
                                           tot_vlnacrjc[aux_cdcooper]
                                           WITH FRAME f_total.           

                      DOWN STREAM str_1 WITH FRAME f_total.
                                            
                  END.

         END.  /* for each crapass */
                                           
         IF   aux_cdcooper = 0 THEN
              aux_cdcooper = 3.

         DISPLAY STREAM str_1 tot_qtcrdrec[3]
                              tot_vlnacrec[3]
                              tot_qtcrdint[3]
                              tot_vlnacint[3]
                              tot_qtcrdrjd[3]
                              tot_vlnacrjd[3]
                              tot_qtcrdrjc[3]
                              tot_vlnacrjc[3]
                              WITH FRAME f_total_geral.
         
         RUN proc_rejeitados.
                                      
         OUTPUT STREAM str_1 CLOSE.                     
         
         ASSIGN tot_qtcrdrec = 0    tot_qtcrdrjd = 0
                tot_qtcrdint = 0    tot_qtcrdrjc = 0
                tot_vlnacrec = 0    tot_vlnacint = 0
                tot_vlnacrjc = 0    tot_vlnacrjd = 0
                aux_cdcooper = crapcop.cdcooper
                glb_cdcritic = 0    aux_flgfirst = TRUE.
 
      END.
         
    UNIX SILENT VALUE("rm bradesco/" + tab_nmarqtel[i] + 
                      ".q 2> /dev/null").
    
    INPUT STREAM str_3 THROUGH VALUE( "ls bradesco/" +  
                                      tab_nmarqtel[i] + "* 2> /dev/null")
                                      NO-ECHO.
    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                     
       SET STREAM str_3 aux_nmarquiv FORMAT "x(60)".

       IF   TRIM(aux_nmarquiv) MATCHES "*original*" THEN
            NEXT.

       UNIX SILENT VALUE("mv " + aux_nmarquiv + " salvar").

    END.         

    INPUT STREAM str_3 CLOSE.
  
    IF aux_flgrejei THEN 
        DO:
            glb_cdcritic = 191.
            RUN fontes/critic.p.
    
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + "' --> '" +  tab_nmarqtel[i] +
                              " >> log/proc_batch.log").
        END.

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = glb_cdprogra  AND
                           craprej.dtmvtolt = aux_dtmvtopg  
                           EXCLUSIVE-LOCK TRANSACTION:
        DELETE craprej.

    END.
    
    DO TRANSACTION:
    
       DO WHILE TRUE:

          FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                             crapres.cdprogra = glb_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
               IF   LOCKED crapres   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO: 
                        glb_cdcritic = 151.
                        RUN fontes/critic.p.
                        UNIX SILENT 
                             VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " >> log/proc_batch.log").

                        UNDO ,RETURN.
                    END.
              LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */
          
  
       ASSIGN crapres.nrdconta = 0 
              glb_nmformul = ""
              glb_nmarqimp = aux_nmarqimp.
              
       IF   glb_cdcooper = 6   THEN
            glb_nrcopias = 1.
       ELSE
            glb_nrcopias = 2.

    END. /* DO TRANSACTION */
     
    RUN fontes/imprim.p.
    
END.

RUN fontes/fimprg.p. 

/*........ PROCEDURE RESPONSAVEL PELA COLETA DOS DADOS DO ARQUIVO .......... */

PROCEDURE p_LogaErro:
  
  DEF INPUT PARAMETER par_nrdconta AS INTEGER                       NO-UNDO.
  DEF INPUT PARAMETER par_cdcooper AS INTEGER                       NO-UNDO.
  
  FIND LAST craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                          craprej.cdagenci = par_cdcooper  AND
                          craprej.nrdconta = par_nrdconta  
                          NO-ERROR.
  
  IF   AVAILABLE craprej   THEN
       craprej.cdcritic = 285.   

END.

PROCEDURE p_gravalinha:

   DEF INPUT PARAMETER par_cdcooper    AS  INT                      NO-UNDO.

   DEF VAR aux_flgctmig                AS LOGI                      NO-UNDO.

   IF   par_cdcooper = crapcop.cdcooper   THEN
        DO:
            
            aux_vlfatura = aux_vlemreal.

            FIND crapcrd WHERE crapcrd.cdcooper = glb_cdcooper  AND
                               crapcrd.nrcrcard = aux_nrcrcard 
                               NO-LOCK NO-ERROR. 

            IF   NOT AVAILABLE crapcrd THEN
                 aux_regexist = FALSE.
            ELSE 
                 aux_regexist = TRUE.

            
            IF   glb_cdcooper = 1  THEN
                 DO:
                     aux_flgctmig = CAN-FIND(craptco WHERE
                                             craptco.cdcopant =  1   AND
                                             craptco.cdcooper = 16   AND
                                             craptco.tpctatrf <> 3   AND
                                             craptco.flgativo = TRUE AND 
                                             craptco.nrctaant =  
                                                     IF aux_regexist THEN 
                                                        crapcrd.nrdconta
                                                     ELSE 
                                                        aux_nrdconta).
                 END.
            ELSE                 
                IF  glb_cdcooper = 2 THEN
                    DO:
                        aux_flgctmig = CAN-FIND(craptco WHERE
                                                craptco.cdcopant =  2   AND
                                                craptco.cdcooper =  1   AND
                                                craptco.tpctatrf <> 3   AND
                                                craptco.flgativo = TRUE AND 
                                                craptco.nrctaant =  
                                                        IF aux_regexist THEN 
                                                           crapcrd.nrdconta
                                                        ELSE 
                                                           aux_nrdconta).
                    END.                                    
                 
            ELSE 
            DO: /* Tratar migraçao da Concredi e Credimilsul*/
                IF  glb_cdcooper = 4  OR 
                    glb_cdcooper = 15 THEN
                    DO:
                        aux_flgctmig = CAN-FIND(craptco WHERE
                                                craptco.cdcopant = glb_cdcooper   AND
                                                craptco.tpctatrf <> 3   AND
                                                craptco.flgativo = TRUE AND 
                                                craptco.nrctaant =  
                                                        IF aux_regexist THEN 
                                                           crapcrd.nrdconta
                                                        ELSE 
                                                           aux_nrdconta).
                    END.
                ELSE
                    ASSIGN aux_flgctmig = FALSE.
            END.

            CREATE craprej.
            ASSIGN aux_nrseqlan = aux_nrseqlan + 1
                   craprej.cdagenci = aux_cdcooper
                   craprej.dtrefere = glb_cdprogra
                   craprej.dtmvtolt = aux_dtmvtopg
                   craprej.nrdconta = IF aux_regexist THEN 
                                         crapcrd.nrdconta
                                      ELSE 
                                         aux_nrdconta
                   craprej.dshistor = aux_nmtitula
                   craprej.cdpesqbb = STRING(aux_nrcrcard,"9999,9999,9999,9999")
                   craprej.vlsdapli = aux_vlemreal
                   craprej.vllanmto = aux_vlfatura
                   craprej.nrdocmto = aux_nrseqlan
                   craprej.cdcooper = glb_cdcooper         
                   craprej.nrdctitg = IF aux_nrctacri <> "" THEN 
                                         aux_nrctacri
                                      ELSE ""
                   craprej.cdcritic = IF aux_nrctacri <> "" THEN 
                                         564
                                      ELSE
                                      IF NOT aux_regexist THEN 
                                         546 
                                      ELSE
                                      IF aux_vlfatura < 0 THEN
                                          631 /* Utilizado apenas para diferenciar creditos VISA */
                                      ELSE
                                      IF aux_flgctmig   THEN
                                         951 
                                      ELSE 
                                          0.
            VALIDATE craprej.
        END.       
   
   IF   crapcop.cdcooper <> 3   THEN 
        RETURN.

   /* So pra CECRED ...*/ 

   ASSIGN aux_vlfatura = aux_vlemreal.
          
   FIND crapcrd WHERE crapcrd.cdcooper = aux_cdcooper  AND
                      crapcrd.nrcrcard = aux_nrcrcard 
                      NO-LOCK NO-ERROR.

   aux_regexist = AVAILABLE crapcrd.
          
   /* Verifica se eh conta migrada */
   IF  aux_cdcooper = 1   THEN 
       DO:
           aux_flgctmig = CAN-FIND(craptco WHERE
                                   craptco.cdcopant =  1   AND
                                   craptco.cdcooper = 16   AND
                                   craptco.tpctatrf <> 3   AND
                                   craptco.flgativo = TRUE AND
                                   craptco.nrctaant =  
                                           IF  aux_regexist THEN 
                                               crapcrd.nrdconta
                                           ELSE 
                                               aux_nrdconta).                 
       END.
   ELSE
       IF  aux_cdcooper = 2 THEN
       DO:
           aux_flgctmig = CAN-FIND(craptco WHERE
                                   craptco.cdcopant =  2   AND
                                   craptco.cdcooper =  1   AND
                                   craptco.tpctatrf <> 3   AND
                                   craptco.flgativo = TRUE AND
                                   craptco.nrctaant =  
                                           IF  aux_regexist THEN 
                                               crapcrd.nrdconta
                                           ELSE 
                                               aux_nrdconta).                 
       END.
   ELSE 
        DO: /* Tratar migraçao da Concredi e Credimilsul*/
            IF  glb_cdcooper = 4  OR 
                glb_cdcooper = 15 THEN
                DO:
                    aux_flgctmig = CAN-FIND(craptco WHERE
                                            craptco.cdcopant = glb_cdcooper   AND
                                            craptco.tpctatrf <> 3   AND
                                            craptco.flgativo = TRUE AND 
                                            craptco.nrctaant =  
                                                    IF aux_regexist THEN 
                                                       crapcrd.nrdconta
                                                    ELSE 
                                                       aux_nrdconta).
                END.
            ELSE
                ASSIGN aux_flgctmig = FALSE.
        END.        
           

   IF  aux_flgctmig   THEN
       DO:
           IF  aux_vlemreal < 0 THEN
               ASSIGN tot_qtcrdrjc[aux_cdcooper] = 
                              tot_qtcrdrjc[aux_cdcooper] + 1
                      tot_vlnacrjc[aux_cdcooper] = 
                              tot_vlnacrjc[aux_cdcooper] + 
                                  aux_vlemreal.
           ELSE
               ASSIGN tot_qtcrdrjd[aux_cdcooper] = 
                              tot_qtcrdrjd[aux_cdcooper] + 1
                      tot_vlnacrjd[aux_cdcooper] = 
                              tot_vlnacrjd[aux_cdcooper] + 
                                  aux_vlemreal.

           glb_cdcritic = 951.
                     
           RUN fontes/critic.p.
                                           
           CREATE w-craprej.   
           ASSIGN w-craprej.cdcooper = aux_cdcooper
                  w-craprej.nrdconta = aux_nrdconta
                  w-craprej.nmtitula = aux_nmtitula
                  w-craprej.nrcrcard = aux_nrcrcard  
                  w-craprej.dtmvtopg = aux_dtmvtopg
                  w-craprej.vlfatura = aux_vlfatura
                  w-craprej.dscritic = glb_dscritic.
       END.
   ELSE


   IF aux_cdcooper <= 0             OR   
        aux_cdcooper >  aux_qtcooper  THEN  /**Coop. Invalida**/
        DO:
            IF   aux_vlemreal < 0 THEN
                 ASSIGN tot_qtcrdrjc[99] = tot_qtcrdrjc[99] + 1
                        tot_vlnacrjc[99] = tot_vlnacrjc[99] + aux_vlemreal.
            ELSE 
                 ASSIGN tot_qtcrdrjd[99] = tot_qtcrdrjd[99] + 1
                        tot_vlnacrjd[99] = tot_vlnacrjd[99] + aux_vlemreal.
     
            ASSIGN glb_cdcritic = 794.
                             
            RUN fontes/critic.p.
            
            CREATE w-craprej.
     
            ASSIGN w-craprej.cdcooper = aux_cdcooper
                   w-craprej.nrdconta = aux_nrdconta
                   w-craprej.nmtitula = aux_nmtitula
                   w-craprej.nrcrcard = aux_nrcrcard  
                   w-craprej.dtmvtopg = aux_dtmvtopg
                   w-craprej.vlfatura = aux_vlfatura
                   w-craprej.dscritic = glb_dscritic
                   aux_cdcooper       = 99.
     
        END.
     ELSE     
       IF aux_nrcrcard = 0     OR
          aux_regexist = FALSE THEN  /*ou cartao inv.*/
          DO:
              IF aux_vlemreal < 0 THEN
                 ASSIGN tot_qtcrdrjc[aux_cdcooper] = 
                                     tot_qtcrdrjc[aux_cdcooper] + 1
                        tot_vlnacrjc[aux_cdcooper] = 
                                     tot_vlnacrjc[aux_cdcooper] + aux_vlemreal.
              ELSE 
                 ASSIGN tot_qtcrdrjd[aux_cdcooper] = 
                                    tot_qtcrdrjd[aux_cdcooper] + 1
                        tot_vlnacrjd[aux_cdcooper] = 
                                    tot_vlnacrjd[aux_cdcooper] + aux_vlemreal.
       
              glb_cdcritic = 546.
                               
              RUN fontes/critic.p.
       
              CREATE w-craprej.

              ASSIGN w-craprej.cdcooper = aux_cdcooper
                     w-craprej.nrdconta = aux_nrdconta
                     w-craprej.nmtitula = aux_nmtitula
                     w-craprej.nrcrcard = aux_nrcrcard  
                     w-craprej.dtmvtopg = aux_dtmvtopg
                     w-craprej.vlfatura = aux_vlfatura
                     w-craprej.dscritic = glb_dscritic.

          END.
       ELSE
         IF aux_nrdconta = 0 THEN /* conta invalida*/
            DO:
               IF aux_vlemreal < 0 THEN
                  ASSIGN tot_qtcrdrjc[aux_cdcooper] = 
                                      tot_qtcrdrjc[aux_cdcooper] + 1
                         tot_vlnacrjc[aux_cdcooper] = 
                                     tot_vlnacrjc[aux_cdcooper] + aux_vlemreal.
               ELSE 
                  ASSIGN tot_qtcrdrjd[aux_cdcooper] = 
                                      tot_qtcrdrjd[aux_cdcooper] + 1
                         tot_vlnacrjd[aux_cdcooper] = 
                                      tot_vlnacrjd[aux_cdcooper] + aux_vlemreal.
         
               glb_cdcritic = 564.
         
               RUN fontes/critic.p.
         
               CREATE w-craprej.

               ASSIGN w-craprej.cdcooper = aux_cdcooper
                      w-craprej.nrdconta = aux_nrdconta
                      w-craprej.nmtitula = aux_nmtitula
                      w-craprej.nrcrcard = aux_nrcrcard  
                      w-craprej.dtmvtopg = aux_dtmvtopg
                      w-craprej.vlfatura = aux_vlfatura
                      w-craprej.dscritic = glb_dscritic.

            END.
         ELSE
           ASSIGN tot_qtcrdint[aux_cdcooper] = tot_qtcrdint[aux_cdcooper] + 1
                  tot_vlnacint[aux_cdcooper] = tot_vlnacint[aux_cdcooper] + 
                                               aux_vlemreal.
        
   
   ASSIGN tot_qtcrdrec[aux_cdcooper] = tot_qtcrdrec[aux_cdcooper] + 1 
          tot_vlnacrec[aux_cdcooper] = 
                            tot_vlnacrec[aux_cdcooper] + aux_vlemreal.

END. /* PROCEDURE */

/*****  PROCEDURE RESPONSAVEL POR CONSISTIR O CONTEUDO DO ARQUIVO A SER
        PROCESSADO (Data, Quant. Registros e Numero da Conta no Bradesco) ****/

PROCEDURE p_consistearq:

    DEF OUTPUT PARAMETER  par_contaarq   AS INTEGER  INIT 0           NO-UNDO.

    DEF             VAR   pro_nrdconta   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_dtarquiv   AS CHAR                      NO-UNDO.
    DEF             VAR   pro_flgerros   AS LOGICAL                   NO-UNDO.
    DEF             VAR   pro_temdolar   AS LOGICAL  INIT FALSE       NO-UNDO. 
    DEF             VAR   pro_qtregist   AS INTEGER                   NO-UNDO.
    DEF             VAR   aux_extensao   AS CHAR                      NO-UNDO.

    ASSIGN aux_nmarqdeb = "carfat*"
           pro_qtregist = 0.
           pro_nrdconta = "2656-0164666".
              
    INPUT STREAM str_1 THROUGH VALUE( "ls bradesco/" + 
                                      aux_nmarqdeb + " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
       SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".

       /*   Desprezar o arquivo Original - arquivo para impressao do extrato */
       
       IF   TRIM(aux_nmarquiv) MATCHES "*original*" THEN
            NEXT.

       
       par_contaarq = par_contaarq + 1.

       UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                          aux_nmarquiv + "_ux 2> /dev/null").
         
       UNIX SILENT VALUE("mv " + aux_nmarquiv + "_ux " + aux_nmarquiv + 
                         " 2> /dev/null").
       

       UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                          aux_nmarquiv + ".q 2> /dev/null").
         
       tab_nmarqtel[par_contaarq] =  SUBSTR(aux_nmarquiv, 
                                            INDEX(aux_nmarquiv, "carfat"),
                                                     LENGTH(aux_nmarquiv)).
                                                                      
                                                                      
       INPUT STREAM str_2 FROM VALUE("bradesco/" +
                                    tab_nmarqtel[par_contaarq] + ".q") NO-ECHO.
       glb_cdcritic = 0.
       
       DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
          
          SET STREAM str_2 aux_setlinha WITH FRAME AA.
          
          ASSIGN pro_qtregist = pro_qtregist + 1.
          
          IF SUBSTR(aux_setlinha, 1, 1) = "0"   THEN
             DO:
                 pro_dtarquiv = SUBSTR(aux_setlinha, 112, 8).

                 IF   TRIM(pro_dtarquiv) = ""   THEN
                      DO:
                          ASSIGN pro_dtarquiv = "err"
                                 pro_flgerros = TRUE
                                 glb_cdcritic = 789.
                      END.
             END.
          ELSE
            IF SUBSTR(aux_setlinha, 1, 1) = "2"   THEN
               DO:
                   pro_flgerros = (INDEX(aux_setlinha, pro_nrdconta) = 0).
            
                   IF   pro_flgerros   THEN
                        glb_cdcritic = 127.
               END.
            ELSE
              IF SUBSTR(aux_setlinha, 1, 1) = "3"   THEN
                 DO:
                     pro_flgerros = INT(SUBSTR(aux_setlinha, 56, 7)) <> 
                                                      (pro_qtregist).           
                     IF   pro_flgerros   THEN
                          glb_cdcritic = 504.
                 END.              

          IF   pro_flgerros   THEN
               LEAVE.               

       END.
       
       IF   pro_flgerros   THEN      
            DO:       
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.

                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                            + " - " + glb_cdprogra + "' --> '"
                                            + glb_dscritic + "' --> '" + 
                                            tab_nmarqtel[par_contaarq] +
                                            " >> log/proc_batch.log").
                     END.

                /*pega extensao do arquivo pra ver se ja nao foi concatenada .err*/
                ASSIGN aux_extensao = SUBSTRING(tab_nmarqtel[par_contaarq],LENGTH(tab_nmarqtel[par_contaarq]) - 2,3).

                /* verifica a extensao para nao mover o arquivo concatenando .err 
                  se ele ja estiver com esta extensao */
                IF  aux_extensao = "err" THEN
                    DO:
                        UNIX SILENT VALUE("mv bradesco/" +
                                 tab_nmarqtel[par_contaarq] + " bradesco/" +
                                 tab_nmarqtel[par_contaarq] + " 2> /dev/null").
                    END.
                ELSE
                    DO:
                        UNIX SILENT VALUE("mv bradesco/" +
                                 tab_nmarqtel[par_contaarq] + " bradesco/" +
                                 tab_nmarqtel[par_contaarq] + ".err 2> /dev/null").
                    END.

                UNIX SILENT VALUE("rm bradesco/" +
                         tab_nmarqtel[par_contaarq] + ".q 2> /dev/null").

                ASSIGN tab_nmarqtel[par_contaarq] = ""
                       par_contaarq = par_contaarq - 1
                       pro_flgerros = FALSE.
                
            END.

       ELSE
            DO:
                UNIX SILENT VALUE("mv bradesco/" +
                       tab_nmarqtel[par_contaarq] + " bradesco/" +
                       tab_nmarqtel[par_contaarq] + "." + pro_dtarquiv +
                       " 2> /dev/null").  
                                  
                ASSIGN aux_diarefer = INT(SUBSTR(pro_dtarquiv, 7, 2))
                       aux_mesrefer = INT(SUBSTR(pro_dtarquiv, 5, 2))
                       aux_anorefer = INT(SUBSTR(pro_dtarquiv, 1, 4))
                       aux_dtrefere = DATE(aux_mesrefer, aux_diarefer,
                                                         aux_anorefer).
                
            END.
       
       ASSIGN pro_qtregist = 0.
       
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    INPUT STREAM str_2 CLOSE.
    
END. /* PROCEDURE p_consistearq */

PROCEDURE proc_rejeitados:

    DISPLAY STREAM str_1 "** COOPERATIVA OU CARTAO INVALIDOS **" AT 7.
    
    aux_cdcooper = 99.
                          
    DISPLAY STREAM str_1 tot_qtcrdrec[aux_cdcooper]
                         tot_qtcrdint[aux_cdcooper]
                         tot_qtcrdrjd[aux_cdcooper]
                         tot_qtcrdrjc[aux_cdcooper]
                         tot_vlnacrec[aux_cdcooper]
                         tot_vlnacint[aux_cdcooper]
                         tot_vlnacrjd[aux_cdcooper]
                         tot_vlnacrjc[aux_cdcooper] WITH FRAME f_total.
                                           
    DOWN STREAM str_1 WITH FRAME f_total.

    FOR EACH w-craprej WHERE w-craprej.vlfatura < 0
                             NO-LOCK BREAK BY w-craprej.cdcooper
                                              BY w-craprej.nrdconta:
    
        IF   FIRST-OF(w-craprej.cdcooper) THEN
             DISPLAY STREAM str_1 WITH FRAME f_cabec_rejeitados_cre.
        
        IF   LINE-COUNTER(str_1) > 77 THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1 WITH FRAME f_cabec_rejeitados_cre.
             END.
             
        DISPLAY STREAM str_1 w-craprej WITH FRAME f_rejeitados.
        
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
        
        ASSIGN aux_qttotrej = aux_qttotrej + 1
               aux_vltotrej = aux_vltotrej + w-craprej.vlfatura.
               
        IF   LAST-OF(w-craprej.cdcooper) THEN
             DO:
                 DISPLAY STREAM str_1 aux_qttotrej aux_vltotrej 
                         WITH FRAME f_total_rejeitados.

                 ASSIGN aux_qttotrej = 0
                        aux_vltotrej = 0.        

             END.
    END.
    
    ASSIGN aux_qttotrej = 0
           aux_qttotrej = 0.
               
    FOR EACH w-craprej WHERE w-craprej.vlfatura > 0
                             NO-LOCK BREAK BY w-craprej.cdcooper
                                              BY w-craprej.nrdconta:
    
        IF   FIRST-OF(w-craprej.cdcooper) THEN
             DISPLAY STREAM str_1 WITH FRAME f_cabec_rejeitados_deb.
        
        IF   LINE-COUNTER(str_1) > 77 THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1 WITH FRAME f_cabec_rejeitados_deb.
             END.

        DISPLAY STREAM str_1 w-craprej WITH FRAME f_rejeitados.
        
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
        
        ASSIGN aux_qttotrej = aux_qttotrej + 1
               aux_vltotrej = aux_vltotrej + w-craprej.vlfatura.
               
        IF   LAST-OF(w-craprej.cdcooper) THEN
             DO:
                 DISPLAY STREAM str_1 aux_qttotrej aux_vltotrej 
                         WITH FRAME f_total_rejeitados.

                 ASSIGN aux_qttotrej = 0
                        aux_vltotrej = 0.  

             END.

    END.
    
    FOR EACH w-craprej:

        DELETE w-craprej.

    END.

END PROCEDURE.

PROCEDURE cria-lau-ctamigrada:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper            NO-UNDO.
    DEF INPUT PARAM par_cdagenci    LIKE    crablot.cdagenci            NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt    LIKE    crablot.cdbccxlt            NO-UNDO.
    DEF INPUT PARAM par_cdbccxpg    LIKE    crablot.cdbccxpg            NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE    crablot.cdhistor            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    LIKE    crablot.dtmvtolt            NO-UNDO.
    DEF INPUT PARAM par_dtmvtopg    LIKE    crablot.dtmvtopg            NO-UNDO.
    DEF INPUT PARAM par_cdpesqbb    AS      DECIMAL                     NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    craptco.nrdconta            NO-UNDO.
    DEF INPUT PARAM par_nrdolote    LIKE    craplot.nrdolote            NO-UNDO.
    DEF INPUT PARAM par_nrdocmto    LIKE    craprej.nrdocmto            NO-UNDO.
    DEF INPUT PARAM par_vllanmto    LIKE    craprej.vllanmto            NO-UNDO.

    CREATE crablau.
    ASSIGN crablau.cdagenci = par_cdagenci
           crablau.cdbccxlt = par_cdbccxlt
           crablau.cdbccxpg = par_cdbccxpg
           crablau.cdcritic = 0               
           crablau.cdhistor = par_cdhistor
           crablau.dtdebito = ?               
           crablau.dtmvtolt = par_dtmvtolt
           crablau.dtmvtopg = par_dtmvtopg
           crablau.insitlau = 3               
           crablau.nrcrcard = par_cdpesqbb
           crablau.nrdconta = par_nrdconta    
           crablau.nrdctabb = par_nrdconta    
           crablau.nrdocmto = par_nrdocmto
           crablau.nrdolote = par_nrdolote
           crablau.nrseqdig = par_nrdocmto
           crablau.nrseqlan = par_nrdocmto                   
           crablau.tpdvalor = 1                   
           crablau.cdseqtel = ""                   
           crablau.vllanaut = IF ( par_vllanmto > 0) THEN
                                 par_vllanmto
                              ELSE
                                 par_vllanmto * -1
           crablau.cdcooper = par_cdcooper.

    VALIDATE crablau.

    RETURN "OK".
END PROCEDURE.


/* ..........................................................................*/

