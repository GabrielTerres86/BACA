/******************************************************************************
 
 Programa: sistema/generico/procedures/superXML.p
 Data:  31/05/2007                             Ultima atualizacao: 21/10/2010
 Autor: Murilo Pereira - SQLWorks                     

 Objetivo: Super-procedure contendo metodos comuns para as XBOs 

 Alteracoes: Alimentar NODE-VALUE piXmlSaida e piXmlExport sempre como STRING
             (Guilherme).
             
             Alteradas as linhas 189 e 315 pois o contador "J" estava sendo 
             referenciado indevidamente nos casos em que o campo é do tipo DATE,
             o erro ocorria qdo apos a leitura de um campo c/ EXTENT
             (Jose Luis Marchezoni, DB1 - 17/03/10)
             
             Controle de registros itens/filhos, Procedure 'piAbreXML'
             (Jose Luis Marchezoni, DB1 - 08/07/10)
             
             21/10/2010 - Tratamento para leitura do node PERMISSAO (David).
             
******************************************************************************/

DEFINE VARIABLE hXDoc       AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXRoot      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXCampo     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXNodeDados AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXRegistro  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXExtent    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hXValue     AS HANDLE     NO-UNDO.

DEFINE VARIABLE hTempTable AS HANDLE      NO-UNDO.
DEFINE VARIABLE hBufferTT  AS HANDLE      NO-UNDO.
DEFINE VARIABLE hBufferRaw AS HANDLE      NO-UNDO.
DEFINE VARIABLE hFieldRaw  AS HANDLE      NO-UNDO.

DEFINE VARIABLE i AS INTEGER    NO-UNDO.
DEFINE VARIABLE j AS INTEGER    NO-UNDO.

DEF TEMP-TABLE tt-erro  NO-UNDO LIKE craperr.

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD nomeCampo  AS CHARACTER
    FIELD valorCampo AS CHARACTER.

DEF TEMP-TABLE tt-param-i NO-UNDO
    FIELD SqControle AS INTEGER
    FIELD nomeTabela AS CHARACTER
    FIELD nomeCampo  AS CHARACTER
    FIELD valorCampo AS CHARACTER.

DEF TEMP-TABLE tt-permis-acesso NO-UNDO
    FIELD nmdatela AS CHAR
    FIELD nmrotina AS CHAR
    FIELD cddopcao AS CHAR
    FIELD idsistem AS INTE
    FIELD cdagecxa AS INTE
    FIELD nrdcaixa AS INTE
    FIELD cdopecxa AS CHAR
    FIELD idorigem AS INTE.

