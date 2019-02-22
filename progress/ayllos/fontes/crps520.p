/*..............................................................................

    Programa: fontes/crps520.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Gabriel
    Data    : Novembro/2008                   Ultima Atualizacao : 26/05/2018
    
    Dados referente ao programa:
    
    Frequencia : Diario (Batch). 
    Objetivo   : Importar os arquivos enviados pela AddMakler com os seguros
                 de Automoveis.

    Alteracoes : 10/03/2009 - Corrigida passagem de paramentro para a BO de
                              email (Gabriel).
                 
                 25/03/2009 - Converter arquivo antes de enviar (Gabriel).
                 
                 15/04/2009 - Incluido critica de "Seguro Antigo" e coluna
                              "Operacao" no relatorio (Elton).

                 20/04/2009 - Considerar seguros antigos na importacao,
                              criticar quando for alterado o tipo de 
                              parcela, incluir e-mail 
                              projetocecred@
                              addmakler.com.br e criticar 
                              importacao com valores negativos (Gabriel).
                              
                 14/07/2010 - Incluida geracao de arquivo de controle para envio
                              de e-mail (GATI - Eder)
                              
                 06/07/2011 - Incluido o e-mail jeicy@cecred.coop.br 
                             (Adriano).             

                 23/12/2011 - Retirar Warnings (Gabriel).
                 
                 23/02/2012 - Alterações para não gerar relatórios crrl496
                              se arquivo vier com campo DETALHE nulo (Lucas).
                              
                 06/02/2013 - Criticar no proc_batch.log caso emails não possam
                              ser enviados (Lucas).
                 
                 19/02/2013 - Incluido o e-mail francys.cavaletti@mdsbr.com.br
                              (Daniele).
                              
                 04/03/2013 - Alterado de lugar onde a variavel aux_flgregis e
                              armazenada como true. Tarefa - 46863 (Lucas R.)
                              
                 04/03/2013 - Substituido e-mail jeicy@cecred.coop.br 
                              por cecredseguros@cecred.coop.br (Daniele).
                 
                 03/06/2013 - Softdesk 66698 - Retirados os seguintes e-mails
                              da lista: luciana.bnu@addmakler.com.br,
                              marilian.bnu@addmakler.com.br e
                              francys.cavaletti@mdsbr.com.br (Carlos).
                              
                28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).              
                              
                13/12/2013 - Incluir VALIDATE crapseg, crawseg (Lucas R.)

			    26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

				21/11/2018 - Alterado busca pelo nrseqdig, para seguros - REMOCAO LOTE

..............................................................................*/

DEF STREAM str_1.  /* Rel496 - Registros importados e rejeitados */
DEF STREAM str_2.  /* Lista de arquivos enviados pela AddMakler  */
DEF STREAM str_3.  /* Arquivo enviado pela AddMakler             */
DEF STREAM str_4.  /* Arquivo de Controle para envio de e-mail   */

{ includes/var_batch.i }

/* Para arquivo */
DEF VAR aux_nmarqimp AS    CHAR   FORMAT "x(21)"                  NO-UNDO.
DEF VAR aux_nomedarq AS    CHAR   FORMAT "x(21)"                  NO-UNDO.
DEF VAR aux_setlinha AS    CHAR                                   NO-UNDO.
DEF VAR aux_qtregist AS    INTE                                   NO-UNDO.
DEF VAR aux_vlpremio AS    DECI                                   NO-UNDO.
DEF VAR aux_flgderro AS    LOGI                                   NO-UNDO.
DEF VAR aux_flgregis AS    LOGI                                   NO-UNDO.
DEF VAR aux_nmarqcon AS    CHAR                                   NO-UNDO.

/* Totais de procesados e rejeitados */
DEF VAR aux_totalpro AS    INT                                    NO-UNDO.
DEF VAR aux_totalrej AS    INT                                    NO-UNDO.

