/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap53.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 10/08/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Pagto de Cheque 

   Alteracoes: 26/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               08/11/2005 - Alteracao da crapchq e crapchs p/ crapfdc
                            (SQlWorks - Eder)
                            
               17/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
                            
               24/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               20/12/2006 - Retirado tratamento Banco/Agencia 104/411 (Diego).
               
               23/02/2007 - Alterados os FINDs da crapfdc, crapcor e crapdev
                            (Evandro).
               
               23/03/2007 - Leitura do crapfdc nao estava ok (Magui).

               10/09/2007 - Conversao de rotina fer_capital para BO 
                            (Sidnei/Precise)
                            
               23/12/2008 - Incluido campo "capital" na temp-table tt-conta
                            (Elton).

               10/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
               
               04/10/2009 - Incluido critica para lancamentos de Cheques TB e
                            Cheques Salario (Elton).  
                            
               28/01/2010 - Adaptações projeto IF CECRED (Guilherme).

               05/11/2010 - Cria registro na tabela crapchd, chama BO
                            atualiza-previa-caixa e verifica horario de 
                            digitacao (HRTRCOMPEL) (Elton).
                            
               24/12/2010 - Tratamento para cheques de contas migradas 
                            (Guilherme).
                          - Na criacao do crapchd, gravado campo nrcheque sem 
                            digito verificador;
                          - Comentado as chamadas da procedure 
                            atualiza-previa-caixa (Elton).
                            
               15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir 
                            LENGTH 34 (Guilherme).
                            
               09/12/2011 - Sustação provisória (André R./Supero).
               
               21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)    
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                        
               23/08/2012 - Procedures valida-pagto-cheque, 
                            valida-pagto-cheque-migrado e 
                            valida-pagto-cheque-migrado-host tratamento cheques
                            custodia - Projeto Tic (Richard/Supero). 
                            
               26/10/2012 - Alteracao da logica para migracao de PAC
                            devido a migracao da AltoVale (Guilherme).
                            
               02/01/2013 - Tratamento Alto Vale (Ze).             
               
               07/01/2013 - Permite pagar cheque de contas migradas tanto 
                            para pagamentos da Viacredi quanto da Alto Vale 
                            (Elton).
                            
               19/09/2013 - Remover tratamento fixo da AltoVale e deixar 
                            de forma generica para receber outras migracoes
                            (Guilherme).
                            
               03/01/2014 - Incluido validate para as tabelas crapdev,
                            craplcx, crapchd (Tiago).
                            
               19/02/2014 - Ajuste leitura craptco (Daniel).  
               
               11/06/2014 - Somente emitir a crítica 950 apenas se a 
                            crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)
                             
               18/05/2018 - Alteraçoes para usar as rotinas mesmo com o processo 
                      norturno rodando (Douglas Pagel - AMcom).
                             
               03/07/2018 - PJ450 Regulatório de Credito - Substituido o create na craplcm pela chamada
                            da rotina gerar_lancamento_conta_comple. (Josiane Stiehler - AMcom)

               10/08/2018 - Adicionado funcao para verificar necessidade de  senha. 
                            PRJ 420 (Mateus Z - Mouts)      
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
                             
............................................................................ */
/*----------------------------------------------------------------------*/
/*  b1crap53.p   - Pagto de Cheque                                      */
/*  Historicos   - 21 ou 26(conta - 978809)                             */
/*  Autenticacao - PG                                                   */
/*----------------------------------------------------------------------*/
{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i } 

DEF  VAR glb_nrcalcul   AS DECIMAL                                  NO-UNDO.
DEF  VAR glb_dsdctitg   AS CHAR                                     NO-UNDO.
DEF  VAR glb_stsnrcal   AS LOGICAL                                  NO-UNDO.

/* Variavel utilizada no include includes/proc_conta_integracao.i */
DEF  VAR glb_cdcooper   AS INT                                      NO-UNDO.

DEF TEMP-TABLE tt-conta                                             NO-UNDO
    FIELD situacao           AS CHAR FORMAT "x(21)"
    FIELD tipo-conta         AS CHAR FORMAT "x(21)"
    FIELD empresa            AS CHAR FORMAT "x(15)"
    FIELD devolucoes         AS INTE FORMAT "99"
    FIELD agencia            AS CHAR FORMAT "x(15)"
    FIELD magnetico          AS INTE FORMAT "z9"     
    FIELD estouros           AS INTE FORMAT "zzz9"
    FIELD folhas             AS INTE FORMAT "zzz,zz9"
    FIELD identidade         AS CHAR 
    FIELD orgao              AS CHAR 
    FIELD cpfcgc             AS CHAR 
    FIELD disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD limite-credito     AS DEC 
    FIELD ult-atualizacao    AS DATE
    FIELD saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR                          
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-". 
   
DEF VAR de-valor-libera         AS DEC                              NO-UNDO.
DEF VAR de-valor                AS DEC                              NO-UNDO.

DEF VAR i-cod-erro              AS INT                              NO-UNDO.
DEF VAR c-desc-erro             AS CHAR                             NO-UNDO.
                                             
DEF VAR h_b2crap00              AS HANDLE                           NO-UNDO.
DEF VAR h-b1crap02              AS HANDLE                           NO-UNDO.
DEF VAR h-b1crap00              AS HANDLE                           NO-UNDO.

DEF VAR p-nro-calculado         AS DEC                              NO-UNDO.
DEF VAR p-lista-digito          AS CHAR                             NO-UNDO.
DEF VAR de-nrctachq             AS DEC  FORMAT "zzz,zzz,zzz,9"      NO-UNDO.
DEF VAR c-cmc-7                 AS CHAR                             NO-UNDO.
DEF VAR i-nro-lote              AS INTE                             NO-UNDO.
DEF VAR i-cdhistor              AS INTE                             NO-UNDO.
DEF VAR aux_lsconta1            AS CHAR                             NO-UNDO.
DEF VAR aux_lsconta2            AS CHAR                             NO-UNDO.
DEF VAR aux_lsconta3            AS CHAR                             NO-UNDO.
DEF VAR aux_lscontas            AS CHAR                             NO-UNDO.
DEF VAR i_conta                 AS DEC                              NO-UNDO.
DEF VAR aux_nrtrfcta            LIKE craptrf.nrsconta               NO-UNDO.
DEF VAR aux_nrdconta            AS INTE                             NO-UNDO.
DEF VAR i_nro-folhas            AS INTE                             NO-UNDO.
DEF VAR i_posicao               AS INTE                             NO-UNDO.
DEF VAR i_nro-talao             AS INTE                             NO-UNDO.
DEF VAR i_nro-docto             AS INTE                             NO-UNDO.
DEF VAR aux_vlsdchsl            LIKE crapsld.vlsdchsl               NO-UNDO.
DEF VAR i_cheque                AS DEC  FORMAT "ZZZ,ZZZ,9"          NO-UNDO.

DEF VAR de-valor-bloqueado      AS DEC                              NO-UNDO.
DEF VAR de-valor-liberado       AS DEC                              NO-UNDO.

DEF VAR aux_tpdmovto            AS INT                              NO-UNDO.

DEF BUFFER b-craphis FOR craphis.

DEF VAR p-valor-disponivel      AS DEC                              NO-UNDO.
DEF VAR p-literal               AS CHAR                             NO-UNDO.
DEF VAR p-ult-sequencia         AS INT                              NO-UNDO.
DEF var p-registro              AS RECID                            NO-UNDO.

DEF VAR p-nome-titular          AS CHAR                             NO-UNDO.
DEF VAR p-poupanca              AS LOG                              NO-UNDO.

DEF VAR i-codigo-erro           AS INT                              NO-UNDO.
DEF VAR aux_nrctcomp            AS INT                              NO-UNDO.
DEF VAR aux_nrctachq            AS INT                              NO-UNDO.
DEF VAR aux_nrtalchq            AS INT                              NO-UNDO.
DEF VAR aux_nrdocchq            AS INT                              NO-UNDO.
DEF VAR aux_nrdocmto            AS DEC                              NO-UNDO.
                            
DEF VAR i-p-nro-cheque          AS INT  FORMAT "zzz,zz9"            
                                        /* Cheque */                NO-UNDO.
DEF var i-p-nrddigc3            AS INT  FORMAT "9"    /* C3 */      NO-UNDO.
DEF VAR i-p-cdbanchq            AS INT  FORMAT "zz9"  /* Banco */   NO-UNDO.
DEF var i-p-cdagechq            AS INT  FORMAT "zzz9" /* Agencia */ NO-UNDO. 
DEF VAR i-nrcheque              AS INT                /* Cheque */  NO-UNDO.
DEF VAR i-p-valor               AS DEC                              NO-UNDO.
DEF VAR i-p-transferencia-conta AS CHAR                             NO-UNDO.
DEF VAR i-p-aviso-cheque        AS CHAR                             NO-UNDO.
DEF VAR i-p-nrctabdb            AS DEC  FORMAT "zzz,zzz,zzz,9" 
                                        /* Conta */                 NO-UNDO.

DEF VAR aux_cdagebcb            AS INT                              NO-UNDO.
DEF VAR TAB_vlchqmai            AS DEC                              NO-UNDO.
DEF VAR in99                    AS INT                              NO-UNDO.

DEF VAR i-cdbanchq              AS INT                              NO-UNDO.
DEF VAR i-cdagechq              AS INT                              NO-UNDO.
DEF VAR de-nrctabdb             AS DEC                              NO-UNDO.

DEF VAR aux_ctpsqitg            AS DEC                              NO-UNDO.
DEF VAR aux_nrdctitg            LIKE crapass.nrdctitg               NO-UNDO.
DEF VAR aux_nrctaass            LIKE crapass.nrdconta               NO-UNDO.
DEF VAR aux_nritgchq            LIKE crapfdc.nrdctitg               NO-UNDO.
DEF VAR aux_tpcheque            AS INTE                             NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200            AS HANDLE                           NO-UNDO.
DEF VAR aux_incrineg            AS INT                              NO-UNDO.
DEF VAR aux_cdcritic            AS INTE                             NO-UNDO.
DEF VAR aux_dscritic            AS CHAR                             NO-UNDO.


{dbo/bo-vercheque.i}
{dbo/bo-vercheque-migrado.i}

/**   Conta Integracao **/
DEF VAR aux_nrdigitg            AS CHAR                             NO-UNDO.
DEF BUFFER crabass5 FOR crapass.                             
{includes/proc_conta_integracao.i}

PROCEDURE critica-codigo-cheque-valor:
    
    DEF INPUT PARAM p-cooper      AS CHAR                              NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT          /* Cod. Agencia   */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa   AS INT  FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-cmc-7       AS CHAR                              NO-UNDO.
    DEF INPUT PARAM p-valor       AS DEC                               NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                          "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
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

    IF   p-cmc-7  <> " "   THEN 
         DO:
             IF  LENGTH(p-cmc-7) = 34  THEN
                 ASSIGN SUBSTR(p-cmc-7,34,1) = ":".

             IF   LENGTH(p-cmc-7)      <> 34  OR
                  SUBSTR(p-cmc-7,1,1)  <> "<" OR
                  SUBSTR(p-cmc-7,10,1) <> "<" OR
                  SUBSTR(p-cmc-7,21,1) <> ">" OR
                  SUBSTR(p-cmc-7,34,1) <> ":"  THEN 
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
         
             ASSIGN i-cdagechq = INT(SUBSTR(p-cmc-7,05,04)) NO-ERROR.
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
                                                 
             ASSIGN de-nrctabdb = IF i-cdbanchq = 1 
                                  THEN DECIMAL(SUBSTR(p-cmc-7,25,08))
                                  ELSE DECIMAL(SUBSTR(p-cmc-7,23,10)) NO-ERROR.

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
                             
              /* Le tabela com as contas convenio do Banco do Brasil - Geral  */
RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                       INPUT 0,
                       OUTPUT aux_lscontas).
    
             ASSIGN aux_nrdctitg = "".
                    
             /** Conta Integracao **/
             IF   LENGTH(STRING(de-nrctabdb)) <= 8   THEN
                  DO:
                      ASSIGN aux_ctpsqitg = de-nrctabdb
                             glb_cdcooper = crapcop.cdcooper.
                      RUN existe_conta_integracao.  
                  END.                    
         
             FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                                crapfdc.cdbanchq = i-cdbanchq         AND
                                crapfdc.cdagechq = i-cdagechq         AND
                                crapfdc.nrctachq = de-nrctabdb        AND
                                crapfdc.nrcheque = i-nrcheque
                                NO-LOCK NO-ERROR.
             /*******************
             IF   ((i-cdbanchq = 1 AND CAN-DO("95,3420",STRING(i-cdagechq))) AND
                    CAN-DO(aux_lscontas,STRING(INT(SUBSTR(p-cmc-7,25,08))))) OR
                    (i-cdbanchq = 756 AND i-cdagechq = crapcop.cdagebcb) OR
                    /** Conta Integracao **/
                    (aux_nrdctitg <> "" AND CAN-DO("3420",STRING(i-cdagechq)))
                    THEN 
                    DO:
                    END.
             ELSE 
             *********************/
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
             IF   p-nro-calculado > 0 OR NUM-ENTRIES(p-lista-digito) <> 3   THEN
                  DO:
                      ASSIGN i-cod-erro  = 666
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