PROCEDURE piAbreXML:
/* Abre o XML e popula parametros */
    DEFINE INPUT  PARAMETER hXBO         AS HANDLE     NO-UNDO. /*X-Doc da XBO*/
    DEFINE OUTPUT PARAMETER TABLE FOR tt-param.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-param-i.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-permis-acesso.

    DEFINE VARIABLE hXDoc       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hCabecalho  AS HANDLE     NO-UNDO. /* Contem o ROOT      */
    DEFINE VARIABLE hTag        AS HANDLE     NO-UNDO. /* Contem o tag Dados */
    DEFINE VARIABLE hParam      AS HANDLE     NO-UNDO. /* Contem os valores  */
    DEFINE VARIABLE hTagI       AS HANDLE     NO-UNDO. /* Contem o tag Dados */
    DEFINE VARIABLE hParamI     AS HANDLE     NO-UNDO. /* Contem os valores  */
                                
    DEFINE VARIABLE i           AS INTEGER    NO-UNDO.
    DEFINE VARIABLE j           AS INTEGER    NO-UNDO.
    DEFINE VARIABLE m           AS INTEGER    NO-UNDO.
    DEFINE VARIABLE n           AS INTEGER    NO-UNDO.
    DEFINE VARIABLE cNomeCampo  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iElementos  AS INTEGER    NO-UNDO.
    DEFINE VARIABLE iSqControle AS INTEGER    NO-UNDO.
    
    DEFINE VARIABLE aux_nmdatela AS CHARACTER NO-UNDO.           
    DEFINE VARIABLE aux_nmrotina AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aux_cddopcao AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aux_idsistem AS INTEGER   NO-UNDO.
    DEFINE VARIABLE aux_cdagecxa AS INTEGER   NO-UNDO.
    DEFINE VARIABLE aux_nrdcaixa AS INTEGER   NO-UNDO.
    DEFINE VARIABLE aux_cdopecxa AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aux_idorigem AS INTEGER   NO-UNDO.

    DEFINE VARIABLE lOk AS LOGICAL NO-UNDO.

    /*  Abertura do XML */
    /*CREATE X-DOCUMENT hXDoc.*/
    CREATE X-NODEREF  hCabecalho.
    CREATE X-NODEREF  hTag.
    CREATE X-NODEREF  hParam.
    CREATE X-NODEREF  hTagI.
    CREATE X-NODEREF  hParamI.
    
    ASSIGN hXDoc = hXBO.
    /* Abertura do XML */

    EMPTY TEMP-TABLE tt-param.
    EMPTY TEMP-TABLE tt-param-i.
    EMPTY TEMP-TABLE tt-permis-acesso.
    
    /*  Busca os dados para executar as procedures internas */
    hXDoc:GET-CHILD(hCabecalho,1).
    DO j = 1 TO hCabecalho:NUM-CHILDREN:
       hCabecalho:GET-CHILD(hTag,j).

       IF  hTag:NAME = "Dados" THEN DO:
           DO i = 1 TO hTag:NUM-CHILDREN:

               hTag:GET-CHILD(hParam,i).

               IF  hParam:NAME = '#text' THEN
                   NEXT.

               /* percorrer os registros filhos */
               DO m = 1 TO hParam:NUM-CHILDREN:
                   hParam:GET-CHILD(hTagI,m).

                   IF  hTagI:NAME = '#text' THEN
                       NEXT.

                   ASSIGN iSqControle = iSqControle + 1.

                   DO n = 1 TO hTagI:NUM-CHILDREN:
                       hTagI:GET-CHILD(hParamI,n).

                       IF  hParamI:NAME = '#text' THEN
                           NEXT.

                       CREATE tt-param-i.
                       ASSIGN
                           tt-param-i.sqControle = iSqControle
                           tt-param-i.nomeTabela = hParam:NAME
                           tt-param-i.nomeCampo  = hParamI:NAME.

                       hParamI:GET-CHILD(hParamI,1) NO-ERROR.

                       IF  ERROR-STATUS:ERROR             OR
                           ERROR-STATUS:NUM-MESSAGES > 0  THEN
                           NEXT.

                       IF  hParamI:SUBTYPE = "Text"  THEN
                           tt-param-i.valorCampo = REPLACE(
                               hParamI:NODE-VALUE,"%20"," ").
                   END.
               END.

               ASSIGN
                   cNomeCampo  = hParam:NAME
                   iElementos  = hParam:NUM-CHILDREN.

               hParam:GET-CHILD(hParam,1) NO-ERROR.

               IF  ERROR-STATUS:ERROR             OR
                   ERROR-STATUS:NUM-MESSAGES > 0  THEN
                   NEXT.

               /* nao criar registros se for um noh de dados (filhos) */
               IF  hParam:SUBTYPE = "Text" AND iElementos = 1 THEN
                   DO:
                      CREATE tt-param.
                      ASSIGN
                          tt-param.nomeCampo = cNomeCampo
                          tt-param.valorCampo = REPLACE(
                                                hParam:NODE-VALUE,"%20"," ").
                   END.
           END. /* Fim do DO i = 1 TO hTag:NUM-CHILDREN: */
       END. /* Fim do IF .. THEN DO */

       IF  hTag:NAME = "Permissao" THEN DO:
           DO i = 1 TO hTag:NUM-CHILDREN:

               hTag:GET-CHILD(hParam,i).

               IF  hParam:NAME = '#text' THEN
                   NEXT.

               ASSIGN cNomeCampo = hParam:NAME.

               hParam:GET-CHILD(hParam,1) NO-ERROR.

               IF  ERROR-STATUS:ERROR             OR
                   ERROR-STATUS:NUM-MESSAGES > 0  OR 
                   hParam:SUBTYPE <> "Text"       THEN
                   NEXT.

               CASE cNomeCampo:
                   WHEN "nmdatela" THEN 
                        aux_nmdatela = REPLACE(hParam:NODE-VALUE,"%20"," ").
                   WHEN "nmrotina" THEN 
                        aux_nmrotina = REPLACE(hParam:NODE-VALUE,"%20"," ").
                   WHEN "cddopcao" THEN 
                        aux_cddopcao = REPLACE(hParam:NODE-VALUE,"%20"," ").
                   WHEN "idsistem" THEN 
                        aux_idsistem = INTE(REPLACE(hParam:NODE-VALUE,
                                                    "%20"," ")).
                   WHEN "cdagecxa" THEN 
                        aux_cdagecxa = INTE(REPLACE(hParam:NODE-VALUE,
                                                    "%20"," ")).
                   WHEN "nrdcaixa" THEN 
                        aux_nrdcaixa = INTE(REPLACE(hParam:NODE-VALUE,
                                                    "%20"," ")).
                   WHEN "cdopecxa" THEN
                        aux_cdopecxa = REPLACE(hParam:NODE-VALUE,"%20"," ").
                   WHEN "idorigem" THEN 
                        aux_idorigem = INTE(REPLACE(hParam:NODE-VALUE,
                                                    "%20"," ")).
               END CASE.

           END.

           IF  aux_nmdatela <> ""  THEN DO:
               CREATE tt-permis-acesso.
               ASSIGN tt-permis-acesso.nmdatela = aux_nmdatela
                      tt-permis-acesso.nmrotina = aux_nmrotina
                      tt-permis-acesso.cddopcao = aux_cddopcao
                      tt-permis-acesso.idsistem = aux_idsistem
                      tt-permis-acesso.cdagecxa = aux_cdagecxa
                      tt-permis-acesso.nrdcaixa = aux_nrdcaixa
                      tt-permis-acesso.cdopecxa = aux_cdopecxa
                      tt-permis-acesso.idorigem = aux_idorigem.
           END.
       END.

    END. /* Fim do DO j = 1 TO hCabecalho:NUM-CHILDREN: */
    /* /Busca os dados para executar as procedures internas */
    
    /*  Destroi os objetos X-Document */
    DELETE OBJECT hXDoc.
    DELETE OBJECT hCabecalho.
    DELETE OBJECT hTag.
    DELETE OBJECT hParam.

    IF  VALID-HANDLE(hTagI) THEN
        DELETE OBJECT hTagI.

    IF  VALID-HANDLE(hParamI) THEN
        DELETE OBJECT hParamI.
    /* /Destroi os objetos X-Document */

