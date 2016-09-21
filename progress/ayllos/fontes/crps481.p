/*.............................................................................

   Programa: fontes/crps481.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007                      Ultima atualizacao: 04/11/2013 
   
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 005. Ordem = 40
               Finalizar as aplicacoes RDCPRE e RDCPOS, colocando o saldo na
               conta investimento.
               Emite relatorio 456.

   Alteracoes: 05/10/2007 - Trabalhar com 4 casas na provisao RDCPOS e
                            RDCPRE (Magui).

               05/11/2007 - Dtfimper da provisao_pre com erro (Magui).
               
               12/11/2007 - Substituir histor 477 por 490 na CI (Magui).
               
               10/12/2007 - Crapass nao cadastrado (Magui).

               11/03/2008 - Melhorar leitura do craplap para taxas (Magui).
               
               03/04/2008 - Deixar finalizar aplicacoes bloqueadas (Magui).

               11/04/2008 - Zerar vlslfmes quando insaqtot = 1 (Magui).
               
               28/04/2008 - Corrigir atualizacao do lote (Magui);
                          - Mostrar aplicacao bloqueada so 1 vez (Evandro).
                          
               03/08/2009 - Paulo - Precise. Incluir quebra por PAC, campo DIAS 
                            de aplicação entre campos "aplicacao" e "creditado"
                            geral um arquivo geral e um para cada pac.
              
               06/08/2009 - Utilizar o numero da aplicacao finalizada como o
                            numero do documento ao gerar os lancamentos na conta
                            investimento  - craplci.nrdocmto = craprda.nraplica
                            (Fernando).

               11/11/2009 - Alterado o FIND da CRAPAGE para que utilizasse o
                            campo cdcooper. (Guilherme/Precise).
                            
               04/03/2010 - Alterado formato do campo "CREDITADO" para valores 
                            negativos (Gabriel).              

               25/08/2011 - Nao zerar vlslfmes quando ultimo dia do mes.
                            Campos sera zerado no crps249 (Magui).
                            
               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).   
                            
               12/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
                         
               03/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).       
                            
               04/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            
..............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps481"
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

RUN STORED-PROCEDURE pc_crps481 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps481 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps481.pr_cdcritic WHEN pc_crps481.pr_cdcritic <> ?
       glb_dscritic = pc_crps481.pr_dscritic WHEN pc_crps481.pr_dscritic <> ?
       glb_stprogra = IF pc_crps481.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps481.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


