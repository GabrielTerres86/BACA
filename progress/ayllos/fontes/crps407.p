/* .............................................................................

   Programa: Fontes/crps407.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Setembro/2004.                     Ultima atualizacao: 07/03/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 082.
               Gerar arquivo de cadastramento Conta Integracao.
               Relatorios:   374 - Enviados
               
   Alteracoes:  Leitura para obter data sistema financeiro(Mirtes)
               
              06/04/2005 - Gravar os erros no log da tela PRCITG;
                           Mover o relatorio para o diretorio "RLNSV" 
                           (Evandro).
                            
              08/06/2005 - Prever Tipo de Conta 17 / 18(Mirtes).

              01/07/2005 - Alimentado campo cdcooper da tabela crapeca (Diego).
              
              29/07/2005 - Alterada mensagem Log referente critica 847 (Diego).
              
              23/09/2005 - Modificado FIND FIRST para FIND na tabela
                           crapcop.cdcooper = glb_cdcooper (Diego).

              04/10/2005 - Cancelada impressao do relatorio 374 para
                           Viacredi (Diego). 
                           
              01/11/2005 - Alterado limite de registros por arquivo (Evandro).
              
              17/11/2005 - Adequacao a pessoas juridicas, uma vez que, foram
                           removidos registros da crapttl (Evandro).
                           
              22/11/2005 - Acerto no contador de registros tipo 1 (Evandro).
              
              28/11/2005 - Acerto do tipo de pessoa (Evandro).
              
              10/01/2006 - Correcao das mensagens para o LOG (Evandro).

              17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

              25/07/2006 - Alterando (David).
              
              04/01/2007 - Prever tipos de contas BANCOOB - 08, 09, 10 e 11
                           (Evandro).
                           
              28/05/2007 - Retirado vinculacao da execucao do fontes/imprim.p
                        ao codigo da cooperativa(Guilherme).

              15/08/2007 - Pega a conta mais antiga do cooperado no sistema
                           financeiro nacional e inclui no arquivo de
                           cadastramento (Elton). 

              22/10/2007 - Inclusao do campo tparquiv no FOR EACH do crapeca,
                           para melhoria de performance (Julio).
             
              15/06/2009 - Eliminar crapeca apenas para as contas enviadas
                            (Fernando).

              03/08/2009 - Pegar nome de talao da crapjur e nao utilizar mais
                           o programa abreviar.p (David).
                           
              11/09/2009 - Acerto na leitura crapeca para pegar nome do talao
                           (Guilherme).
                           
              23/02/2010 - Eliminado campo crapttl.cdmodali (Diego). 
                         - Envia no arquivo o endereco do cooperado, quando 
                           cooperativa for creditextil (Elton).
              
              05/03/2010 - Envia no arquivo o endereco do cooperado, quando 
                           cooperativa for Credcrea (Elton).
                           
              22/03/2010 - Envia no arquivo o endereco do cooperado ao inves 
                           do endereco da cooperativa;
                           Aumentado o formato do campo da conta, no arquivo e
                           no relatorio (Elton).
                                         
              23/05/2011 - Substituido campo crapttl.nranores por 
                           crapenc.dtinires. (Fabricio)
                           
              11/07/2011 - Utilizar nova funcao f_endereco_ctaitg declarada na
                           include endereco_conta_itg.i para configurar endereco
                           do cooperado para envio ao BB (David).
              
              09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).       
                            
              22/01/2014 - Incluir VALIDATE crapeca (Lucas R.)     
              
              16/06/2014 - (Chamado 117414) - Alteraçao das informaçoes do conjuge da crapttl 
                           para utilizar somente crapcje. 
                           (Tiago Castro - RKAM)
                           
              22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
              19/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)     

              28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
                           CH, RE, PP E CT. (PRJ339 - Reinert)              

              07/03/2018 - Ajuste para buscar os tipo de conta integracao 
                           da Package CADA0006 do orcale. PRJ366 (Lombardi).

............................................................................. */

{ sistema/generico/includes/var_oracle.i } 
 
DEF STREAM str_1.     /*  Para relatorio de Aceitos      */
DEF STREAM str_2.     /*  Para relatorio de Criticas     */                 
DEF STREAM str_3.     /*  Para arquivo de cadastramemto  */

DEF BUFFER crabass FOR crapass.

DEFINE TEMP-TABLE cratass 
       FIELD cdagenci  AS INTEGER
       FIELD nrdconta  AS INTEGER
       FIELD nmprimtl  AS CHAR      FORMAT "x(40)"
       INDEX cratass_1 AS PRIMARY nrdconta.

DEFINE TEMP-TABLE crawarq
          FIELD nmarquiv AS CHAR              
          FIELD nrsequen AS INTEGER
          FIELD qtassoci AS INTEGER
          INDEX crawarq1 AS PRIMARY
                nmarquiv nrsequen.

DEFINE TEMP-TABLE tt_tipos_conta
       FIELD inpessoa AS INTEGER
       FIELD cdtipcta AS INTEGER.