END PROCEDURE.





PROCEDURE piXmlSaida:
   /* Variaveis de TT dinamica */
   DEFINE INPUT  PARAMETER hTempTable AS HANDLE     NO-UNDO.
   DEFINE INPUT  PARAMETER cTagName   AS CHARACTER  NO-UNDO.
           
   DEFINE VARIABLE hQuery  AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
   /* /Variaveis de TT dinamica */

   DEFINE VARIABLE hXDoc       AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXRoot      AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXCampo     AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXNodeDados AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXRegistro  AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXExtent    AS HANDLE     NO-UNDO.
   DEFINE VARIABLE hXValue     AS HANDLE     NO-UNDO.

   DEFINE VARIABLE i AS INTEGER    NO-UNDO.
   DEFINE VARIABLE j AS INTEGER    NO-UNDO.
   
   /*  Instancia de Query/Tabela Dinamica */         
   CREATE BUFFER hBuffer FOR TABLE hTempTable:DEFAULT-BUFFER-HANDLE.
                   
   CREATE QUERY hQuery.
   hQuery:SET-BUFFERS(hBuffer).
   hQuery:QUERY-PREPARE("for each " + hTempTable:NAME).
   hQuery:QUERY-OPEN.
   /* /Instancia de Query/Tabela Dinamica */
   
   /*  Instancia de X-Document */
   CREATE X-DOCUMENT hXDoc.
   hXDoc:ENCODING = "ISO-8859-1".
   
   CREATE X-NODEREF  hXRoot.
   CREATE X-NODEREF  hXCampo.
   CREATE X-NODEREF  hXNodeDados.
   CREATE X-NODEREF  hXRegistro.
   CREATE X-NODEREF  hXExtent.
   CREATE X-NODEREF  hXValue.
   hXDoc:CREATE-NODE(hXRoot, "Root", "ELEMENT"). 
   hXDoc:APPEND-CHILD(hXRoot).
   hXDoc:CREATE-NODE(hXNodeDados, cTagName, "ELEMENT").
   hXRoot:APPEND-CHILD(hXNodeDados).
   /* /Instancia de X-Document */
   IF   hTempTable:HAS-RECORDS THEN
        DO:
           hQuery:GET-FIRST.
           DO WHILE NOT hQuery:QUERY-OFF-END:
              hXDoc:CREATE-NODE(hXRegistro, "Registro", "ELEMENT").
              hXNodeDados:APPEND-CHILD(hXRegistro).
              DO i = 1 TO hBuffer:NUM-FIELDS:
                 /* Cria o node com o nome da temp-table */ 
                 hXDoc:CREATE-NODE(hXCampo, 
                                   hBuffer:BUFFER-FIELD(i):NAME,
                                   "ELEMENT").   
                 /* Se a var e extent,poe um attr na tag com o nr de extents */                  
                 IF   hBuffer:BUFFER-FIELD(i):EXTENT > 0 THEN 
                      DO:
                         DO   j = 1 TO hBuffer:BUFFER-FIELD(i):EXTENT:
                              hXCampo:SET-ATTRIBUTE("Extent",
                                      STRING(hBuffer:BUFFER-FIELD(i):EXTENT)).
                              
                              hXRegistro:APPEND-CHILD(hXCampo).
                              
                              hXDoc:CREATE-NODE(hXExtent,
                                                hBuffer:BUFFER-FIELD(i):NAME 
                                                + "." + STRING(j), "ELEMENT").
                              
                              hXCampo:APPEND-CHILD(hXExtent).
                              
                              /*Cria node de texto e coloca no node de campo */
                              hXDoc:CREATE-NODE(hXValue, "", "Text").
                              
                              hXValue:NODE-VALUE = 
                              IF  hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[j] = ?
                                  THEN " "
                              ELSE 
                              IF  hBuffer:BUFFER-FIELD(i):DATA-TYPE = "DATE"
                           THEN STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[J],
                                       "99/99/9999")
                              ELSE
                              STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[j]).
                              
                              hXExtent:APPEND-CHILD(hXValue).
                         END. /* DO j = 1 to.. */
                      END. /* IF hBuffer:buffer-field... */
                 ELSE DO:
                    hXRegistro:APPEND-CHILD(hXCampo).
                    /* Cria o node com o valor do campo na temp-table */ 
                    hXDoc:CREATE-NODE(hXValue, "", "TEXT"). 
                    
                    hXValue:NODE-VALUE = 
                        IF   hBuffer:BUFFER-FIELD(i):BUFFER-VALUE() = ? THEN
                             " " 
                        ELSE 
                        IF   hBuffer:BUFFER-FIELD(i):DATA-TYPE = "DATE" THEN 
                             /*STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[J],
                               [J] = retirada a referencia JOSE LUIS, 17/03/10 */
                             STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE(), 
                                    "99/99/9999")
                        ELSE 
                             STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE()).
                    
                    hXCampo:APPEND-CHILD(hXValue).
                 END.
              END. /* DO i = 1 TO .. */
              hQuery:GET-NEXT().
           END. /* DO WHILE NOT .. */
        END. /* if hTempTable:HAS-RECORDS */
      
      /*  Output do XML resultado para a Web (com ou sem erro) */
      hXDoc:SAVE("stream", 
                 "webstream").
      /* /Output do XML */
      
      /*  Destroi objetos X-Document */
      IF VALID-HANDLE(hXDoc) THEN
         DELETE OBJECT hXDoc.
      IF VALID-HANDLE(hXRoot) THEN
         DELETE OBJECT hXRoot.
      IF VALID-HANDLE(hXCampo) THEN
         DELETE OBJECT hXCampo.
      IF VALID-HANDLE(hXNodeDados) THEN
         DELETE OBJECT hXNodeDados.
      IF VALID-HANDLE(hXValue) THEN
         DELETE OBJECT hXValue.
      /* /Destroi objetos X-Document */

      /*  Destroi objetos de temp-table dinamica */
      IF VALID-HANDLE(hBuffer) THEN
         DELETE OBJECT hBuffer.
      IF VALID-HANDLE(hQuery) THEN
         DELETE OBJECT hQuery.
      IF VALID-HANDLE(hTempTable) THEN
         DELETE OBJECT hTempTable.
      /* /Destroi objetos de temp-table dinamica */
