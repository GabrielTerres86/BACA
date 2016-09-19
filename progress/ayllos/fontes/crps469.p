
/*..............................................................................

   Programa: fontes/crps469.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 12/12/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivo de inclusao/retirada de CONTRA-ORDEM para o
               BANCOOB. Emite relatorio crrl445.

   Alteracoes: 18/04/2007 - Nao considerar historicos 0 e 2 (Evandro).

               10/08/2007 - Executa "fontes/imprim.p" para impressao de
                            relatorio (Elton).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               04/11/2013 - Alterado totalizador de PAs de 99 para 999. (Reinert)
               
               10/12/2014 - Incluido tratamento para incorporação da Credmimilsul
                            e concredi, para ao enviar uma contra-ordem, 
                            enviar o numero de conta do cheque (Odirlei/AMcom)
                            
               12/12/2014 - Alterar aux_motctror de "E" para "S" Sustado, e 
                            inclusao de historicos 817 e 825 (Lucas R. #177748)
..............................................................................*/

{ includes/var_batch.i }

DEF STREAM str_1.

DEF TEMP-TABLE w_enviados
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrchqini AS INTE FORMAT "zzzzzz9"
    FIELD nrchqfim AS INTE FORMAT "zzzzzz9"
    INDEX w_enviados1 cdagenci nrdconta.
 
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
DEF VAR aux_motctror AS CHAR                                           NO-UNDO.
DEF VAR aux_cdpessoa AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcontat AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdddcop AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfoncop AS CHAR                                           NO-UNDO.

DEF VAR aux_nrrettab AS INTE                                           NO-UNDO.
DEF VAR aux_nrramcop AS INTE                                           NO-UNDO.
DEF VAR aux_cdcomand AS INTE                                           NO-UNDO.
DEF VAR aux_nrtextab AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrchqini AS INTE                                           NO-UNDO.
DEF VAR aux_nrchqfim AS INTE                                           NO-UNDO.
DEF VAR aux_maxregis AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta_arq  LIKE crapass.nrdconta                        NO-UNDO.

DEF VAR aux_vlcheque AS DECI                                           NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

FORM w_enviados.nrdconta    AT   5   LABEL "Conta/DV"
     w_enviados.nmprimtl    AT  18   LABEL "Nome"
     w_enviados.nrchqini    AT  61   LABEL "Cheque Inicial"
     w_enviados.nrchqfim    AT  78   LABEL "Cheque Final"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_enviados.

ASSIGN glb_cdprogra = "crps469"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/fimprg.p.
        RETURN.
    END.

ASSIGN aux_nmarqlog = "log/prcbcb_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".
                      
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        
        RUN fontes/fimprg.p.
        RETURN.
    END.

/*** Carrega dados da cooperativa ***/
ASSIGN aux_nrdddcop = SUBSTR(crapcop.nrtelvoz,2,2)
       aux_nrfoncop = SUBSTR(crapcop.nrtelvoz,5,4) + 
                      SUBSTR(crapcop.nrtelvoz,10,4)
       aux_nrramcop = 0
       aux_nmcontat = crapcop.nmrescop.

/*** Tenta converter o DDD para Integer ***/
INT(aux_nrdddcop) NO-ERROR.
               
IF  ERROR-STATUS:ERROR  THEN
    ASSIGN aux_nrdddcop = "0".

/*** Tenta converter o Fone para Integer ***/
INT(aux_nrfoncop) NO-ERROR.

IF  ERROR-STATUS:ERROR  THEN
    ASSIGN aux_nrfoncop = "0".
       
RUN abre_arquivo.

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/fimprg.p.
        RETURN.
    END.

ASSIGN aux_nrrettab = aux_nrtextab.
        
