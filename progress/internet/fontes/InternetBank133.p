/*..............................................................................

   Programa: siscaixa/web/InternetBank133.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas
   Data    : Mar�o/2015.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Gerar o log para os boletos que foram enviados por e-mail
   
   Alteracoes: 
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_cdbandoc LIKE crapcob.cdbandoc                     NO-UNDO.
DEF INPUT PARAM par_nrdctabb LIKE crapcob.nrdctabb                     NO-UNDO.
DEF INPUT PARAM par_nrcnvcob LIKE crapcob.nrcnvcob                     NO-UNDO.
DEF INPUT PARAM par_nrdocmto AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_dsdemail LIKE crapsab.dsdemail                     NO-UNDO.
/* CDTIPLOG - Tipo do log a ser gerado (1 - Erro / 2 - Reenvio)*/
DEF INPUT PARAM par_cdtiplog AS INTE                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS LONGCHAR                              NO-UNDO.

DEF VAR aux_qtddocto AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_dsmsglog AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0088 AS HANDLE                                         NO-UNDO.


/* Verificar a mensagem que ser� adicionada ao log */
IF par_cdtiplog = 1 THEN
    ASSIGN aux_dsmsglog = "ERRO NO ENVIO PARA: " + TRIM(par_dsdemail).
ELSE 
    ASSIGN aux_dsmsglog = "REENVIO PARA: " + TRIM(par_dsdemail).

RUN sistema/generico/procedures/b1wgen0088.p
    PERSISTENT SET h-b1wgen0088.

/* Quantidade de boletos */
ASSIGN aux_qtddocto = NUM-ENTRIES(par_nrdocmto,";").

/* Percorrer todas os boletos e gerar o log informando que n�o foi possivel 
   envi�-lo por e-mail */
DO aux_contador = 1 TO aux_qtddocto:

    IF VALID-HANDLE(h-b1wgen0088) THEN DO:
        /* Encontra o rowid da crapcob para gerar o log */
        FIND FIRST crapcob WHERE crapcob.cdcooper = par_cdcooper
                             AND crapcob.nrdconta = par_nrdconta
                             AND crapcob.nrdocmto = DECI(ENTRY(aux_contador,par_nrdocmto,";"))
                             AND crapcob.cdbandoc = par_cdbandoc
                             AND crapcob.nrdctabb = par_nrdctabb
                             AND crapcob.nrcnvcob = par_nrcnvcob
                           NO-LOCK NO-ERROR.

        IF AVAIL crapcob THEN DO:
            /* Cria o log da cobran�a informando que ocorreu erro no envio por e-mail */
            RUN cria-log-cobranca IN h-b1wgen0088
                  (INPUT ROWID(crapcob),
                   INPUT "996", /* cdoperad */
                   INPUT TODAY,
                   INPUT aux_dsmsglog ).
        END.

    END.
END.

IF VALID-HANDLE(h-b1wgen0088) THEN
    DELETE PROCEDURE h-b1wgen0088.

RETURN "OK".