PROCEDURE critica-valor:
    
    DEF INPUT PARAM p-cooper       AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cod-agencia  AS INT        /* Cod. Agencia    */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa    AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-valor        AS DEC                              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                    "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
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
    
    DEF INPUT PARAM p-cooper        AS CHAR                           NO-UNDO.
    DEF INPUT PARAM p-cod-agencia   AS INT        /* Cod. Agencia  */ NO-UNDO. 
    DEF INPUT PARAM p-nro-caixa     AS INT FORMAT "999" /*Nro Caixa*/ NO-UNDO. 
    DEF INPUT PARAM p-cmc-7-dig     AS CHAR                           NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                        "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    ASSIGN i-cdbanchq = INT(SUBSTRING(p-cmc-7-dig,02,03)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 841
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
             ASSIGN i-cod-erro  = 841
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    ASSIGN de-nrctabdb = IF i-cdbanchq = 1 
                         THEN DECIMAL(SUBSTRING(p-cmc-7-dig,25,08))
                         ELSE DECIMAL(SUBSTRING(p-cmc-7-dig,23,10)) NO-ERROR.

    IF   ERROR-STATUS:ERROR   THEN
         DO:
             ASSIGN i-cod-erro  = 841
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
             ASSIGN i-cod-erro  = 841
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 0,
                           OUTPUT aux_lscontas).

         
    ASSIGN aux_nrdctitg = "".
           
    /**  Conta Integracao **/
    IF   LENGTH(STRING(de-nrctabdb)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = de-nrctabdb
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.

    /***
    IF   ((i-cdbanchq = 1 AND CAN-DO("95,3420",STRING(i-cdagechq))) AND 
          CAN-DO(aux_lscontas,STRING(INT(SUBSTR(p-cmc-7-dig,25,08))))) OR
         (i-cdbanchq = 756 AND i-cdagechq = crapcop.cdagebcb)
         /**   Conta Integracao **/
         OR (aux_nrdctitg <> "" AND CAN-DO("3420", STRING(i-cdagechq)))   THEN
         DO:
         END.
    ELSE 
    ************/ 
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
                           ASSIGN i-cod-erro = 841. /*p-nro-calculado. */
 
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

    DEF INPUT PARAM  p-cooper      AS CHAR                             NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia AS INT          /* Cod. Agencia  */ NO-UNDO.
    DEF INPUT PARAM  p-nro-caixa   AS INT  FORMAT "999" /* Nr Caixa */ NO-UNDO.
    DEF INPUT PARAM  p-cmc-7       AS CHAR                             NO-UNDO.
    DEF INPUT PARAM  p-cmc-7-dig   AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM p-cdcmpchq    AS INT  FORMAT "zz9"     /* Comp */ NO-UNDO.
    DEF OUTPUT PARAM p-cdbanchq    AS INT  FORMAT "zz9"    /* Banco */ NO-UNDO.
    DEF OUTPUT PARAM p-cdagechq    AS INT  FORMAT "zzz9" /* Agencia */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc1    AS INT  FORMAT "9"         /* C1 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9"      NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc2    AS INT  FORMAT "9"         /* C2 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrcheque    AS INT  FORMAT "zzz,zz9"  /* Chq */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc3    AS INT  FORMAT "9"         /* C3 */ NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                       "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    IF  p-cmc-7 <> " " THEN
        ASSIGN c-cmc-7              = p-cmc-7
               SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
        ASSIGN c-cmc-7 = p-cmc-7-dig.  /* <99999999<9999999999>999999999999: */

    ASSIGN p-cdbanchq = INT(SUBSTR(c-cmc-7,02,03)) NO-ERROR.
    
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
   
    ASSIGN p-nrddigc1 = INT(SUBSTR(STRING(p-nro-calculado),LENGTH(
                                          STRING(p-nro-calculado)))).
                   
    /*  Calcula segundo digito de controle  */
    ASSIGN p-nro-calculado =  de-nrctachq * 10.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.

    ASSIGN p-nrddigc2 = 
           INT(SUBSTR(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).
   
    /*  Calcula terceiro digito de controle  */
    ASSIGN p-nro-calculado = p-nrcheque * 10.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.

    ASSIGN p-nrddigc3 =
           INT(SUBSTR(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).
   
    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-pagto-cheque:

    DEF INPUT  PARAM p-cooper              AS CHAR /* Cod. Cooper. */  NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia         AS INT  /* Cod. Agencia */  NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa           AS INT  FORMAT "999" 
                                                   /*Nro Caixa*/       NO-UNDO.
    DEF INPUT  PARAM p-cmc-7               AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM p-cmc-7-dig           AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM p-cdcmpchq            AS INT  FORMAT "zz9" 
                                                   /* Comp */          NO-UNDO.
    DEF INPUT  PARAM p-cdbanchq            AS INT  FORMAT "zz9" 
                                                   /* Banco */         NO-UNDO.
    DEF INPUT  PARAM p-cdagechq            AS INT  FORMAT "zzz9" 
                                                   /* Agcia */         NO-UNDO.
    DEF INPUT  PARAM p-nrddigc1            AS INT  FORMAT "9"
                                                   /* C1 */            NO-UNDO.
    DEF INPUT  PARAM p-nro-conta           AS DEC  FORMAT "zzz,zzz,zzz,9"
                                                                       NO-UNDO.
    DEF INPUT  PARAM p-nrddigc2            AS INT  FORMAT "9" /* C2 */ NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque          AS INT  FORMAT "zzz,zz9" 
                                                   /* Chq */           NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3            AS INT  FORMAT "9" /* C3 */ NO-UNDO.
    DEF INPUT  PARAM p-valor               AS DEC                      NO-UNDO.
    DEF INPUT  PARAM p_tppagmto            AS INT                      NO-UNDO.
    DEF INPUT  PARAM p_flg-erro-cod-senha  AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR INITIAL ''          NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR INITIAL ''          NO-UNDO.
    DEF OUTPUT PARAM p-aux-indevchq        AS INT  /* Devolucao */     NO-UNDO.
    DEF OUTPUT PARAM p-nrdocmto            AS INT                      NO-UNDO.
    DEF OUTPUT PARAM p-conta-atualiza      AS INT                      NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR INITIAL ''          NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC                      NO-UNDO.
    DEF OUTPUT PARAM p-flg-cta-migrada     AS LOGICAL                  NO-UNDO.
    DEF OUTPUT PARAM p-coop-migrada        AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-flg-coop-host       AS LOGICAL                  NO-UNDO.
    DEF OUTPUT PARAM p-nro-conta-nova      AS INT                      NO-UNDO.
    DEF OUTPUT PARAM p-nrcpfcgc            AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-dhprevisao_operacao AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-nro-conta-provisao  AS INT                      NO-UNDO.
    DEF OUTPUT PARAM p-solicita-senha      AS CHAR                     NO-UNDO.    
    
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_nrdconta            AS INT                                       NO-UNDO.
    DEF VAR aux_inexige_senha       AS CHAR                                      NO-UNDO.
    DEF VAR aux_nrcpfcgc            AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdcritic            AS INT                                       NO-UNDO.
    DEF VAR aux_dscritic            AS CHAR                                      NO-UNDO.
    DEF BUFFER crabcop FOR crapcop.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                        "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    IF   p-cmc-7 <> " "  THEN
         ASSIGN c-cmc-7              = p-cmc-7
                SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /* <99999999<9999999999>999999999999: */

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nro-conta = 978809   THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    RUN dbo/pcrap09.p (INPUT p-cooper,
                       INPUT c-cmc-7,
                       OUTPUT p-nro-calculado,
                       OUTPUT p-lista-digito).
    
    /*---- Numero do Documento (Cheque com o Digito ) -----*/
    ASSIGN i_cheque = INT(STRING(p-nro-cheque,"999999") + 
                          STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = i-cdhistor
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL craphis   THEN 
         DO:
             ASSIGN i-cod-erro  = 93
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    IF   craphis.tplotmov <> 1   THEN 
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

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    /* Verifica horario de Corte */
    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                             craptab.nmsistem = "CRED"            AND
                             craptab.tptabela = "GENERI"          AND
                             craptab.cdempres = 0                 AND
                             craptab.cdacesso = "HRTRCOMPEL"      AND
                             craptab.tpregist = p-cod-agencia  
                             NO-LOCK NO-ERROR.

    IF   NOT AVAIL craptab   THEN  
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

    IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
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

    IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
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

    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = p-nro-conta        AND
                       crapfdc.nrcheque = p-nro-cheque
                       NO-LOCK NO-ERROR.
    
    ASSIGN p-flg-cta-migrada = FALSE.
    
    IF  NOT AVAILABLE crapfdc   THEN                
    DO:
    
        /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
        /* Se for Bco Cecred ou Bancoob usa o nrctaant = de-nrctabdb na busca da conta */
        IF  p-cdbanchq = crapcop.cdbcoctl  OR 
            p-cdbanchq = 756               THEN
        DO:
            /* Localiza se o cheque é de uma conta migrada */
            FIND FIRST craptco WHERE 
                       craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                       craptco.nrctaant = INT(p-nro-conta) AND /* conta antiga */
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.
    
            IF  AVAIL craptco  THEN
            DO:
            
                /* verifica se o cheque pertence a conta migrada */
                FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                         crapfdc.cdbanchq = p-cdbanchq       AND
                                         crapfdc.cdagechq = p-cdagechq       AND
                                         crapfdc.nrctachq = p-nro-conta      AND
                                         crapfdc.nrcheque = p-nro-cheque
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

                FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                   NO-LOCK NO-ERROR.
                
                ASSIGN p-flg-cta-migrada = TRUE
                       p-coop-migrada    = crabcop.nmrescop
                       p-flg-coop-host   = FALSE
                       p-nro-conta-nova  = craptco.nrdconta.
            END.
        END.
        ELSE 
        /* Se for BB usa a conta ITG para buscar conta migrada */
        /* Usa o nrdctitg = de-nrctabdb na busca da conta */
        IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
        DO:
            /* Formata conta integracao */
            RUN fontes/digbbx.p (INPUT  p-nro-conta,
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
                                         crapfdc.nrctachq = p-nro-conta      AND
                                         crapfdc.nrcheque = p-nro-cheque
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
                FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                   NO-LOCK NO-ERROR.
                
                ASSIGN p-flg-cta-migrada = TRUE
                       p-coop-migrada    = crabcop.nmrescop
                       p-flg-coop-host   = FALSE
                       p-nro-conta-nova  = craptco.nrdconta.
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
    ELSE
    DO:
        /* Localiza se o cheque é de uma conta migrada */
        FIND FIRST craptco WHERE 
                   craptco.cdcopant = crapcop.cdcooper  AND /* coop ant     */
                   craptco.nrctaant = inte(p-nro-conta) AND /* conta antiga */
                   craptco.tpctatrf = 1                 AND
                   craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.

        IF  AVAIL craptco  THEN
        DO:
            FIND crabcop WHERE crabcop.cdcooper = craptco.cdcooper
               NO-LOCK NO-ERROR.
            
            ASSIGN p-flg-cta-migrada = TRUE
                   p-coop-migrada    = crabcop.nmrescop
                   p-flg-coop-host   = TRUE
                   p-nro-conta-nova  = craptco.nrdconta.
        END.
    END.

    ASSIGN aux_nrdconta = p-nro-conta.

    IF  AVAIL crapfdc  THEN
    DO:
    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
    RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                           INPUT 0,
                          OUTPUT aux_lscontas).

    /*  Le tabela com as contas convenio do Banco do Brasil - talao normal */
    RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                           INPUT 1,
                          OUTPUT aux_lsconta1).
    
    ASSIGN aux_nrdctitg = "".

    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nro-conta)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nro-conta
                    glb_cdcooper = crapfdc.cdcooper.
             RUN existe_conta_integracao.  
         END.                    
    /********************
    IF   ((p-cdbanchq = 1 AND CAN-DO("95,3420",STRING(p-cdagechq))) AND 
            CAN-DO(aux_lscontas,STRING(p-nro-conta))) OR 
           (p-cdbanchq = 756 AND p-cdagechq = crapcop.cdagebcb)
           /** Conta Integracao **/
            OR (aux_nrdctitg <> "" AND CAN-DO("3420",STRING(p-cdagechq)))  THEN
         DO:
         END.
    ELSE 
    ****************************/

    /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/
         RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                                INPUT 2,
                                OUTPUT aux_lsconta2).

    /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
           RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                                  INPUT 3,
                                  OUTPUT aux_lsconta3).


    ASSIGN 
        i-p-nro-cheque          = p-nro-cheque  /* variaveis proc.ver_cheque */
        i-p-nrddigc3            = p-nrddigc3
        i-p-cdbanchq            = p-cdbanchq
        i-p-cdagechq            = p-cdagechq
        i-p-nrctabdb            = p-nro-conta
        i-p-valor               = p-valor
        i-p-transferencia-conta = p-transferencia-conta
        i-p-aviso-cheque        = p-aviso-cheque
        de-nrctachq             = DEC(SUBSTR(c-cmc-7,23,10)).
    
    ASSIGN aux_nrdocmto = 0.
    
    IF  p-flg-cta-migrada  THEN
    DO:
        ASSIGN aux_cdagebcb = crabcop.cdagebcb.
        RUN ver_cheque_migrado.  /* include - bo-vercheque-migrado.i */
    END.
    ELSE
    DO:
        ASSIGN aux_cdagebcb = crapcop.cdagebcb.
        RUN ver_cheque.  /* include - bo-vercheque.i */
    END.
    
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

    /** Conta Integracao **/
    IF   aux_nrdctitg = ""   THEN                                          
         ASSIGN aux_nrctaass = p-nro-conta.
   
    DO   WHILE TRUE:

         FIND crapass WHERE crapass.cdcooper = crapfdc.cdcooper   AND
                            crapass.nrdconta = aux_nrctaass
                            NO-LOCK NO-ERROR.
        
         IF   NOT AVAIL crapass   THEN LEAVE.
        
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
              DO:
                  FIND FIRST craptrf WHERE 
                             craptrf.cdcooper = crapass.cdcooper    AND
                             craptrf.nrdconta = crapass.nrdconta    AND
                             craptrf.tptransa = 1                   AND
                             craptrf.insittrs = 2 
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.
    
                  IF   AVAIL craptrf   THEN
                       DO:
                           ASSIGN p-transferencia-conta = 
                                      "Conta transferida do Numero  " +
                                      STRING(p-nro-conta,"zzzz,zzz,9") +
                                      " para o numero " + 
                                      STRING(craptrf.nrsconta,"zzzz,zzz,9").
                           ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                  aux_nrdconta = craptrf.nrsconta
                                  aux_nrctaass = craptrf.nrsconta.
                       END.
                  ELSE
                       LEAVE.
              END.         
         ELSE
              LEAVE.    
    END. /* DO WHILE */

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = aux_nrctaass. 
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT i_conta,
                                      INPUT-OUTPUT i_conta).

    DELETE PROCEDURE h_b2crap00.

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
        
    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nro-conta,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).

    ASSIGN  aux_nrdconta = crapfdc.nrdconta. 

    IF   ((CAN-DO(aux_lsconta1,STRING(p-nro-conta)))  OR
           aux_nrdctitg <> "" )    /** Conta Integracao **/
          AND i-cdhistor = 21   THEN 
          DO:
                   /*
              ASSIGN i_nro-docto  = i_cheque.   /* Numero do Cheque */

              RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,     /* Nro Cheque */
                                 INPUT-OUTPUT i_nro-talao,     /* Nro Talao  */
                                 INPUT-OUTPUT i_posicao,       /* Posicao    */
                                 INPUT-OUTPUT i_nro-folhas).   /* Nro Folhas */
                     */
              ASSIGN glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,
                                                      "9999999"),1,6))
                     aux_nrdconta = crapfdc.nrdconta.
                       
              IF   crapfdc.tpcheque <> 1   THEN 
              DO:
                  ASSIGN i-cod-erro  = 646 /* Chq Transferencia */
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
              IF   CAN-DO(aux_lsconta3,STRING(p-nro-conta))   AND
                   i-cdhistor  = 26                           THEN 
                   DO:
                       ASSIGN glb_nrcalcul =INT(SUBSTR(STRING(i_cheque,
                                                              "9999999"),1,6)).
                       
                       IF   crapfdc.vlcheque = p-valor  THEN
                            ASSIGN aux_nrdconta = crapfdc.nrdconta.
                       ELSE  
                       DO:
                           ASSIGN i-cod-erro  = 91  
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
                       IF   i-cdhistor = 26 AND
                            NOT CAN-DO(aux_lsconta3,STRING(p-nro-conta))   THEN
                            DO:
                                ASSIGN i-cod-erro = 286 /*Chq Salario n Existe*/
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

    ASSIGN aux_nrtrfcta = 0.  
    DO   WHILE TRUE:
   
         FIND crapass WHERE crapass.cdcooper = crapfdc.cdcooper     AND
                            crapass.nrdconta = aux_nrdconta 
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
         IF    crapass.dtelimin <> ?   THEN 
               DO:
                   ASSIGN i-cod-erro  = 410
                          c-desc-erro = " ".           
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
              DO:
                  FIND FIRST craptrf WHERE
                             craptrf.cdcooper = crapfdc.cdcooper    AND
                             craptrf.nrdconta = crapass.nrdconta    AND
                             craptrf.tptransa = 1                   AND
                             craptrf.insittrs = 2   
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                  IF   NOT AVAIL craptrf   THEN 
                       DO:
                           ASSIGN i-cod-erro  = 95 /* Titular Cta Bloqueado */
                                  c-desc-erro = " ".           
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
                  ASSIGN aux_nrtrfcta = craptrf.nrsconta
                         aux_nrdconta = craptrf.nrsconta.
                  NEXT.
              END.
    

        RUN sistema/generico/procedures/b1wgen0001.p
            PERSISTENT SET h-b1wgen0001.
        
        IF   VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
             RUN ver_capital IN h-b1wgen0001(INPUT  crapfdc.cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtolt,
                                             INPUT  "b1crap53",
                                             INPUT  2, /*CAIXA*/
                                             OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0001.
        END.
         
        /* Verifica se houve erro */
        FIND FIRST tt-erro NO-LOCK  NO-ERROR.

        IF   AVAILABLE tt-erro   THEN
        DO:
             ASSIGN i-cod-erro  = tt-erro.cdcritic
                    c-desc-erro = tt-erro.dscritic.
                      
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.         
         
        LEAVE.

    END.   /* DO WHILE */
    IF   aux_nrtrfcta > 0   THEN /* Transferencia de Conta */
         ASSIGN p-transferencia-conta = "Conta transferida do Numero  " + 
                                        STRING(p-nro-conta,"zzzz,zzz,9") + 
                                        " para o numero " + 
                                        STRING(aux_nrtrfcta,"zzzz,zzz,9")
                aux_nrdconta = aux_nrtrfcta.

    ASSIGN p-conta-atualiza = aux_nrdconta
           p-nrdocmto = aux_nrdocmto. 
    
    IF   p-nrdocmto = 0   THEN    /* include bo-vercheque.i = aux_nrdocmto */
         ASSIGN p-nrdocmto = i_cheque.
                       
    IF   i-cdhistor = 21   OR
         i-cdhistor = 26   THEN 
         DO:
             RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
             ASSIGN i_conta = i_cheque.
             RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT-OUTPUT i_conta).
             DELETE PROCEDURE h_b2crap00.
       
             IF   RETURN-VALUE = "NOK"   THEN 
                  RETURN "NOK".
         END.               

    ASSIGN p-aux-indevchq = 0.

    IF   i-cdhistor = 21   THEN 
         DO:
             ASSIGN i_nro-docto  = i_cheque.   /* Numero do Cheque */

             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,   /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,   /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,     /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas). /* Nro Folhas */
         
             ASSIGN glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,
                                                     "9999999"),1,6)).
         
             IF   crapfdc.dtemschq = ?   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 108
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   crapfdc.dtretchq = ?   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 109 
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         
             IF   CAN-DO("5,6,7", STRING(crapfdc.incheque))   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 97 
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             
             IF   crapfdc.incheque = 8   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 320 
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             
             IF  (crapfdc.cdbantic <> 0
             OR   crapfdc.cdagetic <> 0
             OR   crapfdc.nrctatic <> 0)
            AND  (crapfdc.dtlibtic >= crapdat.dtmvtolt
             OR   crapfdc.dtlibtic  = ?) THEN
                  DO:
                      ASSIGN i-cod-erro  = 950 
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             IF   crapfdc.incheque = 1   OR
                  crapfdc.incheque = 2   THEN 
                  DO:
                      FIND crapcor WHERE crapcor.cdcooper = crapfdc.cdcooper AND
                                         crapcor.cdbanchq = i-p-cdbanchq     AND
                                         crapcor.cdagechq = i-p-cdagechq     AND
                                         crapcor.nrctachq = i-p-nrctabdb     AND
                                         crapcor.nrcheque = INT(i_cheque)    AND
                                         crapcor.flgativo = TRUE
                                         NO-LOCK NO-ERROR.

                      IF   NOT AVAIL crapcor   THEN  
                           DO:
                               ASSIGN i-cod-erro  = 101 
                                      c-desc-erro = " ".           
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      ASSIGN i-cod-erro  = 96 
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.  /* Historico 21 */

    IF   i-cdhistor  = 26   THEN 
         DO: 
             ASSIGN glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,
                                                     "9999999"),1,6)).
             
             IF   CAN-DO("5,7", STRING(crapfdc.incheque))   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 97
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   crapfdc.incheque = 8   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 320
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK". 
                  END.                             
             
             IF  (crapfdc.cdbantic <> 0
             OR   crapfdc.cdagetic <> 0
             OR   crapfdc.nrctatic <> 0)
            AND  (crapfdc.dtlibtic >= crapdat.dtmvtolt
             OR   crapfdc.dtlibtic  = ?) THEN
                  DO:
                      ASSIGN i-cod-erro  = 950
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             IF   crapfdc.incheque = 1   THEN 
                  DO:
                      FIND crapcor WHERE crapcor.cdcooper = crapfdc.cdcooper AND
                                         crapcor.cdbanchq = i-p-cdbanchq     AND
                                         crapcor.cdagechq = i-p-cdagechq     AND
                                         crapcor.nrctachq = i-p-nrctabdb     AND
                                         crapcor.nrcheque = INT(i_cheque)    AND
                                         crapcor.flgativo = TRUE
                                         NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAIL crapcor   THEN  
                           DO:
                               ASSIGN i-cod-erro  = 101 
                                      c-desc-erro = " ".           
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                           
                      FIND craphis WHERE craphis.cdcooper = crapfdc.cdcooper   AND
                                         craphis.cdhistor = crapcor.cdhistor 
                                         NO-LOCK NO-ERROR.
          
                      ASSIGN c-desc-erro  = "Contra Ordem de " + 
                                            STRING(crapcor.dtemscor).
                      IF   AVAIL craphis   THEN
                           ASSIGN c-desc-erro = c-desc-erro + " -->  " +
                                                craphis.dshistor. 
          
                      ASSIGN i-cod-erro  = 0.          
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".                       
                  END.
             IF   crapfdc.incheque = 2   THEN 
                  DO:
                      FIND crapcor WHERE crapcor.cdcooper = crapfdc.cdcooper AND
                                         crapcor.cdbanchq = i-p-cdbanchq     AND
                                         crapcor.cdagechq = i-p-cdagechq     AND
                                         crapcor.nrctachq = i-p-nrctabdb     AND
                                         crapcor.nrcheque = INT(i_cheque)    AND
                                         crapcor.flgativo = TRUE
                                         NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAIL crapcor   THEN  
                           DO:
                               ASSIGN i-cod-erro  = 101 
                                      c-desc-erro = " ".           
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                       
                      FIND craphis WHERE craphis.cdcooper = crapfdc.cdcooper   AND
                                         craphis.cdhistor = crapcor.cdhistor
                                         NO-LOCK NO-ERROR.
          
                      ASSIGN p-aviso-cheque = "Aviso de " + 
                                              STRING(crapcor.dtemscor).
                      IF   AVAIL craphis   THEN
                           ASSIGN p-aviso-cheque = p-aviso-cheque + " -->  " +
                                                   craphis.dshistor. 
                  END.
         END.  /* Historico 26 */              

    IF   craphis.inhistor = 12   THEN 
         DO:  /* Para Historico 26 */
             FIND crapsld WHERE crapsld.cdcooper = crapfdc.cdcooper     AND
                                crapsld.nrdconta = aux_nrdconta 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapsld   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 10
                             c-desc-erro = " ".          
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK". 
                  END.
             aux_vlsdchsl = crapsld.vlsdchsl.
         
         FOR EACH craplcm WHERE craplcm.cdcooper  = crapsld.cdcooper    AND
                                craplcm.nrdconta  = crapsld.nrdconta    AND
                                craplcm.dtmvtolt  = crapdat.dtmvtocd    AND
                                craplcm.cdhistor <> 289             
                                USE-INDEX craplcm2 NO-LOCK:

             FIND b-craphis WHERE b-craphis.cdcooper = craplcm.cdcooper   AND
                                  b-craphis.cdhistor = craplcm.cdhistor 
                                  NO-lock NO-ERROR.

             IF   NOT AVAIL b-craphis   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 80
                             c-desc-erro = " ".          
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK". 
                  END.
             IF   b-craphis.inhistor = 2   THEN 
                  ASSIGN aux_vlsdchsl = aux_vlsdchsl + craplcm.vllanmto.
             ELSE
                  IF   b-craphis.inhistor = 12   THEN
                       ASSIGN aux_vlsdchsl = aux_vlsdchsl - craplcm.vllanmto.
         END.
         IF   aux_vlsdchsl < p-valor   THEN 
              DO:
                  ASSIGN i-cod-erro  = 135
                         c-desc-erro = " ".          
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK". 
              END.
    END.   /* craphis.inhistor = 12  - Somente para Historico 26*/
    END. /* Fim if avail crapfdc */

    FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper  AND
                       craplcm.dtmvtolt = crapdat.dtmvtocd  AND
                       craplcm.cdagenci = p-cod-agencia     AND
                       craplcm.cdbccxlt = 11                AND /* Fixo */
                       craplcm.nrdolote = i-nro-lote        AND
                       craplcm.nrdctabb = INT(p-nro-conta)  AND
                       craplcm.nrdocmto = i_cheque          
                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                       
    IF   AVAIL craplcm   THEN  
         DO:
             ASSIGN i-cod-erro  = 92
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.    
    ELSE
    DO:
        IF  AVAIL crapfdc  THEN
        DO:
        /* VERIFICAR SE O LANCAMENTO EH DE UM CHEQUE MIGRADO */
        /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
        /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
        IF  crapfdc.cdbanchq = crapcop.cdbcoctl  OR 
            crapfdc.cdbanchq = 756               THEN
        DO:
            /* Localiza se o cheque é de uma conta migrada */
            FIND FIRST craptco WHERE 
                       craptco.cdcopant = crapcop.cdcooper AND /* coop antiga  */
                       craptco.nrctaant = inte(i-p-nrctabdb)     AND /* conta antiga */
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

            IF  AVAIL craptco  THEN
            DO:
                FIND craplcm WHERE craplcm.cdcooper = craptco.cdcooper          AND /* coop nova */
                                   craplcm.dtmvtolt = crapdat.dtmvtocd          AND
                                   craplcm.cdagenci = craptco.cdagenci          AND
                                   craplcm.cdbccxlt = 100                       AND /* Fixo */
                                   craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                   craplcm.nrdctabb = int(i-p-nrctabdb)         AND
                                   craplcm.nrdocmto = i_cheque          
                                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                IF  AVAIL craplcm  THEN
                DO:
                    ASSIGN i-cod-erro  = 92
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
        IF  crapfdc.cdbanchq = 1 AND crapfdc.cdagechq = 3420  THEN
        DO:
            /* Formata conta integracao */
            RUN fontes/digbbx.p (INPUT  i-p-nrctabdb,
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
                                   craplcm.dtmvtolt = crapdat.dtmvtocd          AND
                                   craplcm.cdagenci = craptco.cdagenci          AND
                                   craplcm.cdbccxlt = 100                       AND /* Fixo */
                                   craplcm.nrdolote = 205000 + craptco.cdagenci AND
                                   craplcm.nrdctabb = int(i-p-nrctabdb)         AND
                                   craplcm.nrdocmto = i_cheque          
                                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                IF  AVAIL craplcm  THEN
                DO:
                    ASSIGN i-cod-erro  = 92
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
        END. /* fim avail crapfdc */
    END.

    FOR EACH crapneg WHERE crapneg.cdcooper = crapfdc.cdcooper      AND
                           crapneg.nrdconta = INT(aux_nrdconta)     AND
                           crapneg.nrdocmto = i_cheque              AND
                           crapneg.cdhisest = 1                     
                           USE-INDEX crapneg1 NO-LOCK
                           BY crapneg.nrseqdig DESCENDING: 
                  
        IF   CAN-DO("12,13",STRING(crapneg.cdobserv)) AND
             crapneg.dtfimest = ?                     THEN
             DO:            
                ASSIGN i-cod-erro  = 761
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
                     
    /*-------------*/
    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
    
    IF  p-flg-cta-migrada  THEN
    DO:
        /* Se for cooperativa migrada - de origem */
        IF   p-flg-coop-host THEN
             RUN  consulta-conta IN h-b1crap02(INPUT crapcop.nmrescop,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT aux_nrdconta,
                                          OUTPUT TABLE tt-conta).
        ELSE
             RUN  consulta-conta IN h-b1crap02(INPUT p-coop-migrada,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT aux_nrdconta,
                                          OUTPUT TABLE tt-conta).
    END.
    ELSE
    DO:
        RUN  consulta-conta IN h-b1crap02(INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT aux_nrdconta,
                                          OUTPUT TABLE tt-conta).

    END.

    DELETE PROCEDURE h-b1crap02.

    IF   RETURN-VALUE = "NOK"   THEN   
         RETURN "NOK".                    

    ASSIGN de-valor-libera = 0.
    IF   i-cdhistor <> 26   THEN 
         DO:
             FIND FIRST tt-conta NO-LOCK NO-ERROR.
             IF   AVAIL tt-conta   THEN
                  DO:

                      ASSIGN de-valor-bloqueado = tt-conta.bloqueado +
                                                  tt-conta.bloq-praca +
                                                  tt-conta.bloq-fora-praca.
                      ASSIGN de-valor-liberado = tt-conta.acerto-conta -
                                                 de-valor-bloqueado.

                      IF  de-valor-liberado + tt-conta.limite-credito < p-valor
                          THEN DO:
                          /*--- Anterior
                          IF   (tt-conta.acerto-conta + tt-conta.limite-credito)
                               < p-valor THEN  DO: ---*/

                          /*----Nao considera CPMF e considera limite
                          IF   (tt-conta.disponivel + 
                                tt-conta.limite-credito) < p-valor   THEN 
                               ASSIGN de-valor = tt-conta.disponivel + 
                                                 tt-conta.limite-credito
                                      p-valor-disponivel = de-valor
                                      de-valor-libera = ((tt-conta.disponivel +
                                                    tt-conta.limite-credito) -
                                                    p-valor) * -1
                                      p-mensagem = 
                                             "Nao existe Saldo Disponivel.. " +
                                             TRIM(STRING(de-valor,
                                             "zzz,zzz,zzz,zz9.99-")) +
                                             Excedido.. " + 
                                             TRIM(STRING(de-valor-libera,
                                             "zzz,zzz,zzz,zz9.99-")).
                          ---*/
                          /*--- Anterior
                               ASSIGN p-valor-disponivel = 
                                                  tt-conta.acerto-conta +
                                                  tt-conta.limite-credito
                                      de-valor-libera = (tt-conta.acerto-conta -                                                         p-valor) * -1
                                      p-mensagem = "Saldo.. " +
                                            TRIM(STRING(tt-conta.acerto-conta,
                                                 "zzz,zzz,zzz,zz9.99-")) + 
                                            "  Limite Credito.. " +
                                            TRIM(STRING(tt-conta.limite-credito,
                                                 "zzz,zzz,zzz,zz9.99-")) +
                                            "  EXCEDIDO.. " + 
                                            TRIM(STRING(de-valor-libera,
                                            "zzz,zzz,zzz,zz9.99-")).
                          ---------------*/

                               ASSIGN p-valor-disponivel = de-valor-liberado + 
                                                       tt-conta.limite-credito
                                      de-valor-libera = (de-valor-liberado - 
                                                        p-valor) * -1.
         
                               ASSIGN p-mensagem = "Saldo " +
                                            TRIM(STRING(de-valor-liberado,
                                                 "zzz,zzz,zzz,zz9.99-")) + 
                                            " Limite " +
                                            TRIM(STRING(tt-conta.limite-credito,
                                                 "zzz,zzz,zzz,zz9.99-")) +
                                            " Excedido " + 
                                            TRIM(STRING(de-valor-libera,
                                            "zzz,zzz,zzz,zz9.99-")) + 
                                            " Bloq. " + 
                                            TRIM(STRING(de-valor-bloqueado,
                                            "zzz,zzz,zzz,zz9.99-")).

                          END.
                          
                        /* Verificar necessidade de senha apenas se tiver selecionado o tipo Especie */    
                      IF p_tppagmto = 1 
                          THEN DO:    
                              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              
                              aux_nrcpfcgc = REPLACE(tt-conta.cpfcgc, ".", "").
                              aux_nrcpfcgc = REPLACE(aux_nrcpfcgc, "-", "").
                              aux_nrcpfcgc = REPLACE(aux_nrcpfcgc, "/", "").
                              
                              /* CPF/CNPJ sera retornado via parametro */
                              ASSIGN p-nrcpfcgc = aux_nrcpfcgc.
                
                              /* Efetuar a chamada da rotina Oracle */ 
                              RUN STORED-PROCEDURE pc_ver_necessidade_senha
                                  aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper,         /* Cooperativa */
                                                                      INPUT p-cod-agencia,            /* Agencia */
                                                                      INPUT DEC(aux_nrcpfcgc),        /* CPF/CNPJ */
                                                                      INPUT p-valor,                  /* Valor Saque */
                                                                      OUTPUT "",                      /* Data e hora prevista para saque/pagamento em especie. */
                                                                      OUTPUT 0,                       /* Numero da conta da provisao */
                                                                      OUTPUT "",                      /* Indicador de necessidade de senha */
                                                                      OUTPUT 0,                       /* Cod. critica */
                                                                      OUTPUT "").                     /* Desc. critica */

                              /* Fechar o procedimento para buscarmos o resultado */ 
                              CLOSE STORED-PROC pc_ver_necessidade_senha
                                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                              
                              HIDE MESSAGE NO-PAUSE.

                              /* Busca possíveis erros */ 
                              ASSIGN p-dhprevisao_operacao = ""
                                     p-dhprevisao_operacao = pc_ver_necessidade_senha.pr_dhprevisao_operacao 
                                                          WHEN pc_ver_necessidade_senha.pr_dhprevisao_operacao <> ?
                                     p-nro-conta-provisao = 0
                                     p-nro-conta-provisao = pc_ver_necessidade_senha.pr_nrdconta 
                                                          WHEN pc_ver_necessidade_senha.pr_nrdconta <> ?                     
                                     aux_inexige_senha = ""
                                     aux_inexige_senha = pc_ver_necessidade_senha.pr_inexige_senha 
                                                    WHEN pc_ver_necessidade_senha.pr_inexige_senha <> ?
                                     aux_cdcritic = 0
                                     aux_cdcritic = pc_ver_necessidade_senha.pr_cdcritic 
                                                    WHEN pc_ver_necessidade_senha.pr_cdcritic <> ?          
                                     aux_dscritic = ""
                                     aux_dscritic = pc_ver_necessidade_senha.pr_dscritic 
                                                    WHEN pc_ver_necessidade_senha.pr_dscritic <> ?.
                              
                              IF  aux_dscritic <> "" THEN
                                 DO:
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
                              
                              IF aux_inexige_senha = "S" THEN
                                 DO:
                                    
                                    ASSIGN i-cod-erro = 0
                                           c-desc-erro = "Atencao! Provisao para saque nao realizada.
                                          Saque nao autorizado." .
                                 
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    
                                    IF p_flg-erro-cod-senha = "TRUE" THEN DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Informe Codigo/Senha ".
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT p-nro-caixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                    END.                                                   
                                 
                                    ASSIGN p-solicita-senha = "TRUE".
                                    
                                 END. 
                          END.
                  END.
         END.    
    
    RETURN "OK".  
