/* .............................................................................

   Programa: Fontes/crps538.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Novembro/2009.                   Ultima atualizacao: 20/06/2013
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de TITULOS da Nossa Remessa - Conciliacao.

   Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que 
                            esta no HEADER do arquivo e incluir um resumo ao
                            fim do relatorio de Rejeitados, Integrados e
                            Recebidos (Guilherme/Supero)

               28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                            e sair do laco de importacao do arquivo(Guilherme).

               04/06/2010 - Acertos Gerais (Ze).
               
               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).
               
               28/06/2010 - Alteracao na Busca (FIND LAST) ate verificacao na
                            BO (Ze).
                                                       
               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               26/08/2010 - Incluida importacao diferenciada quando CECRED,
                            gerando relatorio 574 do que nao foi importado nas 
                            cooperativas (Guilherme/Supero)
                            
               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv 
                            (Vitor)             
                            
               12/05/2011 - Tratamento para liquidação da cobrança registrada
                          - Definido explicitamente cada bloco de transacao para
                            conseguir efetuar o comando DDA para JD (Guilherme).
                            
               22/06/2011 - Validar a data do arquivo pelo dtmvtolt e nao pelo
                            dtmvtoan (Guilherme).

               24/06/2011 - Gravar banco/agencia origem do pagamento (Rafael).
               
               11/07/2011 - Quando nao encontrar titulo nas cooperativas singulares
                            gerar registros no relatorio(Guilherme).
                            
               13/07/2011 - Incluir baixa automatica por decurso de prazo 
                            (Guilherme).
                            
               02/08/2011 - Criacao da procedure gera_relatorio_605, que gera
                            o crrl605, para conciliacao dos dados da 
                            Sua Remessa(085). Fabricio
                            
               16/09/2011 - Ajustes gera_relatorio_605. Separar liquidacoes
                            pela COOP e COMPE. (Rafael).
                            
               03/10/2011 - Criticar titulos baixados p/ protesto e 
                            pagos a menor (941 e 940). (Rafael).
                            
               03/11/2011 - Ajuste calculo de titulos pagos em atraso (Rafael)
               
               17/11/2011 - Executar liquidacao intrabancaria DDA dos titulos
                            pagos na compe 085. (Rafael)
                          - Mostrar no relatorio 605 qdo ocorrer liquidacao 
                            de um boleto baixado (943). (Rafael)
                          - Alterado prazo de envio para protesto de titulos
                            vencidos. (Rafael)
               
               08/12/2011 - Utilizado data de pagto do arquivo para realizar
                            calculo de juros/multa. (Rafael)
                            
               23/12/2011 - Alterações para substiuir o campo 'TARIFAS' por
                            'TARIFAS COOP'. (Lucas)
                            
               18/01/2012 - Utilizar vlr de abatimento no calculo do título
                            mesmo vencido. (Rafael)
                            
               13/03/2012 - Alterado prazos de decurso de prazo de titulos
                            em virtude do novo catalogo da CIP 3.05. (Rafael)
                          - Valor de abatimento deve ser aplicado antes do 
                            calculo de juros/multa. (Rafael)
                            
               22/03/2012 - Procedure para gerar rel. 618 (CAC). (Lucas)
               
               23/03/2012 - Importar todos arqs 2*.REM - ref CAF (Guilherme)
                          
               10/04/2012 - Aumento de posicoes na variavel com o no. de 
                            arquivos, para 9999 arquivos (Guilherme).
                            
               18/04/2012 - Identificar pagamento DDA ao processar COB615,
                            cdtipdoc = 140 e 144 (DDA INF e DDA VLB). (Rafael)
                            
               14/05/2012 - Tratamento liq de titulos apos baixa. 
                          - Criado critica 947 - Liq de boleto pago. (Rafael)
                          
               10/08/2012 - Ajuste na rotina de liquidacao de titulos
                            descontados da cob. registrada. (Rafael)
                            
               21/08/2012 - Incluido nrseqdig no campo gncptit.hrtransa para 
[B                            evitar chave duplicada de titulo pago. (Rafael)
                            
               29/08/2012 - Removido inclusao na gncptit ref. a liq de boleto
                            pago. Estava mostrando valor duplicado no 
                            relatorio 533 na central. (Rafael)
                            
               23/11/2012 - Ajustes para títulos migrados da Viacredi para 
                            Alto Vale (Gabriel).             
                            
               04/12/2012 - Nao processar arquivos 2*.REM que nao sejam 
                            COB605. (Rafael)
                            
               12/03/2013 - Conforme circular INFO-CIP 009/2013, foi extinto 
                            TD 44 e 144 do pagto de titulos. (Rafael)
                            
               14/03/2013 - Substituir nmrescop por dsdircop ao gerar
                            relatorio 618. (Rafael)                            
                            
               07/05/2013 - Projeto Melhorias da Cobranca - processar titulos
                            da cobranca 085 - sem registro. (Rafael)
                          - Utilizado ROUND nas rotinas de cálculo de juros
                            e multa. (Rafael)
                            
               31/07/2013 - Incluso processo para geracao log com base tabela 
                            crapcol. (Daniel) 
                            
               26/09/2013 - Incluso parametro tt-lat-consolidada nas chamadas
                            de instrucoes da b1wgen0088. Incluso processo de 
                            cobranca tarifa consolidadas (Daniel).
               
               11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               15/11/2013 - Novos ajustes no processamento "COMPEFORA" (Rafael).                            
               
               20/06/2014 - AJuste na chamada da store-procedure, armazenar o 
                            proc-handle (Odirlei-AMcom)
              
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps538"
       glb_flgbatch = FALSE
       glb_cdoperad = "1"
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

RUN STORED-PROCEDURE pc_crps538 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper, 
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_nmtelant,
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

CLOSE STORED-PROCEDURE pc_crps538 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps538.pr_cdcritic WHEN pc_crps538.pr_cdcritic <> ?
       glb_dscritic = pc_crps538.pr_dscritic WHEN pc_crps538.pr_dscritic <> ?
       glb_stprogra = IF pc_crps538.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps538.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


