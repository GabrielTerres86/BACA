/*---------------------------------------------------------------------
   Programa: siscaixa/web/dbo/b2crap15.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : 
   Data    :                             Ultima atualizacao: 24/05/2017

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
							
			   24/05/2017 - Procedure estora-titulo-iptu convertida para
                            Oracle (Projeto 340 - Demetrius/Odirlei)			   
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
    DEF OUTPUT  PARAM pr_cdctrbxo       AS CHAR. 
    
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
    
    FIND LAST craptit NO-LOCK WHERE
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
    ASSIGN pr_cdctrbxo   =  craptit.cdctrbxo.
    
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
    
    DEF    VAR      aux_cdcritic         AS DECI                    NO-UNDO.
    DEF    VAR      aux_dscritic         AS CHAR                    NO-UNDO.
    DEF    VAR      aux_iptu             AS DECI                    NO-UNDO.
    DEF    VAR      aux_pg               AS DECI                    NO-UNDO.
    DEF    VAR      aux_histor           AS DECI                    NO-UNDO.
    
    IF p-iptu THEN 
      aux_iptu = 1.
    ELSE
      aux_iptu = 0.

    FIND FIRST crapcop NO-LOCK WHERE
         crapcop.nmrescop = p-cooper  NO-ERROR.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
           
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        

RUN STORED-PROCEDURE pc_estorna_titulos_iptu
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT crapcop.cdcooper,
                             INPUT p-cod-operador,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                             INPUT aux_iptu,
                              INPUT  p-codigo-barras,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT 0,
                             OUTPUT 0,   /* pr_cdcritic */
                             OUTPUT " "). /* pr_dscritic */

CLOSE STORED-PROC pc_estorna_titulos_iptu
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = pc_estorna_titulos_iptu.pr_cdcritic
           aux_dscritic = pc_estorna_titulos_iptu.pr_dscritic
           aux_pg       = pc_estorna_titulos_iptu.pr_pg
           p-docto      = pc_estorna_titulos_iptu.pr_docto
           aux_histor   = pc_estorna_titulos_iptu.pr_histor
           p-histor     = aux_histor.
   
    IF aux_pg = 1 THEN
       p-pg = TRUE.
    ELSE
       p-pg = FALSE.    
           
    IF TRIM(aux_dscritic) <> ? THEN
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