END PROCEDURE.

PROCEDURE piXmlNew:

   /*  Instancia de X-Document */
   CREATE X-DOCUMENT hXDoc.
   hXDoc:ENCODING = "ISO-8859-1".
   
   CREATE X-NODEREF  hXRoot.
   CREATE X-NODEREF  hXCampo.
   CREATE X-NODEREF  hXNodeDados.
   CREATE X-NODEREF  hXRegistro.
   CREATE X-NODEREF  hXExtent.
   CREATE X-NODEREF  hXValue.
   hXDoc:CREATE-NODE(hXRoot, "Root", "ELEMENT"). 
   hXDoc:APPEND-CHILD(hXRoot).
END PROCEDURE.

PROCEDURE piXmlExport:
    /* Variaveis de TT dinamica */
    DEFINE INPUT  PARAMETER hTempTable AS HANDLE     NO-UNDO.
    DEFINE INPUT  PARAMETER cTagName   AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE hQuery  AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
    /* /Variaveis de TT dinamica */

    /*  Instancia de Query/Tabela Dinamica */         
    CREATE BUFFER hBuffer FOR TABLE hTempTable:DEFAULT-BUFFER-HANDLE.

    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS(hBuffer).
    hQuery:QUERY-PREPARE("for each " + hTempTable:NAME).
    hQuery:QUERY-OPEN.
    /* /Instancia de Query/Tabela Dinamica */

    hXDoc:CREATE-NODE(hXNodeDados, cTagName, "ELEMENT").
    hXRoot:APPEND-CHILD(hXNodeDados).

    /* /Instancia de X-Document */
    IF   hTempTable:HAS-RECORDS THEN
         DO:
            hQuery:GET-FIRST.
            DO WHILE NOT hQuery:QUERY-OFF-END:
               hXDoc:CREATE-NODE(hXRegistro, "Registro", "ELEMENT").
               hXNodeDados:APPEND-CHILD(hXRegistro).
               DO i = 1 TO hBuffer:NUM-FIELDS:
                  /* Cria o node com o nome da temp-table */ 
                  hXDoc:CREATE-NODE(hXCampo, 
                                    hBuffer:BUFFER-FIELD(i):NAME,
                                    "ELEMENT").   
                  /* Se a var e extent,poe um attr na tag com o nr de extents*/                  
                  IF   hBuffer:BUFFER-FIELD(i):EXTENT > 0 THEN 
                       DO:
                          DO   j = 1 TO hBuffer:BUFFER-FIELD(i):EXTENT:
                               hXCampo:SET-ATTRIBUTE("Extent",
                                       STRING(hBuffer:BUFFER-FIELD(i):EXTENT)).
                               hXRegistro:APPEND-CHILD(hXCampo).

                               hXDoc:CREATE-NODE(hXExtent,
                                                 hBuffer:BUFFER-FIELD(i):NAME 
                                                 + "." + STRING(j), "ELEMENT").
                               hXCampo:APPEND-CHILD(hXExtent).

                               /*Cria node de texto e coloca no node de campo */
                               hXDoc:CREATE-NODE(hXValue, "", "Text").
                               
                               hXValue:NODE-VALUE = 
                               IF  hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[j] = ?
                                   THEN " "
                               ELSE 
                               IF  hBuffer:BUFFER-FIELD(i):DATA-TYPE = "DATE" 
                           THEN STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[J], 
                                       "99/99/9999")
                               ELSE 
                               STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[j]).
                               
                               hXExtent:APPEND-CHILD(hXValue).
                          END. /* DO j = 1 to.. */
                       END. /* IF hBuffer:buffer-field... */
                  ELSE DO:
                     hXRegistro:APPEND-CHILD(hXCampo).
                     /* Cria o node com o valor do campo na temp-table */ 
                     hXDoc:CREATE-NODE(hXValue, "", "TEXT"). 
                     hXValue:NODE-VALUE = 
                         IF  hBuffer:BUFFER-FIELD(i):BUFFER-VALUE() = ? 
                             THEN " "
                         ELSE 
                         IF  hBuffer:BUFFER-FIELD(i):DATA-TYPE = "DATE" THEN
                             /*STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE[J],
                               [J] = retirada a referencia, JOSE LUIS, 17/03/10 */
                             STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE(), 
                                    "99/99/9999")
                         ELSE 
                             STRING(hBuffer:BUFFER-FIELD(i):BUFFER-VALUE()).
                     
                     hXCampo:APPEND-CHILD(hXValue).
                  END.
               END. /* DO i = 1 TO .. */
               hQuery:GET-NEXT().
            END. /* DO WHILE NOT .. */
         END. /* if hTempTable:HAS-RECORDS */
