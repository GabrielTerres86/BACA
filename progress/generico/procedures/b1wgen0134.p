
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------------+-------------------------------------------+
  | Rotina Progress                       | Rotina Oracle PLSQL                       |
  +---------------------------------------+-------------------------------------------+
  | b1wgen0134.p (Variaveis)                 | EMPR0004                               |
  | valida_empr_tipo1                        | EMPR0004.pc_valida_empr_tipo1          |
  +------------------------------------------+----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: b1wgen0134.p                  
   Autor   : Tiago.
   Data    : 28/02/2012                        Ultima atualizacao: 05/11/2014
    
   Dados referentes ao programa:

   Objetivo  : BO - PROPOSTA DE EMPRESTIMO/EXTRATO EMPRESTIMO/SALDO EMPRESTIMO

   Alteracoes:  01/03/2012 - Incluidas Procedures para criar e deletar 
                             Lancamentos de Emprestimo (Gabriel).
                             
                04/05/2012 - Passar como parametro para a criacao de lancamentos
                             da craplem valores do lote (Gabriel)            
                             
                04/11/2013 - Ajuste na procedure cria_lancamento_lem para
                             inclusao do parametro cdpactra (Adriano).
                             
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                10/06/2014 - Incluir parametro "par_nrseqava" na procedure 
                             "cria_lancamento_lem" (James)
                             
                05/11/2015 - Incluso parametro "par_cdorigem" na procedure
                            "cria_lancamento_lem" (Daniel) 

..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0134tt.i }


PROCEDURE valida_historico:
    
    DEF INPUT PARAM par_cdhistor    AS INT              NO-UNDO.
    
    DEF VAR aux_flghistr            AS LOGICAL          NO-UNDO.
    DEF VAR aux_contador            AS INT              NO-UNDO.
    
    /**********FIM DAS DEFINICOES*******************************/
    
    ASSIGN aux_flghistr = FALSE.
    
    DO aux_contador = 1 TO EXTENT(aux_histcred):
    
        IF  aux_histcred[aux_contador] = par_cdhistor THEN
            DO:
                ASSIGN aux_flghistr = TRUE.
                LEAVE.
            END.
    END.
    
    IF  NOT aux_flghistr THEN
        RETURN "NOK".
    
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_empr_tipo1:
    
    DEF INPUT  PARAM par_cdcooper    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrctremp    AS INT              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_cdcritic            AS INT              NO-UNDO.
    DEF VAR aux_dscritic            AS CHAR             NO-UNDO.
    

    FIND FIRST crawepr NO-LOCK WHERE crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp AND 
                                     crawepr.tpemprst = 1 NO-ERROR.
    IF  NOT AVAIL crawepr THEN
        DO:             
            ASSIGN aux_cdcritic = 946. 
   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_lote_emprst_tipo1:

    DEF INPUT  PARAM par_cdcooper    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta    AS INT              NO-UNDO.
    DEF INPUT  PARAM par_nrdolote    AS INT              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_cdcritic             AS INT              NO-UNDO.
    DEF VAR aux_dscritic             AS CHAR             NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_nrdolote <= 600000  OR 
        par_nrdolote >= 650000  THEN
        DO:
            ASSIGN aux_cdcritic = 261
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
        

    RETURN "OK".
END.

PROCEDURE cria_lancamento_lem:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cdpactra AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_dtpagemp AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_txjurepr AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlpreemp AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrsequni AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrparepr AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgincre AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flgcredi AS LOGI                            NO-UNDO. 
    DEF INPUT PARAM par_nrseqava AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                            NO-UNDO.

    DEF VAR aux_cdcritic         AS INTE                            NO-UNDO.
    DEF VAR aux_nrseqdig         AS INTE                            NO-UNDO.
    
    DEF VAR h-b1craplot          AS HANDLE                          NO-UNDO.


    RUN cria_lancamento_lem_chave( INPUT par_cdcooper, 
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci, 
                                   INPUT par_cdbccxlt, 
                                   INPUT par_cdoperad, 
                                   INPUT par_cdpactra, 
                                   INPUT par_tplotmov, 
                                   INPUT par_nrdolote, 
                                   INPUT par_nrdconta, 
                                   INPUT par_cdhistor, 
                                   INPUT par_nrctremp, 
                                   INPUT par_vllanmto, 
                                   INPUT par_dtpagemp, 
                                   INPUT par_txjurepr, 
                                   INPUT par_vlpreemp, 
                                   INPUT par_nrsequni, 
                                   INPUT par_nrparepr, 
                                   INPUT par_flgincre, 
                                   INPUT par_flgcredi, 
                                   INPUT par_nrseqava, 
                                   INPUT par_cdorigem, 
                                  OUTPUT aux_nrseqdig).
        
    RETURN "OK".

