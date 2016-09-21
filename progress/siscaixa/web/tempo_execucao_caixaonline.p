/*.............................................................................

   Programa: siscaixa/web/tempo_execucao_caixaonline.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Dezembro/2014                    Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Conforme tempo de monitoracao
   Objetivo  : Executar requisicao no servico WebSpeed do Caixa On-Line para
               monitoracao de performance e disponibilidade
   
   Alteracoes:  
                             
.............................................................................*/                             

ETIME(TRUE).

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/html":U).

DEFINE VARIABLE aux_cdcooper LIKE crapcop.cdcooper NO-UNDO.
DEFINE VARIABLE aux_nmcooper LIKE crapcop.nmrescop NO-UNDO.
DEFINE VARIABLE aux_nrdconta LIKE crapass.nrdconta NO-UNDO.
DEFINE VARIABLE aux_cdagenci LIKE crapage.cdagenci NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa LIKE crapcbl.nrdcaixa NO-UNDO.
DEFINE VARIABLE aux_dtmvtolt LIKE crapdat.dtmvtolt NO-UNDO.
DEFINE VARIABLE aux_vltotrda AS DECI               NO-UNDO. 
DEFINE VARIABLE aux_vltotrpp AS DECI               NO-UNDO.
DEFINE VARIABLE i-qtd-taloes AS INTE               NO-UNDO.
DEFINE VARIABLE v_msgtrf     AS CHAR               NO-UNDO.
DEFINE VARIABLE h-b1crap02   AS HANDLE             NO-UNDO.

DEF TEMP-TABLE craterr NO-UNDO LIKE craperr.   

DEF TEMP-TABLE tt-conta
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

ASSIGN aux_cdcooper = 1.

FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
FIND crapdat WHERE crapdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

ASSIGN aux_nmcooper = crapcop.nmrescop
       aux_cdagenci = 999
       aux_nrdcaixa = 999
       aux_nrdconta = 329
       aux_dtmvtolt = crapdat.dtmvtolt.

RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

RUN consulta-dados-conta.

DELETE PROCEDURE h-b1crap02.

IF  RETURN-VALUE <> "OK"  THEN
    {&out} "2 - NOK - Tempo: " + TRIM(STRING(ETIME,"zz9,999")) + " segundos".
ELSE
    {&out} "0 - OK  - Tempo: " + TRIM(STRING(ETIME,"zz9,999")) + " segundos".

PROCEDURE consulta-dados-conta:
            
    RUN consulta-conta IN h-b1crap02 (INPUT aux_nmcooper, /* aux_nmcooper  */         
                                      INPUT aux_cdagenci, /* v_pac   */
                                      INPUT aux_nrdcaixa, /* v_caixa */
                                      INPUT aux_nrdconta, /* v_conta */
                                     OUTPUT TABLE tt-conta) NO-ERROR.

    IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
        RETURN "NOK".
    
    RUN retornaMsgTransferencia IN h-b1crap02 (INPUT aux_nmcooper,      
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_nrdconta,
                                              OUTPUT v_msgtrf) NO-ERROR.
    
    IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
        RETURN "NOK".

    FIND FIRST tt-conta NO-LOCK NO-ERROR.

    IF  AVAIL tt-conta  THEN
        DO: 
            FOR EACH crapfdc WHERE crapfdc.cdcooper  = aux_cdcooper AND
                                   crapfdc.nrdconta  = aux_nrdconta AND
                                   crapfdc.dtretchq >= DATE(MONTH(aux_dtmvtolt),01,YEAR(aux_dtmvtolt)) AND
                                   crapfdc.tpcheque  = 1
                                   NO-LOCK BREAK BY crapfdc.nrseqems:

                IF  FIRST-OF(crapfdc.nrseqems)  THEN
                    ASSIGN i-qtd-taloes = i-qtd-taloes + 1.

            END.

            RUN verifica_anota IN h-b1crap02 (INPUT aux_nmcooper,       
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_nrdconta) NO-ERROR.

            IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
                RETURN "NOK".
        
            RUN calcula_aplicacoes IN h-b1crap02 (INPUT aux_nmcooper,       
                                                  INPUT aux_cdagenci,
                                                  INPUT aux_nrdcaixa,
                                                 OUTPUT aux_vltotrda,
                                                 OUTPUT TABLE craterr) NO-ERROR.

            IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
                RETURN "NOK".

            RUN calcula_poupanca IN h-b1crap02 (INPUT aux_nmcooper,
                                               OUTPUT aux_vltotrpp) NO-ERROR.

            IF  ERROR-STATUS:NUM-MESSAGES > 0 THEN
                RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.