END PROCEDURE.


PROCEDURE atualiza-pagto-cheque:
        
    DEF INPUT  PARAM p-cooper          AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE /* Cod. Agencia */       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INTE /* Numero Caixa*/        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador    AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-liberador   AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nro-conta       AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque      AS INT  FORMAT "zzz,zz9" /*Chq*/ NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3        AS INT  FORMAT "9" /* C3 */      NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-aux-indevchq    AS INT  /* Devolucao */          NO-UNDO.
    DEF INPUT  PARAM p-nrdocmto        AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-conta-atualiza  AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-cdbanchq        AS INT  FORMAT "zz9"             NO-UNDO.
    DEF INPUT  PARAM p-cdagechq        AS INT  FORMAT "zzz9"            NO-UNDO.
    DEF OUTPUT PARAM p-histor          AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-literal-r       AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r AS INT                           NO-UNDO.

    DEF VAR aux_cdbccxlt AS INTEGER                                     NO-UNDO.
    DEF VAR aux_lsdigctr AS CHAR                                        NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                        NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_nrdctitg = "".
    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nro-conta)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nro-conta
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.                    
    
    IF   aux_nrdctitg = " "   THEN 
         DO:

             DO   WHILE TRUE:
                  FIND crapass WHERE 
                       crapass.cdcooper = crapcop.cdcooper    AND
                       crapass.nrdconta = INT(p-nro-conta)    
                       NO-LOCK NO-ERROR.
                             
                  IF   NOT AVAIL crapass   THEN LEAVE.
                  IF   AVAIL crapass   THEN 
                       DO:
                           IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
                                DO:
                                    FIND FIRST craptrf WHERE
                                            craptrf.cdcooper = 
                                                    crapcop.cdcooper    AND
                                            craptrf.nrdconta = 
                                                    crapass.nrdconta    AND
                                            craptrf.tptransa = 1        AND
                                            craptrf.insittrs = 2   
                                            USE-INDEX craptrf1 
                                            NO-LOCK NO-ERROR.
    
                                IF   AVAIL craptrf   THEN  
                                     ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                            aux_nrdconta = craptrf.nrsconta
                                            p-nro-conta  = craptrf.nrsconta.
                                ELSE 
                                     LEAVE.
                       END.
                  ELSE
                       LEAVE.    
             END.
         END.
