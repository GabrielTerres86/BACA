/* .............................................................................

   Programa: Includes/pedmagc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Agosto/2003.                        Ultima atualizacao: 06/02/2006
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela PEDMAG.

   Alteracoes: 31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    
               06/02/2006 - Inclusao da opcao NO-UNDO nas temp-tables -
                            SQLWorks - Eder
............................................................................. */

DEFINE TEMP-TABLE crawtab                                NO-UNDO
       FIELD  nrpedido  AS  CHAR  FORMAT "x(8)"
       FIELD  dtsolped  AS  DATE  FORMAT "99/99/9999"
       FIELD  dssitped  AS  CHAR  FORMAT "x(10)".

/*FOR EACH crawtab:
    DELETE crawtab.
END. */

EMPTY TEMP-TABLE crawtab.
       
FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "AUTOMA"        AND
                       craptab.cdempres = 0               AND
                       craptab.tpregist = 0               AND
                       craptab.cdacesso  BEGINS "CM"      NO-LOCK.  
                       
    FIND FIRST crawtab WHERE                                                                  crawtab.nrpedido = SUBSTR(craptab.cdacesso, 7, 4) + 
                                  SUBSTR(craptab.cdacesso, 5, 2) + 
                                  SUBSTR(craptab.cdacesso, 3, 2) NO-ERROR.
    
    IF   NOT AVAILABLE crawtab  THEN
         DO:
            CREATE crawtab.
            ASSIGN
               crawtab.nrpedido = SUBSTR(craptab.cdacesso, 7, 4) + 
                                  SUBSTR(craptab.cdacesso, 5, 2) + 
                                  SUBSTR(craptab.cdacesso, 3, 2)
               
               crawtab.dtsolped = DATE(SUBSTR(craptab.cdacesso, 3, 2) + "/" +
                                       SUBSTR(craptab.cdacesso, 5, 2) + "/" + 
                                       SUBSTR(craptab.cdacesso, 7, 4)).
                                       
               IF   INT(craptab.dstextab) = 0   THEN
                    crawtab.dssitped = "SOLICITADO".
               ELSE
               IF   INT(craptab.dstextab) = 1   THEN
                    crawtab.dssitped = "LIBERADO".
               ELSE
                    crawtab.dssitped = "".
         END.       
END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nrpedido WITH FRAME f_pedido.

   ASSIGN  aux_contador = 0
           aux_flgretor = FALSE.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   INT(tel_nrpedido) > 0   THEN
        DO:
            FIND FIRST  crawtab WHERE 
                        crawtab.nrpedido = SUBSTR(tel_nrpedido, 5, 4) +
                                           SUBSTR(tel_nrpedido, 3, 2) +
                                           SUBSTR(tel_nrpedido, 1, 2)
                        EXCLUSIVE-LOCK NO-ERROR.
                        
            IF   AVAILABLE crawtab   THEN
                 DO:
                    ASSIGN tel_dspedido = tel_nrpedido
                           tel_dtsolped = crawtab.dtsolped
                           tel_dssitped = crawtab.dssitped.

                    DISPLAY tel_dspedido tel_dtsolped tel_dssitped
                            WITH FRAME f_lanctos.
                 END.
            ELSE
                 DO:
                    glb_cdcritic = 221.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                 END.
        END.
   ELSE
        DO:
            FOR EACH crawtab BY crawtab.nrpedido DESCENDING.

                ASSIGN aux_regexist = TRUE
                       aux_contador = aux_contador + 1.

                IF   aux_contador = 1   AND   aux_flgretor   THEN
                     DO:
                        PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        CLEAR FRAME f_lanctos ALL NO-PAUSE.
                     END.

                ASSIGN tel_dspedido = SUBSTR(crawtab.nrpedido, 7,2) + 
                                      SUBSTR(crawtab.nrpedido, 5,2) + 
                                      SUBSTR(crawtab.nrpedido, 1,4)
                       tel_dtsolped = crawtab.dtsolped
                       tel_dssitped = crawtab.dssitped.

                DISPLAY tel_dspedido tel_dtsolped tel_dssitped
                        WITH FRAME f_lanctos.

                IF   aux_contador = 11   THEN
                     DO:
                         ASSIGN aux_contador = 0
                                aux_flgretor = TRUE.
                     END.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.  /*  Fim do FOR EACH -- Leitura dos pedidos  */

            tel_nrpedido = "0".

            IF   NOT aux_regexist   THEN
                 DO:
                     glb_cdcritic = 157.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     NEXT.
                 END.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