{ includes/var_batch.i } 

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEFINE VARIABLE aux_cdseqarq AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_dtmvtolt AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_cdseqass AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_cdseqt01 AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_dtnasctl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_cdsexotl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_cdtipdoc AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_cdoedttl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dtemdttl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_mesanord AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dsendere AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrdddcop AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_nrtelcop AS DEC                                  NO-UNDO.
DEFINE VARIABLE aux_dtinires AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dtabtcct AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dtadmemp AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dtnasccj AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrcpfptl AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE aux_inpessoa LIKE crapass.inpessoa                   NO-UNDO.
DEFINE VARIABLE aux_nmarqdat AS CHAR     FORMAT "x(20)"              NO-UNDO.
DEFINE VARIABLE aux_flgfirst AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_contador AS INT      FORMAT "zz9"                NO-UNDO.
DEFINE VARIABLE aux_nmextass AS CHAR     FORMAT "x(50)"              NO-UNDO.
DEFINE VARIABLE aux_dstelefo AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_flgrejei AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_qtdtitul AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_idseqttl AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_dsnatura AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrdocttl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_cdestcvl AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_cdfrmttl AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_grescola AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_cdnatopc AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_cdocpttl AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_vlsalari AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE aux_nmbairro AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrcepend AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_nrcxapst AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_incasprp AS INT                                  NO-UNDO.
DEFINE VARIABLE aux_nmrestal AS CHAR     FORMAT "x(25)"              NO-UNDO.
DEFINE VARIABLE aux_nmmaettl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nmpaittl AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nmconjug AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrcpfcjg LIKE crapcje.nrcpfcjg                   NO-UNDO.
DEFINE VARIABLE aux_nmextemp AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_nrcpfcgc LIKE crapttl.nrcpfcgc                   NO-UNDO.
DEFINE VARIABLE aux_tpnacion LIKE crapttl.tpnacion                   NO-UNDO.
DEFINE VARIABLE aux_nrdconta LIKE crapttl.nrdconta                   NO-UNDO.
                                                                  
/* Variaveis para o XML */ 
DEFINE VARIABLE xDoc          AS HANDLE                              NO-UNDO.   
DEFINE VARIABLE xRoot         AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xRoot2        AS HANDLE                              NO-UNDO.  
DEFINE VARIABLE xField        AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE xText         AS HANDLE                              NO-UNDO. 
DEFINE VARIABLE aux_cont_raiz AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE aux_cont      AS INTEGER                             NO-UNDO. 
DEFINE VARIABLE ponteiro_xml  AS MEMPTR                              NO-UNDO. 
DEFINE VARIABLE aux_tpsconta  AS LONGCHAR                            NO-UNDO.
DEFINE VARIABLE aux_des_erro  AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_dscritic  AS CHAR                                NO-UNDO.

DEFINE VARIABLE aux_dtabertu AS DATE     FORMAT "99/99/9999"         NO-UNDO.
DEFINE VARIABLE aux_dtabtcc2 AS DATE     FORMAT "99/99/9999"         NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0052b AS HANDLE                               NO-UNDO.

/* para o controle da crapeca */
DEFINE VARIABLE aux_nrseqarq AS INT                                  NO-UNDO.

/* nome do arquivo de log */
DEFINE VARIABLE aux_nmarqlog AS CHAR                                 NO-UNDO.

ASSIGN glb_cdprogra = "crps407"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
  
{ includes/endereco_conta_itg.i }

FUNCTION f_tiraponto RETURN CHAR(INPUT  par_nmsempto AS CHAR):
       
  DEFINE VARIABLE aux_nmretorn AS CHAR                     NO-UNDO.
  
  aux_nmretorn = "".
    
  IF   par_nmsempto = "" THEN
       RETURN "".
  ELSE
       DO:
           DO  aux_contador = 1 TO LENGTH(par_nmsempto):
            IF   CAN-DO("A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z, ",
                        CAPS(SUBSTR(par_nmsempto,aux_contador,1))) THEN
                 aux_nmretorn = aux_nmretorn +
                                SUBSTR(par_nmsempto,aux_contador,1).
            ELSE aux_nmretorn = aux_nmretorn + " ".    
        
           END.

           RETURN aux_nmretorn.

       END.  
           
END. /* FUNCTION */

/*  Busca dados da cooperativa  */
      
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

/*  Verifica se os lotes estao fechados  */
   
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "NRARQMVITG"  AND
                   craptab.tpregist = 400
                   NO-LOCK NO-ERROR NO-WAIT.

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
                                " - COO400 - " + glb_cdprogra + "' --> '"  +
                                "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                                " >> " + aux_nmarqlog).
              RUN fontes/fimprg.p.
              RETURN.
          END.
     
ASSIGN aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,01,05))
       aux_dtmvtolt = STRING(DAY(glb_dtmvtolt),"99") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(YEAR(glb_dtmvtolt),"9999")
       aux_flgfirst = TRUE.

/* Tratamento para envio cooperados com erros no  retorno e foram corrigidos */

/* Todos que tiveram erros no retorno (1o. Titular) */
FOR EACH crapeca WHERE crapeca.cdcooper  = glb_cdcooper  AND
                       crapeca.dtretarq <> ?             AND
                       crapeca.idseqttl  = 1             AND     
                       crapeca.tparquiv  = 500           NO-LOCK:

    /* Alteracao depois da data do erro,seta flag para ser enviado novamente */

    FIND FIRST crapalt WHERE crapalt.cdcooper  = glb_cdcooper       AND
                             crapalt.nrdconta  = crapeca.nrdconta   AND
                             crapalt.dtaltera >= crapeca.dtretarq 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAILABLE crapalt   THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                  crapass.nrdconta = crapalt.nrdconta 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
               IF   LOCKED crapass   THEN
                    DO:
                       PAUSE 2 NO-MESSAGE.
                       NEXT.
                    END.
                                  
               LEAVE.
            END.
           
            IF   crapass.flgctitg = 4   AND
                 crapass.dtdemiss = ?   THEN  /* se esta como reprocessar */
                 ASSIGN crapass.flgctitg = 0. /* coloca para enviar */
         END.
END.

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_lista_tipo_conta_itg
aux_handproc = PROC-HANDLE NO-ERROR (INPUT 1,    /* Flag conta itg */
                                     INPUT 0,    /* modalidade */
                                    OUTPUT "",   /* Tipos de conta */
                                    OUTPUT "",   /* Flag Erro */
                                    OUTPUT "").  /* Descrição da crítica */

CLOSE STORED-PROC pc_lista_tipo_conta_itg
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_tpsconta = ""
       aux_des_erro = ""
       aux_dscritic = ""
       aux_tpsconta = pc_lista_tipo_conta_itg.pr_tiposconta 
                      WHEN pc_lista_tipo_conta_itg.pr_tiposconta <> ?
       aux_des_erro = pc_lista_tipo_conta_itg.pr_des_erro 
                      WHEN pc_lista_tipo_conta_itg.pr_des_erro <> ?
       aux_dscritic = pc_lista_tipo_conta_itg.pr_dscritic
                      WHEN pc_lista_tipo_conta_itg.pr_dscritic <> ?.

IF aux_des_erro = "NOK"  THEN
    DO:
        glb_dscritic = aux_dscritic.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        RETURN.
    END.

/* Inicializando objetos para leitura do XML */ 
CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

EMPTY TEMP-TABLE tt_tipos_conta.

/* Efetuar a leitura do XML*/ 
SET-SIZE(ponteiro_xml) = LENGTH(aux_tpsconta) + 1. 
PUT-STRING(ponteiro_xml,1) = aux_tpsconta. 
   
IF ponteiro_xml <> ? THEN
    DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
            xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
            IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
             NEXT. 
    
            IF xRoot2:NUM-CHILDREN > 0 THEN
              CREATE tt_tipos_conta.
    
            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                
                xRoot2:GET-CHILD(xField,aux_cont).
                    
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField:GET-CHILD(xText,1).
               
                ASSIGN tt_tipos_conta.inpessoa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "inpessoa".
                ASSIGN tt_tipos_conta.cdtipcta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtipo_conta".
                
            END. 
            
        END.
    
        SET-SIZE(ponteiro_xml) = 0. 
    END.

DELETE OBJECT xDoc. 
DELETE OBJECT xRoot. 
DELETE OBJECT xRoot2. 
DELETE OBJECT xField. 
DELETE OBJECT xText.