/*---------------------*/                  
    END.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
 
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                         "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
      
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nro-conta = 978809   THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    ASSIGN i_cheque = INT(STRING(p-nro-cheque,"999999") +
                          STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nrdconta = p-conta-atualiza.
    
    IF  aux_nrdconta = p-nro-conta  THEN 
        DO: 
            IF   p-cdbanchq   = crapcop.cdbcoctl  THEN
                 aux_cdbccxlt = crapcop.cdbcoctl.
            ELSE
                 aux_cdbccxlt = 756.
        END.
    ELSE 
        aux_cdbccxlt = 1.
    
    IF   p-aux-indevchq > 0  THEN  
         DO:
             RUN dbo/pcrap10.p (INPUT p-cooper,
                                INPUT crapdat.dtmvtocd,
                                INPUT aux_cdbccxlt,
                                INPUT p-aux-indevchq,
                                INPUT aux_nrdconta,
                                INPUT i_cheque,
                                INPUT p-nro-conta,
                                INPUT p-valor,
                                INPUT 0, /*codigo alinea */
                                INPUT IF (p-aux-indevchq = 1 OR
                                          p-aux-indevchq = 2)
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
             /* Criar registro no crapdev  */
    
             IF   NOT CAN-FIND(crapdev WHERE 
                               crapdev.cdcooper = crapcop.cdcooper      AND
                               crapdev.dtmvtolt = crapdat.dtmvtocd      AND
                               crapdev.nrdconta = aux_nrdconta          AND
                               crapdev.nrdctabb = inte(p-nro-conta)     AND
                               crapdev.nrcheque = i_cheque              AND
                               crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                      p-aux-indevchq = 2) 
                                                  THEN 47
                                                  ELSE 78)              THEN 
                  DO:
                      CREATE crapdev.
                      ASSIGN crapdev.dtmvtolt = crapdat.dtmvtocd
                             crapdev.cdbccxlt = aux_cdbccxlt
                             crapdev.nrdconta = aux_nrdconta
                             crapdev.nrdctabb = p-nro-conta
                             crapdev.nrcheque = i_cheque
                             crapdev.vllanmto = p-valor
                             crapdev.cdalinea = 0
                             crapdev.cdoperad = p-cod-operador
                             crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                    p-aux-indevchq = 2) 
                                                THEN 47
                                                ELSE 78
                             crapdev.insitdev = 1 
                             crapdev.cdcooper = crapcop.cdcooper
                             crapdev.cdbanchq = p-cdbanchq
                             crapdev.cdagechq = p-cdagechq
                             crapdev.nrctachq = p-nro-conta.
                      VALIDATE crapdev.
                  END.              
         END.                      
    
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                       NO-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craplot   THEN 
         DO:
             CREATE craplot.
             ASSIGN craplot.dtmvtolt = crapdat.dtmvtocd
                    craplot.cdagenci = p-cod-agencia   
                    craplot.cdbccxlt = 11              
                    craplot.nrdolote = i-nro-lote
                    craplot.tplotmov = 1
                    craplot.cdoperad = p-cod-operador
                    craplot.cdhistor = 0 /* i-cdhistor */
                    craplot.nrdcaixa = p-nro-caixa
                    craplot.cdopecxa = p-cod-operador  
                    craplot.cdcooper = crapcop.cdcooper.
         END.
    
    IF   i-cdhistor = 21  THEN 
         DO:
             ASSIGN i_nro-docto = i_cheque.
             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,   /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,   /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,     /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas). /* Nro Folhas */
                           
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
        
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                                                        
                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
                                    ASSIGN i-cod-erro = 108
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
         END.  /* Historico 21 */
    ELSE 
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                              
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  
                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
    
    IF   i-cdhistor = 21 THEN   
         ASSIGN crapfdc.incheque = crapfdc.incheque + 5.
    ELSE 
         ASSIGN crapfdc.incheque = (IF crapfdc.incheque = 0 THEN 5
                                  ELSE 
                                  (IF crapfdc.incheque = 2 THEN 7
                                  ELSE 0)).
                                  
    ASSIGN crapfdc.dtliqchq = crapdat.dtmvtocd
           crapfdc.cdoperad = p-cod-operador
           crapfdc.vlcheque = p-valor.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
    RUN STORED-PROCEDURE pc_sequence_progress
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                      ,INPUT "NRSEQDIG"
                      ,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
                      ,INPUT "N"
                      ,"").

    CLOSE STORED-PROC pc_sequence_progress
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                WHEN pc_sequence_progress.pr_sequence <> ?.
    
    /*--- Verifica se Lancamento ja Existe ---*/
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper        AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                             craplcm.cdagenci = p-cod-agencia           AND
                             craplcm.cdbccxlt = 11                      AND
                             craplcm.nrdolote = i-nro-lote              AND
                             craplcm.nrseqdig = aux_nrseqdig
                             USE-INDEX craplcm3 NO-LOCK NO-ERROR.
                             
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
          
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper    AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                             craplcm.cdagenci = p-cod-agencia       AND
                             craplcm.cdbccxlt  = 11                 AND
                             craplcm.nrdolote = i-nro-lote          AND
                             craplcm.nrdctabb = INT(p-nro-conta)    AND
                             craplcm.nrdocmto = i_cheque 
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.
    
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nro-conta,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).
    
    /* PJ450 - Regulatorio de crédito */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.
    
    /*  Cria lancamento da conta do associado ................................ */ 
    RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
          ,INPUT p-cod-agencia                  /* par_cdagenci */
          ,INPUT 11                             /* par_cdbccxlt */
          ,INPUT i-nro-lote                     /* par_nrdolote */
          ,INPUT aux_nrdconta                   /* par_nrdconta */
          ,INPUT i_cheque                       /* par_nrdocmto */
          ,INPUT i-cdhistor                     /* par_cdhistor */
          ,INPUT aux_nrseqdig                   /* par_nrseqdig */
          ,INPUT p-valor                        /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP53," + p-cod-liberador    /* par_cdpesqbb */
          ,INPUT 0                              /* par_vldoipmf */
          ,INPUT 0                              /* par_nrautdoc */
          ,INPUT 0                              /* par_nrsequni */
          ,INPUT crapfdc.cdbanchq               /* par_cdbanchq */
          ,INPUT 0                              /* par_cdcmpchq */
          ,INPUT crapfdc.cdagechq               /* par_cdagechq */
          ,INPUT crapfdc.nrctachq               /* par_nrctachq */
          ,INPUT 0                              /* par_nrlotchq */
          ,INPUT 0                              /* par_sqlotchq */
          ,INPUT ""                             /* par_dtrefere */
          ,INPUT ""                             /* par_hrtransa */
          ,INPUT ""                             /* par_cdoperad */
          ,INPUT ""                             /* par_dsidenti */
          ,INPUT crapcop.cdcooper               /* par_cdcooper */
          ,INPUT glb_dsdctitg                   /* par_nrdctitg */
          ,INPUT ""                             /* par_dscedent */
          ,INPUT 0                              /* par_cdcoptfn */
          ,INPUT 0                              /* par_cdagetfn */
          ,INPUT 0                              /* par_nrterfin */
          ,INPUT 0                              /* par_nrparepr */
          ,INPUT 0                              /* par_nrseqava */
          ,INPUT 0                              /* par_nraplica */
          ,INPUT 0                              /* par_cdorigem */
          ,INPUT 0                              /* par_idlautom */
          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
          ,INPUT 0                              /* Processa lote                                 */
          ,INPUT 0                              /* Tipo de lote a movimentar                     */
          /* CAMPOS DE SAÍDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
          ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
          ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
          ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
       DO:  
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
    ELSE 
       DO:
          /* 02/07/2018- Posicionando no registro da craplcm criado acima */
          FIND FIRST tt-ret-lancto.
          FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
       END.


    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

    ASSIGN p-histor = i-cdhistor.
    
    IF   p-aux-indevchq = 0  THEN
         DO:
             FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                                      craptab.nmsistem = "CRED"              AND
                                      craptab.tptabela = "USUARI"            AND
                                      craptab.cdempres = 11                  AND
                                      craptab.cdacesso = "MAIORESCHQ"        AND
                                      craptab.tpregist = 1
                                      NO-LOCK NO-ERROR.
     
             IF   NOT AVAIL craptab   THEN
                  ASSIGN TAB_vlchqmai = 1.
             ELSE
                  ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).
     
             IF   p-valor < tab_vlchqmai   THEN
                  ASSIGN  aux_tpdmovto = 2.
             ELSE
                  ASSIGN  aux_tpdmovto = 1.
     
    
             RUN fontes/dig_cmc7.p(INPUT  crapfdc.dsdocmc7,
                                   OUTPUT glb_nrcalcul,
                                   OUTPUT aux_lsdigctr).
     
             CREATE crapchd.
             ASSIGN crapchd.cdcooper = crapcop.cdcooper
                    crapchd.cdagechq = crapfdc.cdagechq
                    crapchd.cdagenci = p-cod-agencia
                    crapchd.cdbanchq = crapfdc.cdbanchq
                    crapchd.cdbccxlt = 11
                    crapchd.nrdolote = i-nro-lote
                    crapchd.nrdocmto = i_cheque
                    crapchd.nrseqdig = craplcm.nrseqdig
                    crapchd.cdcmpchq = crapfdc.cdcmpchq
                    crapchd.cdoperad = p-cod-operador
                    crapchd.cdsitatu = 1
                    crapchd.dsdocmc7 = crapfdc.dsdocmc7
                    crapchd.dtmvtolt = crapdat.dtmvtocd
                    crapchd.inchqcop = 1  /* Cheque da Cooperativa */
                    crapchd.insitchq = 0
                    crapchd.cdtipchq = INTEGER(SUBSTR(crapfdc.dsdocmc7,20,1))
                    crapchd.nrcheque = p-nro-cheque 
                    crapchd.nrctachq = p-nro-conta
                    crapchd.nrdconta = aux_nrdconta
                    crapchd.nrddigv1 = INT(ENTRY(1,aux_lsdigctr))
                    crapchd.nrddigv2 = INT(ENTRY(2,aux_lsdigctr))
                    crapchd.nrddigv3 = INT(ENTRY(3,aux_lsdigctr))
                    crapchd.tpdmovto = aux_tpdmovto
                    crapchd.nrterfin = 0
                    crapchd.flgenvio = FALSE
                    crapchd.insitprv = 0
                    crapchd.vlcheque = p-valor.
             VALIDATE crapchd.
    
             /********* Comentado em 19/01/2011 *******
             RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
             RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT p-cooper,
                                                        INPUT p-cod-agencia,
                                                        INPUT p-nro-caixa,
                                                        INPUT p-cod-operador,
                                                        INPUT crapdat.dtmvtolt,
                                                        INPUT 1). /*Inclusao*/
             DELETE PROCEDURE h-b1crap00.
             ****************/
         END.  

    
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-valor,
                                           INPUT dec(p-nrdocmto),
                                           INPUT yes, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line    */         
                                           INPUT NO,   /* NÆo estorno     */
                                           INPUT p-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
   
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
  
    /* Atualiza sequencia Autenticacao */

    ASSIGN craplcm.nrautdoc = p-ult-sequencia.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.
 
    RELEASE craplcm.
    RELEASE craplot.
    RELEASE crapfdc.
   
    RETURN "OK".
