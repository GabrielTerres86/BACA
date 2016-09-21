/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps214.p                | pc_crps214                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps214.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97                           Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Emitir relatorio referente aos convenios de debito em conta.
               Emite relatorio 153.

   Alteracoes: 10/12/97 - Alterado para emitir 3 vias (Deborah).

               09/01/98 - Acerto no acesso a tabela de tarifa (Deborah).

               12/03/98 - Alterado para listar o PAC (Deborah).
               
               24/05/1999 - Criada tabela de tarifas generica para nao
                            calcular mais com 0 (Deborah).
                            
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).
                
               14/10/2004 - Imprimir somente uma via do relatorio (Ze).
               
               11/11/2004 - Enviar e-mail, se existir o e-mail, com o relatorio
                            gerado em anexo (Evandro).

               30/06/2005 - Alimentado campo cdcooper da tabela crapctc (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder     
                       
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               12/04/2007 - Retirar rotina de email em comentario (David).
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               28/08/2008 - Erro de array no lookup. Espaco em branco (Magui).
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               13/10/2008 - Erro de array no lookup. Espaco em branco (Magui).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               16/01/2014 - Inclusao de VALIDATE crapctc (Carlos)
               
               20/06/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure Oracle convertida (Marcos - SUPERO)

............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps214"
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

RUN STORED-PROCEDURE pc_crps214 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps214 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps214.pr_cdcritic WHEN pc_crps214.pr_cdcritic <> ?
       glb_dscritic = pc_crps214.pr_dscritic WHEN pc_crps214.pr_dscritic <> ?
       glb_stprogra = IF pc_crps214.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps214.pr_infimsol = 1 THEN TRUE ELSE FALSE.

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
