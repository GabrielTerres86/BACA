/* .............................................................................
 
   Programa: siscaixa/web/dbo/b1crap80.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 01/08/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Correspondente Bancario

   Alteracoes: 20/09/2005 - Tratar o codigo de segmento do convenio (Julio)
               
               03/03/2006- tratamento para bloquetos de cobrança da
                           cooperativa (Julio)
                           
               23/10/2006 - Criticar sabado, domingo, feriado ou horario > 21h
                            (Evandro).

               17/01/2007 - Eliminar tabela craptab "CORRESPOND" para cada PAC,
                            acessar campo crapage.cdagecbn (Evandro).
                            
               29/08/2007 - Passagem de parametros para a procedure
                            identifica-titulo-coop (Evandro).

               24/03/2008 - Alterado para recibo da DARF nao mostrar as ultimas
                            linhas das informacoes vindas do Banco do Brasil
                            (Elton).

              17/10/2008 - Incluir leitura pelo modulo 11 quando Claro (Magui).
              
              08/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                           (David).

              11/03/2009 - Ajustes para unificacao dos bancos de dados
                           (Evandro).
                           
              20/10/2010 - Incluido caminho completo nas referencias do 
                           diretorio spool (Elton).             
              
              15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir 
                           LENGTH 34 (Guilherme).     
                          
              30/09/2011 - Alterar diretorio spool para
                           /usr/coop/sistema/siscaixa/web/spool (Fernando).  
                           
              22/05/2012 - Nova funcao muda_caracter para remocao de caracter 
                           alfa no codigo do operador. (David Kruger).      
                           
              19/04/2013 - Permitir pagamento de DARFs mesmo estando
                           na crapcon (Lucas).
                           
              11/06/2013 - Impedir pagamentos de convenios próprios pela 
                           rotina 80 (Lucas).
                           
              04/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).

			  01/08/2016 - Adicionado novo campo de arrecadacao GPS
                            conforme solicitado no chamado 460485. (Kelvin)

              03/01/2018 - M307 - Solicitaçao de senha do coordenador quando 
                             valor do pagamento for superior ao limite cadastrado 
                             na CADCOP / CADPAC
                            (Diogo - MoutS)
                           
   ......................................................................... */

/*--------------------------------------------------------------------------*/
/*  b1crap80.p   - Correspondente Bancario                                  */
/*--------------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEFINE VARIABLE i-cod-erro  AS INT    NO-UNDO.
DEFINE VARIABLE c-desc-erro AS CHAR   NO-UNDO.

DEF BUFFER crabcbb FOR crapcbb.

DEF VAR de-valor-calc       AS DEC    NO-UNDO.
DEF VAR p-nro-calculado     AS DEC    NO-UNDO.
DEF VAR p-nro-digito        AS INTE   NO-UNDO.
DEF VAR p-lista-digito      AS CHAR   NO-UNDO.
DEF VAR aux_erro            AS INTE   NO-UNDO.
DEF VAR aux_cod_agencia     AS INTE   NO-UNDO.
DEF VAR aux_nro_caixa       AS INTE   NO-UNDO.
DEF VAR in99                AS INTE   NO-UNDO.

DEF VAR p-literal           AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia     AS INTE  NO-UNDO.
DEF VAR p-registro          AS RECID NO-UNDO.

DEF VAR p-retorno           AS LOG    NO-UNDO.
DEF VAR de-p-titulo5        AS DEC    NO-UNDO.  
DEF VAR i-nro-lote         LIKE craplft.nrdolote                   NO-UNDO.
DEF VAR i-tplotmov         LIKE craplot.tplotmov                   NO-UNDO.
DEF VAR aux_dia             AS INTE   NO-UNDO.
DEF VAR aux_mes             AS INTE   NO-UNDO.
DEF VAR aux_ano             AS INTE   NO-UNDO.
DEF VAR aux_data            AS DATE   NO-UNDO.
DEF VAR aux_vlr_digitado    AS DEC    NO-UNDO.
DEF VAR de-campo            AS DEC FORMAT "99999999999999"      NO-UNDO.
DEF VAR dt-dtvencto         AS DATE    NO-UNDO.
DEF VAR aux_codigo_barras   AS DEC     NO-UNDO.
DEF VAR c_autentica         AS CHAR    NO-UNDO.

DEF VAR c_linha             AS CHAR    NO-UNDO.

DEF STREAM str_1.
DEF VAR aux_contador        AS INTE    NO-UNDO.
DEF VAR aux_nrconven        AS INTE FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nragenci        AS INTE FORMAT "9999"      /* 4 N */  NO-UNDO.
DEF VAR aux_nrdaloja        AS INTE FORMAT "999999"    /* 6 N */  NO-UNDO.
DEF VAR aux_nrpdv           AS INTE FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_cdoperad        AS DECI FORMAT "999999999" /* 9 N */  NO-UNDO.
DEF VAR aux_nsupdv          AS INTE FORMAT "99999999"  /* 8 N */  NO-UNDO.
DEF VAR aux_nrversao        AS INTE                               NO-UNDO.
DEF VAR aux_tipo_trn        AS CHAR FORMAT "x(01)"     NO-UNDO.
DEF VAR aux_nmarquiv        AS CHAR                    NO-UNDO.
DEF VAR i-time              AS INTE                    NO-UNDO.
DEF VAR aux_transacao       AS CHAR   FORMAT "x(03)"   NO-UNDO. 
DEF VAR aux_tppagto         AS INTE   FORMAT "9"       NO-UNDO.
DEF VAR i-nro-rotulos       AS INTE                    NO-UNDO.
DEF VAR aux_tam_payload     AS INTE                    NO-UNDO.
DEF VAR aux_payload         AS CHAR                    NO-UNDO.
DEF VAR aux_cmc7            AS CHAR                    NO-UNDO.
DEF VAR aux_vldescto_int    AS INTE                    NO-UNDO.
DEF VAR aux_vldescto_char   AS CHAR                    NO-UNDO.
DEF VAR aux_tam_campo       AS INTE                    NO-UNDO.
DEF VAR aux_vlinform_int    AS INTE                    NO-UNDO.
DEF VAR aux_vlinform_char   AS CHAR                    NO-UNDO.
DEF VAR aux_vldocto_int     AS INTE                    NO-UNDO.
DEF VAR aux_vldocto_char    AS CHAR                    NO-UNDO.
DEF VAR aux_dtvencto        AS CHAR                    NO-UNDO.
DEF VAR aux_tptransac       AS CHAR                    NO-UNDO.
DEF VAR aux_tamanho         AS INTE                    NO-UNDO.
DEF VAR aux_posicao         AS INTE                    NO-UNDO.
DEF VAR aux_setlinha        AS CHAR                    NO-UNDO.
DEF VAR aux_linha_envio     AS CHAR                    NO-UNDO.
DEF VAR in01                AS INTE                    NO-UNDO.
DEF VAR i-ano-bi            AS INTE                    NO-UNDO.
DEF VAR h-b2crap14          AS HANDLE                  NO-UNDO.
              
FUNCTION muda_caracter RETURN DECIMAL
    (INPUT  p-cod-operador AS CHARACTER) FORWARD.

FORM aux_setlinha  FORMAT "x(150)"
     WITH FRAME AA WIDTH 150 NO-BOX NO-LABELS.


