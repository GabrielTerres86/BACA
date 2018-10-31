/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +--------------------------------+------------------------------------------+
  | Rotina Progress                | Rotina Oracle PLSQL                      |
  +--------------------------------+------------------------------------------+
  | dbo/b1crap00.p                 | CXON0000                                 |
  |  grava-autenticacao            | CXON0000.pc_grava_autenticacao           |
  |  obtem-literal-autenticacao    | CXON0000.pc_obtem_litera_autenticacao    |
  |  grava_autenticacao_internet   | CXON0000.pc_grava_autenticacao_internet  |
  +--------------------------------+------------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ...........................................................................

   Programa: siscaixa/web/dbo/b1crap00.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 04/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Possui varias procedures uteis para todo o sistema.

   Alteracoes: 28/09/2005 - Passagem da cooperativa como parametro para as
                            procedures (Julio)
                            
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder   
               
               26/04/2007 - Usar 3 caracteres para o caixa na procedure
                            obtem-literal-autenticacao (Evandro).
                            
               23/07/2007 - Criada a procedure grava-autenticacao-internet
                            para poder gravar a autenticacao com a data que for
                            enviada via parametro (Evandro).
                            
               15/08/2007 - Alterada grava-autenticacao-internet para receber a
                            conta e titularidade para controle de erros;
                            Alterado para usar a data com crapdat.dtmvtocd
                            (Evandro).
               
               24/01/2008 - Alterado para nao permitir PAC 90 (internet) na 
                            tela de identificacao (Elton).
                            
               18/03/2008 - Tratar autenticacao guias GPS-BANCOOB (Evandro).
               
               20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).
                            
               04/01/2010 - Alterar tratamento para ultimo dia do ano (David).
               
               14/06/2010 - Tratamento para PAC 91, conforme PAC 90 (Elton).
               
               30/08/2010 - Incluido caminho completo para o destino dos 
                            arquivos de log (Elton).               
               
               20/10/2010 - Incluido caminho completo nas referencias do 
                            diretorio spool (Elton).
                            
               29/10/2010 - Incluido procedure atualiza-previa-caixa (Elton).
               
               13/07/2011 - Alteracao no formato do campo p-literal na procedure
                            obtem-literal-autenticacao (Adriano).
                          
               08/08/2011 - Acerto na procedure atualiza-previa-caixa para nao 
                            exibir mensagens de erro no log quando pagamento 
                            for com dinheiro (Elton).
                          
               30/09/2011 - Alterar diretorio spool para
                            /usr/coop/sistema/siscaixa/web/spool (Fernando).
                            
               28/11/2011 - Alteracao de ajuste do dia 13/07/2011, pois quando
                            utilizado retorno COBAN, desconfigurava a aut.
                            Colocado ',' no format do valor para formar 48 pos.
                            (Guilherme).
                            
               14/12/2011 - Continuacao da alteração acima pois RoundTable
                            nao mostrava dif de caracteres em branco(Guilherme)
                            
               08/03/2012 - Alterado a composicao da autenticacao
                             (p-literal) para autenticacoes com data
                             >= 25/04/2012, na procedure 
                             obtem-literal-autenticacao. (Fabricio)
                             
               12/04/2013 - Adicionado procedure verifica-sangria-caixa.
                            (Fabricio)
                            
               21/05/2013 - Alterações para gerar autenticação para DARFs (Lucas).
               
               22/05/2013 - Correção autenticação para DARFs (Lucas).
               
               31/05/2013 - Limpar erro na valida conta (Gabriel).
               
               10/06/2013 - Correção Buffer crapaut (Lucas).
               
               28/06/2013 - Adicionado verificacao por intervalo de tempo
                            na procedure verifica-sangria-caixa. (Fabricio)
               
               06/01/2014 - Procedure valida-agencia: Alterada a mensagem de 
                            erro "PAC..." p/ "PA não permitido". Troca de cod
                            de critica de 15 para 962.
                            Procedure obtem-literal-autenticacao: Troca de cod
                            de critica de 15 para 962. (Carlos)
                            
               08/01/2014 - Inclusao de VALIDATE crapcbl e crapaut (Carlos)
               
               24/03/2014 - Ajuste Oracle tratamento FIND LAST, FIRST das
                            tabelas crapcbl e crapaut (Daniel).
                            
               30/05/2014 - Ajuste na proc obtem-literal-autenticacao,
                            para quando b-crapaut.cdhistor = 1414 (Carlos)
                            
               16/07/2014 - Conversao de procedures atualiza-previa-caixa e
                            valida-agencia do fonte b1crap00 para
                            pc_atualiza_previa_cxa do e pc_valida_agencia
                            pacote CXON0000. (Andre Santos - SUPERO)
                            
               11/12/2014 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
               
               19/02/2015 - Ajuste na rotina grava-autenticacao, inclusão 
                           de validade apos alteração na crapcbl 
                           SD255373 (Odirlei-AMcom)
                           
               18/03/2015 - Procedure para retornar info do BL aberto
                            Melhoria SD 260475 (Lunelli).
                            
               10/03/2016 - Incluir log na grava-autenticacao-internet caso
                            ocorra algum erro na autenticacao (Lucas Ranghetti/Fabricio)
                            
               11/03/2016 - Incluir validacao na grava-autenticacao-internet para 
                            nao ler a tabela crapcbl caso for o cdagenci 90 e 91
                            (Lucas Ranghetti/Fabricio)
                            
               21/03/2016 - Incluir validacao na grava-autenticacao para 
                            nao ler a tabela crapcbl caso for o cdagenci 90 e 91
                            (Lucas Ranghetti/Fabricio)

               28/04/2016 - Acerto string autenticação GPS/1414
                            (Guilherme/SUPERO)

               10/10/2016 - Tratamento para nao chamar mais a autentica.htm 
                            quando for historico 707 nas rotinas AA e AT 
							procedure obtem-reautenticacao (Tiago/Elton SD498973)

               14/12/2016 - Ajustes para nao gravar estorno na crapaut com 
			                nrseqaut zerado pois ocasionava problemas no
							fechamento de caixa (SD535528 Tiago/Elton)
                                                        
               19/03/2018 - Alterado por causa da necessidade de abertura do 
                            caixa online mesmo não tendo terminado o processo batch (noturno)        
                            (Fabio Adriano - AMcom)
							
               13/04/2018 - Foi mudada a estratégia - criada a procedure valida-transacao2
                            para verificar a abertura do caixa online mesmo se o processo
                            batch (noturno) estiver em execução
                            (Fabio Adriano - AMcom)
                    
               17/04/2018 - Foi criada a procedure valida-transacao3
                            para verificar a abertura do caixa online mesmo 
                            e travar a abertura do programa se o processo
                            batch (noturno) estiver em execução ...
                            específico para programas que possuiam a chamada 
                            para a valida-transacao.
                            (Fabio Adriano - AMcom)
                            
               04/10/2018 - Adicionado validacao de horario minimo para 
                            login no caixa online, baseado na coluna hrinicxa
                            da CRAPCOP. SCTASK0027519 - (Mateus Z / Mouts)
                            
............................................................................ */

  
/*---------------------------------------------------------------*/
/*  b1crap00.p - Disponibilidade de Utilizacao do Sistema        */
/*---------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro    AS INTEGER.
DEF VAR c-desc-erro   AS CHAR.


DEF VAR i-dia         AS INTE                                 NO-UNDO.
DEF VAR c-dia         AS CHAR     FORMAT "X(03)" EXTENT 7     NO-UNDO.
DEF VAR c-arquivo     AS CHAR     FORMAT "x(30)"              NO-UNDO.
DEF VAR i-sequen      AS INTE                                 NO-UNDO.
DEF VAR i-seq-aut     AS INTE                                 NO-UNDO.
DEF VAR c-mes         AS CHAR     FORMAT "X(03)" EXTENT 12    NO-UNDO.
DEF VAR i-ano         AS INTE     FORMAT "9999"               NO-UNDO.
DEF VAR c-ano         AS CHAR     FORMAT "x(02)"              NO-UNDO.
def var c-pg-rc       AS CHAR     FORMAT "x(02)"              NO-UNDO.
DEF VAR c-off-line    AS CHAR     FORMAT "x(01)"              NO-UNDO.
DEF VAR dt-dia-util   AS DATE                                 NO-UNDO.

DEF VAR in99          AS INTE                                 NO-UNDO.

DEF VAR r-registro    AS ROWID                                NO-UNDO.
DEF VAR c-literal2    AS CHAR                                 NO-UNDO.

DEF VAR h-b2crap13    AS HANDLE                               NO-UNDO.

DEF BUFFER b-crapaut  FOR crapaut.

DEF TEMP-TABLE tt-crapcbl NO-UNDO LIKE crapcbl
    FIELD dsdonome LIKE crapass.nmprimtl.

ASSIGN c-dia[1] = "DOM"
       c-dia[2] = "SEG"
       c-dia[3] = "TER"
       c-dia[4] = "QUA"
       c-dia[5] = "QUI".
       c-dia[6] = "SEX".
       c-dia[7] = "SAB".

ASSIGN c-mes[1]  = "JAN"
       c-mes[2]  = "FEV"
       c-mes[3]  = "MAR"
       c-mes[4]  = "ABR"
       c-mes[5]  = "MAI"
       c-mes[6]  = "JUN"
       c-mes[7]  = "JUL"
       c-mes[8]  = "AGO"
       c-mes[9]  = "SET"
       c-mes[10] = "OUT"
       c-mes[11] = "NOV"
       c-mes[12] = "DEZ".


PROCEDURE valida-transacao:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    

    IF  SEARCH("../../arquivos/cred_bloq") <> ? THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Sistema Bloqueado ".
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
                             
    IF  NOT AVAIL crapdat THEN 
        DO:
            ASSIGN i-cod-erro  = 1
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".

        END.
    
        
    IF  crapdat.inproces <> 1  THEN 
        DO:
            ASSIGN i-cod-erro  = 138
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END. 
             
    /** --- Verifica se eh ultimo dia util do ano --- **/
    ASSIGN dt-dia-util = DATE(12,31,YEAR(TODAY)).
    
    /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
    IF  WEEKDAY(dt-dia-util) = 1  THEN
        dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
    
    /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
    IF  WEEKDAY(dt-dia-util) = 7  THEN
        dt-dia-util = DATE(12,30,YEAR(crapdat.dtmvtoan)).
       
    IF  TODAY = dt-dia-util  THEN
        DO:
            ASSIGN i-cod-erro  = 914
                   c-desc-erro = " ".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    /* Validar o horario minimo login - SCTASK0027519 */
    IF  TIME < crapcop.hrinicxa  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Login permitido a partir das " + STRING(crapcop.hrinicxa, "HH:MM") + ".".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.    
     
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
         
