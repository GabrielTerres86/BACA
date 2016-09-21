/* .............................................................................

   Programa: Fontes/crps008.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/92.                     Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch)
   Objetivo  : Atualizar mensalmente os saldos (anterior e extrato) e cobrar
               os juros sobre os saldos medios negativos. Atende a solicita-
               cao 003 (Mensal de atualizacao).

   Alteracoes: 08/08/94 - Alterado para somar na base do ipmf o valor do lanca-
                          mento para os casos onde o valor do ipmf seja zerado
                          (Edson).

               14/11/94 - Alterado para  gerar lancamento de juros de saque s/
                          bloqueado (Deborah).

               16/12/94 - Alterado para nao cobrar IPMF depois de 31/12/94
                          (Deborah).

               17/02/95 - Alterado para nao calcular juros para as contas que
                          tenham inpessoa = 3.

               10/03/95 - Alterado para utilizar a moeda fixa do proximo
                          movimento (Odair).

               14/01/97 - Alterado para tratar CPMF (Deborah).

               09/07/97 - Tratar extrato quinzenal (Odair)

               16/02/98 - Alterar a data final da CPMF (Odair)

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               27/01/99 - Alteracao para cobranca do IOF (Deborah).

               01/02/99 - Deve atualizar a base do IOF, mesmo quando o valor
                          do IOF eh zero. (Deborah).

               12/03/1999 - Alterado para calcular mas nao debitar IOF no 
                            ultimo dia do mes (Deborah).

               07/06/1999 - Tratar CPMF (Deborah).

               07/10/1999 - Aumentado o numero de casas decimais nas taxas
                            (Edson).

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner). 
               
               26/08/2003 - Mudanca no calculo do bloqueado (Deborah).

               11/02/2004 - Atualizar campo crapsld.dtrefext (Edson).

               23/06/2004 - Tratar novos campos no crapsld (Edson).

               23/09/2004 - Efetuar virada mensal cad.crapsli(Mirtes).

               10/05/2005 - Ajustar o saldo diario historico (crapsda) (Edson).
               
               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, crapipm, crapneg e crapsli (Diego).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder            

               08/06/2006 - Atualizacao no tratamento do campo crapper.dtfimper
                            , esta data pode ser um feriado ou fim de semana
                            (Julio)

               23/10/2006 - FOR EACH crapper, reparo no tratamentos do dtfimper 
                            para quando nao cair em dia util (Julio)

               12/02/2007 - Efetuada modificacao para nova estrutura crapneg
                            (Diego).
                            
               24/04/2007 - Substituir craptab "JUROSESPEC" pelo craplrt (Ze).
               
               31/10/2007 - Melhorada mensagem de taxa nao cadastrada (Magui).
               
               15/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).

               28/01/2008 - Alterar logica para cobranca de IOF (David).
               
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela craphis(Guilherme).
                            
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps008"
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

RUN STORED-PROCEDURE pc_crps008 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps008 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps008.pr_cdcritic WHEN pc_crps008.pr_cdcritic <> ?
       glb_dscritic = pc_crps008.pr_dscritic WHEN pc_crps008.pr_dscritic <> ?
       glb_stprogra = IF pc_crps008.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps008.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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
