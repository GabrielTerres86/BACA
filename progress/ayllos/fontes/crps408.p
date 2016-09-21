/* ..........................................................................

   Programa: Fontes/crps408.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Setembro/2004.                  Ultima atualizacao: 10/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao 027.
               Gerar arquivo de pedido de cheques.
               Relatorios :  392 e 393 (Cheque)
                             572 e 573 (Formulario Continuo)

   Alteracoes: 14/03/2005 - Modificada a busca da data do tempo de conta do
                            associado (Evandro).
                            
               18/03/2005 - Modificado o FORMAT da C/C INTEGRACAO (Evandro).

               05/07/2005 - Alimentado campo cdcooper das tabelas crapchq e
                            crapped (Diego).
                            
               16/08/2005 - Alterar recebimento de email de talonarios (de
                            fabio@cecred para douglas@cecred) (Junior).
                            
               03/10/2005 - Formulario Continuo ITG (Ze).
               
               13/10/2005 - Ajuste no "Cooperado desde" (Ze).
               
               17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               31/10/2005 - Tratar crapchq.nrdctitg, crapreq.dtpedido e
                            crapreq.nrpedido (Ze).
                            
               02/11/2005 - Substituicao da condicao crapfdc.nrdctitg = STRING(
                            aux_nrdctitg por crapfdc.nrdctitg = 
                            crapass.nrdctitg. (SQLWorks - Andre).
                            
               07/12/2005 - Revisao do crapfdc (Ze Eduardo).          
                  
               23/12/2005 - Inclusao do parametro "tipo de cheque" no fonte
                            calc_cmc7.p  (Julio).
                            
               20/01/2006 - Acerto no relatorio de criticas (Ze).
               
               09/02/2006 - Nao solicitar para Cta. Aplicacao (Ze).
               
               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               18/08/2006 - Alteracao para solicitar taloes de 10 folhas
                            (Julio)

               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David)
                            Mudanca de CGC para CNPJ (Ze). 
                            
               29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                            mais de um titular (Ze).

               13/12/2006 - Alterado envio de e-mail de makelly@cecred.coop.br
                            para jonathan@cecred.coop.br (David).
                            
               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).
                            
               27/02/2007 - Tirar condicao p/ tipo 3 - tratar conforme qtd.
                            folhas no cadastro do cooperado (ass).
                            Tirar condicao p/ tipo 3 - put no arq.p/ interprint 
                            qdo conta <> conta_ant e tprequis <> tprequis_ant
                            (Ze Eduardo).
                            
               19/03/2007 - Padronizacao dos nomes de arquivo (Ze).
               
               21/03/2007 - Acerto no programa (Ze).
               
               18/04/2007 - Tratar sequencia do nro pedido atraves do gnsequt
                            Sequencia unica para todas as cooperativas e
                            Acerto no programa para conta com 8 digitos (Ze).
                            
               30/04/2007 - Para Bancoob eliminar Grp. SETEC e tratar C1 E
                            Acerto no CHEQUE ESPECIAL para Bancoob (Ze).
                            
               18/05/2007 - Mudanca de leiate referente ao Grp. SETEC 
                            Segundo Digito do 3o Campo do CMC-7 (Ze). 
               
               14/08/2007 - Alterado para pegar a data de abertura de conta mais
                            antiga do cooperado cadastrada na crapsfn (Elton).
               
               09/10/2007 - Remover envio de email de talonarios (douglas@cecred
                            e jonathan@cecred) (Guilherme).
                            
               25/02/2008 - Enviar arquivos para Interprint atraves da Nexxera
                            (Julio).
                            
               02/07/2008 - Nao tratar mais os formularios continuos pois o
                            programa crps296.p faz isso (Evandro).

               19/08/2008 - Tratar pracas de compensacao (Magui).
               
               02/12/2008 - Utilizar agencia na geracao do arq BB pelo
                            crapcop.cdageitg e calcular o digito da agencia
                            (Guilherme).
                            
               27/02/2009 - Acerto na formatacao do crapcop.cdageitg - digito
                            da agencia (Ze).
                            
               26/05/2009 - Permitir gerar relatorios de pedidos zerados para
                            Intranet (Diego).
                            
               30/09/2009 - Adaptacoes projeto IF CECRED 
                          - Alterar inhabmen da crapass para crapttl(Guilherme).
                          
               01/03/2010 - Tratar formulario continuo para IF CECRED
                            (Voltar alteração do dia 02/07/2008) (Guilherme).
                            
               30/07/2010 - Verificar AVAIL crapage para endereco do PAC
                            (Guilherme).
                            
               25/08/2010 - A pedidos do suprimentos, criar relatorios 572 e 573
                            para Form. Cont. baseado no 247 e 248 (Guilherme).
                            
               11/10/2010 - Acerto no rel. 572 - rel_cdagenci (Trf.35393) (Ze).
               
               10/02/2011 - Utilizar camnpos ref. Nome no talao - crapttl
                           (Diego).
                           
               18/08/2011 - Alimentar campo da Data Confec. do Cheque (Ze).
               
               12/12/2011 - Imprimir somente os relatorios do Banco 085 
                            - Trf. 43974 (Ze).
               
               10/10/2013 - Chamada Stored Procedure do Oracle
                            (Andre Euzebio / Supero)
............................................................................ */


{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps408"
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

RUN STORED-PROCEDURE pc_crps408 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps408 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps408.pr_cdcritic WHEN pc_crps408.pr_cdcritic <> ?
       glb_dscritic = pc_crps408.pr_dscritic WHEN pc_crps408.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps408.pr_stprogra = 1 THEN
                          TRUE 
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps408.pr_infimsol = 1 THEN
                          TRUE
                      ELSE
                          FALSE.
                          
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
