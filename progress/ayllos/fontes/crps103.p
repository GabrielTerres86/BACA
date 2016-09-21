/* ..........................................................................

   Programa: Fontes/crps103.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/94.                    Ultima atualizacao: 26/01/2011

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular o rendimento mensal e liquido das aplicacoes RDCA e lis-
               tar o resumo mensal.
               Ordem da solicitacao: 10
               Ordem do programa na solicitacao: 3
               Relatorios 86 e 559 

   Alteracoes: 16/02/95 - Alteracoes em funcao da nova rotina de calculo
                          (Deborah).

               07/03/95 - Alterado o layout do relatorio (nome do campo) (Debo-
                          rah).

               11/10/95 - Alterado para incluir na leitura do lap o tratamento
                          para o historico 143. (Odair).

               22/11/96 - Alterado para selecionar somente registros com
                          tpaplica = 3 (Odair).

               17/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               03/03/98 - Acerto da alteracao anterior (Deborah).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/05/98 - Nao atualizar a solicitacao como processada (Odair).

               25/01/98 - Alterado para guardar no crapcot o valor de IOF
                          abonado (Deborah).

               07/01/2000 - Nao gerar relatorio (Deborah). 

               11/02/2000 - Gerar pedido de impressao (Deborah). 

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               07/01/2004 - Incluir IRRF pago durante o mes (Margarete).

               28/01/2004 - Nao atualizar campos do abono de cpmf (Margarete).
               
               19/04/2004 - Atualizar novos campos do craprda (Margarete).

               24/05/2004 - Lista total do histor 866 (Margarete).

               05/07/2004 - Quando saque na carencia atualizacao vlslfmes
                            errada (Margarete).
               
              22/09/2004 - Incluidos historicos 492/493(CI)(Mirtes)

              07/10/2004 - Quando saque total nao esta zerando saldo
                           do final do mes (Margarete).
              
              16/12/2004 - Incluidos historicos 875/877(Ajuste IR)(Mirtes)
              
              28/12/2004 - Alinhados os campos no relatorio (Evandro).

              01/09/2005 - Tratar leitura do craprda (Margarete).
              
              06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).
                           
              15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
              
              13/04/2006 - Acertar atualizacao do campo vlslfmes (Magui)
              
              26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).

              11/07/2007 - Incluido na leitura do craplap para emissao do
                           relatorio os historicos possiveis (Magui).

              03/12/2007 - Substituir chamada da include aplicacao.i pela
                           BO b1wgen0004.i. (Sidnei - Precise).

              07/05/2010 - Incluido relatorio crrl559.lst - Analitico RDCA30
                           (Elton).
                           
              26/08/2010 - Inserir na crapprb o somatorio das aplicacoes.
                           Tarefa 34646 (Henrique).
                           
              26/11/2010 - Retirar da sol 3 ordem 8 e colocar na sol 83
                           ordem 5.E na CECRED sol 83 e ordem 6 (Magui).
                           
              26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)

............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps103"
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

RUN STORED-PROCEDURE pc_crps103 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps103 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps103.pr_cdcritic WHEN pc_crps103.pr_cdcritic <> ?
       glb_dscritic = pc_crps103.pr_dscritic WHEN pc_crps103.pr_dscritic <> ?
       glb_stprogra = IF pc_crps103.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps103.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