PROCEDURE critica-valor.
    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-agencia       AS INT.    /* Cod. Agencia */
    DEF INPUT  PARAM p-nro-caixa         AS INT.    /* Numero Caixa */
    DEF INPUT  PARAM p-vlr-dinheiro      AS DEC.
    DEF INPUT  PARAM p-vlr-cheque        AS DEC.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

           
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
    IF  NOT AVAIL craptab THEN
        DO:
           ASSIGN i-cod-erro = 0
                  c-desc-erro = 
                      "Convenio nao Parametrizado. TAB.CORRESPOND". 
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapage   THEN
         DO:
            ASSIGN i-cod-erro = 15
                   c-desc-erro = "". 
                       
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
         END.
   
    IF   crapage.cdagecbn = 0   THEN
         DO:
            ASSIGN i-cod-erro = 0
                   c-desc-erro = 
                      "Agencia nao Informada Parametrizada. CRAPAGE.". 

            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
         END.
   
       
    IF  p-vlr-dinheiro = 0  AND
        p-vlr-cheque   = 0 THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Informe valor(Dinheiro ou Cheque)".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF  p-vlr-cheque > 0 THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Nao pode ser pago com  Cheque".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
     
    IF  p-vlr-cheque   > 0  AND
        p-vlr-dinheiro > 0 THEN DO:
        ASSIGN i-cod-erro =  269
               c-desc-erro = " ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    
    /* Verifica se eh dia util e se esta dentro do horario (ate 21:00) */
         /* sabado ou domingo */
    IF   CAN-DO("1,7",STRING(WEEKDAY(TODAY)))   OR 
         /* feriado */
         CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                crapfer.dtferiad = TODAY
                                NO-LOCK)        OR 
         /* passou das 21h */
         STRING(TIME,"HH:MM") > "21:00"         THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT 0,
                            INPUT "Data/Horario fora do estabelecido",
                            INPUT YES).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE critica-valor-codigo-cheque.

    DEF INPUT PARAM p-cooper         AS CHAR.
    DEF INPUT PARAM p-cod-agencia    AS INT.    
    DEF INPUT PARAM p-nro-caixa      AS INT FORMAT "999".   
    DEF INPUT PARAM p-cmc-7          AS CHAR.
    DEF INPUT PARAM p-valor          AS DEC.

           
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  p-valor = 0 THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Informe valor(Cheque)" + string(p-valor).
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    IF  p-cmc-7  <> " "  THEN DO:
        IF  LENGTH(p-cmc-7) = 34  THEN
            ASSIGN substr(p-cmc-7,34,1) = ":".

        IF  LENGTH(p-cmc-7)      <> 34  OR
            substr(p-cmc-7,1,1)  <> "<" OR
            substr(p-cmc-7,10,1) <> "<" OR
            substr(p-cmc-7,21,1) <> ">" OR
            substr(p-cmc-7,34,1) <> ":" THEN DO:
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
        RUN dbo/pcrap09.p (INPUT p-cooper,
                           INPUT p-cmc-7,
                           OUTPUT p-nro-calculado,
                           OUTPUT p-lista-digito).
        IF  p-nro-calculado > 0 or
            NUM-ENTRIES(p-lista-digito) <> 3  THEN DO:
            ASSIGN i-cod-erro  = 666
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



PROCEDURE retorna-valores-fatura.    
   /*  Listar   Valor/Sequencia/Digito/Cod~igo de Barras  */
    DEF INPUT         PARAM p-cooper        AS CHAR.
    DEF INPUT         PARAM p-cod-operador  AS CHAR.
    DEF INPUT         PARAM p-cod-agencia   AS INTE.
    DEF INPUT         PARAM p-nro-caixa     AS INTE.
    DEF INPUT         PARAM p-fatura1       AS DEC.
    DEF INPUT         PARAM p-fatura2       AS DEC. 
    DEF INPUT         PARAM p-fatura3       AS DEC.
    DEF INPUT         PARAM p-fatura4       AS DEC.
    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR.
    DEF OUTPUT        PARAM p-vlfatura      AS DEC.
               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
        
    ASSIGN p-vlfatura = 0.
    
    IF  p-fatura1 <> 0 OR
        p-fatura2 <> 0 OR
        p-fatura3 <> 0 OR
        p-fatura4 <> 0 THEN  DO:
        ASSIGN de-valor-calc  =
              DEC(SUBSTR(STRING(p-fatura1,"999999999999"),1,11) + 
                  SUBSTR(STRING(p-fatura2,"999999999999"),1,11) + 
                  SUBSTR(STRING(p-fatura3,"999999999999"),1,11) + 
                  SUBSTR(STRING(p-fatura4,"999999999999"),1,11)).
                                                    
        ASSIGN p-codigo-barras = string(de-valor-calc).
    END.

    ASSIGN de-valor-calc = DEC(p-codigo-barras).
    
    /* Calculo Digito Verificador */
    RUN dbo/pcrap04.p (INPUT-OUTPUT de-valor-calc,
                       OUTPUT p-nro-digito,
                       OUTPUT p-retorno).
    IF  p-retorno = NO  THEN DO:
        IF  SUBSTR(p-codigo-barras,16,4) = "0163"   THEN /* CLARO */
            DO:
                RUN dbo/pcrap14.p (INPUT-OUTPUT p-codigo-barras,
                                         OUTPUT p-nro-digito,
                                         OUTPUT p-retorno).
            END.
        IF  p-retorno = NO                     AND
            SUBSTR(p-codigo-barras,2,1) <> "5" THEN  /* Orgao Governamental */
            DO:                                     /* Devido DAS - Simples */
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
    END.

        
    FIND crapcon NO-LOCK WHERE
         crapcon.cdcooper = crapcop.cdcooper                   AND
         crapcon.cdempcon = INTE(SUBSTR(p-codigo-barras,16,4)) AND
         crapcon.cdsegmto = INTE(SUBSTR(p-codigo-barras,2,1))  NO-ERROR.
         
    IF  AVAIL crapcon THEN
        DO:
            ASSIGN i-cod-erro  = 0           
                   c-desc-erro = "Empresa Conveniada - Utilize opcao 14".

                    
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".   
        END.           

    IF  SUBSTR(p-codigo-barras,16,4)       = "0270" AND /* GPS */
        INTE(SUBSTR(p-codigo-barras,2,1))  = 5      THEN 
        DO:
            IF NOT crapcop.flgargps THEN  /* Arrecada GPS */
               DO:
                   ASSIGN i-cod-erro  = 0          
                          c-desc-erro = "Este documento deve ser arrecadado na rotina 87.".
                          
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.
        END.
        
           
    ASSIGN p-vlfatura         =  DECIMAL(SUBSTR(p-codigo-barras,5,11)) / 100.
    
    ASSIGN i-nro-lote = 22000 + p-nro-caixa.
        
    FIND FIRST crapcbb NO-LOCK WHERE
               crapcbb.cdcooper = crapcop.cdcooper AND
               crapcbb.dtmvtolt = crapdat.dtmvtolt AND
               crapcbb.cdagenci = p-cod-agencia    AND
               crapcbb.cdbccxlt = 11               AND /* FIXO  */
               crapcbb.nrdolote = i-nro-lote       AND
               crapcbb.cdbarras = p-codigo-barras  AND
               crapcbb.flgrgatv = YES NO-ERROR.
    IF   AVAIL crapcbb THEN DO:
         ASSIGN i-cod-erro  =  92           
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



