/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap85.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2007                    Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Recebimento de Beneficios - BANCOOB

   Alteracoes: 31/10/2008 - Grava texto do comprovante de recebimento do INSS
                            na tabela crapaut (Elton);
                          - Verificacao para requisicao duplicada em caso de
                            sistema lento e tratamento do CREATE da craplpi
                            (Evandro).
  
                03/12/2008 - Alterado o campo nrdocpcd para dsdocpcd(Rosangela)
                 
                04/06/2009 - Alteracao CDOPERAD (Kbase).
                
                23/03/2010 - Nao permitir pagamentos para procuradores
                             com a validade ja expirada (Gabriel).
                             
                20/09/2010 - Incluso o nome do operador no termo (Vitor)      
                
                14/02/2013 - Ajuste na procedure paga_beneficio para retirar
                             os comandos UNDO usados indevidamente (Adriano).
                
                17/12/2013 - Adicionado validate para tabela craplpi (Tiago).
                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
   ......................................................................... */

/*--------------------------------------------------------------------------*/
/*  b1crap85.p   - Recebimento de Beneficios - BANCOOB                      */
/*--------------------------------------------------------------------------*/
DEFINE STREAM str_1.

{dbo/bo-erro1.i}

PROCEDURE paga_beneficio:
    DEFINE INPUT  PARAM p-cooper        AS CHAR                     NO-UNDO.
    DEFINE INPUT  PARAM p-cod-agencia   AS INTE                     NO-UNDO.
    DEFINE INPUT  PARAM p-nro-caixa     AS INTE                     NO-UNDO.
    DEFINE INPUT  PARAM p-cod-operador  AS CHAR                     NO-UNDO.
    DEFINE INPUT  PARAM p-data          AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAM p-registro      AS ROWID                    NO-UNDO.
    DEFINE INPUT  PARAM p-tipo-pagto    AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM p-pago-procur   AS LOGICAL                  NO-UNDO.
    DEFINE OUTPUT PARAM p-literal       AS CHAR                     NO-UNDO.
    DEFINE OUTPUT PARAM p-ult-sequencia AS INTE                     NO-UNDO.


    DEFINE VARIABLE aux_contador        AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_vlliquid        AS DEC                      NO-UNDO.
    DEFINE VARIABLE aux_vldoipmf        AS DEC                      NO-UNDO.
    DEFINE VARIABLE aux_cfrvipmf        AS DEC                      NO-UNDO.

    DEFINE VARIABLE i-nro-lote          AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE i-tplotmov          AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE p-recauten          AS RECID                    NO-UNDO.

    DEFINE VARIABLE c-valor             AS CHAR                     NO-UNDO.
    DEFINE VARIABLE c-literal           AS CHAR   EXTENT 36         NO-UNDO.
    DEFINE VARIABLE c-linha1            AS CHAR                     NO-UNDO.
    DEFINE VARIABLE c-linha2            AS CHAR                     NO-UNDO.
    
    DEFINE VARIABLE aux_cdcritic        AS INT                      NO-UNDO.
    DEFINE VARIABLE aux_dscritic        AS CHAR                     NO-UNDO.

    DEFINE VARIABLE h-b1crap00          AS HANDLE                   NO-UNDO.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         RETURN "NOK".

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

    FIND craplbi WHERE ROWID(craplbi) = p-registro NO-LOCK NO-ERROR.
       
    IF   NOT AVAILABLE craplbi   THEN
         DO:
             /* Cria o erro de credito nao encontrado */
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 0,
                            INPUT "Credito nao encontrado!",
                            INPUT YES).
       
             RETURN "NOK".

         END.


    /* Verifica se ja houve pagamento, isso pode acontecer se houver lentidao no sistema.
       Pode acontecer uma requisicao dupla por causa da lentidao */
    FIND craplpi WHERE craplpi.cdcooper = crapcop.cdcooper        AND
                       craplpi.dtmvtolt = p-data                  AND
                       craplpi.cdagenci = p-cod-agencia           AND
                       craplpi.cdbccxlt = 11                      AND
                       craplpi.nrdolote = (27000 + p-nro-caixa)   AND
                       craplpi.nrbenefi = craplbi.nrbenefi        AND
                       craplpi.nrrecben = craplbi.nrrecben        AND
                       craplpi.nrseqcre = craplbi.nrseqcre        AND
                       craplpi.dtiniper = craplbi.dtiniper        AND
                       craplpi.dtfimper = craplbi.dtfimper
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE  craplpi   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 0,
                            INPUT "Pagamento ja efetuado.",
                            INPUT YES).

             RETURN "NOK".

         END.

    IF   p-pago-procur    THEN /* Pagamento para procuradores */
         DO:
             FIND crappbi WHERE crappbi.cdcooper = craplbi.cdcooper   AND
                                crappbi.nrrecben = craplbi.nrrecben   AND
                                crappbi.nrbenefi = craplbi.nrbenefi
                                NO-LOCK NO-ERROR. 
            
             /* Validade ja expirada */
             IF   crappbi.dtvalprc < p-data  THEN
                  DO:
                      RUN cria-erro(INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT 0,
                                    INPUT "Procurador com validade ja expirada.",
                                    INPUT YES).

                      RETURN "NOK".

                  END.
         END. 

    /* Rotinas de pagamento */
    PAGAMENTO:
    DO TRANSACTION:

       /* Pega o registro do credito */
       DO WHILE TRUE:
       
          FIND craplbi WHERE ROWID(craplbi) = p-registro
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF   NOT AVAILABLE craplbi   THEN
               IF   LOCKED craplbi   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Credito nao encontrado!".
       
                        UNDO PAGAMENTO, LEAVE PAGAMENTO.
                    END.
       
          LEAVE.
       END.

       /* calcula o valor a ser pago descontando o CPMF */
       RUN calcula_cpmf (INPUT  p-cooper,
                         INPUT  p-cod-agencia,
                         INPUT  p-nro-caixa,
                         INPUT  p-data,
                         INPUT  craplbi.vllanmto,
                         OUTPUT aux_vlliquid,
                         OUTPUT aux_vldoipmf,
                         OUTPUT aux_cfrvipmf).
       
       ASSIGN craplbi.dtdpagto = p-data
              craplbi.cdoperad = p-cod-operador
              craplbi.vlliqcre = aux_vlliquid.
       
       /* atualiza o banco caixa */
       ASSIGN aux_contador = 0.
       
       DO  WHILE TRUE:
          
           ASSIGN aux_contador = aux_contador + 1.
           
           FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper   AND
                                   crapbcx.dtmvtolt = p-data             AND
                                   crapbcx.cdagenci = p-cod-agencia      AND
                                   crapbcx.nrdcaixa = p-nro-caixa        AND
                                   crapbcx.cdopecxa = p-cod-operador     AND
                                   crapbcx.cdsitbcx = 1  
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
           IF   NOT AVAILABLE crapbcx   THEN DO:
                IF   LOCKED crapbcx     THEN DO:
                     IF  aux_contador <  100  THEN DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                     ELSE DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Tabela CRAPBCX em uso".
       
                        UNDO PAGAMENTO, LEAVE PAGAMENTO.
                     END.
                END.
                ELSE DO:
                        ASSIGN aux_cdcritic = 701
                               aux_dscritic = "".
       
                        UNDO PAGAMENTO, LEAVE PAGAMENTO.
                END.
           END.
           LEAVE.
       END.  /*  DO WHILE */
       
       ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.

       /* grava o lote */
       ASSIGN i-nro-lote = 27000 + p-nro-caixa
              i-tplotmov = 33.
                      
       FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper   AND
                          craplot.dtmvtolt = p-data             AND
                          craplot.cdagenci = p-cod-agencia      AND
                          craplot.cdbccxlt = 11                 AND  /* Fixo */
                          craplot.nrdolote = i-nro-lote         NO-ERROR.
       
       IF  NOT AVAIL craplot  THEN 
           DO:
              CREATE craplot.
              ASSIGN craplot.cdcooper = crapcop.cdcooper
                     craplot.dtmvtolt = p-data
                     craplot.cdagenci = p-cod-agencia
                     craplot.cdbccxlt = 11
                     craplot.nrdolote = i-nro-lote
                     craplot.tplotmov = i-tplotmov
                     craplot.cdoperad = p-cod-operador
                     craplot.cdhistor = 0
                     craplot.nrdcaixa = p-nro-caixa
                     craplot.cdopecxa = p-cod-operador.
           END.
       
       ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
              craplot.qtcompln = craplot.qtcompln + 1
              craplot.qtinfoln = craplot.qtinfoln + 1
              craplot.vlcompcr = craplot.vlcompcr + aux_vlliquid
              craplot.vlinfocr = craplot.vlinfocr + aux_vlliquid.

       /* cria a autenticacao */
       RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
       
       RUN grava-autenticacao IN h-b1crap00 (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT p-cod-operador,
                                             INPUT aux_vlliquid, /* Valor pago */
                                             INPUT craplot.nrseqdig, /* Documento */
                                             INPUT YES, /* YES (PG), NO (REC) */
                                             INPUT "1",  /* On-line            */ 
                                             INPUT NO,    /* Nro estorno        */
                                             INPUT 580, /* Historico */
                                             INPUT ?, /* Data off-line */
                                             INPUT 0, /* Sequencia off-line */
                                             INPUT 0, /* Hora off-line */
                                             INPUT 0, /* Seq.orig.Off-line */
                                             OUTPUT p-literal,
                                             OUTPUT p-ult-sequencia,
                                             OUTPUT p-recauten).
       
       DELETE PROCEDURE h-b1crap00.



       /* Montagem do recibo de pagamento */

       /* Busca o cadastro NB */
       FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper    AND
                          crapcbi.nrrecben = 0                   AND
                          crapcbi.nrbenefi = craplbi.nrbenefi
                          NO-LOCK NO-ERROR.

       /* Busca o cadastro NIT */
       IF   NOT AVAILABLE crapcbi   THEN
            FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper    AND
                               crapcbi.nrrecben = craplbi.nrrecben    AND
                               crapcbi.nrbenefi = 0
                               NO-LOCK NO-ERROR.

       RUN dbo/pcrap12.p (INPUT  craplbi.vlliqcre,
                          INPUT  47,
                          INPUT  47,
                          INPUT  "M",
                          OUTPUT c-linha1,
                          OUTPUT c-linha2).
       
       ASSIGN c-valor =
        FILL(" ",14 - LENGTH(TRIM(STRING(craplbi.vlliqcre,"zzz,zzz,zz9.99")))) + "*" + 
                            (TRIM(STRING(craplbi.vlliqcre,"zzz,zzz,zz9.99"))).
       
       ASSIGN c-literal = " ".
       ASSIGN c-literal[1]  = trim(crapcop.nmrescop) + 
        " - " + TRIM(crapcop.nmextcop) 
              c-literal[2]  = " "
              c-literal[3]  = string(p-data,"99/99/99") +
               " " + STRING(TIME,"HH:MM:SS") +  " PA  " + 
                              string(p-cod-agencia,"999") +
                               "  CAIXA: " + STRING(p-nro-caixa,"Z99") + "/" +
                              substr(p-cod-operador,1,10)  
              c-literal[4]  = " " 
              c-literal[5]  = "        ** RECEBIMENTO INSS " +
               string(craplot.nrseqdig,"ZZZ,ZZ9")  + " **" 
              c-literal[6]  = " " 
              c-literal[7]  = "     NIT: " +
                              STRING(craplbi.nrrecben,"zzzzzzzzzz9")
              c-literal[8]  = "      NB: " +
                              STRING(craplbi.nrbenefi,"zzzzzzzzz9")
              c-literal[9]  = "    NOME: " + crapcbi.nmrecben
              c-literal[10] = "     CPF: " + TRIM(STRING(STRING(crapcbi.nrcpfcgc,"99999999999"),
                                                  "999.999.999-99"))
              c-literal[11] = " PERIODO: " +
                              STRING(craplbi.dtiniper,"99/99/9999") + 
                              " a " +
                              STRING(craplbi.dtfimper,"99/99/9999")

              c-literal[12] = "NATUREZA: " + STRING(craplbi.nrseqcre,"99")
              c-literal[13] = " "
              c-literal[14] = "RECEBI DA " +  
                              STRING(crapcop.nmrescop,"X(11)") + ", REFERENTE AO PAGAMENTO DO"
              c-literal[15] = "BENEFICIO, O VALOR DE R$         " + c-valor
              c-literal[16] = "(" + trim(c-linha1)
              c-literal[17] = trim(c-linha2) + ")"
              c-literal[18] = "AUTENTICADO ABAIXO. "
              c-literal[19] = " "
              c-literal[20] = " "
              c-literal[21] = " ".

       /* Pagamento com cartao nao precisa assinar */
       IF   p-tipo-pagto = 1   THEN
            ASSIGN c-literal[22] = ""
                   c-literal[23] = ""
                   c-literal[24] = "".
       ELSE
       /* Pagamento com recibo */
            DO:
                /* Se foi pago ao procurador */
                IF   p-pago-procur   THEN
                     DO:
                         /* Dados do procurador */
                         FIND crappbi WHERE crappbi.cdcooper = craplbi.cdcooper   AND
                                            crappbi.nrrecben = craplbi.nrrecben   AND
                                            crappbi.nrbenefi = craplbi.nrbenefi
                                            NO-LOCK NO-ERROR.

                         ASSIGN c-literal[22] = "ASSINATURA: _________________________________" 
                                c-literal[23] = "            " + TRIM(crappbi.nmprocur)
                                c-literal[24] = "            " + TRIM(STRING(crappbi.dsdocpcd)).
                     END.
                ELSE
                     /* Pago ao beneficiario */
                     ASSIGN c-literal[22] = "ASSINATURA: _________________________________" 
                            c-literal[23] = "            " + TRIM(crapcbi.nmrecben)
                            c-literal[24] = "            " + TRIM(STRING(STRING(crapcbi.nrcpfcgc,"99999999999"),
                                                                                "999.999.999-99")).
            END.

       ASSIGN c-literal[25] = " "
              c-literal[26] = p-literal  
              c-literal[27] = " "
              c-literal[28] = " "
              c-literal[29] = " "
              c-literal[30] = " "
              c-literal[31] = " "
              c-literal[32] = " "
              c-literal[33] = " "
              c-literal[34] = " "
              c-literal[35] = " "
              c-literal[36] = " ".
       
       ASSIGN p-literal = STRING(c-literal[1],"x(48)")   + 
                          STRING(c-literal[2],"x(48)")   + 
                          STRING(c-literal[3],"x(48)")   + 
                          STRING(c-literal[4],"x(48)")   + 
                          STRING(c-literal[5],"x(48)")   + 
                          STRING(c-literal[6],"x(48)")   + 
                          STRING(c-literal[7],"x(48)")   + 
                          STRING(c-literal[8],"x(48)")   + 
                          STRING(c-literal[9],"x(48)")   + 
                          STRING(c-literal[10],"x(48)")  + 
                          STRING(c-literal[11],"x(48)")  + 
                          STRING(c-literal[12],"x(48)")  +
                          STRING(c-literal[13],"x(48)")  + 
                          STRING(c-literal[14],"x(48)")  + 
                          STRING(c-literal[15],"x(48)")  + 
                          STRING(c-literal[16],"x(48)")  + 
                          STRING(c-literal[17],"x(48)")  +
                          STRING(c-literal[18],"x(48)")  + 
                          STRING(c-literal[19],"x(48)")  + 
                          STRING(c-literal[20],"x(48)")  + 
                          STRING(c-literal[21],"x(48)")  + 
                          STRING(c-literal[22],"x(48)")  + 
                          STRING(c-literal[23],"x(48)")  + 
                          STRING(c-literal[24],"x(48)")  + 
                          STRING(c-literal[25],"x(48)")  + 
                          STRING(c-literal[26],"x(48)")  +
                          STRING(c-literal[27],"x(48)")  + 
                          STRING(c-literal[28],"x(48)")  + 
                          STRING(c-literal[29],"x(48)")  + 
                          STRING(c-literal[30],"x(48)")  + 
                          STRING(c-literal[31],"x(48)")  + 
                          STRING(c-literal[32],"x(48)")  + 
                          STRING(c-literal[33],"x(48)")  +
                          STRING(c-literal[34],"x(48)")  +
                          STRING(c-literal[35],"x(48)")  +
                          STRING(c-literal[36],"x(48)").
       

       FIND LAST crapaut WHERE
                         crapaut.cdcooper = crapcop.cdcooper     AND
                         crapaut.cdagenci = p-cod-agencia        AND
                         crapaut.nrdcaixa = p-nro-caixa          AND
                         crapaut.dtmvtolt = crapdat.dtmvtocd     NO-ERROR.
       
       ASSIGN crapaut.dslitera = p-literal.

        
       /* grava a tabela de lancamentos para INSS - BANCOOB */
       CREATE craplpi.
       ASSIGN craplpi.dtmvtolt = craplot.dtmvtolt
              craplpi.cdagenci = craplot.cdagenci
              craplpi.cdbccxlt = craplot.cdbccxlt
              craplpi.nrdolote = craplot.nrdolote
              craplpi.nrdocmto = craplot.nrseqdig
              craplpi.cdhistor = 580
              craplpi.nrseqdig = craplot.nrseqdig
              craplpi.vllanmto = craplbi.vllanmto
              craplpi.vldoipmf = aux_vldoipmf
              craplpi.nrautdoc = p-ult-sequencia
              craplpi.hrtransa = TIME
              craplpi.cdoperad = p-cod-operador
              craplpi.cdcooper = crapcop.cdcooper
              craplpi.vlliqcre = aux_vlliquid
              craplpi.nrbenefi = craplbi.nrbenefi
              craplpi.nrrecben = craplbi.nrrecben
              craplpi.nrseqcre = craplbi.nrseqcre
              craplpi.dtiniper = craplbi.dtiniper
              craplpi.dtfimper = craplbi.dtfimper
              craplpi.flgpgprd = p-pago-procur
              craplpi.tppagben = p-tipo-pagto NO-ERROR.
       VALIDATE craplpi.

       IF   ERROR-STATUS:ERROR   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tabela CRAPLPI em uso".
       
                UNDO PAGAMENTO, LEAVE PAGAMENTO.
            END.

    END. /* Fim DO TRANSACTION */


    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             /* Cria o erro de credito nao encontrado */
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT aux_cdcritic,
                            INPUT aux_dscritic,
                            INPUT YES).
   
             RETURN "NOK".
         END.
    
    /* libera os registros das tabelas */
    RELEASE craplbi.
    RELEASE crapbcx.
    RELEASE crapaut.
    RELEASE craplot.

    RETURN "OK".

