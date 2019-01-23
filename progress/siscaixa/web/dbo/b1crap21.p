
/*-----------------------------------------------------------------------------

    b1crap21.p - DOC/TED - Estorno
    
    Ultima Atualizacao: 14/06/2018
    
    Alteracoes: 23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
    
                14/03/2008 - No estorno dos TEDs tambem verificar se ja foram
                             enviados e nao tratar envio de arquivos fisicos
                             (Evandro).
                             
                23/10/2009 - Alterada procedure critica-retorna-valores para 
                             criticar estorno de TED´s que são enviadas por 
                             mensageria SPB, pois o crps531.p efetuara o 
                             estorno atraves dos recebimentos de mensagens 
                             de erro (Fernando).
                             
                17/09/2010 - Incluido caminho completo na remocao dos
                             arquivos no diretorio "salvar" (Elton).
                             
                03/11/2010 - Incluido novos parametros no find da tabela 
                             craptvl para gerar a critica 22 (Elton).
                             
                30/05/2011 - Enviar email de Controle de Movimentacao
                            (Gabriel).       
                            
                12/07/2011 - Estorno das tarifas (Gabriel) 
                
                17/08/2011 - Correcao na passagem de parametros para o envio
                             de email de controle de movimentacao (Gabriel)                 
                             
                03/12/2013 - Troca do campo nrdconta por nrdctabb nas consultas
                             da craplcm (Tiago).             

                14/06/2018 - Alteracoes para usar as rotinas mesmo com o processo 
                              norturno rodando (Douglas Pagel - AMcom).
                              
                16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
----------------------------------------------------------------------------- **/

{ dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
                             
DEF VAR i-cod-erro      AS INT  NO-UNDO.
DEF VAR c-desc-erro     AS CHAR NO-UNDO.
DEF VAR i-nro-lote      AS INT  NO-UNDO.
DEF VAR i-nro-lote-lcm  AS INT  NO-UNDO.
DEF VAR i-tipo-lote     AS INT  NO-UNDO.
DEF VAR i-tipo-lote-lcm AS INT  NO-UNDO.
DEF VAR aux_nrcpfcgc1   AS CHAR NO-UNDO.
DEF VAR aux_nrcpfcgc2   AS CHAR NO-UNDO. 
DEF VAR aux_nrcpfcgc11  AS CHAR NO-UNDO.
DEF VAR aux_nrcpfcgc22  AS CHAR NO-UNDO.
DEF VAR in99            AS INT  NO-UNDO.
DEF VAR aux_nmarquiv    AS CHAR NO-UNDO.

PROCEDURE critica-retorna-valores:
    
    DEF INPUT PARAM p-cooper              AS CHAR     NO-UNDO.  
    DEF INPUT PARAM p-cod-agencia         AS INT.  /* Cod. Agencia          */
    DEF INPUT PARAM p-nro-caixa           AS INT.  /* Numero Caixa          */
    DEF INPUT PARAM p-tipo-doc            AS INT.  /* Tipo do Doc           */
    DEF INPUT PARAM p-nro-docmto          AS INTE.
    DEF OUTPUT PARAM p-titular            AS LOG.
    DEF OUTPUT PARAM p-cod-finalidade     AS INT.  /* Codigo da Finalidade   */
    DEF OUTPUT PARAM p-tipo-conta-db      AS INT.  /* Tipo Conta Debitada    */
    DEF OUTPUT PARAM p-tipo-conta-cr      AS INT.  /* Tipo Conta Creditada   */
    DEF OUTPUT PARAM p-nro-conta-de       AS INT.  /* Nro Conta De           */
    DEF OUTPUT PARAM p-nome-de            AS CHAR. /* Nome De                */
    DEF OUTPUT PARAM p-nome-de1           AS CHAR.
    DEF OUTPUT PARAM p-cpfcnpj-de         AS CHAR. /* CPF/CNPJ De            */
    DEF OUTPUT PARAM p-cpfcnpj-de1        AS CHAR.
    DEF OUTPUT PARAM p-cod-banco          AS INT.  /* Codigo  Banco          */
    DEF OUTPUT PARAM p-cod-agencia-banco  AS INT.  /* Codigo Agencia(Banco)  */
    DEF OUTPUT PARAM p-nro-conta-para     AS DEC.  /* Nro Conta Para         */
    DEF OUTPUT PARAM p-nome-para          AS CHAR. /* Nome Para              */
    DEF OUTPUT PARAM p-nome-para1         AS CHAR.
    DEF OUTPUT PARAM p-cpfcnpj-para       AS CHAR. /* CPF/CNPJ Para          */
    DEF OUTPUT PARAM p-cpfcnpj-para1      AS CHAR.
    DEF output PARAM p-val-doc            AS DEC.  /* Valor do DOC           */
    DEF OUTPUT PARAM p-desc-hist          AS CHAR. /* Descricao Historico    */
    DEF OUTPUT PARAM p-nome-banco         AS CHAR. /* Nome Banco             */
    DEF OUTPUT PARAM p-nome-agencia-banco AS CHAR. /* Nome Agencia           */
    DEF OUTPUT PARAM p-desc-finalidade    AS CHAR. /* Descricao Finalidade   */
    DEF OUTPUT PARAM p-desc-conta-db      AS CHAR. /* Descricao Cta Debitada */
    DEF OUTPUT PARAM p-desc-conta-cr      AS CHAR. /* Descricao Cta Creditada*/
    DEF OUTPUT PARAM p-tipo-pessoa-de     AS INTE.
    DEF OUTPUT PARAM p-tipo-pessoa-para   AS INTE.

    DEFINE VARIABLE aux_flgopspb  AS LOGICAL      NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    IF   crapcop.flgopstr OR crapcop.flgoppag   THEN 
         ASSIGN aux_flgopspb = TRUE.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF  p-nro-docmto = 0 THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Numero do Documento deve ser Informado". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

        /* Lote para craptvl */
    IF  p-tipo-doc = 3 OR p-tipo-doc = 4  THEN
        DO:
           IF   aux_flgopspb   THEN /* TED C e TED D - SPB */
                ASSIGN i-nro-lote  = 23000 + p-nro-caixa.
           ELSE
                ASSIGN i-nro-lote  = 21000 + p-nro-caixa.
        END.
    ELSE                           /* DOC */
        ASSIGN i-nro-lote  = 20000 + p-nro-caixa.


    FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                       craptvl.tpdoctrf = p-tipo-doc        AND 
                       craptvl.nrdocmto = p-nro-docmto      AND 
                       craptvl.dtmvtolt = crapdat.dtmvtocd  AND
                       craptvl.cdagenci = p-cod-agencia     AND
                       craptvl.cdbccxlt = 11                AND
                       craptvl.nrdolote = i-nro-lote        NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL  craptvl THEN 
        DO:
            ASSIGN i-cod-erro  = 22
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Arquivo enviado por mensageria - SPB */
    IF   craptvl.idopetrf <> ""   THEN
         DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "TED ja Transmitido.".
                             
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Arquivo DOC ja Transmitido */
    IF  craptvl.flgenvio = YES   AND
        p-tipo-doc      <> 3     THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = 
                      "Docto ja Transmitido. Utilize Opcao X(TelaDoctos)".

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN p-titular           = craptvl.flgtitul 
           p-cod-finalidade    = craptvl.cdfinrcb
           p-tipo-conta-db     = craptvl.tpdctadb 
           p-tipo-conta-cr     = craptvl.tpdctacr
           p-nro-conta-de      = craptvl.nrdconta
           p-nome-de           = craptvl.nmpesemi
           p-nome-de1          = craptvl.nmsegemi
           p-cod-banco         = craptvl.cdbccrcb
           p-cod-agencia-banco = craptvl.cdagercb
           p-nro-conta-para    = craptvl.nrcctrcb   
           p-nome-para         = craptvl.nmpesrcb 
           p-nome-para1        = craptvl.nmstlrcb
           p-val-doc           = craptvl.vldocrcb
           p-desc-hist         = craptvl.dshistor.

    IF  craptvl.flgpescr  THEN
        ASSIGN p-tipo-pessoa-para = 1.
    ELSE
        ASSIGN p-tipo-pessoa-para = 2.

    IF  craptvl.flgpesdb   THEN
        ASSIGN p-tipo-pessoa-de = 1.
    ELSE
        ASSIGN p-tipo-pessoa-de = 2.

    IF  craptvl.flgpescr = YES  THEN   /* Fisica */   
        ASSIGN aux_nrcpfcgc1  = STRING(craptvl.cpfcgrcb,"99999999999")
               aux_nrcpfcgc1  = STRING(aux_nrcpfcgc1,"999.999.999-99") 
               aux_nrcpfcgc11 = STRING(craptvl.cpstlrcb,"99999999999")
               aux_nrcpfcgc11 = STRING(aux_nrcpfcgc11,"999.999.999-99").
    ELSE  
        ASSIGN aux_nrcpfcgc1  = STRING(craptvl.cpfcgrcb,"99999999999999")
               aux_nrcpfcgc1  = STRING(aux_nrcpfcgc1,"99.999.999/9999-99") 
               aux_nrcpfcgc11 = STRING(craptvl.cpstlrcb,"99999999999999")
               aux_nrcpfcgc11 = STRING(aux_nrcpfcgc11,"99.999.999/9999-99").

    IF  p-nro-conta-de <> 0 THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = p-nro-conta-de 
                               NO-LOCK NO-ERROR.
                             
            IF  NOT AVAIL crapass THEN 
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

    IF  p-nro-conta-de <> 0 THEN
        DO:
           IF crapass.inpessoa = 1 THEN
              ASSIGN aux_nrcpfcgc2  = STRING(craptvl.cpfcgemi,"99999999999")
                     aux_nrcpfcgc2  = STRING(aux_nrcpfcgc2,"999.999.999-99")
                     aux_nrcpfcgc22 = STRING(craptvl.cpfsgemi,"99999999999")
                     aux_nrcpfcgc22 = STRING(aux_nrcpfcgc22,"999.999.999-99").
           ELSE 
              ASSIGN aux_nrcpfcgc2  = STRING(craptvl.cpfcgemi,"99999999999999")
                     aux_nrcpfcgc2  = STRING(aux_nrcpfcgc2,"99.999.999/9999-99")
                     aux_nrcpfcgc22 = STRING(craptvl.cpfsgemi,"99999999999999")
                     aux_nrcpfcgc22 =
                     STRING(aux_nrcpfcgc22,"99.999.999/9999-99").
        END.
    ELSE
        DO:
            IF  craptvl.flgpesdb = YES THEN /* Fisica */   
                ASSIGN aux_nrcpfcgc2  = STRING(craptvl.cpfcgemi,"99999999999")
                       aux_nrcpfcgc2  = STRING(aux_nrcpfcgc2,"999.999.999-99")
                       aux_nrcpfcgc22 = STRING(craptvl.cpfsgemi,"99999999999")
                       aux_nrcpfcgc22 = STRING(aux_nrcpfcgc22,"999.999.999-99").
            ELSE 
              ASSIGN aux_nrcpfcgc2  = STRING(craptvl.cpfcgemi,"99999999999999")
                     aux_nrcpfcgc2  = STRING(aux_nrcpfcgc2,"99.999.999/9999-99")
                     aux_nrcpfcgc22 = STRING(craptvl.cpfsgemi,"99999999999999")
                     aux_nrcpfcgc22 = 
                                 STRING(aux_nrcpfcgc22,"99.999.999/9999-99").
         
        END. 

    ASSIGN p-cpfcnpj-para   = aux_nrcpfcgc1
           p-cpfcnpj-de     = aux_nrcpfcgc2. 

    ASSIGN p-cpfcnpj-para1   = aux_nrcpfcgc11 
           p-cpfcnpj-de1     = aux_nrcpfcgc22. 

    FIND crapban WHERE crapban.cdbccxlt = p-cod-banco   NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapban THEN 
        DO:
            ASSIGN i-cod-erro  = 57
                   c-desc-erro = " ". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ELSE
        ASSIGN p-nome-banco = crapban.nmresbcc.
  
    FIND crapagb WHERE crapagb.cdageban = p-cod-agencia-banco AND
                       crapagb.cddbanco = p-cod-banco         NO-LOCK NO-ERROR.
                       
    IF  NOT AVAIL crapagb THEN 
        DO:
            ASSIGN i-cod-erro  = 15
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ELSE
        ASSIGN p-nome-agencia-banco = crapagb.nmageban.
   
    IF  p-tipo-doc = 1    OR                   /* DOC C */
        p-tipo-doc = 2    THEN                 /* DOC D */  
          FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "GENERI"            AND
                             craptab.cdempres = 00                  AND
                             craptab.cdacesso = "FINTRFDOCS"        AND
                             craptab.tpregist = craptvl.cdfinrcb  
                             NO-LOCK NO-ERROR.
                             
    ELSE
          FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "GENERI"            AND
                             craptab.cdempres = 00                  AND
                             craptab.cdacesso = "FINTRFTEDS"        AND
                             craptab.tpregist = craptvl.cdfinrcb  
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab THEN 
        DO:
            ASSIGN i-cod-erro  = 362
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ELSE
        ASSIGN p-desc-finalidade = craptab.dstextab.   

    IF  p-tipo-doc = 2     OR     /* DOC D */
       (p-tipo-doc = 3     AND     /* TED   */
        p-titular  = NO)   THEN 
        DO:
            IF  p-tipo-doc = 2 THEN /* DOC D */ /* Critica Conta Debitada */
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTADBTRF"      AND
                                   craptab.tpregist = craptvl.tpdctadb  
                                   NO-LOCK NO-ERROR.
            ELSE
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTADBTED"      AND
                                   craptab.tpregist = craptvl.tpdctadb   
                                   NO-LOCK NO-ERROR.

            IF  NOT AVAIL craptab   THEN   
                DO:
                    ASSIGN i-cod-erro  = 017
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.
            ELSE         
                ASSIGN p-desc-conta-db = craptab.dstextab.

            IF  p-tipo-doc = 2 THEN /* DOC D */ /* Critica Conta Creditada */
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTACRTRF"      AND
                                   craptab.tpregist = craptvl.tpdctacr
                                   NO-LOCK NO-ERROR.
            ELSE
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = 00                AND
                                   craptab.cdacesso = "TPCTACRTED"      AND
                                   craptab.tpregist = craptvl.tpdctacr
                                   NO-LOCK NO-ERROR.
                  
            IF  NOT AVAIL craptab THEN 
                DO:
                    ASSIGN i-cod-erro  = 017
                           c-desc-erro = "". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                END.
            ELSE         
                ASSIGN p-desc-conta-cr = craptab.dstextab.
        END.
         
    FIND craptab WHERE 
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND /* Verif. horario de corte  */
         craptab.tptabela = "GENERI"         AND
         craptab.cdempres = 0                AND
         craptab.cdacesso = "HRTRDOCTOS"     AND  
         craptab.tpregist = p-cod-agencia    NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab   THEN 
        DO:
            ASSIGN i-cod-erro  = 676
                   c-desc-erro = "". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
    ELSE 
        DO:
           IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   AND
               p-tipo-doc = 3                              THEN 
               DO:
                   ASSIGN i-cod-erro  = 676
                          c-desc-erro = "". 
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
               END.
        END.
   
    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
                       
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".                        

    RETURN "OK".
END PROCEDURE.

PROCEDURE estorna-doc-ted:

    DEF INPUT  PARAM p-cooper               AS CHAR     NO-UNDO.  
    DEF INPUT  PARAM p-cod-agencia          AS INT.   /* Cod. Agencia    */
    DEF INPUT  PARAM p-nro-caixa            AS INT.   /* Numero Caixa    */
    DEF INPUT  PARAM p-tipo-doc             AS INT.   /* Tipo do Doc     */    
    DEF INPUT  PARAM p-nro-docmto           AS INTE.
    DEF INPUT  PARAM p-val-doc              AS DEC.   /* Valor do DOC    */
    DEF OUTPUT PARAM p-histor               AS INTE.
    DEF OUTPUT PARAM p-histor-lcm           AS INTE.
    DEF OUTPUT PARAM p-val-doc-lcm          AS DECI.

    DEF VAR h-b1wgen9998                    AS HANDLE             NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    IF  p-tipo-doc = 3  THEN       /* TED */ 
        ASSIGN i-nro-lote  = 21000 + p-nro-caixa
               i-tipo-lote = 25
               p-histor    = 558.
    ELSE                           /* DOC */
        ASSIGN i-nro-lote  = 20000 + p-nro-caixa
               i-tipo-lote = 24
               p-histor    = 557. 

    /* Lote para debito em CC*/
    ASSIGN i-nro-lote-lcm  = 11000 + p-nro-caixa
           i-tipo-lote-lcm = 1. 

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        ASSIGN in99 = in99 + 1.
        FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapdat.dtmvtocd  AND
                           craplot.cdagenci = p-cod-agencia     AND
                           craplot.cdbccxlt = 11                AND  /* Fixo */
                           craplot.nrdolote = i-nro-lote  
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF  NOT AVAILABLE craplot THEN  
            DO:
                IF  LOCKED craplot THEN 
                    DO:

                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPLOT em uso ".
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
        LEAVE.
    END.  /* DO WHILE */

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
        
        FIND craptvl WHERE craptvl.cdcooper = crapcop.cdcooper  AND
                           craptvl.tpdoctrf = p-tipo-doc        AND
                           craptvl.nrdocmto = p-nro-docmto      AND
                           craptvl.dtmvtolt = crapdat.dtmvtocd  AND 
                           craptvl.cdagenci = p-cod-agencia     AND
                           craptvl.cdbccxlt = 11                AND
                           craptvl.nrdolote = i-nro-lote         
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
        ASSIGN in99 = in99 + 1.
        IF  NOT AVAIL craptvl   THEN 
            DO:
                IF  LOCKED craptvl  THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPTVL em uso ".
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
                        ASSIGN i-cod-erro  = 22
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

    END.  /*   DO WHILE  */  

    ASSIGN craplot.qtcompln = craplot.qtcompln - 1
           craplot.vlcompcr = craplot.vlcompcr - p-val-doc
           craplot.qtinfoln = craplot.qtinfoln - 1
           craplot.vlinfocr = craplot.vlinfocr - p-val-doc.

    RELEASE craplot. 

    /* Somente estorna TED se o arquivo ainda estiver no /micros/COOP/compel */
    IF   p-tipo-doc = 3   THEN /* TED */
         DO:
            ASSIGN aux_nmarquiv = "td" +
                   STRING(craptvl.nrdocmto, "9999999")  + 
                   STRING(DAY(crapdat.dtmvtocd),"99")   + 
                   STRING(MONTH(crapdat.dtmvtocd),"99") +
                   STRING(craptvl.cdagenci, "99") +
                   ".rem".
        
            IF   SEARCH("/micros/" + crapcop.dsdircop + "/compel/" +
                        aux_nmarquiv) = ? THEN
                 DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = "TED ja Transmitido. " +
                                          "Utilize Opcao X(TelaDoctos)".
                     
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
                    /* remove os arquivos */
                    UNIX SILENT VALUE("rm /micros/" + crapcop.dsdircop +
                                      "/compel/" + aux_nmarquiv +
                                      " 2>/dev/null").
                    UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + 
                                      "/salvar/" + aux_nmarquiv + 
                                      " 2>/dev/null").
                END.
         END.
     
    IF   craptvl.nrdconta <> 0   THEN
         DO:
            /* Valor da Tarifa */
            DO in99 = 1 TO 10:

               FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper AND
                                  craplcm.dtmvtolt = crapdat.dtmvtocd AND
                                  craplcm.cdagenci = 1                AND
                                  craplcm.cdbccxlt = 100              AND
                                  craplcm.nrdolote = 7999             AND
                                  craplcm.nrdctabb = craptvl.nrdconta AND
                                  craplcm.nrdocmto = craptvl.nrdocmto
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
               
               IF   NOT AVAIL craplcm   THEN
                    IF   LOCKED craplcm  THEN
                         DO:
                             ASSIGN i-cod-erro  = 114
                                    c-desc-erro = " ".
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         LEAVE.
               ELSE             /* Lancamento disponivel */
                    DO:
                        ASSIGN p-val-doc     = craplcm.vllanmto
                               p-val-doc-lcm = craplcm.vllanmto.

                        /* Para nao criar o crapaut. TEC / DOC em Especie */
                        IF   craplcm.cdhistor = 327   THEN 
                             p-histor-lcm = 0.
                        ELSE     
                             p-histor-lcm = craplcm.cdhistor.
                           
                        DELETE craplcm.
                          
                        DO in99 = 1 TO 10:

                           FIND craplot WHERE
                                craplot.cdcooper = crapcop.cdcooper  AND
                                craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                craplot.cdagenci = 1                 AND
                                craplot.cdbccxlt = 100  /* Fixo */   AND
                                craplot.nrdolote = 7999
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAIL craplot   THEN
                                IF   LOCKED craplot   THEN
                                     DO:
                                         ASSIGN i-cod-erro  = 0
                                                c-desc-erro = "Tabela CRAPLOT"
                                                            + " em uso".
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     DO:
                                         ASSIGN i-cod-erro  = 60
                                                c-desc-erro = " ". 
                                         LEAVE.
                                     END.

                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "".
                           LEAVE.

                        END.

                        IF   i-cod-erro <> 0     OR
                             c-desc-erro <> ""  THEN
                             DO: 
                                 RUN cria-erro (INPUT p-cooper,
                                                INPUT p-cod-agencia,
                                                INPUT p-nro-caixa,
                                                INPUT i-cod-erro,
                                                INPUT c-desc-erro,
                                                INPUT YES).
                                 RETURN "NOK".                          
                             END.

                        ASSIGN craplot.qtcompln = craplot.qtcompln - 1
                               craplot.vlcompdb = craplot.vlcompdb - 
                                                  p-val-doc-lcm
                               craplot.qtinfoln = craplot.qtinfoln - 1
                               craplot.vlinfodb = craplot.vlinfodb -
                                                  p-val-doc-lcm.
                  
                        RELEASE craplot.

                     END.

               ASSIGN i-cod-erro  = 0
                      c-desc-erro = "".
               LEAVE.

            END. /* Do CONTADOR */

            IF   i-cod-erro <> 0  OR
                 c-desc-erro <> "" THEN
                 DO:
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
                 
            /* Valor do Debito */
            DO in99 = 1 TO 10:
                             
                FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper AND
                                   craplcm.dtmvtolt = crapdat.dtmvtocd AND
                                   craplcm.cdagenci = craptvl.cdagenci AND
                                   craplcm.cdbccxlt = 11               AND
                                   craplcm.nrdolote = i-nro-lote-lcm   AND
                                   craplcm.nrdctabb = craptvl.nrdconta AND
                                   craplcm.nrdocmto = craptvl.nrdocmto
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
                IF   NOT AVAIL craplcm   THEN
                     IF   LOCKED craplcm   THEN
                          DO:
                              ASSIGN i-cod-erro  = 114
                                     c-desc-erro = " ".
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              LEAVE.
                          END.
                ELSE              /* Lancamento disponivel */
                     DO:
                         ASSIGN p-val-doc     = craplcm.vllanmto
                                p-val-doc-lcm = craplcm.vllanmto.

                         /* Para nao criar o crapaut. TEC / DOC em Especie */
                         IF   craplcm.cdhistor = 327   THEN 
                              p-histor-lcm = 0.
                         ELSE     
                              p-histor-lcm = craplcm.cdhistor.
                            
                         DELETE craplcm.

                         IF   i-cod-erro <> 0     OR
                              c-desc-erro <> ""  THEN
                              DO: 
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).
                                  RETURN "NOK".                          
                              END.
                     END.

                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "".
                LEAVE.

            END. /* DO ... TO */

            IF   i-cod-erro <> 0  OR
                 c-desc-erro <> "" THEN
                 DO:
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.

         END. /* Fim craptvl.nrdconta <> 0 */

    ASSIGN in99 = 0.

    DO  WHILE TRUE:
       
        FIND crapcme WHERE crapcme.cdcooper = crapcop.cdcooper AND
                           crapcme.dtmvtolt = crapdat.dtmvtocd AND
                           crapcme.cdagenci = craptvl.cdagenci AND
                           crapcme.cdbccxlt = 11               AND
                           crapcme.nrdolote = i-nro-lote-lcm   AND
                           crapcme.nrdctabb = craptvl.nrdconta AND
                           crapcme.nrdocmto = craptvl.nrdocmto 
                           EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN in99 = in99 + 1.
        
        IF  NOT AVAILABLE crapcme   THEN 
            DO:
                IF  LOCKED crapcme  THEN 
                    DO:
                        IF  in99 <  100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 77
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
                RUN sistema/generico/procedures/b1wgen9998.p
                    PERSISTENT SET h-b1wgen9998.

                RUN email-controle-movimentacao IN h-b1wgen9998
                                                   (INPUT crapcop.cdcooper,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT "",
                                                    INPUT "b1crap21",
                                                    INPUT 2, /* C. Online */
                                                    INPUT crapcme.nrdconta,
                                                    INPUT 1,  /* Titular */
                                                    INPUT 3, /* Exclusao */
                                                    INPUT ROWID(crapcme),
                                                    INPUT TRUE, /* Envia */
                                                    INPUT crapdat.dtmvtocd,
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
            
        LEAVE.

    END.  /*   DO WHILE  */
    
    DELETE craptvl.          

    RETURN "OK".

END PROCEDURE.

/* b1crap21.p */

/* .......................................................................... */


