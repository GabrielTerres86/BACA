/* ............................................................................

   Programa: Fontes/crps573.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2010                       Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Gerar arquivo(3040) Dados Individualizados de Risco de Credito
               Juncao do 3020 com o 3030
               Geracao de relatorio para conferencia
               Solicitacao : 80
               Ordem do programa na solicitacao = 4.
               Relatorio 566 e 567.
               Programa baseado no crps368
               Programa baseado no crps369 (tag <Agreg>)
                                      
   Alteracoes : 03/03/2011 - Retirar critica acima de 5milhoes e tratamento 
                             para garantia nao fidejussoria (Guilherme).
                                                         
                12/07/2011 - Realizado alteracao para atender ao novo layout
                             (Adriano).
                             
                05/08/2011 - Incluido atributo VarCamb. (Irlan)
                
                08/08/2011 - Incluido atibuto DiaAtraso (Irlan)
                
                12/09/2011 - Não permitir faturamento anual negativo (Irlan)
                
                04/10/2011 - Inserido Cosif e PercIndx (Irlan)
                
                19/10/2011 - Incluido os dados da central de risco no 
                             cabecalho do arquivo 3040 (Adriano).
                             
                29/12/2011 - Mudança de critério para sobre operações de 
                             crédito por solicitação do Banco Central 
                             (Irlan/Lucas).
 
                05/06/2012 - Ajuste na provisao (Gabriel).
                
                17/08/2012 - Removido Procedure 
                             verifica_garantidores_nao_fidejussorio
                             e sua chamada. (Lucas R.)
                             
                25/09/2012 - Inicializado aux_cddesemp com 1 ao inves de zero 
                             (Irlan)
                             
                10/10/2012 - Tratar campo de modalidade quando 299, 499
                             (Gabriel).   
                             
                22/11/2012 - Ajuste divida estancada (Tiago).                  
                           - Ajustar lanctos da crapris com cdorigem 4 e 5
                             como um unico lancto (Rafael).
                             
                04/01/2013 - Criada procedure verifica_conta_altovale_573
                             para desprezar as contas migradas (Tiago).
                
                14/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                             consulta da craptco (Tiago).  
                             
                21/01/2013 - Gerar as saídas das operações. (Tiago)                             
                
                21/01/2013 - Inclusao do UNFORMATTED na inpressao da tag < inf
                             e inclusao multiplicacao por 100 para buscar o valor
                             inteiro (Lucas R.).
                             
                22/01/2013 - Incluir validacao para para alterar modalidade
                             0203 para 0206 somente se for pessoa fisica 
                             (Lucas R.)      
                             
                08/02/2013 - Ajustes processo de geracao entradas e saidas (Daniel).  
                
                14/02/2013 - Ajustes processo de geracao entradas e saidas para tratar
                             re-geracao do arquivo.(Daniel).     
                
                01/04/2013 - Incluso procedure verifica_garantia_alienacao_fiduciaria
                             (Daniel).
                             
                24/04/2013 - Incluso tratamento para empresimos/financiamentos migrados para
                             Altovale, incluso registro <Inf Tp="1001" nos casos de 
                             cdnatuop = "02" (Daniel).
                
                17/05/2013 - Incluido tratamento de arredondamento na rotina 
                             normaliza_juros, acrescentado ao indice tt-agreg
                             o campo cdvencto e adicionado chamada da procedure
                             busca_modalidade para retirar repeticao de codigo
                             (Tiago).
                             
                17/06/2013 - Tratamento para emprestimos do BNDES; leitura
                             da crapebn quando crapvri.cdmodali = 0499 ou 0299.
                             (Fabricio)
                             
                11/07/2013 - Ajustes no arq3040 devido a quebra por cpf nao
                             estar apresentando os resultados conforme desejado
                             foi necessario realizar a mesma pegando apenas as
                             8 primeiras posicoes do cpf (Tiago).
                             
                05/08/2013 - Chamada da procedure busca_taxeft nos pontos
                             em que se precisa calcular a taxa efetiva anual.
                             (Fabricio)
                             
                14/08/2013 - Incluida procedure verifica_inf_chassi que cria
                             tag <inf> quando modalidade=04 e sub=01 e conter
                             informacoes do chassi (Tiago).   
                             
                26/08/2013 - Incluida regra na procedure verifica_inf_chassi
                             para considerar apenas ("AUTOMOVEL,MOTO,CAMINHAO")
                             do campo crapbpr.dscatbem (Tiago).
                             
                29/08/2013 - incluida procedure 
                             verifica_inf_aplicacao_regulatoria que cria tag
                             <inf> para contratos com linha de credito "DIM"
                             (Tiago).
                             
                17/03/2013 - Ajustado os valores de referencia de faturamento
                             anual para definicao do porte de cliente PJ
                             (Adriano)            

                05/12/2013 - Renomeada procedure verifica_conta_altovale_573
                             para verifica_conta_migracao_573 que despreza
                             as contas migradas (Tiago).

                04/04/2018 - Incluso parametros para agencia (pr_cdagenci) e identificação de paralelo (default 0)
				             para atender Projeto Ligeirinho.


                             
.............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps573"
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

RUN STORED-PROCEDURE pc_crps573 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT 0,
	INPUT 0,                                                  
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

CLOSE STORED-PROCEDURE pc_crps573 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps573.pr_cdcritic WHEN pc_crps573.pr_cdcritic <> ?
       glb_dscritic = pc_crps573.pr_dscritic WHEN pc_crps573.pr_dscritic <> ?
       glb_stprogra = IF pc_crps573.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps573.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