END PROCEDURE. /* Fim paga_beneficio */



PROCEDURE calcula_cpmf:

    DEFINE INPUT  PARAM p-cooper        AS CHAR                     NO-UNDO.
    DEFINE INPUT  PARAM p-cod-agencia   AS INTE                     NO-UNDO.
    DEFINE INPUT  PARAM p-nro-caixa     AS INTE                     NO-UNDO.
    DEFINE INPUT  PARAM p-data          AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAM p-vlcalcul      AS DEC                      NO-UNDO.
    /* Valor liquido */
    DEFINE OUTPUT PARAM p-vlliquid      AS DEC                      NO-UNDO.
    /* Valor descontado */
    DEFINE OUTPUT PARAM p-vldoipmf      AS DEC                      NO-UNDO.
    /* Valor do redutor */
    DEFINE OUTPUT PARAM p-cfrvipmf      AS DEC                      NO-UNDO.


    DEFINE VARIABLE tab_dtinipmf        AS DATE                     NO-UNDO.
    DEFINE VARIABLE tab_dtfimpmf        AS DATE                     NO-UNDO.
    DEFINE VARIABLE tab_txcpmfcc        AS DECIMAL                  NO-UNDO.
    DEFINE VARIABLE tab_txrdcpmf        AS DECIMAL                  NO-UNDO.
    DEFINE VARIABLE tab_indabono        AS INTE                     NO-UNDO.
    DEFINE VARIABLE tab_dtiniabo        AS DATE                     NO-UNDO.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         RETURN "NOK".

    
    /*  Tabela com a taxa do CPMF */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRCPMFCCR"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 641,
                            INPUT "",
                            INPUT YES).

             RETURN "NOK".
         END.

    ASSIGN tab_dtinipmf = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
           tab_dtfimpmf = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
           tab_txcpmfcc = IF p-data >= tab_dtinipmf AND
                             p-data <= tab_dtfimpmf
                             THEN DECIMAL(SUBSTR(craptab.dstextab,23,13))
                             ELSE 0
           tab_txrdcpmf = IF p-data >= tab_dtinipmf AND
                             p-data <= tab_dtfimpmf
                             THEN DECIMAL(SUBSTR(craptab.dstextab,38,13))
                             ELSE 1
           tab_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  /* 0 = abona
                                                                  1 = nao abona */
           tab_dtiniabo = DATE(INT(SUBSTRING(craptab.dstextab,56,2)),
                               INT(SUBSTRING(craptab.dstextab,53,2)),
                               INT(SUBSTRING(craptab.dstextab,59,4))) /* data de inicio do abono */
    
          p-vlliquid = TRUNCATE(p-vlcalcul * tab_txrdcpmf,2)
          p-vldoipmf = p-vlcalcul - p-vlliquid
          p-cfrvipmf = tab_txrdcpmf.

    RETURN "OK".

