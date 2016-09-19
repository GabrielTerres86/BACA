/*.............................................................................

   Programa: Fontes/crps445_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Julho/2011.                     Ultima atualizacao: 04/08/2014
   
   Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                 paralelo. Fonte original crps445.p.

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar planilha Operacoes de Credito -  Utilizado no CORVU
               Solicitacao 2 - Ordem 37.

   Alteracoes: 10/08/2011 - Retirado LOG de inicio de execucao, ficou no
                            programa principal (Evandro).
                            
               10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                            controle de restart (David).
               
               04/08/2014 - Alteração da Nomeclatura para PA (Vanessa).                          
............................................................................. */

/******************************************************************************
    Para restart eh necessario eliminar as tabelas crapscd e crapsdv e 
    rodar novamente
******************************************************************************/

{ includes/var_batch.i "NEW" } 

/* Calcula aplicacoes RDCA30 e RDCA60 por PA */

/* Variaveis para controle da execucao em paralelo */
DEF VAR aux_idparale        AS INT                                  NO-UNDO.
DEF VAR aux_idprogra        AS INT                                  NO-UNDO.
DEF VAR aux_cdagenci        AS INT                                  NO-UNDO.
DEF VAR h_paralelo          AS HANDLE                               NO-UNDO.

DEF VAR aux_tot_vlavaliz    AS DEC                                  NO-UNDO.
DEF VAR aux_tot_vlavlatr    AS DEC                                  NO-UNDO.
DEF BUFFER b_crapsda FOR crapsda.


/* recebe os parametros de sessao (criterio de separacao */
ASSIGN glb_cdprogra = "crps445"
       glb_flgresta = FALSE  /* Sem controle de restart */
       aux_idparale = INT(ENTRY(1,SESSION:PARAMETER))
       aux_idprogra = INT(ENTRY(2,SESSION:PARAMETER))
       aux_cdagenci = aux_idprogra.
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.  

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.cdagenci = aux_cdagenci   NO-LOCK:

    /* Atualiza informacoes de avalistas */
    FOR EACH crapsda WHERE crapsda.cdcooper = glb_cdcooper   AND
                           crapsda.dtmvtolt = glb_dtmvtolt   AND
                           crapsda.nrdconta = crapass.nrdconta
                           USE-INDEX crapsda1 NO-LOCK:
    
        ASSIGN aux_tot_vlavaliz = 0
               aux_tot_vlavlatr = 0.
        
        /* buscar avalistas */
        FOR EACH crapavl WHERE crapavl.cdcooper = crapsda.cdcooper   AND 
                               crapavl.nrdconta = crapsda.nrdconta
                               USE-INDEX crapavl2 NO-LOCK:
        
            /* buscar saldo devedor do emprestimo avalizado */
            FOR EACH crapsdv WHERE crapsdv.cdcooper = crapsda.cdcooper   AND 
                                   crapsdv.nrdconta = crapavl.nrctaavd   AND 
                                   crapsdv.dtmvtolt = crapsda.dtmvtolt   AND 
                                   crapsdv.nrctrato = crapavl.nrctravd   NO-LOCK:
                  
                ASSIGN aux_tot_vlavaliz = aux_tot_vlavaliz + crapsdv.vldsaldo.
                
                /* buscar dados do emprestimos */ 
                FOR EACH crapepr WHERE crapepr.cdcooper = crapsdv.cdcooper   AND 
                                       crapepr.nrdconta = crapsdv.nrdconta   AND 
                                       crapepr.nrctremp = crapsdv.nrctrato   NO-LOCK:
    
                    /* desconsiderar contratos em prejuizo */
                    IF  crapepr.inprejuz = 1  THEN
                        NEXT.
                    
                    /* verificar se emprestimo esta atrasado */
                    IF  (crapepr.qtmesdec - crapepr.qtprecal) <= 1  THEN
                        NEXT.
    
                    /* desconsiderar se pagto vai ocorrer no mes */
                    IF  (MONTH(glb_dtmvtolt) = MONTH(crapepr.dtdpagto))  THEN
                        NEXT.
        
                    ASSIGN aux_tot_vlavlatr = aux_tot_vlavlatr + 
                           TRUNC(crapepr.vlpreemp * 
                                 (crapepr.qtmesdec - crapepr.qtprecal), 2).
                    
                END.   
            END.
        END.
        
        /* atualizar tabela SDA */
        IF (aux_tot_vlavlatr <> 0) OR
           (aux_tot_vlavaliz <> 0) THEN 
           DO  TRANSACTION ON ERROR UNDO, RETURN:
               FIND FIRST b_crapsda WHERE b_crapsda.cdcooper = crapsda.cdcooper   AND 
                                          b_crapsda.nrdconta = crapsda.nrdconta   AND 
                                          b_crapsda.dtmvtolt = crapsda.dtmvtolt
                                          EXCLUSIVE-LOCK NO-ERROR.
               
               ASSIGN crapsda.vlavlatr = aux_tot_vlavlatr
                      crapsda.vlavaliz = aux_tot_vlavaliz.
           END.

    END. /* Fim do EACH crapsda */

END. /* Fim do EACH crapass */



RUN sistema/generico/procedures/bo_paralelo.p PERSISTENT SET h_paralelo.
    
RUN finaliza_paralelo IN h_paralelo (INPUT aux_idparale,
                                     INPUT aux_idprogra).
    
DELETE PROCEDURE h_paralelo.


UNIX SILENT VALUE("echo " + 
                  STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' -->    '" +
                  "Fim da Execucao Paralela - Programa 2 - PA: " +
                  STRING(aux_cdagenci,"zz9") +
                  " >> log/crps445.log").

QUIT.

/* .......................................................................... */

