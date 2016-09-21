/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps418.p              | pc_crps418                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ............................................................................

   Programa: fontes/crps418.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes 
   Data    : Novembro/2004                       Ultima atualizacao: 11/06/2014
   Dados referentes ao programa:

   Frequencia: Semanal.
   Objetivo  : Gerar relatorio 378 - Restricoes Analise Borderos          
               Sol.70.                                        
   
   Alteracoes: 02/12/2004 - Alterado para imprimir 3 vias para a VIACREDI
                            (Edson).

               02/02/2005 - Alterado para imprimir frente e verso marginado
                            conforme solicitacao do Adelino (Edson).

               19/07/2005 - Aumentado campo numero cpf/cgc(Mirtes).

               02/08/2005 - Critica de CPF no SPC(Mirtes)          

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               30/05/2006 - Alterado numero de vias do relatorio crrl378 
                            para Viacredi (Elton).
                             
               26/01/2007 - Alterado formato dos campos do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).
               
               16/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).             
                            
               13/12/2013 - Alterado valor da variavel aux_linha1 de "CPF/CGC"
                            para "CPF/CNPJ" e ajustado posicionamento do form
                            f_cab. (Reinert)
                            
               11/06/2014 - Adapta��o do fonte para execu��o da procedure
                            Oracle convertida (Marcos-Supero)             
                            
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps418"
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

RUN STORED-PROCEDURE pc_crps418 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps418 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps418.pr_cdcritic WHEN pc_crps418.pr_cdcritic <> ?
       glb_dscritic = pc_crps418.pr_dscritic WHEN pc_crps418.pr_dscritic <> ?
       glb_stprogra = IF pc_crps418.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps418.pr_infimsol = 1 THEN TRUE ELSE FALSE.

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