/* variaveis para includes/cabrel132_2.i */
DEF VAR rel_nmresemp AS    CHAR   FORMAT "x(15)"                  NO-UNDO.
DEF VAR rel_nmrelato AS    CHAR   FORMAT "x(40)" EXTENT 5         NO-UNDO.
DEF VAR rel_nrmodulo AS    INTE   FORMAT     "9"                  NO-UNDO.
DEF VAR rel_nmempres AS    CHAR   FORMAT "x(15)"                  NO-UNDO.
DEF VAR rel_nmmodulo AS    CHAR   FORMAT "x(15)" EXTENT 5
                                  INIT ["","","","",""]           NO-UNDO.
/* Enviar por e-mail */
DEF VAR b1wgen0011   AS HANDLE                                    NO-UNDO.

/* Para relatorio 496 */
DEF   TEMP-TABLE w-temp                                           NO-UNDO
      FIELD cdagenci AS    INT
      FIELD nrdconta AS    INT
      FIELD nrctrseg AS    INT
      FIELD dsstatus AS    CHAR
      FIELD dscritic AS    CHAR
      FIELD cdoperac AS    CHAR.  

FORM "Seguro Auto -" aux_nomedarq "- Processado. "
     WITH NO-LABEL FRAME f_processado.

FORM aux_totalpro AT 3 LABEL "Total Processados" FORMAT "z,zzz,zz9"
     aux_totalrej AT 3 LABEL "Total Rejeitados " FORMAT "z,zzz,zz9"
     WITH SIDE-LABELS FRAME f_totais DOWN.

FORM "Seguro Auto -" aux_nomedarq "- Rejeitado - Arquivo em duplicidade."
     WITH WIDTH 132 NO-LABEL FRAME f_dupli.

FORM "Seguro Auto -" aux_nomedarq "- Rejeitado - Divergencia na quantidade" 
     "de registros."
     WITH WIDTH 132 NO-LABEL FRAME f_qtd_erro.

FORM "Seguro Auto -" aux_nomedarq "- Rejeitado - Cooperativa invalida"
     WITH WIDTH 132 NO-LABEL FRAME f_coop_erro.

FORM w-temp.cdagenci COLUMN-LABEL "Pa"          FORMAT "zz9"
     w-temp.nrdconta COLUMN-LABEL "Conta"        FORMAT "zzzz,zzz,9"
     w-temp.nrctrseg COLUMN-LABEL "Contrato"     FORMAT "zz,zzz,zz9"
     w-temp.dsstatus COLUMN-LABEL "Status"       FORMAT "x(12)"
     w-temp.dscritic COLUMN-LABEL "Critica"      FORMAT "x(40)"
     w-temp.cdoperac COLUMN-LABEL "Operacao"     FORMAT "x(13)"  
     WITH WIDTH 132 DOWN FRAME f_status.

glb_cdprogra = "crps520".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN glb_cdcritic    = 0         glb_cdempres  = 11 
       glb_cdrelato[1] = 496       glb_nmarqimp  = "rl/crrl496.lst"
       glb_nmformul    = "132col"  aux_nmarqimp  = "integra/MVSEG*.REM"
       aux_nmarqcon    = "rl/crrl496.txt".
                            
