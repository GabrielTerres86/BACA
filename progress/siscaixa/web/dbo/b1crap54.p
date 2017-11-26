/* .............................................................................

   Programa: siscaixa/web/b1crap54.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 17/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Movimentacoes  - Cheque Avulso (Historico 22)

   Alteracoes: 25/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               23/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               23/12/2008 - Incluido o campo "capital" na temp-table tt-conta
                            (Elton).             

               10/03/2009 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               21/08/2009 - Incluido nome e cpf do segundo titular abaixo do
                            campo de assinatura na impressao (Elton).
                            
               13/12/2011 - Saque com o cartao magnetico (Gabriel).
               
               19/01/2011 - Alterar nrsencar para dssencar (Guilherme).
               
               04/06/2013 - Alterado função lista-saldo-conta para retorno de saldo (Jean Michel).
               
               23/10/2013 - Incluída validação do nível do operador na 
                            procedure 'valida-permissao-saldo-conta' (Diego).
               
               28/05/2014 - Retirada validacao do nivel de operador na 
                            procedure 'valida-permissao-saldo-conta' (Elton).
                            
               27/11/2014 - #227966 Ajustes para a incorporacao da concredi e 
                            credimilsul (Carlos)
                            
               08/09/2015 - Incluido verificacao de taxas de saque, Prj. Tarifas
                            - 218 (Jean Michel).
                            
               02/02/2016 - Incluido verificacao da flag "flsaqpre" para isentar 
                            taxas de saque presencial.(Lombardi #393807).
                            
               23/02/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                            PinPad Novo (Lucas Lunelli - [PROJ290])
               05/04/2016 - Incluidos novos parametros na procedure
                            pc_verifica_tarifa_operacao, Prj 218 (Jean Michel).
                            
			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
                            
............................................................................ */

/*----------------------------------------------------------------------*/
/*  b1crap54.p - Movimentacoes  - Cheque Avulso (Historico 22)          */
/*----------------------------------------------------------------------*/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
/*{ sistema/generico/includes/var_oracle.i } */


DEF VAR i-cod-erro         AS INT                               NO-UNDO.
DEF VAR c-desc-erro        AS CHAR                              NO-UNDO.

DEF VAR i-nro-lote         AS INTE                              NO-UNDO.
DEF VAR aux_nrdconta       AS INTE                              NO-UNDO.
DEF VAR i_conta            AS DEC                               NO-UNDO.
DEF VAR aux_nrtrfcta       LIKE craptrf.nrsconta                NO-UNDO.

DEF VAR h_b2crap00         AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap02         AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap00         AS HANDLE                            NO-UNDO.

DEF VAR in99               AS INTE                              NO-UNDO.
DEF VAR de-valor           AS DEC                               NO-UNDO.

DEF VAR de-valor-libera    AS DEC                               NO-UNDO.
DEF VAR p-literal          AS CHAR                              NO-UNDO.
DEF VAR p-ult-sequencia    AS INTE                              NO-UNDO.
DEF var p-registro         AS RECID                             NO-UNDO.
DEF VAR p-nrdocto          AS INTE                              NO-UNDO.
DEF VAR c-valor            AS CHAR                              NO-UNDO.
       
DEF VAR de-valor-bloqueado AS DEC                               NO-UNDO.
DEF VAR de-valor-liberado  AS DEC                               NO-UNDO.

DEF VAR c-cgc-cpf1         AS CHAR   FORMAT "x(19)"             NO-UNDO.
DEF VAR c-cgc-cpf2         AS CHAR   FORMAT "x(19)"             NO-UNDO.
DEF VAR c-nome-titular1    AS CHAR   FORMAT "x(40)"             NO-UNDO.
DEF VAR c-nome-titular2    AS CHAR   FORMAT "x(40)"             NO-UNDO.
DEF VAR c-literal          AS CHAR   FORMAT "x(48)" EXTENT 33.
DEF VAR c-linha1           AS CHAR   FORMAT "x(47)"             NO-UNDO.
DEF VAR c-linha2           AS CHAR   FORMAT "x(47)"             NO-UNDO.
DEF VAR c-docto            AS CHAR                              NO-UNDO. 

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
    FIELD disponivel         AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-praca         AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-fora-praca    AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD cheque-salario     AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD saque-maximo       AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD acerto-conta       AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD db-cpmf            AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD limite-credito     AS DEC 
    FIELD ult-atualizacao    AS DATE
    FIELD saldo-total        AS DEC  FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-". 

