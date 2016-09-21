/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/saldo_utiliza.p          | GENE0005.pc_saldo_utiliza         |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/






/*******************************************************************************
   Magui = compoe o valor utilizado: 
           - saldo devedor dos emprestimos ate o dia
           - cheques do desconto de cheques que ainda nao foram compensados
           - limite de cheque especial do cooperado, total contratado
           - limite do cartao de credito contratado NAO SERA CONSIDERADO
           - estouro da conta
           - titulos do desconto de titulos ainda em aberto
             
   OBS: Em caso de alteracao, efetuar tambem na procedure "saldo_utiliza" na 
        BO sistema/generico/procedures/b1wgen9999.p.
*******************************************************************************/
/* .............................................................................

   Programa: Fontes/saldo_utiliza.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Julho/2004.                         Ultima atualizacao: 11/06/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Calcular o valor utilizado (credito) do Associado

   Alteracoes: 30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               03/07/2006 - Ajustes para melhorar performance (Edson).

               14/10/2008 - Incluir saldo devedor do desconto de titulos
                            (Gabriel).

               08/08/2012 - Comentado o codigo que considera o limite do cartao 
                            de credito para composicao do saldo utilizado - 
                            Rosangela

               11/06/2013 - Rating BNDES (Guilherme/Supero)
............................................................................. */

{ includes/var_online.i }

DEF INPUT  PARAM par_nrdconta     AS INT                             NO-UNDO.
DEF INPUT  PARAM par_dsctrliq     AS CHAR                            NO-UNDO.
DEF OUTPUT PARAM par_vlutiliz     AS DEC                             NO-UNDO.

DEF VAR aux_vlsdeved_epr          AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_dschq        AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_dstit        AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_conta        AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_cartao       AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_limite       AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved_limite_conta AS DEC                             NO-UNDO.
DEF VAR aux_vlsdeved              AS DEC                             NO-UNDO.
DEF VAR aux_despreza              AS LOG                             NO-UNDO.
DEF VAR aux_contaliq              AS INT                             NO-UNDO.
DEF VAR aux_contador              AS INT                             NO-UNDO.
DEF VAR aux_qtprecal_retorno      LIKE crapepr.qtprecal              NO-UNDO.

DEF BUFFER crabass FOR crapass.

DEF TEMP-TABLE w_contas                                              NO-UNDO
    FIELD  nrdconta  LIKE crapass.nrdconta
    FIELD  vllimcre  LIKE crapass.vllimcre.
   
ASSIGN  par_vlutiliz = 0.             

FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                   crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

EMPTY TEMP-TABLE w_contas.
   
FOR EACH crabass WHERE crabass.cdcooper = glb_cdcooper      AND
                       crabass.nrcpfcgc = crapass.nrcpfcgc  AND
                       crabass.dtelimin = ? NO-LOCK
                       USE-INDEX crapass5:

     CREATE w_contas.
     ASSIGN w_contas.nrdconta = crabass.nrdconta
            w_contas.vllimcre = crabass.vllimcre.

END.           
                   
IF   par_dsctrliq <> "Sem liquidacoes" THEN
     ASSIGN  aux_contaliq = NUM-ENTRIES(par_dsctrliq).
ELSE
     ASSIGN aux_contaliq = 0.

ASSIGN aux_vlsdeved_epr    = 0
       aux_vlsdeved_cartao = 0
       aux_vlsdeved_dschq  = 0
       aux_vlsdeved_limite = 0
       aux_vlsdeved_conta  = 0
       aux_vlsdeved_limite_conta = 0
       aux_vlsdeved        = 0.

