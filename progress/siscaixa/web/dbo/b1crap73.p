/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap73.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 19/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Pagto de Cheque 

   Alteracoes: 29/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               07/11/2005 - Alteracao de crapchq e crapchs p/ crapfdc
                            (SQLWorks - Eder)

               20/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
               
               02/03/2006 - Unificacao dos bancos - SQLWorks - Eder  
               
               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).

               26/02/2007 - Alterados os FINDs da crapfdc (Evandro).

               23/03/2007 - Leitura do crapfdc nao estava ok (Magui).

               22/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               28/01/2010 - Adaptações projeto IF CECRED (Guilherme).
               
               05/11/2010 - Exclui registro da tabela crapchd, chama BO
                            atualiza-previa-caixa e verifica se PAC faz
                            previa dos cheques (Elton).
                            
               04/01/2010 - Tratamento para migracao de PAC (Guilherme).
                          - Comentada chamada da procedure 
                            atualiza-previa-caixa (Elton).
                            
               15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir 
                            LENGTH 34 (Guilherme).             
                            
               27/05/2011 - Enviar email de controle de movimentacao
                            (Gabriel).             
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               15/10/2012 - Alteracao da logica para migracao de PAC
                            devido a migracao da AltoVale (Guilherme).
                            
               19/02/2014 - Ajuste leitura craptco (Daniel) 
              
               14/06/2018 - Alterado para considerar o campo crapdat.dtmvtocd 
                            como data de referencia - Everton Deserto(AMCOM).
							  

               15/10/2018 - Troca DELETE CRAPLCM pela chamada da rotina estorna_lancamento_conta 
                            de dentro da b1wgen0200 
                            (Renato AMcom)
                            
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
              
............................................................................ **/
/*----------------------------------------------------------------------*/
/*  b1crap73.p   - Estorno Pagto de Cheque                              */
/*  Hist¢ricos   - 21 ou 26(conta - 978809)                             */
/*  Autenticacao - PG                                                   */
/*----------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR glb_nrcalcul        AS DECI                             NO-UNDO.
DEF VAR glb_dsdctitg        AS CHAR                             NO-UNDO.
DEF VAR glb_stsnrcal        AS LOGI                             NO-UNDO.

DEF VAR i-cod-erro          AS INT                              NO-UNDO.
DEF VAR c-desc-erro         AS CHAR                             NO-UNDO.

DEF VAR h-b1wgen0200        AS HANDLE                           NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                             NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                             NO-UNDO.

DEF VAR h_b1crap00          AS HANDLE                           NO-UNDO.
DEF VAR h_b2crap00          AS HANDLE                           NO-UNDO.
DEF VAR h-b1crap02          AS HANDLE                           NO-UNDO.
DEF VAR h-b1wgen9998        AS HANDLE                           NO-UNDO.


DEF VAR p-nro-calculado     AS DEC                              NO-UNDO.
DEF VAR p-lista-digito      AS CHAR                             NO-UNDO.
DEF VAR de-nrctachq         AS DEC     FORMAT "zzz,zzz,zzz,9"   NO-UNDO.
DEF VAR c-cmc-7             AS CHAR                             NO-UNDO.
DEF VAR i-nro-lote          AS INTE                             NO-UNDO.
DEF VAR i-cdhistor          AS INTE                             NO-UNDO.
DEF VAR aux_lsconta3        AS CHAR                             NO-UNDO.
DEF VAR aux_lscontas        AS CHAR                             NO-UNDO.
DEF VAR i_conta             AS INTE                             NO-UNDO.
DEF VAR aux_nrdconta        AS INTE                             NO-UNDO.
DEF VAR i_nro-folhas        AS INTE                             NO-UNDO.
DEF VAR i_posicao           AS INTE                             NO-UNDO.
DEF VAR i_nro-talao         AS INTE                             NO-UNDO.
DEF VAR i_nro-docto         AS INTE                             NO-UNDO.
DEF VAR i_cheque            AS DEC     FORMAT "zzz,zzz,9"       NO-UNDO.
DEF VAR aux_indevchq        AS INTE                             NO-UNDO.
DEF VAR i-codigo-erro       AS INTE                             NO-UNDO.
DEF VAR in99                AS INTE                             NO-UNDO. 

DEF VAR i-cdbanchq          AS INTE                             NO-UNDO.
DEF VAR i-cdagechq          AS INTE                             NO-UNDO.
DEF VAR i-nrcheque          AS INTE                             NO-UNDO.
DEF VAR de-nrctabdb         AS DEC                              NO-UNDO.

DEF VAR aux_ctpsqitg        AS DEC                              NO-UNDO.
DEF VAR aux_nrdctitg        LIKE crapass.nrdctitg               NO-UNDO.
DEF VAR aux_nrctaass        LIKE crapass.nrdconta               NO-UNDO.

DEF VAR flg_exetrunc        AS LOG                              NO-UNDO.

DEF BUFFER crabass5 FOR crapass. 
DEF VAR aux_nrdigitg        AS CHAR                             NO-UNDO.
DEF VAR glb_cdcooper        AS INT                              NO-UNDO.
{includes/proc_conta_integracao.i}

PROCEDURE critica-valor:

    DEF INPUT PARAM p-cooper      AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT           /* Cod. Agencia */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-valor       AS DEC                              NO-UNDO.
          
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-valor = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe valor ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    RETURN "OK".
END PROCEDURE.