PROCEDURE valida-cheque-avulso-conta:
    
    DEF INPUT        PARAM p-cooper              AS CHAR.
    DEF INPUT        PARAM p-cod-agencia         AS INTEGER.  /* Cod. Agencia    */
    DEF INPUT        PARAM p-nro-caixa           AS INTEGER.  /* Numero Caixa    */
    DEF INPUT        PARAM p-opcao               AS CHAR.  /* (R)ecibo / (C)artao*/
    DEF INPUT        PARAM p-cartao              AS DEC.      /* Nro Cartao */
    DEF INPUT-OUTPUT PARAM p-nro-conta           AS DEC.      /* Nro Conta       */
    DEF OUTPUT       PARAM p-nome-titular        AS CHAR.
    DEF OUTPUT       PARAM p-transferencia-conta AS CHAR.
    DEF OUTPUT       PARAM p-nrcartao            AS DECI.
    DEF OUTPUT       PARAM p-idtipcar            AS INTE.
                      
    DEF VAR h-b1wgen0032 AS HANDLE               NO-UNDO.
    DEF VAR h-b1wgen0025 AS HANDLE               NO-UNDO.
    DEF VAR aux_dscartao AS CHAR                 NO-UNDO.

    DEF VAR aux_nrcartao AS DEC                  NO-UNDO.
    DEF VAR aux_nrdconta AS INT                  NO-UNDO.
    DEF VAR aux_cdcooper AS INT                  NO-UNDO.
    DEF VAR aux_inpessoa AS INT                  NO-UNDO.
    DEF VAR aux_idsenlet AS LOGICAL              NO-UNDO.
    DEF VAR aux_idseqttl AS INT                  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                 NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
 
    IF   p-opcao = "R"   THEN /* Recibo */
         DO:
             IF  p-nro-conta = 0  THEN 
                 DO:
                     ASSIGN i-cod-erro  = 0
                            c-desc-erro = "Conta deve ser Informada".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.    
    ELSE     /* Cartao */
         DO:
             IF   p-cartao = 0   THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                            c-desc-erro = "Numero do cartao deve ser Informado".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.


             ASSIGN aux_dscartao = "XX" + SUBSTR(STRING(p-cartao),1,16) + "=" + SUBSTR(STRING(p-cartao),17).
                  
             RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.
                 
             RUN verifica_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                                 INPUT 0,
                                                 INPUT aux_dscartao, 
                                                INPUT crapdat.dtmvtolt,
                                               OUTPUT p-nro-conta,
                                                OUTPUT aux_cdcooper,
                                                OUTPUT p-nrcartao,
                                                OUTPUT aux_inpessoa,
                                                OUTPUT aux_idsenlet,
                                                OUTPUT aux_idseqttl,
                                                OUTPUT p-idtipcar,
                                                OUTPUT aux_dscritic).

             DELETE PROCEDURE h-b1wgen0025.

             IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
                  DO:
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT aux_dscritic,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    
    ASSIGN i_conta = p-nro-conta.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (INPUT p-cooper,
                                               INPUT p-cod-agencia, 
                                               INPUT p-nro-caixa, 
                                               INPUT p-nro-conta, 
                                              OUTPUT aux_nrdconta).
    IF   RETURN-VALUE = "NOK" THEN 
         DO:
             DELETE PROCEDURE h-b1crap02.
             RETURN "NOK".
         END.
         
    IF   aux_nrdconta <> 0 THEN
         RUN retornaMsgTransferencia IN h-b1crap02 (INPUT p-cooper,
                                                    INPUT p-cod-agencia, 
                                                    INPUT p-nro-caixa,
                                                    INPUT p-nro-conta, 
                                                   OUTPUT p-transferencia-conta).
    DELETE PROCEDURE h-b1crap02.

    IF   aux_nrdconta <> 0 THEN
         ASSIGN p-nro-conta = aux_nrdconta.
    
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper      AND
                       crapass.nrdconta = INTEGER(p-nro-conta)  NO-LOCK.

    ASSIGN p-nome-titular = crapass.nmprimtl.
   
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-cheque-avulso-valor:
    
    DEF INPUT PARAM p-cooper         AS CHAR.
    DEF INPUT PARAM p-cod-agencia    AS INTEGER.  /* Cod. Agencia       */
    DEF INPUT PARAM p-nro-caixa      AS INTEGER.  /* Numero Caixa       */
    DEF INPUT PARAM p-valor          AS DEC.
     
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  p-valor <= 0  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Um valor maior que zero deve ser Informado".
                   
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

