/* .............................................................................

   Programa: Fontes/crps341.p                               
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson        
   Data    : Abril/2003                      Ultima atualizacao: 03/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.
               Efetuar os lancamentos automaticos no sistema de cheques
               descontados.                    
               Emite relatorio 287.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 08/10/2003 - Atualiza craplcm.dtrefere (Margarete). 

               06/12/2003 - Alterado para tratar cheque em custodia que foi 
                            descontado (Edson).
                            
               22/12/2003 - Alterado para tratar borderos NAO liberados
                            (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).
                            
               18/11/2005 - Acertar leitura do crapfdc (Magui).       
                     
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).      
               
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               07/03/2007 - Ajustes para o Bancoob (Magui).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               05/08/2009 - Criar craprej com dados fixos do lote pois na
                            primeira leitura ele nao tem o lote lido(Guilherme).
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               02/01/2013 - Tratamento para os cheques das contas migradas
                            (Viacredi -> Alto Vale), realizado na procedure 
                            proc_trata_desconto. (Fabricio)
                            
             03/06/2013 - Incluido no FOR EACH craplau a condicao -
                          craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)                            
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps341"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps341 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
    OUTPUT 0,          
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps341 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps341.pr_cdcritic WHEN pc_crps341.pr_cdcritic <> ?
       glb_dscritic = pc_crps341.pr_dscritic WHEN pc_crps341.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps341.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps341.pr_infimsol = 1 THEN 
                          TRUE 
                      ELSE 
                          FALSE. 

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