{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE (glb_nmarqimp) PAGED.
OUTPUT STREAM str_4 TO VALUE (aux_nmarqcon).

VIEW STREAM str_1 FRAME f_cabrel132_1.

PUT STREAM str_4 UNFORMATTED 
    " Pa;Conta;Contrato;Status;Critica;Operacao;Data" SKIP.

INPUT STREAM str_2 THROUGH VALUE("ls " + aux_nmarqimp + " 2>/dev/null") NO-ECHO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    /* Para todos os arquivos ... */

   SET STREAM str_2 aux_nomedarq FORMAT "x(70)".

   EMPTY TEMP-TABLE w-temp.
   
   ASSIGN aux_flgregis = TRUE   aux_flgderro = FALSE   aux_vlpremio = 0
          aux_qtregist = 0      aux_totalpro = 0       aux_totalrej = 0      
          aux_nomedarq = SUBSTRING(aux_nomedarq,9).

   IF   CAN-FIND (craplog WHERE 
                  craplog.cdcooper = glb_cdcooper                AND
                  craplog.cdprogra = glb_cdprogra                AND
                  craplog.dstransa = aux_nomedarq + 
                                     " - PROCESSADO COM SUCESSO" NO-LOCK)  THEN
        DO:
            DISPLAY STREAM str_1 aux_nomedarq WITH FRAME f_dupli.
            
            DOWN WITH FRAME f_dupli.

            UNIX SILENT VALUE ("mv integra/" + aux_nomedarq +  " "  +
                               "salvar/ERRMVSEG" + SUBSTR(aux_nomedarq,6)). 

            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")             +
                               " - "   + glb_cdprogra + "' --> '"            +
                               "ARQUIVO " + aux_nomedarq + " ja processado." +
                               " >> log/proc_batch.log").
            NEXT.
   END.
    
   INPUT STREAM str_3 FROM VALUE ("integra/" + aux_nomedarq) NO-ECHO. 

   /* Verifica se consiste trailer com o detalhe */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

      IF  SUBSTRING(aux_setlinha,1,1) = "0"   THEN  /* Verifica cdcooper */
          DO:  
              IF   NOT INT(SUBSTRING(aux_setlinha,2,2)) = crapcop.cdcooper THEN
                   DO: 
                       aux_flgderro = TRUE.
                       UNIX SILENT VALUE("mv integra/" + aux_nomedarq +  " " +
                                         "salvar/ERRMVSEG"            +
                                         SUBSTRING(aux_nomedarq,6)).

                       DISPLAY STREAM str_1 aux_nomedarq WITH FRAME f_coop_erro.
              
                       DOWN WITH FRAME f_coop_erro.
                   
                       LEAVE. 
                   END.
          END.
      ELSE 
      IF  SUBSTRING(aux_setlinha,1,1) = "1"   THEN
          ASSIGN aux_qtregist = aux_qtregist + 1   
                 aux_vlpremio = aux_vlpremio + 
                                DEC(SUBSTR(aux_setlinha,133,11)) / 100
                 aux_flgregis = TRUE. 
      ELSE
      IF  SUBSTRING(aux_setlinha,1,1) = "9"   THEN 
          DO: 
              IF  aux_qtregist <> INTEGER(SUBSTRING(aux_setlinha,2,4)) THEN
                  DO:
                      aux_flgderro = TRUE.
                      UNIX SILENT VALUE("mv integra/" + aux_nomedarq  +  " " +
                                        "salvar/ERRMVSEG"             + 
                                        SUBSTRING(aux_nomedarq,6)).
              
                      DISPLAY STREAM str_1 aux_nomedarq WITH FRAME f_qtd_erro.
                  
                      DOWN WITH FRAME f_qtd_erro. 
                  
                      LEAVE.
                  END.  
              
              IF  aux_qtregist = 0 THEN 
                  DO:
                      UNIX SILENT VALUE("mv integra/" + aux_nomedarq  +  " " +
                                                      "salvar/" + aux_nomedarq).
                  END.
          END.
   END.           

   IF   aux_flgderro OR aux_qtregist = 0 THEN  NEXT.

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                      craplot.dtmvtolt = glb_dtmvtolt  AND
                      craplot.cdagenci = 1             AND
                      craplot.cdbccxlt = 100           AND
                      craplot.nrdolote = 10116         NO-LOCK NO-ERROR.
   
   
   IF   NOT AVAILABLE craplot   THEN
        DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = glb_cdcooper
                   craplot.dtmvtolt = glb_dtmvtolt
                   craplot.cdagenci = 1
                   craplot.cdbccxlt = 100
                   craplot.nrdolote = 10116
                   craplot.tplotmov = 1
                   craplot.cdhistor = 586.
        END.

   ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtcompln = aux_qtregist
          craplot.qtinfoln = aux_qtregist
          craplot.vlcompdb = aux_vlpremio
          craplot.vlinfodb = aux_vlpremio
          craplot.flgltsis = TRUE.*/
		  
          
   VALIDATE craplot.

   INPUT STREAM str_3 FROM VALUE ("integra/" + aux_nomedarq) NO-ECHO. 

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
      IMPORT STREAM str_3 UNFORMATTED aux_setlinha.  

      /* Se nao eh Detalhe do arquivo, proximo ... */ 
      IF   NOT CAN-DO ("1",SUBSTRING(aux_setlinha,1,1))   THEN   NEXT.

      CREATE w-temp.
      ASSIGN w-temp.cdagenci = INT(SUBSTRING(aux_setlinha,3,3))
             w-temp.nrdconta = INT(SUBSTRING(aux_setlinha,6,8))
             w-temp.nrctrseg = IF  INT(SUBSTR(aux_setlinha,170,8)) <> 0  THEN
                                   INT(SUBSTR(aux_setlinha,170,8))
                               ELSE       
                                   INT(SUBSTR(aux_setlinha,14,8))   
             w-temp.cdoperac = IF  SUBSTR(aux_setlinha,2,1) = "I"   THEN
                                   IF   SUBSTR(aux_setlinha,178,1) = "1"   THEN
                                        "Inclusao" 
                                   ELSE
                                        "Substituicao"
                               ELSE 
                                   "Alteracao" NO-ERROR.
 
      IF   ERROR-STATUS:ERROR   THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Caracter invalido".
           END.
      ELSE
      IF   NOT CAN-FIND(crapage WHERE 
                        crapage.cdcooper = glb_cdcooper      AND
                        crapage.cdagenci = w-temp.cdagenci   NO-LOCK)   THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado" 
                      w-temp.dscritic = "Pa invalido". /*pa do atendente*/
           END.
      ELSE
      IF   NOT CAN-FIND(crapass WHERE 
                        crapass.cdcooper = glb_cdcooper      AND
                        crapass.nrdconta = w-temp.nrdconta   NO-LOCK)   THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Conta invalida".
           END.
      ELSE
      IF   NOT CAN-FIND(crapcsg WHERE
                        crapcsg.cdcooper = glb_cdcooper      AND
                        crapcsg.cdsegura = INT(SUBSTR(aux_setlinha,208,9))
                                                             NO-LOCK)   THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Seguradora invalida".      
           END.              
      ELSE
      IF   NOT SUBSTRING(aux_setlinha,160,2) = "02"            THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Tipo de seguro invalido".
           END.
      ELSE
      IF   NOT CAN-DO("I,A",SUBSTRING(aux_setlinha,2,1))       THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Opcao invalida".
           END.
      ELSE
      IF   NOT CAN-DO("T,F",SUBSTRING(aux_setlinha,187,1))     THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"
                      w-temp.dscritic = "Tipo de parcela invalida".
           END.
      ELSE
      IF   DEC(SUBSTR(aux_setlinha,133,11)) / 100 < 0          OR
           DEC(SUBSTR(aux_setlinha,146,14)) / 100 < 0          THEN
           DO:
               ASSIGN w-temp.dsstatus = "Rejeitado"         /* Valor Premio */
                      w-temp.dscritic = "Valor negativo".   /* Valor parcela */
           END.
      ELSE
           DO:    
               RUN proc_arquivo.
           END. 
                                     
      IF   w-temp.dsstatus = "Processado"   THEN                      
           aux_totalpro = aux_totalpro + 1.
      ELSE
           aux_totalrej = aux_totalrej + 1.              
                                        
   END.  /* Fim DO WHILE TRUE  - Importacao arquivo */   

   FOR EACH w-temp NO-LOCK BY w-temp.cdagenci BY w-temp.nrdconta:
    
       DISPLAY STREAM str_1 w-temp WITH DOWN FRAME f_status.
       DOWN WITH FRAME f_status. 

       PUT STREAM str_4 UNFORMATTED
           STRING(w-temp.cdagenci,">>9")        ";"
           STRING(w-temp.nrdconta,">>>>>>>9")   ";"
           STRING(w-temp.nrctrseg,">>>>>>>9")   ";"
           STRING(w-temp.dsstatus,"X(12)")      ";"
           STRING(w-temp.dscritic,"X(40)")      ";"
           STRING(w-temp.cdoperac,"X(13)")      ";"
           STRING(glb_dtmvtolt,"99/99/9999")  SKIP.
      
   END. /* Tabela w-temp Somente usada para ordenar por PA e conta */

   DISPLAY STREAM str_1 aux_totalpro aux_totalrej WITH FRAME f_totais.

   DOWN STREAM str_1 WITH FRAME f_totais. 
   
   DISPLAY STREAM str_1 aux_nomedarq WITH FRAME f_processado.
   
   DOWN WITH FRAME f_processado. 

   RUN fontes/gera_log.p (INPUT glb_cdcooper,
                          INPUT 0,
                          INPUT "",
                          STRING(aux_nomedarq) + " - PROCESSADO COM SUCESSO",
                          INPUT glb_cdprogra). 

   UNIX SILENT VALUE ("mv integra/" + aux_nomedarq + " salvar/" + aux_nomedarq).

