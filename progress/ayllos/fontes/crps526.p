/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  | CRPS526.p                       | PC_CRPS526.prc                        | 
  +---------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ............................................................................

   Programa: Fontes/crps526.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando
   Data    : ABRIL/2009                     Ultima atualizacao: 11/07/2014
   
   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Cadastramento da taxa CDI para o dia.
   
   
   Alteracoes: 15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                            
               17/11/2011 - Inclusão das chamadas "cadastra_taxa_cdi_mensal" e
                            "cadastra_taxa_cdi_acumulado" para calcular de
                            forma automática a Taxa de CDI (Isara - RKAM)

               30/03/2012 - Incluir parametro (dtmvtopr) na BO 128 (Ze).
               
               03/06/2014 - Incluir o VALIDATE e substituir glb_cdcooper por
                            crapcop.cdcooper (Ze/Rodrigo).
                            
               11/07/2014 - Conversão Progress >> Oracle PLSQL (Jean Michel)
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps526"
       glb_cdcritic = 0
       glb_dscritic = "".

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE PC_CRPS526 aux_handproc = PROC-HANDLE (INPUT 3, /*Cooperativa*/
                                                            INPUT 0, /*Restart*/
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

CLOSE STORED-PROCEDURE PC_CRPS526 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = PC_CRPS526.pr_cdcritic WHEN PC_CRPS526.pr_cdcritic <> ?
       glb_dscritic = PC_CRPS526.pr_dscritic WHEN PC_CRPS526.pr_dscritic <> ?
       glb_stprogra = IF PC_CRPS526.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF PC_CRPS526.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
