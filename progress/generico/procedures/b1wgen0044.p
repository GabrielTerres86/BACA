/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  | procedures/b1wgen0044.p	           | CCAF0001	                         |
  |  verifica_feriado                  | CCAF0001.pc_verifica_feriado        |
  |  calcula_bloqueio_cheque           | CCAF0001.pc_calcula_bloqueio_cheque |
  |  valida_banco_agencia              | CCAF0001.pc_valida_banco_agencia    |
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/







/* ............................................................................

   Programa: generico/procedures/b1wgen0044.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2009                      Ultima atualizacao: 02/04/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : BO para controles de cheque relacionado ao CAF
               
   Alteracoes: 23/03/2010 - Corrigido tratamento para liberacao da custodia
                            (Evandro).
                            
               14/07/2010 - Adequacao a nova regra do Banco Central (Evandro).
               
               
               10/02/2012 - Criado a procedure verifica_feriado (Adriano).
                            
               05/03/2012 - Criado procedure prox_dia_util (Rafael).
               
               29/05/2012 - Corrigir verifica_feriado para tratar final de semana
                            que antecede o feriado como data boa para pagto
                            (Guilherme).
               
               12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               16/01/2014 - Alterada para critica 962 ao nao encontrar PA.
                            (Reinert)                            
             
               02/04/2014 - Tratamento para nao receber cheques de determinados 
                            Bancos (Elton).
............................................................................. */
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