END. /* Fim importacao dos arquivos */

OUTPUT STREAM str_1 CLOSE.
OUTPUT STREAM str_4 CLOSE.

IF   NOT aux_flgregis   THEN   /* Se nao importou nada , retorna */
     DO:  
         UNIX SILENT VALUE ("rm " + glb_nmarqimp).
         UNIX SILENT VALUE ("rm " + aux_nmarqcon).
         RUN fontes/fimprg.p.
         RETURN.
     END.

RUN fontes/imprim.p.

RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET b1wgen0011.
         
IF   VALID-HANDLE (b1wgen0011)   THEN
     DO:
         RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                             INPUT glb_nmarqimp,
                                             INPUT "crrl496.doc").
                      
         IF   aux_flgderro  THEN  
              DO:
                   UNIX SILENT VALUE ("rm " + aux_nmarqcon).
                   
                   RUN enviar_email IN b1wgen0011
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "projetocecred@addmakler.com.br," +
                                        "cecredseguros@ailos.coop.br",
                                  INPUT "Seguros Auto", 
                                  INPUT "crrl496.doc",
                                  INPUT TRUE). 
              END.
         ELSE
              DO:
                  RUN converte_arquivo IN b1wgen0011(INPUT glb_cdcooper,
                                                     INPUT aux_nmarqcon,
                                                     INPUT "crrl496.txt").

                  RUN enviar_email IN b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "projetocecred@addmakler.com.br," +
                                         "cecredseguros@ailos.coop.br",
                                   INPUT "Seguros Auto", 
                                   INPUT "crrl496.doc;crrl496.txt",
                                   INPUT TRUE). 
              END.  

         DELETE PROCEDURE b1wgen0011.
     
     END.
