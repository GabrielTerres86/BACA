/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps217.p                | BTCH0002.pc_crps217               |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/




/*************************************************************************
    COMENTAR A INCLUDES envia_dados_postmix PARA NAO ENVIAR OS CONVITES 
    PARA A EMPRESA RESPONSAVEL PELA IMPRESSAO.
*************************************************************************/



/* ............................................................................

   Programa: Fontes/crps217.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Dezembro/97.                       Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Emitir extrato de conta corrente (laser)
               Solicitacao: 2
               Ordem: 3
               Relatorio: 171
               Tipo Documento: 7
               Formulario: Extrato-laser.

   Alteracoes: 29/06/98 - Alterado para NAO tratar o historico 289 (Edson).
    
               10/09/98 - Tratar tipo de conta 7 (Deborah). 

               16/10/98 - Colocar "pesos" na leitura por agencia (Deborah).

               22/01/99 - Tratar historico 313 (Odair)

               24/06/99 - Tratar historicos 338,340 (odair)

               02/08/99 - Alterado para ler a lista de historicos de uma tabela
                          (Edson).

               24/07/2000 - Acerto no acesso da tabela que estava comentado
                            (Deborah).

               03/10/2000 - Alterar forma saida do arquivo (Margarete/Planner)
                
               22/11/2000 - Alterar leitura do crapass (Margarete/Planner) 
               
               19/12/2000 - Nao gerar automaticamente o pedido de impressao.
                            (Eduardo).
                            
               03/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               12/01/2001 - Mostrar no extrato de c/c as taxas de juros
                            utilizadas. (Eduardo).

               17/09/2001 - Aumentar o campo nrdocmto para 11 histor. 040
                            (Ze Eduardo).

               31/07/2002 - Incluir nova situacao da conta (Margarete).
               
               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).

               21/05/2003 - Alterado para tratar os historicos 104, 302 e 303
                            (Edson).
                            
               27/06/2003 - Incluir 156 na descricao do historico (Ze).        
               
               17/07/2003 - Antecipado a quinzena do dia 15/08/03 para 
                            14/08/2003 devido a manutencao (Deborah).

               29/01/2004 - Nao emite extrato para situacao de conta 6
                            Nao emite extrato para tipo de extrato 0
                            Colocado mensagem para solicitar o cancelamento
                            do extrato mensal (Deborah).

               16/02/2004 - Colocado mensagem padronizada (Deborah).

               25/04/2005 - Incluido, na linha do "EXTERNO" o nro do cadastro
                            do cooperado na empresa (Evandro).

               08/06/2005 - Incluido tipo de conta 17 e 18(Mirtes).

               07/11/2005 - Nova mensagem no rodape (Margarete).

               22/11/2005 - Alterado para mostrar a alinea na descricao do
                            historico 657 (Edson).

               22/12/2005 - Voltada mensagem anterior do rodape (Magui)

               30/01/2006 - Colocada temporariamente a mensagem dos telefones
                            para a URA (Evandro).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               05/05/2006 - Alterada mensagem p/Viacredi(Mirtes)

               27/12/2006 - Alterado de FormXpress para FormPrint (Julio)

               18/04/2007 - Modificado nome do arquivo aux_nmarqdat (Diego).

               30/05/2007 - Colocado o parametro & no comando FormPrint, para 
                            rodar em Back Ground e liberar o processo (Julio).

               04/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

               05/06/2007 - Envio de Informativos por Email (Diego).

               24/07/2007 - Incluidos historicos de transferencia pela internet
                            (Evandro).

               06/08/2007 - Incluido tratamento para informativos Impressos e
                            enviados por Email (Diego).

               12/09/2007 - Efetuado acerto no Envio de Extrato por E-mail. 
                            Utilizar crapass.cdsitdct = 1 somente para extratos
                            impressos (Diego).

               17/09/2007 - USE-INDEX crapcra1 nas buscas do crapcra (Julio)

               31/10/2007 - Usar nmdsecao a partir do ttl.nmdsecao (Guilherme).

               21/01/2008 - Efetuado acerto para enviar extrato quinzenal
                            impresso ao final do mes (Diego).
                            Envio automatico de arquivos para PostMix (Julio)

               13/02/2008 - Chamar nova include "gera_dados_inform_2_postmix.i"
                            (Diego).

               06/02/2008 - Inclusao da include 
                            sistema/generico/includes/b1wgen0001tt.i
                            (Diego).

               17/03/2008 - Incluidos parametros na procedure "consulta-extrato"
                            (Diego).

               27/03/2008 - Acerto no envia do arquivo para a PostMix. (Julio)

               16/04/2008 - Chamar nova includes "envia_dados_postmix.i" 
                            e incluir linha tracejada no final dos lancamentos
                            (Gabriel).

               07/08/2008 - Substituida variavel aux_nrfonura pelo campo
                            crapcop.nrtelura (Diego).

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                            includes/var_informativos.i (Diego).

               03/03/2009 - Acerto na chamada da BO b1wgen0001 (Diego).

               29/04/2009 - Enviar aux_nmdatspt para vendas@blucopy.com.br
                            das cooperativas 1,2,4 Tarefa: 23747 (Guilherme)
                          - Enviar tambem para variaveis@blucopy.com.br
                            (Evandro).

               09/09/2009 - Tratamento para quebra de pagina do Extrato enviado
                            por e-mail (Diego).
                          - Incluir historicos de transferencia de credito de
                            salario (David).

               07/12/2009 - Acerto na apresentacao das mensagens no rodape do
                            extrato (Junior).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               22/04/2010 - Gravar o PAC do associado na cratext.
                            Unificacao das includes que geram os dados 
                            (Gabriel).

               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).

               01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                            (Vitor).             

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               12/01/2011 - Verificar se registro de e-mail foi encontrado.
                            Mostrar no log se e-mail nao existir (David).

               03/02/2011 - Ajuste do format do numero do documento (Henrique).

               14/03/2011 - Substituir dsdemail da ass para a crapcem (Gabriel).

               04/06/2011 - Mehorias de performance (Magui).

               12/12/2011 - Alteração no campo de Assunto dos 
                            email enviados (Lucas).

               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).

               28/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).

               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].

               08/01/2013 - Acerto da paginacao do extrato (linha > 78)
                            (Guilherme/Supero)
                            
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps217"
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

RUN STORED-PROCEDURE pc_crps217 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper, 
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps217 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps217.pr_cdcritic WHEN pc_crps217.pr_cdcritic <> ?
       glb_dscritic = pc_crps217.pr_dscritic WHEN pc_crps217.pr_dscritic <> ?
       glb_stprogra = IF pc_crps217.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps217.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

/* .......................................................................... */
