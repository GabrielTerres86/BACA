/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps652.p                | pc_crps652                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ............................................................................

   Programa: Fontes/crps652.p
   Sistema : CYBER - GERACAO DE ARQUIVO
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : AGOSTO/2013                      Ultima atualizacao: 29/05/2014
   
   Dados referentes ao programa:

   Frequencia: Diaria.
   Objetivo  : Gerar diariamente para o sistema CYBER os layouts de entrada
               (Carga, Carga Manutencao Cadastral, Carga Manutencao Financeira,
               Carga Relations, Carga Garantias, Carga Pagamentos, Carga 
               Baixas) e controlar as baixas e pagamentos para os contratos 
               que estão na cobrança do sistema CYBER.
               
   Alteracoes: 26/09/2013 - Ajuste para gerar pagamento e baixa para os
                            registros que nao fizeram atualizacao financeira
                            no crps280.i "Foram liquidados". (James)
                            
               09/10/2013 - Ajuste para atualizar o campo crapcyb.cdagenci de 
                            acordo com a agencia do cooperado (James).
                            
               28/10/2013 - Ajuste para atualizar o Saldo Devedor e Valor a 
                            Regularizar para a origem conta, quando for
                            baixado (James).
                            
               04/11/2013 - Ajuste para enviar o endereco do "Interveniente 
                            Garantidor" quando for conta (James).
                            
               13/11/2013 - Ajuste para buscar o tipo do documento e numero
                            do documento quando nao possuir na tabela crapass.
                            (James).
                            
               20/11/2013 - Ajuste no tipo de garantia (Oscar).             
               
               21/11/2013 - Ajuste no envio do valor do pagamento. (James)
               
               12/12/2013 - Ajuste para enviar primeiro o Nome do Pai e depois
                            o Nome da Mae no layout "_rel_in.txt". (James)
                            
               21/01/2014 - Ajuste para atualizar agencia. (James)
               
               24/01/2014 - Ajuste para atualizar o Valor a Regularizar quando
                            for baixado. (James)
                            
               13/02/2014 - Comentado o DELETE da tabela crapcyb. (James).
               
               07/03/2014 - Ajuste para liberar o CYBER para mais 7 
                            cooperativas (James).
                            
               11/03/2014 - Ajuste no envio da carga de garantia, para somente
                            enviar os bens, caso possui alguma informacao 
                            cadastrada. (James)
                            
               01/04/2014 - Ajuste para liberar o CYBER para todas as 
                            cooperativas. (James)
                            
               14/05/2014 - Paralelo temporário Oracle está com rollback e gerando
                            em diretório diferente (Oscar).
                            
               29/05/2014 - Liberacao da versao Oracle (Oscar).             
 .......................................................................... */

{includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps652"
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

RUN STORED-PROCEDURE pc_crps652 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT glb_nmtelant,                                                 
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

CLOSE STORED-PROCEDURE pc_crps652 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps652.pr_cdcritic WHEN pc_crps652.pr_cdcritic <> ?
       glb_dscritic = pc_crps652.pr_dscritic WHEN pc_crps652.pr_dscritic <> ?
       glb_stprogra = IF pc_crps652.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps652.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
