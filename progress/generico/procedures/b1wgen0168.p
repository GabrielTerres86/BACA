/**********************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL                |
  +------------------------------------------+------------------------------------+
  | sistema/generico/procedures/b1wgen0168.p |                                    |
  | atualiza_dados_financeiro                | CYBE0001.atualiza_dados_financeiro |
  | atualiza_desconto                        | CYBE0001.pc_atualiza_desconto      |
  | atualiza_emprestimo                      | CYBE0001.pc_atualiza_emprestimo    |
  | atualiza_conta                           | CYBE0001.pc_atualiza_conta         |
  | busca_descricao_critica                  | gene0001.fn_busca_critic           |
  +------------------------------------------+------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

**********************************************************************************/







/*.............................................................................
    
  Programa: b1wgen0168.p
  Autor(a): James Prust Junior
  Data    : 14/08/2013                         Ultima atualizacao: 22/11/2017

  Dados referentes ao programa:

  Objetivo  : BO referente a regras de geracao de arquivos CYBER 

  Alteracoes: 26/09/2013 - Atualizar o campo dtatufin da tabela crapcyb.(James)
  
              11/11/2013 - Ajuste na procedure 
                           "atualiza_data_manutencao_cadastro" para melhorar 
                           a performance. (James)
                           
              14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                           vip no cyber (James).
                           
              12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
              
              27/12/2013 - Ajuste na procedure "atualiza_dados_financeiro"
                           para atualizar a data de pagamento (James)
                           
              11/02/2014 - Ajuste na procedure "atualiza_dados_financeiro"
                           para criar registro no CYBER (James).
              
                         - Removido as procedures "atualiza_emprestimo",
                           "atualiza_conta", "atualiza_desconto" e
                           "atualiza_dados_gerais". (James)
                           
              06/03/2014 - Ajuste para somente atualizar caso nao tiver 
                           baixado (James)

			  22/11/2017 - Inclusao de informacoes na geracao do log codigo 77
						   data proc. atualiza_data_manutencao_cadastro. 
						   (SD 773399) - Carlos Rafael Tanholi.	

			  24/04/2019 - Ajuste na procedure atualiza_data_manutencao_cadastro 
			               para considerar o CDORIGEM 5. (Anderson - Supero)

.............................................................................*/
{ sistema/generico/includes/b1wgen0168tt.i }

