/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap84.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes/Evandro
   Data    : Outubro/2005                    Ultima atualizacao: 20/10/2010 

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Recebimento de Beneficios

   Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               17/01/2007 - Eliminar tabela craptab "CORRESPOND" para cada PAC,
                            acessar campo crapage.cdagecbn (Evandro).
                            
               20/10/2010 - Incluido caminho completo nas referencias do
                            diretorio spool (Elton).
   
               30/09/2011 - Alterar diretorio spool para 
                            /usr/coop/sistema/siscaixa/web/spool (Fernando).
   ......................................................................... */

/*--------------------------------------------------------------------------*/
/*  b1crap84.p   - Recebimento de Beneficios                                */
/*--------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF STREAM str_1.

DEFINE VARIABLE i-cod-erro       AS INT                                NO-UNDO.
DEFINE VARIABLE i-nro-lote       LIKE craplft.nrdolote                 NO-UNDO.
DEFINE VARIABLE i-tplotmov       LIKE craplot.tplotmov                 NO-UNDO.
DEFINE VARIABLE c-desc-erro      AS CHAR                               NO-UNDO.
DEFINE VARIABLE p-literal        AS CHAR                               NO-UNDO.
DEFINE VARIABLE p-ult-sequencia  AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_contador     AS INTE                               NO-UNDO.
DEFINE VARIABLE aux_nmarquiv     AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_setlinha     AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_linha_envio  AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_nrdocmto     AS DECIMAL                            NO-UNDO.
DEF    VAR      i-time           AS INTE                               NO-UNDO.

DEF VAR aux_tam_campo            AS INTE                               NO-UNDO.
DEF VAR aux_vldocto_int          AS INTE                               NO-UNDO.
DEF VAR aux_vldocto_char         AS CHAR                               NO-UNDO.
DEF VAR aux_tam_payload          AS INTE                               NO-UNDO.
DEF VAR aux_payload              AS CHAR                               NO-UNDO.
DEF VAR aux_nrconven             AS INTE FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nragenci             AS INTE FORMAT "9999"      /* 4 N */  NO-UNDO.
DEF VAR aux_nrdaloja             AS INTE FORMAT "999999"    /* 6 N */  NO-UNDO.
DEF VAR aux_nrpdv                AS INTE FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_cdoperad             AS INTE FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nsupdv               AS INTE FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_nrversao             AS INTE                               NO-UNDO.
DEF VAR aux_tipo_trn             AS CHAR FORMAT "x(01)"                NO-UNDO.
DEF VAR in99                     AS INTE                               NO-UNDO.
DEF VAR aux_transacao            AS CHAR FORMAT "x(03)"                NO-UNDO. 
DEF VAR i-nro-rotulos            AS INTE                               NO-UNDO.
DEF VAR c_linha                  AS CHAR                               NO-UNDO.
DEF VAR aux_erro                 AS INTE                               NO-UNDO.
DEF VAR aux_tamanho              AS INTE                               NO-UNDO.
DEF VAR aux_posicao              AS INTE                               NO-UNDO.
DEF VAR c_autentica              AS CHAR                               NO-UNDO.


FORM aux_setlinha  FORMAT "x(150)"
     WITH FRAME AA WIDTH 152 NO-BOX NO-LABELS.

