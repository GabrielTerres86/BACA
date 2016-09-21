/* ............................................................................

   Programa: Fontes/crps569.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Irlan
   Data    : Maio/2010                    Ultima atualizacao: 13/01/2014

   Dados referentes ao programa:

   Frequencia: Mensal
   Objetivo  : Gerar arquivo(3045) de cooperados para consulta no Bacen.
               Solicitacao : 86
               Ordem do programa na solicitacao = 54
               Paralelo

                                      
   Alteracoes : 27/05/2010 - Busca das informações nas tabelas  
                             crapttl. Eliminacao de cpfs duplicados (Irlan).
                
                01/07/2010 - Gerar o cabecalho com o CNPJ da Cecred e 
                             carregar as informacoes de todas cooperativas.
                             Gerar multiplos arquivos quando qtd registro
                             maior que 50000 (Irlan).
                             
                16/07/2010 - Eliminar repetição dos CNPJs com os 8 primeiros
                             caracteres iguais (Irlan).
                                                            
                02/08/2010 - Incluir a chamada ao fimprg.p quando nao for 
                             o dia correto para geracao dos arquivos (Irlan).
                             
                28/01/2011 - Incluido o atributo AutConsCli (Adriano). 
                
                30/08/2011 - Alterado Cab. 3081 para 3045 e Conteúdo da Tag
                             <Cli> passa a estar no atributo "Cd" da Tag <Cli>
                             (Adriano).

                08/05/2012 - Incluida procedure 'envia_cpfcnpj' (Tiago).   
                
                13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)          
                02/04/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                             procedure (Andre Santos - SUPERO)

............................................................................*/

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps569"
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

RUN STORED-PROCEDURE pc_crps569 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps569 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps569.pr_cdcritic WHEN pc_crps569.pr_cdcritic <> ?
       glb_dscritic = pc_crps569.pr_dscritic WHEN pc_crps569.pr_dscritic <> ?
       glb_stprogra = IF pc_crps569.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps569.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
                  
RUN fontes/fimprg.p.

/* .......................................................................... */