PROCEDURE retorna-valores-titulo.       
                                          
    DEF INPUT  PARAM p-cooper          AS CHAR.
    DEF INPUT  PARAM p-cod-operador    AS CHAR.
    DEF INPUT  PARAM p-cod-agencia     AS INTE.
    DEF INPUT  PARAM p-nro-caixa       AS INTE.
    DEF INPUT-OUTPUT  param p-titulo1  AS DEC. /* FORMAT "99999,99999" */     
    DEF INPUT-OUTPUT  PARAM p-titulo2  AS DEC. /* FORMAT "99999,999999" */  
    DEF INPUT-OUTPUT  PARAM p-titulo3  AS DEC. /* FORMAT "99999,999999" */  
    DEF INPUT-OUTPUT  param p-titulo4  AS DEC. /* FORMAT "9" */
    DEF INPUT-OUTPUT  PARAM p-titulo5  AS DEC. /* FORMAT "zz,zzz,zzz,zzz999"*/ 
    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR.
    DEF OUTPUT  PARAM p-vlfatura        AS DEC.
    DEF OUTPUT  PARAM p-dtvencto        AS DATE.
        
    DEFINE VARIABLE aux-nrdconta-cob     AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-bloqueto         AS DECIMAL                 NO-UNDO.
    DEFINE VARIABLE aux-contaconve       AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-convenio         AS DECIMAL                 NO-UNDO.
    DEFINE VARIABLE aux-insittit         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-intitcop         AS INTEGER                 NO-UNDO.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
    
    ASSIGN p-vlfatura    = 0.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  p-titulo1 <> 0 OR
        p-titulo2 <> 0 OR
        p-titulo3 <> 0 OR
        p-titulo4 <> 0 OR
        p-titulo5 <> 0 THEN DO:
            
        ASSIGN de-valor-calc = p-titulo1. 
              /*  Calcula digito- Primeiro campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        TRUE,  /* Validar zeros */      
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).

        IF  p-retorno = NO  THEN DO:
            ASSIGN i-cod-erro  =  8
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

        ASSIGN de-valor-calc = p-titulo2. 
              /*  Calcula digito  - Segundo campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        FALSE,  /* Validar zeros */ 
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).

        IF  p-retorno = NO  THEN DO:
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
        
        ASSIGN de-valor-calc = p-titulo3. 
               /*  Calcula digito  - Terceiro campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        FALSE,  /* Validar zeros */   
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).
        
        IF  p-retorno = NO  THEN DO:
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
        /*  Compoe o codigo de barras atraves da linha digitavel  */

        ASSIGN p-codigo-barras = 
               SUBSTRING(STRING(p-titulo1,"9999999999"),1,4)   +
                         STRING(p-titulo4,"9")                 +
                         STRING(p-titulo5,"99999999999999")    +
               SUBSTRING(STRING(p-titulo1,"9999999999"),5,1)   +
               SUBSTRING(STRING(p-titulo1,"9999999999"),6,4)   +
               SUBSTRING(STRING(p-titulo2,"99999999999"),1,10) +
               SUBSTRING(STRING(p-titulo3,"99999999999"),1,10).
               
    END.
    ELSE DO:   /* Compoe a Linha Digitavel atraves do codigo de Barras */
            
        ASSIGN p-titulo1 = DECIMAL(SUBSTRING(p-codigo-barras,01,04) +
                                   SUBSTRING(p-codigo-barras,20,01) +
                                   SUBSTRING(p-codigo-barras,21,04) + "0")
               p-titulo2 = DECIMAL(SUBSTRING(p-codigo-barras,25,10) + "0")
               p-titulo3 = DECIMAL(SUBSTRING(p-codigo-barras,35,10) + "0")
               p-titulo4 = INTEGER(SUBSTRING(p-codigo-barras,05,01))
               p-titulo5 = DECIMAL(SUBSTRING(p-codigo-barras,06,14)).
         
        ASSIGN de-valor-calc = p-titulo1.  
               /*  Calcula digito- Primeiro campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        TRUE,  /* Validar zeros */
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).
        ASSIGN p-titulo1 = de-valor-calc.
        /*
        IF  p-retorno = NO  THEN DO:
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
        */
        ASSIGN de-valor-calc = p-titulo2. 
               /*  Calcula digito  - Segundo campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        FALSE,  /* Validar zeros */
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).
        ASSIGN p-titulo2 = de-valor-calc.
        /*
        IF  p-retorno = NO  THEN DO:
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
        */
        ASSIGN de-valor-calc = p-titulo3.
               /*  Calcula digito  - Terceiro campo da linha digitavel  */
        RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                           INPUT        FALSE,  /* Validar zeros */
                                 OUTPUT p-nro-digito,
                                 OUTPUT p-retorno).
        ASSIGN p-titulo3 = de-valor-calc.
        /*
        IF  p-retorno = NO  THEN DO:
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
        */
    END.
        
    ASSIGN de-valor-calc = DEC(p-codigo-barras).
      
    /* Calculo Digito Verificador  - Titulo */
    RUN dbo/pcrap05.p (INPUT de-valor-calc,  
                       OUTPUT p-retorno).
    IF  p-retorno = NO  THEN DO:
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

    IF  p-titulo5  <> 0 THEN 
        ASSIGN  de-p-titulo5 =
                DEC(SUBSTR(STRING(p-titulo5, "99999999999999"),5,10))
                p-vlfatura   = de-p-titulo5  / 100
  
                de-campo     =
                    DEC(SUBSTR(STRING(p-titulo5, "99999999999~999"),1,4)).

                /* Zimmermann
                dt-dtvencto  = 10/07/1997 + de-campo.
                */
        RUN calcula_data_vencimento
                    (INPUT  crapdat.dtmvtolt,
                     INPUT  INT(de-campo),
                     OUTPUT dt-dtvencto,
                     OUTPUT i-cod-erro,
                     OUTPUT c-desc-erro).

        IF RETURN-VALUE = "NOK" THEN DO:
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    
    /* Identificar bloquetos Cooperativa */
     RUN dbo/b2crap14.p PERSISTENT SET h-b2crap14.
     RUN identifica-titulo-coop IN h-b2crap14
                              (INPUT  p-cooper,
                               INPUT  0,  /* Conta   */
                               INPUT  0,  /* Titular */
                               INPUT  p-cod-agencia,
                               INPUT  INT(p-nro-caixa),
                               INPUT  p-codigo-barras,
                               INPUT  TRUE,
                               OUTPUT aux-nrdconta-cob,
                               OUTPUT aux-insittit,
                               OUTPUT aux-intitcop,
                               OUTPUT aux-convenio,
                               OUTPUT aux-bloqueto,
                               OUTPUT aux-contaconve).
     DELETE PROCEDURE h-b2crap14.

     IF  RETURN-VALUE = "NOK"  OR
         aux-intitcop = 1 THEN
         DO:                 
            ASSIGN i-cod-erro  = 0            
                   c-desc-erro = "Titulo Cooperativa - Utilize opcao 14 ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".               
         END. 
 
     /*------------------------------------------*/    

    ASSIGN i-nro-lote = 22000 + p-nro-caixa.
        
    FIND FIRST crapcbb NO-LOCK WHERE
               crapcbb.cdcooper = crapcop.cdcooper AND
               crapcbb.dtmvtolt = crapdat.dtmvtolt AND
               crapcbb.cdagenci = p-cod-agencia    AND
               crapcbb.cdbccxlt = 11               AND /* FIXO  */
               crapcbb.nrdolote = i-nro-lote       AND
               crapcbb.cdbarras = p-codigo-barras  AND
               crapcbb.flgrgatv = YES NO-ERROR.
    IF   AVAIL crapcbb THEN DO:
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
    
    
    RETURN "OK".
        
END PROCEDURE.