PROCEDURE valida_banco_agencia:
    
    DEFINE   INPUT PARAM val_cdbanchq AS INTEGER                    NO-UNDO.
    DEFINE   INPUT PARAM val_cdagechq AS INTEGER                    NO-UNDO.
    DEFINE  OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_dscritic      AS CHARACTER                  NO-UNDO.

    DEFINE BUFFER crabagb FOR crapagb.

    EMPTY TEMP-TABLE tt-erro.

    /* Verifica o banco do cheque */
    FIND crapban WHERE crapban.cdbccxlt = val_cdbanchq NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapban    OR
         crapban.cdbccxlt = 8     OR
         crapban.cdbccxlt = 347   OR
         crapban.cdbccxlt = 353   OR
         crapban.cdbccxlt = 356   OR     /** Banco Real **/
         crapban.cdbccxlt = 409   OR
         crapban.cdbccxlt = 453   THEN   
         DO: 
             RUN gera_erro (INPUT 0,  /** Cooperativa **/
                            INPUT 0,  /** PAC         **/
                            INPUT 0,  /** Caixa       **/
                            INPUT 1,  /** Sequencia   **/
                            INPUT 57, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
         
    /* Verifica a agencia do cheque */
    FIND crapagb WHERE crapagb.cddbanco = crapban.cdbccxlt   AND
                       crapagb.cdageban = val_cdagechq
                       NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapagb   THEN
         DO:
             RUN gera_erro (INPUT 0,  /** Cooperativa **/
                            INPUT 0,  /** PAC         **/
                            INPUT 0,  /** Caixa       **/
                            INPUT 1,  /** Sequencia   **/
                            INPUT 15, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    
    /* Verifica se a agencia esta avita */
    IF   crapagb.cdsitagb <> "S"   THEN
         DO:
             /* Verifica se o banco possui alguma agencia ATIVA */
             FIND FIRST crabagb WHERE crabagb.cddbanco = crapban.cdbccxlt   AND
                                      crabagb.cdsitagb = "S"
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crabagb   THEN
                  DO:
                      aux_dscritic = "Nenhuma agencia ativa no banco.".
                      RUN gera_erro (INPUT 0, /** Cooperativa **/
                                     INPUT 0, /** PAC         **/
                                     INPUT 0, /** Caixa       **/
                                     INPUT 1, /** Sequencia   **/
                                     INPUT 0, /** Cdcritic    **/
                                     INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".
                  END.
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE calcula_bloqueio_cheque:

    /* 
       Objetivo  : Calcular a data de bloqueio de um cheque depositado.

       Observacao: 1- A liberacao do cheque para credito em conta do associado
                      acontece no proximo dia util em relacao a data que for 
                      retornada por esta procedure.

                   2- O dia 31/12 eh considerado dia util normalmente, porem
                      no sistema ele fica como feriado durante o ano e eh
                      liberado somente dia 30/12 a noite para evitar que
                      sejam lancados descontos de cheques, etc para esta
                      data durante o ano.
                      
                   3- Conforme acordado, caso a agencia do cheque esteja 
                      INATIVA, sera verificado se o BANCO possuir alguma
                      agencia ATIVA, caso isso seja verdadeiro o tratamento
                      sera como se a agencia do cheque estivesse ATIVA e
                      sera acrescentado 1 dia ao prazo de bloqueio.
					  
				   4-Verificação de agência inativa adicionar 1 dia ao prazo 
				      de bloqueio removida, de acordo com os ajustes do 'P367
					  Compe sessão única' e ocorrência RITM0014144.					  
    */


    DEFINE  INPUT PARAM par_cdcooper AS INTEGER                    NO-UNDO.
    DEFINE  INPUT PARAM par_dtrefere AS DATE                       NO-UNDO.
    DEFINE  INPUT PARAM par_cdagenci AS INTEGER                    NO-UNDO.
    DEFINE  INPUT PARAM par_cdbanchq AS INTEGER                    NO-UNDO.
    DEFINE  INPUT PARAM par_cdagechq AS INTEGER                    NO-UNDO.
    DEFINE  INPUT PARAM par_vlcheque AS DECIMAL                    NO-UNDO.
                                                                   
    DEFINE OUTPUT PARAM aux_dtblqchq AS DATE                       NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.


    DEFINE VARIABLE     aux_dscritic AS CHARACTER                  NO-UNDO.
    
    /* Valor de "corte" do cheque */
    DEFINE VARIABLE aux_vlcheque AS DECIMAL                        NO-UNDO.
    
    /* Quantidade de dias uteis de bloqueio do cheque */
    DEFINE VARIABLE aux_qtdiasut AS INTEGER                        NO-UNDO.
    /* Auxiliar para contabilizar o bloqueio */                    
    DEFINE VARIABLE tmp_qtdiasut AS INTEGER                        NO-UNDO.
    
    /* Validacao dos parametros */

    /* Verifica a cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop   THEN
         DO:
             RUN gera_erro (INPUT 0,   /** Cooperativa **/
                            INPUT 0,   /** PAC         **/
                            INPUT 0,   /** Caixa       **/
                            INPUT 1,   /** Sequencia   **/
                            INPUT 794, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    
    /* Verifica o PAC */
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                       crapage.cdagenci = par_cdagenci
                       NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage   THEN
         DO:
             RUN gera_erro (INPUT 0,   /** Cooperativa **/
                            INPUT 0,   /** PAC         **/
                            INPUT 0,   /** Caixa       **/
                            INPUT 1,   /** Sequencia   **/
                            INPUT 962, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.
    
    /* Verifica a data do sistema */
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapdat   THEN
         DO:
             RUN gera_erro (INPUT 0, /** Cooperativa **/
                            INPUT 0, /** PAC         **/
                            INPUT 0, /** Caixa       **/
                            INPUT 1, /** Sequencia   **/
                            INPUT 1, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    
    /* Verifica o valor de cheques maiores */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                       craptab.nmsistem = "CRED"              AND
                       craptab.tptabela = "USUARI"            AND
                       craptab.cdempres = 11                  AND
                       craptab.cdacesso = "MAIORESCHQ"        AND
                       craptab.tpregist = 1 
                       NO-LOCK NO-ERROR.
                             
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_vlcheque = 1.
    ELSE
         ASSIGN aux_vlcheque  = DEC(SUBSTR(craptab.dstextab,1,15)).

    
    /* Validacao do cheque */

    /* Verifica o valor do cheque */
    IF   par_vlcheque <= 0   THEN
         DO:
             RUN gera_erro (INPUT 0,   /** Cooperativa **/
                            INPUT 0,   /** PAC         **/
                            INPUT 0,   /** Caixa       **/
                            INPUT 1,   /** Sequencia   **/
                            INPUT 269, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    /* Validacao generica de Banco e Agencia */
    RUN valida_banco_agencia(INPUT  par_cdbanchq,
                             INPUT  par_cdagechq,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
    

    /* Busca o registro do banco */
    FIND crapban WHERE crapban.cdbccxlt = par_cdbanchq NO-LOCK NO-ERROR.
    
    /* Busca o registro da agencia */
    FIND crapagb WHERE crapagb.cddbanco = crapban.cdbccxlt   AND
                       crapagb.cdageban = par_cdagechq
                       NO-LOCK NO-ERROR.
    
    /* Verifica a cidade da agencia */
    FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcaf   THEN
         DO:
             aux_dscritic = "Cidade nao cadastrada.".
             RUN gera_erro (INPUT 0, /** Cooperativa **/
                            INPUT 0, /** PAC         **/
                            INPUT 0, /** Caixa       **/
                            INPUT 1, /** Sequencia   **/
                            INPUT 0, /** Cdcritic    **/
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.                       
    
    /* Calcula da quantidade de dias uteis para bloqueio */
    IF   par_vlcheque >= aux_vlcheque   THEN
         aux_qtdiasut = 1.
    ELSE
         aux_qtdiasut = 2.

    /* Quando a agencia do cheque estiver INATIVA, acrescenta 1 dia ao bloqueio
       para minimizar o risco operacional */
	/* Verificação removida de acordo com os ajustes do 
	   P367 - Compe sessão única e ocorrência RITM0014144
    IF   crapagb.cdsitagb <> "S"   THEN
         aux_qtdiasut = aux_qtdiasut + 1. */

        
    /* Calculo da data de liberacao */

    /* 1- Para pagamento no caixa, o lancamento ocorre on-line e comeca a contar os
          dias a partir do dia seguinte (dtmvtopr)
       
       2- Para a custodia, o lancamento ocorre para o dia seguinte (dtmvtopr) entao
          comeca a contar no proximo dia util depois da data informada */
    IF   par_dtrefere = crapdat.dtmvtolt   THEN
         aux_dtblqchq = crapdat.dtmvtopr.
    ELSE
         DO: 
             /* Proximo dia util em relacao a data informada */
             aux_dtblqchq = par_dtrefere + 1.
                    
             DO  WHILE TRUE:

                 IF   WEEKDAY(aux_dtblqchq) = 1   OR
                      WEEKDAY(aux_dtblqchq) = 7   THEN
                      DO:
                          aux_dtblqchq = aux_dtblqchq + 1.
                          NEXT.
                      END.
                                    
                 FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper   AND
                                    crapfer.dtferiad = aux_dtblqchq
                                    NO-LOCK NO-ERROR.
                                                            
                 IF   AVAILABLE crapfer   THEN
                      DO:
                          aux_dtblqchq = aux_dtblqchq + 1.
                          NEXT.
                      END.

                 LEAVE.
             END.
         END.
    
    ASSIGN tmp_qtdiasut = 1.
    
    DO  WHILE TRUE:
    
        /* Sabado e Domingo */
        IF   WEEKDAY(aux_dtblqchq) = 1   OR
             WEEKDAY(aux_dtblqchq) = 7   THEN
             DO:
                aux_dtblqchq = aux_dtblqchq + 1.
                NEXT.
             END.
                    
        /* Feriado Nacional */
        FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper   AND
                           crapfer.dtferiad = aux_dtblqchq
                           NO-LOCK NO-ERROR.
                                            
        IF   AVAILABLE crapfer   THEN
             DO:
                 /* Considera o dia 31/12 como dia normal conforme observacao
                    numero 2 desta procedure */
                 IF   NOT(MONTH(aux_dtblqchq) = 12    AND
                            DAY(aux_dtblqchq) = 31)   THEN
                      DO:
                          aux_dtblqchq = aux_dtblqchq + 1.
                          NEXT.
                      END.
             END.
    
        /* Feriado Municipal */
        FIND crapfsf WHERE crapfsf.cdcidade = crapcaf.cdcidade   AND
                           crapfsf.dtferiad = aux_dtblqchq
                           NO-LOCK NO-ERROR.
    
        IF   AVAILABLE crapfsf   THEN
             DO:
                aux_dtblqchq = aux_dtblqchq + 1.
                NEXT.
             END.

        /* Verifica se ja "pulou" a quantidade de dias uteis de bloqueio */
        IF   tmp_qtdiasut = aux_qtdiasut   THEN
             LEAVE.
    
        /* Contabiliza +1 dia */
        ASSIGN tmp_qtdiasut = tmp_qtdiasut + 1
               aux_dtblqchq = aux_dtblqchq + 1.
    END.  /*  Fim do DO WHILE TRUE  */

    RETURN "OK".

END PROCEDURE.



/* Procedure para verificar se a data de vencimento do titulo caiu em um 
   feriado e, se este, esta sendo pago no proximo dia util em relacao ao seu
   vencimento.  */
PROCEDURE verifica_feriado:

    DEF  INPUT PARAM par_cdcooper AS INT                        NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INT                        NO-UNDO.
    DEF  INPUT PARAM par_dtboleto AS DATE                       NO-UNDO.
                                                                    
    DEF  OUTPUT PARAM par_flgvenci AS LOG                       NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.               
                                                       
                                                       
    DEF VAR aux_dscritic AS CHAR                                NO-UNDO.
    DEF VAR aux_proxutil AS DATE                                NO-UNDO.

    ASSIGN aux_proxutil = par_dtboleto + 1
           par_flgvenci = TRUE.


    /* Verifica a cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapcop THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper, 
                          INPUT par_cdagenci,
                          INPUT 0,   
                          INPUT 1,   
                          INPUT 794, 
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

       END.
    
    /* Verifica o PAC */
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                       crapage.cdagenci = par_cdagenci
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapage THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT 0, 
                          INPUT 1, 
                          INPUT 962, 
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

       END.
    
    IF crapage.cdagenci <> 90 AND
       crapage.cdagenci <> 91 AND
       crapage.cdagepac <> 0  THEN
       DO:
          /* Verifica a data do sistema */
          FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                             NO-LOCK NO-ERROR.
          
          IF NOT AVAIL crapdat THEN
             DO:
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT 0, 
                                INPUT 1, 
                                INPUT 1, 
                                INPUT-OUTPUT aux_dscritic).
          
                 RETURN "NOK".
          
             END.
          
          
          /* Busca o registro do banco */
          FIND crapban WHERE crapban.cdbccxlt = crapcop.cdbcoctl
                             NO-LOCK NO-ERROR.
          
          /* Busca o registro da agencia */
          FIND crapagb WHERE crapagb.cddbanco = crapban.cdbccxlt AND
                             crapagb.cdageban = crapage.cdagepac
                             NO-LOCK NO-ERROR.
          
          /* Verifica a cidade da agencia */
          FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade
                             NO-LOCK NO-ERROR.
          
          IF NOT AVAIL crapcaf THEN
             DO:
                 aux_dscritic = "Cidade nao cadastrada.".

                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT 0, 
                                INPUT 1, 
                                INPUT 0, 
                                INPUT-OUTPUT aux_dscritic).
          
                 RETURN "NOK".
          
             END.                       
          
          DO WHILE TRUE:

             IF WEEKDAY(aux_proxutil) = 1 OR
                WEEKDAY(aux_proxutil) = 7 THEN
                DO:
                   aux_proxutil = aux_proxutil + 1.
                   NEXT.
             
                END.
                                
             FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                crapfer.dtferiad = aux_proxutil
                                NO-LOCK NO-ERROR.
                                                        
             IF AVAIL crapfer THEN
                DO:
                    aux_proxutil = aux_proxutil + 1.
                    NEXT.

                END.
             ELSE
                DO:
                   FIND crapfsf WHERE crapfsf.cdcidade = crapcaf.cdcidade AND
                                      crapfsf.dtferiad = aux_proxutil
                                      NO-LOCK NO-ERROR.
                
                   IF AVAIL crapfsf THEN
                      DO:
                          aux_proxutil = aux_proxutil + 1.
                          NEXT.
                
                      END.

                END.   

          
             LEAVE.

          END.


          IF par_dtmvtolt = aux_proxutil THEN
             DO:
                 IF WEEKDAY(par_dtboleto) = 1 OR
                    WEEKDAY(par_dtboleto) = 7 THEN
                    par_flgvenci = FALSE.
                 ELSE
                 DO:
                 
                 FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                    crapfer.dtferiad = par_dtboleto
                                    NO-LOCK NO-ERROR.
                                                            
                 IF AVAIL crapfer THEN
                    par_flgvenci = FALSE.  
                 ELSE
                    DO:
                       FIND crapfsf WHERE crapfsf.cdcidade = crapcaf.cdcidade AND
                                          crapfsf.dtferiad = par_dtboleto
                                          NO-LOCK NO-ERROR.
                    
                       IF AVAIL crapfsf THEN
                          par_flgvenci = FALSE.  
             
                    END.   
                 END.
             END.
          ELSE
             par_flgvenci = TRUE.

       END.

    
    RETURN "OK".


END PROCEDURE. /*  Fim da procedure verifica_feriado  */

PROCEDURE prox_dia_util :

    DEF  INPUT PARAM par_cdcooper AS INT                        NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                       NO-UNDO.
    DEF  INPUT PARAM par_cdufresd AS CHAR                       NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                       NO-UNDO.
    DEF OUTPUT PARAM par_proxutil AS DATE                       NO-UNDO.
    
    ASSIGN par_proxutil = par_dtvencto.

    /* Verifica a cidade */
    FIND crapcaf WHERE crapcaf.nmcidade = par_nmcidade AND 
                       crapcaf.cdufresd = par_cdufresd
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcaf THEN
       DO:
           RETURN "NOK".
       END.                       

    DO WHILE TRUE:

       IF WEEKDAY(par_proxutil) = 1 OR
          WEEKDAY(par_proxutil) = 7 THEN
          DO:
             par_proxutil = par_proxutil + 1.
             NEXT.

          END.

       FIND crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                          crapfer.dtferiad = par_proxutil
                          NO-LOCK NO-ERROR.

       IF AVAIL crapfer THEN
          DO:
              par_proxutil = par_proxutil + 1.
              NEXT.

          END.
       ELSE
          DO:
             FIND crapfsf WHERE crapfsf.cdcidade = crapcaf.cdcidade AND
                                crapfsf.dtferiad = par_proxutil
                                NO-LOCK NO-ERROR.

             IF AVAIL crapfsf THEN
                DO:
                    par_proxutil = par_proxutil + 1.
                    NEXT.

                END.

          END.          

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE. /* fim da procedure prox_dia_util */


/* .......................................................................... */