PROCEDURE critica-codigo-cheque-dig:
    
    DEF INPUT PARAM p-cooper       AS CHAR      /* Cod. Cooperativa */ NO-UNDO.
    DEF INPUT PARAM p-cod-agencia  AS INT        /* Cod. Agencia    */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa    AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-cmc-7-dig    AS CHAR                             NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-cdbanchq = INT(SUBSTR(p-cmc-7-dig,02,03)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN i-cdagechq = INT(SUBSTRING(p-cmc-7-dig,05,04)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    /* Conta Integracao */
    ASSIGN de-nrctabdb = IF i-cdbanchq = 1 
                         THEN DEC(SUBSTR(p-cmc-7-dig,25,08))
                         ELSE DEC(SUBSTR(p-cmc-7-dig,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN i-nrcheque = INT(SUBSTR(p-cmc-7-dig,14,06)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
            RETURN "NOK".
         END.
                  
    ASSIGN aux_lscontas = ""
           aux_nrdctitg = "".
    
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 0,
                           OUTPUT aux_lscontas).
                     
    /**  Conta Integracao   **/                     
    IF   LENGTH(STRING(de-nrctabdb)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = de-nrctabdb
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.                    
    /*************
    IF   ((i-cdbanchq = 1 AND CAN-DO("95,3420",STRING(i-cdagechq))) AND 
         CAN-DO(aux_lscontas,STRING((INT(SUBSTR(p-cmc-7-dig,25,08)))))) OR
         (i-cdbanchq = 756 AND i-cdagechq = crapcop.cdagebcb) OR
         /**   Conta Integracao **/                             
         (aux_nrdctitg <> "" AND CAN-DO("3420", STRING(i-cdagechq)))  THEN
         DO:
         END.
    ELSE 
    *********************/

    /* Validar se a folha de cheque é da cooperativa */
    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = i-cdbanchq         AND
                       crapfdc.cdagechq = i-cdagechq         AND
                       crapfdc.nrctachq = de-nrctabdb        AND
                       crapfdc.nrcheque = i-nrcheque
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapfdc   THEN
    DO:
       /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
       /* Se for Bco Cecred ou Bancoob usa o nrctaant = de-nrctabdb na busca da conta */
       IF  i-cdbanchq = crapcop.cdbcoctl  OR 
           i-cdbanchq = 756               THEN
       DO:
           /* Localiza se o cheque é de uma conta migrada */
           FIND FIRST craptco WHERE 
                      craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                      craptco.nrctaant = INT(de-nrctabdb) AND /* conta antiga */
                      craptco.tpctatrf = 1                AND
                      craptco.flgativo = TRUE
                      NO-LOCK NO-ERROR.

           IF  AVAIL craptco  THEN
           DO:
               /* verifica se o cheque pertence a conta migrada */
               FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                        crapfdc.cdbanchq = i-cdbanchq       AND
                                        crapfdc.cdagechq = i-cdagechq       AND
                                        crapfdc.nrctachq = de-nrctabdb      AND
                                        crapfdc.nrcheque = i-nrcheque
                                        NO-LOCK NO-ERROR.
               IF  NOT AVAIL crapfdc  THEN
               DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = "Cheque nao e da Cooperativa ".                           
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.

           END.
       END.
       ELSE 
       /* Se for BB usa a conta ITG para buscar conta migrada */
       /* Usa o nrdctitg = de-nrctabdb na busca da conta */
       IF  i-cdbanchq = 1 AND i-cdagechq = 3420  THEN
       DO:
           /* Formata conta integracao */
           RUN fontes/digbbx.p (INPUT  de-nrctabdb,
                                OUTPUT glb_dsdctitg,
                                OUTPUT glb_stsnrcal).
           IF   NOT glb_stsnrcal   THEN
                DO:
                    ASSIGN i-cod-erro  = 8
                           c-desc-erro = " ".           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

           /* Localiza se o cheque é de uma conta migrada */
           FIND FIRST craptco WHERE 
                      craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                      craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                      craptco.tpctatrf = 1                AND
                      craptco.flgativo = TRUE
                      NO-LOCK NO-ERROR.

           IF  AVAIL craptco  THEN
           DO:
               /* verifica se o cheque pertence a conta migrada */
               FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                        crapfdc.cdbanchq = i-cdbanchq       AND
                                        crapfdc.cdagechq = i-cdagechq       AND
                                        crapfdc.nrctachq = de-nrctabdb      AND
                                        crapfdc.nrcheque = i-nrcheque
                                        NO-LOCK NO-ERROR.

               IF  NOT AVAIL crapfdc  THEN
               DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = "Cheque nao e da Cooperativa ".                           
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.

           END.

       END.

    END. 
   
    IF   p-cmc-7-dig <> " "   THEN  
         DO:
             RUN dbo/pcrap09.p (INPUT p-cooper,
                                INPUT p-cmc-7-dig,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).
             IF   p-nro-calculado > 0   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
            
                      IF   p-nro-calculado > 1   THEN
                           ASSIGN i-cod-erro = p-nro-calculado.
 
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE critica-codigo-cheque-valor:
    
    DEF INPUT PARAM p-cooper      AS CHAR      /* Cod. Cooperativa */ NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT       /* Cod. Agencia     */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-cmc-7       AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cmc-7-dig   AS CHAR                             NO-UNDO.
          
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-cmc-7     = " "  AND
         p-cmc-7-dig = " "  THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe numero cheque ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   p-cmc-7  <> " "   THEN 
         DO:
             IF  LENGTH(p-cmc-7) = 34  THEN
                 ASSIGN SUBSTR(p-cmc-7,34,1) = ":".

             IF   LENGTH(p-cmc-7)      <> 34  OR
                  SUBSTR(p-cmc-7,1,1)  <> "<" OR
                  SUBSTR(p-cmc-7,10,1) <> "<" OR
                  SUBSTR(p-cmc-7,21,1) <> ">" OR
                  SUBSTR(p-cmc-7,34,1) <> ":"   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             ASSIGN i-cdbanchq = INT(SUBSTR(p-cmc-7,02,03)) NO-ERROR.

             IF   ERROR-STATUS:ERROR   THEN
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             ASSIGN i-cdagechq = INT(SUBSTRING(p-cmc-7,05,04)) NO-ERROR.
             IF   ERROR-STATUS:ERROR   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             /* Conta Integracao */
             ASSIGN de-nrctabdb = IF i-cdbanchq = 1 
                                  THEN DEC(SUBSTR(p-cmc-7,25,08))
                                  ELSE DEC(SUBSTR(p-cmc-7,23,10)) NO-ERROR.
             /*---------------*/

             IF   ERROR-STATUS:ERROR   THEN
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             ASSIGN i-nrcheque = INT(SUBSTR(p-cmc-7,14,06)) NO-ERROR.
    
             IF   ERROR-STATUS:ERROR   THEN
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                     RETURN "NOK".
                  END.
             
             ASSIGN aux_lscontas = ""
                    aux_nrdctitg = "".
             /*  Tabela com as contas convenio do Banco do Brasil - Geral  */
             RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                                    INPUT 0,
                                    OUTPUT aux_lscontas).
    

             /**  Conta Integracao  **/
             IF   LENGTH(STRING(de-nrctabdb)) <= 8   THEN
                  DO:
                      ASSIGN aux_ctpsqitg = de-nrctabdb
                             glb_cdcooper = crapcop.cdcooper.
                      RUN existe_conta_integracao.  
                  END.                    
             /************************
             IF   ((i-cdbanchq = 1 AND CAN-DO("95,3420",STRING(i-cdagechq))) AND
                  CAN-DO(aux_lscontas,STRING((INT(SUBSTR(p-cmc-7,25,08)))))) OR
                  (i-cdbanchq = 756 AND i-cdagechq = crapcop.cdagebcb) 
                  /**  Conta Integracao **/ 
                  OR 
                  (aux_nrdctitg <> "" AND CAN-DO("3420", STRING(i-cdagechq)))
                  THEN  
                  DO:
                  END.
             ELSE
             ********************/

             /* Validar se a folha de cheque é da cooperativa */
             FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                                crapfdc.cdbanchq = i-cdbanchq         AND
                                crapfdc.cdagechq = i-cdagechq         AND
                                crapfdc.nrctachq = de-nrctabdb        AND
                                crapfdc.nrcheque = i-nrcheque
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapfdc   THEN
             DO:
                /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                /* Se for Bco Cecred ou Bancoob usa o nrctaant = de-nrctabdb na busca da conta */
                IF  i-cdbanchq = crapcop.cdbcoctl  OR 
                    i-cdbanchq = 756               THEN
                DO:
                    /* Localiza se o cheque é de uma conta migrada */
                    FIND FIRST craptco WHERE 
                               craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                               craptco.nrctaant = INT(de-nrctabdb) AND /* conta antiga */
                               craptco.tpctatrf = 1                AND
                               craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

                    IF  AVAIL craptco  THEN
                    DO:
                        /* verifica se o cheque pertence a conta migrada */
                        FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                 crapfdc.cdbanchq = i-cdbanchq       AND
                                                 crapfdc.cdagechq = i-cdagechq       AND
                                                 crapfdc.nrctachq = de-nrctabdb      AND
                                                 crapfdc.nrcheque = i-nrcheque
                                                 NO-LOCK NO-ERROR.
                        IF  NOT AVAIL crapfdc  THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Cheque nao e da Cooperativa ".                           
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.

                    END.
                END.
                ELSE 
                /* Se for BB usa a conta ITG para buscar conta migrada */
                /* Usa o nrdctitg = de-nrctabdb na busca da conta */
                IF  i-cdbanchq = 1 AND i-cdagechq = 3420  THEN
                DO:
                    /* Formata conta integracao */
                    RUN fontes/digbbx.p (INPUT  de-nrctabdb,
                                         OUTPUT glb_dsdctitg,
                                         OUTPUT glb_stsnrcal).
                    IF   NOT glb_stsnrcal   THEN
                         DO:
                             ASSIGN i-cod-erro  = 8
                                    c-desc-erro = " ".           
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                         END.

                    /* Localiza se o cheque é de uma conta migrada */
                    FIND FIRST craptco WHERE 
                               craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                               craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                               craptco.tpctatrf = 1                AND
                               craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

                    IF  AVAIL craptco  THEN
                    DO:
                        /* verifica se o cheque pertence a conta migrada */
                        FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                 crapfdc.cdbanchq = i-cdbanchq       AND
                                                 crapfdc.cdagechq = i-cdagechq       AND
                                                 crapfdc.nrctachq = de-nrctabdb      AND
                                                 crapfdc.nrcheque = i-nrcheque
                                                 NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapfdc  THEN
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Cheque nao e da Cooperativa ".                           
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT i-cod-erro,
                                           INPUT c-desc-erro,
                                           INPUT YES).
                            RETURN "NOK".
                        END.

                    END.
                END.
                ELSE
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Cheque nao e da Cooperativa ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
             END. 

             RUN dbo/pcrap09.p (INPUT p-cooper,
                                INPUT p-cmc-7,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).
             IF   p-nro-calculado > 0 OR
                  NUM-ENTRIES(p-lista-digito) <> 3   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
 
                      IF   p-nro-calculado > 1 THEN
                           ASSIGN i-cod-erro = p-nro-calculado.
 
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.
    IF   p-cmc-7-dig <> " "  THEN  
         DO:
             RUN dbo/pcrap09.p (INPUT p-cooper,
                                INPUT p-cmc-7-dig,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).
             IF   p-nro-calculado > 0   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
            
                      IF  p-nro-calculado > 1 THEN
                          ASSIGN i-cod-erro = p-nro-calculado.
            
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-codigo-cheque:

    DEF INPUT  PARAM p-cooper      AS CHAR      /* Cod. Cooperativa */ NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia AS INT           /* Cod. Agencia */ NO-UNDO. 
    DEF INPUT  PARAM p-nro-caixa   AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT  PARAM p-cmc-7       AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM p-cmc-7-dig   AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM p-cdcmpchq    AS INT  FORMAT "zz9"     /* Comp */ NO-UNDO.
    DEF OUTPUT PARAM p-cdbanchq    AS INT  FORMAT "zz9"    /* Banco */ NO-UNDO.
    DEF OUTPUT PARAM p-cdagechq    AS INT  FORMAT "zzz9"      /* Ag */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc1    AS INT  FORMAT "9"         /* C1 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9"      NO-UNDO. 
    DEF OUTPUT PARAM p-nrddigc2    AS INT  FORMAT "9"         /* C2 */ NO-UNDO. 
    DEF OUTPUT PARAM p-nrcheque    AS INT  FORMAT "zzz,zz9"  /* Chq */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc3    AS INT  FORMAT "9"         /* C3 */ NO-UNDO.
          
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cmc-7 <> " "   THEN
         ASSIGN c-cmc-7              = p-cmc-7
                 SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /* <99999999<9999999999>999999999999: */
   
    ASSIGN p-cdbanchq = INT(SUBSTRING(c-cmc-7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
       
    ASSIGN p-cdagechq = INT(SUBSTRING(c-cmc-7,05,04)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    ASSIGN p-cdcmpchq = INT(SUBSTRING(c-cmc-7,11,03)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
      
    ASSIGN p-nrcheque = INT(SUBSTR(c-cmc-7,14,06)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
                                                 
    ASSIGN de-nrctachq = DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN p-nrctabdb = IF p-cdbanchq = 1 
                        THEN DEC(SUBSTR(c-cmc-7,25,08))
                        ELSE DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.
  
    /*  Calcula primeiro digito de controle  */
    ASSIGN p-nro-calculado = DECIMAL(STRING(p-cdcmpchq,"999") +
                                     STRING(p-cdbanchq,"999") +
                                     STRING(p-cdagechq,"9999") + "0").
                                  
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK"   THEN  
         RETURN "NOK".
    */
    ASSIGN p-nrddigc1 = INT(SUBSTR(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).   
    /*  Calcula segundo digito de controle  */
    ASSIGN p-nro-calculado =  de-nrctachq * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK" THEN  
         RETURN "NOK".
    */              
    ASSIGN p-nrddigc2 = INT(SUBSTR(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).    
    /*  Calcula terceiro digito de controle  */
    ASSIGN p-nro-calculado = p-nrcheque * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK" THEN  
         RETURN "NOK". 
    */              
    ASSIGN p-nrddigc3 = INT(SUBSTR(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-codigo-cheque-valor:

    DEF INPUT PARAM  p-cooper       AS CHAR      /* Cod. Cooperativa*/ NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia  AS INT          /* Cod. Agencia */ NO-UNDO.
    DEF INPUT PARAM  p-nro-caixa    AS INT  FORMAT "999" /*Nro Caixa*/ NO-UNDO.
    DEF INPUT PARAM  p-cmc-7        AS CHAR                            NO-UNDO.
    DEF INPUT PARAM  p-cmc-7-dig    AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM p-cdcmpchq     AS INT FORMAT "zz9"     /* Comp */ NO-UNDO.
    DEF OUTPUT PARAM p-cdbanchq     AS INT FORMAT "zz9"    /* Banco */ NO-UNDO.
    DEF OUTPUT PARAM p-cdagechq     AS INT FORMAT "zzz9" /* Agencia */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc1     AS INT FORMAT "9"         /* C1 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrctabdb     AS DEC FORMAT "zzz,zzz,zzz,9"      NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc2     AS INT FORMAT "9"         /* C2 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrcheque     AS INT FORMAT "zzz,zz9"  /* Chq */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc3     AS INT FORMAT "9"         /* C3 */ NO-UNDO.
    DEF OUTPUT PARAM p-valor        AS DEC NO-UNDO.
          
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cmc-7 <> " " THEN
         ASSIGN c-cmc-7              = p-cmc-7
                SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig.  /* <99999999<9999999999>999999999999: */
   
    ASSIGN p-cdbanchq = INT(SUBSTRING(c-cmc-7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
       
    ASSIGN p-cdagechq = INT(SUBSTRING(c-cmc-7,05,04)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    ASSIGN p-cdcmpchq = INT(SUBSTRING(c-cmc-7,11,03)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                   c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.
 
    ASSIGN p-nrcheque = INT(SUBSTR(c-cmc-7,14,06)) NO-ERROR.
    IF   ERROR-STATUS:ERROR    THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
                                                 
    ASSIGN de-nrctachq = DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN p-nrctabdb = IF p-cdbanchq = 1 
                        THEN DEC(SUBSTR(c-cmc-7,25,08))
                        ELSE DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN 
         DO:
              ASSIGN i-cod-erro  = 666
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.    
    
    /*  Calcula primeiro digito de controle  */
    ASSIGN p-nro-calculado = DECIMAL(STRING(p-cdcmpchq,"999") +
                                     STRING(p-cdbanchq,"999") +
                                     STRING(p-cdagechq,"9999") + "0").
                                  
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
   
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK" THEN  
         RETURN "NOK".
    */
    ASSIGN p-nrddigc1 = INT(SUBSTRING(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).
    /*  Calcula segundo digito de controle  */
    ASSIGN p-nro-calculado =  de-nrctachq * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK"   THEN  
         RETURN "NOK".
    */              
    ASSIGN p-nrddigc2 = INT(SUBSTR(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).
             
    /*  Calcula terceiro digito de controle  */
    ASSIGN p-nro-calculado = p-nrcheque * 10.
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
                                      
    FIND FIRST craperr WHERE craperr.cdcooper = crapcop.cdcooper    AND
                             craperr.cdagenci = INT(p-cod-agencia)  AND
                             craperr.nrdcaixa = INT(p-nro-caixa)    AND
                             craperr.cdcritic = 8 
                             EXCLUSIVE-LOCK NO-ERROR.
                             
    IF   AVAIL craperr   THEN DELETE craperr.

    DELETE PROCEDURE h_b2crap00.
    /*
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK". 
    */              
    ASSIGN p-nrddigc3 = INT(SUBSTR(STRING(p-nro-calculado),
                        LENGTH(STRING(p-nro-calculado)))).

    ASSIGN i_cheque = INT(STRING(p-nrcheque,"999999") + 
                      STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
    
    ASSIGN p-valor = 0. /* Obter o valor */

    FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                             crapass.nrdconta = INT(p-nrctabdb) 
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapass   THEN 
         DO:
             IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                 DO:
       
                     FIND FIRST craptrf WHERE
                                craptrf.cdcooper = crapcop.cdcooper     AND
                                craptrf.nrdconta = crapass.nrdconta     AND
                                craptrf.tptransa = 1                    AND
                                craptrf.insittrs = 2 
                                USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                     IF   AVAIL craptrf THEN 
                          ASSIGN p-nrctabdb  = craptrf.nrsconta.
                 END.    
         END.
    
    FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                       craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplcm.cdagenci = p-cod-agencia     AND
                       craplcm.cdbccxlt = 11                AND /* Fixo */
                       craplcm.nrdolote = i-nro-lote        AND
                       craplcm.nrdctabb = int(p-nrctabdb)   AND
                       craplcm.nrdocmto = i_cheque          
                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   NOT AVAIL craplcm   THEN  
     DO:
         /* VERIFICAR SE O LANCAMENTO EH DE UM CHEQUE MIGRADO */

         /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
         /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = crapcop.cdbcoctl  OR 
             p-cdbanchq = 756               THEN
         DO:
             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrctaant = inte(p-nrctabdb) AND /* conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:

                 FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                    craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplcm.cdagenci = craptco.cdagenci          AND
                                    craplcm.cdbccxlt = 100                       AND /* Fixo */
                                    craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                    craplcm.nrdctabb = int(p-nrctabdb)           AND
                                    craplcm.nrdocmto = i_cheque          
                                    USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplcm  THEN
                 DO:
                     ASSIGN i-cod-erro  = 90
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                   INPUT YES).
                     RETURN "NOK".
                 END.

             END.
         END.
         ELSE 
         /* Se for BB usa a conta ITG para buscar conta migrada */
         /* Usa o nrdctitg = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:
                 FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                    craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplcm.cdagenci = craptco.cdagenci          AND
                                    craplcm.cdbccxlt = 100                       AND /* Fixo */
                                    craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                    craplcm.nrdctabb = int(p-nrctabdb)           AND
                                    craplcm.nrdocmto = i_cheque          
                                    USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplcm  THEN
                 DO:
                     ASSIGN i-cod-erro  = 90
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                   INPUT YES).
                     RETURN "NOK".
                 END.

             END.
         END.
         ELSE
         DO:
             ASSIGN i-cod-erro  = 90
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                           INPUT YES).
             RETURN "NOK".
         END.
     END. 
    
     ASSIGN p-valor = craplcm.vllanmto.

     RETURN "OK".
END PROCEDURE.

PROCEDURE valida-estorno-pagto-cheque:

    DEF INPUT  PARAM  p-cooper      AS CHAR   /* Cod. Cooperativa   */ NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia AS INT       /* Cod. Agencia    */ NO-UNDO.
    DEF INPUT  PARAM  p-nro-caixa   AS INT FORMAT "999" /* Nr Caixa */ NO-UNDO.
    DEF INPUT  PARAM  p-cmc-7       AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM  p-cmc-7-dig   AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM  p-cdcmpchq    AS INT  FORMAT "zz9"    /* Comp */ NO-UNDO.
    DEF INPUT  PARAM  p-cdbanchq    AS INT  FORMAT "zz9"   /* Banco */ NO-UNDO.
    DEF INPUT  PARAM  p-cdagechq    AS INT  FORMAT "zzz9" /* Agenc */  NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc1    AS INT  FORMAT "9"       /* C1 */  NO-UNDO.                            
    DEF INPUT  PARAM  p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9"     NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc2    AS INT  FORMAT "9"        /* C2 */ NO-UNDO.
    DEF INPUT  PARAM  p-nro-cheque  AS INT  FORMAT "zzz,zz9" /* Chq */ NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc3    AS INT  FORMAT "9"        /* C3 */ NO-UNDO.                            
    DEF OUTPUT PARAM  p-valor       AS DEC                             NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN p-nrctabdb = DEC(REPLACE(STRING(p-nrctabdb), '.','')).
    
    /*** Magui desativado em 14/12/2005
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nrdconta = INT(p-nrctabdb)   NO-LOCK NO-ERROR.
    IF   AVAIL crapass   THEN 
         DO:
             RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
             RUN retornaCtaTransferencia IN h-b1crap02 (p-cooper,
                                                        p-cod-agencia,
                                                        p-nro-caixa,
                                                        p-nrctabdb,
                                                        OUTPUT aux_nrdconta).

             IF   RETURN-VALUE = "NOK"   THEN 
                  DO:
                      DELETE PROCEDURE h-b1crap02.
                      RETURN "NOK".
                  END.

             IF   aux_nrdconta <> 0   THEN
                  ASSIGN p-nrctabdb = aux_nrdconta.

             DELETE PROCEDURE h-b1crap02.
         END.
    *************************/
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
 
    IF   p-cmc-7 <> " "  THEN
         ASSIGN c-cmc-7              = p-cmc-7
                SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /* <99999999<9999999999>999999999999: */
   
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nrctabdb = 978809   THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    ASSIGN i_cheque = INT(STRING(p-nro-cheque,"999999") +
                      STRING(p-nrddigc3,"9")).   /* Numero do Cheque */

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = i-cdhistor
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL craphis   THEN 
         DO:
             ASSIGN i-cod-erro  = 83
                   c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   craphis.tplotmov <> 1    THEN
         DO:
             ASSIGN i-cod-erro  = 94
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   craphis.tpctbcxa   <> 2    AND
         craphis.tpctbcxa   <> 3    THEN 
         DO:
             ASSIGN i-cod-erro  = 689
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    /*** Veirifica se PAC faz previa dos cheques ***/
    FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                        craptab.nmsistem = "CRED"             AND
                        craptab.tptabela = "GENERI"           AND
                        craptab.cdempres = 0                  AND
                        craptab.cdacesso = "EXETRUNCAGEM"     AND
                        craptab.tpregist = p-cod-agencia    
                        NO-LOCK NO-ERROR.        
        
    IF   craptab.dstextab = "SIM" THEN
         DO:
             ASSIGN  i-cod-erro   = 0
                     flg_exetrunc = TRUE.
              
             FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                                craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                craplcm.cdagenci = p-cod-agencia     AND
                                craplcm.cdbccxlt = 11                AND /* Fixo */
                                craplcm.nrdolote = i-nro-lote        AND
                                craplcm.nrdctabb = INT(p-nrctabdb)   AND 
                                craplcm.nrdocmto = i_cheque   /* USE-INDEX craplcm1 */
                                NO-LOCK NO-ERROR.             

             IF  NOT AVAIL craplcm  THEN
             DO:
                 /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                 /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                     p-cdbanchq = 756               THEN
                 DO:
                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:

                         FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                            craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                            craplcm.cdagenci = craptco.cdagenci          AND
                                            craplcm.cdbccxlt = 100                       AND /* Fixo */
                                            craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                            craplcm.nrdctabb = int(p-nrctabdb)           AND
                                            craplcm.nrdocmto = i_cheque          
                                            USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                         
                         /* O lancamento, neste ponto, obrigatoriamente deve existir */
                         IF  NOT AVAIL craplcm  THEN
                         DO:
                             ASSIGN i-cod-erro  = 90
                                    c-desc-erro = " ".           
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,                                  
                                            INPUT c-desc-erro,
                                           INPUT YES).
                             RETURN "NOK".
                         END.

                     END.
                 END.
                 ELSE 
                 /* Se for BB usa a conta ITG para buscar conta migrada */
                 /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                 DO:
                     /* Formata conta integracao */
                     RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                          OUTPUT glb_dsdctitg,
                                          OUTPUT glb_stsnrcal).
                     IF   NOT glb_stsnrcal   THEN
                          DO:
                              ASSIGN i-cod-erro  = 8
                                     c-desc-erro = " ".           
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                          END.

                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:
                         FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                            craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                            craplcm.cdagenci = craptco.cdagenci          AND
                                            craplcm.cdbccxlt = 100                       AND /* Fixo */
                                            craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                            craplcm.nrdctabb = int(p-nrctabdb)           AND
                                            craplcm.nrdocmto = i_cheque          
                                            USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                         /* O lancamento, neste ponto, obrigatoriamente deve existir */
                         IF  NOT AVAIL craplcm  THEN
                         DO:
                             ASSIGN i-cod-erro  = 90
                                    c-desc-erro = " ".           
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                           INPUT YES).
                             RETURN "NOK".
                         END.

                     END.
                 END.

             END.
             
             FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper  AND
                                    crapchd.dtmvtolt = craplcm.dtmvtolt  AND
                                    crapchd.cdagenci = p-cod-agencia     AND
                                    crapchd.cdbccxlt = 11                AND
                                    crapchd.nrdolote = i-nro-lote        AND
                                    crapchd.nrseqdig = craplcm.nrseqdig
                                    USE-INDEX crapchd3 NO-LOCK:
                
                 IF  crapchd.insitprv > 0 THEN
                     ASSIGN i-cod-erro =  99999.
             END.

             IF   i-cod-erro > 0 THEN
                  DO:
                        ASSIGN i-cod-erro  = 0  
                               c-desc-erro = "Estorno nao pode ser efetuado. " +
                                             "Cheque ja enviado para previa.".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                  END.

         END.
    
    /* Verifica horario de Corte */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "HRTRCOMPEL"      AND
                       craptab.tpregist = p-cod-agencia  
                       NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL craptab   THEN  
        DO:
            ASSIGN i-cod-erro  = 676
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".          
        END.   

    /** Se PAC nao executa previa faz verificacao de envio **/
    IF  flg_exetrunc = FALSE THEN
        IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
            DO:
                ASSIGN i-cod-erro  = 677
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.    

    IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
        DO:
            ASSIGN i-cod-erro  = 676
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 
    
    ASSIGN aux_lsconta3 = "".
    /*  Le tabela com as contas convenio do Banco do Brasil - cheque salario */     
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 3,
                           OUTPUT aux_lsconta3).
                       
         
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = p-nrctabdb. 
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".

    ASSIGN aux_lscontas = ""
           aux_nrdctitg = "".
    /*  Le tabela com as  contas convenio do Banco do Brasil - Geral  */
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 0,
                           OUTPUT aux_lscontas).


    /** Conta Integracao **/
    IF   LENGTH(STRING(p-nrctabdb)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nrctabdb
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.                    

    /****************
    IF   NOT CAN-DO(aux_lscontas,STRING(p-nrctabdb)) 
         AND  aux_nrdctitg = ""   THEN  /* Conta Integracao */
    *************************/
    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = INTE(p-nrctabdb)   AND
                       crapfdc.nrcheque = p-nro-cheque
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapfdc   THEN
    DO:
        /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
        /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
        IF  p-cdbanchq = crapcop.cdbcoctl  OR 
            p-cdbanchq = 756               THEN
        DO:
            /* Localiza se o cheque é de uma conta migrada */
            FIND FIRST craptco WHERE 
                       craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                       craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

            IF  AVAIL craptco  THEN
            DO:
                /* verifica se o cheque pertence a conta migrada */
                FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                         crapfdc.cdbanchq = p-cdbanchq       AND
                                         crapfdc.cdagechq = p-cdagechq       AND
                                         crapfdc.nrctachq = p-nrctabdb       AND
                                         crapfdc.nrcheque = INT(p-nro-cheque)
                                         NO-LOCK NO-ERROR.
                IF  NOT AVAIL crapfdc  THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Cheque nao e da Cooperativa ".                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            END.
        END.
        ELSE 
        /* Se for BB usa a conta ITG para buscar conta migrada */
        /* Usa o nrdctitg = p-nrctabdb na busca da conta */
        IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
        DO:
            /* Formata conta integracao */
            RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                 OUTPUT glb_dsdctitg,
                                 OUTPUT glb_stsnrcal).
            IF   NOT glb_stsnrcal   THEN
                 DO:
                     ASSIGN i-cod-erro  = 8
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.

            /* Localiza se o cheque é de uma conta migrada */
            FIND FIRST craptco WHERE 
                       craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                       craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

            IF  AVAIL craptco  THEN
            DO:
                /* verifica se o cheque pertence a conta migrada */
                FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                         crapfdc.cdbanchq = p-cdbanchq       AND
                                         crapfdc.cdagechq = p-cdagechq       AND
                                         crapfdc.nrctachq = p-nrctabdb       AND
                                         crapfdc.nrcheque = INT(p-nro-cheque)
                                         NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapfdc  THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Cheque nao e da Cooperativa ".                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
            END.
        END.
    END. 
    ELSE
    DO: 
        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                           crapass.nrdconta = crapfdc.nrdconta 
                           NO-LOCK NO-ERROR.
        IF   NOT AVAIL crapass   THEN 
             DO: 
                 ASSIGN i-cod-erro  = 9
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
    END.

    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).

    IF   i-cdhistor = 21   THEN 
         DO:
             ASSIGN i_nro-docto  = INT(STRING(p-nro-cheque,"999999") +
                                   STRING(p-nrddigc3,"9")). /* Numero do Chq */
             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,     /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,     /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,       /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas).   /* Nro Folhas */
                                
             FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                crapfdc.cdbanchq = p-cdbanchq          AND
                                crapfdc.cdagechq = p-cdagechq          AND
                                crapfdc.nrctachq = p-nrctabdb          AND
                                crapfdc.nrcheque = INT(p-nro-cheque)
                                USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapfdc   THEN 
             DO:
                 /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                 /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                     p-cdbanchq = 756               THEN
                 DO:
                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                                craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:
                         /* verifica se o cheque pertence a conta migrada */
                         FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                  crapfdc.cdbanchq = p-cdbanchq       AND
                                                  crapfdc.cdagechq = p-cdagechq       AND
                                                  crapfdc.nrctachq = p-nrctabdb       AND
                                                  crapfdc.nrcheque = INT(p-nro-cheque)
                                                  NO-LOCK NO-ERROR.
                         IF  NOT AVAIL crapfdc  THEN
                         DO:
                             ASSIGN i-cod-erro  = 180
                                    c-desc-erro = "".
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                         END.

                     END.
                 END.
                 ELSE 
                 /* Se for BB usa a conta ITG para buscar conta migrada */
                 /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                 DO:
                     /* Formata conta integracao */
                     RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                          OUTPUT glb_dsdctitg,
                                          OUTPUT glb_stsnrcal).
                     IF   NOT glb_stsnrcal   THEN
                          DO:
                              ASSIGN i-cod-erro  = 8
                                     c-desc-erro = " ".           
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                          END.

                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                                craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:
                         /* verifica se o cheque pertence a conta migrada */
                         FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                  crapfdc.cdbanchq = p-cdbanchq       AND
                                                  crapfdc.cdagechq = p-cdagechq       AND
                                                  crapfdc.nrctachq = p-nrctabdb       AND
                                                  crapfdc.nrcheque = INT(p-nro-cheque)
                                                  NO-LOCK NO-ERROR.

                         IF  NOT AVAIL crapfdc  THEN
                         DO:
                             ASSIGN i-cod-erro  = 180
                                    c-desc-erro = "".
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                            INPUT YES).
                             RETURN "NOK".
                         END.
                     END.
                 END.
                 ELSE
                 DO:
                     ASSIGN i-cod-erro  = 180
                            c-desc-erro = "".
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
             END.
         END.
    ELSE 
         DO:
             IF   CAN-DO(aux_lsconta3,STRING(p-nrctabdb))   AND
                  i-cdhistor  = 26                          THEN 
                  DO:
                      ASSIGN glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,
                                                       "9999999"),1,6)).

                      FIND crapfdc WHERE
                           crapfdc.cdcooper = crapcop.cdcooper    AND
                           crapfdc.cdbanchq = p-cdbanchq          AND
                           crapfdc.cdagechq = p-cdagechq          AND
                           crapfdc.nrctachq = p-nrctabdb          AND
                           crapfdc.nrcheque = INT(p-nro-cheque)
                           USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.

                      IF   AVAIL crapfdc   THEN 
                           DO:
                               IF   CAN-FIND(craplcm WHERE
                                             craplcm.cdcooper =
                                                     crapcop.cdcooper   AND
                                             craplcm.nrdconta = 
                                                     crapfdc.nrdconta   AND
                                             craplcm.dtmvtolt = 
                                                     crapdat.dtmvtocd   AND   /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                             craplcm.cdhistor = 101     AND
                                             craplcm.nrdocmto = i_cheque
                                             USE-INDEX craplcm2)  THEN 
                                    DO:
                                        ASSIGN i-cod-erro  = 343  
                                               c-desc-erro = " ".         
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END.
                               IF   crapfdc.incheque <> 5 AND
                                    crapfdc.incheque <> 6 AND
                                    crapfdc.incheque <> 7   THEN 
                                    DO:
                                        ASSIGN i-cod-erro  = 99
                                               c-desc-erro = " ".           
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END. 
                           END.
                      ELSE 
                           DO:
                               ASSIGN i-cod-erro = 286 
                                      c-desc-erro = " ".           
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                  END. 
         END.
    
    FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                       craplcm.dtmvtolt = crapdat.dtmvtocd  AND  /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                       craplcm.cdagenci = p-cod-agencia     AND
                       craplcm.cdbccxlt = 11                AND /* Fixo */
                       craplcm.nrdolote = i-nro-lote        AND
                       craplcm.nrdctabb = INT(p-nrctabdb)   AND
                       craplcm.nrdocmto = i_cheque          
                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

     IF   NOT AVAIL craplcm  THEN
     DO:
         /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
         /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = crapcop.cdbcoctl  OR 
             p-cdbanchq = 756               THEN
         DO:
             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:

                 FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                    craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplcm.cdagenci = craptco.cdagenci          AND
                                    craplcm.cdbccxlt = 100                       AND /* Fixo */
                                    craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                    craplcm.nrdctabb = int(p-nrctabdb)           AND
                                    craplcm.nrdocmto = i_cheque          
                                    USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplcm  THEN
                 DO:
                     ASSIGN i-cod-erro  = 90
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                   INPUT YES).
                     RETURN "NOK".
                 END.

             END.
         END.
         ELSE 
         /* Se for BB usa a conta ITG para buscar conta migrada */
         /* Usa o nrdctitg = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT p-nrctabdb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:
                 FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                    craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplcm.cdagenci = craptco.cdagenci          AND
                                    craplcm.cdbccxlt = 100                       AND /* Fixo */
                                    craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                    craplcm.nrdctabb = int(p-nrctabdb)           AND
                                    craplcm.nrdocmto = i_cheque          
                                    USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplcm  THEN
                 DO:
                     ASSIGN i-cod-erro  = 90
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                   INPUT YES).
                     RETURN "NOK".
                 END.

             END.
         END.
         ELSE
         DO:
             ASSIGN i-cod-erro  = 90
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
     END.
     ELSE
     IF   ENTRY(1, craplcm.cdpesqbb) <> "CRAP53"    THEN 
          DO:
              ASSIGN i-cod-erro  = 90
                     c-desc-erro = " ".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END. 

     ASSIGN p-valor = craplcm.vllanmto.

     FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper     AND
                        craplot.dtmvtolt = crapdat.dtmvtocd     AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                        craplot.cdagenci = p-cod-agencia        AND
                        craplot.cdbccxlt = 11                   AND  /* Fixo */
                        craplot.nrdolote = i-nro-lote   
                        NO-LOCK NO-ERROR.
          
     IF   NOT AVAIL craplot   THEN 
     DO:
         /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
         /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = crapcop.cdbcoctl  OR 
             p-cdbanchq = 756               THEN
         DO:
             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:
                 FIND craplot WHERE craplot.cdcooper = craptco.cdcooper     AND /* coop nova */
                                    craplot.dtmvtolt = crapdat.dtmvtocd     AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplot.cdagenci = craptco.cdagenci     AND
                                    craplot.cdbccxlt = 11                   AND  /* Fixo */
                                    craplot.nrdolote = 205000 + craptco.cdagenci   
                                    NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplot  THEN
                 DO:
                     ASSIGN i-cod-erro  = 60
                              c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.

             END.
         END.
         ELSE 
         /* Se for BB usa a conta ITG para buscar conta migrada */
         /* Usa o nrdctitg = p-nrctabdb na busca da conta */
         IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT p-nrctabdb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             /* Localiza se o cheque é de uma conta migrada */
             FIND FIRST craptco WHERE 
                        craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                        craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                        craptco.tpctatrf = 1                AND
                        craptco.flgativo = TRUE
                        NO-LOCK NO-ERROR.

             IF  AVAIL craptco  THEN
             DO:
                 FIND craplot WHERE craplot.cdcooper = craptco.cdcooper     AND /* coop nova */
                                    craplot.dtmvtolt = crapdat.dtmvtocd     AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                    craplot.cdagenci = craptco.cdagenci     AND
                                    craplot.cdbccxlt = 11                   AND  /* Fixo */
                                    craplot.nrdolote = 205000 + craptco.cdagenci   
                                    NO-LOCK NO-ERROR.

                 IF  NOT AVAIL craplot  THEN
                 DO:
                     ASSIGN i-cod-erro  = 60
                              c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
             END.
         END.
         ELSE
         DO:
             .
             /* Revitalizacao - Remocao de lotes
             ASSIGN i-cod-erro  = 60
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
             */
         END.
     END.

     RETURN "OK".  
END PROCEDURE.

PROCEDURE estorna-pagto-cheque:
    
    DEF INPUT  PARAM p-cooper        AS CHAR   /* Cod. Cooperativa */ NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INT    /* Cod. Agencia     */ NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INT    /* Numero Caixa     */ NO-UNDO. 
    DEF INPUT  PARAM p-cod-operador  AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nrctabdb      AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque    AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3      AS INT FORMAT "9"       /* C3 */ NO-UNDO. 
    DEF INPUT  PARAM p-valor         AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-cdbanchq      AS INT FORMAT "zz9"  /* Banco */ NO-UNDO.
    DEF INPUT  PARAM p-cdagechq      AS INT FORMAT "zzz9" /* Agenc */ NO-UNDO.
    DEF OUTPUT PARAM p-histor        AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-docto         AS INT                           NO-UNDO.

    DEF VAR aux_cdbccxlt AS INTE NO-UNDO.
    DEF VAR flg_chqmigra AS LOG  NO-UNDO.

    DEF BUFFER crabbcx FOR crapbcx.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    ASSIGN p-nrctabdb = DEC(REPLACE(STRING(p-nrctabdb), '.','')).
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
 
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nrctabdb = 978809 THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    ASSIGN i_cheque  = INT(STRING(p-nro-cheque,"999999") +
                       STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
                       
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
  
    /*** Verifica se PAC faz previa dos cheques ***/ 
    ASSIGN flg_exetrunc = FALSE.
    FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper   AND
                        craptab.nmsistem = "CRED"             AND
                        craptab.tptabela = "GENERI"           AND
                        craptab.cdempres = 0                  AND
                        craptab.cdacesso = "EXETRUNCAGEM"     AND
                        craptab.tpregist = p-cod-agencia    
                        NO-LOCK NO-ERROR.        
        
    IF   craptab.dstextab = "SIM" THEN
         DO:
             ASSIGN  i-cod-erro   = 0
                     flg_exetrunc = TRUE.

             FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                                craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                craplcm.cdagenci = p-cod-agencia     AND
                                craplcm.cdbccxlt = 11                AND /* Fixo */
                                craplcm.nrdolote = i-nro-lote        AND
                                craplcm.nrdctabb = INT(p-nrctabdb)   AND
                                craplcm.nrdocmto = i_cheque   /* USE-INDEX craplcm1 */
                                NO-LOCK NO-ERROR.             

             IF  NOT AVAIL craplcm THEN
             DO:
                 /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                 /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                     p-cdbanchq = 756               THEN
                 DO:
                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:
                         /* O lancamento, neste ponto, obrigatoriamente deve existir */
                         FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                            craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                            craplcm.cdagenci = craptco.cdagenci          AND
                                            craplcm.cdbccxlt = 100                       AND /* Fixo */
                                            craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                            craplcm.nrdctabb = int(p-nrctabdb)           AND
                                            craplcm.nrdocmto = i_cheque          
                                            USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                         IF  NOT AVAIL craplcm  THEN
                         DO:
                             ASSIGN i-cod-erro  = 90
                                    c-desc-erro = " ".           
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                           INPUT YES).
                             RETURN "NOK".
                         END.

                     END.
                 END.
                 ELSE 
                 /* Se for BB usa a conta ITG para buscar conta migrada */
                 /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                 IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                 DO:
                     /* Formata conta integracao */
                     RUN fontes/digbbx.p (INPUT p-nrctabdb,
                                          OUTPUT glb_dsdctitg,
                                          OUTPUT glb_stsnrcal).
                     IF   NOT glb_stsnrcal   THEN
                          DO:
                              ASSIGN i-cod-erro  = 8
                                     c-desc-erro = " ".           
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                          END.

                     /* Localiza se o cheque é de uma conta migrada */
                     FIND FIRST craptco WHERE 
                                craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                craptco.tpctatrf = 1                AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.

                     IF  AVAIL craptco  THEN
                     DO:
                         /* O lancamento, neste ponto, obrigatoriamente deve existir */
                         FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                            craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                            craplcm.cdagenci = craptco.cdagenci          AND
                                            craplcm.cdbccxlt = 100                       AND /* Fixo */
                                            craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                            craplcm.nrdctabb = int(p-nrctabdb)           AND
                                            craplcm.nrdocmto = i_cheque          
                                            USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                         IF  NOT AVAIL craplcm  THEN
                         DO:
                             ASSIGN i-cod-erro  = 90
                                    c-desc-erro = " ".           
                             RUN cria-erro (INPUT p-cooper,
                                            INPUT p-cod-agencia,
                                            INPUT p-nro-caixa,
                                            INPUT i-cod-erro,
                                            INPUT c-desc-erro,
                                           INPUT YES).
                             RETURN "NOK".
                         END.

                     END.
                 END.
             END.
             
             FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper  AND
                                    crapchd.dtmvtolt = craplcm.dtmvtolt  AND
                                    crapchd.cdagenci = p-cod-agencia     AND
                                    crapchd.cdbccxlt = 11                AND
                                    crapchd.nrdolote = i-nro-lote        AND
                                    crapchd.nrseqdig = craplcm.nrseqdig
                                    USE-INDEX crapchd3 NO-LOCK:
                
                 IF  crapchd.insitprv > 0 THEN
                     ASSIGN i-cod-erro =  99999.
             END.

             IF   i-cod-erro > 0 THEN
                  DO:
                        ASSIGN i-cod-erro  = 0  
                               c-desc-erro = "Estorno nao pode ser efetuado. " +
                                             "Cheque ja enviado para previa.".
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                  END.
             
         END.
    
    /* Verifica horario de Corte */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "HRTRCOMPEL"      AND
                       craptab.tpregist = p-cod-agencia  
                       NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL craptab   THEN  
        DO:
            ASSIGN i-cod-erro  = 676
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".          
        END.   

    IF  flg_exetrunc = FALSE THEN
        IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
            DO:
                ASSIGN i-cod-erro  = 677
                       c-desc-erro = " ".           
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.    

    IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
        DO:
            ASSIGN i-cod-erro  = 676
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END. 

    ASSIGN in99 = 0.
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.
         FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                            craplot.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                            craplot.cdagenci = p-cod-agencia     AND
                            craplot.cdbccxlt = 11                AND /* Fixo */
                            craplot.nrdolote = i-nro-lote        AND
                            1 = 2 /* Revitalizacao - Remocao de lotes - Nao deve retornar o lote nessa busca */
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAIL craplot   THEN 
              DO:
                  IF   LOCKED craplot   THEN 
                       DO:
                           IF   in99 < 100   THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = 
                                                  "Tabela CRAPLOT em uso ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                       END.
                  ELSE 
                  DO:
                      /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                      /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                      IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                          p-cdbanchq = 756               THEN
                      DO:
                          /* Localiza se o cheque é de uma conta migrada */
                          FIND FIRST craptco WHERE 
                                     craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                     craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                                     craptco.tpctatrf = 1                AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                          IF  AVAIL craptco  THEN
                          DO:
                              FIND craplot WHERE craplot.cdcooper = craptco.cdcooper     AND   /* coop nova */
                                                 craplot.dtmvtolt = crapdat.dtmvtocd     AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                                 craplot.cdagenci = craptco.cdagenci     AND
                                                 craplot.cdbccxlt = 11                   AND  /* Fixo */
                                                 craplot.nrdolote = 205000 + craptco.cdagenci   
                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF  NOT AVAIL craplot  THEN
                              DO:
                                  IF   LOCKED craplot   THEN 
                                       DO:
                                           IF   in99 < 100   THEN 
                                                DO:
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                           ELSE 
                                                DO:
                                                    ASSIGN i-cod-erro  = 0
                                                           c-desc-erro = 
                                                                  "Tabela CRAPLOT em uso ".
                                                    RUN cria-erro (INPUT p-cooper,
                                                                   INPUT p-cod-agencia,
                                                                   INPUT p-nro-caixa,
                                                                   INPUT i-cod-erro,
                                                                   INPUT c-desc-erro,
                                                                   INPUT YES).
                                                    RETURN "NOK".
                                                END.
                                       END.
                                  ELSE
                                  DO:
                                      ASSIGN i-cod-erro  = 60
                                             c-desc-erro = " ".           
                                      RUN cria-erro (INPUT p-cooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT i-cod-erro,
                                                     INPUT c-desc-erro,
                                                     INPUT YES).
                                      RETURN "NOK".
                                  END.
                              END.
                          END.
                      END.
                      ELSE 
                      /* Se for BB usa a conta ITG para buscar conta migrada */
                      /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                      IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                      DO:
                          /* Formata conta integracao */
                          RUN fontes/digbbx.p (INPUT p-nrctabdb,
                                               OUTPUT glb_dsdctitg,
                                               OUTPUT glb_stsnrcal).
                          IF   NOT glb_stsnrcal   THEN
                               DO:
                                   ASSIGN i-cod-erro  = 8
                                          c-desc-erro = " ".           
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                   RETURN "NOK".
                               END.

                          /* Localiza se o cheque é de uma conta migrada */
                          FIND FIRST craptco WHERE 
                                     craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                     craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                     craptco.tpctatrf = 1                AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                          IF  AVAIL craptco  THEN
                          DO:
                              FIND craplot WHERE craplot.cdcooper = craptco.cdcooper     AND  /* coop nova */
                                                 craplot.dtmvtolt = crapdat.dtmvtocd     AND  /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                                 craplot.cdagenci = craptco.cdagenci     AND
                                                 craplot.cdbccxlt = 11                   AND  /* Fixo */
                                                 craplot.nrdolote = 205000 + craptco.cdagenci   
                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                              IF  NOT AVAIL craplot  THEN
                              DO:
                                  IF   LOCKED craplot   THEN 
                                       DO:
                                           IF   in99 < 100   THEN 
                                                DO:
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                           ELSE 
                                                DO:
                                                    ASSIGN i-cod-erro  = 0
                                                           c-desc-erro = 
                                                                  "Tabela CRAPLOT em uso ".
                                                    RUN cria-erro (INPUT p-cooper,
                                                                   INPUT p-cod-agencia,
                                                                   INPUT p-nro-caixa,
                                                                   INPUT i-cod-erro,
                                                                   INPUT c-desc-erro,
                                                                   INPUT YES).
                                                    RETURN "NOK".
                                                END.
                                       END.
                                  ELSE
                                  DO:
                                      ASSIGN i-cod-erro  = 60
                                             c-desc-erro = " ".           
                                      RUN cria-erro (INPUT p-cooper,
                                                     INPUT p-cod-agencia,
                                                     INPUT p-nro-caixa,
                                                     INPUT i-cod-erro,
                                                     INPUT c-desc-erro,
                                                     INPUT YES).
                                      RETURN "NOK".
                                  END.
                              END.
                          END.
                      END.
                      ELSE
                      DO:
                          /* Revitalizacao - Remocao de lotes
                          ASSIGN i-cod-erro  = 60
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                          */
                      END.
                  END.
              END.
         LEAVE.
    END.  /*  DO WHILE */
    
    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).

    ASSIGN aux_indevchq = 0.
    IF   i-cdhistor = 21   THEN 
         DO:
             ASSIGN i_nro-docto  = INT(STRING(p-nro-cheque,"999999") +
                                       STRING(p-nrddigc3,"9")). /* Nro do Chq */
       
             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,   /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,   /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,     /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas). /* Nro Folhas */
             ASSIGN in99 = 0.
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.

                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nrctabdb          AND
                                     crapfdc.nrcheque = INT(p-nro-cheque)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-ERROR.

                 IF   NOT AVAIL crapfdc   THEN 
                      DO: 
                          IF   LOCKED crapfdc   THEN 
                               DO:
                                   IF   in99 < 100   THEN 
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                   ELSE 
                                        DO:
                                            ASSIGN i-cod-erro  = 0
                                                   c-desc-erro = 
                                                      "Tabela CRAPFDC em uso ".
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT p-nro-caixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                            RETURN "NOK".
                                        END.
                               END.
                          ELSE 
                          DO:
                              /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                              /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                              IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                                  p-cdbanchq = 756               THEN
                              DO:
                                  /* Localiza se o cheque é de uma conta migrada */
                                  FIND FIRST craptco WHERE 
                                             craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                                             craptco.nrctaant = p-nrctabdb       AND /* conta antiga */
                                             craptco.tpctatrf = 1                AND
                                             craptco.flgativo = TRUE
                                             NO-LOCK NO-ERROR.

                                  IF  AVAIL craptco  THEN
                                  DO:
                                      /* verifica se o cheque pertence a conta migrada */
                                      FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                               crapfdc.cdbanchq = p-cdbanchq       AND
                                                               crapfdc.cdagechq = p-cdagechq       AND
                                                               crapfdc.nrctachq = p-nrctabdb       AND
                                                               crapfdc.nrcheque = INT(p-nro-cheque)
                                                               USE-INDEX crapfdc1
                                                                EXCLUSIVE-LOCK NO-ERROR.
                                      IF  NOT AVAIL crapfdc  THEN
                                      DO:
                                          IF   LOCKED crapfdc   THEN 
                                          DO:
                                              IF   in99 < 100   THEN 
                                              DO:
                                                  PAUSE 1 NO-MESSAGE.
                                                  NEXT.
                                              END.
                                              ELSE 
                                              DO:
                                                  ASSIGN i-cod-erro  = 0
                                                         c-desc-erro = 
                                                            "Tabela CRAPFDC em uso ".
                                                  RUN cria-erro (INPUT p-cooper,
                                                                 INPUT p-cod-agencia,
                                                                 INPUT p-nro-caixa,
                                                                 INPUT i-cod-erro,
                                                                 INPUT c-desc-erro,
                                                                 INPUT YES).
                                                  RETURN "NOK".
                                              END.
                                          END.
                                          ELSE 
                                          DO:
                                              ASSIGN i-cod-erro  = 180
                                                     c-desc-erro = "".
                                              RUN cria-erro (INPUT p-cooper,
                                                             INPUT p-cod-agencia,
                                                             INPUT p-nro-caixa,
                                                             INPUT i-cod-erro,
                                                             INPUT c-desc-erro,
                                                             INPUT YES).
                                              RETURN "NOK".
                                          END.
                                      END.

                                  END.
                              END.
                              ELSE 
                              /* Se for BB usa a conta ITG para buscar conta migrada */
                              /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                              IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                              DO:
                                  /* Formata conta integracao */
                                  RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                                       OUTPUT glb_dsdctitg,
                                                       OUTPUT glb_stsnrcal).
                                  IF   NOT glb_stsnrcal   THEN
                                       DO:
                                           ASSIGN i-cod-erro  = 8
                                                  c-desc-erro = " ".           
                                           RUN cria-erro (INPUT p-cooper,
                                                          INPUT p-cod-agencia,
                                                          INPUT p-nro-caixa,
                                                          INPUT i-cod-erro,
                                                          INPUT c-desc-erro,
                                                          INPUT YES).
                                           RETURN "NOK".
                                       END.

                                  /* Localiza se o cheque é de uma conta migrada */
                                  FIND FIRST craptco WHERE 
                                             craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                                             craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                             craptco.tpctatrf = 1                AND
                                             craptco.flgativo = TRUE
                                             NO-LOCK NO-ERROR.

                                  IF  AVAIL craptco  THEN
                                  DO:
                                      /* verifica se o cheque pertence a conta migrada */
                                      FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                                               crapfdc.cdbanchq = p-cdbanchq       AND
                                                               crapfdc.cdagechq = p-cdagechq       AND
                                                               crapfdc.nrctachq = p-nrctabdb       AND
                                                               crapfdc.nrcheque = INT(p-nro-cheque)
                                                               USE-INDEX crapfdc1
                                                                EXCLUSIVE-LOCK NO-ERROR.

                                      IF  NOT AVAIL crapfdc  THEN
                                      DO:
                                          IF   LOCKED crapfdc   THEN 
                                          DO:
                                              IF   in99 < 100   THEN 
                                              DO:
                                                  PAUSE 1 NO-MESSAGE.
                                                  NEXT.
                                              END.
                                              ELSE 
                                              DO:
                                                  ASSIGN i-cod-erro  = 0
                                                         c-desc-erro = 
                                                            "Tabela CRAPFDC em uso ".
                                                  RUN cria-erro (INPUT p-cooper,
                                                                 INPUT p-cod-agencia,
                                                                 INPUT p-nro-caixa,
                                                                 INPUT i-cod-erro,
                                                                 INPUT c-desc-erro,
                                                                 INPUT YES).
                                                  RETURN "NOK".
                                              END.
                                          END.
                                          ELSE 
                                          DO:
                                              ASSIGN i-cod-erro  = 180
                                                     c-desc-erro = "".
                                              RUN cria-erro (INPUT p-cooper,
                                                             INPUT p-cod-agencia,
                                                             INPUT p-nro-caixa,
                                                             INPUT i-cod-erro,
                                                             INPUT c-desc-erro,
                                                             INPUT YES).
                                              RETURN "NOK".
                                          END.
                                      END.
                                  END.
                              END.
                          END.
                      END.
                 IF   crapfdc.incheque = 1 THEN
                      ASSIGN aux_indevchq = 5.
                 LEAVE.
             END.  /*  DO WHILE */
         END.  /* Historico 21 */
    ELSE 
         DO:
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  
                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nrctabdb          AND
                                     crapfdc.nrcheque = INT(p-nro-cheque)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-ERROR.

                  IF   NOT AVAIL crapfdc   THEN 
                       DO: 
                           IF   LOCKED crapfdc   THEN 
                                DO:
                                    IF   in99 < 100   THEN 
                                         DO:
                                             PAUSE 1 NO-MESSAGE.
                                             NEXT.
                                         END.
                                    ELSE 
                                         DO:
                                             ASSIGN i-cod-erro  = 0
                                                    c-desc-erro = 
                                                      "Tabela CRAPFDC em uso ".
                                             RUN cria-erro (INPUT p-cooper,
                                                            INPUT p-cod-agencia,
                                                            INPUT p-nro-caixa,
                                                            INPUT i-cod-erro,
                                                            INPUT c-desc-erro,
                                                            INPUT YES).
                                              RETURN "NOK".
                                          END.
                                END.
                           ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 286
                                           c-desc-erro = " ".           
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                       END.
                  LEAVE.
             END.  /*  DO WHILE */
         END.  /* Historico 26 */                            
 
    IF   i-cdhistor = 26   THEN 
         DO:
             IF   crapfdc.incheque = 5   THEN
                  ASSIGN crapfdc.incheque = 0.
             ELSE
                  IF   crapfdc.incheque = 6   THEN
                       ASSIGN crapfdc.incheque = 1.
                  ELSE
                       ASSIGN crapfdc.incheque = 2.
         END.

    IF   i-cdhistor = 21   THEN 
         ASSIGN crapfdc.incheque = crapfdc.incheque - 5.
         
    ASSIGN crapfdc.dtliqchq = ?
           crapfdc.cdoperad = ""
           crapfdc.vlcheque = 0.
           
    ASSIGN in99 = 0.
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.
         FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                            craplcm.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                            craplcm.cdagenci = p-cod-agencia     AND
                            craplcm.cdbccxlt = 11                AND /* Fixo */
                            craplcm.nrdolote = i-nro-lote        AND
                            craplcm.nrdctabb = p-nrctabdb        AND
                            craplcm.nrdocmto = i_cheque   USE-INDEX craplcm1
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAIL craplcm   THEN 
             DO:
                 IF   LOCKED craplcm   THEN 
                      DO:
                          IF   in99 < 100   THEN 
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                          ELSE 
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                          c-desc-erro = 
                                                   "Tabela CRAPLCM em uso ".                                       
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT i-cod-erro,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                                   RETURN "NOK".
                               END.
                      END.
                 ELSE
                 DO:
                     /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
                     /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
                     IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                         p-cdbanchq = 756               THEN
                     DO:
                         /* Localiza se o cheque é de uma conta migrada */
                         FIND FIRST craptco WHERE 
                                    craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                    craptco.nrctaant = p-nrctabdb       AND /* conta antiga */
                                    craptco.tpctatrf = 1                AND
                                    craptco.flgativo = TRUE
                                    NO-LOCK NO-ERROR.

                         IF  AVAIL craptco  THEN
                         DO:
                             FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                                craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                                craplcm.cdagenci = craptco.cdagenci          AND
                                                craplcm.cdbccxlt = 100                       AND /* Fixo */
                                                craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                                craplcm.nrdctabb = int(p-nrctabdb)           AND
                                                craplcm.nrdocmto = i_cheque          
                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                             IF   NOT AVAIL craplcm   THEN 
                                  DO:
                                      IF   LOCKED craplcm   THEN 
                                           DO:
                                               IF   in99 < 100   THEN 
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT.
                                                    END.
                                               ELSE 
                                                    DO:
                                                        ASSIGN i-cod-erro  = 0
                                                               c-desc-erro = 
                                                                        "Tabela CRAPLCM em uso ".                                       
                                                        RUN cria-erro (INPUT p-cooper,
                                                                       INPUT p-cod-agencia,
                                                                       INPUT p-nro-caixa,
                                                                       INPUT i-cod-erro,
                                                                       INPUT c-desc-erro,
                                                                       INPUT YES).
                                                        RETURN "NOK".
                                                    END.
                                           END.
                                  END.
                             ELSE
                             DO:
                                 ASSIGN aux_nrdconta = craptco.nrctaant.
                                        flg_chqmigra = TRUE.
                             END.

                         END.
                     END.
                     ELSE 
                     /* Se for BB usa a conta ITG para buscar conta migrada */
                     /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                     IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
                     DO:
                         /* Formata conta integracao */
                         RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                              OUTPUT glb_dsdctitg,
                                              OUTPUT glb_stsnrcal).
                         IF   NOT glb_stsnrcal   THEN
                              DO:
                                  ASSIGN i-cod-erro  = 8
                                         c-desc-erro = " ".           
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).
                                  RETURN "NOK".
                              END.

                         /* Localiza se o cheque é de uma conta migrada */
                         FIND FIRST craptco WHERE 
                                    craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                                    craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                                    craptco.tpctatrf = 1                AND
                                    craptco.flgativo = TRUE
                                    NO-LOCK NO-ERROR.

                         IF  AVAIL craptco  THEN
                         DO:
                             FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                                craplcm.dtmvtolt = crapdat.dtmvtocd          AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                                craplcm.cdagenci = craptco.cdagenci          AND
                                                craplcm.cdbccxlt = 100                       AND /* Fixo */
                                                craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                                craplcm.nrdctabb = int(p-nrctabdb)           AND
                                                craplcm.nrdocmto = i_cheque          
                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                             IF   NOT AVAIL craplcm   THEN 
                                  DO:
                                      IF   LOCKED craplcm   THEN 
                                           DO:
                                               IF   in99 < 100   THEN 
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT.
                                                    END.
                                               ELSE 
                                                    DO:
                                                        ASSIGN i-cod-erro  = 0
                                                               c-desc-erro = 
                                                                        "Tabela CRAPLCM em uso ".                                       
                                                        RUN cria-erro (INPUT p-cooper,
                                                                       INPUT p-cod-agencia,
                                                                       INPUT p-nro-caixa,
                                                                       INPUT i-cod-erro,
                                                                       INPUT c-desc-erro,
                                                                       INPUT YES).
                                                        RETURN "NOK".
                                                    END.
                                           END.
                                  END.
                             ELSE
                             DO:
                                 ASSIGN aux_nrdconta = craptco.nrctaant.
                                        flg_chqmigra = TRUE.
                             END.

                         END.
                     END.
                 END.
             END.
        ELSE
            ASSIGN aux_nrdconta = craplcm.nrdconta.

        LEAVE.
    END.  /*  DO WHILE */

    IF   aux_indevchq > 0   THEN
         DO:
             IF  aux_nrdconta = p-nrctabdb  THEN 
                 DO: 
                     IF   p-cdbanchq   = crapcop.cdbcoctl  THEN
                          aux_cdbccxlt = crapcop.cdbcoctl.
                     ELSE
                          aux_cdbccxlt = 756.
                 END.
             ELSE 
                 aux_cdbccxlt = 1.
             RUN dbo/pcrap10.p (INPUT p-cooper,
                                INPUT crapdat.dtmvtocd,  /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                INPUT aux_cdbccxlt,
                                INPUT aux_indevchq,
                                INPUT aux_nrdconta,
                                INPUT i_cheque,
                                INPUT p-nrctabdb,
                                INPUT p-valor,
                                INPUT 0, /*codigo alinea */
                                INPUT IF (aux_indevchq = 5 OR
                                          aux_indevchq = 6)
                                      THEN 47
                                      ELSE 78,
                                INPUT p-cod-operador,
                                INPUT p-cdbanchq,
                                INPUT p-cdagechq,
                                OUTPUT i-codigo-erro).

             IF   i-codigo-erro > 0   THEN 
                  DO:
                      ASSIGN i-cod-erro  = i-codigo-erro
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.
    
    FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper  AND
                           crapchd.dtmvtolt = craplcm.dtmvtolt  AND
                           crapchd.cdagenci = p-cod-agencia     AND
                           crapchd.cdbccxlt = 11                AND
                           crapchd.nrdolote = i-nro-lote        AND
                           crapchd.nrseqdig = craplcm.nrseqdig
                           USE-INDEX crapchd3 EXCLUSIVE-LOCK:
        DELETE crapchd.
        /******************** Comentado em 19/01/2011 ******************
        /*** Decrementa quantidade de cheques no total para a previa ***/
        RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        RUN atualiza-previa-caixa  IN h_b1crap00  
                                      (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT p-cod-operador,
                                       INPUT crapdat.dtmvtolt,
                                       INPUT 2).  /*Estorno*/
        DELETE PROCEDURE h_b1crap00.
        **********************************/

    END.
    
    IF  flg_chqmigra  THEN
    DO:
        FIND LAST crabbcx WHERE crabbcx.cdcooper = crapcop.cdcooper  AND
                                crabbcx.dtmvtolt = crapdat.dtmvtocd  AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                crabbcx.cdagenci = p-cod-agencia     AND
                                crabbcx.nrdcaixa = p-nro-caixa       AND
                                crabbcx.cdopecxa = p-cod-operador    AND
                                crabbcx.cdsitbcx = 1
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crabbcx   THEN
             DO:
                 ASSIGN i-cod-erro  = 698
                        c-desc-erro = "".

                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        
        FIND craplcx WHERE craplcx.cdcooper = crapcop.cdcooper AND
                           craplcx.dtmvtolt = crapdat.dtmvtocd AND /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                           craplcx.cdagenci = p-cod-agencia    AND
                           craplcx.nrdcaixa = p-nro-caixa      AND
                           craplcx.cdopecxa = p-cod-operador   AND
                           craplcx.nrdocmto = i_cheque         AND
                           craplcx.cdhistor = 704              AND
                           craplcx.vldocmto = p-valor
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE craplcx   THEN
             DO:
                 ASSIGN i-cod-erro  = 90
                        c-desc-erro = "".

                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        DELETE craplcx.

        ASSIGN crabbcx.qtcompln = crabbcx.qtcompln - 1.
        
    END.

    /*** Controle de movimentacao em especie ***/
    FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper  AND
                       crapcme.dtmvtolt = craplcm.dtmvtolt  AND
                       crapcme.cdagenci = craplcm.cdagenci  AND
                       crapcme.cdbccxlt = craplcm.cdbccxlt  AND
                       crapcme.nrdolote = craplcm.nrdolote  AND
                       crapcme.nrdctabb = craplcm.nrdctabb  AND
                       crapcme.nrdocmto = craplcm.nrdocmto  
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapcme   THEN 
         DO:
             RUN sistema/generico/procedures/b1wgen9998.p
                          PERSISTENT SET h-b1wgen9998.

             RUN email-controle-movimentacao IN h-b1wgen9998
                                (INPUT crapcop.cdcooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa, 
                                 INPUT p-cod-operador,
                                 INPUT "b1crap73",
                                 INPUT 2, /* Caixa online */
                                 INPUT crapcme.nrdconta,
                                 INPUT 1, /* Tit*/
                                 INPUT 3, /* Exclusao */
                                 INPUT ROWID(crapcme),
                                 INPUT TRUE, /* Enviar */
                                 INPUT crapdat.dtmvtocd, /* 18/06/2018 - Alterado para o campo dtmvtocd - Everton Deserto(AMCOM).*/
                                 INPUT TRUE,
                                OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen9998.

             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.   
                    
                      IF   AVAIL tt-erro   THEN                            
                           IF   tt-erro.cdcritic <> 0   THEN 
                                ASSIGN i-cod-erro  = tt-erro.cdcritic.           
                           ELSE 
                                ASSIGN c-desc-erro = tt-erro.dscritic.          
                      ELSE                                                 
                           ASSIGN c-desc-erro = "Erro no envio do email.".
                    
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".                   
                  END.

             DELETE crapcme.

         END.
    
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
       RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                  
    RUN estorna_lancamento_conta IN h-b1wgen0200 
      (INPUT craplcm.cdcooper               /* par_cdcooper */
      ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
      ,INPUT craplcm.cdagenci               /* par_cdagenci*/
      ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
      ,INPUT craplcm.nrdolote               /* par_nrdolote */
      ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
      ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
      ,INPUT craplcm.cdhistor               /* par_cdhistor */
      ,INPUT craplcm.nrctachq               /* PAR_nrctachq */
      ,INPUT craplcm.nrdconta               /* PAR_nrdconta */
      ,INPUT craplcm.cdpesqbb               /* PAR_cdpesqbb */
      ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
      ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                
    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
       DO: 
           /* Tratamento de erros conforme anteriores */
           ASSIGN i-cod-erro  = aux_cdcritic
                  c-desc-erro = aux_dscritic.
                      
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.   
                
    IF  VALID-HANDLE(h-b1wgen0200) THEN
      DELETE PROCEDURE h-b1wgen0200.
  
  IF AVAIL craplot THEN
  DO:
    ASSIGN craplot.qtcompln  = craplot.qtcompln  - 1
           craplot.qtinfoln  = craplot.qtinfoln  - 1
           craplot.vlcompdb  = craplot.vlcompdb  - p-valor
           craplot.vlinfodb  = craplot.vlinfodb  - p-valor.
        
     IF   craplot.vlcompdb = 0 AND
          craplot.vlinfodb = 0 AND
          craplot.vlcompcr = 0 AND
          craplot.vlinfocr = 0 THEN
          DELETE craplot.
     ELSE
          RELEASE craplot.
   END.

    RELEASE crapfdc.    

    ASSIGN p-histor = i-cdhistor
           p-docto  = i_cheque.
  
    RETURN "OK".
END PROCEDURE.

/* b1crap73.p */

/* .......................................................................... */

