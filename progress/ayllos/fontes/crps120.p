/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps120.p                | pc_crps120                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/* ..........................................................................

   Programa: Fontes/crps120.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                           Ultima atualizacao: 01/09/2008
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 062.
               Processar as integracoes de credito de pagamento e efetuar os
               debitos de cotas e emprestimos.
               Emite relatorio 98, 99 e 114.

   Alteracoes: 17/11/95 - Alterado para tratar debito do convenio de DENTISTAS
                          para a CEVAL JARAGUA DO SUL (Edson).

               18/11/96 - Alterado para marcar o indicador de integracao de
                          folha de pagto com feito (Edson).

               12/02/97 - Tratar CPMF (Odair).

               21/02/97 - Tratar convenio saude Bradesco (Odair).

               21/05/97 - Alterado para tratar demais convenios (Edson).

               05/06/97 - Criar tabela para descontar emprestimos e capital apos
                          a ultima folha da empresa (Odair).

               25/06/97 - Alterado para eliminar a leitura da tabela de histori-
                          cos de dentistas (Deborah).

               10/07/97 - Tratar historicos de saude bradesco cnv 14 (Odair)

               13/11/97 - Tratar convenio 18 e 19 (Odair).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               22/11/98 - Tratar atendimento noturno (Deborah).
               
               26/02/99 - Tratar arquivos nao encontrados (Odair) 

             23/03/2003 - Incluir tratamento da Concredi (Margarete).

             29/06/2005 - Alimentado campo cdcooper da tabela craptab (Diego).
             
             16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

             05/06/2006 - Criar crapfol zerado para quem tem aviso de debito de 
                          emprestimo mas nao teve credito da folha (Julio)

             30/08/2006 - Somente criar crapfol se for integracao de credito 
                          de salario mensal (Julio)

             20/12/2007 - Remover arquivo de folha para o salvar apenas apos 
                          a solicitacao passar para status "processada" (Julio)
                          
             01/09/2008 - Alteracao CDEMPRES (Kbase).
             
             01/10/2013 - Renomeado "aux_nmarqimp" (EXTENT) para "aux_nmarquiv", 
                          pois aux_nmarqimp eh usado na impressao.i (Carlos)
                          
             25/10/2013 - Copia relatorio para o diretorio rlnsv (Carlos)
             
             29/10/2013 - Incluida var aux_flarqden para saber se copia o 
                          rel crrl114 para o dir rlnsv na sol062.p (Carlos)
             
             08/10/2015 - Migração do conteúdo em progress do fonte crps120.p para 
                          integra_folha.p. O fonte crps120.p ficou apenas para 
                          chamar a rotina em ORACLE.
............................................................................. */
{ includes/var_batch.i {1} }   
{ sistema/generico/includes/var_oracle.i }

{ includes/var_crps120.i "new" }

ASSIGN glb_cdprogra = "crps120"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
            
IF  glb_cdcritic > 0 THEN DO:
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps120 aux_handproc = PROC-HANDLE
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
                     " - " + glb_cdprogra + "' --> '"  +
                     "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
   RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps120 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps120.pr_cdcritic WHEN pc_crps120.pr_cdcritic <> ?
       glb_dscritic = pc_crps120.pr_dscritic WHEN pc_crps120.pr_dscritic <> ?
       glb_stprogra = IF pc_crps120.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps120.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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







/*
{ includes/var_batch.i {1} }   
{ sistema/generico/includes/var_oracle.i }

{ includes/var_crps120.i "new" }

ASSIGN glb_cdprogra = "crps120"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
            
IF  glb_cdcritic > 0 THEN DO:
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps120 aux_handproc = PROC-HANDLE
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
                     " - " + glb_cdprogra + "' --> '"  +
                     "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
   RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps120 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps120.pr_cdcritic WHEN pc_crps120.pr_cdcritic <> ?
       glb_dscritic = pc_crps120.pr_dscritic WHEN pc_crps120.pr_dscritic <> ?
       glb_stprogra = IF pc_crps120.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps120.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

*/