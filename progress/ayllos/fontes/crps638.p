/*..............................................................................

    Programa: fontes/crps638.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 20/02/2019

    Dados referente ao programa:

    Frequencia : Diario (Batch).
    Objetivo   : Convenios Sicredi - Relatório de Conciliação.
                 Chamado Softdesk 43337.

    Alteracoes : 06/05/2013 - Alteração para rodar em cada cooperativa (Lucas).

                 24/05/2013 - Tratamento DARFs (Lucas).

                 03/06/2013 - Correção format vlrs totais (Lucas).

                 11/06/2013 - Somatória de multas e juros ao campo de
                              valor da fatura e melhorias em consultas
                              (Lucas).

                 14/06/2013 - Correção listagem DARF SIMPLES (Lucas).

                 19/06/2013 - Quebra de listagem de convenios por segmto (Lucas).

                 24/06/2013 - Rel.636 Totalização por Cooperativa (Lucas).

                 15/08/2013 - Incluir procedure tt-totais para totalizar por
                              convenios e ordenar pela quantidade total maior
                              para menor no rel636 (Lucas R.).

                 23/04/2014 - Alterar campo.crapscn.nrdiaflt por dsdianor
                              Softdesk 142529 (Lucas R.)

                 24/04/2014 - Inclusao de FIELDS para os for craplft e crapcop
                              (Lucas R.)

                 28/04/2014 - Inclusão de deb. automatico para os relatorios
                              crrl634,crrl635,crrl636 Softdesk 149911 (Lucas R.)

                 05/05/2014 - Ajustes migracao Oracle (Elton).

                 17/06/2014 - 135941 Correcao de quebra de pagina e inclusao do
                              campo vltardrf nos fields da crapcop, procedure
                              gera-rel-mensal-cecred (Carlos)

                 06/08/2014 - Ajustes de paginacao e espacamentos no relatorio
                              crrl636, nos totais de DEBITO AUTOMATICO e
                              TOTAL POR MEIO DE ARRECADACAO (Carlos)

                 29/12/2014 - #232620 Correcao na busca dos convenios que nao
                              sao de debito automatico com a inclusao da clausula
                              crapscn.dsoparre <> "E" (Carlos)

                 06/01/2015 - #232620 Correcao do totalizador de receita liquida
                              da cooperativa para deb automatico e totalizadores
                              gerais do relatorio 636 (Carlos)

                 24/02/2015 - Correção na alimentação do campo 'tt-rel634.vltrfuni'
                              (Lunelli - SD 249805)

                30/04/2015 - Proj. 186 -> Segregacao receita e tarifa em PF e PJ
                             Criacao do novo arquivo AAMMDD_CONVEN_SIC.txt
                             (Guilherme/SUPERO)

                26/06/2015 - Incluir Format com negativo nos FORMs do rel634 no 
                             campo vlrecliq (Lucas Ranghetti #299004)
                                   
                06/07/2015 - Alterar calculo no meio de arrecadacao CAIXA no 
                             acumulativo do campo tt-rel634.vlrecliq, pois estava
                             calculando a tarifa errada. (Lucas Ranghetti #302607)
                             
                21/09/2015 - Incluindo calculo de pagamentos GPS.
                             (André Santos - SUPERO)
                             
                04/12/2015 - Retirar trecho do codigo onde faz a reversao 
                             (Lucas Ranghetti #326987 )
                             
                11/12/2015 - Adicionar sinal negativo nos campos tot_vlrliqpj e 
                             deb_vlrliqpj crrl635 (Lucas Ranghetti #371573 )
                
                06/01/2016 - Retirado o valor referente a taxa de GPS do cabecalho 
                             do arquivo que vai para o radar. (Lombardi #378512)
                
                19/05/2016 - Adicionado negativo no format do f_totais_rel635 
                             (Lucas Ranghetti #447067)
                             
                06/09/2016 - Inclusao coluna Tarifa Sicredi (Projeto 338 - Lucas Lunelli)
				
                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)	
  							 
	        	07/10/2016 - Alteração do diretório para geração de arquivo contábil.
                             P308 (Ricardo Linhares).			 			
                            
                21/02/2017 - Conversao Progress para PLSQL (Jonata - Mouts)    
                             
                20/02/2019 - Inclusao de log de fim de execucao do programa 
                             (Belli - Envolti - Chamado REQ0039739)               
                            
............................................................................. */

{ includes/var_batch.i "new" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "CRPS638"
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

RUN STORED-PROCEDURE pc_crps638 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps638 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps638.pr_cdcritic WHEN pc_crps638.pr_cdcritic <> ?
       glb_dscritic = pc_crps638.pr_dscritic WHEN pc_crps638.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps638.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps638.pr_infimsol = 1 THEN
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS638.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS638.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }                                             
                  
RUN fontes/fimprg.p.

/* .......................................................................... */