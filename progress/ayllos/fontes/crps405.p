/* ............................................................................

   Programa: fontes/crps405.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2004                       Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorio 368 - Relacao Rating a serem atualizados.
               (Apos atualizacao Rating Central de Risco )
               Sol.4 / Ordem 27 /Cadeia 1 / Exclusividade = 2
   Alteracoes: 

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).
               25/08/2005 - Alterada verificacao atualizacao(Mirtes)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               08/12/2005 - Nao listar se cooperado nao possuer
                            saldo operacoes de credito(Mirtes)
                            
               06/02/2006 - Escrever "VENCIDO" quando o rating nao foi
                            atualizado no mes e envio por e-mail (Evandro).
                            
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
               
               10/03/2006 - Imprimir o CPF/CNPJ (Edson).

               05/07/2006 - Ajustes para melhorar a performance (Edson).
               
               26/01/2007 - Alterado formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).    

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).
                            
               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).
               
               15/10/2009 - Ler a crapnrc ao inves da crapras. 
                            Retirar campos da crapass relacionados ao Rating
                            (Gabriel).
                            
               11/08/2011 - Parametro dtrefere na obtem_risco - GE (Guilherme).
               
               10/01/2012 - Melhoria de desempenho (Gabriel)
               
               25/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)

............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps405"
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps405 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps405 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps405.pr_cdcritic WHEN pc_crps405.pr_cdcritic <> ?
       glb_dscritic = pc_crps405.pr_dscritic WHEN pc_crps405.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps405.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps405.pr_infimsol = 1 THEN
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

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS405.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  
RUN fontes/fimprg.p.

/* .......................................................................... */