FOR EACH crapcch WHERE crapcch.cdcooper  = glb_cdcooper              AND
                       crapcch.cdbanchq  = 756                       AND
                       crapcch.flgctitg  = 0                         AND
                       crapcch.cdhistor <> 0 /* Pedido Lib/Bloq */   AND
                       crapcch.cdhistor <> 2 /* Chq Cancelado   */   :

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapcch.nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        NEXT.
        
    /*** Inicial e Final do intervalo de cheques - sem digito ***/
    ASSIGN aux_nrchqini = INTEGER(SUBSTRING(STRING(crapcch.nrchqini,"9999999")
                                  ,1,6))
           aux_nrchqfim = INTEGER(SUBSTRING(STRING(crapcch.nrchqfim,"9999999")
                                  ,1,6))
           aux_cdpessoa = IF  crapass.inpessoa > 1  THEN
                              "j"
                          ELSE
                              "f"
           aux_vlcheque = 0.
                              
    FOR EACH crapfdc WHERE crapfdc.cdcooper  = glb_cdcooper     AND
                           crapfdc.nrdconta  = crapcch.nrdconta AND
                           crapfdc.nrcheque >= aux_nrchqini     AND
                           crapfdc.nrcheque <= aux_nrchqfim     NO-LOCK
                           USE-INDEX crapfdc2:

        ASSIGN aux_vlcheque = aux_vlcheque + crapfdc.vlcheque.
        
    END.

    IF  crapcch.tpopelcm = "1"  THEN
        DO:
            IF  CAN-DO("818,835,810",STRING(crapcch.cdhistor))  THEN
                ASSIGN aux_motctror = "R".
            ELSE
            IF  CAN-DO("800,817,825",STRING(crapcch.cdhistor))  THEN
                ASSIGN aux_motctror = "E". /* Extraviado */
            ELSE         
                ASSIGN aux_motctror = "S".  /* Sustado */
        END.
    ELSE
    IF  crapcch.tpopelcm = "2"  THEN
        DO:
            ASSIGN aux_motctror = "X".
        END.

    RUN registro.

    IF  glb_cdcritic > 0  THEN
        DO:
            RUN fontes/fimprg.p.
            RETURN.
        END.
        
    /*** Atualiza flag crapcch.flgctitg para enviada(1) ***/
    ASSIGN crapcch.flgctitg = 1.

END. /*** Fim do FOR EACH crapcch ***/

RUN fecha_arquivo.

RUN rel_enviados.

RUN fontes/fimprg.p.                 
  
/*-------------------------------- PROCEDURES --------------------------------*/

PROCEDURE abre_arquivo:
     
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "GENERI"      AND
                       craptab.cdempres = 00            AND
                       craptab.cdacesso = "NRARQMVBCB"  AND
                       craptab.tpregist = 002           
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN glb_cdcritic = 393.
            RUN fontes/critic.p.
        
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " >> " + aux_nmarqlog).
        
            RETURN.
        END.    
 
    ASSIGN aux_nrtextab = INT(SUBSTRING(craptab.dstextab,1,5))
           aux_nmarqimp = "BCB_CONTRAO_" +
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(aux_nrtextab,"99999") + ".txt"
           aux_nrregist = 1.
       
    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

    /*** Header ***/
    PUT STREAM str_1 "0"
                     "756"
                     YEAR(glb_dtmvtolt)     FORMAT "9999"
                     MONTH(glb_dtmvtolt)    FORMAT "99"
                     DAY(glb_dtmvtolt)      FORMAT "99"
                     "SERASA-RECHEQUE"      FORMAT "x(15)"
                     aux_nrtextab           FORMAT "9999"
                     FILL(" ",23)           FORMAT "x(23)"
                     INT(aux_nrdddcop)      FORMAT "9999"
                     INT(aux_nrfoncop)      FORMAT "99999999"
                     aux_nrramcop           FORMAT "9999"
                     aux_nmcontat           FORMAT "x(50)"
                     "    "                 
                     FILL(" ",5)            FORMAT "x(5)"
                     "D"
                     FILL(" ",12)           FORMAT "x(12)"
                     aux_nrregist           FORMAT "9999999"
                     SKIP.

END PROCEDURE.

PROCEDURE fecha_arquivo:

    ASSIGN aux_nrregist = aux_nrregist + 1.
                         
    /*** Trailer ***/
    PUT STREAM str_1 "9"
                     FILL(" ",141)    FORMAT "x(141)"
                     aux_nrregist     FORMAT "9999999".

    OUTPUT STREAM str_1 CLOSE.

    /*** Se arquivo gerado nao tem registros "detalhe", entao elimina ***/
    IF  aux_nrregist <= 2  THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            
            LEAVE.        
        END.

    ASSIGN glb_cdcritic = 847.
    RUN fontes/critic.p.
            
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                      + " - BANCOOB CONTRA-ORDEM - " + 
                      glb_cdprogra + "' --> '" + glb_dscritic + " - " + 
                      aux_nmarqimp + " >> " + aux_nmarqlog).

    UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                      ' | tr -d "\032"' +  
                      " > /micros/" + crapcop.dsdircop +
                      "/bancoob/" + aux_nmarqimp + " 2>/dev/null").

    UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 

    /*** Atualizacao da craptab ***/
    ASSIGN glb_cdcritic = 0
           aux_nrtextab = aux_nrtextab + 1
           aux_maxregis = 0
           SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab,"99999").

END PROCEDURE.

