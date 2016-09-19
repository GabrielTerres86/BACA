/* ..........................................................................

   Programa: Fontes/crps153.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                       Ultima atualizacao: 27/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de extrato.

   Alteracoes: 18/07/97 - Fazer a cobranca de todos os extratos tarifados(Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               26/09/97 - Nao emitir aviso de taxa de extrato (Odair)

             02/02/2000 - Quando a conta for transferida, debitar na 
                          conta nova (Deborah).

             02/10/2001 - Incluir insitext = 5 no for each (Margarete).

             30/12/2003 - NAO ISENTAR mais as pessoas juridicas (Edson).

             29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                          craplcm e crapavs (Diego).
             
             10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

             16/01/2006 - Nao tarifar contas eliminadas(Mirtes).
             
             15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
             
             21/10/2010 - Atualizar operações no TAA para processado (Diego).
             
             17/12/2010 - Utilizar as tarifas de extrato de balcao ou TAA
                          adequadamente (Evandro).
                          
             28/03/2011 - Utilizar o nro do TAA para diferenciar extrato de
                          C/C do TAA com o de balcao (Evandro).
                          
             20/04/2012 - Criado uma validação para não duplicar tabela de 
                          lançamentos em depósito a vista (Guilherme Maba).
                        - Ajuste para controle de restart (David Kistner).
                        
             15/05/2013 - Retirado busca valor tarifa utilizando tabela craptab
                          retirado  (Daniel).   
             
             19/06/2013 - Incluida leitura da craptex para gravacao dos 
                          lancamentos na craplat atraves da b1wgen0153
                          (Tiago).

             27/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                          
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps153"
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

RUN STORED-PROCEDURE pc_crps153 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps153 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps153.pr_cdcritic WHEN pc_crps153.pr_cdcritic <> ?
       glb_dscritic = pc_crps153.pr_dscritic WHEN pc_crps153.pr_dscritic <> ?
       glb_stprogra = IF pc_crps153.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps153.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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