END PROCEDURE.

PROCEDURE atualiza-pagto-cheque-migrado:
        
    DEF INPUT  PARAM p-cooper          AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nmcooper        AS CHAR /* nmrescop migrado */   NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE /* Cod. Agencia */       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INTE /* Numero Caixa*/        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador    AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-liberador   AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nro-conta       AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque      AS INT  FORMAT "zzz,zz9" /*Chq*/ NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3        AS INT  FORMAT "9" /* C3 */      NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-aux-indevchq    AS INT  /* Devolucao */          NO-UNDO.
    DEF INPUT  PARAM p-nrdocmto        AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-conta-atualiza  AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-cdbanchq        AS INT  FORMAT "zz9"             NO-UNDO.
    DEF INPUT  PARAM p-cdagechq        AS INT  FORMAT "zzz9"            NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-nova  AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-histor          AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-literal-r       AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r AS INT                           NO-UNDO.

    DEF VAR aux_cdbccxlt AS INTEGER                                     NO-UNDO.
    DEF VAR aux_lsdigctr AS CHAR                                        NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                        NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    
    /** Coperativa atual **/
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    /** Coperativa antiga **/
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.

    MESSAGE p-cooper p-nmcooper.
    
    ASSIGN aux_nrdctitg = "".
    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nro-conta)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nro-conta-nova
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.                    
    
    IF   aux_nrdctitg = " "   THEN 
         DO:

             DO   WHILE TRUE:
                  FIND crapass WHERE 
                       crapass.cdcooper = crapcop.cdcooper    AND
                       crapass.nrdconta = INT(p-nro-conta)    
                       NO-LOCK NO-ERROR.
                             
                  IF   NOT AVAIL crapass   THEN LEAVE.
                  IF   AVAIL crapass   THEN 
                       DO:
                           IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
                                DO:
                                    FIND FIRST craptrf WHERE
                                            craptrf.cdcooper = 
                                                    crapcop.cdcooper    AND
                                            craptrf.nrdconta = 
                                                    crapass.nrdconta    AND
                                            craptrf.tptransa = 1        AND
                                            craptrf.insittrs = 2   
                                            USE-INDEX craptrf1 
                                            NO-LOCK NO-ERROR.
    
                                IF   AVAIL craptrf   THEN  
                                     ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                            aux_nrdconta = craptrf.nrsconta
                                            p-nro-conta  = craptrf.nrsconta.
                                ELSE 
                                     LEAVE.
                       END.
                  ELSE
                       LEAVE.    
             END.
         END.