END PROCEDURE. /* Fim calcula_cpmf */



PROCEDURE segunda_via:
    DEFINE INPUT  PARAM par_cdcooper        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt        AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEFINE INPUT  PARAM par_nrrecben        AS DEC FORMAT "zzzzzzzzzz9" NO-UNDO.
    DEFINE INPUT  PARAM par_nrbenefi        AS DEC FORMAT "zzzzzzzzz9"  NO-UNDO.
    DEFINE INPUT  PARAM par_tpsolici        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_cdmotsol        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_nmarquiv        AS CHAR                     NO-UNDO.

    DEFINE VARIABLE aux_contador            AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE rel_dslocdat            AS CHARACTER FORMAT "x(80)" NO-UNDO.
    DEFINE VARIABLE rel_escolhas            AS LOGICAL
                                               FORMAT "(X) - /( ) - "   NO-UNDO.

    DEFINE VARIABLE rel_dsdopcao            AS CHARACTER  EXTENT 3
                    FORMAT "x(21)"
                    INIT["Perda/Extravio",
                         "Roubo",
                         "Esquecimento da senha"]                       NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         RETURN "NOK".

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = par_cdagenci
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapage   THEN
         RETURN "NOK".
    
    FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper   AND
                       crapcbi.nrrecben = par_nrrecben       AND
                       crapcbi.nrbenefi = par_nrbenefi
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcbi   THEN
         RETURN "NOK".

    OUTPUT STREAM str_1 TO VALUE(par_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.

    PUT STREAM str_1 SKIP(8).

    IF   par_tpsolici = 1   THEN /* Cartao */
         PUT STREAM str_1 "SOLICITACAO DE SEGUNDA VIA DE CARTAO" AT 24
                          SKIP(10).
    ELSE
    IF   par_tpsolici = 2   THEN /* Senha */
         PUT STREAM str_1 "SOLICITACAO DE SEGUNDA VIA DE SENHA"  AT 24
                          SKIP(10).

    PUT STREAM str_1 "NOME DO BENEFICIARIO: "   AT 8
                     crapcbi.nmrecben
                     SKIP(3)
                     "NUMERO DO BENEFICIO: "    AT 8.
        
    IF   par_nrbenefi <> 0   THEN
         PUT STREAM str_1 par_nrbenefi.

    PUT STREAM str_1 "No. NIT (se houver): " AT 45.
     
    IF   par_nrrecben <> 0   THEN
         PUT STREAM str_1 par_nrrecben.
                                                   
    PUT STREAM str_1 SKIP(5).

    DO aux_contador = 1 TO 3:

       /* Esquecimento de senha somente para 2a via de senha */
       IF   aux_contador = 3   AND
            par_tpsolici = 1   THEN
            NEXT.

       IF   aux_contador = par_cdmotsol   THEN
            rel_escolhas = YES.
       ELSE
            rel_escolhas = NO.

       PUT STREAM str_1 rel_escolhas                AT 8
                        rel_dsdopcao[aux_contador]
                        SKIP(2).
    END.

    PUT STREAM str_1 SKIP(5)
                     "AUTORIZACAO" AT 37
                     SKIP(4)
                     "Autorizo,     sob     minha     total"    AT 8
                     "     responsabilidade,     a"
                     SKIP(1)
                     crapcop.nmextcop                           AT 8
                     " - "
                     crapcop.nmrescop
                     ","
                     SKIP(1)
                     "cod "                                     AT 8
                     STRING(crapcop.cdagebcb,"9999") FORMAT "x(4)"
                     ", a receber a segunda via ".

    IF   par_tpsolici = 1   THEN
         PUT STREAM str_1 "do meu cartao pelo motivo acima"
                          SKIP(1)
                          "assinalado."                     AT  8.
    ELSE
    IF   par_tpsolici = 2   THEN
         PUT STREAM str_1 "da senha  de  meu  cartao  pelo"
                          SKIP(1)
                          "motivo acima assinalado."        AT  8.

    ASSIGN rel_dslocdat = TRIM(crapage.nmcidade) + ", " +
                          STRING(par_dtmvtolt,"99/99/9999").

           rel_dslocdat = FILL(" ",INT((80 - LENGTH(rel_dslocdat)) / 2)) +
                          rel_dslocdat.


    PUT STREAM str_1 SKIP(5)
                     rel_dslocdat
                     SKIP(5)
                     "______________________________"  AT 27
                     SKIP
                     crapcbi.nmrecben                  AT 28
                     SKIP.

    PAGE STREAM str_1.
    
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE.


PROCEDURE termo:
    DEFINE INPUT  PARAM par_cdcooper        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_cdoperad        AS CHAR                     NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt        AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEFINE INPUT  PARAM par_nrrecben        AS DEC FORMAT "zzzzzzzzzz9" NO-UNDO.
    DEFINE INPUT  PARAM par_nrbenefi        AS DEC FORMAT "zzzzzzzzz9"  NO-UNDO.
    DEFINE INPUT  PARAM par_cdaltcad        AS INT                      NO-UNDO.
    DEFINE INPUT  PARAM par_nmarquiv        AS CHAR                     NO-UNDO.
     

    DEFINE VARIABLE aux_contador            AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE rel_nrdconta            AS CHARACTER FORMAT "x(10)" NO-UNDO.
    DEFINE VARIABLE rel_dslocdat            AS CHARACTER FORMAT "x(80)" NO-UNDO.
    DEFINE VARIABLE rel_escolhas            AS LOGICAL
                                               FORMAT "(X) - /( ) - "   NO-UNDO.

    DEFINE VARIABLE rel_dsdopcao            AS CHARACTER  EXTENT 2
                    FORMAT "x(20)"
                    INIT["CARTAO MAGNETICO",
                         "CONTA-CORRENTE No. "]                         NO-UNDO.

    DEFINE VARIABLE aux_nmrecben            AS CHAR      FORMAT "x(40)" NO-UNDO.
    DEFINE VARIABLE aux_nmoperad            AS CHAR      FORMAT "x(60)" NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop   THEN
         RETURN "NOK".

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = par_cdagenci
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapage   THEN
         RETURN "NOK".
    
    FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper   AND
                       crapcbi.nrrecben = par_nrrecben       AND
                       crapcbi.nrbenefi = par_nrbenefi
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcbi   THEN
         RETURN "NOK".

    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                
    IF   NOT AVAILABLE crapope   THEN
         RETURN "NOK".
                       

    OUTPUT STREAM str_1 TO VALUE(par_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.

    PUT STREAM str_1 SKIP(5).

    IF   par_cdaltcad = 1   OR    /* C/C -> Cartao */
         par_cdaltcad = 9   THEN  /* Cartao -> C/C */
         PUT STREAM str_1 "TERMO DE OPCAO" AT 35
                          SKIP(3).  /*(10)*/
    ELSE
    IF   par_cdaltcad = 2   THEN /* C/C -> C/C */
         PUT STREAM str_1 "SOLICITACAO DE ALTERACAO DE CONTA CORRENTE" AT 22
                          SKIP(1)
                          "PARA RECEBIMENTO DE BENEFICIO" AT 29
                          SKIP(3). /*(10)*/

    PUT STREAM str_1 "NOME DO BENEFICIARIO: "   AT 8
                     crapcbi.nmrecben
                     SKIP(2)
                     "NUMERO DO BENEFICIO: "    AT 8.
        
    IF   par_nrbenefi <> 0   THEN
         PUT STREAM str_1 par_nrbenefi.

    PUT STREAM str_1 "No. NIT (se houver): " AT 45.
     
    IF   par_nrrecben <> 0   THEN
         PUT STREAM str_1 par_nrrecben.
                                                   
    PUT STREAM str_1 SKIP(6).

    IF   par_cdaltcad = 1   OR
         par_cdaltcad = 9   THEN
         PUT STREAM str_1 "Alteracao de  Modalidade  de  Pagamento  -  " AT 8
                          "(SOMENTE  NA  PROPRIA" SKIP(1)
                          "COOPERATIVA QUE DETEM O PAGAMENTO DO BENEFICIO)." AT 8
                          SKIP(5).
    ELSE
    IF   par_cdaltcad = 2   THEN
         PUT STREAM str_1 "Alteracao  de  Conta  corrente  para  recebimento  " AT 8
                          "do   beneficio"
                          SKIP(1)
                          "(SOMENTE  NA  PROPRIA  COOPERATIVA  QUE  " AT 8
                          "DETEM  O  PAGAMENTO   DO" SKIP(1)
                          "BENEFICIO)." AT 8
                          SKIP(3).


    IF   par_cdaltcad = 1   OR
         par_cdaltcad = 9   THEN
         DO:
             PUT STREAM str_1 "PARA:" AT 8 SKIP(1).

             DO aux_contador = 1 TO 2:

                IF   aux_contador = 1   AND
                     par_cdaltcad = 1   THEN
                     ASSIGN rel_escolhas = YES 
                            rel_nrdconta = "".
                ELSE
                IF   aux_contador = 2   AND
                     par_cdaltcad = 9   THEN
                     ASSIGN rel_escolhas = YES
                            rel_nrdconta = STRING(crapcbi.nrnovcta,"zzzz,zzz,9").
                ELSE
                     ASSIGN rel_escolhas = NO
                            rel_nrdconta = "".

                PUT STREAM str_1 rel_escolhas               AT 8
                                 rel_dsdopcao[aux_contador]
                                 rel_nrdconta
                                 SKIP(1).

             END.
         END.
    ELSE
    IF   par_cdaltcad = 2   THEN
         DO:
             PUT STREAM str_1 "DE:" AT 8 SKIP(1)
                              rel_dsdopcao[2] AT 8
                              STRING(crapcbi.nrdconta,"zzzz,zzz,9") FORMAT "x(10)"
                              SKIP(2)
                              "PARA:" AT 8 SKIP(1)
                              rel_dsdopcao[2] AT 8
                              STRING(crapcbi.nrnovcta,"zzzz,zzz,9") FORMAT "x(10)"
                              SKIP(1).
         END.



    PUT STREAM str_1 SKIP(4)
                     "AUTORIZACAO" AT 37
                     SKIP(4)
                     "Autorizo,     sob     minha     total"    AT 8
                     "     responsabilidade,     a"
                     SKIP(1)
                     crapcop.nmextcop                           AT 8
                     " - "
                     crapcop.nmrescop
                     ","
                     SKIP(1)
                     "cod "                                     AT 8
                     STRING(crapcop.cdagebcb,"9999") FORMAT "x(4)"
                     ", a efetuar a alteracao ".

    IF   par_cdaltcad = 1   OR
         par_cdaltcad = 9   THEN
         PUT STREAM str_1 "assinalada, relativa ao beneficio" SKIP(1)
                          "acima citado."  AT 8
                          SKIP(1).
    ELSE
    IF   par_cdaltcad = 2   THEN
         PUT STREAM str_1 "  da    conta    corrente    para" SKIP(1)
                          "recebimento do beneficio acima citado." AT 8 SKIP(1).

    ASSIGN rel_dslocdat = TRIM(crapage.nmcidade) + ", " +
                          STRING(par_dtmvtolt,"99/99/9999").

           rel_dslocdat = FILL(" ",INT((80 - LENGTH(rel_dslocdat)) / 2)) +
                          rel_dslocdat.

    ASSIGN aux_nmrecben = TRIM(crapcbi.nmrecben).
           
           aux_nmrecben = FILL(" ",INT((40 - LENGTH(crapcbi.nmrecben)) / 2)) +
                          aux_nmrecben.

           
    ASSIGN aux_nmoperad = TRIM(crapope.nmoperad).

           aux_nmoperad = FILL(" ",INT((40 - LENGTH(crapope.nmoperad)) / 2)) +
                          aux_nmoperad.

    PUT STREAM str_1 SKIP(5)
                     rel_dslocdat
                     SKIP(5)
                     "_______________________________________"  AT 22
                     SKIP
                     aux_nmrecben                               AT 22 
                     SKIP(5)
                     "_______________________________________"  AT 22
                     SKIP
                     aux_nmoperad                               AT 22        
                     SKIP. 

    PAGE STREAM str_1.
    
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE.