END PROCEDURE.


PROCEDURE valida-transacao2:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    

    IF  SEARCH("../../arquivos/cred_bloq") <> ? THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Sistema Bloqueado ".
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
                             
    IF  NOT AVAIL crapdat THEN 
        DO:
            ASSIGN i-cod-erro  = 1
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".

        END. 

    /** --- Verifica se eh ultimo dia util do ano --- **/
    ASSIGN dt-dia-util = DATE(12,31,YEAR(TODAY)).
    
    /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
    IF  WEEKDAY(dt-dia-util) = 1  THEN
        dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
    
    /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
    IF  WEEKDAY(dt-dia-util) = 7  THEN
        dt-dia-util = DATE(12,30,YEAR(crapdat.dtmvtoan)).
       
    IF  TODAY = dt-dia-util  THEN
        DO:
            ASSIGN i-cod-erro  = 914
                   c-desc-erro = " ".

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
    END. 
    
    /* Validar o horario minimo login - SCTASK0027519 */
    IF  TIME < crapcop.hrinicxa  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Login permitido a partir das " + STRING(crapcop.hrinicxa, "HH:MM") + ".".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
   
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                        
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
         
END PROCEDURE.


/*somente a validação e bloqueio do acesso ao caixa online
  para programas que não chamavam a valida-transacao*/
PROCEDURE valida-transacao3:
    DEF INPUT  PARAM p-cooper              AS CHAR.
    DEF INPUT  PARAM p-cod-agencia         AS INTE.
    DEF INPUT  PARAM p-nro-caixa           AS INTE.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
           
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
                             
    IF  NOT AVAIL crapdat THEN 
        DO:
            ASSIGN i-cod-erro  = 1
                   c-desc-erro = " ".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".

        END.
    
    /* abertura do caixa online mesmo não tendo terminado
      o processo batch (noturno) - trava a abertura do programa*/
    IF  crapdat.inproces <> 1  THEN 
        DO:
            ASSIGN i-cod-erro  = 138
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        
    /* Validar o horario minimo login - SCTASK0027519 */
    IF  TIME < crapcop.hrinicxa  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Login permitido a partir das " + STRING(crapcop.hrinicxa, "HH:MM") + ".".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.    
     
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RETURN "OK".
         
END PROCEDURE.
    
    
PROCEDURE valida-agencia:
    DEF INPUT PARAM p-cooper        AS CHAR.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper    AND
                             crapage.cdagenci = p-cod-agencia 
                             NO-LOCK NO-ERROR.
                             
    IF  NOT AVAIL crapage  THEN  
        DO:
            ASSIGN i-cod-erro  = 962
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,  
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-cod-agencia = 90 OR    /** Internet **/
        p-cod-agencia = 91 THEN  /** TAA **/
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = " ".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT "PA nao permitido.", 
                           INPUT YES).
            RETURN "NOK".
        END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE verifica-abertura-boletim:
    DEF INPUT PARAM p-cooper        AS CHAR.
    DEF INPUT PARAM p-cod-agencia   AS INTE.
    DEF INPUT PARAM p-nro-caixa     AS INTE.
    DEF INPUT PARAM p-cod-operador  AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                            crapbcx.dtmvtolt = crapdat.dtmvtocd     AND
                            crapbcx.cdagenci = p-cod-agencia        AND
                            crapbcx.nrdcaixa = p-nro-caixa          AND
                            crapbcx.cdopecxa = p-cod-operador       AND
                            crapbcx.cdsitbcx = 1            
                            NO-LOCK NO-ERROR. 

    IF  NOT AVAIL crapbcx   THEN 
        DO:
            ASSIGN i-cod-erro  = 698
                   c-desc-erro = " ".
                   
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
 
