/* ..........................................................................

   Programa: Fontes/crps511.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2008.                     Ultima atualizacao: 01/06/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importar arquivos XML referente TED'S.
    
   Alteracoes: 21/07/2008 - Mover arquivo para diretorio salvar quando registro
                            de TEC ja existir;
                          - Efetuados acertos no LOG (Diego).
                          
               02/10/2008 - Abortar programa quando processo estiver rodando
                            (Diego).
                            
               14/09/2009 - Verificar cooperado por Conta e Cpf (Diego).
               
               17/12/2012 - Nao integrar quando crapass.cdsitdct = 4 (Diego).
               
               03/01/2014 - Trocar Agencia por PA (Reinert)
               
               23/03/2015 - Tratamento para rejeitar todas mensagens e gerar
                            apenas os Logs de erro - SD 174586 (Tiago).
               
               01/06/2015 - No chamado 174586 foi solicitado para que certos trechos
                            de codigo nao fossem executado, para isso foi posto
                            um NEXT para que eles nao executassem, porem esses 
                            codigos inutilizados estavam ocasionando warning 
                            no momento de compilacao, sendo assim eles foram
                            removidos SD 291324 (Kelvin)
 ........................................................................... */

{ includes/var_batch.i  "NEW" }

DEF STREAM str_1.
DEF STREAM str_2.   /*  Para arquivo XML de erro  */ 

DEF VAR aux_cdagenci      AS INT     INIT 1                         NO-UNDO.
DEF VAR aux_cdbccxlt      AS INT     INIT 100                       NO-UNDO.
DEF VAR aux_nrdolote      AS INT     INIT 10115                     NO-UNDO.
DEF VAR aux_tplotmov      AS INT     INIT 1                         NO-UNDO.
DEF VAR aux_nmarquiv      AS CHAR                                   NO-UNDO.
DEF VAR aux_nmarqxml      AS CHAR                                   NO-UNDO.
DEF VAR aux_nmarqlog      AS CHAR                                   NO-UNDO.
DEF VAR aux_contador      AS INT                                    NO-UNDO.
DEF VAR aux_textoxml      AS CHAR    EXTENT 21                      NO-UNDO.
DEF VAR aux_nrdocmto      AS DEC                                    NO-UNDO.

DEF VAR aux_AgCredtd      AS CHAR                                   NO-UNDO.
DEF VAR aux_CtCredtd      AS CHAR                                   NO-UNDO.
DEF VAR aux_dadosdeb      AS CHAR                                   NO-UNDO.
DEF VAR aux_codierro      AS INT                                    NO-UNDO.
DEF VAR aux_CPFCliDebtd   AS CHAR                                   NO-UNDO.


/*  Utilizadas no arquivo de erro  */
DEF VAR aux_Cooperativa   AS CHAR                                   NO-UNDO.
DEF VAR aux_DataHora      AS CHAR                                   NO-UNDO.
DEF VAR aux_NumSeq        AS CHAR                                   NO-UNDO.
DEF VAR aux_CodMsg        AS CHAR                                   NO-UNDO.
DEF VAR aux_NumCtrlIF     AS CHAR                                   NO-UNDO.
DEF VAR aux_ISPBIFDebtd   AS CHAR                                   NO-UNDO.
DEF VAR aux_ISPBIFCredtd  AS CHAR                                   NO-UNDO.
DEF VAR aux_VlrLanc       AS CHAR                                   NO-UNDO.
DEF VAR aux_CodDevTransf  AS CHAR                                   NO-UNDO.
DEF VAR aux_Hist          AS CHAR                                   NO-UNDO.
DEF VAR aux_NivelPref     AS CHAR                                   NO-UNDO.
DEF VAR aux_DtMovto       AS CHAR                                   NO-UNDO.