ELSE
     DO:
         ASSIGN glb_dscritic = "Nao foi possivel enviar emails. HANDLE invalido.".
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p.

PROCEDURE proc_arquivo:
    
   IF   SUBSTRING(aux_setlinha,2,1) = "I"   THEN  
        DO:
       
                 /* Ativo ou substituido */
            IF   NOT CAN-DO ("1,3",SUBSTRING(aux_setlinha,178,1))   THEN
                 DO:
                     ASSIGN w-temp.dsstatus = "Rejeitado"
                            w-temp.dscritic = "Situacao invalida.".
                     RETURN.
                 END.
            
            IF   SUBSTRING(aux_setlinha,178,1) = "3"   THEN  
                 DO:     
                    RUN proc_substituir.
                 END.
            ELSE                                 
                 DO:                                         
                    RUN proc_incluir.
                 END.
        END.
   ELSE      
        DO:      /* Ativo ou Cancelado */
            IF   NOT CAN-DO ("1,2",SUBSTRING(aux_setlinha,178,1))   THEN
                 DO:
                     ASSIGN w-temp.dsstatus = "Rejeitado"
                            w-temp.dscritic = "Situacao invalida.".
                     RETURN.
                 END.
            
            RUN proc_altera.            
        END.

   IF   RETURN-VALUE = "NOK"   THEN   RETURN.             
   
   ASSIGN crawseg.nmdsegur = SUBSTR(aux_setlinha,22,40)
          crawseg.dsmarvei = SUBSTR(aux_setlinha,62,20)
          crawseg.dstipvei = SUBSTR(aux_setlinha,82,20)
          crawseg.nranovei = INTE(SUBSTR(aux_setlinha,102,4))
          crawseg.nrmodvei = INTE(SUBSTR(aux_setlinha,106,4)) 
          crawseg.nrdplaca = SUBSTR(aux_setlinha,110,7)  
          crawseg.dtinivig = DATE(SUBSTR(aux_setlinha,117,8))
          crawseg.dtfimvig = DATE(SUBSTR(aux_setlinha,125,8))
          crawseg.vlpremio = DEC(SUBSTR(aux_setlinha,133,11)) / 100
          crawseg.qtparcel = INTE(SUBSTR(aux_setlinha,144,2))
          crawseg.vlpreseg = DEC(SUBSTR(aux_setlinha,146,14)) / 100
          crawseg.dtdebito = DATE(SUBSTR(aux_setlinha,162,8))   
          crawseg.dschassi = SUBSTR(aux_setlinha,188,20)
          crawseg.cdsegura = INTE(SUBSTR(aux_setlinha,208,9))
          crawseg.dtmvtolt = glb_dtmvtolt
          crawseg.flgunica = IF   SUBSTR(aux_setlinha,187,1) = "T" THEN   TRUE
                             ELSE 
                                  FALSE
          crapseg.dtinivig = crawseg.dtinivig
          crapseg.dtfimvig = crawseg.dtfimvig
          crapseg.dtdebito = crawseg.dtdebito
          crapseg.vlpremio = crawseg.vlpremio
          crapseg.qtparcel = crawseg.qtparcel
          crapseg.vlpreseg = crawseg.vlpreseg
          crapseg.flgunica = crawseg.flgunica
          crapseg.cdsegura = crawseg.cdsegura
          crapseg.dtcancel = DATE(SUBSTR(aux_setlinha,179,8)) NO-ERROR. 
          
   IF   ERROR-STATUS:ERROR   THEN
        DO:
            ASSIGN w-temp.dsstatus = "Rejeitado"
                   w-temp.dscritic = "Caracter invalido".
            UNDO.
        END.   
                                              
   w-temp.dsstatus  = "Processado".

