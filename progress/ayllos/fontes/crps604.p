/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps604.p                | pc_crps604                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps604.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Oliver
   Data    : Agosto/2011.                  Ultima atualizacao: 25/07/2016

   Dados referentes ao programa:

   Frequencia : Diario. Solicitacao 1 / Ordem 36 / Cadeia Exclusiva.
   Objetivo   : Realizar a renovacao dos seguros residenciais.
   
   Alteracoes: 08/12/2011 - Incluida validacao chave tabela crawseg (Diego).
   
               19/12/2011 - Incluido a passagem do parametro crawseg.dtnascsg
                            na procedure cria_seguro (Adriano).
   
               27/02/2013 - Incluir parametro aux_flgsegur na procedure 
                            cria_seguro (Lucas R.).
                            
               25/07/2013 - Incluido o parametro "crawseg.complend" na
                            chamada da procedure "cria_seguro()". (James)
                            
               29/04/2014 - Considerar o valor do plano no novo seguro e 
                            nao mais o valor do antigo seguro (Jonata-RKAM).
                            
               10/11/2014 - Por enquanto, foi retirado o tratamento 
                            de renovacao automatica dos seguros de vida
                            (Jonata-RKAM). 
                            
               13/02/2015 - Ajuste para incluir a renovacao automatica do 
                            seguro de vida.(James)
                            
               16/06/2015 - Incluir a renovacao do seguro de vida no Oracle.
                            (James)
							
			   23/07/2016 - Finalizacao da Conversao (Jonata-Rkam)			
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps604". 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps604 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps604 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps604.pr_cdcritic WHEN pc_crps604.pr_cdcritic <> ?
       glb_dscritic = pc_crps604.pr_dscritic WHEN pc_crps604.pr_dscritic <> ?
       glb_stprogra = IF pc_crps604.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps604.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

/*...........................................................................*/

