/* ..........................................................................

   Programa: fontes/crps422.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004                     Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivo com MOVIMENTO PARA CARTAO DE CREDITO (COO410) dos
               associados para enviar ao Banco do Brasil.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               
               22/11/2005 - Acerto final cartao de credito(Mirtes)
               
               16/02/2006 - Ajustes ao layout (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               20/06/2006 - Incluido Registro Tipo 16 - Cartoes Encerrados
                            (Diego).
                            
               30/06/2006 - Modificado para enviar registro somente 3 dias
                            apos a inclusao (Diego).
                            
               28/07/2006 - Copiar o relatorio de enviados para o diretorio
                            "rlnsv" (Evandro).

               22/09/2006 - Incluido Registro tipo 15 - Alteracao de Limite de
                            Credito (Diego).
                            
               13/04/2007 - Corrigito tipo 16 para bloquear portador (Evandro).

               27/04/2007 - Alterado Indicador Remessa Correio para N(Mirtes)
                            Tarefa 11284

               03/05/2007 - Enviar crrl384 para email da Makelly e Rosangela.
                            Postar crrl384 na Intranet (David).
               
               05/07/2007 - Retirando o envio do relatorio crrl384 para o email
                            da Rosangela (Guilherme).
                            
               30/01/2008 - Envio de arquivo de desbloqueio de cartao p/ o BB
                            (Guilherme).
                            
               21/02/2008 - Incluidas as colunas "Movimentacao" e "Situacao" no
                            relatorio (Evandro).
                            
               04/04/2008 - Enviar tambem "Limite do cartao" quando houver
                            Desbloqueio (Diego).

               13/05/2008 - Alterado para envio de valor zerado no cartao da 
                            conta - 281611 (Somente funcao debito)
        
               12/06/2008 - Alterado campo de totalizacao (Gabriel).

               30/07/2008 - Alterada listagem, removidas as colunas "Adm" e
                            "Tit" e incluida listagem das contas sem conta
                            cartao (Gabriel).

               11/08/2008 - Alterado para nao pular pagina quando lista as sem
                            conta-cartao e incluir linha tracejada (Gabriel).
   
               03/09/2008 - Corrigida leitura para os cartoes sem conta cartao.
                            Mandar email para o luiz fernando e adicionada 
                            coluna de data de solicitacao nos sem conta cartao
                            (Gabriel).
                            
               29/04/2009 - Utilizar glb_cdcooper no FIND do crapfer (David).
               
               21/02/2011 - Encerramento de conta - Cartão Banco do Brasil
                            (Isara - RKAM)
                            
               06/06/2011 - Incluso registro tipo 97 (Vinculação Endereço ITG)
                            (Michel - RKAM)
                
               07/10/2011 - Retirado o campo "Proposta" e incluido o campo
                            "Modalidade" (Henrique).
                          - Alterado para enviar o relatorio para a intranet 
                            da CECRED (Henrique).
                            
               18/10/2011 - Alterado para limpar os registros antigos do 
                            crapeca ao processar o cartao (Henrique).
                          - Removido tratamento para envio de valor zerado para
                            a conta 281611 (Henrique).
                            
               19/04/2012 - Retirado numero e nome do PAC acima das solicitações.
                            Incluído coluna PAC e seu respectivo número nas
                            solicitações (Guilherme Maba).
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               24/01/2014 - Incluir VALIDATE crapeca (Lucas R.)
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa) 

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

............................................................................ */

{ includes/var_batch.i }

DEF STREAM str_1.

DEF     VAR b1wgen0011   AS HANDLE                                   NO-UNDO.

DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(150)"                NO-UNDO.
DEF     VAR aux_nmarqenv AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqcen AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmresadm AS CHAR      FORMAT "x(20)"                 NO-UNDO.
DEF     VAR aux_contdate AS DATE                                     NO-UNDO.
DEF     VAR aux_datatual AS DATE                                     NO-UNDO.
DEF     VAR aux_nrtextab AS INTE                                     NO-UNDO.
DEF     VAR aux_nrregist AS INTE                                     NO-UNDO.
DEF     VAR aux_nrsequen AS INTE                                     NO-UNDO.
DEF     VAR aux_nrdconta AS INTE                                     NO-UNDO.
DEF     VAR aux_contsoli AS INTE                                     NO-UNDO.
DEF     VAR aux_contctma AS INTE                                     NO-UNDO.
DEF     VAR aux_contlimi AS INTE                                     NO-UNDO.
DEF     VAR aux_contdesb AS INTE                                     NO-UNDO.
DEF     VAR aux_contacan AS INTE                                     NO-UNDO.
DEF     VAR aux_contaenc AS INTE                                     NO-UNDO.
DEF     VAR aux_qtdiasut AS INTE                                     NO-UNDO.
DEF     VAR aux_contador AS INTE                                     NO-UNDO.
DEF     VAR aux_flgerros AS LOGICAL                                  NO-UNDO.
DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.
DEF     VAR aux_valor    LIKE craptlc.vllimcrd                       NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DEF     VAR rel_nmempres AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmresemp AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmrelato AS CHAR      FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF     VAR rel_nrmodulo AS INT       FORMAT "9"                     NO-UNDO.
DEF     VAR rel_nmmodulo AS CHAR      FORMAT "x(15)" EXTENT 5
                                      INIT ["DEP. A VISTA   ","CAPITAL        ",
                                            "EMPRESTIMOS    ","DIGITACAO      ",
                                            "GENERICO       "]       NO-UNDO.