/*---------------------*/                  
    END.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
 
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                         "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
      
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nro-conta = 978809   THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    ASSIGN i_cheque = INT(STRING(p-nro-cheque,"999999") +
                          STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nrdconta = p-conta-atualiza.
    
    IF  aux_nrdconta = p-nro-conta  THEN 
        DO: 
            IF   p-cdbanchq   = crapcop.cdbcoctl  THEN
                 aux_cdbccxlt = crapcop.cdbcoctl.
            ELSE
                 aux_cdbccxlt = 756.
        END.
    ELSE 
        aux_cdbccxlt = 1.
    
    IF   p-aux-indevchq > 0  THEN  
         DO:
             RUN dbo/pcrap10.p (INPUT p-nmcooper,
                                INPUT crapdat.dtmvtocd,
                                INPUT aux_cdbccxlt,
                                INPUT p-aux-indevchq,
                                INPUT aux_nrdconta,
                                INPUT i_cheque,
                                INPUT p-nro-conta,
                                INPUT p-valor,
                                INPUT 0, /*codigo alinea */
                                INPUT IF (p-aux-indevchq = 1 OR
                                          p-aux-indevchq = 2)
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
             /* Criar registro no crapdev  */
    
             IF   NOT CAN-FIND(crapdev WHERE 
                               crapdev.cdcooper = crabcop.cdcooper      AND
                               crapdev.dtmvtolt = crapdat.dtmvtocd      AND
                               crapdev.nrdconta = aux_nrdconta          AND
                               crapdev.nrdctabb = inte(p-nro-conta)     AND
                               crapdev.nrcheque = i_cheque              AND
                               crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                      p-aux-indevchq = 2) 
                                                  THEN 47
                                                  ELSE 78)              THEN 
                  DO:
                      CREATE crapdev.
                      ASSIGN crapdev.dtmvtolt = crapdat.dtmvtocd
                             crapdev.cdbccxlt = aux_cdbccxlt
                             crapdev.nrdconta = aux_nrdconta
                             crapdev.nrdctabb = p-nro-conta
                             crapdev.nrcheque = i_cheque
                             crapdev.vllanmto = p-valor
                             crapdev.cdalinea = 0
                             crapdev.cdoperad = p-cod-operador
                             crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                    p-aux-indevchq = 2) 
                                                THEN 47
                                                ELSE 78
                             crapdev.insitdev = 1 
                             crapdev.cdcooper = crabcop.cdcooper
                             crapdev.cdbanchq = p-cdbanchq
                             crapdev.cdagechq = p-cdagechq
                             crapdev.nrctachq = p-nro-conta.
                      VALIDATE crapdev.
                  END.              
         END.                      
    
    IF   i-cdhistor = 21  THEN 
         DO:
             ASSIGN i_nro-docto = i_cheque.
             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,   /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,   /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,     /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas). /* Nro Folhas */
                           
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
        
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                                                        
                  FIND crapfdc WHERE crapfdc.cdcooper = crabcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
                                    ASSIGN i-cod-erro = 108
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
         END.  /* Historico 21 */
    ELSE 
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                              
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  
                  FIND crapfdc WHERE crapfdc.cdcooper = crabcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
 
    IF   i-cdhistor = 21 THEN   
         ASSIGN crapfdc.incheque = crapfdc.incheque + 5.
    ELSE 
         ASSIGN crapfdc.incheque = (IF crapfdc.incheque = 0 THEN 5
                                  ELSE 
                                  (IF crapfdc.incheque = 2 THEN 7
                                  ELSE 0)).
                                  
    ASSIGN crapfdc.dtliqchq = crapdat.dtmvtocd
           crapfdc.cdoperad = "1" /* SUPER-USUARIO na migracao */
           crapfdc.vlcheque = p-valor.
    
    
    /* Verifica se o lote ja Existe na copperativa atual */
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                       NO-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craplot   THEN 
         DO:
             CREATE craplot.
             ASSIGN craplot.dtmvtolt = crapdat.dtmvtocd
                    craplot.cdagenci = p-cod-agencia   
                    craplot.cdbccxlt = 11              
                    craplot.nrdolote = i-nro-lote
                    craplot.tplotmov = 1
                    craplot.cdoperad = "1" /* SUPER-USUARIO para migracao */
                    craplot.cdhistor = 0 /* i-cdhistor */
                    craplot.nrdcaixa = p-nro-caixa 
                    craplot.cdopecxa = p-cod-operador 
                    craplot.cdcooper = crapcop.cdcooper.
         END.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
    RUN STORED-PROCEDURE pc_sequence_progress
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                      ,INPUT "NRSEQDIG"
                      ,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
                      ,INPUT "N"
                      ,"").

    CLOSE STORED-PROC pc_sequence_progress
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                WHEN pc_sequence_progress.pr_sequence <> ?.
    
    /*--- Verifica se Lancamento ja Existe na cooperativa atual ---*/
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper        AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                             craplcm.cdagenci = p-cod-agencia           AND
                             craplcm.cdbccxlt = 11                      AND
                             craplcm.nrdolote = i-nro-lote              AND
                             craplcm.nrseqdig = aux_nrseqdig
                             USE-INDEX craplcm3 NO-LOCK NO-ERROR.
                             
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
          
    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper AND
                             craplcm.dtmvtolt = crapdat.dtmvtocd AND
                             craplcm.cdagenci = p-cod-agencia    AND
                             craplcm.cdbccxlt = 11               AND
                             craplcm.nrdolote = i-nro-lote       AND
                             craplcm.nrdctabb = INT(p-nro-conta) AND
                             craplcm.nrdocmto = i_cheque 
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.
    
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nro-conta,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).
    
    /* PJ450 - Regulatorio de crédito */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.
    
    
    /* Criar o lancamento na cooperativa nova */
    RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
          ,INPUT p-cod-agencia                  /* par_cdagenci */
          ,INPUT 11                             /* par_cdbccxlt */
          ,INPUT i-nro-lote                     /* par_nrdolote */
          ,INPUT p-nro-conta-nova               /* par_nrdconta */
          ,INPUT i_cheque                       /* par_nrdocmto */
          ,INPUT i-cdhistor                     /* par_cdhistor */
          ,INPUT aux_nrseqdig                   /* par_nrseqdig */
          ,INPUT p-valor                        /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP53," + p-cod-liberador    /* par_cdpesqbb */
          ,INPUT 0                              /* par_vldoipmf */
          ,INPUT 0                              /* par_nrautdoc */
          ,INPUT 0                              /* par_nrsequni */
          ,INPUT crapfdc.cdbanchq               /* par_cdbanchq */
          ,INPUT 0                              /* par_cdcmpchq */
          ,INPUT crapfdc.cdagechq               /* par_cdagechq */
          ,INPUT crapfdc.nrctachq               /* par_nrctachq */
          ,INPUT 0                              /* par_nrlotchq */
          ,INPUT 0                              /* par_sqlotchq */
          ,INPUT ""                             /* par_dtrefere */
          ,INPUT ""                             /* par_hrtransa */
          ,INPUT ""                             /* par_cdoperad */
          ,INPUT ""                             /* par_dsidenti */
          ,INPUT crapcop.cdcooper               /* par_cdcooper */
          ,INPUT glb_dsdctitg                   /* par_nrdctitg */
          ,INPUT ""                             /* par_dscedent */
          ,INPUT 0                              /* par_cdcoptfn */
          ,INPUT 0                              /* par_cdagetfn */
          ,INPUT 0                              /* par_nrterfin */
          ,INPUT 0                              /* par_nrparepr */
          ,INPUT 0                              /* par_nrseqava */
          ,INPUT 0                              /* par_nraplica */
          ,INPUT 0                              /* par_cdorigem */
          ,INPUT 0                              /* par_idlautom */
          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
          ,INPUT 0                              /* Processa lote                                 */
          ,INPUT 0                              /* Tipo de lote a movimentar                     */
          /* CAMPOS DE SAÍDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
          ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
          ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
          ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
       DO:  
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
    ELSE 
       DO:
          /* 02/07/2018- Posicionando no registro da craplcm criado acima */
          FIND FIRST tt-ret-lancto.
          FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
       END.


    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

    ASSIGN p-histor = i-cdhistor.
    
    
    IF   p-aux-indevchq = 0  THEN
         DO:
             FIND FIRST craptab WHERE craptab.cdcooper = crabcop.cdcooper    AND
                                      craptab.nmsistem = "CRED"              AND
                                      craptab.tptabela = "USUARI"            AND
                                      craptab.cdempres = 11                  AND
                                      craptab.cdacesso = "MAIORESCHQ"        AND
                                      craptab.tpregist = 1
                                      NO-LOCK NO-ERROR.
     
             IF   NOT AVAIL craptab   THEN
                  ASSIGN TAB_vlchqmai = 1.
             ELSE
                  ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).
     
             IF   p-valor < tab_vlchqmai   THEN
                  ASSIGN  aux_tpdmovto = 2.
             ELSE
                  ASSIGN  aux_tpdmovto = 1.
     
    
             RUN fontes/dig_cmc7.p(INPUT  crapfdc.dsdocmc7,
                                   OUTPUT glb_nrcalcul,
                                   OUTPUT aux_lsdigctr).
     
             CREATE crapchd.
             ASSIGN crapchd.cdcooper = crapcop.cdcooper
                    crapchd.cdagechq = crapfdc.cdagechq
                    crapchd.cdagenci = p-cod-agencia
                    crapchd.cdbanchq = crapfdc.cdbanchq
                    crapchd.cdbccxlt = 11
                    crapchd.nrdolote = i-nro-lote
                    crapchd.nrdocmto = i_cheque
                    crapchd.nrseqdig = craplcm.nrseqdig
                    crapchd.cdcmpchq = crapfdc.cdcmpchq
                    crapchd.cdoperad = p-cod-operador
                    crapchd.cdsitatu = 1
                    crapchd.dsdocmc7 = crapfdc.dsdocmc7
                    crapchd.dtmvtolt = crapdat.dtmvtocd
                    crapchd.inchqcop = 1  /* Cheque da Cooperativa */
                    crapchd.insitchq = 0  
                    crapchd.cdtipchq = INTEGER(SUBSTR(crapfdc.dsdocmc7,20,1))
                    crapchd.nrcheque = p-nro-cheque 
                    crapchd.nrctachq = p-nro-conta
                    crapchd.nrdconta = aux_nrdconta
                    crapchd.nrddigv1 = INT(ENTRY(1,aux_lsdigctr))
                    crapchd.nrddigv2 = INT(ENTRY(2,aux_lsdigctr))
                    crapchd.nrddigv3 = INT(ENTRY(3,aux_lsdigctr))
                    crapchd.tpdmovto = aux_tpdmovto
                    crapchd.nrterfin = 0
                    crapchd.flgenvio = FALSE
                    crapchd.insitprv = 0
                    crapchd.vlcheque = p-valor.

             VALIDATE crapchd.
    
             /********* Comentado em 19/01/2011 *********
             RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
             RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT p-cooper,
                                                        INPUT p-cod-agencia,
                                                        INPUT p-nro-caixa,
                                                        INPUT p-cod-operador,
                                                        INPUT crapdat.dtmvtolt,
                                                        INPUT 1). /*Inclusao*/
             DELETE PROCEDURE h-b1crap00.
             ******************/
         END.  

    
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-valor,
                                           INPUT dec(p-nrdocmto),
                                           INPUT yes, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line    */         
                                           INPUT NO,   /* NÆo estorno     */
                                           INPUT p-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
   
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
  
    /* Atualiza sequencia Autenticacao */

    ASSIGN craplcm.nrautdoc = p-ult-sequencia.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.
 
    RELEASE craplcm.
    RELEASE craplot.
    RELEASE crapfdc.
   
    RETURN "OK".
END PROCEDURE.

PROCEDURE atualiza-pagto-cheque-migrado-host:
        
    DEF INPUT  PARAM p-cooper          AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nmcooper        AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE /* Cod. Agencia */       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INTE /* Numero Caixa*/        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador    AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-liberador   AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-nro-conta       AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-nro-cheque      AS INT  FORMAT "zzz,zz9" /*Chq*/ NO-UNDO.
    DEF INPUT  PARAM p-nrddigc3        AS INT  FORMAT "9" /* C3 */      NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC                           NO-UNDO.
    DEF INPUT  PARAM p-aux-indevchq    AS INT  /* Devolucao */          NO-UNDO.
    DEF INPUT  PARAM p-nrdocmto        AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-conta-atualiza  AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-cdbanchq        AS INT  FORMAT "zz9"             NO-UNDO.
    DEF INPUT  PARAM p-cdagechq        AS INT  FORMAT "zzz9"            NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-nova  AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-histor          AS INT                           NO-UNDO.
    DEF OUTPUT PARAM p-literal-r       AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r AS INT                           NO-UNDO.

    DEF VAR aux_cdbccxlt AS INTEGER                                     NO-UNDO.
    DEF VAR aux_lsdigctr AS CHAR                                        NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    
    /* cooperativa antiga */
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /* cooperativa nova */ 
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_nrdctitg = "".
    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nro-conta)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nro-conta
                    glb_cdcooper = crapcop.cdcooper.
             RUN existe_conta_integracao.  
         END.                    
    
    IF   aux_nrdctitg = " "   THEN 
         DO:

             DO   WHILE TRUE:
                  FIND crapass WHERE 
                       crapass.cdcooper = crapcop.cdcooper    AND
                       crapass.nrdconta = INT(p-nro-conta)    
                       NO-LOCK NO-ERROR.
                             
                  IF   NOT AVAIL crapass   THEN LEAVE.
                  IF   AVAIL crapass   THEN 
                       DO:
                           IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))  THEN
                                DO:
                                    FIND FIRST craptrf WHERE
                                            craptrf.cdcooper = 
                                                    crapcop.cdcooper    AND
                                            craptrf.nrdconta = 
                                                    crapass.nrdconta    AND
                                            craptrf.tptransa = 1        AND
                                            craptrf.insittrs = 2   
                                            USE-INDEX craptrf1 
                                            NO-LOCK NO-ERROR.
    
                                IF   AVAIL craptrf   THEN  
                                     ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                            aux_nrdconta = craptrf.nrsconta
                                            p-nro-conta  = craptrf.nrsconta.
                                ELSE 
                                     LEAVE.
                       END.
                  ELSE
                       LEAVE.    
             END.
         END.