FOR EACH crapass WHERE crapass.cdcooper  = glb_cdcooper  AND
                       crapass.flgctitg = 0              AND  /* nao enviado */
                       crapass.nrdctitg = ""             NO-LOCK,
    EACH tt_tipos_conta
                 WHERE tt_tipos_conta.inpessoa = crapass.inpessoa AND
                       tt_tipos_conta.cdtipcta = crapass.cdtipcta NO-LOCK
                       BY crapass.cdagenci:
          
    ASSIGN aux_flgrejei = FALSE
           aux_qtdtitul = 0
           aux_nrseqarq = 1000. /* nro. ficticio */
       
    FOR EACH crapeca WHERE 
             crapeca.cdcooper = glb_cdcooper     AND
             crapeca.nrdconta = crapass.nrdconta AND
             crapeca.tparquiv = 500: /*Erros coop.(antes envio)*/
             DELETE crapeca.
    END.

    /* ----------------- Verifica Criticas ------------------- */
       
    IF   crapass.inpessoa > 3 THEN
         DO TRANSACTION:

            CREATE crapeca.
            ASSIGN crapeca.nrdconta = crapass.nrdconta
                   crapeca.tparquiv = 500
                   crapeca.dscritic = "Associado com tipo de pessoa invalido"
                   crapeca.dtgerarq = glb_dtmvtolt
                   crapeca.nrseqarq = aux_nrseqarq
                   crapeca.cdcooper = glb_cdcooper
                   aux_nrseqarq     = aux_nrseqarq + 1.
            VALIDATE crapeca.
            NEXT.  
         END.
    
    FIND LAST crapalt WHERE crapalt.cdcooper = glb_cdcooper      AND
                            crapalt.nrdconta = crapass.nrdconta  AND
                            crapalt.tpaltera = 1             
                            NO-LOCK NO-ERROR.
                            
    IF   NOT AVAILABLE crapalt THEN   /* Associado sem Recadastramento */
         DO TRANSACTION:

             CREATE crapeca.
             ASSIGN crapeca.nrdconta = crapass.nrdconta
                    crapeca.tparquiv = 500
                    crapeca.dtgerarq = glb_dtmvtolt
                    crapeca.dscritic = "Associado nao recadastrado"
                    crapeca.nrseqarq = aux_nrseqarq
                    crapeca.cdcooper = glb_cdcooper
                    aux_nrseqarq     = aux_nrseqarq + 1.
             VALIDATE crapeca.
             NEXT.                   
         END.

    
    FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper      AND
                           crapttl.nrdconta = crapass.nrdconta  NO-LOCK:

        ASSIGN aux_qtdtitul = aux_qtdtitul + 1.
        
        IF   crapass.inpessoa = 1 THEN
             DO:
                 IF   crapttl.indnivel < 4   THEN
                      DO TRANSACTION:

                         CREATE crapeca.
                         ASSIGN crapeca.nrdconta = crapass.nrdconta
                                crapeca.tparquiv = 500
                                crapeca.dtgerarq = glb_dtmvtolt
                                crapeca.dscritic = 
                                        "Associado sem cadastramento completo"
                                aux_flgrejei     = TRUE
                                crapeca.nrseqarq = aux_nrseqarq
                                crapeca.cdcooper = glb_cdcooper
                                aux_nrseqarq     = aux_nrseqarq + 1.
                         VALIDATE crapeca.
                         NEXT.
                      END.
                
                 IF   NOT CAN-DO("CI,CN,CH,RE,PP,CT",crapttl.tpdocttl) THEN
                      DO TRANSACTION:

                         CREATE crapeca.
                         ASSIGN crapeca.nrdconta = crapass.nrdconta
                                crapeca.tparquiv = 500
                                crapeca.dtgerarq = glb_dtmvtolt
                                crapeca.dscritic = 
                                        "Tipo de documento nao aceito pelo BB"
                                aux_flgrejei     = TRUE
                                crapeca.nrseqarq = aux_nrseqarq
                                crapeca.cdcooper = glb_cdcooper
                                aux_nrseqarq     = aux_nrseqarq + 1.
                         VALIDATE crapeca.
                         NEXT.
                      END.
   
                 IF   crapttl.idorgexp = 0 THEN
                      DO TRANSACTION:

                         CREATE crapeca.
                         ASSIGN crapeca.nrdconta = crapass.nrdconta
                                crapeca.tparquiv = 500
                                crapeca.dtgerarq = glb_dtmvtolt
                                crapeca.dscritic = 
                                        "Documento sem Orgao expedidor"
                                aux_flgrejei     = TRUE
                                crapeca.nrseqarq = aux_nrseqarq
                                crapeca.cdcooper = glb_cdcooper
                                aux_nrseqarq     = aux_nrseqarq + 1.
                         VALIDATE crapeca.
                         NEXT. 
                      END.
                      
                 IF   crapttl.dtemdttl = ? THEN
                      DO TRANSACTION:

                         CREATE crapeca.
                         ASSIGN crapeca.nrdconta = crapass.nrdconta
                                crapeca.tparquiv = 500
                                crapeca.dtgerarq = glb_dtmvtolt
                                crapeca.dscritic = 
                                        "Associado sem data emisssao do doc"
                                aux_flgrejei     = TRUE
                                crapeca.nrseqarq = aux_nrseqarq
                                crapeca.cdcooper = glb_cdcooper
                                aux_nrseqarq     = aux_nrseqarq + 1.
                         VALIDATE crapeca.
                         NEXT.                   
                      END.
   
                 IF   crapttl.cdestcvl = 0 THEN
                      DO TRANSACTION:

                         CREATE crapeca.
                         ASSIGN crapeca.nrdconta = crapass.nrdconta
                                crapeca.tparquiv = 500
                                crapeca.dtgerarq = glb_dtmvtolt
                                crapeca.dscritic = "Associado sem estado civil"
                                aux_flgrejei     = TRUE
                                crapeca.nrseqarq = aux_nrseqarq
                                crapeca.cdcooper = glb_cdcooper
                                aux_nrseqarq     = aux_nrseqarq + 1.
                         VALIDATE crapeca.
                         NEXT.                   
                      END.
             END.
    END.             /*    Fim do For Each crapttl    */
    
    IF   aux_flgrejei THEN
         NEXT.
                    
    /* --------------------------------------------------- */
    
    IF   aux_flgfirst  THEN
         DO:     
             ASSIGN aux_cdseqass = 0
                    aux_cdseqt01 = 0 
                    aux_nmarqdat = "coo400" +
                                   STRING(DAY(glb_dtmvtolt),"99") + 
                                   STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(aux_cdseqarq,"99999") + ".rem".

             IF   SEARCH("arq/" + aux_nmarqdat) <> ? THEN
                  UNIX SILENT VALUE("rm arq/" + aux_nmarqdat + " 2>/dev/null").
                       
             OUTPUT STREAM str_3 TO VALUE("arq/" + aux_nmarqdat).
                
             
             /* ------------   Header do Arquivo   ------------  */

             PUT STREAM str_3 "0000000"
                              crapcop.cdageitg            FORMAT "9999"
                              crapcop.nrctaitg            FORMAT "99999999"
                              "COO400  "
                              aux_cdseqarq                FORMAT "99999"
                              aux_dtmvtolt                FORMAT "x(08)"
                              crapcop.cdcnvitg            FORMAT "999999999"
                              crapcop.cdmasitg            FORMAT "99999"
                              FILL(" ",336)               FORMAT "x(336)" 
                              SKIP.
             
             ASSIGN aux_flgfirst = FALSE
                    aux_dstelefo = "".

             DO  aux_contador = 1 TO 15:
                 IF   CAN-DO("0,1,2,3,4,5,6,7,8,9, ",
                             SUBSTR(crapcop.nrtelvoz,aux_contador,1)) THEN
                      aux_dstelefo = aux_dstelefo + 
                                     SUBSTR(crapcop.nrtelvoz,aux_contador,1).
             END.
       
             ASSIGN aux_mesanord = STRING(MONTH(glb_dtmvtolt),"99") +
                                   STRING(YEAR(glb_dtmvtolt),"9999")
                    aux_nrdddcop = INT(STRING(SUBSTR(aux_dstelefo,1,02),"99"))
                    aux_nrtelcop = DEC(STRING(SUBSTR(aux_dstelefo,4,09),
                                                     "999999999")).
         
         END.  /*  Fim  do  aux_flgfirst  */
    
         FIND FIRST crapenc WHERE 
                    crapenc.cdcooper = glb_cdcooper      AND
                    crapenc.nrdconta = crapass.nrdconta  AND
                    crapenc.idseqttl = 1                 AND
                    crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
            
         IF  AVAILABLE crapenc  THEN
             ASSIGN aux_dsendere =  f_endereco_ctaitg(INPUT crapenc.dsendere,
                                                      INPUT crapenc.nrendere,
                                                      INPUT crapenc.nrdoapto,
                                                      INPUT crapenc.cddbloco)
                    aux_nmbairro =  crapenc.nmbairro
                    aux_nrcepend =  crapenc.nrcepend
                    aux_nrcxapst =  crapenc.nrcxapst
                    aux_incasprp =  crapenc.incasprp.
         ELSE
             ASSIGN aux_dsendere =  ""
                    aux_nmbairro =  ""
                    aux_nrcepend =  0
                    aux_nrcxapst =  0
                    aux_incasprp =  0.
                     
    /* limite maximo de registros = 49990 */
    IF   (aux_qtdtitul + aux_cdseqass) > 49988 THEN 
         DO:
             /* ------------   Trailer do Arquivo   ------------  */
                 
             PUT STREAM str_3 "9999999"
                              aux_cdseqt01          FORMAT "99999"
                              (aux_cdseqass + 2)    FORMAT "999999999"
                              FILL(" ",369)         FORMAT "x(369)" 
                              SKIP.            
                 
             OUTPUT STREAM str_3 CLOSE.

             glb_cdcritic = 847.
             RUN fontes/critic.p.
             
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - COO400 - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " - " + aux_nmarqdat +
                               " >> " + aux_nmarqlog).

             UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqdat + 
                               ' | tr -d "\032"' +   
                               " > /micros/" + crapcop.dsdircop + 
                               "/compel/" + aux_nmarqdat + " 2>/dev/null").

             UNIX SILENT VALUE("mv arq/" + aux_nmarqdat + 
                               " salvar 2>/dev/null"). 
                 
             ASSIGN aux_flgfirst = TRUE
                    aux_cdseqarq = aux_cdseqarq + 1.
                                         
             NEXT.
         END.

    /* Pessoa FISICA */
    IF   crapass.inpessoa = 1   THEN
         DO:
            FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                   crapttl.nrdconta = crapass.nrdconta NO-LOCK: 
                ASSIGN aux_cdsexotl = IF   crapttl.cdsexotl = 1 THEN
                                           "M"
                                      ELSE "F"
                       aux_dtinires = STRING(MONTH(crapenc.dtinires), "99") +
                                      STRING(YEAR(crapenc.dtinires), "9999")
                       aux_nrcpfcgc = crapttl.nrcpfcgc
                       aux_tpnacion = crapttl.tpnacion
                       aux_nrdconta = crapttl.nrdconta
                       aux_inpessoa = 1.
                                                
                CASE crapttl.tpdocttl:
                     WHEN "CH" THEN aux_cdtipdoc = 31.
                     WHEN "CI" THEN aux_cdtipdoc = 20.
                     WHEN "CP" THEN aux_cdtipdoc = 21.
                     WHEN "CT" THEN aux_cdtipdoc = 21.
                END CASE.

                IF   crapttl.idseqttl = 1 THEN 
                     DO:
                        ASSIGN aux_dtabertu = ?.
                        
                        FOR EACH crapsfn WHERE 
                                 crapsfn.cdcooper = glb_cdcooper        AND
                                 crapsfn.nrcpfcgc = crapass.nrcpfcgc    AND
                                 crapsfn.tpregist = 1                   NO-LOCK 
                                    BY crapsfn.dtabtcct DESCENDING:
                        
                            ASSIGN aux_dtabertu = crapsfn.dtabtcct. 
                        
                        END.
                         
                        IF  crapass.dtabtcct <> ? AND
                            crapass.dtabtcct < crapass.dtadmiss THEN
                                
                            ASSIGN aux_dtabtcc2 = crapass.dtabtcct.
                        
                        ELSE
                            ASSIGN aux_dtabtcc2 = crapass.dtadmiss.
                            
                        IF  aux_dtabertu <> ?  AND
                            aux_dtabertu < aux_dtabtcc2 THEN 
                            
                            aux_dtabtcct =   STRING(DAY(aux_dtabertu),"99")
                                           + STRING(MONTH(aux_dtabertu),"99")
                                           + STRING(YEAR(aux_dtabertu),"9999").
                        ELSE
                            aux_dtabtcct =   STRING(DAY(aux_dtabtcc2),"99")
                                           + STRING(MONTH(aux_dtabtcc2),"99")
                                           + STRING(YEAR(aux_dtabtcc2),"9999").
                     END.
                ELSE
                     aux_dtabtcct = "00000000".               
                        
                ASSIGN aux_cdseqass = aux_cdseqass + 1
                       aux_cdseqt01 = aux_cdseqt01 + 1
                       aux_dtnasctl = STRING(DAY(crapttl.dtnasttl),"99") +
                                      STRING(MONTH(crapttl.dtnasttl),"99") +
                                      STRING(YEAR(crapttl.dtnasttl),"9999")
                       aux_nmextass = f_tiraponto(crapttl.nmextttl)
                       aux_idseqttl = crapttl.idseqttl
                       aux_dtemdttl = STRING(DAY(crapttl.dtemdttl),"99") +
                                      STRING(MONTH(crapttl.dtemdttl),"99") +
                                      STRING(YEAR(crapttl.dtemdttl),"9999")
                       aux_nrcpfptl = IF   crapttl.idseqttl > 1 THEN
                                           aux_nrcpfptl
                                      ELSE 0
                       aux_dsnatura = CAPS(crapttl.dsnatura)
                       aux_nrdocttl = CAPS(crapttl.nrdocttl)
                       aux_cdestcvl = crapttl.cdestcvl
                       aux_cdfrmttl = crapttl.cdfrmttl
                       aux_grescola = crapttl.grescola
                       aux_cdnatopc = crapttl.cdnatopc
                       aux_cdocpttl = crapttl.cdocpttl
                       aux_vlsalari = 100.
                
                /* Retornar orgao expedidor */
                IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

                ASSIGN aux_cdoedttl = "".
                RUN busca_org_expedidor IN h-b1wgen0052b 
                                   ( INPUT crapttl.idorgexp,
                                    OUTPUT aux_cdoedttl,
                                    OUTPUT glb_cdcritic, 
                                    OUTPUT glb_dscritic).

                ASSIGN aux_cdoedttl = TRIM(aux_cdoedttl,"/.-[](){}").
                DELETE PROCEDURE h-b1wgen0052b.   

                IF  RETURN-VALUE = "NOK" THEN
                DO:
                    ASSIGN aux_cdoedttl = 'NAO CADAST'.
                END.
                
                IF   crapttl.nmtalttl = "" THEN
                     RUN fontes/abreviar.p (INPUT  crapttl.nmextttl, INPUT 25,
                                            OUTPUT aux_nmrestal).
                ELSE
                     aux_nmrestal = crapttl.nmtalttl.
               
                RUN detalhe_tipo_1.    
                      
                IF   crapttl.dtadmemp = ? THEN
                     aux_dtadmemp = "000000".
                ELSE
                     aux_dtadmemp = STRING(MONTH(crapttl.dtadmemp),"99") +
                                    STRING(YEAR(crapttl.dtadmemp),"9999").
                                    
                FIND crapcje WHERE crapcje.cdcooper = glb_cdcooper     AND
                                   crapcje.nrdconta = crapass.nrdconta AND
                                   crapcje.idseqttl = crapttl.idseqttl
                                   NO-LOCK NO-ERROR.
                IF AVAILABLE crapcje THEN
                  DO:
                    IF   crapcje.dtnasccj = ? THEN
                     aux_dtnasccj = "00000000".
                    ELSE      
                     aux_dtnasccj = STRING(DAY(crapcje.dtnasccj),"99") +
                                    STRING(MONTH(crapcje.dtnasccj),"99") +
                                    STRING(YEAR(crapcje.dtnasccj),"9999").
                  END.
    
                FIND crapcje WHERE crapcje.cdcooper = glb_cdcooper     AND
                                   crapcje.nrdconta = crapass.nrdconta AND
                                   crapcje.idseqttl = crapttl.idseqttl
                                   NO-LOCK NO-ERROR.
                IF AVAILABLE crapcje THEN
                  ASSIGN aux_nmconjug = f_tiraponto(crapcje.nmconjug).
                  
                ASSIGN aux_cdseqass = aux_cdseqass + 1
                       aux_nmmaettl = f_tiraponto(crapttl.nmmaettl)
                       aux_nmpaittl = f_tiraponto(crapttl.nmpaittl)
                       aux_nmextemp = f_tiraponto(crapttl.nmextemp).
                             
                /* ---------   Registro Detalhe  TIPO 02   ----------  */
                PUT STREAM str_3 aux_cdseqass       FORMAT "99999"
                                 "02"               /* registro detalhe */
                                 crapttl.nrcpfcgc   FORMAT "99999999999999"
                                 aux_nmmaettl       FORMAT "x(50)"
                                 aux_nmpaittl       FORMAT "x(50)"
                                 aux_nrcpfcjg       FORMAT "99999999999"
                                 aux_dtnasccj       FORMAT "x(08)"
                                 aux_nmconjug       FORMAT "x(50)"
                                 crapttl.tpcttrab   FORMAT "9"
                                 aux_inpessoa       FORMAT "9"
                                 crapttl.nrcpfemp   FORMAT "99999999999999"
                                 aux_dtadmemp       FORMAT "x(06)"
                                 aux_nmextemp       FORMAT "x(50)"
                                 crapttl.dsproftl   FORMAT "x(30)"
                                 crapttl.cdnvlcgo   FORMAT "9"
                                 FILL(" ",97)       FORMAT "x(97)"
                                 SKIP.
    
                IF   crapttl.idseqttl = 1 THEN
                     DO:
                        CREATE cratass.
                        ASSIGN cratass.cdagenci = crapass.cdagenci
                               cratass.nrdconta = crapttl.nrdconta
                               cratass.nmprimtl = crapass.nmprimtl
                               aux_nrcpfptl     = crapttl.nrcpfcgc.
                     END.
            END. /*   Fim do For Each crapttl   */
         END. /* Fim - pessoa FISICA */
    ELSE         
         /* Pessoa JURIDICA ou conta ADMINISTRATIVA */
         DO:
            FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                               crapjur.nrdconta = crapass.nrdconta   
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapjur   THEN
                 DO TRANSACTION:
                    
                    CREATE crapeca.
                    ASSIGN crapeca.nrdconta = crapass.nrdconta
                           crapeca.tparquiv = 500
                           crapeca.dscritic = "Associado com cadastro " +
                                              "incompleto"
                           crapeca.dtgerarq = glb_dtmvtolt
                           crapeca.nrseqarq = aux_nrseqarq
                           crapeca.cdcooper = glb_cdcooper
                           aux_nrseqarq     = aux_nrseqarq + 1.
                    VALIDATE crapeca.
                    NEXT.
                 
                 END.
                 
            ASSIGN aux_dtabertu = ?.
            
            FOR EACH crapsfn WHERE  crapsfn.cdcooper = glb_cdcooper     AND
                                    crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                                    crapsfn.tpregist = 1                NO-LOCK
                                        BY crapsfn.dtabtcct DESC:
                
                ASSIGN aux_dtabertu = crapsfn.dtabtcct. 
                                        
            END.       
            
            IF  crapass.dtabtcct <> ?                AND
                crapass.dtabtcct <  crapass.dtadmiss THEN
                ASSIGN aux_dtabtcc2 = crapass.dtabtcct.
            ELSE
                ASSIGN aux_dtabtcc2 = crapass.dtadmiss.
                
            IF  aux_dtabertu < aux_dtabtcc2 THEN
                aux_dtabtcct = STRING(DAY(aux_dtabertu),"99")   +
                               STRING(MONTH(aux_dtabertu),"99") +
                               STRING(YEAR(aux_dtabertu),"9999").
            ELSE
                aux_dtabtcct = STRING(DAY(aux_dtabtcc2),"99")   + 
                               STRING(MONTH(aux_dtabtcc2),"99") +
                               STRING(YEAR(aux_dtabtcc2),"9999").
            
            IF  crapjur.nmtalttl = ""  THEN
                RUN fontes/abreviar.p (INPUT  crapass.nmprimtl, INPUT 25,
                                       OUTPUT aux_nmrestal). 
            ELSE
                aux_nmrestal = crapjur.nmtalttl.
                
            ASSIGN aux_cdseqass = aux_cdseqass + 1
                   aux_cdseqt01 = aux_cdseqt01 + 1
                   aux_nrcpfcgc = crapass.nrcpfcgc
                   aux_inpessoa = 2
                   aux_dtnasctl = STRING(DAY(crapass.dtnasctl),"99")   +
                                  STRING(MONTH(crapass.dtnasctl),"99") +
                                  STRING(YEAR(crapass.dtnasctl),"9999")
                   aux_nmextass = f_tiraponto(crapass.nmprimtl)
                   aux_idseqttl = 1
                   aux_nrcpfptl = 0
                   aux_cdsexotl = ""
                   aux_tpnacion = 0
                   aux_dsnatura = ""
                   aux_cdtipdoc = 0
                   aux_nrdocttl = ""
                   aux_cdoedttl = ""
                   aux_dtemdttl = "00000000"
                   aux_cdestcvl = 0
                   aux_cdfrmttl = 0
                   aux_grescola = 0
                   aux_cdnatopc = 0
                   aux_cdocpttl = 0
                   aux_vlsalari = 0
                   aux_dtinires = ""
                   aux_idseqttl = 1
                   aux_nrdconta = crapass.nrdconta.
            
            RUN detalhe_tipo_1.

            CREATE cratass.
            ASSIGN cratass.cdagenci = crapass.cdagenci
                   cratass.nrdconta = crapass.nrdconta
                   cratass.nmprimtl = crapass.nmprimtl
                   aux_nrcpfptl     = crapass.nrcpfcgc.

         END. /* Fim - Pessoa JURIDICA ou conta ADMINISTRATIVA */
       
    DO TRANSACTION:
          
       DO WHILE TRUE:

          FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                             crabass.nrdconta = crapass.nrdconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
          IF   NOT AVAILABLE craptab   THEN
               DO:
                   IF   LOCKED craptab   THEN
                        DO:
                            glb_cdcritic = 72.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
               END.          
          ELSE
               glb_cdcritic = 0.

          LEAVE.

       END.  /*  Fim do DO .. TO  */

       IF   glb_cdcritic > 0 THEN
            RETURN.
       
       ASSIGN crabass.flgctitg = 1
              crabass.dtectitg = glb_dtmvtolt.
       
    END. /* DO TRANSACTION */  
              
END.    /*  fim do for each crapass */
   
IF   NOT aux_flgfirst THEN  /*  gerou algum arquivo  */
     DO:
         /* ------------   Trailer do Arquivo   ------------  */
                 
         PUT STREAM str_3 "9999999"
                          aux_cdseqt01          FORMAT "99999"
                          (aux_cdseqass + 2)    FORMAT "999999999"
                          FILL(" ",369)         FORMAT "x(369)" 
                          SKIP.            
                 
         OUTPUT STREAM str_3 CLOSE.

         glb_cdcritic = 847.
         RUN fontes/critic.p.
            
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - COO400 - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " - " + aux_nmarqdat + 
                           " >> " + aux_nmarqlog).
         
         UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqdat + 
                           ' | tr -d "\032"' +   
                           " > /micros/" + crapcop.dsdircop + 
                           "/compel/" + aux_nmarqdat + " 2>/dev/null").
         
         UNIX SILENT VALUE("mv arq/" + aux_nmarqdat + 
                           " salvar 2>/dev/null"). 
              
         DO TRANSACTION ON ENDKEY UNDO, LEAVE:

            /*   Atualiza a sequencia da remessa  */
               
            DO WHILE TRUE:

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                  craptab.nmsistem = "CRED"        AND
                                  craptab.tptabela = "GENERI"      AND
                                  craptab.cdempres = 00            AND
                                  craptab.cdacesso = "NRARQMVITG"  AND
                                  craptab.tpregist = 400
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

            SUBSTRING(craptab.dstextab,1,5) = STRING(aux_cdseqarq + 1,"99999").

         END. /* TRANSACTION */
           
     END.  /* fim do aux_flgfirst */ 

RUN p_imprime_aceitos.  /*   Imprime Rejeitados   */

RUN fontes/fimprg.p.

/* .......................................................................... */


PROCEDURE p_imprime_aceitos:
   
   DEFINE VARIABLE tot_qtdtotal AS INT                                NO-UNDO.
   DEFINE VARIABLE rel_dsagenci AS CHAR  FORMAT "x(21)"               NO-UNDO.
   DEFINE VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.
   DEFINE VARIABLE aux_flgfirst AS LOGICAL                            NO-UNDO.
   DEFINE VARIABLE aux_dtmvtolt AS DATE                               NO-UNDO.
   

   FORM rel_dsagenci AT  2 FORMAT "x(21)" LABEL "PA"
        SKIP(1)
        WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_agencia.

   FORM cratass.cdagenci  AT 06 FORMAT "zzz"        LABEL "PA"
        cratass.nrdconta  AT 14 FORMAT "zzzz,zzz,9" LABEL "CONTA/DV"
        cratass.nmprimtl  AT 30 FORMAT "x(40)"      LABEL "NOME"
        
        WITH NO-BOX NO-LABELS DOWN  WIDTH 132 FRAME f_descricao_ace.

   FORM SKIP(1)
        "TOTAL DE CONTAS ENVIADAS ==>"  AT  30
        tot_qtdtotal                    AT  67 FORMAT "zzz,zz9"
        SKIP(2)
        WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total_ace.

   { includes/cabrel132_1.i }  /*  Monta cabecalho do rel. de aceitos   */

   ASSIGN aux_nmarqimp = "rl/crrl374_" + STRING(TIME) + ".lst"
          tot_qtdtotal = 0.
            
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             
   VIEW STREAM str_1 FRAME f_cabrel132_1.
   
   FOR EACH cratass BY cratass.cdagenci
                      BY cratass.nrdconta:
   
       tot_qtdtotal = tot_qtdtotal + 1.

       DISPLAY STREAM str_1 cratass.cdagenci  cratass.nrdconta
                            cratass.nmprimtl  WITH FRAME f_descricao_ace.

       DOWN STREAM str_1 WITH FRAME f_descricao_ace.
 
       IF   LINE-COUNTER(str_1) >= 82 THEN
            PAGE STREAM str_1.
   END.
   
   DISPLAY STREAM str_1 tot_qtdtotal WITH FRAME f_total_ace.

   OUTPUT STREAM str_1 CLOSE.

   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqimp.
           
   RUN fontes/imprim.p.
                       
   /* se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" */
   IF   glb_inproces = 1   THEN
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv/" +
                          SUBSTRING(aux_nmarqimp,R-INDEX(aux_nmarqimp,"/") + 1,
                          LENGTH(aux_nmarqimp) - R-INDEX(aux_nmarqimp,"/"))).

END.   /*  fim da PROCEDURE  */

PROCEDURE detalhe_tipo_1:
                     
    /* ------------   Registro Detalhe  TIPO 01   ------------  */    
    PUT STREAM str_3 aux_cdseqass                     FORMAT "99999"
                     "01"                             /* registro detalhe */
                     aux_nrcpfcgc                     FORMAT "99999999999999"
                     aux_inpessoa                     FORMAT "9"
                     aux_dtnasctl                     FORMAT "99999999"
                     aux_nmextass                     FORMAT "x(50)"
                     aux_nmrestal                     FORMAT "x(25)"
                     aux_idseqttl                     FORMAT "9"
                     aux_nrcpfptl                     FORMAT "99999999999999"
                     aux_cdsexotl                     FORMAT "x"
                     aux_tpnacion                     FORMAT "99"
                     aux_dsnatura                     FORMAT "x(25)"
                     aux_cdtipdoc                     FORMAT "99"
                     aux_nrdocttl                     FORMAT "x(20)"
                     aux_cdoedttl                     FORMAT "x(15)"
                     aux_dtemdttl                     FORMAT "99999999"
                     aux_cdestcvl                     FORMAT "99"
                     "1"                              /*capac. civil - CAPAZ*/
                     aux_cdfrmttl                     FORMAT "999"
                     aux_grescola                     FORMAT "999"
                     aux_cdnatopc                     FORMAT "999"
                     aux_cdocpttl                     FORMAT "999"
                     aux_vlsalari                     FORMAT "999999999999999"
                     aux_mesanord                     FORMAT "999999"
                     aux_dsendere                     FORMAT "x(35)"
                     aux_nmbairro                     FORMAT "x(30)"
                     aux_nrcepend                     FORMAT "99999999"
                     aux_nrdddcop                     FORMAT "99"
                     aux_nrtelcop                     FORMAT "999999999"
                     aux_nrcxapst                     FORMAT "999999999"
                     aux_incasprp                     FORMAT "99"
                     aux_dtinires                     FORMAT "999999"
                     "S"                              /* Ind. uso talonario */
                     aux_idseqttl                     FORMAT "9"
                     "            "
                     aux_dtabtcct                     FORMAT "99999999"
                     STRING(aux_nrdconta,"99999999")  FORMAT "x(17)"   
                     "0000"                           /* Cod. modalidade */
                     FILL(" ",17)                     FORMAT "x(17)" 
                     SKIP.
END PROCEDURE.


/* .......................................................................... */