/* para os que foram enviados */
DEF TEMP-TABLE w_enviados                                            NO-UNDO
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmtitcrd LIKE crawcrd.nmtitcrd
    FIELD nrctrcrd LIKE crawcrd.nrctrcrd
    FIELD dtsolici LIKE crawcrd.dtsolici
    FIELD flgcnmae AS   LOG
    FIELD tpregist AS   INT
    FIELD cdmovmto AS   INT
    FIELD dsmovmto AS   CHAR
    FIELD dssitcrd AS   CHAR
    FIELD nmresadm AS   CHAR
    INDEX w_enviados1
          tpregist
          cdagenci
          nrdconta.

/* para "organizar" a leitura das propostas de cartao aprovadas */
DEF TEMP-TABLE wcartao                                               NO-UNDO
    FIELD cdcooper   LIKE crapass.cdcooper
    FIELD nrdconta   LIKE crawcrd.nrdconta
    FIELD dtsolici   LIKE crawcrd.dtsolici
    FIELD cdadmcrd   LIKE crawcrd.cdadmcrd
    FIELD flctamae   AS   LOG
    FIELD nrsequen   AS   INT
    FIELD nrdrecid   AS   RECID
    INDEX ch-wcartao AS   PRIMARY 
          nrdconta
          nrsequen
          cdadmcrd.

FORM w_enviados.cdagenci    AT   2  LABEL "PA"
     w_enviados.nrdconta    AT   6  LABEL "Conta/DV"
     w_enviados.nrdctitg    AT  17  LABEL "Conta de Integracao"
     w_enviados.nmtitcrd    AT  37  LABEL "Nome do Titular"
     w_enviados.nmresadm    AT  78  LABEL "Modalidade"     FORMAT "x(18)"
     w_enviados.dsmovmto    AT  97  LABEL "Movimentacao"   FORMAT "x(12)"
     w_enviados.dssitcrd    AT 110  LABEL "Situacao"
     WITH DOWN NO-LABELS WIDTH 132  FRAME f_enviados.

FORM w_enviados.cdagenci    AT   2  LABEL "PA"
     w_enviados.nrdconta    AT   6  LABEL "Conta/DV"           
     w_enviados.nrdctitg    AT  17  LABEL "Conta de Integracao"
     w_enviados.nmtitcrd    AT  37  LABEL "Nome do Titular"
     w_enviados.nmresadm    AT  78  LABEL "Modalidade"     FORMAT "x(18)"
     w_enviados.dsmovmto    AT  97  LABEL "Movimentacao"   FORMAT "x(12)"
     w_enviados.dssitcrd    AT 110  LABEL "Situacao"
     w_enviados.dtsolici    AT 119  LABEL "Solicitacao"    FORMAT "99/99/9999"
     WITH DOWN NO-LABELS WIDTH 132  FRAME f_enviados_sem_conta_cartao.

DEF     VAR aux_nmarqlog      AS CHAR                                NO-UNDO.

ASSIGN glb_cdprogra = "crps422"
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

/* limpar a temp-table */
EMPTY TEMP-TABLE wcartao.

/* Verifica o bloqueio do arquivo */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "NRARQMVITG"   AND
                   craptab.tpregist = 410            NO-LOCK NO-ERROR.

IF   NOT AVAIL craptab   THEN
     DO:
          glb_cdcritic = 393.
          RUN fontes/critic.p. 
          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +    
                            " - " + glb_cdprogra + "' --> '"  +    
                            glb_dscritic + " >> " + aux_nmarqlog). 

          RUN fontes/fimprg.p. 
          RETURN.
     END.    
ELSE
     IF INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
        DO:
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - COO410 - " + glb_cdprogra + "' --> '"  +
                             "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                             " >> " + aux_nmarqlog).

              
            RUN fontes/fimprg.p. 
            RETURN.
        END.
 
RUN abre_arquivo. 

ASSIGN aux_datatual = glb_dtmvtolt
       aux_qtdiasut = 0.

/*  Procura pelo 3 dia util anterior */
DO WHILE aux_qtdiasut < 3:

   ASSIGN aux_datatual = aux_datatual - 1.
   
   IF   LOOKUP(STRING(WEEKDAY(aux_datatual)),"1,7") <> 0        OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND 
                               crapfer.dtferiad = aux_datatual) THEN
        NEXT.

   ASSIGN aux_qtdiasut = aux_qtdiasut + 1.

END.

FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper  AND   
                      (crawcrd.flgctitg = 0             OR  /* Nao enviado  */
                       crawcrd.flgctitg = 4)            AND /* Reprocessado */
                       crawcrd.insitcrd = 1             AND /* Aprovado     */
                       CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd)) AND
                       crawcrd.dtpropos <= aux_datatual NO-LOCK:
    CASE crawcrd.cdgraupr:
        WHEN 1 THEN aux_nrsequen = 3.  /* Conjuge */
        WHEN 3 THEN aux_nrsequen = 4.  /* Filhos */
        WHEN 4 THEN aux_nrsequen = 5.  /* Companheiro */
        WHEN 5 THEN aux_nrsequen = 1.  /* Primeiro titular */
        WHEN 6 THEN aux_nrsequen = 2.  /* Segundo titular */
    END.
        
    CREATE wcartao.
    ASSIGN wcartao.nrdconta = crawcrd.nrdconta
           wcartao.cdadmcrd = crawcrd.cdadmcrd
           wcartao.nrsequen = aux_nrsequen
           wcartao.nrdrecid = RECID(crawcrd)
           wcartao.flctamae = TRUE.
END.


FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper   AND
                      (crawcrd.flgctitg = 1              OR      /* Enviada */
                       crawcrd.flgctitg = 4)             AND  /* Reprocessado */
                       crawcrd.insitcrd = 1              AND
                       CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd)) AND
                       crawcrd.dtpropos <= aux_datatual  NO-LOCK: 

    CASE crawcrd.cdgraupr:
         WHEN 1 THEN aux_nrsequen = 3.  /* Conjuge */
         WHEN 3 THEN aux_nrsequen = 4.  /* Filhos */
         WHEN 4 THEN aux_nrsequen = 5.  /* Companheiro */
         WHEN 5 THEN aux_nrsequen = 1.  /* Primeiro titular */
         WHEN 6 THEN aux_nrsequen = 2.  /* Segundo titular */
    END.

    ASSIGN aux_contdate = crawcrd.dtsolici  /* Solicitacao */
           aux_contador = 0.

    DO WHILE aux_contador < 5:   /* 5 dias uteis apos a Solicit.*/

       ASSIGN aux_contdate = aux_contdate + 1.
                      
       IF   CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                   crapfer.dtferiad = aux_contdate) OR
            CAN-DO  ("1,7",STRING(WEEKDAY(aux_contdate)))           THEN
            NEXT.
            
       aux_contador = aux_contador + 1.
                   
    END.
    IF   glb_dtmvtolt > aux_contdate   THEN    
         DO:   
             CREATE wcartao.
      
             ASSIGN wcartao.nrdconta = crawcrd.nrdconta
                    wcartao.cdadmcrd = crawcrd.cdadmcrd
                    wcartao.dtsolici = crawcrd.dtsolici
                    wcartao.nrsequen = aux_nrsequen
                    wcartao.nrdrecid = RECID(crawcrd)
                    wcartao.flctamae = FALSE.  /* Sem conta-cartao */
         END. 
END.