PROCEDURE gera-titulos-faturas.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-codigo-barras    AS CHAR.
    DEF INPUT  PARAM p-dsdocmc7         AS CHAR.
    DEF INPUT  PARAM p-valor-pago       AS DEC.   /* Valor Pago Docto */
    DEF INPUT  PARAM p-vldescto         AS DEC.
    DEF INPUT  PARAM p-dtvencto         AS CHAR.
    DEF INPUT  PARAM p-tipo-docto       AS INTE. /* 1- titulo , 2-fatura */
    DEF INPUT  PARAM p-valor-doc        AS DEC.  /* Valor Documento */
    DEF INPUT  PARAM p-dsautent         AS CHAR. /* Literal aut.corresp.*/
    DEF INPUT  PARAM p-autchave         AS INTE.
    DEF INPUT  PARAM p-cdchave          AS CHAR.
    DEF OUTPUT PARAM p-histor           AS INTE.
    DEF OUTPUT PARAM p-pg               AS LOG.
    DEF OUTPUT PARAM p-docto            AS DEC.
    DEF OUTPUT PARAM p-registro         AS RECID.
    
    ASSIGN i-nro-lote = 22000 + p-nro-caixa
           i-tplotmov = 28.
               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

            
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.

    FIND craplot  WHERE
         craplot.cdcooper = crapcop.cdcooper AND
         craplot.dtmvtolt = crapdat.dtmvtolt AND
         craplot.cdagenci = p-cod-agencia    AND
         craplot.cdbccxlt = 11               AND  /* Fixo */
         craplot.nrdolote = i-nro-lote no-error.
    IF  NOT AVAIL craplot THEN do:
        CREATE  craplot.
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
 
    ASSIGN aux_data = ?.
    IF  p-dtvencto <> " " THEN
        ASSIGN aux_dia  = INTE(STRING(SUBSTR(p-dtvencto,1,2),"99"))
               aux_mes  = INTE(STRING(SUBSTR(p-dtvencto,3,2),"99"))
               aux_ano  = INTE(STRING(SUBSTR(p-dtvencto,5,4),"9999"))
               aux_data = DATE(aux_mes,aux_dia,aux_ano).
    
    CREATE crapcbb.
    ASSIGN crapcbb.cdcooper = crapcop.cdcooper
           crapcbb.dtmvtolt = craplot.dtmvtolt
           crapcbb.cdagenci = craplot.cdagenci
           crapcbb.cdbccxlt = craplot.cdbccxlt
           crapcbb.nrdolote = craplot.nrdolote
           crapcbb.cdopecxa = p-cod-operador 
           crapcbb.nrdcaixa = p-nro-caixa
           crapcbb.nrdmaqui = p-nro-caixa
           crapcbb.cdbarras = p-codigo-barras
           crapcbb.dsdocmc7 = p-dsdocmc7
           crapcbb.valorpag = p-valor-pago
           crapcbb.vldescto = p-vldescto
           crapcbb.valordoc = p-valor-doc
           crapcbb.tpdocmto = p-tipo-docto /* 1-titulo - 2-fatura */
           crapcbb.nrseqdig = craplot.nrseqdig + 1.  

    IF  crapcbb.tpdocmto = 2 THEN  /* Fatura */
        ASSIGN crapcbb.dtvencto = ?.
    ELSE
        ASSIGN crapcbb.dtvencto = aux_data.

    ASSIGN crapcbb.dsautent = p-dsautent
           crapcbb.autchave = p-autchave 
           crapcbb.cdchaveb = p-cdchave.
           
    ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.vlcompcr = craplot.vlcompcr + p-valor-pago.
           craplot.vlinfocr = craplot.vlinfocr + p-valor-pago.

   ASSIGN p-pg       = NO
          p-docto    = crapcbb.nrseqdig
          p-histor   = 750
          p-registro = RECID(crapcbb).
   
   RELEASE crapcbb.
    
   RELEASE craplot.

   RETURN "OK".

END PROCEDURE.