PROCEDURE atualiza_dados_financeiro:

    DEF INPUT PARAM TABLE FOR tt-crapcyb.

    DEF OUTPUT PARAM par_cdcritic AS INTE INIT 0                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FOR EACH tt-crapcyb NO-LOCK:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapcyb WHERE crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                               crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                               crapcyb.cdorigem = tt-crapcyb.cdorigem AND
                               crapcyb.nrctremp = tt-crapcyb.nrctremp
                               EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
            IF NOT AVAIL crapcyb THEN
               DO:
                   IF LOCKED crapcyb THEN
                      DO:
                          IF aux_contador = 10 THEN
                             DO:
                                 ASSIGN par_cdcritic = 77.
                                 LEAVE Contador.
                             END.
                          ELSE
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT Contador.
                             END.
                      END.
                   ELSE 
                      DO:
                          IF tt-crapcyb.vlpreapg > 0 THEN
                             DO:
                                 CREATE crapcyb.
                                 BUFFER-COPY tt-crapcyb TO crapcyb. 
                                 ASSIGN crapcyb.dtatufin = tt-crapcyb.dtmvtolt.
                                 VALIDATE crapcyb.

                             END. /* END IF tt-crapcyb.vlpreapg > 0 */

                          LEAVE Contador.
                      END.
               END.
            ELSE 
               DO:
                   /* Caso jah estiver baixado, vamos reativar */ 
                   IF crapcyb.dtdbaixa <> ? AND tt-crapcyb.vlpreapg > 0 THEN
                      DO:
                          ASSIGN crapcyb.dtdbaixa = ?
                                 crapcyb.dtmancad = tt-crapcyb.dtmvtolt
                                 crapcyb.dtmanavl = tt-crapcyb.dtmvtolt
                                 crapcyb.dtmangar = tt-crapcyb.dtmvtolt
                                 crapcyb.dtdpagto = tt-crapcyb.dtdpagto.
                      END.

                   IF crapcyb.dtdbaixa = ? THEN
                      DO:
                          ASSIGN crapcyb.vlsdevan = crapcyb.vlsdeved
                                 crapcyb.vlsdeved = tt-crapcyb.vlsdeved
                                 crapcyb.vljura60 = tt-crapcyb.vljura60
                                 crapcyb.vlpreemp = tt-crapcyb.vlpreemp
                                 crapcyb.qtpreatr = tt-crapcyb.qtpreatr
                                 crapcyb.vlprapga = crapcyb.vlpreapg
                                 crapcyb.vlpreapg = tt-crapcyb.vlpreapg
                                 crapcyb.vldespes = tt-crapcyb.vldespes
                                 crapcyb.vlperris = tt-crapcyb.vlperris
                                 crapcyb.nivrisat = tt-crapcyb.nivrisat
                                 crapcyb.nivrisan = tt-crapcyb.nivrisan
                                 crapcyb.dtdrisan = tt-crapcyb.dtdrisan
                                 crapcyb.qtdiaris = tt-crapcyb.qtdiaris
                                 crapcyb.qtdiaatr = tt-crapcyb.qtdiaatr
                                 crapcyb.flgrpeco = tt-crapcyb.flgrpeco
                                 crapcyb.qtprepag = tt-crapcyb.qtprepag
                                 crapcyb.txmensal = tt-crapcyb.txmensal
                                 crapcyb.txdiaria = tt-crapcyb.txdiaria
                                 crapcyb.vlprepag = tt-crapcyb.vlprepag
                                 crapcyb.qtmesdec = tt-crapcyb.qtmesdec
                                 crapcyb.flgresid = tt-crapcyb.flgresid.
                   
                          IF crapcyb.dtmvtolt = tt-crapcyb.dtmvtolt AND 
                             tt-crapcyb.vlpreapg = 0                THEN
                             ASSIGN crapcyb.dtatufin = ?.
                          ELSE 
                             ASSIGN crapcyb.dtatufin = tt-crapcyb.dtmvtolt.
        
                          /* Desconto e Emprestimo */
                          IF CAN-DO("2,3",STRING(crapcyb.cdorigem)) THEN
                             ASSIGN crapcyb.dtdpagto = tt-crapcyb.dtdpagto.

                      END. /* IF crapcyb.dtdbaixa = ? THEN */

                   LEAVE Contador.

               END. /* END ELSE */

        END. /* Contador */

        IF par_cdcritic > 0 THEN
           RETURN "NOK".

    END. /* FOR EACH tt-crapcyb */

    RETURN "OK".

END.

PROCEDURE atualiza_data_manutencao_cadastro:
    
    DEF INPUT PARAM TABLE FOR tt-crapcyb.
                        
    DEF OUTPUT PARAM par_cdcritic AS INTE INIT 0                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF BUFFER bcrapcyb FOR crapcyb.
                        
    FOR EACH tt-crapcyb NO-LOCK:
                        
        FOR EACH crapcyb WHERE ((crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                                 crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                                 crapcyb.cdorigem = 1 )                 OR
                                (crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                                 crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                                 crapcyb.cdorigem = 2 )                 OR
                                (crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                                 crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                                 crapcyb.cdorigem = 3 )                 OR
                                (crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                                 crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                                 crapcyb.cdorigem = 4)                  OR
								(crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                                 crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                                 crapcyb.cdorigem = 5))
                               NO-LOCK:

            Contador: DO aux_contador = 1 TO 10:

                FIND bcrapcyb WHERE bcrapcyb.cdcooper = crapcyb.cdcooper AND
                                    bcrapcyb.cdorigem = crapcyb.cdorigem AND
                                    bcrapcyb.nrdconta = crapcyb.nrdconta AND
                                    bcrapcyb.nrctremp = crapcyb.nrctremp
                                    EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                IF NOT AVAIL bcrapcyb THEN
                   DO:
                       IF LOCKED bcrapcyb THEN
                          DO:
                              IF aux_contador = 10 THEN
                                 DO:
                                     ASSIGN par_cdcritic = 77
									        par_dscritic = "(CRAPCYB - BO168)".
                                     LEAVE Contador.
                                 END.
                              ELSE
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT Contador.
                                 END.
                          END.
                       ELSE /* Nao achou nenhum registro */
                          LEAVE Contador.
                   END.
                ELSE
                   DO:
                       ASSIGN bcrapcyb.dtmancad = tt-crapcyb.dtmancad.
                       LEAVE Contador.
                   END.

            END. /* Contador */

            IF par_cdcritic > 0 THEN
               RETURN "NOK".

        END. /* FOR EACH crapcyb */
    
    END. /* FOR EACH tt-crapcyb */
    
    RETURN "OK".