FOR EACH wcartao NO-LOCK BREAK BY wcartao.nrdconta
                                  BY wcartao.cdadmcrd
                                     BY wcartao.nrsequen TRANSACTION:
    
    /* Retirar criticas das contas com cartoes solicitados */
    FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper      
                       AND crapeca.nrdconta = wcartao.nrdconta  
                       AND crapeca.tparquiv = 510               
                       EXCLUSIVE-LOCK:
        DELETE crapeca.
    END.

    FIND crawcrd WHERE RECID(crawcrd) = wcartao.nrdrecid NO-ERROR.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                       crapass.nrdconta = crawcrd.nrdconta NO-LOCK NO-ERROR.
    
    FIND FIRST craptlc WHERE craptlc.cdcooper = glb_cdcooper       AND 
                             craptlc.cdadmcrd = crawcrd.cdadmcrd   AND
                             craptlc.cdlimcrd = crawcrd.cdlimcrd   
                             NO-LOCK NO-ERROR.
     
    IF   FIRST-OF(wcartao.nrdconta)   AND 
         FIRST-OF(wcartao.cdadmcrd)  THEN
         DO:
            ASSIGN aux_nrdconta = 0
                   aux_flgerros = NO
                   aux_valor =  craptlc.vllimcrd.

            IF   wcartao.nrsequen = 1   THEN
                 DO:
                    /* registro tipo 13 */
                    ASSIGN aux_nrregist = aux_nrregist + 1
                           aux_nrdconta = wcartao.nrdconta
                           aux_nrdctitg = SUBSTRING(crapass.nrdctitg,1,7)
                           aux_dsdlinha = STRING(aux_nrregist,"99999")        +
                                          "13"                                +
                                          STRING(crawcrd.cdadmcrd,"99")       +
                                          STRING(crawcrd.dddebito,"99")       +
                                          "S"                                 +
                                          STRING(crapcop.cdageitg,"9999")     +
                                          " "                                 +
                                          STRING(INTEGER(aux_nrdctitg),
                                                              "99999999999")  +
                                          " NNN"                              +
                                          STRING(crawcrd.nmtitcrd,"x(19)")    +
                                          "00000000"                          +
                                          STRING(INTE(aux_valor),
                                                                "999999999")  +
                                          STRING(crapass.nrdconta,"99999999").
                                          /* o restante sao brancos */
                    
                    PUT STREAM str_1  aux_dsdlinha SKIP.
                    
                    /* registro tipo 97 */
                    ASSIGN aux_nrregist = aux_nrregist + 1
                           aux_nrdctitg = SUBSTRING(crapass.nrdctitg,1,7)

                           aux_dsdlinha = STRING(aux_nrregist,"99999")        +
                                          "97"                                +
                                          STRING(crapcop.cdageitg,"9999")     +
                                          STRING(INTEGER(aux_nrdctitg),
                                                              "99999999999").
                                          /* o restante sao brancos */

                    PUT STREAM str_1  aux_dsdlinha SKIP.
                 END.
            ELSE
                 DO:
                    FIND FIRST crawcrd WHERE 
                               crawcrd.cdcooper = glb_cdcooper       AND
                               crawcrd.nrdconta = wcartao.nrdconta   AND
                               crawcrd.cdgraupr = 5                  AND
                               crawcrd.cdadmcrd = wcartao.cdadmcrd
                               NO-LOCK NO-ERROR.
                               
                    IF   NOT AVAILABLE crawcrd   THEN
                         DO:
                            ASSIGN aux_flgerros = YES.
                            
                            CREATE crapeca.
                            ASSIGN crapeca.nrdconta = crapass.nrdconta
                                   crapeca.tparquiv = 510
                                   crapeca.idseqttl = 2
                                   crapeca.dscritic = "Cartao do 1o titular " +
                                                      "ainda nao foi " +
                                                      "cadastrado."
                                   crapeca.cdcooper = glb_cdcooper.
                            VALIDATE crapeca.
                            NEXT.
                         END.
                 END.
         END.
    
    IF   wcartao.nrsequen <> 1   THEN
         DO:
            IF   aux_nrdconta <> 0   THEN
                 DO: 
                    /* registro tipo 14 - sem o numero da conta cartao
                       porque esta sendo cadastrado junto com o 1o titular */
                    ASSIGN aux_nrregist = aux_nrregist + 1
                           aux_nrdctitg = SUBSTRING(crapass.nrdctitg,1,7)
                           aux_dsdlinha = STRING(aux_nrregist,"99999")    +
                                          "14"                            +
                                          STRING(crapass.nrcpfcgc,
                                                 "99999999999")           +
                                          STRING(crawcrd.nmtitcrd,
                                                 "x(19)")                 +
                                          STRING(crapcop.cdageitg,"9999") +
                                          " "                             +
                                          STRING(INTEGER(aux_nrdctitg),
                                                 "99999999999")           +
                                          "  000000000"                   +
                                          "         "                     +
                                          STRING(crawcrd.cdadmcrd,"99")   +
                                          STRING(crawcrd.nrcpftit,
                                                 "99999999999")           +
                                          STRING(crapass.nrdconta,
                                                 "99999999").
                                          /* o restante sao brancos */
                     
                    PUT STREAM str_1  aux_dsdlinha SKIP.
                 END.
            ELSE
                 IF   NOT aux_flgerros   THEN
                      DO:
                          /* registro tipo 14 - com o numero da conta
                             cartao - 1o titular ja foi cadastrado*/
                          ASSIGN aux_nrregist = aux_nrregist + 1
                                 aux_nrdctitg = SUBSTRING(crapass.nrdctitg,1,7)
                                 aux_dsdlinha = 
                                          STRING(aux_nrregist,"99999")    +
                                          "14"                            +
                                          STRING(crapass.nrcpfcgc,
                                                 "99999999999")           +
                                          STRING(crawcrd.nmtitcrd,
                                                 "x(19)")                 +
                                          STRING(crapcop.cdageitg,"9999") + 
                                          " "                             +
                                          STRING(INTEGER(aux_nrdctitg),
                                                 "99999999999")           +
                                          "  000000000"                   +
                                          STRING(crawcrd.nrcctitg,
                                                 "999999999")             +
                                          STRING(crawcrd.cdadmcrd,"99")   +
                                          STRING(crawcrd.nrcpftit,
                                                 "99999999999")           +
                                          STRING(crapass.nrdconta,
                                                 "99999999").
                                          /* o restante sao brancos */
         
                          PUT STREAM str_1  aux_dsdlinha SKIP.
                                          
                      END.
         END.
    
    /* Busca a modalidade do cartao */
    FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper
                   AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                   NO-LOCK NO-ERROR.

    IF  AVAIL crapadc THEN
        ASSIGN aux_nmresadm = crapadc.nmresadm.
    ELSE
        ASSIGN aux_nmresadm = "".

    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.nrdctitg = crapass.nrdctitg
           w_enviados.nmtitcrd = crawcrd.nmtitcrd
           w_enviados.nrctrcrd = crawcrd.nrctrcrd
           w_enviados.tpregist = 1
           w_enviados.cdmovmto = 1
           w_enviados.dsmovmto = "Solicitacao"
           w_enviados.flgcnmae = wcartao.flctamae
           w_enviados.dtsolici = wcartao.dtsolici
           w_enviados.dssitcrd = IF   crawcrd.flgctitg = 0 THEN
                                      "ENV."
                                 ELSE
                                      "REENV."
           w_enviados.nmresadm = aux_nmresadm
           aux_contsoli        = aux_contsoli + 1 WHEN wcartao.flctamae
           aux_contctma        = aux_contctma + 1 WHEN NOT wcartao.flctamae.
                                                       /*Sem conta-cartao*/
       
    /* atualizacao da tabela */
    ASSIGN crawcrd.flgctitg = 1  /* enviado */
           crawcrd.dtsolici = glb_dtmvtolt.

    RELEASE crawcrd.
