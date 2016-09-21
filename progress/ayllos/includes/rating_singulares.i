/*.............................................................................

   Programa: includes/gera_rating.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Guilherme   
   Data    : Setembro/2011                     Ultima Atualizacao: 04/11/2011

   Dados referentes ao programa: Digitar rating das cooperativas singulares
                                 na CECRED

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar o cadastramento RATING.            

   Alteracao : 04/11/2011 - Realizado as seguintes alterecoes:
                            - Enquanto nao forem selecionados todos os itens, 
                              sera informado uma mensagem solicitando a selecao
                              de todos;
                            - Solicitacao de alteracao pela tela ATURAT, podera
                              ser selecionado um ou mais itens para serem
                              atualizados (Adriano).
   
............................................................................. */

DEF   VAR aux_ultlinha      AS INT                                    NO-UNDO.

DEF VAR tel_nrtopico        LIKE craprat.nrtopico                     NO-UNDO.
DEF VAR tel_dstopico        LIKE craprat.dstopico                     NO-UNDO.
DEF VAR tel_nritetop        LIKE craprai.nritetop                     NO-UNDO.
DEF VAR tel_dsitetop        LIKE craprai.dsitetop                     NO-UNDO.
DEF VAR tel_nrseqite        LIKE craprad.nrseqite                     NO-UNDO.
DEF VAR tel_dsseqite        LIKE craprad.dsseqite                     NO-UNDO.
DEF VAR tel_nrtopicob       LIKE craprat.nrtopico                     NO-UNDO.
DEF VAR tel_dstopicob       LIKE craprat.dstopico                     NO-UNDO.
DEF VAR tel_nritetopb       LIKE craprai.nritetop                     NO-UNDO.
DEF VAR tel_dsitetopb       LIKE craprai.dsitetop                     NO-UNDO.
DEF VAR tel_pesosequb       LIKE craprad.pesosequ                     NO-UNDO.
DEF VAR tel_pesoitemb       LIKE craprai.pesoitem                     NO-UNDO.
                
DEF VAR tel_nrseqiteb       LIKE craprad.nrseqite                     NO-UNDO.
DEF VAR tel_dsseqiteb       LIKE craprad.dsseqite                     NO-UNDO.
                    
DEF VAR aux_pesquisa        AS LOGICAL FORMAT "S/N"                   NO-UNDO.
DEF VAR aux_contalin        AS INT                                    NO-UNDO.
                    
DEF VAR tel_numdotop        AS CHAR                                   NO-UNDO.
DEF VAR tel_topeitem        AS CHAR                                   NO-UNDO.
DEF VAR tel_topitesq        AS CHAR                                   NO-UNDO.
                            
DEF   VAR aux_percentu      AS DEC     FORMAT "zz9.99"   EXTENT 20    NO-UNDO.
DEF   VAR aux_notadefi      AS DEC     FORMAT "zz9.99"   EXTENT 20    NO-UNDO.
DEF   VAR aux_notatefi      AS DEC     FORMAT "zz9.99"   EXTENT 20    NO-UNDO.
DEF   VAR aux_parecefi      AS CHAR    FORMAT "x(15)"    EXTENT 20    NO-UNDO.
DEF   VAR aux_notadeju      AS DEC     FORMAT "zz9.99"   EXTENT 20    NO-UNDO.
DEF   VAR aux_notateju      AS DEC     FORMAT "zz9.99"   EXTENT 20    NO-UNDO.
DEF   VAR aux_pareceju      AS CHAR    FORMAT "x(15)"    EXTENT 20    NO-UNDO.
                                                                      
DEF   VAR aux_risco         AS CHAR    FORMAT "x(02)"                 NO-UNDO.
DEF   VAR aux_provisao      AS DEC     FORMAT "zz9.99"                NO-UNDO.
DEF   VAR aux_nota_de       AS DEC     FORMAT "zz9.99"                NO-UNDO.
DEF   VAR aux_nota_ate      AS DEC     FORMAT "zz9.99"                NO-UNDO.
DEF   VAR aux_parecer       AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF   VAR tel_vlrnota       AS DEC     FORMAT "zzz9.99"               NO-UNDO.
DEF   VAR tel_datatual      AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF   VAR aux_vlrnota       AS DEC     FORMAT "zzz9.99"               NO-UNDO.
DEF   VAR aux_vlrnota_total AS DEC     FORMAT "zzz9.99"               NO-UNDO.
DEF   VAR l_selecionado     AS LOG                                    NO-UNDO.