PROCEDURE grava-autenticacao:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-valor         AS DEC.
    DEF INPUT  PARAM p-docto         AS dec.
    DEF INPUT  PARAM p-operacao      AS LOG.
    DEF INPUT  PARAM p-status        AS CHAR.
    DEF INPUT  PARAM p-estorno       AS LOG. 
    DEF INPUT  PARAM p-histor        AS INTE.

    DEF INPUT  PARAM p-data-off      AS DATE.
    DEF INPUT  param p-sequen-off    AS INTE.
    DEF INPUT  PARAM p-hora-off      AS INTE.
    DEF INPUT  PARAM p-seq-aut-off   AS INTE.
    DEF OUTPUT PARAM p-literal       AS char.
    DEF OUTPUT PARAM p-sequencia     AS INTE.
    DEF OUTPUT PARAM p-registro      AS RECID.

    DEF VAR aux_nrsequen            AS INTE     NO-UNDO.
    DEF VAR aux_busca               AS CHAR     NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
      RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-data-off = ?      AND  /** Autenticacao ON-LINE **/
        p-cod-agencia <> 90 AND  /** Internet **/
        p-cod-agencia <> 91 THEN /** TAA **/ 
        DO:
            /*----           Atualiza BL         ------*/
            ASSIGN in99 = 0. 

            DO WHILE TRUE:

                ASSIGN in99 = in99 + 1.
        
                FIND crapcbl WHERE 
                     crapcbl.cdcooper = crapcop.cdcooper  AND
                     crapcbl.cdagenci = p-cod-agencia     AND
                     crapcbl.nrdcaixa = p-nro-caixa 
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapcbl THEN  
                    DO:
                        IF  LOCKED crapcbl THEN 
                            DO:
                                IF  in99 <= 10  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                    "Tabela CRAPCBL em uso ".
                                                    
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
                                CREATE crapcbl.
                                ASSIGN crapcbl.cdcooper = crapcop.cdcooper
                                       crapcbl.cdagenci = p-cod-agencia
                                       crapcbl.nrdcaixa = p-nro-caixa.
                                
                                VALIDATE crapcbl.

                                LEAVE.
                            END.
                    END.
                    
                LEAVE.
                
            END.  /* Fim do DO WHILE */

            /* --- Inicio do código alterado por Robinson --- */
            /* Inclusa a condição de verificação da id do bl  */
            IF  crapcbl.blident <> " " THEN 
                DO:
                    IF  p-operacao = YES THEN   /* PG  - Debito */
                        DO:
                            IF  p-estorno = YES  THEN 
                                DO:
                                    ASSIGN crapcbl.vlcompdb = 
                                                crapcbl.vlcompdb - p-valor.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN crapcbl.vlcompdb = 
                                                crapcbl.vlcompdb + p-valor.
                                END.
                        END.
                    ELSE                        /* RC  - Credito */
                        DO: 
                            IF  p-estorno = YES  THEN 
                                DO:
                                    ASSIGN crapcbl.vlcompcr = 
                                                crapcbl.vlcompcr - p-valor.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN crapcbl.vlcompcr = 
                                                crapcbl.vlcompcr + p-valor.
                                END.
                        END.
                    /* validade para que a informação fique
                       visivel nas outras sessoes para não causar
                       falha ao finalizar o BL*/
                      
                    VALIDATE crapcbl.
                END.
            /* --- Fim do código alterado por Robinson --- */
        END.
   
    /*---------------------------*/
    IF  p-data-off = ?  THEN  /* Autenticacao ON-LINE */
        DO:
            /* Alterado para utilizar sequence atraves do Oracle */
            
            ASSIGN aux_busca = TRIM(STRING(crapcop.cdcooper))   + ";" +
                               TRIM(STRING(p-cod-agencia))      + ";" +
                               TRIM(STRING(p-nro-caixa))        + ";" +
                               STRING(crapdat.dtmvtocd,'99/99/9999').
            
            RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPAUT"
            									,INPUT "NRSEQUEN"
            									,INPUT aux_busca
            									,INPUT "N"
            									,"").
            
            CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            		  
            ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
            					  WHEN pc_sequence_progress.pr_sequence <> ?.

            ASSIGN i-sequen = aux_nrsequen.
            
            ASSIGN p-sequencia = i-sequen.

            /* Atualiza Tabela de Autenticacoes */
            IF  p-estorno = NO THEN /* Nao Estorno */
                DO:
                    CREATE crapaut.
                    ASSIGN crapaut.cdcooper = crapcop.cdcooper
                           crapaut.cdagenci = p-cod-agencia
                           crapaut.nrdcaixa = p-nro-caixa
                           crapaut.dtmvtolt = crapdat.dtmvtocd
                           crapaut.nrsequen = i-sequen 
                           crapaut.cdopecxa = p-cod-operador
                           crapaut.hrautent = TIME
                           crapaut.vldocmto = p-valor
                           crapaut.nrdocmto = p-docto
                           crapaut.tpoperac = p-operacao
                           crapaut.cdstatus = p-status
                           crapaut.estorno  = p-estorno
                           crapaut.cdhistor = p-histor.

                    VALIDATE crapaut.
                END.
            ELSE 
                DO:       
                    /* Ultima sequencia = Autenticacao p/gravar no Estorno */
                    ASSIGN i-seq-aut = 0.
                    
                    IF  p-status      = "1"     AND  /* ON_LINE */
                        p-sequen-off <>  0      THEN /* enviado pelo 78*/
                        ASSIGN i-seq-aut = p-sequen-off.
                    ELSE 
                        DO:
                            FIND LAST crapaut WHERE 
                                      crapaut.cdcooper = crapcop.cdcooper AND
                                      crapaut.cdagenci = p-cod-agencia    AND
                                      crapaut.nrdcaixa = p-nro-caixa      AND
                                      crapaut.dtmvtolt = crapdat.dtmvtocd AND
                                      crapaut.cdhistor = p-histor         AND
                                      crapaut.nrdocmto = p-docto          AND
                                      crapaut.estorno  = NO        
                                      NO-LOCK NO-ERROR.

                            IF  AVAILABLE crapaut  THEN 
							    DO:
                                ASSIGN i-seq-aut = crapaut.nrsequen.           
                        END.
							ELSE
								DO:
									FIND LAST crapaut WHERE 
											  crapaut.cdcooper = crapcop.cdcooper AND
											  crapaut.cdagenci = p-cod-agencia    AND
											  crapaut.nrdcaixa = p-nro-caixa      AND
											  crapaut.dtmvtolt = crapdat.dtmvtocd AND
											  crapaut.cdhistor = p-histor         AND
											  crapaut.nrdocmto = DECI(SUBSTR(STRING(p-docto), 1, LENGTH(STRING(p-docto)) - 3)) AND
											  crapaut.estorno  = NO        
											  NO-LOCK NO-ERROR.
            
									IF  AVAILABLE crapaut  THEN 
										DO:
                                ASSIGN i-seq-aut = crapaut.nrsequen.           
                        END.
								END.
                        END.

                    CREATE crapaut.
                    ASSIGN crapaut.cdcooper = crapcop.cdcooper
                           crapaut.cdagenci = p-cod-agencia
                           crapaut.nrdcaixa = p-nro-caixa
                           crapaut.dtmvtolt = crapdat.dtmvtocd
                           crapaut.nrsequen = i-sequen 
                           crapaut.cdopecxa = p-cod-operador
                           crapaut.hrautent = TIME
                           crapaut.vldocmto = p-valor
                           crapaut.nrdocmto = p-docto
                           crapaut.tpoperac = p-operacao
                           crapaut.cdstatus = p-status
                           crapaut.estorno  = p-estorno
                           crapaut.nrseqaut = i-seq-aut
                           crapaut.cdhistor = p-histor.

                    VALIDATE crapaut.
                END.
        
            IF  AVAILABLE b-crapaut  THEN
                RELEASE b-crapaut NO-ERROR.
        END.        
    ELSE    /* Importacao OFF-LINE */
        DO: 
            ASSIGN in99 = 0. 

            DO WHILE TRUE:

                ASSIGN in99 = in99 + 1.
                
                FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper AND
                                   crapaut.cdagenci = p-cod-agencia    AND
                                   crapaut.nrdcaixa = p-nro-caixa      AND
                                   crapaut.dtmvtolt = p-data-off       AND
                                   crapaut.nrsequen = p-sequen-off  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                      
                IF  NOT AVAILABLE crapaut THEN  
                    DO:
                        IF  LOCKED crapaut THEN 
                            DO:
                                IF  in99 <= 10  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                    "Tabela CRAPAUT em uso ".
                                                    
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
                                CREATE crapaut.
                                ASSIGN crapaut.cdcooper = crapcop.cdcooper
                                       crapaut.cdagenci = p-cod-agencia
                                       crapaut.nrdcaixa = p-nro-caixa
                                       crapaut.dtmvtolt = p-data-off
                                       crapaut.nrsequen = p-sequen-off
                                       crapaut.cdopecxa = p-cod-operador
                                       crapaut.hrautent = p-hora-off
                                       crapaut.vldocmto = p-valor
                                       crapaut.nrdocmto = p-docto
                                       crapaut.tpoperac = p-operacao
                                       crapaut.cdstatus = p-status
                                       crapaut.estorno  = p-estorno
                                       crapaut.nrseqaut = p-seq-aut-off
                                       crapaut.cdhistor = p-histor.

                                VALIDATE crapaut.
                            END.
                    END.                
 
                LEAVE.
             
            END. /* Fim do DO WHILE TRUE */                                  
        END.

    ASSIGN c-literal2 = " ".
    
    IF  p-data-off = ?  THEN   /* Autenticacao ON-LINE */
        DO:
            /* --- Inicio do código alterado por Robinson --- */
            IF  p-cod-agencia <> 90 AND   /** Internet **/
                p-cod-agencia <> 91 THEN  /** TAA **/ 
                DO:  
            /* Inclusa a condição de verificação da id do bl  */
            IF  crapcbl.blident <> " "  THEN 
                DO:
                    ASSIGN crapaut.blidenti = crapcbl.blidenti
                           crapaut.blsldini = crapcbl.vlinicial
                           /*** Magui testes 29/05/2003
                           crapaut.bltotpag = crapcbl.vlcompcr
                           crapaut.bltotrec = crapcbl.vlcompdb
                           ******/
                           crapaut.bltotpag = crapcbl.vlcompdb
                           crapaut.bltotrec = crapcbl.vlcompcr
                           crapaut.blvalrec = crapcbl.vlinicial + 
                                              crapcbl.vlcompdb - 
                                              crapcbl.vlcompcr.
                END.
            /* --- Fim do código alterado por Robinson --- */

            ASSIGN c-literal2 = crapaut.blidenti  + " "  +
                             string(crapaut.blsldini,"zzz,zzz,zz9.99-") + " " +
                             string(crapaut.bltotpag,"zzz,zzz,zz9.99-") + " " +
                             STRING(crapaut.bltotrec,"zzz,zzz,zz9.99-") + " " +
                             string(crapaut.blvalrec,"zzz,zzz,zz9.99-").
        END.
        END.

    ASSIGN r-registro = ROWID(crapaut).

    RUN obtem-literal-autenticacao (INPUT p-cooper,
                                    INPUT r-registro,
                                   OUTPUT p-literal).

    /*--- Armazena Literal de Autenticacao na Tabela crapaut --*/
    ASSIGN crapaut.dslitera = p-literal.
           
    ASSIGN p-registro = RECID(crapaut).

    RELEASE crapaut NO-ERROR.

    IF  AVAILABLE crapcbl  THEN
        RELEASE crapcbl NO-ERROR.
    
    /*----------Gera Arquivo Texto-----*/ 
    ASSIGN i-dia =  WEEKDAY(crapdat.dtmvtocd).
    
    IF  p-cod-agencia <> 90 AND   /** Internet **/
        p-cod-agencia <> 91 THEN  /** TAA **/ 
        DO:      
    ASSIGN c-arquivo = "/usr/coop/sistema/siscaixa/web/spool/" +
                       crapcop.dsdircop + string(p-cod-agencia,"999") + 
                       string(p-nro-caixa,"999") + 
                       c-dia[i-dia] + ".txt".  /* Nome Fixo  */
 
    OUTPUT TO VALUE(c-arquivo) APPEND.
    
    PUT  p-literal  FORMAT "x(48)"
         " - " 
         c-literal2 FORMAT "x(48)"
         SKIP.
         
    OUTPUT CLOSE.
        END.
    /*------------------------------*/
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-autenticacao-offline:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-valor         AS DEC.
    DEF INPUT  PARAM p-docto         AS DEC.
    DEF INPUT  PARAM p-operacao      AS LOG.
    DEF INPUT  PARAM p-status        AS CHAR.
    DEF INPUT  PARAM p-estorno       AS LOG. 
    DEF INPUT  PARAM p-blidenti      AS CHAR.
    DEF INPUT  PARAM p-histor        AS INTE.

    DEF INPUT  PARAM p-data-off      AS DATE.
    DEF INPUT  param p-sequen-off    AS INTE.
    DEF INPUT  PARAM p-hora-off      AS INTE.
    DEF INPUT  PARAM p-seq-aut-off   AS INTE.
    DEF OUTPUT PARAM p-literal       AS char.
    DEF OUTPUT PARAM p-sequencia     AS INTE.
    DEF OUTPUT PARAM p-registro      AS RECID.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper    AND
                       crapaut.cdagenci = p-cod-agencia       AND
                       crapaut.nrdcaixa = p-nro-caixa         AND
                       crapaut.dtmvtolt = p-data-off          AND
                       crapaut.nrsequen = p-sequen-off        NO-ERROR.

    IF  NOT AVAIL  crapaut THEN 
        DO:

            CREATE crapaut.
            ASSIGN crapaut.cdcooper = crapcop.cdcooper
                   crapaut.cdagenci = p-cod-agencia
                   crapaut.nrdcaixa = p-nro-caixa
                   crapaut.dtmvtolt = p-data-off
                   crapaut.nrsequen = p-sequen-off
                   crapaut.cdopecxa = p-cod-operador
                   crapaut.hrautent = p-hora-off
                   crapaut.vldocmto = p-valor
                   crapaut.nrdocmto = p-docto
                   crapaut.tpoperac = p-operacao
                   crapaut.cdstatus = p-status
                   crapaut.estorno  = p-estorno
                   crapaut.blidenti = p-blidenti
                   crapaut.nrseqaut = p-seq-aut-off
                   crapaut.cdhistor = p-histor.

            VALIDATE crapaut.
        END.

    ASSIGN c-literal2 = " "
           r-registro = ROWID(crapaut).
    
    RUN obtem-literal-autenticacao(INPUT  p-cooper,
                                   INPUT  r-registro,
                                   OUTPUT p-literal).
  
    /*--- Armazena Literal de Autenticacao na Tabela crapaut --*/
    ASSIGN crapaut.dslitera = p-literal.
           
    ASSIGN p-registro = RECID(crapaut).

    RELEASE crapaut.

    /*----------Gera Arquivo Texto-----*/ 
    ASSIGN i-dia =  WEEKDAY(crapdat.dtmvtocd).
    
    ASSIGN c-arquivo = "/usr/coop/sistema/siscaixa/web/spool/" +
                       crapcop.dsdircop + string(p-cod-agencia,"999") + 
                       string(p-nro-caixa,"999") + 
                       c-dia[i-dia] + ".txt".  /* Nome Fixo  */
 
    OUTPUT TO VALUE(c-arquivo) APPEND.
    
    PUT  p-literal  FORMAT "x(48)"
         " - " 
         c-literal2 FORMAT "x(48)"
         SKIP.
    OUTPUT CLOSE.
    /*------------------------------*/
   
    RETURN "OK".