PROCEDURE valida-saldo-conta:

    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-conta        AS DEC.
    DEF INPUT  PARAM p-valor            AS DEC.
    DEF OUTPUT PARAM p-mensagem         AS CHAR.
    DEF OUTPUT PARAM p-valor-disponivel AS DEC.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = DEC(REPLACE(string(p-nro-conta),".","")).

    ASSIGN p-mensagem         = " "
           p-valor-disponivel = 0.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (p-cooper,
                                               p-cod-agencia, 
                                               p-nro-caixa, 
                                               p-nro-conta, 
                                               OUTPUT aux_nrdconta).

    IF RETURN-VALUE = "NOK" THEN 
        DO:
            DELETE PROCEDURE h-b1crap02.
            RETURN "NOK".
        END.

    IF aux_nrdconta <> 0 THEN
        ASSIGN p-nro-conta = aux_nrdconta.

    RUN consulta-conta IN h-b1crap02(INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT p-nro-conta,
                                     OUTPUT TABLE tt-conta).
    DELETE PROCEDURE h-b1crap02.

    IF  RETURN-VALUE = "NOK" THEN   
        RETURN "NOK".                    

    ASSIGN de-valor-libera = 0.
    FIND FIRST tt-conta NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-conta  THEN  
        DO:
            
            ASSIGN de-valor-bloqueado = tt-conta.bloqueado +
                                        tt-conta.bloq-praca +
                                        tt-conta.bloq-fora-praca.
            ASSIGN de-valor-liberado = tt-conta.acerto-conta -
                                       de-valor-bloqueado.
            IF  de-valor-liberado  + tt-conta.limite-credito < p-valor THEN
                DO:
                    
                    ASSIGN p-valor-disponivel = 
                                de-valor-liberado + 
                                tt-conta.limite-credito
                           de-valor-libera    = 
                                (de-valor-liberado - p-valor) * -1.
         
                    ASSIGN p-mensagem         = 
                                "Saldo " +
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
        END.    
       
    RETURN "OK".
END PROCEDURE.

PROCEDURE lista-saldo-conta:
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-conta        AS DEC.
    DEF INPUT  PARAM p-valor            AS DEC.
    DEF OUTPUT PARAM p-mensagem         AS CHAR.
    DEF OUTPUT PARAM p-saldo-conta      AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta = DEC(REPLACE(string(p-nro-conta),".","")).
   
    ASSIGN p-mensagem         = " "
            p-saldo-conta = "".

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                                         
    RUN retornaCtaTransferencia IN h-b1crap02 (p-cooper,
                                               p-cod-agencia, 
                                               p-nro-caixa, 
                                               p-nro-conta, 
                                               OUTPUT aux_nrdconta).

    IF  RETURN-VALUE = "NOK" THEN 
        DO:
            DELETE PROCEDURE h-b1crap02.
            RETURN "NOK".
        END.

    IF aux_nrdconta <> 0 THEN
        ASSIGN p-nro-conta = aux_nrdconta.

    RUN  consulta-conta IN h-b1crap02(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT p-nro-conta,
                                      OUTPUT TABLE tt-conta).
    DELETE PROCEDURE h-b1crap02.

    IF  RETURN-VALUE = "NOK" THEN   
        RETURN "NOK".                    

    FIND FIRST tt-conta NO-LOCK NO-ERROR.
    IF  AVAIL tt-conta THEN  
        DO:
         
            ASSIGN de-valor-bloqueado = tt-conta.bloqueado +
                                        tt-conta.bloq-praca +
                                        tt-conta.bloq-fora-praca.
            ASSIGN de-valor-liberado = tt-conta.acerto-conta -
                                       de-valor-bloqueado.
            ASSIGN p-mensagem = "Saldo " +
                                TRIM(STRING(de-valor-liberado,
                                     "zzz,zzz,zzz,zz9~.99-")) +
                                "  Limite " +
                                TRIM(STRING(tt-conta.limite-credito,
                                     "zzz,zzz,zzz,zz9.99-")) +
                                " Bloqueado " +
                                TRIM(STRING(de-valor-bloqueado,
                                     "zzz,zzz,zzz,zz9.99-")).
            ASSIGN p-saldo-conta = TRIM(STRING(de-valor-liberado,"zzz,zzz,zzz,zz9~.99-")). 

        END.
    RETURN "OK".