PROCEDURE gera-arquivo-correspondente.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-codigo-barras    AS CHAR.
    DEF INPUT  PARAM p-dsdocmc7         AS CHAR.
    DEF INPUT  PARAM p-valor            AS DEC.  /* valor dinheiro  */
    DEF INPUT  PARAM p-valor1           AS DEC.  /* valor cheque    */
    DEF INPUT  PARAM p-vlfatura         AS DEC.  /* valor docto     */
    DEF INPUT  PARAM p-vldescto         AS DEC.  /* valor desconto  */
    DEF INPUT  PARAM p-dtvencto         AS CHAR. /* Data vencto     */
    DEF INPUT  PARAM p-tpdocmto         AS INTE. /* 1 - titulo/ 2 - fatura */
    DEF OUTPUT PARAM p-autentica        AS CHAR. /* Literal Aut.Corresp. */
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

           
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    
    ASSIGN i-nro-lote = 22000 + p-nro-caixa.
        
    FIND FIRST crapcbb NO-LOCK WHERE
               crapcbb.cdcooper = crapcop.cdcooper AND
               crapcbb.dtmvtolt = crapdat.dtmvtolt AND
               crapcbb.cdagenci = p-cod-agencia    AND
               crapcbb.cdbccxlt = 11               AND /* FIXO  */
               crapcbb.nrdolote = i-nro-lote       AND
               crapcbb.cdbarras = p-codigo-barras  AND
               crapcbb.flgrgatv = YES NO-ERROR.
    IF   AVAIL crapcbb THEN DO:
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
    
    
    
    IF  p-dtvencto <> " " THEN DO:
        ASSIGN i-cod-erro = 0
               in01       = 1.
        DO  WHILE in01  LE 8:
            IF  SUBSTR(p-dtvencto,in01,1) <> "0" AND
                SUBSTR(p-dtvencto,in01,1) <> "1" AND
                SUBSTR(p-dtvencto,in01,1) <> "2" AND
                SUBSTR(p-dtvencto,in01,1) <> "3" AND
                SUBSTR(p-dtvencto,in01,1) <> "4" AND
                SUBSTR(p-dtvencto,in01,1) <> "5" AND
                SUBSTR(p-dtvencto,in01,1) <> "6" AND
                SUBSTR(p-dtvencto,in01,1) <> "7" AND
                SUBSTR(p-dtvencto,in01,1) <> "8" AND
                SUBSTR(p-dtvencto,in01,1) <> "9" THEN DO:
                
                ASSIGN i-cod-erro  = 13 /* Data errada */
                       c-desc-erro = " ".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                in01 = 8.
            END.
            in01 = in01 + 1.
        END.
        IF  i-cod-erro <> 0 THEN
            RETURN "NOK".
    END.
  
    IF  p-dtvencto <> " " THEN DO: /* DDMMAAAA */
           
        IF  INT(SUBSTR(p-dtvencto,1,2)) = 0  OR         /* Dia */
            INT(SUBSTR(p-dtvencto,1,2)) > 31 THEN DO:
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
           
        IF (INT(SUBSTR(p-dtvencto,3,2)) = 4   OR
            INT(SUBSTR(p-dtvencto,3,2)) = 6   OR
            INT(SUBSTR(p-dtvencto,3,2)) = 9   OR
            INT(SUBSTR(p-dtvencto,3,2)) = 11) AND
           (INT(SUBSTR(p-dtvencto,1,2)) > 30) THEN DO:
            
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
        
        IF   INT(SUBSTR(p-dtvencto,3,2)) = 2 THEN DO:
        
             ASSIGN i-ano-bi = INT(SUBSTR(p-dtvencto,5,4)) / 4.
             IF  i-ano-bi * 4 <> INT(SUBSTR(p-dtvencto,5,4)) THEN DO:
                 IF  INT(SUBSTR(p-dtvencto,1,2)) > 28 THEN DO:
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
             ELSE DO:    /* Ano Bissexto. */

                 IF  INT(SUBSTR(p-dtvencto,1,2)) > 29 THEN DO:
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
        
        IF   INT(SUBSTR(p-dtvencto,3,2)) > 12 OR       /* Mes */
             INT(SUBSTR(p-dtvencto,3,2)) = 0  THEN DO:
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
    
    IF  p-tpdocmto = 1 THEN DO:   /* Titulo */
        IF  DEC(SUBSTR(p-codigo-barras,6,14)) = 0 THEN DO:
            IF  p-dtvencto = " "   THEN DO:
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
          
            IF  p-vlfatura = 0 THEN DO:
                ASSIGN i-cod-erro  = 269 /* Valor errado */
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
        ELSE DO:
              IF  DEC(SUBSTR(p-codigo-barras,6,5)) = 0  AND
                  p-dtvencto = " " THEN DO:
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

    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND LAST crapbcx  EXCLUSIVE-LOCK WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR NO-WAIT.
      
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
    
    ASSIGN p-autentica = " "
           p-autchave  = 0 
           p-cdchave   = " ".
           
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
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
            aux_nsupdv   = crapbcx.nrsequni.
            aux_cdoperad = muda_caracter(p-cod-operador).
    
    ASSIGN aux_linha_envio = " ".
    
    IF  p-tpdocmto = 1 THEN
        ASSIGN  aux_transacao = "268".   /* Pagamento Titulo */
    ELSE
        ASSIGN  aux_transacao = "358".   /* Pagamento Convenio */
 
    IF  p-valor > 0 THEN
        ASSIGN aux_tppagto = 1. /* Dinheiro */
    ELSE                       
        ASSIGN aux_tppagto = 2. /* Cheque */
    
    ASSIGN aux_codigo_barras = DEC(p-codigo-barras).
    /*---  Formacao do campo payload  ---*/
    ASSIGN aux_payload  = "00001"     +     /* Fixo */
                          "00012"     +     /* Rotulo codigo barras */ 
                          "0045"      +     /* Tamanho campo codigo barras */
                          "0"         +
                          STRING(aux_codigo_barras,
                                "99999999999999999999999999999999999999999999")
                          + /* Codigo de barras */
                          "00022"     +     /* Rotulo tipo pagto    */
                          "0001"      +             /* Tam.campo tipo pagto */
                          STRING(aux_tppagto,"9").  /* Tipo de pagto       */
    ASSIGN aux_tam_payload = 69.
    ASSIGN i-nro-rotulos   = 2 . /* codigo barras e forma de pagto */
   
    IF  p-dsdocmc7 <> " " THEN  DO:          
        ASSIGN i-nro-rotulos = i-nro-rotulos + 1.
        ASSIGN aux_cmc7 = SUBSTR(p-dsdocmc7,2,8)   + /* Apenas parte numerica*/
                          SUBSTR(p-dsdocmc7,11,10) +
                          SUBSTR(P-dsdocmc7,22,12).
        ASSIGN aux_payload = aux_payload + 
                             "00026"    +  /* Rotulo CMC_7 */
                             "0030"     +  /* Tamanho campo cmc_7 */
                             aux_cmc7.
        ASSIGN aux_tam_payload = aux_tam_payload + 30.
        ASSIGN aux_tam_payload = aux_tam_payload + 9. /* Tamanho  e Rotulo */
    END.    

    IF  p-vldescto > 0 THEN DO:
        ASSIGN i-nro-rotulos     = i-nro-rotulos + 1.
        ASSIGN aux_vldescto_int  =  p-vldescto * 100.
        ASSIGN aux_vldescto_char =  STRING(aux_vldescto_int).
        ASSIGN aux_tam_campo     =  LENGTH(aux_vldescto_char).
        ASSIGN aux_payload = aux_payload  + 
                            "00095"       +    /* Rotulo Desconto */
                            STRING(aux_tam_campo,"9999") + /* Tam.campo descto*/
                            aux_vldescto_char.
        ASSIGN aux_tam_payload = aux_tam_payload + aux_tam_campo.
        ASSIGN aux_tam_payload = aux_tam_payload + 9. /* Tamanho e Rotulo */
     
    END.                        
    
                   
    IF  p-tpdocmto = 1 THEN DO:   /* Apenas para Titulo - valor nominal */
        ASSIGN i-nro-rotulos     = i-nro-rotulos + 1.
        ASSIGN aux_vlinform_int  = p-vlfatura * 100.
        /*-----
        ASSIGN aux_vlinform_int  = (p-valor + p-valor1) * 100.
        ------*/
        ASSIGN aux_vlinform_char = STRING(aux_vlinform_int).
        ASSIGN aux_tam_campo     = LENGTH(aux_vlinform_char).
        ASSIGN aux_tam_payload   = aux_tam_payload + aux_tam_campo.
        ASSIGN aux_tam_payload   = aux_tam_payload + 9. /* Tamanho e Rotulo */
        ASSIGN aux_payload = aux_payload   +
                        "00099"        + /* Rotulo Vlr. Nominal(Inform.) */
                        STRING(aux_tam_campo,"9999") + /* Tam.campo vlr.docto*/
                        aux_vlinform_char.
    END.
                                       
    ASSIGN i-nro-rotulos    = i-nro-rotulos + 1.
    assign aux_vldocto_int = (p-valor + p-valor1) * 100.
    /*-----
    ASSIGN aux_vldocto_int  = p-vlfatura  * 100. /* Valor documento */
    ------*/
    ASSIGN aux_vldocto_char = STRING(aux_vldocto_int).
    ASSIGN aux_tam_campo    = LENGTH(aux_vldocto_char).
    ASSIGN aux_tam_payload  = aux_tam_payload + aux_tam_campo.
    ASSIGN aux_tam_payload  = aux_tam_payload + 9. /* Tamanho Rotulo */
    ASSIGN aux_payload = aux_payload + 
                        "00113"      +  /* Rotulo Valor Documento          */
                        STRING(aux_tam_campo,"9999") + /* Tamanho vlr.pago */
                        aux_vldocto_char.
                                            
    IF  p-dtvencto <> " " THEN DO: /* DDMMAAAA */
        ASSIGN i-nro-rotulos = i-nro-rotulos + 1.
        ASSIGN aux_dtvencto = SUBSTR(p-dtvencto,5,4)  +   /* AAAA */
                              SUBSTR(p-dtvencto,3,2)  +   /* MM   */
                              SUBSTR(p-dtvencto,1,2).
        ASSIGN aux_tam_payload = aux_tam_payload  + 8.
        ASSIGN aux_tam_payload = aux_tam_payload + 9. /* Tamanho Rotulo */
        ASSIGN aux_payload = aux_payload +
                             "00021"     +  /* Rotulo Data Vencimento */
                             "0008"      +  /* Tamanho campo Data Vencto */
                             STRING(aux_dtvencto,"99999999").
    END.                        
    
    ASSIGN aux_tam_payload = aux_tam_payload + 1. /* campo @ */
    ASSIGN aux_tipo_trn = "P".
          
    ASSIGN i-time = TIME.
    RUN processa_envio_recebimento ( INPUT p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
   
    RELEASE crapbcx.
    
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

     /* A partir da posicao 136, dados para autenticar - fatura */
     IF  p-tpdocmto = 2 THEN  /* aux_tptransac= "358"*/ /* Convenio */
         ASSIGN aux_tam_payload = aux_tam_payload - 135
                p-autentica     = SUBSTR(c_linha,136,aux_tam_payload).
     ELSE 
        /* A partir da posicao 118, dados para autenticar - titulo */
           ASSIGN aux_tam_payload = aux_tam_payload - 118    /* Titulo */
                  p-autentica     = SUBSTR(c_linha,119,aux_tam_payload).
    
     ASSIGN aux_tamanho  =  LENGTH(p-autentica) / 38.
     ASSIGN aux_posicao  = 1.
     ASSIGN aux_contador = 1.
     /* Retirar caracteres nao reconhecidos - autenticadora */
     p-autentica = REPLACE(p-autentica,"="," ").
     p-autentica = REPLACE(p-autentica,"&","E").  

     DO  WHILE aux_contador LE aux_tamanho:
         ASSIGN c_autentica  = c_autentica + 
                STRING(SUBSTR(p-autentica,aux_posicao,38),"x(38)") + 
                  "          ". /* Tamanho 48 */
         ASSIGN aux_posicao  = aux_posicao + 38.
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


PROCEDURE verifica-valor-desconto.

    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-agencia       AS INT.    /* Cod. Agencia */
    DEF INPUT  PARAM p-nro-caixa         AS INT.    /* Numero Caixa */
    DEF INPUT  PARAM p-vlr-dinheiro      AS DEC.
    DEF INPUT  PARAM p-vlr-cheque        AS DEC.
    DEF INPUT  PARAM p-vlr-docto         AS DEC.
    DEF INPUT  PARAM p-vlr-descto        AS DEC.

    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN aux_vlr_digitado = p-vlr-dinheiro + p-vlr-cheque.
    
    IF  aux_vlr_digitado <> (p-vlr-docto - p-vlr-descto)  THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Valor nao Confere com o Informado". 
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




PROCEDURE gera-retorno-autenticacao.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-transacao        AS CHAR.
    DEF INPUT  PARAM p-registro         AS RECID.
    DEF INPUT  PARAM p-sequencia        AS INTE.
    DEF INPUT  PARAM p-literal          AS CHAR.
    DEF OUTPUT PARAM p-autentica        AS CHAR. /* Literal Aut.Corresp. */
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
   
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).


    FIND LAST crapbcx  WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR. 
    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
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
            aux_cdoperad = muda_caracter(p-cod-operador)
            i-time       = TIME.

    ASSIGN  aux_transacao   = p-transacao   /* 9900  */
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.

    ASSIGN aux_tipo_trn = "X".
          
    RUN processa_envio_recebimento ( INPUT p-cooper,
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

    FIND crapaut WHERE
         crapaut.cdcooper = crapcop.cdcooper AND
         crapaut.cdagenci = p-cod-agencia    AND
         crapaut.nrdcaixa = p-nro-caixa      AND
         crapaut.dtmvtolt = crapdat.dtmvtolt AND
         crapaut.nrsequen = p-sequencia NO-ERROR.
    ASSIGN crapaut.dslitera = p-literal.
    
    RELEASE crapaut.
 
    FIND crapcbb WHERE 
         RECID(crapcbb) = p-registro NO-ERROR.
    ASSIGN  crapcbb.nrautdoc  = p-sequencia.
    ASSIGN  crapcbb.dsautent  = p-literal. /* Lit.cooper(x48)+B.Brasil */
    ASSIGN crapcbb.flgrgfim   = YES.
    RELEASE crapcbb.
 
         
    RETURN "OK".
    
END PROCEDURE.

  

PROCEDURE executa-pendencias.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
 
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND LAST crapbcx  EXCLUSIVE-LOCK WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR NO-WAIT.
      
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

 
    /*=== ANTIGO
    FIND LAST crapbcx  WHERE 
              crapbcx.cdcooper = crapcop.cdcooper and
              crapbcx.dtmvtolt = crapdat.dtmvtolt and
              crapbcx.cdagenci = p-cod-agencia    and
              crapbcx.nrdcaixa = p-nro-caixa      and
              crapbcx.cdopecxa = p-cod-operador   and
              crapbcx.cdsitbcx = 1  NO-ERROR. 
    ================*/

    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
    
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.

    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
                       
    ASSIGN  aux_nrpdv      = p-nro-caixa
            aux_nsupdv     = crapbcx.nrsequni
            aux_cdoperad   = muda_caracter(p-cod-operador)
            i-time         = TIME.

    ASSIGN  aux_transacao   = "9903"   
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.

    ASSIGN aux_tipo_trn     = "X".
              
    RUN processa_envio_recebimento ( INPUT p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
                      
    RELEASE crapbcx.
    
    /* Remover arquivo */
    IF c-desc-erro <> " " THEN
       RETURN "NOK".
    
    IF  c_linha      = " "  AND
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

    IF  SUBSTR(c_linha,68,1) = "1" OR
        SUBSTR(c_linha,68,1) = "9" THEN DO: /* Cancelar */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Execute opcao de Cancelamento ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    IF  SUBSTR(c_linha,68,1) = "5" THEN DO: /* Retransmissao */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Repetir Transmissao/Cancelar Corresp.".
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
         
PROCEDURE executa-pendencias-fechamento.
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
     
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
    
    ASSIGN in99 = 0.
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND LAST crapbcx  EXCLUSIVE-LOCK WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR NO-WAIT.
      
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

 
    /*=== ANTIGO
    FIND LAST crapbcx  WHERE 
              crapbcx.cdcooper = crapcop.cdcooper and
              crapbcx.dtmvtolt = crapdat.dtmvtolt and
              crapbcx.cdagenci = p-cod-agencia    and
              crapbcx.nrdcaixa = p-nro-caixa      and
              crapbcx.cdopecxa = p-cod-operador   and
              crapbcx.cdsitbcx = 1  NO-ERROR. 
    ================*/
    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
    
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
                        
    ASSIGN  aux_nrpdv      = p-nro-caixa
            aux_nsupdv     = crapbcx.nrsequni
            aux_cdoperad   = muda_caracter(p-cod-operador)
            i-time         = TIME.

    ASSIGN  aux_transacao   = "9903"   
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.

    ASSIGN aux_tipo_trn     = "X".
              
    RUN processa_envio_recebimento ( INPUT p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
                      
    RELEASE crapbcx.
    
    /* Remover arquivo */
    IF c-desc-erro <> " " THEN DO:
       IF  c-desc-erro MATCHES "*PDV SEM PENDEN*"  THEN
           RETURN "OK".
       ELSE
           RETURN "NOK".
    
    END.
    
    IF  c_linha      = " "  AND
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

    IF  SUBSTR(c_linha,68,1) = "1" OR
        SUBSTR(c_linha,68,1) = "9" THEN DO: /* Cancelar */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Execute opcao de Cancelamento ".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
    IF  SUBSTR(c_linha,68,1) = "5" THEN DO: /* Retransmissao */
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Repetir Transmissao/Cancelar Corresp.".
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
         



PROCEDURE executa-canc-correspondente.
 
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF OUTPUT PARAM p-impaut           AS LOG.    
    DEF OUTPUT PARAM p-codigo-barras    AS CHAR.
    DEF OUTPUT PARAM p-tpdocmto         AS INTE.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
     
    ASSIGN p-impaut  = NO.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    FIND LAST crapbcx  WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR. 
    ASSIGN crapbcx.nrsequni = crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).

    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
                   
    ASSIGN  aux_nrpdv      = p-nro-caixa
            aux_nsupdv     = crapbcx.nrsequni
            aux_cdoperad   = muda_caracter(p-cod-operador)
            i-time         = TIME.

    ASSIGN  aux_transacao   = "9902"   
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.
    
    ASSIGN aux_tipo_trn     = "X".
              
    RUN processa_envio_recebimento ( INPUT p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
   
    /* Remover arquivo */
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

    FIND LAST crapcbb WHERE  
              crapcbb.cdcooper = crapcop.cdcooper AND
              crapcbb.dtmvtolt = crapdat.dtmvtolt AND
              crapcbb.cdagenci = p-cod-agencia    AND
              crapcbb.nrdcaixa = p-nro-caixa      AND
              crapcbb.cdopecxa = p-cod-operador   AND
              crapcbb.flgrgfim = NO  NO-ERROR.
    
    IF  AVAIL crapcbb  THEN DO:
        IF  crapcbb.dsautent <> " " AND  /* Havia autent.Cooperativa */
            crapcbb.flgrgfim = NO  THEN DO:

            ASSIGN crapcbb.flgrgatv = NO.   /* Estornado */
            ASSIGN p-impaut = YES. /* gerar autenticacao de estorno */
            ASSIGN p-codigo-barras = crapcbb.cdbarras.
            ASSIGN p-tpdocmto      = crapcbb.tpdocmto.
            RELEASE crapcbb.
        END.
    END.
    
    RETURN "OK".

END PROCEDURE.         
     


PROCEDURE executa-retransmissao.
    
    DEF INPUT PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF OUTPUT PARAM p-autentica        AS CHAR. /* Literal Aut.Corresp. */
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */
    DEF OUTPUT PARAM p-histor           AS INTE.
    DEF OUTPUT PARAM p-pg               AS LOG.
    DEF OUTPUT PARAM p-docto            AS DEC.
    DEF OUTPUT PARAM p-registro         AS RECID.
    DEF OUTPUT PARAM p-jaautent         AS LOG.
        
               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND LAST crapcbb WHERE  
              crapcbb.cdcooper = crapcop.cdcooper AND
              crapcbb.dtmvtolt = crapdat.dtmvtolt AND
              crapcbb.cdagenci = p-cod-agencia    AND
              crapcbb.nrdcaixa = p-nro-caixa      AND
              crapcbb.cdopecxa = p-cod-operador   AND
              crapcbb.flgrgfim = NO NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcbb  THEN DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Sem reg. p/retransmissao. Execute Pendencias".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
 
    ASSIGN p-pg       = NO
           p-docto    = crapcbb.nrseqdig
           p-histor   = 0
           p-registro = RECID(crapcbb)
           p-jaautent = NO.
        
    FIND LAST crapbcx  WHERE 
              crapbcx.cdcooper = crapcop.cdcooper AND
              crapbcx.dtmvtolt = crapdat.dtmvtolt AND
              crapbcx.cdagenci = p-cod-agencia    AND
              crapbcx.nrdcaixa = p-nro-caixa      AND
              crapbcx.cdopecxa = p-cod-operador   AND
              crapbcx.cdsitbcx = 1  NO-ERROR.
    ASSIGN crapbcx.nrsequni= crapbcx.nrsequni + 1.
               
    ASSIGN aux_nrconven  =  0
           aux_nrversao  =  0.
    FIND craptab WHERE
         craptab.cdcooper = crapcop.cdcooper AND
         craptab.nmsistem = "CRED"           AND
         craptab.tptabela = "USUARI"         AND
         craptab.cdempres = 11               AND
         craptab.cdacesso = "CORRESPOND"     AND
         craptab.tpregist = 000 NO-LOCK NO-ERROR.
    IF AVAIL craptab   THEN                    
       ASSIGN aux_nrconven = INT(SUBSTR(craptab.dstextab,1,9))
              aux_nrversao = INT(SUBSTR(craptab.dstextab,11,3)).
     
    ASSIGN aux_nragenci = 0
           aux_nrdaloja = 100 + p-cod-agencia.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = p-cod-agencia      NO-LOCK NO-ERROR.

    IF   AVAILABLE crapage   THEN   
         ASSIGN aux_nragenci = crapage.cdagecbn.
                   
    ASSIGN  aux_nrpdv      = p-nro-caixa
            aux_nsupdv     = crapbcx.nrsequni
            aux_cdoperad   = muda_caracter(p-cod-operador)
            i-time         = TIME.

    ASSIGN  aux_transacao   = "9901" /* Retransmissao */
            i-nro-rotulos   = 0 
            aux_tam_payload = 0
            aux_vldocto_int = 0.

    ASSIGN aux_tipo_trn     = "X".
                                       
    RUN processa_envio_recebimento ( INPUT p-cooper,
                                     INPUT  p-cod-agencia,
                                     INPUT  p-nro-caixa,
                                     OUTPUT p-autchave,    
                                     OUTPUT p-cdchave).  
   
    /* Remover arquivo */
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

    /* A partir da posicao 136, dados para autenticar - fatura */
    IF crapcbb.tpdocmto = 2 THEN /* aux_tptransac= "358"*/ /* Convenio */
       ASSIGN aux_tam_payload = aux_tam_payload - 135
              p-autentica     = SUBSTR(c_linha,136,aux_tam_payload).
    ELSE 
       /* A partir da posicao 118, dados para autenticar - titulo */
       ASSIGN aux_tam_payload = aux_tam_payload - 118    /* Titulo */
              p-autentica     = SUBSTR(c_linha,119,aux_tam_payload).
    
    ASSIGN aux_tamanho  =  LENGTH(p-autentica) / 38.
    ASSIGN aux_posicao  = 1.
    ASSIGN aux_contador = 1.
    /* Retirar caracteres nao reconhecidos - autenticadora */
    p-autentica = REPLACE(p-autentica,"="," ").
    p-autentica = REPLACE(p-autentica,"&","E").  
 

    DO  WHILE aux_contador LE aux_tamanho:
        ASSIGN c_autentica  = c_autentica + 
                   STRING(SUBSTR(p-autentica,aux_posicao,38),"x(38)") + 
                   "          ". /* Tamanho 48 */
        ASSIGN aux_posicao  = aux_posicao + 38.
        ASSIGN aux_contador = aux_contador + 1.
    END.
      
    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE 10:
        ASSIGN c_autentica  = c_autentica + STRING(" ","x(48)").
        ASSIGN aux_contador = aux_contador + 1.
    END.
       
    ASSIGN p-autentica = c_autentica.
    
    IF  crapcbb.dsautent <> " "   AND        /* Nao necessario autenticar */
        LENGTH(TRIM(crapcbb.dsautent)) > 50  THEN DO:
        FIND crabcbb WHERE 
             RECID(crabcbb) = p-registro NO-ERROR.
        ASSIGN  crabcbb.flgrgfim  = YES. /* Finalizacao OK */
        RELEASE crabcbb.
        ASSIGN p-jaautent = YES.
    END.
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE processa_envio_recebimento.

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF OUTPUT PARAM p-autchave         AS INTE. /* Nro Aut.Correspondente */
    DEF OUTPUT PARAM p-cdchave          AS CHAR. /* Chave Correspondente */
    
    DEF VAR          aux_controle       AS LOG                  NO-UNDO.    
               
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.

    
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

    IF  aux_tipo_trn = "P" THEN 
       DO:  
          ASSIGN aux_contador = 1.
          DO  WHILE aux_contador LE (aux_tam_payload - 1):
              ASSIGN aux_linha_envio = aux_linha_envio + 
                                       SUBSTR(aux_payload,aux_contador,1).
              ASSIGN aux_contador = aux_contador + 1.
          END.
          ASSIGN aux_linha_envio = aux_linha_envio + "@".
       END.
     
    ASSIGN aux_nmarquiv = "/usr/coop/sistema/siscaixa/web/spool/" +
                          crapcop.dsdircop            +
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
                  ASSIGN aux_erro        = INT(SUBSTR(aux_setlinha,70,3))
                         aux_cod_agencia = p-cod-agencia
                         aux_nro_caixa   = p-nro-caixa.
                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = "Erro nao previsto " +
                                        STRING(aux_erro,"999").
                     
             END. 

             ASSIGN p-cdchave       = SUBSTR(aux_setlinha,45,8)
                    p-autchave      = INT(SUBSTR(aux_setlinha,57,4))
                    aux_tam_payload = INT(SUBSTR(aux_setlinha,93,9))
                    aux_tptransac   = SUBSTR(aux_setlinha,61,4)
                    c_linha         = ""
                    aux_controle    = FALSE.

             SET   STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 150.
             /* Demais linhas - tamanho 38 */

             DO  WHILE TRUE   ON ENDKEY UNDO, LEAVE  RETORNO: 
                 
                 IF  aux_setlinha MATCHES "*Modelo*" THEN  /** Acerta DARF **/
                     ASSIGN aux_controle = TRUE.
 
                 IF  aux_controle = FALSE THEN
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
    
    /* Mirtes
    UNIX SILENT VALUE("rm " + aux_nmarquiv + 
                      " 2>/dev/null").
    */

    IF  c-desc-erro <> " "  THEN DO:
        IF  aux_tam_payload > 0 AND
            SUBSTR(c_linha,1,1) = "Z" THEN DO: /* Mensagem de ERRO COBAN */
            ASSIGN c-desc-erro = SUBSTR(c_linha,9,3) + "  - " +
                                 TRIM(SUBSTR(c_linha,15,40)).
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT aux_cod_agencia,
                           INPUT aux_nro_caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
        END.
        ELSE
            DO:
               FIND crapcbe NO-LOCK WHERE
                    crapcbe.cdcooper = crapcop.cdcooper AND
                    crapcbe.cdcritic = aux_erro NO-ERROR.
               IF  AVAIL crapcbe THEN 
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = STRING(crapcbe.cdcritic,"999") + "-" + 
                                        STRING(crapcbe.cdorigem,"9")  + "-" +
                                        TRIM(crapcbe.dscritic).
   
               RUN cria-erro (INPUT p-cooper,
                              INPUT aux_cod_agencia,
                              INPUT aux_nro_caixa,
                              INPUT i-cod-erro,
                              INPUT c-desc-erro,
                              INPUT YES).
             END.
    END.    

END PROCEDURE.

/********************************************************************************
 Função que muda caracter alfa para numerico.
*********************************************************************************/

FUNCTION muda_caracter RETURN DECIMAL
    (INPUT p-cod-operador AS CHARACTER):

DEF VAR aux_cont     AS INTE NO-UNDO.
DEF VAR converte     AS CHAR NO-UNDO.
DEF VAR aux_int      AS DECI NO-UNDO.
DEF VAR aux_result   AS CHAR NO-UNDO.

DEF VAR aux_cont2    AS INTE NO-UNDO.

  ASSIGN aux_cont  = 0
         aux_int   = 0
         aux_cont2 = 0.

  IF  LENGTH(p-cod-operador) > 9 THEN
      DO:
        ASSIGN aux_cont2 = LENGTH(p-cod-operador)
               aux_cont2 = aux_cont2 - 8       
               p-cod-operador = SUBSTRING(p-cod-operador, aux_cont2,
                                          LENGTH(p-cod-operador)).
      END.

  DO aux_cont = 1 TO LENGTH(p-cod-operador):

     converte = SUBSTR(p-cod-operador,aux_cont,1).

     aux_int = DECI(converte) NO-ERROR.

     IF ERROR-STATUS:ERROR THEN
        DO:
          aux_result = aux_result + "0".
        END.
     ELSE
       aux_result = aux_result + converte.
  END.

  RETURN DECI(aux_result).

END FUNCTION.

PROCEDURE calcula_data_vencimento:

    DEF INPUT  PARAM p-dtmvtolt         LIKE crapdat.dtmvtolt           NO-UNDO.
    DEF INPUT  PARAM p-de-campo         AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM p-dtvencto         AS DATE                         NO-UNDO.
    DEF OUTPUT PARAM p-cod-erro         AS INTE                         NO-UNDO.           
    DEF OUTPUT PARAM p-desc-erro        AS CHAR                         NO-UNDO.    

    DEF VAR aux_fatordia AS INTE                                        NO-UNDO.
    DEF VAR aux_fator    AS INTE                                        NO-UNDO.
    DEF VAR aux_dtvencto AS DATE                                        NO-UNDO.   

    DEF VAR aux_fv1997   AS DATE                                        NO-UNDO.
    DEF VAR aux_fv2025   AS DATE                                        NO-UNDO.

    DEF VAR aux_situacao AS INTE                                        NO-UNDO.
    DEF VAR aux_contador AS INTE                                        NO-UNDO.

    /* 0 - Fora Ranger 
       1 - A Vencer 
       2 - Vencida       */
    ASSIGN aux_situacao = 0. 


    /* Calcular Fator do Dia */
    ASSIGN aux_fatordia = p-dtmvtolt - DATE("07/10/1997").
    
    IF aux_fatordia > 9999 THEN DO:
    
        IF ( aux_fatordia MODULO 9000 ) < 1000 THEN
            aux_fatordia = ( aux_fatordia MODULO 9000 )  + 9000.
        ELSE
            aux_fatordia = ( aux_fatordia MODULO 9000 ).
    
    END.


    /* Verifica se esta A Vencer  */
    aux_fator = aux_fatordia.
    
    DO aux_contador=0 TO 5500:
    
        IF p-de-campo = aux_fator THEN DO:
            aux_situacao = 1. /* A Vencer */
            LEAVE.
        END.
    
        IF aux_fator > 9999 THEN
            aux_fator = 1000.
        ELSE
            aux_fator = aux_fator + 1.
    
    END.

    /* Verifica se esta Vencido */
    aux_fator = aux_fatordia - 1.
    
    IF aux_fator < 1000 THEN
         aux_fator = aux_fator + 9000.
    
    IF aux_situacao = 0 THEN DO:
    
        DO aux_contador=0 TO 3000:
    
            IF p-de-campo = aux_fator THEN DO:
                aux_situacao = 2. /* Vencido */
                LEAVE.
            END.
    
            IF aux_fator < 1000 THEN
                aux_fator = aux_fator + 9000.
            ELSE
                aux_fator = aux_fator - 1.
    
        END.
    
    END.
    
    IF aux_situacao = 0  THEN DO:
        ASSIGN p-cod-erro  = 0           
               p-desc-erro = "Boleto fora do ranger permitido!".
        RETURN "NOK".
    END.
    ELSE
        IF aux_situacao = 1 THEN DO:  /* A Vencer */
            IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - 1000 + (9999 - aux_fatordia + 1 ) ).
            ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
            END.
        ELSE DO:   /* Vencido */
             IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
             ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia - 9000 ).
        END.

    ASSIGN p-dtvencto = aux_dtvencto.

    RETURN "OK".
   
END.


PROCEDURE validar-valor-limite:

    DEF INPUT PARAM par_nmrescop  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap14            AS HANDLE                          NO-UNDO.
    
    
    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapcop THEN
      DO: 
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Cooperativa nao encontrada.".
        RUN cria-erro (INPUT par_nmrescop,
                       INPUT par_cdagenci,
                       INPUT par_nrocaixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
      END.
      
    
    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                           
    RUN valida-valor-limite IN h_b1crap14(INPUT crapcop.cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT par_cdagenci,
                                          INPUT par_nrocaixa,
                                          INPUT par_vltitfat,
                                          INPUT par_senha,
                                          OUTPUT par_des_erro,
                                          OUTPUT par_dscritic,
                                          OUTPUT par_inssenha).
    DELETE PROCEDURE h_b1crap14.
    
    IF RETURN-VALUE = 'NOK' THEN  
     DO:
        RUN cria-erro (INPUT par_nmrescop,
                       INPUT par_cdagenci,
                       INPUT par_nrocaixa,
                       INPUT 0,
                       INPUT par_dscritic,
                       INPUT YES).
        RETURN "NOK".
     END.
     
    RETURN "OK".

END PROCEDURE.