DEF   VAR aux_nrctrrat      LIKE crapras.nrctrrat                     NO-UNDO.  
DEF   VAR aux_tpctrrat      LIKE crapras.tpctrrat                     NO-UNDO.
DEF   VAR aux_vlrrisco      AS DEC                                    NO-UNDO.
DEF   VAR aux_atualiza      AS LOG                                    NO-UNDO.
DEF   VAR aux_diarating     AS INTE                                   NO-UNDO.

DEFINE VARIABLE aux_selecionou_algo AS LOGICAL     NO-UNDO.

DEF TEMP-TABLE  w_lista                                               NO-UNDO
    FIELDS nrsequen          AS CHAR FORMAT "x(8)"   /* x(10)*/
    FIELDS descricao         AS CHAR FORMAT "x(50)" 
    FIELDS reg_craprat       AS RECID
    FIELDS reg_craprai       AS RECID
    FIELDS reg_craprad       AS RECID
    FIELDS nrtopico          LIKE craprat.nrtopico
    FIELDS nritetop          LIKE craprai.nritetop
    FIELDS nrseqite          LIKE craprad.nrseqite
    FIELDS nota              AS CHAR FORMAT "x(07)"
    FIELDS selecionado       AS CHAR FORMAT "x(01)"     
    FIELDS lista_topico      AS INTE FORMAT "zzz"                     
    FIELDS lista_item_topico AS INTE FORMAT "zzz".         
    
DEF BUFFER b_w_lista FOR w_lista.  
DEF BUFFER bw_lista  FOR w_lista.  
DEF BUFFER b-singulares1 FOR tt-singulares.

/* Variaveis para mostrar a consulta */          
 
FORM 
     SKIP(9)
     WITH ROW 11 CENTERED TITLE "CLASSIFICAO DE RISCO" OVERLAY WIDTH 80 FRAME   
                f_rating_all. 

DEF QUERY  brating-q FOR  w_lista. 

DEF BROWSE brating-b QUERY brating-q
      DISPLAY w_lista.nrsequen    NO-LABEL
              w_lista.descricao   NO-LABEL   FORMAT "x(46)"
              w_lista.nota        NO-LABEL   
              w_lista.selecionado NO-LABEL
      WITH 6 DOWN NO-BOX OVERLAY CENTERED.

FORM  "SEQUEN:" 
      brating-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
      WITH NO-LABEL ROW 15 COLUMN 3 OVERLAY NO-BOX FRAME f_ratingc.

FORM "TOPICO:"     AT  2
     tel_numdotop  AT 12   
     tel_dstopicob AT 21    
     "ITEM  :"     AT  2 
     tel_topeitem  AT 12   
     tel_dsitetopb AT 21   FORMAT "x(46)"
     WITH NO-LABELS SIDE-LABELS ROW 12 NO-BOX COLUMN 2 NO-ATTR-SPACE 
          
          OVERLAY WIDTH 78 FRAME  f_ratingc1.

ON GO, RETURN OF brating-b DO:
    
   IF UPPER(glb_cdprogra) = "ATURAT" THEN
      DO:
         IF NOT aux_selecionou_algo THEN
            DO:
               ASSIGN glb_dscritic = "Rating incompleto. Preencha um ou mais itens.". 
               MESSAGE glb_dscritic.
               PAUSE 3 NO-MESSAGE.
               HIDE MESSAGE.
               ASSIGN glb_dscritic = "".
            
            END.
         ELSE
            APPLY "END-ERROR".
         
      END.
   ELSE
     IF  NOT l_selecionado  THEN
         DO:
            ASSIGN glb_dscritic = "Rating incompleto. Preencha todos os itens.". 
            MESSAGE glb_dscritic.
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.
            ASSIGN glb_dscritic = "".
      
         END.

END.


ON VALUE-CHANGED, ENTRY OF brating-b DO:       
      
   IF AVAIL w_lista   THEN 
      RUN lista_detalhado.

END. 

