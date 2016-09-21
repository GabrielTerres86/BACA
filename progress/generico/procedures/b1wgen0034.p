/*..............................................................................

    Programa: b1wgen0034.p
    Autor   : Magui/David
    Data    : Setembro/2008                     Ultima Atualizacao: 06/03/2014
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a geracao dos arquivos DRM(2040) E DLO.
                    
    Alteracoes: 30/08/2010 - Incluido caminho completo na gravacao da variavel
                             aux_nmarqdrm no diretorio "arq" (Elton).
                             
                06/03/2014 - Convertido craptab.tpregist para INTEGER. (Reinert)                             
..............................................................................*/

{ sistema/generico/includes/b1wgen0034.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

PROCEDURE gera_table_drm:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR w_drm.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE w_drm.

    ASSIGN aux_qtvertic = 0
           aux_vertices = 0.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 1 
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,     /** PAC       **/
                           INPUT 0,     /** Caixa     **/
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
                       
    /*** Carregando vertices usados pelo DRM ***/
    FOR EACH craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                           craptab.nmsistem = "DRM"              AND
                           craptab.tptabela = "CONFIG"           AND
                           craptab.cdacesso = "VERTICEDRM"       NO-LOCK:
        ASSIGN aux_qtvertic = aux_qtvertic + 1
               aux_vertices[INTE(craptab.tpregist)] = INTE(craptab.dstextab).            END.
                           
    FOR EACH crapdrm WHERE crapdrm.cdcooper = par_cdcooper   AND
                           crapdrm.dtmvtolt = par_dtmvtolt   NO-LOCK
                           BREAK BY crapdrm.cdditdrm
                                 BY crapdrm.cdfatris
                                 BY crapdrm.cdlocreg
                                 BY crapdrm.qtdiauti:
        ASSIGN aux_vllanmto = aux_vllanmto + crapdrm.vllanmto.
        IF   crapdrm.cdditdrm begins "A" /* ativos */ OR
             crapdrm.cdditdrm begins "P" /* passivos */   THEN
             IF   crapdrm.cdfatris = "JM1"   OR
                  crapdrm.cdfatris = "JM2"   OR
                  crapdrm.cdfatris = "JM3"   OR
                  crapdrm.cdfatris = "JM4"   OR
                  crapdrm.cdfatris = "JM5"   OR
                  crapdrm.cdfatris = "JM9"   OR
                  crapdrm.cdfatris = "JT1"   OR
                  crapdrm.cdfatris = "JT2"   OR
                  crapdrm.cdfatris = "JT3"   OR
                  crapdrm.cdfatris = "JT9"   OR
                  crapdrm.cdfatris = "JI1"   OR
                  crapdrm.cdfatris = "JI2"   OR
                  crapdrm.cdfatris = "JI9"   THEN
                  ASSIGN aux_vllanris = aux_vllanris + crapdrm.vllanmto.
         
        IF  LAST-OF(crapdrm.qtdiauti)  THEN
            DO:
               ASSIGN aux_occ            = 0
                      aux_vertice_antes  = 0       aux_vertice_poste  = 0
                      aux_cdvertic_antes = 0       aux_cdvertic_poste = 0
                      aux_valor_antes    = 0       aux_valor_poste    = 0
                      aux_valor_mam      = 0.
               /*** Prazos maiores que 2520 devem ser alocados codigo 12 ***/
               IF   crapdrm.qtdiauti > aux_vertices[aux_qtvertic - 1]  THEN
                    ASSIGN aux_valor_antes = (crapdrm.qtdiauti /
                                              aux_vertices[aux_qtvertic - 1]) *
                                              aux_vllanmto
                           aux_valor_mam = aux_vllanmto                     
                           aux_cdvertic_antes = aux_qtvertic.
               ELSE
               IF   crapdrm.qtdiauti = aux_vertices[1]  THEN
                    ASSIGN aux_valor_antes = aux_vllanmto
                           aux_cdvertic_antes = 1.
               ELSE             
                    DO aux_occ = 1 TO aux_qtvertic - 1:
                       IF    aux_vertices[aux_occ] = crapdrm.qtdiauti    THEN
                             DO:
                                 ASSIGN aux_cdvertic_antes = aux_occ
                                        aux_vertice_antes = 
                                            aux_vertices[aux_occ]
                                        aux_valor_antes = aux_vllanmto.    
                                 LEAVE.           
                             END.
                       IF    aux_vertices[aux_occ] > crapdrm.qtdiauti   THEN
                             DO:
                                 ASSIGN aux_cdvertic_poste = aux_occ
                                        aux_vertice_poste  =
                                                    aux_vertices[aux_occ]
                                        aux_cdvertic_antes  = aux_occ - 1
                                        aux_vertice_antes  = 
                                                    aux_vertices[aux_occ - 1].
                                 LEAVE.
                             END.
                    END.
               IF   aux_vertice_poste <> 0   THEN 
                    ASSIGN aux_valor_antes = 
                                ((aux_vertice_poste - crapdrm.qtdiauti) /
                                (aux_vertice_poste - aux_vertice_antes)) *
                                aux_vllanmto
                           aux_valor_poste = aux_vllanmto - aux_valor_antes.
               FIND w_drm WHERE w_drm.cdditdrm = crapdrm.cdditdrm   AND
                                w_drm.cdfatris = crapdrm.cdfatris   AND
                                w_drm.cdlocreg = crapdrm.cdlocreg   AND
                                w_drm.vertice  = aux_cdvertic_antes
                                NO-ERROR.
               IF   NOT AVAILABLE w_drm   THEN                   
                    DO:
                        CREATE w_drm.
                        ASSIGN w_drm.cdditdrm = crapdrm.cdditdrm
                               w_drm.cdfatris = crapdrm.cdfatris
                               w_drm.cdlocreg = crapdrm.cdlocreg
                               w_drm.vertice  = aux_cdvertic_antes.
                    END.
               ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                        aux_valor_antes
                      w_drm.valor_mam = w_drm.valor_mam + aux_valor_mam.                        IF   aux_valor_poste <> 0   THEN                             
                    DO:
                        FIND w_drm WHERE w_drm.cdditdrm = crapdrm.cdditdrm   AND
                                         w_drm.cdfatris = crapdrm.cdfatris   AND
                                         w_drm.cdlocreg = crapdrm.cdlocreg   AND
                                         w_drm.vertice  = aux_cdvertic_poste
                                         NO-ERROR.
                        IF   NOT AVAILABLE w_drm   THEN                   
                             DO:
                                 CREATE w_drm.
                                 ASSIGN w_drm.cdditdrm = crapdrm.cdditdrm
                                        w_drm.cdfatris = crapdrm.cdfatris
                                        w_drm.cdlocreg = crapdrm.cdlocreg
                                        w_drm.vertice  = aux_cdvertic_poste.
                             END.
                        ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                           aux_valor_poste.
                    END.      
               ASSIGN aux_vllanmto = 0.
            END.   
                        
        IF  LAST-OF(crapdrm.cdfatris)   THEN
            DO:
               IF   aux_vllanris > 0   THEN
                    DO:
                        /*** Para o AFC so e importante os fatores de risco,
                             mais precisamos separa-los em compra e venda ***/
                        IF   SUBSTR(crapdrm.cdditdrm,1,1) = "A"   THEN
                             ASSIGN aux_cdditafc = "A40".
                        ELSE
                             ASSIGN aux_cdditafc = "P10".
                        FIND w_afc WHERE w_afc.cdditdrm = aux_cdditafc AND
                                         w_afc.cdfatris = crapdrm.cdfatris AND
                                         w_afc.qtdiauti = crapdrm.qtdiauti
                                         NO-ERROR.
                        IF   NOT AVAILABLE w_afc   THEN
                             DO:
                                 CREATE w_afc.
                                 ASSIGN w_afc.cdditdrm = aux_cdditafc
                                        w_afc.cdfatris = crapdrm.cdfatris
                                        w_afc.qtdiauti = crapdrm.qtdiauti.
                            END.
                       ASSIGN w_afc.vllanris = w_afc.vllanris + aux_vllanris.                       END.
               ASSIGN aux_vllanris = 0.
            END.
    END.
    /*** Para geracao do AFC sao usados somente alguns fatores de risco
         JM1, JM2, JM3, JM4, JM5, JM9, JT1, JT2, JT3, JT9, JI1, JI2, JI9 ***/
    FOR EACH w_afc WHERE w_afc.cdditdrm = "A40"  NO-LOCK 
                                                 BREAK BY w_afc.cdfatris
                                                       BY w_afc.qtdiauti:
        /*** Nao existe o fator correspondente no passivo entao gera
             direto o AFC de compra desse fator ***/
        FIND FIRST b_w_afc WHERE b_w_afc.cdditdrm = "P10"   AND
                                 b_w_afc.cdfatris = w_afc.cdfatris 
                                 NO-LOCK NO-ERROR.
        IF   NOT AVAILABLE b_w_afc   THEN
             DO:
                 ASSIGN aux_occ            = 0
                        aux_vertice_antes  = 0       aux_vertice_poste  = 0
                        aux_cdvertic_antes = 0       aux_cdvertic_poste = 0
                        aux_valor_antes    = 0       aux_valor_poste    = 0
                        aux_valor_mam      = 0.
                /*** Prazos maiores que 2520 devem ser alocados codigo 12 ***/
                IF   w_afc.qtdiauti >= aux_vertices[aux_qtvertic - 1]  THEN
                     ASSIGN aux_valor_antes = (w_afc.qtdiauti /
                                              aux_vertices[aux_qtvertic - 1]) *
                                               w_afc.vllanris
                           aux_cdvertic_antes = aux_qtvertic - 1.
               ELSE
               IF   w_afc.qtdiauti = aux_vertices[1]  THEN
                    ASSIGN aux_valor_antes = w_afc.vllanris
                           aux_cdvertic_antes = 1.
               ELSE             
                    DO aux_occ = 1 TO aux_qtvertic - 1:
                       IF    aux_vertices[aux_occ] = w_afc.qtdiauti   THEN
                             DO:
                                 ASSIGN aux_cdvertic_antes = aux_occ
                                        aux_vertice_antes = 
                                                    aux_vertices[aux_occ]
                                        aux_valor_antes = w_afc.vllanris.                                     LEAVE.                   
                             END.
                       IF    aux_vertices[aux_occ] > w_afc.qtdiauti   THEN
                             DO:
                                 ASSIGN aux_cdvertic_poste = aux_occ
                                        aux_vertice_poste  =
                                                    aux_vertices[aux_occ]
                                        aux_cdvertic_antes  = aux_occ - 1
                                        aux_vertice_antes  = 
                                                    aux_vertices[aux_occ - 1].
                                 LEAVE.
                             END.
                    END.
               IF   aux_vertice_poste <> 0   THEN 
                    ASSIGN aux_valor_antes = 
                                ((aux_vertice_poste - w_afc.qtdiauti) /
                                (aux_vertice_poste - aux_vertice_antes)) *
                                w_afc.vllanris
                           aux_valor_poste = w_afc.vllanris - aux_valor_antes.
               FIND w_drm WHERE w_drm.cdditdrm = "AFC"            AND
                                w_drm.cdfatris = w_afc.cdfatris   AND
                                w_drm.cdlocreg = 1                AND
                                w_drm.vertice  = aux_cdvertic_antes
                                NO-ERROR.
               IF   NOT AVAILABLE w_drm   THEN                   
                    DO:
                        CREATE w_drm.
                        ASSIGN w_drm.cdditdrm = "AFC"
                               w_drm.cdfatris = w_afc.cdfatris
                               w_drm.cdlocreg = 1
                               w_drm.vertice  = aux_cdvertic_antes.
                    END.
               ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                        aux_valor_antes
                      w_drm.valor_mam = w_drm.valor_mam + aux_valor_mam.
               IF   aux_valor_poste <> 0   THEN                             
                    DO:
                        FIND w_drm WHERE w_drm.cdditdrm = "AFC"              AND
                                         w_drm.cdfatris = w_afc.cdfatris     AND
                                         w_drm.cdlocreg = 1                  AND
                                         w_drm.vertice  = aux_cdvertic_poste
                                         NO-ERROR.
                        IF   NOT AVAILABLE w_drm   THEN                   
                             DO:
                                 CREATE w_drm.
                                 ASSIGN w_drm.cdditdrm = "AFC"
                                        w_drm.cdfatris = w_afc.cdfatris
                                        w_drm.cdlocreg = 1
                                        w_drm.vertice  = aux_cdvertic_poste.
                             END.
                        ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                           aux_valor_poste.
                    END.      
               ASSIGN aux_vllanmto = 0.
             END.   
        ELSE DO:
        /*** Existe fator correspondente no passivo ***/
        IF  FIRST-OF(w_afc.cdfatris)   THEN
            DO:
                EMPTY TEMP-TABLE w_dias_afc.
                FOR EACH b_w_afc WHERE b_w_afc.cdditdrm = "P10" AND
                                       b_w_afc.cdfatris = w_afc.cdfatris
                                       NO-LOCK:
                    FIND w_dias_afc 
                   WHERE w_dias_afc.qtdiauti = b_w_afc.qtdiauti NO-ERROR.
                    IF   NOT AVAILABLE w_dias_afc   THEN
                         DO:
                              CREATE w_dias_afc.
                              ASSIGN w_dias_afc.qtdiauti = b_w_afc.qtdiauti.
                         END.
                         ASSIGN w_dias_afc.vllanvda = w_dias_afc.vllanvda +
                                                      b_w_afc.vllanris.
                END.
            END.
        FIND w_dias_afc WHERE w_dias_afc.qtdiauti = w_afc.qtdiauti NO-ERROR.
        IF   NOT AVAILABLE w_dias_afc   THEN
             DO:
                 CREATE w_dias_afc.
                 ASSIGN w_dias_afc.qtdiauti = w_afc.qtdiauti.
             END.
        ASSIGN w_dias_afc.vllancmp = w_dias_afc.vllancmp +
                                                      w_afc.vllanris.
       IF   LAST-OF(w_afc.cdfatris)   THEN
            DO:
                ASSIGN aux_vllanmto = 0.
                FOR EACH w_dias_afc NO-LOCK BY w_dias_afc.qtdiauti:
                    ASSIGN aux_vllanmto = w_dias_afc.vllancmp - 
                                          w_dias_afc.vllanvda. 
                    IF   aux_vllanmto > 0   OR
                         aux_vllanmto < 0   THEN
                         DO:
                             IF   aux_vllanmto < 0   THEN
                                  ASSIGN aux_vllanmto = aux_vllanmto * -1
                                         aux_cdlocreg = 2.
                             ELSE
                                  ASSIGN aux_cdlocreg = 1.       
                             ASSIGN aux_occ          = 0
                                  aux_vertice_antes = 0 aux_vertice_poste = 0
                                  aux_cdvertic_antes = 0 aux_cdvertic_poste = 0
                                  aux_valor_antes = 0 aux_valor_poste = 0
                                  aux_valor_mam = 0.
                             /*** Prazos maiores que 2520 devem ser 
                                                     alocados codigo 12 ***/
                            IF   w_dias_afc.qtdiauti >= 
                                        aux_vertices[aux_qtvertic - 1]  THEN
                                 ASSIGN aux_valor_antes =
                                             (w_dias_afc.qtdiauti /
                                              aux_vertices[aux_qtvertic - 1]) *
                                              aux_vllanmto
                                        aux_cdvertic_antes = aux_qtvertic - 1.
                            ELSE
                            IF   w_dias_afc.qtdiauti = aux_vertices[1]  THEN
                                 ASSIGN aux_valor_antes = aux_vllanmto
                                        aux_cdvertic_antes = 1.
                            ELSE             
                            DO aux_occ = 1 TO aux_qtvertic - 1:
                               IF    aux_vertices[aux_occ] =
                                         w_dias_afc.qtdiauti   THEN
                                     DO:
                                         ASSIGN aux_cdvertic_antes = aux_occ
                                                aux_vertice_antes =
                                                    aux_vertices[aux_occ]
                                                aux_valor_antes =
                                                          aux_vllanmto.    
                                         LEAVE.           
                                     END.     
                               IF    aux_vertices[aux_occ] >
                                                  w_dias_afc.qtdiauti   THEN
                                     DO:
                                         ASSIGN aux_cdvertic_poste = aux_occ
                                                aux_vertice_poste  =
                                                    aux_vertices[aux_occ]
                                                aux_cdvertic_antes  =
                                                             aux_occ - 1
                                                aux_vertice_antes  = 
                                                    aux_vertices[aux_occ - 1].
                                         LEAVE.
                                     END.
                            END.
                            IF   aux_vertice_poste <> 0   THEN 
                                 ASSIGN aux_valor_antes = 
                                  ((aux_vertice_poste - w_dias_afc.qtdiauti) /
                                  (aux_vertice_poste - aux_vertice_antes)) *
                                   aux_vllanmto
                                        aux_valor_poste = aux_vllanmto - 
                                                              aux_valor_antes.
                            FIND w_drm
                           WHERE w_drm.cdditdrm = "AFC"            AND
                                 w_drm.cdfatris = w_afc.cdfatris   AND
                                 w_drm.cdlocreg = aux_cdlocreg     AND
                                 w_drm.vertice  = aux_cdvertic_antes
                                 NO-ERROR.
                            IF   NOT AVAILABLE w_drm   THEN                   
                                 DO:
                                     CREATE w_drm.
                                     ASSIGN w_drm.cdditdrm = "AFC"
                                            w_drm.cdfatris = w_afc.cdfatris
                                            w_drm.cdlocreg = aux_cdlocreg
                                            w_drm.vertice  = aux_cdvertic_antes.
                                 END.
                            ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                         aux_valor_antes
                                   w_drm.valor_mam = w_drm.valor_mam +
                                                           aux_valor_mam.
                            IF   aux_valor_poste <> 0   THEN                                                      DO:
                                     FIND w_drm 
                                   WHERE w_drm.cdditdrm = "AFC"              AND
                                         w_drm.cdfatris = w_afc.cdfatris     AND
                                         w_drm.cdlocreg = aux_cdlocreg       AND
                                         w_drm.vertice  = aux_cdvertic_poste
                                         NO-ERROR.
                                     IF   NOT AVAILABLE w_drm   THEN                                                     DO:
                                              CREATE w_drm.
                                              ASSIGN w_drm.cdditdrm = "AFC"
                                                w_drm.cdfatris = w_afc.cdfatris
                                                w_drm.cdlocreg =  aux_cdlocreg
                                                w_drm.vertice  =
                                                           aux_cdvertic_poste.
                                          END.
                                     ASSIGN w_drm.valor_vertice =
                                                  w_drm.valor_vertice +
                                                           aux_valor_poste.
                                 END.      
                         END.                 
                END.
            END.                                           
       END.
    END.
    /*** Procurar se nao ha algum passivo sem o seu correspondente ativo ***/
    FOR EACH w_afc WHERE w_afc.cdditdrm = "P10"  NO-LOCK 
                                                 BREAK BY w_afc.cdfatris
                                                       BY w_afc.qtdiauti:
        /*** Nao existe o fator correspondente no passivo entao gera
             direto o AFC de compra desse fator ***/
        FIND FIRST b_w_afc WHERE b_w_afc.cdditdrm = "A40"   AND
                                 b_w_afc.cdfatris = w_afc.cdfatris 
                                 NO-LOCK NO-ERROR.
        IF   NOT AVAILABLE b_w_afc   THEN
             DO:
                 ASSIGN aux_occ            = 0
                        aux_vertice_antes  = 0       aux_vertice_poste  = 0
                        aux_cdvertic_antes = 0       aux_cdvertic_poste = 0
                        aux_valor_antes    = 0       aux_valor_poste    = 0
                        aux_valor_mam      = 0.
                /*** Prazos maiores que 2520 devem ser alocados codigo 12 ***/
                IF   w_afc.qtdiauti >= aux_vertices[aux_qtvertic - 1]  THEN
                     ASSIGN aux_valor_antes = (w_afc.qtdiauti /
                                              aux_vertices[aux_qtvertic - 1]) *
                                               w_afc.vllanris
                           aux_valor_mam = w_afc.vllanris                     
                           aux_cdvertic_antes = aux_qtvertic - 1.
               ELSE
               IF   w_afc.qtdiauti = aux_vertices[1]  THEN
                    ASSIGN aux_valor_antes = w_afc.vllanris
                           aux_cdvertic_antes = 1.
               ELSE             
                    DO aux_occ = 1 TO aux_qtvertic - 1:
                       IF    aux_vertices[aux_occ] = w_afc.qtdiauti   THEN
                             DO:
                                 ASSIGN aux_cdvertic_antes = aux_occ
                                        aux_vertice_antes =
                                                    aux_vertices[aux_occ]
                                        aux_valor_antes = w_afc.vllanris.                                        LEAVE.
                             END.
                       IF    aux_vertices[aux_occ] > w_afc.qtdiauti   THEN
                             DO:
                                 ASSIGN aux_cdvertic_poste = aux_occ
                                        aux_vertice_poste  =
                                                    aux_vertices[aux_occ]
                                        aux_cdvertic_antes  = aux_occ - 1
                                        aux_vertice_antes  = 
                                                    aux_vertices[aux_occ - 1].
                                 LEAVE.
                             END.
                    END.
               IF   aux_vertice_poste <> 0   THEN 
                    ASSIGN aux_valor_antes = 
                                ((aux_vertice_poste - w_afc.qtdiauti) /
                                (aux_vertice_poste - aux_vertice_antes)) *
                                w_afc.vllanris
                           aux_valor_poste = w_afc.vllanris - aux_valor_antes.
               FIND w_drm WHERE w_drm.cdditdrm = "AFC"            AND
                                w_drm.cdfatris = w_afc.cdfatris   AND
                                w_drm.cdlocreg = 2                AND
                                w_drm.vertice  = aux_cdvertic_antes
                                NO-ERROR.
               IF   NOT AVAILABLE w_drm   THEN                   
                    DO:
                        CREATE w_drm.
                        ASSIGN w_drm.cdditdrm = "AFC"
                               w_drm.cdfatris = w_afc.cdfatris
                               w_drm.cdlocreg = 2
                               w_drm.vertice  = aux_cdvertic_antes.
                    END.
               ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                        aux_valor_antes
                      w_drm.valor_mam = w_drm.valor_mam + aux_valor_mam.
               IF   aux_valor_poste <> 0   THEN                             
                    DO:
                        FIND w_drm WHERE w_drm.cdditdrm = "AFC"              AND
                                         w_drm.cdfatris = w_afc.cdfatris     AND
                                         w_drm.cdlocreg = 2                  AND
                                         w_drm.vertice  = aux_cdvertic_poste
                                         NO-ERROR.
                        IF   NOT AVAILABLE w_drm   THEN                   
                             DO:
                                 CREATE w_drm.
                                 ASSIGN w_drm.cdditdrm = "AFC"
                                        w_drm.cdfatris = w_afc.cdfatris
                                        w_drm.cdlocreg = 2
                                        w_drm.vertice  = aux_cdvertic_poste.
                             END.
                        ASSIGN w_drm.valor_vertice = w_drm.valor_vertice +
                                                           aux_valor_poste.
                    END.      
               ASSIGN aux_vllanmto = 0.
             END.   
    END.
    RETURN "OK".
    
END.

PROCEDURE gera_arquivo_drm:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_dtrefere LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM TABLE for w_drm.

    DEF OUTPUT PARAM par_dsdirdrm AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqdrm AS CHAR                                    NO-UNDO.
    DEF VAR ini_tagitdrm AS CHAR                                    NO-UNDO.
    DEF VAR fim_tagitdrm AS CHAR                                    NO-UNDO.
    DEF VAR aux_dslinxml AS CHAR FORMAT "x(100)"                    NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
     
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 1 
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,     /** PAC       **/
                           INPUT 0,     /** Caixa     **/
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
            
    ASSIGN aux_nmarqdrm = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/arq/2040" + STRING(MONTH(par_dtrefere),"99") + 
                          SUBSTR(STRING(YEAR(par_dtrefere),"9999"),3,2) + 
                          ".xml"
           par_dsdirdrm = "/micros/" + LC(crapcop.dsdircop) + "/contab/" + 
                          SUBSTR(aux_nmarqdrm,5).
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqdrm).

    PUT STREAM str_1 '<?xml version="1.0" encoding="UTF-8" ?>' SKIP
                     '<Doc2040>' SKIP
                     '  <IdDocto>2040</IdDocto>' SKIP
                     '  <IdDoctoVersao>v01</IdDoctoVersao>' SKIP
                     '  <DataBase>'
                     STRING(YEAR(par_dtrefere),"9999") FORMAT "x(4)"
                     '-' FORMAT "x(1)"
                     STRING(MONTH(par_dtrefere),"99") FORMAT "x(2)"
                     '</DataBase>' SKIP
                     '  <IdInstFinanc>05463212</IdInstFinanc>' SKIP
                     '  <TipoArq>I</TipoArq>' SKIP
                     '  <NomeContato>Marcos Roberto Linhares Imme</NomeContato>'
                     SKIP
                     '  <FoneContato>4732314668</FoneContato>' SKIP.
                 
    FOR EACH w_drm NO-LOCK BREAK BY w_drm.cdditdrm
                                    BY w_drm.cdfatris
                                       BY w_drm.cdlocreg:
                
        IF  FIRST-OF(w_drm.cdditdrm)  THEN
            DO:
                IF  SUBSTR(w_drm.cdditdrm,1,1) = "A"  THEN
                    DO:
                        IF  w_drm.cdditdrm = "AFC"  THEN
                            ASSIGN ini_tagitdrm = "AtividadeFinanceira".
                        ELSE
                            ASSIGN ini_tagitdrm = "Ativo".
                    END.
                ELSE
                IF  SUBSTR(w_drm.cdditdrm,1,1) = "P"  THEN
                    ASSIGN ini_tagitdrm = "Passivo".
            
                IF  fim_tagitdrm <> ""            AND
                    fim_tagitdrm <> ini_tagitdrm  THEN
                    DO:
                        ASSIGN aux_dslinxml = "  </" + fim_tagitdrm + ">".
                        PUT STREAM str_1 aux_dslinxml SKIP.
                    END.
                
                IF  ini_tagitdrm <> fim_tagitdrm  THEN
                    DO:
                        ASSIGN fim_tagitdrm = ini_tagitdrm
                               aux_dslinxml = "  <" + ini_tagitdrm + ">".
                        PUT STREAM str_1 aux_dslinxml SKIP.
                    END.
            END.

        IF  FIRST-OF(w_drm.cdlocreg)  THEN
            DO:
                IF  w_drm.cdditdrm = "AFC"  THEN
                    DO:
                        ASSIGN aux_dslinxml = '    <ItemCarteira Item="' +
                                              w_drm.cdditdrm + '" IdPosicao=' +
                                              (IF  w_drm.cdlocreg = 1  THEN
                                                   '"C" '
                                              ELSE
                                                   '"V" ') +
                                              'FatorRisco="' + w_drm.cdfatris + 
                                              '">'.
                        PUT STREAM str_1 aux_dslinxml SKIP.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_dslinxml = '    <ItemCarteira Item="' +
                                              w_drm.cdditdrm + '" ' +
                                              'FatorRisco="' + w_drm.cdfatris + 
                                              '" LocalRegistro="' + 
                                              STRING(w_drm.cdlocreg,"99") +
                                              '" ' + 'CarteiraNegoc="02">'.
                        PUT STREAM str_1 aux_dslinxml SKIP.
                    END.
            END.

        ASSIGN aux_dslinxml = '      <FluxoVertice CodVertice="' + 
                              STRING(w_drm.vertice,"99") + '" ValorAlocado="' + 
                              TRIM(STRING(w_drm.valor_vertice)) + '"' +
                              (IF  w_drm.valor_mam > 0      AND
                                   w_drm.cdditdrm <> "AFC"  THEN
                                   ' ValorMaM="' + 
                                   TRIM(STRING(w_drm.valor_mam)) + '" '
                               ELSE
                                   ' ') +   
                              '/>'.
        PUT STREAM str_1 aux_dslinxml SKIP.

        IF  LAST-OF(w_drm.cdlocreg)  THEN
            PUT STREAM str_1 '    </ItemCarteira>' SKIP.
        
    END. /** Fim do FOR EACH w_drm **/

    IF  fim_tagitdrm <> ""  THEN
        DO:
            ASSIGN aux_dslinxml = "  </" + fim_tagitdrm + ">".
            PUT STREAM str_1 aux_dslinxml SKIP.
        END.
    
    PUT STREAM str_1 '</Doc2040>'.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE ("cp " + aux_nmarqdrm + " salvar").
    UNIX SILENT VALUE ("cp " + aux_nmarqdrm + " " + par_dsdirdrm).

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
