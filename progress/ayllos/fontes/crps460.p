/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps460.p                | pc_crps460                        |
  +---------------------------------+-----------------------------------+


  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.


  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* .............................................................................

   Programa: Fontes/crps460.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio       
   Data    : Dezembro/2005.                  Ultima atualizacao: 30/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 082    Ordem 67.
               Gerar arquivo de pedido de cheques B. Brasil (Conta Integracao)
               para impressao na CECRED.
               Relatorios :  432, 433 e 434 (binario do cheque).

   Alteracoes: 25/01/2006 - Acerto no relatorio de criticas, estava listando
                            criticas de requisicoes anteriores.
                            O relatorio que sai as 13:30 nao estava salvando
                            no MTGED (Julio)

               09/02/2006 - Criada mensagem referente pedido taloes no
                            diretorio /micros/cecred/pedido (Diego).
                            
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               07/03/2006 - Acerto mensagem pedido taloes (Diego).

               30/03/2006 - Alterado diretorio de mensagem referente pedido
                            taloes (Diego).
                            
               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).

               19/03/2007 - Padronizacao das colunas dos relatorios (Ze).
               
               16/04/2007 - Tratar sequencia do nro pedido atraves do gnsequt
                            Sequencia unica para todas as cooperativas (Ze).

               17/08/2007 - Incluida variaveis para armazenar as datas de
                            aberturas de conta mais antigas do cooperado no SFN
                            (Elton).

               07/11/2007 - Nao imprimir relatorios zerados (Julio).

               15/08/2008 - Aceitar qualquer compe (Magui).

               15/09/2008 - Acertado para gerar relatorio em PDF na Intranet
                            (Diego).

               02/12/2008 - Usar crapcop.cdageitg para banco = 1 e calcular 
                            digito da agencia (Guilherme).

               04/12/2009 - Imprimir 1 via do crrl433 com duas capas(Guilherme)

               30/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).

               17/05/2009 - Tratar os cheques IF CECRED(Guilherme).

               10/02/2011 - Utilizar campo "Nome no talao" - crapttl (Diego).

               06/10/2011 - Incluir a data de confecção no arquivo de dados
                            (Isara - RKAM).

               15/10/2012 - Incluido tratamento para nome da logo de cheque da 
                            cooperativa Viacredi Alto Vale (Diego).             

               11/04/2013 - Ajuste no arquivo de controle para o crrl433
                            (Daniele).

               13/05/2013 - Ajuste no arquivo de controle para o crrl433 (Ze).

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Andre Euzebio - Supero).

               02/01/2014 - Retirado comando unix que diz respeito a
                            "Fila de impressao" (Tiago). 

               26/05/2014 - Retirado mensagem do log, "NAO HA REQUISICOES PARA 
                            CHEQUES AVULSO E/OU TB", conforme chamado: 144959, 
                            data: 02/04/2014
                            do log: crrl999_viacredi_02042014. Jéssica (DB1).

               06/06/2014 - Alterado o caminho dos relatorios, de salvar/ para
                            rl/. Tambem criada rotina para copiar os relatorios
                            apenas no fim para o salvar/  (Guilherme/SUPERO)
                            
               17/06/2014 - Ajuste da correcao de 26/05 (Carlos)

               30/06/2014 - Ajuste para salvar o arquivo crrl434 em diretorio
                            "salvar" em vez de "rl" como os relatorios 432 e 433.
                            (Jorge/Elton) Emergencial.     
                            
               01/10/2014 - Migracao PROGRESS/ORACLE - Incluido chamada da
                            procedure convertida para oracle (Odirlei - AMcom)
                                                 
............................................................................. */

{ includes/var_batch.i {1}} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps460"
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

RUN STORED-PROCEDURE pc_crps460 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps460 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps460.pr_cdcritic WHEN pc_crps460.pr_cdcritic <> ?
       glb_dscritic = pc_crps460.pr_dscritic WHEN pc_crps460.pr_dscritic <> ?
       glb_stprogra = IF pc_crps460.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps460.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

/* ...........................................................................*/


