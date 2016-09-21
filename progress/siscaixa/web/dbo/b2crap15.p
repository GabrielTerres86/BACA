/*---------------------------------------------------------------------
   Programa: siscaixa/web/dbo/b2crap15.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : 
   Data    :                             Ultima atualizacao: 28/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Arrecadacoes  (Titulos/IPTU) - Antigo LANTIT. 


   Alteracoes: 15/08/2007 - Alterado para usar a data com crapdat.dtmvtocd e
                            tratamento para os erros da internet;
                          - Criada procedure estorna-tarifa-titulo (Evandro).
                          
               18/02/2008 - Retira codigo CEB do numero do documento quando for
                            boleto da cooperativa (Elton).

               03/06/2008 - Separacao de lotes para titulos da coop (Evandro).

               14/10/2008 - Tratamento para desconto de titulos (Elton).
               
               08/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                            (David).
              
               26/02/2009 - Tratar campos crapcob.vltarifa,crapcob.cdbanpag e
                            crapcob.cdagepag (Gabriel).
                            
               24/06/2009 - Estorna lancamentos de titulos em epr(Guilherme).
               
               17/08/2009 - Somente estornar titulos em desconto com situacao
                            igual a 2-Pago e corrigida busca do numero do
                            documento (Evandro).
                            
               04/06/2010 - Tratamento referente a tarifa de TAA na procedure 
                            estorna-tarifa-titulo (Elton).
                            
               06/01/2011 - Na procedure estorna-titulos-iptu faz o estorno
                            de cheques quando o titulo for pago com cheque 
                            (Elton).
                            
               03/03/2011 - Nao permitir estorno de pagamentos efetuados
                            via DDA (David)  
                            
               19/05/2011 - Descomentada chamada da procedure 
                            atualiza-previa-caixa;
                          - acerto na contabilizacao dos cheques na craplot
                            (Elton).
               
               19/09/2012 - Tratamento para titulos duplicados (Elton).
               
               22/02/2013 - Ajuste no estorno de titulos com CEB 5 digitos
                            do convenio 1343313 Viacredi (Rafael).
                            
               31/05/2013 - Ajuste na numeracao do documento da rotina de
                            estorno devido ao CEB 5 digitos (Rafael).
                            
               02/01/2014 - Melhoria leitura tabela crapcob (Daniel).
               
               24/09/2014 - Ajuste na estorna-titulos-iptu para deletar 
                            crapret das cobranças com registro, chamaro 202445
                            (Odirlei/AMcom)
               
               03/11/2014 - Ajuste na rotina estorna-titulos-iptu, para buscar 
                            informações da crapceb somente se for convenio
                            de 7 digitos( SD 218160 - Odirlei-AMcom)
                                         
               17/11/2015 - Ajuste na rotina estorna-tarifa-titulo para nao
                            utilizar mais o estorno de tarifa
                            e procurar lote e lcm pios a tarifa
                            e gerada na craplat agora 
                            (Tiago/Elton SD358469).
                            
               28/06/2016 - Ajustado para que as ocorrencias 76 e 77 tambem
                            sejam deletadas da crapret, da mesma forma que 
                            as ocorrencias 6 e 17 (Douglas - Chamado 461531)
---------------------------------------------------------------------------*/
 
{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0030tt.i }

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.


DEF VAR de-valor-calc AS DEC  NO-UNDO.
DEF VAR p-nro-digito  AS INTE NO-UNDO.
DEF VAR p-retorno     AS LOG  NO-UNDO.
DEF VAR i-nro-lote    LIKE craplft.nrdolote                   NO-UNDO.
DEF VAR de-campo      AS DECIMAL FORMAT "99999999999999"      NO-UNDO.
DEF VAR dt-dtvencto   AS DATE NO-UNDO.
DEF VAR i-digito      AS INTE NO-UNDO.
DEF VAR i-cdhistor    AS INTE NO-UNDO.

DEF VAR tab_intransm  AS INT  NO-UNDO.
DEF VAR tab_hrlimite  AS INT  NO-UNDO.
DEF VAR in99          AS INT  NO-UNDO.

DEF VAR h-b1craplot         AS HANDLE                               NO-UNDO.
DEF VAR h-b1craplcm         AS HANDLE                               NO-UNDO.

DEF VAR h-b1wgen0030        AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0023        AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0089        AS HANDLE                               NO-UNDO.
DEF VAR h-b1crap00          AS HANDLE                               NO-UNDO.

DEF TEMP-TABLE tt-erro      NO-UNDO     LIKE craperr.

DEF TEMP-TABLE cratlot      NO-UNDO     LIKE craplot.
DEF TEMP-TABLE cratlcm      NO-UNDO     LIKE craplcm.


