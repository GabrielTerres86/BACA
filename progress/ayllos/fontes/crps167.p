/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps167.p                | pc_crps167                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/


/* ..........................................................................

   Programa: Fontes/crps167.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/96.                         Ultima atualizacao: 07/04/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 005.
               Listar a relacao de arquivos de integracao de convenios de debito
               em conta que nao estao disponiveis
               Ordem do programa na solicitacao 10.
               Emite relatrio 132.

   Alteracoes: 20/02/97 - Tratar seguro saude Bradesco (Odair).

               03/06/97 - Ler arquivos de convenios crapcnv (Odair)

               20/06/97 - Alterado para eliminar tratamento do convenio de
                          dentistas (Deborah).

               10/07/97 - Tratar convenio 14 saude bradesco (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               25/10/1999 - Alterado para rodar um dia antes do dia do pro-
                            cessamento dos convenios (Deborah).

               03/11/2000 - Eliminar a coluna Empresa e incluir o campo
                            Obrigatorio e Observacao (Eduardo).
                            
               31/05/2002 - Selecionar somente crapcnv.inobriga igual a 1 
                            (Junior).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder            
               
               04/01/2008 - Enviar crrl132 por email(Guilherme).
               
               07/04/2015 - Conversão Progress -> PL/SQL (Carlos)
............................................................................. */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps167".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps167 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
      INPUT INT(STRING(glb_flgresta,"1/0")),
      INPUT 0,
      INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps167 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps167.pr_cdcritic WHEN pc_crps167.pr_cdcritic <> ?
       glb_dscritic = pc_crps167.pr_dscritic WHEN pc_crps167.pr_dscritic <> ?
       glb_stprogra = IF pc_crps167.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps167.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