END.

PROCEDURE atualiza_data_manutencao_avalista:
    
    DEF INPUT PARAM TABLE FOR tt-crapcyb.
                        
    DEF OUTPUT PARAM par_cdcritic AS INTE INIT 0                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FOR EACH tt-crapcyb NO-LOCK:

        Contador: DO aux_contador = 1 TO 10:
                                
           FIND crapcyb WHERE crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                              crapcyb.cdorigem = tt-crapcyb.cdorigem AND
                              crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                              crapcyb.nrctremp = tt-crapcyb.nrctremp
                              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

           IF NOT AVAIL crapcyb THEN
              DO:
                  IF LOCKED crapcyb THEN
                     DO:
                         IF aux_contador = 10 THEN
                            DO:
                                ASSIGN par_cdcritic = 77.
                                LEAVE Contador.
                            END.
                         ELSE
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                     END.
                  ELSE
                     LEAVE Contador.
              END.
           ELSE
              DO:
                  ASSIGN crapcyb.dtmanavl = tt-crapcyb.dtmanavl.
                  LEAVE Contador.
              END.
              
        END. /* Contador */

        IF par_cdcritic > 0 THEN
           RETURN "NOK".

    END. /* FOR EACH tt-crapcyb */

    RETURN "OK".
END.

PROCEDURE atualiza_data_manutencao_garantia:
    
    DEF INPUT  PARAM TABLE FOR tt-crapcyb.

    DEF OUTPUT PARAM par_cdcritic AS INTE INIT 0                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    FOR EACH tt-crapcyb NO-LOCK:

        Contador: DO aux_contador = 1 TO 10:
                                
           FIND crapcyb WHERE crapcyb.cdcooper = tt-crapcyb.cdcooper AND
                              crapcyb.cdorigem = tt-crapcyb.cdorigem AND
                              crapcyb.nrdconta = tt-crapcyb.nrdconta AND
                              crapcyb.nrctremp = tt-crapcyb.nrctremp
                              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

           IF NOT AVAIL crapcyb THEN
              DO:
                  IF LOCKED crapcyb THEN
                     DO:
                         IF aux_contador = 10 THEN
                            DO:
                                ASSIGN par_cdcritic = 77.
                                LEAVE Contador.
                            END.
                         ELSE
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                     END.
                  ELSE
                     LEAVE Contador.
              END.
           ELSE
              DO:
                  ASSIGN crapcyb.dtmangar = tt-crapcyb.dtmangar.
                  LEAVE Contador.
              END.
              
        END. /* Contador */

        IF par_cdcritic > 0 THEN
           RETURN "NOK".

    END. /* FOR EACH tt-crapcyb */

    RETURN "OK".

END.

PROCEDURE busca_descricao_critica:
    
    DEF INPUT  PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    FIND crapcri WHERE crapcri.cdcritic = par_cdcritic
                       NO-LOCK NO-ERROR.
    IF AVAILABLE crapcri THEN
       ASSIGN par_dscritic = crapcri.dscritic.
    
    RETURN "OK".
END.