END PROCEDURE.  /* Fim Procedure generica para cada registro */

PROCEDURE proc_substituir:
                   
   FIND crawseg WHERE crawseg.cdcooper = glb_cdcooper      AND
                      crawseg.nrdconta = w-temp.nrdconta   AND
                      crawseg.nrctrseg = w-temp.nrctrseg   
                      EXCLUSIVE-LOCK NO-ERROR.
                                            
   FIND crapseg WHERE crapseg.cdcooper = glb_cdcooper      AND
                      crapseg.nrdconta = w-temp.nrdconta   AND
                      crapseg.nrctrseg = w-temp.nrctrseg   AND
                      crapseg.tpseguro = 2
                      EXCLUSIVE-LOCK NO-ERROR.
         
   IF   NOT AVAILABLE crawseg   OR   NOT AVAILABLE crapseg   THEN
        DO:
            ASSIGN w-temp.dsstatus = "Rejeitado"
                   w-temp.dscritic = "Contrato inexistente".
            RETURN "NOK".
        END.

   ASSIGN crawseg.nrctratu = INT(SUBSTR(aux_setlinha,14,8))
           
          crapseg.nrctratu = crawseg.nrctratu
          crapseg.cdsitseg = 3                 /* Substituido  */
           
          w-temp.nrctrseg  = INT(SUBSTR(aux_setlinha,14,8)).
           
   RUN proc_incluir.

   IF   RETURN-VALUE = "NOK"   THEN         
        DO:
            UNDO, RETURN "NOK".
        END.

END PROCEDURE.  /* Fim Procedure de Substituicao */