ON RETURN OF brating-b DO:  

   IF  AVAIL w_lista        AND
       w_lista.nota <> ""   THEN
       DO:
           RUN atualiza_rating.
           
           ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("brating-q").
                     
           /* rotina para posicionar o browse no proximo item */
           aux_contador = 0.
                     
           FOR EACH b_w_lista WHERE  
                    b_w_lista.nrtopico = w_lista.nrtopico   AND
                    b_w_lista.nritetop = w_lista.nritetop   NO-LOCK:

               aux_contador = aux_contador + 1.

           END.
                     
           FIND LAST b_w_lista.
           
           IF   NOT(b_w_lista.nrtopico = w_lista.nrtopico    AND
                    b_w_lista.nritetop = w_lista.nritetop)   THEN
                aux_contador = aux_contador + 1.
                      
           aux_contador = aux_contador -
                           INTEGER(SUBSTRING(w_lista.nrsequen,
                                            LENGTH(w_lista.nrsequen),1)).
                     
           RUN open_browser.                         
           
           REPOSITION brating-q TO ROW (aux_ultlinha + aux_contador).
                     
           RUN lista_detalhado.

           RUN grava_singulares.
           
            
       END.

END.

DO WHILE TRUE:

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = aux_nrdconta
                      NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapass  THEN
   DO:
       glb_cdcritic = 9.
       RUN fontes/critic.p.
       MESSAGE glb_dscritic.
       PAUSE 3 NO-MESSAGE.
       LEAVE.
   END.

   ASSIGN aux_selecionou_algo = FALSE
          l_selecionado = FALSE.

   VIEW FRAME f_rating_all.

   PAUSE 0 NO-MESSAGE.

   HIDE FRAME f_ratingc.
   
   HIDE FRAME f_ratingc1.
   
   HIDE MESSAGE.

   RUN carrega_tabela_work.

   RUN p_carregabrowser.

   RUN verifica_selecionados.


   /* se selecionou algo e selecionou tudo pede confirmacao */
   IF  (aux_selecionou_algo AND l_selecionado)                  OR
       (UPPER(glb_cdprogra) = "ATURAT" AND aux_selecionou_algo) THEN
   DO:
       RUN fontes/confirma.p (INPUT "",
                              OUTPUT aux_confirma).
    
       IF   aux_confirma = "S"   THEN
       DO:
           IF   RETURN-VALUE <> "OK"   THEN
                DO:
                    IF   glb_cdcritic <> 0  THEN
                         DO:
                             RUN fontes/critic.p.
                             MESSAGE glb_dscritic.
                             PAUSE 3 NO-MESSAGE.
                         END.
                END.
            ELSE
                ASSIGN glb_dscritic = ""
                       glb_cdcritic = 0.
       END.
   END.
   ELSE
   DO:
       ASSIGN glb_dscritic =  
               "Rating Incompleto - " +
               "Sem Classificacao Risco - VERIFIQUE".
       MESSAGE glb_dscritic.
   END.
   
   HIDE FRAME f_rating_all NO-PAUSE.
   CLEAR FRAME f_ratingc.
   CLEAR FRAME f_ratingc1.
   HIDE FRAME f_ratingc NO-PAUSE.
   HIDE FRAME f_ratingc1 NO-PAUSE.

   LEAVE.

END.   /* Fim do DO WHILE TRUE */


PROCEDURE p_carregabrowser:
          
   RUN open_browser.
     
   ENABLE brating-b
          WITH FRAME f_ratingc.

   WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
   
END PROCEDURE.
 
PROCEDURE open_browser:

   OPEN QUERY brating-q          
        FOR EACH w_lista NO-LOCK BY w_lista.nrtopico
                                  BY w_lista.nritetop
                                   BY w_lista.nrseqite.

END PROCEDURE. 