/*---------------------*/                  
    END.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
 
    IF   p-cod-agencia = 0   OR
         p-nro-caixa   = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro =
                         "CAIXA perdeu PONTEIRO. REINICIE O MICRO E AVISE CPD".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
     
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.
      
    /* Validar para criar o lancamento ao fim da procedure */
    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                            crapbcx.dtmvtolt = crapdat.dtmvtocd  AND
                            crapbcx.cdagenci = p-cod-agencia     AND
                            crapbcx.nrdcaixa = p-nro-caixa       AND
                            crapbcx.cdopecxa = p-cod-operador    AND
                            crapbcx.cdsitbcx = 1
                            EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapbcx   THEN
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
    
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    IF   p-nro-conta = 978809   THEN  /* Verifica qual o historico */
         ASSIGN i-cdhistor = 26.
    ELSE
         ASSIGN i-cdhistor = 21.

    ASSIGN i_cheque = INT(STRING(p-nro-cheque,"999999") +
                          STRING(p-nrddigc3,"9")).   /* Numero do Cheque */
  
    ASSIGN aux_nrdconta = p-conta-atualiza.
    
    IF  aux_nrdconta = p-nro-conta  THEN 
        DO: 
            IF   p-cdbanchq   = crapcop.cdbcoctl  THEN
                 aux_cdbccxlt = crapcop.cdbcoctl.
            ELSE
                 aux_cdbccxlt = 756.
        END.
    ELSE 
        aux_cdbccxlt = 1.
    
    IF   p-aux-indevchq > 0  THEN  
         DO:
             RUN dbo/pcrap10.p (INPUT p-cooper,
                                INPUT crapdat.dtmvtocd,
                                INPUT aux_cdbccxlt,
                                INPUT p-aux-indevchq,
                                INPUT aux_nrdconta,
                                INPUT i_cheque,
                                INPUT p-nro-conta,
                                INPUT p-valor,
                                INPUT 0, /*codigo alinea */
                                INPUT IF (p-aux-indevchq = 1 OR
                                          p-aux-indevchq = 2)
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
             /* Criar registro no crapdev  */
    
             IF   NOT CAN-FIND(crapdev WHERE 
                               crapdev.cdcooper = crapcop.cdcooper      AND
                               crapdev.dtmvtolt = crapdat.dtmvtocd      AND
                               crapdev.nrdconta = aux_nrdconta          AND
                               crapdev.nrdctabb = inte(p-nro-conta)     AND
                               crapdev.nrcheque = i_cheque              AND
                               crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                      p-aux-indevchq = 2) 
                                                  THEN 47
                                                  ELSE 78)              THEN 
                  DO:
                      CREATE crapdev.
                      ASSIGN crapdev.dtmvtolt = crapdat.dtmvtocd
                             crapdev.cdbccxlt = aux_cdbccxlt
                             crapdev.nrdconta = aux_nrdconta
                             crapdev.nrdctabb = p-nro-conta
                             crapdev.nrcheque = i_cheque
                             crapdev.vllanmto = p-valor
                             crapdev.cdalinea = 0
                             crapdev.cdoperad = p-cod-operador
                             crapdev.cdhistor = IF (p-aux-indevchq = 1 OR 
                                                    p-aux-indevchq = 2) 
                                                THEN 47
                                                ELSE 78
                             crapdev.insitdev = 1 
                             crapdev.cdcooper = crapcop.cdcooper
                             crapdev.cdbanchq = p-cdbanchq
                             crapdev.cdagechq = p-cdagechq
                             crapdev.nrctachq = p-nro-conta.
                      VALIDATE crapdev.
                  END.              
         END.                      
    
    IF   i-cdhistor = 21  THEN 
         DO:
             ASSIGN i_nro-docto = i_cheque.
             RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,   /* Nro Cheque */
                                INPUT-OUTPUT i_nro-talao,   /* Nro Talao  */
                                INPUT-OUTPUT i_posicao,     /* Posicao    */
                                INPUT-OUTPUT i_nro-folhas). /* Nro Folhas */
                           
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
        
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                                                        
                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
                                    ASSIGN i-cod-erro = 108
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
         END.  /* Historico 21 */
    ELSE 
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
                              
             ASSIGN in99 = 0
                    glb_nrcalcul = INT(SUBSTR(STRING(i_cheque,"9999999"),1,6)).
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  
                  FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper    AND
                                     crapfdc.cdbanchq = p-cdbanchq          AND
                                     crapfdc.cdagechq = p-cdagechq          AND
                                     crapfdc.nrctachq = p-nro-conta         AND
                                     crapfdc.nrcheque = INT(glb_nrcalcul)
                                     USE-INDEX crapfdc1
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

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
    
    IF   i-cdhistor = 21 THEN   
         ASSIGN crapfdc.incheque = crapfdc.incheque + 5.
    ELSE 
         ASSIGN crapfdc.incheque = (IF crapfdc.incheque = 0 THEN 5
                                  ELSE 
                                  (IF crapfdc.incheque = 2 THEN 7
                                  ELSE 0)).
                                  
    ASSIGN crapfdc.dtliqchq = crapdat.dtmvtocd
           crapfdc.cdoperad = "1" /* SUPER-USUARIO para migracao */
           crapfdc.vlcheque = p-valor.
    
    /* Localiza se o cheque é de uma conta migrada */
    FIND FIRST craptco WHERE 
               craptco.cdcopant = crapfdc.cdcooper AND /* coop antiga  */
               craptco.nrctaant = crapfdc.nrdconta AND /* conta antiga */
               craptco.tpctatrf = 1                AND
               craptco.flgativo = TRUE
               NO-LOCK NO-ERROR.

    IF  AVAIL craptco  THEN
    DO:
        FIND craplot WHERE craplot.cdcooper = craptco.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtocd  AND
                           craplot.cdagenci = craptco.cdagenci  AND
                           craplot.cdbccxlt = 100               AND  /* Fixo */
                           craplot.nrdolote = 205000 + craptco.cdagenci 
                           EXCLUSIVE-LOCK NO-ERROR.
                           
        IF   NOT AVAIL craplot   THEN 
             DO:
                 CREATE craplot.
                 ASSIGN craplot.dtmvtolt = crapdat.dtmvtocd
                        craplot.cdagenci = craptco.cdagenci
                        craplot.cdcooper = craptco.cdcooper
                        craplot.cdbccxlt = 100
                        craplot.nrdolote = 205000 + craptco.cdagenci
                        craplot.tplotmov = 1
                        craplot.cdoperad = "1" /* SUPER-USUARIO para migracao */
                        craplot.cdhistor = 0. /* i-cdhistor */
             END.
    END.

    /*--- Verifica se Lancamento ja Existe ---*/
    FIND FIRST craplcm WHERE craplcm.cdcooper = craplot.cdcooper     AND
                             craplcm.dtmvtolt = craplot.dtmvtolt     AND
                             craplcm.cdagenci = craplot.cdagenci     AND
                             craplcm.cdbccxlt = craplot.cdbccxlt     AND
                             craplcm.nrdolote = craplot.nrdolote     AND
                             craplcm.nrseqdig = craplot.nrseqdig + 1 
                             USE-INDEX craplcm3 NO-LOCK NO-ERROR.
                             
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
          
    FIND FIRST craplcm WHERE craplcm.cdcooper = craplot.cdcooper   AND
                             craplcm.dtmvtolt = craplot.dtmvtolt   AND
                             craplcm.cdagenci = craplot.cdagenci   AND
                             craplcm.cdbccxlt = craplot.cdbccxlt   AND
                             craplcm.nrdolote = craplot.nrdolote   AND
                             craplcm.nrdctabb = INT(p-nro-conta)   AND
                             craplcm.nrdocmto = i_cheque 
                             USE-INDEX craplcm1 NO-LOCK NO-ERROR.
    
    IF   AVAIL craplcm   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento ja existente".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nro-conta,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).
    
    /* PJ450 - Regulatorio de crédito */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
        RUN sistema/generico/procedures/b1wgen0200.p 
        PERSISTENT SET h-b1wgen0200.
    
    
    /* Criar o lancamento  */
    RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
          ,INPUT craplot.cdagenci               /* par_cdagenci */
          ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
          ,INPUT craplot.nrdolote               /* par_nrdolote */
          ,INPUT p-nro-conta-nova               /* par_nrdconta */
          ,INPUT i_cheque                       /* par_nrdocmto */
          ,INPUT 521                            /* par_cdhistor */
          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
          ,INPUT p-valor                        /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP53," + p-cod-liberador    /* par_cdpesqbb */
          ,INPUT 0                              /* par_vldoipmf */
          ,INPUT 0                              /* par_nrautdoc */
          ,INPUT 0                              /* par_nrsequni */
          ,INPUT crapfdc.cdbanchq               /* par_cdbanchq */
          ,INPUT 0                              /* par_cdcmpchq */
          ,INPUT crapfdc.cdagechq               /* par_cdagechq */
          ,INPUT crapfdc.nrctachq               /* par_nrctachq */
          ,INPUT 0                              /* par_nrlotchq */
          ,INPUT 0                              /* par_sqlotchq */
          ,INPUT ""                             /* par_dtrefere */
          ,INPUT ""                             /* par_hrtransa */
          ,INPUT ""                             /* par_cdoperad */
          ,INPUT ""                             /* par_dsidenti */
          ,INPUT craplot.cdcooper               /* par_cdcooper */
          ,INPUT glb_dsdctitg                   /* par_nrdctitg */
          ,INPUT ""                             /* par_dscedent */
          ,INPUT 0                              /* par_cdcoptfn */
          ,INPUT 0                              /* par_cdagetfn */
          ,INPUT 0                              /* par_nrterfin */
          ,INPUT 0                              /* par_nrparepr */
          ,INPUT 0                              /* par_nrseqava */
          ,INPUT 0                              /* par_nraplica */
          ,INPUT 0                              /* par_cdorigem */
          ,INPUT 0                              /* par_idlautom */
          /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
          ,INPUT 0                              /* Processa lote                                 */
          ,INPUT 0                              /* Tipo de lote a movimentar                     */
          /* CAMPOS DE SAÍDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
          ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
          ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
          ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
       DO:  
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
    ELSE 
       DO:
          /* 02/07/2018- Posicionando no registro da craplcm criado acima */
          FIND FIRST tt-ret-lancto.
          FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
       END.


    IF  VALID-HANDLE(h-b1wgen0200) THEN
        DELETE PROCEDURE h-b1wgen0200.

    ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1 
           craplot.qtcompln  = craplot.qtcompln + 1
           craplot.qtinfoln  = craplot.qtinfoln + 1
           craplot.vlcompdb  = craplot.vlcompdb + p-valor
           craplot.vlinfodb  = craplot.vlinfodb + p-valor. 
 
    ASSIGN p-histor = i-cdhistor.
    
    
    IF   p-aux-indevchq = 0  THEN
         DO:
             FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                                      craptab.nmsistem = "CRED"              AND
                                      craptab.tptabela = "USUARI"            AND
                                      craptab.cdempres = 11                  AND
                                      craptab.cdacesso = "MAIORESCHQ"        AND
                                      craptab.tpregist = 1
                                      NO-LOCK NO-ERROR.
     
             IF   NOT AVAIL craptab   THEN
                  ASSIGN TAB_vlchqmai = 1.
             ELSE
                  ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).
     
             IF   p-valor < tab_vlchqmai   THEN
                  ASSIGN  aux_tpdmovto = 2.
             ELSE
                  ASSIGN  aux_tpdmovto = 1.
     
    
             RUN fontes/dig_cmc7.p(INPUT  crapfdc.dsdocmc7,
                                   OUTPUT glb_nrcalcul,
                                   OUTPUT aux_lsdigctr).
     
             CREATE crapchd.
             ASSIGN crapchd.cdcooper = crapcop.cdcooper
                    crapchd.cdagechq = crapfdc.cdagechq
                    crapchd.cdagenci = p-cod-agencia
                    crapchd.cdbanchq = crapfdc.cdbanchq
                    crapchd.cdbccxlt = 11
                    crapchd.nrdolote = i-nro-lote
                    crapchd.nrdocmto = i_cheque
                    crapchd.nrseqdig = craplcm.nrseqdig
                    crapchd.cdcmpchq = crapfdc.cdcmpchq
                    crapchd.cdoperad = p-cod-operador
                    crapchd.cdsitatu = 1
                    crapchd.dsdocmc7 = crapfdc.dsdocmc7
                    crapchd.dtmvtolt = crapdat.dtmvtocd
                    crapchd.inchqcop = 1  /* Cheque da Cooperativa */
                    crapchd.insitchq = 0
                    crapchd.cdtipchq = INTEGER(SUBSTR(crapfdc.dsdocmc7,20,1))
                    crapchd.nrcheque = p-nro-cheque
                    crapchd.nrctachq = p-nro-conta
                    crapchd.nrdconta = aux_nrdconta
                    crapchd.nrddigv1 = INT(ENTRY(1,aux_lsdigctr))
                    crapchd.nrddigv2 = INT(ENTRY(2,aux_lsdigctr))
                    crapchd.nrddigv3 = INT(ENTRY(3,aux_lsdigctr))
                    crapchd.tpdmovto = aux_tpdmovto
                    crapchd.nrterfin = 0
                    crapchd.flgenvio = FALSE
                    crapchd.insitprv = 0
                    crapchd.vlcheque = p-valor.
             VALIDATE crapchd.
    
             /********** Comentado em 19/01/2011 **********
             RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
             RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT p-cooper,
                                                        INPUT p-cod-agencia,
                                                        INPUT p-nro-caixa,
                                                        INPUT p-cod-operador,
                                                        INPUT crapdat.dtmvtolt,
                                                        INPUT 1). /*Inclusao*/
             DELETE PROCEDURE h-b1crap00.
             ***************/
         END.  

    
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-valor,
                                           INPUT dec(p-nrdocmto),
                                           INPUT yes, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line    */         
                                           INPUT NO,   /* NÆo estorno     */
                                           INPUT p-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
   
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
  
    /* Atualiza sequencia Autenticacao */

    ASSIGN craplcm.nrautdoc = p-ult-sequencia.

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           p-literal-r       = p-literal.
    
    /* Utilizado como base bcaixal.i */
    CREATE craplcx.
    ASSIGN craplcx.dtmvtolt = crapdat.dtmvtocd
           craplcx.cdagenci = p-cod-agencia
           craplcx.nrdcaixa = p-nro-caixa
           craplcx.cdopecxa = p-cod-operador
           craplcx.nrdocmto = i_cheque
           craplcx.nrseqdig = crapbcx.qtcompln + 1
           craplcx.nrdmaqui = crapbcx.nrdmaqui
           craplcx.cdhistor = 704
           craplcx.dsdcompl = "Saque da conta sobreposta " +
                              STRING(crapfdc.nrdconta,"zzzz,zzz,z")
           crapbcx.qtcompln = crapbcx.qtcompln + 1
           craplcx.vldocmto = p-valor
           craplcx.cdcooper = crapcop.cdcooper.
    VALIDATE craplcx.
    
    RELEASE craplcm.
    RELEASE craplot.
    RELEASE crapfdc.
   
    RETURN "OK".
END PROCEDURE.

/* b1crap53.p */
                                           
/* .........................................................................*/


