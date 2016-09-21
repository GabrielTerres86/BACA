/* ..........................................................................

   Programa: Fontes/crps499.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Novembro/2007                   Ultima atualizacao: 30/07/2013
                                      
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 39. Rodar no mensal.
               Estatistica lancamentos BB e Bancoob (relatorio 472).
               
   Alteracoes: 02/04/2008 - Alterado nomes dos labels (Gabriel).
   
               12/08/2008 - Unificacao dos Bancos incluido cdcooper na busca da
                            tabela crapage(Guilherme).
               27/10/2008 - Acerto informacao devolucao de cheques(BB/Bancoob)
                            Campo Sr.Devolucao(Mirtes)

               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                            (Sidnei - Precise).                           
               
               15/10/2009 - Incluido tratamento para Banco CECRED
                            crapcop.cdbcoctl (Guilherme/Supero)
               13/05/2010 - Alterar para o formato 234 col. e colocar as colunas
                            SR COBRANCA e NR COBAN ao final. Inserir as colunas
                            NR TED e SR TED, dividindo o NR DOC e SR DOC de
                            acordo com o tpdoctrf (Guilherme/Supero)
                            
               26/05/2010 - Atualizacao dos historicos CECRED (Ze).
               
               09/06/2010 - Incluido as colunas "NR TEC" e "SR TEC";
                          - Utilizado na NOSSA REMESSA a condicao de banco de 
                            envio "cdbcoenv" para listar as informacoes (Elton).
               
               18/10/2010 - Valores de Dev. invertidos (Trf. 35050) (Ze).
               
               29/11/2010 - Desconsiderar mensagens rejeitadas na contabilizacao
                            de TED/TEC(SPB) ref. NOSSA REMESSA (Diego).
                            
               21/03/2011 - Nao comparar contas ITG do crapass com do craplcm
                            quando nossa mensageria (Magui).
                            
               07/04/2011 - Melhoria na selecao de CHQ.DEV.SR e endentacao (Ze)
               
               20/04/2011 - Alterado para rodar na solicitacao 4 e somente na 
                            CECRED lendo todas as coop (Adriano).
                            
               26/07/2011 - Nas colunas SR TEC e SR TED buscar todos os 
                            lançamentos: automáticos e manuais.
                          - Incluir o histórico 548 na busca dos lançamentos.
                          - Incluir verificação do TED para o histórico 548.
                            (Isara - RKAM)
                            
               05/10/2011 - Incluir os historicos 971 e 977 (Cobranca
                            Registrada Sua Remessa) (Ze).
                            
               14/11/2011 - Ajustes no relatorio crrl472. (Rafael).
               
               16/03/2012 - Criado os forms abaixo onde os quais irao mostrar
                            os dados do bancoob.
                            - f_qtd_totais_bancoob
                            - f_qtd_geral_bancoob
                            - f_vlr_totais_bancoob
                            - f_vlr_geral_bancoob
                            (Adriano).
               
               03/07/2012 - Incluido email 'flavia@cecred.coop.br' para o envio
                            do relatorio crrl472 (Tiago).
                            
               04/02/2013 - Alterado para gerar o nome do rel.472 com cdcooper
                            ao invés do nmrescop (Lucas).
                            
               30/07/2013 - Incluido campos para GPS nos totais bancoob
                            (Douglas).
               
               08/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)             

..............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps499"
       glb_flgbatch = FALSE
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps499 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps499 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps499.pr_cdcritic WHEN pc_crps499.pr_cdcritic <> ?
       glb_dscritic = pc_crps499.pr_dscritic WHEN pc_crps499.pr_dscritic <> ?
       glb_stprogra = IF pc_crps499.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps499.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.