PROCEDURE  carrega_tabela_work.

   EMPTY TEMP-TABLE w_lista.
   EMPTY TEMP-TABLE bw_lista.
   EMPTY TEMP-TABLE tt-singulares.

   ASSIGN aux_vlrnota       = 0
          aux_vlrnota_total = 0
          aux_nrctrrat      = 0
          aux_tpctrrat      = 0.
          
   /*--- Gera tabela RATING --*/
   FOR  EACH craprat WHERE craprat.cdcooper  = glb_cdcooper      AND 
                           craprat.nrtopico >= 0                 AND
                           craprat.inpessoa  = 2                 AND
                           craprat.flgativo  = YES               NO-LOCK,

        EACH craprai WHERE craprai.cdcooper = glb_cdcooper       AND
                           craprai.nrtopico = craprat.nrtopico   NO-LOCK,

        EACH craprad WHERE craprad.cdcooper = glb_cdcooper       AND 
                           craprad.nrtopico = craprai.nrtopico   AND
                           craprad.nritetop = craprai.nritetop   NO-LOCK
                           BREAK BY craprat.nrtopico
                                    BY craprai.nritetop 
                                       BY craprad.nrseqite.
        
        CREATE w_lista.

        ASSIGN w_lista.nrsequen = TRIM(STRING(craprat.nrtopico)) + "." +
                                  TRIM(STRING(craprai.nritetop)) + "." +
                                  TRIM(STRING(craprad.nrseqite)).
        
        ASSIGN w_lista.descricao   = craprad.dsseqite
               w_lista.reg_craprat = RECID(craprat)
               w_lista.reg_craprai = RECID(craprai)
               w_lista.reg_craprad = RECID(craprad)
               w_lista.nota        = 
               STRING((craprai.pesoitem * craprad.pesosequ),"zz9.99")
               w_lista.nrtopico    = craprat.nrtopico
               w_lista.nritetop    = craprai.nritetop
               w_lista.nrseqite    = craprad.nrseqite.
        
        IF  FIRST-OF(craprat.nrtopico) THEN
            ASSIGN w_lista.lista_topico = w_lista.nrtopico.
        
        IF  FIRST-OF(craprai.nritetop) THEN
            ASSIGN w_lista.lista_item_topico = w_lista.nritetop.
            
        
        FIND crapras WHERE  crapras.cdcooper = glb_cdcooper        AND 
                            crapras.nrdconta = crapass.nrdconta    AND
                            crapras.nrctrrat = {1}                 AND
                            crapras.tpctrrat = {2}                 AND
                            crapras.nrtopico = craprat.nrtopico    AND
                            crapras.nritetop = craprai.nritetop    AND
                            crapras.nrseqite = craprad.nrseqite
                            NO-LOCK NO-ERROR.

        IF  AVAIL crapras THEN 
            ASSIGN w_lista.selecionado = "*"
                   aux_vlrnota         = craprai.pesoitem * craprad.pesosequ.
        ELSE
            ASSIGN w_lista.selecionado = " " 
                   aux_vlrnota         = 0.

        ASSIGN aux_vlrnota_total = aux_vlrnota_total + aux_vlrnota.

    END.

    /*-- criar o total de 6 registros para cada iten de topico --*/
    FOR EACH w_lista BREAK BY  w_lista.nrtopico
                                BY  w_lista.nritetop
                                    BY  w_lista.nrseqite:
    
        IF   FIRST-OF(w_lista.nritetop)   THEN
             aux_contador = 0.
           
        aux_contador = aux_contador + 1.
        
        IF   LAST-OF(w_lista.nritetop)   THEN
             DO:
                 IF   aux_contador >= 6   THEN
                      NEXT.
                  
                 DO aux_contador = (aux_contador + 1) TO 6:

                    CREATE b_w_lista.
                    ASSIGN b_w_lista.nrsequen  = ""
                           b_w_lista.descricao = ""
                           b_w_lista.nota      = ""
                           b_w_lista.nrtopico  = w_lista.nrtopico
                           b_w_lista.nritetop  = w_lista.nritetop
                           b_w_lista.nrseqite  = aux_contador.
               
                 END.
             END.
    END.
  
END PROCEDURE.