PROCEDURE retorna-valores-titulo-iptu.       
                                          
    DEF INPUT  PARAM p-cooper           AS  CHAR.
    DEF INPUT  PARAM p-cod-operador     AS  char.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
   
    DEF INPUT-OUTPUT   param p-titulo1         AS DEC.  
    DEF INPUT-OUTPUT   PARAM p-titulo2         AS DEC.   
    DEF INPUT-OUTPUT   PARAM p-titulo3         AS DEC.  
    DEF INPUT-OUTPUT   param p-titulo4         AS DEC.    
    DEF INPUT-OUTPUT   PARAM p-titulo5         AS DEC.   

    DEF INPUT-OUTPUT  PARAM p-codigo-barras AS CHAR.
    
    DEF INPUT   PARAM p-iptu            AS LOG.
    DEF INPUT   PARAM p-cadastro        AS DEC.
    DEF INPUT   PARAM p-cadastro-conf   AS DEC.
    DEF OUTPUT  PARAM p-valor-pago      AS DEC.
    DEF OUTPUT  PARAM p-valordoc        AS DEC.
    
    ASSIGN p-valor-pago    = 0.
                 
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.


    IF  p-iptu = YES  THEN   
        ASSIGN i-nro-lote = 17000 + p-nro-caixa.
    ELSE
        ASSIGN i-nro-lote = 16000 + p-nro-caixa.

        
    IF  p-iptu = NO  THEN  DO:   /* T¡tulo */
        
        FIND craptab  NO-LOCK WHERE 
             craptab.cdcooper = crapcop.cdcooper AND
             craptab.nmsistem = "CRED"           AND
             craptab.tptabela = "GENERI"         AND
             craptab.cdempres = 0                AND
             craptab.cdacesso = "HRTRTITULO"     AND
             craptab.tpregist = p-cod-agencia NO-ERROR.

        IF   NOT AVAIL craptab   THEN
             ASSIGN tab_intransm = 1
                    tab_hrlimite = 64800.    
        ELSE
             ASSIGN tab_intransm = INT(SUBSTRING(craptab.dstextab,1,1))
                    tab_hrlimite = INT(SUBSTRING(craptab.dstextab,3,5)).

        /*  Tabela com o horario limite para digitacao  */
        FIND craptab NO-LOCK WHERE 
             craptab.cdcooper = crapcop.cdcooper AND
             craptab.nmsistem = "CRED"           AND
             craptab.tptabela = "GENERI"         AND
             craptab.cdempres = 0                AND
             craptab.cdacesso = "HRTRTITULO"     AND
             craptab.tpregist = p-cod-agencia    NO-ERROR.
        IF  NOT AVAIL craptab  THEN  DO:
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
        IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))  THEN DO:
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
        IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN DO:
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
                        
        IF  p-titulo1 <> 0 OR
            p-titulo2 <> 0 OR
            p-titulo3 <> 0 OR
            p-titulo4 <> 0 OR
            p-titulo5 <> 0 THEN DO:
            
            ASSIGN de-valor-calc = p-titulo1. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        TRUE, /* Validar zeros */      
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

            ASSIGN de-valor-calc = p-titulo2. 
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE, /* Validar zeros */
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
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE, /* Validar zeros */
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

            /* Compoe o codigo de barras atraves da linha digitavel  */
            p-codigo-barras = SUBSTR(STRING(p-titulo1,"9999999999"),1,4)   +
                                     STRING(p-titulo4,"9")                 +
                                     STRING(p-titulo5,"99999999999999")    +
                              SUBSTR(STRING(p-titulo1,"9999999999"),5,1)   +
                              SUBSTR(STRING(p-titulo1,"9999999999"),6,4)   + 
                              SUBSTR(STRING(p-titulo2,"99999999999"),1,10) +
                              SUBSTR(STRING(p-titulo3,"99999999999"),1,10).
        END.
        ELSE DO:     /* Compäe a Linha Digit vel atrav‚s do C¢digo de Barras */
            
            ASSIGN p-titulo1 = DECIMAL(SUBSTRING(p-codigo-barras,01,04) +
                                       SUBSTRING(p-codigo-barras,20,01) +
                                       SUBSTRING(p-codigo-barras,21,04) + "0")
                   p-titulo2 = DECIMAL(SUBSTRING(p-codigo-barras,25,10) + "0")
                   p-titulo3 = DECIMAL(SUBSTRING(p-codigo-barras,35,10) + "0")
                   p-titulo4 = INTEGER(SUBSTRING(p-codigo-barras,05,01))
                   p-titulo5 = DECIMAL(SUBSTRING(p-codigo-barras,06,14)).

            /**-------- VERIFICA COM EDSON A VALIDACAO DE LINHA DIGITAVEL ----*/
            /*  Calcula digito- Primeiro campo da linha digitavel  */
            ASSIGN de-valor-calc = p-titulo1.  
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        TRUE, /* Validar zeros */
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
            
            /*  Calcula digito  - Segundo campo da linha digitavel  */
            ASSIGN de-valor-calc = p-titulo2.  
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE, /* Validar zeros */
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
            /*  Calcula digito  - Terceiro campo da linha digitavel  */
            ASSIGN de-valor-calc = p-titulo3.  
            RUN dbo/pcrap03.p (INPUT-OUTPUT de-valor-calc,
                               INPUT        FALSE, /* Validar zeros */
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
    END.

     IF  p-iptu = YES  THEN   
        ASSIGN i-nro-lote = 17000 + p-nro-caixa
               p-valordoc = DECIMAL(SUBSTR(p-codigo-barras,5,11)) / 100.
    ELSE
        ASSIGN i-nro-lote = 16000 + p-nro-caixa  
               p-valordoc = DECIMAL(SUBSTR(STRING(p-titulo5, "99999999999999"),5,10)) / 100.
               /*p-valordoc = p-titulo5  / 100.*/

    IF  p-iptu = YES  THEN   DO:   /* Processa IPTU */
         
        IF  (INT(SUBSTR(p-codigo-barras, 16, 4)) <> 557)      or  
            (INT(SUBSTR(p-codigo-barras, 02, 1)) <> 1)    THEN DO:  
             ASSIGN i-cod-erro  = 100    
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".  
        END.

        IF   (INT(SUBSTR(p-codigo-barras, 28, 3)) = 511)  THEN
              DO: 
                 IF   p-cadastro <> p-cadastro-conf   THEN
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
                           
                  IF   p-cadastro = 0   THEN
                       DO:                                 
                         ASSIGN i-cod-erro  = 375           
                                c-desc-erro = " ".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".                             
                       END.
                                  
                   ASSIGN SUBSTR(p-codigo-barras, 31, 10) =
                          STRING(p-cadastro, "9999999999").
              END.
                   
    END.        /* IPTU */

    else do:   /* Titilo */ 
       
        IF  (INT(SUBSTR(p-codigo-barras, 16, 4)) = 557)  AND   /* Prefeitura  */
            (INT(SUBSTR(p-codigo-barras, 02, 1)) = 1)  THEN DO: /* Cod.Segmto */
             ASSIGN i-cod-erro  = 100    
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".  
        END.
        ELSE DO:

             /*  Verifica a hora somente para a arrecadacao caixa  */
                     
             IF   TIME >= tab_hrlimite   THEN DO:
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

             IF   tab_intransm > 0   THEN  DO:
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
        END.
    END.


    FIND craplot  NO-LOCK WHERE
         craplot.cdcooper = crapcop.cdcooper AND
         craplot.dtmvtolt = crapdat.dtmvtocd AND
         craplot.cdagenci = p-cod-agencia    AND
         craplot.cdbccxlt = 11               AND  /* Fixo */
         craplot.nrdolote = i-nro-lote no-error.
    IF  NOT AVAIL craplot THEN do:
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
    
    FIND craptit NO-LOCK WHERE
         craptit.cdcooper = crapcop.cdcooper AND 
         craptit.dtmvtolt = crapdat.dtmvtocd AND
         craptit.cdagenci = p-cod-agencia    AND
         craptit.cdbccxlt = 11               AND /* FIXO  */
         craptit.nrdolote = i-nro-lote       AND
         craptit.dscodbar = p-codigo-barras NO-ERROR.
    IF  NOT AVAIL craptit  THEN  DO:
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

    IF  craptit.flgpgdda  THEN DO:
        ASSIGN i-cod-erro  = 0           
               c-desc-erro = "Titulo DDA. Estorno nao permitido.".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
        
    ASSIGN p-valor-pago  =  craptit.vldpagto.
    
    RETURN "OK".
        
END PROCEDURE.

PROCEDURE estorna-titulos-iptu.
    
    DEF INPUT  PARAM p-cooper            AS CHAR.
    DEF INPUT  PARAM p-cod-operador      AS char.
    DEF INPUT  PARAM p-cod-agencia       AS INTE.
    DEF INPUT  PARAM p-nro-caixa         AS INTE.

    DEF INPUT  PARAM p-iptu              AS LOG.
    DEF INPUT  PARAM p-codigo-barras     AS CHAR.
 
    DEF OUTPUT PARAM p-histor            AS INTE.
    DEF OUTPUT PARAM p-pg                AS LOG.
    DEF OUTPUT PARAM p-docto             AS DEC.
    
    DEFINE BUFFER b-craplot FOR craplot.

    DEFINE BUFFER crablot FOR craplot. 

    DEFINE VARIABLE h-b2crap14           AS HANDLE                  NO-UNDO.
    DEFINE VARIABLE aux-nrdconta-cob     AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-bloqueto         AS DECIMAL                 NO-UNDO.
    DEFINE VARIABLE aux-bloqueto2        AS DECIMAL                 NO-UNDO.
    DEFINE VARIABLE aux-contaconve       AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-convenio         AS DECIMAL                 NO-UNDO.
    DEFINE VARIABLE aux-insittit         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux-intitcop         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_flgepr           AS LOGICAL                 NO-UNDO.
    
    DEFINE VARIABLE aux_nrcnvbol         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_nrctabol         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_nrboleto         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_contador         AS INTEGER                 NO-UNDO.
    DEFINE VARIABLE aux_rowidcob         AS ROWID                   NO-UNDO.
    
    FIND crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
           
    IF  p-iptu = YES  THEN   
        ASSIGN i-nro-lote = 17000 + p-nro-caixa.
    ELSE
        ASSIGN i-nro-lote = 16000 + p-nro-caixa.

    ASSIGN in99 = 0
           aux_flgepr = FALSE. /* Variavel para ver se eo bol. esta em epr */
    DO  WHILE TRUE:
       
        ASSIGN in99 = in99 + 1.
        FIND craplot EXCLUSIVE-LOCK  WHERE
             craplot.cdcooper = crapcop.cdcooper AND
             craplot.dtmvtolt = crapdat.dtmvtocd AND
             craplot.cdagenci = p-cod-agencia    AND
             craplot.cdbccxlt = 11               AND  /* Fixo */
             craplot.nrdolote = i-nro-lote NO-ERROR NO-WAIT.
      
        IF   NOT AVAILABLE craplot   THEN  DO:
             IF   LOCKED craplot     THEN DO:
                  IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
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
             ELSE DO:
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
    END.  /*  DO WHILE */

    ASSIGN in99 = 0.
    DO WHILE TRUE:

        FIND craptit EXCLUSIVE-LOCK  WHERE
             craptit.cdcooper = crapcop.cdcooper   AND
             craptit.dtmvtolt = crapdat.dtmvtocd   AND
             craptit.cdagenci = craplot.cdagenci   AND
             craptit.cdbccxlt = craplot.cdbccxlt   AND
             craptit.nrdolote = craplot.nrdolote   AND
             craptit.dscodbar = p-codigo-barras NO-ERROR NO-WAIT.

        ASSIGN in99 = in99 + 1.
        IF    NOT AVAILABLE craptit THEN DO:
              IF   LOCKED craptit   THEN DO:
                   IF  in99 <  100  THEN DO:
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
                  ELSE DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Tabela CRAPTIT em uso ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                    INPUT YES).
                      RETURN "NOK".
                  END.
              END.
              ELSE  DO:
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
   
       LEAVE.
    END.  /*  DO WHILE */

    IF  craptit.flgpgdda  THEN DO:
        ASSIGN i-cod-erro  = 0           
               c-desc-erro = "Titulo DDA. Estorno nao permitido.".
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    ASSIGN craplot.vlcompcr = craplot.vlcompcr - craptit.vldpagto
           craplot.qtcompln = craplot.qtcompln - 1

           craplot.vlinfocr = craplot.vlinfocr - craptit.vldpagto 
           craplot.qtinfoln = craplot.qtinfoln - 1.

    ASSIGN p-pg     = NO
           p-docto  = craptit.nrdocmto
           p-histor = craplot.cdhistor.
  

    RUN dbo/b2crap14.p PERSISTENT SET h-b2crap14.
    RUN identifica-titulo-coop IN h-b2crap14
                             (INPUT  p-cooper,
                              INPUT  0,  /* Conta   */
                              INPUT  0,  /* Titular */
                              INPUT  p-cod-agencia,
                              INPUT  INT(p-nro-caixa),
                              INPUT  p-codigo-barras,
                              INPUT  FALSE,
                              OUTPUT aux-nrdconta-cob,
                              OUTPUT aux-insittit,
                              OUTPUT aux-intitcop,
                              OUTPUT aux-convenio,
                              OUTPUT aux-bloqueto,
                              OUTPUT aux-contaconve).

   DELETE PROCEDURE h-b2crap14.   
   
   IF aux-intitcop = 1 THEN /* Se for título da cooperativa */
      DO:

         /* Pega o codigo do banco (cddbanco) */
         FIND crapcco WHERE crapcco.cdcooper = crapcop.cdcooper AND
                            crapcco.nrconven = INTEGER(aux-convenio)
                            NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE crapcco   THEN
             DO:
                ASSIGN i-cod-erro  = 563
                       c-desc-erro = "".

                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".             
             END.         

         /* buscar ceb apenas para os convenios de 7 digitos 
            SD 218160 */
         IF LENGTH(STRING(aux-convenio)) >= 7 THEN
         DO:
             FIND crapceb WHERE  crapceb.cdcooper = crapcop.cdcooper     AND
                                 crapceb.nrconven = INT(aux-convenio)    AND
                                 crapceb.nrcnvceb =                            
                                         INTEGER(SUBSTR(p-codigo-barras, 33, 4))
                                 NO-LOCK NO-ERROR.
    
             IF  NOT AVAIL crapceb           AND
                 crapcop.cdcooper = 1        AND
                 INT(aux-convenio) = 1343313 AND
                 SUBSTR(p-codigo-barras, 33, 3) = "100" THEN
                 DO:
                     FOR EACH crapceb WHERE 
                              crapceb.cdcooper = crapcop.cdcooper  AND
                              crapceb.nrconven = INT(aux-convenio) AND
                              SUBSTR(TRIM(STRING(crapceb.nrcnvceb,"zzzz9")),1,4) = 
                                 TRIM(STRING(aux-convenio,"zzz9"))
                              NO-LOCK
                        ,EACH crapcob WHERE
                              crapcob.cdcooper = crapceb.cdcooper AND
                              crapcob.cdbandoc = crapcco.cddbanco AND
                              crapcob.nrdctabb = crapcco.nrdctabb AND
                              crapcob.nrcnvcob = crapceb.nrconven AND
                              crapcob.nrdconta = crapceb.nrdconta AND
                              crapcob.nrdocmto = aux-bloqueto     AND
                              crapcob.vldpagto = craptit.vldpagto
                              NO-LOCK:
                         aux_rowidcob = ROWID(crapcob).
                     END.
        
                     FIND crapcob WHERE ROWID(crapcob) = aux_rowidcob
                         NO-LOCK NO-ERROR.
        
                     IF  AVAIL crapcob THEN
                         DO:
                             FIND crapceb WHERE
                                  crapceb.cdcooper = crapcob.cdcooper AND
                                  crapceb.nrconven = crapcob.nrcnvcob AND
                                  crapceb.nrdconta = crapcob.nrdconta
                                  NO-LOCK NO-ERROR.
                         END.
        
                 END.
         END.
                             
         /*Quando for boleto da cooperativa, retira o codigo CEB do documento*/
         IF  AVAILABLE crapceb   THEN
             ASSIGN aux-bloqueto = DEC(STRING(crapceb.nrcnvceb,"99999") + 
                                        STRING(aux-bloqueto, "999999999"))
                    aux-bloqueto2 = DEC(SUBSTR(STRING(aux-bloqueto),
                                        LENGTH(STRING(aux-bloqueto)) - 5 , 6)).
         ELSE
             aux-bloqueto2 = aux-bloqueto.
              

         FIND craptdb WHERE  craptdb.cdcooper = crapcop.cdcooper   AND
                             craptdb.cdbandoc = crapcco.cddbanco   AND
                             craptdb.nrdconta = aux-nrdconta-cob   AND
                             craptdb.insittit = 2 /* Pago */       AND
                             craptdb.nrdctabb = aux-contaconve     AND
                             craptdb.nrcnvcob = INTE(aux-convenio) AND
                             craptdb.nrdocmto = aux-bloqueto2
                             NO-LOCK NO-ERROR.
                                                       
         IF NOT AVAIL craptdb AND 
             crapcco.flgregis = FALSE THEN 
            DO:
               ASSIGN in99 = 0.
               DO WHILE TRUE:

                  ASSIGN in99 = in99 + 1.

                  FIND b-craplot WHERE
                       b-craplot.cdcooper = crapcop.cdcooper AND
                       b-craplot.dtmvtolt = crapdat.dtmvtocd AND
                       b-craplot.cdagenci = p-cod-agencia    AND
                       b-craplot.cdbccxlt = 100              AND  /* Fixo */
                       b-craplot.nrdolote = 10800 + p-nro-caixa 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE b-craplot THEN  
                     DO:
                       IF LOCKED b-craplot THEN 
                          DO:
                            IF  in99 <  100  THEN 
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
                  LEAVE.                    
               END.  /*  DO WHILE b-craplot */

               ASSIGN in99 = 0.
               DO WHILE TRUE:

                  ASSIGN in99 = in99 + 1.
                  FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper   AND
                                     craplcm.dtmvtolt = b-craplot.dtmvtolt AND
                                     craplcm.cdagenci = b-craplot.cdagenci AND
                                     craplcm.cdbccxlt = b-craplot.cdbccxlt AND
                                     craplcm.nrdolote = b-craplot.nrdolote AND
                                     (craplcm.nrdocmto = aux-bloqueto      OR
                                      craplcm.nrdocmto = aux-bloqueto2)    AND
                                     craplcm.nrdctabb = aux-contaconve     AND
                                     craplcm.nrdconta = aux-nrdconta-cob
                                     USE-INDEX craplcm1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE craplcm   THEN  
                     DO:
                         IF LOCKED craplcm  THEN 
                            DO:
                               IF in99 <  100  THEN 
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
                                FIND   craplcm WHERE   craplcm.cdcooper = crapcop.cdcooper   AND
                                                       craplcm.dtmvtolt = b-craplot.dtmvtolt AND
                                                       craplcm.cdagenci = b-craplot.cdagenci AND
                                                       craplcm.cdbccxlt = b-craplot.cdbccxlt AND
                                                       craplcm.nrdolote = b-craplot.nrdolote AND
                                                    (  craplcm.nrdocmto = aux-bloqueto       OR
                                                       craplcm.nrdocmto = aux-bloqueto2)     AND
                                                       craplcm.nrdctabb = aux-nrdconta-cob   AND
                                                       craplcm.nrdconta = aux-nrdconta-cob
                                                       USE-INDEX craplcm1
                                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL craplcm THEN 
                                    DO:                                       

                                        ASSIGN i-cod-erro  = 11
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
                  LEAVE.
 
               END. /* while craplcm */
            END. 

         ASSIGN in99 = 0.
         DO WHILE TRUE:

            ASSIGN in99 = in99 + 1.

            FIND crapcob WHERE crapcob.cdcooper = crapcop.cdcooper   AND
                               crapcob.cdbandoc = crapcco.cddbanco   AND 
                               crapcob.nrcnvcob = INTE(aux-convenio) AND
                               crapcob.nrdconta = aux-nrdconta-cob   AND
                               crapcob.nrdocmto = aux-bloqueto2      AND
                               crapcob.nrdctabb = aux-contaconve
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE crapcob   THEN  
               DO:
                  IF LOCKED crapcob  THEN 
                     DO:
                        IF in99 <  100  THEN 
                           DO:
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                           END.
                        ELSE 
                           DO:
                             ASSIGN i-cod-erro  = 0
                                    c-desc-erro = "Tabela CRAPCOB em uso ".
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
                        ASSIGN i-cod-erro  = 11
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
                   ASSIGN crapcob.incobran = 0
                          crapcob.indpagto = 0
                          crapcob.dtdpagto = ?
                          crapcob.vldpagto = 0
                          crapcob.vltarifa = 0
                          crapcob.cdbanpag = 0
                          crapcob.cdagepag = 0
                          aux_nrcnvbol     =  crapcob.nrcnvcob  
                          aux_nrctabol     =  crapcob.nrdconta
                          aux_nrboleto     =  crapcob.nrdocmto.


                   IF  crapcob.nrctremp <> 0  THEN
                       aux_flgepr = TRUE.
                   ELSE
                       aux_flgepr = FALSE.

                   RUN estorna-tarifa-titulo (INPUT  crapcop.cdcooper,
                                              INPUT  aux-nrdconta-cob,
                                              INPUT  p-cod-agencia,
                                              INPUT  p-nro-caixa,
                                              INPUT  aux-convenio,
                                              INPUT  aux-bloqueto2,
                                              INPUT  aux_flgepr,
                                              OUTPUT c-desc-erro).

                   IF   RETURN-VALUE = "NOK"   THEN
                        DO:
                            RUN cria-erro (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT 0,
                                           INPUT c-desc-erro,
                                           INPUT YES).

                            RETURN "NOK".
                        END.

                   /* Verificar se é uma cobrança com regisrtro*/     
                   IF crapcob.flgregis THEN
                   DO:
                     /* Caso for é necessario deletar o registro 
                        na crapret cdocorre = 6 */
                        DO  aux_contador = 1 TO 10:
                            
                          FIND crapret
                             WHERE crapret.cdcooper = crapcob.cdcooper
                               AND crapret.nrdconta = crapcob.nrdconta
                               AND crapret.nrcnvcob = crapcob.nrcnvcob
                               AND crapret.nrdocmto = crapcob.nrdocmto
                               AND crapret.dtocorre = crapdat.dtmvtocd
                               AND crapret.cdocorre = 6
                               EXCLUSIVE-LOCK NO-ERROR.
                          
                            IF  NOT AVAILABLE crapret   THEN
                            DO:
                                IF  LOCKED crapret   THEN
                                    DO:                           
                                        PAUSE 1 NO-MESSAGE.
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Tabela CRAPRET em uso ".
                                        NEXT.
                                    END.
                            END.  
                            
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "".
                            LEAVE.
                        END. /*Fim loop de controle*/
                        
                        /* se encontrou critica, gerar registro de erro*/
                        IF i-cod-erro > 0 OR 
                           c-desc-erro  <> "" THEN
                        DO:
                                           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                        END.
                        
                        /*se localizou crapret com cdocorre = 6,
                           deve eliminar*/
                        IF AVAILABLE crapret THEN
                          DELETE crapret.
                        
                        /* Buscar  registro de retorno para o cooperado
                           na crapret com cdocorre = 17 */
                        DO  aux_contador = 1 TO 10:
                            
                          FIND crapret
                             WHERE crapret.cdcooper = crapcob.cdcooper
                               AND crapret.nrdconta = crapcob.nrdconta
                               AND crapret.nrcnvcob = crapcob.nrcnvcob
                               AND crapret.nrdocmto = crapcob.nrdocmto
                               AND crapret.dtocorre = crapdat.dtmvtocd
                               AND crapret.cdocorre = 17
                               EXCLUSIVE-LOCK NO-ERROR.
                          
                            IF  NOT AVAILABLE crapret   THEN
                            DO:
                                IF  LOCKED crapret   THEN
                                    DO:                           
                                        PAUSE 1 NO-MESSAGE.
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Tabela CRAPRET em uso ".
                                        NEXT.
                                    END.
                            END.  
                            
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "".
                            LEAVE.
                        END. /*Fim loop de controle*/
                        
                        /* se encontrou critica, gerar registro de erro*/
                        IF i-cod-erro > 0 OR 
                           c-desc-erro  <> "" THEN
                        DO:
                                           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                        END.
                        
                        /*se localizou crapret com cdocorre = 17,
                           deve eliminar*/
                        IF AVAILABLE crapret THEN
                          DELETE crapret.

						  
                     /* Caso for é necessario deletar o registro 
                        na crapret cdocorre = 76 */
                        DO  aux_contador = 1 TO 10:
                            
                          FIND crapret
                             WHERE crapret.cdcooper = crapcob.cdcooper
                               AND crapret.nrdconta = crapcob.nrdconta
                               AND crapret.nrcnvcob = crapcob.nrcnvcob
                               AND crapret.nrdocmto = crapcob.nrdocmto
                               AND crapret.dtocorre = crapdat.dtmvtocd
                               AND crapret.cdocorre = 76
                               EXCLUSIVE-LOCK NO-ERROR.
                          
                            IF  NOT AVAILABLE crapret   THEN
                            DO:
                                IF  LOCKED crapret   THEN
                                    DO:                           
                                        PAUSE 1 NO-MESSAGE.
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Tabela CRAPRET em uso ".
                                        NEXT.
                                    END.
                            END.  
                            
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "".
                            LEAVE.
                        END. /*Fim loop de controle*/
                        
                        /* se encontrou critica, gerar registro de erro*/
                        IF i-cod-erro > 0 OR 
                           c-desc-erro  <> "" THEN
                        DO:
                                           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                        END.
                        
                        /*se localizou crapret com cdocorre = 76,
                           deve eliminar*/
                        IF AVAILABLE crapret THEN
                          DELETE crapret.
						  
						  
                     /* Caso for é necessario deletar o registro 
                        na crapret cdocorre = 77 */
                        DO  aux_contador = 1 TO 10:
                            
                          FIND crapret
                             WHERE crapret.cdcooper = crapcob.cdcooper
                               AND crapret.nrdconta = crapcob.nrdconta
                               AND crapret.nrcnvcob = crapcob.nrcnvcob
                               AND crapret.nrdocmto = crapcob.nrdocmto
                               AND crapret.dtocorre = crapdat.dtmvtocd
                               AND crapret.cdocorre = 77
                               EXCLUSIVE-LOCK NO-ERROR.
                          
                            IF  NOT AVAILABLE crapret   THEN
                            DO:
                                IF  LOCKED crapret   THEN
                                    DO:                           
                                        PAUSE 1 NO-MESSAGE.
                                        ASSIGN i-cod-erro  = 0
                                               c-desc-erro = "Tabela CRAPRET em uso ".
                                        NEXT.
                                    END.
                            END.  
                            
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "".
                            LEAVE.
                        END. /*Fim loop de controle*/
                        
                        /* se encontrou critica, gerar registro de erro*/
                        IF i-cod-erro > 0 OR 
                           c-desc-erro  <> "" THEN
                        DO:
                                           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                        END.
                        
                        /*se localizou crapret com cdocorre = 77,
                           deve eliminar*/
                        IF AVAILABLE crapret THEN
                          DELETE crapret.
						  

                        /* criar log de cobranca */
                        RUN sistema/generico/procedures/b1wgen0089.p
                           PERSISTENT SET h-b1wgen0089.
                           
                        IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "Handle invalido para " +
                                                "h-b1wgen0089.".
                            
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT 0,
                                          INPUT c-desc-erro,
                                          INPUT YES).

                           RETURN "NOK".
                        END.
                        
                        RUN cria-log-cobranca IN h-b1wgen0089                        
                                  (INPUT ROWID(crapcob),
                                   INPUT p-cod-operador,
                                   INPUT crapdat.dtmvtocd,
                                   INPUT "Cobrança estornada.").

                       DELETE PROCEDURE h-b1wgen0089.

                   END. /* Fim IF crapcob.flgregis */


                   IF  crapcob.nrctremp <> 0  AND 
                       crapcob.nrctasac <> 0  THEN
                   DO:
                   /* Fazer estorno de lancamentos de baixa de emprestimo */
                   RUN sistema/generico/procedures/b1wgen0023.p
                       PERSISTENT SET h-b1wgen0023.
                       
                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = "Handle invalido para " +
                                                "h-b1wgen0023.".
                            
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT 0,
                                          INPUT c-desc-erro,
                                          INPUT YES).

                           RETURN "NOK".
                       END.

                   /* Faz os lancamentos necessarios */
                   RUN estorna_baixa_epr_titulo IN h-b1wgen0023
                                             (INPUT crapcop.cdcooper,
                                              INPUT 0,   /* agencia */
                                              INPUT 0,   /* nro-caixa */  
                                              INPUT 0,   /* operador */
                                              INPUT crapcob.nrdconta,
                                              INPUT 1,   /* idseqttl */
                                              INPUT 1,   /* Ayllos */
                                              INPUT "b2crap15.p",
                                              INPUT crapdat.dtmvtolt,
                                              INPUT crapcob.nrctasac,
                                              INPUT crapcob.nrctremp,
                                              INPUT crapcob.nrdocmto,
                                              INPUT crapcob.dtvencto,
                                              INPUT TRUE,
                                              OUTPUT TABLE tt-erro).
                   
                   DELETE PROCEDURE h-b1wgen0023.
                  
                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           /* Caso ocorra erros, joga pro log */
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                           IF  AVAILABLE tt-erro  THEN
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                          c-desc-erro = tt-erro.dscritic.
                            
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT 0,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).

                               END.
                           ELSE
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                          c-desc-erro = 
                                          "Emprestimo nao estornado. Conta " + 
                                           STRING(crapcob.nrdconta) +
                                          " Ctr. " + 
                                           STRING(crapcob.nrctremp) +
                                          " Cta.Sac. " +
                                           STRING(crapcob.nrctasac) +
                                          " Bol. " +
                                           STRING(crapcob.nrdocmto).
                            
                                   RUN cria-erro (INPUT p-cooper,
                                                  INPUT p-cod-agencia,
                                                  INPUT p-nro-caixa,
                                                  INPUT 0,
                                                  INPUT c-desc-erro,
                                                  INPUT YES).
                               END.
                               
                           RETURN "NOK".
                               
                       END.     
                   END. /* final do estorno de titulos em emprestimo */   
               END.

            LEAVE.
         END. /* while crapcob */

         IF NOT AVAIL craptdb AND 
            crapcco.flgregis = FALSE THEN 
            DO:
               ASSIGN b-craplot.vlcompcr = b-craplot.vlcompcr - craplcm.vllanmto
                      b-craplot.qtcompln = b-craplot.qtcompln - 1               
                      b-craplot.vlinfocr = b-craplot.vlinfocr - craplcm.vllanmto
                      b-craplot.qtinfoln = b-craplot.qtinfoln - 1.

               IF  b-craplot.vlcompdb = 0 AND
                   b-craplot.vlinfodb = 0 AND
                   b-craplot.vlcompcr = 0 AND
                   b-craplot.vlinfocr = 0 THEN
                   DELETE b-craplot.
               ELSE
                   RELEASE b-craplot.
   
               RELEASE crapcob.
               DELETE craplcm.
            END.
      
         ASSIGN in99 = 0.
         DO WHILE TRUE:
            
            FIND crapchd EXCLUSIVE-LOCK  WHERE
                 crapchd.cdcooper = crapcop.cdcooper    AND
                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                 crapchd.cdagenci = p-cod-agencia       AND 
                 crapchd.cdbccxlt = 500                 AND
                 crapchd.nrdolote = 28000 + p-nro-caixa AND
                 crapchd.nrboleto = aux_nrboleto        AND
                 crapchd.nrctabol = aux_nrctabol        AND
                 crapchd.nrcnvbol = aux_nrcnvbol        NO-ERROR NO-WAIT.
    
            ASSIGN in99 = in99 + 1.
            IF    NOT AVAILABLE crapchd THEN DO:
                  IF   LOCKED crapchd   THEN DO:
                       IF  in99 <  100  THEN DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      ELSE DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Tabela CRAPCHD em uso ".           
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
       
            LEAVE.
         END.  /*  DO WHILE */
         
         IF  AVAIL crapchd THEN 
             DO:
                 ASSIGN in99 = 0.
                 DO WHILE TRUE:
                   
                    ASSIGN in99 = in99 + 1.
                    FIND crablot EXCLUSIVE-LOCK  WHERE
                         crablot.cdcooper = crapcop.cdcooper AND
                         crablot.dtmvtolt = crapdat.dtmvtocd AND 
                         crablot.cdagenci = crapchd.cdagenci AND
                         crablot.cdbccxlt = crapchd.cdbccxlt AND
                         crablot.nrdolote = crapchd.nrdolote NO-ERROR NO-WAIT.
                  
                    IF   NOT AVAILABLE crablot   THEN  DO:
                         IF   LOCKED crablot     THEN DO:
                              IF  in99 <  100  THEN DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                              ELSE DO:
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
                         ELSE DO:
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
                 END.  /*  DO WHILE */

                 ASSIGN crablot.vlcompdb = crablot.vlcompdb - crapchd.vlcheque
                        crablot.vlcompcr = crablot.vlcompcr - crapchd.vlcheque
                        crablot.vlinfodb = crablot.vlinfodb - crapchd.vlcheque
                        crablot.vlinfocr = crablot.vlinfocr - crapchd.vlcheque
                        crablot.qtinfoln = crablot.qtinfoln - 1
                        crablot.qtcompln = crablot.qtcompln - 1.                                                    
            
                 /*** Lote de cheque ***/
                 IF crablot.vlcompdb = 0 AND
                    crablot.vlinfodb = 0 AND
                    crablot.vlcompcr = 0 AND
                    crablot.vlinfocr = 0 THEN
                    DELETE crablot.
                 ELSE
                    RELEASE crablot.
            
                 DELETE crapchd.

                 RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00. 
                 RUN atualiza-previa-caixa IN h-b1crap00 (INPUT crapcop.nmrescop,
                                                          INPUT p-cod-agencia,
                                                          INPUT p-nro-caixa,
                                                          INPUT p-cod-operador,
                                                          INPUT crapdat.dtmvtolt,
                                                          INPUT 2).  /*Estorno*/
                 DELETE PROCEDURE h-b1crap00.

             END. /**IF AVAIL crapchd **/
      END.
   
   IF craplot.vlcompdb = 0 AND
      craplot.vlinfodb = 0 AND
      craplot.vlcompcr = 0 AND
      craplot.vlinfocr = 0 THEN
      DELETE craplot.
   ELSE
      RELEASE craplot.
      
   DELETE craptit.

   RETURN "OK".