PROCEDURE registro:

    IF  aux_maxregis = 9988  THEN  /*** Maximo 9990 linhas ***/
        DO:
            RUN fecha_arquivo.
            RUN abre_arquivo.

            IF  glb_cdcritic > 0  THEN
                RETURN.
        END.
    
    /* Enviar o numero da conta do cheque para não ocorrer problemas
      qnd cheque for incorporado -incorporação credimilsul e concredi */
    ASSIGN aux_nrdconta_arq = crapcch.nrctachq.

    ASSIGN aux_maxregis = aux_maxregis + 1
           aux_nrregist = aux_nrregist + 1.

    /*** Detalhe ***/
    PUT STREAM str_1 "1"
                     crapcch.tpopelcm           FORMAT "9"
                     "756"
                     crapcch.cdagechq           FORMAT "9999"
                     aux_nrdconta_arq           FORMAT "999999999999999"
                     aux_cdpessoa               FORMAT "x(1)"
                     crapass.nrcpfcgc           FORMAT "99999999999999"
                     crapass.nmprimtl           FORMAT "x(70)"
                     aux_nrchqini               FORMAT "999999"
                     aux_nrchqfim               FORMAT "999999"
                     aux_motctror               FORMAT "x(1)"
                    (aux_vlcheque * 100)        FORMAT "999999999999"
                     YEAR(crapcch.dtmvtolt)     FORMAT "9999"
                     MONTH(crapcch.dtmvtolt)    FORMAT "99"
                     DAY(crapcch.dtmvtolt)      FORMAT "99"
                     aux_nrregist               FORMAT "9999999"
                     SKIP.
    
    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.nmprimtl = crapass.nmprimtl
           w_enviados.nrchqini = aux_nrchqini
           w_enviados.nrchqfim = aux_nrchqfim.

END PROCEDURE.

PROCEDURE rel_enviados:

    ASSIGN aux_nmarqrel = "rl/crrl445_999.lst".

    /*** Monta o cabecalho ***/
    { includes/cabrel132_1.i }
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) APPEND PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
       
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.cdagenci
                                         BY w_enviados.nrdconta:
                                                   
        IF  FIRST-OF(w_enviados.cdagenci)  THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                   crapage.cdagenci = w_enviados.cdagenci
                                   NO-LOCK NO-ERROR.
                
                PUT STREAM str_1 "PA: " crapage.cdagenci " - " crapage.nmresage
                                 SKIP.
            END.

        DISPLAY STREAM str_1
                       w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                       w_enviados.nmprimtl  WHEN FIRST-OF(w_enviados.nrdconta)
                       w_enviados.nrchqini
                       w_enviados.nrchqfim
                       WITH FRAME f_enviados.
                     
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF  LAST-OF(w_enviados.nrdconta)  THEN  
            PUT STREAM str_1 SKIP(1).
                
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                PUT STREAM str_1 "PA: " w_enviados.cdagenci " - "
                                 crapage.nmresage SKIP.
            END.
         
    END. /** Fim do FOR EACH w_enviados **/
    
    OUTPUT STREAM str_1 CLOSE.
    
    /*** Se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" ***/
    IF  glb_inproces = 1  THEN
        UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                          SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                          LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
                          
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.cdagenci
                                         BY w_enviados.nrdconta:

        IF  FIRST-OF(w_enviados.cdagenci)  THEN
            DO:
                ASSIGN aux_nmarqrel = "rl/crrl445_" + 
                                      STRING(w_enviados.cdagenci,"999") +
                                      ".lst".

                OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) 
                                    APPEND PAGED PAGE-SIZE 84.
                
                VIEW STREAM str_1 FRAME f_cabrel132_1.
                
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                   crapage.cdagenci = w_enviados.cdagenci
                                   NO-LOCK NO-ERROR.
                
                PUT STREAM str_1 SKIP
                                 "PA: " crapage.cdagenci " - " crapage.nmresage
                                 SKIP(1).
            END.
            
        DISPLAY STREAM str_1
                       w_enviados.nrdconta  WHEN FIRST-OF(w_enviados.nrdconta)
                       w_enviados.nmprimtl  WHEN FIRST-OF(w_enviados.nrdconta)
                       w_enviados.nrchqini
                       w_enviados.nrchqfim
                       WITH FRAME f_enviados.
         
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF  LAST-OF(w_enviados.nrdconta)  THEN  
            PUT STREAM str_1 SKIP(1).
                
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                PUT STREAM str_1 SKIP
                                 "PA: " w_enviados.cdagenci " - "
                                 crapage.nmresage 
                                 SKIP(1).
            END.
            
        IF  LAST-OF(w_enviados.cdagenci)  THEN
            DO:
                OUTPUT STREAM str_1 CLOSE.
                
                ASSIGN  glb_nmformul = "132col"
                        glb_nmarqimp = aux_nmarqrel
                        glb_nrcopias = 1.

                RUN fontes/imprim.p.
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                         SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                         LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
            END.
         
    END. /*** Fim do FOR EACH w_enviados ***/

END PROCEDURE.

/*...........................................................................*/
