/* .............................................................................

   Programa: fontes/crps545.p
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Dezembro/2009.                     Ultima atualizacao: 26/05/2018
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivo de transferencia de creditos do software
               Cabine financeira da empresa JD Consultores
               
   Observacoes: Do programa:
                - Executado no processo noturno. Cadeia EXCLUSIVA.
                  (Somente processo da Cecred);
                - Fara a leitura de um arquivo txt e ira extrair os dados para
                  uma tabela generica (gnmvspb);
                - Arquivo com extensao texto (.txt);
                  
                Do arquivo:
                - Possui um cabecalho, e um rodape e nas linhas intermediarias
                  contem uma transacao por linha
                - Separacao posicional de campos
                - Formatacao do nome do arquivo a ser importado:
                  ISPB_DataInicioPeriodo_DataFimPeriodo.txt
                - Diretorio onde ele eh disponibilizado: /micros/cecred/spb
                
   Alteracoes: 19/05/2010 - Incluido comando REPLACE na atribuicao do campo
                            crawint.vllanmto (Diego).
                            
               17/12/2010 - Tratamento para numero de conta maior que 9
                            digitos (Diego).
                            
               05/05/2011 - Incluido tratamento ref. codigo de agencia das
                            mensagens de devolucao (Diego).             
                
               19/09/2011 - Incluido novo campo criado na tabela gnmvspb 
                            (Henrique).
                            
               18/01/2012 - Tratar data no nome do arquivo (Diego).    
               
               04/04/2012 - Alteração do campo cdfinmsg para dsfinmsg.
                            (David Kruger).        
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).   
               
               17/10/2012 - Tratamento contas transferidas (Diego).
               
               22/01/2013 - Quando TEC salario utilizar campos da Conta Debito
                            do arquivo (Diego).
               
               19/07/2013 - Na verificação das STR´s, setar aux_cdagectl em 
                            função do código de barras, descobrindo a 
                            cooperativa pelo código do convenio (Carlos).
                            
               22/10/2013 - Retirada a var aux_flgregis, nao utilizada (Carlos)
               
               06/11/2013 - Melhoria na performance retirando o RUN da BO 46 de
                            dentro do FOR EACH da crawint (Carlos)
                            
               18/12/2014 - Tratamento contas incorporadas CONCREDI e CREDIMILSUL
                           (Diego).       
                           
               26/03/2015 - Correção de status do movimento e codigo da cooperativa 
                            para VRBOLETO(STR0026R2). (SD 269372 - Carlos Rafael Tanholi)
                            
               11/08/2015 - Comentado tratamento para contas incorporadas 
                            (Diego). 

               28/07/2015 - Corrigida atribuicao da variavel aux_nrcpfcre nas 
                            mensagens de TEC Salario (Diego).                        

               29/03/2016 - Ajustado tratamento para validacao das contas
                            migradas ACREDI >> VIACREDI 
                            (Douglas - Chamado 424491)

               23/05/2016 - Ajustado tratamento para validacao das contas
                            migradas VIACREDI >> VIACREDI ALTO VALE
                            (Douglas - Chamado 406267)

               26/12/2016 - Tratamento incorporação Transposul (Diego).

               13/01/2017 - Incorporacao - Tratado recebimento de TED para 
                            agencia antiga e conta de destino invalida, para 
                            criar registro na gnmvspb com cdcooper da coop.
                            nova, pois estava criando com a coop. antiga e nao
                            ocorria centralizacao (Diego).
                  
               02/02/2017 - Ajustado para que seja possivel importar os arquivos 
                            do SPB para quando o Bacen estiver em crise 
                            (Douglas - Chamado 536015)
                            
               07/03/2017 - Na mensagem STR0010R2 originada pelo sistema MATERA
                            foi adicionado tratamento para enviar por e-mail.
                            (Ricardo Linhares - Chamado 625310)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
                                             
               18/10/2018 - Marcelo Telles Coelho - Projeto 475 - Sprint C
                          - Passar a chamar a procedure Oracle PC_CRPS545

............................................................................ */
{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps545"
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

RUN STORED-PROCEDURE pc_crps545 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT INT(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps545 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps545.pr_cdcritic WHEN pc_crps545.pr_cdcritic <> ?
       glb_dscritic = pc_crps545.pr_dscritic WHEN pc_crps545.pr_dscritic <> ?
       glb_stprogra = IF pc_crps545.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps545.pr_infimsol = 1 THEN TRUE ELSE FALSE.


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
