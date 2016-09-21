/* ..........................................................................

   Programa: Fontes/crps387.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                        Ultima atualizacao: 23/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 092.
               Integrar Arquivos Debito Automatico(GENERICO)
               Emite relatorio 344.
   
   Alteracoes: 31/05/2004 -  Alterado tamanho campo contrato(impressao). 
                             Desprezar convenios que nao pertencam a
                             cooperativa(Mirtes)

               08/06/2004 - Mover arquivos diretorio integra para diretorio
                            salvar(quando nao estiverem parametrizados na
                            tabela de convenios)(Mirtes)
                            
               24/06/2004 - Tratamento de erro. (Ze Eduardo).           
                 
               26/07/2004 - Sequenciar pelo numero do convenio (Mirtes).
               
               27/07/2004 - Alterado path /usr/nexxera(Mirtes).

               29/11/2004 - Tratamento para recebimento do registro "D" (Julio)
                
               03/02/2005 - Acerto para atribuicao do numero do documento
                            para o craplau (Julio)

               22/02/2005 - Alterada a forma de leitura do codigo do cliente 
                            no convenio (Julio)

               06/03/2005 - Tratamento para Convenio 22 (Julio)
               
               19/04/2005 - Tratamento para Registro "D", aceitar referencias 
                            com ate 25 digitos (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas crapndb,
                            craplot, craplau, crapavs, e do buffer crabatr
                            (Diego).

               12/07/2005 - Tratamento UNIMED Blumenau -> 509 (Julio)

               12/08/2005 - Nao tirar mais a data de cancelamento da 
                            autorizacao quando um convenio enviar rejeicao de 
                            cancelamento (Julio).
                            
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Comparar valor do lancamento para verificar
                            duplicidades, so consistir se o valor for igual.
                            (Julio)
                            
               11/10/2005 - Comparar nrseqdig para cada lancamento (Julio)
                            
               07/11/2005 - Tratamento especial para registro duplicado da 
                            UNIMED (Julio)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               20/02/2006 - Fazer importacao de registros tipo "B" para a
                            criacao da crapatr (Evandro).

               03/05/2006 - Criticar contas com numero maior que 8 digitos 
                            vindas no arquivo (Julio)

               12/05/2006 - Tratamento para registros duplicados UNIMED 22
                            (Julio)
                            
               21/06/2006 - Retirada NO-LOCK leitura craplau(erro)(Mirtes)
               
               22/08/2006 - Tratamento para numeros de conta, maiores do que
                            o suportado por uma variavel INTEGER (Julio)

               27/11/2006 - Apresentar relatorio de inclusoes e cancelamentos
                            quando for debito automatico (B) (Elton).
                            
               30/03/2007 - Utilizar o historico na busca do tipo D (Evandro).
               
               07/05/2007 - Atualizar os registros da craplau quando for tipo
                            "D" (Evandro).
               
               29/05/2007 - Inclui informacoes na tabela gnarqrx quando 
                            convenio requer confirmacao de recebimento do
                            arquivo enviado (registro "J") (Elton).
               
               26/09/2007 - Alterado para incluir "0" no numero de documento dos
                            registros duplicados mais de uma vez do convenio
                            UNIMED 22 (Elton).

               02/01/2008 - Tratamento na integracao de arquivo da uniodonto
                            quando conta nao existir na cooperativa (David).
               
               02/04/2008 - Incluido cdcooper e EXCLUSIVE-LOCK na transacao que
                            apaga os dados da tabela generica gncontr (Elton).

               04/06/2008 - Campo dsorigem nas leituras da craplau 
                          - Campo cdcooper nas leituras da craphis (David)
                          
               20/10/2008 - Nao permite debito de contas que estejam demitidas;
                          - Mostra no relatorio 344, critica 447 quando conta
                            estiver cancelada (Elton).
               
               12/11/2008 - Nao mostrar critica no log quando o motivo for
                            cancelamento de debito (Elton).
               
               14/11/2008 - Possibilita o cadastramento de debito quando receber
                            registro do tipo "E" e gnconve.flgindeb = TRUE
                            (Elton).
               
               22/12/2008 - Tratado problemas com contas transferidas (Elton).
               
               16/01/2009 - Alteracao CDEMPRES (Kbase).
               
               23/01/2009 - Preenche o campo "crapatr.nmempres" quando for
                            incluido autorizacao de debito para  convenio 586
                            (Elton).
                            
               27/02/2009 - Corrigido tamanho do nome do arquivo (Diego).
               
               03/03/2009 - Recebe registros de cadastramento "B" do convenio
                            ADDMAKLER - 39 sem a necessidade da Declaracao
                            (Elton).

               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - Paulo.
               
               07/08/2009 - Nao permite incluir autorizacoes quando convenio for
                            UNIODONTO - 32 (Elton).

               17/08/2009 - Alterado para permitir inclusao de autorizacoes
                            quando convenio for UNIODONTO - 32 (Elton).
                            
               23/09/2009 - Nao mostra no log a critica de autorizacao de debito
                            ja cadastrada; 
                          - Mostra no relatorio e no log critica de lancamento
                            automatico ja existente "craplau" (Elton).
                            
               16/10/2009 - Tratamento para convenio 38 - Unimed Planalto Norte
                            (Elton).
                            
               03/09/2010 - Tratamento para convenio 48 - TIM Celular 
                          - Se cooperado estiver com autorizacao cancelada, 
                            nao limpa o campo crapatr.dtfimatr, caso o convenio 
                            mande um debito e estiver com gnconve.flgindeb = 
                            TRUE (Elton).
                            
               29/03/2011 - Acerto no tratamento da Unimed - 22 (Elton).
               
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               17/06/2011 - Criticar desagendamento de debito quando debito
                            nao tiver sido agendando (Elton).
                            
               05/07/2011 - Tratamento para registros duplicados da 
                            Liberty - 55 (Elton).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               23/01/2012 - Tratar conta invalida (Guilherme/Supero)
               
               15/06/2012 - Substituição da critica 127 pela chamada da
                            procedure critica_debito_cooperativa (Lucas R.).
                            
               19/06/2012 - Inclusão de chamada na linha 908 para a procedure 
                            critica_debito_cooperativa e tratamento para 
                            critica 13 (Lucas R.).
                            
               03/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                            código do convênio (Guilherme Maba). 
                            
               06/07/2012 - Substituido gncoper por crapcop (Tiago).             
               
               20/09/2012 - Tratamento para migracao Alto Vale (Elton).
               
               30/11/2012 - Acerto para migracao Alto Vale (Elton).
               
               27/02/2013 - Na linha 2212 incluir IF aux_tpregist = "E" grava o
                            w-relato.vllanmto se nao atribui "0".
                          - Na linha 2198 incluir IF  par_flgtxtar = 1 grava o
                            crabcop.cdcooper se nao faz como antes (Lucas R.).
                          - Tratamento para codigo de referencia zerado (Elton).
                          
               03/06/2013 - Incluido no FOR EACH,FIND FIRST e FIND a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               05/11/2013 - Tratamento migracao Acredi (Elton).
               
               27/11/2013 - Ajustar programa para tratar o campo agencia dos 
                            arquivos de debito automatico (Lucas R.)
                            
               22/01/2014 - Incluir VALIDATE gnarqrx,gncontr,crapatr,crabatr, 
                            craplot,craplau,crapndb,crapavs (Lucas R)
                            
               23/01/2014 - Ajustes referentes ao Max.Int para nrdconta 
                            (Lucas R)
                            
               02/04/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................ */
                          
{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps387"
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

RUN STORED-PROCEDURE pc_crps387 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps387 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps387.pr_cdcritic WHEN pc_crps387.pr_cdcritic <> ?
       glb_dscritic = pc_crps387.pr_dscritic WHEN pc_crps387.pr_dscritic <> ?
       glb_stprogra = IF pc_crps387.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps387.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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