END PROCEDURE.
   
PROCEDURE valida-permissao-saldo-conta:
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-valor            AS DEC.
    DEF INPUT  PARAM p-cod-operador     AS CHAR.
    DEF INPUT  PARAM p-nro-conta        AS DEC.     
    DEF INPUT  PARAM p-nrcartao         AS DECI.
    DEF INPUT  PARAM p-opcao            AS CHAR.
    DEF INPUT  PARAM p-senha-cartao     AS CHAR.
    DEF INPUT  PARAM p-codigo           AS char.
    DEF INPUT  PARAM p-senha            AS CHAR.
    DEF INPUT  PARAM p-disponivel       AS DEC.    
    DEF INPUT  PARAM p-mensagem         AS CHAR.                                
    DEF INPUT  PARAM p-idtipcar         AS INTE.
    DEF INPUT  PARAM p-infocry          AS CHAR.
    DEF INPUT  PARAM p-chvcry           AS CHAR.

    DEF VAR h-b1wgen0025 AS HANDLE                                NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
    DEF VAR aux_dspnblcr AS CHAR                                  NO-UNDO.
             
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
                
    IF   p-opcao = "C"   THEN
                    DO: 
            RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.
                        
            RUN valida_senha_tp_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                                       INPUT p-nro-conta, 
                                                       INPUT p-nrcartao,
                                                       INPUT p-idtipcar,
                                                       INPUT p-senha-cartao,
                                                       INPUT p-infocry,
                                                       INPUT p-chvcry,
                                                      OUTPUT aux_cdcritic,
                                                      OUTPUT aux_dscritic). 

            DELETE PROCEDURE h-b1wgen0025.

            IF  RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
                  DO:
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                   INPUT aux_cdcritic,
                                   INPUT aux_dscritic,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.

    ASSIGN de-valor-libera =  (p-disponivel - p-valor) * -1.

    IF  p-mensagem <> "" THEN 
        DO:
            IF  p-codigo = "" THEN 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Informe Codigo/Senha ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                               crapope.cdoperad = p-codigo 
                               NO-ERROR.
                                     
            IF  NOT AVAIL crapope THEN 
                DO:
                    ASSIGN i-cod-erro  = 67
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.
           
            IF  p-senha <> crapope.cddsenha  THEN 
                DO:
                    ASSIGN i-cod-erro  = 3
                           c-desc-erro = " ".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.

            /******* Comentado em 28/05/2014 *******
            IF   p-opcao = "crap051a2"  THEN
                 DO:
                     /* Nivel 2-Coordenador / 3-Gerente */
                     IF   crapope.nvoperad < 2   THEN
                          DO:
                              RUN cria-erro (INPUT p-cooper,        
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT 824,
                                             INPUT "",
                                             INPUT YES).
                              RETURN "NOK".
                          END.
                 END.
            ***********************/

            IF  crapope.vlpagchq < de-valor-libera THEN 
                DO:

                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Sem Permissao p/Liberacao " + 
                                         STRING(de-valor-libera).
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.  /* p-mensagem <> " " */
        
        END.
   
    RETURN "OK".
END PROCEDURE.