PROCEDURE grava_singulares:
  
   /* Para as cooperativas, quando terminar de selecionar cria a tt-singulares
      e sai. Para a CENTRAL, a tt-singulares eh alimentada a cada RETURN no 
      browser e se, a nota for diferente de vazio */
   IF w_lista.nota = ""              OR
     (UPPER(glb_cdprogra) = "ATURAT" AND 
      w_lista.nota <> "")            THEN
      DO: 
         FOR EACH bw_lista BREAK BY bw_lista.nrtopico
                                   BY bw_lista.nritetop
                                     BY bw_lista.nrseqite:
         
             FIND tt-singulares WHERE 
                                tt-singulares.nrtopico = bw_lista.nrtopico AND
                                tt-singulares.nritetop = bw_lista.nritetop AND
                                tt-singulares.nrseqite = bw_lista.nrseqite
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL tt-singulares THEN
                IF bw_lista.selecionado = "*" THEN
                   DO: 
                      FIND b-singulares1 WHERE 
                           b-singulares1.nrtopico = bw_lista.nrtopico AND
                           b-singulares1.nritetop = bw_lista.nritetop 
                           NO-LOCK NO-ERROR.
                      
                      IF AVAIL b-singulares1 THEN
                         DELETE b-singulares1.

                      CREATE tt-singulares.
                  
                      ASSIGN tt-singulares.nrtopico = bw_lista.nrtopico
                             tt-singulares.nritetop = bw_lista.nritetop
                             tt-singulares.nrseqite = bw_lista.nrseqite.
                       
                   END.
      
         END.
         
         IF UPPER(glb_cdprogra) <> "ATURAT" OR 
           (UPPER(glb_cdprogra) =  "ATURAT" AND
            w_lista.nota = "")              THEN
            LEAVE.
      
      END.

END PROCEDURE.

PROCEDURE lista_detalhado:

    IF w_lista.nota = "" THEN
       LEAVE.

    FIND craprat WHERE RECID(craprat) = w_lista.reg_craprat NO-LOCK NO-ERROR.
    FIND craprai WHERE RECID(craprai) = w_lista.reg_craprai NO-LOCK NO-ERROR.
    FIND craprad WHERE RECID(craprad) = w_lista.reg_craprad NO-LOCK NO-ERROR.

    ASSIGN tel_nrtopicob = craprat.nrtopico 
           tel_dstopicob = craprat.dstopico 
           tel_nritetopb = craprai.nritetop  
           tel_dsitetopb = craprai.dsitetop  
           tel_nrseqiteb = craprad.nrseqite    
           tel_dsseqiteb = craprad.dsseqite   
           tel_numdotop = TRIM(STRING(craprat.nrtopico))
           tel_topeitem = tel_numdotop + "." +
                          TRIM(STRING(craprai.nritetop))

           tel_topitesq = tel_topeitem + "." +
                          TRIM(STRING(craprad.nrseqite))
          
           tel_pesoitemb = craprai.pesoitem
           tel_pesosequb = craprad.pesosequ.
 
    DISPLAY tel_dstopicob  
            tel_dsitetopb                     
            tel_numdotop
            tel_topeitem
            WITH FRAME f_ratingc1.


END PROCEDURE. 

    
PROCEDURE verifica_selecionados:

    /* Verifica se Rating Completo */
    ASSIGN l_selecionado = YES.

    FOR EACH craprat WHERE craprat.cdcooper = glb_cdcooper      AND
                           craprat.inpessoa = crapass.inpessoa  AND
                           craprat.flgativo = YES               
                           NO-LOCK,

        EACH craprai WHERE craprai.cdcooper = glb_cdcooper      AND
                           craprai.nrtopico = craprat.nrtopico 
                           NO-LOCK:

        IF NOT CAN-FIND (FIRST tt-singulares WHERE
                               tt-singulares.nrtopico = craprat.nrtopico  AND
                               tt-singulares.nritetop = craprai.nritetop
                               NO-LOCK) THEN
        DO:
            ASSIGN l_selecionado  = NO.
            LEAVE.

        END.

    END.

END PROCEDURE.


PROCEDURE atualiza_rating:

    ASSIGN aux_selecionou_algo = TRUE.

    IF  w_lista.selecionado <> "*" THEN
        ASSIGN w_lista.selecionado = "*".
           

    FOR EACH b_w_lista:
          
        IF  b_w_lista.nrtopico = w_lista.nrtopico AND
            b_w_lista.nritetop = w_lista.nritetop THEN
            DO: 
            
               IF  b_w_lista.reg_craprad = w_lista.reg_craprad THEN 
                   NEXT.
               ELSE
                   ASSIGN  b_w_lista.selecionado = " ".
                   
                   
            END.
    END.
    
    FIND LAST b_w_lista.
    
    IF   b_w_lista.nrtopico = w_lista.nrtopico   AND
         b_w_lista.nritetop = w_lista.nritetop   THEN
         APPLY "END-ERROR".

END PROCEDURE.
/* ....................................................................... */


