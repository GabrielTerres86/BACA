/* ..........................................................................
            
   Programa: Fontes/crps474.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Fevereiro/2012.                    Ultima atualizacao: 14/01/2015
             
   Dados referentes ao programa:

   Frequencia: Diaria
   Objetivo  : Pagamento de parcelas dos emprestimos.

   Alteracoes: 05/02/2013 - Tratar transacao por parcela (Gabriel).
   
               25/02/2013 - Mandar numero do contrato para a procedure
                            de validacao de pagamento (Gabriel). 
                            
               27/02/2013 - Atribuir valor da referencia dos juros somente
                            quando o mesmo vier com valor positivo (Gabriel).
                            
               17/04/2013 - Ajuste para pagamento parcial em dia (Gabriel).
               
               22/08/2013 - Incluido a chamada da procedure "atualiza_desconto"
                            "atualiza_emprestimo" para os contratos que 
                            nao ocorreram debito (James).
                            
               09/10/2013 - Atribuido valor 0 no campo crapcyb.cdagenci 
                            (James)
               
               01/11/2013 - Ajustes realizados: 
                            - Atender ao comunicado 08/2011;
                            - Inclusao do parametro cdpactra na chamada das
                              procedures lanca_juro_contrato, 
                              efetiva_pagamento_normal_parcela,
                              efetiva_pagamento_atrasado_parcela;
                            (Adriano).
               
               14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                            vip no cyber (James).
                            
               27/11/2013 - Enviado cdpactra/cdagenci = 1 nas procedures:
                             - lanca_juro_contrato, 
                             - efetiva_pagamento_normal_parcela,
                             - efetiva_pagamento_atrasado_parcela
                            (Adriano).
               
               14/01/2015 - Implementação lógica para processamento on-line e diário. 
                            229243 (Jean -RKAM)
                            
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps474"
       glb_flgbatch = false
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
/*
    Incluídos os parâmetros pr_cdagenci e pr_idparale na chamada do pc_crps474 (229243)
*/
RUN STORED-PROCEDURE pc_crps474 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT 0,
    INPUT glb_nmdatela,
    INPUT ?,
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

CLOSE STORED-PROCEDURE pc_crps474 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps474.pr_cdcritic WHEN pc_crps474.pr_cdcritic <> ?
       glb_dscritic = pc_crps474.pr_dscritic WHEN pc_crps474.pr_dscritic <> ?
       glb_stprogra = IF pc_crps474.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps474.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

       