END PROCEDURE.

PROCEDURE estorna-tarifa-titulo:
 
    DEF INPUT  PARAM p-cdcooper          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nrdconta-cob      AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-convenio          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-nrautdoc          AS INTE                       NO-UNDO.
    DEF INPUT  PARAM p-flgepr            AS LOGICAL                    NO-UNDO.
    
    DEF OUTPUT PARAM p-dscritic          AS CHAR                       NO-UNDO.
    
    DEF VARIABLE     aux_cdhistor        LIKE craplcm.cdhistor         NO-UNDO.
    DEF VARIABLE     aux_vltarifa        LIKE craplcm.vllanmto         NO-UNDO.
    
    DEF VARIABLE     aux_vlrtarif        LIKE craplcm.vllanmto         NO-UNDO.
    DEF VARIABLE     aux_idorigem        AS INTE                       NO-UNDO.

    DEF BUFFER crablcm FOR craplcm.
    
    
    /* Data do sistema */
    FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

    /* Pega o historico e valor da taxa */
    FIND crapcco WHERE crapcco.cdcooper = p-cdcooper   AND
                       crapcco.nrconven = p-convenio   NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcco   THEN
         DO:
             p-dscritic = "Convenio nao encontrado.".
             RETURN "NOK".
         END.

    /* Tarifa para pagamento atraves da internet */
    IF   p-cod-agencia = 90   THEN
         ASSIGN aux_cdhistor = crapcco.cdhisnet
                aux_vltarifa = crapcco.vlrtarnt.
    ELSE /* Tarifa para pagamento atraves de TAA/Cash */
    IF   p-cod-agencia = 91   THEN
         ASSIGN aux_cdhistor = crapcco.cdhistaa
                aux_vltarifa = crapcco.vltrftaa.
    ELSE
    /* Tarifa para pagamento atraves do caixa on-line */
         ASSIGN aux_cdhistor = crapcco.cdhiscxa
                aux_vltarifa = crapcco.vlrtarcx.     

    FIND craptdb WHERE craptdb.cdcooper = crapcop.cdcooper AND
                       craptdb.nrdconta = p-nrdconta-cob   AND
                       craptdb.insittit = 2 /* Pago */     AND
                       craptdb.cdbandoc = crapcco.cddbanco AND
                       craptdb.nrcnvcob = p-convenio       AND
                       craptdb.nrdocmto = p-nrautdoc       AND
                       craptdb.nrdctabb = crapcco.nrdctabb     
                       NO-LOCK NO-ERROR.

    IF  AVAIL craptdb THEN
        DO:  

              CREATE tt-titulos.
              BUFFER-COPY craptdb TO tt-titulos.

              IF   p-cod-agencia = 90   THEN      
                   aux_idorigem  = 3.    /** Internet **/
              ELSE
              IF   p-cod-agencia = 91   THEN
                   aux_idorigem  = 4.    /** Cash/TAA **/
              ELSE
                   aux_idorigem  = 2.    /** Caixa On-Line **/
                   
              RUN sistema/generico/procedures/b1wgen0030.p 
                  PERSISTENT SET h-b1wgen0030. 
                                    
              RUN efetua_estorno_baixa_titulo IN h-b1wgen0030( 
                                                 INPUT p-cdcooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT 0, /* operador */
                                                 INPUT crapdat.dtmvtoan,
                                                 INPUT crapdat.dtmvtolt,
                                                 INPUT aux_idorigem,
                                                 INPUT p-nrdconta-cob,
                                                 INPUT TABLE tt-titulos,
                                                 OUTPUT TABLE tt-erro).
                                                       
              DELETE PROCEDURE h-b1wgen0030. 

              IF   RETURN-VALUE <> "OK"   THEN
              DO:
                   FIND FIRST tt-erro.
                   p-dscritic =  tt-erro.dscritic.
                   UNDO, RETURN "NOK".
              END.
                
        END.                                                 

    RETURN "OK".
 
END PROCEDURE. /* fim estorna-tarifa-titulo */

/* b2crap15.p */