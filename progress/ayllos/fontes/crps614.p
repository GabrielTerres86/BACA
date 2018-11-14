/*.............................................................................

    Programa: fontes/crps614.p
    Autor(a): Fabricio
    Data    : Janeiro/2012                      Ultima atualizacao: 30/04/2018
  
    Dados referentes ao programa:
  
    Frequencia: Diario (Batch).
    Objetivo  : Criar lancamento de debito na conta do cooperado, referente
                a mensalidade do cartao transportadora PAMCARD.
                
  
    Alteracoes: 03/02/2012 - Ajuste para debitar as mensalidades para quando 
                             for dia 1 - primeiro (Adriano).
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                                
                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
                
                06/04/2015 - Alterado para que as criticas 09 e 75 fossem
                             retiradas do proc_batch.log e transferidas para
                             proc_message.log acrescentando a data na frente
                             do log (SD273423 Tiago/Fabricio).
                             
               05/12/2017 - Arrumar leitura da crappam para buscarmos da forma
                            correta na condicao "OR", foi incluido parenteses 
                            (Lucas Ranghetti #804628)

               30/04/2018 - Criacao do programa hibrido. (Odirlei-AMcom)

.............................................................................*/


{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps614"
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

RUN STORED-PROCEDURE pc_crps614 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper,
    INPUT glb_cdoperad,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - "   + glb_cdprogra   + "' --> '" +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
    END.

CLOSE STORED-PROCEDURE pc_crps614 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps614.pr_cdcritic WHEN pc_crps614.pr_cdcritic <> ?
       glb_dscritic = pc_crps614.pr_dscritic WHEN pc_crps614.pr_dscritic <> ?
       glb_stprogra = IF pc_crps614.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps614.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - "   + glb_cdprogra   + "' --> '" +
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