END.

RUN fecha_arquivo. 

RUN rel_enviados. /* relatorio de enviados */ 

RUN fontes/fimprg.p.

PROCEDURE abre_arquivo.

   ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
          aux_nmarqimp = "coo410" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0.

   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

   /* header */
   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") +
                         STRING(crapcop.nrctaitg,"99999999") +
                         "COO410  " +
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999") +
                         STRING(crapcop.cdmasitg,"99999").
                         /* o restante sao brancos */

   PUT STREAM str_1  aux_dsdlinha SKIP.

END PROCEDURE.
                                   
PROCEDURE fecha_arquivo.                                                     
                                                                             
   /* Emitir o pedido de desbloqueio de cartoes */                           
   /* Administradoras: 83,84,85,86,87,88 */                                  
   FOR EACH crawcrd WHERE                                                    
            crawcrd.cdcooper = glb_cdcooper  AND                             
           (crawcrd.flgctitg = 5             OR  /* Desbloqueio           */ 
            crawcrd.flgctitg = 6)            AND /* Reproces. Desbloqueio */ 
            crawcrd.insitcrd = 4                 /* EM USO                */ 
            EXCLUSIVE-LOCK:                                                  
                                                                             
       /* Registro tipo 16 - Desbloqueio */                                  
       ASSIGN aux_nrregist = aux_nrregist + 1                                
              aux_dsdlinha = STRING(aux_nrregist,"99999")           +        
                             "16"                                   +        
                             STRING(crawcrd.nrcctitg,"999999999")   +        
                             STRING(crawcrd.nrcpftit,"99999999999") +        
                             "                 "                    +        
                             "1"                                    +        
                             "2". /* Desbloqueio */                          
                             /* o restante sao brancos */                    
                                                                             
       PUT STREAM str_1  aux_dsdlinha SKIP.                                  
                                                                             
       /* Quando houver desbloqueio, Enviar tbm o limite */                  
       FIND FIRST craptlc WHERE craptlc.cdcooper = glb_cdcooper      AND     
                                craptlc.cdadmcrd = crawcrd.cdadmcrd  AND     
                                craptlc.cdlimcrd = crawcrd.cdlimcrd          
                                NO-LOCK NO-ERROR.                            
                                                                             
       /* registro tipo 15 */                                                
       ASSIGN aux_nrregist = aux_nrregist + 1                                
              aux_dsdlinha = STRING(aux_nrregist,"99999")               +    
                             "15"                                       +    
                             STRING(crawcrd.nrcctitg,"999999999")       +    
                             STRING(INTE(craptlc.vllimcrd),"999999999") +    
                             "S".                                            
                             /* o restante sao brancos */                    
                                                                             
       PUT STREAM str_1  aux_dsdlinha SKIP.                                  
                                                                             
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND            
                          crapass.nrdconta = crawcrd.nrdconta                
                          NO-LOCK NO-ERROR.                                  
                                                                             
       /* Busca a modalidade do cartao */
       FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper
                      AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                      NO-LOCK NO-ERROR.

       IF  AVAIL crapadc THEN
           ASSIGN aux_nmresadm = crapadc.nmresadm.
       ELSE
           ASSIGN aux_nmresadm = "".

       CREATE w_enviados.                                                    
       ASSIGN w_enviados.cdagenci = crapass.cdagenci                         
              w_enviados.nrdconta = crapass.nrdconta                         
              w_enviados.nrdctitg = crapass.nrdctitg                         
              w_enviados.nmtitcrd = crawcrd.nmtitcrd                         
              w_enviados.nrctrcrd = crawcrd.nrctrcrd                         
              w_enviados.tpregist = 2                                        
              w_enviados.cdmovmto = 4                                        
              w_enviados.dsmovmto = "Desblq./Lim."                           
              w_enviados.flgcnmae = TRUE                                     
              w_enviados.dssitcrd = IF crawcrd.flgctitg = 5 THEN "ENV."      
                                    ELSE "REENV."
              w_enviados.nmresadm = aux_nmresadm.                           
                                                                             
       ASSIGN aux_contdesb = aux_contdesb + 1.                               
                                                                             
       /* atualizacao da tabela */                                           
       ASSIGN crawcrd.flgctitg = 1  /* enviado */                            
              crawcrd.dtsolici = glb_dtmvtolt.                               
   END.                                                                      
                                                                             
   /* Cartoes Cancelados */                                                  
   FOR EACH crawcrd WHERE                                                    
            crawcrd.cdcooper =  glb_cdcooper AND                             
           (crawcrd.flgctitg = 0             OR  /* Nao enviado  */          
            crawcrd.flgctitg = 4)            AND /* Reprocessado */          
            crawcrd.insitcrd = 5             AND /* Cancelado    */          
            CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd))             
            EXCLUSIVE-LOCK:                                                  
                                                                             
       /* registro tipo 16 */                                                
       ASSIGN aux_nrregist = aux_nrregist + 1                                
              aux_dsdlinha = STRING(aux_nrregist,"99999")           +        
                             "16"                                   +        
                             STRING(crawcrd.nrcctitg,"999999999")   +        
                             STRING(crawcrd.nrcpftit,"99999999999") +        
                             "                 "                    +        
                             "1"                                    +        
                             "1".                                            
                             /* o restante sao brancos */                    
                                                                             
       PUT STREAM str_1  aux_dsdlinha SKIP.                                  
                                                                             
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND            
                          crapass.nrdconta = crawcrd.nrdconta                
                          NO-LOCK NO-ERROR.                                  
                                                                             
       /* Busca a modalidade do cartao */
       FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper
                      AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                      NO-LOCK NO-ERROR.

       IF  AVAIL crapadc THEN
           ASSIGN aux_nmresadm = crapadc.nmresadm.
       ELSE
           ASSIGN aux_nmresadm = "".
       
       CREATE w_enviados.                                                    
       ASSIGN w_enviados.cdagenci = crapass.cdagenci                         
              w_enviados.nrdconta = crapass.nrdconta                         
              w_enviados.nrdctitg = crapass.nrdctitg                         
              w_enviados.nmtitcrd = crawcrd.nmtitcrd                         
              w_enviados.nrctrcrd = crawcrd.nrctrcrd                         
              w_enviados.tpregist = 2                                        
              w_enviados.cdmovmto = 3                                        
              w_enviados.dsmovmto = "Bloqueio"                               
              w_enviados.flgcnmae = TRUE                                     
              w_enviados.dssitcrd = IF crawcrd.flgctitg = 0 THEN "ENV."      
                                    ELSE "REENV."                           
              w_enviados.nmresadm = aux_nmresadm.

       ASSIGN aux_contacan = aux_contacan + 1.                               
                                                                             
       /* atualizacao da tabela */                                           
       ASSIGN crawcrd.flgctitg = 1  /* enviado */                            
              crawcrd.dtsolici = glb_dtmvtolt.                               
   END.                                                                      
                                                                             
   /* Registro tipo 16 - Cartoes Encerrados */                               
   FOR EACH crawcrd WHERE                                                    
            crawcrd.cdcooper =  glb_cdcooper AND                             
           (crawcrd.flgctitg = 0             OR  /* Nao enviado  */          
            crawcrd.flgctitg = 4)            AND /* Reprocessado */          
            crawcrd.insitcrd = 6             AND /* Encerrado    */          
            CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd))             
            EXCLUSIVE-LOCK:                                                  
                                                                             
       /* registro tipo 16 */                                                
       ASSIGN aux_nrregist = aux_nrregist + 1                                
              aux_dsdlinha = STRING(aux_nrregist,"99999")           +        
                             "16"                                   +        
                             STRING(crawcrd.nrcctitg,"999999999")   +        
                             STRING(crawcrd.nrcpftit,"99999999999") +        
                             "                 "                    +        
                             "1"                                    +        
                             "3".                                            
                             /* o restante sao brancos */                    
                                                                             
       PUT STREAM str_1  aux_dsdlinha SKIP.                                  
                                                                             
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND            
                          crapass.nrdconta = crawcrd.nrdconta                
                          NO-LOCK NO-ERROR.                                  
                                                                             
       /* Busca a modalidade do cartao */
       FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper
                      AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                      NO-LOCK NO-ERROR.

       IF  AVAIL crapadc THEN
           ASSIGN aux_nmresadm = crapadc.nmresadm.
       ELSE
           ASSIGN aux_nmresadm = "".
       
       CREATE w_enviados.                                                    
       ASSIGN w_enviados.cdagenci = crapass.cdagenci                         
              w_enviados.nrdconta = crapass.nrdconta                         
              w_enviados.nrdctitg = crapass.nrdctitg                         
              w_enviados.nmtitcrd = crawcrd.nmtitcrd                         
              w_enviados.nrctrcrd = crawcrd.nrctrcrd                         
              w_enviados.tpregist = 2                                        
              w_enviados.cdmovmto = 5                                        
              w_enviados.dsmovmto = "Encerrado"                              
              w_enviados.flgcnmae = TRUE                                     
              w_enviados.dssitcrd = IF crawcrd.flgctitg = 0 THEN "ENV."      
                                    ELSE "REENV."
              w_enviados.nmresadm = aux_nmresadm.
                                                                             
       ASSIGN aux_contaenc = aux_contaenc + 1.                               
                                                                             
       /* atualizacao da tabela */                                           
       ASSIGN crawcrd.flgctitg = 1  /* enviado */                            
              crawcrd.dtsolici = glb_dtmvtolt.                               
   END.                                                                      
                                                                             
   /* Cartoes Alterados */                                                   
   FOR EACH crawcrd WHERE                                                    
            crawcrd.cdcooper =  glb_cdcooper AND                             
           (crawcrd.flgctitg = 0             OR  /* Nao enviado  */          
            crawcrd.flgctitg = 4)            AND /* Reprocessado */          
            crawcrd.insitcrd = 4             AND /*    em uso    */          
            CAN-DO("83,84,85,86,87,88",STRING(crawcrd.cdadmcrd))             
            EXCLUSIVE-LOCK:                                                  
                                                                             
                                                                             
       FIND FIRST craptlc WHERE craptlc.cdcooper = glb_cdcooper      AND     
                                craptlc.cdadmcrd = crawcrd.cdadmcrd  AND     
                                craptlc.cdlimcrd = crawcrd.cdlimcrd          
                                NO-LOCK NO-ERROR.                            
                                                                             
       /* registro tipo 15 */                                                
       ASSIGN aux_nrregist = aux_nrregist + 1                                
              aux_dsdlinha = STRING(aux_nrregist,"99999")               +    
                             "15"                                       +    
                             STRING(crawcrd.nrcctitg,"999999999")       +    
                             STRING(INTE(craptlc.vllimcrd),"999999999") +    
                             "S".                                            
                             /* o restante sao brancos */                    
                                                                             
       PUT STREAM str_1  aux_dsdlinha SKIP.                                  
                                                                             
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND            
                          crapass.nrdconta = crawcrd.nrdconta                
                          NO-LOCK NO-ERROR.                                  
                                                                             
       /* Busca a modalidade do cartao */
       FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper
                      AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                      NO-LOCK NO-ERROR.

       IF  AVAIL crapadc THEN
           ASSIGN aux_nmresadm = crapadc.nmresadm.
       ELSE
           ASSIGN aux_nmresadm = "".

       CREATE w_enviados.                                                    
       ASSIGN w_enviados.cdagenci = crapass.cdagenci                         
              w_enviados.nrdconta = crapass.nrdconta                         
              w_enviados.nrdctitg = crapass.nrdctitg                         
              w_enviados.nmtitcrd = crawcrd.nmtitcrd                         
              w_enviados.nrctrcrd = crawcrd.nrctrcrd                         
              w_enviados.tpregist = 1                                        
              w_enviados.cdmovmto = 2                                        
              w_enviados.dsmovmto = "Alt. Limite"                            
              w_enviados.flgcnmae = TRUE                                     
              w_enviados.dssitcrd = IF crawcrd.flgctitg = 0 THEN "ENV."      
                                    ELSE "REENV."
              w_enviados.nmresadm = aux_nmresadm.
                                                                             
       ASSIGN aux_contlimi = aux_contlimi + 1.                               
                                                                             
       /* atualizacao da tabela */                                           
       ASSIGN crawcrd.flgctitg = 1.  /* enviado */                           
                                                                             
   END.                                                                      
                                                                             
   /* trailer */                                                             
   /* total de registros + header + trailer */                               
   ASSIGN aux_nrregist = aux_nrregist + 2                                    
          aux_dsdlinha = "9999999"  +                                        
                         "00000" +                                           
                         STRING(aux_nrregist,"999999999").                   
                         /* o restante sao brancos */                        
                                                                             
   PUT STREAM str_1 aux_dsdlinha.                                            
                                                                             
   OUTPUT STREAM str_1 CLOSE.                                                
                                                                             
   /* verifica se o arquivo gerado nao tem registros "detalhe" */            
   IF   aux_nrregist <= 2   THEN                                             
        DO:                                                                  
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.                                                           
        END.                                                                 
                                                                             
   glb_cdcritic = 847.                                                       
   RUN fontes/critic.p.                                                      
                                                                             
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO410 - " + glb_cdprogra + "' --> '"  +
                     glb_dscritic + " - " + aux_nmarqimp +
                     " >> " + aux_nmarqlog).

   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +
                     ' | tr -d "\032"' +
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").

    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null").       
                                                                             
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:                                     
                                                                             
      /*   Atualiza a sequencia da remessa  */                               
      DO WHILE TRUE:                                                         
                                                                             
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND             
                            craptab.nmsistem = "CRED"        AND             
                            craptab.tptabela = "GENERI"      AND             
                            craptab.cdempres = 00            AND             
                            craptab.cdacesso = "NRARQMVITG"  AND             
                            craptab.tpregist = 410                           
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.                 
                                                                             
         IF   NOT AVAILABLE craptab   THEN                                   
              IF   LOCKED craptab   THEN                                     
                   DO:                                                       
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                                                
                        NEXT.
                                                  
                   END.                                                      
              ELSE                                                           
                  DO:                                                        
                      glb_cdcritic = 55.                                     
                      LEAVE.                                                 
                  END.                                                       
         ELSE                                                                
             glb_cdcritic = 0.                                               
                                                                             
         LEAVE.                                                              
                                                                             
     END.  /*  Fim do DO .. TO  */                                           
                                                                             
     IF   glb_cdcritic > 0 THEN                                              
          RETURN.                                                            
                                                                             
     SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1, "99999").    
                                                                             
   END. /* TRANSACTION */                                                    
                                                                             
