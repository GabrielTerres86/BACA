
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps464.p                | pc_crps464                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* .............................................................................

   Programa: Fontes/crps464.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Fevereiro/2006                    Ultima atualizacao: 24/06/2014
      
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Gerar arquivos de retorno para os bloquetos pagos no caixa.
               Atende a solicitacao 82.
               Ordem 33.  
   
   Alteracoes: 10/04/2006 - Incluir geracao de arquivo Pre-Impresso (Ze).
   
               08/08/2006 - Retirado informacao fixa "0014",
                            Acerto no crapass.inarqcbr e Convenio com 7 digitos
                            crapceb (Julio/Ze).

               23/08/2006 - Nao gerar arquivo para PRE-IMPRESSOS que sejam 
                            tipo FEBRABAN (Julio/Ze).     
               
               31/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               03/10/2006 - Gerar arquivos diferentes para conta e convenios
                            (Julio)

               12/04/2007 - Retirar rotina de email em comentario (David).
               
               21/08/2007 - Alterado para valor de tarifa pegar informacoes da
                            crapcco.vlrtarcx quando bloqueto for pago no caixa
                            ou crapcco.vlrtarnt quando bloqueto for pago via
                            internet (Elton).
               
               02/04/2008 - Conversao do programa para BO b1wgen0010. 
                            Efetuado chamada do mesmo pelo programa.
                            (Sidnei - Precise)
                          - Utilizar includes para temp-tables (David).
                          - Incluido novo parametro, referente ao numero de
                            convenio, na procedure gera_retorno_arq_cobranca da
                            BO b1wgen0010 (Elton). 
               
               22/07/2010 - Incluida chamada da procedure 
                            gera_retorno_arq_cobranca_viacredi se cooperativa
                            for viacredi (Elton).              
                            
               20/09/2010 - Incluir CREDCREA na geracao do arq. retorno do
                            CoopCob (Ze).
                            
               13/10/2010 - Alteracao no parametro gera_retorno_arq_cobranca
                            (Ze).
                            
               24/06/2014 - Conversao Progres -> Oracle, adaptaçao fonte hibrido
                            para chamar rotina oracle (Odirlei-AMcom).
                                         
............................................................................. */

DEF STREAM str_1.   /*  Para arquivo de trabalho */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_batch.i {1} }

ASSIGN glb_cdprogra = "crps464"
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

RUN STORED-PROCEDURE pc_crps464 aux_handproc = PROC-HANDLE NO-ERROR
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps464 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps464.pr_cdcritic WHEN pc_crps464.pr_cdcritic <> ?
       glb_dscritic = pc_crps464.pr_dscritic WHEN pc_crps464.pr_dscritic <> ?
       glb_stprogra = IF pc_crps464.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps464.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

/*.......................................................................... */