PROCEDURE atualiza-cheque-avulso:
    
    DEF INPUT  PARAM p-cooper                  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia             AS INTEGER. /* Cod. Agencia */
    DEF INPUT  PARAM p-nro-caixa               AS INTEGER. /* Numero Caixa */
    DEF INPUT  PARAM p-cod-operador            AS CHAR.
    DEF INPUT  PARAM p-cod-liberador           AS CHAR.
    DEF INPUT  PARAM p-opcao                   AS CHAR.
    DEF INPUT  PARAM p-nrcartao                AS DECI.
    DEF INPUT  PARAM p-idtipcar                AS INTE.
    DEF INPUT  PARAM p-nro-conta               AS DEC.   
    DEF INPUT  PARAM p-valor                   AS DEC.
    DEF OUTPUT PARAM p-nrdocmto                AS DEC.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia-autentica AS INTE.
 
    DEF VAR aux_cdcritic AS INTE NO-UNDO.
    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_idtipcar AS INTE NO-UNDO.
    DEF VAR aux_nrcartao AS DECI NO-UNDO.
    DEF VAR aux_cdhistor AS INTE NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN c-docto    = STRING(time) + "1".  

    ASSIGN p-nrdocto  = INTE(c-docto)
           p-nrdocmto = p-nrdocto.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (p-cooper,
                                               p-cod-agencia, 
                                               p-nro-caixa, 
                                               p-nro-conta, 
                                               OUTPUT aux_nrdconta).

    IF  RETURN-VALUE = "NOK" THEN 
        DO:
            DELETE PROCEDURE h-b1crap02.
            RETURN "NOK".
        END.

    IF aux_nrdconta <> 0 THEN
        ASSIGN p-nro-conta = aux_nrdconta.

    DELETE PROCEDURE h-b1crap02.
           
    FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                             craplot.dtmvtolt = crapdat.dtmvtolt AND
                             craplot.cdagenci = p-cod-agencia    AND
                             craplot.cdbccxlt = 11               AND /* Fixo */
                             craplot.nrdolote = i-nro-lote       NO-ERROR.
         
    IF  NOT AVAIL craplot THEN 
        DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = crapcop.cdcooper
                   craplot.dtmvtolt = crapdat.dtmvtolt
                   craplot.cdagenci = p-cod-agencia   
                   craplot.cdbccxlt = 11              
                   craplot.nrdolote = i-nro-lote
                   craplot.tplotmov = 1
                   craplot.cdoperad = p-cod-operador
                   craplot.cdhistor = 0 /* 22 */
                   craplot.nrdcaixa = p-nro-caixa
                   craplot.cdopecxa = p-cod-operador.
        END.

    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper    AND
                             craplcm.dtmvtolt = crapdat.dtmvtolt    AND 
                             craplcm.cdagenci = p-cod-agencia       AND
                             craplcm.cdbccxlt = 11                  AND
                             craplcm.nrdolote = i-nro-lote          AND
                             craplcm.nrdctabb = inte(p-nro-conta)   AND
                             craplcm.nrdocmto = p-nrdocto           
                             USE-INDEX craplcm1 NO-ERROR.
         
    IF  AVAIL craplcm  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "CRAPLCM(1)Existe - Avise INF " +
                                 STRING(p-nro-conta) + " - " +
                                 STRING(p-nrdocto).
                                 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    FIND FIRST craplcm WHERE craplcm.cdcooper = crapcop.cdcooper    AND
                             craplcm.dtmvtolt = crapdat.dtmvtolt    AND 
                             craplcm.cdagenci = p-cod-agencia       AND
                             craplcm.cdbccxlt = 11                  AND
                             craplcm.nrdolote = i-nro-lote          AND
                             craplcm.nrseqdig = craplot.nrseqdig + 1  
                             USE-INDEX craplcm3 NO-ERROR.   
         
    IF  AVAIL craplcm  THEN  
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "CRAPLCM(2)Existe - Avise INF " + 
                                 STRING(i-nro-lote) + " - " + 
                                 STRING(craplot.nrseqdig + 1).
                                 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    CREATE craplcm.
    ASSIGN craplcm.cdcooper = crapcop.cdcooper
           craplcm.dtmvtolt = crapdat.dtmvtolt
           craplcm.cdagenci = p-cod-agencia
           craplcm.cdbccxlt  = 11
           craplcm.nrdolote = i-nro-lote
           craplcm.nrdconta = p-nro-conta
           craplcm.nrdocmto = p-nrdocto
           craplcm.vllanmto = p-valor 
           craplcm.cdhistor = IF   (p-opcao = "R" )   THEN   
                                   22
                              ELSE  
                                   1030
           craplcm.nrseqdig = craplot.nrseqdig + 1 
           craplcm.nrdctabb = p-nro-conta
           craplcm.nrdctitg = STRING(p-nro-conta,"99999999")
           craplcm.cdpesqbb = "CRAP54," + p-cod-liberador.
   
    ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1 
           craplot.qtcompln  = craplot.qtcompln + 1
           craplot.qtinfoln  = craplot.qtinfoln + 1
           craplot.vlcompdb  = craplot.vlcompdb + p-valor
           craplot.vlinfodb  = craplot.vlinfodb + p-valor.

  RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
  RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT p-cod-operador,
                                         INPUT p-valor,
                                         INPUT dec(p-nrdocto),
                                         INPUT yes, /* YES (PG), NO (REC) */
                                         INPUT "1",  
                                         INPUT NO,   /* Nao estorno        */
                                         INPUT craplcm.cdhistor, /*Historico */ 
                                         INPUT ?, /* Data off-line */
                                         INPUT 0, /* Sequencia off-line */
                                         INPUT 0, /* Hora off-line */
                                         INPUT 0, /* Seq.orig.Off-line */
                                         OUTPUT p-literal,
                                         OUTPUT p-ult-sequencia,
                                         OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    /* Atualiza sequencia Autenticacao */
    ASSIGN  craplcm.nrautdoc = p-ult-sequencia.   
   
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
   
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " "
           c-cgc-cpf1      = " "
           c-cgc-cpf2      = " ".
           
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                       crapass.nrdconta = craplcm.nrdconta 
                       NO-LOCK NO-ERROR.
         
    IF  AVAIL crapass THEN 
        DO:
            ASSIGN c-nome-titular1 = crapass.nmprimtl.

            FIND crapttl WHERE crapttl.cdcooper = crapcop.cdcooper AND
                               crapttl.nrdconta = crapass.nrdconta AND
                               crapttl.idseqttl = 2 NO-LOCK NO-ERROR.
                
            IF  crapass.inpessoa = 1 THEN
                DO:
                   ASSIGN c-cgc-cpf1 = STRING(crapass.nrcpfcgc,"99999999999")
                          c-cgc-cpf1 = STRING(c-cgc-cpf1,"999.999.999-99").
                       
                   IF AVAIL crapttl THEN
                      ASSIGN c-cgc-cpf2 = STRING(crapttl.nrcpfcgc,"99999999999")
                             c-cgc-cpf2 = STRING(c-cgc-cpf2,"999.999.999-99")
							 c-nome-titular2 = crapttl.nmextttl. 
                END.
            ELSE 
                ASSIGN c-cgc-cpf1 = STRING(crapass.nrcpfcgc,"99999999999999")
                       c-cgc-cpf1 = STRING(c-cgc-cpf1,"99.999.999/9999-99").
        END.
 
    RUN dbo/pcrap12.p (INPUT  p-valor,
                       INPUT  47,
                       INPUT  47,
                       INPUT  "M",
                       OUTPUT c-linha1,
                       OUTPUT c-linha2).

    ASSIGN c-valor =
     FILL(" ",14 - LENGTH(TRIM(STRING(p-valor,"zzz,zzz,zz9.99")))) + "*" + 
                         (TRIM(STRING(p-valor,"zzz,zzz,zz9.99"))).
  
    ASSIGN c-literal = " ".
    ASSIGN c-literal[1]  = trim(crapcop.nmrescop) + 
     " - " + TRIM(crapcop.nmextcop) 
           c-literal[2]  = " "
           c-literal[3]  = string(crapdat.dtmvtolt,"99/99/99") +
            " " + STRING(TIME,"HH:MM:SS") +  " PAC " + 
                           string(p-cod-agencia,"999") +
                            "  CAIXA: " + STRING(p-nro-caixa,"Z99") + "/" +
                           substr(p-cod-operador,1,10)  
           c-literal[4]  = " " 
           c-literal[5]  = "     ** RECIBO DE SAQUE AVULSO " +
            string(p-nrdocto,"ZZZ,ZZ9")  + " **" 
           c-literal[6]  = " " 
           c-literal[7]  = "CONTA: "    +   
           trim(string(craplcm.nrdconta,"zzzz,zzz,9"))
           c-literal[8]  = "       "    +   trim(c-nome-titular1)
           c-literal[9]  = "       "    +   trim(c-nome-titular2)
           c-literal[10] = " "
           c-literal[11] = "RECEBI(EMOS) DA " +  
           STRING(crapcop.nmrescop,"X(11)") + ", A DEBITO  DA  CONTA"
           c-literal[12] = "CORRENTE ACIMA, O VALOR DE R$    " + c-valor
           c-literal[13] = "(" + trim(c-linha1)
           c-literal[14] = trim(c-linha2) + ")"
           c-literal[15] = "AUTENTICADO ABAIXO. " 
           c-literal[16] = " "
           c-literal[17] = " "
           c-literal[18] = " "
           c-literal[19] = "ASSINATURA: _________________________________" 
           c-literal[20] = "            " + TRIM(c-nome-titular1)
           c-literal[21] = "            " + TRIM(c-cgc-cpf1) 
           c-literal[22] = "            " + TRIM(c-nome-titular2)
           c-literal[23] = "            " + TRIM(c-cgc-cpf2) 
           c-literal[24] = " "       
           c-literal[25] = p-literal
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " "
           c-literal[32] = " "
           c-literal[33] = " ".

    ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")   + 
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
                                 STRING(c-literal[33],"x(48)").

    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.
    
    ASSIGN in99 = 0. 
    DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL   crapaut   THEN  
            DO:
                
                IF LOCKED crapaut   THEN 
                    DO:
                
                            IF  in99 <  100  THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = "Tabela CRAPAUT em uso ".
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
            
                ASSIGN  crapaut.dslitera = p-literal-autentica.
                ASSIGN  crapaut.nrdconta = craplcm.nrdconta.
                RELEASE crapaut.
                LEAVE.
            END.
    END. /* fim do DO  WHILE TRUE */
    
    RELEASE craplcm.
    RELEASE craplot.

    IF crapcop.flsaqpre = FALSE THEN DO:
    
    /*VERIFICACAO TARIFAS DE SAQUE*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_verifica_tarifa_operacao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                 INPUT p-cod-operador,   /* Código do Operador */
                                 INPUT 1,                /* Codigo Agencia */
                                 INPUT 100,              /* Codigo banco caixa */
                                 INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                 INPUT "",               /* Nome da Tela */
                                 INPUT 2,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */   
                                 INPUT p-nro-conta,      /* Numero da Conta */
                                 INPUT 1,                /* Tipo de Tarifa(1-Saque,2-Consulta) */
                                 INPUT 0,                /* Tipo de TAA que foi efetuado a operacao(0-Cooperativas Filiadas,1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus) */
                                   INPUT 0,                /* Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque) */
                                  OUTPUT 0,                /* Quantidade de registros a cobrar tarifa na operação */
                                  OUTPUT 0,                /* Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta */
                                OUTPUT 0,                /* Código da crítica */
                                OUTPUT "").              /* Descrição da crítica */
    
    CLOSE STORED-PROC pc_verifica_tarifa_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_verifica_tarifa_operacao.pr_cdcritic 
                          WHEN pc_verifica_tarifa_operacao.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_tarifa_operacao.pr_dscritic
                          WHEN pc_verifica_tarifa_operacao.pr_dscritic <> ?.
    
    IF aux_cdcritic <> 0 OR (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
     DO:
         IF aux_dscritic = "" THEN
            DO:
               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                  NO-LOCK NO-ERROR.
    
               IF AVAIL crapcri THEN
                  ASSIGN aux_dscritic = crapcri.dscritic.
    
            END.
         
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT aux_cdcritic,
                        INPUT aux_dscritic,
                        INPUT YES).

         RETURN "NOK".
            
     END.                          
    /*FIM VERIFICACAO TARIFAS DE SAQUE*/
    END. 
	/* GERAÇAO DE LOG */
    IF (p-opcao = "R" )   THEN
        ASSIGN aux_cdhistor = 22
               aux_idtipcar = 0
               aux_nrcartao = 0.
    ELSE  
        ASSIGN aux_cdhistor = 1030
               aux_idtipcar = p-idtipcar
               aux_nrcartao = p-nrcartao.
               
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_gera_log_ope_cartao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                 INPUT p-nro-conta,      /* Numero da Conta */ 
                                 INPUT 1,                /* Saque */
                                 INPUT 2,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */ 
                                 INPUT aux_idtipcar, 
                                 INPUT p-nrdocto,        /* Nrd Documento */               
                                 INPUT aux_cdhistor,
                                 INPUT aux_nrcartao,
                                 INPUT p-valor,
                                 INPUT p-cod-operador,   /* Código do Operador */
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT p-cod-agencia,
                                 INPUT 0,
                                 INPUT "",
                                 INPUT 0,
                                OUTPUT "").              /* Descrição da crítica */

    /* Código da crítica */    
    CLOSE STORED-PROC pc_gera_log_ope_cartao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""           
           aux_dscritic = pc_gera_log_ope_cartao.pr_dscritic
                          WHEN pc_gera_log_ope_cartao.pr_dscritic <> ?.
                          
    IF (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
      DO:                 
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT aux_cdcritic,
                        INPUT aux_dscritic,
                        INPUT YES).

         RETURN "NOK".            
      END.     

    RETURN "OK".
END PROCEDURE.

/* b1crap54.p */

/* .......................................................................... */
