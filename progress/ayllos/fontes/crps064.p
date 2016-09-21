/* ..........................................................................

   Programa: Fontes/crps064.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 035.
               Encerramento do periodo de apuracao do IPMF.

   Alteracoes: 14/01/97 - Alterado para tratar CPMF (Deborah).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               29/07/98 - Tratamento da CPMF para programa que le lcm (Odair)
               
               24/08/98 - Acertar vlbascpm = 0 (Odair)

               08/09/98 - Acerto na atualizacao da base compensada no crapper
                          (Deborah).
                         
               21/08/03 - Modificar o historico de 005 para 188 (Ze Eduardo).

               28/06/2005 - Alimentado campo cdcooper das tabelas crapipm e 
                            craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               08/06/2006 - Alteracao na atualizacao do campo crapper.dtfimper
                            (Julio)
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
                            
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps064"
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

RUN STORED-PROCEDURE pc_crps064 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
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
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.
     
CLOSE STORED-PROCEDURE pc_crps064 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps064.pr_cdcritic WHEN pc_crps064.pr_cdcritic <> ?
       glb_dscritic = pc_crps064.pr_dscritic WHEN pc_crps064.pr_dscritic <> ?
       glb_stprogra = IF pc_crps064.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps064.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
                      
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