/*  Variaveis para importacao do XML */ 
DEF VAR hDoc              AS HANDLE                                 NO-UNDO.
DEF VAR hRoot             AS HANDLE                                 NO-UNDO.
DEF VAR hNode             AS HANDLE                                 NO-UNDO.
DEF VAR hSubNode          AS HANDLE                                 NO-UNDO.
DEF VAR hNameTag          AS HANDLE                                 NO-UNDO.
DEF VAR hTextTag          AS HANDLE                                 NO-UNDO.

DEFINE TEMP-TABLE crawarq                                           NO-UNDO
       FIELD nrsequen AS INTEGER
       FIELD nmarquiv AS CHAR
       INDEX crawarq1 AS PRIMARY
             nrsequen nmarquiv.
       

ASSIGN glb_cdprogra = "crps511".

ASSIGN glb_cdcooper = INT(SESSION:PARAMETER).

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/* Busca data do sistema */ 

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAIL crapdat THEN 
     DO:
         ASSIGN glb_cdcritic = 1.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.   
                                                    
/* Abortar programa quando processo estiver rodando */ 
IF   TODAY > crapdat.dtmvtolt  THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           "Processo rodando !!" + " >> log/proc_batch.log").
         QUIT.
     
     END.                                              
                
ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                      "/integra/msgr_bancoob_*.xml"
       aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" + 
                      "mqbancoob_processa_" +
                      STRING(crapdat.dtmvtolt,"999999") + ".log"
       aux_contador = 0.
                      
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.
            
   ASSIGN aux_contador = aux_contador + 1.
   
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = aux_contador
          crawarq.nmarquiv = aux_nmarquiv.
          
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.
    