END PROCEDURE.
 
PROCEDURE obtem-literal-autenticacao:

    DEF INPUT  PARAM p-cooper        AS CHAR                NO-UNDO.
    DEF INPUT  PARAM p-registro      AS ROWID               NO-UNDO.
    DEF OUTPUT PARAM p-literal       AS CHAR                NO-UNDO.

    DEF VAR aux_dssigaut             AS CHARACTER           NO-UNDO.
    DEF VAR aux_nrctasic             AS CHARACTER           NO-UNDO.

    DEF VAR aux_vldocmto             AS CHARACTER           NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN p-literal = " ".

    FIND b-crapaut WHERE ROWID(b-crapaut) = p-registro NO-LOCK NO-ERROR.

    IF  AVAIL b-crapaut  THEN  
        DO:
            FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                                     crapage.cdagenci = b-crapaut.cdagenci
                                     NO-LOCK NO-ERROR.
                             
            IF  NOT AVAIL crapage  THEN  
                DO:
                    ASSIGN i-cod-erro  = 962
                           c-desc-erro = " ".
                   
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT b-crapaut.cdagenci,
                                   INPUT b-crapaut.nrdcaixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,  
                                   INPUT YES).
                    RETURN "NOK".
                END.
            
            ASSIGN i-ano = YEAR(b-crapaut.dtmvtolt)
                   c-ano = SUBSTR(STRING(i-ano,"9999"),3,2).
                   
            IF  b-crapaut.tpoperac = yes THEN 
                ASSIGN c-pg-rc = "PG".
            ELSE
                ASSIGN c-pg-rc = "RC".
        
            IF  b-crapaut.cdstatus = "2"  THEN /* off-line */
                ASSIGN c-off-line = "*".
            ELSE
                ASSIGN c-off-line = " ".

            DEF VAR c-valor AS CHAR.

            /* Guias GPS-BANCOOB */
            IF   b-crapaut.cdhistor = 582   THEN
                 ASSIGN c-valor = FILL(" ",10 - LENGTH(TRIM(
                                      STRING(b-crapaut.vldocmto,
                                             "zzz,zz9.99")))) + "*" +
                                      (TRIM(STRING(b-crapaut.vldocmto,
                                                   "zzz,zz9.99")))
                       aux_dssigaut = "CEC " + STRING(crapcop.cdagebcb,"9999").
            ELSE
                 ASSIGN c-valor = FILL(" ",14 - LENGTH(TRIM(
                                       STRING(b-crapaut.vldocmto,
                                              "zzz,zzz,zz9.99")))) + "*" +
                                       (TRIM(STRING(b-crapaut.vldocmto,
                                                    "zzz,zzz,zz9.99")))
                        aux_dssigaut = crapcop.dssigaut.
            
            IF  b-crapaut.estorno = NO THEN 
                DO:
                    /* Nao utilizar a nova sequencia para data inferior a data 
                       da liberacao do projeto de padronizacao da autenticacao,
                       autenticacao dos pac 90 e 91 e de guias GPS */
                    IF  b-crapaut.dtmvtolt < 04/25/2012  OR
                        b-crapaut.cdhistor = 582         OR
                        b-crapaut.cdagenci = 90          OR   /* Internet */
                        b-crapaut.cdagenci = 91          THEN /* TAA */
                        ASSIGN p-literal =  aux_dssigaut                       +
                                " " + STRING(b-crapaut.nrsequen,"99999") + " " +
                                 STRING(DAY(b-crapaut.dtmvtolt),"99")          +    
                                 c-mes[MONTH(b-crapaut.dtmvtolt)]              +
                                 c-ano                                         +
                                 "      "                                      +
                                 c-valor                                       + 
                                 c-pg-rc                                       + 
                                 c-off-line                                    +
                                 STRING(b-crapaut.nrdcaixa,"z99")              + 
                                 STRING(b-crapaut.cdagenci,"999").
                    ELSE
                    IF  b-crapaut.dsobserv <> "" THEN /* DARF */
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempres = b-crapaut.dsobserv
                                                                NO-LOCK NO-ERROR NO-WAIT.

                            IF  AVAIL crapscn THEN
                                DO:
                                    /* CAIXA */
                                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                                             crapstn.tpmeiarr = "C" 
                                                             NO-LOCK NO-ERROR NO-WAIT.
        
                                    IF  NOT AVAIL crapstn THEN
                                        DO:
                                            ASSIGN i-cod-erro  = 0
                                                   c-desc-erro = "Transacao para pagamento nao cadastrada.".
                                                   
                                            RUN cria-erro (INPUT p-cooper,
                                                           INPUT b-crapaut.cdagenci,
                                                           INPUT b-crapaut.nrdcaixa,
                                                           INPUT i-cod-erro,
                                                           INPUT c-desc-erro,
                                                           INPUT YES).
                                            RETURN "NOK".
                                        END.
        
                                    ASSIGN p-literal = "BCS"                                       +
                                                       "00089-2 "                                  +
                                                       STRING(crapcop.cdagesic, "9999")            + " " +
                                                       STRING(b-crapaut.nrdcaixa, "999")           + " " +
                                                       STRING(b-crapaut.nrsequen, "99999")         + " " +
                                                       "********"                                  +
                                                       STRING(b-crapaut.vldocmto,"z,zzz,zz9.99")   +
                                                       "RR     "                                   + " " +
                                                       STRING(b-crapaut.dtmvtolt, "99/99/9999")    + " " +
                                                       "* *****-*"                                 + " " +
                                                       STRING(crapstn.cdtransa, "999")             + " " +
                                                       STRING(crapscn.dssigemp, "999999999").
                                END.
                            
                        END.
                    /* else cdhistor (p-histor) = 1414 ... 
                    conforme documento gps - sicredi - 08/07/2013 */
                    ELSE IF b-crapaut.cdhistor = 1414 THEN 
                        DO:
                            ASSIGN aux_nrctasic = FILL("0", 6 - LENGTH(STRING(crapcop.nrctasic))) + 
                                                  STRING(crapcop.nrctasic).

                            ASSIGN aux_vldocmto = TRIM(STRING(b-crapaut.vldocmto, "zzz,zzz,zz9.99")).

                            ASSIGN p-literal = "CCR"                                       +
                                               STRING(aux_nrctasic, "99999-9")             + " " +
                                               STRING(b-crapaut.nrdcaixa, "999")           + " " +
                                               STRING(b-crapaut.nrsequen, "9999")          + " " + /* 20 */
                                               STRING(b-crapaut.dtmvtolt, "99/99/9999")    + " " + /* 30 */
                                               FILL("*", 23 - LENGTH(aux_vldocmto))        + 
                                               aux_vldocmto                                +
                                               "RC      "                                  + /* 49 */
                                               "GPS/INSS IDENT " +
                                               STRING(b-crapaut.nrdocmto,"99999999999999").

                        END.
                    ELSE
                        ASSIGN p-literal = STRING(crapcop.cdbcoctl, "999")  +
                                           STRING(crapcop.cdagectl, "9999") +
                                           STRING(crapage.cdagenci, "999")  +
                                           STRING(b-crapaut.nrdcaixa, "99") +
                                           " "                              +
                                        STRING(b-crapaut.nrsequen, "99999") +
                                           " "                              +
                                       STRING(DAY(b-crapaut.dtmvtolt),"99") +
                                    STRING(MONTH(b-crapaut.dtmvtolt), "99") +
                                           c-ano                            +
                                           "     "                          +
                                           c-off-line                       +
                                           c-valor                          +
                                           c-pg-rc.
                END.           
            ELSE 
                DO:
                    /* Nao utilizar a nova sequencia para data inferior a data 
                       da liberacao do projeto de padronizacao da autenticacao,
                       autenticacao dos pac 90 e 91 e de guias GPS */
                    IF  b-crapaut.dtmvtolt < 04/25/2012  OR  
                        b-crapaut.cdhistor = 582         OR
                        b-crapaut.cdagenci = 90          OR   /* Internet */
                        b-crapaut.cdagenci = 91          THEN /* TAA */
                        ASSIGN p-literal =  aux_dssigaut                       +
                                " " + STRING(b-crapaut.nrsequen,"99999") + " " +
                                STRING(DAY(b-crapaut.dtmvtolt),"99")           +    
                                c-mes[MONTH(b-crapaut.dtmvtolt)]               +
                                c-ano                                          +
                                "-E"                                           + 
                                STRING(b-crapaut.nrseqau,"99999")              +
                                " "                                            +
                                STRING(b-crapaut.vldocmto,"zzz,zzz,zz9.99")    +
                                c-pg-rc                                        + 
                                c-off-line                                     +
                                STRING(b-crapaut.nrdcaixa,"z99")               + 
                                STRING(b-crapaut.cdagenci,"999").
                    ELSE
                        ASSIGN p-literal = STRING(crapcop.cdbcoctl, "999")    +
                                             STRING(crapcop.cdagectl, "9999") +
                                             STRING(crapage.cdagenci, "999")  +
                                             STRING(b-crapaut.nrdcaixa, "99") +
                                             " "                              +
                                          STRING(b-crapaut.nrsequen, "99999") +
                                             " "                              +
                                         STRING(DAY(b-crapaut.dtmvtolt),"99") +
                                      STRING(MONTH(b-crapaut.dtmvtolt), "99") +
                                             c-ano                            +
                                             "E"                              +
                                          STRING(b-crapaut.nrseqaut, "99999") +
                                             c-off-line                       +
                                            STRING(b-crapaut.vldocmto, 
                                                            "zzz,zzz,zz9.99") +
                                             c-pg-rc.

                END.
        END. /* avail b-crapaut */
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE obtem-reautenticacao:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-sequencia     AS INTE.
    DEF INPUT  PARAM p-data-inf      AS INTE.
    DEF OUTPUT PARAM p-ctrmovto      AS INTE.
    DEF OUTPUT PARAM p-nrdolote      AS INTE.
    DEF OUTPUT PARAM p-nrdocmto      AS INTE.
    DEF OUTPUT PARAM p-literal       AS CHAR.
    DEF OUTPUT PARAM p-recibo        AS LOG.

    DEF VAR da-data-inf AS CHAR FORMAT "x(08)" NO-UNDO.
    DEF VAR da-data     AS DATE                NO-UNDO.
    DEF VAR aux_dia     AS INTE                NO-UNDO.
    DEF VAR aux_mes     AS INTE                NO-UNDO.
    DEF VAR aux_ano     AS INTE                NO-UNDO.
    DEF VAR i-ano-bi    AS INTE                NO-UNDO.
    
    DEF BUFFER crablcm FOR craplcm.
    DEF BUFFER crabcme FOR crapcme.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN da-data-inf = STRING(p-data-inf,"99999999").

    ASSIGN aux_dia = INT(SUBSTR(da-data-inf,1,2))
           aux_mes = INT(SUBSTR(da-data-inf,3,2))
           aux_ano = INT(SUBSTR(da-data-inf,5,4)).

    IF  p-data-inf <> 0 THEN    /* DDMMAAAA */
        DO:
            IF  aux_dia  = 0    OR         /* Dia */
                aux_dia  > 31   THEN 
                DO:
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                           
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
           
            IF (aux_mes = 4     OR
                aux_mes = 6     OR
                aux_mes = 9     OR
                aux_mes = 11)   AND
               (aux_dia > 30)   THEN 
                DO:
            
                    ASSIGN i-cod-erro  = 13 /* Data errada */
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
        
            IF  aux_mes = 2 THEN 
                DO:
        
                    ASSIGN i-ano-bi = aux_ano / 4.
                    IF  i-ano-bi * 4 <> aux_ano THEN 
                        DO:
                            IF  aux_dia > 28 THEN 
                                DO:
                                    ASSIGN i-cod-erro  = 13 /* Data errada */
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
                        DO:    /* Ano Bissexto. */

                            IF  aux_dia > 29 THEN 
                                DO:
                                    ASSIGN i-cod-erro  = 13 /* Data errada */
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
        
            IF  aux_mes > 12    OR       /* Mes */
                aux_mes = 0     THEN 
                DO:
                    ASSIGN i-cod-erro  = 13 /* Data errada */
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
    
    IF  p-data-inf = 0 THEN
        ASSIGN da-data = crapdat.dtmvtocd.
    ELSE
        ASSIGN da-data = DATE(aux_mes,aux_dia,aux_ano). 
    
    IF  p-data-inf <> 0                 AND
        da-data    >= crapdat.dtmvtocd  THEN 
        DO:

            ASSIGN i-cod-erro  = 13 /* Data errada */
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.  
    
    ASSIGN p-recibo =  NO.

    FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper    AND
                       crapaut.cdagenci = p-cod-agencia       AND 
                       crapaut.nrdcaixa = p-nro-caixa         AND 
                       crapaut.dtmvtolt = da-data             AND 
                       crapaut.nrsequen = p-sequencia 
                       NO-LOCK NO-ERROR.
    IF  AVAIL crapaut THEN
        DO:
            ASSIGN p-literal = crapaut.dslitera.
            IF  length(p-literal) >= 150  THEN
                ASSIGN p-recibo    = yes.
        END.
    ELSE
        DO:
            ASSIGN p-literal   = ""
                   i-cod-erro  = 0
                   c-desc-erro = "Sequencia nao encontrada".
                   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Tratamento para nao chamar mais a autentica.htm 
       quando for historico 707 nas rotinas AA e AT */
    IF  crapaut.cdhistor = 707 THEN
        DO:
            ASSIGN p-literal   = ""
                   i-cod-erro  = 0
                   c-desc-erro = "Comprovante do pagamento disponível apenas no Gerenciador Financeiro.".
    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.


    ASSIGN p-ctrmovto = 0.
    
    FOR EACH crablcm WHERE crablcm.cdcooper = crapcop.cdcooper  AND
                           crablcm.dtmvtolt = da-data           AND
                           crablcm.cdagenci = p-cod-agencia     AND
                           crablcm.cdbccxlt = 11                AND
                           crablcm.nrautdoc = p-sequencia       
                           USE-INDEX craplcm3 NO-LOCK:
                           
        FIND crabcme WHERE crabcme.cdcooper = crapcop.cdcooper  AND
                           crabcme.dtmvtolt = crablcm.dtmvtolt  AND
                           crabcme.cdagenci = crablcm.cdagenci  AND
                           crabcme.cdbccxlt = crablcm.cdbccxlt  AND
                           crabcme.nrdolote = crablcm.nrdolote  AND
                           crabcme.nrdocmto = crablcm.nrdocmto   
                           NO-LOCK NO-ERROR.
                           
        IF   AVAILABLE crabcme   THEN
             DO:
                 ASSIGN p-ctrmovto = crabcme.tpoperac
                        p-nrdolote = crabcme.nrdolote
                        p-nrdocmto = crabcme.nrdocmto.
             END.      
    END.
    IF  p-data-inf <> 0 THEN  /* Log autenticacao Dias Anteriores... */
        DO:
            UNIX SILENT VALUE("echo " + 
                 STRING(crapdat.dtmvtocd,"99/99/9999") + " " +
                 STRING(TIME,"HH:MM:SS") + " ' ---> '"  +
                 " Operador " + p-cod-operador +
                 " Reautenticou Sequencia " + STRING(p-sequencia) +
                 " da Data " + STRING(p-data-inf) + 
                 " do PAC " +  STRING(p-cod-agencia) +
                 " do Caixa " + STRING(p-nro-caixa) +
                 " >> /usr/coop/" + TRIM(crapcop.dsdircop) + 
                 "/log/reautentica.log").
        END.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE critica-controle:

   DEF INPUT PARAM p-cooper        AS CHAR.
   DEF INPUT PARAM p-cod-agencia   AS INTE.
   DEF INPUT PARAM p-nro-caixa     AS INTE.
   DEF INPUT PARAM p-doctoinf      AS INTE.
   DEF INPUT PARAM p-doctoimp      AS INTE.

   FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
   
   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa).

   IF   p-doctoinf <> p-doctoimp   THEN
        DO:
            ASSIGN i-cod-erro  = 22
                   c-desc-erro = "".
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

