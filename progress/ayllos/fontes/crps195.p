/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps195.p                | pc_crps195                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* ............................................................................
   Programa: Fontes/crps195.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97.                        Ultima atualizacao: 03/06/2014

   Dados referentes ao programa:

   Frequencia: Solicitacao (Batch).
   Objetivo  : Atende a solicitacao 072.
               Gerar avisos de debito/credito referente convenios.
               Emite relatorio 152.

   Alteracoes: 01/07/97 - Criar tabela para fechamento convenio 8 (Odair)

               15/07/97 - Tratar parametro da solicitacao 1,2 (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               05/11/97 - Criar o numero do documento que vem do arquivo (Odair)

               16/12/97 - Colocar dtresumo no crapctc para arquivos zerados
                          (Odair)

               22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                          zeros (Deborah).

               24/03/98 - Cancelada a alteracao anterior (Deborah).

               27/04/98 - Melhorar restart (Odair)

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               09/04/1999 - Alterado para tirar a consistencia das
                            empresas conveniadas (Deborah).

               08/10/1999 - No convenio 8 permitir somente empresa 1 (Deborah).
               
               11/11/1999 - No convenio 8 permitir tambem empresa 99 (Deborah).
               
               15/02/2000 - Quando integrar apos o credito da folha, 
                            jogar para debito em conta (Deborah).

               24/02/2000 - Acerto na alteracao anterior (Deborah).

               29/03/2000 - Jogar os debitos para conta corrente se a folha 
                            ja tiver sido creditada (Deborah).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                            titular (Eduardo).
                            
               25/11/2003 - Nao imprimir se o convenio nao foi integrado e nao
                            nao e obrigatorio (Deborah).

               11/11/2004 - Enviar e-mail, se existir o e-mail, com o relatorio
                            gerado em anexo (Evandro).

               29/06/2005 - Alimentado campo cdcooper das tabelas craprej,
                            crapavs, crapctc e crapepc (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
                            ATENCAO: ESSA ALTERACAO NAO FOI INCLUIDA NO 
                            BACALHAU/CRPB169

               20/11/2006 - Envio de email pela BO b1wgen0011 (David).
               
               02/03/2007 - Criticar empresas que nao estiverem no crapcnv
                            (Julio)
                            
               27/03/2007 - Acerto na critica da empresa - Criticar somente a
                            for conveniado a FOLHA (Ze).

               12/04/2007 - Retirar rotina de email em comentario (David).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               19/10/2009 - Alteracao Codigo Historico (Kbase). 
               
               06/05/2011 - Melhorado mensagem da critica referente ao erro
                            182 para ser colocada no log (Adriano).
                            
               14/05/2012 - Tratado para nao parar processo quando critica 182
                            (Diego).             
                            
               16/01/2014 - Inclusao de VALIDATE craprej, crapavs, crapctc e 
                            crapepc (Carlos)
                            
               22/05/2014 - Remover o comando que despreza cod. convenios
                            superior a 48 (Ze).
               
               03/06/2014 - Ajustado tamanho do numero do documento (Elton).
               

               13/06/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Alisson - AMcom)
             
............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps195"
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

RUN STORED-PROCEDURE pc_crps195 aux_handproc = PROC-HANDLE NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps195 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps195.pr_cdcritic WHEN pc_crps195.pr_cdcritic <> ?
       glb_dscritic = pc_crps195.pr_dscritic WHEN pc_crps195.pr_dscritic <> ?
       glb_stprogra = IF pc_crps195.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps195.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
