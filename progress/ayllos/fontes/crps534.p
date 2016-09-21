/* ..........................................................................

   Programa: Fontes/crps534.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Dezembro/2009.                  Ultima atualizacao: 13/11/2013 
   Dados referentes ao programa:                                               

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos de DOC's/Depositos - Sua Remessa.
               Emite relatorio 527.

   Alteracoes: 31/05/2010 - Permitir que o programa rode diferenciadamente para
                            coop 3, lendo todos os arquivos 3*.RET, importar os
                            dados e gerar um relatorio. Quando for outra coop,
                            continuar o funcionamento atual (Guilherme/Supero)

               10/06/2010 - Exibir as informacoes dos DOCs Integrados (Ze).
               
               16/06/2010 - Acertos Gerais (Ze).
                           
               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)
               
               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv 
                            (Vitor)

               13/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                            (Guilherme/Supero)
                            
               10/01/2011 - Alteracao do total do rel. 526_99 (Ze).   
               
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).
                            
               24/02/2011 - Alterado layout do reatorio crrl563 (Henrique).
                           
               07/04/2011 - Quando tipo de doc 2 e campo 105,2 igual a 50
                            criticar o cpf/cnpj (Magui).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)
                            
               19/10/2011 - Corrigir FORMAT para campo nrdocmto (David).
               
               21/12/2011 - Corrigido warnings (Tiago).     
               
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               04/07/2012 - Retirado email fabiano@viacredi.com.br do 
                            recebimento do relatório (Guilherme Maba).
               
               24/10/2012 - Layout do relatorio de rejeitados campo conta de
                            8 para 13 posições - rel 527 (Tiago/ZE).
                            
               03/01/2013 - Adaptacao da Migracao AltoVale (Ze).             
               
               18/02/2013 - Zerar variavel glb_cdcritic - Trf. 44680 (Ze).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               10/09/2013 - Incluida critica 64(conta encerrada) (Diego).
               
               23/10/2013 - Correcao critica 64-tratar conta migrada (Diego).
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps534"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps534 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                   
    INPUT glb_nmtelant,                              
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

CLOSE STORED-PROCEDURE pc_crps534 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps534.pr_cdcritic WHEN pc_crps534.pr_cdcritic <> ?
       glb_dscritic = pc_crps534.pr_dscritic WHEN pc_crps534.pr_dscritic <> ?
       glb_stprogra = IF pc_crps534.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps534.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


