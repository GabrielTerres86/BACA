/* ............................................................................

   Programa: Fontes/crps375.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Dezembro/2003.                  Ultima atualizacao: 11/10/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.(Exclusivo)
               Integrar arquivos do BANCO BRASIL  de COBRANCA.
               Emite relatorio 325.

   Alteracao : 23/03/2004 - Prever Juros(Mirtes)
   
               30/03/2004 - Prever Abatimento(Mirtes)
               
               08/09/2004 - Desprezar apenas registro com problemas(Mirtes)
               
               20/12/2004 - Tratamento de Erros - Segura (Ze Eduardo).
               
               28/02/2005 - Tratamento COMPEFORA (Ze Eduardo).
               
               15/04/2005 - Tratamento para a importacao do cadastramento
                            dos bloquetos (Ze).
                            
               21/09/2005 - Tratamento na geracao do arquivo retorno (Ze).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               30/09/2005 - Acertos no programa (ZE).
               
               15/12/2005 - Tratamento COMPEFORA (Ze).
               
               20/03/2006 - Trocar consulta no craptab pelo crapcco (Julio/Ze)
               
               16/06/2006 - Acerto no arquivo de Retorno (Ze).
               
               08/08/2006 - Acerto no crapass.inarqcbr e Convenio com 7 digitos
                            crapceb (Ze).

               03/10/2006 - Separar arquivos de retorno por conta e por
                            convenio (Julio)

               09/11/2006 - Envio de email pela BO h_b1wgen0011 (David).

               05/12/2006 - Mover arquivo de anexo do e-mail para o diretorio
                            salvar (David).
                            
               22/12/2006 - Incluido no relatorio o nosso numero completo e o
                            convenio (Evandro).

               22/03/2007 - Erro nrdocmto quando taxa (Magui).

               12/04/2007 - Retirar rotina de email em comentario (David).
               
               30/07/2007 - Enviar email somente para quem estar cadastrado
                            na tela CONTAS e nao mais pelo convenio (ZE).
                            
               05/03/2008 - Nao criar arquivo de retorno para quem nao estiver
                            cadastrado na tela CONTAS (Ze).
                            
               12/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).
               
               08/10/2008 - Incluida variaveis para tratamento de desconto de
                            titulos (Elton). 
                            
               10/11/2008 - Incluir controles na selecao de arquivos para 
                            importacao (Ze).
                            
               17/03/2009 - Incluir campo banco e agencia pagto. (Ze).
               
               22/06/2009 - Incluir variavel h_b1wgen0023 (Guilherme).
               
               18/09/2009 - Ajustes gerais no programa:
                            - Alteracao do FORM totais para incluir novos 
                              campos e ajustar variaveis;
                            - Criacao de procedures para estruturacao do codigo
                            - Utilizacao da BO b1wgen0010 para geracao de 
                              arquivos de retorno no layout FEBRABAN e OUTROS;
                            - Passagem dos codigos (Procedures) para a BO
                              b1wgen0010
                             (GATI - Eder)
                            
               29/09/2009 - Tratamento para registro "Y" - Cheques (David).
               
               29/10/2009 - Alteracao do relatorio final para apresentar
                            detalhes do cheque (GATI - Eder)
                            
               17/02/2010 - Realizar inconsistencia 592 apenas para
                            convenio "IMPRESSO PELO SOFTWARE"

               16/09/2010 - Executar CoopCop mediante parametrizacao na CADCCO
                            (Guilherme/Supero)

               12/11/2010 - Alteracoes no p_gera_arquivo e crawcta
                            (Guilherme/Supero)

               14/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                            (Guilherme/Supero)
                            
               06/01/2011 - Ajuste na condicao para tarifa (David). 
               
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            Criado tratamento para atualizar os boletos da
                            Acredicoop para liquidados (Adriano).     
                            
               15/03/2011 - Nao criticar quando crapcob inexistente.
                            Lancamento unificado (Gabriel).     
                            
               29/03/2011 - Acerto na alimentacao do campo tt-regimp.nrdconta
                          - Temporariamente passar FALSE para flgcruni 
                            (Guilherme)
                            
               08/04/2011 - Substituicao dos campos inarqcbr e dsdemail da
                            crapass para a crapceb. Ativar flgcruni (Gabriel).
                            
               03/05/2011 - Criacao do crapceb quando criado o crapcob
                            (Gabriel).     
                            
               16/05/2011 - Nao sera mais enviado o relatorio 325 para o e-mail
                            fabiano@viacredi.coop.br (Adriano).   
                            
               16/05/2011 - Gravar no dsidenti da lcm a quantidade de boletos
                            (Gabriel).                                            

               02/06/2011 - Processar titulos somente da cobranca sem registro
                            (Rafael).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)
                            
               11/08/2011 - Ajuste quando o arquivo for rejeitado e
                            Caracter invalido em entrada numerica X (Ze).
                            
               16/08/2011 - Tratamento para nao integrar contas inexistentes
                            Trf. 41903 (Ze).
                            
               23/12/2012 - Tratar CEB de um cooperado que utilizou o CEB
                            errado (Credelesc) conforme Trf. 44309 (Rafael).
                            
               12/06/2012 - Ajuste no sequencial do arquivo e validar historico
                            do convenio (David Kistner)
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).             
               
               10/07/2012 - Ajuste na rotina cria-ceb-cob: criar titulo somente
                            se o cooperado possuir convenio (Rafael).
                            
               18/09/2012 - Ajuste nos titulos pagos com cheque (Rafael).
               
               19/09/2012 - Omitir critica 922 de tit pagos com cheque (Rafael).
               
               02/10/2012 - Criar relatorio 627 referente a titulos pagos
                            com cheque (Rafael).
                            
               22/11/2012 - Tratamento para titulos das contas migradas
                            (Viacredi -> Alto Vale). Alimentado tabela crapafi
                            para acerto financeiro entre as singulares,
                            por parte da Cecred. (Fabricio)
                            
               04/01/2013 - Apagar registro na cratarq quando arquivo nao 
                            for valido ou convenio nao cadastrado. (Rafael)                                                             
                            
               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago).             
                            
               24/01/2013 - Utilizar vlr da tarifa do banco ao realizar 
                            acerto financeiro de titulos migrados. (Rafael)
                            
               15/02/2013 - Tratamento para nro. CEB com cinco digitos;
                            convenio "1343313". (Fabricio)
                            
               26/02/2013 - Nao considerar insitceb na pesquisa CEB do 
                            convenio do cooperado. (Rafael)
                            
               10/06/2013 - Remover titulo do bordero de desconto em estudo
                            no processo de liquidacao de titulo. (Rafael)
                            
               24/06/2013 - Ajuste nos lanctos de Acerto Financeiro entre 
                            contas migradas BB. (Rafael)
               
               25/06/2013 - Alimentar as informacoes de valor e historico
                            de tarifas a partidar da procedure 
                            carrega_dados_tarifa_cobranca da b1wgen0153 e nao
                            mais da crapcco, nao criar mais craplot e nem 
                            craplcm e sim criar lancamento na craplat
                            atraves da b1wgen0153 (Tiago).
                            
               08/08/2013 - Alterado a procedure "efetiva_atualizacoes_compensacao"
                            incluso processo busca tarifa e historico  utilizando
                            rotina b1wgen0153. (Daniel)
                            
               25/09/2013 - Incluso novo parametro aux_cdpesqbb na chamada da procedure
                            efetua-lanc-craplat. (Daniel)  
                            
               27/09/2013 - Alterado valor recebido pelo campo crapafi.vllanmto (Daniel). 
               
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps375"
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

RUN STORED-PROCEDURE pc_crps375 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    INPUT glb_nmtelant,
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

CLOSE STORED-PROCEDURE pc_crps375 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps375.pr_cdcritic WHEN pc_crps375.pr_cdcritic <> ?
       glb_dscritic = pc_crps375.pr_dscritic WHEN pc_crps375.pr_dscritic <> ?
       glb_stprogra = IF pc_crps375.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps375.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
 