END PROCEDURE.                                                               

PROCEDURE rel_enviados.

    ASSIGN aux_nmarqrel = "rl/crrl384_" + STRING(TIME) + ".lst"
           aux_nmarqcen = "/usr/coop/cecred/rl/" 
                          + SUBSTR(aux_nmarqrel,4,LENGTH(aux_nmarqrel) - 7) 
                          + "_" + crapcop.nmrescop + ".lst".

    { includes/cabrel132_1.i }  /* Monta o cabecalho */

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    RUN lista_enviados (INPUT TRUE,
                        INPUT aux_contsoli).

    RUN lista_enviados (INPUT FALSE,
                        INPUT aux_contctma).  /* lista as solicitacoes */
                                                 /*  sem conta-cartao  */
    OUTPUT STREAM str_1 CLOSE.

    /* Copia o arquivo para o doretorio da CECRED */
    UNIX SILENT VALUE ("cp " + aux_nmarqrel + " " + aux_nmarqcen + 
                       " 2> /dev/null").

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel.

    RUN fontes/imprim.p.

    ASSIGN glb_nmarqimp = aux_nmarqcen.

    /* Envia o arquivo para a intranet */
    RUN fontes/imprim_unif.p (INPUT 3). 

    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT
        SET b1wgen0011.

    IF   VALID-HANDLE(b1wgen0011)   THEN
         DO:
             aux_nmarqenv = SUBSTR(aux_nmarqrel,4,LENGTH(aux_nmarqrel) - 7) +
                            ".txt".

             RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                                 INPUT aux_nmarqrel,
                                                 INPUT aux_nmarqenv).

             RUN enviar_email IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdprogra,
                                 INPUT "cartoes@ailos.coop.br",
                                 INPUT "TITULARES ENVIADOS CARTAO CREDITO " +
                                       "BB - " + CAPS(crapcop.nmrescop),
                                 INPUT aux_nmarqenv,
                                 INPUT TRUE).

             DELETE PROCEDURE b1wgen0011.
         END.

    /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
    IF   glb_inproces = 1   THEN
         UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                           SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                           LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