PROCEDURE proc_incluir:

    DEFINE VAR aux_nrseqdig AS INT INIT 1   NO-UNDO.

    IF   CAN-FIND (crawseg WHERE crawseg.cdcooper = glb_cdcooper       AND
                                 crawseg.nrdconta = w-temp.nrdconta    AND
                                 crawseg.nrctrseg = w-temp.nrctrseg)   THEN
         DO:
              ASSIGN w-temp.dsstatus = "Rejeitado"
                     w-temp.dscritic = "Contrato ja existente".
              RETURN "NOK".                    
         END.                        
    
    /* So para achar ultima nrseqdig e nao dar erro na chave unica crapseg3 */
    FOR EACH crapseg WHERE crapseg.cdcooper = glb_cdcooper      AND
                           crapseg.dtmvtolt = glb_dtmvtolt      AND
                           crapseg.cdagenci = w-temp.cdagenci   AND
                           crapseg.cdbccxlt = 100               AND
                           crapseg.nrdolote = 10116             NO-LOCK
                           BREAK BY crapseg.nrseqdig:     
                                            
        IF   LAST-OF(crapseg.nrseqdig)   THEN
             aux_nrseqdig = crapseg.nrseqdig + 1.
            
    END.

    CREATE crapseg.
    ASSIGN crapseg.cdcooper = glb_cdcooper
           crapseg.nrdconta = w-temp.nrdconta
           crapseg.nrctrseg = w-temp.nrctrseg
           crapseg.cdagenci = w-temp.cdagenci
           crapseg.dtmvtolt = glb_dtmvtolt
           crapseg.nrseqdig = aux_nrseqdig
           crapseg.tpseguro = 2
           crapseg.dtiniseg = DATE(SUBSTR(aux_setlinha,117,8))
           crapseg.cdbccxlt = 100
           crapseg.nrdolote = 10116     
           crapseg.dtprideb = DATE(SUBSTR(aux_setlinha,162,8))
           crapseg.flgconve = TRUE
           crapseg.cdsitseg = 1.    /* Ativo */
           
    CREATE crawseg.    
    ASSIGN crawseg.cdcooper = glb_cdcooper
           crawseg.nrdconta = w-temp.nrdconta
           crawseg.nrctrseg = w-temp.nrctrseg
           crawseg.tpseguro = 2
           crawseg.dtmvtolt = glb_dtmvtolt
           crawseg.dtprideb = crapseg.dtprideb
           crawseg.dtiniseg = DATE(SUBSTR(aux_setlinha,117,8))
           crawseg.flgconve = TRUE.
    
    IF   SUBSTRING(aux_setlinha,178,1) = "3"   THEN
         ASSIGN crawseg.lsctrant = TRIM(SUBSTR(aux_setlinha,170,8))
                                     
                crapseg.lsctrant = TRIM(SUBSTR(aux_setlinha,170,8)).

    VALIDATE crapseg.
    VALIDATE crawseg.

END PROCEDURE. /* Fim Procedure de inclusao */

PROCEDURE proc_altera:
    
    FIND crawseg WHERE crawseg.cdcooper = glb_cdcooper      AND
                       crawseg.nrdconta = w-temp.nrdconta   AND
                       crawseg.nrctrseg = w-temp.nrctrseg  
                       EXCLUSIVE-LOCK NO-ERROR.
                                            
    FIND crapseg WHERE crapseg.cdcooper = glb_cdcooper      AND
                       crapseg.nrdconta = w-temp.nrdconta   AND
                       crapseg.nrctrseg = w-temp.nrctrseg   AND
                       crapseg.tpseguro = 2
                       EXCLUSIVE-LOCK NO-ERROR.
           
    IF   NOT AVAILABLE crawseg   OR   NOT AVAILABLE crapseg   THEN
         DO:
             ASSIGN w-temp.dsstatus = "Rejeitado"
                    w-temp.dscritic = "Contrato inexistente".
             RETURN "NOK".
         END.
             
    IF   (crapseg.flgunica       AND  SUBSTR(aux_setlinha,187,1) <> "T")   OR
  
         (NOT crapseg.flgunica   AND  SUBSTR(aux_setlinha,187,1) <> "F")   THEN
         
         DO:
             ASSIGN w-temp.dsstatus = "Rejeitado"
                    w-temp.dscritic = "Tipo de parcela nao pode ser alterado".
             RETURN "NOK".       
         END.
    
    ASSIGN crapseg.dtaltseg = glb_dtmvtolt
           crapseg.cdsitseg = INTE(SUBSTR(aux_setlinha,178,1)).

END PROCEDURE.  /* Fim Procedure de alteracao */
                         
/*............................................................................*/

