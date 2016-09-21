/* ..........................................................................
                    ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps150.p                | pc_crps150                        |
  +---------------------------------+-----------------------------------+ 

   Programa: Fontes/crps150.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Odair
   Data    : Marco/96.                       Ultima atualizacao: 05/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de tarifa sobre retirada
               de talonarios.

   Alteracoes: 21/05/96 - Alterado para tratar conta conjunta (ate 2 taloes
                          gratuitos por mes) (Deborah).

               05/02/97 - Nao cobrar taloes referente conta convenio CPMF
                          (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               15/03/99 - Alterado para permitir ate 2 talonarios para as
                          contas conjuntas (Deborah).

               05/03/99 - Nao selecionar cheques de transferencia (Odair)

               01/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             24/02/2003 - Usar agencia e numero do lote para separar
                          as agencias (Margarete).

             22/10/2004 - Tratar conta de integracao (Margarete).

             29/06/2005 - Alimentado  campo cdcooper das tabelas craplot,
                          craplcm e crapavs (Diego).
                          
             16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
             
             01/09/2008 - Alteracao CDEMPRES (Kbase).

             01/10/2008 - Lote 10023 para histor 162, trfa talao (Magui).
             
             15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
             
             11/01/2013 - Tratamento para contas migradas 
                            Viacredi -> AltoVale. (Fabricio)
                            
             26/03/2013 - Ajustes referentes ao projeto tarifas fase 2
                          Grupo de cheques (Lucas R.)
                          
             11/10/2013 - Incluido parametro cdprogra nas procedures da 
                          b1wgen0153 que carregam dados de tarifas e incluído
                          tratamento pessoa jurídica (Tiago).
                          
             12/02/2014 - Retirados "Return" para nao abortar a execucao quando
                          for feita chamada a b1wgen0153 (Tiago).
                          
             05/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).              
............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps150"
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

RUN STORED-PROCEDURE pc_crps150 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps150 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps150.pr_cdcritic WHEN pc_crps150.pr_cdcritic <> ?
       glb_dscritic = pc_crps150.pr_dscritic WHEN pc_crps150.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps150.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps150.pr_infimsol = 1 THEN
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

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/*............................................................................*/