END PROCEDURE.

PROCEDURE lista_enviados:

    DEF     INPUT PARAM par_flgcnmae  AS LOGICAL                      NO-UNDO.
    DEF     INPUT PARAM par_ctsolici  AS INTEGER                      NO-UNDO.
    DEF     VAR   aux_linhatrc        AS CHARACTER  FORMAT "x(132)"   NO-UNDO.

    aux_linhatrc = FILL("-",132).

    FOR EACH w_enviados WHERE flgcnmae = par_flgcnmae USE-INDEX w_enviados1
                        NO-LOCK BREAK  BY w_enviados.cdmovmto
                                          BY w_enviados.cdagenci
                                             BY w_enviados.nrdconta:

        IF   par_flgcnmae   THEN
             DISPLAY STREAM str_1
                     w_enviados.cdagenci
                     w_enviados.nrdconta WHEN FIRST-OF(w_enviados.nrdconta)
                     w_enviados.nrdctitg WHEN FIRST-OF(w_enviados.nrdconta)
                     w_enviados.nmtitcrd
                     w_enviados.nmresadm
                     w_enviados.dsmovmto
                     w_enviados.dssitcrd WITH FRAME f_enviados.
        ELSE
             DISPLAY STREAM str_1
                     w_enviados.cdagenci
                     w_enviados.nrdconta WHEN FIRST-OF(w_enviados.nrdconta)
                     w_enviados.nrdctitg WHEN FIRST-OF(w_enviados.nrdconta)
                     w_enviados.nmtitcrd
                     w_enviados.nmresadm
                     w_enviados.dsmovmto
                     w_enviados.dssitcrd
                     w_enviados.dtsolici WITH FRAME f_enviados_sem_conta_cartao.

        DOWN STREAM str_1 WITH FRAME f_enviados.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
             DO:
                 PAGE STREAM str_1.
                 
             END.

        IF   LAST-OF(w_enviados.nrdconta)   THEN  /*pular linha a cada conta*/
             PUT STREAM str_1 SKIP(1).

        IF   LAST-OF (w_enviados.cdmovmto)   THEN
             DO:
                 IF   w_enviados.cdmovmto = 1   THEN
                      IF   par_flgcnmae   THEN
                           PUT STREAM str_1 SKIP(1)
                                      "TOTAL DE CARTOES SOLICITADOS         : "
                                      par_ctsolici FORMAT "zzz,zz9" SKIP(1).
                      ELSE
                           PUT STREAM str_1 SKIP(1)
                                      "TOTAL DE CARTOES SOLICITADOS SEM "
                                      "CONTA CARTAO :"
                                      par_ctsolici FORMAT "zzz,zz9" SKIP(1).
                 ELSE
                 IF   w_enviados.cdmovmto = 2   THEN
                      PUT STREAM str_1 SKIP(1)
                                 "TOTAL DE ALTERACOES DE LIMITE        : "
                                 aux_contlimi FORMAT "zzz,zz9" SKIP(1).
                 ELSE
                 IF   w_enviados.cdmovmto = 3   THEN
                      PUT STREAM str_1 SKIP(1)
                                 "TOTAL DE BLOQUEIOS DE CONTA CARTAO   : "
                                 aux_contacan FORMAT "zzz,zz9" SKIP(1).
                 ELSE
                 IF   w_enviados.cdmovmto = 5   THEN
                      PUT STREAM str_1 SKIP(1)
                                 "TOTAL DE ENCERRAMENTOS DE CONTA CARTAO   : "
                                 aux_contaenc FORMAT "zzz,zz9" SKIP(1).
                 ELSE
                      PUT STREAM str_1 SKIP(1)
                                 "TOTAL DE DESBLOQUEIO DE CONTA CARTAO : "
                                 aux_contdesb FORMAT "zzz,zz9" SKIP(1).

                 PUT STREAM str_1 aux_linhatrc SKIP (1).

             END.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
             DO:
                 PAGE STREAM str_1.

             END.
    END.

END PROCEDURE.

/*............................................................................*/