PROCEDURE executa-consulta.
    DEF INPUT  PARAM v_coop         AS CHAR.
    DEF INPUT  PARAM v_pac          AS INT.
    DEF INPUT  PARAM v_caixa        AS INT.
    DEF INPUT  PARAM v_operador     AS CHAR.
    DEF INPUT  PARAM v_cartao       AS CHAR.
    DEF INPUT  PARAM v_senha        AS CHAR.
    DEF OUTPUT PARAM v_valor        AS DEC.
    DEF OUTPUT PARAM p-autentica    AS CHAR.
    
    DEF OUTPUT PARAM p-autchave     AS INTE.
    DEF OUTPUT PARAM p-cdchave      AS CHAR.
    
    DEF VAR v_senha_crip            AS CHAR          NO-UNDO.
           
    RUN elimina-erro (INPUT v_coop,
                      INPUT v_pac,
                      INPUT v_caixa).

    /* Verifica cartao */
    IF  v_cartao = ""  THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "O numero do cartao deve ser preenchido".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.

    /* Verifica senha */
    IF  v_senha = ""  THEN
        DO:
           ASSIGN i-cod-erro  = 088
                  c-desc-erro = " ".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.

    /* Para os 2 tipos de leitoras */
    IF   LENGTH(v_cartao) > 37 THEN
         ASSIGN v_cartao = SUBSTR(v_cartao,2,37).
    ELSE
         ASSIGN SUBSTRING(v_cartao,17,1) = "=" + SUBSTRING(v_cartao,17,1).

    /*-- Teste
    ASSIGN v_cartao = "4001999999999999=68001002101796614014". 
    ASSIGN v_cartao = "4001990000000227=07121260000059390790".
    ---*/
    RUN criptografa_senha(INPUT  v_cartao,
                          INPUT  v_senha,
                          OUTPUT v_senha_crip).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Erro de criptografia.".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.
 
    ASSIGN i-time = TIME.
    RUN processa_envio_recebimento(INPUT  v_coop,
                                   INPUT  1,
                                   INPUT  v_pac,
                                   INPUT  v_caixa,
                                   INPUT  v_operador,
                                   INPUT  v_cartao,
                                   INPUT  v_senha_crip,
                                   OUTPUT  p-autchave,
                                   OUTPUT  p-cdchave,
                                   INPUT-OUTPUT v_valor).
       
    RELEASE crapbcx.
        
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK".

    /* Remover arquivo */
    IF c-desc-erro <> " " THEN
       RETURN "NOK".
    
    IF  c_linha      = " " AND
        aux_setlinha = " " THEN DO: /* TIME OUT */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Tempo Excedido - Execute Pendencias ".
        RUN cria-erro (INPUT v_coop,
                       INPUT v_pac,
                       INPUT v_caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    /* A partir da posicao 113, dados para autenticar - Consulta */
    ASSIGN aux_tam_payload = aux_tam_payload - 113  /* 128 */                 
           p-autentica     = SUBSTR(c_linha,113,aux_tam_payload).         

    ASSIGN aux_tamanho  =  LENGTH(p-autentica) / 38.
    ASSIGN aux_posicao  = 1.
    ASSIGN aux_contador = 1.
    /* Retirar caracteres nao reconhecidos - autenticadora */
    p-autentica = REPLACE(p-autentica,"="," ").
    p-autentica = REPLACE(p-autentica,"&","E").  
 
    DO  WHILE aux_contador LE aux_tamanho:
        ASSIGN c_autentica  = c_autentica + 
                   STRING(SUBSTR(p-autentica,aux_posicao ,38),"x(38)") + 
                   "          ". /* Tamanho 48 */
        ASSIGN aux_posicao  = aux_posicao  + 38 + 5.
        ASSIGN aux_contador = aux_contador + 1.
    END.
      
    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE 10:
        ASSIGN c_autentica  = c_autentica + STRING(" ","x(48)").
        ASSIGN aux_contador = aux_contador + 1.
    END.
       
    ASSIGN p-autentica = c_autentica. 

    RETURN "OK".
END PROCEDURE.

PROCEDURE executa-recebimento.
    DEF INPUT        PARAM v_coop         AS CHAR.
    DEF INPUT        PARAM v_pac          AS INT.
    DEF INPUT        PARAM v_caixa        AS INT.
    DEF INPUT        PARAM v_operador     AS CHAR.
    DEF INPUT        PARAM v_cartao       AS CHAR.
    DEF INPUT        PARAM v_senha        AS CHAR.
    DEF INPUT-OUTPUT PARAM v_valor        AS DEC.
    DEF OUTPUT       PARAM p-autentica    AS CHAR.
    DEF OUTPUT       PARAM p-docto        AS INTE.
    
    DEF OUTPUT       PARAM p-autchave     AS INTE.
    DEF OUTPUT       PARAM p-cdchave      AS CHAR.
    
    DEF VAR v_senha_crip           AS CHAR          NO-UNDO.

    RUN elimina-erro (INPUT v_coop,
                      INPUT v_pac,
                      INPUT v_caixa).

    /* Verifica cartao */
    IF  v_cartao = ""  THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "O numero do cartao deve ser preenchido".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.

    /* Verifica senha */
    IF  v_senha = ""  THEN
        DO:
           ASSIGN i-cod-erro  = 088
                  c-desc-erro = " ".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.

    /* Verifica valor */
    IF  v_valor = 0  THEN
        DO:
           ASSIGN i-cod-erro  = 269
                  c-desc-erro = " ".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.

    /* Para os 2 tipos de leitoras */
    IF   LENGTH(v_cartao) > 37 THEN
         ASSIGN v_cartao = SUBSTR(v_cartao,2,37).
    ELSE
         ASSIGN SUBSTRING(v_cartao,17,1) = "=" + SUBSTRING(v_cartao,17,1).

           /*
    ASSIGN v_cartao = "4001999999999999=68001002101796614014". 
    ASSIGN v_cartao = "4001990000000227=07121260000059390790".
    */
    
    RUN criptografa_senha(INPUT  v_cartao,
                          INPUT  v_senha,
                          OUTPUT v_senha_crip).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Erro de criptografia.".

           RUN cria-erro (INPUT v_coop,
                          INPUT v_pac,
                          INPUT v_caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).

           RETURN "NOK".
        END.
        
    ASSIGN i-time = TIME.
    RUN processa_envio_recebimento(INPUT v_coop,
                                   INPUT 2,
                                   INPUT v_pac,
                                   INPUT v_caixa,
                                   INPUT v_operador,
                                   INPUT v_cartao,
                                   INPUT v_senha_crip,
                                   OUTPUT  p-autchave,
                                   OUTPUT  p-cdchave,
                                   INPUT-OUTPUT v_valor).

    RELEASE crapbcx.
    
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK".

    /* Remover arquivo */
    IF c-desc-erro <> " " THEN
       RETURN "NOK".
    
    IF  c_linha      = " " AND
        aux_setlinha = " " THEN DO: /* TIME OUT */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Tempo Excedido - Execute Pendencias ".
        RUN cria-erro (INPUT v_coop,  
                       INPUT v_pac,        
                       INPUT v_caixa,      
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    /* A partir da posicao 128, dados para autenticar - Recebimento */
    ASSIGN aux_tam_payload = aux_tam_payload - 128
           p-autentica     = SUBSTR(c_linha,128,aux_tam_payload).

    ASSIGN aux_tamanho  =  LENGTH(p-autentica) / 38.
    ASSIGN aux_posicao  = 1.
    ASSIGN aux_contador = 1.
    /* Retirar caracteres nao reconhecidos - autenticadora */
    p-autentica = REPLACE(p-autentica,"="," ").
    p-autentica = REPLACE(p-autentica,"&","E").  
    c_autentica = " ".
    

    DO  WHILE aux_contador LE aux_tamanho:
        ASSIGN c_autentica = c_autentica + 
               STRING(SUBSTR(p-autentica,aux_posicao,38),"x(38)") +
               "          ". /* Tamanho 48 */
        ASSIGN aux_posicao  = aux_posicao + 5 + 38.
        ASSIGN aux_contador = aux_contador + 1.
    END.

                
    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE 10:
        ASSIGN c_autentica  = c_autentica + STRING(" ","x(48)").
        ASSIGN aux_contador = aux_contador + 1.
    END.
       
    ASSIGN p-autentica = c_autentica 
           p-docto     = INTE(TIME).

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE criptografa_senha.
    DEF INPUT  PARAM cartao      AS CHAR.
    DEF INPUT  PARAM senha       AS CHAR.
    DEF OUTPUT PARAM senha_crip  AS CHAR.

    DEF VAR retorno        AS INT                   NO-UNDO.
    DEF VAR dukpt          AS CHAR                  NO-UNDO.
    
    /* Chama DLL que faz criptografia da senha */
    RUN fontes/coban_inss.p (INPUT  SUBSTRING(cartao,1,16),
                                                INPUT  senha,
                                                OUTPUT retorno,
                                                OUTPUT dukpt).

    IF  retorno <> 0  THEN
        RETURN "NOK".
    ELSE
        senha_crip = dukpt.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE processa_envio_recebimento.
    DEF INPUT        PARAM p-cooper           AS CHAR.
    DEF INPUT        PARAM p-operacao         AS INT.
    DEF INPUT        PARAM p-cod-agencia      AS INTE.
    DEF INPUT        PARAM p-nro-caixa        AS INTE.
    DEF INPUT        PARAM p-cod-operador     AS CHAR.
    DEF INPUT        PARAM p-cartao           AS CHAR.
    DEF INPUT        PARAM p-senha            AS CHAR.
    DEF OUTPUT       PARAM p-autchave         AS INTE. /* Nro Aut.Corresp. */
    DEF OUTPUT       PARAM p-cdchave          AS CHAR. /* Chave Corresp.   */
    DEF INPUT-OUTPUT PARAM p-valor            AS DEC.

    /*--- p-operacao: 1 - Consulta / 2 - Recebimento ---*/

    DEFINE VARIABLE c_autentica               AS CHARACTER      NO-UNDO.
    DEFINE VARIABLE aux_posicao               AS INTEGER        NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.           

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        
        FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                                crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
                                crapbcx.cdagenci = p-cod-agencia     AND
                                crapbcx.nrdcaixa = p-nro-caixa       AND
                                crapbcx.cdopecxa = p-cod-operador    AND
                                crapbcx.cdsitbcx = 1  
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF   NOT AVAILABLE crapbcx   THEN  DO:
             IF   LOCKED crapbcx     THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
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
             ELSE DO:
                  ASSIGN i-cod-erro  = 701
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

    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
    
    ASSIGN p-autchave  = 0 
           p-cdchave   = " ".
     
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "USUARI"          AND
                       craptab.cdempres = 11                AND
                       craptab.cdacesso = "CORRESPOND"      AND
                       craptab.tpregist = 000               NO-LOCK NO-ERROR.

    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
    
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
     
    ASSIGN  aux_nrpdv    = p-nro-caixa
            aux_nsupdv   = crapbcx.nrsequni
            aux_cdoperad = INT(p-cod-operador).
    
    ASSIGN aux_linha_envio = " ".
    
    IF  p-operacao = 1 THEN
        ASSIGN  aux_transacao    = "020"    /* Consulta INSS    */
                aux_tipo_trn     = "C" 
                i-nro-rotulos    = 3  
                aux_vldocto_int  = 0
                aux_vldocto_char = STRING(aux_vldocto_int) 
                aux_tam_payload  = 102.
    ELSE
        ASSIGN  aux_transacao    = "284"    /* Recebimento INSS   */
                aux_tipo_trn     = "P" 
                i-nro-rotulos    = 4  
                aux_vldocto_int  = p-valor  * 100 
                aux_vldocto_char = STRING(aux_vldocto_int) 
                aux_tam_campo    = LENGTH(aux_vldocto_char) 
                aux_tam_payload  = 111 + aux_tam_campo.
       
    /*---------Teste
    ASSIGN aux_nrconven = 11357            
           aux_nragenci = 6800
           aux_nrdaloja = 1111
           aux_nrpdv = 1.
    -------------*/
    
    /*---- ENVIO ----*/
    ASSIGN aux_linha_envio = 
               STRING(aux_nrconven,"999999999")               +        
               STRING(aux_nragenci,"9999")                    +         
               STRING(aux_nrdaloja,"999999")                  +       
               STRING(aux_nrpdv,"99999999")                   +      
               STRING(aux_cdoperad,"999999999")               +          
               STRING(aux_nsupdv,"99999999")                  +       
               "00000000"                                     +                               "0000"                                         +                                "0000"                                         +                                STRING(SUBSTR(aux_transacao,1,4),"x(04)")      +   
               STRING(aux_nrversao,"999")                     +                                 STRING(aux_tipo_trn,"x")                       +                                 "0"                                            +                                "000"                                          +                                 STRING(i-nro-rotulos,"999")                    +
               STRING(aux_vldocto_int,"99999999999999999")    +              
               STRING(aux_tam_payload,"999999999").             
   
    ASSIGN aux_payload = "00001000880037" +
                          STRING(p-cartao,"x(37)").
    
    IF  p-operacao = 2  THEN     /* Recebimento */
        ASSIGN aux_payload = aux_payload + 
                      "00117"      +  /* Rotulo Valor Documento          */
                      STRING(aux_tam_campo,"9999") + /* Tamanho vlr.pago */
                      aux_vldocto_char.
  
    ASSIGN aux_payload   
                       = aux_payload     + "00155" + "0016" + 
                        STRING(SUBSTRING(p-senha,1,16),"x(16)") +
                        "00180" + "0016" + 
                        STRING(SUBSTRING(p-senha,17,16),"x(16)").

    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE (aux_tam_payload - 1):
        ASSIGN aux_linha_envio = aux_linha_envio + 
                                 SUBSTR(aux_payload,aux_contador,1).
        ASSIGN aux_contador = aux_contador + 1.
    END.
    ASSIGN aux_linha_envio = aux_linha_envio + "@"
           aux_setlinha    = " " .

    ASSIGN aux_nmarquiv = "/usr/coop/sistema/siscaixa/web/spool/" +  
                          crapcop.dsdircop +
                          "INSS" +
                          STRING(p-cod-agencia,"999") + 
                          STRING(p-nro-caixa,"999")   +
                          STRING(i-time,"99999")      + 
                          ".ret".
    
    /*----------Teste 
    IF  p-operacao = 1  THEN /* Consulta */
        DO:
            OUTPUT STREAM str_1 TO 
            VALUE("/usr/coop/viacredi/siscaixa/web/spool/evandro_cons.env").
            PUT STREAM str_1 aux_linha_envio FORMAT "x(296)" SKIP.
            OUTPUT STREAM str_1 CLOSE.
        END.
    ELSE
        DO:
            OUTPUT STREAM str_1 TO 
            VALUE("/usr/coop/viacredi/siscaixa/web/spool/evandro_receb.env").
            PUT STREAM str_1 aux_linha_envio FORMAT "x(296)" SKIP.
            OUTPUT STREAM str_1 CLOSE.
        END.

    IF  p-operacao = 1  THEN /* Consulta */
        aux_nmarquiv="/usr/coop/viacredi/siscaixa/web/spool/evandro.ret".
        
    ELSE                     /* Recebimento */

        aux_nmarquiv="/usr/coop/viacredi/siscaixa/web/spool/evandro2.ret".
    
    -------------------------------*/
        
    UNIX SILENT VALUE("/usr/local/bin/mtcoban.sh "  +
                      '"' + STRING(aux_linha_envio) + '" '   +
                      '"' + TRIM(aux_nmarquiv)      + '" '   +
                      '"' + TRIM(crapcop.dsdircop)  + '"').

    /*--- RECEBIMENTO  --*/
    
    ASSIGN aux_contador = 1.
    
    ASSIGN c-desc-erro  = " ".
    ASSIGN c_linha      = " ".
    RETORNO:
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE RETORNO:
      
         IF  SEARCH (aux_nmarquiv) <> ?  THEN DO:
          
             INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
             SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
             /* Primeira linha - Tamanho 102 */
  
             IF   SUBSTR(aux_setlinha,70,3) <> "000" THEN DO: 
                  /* Retorno com erro */     
                  ASSIGN aux_erro        = INT(SUBSTR(aux_setlinha,70,3)).
                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = "Erro nao previsto " +
                                        STRING(aux_erro,"999").
                     
            END. 

            ASSIGN  p-cdchave       = SUBSTR(aux_setlinha,45,8)
                    p-autchave      = INT(SUBSTR(aux_setlinha,57,4))
                    aux_tam_payload = INT(SUBSTR(aux_setlinha,93,9))
                    c_linha         = "".

             SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
             /* Demais linhas - tamanho 38 */

             DO  WHILE TRUE   ON ENDKEY UNDO, LEAVE  RETORNO: 
                 ASSIGN c_linha = c_linha + 
                        STRING(SUBSTR(aux_setlinha,1,38),"x(38)").
                 SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.

             END.  /* Do while */
              
             LEAVE RETORNO.
              
         END.

         ASSIGN aux_contador = aux_contador + 1.
         IF  aux_contador > 900 THEN
             LEAVE RETORNO.

    END.   /* Do while */

    INPUT STREAM str_1 CLOSE.
     
     IF  c-desc-erro <> " "  THEN DO:
        IF  aux_tam_payload > 0 AND
            SUBSTR(c_linha,1,1) = "Z" THEN DO: /* Mensagem de ERRO COBAN */
            ASSIGN c-desc-erro = SUBSTR(c_linha,9,3) + "  - " +
                                 TRIM(SUBSTR(c_linha,15,40)).
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,  
                           INPUT p-nro-caixa,   
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        ELSE
            DO:
               FIND crapcbe WHERE
                    crapcbe.cdcooper = crapcop.cdcooper  AND
                    crapcbe.cdcritic = aux_erro          NO-LOCK NO-ERROR.
              
               IF  AVAIL crapcbe THEN 
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = STRING(crapcbe.cdcritic,"999") + "-" + 
                                        STRING(crapcbe.cdorigem,"9")  + "-" +
                                        TRIM(crapcbe.dscritic).
   
               RUN cria-erro (INPUT p-cooper,
                              INPUT p-cod-agencia,  
                              INPUT p-nro-caixa,  
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
             END.
    END.    

END PROCEDURE.

PROCEDURE grava-comprovante.
    DEF INPUT PARAM p-recid       AS RECID.
    DEF INPUT PARAM p-comprovante AS CHAR.

    FIND crapaut WHERE RECID(crapaut) = p-recid EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAILABLE crapaut  THEN
        DO:
           ASSIGN crapaut.dslitera = p-comprovante.
           RELEASE crapaut.
        END.

END PROCEDURE.

PROCEDURE gera-recebimento.
    DEF INPUT PARAM p-cooper           AS CHAR.
    DEF INPUT PARAM p-cod-operador     AS CHAR.
    DEF INPUT PARAM p-cod-agencia      AS INTE.
    DEF INPUT PARAM p-nro-caixa        AS INTE.
    DEF INPUT PARAM p-cartao           AS CHAR.
    DEF INPUT PARAM p-valor            AS DEC.   /* Valor */
    DEF INPUT PARAM p-tipo-docto       AS INTE. /* 1- tit, 2-fat, 3- inss */
    DEF INPUT PARAM p-comprovante      AS CHAR. /* Literal aut.corresp.*/
    DEF INPUT PARAM p-sequencia        AS INT.
    DEF INPUT PARAM p-autchave         AS INT.
    DEF INPUT PARAM p-cdchave          AS CHAR.
    DEF OUTPUT PARAM p-registro        AS RECID.
    
    ASSIGN i-nro-lote = 25000 + p-nro-caixa
           i-tplotmov = 31.
                   
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
            
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtolt  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote        NO-ERROR.

    IF  NOT AVAIL craplot  THEN 
        DO:
           CREATE craplot.
           ASSIGN craplot.cdcooper = crapcop.cdcooper
                  craplot.dtmvtolt = crapdat.dtmvtolt
                  craplot.cdagenci = p-cod-agencia   
                  craplot.cdbccxlt = 11              
                  craplot.nrdolote = i-nro-lote
                  craplot.tplotmov = i-tplotmov
                  craplot.cdoperad = p-cod-operador
                  craplot.cdhistor = 0
                  craplot.nrdcaixa = p-nro-caixa
                  craplot.cdopecxa = p-cod-operador.
        END.
    
    CREATE crapcbb.
    ASSIGN crapcbb.cdcooper = crapcop.cdcooper
           crapcbb.dtmvtolt = craplot.dtmvtolt
           crapcbb.cdagenci = craplot.cdagenci
           crapcbb.cdbccxlt = craplot.cdbccxlt
           crapcbb.nrdolote = craplot.nrdolote
           crapcbb.cdhistor = 459
           crapcbb.cdopecxa = p-cod-operador 
           crapcbb.nrdcaixa = p-nro-caixa
           crapcbb.nrdmaqui = p-nro-caixa
           crapcbb.cdbarras = p-cartao
           crapcbb.valorpag = p-valor
           crapcbb.valordoc = p-valor
           crapcbb.tpdocmto = p-tipo-docto /* 1- titulo , 2-fatura, 3- inss */
           crapcbb.nrseqdig = craplot.nrseqdig + 1
           crapcbb.dsautent = p-comprovante
           crapcbb.nrautdoc = p-sequencia
           crapcbb.autchave = p-autchave
           crapcbb.cdchave  = p-cdchave 
           crapcbb.nrsequen = craplot.nrseqdig + 1
           craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompdb = craplot.vlcompdb + p-valor.
           craplot.vlinfodb = craplot.vlinfodb + p-valor.

   ASSIGN   p-registro = RECID(crapcbb).
   
    /* Libera as tabelas */
   RELEASE crapcbb.
   RELEASE craplot.

   RETURN "OK".

END PROCEDURE.

PROCEDURE gera-retorno-autenticacao.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-transacao        AS CHAR.
    DEF INPUT  PARAM p-registro         AS RECID.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */
               
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
   
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                            crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
                            crapbcx.cdagenci = p-cod-agencia     AND
                            crapbcx.nrdcaixa = p-nro-caixa       AND
                            crapbcx.cdopecxa = p-cod-operador    AND
                            crapbcx.cdsitbcx = 1                 NO-ERROR. 

    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper   AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CORRESPOND"       AND
                       craptab.tpregist = 000                NO-LOCK NO-ERROR.
 
    IF  AVAIL craptab   THEN                    
        ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
               aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
    
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.

    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
 
    ASSIGN  aux_nrpdv    = p-nro-caixa
            aux_nsupdv   = crapbcx.nrsequni
            aux_cdoperad = INT(p-cod-operador)
            i-time       = TIME.

    ASSIGN  aux_transacao   = p-transacao   /* 9900  */
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.

    ASSIGN aux_tipo_trn = "X".
          

    /*--- Teste
    ASSIGN aux_nrconven = 11357      
           aux_nragenci = 6800
           aux_nrdaloja = 1111
           aux_nrpdv = 1.
    -------------*/
    
    RUN processa_retorno_autenticacao ( INPUT p-cooper,
                                        INPUT  p-cod-agencia,
                                        INPUT  p-nro-caixa,
                                        OUTPUT p-autchave,    
                                        OUTPUT p-cdchave).  
     
    IF c-desc-erro <> " " THEN
       RETURN "NOK".
    
    IF  c_linha      = " " AND
        aux_setlinha = " " THEN DO: /* TIME OUT */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Tempo Excedido - Execute Pendencias ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    FIND crapcbb WHERE RECID(crapcbb) = p-registro NO-ERROR.

    ASSIGN crapcbb.flgrgfim   = YES.
    
    RELEASE crapcbb.
         
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE processa_retorno_autenticacao.

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */
               
    FIND crapcop WHERE
         crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /*---- ENVIO ----*/
    ASSIGN aux_linha_envio = 
               STRING(aux_nrconven,"999999999") +        
               STRING(aux_nragenci,"9999")      +         
               STRING(aux_nrdaloja,"999999")    +       
               STRING(aux_nrpdv,"99999999")     +      
               STRING(aux_cdoperad,"999999999") +          
               STRING(aux_nsupdv,"99999999")    +       
               "00000000"                       +                     
               "0000"                           +                      
               "0000"                           +                      
               STRING(SUBSTR(aux_transacao,1,4),"x(04)")      +   
               STRING(aux_nrversao,"999")       +                             
               STRING(aux_tipo_trn,"x")         +                    
               "0"                              +                      
               "000"                            +                       
               STRING(i-nro-rotulos,"999")      +
               STRING(aux_vldocto_int,"99999999999999999") +              
               STRING(aux_tam_payload,"999999999").             
   
    IF  aux_tipo_trn = "P" THEN DO:  
        ASSIGN aux_contador = 1.
        DO  WHILE aux_contador LE (aux_tam_payload - 1):
            ASSIGN aux_linha_envio = aux_linha_envio + 
                                     SUBSTR(aux_payload,aux_contador,1).
            ASSIGN aux_contador = aux_contador + 1.
        END.
        ASSIGN aux_linha_envio = aux_linha_envio + "@".
    END.
     
    ASSIGN aux_nmarquiv = "/usr/coop/sistema/siscaixa/web/spool/" +
                          crapcop.dsdircop +
                          "INSS" +
                          STRING(p-cod-agencia,"999") + 
                          STRING(p-nro-caixa,"999")   +
                          STRING(i-time,"99999")      + 
                          ".ret".

    ASSIGN aux_setlinha  = " ".
    UNIX SILENT VALUE("/usr/local/bin/mtcoban.sh "  +
                      '"' + STRING(aux_linha_envio) + '" '   +
                      '"' + TRIM(aux_nmarquiv)      + '" '   +
                      '"' + TRIM(crapcop.dsdircop)  + '"').
    
    /*--- RECEBIMENTO  --*/
    
    ASSIGN aux_contador = 1.
    
    ASSIGN c-desc-erro  = " ".
    ASSIGN c_linha      = " ".
    RETORNO:
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE RETORNO:
      
         IF  SEARCH (aux_nmarquiv) <> ?  THEN DO:
          
             INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.
             SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
             /* Primeira linha - Tamanho 102 */
  
             IF   SUBSTR(aux_setlinha,70,3) <> "000" THEN DO: 
                  /* Retorno com erro */     
                  ASSIGN aux_erro    = INT(SUBSTR(aux_setlinha,70,3))
                         i-cod-erro  = 0
                         c-desc-erro = "Erro nao previsto " +
                                        STRING(aux_erro,"999").
                     
            END. 

            ASSIGN  p-cdchave       = SUBSTR(aux_setlinha,45,8)
                    p-autchave      = INT(SUBSTR(aux_setlinha,57,4))
                    aux_tam_payload = INT(SUBSTR(aux_setlinha,93,9))
                    c_linha         = "".

             SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
             /* Demais linhas - tamanho 38 */

             DO  WHILE TRUE   ON ENDKEY UNDO, LEAVE  RETORNO: 
                 ASSIGN c_linha = c_linha + 
                        STRING(SUBSTR(aux_setlinha,1,38),"x(38)").
                 SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.

             END.  /* Do while */
              
             LEAVE RETORNO.
              
         END.

         ASSIGN aux_contador = aux_contador + 1.
         IF  aux_contador > 900 THEN
             LEAVE RETORNO.

    END.   /* Do while */

    INPUT STREAM str_1 CLOSE.
    
    IF  c-desc-erro <> " "  THEN DO:
        IF  aux_tam_payload > 0 AND
            SUBSTR(c_linha,1,1) = "Z" THEN DO: /* Mensagem de ERRO COBAN */
            ASSIGN c-desc-erro = SUBSTR(c_linha,9,3) + "  - " +
                                 TRIM(SUBSTR(c_linha,15,40)).
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,  
                           INPUT p-nro-caixa,  
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        ELSE
            DO:
               
               FIND crapcbe WHERE
                    crapcbe.cdcooper = crapcop.cdcooper  AND
                    crapcbe.cdcritic = aux_erro          NO-LOCK NO-ERROR.
              
               IF  AVAIL crapcbe THEN 
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = STRING(crapcbe.cdcritic,"999") + "-" + 
                                        STRING(crapcbe.cdorigem,"9")  + "-" +
                                        TRIM(crapcbe.dscritic).
   
               RUN cria-erro (INPUT p-cooper,
                              INPUT p-cod-agencia,   
                              INPUT p-nro-caixa,  
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
             END.
    END.    

END PROCEDURE.




  


                                                                 
