/* ..........................................................................

   Programa: Fontes/crps001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                    Ultima atualizacao: 06/06/2013
   
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
               Calcula o saldo diario e apura os saldos medios.

   Alteracoes: 10/10/94 - Alterado para registrar as devolucoes de cheques
                          no crapneg (Edson).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo que
                          o 47 (Deborah).

               03/11/94 - Alterado para incluir nrdctabb, nrdocmto, qtdiaest e
                          vllimcre e alterar vlestmfx para vlestour na gravacao
                          do arquivo crapneg. Eliminada a rotina de acesso a ta-
                          bela de moedas fixas. (Deborah).

               08/11/94 - Alterado para gravar codigos anteriores e atuais no
                          crapneg. (Deborah).

               09/11/94 - Alterado para gerar registros de credito em liquida-
                          cao no crapneg - hist. 4 (Odair).

               10/11/94 - Alterado para modificar os calculos de saldos medios
                          (Deborah).

               16/12/94 - Alterado para nao calcular IPMF depois de 31/12/94
                          (Deborah).

               14/01/97 - Alterado para tratar CPMF apos 23/01/97 (Deborah).

               21/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               07/07/97 - Tratar extrato quinzenal (Odair).

               16/02/98 - Alterar a data final do CPMF (Odair)

               22/04/98 - Tratamento para milenio e troca para V8 (Magui).

               26/06/98 - Alterado para NAO tratar historico 289 na leitura
                          do craplcm e a criacao do historico 289 quando
                          houver cobranca de CPMF sobre cobertura de saldo
                          devedor (Edson).

               29/07/98 - Alterado para nao compensar a CPMF em periodos 
                          anteriores (Edson).

               10/08/98 - Comentar datas de cheque < 01/23/98 (Odair)
               
               16/12/98 - Tratar historico 47 para digitacao fora compe
                          para tratamento para contabilidade (Odair).
               
               22/01/99 - Calcular a base de calculo do IOF (Deborah).

               12/03/99 - Nova forma de calculo da base do IOF a partir de
                          15/03/1999 e cobranca no primeiro dia util (Deborah)

               07/06/1999 - Tratar CPMF (Deborah).
                 
               23/06/1999 - Tratar historico 340 como 47 (Odair).  

               05/10/2001 - Inclui atualizacao qtddusol (Magui).

               19/04/2002 - Nao cobrar CPMF do historico 43 (Deborah).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera       
                            armazenado na variavel aux_lsconta3 (Julio).
                            Alterado a quinzena do dia 15/08/03 para o dia
                            14/08/03 em virtude de manutencao (Deborah)

               06/08/2003 - Tratamento historico 156 (Julio).

               11/08/2003 - Mudar calculo do utilizado.
                            O bloqueio de emprestimo passou a ser considerado
                            bloqueado (Deborah).

               15/10/2003 - Tratamento para calculo do VAR (Magui).

               03/05/2004 - Atual.Data/Dias Credito Liquidacao Risco(Mirtes).
               
               08/03/2005 - Alimentar a tabela "crapsda" (Evandro).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, crapneg, craplot, crapvar e crapsda 
                            (Diego).

               09/12/2005 - Cheque salario nao existe mais (Magui).

               19/12/2005 - Atualizar o valor do cheque e da cpmf no crapfdc
                            (Edson).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
                            
               14/08/2006 - Alimentar o campo crapsda.dtdsdclq a partir do
                            crapsld (Edson).
                            
               12/02/2007 - Efetuada alteracao para nova estrutura crapneg
                            (Diego).
                            
               07/03/2007 - Ajustes para o Bancoob (Magui).
               
               20/04/2007 - Substituir craptab "LIMCHEQESP" pelo craplrt (Ze).

               15/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).
               
               09/09/2009 - Acerto de leitura sem cdcooper (Diego).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               10/01/2011 - Para as ctas TCO criar o crapneg na coop 2 para os
                            historicos de devolucao (Ze).
                            
               02/02/2011 - Melhoria na criacao do crapneg para ctas cadastra-
                            das no TCO (Ze).
                
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................. */
/****** Decisoes sobre o VAR ***********************************************
disponivel = dispon + chsl + bloq + blfp + blpr = a vista
adiantamento = alem do limite = a vista
contrato de limite de credito = nao lanca
utilizado = vencimento do contrato de limite sem juros
***************************************************************************/

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps001"
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

RUN STORED-PROCEDURE pc_crps001 NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps001.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps001.pr_cdcritic WHEN pc_crps001.pr_cdcritic <> ?
       glb_dscritic = pc_crps001.pr_dscritic WHEN pc_crps001.pr_dscritic <> ?
       glb_stprogra = IF pc_crps001.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps001.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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