FOR EACH w_contas NO-LOCK:

    FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper       AND
                           crapepr.nrdconta = w_contas.nrdconta  AND 
                           crapepr.inliquid = 0                  NO-LOCK:
             
        ASSIGN aux_despreza = NO.
      
        DO aux_contador = 1 TO aux_contaliq:

           IF   crapepr.nrctremp = INT(ENTRY(aux_contador,par_dsctrliq)) THEN
                DO:
                    ASSIGN aux_despreza = YES.
                    LEAVE.
                END.
    
        END.  /*  Fim do DO .. TO  */
               
        IF   aux_despreza = YES   THEN
             NEXT.
                                                                  
        ASSIGN aux_vlsdeved = 0.
    
        RUN fontes/saldo_epr.p (INPUT  crapepr.nrdconta,
                                INPUT  crapepr.nrctremp,
                                OUTPUT aux_vlsdeved,
                                OUTPUT aux_qtprecal_retorno).
          
        IF   glb_cdcritic > 0   THEN
             ASSIGN aux_vlsdeved = 0.
                  
        IF   aux_vlsdeved < 0 THEN
             ASSIGN  aux_vlsdeved = 0.
                   
        ASSIGN aux_vlsdeved_epr = aux_vlsdeved_epr + aux_vlsdeved.  
    
    END.  /*  Fim do FOR EACH crapepr  */
    

    /* BNDES - Emprestimos Ativos */
    FOR EACH crapebn WHERE crapebn.cdcooper = glb_cdcooper      AND
                           crapebn.nrdconta = w_contas.nrdconta AND 
                          (crapebn.insitctr = "N" OR
                           crapebn.insitctr = "A") NO-LOCK:

        ASSIGN aux_vlsdeved_epr = aux_vlsdeved_epr + crapebn.vlsdeved.

    END.

    /* Nao pode ser utilizado o limite do cartao para compor endividamento
       Esta norma esta descrita na politica de credito
    
    FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper       AND
                           crawcrd.nrdconta = w_contas.nrdconta  AND        
                           crawcrd.insitcrd = 4                  NO-LOCK:
                              
        FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper       AND
                           craptlc.cdadmcrd = crawcrd.cdadmcrd   AND
                           craptlc.tpcartao = crawcrd.tpcartao   AND
                           craptlc.cdlimcrd = crawcrd.cdlimcrd   AND
                           craptlc.dddebito = 0           
                           NO-LOCK NO-ERROR.
                             
        IF   AVAIL craptlc THEN
             ASSIGN aux_vlsdeved_cartao = aux_vlsdeved_cartao +
                                                       craptlc.vllimcrd.

    END.  /*  Fim do DO FOR EACH crawcrd  */ */
   
    
    aux_vlsdeved = 0.

    FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                           crapcdb.nrdconta = w_contas.nrdconta   AND
                           crapcdb.insitchq = 2                  AND
                           crapcdb.dtlibera > glb_dtmvtolt       NO-LOCK:
    
         aux_vlsdeved = aux_vlsdeved + crapcdb.vlcheque.
        
    END.  /*  Fim do FOR EACH crapcdb  */
           
    aux_vlsdeved_dschq = aux_vlsdeved_dschq + aux_vlsdeved.

    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper       AND
                       crapsld.nrdconta = w_contas.nrdconta  NO-LOCK.
 
    ASSIGN aux_vlsdeved_limite = aux_vlsdeved_limite + w_contas.vllimcre

           aux_vlsdeved_limite_conta = w_contas.vllimcre
                 
           aux_vlsdeved = crapsld.vlsddisp.
                
    IF   aux_vlsdeved > 0 THEN
         ASSIGN aux_vlsdeved = 0.

    IF   aux_vlsdeved < 0 THEN
         DO:
             ASSIGN aux_vlsdeved = aux_vlsdeved * -1.
                                     
             IF   aux_vlsdeved  > aux_vlsdeved_limite_conta THEN
                  DO:
                      ASSIGN aux_vlsdeved = aux_vlsdeved -
                                                 aux_vlsdeved_limite_conta.
                  END.
             ELSE
                  ASSIGN aux_vlsdeved = 0.
         END. 
                 
    ASSIGN aux_vlsdeved_conta = aux_vlsdeved_conta + aux_vlsdeved
           aux_vlsdeved       = 0. 

    FOR EACH craptdb WHERE (craptdb.cdcooper = glb_cdcooper        AND
                            craptdb.nrdconta = w_contas.nrdconta   AND
                            craptdb.insittit =  4)   OR
                            craptdb.cdcooper = glb_cdcooper        AND
                            craptdb.nrdconta = w_contas.nrdconta   AND
                            craptdb.insittit = 2                   AND
                            craptdb.dtdpagto = glb_dtmvtolt        NO-LOCK:
          
        aux_vlsdeved = aux_vlsdeved + craptdb.vltitulo.                     
                                                        
    END. /* Fim desconto de titulos */
    
    aux_vlsdeved_dstit = aux_vlsdeved_dstit + aux_vlsdeved.
   
END.   /*  Fim do FOR EACH w_contas  */

ASSIGN par_vlutiliz = aux_vlsdeved_epr    +
                      aux_vlsdeved_dschq  +
                      aux_vlsdeved_limite +
                      aux_vlsdeved_cartao +
                      aux_vlsdeved_conta  +
                      aux_vlsdeved_dstit.       
                      
/* .......................................................................... */