FOR EACH crawarq NO-LOCK BY crawarq.nrsequen:

    /**  Objetos utilizados na leitura do XML  **/
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.
    CREATE X-NODEREF  hNode.
    CREATE X-NODEREF  hSubNode.
    CREATE X-NODEREF  hNameTag.
    CREATE X-NODEREF  hTextTag.

    ASSIGN aux_codierro = 0
           aux_dadosdeb = ""
           aux_nmarqxml = SUBSTRING(crawarq.nmarquiv,
                          R-INDEX(crawarq.nmarquiv,"/") + 1).
    
    /** Metodo para importar o arquivo XML **/
    hDoc:LOAD("FILE",crawarq.nmarquiv,FALSE).
        
    /** Obtem TAG Root "MQRecebimento" do XML **/
    hDoc:GET-CHILD(hRoot,1).
    
  
    /** Obtem TAG "Header" **/
    hRoot:GET-CHILD(hNode,2).
    
    /** Efetua leitura dos dados do Header **/
    DO aux_contador = 1 TO hNode:NUM-CHILDREN:
    
       hNode:GET-CHILD(hNameTag,aux_contador).
       
       IF   hNameTag:NAME <> "#text"  THEN
            DO:
                hNameTag:GET-CHILD(hTextTag,1) NO-ERROR.
                
                IF   hNameTag:NAME = "Cooperativa"  THEN
                     ASSIGN aux_Cooperativa = hTextTag:NODE-VALUE.
                ELSE
                IF   hNameTag:NAME = "DataHora"  THEN
                     ASSIGN aux_DataHora = hTextTag:NODE-VALUE.
                ELSE
                     ASSIGN aux_NumSeq = hTextTag:NODE-VALUE.
                
            END.
    END.
    
    
    /** Obtem TAG "MsgSPB" **/
    hRoot:GET-CHILD(hNode,4).                           

    /** Obtem NODE pai da Mensagem (MsgSPB) **/
    hNode:GET-CHILD(hSubNode,2). 
    
    /** Efetua leitura dos dados da mensagem **/
    DO aux_contador = 1 TO hSubNode:NUM-CHILDREN:
                
       /** Obtem TAG com dado da mensagem **/
       hSubNode:GET-CHILD(hNameTag,aux_contador).

       /** Gerar registro somente quando for uma tag valida **/ 
       IF   hNameTag:NAME <> "#text"  THEN
            DO:
                /** Obtem conteudo da Tag de dado da mensagem **/
                hNameTag:GET-CHILD(hTextTag,1) NO-ERROR.
                        
                IF   ERROR-STATUS:ERROR             OR
                     ERROR-STATUS:NUM-MESSAGES > 0  THEN
                     NEXT.
                
                IF  hNameTag:NAME = "CodMsg"  THEN
                    ASSIGN aux_CodMsg = hTextTag:NODE-VALUE.
                ELSE                
                IF  hNameTag:NAME  MATCHES  "NumCtrl*"  THEN
                    ASSIGN aux_NumCtrlIF = hTextTag:NODE-VALUE.
                ELSE                     
                IF  hNameTag:NAME = "ISPBIFDebtd"  THEN
                    ASSIGN aux_ISPBIFDebtd = hTextTag:NODE-VALUE.
                ELSE
                IF  hNameTag:NAME = "AgDebtd"  OR
                    hNameTag:NAME = "CtDebtd"  OR
                    hNameTag:NAME = "CPFCliDebtd"  THEN
                    DO:
                        IF   hNameTag:NAME = "CPFCliDebtd"  THEN
                             ASSIGN aux_CPFCliDebtd = hTextTag:NODE-VALUE.
                        
                        IF   aux_dadosdeb = ""  THEN
                             ASSIGN aux_dadosdeb = hNameTag:NAME + ":" +
                                                   hTextTag:NODE-VALUE.
                        ELSE
                             ASSIGN aux_dadosdeb = aux_dadosdeb + " / " +
                                                   hNameTag:NAME + ":" +
                                                   hTextTag:NODE-VALUE.
                                                    
                    END.
                ELSE
                IF  hNameTag:NAME = "ISPBIFCredtd" THEN
                    ASSIGN aux_ISPBIFCredtd = hTextTag:NODE-VALUE.
                ELSE
                IF  hNameTag:NAME = "AgCredtd"  THEN
                    DO: 
                        ASSIGN aux_AgCredtd = hTextTag:NODE-VALUE.
                        
                        /*  Se for de outra cooperativa  */
                        IF  crapcop.cdagebcb <> INT(hTextTag:NODE-VALUE)  THEN
                            LEAVE.
                    END.
                ELSE
                IF  hNameTag:NAME = "CtCredtd"  THEN
                    DO:
                        FIND FIRST crapttl WHERE 
                                crapttl.cdcooper = glb_cdcooper             AND
                                crapttl.nrdconta = INT(hTextTag:NODE-VALUE) AND
                                crapttl.nrcpfcgc = DEC(aux_CPFCliDebtd)
                                NO-LOCK NO-ERROR.
                              
                        IF   NOT AVAIL crapttl  THEN
                             ASSIGN aux_codierro = 2.  /* Conta invalida */
                        ELSE
                             DO:
                                 FIND crapass WHERE
                                      crapass.cdcooper = glb_cdcooper     AND
                                      crapass.nrdconta = crapttl.nrdconta
                                      NO-LOCK NO-ERROR.
                             
                                 IF   crapass.dtelimin <> ?  OR
                                      crapass.cdsitdct = 4  THEN
                                      /* Conta encerrada */
                                      ASSIGN aux_codierro = 1.   
                             END.
                              
                        ASSIGN aux_CtCredtd = hTextTag:NODE-VALUE.
                    END.
                ELSE
                IF  hNameTag:NAME = "VlrLanc"  THEN 
                    ASSIGN aux_VlrLanc = hTextTag:NODE-VALUE
                           aux_VlrLanc = REPLACE(aux_VlrLanc,".",",").
                ELSE
                IF  hNameTag:NAME = "CodIdentdTransf"  THEN
                    ASSIGN aux_CodDevTransf = hTextTag:NODE-VALUE.
                ELSE
                IF  hNameTag:NAME = "DtMovto"  THEN
                    ASSIGN aux_DtMovto = SUBSTRING(hTextTag:NODE-VALUE,1,10).
                 
            END. 

    END. /** Fim do DO ... TO **/

    /***********************************************************************/
    /***                             ATENCAO                             ***/
    /***********************************************************************/
    /* Este tratamento das mensagens foi retirado para que todos arquivos  */
    /* processados por este programa sejam rejeitados SoftDesk 174586.     */
    /*                                                                     */
    /* Foi removido todos os trechos de código abaixo do NEXT usado no     */
    /* chamado acima, pois estava gerando warning no momento de compilar   */
    /* SD 291324 (Kelvin)                                                  */
    /***********************************************************************/
    
     UNIX SILENT VALUE ("mv " + crawarq.nmarquiv + " salvar/" +
                        aux_nmarqxml). 
            
     /* Logar */
     UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") +
                        " - " + STRING(TIME,"HH:MM:SS") +
                        " - " + glb_cdprogra + " - ERRO    --> "  +
                        "Arquivo " + aux_nmarqxml + " nao foi " +
                        "processado. Evento: " + aux_CodMsg + 
                        " , Valor: " + aux_VlrLanc + '"' + " >> "  
                        + aux_nmarqlog).
                        
     NEXT.