END PROCEDURE.

PROCEDURE cria_lancamento_lem_chave:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cdpactra AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_tplotmov AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_dtpagemp AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_txjurepr AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlpreemp AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrsequni AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrparepr AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_flgincre AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flgcredi AS LOGI                            NO-UNDO. 
    DEF INPUT PARAM par_nrseqava AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.

    DEF VAR aux_cdcritic         AS INTE                            NO-UNDO.
    DEF VAR aux_nrseqdig         AS INTE                            NO-UNDO.
    
    DEF VAR h-b1craplot          AS HANDLE                          NO-UNDO.


    DO TRANSACTION ON ERROR UNDO , RETURN "NOK":
    
       IF ROUND(par_vllanmto,2) > 0 THEN
          DO:
              /* Atualiza lote */
              RUN sistema/generico/procedures/b1craplot.p PERSISTENT SET h-b1craplot.
              
              RUN inclui-altera-lote IN h-b1craplot (INPUT par_cdcooper,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_cdpactra,
                                                     INPUT par_cdbccxlt,
                                                     INPUT par_nrdolote,
                                                     INPUT par_tplotmov, 
                                                     INPUT par_cdoperad,
                                                     INPUT par_cdhistor,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_vllanmto,
                                                     INPUT par_flgincre,
                                                     INPUT par_flgcredi,
                                                    OUTPUT aux_nrseqdig,
                                                    OUTPUT aux_cdcritic).
             
              DELETE PROCEDURE h-b1craplot.
         
              CREATE craplem.
              ASSIGN craplem.dtmvtolt = par_dtmvtolt
                     craplem.cdagenci = par_cdpactra
                     craplem.cdbccxlt = par_cdbccxlt
                     craplem.nrdolote = par_nrdolote
                     craplem.nrdconta = par_nrdconta
                     craplem.nrdocmto = aux_nrseqdig 
                     craplem.cdhistor = par_cdhistor
                     craplem.nrseqdig = aux_nrseqdig 
                     craplem.nrctremp = par_nrctremp
                     craplem.vllanmto = par_vllanmto
                     craplem.dtpagemp = par_dtpagemp
                     craplem.txjurepr = par_txjurepr
                     craplem.vlpreemp = par_vlpreemp
                     craplem.nrsequni = par_nrsequni 
                     craplem.cdcooper = par_cdcooper
                     craplem.nrparepr = par_nrparepr
                     craplem.nrseqava = par_nrseqava
                     craplem.cdorigem = par_cdorigem.
              VALIDATE craplem.
          END.
    END.

    ASSIGN par_nrseqdig = aux_nrseqdig.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE desfaz_lancamentos_lem:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                            NO-UNDO.

    DEF VAR aux_contador         AS INTE                            NO-UNDO.

    DEF BUFFER crablem FOR craplem.

    /* Para todos os lancamentos da conta e contrato */
    FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper   AND
                           craplem.nrdconta = par_nrdconta   AND
                           craplem.nrctremp = par_nrctremp   NO-LOCK:

        DO aux_contador = 1 TO 10:

            FIND crablem WHERE crablem.cdcooper = craplem.cdcooper   AND
                               crablem.dtmvtolt = craplem.dtmvtolt   AND
                               crablem.cdagenci = craplem.cdagenci   AND
                               crablem.cdbccxlt = craplem.cdbccxlt   AND
                               crablem.nrdolote = craplem.nrdolote   AND
                               crablem.nrdconta = craplem.nrdconta   AND
                               crablem.nrdocmto = craplem.nrdocmto   
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crablem   THEN
                 IF   LOCKED crablem   THEN
                      DO:
                          ASSIGN par_cdcritic = 77.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.

            ASSIGN par_cdcritic = 0.
            LEAVE.

        END.

        DELETE crablem.

    END.

    IF   par_cdcritic <> 0   THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */

