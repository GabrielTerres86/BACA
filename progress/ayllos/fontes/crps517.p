/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps517.p                | pc_crps517                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/*..............................................................................

    Programa: Fontes/crps517.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Outubro/2008                    Ultima Atualizacao: 19/05/2014

    Dados referente ao programa:
    
    Frequencia: Diario.
    
    Objetivo  : Controlar vigencia dos contratos de limite e o debito de 
                titulos em desconto que atingiram a data de vencimento.
                
    Alteracoes: 06/01/2009 - Tratamento p/ feriados e fins de semana (Evandro).
    
                28/05/2009 - Antes de efetuar a baixa do titulo como vencido
                             verificar se o crapcob esta baixado, caso esteja
                             jogar uma critica no processo pois ocorreu problema
                             na baixa do titulo quando ele foi pago
                             (Compe ou Caixa e Internet) (Guilherme).

                02/06/2009 - Retirado a critica do log, porque foi colocado
                             tratamento de erros dentro de b2crap14(Guilherme).
                             
                10/12/2009 - Imprimir cada relatorio 497 dos PAs (Evandro).
                
                30/11/2011 - Condiçao para nao executar relatórios 497 e nao dar
                             baixa nos títulos no último dia útil do ano (Lucas).
                         
                28/06/2012 - Incluido novo parametro na busca_tarifas_dsctit.
                             (David Kruger).
                             
                15/10/2012 - Incluido coluna Tipo Cobr. no relat. 497 (Rafael).

                06/11/2012 - Incluido chamada da procedure desativa-rating
                             da BO43 (Tiago).
                             
                12/07/2013 - Alterado processo para busca valor tarifa renovacao,
                             projeto tarifas (Daniel).
                             
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               27/11/2013 - Incluido chamada do fimprg antes do return que
                            abortava o programa sendo que nao era um erro
                            (Tiago).      
                            
               28/11/2013 - Retirado return no caso de tarifa de renovacao zerada
                            (Daniel).             
                            
               23/12/2013 - Alterado totalizador de PAs de 99 para 999. 
                            (Reinert)                            
                                   
               19/05/2014 - Conversao Progress => Oracle (Andrino-RKAM).

..............................................................................*/
    
{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps517"
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

RUN STORED-PROCEDURE pc_crps517 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                 
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_cdoperad,
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
        
CLOSE STORED-PROCEDURE pc_crps517 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps517.pr_cdcritic WHEN pc_crps517.pr_cdcritic <> ?
       glb_dscritic = pc_crps517.pr_dscritic WHEN pc_crps517.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps517.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps517.pr_infimsol = 1 THEN
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

/* .......................................................................... */