END.

PROCEDURE gera_erro_xml:

  ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop +
                        "/integra/msge_bancoob_" + STRING(YEAR(TODAY),"9999")
                        + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")
                        + STRING(ETIME,"99999999") + ".xml"
                        
         aux_VlrLanc  = REPLACE(aux_VlrLanc,",",".")
         aux_DataHora = REPLACE(aux_DataHora," ","T").             
                              
  ASSIGN aux_textoxml[1] = "<MQEnvio>"
         aux_textoxml[2] = "<Header>" 
         aux_textoxml[3] = "   <Cooperativa>" + aux_Cooperativa +
                             "</Cooperativa>"
         aux_textoxml[4] = "   <DataHora>" + aux_DataHora + "</DataHora>"
         aux_textoxml[5] = "   <NumSeq>" + aux_NumSeq + "</NumSeq>"
         aux_textoxml[6] = "</Header>"
         aux_textoxml[7] = "<MsgSPB>".
                                                
  
  IF   aux_CodMsg = "STR0037R2"  THEN
       ASSIGN aux_textoxml[8]  = "<STRReqTransfDevolTransfIndevida>"
              aux_textoxml[9]  = "   <CodMsg>STR0010</CodMsg>"
              aux_textoxml[10] = "   <NumCtrlIF>" + aux_NumCtrlIF + 
                                   "</NumCtrlIF>" 
              aux_textoxml[11] = "   <ISPBIFDebtd>" + aux_ISPBIFCredtd + 
                                   "</ISPBIFDebtd>"
              aux_textoxml[12] = "   <ISPBIFCredtd>" + aux_ISPBIFDebtd + 
                                   "</ISPBIFCredtd>"
              aux_textoxml[13] = "   <VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[14] = "   <CodDevTransf>" + STRING(aux_codierro) + 
                                   "</CodDevTransf>"
              aux_textoxml[15] = "   <NumCtrlSTROr>" + aux_NumCtrlIF + 
                                   "</NumCtrlSTROr>"
              aux_textoxml[16] = "   <Hist>" + aux_Hist + "</Hist>"
              aux_textoxml[17] = "   <NivelPref>" + aux_NivelPref +
                                   "</NivelPref>"
              aux_textoxml[18] = "   <DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[19] = "</STRReqTransfDevolTransfIndevida>"
              aux_textoxml[20] = "</MsgSPB>"
              aux_textoxml[21] = "</MQEnvio>".
  ELSE
  IF   aux_CodMsg = "PAG0137R2"  THEN
       ASSIGN aux_textoxml[8]  = "<PAGReqDevolTransfIndevida>"
              aux_textoxml[9]  = "   <CodMsg>PAG0111</CodMsg>"
              aux_textoxml[10] = "   <NumCtrlIF>" + aux_NumCtrlIF + 
                                   "</NumCtrlIF>" 
              aux_textoxml[11] = "   <ISPBIFDebtd>" + aux_ISPBIFCredtd + 
                                   "</ISPBIFDebtd>"
              aux_textoxml[12] = "   <ISPBIFCredtd>" + aux_ISPBIFDebtd + 
                                   "</ISPBIFCredtd>"
              aux_textoxml[13] = "   <VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[14] = "   <CodDevTransf>" + STRING(aux_codierro) + 
                                   "</CodDevTransf>"
              aux_textoxml[15] = "   <NumCtrlPAGOr>" + aux_NumCtrlIF + 
                                   "</NumCtrlPAGOr>"
              aux_textoxml[16] = "   <Hist>" + aux_Hist + "</Hist>"
              aux_textoxml[17] = "   <NivelPrefPAG>" + aux_NivelPref +
                                   "</NivelPrefPAG>"
              aux_textoxml[18] = "   <DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[19] = "</PAGReqDevolTransfIndevida>"
              aux_textoxml[20] = "</MsgSPB>"
              aux_textoxml[21] = "</MQEnvio>".
  ELSE
       ASSIGN aux_textoxml[8]  = "<DECReqTransfDevolTransfIndevida>"
              aux_textoxml[9]  = "   <CodMsg>DEC0010</CodMsg>"
              aux_textoxml[10] = "   <NumCtrlIF>" + aux_NumCtrlIF + 
                                   "</NumCtrlIF>"
              aux_textoxml[11] = "   <VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[12] = "   <CodDevTransf>" + STRING(aux_codierro) + 
                                   "</CodDevTransf>"
              aux_textoxml[13] = "   <NumCtrlDECOr>" + aux_NumCtrlIF + 
                                   "</NumCtrlDECOr>"
              aux_textoxml[14] = "   <Hist>" + aux_Hist + "</Hist>"
              aux_textoxml[15] = "   <NivelPref>" + aux_NivelPref +
                                   "</NivelPref>"
              aux_textoxml[16] = "   <DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[17] = "</DECReqTransfDevolTransfIndevida>"
              aux_textoxml[18] = "</MsgSPB>"
              aux_textoxml[19] = "</MQEnvio>"
              aux_textoxml[20] = ""
              aux_textoxml[21] = "".
  

  OUTPUT STREAM str_2 TO VALUE (aux_nmarquiv).

  DO   aux_contador = 1 TO 21:
  
       PUT STREAM str_2 aux_textoxml[aux_contador]  FORMAT "x(80)" SKIP.
  END.
  
  OUTPUT STREAM str_2 CLOSE.
  
  /* copia XML de erro para o diretorio salvar */
  UNIX SILENT VALUE ("cp " + aux_nmarquiv + " salvar/").

  /* move o arquivo para o diretorio salvar */
  UNIX SILENT VALUE ("mv " + crawarq.nmarquiv + " salvar/" + aux_nmarqxml).
                    
  /* Logar */
  UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
                     STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra +
                     " - ERRO    --> "  + "Arquivo " + aux_nmarqxml +
                     " nao foi processado. Age. Coop: " + aux_AgCredtd +
                     " , Conta: " + aux_CtCredtd + " , Valor: " + 
                     aux_VlrLanc + '"' + " >> " +
                     aux_nmarqlog).
  
  DELETE OBJECT hTextTag.                                          
  DELETE OBJECT hNameTag.
  DELETE OBJECT hSubNode.
  DELETE OBJECT hNode.
  DELETE OBJECT hRoot.
  DELETE OBJECT hDoc.

END PROCEDURE.


/* .......................................................................... */
