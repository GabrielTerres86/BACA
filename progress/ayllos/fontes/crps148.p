/* ..........................................................................

   Programa: Fontes/crps148.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                      Ultima atualizacao: 03/01/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 5 (Finalizacao do processo).
               Calcula as aplicacoes RPP aniversariantes.
               Nao gera relatorio.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes)
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               04/06/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)
                            
               23/08/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)

			   03/01/2018 - Inclusão de novos parametros na chamado da 
			                da procedure pc_crps148 - Projeto Ligeirinho -
							(Jonatas Jaqmam - AMcom)
                            
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps148"
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

RUN STORED-PROCEDURE pc_crps148 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper, 
    INPUT 0,
	INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps148 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps148.pr_cdcritic WHEN pc_crps148.pr_cdcritic <> ?
       glb_dscritic = pc_crps148.pr_dscritic WHEN pc_crps148.pr_dscritic <> ?
       glb_stprogra = IF pc_crps148.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps148.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
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