END PROCEDURE.

PROCEDURE piXmlAtributo:
    DEFINE INPUT  PARAMETER ipNomeVar  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER ipVariable AS CHARACTER  NO-UNDO.
    
    IF hXNodeDados:UNIQUE-ID = 0 /* não está carregado */ THEN 
       hXDoc:CREATE-NODE(hXNodeDados, 'Dados', "ELEMENT").
    
    IF ipVariable = ? THEN
       ipVariable = "".
    
    hXNodeDados:SET-ATTRIBUTE(ipNomeVar, ipVariable).
    hXRoot:APPEND-CHILD(hXNodeDados).

END PROCEDURE.

PROCEDURE piXmlSave:
    /*  Output do XML resultado para a Web (com ou sem erro) */
    hXDoc:SAVE("stream", 
               "webstream").
    /* /Output do XML */

    /*  Destroi objetos X-Document */
    IF VALID-HANDLE(hXDoc) THEN
       DELETE OBJECT hXDoc.
    IF VALID-HANDLE(hXRoot) THEN
       DELETE OBJECT hXRoot.
    IF VALID-HANDLE(hXCampo) THEN
       DELETE OBJECT hXCampo.
    IF VALID-HANDLE(hXNodeDados) THEN
       DELETE OBJECT hXNodeDados.
    IF VALID-HANDLE(hXValue) THEN
       DELETE OBJECT hXValue.
    /* /Destroi objetos X-Document */

END PROCEDURE.
