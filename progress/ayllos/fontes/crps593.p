/* ............................................................................

   Programa: Fontes/crps593.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Marco/2011                       Ultima atualizacao: 17/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Emitir Relacao de Cheques Nao Digitalizados de cada PAC.
               Relatorio 593.
               
   Alteracoes: 17/05/2011 - Criacao do relatorio crrl593_99. Resumo geral, em
                            quantidade de cheques, de todos os PAC's. 
                            (Fabricio)
                            
               19/05/2011 - Incorporado no crrl593_99 a relacao dos cheques que
                            devem ser liberados em até 3 (tres) dias uteis.
                            (Fabricio)
   
               18/07/2011 - Tratamento para nao listar cheques da própria 
                            cooperativa quando for Viacredi (Elton/Ze).
                            
               15/09/2011 - Somente considerar a sit. da previa como 0
                            (nao gerado) - devido a ABBC nao enviar diariamente
                            a planilha com os cheques a compensar E do Kofax
                            Server nao copiar as imagens de cust/desc no 
                            servidor de imagens (porem transmite p/ ABBC) (Ze).
                            
               18/10/2011 - Incluir a Data de Aprov. do Bordero na selecao dos
                            cheques de Desconto (Ze).
                            
               13/02/2012 - Alteracao para que todas as coops possam digitalizar
                            cheques da propria cooperativa (ZE).
                            
               20/04/2012 - Listar todos os cheques de custodia e desconto que 
                            nao estiverem em situacao de processado - 3 (Elton).
                            
               04/10/2012 - Alterado periodo de abrangencia do relatorio 593 
                            de 7 dias para 15 dias (Elton).
                            
               26/03/2013 - Alterado ordenacao no relatorio para cheques de
                            custodia (Elton).
               
               09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                          
                            
               06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
               
               17/06/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Odirlei - AMcom)
                                           
............................................................................ */

DEF STREAM str_1.

{ includes/var_online.i {1} } 

{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps593"       
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

RUN STORED-PROCEDURE pc_crps593 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT 0,
    INPUT 0,    
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

CLOSE STORED-PROCEDURE pc_crps593 WHERE PROC-HANDLE = aux_handproc.
 
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps593.pr_cdcritic WHEN pc_crps593.pr_cdcritic <> ?
       glb_dscritic = pc_crps593.pr_dscritic WHEN pc_crps593.pr_dscritic <> ?
       glb_stprogra = IF pc_crps593.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps593.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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


/* .......................................................................... */