PROCEDURE valida-conta:

  DEF INPUT  PARAM p-cooper        AS CHAR.
  DEF INPUT  PARAM p-cod-agencia   AS INTE.
  DEF INPUT  PARAM p-nro-caixa     AS INTE.
  DEF INPUT  PARAM p-nrdconta      AS INTE.
  DEF OUTPUT PARAM p-nmprimtl      AS CHAR.

  FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

  FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                     crapass.nrdconta = p-nrdconta          NO-LOCK NO-ERROR.

  RUN elimina-erro (INPUT p-cooper,
                    INPUT p-cod-agencia,
                    INPUT p-nro-caixa).

  IF  NOT AVAILABLE crapass THEN
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
     
  ASSIGN p-nmprimtl = crapass.nmprimtl.
  
  IF  crapass.dtelimin <> ? THEN 
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

  IF  crapass.dtdemiss <> ? THEN 
      DO:
          ASSIGN i-cod-erro  = 75
                 c-desc-erro = " ".
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


PROCEDURE grava-autenticacao-internet:
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-nrdconta      AS INTE.
    DEF INPUT  PARAM p-idseqttl      LIKE crapttl.idseqttl.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-valor         AS DEC.
    DEF INPUT  PARAM p-docto         AS dec.
    DEF INPUT  PARAM p-operacao      AS LOG.
    DEF INPUT  PARAM p-status        AS CHAR.
    DEF INPUT  PARAM p-estorno       AS LOG. 
    DEF INPUT  PARAM p-histor        AS INTE.

    DEF INPUT  PARAM p-data-off      AS DATE.
    DEF INPUT  param p-sequen-off    AS INTE.
    DEF INPUT  PARAM p-hora-off      AS INTE.
    DEF INPUT  PARAM p-seq-aut-off   AS INTE.
    DEF INPUT  PARAM p-cdempres      AS CHAR.

    DEF OUTPUT PARAM p-literal       AS char.
    DEF OUTPUT PARAM p-sequencia     AS INTE.
    DEF OUTPUT PARAM p-registro      AS RECID.

    DEFINE  VARIABLE aux_nrdcaixa    LIKE crapaut.nrdcaixa            NO-UNDO.

    DEF VAR aux_ponteiro            AS INTE                           NO-UNDO.
    DEF VAR aux_nrsequen            AS INTE                           NO-UNDO.
    DEF VAR aux_busca               AS CHAR                           NO-UNDO.   
    
    DEF VAR aux_flgerlog            AS CHAR                           NO-UNDO.
	  DEF VAR aux_des_log             AS CHAR                           NO-UNDO.
                                                                     
    DEF VAR h-b1wgen0153            AS HANDLE                         NO-UNDO.
    
    /* Tratamento de erros para internet */
    IF   p-cod-agencia = 90   OR    /** Internet **/
         p-cod-agencia = 91   THEN  /** TAA **/
         aux_nrdcaixa = INT(STRING(p-nrdconta) + STRING(p-idseqttl)).
    ELSE
         aux_nrdcaixa = p-nro-caixa.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT aux_nrdcaixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-data-off = ?      AND   /* Autenticacao ON-LINE */
        p-cod-agencia <> 90 AND   /** Internet **/
        p-cod-agencia <> 91 THEN  /** TAA **/ 
        DO:
            /*----           Atualiza BL         ------*/
            ASSIGN in99 = 0. 

            DO WHILE TRUE:

                ASSIGN in99 = in99 + 1.
        
                FIND crapcbl WHERE 
                     crapcbl.cdcooper = crapcop.cdcooper  AND
                     crapcbl.cdagenci = p-cod-agencia     AND
                     crapcbl.nrdcaixa = p-nro-caixa 
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapcbl THEN  
                    DO:
                        IF  LOCKED crapcbl THEN 
                            DO:
                                IF  in99 <= 10  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                    "Tabela CRAPCBL em uso ".
                                                    
                                        RUN sistema/generico/procedures/b1wgen0153.p 
                                            PERSISTENT SET h-b1wgen0153.
                                    
                                        /* Gerar log */       
                                        ASSIGN aux_des_log  = "Nao achou crapcbl -> " +
                                                              "cdcooper: " +  string(crapcop.cdcooper) + " " +
                                                              "dtmvtolt: " +  string(TODAY,"99/99/9999") + " " +
                                                              "cdagenci: " +  string(p-cod-agencia)     + " " +
                                                              "nrdconta: " +  STRING(p-nrdconta) + " " +
                                                              "nrdcaixa: " +  STRING(p-nro-caixa)+ " " +
                                                              "Valor: "    +  STRING(p-valor) + " " +
                                                              "operacao: " +  STRING(p-operacao,"DEB/CRE") + " " +
                                                              "nrsequen: " +  STRING(p-sequen-off) + " " +
                                                              "critica: " + c-desc-erro + " " +
                                                              "rotina: b1crap00.grava-autenticacao-internet ".

                                        RUN gera_log_lote_uso IN h-b1wgen0153
                                                            ( INPUT crapcop.cdcooper,
                                                              INPUT p-nrdconta,
                                                              INPUT 0, /* lote */
                                                              INPUT-OUTPUT aux_flgerlog,
                                                              INPUT aux_des_log).	            
                                                
                                        IF  VALID-HANDLE(h-b1wgen0153) THEN
                                            DELETE PROCEDURE h-b1wgen0153.
                                            
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT aux_nrdcaixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END.
                            END.
                        ELSE 
                            DO:
                                CREATE crapcbl.
                                ASSIGN crapcbl.cdcooper = crapcop.cdcooper
                                       crapcbl.cdagenci = p-cod-agencia
                                       crapcbl.nrdcaixa = p-nro-caixa.

                                VALIDATE crapcbl.

                                LEAVE.
                            END.
                    END.
                    
                LEAVE.
                
            END.  /*  DO WHILE */

            /* --- Inicio do código alterado por Robinson --- */
            /* Inclusa a condição de verificação da id do bl  */
            IF  crapcbl.blident <> " " THEN 
                DO:
                    IF  p-operacao = YES THEN   /* PG  - Debito */
                        DO:
                            IF  p-estorno = YES  THEN 
                                DO:
                                    ASSIGN crapcbl.vlcompdb = 
                                                crapcbl.vlcompdb - p-valor.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN crapcbl.vlcompdb = 
                                                crapcbl.vlcompdb + p-valor.
                                END.
                        END.
                    ELSE                        /* RC  - Credito */
                        DO: 
                            IF  p-estorno = YES  THEN 
                                DO:
                                    ASSIGN crapcbl.vlcompcr = 
                                                crapcbl.vlcompcr - p-valor.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN crapcbl.vlcompcr = 
                                                crapcbl.vlcompcr + p-valor.
                                END.
                        END.
                END.
            /* --- Fim do código alterado por Robinson --- */
        END.
   
    /*---------------------------*/
    IF  p-data-off = ?  THEN  /* Autenticacao ON-LINE */
        DO: /* Alterado para utilizar sequence atraves do Oracle */
            
            ASSIGN aux_busca = TRIM(STRING(crapcop.cdcooper))   + ";" +
                               TRIM(STRING(p-cod-agencia))      + ";" +
                               TRIM(STRING(p-nro-caixa))        + ";" +
                               STRING(crapdat.dtmvtocd,'99/99/9999').
            
            RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPAUT"
            									,INPUT "NRSEQUEN"
            									,INPUT aux_busca
            									,INPUT "N"
            									,"").
            
            CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            		  
            ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
            					  WHEN pc_sequence_progress.pr_sequence <> ?.
            
            ASSIGN i-sequen = aux_nrsequen.

            ASSIGN p-sequencia = i-sequen.

            /* Atualiza Tabela de Autenticacoes */
            IF  p-estorno = NO THEN /* Nao Estorno */
                DO:
                    CREATE crapaut.
                    ASSIGN crapaut.cdcooper = crapcop.cdcooper
                           crapaut.cdagenci = p-cod-agencia
                           crapaut.nrdcaixa = p-nro-caixa
                           crapaut.dtmvtolt = crapdat.dtmvtocd
                           crapaut.nrsequen = i-sequen 
                           crapaut.cdopecxa = p-cod-operador
                           crapaut.hrautent = TIME
                           crapaut.vldocmto = p-valor
                           crapaut.nrdocmto = p-docto
                           crapaut.tpoperac = p-operacao
                           crapaut.cdstatus = p-status
                           crapaut.estorno  = p-estorno
                           crapaut.cdhistor = p-histor.

                    IF  p-cdempres <> ""  THEN /* DARF */
                        ASSIGN crapaut.dsobserv = p-cdempres.

                    VALIDATE crapaut.

                END.
            ELSE 
                DO:        
                    /* Ultima sequencia = Autenticacao p/gravar no Estorno */
                    ASSIGN i-seq-aut = 0.
                    
                    IF  p-status      = "1"     AND  /* ON_LINE */
                        p-sequen-off <>  0      THEN /* enviado pelo 78*/
                        ASSIGN i-seq-aut = p-sequen-off.
                    ELSE 
                        DO:
                            FIND LAST crapaut WHERE 
                                      crapaut.cdcooper = crapcop.cdcooper AND
                                      crapaut.cdagenci = p-cod-agencia    AND
                                      crapaut.nrdcaixa = p-nro-caixa      AND
                                      crapaut.dtmvtolt = crapdat.dtmvtocd AND
                                      crapaut.cdhistor = p-histor         AND
                                      crapaut.nrdocmto = p-docto          AND
                                      crapaut.estorno  = NO        
                                      NO-LOCK NO-ERROR.

                            IF  AVAILABLE crapaut  THEN 
                                ASSIGN i-seq-aut = crapaut.nrsequen.           
                        END.
            
                    CREATE crapaut.
                    ASSIGN crapaut.cdcooper = crapcop.cdcooper
                           crapaut.cdagenci = p-cod-agencia
                           crapaut.nrdcaixa = p-nro-caixa
                           crapaut.dtmvtolt = crapdat.dtmvtocd
                           crapaut.nrsequen = i-sequen
                           crapaut.cdopecxa = p-cod-operador
                           crapaut.hrautent = TIME
                           crapaut.vldocmto = p-valor
                           crapaut.nrdocmto = p-docto
                           crapaut.tpoperac = p-operacao
                           crapaut.cdstatus = p-status
                           crapaut.estorno  = p-estorno
                           crapaut.nrseqaut = i-seq-aut
                           crapaut.cdhistor = p-histor.

                    VALIDATE crapaut.
                END.
                
                IF  AVAILABLE b-crapaut  THEN
                    RELEASE b-crapaut NO-ERROR. 
        END.          

    ELSE    /* Importacao OFF-LINE */
        DO:          
            ASSIGN in99 = 0. 

            DO WHILE TRUE:

                ASSIGN in99 = in99 + 1.
                
                FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper AND
                                   crapaut.cdagenci = p-cod-agencia    AND
                                   crapaut.nrdcaixa = p-nro-caixa      AND
                                   crapaut.dtmvtolt = p-data-off       AND
                                   crapaut.nrsequen = p-sequen-off  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                      
                IF  NOT AVAILABLE crapaut THEN  
                    DO:
                        IF  LOCKED crapaut THEN 
                            DO:
                                IF  in99 <= 10  THEN 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE 
                                    DO:
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = 
                                                    "Tabela CRAPAUT em uso ".
                                                    
                                        RUN sistema/generico/procedures/b1wgen0153.p 
                                            PERSISTENT SET h-b1wgen0153.
                                    
                                        /* Gerar log */       
                                        ASSIGN aux_des_log  = "Nao achou crapaut -> " +
                                                              "cdcooper: " +  string(crapcop.cdcooper) + " " +
                                                              "dtmvtolt: " +  string(TODAY,"99/99/9999") + " " +
                                                              "cdagenci: " +  string(p-cod-agencia)     + " " +
                                                              "nrdconta: " +  STRING(p-nrdconta) + " " +
                                                              "nrdcaixa: " +  STRING(p-nro-caixa)+ " " +
                                                              "Valor: "    +  STRING(p-valor) + " " +
                                                              "operacao: " +  STRING(p-operacao,"DEB/CRE") + " " +
                                                              "nrsequen: " +  STRING(p-sequen-off) + " " +
                                                              "critica: " + c-desc-erro + " " +
                                                              "rotina: b1crap00.grava-autenticacao-internet ".

                                        RUN gera_log_lote_uso IN h-b1wgen0153
                                                            ( INPUT crapcop.cdcooper,
                                                              INPUT p-nrdconta,
                                                              INPUT 0, /* lote */
                                                              INPUT-OUTPUT aux_flgerlog,
                                                              INPUT aux_des_log).	            
                                                
                                        IF  VALID-HANDLE(h-b1wgen0153) THEN
                                            DELETE PROCEDURE h-b1wgen0153.
                                                    
                                        RUN cria-erro (INPUT p-cooper,
                                                       INPUT p-cod-agencia,
                                                       INPUT aux_nrdcaixa,
                                                       INPUT i-cod-erro,
                                                       INPUT c-desc-erro,
                                                       INPUT YES).
                                        RETURN "NOK".
                                    END.
                            END.
                        ELSE  
                            DO:
                                CREATE crapaut.
                                ASSIGN crapaut.cdcooper = crapcop.cdcooper
                                       crapaut.cdagenci = p-cod-agencia
                                       crapaut.nrdcaixa = p-nro-caixa
                                       crapaut.dtmvtolt = p-data-off
                                       crapaut.nrsequen = p-sequen-off
                                       crapaut.cdopecxa = p-cod-operador
                                       crapaut.hrautent = p-hora-off
                                       crapaut.vldocmto = p-valor
                                       crapaut.nrdocmto = p-docto
                                       crapaut.tpoperac = p-operacao
                                       crapaut.cdstatus = p-status
                                       crapaut.estorno  = p-estorno
                                       crapaut.nrseqaut = p-seq-aut-off
                                       crapaut.cdhistor = p-histor.

                                VALIDATE crapaut.
                            END.
                    END.                
 
                LEAVE.
             
            END. /* Fim do DO WHILE TRUE */           
        END.

    ASSIGN c-literal2 = " ".
    
    IF  p-data-off = ?  THEN   /* Autenticacao ON-LINE */
        DO:
            /* --- Inicio do código alterado por Robinson --- */
            IF  p-cod-agencia <> 90 AND   /** Internet **/
                p-cod-agencia <> 91 THEN  /** TAA **/ 
                DO:  
            /* Inclusa a condição de verificação da id do bl  */
            IF  crapcbl.blident <> " " THEN 
                DO:
                    ASSIGN crapaut.blidenti = crapcbl.blidenti
                           crapaut.blsldini = crapcbl.vlinicial
                           /*** Magui testes 29/05/2003
                           crapaut.bltotpag = crapcbl.vlcompcr
                           crapaut.bltotrec = crapcbl.vlcompdb
                           ******/
                           crapaut.bltotpag = crapcbl.vlcompdb
                           crapaut.bltotrec = crapcbl.vlcompcr
                           crapaut.blvalrec = crapcbl.vlinicial + 
                                              crapcbl.vlcompdb - 
                                              crapcbl.vlcompcr.
                END.
            /* --- Fim do código alterado por Robinson --- */

            ASSIGN c-literal2 = crapaut.blidenti  + " "  +
                             string(crapaut.blsldini,"zzz,zzz,zz9.99-") + " " +
                             string(crapaut.bltotpag,"zzz,zzz,zz9.99-") + " " +
                             STRING(crapaut.bltotrec,"zzz,zzz,zz9.99-") + " " +
                             string(crapaut.blvalrec,"zzz,zzz,zz9.99-").
        END.
        END.

    ASSIGN r-registro = ROWID(crapaut).

    RUN obtem-literal-autenticacao (INPUT p-cooper,
                                    INPUT r-registro,
                                   OUTPUT p-literal).
  
    /*--- Armazena Literal de Autenticacao na Tabela crapaut --*/
    ASSIGN crapaut.dslitera = p-literal.
           
    ASSIGN p-registro = RECID(crapaut).

    RELEASE crapaut NO-ERROR.

    IF  AVAILABLE crapcbl THEN
        RELEASE crapcbl NO-ERROR.
    
    /*----------Gera Arquivo Texto-----*/ 
    ASSIGN i-dia =  WEEKDAY(crapdat.dtmvtocd).
    
    IF  p-cod-agencia <> 90 AND   /** Internet **/
        p-cod-agencia <> 91 THEN  /** TAA **/ 
        DO:
    ASSIGN c-arquivo = "/usr/coop/sistema/siscaixa/web/spool/" +
                       crapcop.dsdircop +   string(p-cod-agencia,"999") + 
                       string(p-nro-caixa,"999") + 
                       c-dia[i-dia] + ".txt".  /* Nome Fixo  */
 
    OUTPUT TO VALUE(c-arquivo) APPEND.
    
    PUT  p-literal  FORMAT "x(48)"
         " - " 
         c-literal2 FORMAT "x(48)"
         SKIP.
         
    OUTPUT CLOSE.
        END.
        
    /*------------------------------*/
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE atualiza-previa-caixa:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-dtmvtolt      AS DATE.
    DEF INPUT  PARAM p-operacao      AS INTE.
                                    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
 
    FIND LAST  crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                             crapbcx.cdagenci = p-cod-agencia     AND
                             crapbcx.nrdcaixa = p-nro-caixa       AND
                             crapbcx.cdopecxa = p-cod-operador    AND
                             crapbcx.dtmvtolt = p-dtmvtolt 
                             EXCLUSIVE-LOCK NO-ERROR.
    
    IF  AVAIL crapbcx THEN
        DO: 
            IF  p-operacao = 1  THEN   /** Inclusão **/
                crapbcx.qtchqprv = crapbcx.qtchqprv + 1.
            ELSE                        
            IF  p-operacao = 2 THEN    /** Estorno **/
                crapbcx.qtchqprv = crapbcx.qtchqprv - 1.
            ELSE  /** 3 - Consulta **/
            DO:  
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                                   craptab.nmsistem = "CRED"             AND
                                   craptab.tptabela = "GENERI"           AND
                                   craptab.cdempres = 0                  AND
                                   craptab.cdacesso = "EXETRUNCAGEM"     AND
                                   craptab.tpregist = p-cod-agencia    NO-LOCK NO-ERROR.
                
                IF  NOT AVAIL craptab OR craptab.dstextab = "NAO" THEN
                    RETURN "OK".
                ELSE
                    DO:    
                        RUN valida-agencia (INPUT p-cooper, 
                                            INPUT p-cod-agencia, 
                                            INPUT p-nro-caixa).
                        
                        IF  crapbcx.qtchqprv > crapage.qtchqprv THEN
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Fazer previa dos cheques.".
                                            
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

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-sangria-caixa:

    DEF INPUT PARAM p-cooper       AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-nro-caixa    AS INTE.
    DEF INPUT PARAM p-cod-operador AS CHAR.

    DEF VAR v-saldo-caixa   AS DECI.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper AND
                            crapbcx.dtmvtolt = crapdat.dtmvtocd AND
                            crapbcx.cdagenci = p-cod-agencia    AND
                            crapbcx.nrdcaixa = p-nro-caixa      AND
                            crapbcx.cdopecxa = p-cod-operador   AND
                            crapbcx.cdsitbcx = 1            
                            NO-LOCK NO-ERROR.

    IF NOT AVAIL crapbcx THEN
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

    /* verifica se a flag de caixa ativo esta como TRUE */
    IF crapbcx.flgcxsgr THEN
    DO:
        /* se o caixa esta ativo, entao verifica se ja atingiu o intervalo de
           tempo para a verificacao da sangria de caixa */
        IF (TIME - crapbcx.hrultsgr) >= (crapcop.qttmpsgr)  THEN
        DO:
            RUN verifica-saldo-caixa (INPUT crapcop.cdcooper,
                                      INPUT crapcop.nmrescop,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT p-cod-operador,
                                     OUTPUT v-saldo-caixa).

            IF RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
    
            FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                                     crapage.cdagenci = p-cod-agencia 
                                     NO-LOCK NO-ERROR.

            IF AVAIL crapage THEN
            DO:
                ASSIGN in99 = 0.
            
                DO WHILE TRUE:
                    
                    ASSIGN in99 = in99 + 1.
            
                    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper AND
                                            crapbcx.dtmvtolt = crapdat.dtmvtocd AND
                                            crapbcx.cdagenci = p-cod-agencia    AND
                                            crapbcx.nrdcaixa = p-nro-caixa      AND
                                            crapbcx.cdopecxa = p-cod-operador   AND
                                            crapbcx.cdsitbcx = 1            
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF NOT AVAIL crapbcx THEN
                    DO:
                        IF LOCKED crapbcx THEN
                        DO:
                            IF in99 <= 10 THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                            ELSE
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPBCX em uso ".
                                                                
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
                    END.
            
                    LEAVE.
                END.

                ASSIGN crapbcx.hrultsgr = TIME.

                IF crapage.vlmaxsgr <= v-saldo-caixa THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "ATENCAO, saldo maximo em caixa, " +
                                         "e necessario efetuar sangria.".
                                            
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    ASSIGN crapbcx.flgcxsgr = FALSE.

                    RETURN "MAX".
                END.
                ELSE
                IF crapage.vlminsgr <= v-saldo-caixa THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "ATENCAO, seu saldo em caixa e de " +
                                " R$ " + STRING(v-saldo-caixa, "zzz,zz9.99") + 
                                ", efetue a sangria.".
                                            
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).

                    RETURN "MIN".
                END.

                RELEASE crapbcx.
            END.
            ELSE
                RETURN "NOK".    
        END.
    END.
    ELSE
    DO:
        /* se o caixa nao esta ativo, entao eh porque ainda nao foi feita
           a sangria. Lanca mensagem novamente */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "ATENCAO, saldo maximo em caixa, " +
                             "e necessario efetuar sangria.".
                                            
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "MAX".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-saldo-caixa:

    DEF INPUT PARAM p-cooper       AS INTE.
    DEF INPUT PARAM p-nmrescop     AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-nro-caixa    AS INTE.
    DEF INPUT PARAM p-cod-operador AS CHAR.

    DEF OUTPUT PARAM p-saldo-caixa AS DECI.

    DEF VAR v-valor-credito AS DECI.
    DEF VAR v-valor-debito  AS DECI.

    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cooper
                             NO-LOCK NO-ERROR.

    FIND LAST crapbcx WHERE crapbcx.cdcooper = p-cooper         AND
                            crapbcx.dtmvtolt = crapdat.dtmvtocd AND
                            crapbcx.cdagenci = p-cod-agencia    AND
                            crapbcx.nrdcaixa = p-nro-caixa      AND
                            crapbcx.cdopecxa = p-cod-operador   AND
                            crapbcx.cdsitbcx = 1            
                            NO-LOCK NO-ERROR.

    IF NOT AVAIL crapbcx THEN
    DO:
        ASSIGN i-cod-erro  = 698
               c-desc-erro = "".
                   
        RUN cria-erro (INPUT p-nmrescop,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    RUN dbo/b2crap13.p PERSISTENT SET h-b2crap13.

    RUN disponibiliza-dados-boletim-caixa IN h-b2crap13 
                                                   (INPUT p-nmrescop,
                                                    INPUT p-cod-operador,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT ROWID(crapbcx),
                                                    INPUT " ",
                                                    INPUT NO, 
                                                    INPUT "",
                                                   OUTPUT v-valor-credito,
                                                   OUTPUT v-valor-debito
                                                   ).

    IF VALID-HANDLE(h-b2crap13) THEN
        DELETE OBJECT h-b2crap13.

    RUN verifica-erro (INPUT p-nmrescop,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
                
    ASSIGN p-saldo-caixa = crapbcx.vldsdini + v-valor-credito - v-valor-debito.
    
END PROCEDURE.

/*
Fazer tratamento de horário para o pagamento da guia, somente permitir 
o pagamento se horário (TIME) for maior ou igual a crapcop.hrinigps e 
menor ou igual a crapcop.hrfimgps. 
Gerar crítica 676 - Horario esgotado para digitacao.
*/
PROCEDURE verifica-horario-gps:
    DEF INPUT PARAM p-cdcooper     AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-nro-caixa    AS INTE.

    FIND FIRST crapcop WHERE crapcop.nmrescop = p-cdcooper NO-LOCK.

    IF  TIME >= crapcop.hrinigps AND 
        TIME <= crapcop.hrfimgps THEN
        RETURN "OK".
        
    /*Horario esgotado para digitacao.*/
    ASSIGN i-cod-erro  = 676
           c-desc-erro = "".
                   
    RUN cria-erro (INPUT crapcop.nmrescop,
                   INPUT p-cod-agencia,
                   INPUT p-nro-caixa,
                   INPUT i-cod-erro,
                   INPUT c-desc-erro,
                   INPUT YES).

    RETURN "NOK".
END.


/* Retornar temp-table com informações pertinentes ao BL aberto, se houver */
PROCEDURE retorna-dados-bl:

    DEF INPUT PARAM p-cdcooper     AS CHAR.
    DEF INPUT PARAM p-cod-agencia  AS INTE.
    DEF INPUT PARAM p-nro-caixa    AS INTE.
    DEF OUTPUT PARAM TABLE FOR tt-crapcbl.

    FIND FIRST crapcop WHERE crapcop.nmrescop = p-cdcooper NO-LOCK.

    FIND crapcbl WHERE 
         crapcbl.cdcooper = crapcop.cdcooper  AND
         crapcbl.cdagenci = p-cod-agencia     AND
         crapcbl.nrdcaixa = p-nro-caixa 
         NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAILABLE crapcbl THEN
        DO:
            IF  crapcbl.nrdconta = 0 THEN
                RETURN "OK".

            FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                     crapass.nrdconta = crapcbl.nrdconta  AND
                                     crapass.dtdemiss = ?
                                     NO-LOCK NO-ERROR.

            CREATE tt-crapcbl.
            ASSIGN tt-crapcbl.blidenti  = crapcbl.blidenti 
                   tt-crapcbl.cdagenci  = crapcbl.cdagenci 
                   tt-crapcbl.cdcooper  = crapcbl.cdcooper 
                   tt-crapcbl.nrdcaixa  = crapcbl.nrdcaixa 
                   tt-crapcbl.nrdconta  = crapcbl.nrdconta 
                   tt-crapcbl.vlcompcr  = crapcbl.vlcompcr 
                   tt-crapcbl.vlcompdb  = crapcbl.vlcompdb 
                   tt-crapcbl.vlinicial = crapcbl.vlinicial.

            IF  AVAIL crapass THEN
                ASSIGN tt-crapcbl.dsdonome  = crapass.nmprimtl.
        END.
        

    RETURN "OK".
END.

/* b1crap00.p */
/* ......................................................................... */